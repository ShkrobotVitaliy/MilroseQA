public with sharing class ProposalDrawingsStoredDocsContExt {
    public Id parentId { get; set; }
    public List<LStore__Stored_Document__c> drawingsList { get; set; }

    public Boolean testFlag {get; set;}

    public ProposalDrawingsStoredDocsContExt( ApexPages.StandardController controller ) {
        parentId = ApexPages.currentPage().getParameters().get( 'parentId' );
        if( String.isNotBlank( parentId ) ) {
            drawingsList = StoredDocumentServices.getStoredDocumentList( parentId );
        }
        
        testFlag = true;
    }
}