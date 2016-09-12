@isTest
private class TestStoredDocsInlineTaskItemController {

    private static ApexPages.StandardController testController;
    private static StoredDocsInlineTaskItemController testStoredDocsInlineTaskItemController;

    private static testMethod void testStoredDocsInlineTaskItemController() {

        Test.setCurrentPageReference(Page.StoredDocsInlineTaskItem);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );

        Test.startTest();
            testStoredDocsInlineTaskItemController = new StoredDocsInlineTaskItemController(testController);
        Test.stopTest();

    }
    
    private static testMethod void testIsShowButton(){
    	Test.setCurrentPageReference(Page.StoredDocsInlineTaskItem);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );
        testStoredDocsInlineTaskItemController = new StoredDocsInlineTaskItemController(testController);
        
        Test.startTest();
        	Boolean testBoolean = testStoredDocsInlineTaskItemController.isShowButton;
        Test.stopTest();
    }
}