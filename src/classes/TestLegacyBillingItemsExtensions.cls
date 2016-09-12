@isTest
private class TestLegacyBillingItemsExtensions {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 2;
    private static final Integer NUMBER_TO_CREATE_CODA_INVOICE = 2;
    private static final Integer NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE = 3;
    private static final Integer NUMBER_TO_CREATE_LEGACY_BILLING_ITEM = 5;
    private static final Integer NUMBER_TO_CREATE_DIMENSION1 = 1;
    private static final Integer NUMBER_TO_CREATE_DIMENSION2 = 1;
    private static final Integer NUMBER_TO_CREATE_PRODUCT2 = 1;

    private static List<Account> testAccountList;
    private static List<c2g__codaInvoice__c> testCodaInvoiceList;
    private static List<Legacy_Pro_forma_Invoice__c> testLegacyProformaInvoiceListWithSalesInvoce;
    private static List<Legacy_Pro_forma_Invoice__c> testLegacyProformaInvoiceListWithoutSalesInvoce;
    private static List<Legacy_Billing_Item__c> testLegacyBillingItemList;
    private static List<c2g__codaDimension1__c> testDimension1List;
    private static List<c2g__codaDimension2__c> testDimension2List;
    private static List<Product2> testProduct2List;

    private static PageReference testPage;
    private static ApexPages.StandardController testStandardController;
    private static LegacyBillingItemsExtensions testController;

    private static Boolean prepareDataForTest(Boolean createWithSalesInvoice){
        Boolean hasClosedPeriodErrors = false;
        testProduct2List = TestingUtils.createProduct2List(NUMBER_TO_CREATE_PRODUCT2, null, true);
        testDimension1List = TestingUtils.createDimension_1_List(NUMBER_TO_CREATE_DIMENSION1, true);
        testDimension2List = TestingUtils.createDimension2List(NUMBER_TO_CREATE_DIMENSION2, null, true);

        List<Legacy_Pro_forma_Invoice__c> legacyProformaInvoiceListForInsert = new List<Legacy_Pro_forma_Invoice__c>();
        testLegacyProformaInvoiceListWithSalesInvoce = new List<Legacy_Pro_forma_Invoice__c>();
        testLegacyProformaInvoiceListWithoutSalesInvoce = new List<Legacy_Pro_forma_Invoice__c>();

        testAccountList = testingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);

        //create Legacy_Pro_forma_Invoice__c with FF_Sales_Invoice__c
        if(createWithSalesInvoice){
            try {
                System.runAs(TestingUtils.getFFUser ()){
                    testCodaInvoiceList = new List<c2g__codaInvoice__c>();
                    for (Account accountItem : testAccountList){
                        for (c2g__codaInvoice__c invoiceItem : TestingUtils.createSalesInvoiceList(NUMBER_TO_CREATE_CODA_INVOICE, testAccountList[0].Id, null, null, false)){
                            testCodaInvoiceList.add(invoiceItem);
                        }
                    }
                    insert testCodaInvoiceList;
                }

                for (c2g__codaInvoice__c invoiceItem : testCodaInvoiceList){
                    for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE, false)){
                        legacyProformaInvoiceItem.FF_Sales_Invoice__c = invoiceItem.Id;
                        testLegacyProformaInvoiceListWithSalesInvoce.add(legacyProformaInvoiceItem);
                        legacyProformaInvoiceListForInsert.add(legacyProformaInvoiceItem);
                    }
                }
            } catch( DmlException e ) {
                if( e.getMessage().contains( TestingUtils.CLOSED_PERIOD_ERROR ) ) {
                    hasClosedPeriodErrors = true;
                } else {
                    Throw new ErrorException( e.getMessage() );
                }
            }
        }
        //create Legacy_Pro_forma_Invoice__c without FF_Sales_Invoice__c
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE_LEGACY_PRO_FORMA_INVOICE, false)){
            testLegacyProformaInvoiceListWithoutSalesInvoce.add(legacyProformaInvoiceItem);
            legacyProformaInvoiceListForInsert.add(legacyProformaInvoiceItem);
        }

        insert legacyProformaInvoiceListForInsert;

        testLegacyBillingItemList = new List<Legacy_Billing_Item__c>();
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : legacyProformaInvoiceListForInsert){
            for (Legacy_Billing_Item__c legacyBillingItem : TestingUtils.createLegacyBillingItemList (NUMBER_TO_CREATE_LEGACY_BILLING_ITEM, null, null, null,
                                                                                                      testDimension2List[0].Id, testProduct2List[0].Id, testDimension1List[0].Id, false)){
                legacyBillingItem.Legacy_Pro_forma_Invoice__c = legacyProformaInvoiceItem.Id;
                testLegacyBillingItemList.add(legacyBillingItem);
            }
        }
        insert testLegacyBillingItemList;
        return hasClosedPeriodErrors;
    }

    private static void preparePageController (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem){
        testPage = Page.LegacyBillingItemsRelatedList;
        Test.setCurrentPage(testPage);
        testStandardController = new ApexPages.StandardController(legacyProformaInvoiceItem);
        testController = new LegacyBillingItemsExtensions(testStandardController);
    }

