global class CreateBatchStatementOfAccountsAttach implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global final DateTime PROCESSING_DATE_TIME;

	public CreateBatchStatementOfAccountsAttach(DateTime executingDate) {
		this.PROCESSING_DATE_TIME = executingDate;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		String query =  'SELECT Id, Subject_for_SOA_email__c, ' +
						'    (Select Id, Subject, WhoId, CreatedDate From Tasks Where (Subject Like \'Email: %\') And CreatedDate >= : PROCESSING_DATE_TIME  Order By CreatedDate Desc ) ' +
						'FROM Contact ' +
						'WHERE (Email_Statements_Job_Error__c = false OR EmailBouncedDate != null) AND ' +
						'	(Email_Statement_Sent_Date_Time__c >= : PROCESSING_DATE_TIME Or Additional_Email_Statement_Sent_Date__c >= : PROCESSING_DATE_TIME)';

		System.Debug( LoggingLevel.ERROR, '^^^ query = ' + query);

		return Database.getQueryLocator(query);
	}

	global void execute( Database.BatchableContext BC, List<Sobject> scope ) {
		List<Contact> contacts = (List<Contact>)scope;

		Map<Id, Set<Id>> contactWithAccounts = new Map<Id, Set<Id>>();
		for (Contact contact : contacts){
			AccountReportController accountReport = new AccountReportController( contact.Id );
			try{
				Map<Id, String> accountIdToAccountName = accountReport.findAccounts( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT, false );
				contactWithAccounts.put(contact.Id, accountIdToAccountName.keySet());
			} catch (Exception ex){
				contactWithAccounts.put(contact.Id, new Set<Id>());
			}
		}

		DDPRequest ddpRequest = new DDPRequest();

		List<String> taskIdsForLoopDDP = new List<String>();
		List<Task> taskForAttachments = new List<Task>();
		Boolean doSendRequest = false;
		for (Contact contact : contacts){
			for (Task task : contact.Tasks){
				if (Task.Subject.contains( 'Email: ' + contact.Subject_for_SOA_email__c ) ){
					taskIdsForLoopDDP.add(String.valueOf(task.Id));
					taskForAttachments.add(task);
					continue;
				}
			}
		}
		List<LStore__Stored_Document__c> files = [SELECT Id, LStore__File_Name__c, LStore__Folder__c, Related_Object_Id__c
												  FROM LStore__Stored_Document__c
												  WHERE Related_Object_Id__c IN : taskIdsForLoopDDP AND LStore__File_Name__c != null];

		Set<Id> taskIds = new Set<Id>();
		for ( LStore__Stored_Document__c file :  files ){
			taskIds.add(Id.valueOf(file.Related_Object_Id__c));
		}

		for (Task task : taskForAttachments){
			if ( !taskIds.contains( Id.valueOf(task.Id) ) ){
				for(Id accountId : contactWithAccounts.get(task.WhoId)){
					ddpRequest.addConfiguration(task.Id, DDPHelperServices.STATEMENT_OF_ACCOUNTS_TASK_DOCUMENT, 'Attach', accountId, null, null, null);
					doSendRequest = true;
				}
			}
		}

		if (!Test.isRunningTest() && doSendRequest) ddpRequest.sendRequestsForBatch();
	}

	global void finish(Database.BatchableContext BC) {}
}