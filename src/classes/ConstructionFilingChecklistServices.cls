public with sharing class ConstructionFilingChecklistServices {
    
    public static Work_Permit_Filing_Checklist__c getConstructionFillingChecklistByTaskItemId(Id taskItemId) {
        List<Work_Permit_Filing_Checklist__c> workPermitFilingList = new List<Work_Permit_Filing_Checklist__c>([SELECT Is_Construction_Checklist_Not_Required__c, Is_Construction_Fees_Not_Required__c, Is_Construction_Scope_Not_Required__c, 
                                                                                                                       Is_Construction_Technical_Not_Require__c 
                                                                                                                FROM Work_Permit_Filing_Checklist__c
                                                                                                                WHERE Task_Item__c =: taskItemId]); 
                
        if (null == workPermitFilingList || workPermitFilingList.isEmpty()) {
            return null;
        
        }
        
        return workPermitFilingList.get(0);
    
    }

}