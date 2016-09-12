@isTest
private class TestProjectLevelTransmittalController {
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
	private static ProjectLevelTransmittalController testController;
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

	private static void prepareDataForTest(){
		FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
																										 City__c = 'city',
																										 Street__c = 'street',
																										 Phone__c = '888-999-666',
																										 Fax__c = '111-222-333');
		Insert testFulfillmentOfficeAddresses;

		testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
		}
		Insert testProjectProfileList;

		testCommentsTransmittalList = TestingUtils.createCommnetsTransmittal(NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL, false);
		for (Comments_Transmittal__c commentsTransmittalItem : testCommentsTransmittalList){
			commentsTransmittalItem.Short_Name__c = TEST_SHORT_NAME;
			commentsTransmittalItem.Description__c = TEST_DESCRIPTION;
		}
		insert testCommentsTransmittalList;

		projectRosterContactRecordTypeId = [SELECT Id, SobjectType, DeveloperName, Name
											FROM RecordType
											WHERE SobjectType = : ProjectRosterServices.PROJECT_ROSTER_OBJECT_API_NAME AND
												DeveloperName = : ProjectRosterServices.TYPE_CONTACT LIMIT 1][0].Id;

		testProjectRosterList = new List<Project_Roster__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Contact contactItem : testContactWithAccountList){
				Integer iRosterRole = 0;
				for(Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
					projectRosterItem.Contact__c = contactItem.Id;
					projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(iRosterRole++);
					projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
					projectRosterItem.Project_Profile__c = projectProfileItem.Id;
					testProjectRosterList.add(projectRosterItem);
				}
			}
		}

		insert testProjectRosterList;

		testDDPHelperList = new List<DDP_Helper__c>();
		for (Project_Roster__c projectRosterItem : testProjectRosterList){
			for (DDP_Helper__c ddpHelperItem : TestingUtils.createDDPHelperList(NUMBER_TO_CREATE_DDP_HELPER, false)){
				ddpHelperItem.Project_Profile__c = projectRosterItem.Project_Profile__c;
				ddpHelperItem.Project_Roster__c = projectRosterItem.Id;
				ddpHelperItem.Type__c = TEST_TYPE_NAME;
				testDDPHelperList.add(ddpHelperItem);
			}
		}
		insert testDDPHelperList;

		testDDPList = TestingUtils.createLoopDDPList(1, false);
		testDDPList[0].Name = DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT_CONTACT;
		insert testDDPList;

		testDDPIntegrationOptionList = TestingUtils.createLoopDDPIntegrationOptionList(1, testDDPList[0].Id, false);
		testDDPIntegrationOptionList[0].Name = TEST_INTEGRATION_OPTION_NAME_DOWNLOAD;
		insert testDDPIntegrationOptionList;
	}

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.ProjectLevelTransmittal;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			testStandardController = new ApexPages.standardController(projectProfileForStandardController);
			testController = new ProjectLevelTransmittalController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		setupData();
		prepareDataForTest();

		Test.startTest();

			preparePageController(testProjectProfileList[0]);
			System.assert(testController != null);
			System.assert(testController.projectProfileItem != null);

			Boolean testBoolean;
			testBoolean = testController.tableDataRows == null;
			testBoolean = testController.disabledButton == null;
			testBoolean = testController.tableRecordId == null;
			testBoolean = testController.updateDataRowsAction() == null;
			testController.tableRecordId = testController.tableDataRows[0].Id;
			testBoolean = testController.deleteDataRowAction() == null;
			testBoolean = testController.addNewDataRowAction() == null;
			testBoolean = testController.recordsToSendMap == null;
			testController.tableDataRows[0].Is_Email_Sent__c = true;
			testController.tableDataRows[0].Sent_VIA__c = 'test';
			testController.tableDataRows[0].Artifacts__c = 'test';
			testBoolean = testController.populateRecordsToSendMap() == null;
			testBoolean = testController.rosterSendToAction() == null;
			testBoolean = testController.rosterReplyToAction() == null;
			testBoolean = testController.rosterCCToAction() == null;
			testBoolean = testController.addCCToRoster() == null;
			testBoolean = testController.disableAddCCButton == null;
			testBoolean = testController.rosterReplyToId == null;
			testBoolean = testController.rosterId == null;
			testBoolean = testController.rosterForTransmittalSendTo == null;
			testBoolean = testController.rosterForTransmittalReplyTo == null;
			testBoolean = testController.rosterIdToRoleOptions == null;
			testBoolean = testController.commentsShortName == null;
			testBoolean = testController.showTransmittalEditor == null;
			testBoolean = testController.transmittal == null;
			testBoolean = testController.nameToRosterMap == null;
			testBoolean = testController.previewTransmittal() == null;
			testBoolean = testController.filledOutTransmittalRecord() == null;
			testBoolean = testController.cancelAction() == null;
			testBoolean = testController.saveTransmittal() == null;
			testBoolean = testController.updateRecordToCreateTransmittal() == null;
			testBoolean = testController.attachPDF() == null;
			testBoolean = testController.returnToProjectLevel() == null;

		Test.stopTest();
	}
}