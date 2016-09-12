trigger DocusignStatusTrigger on dsfs__DocuSign_Status__c( after update ) {
    if( Trigger.isAfter ) {
        if( Trigger.isUpdate ) {
            DocusignServices.setEsignedFlagOnProposalOrChangeOrder( DocusignServices.filterCompletedDocusignStatuses( Trigger.new, Trigger.oldMap ) );
            DocusignServices.removeUnfinishedFollowUpReminders( DocusignServices.filterDocusignStatusesToRemoveReminders( Trigger.new, Trigger.oldMap ) );
        }
    }
}