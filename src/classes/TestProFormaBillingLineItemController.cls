@isTest
private class TestProFormaBillingLineItemController {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PHASE = 4;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
    private static final String TEST_INVOICE_FORMAT = 'Standard';
    private static final String TEST_FLOOR_VALUE = '1';
    private static final String DAY_OF_WEEK_TODAY = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('EEEE');
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                    ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Phase__c> testPhaseList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static List<Pro_forma_Invoice__c> testProformaInvoiceList;
    private static PageReference testPage;
    private static ProFormaBillingLineItemController testController;
    private static User projectManagerUser;
    private static User partnerUser;

    private static void setupData (){
        Id testUserId = UserInfo.getUserId();
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        //create Accounts for test
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        //create Contacts with accounts for test
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        //create Region, Municipality, Building, Phases for test
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, true);
        //create Proposal for test
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE_PROJECT_PROFILE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, testUserId, projectManagerUser.Id, true);
        //create Project Profile for test
        testProjectProfileList = new List<Project_Profile__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( 1, testAccountList[0].Id,
                                                                                                testContactWithAccountList[0].Id, testAccountList[0].Id,
                                                                                                testContactWithAccountList[0].Id, testAccountList[0].Id,
                                                                                                testContactWithAccountList[0].Id, projectManagerUser.Id, false)){

                projectProfileItem.Proposal__c = proposalItem.Id;
                projectProfileItem.Frequency__c = DateUtils.WEEKLY;
                projectProfileItem.Billing_day__c = DAY_OF_WEEK_TODAY;
                projectProfileItem.Invoice_Format__c = TEST_INVOICE_FORMAT;
                projectProfileItem.Floor_s__c = TEST_FLOOR_VALUE;
                projectProfileItem.Account_Executive__c = testUserId;
                projectProfileItem.No_Document_Shredding__c = false;
                testProjectProfileList.add(projectProfileItem);
            }
        }
        insert testProjectProfileList;

        Map<Id, Proposal__c> temporaryPrfopoaslMap = new Map<Id, Proposal__c>(testProposalList);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
             temporaryPrfopoaslMap.get(projectProfileItem.Proposal__c).Project_Profile__c = projectProfileItem.Id;
        }
        update testProjectProfileList;
    }

    private static void prepareData(){
        testPhaseList = new List<Phase__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Project_Profile__c = projectProfileItem.Id;
                phaseItem.Proposal__c = projectProfileItem.Proposal__c;
                testPhaseList.add(phaseItem);
            }
        }
        insert testPhaseList;
        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Project_Profile__c = phaseItem.Project_Profile__c;
                serviceItem.Proposal__c = phaseItem.Proposal__c;
                serviceItem.Phase__c = phaseItem.Id;
                testServiceItemList.add(serviceItem);
            }
        }
        insert testServiceItemList;
        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, serviceItem.Project_Profile__c,
                                                                                                testAccountList[0].Id, testContactWithAccountList[0].Id, false)){
                billingLineItem.Phase__c = serviceItem.Phase__c;
                billingLineItem.Project_Profile__c = serviceItem.Project_Profile__c;
                billingLineItem.Service_Item__c = serviceItem.Id;
                billingLineItem.Project_Address__c = testBuildingList[0].Id;
                billingLineItem.Milestone_Date__c = Date.today();
                billingLineItem.Billed__c = false;
                billingLineItem.isReimbursable__c = true;
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;
    }

    private static void preparePageController (){
        if ( MilroseSetting__c.getInstance('Number_of_Rows_in_Proforma_Generator') == null ){
            insert new MilroseSetting__c(Name = 'Number_of_Rows_in_Proforma_Generator', Custom_Number__c = 500);
        }
        testPage = Page.ProFormaBillingLineItem;
        Test.setCurrentPage(testPage);
        testController = new ProFormaBillingLineItemController();
    }

    private static testmethod void testCreatePage (){
        setupData();
        Test.startTest();
            preparePageController();
        Test.stopTest();

        System.assert (String.isEmpty(testController.billingClientCompanyFilter));
        System.assert (String.isEmpty(testController.accountingContactCompanyFilter));
        System.assert (String.isEmpty(testController.projectNumberFilter));
        System.assert (String.isEmpty(testController.projectAddressFilter));
        System.assert (String.isEmpty(testController.billingMethodFiltr));
        System.assert (String.isEmpty(testController.serviceNameFilter));
        System.assert (String.isEmpty(testController.poFilter));
        System.assert (!testController.billingMethodOptions.isEmpty());
    }

    private static testmethod void testSearchActionWithoutBillingLineItem (){
        setupData();
        preparePageController();

        testController.billingClientCompanyFilter = '';
        testController.accountingContactCompanyFilter = '';
        testController.projectNumberFilter = '';
        testController.projectAddressFilter = '';
        testController.billingMethodFiltr = '';
        testController.serviceNameFilter = '';
        testController.poFilter = '';
        testController.isReimbursables = true;

        Test.startTest();
            testController.searchAction();
        Test.stopTest();

        System.assert (testController.billingLineItemList.isEmpty());
    }

    private static testmethod void testSearchActionWithBillingLineItem (){
        setupData();
        prepareData();
        preparePageController();

        System.assert(testController != null);

        testController.billingClientCompanyFilter = '';
        testController.accountingContactCompanyFilter = '';
        testController.projectNumberFilter = '';
        testController.projectAddressFilter = '';
        testController.billingMethodFiltr = '';
        testController.serviceNameFilter = '';
        testController.poFilter = '';
        testController.isReimbursables = true;

        Test.startTest();
            testController.searchAction();
        Test.stopTest();

//      System.assert (!testController.billingLineItemList.isEmpty());
//      System.assertEquals (testBillingLineItemList.size(), testController.billingLineItemList.size());
    }

    private static testmethod void testGenerateInvoicesAction (){
        setupData();
        prepareData();
        preparePageController();
/*
        testController.billingClientCompanyFilter = '';
        testController.accountingContactCompanyFilter = '';
        testController.projectNumberFilter = '';
        testController.projectAddressFilter = '';
        testController.billingMethodFiltr = '';
        testController.serviceNameFilter = '';
        testController.poFilter = '';
*/
        System.assert(testController != null);

        testController.isReimbursables = true;

        testController.searchAction();

        for (BillingLineItemWrapper bliWrapper : testController.billingLineItemList){
            bliWrapper.selected = true;
        }

        Test.startTest();
//            testController.generateInvoicesAction();
        Test.stopTest();
/*
        testProformaInvoiceList = [ SELECT Id, Project_Profile__c
                                    FROM Pro_forma_Invoice__c
                                    WHERE Project_Profile__c IN : testProjectProfileList];
        System.assert (!testProformaInvoiceList.isEmpty());
        System.assertEquals (NUMBER_TO_CREATE_PROJECT_PROFILE, testProformaInvoiceList.size());
        testBillingLineItemList = [ SELECT Id, Pro_forma_Invoice__c, Billed__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id IN : testBillingLineItemList];
        for (Billing_Line_Item__c bli : testBillingLineItemList){
            System.assert (bli.Pro_forma_Invoice__c != null);
            System.assert (bli.Billed__c != null);
        }
*/
    }

    private static testmethod void testIsGenerateInvoicesForPartnerUser (){
        setupData();
        Boolean result;
        System.runAs(partnerUser){
            preparePageController();

            Test.startTest();
                result = testController.isGenerateInvoices;
            Test.stopTest();
        }

        System.assert (!result);
    }

    private static testmethod void testIsGenerateInvoicesForProjectManagerUser (){
        setupData();
        Boolean result;
        System.runAs(projectManagerUser){
            preparePageController();

            Test.startTest();
                result = testController.isGenerateInvoices;
            Test.stopTest();
        }

        System.assert (result);
    }

    private static testmethod void testSortAction (){
        setupData();
        prepareData();
        preparePageController();

        testController.billingClientCompanyFilter = '';
        testController.accountingContactCompanyFilter = '';
        testController.projectNumberFilter = '';
        testController.projectAddressFilter = '';
        testController.billingMethodFiltr = '';
        testController.serviceNameFilter = '';
        testController.poFilter = '';
        testController.isReimbursables = true;

        testController.billingLineItemList = new List<BillingLineItemWrapper>();

        for (Billing_Line_Item__c billingLineItem : testBillingLineItemList){
            testController.billingLineItemList.add (new BillingLineItemWrapper (billingLineItem) );
        }

        System.assert(testController != null);

        Test.startTest();
            testController.searchAction();
            testController.getPicklistValuesAsSelectOptions(Billing_Line_Item__c.getSObjectType(), 'Project_Profile__c', '');
            testController.sortAction();
            Boolean testBoolean = testController.hasNext;
            System.assert(! testBoolean);

            testBoolean = testController.hasPrevious;
            
            Integer testInteger = testController.pageNumber;
            testController.previous();
            testController.next();
        Test.stopTest();
    }
}