@isTest
private class TestPickupAnalyzeArtifactsFromAuthorityC {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM_FUNCTIONALITY = 1;

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
	private static List<Task_Item_Functionality__c> testTaskItemFunctionalityList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static PickupAnalyzeArtifactsFromAuthorityCon testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, false);
		for (Integer i = 0; i < testContactWithAccountList.size(); i++){
			testContactWithAccountList[i].Email = 'test' + String.valueOf(i) + 'test@gmail.com';
		}
		insert testContactWithAccountList;
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

		testTaskItemFunctionalityList = new List<Task_Item_Functionality__c>();
		for(Task_Item__c taskItemItem : testTaskItemList){
			for(Task_Item_Functionality__c tif : TestingUtils.createTaskItemFunctionality(NUMBER_TO_CREATE_TASK_ITEM_FUNCTIONALITY, false)){
				tif.Task_Item__c = taskItemItem.Id;
				testTaskItemFunctionalityList.add(tif);
			}
		}
		insert testTaskItemFunctionalityList;
	}

	private static void preparePageController (Task_Item__c taskItemForStandardController){
		testPage = Page.PickupAnalyzeArtifactsFromAuthority;
		Test.setCurrentPage(testPage);
		if (taskItemForStandardController != null) {
			testStandardController = new ApexPages.standardController(taskItemForStandardController);
			testController = new PickupAnalyzeArtifactsFromAuthorityCon(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(testTaskItemList[0]);

			System.assert(testController != null);
			Boolean testBoolean;
			testBoolean = testController.addRequaredTIF() == null;
			testBoolean = testController.addNewLineAction() == null;
			testBoolean = testController.saveTasktemFunctionality() == null;
			for (Task_Item_Functionality__c tifItem : testController.taskItemFunctionalityList){
				tifItem.Is_Saved__c = true;
				tifItem.Comments__c = 'test comment';
				tifItem.Disapproved_Date__c = Date.today();
			}
			testController.taskItem.Status__C = TaskItemServices.TASK_ITEM_STATUS_DISAPPROVED;
			testBoolean = testController.saveTasktemFunctionality() == null;
			testBoolean = testController.deleteRecordAction() == null;
			testController.tifRecordId = testController.taskItemFunctionalityList[0].Id;
			testBoolean = testController.deleteRecordAction() == null;

			Id incorrectTIFId = Id.valueOf(Task_Item_Functionality__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
			testController.taskItemFunctionalityList.add(new Task_Item_Functionality__c(Id = incorrectTIFId));
			testController.tifRecordId = incorrectTIFId;
			testBoolean = testController.deleteRecordAction() == null;

		Test.stopTest();
	}
}