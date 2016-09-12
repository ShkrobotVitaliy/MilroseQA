@isTest
private class TestServiceTemplateServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer ONE_OBJECT_CREATION = 1;
    private static Account testAccount;
    private static Contact testContact;
    private static User projectManagerUser;
    private static List <Project_Profile__c> testProjectProfileList;
    private static List <Service_Template__c> testServiceTemplateList;
    private static List <Service_Item__c> testServiceItemList;
    private static List <Billing_Line_Item__c> testBillingLineItemList;
    private static List <c2g__codaTaxCode__c> testTaxCodeList;
    private static List <c2g__codaGeneralLedgerAccount__c> testGenerealLedgerAccountList;
    
    private static void setUp(Boolean doInsert){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(ONE_OBJECT_CREATION, 'testAccount', true)[0];
        testContact = TestingUtils.createContactList(ONE_OBJECT_CREATION, testAccount.Id, true)[0];
        testProjectProfileList = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE, true);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true);
        testBillingLineItemList = TestingUtils.createBillingLineItemList(NUMBER_TO_CREATE, 
                                                                         testProjectProfileList[0].Id, 
                                                                         testAccount.Id, 
                                                                         testContact.Id, 
                                                                         doInsert);
        testGenerealLedgerAccountList = TestingUtils.createGeneralLedgerAccountList(NUMBER_TO_CREATE, 'testReportCode', 'TestName', true);                                                                         
        testTaxCodeList = TestingUtils.createTaxCodeList(NUMBER_TO_CREATE, testGenerealLedgerAccountList[0].Id, true);                                                                 
    }
    @isTest(seeAllData = false) private static void testUpdateServiceItemTaxCode(){
        setUp(false);
        Map<Id, Service_Template__c> testServiceTemplateMap = new Map<Id, Service_Template__c>();
        for(Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateItem.Tax_Code_1__c = testTaxCodeList[0].Id;
            serviceTemplateItem.Tax_Code_2__c = testTaxCodeList[1].Id;
            testServiceTemplateMap.put(serviceTemplateItem.Id, serviceTemplateItem);
        }
            update testServiceTemplateList;
        for(Service_Item__c serviceItem : testServiceItemList ) {
            serviceItem.Service_Template__c = testServiceTemplateList[0].Id;
            serviceItem.Tax_Code_1__c = testTaxCodeList[1].Id;
            serviceItem.Tax_Code_2__c = testTaxCodeList[2].Id;
        }
            update testServiceItemList;
    
        Test.startTest();
            ServiceTemplateServices.filterServiceTemplateTaxCode(testServiceTemplateList, testServiceTemplateMap);
            ServiceTemplateServices.updateServiceItemTaxCode(testServiceTemplateMap);
        Test.stopTest();    
        
        List<Service_Item__c> testServiceItemsToUpdate = [SELECT Id,Tax_Code_1__c,Tax_Code_2__c,Service_Template__c FROM Service_Item__c WHERE Service_Template__c = : testServiceTemplateList[0].Id];
        for(Service_Item__c testServiceItem : testServiceItemsToUpdate){
            System.assertEquals(testServiceTemplateList[0].Tax_Code_1__c, testServiceItem.Tax_Code_1__c);
            System.assertEquals(testServiceTemplateList[0].Tax_Code_2__c, testServiceItem.Tax_Code_2__c);
        }
        
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemsByServiceId(){
        Map<Id,Service_Item__c> testServiceMap = new Map<Id,Service_Item__c>();
        setUp(false);
        Set<Id> testIdList  = new Set<Id>();
        testIdList.add(testServiceTemplateList[0].Id);
        for(Service_Item__c serviceItem : testServiceItemList ) {
            serviceItem.Service_Template__c = testServiceTemplateList[0].Id;
            testServiceMap.put(serviceItem.Id,serviceItem);
        }
            update testServiceItemList;
        
        Test.startTest();
            List<Service_Item__c> testServiceList = ServiceTemplateServices.getServiceItemsByServiceId(testIdList);
        Test.stopTest();
        
        
        System.assertEquals(NUMBER_TO_CREATE, testServiceList.size());
        for(Service_Item__c servItem : testServiceList){
            System.assertEquals(testServiceMap.get(servItem.Id).Id, servItem.Id);
        }
    }

    
    @isTest(seeAllData = false) private static void testFilterMetDataScanningFeeOldMapIsNotNull(){
        setUp(false);
        Map<Id, Service_Template__c> testServiceTemplatesNew = new Map<Id, Service_Template__c>();
        Map<Id, Service_Template__c> testServiceTemplatesOld = new Map<Id, Service_Template__c>();
        for(Service_Template__c servTemplItem :  testServiceTemplateList){
            testServiceTemplatesOld.put(servTemplItem.Id,servTemplItem.clone());
            servTemplItem.Met_Data_Scanning_Fee__c = 5;
            testServiceTemplatesNew.put(servTemplItem.Id,servTemplItem);
        }
            update testServiceTemplateList;
        
        Test.startTest();
            Map<Id, Service_Template__c> serviceTemplateMap = ServiceTemplateServices.filterMetDataScanningFee(testServiceTemplatesNew, testServiceTemplatesOld);
        Test.stopTest();
        
        testServiceTemplateList = [SELECT Id,Met_Data_Scanning_Fee__c FROM Service_Template__c];    
        
        for(Service_Template__c servTemplateItem : testServiceTemplateList){
            System.assertEquals(testServiceTemplatesNew.get(servTemplateItem.Id).Id, serviceTemplateMap.get(servTemplateItem.Id).Id);
            System.assertEquals(testServiceTemplatesNew.get(servTemplateItem.Id).Met_Data_Scanning_Fee__c, serviceTemplateMap.get(servTemplateItem.Id).Met_Data_Scanning_Fee__c);
        }
    }
    
    @isTest(seeAllData = false) private static void testFilterMetDataScanningFeeOldMapIsNull(){
        setUp(false);
        Map<Id, Service_Template__c> testServiceTemplatesNew = new Map<Id, Service_Template__c>();
        for(Service_Template__c servTemplItem :  testServiceTemplateList){
            servTemplItem.Met_Data_Scanning_Fee__c = 5;
            testServiceTemplatesNew.put(servTemplItem.Id,servTemplItem);
        }
            update testServiceTemplateList;
        
        Test.startTest();
            Map<Id, Service_Template__c> serviceTemplateMap = ServiceTemplateServices.filterMetDataScanningFee(testServiceTemplatesNew, null);
        Test.stopTest();
        
        testServiceTemplateList = [SELECT Id,Met_Data_Scanning_Fee__c FROM Service_Template__c];    
        
        for(Service_Template__c servTemplateItem : testServiceTemplateList){
            System.assertEquals(testServiceTemplatesNew.get(servTemplateItem.Id).Id, serviceTemplateMap.get(servTemplateItem.Id).Id);
            System.assertEquals(testServiceTemplatesNew.get(servTemplateItem.Id).Met_Data_Scanning_Fee__c, serviceTemplateMap.get(servTemplateItem.Id).Met_Data_Scanning_Fee__c);
        }   
    }
    
    @isTest(seeAllData = false) private static void testUpdateMetDataScanningFee(){
        setUp(false);
        Map<Id,Service_Template__c> testServiceTemplateMap = new Map<Id,Service_Template__c>();
        for(Service_Template__c servTemplateItem : testServiceTemplateList){
            servTemplateItem.Met_Data_Scanning_Fee__c = 5;
            testServiceTemplateMap.put(servTemplateItem.Id,servTemplateItem);
        }
            update testServiceTemplateList;
        for(Service_Item__c serviceItem : testServiceItemList ) {
            serviceItem.Service_Template__c = testServiceTemplateList[0].Id;
        }
            update testServiceItemList; 
            
        Test.startTest();
            ServiceTemplateServices.updateMetDataScanningFee(testServiceTemplateMap);
        Test.stopTest();
        
        List<Service_Item__c> testServiceList = [SELECT Id,Met_Data_Scanning_Fee__c FROM Service_Item__c];
        
        System.assertEquals(NUMBER_TO_CREATE, testServiceList.size());
        for(Service_Item__c servItem : testServiceList){
            System.assertEquals(5, servItem.Met_Data_Scanning_Fee__c);
        }
            
        
    }
}