@isTest
private class TestMassSendInvoiceContExt {
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_PROFORMA_INVOICE = 3;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Pro_forma_Invoice__c> testProFormaInvoiceList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static List <Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOption;
    private static List <Loop__DDP__c> testLoopDDP;

    private static PageReference testPage;
    private static MassSendInvoiceContExt testController;
    private static ApexPages.StandardSetController testStandardController;

//    private static ApexPages.StandardSetController testController;
//    private static MassSendInvoiceContExt testMassSendInvoiceContExt;

    private static ApexPages.StandardController stdController;
    private static Pro_forma_invoice__c invoice;
    private static final Integer NUMBER_TO_CREATE = 4;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProjectProfile;
    private static Building__c testBuilding;

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(numberToCreate, doInsert);
    }

    private static void prepareDataForTest() {
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false);
        testLoopDDP[0].Name = 'Create Invoices';
        insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(1, testLoopDDP[0].Id, false);
        testLoopDDPIntegrationOption[0].Name = 'Attach';
        insert testLoopDDPIntegrationOption;
        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PROFORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
        }
        insert testProFormaInvoiceList;
        system.debug('testProFormaInvoiceList: ' + testProFormaInvoiceList);
    }

    private static void preparePageController (List<Pro_forma_Invoice__c> proformaInvoiceList){
        testPage = Page.MassSendInvoiceAttach;
        Test.setCurrentPage(testPage);
        if (proformaInvoiceList != null){
            Set<Id> idSet = new Set<Id>();
            for(Pro_forma_Invoice__c pfi : proformaInvoiceList) {
                idSet.add(pfi.Id);
            }
            List<Pro_forma_Invoice__c> invoiceList = [SELECT Id FROM Pro_forma_Invoice__c WHERE Id IN : idSet];
            testStandardController = new ApexPages.StandardSetController(invoiceList);
            testController = new MassSendInvoiceContExt(testStandardController);
        }
    }

    private static testmethod void testInitMassSendInvoiceContExt(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        Test.startTest();
            preparePageController(testProFormaInvoiceList);
        Test.stopTest();

        System.assert(testController != null);
    }
/*
    private static testmethod void testGetProFormaInvoices() {
        testInitMassSendInvoiceContExt(); 
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.getProFormaInvoices();
        System.assertEquals(testController.proFormaInvoiceIdSet.isEmpty(), true);
        System.assertEquals(testController.proFormaInvoiceMap.isEmpty(), true);
        Set<String> idSet = new Set<String>();
        for(Pro_forma_Invoice__c pfi : testProFormaInvoiceList) {
            idSet.add(pfi.Id);
        }
        testController.proFormaInvoiceIdSet = idSet;
        testController.getProFormaInvoices();      
        
    }

    private static testmethod void testAfterCreated() {
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.proFormaInvoiceCreatedId = testProFormaInvoiceList[0].Id;
        testController.getProFormaInvoices();
        testController.proFormaInvoiceList = testProFormaInvoiceList;
        testController.afterCreated();
        System.assertEquals(testController.action, 'runDDP');
    }  
    
    private static testmethod void testRunDDP() {
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);
        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;        
        testController.proFormaInvoiceCreatedId = testProFormaInvoiceList[0].Id;
        testController.getProFormaInvoices();
        testController.proFormaInvoiceList = testProFormaInvoiceList;
        testController.proFormaInvoiceId = testProFormaInvoiceList[0].id;  
        Set<String> idSet = new Set<String>();
        for(Pro_forma_Invoice__c pfi : testProFormaInvoiceList) {
            idSet.add(pfi.Id);
        }
        testController.proFormaInvoiceIdSet = idSet;               
        testController.getProFormaInvoices();    
        testController.runDDP();
    }     
    
    private static testmethod void testCreateUrl() {
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);
        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;        
        testController.getProFormaInvoices(); 
        testController.proFormaInvoiceId = testProFormaInvoiceList[0].Id;
        testController.storedDocumentIdSet = testController.proFormaInvoiceIdSet;
        testController.proFormaInvoiceIdCreatedSet = testController.proFormaInvoiceIdSet;
        testController.getProFormaInvoices(); 
        testController.createUrl(false);
    }

    private static testmethod void testAutorun() {
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);
        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;
        Set<String> idSet = new Set<String>();
        List<Pro_forma_Invoice__c> proFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for(Pro_forma_Invoice__c pfi : testProFormaInvoiceList) {
            idSet.add(pfi.Id);
            proFormaInvoiceList.add(pfi);
            break;
        }
        testController.proFormaInvoiceIdSet = idSet;        
        testController.proFormaInvoiceList = proFormaInvoiceList;
        
        testController.Autorun();
        testController.deliveryOption = 'Email';
        testController.action = 'autorunCompite';
        testController.proFormaInvoiceIdSet = new Set<String>();
        testController.proFormaInvoiceList = new List<Pro_forma_Invoice__c>(); 
        testController.Autorun();
    }

    private static testmethod void testResponseAction() {
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);

        testPage = Page.MassSendInvoiceAttach;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('response', 'response=action=afterCreatedsubDelimsproFormaInvoiceCreatedId=a3WJ0000000Dpq6MACsubDelimsproFormaInvoiceIdSet=a3WJ0000000Dpq6MAC,a3WJ0000000DpqBMAS,a3WJ0000000Dpq9MAC,a3WJ0000000Dpq7MAC,a3WJ0000000DpqAMAS,a3WJ0000000DpqEMAS,a3WJ0000000DpqCMAS,a3WJ0000000Dpq8MAC,a3WJ0000000DpqDMASsubDelimsproFormaInvoiceIdCreatedSet=a3WJ0000000Dpq6MACsubDelimsdeliveryOption=AttachsubDelimsddpHelperId=a3fJ0000000BYXIIA4 storedDocumentIdSetsubDelimsstoredDocumentIdSet=test');
        if (testProFormaInvoiceList != null){
            Set<Id> idSet = new Set<Id>();
            for(Pro_forma_Invoice__c pfi : testProFormaInvoiceList) {
                idSet.add(pfi.Id);
            }
            List<Pro_forma_Invoice__c> invoiceList = [SELECT Id FROM Pro_forma_Invoice__c WHERE Id IN : idSet];
            testStandardController = new ApexPages.StandardSetController(invoiceList);
            testController = new MassSendInvoiceContExt(testStandardController);
        }
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;
        testController.proFormaInvoiceList = testProFormaInvoiceList;       
        testController.responseAction();
    }    

    private static testmethod void testSendPdf() {
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false);
        testLoopDDP[0].Name = 'Join Invoices Together';
        insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(1, testLoopDDP[0].Id, false);
        testLoopDDPIntegrationOption[0].Name = 'Email';
        insert testLoopDDPIntegrationOption; 
        
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;
        testController.proFormaInvoiceList = testProFormaInvoiceList;
        testController.sendPdf();
    } 

    private static testmethod void testDownloadPdf() {
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false);
        testLoopDDP[0].Name = 'Join Invoices Together';
        insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(1, testLoopDDP[0].Id, false);
        testLoopDDPIntegrationOption[0].Name = 'Download';
        insert testLoopDDPIntegrationOption; 
        
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;
        testController.proFormaInvoiceList = testProFormaInvoiceList;
        testController.downloadPdf();
    }      

    private static testmethod void testChangeStoreDocumentParentId() {       
        testInitMassSendInvoiceContExt();
        System.assert(testController != null);

        testController.deliveryOption = 'Attach';
        testController.deliveryOption = testController.deliveryOption;
        testController.proFormaInvoiceList = testProFormaInvoiceList;
        testController.getProFormaInvoices();        
        testController.changeStoreDocumentParentId(testProFormaInvoiceList[0].Id);
    }          
*/
    private static testMethod void testUpdateInvoiceBLIDataForPDF() {
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'testAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        testProjectProfile = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, null, null, null, null, null, null, null, false)[0];
        testProjectProfile.Billing_Company_Name__c = testAccount.Id;
        testProjectProfile.Billing_Company_Contact__c = testContact.id;
        testProjectProfile.Billing_Method__c = 'Installment';
        testProjectProfile.Frequency__c = 'Monthly';
        testProjectProfile.Billing_day__c = '1';
        insert testProjectProfile;
            
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, null, 'TestStreet', '5', 'TestCity', '79000', true)[0];

        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for(Pro_forma_Invoice__c pfi : TestingUtils.createProFormaInvoiceList(5, null, null, null, false)) {
            pfi.Project_Profile__c = testProjectProfile.Id;
            testProFormaInvoiceList.add(pfi);
        }
        insert testProFormaInvoiceList;

