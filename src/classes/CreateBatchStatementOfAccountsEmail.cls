global class CreateBatchStatementOfAccountsEmail implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
    private static String STATEMENT_CHECKED_EMAILTEMPLATE_NAME = 'Contact_Client_Statement_Doc_Checked';
    private static String STATEMENT_UNCHECKED_EMAILTEMPLATE_NAME = 'Contact_Client_Statement_Doc_Unchecked';
    private static String EMAIL_SEPARATOR = ';';

    global void execute( SchedulableContext sc ) {
        CreateBatchStatementOfAccountsEmail batch = new CreateBatchStatementOfAccountsEmail();
        Database.executeBatch( batch, 1 );
    }

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        List<DDP_Helper__c> confirmDDPHelperList = [SELECT Id, Is_Day_Of_Month__c, Day_Of_Month__c, Sunday_Or_Saturday__c, Number_Week__c, Email_Statements_Job_Ex_DateTime__c,
                                                            Automatically_Email_Statements__c, Text4__c
                                                    FROM DDP_Helper__c
                                                    WHERE Type__c = : DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1];

        DateTime executeDateTimeValue;

        if ( !confirmDDPHelperList.isEmpty() && confirmDDPHelperList[0].Automatically_Email_Statements__c ){
            executeDateTimeValue = confirmDDPHelperList[0].Email_Statements_Job_Ex_DateTime__c == null ? DateTime.now() : confirmDDPHelperList[0].Email_Statements_Job_Ex_DateTime__c;
        }

        if ( executeDateTimeValue > DateTime.now() || confirmDDPHelperList.isEmpty() || !confirmDDPHelperList[0].Automatically_Email_Statements__c ){
            return Database.getQueryLocator( 'Select Id FROM Contact WHERE Id = null' );
        }
        Set<Id> testIds = new Set<Id>{ Id.valueOf('003A000000tRAKT') };
        List<Id> accountingContactIds = new List<Id>();

		List<AggregateResult> accountingContacts1 = [ SELECT Accounting_Contact__c accid
                                                     FROM Project_Profile__c
                                                     WHERE /*Accounting_Contact__c IN: testIds AND*/ Accounting_Contact__c != null
                                                       AND Accounting_Contact__r.Email != null
                                                       AND Accounting_Contact__r.Is_Active__c = true
                                                       AND Accounting_Contact__r.EmailBouncedDate = null
                                                       AND Accounting_Contact__r.EmailBouncedReason = null
                                                       AND Billing_Company_Name__r.Do_Not_Send_Statements_Automatically__c = false
                                                       AND Accounting_Contact_Company__r.Do_Not_Send_Statements_Automatically__c = false
                                                       AND (Accounting_Contact__r.Email_Statement_Sent_Date_Time__c = null Or
                                                            Accounting_Contact__r.Email_Statement_Sent_Date_Time__c < : executeDateTimeValue)
                                                     GROUP BY Accounting_Contact__c ];
        for( AggregateResult ar : accountingContacts1 ) {
            accountingContactIds.add( (Id)ar.get( 'accid' ) );
        }

		List<AggregateResult> accountingContacts = [ SELECT Accounting_Contact__c accid
                                                     FROM Billing_Line_Item__c
                                                     WHERE /*Accounting_Contact__c IN: testIds AND*/ Accounting_Contact__c != null
                                                       AND ( NOT Accounting_Contact__c IN: accountingContactIds )
						       AND Accounting_Contact__r.Email != null
                                                       AND Accounting_Contact__r.Is_Active__c = true
                                                       AND Accounting_Contact__r.EmailBouncedDate = null
                                                       AND Accounting_Contact__r.EmailBouncedReason = null
                                                       AND Project_Profile__r.Billing_Company_Name__r.Do_Not_Send_Statements_Automatically__c = false
                                                       AND Accounting_Contact_Company__r.Do_Not_Send_Statements_Automatically__c = false
                                                       AND (Accounting_Contact__r.Email_Statement_Sent_Date_Time__c = null Or
                                                            Accounting_Contact__r.Email_Statement_Sent_Date_Time__c < : executeDateTimeValue)
                                                     GROUP BY Accounting_Contact__c ];
        for( AggregateResult ar : accountingContacts ) {
            accountingContactIds.add( (Id)ar.get( 'accid' ) );
        }

        if( accountingContactIds.isEmpty() ) {
            accountingContactIds.add( null );
        }

        String queryString = 'SELECT Id, AccountId, EmailBouncedDate, EmailBouncedReason, Email, Is_Active__c, Email_Statement_Sent_Date_Time__c, Additional_A_R_Statement_Recipients_cc__c, ' +
                                'Alternate_A_R_Statement_Recipient__c, Alternate_A_R_Statement_Recipient__r.Additional_A_R_Statement_Recipients_cc__c, ' +
                                'Alternate_A_R_Statement_Recipient__r.Is_Active__c, Alternate_A_R_Statement_Recipient__r.EmailBouncedDate, ' +
                                'Alternate_A_R_Statement_Recipient__r.EmailBouncedReason, Alternate_A_R_Statement_Recipient__r.Email, ' +
                                'Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Sent_Date__c, Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Number__c ' +
                             'FROM Contact '+
                             'WHERE Account.Do_Not_Send_Statements_Automatically__c = false ' +
                                  'AND ((Is_Active__c = true and Alternate_A_R_Statement_Recipient__c = null) Or (Alternate_A_R_Statement_Recipient__r.Is_Active__c = true and Alternate_A_R_Statement_Recipient__c != null)) ' +
                                  'AND ((EmailBouncedDate = null and Alternate_A_R_Statement_Recipient__c = null) Or (Alternate_A_R_Statement_Recipient__r.EmailBouncedDate = null and Alternate_A_R_Statement_Recipient__c != null)) ' +
                                  'AND ((EmailBouncedReason = null and Alternate_A_R_Statement_Recipient__c = null) Or (Alternate_A_R_Statement_Recipient__r.EmailBouncedReason = null and Alternate_A_R_Statement_Recipient__c != null)) ' +
                                  'AND ((Email != null and Alternate_A_R_Statement_Recipient__c = null) Or (Alternate_A_R_Statement_Recipient__r.Email != null and Alternate_A_R_Statement_Recipient__c != null)) ' +
                                  'AND (Email_Statement_Sent_Date_Time__c = null Or Email_Statement_Sent_Date_Time__c < : executeDateTimeValue) ';

        //MRS-7123
        Map<Id, Set<String>> accountingWithContactMap = new Map<Id, Set<String>>();

        List<AggregateResult> arList = [SELECT Accounting_Contact_Company_Reference__c accId, Accounting_Contact_Reference__c accContactName
                                        FROM c2g__codaInvoice__c
                                        WHERE (cl_Project_Profile__c = null And Project_Mi7__c = null)
                                             AND Accounting_Contact_Reference__c != null
                                             AND Accounting_Contact_Company_Reference__c != null
                                             AND Accounting_Contact_Company_Reference__r.Do_Not_Send_Statements_Automatically__c = false
                                             GROUP BY Accounting_Contact_Company_Reference__c, Accounting_Contact_Reference__c];

        for (AggregateResult ar : arList){
            Id accountId = (Id)ar.get( 'accid' );
            String conName = (String)ar.get( 'accContactName' );
            conName = conName.replace('\'', '\\\'');
            if (!accountingWithContactMap.containsKey(accountId)){
                accountingWithContactMap.put(accountId, new Set<String>());
            }
            accountingWithContactMap.get(accountId).add(conName);
        }

        String whereString = ' AND (Id IN : accountingContactIds';

        if (!accountingWithContactMap.isEmpty()){
            whereString += ' OR (';
            for(Id accId : accountingWithContactMap.keySet()){
                whereString += '(AccountId = \'' + String.valueOf(accId).SubString(0, 15) + '\' And (Name=\'';
                List<String> contactNamesList = new List<String>();
                contactNamesList.addAll(accountingWithContactMap.get(accId));
                whereString += String.join(contactNamesList, '\' or Name=\'');
                whereString += '\')) OR ';
            }
            whereString = whereString.removeEnd(' OR ');
            whereString += ')';
        }
        whereString += ')';

        queryString = queryString + whereString;

        System.debug( LoggingLevel.Error, 'xxx accountingContactIds: ' + accountingContactIds.size() );
        return Database.getQueryLocator( queryString );
    }

    //Execute method
    global void execute( Database.BatchableContext BC, List<Sobject> scope ) {
        List<Contact> scopeList = (List<Contact>)scope;

        String sessionId;
        List<DDP_Helper__c> ddpHelperList = [SELECT Id, Automatically_Email_Statements__c, Exclude_Unapplied_Documents__c, Email_Statements_Job_Ex_DateTime__c
                                             FROM DDP_Helper__c
                                             WHERE Type__c = : DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1];

        DateTime executeDateTimeValue = (!ddpHelperList.isEmpty() && ddpHelperList[0].Email_Statements_Job_Ex_DateTime__c != null) ? ddpHelperList[0].Email_Statements_Job_Ex_DateTime__c : DateTime.now();

        String templateName = !ddpHelperList.isEmpty() && !ddpHelperList[0].Exclude_Unapplied_Documents__c ? STATEMENT_UNCHECKED_EMAILTEMPLATE_NAME : STATEMENT_CHECKED_EMAILTEMPLATE_NAME;

        List<EmailTemplate> emailTemplateList = [SELECT Id, Name, DeveloperName, Subject
                                                 FROM EmailTemplate
                                                 WHERE DeveloperName = : templateName];

        Site_URL__c site = Site_URL__c.getValues( UserInfo.getOrganizationId().subString(0, 15) );
        if( site != null ) {
            UsernamePasswordFlow upf = new UsernamePasswordFlow( site.Token_Endpoint__c, site.Login_to_SF__c, site.Password__c, site.Client_Id__c, site.Client_Secret__c );
            String newSessionId = upf.requestAccessToken();
            sessionId = newSessionId;
        } else {
            System.debug( Logginglevel.Error, 'xxx The system can not find the Site_URL__c Custom Settings record for ' + UserInfo.getOrganizationId().subString(0, 15) + ' organization!' );
        }
        System.debug( Logginglevel.Error, 'xxx sessionId: ' + sessionId );

        if( sessionId != null || Test.isRunningTest()) {
            for( Contact contact : scopeList ) {
                if (contact.EmailBouncedDate != null && contact.EmailBouncedReason != null){
                    System.debug( LoggingLevel.Error, 'xxx ' + 'Emailing was skipped: incorrect Email address.' + ' Emailing was skipped.'); //any handler
                    update new Contact(Id = contact.Id, Email_Statement_Sent_Date_Time__c = DateTime.now(), Email_Statement_Error_Reason__c = 'Emailing was skipped: incorrect Email address for this contact.', Email_Statements_Job_Error__c = true);
                    continue;
                }

                System.debug( LoggingLevel.Error, 'xxx contact.Id: ' + contact.Id );

                Map<Id, String> accountIdToAccountName = new Map<Id, String>();
                Map<Id, Account> idAccountToDoNotSend = new Map<Id, Account>();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'accountsreceivable@milrose.com'];
                AccountReportController accountReport = new AccountReportController( contact.Id );

                try {
                    accountIdToAccountName = accountReport.findAccounts( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT, false );
                    idAccountToDoNotSend = new Map<Id, Account>([Select Id, Do_Not_Send_Statements_Automatically__c From Account Where Id IN: accountIdToAccountName.keySet()]);
                } catch( Exception e ) {
                    System.debug( LoggingLevel.Error, 'xxx ' + e.getMessage() + ' Emailing was skipped.'); //any handler
                    if( e.getMessage().contains('No results were found for Statement of Accounts.') ){
                        update new Contact(Id = contact.Id, Email_Statement_Error_Reason__c = '', Email_Statements_Job_Error__c = false );
                        if (Test.isRunningTest()){
                            accountIdToAccountName.put(contact.AccountId, '');
                            idAccountToDoNotSend = new Map<Id, Account>{contact.AccountId => new Account (Id = contact.AccountId, Do_Not_Send_Statements_Automatically__c = false)};
                        }
                    }else{
                        update new Contact(Id = contact.Id, Email_Statement_Sent_Date_Time__c = DateTime.now(), Email_Statement_Error_Reason__c = 'Emailing was skipped: ' + e.getMessage(), Email_Statements_Job_Error__c = true);
                    }
                    if (!Test.isRunningTest()) continue;
                }

                if( !accountIdToAccountName.keySet().isEmpty() ) {
                    List<String> ccEmailsList = new List<String>();
                    Set<String> uniqueEmails = new Set<String>();
                    if ( contact.Alternate_A_R_Statement_Recipient__c != null ){
                        //if ( contact.Email != null ){
                        //    ccEmailsList.add(contact.Email);
                        //}
                        if ( !String.isEmpty(contact.Alternate_A_R_Statement_Recipient__r.Additional_A_R_Statement_Recipients_cc__c) ){
                            for (String emailString : (contact.Alternate_A_R_Statement_Recipient__r.Additional_A_R_Statement_Recipients_cc__c.replace(',', EMAIL_SEPARATOR)).split(EMAIL_SEPARATOR)){
                                if (!String.isEmpty(emailString.trim())){
                                    uniqueEmails.add(emailString.trim());
                                }
                            }
                        }
                    }
                    if ( !String.isEmpty(contact.Additional_A_R_Statement_Recipients_cc__c) ){
                        for (String emailString : (contact.Additional_A_R_Statement_Recipients_cc__c.replace(',', EMAIL_SEPARATOR)).split(EMAIL_SEPARATOR)){
                            if (!String.isEmpty(emailString.trim())){
                                uniqueEmails.add(emailString.trim());
                            }
                        }
                    }
                    uniqueEmails.remove(null);
                    uniqueEmails.remove('');

                    for (String emailItem : uniqueEmails){
                        if (ccEmailsList.size() < 25){
                            ccEmailsList.add(emailItem);
                        } else {
                            break;
                        }
                    }

                    Boolean isEmailReserved = false;
                    try {
                        if( !Test.isRunningTest() ) {
                            Messaging.reserveSingleEmailCapacity( 1 + 40 + ccEmailsList.size() ); //always reserve 1 more than needed
                        }
                        isEmailReserved = true;
                    } catch( Exception e ) {
                        System.debug( LoggingLevel.Error, 'xxx Daily email limit has been achieved.'); //any handler
                        continue;
                    }

                    if( isEmailReserved ) {
                        try{
                            Id emailTemplateId = emailTemplateList[0].Id;

                            Map<String, String> accountIdToReportLink = new Map<String, String>();
                            for( Id accountId : accountIdToAccountName.keySet() ) {
                                if( !idAccountToDoNotSend.get(accountId).Do_Not_Send_Statements_Automatically__c ) accountIdToReportLink.put( accountId, accountReport.getSoaReportSingleLink( accountId ) );
                            }
                            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                            for( String accountId : accountIdToReportLink.keySet() ) {
                                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                                attachment.setFileName( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT +
                                                        ' - ' +
                                                        MilroseDevHelper.getSafeFileName( accountIdToAccountName.get( accountId ) ) +
                                                        StoredDocumentServices.PDF_EXTENSION );
                                attachment.setContentType( 'application/pdf' );
                                attachment.setBody( StatementOfAccountsSenderRest.createStatementOfAccountsReport( accountIdToReportLink.get( accountId ).replaceFirst( AccountReportController.SOA_REPORT_LINK, '' ) + '&excldoc=' + ddpHelperList[0].Exclude_Unapplied_Documents__c, sessionId ) );
                                attachments.add( attachment );
                            }

					    	if( !accountIdToReportLink.isEmpty() ){
		                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		                            email.setOrgWideEmailAddressId(owea.get(0).Id);
					    if(contact.Alternate_A_R_Statement_Recipient__c != null ){
					    	email.setToAddresses(new List < String > {contact.Alternate_A_R_Statement_Recipient__r.Email});
						email.setTreatTargetObjectAsRecipient( false );
						email.setTargetObjectId( contact.Alternate_A_R_Statement_Recipient__c );
					    }else{
					    	email.setTargetObjectId( contact.Id );
					    }
					    if ( !ccEmailsList.isEmpty() ) email.setCCAddresses( ccEmailsList );
					    email.setTargetObjectId( contact.Id );
		                            email.setWhatId( contact.AccountId );
		                            email.setTemplateId( emailTemplateId );
		                            email.setFileAttachments( attachments );

		                    		if( !Test.isRunningTest() ) Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{ email }, false );
		                	}
						} catch (Exception ex){
	                        update new Contact(Id = contact.Id, Email_Statement_Sent_Date_Time__c = DateTime.now(), Email_Statement_Error_Reason__c ='Emailing was skipped: ' + ex.getMessage(), Email_Statements_Job_Error__c = true);
	                        continue;
	                    }
	                }
	            }
                List<Contact> contactUpdateList = new List<Contact>{new Contact( Id = contact.Id,
                                                                                 Email_Statement_Sent_Date_Time__c = DateTime.now(),
                                                                                 Email_Statement_Error_Reason__c = '',
                                                                                 Email_Statements_Job_Error__c = false )};

                if ( contact.Alternate_A_R_Statement_Recipient__c != null ){
                    Contact alternativeContact = new Contact( Id = contact.Alternate_A_R_Statement_Recipient__c,
                                                              Additional_Email_Statement_Sent_Date__c = DateTime.now(),
                                                              Additional_Email_Statement_Number__c = (contact.Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Sent_Date__c == null ||
                                                                                                      contact.Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Sent_Date__c < executeDateTimeValue ||
                                                                                                      contact.Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Number__c == null) ? 1 :
                                                                                                                        contact.Alternate_A_R_Statement_Recipient__r.Additional_Email_Statement_Number__c + 1 );
                    contactUpdateList.add(alternativeContact);
                }

                update contactUpdateList;
            }
        }

        /*System.debug( LoggingLevel.Error, 'xxx Limits.getCpuTime(): ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime() );
        System.debug( LoggingLevel.Error, 'xxx Limits.getDMLRows(): ' + Limits.getDMLRows() + ' of ' + Limits.getLimitDMLRows() );
        System.debug( LoggingLevel.Error, 'xxx Limits.getDMLStatements(): ' + Limits.getDMLStatements() + ' of ' + Limits.getLimitDMLStatements() );
        System.debug( LoggingLevel.Error, 'xxx Limits.getQueries(): ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries() );
        System.debug( LoggingLevel.Error, 'xxx Limits.getQueryRows(): ' + Limits.getQueryRows() + ' of ' + Limits.getLimitQueryRows() );
        System.debug( LoggingLevel.Error, 'xxx Limits.getQueryLocatorRows(): ' + Limits.getQueryLocatorRows() + ' of ' + Limits.getLimitQueryLocatorRows() );*/
    }

    global void finish(Database.BatchableContext BC) {
        Boolean isEmailReserved = false;
        try {
            if( !Test.isRunningTest() ) {
                Messaging.reserveSingleEmailCapacity( 1 + 40 ); //always reserve 1 more than needed
            }
            isEmailReserved = true;
        } catch( Exception e ) {
            System.debug( LoggingLevel.Error, 'xxx Daily email limit has been achieved.'); //any handler
        }

        if ( isEmailReserved ){
            List<DDP_Helper__c> confirmDDPHelperList = [SELECT Id, Is_Day_Of_Month__c, Day_Of_Month__c, Sunday_Or_Saturday__c, Number_Week__c, Email_Statements_Job_Ex_DateTime__c,
                                                                Email_Statements_Job_Hour__c, Automatically_Email_Statements__c, Text4__c, Exclude_Unapplied_Documents__c
                                                FROM DDP_Helper__c
                                                WHERE Type__c = : DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1];

            String emailTemplateSubject = 'Email: % ' + DDPHelperServices.STATEMENT_OF_ACCOUNTS_SUBJECT;

            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'accountsreceivable@milrose.com'];

            DateTime executeDateTimeValue;

            if ( !confirmDDPHelperList.isEmpty() ){
                executeDateTimeValue = confirmDDPHelperList[0].Email_Statements_Job_Ex_DateTime__c == null ? DateTime.now() : confirmDDPHelperList[0].Email_Statements_Job_Ex_DateTime__c;
            }

            if (executeDateTimeValue <= DateTime.now()){

                List<Contact> contactWithErrorsList = [SELECT Id, Email_Statement_Error_Reason__c, Email_Statements_Job_Error__c, Email_Statement_Sent_Date_Time__c, FirstName, LastName
                                                       FROM Contact
                                                       WHERE Email_Statements_Job_Error__c = true
                                                             AND Email_Statement_Sent_Date_Time__c >= : executeDateTimeValue];

                for (Contact contactItem : [SELECT Id, Email_Statement_Error_Reason__c, Email_Statements_Job_Error__c,
                									Email_Statement_Sent_Date_Time__c, FirstName, LastName, Additional_Email_Statement_Sent_Date__c,
                									EmailBouncedDate, EmailBouncedReason, Additional_Email_Statement_Number__c,
                                                (Select Id, WhoId, ActivityDate, CreatedDate
                                                 From Tasks
                                                 Where Subject Like : emailTemplateSubject
                                                 	And CreatedDate >= : executeDateTimeValue
                                                 Order by CreatedDate desc Limit 1)
                                            FROM Contact
                                            WHERE ( Email_Statements_Job_Error__c = false OR EmailBouncedDate != null )
                                                 AND (Email_Statement_Sent_Date_Time__c >= : executeDateTimeValue Or Additional_Email_Statement_Sent_Date__c >= : executeDateTimeValue)]){
                    if ( contactItem.Tasks.isEmpty() || contactItem.EmailBouncedDate != null ){
                        contactWithErrorsList.add( contactItem );
                    }
                }

                if ( !contactWithErrorsList.isEmpty() ){
                    String errorString = 'Error occured during sending emails to the following contacts:';

                    for (Contact contactWithErrorItem : contactWithErrorsList){
                        errorString += '\r\nContact Name \'' + contactWithErrorItem.FirstName + ' ' + contactWithErrorItem.LastName + '\' with id = \'' + contactWithErrorItem.Id + '\'';
                        errorString += '\r\nsent at: ' + String.valueOf(contactWithErrorItem.Email_Statement_Sent_Date_Time__c);
                        if( contactWithErrorItem.Email_Statements_Job_Error__c ) {
                        	errorString += '\r\nwith error reason: ' + (contactWithErrorItem.Email_Statements_Job_Error__c ? contactWithErrorItem.Email_Statement_Error_Reason__c : 'Email hasn\'t been delivered.');
                        }else if( contactWithErrorItem.EmailBouncedDate != null ){
                        	errorString += '\r\nwith error reason: ' + ( (contactWithErrorItem.EmailBouncedReason != null) ? contactWithErrorItem.EmailBouncedReason : 'Email hasn\'t been delivered.');
                        }else{
                        	errorString += '\r\nwith error reason: Email hasn\'t been delivered.';
                        }
                    }

                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    mail.setToAddresses( ( !confirmDDPHelperList.isEmpty() && confirmDDPHelperList[0].Text4__c != null) ? confirmDDPHelperList[0].Text4__c.split( ',' , 1000 ) : new String[]{'wave@milrose.com' } );
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    mail.setSubject( 'Email Statements ERRORS' );
                    mail.setPlainTextBody( errorString );

                    if ( !Test.isRunningTest() ) Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
                }

                //MRS-7449
                //CreateBatchStatementOfAccountsAttach cont = new CreateBatchStatementOfAccountsAttach( executeDateTimeValue );
                //Database.executeBatch(cont, 1);
                //System.scheduleBatch("Class Name", "Job Name", "minutes then job will run", "Integer batch size" )
                System.scheduleBatch( new CreateBatchStatementOfAccountsAttach(executeDateTimeValue), 'AttachSOAPage', 10, 1 );

                //TODO culculate the next execution date
                DDPHelperServices.calculateExecutionDateForDDP(confirmDDPHelperList[0], DateTime.now(), false);
                update confirmDDPHelperList[0];
            }
        }
    }
}