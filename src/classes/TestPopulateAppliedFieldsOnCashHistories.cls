@isTest
private class TestPopulateAppliedFieldsOnCashHistories {
	
	@isTest(SeeAllData = true) static void testBatchTestPopulateAppliedFieldsOnCashHistories() {
		
		List<c2g__codaYear__c> years = [SELECT c2g__Status__c FROM c2g__codaYear__c];
		for( c2g__codaYear__c year : years) year.c2g__Status__c = 'Open';
		Database.update( years, false );

		List<c2g__codaPeriod__c> periods = [SELECT c2g__Closed__c FROM c2g__codaPeriod__c];
		for(c2g__codaPeriod__c period : periods) period.c2g__Closed__c = false;
		Database.update( periods, false );

		List<c2g__codaCashMatchingHistory__c> cashHistoriesList = [SELECT Cash_Applied__c, Credits_Applied__c, Journals_Applied__c, Document_Number__c, c2g__MatchingReference__c,
   																   c2g__Period__r.c2g__Closed__c
   																   FROM c2g__codaCashMatchingHistory__c
   																   WHERE c2g__Period__r.c2g__Closed__c = false
   																   LIMIT 1];

		Test.startTest();
			PopulateAppliedFieldsOnCashHistories pafoch = new PopulateAppliedFieldsOnCashHistories();
			pafoch = new PopulateAppliedFieldsOnCashHistories('SELECT Id FROM c2g__codaMatchingReference__c WHERE Id=' + '\''+ cashHistoriesList[0].c2g__MatchingReference__c +'\'');
			Database.executeBatch(pafoch);
		Test.stopTest();
	}

}