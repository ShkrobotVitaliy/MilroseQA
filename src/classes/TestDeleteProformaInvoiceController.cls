@isTest
private class TestDeleteProformaInvoiceController {
	private static Integer NUMBER_TO_CREATE_ACCOUNT = 2;
	private static Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 3;


	private static List<Account> testAccountList;
	private static List<Contact> testContactList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Pro_forma_Invoice__c> testProformaInvoiceList;

	private static PageReference testPage;
	private static ApexPages.StandardController testStandardController;
	private static DeleteProformaInvoiceController testController;

	private static void prepareDataForTest(Boolean clFFAInvoiceCreatedValue){
		testAccountList = TestingUtils.createAccountList (NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactList = new List<Contact>();
		for (Account accountItem : testAccountList){
			testContactList.addAll( TestingUtils.createContactList(1, accountItem.Id, false ) );
		}
		insert testContactList;
		testRegionList = TestingUtils.createRegionList (1, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(1, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, true);

		testProformaInvoiceList = TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testContactList[0].AccountId, testContactList[0].Id,
																		 testBuildingList[0].Id, false);
		for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
			proformaInvoiceItem.cl_FFA_Invoice_Created__c = clFFAInvoiceCreatedValue;
		}
		insert testProformaInvoiceList;
	}

	private static void preparePageController (Pro_Forma_Invoice__c proformaInvoiceItem){
		testPage = Page.DeleteProformaInvoice;
		Test.setCurrentPage(testPage);
		testStandardController = new ApexPages.StandardController(proformaInvoiceItem);
		testController = new DeleteProformaInvoiceController(testStandardController);
	}

	private static testmethod void testInitController(){
		prepareDataForTest(true);

		Test.startTest();
			preparePageController(testProformaInvoiceList[0]);
		Test.stopTest();

		System.assert(testController.isValid);
	}

	private static testmethod void testgoBack(){
		prepareDataForTest(true);
		preparePageController(testProformaInvoiceList[0]);

		PageReference pr = null;

		Test.startTest();
			pr = testController.goBack();
		Test.stopTest();

		System.assert(testController.isValid);
		System.assert(pr != null);
	}

	private static testmethod void testValidateAndDeleteWithFFInvoice(){
		prepareDataForTest(true);
		preparePageController(testProformaInvoiceList[0]);

		Test.startTest();

			testController.validateAndDelete();

		Test.stopTest();

		List<Pro_forma_Invoice__c> resultList = [SELECT Id FROM Pro_forma_Invoice__c WHERE Id = : testProformaInvoiceList[0].Id];
		System.assert (!resultList.isEmpty());
		System.assertEquals (1, resultList.size());
	}

	private static testmethod void testValidateAndDeleteWithoutFFInvoice(){
		prepareDataForTest(false);
		preparePageController(testProformaInvoiceList[0]);

		Test.startTest();

			testController.validateAndDelete();

		Test.stopTest();

		List<Pro_forma_Invoice__c> resultList = [SELECT Id FROM Pro_forma_Invoice__c WHERE Id = : testProformaInvoiceList[0].Id];
		System.assert (resultList.isEmpty());
	}
}