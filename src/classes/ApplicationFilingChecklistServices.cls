public with sharing class ApplicationFilingChecklistServices {
    
    public static Application_Filing_Checklist__c getAppFillingChecklistByTaskItemId(Id taskItemId) {
        List<Application_Filing_Checklist__c> appFilingList = new List<Application_Filing_Checklist__c>([SELECT Id, Is_Not_Property_Required__c, Is_App_Checklist_Not_Required__c, 
                                                                                                                Is_Not_Scope_Required__c
                                                                                                         FROM Application_Filing_Checklist__c 
                                                                                                         WHERE Task_Item__c =: taskItemId]); 
                
        if (null == appFilingList || appFilingList.isEmpty()) {
            return null;
        
        }
        
        return appFilingList.get(0);
    
    }

}