@isTest(seeAllData = true)
    private static void testInitControllerWithSaleInvoice(){
        Boolean hasClosedPeriodErrors = prepareDataForTest(true);

        Test.startTest();

            if( !testLegacyProformaInvoiceListWithSalesInvoce.isEmpty() ) preparePageController(testLegacyProformaInvoiceListWithSalesInvoce[0]);

        Test.stopTest();

        if( !hasClosedPeriodErrors ) {
            System.assert(testController.legacyProformaInvoice != null);
        }
    }

    private static testmethod void testInitControllerWithoutSaleInvoice(){
        prepareDataForTest(false);

        Test.startTest();

            preparePageController(testLegacyProformaInvoiceListWithoutSalesInvoce[0]);

        Test.stopTest();

        System.assert(testController.legacyProformaInvoice != null);
    }

    private static testmethod void testGetLegacyBillingItemList(){
        prepareDataForTest(false);
        preparePageController(testLegacyProformaInvoiceListWithoutSalesInvoce[0]);

        List<Legacy_Billing_Item__c> resultLegacyBillingItemList;

        Test.startTest();

            resultLegacyBillingItemList = testController.getLegacyBillingItemList();

        Test.stopTest();

        System.assert (resultLegacyBillingItemList != null);
        System.assert (! resultLegacyBillingItemList.isEmpty() );

        for (Legacy_Billing_Item__c legacyBillingItem : resultLegacyBillingItemList){
            System.assertEquals (testLegacyProformaInvoiceListWithoutSalesInvoce[0].Id, legacyBillingItem.Legacy_Pro_forma_Invoice__c);
        }
    }

@isTest(seeAllData = true)
    private static void testRemoveLegacyProformaInvoiceLookUpWithSalesInvoice(){
        Boolean hasClosedPeriodErrors = prepareDataForTest(true);
        if( !testLegacyProformaInvoiceListWithSalesInvoce.isEmpty() ) {
            preparePageController(testLegacyProformaInvoiceListWithSalesInvoce[0]);

            for (Legacy_Billing_Item__c legacyBillingItem: testLegacyBillingItemList){
                if (legacyBillingItem.Legacy_Pro_forma_Invoice__c == testLegacyProformaInvoiceListWithSalesInvoce[0].Id){
                    testController.legacyBillingItemId = legacyBillingItem.Id;
                    break;
                }
            }
        }

        PageReference resultPageReference;

        Test.startTest();

            if( !testLegacyProformaInvoiceListWithSalesInvoce.isEmpty() ) resultPageReference = testController.removeLegacyProformaInvoiceLookUp();

        Test.stopTest();

        if( !hasClosedPeriodErrors ) {
            System.assert(resultPageReference == null);
        }
    }

    private static testmethod void testRemoveLegacyProformaInvoiceLookUpWithoutItem(){
        prepareDataForTest(false);
        preparePageController(testLegacyProformaInvoiceListWithoutSalesInvoce[0]);

        testController.legacyBillingItemId = null;

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.removeLegacyProformaInvoiceLookUp();

        Test.stopTest();

        System.assert(resultPageReference == null);
    }

    private static testmethod void testRemoveLegacyProformaInvoiceLookUp(){
        prepareDataForTest(false);
        preparePageController(testLegacyProformaInvoiceListWithoutSalesInvoce[0]);

        for (Legacy_Billing_Item__c legacyBillingItem: testLegacyBillingItemList){
            if (legacyBillingItem.Legacy_Pro_forma_Invoice__c == testLegacyProformaInvoiceListWithoutSalesInvoce[0].Id){
                testController.legacyBillingItemId = legacyBillingItem.Id;
                break;
            }
        }
        Id bliId = testController.legacyBillingItemId;

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.removeLegacyProformaInvoiceLookUp();

        Test.stopTest();

        Legacy_Billing_Item__c checkResultRecord = [SELECT Id, Legacy_Pro_forma_Invoice__c, Billed__c
                                                    FROM Legacy_Billing_Item__c
                                                    WHERE Id = : bliId];

        System.assertEquals (null, checkResultRecord.Legacy_Pro_forma_Invoice__c);
        System.assertEquals (false, checkResultRecord.Billed__c);
    }

    private static testmethod void testRemoveLegacyProformaInvoiceLookUpWithIncorrectData(){
        prepareDataForTest(false);
        preparePageController(testLegacyProformaInvoiceListWithoutSalesInvoce[0]);

        testController.legacyBillingItemId = Id.valueOf(Legacy_Billing_Item__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.removeLegacyProformaInvoiceLookUp();

        Test.stopTest();

        System.assert(resultPageReference == null);
    }
}