@isTest(seeAllData = true)
private class TestCashMatchingHistoryTrigger {
	
	@isTest static void testAppliedFieldsOnProForma() {
	
		c2g__codaCashMatchingHistory__c codaHistory = [SELECT Id, Cash_Applied__c, Credits_Applied__c, Journals_Applied__c
														FROM c2g__codaCashMatchingHistory__c
														WHERE c2g__TransactionLineItem__r.c2g__Transaction__r.Pro_forma_Invoice__c != null
															AND c2g__Period__r.c2g__Closed__c = false
														LIMIT 1];
		codaHistory.Cash_Applied__c = true;
		codaHistory.Credits_Applied__c = true;
		codaHistory.Journals_Applied__c = true;
		UPSERT codaHistory;
	}	
	
}