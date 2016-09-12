trigger ManageResponseFromAuthorityTrigger on Manage_Response_From_Authority__c ( before update ) {
	ManageResponseFromAuthorityServices.createEventsForProjectManager( ManageResponseFromAuthorityServices.filterResponseRecordsToCreateReminders( Trigger.newMap, Trigger.oldMap ) );
	ManageResponseFromAuthorityServices.deleteEventsForProjectManager( ManageResponseFromAuthorityServices.filterResponseRecordsToDeleteReminders( Trigger.newMap, Trigger.oldMap ) );
}