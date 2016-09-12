public with sharing class CalculatePlannedDatesController {
    public static String INVALID_PROJECT_PROFILE                     = 'Invalid Project Profile: ';
    public static String NO_SERVICES_FOR_PROJECT_PROFILE             = 'No Services for Project Profile';
    public static String PLANNED_DATES_SUBMITTED_FOR_PROJECT_PROFILE = 'The plan has already been committed.';
    public static String PROJECT_START_DATE_IS_NOT_SPECIFIED         = 'Project Start Date has not been specified. Please do it before Project Expected Dates calculation.';
    public static String SERVICES_WITHOUT_TASKS                      = 'Project has at least one empty Service (without defined Tasks). You cannot commit Project Plan with empty Services.';
    public static String INVALID_PROJECT_MANAGER                     = 'You have no permissions. Only User from Assignment section can calculate/submit Project plan.';
    public static String DATES_ARE_NOT_CALCULATED                    = 'Planned Dates can not be committed if Expected and Planned Dates are not calculated.';
    public static String SUCCESSOR_PREDECESSOR_THE_SAME              = 'Predecessor and Successor Milestones of a service cannot be the same. Please redefine your Milestones';
    public static String SERVICES_WITHOUT_CALSULATED_DATES           = 'Please calculate Planned dates before Commiting of Project';
    public static String DATE_CALCULATION_TOO_LONG                   = 'Calculation process is going very long. Please make sure your Milestones are set up correctly.';
    public static String PROJECT_STATE_ON_HOLD_ERROR                 = 'You cannot commit Planned Date if Project State is "On Hold".';
    public static String PROJECT_BILLING_DATE_SHOULD_BE_POPULATED    = 'This project is set up to bill installments over a period of time. You cannot start the project ' +
                                                                       'until a Billing End Date is specified so that the system can calculate the periodic billing.';


    private final String projectId = ApexPages.currentPage().getParameters().get('Id');
    private final String isSubmit  = ApexPages.currentPage().getParameters().get('isSubmit');
    private final String serviceId = ApexPages.currentPage().getParameters().get('serviceId');
    private final String taskId    = ApexPages.currentPage().getParameters().get('taskId');

    private final String serviceOrTaskOwnerId = ApexPages.currentPage().getParameters().get('serviceOrTaskOwnerId');
    private final Boolean isProjectLevel = ( ApexPages.currentPage().getParameters().get('isProjectLevel') != null ) ? Boolean.valueOf( ApexPages.currentPage().getParameters().get('isProjectLevel') ) : false;

    public Project_Profile__c project;
    public Map<Id, Service_Item__c> servicesWithTasks;

    public boolean isValidUser { get ;set; }

    public CalculatePlannedDatesController(){
        this.isValidUser = true;

        try{
            Id currentUserId = UserInfo.getuserid();
            User currentUserWithRoleProfile = [SELECT Id, Profile.Name, ProfileId, UserRoleId, UserRole.Name
                                               FROM User
                                               WHERE Id = : currentUserId];
            String currentUserProfile = currentUserWithRoleProfile.Profile.Name;
            String currentUserRoleName = currentUserWithRoleProfile.UserRole.Name;

            this.project = ProjectProfileServices.getProjectWithRostersTaskServices(new List<Project_Profile__c>{new Project_Profile__c(Id = this.projectId)}, currentUserId).values()[0]; //MRS-6731

            if ( currentUserProfile.contains( UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ||
                 currentUserProfile.contains( UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) || //MRS-6507
                 currentUserProfile.contains( UserServices.PROFILE_STAFF_ACCOUNTANT ) ||
                 UserServices.isValidUserForProject( currentUserId, this.project, serviceOrTaskOwnerId != null ? Id.valueOf( this.serviceOrTaskOwnerId ) : null, null, this.isProjectLevel, false ) ||
                 UserServices.isValidUserForProjectCheckServiceORTaskOwners( currentUserId, this.project ) ||
                 ( String.isEmpty( serviceId ) && String.isEmpty( taskId ) && ProjectProfileServices.isUserInProjectRosterList( this.project, currentUserId, currentUserProfile, currentUserRoleName, true ) ) ) { //MRS-6731

                this.servicesWithTasks = ServiceItemServices.getServiceItemsWithTaskItemsByProjectId(this.projectId,
                                                                                                     new Set<String>{ServiceItemServices.SERVICE_STATUS_NOTSTARTED,
                                                                                                                     ServiceItemServices.SERVICE_STATUS_ACTIVE,
                                                                                                                     ServiceItemServices.SERVICE_STATUS_COMPLETED});

            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, INVALID_PROJECT_MANAGER));
                this.isValidUser = false;

            }

        } catch (Exception ex) {
            this.isValidUser = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_PROJECT_PROFILE + ex.getMessage()));

        }

    }

    public PageReference calculateDates() {
        Savepoint sp = Database.setSavepoint();
        PageReference pr = null;
        if ( isValidUser ){
            try {
                if( project.Project_State__c == ProjectProfileServices.PROJECT_STATE_ON_HOLD && isSubmit != null ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, PROJECT_STATE_ON_HOLD_ERROR ));
                    return null;
                }
                if( project.Project_Start_Date__c == null ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, PROJECT_START_DATE_IS_NOT_SPECIFIED ));
                    return null;
                }
                if( project.Project_Expected_End_Date__c == null && isSubmit != null ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, DATES_ARE_NOT_CALCULATED ));
                    return null;
                }
                if( servicesWithTasks.isEmpty() ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, NO_SERVICES_FOR_PROJECT_PROFILE ));
                    return null;
                }
                if( isSubmit == null ) {
                    for( Id serviceItemId: servicesWithTasks.keySet() ) {
                        if( servicesWithTasks.get( serviceItemId ).Successor_Milestone__c == servicesWithTasks.get( serviceItemId ).Predecessor_Milestone__c ) {
                            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, SUCCESSOR_PREDECESSOR_THE_SAME ) );
                            return null;
                        }
                    }

                    if (servicesWithTasks.size() > TaskItemServices.SERVICE_ITEM_COUNT){
                        futureCalculation(projectId, taskId);
                    } else {
                        processCalculation( projectId, taskId, servicesWithTasks );
                    }
                } else {
                    //MRS-6786
                    if ( ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ||
                          ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c ) ) ){

                          if( project.Billing_End_Date__c == null ){
	                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, PROJECT_BILLING_DATE_SHOULD_BE_POPULATED ));
	                        return null;
                          }
                          Boolean isPercentageInterval = false;
                          for( Billing_Date__c item: [Select Id, Name, Percentage__c From Billing_Date__c Where Project_Profile__c =: project.Id AND Percentage__c > 0 limit 1 ]){
                          	isPercentageInterval = true;
                          }
                          if( !isPercentageInterval ){
                          	ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot start the project before billing percentages are set up' ));
	                        return null;
                          }
                    }

                    List<Service_Item__c> unsubmittedCOServices = new List<Service_Item__c>();
                    for( Service_Item__c servItem : servicesWithTasks.values() ) {
                        if( servItem.Task_Items__r.isEmpty() ) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, SERVICES_WITHOUT_TASKS ));
                            return null;
                        }
                        if( servItem.Expected_Start_Date__c == null || servItem.Expected_End_Date__c == null ) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, SERVICES_WITHOUT_CALSULATED_DATES ));
                            return null;
                        }
                        if( servItem.Applied_Amendment__c && !servItem.Submitted_CO_Planned_Dates__c ) {
                            unsubmittedCOServices.add( servItem );
                        }
                     }


                    if( !servicesWithTasks.values()[0].Project_Profile__r.Submitted_Planned_Dates__c ) {
                        project.Submitted_Planned_Dates__c = true;
                        project.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
                        project.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();
                        update project;
                    } else {
                        if( unsubmittedCOServices.isEmpty() ){
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, PLANNED_DATES_SUBMITTED_FOR_PROJECT_PROFILE ));
                            return null;
                        } else {
                            for( Service_Item__c servItem : unsubmittedCOServices ) {
                                servItem.Planned_Start_Date__c = servItem.Expected_Start_Date__c;
                                servItem.Planned_End_Date__c = servItem.Expected_End_Date__c;
                                servItem.Total_Planned_Service_Duration__c = servItem.Expected_Service_Duration__c;
                                servItem.Submitted_CO_Planned_Dates__c = true;
                            }

                            update unsubmittedCOServices;
                        }
                    }
                }
            } catch ( Exception e ) {
                if( e.getMessage() != null && e.getMessage().contains( ErrorException.APEX_CPU_TIME_LIMIT_EXCEEDED ) ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, DATE_CALCULATION_TOO_LONG ) );
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                }

                DataBase.rollback(sp);
                return null;
            }
            if( serviceId != null ) {
                pr = new PageReference( '/' + serviceId );
            } else if( taskId != null ) {
                pr = new PageReference( '/' + taskId );
            } else {
                pr = new PageReference( '/' + projectId);
            }
            pr.setRedirect(true);
        }
        return pr;
    }


    @future
    public static void futureCalculation(Id projectId, Id taskItemId){
        Map<Id, Service_Item__c> servicesWithTasksMap = ServiceItemServices.getServiceItemsWithTaskItemsByProjectId( projectId,
                                                                                                                     new Set<String>{ServiceItemServices.SERVICE_STATUS_NOTSTARTED,
                                                                                                                                     ServiceItemServices.SERVICE_STATUS_ACTIVE,
                                                                                                                                     ServiceItemServices.SERVICE_STATUS_COMPLETED});

        Savepoint sp = Database.setSavepoint();

        TaskItemServices.runInFutureMethod = true;

        try {
            processCalculation(projectId, taskItemId, servicesWithTasksMap);
        } catch (Exception ex){
            DataBase.rollback(sp);
        }
    }

    public static void processCalculation( Id projectId, Id taskItemId, Map<Id, Service_Item__c> servicesWithTasksMap ){
        try {
            for( Id serviceItemId: servicesWithTasksMap.keySet() ) {
                TaskManagementServices.seqNumberToTaskItemForService.put( serviceItemId, new Map<Integer, Task_Item__c>() );
                for( Task_Item__c tItem : servicesWithTasksMap.get( serviceItemId ).Task_Items__r ) {
                    TaskManagementServices.seqNumberToTaskItemForService.get( serviceItemId ).put( Integer.valueOf(tItem.Sequence_Number__c), tItem );
                }
            }
            // Prepare maps of all Tasks with Prededecessors and Successors
            Id serviceIdDoNotUpdate = TaskManagementServices.collectTaskPredecessorsAndSuccessors( servicesWithTasksMap, taskItemId, true, true );
            // Calculate Planned Start/End Dates for all Services
            // serviceIdDoNotUpdate - not NULL only if you calcuate Dates from Task Item level
            TaskManagementServices.calculatePlannedExpectedDatesForServices( servicesWithTasksMap, serviceIdDoNotUpdate, null );
            //update servicesWithTasksMap.values();
            // Calculate Planned Start/End Dates for all Tasks
            TaskManagementServices.calculatePlannedDatesForTasks( servicesWithTasksMap, null, taskItemId, true );
            update servicesWithTasksMap.values();
        } catch (Exception ex){
            throw new ErrorException( ex.getMessage() );
        }
    }
}