@isTest
private class TestRosterEmailJunctionServices {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 1;
	private static final String PROPOSAL_RFP_ATTACHMENTS = 'test RFP Attachments';
	private static final String CONTACT_TEST_EMAIL = 'test@test.com';

	private static List<Project_Team__c> testProjectTeamList;
	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Roster_Email_Junction__c> testRosterEmailJunctionList;
	private static List<Project_Roster__c> testProjectRosterList;

	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;

	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static void setupGeneralData() {
		TestingUtils.setupData();
		partnerUser = TestingUtils.testPartnerUser;
		projectManagerUser = TestingUtils.testProjectManagerUser;
		currentUserId = TestingUtils.testCurrentUserId;
		testProjectTeamList = TestingUtils.testProjectTeamList;
		testAccountList = TestingUtils.testAccountList;

		testContactWithAccountList = TestingUtils.testContactWithAccountList;
		for(Contact c: testContactWithAccountList){
			c.Email = CONTACT_TEST_EMAIL;
		}
		update testContactWithAccountList;

		testRegionList = TestingUtils.testRegionList;
		testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
		testBuildingList = TestingUtils.testBuildingList;

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
		testProposalList = TestingUtils.testProposalList;
		for(Proposal__c pr: testProposalList){
			pr.RFP_Attachments__c = PROPOSAL_RFP_ATTACHMENTS;
		}
		update testProposalList;



		testProjectProfileList = TestingUtils.testProjectProfileList;
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Building__c = testBuildingList[0].Id;
			projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
		}
		update testProjectProfileList;
		prepareRecordTypes();
	}

	//create Project Roster for test
	private static void prepareDataForTest(){
		testProjectRosterList = new List<Project_Roster__c>();
		//created PRosters for  Partner, Project Manager and current Users
		List<Id> projectUserIdList = new List<Id>{partnerUser.Id, projectManagerUser.Id, currentUserId};
		for (Proposal__c proposalItem : testProposalList){
			Integer i = 0;
			for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(testContactWithAccountList.size(), false)){
				projectRosterItem.Contact__c = testContactWithAccountList[i].Id;
				projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
				projectRosterItem.Proposal__c = proposalItem.Id;
				testProjectRosterList.add(projectRosterItem);
				i++;
			}
			i = 0;
			for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(projectUserIdList.size(), false)){
				projectRosterItem.User__c = projectUserIdList[i];
				projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
				projectRosterItem.Proposal__c = proposalItem.Id;
				testProjectRosterList.add(projectRosterItem);
				i++;
			}
		}
		insert testProjectRosterList;
	}

	private static void prepareRecordTypes(){
		for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
			if (schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_CONTACT){
				projectRosterContactRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
			if (schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_USER){
				projectRosterUserRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
		}
	}

	private static testmethod void sendEmailsToRecipientsProposals(){
		setupGeneralData();
		prepareDataForTest();
		
		List<Roster_Email_Junction__c> newListJunctions = TestingUtils.createRosterEmailJunctionList(2, testProposalList[0], false);
		for(Roster_Email_Junction__c r : newListJunctions){
			r.Reminder_Date_Time__c = Datetime.now();
		} 
		insert newListJunctions;

		/*List<LStore__Stored_Document__c> listStoreDocument1 = TestingUtils.createLStoreStoredDocumentList(2, testProposalList[0].Id, false);
		listStoreDocument1[0].LStore__File_Name__c = StoredDocumentServices.RFP_DOCUMENTS_FOLDER;
		listStoreDocument1[0].RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID;
		listStoreDocument1[1].LStore__File_Name__c = StoredDocumentServices.PROPOSALS_FILE_TYPE;
		insert listStoreDocument1;
		*/
//--------------
		List<Change_Order__c> testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(2, false)){
                changeOrderItem.Proposal__c = testProposalList[0].Id;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        List<Document> docItem = [SELECT Id FROM Document WHERE Type IN : EmailMessageService.unpredictableFilesEtentions LIMIT 1];
        List<DocumentWrapper> testDocWrapperList = new List<DocumentWrapper>();
        if (!docItem.isEmpty()){
            testDocWrapperList.add(new DocumentWrapper(docItem[0]));
        } else {
            testDocWrapperList.add(new DocumentWrapper(new Document()));
        }
        List<LStore__Stored_Document__c> testLStoreStoredDocument = new List<LStore__Stored_Document__c>();
        Integer exrternalIdIndex = 0;
        for (Proposal__c proposalItem : testProposalList){
            for (LStore__Stored_Document__c testLStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (1, String.valueOf(proposalItem.Id), false)){
                testLStoreStoredDocumentItem.RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID;
                testLStoreStoredDocumentItem.LStore__File_Name__c = StoredDocumentServices.RFP_DOCUMENTS_FOLDER;
                testLStoreStoredDocumentItem.LStore__External_Id__c = 'test' + String.valueOf(exrternalIdIndex++);
                testLStoreStoredDocument.add(testLStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocument;

        List<LStore__Stored_Document__c> testLStoreStoredDocumentFiles = new List<LStore__Stored_Document__c>();
        for (LStore__Stored_Document__c testLStoreStoredDocumentFolder : testLStoreStoredDocument){
            for (LStore__Stored_Document__c testLStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (1, testLStoreStoredDocumentFolder.LStore__Related_Object_Id__c, false)){
                testLStoreStoredDocumentItem.LStore__Folder__c = testLStoreStoredDocumentFolder.Id;
                testLStoreStoredDocumentItem.LStore__Type__c = 'ppt';
                testLStoreStoredDocumentItem.LStore__External_Id__c = 'test' + String.valueOf(exrternalIdIndex++);
                testLStoreStoredDocumentFiles.add(testLStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocumentFiles;
//---------------------
		Roster_Email_Junction_Data__c rosterEmailJunctionData1 = new Roster_Email_Junction_Data__c();
			rosterEmailJunctionData1.is_CC__c = true;
			rosterEmailJunctionData1.is_TO__c = true;
			rosterEmailJunctionData1.Project_Roster__c = testProjectRosterList[0].Id;
			rosterEmailJunctionData1.Roster_Email_Junction__c = newListJunctions[0].Id;
		
		insert rosterEmailJunctionData1;

		Roster_Email_Junction_Data__c rosterEmailJunctionData2 = new Roster_Email_Junction_Data__c();
			rosterEmailJunctionData2.is_CC__c = true;
			rosterEmailJunctionData2.is_TO__c = true;
			rosterEmailJunctionData2.Project_Roster__c = testProjectRosterList[1].Id;
			rosterEmailJunctionData2.Roster_Email_Junction__c = newListJunctions[1].Id;
		
		insert rosterEmailJunctionData2;

		Map<Id, Roster_Email_Junction__c> oldMapJunctions = new Map<Id, Roster_Email_Junction__c>();
		for(Roster_Email_Junction__c rej : newListJunctions){
			oldMapJunctions.put(rej.Id, rej);
		}

		System.debug('!!!!! newListJunctions.size() = ' + newListJunctions.size());

		for(Roster_Email_Junction__c r : newListJunctions){
			r.Send_Email__c = true;
			r.Is_Automatic_Follow_Up__c = true;
		}

		Test.startTest();
			update newListJunctions;
		Test.stopTest();

		RosterEmailJunctionServices.deleteJunctions(newListJunctions);

	}

	private static testmethod void sendEmailsToRecipientsProposalWithChangeOrder(){
		setupGeneralData();
		prepareDataForTest();
		List<Change_Order__c> listChangeOrders = TestingUtils.createChangeOrderList(2, false);
		Integer i=0;
		for(Change_Order__c cho : listChangeOrders){
			cho.Proposal__c = testProposalList[i].Id;
			cho.Change_Order_Sent_DateTime__c = Datetime.now() + 1;
			i++;
		}
		insert listChangeOrders;

		List<Roster_Email_Junction__c> newListJunctions = TestingUtils.createRosterEmailJunctionList(2, testProposalList[0], false);
		for(Roster_Email_Junction__c r : newListJunctions){
			r.Reminder_Date_Time__c = Datetime.now();
			r.Change_Order__c = listChangeOrders[0].Id;
		} 
		insert newListJunctions;

		Roster_Email_Junction_Data__c rosterEmailJunctionData1 = new Roster_Email_Junction_Data__c();
			rosterEmailJunctionData1.is_CC__c = true;
			rosterEmailJunctionData1.is_TO__c = true;
			rosterEmailJunctionData1.Project_Roster__c = testProjectRosterList[0].Id;
			rosterEmailJunctionData1.Roster_Email_Junction__c = newListJunctions[0].Id;
		
		insert rosterEmailJunctionData1;

		Map<Id, Roster_Email_Junction__c> oldMapJunctions = new Map<Id, Roster_Email_Junction__c>();
		for(Roster_Email_Junction__c rej : newListJunctions){
			oldMapJunctions.put(rej.Id, rej);
		}

		System.debug('!!!!! newListJunctions.size() = ' + newListJunctions.size());

		for(Roster_Email_Junction__c r : newListJunctions){
			r.Send_Email__c = true;
			r.Is_Automatic_Follow_Up__c = true;
		}

		Test.startTest();
			update newListJunctions;
		Test.stopTest();

		RosterEmailJunctionServices.changeRosterEmailJunctionType(false, listChangeOrders[0].Id);

	}

}