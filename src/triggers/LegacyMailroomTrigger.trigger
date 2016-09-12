trigger LegacyMailroomTrigger on Legacy_Mailroom__c(after insert) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LegacyBillingItemServices.buildRelationsBetweenMailroomAndLBIs(Trigger.new);
        
        }
    
    }

}