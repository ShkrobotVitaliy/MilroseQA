@isTest
private class TestAccountServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static List <Account> testAccountList;
    
    
    private static void setUp(Boolean doInsert){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'American Express', true);

        Account accoutCheck = testAccountList.get(0);
        List<Account> accs = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'American Express', true);
       
        for (Account acc : accs){
            acc.Account_Check__c = accoutCheck.Id;
            acc.Approved_Vendor__c = true;
        }
        update accs;
    }
    
    @isTest static void testUncoveredParts() {
        Account account = TestingUtils.createAccountList(1, null, false)[0];
        account.MSA_End_Date__c = Date.today();
        account.MSA__c = true;
        account.Account_Manager__c = TestingUtils.createUsers(1, true)[0].Id;
        INSERT account;
        
        Account accountOnHold = TestingUtils.createAccountList(1, null, false)[0];
        accountOnHold.Accounting_Hold__c = true; 
        INSERT accountOnHold;

        Contact contact = TestingUtils.createContactList(1, false)[0];
        contact.AccountId = accountOnHold.Id;
        INSERT contact;

        Project_Profile__c project = TestingUtils.createProjectProfileForTest(1, false)[0];
        project.Billing_Company_Name__c = accountOnHold.Id;
        project.Billing_Company_Contact__c = contact.Id;
        project.Accounting_Hold__c = false;
        project.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        INSERT project;

        Test.startTest();
            String getAccountNameByIds1 = AccountServices.getAccountNameByIds( account.Id );
            String getAccountNameByIds2 = AccountServices.getAccountNameByIds( null );
            AccountServices.createReminderForAccountManagerMSAAccount( new List<Account> { account }, new Map<Id, Account> { account.Id => account } );
            AccountServices.processingOnHoldAccounts( new List<Account> { account, accountOnHold } );

        Test.stopTest();
    }

    @isTest(seeAllData = false) 
    private static void testGetAmericanExpressAccount(){
        Set<Id> testAccountIdSet = new Set<Id>();
        Account testEmptyAccount = new Account(Name = 'TestAccount');
            insert testEmptyAccount;
        setUp(false);
        
        Test.startTest();
            List<Account> testList = AccountServices.getAmericanExpressAccount();
        Test.stopTest();    
        
        System.assertEquals(1, testList.size());
        for(Account accItem : testAccountList){
            testAccountIdSet.add(accItem.Id);
        }
        
        System.assert(testAccountIdSet.contains(testList[0].Id));
    }
    
    @isTest (seeAllData = false) 
    private static void testGetEmptyAccountWithPurchaseInvoicesByIds(){
        setUp(false);
        Test.startTest();
            List<Account> testList = AccountServices.getAccountWithPurchaseInvoicesByIds(null);
        Test.stopTest();
    

    }
    
    @isTest (seeAllData = false) 
    private static void testGetAccountWithPurchaseInvoicesByIds(){
        Set<Id> testAccountIdSet = new Set<Id>();
        setUp(false);
        for(Account accItem : testAccountList){         
            testAccountIdSet.add(accItem.Id);
        }
        testAccountList[0].Account_Check__c = testAccountList[1].Id;
            update testAccountList;
            
        Test.startTest();
            List<Account> testList = AccountServices.getAccountWithPurchaseInvoicesByIds(testAccountIdSet);
        Test.stopTest();
        
        System.assert(! testList.isEmpty());
        System.assertEquals(testAccountList[0].Id, testList[0].Id); 
        System.assertEquals(testAccountList[1].Id, testList[0].Account_Check__c);   
    }
    
     @isTest
    private static void testGetApprovedVendors() {
        setUp(false);
        List<Account> accounts = AccountServices.getApprovedVendors();
        System.assert(! accounts.isEmpty());
     
    }
    
     @isTest
    private static void testGetParentAccountsSelectOptions() {
        setUp(false);
        List<SelectOption> options = AccountServices.getParentAccountsSelectOptions();
        System.assert(! options.isEmpty());
    }
    
    @isTest
    private static void testGetAccountByIds() {
        setUp(false);
        Map<Id, Account> accounts = AccountServices.getAccountByIds(null);
        System.assert(accounts.isEmpty());
        
        accounts = AccountServices.getAccountByIds(new Set<Id> { testAccountList[0].Id });
        System.assert(!accounts.isEmpty());
     
    }

}