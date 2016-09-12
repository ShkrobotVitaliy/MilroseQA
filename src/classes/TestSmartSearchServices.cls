@isTest
private class TestSmartSearchServices {
    private static final Integer NUMBER_TO_CREATE = 1;
    private static List <Account> testAccountList;
    
    @isTest static void testSmartSearchFunctionality() {
        Account account = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'testAccountName', true)[0];
        Building__c building = TestingUtils.createBuildingList (NUMBER_TO_CREATE, null, 'testStreetName', null, null, null, true)[0];        
        
        Smart_search__c smartSearchForAccount = new Smart_search__c( Original_Version__c = 'testAccountName', Smart_Search_Version_1__c = 'test1', Smart_Search_Version_2__c = 'test2', Smart_Search_Version_3__c = 'test3');
        Smart_search__c smartSearchForBuilding = new Smart_search__c( Original_Version__c = 'testStreetName', Smart_Search_Version_1__c = 'test1', Smart_Search_Version_2__c = 'test2', Smart_Search_Version_3__c = 'test3');
        
        Test.startTest();
            insert smartSearchForAccount;
            insert smartSearchForBuilding;
            
            Account_Search_Junction__c accSerJun = [Select Id From Account_Search_Junction__c Where Account__c =: account.Id];
            Building_Search_Junction__c buildSerJun = [Select Id From Building_Search_Junction__c Where Building__c =: building.Id];
            
            system.assertEquals( NUMBER_TO_CREATE, [Select Id From Account_Search_Junction__c Where Account__c =: account.Id].size());
            system.assertEquals( NUMBER_TO_CREATE, [Select Id From Building_Search_Junction__c Where Building__c =: building.Id].size());
            
            delete accSerJun;
            delete buildSerJun;
            
            Database.executeBatch( new CreateBatchSmartSearchFunctionality(), 1 );
            
            delete smartSearchForAccount;
            delete smartSearchForBuilding;
        Test.stopTest();
    }
}