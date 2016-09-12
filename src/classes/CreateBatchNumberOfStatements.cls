global class CreateBatchNumberOfStatements implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts {
    private static String STATEMENT_CHECKED_EMAILTEMPLATE_NAME = 'Contact_Client_Statement_Doc_Checked';
    private static String STATEMENT_UNCHECKED_EMAILTEMPLATE_NAME = 'Contact_Client_Statement_Doc_Unchecked';

    global void execute( SchedulableContext sc ) {
        CreateBatchNumberOfStatements batch = new CreateBatchNumberOfStatements();
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

        Site_URL__c site = Site_URL__c.getValues( UserInfo.getOrganizationId().subString(0, 15) );
        if( site != null ) {
            UsernamePasswordFlow upf = new UsernamePasswordFlow( site.Token_Endpoint__c, site.Login_to_SF__c, site.Password__c, site.Client_Id__c, site.Client_Secret__c );
            String newSessionId = upf.requestAccessToken();
            sessionId = newSessionId;
        } else {
            System.debug( Logginglevel.Error, 'xxx The system can not find the Site_URL__c Custom Settings record for ' + UserInfo.getOrganizationId().subString(0, 15) + ' organization!' );
        }
        System.debug( Logginglevel.Error, 'xxx sessionId: ' + sessionId );

        if( sessionId != null ) {
            for( Contact contact : scopeList ) {

                Map<Id, String> accountIdToAccountName = new Map<Id, String>();
                Map<Id, String> accountIdToAccountNameForSending = new Map<Id, String>();
                AccountReportController accountReport = new AccountReportController( contact.Id );
                String subjectOfEmail = '';
                try {
                	accountIdToAccountName = accountReport.findAccounts( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT, false );
                	for( Account item: [Select Id, Name, Do_Not_Send_Statements_Automatically__c From Account Where Id IN: accountIdToAccountName.keySet() ]){
                		if( !item.Do_Not_Send_Statements_Automatically__c ) accountIdToAccountNameForSending.put( item.Id,accountIdToAccountName.get(item.Id) );
                	}
			        for(String item: accountIdToAccountNameForSending.values() ){
			        	if( subjectOfEmail == null || subjectOfEmail == '' ){
			        		subjectOfEmail = item + ', ';
			        	}else{
			        		subjectOfEmail += item + ', ';
			        	}
			        }
                    subjectOfEmail = subjectOfEmail.removeEnd(', ');
			        subjectOfEmail += ' ' + DDPHelperServices.STATEMENT_OF_ACCOUNTS_SUBJECT;//' Accounts Receivable Statement from Milrose Consultants';
                } catch( Exception e ) {
                    continue;
                }

                try {
                    UPDATE new Contact( Id = contact.Id, Number_Of_Attachments_To_Send__c = accountIdToAccountName.keySet().size(), Subject_for_SOA_email__c = subjectOfEmail );
                } catch( Exception e ) {
                    System.debug( LoggingLevel.Error, 'xxx ' + e.getMessage() + ' Can not update Contact data.'); //any handler
                }
            }
        }


    }

    global void finish(Database.BatchableContext BC) {

    }
}