@isTest
private class TestReopenProjectController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private final static Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 2;
	private final static Integer NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL = 1;
	private final static Integer NUMBER_TO_CREATE_DDP_HELPER = 1;
	private final static String TEST_PROJECT_ROSTER_ROLE = 'test project roster role';
	private final static String TEST_SEND_VIE = 'test send vie';
	private final static String TEST_ARTIFACT = 'test artifact';
	private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';
	private final static String TEST_SHORT_NAME = 'test short name';
	private final static String TEST_DESCRIPTION = 'test description';
	private final static String TEST_INTEGRATION_OPTION_NAME_DOWNLOAD = 'Download';
	private final static String TEST_TYPE_NAME = 'Project Level Transmittal';

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<DDP_Helper__c> testDDPHelperList;
	private static List<Comments_Transmittal__c> testCommentsTransmittalList;
	private static List<Loop__DDP__c> testDDPList;
	private static List<Loop__DDP_Integration_Option__c> testDDPIntegrationOptionList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static ReopenProjectController testController;
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

		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_CLOSED;
		}

		update testProjectProfileList;
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.ReopenProject;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			testStandardController = new ApexPages.standardController(projectProfileForStandardController);
			testController = new ReopenProjectController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(testProjectProfileList[0]);
			System.assert(testController != null);

			testController.isValid = true;
			testController.reopenCurrentProject();

		Test.stopTest();
	}
}