@isTest
private class TestProFormaLegacyBillingItemController {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ProFormaLegacyBillingItemController proFormaLegController;
    
    private static void initilliazeController(){
        if ( MilroseSetting__c.getInstance('Number_of_Rows_in_Legacy_Generator') == null ){
            insert new MilroseSetting__c(Name = 'Number_of_Rows_in_Legacy_Generator', Custom_Number__c = 500);
        }
        proFormaLegController = new ProFormaLegacyBillingItemController();
    }
    
    private static testMethod void testGettersAndSetters(){
        initilliazeController();
        System.assert(proFormaLegController != null);

        Test.startTest();
            Boolean availableGenerateInvoice = proFormaLegController.availableGenerateInvoice;
            List<LegacyBillingItemWrapper> legacyBillingItems = proFormaLegController.legacyBillingItems;
        Test.stopTest();
    }
    
    private static testMethod void testSearch(){
        initilliazeController();
        System.assert(proFormaLegController != null);

        proFormaLegController.billingClientCompanyFilter = 'Test';
        proFormaLegController.accountingContactCompanyFilter = 'Test';
        proFormaLegController.mrcFilter = 'Test';
        proFormaLegController.projectAddressFilter = 'Test';
        proFormaLegController.notBilliableFilter = true;
        Boolean isVisibleSaveButton = proFormaLegController.isVisibleSaveButton;
        List<SelectOption>  deliveryMethodOptions = proFormaLegController.deliveryMethodOptions;
        
        Test.startTest();
            proFormaLegController.search();
            proFormaLegController.saveChanges();
        Test.stopTest();


    }
    
    private static testMethod void testGenerateInvoices(){
        initilliazeController();
        System.assert(proFormaLegController != null);
        
        proFormaLegController.billingClientCompanyFilter = 'Test';
        proFormaLegController.accountingContactCompanyFilter = 'Test';
        proFormaLegController.mrcFilter = 'Test';
        proFormaLegController.projectAddressFilter = 'Test';
        proFormaLegController.notBilliableFilter = true;
        
        Test.startTest();
            proFormaLegController.generateInvoices();
            
            LegacyBillingItemWrapper wrapper = new LegacyBillingItemWrapper(new Legacy_Billing_Item__c());
            wrapper.selected = true;
            proFormaLegController.legacyBillingItems = new List<LegacyBillingItemWrapper>();
            proFormaLegController.legacyBillingItems.add(wrapper);
            proFormaLegController.search();
            
            proFormaLegController.generateInvoices();
        Test.stopTest();
    }
}