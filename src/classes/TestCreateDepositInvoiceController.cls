@isTest
private class TestCreateDepositInvoiceController {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
	private static final Integer NUMBER_TO_CREATE_DEPOSIT_INVOICE = 3;

	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Deposit_invoice__c> testDepositInvoiceList;
	private static CreateDepositInvoiceController testController;
	private static ApexPages.StandardController standardController;

	private static void setupData(){
		testProjectProfileList = TestingUtils.createProjectProfileForTest(1, true);
		testDepositInvoiceList = TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE_DEPOSIT_INVOICE, null, testProjectProfileList[0].Id, true);
	}

	private static void createController(Deposit_invoice__c depositInvoice){
		Test.setCurrentPage(Page.CreateDepositInvoice);
		standardController = new ApexPages.StandardController(depositInvoice);
		testController = new CreateDepositInvoiceController(standardController);
	}

	private static testmethod void testCreateController(){
		setupData();

		Test.startTest();

			createController(testDepositInvoiceList[0]);

		Test.stopTest();

		System.assert(testController.invoice != null);
		System.assertEquals(testDepositInvoiceList[0].Id, testController.invoice.Id);
	}

	private static testmethod void testAutoRun(){
		setupData();
		createController(testDepositInvoiceList[0]);

		PageReference pr;

		Test.startTest();

			pr = testController.autoRun();

		Test.stopTest();

		System.assert(pr == null);
	}

	private static testmethod void testAutoRunWithIncorrectData(){
		setupData();
		createController(testDepositInvoiceList[0]);
		testController.invoice.Id = Id.valueOf(Deposit_invoice__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

		PageReference pr;

		Test.startTest();

			pr = testController.autoRun();

		Test.stopTest();

		System.assert(pr == null);		
	}

	private static testmethod void testGoBack(){
		setupData();
		createController(testDepositInvoiceList[0]);

		PageReference pr;

		Test.startTest();

			pr = testController.goBack();

		Test.stopTest();

		System.assert(pr != null);
	}
}