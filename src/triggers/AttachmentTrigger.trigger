trigger AttachmentTrigger on Attachment( before insert, after insert ) {

    if( Trigger.isInsert ) {
        if( Trigger.isBefore ) {
            AttachmentServices.renameSignedAttachments( AttachmentServices.filterSignedAttachmentsForRenaming( Trigger.new ) );
            StoredDocumentServices.createFoldersForStoredDocsFromAttachments( AttachmentServices.filterAttachmentIdsForMovingToStoredDocuments( Trigger.new, true ).keySet() );
        }
        if( Trigger.isAfter ) {
            Map<Id, List<Id>> filteredAttachmentIdsForMovingToStoredDocuments = AttachmentServices.filterAttachmentIdsForMovingToStoredDocuments( Trigger.new, false );
            AttachmentServices.moveAttachmentsToStoredDocuments( filteredAttachmentIdsForMovingToStoredDocuments );
            AttachmentServices.deleteUnneededAttachments( AttachmentServices.filterUnneededAttachmentsForDeletion( Trigger.new, filteredAttachmentIdsForMovingToStoredDocuments ) );
        }
    }

}