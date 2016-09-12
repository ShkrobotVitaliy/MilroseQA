trigger BillingLineItemTrigger on Billing_Line_Item__c (before insert, before update, after insert, after update, after delete) {

    if (Trigger.isBefore) {
        if(Trigger.isBefore || Trigger.isUpdate) { // MRS 7140
            BillingLineItemServices.preventCheckHideFromRecap(Trigger.new, Trigger.oldMap);
        }
        BillingLineItemServices.populatePayableReimbursableBLIPurchaseOrder( Trigger.new ); // MRS 7025
        if (Trigger.isInsert) {
            MilroseDevHelper.setWorkType( Trigger.new );
            BillingLineItemServices.setBillingLineItemIsActive(Trigger.new); //MRS-7459
            BillingLineItemServices.deactivateIsReimbursableNoAfterPrebiled( Trigger.new ); //MRS-6242
            BillingLineItemServices.setRequiresCheckImageField( Trigger.new ); //MRS-6029
        }
		BillingLineItemServices.populatePOForHiddenBLIs( Trigger.new );
        BillingLineItemServices.updateContactsAmountsAndPO( BillingLineItemServices.filteredBLIWithChangedProjectPoOrAmounts(Trigger.new, Trigger.oldMap), Trigger.oldMap );

    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            ProformaInvoiceServices.totalBilledAmount( BillingLineItemServices.filterBillingLineItemTotalAmountForProformaInvoice(Trigger.new, Trigger.oldMap), Trigger.newMap );
            BillingLineItemServices.setDepositOnAccountCheckboxForProformaInvoices( BillingLineItemServices.filterBlisForSettingDepositOnAccountCheckbox ( Trigger.new, Trigger.oldMap ) );

            //Recalculate Total Commissionable Amount
            BillingLineItemServices.updateTotalCommissionableAmount( BillingLineItemServices.filteredItemForTotalCommissionableAmount( Trigger.new ) );
        }

        if( Trigger.isInsert ) {
            //vvv needs to be at the end to forward all field changes to a cloned BLI for Check Processing Fee
            BillingLineItemServices.createCheckProcessingFeeBli( BillingLineItemServices.filterBlisForCreatingCheckProcessingBli( Trigger.new ) );
        }

        if (Trigger.isDelete) {
            //Recalculate Total Commissionable Amount
            BillingLineItemServices.updateTotalCommissionableAmount( BillingLineItemServices.filteredItemForTotalCommissionableAmount( Trigger.old ) );
        }
		Set<Id> poIdSet = BillingLineItemServices.filteredIdxOfPOsToUpdate(Trigger.newMap, Trigger.oldMap);
        PurchaseOrderServices.updatePurchaseOrdersData( poIdSet ); //MRS-6939 Update related PO's data on basis of corrected BLIs
		PurchaseOrderServices.calculatePurchaseOrderTotals( poIdSet ); //MRS 7570
        //MRS-7067
        BillingLineItemServices.updateBillingDateAmount( BillingLineItemServices.filteredBLIWithBillingDate( Trigger.new, Trigger.oldMap ), Trigger.isDelete );
        //MRS-6237, MRS-7262
        if ( Trigger.isUpdate) {
        	BillingLineItemServices.setPFItoHiddenBLIs( BillingLineItemServices.filteredBLIWithNewPFIpopulated( Trigger.new, Trigger.oldMap ), BillingLineItemServices.filteredBLIWithChangedActive( Trigger.new, Trigger.oldMap ) );
        }
    }
}