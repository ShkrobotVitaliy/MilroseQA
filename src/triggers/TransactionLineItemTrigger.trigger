trigger TransactionLineItemTrigger on c2g__codaTransactionLineItem__c (before insert, before update, after insert, after update, after delete) {
    if( Trigger.isBefore ) {
        if ( (Trigger.isInsert || Trigger.isUpdate) && !TransactionLineItemServices.isUpdateAfterInsert) {
            TransactionLineItemServices.populateProjectProfileLookup( Trigger.new );
            
        }
    }
    if( Trigger.isAfter ) {
        if( (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete) && !TransactionLineItemServices.isUpdateAfterInsert) {
            TransactionLineItemServices.calculateAmountRemaining( Trigger.new, Trigger.old );
        }
        
        if (Trigger.isInsert || Trigger.isUpdate) {
            TransactionLineItemServices.updateCashEntryLineItemLookup(Trigger.newMap);
        
        }
    
    }

}