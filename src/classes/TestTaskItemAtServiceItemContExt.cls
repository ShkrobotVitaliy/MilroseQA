@isTest
private class TestTaskItemAtServiceItemContExt {

    private static ApexPages.StandardController testController;
    private static TaskItemAtServiceItemContExt  testTaskItemAtServiceItemContExt ;

    private static testMethod void testTaskItemAtServiceItemContExt () {

        Test.setCurrentPageReference(Page.TaskItemAtServiceItemPage );
        testController = new ApexPages.StandardController( TestingUtils.createServiceItemList(1, true)[0] );

        Test.startTest();
            testTaskItemAtServiceItemContExt  = new TaskItemAtServiceItemContExt (testController);
        Test.stopTest();

    }
}