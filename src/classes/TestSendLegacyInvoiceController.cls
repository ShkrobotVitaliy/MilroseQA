@isTest
private class TestSendLegacyInvoiceController {
    private static ApexPages.StandardController testController;
    private static SendLegacyInvoiceController testSendLegacyInvoiceController;
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
        
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor1() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
                
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'CreateInvoices');
        ApexPages.currentPage().getParameters().put('action', 'Send');  
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor2() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
                
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'CreateSendInvoices');
        ApexPages.currentPage().getParameters().put('action', 'Create');  
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor3() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
                
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'CreateCreditNote1');
        ApexPages.currentPage().getParameters().put('action', 'Create');  
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor4() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
                
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'CreateCreditNote2');
        ApexPages.currentPage().getParameters().put('action', 'Create');  
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testSendLegacyInvoiceControllerConstructor5() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
                
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'test1');
        ApexPages.currentPage().getParameters().put('action', 'test1');  
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            String ddpName        = testSendLegacyInvoiceController.ddpName; 
            String deliveryOption = testSendLegacyInvoiceController.deliveryOption;

        Test.stopTest();
    
    }
    
    private static testMethod void testAutorun() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
        
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'test1');
        ApexPages.currentPage().getParameters().put('action', 'Send');
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            testSendLegacyInvoiceController.autorun();
            
            PageReference pageBack = testSendLegacyInvoiceController.back();

        Test.stopTest();
    
    }
    
     private static testMethod void testAutorun1() {
        Legacy_Pro_forma_Invoice__c legacyInvoiceForStandardController = new Legacy_Pro_forma_Invoice__c();
        insert legacyInvoiceForStandardController;
        
        Test.setCurrentPageReference(Page.SendLegacyInvoice);
        ApexPages.currentPage().getParameters().put('ddpName', 'test1');
        ApexPages.currentPage().getParameters().put('action', 'Attach');
        
        testController = new ApexPages.StandardController(legacyInvoiceForStandardController);
        
        Test.startTest();
            testSendLegacyInvoiceController = new SendLegacyInvoiceController(testController);
            
            legacyInvoiceForStandardController.FFA_Invoice_Created__c = true;
            testSendLegacyInvoiceController.autorun();
            
            legacyInvoiceForStandardController.cl_FFA_Credit_Note_1_Created__c = true;
            testSendLegacyInvoiceController.autorun();
            
            legacyInvoiceForStandardController.cl_FFA_Credit_Note_2_Created__c = true;
            testSendLegacyInvoiceController.autorun();
        Test.stopTest();
    
    }
    
}