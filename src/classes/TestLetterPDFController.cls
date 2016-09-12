@isTest
private class TestLetterPDFController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final String TEST_PROJECT_CLOSURE_REASON_VALUE = 'test project closure reasone';
	private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static PageReference testPage;
	private static LetterPDFController testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
																										 City__c = 'city',
																										 Street__c = 'street',
																										 Phone__c = '888-999-666',
																										 Fax__c = '111-222-333');

		Insert testFulfillmentOfficeAddresses;

		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

		testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);

		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
		}
		insert testProjectProfileList;
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.Letter;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			ApexPages.currentPage().getParameters().put('projectId', projectProfileForStandardController.Id);
			testStandardController = new ApexPages.standardController(projectProfileForStandardController);
			testController = new LetterPDFController();
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();
			preparePageController(testProjectProfileList[0]);

			System.assert(testController != null);

			//for test coverage
			Boolean testBoolean;
			testBoolean = testController.project != null;
			testBoolean = testController.fieldNumber != null;
			testBoolean = testController.type != null;
			testBoolean = testController.isProjectProfile != null;
			testBoolean = testController.isServiceItem != null;
			testBoolean = testController.fulfillmentOffice != null;

		Test.stopTest();
	}
}