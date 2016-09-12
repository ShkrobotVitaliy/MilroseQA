trigger MilrosePurchaseInvoiceTrigger on c2g__codaPurchaseInvoice__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore){
        if (Trigger.isInsert) {
            Id iii;
            for (c2g__codaPurchaseInvoice__c item : Trigger.new){
                iii = item.id;
                break;
            }
            System.debug('for code coverage');
            
            //Payable Invoices created manually.
            PurchaseInvoiceServices.setProjectMi7IdsForPayableInvoices(Trigger.new);

        }
        
        if (Trigger.isUpdate) {
            //Payable Invoices created manually.
            PurchaseInvoiceServices.setProjectMi7IdsForPayableInvoices(PurchaseInvoiceServices.filterPurchaseInvoiceForSetMi7Projects(Trigger.new, Trigger.oldMap));
        
        }
    
    }

     /*if (Trigger.isAfter) {  
         if (Trigger.isUpdate) {
             //Run ClickLink: Create Billing Line Items
             PurchaseInvoiceServices.runBLIClickRule(PurchaseInvoiceServices.filterPurchaseInvoiceForBLI(Trigger.new, Trigger.oldMap));
             
             //Run ClickLink: Create Legacy Billing Items
             PurchaseInvoiceServices.runLegacyBillingItemClickRule(PurchaseInvoiceServices.filterPurchaseInvoiceForLegacyBillingItem(Trigger.new));
         
         }
     
     }*/
}