trigger LegacyProformaInvoiceTrigger on Legacy_Pro_forma_Invoice__c (before delete, before update) {
    
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            LegacyProformaInvoiceServices.validationCreateFFACreditNote(Trigger.newMap, Trigger.old);
        
        }
    
        if (Trigger.isDelete) {
            LegacyProformaInvoiceServices.unbilledLegacyItemForLegacyInvoices(Trigger.oldMap);
        
        }
    
    }

}