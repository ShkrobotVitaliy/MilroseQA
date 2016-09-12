trigger StoredDocumentTrigger on LStore__Stored_Document__c ( before insert, after insert, before update ) {
    if( Trigger.isBefore ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            StoredDocumentServices.cloneRelatedObjectIdField( Trigger.new );
        }
        if( Trigger.isInsert ) {
            ScanRequestServices.copyFieldsFromScanRequest( StoredDocumentServices.filterStoredDocumentsForCopyingFieldsFromScanRequest( Trigger.new ) );
            BillingLineItemServices.setCheckImageAttachedOnRelatedBli( Trigger.new );
        }
    }
    if( Trigger.isInsert ) {
        Map<String, List<LStore__Stored_Document__c>> filteredDocumentsByType = StoredDocumentServices.filterDocumentsByTypes( Trigger.new );
        if( Trigger.isBefore ) {
            StoredDocumentServices.updateName( Trigger.new );
            //StoredDocumentServices.deleteStoredDocForFormItemAfterNewUpload( Trigger.new );
            StoredDocumentServices.updateFormItemForStoreDocument( StoredDocumentServices.filterFormItemForStoreDocument( Trigger.new ) );
            StoredDocumentServices.fillRelatedFieldsInStoredDocuments( filteredDocumentsByType.get( StoredDocumentServices.ACCOUNTING_FILE_TYPE ) );
            StoredDocumentServices.copyChangeOrderDocumentType( filteredDocumentsByType.get( StoredDocumentServices.ACCOUNTING_FILE_TYPE ) );
            StoredDocumentServices.updateProjectLabelDocumentFields( filteredDocumentsByType.get( StoredDocumentServices.PROJECT_LABEL_DOCUMENT ) );
        }
        if( Trigger.isAfter ) {
            FormItemsServices.attachStoredDocumentToFormItem( filteredDocumentsByType.get( StoredDocumentServices.FORMS_FILE_TYPE ) );
            AttachmentServices.deleteAttachmentsByName( StoredDocumentServices.filterStoredDocumentsToFindRelatedAttachmentsByNames( Trigger.new ) );
            StoredDocumentServices.deleteDocusignSignedDocsIfOnPaperExists( StoredDocumentServices.filterStoredDocumentsToFindSignedOrOnPaperAttachments( Trigger.new ) );
        }
    }

}