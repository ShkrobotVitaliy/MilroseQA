@isTest
private class TestMassMassSendLegacyInvoiceExtensions {
    private static PageReference testPage;
    private static MassSendLegacyInvoiceExtensions testController;
    private static ApexPages.StandardSetController testStandardController;
    
    private static testmethod void testCoverageMethod() {
        List<Legacy_Pro_forma_Invoice__c> legacyInvoices = TestingUtils.createLegacyProFormaInvoiceList(5, false);
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : legacyInvoices){
            legacyProformaInvoiceItem.FFA_Invoice_Created__c = false;
        }
        insert legacyInvoices;

        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : legacyInvoices){
            legacyProformaInvoiceItem.FFA_Invoice_Created__c = true;
        }
        update legacyInvoices;

        testStandardController = new ApexPages.StandardSetController([SELECT Id FROM Legacy_Pro_forma_Invoice__c WHERE Id IN : legacyInvoices]);//new ApexPages.StandardSetController(legacyInvoices);
        testStandardController.setSelected(legacyInvoices);
        testController = new MassSendLegacyInvoiceExtensions(testStandardController);
        PageReference pg = testController.back();
        PageReference downloadPdf = testController.downloadPdf();
        
        System.assert( ApexPages.hasMessages() );

        testController.autorun();
        testController.actionParam = DDPEmailServices.DELIVERY_METHOD_EMAIL;
        testController.autorun();
        testController.actionParam = DDPEmailServices.DELIVERY_METHOD_ATTACH;
        testController.autorun();

        String ddpNameParam = testController.ddpNameParam;
    }
    
}