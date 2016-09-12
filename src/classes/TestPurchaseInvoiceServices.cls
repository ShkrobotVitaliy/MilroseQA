@isTest
private class TestPurchaseInvoiceServices {
    private static List<c2g__codaPurchaseInvoice__c> newInvoice;
    private static Map<Id, c2g__codaPurchaseInvoice__c> oldInvoiceMap;    
    private  static final String INVOICE_STATUS_COMPLETE  = 'Complete';
    
    private static void setUp(){
        newInvoice = [SELECT Id,c2g__InvoiceStatus__c FROM c2g__codaPurchaseInvoice__c WHERE BLI_Created__c = false AND Create_BLI__c = true AND c2g__InvoiceStatus__c = :INVOICE_STATUS_COMPLETE ];
    }
    
    /*@isTest(seeAllData = true)private static  void testRunBLIClickRule(){
        setUp();
                
        Test.startTest();
            PurchaseInvoiceServices.runBLIClickRule(newInvoice);
        Test.stopTest();    
    }*/
    
    @isTest(seeAllData = true)private static  void testFilterPurchaseInvoiceForLegacyBillingItem(){
        newInvoice = [SELECT Id,MRC__c,Created_by_ClickLink__c,Create_Legacy_BLI__c,Legacy_BLI_Created__c, c2g__InvoiceStatus__c
                      FROM c2g__codaPurchaseInvoice__c
                      WHERE MRC__c != null AND Created_by_ClickLink__c = false AND
                            Create_Legacy_BLI__c= true AND
                            Legacy_BLI_Created__c = false ];
 
        Test.startTest();
            PurchaseInvoiceServices.filterPurchaseInvoiceForLegacyBillingItem(newInvoice);
        Test.stopTest();    
    }
    
    /*@isTest(seeAllData = true)private static  void testRunLegacyBillingItemClickRule(){
        setUp();
                
        Test.startTest();
            PurchaseInvoiceServices.runLegacyBillingItemClickRule(newInvoice);
        Test.stopTest();    
    }*/
    
    @isTest(seeAllData = true)private static  void testSetProjectMi7IdsForPayableInvoices(){
        newInvoice = [SELECT Id, MRC__c, Created_by_ClickLink__c, c2g__Dimension1__c, c2g__Dimension2__c, Project_Native__c, Create_Legacy_BLI__c
                      FROM c2g__codaPurchaseInvoice__c 
                      WHERE MRC__c != null AND Created_by_ClickLink__c = false];
        
        Test.startTest();
            PurchaseInvoiceServices.setProjectMi7IdsForPayableInvoices(newInvoice);
        Test.stopTest();    
    }

    @isTest
    private static  void testFilterPurchaseInvoiceForBLI(){        
        Test.startTest();
            List<c2g__codaPurchaseInvoice__c> payableInvoices = PurchaseInvoiceServices.filterPurchaseInvoiceForBLI(new List<c2g__codaPurchaseInvoice__c>(), new Map<Id, c2g__codaPurchaseInvoice__c>());
        Test.stopTest();    
    
    }
    
    @isTest
    private static  void testFilterPurchaseInvoiceForSetMi7Projects(){        
        Test.startTest();
            List<c2g__codaPurchaseInvoice__c> payableInvoices = PurchaseInvoiceServices.filterPurchaseInvoiceForSetMi7Projects(new List<c2g__codaPurchaseInvoice__c>(), new Map<Id, c2g__codaPurchaseInvoice__c>());
        Test.stopTest();    
    
    }
    
    @isTest
    private static  void testUpdatePurchaseInvoiceDimensions(){        
        Test.startTest();
            PurchaseInvoiceServices.updatePurchaseInvoiceDimensions(null);
            PurchaseInvoiceServices.updatePurchaseInvoiceDimensions(new Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c>());
        Test.stopTest();    
    
    }
    
    @isTest
    private static  void testGetPurchaseInvoiceIdToPurchaseLineItem(){        
        Test.startTest();
            Map<Id, c2g__codaPurchaseInvoiceExpenseLineItem__c> lineItems = PurchaseInvoiceServices.getPurchaseInvoiceIdToPurchaseLineItem(new List<c2g__codaPurchaseInvoiceExpenseLineItem__c>());
        Test.stopTest();    
    
    }
    
    @isTest
    private static  void testGetPurchaseInvoicesByIds() {        
        Test.startTest();
            List<c2g__codaPurchaseInvoice__c> invoices = PurchaseInvoiceServices.getPurchaseInvoicesByIds(null);            
        Test.stopTest();    
    
    }

}