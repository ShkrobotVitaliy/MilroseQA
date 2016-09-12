@isTest
private class TestLegacyBillingItemServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;

    private static List<Legacy_Billing_Item__c> testLegacyBillingItemList;
    public static List<Account> testAccountList;

    private static void setUp(Boolean doInsert){

        testLegacyBillingItemList = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, false);
        
        if(doInsert){

            insert testLegacyBillingItemList;
            
        }
        
    }
    
    
    private static testMethod void testFilterLegacyBillingItem(){
        setUp(true);
        
        List<Legacy_Billing_Item__c> items = null;

        Test.startTest();
            items = LegacyBillingItemServices.filterLegacyBillingItem(testLegacyBillingItemList);
        Test.stopTest();

        System.assert(! items.isEmpty() );
    }
    
    private static testMethod void testUpdateManuallyCreatedLegacyItem(){
        setUp(true);
        
        Test.startTest();
            LegacyBillingItemServices.updateManuallyCreatedLegacyItem(testLegacyBillingItemList);
        Test.stopTest();

        System.assert(! testLegacyBillingItemList.isEmpty() );
    }
    
    private static testMethod void testUpdateManuallyCreatedLegacyItem2(){
        Test.startTest();

        Project__c p = new Project__c(MRC__c = '1234');
        insert p;

        Legacy_Billing_Item__c lineItem = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, false)[0];
        lineItem.MRC__c = '1234';
        lineItem.Billed__c = true;
        insert lineItem;
        
        List<Legacy_Billing_Item__c> billingItems = new List<Legacy_Billing_Item__c>();
        billingItems.add(lineItem);
        
        LegacyBillingItemServices.updateManuallyCreatedLegacyItem(billingItems);
        
        Test.stopTest();

        System.assert(! billingItems.isEmpty() );
    }
    
    
    private static testMethod void testFilterClickLinkLegacyBillingItem(){
        setUp(false);
        for(Legacy_Billing_Item__c item : testLegacyBillingItemList){
            item.Created_by_ClickLink__c = true;
        }
            insert testLegacyBillingItemList;
            
        Test.startTest();
            LegacyBillingItemServices.filterClickLinkLegacyBillingItem(testLegacyBillingItemList);
        Test.stopTest();

        System.assert(! testLegacyBillingItemList.isEmpty() );
    }
    
    private static testMethod void testUpdateClickLinkCreatedLegacyItem(){
        setUp(true);
        
        Test.startTest();
            LegacyBillingItemServices.updateClickLinkCreatedLegacyItem(testLegacyBillingItemList);
        Test.stopTest();

        System.assert(! testLegacyBillingItemList.isEmpty() );
    }
    
    private static testMethod void testBruildQueryWhere(){
        
        Test.startTest();
             String buildQueryWhere = LegacyBillingItemServices.buildQueryWhere('Test', 'Test', 'Test', 'Test', 'test', true);
             System.assert(! String.isBlank(buildQueryWhere) );

             String buildQuerySelect = LegacyBillingItemServices.buildQuerySelect(buildQueryWhere, 'Territory__c');
             System.assert(! String.isBlank(buildQuerySelect) );

        Test.stopTest();

    }
    
    private static testMethod void testGetLegacyLineItemByInvoiceIdsEmptyParameter() {
        Test.startTest();
            List<Legacy_Billing_Item__c> items = LegacyBillingItemServices.getLegacyLineItemByInvoiceIds(null);
            System.assert( items.isEmpty() );
        Test.stopTest();
    
    }
    
    private static testMethod void testGetLegacyLineItemByInvoiceIds() {
        Test.startTest();
            Legacy_Pro_forma_Invoice__c legacy = new Legacy_Pro_forma_Invoice__c();
            insert legacy;
            Legacy_Billing_Item__c lineItem = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, false)[0];
            lineItem.Legacy_Pro_forma_Invoice__c = legacy.Id;
            lineItem.Billed__c = true;
            insert lineItem;
            
            List<Legacy_Billing_Item__c> items = LegacyBillingItemServices.getLegacyLineItemByInvoiceIds(new Set<Id> { lineItem.Id });
            update legacy;

            System.assert( items.isEmpty() );
        Test.stopTest();
    
    }
    
    private static testMethod void testPopulateDimensions() {
        setUp(true);
        
        Test.startTest();
            LegacyBillingItemServices.populateDimensions(testLegacyBillingItemList);
        Test.stopTest();
        
        System.assert(! testLegacyBillingItemList.isEmpty() );

    }
    
    private static testMethod void testPopulateDimensions2() {
        Test.startTest();

        Legacy_Pro_forma_Invoice__c legacyInvoice = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoice;
        
        Legacy_Billing_Item__c lineItem = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, false)[0];
        lineItem.Legacy_Pro_forma_Invoice__c = legacyInvoice.Id;
        lineItem.Quantity__c = 2;
        lineItem.Price__c = 50;
        lineItem.Department_DL__c = 'Department';
        insert lineItem;
        
        List<Legacy_Billing_Item__c> billingItems = new List<Legacy_Billing_Item__c>();
        billingItems.add(lineItem);
        
        LegacyBillingItemServices.populateDimensions(billingItems);
        
        Test.stopTest();

        System.assert(! billingItems.isEmpty() );
    
    }
    
    private static testMethod void testUpdateAggregate() {
        setUp(true);
        
        Integer iter = 1;
        Test.startTest();
            for (Legacy_Billing_Item__c item : testLegacyBillingItemList) {
                item.Price__c = iter++; 
                item.Quantity__c = iter++;
            
            }
            update testLegacyBillingItemList;
        Test.stopTest();

        System.assert(! testLegacyBillingItemList.isEmpty() );

    }
    
    private static testMethod void testDeleteAggregate() {
        setUp(true);
        
        Test.startTest();
            System.assert(! testLegacyBillingItemList.isEmpty() );
            delete testLegacyBillingItemList;
        Test.stopTest();

    }
    
    private static testMethod void testUpdateAggregatedFieldsOnLegacyProformInvoiceEmptyParameter() {
        setUp(true);
        
        Test.startTest();
            LegacyBillingItemServices.updateAggregatedFieldsOnLegacyProformInvoice(null);
        Test.stopTest();

        System.assert( ! testLegacyBillingItemList.isEmpty() );
    
    }
    
    private static testMethod void testUpdateAggregatedFieldsOnLegacyProformInvoice() {
        Legacy_Pro_forma_Invoice__c legacyInvoice = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoice;
        
        Legacy_Billing_Item__c lineItem = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, false)[0];
        lineItem.Legacy_Pro_forma_Invoice__c = legacyInvoice.Id;
        lineItem.Quantity__c = 2;
        lineItem.Price__c = 50;
        insert lineItem;
        
        Map<Id, Legacy_Pro_forma_Invoice__c> invoicesMap = new Map<Id, Legacy_Pro_forma_Invoice__c>();
        invoicesMap.put(legacyInvoice.Id, legacyInvoice);
        
        Test.startTest();
            LegacyBillingItemServices.updateAggregatedFieldsOnLegacyProformInvoice(invoicesMap);
        Test.stopTest();

        System.assert( ! invoicesMap.isEmpty() );
    
    }
    
    private static testMethod void testFilterLegacyInvoiceForUpdateAggregate() {
        setUp(true);
        
        Test.startTest();
            Map<Id, Legacy_Pro_forma_Invoice__c>  mapsLegacy = LegacyBillingItemServices.filterLegacyInvoiceForUpdateAggregate(testLegacyBillingItemList);
            System.assert( mapsLegacy.isEmpty() );
        Test.stopTest();

    }
    
    private static testMethod void testGetMRCNumberToProjectNameMi7ByMrc() {
        setUp(true);
        
        Test.startTest();
            Project__c p = new Project__c(MRC__c = '1234');
            insert p;
            Map<String, Project__c> mapProjects = LegacyBillingItemServices.getMRCNumberToProjectNameMi7ByMrc(new Set<String> { p.MRC__c });

            System.assert( ! mapProjects.isEmpty() );
        Test.stopTest();
    
    }

    private static testMethod void testgetAggregatedLegacyLineItemsByInvoiceIdsEmptyParameter() {
        setUp(true);
        
        Test.startTest();  
            AggregateResult[] arr = LegacyBillingItemServices.getAggregatedLegacyLineItemsByInvoiceIds(null);
            System.assert( arr.isEmpty() );
        Test.stopTest();
    
    }
    
    private static testMethod void testGetAllLegacyLineItemByInvoiceIds() {
        Test.startTest();
            Legacy_Pro_forma_Invoice__c legacyProforma = new Legacy_Pro_forma_Invoice__c();
            insert legacyProforma;
            
            List<Legacy_Billing_Item__c> allLegacyLineItemByInvoiceIds = LegacyBillingItemServices.getAllLegacyLineItemByInvoiceIds(legacyProforma.Id);

            System.assert( allLegacyLineItemByInvoiceIds.isEmpty() );
        Test.stopTest();
    }
    
    private static testMethod void testGetAllLegacyLineItemByInvoiceIdsEmptyParameter() {
        
        List<Legacy_Billing_Item__c> allLegacyLineItemByInvoiceIds = null;
        Test.startTest();
            try {
                allLegacyLineItemByInvoiceIds = LegacyBillingItemServices.getAllLegacyLineItemByInvoiceIds(null);
        
            } catch (Exception ex) {
                System.debug('>>>' + ex.getMessage());
            }
        Test.stopTest();

        System.assert(allLegacyLineItemByInvoiceIds == null);
    }

    private static testMethod void testNewInstance() {
        Test.startTest();
            Legacy_Billing_Item__c item = LegacyBillingItemServices.newInstance(new Legacy_Billing_Item__c(), true, false);
            System.assert(item != null);
        Test.stopTest();
    }
    
    private static testMethod void testGenerateLegacyBLIForAddidtionalFeesEmptyParam() {
        System.assert( testLegacyBillingItemList == null );   
        LegacyBillingItemServices.generateLegacyBLIForAddidtionalFees(null);
    
    }
}