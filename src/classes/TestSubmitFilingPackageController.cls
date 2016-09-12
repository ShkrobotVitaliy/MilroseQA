@isTest
private class TestSubmitFilingPackageController {

    private static ApexPages.StandardController testController;
    private static SubmitFilingPackageToAuthorityController  testSubmitFilingPackageToAuthorityController ;

    private static testMethod void testManageResponseFromAuthorityExtention() {

        Test.setCurrentPageReference(Page.SubmitFilingPackageToAuthoritySection );
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );

        Test.startTest();
            testSubmitFilingPackageToAuthorityController  = new SubmitFilingPackageToAuthorityController (testController);
            testSubmitFilingPackageToAuthorityController.updateStatus();
        Test.stopTest();

    }
}