public class DepositInvoiceServices {
    public final static String RETAINER_INVOICE_DDP = 'Deposit Invoice'; //MRS 7498
    public static final String SERVICE_RETAINER_TYPE = 'Service Retainer';
    public static final String MUNICIPAL_FEE_RETAINER_TYPE = 'Municipal Fee Deposit'; //MRS 7498

    //MRS 6688
    public static void sendEmailsWhenRamainingLess15perOfPaid( List<Deposit_Invoice__c> newList, Map<Id, Deposit_Invoice__c> oldMap ) {
        Set<Id> idxNewIvoicesSet = new Set<Id> ();
        for(Deposit_Invoice__c dInvoice : newList) idxNewIvoicesSet.add(dInvoice.Id);
        List<c2g__codaCashEntryLineItem__c> codaCashEntryLineItemList= [SELECT c2g__CashEntry__r.c2g__Status__c, Deposit_Invoice__c
                                                                            FROM c2g__codaCashEntryLineItem__c
                                                                            WHERE Deposit_Invoice__c IN :idxNewIvoicesSet
                                                                                AND c2g__CashEntry__r.c2g__Status__c = 'Complete'];
        Set<Id> idInvWithPostedCashEntriesSet = new Set<Id> ();
        for(c2g__codaCashEntryLineItem__c codaTransactionLineItem : codaCashEntryLineItemList) idInvWithPostedCashEntriesSet.add(codaTransactionLineItem.Deposit_Invoice__c);

        Map<Id, String> projectsIdToInvoiceLink = new Map<Id, String> ();
        for( Deposit_Invoice__c di : newList ) {
            if(idInvWithPostedCashEntriesSet.contains(di.Id)) {
                Decimal newInvoiceAmountPaid = di.Amount_Paid__c == null ? 0 : di.Amount_Paid__c;
                Decimal newInvoiceAmountRemaining = di.Amount_Remaining__c == null ? 0 : di.Amount_Remaining__c;
                if( newInvoiceAmountRemaining < newInvoiceAmountPaid * 0.15 && di.Project_Profile__c != null && di.Deposit_Invoice_Type__c == MUNICIPAL_FEE_RETAINER_TYPE ) {
                    if( oldMap == null ) {
                        projectsIdToInvoiceLink.put( di.Project_Profile__c, '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + di.Id + '">' + di.Deposit_Invoice_Number__c + '</a>' );
                    } else {
                        Decimal oldInvoiceAmountPaid = oldMap.get( di.Id ).Amount_Paid__c == null ? 0 : oldMap.get( di.Id ).Amount_Paid__c;
                        Decimal oldInvoiceAmountRemaining = oldMap.get( di.Id ).Amount_Remaining__c == null ? 0 : oldMap.get( di.Id ).Amount_Remaining__c;
                        if( (newInvoiceAmountPaid + newInvoiceAmountRemaining != oldInvoiceAmountPaid + oldInvoiceAmountRemaining ) )
                            projectsIdToInvoiceLink.put( di.Project_Profile__c, '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + di.Id + '">' + di.Deposit_Invoice_Number__c + '</a>' );
                    }
                }
            }
        }

        if( !projectsIdToInvoiceLink.isEmpty() ) {
			Map<Id, Id> projectIdToAccountManagerUserIdMap = new Map<Id, Id> ();
			for(Project_Roster__c roster : [SELECT Project_Profile__c, User__c
											   FROM Project_Roster__c
											   WHERE Role__c = :ProjectRosterServices.ACCOUNT_MANAGER
												 AND Project_Profile__c IN :projectsIdToInvoiceLink.keySet()
												 AND Active__c = true
												 AND User__c != null]) projectIdToAccountManagerUserIdMap.put(roster.Project_Profile__c, roster.User__c);
 			
			
            List<Deposit_Invoice__c> invoices = [SELECT Project_Profile__c,
														Project_Profile__r.Id,
                                                        Project_Profile__r.Project_Name__c,
                                                        Project_Profile__r.Project_Name_For_Email__c,
                                                        Project_Profile__r.Project_Number_URL__c,
                                                        Project_Profile__r.Building__r.Name,
                                                        Project_Profile__r.Floor_s__c,
                                                        Project_Profile__r.Production_Manager__c,
                                                        Project_Profile__r.OwnerId,
                                                        Amount_Paid__c, Amount_Remaining__c, Deposit_Invoice_Number__c, CreatedDate
                                                FROM Deposit_Invoice__c
                                                WHERE Project_Profile__c IN: projectsIdToInvoiceLink.keySet()
                                                    AND Deposit_Invoice_Type__c = :MUNICIPAL_FEE_RETAINER_TYPE];  

            Map<Id, Map<Id, List<Deposit_Invoice__c>>> userIdToMapProjectIdToListOfInvoices = new Map<Id, Map<Id, List<Deposit_Invoice__c>>> ();
            for( Deposit_Invoice__c invoice : invoices ) {
                Id receiverUserId;
                if( projectIdToAccountManagerUserIdMap.get(invoice.Project_Profile__c) != null ) receiverUserId = projectIdToAccountManagerUserIdMap.get(invoice.Project_Profile__c);
                else if( invoice.Project_Profile__r.Production_Manager__c != null ) receiverUserId = invoice.Project_Profile__r.Production_Manager__c;
                     else receiverUserId = invoice.Project_Profile__r.OwnerId;
                
                if( userIdToMapProjectIdToListOfInvoices.get( receiverUserId ) == null ) userIdToMapProjectIdToListOfInvoices.put( receiverUserId, new Map<Id, List<Deposit_Invoice__c>> () );
                if( userIdToMapProjectIdToListOfInvoices.get( receiverUserId ).get( invoice.Project_Profile__r.Id ) == null )
                                            userIdToMapProjectIdToListOfInvoices.get( receiverUserId ).put( invoice.Project_Profile__r.Id, new List<Deposit_Invoice__c> () );
                userIdToMapProjectIdToListOfInvoices.get( receiverUserId ).get( invoice.Project_Profile__r.Id ).add( invoice );
            }

            for( Id userId : userIdToMapProjectIdToListOfInvoices.keyset() ) {
                for( Id projectId : userIdToMapProjectIdToListOfInvoices.get( userId ).keyset() ) {
                    Deposit_Invoice__c invoice = userIdToMapProjectIdToListOfInvoices.get( userId ).get( projectId ).get(0);
                    String subject = invoice.Project_Profile__r.Project_Name_For_Email__c + ', ' + invoice.Project_Profile__r.Project_Name__c + ' - ' + invoice.Project_Profile__r.Building__r.Name + ', ' 
                                + invoice.Project_Profile__r.Floor_s__c + ' - Municipal Fee Retainer Low';
                    String body = '<html>There is less than 15% of the original municipal fee retainer amount left for Deposit Invoice# '
                                   + projectsIdToInvoiceLink.get( projectId ) +
                                   + '.<br/>Please review the project and any other retainers that may exist to determine if additional fees need to be requested from the client.<br/><br/>'
                                   + '<table style="border:1px solid black; border-collapse:collapse;"><thead><tr style="background-color:#f0f0f0;">'
                                   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Municipal Fee Retainer Invoices</th>'
                                   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Date</th>'
                                   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Amount Paid</th>'
                                   + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">Amount Remaining</th></tr></thead><tbody>';
                    Decimal totalPaid = 0, totalRemaining = 0;
                    for( Deposit_Invoice__c di : userIdToMapProjectIdToListOfInvoices.get( userId ).get( projectId ) ) {
                        Decimal amountPaid = di.Amount_Paid__c == null ? 0 : di.Amount_Paid__c;
                        Decimal amountRemaining = di.Amount_Remaining__c == null ? 0 : di.Amount_Remaining__c;
                        DateTime dateDi = di.CreatedDate;
                        body += '<tr>'
                               +'<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ di.Deposit_Invoice_Number__c +'</td>'
                               +'<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ dateDi.format('MM/dd/yyyy') +'</td>'
                               +'<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ amountPaid +'</td>'
                               +'<td style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;">'+ amountRemaining +'</td>'
                               +'</tr>';
                        totalPaid += amountPaid;
                        totalRemaining += amountRemaining;
                    }
                    body += '<tr><th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px;"></th>'
                              + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px; text-align: left;">Total:</th>'
                              + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px; text-align: left;">' + totalPaid + '</th>'
                              + '<th style="border:1px solid black; border-collapse:collapse; padding: 3px 4px 3px 4px; text-align: left;">' + totalRemaining + '</th></tr></tbody></table></html>';
                    EmailMessageService.sendMassMailToInternalUsers( new Set<Id> { userId }, body, subject);
                }
            }
        }
    } 

    //MRS 6991 7289
    public static List<Map<Id, List<String>>> filteredIdsOfRetainerInvoicesWithChangedCashEntryLineItems( Map<Id, c2g__codaCashEntryLineItem__c> newItems,
                                                                                                        Map<Id, c2g__codaCashEntryLineItem__c> oldItems) {
		List<Map<Id, List<String>>> res = new List<Map<Id, List<String>>> {new Map<Id, List<String>>(), new Map<Id, List<String>>()};
		//res[0] - MUNICIPAL_FEE_RETAINER_TYPE, res[1] - SERVICE_RETAINER_TYPE
        for( Id idx : newItems.keySet() ) {
            if( newItems.get( idx ).Deposit_Invoice__c != null
                && ( oldItems == null || oldItems.get( idx ) == null ||
                     oldItems.get( idx ).Payment_Type__c != newItems.get( idx ).Payment_Type__c ||
                     oldItems.get( idx ).Deposit_Invoice__c != newItems.get( idx ).Deposit_Invoice__c   ) ) {

				if(newItems.get( idx ).Payment_Type__c == MUNICIPAL_FEE_RETAINER_TYPE) {
                	res[0].put(newItems.get( idx ).Deposit_Invoice__c, new List<String> { String.valueOf(newItems.get(idx).c2g__CashEntryValue__c), String.valueOf(newItems.get(idx).c2g__LineDescription__c) });
				} else if(newItems.get( idx ).Payment_Type__c == SERVICE_RETAINER_TYPE) {
					res[1].put(newItems.get( idx ).Deposit_Invoice__c, new List<String> { String.valueOf(newItems.get(idx).c2g__NetValue__c) });
				}
            }
        }
        return res;
    }

    //MRS 6991 7289
    public static void sendEmailsRegCashEntLineItems( List<Map<Id, List<String>>> invoicesStructure ) {
		if(!invoicesStructure[0].isEmpty()) {
	        for( Deposit_Invoice__c invoice : [SELECT Project_Profile__r.Project_Name_For_Email__c,
                                                    Project_Profile__r.Project_Number_URL__c,
                                                    Project_Profile__r.Project_Member__c,
                                                    Project_Profile__r.Project_Manager__c,
                                                    Project_Profile__r.Production_Manager__c,
	                                                    Project_Profile__r.OwnerId,
														Project_Profile__c
                                            FROM Deposit_Invoice__c
	                                            WHERE Id IN: invoicesStructure[0].keySet()] ) {

                if( invoice.Project_Profile__c != null) {
                    Set<Id> userIdx = new Set<Id> ();
                    if( invoice.Project_Profile__r.Project_Member__c != null ) userIdx.add( invoice.Project_Profile__r.Project_Member__c );
                    if( invoice.Project_Profile__r.Project_Manager__c != null ) userIdx.add( invoice.Project_Profile__r.Project_Manager__c );
                    if( invoice.Project_Profile__r.Production_Manager__c != null ) userIdx.add( invoice.Project_Profile__r.Production_Manager__c );
                    userIdx.add(invoice.Project_Profile__r.OwnerId);
                    EmailMessageService.sendMassMailToInternalUsers( userIdx,
									'<html> DOB Fees Payment of $ ' + invoicesStructure[0].get(invoice.Id).get(0) + ' has been received for <a href="' +
                                                                               System.URL.getSalesforceBaseUrl().toExternalForm() +
                                                                                ((String)invoice.Project_Profile__r.Project_Number_URL__c).remove('<a href="')
                                                                                + '<br/>Description: ' + invoicesStructure[0].get(invoice.Id).get(1) +
                                                                                +'</html>', 'Payment Received for ' + invoice.Project_Profile__r.Project_Name_For_Email__c); // MRS 6259
                }
			}
		}
		if(!invoicesStructure[1].isEmpty()) {
			for( Deposit_Invoice__c invoice : [SELECT Proposal__r.OwnerId, Proposal__r.Name, Proposal__c
	                                            FROM Deposit_Invoice__c
	                                            WHERE Id IN: invoicesStructure[1].keySet()] ) {
                if(invoice.Proposal__c != null) {
                    EmailMessageService.sendMassMailToInternalUsers( new Set<Id> { invoice.Proposal__r.OwnerId },
									'<html> A payment of ' + invoicesStructure[1].get(invoice.Id).get(0) + ' has been received for <a href="' 
								   + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + ((String)invoice.Proposal__c) + '">' + invoice.Proposal__r.Name + '</a>.</html>',
									'Retainer payment received for ' + invoice.Proposal__r.Name);
                }
            }
        }
    }

    public static void calculateAmountPaid( List<c2g__codaCashEntryLineItem__c> newItems, List<c2g__codaCashEntryLineItem__c> oldItems ) {
        Map<Id, Deposit_Invoice__c> depositInvoicesToUpdate = new Map<Id, Deposit_Invoice__c>();
        if( newItems != null ) {
            for( c2g__codaCashEntryLineItem__c celi : newItems ) {
                depositInvoicesToUpdate.put( celi.Deposit_Invoice__c, new Deposit_Invoice__c( Id = celi.Deposit_Invoice__c,
                                                                                              Amount_Paid__c = 0.00 ) );
            }
        }
        if( oldItems != null ) {
            for( c2g__codaCashEntryLineItem__c celi : oldItems ) {
                depositInvoicesToUpdate.put( celi.Deposit_Invoice__c, new Deposit_Invoice__c( Id = celi.Deposit_Invoice__c,
                                                                                              Amount_Paid__c = 0.00 ) );
            }
        }
        depositInvoicesToUpdate.remove(null);
        for( AggregateResult aggItem : [ SELECT Deposit_Invoice__c, SUM(c2g__NetValue__c)
                                         FROM c2g__codaCashEntryLineItem__c
                                         WHERE Deposit_Invoice__c IN : depositInvoicesToUpdate.keySet()
                                         GROUP BY Deposit_Invoice__c] ) {
            depositInvoicesToUpdate.put( (Id)aggItem.get('Deposit_Invoice__c'), new Deposit_Invoice__c( Id = (Id)aggItem.get('Deposit_Invoice__c'),
                                                                                                        Amount_Paid__c = (Decimal)aggItem.get('expr0') ) );
        }
        try {
            UPDATE depositInvoicesToUpdate.values();
        } catch( dmlException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                depositInvoicesToUpdate.values()[i].addError( 'Can not update Deposit Invoice Totals. ' + dmlEx.getMessage() );
            }
        }
    }

    public static List<List<Deposit_Invoice__c>> filterDepositInvoicesForPopulateProposalOrProject( List<Deposit_Invoice__c> newItems, Map<Id, Deposit_Invoice__c> oldItemsMap ) {
        List<Deposit_Invoice__c> filteredInvoicesToPopulateProject = new List<Deposit_Invoice__c>();
        List<Deposit_Invoice__c> filteredInvoicesToPopulateProposal = new List<Deposit_Invoice__c>();
        for( Deposit_Invoice__c depositInvoiceItem : newItems ) {
            if( String.isBlank( depositInvoiceItem.Project_Profile__c ) && !String.isBlank( depositInvoiceItem.Proposal__c ) ) {
                filteredInvoicesToPopulateProject.add( depositInvoiceItem );
            }
            if( !String.isBlank( depositInvoiceItem.Project_Profile__c ) && String.isBlank( depositInvoiceItem.Proposal__c ) ) {
                filteredInvoicesToPopulateProposal.add( depositInvoiceItem );
            }
        }
        return new List<List<Deposit_Invoice__c>>{ new List<Deposit_Invoice__c>( filteredInvoicesToPopulateProject ),
                                                   new List<Deposit_Invoice__c>( filteredInvoicesToPopulateProposal ) };
    }

    public static void populateProposalOrProject( List<List<Deposit_Invoice__c>> filteredItems ) {
        Set<Id> parentIds;
        if( !filteredItems[0].isEmpty() ) {
            parentIds = new Set<Id>();
            for( Deposit_Invoice__c depositInvoiceItem : filteredItems[0] ) {
                parentIds.add( depositInvoiceItem.Proposal__c );
            }
            Map<Id, Proposal__c> proposalIdToProposal = new Map<Id, Proposal__c>( [ SELECT Id, Project_Profile__c
                                                                                    FROM Proposal__c
                                                                                    WHERE Id IN : parentIds ] );
            for( Deposit_Invoice__c depositInvoiceItem : filteredItems[0] ) {
                depositInvoiceItem.Project_Profile__c = proposalIdToProposal.get( depositInvoiceItem.Proposal__c ) != null ? proposalIdToProposal.get( depositInvoiceItem.Proposal__c ).Project_Profile__c : null;
            }
        }
        if( !filteredItems[1].isEmpty() ) {
            parentIds = new Set<Id>();
            for( Deposit_Invoice__c depositInvoiceItem : filteredItems[1] ) {
                parentIds.add( depositInvoiceItem.Project_Profile__c );
            }
            Map<Id, Project_Profile__c> projectIdToProject = new Map<Id, Project_Profile__c>( [ SELECT Id, Proposal__c
                                                                                                FROM Project_Profile__c
                                                                                                WHERE Id IN : parentIds ] );
            for( Deposit_Invoice__c depositInvoiceItem : filteredItems[1] ) {
                depositInvoiceItem.Proposal__c = projectIdToProject.get( depositInvoiceItem.Project_Profile__c ) != null ? projectIdToProject.get( depositInvoiceItem.Project_Profile__c ).Proposal__c : null;
            }
        }
    }

    public static List<Deposit_Invoice__c> filterDepositInvoicesForPopulateCompanyData( List<Deposit_Invoice__c> newItems ) {
        List<Deposit_Invoice__c> filteredInvoices = new List<Deposit_Invoice__c>();
        for( Deposit_Invoice__c depositInvoiceItem : newItems ) {
            if( !String.isBlank( depositInvoiceItem.Proposal__c ) && !depositInvoiceItem.Is_Created_From_Code__c ) {
                filteredInvoices.add( depositInvoiceItem );
            }
        }
        return filteredInvoices;
    }

    public static void populateCompanyData( List<Deposit_Invoice__c> filteredItems ) {
        Set<Id> proposalIds = new Set<Id>();
        for( Deposit_Invoice__c depositInvoiceItem : filteredItems ) {
            proposalIds.add( depositInvoiceItem.Proposal__c );
        }
        Map<Id, Proposal__c> proposals = new Map<Id, Proposal__c>( [ SELECT Id, Billing_Company_Name__c, Billing_Company_Contact__c,
                                                                            Accounting_Contact_Company__c, Accounting_Contact__c
                                                                     FROM Proposal__c
                                                                     WHERE Id IN : proposalIds ] );
        for( Deposit_Invoice__c depositInvoiceItem : filteredItems ) {
            if( String.isBlank( depositInvoiceItem.Billing_Company_Name__c ) &&
                String.isBlank( depositInvoiceItem.Billing_Company_Contact__c ) &&
                String.isBlank( depositInvoiceItem.Accounting_Contact_Company__c ) &&
                String.isBlank( depositInvoiceItem.Accounting_Contact__c ) ) {
                depositInvoiceItem.Billing_Company_Name__c = proposals.get( depositInvoiceItem.Proposal__c ).Billing_Company_Name__c;
                depositInvoiceItem.Billing_Company_Contact__c = proposals.get( depositInvoiceItem.Proposal__c ).Billing_Company_Contact__c;
                depositInvoiceItem.Accounting_Contact_Company__c = proposals.get( depositInvoiceItem.Proposal__c ).Accounting_Contact_Company__c;
                depositInvoiceItem.Accounting_Contact__c = proposals.get( depositInvoiceItem.Proposal__c ).Accounting_Contact__c;
            }
        }
    }

    public void updateTransactionLineItemsByDeposites(Map<Id, Set<Id>> depositeIdToCashEntryIds) {
        Set<Id> cashIds = new Set<Id>();

        for (Set<Id> cashSet : depositeIdToCashEntryIds.values()) {
            cashIds.addall(cashSet);

        }
        cashIds.remove(null);

        List<c2g__codaCashEntry__c> cashEntries = new List<c2g__codaCashEntry__c>([SELECT Id, c2g__Transaction__c
                                                                                   FROM c2g__codaCashEntry__c
                                                                                   WHERE Id IN: cashIds]);

    }

    public static Map<Id, c2g__codaCashEntryLineItem__c> filteredCashEntryLineItem(List<c2g__codaCashEntryLineItem__c> newList, Map<Id, c2g__codaCashEntryLineItem__c> oldMap) {
        Map<Id, c2g__codaCashEntryLineItem__c> filteredLineItem = new Map<Id, c2g__codaCashEntryLineItem__c>();

        for (c2g__codaCashEntryLineItem__c lineItem : newList) {
            if (lineItem.Deposit_Invoice__c != oldMap.get(lineItem.Id).Deposit_Invoice__c) {
                filteredLineItem.put(lineItem.Id, lineItem);

            }

        }
        return filteredLineItem;

    }

    public static void updateDepositInvoiceOnTransactionLineItem(Map<Id, c2g__codaCashEntryLineItem__c> cashEntryLineItems) {
        List<c2g__codaTransactionLineItem__c> transactioItems = TransactionLineItemServices.getTransactionLineItemsByCashLineItemIds(cashEntryLineItems.keySet());

        for (c2g__codaTransactionLineItem__c lineItem : transactioItems) {
            if (cashEntryLineItems.containsKey(lineItem.Cash_Entry_Line_Item__c)) {
                lineItem.Deposit_Invoice__c = cashEntryLineItems.get(lineItem.Cash_Entry_Line_Item__c).Deposit_Invoice__c;

            }

        }
        update transactioItems;

    }

    public static Decimal getRemainingAmountByProjectId(Id projectId) {
        if (null == projectId) {
            return 0.00;

        }

        AggregateResult[] aggResult = [SELECT SUM(Amount_Remaining__c), Project_Profile__c, Deposit_Invoice_Type__c
                                       FROM Deposit_Invoice__c
                                       WHERE Project_Profile__c =: projectId AND Deposit_Invoice_Type__c =: DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE
                                       GROUP BY Project_Profile__c, Deposit_Invoice_Type__c];

        return aggResult.isEmpty() ? 0.00 : (Decimal)aggResult[0].get('expr0');

    }

    public static List<Deposit_Invoice__c> manageDepositInvoices( Proposal__c proposal, List<ChangeOrderModel> changeOrders ) { //MRS 7298
		Deposit_Invoice__c addReimbInvoice;
		Map<Id,Boolean> coIdToAddReimbInvoiceWasAdded = new Map<Id, Boolean>();
		Boolean addReimbInvWasAdded = false;
        Boolean isChangeOrder = changeOrders != null && !changeOrders.isEmpty();
        String query = '';
        query += 'SELECT Amount_Paid__c, Deposit_Invoice_Type__c, Proposal__c, Change_Order__c, Billing_Company_Name__c, ';
        query +=        'Billing_Company_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c, Deposit_Amount__c, For_Add_Reimbursables__c ';
        query += 'FROM Deposit_Invoice__c ';
        query += 'WHERE Proposal__c = \'' + proposal.Id + '\' ';
        query += 'AND Is_Created_From_Code__c = true ';
        if( !isChangeOrder ) {
            //query += 'AND Change_Order__c = null'; //take proposal deposit invoices also
        } else {
            Set<Id> changeOrderIds = new Set<Id>();
            for( ChangeOrderModel changeOrder : changeOrders ) {
                changeOrderIds.add( changeOrder.changeOrderRecord.Id );
            }
            query += 'AND Change_Order__c IN : changeOrderIds';
        }
        Map<Id, Deposit_Invoice__c> originalInvoices = new Map<Id, Deposit_Invoice__c>( (List<Deposit_Invoice__c>)Database.query( query ) );

        List<Deposit_Invoice__c> serviceRetainers = new List<Deposit_Invoice__c>();
        List<Deposit_Invoice__c> muniFeeRetainers = new List<Deposit_Invoice__c>();
		List<Deposit_Invoice__c> addReimbRetainers = new List<Deposit_Invoice__c>();
        List<Deposit_Invoice__c> invoicesToCreateOrUpdate = new List<Deposit_Invoice__c>();
        for( Deposit_Invoice__c invoice : originalInvoices.values() ) {
            if( invoice.Deposit_Invoice_Type__c == SERVICE_RETAINER_TYPE ) {
                serviceRetainers.add( invoice );
            } else if( invoice.Deposit_Invoice_Type__c == MUNICIPAL_FEE_RETAINER_TYPE ) {
				if(invoice.For_Add_Reimbursables__c) {
					addReimbRetainers.add(invoice);
				} else {
                muniFeeRetainers.add( invoice );
            }
        }
        }
        
        if( !isChangeOrder ) {
            if( serviceRetainers.isEmpty() ) {
                invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, null, null, SERVICE_RETAINER_TYPE ) );
            } else {
                for( Deposit_Invoice__c invoice : serviceRetainers ) {
                    invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, null, invoice, SERVICE_RETAINER_TYPE ) );
                }
            }
            if( muniFeeRetainers.isEmpty() ) {
                if( doCreateMunicipalFeeRetainer( proposal, null ) ) {
                    invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, null, null, MUNICIPAL_FEE_RETAINER_TYPE ) );
                }
            } else {
                for( Deposit_Invoice__c invoice : muniFeeRetainers ) {
                    invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, null, invoice, MUNICIPAL_FEE_RETAINER_TYPE ) );
                }
            }
			addReimbInvoice = prepareAddReimbursablesDepositInvoiceForProposal(proposal);
			if(addReimbInvoice != null) {
				if(addReimbRetainers.isEmpty()) {
					invoicesToCreateOrUpdate.add(addReimbInvoice);
					if(addReimbRetainers.isEmpty()) addReimbInvWasAdded = true;
				} else if(invoicesHaveDifferences(addReimbInvoice, addReimbRetainers[0])) {
					addReimbInvoice.Id = addReimbRetainers[0].Id;
					invoicesToCreateOrUpdate.add(addReimbInvoice);
				}
        } else {
				if(!addReimbRetainers.isEmpty()) {
					DELETE addReimbRetainers[0];
				}
			} 
        } else {
            Map<Id, Deposit_Invoice__c> changeOrderIdToDepositInvoice = new Map<Id, Deposit_Invoice__c>();
            for( Deposit_Invoice__c invoice : muniFeeRetainers ) {
                changeOrderIdToDepositInvoice.put( invoice.Change_Order__c, invoice );
            }
			Map<Id, Deposit_Invoice__c> coIdToExistingAddReimbInvoice = new Map<Id, Deposit_Invoice__c>();
			for( Deposit_Invoice__c invoice : addReimbRetainers ) {
				coIdToExistingAddReimbInvoice.put(invoice.Change_Order__c, invoice);
			}
			Map<Id, Deposit_Invoice__c> coIdToAddReimbInvoiceMap = prepareAddReimbursablesDepositInvoiceForCO(proposal, changeOrders);
			List<Deposit_Invoice__c> addReimbInvoicesToDelete = new List<Deposit_Invoice__c>();
            for( ChangeOrderModel changeOrder : changeOrders ) {
                Deposit_Invoice__c invoice = changeOrderIdToDepositInvoice.get( changeOrder.changeOrderRecord.Id );
                if( invoice == null ) {
                    if( doCreateMunicipalFeeRetainer( proposal, changeOrder ) ) {
                        invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, changeOrder, null, MUNICIPAL_FEE_RETAINER_TYPE ) );
                    }
                } else {
                    invoicesToCreateOrUpdate.add( prepareDepositInvoice( proposal, changeOrder, invoice, MUNICIPAL_FEE_RETAINER_TYPE ) );
                }
				if(coIdToAddReimbInvoiceMap.get(changeOrder.changeOrderRecord.Id) != null) {
					if(coIdToExistingAddReimbInvoice.get(changeOrder.changeOrderRecord.Id) == null) {
						invoicesToCreateOrUpdate.add(coIdToAddReimbInvoiceMap.get(changeOrder.changeOrderRecord.Id));
						coIdToAddReimbInvoiceWasAdded.put(changeOrder.changeOrderRecord.Id, true);
					} else if(invoicesHaveDifferences(coIdToAddReimbInvoiceMap.get(changeOrder.changeOrderRecord.Id), coIdToExistingAddReimbInvoice.get(changeOrder.changeOrderRecord.Id))) {
						coIdToAddReimbInvoiceMap.get(changeOrder.changeOrderRecord.Id).Id = coIdToExistingAddReimbInvoice.get(changeOrder.changeOrderRecord.Id).Id;
						invoicesToCreateOrUpdate.add(coIdToAddReimbInvoiceMap.get(changeOrder.changeOrderRecord.Id));
					}
				} else {
					if(coIdToExistingAddReimbInvoice.get(changeOrder.changeOrderRecord.Id) != null) {
						addReimbInvoicesToDelete.add(coIdToExistingAddReimbInvoice.get(changeOrder.changeOrderRecord.Id));
					}
				}
            }
			if(!addReimbInvoicesToDelete.isEmpty()) {
				DELETE addReimbInvoicesToDelete;
            }
        }

        List<Deposit_Invoice__c> invoicesToCreateDocuments = new List<Deposit_Invoice__c>();
        for( Deposit_Invoice__c invoice : invoicesToCreateOrUpdate ) {
            if(invoice.Id == null || originalInvoices.get( invoice.Id ) == null || invoicesHaveDifferences(invoice, originalInvoices.get(invoice.Id))) {
                invoicesToCreateDocuments.add( invoice );
            }
        }

        UPSERT invoicesToCreateOrUpdate;
		if(addReimbInvWasAdded || !coIdToAddReimbInvoiceWasAdded.isEmpty()) {
			if(!isChangeOrder) {
				PreventTwiceExecution.proposalFirstRun = false;
				UPSERT (new Proposal__c(Id = proposal.Id, Add_Reimbursable_Invoice__c = addReimbInvoice.Id));
			} else {
				List<Change_Order__c> changeOrdersToUpdate = new List<Change_Order__c>();
				System.debug(LoggingLevel.ERROR, 'invoicesToCreateOrUpdate = ' + invoicesToCreateOrUpdate);
				for(Deposit_Invoice__c di : invoicesToCreateOrUpdate) {
					if(coIdToAddReimbInvoiceWasAdded.get(di.Change_Order__c) && di.For_Add_Reimbursables__c) { //MRS 7508
						changeOrdersToUpdate.add(new Change_Order__c(Id = di.Change_Order__c, Add_Reimbursable_Invoice__c = di.Id));
					}
				}
				PreventTwiceExecution.changeOrderFirstRun = false;
				UPSERT changeOrdersToUpdate;
			}
		}
        return invoicesToCreateDocuments;
    }

	public static void createDepositInvoicePdf( List<Deposit_Invoice__c> invoices ) {
        if( invoices != null && !invoices.isEmpty() ) {
            DDPRequest request = new DDPRequest();
            for( Deposit_Invoice__c invoice : invoices ) {
                request.addConfiguration( invoice.Id, RETAINER_INVOICE_DDP, DDPEmailServices.DELIVERY_METHOD_ATTACH );
            }
            request.sendRequest();
        }
    }

    public static Deposit_Invoice__c prepareDepositInvoice( Proposal__c proposal, ChangeOrderModel changeOrder, Deposit_Invoice__c invoice, String invoiceType ) {
        Deposit_Invoice__c newInvoice = new Deposit_Invoice__c( Proposal__c = proposal.Id,
                                                                Change_Order__c = ( changeOrder != null
                                                                                    ? changeOrder.changeOrderRecord.Id
                                                                                    : null ),
                                                                Billing_Company_Name__c = proposal.Billing_Company_Name__c,
                                                                Billing_Company_Contact__c = proposal.Billing_Company_Contact__c,
                                                                Accounting_Contact_Company__c = proposal.Accounting_Contact_Company__c,
                                                                Accounting_Contact__c = proposal.Accounting_Contact__c,
                                                                Amount_Paid__c = 0.00,
                                                                Is_Created_From_Code__c = true );
        if( invoice != null ) {
            newInvoice.Id = invoice.Id;
            newInvoice.Amount_Paid__c = invoice.Amount_Paid__c;
        }
        if( invoiceType == SERVICE_RETAINER_TYPE ) {
            newInvoice.Deposit_Invoice_Type__c = SERVICE_RETAINER_TYPE;
            newInvoice.Deposit_Amount__c = proposal.Discounted_Total_Service_Amount__c * ( !proposal.No_Retainer__c //MRS 7419
                                                                                ? ( proposal.Retainer_Amount__c != null
                                                                                    ? proposal.Retainer_Amount__c / 100
                                                                                    : 0.00 )
                                                                                : 0.00 );
            return newInvoice;
        } else if( invoiceType == MUNICIPAL_FEE_RETAINER_TYPE ) {
            newInvoice.Deposit_Invoice_Type__c = MUNICIPAL_FEE_RETAINER_TYPE;
            newInvoice.Deposit_Amount__c = ( doCreateMunicipalFeeRetainer( proposal, changeOrder )
                                             ? ( changeOrder == null
                                                 ? ( proposal.Projected_DOB_Fee__c != null
                                                     ? proposal.Projected_DOB_Fee__c
                                                     : 0.00 )
                                                 : ( changeOrder.changeOrderRecord.Projected_DOB_Fee__c != null
                                                     ? changeOrder.changeOrderRecord.Projected_DOB_Fee__c
                                                     : 0.00 ) )
                                             : 0.00 );
            return newInvoice;
        }
        return null;
    }
	
	public static Deposit_Invoice__c prepareAddReimbursablesDepositInvoiceForProposal(Proposal__c proposal) { //MRS 7298
		Decimal amount = 0;
		for(Additional_Reimbursable__c ar : [SELECT Amount__c, Send_Muni_Fee_Invoice__c FROM Additional_Reimbursable__c WHERE Proposal__c = :proposal.Id]) {
			if(ar.Send_Muni_Fee_Invoice__c) amount += ar.Amount__c;
		}

		if(amount > 0) {
	        return(new Deposit_Invoice__c(Proposal__c = proposal.Id,
						Change_Order__c = null,
						Billing_Company_Name__c = proposal.Billing_Company_Name__c,
						Billing_Company_Contact__c = proposal.Billing_Company_Contact__c,
						Accounting_Contact_Company__c = proposal.Accounting_Contact_Company__c,
						Accounting_Contact__c = proposal.Accounting_Contact__c,
						Amount_Paid__c = 0.00,
						Is_Created_From_Code__c = true, For_Add_Reimbursables__c = true,
						Deposit_Invoice_Type__c = MUNICIPAL_FEE_RETAINER_TYPE, Deposit_Amount__c = amount));
		}
        return null;
    }

	public static Map<Id, Deposit_Invoice__c> prepareAddReimbursablesDepositInvoiceForCO(Proposal__c proposal, List<ChangeOrderModel> changeOrders) { //MRS 7298
		Map<Id, Deposit_Invoice__c> res = new Map<Id, Deposit_Invoice__c>();
		
		Map<Id, Decimal> amount = new Map<Id, Decimal>();
		for(ChangeOrderModel cO : changeOrders) {
			amount.put(cO.changeOrderRecord.Id, 0);
		}

		for(Additional_Reimbursable__c ar : [SELECT Amount__c, Send_Muni_Fee_Invoice__c, Change_Order__c FROM Additional_Reimbursable__c
												WHERE Proposal__c = :proposal.Id AND Change_Order__c IN :amount.keySet()]) {
			if(ar.Send_Muni_Fee_Invoice__c) amount.put(ar.Change_Order__c, amount.get(ar.Change_Order__c) + ar.Amount__c);
		}

		for(Id idx : amount.keySet()) {
			if(amount.get(idx) > 0) {
				res.put(idx, new Deposit_Invoice__c( Proposal__c = proposal.Id,
														Change_Order__c = idx,
														Billing_Company_Name__c = proposal.Billing_Company_Name__c,
														Billing_Company_Contact__c = proposal.Billing_Company_Contact__c,
														Accounting_Contact_Company__c = proposal.Accounting_Contact_Company__c,
														Accounting_Contact__c = proposal.Accounting_Contact__c,
														Amount_Paid__c = 0.00,
														Is_Created_From_Code__c = true, For_Add_Reimbursables__c = true,
														Deposit_Invoice_Type__c = MUNICIPAL_FEE_RETAINER_TYPE, Deposit_Amount__c = amount.get(idx)));
			}
		}
		return res;
    }

	public static Boolean invoicesHaveDifferences(Deposit_Invoice__c newInvoice, Deposit_Invoice__c oldInvoice) { // MRS 7298
		return newInvoice.Proposal__c != oldInvoice.Proposal__c ||
                  newInvoice.Change_Order__c != oldInvoice.Change_Order__c ||
                  newInvoice.Billing_Company_Name__c != oldInvoice.Billing_Company_Name__c ||
                  newInvoice.Billing_Company_Contact__c != oldInvoice.Billing_Company_Contact__c ||
                  newInvoice.Accounting_Contact_Company__c != oldInvoice.Accounting_Contact_Company__c ||
                  newInvoice.Accounting_Contact__c != oldInvoice.Accounting_Contact__c ||
                  newInvoice.Amount_Paid__c != oldInvoice.Amount_Paid__c ||
                  newInvoice.Deposit_Invoice_Type__c != oldInvoice.Deposit_Invoice_Type__c ||
                  newInvoice.Deposit_Amount__c != oldInvoice.Deposit_Amount__c;
    }

    public static Boolean doCreateMunicipalFeeRetainer( Proposal__c proposal, ChangeOrderModel changeOrder ) {
        if( proposal != null ) {
            if( changeOrder != null ) {
                return !proposal.No_Retainer__c &&
                       changeOrder.changeOrderRecord.Municipal_Authority_Fees__c != null &&
                       changeOrder.changeOrderRecord.Municipal_Authority_Fees__c.contains( ChangeOrderServices.DOB_VARIANCE_FEES_PROJECTED );
            } else {
                return !proposal.No_Retainer__c &&
                       proposal.Municipal_Authority_Fees__c != null &&
                       proposal.Municipal_Authority_Fees__c.contains( ChangeOrderServices.DOB_VARIANCE_FEES_PROJECTED );
            }
        }
        return false;
    }

}