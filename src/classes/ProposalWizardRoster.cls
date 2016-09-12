public with sharing class ProposalWizardRoster {
    public List<ProposalWizardRosterWrapper> rosters { get { if( rosters == null ) rosters = new List<ProposalWizardRosterWrapper>(); return rosters; } set; }
    public Project_Roster__c rosterToAdd { get { if( rosterToAdd == null ) rosterToAdd = new Project_Roster__c(); return rosterToAdd; } set; }
    private Set<Id> rosterIdsToDelete = new Set<Id>();

    public ProposalWizardRoster( Proposal__c proposal, ProposalWizardModel pwm ) {
        initProposalWizardRoster( proposal, pwm );
    }

    public Map<Decimal, List<LStore__Stored_Document__c>> getTotalSizeOfProposalAttachments( Id proposalId ) { //G300
        Decimal totalFileSize = 0;
        Map<Decimal, List<LStore__Stored_Document__c>> totalFileSizeToFiles = new Map<Decimal, List<LStore__Stored_Document__c>>();
        List<LStore__Stored_Document__c> files = [ SELECT Id, Name, LStore__File_Size__c
                                                   FROM LStore__Stored_Document__c
                                                   WHERE Proposal__c = : proposalId ];
        for( LStore__Stored_Document__c file : files ) {
            totalFileSize += file.LStore__File_Size__c;
        }
        totalFileSizeToFiles.put( totalFileSize, files );
        return totalFileSizeToFiles;
    }

    public void initProposalWizardRoster( Proposal__c proposal, ProposalWizardModel pwm ) {
        removeInvalidContactLookups( proposal );
        initRosters( proposal, false );
        replaceRoster( proposal, pwm, ProjectRosterServices.PARTNER );
        replaceRoster( proposal, pwm, ProjectRosterServices.SALESPERSON );
        replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNT_MANAGER );
        replaceRoster( proposal, pwm, ProjectRosterServices.PROPOSAL_CREATOR_ROLE );
        primaryCompanyAction( proposal, pwm, true );
        pwm.updateIsUserInRoster( isUserInRoster() );
    }

    public void initRosters( Proposal__c proposal, Boolean doSort ) {
        rosters = new List<ProposalWizardRosterWrapper>();
        Map<String, Project_Roster__c> roleToRoster = new Map<String, Project_Roster__c>();
        //MRS-6868
//        Map<Id, Boolean> rosterIdToEnableStatusMap = new Map<Id, Boolean>();
//        if( !String.isBlank( proposal.Project_Profile__c ) ) {
//            rosterIdToEnableStatusMap = ProjectProfileServices.getProjectRosterStatus( proposal.Project_Profile__c );
//        }
        List<Project_Roster__c> rostersFromDb = new List<Project_Roster__c>();
        if( !String.isEmpty( proposal.Id ) ) {
           rostersFromDb.addAll( ProjectRosterServices.getProjectRosterById( proposal.Id ) );
        }
        for( Project_Roster__c roster : rostersFromDb ) {
            if( String.isBlank( roster.Contact__c ) && String.isBlank( roster.User__c ) ) {
                rosterIdsToDelete.add( roster.Id ); //throw out empty rosters
            } else if( /*!rosterIdToEnableStatusMap.containsKey( roster.Id ) ||*/ String.isBlank( proposal.Project_Profile__c ) || roster.Active__c ) { //
                rosters.add( new ProposalWizardRosterWrapper( roster ) );
            }
        }
        if( doSort ) rosters.sort();
    }

    public Boolean isUserInRoster() {
        Id currentUserId = UserInfo.getUserId();
        for( ProposalWizardRosterWrapper pwrw : getUserRosters() ) {
            if( pwrw.isActive && pwrw.record.User__c == currentUserId ) {
                return true;
            }
        }
        return false;
    }

    private void removeInvalidContactLookups( Proposal__c proposal ) {
        Set<String> accountIds = new Set<String>();
        accountIds.add( proposal.Primary_Company_Name__c );
        accountIds.add( proposal.Billing_Company_Name__c );
        accountIds.add( proposal.Accounting_Contact_Company__c );
        Map<String, Map<String, String>> accountIdToContactIdToContactName = ProposalWizardServices.getAccountIdToContactIdToContactName( accountIds );
        if( !accountIdToContactIdToContactName.get( proposal.Primary_Company_Name__c ).containsKey( proposal.Primary_Company_Contact__c ) ) {
            proposal.Primary_Company_Contact__c = null;
        }
        if( !accountIdToContactIdToContactName.get( proposal.Billing_Company_Name__c ).containsKey( proposal.Billing_Company_Contact__c ) ) {
            proposal.Billing_Company_Contact__c = null;
        }
        if( !accountIdToContactIdToContactName.get( proposal.Accounting_Contact_Company__c ).containsKey( proposal.Accounting_Contact__c ) ) {
            proposal.Accounting_Contact__c = null;
        }
    }

    public transient List<ProposalWizardRosterWrapper> contactRosters;
    public List<ProposalWizardRosterWrapper> getContactRosters() {
        List<ProposalWizardRosterWrapper> contactRostersOutput = new List<ProposalWizardRosterWrapper>();
        for( ProposalWizardRosterWrapper roster : rosters ) {
            if( !String.isBlank( roster.record.Contact__c ) ) {
                contactRostersOutput.add( roster );
            }
        }
        return contactRostersOutput;
    }

    public List<ProposalWizardRosterWrapper> getUserRosters() {
        List<ProposalWizardRosterWrapper> userRostersOutput = new List<ProposalWizardRosterWrapper>();
        for( ProposalWizardRosterWrapper roster : rosters ) {
            if( !String.isBlank( roster.record.User__c ) ) {
                userRostersOutput.add( roster );
            }
        }
        return userRostersOutput;
    }

    // Step 1 contact rosters actions START
    public void changeContactRosterRoleAction() {
        String rosterId = ApexPages.currentPage().getParameters().get('rosterId');
        String rosterRole = ApexPages.currentPage().getParameters().get('rosterRole');
        if( !String.isBlank( rosterId ) ) {
            for( ProposalWizardRosterWrapper roster : rosters ) {
                if( roster.record.Id == rosterId ) {
                    roster.record.Role__c = rosterRole;
                    break;
                }
            }
        }
    }

    public void deleteContactFromRosterAction() {
        String rosterId = ApexPages.currentPage().getParameters().get('rosterId');
        Integer rosterIndexToDelete;
        if( !String.isBlank( rosterId ) ) {
            for( Integer iterator = 0; iterator < rosters.size(); iterator++ ) {
                if( !String.isBlank( rosters[iterator].record.Id ) && rosters[iterator].record.Id == rosterId ) {
                    rosterIndexToDelete = iterator;
                    break;
                }
            }
        }
        if( rosterIndexToDelete != null ) {
            try {
                DELETE new Project_Roster__c( Id = rosterId );
                rosters.remove( rosterIndexToDelete );
            } catch( DmlException e ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Error deleting roster.' ) );
            }
        }
    }

    public void addContactToRosterAction( Proposal__c proposal ) {
        if( rosterToAdd != null && rosterToAdd.Contact_Filter__c != null ) {
            Id contactId = rosterToAdd.Contact_Filter__c;
            rosterToAdd.Contact_Filter__c = null;
            rosterToAdd.Contact__c = contactId;
            rosterToAdd.Is_Manually_Added_Roster__c = true;
            Contact contactRoster = ProjectRosterServices.getContactById( rosterToAdd.Contact__c );
            rosters.add( new ProposalWizardRosterWrapper( rosterToAdd, contactRoster ) );
        }
        rosters.sort();
        rosterToAdd = null;
        //saveProjectRoster( proposal );
    }
    // Step 1 contact rosters actions END

    //Adding-removing-replacing rosters START
    public void replaceRoster( Proposal__c proposal, ProposalWizardModel pwm, String role ) {
        replaceRoster( proposal, pwm, role, false, false, false );
    }

    public void replaceRoster( Proposal__c proposal, ProposalWizardModel pwm, String role, Boolean onlyRemove, Boolean doSort, Boolean doUpdateIsUserInRoster ) {
        Id proposalField = ProjectRosterServices.getRoleToUserField( proposal ).get( role );
        Boolean isUser = ProjectRosterServices.getRoleToIsUser().get( role ) == true;
        for( Integer iterator = 0; iterator < rosters.size(); iterator++ ) {
            ProposalWizardRosterWrapper roster = rosters[iterator];
            Id userOrContactId = isUser ? roster.record.User__c : roster.record.Contact__c;
            Id rosterId = roster.record.Id;
            if( !String.isBlank( userOrContactId ) && roster.record.Role__c == role && roster.record.is_Read__c ) {
                if( userOrContactId != proposalField ) {
                    if( String.isBlank( proposal.Project_Profile__c ) ) {
                        removeUserOrContactFromRoster( proposalField, rosterId, iterator );
                        if( !onlyRemove ) {
                            addUserOrContactToRoster( proposal, role, rosterId, iterator );
                        }
                    }
                }
                return;
            }
        }
        if( !onlyRemove ) {
            addUserOrContactToRoster( proposal, role, null, null );
        }
        if( isUser && doUpdateIsUserInRoster ) {
            pwm.updateIsUserInRoster( isUserInRoster() );
        }
        if( doSort ) {
            rosters.sort();
        }
    }

    private void removeUserOrContactFromRoster( Id proposalField, Id rosterId, Integer iterator ) {
        if( String.isBlank( proposalField ) ) {
            if( !String.isBlank( rosterId ) ) {
                rosterIdsToDelete.add( rosterId );
            }
            rosters.remove( iterator );
        }
    }

    private void addUserOrContactToRoster( Proposal__c proposal, String role, Id rosterId, Integer iterator ) {
        Id proposalField = ProjectRosterServices.getRoleToUserField( proposal ).get( role );
        if( !String.isBlank( proposalField ) ) {
            Project_Roster__c newRoster = new Project_Roster__c( Id = rosterId,
                                                                 Initially_Added_Roster__c = true,
                                                                 Key__c = null );
            ProposalWizardRosterWrapper newRosterWrapper;
            Boolean isUser = ProjectRosterServices.getRoleToIsUser().get( role ) == true;
            if( isUser ) {
                User userForRoster = UserServices.getUserById( proposalField );
                newRoster.User__c = userForRoster.Id;
                newRosterWrapper = new ProposalWizardRosterWrapper( newRoster, userForRoster, role, !ProposalWizardServices.isMi3( proposal ) );
            } else {
                Contact contactForRoster = ProjectRosterServices.getContactById( proposalField );
                newRoster.Contact__c = contactForRoster.Id;
                newRosterWrapper = new ProposalWizardRosterWrapper( newRoster, contactForRoster, role, !ProposalWizardServices.isMi3( proposal ) );
            }

            if( !String.isBlank( newRosterWrapper.record.Contact__c ) || !String.isBlank( newRosterWrapper.record.User__c ) ) {
                if( iterator != null ) {
                    newRosterWrapper.record.To__c = rosters[iterator].record.To__c;
                    newRosterWrapper.record.Cc__c = rosters[iterator].record.Cc__c;
                    newRosterWrapper.record.Send_Reminder__c = rosters[iterator].record.Send_Reminder__c;
                    rosters[iterator] = newRosterWrapper;
                } else {
                    rosters.add( newRosterWrapper );
                }
            } else {
                if( iterator != null ) {
                    rosters.remove(iterator);
                }
            }
        }
    }

    public Boolean saveProjectRoster( Proposal__c proposal, ProposalWizardModel pwm ) {
        List<Project_Roster__c> rostersToUpsert = new List<Project_Roster__c>();
        Project_Roster__c pr;
        if( !String.isBlank( proposal.Id ) ) {
            for( ProposalWizardRosterWrapper roster : rosters ) {
                pr = roster.record;
                pr.Proposal__c = proposal.Id;
                pr.Project_Profile__c = proposal.Project_Profile__c;
                rostersToUpsert.add( pr );
            }
            System.Savepoint sp_saveProjectRoster = Database.setSavepoint();
            if( rosterIdsToDelete.size() > 0 ) {
                List<Project_Roster__c> rostersToDelete = new List<Project_Roster__c>();
                for( Id rosterId : rosterIdsToDelete ) {
                    rostersToDelete.add( new Project_Roster__c( Id = rosterId ) );
                }
                try {
                    Database.delete( rostersToDelete, false );
                    rosterIdsToDelete = new Set<Id>();
                } catch( Exception e ) {
                    Database.rollback( sp_saveProjectRoster );
                    throw new ErrorException( 'Error deleting Roster.' );
                    return false;
                }
            }
            try {
                UPSERT rostersToUpsert;
                initRosters( proposal, true );
                pwm.updateIsUserInRoster( isUserInRoster() );
            } catch( Exception e ) {
                Database.rollback( sp_saveProjectRoster );
                throw new ErrorException( 'Error saving Roster.' );
                return false;
            }
        }
        return true;
    }
    //Adding-removing-replacing rosters END

    //Primary-Billing-Accounting START
    public void primaryCompanyAction( Proposal__c proposal, ProposalWizardModel pwm, Boolean doSort ) {
        if( String.isBlank( proposal.Primary_Company_Name__c ) ) {
            proposal.Primary_Company_Contact__c = null;
            replaceRoster( proposal, pwm, ProjectRosterServices.PRIMARY_CLIENT_CONTACT, true, false, false );
        } else {
            replaceRoster( proposal, pwm, ProjectRosterServices.PRIMARY_CLIENT_CONTACT, false, false, false );
        }
        if( proposal.Primary_Client_is_Billing_Client__c ) {
            if( proposal.Billing_Company_Name__c != proposal.Primary_Company_Name__c ) {
                proposal.Billing_Company_Name__c = proposal.Primary_Company_Name__c;
                billingCompanyAction( proposal, pwm, true, false );
                return;
            }
        }
        billingCompanyAction( proposal, pwm, false, false );
        if( doSort ) rosters.sort();
    }

    public void billingCompanyAndContactAction( Proposal__c proposal, ProposalWizardModel pwm, Boolean isBillingCompanyChanged, Boolean doSort ) {
        Account billingAccount = ProposalWizardServices.getBillingAccountForFields( proposal );
        billingCompanyAction( proposal, pwm, billingAccount, isBillingCompanyChanged, false );

        if( billingAccount.Mail_All_Invoices_To_Contact__c != proposal.Billing_Company_Contact__c ) {
            if( !String.isEmpty( billingAccount.Mail_All_Invoices_To_Contact__c ) ) {
                proposal.Send_Invoices_to_Different_Contact__c = true;
                proposal.Accounting_Contact_Company__c = billingAccount.Mail_All_Invoices_To_Account__c != null ? billingAccount.Mail_All_Invoices_To_Account__c : proposal.Billing_Company_Name__c;
                proposal.Accounting_Contact__c = billingAccount.Mail_All_Invoices_To_Contact__c;
            } 
            //else { // MRS 7103
            //    proposal.Send_Invoices_to_Different_Contact__c = false;
            //    proposal.Accounting_Contact_Company__c = proposal.Billing_Company_Name__c;
            //    proposal.Accounting_Contact__c = proposal.Billing_Company_Contact__c;
            //}
        }
        accountingCompanyAction( proposal, pwm, false );
        if( doSort ) rosters.sort();
    }

    public void accountingContactAction( Proposal__c proposal, ProposalWizardModel pwm ) {
        replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT, false, true, false );
        uncheckSendInvoicesToDifferentContactIfApplies( proposal );
    }

    public void uncheckSendInvoicesToDifferentContactIfApplies( Proposal__c proposal ) {
        if( proposal.Accounting_Contact_Company__c == proposal.Billing_Company_Name__c &&
            proposal.Accounting_Contact__c == proposal.Billing_Company_Contact__c ) {
            proposal.Send_Invoices_to_Different_Contact__c = false;
        }
    }

    public void billingCompanyAction( Proposal__c proposal, ProposalWizardModel pwm, Boolean isBillingCompanyChanged, Boolean doSort ) {
        billingCompanyAction( proposal, pwm, new Account(), isBillingCompanyChanged, doSort );
    }

    public void billingCompanyAction( Proposal__c proposal, ProposalWizardModel pwm, Account billingAccount, Boolean isBillingCompanyChanged, Boolean doSort ) {
        if( String.isBlank( proposal.Billing_Company_Name__c ) ) {
            proposal.Billing_Company_Contact__c = null;
            replaceRoster( proposal, pwm, ProjectRosterServices.BILLING_CLIENT_CONTACT, true, false, false );
        } else {
            replaceRoster( proposal, pwm, ProjectRosterServices.BILLING_CLIENT_CONTACT, false, false, false );
        }
        if( !proposal.Send_Invoices_to_Different_Contact__c ) {
            proposal.Accounting_Contact_Company__c = proposal.Billing_Company_Name__c;
            proposal.Accounting_Contact__c = proposal.Billing_Company_Contact__c;
        }
        accountingCompanyAction( proposal, pwm, false );

        if( isBillingCompanyChanged ) {
            if( String.isBlank( billingAccount.Id ) ) {
                billingAccount = ProposalWizardServices.getBillingAccountForFields( proposal );
            }
            setProposalFieldsForBillingClient( proposal, pwm, billingAccount );
        }
        if( doSort ) rosters.sort();
    }

    public void accountingCompanyAction( Proposal__c proposal, ProposalWizardModel pwm, Boolean doSort ) {
        if( String.isBlank( proposal.Accounting_Contact_Company__c ) ) {
            proposal.Accounting_Contact__c = null;
            replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT, true, false, false );
        } else {
            replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT, false, false, false );
        }
        uncheckSendInvoicesToDifferentContactIfApplies( proposal );
        if( doSort ) rosters.sort();
    }

    public void primaryCompanyIsBillingCompanyAction( Proposal__c proposal, ProposalWizardModel pwm ) {
        if( proposal.Primary_Client_is_Billing_Client__c ) {
            proposal.Billing_Company_Name__c = proposal.Primary_Company_Name__c;
            proposal.Billing_Company_Contact__c = proposal.Primary_Company_Contact__c;
        } else {
            proposal.Billing_Company_Name__c = null;
            proposal.Billing_Company_Contact__c = null;
        }
        billingCompanyAndContactAction( proposal, pwm, true, false );
        rosters.sort();
    }

    public void sendInvoicesToDifferentContactAction( Proposal__c proposal, ProposalWizardModel pwm ) {
        if( proposal.Send_Invoices_to_Different_Contact__c ) {
            proposal.Accounting_Contact_Company__c = null;
        } else {
            proposal.Accounting_Contact_Company__c = proposal.Billing_Company_Name__c;
            proposal.Accounting_Contact__c = proposal.Billing_Company_Contact__c;
        }
        accountingCompanyAction( proposal, pwm, false );
        rosters.sort();
    }

    public void setProposalFieldsForBillingClient( Proposal__c proposal, ProposalWizardModel pwm, Account billingAccount ) {
        if( !String.isBlank( proposal.Billing_Company_Name__c ) && !String.isEmpty( billingAccount.Id ) ) {
            proposal.Send_Copy_To__c = billingAccount.Send_Copy_To__c;
            proposal.Delivery_Method__c = billingAccount.Delivery_Method__c != null
                                          ? billingAccount.Delivery_Method__c
                                          : ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Delivery_Method__c' );
            proposal.Separate_Reimbursables__c = billingAccount.Separate_Reimbursables__c;
   			if(proposal.Status__c != ProposalServices.PROPOSAL_STATUS_AWARDED) { // MRS 7367
            proposal.Billing_Method__c = billingAccount.Billing_Method__c != null
                                         ? billingAccount.Billing_Method__c
                                         : ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Billing_Method__c' );
            proposal.Frequency__c = billingAccount.Frequency__c;
            proposal.Billing_day__c = billingAccount.Billing_day__c;
				proposal.Interval__c = billingAccount.Interval__c;
            proposal.Quarterly_Month__c = billingAccount.Quarterly_Month__c;
			}

            proposal.Special_Instructions_Long__c = billingAccount.Special_Instructions_Long__c;
            proposal.No_Document_Shredding__c = billingAccount.No_Document_Shredding__c;
            proposal.Invoice_Format__c = billingAccount.Invoice_Format__c != null
                                         ? billingAccount.Invoice_Format__c
                                         : ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Invoice_Format__c' );
            proposal.No_Met_Data_Scanning__c = billingAccount.No_Met_Data_Scanning__c;
            proposal.No_Messenger_Fedex__c = billingAccount.No_Messenger_Fedex__c;
            proposal.No_Retainer__c = billingAccount.No_Retainer__c;
            proposal.Retainer_Amount__c = billingAccount.Retainer__c == null
                                          ? 0
                                          : billingAccount.Retainer__c;
            proposal.Reimbursable_Items_Basis__c = !billingAccount.No_Reimbursables__c;
            proposal.Reimbursable_Percentage__c = billingAccount.Reimbursables__c;
            if( !proposal.Is_Change_Order__c ) { /*MRS-5978*/
                proposal.Account_Executive__c = billingAccount.Account_Manager__c;
                replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNT_MANAGER, false, false, true );
            }
            //proposal.Salesperson__c = billingAccount.Salesperson__c; /*MRS-5977*/
            proposal.PO_Required__c = billingAccount.PO_Required__c;
			proposal.PO_Not_Required__c = billingAccount.PO_Not_Required__c; //MRS 7191
            if( proposal.Status__c != ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT && !ProposalWizardServices.hasPendingChangeOrders( pwm ) ) {
                proposal.UseDocusign__c = billingAccount.UseDocusign__c;
            }
        } else {
			if(proposal.Status__c != ProposalServices.PROPOSAL_STATUS_AWARDED) { // MRS 7367
            proposal.Billing_Method__c = ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Billing_Method__c' );
				proposal.Frequency__c = null;
            	proposal.Billing_day__c = null;
				proposal.Quarterly_Month__c = null;	
			}
            proposal.Delivery_Method__c = ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Delivery_Method__c' ) ;
            proposal.Invoice_Format__c = ProposalWizardServices.getDefaultPicklistValue( Proposal__c.sObjectType, 'Invoice_Format__c' );
            proposal.UseDocusign__c = ProposalWizardServices.getDefaultBooleanValue( Proposal__c.sObjectType, 'UseDocusign__c' );
        }
    }
    //Primary-Billing-Accounting END

    //Additional supplementary methods START
    public Boolean isRosterValid() {
        Boolean isValid = true;
        for( ProposalWizardRosterWrapper roster : getContactRosters() ) {
            if( roster.record.Role__c == null || roster.record.Role__c == '' ) {
                isValid = false;
            }
        }
        return isValid;
    }

    public Id addAdditionalToAndCc( Proposal__c proposal ) {
        return addAdditionalToAndCc( proposal, null, null );
    }

    public Id addAdditionalToAndCc( Proposal__c proposal, Map<String, String> emailToNameForCc, Map<String, String> emailToNameForApprover ) {
        Id emailToContactId;
        String emailToContactEmail = '';
        Map<String, String> toEmailAddresses = new Map<String, String>();
        Map<String, String> ccEmailAddresses = new Map<String, String>();
        Map<String, String> approverEmailAddresses = new Map<String, String>();
        List<String> toEmailAddressesList = new List<String>();
        List<String> ccEmailAddressesList = new List<String>();
        for( ProposalWizardRosterWrapper roster : rosters ) {
            String emailAddress = roster.email != null ? roster.email.trim() : '';
            if( !String.isEmpty( emailAddress ) && roster.isActive ) {
                if( roster.record.To__c && roster.contact != null && !String.isEmpty( roster.contact.Id ) && String.isEmpty( emailToContactId ) ) { //first contact with 'to' checked
                    emailToContactId = roster.contact.Id;
                    emailToContactEmail = emailAddress;
                    approverEmailAddresses.remove( emailAddress );
                    ccEmailAddresses.remove( emailAddress );
                } else if( roster.record.Approver__c && roster.contact != null && !String.isEmpty( roster.contact.Id ) && emailToContactEmail != emailAddress && !toEmailAddresses.containsKey( emailAddress ) && approverEmailAddresses.isEmpty() ) {
                    approverEmailAddresses.put( emailAddress, roster.contactName );
                    ccEmailAddresses.remove( emailAddress );
                } else if( roster.record.To__c && emailToContactEmail != emailAddress && !toEmailAddresses.containsKey( emailAddress ) ) {
                    toEmailAddresses.put( emailAddress, roster.contactName );
                    approverEmailAddresses.remove( emailAddress );
                } else if( roster.record.Cc__c && !ccEmailAddresses.containsKey( emailAddress ) && !approverEmailAddresses.containsKey( emailAddress ) && !toEmailAddresses.containsKey( emailAddress ) ) {
                    ccEmailAddresses.put( emailAddress, roster.contactName );
                }
            }
        }

        toEmailAddressesList.addAll( toEmailAddresses.keySet() );
        ccEmailAddressesList.addAll( ccEmailAddresses.keySet() );
        proposal.Additional_To__c = String.join( toEmailAddressesList, ', ' );
        proposal.Additional_Cc__c = String.join( ccEmailAddressesList, ', ' );

        if( emailToNameForApprover != null ) {
            emailToNameForApprover.clear();
            emailToNameForApprover.putAll( approverEmailAddresses );
        }

        if( emailToNameForCc != null ) {
            emailToNameForCc.clear();
            emailToNameForCc.putAll( ccEmailAddresses );
            emailToNameForCc.putAll( toEmailAddresses );
            emailToNameForCc.remove( emailToContactEmail );
        }

        return emailToContactId;
    }

    public Boolean isAdditionalToAndCcValid() {
        Integer numberOfContactApprovers = 0;
        Integer numberOfContactSigners = 0;
        for( ProposalWizardRosterWrapper roster : rosters ) {
            String emailAddress = roster.email != null ? roster.email.trim() : '';
            if( ( roster.record.To__c || roster.record.Approver__c ) && ( roster.contact == null || String.isEmpty( roster.contact.Id ) || String.isEmpty( emailAddress ) || !roster.isActive ) ) {
                return false;
            }
            if( !String.isEmpty( emailAddress ) && roster.contact != null && !String.isEmpty( roster.contact.Id ) && roster.isActive ) {
                if( roster.record.To__c ) {
                    numberOfContactSigners++;
                }
                if( roster.record.Approver__c ) {
                    numberOfContactApprovers++;
                }
            }
        }
        if( numberOfContactSigners == 1 && numberOfContactApprovers <= 1 ) {
            return true;
        }
        if( numberOfContactSigners == 0 && numberOfContactApprovers == 0 ) {
            return true;
        }
        return false;
    }
    //Additional supplementary methods END

    //Work with Roster email junctions START
    // G300 MRS-6807 return chaged to List<Roster_Email_Junction__c>
    public List<Roster_Email_Junction__c> createRosterEmailJunctions( ProposalWizardModel pwm, Proposal__c proposal, Id changeCoStatusCoId, Boolean createTimedFollowups, Boolean createAutomaticFollowups ) {
        if( !String.isBlank( proposal.Id ) ) {
            Map<DateTime, Roster_Email_Junction__c> dateToRosterEmailJunction = new Map<DateTime, Roster_Email_Junction__c>();
            Map<DateTime, List<Roster_Email_Junction_Data__c>> rosterEmailJunctionData = new Map<DateTime, List<Roster_Email_Junction_Data__c>>();

            Roster_Email_Junction__c rosterEmailJunctionFollowup = initRosterEmailJunction( pwm, proposal, changeCoStatusCoId, null, true );
            List<Roster_Email_Junction_Data__c> rosterEmailJunctionDataFollowup = new List<Roster_Email_Junction_Data__c>();

            try {
                saveProjectRoster( proposal, pwm );

                for( ProposalWizardRosterWrapper roster : rosters ) {
                    if( roster.record.To__c || roster.record.Cc__c ) {
                        if( createTimedFollowups && roster.record.Send_Reminder__c != null ) {
                            if( !dateToRosterEmailJunction.containsKey( roster.record.Send_Reminder__c ) ) {
                                dateToRosterEmailJunction.put( roster.record.Send_Reminder__c, initRosterEmailJunction( pwm, proposal, changeCoStatusCoId, roster, false ) );
                                rosterEmailJunctionData.put( roster.record.Send_Reminder__c, new List<Roster_Email_Junction_Data__c>() );
                            }
                            rosterEmailJunctionData.get( roster.record.Send_Reminder__c ).add( initRosterEmailJunctionData( roster ) );
                        }
                        if( createAutomaticFollowups && roster.record.Role__c != ProjectRosterServices.PARTNER ) { /* MRS-6114 */
                            rosterEmailJunctionDataFollowup.add( initRosterEmailJunctionData( roster ) );
                        }
                    }
                    roster.record.Send_Reminder__c = null;
                }

                List<Roster_Email_Junction__c> junctionsToInsert = new List<Roster_Email_Junction__c>();
                junctionsToInsert.addAll( dateToRosterEmailJunction.values() );
                if( !rosterEmailJunctionDataFollowup.isEmpty() ) {
                    junctionsToInsert.add( rosterEmailJunctionFollowup );
                }

                DELETE getRosterEmailJunctionsForDeletion( proposal, changeCoStatusCoId, createTimedFollowups, createAutomaticFollowups );

                INSERT junctionsToInsert;
                //if( !ProposalWizardServices.doUseDocusign( proposal, changeCoStatusCoId, pwm ) ) {
                    List<Roster_Email_Junction_Data__c> junctionsDataToInsert = new List<Roster_Email_Junction_Data__c>();
                    for( Datetime junctionDate : rosterEmailJunctionData.keySet() ) {
                        for( Roster_Email_Junction_Data__c junction : rosterEmailJunctionData.get( junctionDate ) ) {
                            junction.Roster_Email_Junction__c = dateToRosterEmailJunction.get( junctionDate ).Id;
                            junctionsDataToInsert.add( junction );
                        }
                    }
                    for( Roster_Email_Junction_Data__c junction : rosterEmailJunctionDataFollowup ) {
                        junction.Roster_Email_Junction__c = rosterEmailJunctionFollowup.Id;
                        junctionsDataToInsert.add( junction );
                    }
                    INSERT junctionsDataToInsert;
                //}
                return junctionsToInsert;
            } catch( Exception e ) {
                throw new ErrorException( 'Error saving Roster Email Junctions: ' + String.valueOf(e) );
            }
        }
        return null;
    }

    public List<Roster_Email_Junction__c> getRosterEmailJunctionsForDeletion( Proposal__c proposal, Id changeCoStatusCoId, Boolean deleteTimedFollowups, Boolean deleteAutomaticFollowups ) {
        /* MRS-5559 delete existing junctions */
        List<Roster_Email_Junction__c> rosterEmailJunctionsForDeletion = new List<Roster_Email_Junction__c>();
        if( !String.isBlank( proposal.Id ) ) {
            String query = 'SELECT Id FROM Roster_Email_Junction__c WHERE';
            if( String.isBlank( changeCoStatusCoId ) ) {
                query += ' Proposal__c = \'' + String.valueOf( proposal.Id ) + '\'';
            } else {
                query += ' Change_Order__c = \'' + String.valueOf( changeCoStatusCoId ) + '\'';
            }
            if( deleteAutomaticFollowups && !deleteTimedFollowups ) {
                query += ' AND Is_Automatic_Follow_Up__c = true';
            }
            if( deleteTimedFollowups && !deleteAutomaticFollowups ) {
                query += ' AND Is_Automatic_Follow_Up__c = false';
            }
            rosterEmailJunctionsForDeletion = Database.query( query );
        }
        return rosterEmailJunctionsForDeletion;
    }

    public Roster_Email_Junction__c initRosterEmailJunction( ProposalWizardModel pwm, Proposal__c proposal, Id changeCoStatusCoId, ProposalWizardRosterWrapper rosterWrapper, Boolean isAutomaticFollowUp ) {
        Roster_Email_Junction__c junction = new Roster_Email_Junction__c();
        junction.Sender__c = UserInfo.getUserId();
        junction.Proposal__c = proposal.Id;
        junction.Change_Order__c = changeCoStatusCoId;
        if( !String.isBlank( changeCoStatusCoId ) && pwm.changeOrderModelMap.get( changeCoStatusCoId ) != null ) {
            junction.Document_Type__c = pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Document_Type__c;
        }
        if( isAutomaticFollowUp ) {
            junction.Reminder_Date_Time__c = BusinessHours.add( DateUtils.MILROSE_BUSINESS_HOURS_ID, Datetime.now(), 3 * DateUtils.ONE_DAY );
            junction.Is_Automatic_Follow_Up__c = true;
        } else {
            junction.Reminder_Date_Time__c = rosterWrapper.record.Send_Reminder__c;
            junction.Is_Automatic_Follow_Up__c = false;
        }
        return junction;
    }

    public Roster_Email_Junction_Data__c initRosterEmailJunctionData( ProposalWizardRosterWrapper rosterWrapper ) {
        Roster_Email_Junction_Data__c junction = new Roster_Email_Junction_Data__c();
        junction.Project_Roster__c = rosterWrapper.record.Id;
        junction.is_TO__c = rosterWrapper.record.To__c;
        junction.is_CC__c = rosterWrapper.record.Cc__c;
        return junction;
    }
    //Work with Roster email junctions END

}