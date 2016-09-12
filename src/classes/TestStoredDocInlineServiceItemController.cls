@isTest
private class TestStoredDocInlineServiceItemController {

    private static ApexPages.StandardController testController;
    private static StoredDocInlineServiceItemController testStoredDocInlineServiceItemController;

    private static testMethod void testStoredDocInlineServiceItemController() {

        Test.setCurrentPageReference(Page.StoredDocsInlineServiceItem);
        testController = new ApexPages.StandardController( TestingUtils.createServiceItemList(1, true)[0] );

        Test.startTest();
            testStoredDocInlineServiceItemController = new StoredDocInlineServiceItemController(testController);
            Boolean test1 = testStoredDocInlineServiceItemController.isShowButton;
            String test2 = testStoredDocInlineServiceItemController.getLstoreUrl;
        Test.stopTest();

    }
}