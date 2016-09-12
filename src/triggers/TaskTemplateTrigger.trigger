trigger TaskTemplateTrigger on Task_Template__c (before insert, after insert) {

    if( Trigger.isBefore && Trigger.isInsert ) {
        TaskTemplateServices.updateTaskTemplateNames( Trigger.new );
    }

    if( Trigger.isAfter && Trigger.isInsert ) {
        TaskTemplateServices.populateSuccessorPredecessorTasks( Trigger.new );
    }
    
}