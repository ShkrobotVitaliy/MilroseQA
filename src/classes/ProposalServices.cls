public without sharing class ProposalServices {
    public static final String PROPOSAL_OBJECT_API_NAME = 'Proposal__c';

    public static final String PROPOSAL_STATUS_NEW = 'Draft';
    public static final String PROPOSAL_STATUS_IN_REVIEW = 'In Internal Review';
    public static final String PROPOSAL_STATUS_AWARDED = 'Awarded';
    public static final String PROPOSAL_STATUS_NOT_AWARDED = 'Not Awarded';
    public static final String PROPOSAL_STATUS_PENDING_CLIENT = 'Pending Client Approval';
    public static final String PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW = 'Passed Internal Review';
    public static final String PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW = 'Failed Internal Review';
    public static final String PROPOSAL_STATUS_CANCELLED = 'Canceled';
    public static final String PROPOSAL_STATUS_EXPIRED = 'Expired';
    public static final String PROPOSAL_STATUS_REJECTED = 'Rejected';
    public static final String PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE = 'C&Z Scope Review Complete';
    public static final String PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW = 'In C&Z Scope Review';
    public static final String PROPOSAL_STATUS_WITHDRAWN = 'Withdrawn';
    public static final String APPROVAL_PROCESS_STEP_REJECTED = 'Rejected';
    public static final String PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED = 'Change Order Requested';
    public static final String PROPOSAL_STATUS_CHANGE_ORDER_APPROVED = 'Change Order Approved';
    public static final String PROPOSAL_TYPE_CHANGE_ORDER = 'Change Order';
    public static final Double VERSION_MINOR_STEP = 0.01;
    public static final Double VERSION_MAJOR_STEP = 1;
    public static final String PROPOSAL_BILLING_METHOD_MILESTONE = 'Milestone';
    public static final String PROPOSAL_FREQUENCY_QUARTERLY = 'Quarterly';
    public static final String PROPOSAL_TYPE_RFP = 'RFP';
    public static final String PROPOSAL_RFP_ATTACHMENTS_DELIMITER = ';';

    public static final String PROPOSAL_RECORDTYPE_STANDARD = 'Standard';
    public static final String PROPOSAL_RECORDTYPE_IN_REVIEW = 'In Review';
    public static final String PROPOSAL_RECORDTYPE_APPROVED = 'Approved';
    public static final String PROPOSAL_RECORDTYPE_AWARDED = 'Awarded';

    private static Map<String, String> proposalToHistoricalMap = new Map<String, String>();
    public static final List<String> PROPOSAL_DISABLED_EDIT_STATUSES = new List<String>{PROPOSAL_STATUS_AWARDED,
                                                                                        PROPOSAL_STATUS_NOT_AWARDED,
                                                                                        PROPOSAL_STATUS_PENDING_CLIENT,
                                                                                        PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
                                                                                        PROPOSAL_STATUS_EXPIRED,
                                                                                        PROPOSAL_STATUS_IN_REVIEW,
                                                                                        PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW};

	public static void sendEmailAboutContactsChanging(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap) { //MRS 7336
		List<Proposal__c> changedProposalsList = new List<Proposal__c>();
		Map<Id, Account> accountAffectedMap = new Map<Id, Account>();
		Map<Id, Contact> contactAffectedMap = new Map<Id, Contact>();
		List<Task> tasksToInsert = new List<Task>();
		for(Proposal__c proposal : newList) {
			Boolean billingCompanyChaged = proposal.Billing_Company_Name__c != oldMap.get(proposal.Id).Billing_Company_Name__c;
			Boolean billingContactChaged = proposal.Billing_Company_Contact__c != oldMap.get(proposal.Id).Billing_Company_Contact__c;
			Boolean accountingCompanyChaged = proposal.Accounting_Contact_Company__c != oldMap.get(proposal.Id).Accounting_Contact_Company__c;
			Boolean accountingContactChaged = proposal.Accounting_Contact__c != oldMap.get(proposal.Id).Accounting_Contact__c;
			if(proposal.Status__c == PROPOSAL_STATUS_AWARDED && oldMap.get(proposal.Id).Status__c == PROPOSAL_STATUS_AWARDED 
					&& (billingCompanyChaged || billingContactChaged || accountingCompanyChaged || accountingContactChaged)) {
				changedProposalsList.add(proposal);
				if(billingCompanyChaged || billingContactChaged) {
					accountAffectedMap.put(proposal.Billing_Company_Name__c, new Account());
					accountAffectedMap.put(oldMap.get(proposal.Id).Billing_Company_Name__c, new Account());
					contactAffectedMap.put(proposal.Billing_Company_Contact__c, new Contact());
					contactAffectedMap.put(oldMap.get(proposal.Id).Billing_Company_Contact__c, new Contact());
				}
				if(accountingCompanyChaged || accountingContactChaged) {
					accountAffectedMap.put(proposal.Accounting_Contact_Company__c, new Account());
					accountAffectedMap.put(oldMap.get(proposal.Id).Accounting_Contact_Company__c, new Account());
					contactAffectedMap.put(proposal.Accounting_Contact__c, new Contact());
					contactAffectedMap.put(oldMap.get(proposal.Id).Accounting_Contact__c, new Contact());
				}
			}
		}
		
		if(!changedProposalsList.isEmpty()) {
				
			Map<Id, Proposal__c> proposalsFromDB = new Map<Id, Proposal__c> ([SELECT Id, Project_Profile__c, Project_Profile__r.Project_Name_For_Email__c
																				FROM Proposal__c WHERE Id IN :changedProposalsList]);
			accountAffectedMap.remove(null);
			accountAffectedMap = new Map<Id, Account>([SELECT Id, Name, A_R_coordinator__c FROM Account WHERE Id IN :accountAffectedMap.keySet()]);
			contactAffectedMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactAffectedMap.keySet()]);
			for(Proposal__c proposal : changedProposalsList) {
				Boolean billingCompanyChaged = proposal.Billing_Company_Name__c != oldMap.get(proposal.Id).Billing_Company_Name__c;
				Boolean billingContactChaged = proposal.Billing_Company_Contact__c != oldMap.get(proposal.Id).Billing_Company_Contact__c;
				Boolean accountingCompanyChaged = proposal.Accounting_Contact_Company__c != oldMap.get(proposal.Id).Accounting_Contact_Company__c;
				Boolean accountingContactChaged = proposal.Accounting_Contact__c != oldMap.get(proposal.Id).Accounting_Contact__c;
				Set<Id> recipientsIdSet = new Set<Id>();
				String subject = 'Action required - '
								  + (!String.isBlank(proposalsFromDB.get(proposal.Id).Project_Profile__c) ? proposalsFromDB.get(proposal.Id).Project_Profile__r.Project_Name_For_Email__c : '')
								  + ' Client Change Notification';
				String body = '<html>Accounts Receivable Coordinator,<br/><br/>Please note the above changes to ';
				String textBody = 'Accounts Receivable Coordinator,\n\nPlease note the above changes to ';
				if(!String.isBlank(proposalsFromDB.get(proposal.Id).Project_Profile__c)) {
					body += '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + ((String)proposalsFromDB.get(proposal.Id).Project_Profile__c)
							   + '">' + proposalsFromDB.get(proposal.Id).Project_Profile__r.Project_Name_For_Email__c + '</a> / ';
					textBody += proposalsFromDB.get(proposal.Id).Project_Profile__r.Project_Name_For_Email__c + ' / ';
				}
				body += '<a href="' 
							   + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + ((String)proposal.Id) + '">' 
							   + proposal.Name + '</a> made by <a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + UserInfo.getUserId() + '">' + UserInfo.getName() + '</a>. <br/><br/>'
							   + 'Please review and confirm the above changes. Request and send new PDF invoices that reflect the<br/>'
							   + 'changes as necessary. Specifically, review the Statement of Accounts and request a Credit and Rebill of<br/>'
							   + 'active invoices if applicable (may need to confirm if old invoices are being processed or if old party is still<br/>'
							   + 'responsible for payment). Check if this impacts any other projects.<br/><br/><table style="border:1px solid black; border-collapse:collapse;">'
							   + '<thead><tr style="background-color:#f0f0f0;">'
							   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;"></th>'
							   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">OLD</th>'
							   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">NEW</th></tr></thead><tbody>';
				textBody +=  proposal.Name + ' made by ' + UserInfo.getName() + '.\n\n'
							+ 'Please review and confirm the above changes. Request and send new PDF invoices that reflect the\n'
							+ 'changes as necessary. Specifically, review the Statement of Accounts and request a Credit and Rebill of\n'
							+ 'active invoices if applicable (may need to confirm if old invoices are being processed or if old party is still\n'
							+ 'responsible for payment). Check if this impacts any other projects.\n\n';

				if(billingCompanyChaged) {
					if(accountAffectedMap.get(proposal.Billing_Company_Name__c) != null) recipientsIdSet.add(accountAffectedMap.get(proposal.Billing_Company_Name__c).A_R_coordinator__c);
					if(accountAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c) != null) recipientsIdSet.add(accountAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c).A_R_coordinator__c);
					String oldBCompany = !String.isBlank(oldMap.get(proposal.Id).Billing_Company_Name__c) ? accountAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c).Name : '';
					String newBCompany = !String.isBlank(proposal.Billing_Company_Name__c) ? accountAffectedMap.get(proposal.Billing_Company_Name__c).Name : '';
					body += '<tr>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Billing Client</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ oldBCompany +'</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ newBCompany +'</td>'
						  + '</tr>';
					textBody += 'Billing Client:\tOld: '+ oldBCompany + '\t\tNew:' + newBCompany + '\n';
				}
				if(billingContactChaged) {
					if(accountAffectedMap.get(proposal.Billing_Company_Name__c) != null) recipientsIdSet.add(accountAffectedMap.get(proposal.Billing_Company_Name__c).A_R_coordinator__c);
					if(accountAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c) != null) recipientsIdSet.add(accountAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c).A_R_coordinator__c);
					String oldBContact = !String.isBlank(oldMap.get(proposal.Id).Billing_Company_Contact__c) ? contactAffectedMap.get(oldMap.get(proposal.Id).Billing_Company_Contact__c).Name : '';
					String newBContact = !String.isBlank(proposal.Billing_Company_Contact__c) ? contactAffectedMap.get(proposal.Billing_Company_Contact__c).Name : '';
					body += '<tr>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Billing Contact</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ oldBContact +'</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ newBContact +'</td>'
						  + '</tr>';
					textBody += 'Billing Contact:\tOld: '+ oldBContact + '\t\tNew:' + newBContact + '\n';
				}
				if(accountingCompanyChaged) {
					if(accountAffectedMap.get(proposal.Accounting_Contact_Company__c) != null) recipientsIdSet.add(accountAffectedMap.get(proposal.Accounting_Contact_Company__c).A_R_coordinator__c);
					if(accountAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact_Company__c) != null) recipientsIdSet.add(accountAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact_Company__c).A_R_coordinator__c);
					String oldACompany = !String.isBlank(oldMap.get(proposal.Id).Accounting_Contact_Company__c) ? accountAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact_Company__c).Name : '';
					String newACompany = !String.isBlank(proposal.Accounting_Contact_Company__c) ? accountAffectedMap.get(proposal.Accounting_Contact_Company__c).Name : '';
					body += '<tr>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Accounting Client</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ oldACompany +'</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ newACompany +'</td>'
						  + '</tr>';
					textBody += 'Accounting Client:\tOld: '+ oldACompany + '\t\tNew:' + newACompany + '\n';
				}
				if(accountingContactChaged) {
					if(accountAffectedMap.get(proposal.Accounting_Contact_Company__c) != null) recipientsIdSet.add(accountAffectedMap.get(proposal.Accounting_Contact_Company__c).A_R_coordinator__c);
					if(accountAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact_Company__c) != null) recipientsIdSet.add(accountAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact_Company__c).A_R_coordinator__c);
					String oldAContact = !String.isBlank(oldMap.get(proposal.Id).Accounting_Contact__c) ? contactAffectedMap.get(oldMap.get(proposal.Id).Accounting_Contact__c).Name : '';
					String newAContact = !String.isBlank(proposal.Accounting_Contact__c) ? contactAffectedMap.get(proposal.Accounting_Contact__c).Name : '';
					body += '<tr>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Accounting Contact</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ oldAContact +'</td>'
						  + '<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ newAContact +'</td>'
						  + '</tr>';
					textBody += 'Accounting Contact:\tOld: '+ oldAContact + '\t\tNew:' + newAContact + '\n';
				}
				body +='</tbody></table></html>';
				recipientsIdSet.remove(null);
				EmailMessageService.sendMassMailToInternalUsers(recipientsIdSet, body, subject);
				if(!String.isBlank(proposal.Project_Profile__c)) {
					for(Id idxUser : recipientsIdSet) {
						Task taskToAdd = new Task();
						taskToAdd.WhatId = proposal.Project_Profile__c;
						taskToAdd.Subject = 'Email: ' + subject;
						taskToAdd.Description = textBody;
						taskToAdd.Status = 'Completed';
						taskToAdd.Priority = 'Normal';
						taskToAdd.OwnerId = idxUser;
						tasksToInsert.add(taskToAdd);
					}
				}
			}
			
			if(!tasksToInsert.isEmpty()) {
				UPSERT tasksToInsert;
			}
		}	
	}

    public static String proposalPrefix { get { if( proposalPrefix == null ) proposalPrefix = Proposal__c.sObjectType.getDescribe().getKeyPrefix(); return proposalPrefix; } private set; }

    public static void checkRequiredFields( List<Proposal__c> filteredProposals ) {
        for( Proposal__c proposal : filteredProposals ) {
            if( String.isEmpty( proposal.Primary_Company_Name__c ) ||
                String.isEmpty( proposal.Primary_Company_Contact__c ) ||
                String.isEmpty( proposal.Billing_Company_Name__c ) ||
                String.isEmpty( proposal.Billing_Company_Contact__c ) ||
                proposal.Proposal_RFP_Request_Date__c == null ||
                String.isEmpty( proposal.Salesperson__c ) ||
                String.isEmpty( proposal.Fulfillment_Office__c ) ||
                String.isEmpty( proposal.Project_Name__c ) ||
                String.isEmpty( proposal.Description__c ) ||
                ( proposal.Partner_Approval_Required__c && String.isEmpty( proposal.Internal_Reviewer__c ) ) ) {
                proposal.addError( 'Can not save Proposal: not all required fields were entered.' );
            }
        }
    }

    public static List<Set<Id>> filterProposalsWithChangedTaxStatus(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap) { // MRS 7096
        List<Set<Id>> res = new List<Set<Id>> { new Set<Id> (), new Set<Id> () };
        
        Set<Id> changedBillingAccountIdSet = new Set<Id> ();
        List<Proposal__c> proposalsWithChangedBillingAccount = new List<Proposal__c> ();

        for(Proposal__c proposal : newList) if(proposal.Billing_Company_Name__c != oldMap.get(proposal.Id).Billing_Company_Name__c) {
            if(!String.isBlank(proposal.Billing_Company_Name__c)) changedBillingAccountIdSet.add(proposal.Billing_Company_Name__c);
            if(!String.isBlank(oldMap.get(proposal.Id).Billing_Company_Name__c)) changedBillingAccountIdSet.add(oldMap.get(proposal.Id).Billing_Company_Name__c);
            proposalsWithChangedBillingAccount.add(proposal);
        }

        Map<Id, String> accountIdToTaxStatusMap = new Map<Id, String> ();
        List<Account> accounts = !changedBillingAccountIdSet.isEmpty()
											? [SELECT c2g__CODASalesTaxStatus__c
											   FROM Account
											   WHERE Id IN :changedBillingAccountIdSet]
											: new List<Account>();//MRS-7473
        for(Account a : accounts) accountIdToTaxStatusMap.put(a.Id, a.c2g__CODASalesTaxStatus__c);

        for(Proposal__c proposal : proposalsWithChangedBillingAccount) {
            if(proposal.Billing_Company_Name__c != oldMap.get(proposal.Id).Billing_Company_Name__c) {
                String newTaxStatus = String.isBlank(proposal.Billing_Company_Name__c) ? null : accountIdToTaxStatusMap.get(proposal.Billing_Company_Name__c); 
                String oldTaxStatus = String.isBlank(oldMap.get(proposal.Id).Billing_Company_Name__c) ? null : accountIdToTaxStatusMap.get(oldMap.get(proposal.Id).Billing_Company_Name__c);
                if((newTaxStatus == 'Exempt' || newTaxStatus == 'Exempt for Qualifying Products') && oldTaxStatus != 'Exempt' && oldTaxStatus != 'Exempt for Qualifying Products') {
                    res[0].add(proposal.Id); // list of Id where SI taxes should be cleaned up
                } else if(oldTaxStatus == 'Exempt' || oldTaxStatus == 'Exempt for Qualifying Products') {
                    res[1].add(proposal.Id); // list od Id where SI taxes has to be populated from templates
                }          
            }
        }
        return res;
    }

    public static void changePONotesOnProject(List<Proposal__c> newList, Map<Id, Proposal__c> oldMap) { //MRS 7238
        List<Project_Profile__c> projectsToUpdate = new List<Project_Profile__c> ();
        for(Proposal__c proposal : newList) {
            if(proposal.Project_Profile__c != null && proposal.PO_Tracking_Notes__c != oldMap.get(proposal.Id).PO_Tracking_Notes__c) {
                projectsToUpdate.add(new Project_Profile__c(Id = proposal.Project_Profile__c, PO_Tracking_Notes__c = proposal.PO_Tracking_Notes__c));   
            }
        }
        UPDATE projectsToUpdate;
    }

    public static void changeProposalCreatorOnProject( List<Proposal__c> proposalsWithChangedCreator, List<Proposal__c> proposalsWithChangedOwner ) {
        Map<Id, Proposal__c> projectIdToProposalForErrorHandling = new Map<Id, Proposal__c>();
        Map<Id, Project_Profile__c> projectIdToProject = new Map<Id, Project_Profile__c>();
        for( Proposal__c proposal : proposalsWithChangedCreator ) {
            projectIdToProposalForErrorHandling.put( proposal.Project_Profile__c, proposal );
            projectIdToProject.put( proposal.Project_Profile__c, new Project_Profile__c( Id = proposal.Project_Profile__c,
                                                                                         Proposal_Specialist__c = proposal.Proposal_Specialist__c ) );
        }
        for( Proposal__c proposal : proposalsWithChangedOwner ) {
            projectIdToProposalForErrorHandling.put( proposal.Project_Profile__c, proposal );
            projectIdToProject.put( proposal.Project_Profile__c, new Project_Profile__c( Id = proposal.Project_Profile__c,
                                                                                         Proposal_Specialist__c = proposal.Proposal_Specialist__c ) );
        }
        projectIdToProposalForErrorHandling.remove(null);
        projectIdToProject.remove(null);

        List<Project_Profile__c> projectsToUpdate = projectIdToProject.values();
        try {
            UPDATE projectsToUpdate;
        } catch( DmlException dmlEx ) {
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                projectIdToProposalForErrorHandling.get( projectsToUpdate[i].Id ).addError( 'Can not update Owner or Proposal Creator on Project. ' + dmlEx.getMessage() );
            }
        }
    }

    public static void changeProposalCreatorOwnerOnProposal( List<Proposal__c> proposalsWithChangedCreator, List<Proposal__c> proposalsWithChangedOwner ) {
        for( Proposal__c proposal : proposalsWithChangedCreator ) {
            if( String.isBlank( proposal.Proposal_Specialist__c ) ) {
                proposal.Proposal_Specialist__c = proposal.OwnerId;
            } else {
                proposal.OwnerId = proposal.Proposal_Specialist__c;
            }
        }
        for( Proposal__c proposal : proposalsWithChangedOwner ) {
            proposal.Proposal_Specialist__c = proposal.OwnerId;
        }
    }

    public static List<Proposal__c> filterProposalsWithChangedProposalCreator( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ){
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        if( newProposalList != null ) {
            if( oldProposalMap == null ) { //treat as with changed proposal creator
                filteredProposals.addAll( newProposalList );
            } else {
                for( Proposal__c proposal : newProposalList ) {
                    if( proposal.Proposal_Specialist__c != oldProposalMap.get( proposal.Id ).Proposal_Specialist__c ) {
                        filteredProposals.add( proposal );
                    }
                }
            }
        }
        return filteredProposals;
    }

    public static List<Proposal__c> filterProposalsWithChangedOwner( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ){
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        if( oldProposalMap != null && newProposalList != null ) {
            for( Proposal__c proposal : newProposalList ) {
                if( proposal.OwnerId != oldProposalMap.get( proposal.Id ).OwnerId ) {
                    filteredProposals.add( proposal );
                }
            }
        }
        return filteredProposals;
    }

    public static Set<Id> filterProposalsWithChangedPONotRequiredCheckbox( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ){
        Set<Id> filteredIds = new Set<Id>();
        if( oldProposalMap != null && newProposalList != null ) {
            for( Proposal__c proposal : newProposalList ) {
                if( proposal.Project_Profile__c != null && proposal.PO_Not_Required__c != oldProposalMap.get( proposal.Id ).PO_Not_Required__c ) {
                    filteredIds.add( proposal.Project_Profile__c );
                }
            }
        }
	system.debug(LoggingLevel.Error,'filteredIds ='+filteredIds);
        return filteredIds;
    }

    public static List<Proposal__c> filterProposalsNotDraft( List<Proposal__c> newProposals ){
        if (newProposals == null) return new List<Proposal__c>();
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newProposals ){
            if( !proposal.Is_Draft__c ) {
                filteredProposals.add( proposal );
            }
        }
        return filteredProposals;
    }

    public static List<Proposal__c> filterProposalsToChangeVersion( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ){
        if( oldProposalMap == null ){
            return newProposalList;
        }
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c newProposal: newProposalList ){
            if( newProposal.Status__c != oldProposalMap.get(newProposal.Id).Status__c ){
                filteredProposals.add(newProposal);
            }
        }
        return filteredProposals;
    }

    public static void updateProposalVersion( List<Proposal__c> proposalList ){
        Set<String> proposalMajorVerions = new Set<String>{ PROPOSAL_STATUS_AWARDED, PROPOSAL_STATUS_PENDING_CLIENT, PROPOSAL_STATUS_REJECTED, PROPOSAL_STATUS_CANCELLED, PROPOSAL_STATUS_NOT_AWARDED};
        for( Proposal__c proposalItem: proposalList ) {
            if( proposalItem.Version__c == null ) {
                proposalItem.Version__c = 0.01;
            } else {
                if( proposalMajorVerions.contains( proposalItem.Status__c ) ){
                    proposalItem.Version__c = proposalItem.Version__c.intValue() + VERSION_MAJOR_STEP;
                }else{
                    proposalItem.Version__c = proposalItem.Version__c + VERSION_MINOR_STEP;
                }
                proposalItem.Version_Text__c = getProposalPDFVersion( (Double)proposalItem.Version__c );
            }
        }
    }

    public static String getProposalPDFVersion( Double version){
        String result = String.ValueOf(version);
        if( version < 10 ){
            result = '0' + result;
        }
        List<String> splitedResult = result.split('\\.');
        if( splitedResult[1].length() == 1 ){
            result = result + '0';
        }
        return result;
    }

    public static void updateProposalVersion( Map<Id, List<Change_Order__c>> proposalIdToChangeOrders ){
        Map<Id, Proposal__c> proposalIdToProposal = new Map<Id, Proposal__c>( [ SELECT Id, Version__c, Version_Text__c FROM Proposal__c WHERE Id IN : proposalIdToChangeOrders.keySet() ] );
         List<Change_History_Proposal__c> changeHistoryItemsToCreate = new List<Change_History_Proposal__c>();
        for( List<Change_Order__c> coList : proposalIdToChangeOrders.values() ) {
            for( Change_Order__c coItem : coList ) {
                Proposal__c currentProposal = proposalIdToProposal.get( coItem.Proposal__c );
                if( coItem.Status__c == ChangeOrderServices.STATUS_APPROVED ||
                    coItem.Status__c == ChangeOrderServices.STATUS_PENDING_CLIENT ||
                    coItem.Status__c == ChangeOrderServices.STATUS_REJECTED) {
                    currentProposal.Version__c = currentProposal.Version__c.intValue() + VERSION_MAJOR_STEP;
                } else {
                    Decimal version = proposalIdToProposal.get( coItem.Proposal__c ).Version__c;
                    if( (version + VERSION_MINOR_STEP).intValue() - version.intValue() == 0 ) { //1.7, 1.8, 1.9, 1.9, 1.9
                        currentProposal.Version__c += VERSION_MINOR_STEP;
                    }
                }
                currentProposal.Version_Text__c = getProposalPDFVersion( (Double)currentProposal.Version__c);
                changeHistoryItemsToCreate.add( new Change_History_Proposal__c( Change_Order__c = coItem.Id, Proposal__c = coItem.Proposal__c, Version_Text__c = proposalIdToProposal.get( coItem.Proposal__c ).Version_Text__c ) );
            }
        }
        try {
            UPDATE proposalIdToProposal.values();
            Insert changeHistoryItemsToCreate;
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                proposalIdToProposal.values()[dmlEx.getDmlIndex(i)].addError( 'Can not update Proposal Version: ' + dmlEx.getMessage() );
            }
        }
    }

    public static Map<Id, Boolean> proposalIdToAllOSProposalFlag; // KDI 11/12/13
    public static Map<Id, List<Service_Item__c>> proposalIdToServiceItems; // KDI 11/12/13
    public static Map<Id, Proposal__c> mapProposalWithNotesAndRosters;


    public static Map<Id, Proposal__c> getProposalsWithRelatedLists( List<Proposal__c> proposals ){
        return new Map<Id, Proposal__c>( [ SELECT Id, Municipal_Agency_ID__c, Partner__c, Account_Executive__c, Proposal_Specialist__c, Salesperson__c,
													Address__c, Address__r.Owner_Contact_1__c, Address__r.Owner_Contact_2__c, Address__r.Building_Manager__c, /* MRS 6888 */
                                                  ( Select Title, ParentId, OwnerId, IsPrivate, id, Body From Notes ),
                                                  ( Select Id, Project_Profile__c, Proposal__c, Role__c, Contact__c, User__c From Project_Rosters__r ),
                                                  ( Select Id, Project_Profile__c, Proposal__c From Phases__r ),
                                                  ( SELECT Id, Service_Template__r.Service_Row_Number__c, Is_Alternative__c, Service_Template__r.Role_Assignment__c, Role_Assignment__c FROM Service_Items__r ),
                                                  ( SELECT Proposal__c, Project__c FROM Floors__r ),
                                                  ( SELECT Proposal__c, Project_Profile__c FROM Purchase_Orders__r ),
                                                  ( SELECT Proposal__c, Project_Profile__c FROM Deposit_Invoices__r ),
                                                  ( SELECT Id, Project__c, Proposal__c FROM Doc_Storage__r )
                                           FROM Proposal__c
                                           WHERE Id IN : proposals ] );
    }

    public static void initVariablesForRoleAssignment( List<Proposal__c> proposals ) { // KDI 11/12/13'
        proposalIdToAllOSProposalFlag = new Map<Id, Boolean>();
        proposalIdToServiceItems = ServiceItemServices.getServiceItemsByProposalsIdList( proposals );

        if( proposals.isEmpty() ) return;

        mapProposalWithNotesAndRosters = getProposalsWithRelatedLists( proposals );
        for( Proposal__c prop : mapProposalWithNotesAndRosters.values() ) {
            Boolean hasAllOSServices = true;
            for( Service_Item__c si : prop.Service_Items__r ) {
                if( !si.Is_Alternative__c &&
                    !String.isBlank( si.Service_Template__r.Service_Row_Number__c ) &&
                    !si.Service_Template__r.Service_Row_Number__c.startsWith( ServiceItemServices.OS_SERVICE ) ) {
                    hasAllOSServices = false;
                    break;
                }
            }
            proposalIdToAllOSProposalFlag.put( prop.Id, hasAllOSServices );
        }
    }

     public static Map<Id, Proposal__c> filterProposalWithStatusAwardedForProjectProfileCreation( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldMap ){
        Map<Id, Proposal__c> filteredProposalsForProjectCreation = new Map<Id, Proposal__c>();
        List<Proposal__c> filteredAwardedProposals = filteredProposals( newProposalList, PROPOSAL_STATUS_AWARDED );

        if( !filteredAwardedProposals.isEmpty() ){
            initVariablesForRoleAssignment( filteredAwardedProposals );

            for(Proposal__c proposalItem : filteredAwardedProposals ) {
                if( ( proposalIdToAllOSProposalFlag.get( proposalItem.Id ) != null && proposalIdToAllOSProposalFlag.get( proposalItem.Id ) ) ||
                    ( proposalItem.Project_Team__c != null && oldMap.get( proposalItem.Id ).Project_Team__c == null ) ) { // KDI 11/12/13
                        filteredProposalsForProjectCreation.put( proposalItem.Id, proposalItem );
                }
            }
        }
        return filteredProposalsForProjectCreation;
    }

    public static List<Proposal__c> filterProposalWithStatusFailedInternalReviewForAddRejectionReasonAfterReject( List<Proposal__c> newProposalList ){
        return filteredProposals( newProposalList, PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW );
    }

    public static List<Proposal__c> filterProposalWithStatusRejectedForProposalHistoricalCreation( List<Proposal__c> newProposalList ){
        return filteredProposals( newProposalList, PROPOSAL_STATUS_REJECTED );
    }

    public static List<Proposal__c> filterProposalWithStatusPendingClientApproval( List<Proposal__c> newProposalList ){
        return filteredProposals( newProposalList, PROPOSAL_STATUS_PENDING_CLIENT );
    }

    public static List<Proposal__c> filterProposalWithStatusChangeOrderApproved( List<Proposal__c> newProposalList ){
        return filteredProposals( newProposalList, PROPOSAL_STATUS_CHANGE_ORDER_APPROVED );
    }

    public static List<Proposal__c> filteredProposals( List<Proposal__c> newProposalList, String status ){
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        if( status == PROPOSAL_STATUS_AWARDED ){
            for( Proposal__c proposalItem: newProposalList ){
                if( proposalItem.Status__c == PROPOSAL_STATUS_AWARDED && proposalItem.Project_Profile__c == null ){
                    filteredProposals.add( proposalItem );
                }
            }
        }else if( status == PROPOSAL_STATUS_REJECTED ){
            for( Proposal__c proposalItem: newProposalList ){
                if( proposalItem.Status__c == PROPOSAL_STATUS_REJECTED ){
                    filteredProposals.add( proposalItem );
                }
            }
        }else if( status == PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ){
            for( Proposal__c proposalItem: newProposalList ){
                if( proposalItem.Status__c == PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW && String.isEmpty( proposalItem.Rejection_Reason__c ) ){
                    filteredProposals.add( proposalItem );
                }
            }
        } else if( status == PROPOSAL_STATUS_PENDING_CLIENT ){
            for( Proposal__c proposalItem: newProposalList ){
                if( proposalItem.Status__c == PROPOSAL_STATUS_PENDING_CLIENT ){
                    filteredProposals.add( proposalItem );
                }
            }
        } else if( status == PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ){
            for( Proposal__c proposalItem: newProposalList ){
                if( proposalItem.Status__c == PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ){
                    filteredProposals.add( proposalItem );
                }
            }
        }

        return filteredProposals;
    }

    public static void createProposalHistorical( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ) {
        proposalToHistoricalMap = new Map<String, String>();
        List<Proposal_Historical__c> propHistList = new List<Proposal_Historical__c>();
        List<Service_Historical__c> serviceHictoricalList = new List<Service_Historical__c>();
        Proposal_Historical__c propHist;
        Map<Id, Proposal__c> proposalMapWithServices = new Map<Id, Proposal__c>([Select Id, Name, (Select Id, Name From Service_Items__r) From Proposal__c Where Id IN: newProposalList]);

        for( Proposal__c proposalItem: newProposalList ){
            if( oldProposalMap.get(proposalItem.Id).Status__c != PROPOSAL_STATUS_REJECTED ){
                propHist = new Proposal_Historical__c();
                propHist.Name = proposalItem.Name;
                propHist.Proposal__c = proposalItem.Id;
                propHist.Project_Name__c = proposalItem.Project_Name__c;
                propHist.Version__c = proposalItem.Version__c;
                propHistList.add( propHist );
            }
        }
        try{
            if( !propHistList.isEmpty() ) {
                insert propHistList;
            }
            for( Proposal_Historical__c proposalHistoricalItem: propHistList ){
                for( Service_Item__c serviceItem: proposalMapWithServices.get( proposalHistoricalItem.Proposal__c ).Service_Items__r ){
                    Service_Historical__c servHist = new Service_Historical__c();
                    servHist.Name = serviceItem.Name;
                    servHist.Service_Item__c = serviceItem.Id;
                    servHist.Proposal_Historical__c = proposalHistoricalItem.Id;
                    serviceHictoricalList.add( servHist );
                }
            }
            try{
                if( !serviceHictoricalList.isEmpty() ) {
                    insert serviceHictoricalList;
                }
            }
            catch( DMLException dmlEx ) {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    Service_Historical__c serviceHictorical = serviceHictoricalList[dmlEx.getDmlIndex(i)];
                    for ( Proposal_Historical__c propHistItem: propHistList ){
                        if( serviceHictorical.Proposal_Historical__c == propHistItem.Id ){
                            new Map<Id, Proposal__c> (newProposalList).get(propHistItem.Proposal__c).addError(Label.Create_Service_Historical_Error + dmlEx.getMessage());
                        }
                    }
                }
            }
        }
        catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                new Map<Id, Proposal__c> (newProposalList).get(propHistList[dmlEx.getDmlIndex(i)].Proposal__c).addError( Label.Create_Proposal_Historical_Error + dmlEx.getMessage() );
            }
        }
        for( Proposal_Historical__c proposalHistorical: propHistList){
            proposalToHistoricalMap.put( proposalHistorical.Proposal__c, proposalHistorical.Id );
        }
    }

    public static void addRejectionReasonAfterReject( List<Proposal__c> proposalList ) {
        Map<Id, Proposal__c> idToProposal = new Map<Id, Proposal__c>( proposalList );
        for( ProcessInstance itemPrIns:   [Select TargetObject.Name, TargetObject.Id, TargetObjectId, Status, Id,
                                          (Select StepStatus, Comments, CreatedDate From Steps Order By CreatedDate DESC Limit 1)
                                           From ProcessInstance
                                           Where Status = 'Rejected'
                                           AND TargetObjectId
                                           IN: proposalList
                                           Order By CreatedDate DESC Limit 1]){
            idToProposal.get(itemPrIns.TargetObject.Id).Rejection_Reason__c = itemPrIns.Steps[0].Comments;
        }
    }

    public static void preventDeleteProposalIfStatusAwarded ( List<Proposal__c> newProposalList ){
        for( Proposal__c proposalItem: newProposalList ){
            if( proposalItem.Status__c == PROPOSAL_STATUS_AWARDED ){
                proposalItem.Status__c.addError( Label.Delete_Awarded_Proposal_Error );
            }
        }
    }

    public static Map<Id, Proposal__c> filterProposalsWithChangedStatus( Map<Id, Proposal__c> newMap, Map<Id, Proposal__c> oldMap ) {
        if( oldMap == null ) return newMap;
        Map<Id, Proposal__c> filteredProposals = new Map<Id, Proposal__c>();
        for( Proposal__c proposal: newMap.values() ) {
            if( proposal.Status__c != oldMap.get(proposal.Id).Status__c ) {
                filteredProposals.put( proposal.Id, proposal );
            }
        }

        return filteredProposals;
    }

    public static void updateChangeHistory( Map<Id, Proposal__c> proposalMap ){
        List<Change_History_Proposal__c> changeHistoryItemsToCreate = new List<Change_History_Proposal__c>();
        for( Proposal__c proposal: proposalMap.values() ) {
            changeHistoryItemsToCreate.add( new Change_History_Proposal__c( Proposal__c = proposal.Id, Version_Text__c = proposal.Version_Text__c ) );
        }
        try {
            INSERT changeHistoryItemsToCreate;
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                proposalMap.get(changeHistoryItemsToCreate[dmlEx.getDmlIndex(i)].Proposal__c).addError( 'Can not update Change History: ' + dmlEx.getMessage() );
            }
        }
    }

    public static List<LStore__Stored_Document__c> storedDocsOrFolder(Id parentObjectId, Id folderRecordTypeId, String currentStorageFolder) {

        List<LStore__Stored_Document__c> storedDocsFolderDb = [SELECT LStore__Folder__c, LStore__File_Name__c, LStore__File_Name_Calc__c
                                                               FROM LStore__Stored_Document__c
                                                               WHERE Related_Object_Id__c = : String.valueOf(parentObjectId)
                                                                 AND RecordTypeId = : folderRecordTypeId
                                                                 AND LStore__File_Name_Calc__c = : currentStorageFolder
                                                               LIMIT 1 ];
        List<LStore__Stored_Document__c> storedDocsFolder = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c doc : storedDocsFolderDb ) {
            if( doc.LStore__File_Name__c == currentStorageFolder ) {
                storedDocsFolder.add( doc );
            }
        }
        system.debug('storedDocsFolder: ' + storedDocsFolder);
        if( storedDocsFolder.isEmpty() ) return storedDocsFolder;
        List<LStore__Stored_Document__c> storedDocsFileDb = [SELECT RecordType.DeveloperName, RecordTypeId, LStore__Related_Object_Id__c, LStore__File_Name__c, Id, LStore__Keywords__c, LStore__Folder__c
                                                             FROM LStore__Stored_Document__c
                                                             WHERE Related_Object_Id__c = : String.valueOf(parentObjectId) ];
        List<LStore__Stored_Document__c> storedDocsFile = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c doc : storedDocsFileDb ) {
            if( doc.LStore__Folder__c == storedDocsFolder.get(0).Id ) {
                storedDocsFile.add( doc );
                break;
            }
        }
        system.debug('storedDocsFile: ' + storedDocsFile);
        return storedDocsFile;
    }

    public static void createTaskForProposalCreator( List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposalMap ){
        List<Task> taskList = new List<Task>();
        for( Proposal__c proposal: newProposals ){
            if( !proposal.Is_Draft__c &&
                proposal.Status__c == PROPOSAL_STATUS_PENDING_CLIENT &&
                oldProposalMap.get(proposal.Id).Status__c != PROPOSAL_STATUS_PENDING_CLIENT ){
                Task task = new Task();
                task.Subject = proposal.Name + ': ' + PROPOSAL_STATUS_PENDING_CLIENT;
                task.OwnerId = proposal.OwnerId;
                task.WhatId = proposal.Id;
                task.Priority = 'Normal';
                task.Status = 'In Progress';
                task.ReminderDateTime = proposal.Send_Reminder_To_Creator__c;
                taskList.add( task );
            }
        }
        insert taskList;
    }

    public static Map<Id, Proposal__c> changedAssigneeOnProposal(List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposals) {
        Map<Id, Proposal__c> proposals = new Map<Id, Proposal__c>();
        for (Proposal__c newItem : newProposals) {
            if ( (!String.isBlank(newItem.Project_Team__c) && newItem.Project_Team__c != oldProposals.get(newItem.Id).Project_Team__c) ||
                 (!String.isBlank(newItem.Resource__c) && newItem.Resource__c != oldProposals.get(newItem.Id).Resource__c) ) {
                proposals.put(newItem.Id, newItem);
            }
        }
        return proposals;
    }

    // KDI 2013-10-09 - to re-evaluate time-based wf if proposal status changes
    public static void dummyUpdateRostersForWorkflowReminders( List<Proposal__c> proposals ) {
        Database.update( [SELECT Id FROM Project_Roster__c WHERE Proposal__r.Is_Draft__c = false AND Proposal__c IN : proposals], false );
    }

    public static List<Proposal__c> getProposalById(Id proposalId) {
        return [ SELECT Id, Name, Project_Profile__c, Address__c, Floor_s__c FROM Proposal__c WHERE Id = :proposalId ];
    }

    public static Id getProposalIdByProjectId(Id projectId) {
        if (String.isBlank(projectId)) {
            throw new ErrorException('Parameter project Id can not be empty!');

        }

        List<Proposal__c> proposals = new List<Proposal__c>([SELECT Id FROM Proposal__c WHERE Project_Profile__c =: projectId]);

        if (proposals.isEmpty()) {
            throw new ErrorException('Proposal(s) does not exist!');

        }

        return proposals.get(0).Id;

    }

    public static void syncProposalFields( List<Project_Profile__c> projectsWithChangedProjectTeamsOrOtherLookupFields,
                                           List<Project_Profile__c> projectsWithChangedName,
                                           List<Project_Profile__c> projectsWithChangedProposalCreator,
                                           List<Project_Profile__c> projectsWithChangedClientProject,
                                           Map<Id, Project_Profile__c> oldProjects ) {
        Map<Id, Proposal__c> proposalIdToProposal = new Map<Id, Proposal__c>();
        Map<Id, Project_Profile__c> proposalIdToProjectForErrorHandling = new Map<Id, Project_Profile__c>();

        for( Project_Profile__c project : projectsWithChangedProjectTeamsOrOtherLookupFields ) {
            if( project.Project_Team__c != oldProjects.get( project.Id ).Project_Team__c || //MRS-6358, MRS-6344
                project.FREP__c != oldProjects.get( project.Id ).FREP__c || //MRS-6751
                project.Production_Manager__c != oldProjects.get( project.Id ).Production_Manager__c ) {
                Proposal__c proposal = proposalIdToProposal.get( project.Proposal__c );
                if( proposal == null ) {
                    proposal = new Proposal__c( Id = project.Proposal__c );
                }
                proposal.Project_Team__c = project.Project_Team__c;
                proposal.FREP__c = project.FREP__c;
                proposal.Production_Manager__c = project.Production_Manager__c;
                proposalIdToProposal.put( proposal.Id, proposal );
                proposalIdToProjectForErrorHandling.put( proposal.Id, project );
            }
        }

        for( Project_Profile__c project : projectsWithChangedName ) {
            Proposal__c proposal = proposalIdToProposal.get( project.Proposal__c );
            if( proposal == null ) {
                proposal = new Proposal__c( Id = project.Proposal__c );
            }
            proposal.Project_Name__c = project.Project_Name__c;
            proposalIdToProposal.put( proposal.Id, proposal );
            proposalIdToProjectForErrorHandling.put( proposal.Id, project );
        }

        for( Project_Profile__c project : projectsWithChangedProposalCreator ) {
            if( !String.isBlank( project.Proposal_Specialist__c ) ) {
                Proposal__c proposal = proposalIdToProposal.get( project.Proposal__c );
                if( proposal == null ) {
                    proposal = new Proposal__c( Id = project.Proposal__c );
                }
                proposal.Proposal_Specialist__c = project.Proposal_Specialist__c;
                proposal.OwnerId = project.Proposal_Specialist__c;
                proposalIdToProposal.put( proposal.Id, proposal );
                proposalIdToProjectForErrorHandling.put( proposal.Id, project );
            }
        }

        for( Project_Profile__c project : projectsWithChangedClientProject ) {
            Proposal__c proposal = proposalIdToProposal.get( project.Proposal__c );
            if( proposal == null ) {
                proposal = new Proposal__c( Id = project.Proposal__c );
            }
            proposal.Client_Project__c = project.Client_Project__c;
            proposalIdToProposal.put( proposal.Id, proposal );
            proposalIdToProjectForErrorHandling.put( proposal.Id, project );
        }

        proposalIdToProposal.remove( null );
        proposalIdToProjectForErrorHandling.remove(null);

        if( !proposalIdToProposal.keySet().isEmpty() ) {
            try {
                UPDATE proposalIdToProposal.values();
            } catch( DmlException dmlEx ) {
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                    proposalIdToProjectForErrorHandling.get( proposalIdToProposal.values()[i].Id ).addError( 'Can not sync Proposal fields with Project. ' + dmlEx.getMessage() );
                }
            }
        }
     }

    public static void updateProposalsWithProjectProfile( List<Project_Profile__c> createdProjects ) {
        List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
        for( Project_Profile__c pp : createdProjects ) {
            if( !String.isBlank(pp.Proposal__c) ) {
                proposalsToUpdate.add( new Proposal__c( Id = pp.Proposal__c, Project_Profile__c = pp.Id ) );
            }
        }
        UPDATE proposalsToUpdate;
        // KDI - 05-Dec-2013: Added ^^^ instead of vvv
        /*Map<Id, Id> proposalIdsToProjectId = new Map<Id, Id>();
        for( Project_Profile__c pr : createdProjects ){
            proposalIdsToProjectId.put( pr.Proposal__c, pr.Id );
        }
        List<Proposal__c> proposalsToUpdate = [ Select Id, Project_Profile__c From Proposal__c Where Id IN :proposalIdsToProjectId.keySet() ];
        for( Proposal__c prop : proposalsToUpdate ) {
            prop.Project_Profile__c = proposalIdsToProjectId.get( prop.Id );
        }
        update proposalsToUpdate;*/
    }

    public static void cleanUpCZAnalystData( Map<Id, Change_Order__c> changeOrders ){
    	if (changeOrders.isEmpty()){return;}//MRS-7473
        Set<Id> proposalsId = new Set<Id>();
        for( Change_Order__c changeOrder: changeOrders.values() ){
            proposalsId.add( changeOrder.Proposal__c );
        }
        Map<Id, Proposal__c> proposalIdToProposal = new Map<Id, Proposal__c>( [ SELECT Id, Code_Zoning_Analyst__c, Code_Zoning_Analyst_Email__c FROM Proposal__c WHERE Id IN : proposalsId ] );
        for( Proposal__c proposal : proposalIdToProposal.values() ) {
            proposal.Code_Zoning_Analyst__c = null;
            proposal.Code_Zoning_Analyst_Email__c = null;
        }
        try {
            UPDATE proposalIdToProposal.values();
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                proposalIdToProposal.values()[dmlEx.getDmlIndex(i)].addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
            }
        }

    }

    public static Map<Id, String> filterProposalsWithChangedMunicipalityId( List<Proposal__c> newList, Map<Id, Proposal__c> oldMap ) {
        Map<Id, String> proposalIdToMunicipalityIdMap = new Map<Id, String>();
        for( Proposal__c proposal : newList ) {
            if( ( proposal.Municipal_Agency_ID__c != oldMap.get( proposal.Id ).Municipal_Agency_ID__c ) ) {
                proposalIdToMunicipalityIdMap.put( proposal.Id, proposal.Municipal_Agency_ID__c );
            }
        }
        return proposalIdToMunicipalityIdMap;
    }

    public static List<Proposal__c> filterProposalsWithEmptyRetainerAmount( List<Proposal__c> newList ) {
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newList ) {
            if( proposal.Retainer_Amount__c == null ) {
                filteredProposals.add(proposal);
            }
        }
        return filteredProposals;
    }

    public static void setDefaultRetainerAmountValue(  List<Proposal__c> proposals ){
        if( proposals.isEmpty() ) return;
        for( Proposal__c proposal : proposals ) {
            proposal.Retainer_Amount__c = 30;
        }
    }

    public static List<Roster_Email_Junction__c> filterEmailJunctionsAfterPendingClientApproval( List<Proposal__c> newProposalList, Map<Id, Proposal__c> oldProposalMap ) {
        Set<Id> proposalIds = new Set<Id>();
        for( Proposal__c newProposal: newProposalList ) {
            if( ( newProposal.Status__c != PROPOSAL_STATUS_PENDING_CLIENT && oldProposalMap.get(newProposal.Id).Status__c == PROPOSAL_STATUS_PENDING_CLIENT ) ||
                ( newProposal.Status__c == PROPOSAL_STATUS_EXPIRED && oldProposalMap.get(newProposal.Id).Status__c != PROPOSAL_STATUS_EXPIRED ) ) {
                proposalIds.add(newProposal.Id);
            }
        }
        List<Roster_Email_Junction__c> junctions = new List<Roster_Email_Junction__c>();
        if( !proposalIds.isEmpty() ) {
            junctions = [ SELECT Id FROM Roster_Email_Junction__c WHERE Proposal__c IN : proposalIds ];
        }
        return junctions;
    }

    public static List<Proposal__c> filterProposalsAfterPendingClientApprovalToVoidEnvelopes( List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposalMap ) {
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newProposals ) {
            if( proposal.Status__c != PROPOSAL_STATUS_PENDING_CLIENT && proposal.Status__c != PROPOSAL_STATUS_AWARDED && oldProposalMap.get( proposal.Id ).Status__c == PROPOSAL_STATUS_PENDING_CLIENT ) {
                filteredProposals.add( proposal );
            }
        }
        return filteredProposals;
    }

    public static void updateBaseServicesTotal( List<Id> proposalIds ) {
        if( proposalIds.isEmpty() ) return;
        Map<Id, Proposal__c> proposalsForUpdate = new Map<Id, Proposal__c>();

        for( AggregateResult total : [ SELECT Proposal__c proposal, SUM(Total_Service_Price__c) total
                                         FROM Service_Item__c
                                        WHERE Proposal__c IN : proposalIds
                                          AND Proposal__r.Status__c != : ProposalServices.PROPOSAL_STATUS_AWARDED
                                          AND Is_Alternative__c = false
                                          AND Original__c = true
                                          AND Total_Service_Price__c != null
                                        GROUP BY Proposal__c ] ) {
            proposalsForUpdate.put( (Id)total.get('proposal'), new Proposal__c( Id = (Id)total.get('proposal'), Base_Services_Total__c = (Decimal)total.get('total') ) );
        }
        for( Id proposalId : proposalIds ) {
            if( !proposalsForUpdate.containsKey( proposalId ) ) {
                proposalsForUpdate.put( proposalId, new Proposal__c( Id = proposalId, Base_Services_Total__c = 0.00 ) );
            }
        }
        UPDATE proposalsForUpdate.values();
    }

    @future
    public static void updateReceivedPO( Set<Id> proposalIds ) {//MRS-7473
    	updateReceivedPO(proposalIds, new List<Service_Item__C>());
    }

    public static void updateReceivedPO( Set<Id> proposalIds, List<Service_Item__C> serviceItemListNew ) {
        if( !proposalIds.isEmpty() ) {
System.debug( LoggingLevel.Error, 'xxx proposalIds: ' + proposalIds );
            List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
            List<Service_Item__c> servicesFromDB = [ SELECT Proposal__c, Original__c, Change_Order__c, Change_Order__r.Status__c, Purchase_Order__c, Is_Amendmend_Deleted__c
                                                     FROM Service_Item__c
                                                     WHERE Proposal__c IN : proposalIds
                                                       AND ( Status__c = : ServiceItemServices.SERVICE_STATUS_ACTIVE OR Status__c = : ServiceItemServices.SERVICE_STATUS_NOTSTARTED OR
                                                             Status__c = :ServiceItemServices.SERVICE_STATUS_COMPLETED )
                                                       /*AND ( Original__c = true OR Change_Order__r.Status__c = : ChangeOrderServices.STATUS_APPROVED )*/
                                                       AND Is_Alternative__c = false
                                                       AND ( ( Is_Amendmend_Deleted__c = false AND Change_Order__r.Status__c  = : ChangeOrderServices.STATUS_APPROVED ) OR
                                                             ( Is_Amendmend_Deleted__c = true  AND Change_Order__r.Status__c != : ChangeOrderServices.STATUS_APPROVED ) OR
                                                             ( Original__c = true AND Change_Order__c = null ) ) ];
                                                       /*AND ( ( Is_Amendmend_Deleted__c = false OR
                                                               Change_Order__r.Status__c != : ChangeOrderServices.STATUS_APPROVED ) AND
                                                             Actual_End_Date__c = null ) //instead of service status*/
            Set<Id> proposalsWithServicesIdxSet = new Set<Id> (); // MRS 7074
            Set<Id> proposalIdsWithBaseServicesPoReceived = new Set<Id>();
            Set<Id> proposalIdsWithAllServicesPoReceived = new Set<Id>();

            for( Service_Item__c serviceItem : servicesFromDB ) { // MRS 7074
System.debug( LoggingLevel.Error, 'xxx serviceItem: ' + serviceItem );
                if( serviceItem.Purchase_Order__c == null ) {
                    if( serviceItem.Original__c ) {
                        proposalIdsWithBaseServicesPoReceived.add( serviceItem.Proposal__c );
                        proposalIdsWithAllServicesPoReceived.add( serviceItem.Proposal__c );
                    } else if( serviceItem.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ) {
                        proposalIdsWithAllServicesPoReceived.add( serviceItem.Proposal__c );
                    }
                }
                proposalsWithServicesIdxSet.add( serviceItem.Proposal__c );
            }
System.debug( LoggingLevel.Error, 'xxx proposalsWithServicesIdxSet: ' + proposalsWithServicesIdxSet );
System.debug( LoggingLevel.Error, 'xxx proposalIdsWithBaseServicesPoReceived: ' + proposalIdsWithBaseServicesPoReceived );
System.debug( LoggingLevel.Error, 'xxx proposalIdsWithAllServicesPoReceived: ' + proposalIdsWithAllServicesPoReceived );
            for( Id proposalId : proposalIds ) {
                if( proposalsWithServicesIdxSet.contains( proposalId ) ) { // MRS 7074
                    proposalsToUpdate.add( new Proposal__c( Id = proposalId,
                                                            Received_PO__c = !proposalIdsWithBaseServicesPoReceived.contains( proposalId ),
                                                            Received_PO_All_Services__c = !proposalIdsWithAllServicesPoReceived.contains( proposalId ) ) );
                } else {
                    proposalsToUpdate.add( new Proposal__c( Id = proposalId, Received_PO__c = false, Received_PO_All_Services__c = false ) );
                }
            }
System.debug( LoggingLevel.Error, 'xxx proposalsToUpdate: ' + proposalsToUpdate );
            if( !proposalsToUpdate.isEmpty() ) {
                try {
                    UPDATE proposalsToUpdate;
                } catch( DMLException dmlEx ) {
                    if ( serviceItemListNew == null || serviceItemListNew.isEmpty() ){ //MRS-6595
                        for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                            proposalsToUpdate[dmlEx.getDmlIndex(i)].addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                        }
                    } else {
                        for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                            Id proposalId = proposalsToUpdate[dmlEx.getDmlIndex(i)].Id;
                            for ( Service_Item__c serviceItemItem : serviceItemListNew ){
                                if ( serviceItemItem.Proposal__c == proposalId ){
                                    serviceItemItem.addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static List<Proposal__c> updateRequestDate( List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposals ) {
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newProposals ) {
            if( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW &&
                ( oldProposals == null || oldProposals.get( proposal.Id ).Status__c != proposal.Status__c ) ) {
                proposal.Request_Date__c = Date.today();
            }
        }
        return filteredProposals;
    }

    public static List<Proposal__c> filterProposalsToChangeRecordType( List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposals ) {
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newProposals ) {
            if( oldProposals == null || oldProposals.get( proposal.Id ).Status__c != proposal.Status__c ) {
                if( getProposalStatusToRecordTypeName().keySet().contains( proposal.Status__c ) ) {
                    filteredProposals.add( proposal );
                }
            }
        }
        return filteredProposals;
    }

    public static void updateRecordTypeForLayoutChange( List<Proposal__c> filteredProposals ) {
        if( filteredProposals != null && !filteredProposals.isEmpty() ) {
            Map<String, Id> recordtypeNameToId = ProposalServices.getRecordTypeNameToId();
            for( Proposal__c proposal : filteredProposals ) {
                String recordTypeName = getProposalStatusToRecordTypeName().get( proposal.Status__c );
                if( !String.isBlank( recordTypeName ) ) {
                    proposal.RecordTypeId = recordtypeNameToId.get( recordTypeName );
                }
            }
        }
    }

    public static Map<String, String> getProposalStatusToRecordTypeName() {
        return new Map<String, String>{ ProposalServices.PROPOSAL_STATUS_NEW                    => ProposalServices.PROPOSAL_RECORDTYPE_STANDARD,
                                        ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW => ProposalServices.PROPOSAL_RECORDTYPE_STANDARD,
                                        ProposalServices.PROPOSAL_STATUS_REJECTED               => ProposalServices.PROPOSAL_RECORDTYPE_STANDARD,
                                        ProposalServices.PROPOSAL_STATUS_IN_REVIEW              => ProposalServices.PROPOSAL_RECORDTYPE_IN_REVIEW,
                                        ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT         => ProposalServices.PROPOSAL_RECORDTYPE_APPROVED,
                                        ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW => ProposalServices.PROPOSAL_RECORDTYPE_APPROVED,
                                        ProposalServices.PROPOSAL_STATUS_NOT_AWARDED            => ProposalServices.PROPOSAL_RECORDTYPE_APPROVED,
                                        ProposalServices.PROPOSAL_STATUS_CANCELLED              => ProposalServices.PROPOSAL_RECORDTYPE_APPROVED,
                                        ProposalServices.PROPOSAL_STATUS_AWARDED                => ProposalServices.PROPOSAL_RECORDTYPE_AWARDED };
    }

    public static Map<String, Id> getRecordTypeNameToId() {
        Map<String, Id> recordtypeNameToId = new Map<String, Id>();
        for( Recordtype recordtypeItem : [ SELECT Id, Name FROM Recordtype
                                          WHERE SobjectType = : ProposalServices.PROPOSAL_OBJECT_API_NAME ] ) {
            recordtypeNameToId.put( recordtypeItem.Name, recordtypeItem.Id );
        }
        return recordtypeNameToId;
    }

    public static List<Proposal__c> updateLastStatusChange( List<Proposal__c> newProposals, Map<Id, Proposal__c> oldProposals ) {
        List<Proposal__c> filteredProposals = new List<Proposal__c>();
        for( Proposal__c proposal : newProposals ) {
            if( oldProposals == null || oldProposals.get( proposal.Id ).Status__c != proposal.Status__c ) {
                proposal.Last_Status_Change__c = DateTime.now(); // MRS 7165
            }
        }
        return filteredProposals;
    }

	public static void setQuarterlyMonthAccordinglyToFrequency(List<Proposal__c> newList) { //MRS 7400
		for(Proposal__c proposal : newList) {
			if(proposal.Frequency__c == 'Weekly' || proposal.Frequency__c == 'Monthly') proposal.Quarterly_Month__c = null;
		}
	}
}