@isTest
private class TestContactLevelTransmittalController {
	private final static Integer NUMBER_TO_CREATE_CONTACT = 3;
	private final static Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 2;
	private final static Integer NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL = 1;
	private final static String TEST_PROJECT_ROSTER_ROLE = 'test project roster role';
	private final static String TEST_SEND_VIE = 'test send vie';
	private final static String TEST_ARTIFACT = 'test artifact';
	private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';
	private final static String TEST_SHORT_NAME = 'test short name';
	private final static String TEST_DESCRIPTION = 'test description';
	private final static String TEST_INTEGRATION_OPTION_NAME_DOWNLOAD = 'Download';

	private static List<Contact> testContactList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<DDP_Helper__c> testDDPHelperList;
	private static List<Comments_Transmittal__c> testCommentsTransmittalList;
	private static List<Loop__DDP__c> testDDPList;
	private static List<Loop__DDP_Integration_Option__c> testDDPIntegrationOptionList;

	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static ContactLevelTransmittalController testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
																										 City__c = 'city',
																										 Street__c = 'street',
																										 Phone__c = '888-999-666',
																										 Fax__c = '111-222-333');
		Insert testFulfillmentOfficeAddresses;

		testCommentsTransmittalList = TestingUtils.createCommnetsTransmittal(NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL, false);
		for (Comments_Transmittal__c commentsTransmittalItem : testCommentsTransmittalList){
			commentsTransmittalItem.Short_Name__c = TEST_SHORT_NAME;
			commentsTransmittalItem.Description__c = TEST_DESCRIPTION;
		}
		insert testCommentsTransmittalList;

		testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, false);
		Integer i = 0;
		for (Contact contactItem : testContactList){
			contactItem.Is_Active__c = true;
			contactItem.Email = 'test' + String.valueOf(i++) + '@test.com';
		}
		insert testContactList;

		projectRosterContactRecordTypeId = [SELECT Id, SobjectType, DeveloperName, Name
											FROM RecordType
											WHERE SobjectType = : ProjectRosterServices.PROJECT_ROSTER_OBJECT_API_NAME AND
												DeveloperName = : ProjectRosterServices.TYPE_CONTACT LIMIT 1][0].Id;

		testProjectRosterList = new List<Project_Roster__c>();
		for (Contact contactItem : testContactList){
			Integer iRosterRole = 0;
			for(Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
				projectRosterItem.Contact__c = contactItem.Id;
				projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(iRosterRole++);
				projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
				testProjectRosterList.add(projectRosterItem);
			}
		}

		insert testProjectRosterList;
	}

	private static void prepareDDPForTest(){
		testDDPList = TestingUtils.createLoopDDPList(1, false);
		testDDPList[0].Name = DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT_CONTACT;
		insert testDDPList;

		testDDPIntegrationOptionList = TestingUtils.createLoopDDPIntegrationOptionList(1, testDDPList[0].Id, false);
		testDDPIntegrationOptionList[0].Name = TEST_INTEGRATION_OPTION_NAME_DOWNLOAD;
		insert testDDPIntegrationOptionList;

	}

	private static void preparePageController (Contact contactItemForStandardController){
		testPage = Page.ContactLevelTransmittal;
		Test.setCurrentPage(testPage);
		if (contactItemForStandardController != null) {
			testStandardController = new ApexPages.standardController(contactItemForStandardController);
			testController = new ContactLevelTransmittalController(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(testContactList[0]);

		Test.stopTest();

		System.assert(testController != null);
	}


	private static testmethod void testAddNewDataRowAction(){
		prepareDataForTest();
			preparePageController(testContactList[0]);

		Test.startTest();

			testController.addNewDataRowAction();

		Test.stopTest();
	}

	private static testmethod void testUpdateDataRowsAction(){
		prepareDataForTest();
			preparePageController(testContactList[0]);

		Test.startTest();

			testController.updateDataRowsAction();

		Test.stopTest();
	}

	private static testmethod void testPreviewTransmittal(){
		prepareDataForTest();
		preparePageController(testContactList[0]);

		System.assert(!testController.tableDataRows.isEmpty());
		for(DDP_Helper__c recordItem : testController.tableDataRows){
			recordItem.Is_Email_Sent__c = true;
			recordItem.Sent_Date_Time__c = null;
			recordItem.Sent_VIA__c = TEST_SEND_VIE;
			recordItem.Artifacts__c = TEST_ARTIFACT;
		}

		Test.startTest();

			testController.previewTransmittal();

		Test.stopTest();
	}

	private static testmethod void testDeleteDataRowAction(){
		prepareDataForTest();
		preparePageController(testContactList[0]);

		testController.addNewDataRowAction();
		testController.tableRecordId = testController.tableDataMap.values()[0].Id;

		Test.startTest();

			testController.deleteDataRowAction();

		Test.stopTest();
	}

	private static testmethod void testSaveTransmittal(){
		prepareDataForTest();
		prepareDDPForTest();
		preparePageController(testContactList[0]);

		System.assert(!testController.tableDataRows.isEmpty());
		for(DDP_Helper__c recordItem : testController.tableDataRows){
			recordItem.Is_Email_Sent__c = true;
			recordItem.Sent_Date_Time__c = null;
			recordItem.Sent_VIA__c = TEST_SEND_VIE;
			recordItem.Artifacts__c = TEST_ARTIFACT;
		}

		testController.transmittal.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
		testController.transmittal.Comments__c = TEST_SHORT_NAME;

		for (Project_Roster__c projectRosterItem : testProjectRosterList){
			if(projectRosterItem.Contact__c == testContactList[0].Id ){
				testController.rosterId = projectRosterItem.Id;
				testController.rosterForTransmittalSendTo = projectRosterItem;
				break;
			}
		}

		Test.startTest();

			testController.saveTransmittal();

		Test.stopTest();
	}


	private static testmethod void testAttachPDF(){
		prepareDataForTest();
		prepareDDPForTest();
		preparePageController(testContactList[0]);

		Test.startTest();

			testController.attachPDF();

		Test.stopTest();
	}


	private static testmethod void testRosterCCToAction(){
		prepareDataForTest();
		preparePageController(testContactList[0]);

		testController.initRosterForTransmittal();


		for (Project_Roster__c projectRosterItem : testProjectRosterList){
			if(projectRosterItem.Contact__c == testContactList[0].Id ){
				testController.wrapoutRosters[0].rosterIdCCToInWrapper = projectRosterItem.Id;
				break;
			}
		}

		Test.startTest();

			testController.rosterCCToAction();

		Test.stopTest();
	}

	private static testmethod void testReturnToProjectLevel(){
		prepareDataForTest();
		preparePageController(testContactList[0]);

		Test.startTest();

			testController.returnToProjectLevel();

		Test.stopTest();
	}

	private static testmethod void testForCodeCoverage(){
		prepareDataForTest();
		preparePageController(testContactList[0]);

		Test.startTest();

			System.assert(testController.disabledButton != null);
			System.assert(testController.disableAddCCButton != null);
			testController.addCCToRoster();
			System.assert(testController.rosterIdToRoleOptions != null);
			System.assert(testController.officeIdToOfficeOptions != null);
			System.assert(testController.nameToRosterMap != null);
			testController.cancelAction();

		Test.stopTest();
	}
}