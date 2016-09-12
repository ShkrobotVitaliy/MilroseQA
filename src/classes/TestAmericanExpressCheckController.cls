@isTest
private class TestAmericanExpressCheckController {
	private static final Integer NUMBERF_TO_CREATE_PRO_FORMA_INVOICE = 1;
	private static final Integer NUMBER_TO_CREATE = 1;
	private static Account testAccount;
	private static Contact testContact;
	private static User projectManager;
	private static Project_Profile__c testProject;
	private static Proposal__c testProposal;
	private static List<Pro_forma_Invoice__c> testProformaInvoiceList;

	private static ApexPages.StandardController controller;
	private static AmericanExpressCheckController testController;

	private static void prepareDataForTest (){
		projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);

		testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAcc', false)[0];
		testAccount.A_R_coordinator__c = projectManager.Id;
		insert testAccount;

		testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];

		testProposal = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE, false)[0];
		testProposal.Billing_Company_Name__c = testAccount.Id;
		testProposal.Billing_Company_Contact__c = testContact.Id;
		testProposal.Accounting_Contact_Company__c = testAccount.Id;
		testProposal.Accounting_Contact__c = testContact.Id;
		insert testProposal;

		testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE,
															testAccount.Id,
															testContact.Id,
															testAccount.Id,
															testContact.Id,
															testAccount.Id,
															testContact.Id,
															projectManager.Id,
															false)[0];
		testProject.Billing_Company_Name__c = testAccount.Id;
		testProject.Billing_Company_Name__c = testAccount.Id;
		testProject.Billing_Company_Contact__c = testContact.Id;
		testProject.Accounting_Contact_Company__c = testAccount.Id;
		testProject.Accounting_Contact__c = testContact.Id;
		testProject.Primary_Company_Name__c = testAccount.Id;
		testProject.Fulfillment_Office__c = 'TestOffice';
		testProject.Proposal__c = testProposal.Id;
		insert testProject;

		testProposal.Project_Profile__c = testProject.Id;
		update testProposal;

		testProformaInvoiceList = TestingUtils.createProFormaInvoiceList(NUMBERF_TO_CREATE_PRO_FORMA_INVOICE, testAccount.Id, testContact.Id, null, false);
		for(Pro_forma_Invoice__c proFormaInvoiceItem : testProformaInvoiceList){
			proFormaInvoiceItem.Project_Profile__c = testProject.Id;
		}
		insert testProformaInvoiceList;
	}

	private static void setUpControllerAndInitiliazePage( Pro_forma_Invoice__c proFormaInvoice ){        
		controller = new ApexPages.StandardController( proFormaInvoice );
		testController = new AmericanExpressCheckController(controller);
	}

	private static testMethod void testInitAmericanExpressCheckController(){
		prepareDataForTest();

		Test.startTest();
			setUpControllerAndInitiliazePage(testProformaInvoiceList[0]);
		Test.stopTest();
	}

	@IsTest(SeeAllData=true)
	private static void testInitAmericanExpressCheckControllerActualData(){
		prepareDataForTest();

		testProformaInvoiceList = [SELECT Id FROM Pro_forma_Invoice__c LIMIT 1];

		Test.startTest();
			setUpControllerAndInitiliazePage(testProformaInvoiceList[0]);
		Test.stopTest();
	}

	@IsTest(SeeAllData=true)
	private static void testAmericanExpressProformaInvoiceWrapper(){
		List<c2g__codaPurchaseInvoice__c> invoiceList = [SELECT Id, Billing_Line_Item__r.Milestone_Date__c, Check_Request__r.Account__r.Name, Check_Request__r.Account__r.City__c,
																	Check_Request__r.Account__r.StateProvID__c, Check_Request__r.Owner.Name, Billing_Line_Item__r.Amount__c,
																	Billing_Line_Item__r.Name, Check_Request__r.Account__r.Phone, Check_Request__r.Account__r.BillingStreet,
																	Check_Request__r.Account__r.BillingCity, Check_Request__r.Account__r.BillingState,
																	Check_Request__r.Account__r.BillingPostalCode, Check_Request__r.Account__r.BillingCountry
														 FROM c2g__codaPurchaseInvoice__c
														 WHERE Check_Request__r.Requested_From__c = : CheckServices.CHARGE
																AND Billing_Line_Item__r.Pro_forma_Invoice__c != null LIMIT 1];

		Test.startTest();
			if ( !invoiceList.isEmpty() ) new AmericanExpressCheckController.AmericanExpressProformaInvoiceWrapper(invoiceList[0]);
		Test.stopTest();
	}
}