@isTest
private class TestDrawingsReceivedController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 2;
	private static final Integer NUMBER_TO_CREATE_DRAWINGS_RECEIVED = 1;
	private static final String TEST_PROJECT_CLOSURE_REASON_VALUE = 'test project closure reasone';
	private static final String TEST_PROJECT_ROSTER_ROLE = 'test project roster role';

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<Drawings_Received__c> testDrawingsReceivedList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static DrawingsReceivedController testController;
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

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROJECT_PROFILE);
		testProposalList = TestingUtils.testProposalList;
		testProjectProfileList = TestingUtils.testProjectProfileList;

		projectRosterContactRecordTypeId = [SELECT Id, SobjectType, DeveloperName, Name
											FROM RecordType
											WHERE SobjectType = : ProjectRosterServices.PROJECT_ROSTER_OBJECT_API_NAME AND
												DeveloperName = : ProjectRosterServices.TYPE_CONTACT LIMIT 1][0].Id;

		testProjectRosterList = new List<Project_Roster__c>();
		for (Contact contactItem : testContactWithAccountList){
			Integer iRosterRole = 0;
			for(Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
				projectRosterItem.Contact__c = contactItem.Id;
				projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(iRosterRole++);
				projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
				testProjectRosterList.add(projectRosterItem);
			}
		}

		insert testProjectRosterList;

		testDrawingsReceivedList = TestingUtils.createDrawingsReceivedList(NUMBER_TO_CREATE_DRAWINGS_RECEIVED, testProjectProfileList[0].Id, true);
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.DrawingsReceived;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			testStandardController = new ApexPages.standardController(projectProfileForStandardController);
			testController = new DrawingsReceivedController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		setupData();

		Test.startTest();

			preparePageController(testProjectProfileList[0]);

			System.assert(testController != null);
			System.assert(testController.getRosters() != null);

			for(Drawings_Received__c drawingsReceivedItem : testController.drawingsReceived){
				drawingsReceivedItem.Work_Type__c = 'test work type';
				break;
			}

			testController.saveDrawingsReceived();

		Test.stopTest();
	}
}