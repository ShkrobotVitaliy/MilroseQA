@isTest
private class TestSendLettersController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 1;


	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Task_Item__c> testTaskItemList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static PageReference testPage;
	private static SendLettersController testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROJECT_PROFILE);
		testProposalList = TestingUtils.testProposalList;
		testProjectProfileList = TestingUtils.testProjectProfileList;

		testServiceItemList = new List<Service_Item__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, projectProfileItem.Proposal__c, false)){
				serviceItemItem.Project_Profile__c = projectProfileItem.Id;
				testServiceItemList.add(serviceItemItem);
			}
		}
		insert testServiceItemList;

		testTaskItemList = new List<Task_Item__c>();
		for (Service_Item__c serviceItemItem : testServiceItemList){
			for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
				testTaskItemList.add(taskItemItem);
			}
		}
		insert testTaskItemList;
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController, Id recordId){
		testPage = Page.SendLetters;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			ApexPages.currentPage().getParameters().put('projectId', projectProfileForStandardController.Id);
			ApexPages.currentPage().getParameters().put('id', String.valueOf(recordId));
			testController = new SendLettersController();
		}
	}

	private static testmethod void testInitControllerForServiceItem(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(new Project_Profile__c(Id = testServiceItemList[0].Project_Profile__c), testServiceItemList[0].Id);
			System.assert(testController != null);

			//for test coverage
			Boolean testBoolean;
			testBoolean = testController.project == null;
			testBoolean = testController.allowToSendLetter == null;
			testBoolean = testController.autorun() == null;
			testBoolean = testController.close() == null;


		Test.stopTest();
	}

	private static testmethod void testInitControllerForTaskItem(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(new Project_Profile__c(Id = testTaskItemList[0].Project_Profile__c), testTaskItemList[0].Id);
			System.assert(testController != null);

		Test.stopTest();
	}
}