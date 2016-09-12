@isTest(SeeAllData=true)
private class TestAccountReportController {
    private static final Integer NUMBER_TO_CREATE = 1;
    private static ApexPages.StandardController controller;
    private static AccountReportController reportController;
    private static Account testAccount;
    private static Contact testContact;
    private static User projectManager;
    private static Project_Profile__c testProject;
    private static Proposal__c testProposal;
    private static Loop__DDP_Integration_Option__c testLoopDDpIntegrationOption;
    private static Loop__DDP__c testLoopDDP;
    private static c2g__codaTransactionLineItem__c testTransactionLineItem;
    private static c2g__codaCompany__c testCompany;
    private static Pro_forma_Invoice__c testInvoice;
    private static c2g__codaInvoice__c salesInvoice;

    private static void setUp(){        
        projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);

        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAcc', false)[0];
        testAccount.A_R_coordinator__c = projectManager.Id;
        INSERT testAccount;

        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];

        testProposal = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE, false)[0];
        testProposal.Billing_Company_Name__c = testAccount.Id;
        testProposal.Billing_Company_Contact__c = testContact.Id;
        testProposal.Accounting_Contact_Company__c = testAccount.Id;
        testProposal.Accounting_Contact__c = testContact.Id;
        INSERT testProposal;

        testProject = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE,
                                                             testAccount.Id,
                                                             testContact.Id,
                                                             testAccount.Id,
                                                             testContact.Id,
                                                             testAccount.Id,
                                                             testContact.Id,
                                                             projectManager.Id,
                                                             false)[0];
        testProject.Billing_Company_Name__c = testAccount.Id;  
        testProject.Billing_Company_Name__c = testAccount.Id;
        testProject.Billing_Company_Contact__c = testContact.Id;
        testProject.Accounting_Contact_Company__c = testAccount.Id;
        testProject.Accounting_Contact__c = testContact.Id;  
        testProject.Primary_Company_Name__c = testAccount.Id;
        testProject.Proposal__c = testProposal.Id;
        INSERT testProject;

        testProposal.Project_Profile__c = testProject.Id;
        UPDATE testProposal;

        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, true)[0];                                                             
        testLoopDDpIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, true)[0];     

        testInvoice = TestingUtils.createProFormaInvoiceList(1, testAccount.Id, testContact.Id, null, false)[0];
        testInvoice.Project_Profile__c = testProject.Id;
        INSERT testInvoice;

        salesInvoice = TestingUtils.createSalesInvoiceList( 1, testAccount.Id, Date.today(), Date.today(), false)[0];
        salesInvoice.Billing_Company_Reference__c = testAccount.Id;
        salesInvoice.c2g__Account__c = testAccount.Id;
        salesInvoice.c2g__InvoiceStatus__c = 'In Progress';
        INSERT salesInvoice;

        testInvoice.Sales_Invoice__c = salesInvoice.Id;
        UPSERT testInvoice;
    }
    
    private static void setUpControllerAndInitiliazePage(){        
        controller = new ApexPages.StandardController(testAccount);
        reportController = new AccountReportController();
    }

    @isTest static void testUncoveredPart() {
        setUp();
        Test.setCurrentPageReference(Page.AccountReport);
        
        System.runAs(projectManager) {
            Test.startTest();
                setUpControllerAndInitiliazePage();
        
                Boolean asrrRenderas = reportController.asrrRenderas;
                Boolean asrrDocStyle = reportController.asrrDocStyle;
                Boolean asrrLineDetail = reportController.asrrLineDetail;
                Boolean soaRenderas = reportController.soaRenderas;
                Boolean soaCombine = reportController.soaCombine;
                Boolean showProjectProfileBillingCompanyFiltersOnly = reportController.showProjectProfileBillingCompanyFiltersOnly;

                Map<Id, String> getFoundSoaReportsAccountIdToSingleLink = reportController.getFoundSoaReportsAccountIdToSingleLink();
                String getSoaReportSingleLink = reportController.getSoaReportSingleLink( testAccount.Id );
                String getFoundSoaReportsGroupLink = reportController.getFoundSoaReportsGroupLink();
                String getFoundSoaReportsGroupNames = reportController.getFoundSoaReportsGroupNames();
                String getLinkEnding = reportController.getLinkEnding();
                PageReference sendEmail = reportController.sendEmail();
                try { Map<Id, String> findProjects = reportController.findProjects( StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT ); } catch ( Exception ex ) {}
                List<selectOption> fulfillmentOfficeOption = reportController.fulfillmentOfficeOption;
                Boolean printAmName = reportController.printAmName;
                String fileDownloadIframeSrc = reportController.fileDownloadIframeSrc;
                reportController.asrHelper.Accounting_Company__c = testAccount.Id;
                PageReference generateAsr = reportController.generateAsr();
                PageReference generateSoa = reportController.generateSoa();

            Test.stopTest();
        }
    }
    
    private static testMethod void testAccountReportControllerIdParam(){
        setUp();
        Test.setCurrentPageReference(Page.AccountReport);
        ApexPages.currentPage().getParameters().put('c',testContact.Id);
        ApexPages.currentPage().getParameters().put('a',testAccount.Id);  
        ApexPages.currentPage().getParameters().put('c',testContact.Id); 
        
        System.runAs(projectManager) {
            Test.startTest();
                setUpControllerAndInitiliazePage();
                Pagereference pr = reportController.goBack();
                System.assert(pr.getUrl().contains(testContact.Id));
            Test.stopTest();
        }
    }

    private static testMethod void testAccountReportControllerNoParam(){
        setUp();
        Test.setCurrentPageReference(Page.AccountReport);
        
        System.runAs(projectManager) {
            Test.startTest();
                setUpControllerAndInitiliazePage();
                Pagereference pr = reportController.generateAsr();
                System.assert(pr == null);
            Test.stopTest();
        }
    }

    private static testMethod void testAutorun(){
        setUp();
        Test.setCurrentPageReference(Page.AccountReport);
        ApexPages.currentPage().getParameters().put('send',String.valueOf(true)) ;
        setUpControllerAndInitiliazePage();
        
        Test.startTest();
            PageReference pr = reportController.autorun();
            System.assert(pr == null);
        Test.stopTest();
        
    }
}