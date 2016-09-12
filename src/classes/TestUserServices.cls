@isTest
private class TestUserServices {
    private static User ProjectManagerUser;
    private static User partnerUser;
    private static Id currentUserId; 
    private static Project_Profile__c testProject;
    private static Set<Id>projectProfileIdSet;
    private static List<Service_Item__c> serviceItemList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static final Integer NUMBER_TO_CREATE = 3;
    private static List <Proposal__c> testProposalList;
    private static List <Account> testAccountList;
    private static List <Contact> testContactList;
    private static List <Region__c> testRegionList;
    private static List <Munucipalities__c> testMunucipalitiesList;
    private static List <Building__c> testBuildingList;
    
        
    private static void setUp(){ 
        ProjectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile('Partner');
        currentUserId = TestingUtils.createUsers(1, true)[0].Id;
        testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, null, null, null, null, null, null, null, true)[0];
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true);
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccountList[0].Id, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, 'TestStreet', 'TestHouse', 'TestCity', '012', true);
        
        
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, testProject.Id, testAccountList[0].Id, testContactList[0].Id,
                                                            testAccountList[0].Id, testContactList[0].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
        projectProfileIdSet = new Set<Id>();        
        serviceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false);
        for(Service_Item__c item : serviceItemList){
            item.Project_Profile__c=testProject.id;
            item.Proposal__c = testProposalList[0].Id;
            projectProfileIdSet.add(item.Project_Profile__c);
            
        }        
        insert serviceItemList;
    }

    @isTest(SeeAllData = false) static void testUncoveredParts(){
        setUp();
        Test.startTest();

        Id getUserIdByUserName = UserServices.getUserIdByUserName('Milrose Wave');

        Map<String, Id> getUserRoleNameToUserId = UserServices.getUserRoleNameToUserId();

        User u = UserServices.currentUserWithRoleProfile;

        Map<Id, String> getUserIdToRoleName = UserServices.getUserIdToRoleName();

        ProposalServices.proposalIdToServiceItems = new Map<Id, List<Service_Item__c>> { testProposalList[0].Id => serviceItemList };
        Id getOwnerIdForAllOSProjectProfile = UserServices.getOwnerIdForAllOSProjectProfile( testProposalList[0] );

        Set<Id> getUserIdsByRole = UserServices.getUserIdsByRole( UserServices.ROLE_PROPOSAL_SPECIALIST );

        Map<Id, User> getUsersMapByRole = UserServices.getUsersMapByRole( UserServices.ROLE_PROPOSAL_SPECIALIST );

        Map<Id, User> getUsersMapByRoleAndRegion = UserServices.getUsersMapByRoleAndRegion( UserServices.ROLE_PROPOSAL_SPECIALIST, '%');

        Boolean isProjectManagerAssignedToProject = UserServices.isProjectManagerAssignedToProject( ProjectManagerUser.Id,
                                                                                                    UserServices.PROFILE_PROJECT_MANAGER_2,
                                                                                                    ProjectManagerUser.Id, ProjectManagerUser.Id);
        Boolean isProductionManagerAssignedToProject = UserServices.isProductionManagerAssignedToProject( ProjectManagerUser.Id,
                                                                                                          UserServices.PROFILE_PROJECT_MANAGER_2,
                                                                                                          ProjectManagerUser.Id);
        Set<Id> getUserIdsByProfileName = UserServices.getUserIdsByProfileName( UserServices.PROFILE_PROJECT_MANAGER_2 );
        Boolean isValidUserForProject1 = UserServices.isValidUserForProject( currentUserId, testProject,
                                                                            currentUserId, currentUserId, true, true);
        Boolean isValidUserForProjectCheckServiceORTaskOwners = UserServices.isValidUserForProjectCheckServiceORTaskOwners( currentUserId, testProject);

        System.runAs( ProjectManagerUser ) {
            UserServices.currentUserProfile = new Profile( Name = UserServices.PROFILE_OPERATIONS_MANAGER + ' _TEST' );
            //testProject.OwnerId = currentUserId;
            Boolean isValidUserForProject2 = UserServices.isValidUserForProject( currentUserId, testProject,
                                                                                 currentUserId, currentUserId, true, true); 
        }



        Test.stopTest();
    }
    
    @isTest (seeAllData = false) private static void testGetOwnerIdForAllOSProjectProfileNull(){
        setUp();

        testServiceTemplateList = TestingUtils.createServiceTemplateList(1, false);
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList) {
            serviceTemplateItem.Role_Assignment__c = 'test';
        }
        insert testServiceTemplateList;

        for (Service_Item__c serviceItemItem : serviceItemList){
            serviceItemItem.Service_Template__c = testServiceTemplateList[0].Id;
        }
        update serviceItemList;

        ProposalServices.initVariablesForRoleAssignment(testProposalList);
        
        Test.startTest();
            Id testId = UserServices.getOwnerIdForAllOSProjectProfile(testProposalList[0]);
        Test.stopTest();
        
        //needs normal assert
        System.assertEquals(null, UserServices.getOwnerIdForAllOSProjectProfile(testProposalList[0]));  
        
    }
    
    @isTest(seeAllData = false) private static void testIsAddDocument_AdminRole(){
        String testRoleValue = 'test role';

        Test.startTest();
            Boolean testBoolean = UserServices.isAddDocument(testRoleValue, userinfo.getUserId());
        Test.stopTest();

        User curentUserWithRoleAndProfile = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Id = : userinfo.getUserId()];

        System.assertEquals( (curentUserWithRoleAndProfile.Profile.Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) || curentUserWithRoleAndProfile.UserRole.Name.contains(testRoleValue), testBoolean);
    

    }

    @isTest(seeAllData = false) private static void testIsAddDocument_SelectedRole(){
        setUp();
        System.runAs(ProjectManagerUser){
            Test.startTest();
                Boolean testBoolean = UserServices.isAddDocument(UserServices.PROFILE_PROJECT_MANAGER_2, ProjectManagerUser.Id);
            Test.stopTest();
            
            System.assertEquals(true, testBoolean);
        }
    }
    
    @isTest(seeAllData = false ) private static void testGetProfile(){
        Test.startTest();
            Profile testProfile = UserServices.getProfile();
        Test.stopTest();
        
        System.assertEquals(userinfo.getProfileId(), String.valueOf(testProfile.Id));
    }
    
    @isTest( seeAllData = false ) private static void testGetUserById(){    
        Id testUserId = TestingUtils.createUsers(NUMBER_TO_CREATE, true)[0].Id;
        
        Test.startTest();
            User testMethodUser = UserServices.getUserById(testUserId);
        Test.stopTest();
        
        
        System.assertEquals(testUserId, testMethodUser.Id);
        
    }
}