public with sharing class StoredDocsInlineUploadFormController {
	public static String ERROR_DELETING_FORM_ITEM = 'Error Occurred when deleting the Form Item Record';
	public Form_Item__c formItem {get; set;}
	public Form_Meta_Data_Object_1__c formMetaDataObject {get; set;}

	public StoredDocsInlineUploadFormController(ApexPages.StandardController controller) {
		String formItemId = ApexPages.currentPage().getParameters().get('formItemId');
		List<Form_Item__c> formItems = new List<Form_Item__c>([SELECT Id, Form_Name__c, Short_Form_Name__c, Form_Id__c, Subject__c, Municipality__c, Region__c, Region__r.Name
				                                     FROM Form_Item__c
				                                     WHERE Id =: formItemId]);
		formMetaDataObject = (Form_Meta_Data_Object_1__c)controller.getRecord();
        if( formItems.isEmpty() ){
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Form item is not valid!' ) );
        }else{
        	formItem = formItems[0];
        }

    }

    public void updateFormItem(){
        try {
            upsert formItem;
        } catch( DmlException ex ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error Occurred when upserting a Form Item Record' ) );
        }
    }

    public void cancelFormUpload(){
        try {
            //NOTE: formMetaDataToInsert will be deleted automaticaly
            if( formItem.Id != null ) delete formItem;
        } catch( DmlException ex ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ERROR_DELETING_FORM_ITEM ) );
        }
    }

    public String backToTaskUrl{ 
        get{
            return URL.getSalesforceBaseUrl().toExternalForm() + '/apex/CompleteFormsTaskItem?id=' + formMetaDataObject.Task_Item__c;
        }
        private set;
    }

}