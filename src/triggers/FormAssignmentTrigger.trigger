trigger FormAssignmentTrigger on Form_Assignment__c (after update) {

	if( Trigger.isAfter && Trigger.isUpdate ) {
		EventServices.manageEventsForSignatureSealsTaskItem( FormAssignmentsServices.filterFormAssignmentsForEventManagement( Trigger.new, Trigger.oldMap ) );
	}

}