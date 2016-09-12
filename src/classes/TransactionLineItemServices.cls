public class TransactionLineItemServices {
    public final static String ACCOUNT_LINE_TYPE = 'Account';
    public final static String AVAILABLE_MATCHING_STATUS = 'Available';
    
    public static Boolean isUpdateAfterInsert = false;
    
    public static void populateProjectProfileLookup( List<c2g__codaTransactionLineItem__c> newItems) {
        Set<Id> transactionIds = new Set<Id>();
        for( c2g__codaTransactionLineItem__c tli : newItems ) {
            transactionIds.add( tli.c2g__Transaction__c );
        }
        transactionIds.remove(null);
        Map<Id, c2g__codaTransaction__c> transactionIdToTransaction = new Map<Id, c2g__codaTransaction__c>( [SELECT Id, Pro_forma_Invoice__r.Project_Profile__c
                                                                                                             FROM c2g__codaTransaction__c
                                                                                                             WHERE Id IN : transactionIds] );
        for( c2g__codaTransactionLineItem__c tli : newItems ) {
            tli.Project_Profile__c = transactionIdToTransaction.get(tli.c2g__Transaction__c) != null ? transactionIdToTransaction.get(tli.c2g__Transaction__c).Pro_forma_Invoice__r.Project_Profile__c : null;
        }
    }
    
    public static void calculateAmountRemaining( List<c2g__codaTransactionLineItem__c> newItems, List<c2g__codaTransactionLineItem__c> oldItems ) {
        Map<Id, Deposit_Invoice__c> depositInvoicesToUpdate = new Map<Id, Deposit_Invoice__c>();
        if( newItems != null ) {
            for( c2g__codaTransactionLineItem__c tli : newItems ) {
                    depositInvoicesToUpdate.put( tli.Deposit_Invoice__c, new Deposit_Invoice__c( Id = tli.Deposit_Invoice__c,
                                                                                                 Amount_Remaining__c = 0.00 ) );
            }
        }
        if( oldItems != null ) {
            for( c2g__codaTransactionLineItem__c tli : oldItems ) {
                    depositInvoicesToUpdate.put( tli.Deposit_Invoice__c, new Deposit_Invoice__c( Id = tli.Deposit_Invoice__c,
                                                                                                 Amount_Remaining__c = 0.00 ) );
            }
        }
        depositInvoicesToUpdate.remove(null);
        for( AggregateResult aggItem : [ SELECT Deposit_Invoice__c, SUM(c2g__HomeOutstandingValue__c)
                                         FROM c2g__codaTransactionLineItem__c
                                         WHERE Deposit_Invoice__c IN : depositInvoicesToUpdate.keySet()
                                         GROUP BY Deposit_Invoice__c] ) {
            depositInvoicesToUpdate.put( (Id)aggItem.get('Deposit_Invoice__c'), new Deposit_Invoice__c( Id = (Id)aggItem.get('Deposit_Invoice__c'),
                                                                                                        Amount_Remaining__c = -1 * (Decimal)aggItem.get('expr0') ) );
        }
        try {
            UPDATE depositInvoicesToUpdate.values();
        } catch( dmlException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                //KDI: Removed an error since TLIs are generated via FF and we don't want them to disappear because of an error on Deposit Invoice
                //depositInvoicesToUpdate.values()[i].addError( 'Can not update Deposit Invoice Totals. ' + dmlEx.getMessage() );    
            }
        }
    }    
    
    public static void updateCashEntryLineItemLookup(Map<Id, c2g__codaTransactionLineItem__c> transactionLineItems) {
        if (TransactionLineItemServices.isUpdateAfterInsert) {
            return;
        
        }
        
        List<c2g__codaTransactionLineItem__c> transactionToUpdate = new List<c2g__codaTransactionLineItem__c>();
        
        for (c2g__codaTransactionLineItem__c lineItem : TransactionLineItemServices.getTransactionLineItemsByIds(transactionLineItems.keySet())) {
            if (lineItem.Cash_Entry_Cash_Entry_Line_Item_Id__c instanceof Id && lineItem.Cash_Entry_Line_Item__c != Id.valueOf(lineItem.Cash_Entry_Cash_Entry_Line_Item_Id__c)) {
                lineItem.Cash_Entry_Line_Item__c = Id.valueOf(lineItem.Cash_Entry_Cash_Entry_Line_Item_Id__c);
                transactionToUpdate.add(lineItem);
                
            }
        
        }
        
        TransactionLineItemServices.isUpdateAfterInsert = true;
        if (transactionToUpdate.size() > 0) {
            update transactionToUpdate;
        
        }
        
    }
    
    public static List<c2g__codaTransactionLineItem__c> getTransactionLineItemsByIds(Set<Id> lineItemIds) {
        if (null == lineItemIds || lineItemIds.isEmpty()) {
            return new List<c2g__codaTransactionLineItem__c>();
        
        }
    
        return new List<c2g__codaTransactionLineItem__c>([SELECT Name, Id, Deposit_Invoice__c, Cash_Entry_Line_Item__c, Cash_Entry_Cash_Entry_Line_Item_Id__c 
                                                          FROM c2g__codaTransactionLineItem__c
                                                          WHERE Id IN: lineItemIds]);
    
    }
    
    public static List<c2g__codaTransactionLineItem__c> getTransactionLineItemsByCashLineItemIds(Set<Id> cashLineItemIds) {
        if (null == cashLineItemIds || cashLineItemIds.isEmpty()) {
            return new List<c2g__codaTransactionLineItem__c>();
        
        }
    
        return new List<c2g__codaTransactionLineItem__c>([SELECT Name, Id, Deposit_Invoice__c, Cash_Entry_Line_Item__c 
                                                          FROM c2g__codaTransactionLineItem__c
                                                          WHERE Cash_Entry_Line_Item__c IN: cashLineItemIds]);
    
    }

}