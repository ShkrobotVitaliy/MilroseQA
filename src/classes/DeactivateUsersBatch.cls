global class DeactivateUsersBatch implements Database.Batchable<sObject> {
	String query;
	global final List<Id> usersThatShouldReceiveEmails;

	global DeactivateUsersBatch(List<Id> usersThatShouldReceiveEmails, List<User> deactivatedUsers) {
		this.usersThatShouldReceiveEmails = usersThatShouldReceiveEmails;
		query = 'SELECT Id, LastModifiedById FROM User WHERE (Id IN (';
		for (User deactivatedUser : deactivatedUsers){
			query += '\'' + deactivatedUser.Id + '\',';
		}
		query = query.removeEnd(',') + '))';
		System.Debug(LoggingLevel.ERROR, '^^^ query = ' + query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<User> deactivatedUsers = (List<User>)scope;

		for (User deactivatedUser : deactivatedUsers){
			EmailMessageService.sendEmailNotificationDeactivateUser(usersThatShouldReceiveEmails, deactivatedUser.Id);
		}
	}

	global void finish(Database.BatchableContext BC) {}
}