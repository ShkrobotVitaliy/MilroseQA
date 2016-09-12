trigger CheckRequestTrigger on Check__c (before insert, before update, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        MilroseDevHelper.setWorkType(Trigger.new);
    
    }
    
    if (Trigger.isUpdate) {
        
        if (Trigger.isBefore) {
            //MRS-6274
            CheckServices.validateChangeChangeAccountCheckAmount(CheckServices.filteredChecktWithChangeAccountCheckAmount(Trigger.new, Trigger.oldMap));

            CheckServices.sendCheckRequestReminder(CheckServices.getGroupNumbersForReminder(Trigger.new, Trigger.oldMap));

        }
        
        if (Trigger.isAfter) {
            CheckServices.completeTasks(CheckServices.filterChecksForCompleteTasks(Trigger.newMap));
            
        }
    
    }

}