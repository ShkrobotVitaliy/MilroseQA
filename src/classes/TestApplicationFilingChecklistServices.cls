@isTest
private class TestApplicationFilingChecklistServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static List <Task_Item__c> testTaskItemList;
    private static List <Application_Filing_Checklist__c> testAppFillCheckList;
    
    private static void setUp(Boolean doInsert){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, true);
        testAppFillCheckList = TestingUtils.createApplicationFillingChecklistList(NUMBER_TO_CREATE, doInsert);
    }
    
    @isTest(seeAllData = false) private static void testGetAppFillingChecklistByTaskItemId(){   
        setUp(false);   
        System.assertEquals(null, ApplicationFilingChecklistServices.getAppFillingChecklistByTaskItemId(testTaskItemList[0].Id));           
        testAppFillCheckList[0].Task_Item__c = testTaskItemList[0].Id;
            insert testAppFillCheckList;
        
        Test.startTest();
            Application_Filing_Checklist__c testApp = ApplicationFilingChecklistServices.getAppFillingChecklistByTaskItemId(testTaskItemList[0].Id);
        Test.stopTest();
        
        System.assertEquals(testAppFillCheckList[0].Id, testApp.Id);
    }
}