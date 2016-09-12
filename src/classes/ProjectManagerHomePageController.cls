public with sharing class ProjectManagerHomePageController{

    private static final Integer MAX_URL_LENGTH = 2000;

    public static Id currentUserId {
        get{
            if( currentUserId == null ) currentUserId = UserInfo.getUserId();
            return currentUserId;
        }
    }

    public static String currentUserName {
        get{
            if( currentUserName == null ) currentUserName = UserInfo.getName();
            return currentUserName;
        }
    }

    public static List<Profile> currentProfile {
        get{
            if( currentProfile == null ) currentProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1];
            return currentProfile;
        }
    }

    public static String currentUserProfileName {
        get{
            if( currentUserProfileName == null ) currentUserProfileName = currentProfile[0].Name;
            return currentUserProfileName;
        }
    }

    public static List<UserRole> currentRole {
        get{
            if( currentRole == null ) currentRole = [SELECT Id, Name FROM UserRole WHERE Id =: UserInfo.getUserRoleId() LIMIT 1];
            return currentRole;
        }
    }

    public static Set<ID> getRoleSubordinateUsers( Id userId ) {

        Id roleId = UserInfo.getUserRoleId();

        Set<Id> allSubRoleIds = getAllSubRoleIds( new Set<Id>{roleId} );

        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds]);

        return users.keySet();
    }

    public static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();

        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN :roleIds AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
        }

        if(currentRoleIds.size() > 0) currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

        return currentRoleIds;
    }

    public static List<UserRole> reportToCurrentRole {
        get{
            if( reportToCurrentRole == null ) reportToCurrentRole = [SELECT Id, Name, ParentRoleID FROM UserRole WHERE ParentRoleID =: currentRole[0].Id ];
            return reportToCurrentRole;
        }
    }

    public List<Proposal__c> processingProposals {
        get{
            List<Proposal__c> processingProposals = new List<Proposal__c>();
            if( isPartner ) {
                processingProposals = psRFPProposals;
            } else if( isSIPSUser ) {
                processingProposals = proposalsInInternalReviewSIPS;
            }
            return processingProposals;
        }
    }

    public Boolean needProposal {
        get{
            return isSIPSUser || isProposalSpecialist;
        }
        set;
    }

    public Boolean isSIPSUser {
        get{
            return ( currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ||
                     currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_COORDINATOR) );
        }
        set;
    }

    public Boolean isProposalSpecialist {
        get{
            if( currentProfile[0].Name == UserServices.PROFILE_PROPOSAL_SPECIALIST ) return true;
            return false;
        }
        set;
    }

    public Boolean isProjectManager1 {
        get{
            if( currentProfile[0].Name == UserServices.PROFILE_PROJECT_MANAGER_1 ) return true;
            return false;
        }
        set;
    }

    public Boolean isCZAnalyst {
        get{
            if( currentProfile[0].Name == UserServices.PROFILE_CODE_ZONING_ANALYST ) return true;
            return false;
        }
        set;
    }

    public Boolean isPartner {
        get{
            if( currentProfile[0].Name.contains(UserServices.PROFILE_PARTNER) ) return true;
            return false;
        }
        set;
    }

    public List<selectOption> partnerOptions {get{if(partnerOptions == null) partnerOptions = new List<selectOption>(); return partnerOptions;} set;}

    public String partnerId{ get;set; }

    public Boolean isExecutiveAdmins {
        get{
            if( currentProfile[0].Name.contains( UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ) ) return true;
            return false;
        }
        set;
    }

    private Map<String, String> partnerIdToService;
    private Map<String, String> partnerIdToColor;
	public Set<Id> setOfPm1AndPm2Ids; // MRS 6560

    public ProjectManagerHomePageController(){

        if( isExecutiveAdmins ){

            List<String> partnersName = new List<String>();
            partnerIdToService = new Map<String, String>();
            partnerIdToColor = new Map<String, String>();
            Map<String, String> partnerNameToPartnerId = new Map<String, String>();

            for( User item: [ Select Id, Name From User Where Profile.Name =: UserServices.PROFILE_PARTNER AND isActive = true ]){
                partnerNameToPartnerId.put( item.Name, item.Id );

            }

            for( PartnerOptions__c item: PartnerOptions__c.getall().values()){
                if( !currentRole.isEmpty() && item.Admin_Role__c == currentRole[0].Name ){
                    partnersName.add( item.Partner_Name__c );
                    partnerIdToService.put( partnerNameToPartnerId.get( item.Partner_Name__c ), item.Partner_Service__c );
                    partnerIdToColor.put( partnerNameToPartnerId.get( item.Partner_Name__c ), item.Partner_Color__c );
                }
            }

            for( User item: [Select Name, Id, UserRoleId From User Where Name IN: partnersName AND isActive = true Order by Name]){
                partnerOptions.add( new SelectOption( item.Id, item.Name ) );

                if ( partnerId == null && ( (currentRole[0].Name == UserServices.ROLE_EXECUTIVE_ADMIN_1 && item.Name == UserServices.DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_1) ||
                							(currentRole[0].Name == UserServices.ROLE_EXECUTIVE_ADMIN_2 && item.Name == UserServices.DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_2) ||
                							(currentRole[0].Name == UserServices.ROLE_EXECUTIVE_ADMIN_3 && item.Name == UserServices.DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_3) ) ) {
                	partnerId = item.Id;
                	colorPartner = partnerIdToColor.get( partnerId );
                }

            }

        }
        if( ApexPages.currentPage().GetURL().contains( PMChangeOrderTracking_PAGE ) )    partnerChangeOrdersDefault();
        if( ApexPages.currentPage().GetURL().contains( EAMyChangeOrderTracking_PAGE ) )  executiveAdminsChangeOrdersDefault();
        if( ApexPages.currentPage().GetURL().contains( EAMyServiceAssignments_PAGE ) )   executiveAdminMyServicesDefault();
        if( ApexPages.currentPage().GetURL().contains( PSRFPProposalChangeOrde_PAGE ) )  partnerRFPProposalsInProcessDefault();
        if( ApexPages.currentPage().GetURL().contains( ADMServiceAssignments_PAGE ) )    partnerServicesDefault();
        if( ApexPages.currentPage().GetURL().contains( PartnerActiveProjects_PAGE ) )    partnerActiveProjectsDefaults();
		if( ApexPages.currentPage().GetURL().contains( ProjectManagerHomeTasksList ) ) { // MRS 6560
			pupulateSetOfPm1AndPm2Ids();
		} else {
			setOfPm1AndPm2Ids = new Set<Id> ();
			setOfPm1AndPm2Ids.add(currentUserId);
		}
    }

    public static final String PMChangeOrderTracking_PAGE = 'PMChangeOrderTracking';
    public static final String EAMyChangeOrderTracking_PAGE = 'EAMyChangeOrderTracking';
    public static final String EAMyServiceAssignments_PAGE = 'EAMyServiceAssignments';
    public static final String PSRFPProposalChangeOrde_PAGE = 'PSRFPProposalChangeOrde';
    public static final String ADMServiceAssignments_PAGE = 'ADMServiceAssignments';
    public static final String PartnerActiveProjects_PAGE = 'PartnerActiveProjects';
	public static final String ProjectManagerHomeTasksList = 'PMSFTaskActivities'; // MRS 6560

    public String colorPartner {get; set;}

    public PageReference refreshPartner() {
        colorPartner = partnerIdToColor.get( partnerId );

        if( ApexPages.currentPage().GetURL().contains( PMChangeOrderTracking_PAGE ) )    partnerChangeOrdersDefault();
        if( ApexPages.currentPage().GetURL().contains( PSRFPProposalChangeOrde_PAGE ) )  partnerRFPProposalsInProcessDefault();
        if( ApexPages.currentPage().GetURL().contains( ADMServiceAssignments_PAGE ) )    partnerServicesDefault();
        if( ApexPages.currentPage().GetURL().contains( PartnerActiveProjects_PAGE ) )    partnerActiveProjectsDefaults();

        return null;
    }

    public Boolean isFREP {
        get{
            if( currentProfile[0].Name == UserServices.PROFILE_FREP ) return true;
            return false;
        }
        set;
    }

    public List<Project_Profile__c> notStartedProjectsForProjectManagerMap {
       get {
            Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_ACCOUNT_MANAGER,
                                                         UserServices.PROFILE_PROJECT_MANAGER_1,
                                                         UserServices.PROFILE_PROJECT_MANAGER_2,
                                                         UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                         UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                         UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER,
                                                         UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME,
                                                         UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                         UserServices.SUPPORT_STAFF,
                                                         UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER,
                                                         UserServices.PROFILE_CODE_ZONING_ANALYST,
                                                         UserServices.PROFILE_SIPS_COORDINATOR };

            if ( !validProfiles.contains(currentProfile[0].Name) ) return null;
            Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
            													ProjectProfileServices.PROJECT_STATE_CLOSED,
            													ProjectProfileServices.PROJECT_STATE_ON_HOLD };
            String query = ' Select Id, Name, Project_Name__c, Primary_Company_Name__r.Name, Building__r.Name, Proposal__c, Proposal__r.Name, Proposal__r.Proposal_Awarded_Date__c, ' +
                           '        Project_Team__r.Project_Manager__c, Project_Team__r.Project_Member__c, CreatedDate ' +
                           ' From Project_Profile__c ' +
                           ' Where Submitted_Planned_Dates__c = false ' +
                           ' AND Proposal__r.Proposal_Awarded_Date__c != null ' +
                           ' AND Project_State__c NOT IN: notValidProjectState ';

            if ( currentProfile[0].Name == UserServices.PROFILE_SHARED_SERVICES_MANAGER ||
                 currentProfile[0].Name == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                 currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ) {
                query += 'AND Project_Team__c = null ';
                if ( currentProfile[0].Name == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) {
                    query += ' AND OwnerId =\''+currentUserId+'\'';
                }
            } else if ( currentProfile[0].Name == UserServices.PROFILE_ACCOUNT_MANAGER ) {
                 if ( !currentRole.isEmpty() && currentRole[0].Name.contains( UserServices.ROLE_MANAGER_OF_ACCOUNTS ) ){
                     Set<ID> accountmanagersIds = getRoleSubordinateUsers( currentUserId );
                     query += ' AND ( OwnerId IN: accountmanagersIds OR OwnerId =\''+currentUserId+'\' ) ';
                 }else{
                     query += ' AND OwnerId =\''+currentUserId+'\'';
                 }
            }else {
                query += 'AND (Project_Team__r.Project_Manager__c =: currentUserId OR Project_Team__r.Project_Member__c =: currentUserId OR OwnerId =: currentUserId ) ';
            }
            query += 'Order by CreatedDate DESC limit 1000';
            notStartedProjectsForProjectManagerMap = database.query(query);

            return notStartedProjectsForProjectManagerMap;
        }
        set;
    }

    public List<Change_Order__c> changeOrders {
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PROJECT_MANAGER_1,
                                                          UserServices.PROFILE_PROJECT_MANAGER_2,
                                                          UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                          UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                          UserServices.PROFILE_PROPOSAL_SPECIALIST,
                                                          UserServices.PROFILE_ACCOUNT_MANAGER,
                                                          UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER,
                                                          UserServices.PROFILE_SIPS_COORDINATOR,
                                                          UserServices.PROFILE_CODE_ZONING_ANALYST,
                                                          UserServices.PROFILE_PRODUCTION_MANAGER,
                                                          UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                          UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER,
                                                          UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME };
             if ( !validProfiles.contains(currentProfile[0].Name) ) return null;

             Set<String> statuses = getProcessingStatuses( currentProfile[0].Name );
             Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
             													ProjectProfileServices.PROJECT_STATE_ON_HOLD,
             													ProjectProfileServices.PROJECT_STATE_CLOSED };

             String query = 'Select Status__c, Proposal__r.Name, Proposal__c, Project_Profile__r.Project_Name__c, Project_Profile__r.OwnerId, Approved_Date__c, Number__c, '+
                                   'Project_Profile__r.Building__c, Project_Profile__r.Name, Project_Profile__c, Name, Change_Request_Date__c, Last_Change_Date__c, ' +
                                   'Version__c, Project_Profile__r.Building__r.Name, Proposal__r.Version__c, Project_Profile__r.Project_Member__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c, ' +
                                   'Project_Profile__r.Project_Manager__c, Proposal__r.Proposal_Awarded_Date__c, Proposal__r.Region__c, Internal_Reviewer__c, eSigned__c, CreatedById ' + //MRS 7019
                            'From Change_Order__c Where ( ( ';

             if ( currentProfile[0].Name == UserServices.PROFILE_CODE_ZONING_ANALYST ) {
                 //MRS 7019
                 query += '( CreatedById = \'' + currentUserId + '\' OR '
                        + '( Code_Zoning_Analyst__r.Id = \''+currentUserId+'\' AND Status__c = \'' + ChangeOrderServices.STATUS_IN_INT_REVIEW + '\' ) ) ';
             } else if ( currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ) {
                 query += '     ( Internal_Reviewer__r.Id = \'' + currentUserId + '\' AND ' +
                          '     SIPS_Coordinator__c = null )';

             } else if ( currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_COORDINATOR) ) {
                 query += ' SIPS_Coordinator__c = \'' + currentUserId + '\'';

             } else if ( currentProfile[0].Name == UserServices.PROFILE_PROPOSAL_SPECIALIST ) {
                 query += ' Project_Profile__r.Proposal_Specialist__r.Id = \'' + currentUserId + '\' OR '+
                          '     Internal_Reviewer__r.Id = \'' + currentUserId + '\'';
             } else if ( currentProfile[0].Name == UserServices.PROFILE_PRODUCTION_MANAGER ) {
                 query += ' ( Project_Profile__r.Production_Manager__r.ProfileId = \'' + currentProfile[0].Id + '\' AND ' +
                          '     Project_Profile__r.Production_Manager__r.Id =\'' + currentUserId + '\' )';

             } else if ( currentProfile[0].Name.contains( UserServices.PROFILE_PROJECT_MANAGER ) ) {
                 query += ' ( Project_Profile__r.Project_Member__r.Id = \'' + currentUserId + '\' OR ' +
                          '   Project_Profile__r.Project_Manager__r.Id = \'' + currentUserId + '\' OR ' +
                          '   Project_Profile__r.OwnerId = \'' + currentUserId + '\' )';

             } else if ( currentProfile[0].Name == UserServices.PROFILE_ACCOUNT_MANAGER ) {
                 query += ' Project_Profile__r.Account_Executive__r.Id = \'' + currentUserId + '\' OR ' +
                          '       Internal_Reviewer__r.Id = \'' + currentUserId + '\' ) AND ' +
                          '        ( Status__c IN: statuses )' ;

             } else {
                 query += ' OwnerId =\''+currentUserId+'\'';
             }

             if ( currentProfile[0].Name != UserServices.PROFILE_ACCOUNT_MANAGER ){
                query += ' OR Project_Profile__r.OwnerId = \'' + currentUserId + '\' ) AND (Status__c IN: statuses) ';
             }

         if ( currentProfile[0].Name == UserServices.PROFILE_PROPOSAL_SPECIALIST ) {
                query += ' ) AND ( Project_Profile__r.Project_State__c Not IN: notValidProjectState ) AND ( Status__c != \'' + ChangeOrderServices.STATUS_APPROVED + '\' ) Order by Approved_Date__c DESC limit 1000';
         }else{
            query += ' ) AND ( Project_Profile__r.Project_State__c Not IN: notValidProjectState ) AND ( NOT ( Status__c = \'' + ChangeOrderServices.STATUS_APPROVED + '\' AND Approved_Date__c < ' + String.valueOf(Date.today().addDays(-28) ) + ') ) Order by Approved_Date__c DESC limit 1000';
         }

             changeOrders = database.query(query);
             return changeOrders;
        }
        set;
    }

    public List<Admin_Service__c> adminServiceListForOM {
        get{
            if ( ( currentProfile[0].Name.contains(UserServices.PROFILE_OPERATIONS_MANAGER) || currentProfile[0].Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   adminServiceListForOM == null ){
                adminServiceListForOM = [SELECT Id, Name, OwnerId, Owner.Name, Category__c, Closed__c, Opened__c, Status__c
                                         FROM Admin_Service__c
                                         WHERE Status__c != 'Closed'];
            } else if( !currentProfile[0].Name.contains(UserServices.PROFILE_OPERATIONS_MANAGER) && adminServiceListForOM == null ){
                adminServiceListForOM = new List<Admin_Service__c>();
            }
            return adminServiceListForOM;
        }
        set;
    }

    public List<Proposal_Request__c> proposalRequestListForOM {
        get{
            if ( ( currentProfile[0].Name.contains(UserServices.PROFILE_OPERATIONS_MANAGER) || currentProfile[0].Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   proposalRequestListForOM == null ){
                proposalRequestListForOM = [SELECT Id, Name, CreatedById, CreatedBy.Name, CreatedDate, Rush__c, Proposal_Specialist__c, Proposal_Specialist__r.Name, Status__c
                                            FROM Proposal_Request__c
                                            WHERE Status__c IN ('Opened', 'Assigned To PS', 'Proposal In Progress')];
            } else if( !currentProfile[0].Name.contains(UserServices.PROFILE_OPERATIONS_MANAGER) && proposalRequestListForOM == null ){
                proposalRequestListForOM = new List<Proposal_Request__c>();
            }
            return proposalRequestListForOM;
        }
        set;
    }

    //MRS-7416
    public List<Opportunity> opportunityListForPS {
        get{
            if ( ( currentProfile[0].Name.contains(UserServices.PROFILE_PROPOSAL_SPECIALIST) || currentProfile[0].Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   opportunityListForPS == null ){
                opportunityListForPS = [SELECT Id, Name, OwnerId, Account.Name, CreatedDate, Opportunity_Contact__c, AccountId,
                									Opportunity_Contact__r.Name, Building__c, Building__r.Name,
                									Date_of_Proposal_Requested__c, CloseDate, Amount, Opportunity_Number__c
                                            FROM Opportunity
                                            WHERE ( OwnerId =: UserInfo.getUserId() OR Proposal_Specialist__c =: UserInfo.getUserId() )
                                            	AND StageName IN ('Initial Engagement',
                                            						'Follow-up',
                                            						'Information Gathering',
                                            						'Scope Review Required',
                                            						'Proposal Required')];
            } else {
                opportunityListForPS = new List<Opportunity>();
            }
            return opportunityListForPS;
        }
        set;
    }

    public transient List<Change_Order__c> partnerChangeOrders {
        get;
        set;
    }

    public void partnerChangeOrdersDefault() {

         Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PARTNER, UserServices.EXECUTIVE_ADMIN_PROFILE_NAME };
         Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
         													ProjectProfileServices.PROJECT_STATE_ON_HOLD,
         													ProjectProfileServices.PROJECT_STATE_CLOSED };

         if ( validProfiles.contains(currentProfile[0].Name) ){
             Set<String> statuses = getProcessingStatuses( currentProfile[0].Name );
             String query = 'Select Status__c, Proposal__r.Name, Proposal__c, Project_Profile__r.Project_Name__c, Project_Profile__r.OwnerId, Approved_Date__c, Number__c, '+
                            '       Project_Profile__r.Building__c, Project_Profile__r.Name, Project_Profile__c, Name, Change_Request_Date__c, Last_Change_Date__c, ' +
                            '       Version__c, Project_Profile__r.Building__r.Name, Proposal__r.Version__c, Project_Profile__r.Project_Member__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c, '+
                            '       Project_Profile__r.Project_Manager__c, Proposal__r.Proposal_Awarded_Date__c, Proposal__r.Region__c, Internal_Reviewer__c, eSigned__c '+
                            'From Change_Order__c Where ';
             if ( partnerId != null ) {
                query += ' ( Internal_Reviewer__r.Id = \'' + partnerId + '\' OR ' +
                         ' Project_Profile__r.Partner__r.Id = \'' + partnerId + '\' )';
             } else{
                query += ' ( Internal_Reviewer__r.Id = \'' + currentUserId + '\' OR ' +
                         ' Project_Profile__r.Partner__r.Id = \'' + currentUserId + '\' )';
             }

             query += ' AND ( Status__c IN: statuses ) AND ( Project_Profile__r.Project_State__c Not IN: notValidProjectState ) limit 1000';

             partnerChangeOrders = database.query(query);
        }

    }

    public transient List<Change_Order__c> executiveAdminsMyChangeOrders {
        get;
        set;
    }

    public void executiveAdminsChangeOrdersDefault() {

         Set<String> validProfiles = new Set<String>{ UserServices.EXECUTIVE_ADMIN_PROFILE_NAME };
         Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
         													ProjectProfileServices.PROJECT_STATE_ON_HOLD,
         													ProjectProfileServices.PROJECT_STATE_CLOSED };

         if ( validProfiles.contains(currentProfile[0].Name) ){
             Set<String> statuses = getProcessingStatuses( currentProfile[0].Name );

             executiveAdminsMyChangeOrders = [Select Status__c, Proposal__r.Name, Proposal__c, Project_Profile__r.Project_Name__c, Project_Profile__r.OwnerId, Approved_Date__c, Number__c,
                                                       Project_Profile__r.Building__c, Project_Profile__r.Name, Project_Profile__c, Name, Change_Request_Date__c, Last_Change_Date__c,
                                                       Version__c, Project_Profile__r.Building__r.Name, Proposal__r.Version__c, Project_Profile__r.Project_Member__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c,
                                                       Project_Profile__r.Project_Manager__c, Proposal__r.Proposal_Awarded_Date__c, Proposal__r.Region__c, Internal_Reviewer__c, eSigned__c,
                                                       Project_Profile__r.Partner__c, Project_Profile__r.Partner__r.Name
                                                From Change_Order__c Where CreatedById = : currentUserId AND
                                                    ( Status__c IN: statuses ) AND ( Project_Profile__r.Project_State__c Not IN: notValidProjectState ) limit 1000];
        }

    }

    public List<Proposal__c> psRFPProposals {
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_ACCOUNT_MANAGER,
                                                          UserServices.PROFILE_PROPOSAL_SPECIALIST,
                                                          UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                          UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                          UserServices.PROFILE_CODE_ZONING_ANALYST };

             if ( !validProfiles.contains(currentProfile[0].Name) ) return null;

             Set<String> statuses = new Set<String>{ ProposalServices.PROPOSAL_STATUS_NEW,
                                                     ProposalServices.PROPOSAL_STATUS_IN_REVIEW,
                                                     ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
                                                     ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW,
                                                     ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
                                                     ProposalServices.PROPOSAL_STATUS_REJECTED,
                                                     ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE,
                                                     ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW };

             String query = ' Select Version__c, Status__c, Address__r.Name, Proposal_Type__c, Project_Profile__r.Building__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Building__r.Name, '+
                            ' Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Name, Primary_Company_Name__r.Name, Floor_s__c, Description__c, SIPS_Coordinator__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c, '+
                            ' Requested_By__r.Name, Requested_By__c, Project_Name__c, Address__c, OwnerId, Primary_Company_Name__c, Last_Status_Change__c, Region__c, Is_Draft__c, eSigned__c From Proposal__c ';

             if ( currentProfile[0].Name == UserServices.PROFILE_CODE_ZONING_ANALYST ){
                 if ( !currentRole.isEmpty() && currentRole[0].Name.contains( UserServices.ROLE_CZ_MANAGER ) ){
                     query += ' Where ( ( Code_Zoning_Analyst__c = null AND Region__c =\''+currentRole[0].Name.substringBefore(' ')+'\' ) ' +
                              '     OR Code_Zoning_Analyst__r.Id =\''+currentUserId+'\''+')';
                 }else{
                     query += ' Where Code_Zoning_Analyst__r.Id =\''+currentUserId+'\'';
                 }
             }else{
                 query += ' Where OwnerId =\''+currentUserId+'\'';
             }

             if ( currentProfile[0].Name == UserServices.PROFILE_CODE_ZONING_ANALYST ){
                 query += ' AND (Status__c =\''+ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW+'\''+') limit 1000';
             } else {
                 query += ' AND (Status__c IN: statuses) limit 1000';
             }

             psRFPProposals = database.query(query);

             if( currentProfile[0].Name == UserServices.PROFILE_PROPOSAL_SPECIALIST ){
             	for( Opportunity item: [SELECT Id, Name, OwnerId, Account.Name, CreatedDate, Date_of_Last_Contact__c,
                									Building__c, Building__r.Name, Amount, Opportunity_Number__c, StageName
                                            FROM Opportunity
                                            WHERE ( OwnerId =: UserInfo.getUserId() OR Proposal_Specialist__c =: UserInfo.getUserId() )
                                            	AND StageName = 'Proposal Required'] ){

                	psRFPProposals.add( new Proposal__c(Proposal_Type__c = 'Opportunity',
                										Opportunity__c = item.Id,
												Mi3_MRC__c = item.Opportunity_Number__c,
                										Project_Name__c = item.Name,
                										Address__c = item.Building__c,
												Municipal_Agency_ID__c = item.Building__r.Name,
                										Status__c = item.StageName,
                										Last_Follow_Up_Date__c = item.Date_of_Last_Contact__c) );

             	}
             }
             return psRFPProposals;
        }
        set;
    }

    public List<Proposal__c> partnerRFPProposalsInProcess {get;set;}

    public void partnerRFPProposalsInProcessDefault() {
        Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PARTNER, UserServices.EXECUTIVE_ADMIN_PROFILE_NAME };

             if ( validProfiles.contains(currentProfile[0].Name) ) {

             Set<String> statuses = new Set<String>{  ProposalServices.PROPOSAL_STATUS_IN_REVIEW,
                                                      ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
                                                      ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW,
                                                      ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
                                                      ProposalServices.PROPOSAL_STATUS_REJECTED,
                                                      ProposalServices.PROPOSAL_STATUS_NEW,
                                                      ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE,
                                                      ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW};

             String query = ' Select Version__c, Status__c, Address__r.Name, Proposal_Type__c, Project_Profile__r.Building__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Building__r.Name, '+
                            ' Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Name, Primary_Company_Name__r.Name, Floor_s__c, Description__c, SIPS_Coordinator__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c, '+
                            ' Requested_By__r.Name, Requested_By__c, Project_Name__c, Address__c, OwnerId, Primary_Company_Name__c, Last_Status_Change__c, Region__c, Is_Draft__c, eSigned__c From Proposal__c Where';

             if ( partnerId != null ) {
                query += ' ( Internal_Reviewer__r.Id = \'' + partnerId + '\' OR ' +
                         '  Partner__r.Id = \'' + partnerId + '\' )';
             } else{
                query += ' ( Internal_Reviewer__r.Id = \'' + currentUserId + '\' OR ' +
                         '  Partner__r.Id = \'' + currentUserId + '\' )';
             }

             query += ' AND (Status__c IN: statuses) limit 1000';

             partnerRFPProposalsInProcess = database.query(query);
        }
    }

    public List<Proposal__c> proposalsInInternalReviewSIPS {
        get {
             if ( !isSIPSUser ) return null;

             Set<String> statuses = new Set<String>{ ProposalServices.PROPOSAL_STATUS_IN_REVIEW };

             String query = ' Select Version__c, Status__c, Address__r.Name, Proposal_Type__c, Project_Profile__r.Building__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Building__r.Name, '+
                            '        Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Name, Primary_Company_Name__r.Name, Floor_s__c, Description__c, '+
                            '        Requested_By__r.Name, Requested_By__c, Project_Name__c, Address__c, OwnerId, Primary_Company_Name__c, Last_Status_Change__c, Owner.Name, SIPS_Coordinator__c ' +
                            ' From Proposal__c ';

             if ( currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ) {
                 query += ' Where Internal_Reviewer__r.Id = \'' + currentUserId + '\' AND ' +
                          '       SIPS_Coordinator__c = null AND ' +
                          '       Status__c IN: statuses limit 1000';
             } else if ( currentProfile[0].Name.contains(UserServices.PROFILE_SIPS_COORDINATOR) ) {
                 query += ' Where SIPS_Coordinator__c = \'' + currentUserId + '\' AND ' +
                          '       Status__c IN: statuses limit 1000';
             }

             proposalsInInternalReviewSIPS = database.query(query);
             return proposalsInInternalReviewSIPS;
        }
        set;
    }

    public List<Proposal__c> proposalsTraking {
        get {
            Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_ACCOUNT_MANAGER,
                                                         UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };

            if ( !validProfiles.contains(currentProfile[0].Name) ) {
                return null;
            }

            Set<String> statuses = new Set<String>{ ProposalServices.PROPOSAL_STATUS_IN_REVIEW,
                                                      ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
                                                      ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW,
                                                      ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
                                                      ProposalServices.PROPOSAL_STATUS_REJECTED,
                                                      ProposalServices.PROPOSAL_STATUS_NEW,
                                                      ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE,
                                                      ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW };

            String query =  ' Select Version__c, Status__c, Address__r.Name, Proposal_Type__c, Project_Profile__r.Building__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Building__r.Name, '+
                            '        Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Name, Primary_Company_Name__r.Name, Floor_s__c, Description__c, Last_Follow_Up_Date__c, Follow_Ups_Count__c, '+
                            '        Requested_By__r.Name, Requested_By__c, Project_Name__c, Address__c, OwnerId, Primary_Company_Name__c, Last_Status_Change__c, Owner.Name, SIPS_Coordinator__c, eSigned__c ' +
                            ' From Proposal__c ';

            query += ' Where ( Account_Executive__r.Id = \'' + currentUserId + '\' OR ' +
                      '       Internal_Reviewer__r.Id = \'' + currentUserId + '\' ) AND ' +
                      '       ( Status__c IN: statuses ) limit 1000';

            proposalsTraking = database.query(query);
            return proposalsTraking;
        }
        set;
    }

    public List<Proposal__c> getProposalsByStatuses (Set<String> statuses, Boolean isInclude) {

        String query = ' Select Version__c, Status__c, Address__r.Name, Proposal_Type__c, Project_Profile__r.Building__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Building__r.Name, '+
                '        Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Name, Primary_Company_Name__r.Name, Floor_s__c, Description__c, '+
                '        Requested_By__r.Name, Requested_By__c, Project_Name__c, Address__c, OwnerId, Primary_Company_Name__c, Last_Status_Change__c, Owner.Name, SIPS_Coordinator__c ' +
                ' From Proposal__c ';

        if (isInclude){
            query += ' Where Internal_Reviewer__r.Id = \'' + currentUserId + '\' AND ' +
                  '       Status__c IN: statuses limit 1000';
        } else {
            query += ' Where Internal_Reviewer__r.Id = \'' + currentUserId + '\' AND ' +
                  '       Status__c NOT IN: statuses limit 1000';
        }

        List<Proposal__c> results = database.query(query);

        return results;
    }

    public List<Service_Item__c> upcomingExpirationsList {
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PROJECT_MANAGER_1,
                                                          UserServices.PROFILE_PROJECT_MANAGER_2,
                                                          UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                          UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                          UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME,
                                                          UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                          UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER,
                                                          UserServices.PROFILE_SIPS_COORDINATOR,
                                                          UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER,
                                                          UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                          UserServices.PROFILE_PRODUCTION_MANAGER };
             Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
             													 ProjectProfileServices.PROJECT_STATE_CLOSED,
             													 ProjectProfileServices.PROJECT_STATE_ON_HOLD };//MRS-6465

             Set<String> validRoles = new Set<String>{ UserServices.ROLE_DOT_DEPARTMENT_MANAGER,
                                                       UserServices.ROLE_AHV_DEPARTMENT_MANAGER };//MRS-6689

             if ( !validProfiles.contains(currentProfile[0].Name) && !validRoles.contains( currentRole[0].Name ) ) return null;

             Date expectedDate1 = Date.today();
             Date expectedDate2 = (DateUtils.getDatetimeWithTimeShiftByBusinessHours(DateTime.now(), '7d')).Date();
             Date expectedDate3 = (DateUtils.getDatetimeWithTimeShiftByBusinessHours(DateTime.now(), '20d')).Date();

             Set<Id> validUsersId = getRoleSubordinateUsers( currentUserId );

             String query = ' Select Id, Name, Expiration_Date__c, Proposal__r.Primary_Company_Name__c, Municipal_Agency_ID__c, Proposal__r.Floor_s__c, Project_Profile__r.Building__c, Project_Profile__c, ' +
                            '   Proposal__r.Name, Project_Profile__r.Name, Proposal__r.Primary_Company_Name__r.Name, Service_Name_Full__c, Project_Profile__r.Building__r.Name, ' +
                            '   Renewal_Required__c, Comment__c ' +
                            ' From Service_Item__c ' +
                            ' Where Expiration_Date__c >: expectedDate1 AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\' AND ' + //MRS-6465
                            ' Project_Profile__c != null AND ( Project_Profile__r.Project_State__c Not IN: notValidProjectState ) AND ' +
                            '   ( Project_Profile__r.Project_Team__r.Project_Manager__c = \'' + currentUserId + '\' OR ' +
                            '       Project_Profile__r.Project_Team__r.Project_Member__c = \'' + currentUserId + '\' OR ' +
                            '       OwnerId = \'' + currentUserId + '\' ';

            if ( !currentRole.isEmpty() && validRoles.contains( currentRole[0].Name ) ){
                query +=    '     OR OwnerId IN: validUsersId ) AND ( ( Expiration_Date__c <=: expectedDate2 AND Service_Template__r.Is_AHV_Service__c = true ) OR ( Expiration_Date__c <=: expectedDate3 AND Service_Template__r.Is_DOT_Service__c = true ) ) ';
            } else if ( currentProfile[0].Name == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ||
                  currentProfile[0].Name == UserServices.PROFILE_SHARED_SERVICES_MANAGER ||
                  currentProfile[0].Name == UserServices.PROFILE_CLIENT_SERVICE_MANAGER || //MRS-6952
                  currentProfile[0].Name == UserServices.PROFILE_PRODUCTION_MANAGER ) {
                query += ' OR OwnerId IN: validUsersId ) ';
             } else {
                query += ' ) ';
             }

             query += ' Order by Expiration_Date__c DESC limit 1000 ';

             upcomingExpirationsList = database.query(query);
             return upcomingExpirationsList;
        }
        set;
    }

    public Map<Id, Service_Item__c> upcomingExpirationsAdmDepartmentManager {
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.SUPPORT_STAFF, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };
             Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
             													 ProjectProfileServices.PROJECT_STATE_CLOSED,
             													 ProjectProfileServices.PROJECT_STATE_ON_HOLD };

             if ( !validProfiles.contains(currentProfile[0].Name) ) return null;

             upcomingExpirationsAdmDepartmentManager = new Map<Id, Service_Item__c>([ Select Proposal__r.Expiration_Date__c, Proposal__r.Floor_s__c, Proposal__r.Address__c, Proposal__r.Project_Name__c, Proposal__r.Name, Proposal__r.Primary_Company_Name__c,
                                                Proposal__r.Id, Proposal__c, Municipal_Agency_ID__c, Project_Profile__r.Building__c, Project_Profile__r.Primary_Company_Name__c,
                                                Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Name, Id, Expiration_Date__c,
                                                Proposal__r.Project_Team__r.Project_Manager__c, Proposal__r.Project_Team__r.Project_Member__c, Proposal__r.Primary_Company_Name__r.Name,
                                                Project_Profile__r.Building__r.Name, Service_Name_Full__c, Project_Profile__r.Project_Team__r.Name, Project_Profile__r.Project_Team__c
                                            From Service_Item__c s
                                            Where Expiration_Date__c >: Date.today()
                                                AND Expiration_Date__c <=: Date.today().addDays(30)
                                                AND Status__c !=: ServiceItemServices.SERVICE_STATUS_COMPLETED
                                                AND Status__c !=: ServiceItemServices.SERVICE_STATUS_INACTIVE
                                                AND Project_Profile__c != null
                                                AND Project_Profile__r.Project_State__c Not IN: notValidProjectState
                                            Order by Expiration_Date__c DESC
                                            limit 1000]);
             return upcomingExpirationsAdmDepartmentManager;
        }
        set;
    }

    public List<Service_Item__c> serviceAssignmentsAdmDepartmentManager {
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_ACCOUNT_MANAGER,
                                                          UserServices.SUPPORT_STAFF,
                                                          UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER,
                                                          UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME,
                                                          UserServices.PROFILE_SIPS_COORDINATOR,
                                                          UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER,
                                                          UserServices.PROFILE_CODE_ZONING_ANALYST,
                                                          UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                          UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                          UserServices.PROFILE_OPERATIONS_MANAGER,
                                                          UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                          UserServices.PROFILE_PRODUCTION_MANAGER };
             Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
             													 ProjectProfileServices.PROJECT_STATE_CLOSED,
             													 ProjectProfileServices.PROJECT_STATE_ON_HOLD };

             if ( !validProfiles.contains(currentProfile[0].Name) ) return null;

             String query = ' Select ID, Name, Service_Name_Full__c, Project_Profile__r.Name, Project_Name__c, Project_Profile__r.Building__c, CreatedDate, Project_Profile__r.CreatedDate, ' +
                            '   Project_Profile__r.Building__r.Name, Project_Profile__r.Floor_s__c, Expected_Start_Date__c, Expected_End_Date__c, Project_Profile__c, ' +
                            '   Project_Profile__r.Project_Team__c, Project_Profile__r.Project_Team__r.Name, OwnerId, Owner.Name, Awarded_Date__c ' + //MRS 7019
                            ' From  Service_Item__c ' +
                            ' Where  Status__c != \'' + ServiceItemServices.SERVICE_STATUS_COMPLETED + '\' AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\' AND'+
                            ' Project_Profile__c != null AND (Project_Profile__r.Project_State__c Not IN: notValidProjectState)';

                 if ( currentProfile[0].Name == UserServices.PROFILE_ACCOUNT_MANAGER ){
                     if ( !currentRole.isEmpty() && currentRole[0].Name.contains( UserServices.ROLE_MANAGER_OF_ACCOUNTS ) ){
                         //Set<ID> accountmanagersIds = getRoleSubordinateUsers( currentUserId );
                         query += ' AND OwnerId =\''+currentUserId+'\' ';
                     }else{
                         query += ' AND OwnerId =\''+currentUserId+'\' ';
                     }
                 }else{
                    query += ' AND OwnerId =\''+currentUserId+'\'';
                 }
                 if ( isCZAnalyst ) { // MRS 7019
                  query += ' Order by Awarded_Date__c DESC limit 1000 ';
                 } else {
                  query += ' Order by CreatedDate DESC limit 1000 ';
                 }

             serviceAssignmentsAdmDepartmentManager = database.query(query);
             return serviceAssignmentsAdmDepartmentManager;
        }
        set;
    }

    public List<Service_Item__c> partnerServices { get; set; }
    public String partnerServicesSeqNumber { get; set; }

    public void partnerServicesDefault() {
         Set<String> validProfiles = new Set<String>{ UserServices.EXECUTIVE_ADMIN_PROFILE_NAME, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };
         Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
         													 ProjectProfileServices.PROJECT_STATE_CLOSED,
         													 ProjectProfileServices.PROJECT_STATE_ON_HOLD };

         if ( validProfiles.contains(currentProfile[0].Name) ) {


             if( partnerIdToService!= null && partnerId != null) partnerServicesSeqNumber = partnerIdToService.get( partnerId );

             partnerServices = new List<Service_Item__c>([ Select ID, Name, Service_Name_Full__c, Project_Profile__r.Name, Project_Name__c, Project_Profile__r.Building__c, CreatedDate, Project_Profile__r.CreatedDate,
                                                            Project_Profile__r.Building__r.Name, Project_Profile__r.Floor_s__c, Expected_Start_Date__c, Expected_End_Date__c, Project_Profile__c,
                                                            Project_Profile__r.Project_Team__c, Project_Profile__r.Project_Team__r.Name, OwnerId, Owner.Name,
                                                            Original__c, Change_Order__c, Awarded_Date__c //MRS-6774 MRS 7019
                                                        From Service_Item__c
                                                        Where Service_Template_Row__c =: partnerServicesSeqNumber
                                                            AND Status__c !=: ServiceItemServices.SERVICE_STATUS_COMPLETED
                                                            AND Status__c !=: ServiceItemServices.SERVICE_STATUS_INACTIVE
                                                            AND Project_Profile__c != null
                                                            AND Project_Profile__r.Project_State__c Not IN: notValidProjectState
                                                        Order by CreatedDate DESC
                                                        limit 1000]);
        }
    }

    //MRS-6774
    public transient List<Service_Item__c> executiveAdminMyServices { get; set; }

    public void executiveAdminMyServicesDefault() {
         Set<String> validProfiles = new Set<String>{ UserServices.EXECUTIVE_ADMIN_PROFILE_NAME, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };
         Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
         													 ProjectProfileServices.PROJECT_STATE_CLOSED,
         													 ProjectProfileServices.PROJECT_STATE_ON_HOLD };

         if ( validProfiles.contains(currentProfile[0].Name) ) {

             executiveAdminMyServices = new List<Service_Item__c>([ Select ID, Name, Service_Name_Full__c, Project_Profile__r.Name, Project_Name__c, Project_Profile__r.Building__c, CreatedDate, Project_Profile__r.CreatedDate,
                                                            Project_Profile__r.Building__r.Name, Project_Profile__r.Floor_s__c, Expected_Start_Date__c, Expected_End_Date__c, Project_Profile__c,
                                                            Project_Profile__r.Project_Team__c, Project_Profile__r.Project_Team__r.Name, OwnerId, Owner.Name,
                                                            Project_Profile__r.Partner__c, Project_Profile__r.Partner__r.Name, Awarded_Date__c, Original__c, Change_Order__c /* MRS 7019*/
                                                        From Service_Item__c
                                                        Where OwnerId = : userinfo.getuserid()
                                                            AND Status__c !=: ServiceItemServices.SERVICE_STATUS_COMPLETED
                                                            AND Status__c !=: ServiceItemServices.SERVICE_STATUS_INACTIVE
                                                            AND Project_Profile__c != null
                                                            AND Project_Profile__r.Project_State__c Not IN: notValidProjectState
                                                        Order by CreatedDate DESC
                                                        limit 1000]);
        }
    }

    public Map<Id, Project_Profile__c> newProjectAssignmentsForProdM {
       get {
            Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PRODUCTION_MANAGER,
                                                         UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                         UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                         UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                         UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER };

            if ( !validProfiles.contains(currentProfile[0].Name) ) return null;
            Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
            													ProjectProfileServices.PROJECT_STATE_ON_HOLD,
            													ProjectProfileServices.PROJECT_STATE_CLOSED };
            newProjectAssignmentsForProdM = new Map<Id, Project_Profile__c>([ Select Id, Name, Project_Name__c, Primary_Company_Name__r.Name, Building__r.Name, CreatedDate,
                    Proposal__c, Proposal__r.Proposal_Awarded_Date__c, Project_Team__r.Project_Manager__c, Project_Team__r.Project_Member__c, Project_Team__r.Name, Project_Team__r.Id
                From Project_Profile__c
                Where Submitted_Planned_Dates__c = false AND (Project_Team__r.Production_Manager__c =: currentUserId OR OwnerId =: currentUserId) AND
                    Proposal__r.Proposal_Awarded_Date__c != null AND Project_State__c NOT IN: notValidProjectState
                limit 1000]);

            return newProjectAssignmentsForProdM;
        }
        set;
    }

    public transient List<Project_Profile__c> partnerActiveProjects { get; set; }

    public void partnerActiveProjectsDefaults() {

        Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                     UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
                                                     UserServices.PROFILE_PARTNER,
                                                     UserServices.EXECUTIVE_ADMIN_PROFILE_NAME,
                                                     UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                     UserServices.PROFILE_ACCOUNT_MANAGER };

        if ( validProfiles.contains(currentProfile[0].Name) ) {
            Set<String> statuses = new Set<String>{ ProjectProfileServices.PROJECT_STATE_IN_PROCESS, ProjectProfileServices.PROJECT_STATE_NOT_STARTED };
            String query = ' Select Id, Name, Project_Name__c, Building__r.Name, Project_Manager__r.Name, Floor_s__c, CreatedDate, ' +
                       '        Proposal__c, Proposal__r.Proposal_Awarded_Date__c, Proposal__r.Name, Partner__r.Name, Project_Team__r.Name ' +
                       '     From Project_Profile__c ' +
                       '     Where Project_State__c IN: statuses ';
             if( currentProfile[0].Name == UserServices.PROFILE_SHARED_SERVICES_MANAGER ){
                 query += ' AND OwnerId =\'' + currentUserId+'\'';
             }else if( currentProfile[0].Name != UserServices.PROFILE_ACCOUNT_MANAGER ){
                 if ( partnerId != null ) {
                    query += ' AND Partner__c =\'' + partnerId + '\'';
                 } else{
                    query += ' AND Partner__c =\'' + currentUserId+'\'';
                 }
             } else{
                 query += ' AND Account_Executive__c =\'' + currentUserId+'\'';
             }
             query += ' Order by CreatedDate DESC limit 1000 ';
             partnerActiveProjects = database.query(query);
        }
    }

    public transient List<Task_Item__c> milestones;
    public List<Task_Item__c> getMilestones() {
        return retriveMilestones();
    }

    public Date expectedDate1 {
        get{
            return expectedDate1;
        }
        set{ expectedDate1 = value;}
    }

    public Date expectedDate2 {
        get{
            return expectedDate2;
        }
        set{ expectedDate2 = value;}
    }

    public PageReference doSearch(){
        milestones = retriveMilestones();
        return null;
    }

    public List<Task_Item__c> retriveMilestones(){
        Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_PRODUCTION_MANAGER,
                                                     UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                     UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };
        Set<String> notValidProjectState = new Set<String>{ ProjectProfileServices.PROJECT_STATE_COMPLETE,
        													ProjectProfileServices.PROJECT_STATE_ON_HOLD,
        													ProjectProfileServices.PROJECT_STATE_CLOSED };

        List<Task_Item__c> resultMilestoneList = new List<Task_Item__c>();

        if ( validProfiles.contains(currentProfile[0].Name) ){

            String recordType = TaskManagementServices.MILESTONE_RECORDTYPE_NAME;
            String tasksQuery = 'SELECT Id, Name, Expected_Start_Date__c, Planned_Start_Date__c, Actual_Start_Date__c, Project_Profile__r.Project_Team__c, Project_Profile__r.Floor_s__c, Project_Profile__r.Expected_Occupancy_Date__c, '+
                '                    Project_Profile__r.Expected_Construction_Start_Date__c, Project_Profile__r.Building__c, Project_Profile__r.Primary_Company_Name__c, Project_Profile__r.OwnerId, Project_Profile__r.Id, Project_Profile__c, Project_Profile__r.Primary_Company_Name__r.Name, '+
                '                    Project_Profile__r.Building__r.Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Task_Status_Color__c, Expected_End_Date__c, Actual_End_Date__c, Project_Profile__r.Project_Team__r.Name '+
                '                FROM Task_Item__c ' +
                '                WHERE RecordType.Name =: recordType AND Project_Profile__r.Project_Team__r.Production_Manager__c =: currentUserId AND Expected_Start_Date__c != null AND Project_Profile__r.Submitted_Planned_Dates__c = true '+
                '                      AND (Project_Profile__r.Project_State__c Not IN: notValidProjectState)' +
                '                      AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_COMPLETED + '\' AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\'';
            if ( expectedDate1 != null && expectedDate2 != null ) {
                tasksQuery += 'AND Expected_Start_Date__c >=: expectedDate1 AND Expected_Start_Date__c <=: expectedDate2 limit 1000';
            } else if ( expectedDate1 == null && expectedDate2 != null ){
                tasksQuery += 'AND Expected_Start_Date__c <=: expectedDate2 limit 1000';
            } else if ( expectedDate1 != null && expectedDate2 == null ){
                tasksQuery += 'AND Expected_Start_Date__c >=: expectedDate1 limit 1000';
            } else {
                tasksQuery += 'limit 1000';
            }
            resultMilestoneList = DataBase.query(tasksQuery);
        }

        return resultMilestoneList;
    }

    public List<Proposal__c> assignNewProjectsOMSS{
        get {
             Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_OPERATIONS_MANAGER,
                                                          UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                          UserServices.PROFILE_DIRECTOR_OF_OPERATIONS,
                                                          UserServices.PROFILE_CLIENT_SERVICE_MANAGER, //MRS-6952
                                                          UserServices.PROFILE_PRODUCTION_MANAGER };//MRS-6507

             if ( !validProfiles.contains( currentProfile[0].Name) ) return null;

			 List<Proposal__c> assignNewProjectsOMSSfull;
             if( currentProfile[0].Name != UserServices.PROFILE_PRODUCTION_MANAGER &&
                 currentProfile[0].Name != UserServices.PROFILE_CLIENT_SERVICE_MANAGER ){ //MRS-6952
             	assignNewProjectsOMSSfull = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c,
                                                                Description__c, Name, Address__c, OwnerId, Last_Status_Change__c, Region__c, Project_Name__c
                                                            From Proposal__c
                                                            Where ( Status__c =: ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null AND Project_Profile__c = null )];
             }else{
             	assignNewProjectsOMSSfull = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c,
                                                                Description__c, Name, Address__c, OwnerId, Last_Status_Change__c, Region__c, Project_Name__c
                                                            From Proposal__c
                                                            Where ( Status__c =: ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null AND Project_Profile__c = null AND Production_Manager__c =: currentUserId)];
             }


         	for( Proposal__c item: [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c, Production_Manager__c,
                                                            Description__c, Name, Address__c, OwnerId, Last_Status_Change__c, Region__c, Project_Name__c,
                                                            ( Select Id From Service_Items__r
                                                                Where Original__c = false
                                                                    AND Is_Amendmend_Added__c = true
                                                                    AND Change_Order_Status__c =: ChangeOrderServices.STATUS_APPROVED
                                                                    AND Service_Template_Row__c like 'APS%'
                                                                    limit 1)
                                                        From Proposal__c
                                                        Where Status__c =: ProposalServices.PROPOSAL_STATUS_AWARDED
                                                            AND Proposal_Awarded_Date__c != null
                                                            AND Project_Profile__r.Project_Team__c = null
                                                            AND Project_Profile__c != null ] ){
                 for( Service_Item__c item1: item.Service_Items__r ){
                     if( currentProfile[0].Name != UserServices.PROFILE_PRODUCTION_MANAGER &&
                          currentProfile[0].Name != UserServices.PROFILE_CLIENT_SERVICE_MANAGER ){ //MRS-6952
                     	assignNewProjectsOMSSfull.add( item );
                     }else{
                     	if( item.Production_Manager__c == currentUserId ) assignNewProjectsOMSSfull.add( item );
                     }
                 }
             }

             return assignNewProjectsOMSSfull;
        }
        set;
    }

	public void pupulateSetOfPm1AndPm2Ids() { // MRS 6560
		setOfPm1AndPm2Ids = new Set<Id> ();
		for(Project_Team__c projectTeam : [SELECT Project_Member__c, Project_Manager__c FROM Project_Team__c
											   WHERE Project_Member__c =: currentUserId OR Project_Manager__c =:currentUserId]) {
			if(!String.isBlank(projectTeam.Project_Member__c)) setOfPm1AndPm2Ids.add(projectTeam.Project_Member__c);
			if(!String.isBlank(projectTeam.Project_Manager__c)) setOfPm1AndPm2Ids.add(projectTeam.Project_Manager__c);
		}
		setOfPm1AndPm2Ids.add(currentUserId); //MRS 7322
	}

    public Map<Id, Task> tasksForProjectManager {
        get {
            tasksForProjectManager = new Map<Id, Task>([Select WhatId,  ActivityDate, What.Name, Priority, Subject, Status, OwnerId, Id, Description, CreatedDate, CreatedBy.Name, CreatedById, ReminderDateTime
                                          From Task Where OwnerId IN :setOfPm1AndPm2Ids AND Status !=: ServiceItemServices.SERVICE_STATUS_COMPLETED Order by CreatedDate DESC
                                          limit 250]);
            return tasksForProjectManager ;
        }
        set;
    }

    public Map<Id, Task> tasksByProjectManager {
        get {
            tasksByProjectManager = new Map<Id, Task>([ Select WhatId,  ActivityDate, What.Name, Priority, Subject, Status, OwnerId, Owner.Name, Id, Description, CreatedDate, CreatedById, ReminderDateTime
                                          From Task Where CreatedById IN :setOfPm1AndPm2Ids AND Status !=: ServiceItemServices.SERVICE_STATUS_COMPLETED Order by CreatedDate DESC
                                          limit 250]);
            return tasksByProjectManager;
        }
        set;
    }

    public String arURL {
        get{
            Set<String> validProfiles = new Set<String>{ UserServices.PROFILE_ACCOUNT_MANAGER, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN };
            if ( !validProfiles.contains(currentProfile[0].Name) ) return null;

            Set<String> validProposalStatuses = new Set<String>{ ProposalServices.PROPOSAL_STATUS_NEW, ProposalServices.PROPOSAL_STATUS_IN_REVIEW, ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
                ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW, ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE, ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW,
                ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED, ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW,
                ProposalServices.PROPOSAL_STATUS_REJECTED, ProposalServices.PROPOSAL_STATUS_AWARDED };

            Set<String> validProjectStatuses =
              new Set<String>{ ProjectProfileServices.PROJECT_STATE_NOT_STARTED, ProjectProfileServices.PROJECT_STATE_IN_PROCESS,
                                ProjectProfileServices.PROJECT_STATE_COMPLETE, ProjectProfileServices.PROJECT_STATE_CLOSED };

            MilroseSetting__c milroseSetting = MilroseSetting__c.getInstance('ARReportID');
            arURL = '/'+ milroseSetting.Report_ID__c + '?isdtp=nv&pv3=' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '&pv4=';

            Set<String> filterAccountIds = new Set<String>();
            for( Proposal__c item: [Select Id, Billing_Company_Name__c
                                    From Proposal__c
                                    Where Account_Executive__c =: currentUserId
                                    AND Status__c IN: validProposalStatuses
                                    AND Billing_Company_Name__c != null]){
system.debug('@item1='+item);
                filterAccountIds.add( item.Billing_Company_Name__c );
            }

            for( Project_Profile__c item: [Select Id, Billing_Company_Name__c
                                            From Project_Profile__c
                                            Where Account_Executive__c =: currentUserId
                                                AND Project_State__c IN: validProjectStatuses
                                                AND Billing_Company_Name__c != null
                                                AND Billing_Company_Name__c NOT IN: filterAccountIds]){
system.debug('@item2='+item);
                filterAccountIds.add( item.Billing_Company_Name__c );

            }

            //MRS-6868
            for( Project_Profile__c item: [Select Id, Billing_Company_Name__c,
                                                    (Select Id, Active__c
                                                     From Project_Rosters__r
                                                     Where User__c != null And Active__c = true And
                                                            ( Role__c = 'Account Manager' or Role__c = 'Manager of Accounts' ) And
                                                            User__c =: currentUserId Limit 1)
                                           From Project_Profile__c
                                           Where Project_State__c IN: validProjectStatuses
                                               AND Billing_Company_Name__c != null
                                               AND Billing_Company_Name__c NOT IN: filterAccountIds]){

                if ( !item.Project_Rosters__r.isEmpty() ){
                    filterAccountIds.add( item.Billing_Company_Name__c );
                }
            }

            // filter Accounts by Sum of c2g__codaTransactionLineItem__c not euqals 0

            List<AggregateResult> agResults = [Select c2g__Account__c accId, SUM(c2g__HomeOutstandingValue__c) grandTotal
                                                From c2g__codaTransactionLineItem__c
                                                Where c2g__HomeOutstandingValue__c != null
                                                And c2g__HomeOutstandingValue__c != 0
                                                And c2g__Account__c IN : filterAccountIds
                                                AND c2g__MatchingStatus__c != 'Matched'
                                                AND c2g__GeneralLedgerAccount__r.Name like '12100%'
                                                AND c2g__LineType__c = 'Account'
                                                Group By c2g__Account__c];

            List<String> accountIds = new List<String>();

            for (AggregateResult ar : agResults) {
                String accId = String.valueOf(ar.get('accId')).subString(0,15);
                Decimal grandTotal = (Decimal) ar.get('grandTotal');

                if (grandTotal != 0){
                   accountIds.add(accId);
                }
            }

            arURL += String.join(accountIds, ',');

            //resize arUrl to 2000 chars which is max url length for most browsers
            if (arURL.length() > MAX_URL_LENGTH) {
                arURL = arURL.subString(0, MAX_URL_LENGTH);
                arURL = arURL.subString(0, arURL.lastIndexOf(','));
            }
		system.debug('@arURL='+arURL);
            return arURL;
        }

        set;
    }

    public String userWorkloadURL {
        get{
            if( userWorkloadURL == null ){
                String roles = '';
                Boolean first = true;
                for ( UserRole item: reportToCurrentRole ) {
                    if (!first) {
                        roles += ',';
                    }
                    roles += item.Name;
                    first = false;
                }
                MilroseSetting__c milroseSetting = MilroseSetting__c.getInstance('UserWorkloadReportID');
                userWorkloadURL = '/' + milroseSetting.Report_ID__c + '?isdtp=nv&pv0=' + ( roles != '' ? roles : 'NONE' );
            }
            return userWorkloadURL;
        }
        set;
    }

    private Set<String> getProcessingStatuses( String userProfile ) {
        Set<String> statuses;
        if( userProfile == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
            userProfile == UserServices.PROFILE_ACCOUNT_MANAGER ||
            userProfile.contains(UserServices.PROFILE_PARTNER) ){
            statuses = new Set<String>{ ChangeOrderServices.STATUS_IN_CZ_REVIEW,
                                        ChangeOrderServices.STATUS_IN_INT_REVIEW,
                                        ChangeOrderServices.STATUS_APPROVED,
                                        ChangeOrderServices.STATUS_REJECTED,
                                        ChangeOrderServices.STATUS_REQUESTED,
                                        ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE,
                                        ChangeOrderServices.STATUS_PASSED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_FAILED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PENDING_CLIENT };

        } else if( userProfile.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ||
                   userProfile.contains(UserServices.PROFILE_SIPS_COORDINATOR) ){
            statuses = new Set<String>{ ChangeOrderServices.STATUS_IN_INT_REVIEW };

        } else if( userProfile == UserServices.PROFILE_CODE_ZONING_ANALYST ){ // MRS 7019
            statuses = new Set<String>{ ChangeOrderServices.STATUS_DRAFT,
                                        ChangeOrderServices.STATUS_REQUESTED,
                                        ChangeOrderServices.STATUS_IN_CZ_REVIEW,
                                        ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE,
                                        ChangeOrderServices.STATUS_IN_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PASSED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_FAILED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PENDING_CLIENT,
                                        ChangeOrderServices.STATUS_REJECTED
                                      };

        } else if( userProfile == UserServices.PROFILE_PRODUCTION_MANAGER ||
                   userProfile == UserServices.PROFILE_CLIENT_SERVICE_MANAGER ){ //MRS-6952
            statuses = new Set<String>{ ChangeOrderServices.STATUS_REQUESTED,
                                        ChangeOrderServices.STATUS_IN_CZ_REVIEW,
                                        ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE,
                                        ChangeOrderServices.STATUS_IN_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PASSED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_FAILED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PENDING_CLIENT,
                                        ChangeOrderServices.STATUS_APPROVED,
                                        ChangeOrderServices.STATUS_REJECTED };

        } else {
            statuses = new Set<String>{ ChangeOrderServices.STATUS_DRAFT,
                                        ChangeOrderServices.STATUS_REQUESTED,
                                        ChangeOrderServices.STATUS_IN_CZ_REVIEW,
                                        ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE,
                                        ChangeOrderServices.STATUS_IN_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PASSED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_FAILED_INT_REVIEW,
                                        ChangeOrderServices.STATUS_PENDING_CLIENT,
                                        ChangeOrderServices.STATUS_APPROVED,
                                        ChangeOrderServices.STATUS_REJECTED };
        }
        return statuses;
     }

}