@isTest
private class TestProformaInvoiceServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PHASE = 4;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 5;
    private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUBMER_TO_CREATE_SALES_INVOICE = 5;
    private static final Integer NUBMER_TO_CREATE_TRANSACTION = 5;
    private static final Integer NUBMER_TO_CREATE_COMPANY = 5;
    private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
    private static final Decimal TOTAL_SERVICE_AMOUNT = 4.5;
    private static final Decimal BILLING_LINE_ITEM_QUANTITY = 3.4;
    private static final Decimal BILLING_LINE_ITEM_UNIT_PRICE = 1.3;
    private static final String TEST_INVOICE_FORMAT = 'Standard';
    private static final String TEST_FLOOR_VALUE = '1';
    private static final String DAY_OF_WEEK_TODAY = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('EEEE');
    private static final Double SERVICE_ITEM_SHREDDING_FEES_TEST_VALUE = 1.2;
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                   ProjectProfileServices.BILLINGMETHODPERCENTAGE};
    private static final String FIRST_QUARTERLY_MONTH_VALUE = '1st';
    private static final Decimal PURCHASE_ORDER_AMOUNT = 10000;

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
    private static User projectManagerUser;
    private static User partnerUser;
    private static List<c2g__codaInvoice__c> salesInvoiceList;
    private static List<c2g__codaTransactionLineItem__c> transActionLineItemList;
    private static List<c2g__codaCompany__c> testCompanyList;
    private static List<Task_Item__c> testTaskItemList;

    private static void setupData (List<String> billingMethodList){
        setupData(billingMethodList, DateUtils.WEEKLY);
    }

    private static void setupData (List<String> billingMethodList, String projectFrequencyValue){
        Id testUserId = UserInfo.getUserId();
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        //create Accounts for test
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        //create Contacts with accounts for test
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT,
                                                                    new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        //create Region, Municipality, Building, Phases for test
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, false);
        for(Building__c item : testBuildingList){
            item.Name = 'testBuilding';
        }
        insert testBuildingList;
        testProformaInvoiceList = TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testAccountList[0].Id, testContactWithAccountList[0].Id, testBuildingList[0].Id, false);
        testProposalList = new List<Proposal__c>();
        for (String stringItem : billingMethodList){
            for (Proposal__c proposalItem : TestingUtils.createProposalList (NUMBER_TO_CREATE_PROJECT_PROFILE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                                null, null, null, null, partnerUser.Id, testUserId, projectManagerUser.Id, false)){
                proposalItem.Billing_Method__c = stringItem;
                proposalItem.Frequency__c = projectFrequencyValue;
                if (projectFrequencyValue == DateUtils.WEEKLY){
                    proposalItem.Billing_day__c = DAY_OF_WEEK_TODAY;
                }
                if (projectFrequencyValue == DateUtils.MONTHLY){
                    proposalItem.Billing_day__c = String.valueOf(Date.today().day());
                }
                if (projectFrequencyValue == DateUtils.QUARTERLY){
                    proposalItem.Billing_day__c = String.valueOf(Date.today().day());
                    proposalItem.Quarterly_Month__c = FIRST_QUARTERLY_MONTH_VALUE;
                }
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;
        //create Project Profile for test
        testProjectProfileList = new List<Project_Profile__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( 1, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Proposal__c = proposalItem.Id;
                projectProfileItem.Frequency__c = projectFrequencyValue;
                if (projectFrequencyValue == DateUtils.WEEKLY){
                    projectProfileItem.Billing_day__c = DAY_OF_WEEK_TODAY;
                }
                if (projectFrequencyValue == DateUtils.MONTHLY){
                    projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                }
                if (projectFrequencyValue == DateUtils.QUARTERLY){
                    projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                    projectProfileItem.Quarterly_Month__c = FIRST_QUARTERLY_MONTH_VALUE;
                }
                projectProfileItem.Total_Service_Amount__c = TOTAL_SERVICE_AMOUNT;
                projectProfileItem.Invoice_Format__c = TEST_INVOICE_FORMAT;
                projectProfileItem.Floor_s__c = TEST_FLOOR_VALUE;
                projectProfileItem.Account_Executive__c = testUserId;
                projectProfileItem.Billing_Method__c = proposalItem.Billing_Method__c;
                projectProfileItem.Project_Name__c = 'TestProject';
                projectProfileItem.Building__c = testBuildingList[0].Id;
                testProjectProfileList.add(projectProfileItem);
            }
        }
        insert testProjectProfileList;

        Map<Id, Proposal__c> temporaryPrfoposalMap = new Map<Id, Proposal__c>(testProposalList);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
             temporaryPrfoposalMap.get(projectProfileItem.Proposal__c).Project_Profile__c = projectProfileItem.Id;
        }
        update testProjectProfileList;

        testPhaseList = new List<Phase__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Project_Profile__c = projectProfileItem.Id;
                phaseItem.Proposal__c = projectProfileItem.Proposal__c;
                testPhaseList.add(phaseItem);
            }
        }
    }

    private static void createServiceItem (Integer numberToCreate, List<Phase__c> phaseList){
        testServiceItemList = new List<Service_Item__c>();
        Proposal__c tempProposal = TestingUtils.createProposalListForTest(1, true)[0];
        for (Phase__c phaseItem : phaseList) {
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(numberToCreate, false)){
                serviceItemItem.Proposal__c = tempProposal.Id;
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Project_Profile__c = phaseItem.Project_Profile__c;
                testServiceItemList.add(serviceItemItem);
            }
        }
        INSERT testServiceItemList;
    }

    private static List<Billing_Line_Item__c> createBillingLineItem (Integer numberToCreate, List<Service_Item__c> serviceItemList, Boolean doInsert){
        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>(testProjectProfileList);

        List<Billing_Line_Item__c> resultBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Service_Item__c serviceItemItem : serviceItemList){
            Project_Profile__c projectProfileItem = projectProfileMap.get(serviceItemItem.Project_Profile__c);
            for (Billing_Line_Item__c billingLineItemItem : TestingUtils.createBillingLineItemList (numberToCreate,
                                                                                                    serviceItemItem.Project_Profile__c,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    false)){
                billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c).addDays(-1);
                billingLineItemItem.Project_Address__c = projectProfileItem.Building__c;
                billingLineItemItem.Service_Item__c = serviceItemItem.Id;
                billingLineItemItem.Phase__c = serviceItemItem.Phase__c;
                resultBillingLineItemList.add(billingLineItemItem);
            }
        }
        if(doInsert){
            insert resultBillingLineItemList;
        }

        return resultBillingLineItemList;
    }

