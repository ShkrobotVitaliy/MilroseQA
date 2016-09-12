trigger RosterEmailJunctionTrigger on Roster_Email_Junction__c (before update) {
	RosterEmailJunctionServices.countRemindersForProposalsAndCOs( RosterEmailJunctionServices.filterJunctionsToCountReminders(Trigger.new, Trigger.OldMap) );
	RosterEmailJunctionServices.sendEmailsToRecipients( RosterEmailJunctionServices.filterJunctionsToSendEmail(Trigger.new, Trigger.OldMap) );
}