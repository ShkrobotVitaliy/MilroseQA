trigger MilrosePurchaseInvoiceExpenseLineItemTrigger on c2g__codaPurchaseInvoiceExpenseLineItem__c (after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            PurchaseInvoiceServices.updatePurchaseInvoiceDimensions(PurchaseInvoiceServices.getPurchaseInvoiceIdToPurchaseLineItem(Trigger.new));
        
        }
    
    }
}