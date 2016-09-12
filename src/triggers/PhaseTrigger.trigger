trigger PhaseTrigger on Phase__c( before insert, before update ) {
    if( Trigger.isBefore ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            PhaseServices.populatePhaseNames( Trigger.new );
        }
    }
}