public without sharing class CashMatchingHistoryServices {
	
	public static Set<Id> invoicesWithChangedAppliedFields(List<c2g__codaCashMatchingHistory__c> newHistoriesList,
																	Map<Id, c2g__codaCashMatchingHistory__c> oldHistoriesMap) {
		Set<Id> setInvoicesIdx = new Set<Id>();
		Set<Id> setTransactionsLinesIdx = new Set<Id>();
		for(c2g__codaCashMatchingHistory__c cmHistory : newHistoriesList) {
			if((oldHistoriesMap == null || oldHistoriesMap.get(cmHistory.Id) == null ||
				cmHistory.Cash_Applied__c != oldHistoriesMap.get(cmHistory.Id).Cash_Applied__c ||
				cmHistory.Credits_Applied__c != oldHistoriesMap.get(cmHistory.Id).Credits_Applied__c ||
				cmHistory.Journals_Applied__c != oldHistoriesMap.get(cmHistory.Id).Journals_Applied__c) && !String.isBlank(cmHistory.c2g__TransactionLineItem__c)) {
					setTransactionsLinesIdx.add(cmHistory.c2g__TransactionLineItem__c);
			}
		}
		if((newHistoriesList == null || newHistoriesList.isEmpty()) && oldHistoriesMap != null) {
			for(c2g__codaCashMatchingHistory__c cmHistory : oldHistoriesMap.values()) {
				if(!String.isBlank(cmHistory.c2g__TransactionLineItem__c)) {
					setTransactionsLinesIdx.add(cmHistory.c2g__TransactionLineItem__c);
				}
			}
		}
		if(!setTransactionsLinesIdx.isEmpty()) {
			for(c2g__codaTransactionLineItem__c transactionLineItem : [SELECT c2g__Transaction__r.Pro_forma_Invoice__c
																		FROM c2g__codaTransactionLineItem__c
																		WHERE Id IN : setTransactionsLinesIdx]) {
				if(!String.isBlank(transactionLineItem.c2g__Transaction__r.Pro_forma_Invoice__c)) setInvoicesIdx.add(transactionLineItem.c2g__Transaction__r.Pro_forma_Invoice__c);
			}
		}
		return setInvoicesIdx;
	}
}