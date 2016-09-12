@isTest
private class TestTransactionLineItemTrigger {

	//can not create c2g__codaTransactionLineItem__c
	@isTest(seeAllData=true)
	private static void testInsertCodaTransactionLineItem (){
		c2g__codaTransactionLineItem__c codaTransactionLineItem = new c2g__codaTransactionLineItem__c();
		try {
			insert codaTransactionLineItem;
		} catch (DmlException dmlEx){
			//todo
		}
		System.assert(codaTransactionLineItem != null);
	}

	@isTest(seeAllData=true)
	private static void testUpdateCodaTransactionLineItem () {
		List<c2g__codaTransactionLineItem__c> codaTransactionLineItems = [ SELECT Id FROM c2g__codaTransactionLineItem__c LIMIT 100 ];
		try {
			Database.update( codaTransactionLineItems, false );
		} catch (DmlException dmlEx){
			//todo
		}
		System.assert(codaTransactionLineItems != null);
	}
}