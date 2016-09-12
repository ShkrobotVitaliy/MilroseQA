public with sharing class SignOffFilingChecklistServices {
    
    public static Application_Sign_Off_Scope__c getSignOffFillingChecklistByTaskItemId(final Id taskItemId) {
        if (String.isBlank(taskItemId)) {
           throw new ErrorException('Parameter Task Item Id can not be empty!');
        
        }
    
        List<Application_Sign_Off_Scope__c> signOffFilingList = new List<Application_Sign_Off_Scope__c>([SELECT Is_Sign_Off_Checklist_Not_Required__c
                                                                                                         FROM Application_Sign_Off_Scope__c
                                                                                                         WHERE Task_Item__c =: taskItemId]); 
                
        if (null == signOffFilingList || signOffFilingList.isEmpty()) {
            return null;
        
        }
        return signOffFilingList.get(0);
    
    }
    
     public static List<Application_Sign_Off_Scope__c> getSignOffFillingChecklistListByTaskItemId(final Id taskItemId) {
        if (String.isBlank(taskItemId)) {
           throw new ErrorException('Parameter Task Item Id can not be empty!');
        
        }
    
        List<Application_Sign_Off_Scope__c> signOffFilingList = new List<Application_Sign_Off_Scope__c>([SELECT Is_Sign_Off_Checklist_Not_Required__c, Is_Fire_Alarm_Not_Required__c, Is_General_Construction_Not_Required__c,
                                                                                                                Is_Mechanical_Not_Required__c, Is_Plumbing_Not_Required__c, Is_Sprinkler_Not_Required__c,
                                                                                                                Is_Structural_Not_Required__c, Work_Type__c
                                                                                                         FROM Application_Sign_Off_Scope__c
                                                                                                         WHERE Task_Item__c =: taskItemId]); 
                
        if (null == signOffFilingList || signOffFilingList.isEmpty()) {
            return null;
        
        }
        return signOffFilingList;
    
    }

}