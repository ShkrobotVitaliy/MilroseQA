@isTest
private class TestFormAssignmentsServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static User testUser;
    private static User projectManagerUser;
    private static Account testAccount;
    private static Contact testContact;
    private static Building__c testBuilding;
    private static List <Project_Profile__c> testProjectProfileList;
    private static List <Form_Item__c> testFormItemList;
    
    private static void setUp(Boolean doInsert){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testUser = TestingUtils.createUsers(1, true)[0];
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
            testContact.AccountId = testAccount.Id;
            insert testContact;
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, null, 'TestStreet', 'TestHouse', 'TestCity', 'TestZip', true)[0];  
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
        testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE, doInsert);                                                                       
    }
    
    private static testmethod void testCreateFormAssignments(){
        setUp(false);
        for(Form_Item__c item : testFormItemList){
            item.Project__c  = testProjectProfileList[0].Id;
            item.Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;
        }
            
        
        Test.startTest();
            insert testFormItemList;
            
        Test.stopTest();
        
        /*Map<Id,Form_Item__c> testMap = new Map<Id,Form_Item__c>();
        List<Form_Assignment__c> testFromAssignment = [SELECT Id,Project__c,Status__c,Form_Item__c FROM Form_Assignment__c WHERE Project__c = : testProjectProfileList[0].Id];
        
        System.assertEquals(testFormItemList.size(), testFromAssignment.size());
        for(Form_Item__c item : testFormItemList){
            testMap.put(item.Id,item);
        }
        for(Form_Assignment__c item : testFromAssignment){
            System.assertEquals(testMap.get(item.Form_Item__c).Form_Status__c, item.Status__c);
            System.assertEquals(testMap.get(item.Form_Item__c).Project__c, item.Project__c);
        }*/

        System.assert(! getAllFormAssignments().isEmpty() );
    }

    private static testmethod void testUpdateFormAssignmentsStatusSecondCondition(){
        setUp(false);
        Map<Id,Form_Item__c> testOldFormItemMap = new Map<Id,Form_Item__c>();
        for(Form_Item__c item : testFormItemList){                  
            item.Project__c  = testProjectProfileList[0].Id;
            testOldFormItemMap.put(item.Id,item);                       
        }
            insert testFormItemList;
            
        for(Form_Item__c item : testFormItemList){      
            item.Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;  
        }
            update testFormItemList;
            
        Test.startTest();
            FormAssignmentsServices.updateFormAssignmentsStatus(testFormItemList);
        Test.stopTest();
        
        List<Form_Assignment__c> testFromAssignment = [SELECT Id,Project__c,Status__c,Form_Item__c FROM Form_Assignment__c WHERE Project__c = : testProjectProfileList[0].Id];
        
        for(Form_Assignment__c item : testFromAssignment){
            System.assertEquals(FormItemsServices.FORM_ITEM_STATUS_GENERATED, item.Status__c);
        }
    
    }
    
    
    private static List<Form_Assignment__c> getAllFormAssignments(){
        return [SELECT Id, Project__c, Status__c, Form_Item__c 
                FROM Form_Assignment__c];
    }
}