//        testProFormaInvoice = TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE, testAccount.Id, testContact.Id, testBuilding.Id, false)[0];

        List<Billing_Line_Item__c> billingLineItemList = TestingUtils.createBillingLineItemList(4, testProjectProfile.Id, null, null, false);
        List<Mailroom__c> mailroomList = TestingUtils.createMailRoomList(4, true);
        List<Pro_forma_Invoice__c> proformaImvoiceList = [SELECT Id, Billing_Contact__c, Sales_Invoice__c, Project_Profile__c,
                                                                cl_FF_Sales_Credit_Note_1__c, cl_FF_Sales_Credit_Note_2__c, cl_Create_FFA_Invoice__c, cl_FFA_Invoice_Created__c
                                                          FROM Pro_forma_Invoice__c
                                                          WHERE Id IN : testProFormaInvoiceList];

        billingLineItemList[0].Mailroom__c = mailroomList[0].Id;
        billingLineItemList[1].Mailroom__c = mailroomList[1].Id;
        billingLineItemList[2].Mailroom__c = mailroomList[2].Id;
        billingLineItemList[3].Mailroom__c = mailroomList[3].Id;
        insert billingLineItemList;
        set<Id> bLIIdSet = new set<Id>();
        for(Billing_Line_Item__c bli : billingLineItemList) {
            bLIIdSet.add(bli.Id);
        }
        billingLineItemList = [SELECT ID, Mailroom__c, Reimbursable_Type__c, Pro_forma_Invoice__c, Mailroom__r.COSTCATID_Service_Type__c From Billing_Line_Item__c WHERE Id IN : bLIIdSet];
        billingLineItemList[0].Mailroom__r.COSTCATID_Service_Type__c = 'FED EX';
        billingLineItemList[0].Pro_forma_Invoice__c = proformaImvoiceList[0].Id;
        billingLineItemList[1].Mailroom__r.COSTCATID_Service_Type__c = 'MESS';
        billingLineItemList[1].Pro_forma_Invoice__c = proformaImvoiceList[1].Id;
        billingLineItemList[2].Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING;
        billingLineItemList[2].Pro_forma_Invoice__c = proformaImvoiceList[2].Id;
        billingLineItemList[3].Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING;
        billingLineItemList[3].Pro_forma_Invoice__c = proformaImvoiceList[3].Id;
        system.debug('billingLineItemList: ' + billingLineItemList);
        update billingLineItemList;

        testStandardController = new ApexPages.StandardSetController(proformaImvoiceList);
        testController = new MassSendInvoiceContExt(testStandardController);
        System.assert(testController != null);
        
        testController.updateInvoiceBLIDataForPDF();
    }
}