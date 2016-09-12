trigger PurchaseOrderTrigger on Purchase_Order__c ( before insert, before update, after insert, after update ) {
    if ( Trigger.isBefore ){
        if ( Trigger.isInsert || Trigger.isUpdate ) {
            PurchaseOrderServices.populateProjectProfileOnPO( Trigger.new );
        }
    }

    if( Trigger.isAfter ){
        if( Trigger.isInsert ){
            StoredDocumentServices.createFolders(StoredDocumentServices.filterIfFoldersCreated(Trigger.newMap.keySet()));
        }

	if( !PurchaseOrderServices.preventDoubleLinkingBLIsToPO && !BillingLineItemServices.serviceTriggerWillAttachPO ){
		BillingLineItemServices.linkExistingBLIToNewPurchaseOrders(Trigger.new);
	}

	if( Trigger.isUpdate ){
            ProformaInvoiceServices.generateProformaInvoicesPDF( PurchaseOrderServices.filterInvoicesWithChangedPO( Trigger.new, Trigger.oldMap) );
            //BillingLineItemServices.linkExistingReimbBLIToPurchaseOrdersWithIncreasedAmount( PurchaseOrderServices.filterPOwithIncreasedAmount( Trigger.new, Trigger.oldMap) );//MRS-7026
        }
    }
}