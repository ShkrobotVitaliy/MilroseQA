trigger ProFormaInvoiceTrigger on Pro_forma_Invoice__c ( before insert, after insert, before update, after update, before delete, after delete ){
    if( Trigger.isBefore ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            ProformaInvoiceServices.restrictFFAInvoiceCreation( Trigger.new );
            ProformaInvoiceServices.preventCheckHideFromRecap(Trigger.new, Trigger.oldMap); // MRS 7140
        }
        
        if (Trigger.isUpdate) {
            ProformaInvoiceServices.validationCreateFFACreditNote(Trigger.newMap , Trigger.old);
        
        }
    
    }
    if( Trigger.isAfter ) {
        if( Trigger.isUpdate || Trigger.isInsert ) {
            ProjectProfileServices.calculateOutstandingAmountsByDate( ProformaInvoiceServices.filterProFormaInvoicesForOutstandingAmountsCalculation( Trigger.new, Trigger.oldMap ) );
        }
        if (Trigger.isUpdate){
            ProformaInvoiceServices.updateBillingLIAddressContactValues(ProformaInvoiceServices.filteredProFormaInvoiceWithChangedAddressContact(Trigger.new, Trigger.oldMap));

			//MRS-6549
            ProformaInvoiceServices.updateBillingLIHideFromRecap(ProformaInvoiceServices.filteredProFormaInvoiceWithHideFromRecap(Trigger.new, Trigger.oldMap));
        }
        if( Trigger.isUpdate || Trigger.isInsert){ //MRS 7558
            PurchaseOrderServices.calculatePurchaseOrderTotals( ProformaInvoiceServices.filterPurchaseOrdersForTotalAmount( Trigger.newMap, Trigger.oldMap ) );
        }
    }
    
    if (Trigger.isDelete && Trigger.isBefore){
        BillingLineItemServices.updateBLIAfterProformaDeleted( Trigger.oldMap );
    }
}