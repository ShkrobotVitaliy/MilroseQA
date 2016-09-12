@isTest
private class TestCloseProjectController {
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final String TEST_PROJECT_CLOSURE_REASON_VALUE = 'test project closure reasone';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPage;
    private static CloseProjectController testController;
    private static ApexPages.StandardController testStandardController;

    private static void setupData(){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void createProjectProfile(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = new List<Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                            testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            testProjectProfileList.add(projectProfileItem);
        }

        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
        if(doInsert){
            insert testProjectProfileList;
        }
    }

    private static void preparePageController (Project_Profile__c projectProfileForStandardController){
        testPage = Page.CloseProject;
        Test.setCurrentPage(testPage);
        if (projectProfileForStandardController != null) {
            testStandardController = new ApexPages.standardController(projectProfileForStandardController);
            testController = new CloseProjectController(testStandardController);
        }
    }

    private static testmethod void testInitControllerWithProjectStateNotClosed(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        Test.startTest();

            preparePageController(testProjectProfileList[0]);

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assert (msgList.isEmpty());

        System.assertEquals(testProjectProfileList[0].Id, testController.currentProject.Id);
//        System.assert(testController.isValid);
    }

    private static testmethod void testInitControllerWithProjectStateClosed(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_CLOSED;
        }
        update testProjectProfileList;

        Test.startTest();

            preparePageController(testProjectProfileList[0]);

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
//        System.assertEquals (CloseProjectController.PROJECT_PROFILE_IS_CLOSED, msgList[0].getDetail());

        System.assertEquals(testProjectProfileList[0].Id, testController.currentProject.Id);
        System.assert(!testController.isValid);
    }

    /*private static testmethod void testInitControllerWithInvalidProjectRole(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_CLOSED;
        }
        insert testProjectProfileList;

        List<User> invalidUserList = [SELECT Id
                                      FROM User
                                      WHERE IsActive = true AND
                                            Profile.Name != : UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN AND
                                            Profile.Name != : UserServices.PROFILE_OPERATIONS_MANAGER AND
                                            Profile.Name != : UserServices.PROFILE_SHARED_SERVICES_MANAGER AND
                                            Profile.Name != : UserServices.PROFILE_PROJECT_MANAGER_2 AND
                                            Profile.Name != : UserServices.PROFILE_PROJECT_MANAGER_1 AND
                                            Profile.Name != : UserServices.PROFILE_PRODUCTION_MANAGER
                                            LIMIT 1];

        System.assert(!invalidUserList.isEmpty(), 'Invalid user list for this test method is empty');

        Test.startTest();

            System.runAs(invalidUserList[0]){
                preparePageController(testProjectProfileList[0]);
            }

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assert (msgList[0].getDetail().contains(CloseProjectController.INVALID_PROJECT_ROLE));

        System.assertEquals(testProjectProfileList[0].Id, testController.currentProject.Id);
        System.assert(!testController.isValid);
    }*/

    private static testmethod void testInitControllerWithIncorrectData(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        Id incorrectProjectProfileId = Id.valueOf(Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        Project_Profile__c incorrecrProjectProfile = new Project_Profile__c(Id = incorrectProjectProfileId);

        Test.startTest();

            preparePageController(incorrecrProjectProfile);

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
    }

    private static testmethod void testCloseProjectAction(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assert (msgList.isEmpty());

        Test.startTest();

            System.assert(!testController.closeProjectAction);

        Test.stopTest();
    }

    private static testmethod void testAddProjectClosingReasonAction(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        testController.currentProject.Project_Closure_Reason__c = TEST_PROJECT_CLOSURE_REASON_VALUE;

        Test.startTest();

            testController.addProjectClosingReasonAction();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
//        System.assert (msgList.isEmpty());

        List<Project_Profile__c> resultProjectProfileList = [SELECT Id, Project_Closure_Reason__c, Project_State__c
                                                             FROM Project_Profile__c
                                                             WHERE Id = : testProjectProfileList[0].Id];

        System.assert(!resultProjectProfileList.isEmpty());
        System.assertEquals(TEST_PROJECT_CLOSURE_REASON_VALUE, resultProjectProfileList[0].Project_Closure_Reason__c);
        System.assertEquals(ProjectProfileServices.PROJECT_STATE_CLOSED, resultProjectProfileList[0].Project_State__c);
    }

    private static testmethod void testAddProjectClosingReasonActionWithEmptyReason(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        Test.startTest();

            testController.addProjectClosingReasonAction();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
//        System.assert (msgList[0].getDetail().contains('Project Closure Reason is required'));

        List<Project_Profile__c> resultProjectProfileList = [SELECT Id, Project_Closure_Reason__c, Project_State__c
                                                             FROM Project_Profile__c
                                                             WHERE Id = : testProjectProfileList[0].Id];

        System.assert(!resultProjectProfileList.isEmpty());
        System.assert(resultProjectProfileList[0].Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED);
    }

    private static testmethod void testAddProjectClosingReasonActionWithIncorrectData(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        Id incorrectProjectProfileId = Id.valueOf(Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        testController.currentProject.Id = incorrectProjectProfileId;
        testController.currentProject.Project_Closure_Reason__c = TEST_PROJECT_CLOSURE_REASON_VALUE;

        Test.startTest();

            testController.addProjectClosingReasonAction();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());

        List<Project_Profile__c> resultProjectProfileList = [SELECT Id, Project_Closure_Reason__c, Project_State__c
                                                             FROM Project_Profile__c
                                                             WHERE Id = : testProjectProfileList[0].Id];

        System.assert(!resultProjectProfileList.isEmpty());
        System.assert(resultProjectProfileList[0].Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED);
    }

    private static testmethod void testCancelAction(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.cancelAction();

        Test.stopTest();

        System.assert(resultPageReference != null);
    }

    private static testmethod void testShowDialogCloseProject(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        Test.startTest();

            testController.showDialogCloseProject();

        Test.stopTest();

        System.assert(testController.closeProjectAction);
    }

    private static testmethod void testCancelCloseProject(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        insert testProjectProfileList;

        preparePageController(testProjectProfileList[0]);

        Test.startTest();

            testController.cancelCloseProject();

        Test.stopTest();

        System.assert(!testController.closeProjectAction);
    }
}