public without sharing class CloneProposalExtention {

    public final Proposal__c proposal { get; private set; }
    @testVisible private Map<Id, Id> originalToClonedPhasesMap   = new Map<Id, Id>();
    @testVisible private Map<Id, Id> originalToClonedServicesMap = new Map<Id, Id>();
    @testVisible private Map<Id, Id> originalToclonedFloorsMap   = new Map<Id, Id>();
    @testVisible private String currentUserRoleName;
    @testVisible private Map<String, Set<String>> allowedProfiles = new Map<String, Set<String>>{ UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN => null,
                                                                                                  UserServices.PROFILE_DIRECTOR_OF_OPERATIONS => null, //MRS-6507
                                                                                                  UserServices.PROFILE_PROPOSAL_SPECIALIST => null,
                                                                                                  UserServices.PROFILE_SHARED_SERVICES_MANAGER => null, //MRS-6625
                                                                                                  UserServices.PROFILE_PARTNER => null,
                                                                                                  UserServices.PROFILE_ACCOUNT_MANAGER => null,
                                                                                                  UserServices.EXECUTIVE_ADMIN_PROFILE_NAME => null,
                                                                                                  UserServices.PROFILE_OPERATIONS_MANAGER => null,
                                                                                                  UserServices.PROFILE_CODE_ZONING_ANALYST => new Set<String>{ UserServices.ROLE_LI_CZ_MANAGER } };
    @testVisible private String profileName;
    @testVisible private List<Service_Item__c> originalServices;

    public CloneProposalExtention(ApexPages.StandardController controller) {
        this.proposal = (Proposal__c)controller.getRecord();
        Profile profileRecord = [Select Name From Profile where id =: UserInfo.getProfileId() limit 1];
        this.profileName = profileRecord.Name;
        UserRole currentUserRole = UserServices.getCurrentUserRole();
        this.currentUserRoleName = currentUserRole == null ? '' : currentUserRole.Name;
    }

    public PageReference createCloneOfProposal() {
        if( !this.allowedProfiles.keySet().contains( this.profileName ) ||
            ( this.allowedProfiles.keySet().contains( this.profileName ) && this.allowedProfiles.get( this.profileName ) != null && !(this.allowedProfiles.get( this.profileName )).contains( this.currentUserRoleName ) ) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Only Users with Profiles \'Proposal Specialist\', \'Partner\', \'Account Manager\', \'Executive Admins\', \'Operations Manager\', and \'LI Code & Zoning Department Manager\' have permission to clone Proposal'));
            return null;
        }

        Savepoint sp = Database.setSavepoint();
        Proposal__c originalProposal;
        Proposal__c clonedProposal;
        try {
            String query = createQueryStringForProposal();
            originalProposal = Database.query(query);
            if( !String.isBlank( originalProposal.Mi3_MRC__c ) &&
                    this.profileName != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN &&
                    this.profileName != UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) { //MRS-6507
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'This is a Mi3 Proposal. Mi3 Proposals can not be cloned.'));
                return null;
            }

            Account billingAccount = new Account( UseDocusign__c = true, No_Retainer__c = false, Retainer__c = 30 );
            if( !String.isBlank( originalProposal.Billing_Company_Name__c ) ) {
                billingAccount = [ SELECT UseDocusign__c, No_Retainer__c, Retainer__c
                                   FROM Account
                                   WHERE Id = : originalProposal.Billing_Company_Name__c ];
            }

            query = createQueryStringForServiceItems();
            originalServices = Database.query(query);

            clonedProposal = originalProposal.clone(false, true);
            clonedProposal.Project_Profile__c = null;
            clonedProposal.Client_Project__c = null;
            clonedProposal.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            clonedProposal.Proposal_Awarded_Date__c = null;
            clonedProposal.Proposal_Expiration_Date__c = Date.today().addMonths(6);
            clonedProposal.Project_Team__c = null;
            clonedProposal.FREP__c = null;
            clonedProposal.Internal_Reviewer__c = null;
            clonedProposal.Partner_Approval_Required__c = true;
            clonedProposal.Code_Zoning_Analyst__c = null;
            clonedProposal.Provided_Documents__c = false;
            clonedProposal.Provided_Drawings__c = false;
            clonedProposal.SIPS_Coordinator__c = null;
            clonedProposal.Production_Manager__c = null; //MRS-6853
            clonedProposal.is_Change_Order__c = false;
            clonedProposal.Version__c = null;
            clonedProposal.Version_Text__c = '00.01';
            clonedProposal.OwnerId = UserInfo.getUserId();
            clonedProposal.Proposal_Specialist__c = UserInfo.getUserId();
            clonedProposal.Is_Draft__c = true;
            clonedProposal.Proposal_Sent_Date__c = null;
            clonedProposal.Proposal_Awarded_Date__c = null;
            clonedProposal.Last_Status_Change__c = null;
            clonedProposal.Proposal_Type__c = ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Proposal_Type__c');
            clonedProposal.RFP_Attachments__c = null; //MRS-5140
            clonedProposal.No_Retainer__c = billingAccount.No_Retainer__c;
            clonedProposal.Retainer_Amount__c = ( ( !clonedProposal.No_Retainer__c && billingAccount.Retainer__c != null ) ? billingAccount.Retainer__c : 0 );
            clonedProposal.Reimbursable_Percentage__c = 15;//MRS-6429
            clonedProposal.Is_Mi3_Project_Created__c = false;
            clonedProposal.Received_Signed_Proposal__c = false;
            clonedProposal.eSigned__c = '';
			clonedProposal.Proposal_Sender__c = null; // MRS 7203
            clonedProposal.UseDocusign__c = billingAccount.UseDocusign__c;
            clonedProposal.Follow_Ups_Count__c = 0; // MRS 7165
            clonedProposal.Last_Follow_Up_Date__c = null;
			clonedProposal.Percents_View_State__c = null; // MRS 7358
			clonedProposal.Add_Reimbursable_Invoice__c = null; //MRS 7466
			if(originalProposal.Id != null) clonedProposal.Has_Been_Cloned_From_Proposal__c = String.valueOf(originalProposal.Id); //MRS 7530

            INSERT clonedProposal;
        } catch( Exception ex ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        if( !clonePhases( originalProposal, clonedProposal, sp ) ){
            return null;
        }
        if( !cloneServices( originalProposal, clonedProposal, sp ) ){
            return null;
        }
        if( !cloneFloors( originalProposal, clonedProposal, sp ) ){
            return null;
        }
        if( !cloneServiceToFloorJunctions( sp ) ){
            return null;
        }
        if( !cloneProjectRosters( originalProposal, clonedProposal, sp ) ){
            return null;
        }

        PageReference pageReference = new PageReference('/apex/ProposalWizard');
        pageReference.getParameters().put('id', clonedProposal.Id);
        pageReference.setRedirect(true);
        return pageReference;
    }

    @testVisible
    private String createQueryStringForProposal(){
        String query = 'SELECT ';
        query += MilroseDevHelper.getCreatableFieldsSelectByObjectName(ProposalServices.PROPOSAL_OBJECT_API_NAME);
        //query += ', (SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(ServiceItemServices.SERVICE_ITEM_OBJECT_API_NAME) + ' FROM Service_Items__r WHERE Is_Amendmend_Deleted__c = false)';
//        query += ', (SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(ProjectRosterServices.PROJECT_ROSTER_OBJECT_API_NAME) + ' FROM Project_Rosters__r WHERE Initially_Added_Roster__c = true)';
//        query += ', (SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(PhaseServices.PHASE_OBJECT_API_NAME) + ' FROM Phases__r)';
//        query += ', (SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(FloorServices.FLOOR_OBJECT_API_NAME) + ' FROM Floors__r)';
        query += ' FROM Proposal__c WHERE Id = ' + '\'' + this.proposal.Id + '\'';

        return query;
    }

    //MRS-6248
    private static Set<String> notClonedFieldsForServiceItems {
        get{
            if ( notClonedFieldsForServiceItems == null ){
                notClonedFieldsForServiceItems = new Set<String>();
                try {
                    for (Unclonned_Service_Fields__c fieldApiItem : Unclonned_Service_Fields__c.getall().values()){
                        notClonedFieldsForServiceItems.add( fieldApiItem.Uncloned_Service_Field__c );
                    }
                } catch (Exception ex){}
            }
            return notClonedFieldsForServiceItems;
        }
        set{}
    }

    @testVisible
    private String createQueryStringForServiceItems(){
        return ' SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(ServiceItemServices.SERVICE_ITEM_OBJECT_API_NAME, notClonedFieldsForServiceItems) + ', Change_Order_Status__c' +
               //' Service_Template__r.Expected_Start_Date__c, Service_Template__r.Expected_End_Date__c, Service_Template__r.Expected_Service_Duration__c '+
               ' FROM  Service_Item__c WHERE Proposal__c = ' + '\'' + this.proposal.Id + '\'';
    }

    @testVisible
    private Boolean clonePhases( Proposal__c originalProposal, Proposal__c clonedProposal,  Savepoint sp ){
        Boolean status = true;

        String queryPhaseString = 'SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(PhaseServices.PHASE_OBJECT_API_NAME) + ' FROM Phase__c WHERE Proposal__c = \'' + String.valueOf(originalProposal.Id) + '\'';
        List<Phase__c> originalPhases = Database.query(queryPhaseString);

        if( originalPhases.IsEmpty() ){
             return status;
        }

        List<Phase__c> clonedPhases = originalPhases.deepClone();
        for( Phase__c phase: clonedPhases ){
            phase.Proposal__c = clonedProposal.Id;
            phase.Project_Profile__c = null;
            phase.OwnerId = UserInfo.getUserId();
        }
        try {
            insert clonedPhases;
            for(Integer i=0; i<originalPhases.size(); i++){
                originalToClonedPhasesMap.put(originalPhases[i].Id, clonedPhases[i].Id);
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            status = false;
        }

        return status;
    }

    @testVisible
    private Boolean cloneServices( Proposal__c originalProposal, Proposal__c clonedProposal,  Savepoint sp ){
        List<Service_Item__c> filteredServices = new List<Service_Item__c>();
        Map<Id, Service_Item__c> filteredTemplateToServicesMap = new Map<Id, Service_Item__c>();
        for( Service_Item__c service: originalServices ){
            if( !service.Is_Amendmend_Deleted__c || ( service.Is_Amendmend_Deleted__c && service.Change_Order_Status__c != ChangeOrderServices.STATUS_APPROVED ) ){
                filteredServices.add(service);
            }
            if( service.Change_Order_Status__c != ChangeOrderServices.STATUS_APPROVED && //it is here because a formula (non-creatable) field on original service is used to perform a check
                service.Quantity_Old__c != null &&
                service.Quantity_Old__c > 0 ) {
                service.Quantity__c = service.Quantity_Old__c;
            }
        }
        Boolean status = true;
        if( filteredServices.IsEmpty() ){
            return status;
        }

        List<Service_Item__c> clonedServices = filteredServices.deepClone();

        //MRS-7530
        List<Id> serviceTemplateIds = new List<Id>();
        for (Service_Item__c service : clonedServices){
            serviceTemplateIds.add(service.Service_Template__c);
        }
        Map<Id, Service_Template__c> serviceTemplateMap = new Map<Id, Service_Template__c>(ServiceItemServices.getServiceTemplateForServiceItem(serviceTemplateIds, null));

        for( Integer i=0; i<clonedServices.size(); i++ ){
            //MRS-7530
            ServiceItemServices.populateServiceItemFromServiceTemplateFields(serviceTemplateMap.get(clonedServices[i].Service_Template__c), clonedServices[i], false);

            clonedServices[i].Proposal__c = clonedProposal.Id;
            clonedServices[i].Project_Profile__c = null;
            clonedServices[i].Change_Order__c = null;
            clonedServices[i].Change_Order_Old__c = null;
            clonedServices[i].Original__c = true;
            clonedServices[i].Applied_Amendment__c = false;
            clonedServices[i].Doc_Shredding_BLI_Created__c = false;
            clonedServices[i].Met_Data_BLI_Created__c = false;
            clonedServices[i].Is_Amendmend_Added__c = false;
            clonedServices[i].Is_Amendmend_Deleted__c = false;
            clonedServices[i].Quantity_Old__c = null;

            clonedServices[i].Amount_Paid__c = null;
            clonedServices[i].Amount_Due__c = null;
            clonedServices[i].Amount_Billed__c = null;

            clonedServices[i].Amendmend_Modification_Date__c = null;
            clonedServices[i].Expiration_Date__c = null;

            clonedServices[i].Expected_Start_Date__c = null;
            clonedServices[i].Expected_End_Date__c = null;
            clonedServices[i].Expected_Service_Duration__c = null;
            clonedServices[i].Actual_Start_Date__c = null;
            clonedServices[i].Actual_End_Date__c = null;
            clonedServices[i].Planned_Start_Date__c = null;
            clonedServices[i].Planned_End_Date__c  = null;
            clonedServices[i].Total_Planned_Service_Duration__c = null;
            clonedServices[i].Actual_Duration__c = null;
            clonedServices[i].Disapproved_Date__c = null;
            clonedServices[i].Approved_Date__c = null;
            clonedServices[i].Filed_Date__c = null;
            clonedServices[i].Purchase_Order__c = null;
            clonedServices[i].Non_Billable_Reason__c = null; // 7056

            clonedServices[i].Phase__c = originalToClonedPhasesMap.containsKey(filteredServices[i].Phase__c) ? originalToClonedPhasesMap.get(filteredServices[i].Phase__c) : null;
            clonedServices[i].OwnerId = UserInfo.getUserId();
        }
        try {
            insert clonedServices;
            for(Integer i=0; i<filteredServices.size(); i++){
                originalToClonedServicesMap.put(filteredServices[i].Id, clonedServices[i].Id);
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            status = false;
        }

        return status;
    }

    @testVisible
    private Boolean cloneFloors( Proposal__c originalProposal, Proposal__c clonedProposal,  Savepoint sp ){
        Boolean status = true;

        String queryFloorString = ' SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(FloorServices.FLOOR_OBJECT_API_NAME) + 
                                  ' FROM Floor__c ' +
                                  ' WHERE Proposal__c = \'' + String.valueOf(originalProposal.Id) + '\'';

        List<Floor__c> originalFloors = Database.query(queryFloorString);

        if( originalFloors.IsEmpty() ){
             return status;
        }

        List<Floor__c> clonedFloors = originalFloors.deepClone();
        for( Floor__c floor: clonedFloors ){
            floor.Proposal__c = clonedProposal.Id;
            floor.Project__c = null;
            floor.OwnerId = UserInfo.getUserId(); 
        }
        try {
            insert clonedFloors;
            for(Integer i=0; i<originalFloors.size(); i++){
                originalToclonedFloorsMap.put(originalFloors[i].Id, clonedFloors[i].Id);
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            status = false;
        }

        return status;
    }

    @testVisible
    private Boolean cloneServiceToFloorJunctions( Savepoint sp ){
        Boolean status = true;

        List<Service_Floor_Junction__c> existingJunctions = new List<Service_Floor_Junction__c>([SELECT Id, Service_Item__c, Floor__c
                                                                                                FROM Service_Floor_Junction__c
                                                                                                WHERE Floor__c IN: originalToclonedFloorsMap.keySet()]);
        if( existingJunctions.IsEmpty() ){
             return status;
        }

        List<Service_Floor_Junction__c> clonedJunctions = new List<Service_Floor_Junction__c>();
        for( Service_Floor_Junction__c junction: existingJunctions ){
            if( originalToclonedFloorsMap.containsKey(junction.Floor__c) && originalToClonedServicesMap.containsKey(junction.Service_Item__c) ){
                Service_Floor_Junction__c newJunction = new Service_Floor_Junction__c();
                newJunction.Floor__c = originalToclonedFloorsMap.get(junction.Floor__c);
                newJunction.Service_Item__c = originalToClonedServicesMap.get(junction.Service_Item__c);
                clonedJunctions.add( newJunction );
            }
        }

        try {
            insert clonedJunctions;
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            status = false;
        }

        return status;
    }

    @testVisible
    private Boolean cloneProjectRosters( Proposal__c originalProposal, Proposal__c clonedProposal,  Savepoint sp ){
        Boolean status = true;

        String queryProjectRosterString = ' SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName(ProjectRosterServices.PROJECT_ROSTER_OBJECT_API_NAME) + 
                                          ' FROM Project_Roster__c ' +
                                          ' WHERE Proposal__c = \'' + String.valueOf(originalProposal.Id) + '\' AND Initially_Added_Roster__c = true';

        List<Project_Roster__c> originalProjectRosterList = Database.query(queryProjectRosterString);

        if( originalProjectRosterList.IsEmpty() ){
             return status;
        }

        //MRS-4493
        List<Project_Roster__c> filteredRosters = new List<Project_Roster__c>();
        Set<Id> excludeUsersFromRosterId = new Set<Id>();
        if( originalProposal.Project_Team__c != null ){
            Map<Id, Project_Team__c>  projectTeamMap = ProjectTeamServices.getAllProjectTeams();
            excludeUsersFromRosterId.add( projectTeamMap.get(originalProposal.Project_Team__c).Project_Manager__c );
            excludeUsersFromRosterId.add( originalProposal.OwnerId );
        }else{
            filteredRosters = originalProjectRosterList;
        }

        if( filteredRosters.isEmpty() ){
            for( Project_Roster__c roster: originalProjectRosterList ){
                if( !excludeUsersFromRosterId.contains(roster.User__c) ){
                    filteredRosters.add(roster);
                }
            }
        }

        List<Project_Roster__c> clonedRosters = filteredRosters.deepClone();
        for( Project_Roster__c roster: clonedRosters ){
            roster.Proposal__c = clonedProposal.Id;
            roster.Project_Profile__c = null;
            roster.Key__c = null;
            roster.OwnerId = UserInfo.getUserId();
        }
        try {
            insert clonedRosters;
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            status = false;
        }

        return status;
    }

    public PageReference backAction() {
        PageReference pageReference = new ApexPages.StandardController(this.proposal).view();
        pageReference.setRedirect(true);
        return pageReference;
    }
}