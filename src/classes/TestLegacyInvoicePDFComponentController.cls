@isTest
private class TestLegacyInvoicePDFComponentController {
    private static final Integer NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE = 1;

    private static List<Legacy_Pro_forma_Invoice__c> testLegacyProformaInvoiceList;

    private static LegacyInvoicePDFComponentController testController;

    private static void prepareDataForTest(){
        testLegacyProformaInvoiceList = TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE, true);
    }

    private static testmethod void testInitController(){
        prepareDataForTest();

        Test.startTest();

            testController = new LegacyInvoicePDFComponentController();

            System.assert(testController != null);

            testController.setLegacyInvoiceRecord(testLegacyProformaInvoiceList[0]);

            Boolean testBoolean;
            testBoolean = testController.getLegacyInvoiceRecord() != null;
            testBoolean = testController.address1 != null;
            testBoolean = testController.address2 != null;
            testBoolean = testController.currentAmount != null;
            testBoolean = testController.out30Amount != null;
            testBoolean = testController.out60Amount != null;
            testBoolean = testController.out90Amount != null;
            testBoolean = testController.out90PlusAmount != null;
            testBoolean = testController.outstandingAmountDueSum != null;

        Test.stopTest();
    }
}