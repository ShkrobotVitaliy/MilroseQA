public without sharing class SOAController {
    private final static String WAVE_PROJECT = '1';
    private final static String OLD_PROJECT = '2';
    private final static String IMPORTED_INV = '3';

    public Boolean isValid { get; private set; }
    public List<SOAWrapper> reports { get { if( reports == null ) reports = new List<SOAWrapper>(); return reports; } private set; }

    private Map<Id, Account> accountIdToAccount = new Map<Id, Account>();

    public String fileName {
        get {
            if( accountIdToAccount.size() > 1 ) {
                return 'Combined Report';
            } else if( accountIdToAccount.keySet().size() == 1 ) {
                return MilroseDevHelper.getSafeFileName( accountIdToAccount.values()[0].Name );
            } else {
                return '';
            }
        }
    }

    public String partNumber { get { if( partNumber == null ) { partNumber = ''; } else { return ' - Part ' + partNumber; } return partNumber; } set; }

    Contact accountingContact;
    Contact billingContact;

    private String filterAccountId;
    private String filterContactId;

    private String ppr;
    private String ac;
    private String acc;
    private String bc;
    private String bcc;
    private String arc;
    private String ffo;
    private String am;
    private Boolean noAccountManager;
    private String par;
    private Boolean noPartner;
    private Boolean printAmName;
    private Boolean excludeUnnapliedDocuments;

    private String arCoorName;
    private String arCoorPhone;
    private String arCoorEmail;

    public String renderAs { get; private set; }
    public Boolean doNotDownload = false;

    public Set<Id> partnerIds = new Set<Id>();
    public Set<String> partnerNames = new Set<String>();

    public String milroseLogoIdExternalUrl { get { return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + milroseLogoId + '&oid=' + UserInfo.getOrganizationId(); } }
    public String milroseLogoId {
        get {
            if( milroseLogoId == null ) {
                List<Document> docs = [ SELECT Id FROM Document WHERE DeveloperName = : MilroseDevHelper.MILROSE_LOGO_DOCUMENT_DEVELOPER_NAME ];
                if( !docs.isEmpty() ) {
                    milroseLogoId = docs[0].Id;
                } else {
                    milroseLogoId = '';
                }
            }
            return milroseLogoId;
        }
        set;
    }

    //Wave Projects Data
    private Map<Id, List<Id>> accountIdToProjectIdsWave = new Map<Id, List<Id>>();
    private Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>> accountIdToProjectIdToTlisWave = new Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>>();
    private Map<Id, Map<Id, c2g__codaInvoice__c>> accountIdToTransactionIdToSalesInvoiceWave = new Map<Id, Map<Id, c2g__codaInvoice__c>>();

    //Mi7 Projects Data
    private Map<Id, List<Id>> accountIdToProjectIdsMi7 = new Map<Id, List<Id>>();
    private Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>> accountIdToProjectIdToTlisMi7 = new Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>>();
    private Map<Id, Map<Id, c2g__codaInvoice__c>> accountIdToTransactionIdToSalesInvoiceMi7 = new Map<Id, Map<Id, c2g__codaInvoice__c>>();

    //Imported SI Data
    private Map<Id, Map<String, List<c2g__codaInvoice__c>>> accountIdToCompositeKeyToSalesInvoices = new Map<Id, Map<String, List<c2g__codaInvoice__c>>>();
    private Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>> accountIdToSalesInvoiceIdToTlis = new Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>>();

    //Unapplied Transactions
    private Map<Id, List<c2g__codaTransactionLineItem__c>> accountIdToUnappliedTlis = new Map<Id, List<c2g__codaTransactionLineItem__c>>();

    //Unapplied Debit Memos
    private Map<Id, List<c2g__codaTransactionLineItem__c>> accountIdToUnappliedDebitMemoTlis = new Map<Id, List<c2g__codaTransactionLineItem__c>>();

    public SOAController() {
        this.isValid = true;
        this.partNumber = ApexPages.currentPage().getParameters().get('part');
        this.filterAccountId = ApexPages.currentPage().getParameters().get('a');
        this.filterContactId = ApexPages.currentPage().getParameters().get('c');
        this.ppr = ApexPages.currentPage().getParameters().get('ppr');
        this.ac  = ApexPages.currentPage().getParameters().get('ac');
        this.acc = ApexPages.currentPage().getParameters().get('acc');
        this.bc  = ApexPages.currentPage().getParameters().get('bc');
        this.bcc = ApexPages.currentPage().getParameters().get('bcc');
        this.arc = ApexPages.currentPage().getParameters().get('arc');
        this.ffo = ApexPages.currentPage().getParameters().get('ffo');
        this.am = ApexPages.currentPage().getParameters().get('am');
        this.noAccountManager = ApexPages.currentPage().getParameters().get('noam') == 'true' ? true : false;
        this.par = ApexPages.currentPage().getParameters().get('par');
        this.noPartner = ApexPages.currentPage().getParameters().get('nopar') == 'true' ? true : false;
        this.printAmName = ApexPages.currentPage().getParameters().get('printam') == 'true' ? true : false;
        this.renderAs = !( String.isEmpty( ApexPages.currentPage().getParameters().get('renderAs') ) ) ? ( ApexPages.currentPage().getParameters().get('renderAs') == 'pdf' ? 'pdf' : '' ) : 'pdf';
        if( this.renderAs == 'pdf' ) {
            this.doNotDownload = ApexPages.currentPage().getParameters().get('dl') == 'false' ? true : false;
        }
        this.excludeUnnapliedDocuments = ApexPages.currentPage().getParameters().get('excldoc') == 'true' ? true : false;

        //MRS-7449
        if ( ApexPages.currentPage().getParameters().get('runsForTaskAttachment') == 'true' ){
            List<DDP_Helper__c> ddpHelperList = [SELECT Id, Automatically_Email_Statements__c, Exclude_Unapplied_Documents__c, Email_Statements_Job_Ex_DateTime__c
                                                 FROM DDP_Helper__c
                                                 WHERE Type__c = : DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1];
            if (!ddpHelperList.isEmpty()){
                this.excludeUnnapliedDocuments = ddpHelperList[0].Exclude_Unapplied_Documents__c;
            }
        }

        for( User user : [ SELECT Name
                           FROM User
                           WHERE Profile.Name = : UserServices.PROFILE_PARTNER
                              OR Name IN : ProposalWizardServices.getUserNamesForPartnerDropdown()
                           ORDER BY Name
                           LIMIT 1000 ] ) {
            partnerIds.add( user.Id );
            partnerNames.add( user.Name );
        }

        if( !String.isEmpty( this.filterAccountId ) ) {
            if( !( this.filterAccountId instanceOf Id ) || String.valueOf( Id.valueOf( this.filterAccountId ).getsObjectType() ) != 'Account' ) {
                this.filterAccountId = null;
            } else {
                getArCoorFromAccount();
            }
        }

        if( !String.isEmpty( filterContactId ) ) {
            if ( !( this.filterContactId instanceOf Id ) || String.valueOf( Id.valueOf( this.filterContactId ).getsObjectType() ) != 'Contact' ) {
                this.filterContactId = null;
            } else {
                getArCoorFromContact();
            }
        }

        String accountIdsJoined = ApexPages.currentPage().getParameters().get('p');
        Set<Id> accountIds = new Set<Id>();
        for( String accountId : accountIdsJoined.split( ',' ) ) {
            if( accountId instanceof Id && String.valueOf( Id.valueOf( accountId ).getsObjectType() ) == 'Account' ) {
                accountIds.add( accountId );
            }
        }

        getAccounts( accountIds );

        if( this.accountIdToAccount.keySet().isEmpty() ) {
            MilroseDevHelper.addMessage('No requested Account(s) found or invalid data was passed.');
            this.isValid = false;
            return;
        }

        if( !String.isEmpty( acc ) ) {
            List<Contact> accountingContacts = [ SELECT Name FROM Contact WHERE Id = : acc ];
            if( !accountingContacts.isEmpty() ) {
                accountingContact = accountingContacts[0];
            }
        }
        if( !String.isEmpty( bcc ) ) {
            List<Contact> billingContacts = [ SELECT Name FROM Contact WHERE Id = : bcc ];
            if( !billingContacts.isEmpty() ) {
                billingContact = billingContacts[0];
            }
        }

        prepareData( accountIdToAccount.keySet() );

        Map<String, List<Id>> accountNameToAccountIds = new Map<String, List<Id>>();
        for( Account accountItem : accountIdToAccount.values() ) {
            if( !accountNameToAccountIds.containsKey( accountItem.Name ) ) {
                accountNameToAccountIds.put( accountItem.Name, new List<Id>() );
            }
            accountNameToAccountIds.get( accountItem.Name ).add( accountItem.Id );
        }
        List<String> accountNames = new List<String>( accountNameToAccountIds.keySet() );
        accountNames.sort();
        for( String accountName : accountNames ) {
            for( Id accountId : accountNameToAccountIds.get( accountName ) ) {
                this.reports.add( new SOAWrapper( this.accountIdToAccount.get( accountId ),
                                                  this.ppr, this.ac, this.acc, this.bc, this.bcc, this.arc, this.ffo, this.am, this.par, this.noAccountManager, this.noPartner, this.printAmName,
                                                  this.filterAccountId, this.filterContactId,
                                                  this.accountingContact, this.billingContact,
                                                  this.arCoorName, this.arCoorPhone, this.arCoorEmail,
                                                  this.accountIdToProjectIdsWave.get( accountId ),
                                                  this.accountIdToProjectIdToTlisWave.get( accountId ),
                                                  this.accountIdToTransactionIdToSalesInvoiceWave.get( accountId ),
                                                  this.accountIdToProjectIdsMi7.get( accountId ),
                                                  this.accountIdToProjectIdToTlisMi7.get( accountId ),
                                                  this.accountIdToTransactionIdToSalesInvoiceMi7.get( accountId ),
                                                  this.accountIdToCompositeKeyToSalesInvoices.get( accountId ),
                                                  this.accountIdToSalesInvoiceIdToTlis.get( accountId ),
                                                  this.accountIdToUnappliedTlis.get( accountId ),
                                                  this.accountIdToUnappliedDebitMemoTlis.get( accountId ),
                                                  this.excludeUnnapliedDocuments ) );
            }
        }
        if( !this.reports.isEmpty() ) {
            this.reports[0].isFirst = true;
            this.reports[ this.reports.size() - 1 ].isLast = true;
        }

        if( renderAs == 'pdf' ) {
            if( !this.doNotDownload ) {
                Apexpages.currentPage().getHeaders().put( 'Content-Type', 'application/pdf; charset=UTF-8;' );
                Apexpages.currentPage().getHeaders().put( 'Content-Disposition', 'attachment; filename="Statement Of Accounts - ' + fileName + partNumber + '.pdf"' );
            }
        } else {
            Apexpages.currentPage().getHeaders().put( 'Content-Type', 'application/vnd.ms-excel; charset=UTF-8;' );
            Apexpages.currentPage().getHeaders().put( 'Content-Disposition', 'attachment; filename="Statement Of Accounts - ' + fileName + partNumber + '.xls"' );
        }
    }

    private void getAccounts( Set<Id> accountIds ) {
        if( accountIds != null && !accountIds.isEmpty() ) {
            this.accountIdToAccount = new Map<Id, Account> ( [ SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                                           c2g__CODAFinanceContact__c, c2g__CODAFinanceContact__r.Account.Name,
                                                           c2g__CODAFinanceContact__r.MailingStreet,
                                                           c2g__CODAFinanceContact__r.MailingCity, c2g__CODAFinanceContact__r.MailingState,
                                                           c2g__CODAFinanceContact__r.MailingPostalCode, c2g__CODAFinanceContact__r.Name,
                                                           A_R_Coordinator_Full_Name__c, A_R_Coordinator_Phone__c, A_R_Coordinator_Email__c
                                                    FROM Account
                                                    WHERE Id IN : accountIds
                                                    ORDER BY Name ] );
        }
    }

    private void getArCoorFromContact() {
        List<Contact> contacts = [ SELECT Id, Account.A_R_Coordinator_Phone__c, Account.A_R_Coordinator_Full_Name__c, Account.A_R_Coordinator_Email__c
                                   FROM Contact
                                   WHERE Id = : this.filterContactId ];
        if( !contacts.isEmpty() ) {
            this.arCoorName = contacts[0].Account.A_R_Coordinator_Full_Name__c;
            this.arCoorPhone = contacts[0].Account.A_R_Coordinator_Phone__c;
            this.arCoorEmail = contacts[0].Account.A_R_Coordinator_Email__c;
        }
    }

    private void getArCoorFromAccount() {
        List<Account> accounts = [ SELECT Id, A_R_Coordinator_Phone__c, A_R_Coordinator_Full_Name__c, A_R_Coordinator_Email__c
                                   FROM Account
                                   WHERE Id = : this.filterAccountId ];
        if( !accounts.isEmpty() ) {
            this.arCoorName = accounts[0].A_R_Coordinator_Full_Name__c;
            this.arCoorPhone = accounts[0].A_R_Coordinator_Phone__c;
            this.arCoorEmail = accounts[0].A_R_Coordinator_Email__c;
        }
    }

    private void prepareData( Set<Id> accountIds ) {
        String query;

        String partnerName = '';
        if( !String.isEmpty( this.par ) ) {
            List<User> partners = [ SELECT Name FROM User WHERE Id = : this.par ];
            if( !partners.isEmpty() ) {
                partnerName = partners[0].Name;
            }
        }

        String accountManagerName = '';
        if( !String.isEmpty( this.am ) ) {
            List<User> accountManagers = [ SELECT FirstName, LastName FROM User WHERE Id = : this.am ];
            if( !accountManagers.isEmpty() ) {
                accountManagerName = accountManagers[0].FirstName + ' ' + accountManagers[0].LastName;
            }
        }


        List<c2g__codaTransactionLineItem__c> queryResult;
        //C - Applied transactions / Wave projects
        if( true ) {
            Map<Id, Id> transactionIdToAccountId = new Map<Id, Id>();
            query  =  'SELECT c2g__Transaction__c, Project_Profile__c, ';
            query +=         'Project_Profile__r.Address_Building_AKA__c, ';
            query +=         'Project_Profile__r.Name, ';
            query +=         'Project_Profile__r.Client_Project__c, ';
            query +=         'Project_Profile__r.Project_Name__c, ';
            query +=         'Project_Profile__r.Billing_Company_Contact__r.Name, ';
            query +=         'Project_Profile__r.Account_Executive__c, Project_Profile__r.Account_Executive__r.FirstName, Project_Profile__r.Account_Executive__r.LastName, ';
            query +=         'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c, ';
            query +=         'c2g__Transaction__r.Pro_forma_Invoice__r.Name_without_Prefix__c, ';
            query +=         'c2g__Transaction__r.Pro_forma_Invoice__r.Invoice_Date__c, ';
            query +=         'c2g__HomeValue__c, c2g__HomeOutstandingValue__c, ';
            query +=         'Project_Profile__r.Floor_s__c, ';
            query +=         'c2g__Transaction__r.PO_Reference__c ';
            query +=  'FROM c2g__codaTransactionLineItem__c ';
            query +=  'WHERE c2g__Transaction__r.c2g__TransactionType__c = \'' + TransactionServices.INVOICE_TRANSACTION_TYPE + '\' AND ';
            query +=        'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query +=        'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query +=        'c2g__HomeOutstandingValue__c != 0 AND ';
            query +=        'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c IN :accountIds ';

            query += addToQuery( ppr, 'Project_Profile__c' );
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : am ),
                                 ( noAccountManager ? 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Account_Executive__c' : 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Account_Executive__c' ) );
            query += addToQuery( bc,  'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c' );
            query += addToQuery( bcc, 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Contact__c' );
            query += addToQuery( ac,  'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact_Company__c' );
            query += addToQuery( acc, 'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact__c' );
            query += addToQuery( arc, 'c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__r.A_R_coordinator__c' );
            query += addToQuery( ffo, 'Project_Profile__r.Fulfillment_Office__c' );
            if( noPartner ) {
                query += 'AND ( c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c NOT IN :partnerIds ) ';
            } else {
                query += addToQuery( par, 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c' );
            }
            /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : par ),
                                 ( noPartner ? 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__c != null AND c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c' : 'c2g__Transaction__r.Pro_forma_Invoice__r.Project_Profile__r.Partner__c' ) );*/
            query += addToQuery( filterAccountId, 'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact_Company__c' );
            query += addToQuery( filterContactId, 'c2g__Transaction__r.Pro_forma_Invoice__r.Accounting_Contact__c' );

            query += 'ORDER BY Project_Profile__r.Name, CreatedDate';

            System.debug( LoggingLevel.Error, 'xxx Wave projects query: ' + query );
            queryResult = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Wave projects query size: ' + queryResult.size() );
            for( c2g__codaTransactionLineItem__c tli : queryResult ) {
                Id accountId = tli.c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c;
                if( !this.accountIdToProjectIdToTlisWave.containsKey( accountId ) ) {
                    this.accountIdToProjectIdToTlisWave.put( accountId, new Map<Id, List<c2g__codaTransactionLineItem__c>>() );
                    this.accountIdToProjectIdsWave.put( accountId, new List<Id>() );
                }

                Map<Id, List<c2g__codaTransactionLineItem__c>> projectIdToTlis = this.accountIdToProjectIdToTlisWave.get( accountId );
                if( !projectIdToTlis.containsKey( tli.Project_Profile__c ) ) {
                    projectIdToTlis.put( tli.Project_Profile__c, new List<c2g__codaTransactionLineItem__c>() );
                    this.accountIdToProjectIdsWave.get( accountId ).add( tli.Project_Profile__c );
                }
                projectIdToTlis.get( tli.Project_Profile__c ).add( tli );

                transactionIdToAccountId.put( tli.c2g__Transaction__c, accountId );
            }

            for( c2g__codaInvoice__c invoice : [ SELECT c2g__Transaction__c, cl_Floor_s__c, Name
                                                 FROM c2g__codaInvoice__c
                                                 WHERE c2g__Transaction__c IN : transactionIdToAccountId.keySet() ] ) {
                Id accountId = transactionIdToAccountId.get( invoice.c2g__Transaction__c );
                if( !this.accountIdToTransactionIdToSalesInvoiceWave.containsKey( accountId ) ) {
                    this.accountIdToTransactionIdToSalesInvoiceWave.put( accountId, new Map<Id, c2g__codaInvoice__c>() );
                }
                Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice = this.accountIdToTransactionIdToSalesInvoiceWave.get( accountId );
                transactionIdToSalesInvoice.put( invoice.c2g__Transaction__c, invoice );
            }
        }

        //D - Applied transactions / Mi7 projects
        if( String.isEmpty( ppr ) && String.isEmpty( ffo ) ) {
            Map<Id, Id> transactionIdToAccountId = new Map<Id, Id>();
            query  = 'SELECT c2g__Transaction__c, c2g__Transaction__r.Project_Name_Mi7__c, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.Building__r.Name, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.MRC__c, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.Client_Project__c, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.Name, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.Billing_Contact_SF__r.Name, ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__c, c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__r.FirstName, c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__r.LastName, ';
            query +=        'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c, ';
            query +=        'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Name_without_Prefix__c, ';
            query +=        'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Invoice_Date__c, ';
            query +=        'c2g__HomeValue__c, c2g__HomeOutstandingValue__c ';
            query += 'FROM c2g__codaTransactionLineItem__c ';
            query += 'WHERE c2g__Transaction__r.c2g__TransactionType__c = \'' + TransactionServices.INVOICE_TRANSACTION_TYPE + '\' AND ';
            query +=       'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query +=       'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query +=       'c2g__HomeOutstandingValue__c != 0 AND ';
            query +=       'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c IN :accountIds ';

            query += addToQuery( ppr, 'c2g__Transaction__r.Project_Name_Mi7__c' );
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ),
                                 ( noAccountManager ? 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Sales_Exec_SF__c' : 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Sales_Exec_SF__r.Name' ) );
            query += addToQuery( bc,  'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c' );
            query += addToQuery( bcc, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Contact__c' );
            query += addToQuery( ac,  'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact_Company__c' );
            query += addToQuery( acc, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact__c' );
            query += addToQuery( arc, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__r.A_R_coordinator__c' );
            if( noPartner ) {
                query += 'AND ( c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND ( c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__c = null OR c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name NOT IN :partnerNames ) ) ';
            } else {
                query += addToQuery( partnerName, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name' );
            }
            /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ),
                                 ( noPartner ? 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__c != null AND c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__c' : 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Project_Native__r.Partner__r.Name' ) );*/

            query += addToQuery( filterAccountId, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact_Company__c' );
            query += addToQuery( filterContactId, 'c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Accounting_Contact__c' );

            query += 'ORDER BY c2g__Transaction__r.Project_Name_Mi7__r.MRC__c, CreatedDate';

            System.debug( LoggingLevel.Error, 'xxx Mi7 projects query: ' + query );
            queryResult = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Mi7 projects query size: ' + queryResult.size() );
            for( c2g__codaTransactionLineItem__c tli : queryResult ) {
                Id accountId = tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Billing_Client_Company__c;
                if( !this.accountIdToProjectIdToTlisMi7.containsKey( accountId ) ) {
                    this.accountIdToProjectIdToTlisMi7.put( accountId, new Map<Id, List<c2g__codaTransactionLineItem__c>>() );
                    this.accountIdToProjectIdsMi7.put( accountId, new List<Id>() );
                }

                Map<Id, List<c2g__codaTransactionLineItem__c>> projectIdToTlis = this.accountIdToProjectIdToTlisMi7.get( accountId );

                if( !projectIdToTlis.containsKey( tli.c2g__Transaction__r.Project_Name_Mi7__c ) ) {
                    projectIdToTlis.put( tli.c2g__Transaction__r.Project_Name_Mi7__c, new List<c2g__codaTransactionLineItem__c>() );
                    this.accountIdToProjectIdsMi7.get( accountId ).add( tli.c2g__Transaction__r.Project_Name_Mi7__c );
                }
                projectIdToTlis.get( tli.c2g__Transaction__r.Project_Name_Mi7__c ).add( tli );

                transactionIdToAccountId.put( tli.c2g__Transaction__c, accountId );
            }
            for( c2g__codaInvoice__c invoice : [ SELECT c2g__Transaction__c, PO_Reference__c, Original_Invoice_Number__c,
                                                        c2g__InvoiceDate__c, cl_Floor_s__c, Name
                                                 FROM c2g__codaInvoice__c
                                                 WHERE c2g__Transaction__c IN : transactionIdToAccountId.keySet() ] ) {
                Id accountId = transactionIdToAccountId.get( invoice.c2g__Transaction__c );
                if( !this.accountIdToTransactionIdToSalesInvoiceMi7.containsKey( accountId ) ) {
                    this.accountIdToTransactionIdToSalesInvoiceMi7.put( accountId, new Map<Id, c2g__codaInvoice__c>() );
                }
                Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice = this.accountIdToTransactionIdToSalesInvoiceMi7.get( accountId );
                transactionIdToSalesInvoice.put( invoice.c2g__Transaction__c, invoice );
            }
        }

        //E - Imported invoices with applied TLIs (Imported SI)
        if( String.isEmpty( ppr ) && String.isEmpty( ffo ) ) {
            Map<Id, Map<Id, Id>> accountIdToTransactionIdToSalesInvoiceId = new Map<Id, Map<Id, Id>>();
            Map<Id, Id> transactionIdToAccountId = new Map<Id, Id>();
            query  = 'SELECT c2g__Transaction__c, Project_Address_Reference__c, Project_Reference__c, cl_Floor_s__c, CreatedDate, Name, ';
            query +=        'Client_Project_Reference__c, Project_Info_Reference__c, Billing_Contact_Reference__c, ';
            query +=        'Billing_Company_Reference__c, Invoice_Reference__c, c2g__InvoiceDate__c, PO_Reference__c, ';
            query +=        'Accounting_Contact_Reference__c, Accounting_Contact_Company_Reference__c, c2g__Transaction__r.Account_Manager_Reference__c ';
            query += 'FROM c2g__codaInvoice__c ';
            query += 'WHERE Billing_Company_Reference__c IN :accountIds AND ';
            query +=        'c2g__Transaction__r.c2g__TransactionType__c = \'' + TransactionServices.INVOICE_TRANSACTION_TYPE + '\' AND ';
            query +=        'c2g__Transaction__r.Project_Name_Mi7__c = null AND ';
            query +=        'c2g__Transaction__r.Project_Profile__c = null AND ';
            query +=        'c2g__Transaction__c != null ';

            query += addToQuery( ac, 'Accounting_Contact_Company_Reference__c' );
            query += addToQuery( bc, 'Billing_Company_Reference__c' );
            if( !String.isEmpty( acc ) && accountingContact != null ) {
                query += addToQuery( String.escapeSingleQuotes( accountingContact.Name ), 'Accounting_Contact_Reference__c' );
            }
            if( !String.isEmpty( bcc ) && billingContact != null ) {
                query += addToQuery( String.escapeSingleQuotes( billingContact.Name ), 'Billing_Contact_Reference__c' );
            }
            query += addToQuery( arc, 'Billing_Company_Reference__r.A_R_coordinator__c' );

            query += 'ORDER BY CreatedDate ';

            System.debug( LoggingLevel.Error, 'xxx Imported invoices query: ' + query );
            List<c2g__codaInvoice__c> queryResultInvoices = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Imported invoices query size: ' + queryResultInvoices.size() );
            for( c2g__codaInvoice__c invoice : queryResultInvoices ) {
                Id accountId = invoice.Billing_Company_Reference__c;
                if( !String.isEmpty( invoice.Project_Info_Reference__c ) ) { //!
                    if( !accountIdToTransactionIdToSalesInvoiceId.containsKey( accountId ) ) {
                        accountIdToTransactionIdToSalesInvoiceId.put( accountId, new Map<Id, Id>() );
                        this.accountIdToCompositeKeyToSalesInvoices.put( accountId, new Map<String, List<c2g__codaInvoice__c>>() );
                    }
                    accountIdToTransactionIdToSalesInvoiceId.get( accountId ).put( invoice.c2g__Transaction__c, invoice.Id );

                    Map<String, List<c2g__codaInvoice__c>> compositeKeyToSalesInvoices = this.accountIdToCompositeKeyToSalesInvoices.get( accountId );
                    String compositeKey = invoice.Project_Address_Reference__c +
                                          invoice.Project_Reference__c +
                                          invoice.Client_Project_Reference__c +
                                          invoice.Project_Info_Reference__c +
                                          invoice.Billing_Contact_Reference__c +
                                          ( this.printAmName ? invoice.c2g__Transaction__r.Account_Manager_Reference__c : '' );
                    if( !compositeKeyToSalesInvoices.containsKey( compositeKey ) ) {
                        compositeKeyToSalesInvoices.put( compositeKey, new List<c2g__codaInvoice__c>() );
                    }
                    compositeKeyToSalesInvoices.get( compositeKey ).add( invoice );

                    //populate maps with empty lists
                    if( !this.accountIdToSalesInvoiceIdToTlis.containsKey( accountId ) ) {
                        this.accountIdToSalesInvoiceIdToTlis.put( accountId, new Map<Id, List<c2g__codaTransactionLineItem__c>>() );
                    }
                    Map<Id, List<c2g__codaTransactionLineItem__c>> salesInvoiceIdToTlis = this.accountIdToSalesInvoiceIdToTlis.get( accountId );
                    if( !salesInvoiceIdToTlis.containsKey( invoice.Id ) ) {
                        salesInvoiceIdToTlis.put( invoice.Id, new List<c2g__codaTransactionLineItem__c>() );
                    }

                    transactionIdToAccountId.put( invoice.c2g__Transaction__c, accountId );
                }
            }

            Set<Id> transactionIds = transactionIdToAccountId.keySet();
            query  = 'SELECT c2g__Transaction__c, c2g__HomeValue__c, c2g__HomeOutstandingValue__c, c2g__Transaction__r.Account_Manager_Reference__c ';
            query +=   'FROM c2g__codaTransactionLineItem__c ';
            query +=  'WHERE c2g__Transaction__c IN :transactionIds AND ';
            query +=        'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query +=        'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query +=        'c2g__HomeOutstandingValue__c != 0 ';
            if( noPartner ) {
                query += ' AND ( c2g__Transaction__r.Partner_Reference__c = null OR c2g__Transaction__r.Partner_Reference__c NOT IN :partnerNames ) ';
            } else {
                query += addToQuery( partnerName, 'c2g__Transaction__r.Partner_Reference__c' );
            }
            /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c' );*/
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c' );
            /*query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : am ), 'c2g__Account__r.Account_Manager__c' );*/
            query +=  'ORDER BY CreatedDate ';

            System.debug( LoggingLevel.Error, 'xxx Imported invoices transactions query: ' + query );
            queryResult = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Imported invoices transactions query size: ' + queryResult.size() );
            for( c2g__codaTransactionLineItem__c tli : queryResult ) {
                //populate empty lists
                Id accountId = transactionIdToAccountId.get( tli.c2g__Transaction__c );
                Id salesInvoiceId = accountIdToTransactionIdToSalesInvoiceId.get( accountId ).get( tli.c2g__Transaction__c );
                Map<Id, List<c2g__codaTransactionLineItem__c>> salesInvoiceIdToTlis = this.accountIdToSalesInvoiceIdToTlis.get( accountId );
                salesInvoiceIdToTlis.get( salesInvoiceId ).add( tli );
            }
        }

        //B - Unapplied transactions
        if( true ) {
            query  = 'SELECT Statement_Reference__c, c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionDate__c, ';
            query +=        'c2g__HomeOutstandingValue__c, Project_Profile__c, c2g__Transaction__r.Project_Name_Mi7__c, c2g__Account__c, c2g__Account__r.Account_Manager__c ';
            query += 'FROM c2g__codaTransactionLineItem__c ';
            query += 'WHERE ( c2g__Transaction__r.c2g__TransactionType__c = \'Cash\' OR ';
            query +=        'c2g__Transaction__r.c2g__TransactionType__c = \'Journal\' OR ';
            query +=        'c2g__Transaction__r.c2g__TransactionType__c = \'Credit Note\' OR ';
            query +=        'c2g__Transaction__r.c2g__TransactionType__c = \'Cash Matching Journal\' ) AND ';
            query +=        'c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query +=        'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query +=        'c2g__HomeOutstandingValue__c != 0 AND ';
            query +=        'c2g__Account__c IN :accountIds ';
            query += addToQuery( arc, 'c2g__Account__r.A_R_coordinator__c' );
            /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c' );
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c' );*/
            //query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : am ), 'c2g__Account__r.Account_Manager__c' );
            query += 'ORDER BY CreatedDate ';

            System.debug( LoggingLevel.Error, 'xxx Unapplied transactions query: ' + query );
            queryResult = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Unapplied transactions query size: ' + queryResult.size() );
            for( c2g__codaTransactionLineItem__c tli : queryResult ) {
                if( !noAccountManager && am == null ) { //if am filter is not set, add tli to the report
                    addUnappliedTransaction( tli );
                } else if( noAccountManager || am != null ) { //if am filter is set, or noAm set
                    Boolean projectRelatedTlisFound = false;
                    Id accountId = tli.c2g__Account__c;
                    if( !projectRelatedTlisFound && this.accountIdToProjectIdToTlisWave.get( accountId ) != null ) { //check if there are wave projects found for that account, and add tli if yes
                        projectRelatedTlisFound = true;
                        addUnappliedTransaction( tli );
                    }
                    if( !projectRelatedTlisFound && this.accountIdToProjectIdToTlisMi7.get( accountId ) != null ) { //check if there are mi7 projects found for that account, and add tli if yes
                        projectRelatedTlisFound = true;
                        addUnappliedTransaction( tli );
                    }
                    if( !projectRelatedTlisFound && this.accountIdToSalesInvoiceIdToTlis.get( accountId ) != null ) { //check if there are imported SI found for that account, and add tli if yes
                        for( List<c2g__codaTransactionLineItem__c> salesInvoiceIdToTlis : this.accountIdToSalesInvoiceIdToTlis.get( accountId ).values() ) {
                            if( salesInvoiceIdToTlis != null && !salesInvoiceIdToTlis.isEmpty() ) {
                                addUnappliedTransaction( tli );
                                projectRelatedTlisFound = true;
                                break;
                            }
                        }
                    }
                    if( !projectRelatedTlisFound && tli.c2g__Account__r.Account_Manager__c == ( noAccountManager ? null : am ) ) { // if nothing was found (wave/mi7/invoices), then add tli if account.AM on tli is the same as in filter
                        addUnappliedTransaction( tli );
                    }
                }
            }
        }

        //A - Unapplied Debit Memos (Imported SI to be shown as unapplied transactions)
        if( true ) {
            Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>> accountIdToTransactionIdToTlis = new Map<Id, Map<Id, List<c2g__codaTransactionLineItem__c>>>();
            Map<Id, Id> transactionIdToAccountId = new Map<Id, Id>();
            query  = 'SELECT Statement_Reference__c, c2g__Transaction__r.c2g__DocumentNumber__c, c2g__Transaction__r.c2g__TransactionDate__c, ';
            query +=        'c2g__HomeOutstandingValue__c, Project_Profile__c, c2g__Transaction__r.Project_Name_Mi7__c, c2g__Account__c, c2g__Transaction__c ';
            query += 'FROM c2g__codaTransactionLineItem__c ';
            query += 'WHERE c2g__LineType__c = \'' + TransactionLineItemServices.ACCOUNT_LINE_TYPE + '\' AND ';
            query +=       'c2g__MatchingStatus__c = \'' + TransactionLineItemServices.AVAILABLE_MATCHING_STATUS + '\' AND ';
            query +=       'c2g__HomeOutstandingValue__c != 0 AND ';
            query +=       'c2g__Account__c IN :accountIds ';
            query += addToQuery( arc, 'c2g__Account__r.A_R_coordinator__c' );
            /*query += addToQuery( ( noPartner ? MilroseDevHelper.NULL_STRING : partnerName ), 'c2g__Transaction__r.Partner_Reference__c' );
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : accountManagerName ), 'c2g__Transaction__r.Account_Manager_Reference__c' );*/
            query += addToQuery( ( noAccountManager ? MilroseDevHelper.NULL_STRING : am ), 'c2g__Account__r.Account_Manager__c' );
            query += 'ORDER BY CreatedDate';

            System.debug( LoggingLevel.Error, 'xxx Unapplied debit memos query: ' + query );
            queryResult = Database.query( query );
            System.debug( LoggingLevel.Error, 'xxx Unapplied debit memos query size: ' + queryResult.size() );
            for( c2g__codaTransactionLineItem__c tli : queryResult ) {
                if( tli.c2g__HomeOutstandingValue__c != null ) {
                    Id accountId = tli.c2g__Account__c;
                    if( !accountIdToTransactionIdToTlis.containsKey( accountId ) ) {
                        accountIdToTransactionIdToTlis.put( accountId, new Map<Id, List<c2g__codaTransactionLineItem__c>>() );
                    }
                    Map<Id, List<c2g__codaTransactionLineItem__c>> transactionIdToTlis = accountIdToTransactionIdToTlis.get( accountId );
                    if( !transactionIdToTlis.containsKey( tli.c2g__Transaction__c ) ) {
                        transactionIdToTlis.put( tli.c2g__Transaction__c, new List<c2g__codaTransactionLineItem__c>() );
                    }
                    transactionIdToTlis.get( tli.c2g__Transaction__c ).add( tli );

                    transactionIdToAccountId.put( tli.c2g__Transaction__c, accountId );
                }
            }

            for( c2g__codaInvoice__c invoice : [ SELECT c2g__Transaction__c, Project_Address_Reference__c, Project_Reference__c,
                                                        Client_Project_Reference__c, Project_Info_Reference__c, Billing_Contact_Reference__c,
                                                        Accounting_Contact_Reference__c
                                                 FROM c2g__codaInvoice__c
                                                 WHERE Billing_Company_Reference__c = null AND
                                                       Accounting_Contact_Company_Reference__c = null AND
                                                       c2g__Transaction__r.c2g__TransactionType__c = : TransactionServices.INVOICE_TRANSACTION_TYPE AND
                                                       c2g__Transaction__r.Project_Name_Mi7__c = null AND
                                                       c2g__Transaction__r.Project_Profile__c = null AND
                                                       cl_Pro_forma_Invoice__c = null AND
                                                       Legacy_Pro_forma_Invoice__c = null AND
                                                       c2g__Transaction__c IN : transactionIdToAccountId.keySet()
                                                 ORDER BY CreatedDate ] ) {
                if( String.isEmpty( invoice.Project_Reference__c ) &&
                    String.isEmpty( invoice.Billing_Contact_Reference__c ) &&
                    String.isEmpty( invoice.Accounting_Contact_Reference__c ) &&
                    String.isEmpty( invoice.Project_Address_Reference__c ) &&
                    String.isEmpty( invoice.Client_Project_Reference__c ) &&
                    String.isEmpty( invoice.Project_Info_Reference__c ) ) {
                    Id accountId = transactionIdToAccountId.get( invoice.c2g__Transaction__c );
                    for( c2g__codaTransactionLineItem__c tli : accountIdToTransactionIdToTlis.get( accountId ).get( invoice.c2g__Transaction__c ) ) {
                        if( tli.c2g__HomeOutstandingValue__c != null ) {
                            if( !this.accountIdToUnappliedDebitMemoTlis.containsKey( accountId ) ) {
                                this.accountIdToUnappliedDebitMemoTlis.put( accountId, new List<c2g__codaTransactionLineItem__c>() );
                            }
                            this.accountIdToUnappliedDebitMemoTlis.get( accountId ).add( tli );
                        }
                    }
                }
            }
        }
    }

    public void addUnappliedTransaction( c2g__codaTransactionLineItem__c tli ) {
        Id accountId = tli.c2g__Account__c;
        if( !this.accountIdToUnappliedTlis.containsKey( accountId ) ) {
            this.accountIdToUnappliedTlis.put( accountId, new List<c2g__codaTransactionLineItem__c>() );
        }
        this.accountIdToUnappliedTlis.get( accountId ).add( tli );
    }

    public String addToQuery( String param, String field ) {
        if( !String.isEmpty( param ) ) {
            return 'AND ' + field + ' = ' + ( param == MilroseDevHelper.NULL_STRING ? param : '\'' + param + '\'' ) + ' ';
        }
        return '';
    }

    public class SOAWrapper {
        public Boolean isFirst { get { if( isFirst == null ) isFirst = false; return isFirst; } set; }
        public Boolean isLast { get { if( isLast == null ) isLast = false; return isLast; } set; }

        public Account account { get { if( account == null ) account = new Account(); return account; } private set; }
        public String arCoorName { get; private set; }
        public String arCoorPhone { get; private set; }
        public String arCoorEmail { get; private set; }

        public Decimal outstAmt_0_30 { get { if( outstAmt_0_30 == null ) outstAmt_0_30 = 0.00; return outstAmt_0_30; } private set; }
        public Decimal outstAmt_31_60 { get { if( outstAmt_31_60 == null ) outstAmt_31_60 = 0.00; return outstAmt_31_60; } private set; }
        public Decimal outstAmt_61_90 { get { if( outstAmt_61_90 == null ) outstAmt_61_90 = 0.00; return outstAmt_61_90; } private set; }
        public Decimal outstAmt_91_120 { get { if( outstAmt_91_120 == null ) outstAmt_91_120 = 0.00; return outstAmt_91_120; } private set; }
        public Decimal outstAmt_121_365 { get { if( outstAmt_121_365 == null ) outstAmt_121_365 = 0.00; return outstAmt_121_365; } private set; }
        public Decimal outstAmt_366_plus { get { if( outstAmt_366_plus == null ) outstAmt_366_plus = 0.00; return outstAmt_366_plus; } private set; }
        public Decimal accountSubtotal { get { if( accountSubtotal == null ) accountSubtotal = 0.00; return accountSubtotal; } private set; }

        public Decimal unapDocSubtotal { get { if( unapDocSubtotal == null ) unapDocSubtotal = 0.00; return unapDocSubtotal; } private set; }
        public Decimal totalDue { get { return accountSubtotal + unapDocSubtotal; } private set; }

        public List<SOAWrapperTable> tables { get { if( tables == null ) tables = new List<SOAWrapperTable>(); return tables; } private set; }
        public List<SOAWrapperLineUnappliedDoc> unapTransactions { get { if( unapTransactions == null ) unapTransactions = new List<SOAWrapperLineUnappliedDoc>(); return unapTransactions; } private set; }

        public SOAWrapper( Account accountItem,
                           String ppr, String ac, String acc, String bc, String bcc, String arc, String ffo, String am, String par, Boolean noAccountManager, Boolean noPartner, Boolean printAmName,
                           String filterAccountId, String filterContactId,
                           Contact accountingContact, Contact billingContact,
                           String arCoorName, String arCoorPhone, String arCoorEmail,
                           List<Id> projectIdsWave,
                           Map<Id, List<c2g__codaTransactionLineItem__c>> projectIdToTlisWave,
                           Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoiceWave,
                           List<Id> projectIdsMi7,
                           Map<Id, List<c2g__codaTransactionLineItem__c>> projectIdToTlisMi7,
                           Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoiceMi7,
                           Map<String, List<c2g__codaInvoice__c>> compositeKeyToSalesInvoices,
                           Map<Id, List<c2g__codaTransactionLineItem__c>> salesInvoiceIdToTlis,
                           List<c2g__codaTransactionLineItem__c> unappliedTlis,
                           List<c2g__codaTransactionLineItem__c> unappliedDebitMemoTlis,
                           Boolean excludeUnnapliedDocuments ) {
            Integer seqNumber = 1;
            String query;

            this.account = accountItem;

            if( String.isEmpty( filterContactId ) && String.isEmpty( filterAccountId ) ) {
                this.arCoorName = accountItem.A_R_Coordinator_Full_Name__c;
                this.arCoorPhone = accountItem.A_R_Coordinator_Phone__c;
                this.arCoorEmail = accountItem.A_R_Coordinator_Email__c;
            } else {
                this.arCoorName = arCoorName;
                this.arCoorPhone = arCoorPhone;
                this.arCoorEmail = arCoorEmail;
            }

            //applied transactions / wave projects
            if( projectIdsWave != null ) {
                for( Id projectId : projectIdsWave ) {
                    SOAWrapperTable table = new SOAWrapperTable( WAVE_PROJECT,
                                                                 projectIdToTlisWave.get( projectId ),
                                                                 transactionIdToSalesInvoiceWave,
                                                                 printAmName,
                                                                 seqNumber );
                    seqNumber = addTablesAndCalculateAmounts( table, printAmName, seqNumber );
                }
            }

            //applied transactions / Mi7 projects
            if( projectIdsMi7 != null ) {
                for( Id projectId : projectIdsMi7 ) {
                    SOAWrapperTable table = new SOAWrapperTable( OLD_PROJECT,
                                                                 projectIdToTlisMi7.get( projectId ),
                                                                 transactionIdToSalesInvoiceMi7,
                                                                 printAmName,
                                                                 seqNumber );
                    seqNumber = addTablesAndCalculateAmounts( table, printAmName, seqNumber );
                }
            }

            //imported SI
            if( compositeKeyToSalesInvoices != null ) {
                for( String compositeKey : compositeKeyToSalesInvoices.keySet() ) {
                    SOAWrapperTable table = new SOAWrapperTable( IMPORTED_INV,
                                                                 compositeKeyToSalesInvoices.get( compositeKey ),
                                                                 salesInvoiceIdToTlis,
                                                                 printAmName,
                                                                 seqNumber );
                    seqNumber = addTablesAndCalculateAmounts( table, printAmName, seqNumber );
                }
            }

            //unapplied transactions
            if( unappliedTlis != null && !excludeUnnapliedDocuments ) {
                for( c2g__codaTransactionLineItem__c tli : unappliedTlis ) {
                    SOAWrapperLineUnappliedDoc unapTransaction = new SOAWrapperLineUnappliedDoc( tli );
                    unapTransactions.add( unapTransaction );
                    unapDocSubtotal += unapTransaction.totalDue;
                }
            }

            //Unapplied Debit Memos
            if( unappliedDebitMemoTlis != null && !excludeUnnapliedDocuments ) {
                for( c2g__codaTransactionLineItem__c tli : unappliedDebitMemoTlis ) {
                    SOAWrapperLineUnappliedDoc unapTransaction = new SOAWrapperLineUnappliedDoc( tli );
                    unapTransactions.add( unapTransaction );
                    unapDocSubtotal += unapTransaction.totalDue;
                }
            }

            //sort list by Address_Building_AKA__c and Project_Number_c
            tables.sort();
            for( Integer i = 1; i <= tables.size(); i++ ) {
                tables[ i-1 ].seqNumber = i;
            }
        }

        public Map<String, Integer> compositeKeyToTableSeqNumber = new Map<String, Integer>(); //joins tables together if headers are the same

        public Integer addTablesAndCalculateAmounts( SOAWrapperTable table, Boolean printAmName, Integer seqNumber ) {
            if( !table.lines.isEmpty() ) {
                outstAmt_0_30 += table.outstAmt_0_30;
                outstAmt_31_60 += table.outstAmt_31_60;
                outstAmt_61_90 += table.outstAmt_61_90;
                outstAmt_91_120 += table.outstAmt_91_120;
                outstAmt_121_365 += table.outstAmt_121_365;
                outstAmt_366_plus += table.outstAmt_366_plus;
                accountSubtotal += table.totalDue;
                String compositeKey = table.projectBuilding +
                                      table.projectName +
                                      table.projectClientProject +
                                      table.projectInfo +
                                      table.projectBillingCompanyContact +
                                      ( printAmName ? table.amName : '' );
                if( !compositeKeyToTableSeqNumber.containsKey( compositeKey ) ) { //add new table
                    compositeKeyToTableSeqNumber.put( compositeKey, seqNumber - 1 );
                    tables.add( table );
                    seqNumber++;
                } else { //join tables
                    SOAWrapperTable existingTable = tables.get( compositeKeyToTableSeqNumber.get( compositeKey ) );
                    existingTable.lines.addAll( table.lines );
                    existingTable.outstAmt_0_30 += table.outstAmt_0_30;
                    existingTable.outstAmt_31_60 += table.outstAmt_31_60;
                    existingTable.outstAmt_61_90 += table.outstAmt_61_90;
                    existingTable.outstAmt_91_120 += table.outstAmt_91_120;
                    existingTable.outstAmt_121_365 += table.outstAmt_121_365;
                    existingTable.outstAmt_366_plus += table.outstAmt_366_plus;
                    existingTable.totalDue += table.totalDue;

                    //overwrite floor info with info from the latest invoice
                    Map<String, String> invoiceNameToFloorInfo = new Map<String, String>{ existingTable.latestInvoiceName => existingTable.floorInfo,
                                                                                          table.latestInvoiceName => table.floorInfo };
                    List<String> invoiceNames = new List<String>( invoiceNameToFloorInfo.keySet() );
                    invoiceNames.sort();
                    existingTable.latestInvoiceName = invoiceNames[ invoiceNames.size() - 1 ];
                    existingTable.floorInfo = invoiceNameToFloorInfo.get( existingTable.latestInvoiceName );
                }
            }
            return seqNumber;
        }
    }

    public class SOAWrapperTable implements Comparable {
        public Integer seqNumber { get { if( seqNumber == null ) seqNumber = 1; return seqNumber; } private set; }
        public Decimal outstAmt_0_30 { get { if( outstAmt_0_30 == null ) outstAmt_0_30 = 0.00; return outstAmt_0_30; } private set; }
        public Decimal outstAmt_31_60 { get { if( outstAmt_31_60 == null ) outstAmt_31_60 = 0.00; return outstAmt_31_60; } private set; }
        public Decimal outstAmt_61_90 { get { if( outstAmt_61_90 == null ) outstAmt_61_90 = 0.00; return outstAmt_61_90; } private set; }
        public Decimal outstAmt_91_120 { get { if( outstAmt_91_120 == null ) outstAmt_91_120 = 0.00; return outstAmt_91_120; } private set; }
        public Decimal outstAmt_121_365 { get { if( outstAmt_121_365 == null ) outstAmt_121_365 = 0.00; return outstAmt_121_365; } private set; }
        public Decimal outstAmt_366_plus { get { if( outstAmt_366_plus == null ) outstAmt_366_plus = 0.00; return outstAmt_366_plus; } private set; }
        public Decimal totalDue { get { if( totalDue == null ) totalDue = 0.00; return totalDue; } private set; }

        public String projectBuilding { get { if( projectBuilding == null ) projectBuilding = ''; return projectBuilding; } private set; }
        public String projectName { get { if( projectName == null ) projectName = ''; return projectName; } private set; }
        public String projectClientProject { get { if( projectClientProject == null ) projectClientProject = ''; return projectClientProject; } private set; }
        public String projectInfo { get { if( projectInfo == null ) projectInfo = ''; return projectInfo; } private set; }
        public String projectBillingCompanyContact { get { if( projectBillingCompanyContact == null ) projectBillingCompanyContact = ''; return projectBillingCompanyContact; } private set; }
        public String floorInfo { get { if( floorInfo == null ) floorInfo = ''; return floorInfo; } private set; }
        public Boolean printAmName { get { if( printAmName == null ) printAmName = false; return printAmName; } private set; }
        public String amName { get { if( amName == null ) amName = ''; return amName; } private set; }
        public String latestInvoiceName;

        public List<SOAWrapperLine> lines { get { if( lines == null ) lines = new List<SOAWrapperLine>(); return lines; } private set; }

        public Integer compareTo( Object compareTo ) {
            SOAWrapperTable soaWraperTableItem = (SOAWrapperTable) compareTo;
            if (projectName > soaWraperTableItem.projectName) return 1;
            if (projectName < soaWraperTableItem.projectName) return -1;
            if (projectName == soaWraperTableItem.projectName) return 0;
            return -1;
        }

        public SOAWrapperTable( String type, List<c2g__codaTransactionLineItem__c> tlis, Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice, Boolean printAmName, Integer seqNumber ) { // wave and old project
            this.seqNumber = seqNumber;
            this.printAmName = printAmName;
            if( type == WAVE_PROJECT ) {
                projectBuilding = tlis[0].Project_Profile__r.Address_Building_AKA__c;
                projectName = tlis[0].Project_Profile__r.Name;
                projectClientProject = tlis[0].Project_Profile__r.Client_Project__c;
                projectInfo = tlis[0].Project_Profile__r.Project_Name__c;
                projectBillingCompanyContact = tlis[0].Project_Profile__r.Billing_Company_Contact__r.Name;
                for( c2g__codaTransactionLineItem__c tli : tlis ) {
                    populateAmName( tli, type );
                    getFloorInfo( tli, transactionIdToSalesInvoice, null, type );
                    addLinesAndCalculateAmounts( tli, type, null );
                }
            } else if( type == OLD_PROJECT ) {
                projectBuilding = tlis[0].c2g__Transaction__r.Project_Name_Mi7__r.Building__r.Name;
                projectName = tlis[0].c2g__Transaction__r.Project_Name_Mi7__r.MRC__c;
                projectClientProject = tlis[0].c2g__Transaction__r.Project_Name_Mi7__r.Client_Project__c;
                projectInfo = tlis[0].c2g__Transaction__r.Project_Name_Mi7__r.Name;
                projectBillingCompanyContact = tlis[0].c2g__Transaction__r.Project_Name_Mi7__r.Billing_Contact_SF__r.Name;
                for( c2g__codaTransactionLineItem__c tli : tlis ) {
                    populateAmName( tli, type );
                    getFloorInfo( tli, transactionIdToSalesInvoice, null, type );
                    addLinesAndCalculateAmounts( tli, type, transactionIdToSalesInvoice );
                }
            }
        }

        public SOAWrapperTable( String type, List<c2g__codaInvoice__c> invoices, Map<Id, List<c2g__codaTransactionLineItem__c>> salesInvoiceIdToTlis, Boolean printAmName, Integer seqNumber ) { // imported SI
            this.seqNumber = seqNumber;
            this.printAmName = printAmName;
            if( type == IMPORTED_INV ) {
                projectBuilding = invoices[0].Project_Address_Reference__c;
                projectName = invoices[0].Project_Reference__c;
                projectClientProject = invoices[0].Client_Project_Reference__c;
                projectInfo = invoices[0].Project_Info_Reference__c;
                projectBillingCompanyContact = invoices[0].Billing_Contact_Reference__c;
                getFloorInfo( null, null, invoices, type );
                if( salesInvoiceIdToTlis != null && !salesInvoiceIdToTlis.isEmpty() ) {
                    for( c2g__codaInvoice__c invoice : invoices ) {
                        if( salesInvoiceIdToTlis.get( invoice.Id ) != null && !salesInvoiceIdToTlis.get( invoice.Id ).isEmpty() ) {
                            for( c2g__codaTransactionLineItem__c tli : salesInvoiceIdToTlis.get( invoice.Id ) ) {
                                populateAmName( tli, type );
                                addLinesAndCalculateAmounts( tli, type, new Map<Id, c2g__codaInvoice__c>{ tli.c2g__Transaction__c => invoice } );
                            }
                        }
                    }
                }
            }
        }

        private void populateAmName( c2g__codaTransactionLineItem__c tli, String type ) {
            if( printAmName && String.isEmpty( amName ) ) {
                if( type == WAVE_PROJECT ) {
                    if( !String.isEmpty( tli.Project_Profile__r.Account_Executive__c ) ) {
                        this.amName = tli.Project_Profile__r.Account_Executive__r.FirstName + ' ' + tli.Project_Profile__r.Account_Executive__r.LastName;
                    }
                } else if( type == OLD_PROJECT ) {
                    if( !String.isEmpty( tli.c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__c ) ) {
                        this.amName = tli.c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__r.FirstName + ' ' + tli.c2g__Transaction__r.Project_Name_Mi7__r.Sales_Exec_SF__r.LastName;
                    }
                } else if( type == IMPORTED_INV ) {
                    if( !String.isEmpty( tli.c2g__Transaction__r.Account_Manager_Reference__c ) ) {
                        this.amName = tli.c2g__Transaction__r.Account_Manager_Reference__c;
                    }
                }
            }
        }

        private void getFloorInfo( c2g__codaTransactionLineItem__c tli, Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice, //wave and imported projects
                                   List<c2g__codaInvoice__c> invoices, //imported invoices
                                   String type ) {
            Map<String, String> invoiceNameToFloorInfo = new Map<String, String>();
            if( type == IMPORTED_INV ) { //imported invoices
                for( c2g__codaInvoice__c invoice : invoices ) {
                    invoiceNameToFloorInfo.put( invoice.Name, invoice.cl_Floor_s__c );
                }
            } else { //wave and imported projects
                invoiceNameToFloorInfo.put( latestInvoiceName, floorInfo );
                if( transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ) != null ) {
                    invoiceNameToFloorInfo.put( transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).Name, transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).cl_Floor_s__c );
                }
            }
            List<String> invoiceNames = new List<String>( invoiceNameToFloorInfo.keySet() );
            invoiceNames.sort();
            latestInvoiceName = invoiceNames[ invoiceNames.size() - 1 ];
            floorInfo = invoiceNameToFloorInfo.get( latestInvoiceName );
        }

        private void addLinesAndCalculateAmounts( c2g__codaTransactionLineItem__c tli, String type, Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice ) {
            if( tli.c2g__HomeOutstandingValue__c != null ) {
                SOAWrapperLine line = new SOAWrapperLine( tli, type, transactionIdToSalesInvoice );
                lines.add( line );

                outstAmt_0_30 += line.outstAmt_0_30;
                outstAmt_31_60 += line.outstAmt_31_60;
                outstAmt_61_90 += line.outstAmt_61_90;
                outstAmt_91_120 += line.outstAmt_91_120;
                outstAmt_121_365 += line.outstAmt_121_365;
                outstAmt_366_plus += line.outstAmt_366_plus;
                totalDue += line.totalDue;
            }
        }
    }

    public class SOAWrapperLine {
        public String invoiceNumber { get { if( invoiceNumber == null ) invoiceNumber = ''; return invoiceNumber; } private set; }
        public Date dateOfInvoice { get; private set; }
        public Decimal originalAmt { get { if( originalAmt == null ) originalAmt = 0.00; return originalAmt; } private set; }
        public String clientPO { get { if( clientPO == null ) clientPO = ''; return clientPO; } private set; }
        public List<String> clientPOs { get { return MilroseDevHelper.splitStringsBySymbolCount( clientPO, 15 ); } }
        public Decimal appliedAmt { get { if( appliedAmt == null ) appliedAmt = 0.00; return appliedAmt; } private set; }
        public Decimal outstAmt_0_30 { get { if( outstAmt_0_30 == null ) outstAmt_0_30 = 0.00; return outstAmt_0_30; } private set; }
        public Decimal outstAmt_31_60 { get { if( outstAmt_31_60 == null ) outstAmt_31_60 = 0.00; return outstAmt_31_60; } private set; }
        public Decimal outstAmt_61_90 { get { if( outstAmt_61_90 == null ) outstAmt_61_90 = 0.00; return outstAmt_61_90; } private set; }
        public Decimal outstAmt_91_120 { get { if( outstAmt_91_120 == null ) outstAmt_91_120 = 0.00; return outstAmt_91_120; } private set; }
        public Decimal outstAmt_121_365 { get { if( outstAmt_121_365 == null ) outstAmt_121_365 = 0.00; return outstAmt_121_365; } private set; }
        public Decimal outstAmt_366_plus { get { if( outstAmt_366_plus == null ) outstAmt_366_plus = 0.00; return outstAmt_366_plus; } private set; }
        public Decimal totalDue { get { if( totalDue == null ) totalDue = 0.00; return totalDue; } private set; }



        public SOAWrapperLine( c2g__codaTransactionLineItem__c tli, String type, Map<Id, c2g__codaInvoice__c> transactionIdToSalesInvoice ) {
            if( type == WAVE_PROJECT ) {
                invoiceNumber = tli.c2g__Transaction__r.Pro_forma_Invoice__r.Name_without_Prefix__c;
                dateOfInvoice = tli.c2g__Transaction__r.Pro_forma_Invoice__r.Invoice_Date__c;
                clientPO = tli.c2g__Transaction__r.PO_Reference__c;
            } else if( type == OLD_PROJECT ) {
                invoiceNumber = tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Name_without_Prefix__c; //tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Name_without_Prefix__c != null ? tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Name_without_Prefix__c : transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).Original_Invoice_Number__c;
                dateOfInvoice = tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Invoice_Date__c; //tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Invoice_Date__c != null ? tli.c2g__Transaction__r.Legacy_Pro_forma_Invoice__r.Invoice_Date__c : transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).c2g__InvoiceDate__c;
                if( transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ) != null ) {
                    clientPO = transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).PO_Reference__c;
                }
            } else if( type == IMPORTED_INV ) {
                invoiceNumber = transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).Invoice_Reference__c;
                dateOfInvoice = transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).c2g__InvoiceDate__c;
                clientPO = transactionIdToSalesInvoice.get( tli.c2g__Transaction__c ).PO_Reference__c;
            }
            originalAmt = tli.c2g__HomeValue__c;
            appliedAmt = tli.c2g__HomeValue__c - tli.c2g__HomeOutstandingValue__c;
            if( Test.isRunningTest() ) dateOfInvoice = Date.today();
            if( dateOfInvoice <= Date.today() && dateOfInvoice > Date.today().addDays(-31) ) outstAmt_0_30 = tli.c2g__HomeOutstandingValue__c;
            if( dateOfInvoice <= Date.today().addDays(-31) && dateOfInvoice > Date.today().addDays(-61) ) outstAmt_31_60 = tli.c2g__HomeOutstandingValue__c;
            if( dateOfInvoice <= Date.today().addDays(-61) && dateOfInvoice > Date.today().addDays(-91) ) outstAmt_61_90 = tli.c2g__HomeOutstandingValue__c;
            if( dateOfInvoice <= Date.today().addDays(-91) && dateOfInvoice > Date.today().addDays(-121) ) outstAmt_91_120 = tli.c2g__HomeOutstandingValue__c;
            if( dateOfInvoice <= Date.today().addDays(-121) && dateOfInvoice > Date.today().addDays(-366) ) outstAmt_121_365 = tli.c2g__HomeOutstandingValue__c;
            if( dateOfInvoice <= Date.today().addDays(-366) ) outstAmt_366_plus = tli.c2g__HomeOutstandingValue__c;
            totalDue = tli.c2g__HomeOutstandingValue__c;
        }
    }

    public class SOAWrapperLineUnappliedDoc {
        public Decimal totalDue { get { if( totalDue == null ) totalDue = 0.00; return totalDue; } private set; }

        public List<String> referenceNumbers { get { if( referenceNumbers == null ) referenceNumbers = new List<String>(); return referenceNumbers; } private set; }
        public List<String> documentNumbers { get { if( documentNumbers == null ) documentNumbers = new List<String>(); return documentNumbers; } private set; }
        public List<String> datesReceived { get { if( datesReceived == null ) datesReceived = new List<String>(); return datesReceived; } private set; }
        public List<String> amounts { get { if( amounts == null ) amounts = new List<String>(); return amounts; } private set; }
        public List<Integer> listIndexes {
            get {
                List<Integer> indexes = new List<Integer>();
                for( Integer index = 0; index < referenceNumbers.size(); index ++ ) {
                    indexes.add( index );
                }
                return indexes;
            } private set;
        }

        public SOAWrapperLineUnappliedDoc( c2g__codaTransactionLineItem__c tli ) { //for unapplied transactions
            referenceNumbers = MilroseDevHelper.splitStringsBySymbolCount( tli.Statement_Reference__c, 70 );
            for( Integer i = 0; i < referenceNumbers.size(); i++ ) {
                if( i == 0 ) {
                    String documentNumber = tli.c2g__Transaction__r.c2g__DocumentNumber__c;
                    if( !String.isBlank( documentNumber ) && documentNumber.startsWith( SalesInvoiceServices.SALES_CREDIT_NOTES_PREFIX_SCR ) ) { //MRS-5111
                        documentNumber = documentNumber.removeStart( SalesInvoiceServices.SALES_CREDIT_NOTES_PREFIX_SCR );
                        while( !String.isEmpty( documentNumber ) && documentNumber.substring( 0, 1 ) == '0' ) {
                            documentNumber = documentNumber.removestart('0');
                        }
                        documentNumbers.add( SalesInvoiceServices.SALES_CREDIT_NOTES_PREFIX_SCR + documentNumber );
                    } else {
                        documentNumbers.add( tli.c2g__Transaction__r.c2g__DocumentNumber__c != null ? tli.c2g__Transaction__r.c2g__DocumentNumber__c : '' );
                    }

                    datesReceived.add( tli.c2g__Transaction__r.c2g__TransactionDate__c != null
                                       ? tli.c2g__Transaction__r.c2g__TransactionDate__c.month() + '/' +
                                         tli.c2g__Transaction__r.c2g__TransactionDate__c.day() + '/' +
                                         tli.c2g__Transaction__r.c2g__TransactionDate__c.year()
                                       : '' );

                    String amount = ( ( tli.c2g__HomeOutstandingValue__c != null ? tli.c2g__HomeOutstandingValue__c : 0.00 ).setScale(2) ).format();
                    if( !amount.contains('.' ) ) amount += '.00';
                    if( amount.indexOf('-') != -1 ) amount = amount.replace( '-', '-$' );
                    amounts.add( amount );

                    totalDue = tli.c2g__HomeOutstandingValue__c;
                } else {
                    documentNumbers.add('');
                    datesReceived.add('');
                    amounts.add('');
                }
            }
        }
    }

}