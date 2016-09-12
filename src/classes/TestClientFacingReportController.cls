@isTest
private class TestClientFacingReportController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
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
	private static List<Proposal__c> testProposalList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static PageReference testPage;
	private static ClientFacingReportController testController;
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

	private static void createProposalProjectPropfileForTest(Integer numberToCreate){
		TestingUtils.createProposalWithProjectProfileList(numberToCreate);
		testProposalList = TestingUtils.testProposalList;
		testProjectProfileList = TestingUtils.testProjectProfileList;
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.ClientFacingReport;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			testStandardController = new ApexPages.standardController(projectProfileForStandardController);
			ApexPages.currentPage().getParameters().put('Id', projectProfileForStandardController.Id);
			testController = new ClientFacingReportController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		setupData();
		createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);

		Test.startTest();

			preparePageController(testProjectProfileList[0]);

		Test.stopTest();

		System.assert(testController != null);
	}

	private static testmethod void testSearchAction(){
		setupData();
		createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);
		preparePageController(testProjectProfileList[0]);

		Test.startTest();

			testController.baseProposal.Project_Profile__c            = testProjectProfileList[0].Id;
			testController.baseProposal.Accounting_Contact_Company__c = testProjectProfileList[0].Accounting_Contact_Company__c;
			testController.baseProposal.Billing_Company_Name__c       = testProjectProfileList[0].Billing_Company_Name__c;
			testController.baseProposal.Primary_Company_Name__c       = testProjectProfileList[0].Primary_Company_Name__c;
			testController.baseProposal.Address__c                    = testProjectProfileList[0].Building__c;

			System.assert(testController.selectedProjectsList.isEmpty());

			testController.searchAction();

		Test.stopTest();

		System.assert(!testController.selectedProjectsList.isEmpty());
	}

	private static testmethod void testForCodeCoverage(){
		setupData();
		createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);
		preparePageController(testProjectProfileList[0]);

		Test.startTest();

			System.assert(testController.selectedSingleProject != null);
			System.assert(testController.selectedMultipleProject != null);
			System.assert(testController.getRadioItems() != null);

		Test.stopTest();
	}
}