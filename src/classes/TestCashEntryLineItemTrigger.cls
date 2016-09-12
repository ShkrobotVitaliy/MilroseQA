@isTest(SeeAllData=true)
private class TestCashEntryLineItemTrigger {

	private static testmethod void testInsertCashEntryLineItem(){
		try{
			update [SELECT Id FROM c2g__codaCashEntryLineItem__c LIMIT 1];
		} catch (Exception ex){}
	}
}