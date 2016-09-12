public with sharing class ServiceItemGeneratedFormsExtension {

    private final Service_Item__c serviceItem;
    public List<LStore__Stored_Document__c> lStoreDocumentsForDisplay {get; set;}    
    public String downloadPdfUrl { get; set; }    
    public string selectedFormItemId { get; set; }

    public ServiceItemGeneratedFormsExtension(ApexPages.StandardController controller) {
        serviceItem = (Service_Item__c)controller.getRecord();
    }
    
    public void getStoreDocuments() {
        if(String.isBlank(serviceItem.id)) return;
        PageReference pr;
        PageReference prFileList;
        lStoreDocumentsForDisplay = new List<LStore__Stored_Document__c>();
        Set<Id> fmdoIds = new Set<Id>();
        for( Form_Meta_Data_Object_1__c fmdo : [ Select Id From Form_Meta_Data_Object_1__c 
                                                 Where Service_Item__c = : serviceItem.id AND Task_Item__r.RecordType.Name = : TaskItemServices.COMPLETE_FORMS_TASK_NAME ] ) {
            fmdoIds.add( fmdo.Id );
        }

        lStoreDocumentsForDisplay = [ SELECT RecordType.DeveloperName, RecordTypeId, LStore__Related_Object_Id__c, LStore__File_Name__c, Id,
                                             LStore__Type_Calc__c, CreatedDate, LStore__Description__c, CreatedById, CreatedBy.Alias,
                                             LStore__File_Size_Calc__c
                                      FROM LStore__Stored_Document__c
                                      WHERE RecordTypeId != : StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                      AND Related_Object_Id__c IN : fmdoIds ];
    }

    public PageReference openPDF(){
        downloadPdfUrl = '/apex/lstore__storedDocViewRestore?id=' + selectedFormItemId + '&action=download&contentType=redirect&retURL=/' + serviceItem.id;
        return null;
    }

}