//------------------------------------------test processProformaInvoices start------------------------------------------//

    //condition number 1:
    //Project's "Separate Reimbursables" = TRUE; "Do Not Bill Reimbursables Alone" = TRUE. two BLI regular and reimbursable
    //Result: 2 proforma invoices are generated
    private static testmethod void testProcessProformaInvoices1(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = true;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }
        //create 1 regular BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = false;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(2, testProformaInvoiceList.size());
    }

    //condition number 2:
    //Project's "Separate Reimbursables" = TRUE; "Do Not Bill Reimbursables Alone" = FALSE. two BLI regular and reimbursable
    //Result: 2 proforma invoices are generated
    private static testmethod void testProcessProformaInvoices2(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = true;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }
        //create 1 regular BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = false;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, false, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(2, testProformaInvoiceList.size());
    }

    //condition number 3:
    //Project's "Separate Reimbursables" = FALSE; "Do Not Bill Reimbursables Alone" = TRUE. two BLI regular and reimbursable
    //Result: 2 proforma invoices are generated
    private static testmethod void testProcessProformaInvoices3(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = false;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }
        //create 1 regular BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = false;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

    //condition number 4:
    //Project's "Separate Reimbursables" = FALSE; "Do Not Bill Reimbursables Alone" = FALSE. two BLI regular and reimbursable
    //Result: 2 proforma invoices are generated
    private static testmethod void testProcessProformaInvoices4(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = false;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }
        //create 1 regular BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = false;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, false, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

    //condition number 5:
    //Project's "Separate Reimbursables" = TRUE; "Do Not Bill Reimbursables Alone" = TRUE. one BLI reimbursable
    //Result: proforma invoices is not generated
    private static testmethod void testProcessProformaInvoices5(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = true;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            Project_Profile__c projectProfileItem = new Map<Id, Project_Profile__c>(testProjectProfileList).get(billingLineItemItem.Project_Profile__c);
            billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c);
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(testProformaInvoiceList.isEmpty());
    }

    //condition number 5:
    //Project's "Separate Reimbursables" = TRUE; "Do Not Bill Reimbursables Alone" = TRUE. one BLI reimbursable. Milestone Date field value is prev month Date.
    //Result: 1 proforma invoices is generated
    private static testmethod void testProcessProformaInvoices5PrevMonth(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = true;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            Project_Profile__c projectProfileItem = new Map<Id, Project_Profile__c>(testProjectProfileList).get(billingLineItemItem.Project_Profile__c);
            billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c).addMonths(-2).addDays(-5); //MRS 7461
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

    //condition number 6:
    //Project's "Separate Reimbursables" = TRUE; "Do Not Bill Reimbursables Alone" = FALSE. one BLI reimbursable
    //Result: 1 proforma invoices is generated
    private static testmethod void testProcessProformaInvoices6(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = true;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, false, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

    //condition number 7:
    //Project's "Separate Reimbursables" = FALSE; "Do Not Bill Reimbursables Alone" = TRUE. one BLI reimbursable
    //Result: proforma invoices is not generated
    private static testmethod void testProcessProformaInvoices7(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = false;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            Project_Profile__c projectProfileItem = new Map<Id, Project_Profile__c>(testProjectProfileList).get(billingLineItemItem.Project_Profile__c);
            billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c);
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(testProformaInvoiceList.isEmpty());
    }

    //condition number 7:
    //Project's "Separate Reimbursables" = FALSE; "Do Not Bill Reimbursables Alone" = TRUE. Milestone Date field value is prev month Date.
    //Result: 1 proforma invoices is generated
    private static testmethod void testProcessProformaInvoices7PrevMonth(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = false;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            Project_Profile__c projectProfileItem = new Map<Id, Project_Profile__c>(testProjectProfileList).get(billingLineItemItem.Project_Profile__c);
            billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c).addMonths(-2).addDays(-7); //MRS 7341
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, true, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

    //condition number 8:
    //Project's "Separate Reimbursables" = FALSE; "Do Not Bill Reimbursables Alone" = false. one BLI reimbursable
    //Result: 1 proforma invoices is generated
    private static testmethod void testProcessProformaInvoices8(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE}, DateUtils.MONTHLY);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Separate_Reimbursables__c = false;
        }
        update testProjectProfileList;

        createServiceItem (NUMBER_TO_CREATE_SERVICE_ITEM, testPhaseList);

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        //create 1 reimbursable BLI
        for (Billing_Line_Item__c billingLineItemItem : createBillingLineItem(1, new List<Service_Item__c>{testServiceItemList[0]}, false)){
            billingLineItemItem.isReimbursable__c = true;
            testBillingLineItemList.add(billingLineItemItem);
        }

        insert testBillingLineItemList;

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testProformaInvoiceList.isEmpty());

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices(testBillingLineItemList, false, false, false);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id
                                   FROM Pro_forma_Invoice__c
                                   WHERE Project_Profile__c = : testServiceItemList[0].Project_Profile__c AND
                                            Phase__c = : testServiceItemList[0].Phase__c];

        System.assert(!testProformaInvoiceList.isEmpty());
        System.assertEquals(1, testProformaInvoiceList.size());
    }

