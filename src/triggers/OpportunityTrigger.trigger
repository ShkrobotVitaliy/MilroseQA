trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
	if(Trigger.isBefore) { //MRS 7407
		OpportunityServices.setOpportunityFollowUpHours(Trigger.new);
	}
	if(PreventTwiceExecution.opportunityFirstRun) { //MRS 7468
		if(Trigger.isAfter) {
			OpportunityServices.sendEmailNotificationToUsers(OpportunityServices.filteredOpportunitiesThatMustBeEmailed(Trigger.new)); // MRS 7241
			StoredDocumentServices.createFolders(StoredDocumentServices.filterIfFoldersCreated(Trigger.newMap.keySet())); // MRS 7225
			PreventTwiceExecution.opportunityFirstRun = false;
		}
	}
}