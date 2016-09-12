global class EmailTest implements Messaging.InboundEmailHandler {

  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
  
    Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
   
    String myPlainText= email.plainTextBody;
    List<Task> newTask = new List<Task>();

    try {

      Contact vCon = [SELECT Id, Name, Email FROM Contact WHERE Email = :email.fromAddress LIMIT 1];

      newTask.add(new Task(Description =  myPlainText,
           Priority = 'Normal',
           Status = 'Inbound Email',
           Subject = email.subject,
           IsReminderSet = true,
           ReminderDateTime = System.now()+1,
           WhoId =  vCon.Id));
      
     insert newTask;   
      
    }

    // If an exception occurs when the query accesses the contact record, a QueryException is called.
    // The exception is written to the Apex debug log.

   catch (QueryException e) {

       System.debug('test: ' + e);

   }
   
   result.success = true;
   return result;
  
  }
}