@isTest
private class TestRetainerInvoiceController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 1;
	private static final Integer NUMBER_TO_CREATE_DEPOSIT_INVOICE = 1;


	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Change_Order__c> testChangeOrderList;
	private static List<Deposit_Invoice__c> testDepositInvoiceList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static PageReference testPage;
	private static RetainerInvoiceController testController;
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

		for (Proposal__c proposalItem : testProposalList){
			proposalItem.No_Retainer__c = false;
			proposalItem.Retainer_Amount__c = 3.4;
		}
		update testProposalList;

		testChangeOrderList = new List<Change_Order__c>();
		for (Proposal__c proposalItem : testProposalList){
			for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
				changeOrderItem.Status__c = ChangeOrderServices.STATUS_PENDING_CLIENT;
				changeOrderItem.Proposal__c = proposalItem.Id;
				changeOrderItem.Municipal_Authority_Fees__c = ChangeOrderServices.DOB_VARIANCE_FEES_PROJECTED;
				changeOrderItem.Projected_DOB_Fee__c = 2.1;
				changeOrderItem.Project_Profile__c = proposalItem.Project_Profile__c;
				testChangeOrderList.add(changeOrderItem);
			}
		}
		insert testChangeOrderList;

		testDepositInvoiceList = new List<Deposit_Invoice__c>();

		//create Deposit Invoices without CO
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, projectProfileItem.Proposal__c, projectProfileItem.Id, false)){
				depositInvoiceItem.Deposit_Invoice_Type__c = DepositInvoiceServices.SERVICE_RETAINER_TYPE;
				testDepositInvoiceList.add(depositInvoiceItem);
			}
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, projectProfileItem.Proposal__c, projectProfileItem.Id, false)){
				depositInvoiceItem.Accounting_Contact_Company__c = projectProfileItem.Accounting_Contact_Company__c;
				depositInvoiceItem.Accounting_Contact__c = projectProfileItem.Accounting_Contact__c;
				depositInvoiceItem.Billing_Company_Name__c = projectProfileItem.Billing_Company_Name__c;
				depositInvoiceItem.Billing_Company_Contact__c = projectProfileItem.Billing_Company_Contact__c;
				depositInvoiceItem.Deposit_Invoice_Type__c = DepositInvoiceServices.SERVICE_RETAINER_TYPE;
				testDepositInvoiceList.add(depositInvoiceItem);
			}
		}

		//create Deposit Invoices with CO
		for (Change_Order__c changeOrderItem : testChangeOrderList){
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, changeOrderItem.Proposal__c, changeOrderItem.Project_Profile__c, false)){
				depositInvoiceItem.Change_Order__c = changeOrderItem.Id;
				depositInvoiceItem.Deposit_Invoice_Type__c = DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE;
				testDepositInvoiceList.add(depositInvoiceItem);
			}
		}
		insert testDepositInvoiceList;
	}

	private static void preparePageController (Proposal__c proposalForStandardController, Boolean isCOType){
		testPage = Page.RetainerInvoice;
		Test.setCurrentPage(testPage);
		if (proposalForStandardController != null) {
			ApexPages.currentPage().getParameters().put('p', proposalForStandardController.Id);
			if (isCOType) ApexPages.currentPage().getParameters().put('Type', 'co');
			testController = new RetainerInvoiceController();
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(testProposalList[0], false);
			System.assert(testController != null);

			//for test coverage
			System.assert (testController.invoices != null && testController.invoices.size() > 0);

			Boolean testBoolean;
			testBoolean = testController.invoices[0].invoiceId == null;
			testBoolean = testController.invoices[0].invoiceDate == null;
			testBoolean = testController.invoices[0].proposalName == null;
			testBoolean = testController.invoices[0].clientProject == null;
			testBoolean = testController.invoices[0].showMailTo == null;
			testBoolean = testController.invoices[0].floors == null;
			testBoolean = testController.invoices[0].projectName == null;
			testBoolean = testController.invoices[0].projectMrcName == null;
			testBoolean = testController.invoices[0].refNumber == null;
			testBoolean = testController.invoices[0].address1 == null;
			testBoolean = testController.invoices[0].address2 == null;
			testBoolean = testController.invoices[0].depositPercentage == null;
			testBoolean = testController.invoices[0].depositType == null;
			testBoolean = testController.invoices[0].quantity == null;
			testBoolean = testController.invoices[0].depositAmount == null;
			testBoolean = testController.invoices[0].depositAmountTotal == null;
			testBoolean = testController.invoices[0].amountPaid == null;
			testBoolean = testController.invoices[0].tax == null;
			testBoolean = testController.invoices[0].amountDue == null;
			testBoolean = testController.invoices[0].accountManagerName == null;

			for (Integer i = 0; i < testController.invoices.size() - 1; i++){
				testBoolean = testController.invoices[i].accountingCompanyName == null;
				testBoolean = testController.invoices[i].accountingContactAddress == null;
				testBoolean = testController.invoices[i].accountingContactName == null;
				testBoolean = testController.invoices[i].billingCompanyName == null;
				testBoolean = testController.invoices[i].billingContactAddress == null;
				testBoolean = testController.invoices[i].billingContactName == null;
				testBoolean = testController.invoices[i].arCoorName == null;
				testBoolean = testController.invoices[i].arCoorPhone == null;
				testBoolean = testController.invoices[i].arCoorEmail == null;
			}

		Test.stopTest();
	}
}