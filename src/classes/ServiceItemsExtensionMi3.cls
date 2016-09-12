public with sharing class ServiceItemsExtensionMi3 {
    private static String PREPARE_FILING_PACKAGE_RT_NAME = 'Prepare Filing Package';
    private static String PREPARE_FILING_PACKAGE_CATEGORY_COMPLETE_STATUS = 'Package Completed';

    public final Project_Profile__c project { get; set; }
    public List<ServiceItemWrapperMi3> serviceItemWrappers { get { if( serviceItemWrappers == null ) serviceItemWrappers = new List<ServiceItemWrapperMi3>(); return serviceItemWrappers; } set; }
    public Boolean isValid { get { if( isValid == null ) isValid = true; return isValid; } set; }
    private String profileName;

    public ServiceItemsExtensionMi3( ApexPages.StandardController controller ) {
        Boolean isAllOSServices = true;
        profileName = ProposalWizardServices.getProfileNameById( UserInfo.getProfileId() );
        project = (Project_Profile__c)controller.getRecord();
        for( Service_Item__c serviceItem : [ SELECT Id, Name, Service_Group__c, Service_Name_Full__c, Municipal_Agency_ID__c,
                                                    Actual_Start_Date__c, Actual_End_Date__c, Expected_Start_Date__c,
                                                    Expected_End_Date__c, Row_Position__c, Row_Position_Project__c,
                                                    Actual_Start_Date_Is_From_Terminator__c, Service_Template__r.Service_Row_Number__c,
                                                    ( SELECT Id, Name, Status__c, Predecessor_Task__c, Successor_Task__c, RecordType.Name,
                                                             Actual_Start_Date__c, Actual_End_Date__c, Sequence_Number__c,
                                                             Expected_Start_Date__c, Expected_End_Date__c, Expected_Duration__c, Actual_Duration__c,
                                                             Is_Application_Filing_Checklist_Complete__c, No_Checklist_Required_Service__c
                                                      FROM Task_Items__r
                                                      ORDER BY Sequence_Number__c ASC )
                                             FROM Service_Item__c
                                             WHERE Project_Profile__c = : project.Id
                                               AND Is_Alternative__c = false
                                             ORDER BY Row_Position__c ASC, Phase__r.Number__c ASC, Row_Position_Project__c ASC, Predecessor_Milestone__c ASC, Successor_Milestone__c ASC, CreatedDate ASC, Name ASC, Id ASC ] ) {
            if( !String.isBlank( serviceItem.Service_Template__r.Service_Row_Number__c ) &&
                !serviceItem.Service_Template__r.Service_Row_Number__c.startsWith( ServiceItemServices.OS_SERVICE ) ) {
                isAllOSServices = false;
            }
            serviceItemWrappers.add( new ServiceItemWrapperMi3( serviceItem ) );
        }
        if( !isAllOSServices && ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER_QA ) ) {
            MilroseDevHelper.addMessage( 'You can not perform task termination: this is not an OS-services-only Project.' );
            isValid = false;
        }
    }

    public String currentTaskId { get; set; }
    public String currentServiceId { get; set; }
    public void setStatus() {
        for( ServiceItemWrapperMi3 serviceItem : serviceItemWrappers ) {
            if( serviceItem.record.Id == currentServiceId ) {
                serviceItem.selectedTaskItemId = currentTaskId;
                serviceItem.currentTaskItemWrapper = String.isBlank( currentTaskId ) ? serviceItem.taskItemWrappers.get( null ) : serviceItem.taskItemWrappers.get( currentTaskId );
            }
        }
    }

    public void calcutateDates() {
        if( !isTerminateTasksButtonValid( true ) ) {
            return;
        }
        List<Task_Item__c> taskItemsToUpdate = new List<Task_Item__c>();
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        List<TaskItemWrapperMi3> taskItemWrappers;
        Integer currentTaskItemWrapperNumber;
        DateTime projectStartDate, startDate, endDate;
        for( ServiceItemWrapperMi3 serviceItemWrapperItem : serviceItemWrappers ) {
            Service_Item__c serviceItem = serviceItemWrapperItem.record.clone(true);
            //0-th task wrapper has the null task record for the page view purposes
            if( serviceItemWrapperItem.currentTaskItemWrapper.record != null ) {
                taskItemWrappers = serviceItemWrapperItem.taskItemWrappersList;
                currentTaskItemWrapperNumber = Integer.valueOf( serviceItemWrapperItem.currentTaskItemWrapper.taskNumber );
                endDate = serviceItemWrapperItem.taskItemForDate.Actual_End_Date__c;
                if( currentTaskItemWrapperNumber == taskItemWrappers.size() - 1 ) {
                    serviceItem.Actual_End_Date__c = serviceItemWrapperItem.record.Expected_End_Date__c = endDate;
                }
                for( Integer i = currentTaskItemWrapperNumber; i > 0; i-- ) {
                    Task_Item__c taskItem = taskItemWrappers[i].record.clone(true);
                    if( i == currentTaskItemWrapperNumber ) {
                        taskItem.Status__c = taskItemWrappers[i].newStatus;
                    } else {
                        taskItem.Status__c = taskItemWrappers[i].completeStatusesList[0]; //for different complete statuses taking the first one (prevalent are first)
                    }
                    taskItem.Actual_End_Date__c = taskItem.Expected_End_Date__c = endDate;
                    startDate = DateUtils.getDatetimeWithTimeShiftByBusinessHours( endDate, taskItem.Expected_Duration__c, false );
                    taskItem.Actual_Start_Date__c = taskItem.Expected_Start_Date__c = startDate;
                    if( taskItem.RecordType.Name == PREPARE_FILING_PACKAGE_RT_NAME && taskItem.Status__c == PREPARE_FILING_PACKAGE_CATEGORY_COMPLETE_STATUS ) {
                        taskItem.Is_Application_Filing_Checklist_Complete__c = true;
                        taskItem.No_Checklist_Required_Service__c = true;
                    }
                    taskItem.Name = (TaskServices.TERMINATED_TASK_NAME_PREFIX + taskItem.Name).left(80);
                    //taskItem.Actual_Duration__c = taskItem.Expected_Duration__c;
                    endDate = startDate;
                    taskItemsToUpdate.add( taskItem );
                }
                serviceItem.Actual_Start_Date__c = serviceItem.Expected_Start_Date__c = startDate;
                serviceItem.Actual_Start_Date_Is_From_Terminator__c = true;
                if( projectStartDate > startDate || projectStartDate == null ) {
                    projectStartDate = startDate;
                }
            }
            serviceItem.Row_Position_Project__c = serviceItem.Row_Position__c;
            serviceItemsToUpdate.add( serviceItem );
        }
        project.Project_Start_Date__c = Date.valueOf( projectStartDate );
        project.RecordTypeId = RecordTypeServices.getRecordTypesForObjectByDeveloperNames( ProjectProfileServices.PROJECT_SOBJECT_NAME,
                                                                                           new Set<String>{ ProjectProfileServices.PROJECT_STANDARD_DEVELOPERNAME } ).values()[0].Id;
        System.Savepoint sp_calcutateDates = Database.setSavepoint();
        try {
            UPDATE taskItemsToUpdate;
            UPDATE serviceItemsToUpdate;
            UPDATE project;
        } catch( dmlException dmlEx ) {
            Database.rollback( sp_calcutateDates );
            for ( Integer dmlExIndex = 0; dmlExIndex < dmlEx.getNumDml(); dmlExIndex++ ) {
                MilroseDevHelper.addMessage( 'Error occurred: ' +  dmlEx.getDmlMessage( dmlExIndex ) );
            }
        }
    }

    public Boolean isTerminateTasksButtonValid { get { return isTerminateTasksButtonValid( false ); } set; }
    public Boolean isTerminateTasksButtonValid( Boolean isAddMessage ) {
        if( !isValid ) {
            return false;
        }
        Boolean terminateTasksButtonValid = true;
        for( ServiceItemWrapperMi3 serviceItem : serviceItemWrappers ) {
            if( serviceItem.currentTaskItemWrapper.record != null ) {
                if( ( serviceItem.currentTaskItemWrapper.completeStatusesSet.contains( serviceItem.currentTaskItemWrapper.newStatus ) &&
                      serviceItem.taskItemForDate.Actual_End_Date__c == null ) ||
                    ( !serviceItem.currentTaskItemWrapper.completeStatusesSet.contains( serviceItem.currentTaskItemWrapper.newStatus ) ) ) {
                        if( isAddMessage ) MilroseDevHelper.addMessage( 'Values for Service ' + serviceItem.record.Name + ' are improper.' );
                        terminateTasksButtonValid = false;
                }
            }
        }
        return terminateTasksButtonValid;
    }


    public class ServiceItemWrapperMi3 {
        public Service_Item__c record { get; set; }
        public Map<Id, TaskItemWrapperMi3> taskItemWrappers { get { if( taskItemWrappers == null ) taskItemWrappers = new Map<Id, TaskItemWrapperMi3>(); return taskItemWrappers; } set; }
        public List<TaskItemWrapperMi3> taskItemWrappersList = new List<TaskItemWrapperMi3>();
        public TaskItemWrapperMi3 currentTaskItemWrapper { get; set; }
        public List<SelectOption> taskItemsOptions { get { return createtaskItemsOptions(); } }
        public Task_Item__c taskItemForDate { get { if( taskItemForDate == null ) taskItemForDate = new Task_Item__c( Actual_End_Date__c = null ); return taskItemForDate; } set; }
        private Integer taskNumber = 0;
        public String selectedTaskItemId { get; set; }

        public ServiceItemWrapperMi3( Service_Item__c serviceItem ) {
            record = serviceItem;
            //create a 0-th task wrapper with the null task record for the page view purposes
            taskItemWrappers.put( null, new TaskItemWrapperMi3( null ) );
            taskItemWrappers.get( null ).taskNumber = taskNumber++;
            taskItemWrappersList.add( taskItemWrappers.get( null ) );
            currentTaskItemWrapper = taskItemWrappers.get( null );
            selectedTaskItemId = '';

            for( Task_Item__c taskItem : serviceItem.Task_Items__r ) {
                taskItemWrappers.put( taskItem.Id, new TaskItemWrapperMi3( taskItem ) );
                taskItemWrappers.get( taskItem.Id ).taskNumber = taskNumber++;
                taskItemWrappersList.add( taskItemWrappers.get( taskItem.Id ) );
            }
            for( TaskItemWrapperMi3 taskItem : taskItemWrappersList ) {
                if( taskItem.isComplete ) {
                    currentTaskItemWrapper = taskItem;
                    selectedTaskItemId = taskItem.recordId;
                }
            }
        }

        private List<SelectOption> createtaskItemsOptions() {
            List<SelectOption> taskItemsOptions = new List<SelectOption>();
            for( TaskItemWrapperMi3 taskItem : taskItemWrappersList ) {
                taskItemsOptions.add( new SelectOption( taskItem.recordId, taskItem.recordName ) );
            }
            return taskItemsOptions;
        }
    }


    public class TaskItemWrapperMi3 {
        public Integer taskNumber;
        public String recordId { get { return record == null ? '' : record.Id; } set; }
        public String recordName { get { return record == null ? '-- None --' : record.Name; } set; }
        public String status { get { return record == null ? '' : record.Status__c; } set; }
        public Task_Item__c record { get; set; }
        public String newStatus { get { if( newStatus == null ) newStatus = ''; return newStatus; } set; }
        public List<SelectOption> completeStatuses { get { if( completeStatuses == null ) completeStatuses = new List<SelectOption>(); return completeStatuses; } set; }
        public List<String> completeStatusesList { get { if( completeStatusesList == null ) completeStatusesList = new List<String>(); return completeStatusesList; } set; }
        public Set<String> completeStatusesSet { get { if( completeStatusesSet == null ) completeStatusesSet = new Set<String>(); return completeStatusesSet; } set; }
        public Boolean isComplete { get; set; }

        public TaskItemWrapperMi3( Task_Item__c taskItem ) {
            record = taskItem;
            isComplete = false;
            if( record == null ) {
                completeStatuses.add( new SelectOption ( '', '-- None --' ) );
            } else {
                //newStatus = record.Status__c;
                //completeStatuses.add( new SelectOption ( record.Status__c, record.Status__c ) );
                List<Tasks_Statuses__c> prevalentCompletionTasks = new List<Tasks_Statuses__c>();
                List<Tasks_Statuses__c> otherCompletionTasks = new List<Tasks_Statuses__c>();
                List<Tasks_Statuses__c> allCompletionTasks = new List<Tasks_Statuses__c>();
                for( Tasks_Statuses__c taskStatus : Tasks_Statuses__c.getAll().values() ) {
                    if( record.RecordType.Name == taskStatus.Task_Name__c ) {
                        if( taskStatus.IsComplete__c ) {
                            if( taskStatus.IsPrevalent__c ) {
                                prevalentCompletionTasks.add( taskStatus );
                            } else {
                                otherCompletionTasks.add( taskStatus );
                            }
                            if( record.Status__c == taskStatus.Status__c ) {
                                isComplete = true;
                                //completeStatuses.remove(0);
                            }
                        }
                    }
                }
                allCompletionTasks.addAll( prevalentCompletionTasks );
                allCompletionTasks.addAll( otherCompletionTasks );
                for( Tasks_Statuses__c taskStatus : allCompletionTasks ) {
                    completeStatuses.add( new SelectOption ( taskStatus.Status__c, taskStatus.Status__c ) );
                    completeStatusesList.add( taskStatus.Status__c );
                    completeStatusesSet.add( taskStatus.Status__c );
                }
                if( !completeStatusesList.isEmpty() ) {
                    newStatus = completeStatusesList[0];
                }
            }
        }
    }

    private static Map<Id, Proposal__c> getProposalsWithRelatedLists( List<Proposal__c> proposals ){
        return new Map<Id, Proposal__c>( [ SELECT Id, Municipal_Agency_ID__c, Partner__c, Account_Executive__c,
                                                  ( Select Title, ParentId, OwnerId, IsPrivate, id, Body From Notes ),
                                                  ( Select Id, Project_Profile__c, Proposal__c, Role__c From Project_Rosters__r ),
                                                  ( Select Id, Project_Profile__c, Proposal__c From Phases__r ),
                                                  ( SELECT Service_Template__r.Service_Row_Number__c, Is_Alternative__c FROM Service_Items__r ),
                                                  ( SELECT Proposal__c, Project__c FROM Floors__r ),
                                                  ( SELECT Proposal__c, Project_Profile__c FROM Purchase_Orders__r ),
                                                  ( SELECT Proposal__c, Project_Profile__c FROM Deposit_Invoices__r )
                                           FROM Proposal__c
                                           WHERE Id IN : proposals ] );
    }

}