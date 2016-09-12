trigger RFIScopeTrigger on RFI_Scope__c (before insert, after insert, before update, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        RFIScopeServices.insertRFIDescriptions(Trigger.new);
    
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            RFIWorkTypeServices.createRFIWorkType(Trigger.newMap);
            StoredDocumentServices.createFolders(StoredDocumentServices.filterIfFoldersCreated(Trigger.newMap.keySet()));
        
        }
        
        if (Trigger.isUpdate) {
            RFIScopeServices.completeTasks(Trigger.new, Trigger.oldMap);
        
        }
    
    }

}