//------------------------------------------test processProformaInvoices END------------------------------------------//


    private static testmethod void testCreateProformaInvoice(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        testServiceItemList = new List<Service_Item__c>();
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Proposal__c = proposal.Id;
                serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
                testServiceItemList.add(serviceItem);
            }
            INSERT testServiceItemList;
        testBillingLineItemList = TestingUtils.createBillingLineItemList(1, testProjectProfileList[0].Id, testProjectProfileList[0].Billing_Company_Name__c,
                                                                         testProjectProfileList[0].Billing_Company_Contact__c, false);
        for(Billing_Line_Item__c item : testBillingLineItemList){
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Project_Profile__c = testServiceItemList[0].Project_Profile__c;
        }
        testBillingLineItemList[0].Phase__c = testPhaseList[0].Id;
        testBillingLineItemList[0].Project_Address__c = testBuildingList[0].Id;
        testBillingLineItemList[0].Milestone_Date__c = Date.today();
        insert testBillingLineItemList;
        testBillingLineItemList = [ SELECT Id, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__r.Billing_Method__c,
                                        Pro_forma_Invoice__c, Billing_Client__c, Billing_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c,
                                        Project_Profile__c, Project_Profile__r.Client_Project__c, Project_Profile__r.Invoice_Format__c, Purchase_Order__c, Phase__c,
                                        Project_Profile__r.Floor_s__c, Project_Profile__r.Account_Executive__c, Project_Address__c, Milestone_Date__c,
                                        Project_Profile__r.Frequency__c, isReimbursable__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id = : testBillingLineItemList[0].Id];

        ProformaInvoiceServices.projectMap = ProjectProfileServices.getProgectProfileMap( new Map<Id, Project_Profile__c>(testProjectProfileList).keySet() );

        Pro_forma_Invoice__c proformaInvoiceItem;

        Test.startTest();
            proformaInvoiceItem = ProformaInvoiceServices.createProformaInvoice(testBillingLineItemList[0]);
        Test.stopTest();

        System.assertEquals (testBillingLineItemList[0].Billing_Client__c, proformaInvoiceItem.Billing_Client_Company__c);
        System.assertEquals (testBillingLineItemList[0].Billing_Contact__c, proformaInvoiceItem.Billing_Contact__c);
        System.assertEquals (testBillingLineItemList[0].Accounting_Contact_Company__c, proformaInvoiceItem.Accounting_Contact_Company__c);
        System.assertEquals (testBillingLineItemList[0].Accounting_Contact__c, proformaInvoiceItem.Accounting_Contact__c);
        System.assertEquals (testProjectProfileList[0].Id, proformaInvoiceItem.Project_Profile__c);
        System.assertEquals (testBillingLineItemList[0].Project_Profile__r.Client_Project__c, proformaInvoiceItem.Client_Project__c);
        System.assertEquals (testBillingLineItemList[0].Project_Profile__r.Invoice_Format__c, proformaInvoiceItem.Invoice_Format__c);
