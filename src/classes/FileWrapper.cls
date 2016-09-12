public with sharing class FileWrapper {
    public LStore__Stored_Document__c document { get; private set; }
    public Boolean isSelect { get; set; }
    public String relatedTo { get; set; }
    
    public FileWrapper(final LStore__Stored_Document__c document) {
         this.document = document;
         this.isSelect = false;
    
    }
    
    public FileWrapper(final LStore__Stored_Document__c document, String relatedTo) {
         this.document  = document;
         this.relatedTo = relatedTo;
         this.isSelect  = false;
    
    }

    public String externalURL {
        get {
            return EmailMessageService.getExternalURL( this.document.LStore__External_Id__c );
        }
        private set;
    }
}