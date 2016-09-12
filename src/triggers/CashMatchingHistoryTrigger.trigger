trigger CashMatchingHistoryTrigger on c2g__codaCashMatchingHistory__c (after insert, after update, after delete) {

	if(Trigger.isAfter) {
		
		ProformaInvoiceServices.updateInvoiceCashMatchingFields(CashMatchingHistoryServices.invoicesWithChangedAppliedFields(Trigger.new, Trigger.oldMap));
	    
	}
}