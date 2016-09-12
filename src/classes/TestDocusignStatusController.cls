@isTest
private class TestDocusignStatusController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_DOCUSING_STATUS = 1;
	private static final Integer NUMBER_TO_CREATE_DOCUSING_RECIPIENT_STATUS = 1;
	private static final String RECIPIENT_TYPE_SIGNER = 'Signer';

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<dsfs__DocuSign_Status__c> testDocuSignStatusList;
	private static List<dsfs__DocuSign_Recipient_Status__c> testDocuSignRecipientStatusList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static PageReference testPage;
	private static DocusignStatusController testController;
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

		testDocuSignStatusList = new List<dsfs__DocuSign_Status__c>();
		for (Proposal__c proposalItem : testProposalList){
			for(dsfs__DocuSign_Status__c docuSignStatusItem : TestingUtils.createDocuSignStatusList(NUMBER_TO_CREATE_DOCUSING_STATUS, false)){
				docuSignStatusItem.Proposal_Docusign_Status__c = proposalItem.Id;
				testDocuSignStatusList.add(docuSignStatusItem);
			}
		}
		insert testDocuSignStatusList;

		testDocuSignRecipientStatusList = new List<dsfs__DocuSign_Recipient_Status__c>();
		for (dsfs__DocuSign_Status__c docuSignStatusItem : testDocuSignStatusList){
			for(dsfs__DocuSign_Recipient_Status__c docuSignRecipientStatusItem : TestingUtils.createDocuSignRecipientStatusList(NUMBER_TO_CREATE_DOCUSING_RECIPIENT_STATUS, docuSignStatusItem.Id, false)){
				docuSignRecipientStatusItem.Recipient_Type__c = RECIPIENT_TYPE_SIGNER;
				testDocuSignRecipientStatusList.add(docuSignRecipientStatusItem);
			}
		}
		insert testDocuSignRecipientStatusList;

		
	}

	private static void preparePageController (Proposal__c proposalForStandardController){
		testPage = Page.DocusignStatus;
		Test.setCurrentPage(testPage);
		if (proposalForStandardController != null) {
			testStandardController = new ApexPages.StandardController( proposalForStandardController );
			testController = new DocusignStatusController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		setupData();

		Test.startTest();

			preparePageController(testProposalList[0]);
			System.assert(testController != null);

			testController.refreshStatuses();

		Test.stopTest();
	}

}