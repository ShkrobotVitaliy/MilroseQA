@isTest
private class TestProjectRenewableServicesController {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPage;
    private static ProjectRenewableServicesController testController;
    private static ApexPages.StandardController testStandardController;

    private static void setupData (){
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

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;
        }
        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static void prepareDataForTest(){
        testServiceItemList = new List<Service_Item__c>();
        List<Service_Item__c> serviceItemListForInsert = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            //Service Item List with Task Items
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Issuance__c = ServiceItemServices.SERVICE_ISSUANCE_RENEWAL;
                testServiceItemList.add(serviceItemItem);
                serviceItemListForInsert.add(serviceItemItem);
            }
            //Service Item List without Task Items
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Issuance__c = ServiceItemServices.SERVICE_ISSUANCE_RENEWAL;
                serviceItemListForInsert.add(serviceItemItem);
            }
        }
        insert serviceItemListForInsert;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
                taskItemItem.Name = TaskItemServices.PICKUP_ANALIZE_TASK_NAME;
                taskItemItem.Activation_Date__c = DateTime.now();
                taskItemItem.Expiration_Date__c = DateTime.now();
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;
    }

    private static void preparePageController (Project_Profile__c projectProfileForStandardController){
        testPage = Page.ProjectRenewableServices;
        Test.setCurrentPage(testPage);
        if (projectProfileForStandardController != null) {
            testStandardController = new ApexPages.standardController(projectProfileForStandardController);
            testController = new ProjectRenewableServicesController(testStandardController);
        }
    }

    private static testmethod void testInitConlrollerWithEmptyServiceList(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Test.startTest();

            preparePageController(testProjectProfileList[0]);

        Test.stopTest();

        System.assert(! ApexPages.hasMessages());
    }

    private static testmethod void testInitConlroller(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        Test.startTest();

            preparePageController(testProjectProfileList[0]);

        Test.stopTest();

        System.assert(! ApexPages.hasMessages());
    }
}