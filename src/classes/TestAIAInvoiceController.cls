@isTest
private class TestAIAInvoiceController {
    private static final String FAKE_ID = '000000000000';
    private static final Integer NUMBER_TO_CREATE = 1;
    private static AIAInvoiceController controller;
    private static User projectManager;
    private static Account account;
    private static Contact contact;
    private static Project_Profile__c project;
    private static Proposal__c proposal;
    private static List<Change_Order__c> changeOrders;
    private static List<Service_Item__c> services;
    private static List<Billing_Line_Item__c> blis;
    private static List<Pro_forma_Invoice__c> pfis;

    private static void setUpControllerAndInitiliazePage( Id pfiIdToUse ) {
        Test.setCurrentPageReference(Page.AIAInvoice);
        if( pfiIdToUse != null ) {
            ApexPages.currentPage().getParameters().put( 'p', pfiIdToUse );
        }
        controller = new AIAInvoiceController();
    }

    private static void setupData( String billingMethod ) {
        projectManager = TestingUtils.userWithProfile( UserServices.PROFILE_PROJECT_MANAGER_2 );
        account = TestingUtils.createAccountList( NUMBER_TO_CREATE, 'TestAcc', true )[0];
        contact = TestingUtils.createContactList( NUMBER_TO_CREATE, account.Id, false )[0];
        contact.FirstName = 'Test';
        INSERT contact;

        proposal = TestingUtils.createProposalListForTest( NUMBER_TO_CREATE, true)[0];

        project = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE, account.Id, contact.Id, account.Id, contact.Id,
                                                         account.Id, contact.Id, projectManager.Id, false )[0];
        project.Billing_Method__c = billingMethod;
        if( billingMethod == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
            project.Interval__c = false;
        }
        if( billingMethod == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
            project.Frequency__c = ProjectProfileServices.FREQUENCY_MONTHLY;
            project.Billing_Day__c = '1';
        }
        INSERT project;

        project.Proposal__c = proposal.Id;

        update project;

        changeOrders = TestingUtils.createChangeOrderList( 2*NUMBER_TO_CREATE, false );
        for( Change_Order__c co : changeOrders ) {
            co.Project_Profile__c = project.Id;
            co.Services_Total__c = 0;
        }
        changeOrders[0].Status__c = ChangeOrderServices.STATUS_APPROVED;
        changeOrders[1].Status__c = ChangeOrderServices.STATUS_DRAFT;
        INSERT changeOrders;

        services = TestingUtils.createServiceItemList( 9*NUMBER_TO_CREATE, false );
        for( Service_Item__c si : services ) {
            si.Project_Profile__c = project.Id;
            si.Quantity__c = 1;
            si.Tax_Percent_1__c = 0;
            si.Tax_Percent_2__c = 0;
        }
        services[0].Original__c = true; services[0].Is_Amendmend_Deleted__c = true; services[0].Change_Order__c = changeOrders[1].Id;
        services[1].Original__c = true; services[1].Change_Order__c = changeOrders[0].Id; services[1].Quantity_Old__c = 2; // any value > 1
        services[2].Original__c = true; services[2].Change_Order__c = changeOrders[1].Id; services[2].Quantity_Old__c = 2; // any value > 1
        services[3].Original__c = true; services[3].Change_Order__c = changeOrders[1].Id;
        services[4].Is_Amendmend_Deleted__c = true; services[4].Change_Order__c = changeOrders[1].Id;
        services[5].Change_Order__c = changeOrders[0].Id;
        services[6].Change_Order__c = changeOrders[1].Id; services[6].Quantity_Old__c = 2; // any value > 1
        services[7].Original__c = true;
        services[8].Is_Amendmend_Deleted__c = true; services[8].Change_Order__c = changeOrders[0].Id; // should not be in AIA Invoice
        INSERT services;

        pfis = TestingUtils.createProFormaInvoiceList( 2*NUMBER_TO_CREATE, account.Id, contact.Id, null, false );
        for( Pro_forma_Invoice__c pfi : pfis ) {
            pfi.Project_Profile__c = project.Id;
        }
        INSERT pfis;

        blis = TestingUtils.createBillingLineItemList( 4*NUMBER_TO_CREATE, project.Id, account.Id, contact.Id, false );
        for( Billing_Line_Item__c bli : blis ) {
            bli.Project_Profile__c = project.Id;
            bli.Amount__c = 10; // any value;
        }
        blis[0].Service_Item__c = services[0].Id; blis[0].Pro_forma_Invoice__c = pfis[0].Id; blis[0].isReimbursable__c = true;
        blis[1].Service_Item__c = services[1].Id; blis[1].Pro_forma_Invoice__c = pfis[1].Id; blis[1].isReimbursable__c = true;
        blis[2].Service_Item__c = services[2].Id; blis[2].Pro_forma_Invoice__c = pfis[0].Id;
        blis[3].Service_Item__c = services[3].Id; blis[3].Pro_forma_Invoice__c = pfis[1].Id;
        INSERT blis;

    }

    @isTest static void initWithErrors() {
        Test.startTest();
            //test with fake id
            setUpControllerAndInitiliazePage( null );
            
            System.assert(ApexPages.hasMessages());
            System.assert(! controller.isValid);

            
            setUpControllerAndInitiliazePage( Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix() + FAKE_ID );
            System.assert(ApexPages.hasMessages());
            System.assert(! controller.isValid);

            //test with no project and billing line item
            setupData( ProjectProfileServices.BILLINGMETHODMILESTONE );
            DELETE blis;
            DELETE project;
            setUpControllerAndInitiliazePage( pfis[0].Id );

            System.assert(ApexPages.hasMessages());
            System.assert(! controller.isValid);
        Test.stopTest();
    }

    @isTest static void testASRRControllerWithProjectMilestone() {
        setupData( ProjectProfileServices.BILLINGMETHODMILESTONE );
        
        Test.startTest();
            setUpControllerAndInitiliazePage( pfis[0].Id );
        Test.stopTest();

        System.assert(controller.isValid);
        System.assert(controller.content != null);
    }

    @isTest static void testASRRControllerWithProjectInstallment() {
        setupData( ProjectProfileServices.BILLINGMETHODINSTALLMENT );
        
        Test.startTest();
            setUpControllerAndInitiliazePage( pfis[0].Id );
        Test.stopTest();

        System.assert(controller.isValid);
        System.assert(controller.content != null);
    }

    @isTest static void testASRRControllerWithProjectPercentage() {
        setupData( ProjectProfileServices.BILLINGMETHODPERCENTAGE );
        
        Test.startTest();
            setUpControllerAndInitiliazePage( pfis[0].Id );
        Test.stopTest();

        System.assert(controller.isValid);
        System.assert(controller.content != null);        
    }

}