@isTest
private class TestConstructionFilingChecklistServices {
    private static final Integer NUMBER_TO_CREATE = 5; 
    private static List<Work_Permit_Filing_Checklist__c> testWorkPermitFillingCheckList;
    private static List<Task_Item__c> testTaskItemList; 
    
    
    private static void setUp(Boolean doInsert){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, true);
        testWorkPermitFillingCheckList = TestingUtils.createWorkPermitFillingChecklistList(NUMBER_TO_CREATE, doInsert);     
    }
    
    @istest(seeAllData = false) private static void testGetConstructionFillingChecklistByTaskItemId(){
        setUp(false);
        
        for(Work_Permit_Filing_Checklist__c item : testWorkPermitFillingCheckList){
            item.Task_Item__c = testTaskItemList[0].Id;
        }
            insert testWorkPermitFillingCheckList;
        
        Test.startTest();
            Work_Permit_Filing_Checklist__c testWorkPermitFillingCheck = ConstructionFilingChecklistServices.getConstructionFillingChecklistByTaskItemId(testTaskItemList[0].Id);
        Test.stopTest();            
        
        System.assertEquals(testWorkPermitFillingCheckList[0].Id, testWorkPermitFillingCheck.Id);
        System.assertEquals(testWorkPermitFillingCheckList[0].Is_Construction_Checklist_Not_Required__c, testWorkPermitFillingCheck.Is_Construction_Checklist_Not_Required__c);
        System.assertEquals(testWorkPermitFillingCheckList[0].Is_Construction_Fees_Not_Required__c, testWorkPermitFillingCheck.Is_Construction_Fees_Not_Required__c);
        System.assertEquals(testWorkPermitFillingCheckList[0].Is_Construction_Scope_Not_Required__c, testWorkPermitFillingCheck.Is_Construction_Scope_Not_Required__c);
        System.assertEquals(testWorkPermitFillingCheckList[0].Is_Construction_Technical_Not_Require__c, testWorkPermitFillingCheck.Is_Construction_Technical_Not_Require__c);       
    }   
    
    @istest(seeAllData = false) private static void testGetConstructionFillingChecklistByTaskItemIdNullTest(){
        setUp(false);
        
        for(Work_Permit_Filing_Checklist__c item : testWorkPermitFillingCheckList){
            item.Task_Item__c = testTaskItemList[0].Id;
        }
            insert testWorkPermitFillingCheckList;
            
        Test.startTest();
            System.assertEquals(null, ConstructionFilingChecklistServices.getConstructionFillingChecklistByTaskItemId(testTaskItemList[1].Id));
        Test.stopTest();    
    }
}