@isTest
private class TestPDFFormGenerator {
	/*private static final Integer NUMBER_TO_CREATE = 5;
	private static List <Form_Item__c> testFormItemList;
	private static ApexPages.StandardController controller;
	private static PDFFormGenerator pdfGenerator;
	private final static String ddpName = 'UploadTest';
	private final static String deliveryMethod = 'Attach';
	private static Loop__DDP_Integration_Option__c testLoopDDPIntegrationOption;
	private static Loop__DDP__c testLoopDDP;
	private static Service_Item__c testServiceItem;

	private static void setUp(){
		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE, true);	
		testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0]; 
			testLoopDDP.Name = ddpName;
			insert testLoopDDP;
		testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, false)[0];
			testLoopDDPIntegrationOption.Name = deliveryMethod;
			insert testLoopDDPIntegrationOption;
		testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true)[0];	 
	}

	private static void initilliazeClass(){
		pdfGenerator = new PDFFormGenerator(new FormSample_sve(new ApexPages.StandardController(testFormItemList[0])));
	}

	private static testMethod void testPDFFormGenerator(){
		setUp();

		Test.startTest();
			initilliazeClass();
		Test.stopTest();
	}

	private static testMethod void testUpdateDocAndDdp(){
		setUp();
		initilliazeClass();

		Test.startTest();
			pdfGenerator.updateDocAndDdp();
		Test.stopTest();
	}

	private static testMethod void testSendPdfViaApex(){
		setUp();
		initilliazeClass();
		PDFFormGenerator.serviceItemId = String.valueOf(testServiceItem.Id);

		Test.startTest();
			PDFFormGenerator.sendPdfViaApex();
		Test.stopTest();
	}*/
}