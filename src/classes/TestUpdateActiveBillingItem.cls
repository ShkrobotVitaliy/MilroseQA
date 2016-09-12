@isTest
private class TestUpdateActiveBillingItem {
    private static final Integer NUMBER_TO_CREATE = 5; 
    private static ApexPages.StandardController stdController;
    private static UpdateActiveBillingItem updateActiveBillingItemExt;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProject;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User projectManager;
    private static Service_Item__c testServiceItem;

    private static void setUp(){
        projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE,
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            projectManager.Id,
                                                            false)[0];
             testProject.Billing_Method__c = 'Milestone';
             insert testProject;    
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false)[0];
            testServiceItem.Project_Profile__c =  testProject.Id;
            insert testServiceItem;
            
        testBillingLineItemList = TestingUtils.createBillingLineItemList(NUMBER_TO_CREATE, testProject.Id, testAccount.Id, testContact.Id, false);
        for(Billing_Line_Item__c item : testBillingLineItemList){
            item.Active_Billing_Line_Item__c = true;
            item.Service_Item__c = testServiceItem.Id;
        }
            insert testBillingLineItemList;
            
        
        Test.setCurrentPageReference(Page.UpdateActiveBillingItem);
             
    }
    private static void initializeController(){
        stdController = new ApexPages.StandardController(testBillingLineItemList[0]);
        updateActiveBillingItemExt = new UpdateActiveBillingItem(stdController);
    }
    
    @isTest(seeAllData = false) private static void testUpdateActiveBillingItem(){
        setUp();        
        ApexPages.currentPage().getParameters().put('id',testBillingLineItemList[0].Id);
        initializeController();
        
        
        Test.startTest();    
            updateActiveBillingItemExt.updateActiveField();
        Test.stopTest();
        
        testBillingLineItemList= [SELECT Id,Active_Billing_Line_Item__c FROM Billing_Line_Item__c];
        System.assertEquals(false, testBillingLineItemList[0].Active_Billing_Line_Item__c);
        System.assert(ApexPages.currentPage().getUrl().contains(String.valueOf(testBillingLineItemList[0].Id)));
    }
    
    @isTest(seeAllData = false) private static void testUpdateActiveFieldBillingItemIsNull(){
        setUp();
        initializeController();
        
        Test.startTest();
            System.assertEquals(null, updateActiveBillingItemExt.updateActiveField());
        Test.stopTest();
    }
    

}