@isTest(SeeAllData = true)
private class TestSOAController {
    private static final String FAKE_ID = '000000000000';
    private static final Integer NUMBER_TO_CREATE = 1;
    private static SOAController controller;
    private static User projectManager;
    private static Account account;
    private static Contact contact;
    private static Project_Profile__c project;

    private static void setUpControllerAndInitiliazePage( Id accountId ) {
        Test.setCurrentPageReference(Page.SOA);
        if( accountId != null ) {
            ApexPages.currentPage().getParameters().put( 'p', accountId );
        } else {
            ApexPages.currentPage().getParameters().put( 'p', '' );
        }
        controller = new SOAController();
    }

    private static void setupData() {
        projectManager = TestingUtils.userWithProfile( UserServices.PROFILE_PROJECT_MANAGER_2 );
        account = TestingUtils.createAccountList( NUMBER_TO_CREATE, 'TestAcc', true )[0];
        contact = TestingUtils.createContactList( NUMBER_TO_CREATE, account.Id, false )[0];
        contact.FirstName = 'Test';
        INSERT contact;
        project = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE, account.Id, contact.Id, account.Id, contact.Id,
                                                         account.Id, contact.Id, projectManager.Id, true )[0];
    }

    @isTest static void TestCodaTransaction() {
        List<c2g__codaTransactionLineItem__c> trLineItems = [SELECT c2g__Transaction__c, Project_Profile__c, Project_Profile__r.Address_Building_AKA__c, Project_Profile__r.Name,
                                                    Project_Profile__r.Client_Project__c, Project_Profile__r.Project_Name__c, Project_Profile__r.Billing_Company_Contact__r.Name,
                                                    Project_Profile__r.Account_Executive__c, Project_Profile__r.Account_Executive__r.FirstName, Project_Profile__r.Account_Executive__r.LastName,
                                                    c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c, c2g__Transaction__r.Pro_forma_Invoice__r.Name_without_Prefix__c,
                                                    c2g__Transaction__r.Pro_forma_Invoice__r.Invoice_Date__c, c2g__HomeValue__c, c2g__HomeOutstandingValue__c, Project_Profile__r.Floor_s__c,
                                                    c2g__Transaction__r.PO_Reference__c
                                            FROM c2g__codaTransactionLineItem__c
                                            WHERE c2g__Transaction__r.c2g__TransactionType__c = :TransactionServices.INVOICE_TRANSACTION_TYPE 
                                                AND c2g__LineType__c = :TransactionLineItemServices.ACCOUNT_LINE_TYPE
                                                AND c2g__MatchingStatus__c = :TransactionLineItemServices.AVAILABLE_MATCHING_STATUS
                                                AND c2g__HomeOutstandingValue__c != 0
                                                AND c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c != null];
        if( trLineItems != null ) {
            setupData();
            Test.setCurrentPageReference(Page.SOA);
            ApexPages.currentPage().getParameters().put( 'p', trLineItems[0].c2g__Transaction__r.Pro_forma_Invoice__r.Billing_Client_Company__c );
            controller = new SOAController();   

            Test.startTest();

                String milroseLogoIdExternalUrl = controller.milroseLogoIdExternalUrl;

            Test.stopTest();
        }
    }

    @isTest static void TestUncoveredParts() {
        setupData();
        Test.setCurrentPageReference(Page.SOA);
        ApexPages.currentPage().getParameters().put( 'p', account.Id );
        ApexPages.currentPage().getParameters().put( 'a', account.Id );
        ApexPages.currentPage().getParameters().put( 'c', contact.Id );
        ApexPages.currentPage().getParameters().put( 'acc', contact.Id );
        ApexPages.currentPage().getParameters().put( 'bcc', contact.Id );
        ApexPages.currentPage().getParameters().put( 'par', projectManager.Id );
        ApexPages.currentPage().getParameters().put( 'am', projectManager.Id );

        controller = new SOAController();   

        Test.startTest();

            String milroseLogoIdExternalUrl = controller.milroseLogoIdExternalUrl;

        Test.stopTest();

        ApexPages.currentPage().getParameters().put( 'a', 'fakeAccountID' );
        ApexPages.currentPage().getParameters().put( 'c', 'fakeContactId' );
        ApexPages.currentPage().getParameters().put( 'renderAs', 'xls' );
        controller = new SOAController();   
    }

    @isTest static void initWithErrors() {
        Test.startTest();
            setUpControllerAndInitiliazePage( null );
            setUpControllerAndInitiliazePage( Schema.SObjectType.Lead.getKeyPrefix() + FAKE_ID );
            setUpControllerAndInitiliazePage( Schema.SObjectType.Account.getKeyPrefix() + FAKE_ID );
        Test.stopTest();
    }

    @isTest static void testSOAController() {
        setupData();

        Test.startTest();
            setUpControllerAndInitiliazePage( account.Id );
            String milroseLogoIdExternalUrl = controller.milroseLogoIdExternalUrl;
        Test.stopTest();
    }

    @isTest static void testSOAControllerTables() {
        setupData();
        SOAController.SOAWrapperTable table;
        SOAController.SOAWrapperLine line;
        c2g__codaTransaction__c tr = new c2g__codaTransaction__c( Id = Schema.SObjectType.c2g__codaTransaction__c.getKeyPrefix() + FAKE_ID );
        c2g__codaTransactionLineItem__c tli = new c2g__codaTransactionLineItem__c( Id = Schema.SObjectType.c2g__codaTransactionLineItem__c.getKeyPrefix() + FAKE_ID,
                                                                                   c2g__Transaction__c = tr.Id,
                                                                                   c2g__HomeValue__c = 0,
                                                                                   c2g__HomeOutstandingValue__c = 0 );
        c2g__codaInvoice__c si = new c2g__codaInvoice__c( Id = Schema.SObjectType.c2g__codaInvoice__c.getKeyPrefix() + FAKE_ID );

        Test.startTest();
            setUpControllerAndInitiliazePage( account.Id );
            table = new SOAController.SOAWrapperTable( 'test',
                                                       new List<c2g__codaTransactionLineItem__c>{ tli },
                                                       new Map<Id, c2g__codaInvoice__c>{ tr.Id => si },
                                                       true,
                                                       1 );
            table = new SOAController.SOAWrapperTable( 'test',
                                                       new List<c2g__codaInvoice__c>{ si },
                                                       new Map<Id, List<c2g__codaTransactionLineItem__c>>{ si.Id => new List<c2g__codaTransactionLineItem__c>{ tli } },
                                                       true,
                                                       2 );

            line = new SOAController.SOAWrapperLine( tli,
                                                     '1',
                                                     new Map<Id, c2g__codaInvoice__c>{ tr.Id => si } );
            line = new SOAController.SOAWrapperLine( tli,
                                                     '2',
                                                     new Map<Id, c2g__codaInvoice__c>{ tr.Id => si } );
            line = new SOAController.SOAWrapperLine( tli,
                                                     '3',
                                                     new Map<Id, c2g__codaInvoice__c>{ tr.Id => si } );
        Test.stopTest();
    }

}