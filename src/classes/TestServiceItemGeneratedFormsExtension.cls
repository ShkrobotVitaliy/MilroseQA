@isTest
private class TestServiceItemGeneratedFormsExtension {

    private static ServiceItemGeneratedFormsExtension testController;

    private static testmethod void testForCoverage(){

        testController = new ServiceItemGeneratedFormsExtension(new ApexPages.standardController( TestingUtils.createServiceItemList(1, true)[0] ));

        Test.startTest();        
            testController.getStoreDocuments();
            testController.openPDF();
        Test.stopTest();
    }
    
}