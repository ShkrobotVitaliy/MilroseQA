@isTest
private class TestCreateDepositDetailReportController {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
	private static final Integer NUMBER_TO_CREATE_DEPOSIT_INVOICE = 3;

	private static final String DEPOSIT_DETAIL_VALUE = 'Deposit Detail';

	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Deposit_invoice__c> testDepositInvoiceList;
	private static List<DDP_Helper__c> testDDPHelper;
	private static CreateDepositDetailReportController testController;
	private static ApexPages.StandardController standardController;
	private static PageReference testPageReference;

	private static void setupData(Integer numberToCreate, Boolean doInsert){
		testProjectProfileList = TestingUtils.createProjectProfileForTest(1, true);
		testDepositInvoiceList = TestingUtils.createDepositInvoiceList(numberToCreate, null, testProjectProfileList[0].Id, doInsert);
	}

	private static void createController(Deposit_invoice__c depositInvoice){
		Test.setCurrentPage(Page.CreateDepositDetailReport);
		standardController = new ApexPages.StandardController(depositInvoice);
		testController = new CreateDepositDetailReportController(standardController);
	}

	private static testmethod void testInitController (){
		setupData(NUMBER_TO_CREATE_DEPOSIT_INVOICE, true);

		Test.startTest();

			createController(testDepositInvoiceList[0]);

		Test.stopTest();

		System.assert(testController.isValid);
	}

	private static testmethod void testGoBack(){
		setupData(NUMBER_TO_CREATE_DEPOSIT_INVOICE, true);

		createController(testDepositInvoiceList[0]);

		Test.startTest();

			testPageReference = testController.goBack();

		Test.stopTest();

		System.assert (testPageReference != null);
	}

	private static testmethod void testAutoRunWithoutDDPHelper(){
		setupData(NUMBER_TO_CREATE_DEPOSIT_INVOICE, true);

		createController(testDepositInvoiceList[0]);

		Test.startTest();

			testController.autoRun();

		Test.stopTest();

		System.assert(testController.isValid);

	}

	/*@isTest(seeAllData=true)
	private static void testAutoRun(){
		setupData(NUMBER_TO_CREATE_DEPOSIT_INVOICE, true);

		testDDPHelper = new List<DDP_Helper__c>();
		for (Deposit_Invoice__c depositInvoiceItem : testDepositInvoiceList){
			for (DDP_Helper__c ddpHelperItem : TestingUtils.createDDPHelperList(1, false)){
				ddpHelperItem.Deposit_Invoice__c = depositInvoiceItem.Id;
				ddpHelperItem.Type__c = DEPOSIT_DETAIL_VALUE;
				testDDPHelper.add(ddpHelperItem);
			}
		}
		insert testDDPHelper;

		List<c2g__codaCashMatchingHistory__c> tm = [SELECT Id, c2g__TransactionLineItem__c
											        FROM c2g__codaCashMatchingHistory__c LIMIT 1];
		if( !tm.isEmpty() ) {
			c2g__codaTransactionLineItem__c tl = new c2g__codaTransactionLineItem__c(Id = tm[0].c2g__TransactionLineItem__c, Deposit_Invoice__c = testDepositInvoiceList[0].Id);
			update tl;
		}

		createController(testDepositInvoiceList[0]);

		Test.startTest();

			testController.autoRun();

		Test.stopTest();

		System.assert(testController.isValid);
	}*/
}