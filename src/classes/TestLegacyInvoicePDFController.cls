@isTest
private class TestLegacyInvoicePDFController {
    private static final Integer NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE = 1;

    private static List<Legacy_Pro_forma_Invoice__c> testLegacyProformaInvoiceList;

    private static PageReference testPage;
    private static LegacyInvoicePDFController testController;
    private static ApexPages.StandardController testStandardController;

    private static void prepareDataForTest(){
        testLegacyProformaInvoiceList = TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE, true);
    }

    private static void preparePageController (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceForStandardController, String actionValue){
        testPage = Page.LegacyInvoicePDF;
        Test.setCurrentPage(testPage);
        if (legacyProformaInvoiceForStandardController != null) {
            ApexPages.currentPage().getParameters().put('legacyId', legacyProformaInvoiceForStandardController.Id);
            ApexPages.currentPage().getParameters().put('action', !String.isEmpty(actionValue) ? actionValue : 'testActionValue');
            testStandardController = new ApexPages.standardController(legacyProformaInvoiceForStandardController);
            testController = new LegacyInvoicePDFController();
        }
    }

    private static testmethod void testInitController(){
        prepareDataForTest();

        Test.startTest();
            preparePageController(testLegacyProformaInvoiceList[0], null);

            System.assert(testController.legacyInvoice != null);
            System.assert(testController != null);

            //for test coverage
            Boolean testBoolean;
            testBoolean = testController.isDisplayMailTo != null;
            testBoolean = testController.isCredit1 != null;
            testBoolean = testController.isCredit2 != null;
            testBoolean = testController.creditNoteNumberShort != null;
            preparePageController(testLegacyProformaInvoiceList[0], 'credit1');
            testBoolean = testController.creditNoteNumberShort != null;
            preparePageController(testLegacyProformaInvoiceList[0], 'credit2');
            testBoolean = testController.creditNoteNumberShort != null;

        Test.stopTest();
    }
}