public with sharing class UserServices {
    public static final String PROFILE_FREP = 'FREP';
    public static final String PROFILE_PARTNER = 'Partner';
    public static final String PROFILE_FINANCE_MANAGER = 'Finance Management';
    public static final String PROFILE_CFO = 'CFO';
    public static final String PROFILE_COO = 'COO';
    public static final String PROFILE_A_R_CORDINATOR = 'A/R Coordinator';
    public static final String PROFILE_BILLING_COORDINATOR = 'Billing Coordinator';
    public static final String PROFILE_PROJECT_MANAGER = 'Project Manager';
    public static final String PROFILE_PROJECT_MANAGER_2 = 'Project Manager 2';
    public static final String PROFILE_PROJECT_MANAGER_1 = 'Project Manager 1';

    public static final String PROFILE_PLATFORM_SYSTEM_ADMIN = 'Platform System Admin';
    public static final String PROFILE_PROPOSAL_SPECIALIST = 'Proposal Specialist';
    public static final String PROFILE_STAFF_ACCOUNTANT = 'Staff Accountant';
    public static final String PROFILE_CODE_ZONING_ANALYST = 'Code & Zoning Team';
    public static final String PROFILE_OPERATIONS_MANAGER = 'Operations Manager';
    public static final String PROFILE_SHARED_SERVICES_MANAGER = 'Shared Services Manager';
    public static final String PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER = 'Shared Services Department Manager';
    public static final String PROFILE_SIPS_DEPARTMENT_MANAGER = 'SIPS Department Manager';
    public static final String PROFILE_SIPS_COORDINATOR = 'SIPS Coordinator';
    public static final String PROFILE_ACCOUNT_MANAGER = 'Account Manager';
    public static final String PROFILE_PRODUCTION_MANAGER = 'Production Manager';
    public static final String PROFILE_CLIENT_SERVICE_MANAGER = 'Client Service Manager';//MRS-6952
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';
    public static final String PROFILE_ACCOUNTING_SUPERVISOR = 'Accounting Supervisor';
    public static final String SUPPORT_STAFF = 'Support Staff';
    public static final String HUMAN_RESOURCES = 'Human Resources';
    public static final String SHARED_SERVICES_COORDINATOR_PROFILE_NAME = 'Shared Services Coordinator';
    public static final String EXECUTIVE_ADMIN_PROFILE_NAME = 'Executive Admins';
    public static final String PROFILE_DIRECTOR_OF_OPERATIONS = 'Director of Operations';//MRS-6507

    public static final String ROLE_EXECUTIVE_ADMIN_1 = 'Executive Admin 1';
    public static final String ROLE_EXECUTIVE_ADMIN_2 = 'Executive Admin 2';
    public static final String ROLE_EXECUTIVE_ADMIN_3 = 'Executive Admin 3';
    public static final String DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_1  = 'Louis Milo';
    public static final String DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_2  = 'Domenick Chieco';
    public static final String DEFAULT_PARTNER_FOR_ROLE_EXECUTIVE_ADMIN_3  = 'Greg Tabone';

    public static final String ROLE_PROPOSAL_SPECIALIST = 'Proposal Specialist';
    public static final String ROLE_SHARED_SERVICES_MANAGER = 'Shared Services Manager';
    public static final String ROLE_MANAGER_OF_ACCOUNTS = 'Manager of Accounts';
	public static final String ROLE_ACCOUNT_MANAGER = 'Account manager'; //MRS 7592
    public static final String ROLE_OPERATIONS_MANAGER = 'Operations Manager'; //plus region division on the front
    public static final String ROLE_DOT_DEPARTMENT_MANAGER = 'DOT Department Manager';
    public static final String ROLE_PLUMBING_DIVISION_DEPARTMENT_MANAGER = 'Plumbing Division Department Manager';
    public static final String ROLE_AHV_DEPARTMENT_MANAGER = 'AHV Department Manager';
    public static final String ROLE_AHV_DEPARTMENT_COORDINATOR = 'AHV Department Coordinator';
    public static final String ROLE_SIPS_DEPARTMENT_MANAGER = 'SIPS Department Manager';
    public static final String ROLE_SIPS_DEPARTMENT_COORDINATOR = 'SIPS Department Coordinator';
    public static final String ROLE_C_OF_O_DEPARTMENT_MANAGER = 'C of O Department Manager';
    public static final String ROLE_C_OF_O_DEPARTMENT_COORDINATOR = 'C of O Department Coordinator';
    public static final String ROLE_FDNY_DEPARTMENT_MANAGER = 'FDNY Department Manager';
    public static final String ROLE_FDNY_DEPARTMENT_REVIEWER = 'FDNY Department Reviewer';
    public static final String ROLE_FDNY_DEPARTMENT_COORDINATOR = 'FDNY Department Coordinator'; //MRS 6889
    public static final String ROLE_VIOLATIONS_DEPARTMENT_MANAGER = 'Violations Department Manager';
    public static final String ROLE_VIOLATIONS_DEPARTMENT_COORDINATOR = 'Violations Department Coordinator';
    public static final String ROLE_ADMINISTRATION_DEPARTMENT_MANAGER = 'Administration Department Manager';
    public static final String ROLE_ADMINISTRATION_DEPARTMENT_COORDINATOR = 'Administration Department Coordinator';
    public static final String ROLE_CZ_MANAGER = 'Code & Zoning Department Manager'; //plus region division on the front
    public static final String ROLE_CODE_ZONING_ANALYST = 'Code & Zoning Analyst';
    public static final String ROLE_CODE_ZONING_DEPARTMENT_REVIEWER = 'Code & Zoning Department Reviewer';
    public static final String ROLE_LI_CZ_MANAGER = 'LI ' + ROLE_CZ_MANAGER;
    public static final String ROLE_DIRECTOR_OF_OPERATIONS = 'Director of Operations';//MRS-6507

    public static final String ROLE_DEV_NAME_C_OF_O_DEPARTMENT_MANAGER = 'C_of_O_Department_Manager';

    public static final String PROFILE_FREP_QA = 'FREP (QA)';
    public static final String PROFILE_PARTNER_QA = 'Partner (QA)';
    public static final String PROFILE_PROPOSAL_SPECIALIST_QA = 'Proposal Specialist (QA)';
    public static final String PROFILE_PROJECT_MANAGER_2_QA = 'Project Manager 2 (QA)';
    public static final String PROFILE_PROJECT_MANAGER_1_QA = 'Project Manager 1 (QA)';
    public static final String PROFILE_PRODUCTION_MANAGER_QA = 'Production Manager (QA)';
    public static final String PROFILE_CODE_ZONING_ANALYST_QA = 'Code & Zoning Team (QA)';
    public static final String PROFILE_STAFF_ACCOUNTANT_QA = 'Staff Accountant (QA)';
    public static final String PROFILE_FINANCE_MANAGER_QA = 'Finance Management (QA)';
    public static final String PROFILE_A_R_CORDINATOR_QA = 'A/R Coordinator (QA)';
    public static final String PROFILE_ACCOUNT_MANAGER_QA = 'Account Manager (QA)';
    public static final String PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER_QA = 'Shared Services Department Manager (QA)';
    public static final String PROFILE_SIPS_DEPARTMENT_MANAGER_QA = 'SIPS Department Manager (QA)';
    public static final String PROFILE_SIPS_COORDINATOR_QA = 'SIPS Coordinator (QA)';
    public static final String PROFILE_OPERATIONS_MANAGER_QA = 'Operations Manager (QA)';
    public static final String PROFILE_SHARED_SERVICES_MANAGER_QA = 'Shared Services Manager (QA)';

     //MRS-7268
    public static Map<Id, Boolean> idsOfInactiveUsersMap;
    public static void getIdsOfInactiveUsersMap(){
        if ( idsOfInactiveUsersMap == null ){
          idsOfInactiveUsersMap = new Map<Id, Boolean>();
            for( User item: [ SELECT Id FROM User WHERE isActive = false] ){
              idsOfInactiveUsersMap.put(item.Id,true);
            }

        }

    }
    
    //MRS 6043
    public static Map<String, Id> userIdToUserName;
    public static Id getUserIdByUserName( String userName ) {
        if( userIdToUserName == null ) {
            userIdToUserName = new Map<String, Id> ();
            List<User> users = [SELECT Name FROM User];
            if( users != null ) {
                for( User u : users ) {
                    userIdToUserName.put(u.Name, u.Id);    
                }
            }
        }
        return userIdToUserName.get( userName );
    }

    public static Map<String, Id> userRoleNameToUserId; // KDI 11/12/13
    public static void prepareUserRoleNameToUserId() { // KDI 11/12/13
        if( userRoleNameToUserId == null ) {
            userRoleNameToUserId = new Map<String, Id>();
            List<UserRole> userRoles = new List<UserRole>();
            userRoles = [SELECT Name, DeveloperName,
                                            ( Select Id From Users WHERE isActive = true LIMIT 1 )
                                        FROM UserRole
                                        Where NOT Name IN: ProjectTeamServices.PROJECT_TEAM_USERS ];

            for( UserRole roleItem : userRoles ) {
                for( User userItem : roleItem.Users ) {
                    userRoleNameToUserId.put( roleItem.Name, userItem.Id );
                }
            }
        }
    }

    public static Map<String, Id> getUserRoleNameToUserId(){
        if (userRoleNameToUserId == null){
            prepareUserRoleNameToUserId();
        }
        return userRoleNameToUserId;
    }

    public static User currentUserWithRoleProfile{
        get {
            if ( currentUserWithRoleProfile == null ){
                currentUserWithRoleProfile = [ SELECT Id, Profile.Name, ProfileId, UserRoleId, UserRole.Name
                                               FROM User
                                               WHERE Id = : userinfo.getuserid()];
           }
           return currentUserWithRoleProfile;
        }
        set {}
    }

    public static Map<Id, String> userIdToRoleName;
    public static void prepareUserIdToUserRoleName() {
        if( userIdToRoleName == null ) {
            userIdToRoleName = new Map<Id, String>();
            List<UserRole> userRoles = new List<UserRole>();
            userRoles = [SELECT Name, DeveloperName,
                                            ( Select Id From Users WHERE isActive = true )
                                        FROM UserRole
                                        Where NOT Name IN: ProjectTeamServices.PROJECT_TEAM_USERS ];

            for( UserRole roleItem : userRoles ) {
                for( User userItem : roleItem.Users ) {
                    userIdToRoleName.put( userItem.Id, roleItem.Name );
                }
            }
        }
    }

    public static Map<Id, String> getUserIdToRoleName(){
        if (userIdToRoleName == null){
            prepareUserIdToUserRoleName();
        }
        return userIdToRoleName;
    }

    public static Id getOwnerIdForAllOSProjectProfile( Proposal__c proposal ) { // KDI 11/12/13
        Set<String> ssDepartmentUsersRoles = new Set<String>{ ROLE_VIOLATIONS_DEPARTMENT_MANAGER, ROLE_C_OF_O_DEPARTMENT_MANAGER,
                                                            ROLE_DOT_DEPARTMENT_MANAGER, ROLE_PLUMBING_DIVISION_DEPARTMENT_MANAGER,
                                                            ROLE_AHV_DEPARTMENT_MANAGER, ROLE_FDNY_DEPARTMENT_MANAGER,
                                                            PROFILE_SHARED_SERVICES_MANAGER, ROLE_SIPS_DEPARTMENT_MANAGER,
                                                            ROLE_ADMINISTRATION_DEPARTMENT_MANAGER };
        Boolean isOMManagerOwner = false;
        Boolean isAMManagerOwner = false;
        Boolean isCZManagerOwner = false;
        Id idOfProjectOwner;
        if( userRoleNameToUserId == null ) return null;
        if( ProposalServices.proposalIdToServiceItems.get( proposal.Id ) != null ) {
            for( Service_Item__c si : ProposalServices.proposalIdToServiceItems.get( proposal.Id ) ) {
                if( !String.isBlank( si.Service_Template__r.Role_Assignment__c ) &&
                        userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c ) ) {

                    if( ssDepartmentUsersRoles.contains(si.Service_Template__r.Role_Assignment__c)) {
                        return userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                    }

                    if( si.Service_Template__r.Role_Assignment__c.contains( ROLE_CZ_MANAGER ) &&
                            isCZManagerOwner == false ){

                        isCZManagerOwner = true;
                        idOfProjectOwner = userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                    }

                    if( si.Service_Template__r.Role_Assignment__c.contains( ROLE_MANAGER_OF_ACCOUNTS ) &&
                            isCZManagerOwner == false &&
                            isAMManagerOwner == false ){

                        isAMManagerOwner = true;
                        if( proposal.Account_Executive__c != null ){
                            idOfProjectOwner = proposal.Account_Executive__c;
                        }else{
                            idOfProjectOwner = userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                        }
                    }

                    if ( idOfProjectOwner == null ) idOfProjectOwner = userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );

                 } else {
                    for( String item: userRoleNameToUserId.keySet() ){
                        if( item.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) &&
                                isCZManagerOwner == false &&
                                isAMManagerOwner == false &&
                                isOMManagerOwner == false &&
                                idOfProjectOwner == null){

                            idOfProjectOwner = userRoleNameToUserId.get( item );
                            isOMManagerOwner = true;
                            break;
                        }
                    }
                }
            }
        }
        return idOfProjectOwner;
    }

    public static User getUserById(Id userId) {
        User user = new User();
        if(userId != null) {
            user = [ SELECT Id, ContactId, Name, Alias, Email, Service_Type_User__c, Office__c, Title, Phone, IsActive,
                            Extension, CompanyName, Street, State, PostalCode, Office_Number__c, Longitude, Latitude, Country, City
                     FROM User WHERE Id = : userId ];
        }
        return user;
    }

    public static Boolean isAddDocument( String role, Id prjectUserId ) {
        Boolean isShow = false;
        Profile ProfileName = getProfile();
        if(ProfileName.Name == PROFILE_PLATFORM_SYSTEM_ADMIN) return true;
        if(ProfileName.Name.contains( role ) ) {
            if(prjectUserId == userinfo.getUserId()) {
                isShow = true;
            }
        }
        return isShow;
    }

    @TestVisible private static Profile currentUserProfile;

    public static Profile getProfile() {
        if ( currentUserProfile == null ) {
            currentUserProfile = [select Id, Name from Profile where id = : userinfo.getProfileId()];
        }
        return currentUserProfile;
    }

    public static UserRole getCurrentUserRole() {
        List<UserRole> userRoles = new List<UserRole>([SELECT Id, Name FROM UserRole WHERE Id =: UserInfo.getUserRoleId()]);
        return userRoles.isEmpty() ? null : userRoles[0];
    }

    public static Set<Id> getUserIdsByRole( String roleDeveloperName ) {
        Set<Id> userIds = new Set<Id>();
        if( roleDeveloperName != null ) {
            for( UserRole userRoleItem : [ SELECT Id, (SELECT Id FROM Users WHERE IsActive = true) FROM UserRole WHERE DeveloperName Like : '%' + RoleDeveloperName + '%'] ){
                for( User userItem : userRoleItem.Users ) {
                    userIds.add( userItem.Id );
                }
            }
        }
        return userIds;
    }

    public static Map<Id, User> getUsersMapByRole( String roleDeveloperName ) {
        Map<Id, User> usersByRoleMap = new Map<Id, User>();
        if( roleDeveloperName != null ) {
            for( UserRole userRoleItem : [ SELECT Id, (SELECT Id, Email FROM Users WHERE IsActive = true) FROM UserRole WHERE Name Like : '%' + RoleDeveloperName + '%'] ){
                for( User userItem : userRoleItem.Users ) {
                    usersByRoleMap.put( userItem.Id, userItem );
                }
            }
        }
        return usersByRoleMap;
    }

    public static Map<Id, User> getUsersMapByRoleAndRegion( String roleName, String regionName ) {
        Map<Id, User> usersByRoleMap = new Map<Id, User>();
        if( roleName != null && regionName != null ) {
            for( UserRole userRoleItem : [ SELECT Id, (SELECT Id, Email FROM Users WHERE IsActive = true) FROM UserRole WHERE Name Like : '%' + roleName + '%' AND Name Like: '%' + regionName + '%']){
                for( User userItem : userRoleItem.Users ) {
                    usersByRoleMap.put( userItem.Id, userItem );
                }
            }
        }
        return usersByRoleMap;
    }

    public static Boolean isProjectManagerAssignedToProject( Id userId, String userProfileName, Id projectManager2, Id projectManager1 ) {
        return userProfileName.contains( PROFILE_PROJECT_MANAGER ) && ( userId == projectManager2 || userId == projectManager1 );
    }

    public static Boolean isProductionManagerAssignedToProject( Id userId, String userProfileName, Id prodManager ) {
        return userProfileName.contains( PROFILE_PRODUCTION_MANAGER ) && ( userId == prodManager ) ;
    }

    public static Set<Id> getUserIdsByProfileName( String profileName ) {
        Set<Id> userIds = new Set<Id>();
        List<Profile> profiles = [ SELECT Id, (SELECT Id FROM Users WHERE IsActive = true) FROM Profile WHERE Name = : profileName ];
        for( Profile profile : profiles ) {
            for( User user : profile.Users ) {
                userIds.add( User.Id );
            }
        }
        return userIds;
    }

    public static Boolean isValidUserForProject( Id userId, Project_Profile__c projectWithAssignments, Id ownerId, Id managerId, Boolean isProjectLevel, Boolean isFinanceOperation ){
        String userProfile = getProfile().Name;
        UserRole userRoleRecord = UserServices.getCurrentUserRole();
        String userRole = ( userRoleRecord != null ? userRoleRecord.Name : null );

        if( userProfile.equals( PROFILE_PLATFORM_SYSTEM_ADMIN ) || userProfile.contains( SUPPORT_STAFF ) ) return true;

        Boolean isProjectLevelAccess = ( userId == projectWithAssignments.Project_Member__c         ||      // Project Manager 1
                                         userId == projectWithAssignments.Project_Manager__c        ||      // Project Manager 2
                                         userId == projectWithAssignments.Production_Manager__c     ||      // Production Manager
                                         userId == projectWithAssignments.FREP__c                   ||      // Filing Rep
                                         userId == projectWithAssignments.OwnerId                   ||      // Project Owner

                                         ( isFinanceOperation &&
                                           ( userProfile.contains( PROFILE_FINANCE_MANAGER ) ||
                                             userProfile.contains( PROFILE_ACCOUNTING_SUPERVISOR ) || //MRS-6467
                                             userProfile.contains( PROFILE_CFO ) ||
                                             userProfile.contains( PROFILE_A_R_CORDINATOR )  ||
                                             userProfile.contains( PROFILE_STAFF_ACCOUNTANT ) ) ) ||

                                         userProfile.contains( PROFILE_SHARED_SERVICES_MANAGER ) ||
                                         userProfile.contains( PROFILE_DIRECTOR_OF_OPERATIONS ) || //MRS-6507

                                         ( userProfile.contains( PROFILE_OPERATIONS_MANAGER ) &&
                                           userRole != null )
                                       );

        Boolean isServiceOrTaskLevelAccess = false;
        if( !isProjectLevel ){
            isServiceOrTaskLevelAccess = ( userId == managerId || userId == ownerId);
        }

        return isProjectLevelAccess || isServiceOrTaskLevelAccess;
    }

    public static Boolean isValidUserForProjectCheckServiceORTaskOwners( Id userId, Project_Profile__c projectWithAssignments ){
        if ( userId == null || projectWithAssignments == null ) return false;
        for( Service_Item__c item: [Select OwnerId, Manager_Lookup__c, (Select OwnerId, Manager_Lookup__c From Task_Items__r) From Service_Item__c Where Project_Profile__c =: projectWithAssignments.Id] ){
            if( userId == item.OwnerId ) return true;
            if( userId == item.Manager_Lookup__c ) return true;
            for( Task_Item__c item1: item.Task_Items__r){
                if( userId == item1.OwnerId ) return true;
                if( userId == item1.Manager_Lookup__c ) return true;
            }
        }

        return false;
    }

    public static void updateDeliveryOptionsForUsers( List<User> userListNew, Map<Id, User> userMapOld ) {
        List<User> filteredUserList = new List<User>();

        for( User userItem : userListNew ) {
            if( ( userMapOld == null && userItem.IsActive ) ||
                ( userMapOld != null && userItem.IsActive != userMapOld.get(userItem.Id).IsActive ) ){
                filteredUserList.add( userItem );
            }
        }
        if( !filteredUserList.isEmpty() ) {
            updateDeliveryOptionsForUsers();
        }
    }

    @future
    public static void updateDeliveryOptionsForUsers() {
        Integer minimumFreeTemplatesAmount = 9; //free will be used for template carousel

        Set<Id> allActiveUserIds = ( new Map<Id, User>( [ SELECT Id FROM User WHERE IsActive = true ORDER BY Id ] ) ).keySet();
        Set<Id> alreadyAssignedUserIds = new Set<Id>();
        Set<Id> notAssignedUserIds = new Set<Id>( allActiveUserIds );

        List<Loop__DDP_Integration_Option__c> existingDeliveryOptions = [ SELECT Send_Email_User__c
                                                                          FROM Loop__DDP_Integration_Option__c
                                                                          WHERE Loop__DDP__r.Name = : DDPEmailServices.DDP_NAME_SEND_LETTER
                                                                            AND Recordtype.Name = : DDPEmailServices.DELIVERY_METHOD_EMAIL
                                                                            AND Loop__Template__c != null
                                                                          ORDER BY Loop__Order__c NULLS LAST ];
        Map<Id, Loop__DDP_Integration_Option__c> freeDeliveryOptions = new Map<Id, Loop__DDP_Integration_Option__c>();
        Map<Id, Loop__DDP_Integration_Option__c> deliveryOptionsToUpdate = new Map<Id, Loop__DDP_Integration_Option__c>();

        for( Loop__DDP_Integration_Option__c deliveryOption : existingDeliveryOptions ) {
            if( allActiveUserIds.contains( deliveryOption.Send_Email_User__c ) && !alreadyAssignedUserIds.contains( deliveryOption.Send_Email_User__c ) ) {
                alreadyAssignedUserIds.add( deliveryOption.Send_Email_User__c );
                notAssignedUserIds.remove( deliveryOption.Send_Email_User__c );
            } else {
                if( deliveryOption.Send_Email_User__c != null ) {
                    deliveryOption.Send_Email_User__c = null;
                    deliveryOptionsToUpdate.put( deliveryOption.Id, deliveryOption );
                }
                freeDeliveryOptions.put( deliveryOption.Id, deliveryOption );
            }
        }

        for( Id notAssignedUserId : notAssignedUserIds ) {
            if( freeDeliveryOptions.size() > minimumFreeTemplatesAmount ) {
                Loop__DDP_Integration_Option__c freeDeliveryOption = freeDeliveryOptions.values().get(0);
                freeDeliveryOption.Send_Email_User__c = notAssignedUserId;
                freeDeliveryOptions.remove( freeDeliveryOption.Id );
                deliveryOptionsToUpdate.put( freeDeliveryOption.Id, freeDeliveryOption );
            }
        }

        if( !deliveryOptionsToUpdate.isEmpty() ) {
            UPDATE deliveryOptionsToUpdate.values();
        }

        /*List<User> filteredUsers = [ SELECT IsActive FROM User WHERE Id IN : filteredUserIds ];

        List<Loop__DDP_Integration_Option__c> deliveryOptionList = [SELECT Id, Send_Email_User__c
                                                                    FROM Loop__DDP_Integration_Option__c
                                                                    WHERE Loop__DDP__r.Name = : DDPEmailServices.DDP_NAME_SEND_LETTER
                                                                    AND (Send_Email_User__c IN : filteredUserList Or Send_Email_User__c = null)
                                                                    AND Recordtype.Name = : DDPEmailServices.DELIVERY_METHOD_EMAIL
                                                                    AND Loop__Template__c != null ];

        Map<Id, Loop__DDP_Integration_Option__c> deliveryOptionUpdateMap = new Map<Id, Loop__DDP_Integration_Option__c>();
        Map<Id, Loop__DDP_Integration_Option__c> userWithDeliveryOptionMap = new Map<Id, Loop__DDP_Integration_Option__c>();
        Map<Id, Loop__DDP_Integration_Option__c> deliveryOptionWithoutUserMap = new Map<Id, Loop__DDP_Integration_Option__c>();

        for (Loop__DDP_Integration_Option__c doItem : deliveryOptionList){
            if ( doItem.Send_Email_User__c != null ){
                userWithDeliveryOptionMap.put(doItem.Send_Email_User__c, doItem);
            } else {
                deliveryOptionWithoutUserMap.put(doItem.id, doItem);
            }
        }

        for (User userItem : filteredUserList){
            if (!userItem.IsActive){
                Loop__DDP_Integration_Option__c doItem = userWithDeliveryOptionMap.get(userItem.Id);
                doItem.Send_Email_User__c = null;
                deliveryOptionUpdateMap.put(doItem.Id, doItem);
                deliveryOptionWithoutUserMap.put(doItem.Id, doItem);
            }
        }

        for (User userItem : filteredUserList){
            if ( deliveryOptionWithoutUserMap.size() >= minimumFreeTemplatesAmount ) {
                if (userItem.IsActive){
                    Loop__DDP_Integration_Option__c doItem = deliveryOptionWithoutUserMap.values()[0];
                    doItem.Send_Email_User__c = userItem.Id;
                    deliveryOptionUpdateMap.put(doItem.Id, doItem);
                    deliveryOptionWithoutUserMap.remove(doItem.Id);
                }
            }
        }

        try {
            if ( !deliveryOptionUpdateMap.isEmpty() ){
                update deliveryOptionUpdateMap.values();
            }
        } catch (Exception ex){}*/
    }

    //MRS-7483
    public static List<User> deactivatedUsersList( List<User> userListNew, Map<Id, User> userMapOld ){
        List<User> filteredUserList = new List<User>();

        for( User userItem : userListNew ) {
            if( !userItem.IsActive && userMapOld.get(userItem.Id).IsActive ){
                filteredUserList.add( userItem );
            }
        }

        return filteredUserList;
    }

    public static void sendHelperEmailAboutDeactivateUser(List<User> filteredUserList){
		if(!filteredUserList.isEmpty()) {
        	DeactivateUsersBatch cont = new DeactivateUsersBatch(new List<Id>{ UserInfo.getUserId() }, filteredUserList);
			Database.executeBatch(cont);
		}
    }
}