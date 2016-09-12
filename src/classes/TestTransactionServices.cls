@isTest
private class TestTransactionServices {
	private static List<Account> testAccountList;
	private static List<c2g__codaInvoice__c> testCodaInvoiceList;
	private static List<c2g__codaTransaction__c>testCodaTransactionList;
	private static User ffUser = TestingUtils.getFFUser ();

	private static testmethod void testUpdateTransactionFieldsFromSalesInvoices(){
		testAccountList = testingUtils.createAccountList(1, null, true);

		Id fakeCodaTransactionId = Id.valueOf(c2g__codaTransaction__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

		testCodaInvoiceList = TestingUtils.createSalesInvoiceList(1, testAccountList[0].Id, null, null, false);
		testCodaInvoiceList[0].c2g__Transaction__c = fakeCodaTransactionId;

		Test.startTest();

			TransactionServices.updateTransactionFieldsFromSalesInvoices(testCodaInvoiceList);

		Test.stopTest();
	}
}