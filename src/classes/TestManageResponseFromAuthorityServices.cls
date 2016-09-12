@isTest
private class TestManageResponseFromAuthorityServices {
    private static final Integer NUMBER_TO_CREATE = 5;   
    private static User projectManagerUser;
    private static User adminUser;
    private static User productionManager;
    private static List <Task_Item__c> testTaskItemList;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Project_Profile__c> testProjectProfileList;  
    private static List<Manage_Response_From_Authority__c> testmanaeResponceFromAuthorityList;
    
    private static void setUp(Boolean doInsert){        
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        adminUser = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);
        productionManager = TestingUtils.userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];        
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, null, testProjectProfileList[0].Id, true);
        testmanaeResponceFromAuthorityList = TestingUtils.createManageResponceFromAuthority(NUMBER_TO_CREATE, doInsert);        
    }
    
    @isTest(seeAllData = false)private static void testFilterResponseRecordsToCreateReminders(){
        setUp(false);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Task_Item__c = testTaskItemList[0].Id;
            item.Use_Alert__c = true;           
        }
            insert testmanaeResponceFromAuthorityList;
        Map<Id, Manage_Response_From_Authority__c> newResponseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        Map<Id, Manage_Response_From_Authority__c> oldResponseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            oldResponseItemMap.put(item.Id,item.clone());
            item.Alert_Time__c = Date.today();
            newResponseItemMap.put(item.Id,item);           
        }
            update testmanaeResponceFromAuthorityList;
        
        System.assert(! testmanaeResponceFromAuthorityList.isEmpty() );

        Test.startTest();
            Map<Id, Manage_Response_From_Authority__c> filterMap = ManageResponseFromAuthorityServices.filterResponseRecordsToCreateReminders(newResponseItemMap, oldResponseItemMap);
            System.assert(! filterMap.isEmpty() );
        Test.stopTest();
    }
    
    @isTest(seeAllData = false)private static void testFilterResponseRecordsToDeleteReminders(){
        setUp(false);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Task_Item__c = testTaskItemList[0].Id;
            item.Use_Alert__c = true;           
        }
            insert testmanaeResponceFromAuthorityList;
        Map<Id, Manage_Response_From_Authority__c> newResponseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        Map<Id, Manage_Response_From_Authority__c> oldResponseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            oldResponseItemMap.put(item.Id,item.clone());
            item.Received_Date_Time__c = DateTime.now();
            newResponseItemMap.put(item.Id,item);           
        }
            update testmanaeResponceFromAuthorityList;

        System.assert(! testmanaeResponceFromAuthorityList.isEmpty() );

        Test.startTest();
            Map<Id, Manage_Response_From_Authority__c> filterMap = ManageResponseFromAuthorityServices.filterResponseRecordsToCreateReminders(newResponseItemMap, oldResponseItemMap);
            System.assert( filterMap != null );
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testCreateEventsForProjectManager(){
        setUp(false);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Task_Item__c = testTaskItemList[0].Id;
            item.Alert_Time__c = DateTime.now();        
        }
            insert testmanaeResponceFromAuthorityList;
        Map<Id, Manage_Response_From_Authority__c> responseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            responseItemMap.put(item.Id,item);
        }
        
        System.assert(! responseItemMap.isEmpty() );

        Test.startTest();
            ManageResponseFromAuthorityServices.createEventsForProjectManager(responseItemMap);
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testDeleteEventsForProjectManager(){
        setUp(false);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Task_Item__c = testTaskItemList[0].Id;
            item.Alert_Time__c = DateTime.now();        
        }
            insert testmanaeResponceFromAuthorityList;
        Map<Id, Manage_Response_From_Authority__c> responseItemMap  = new Map<Id, Manage_Response_From_Authority__c>();
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            responseItemMap.put(item.Id,item);
        }

        System.assert(! responseItemMap.isEmpty() );
        
        ManageResponseFromAuthorityServices.createEventsForProjectManager(responseItemMap);
        
        Test.startTest();
            ManageResponseFromAuthorityServices.deleteEventsForProjectManager(responseItemMap);
        Test.stopTest();
    }
}