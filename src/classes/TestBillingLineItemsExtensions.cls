@isTest
private class TestBillingLineItemsExtensions {
    private static ApexPages.StandardController stdController;
    private static BillingLineItemsExtensions billExtendsions;
    private static Pro_forma_invoice__c invoice;
    private static final Integer NUMBER_TO_CREATE = 5;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProjectProfile;
    private static Building__c testBuilding;
    private static Pro_forma_Invoice__c testProFormaInvoice;
    private static List<Billing_Line_Item__c> testBillingLineItemList; 
    private static Region__c  testRegion; 
    private static Munucipalities__c testMunucipality;  
         
    private static void insertData(){
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'testAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];       
            testContact.AccountId = testAccount.Id;
            insert testContact;
        testProjectProfile = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, null, null, null, null, null, null, null, false)[0];
            testProjectProfile.Billing_Company_Name__c = testAccount.Id;
            testProjectProfile.Billing_Company_Contact__c = testContact.id;
            testProjectProfile.Billing_Method__c = 'Installment';
            testProjectProfile.Frequency__c = 'Monthly';
            testProjectProfile.Billing_day__c = '1';
            insert testProjectProfile;  
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true)[0];
        testMunucipality = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true)[0];            
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipality.Id, 'TestStreet', '5', 'TestCity', '79000', true)[0];        
        testProFormaInvoice = TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE, testAccount.Id, testContact.Id, testBuilding.Id, false)[0];
            testProFormaInvoice.Project_Profile__c = testProjectProfile.Id;        
            insert testProFormaInvoice;             
        testBillingLineItemList = TestingUtils.createBillingLineItemList(NUMBER_TO_CREATE, 
                                                                         testProjectProfile.Id, 
                                                                         testAccount.Id, 
                                                                         testContact.Id, 
                                                                         true);
    }
     
    private static void setUp(){
        Test.setCurrentPageReference(Page.BillingLineItemsRelatedList);
        stdController = new ApexPages.StandardController(testProFormaInvoice);
        billExtendsions = new BillingLineItemsExtensions(stdController);
    }
         
    @isTest(seeAllData = false) private static void testBillingLineItemsExtensions(){
        insertData();
        setUp();
        
        Test.startTest();
            invoice = (Pro_forma_invoice__c)stdController.getRecord();
        Test.stopTest();
        
        System.assertEquals(invoice, billExtendsions.invoice);  
        System.assert(billExtendsions.getBillingLineItems() != null);
        System.assert(billExtendsions.getBillingLineItems().isEmpty());  
    }
    
    @isTest(seeAllData = false) private static void testGetBillingLineItems(){
        insertData();       
        for(Billing_Line_Item__c item :testBillingLineItemList){
            item.Pro_forma_Invoice__c = testProFormaInvoice.Id;             
        }
        update testBillingLineItemList;     
        setUp();
        
        Test.startTest();
             billExtendsions.getBillingLineItems();
        Test.stopTest();
        
        testBillingLineItemList = [ Select b.Name, b.Unit_Price__c, b.Quantity__c, b.Id, b.Amount__c, Project_Profile__r.Billing_Method__c
                                    From Billing_Line_Item__c b
                                    Where b.Pro_forma_Invoice__c =: testProFormaInvoice.Id];
        System.assertEquals(testBillingLineItemList.size(), (billExtendsions.billingItems).size());
        
        
        Map<Id,Billing_Line_Item__c> testMap = new Map<Id,Billing_Line_Item__c>();
        for(Billing_Line_Item__c item : testBillingLineItemList){
            testMap.put(item.Id,item);
        }
        for(Billing_Line_Item__c item : billExtendsions.billingItems){
            System.assertEquals(testMap.get(item.id).Name, item.Name);
            System.assertEquals(testMap.get(item.id).Unit_Price__c, item.Unit_Price__c);
            System.assertEquals(testMap.get(item.id).Quantity__c, item.Quantity__c);
            System.assertEquals(testMap.get(item.id).Id, item.Id);
            System.assertEquals(testMap.get(item.id).Amount__c, item.Amount__c);
        }   
    }
    
    @isTest(seeAllData = false) private static void testEditBillItem_Null(){
        insertData();       
        setUp();
        
        Test.startTest();           
            billExtendsions.editBillItem(); 
        Test.stopTest();
         
        System.assertEquals(null, billExtendsions.billItemId); 
    }
    
    @isTest(seeAllData = false) private static void testEditBillItem_PageReference(){
        insertData();
        for(Billing_Line_Item__c item :testBillingLineItemList){
            item.Pro_forma_Invoice__c = testProFormaInvoice.Id;             
        }
        update testBillingLineItemList;                 
        setUp();
        billExtendsions.billItemId = testBillingLineItemList[0].Id;  
        billExtendsions.getBillingLineItems();
        
        Test.startTest();           
            PageReference testPage = billExtendsions.editBillItem();   
        Test.stopTest();        
               
        System.assert(testPage.getUrl().contains( String.valueOf(billExtendsions.billItemId).substring(0,14))); 
    }
    
    @isTest(seeAllData = false) private static void testRemoveBillItemLookUp_Null(){
        insertData();       
        setUp();
        
        Test.startTest();           
            billExtendsions.removeBillItemLookUp(); 
        Test.stopTest();
         
        System.assertEquals(null, billExtendsions.billItemId); 
    }
    
    @isTest(seeAllData = false) private static void testRemoveBillItemLookUp(){
        insertData();   
        for(Billing_Line_Item__c item :testBillingLineItemList){
            item.Pro_forma_Invoice__c = testProFormaInvoice.Id;             
        }
        update testBillingLineItemList;            
        setUp();
        billExtendsions.billItemId = testBillingLineItemList[0].Id;     
        billExtendsions.getBillingLineItems();      
        
        Test.startTest();           
            billExtendsions.removeBillItemLookUp(); 
        Test.stopTest();
         
        Billing_Line_Item__c testBillingLineItem = [SELECT Id,Pro_forma_Invoice__c,Billed__c FROM Billing_Line_Item__c Where Id = : billExtendsions.billItemId][0];
        
        System.assertEquals(null, testBillingLineItem.Pro_forma_Invoice__c);
        System.assertEquals(false, testBillingLineItem.Billed__c);
    }
    
    @isTest(seeAllData = false) private static void testBillingLineItemsExtensions_Null(){
        Pro_forma_Invoice__c ProFormaInvoice = new Pro_forma_Invoice__c();
        
        Test.startTest();
            stdController = new ApexPages.StandardController(ProFormaInvoice);
            billExtendsions = new BillingLineItemsExtensions(stdController); 
        Test.stopTest();
        
        System.assertEquals(null, billExtendsions.getBillingLineItems());
    }
}