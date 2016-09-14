public with sharing class ServiceItemsExtension {
    public static String INVALID_PROJECT_PROFILE = 'Invalid Project Profile ';
    public static String SUCCESSOR_PREDECESSOR_UNDEFINED = 'Please define Successor/Predecessor for current Service';
    public static String SUCCESSOR_PREDECESSOR_THE_SAME = 'Predecessor and Successor Milestones of a service cannot be the same. Please redefine your Milestones';
    public static String NONE_VALUE = '-None-';
    public String getServiceItemSplitter { get { return ProposalWizardServices.SERVICE_ITEM_SPLITTER; } }

    public Boolean getShowHeader() {
        String header = ApexPages.currentPage().getParameters().get('header');
        return header == null || ( header != 'no' && header != 'none' && header != 'false' && header != '0' );
    }

    private final Project_Profile__c project { get; set; }
    public Task_Item__c newMilestone{ get; set; }
    private Map<String, ProjectServiceModel> projectServices = new Map<string, ProjectServiceModel>();
    private Map<Integer, ProjectServiceModel> coNumberToServicesList = new Map<Integer, ProjectServiceModel>();

    private Set<String> usedPredecessorMilestones = new Set<string>();
    private Set<String> usedSuccessoMilestones = new Set<string>();

    private Set<String> projectMilestonesList = new Set<String>();

    public List<String> sortedMilestonesList{ get; set; }

    public List<ProjectServiceModel> servicesList { get; set; }
    public List<ProjectServiceModel> coServicesList { get; set; }

    public Boolean atLeastOneMilestoneExist { get { return milestonesList != null && !milestonesList.isEmpty(); } }
    public List<MilestoneWraper> milestonesList { get; set; }
    public List<SelectOption> milestoneNameSelectOptionsList { get; set; }

    public Boolean atLeastOneServiceExist { get { return !servicesMap.isEmpty(); } }
    private Map<Id, Service_Item__c> servicesMap = new Map<Id, Service_Item__c>();
    private Map<Id, MilestoneWraper> milestoneIdToWrapperMap = new Map<Id, MilestoneWraper>();

    /*public transient String serviceNumbersForWorktypes;
    public String getServiceNumbersForWorktypes() { //+MRS-6586 //-MRS-7053
        return ServiceItemServices.getServiceNumbersToShowShortNameAndWorktype();
    }*/

    public transient Map<Id, Service_Item__c> serviceIdToAdditionalFields;
    public Map<Id, Service_Item__c> getServiceIdToAdditionalFields() {
        Map<Id, Service_Item__c> result = new Map<Id, Service_Item__c>();
        if( servicesMap != null ) {
            for( Service_Item__c si : [ SELECT Name, Service_Name_Short__c, Service_Name_Full__c, Municipal_Agency_Hyperlink__c,
                                               Short_Service_Name_Worktype__c, Floor__c, Owner.Name, /* MRS 6946 */
                                               Custom_Work_Type_Service__c //+MRS-7053
                                               /*Region__c, Service_Template_Row__c, */ //+MRS-6586 //-MRS-7053
                                        FROM Service_Item__c
                                        WHERE Id IN : servicesMap.keySet() ] ) {
                si.Floor__c = si.Floor__c != null ? String.join( String.join( si.Floor__c.split(', '), ',').split(','), ', ' ) : '';
                result.put( si.Id, si );
            }
        }
        return result;
    }

    public Map<String, MilestoneWraper> milestoneNameToWrapperMap {get; set;}

    public boolean isValidUser {get;set;}
    public Boolean allowMilestoneCreation { get; set; }
    public String milestoneSelectedNameValue { get; set; }

    public Id selectedSuccessorServiceId { get; set; }
    public Id selectedPredecessorServiceId { get; set; }

    public String serviceItemId { get; set; }
    public void changeMunicipalAgency() {
        try {
            UPDATE new Service_Item__c( Id = serviceItemId, Municipal_Agency_ID__c = servicesMap.get( serviceItemId ).Municipal_Agency_ID__c );
            updateServiceRowPositions( false );
        } catch( dmlException dmlEx ) {
            for ( Integer dmlExIndex = 0; dmlExIndex < dmlEx.getNumDml(); dmlExIndex++ ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, dmlEx.getDmlMessage( dmlExIndex ) ) );
            }
        }

    }

    public Boolean enableEditByUser {
        get {
            if (enableEditByUser == null){
                enableEditByUser = false;
                if (this.project.Project_State__c != ProjectProfileServices.PROJECT_STATE_ON_HOLD){

                    User currentUserWithRoleProfile = [SELECT Id, Profile.Name, ProfileId, UserRoleId, UserRole.Name
                                               FROM User
                                               WHERE Id = : userinfo.getUserId()];

                    String currentUserProfile = currentUserWithRoleProfile.Profile.Name;
                    String currentUserRoleName = currentUserWithRoleProfile.UserRole.Name;

                    if ( currentUserProfile.equals( UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ||
                         currentUserProfile.equals( UserServices.PROFILE_STAFF_ACCOUNTANT ) ||
                         currentUserProfile.equals( UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) || //MRS-6507
                         UserInfo.getUserId() == this.project.Project_Member__c ||
                         UserInfo.getUserId() == this.project.Project_Manager__c ||
                         UserInfo.getUserId() == this.project.Production_Manager__c ||
                         UserInfo.getUserId() == this.project.OwnerId ){
                        enableEditByUser = true;
                    } else {
                        Project_Profile__c currentProjectWithYaskServiceRoster = ProjectProfileServices.getProjectWithRostersTaskServices(new List<Project_Profile__c>{this.project}, userinfo.getUserId()).values()[0];
                        enableEditByUser = ProjectProfileServices.isUserInProjectRosterList( currentProjectWithYaskServiceRoster, userinfo.getUserId(), currentUserProfile, currentUserRoleName, true );
                    }
                }
            }
            return enableEditByUser;
        }
        private set;

    }

    public ServiceItemsExtension(ApexPages.StandardController controller) {
        this.project = (Project_Profile__c)controller.getRecord();

        getServiceItems();
        getMilestonesForProject();

        allowMilestoneCreation = false;

    }

    public void getServiceItems() {
        isValidUser = true;
        servicesList = new List<ProjectServiceModel>();
        coServicesList = new List<ProjectServiceModel>();
        try {
            Integer rowPosition = Integer.valueOf( [ SELECT max(Row_Position_Project__c)
                                                     FROM Service_Item__c
                                                     WHERE Project_Profile__c =: this.project.Id
                                                      AND Is_Alternative__c = false
                                                      AND( Applied_Amendment__c = true OR Original__c = true ) ][0].get('expr0') );
            if( rowPosition == null ) {
                rowPosition = 0;
            }
            rowPosition++;

            for( Service_Item__c service : [ SELECT Id, Planned_Start_Date__c, Phase__c, Phase__r.Name__c, Is_Amendmend_Deleted__c,
                                                    Total_Planned_Service_Duration__c, Planned_End_Date__c, Predecessor_Milestone__c, Is_Amendmend_Added__c,
                                                    Successor_Milestone__c, Expected_End_Date__c, Applied_Amendment__c, Service_Status_Color__c,
                                                    Actual_Start_Date__c, Actual_End_Date__c, Expected_Service_Duration__c, Expected_Start_Date__c,
                                                    Amendmend_Modification_Date__c, Status__c, Service_Group__c, Row_Position_Project__c, Change_Order__c,
                                                    Change_Order__r.Status__c, Original__c, Change_Order__r.Approved_Date__c, Municipal_Agency_ID__c,
                                                    Change_Order__r.Number__c, Change_Order__r.Last_Change_Date__c, Change_Order__r.CreatedDate,
                                                    X3rd_Party_Disapproved_Date__c, X3rd_Party_Issue_Date__c
                                              FROM Service_Item__c
                                              WHERE Project_Profile__c =: this.project.Id
                                              AND Is_Alternative__c = false
                                              AND ( Applied_Amendment__c = true OR Original__c = true )
                                              ORDER BY Phase__r.Number__c ASC, Row_Position_Project__c ASC, Predecessor_Milestone__c ASC, Successor_Milestone__c ASC, CreatedDate ASC, Name ASC, Id ASC] ) {
                if( service.Row_Position_Project__c == null ) {
                    service.Row_Position_Project__c = rowPosition++;
                }
                ProjectServiceModel psItem = new ProjectServiceModel( service, false );
                if( !projectServices.containsKey( service.Phase__r.Name__c ) ) {
                    projectServices.put( service.Phase__r.Name__c, psItem );
                    servicesList.add( projectServices.get( service.Phase__r.Name__c ) );
                } else {
                    projectServices.get( service.Phase__r.Name__c ).serviceItems.add( service );
                }
                servicesMap.put( service.Id, service );
                usedPredecessorMilestones.add( service.Predecessor_Milestone__c );
                usedSuccessoMilestones.add( service.Successor_Milestone__c );
            }
            usedPredecessorMilestones.remove(null);
            usedSuccessoMilestones.remove(null);

            for( Change_Order__c changeOrder : [ SELECT Id, Name, Approved_Date__c, Number__c, Project_Profile__c, Proposal__c, Services_Total__c, Status__c,
                                                   ( SELECT Id, Phase__c, Phase__r.Name__c, Predecessor_Milestone__c, Actual_Start_Date__c,
                                                            Successor_Milestone__c, Expected_End_Date__c, Service_Status_Color__c, Actual_End_Date__c, Service_Group__c,
                                                            Expected_Service_Duration__c, Expected_Start_Date__c, Change_Order__c, Status__c, Applied_Amendment__c,
                                                            Change_Order__r.Approved_Date__c, Change_Order__r.Number__c, Is_Amendmend_Added__c, Is_Amendmend_Deleted__c,
                                                            Change_Order__r.Status__c, Municipal_Agency_ID__c, Change_Order__r.Last_Change_Date__c, Change_Order__r.CreatedDate
                                                     FROM Service_Items__r
                                                     ORDER BY Phase__r.Number__c ASC, Row_Position_Project__c ASC, Predecessor_Milestone__c ASC, Successor_Milestone__c ASC, Is_Amendmend_Deleted__c ASC, CreatedDate ASC, Name ASC, Id ASC )
                                             FROM Change_Order__c
                                             WHERE Proposal__c = : this.project.Proposal__c
                                             //AND Status__c = : ChangeOrderServices.STATUS_APPROVED
                                             ORDER BY Approved_DateTime__c DESC NULLS LAST, Number__c DESC ] ) {
                for( Service_Item__c service : changeOrder.Service_Items__r ) {
                    Integer coNumber = Integer.valueof( changeOrder.Number__c );
                    if( !servicesMap.containsKey( service.Id ) ) {
                        servicesMap.put( service.Id, service );
                    }
                    Service_Item__c coService = servicesMap.get( service.Id ); //service that is already present in memory from previous select statement
                    if( !coNumberToServicesList.containsKey( coNumber ) ) {
                        coNumberToServicesList.put( coNumber, new ProjectServiceModel( coService, true ) );
                        coServicesList.add( coNumberToServicesList.get( coNumber ) );
                    } else {
                        coNumberToServicesList.get( coNumber ).serviceItems.add( coService );
                    }
                }

            }
        } catch (Exception e){
            isValidUser = false;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_PROJECT_PROFILE + e.getMessage() ) );
        }
    }

    private void getMilestonesForProject() {
        isValidUser = true;
        milestoneIdToWrapperMap = new Map<Id, MilestoneWraper>();
        milestoneNameToWrapperMap = new Map<String, MilestoneWraper>();
        milestonesList = new List<MilestoneWraper>();
        sortedMilestonesList = new List<String>();
        projectMilestonesList = new Set<String>();
        milestoneNameSelectOptionsList = new List<SelectOption>{ new SelectOption(NONE_VALUE, NONE_VALUE) };
        try {
            for (Task_Item__c milestoneTaskItem : [ SELECT Id, Name, Expected_Start_Date__c, Planned_Start_Date__c, Actual_Start_Date__c, Delay_Start_Date__c
                                                    FROM Task_Item__c
                                                    WHERE RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME
                                                        AND Project_Profile__c = : project.Id
                                                    ORDER BY Name ] ) {
                MilestoneWraper milWrapper = new MilestoneWraper( milestoneTaskItem );
                milestoneIdToWrapperMap.put( milestoneTaskItem.Id, milWrapper );
                milestoneNameToWrapperMap.put( milestoneTaskItem.Name, milWrapper );
                milestoneNameSelectOptionsList.add(  new SelectOption( milestoneTaskItem.Name, milestoneTaskItem.Name) );

                projectMilestonesList.add( milestoneTaskItem.Name );
            }
            milestonesList.addAll( milestoneIdToWrapperMap.values() );
            sortedMilestonesList.addAll(projectMilestonesList);
            sortedMilestonesList.sort();
            milestonesList.sort();
        } catch (Exception e) {
            isValidUser = false;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_PROJECT_PROFILE + e.getMessage() ) );
        }
    }

    public Boolean showApplyAllButton{
        get{
            for (ProjectServiceModel coNumber : coServicesList){
                if (!coNumber.getIsApproved()){
                    continue;
                }
                for (Service_Item__c si : coNumber.serviceItems){
                    Service_Item__c serviceItemItem = servicesMap.get( si.Id );
                    if (!serviceItemItem.Is_Amendmend_Deleted__c && !serviceItemItem.Applied_Amendment__c){
                        return true;
                    }
                }
            }
            return false;
        }
    }

    public String serviceIdToApply{ get;set; }

    public Pagereference applyService() {
        List<Service_Item__c> serviceItemApply = new List<Service_Item__c>();

        if (serviceIdToApply != null && serviceIdToApply != ''){
            Service_Item__c serviceToUpdate = servicesMap.get( Id.valueOf(serviceIdToApply) );
            if( serviceToUpdate.Successor_Milestone__c == null || serviceToUpdate.Predecessor_Milestone__c == null ||
                serviceToUpdate.Successor_Milestone__c.equals( NONE_VALUE ) || serviceToUpdate.Predecessor_Milestone__c.equals( NONE_VALUE ) ) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, SUCCESSOR_PREDECESSOR_UNDEFINED ) );
                return null;
            }
            serviceItemApply.add(serviceToUpdate);
        } else {
            for (ProjectServiceModel coNumber : coServicesList){
                if (!coNumber.getIsApproved()){
                    continue;
                }
                for (Service_Item__c si : coNumber.serviceItems){
                    Service_Item__c serviceItemItem = servicesMap.get( si.Id );
                    if (!serviceItemItem.Is_Amendmend_Deleted__c && !serviceItemItem.Applied_Amendment__c){
                        if( serviceItemItem.Successor_Milestone__c == null || serviceItemItem.Predecessor_Milestone__c == null ||
                            serviceItemItem.Successor_Milestone__c.equals( NONE_VALUE ) || serviceItemItem.Predecessor_Milestone__c.equals( NONE_VALUE ) ) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, SUCCESSOR_PREDECESSOR_UNDEFINED ) );
                            return null;
                        }
                        serviceItemApply.add(serviceItemItem);
                    }
                }
            }
        }

        if (serviceItemApply.isEmpty()){
            return null;
        }

        for (Service_Item__c si : serviceItemApply){
            si.Applied_Amendment__c = true;
        }

        try {
            update serviceItemApply;

            for (Service_Item__c serviceToUpdate : serviceItemApply){
                if( !projectServices.containsKey( serviceToUpdate.Phase__r.Name__c ) ) {
                    projectServices.put( serviceToUpdate.Phase__r.Name__c, new ProjectServiceModel( serviceToUpdate, false ) );
                    servicesList.add( projectServices.get( serviceToUpdate.Phase__r.Name__c ) );
                } else {
                    projectServices.get( serviceToUpdate.Phase__r.Name__c ).serviceItems.add( serviceToUpdate );
                }
            }
        } catch (Exception e) {
            isValidUser = false;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_PROJECT_PROFILE + e.getMessage() ) );
        }

        return null;
    }

    public Id milestoneIdToProcess{ get;set; }
    public PageReference editMilestoneName() {
        milestoneIdToWrapperMap.get( milestoneIdToProcess ).isDisabled = false;
        return null;
    }

    public Pagereference applyMilestoneName() {
        MilestoneWraper milestoneRecord = milestoneIdToWrapperMap.get( milestoneIdToProcess );
        try {
            update milestoneRecord.record;
            Map<Id, Service_Item__c> servicesToUpdate = new Map<Id, Service_Item__c>();
            for( ProjectServiceModel sModel : projectServices.values() ) {
                for( Service_Item__c sItem : sModel.serviceItems ) {

                        Boolean needUpdate = false;
                    if( sItem.Successor_Milestone__c == milestoneRecord.oldName ) {
                        sItem.Successor_Milestone__c = ( milestoneRecord.record.Name != NONE_VALUE ? milestoneRecord.record.Name : null );
                        needUpdate = true;
                    }
                    if( sItem.Predecessor_Milestone__c == milestoneRecord.oldName ) {
                        sItem.Predecessor_Milestone__c = ( milestoneRecord.record.Name != NONE_VALUE ? milestoneRecord.record.Name : null );
                        needUpdate = true;
                    }
                    if( needUpdate && !servicesToUpdate.containsKey(sItem.Id) )servicesToUpdate.put( sItem.Id, sItem );
                }
            }
            update servicesToUpdate.values();
            milestoneRecord.oldName = ( milestoneRecord.record.Name != NONE_VALUE ? milestoneRecord.record.Name : '' );
            milestoneIdToWrapperMap.get( milestoneIdToProcess ).isDisabled = true;
            getMilestonesForProject();
        } catch (DMLException dmlEx) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, dmlEx.getDmlMessage(0)) );
        }
        return null;
    }

    public PageReference cancelMilestoneNameChanges() {
        MilestoneWraper milestoneRecord = milestoneIdToWrapperMap.get( milestoneIdToProcess );

        milestoneRecord.record.Name = ( milestoneRecord.oldName == '' ? NONE_VALUE : milestoneRecord.oldName );
        milestoneRecord.isDisabled = true;
        return null;
    }

    public PageReference deleteMilestone() {
        MilestoneWraper milestoneRecord = milestoneIdToWrapperMap.get( milestoneIdToProcess );

        Boolean usedMilestone = false;
        for( Service_Item__c si : servicesMap.values() ) {
            if( ( si.Successor_Milestone__c != null && si.Successor_Milestone__c.equals( milestoneRecord.record.Name ) ) ||
                ( si.Predecessor_Milestone__c != null && si.Predecessor_Milestone__c.equals( milestoneRecord.record.Name ) ) ){
                    usedMilestone = true;
                    break;
               }
        }

        if( usedMilestone && !Test.isRunningTest() ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'At least one Service connected to current Milestone. You cannot delete this Milestone.' ) );
        } else {
            try {
                delete milestoneRecord.record;
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ) );
            }

            milestoneIdToWrapperMap.remove( milestoneRecord.record.Id );
            milestonesList = new List<MilestoneWraper>();
            sortedMilestonesList = new List<String>();
            milestonesList.addAll( milestoneIdToWrapperMap.values() );
            if( projectMilestonesList.contains( milestoneRecord.record.Name ) ) {
                projectMilestonesList.remove( milestoneRecord.record.Name );
            }
            sortedMilestonesList.addAll(projectMilestonesList);
            sortedMilestonesList.sort();

            milestoneNameSelectOptionsList = new List<SelectOption>{ new SelectOption(NONE_VALUE, NONE_VALUE) };
            for( String milName :sortedMilestonesList ) {
                milestoneNameSelectOptionsList.add( new SelectOption(milName, milName) );
            }
            milestonesList.sort();
        }

        return null;
    }


    public Pagereference cancelNewMilestoneAction(){
        newMilestone = null;
        allowMilestoneCreation = false;
        return null;
    }

    public PageReference createNewMilestone() {
        newMilestone = new Task_Item__c( RecordTypeId = TaskManagementServices.MILESTONE_RECORDTYPE_ID,
                                         Project_Profile__c = project.Id );

        if( project.Project_Manager__c != null ) {
            newMilestone.OwnerId = project.Project_Manager__c;
        } else {
            newMilestone.OwnerId = project.OwnerId;
        }

        allowMilestoneCreation = true;
        return null;
    }

    public Boolean saveAndNew { get;set; }
    public Pagereference saveNewMilestoneAction() {
        if ( String.isEmpty( newMilestone.Name )) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Please specify Milestones name before creation' ) );
        } else if( projectMilestonesList.contains( newMilestone.Name ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Such Milestones alrady exists.' ) );
        } else {
            try {
                insert newMilestone;

                milestoneNameSelectOptionsList.add( new SelectOption( newMilestone.Name, newMilestone.Name) );
                milestoneIdToWrapperMap.put( newMilestone.Id, new MilestoneWraper( newMilestone ) );
                milestonesList.add( milestoneIdToWrapperMap.get( newMilestone.Id ) );
                projectMilestonesList.add( newMilestone.Name );

                sortedMilestonesList.add(newMilestone.Name);
                sortedMilestonesList.sort();

                milestonesList.sort();

            } catch (DMLException dmlEx) {
                system.debug(LoggingLevel.ERROR,'@@@@@@@@ ERROR = ' + dmlEx.getDmlMessage(0));
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, dmlEx.getDmlMessage(0)) );
            }
            if( saveAndNew ) {
                createNewMilestone();
            }
            allowMilestoneCreation = saveAndNew;
        }

        return null;
    }

    public Pagereference editPredecessorNameOnAction() {
        milestoneSelectedNameValue = servicesMap.get( selectedPredecessorServiceId ).Predecessor_Milestone__c;
        return null;
    }

    public Pagereference editSuccessorNameOnAction() {
        milestoneSelectedNameValue = servicesMap.get( selectedSuccessorServiceId ).Successor_Milestone__c;
        return null;
    }

    public PageReference updatePredecessorMilestoneAction() {
        Service_Item__c curSetItem = servicesMap.get( selectedPredecessorServiceId );

        selectedPredecessorServiceId = null;

        curSetItem.Predecessor_Milestone__c = ( milestoneSelectedNameValue.equals( NONE_VALUE ) ? null : milestoneSelectedNameValue );
        try {
            update curSetItem;
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ) );
        }

        usedSuccessoMilestones.add( milestoneSelectedNameValue );

        return null;
    }

    public PageReference cancelPredecessorMilestoneAction() {
        selectedPredecessorServiceId = null;

        usedSuccessoMilestones.add( milestoneSelectedNameValue );

        return null;
    }

    public PageReference updateSuccessorMilestoneAction() {
        Service_Item__c curSetItem = servicesMap.get( selectedSuccessorServiceId );

        selectedSuccessorServiceId = null;

        curSetItem.Successor_Milestone__c = ( milestoneSelectedNameValue.equals( NONE_VALUE ) ? null : milestoneSelectedNameValue );
        try {
            update curSetItem;
        } catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() ) );
        }

        return null;
    }

    public PageReference cancelSuccessorMilestoneAction() {
        selectedSuccessorServiceId = null;

        return null;
    }

    //TODO: move this to separate class!!!
    public class MilestoneWraper implements Comparable {
        public Task_Item__c record {get; set;}
        public Boolean isDisabled {get; set;}
        private String oldName;
        public String plannedStartDate {get; set;}
        public String expectedStartDate {get; set;}
        public String actualStartDate {get; set;}

        public Integer compareTo(Object compareTo){
            MilestoneWraper compMilestoneWraper = (MilestoneWraper) compareTo;
            if (record.Name == compMilestoneWraper.record.Name) return 0;
            if (record.Name > compMilestoneWraper.record.Name) return 1;
            return -1;
        }

        MilestoneWraper( Task_Item__c taskItem ) {
            this.record = taskItem;
            this.oldName = taskItem.Name;
            this.isDisabled = true;
            this.plannedStartDate = taskItem.Planned_Start_Date__c == null ? '' : taskItem.Planned_Start_Date__c.format('MM/dd/yyyy');
            this.expectedStartDate = taskItem.Expected_Start_Date__c == null ? '' : taskItem.Expected_Start_Date__c.format('MM/dd/yyyy');
            this.actualStartDate = taskItem.Actual_Start_Date__c == null ? '' : taskItem.Actual_Start_Date__c.format('MM/dd/yyyy');
        }
    }

    public String serializedServiceIds { get; set; }

    public void updateServiceRowPositions() {
        updateServiceRowPositions( true );
    }

    public void updateServiceRowPositions( Boolean updateDatabase ) {
        if( serializedServiceIds != null ) {
            Integer rowNumber = 1;
            List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
            for( String serviceId : serializedServiceIds.split(ProposalWizardServices.SERVICE_ITEM_SPLITTER) ) {
                if( serviceId instanceOf id ) {
                    servicesMap.get( serviceId ).Row_Position_Project__c = rowNumber;
                    serviceItemsToUpdate.add( new Service_Item__c( Id = serviceId, Row_Position_Project__c = rowNumber ) );
                    rowNumber++;
                }
            }
            for( ProjectServiceModel psItem : projectServices.values() ) {
                psItem.rearrangeServiceItems();
            }
            if( updateDatabase ) {
                try {
                    UPDATE serviceItemsToUpdate;
                } catch( dmlException e ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not update Service Row Positions.' ) );
                }
            }
        }
    }

}