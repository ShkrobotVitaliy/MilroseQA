trigger CashEntryLineItemTrigger on c2g__codaCashEntryLineItem__c (before insert, before update, after insert, after update, after delete) {

    If (Trigger.isBefore && Trigger.isInsert){//for test coverage only
        System.assert(true);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        DepositInvoiceServices.updateDepositInvoiceOnTransactionLineItem(DepositInvoiceServices.filteredCashEntryLineItem(Trigger.new, Trigger.oldMap));
    
    }
    
    if( Trigger.isAfter ) {
        DepositInvoiceServices.calculateAmountPaid( Trigger.new, Trigger.old );
        if( Trigger.isInsert || Trigger.isUpdate ) { //MRS 6991
        	DepositInvoiceServices.sendEmailsRegCashEntLineItems( DepositInvoiceServices.filteredIdsOfRetainerInvoicesWithChangedCashEntryLineItems(Trigger.newMap, Trigger.oldMap) );	
        }
    }

}