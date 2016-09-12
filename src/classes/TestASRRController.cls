@isTest
private class TestASRRController {
    private static final Integer NUMBER_TO_CREATE = 1;
    private static ASRRController controller;
    private static User projectManager;
    private static Account account;
    private static Contact contact;
    private static Project_Profile__c project;
    private static Change_Order__c changeOrder;
    private static List<Service_Item__c> services;
    private static List<Billing_Line_Item__c> blis;
    private static List<Phase__c> phases;
    private static Pro_forma_Invoice__c pfi;

    private static void setUpControllerAndInitiliazePage( Id projectIdToUse ) {
        Test.setCurrentPageReference(Page.ASRR);
        if( projectIdToUse != null ) {
            ApexPages.currentPage().getParameters().put( 'p', projectIdToUse );
        }
        controller = new ASRRController();
    }

    private static void setupData( String billingMethod ) {

        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true)[0];

        projectManager = TestingUtils.userWithProfile( UserServices.PROFILE_PROJECT_MANAGER_2 );
        account = TestingUtils.createAccountList( NUMBER_TO_CREATE, 'TestAcc', true )[0];
        contact = TestingUtils.createContactList( NUMBER_TO_CREATE, account.Id, false )[0];
        contact.FirstName = 'Test';
        INSERT contact;

        Building__c building = TestingUtils.createBuildingList (1, null, null, null, null, null, true)[0];
        Building_AKA__c bAKA = new Building_AKA__c(Building__c=building.Id);
        INSERT bAKA;

        project = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE, account.Id, contact.Id, account.Id, contact.Id,
                                                         account.Id, contact.Id, projectManager.Id, false )[0];
        project.Building_AKA__c = bAKA.Id;
        project.Billing_Method__c = billingMethod;
        if( billingMethod == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
            project.Interval__c = false;
        }
        if( billingMethod == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
            project.Frequency__c = ProjectProfileServices.FREQUENCY_MONTHLY;
            project.Billing_Day__c = '1';
        }
        INSERT project;

        changeOrder = TestingUtils.createChangeOrderList( NUMBER_TO_CREATE, false )[0];
        changeOrder.Status__c = ChangeOrderServices.STATUS_APPROVED;
        INSERT changeOrder;

        phases = TestingUtils.createPhaseList( 2*NUMBER_TO_CREATE, false );
        phases[0].Number__c = 1;
        phases[1].Number__c = 2;
        INSERT phases;

        services = TestingUtils.createServiceItemList( 2*NUMBER_TO_CREATE, false );
        services[0].Project_Profile__c = project.Id;
        services[0].Is_Amendmend_Deleted__c = false;
        services[0].Original__c = true;
        services[0].Phase__c = phases[0].Id;
        services[0].Proposal__c = proposal.Id;
        services[1].Project_Profile__c = project.Id;
        services[1].Change_Order__c = changeOrder.Id;
        services[1].Phase__c = phases[1].Id;
        services[1].Proposal__c = proposal.Id;
        INSERT services;

        pfi = TestingUtils.createProFormaInvoiceList( NUMBER_TO_CREATE, account.Id, contact.Id, null, false )[0];
        pfi.Project_Profile__c = project.Id;
        INSERT pfi; 

        blis = TestingUtils.createBillingLineItemList( 3*NUMBER_TO_CREATE, project.Id, account.Id, contact.Id, false );
        blis[0].isReimbursable__c = true;
        blis[1].isReimbursable__c = false;
        blis[1].Service_Item__c = services[1].Id;
        blis[2].isReimbursable__c = false;
        blis[2].Service_Item__c = null;
        blis[2].Project_Profile__c = pfi.Project_Profile__c;
        blis[2].Pro_forma_Invoice__c = pfi.Id;
        INSERT blis;

    }

    @isTest static void testUncoveredParts() {
        setupData( ProjectProfileServices.BILLINGMETHODPERCENTAGE );
        
        Test.setCurrentPageReference(Page.ASRR);
        ApexPages.currentPage().getParameters().put( 'p', project.Id );

        ApexPages.currentPage().getParameters().put( 'renderAs', 'pdf' );
        ApexPages.currentPage().getParameters().put( 'page', 'true' );
        ApexPages.currentPage().getParameters().put( 'detail', 'true' );
        ApexPages.currentPage().getParameters().put( 'type', 'new' );
        ApexPages.currentPage().getParameters().put( 'inv', pfi.Id );
        ApexPages.currentPage().getParameters().put( 'ppr', '' );
        ApexPages.currentPage().getParameters().put( 'bc', '' );
        controller = new ASRRController();

        String address1 = controller.address1;
        String address2 = controller.address2;
        String milroseLogoIdExternalUrl = controller.milroseLogoIdExternalUrl;

        Boolean showAmountBilled = controller.content.tables[0].showAmountBilled;
        Boolean showAmountPaid = controller.content.tables[0].showAmountPaid;
        Boolean showAmountDue = controller.content.tables[0].showAmountDue;
        Boolean showBalanceToBill = controller.content.tables[0].showBalanceToBill;

        Boolean showMunicipalAgency = controller.content.tables[0].sections[0].lines[0].showMunicipalAgency;
        Boolean showInvoiceNumbers = controller.content.tables[0].sections[0].lines[0].showInvoiceNumbers;
        Boolean showInvoiceDates = controller.content.tables[0].sections[0].lines[0].showInvoiceDates;
        Boolean showParentName = controller.content.tables[0].sections[0].lines[0].showParentName;
        Boolean showClientProject = controller.content.tables[0].sections[0].lines[0].showClientProject;
        Boolean showAmounts = controller.content.tables[0].sections[0].lines[0].showAmounts;
    }

    @isTest static void initWithErrors() {
        Test.startTest();
            //test null id
            setUpControllerAndInitiliazePage( null );
           
            System.assert(ApexPages.hasMessages());
            System.assert(! controller.isValid);

            //test with wrong project id
            setupData( null );
            Id deletedProjectId = project.Id;
            DELETE blis;
            DELETE project;
            setUpControllerAndInitiliazePage( deletedProjectId );

            System.assert(ApexPages.hasMessages());
            System.assert(! controller.isValid);

        Test.stopTest();
    }
    
    @isTest static void testASRRControllerWithProjectPercentage() {
        setupData( ProjectProfileServices.BILLINGMETHODPERCENTAGE );

        Test.startTest();
            setUpControllerAndInitiliazePage( project.Id );
        Test.stopTest();

        System.assert(! ApexPages.hasMessages());
        System.assert(controller.isValid);
        System.assert(controller.parent.Id == project.Id);
        System.assert(controller.content != null);
    }

    @isTest static void testASRRControllerWithProjectInstallment() {
        setupData( ProjectProfileServices.BILLINGMETHODINSTALLMENT );

        Test.startTest();
            setUpControllerAndInitiliazePage( project.Id );
        Test.stopTest();

        System.assert(! ApexPages.hasMessages());
        System.assert(controller.isValid);
        System.assert(controller.parent.Id == project.Id);
        System.assert(controller.content != null);
    }

    
}