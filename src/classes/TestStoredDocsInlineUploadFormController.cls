@isTest
private class TestStoredDocsInlineUploadFormController {
    private static PageReference testPage;
    private static StoredDocsInlineUploadFormController testController;
    private static ApexPages.StandardController testStandardController;

    private static Task_Item__c testTaskItem;
    private static Form_Template__c testFormTemplate;
    private static Form_Item__c testFormItem;
    private static Form_Meta_Data_Object_1__c testMetadataObject;
    
    
    private static void preparePageController(Form_Meta_Data_Object_1__c metadataObject){
        testPage = Page.StoredDocsInlineUploadForm;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('formItemId', testFormItem.Id);  
        testStandardController = new ApexPages.standardController(metadataObject);
        testController = new StoredDocsInlineUploadFormController(testStandardController);
    }

    private static void setupData(){
        testTaskItem = TestingUtils.createTaskItemList(1, true)[0];
        testFormItem = TestingUtils.createFormItemList(1, true)[0];
        testMetadataObject = TestingUtils.createFormMetaDataObject1List(1, testFormItem.Id, true)[0];
    }

    private static testmethod void testInitCompleteFormsTaskExtension(){
        setupData();
        Test.startTest();
            preparePageController(testMetadataObject);
        Test.stopTest();

        System.assert(testController != null, 'Test Controller is null');
        System.assert(!String.isBlank(testController.backToTaskUrl), 'Back to Task Item URL is empty');
        System.assert(!testController.backToTaskUrl.contains('StoredDocsInlineUploadForm'), 'Back to Task Item URL does not contains StoredDocsInlineUploadForm part');
    }
    
    private static testmethod void testUpdateFormItem(){
        setupData();
        preparePageController(testMetadataObject);
        testFormItem.Form_Name__c = 'Test Name';
        Test.startTest();
            testController.updateFormItem();
        Test.stopTest();
    }
    
    private static testmethod void testCancelFormUpload(){
        setupData();
        preparePageController(testMetadataObject);
        Test.startTest();
            testController.cancelFormUpload();
        Test.stopTest();
        List<Form_Item__c> formItemsFromDB = new List<Form_Item__c>([Select Id from Form_Item__c where id =: testFormItem.Id]);
        List<Form_Meta_Data_Object_1__c> formMetaObjectFromDB = new List<Form_Meta_Data_Object_1__c>([Select Id from Form_Meta_Data_Object_1__c where id =: testMetadataObject.Id]);
        System.assert(formItemsFromDB.isEmpty(), 'From Item has not been deleted');
        System.assert(formMetaObjectFromDB.isEmpty(), 'From Meta Data Object has not been deleted');
    }
}