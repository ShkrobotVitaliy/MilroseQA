public with sharing class AccountServices {

    public static String getAccountNameByIds(String accountIds) { //6930
        if (String.isBlank(accountIds)) return '';
        Account a = [SELECT Id, Name
                                 FROM Account
                                 WHERE Id =: accountIds];
        if(a != null && !String.isBlank(a.Name)) return a.Name;
        return '';
    }

    public static Map<Id, Account> getAccountByIds(Set<Id> accountIds) {
        if (null == accountIds || accountIds.isEmpty()) {
            return new Map<Id, Account>();

        }
        return new Map<Id, Account>([SELECT Id, Delivery_Method__c, Billing_Method__c, Quarterly_Month__c, Billing_day__c,
                                            Frequency__c, Invoice_Format__c, Separate_Reimbursables__c, No_Document_Shredding__c,
                                            No_Met_Data_Scanning__c, Special_Instructions__c, Interval__c, Special_Instructions_Long__c
                                     FROM Account
                                     WHERE Id IN: accountIds]);

    }

    public static List<Account> getAccountWithPurchaseInvoicesByIds(Set<Id> accountIds) {
         if (null == accountIds || accountIds.isEmpty()) {
             return new List<Account>();

         }

         List<Account> accounts = new List<Account>([SELECT Name, Id, Account_Check__c,
                                                         (SELECT Id, c2g__InvoiceStatus__c, c2g__PaymentStatus__c
                                                          FROM c2g__PurchaseInvoices__r
                                                          WHERE c2g__InvoiceStatus__c =: 'In Progress' OR
                                                                (c2g__InvoiceStatus__c =: 'Complete' AND (c2g__PaymentStatus__c =: 'Part Paid' OR c2g__PaymentStatus__c =: 'Unpaid')))
                                                     FROM Account
                                                     WHERE Account_Check__c IN: accountIds]);

         List<Account> avariableAccount = new List<Account>();

         for (Account acc : accounts) {
             if (acc.c2g__PurchaseInvoices__r.isEmpty()) {
                 avariableAccount.add(acc);

             }

         }
         return avariableAccount;

     }

     public static List<Account> getAmericanExpressAccount() {
         return new List<Account>([SELECT Name, Id FROM Account WHERE Name = 'American Express' limit 1]);

     }

     public static List<Account> getApprovedVendors() {
         return new List<Account>([SELECT Name, Id FROM Account WHERE Approved_Vendor__c = true]);

     }

     public static List<SelectOption> getParentAccountsSelectOptions() {
         List<SelectOption> accountOptions = new List<SelectOption>();
         accountOptions.add(new SelectOption ('', '-- None --'));

         List<Account> childAccounts = new List<Account>([SELECT Account_Check__r.Id, Account_Check__r.Name, Account_Check__c
                                                          FROM ACCOUNT
                                                          WHERE Account_Check__r.Account_Check__c = null AND Account_Check__c <> null ORDER BY Account_Check__r.Name LIMIT 50000]);

         Set<String> accountName = new Set<String>();

         for (Account acc : childAccounts) {
             if (!accountName.contains(acc.Account_Check__r.Name)) {
                 accountName.add(acc.Account_Check__r.Name);
                 accountOptions.add(new SelectOption (acc.Account_Check__r.Id, acc.Account_Check__r.Name));

             }

         }
         return accountOptions;

     }

     public static Map<Id, Account> filteredAccountsWithChangedARCoordinator( List<Account> newAccountList, Map<Id, Account> oldAccountMap ) {
        Map<Id, Account> filteredAccounts = new Map<Id, Account>();

        for( Account item : newAccountList ) {
            if( item.A_R_coordinator__c != oldAccountMap.get( item.Id ).A_R_coordinator__c ) {
                filteredAccounts.put( item.Id, item );
            }
        }
        return filteredAccounts;
    }

    public static void updateAcountsRetainerAndReimbursable( List<Account> newAccountList ){

        for( Account acc: newAccountList ){
            if( acc.No_Retainer__c ){
                acc.Retainer__c = 0;
            }else{
            	if( acc.Retainer__c == null || acc.Retainer__c == 0) acc.Retainer__c = 30;
            }

            if( acc.No_Reimbursables__c ){
                acc.Reimbursables__c = 0;
            }else{
            	if( acc.Reimbursables__c == null || acc.Reimbursables__c == 0) acc.Reimbursables__c = 15;
            }
        }
    }

    public static List<Account> filteredAccountWithMSAEndDate( List<Account> newAccountList, Map<Id, Account> oldAccountMap ){
        List<Account> filteredList = new List<Account>();

        for ( Account acountItem : newAccountList ){
            if ( oldAccountMap == null ){
                if ( acountItem.MSA_End_Date__c != null && acountItem.Account_Manager__c != null && acountItem.MSA__c ){
                    filteredList.add(acountItem);
                }
            } else {
                Account accountOld = oldAccountMap.get(acountItem.Id);
                if ( (acountItem.MSA__c != null && acountItem.MSA__c != accountOld.MSA__c) ||
                     acountItem.MSA_End_Date__c != accountOld.MSA_End_Date__c ||
                     acountItem.Account_Manager__c != accountOld.Account_Manager__c ){
                    filteredList.add(acountItem);
                }
            }
        }

        return filteredList;
    }

    public static void createReminderForAccountManagerMSAAccount( List<Account> newAccountList, Map<Id, Account> oldAccountMap ){
        if ( newAccountList == null || newAccountList.isEmpty() ){ return; }

        List<Event> newEventReminderList = new List<Event>();
        String eventSubjectCompareString = '%' + EventServices.ACCOUNT_MANAGER_MSA_REMINDER + '%';
        Map<Id, Event> accountWithEventMap = new Map<Id, Event>();
        if ( oldAccountMap != null ){
            for ( Event eventItem : [SELECT Id, WhatId, IsReminderSet, OwnerId, Subject
                                     FROM Event
                                     WHERE WhatId IN : newAccountList AND
                                            Subject Like : eventSubjectCompareString AND
                                            IsReminderSet = true] ){
                accountWithEventMap.put(eventItem.WhatId, eventItem);
            }
        }
        for ( Account accountItem : newAccountList ){
            if ( accountItem.MSA_End_Date__c != null && accountItem.Account_Manager__c != null && accountItem.MSA__c ){
                Date dateOfReminder = accountItem.MSA_End_Date__c.addMonths( -3 );
                Datetime reminderDateTime = ((Datetime.newInstance(dateOfReminder.year(), dateOfReminder.month(), dateOfReminder.day(), 8, 0, 0)));
                String subjectValue = accountItem.Name + EventServices.ACCOUNT_MANAGER_MSA_REMINDER + String.valueOf(accountItem.MSA_End_Date__c);
                Event eventItem = accountWithEventMap.containsKey( accountItem.Id ) ?
                                                            accountWithEventMap.get( accountItem.Id ) :
                                                            EventServices.createNewEvent( accountItem.Id, reminderDateTime, subjectValue, '' );
                eventItem.OwnerId = accountItem.Account_Manager__c;
                eventItem.ReminderDateTime = reminderDateTime;
                eventItem.StartDateTime = reminderDateTime;
                eventItem.EndDateTime = reminderDateTime;
                eventItem.Subject = subjectValue;
                eventItem.IsReminderSet = true;
                newEventReminderList.add(eventItem);
            } else {
                if ( accountWithEventMap.containsKey( accountItem.Id ) ) {
                    Event eventItem = accountWithEventMap.get( accountItem.Id );
                    eventItem.IsReminderSet = false;
                    newEventReminderList.add(eventItem);
                }
            }
        }
        try {
            upsert newEventReminderList;
        } catch ( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                new Map<Id, Account>(newAccountList).get(newEventReminderList[i].WhatId).addError('Error creating reminder for Account ' + dmlEx.getMessage());
            }
        }
    }

    public static List<Account> filteredOnHoldAccount( List<Account> newAccountList, Map<Id, Account> oldAccountMap ){
        List<Account> filteredList = new List<Account>();

        for ( Account acountItem : newAccountList ){
            if ( acountItem.Accounting_Hold__c != null && acountItem.Accounting_Hold__c != oldAccountMap.get(acountItem.Id).Accounting_Hold__c ){
                filteredList.add(acountItem);
            }
        }

        return filteredList;
    }

    public static void processingOnHoldAccounts( List<Account> newAccountList ){
        if ( newAccountList.isEmpty() ){ return; }

        Set<Id> onHoldOnAccountSetId = new Set<Id>();
        Set<Id> onHoldOffAccountSetId = new Set<Id>();

        String organizationPhoneNumber;
        String controllerName;
        List<User> userWithRoleController = [SELECT Id, Name, Phone FROM User WHERE IsActive = true And UserRole.Name = 'Controller' limit 1];

        Map<Id, Set<Id>> accountWithUserMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> accountWithContactMap = new Map<Id, Set<Id>>();

        for( Account acc: newAccountList ){
            accountWithUserMap.put(acc.Id, new Set<Id>());
            accountWithContactMap.put( acc.Id, new Set<Id>() );
            if(acc.A_R_coordinator__c != null){accountWithUserMap.get(acc.Id).add(acc.A_R_coordinator__c);}
            if(acc.Account_Manager__c != null){accountWithUserMap.get(acc.Id).add(acc.Account_Manager__c);}
            if ( acc.Accounting_Hold__c ){
                onHoldOnAccountSetId.add ( acc.Id );
            } else {
                onHoldOffAccountSetId.add( acc.Id );
            }
        }

        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>([SELECT Id, Project_State__c, Billing_Company_Name__r.Accounting_Hold__c, Billing_Company_Name__c,
                                                                                            Accounting_Contact__c, Billing_Company_Contact__c, Primary_Company_Contact__c, Submitted_Planned_Dates__c,
                                                                                            Account_Executive__c, FREP__c, Partner__c, Production_Manager__c, Project_Member__c, Project_Manager__c,
                                                                                            Proposal_Specialist__c, Resource__c, Salesperson__c, OwnerId, Proposal__r.OwnerId,
                                                                                            (Select Id, OwnerId From Service_Items__r Where Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                                                            (Select Id, OwnerId From Task_Items__r
                                                                                             Where RecordType.Name !=: TaskManagementServices.MILESTONE_RECORDTYPE_NAME And
                                                                                             Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                                                            (Select Id, Active__c, User__c, Contact__c, Role__c, LastModifiedDate, CreatedDate, Is_Manually_Added_Roster__c
                                                                                             From Project_Rosters__r Where User__c != null And  User__r.IsActive = true And RecordType.Name =: ProjectRosterServices.TYPE_USER And Active__c = true Order By CreatedDate Desc) //MRS-6868
                                                                                         FROM Project_Profile__c
                                                                                         WHERE ( Billing_Company_Name__c IN : onHoldOnAccountSetId AND Accounting_Hold__c = false AND
                                                                                                                (Project_State__c = : ProjectProfileServices.PROJECT_STATE_IN_PROCESS OR Project_State__c = : ProjectProfileServices.PROJECT_STATE_NOT_STARTED) ) OR
                                                                                             ( Billing_Company_Name__c IN : onHoldOffAccountSetId AND ( Accounting_Hold__c = true And Project_State__c  = : ProjectProfileServices.PROJECT_STATE_ON_HOLD ) )]);


        Set<String> availableProposalStatuses = new Set<String>{ProposalServices.PROPOSAL_STATUS_NEW,
        														ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW,
        														ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE,
        														ProposalServices.PROPOSAL_STATUS_IN_REVIEW,
        														ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
        														ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
        														ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW,
                                                                ProposalServices.PROPOSAL_STATUS_REJECTED};

        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>([SELECT Id, Status__c, OwnerId, Billing_Company_Name__c
                                                                     FROM Proposal__c
                                                                     WHERE ( Billing_Company_Name__c IN : onHoldOnAccountSetId OR Billing_Company_Name__c IN : onHoldOffAccountSetId )
                                                                     	AND Status__c IN: availableProposalStatuses ]);

        if ( projectProfileMap.isEmpty() && proposalMap.isEmpty() ){ return; }

        for ( Project_Profile__c projectProfileItem : projectProfileMap.values() ){
            projectProfileItem.Accounting_Hold__c = projectProfileItem.Billing_Company_Name__r.Accounting_Hold__c;
            projectProfileItem.Project_State__c = projectProfileItem.Billing_Company_Name__r.Accounting_Hold__c ? ProjectProfileServices.PROJECT_STATE_ON_HOLD :
                                                    ( projectProfileItem.Submitted_Planned_Dates__c ? ProjectProfileServices.PROJECT_STATE_IN_PROCESS : ProjectProfileServices.PROJECT_STATE_NOT_STARTED );
            Set<Id> rosterUserSetId = new Set<Id>();
            //MRS-6868
            for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
                rosterUserSetId.add(projectRosterItem.User__c);
            }
            accountWithUserMap.get(projectProfileItem.Billing_Company_Name__c).addAll(rosterUserSetId);
            accountWithContactMap.get(projectProfileItem.Billing_Company_Name__c).add(projectProfileItem.Accounting_Contact__c);
            accountWithContactMap.get(projectProfileItem.Billing_Company_Name__c).add(projectProfileItem.Billing_Company_Contact__c);
            accountWithContactMap.get(projectProfileItem.Billing_Company_Name__c).add(projectProfileItem.Primary_Company_Contact__c);
        }

        for ( Proposal__c proposalItem : proposalMap.values() ){
            accountWithUserMap.get(proposalItem.Billing_Company_Name__c).add(proposalItem.OwnerId);
        }

        try {
            update projectProfileMap.values();
        } catch ( DMLException dmlEx ){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                new Map<Id, Account>(newAccountList).get(projectProfileMap.values()[i].Billing_Company_Name__c).addError('Error occurred during updating Project Profile Record ' + dmlEx.getMessage());
            }
            return;
        }

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        for (Account accountItem : newAccountList){
            String subjectValue = accountItem.Name + ( accountItem.Accounting_Hold__c ? ' has been placed on hold.' : ' has been removed from hold.' );
            String emailBodyValue = '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + accountItem.Id + '">' + accountItem.Name + '</a>';
                   emailBodyValue += accountItem.Accounting_Hold__c ? ' has been placed on hold. No work should be done for this client until they have been removed from hold.' :
                                                       ' has been removed from hold. Please proceed with working on their projects.';
            for ( Id userId : accountWithUserMap.get( accountItem.Id ) ){
                mailList.add( EmailMessageService.createEmailNotificationMessage(subjectValue, emailBodyValue, userId) );
            }

            if ( accountItem.A_R_coordinator__c == null && String.isEmpty(organizationPhoneNumber) ){
                organizationPhoneNumber = ( !userWithRoleController.isEmpty() && userWithRoleController[0].Phone != null )
                							? userWithRoleController[0].Phone
                							: [SELECT Id, Phone FROM Organization WHERE Id = :UserInfo.getOrganizationId()].Phone;
            }

            if ( accountItem.A_R_coordinator__c == null && String.isEmpty(controllerName) ){
                controllerName = !userWithRoleController.isEmpty() ? userWithRoleController[0].Name : 'Milrose Consultants, Inc.';
            }

            emailBodyValue = accountItem.Name;
            if (accountItem.Accounting_Hold__c){
                emailBodyValue += ' has been placed on hold.  We will not be proceeding with any work until the hold is lifted. Please contact ';
                emailBodyValue += ( accountItem.A_R_coordinator__c == null ? controllerName : accountItem.A_R_Coordinator_Full_Name__c ) + ' at ';
                emailBodyValue += ( String.isEmpty( accountItem.AR_Coordinator_Phone__c ) ? organizationPhoneNumber : accountItem.AR_Coordinator_Phone__c ) + ' if you have any questions.';
            } else {
                emailBodyValue += ' has been removed from hold.  Please contact your project manager if you have any specific questions related to your project.';
            }

            for( Id contactId : accountWithContactMap.get( accountItem.Id ) ){
                mailList.add( EmailMessageService.createEmailNotificationMessage(subjectValue, emailBodyValue, contactId) );
            }
        }

        if( !Test.isRunningTest() && !mailList.isEmpty() ) Messaging.sendEmail(mailList);
    }

    public static List<Set<Id>> filterProposalsWithChangedAccountsTaxStatus(List<Account> newList, Map<Id, Account> oldMap) { // MRS 7096
        List<Set<Id>> res = new List<Set<Id>> { new Set<Id> (), new Set<Id> () };

        Set<Id> idxOfAccountsSet = new Set<Id> ();
        for(Account a : newList) idxOfAccountsSet.add(a.Id);
        List<Proposal__c> proposals = [SELECT Id, Billing_Company_Name__c FROM Proposal__c WHERE Billing_Company_Name__c IN :idxOfAccountsSet];
        Map<Id, Set<Id>> accountIdToProposalsIdxSet = new Map<Id, Set<Id>> ();
        for(Proposal__c p : proposals) {
            if(accountIdToProposalsIdxSet.get(p.Billing_Company_Name__c) == null) accountIdToProposalsIdxSet.put(p.Billing_Company_Name__c, new Set<Id> ());
            accountIdToProposalsIdxSet.get(p.Billing_Company_Name__c).add(p.Id);
        }
        for(Account a : newList) {
            if((a.c2g__CODASalesTaxStatus__c == 'Exempt' || a.c2g__CODASalesTaxStatus__c == 'Exempt for Qualifying Products')
                && oldMap.get(a.Id).c2g__CODASalesTaxStatus__c != 'Exempt' && oldMap.get(a.Id).c2g__CODASalesTaxStatus__c != 'Exempt for Qualifying Products') {
                if(accountIdToProposalsIdxSet.get(a.Id) != null ) res[0].addAll(accountIdToProposalsIdxSet.get(a.Id)); // list of Id where SI taxes should be cleaned up
            } else if(oldMap.get(a.Id).c2g__CODASalesTaxStatus__c == 'Exempt' || oldMap.get(a.Id).c2g__CODASalesTaxStatus__c == 'Exempt for Qualifying Products') {
                if(accountIdToProposalsIdxSet.get(a.Id) != null ) res[1].addAll(accountIdToProposalsIdxSet.get(a.Id)); // list od Id where SI taxes has to be populated from templates
            }
        }
        return res;
    }

    //MRS-7191
    public static void filteredAccountsWithPORequiredNotCheckedAndSetPoNotRequiredCheckbox( List<Account> newAccountList, Map<Id, Account> oldMap ) {
        for( Account item : newAccountList ) {
            if( !item.PO_Required__c && ( oldMap != null && oldMap.get(item.Id).PO_Required__c ) ) {
                item.PO_Not_Required__c = false;
            }
        }
    }

    //MRS-7337
    public static List<Account> filterContactWithChangesActiveField ( List<Account> newAccountList, Map<Id, Account> oldMap ){
        List<Account> filteredAccountList = new List<Account>();
        for( Account accountItem : newAccountList ){
            if ( accountItem.Do_Not_Send_Statements_Automatically__c && !oldMap.get(accountItem.Id).Do_Not_Send_Statements_Automatically__c ){
                filteredAccountList.add( accountItem );
            }
        }

        return filteredAccountList;
    }

    public static void validateAccountsWithAlternateARStatementRecipient( List<Account> filteredAccountList ){ //MRS 7337 7426
        if( filteredAccountList.isEmpty() ){
            return;
        }

        Map<Id, Contact> contactsMap = new Map<Id, Contact> ([SELECT Id, Name_Full__c, AccountId
															  FROM Contact
																WHERE AccountId IN : filteredAccountList
								                          		AND Is_Active__c = true]);

		List<Contact> contactsWithAltCont = [SELECT Id, Name_Full__c, AccountId, Alternate_A_R_Statement_Recipient__c
														  			FROM Contact
																	WHERE Is_Active__c = true
																	AND Alternate_A_R_Statement_Recipient__c IN :contactsMap.keySet()];

		Map<Id, List<String>> idContactToRelatedAlternateContactsAsChild = new Map<Id, List<String>>();
		for(Contact c : contactsWithAltCont) {
			if(idContactToRelatedAlternateContactsAsChild.get(c.Alternate_A_R_Statement_Recipient__c) == null) idContactToRelatedAlternateContactsAsChild.put(c.Alternate_A_R_Statement_Recipient__c, new List<String>());
			idContactToRelatedAlternateContactsAsChild.get(c.Alternate_A_R_Statement_Recipient__c).add(c.Name_Full__c);
		}

		Map<Id, List<String>> accIdToErrorsMap = new Map<Id, List<String>>();
		for(Id idx : idContactToRelatedAlternateContactsAsChild.keySet()) {
			if(accIdToErrorsMap.get(contactsMap.get(idx).AccountId) == null) accIdToErrorsMap.put(contactsMap.get(idx).AccountId, new List<String>());
			accIdToErrorsMap.get(contactsMap.get(idx).AccountId).add(contactsMap.get(idx).Name_Full__c +
				' ' + String.format(Label.Alternate_ASR_do_not_send_Validation, new List<String>{String.join(idContactToRelatedAlternateContactsAsChild.get(idx), ', ')}));
		}

		for( Account accountItem: filteredAccountList ){
        	if(accIdToErrorsMap.get(accountItem.Id) != null) {
				accountItem.addError(String.join(accIdToErrorsMap.get(accountItem.Id), '; ') + ' Please remove these contacts as the alternate recipients before checking this box.'); //MRS 7426
        	}
		}
    }
}