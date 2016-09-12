@isTest
private class TestProposalWizardRoster {
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<Proposal__c> testProposalDraftList;
	private static List<Contact> testContactList;
    private static List<LStore__Stored_Document__c> testStoredDocumentList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static ProposalWizardRoster testClass;
	private static ProposalWizardModel proposalWizModel;
	private static PageReference testPage;

	private static void prepareRecordTypePickListForTest(){
		for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
			if(schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_USER){
				projectRosterUserRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
			if(schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_CONTACT){
				projectRosterContactRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
		}
	}

	private static void setupData(){
		if (projectRosterUserRecordTypeId == null || projectRosterContactRecordTypeId == null){
			prepareRecordTypePickListForTest();
		}

		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

		testContactList = TestingUtils.createContactList(1, true);
	}

	private static void prepareDataForTest(){
		setupData();

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
		testProposalList = TestingUtils.testProposalList;
		testProjectProfileList = TestingUtils.testProjectProfileList;

		testStoredDocumentList = new List<LStore__Stored_Document__c>();
		for (Proposal__c proposalItem : testProposalList){
			for (LStore__Stored_Document__c storedDocumentItem : TestingUtils.createLStoreStoredDocumentList(1, String.valueOf(proposalItem.Id), false)){
				storedDocumentItem.LStore__File_Size__c = 10;
				testStoredDocumentList.add(storedDocumentItem);
			}
		}
		insert testStoredDocumentList;
	}

	private static void createProjectRostersForProposal(){
		String userKeyPrefix = User.sObjectType.getDescribe().getKeyPrefix();
		testProjectRosterList = new List<Project_Roster__c>();
		for (Proposal__c proposalItem : testProposalList){
			Map<String, Id> tmpRoleWithPersonMap = ProjectRosterServices.getRoleToUserField(proposalItem);
			for (String roleValue : tmpRoleWithPersonMap.keySet()){
				if (tmpRoleWithPersonMap.get(roleValue) != null){
					Id personId = tmpRoleWithPersonMap.get(roleValue);//User or Contact Id
					for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
						projectRosterItem.Proposal__c = proposalItem.Id;
						projectRosterItem.Project_Profile__c = proposalItem.Project_Profile__c;
						projectRosterItem.Role__c = roleValue;
						projectRosterItem.Is_Read__c = true;
						if (String.valueOf(personId).startsWith(userKeyPrefix)){
							projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
							projectRosterItem.User__c = personId;
						}else{
							projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
							projectRosterItem.Contact__c = personId;
						}
						testProjectRosterList.add(projectRosterItem);
					}
					for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
						projectRosterItem.Proposal__c = proposalItem.Id;
						projectRosterItem.Project_Profile__c = proposalItem.Project_Profile__c;
						projectRosterItem.Role__c = roleValue;
						projectRosterItem.Is_Read__c = true;
						if (String.valueOf(personId).startsWith(userKeyPrefix)){
							projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
							projectRosterItem.User__c = currentUserId;
						}else{
							projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
							projectRosterItem.Contact__c = testContactList[0].Id;
						}
						testProjectRosterList.add(projectRosterItem);
					}
				}
			}
		}
		insert testProjectRosterList;
	}

	private static void initiliazeClass(Proposal__c proposalItem){
		proposalWizModel = new ProposalWizardModel(proposalItem, testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.ROLE_CZ_MANAGER);
		testClass = new ProposalWizardRoster(proposalItem, proposalWizModel);
	}

	private static void setPageWithParameters(Id projectRosterId, String rosterRole){
		testPage = Page.ProposalWizard;
		Test.setCurrentPage(testPage);
		ApexPages.currentPage().getParameters().put('rosterId', (projectRosterId == null) ? '' : String.valueOf(projectRosterId));
		ApexPages.currentPage().getParameters().put('rosterRole', (rosterRole == null) ? '' : rosterRole);
	}

	private static testMethod void testInitClass(){
		prepareDataForTest();
		createProjectRostersForProposal();
		setPageWithParameters(testProjectRosterList[0].Id, 'test roster role');

		Test.startTest();
			initiliazeClass(testProposalList[0]);

			System.assert(testClass != null);
			Boolean testBoolean;
			testBoolean = testClass.getTotalSizeOfProposalAttachments(testProposalList[0].Id) == null;
			testBoolean = testClass.getContactRosters() == null;
			testBoolean = testClass.changeContactRosterRoleAction() == null;
			testBoolean = testClass.getContactRosters() == null;
			testClass.rosterToAdd.Contact_Filter__c = testContactList[0].Id;
			testBoolean = testClass.addContactToRosterAction(testProposalList[0]) == null;
			testBoolean = testClass.deleteContactFromRosterAction() == null;
			testBoolean = testClass.saveProjectRoster(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Primary_Company_Name__c = null;
			testProposalList[0].Primary_Client_is_Billing_Client__c = true;
			testBoolean = testClass.primaryCompanyAction(testProposalList[0], proposalWizModel, false) == null;
			testBoolean = testClass.billingCompanyAndContactAction(testProposalList[0], proposalWizModel, false, false) == null;
			testBoolean = testClass.accountingContactAction(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Billing_Company_Contact__c = null;
			testBoolean = testClass.billingCompanyAction(testProposalList[0], proposalWizModel, testAccountList[0], false, false) == null;
			testProposalList[0].Accounting_Contact_Company__c = null;
			testBoolean = testClass.accountingCompanyAction(testProposalList[0], proposalWizModel, false) == null;
			testBoolean = testClass.isRosterValid() == null;
		Test.stopTest();

	}

	private static testMethod void testInitClass1(){
		prepareDataForTest();
		createProjectRostersForProposal();
		setPageWithParameters(testProjectRosterList[0].Id, 'test roster role');

		Test.startTest();
			initiliazeClass(testProposalList[0]);

			System.assert(testClass != null);
			Boolean testBoolean;
			testProposalList[0].Primary_Client_is_Billing_Client__c = true;
			testBoolean = testClass.primaryCompanyIsBillingCompanyAction(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Primary_Client_is_Billing_Client__c = false;
			testBoolean = testClass.primaryCompanyIsBillingCompanyAction(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Send_Invoices_to_Different_Contact__c = true;
			testBoolean = testClass.sendInvoicesToDifferentContactAction(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Send_Invoices_to_Different_Contact__c = false;
			testBoolean = testClass.sendInvoicesToDifferentContactAction(testProposalList[0], proposalWizModel) == null;
			testProposalList[0].Send_Invoices_to_Different_Contact__c = false;
			testBoolean = testClass.setProposalFieldsForBillingClient(testProposalList[0], proposalWizModel, testAccountList[0]) == null;
			testProposalList[0].Send_Invoices_to_Different_Contact__c = false;
			testBoolean = testClass.setProposalFieldsForBillingClient(testProposalList[0], proposalWizModel, new Account()) == null;
			testBoolean = testClass.addAdditionalToAndCc(testProposalList[0]) == null;
			testBoolean = testClass.isAdditionalToAndCcValid() == null;
			testBoolean = testClass.initRosterEmailJunctionData( new ProposalWizardRosterWrapper(testProjectRosterList[0]) ) == null;
			testBoolean = testClass.initRosterEmailJunction(proposalWizModel, testProposalList[0], null, new ProposalWizardRosterWrapper(testProjectRosterList[0]), false) == null;
			testBoolean = testClass.createRosterEmailJunctions(proposalWizModel, testProposalList[0], null, false, false) == null;
			testProposalList[0].UseDocusign__c = false;
			testBoolean = testClass.createRosterEmailJunctions(proposalWizModel, testProposalList[0], null, false, false) == null;
		Test.stopTest();
	}

	private static testMethod void testInitClassWithoutProjectProfile(){
		setupData();
		testProposalList = TestingUtils.createProposalListForTest(1, true);
		createProjectRostersForProposal();
		setPageWithParameters(testProjectRosterList[0].Id, 'test roster role');

		Test.startTest();
			initiliazeClass(testProposalList[0]);

			System.assert(testClass != null);
		Test.stopTest();

	}
}