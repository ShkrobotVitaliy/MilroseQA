@isTest
private class TestDepositDetailController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_DEPOSIT_INVOICE = 1;


	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Deposit_Invoice__c> testDepositInvoiceList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static PageReference testPage;
	private static DepositDetailController testController;
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

		testDepositInvoiceList = new List<Deposit_Invoice__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, projectProfileItem.Proposal__c, projectProfileItem.Id, false)){
				testDepositInvoiceList.add(depositInvoiceItem);
			}
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, projectProfileItem.Proposal__c, null, false)){
				testDepositInvoiceList.add(depositInvoiceItem);
			}
		}
		insert testDepositInvoiceList;
	}

	private static void preparePageController (Deposit_Invoice__c depositInvoiceForStandardController){
		testPage = Page.DepositDetail;
		Test.setCurrentPage(testPage);
		if (depositInvoiceForStandardController != null) {
			ApexPages.currentPage().getParameters().put('p', depositInvoiceForStandardController.Id);
			testController = new DepositDetailController();
		}
	}

	private static testmethod void testInitController(){
		setupData();

		Test.startTest();

			preparePageController(testDepositInvoiceList[0]);
			System.assert(testController != null);

			//for test coverage
			Boolean testBoolean;
			testBoolean = testController.invoiceId == null;
			testBoolean = testController.invoiceDate == null;
			testBoolean = testController.proposalName == null;
			testBoolean = testController.clientProject == null;
			testBoolean = testController.showMailTo == null;
			testBoolean = testController.floors == null;
			testBoolean = testController.projectName == null;
			testBoolean = testController.address1 == null;
			testBoolean = testController.address2 == null;
			testBoolean = testController.accountManagerName == null;
			testBoolean = testController.accountingCompanyName == null;
			testBoolean = testController.accountingContactAddress == null;
			testBoolean = testController.accountingContactName == null;
			testBoolean = testController.billingCompanyName == null;
			testBoolean = testController.billingContactAddress == null;
			testBoolean = testController.billingContactName == null;

		Test.stopTest();
	}



}