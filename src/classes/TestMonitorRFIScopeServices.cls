@isTest
private class TestMonitorRFIScopeServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static List<Monitor_RFI_Scope__c> newMonitorRFIScopes;
    private static List<RFI_Scope__c> testRFIScopeList;
    private static Region__c testRegion;
    private static Project_Roster__c testProjectRoster;
    private static String testKey = String.escapeSingleQuotes('TestKey');
    private static Account testAccount;
    private static Contact testContact;
    
    private static void setUp(){
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProjectRoster = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false)[0];
            testProjectRoster.Contact__c = testContact.Id;
            insert testProjectRoster;
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];
        testRFIScopeList = TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE, testRegion.Id, true);
        newMonitorRFIScopes = TestingUtils.createMonitorRFIWorkList(NUMBER_TO_CREATE, testRFIScopeList[0].Id,false);
        for(Monitor_RFI_Scope__c item : newMonitorRFIScopes){       
            item.Key__c = testKey;
        }
            insert newMonitorRFIScopes;
    }
    
    private static testMethod void testNewInstance(){
        setUp();
        
        Test.startTest();
            Monitor_RFI_Scope__c newInstance = MonitorRFIScopeServices.newInstance('TestReceip', testRFIScopeList[0].Id, testKey, 'TestType', testProjectRoster.Id, 'test string');
            System.assert(newInstance != null);
        Test.stopTest();
    }
    
    private static testMethod void testGetUnlockedRFIMonitorByUniqeKey(){
        setUp();
        
        Test.startTest();
            List<Monitor_RFI_Scope__c> unlockedRFIMonitorByUniqeKey = MonitorRFIScopeServices.getUnlockedRFIMonitorByUniqeKey(testKey);
            System.assert(unlockedRFIMonitorByUniqeKey != null);
        Test.stopTest();
    }
    
    private static testMethod void testGetUnlockedRFIMonitorByUniqeEmptyKey(){
        setUp();
        
        Test.startTest();
            List<Monitor_RFI_Scope__c> nlockedRFIMonitorByUniqeKey = MonitorRFIScopeServices.getUnlockedRFIMonitorByUniqeKey('');
            System.assert(nlockedRFIMonitorByUniqeKey != null);
        Test.stopTest();
    }
    
}