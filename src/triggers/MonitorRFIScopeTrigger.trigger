trigger MonitorRFIScopeTrigger on Monitor_RFI_Scope__c (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        //MonitorRFIScopeServices.lockOldMonitorRFIScope(Trigger.new);
    
    }
}