//      System.assertEquals (testBillingLineItemList[0].Purchase_Order__c, proformaInvoiceItem.Purchase_Order__c);
        System.assertEquals (testBillingLineItemList[0].Phase__c, proformaInvoiceItem.Phase__c);
        System.assertEquals (testBillingLineItemList[0].Project_Profile__r.Floor_s__c, proformaInvoiceItem.Floor_s__c);
        System.assertEquals (testBillingLineItemList[0].Project_Profile__r.Account_Executive__c, proformaInvoiceItem.Account_Manager__c);
        System.assertEquals (testBillingLineItemList[0].Project_Address__c, proformaInvoiceItem.Project_Address__c);
        System.assertEquals (testBillingLineItemList[0].Project_Profile__r.Project_Name__c, proformaInvoiceItem.Project_Details__c);
        System.assertEquals (Date.today(), proformaInvoiceItem.Invoice_Date__c);
    }

    private static testmethod void testProcessProformaInvoicesUCRX21(){
        setupData(BILLING_METHOD_VALUES_LIST);
        testServiceItemList = new List<Service_Item__c>();
        testPurchaseOrderList = new List<Purchase_Order__c>();
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        testTaskItemList = new List<Task_Item__c>();
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        Map<Id, List<Purchase_Order__c>> mapProjectWithPurchaseOrder = new Map<Id, List<Purchase_Order__c>>();
        Map<Id, List<Pro_forma_Invoice__c>> mapProjectWithProformaInvoice = new Map<Id, List<Pro_forma_Invoice__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            if (projectProfileItem.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE){
                mapProjectWithPurchaseOrder.put(projectProfileItem.Id, new List<Purchase_Order__c>());
                for(Purchase_Order__c item : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false)){
                    item.Project_Profile__c = projectProfileItem.Id;
                    item.Purchase_Order_Amount__c = PURCHASE_ORDER_AMOUNT;
                    mapProjectWithPurchaseOrder.get(projectProfileItem.Id).add(item);
                    testPurchaseOrderList.add(item);
                }
            }
            mapProjectWithProformaInvoice.put(projectProfileItem.Id, new List<Pro_forma_Invoice__c>());
            for(Pro_forma_Invoice__c itemProForma : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                            testAccountList[0].Id,
                                                                                            testContactWithAccountList[0].Id,
                                                                                            testBuildingList[0].Id,
                                                                                            false)){
                itemProForma.Project_Profile__c = projectProfileItem.Id;
                mapProjectWithProformaInvoice.get(projectProfileItem.Id).add(itemProForma);
                testProformaInvoiceList.add(itemProForma);
            }
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Project_Profile__c = projectProfileItem.Id;
                serviceItem.Category__c = 'Application Filing';
                serviceItem.Type__c = 'Plan Approval';
                serviceItem.Actual_Start_Date__c = DateTime.now();
                serviceItem.Shredding_Fees__c = SERVICE_ITEM_SHREDDING_FEES_TEST_VALUE;
                serviceItem.Proposal__c = proposal.Id;
                if (projectProfileItem.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE){
                    serviceItem.Doc_Shredding_BLI_Created__c = false;
                    serviceItem.Actual_End_Date__c = DateTime.now();
                    serviceItem.Actual_Start_Date__c = DateTime.now();
                }
                testServiceItemList.add(serviceItem);
            }
        }

        insert testProformaInvoiceList;
        insert testServiceItemList;
        insert testPurchaseOrderList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        for (Service_Item__c serviceItem : testServiceItemList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, serviceItem.Project_Profile__c,
                                                                                                testAccountList[2].Id, testContactWithAccountList[2].Id, false)){
                billingLineItem.Phase__c = testPhaseList[0].Id;
                billingLineItem.Service_Item__c = serviceItem.Id;
                billingLineItem.Project_Address__c = testBuildingList[0].Id;
                billingLineItem.Milestone_Date__c = Date.today();
                billingLineItem.Quantity__c = BILLING_LINE_ITEM_QUANTITY;
                billingLineItem.Unit_Price__c = BILLING_LINE_ITEM_UNIT_PRICE;
                billingLineItem.Purchase_Order__c = mapProjectWithPurchaseOrder.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithPurchaseOrder.get(serviceItem.Project_Profile__c)[0].id : null;
                billingLineItem.Pro_forma_Invoice__c = mapProjectWithProformaInvoice.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithProformaInvoice.get(serviceItem.Project_Profile__c)[0].id : null;
                billingLineItem.Project_Profile__c = serviceItem.Project_Profile__c;
                billingLineItem.Amount__c = mapProjectWithPurchaseOrder.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithPurchaseOrder.get(serviceItem.Project_Profile__c)[0].Purchase_Order_Amount__c/(NUMBER_TO_CREATE_BILLING_LINE_ITEM * 5) : 0;
                testBillingLineItemList.add(billingLineItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItem.Id;
                taskItemItem.Billing_Trigger__c = true;
                taskItemItem.Is_Locked__c = false;
                taskItemItem.Billing_Percentage__c = 0.1;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testBillingLineItemList;
        insert testTaskItemList;
        testBillingLineItemList = [ SELECT Id, Project_Profile__r.Name, Billing_Client__c, Service_Category__c, Project_Profile__r.Project_Name__c,
                                        Pro_forma_Invoice__c, Project_Profile__r.Billing_Method__c, Billing_Contact__c, Accounting_Contact_Company__c,
                                        Accounting_Contact__c, Project_Profile__c, Project_Profile__r.Client_Project__c, Project_Profile__r.Invoice_Format__c,
                                        Purchase_Order__c, Phase__c, Service_Filling_Status__c, Project_Profile__r.Frequency__c, Service_Item__c,
                                        Billed__c, Project_Profile_No_Document_Shredding__c, Service_Shredding_Fee__c, isReimbursable__c, Milestone_Date__c,
                                        Project_Address__c, Service_Type__c, Sales_Tax_Amount__c, Service_Item__r.Phase__c, Quantity__c, Unit_Price__c,
										Project_Profile__r.PO_Required__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id = : testBillingLineItemList ];

        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices (testBillingLineItemList);
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id, Project_Profile__c FROM Pro_forma_Invoice__c];

        System.assert (!testProformaInvoiceList.isEmpty());
//        System.assertEquals (NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testProformaInvoiceList.size());

        testBillingLineItemList = [ SELECT Id, Pro_forma_Invoice__c, Billed__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id IN : testBillingLineItemList];
        for (Billing_Line_Item__c bli : testBillingLineItemList){
            System.assert (bli.Pro_forma_Invoice__c != null);
            System.assert (bli.Billed__c != null);
        }
    }

    private static testmethod void testProcessProformaInvoicesUCRX22(){
        setupData(BILLING_METHOD_VALUES_LIST);
        testServiceItemList = new List<Service_Item__c>();
        testPurchaseOrderList = new List<Purchase_Order__c>();
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        testTaskItemList = new List<Task_Item__c>();
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        Map<Id, List<Purchase_Order__c>> mapProjectWithPurchaseOrder = new Map<Id, List<Purchase_Order__c>>();
        Map<Id, List<Pro_forma_Invoice__c>> mapProjectWithProformaInvoice = new Map<Id, List<Pro_forma_Invoice__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            if (projectProfileItem.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE){
                mapProjectWithPurchaseOrder.put(projectProfileItem.Id, new List<Purchase_Order__c>());
                for(Purchase_Order__c item : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false)){
                    item.Project_Profile__c = projectProfileItem.Id;
                    item.Purchase_Order_Amount__c = PURCHASE_ORDER_AMOUNT;
                    mapProjectWithPurchaseOrder.get(projectProfileItem.Id).add(item);
                    testPurchaseOrderList.add(item);
                }
            }
            mapProjectWithProformaInvoice.put(projectProfileItem.Id, new List<Pro_forma_Invoice__c>());
            for(Pro_forma_Invoice__c itemProForma : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                            testAccountList[0].Id,
                                                                                            testContactWithAccountList[0].Id,
                                                                                            testBuildingList[0].Id,
                                                                                            false)){
                itemProForma.Project_Profile__c = projectProfileItem.Id;
                mapProjectWithProformaInvoice.get(projectProfileItem.Id).add(itemProForma);
                testProformaInvoiceList.add(itemProForma);
            }
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Project_Profile__c = projectProfileItem.Id;
                serviceItem.Category__c = 'Not Equals Application Filing';
                serviceItem.Type__c = 'Not Equals Plan Approval';
                serviceItem.Actual_Start_Date__c = DateTime.now();
                serviceItem.Shredding_Fees__c = SERVICE_ITEM_SHREDDING_FEES_TEST_VALUE;
                serviceItem.Proposal__c = proposal.Id;
                if (projectProfileItem.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE){
                    serviceItem.Doc_Shredding_BLI_Created__c = false;
                    serviceItem.Actual_End_Date__c = DateTime.now();
                    serviceItem.Actual_Start_Date__c = DateTime.now();
                }
                testServiceItemList.add(serviceItem);
            }
        }

        insert testProformaInvoiceList;
        insert testServiceItemList;
        insert testPurchaseOrderList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        for (Service_Item__c serviceItem : testServiceItemList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, serviceItem.Project_Profile__c,
                                                                                                testAccountList[2].Id, testContactWithAccountList[2].Id, false)){
                billingLineItem.Phase__c = testPhaseList[0].Id;
                billingLineItem.Service_Item__c = serviceItem.Id;
                billingLineItem.Project_Address__c = testBuildingList[0].Id;
                billingLineItem.Milestone_Date__c = Date.today();
                billingLineItem.Quantity__c = BILLING_LINE_ITEM_QUANTITY;
                billingLineItem.Unit_Price__c = BILLING_LINE_ITEM_UNIT_PRICE;
                billingLineItem.Purchase_Order__c = mapProjectWithPurchaseOrder.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithPurchaseOrder.get(serviceItem.Project_Profile__c)[0].id : null;
                billingLineItem.Pro_forma_Invoice__c = mapProjectWithProformaInvoice.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithProformaInvoice.get(serviceItem.Project_Profile__c)[0].id : null;
                billingLineItem.Project_Profile__c = serviceItem.Project_Profile__c;
                billingLineItem.Amount__c = mapProjectWithPurchaseOrder.containsKey(serviceItem.Project_Profile__c) ? mapProjectWithPurchaseOrder.get(serviceItem.Project_Profile__c)[0].Purchase_Order_Amount__c/(NUMBER_TO_CREATE_BILLING_LINE_ITEM * 5) : 0;
                testBillingLineItemList.add(billingLineItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItem.Id;
                taskItemItem.Billing_Trigger__c = true;
                taskItemItem.Is_Locked__c = false;
                taskItemItem.Billing_Percentage__c = 0.1;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testBillingLineItemList;
        insert testTaskItemList;
        testBillingLineItemList = [ SELECT Id, Project_Profile__r.Name, Billing_Client__c, Service_Category__c, Project_Profile__r.Project_Name__c,
                                        Pro_forma_Invoice__c, Project_Profile__r.Billing_Method__c, Billing_Contact__c, Accounting_Contact_Company__c,
                                        Accounting_Contact__c, Project_Profile__c, Project_Profile__r.Client_Project__c, Project_Profile__r.Invoice_Format__c,
                                        Purchase_Order__c, Phase__c, Service_Filling_Status__c, Project_Profile__r.Frequency__c, Service_Item__c,
                                        Billed__c, Project_Profile_No_Document_Shredding__c, Service_Shredding_Fee__c, isReimbursable__c, Milestone_Date__c,
                                        Project_Address__c, Service_Type__c, Sales_Tax_Amount__c, Service_Item__r.Phase__c, Quantity__c, Unit_Price__c,
										Project_Profile__r.PO_Required__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id = : testBillingLineItemList ];
        Map<Id, Account> idToAccountMap = new Map<Id, Account> ();
        for( Account account : testAccountList ) {
            idToAccountMap.put( account.Id, account);
        }
        Test.startTest();
            ProformaInvoiceServices.processProformaInvoices (testBillingLineItemList);
            ProformaInvoiceServices.updateARCoordinator( idToAccountMap );
            Map<Id, Task_Item__c> taskItemsFromDB = ProformaInvoiceServices.taskItemsFromDB;
            ProformaInvoiceServices.generateCreditNotes( testProformaInvoiceList );
            try { ProformaInvoiceServices.processProformaInvoices(new List<Billing_Line_Item__c> { testBillingLineItemList[0] } , false, false, true); } catch ( Exception ex ) {}
            ProformaInvoiceServices.updateProformaInvoicesFormatAndSendCopyTo( new Map<Id, Project_Profile__c> {testProjectProfileList[0].Id=>testProjectProfileList[0]}, 
                                                                               new Map<Id, Project_Profile__c> {testProjectProfileList[0].Id=>testProjectProfileList[0]} );
            ProformaInvoiceServices.updateChangedBillingAccountingInformation( new Map<Id, Project_Profile__c> {testProjectProfileList[0].Id=>testProjectProfileList[0]}, 
                                                                               new Map<Id, Project_Profile__c> {testProjectProfileList[0].Id=>testProjectProfileList[0]} );
            ProformaInvoiceServices.updateBillingLIHideFromRecap( new List<Pro_forma_Invoice__c> { testProformaInvoiceList[0] } );

        Test.stopTest();

        testProformaInvoiceList = [SELECT Id, Project_Profile__c FROM Pro_forma_Invoice__c];

        System.assert (!testProformaInvoiceList.isEmpty());
//        System.assertEquals (NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testProformaInvoiceList.size());

        testBillingLineItemList = [ SELECT Id, Pro_forma_Invoice__c, Billed__c
                                    FROM Billing_Line_Item__c
                                    WHERE Id IN : testBillingLineItemList];
        for (Billing_Line_Item__c bli : testBillingLineItemList){
            System.assert (bli.Pro_forma_Invoice__c != null);
            System.assert (bli.Billed__c != null);
        }
    }

    @isTest(seeAllData = false )private static void testFilterPurchaseOrdersForTotalAmount(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false);
        Map<Id, Pro_forma_Invoice__c> newProformaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>();
        Map<Id, Pro_forma_Invoice__c> oldProformaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>();

        for(Purchase_Order__c  item : testPurchaseOrderList){
            item.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testPurchaseOrderList;
        testPurchaseOrderList = [SELECT Id FROM Purchase_Order__c];
        for(Pro_forma_Invoice__c itemProForma : testProformaInvoiceList){
            itemProForma.Project_Profile__c = testProjectProfileList[0].Id;
            itemProForma.Purchase_Order__c = testPurchaseOrderList[0].Id;
        }
        insert testProformaInvoiceList;
        testProformaInvoiceList = [SELECT Id,Total_Billed_Amount__c,Purchase_Order__c FROM Pro_forma_Invoice__c];
        for(Pro_forma_Invoice__c item : testProformaInvoiceList){
            oldProformaInvoiceMap.put(item.Id,item.clone());
            item.Subtotal__c = 5;
            item.Tax__c = 5;
            item.Purchase_Order__c = testPurchaseOrderList[1].Id;
            newProformaInvoiceMap.put(item.Id,item);
        }
            update testProformaInvoiceList;

        Test.startTest();
            Set<Id> testFilterPurchaseOrdersForTotalAmountSet = ProformaInvoiceServices.filterPurchaseOrdersForTotalAmount(newProformaInvoiceMap, oldProformaInvoiceMap);
        Test.stopTest();

        for(Id itemId : testFilterPurchaseOrdersForTotalAmountSet){
            if(String.valueOf(itemId).equals(String.valueof(testPurchaseOrderList[0].Id))){
                System.assertEquals(testPurchaseOrderList[0].Id, String.valueOf(itemId));
            }else{
                System.assertEquals(testPurchaseOrderList[1].Id, String.valueOf(itemId));
            }
        }

    }

    @isTest(seeAllData = false )private static void testFilterPurchaseOrdersForTotalAmount_oldMapNull(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false);
        Map<Id, Pro_forma_Invoice__c> newProformaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>();

        for(Purchase_Order__c  item : testPurchaseOrderList){
            item.Project_Profile__c = testProjectProfileList[0].Id;
        }
            insert testPurchaseOrderList;
        testPurchaseOrderList = [SELECT Id FROM Purchase_Order__c];
        for(Pro_forma_Invoice__c itemProForma : testProformaInvoiceList){
            itemProForma.Project_Profile__c = testProjectProfileList[0].Id;
            itemProForma.Purchase_Order__c = testPurchaseOrderList[0].Id;
        }
        insert testProformaInvoiceList;
        testProformaInvoiceList = [SELECT Id,Total_Billed_Amount__c,Purchase_Order__c FROM Pro_forma_Invoice__c];
        for(Pro_forma_Invoice__c item : testProformaInvoiceList){
            newProformaInvoiceMap.put(item.Id,item);
        }

        Test.startTest();
            Set<Id> testFilterPurchaseOrdersForTotalAmountSet = ProformaInvoiceServices.filterPurchaseOrdersForTotalAmount(newProformaInvoiceMap, null);
        Test.stopTest();

        for(Id item :testFilterPurchaseOrdersForTotalAmountSet){
            System.assertEquals(testPurchaseOrderList[0].Id, item);
        }


    }

    @isTest(seeAllData = false )private static void testRestrictFFAInvoiceCreation(){
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        Map<Id, Set<Id>> billinLineItemToProFormaMap = new Map<Id, Set<Id>>();
        Map<Id, Billing_Line_Item__c> bliMap = new Map<Id, Billing_Line_Item__c>();
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false);
        testBillingLineItemList = TestingUtils.createBillingLineItemList(5, testProjectProfileList[0].Id, testProjectProfileList[0].Billing_Company_Name__c,
                                                                         testProjectProfileList[0].Billing_Company_Contact__c, false);

        testServiceItemList = new List<Service_Item__c>();
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Proposal__c = proposal.Id;
                serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
                testServiceItemList.add(serviceItem);
            }
            insert testServiceItemList;
        for(Purchase_Order__c  item : testPurchaseOrderList){
            item.Project_Profile__c = testProjectProfileList[0].Id;
        }
            insert testPurchaseOrderList;

        for(Pro_forma_Invoice__c itemProForma : testProformaInvoiceList){
            itemProForma.Project_Profile__c = testProjectProfileList[0].Id;
            itemProForma.Purchase_Order__c = testPurchaseOrderList[0].Id;
            itemProForma.Subtotal__c = 5;
        }
            insert testProformaInvoiceList;

        for(Billing_Line_Item__c item : testBillingLineItemList){
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Pro_forma_Invoice__c = testProformaInvoiceList[0].Id;
        }
            insert testBillingLineItemList;


        for(Billing_Line_Item__c item : testBillingLineItemList){
            billinLineItemToProFormaMap.put(item.Pro_forma_Invoice__c, new Set<Id>());
            billinLineItemToProFormaMap.get(item.Pro_forma_Invoice__c).add(item.Id);
            bliMap.put(item.Id,item);
        }
        billinLineItemToProFormaMap.put(testProformaInvoiceList[1].Id,new Set<Id>());

        Test.startTest();
            ProformaInvoiceServices.totalBilledAmount(billinLineItemToProFormaMap, bliMap);
        Test.stopTest();

        List<Pro_forma_Invoice__c> testList = [Select id,Subtotal__c From Pro_forma_Invoice__c Where Subtotal__c = 0 ];

