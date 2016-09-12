trigger TaskTrigger on Task (before insert, after insert, before update) {
	if ( Trigger.isBefore ){
		if ( Trigger.isInsert || Trigger.isUpdate ){
			TaskServices.connectDummySharingRecordToTask( TaskServices.filteredTaskWithEmptyParentRecord( Trigger.new ) );
		}
	}

	if ( Trigger.isInsert && Trigger.isAfter ){
		AttachmentServices.moveAttachmentsToStoredDocuments( AttachmentServices.findAttachmentsForTasks( Trigger.new ) );
		TaskServices.populateContactSendersList( TaskServices.filteredCheckEmailTrecingList( Trigger.new ) );
	}
}