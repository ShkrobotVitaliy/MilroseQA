global class SendOpportunitiesFollowUps implements Schedulable {
	global void execute(SchedulableContext sc) {
		String dayOfWeek = DateTime.now().format('E');
		if(dayOfWeek != 'Sat' && dayOfWeek != 'Sun') {
			List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> ();
			Integer hour = Datetime.now().hour();
			for(Opportunity opp : [SELECT Id, Name, Salesperson__c
								   FROM Opportunity
								   WHERE StageName != 'Not Awarded (Lost to Competition)'
										AND StageName != 'Awarded'
										AND StageName != 'Canceled (Client Decided Not to Proceed)'
										AND StageName != 'Withdrawn (We Decided Not to Proceed)'
										AND StageName != 'Expired (Older than 6 Months)'
										AND Salesperson__c != null
										AND Date_of_Next_Follow_up__c < : (!Test.isRunningTest()) ? Date.today().addDays(1) : null
										AND Email_Hour__c = :hour]) {
				Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
		        emailMsg.setTargetObjectId(opp.Salesperson__c);
		        emailMSg.saveAsActivity = false;
				emailMsg.setBccSender(false);
				emailMsg.setUseSignature(false);
				emailmsg.setHtmlBody('<html>You have a follow-up scheduled today for the <a href="'
									+ System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id+'">' + opp.Name + '</a> opportunity.<br/>'
									+ 'Please follow-up, update the record, and/or adjust the “Date of the Next Follow-up” field if applicable.<br/><br/>'
									+ 'To stop these emails from sending in the near future:<br/>'
									+ '     1. Select a date in the future for the “Date of Next Follow-up” field.<br/>'
									+ '     2. Delete the date in the “Date of Next Follow-up” field.<br/>'
									+ '     3. Update the status of the Opportunity to: “Not Awarded”, “Awarded”, “Canceled”, “Withdrawn”, or “Expired”.<br/><br/>'
									+ '<i>Note: Emails will continue to send on each business day until one of the above actions occurs.</i></html>');
				emailMsg.setSubject('Follow-up Scheduled for ' + opp.Name);
				messages.add(emailMsg);			
			}

			Messaging.sendEmail(messages);
		}		
	}
}