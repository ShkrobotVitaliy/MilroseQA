trigger ContactTrigger on Contact( before insert, before update, after update ) {
	if ( Trigger.isAfter ){
		if ( Trigger.isUpdate ){
			//MRS-7207
			ContactServices.validateContactsAlternateARStatementRecipient( ContactServices.filterContactWithChangesAlternateARStatementRecipient( Trigger.new, Trigger.oldMap ) );
			ContactServices.validateInactiveContactsWithAlternateARStatementRecipient( ContactServices.filterContactWithChangesActiveField( Trigger.new, Trigger.oldMap ) );
		}
	}
}