//        System.assertEquals(2, testList.size());
        for(Pro_forma_Invoice__c item :testList){
            if(String.valueOf(item.Id).equals(String.valueOf(testProformaInvoiceList[0].Id))){
                System.assertEquals(testProformaInvoiceList[0].Id, item.Id);
            }else{
                System.assertEquals(testProformaInvoiceList[1].Id, item.Id);
            }
        }
    }

    private static testmethod void testFilteredProFormaInvoiceWithChangedAddressContact (){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});

        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Accounting_Contact_Company__c = projectProfileItem.Accounting_Contact_Company__c;
                proformaInvoiceItem.Accounting_Contact__c = projectProfileItem.Accounting_Contact__c;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;

        List<Account> additionalAccountList = TestingUtils.createAccountList(2, null, true);
        List<Contact> additionalContactWithAccountList = new List<Contact>();
        for (Account accountItem : additionalAccountList){
            additionalContactWithAccountList.addAll(TestingUtils.createContactList(1, accountItem.Id, false));
        }
        insert additionalContactWithAccountList;

        List<Building__c> additionalBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, true);

        Map<Id, Pro_forma_Invoice__c> proformaInvoiceOldMap = new Map<Id, Pro_forma_Invoice__c>(testProformaInvoiceList.deepClone(true));

        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            proformaInvoiceItem.Accounting_Contact__c = additionalContactWithAccountList[0].Id;
            proformaInvoiceItem.Accounting_Contact_Company__c = additionalContactWithAccountList[0].AccountId;
            proformaInvoiceItem.Billing_Client_Company__c = additionalContactWithAccountList[0].Id;
            proformaInvoiceItem.Billing_Contact__c = additionalContactWithAccountList[0].AccountId;
            proformaInvoiceItem.Project_Address__c = additionalBuildingList[0].Id;
        }

        List<Pro_forma_Invoice__c> resultProformaInvoiceList;

        Test.startTest();

            resultProformaInvoiceList = ProformaInvoiceServices.filteredProFormaInvoiceWithChangedAddressContact(testProformaInvoiceList, proformaInvoiceOldMap);

        Test.stopTest();

        System.assert(resultProformaInvoiceList != null);
        System.assert(!resultProformaInvoiceList.isEmpty());
        System.assertEquals(new Map<Id, Pro_forma_Invoice__c>(testProformaInvoiceList).keySet(), new Map<Id, Pro_forma_Invoice__c>(resultProformaInvoiceList).keySet());
    }

    private static testmethod void testUpdateBillingLIAddressContactValues(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        Map<Id, Service_Item__c> projectWithServiceMap = new Map<Id, Service_Item__c>();

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Proposal__c = proposal.Id;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                projectWithServiceMap.put(projectProfileItem.Id, serviceItemItem);
            }
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                proformaInvoiceItem.Accounting_Contact_Company__c = projectProfileItem.Accounting_Contact_Company__c;
                proformaInvoiceItem.Accounting_Contact__c = projectProfileItem.Accounting_Contact__c;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;
        insert projectWithServiceMap.values();

        List<Account> additionalAccountList = TestingUtils.createAccountList(2, null, true);
        List<Contact> additionalContactWithAccountList = new List<Contact>();
        for (Account accountItem : additionalAccountList){
            additionalContactWithAccountList.addAll(TestingUtils.createContactList(1, accountItem.Id, false));
        }
        insert additionalContactWithAccountList;

        List<Building__c> additionalBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, true);

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false)){
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Pro_forma_Invoice__c = proformaInvoiceItem.Id;
                billingLineItem.Accounting_Contact_Company__c = proformaInvoiceItem.Accounting_Contact_Company__c;
                billingLineItem.Accounting_Contact__c = proformaInvoiceItem.Accounting_Contact__c;
                billingLineItem.Project_Address__c = proformaInvoiceItem.Project_Address__c;
                billingLineItem.Service_Item__c = projectWithServiceMap.get(proformaInvoiceItem.Project_Profile__c).Id;
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;

        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            proformaInvoiceItem.Accounting_Contact__c = additionalContactWithAccountList[0].Id;
            proformaInvoiceItem.Accounting_Contact_Company__c = additionalContactWithAccountList[0].AccountId;
            proformaInvoiceItem.Billing_Client_Company__c = additionalContactWithAccountList[0].AccountId;
            proformaInvoiceItem.Billing_Contact__c = additionalContactWithAccountList[0].Id;
            proformaInvoiceItem.Project_Address__c = additionalBuildingList[0].Id;
        }

        Test.startTest();

            update testProformaInvoiceList;
            
            List<Pro_forma_Invoice__c> invoices = ProformaInvoiceServices.getProformaInvoiceByIds(null);
            Map<Id, Pro_forma_Invoice__c> mapInvoices = new Map<Id, Pro_forma_Invoice__c>(testProformaInvoiceList);
            invoices = ProformaInvoiceServices.getProformaInvoiceByIds(mapInvoices.keySet());

        Test.stopTest();

        testBillingLineItemList = [SELECT Id, Billing_Client__c, Billing_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c,
                                        Project_Address__c, Project_Profile__c, Pro_forma_Invoice__c, Pro_forma_Invoice__r.Billing_Client_Company__c,
                                        Pro_forma_Invoice__r.Billing_Contact__c, Pro_forma_Invoice__r.Accounting_Contact_Company__c,
                                        Pro_forma_Invoice__r.Accounting_Contact__c, Pro_forma_Invoice__r.Project_Address__c,
                                        Pro_forma_Invoice__r.Project_Profile__c
                                   FROM Billing_Line_Item__c
                                   WHERE Pro_forma_Invoice__c IN : testProformaInvoiceList];

        for (Billing_Line_Item__c billingLineItem : testBillingLineItemList){
            System.assertEquals(billingLineItem.Pro_forma_Invoice__r.Billing_Client_Company__c, billingLineItem.Billing_Client__c);
            System.assertEquals(billingLineItem.Pro_forma_Invoice__r.Billing_Contact__c, billingLineItem.Billing_Contact__c);
            System.assertEquals(billingLineItem.Pro_forma_Invoice__r.Accounting_Contact_Company__c, billingLineItem.Accounting_Contact_Company__c);
            System.assertEquals(billingLineItem.Pro_forma_Invoice__r.Accounting_Contact__c, billingLineItem.Accounting_Contact__c);
            System.assertEquals(billingLineItem.Pro_forma_Invoice__r.Project_Address__c, billingLineItem.Project_Address__c);
        }
    }

    private static testmethod void testGetProformaInvoiceToLineItemsMap(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT});

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Billing_Line_Item__c bilingLineItem : TestingUtils.createBillingLineItemList ( NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                projectProfileItem.Id,
                                                                                                testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id,
                                                                                                false ) ){
                testBillingLineItemList.add(bilingLineItem);
            }
        }
        insert testBillingLineItemList;

        Map<Id,  List<Billing_Line_Item__c>> resultProjectProfileWithBillingLineitemMap;

        Test.startTest();

            resultProjectProfileWithBillingLineitemMap = ProformaInvoiceServices.getProformaInvoiceToLineItemsMap(testBillingLineItemList);

        Test.stopTest();

        System.assert (resultProjectProfileWithBillingLineitemMap != null && !resultProjectProfileWithBillingLineitemMap.isEmpty());
    }

    private static testmethod void testGetProjectToProformaInvoiceToLineItemsMap(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT});

        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    testAccountList[0].Id,
                                                                                                    testContactWithAccountList[0].Id,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            for (Billing_Line_Item__c bilingLineItem : TestingUtils.createBillingLineItemList ( NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id,
                                                                                                false ) ){
                bilingLineItem.Pro_forma_Invoice__c = proformaInvoiceItem.Id;
                testBillingLineItemList.add(bilingLineItem);
            }
        }
        insert testBillingLineItemList;

        Map<Id, Map<Id, List<Billing_Line_Item__c>>> resultProjectProfileWithProformaInvoiceWithBillingLineitemMap;

        Test.startTest();

            resultProjectProfileWithProformaInvoiceWithBillingLineitemMap = ProformaInvoiceServices.getProjectToProformaInvoiceToLineItemsMap(testBillingLineItemList);

        Test.stopTest();

        System.assert (resultProjectProfileWithProformaInvoiceWithBillingLineitemMap != null && !resultProjectProfileWithProformaInvoiceWithBillingLineitemMap.isEmpty());
    }
    
    @isTest(seeAllData = false )
    private static void testValidationCreateFFACreditNote(){
        Map<Id, Set<Id>> billinLineItemToProFormaMap = new Map<Id, Set<Id>>();
        Map<Id, Billing_Line_Item__c> bliMap = new Map<Id, Billing_Line_Item__c>();
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false);
        testBillingLineItemList = TestingUtils.createBillingLineItemList(5, testProjectProfileList[0].Id, testProjectProfileList[0].Billing_Company_Name__c,
                                                                         testProjectProfileList[0].Billing_Company_Contact__c, false);
    
        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
            serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItem.Proposal__c = proposal.Id;
            testServiceItemList.add(serviceItem);
        }
        insert testServiceItemList;
        
        for(Purchase_Order__c  item : testPurchaseOrderList){
            item.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testPurchaseOrderList;
    
        for(Pro_forma_Invoice__c itemProForma : testProformaInvoiceList){
            itemProForma.Project_Profile__c = testProjectProfileList[0].Id;
            itemProForma.Purchase_Order__c = testPurchaseOrderList[0].Id;
            itemProForma.Subtotal__c = 5;
        }
        insert testProformaInvoiceList;
    
        for(Billing_Line_Item__c item : testBillingLineItemList){
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Pro_forma_Invoice__c = testProformaInvoiceList[0].Id;
        }
        insert testBillingLineItemList;
    
        for(Billing_Line_Item__c item : testBillingLineItemList){
            billinLineItemToProFormaMap.put(item.Pro_forma_Invoice__c, new Set<Id>());
            billinLineItemToProFormaMap.get(item.Pro_forma_Invoice__c).add(item.Id);
            bliMap.put(item.Id,item);
        }
        billinLineItemToProFormaMap.put(testProformaInvoiceList[1].Id,new Set<Id>());
        System.assert(! testProformaInvoiceList.isEmpty());

        Test.startTest();
            try {
                testProformaInvoiceList.get(0).cl_Create_FFA_Credit_Note_1__c = true;
                update testProformaInvoiceList;
            
            } catch (Exception ex) {
            
            }
            
            try {
                testProformaInvoiceList.get(1).cl_Create_FFA_Credit_Note_2__c = true;
                update testProformaInvoiceList;
            
            } catch (Exception ex) {
            
            }
        Test.stopTest();


    }
    
    @isTest(seeAllData = false )
    private static void testUpdateInvoicesDataForPDF(){
        setupData(new List<String>{ProjectProfileServices.BILLINGMETHODMILESTONE});

        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        Map<Id, Service_Item__c> projectWithServiceMap = new Map<Id, Service_Item__c>();
        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                ServiceItemItem.Proposal__c = proposal.Id;
                projectWithServiceMap.put(projectProfileItem.Id, serviceItemItem);
            }
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                proformaInvoiceItem.Accounting_Contact_Company__c = projectProfileItem.Accounting_Contact_Company__c;
                proformaInvoiceItem.Accounting_Contact__c = projectProfileItem.Accounting_Contact__c;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;
        insert projectWithServiceMap.values();

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            List<Billing_Line_Item__c> bliListForInvoice = TestingUtils.createBillingLineItemList (3,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false);
            for (Billing_Line_Item__c billingLineItem : bliListForInvoice){
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Pro_forma_Invoice__c = proformaInvoiceItem.Id;
                billingLineItem.Accounting_Contact_Company__c = proformaInvoiceItem.Accounting_Contact_Company__c;
                billingLineItem.Accounting_Contact__c = proformaInvoiceItem.Accounting_Contact__c;
                billingLineItem.Project_Address__c = proformaInvoiceItem.Project_Address__c;
                billingLineItem.Service_Item__c = projectWithServiceMap.get(proformaInvoiceItem.Project_Profile__c).Id;
            }
            bliListForInvoice[0].Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING;
            bliListForInvoice[1].Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING;
            bliListForInvoice[2].isHourlyConsulting__c = true;
            testBillingLineItemList.addAll(bliListForInvoice);
        }
        insert testBillingLineItemList;

        Test.startTest();
           Boolean status = ProformaInvoiceServices.updateInvoicesDataForPDF( new Map<Id, Pro_forma_Invoice__c>(testProformaInvoiceList), true );
        Test.stopTest();

        testProformaInvoiceList = [SELECT Id, Sent_To_Client__c FROM Pro_forma_Invoice__c WHERE id IN : testProformaInvoiceList];

        System.assert(! testProformaInvoiceList.isEmpty());
        
        for( Pro_forma_Invoice__c invoice : testProformaInvoiceList ){
            System.assert(invoice.Sent_To_Client__c, 'Asserrtion Failed' + invoice);
        }
    }
}