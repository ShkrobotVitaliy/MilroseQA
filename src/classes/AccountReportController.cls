public without sharing class AccountReportController {
    public final static String SOA_REPORT_LINK = '/apex/SOA';

    public Boolean isAllowedProfile { get { if( isAllowedProfile == null ) isAllowedProfile = true; return isAllowedProfile; } set; }
    public Boolean isRunningSeparately { get { if( isRunningSeparately == null ) isRunningSeparately = true; return isRunningSeparately; } set; }
    public Boolean sendStatement { get { if( sendStatement == null ) sendStatement = false; return sendStatement; } set; }

    public Boolean asrrRenderas { get { if( asrrRenderas == null ) asrrRenderas = false; return asrrRenderas; } set; }
    public Boolean asrrDocStyle { get { if( asrrDocStyle == null ) asrrDocStyle = false; return asrrDocStyle; } set; }
    public Boolean asrrLineDetail { get { if( asrrLineDetail == null ) asrrLineDetail = false; return asrrLineDetail; } set; }
    public Boolean soaRenderas { get { if( soaRenderas == null ) soaRenderas = false; return soaRenderas; } set; }
    public Boolean soaCombine { get { if( soaCombine == null ) soaCombine = false; return soaCombine; } set; }
    public Boolean isHomePageLayout { get { if( isHomePageLayout == null ) isHomePageLayout = false; return isHomePageLayout; } set; }//MRS-6487
    public Boolean showProjectProfileBillingCompanyFiltersOnly { get { if( showProjectProfileBillingCompanyFiltersOnly == null ) showProjectProfileBillingCompanyFiltersOnly = false; return showProjectProfileBillingCompanyFiltersOnly; } set; }//MRS-6487

    public List<String> foundAsrrProjectNames { get; set; }
    public Map<String, List<String>> foundAsrrReportsProjectNameToIds { get; set; }

    public List<List<String>> foundSoaReportAccountNamesSplit { get; set; }
    public Map<String, List<String>> foundSoaReportsAccountNameToIds { get; set; }

    public transient Map<Id, String> foundSoaReportsAccountIdToSingleLink;
    public Map<Id, String> getFoundSoaReportsAccountIdToSingleLink () {
        Map<Id, String> result = new Map<Id, String>();
        if( foundSoaReportAccountNamesSplit != null ) {
            for( List<String> namesSplitByThousand : foundSoaReportAccountNamesSplit ) {
                for( String accountName : namesSplitByThousand ) {
                    for( Id accountId : foundSoaReportsAccountNameToIds.get( accountName ) ) {
                        result.put( accountId, getSoaReportSingleLink( accountId ) );
                    }
                }
            }
        }
        return result;
    }

    public String getSoaReportSingleLink( Id accountId ) {
        return SOA_REPORT_LINK + '?p=' + accountId + getLinkEnding();
    }

    public transient String foundSoaReportsGroupLink;
    public String getFoundSoaReportsGroupLink() {
        String result = '';
        if( foundSoaReportAccountNamesSplit != null ) {
            result = SOA_REPORT_LINK + '?p=';
            for( List<String> namesSplitByThousand : foundSoaReportAccountNamesSplit ) {
                for( String accountName : namesSplitByThousand ) {
                    for( Id accountId : foundSoaReportsAccountNameToIds.get( accountName ) ) {
                        result += accountId + ',';
                    }
                }
            }
            result = result.removeEnd( ',' );
            result += getLinkEnding();
        }
        return result;
    }

    public transient String foundSoaReportsGroupNames;
    public String getFoundSoaReportsGroupNames() {
        String result = '';
        if( foundSoaReportAccountNamesSplit != null ) {
            for( List<String> namesSplitByThousand : foundSoaReportAccountNamesSplit ) {
                result += String.join( namesSplitByThousand, ', ' ) + ', ';
            }
            result = result.removeEnd( ', ' );
        }
        return result;
    }

    public String getLinkEnding() {
        return ( soaHelper.Project_Profile__c != null ? '&ppr=' + soaHelper.Project_Profile__c : '' ) +
               ( soaHelper.Accounting_Company__c != null ? '&ac=' + soaHelper.Accounting_Company__c : '' ) +
               ( soaHelper.Accounting_Company_Contact__c != null ? '&acc=' + soaHelper.Accounting_Company_Contact__c : '' ) +
               ( soaHelper.Billing_Company__c != null ? '&bc=' + soaHelper.Billing_Company__c : '' ) +
               ( soaHelper.Billing_Company_Contact__c != null ? '&bcc=' + soaHelper.Billing_Company_Contact__c : '' ) +
               ( soaHelper.A_R_Coordinator__c != null ? '&arc=' + soaHelper.A_R_Coordinator__c : '' ) +
               ( soaHelper.Account_Manager__c != null ? '&am=' + soaHelper.Account_Manager__c : '' ) +
               ( '&noam=' + String.valueOf( noAccountManager ) ) +
               ( soaFulfillmentOffice != null ? '&ffo=' + soaFulfillmentOffice : '' ) +
               ( soaPartner != null ? '&par=' + soaPartner : '' ) +
               ( '&nopar=' + String.valueOf( noPartner ) );
    }

    private Map<Id, String> foundRecordIds = new Map<Id, String>();
    private EmailTemplate emailTemplate;

    public DDP_Helper__c asrHelper { get { if( asrHelper == null ) asrHelper = new DDP_Helper__c(); return asrHelper; } set; }

    public DDP_Helper__c soaHelper { get { if( soaHelper == null ) soaHelper = new DDP_Helper__c(); return soaHelper; } set; }
    public Boolean noAccountManager { get { if( noAccountManager == null ) noAccountManager = false; return noAccountManager; } set; }
    public String soaFulfillmentOffice { get; set; }
    public List<selectOption> fulfillmentOfficeOption { get { return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'Fulfillment_Office__c'), true, true); } set;}
    public String soaPartner { get; set; }
    public Boolean noPartner { get { if( noPartner == null ) noPartner = false; return noPartner; } set; }
    public List<SelectOption> partners { get { if( partners == null ) partners = new List<SelectOption>(); return partners; } set; }
    public Boolean printAmName { get { if( printAmName == null ) printAmName = false; return printAmName; } set; }

    public Account runningAccount { get { if(runningAccount == null) runningAccount = new Account(); return runningAccount; } set; }
    public Contact runningContact { get { if(runningContact == null) runningContact = new Contact(); return runningContact; } set; }

    public Set<Id> partnerIds = new Set<Id>();
    public Set<String> partnerNames = new Set<String>();

    public Id runningRecordId { get; set; }

    private String filterId;
    
    private Id accountingContactAccountId;
    private Id billingContactAccountId;

    public String fileDownloadIframeSrc { get; set; }

    public List<SelectOption> getPartnersOptions() {
        List<SelectOption> partnersOptions = new List<SelectOption>();
        partnersOptions.add( new SelectOption( '', '--None--' ) );
        for( User user : [ SELECT Name
                           FROM User
                           WHERE Profile.Name = : UserServices.PROFILE_PARTNER
                              OR Name IN : ProposalWizardServices.getUserNamesForPartnerDropdown()
                           ORDER BY Name
                           LIMIT 1000 ] ) {
            partnersOptions.add( new SelectOption( user.Id, user.Name ) );
            partnerIds.add( user.Id );
            partnerNames.add( user.Name );
        }
        return partnersOptions;
    }

    public AccountReportController( Id batchAccountingContactId ) {
        soaHelper.Accounting_Company_Contact__c = batchAccountingContactId;
    }

    public AccountReportController() {
        partners = getPartnersOptions();

        sendStatement = !String.isEmpty( ApexPages.currentPage().getParameters().get('send') );
        isHomePageLayout = ApexPages.currentPage().getURL().endsWith('home.jsp');

        
    
    String idParam = ApexPages.currentPage().getParameters().get('a');
        if( !String.isEmpty( idParam ) ) {
            filterId = idParam;
            runningAccount = [ SELECT Id, Name, c2g__CODAFinanceContact__c FROM Account WHERE Id = : idParam ];
            soaHelper.Accounting_Company__c = runningAccount.Id;
            runningRecordId = runningAccount.Id;
            isRunningSeparately = false;
        }
        idParam = ApexPages.currentPage().getParameters().get('c');
        if( !String.isEmpty( idParam ) ) {
            filterId = idParam;
            runningContact = [ SELECT Id, Name, AccountId FROM Contact WHERE Id = : idParam ];
            soaHelper.Accounting_Company_Contact__c = runningContact.Id;
            runningRecordId = runningContact.Id;
            isRunningSeparately = false;
        }

        String profileName = [ SELECT Name FROM Profile WHERE Id = : UserInfo.getProfileId() LIMIT 1 ][0].Name;
        CustomPermissionsAccountReport__c customPermissionsAR = CustomPermissionsAccountReport__c.getValues( UserInfo.getName() );

        if( profileName != UserServices.PROFILE_FINANCE_MANAGER &&
            profileName != UserServices.PROFILE_CFO &&
            profileName != UserServices.PROFILE_COO &&
            profileName != UserServices.EXECUTIVE_ADMIN_PROFILE_NAME &&
            !profileName.contains(UserServices.PROFILE_STAFF_ACCOUNTANT) &&
            !profileName.contains(UserServices.PROFILE_A_R_CORDINATOR) &&
            !profileName.contains(UserServices.PROFILE_ACCOUNT_MANAGER) &&
            !profileName.contains(UserServices.PROFILE_PARTNER) &&
            profileName != UserServices.PROFILE_ACCOUNTING_SUPERVISOR &&
            profileName != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN &&
            profileName != UserServices.PROFILE_DIRECTOR_OF_OPERATIONS && //MRS-6507
            profileName != UserServices.SYSTEM_ADMINISTRATOR ) {

            if ( profileName != UserServices.PROFILE_ACCOUNTING_SUPERVISOR && !isHomePageLayout
                && !( customPermissionsAR != null && (Id.valueOf(customPermissionsAR.Id__c) == UserInfo.getUserId()) ) ){//MRS-6487 MRS-7325
                MilroseDevHelper.addMessage( 'You are not allowed to perform actions on this page.' );
                isAllowedProfile = false;
            }

        }

        if( !String.isEmpty( runningAccount.Id ) && String.isEmpty( runningAccount.c2g__CODAFinanceContact__c ) ) {
            MilroseDevHelper.addMessage( 'Finance Contact should be specified for the current Account.', MilroseDevHelper.INFO );
        }

        if ( isHomePageLayout && (profileName.contains(UserServices.PROFILE_STAFF_ACCOUNTANT) || profileName.contains(UserServices.PROFILE_A_R_CORDINATOR) || profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || profileName.contains(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) ) ){//MRS-6487
            showProjectProfileBillingCompanyFiltersOnly = true;
        }

        if( sendStatement ) {
            try {
                emailTemplate = EmailMessageService.getEmailTemplateByDeveloperName( EmailMessageService.SOA_TEMPLATE_NAME );
            } catch( exception ex ) {
            }
        }
    }

    public PageReference autorun() {
        if( sendStatement ) {
            return generateSoa();
        }
        return null;
    }

    public PageReference goBack() {
        return new PageReference('/' + runningRecordId);
    }

    public PageReference generateAsr() {
        foundAsrrReportsProjectNameToIds = null;
        foundAsrrProjectNames = null;
        return generatePDF( StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT );
    }

    public PageReference generateSoa() {
        foundSoaReportAccountNamesSplit = null;
        foundSoaReportsAccountNameToIds = null;
        return generatePDF( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT );
    }

    private PageReference generatePDF( String reportType ) {
        if( isValid( reportType ) ) {
            try {
                if( reportType == StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT ) {
                    foundRecordIds = findProjects( reportType );
                    if( foundRecordIds.isEmpty() ) {
                        foundAsrrReportsProjectNameToIds = null;
                        foundAsrrProjectNames = null;
                    } else {
                        foundAsrrReportsProjectNameToIds = new Map<String, List<String>>();
                        foundAsrrProjectNames = new List<String>();
                    }
                    Set<String> foundAsrrProjectNamesSet = new Set<String>();
                    for( Id idItem : foundRecordIds.keySet() ) {
                        String foundRecordName = foundRecordIds.get( idItem );
                        if( !foundAsrrReportsProjectNameToIds.containsKey( foundRecordName ) ) {
                            foundAsrrReportsProjectNameToIds.put( foundRecordName, new List<String>() );
                        }
                        foundAsrrReportsProjectNameToIds.get( foundRecordName ).add( idItem );
                        foundAsrrProjectNamesSet.add( foundRecordName );
                    }
                    foundAsrrProjectNames.addAll( foundAsrrProjectNamesSet );
                    foundAsrrProjectNames.sort();
                    return null;
                } else if( reportType == StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT ) {
                    foundRecordIds = findAccounts( reportType, true );
                    if( !sendStatement ) {
                        if( foundRecordIds.isEmpty() ) {
                            foundSoaReportAccountNamesSplit = null;
                            foundSoaReportsAccountNameToIds = null;
                        } else {
                            foundSoaReportAccountNamesSplit = new List<List<String>>();
                            foundSoaReportsAccountNameToIds = new Map<String, List<String>>();
                        }
                        Set<String> foundSoaReportNamesSet = new Set<String>();
                        for( Id idItem : foundRecordIds.keySet() ) {
                            String foundRecordName = foundRecordIds.get( idItem );
                            if( !foundSoaReportsAccountNameToIds.containsKey( foundRecordName ) ) {
                                foundSoaReportsAccountNameToIds.put( foundRecordName, new List<String>() );
                            }
                            foundSoaReportsAccountNameToIds.get( foundRecordName ).add( idItem );
                            foundSoaReportNamesSet.add( foundRecordName );
                        }

                        List<String> foundSoaReportNames = new List<String>( foundSoaReportNamesSet );
                        foundSoaReportNames.sort();
                        List<String> reportNamesSplitByThousand = new List<String>();
                        Integer counter = 0;
                        for( String name : foundSoaReportNames ) {
                            if( counter++ < 1000 ) {
                                reportNamesSplitByThousand.add( name );
                            } else {
                                counter = 0;
                                foundSoaReportAccountNamesSplit.add( reportNamesSplitByThousand );
                                reportNamesSplitByThousand = new List<String>();
                            }
                        }
                        if( !reportNamesSplitByThousand.isEmpty() ) {
                            foundSoaReportAccountNamesSplit.add( reportNamesSplitByThousand );
                        }
                        return null;
                    } else {
                        if( emailTemplate == null ) {
                            MilroseDevHelper.addMessage( 'No email template that is used to send this type of emails was found.' );
                            return null;
                        }
                    }
                }
            } catch( exception ex ) {
                foundAsrrReportsProjectNameToIds = null;
                MilroseDevHelper.addMessage( ex.getMessage() );
                if( !Test.isRunningTest() ) return null;
            }
        } else {
            MilroseDevHelper.addMessage( 'The selection is not valid. Please, make another choice.', MilroseDevHelper.INFO );
            return null;
        }
        return null;
    }

    public PageReference sendEmail() {
        if( !String.isEmpty( runningAccount.Id ) && String.isEmpty( runningAccount.c2g__CODAFinanceContact__c ) ) {
            MilroseDevHelper.addMessage( 'Email was not sent: Finance Contact should be specified for the current Account.', MilroseDevHelper.INFO );
            return null;
        }
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSaveAsActivity( true );
        if( emailTemplate != null ) {
            email.setTemplateId( emailTemplate.Id );
        }
        if( runningContact.Id != null ) {
            email.setTargetObjectId( runningContact.Id );
            email.setWhatId( runningContact.AccountId );
        } else if( runningAccount.Id != null ) {
            email.setTargetObjectId( runningAccount.c2g__CODAFinanceContact__c );
            email.setWhatId( runningAccount.Id );
        }

        //email.setSubject( subject );
        //email.setToAddresses( new String[] { 'to@to.com' } );
        //email.setCcAddresses( new String[] { 'to@to.com' } );
        //email.setReplyTo( 'to@to.com' );
        //email.setSenderDisplayName( 'User' );
        //email.setPlainTextBody( body );

        List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
        for( Id foundRecordId : foundRecordIds.keySet() ) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            PageReference pdfItem = Page.SOA;
            pdfItem.getParameters().put( 'p', (String)foundRecordId );
            pdfItem.getParameters().put( 'a', (String)filterId );
            pdfItem.getParameters().put( 'c', (String)filterId );
            if( !String.isEmpty( soaHelper.Project_Profile__c ) ) pdfItem.getParameters().put( 'ppr', (String)soaHelper.Project_Profile__c );
            if( !String.isEmpty( soaHelper.Accounting_Company__c ) ) pdfItem.getParameters().put( 'ac', (String)soaHelper.Accounting_Company__c );
            if( !String.isEmpty( soaHelper.Accounting_Company_Contact__c ) ) pdfItem.getParameters().put( 'acc', (String)soaHelper.Accounting_Company_Contact__c );
            if( !String.isEmpty( soaHelper.Billing_Company__c ) ) pdfItem.getParameters().put( 'bc', (String)soaHelper.Billing_Company__c );
            if( !String.isEmpty( soaHelper.Billing_Company_Contact__c ) ) pdfItem.getParameters().put( 'bcc', (String)soaHelper.Billing_Company_Contact__c );
            if( !String.isEmpty( soaHelper.A_R_Coordinator__c ) ) pdfItem.getParameters().put( 'arc', (String)soaHelper.A_R_Coordinator__c );
            if( !String.isEmpty( soaHelper.Account_Manager__c ) ) pdfItem.getParameters().put( 'am', (String)soaHelper.Account_Manager__c );
            pdfItem.getParameters().put( 'noam', String.valueOf( noAccountManager ) );
            if( !String.isEmpty( soaFulfillmentOffice ) ) pdfItem.getParameters().put( 'ffo', (String)soaFulfillmentOffice );
            if( !String.isEmpty( soaPartner ) ) pdfItem.getParameters().put( 'par', (String)soaPartner );
            pdfItem.getParameters().put( 'nopar', String.valueOf( noPartner ) );
            pdfItem.getParameters().put( 'printam', String.valueOf( printAmName ) );

            pdfItem.setRedirect( true );
            Blob pdfItemContent = pdfItem.getContent();
            efa.setFileName( StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT + ' - ' + foundRecordIds.get( foundRecordId ) + '.pdf' );
            efa.setBody( pdfItemContent );
            efas.add( efa );
        }
        email.setFileAttachments( efas );

        Boolean isSuccess = true;
        if( !Test.isRunningTest() ) { try { Messaging.SendEmailResult [] r = Messaging.sendEmail( new Messaging.SingleEmailMessage[] { email } ); } catch ( exception e ) { MilroseDevHelper.addMessage( 'An error occurred whils sending the email: ' + e.getMessage() ); isSuccess = false; } }
        if( !isRunningSeparately && isSuccess ) {
            PageReference pr = new PageReference('/' + runningRecordId);
            pr.setRedirect( true );
            return pr;
        }
        return null;
    }

    private Boolean isValid( String reportType ) {
        if( reportType == StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT ) {
            if( !String.isEmpty( asrHelper.Project_Profile__c ) ||
                !String.isEmpty( asrHelper.Billing_Company__c ) ||
                !String.isEmpty( asrHelper.Billing_Company_Contact__c ) ||
                !String.isEmpty( asrHelper.Accounting_Company__c ) ||
                !String.isEmpty( asrHelper.Accounting_Company_Contact__c ) ) {
                return true;
            } else {
                return false;
            }
        } else if( reportType == StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT ) {
            return true;
        }
        return false;
    }

    private String addToQuery( String param, String field, Boolean isFirst ) {
        if( !String.isEmpty( param ) ) {
            String result = field + ' = ' + ( param == MilroseDevHelper.NULL_STRING ? param : '\'' + param + '\'' );
            if( isFirst != null && isFirst == true ) {
                result = ' AND ' + result + ' ';
            } else if( isFirst != null && isFirst == false ) {
                result = ' ' + result + ' AND ';
            }
            return result;
        }
        return '';
    }

    public Map<Id, String> findAccounts( String reportType, Boolean useDebugLog ) {
        String debugLog = 'Project Profile: ' + soaHelper.Project_Profile__c + '\n' +
                          'Billing Company: ' + soaHelper.Billing_Company__c + '\n' +
                          'Billing Company Contact: ' + soaHelper.Billing_Company_Contact__c + '\n' +
                          'Accounting Company: ' + soaHelper.Accounting_Company__c + '\n' +
                          'Accounting Company Contact: ' + soaHelper.Accounting_Company_Contact__c + '\n' +
                          'A/R Coordinator: ' + soaHelper.A_R_Coordinator__c + '\n' +
                          'Account Manager: ' + soaHelper.Account_Manager__c + '\n' +
                          'No Account Manager: ' + String.valueOf( noAccountManager ) + '\n' +
                          'Fulfillment Office: ' + soaFulfillmentOffice + '\n' +
                          'Partner: ' + soaPartner + '\n' +
                          'No Partner: ' + String.valueOf( noPartner ) + '\n' +
                          '\n';
        String query = '';
        Set<Id> accountIds = new Set<Id>();
        Map<Id, String> accountIdToAccountName = new Map<Id, String>();
    
    if( soaHelper.Accounting_Company_Contact__c != null ) accountingContactAccountId = [SELECT Id, AccountId FROM Contact WHERE Id =: soaHelper.Accounting_Company_Contact__c ][0].AccountId;
    if( soaHelper.Billing_Company_Contact__c != null ) billingContactAccountId  = [SELECT Id, AccountId FROM Contact WHERE Id =: soaHelper.Billing_Company_Contact__c ][0].AccountId;
System.debug( LoggingLevel.Error, 'debugLog: ' + debugLog );
System.debug( LoggingLevel.Error, 'accountingContactAccountId: ' + accountingContactAccountId );

        String partnerName = '';
        if( !String.isEmpty( soaPartner ) ) {
            List<User> partners = [ SELECT Name FROM User WHERE Id = : soaPartner ];
            if( !partners.isEmpty() ) {
                partnerName = partners[0].Name;
            }
        }

        String accountManagerName = '';
        if( !String.isEmpty( soaHelper.Account_Manager__c ) ) {
            List<User> accountManagers = [ SELECT FirstName, LastName FROM User WHERE Id = : soaHelper.Account_Manager__c ];
            if( !accountManagers.isEmpty() ) {
                accountManagerName = accountManagers[0].FirstName + ' ' + accountManagers[0].LastName;
            }
        }

        //select related contact names for imported invoices
        Map<Id, Contact> contactIdToContactForInvoices = new Map<Id, Contact>();
        contactIdToContactForInvoices.put( soaHelper.Billing_Company_Contact__c, null );
        contactIdToContactForInvoices.put( soaHelper.Accounting_Company_Contact__c, null );
        contactIdToContactForInvoices.remove( null );
        if( !contactIdToContactForInvoices.keySet().isEmpty() ) {
            contactIdToContactForInvoices = new Map<Id, Contact>( [ SELECT Id, Name
                                                                    FROM Contact
                                                                    WHERE Id IN : contactIdToContactForInvoices.keySet() ] );
        }

        //A - Unapplied Debit Memos (Imported SI to be shown as unapplied transactions)
        if( true ) {
            List<AggregateResult> unappliedInvoiceTransactions = new List<AggregateResult>();
            Set<Id> unappliedInvoiceTransactionIds = new Set<Id>();
            List<c2g__codaInvoice__c> unappliedInvoices = new List<c2g__codaInvoice__c>();
            if( ( String.isEmpty( soaHelper.Project_Profile__c ) &&
                 !String.isEmpty( soaHelper.Billing_Company__c ) &&
                  String.isEmpty( soaHelper.Billing_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.A_R_Coordinator__c ) &&
                  String.isEmpty( soaFulfillmentOffice ) &&
                  /*( String.isEmpty( soaHelper.Account_Manager__c ) && !noAccountManager ) &&*/
                  ( String.isEmpty( soaPartner ) && !noPartner ) ) ||
                ( String.isEmpty( soaHelper.Project_Profile__c ) &&
                 !String.isEmpty( soaHelper.Billing_Company__c ) &&
                  String.isEmpty( soaHelper.Billing_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company_Contact__c ) &&
                 !String.isEmpty( soaHelper.A_R_Coordinator__c ) &&
                  String.isEmpty( soaFulfillmentOffice ) &&
                  /*( String.isEmpty( soaHelper.Account_Manager__c ) && !noAccountManager ) &&*/
                  ( String.isEmpty( soaPartner ) && !noPartner ) ) ||
                ( String.isEmpty( soaHelper.Project_Profile__c ) &&
                  String.isEmpty( soaHelper.Billing_Company__c ) &&
                  String.isEmpty( soaHelper.Billing_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company_Contact__c ) &&
                 !String.isEmpty( soaHelper.A_R_Coordinator__c ) &&
                  String.isEmpty( soaFulfillmentOffice ) &&
                  /*( String.isEmpty( soaHelper.Account_Manager__c ) && !noAccountManager ) &&*/
                  ( String.isEmpty( soaPartner ) && !noPartner ) ) ||
                ( String.isEmpty( soaHelper.Project_Profile__c ) &&
                  String.isEmpty( soaHelper.Billing_Company__c ) &&
                  String.isEmpty( soaHelper.Billing_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.A_R_Coordinator__c ) &&
                  String.isEmpty( soaFulfillmentOffice ) ) &&
                  /*( String.isEmpty( soaHelper.Account_Manager__c ) && !noAccountManager ) &&*/
                  ( String.isEmpty( soaPartner ) && !noPartner ) ) {
                accountIds = accountIdToAccountName.keySet();

                unappliedInvoices = [ SELECT c2g__Transaction__c, Project_Address_Reference__c, Project_Reference__c, Client_Project_Reference__c, Project_Info_Reference__c,
                                             Billing_Contact_Reference__c, Accounting_Contact_Reference__c
                                      FROM c2g__codaInvoice__c
                                      WHERE Billing_Company_Reference__c = null AND
                                            Accounting_Contact_Company_Reference__c = null AND
                                            c2g__Transaction__r.c2g__TransactionType__c = : TransactionServices.INVOICE_TRANSACTION_TYPE AND
                                            c2g__Transaction__r.Project_Name_Mi7__c = null AND
                                            c2g__Transaction__r.Project_Profile__c = null AND
                                            cl_Pro_forma_Invoice__c = null AND
                                            Legacy_Pro_forma_Invoice__c = null AND
                                            c2g__Transaction__c != null
                                      ORDER BY CreatedDate ];
                for( c2g__codaInvoice__c invoice : unappliedInvoices ) {
                    if( String.isEmpty( invoice.Project_Reference__c ) &&
                        String.isEmpty( invoice.Billing_Contact_Reference__c ) &&
                        String.isEmpty( invoice.Accounting_Contact_Reference__c ) &&
                        String.isEmpty( invoice.Project_Address_Reference__c ) &&
                        String.isEmpty( invoice.Client_Project_Reference__c ) &&
                        String.isEmpty( invoice.Project_Info_Reference__c ) ) { //!
                        unappliedInvoiceTransactionIds.add( invoice.c2g__Transaction__c );
                    }
                }
                query  = 'SELECT c2g__Account__c, c2g__Account__r.Name ';
                query += 'FROM c2g__codaTransactionLineItem__c ';
                query += 'WHERE c2g__Transaction__c IN :unappliedInvoiceTransactionIds AND ';
                query +=       'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
                query +=       'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
                query +=       'c2g__HomeOutstandingValue__c != 0 AND ';
                query +=       'c2g__Account__c != null ';
                query += addToQuery( soaHelper.Billing_Company__c, 'c2g__Account__c', true );
                query += addToQuery( soaHelper.A_R_Coordinator__c, 'c2g__Account__r.A_R_Coordinator__c', true );
                /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c', true );
                query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c', true );*/
                query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : soaHelper.Account_Manager__c ), 'c2g__Account__r.Account_Manager__c', true );
                query +=       'AND ';
                query +=       'c2g__Account__c NOT IN :accountIds ';
                query += 'GROUP BY c2g__Account__c, c2g__Account__r.Name';

                System.debug( LoggingLevel.Error, 'xxx Unapplied Invoices Transactions Query: ' + query );
                unappliedInvoiceTransactions = Database.query( query );
                System.debug( LoggingLevel.Error, 'xxx Unapplied Invoices Transactions Found: ' + unappliedInvoiceTransactions.size() );
                for( AggregateResult ar : unappliedInvoiceTransactions ) {
                    accountIdToAccountName.put( (Id)ar.get('c2g__Account__c'), (String)ar.get('Name') );
                    System.debug( LoggingLevel.Error, 'accountIdToAccountName: ' + accountIdToAccountName );
                }
            }
            debugLog += 'UnappliedInvcs: ' + unappliedInvoices.size() + '/' + unappliedInvoiceTransactions.size() + '       | Accounts: ' + String.valueOf( accountIdToAccountName.size() ) + '\n';
            unappliedInvoiceTransactions = null; //clear heap
            unappliedInvoiceTransactionIds = null; //clear heap
            unappliedInvoices = null; //clear heap
        }

        //B - Unapplied transactions
        if( true ) {
            List<AggregateResult> unappliedTransactions = new List<AggregateResult>();
            if( ( String.isEmpty( soaHelper.Project_Profile__c ) &&
                  String.isEmpty( soaHelper.Billing_Company_Contact__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company__c ) &&
                  String.isEmpty( soaHelper.Accounting_Company_Contact__c ) &&
                  String.isEmpty( soaFulfillmentOffice ) &&
                  /*( String.isEmpty( soaHelper.Account_Manager__c ) && !noAccountManager ) &&*/
                  ( String.isEmpty( soaPartner ) && !noPartner ) ) &&
                ( ( !String.isEmpty( soaHelper.Billing_Company__c ) &&  String.isEmpty( soaHelper.A_R_Coordinator__c ) ) ||
                  ( !String.isEmpty( soaHelper.Billing_Company__c ) && !String.isEmpty( soaHelper.A_R_Coordinator__c ) ) ||
                  (  String.isEmpty( soaHelper.Billing_Company__c ) && !String.isEmpty( soaHelper.A_R_Coordinator__c ) ) ||
                  (  String.isEmpty( soaHelper.Billing_Company__c ) &&  String.isEmpty( soaHelper.A_R_Coordinator__c ) ) ) ) {
                accountIds = accountIdToAccountName.keySet();
                query  = 'SELECT c2g__Account__c, c2g__Account__r.Name ';
                query += 'FROM c2g__codaTransactionLineItem__c ';
                query += 'WHERE ( c2g__Transaction__r.c2g__TransactionType__c = \'Cash\' OR ';
                query +=         'c2g__Transaction__r.c2g__TransactionType__c = \'Journal\' OR ';
                query +=         'c2g__Transaction__r.c2g__TransactionType__c = \'Credit Note\' OR ';
                query +=         'c2g__Transaction__r.c2g__TransactionType__c = \'Cash Matching Journal\' ) AND ';
                query +=       'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
                query +=       'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
                query +=       'c2g__HomeOutstandingValue__c != 0 AND ';
                query +=       'c2g__Account__c != null ';
                query += addToQuery( soaHelper.Billing_Company__c, 'c2g__Account__c', true );
                query += addToQuery( soaHelper.A_R_Coordinator__c, 'c2g__Account__r.A_R_Coordinator__c', true );
                /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c', true );
                query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c', true );*/
                query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : soaHelper.Account_Manager__c ), 'c2g__Account__r.Account_Manager__c', true );
                query +=       'AND ';
                query +=       'c2g__Account__c NOT IN :accountIds ';
                query += 'GROUP BY c2g__Account__c, c2g__Account__r.Name';

                System.debug( LoggingLevel.Error, 'xxx Unapplied Transactions Query: ' + query );
                unappliedTransactions = Database.query( query );
                System.debug( LoggingLevel.Error, 'xxx Unapplied Transactions Found: ' + unappliedTransactions.size() );
                for( AggregateResult ar : unappliedTransactions ) {
                    accountIdToAccountName.put( (Id)ar.get('c2g__Account__c'), (String)ar.get('Name') );
                    System.debug( LoggingLevel.Error, 'accountIdToAccountName: ' + accountIdToAccountName );
                }
            }
            debugLog += 'UnappliedDocs: ' + unappliedTransactions.size() + '        | Accounts: ' + String.valueOf( accountIdToAccountName.size() ) + '\n';
            unappliedTransactions = null; //clear heap
        }

        //C, D - Applied transactions / Wave projects + Applied transactions / Mi7 projects - that match filter criteria
        if( true ) {
            List<c2g__codaTransactionLineItem__c> projectsTransactions = new List<c2g__codaTransactionLineItem__c>();
            accountIds = accountIdToAccountName.keySet();
            query = 'SELECT ';
            query += 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c, c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__r.Name, ';
            query += 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c, c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__r.Name, ';
            query += 'c2g__HomeOutstandingValue__c, c2g__Transaction__r.c2g__TransactionDate__c ';
            query += 'FROM c2g__codaTransactionLineItem__c WHERE ';
            query += '( ( ';
            query += 'c2g__Transaction__r.c2g__TransactionType__c = \'' + TransactionServices.INVOICE_TRANSACTION_TYPE + '\' AND '; //TLI filter:
            query += 'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query += 'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query += 'c2g__HomeOutstandingValue__c != 0 ';
            query += ') AND ( ';
            query += '( c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c NOT IN :accountIds ) OR ';
            query += '( c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c != null AND  c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c NOT IN :accountIds ) ';
            query += ') )';

            String addQueryWaveProject = '';
            addQueryWaveProject += addToQuery( soaHelper.Project_Profile__c, 'Project_Profile__c', false );
            addQueryWaveProject += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : soaHelper.Account_Manager__c ),
                                               ( noAccountManager ? 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Account_Executive__c' : 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Account_Executive__c' ),
                                               false );
            addQueryWaveProject += addToQuery( soaHelper.Billing_Company__c, 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c', false );
            addQueryWaveProject += addToQuery( soaHelper.Billing_Company_Contact__c, 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Contact__c', false );
            addQueryWaveProject += addToQuery( soaHelper.Accounting_Company__c, 'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact_Company__c', false );
            addQueryWaveProject += addToQuery( soaHelper.Accounting_Company_Contact__c, 'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact__c', false );
            addQueryWaveProject += addToQuery( soaHelper.A_R_Coordinator__c, 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__r.A_R_Coordinator__c', false );
            addQueryWaveProject += addToQuery( soaFulfillmentOffice, 'Project_Profile__r.Fulfillment_Office__c', false );
            if( noPartner ) {
                addQueryWaveProject += ' ( c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c NOT IN :partnerIds ) AND ';
            } else {
                addQueryWaveProject += addToQuery( soaPartner, 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c', false );
            }
            /*addQueryWaveProject += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : soaPartner ),
                                               ( noPartner ? 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c' : 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c' ),
                                               false );*/

            addQueryWaveProject = addQueryWaveProject.removeEnd( ' AND ' );

            String addQueryLegacyProject = '';
            if( String.isEmpty( soaHelper.Project_Profile__c ) && String.isEmpty( soaFulfillmentOffice ) ) {
                addQueryLegacyProject += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ),
                                                     ( noAccountManager ? 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Sales_Exec_SF__c' : 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Sales_Exec_SF__r.Name' ),
                                                     false );
                addQueryLegacyProject += addToQuery( soaHelper.Billing_Company__c, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c', false );
                addQueryLegacyProject += addToQuery( soaHelper.Billing_Company_Contact__c, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Contact__c', false );
                addQueryLegacyProject += addToQuery( soaHelper.Accounting_Company__c, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact_Company__c', false );
                addQueryLegacyProject += addToQuery( soaHelper.Accounting_Company_Contact__c, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact__c', false );
                addQueryLegacyProject += addToQuery( soaHelper.A_R_Coordinator__c, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__r.A_R_coordinator__c', false );
                if( noPartner ) {
                    addQueryLegacyProject += ' ( c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND ( c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__c = null OR c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name NOT IN :partnerNames ) ) AND ';
                } else {
                    addQueryLegacyProject += addToQuery( partnerName, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name', false );
                }
                /*addQueryLegacyProject += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ),
                                                     ( noPartner ? 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__c' : 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name' ),
                                                     false );*/

                addQueryLegacyProject = addQueryLegacyProject.removeEnd( ' AND ' );
            }

            String addQueryBothProjects = String.isEmpty(addQueryWaveProject)
                                          ? ( String.isEmpty(addQueryLegacyProject)
                                              ? ''
                                              : addQueryLegacyProject )
                                          : ( String.isEmpty(addQueryLegacyProject)
                                              ? addQueryWaveProject
                                              : '( ' + addQueryWaveProject + ' ) OR ( ' + addQueryLegacyProject + ' )' );

            if( !String.isEmpty(addQueryBothProjects) ) addQueryBothProjects = ' AND ( ' + addQueryBothProjects + ' )';

            query += addQueryBothProjects;
            query += ' ORDER BY c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__r.Name ASC NULLS LAST, c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__r.Name ASC NULLS LAST';

            System.debug( LoggingLevel.Error, 'xxx Wave/Mi7 Query: ' + query );
            projectsTransactions = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Wave/Mi7 Found: ' + projectsTransactions.size() );
            for( c2g__codaTransactionLineItem__c tli : projectsTransactions ) {
                if( !String.isEmpty( tli.c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c ) &&
                    tli.c2g__HomeOutstandingValue__c != null &&
                    tli.c2g__Transaction__r.c2g__TransactionDate__c != null ) {
                    accountIdToAccountName.put( tli.c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c, tli.c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__r.Name );
                } else if( !String.isEmpty( tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c ) &&
                    tli.c2g__HomeOutstandingValue__c != null &&
                    tli.c2g__Transaction__r.c2g__TransactionDate__c != null ) {
                    accountIdToAccountName.put( tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c, tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__r.Name );
                }
            }
            debugLog += 'ProjectsOrMi7: ' + projectsTransactions.size() + '                   | Accounts: ' + String.valueOf( accountIdToAccountName.size() ) + '\n';
            projectsTransactions = null; //clear heap
            System.debug( LoggingLevel.Error, 'accountIdToAccountName: ' + accountIdToAccountName );
        }

        //E - Imported invoices with applied TLIs (Imported SI) - that match filter criteria
        if( true ) {
            List<c2g__codaInvoice__c> importedInvoices = new List<c2g__codaInvoice__c>();
            List<c2g__codaTransactionLineItem__c> invoiceTransactions = new List<c2g__codaTransactionLineItem__c>();
            Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice = new Map<Id, c2g__codaInvoice__c>();
            if( String.isEmpty( soaHelper.Project_Profile__c ) && String.isEmpty( soaFulfillmentOffice ) ) {
                accountIds = accountIdToAccountName.keySet();
        System.debug( LoggingLevel.Error, 'accountIds: ' + accountIds );
                query  = 'SELECT ';
                query += 'c2g__Transaction__c, Billing_Company_Reference__c, Billing_Company_Reference__r.Name, ';
                query += 'c2g__Transaction__r.c2g__TransactionDate__c, Project_Reference__c ';
                query += 'FROM c2g__codaInvoice__c WHERE ';

                if( !String.isEmpty( soaHelper.Billing_Company__c ) ) query += 'Billing_Company_Reference__c = \'' + soaHelper.Billing_Company__c + '\' AND ';
                if( !String.isEmpty( soaHelper.Billing_Company_Contact__c ) ) query += 'Billing_Contact_Reference__c = \'' + String.escapeSingleQuotes( contactIdToContactForInvoices.get(soaHelper.Billing_Company_Contact__c).Name ) + '\' AND ';
                if( !String.isEmpty( soaHelper.Accounting_Company__c ) ) query += 'Accounting_Contact_Company_Reference__c = \'' + soaHelper.Accounting_Company__c + '\' AND ';
                if( !String.isEmpty( soaHelper.Accounting_Company_Contact__c ) ) query += 'Accounting_Contact_Reference__c = \'' + String.escapeSingleQuotes( contactIdToContactForInvoices.get(soaHelper.Accounting_Company_Contact__c).Name ) + '\' AND ';
                if( !String.isEmpty( soaHelper.A_R_Coordinator__c ) ) query += 'Billing_Company_Reference__r.A_R_Coordinator__c = \'' + soaHelper.A_R_Coordinator__c + '\' AND ';

                query += 'c2g__Transaction__r.c2g__TransactionType__c = \'' + TransactionServices.INVOICE_TRANSACTION_TYPE + '\' AND '; //TLI filter:
                query += 'c2g__Transaction__r.Project_Name_Mi7__c = null AND ';
                query += 'c2g__Transaction__r.Project_Profile__c = null AND ';
                query += 'Billing_Company_Reference__c != null AND ';
                accountIds = accountIdToAccountName.keySet(); query += 'Billing_Company_Reference__c NOT IN :accountIds';
        System.debug( LoggingLevel.Error, 'accountIds: ' + accountIds );
                System.debug( LoggingLevel.Error, 'xxx Imported Invoices Query: ' + query );
                importedInvoices = Database.query( query );
        System.debug( LoggingLevel.Error, 'importedInvoices: ' + importedInvoices );
                System.debug( LoggingLevel.Error, 'xxx Imported Invoices Found: ' + importedInvoices.size() );
                for( c2g__codaInvoice__c invoice : importedInvoices ) {
                    if( !String.isEmpty( invoice.Project_Reference__c ) && invoice.c2g__Transaction__r.c2g__TransactionDate__c != null ) {
                        transactionIdToSalesInvoice.put( invoice.c2g__Transaction__c, invoice );
                    }
                }
                Set<Id> transactionIds = transactionIdToSalesInvoice.keySet();
                query  = 'SELECT c2g__Transaction__c, c2g__HomeOutstandingValue__c ';
                query +=   'FROM c2g__codaTransactionLineItem__c ';
                query +=  'WHERE c2g__Transaction__c IN :transactionIds AND ';
                query +=        'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
                query +=        'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
                query +=        'c2g__HomeOutstandingValue__c != 0 ';
                if( noPartner ) {
                    query += ' AND ( c2g__Transaction__r.Partner_Reference__c = null OR c2g__Transaction__r.Partner_Reference__c NOT IN :partnerNames ) ';
                } else {
                    query += addToQuery( partnerName, 'c2g__Transaction__r.Partner_Reference__c', true );
                }
                /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c', true );*/
                query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c', true );
                /*query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : soaHelper.Account_Manager__c ), 'c2g__Account__r.Account_Manager__c', true );*/

                query = query.removeEnd( ' AND ' );

                System.debug( LoggingLevel.Error, 'xxx Imported Invoices Transactions Query: ' + query );
                invoiceTransactions = Database.query( query );
                System.debug( LoggingLevel.Error, 'xxx Imported Invoices Transactions Found: ' + invoiceTransactions.size() );
                transactionIds = null; //clear heap

                for( c2g__codaTransactionLineItem__c tli : invoiceTransactions ) {
                    if( tli.c2g__HomeOutstandingValue__c != null ) {
                        c2g__codaInvoice__c invoiceItem = transactionIdToSalesInvoice.get( tli.c2g__Transaction__c );
                        if( accountingContactAccountId != null ){
                if( accountingContactAccountId == invoiceItem.Billing_Company_Reference__c ) accountIdToAccountName.put( invoiceItem.Billing_Company_Reference__c, invoiceItem.Billing_Company_Reference__r.Name );
            }else if( billingContactAccountId != null ){
                if( billingContactAccountId == invoiceItem.Billing_Company_Reference__c ) accountIdToAccountName.put( invoiceItem.Billing_Company_Reference__c, invoiceItem.Billing_Company_Reference__r.Name );
            }else{
                accountIdToAccountName.put( invoiceItem.Billing_Company_Reference__c, invoiceItem.Billing_Company_Reference__r.Name );
                        }
            }
                }
                System.debug( LoggingLevel.Error, 'accountIdToAccountName: ' + accountIdToAccountName );
            }
            debugLog += 'ImportedInvcs: ' + importedInvoices.size() + '/' + invoiceTransactions.size() + ' | Accounts: ' + String.valueOf( accountIdToAccountName.size() ) + '\n';
            importedInvoices = null; //clear heap
            invoiceTransactions = null; //clear heap
            transactionIdToSalesInvoice = null; //clear heap
        }

        if( accountIdToAccountName.keySet().isEmpty() ) {
            throw new ErrorException( 'No results were found for ' + reportType + '.' );
        }

        if( useDebugLog == true ) {
            ErrorException.addLog( debugLog, 'Account Report' );
        }

        return accountIdToAccountName;
    }

    public Map<Id, String> findProjects( String reportType ) {
        String query = '';
        Map<Id, String> foundProjectIds = new Map<Id, String>();
        Set<Id> foundProFormaInvoiceIds = new Set<Id>();
        if( reportType == StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT ) {
            //find projects that match the filter criteria and have unpaid or partially paid PFIs
            query  = 'SELECT Project_Profile__c, Project_Profile__r.Name, (Select Id From Billing_Line_Items__r Where Hide_from_Recap__c = false Limit 1) ';//MRS-6549
            query += 'FROM Pro_Forma_Invoice__c ';
            query += 'WHERE ( Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_UNPAID + '\' OR ';
            query +=         'Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_PART_PAID + '\' OR ';
            query +=         'Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_PAID + '\' ) AND ';
            if( !String.isEmpty( asrHelper.Project_Profile__c ) ) {
                query += 'Project_Profile__c = \'' + asrHelper.Project_Profile__c + '\' AND ';
            }
            if( !String.isEmpty( asrHelper.Billing_Company__c ) ) {
                query += 'Billing_Client_Company__c = \'' + asrHelper.Billing_Company__c + '\' AND ';
            }
            if( !String.isEmpty( asrHelper.Billing_Company_Contact__c ) ) {
                query += 'Billing_Contact__c = \'' + asrHelper.Billing_Company_Contact__c + '\' AND ';
            }
            if( !String.isEmpty( asrHelper.Accounting_Company__c ) ) {
                query += 'Accounting_Contact_Company__c = \'' + asrHelper.Accounting_Company__c + '\' AND ';
            }
            if( !String.isEmpty( asrHelper.Accounting_Company_Contact__c ) ) {
                query += 'Accounting_Contact__c = \'' + asrHelper.Accounting_Company_Contact__c + '\' AND ';
            }
            query = query.removeEnd(' AND ');

            for( Pro_Forma_Invoice__c pfi : Database.query( query ) ) {
                if ( !pfi.Billing_Line_Items__r.isEmpty() ){//MRS-6549
                    foundProjectIds.put( pfi.Project_Profile__c, pfi.Project_Profile__r.Name );
                }
            }

            /*query = 'SELECT Id, Name, (SELECT Id FROM Pro_Forma_Invoices__r WHERE Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_UNPAID + '\' OR Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_PART_PAID + '\' OR Sales_Invoice__r.c2g__PaymentStatus__c = \'' + SalesInvoiceServices.PAYMENT_STATUS_PAID + '\') FROM Project_Profile__c WHERE ';
            if( !String.isEmpty( asrHelper.Project_Profile__c ) ) query += 'Id = \'' + asrHelper.Project_Profile__c + '\' AND ';
            if( !String.isEmpty( asrHelper.Billing_Company__c ) ) query += 'Billing_Company_Name__c = \'' + asrHelper.Billing_Company__c + '\' AND ';
            if( !String.isEmpty( asrHelper.Billing_Company_Contact__c ) ) query += 'Billing_Company_Contact__c = \'' + asrHelper.Billing_Company_Contact__c + '\' AND ';
            if( !String.isEmpty( asrHelper.Accounting_Company__c ) ) query += 'Accounting_Contact_Company__c = \'' + asrHelper.Accounting_Company__c + '\' AND ';
            if( !String.isEmpty( asrHelper.Accounting_Company_Contact__c ) ) query += 'Accounting_Contact__c = \'' + asrHelper.Accounting_Company_Contact__c + '\'';
            query = query.removeEnd(' AND ');
            query = query.removeEnd(' WHERE ');
            List<Project_Profile__c> filteredProjects = Database.query( query );
            for( Project_Profile__c proj : filteredProjects ) {
                if( !proj.Pro_Forma_Invoices__r.isEmpty() ) {
                    foundProjectIds.put( proj.Id, proj.Name );
                }
            }*/
            if( foundProjectIds.keySet().isEmpty() ) {
                throw new ErrorException( 'No results were found for ' + reportType + '.' );
            }
        }
        return foundProjectIds;
    }

}