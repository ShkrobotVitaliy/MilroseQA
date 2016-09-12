public with sharing class CreateFormItemPDFController {
    private final String recordId = ApexPages.currentPage().getParameters().get('id');
    
    private final static String DDP_NAME = 'Generate PDF Form';
    private final static String DELIVERY_METHOD = 'Attach';
    public SObject formMetaData;
    
    public Boolean isValid { get; set; }
    
    private final String METADATA_OBJECT_1 = 'Form_Meta_Data_Object_1__c';
    
    public CreateFormItemPDFController(){
        isValid = true;
    }

    public PageReference runDdp() {
        formMetaData = getRecord( METADATA_OBJECT_1 );

        String ddpName;

        if( ((Form_Meta_Data_Object_1__c)formMetaData).Form_Item__r.Form_Template__r.DDP_Name__c != null ){
            ddpName = ((Form_Meta_Data_Object_1__c)formMetaData).Form_Item__r.Form_Template__r.DDP_Name__c;
        } else {
            ddpName = DDP_NAME;
        }

        formMetaData.put('Version__c', Integer.valueOf( formMetaData.get( 'Version__c' ) ) + 1 );
        update formMetaData;

        DDPRequest request = new DDPRequest();

        request.addConfiguration( recordId,
                                  ddpName,
                                  DELIVERY_METHOD );
        request.sendRequest();
        return goBack();
    }
    
    public PageReference goBack() {
        return new PageReference('/' + getTaskId( formMetaData, METADATA_OBJECT_1 ));
    }
    
    // ----------------------Private aria -----------------
    private Id getTaskId( SObject formMetaData, String objectName ){
        Id taskItemId;
        if( objectName.equals( METADATA_OBJECT_1 ) ){
            taskItemId = ((Form_Meta_Data_Object_1__c)formMetaData).Task_Item__c;
        }
        return taskItemId;
    }

    private SObject getRecord( String objectName ){
        SObject retRecord;
        if( objectName.equals( METADATA_OBJECT_1 ) ){
            retRecord = [ Select Id, Task_Item__c, Form_PDF_Name__c, Version__c, Form_Item__r.Form_Template__r.DDP_Name__c From Form_Meta_Data_Object_1__c Where Id = :recordId];
        }
        return retRecord;
    }
}