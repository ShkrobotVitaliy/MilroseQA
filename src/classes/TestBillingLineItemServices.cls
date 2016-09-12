@isTest
private class TestBillingLineItemServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
    private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 1;
    private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_MAILROOM = 3;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 3;
    private static final Decimal BILLING_LINE_ITEM_AMOUNT = 10.1;
    private static final Integer MAIL_ROOM_NUMBER = 3;
    private static final Integer PURCHASE_ORDER_NUMBER = 3;
    private static final Integer TAKS_ITEM_NUMBER = 3;
    private static final Integer BILLING_DATE_NUMBER = 3;
    private static final Integer PHASE_NUMBER = 3;
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                    ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static List<Pro_forma_Invoice__c> testProFormaInvoiceList;
    private static List<Proposal__c> testProposalList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Billing_Line_Item__c> oldTestBillingLineItemList;
    private static List<Billing_Date__c> testBlllingDateList;
    private static List<Task_Item__c> testTaskitemList;
    private static List<Phase__c> testPhaseList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static Pro_forma_Invoice__c oldtestProformaInvoice;
    private static List<Mailroom__c> testMailRoomList;
    private static Set<Id> testBillingItemIdSet;
    private static List<Deposit_Invoice__c> testDepositInvoiceList;
    private static User projectManagerUser;

    private static Id performHourlyConsultingRecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get(TaskItemServices.PERFORM_HOURLY_CONSULTING_TASK_NAME);
    private static Id completeFormsRecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get(TaskItemServices.COMPLETE_FORMS_TASK_NAME);

    private static void createData(){
        TestingUtils.setupData();
        projectManagerUser = TestingUtils.testProjectManagerUser;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void setupData(){
        createData();

        testProjectProfileList = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[0].Id, testContactWithAccountList[0].Id, testAccountList[0].Id,
                                                                        testContactWithAccountList[0].Id, projectManagerUser.Id, false );

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);

        for(Proposal__c proposalItem : testProposalList){
            proposalItem.Discounted_Total_Service_Amount__c = 20;
        }
        insert testProposalList;

        for(Integer i = 0; i < testProjectProfileList.size(); i++) {
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
        }
        INSERT testProjectProfileList;
        for(Integer i = 0; i < testProjectProfileList.size(); i++) {
            testProposalList[i].Project_Profile__c = testProjectProfileList[i].Id;
        }
        UPDATE testProposalList;
    }

    private static void prepareProjectsWithDifferentMethods(){
        createData();

        testProposalList = new List<Proposal__c>();
        testProjectProfileList = new List<Project_Profile__c>();
        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            for (Proposal__c proposalItem : TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false) ){
                proposalItem.Billing_Method__c = billingMethodItem;
                proposalItem.Frequency__c = DateUtils.MONTHLY;
                proposalItem.Billing_day__c = String.valueOf(Date.today().day());
                proposalItem.Discounted_Total_Service_Amount__c = 1;
                testProposalList.add(proposalItem);
                if (billingMethodItem == ProjectProfileServices.BILLINGMETHODPERCENTAGE){
                    proposalItem.Interval__c = false;
                    proposalItem = proposalItem.clone(true, true, true, true);
                    proposalItem.Interval__c = true;
                    testProposalList.add(proposalItem);
                }
            }

            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Billing_Method__c = billingMethodItem;
                projectProfileItem.Building__c = testBuildingList[0].id;
                projectProfileItem.Frequency__c = DateUtils.MONTHLY;
                projectProfileItem.Expected_Construction_Start_Date__c = Date.today();
                projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(1);
                projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                projectProfileItem.Total_Service_Amount__c = 100;
                projectProfileItem.Reimbursable1__c = 10;
                projectProfileItem.Reimbursable2__c = 10;
                projectProfileItem.Reimbursable3__c = 10;
                projectProfileItem.Reimbursable4__c = 10;
                testProjectProfileList.add(projectProfileItem);
                if (billingMethodItem == ProjectProfileServices.BILLINGMETHODPERCENTAGE){
                    projectProfileItem.Interval__c = false;
                    projectProfileItem = projectProfileItem.clone(true, true, true, true);
                    projectProfileItem.Interval__c = true;
                    testProjectProfileList.add(projectProfileItem);
                }

            }
        }
        insert testProposalList;

        for(Integer i = 0; i < testProjectProfileList.size(); i++) {
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
        }
        insert testProjectProfileList;
        for(Integer i = 0; i < testProjectProfileList.size(); i++) {
            testProposalList[i].Project_Profile__c = testProjectProfileList[i].Id;
        }
        update testProposalList;

        testBlllingDateList = new List<Billing_Date__c>();
        testServiceItemList = new List<Service_Item__c>();
        List<Service_Item__c> hourlyConsultingServiceItemList = new List<Service_Item__c>();
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for(Project_Profile__c project : testProjectProfileList){
            if (project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ||
                (project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c)){
                for(Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(1, Date.today(), project.Id, false)){
                    billingDateItem.Billed__c = false;
                    testBlllingDateList.add(billingDateItem);
                }
            }
            for(Service_Item__C si : TestingUtils.createServiceItemList(1, project.Proposal__c, false)){
                si.Project_Profile__c = project.Id;
                serviceItemList.add(si);
                testServiceItemList.add(si);
            }
            for(Service_Item__C si : TestingUtils.createServiceItemList(1, project.Proposal__c, false)){
                si.Project_Profile__c = project.Id;
                si.Quantity__c = 10;
                hourlyConsultingServiceItemList.add(si);
                testServiceItemList.add(si);
            }
        }
        insert testBlllingDateList;
        insert testServiceItemList;

        Map<Id, Project_Profile__c> projectMap = new Map<Id, Project_Profile__c>(testProjectProfileList);

        testTaskitemList = new List<Task_Item__c>();
        for (Service_Item__c si : hourlyConsultingServiceItemList){
            for (Task_Item__c ti : TestingUtils.createTaskItemList(1, si.Id, si.Project_Profile__c, false)){
                ti.RecordTypeId = performHourlyConsultingRecordTypeId;
                ti.Name = TaskItemServices.PERFORM_HOURLY_CONSULTING_TASK_NAME;
                testTaskitemList.add(ti);
            }
        }
        for (Service_Item__c si : serviceItemList){
            for (Task_Item__c ti : TestingUtils.createTaskItemList(1, si.Id, si.Project_Profile__c, false)){
                ti.RecordTypeId = completeFormsRecordTypeId;
                ti.Billing_Percentage__c = 100;
                ti.Billing_Trigger__c = true;
                ti.Name = TaskItemServices.COMPLETE_FORMS_TASK_NAME;
                testTaskitemList.add(ti);
            }
        }
        insert testTaskitemList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Billing_Date__c billingDateItem : testBlllingDateList){
            Project_Profile__c project = projectMap.get(billingDateItem.Project_Profile__c);
            for (Billing_Line_Item__c bli : TestingUtils.createBillingLineItemList(1, billingDateItem.Project_Profile__c, project.Billing_Company_Name__c, project.Billing_Company_Contact__c, false)){
                testBillingLineItemList.add(bli);
            }
        }

        Map<Id, Billing_Line_Item__c> taskWithBLIMap = new Map<Id, Billing_Line_Item__c>();
        for (Task_Item__c ti : testTaskitemList){
            Project_Profile__c project = projectMap.get(ti.Project_Profile__c);

            if (project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ||
                (project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c)) continue;

            for (Billing_Line_Item__c bli : TestingUtils.createBillingLineItemList(1, ti.Project_Profile__c, project.Billing_Company_Name__c, project.Billing_Company_Contact__c, false)){
                bli.isHourlyConsulting__c = ti.RecordTypeId == performHourlyConsultingRecordTypeId;
                bli.Service_Item__c = ti.Service_Item__c;
                bli.Related_Service_Item__c = ti.Service_Item__c;
                bli.Active_Billing_Line_Item__c = false;
                bli.Quantity__c = 2;
                bli.Unit_Price__c = 50;
                bli.isReimbursable__c = false;
                bli.Task_Item__c = ti.Id;
                taskWithBLIMap.put(ti.Id, bli);
                testBillingLineItemList.add(bli);
            }
        }
        insert testBillingLineItemList;

        for (Task_Item__c ti : testTaskitemList){
            if (taskWithBLIMap.containsKey(ti.Id) && taskWithBLIMap.get(ti.Id) != null){
                ti.Billing_Line_Item__c = taskWithBLIMap.get(ti.Id).Id;
            }
        }
        update testTaskitemList;
    }

    private static void prepareData (Decimal amountValue, Boolean doInsert){
        testBillingLineItemList = new List<Billing_Line_Item__c>();
        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        testServiceItemList = new List<Service_Item__c>();
        testDepositInvoiceList = new List<Deposit_Invoice__c>();

        oldtestProformaInvoice = TestingUtils.createProFormaInvoiceList ( NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testProjectProfileList[0].Billing_Company_Name__c,
                                                                         testProjectProfileList[0].Billing_Company_Contact__c, testBuildingList[0].Id, false )[0];
        oldtestProformaInvoice.Project_Profile__c = testProjectProfileList[0].Id;
        insert  oldtestProformaInvoice;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Pre_billed__c = false;
            projectProfileItem.Billing_Method__c = 'Milestone';
            for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepositInvoiceList(1, projectProfileItem.Proposal__c, projectProfileItem.Id, false)){
                depositInvoiceItem.Amount_Remaining__c = 1;
                depositInvoiceItem.Deposit_Invoice_Type__c = DepositInvoiceServices.SERVICE_RETAINER_TYPE;
                testDepositInvoiceList.add(depositInvoiceItem);
            }
            for(Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Project_Profile__c =    projectProfileItem.Id;
                serviceItem.Proposal__c = projectProfileItem.Proposal__c;
                serviceItem.Met_Data_Scanning_Fee__c = 10;
                serviceItem.Quantity__c = 100;
                serviceItem.Tax_Percent_1__c = 15;
                serviceItem.Tax_Percent_2__c = 15;
                testServiceItemList.add(serviceItem);
            }
            for(Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList ( NUMBER_TO_CREATE_PRO_FORMA_INVOICE, projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c, testBuildingList[0].Id, false )){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proformaInvoiceItem);
            }

        }
        UPSERT testProjectProfileList;
        INSERT testDepositInvoiceList;
        UPSERT testServiceItemList;
        UPSERT testProFormaInvoiceList;
        
        for (Pro_forma_Invoice__c proFormaInvoiceItem : testProFormaInvoiceList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, proFormaInvoiceItem.Project_Profile__c,
                                                                                                proFormaInvoiceItem.Billing_Client_Company__c,
                                                                                                proFormaInvoiceItem.Billing_Contact__c, false)){
                //billingLineItem.Pro_forma_Invoice__c = proFormaInvoiceItem.Id;
                billingLineItem.Amount__c = amountValue;
                billingLineItem.Service_Item__c = testServiceItemList[0].Id;
                billingLineItem.Quantity__c = 150;
                //billingLineItem.Billing_Percentage__c = 10;
                billingLineItem.Unit_Price__c = 300;

                testBillingLineItemList.add(billingLineItem);
            }
        }
        if (doInsert){
            insert testBillingLineItemList;
        }
    }

    private static void oldBillingLineItem(){
        //testBillingLineItemList = new List<Billing_Line_Item__c>();
        oldtestProformaInvoice = TestingUtils.createProFormaInvoiceList ( NUMBER_TO_CREATE_PRO_FORMA_INVOICE, testProjectProfileList[0].Billing_Company_Name__c,
                                                                                                    testProjectProfileList[0].Billing_Company_Contact__c, testBuildingList[0].Id, false )[0];
            oldtestProformaInvoice.Project_Profile__c = testProjectProfileList[0].Id;
            insert  oldtestProformaInvoice;

        oldTestBillingLineItemList = TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, oldtestProformaInvoice.Project_Profile__c,
                                                                                            oldtestProformaInvoice.Billing_Client_Company__c,
                                                                                            oldtestProformaInvoice.Billing_Contact__c, false);
            for (Billing_Line_Item__c billingLineItem : oldTestBillingLineItemList){
                billingLineItem.Pro_forma_Invoice__c = oldtestProformaInvoice.Id;
                billingLineItem.Amount__c = 1;
                billingLineItem.Service_Item__c = testServiceItemList[0].Id;
            }
                insert oldTestBillingLineItemList;
    }

    private static void moreData(){
        testBlllingDateList = TestingUtils.createBillingDateList(BILLING_DATE_NUMBER, Date.newInstance(2013, 10, 2), testProjectProfileList[0].Id, false);
             testBlllingDateList[0].Processing_Day__c =  Date.newInstance(2013, 12, 2);
             insert testBlllingDateList;
        testTaskitemList = TestingUtils.createTaskItemList(TAKS_ITEM_NUMBER, testServiceItemList[0].Id, testProjectProfileList[0].Id, false);
            testTaskitemList[0].Actual_Start_Date__c = Date.newInstance(2013, 9, 2);
            testTaskitemList[0].Actual_End_Date__c = Date.newInstance(2013, 12, 2);
            for (Task_Item__c item : testTaskitemList){
                item.Billing_Percentage__c = 15;
            }
        testPhaseList = TestingUtils.createPhaseList(PHASE_NUMBER, false);
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(PURCHASE_ORDER_NUMBER, Date.today(), false);
        for(Project_Profile__c itemProject : testProjectProfileList){
            itemProject.Billing_Method__c = 'Milestone';
            for(Purchase_Order__c item : testPurchaseOrderList){
                item.Project_Profile__c = itemProject.Id;
                item.Purchase_Order_Amount__c = 3;
                for(Phase__c itemPhase : testPhaseList){
                    itemPhase.Project_Profile__c = itemProject.Id;
                    for(Service_Item__c itemService : testServiceItemList){
                        itemService.Purchase_Order__c = item.Id;
                        itemService.Service_Name_Full__c = 'testService';
                        itemService.Description__c = 'testDescription';
                        itemService.Phase__c = itemPhase.Id;
                    }
                }
            }
        }
        update testProjectProfileList;
        insert testPhaseList;
        insert testPurchaseOrderList;
        update testServiceItemList;
        insert testTaskitemList;
    }

    private static List<Billing_Line_Item__c> getAllBillingLineItems(){
        return [SELECT Id, Billing_Project_Method__c, Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Project_Address__r.Name, Project_Address__c, Billing_Client__r.Name,
                        Billing_Client__c, Accounting_Contact__c, Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name, Project_Profile__r.Billing_Method__c,
                        Unit_Price__c, Quantity__c, Milestone_Date__c, Purchase_Order__r.Purchase_Order__c, Purchase_Order__c, External_ID__c,
                        Service_Name__c, Service_Item__c, Service_Item__r.Name, Phase__c, Project_Profile__r.Billing_Day__c, Project_Profile__r.Floor_s__c, Amount__c,
                        Project_Profile__r.Account_Executive__c, Project_Profile__r.Frequency__c, Project_Profile__r.Quarterly_Month__c,
                        Billing_Contact__c, Client_Contact__c, Pro_forma_Invoice__c, Phase__r.Name__c, Project_Profile__r.Total_Service_Amount__c, Project_Profile__r.Client_Project__c,
                        Project_Profile__r.Invoice_Format__c, Service_Category__c, Service_Filling_Status__c, Project_Profile_No_Document_Shredding__c, Service_Type__c, Municipal_Agency_ID__c,
                        Project_Profile__r.Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Billing_Company_Name__c, Pro_forma_Invoice__r.Project_Profile__c, 
                        Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Project_Profile__r.Interval__c, Sales_Tax_Amount__c, 
                        CreatedDate, Project_Profile__r.No_Met_Data_Scanning__c, Project_Profile__r.Separate_Phases__c, Project_Profile__r.Separate_Reimbursables__c, isReimbursable__c
                        FROM Billing_Line_Item__c];
    }

    @isTest static void testFilteredIdxOfPOsToUpdate() {
        setupData();
        prepareData( 2, true);

        Id testPOId = Id.valueOf(Task.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        List<Billing_Line_Item__c> oldBLIList = testBillingLineItemList.deepClone(true, true, true);
        for (Integer i = 0; i < testBillingLineItemList.size(); i++){
            testBillingLineItemList[i].Billed__c = true;
            oldBLIList[i].Billed__c = false;
            testBillingLineItemList[i].Purchase_Order__c = oldBLIList[i].Purchase_Order__c = testPOId;
        }

        Set<Id> resIdSet = new Set<Id>();

        Test.startTest();

            resIdSet = BillingLineItemServices.filteredIdxOfPOsToUpdate(new Map<Id, Billing_Line_Item__c>(testBillingLineItemList), new Map<Id, Billing_Line_Item__c>(oldBLIList));
            resIdSet = BillingLineItemServices.filteredIdxOfPOsToUpdate(new Map<Id, Billing_Line_Item__c>(testBillingLineItemList), null);
            resIdSet = BillingLineItemServices.filteredIdxOfPOsToUpdate(null, new Map<Id, Billing_Line_Item__c>(oldBLIList));
            System.assert(resIdSet != null);

        Test.stopTest();
    }

    @isTest static void testUncoveredParts() {
        setupData();
        prepareData( 50, true);
        moreData();
        Billing_Line_Item__c bli = new Billing_Line_Item__c ();
        bli.Project_Profile__c = testProjectProfileList[0].Id;
        bli.Service_Item__c  = testServiceItemList[0].Id;
        INSERT bli;
        List<Billing_Line_Item__c> bliForBatchList = BillingLineItemServices.bliForBatchList( testProjectProfileList, true );
        List<Billing_Line_Item__c> bliForBatchList1 = BillingLineItemServices.bliForBatchList( testProjectProfileList, false );
        Billing_Line_Item__c newReimbursableLineItemMunicipal = BillingLineItemServices.newReimbursableLineItemMunicipal( testProjectProfileList[0] );
        Billing_Line_Item__c newReimbursableLineItemMessenger = BillingLineItemServices.newReimbursableLineItemMessenger( testProjectProfileList[0] );
        testProjectProfileList[0].Reimbursable1__c = 5;
        Billing_Line_Item__c newReimbursableLineItemScanning1 = BillingLineItemServices.newReimbursableLineItemScanning( testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0], testBlllingDateList[0] );
        Billing_Line_Item__c newReimbursableLineItemScanning2 = BillingLineItemServices.newReimbursableLineItemScanning( null, testServiceItemList[0], testProjectProfileList[0], testBlllingDateList[0] );
        BillingLineItemServices.populateReimbursableLineItemsPurchaseOrder( testBillingLineItemList, testPurchaseOrderList );
        Id getPurchaseOrderForLimeItemPercentage = BillingLineItemServices.getPurchaseOrderForRegularBLI( testPurchaseOrderList, bli, true);
        List<Billing_Line_Item__c> getBillingLineItemByInvoiceId1 = BillingLineItemServices.getBillingLineItemByInvoiceId( testProFormaInvoiceList[0].Id );
        try { List<Billing_Line_Item__c> getBillingLineItemByInvoiceId2 = BillingLineItemServices.getBillingLineItemByInvoiceId( null ); } catch (Exception ex) {}
        List<Billing_Line_Item__c> getBillingLineItemWithProformaInvoice = BillingLineItemServices.getBillingLineItemWithProformaInvoice( new Set<Id> { testServiceItemList[0].Id } );
        BillingLineItemServices.getBliWithoutPO(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());
    }

    @isTest static void testUncalledFunctions() {
        setupData();
        prepareData( 50, true);
        moreData();
        Billing_Line_Item__c bli = new Billing_Line_Item__c ();
        bli.Project_Profile__c = testProjectProfileList[0].Id;
        bli.Service_Item__c  = testServiceItemList[0].Id;
        INSERT bli;
        //BillingLineItemServices.linkExistingReimbBLIToPurchaseOrdersWithIncreasedAmount( testPurchaseOrderList );
        //List<Billing_Line_Item__c> getReimbBliWithoutPO = BillingLineItemServices.getReimbBliWithoutPO( new Set<Id> { testProjectProfileList[0].Id } );
        Map<Id, Billing_Line_Item__c> getNotSupercededBLIByProjectsId = BillingLineItemServices.getNotSupercededBLIByProjectsId( new Set<Id> { testProjectProfileList[0].Id } );
        Map<Id, Billing_Line_Item__c> getBLIForInvoicesToGeneratePDF = BillingLineItemServices.getBLIForInvoicesToGeneratePDF( new Set<Id> { testProFormaInvoiceList[0].Id } );
    }

    @isTest static void testUncalledMethods() {
        setupData();
        prepareData( 50, true);
        moreData();
        Billing_Line_Item__c bli = new Billing_Line_Item__c ();
        bli.Project_Profile__c = testProjectProfileList[0].Id;
        bli.Service_Item__c  = testServiceItemList[0].Id;

        INSERT bli;
        Set<Id> getInvoiceIdsThatHaveChargeChecks = BillingLineItemServices.getInvoiceIdsThatHaveChargeChecks( new Set<Id> { testProFormaInvoiceList[0].Id } );
        BillingLineItemServices.deActiveBillingLineItemFuture( new Set<Id> { testTaskitemList[0].Id } );
        BillingLineItemServices.activeBillingLineItemFuture( new Set<Id> { testTaskitemList[0].Id } );
        List<Billing_Line_Item__c> getBillingLineItemByTaskItemIds = BillingLineItemServices.getBillingLineItemByTaskItemIds( new Set<Id> { testTaskitemList[0].Id } );
        Billing_Line_Item__c initRemainingHoursBli1 = BillingLineItemServices.initRemainingHoursBli( testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0],
                                                                                                                            new Map<Id, Service_Item__c> { testServiceItemList[0].Id => testServiceItemList[0] } );
        Billing_Line_Item__c initRemainingHoursBli2 = BillingLineItemServices.initRemainingHoursBli( testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0], 
                                                                                                    new Map<Id, Service_Item__c> { testServiceItemList[0].Id => testServiceItemList[0] }, true );
        Billing_Line_Item__c initRemainingHoursBli3 = BillingLineItemServices.initRemainingHoursBli( testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0], 
                                                                                                    new Map<Id, Service_Item__c> { testServiceItemList[0].Id => testServiceItemList[0] }, false );
    }
    @isTest static void testBLIMetods() {
        setupData();
        prepareData( 50, true);
        moreData();
        Billing_Line_Item__c bli = new Billing_Line_Item__c ();
        bli.Project_Profile__c = testProjectProfileList[0].Id;
        bli.Service_Item__c  = testServiceItemList[0].Id;
        INSERT bli;
        Check_Processing_Fee__c checkProcessingFee = new Check_Processing_Fee__c(Name = 'test_name', Charge_Check_Processing_Fee__c = true, Processing_Fee_GLA__c = 'test', Processing_Fee_Amount__c = 10);
        INSERT checkProcessingFee;
        Billing_Line_Item__c bliToClone = [SELECT Id__c FROM Billing_Line_Item__c WHERE Id = :bli.Id];
        //String cloneBLI = BillingLineItemServices.cloneBLI( bliToClone.Id__c );
        BillingLineItemServices.resetRequiresCheckImageForRelatedCheckProcessingFeeBlis( new Set<Id> { bli.Id } );
    }

    private static testMethod void testFilterBillingLineItemTotalAmountForProformaInvoice_OldMapIsNull(){
        setupData();
        prepareData(50,true);
//        testBillingLineItemList = new List<Billing_Line_Item__c>();

        testBillingItemIdSet = new Set<Id>();
        Set<Id> methodSetId ;

        for(Billing_Line_Item__c item : testBillingLineItemList){
            testBillingItemIdSet.add(item.id);
        }

        Test.startTest();
             Map<Id, Set<Id>> testBillinLineItemToProFormaMap = BillingLineItemServices.filterBillingLineItemTotalAmountForProformaInvoice(testBillingLineItemList, null);
        Test.stopTest();
        System.debug(LoggingLevel.error,'@@@testBillinLineItemToProFormaMap' + testBillinLineItemToProFormaMap);
        /*for(Billing_Line_Item__c item : testBillingLineItemList){
            //System.assertEquals(testBillingLineItemList.size(), testBillinLineItemToProFormaMap.get(item.Pro_forma_Invoice__c).size());
            methodSetId = testBillinLineItemToProFormaMap.get(item.Pro_forma_Invoice__c);
            System.assert(testBillingItemIdSet.equals(methodSetId));
        }*/


    }

    private static testMethod void testFilterBillingLineItemTotalAmountForProformaInvoice_OldProformaInvoiceIsNotNull(){
        System.debug(LoggingLevel.Error,'@@@Stage111');
        setupData();
        prepareData(50,true);
        testBillingItemIdSet = new Set<Id>();
        Set<Id> methodSetId = new Set<Id>();

        Map <Id, Billing_Line_Item__c> oldBillingItemMap = new Map<Id, Billing_Line_Item__c>();

        for(Billing_Line_Item__c item : testBillingLineItemList){
            oldBillingItemMap.put(item.Id,item.clone());
            item.Amount__c = 50;
            item.cl_Credit_2_Amount__c = 1.1;
            testBillingItemIdSet.add(item.id);
        }


        Test.startTest();
             Map<Id, Set<Id>> testBillinLineItemToProFormaMap = BillingLineItemServices.filterBillingLineItemTotalAmountForProformaInvoice(testBillingLineItemList, oldBillingItemMap);
        Test.stopTest();

        Set<Id> idSetTest = testBillinLineItemToProFormaMap.KeySet();
        List<Pro_forma_Invoice__c> testProformaList = [Select Id From Pro_forma_Invoice__c Where Id IN : idSetTest];
        System.assertEquals(testProformaList.size() , testBillinLineItemToProFormaMap.size());


        for(Integer i = 0; i < testProformaList.size();i++  ){
            for(Pro_forma_Invoice__c proformaItem: testProformaList){
                System.assert( testBillinLineItemToProFormaMap.containsKey(proformaItem.Id));
            }
            System.assert(testBillingItemIdSet.equals(testBillinLineItemToProFormaMap.get(oldBillingItemMap.values()[i].Pro_forma_Invoice__c)));

        }



    }

    private static testMethod void testGenerateBillingLineItemsForMailroomTrigger(){
        Integer testNumber = 10;
        setupData();
        testProjectProfileList = [SELECT Id,Pre_billed__c FROM Project_Profile__c ];
        testMailRoomList = TestingUtils.createMailRoomList(MAIL_ROOM_NUMBER, false);
        for(Project_Profile__c itemProject : testProjectProfileList){
            for(Mailroom__c item : testMailRoomList){
                item.Project_Profile__c = itemProject.Id;
                item.Price__c = 10;
                item.Date_created__c = Date.today();
            }
        }


        Test.startTest();
            insert  testMailRoomList;
        Test.stopTest();

        List<Billing_Line_Item__c>testBillingListList = [SELECT ID,isReimbursable__c,Quantity__c,Unit_Price__c,Amount__c
                                              From Billing_Line_Item__c];

        for(Billing_Line_Item__c item : testBillingListList){
            System.assertEquals(true, item.isReimbursable__c);
            System.assertEquals(1, item.Quantity__c);
            System.assertEquals(10, item.Unit_Price__c);
            System.assertEquals(10, item.Unit_Price__c);
        }
    }

    private static testMethod void testNewReimbursableLineItem_BillingLineItem(){
        setupData();
        prepareData(0,true);
        moreData();     
        
        Test.startTest();
            Billing_Line_Item__c reimbursableLineItem = BillingLineItemServices.newReimbursableLineItem(testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0], testBlllingDateList[0],'TestProduct','TestDescription','TestType');
        Test.stopTest();

        System.assertEquals(true, reimbursableLineItem.isReimbursable__c);
    }

    private static testMethod void testNewReimbursableLineItem_taskItemIsNull(){
        setupData();
        prepareData(0,true);
        moreData();
        //List<Billing_Date__c> testBlllingDateList = TestingUtils.createBillingDateList(BILLING_DATE_NUMBER, Date.newInstance(2013, 10, 2), testProjectProfileList[0].Id, true);
        Test.startTest();
            Billing_Line_Item__c reimbursableLineItem = BillingLineItemServices.newReimbursableLineItem(null, testServiceItemList[0], testProjectProfileList[0],testBlllingDateList[0],'TestProduct','TestDescription','TestType');
        Test.stopTest();
    }



    private static testMethod void testInitBillingLineItem_TaskItem(){
        setupData();
        prepareData(0,true);
        moreData();

        Test.startTest();
            Billing_Line_Item__c billintLineItem =  BillingLineItemServices.initBillingLineItem(null, testTaskitemList[0], testServiceItemList[0], testProjectProfileList[0], testBlllingDateList[0]);
        Test.stopTest();
    }

    private static testMethod void testInitBillingLineItem_ServiceItem(){
        setupData();
        prepareData(0,true);
        moreData();


        Test.startTest();
            Billing_Line_Item__c billintLineItem =  BillingLineItemServices.initBillingLineItem(null, null, testServiceItemList[0], testProjectProfileList[0], testBlllingDateList[0]);
        Test.stopTest();

    }

    private static testMethod void testInitBillingLineItem_ProjectProfile(){
        setupData();
        prepareData(0,true);
        moreData();


        Test.startTest();
            Billing_Line_Item__c billintLineItem =  BillingLineItemServices.initBillingLineItem(null, null, null, testProjectProfileList[0], testBlllingDateList[0]);
        Test.stopTest();

    }

    private static testMethod void testInitBillingLineItem_BillingDate(){
        setupData();
        prepareData(0,true);
        moreData();


        Test.startTest();
            Billing_Line_Item__c billintLineItem =  BillingLineItemServices.initBillingLineItem(null, null, null, null, testBlllingDateList[0]);
        Test.stopTest();

    }


    private static testMethod void testBuildQuery(){
        String expectedResult = 'SELECT Id, Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Project_Address__r.Name, Project_Address__c, Billing_Client__r.Name, '+
                        'Billing_Client__c, Accounting_Contact__c, Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name, Project_Profile__r.Billing_Method__c, '+
                        'Unit_Price__c, Quantity__c, Milestone_Date__c, Purchase_Order__r.Purchase_Order__c, Purchase_Order__c, External_ID__c, '+
                        'Service_Name__c, Service_Item__c, Service_Item__r.Name, Phase__c, Project_Profile__r.Billing_Day__c, Project_Profile__r.Floor_s__c, Amount__c,'+
                        'Project_Profile__r.Account_Executive__c, Project_Profile__r.Frequency__c, Project_Profile__r.Quarterly_Month__c, '+
                        'Billing_Contact__c, Client_Contact__c, Pro_forma_Invoice__c, Phase__r.Name__c, Project_Profile__r.Total_Service_Amount__c, Project_Profile__r.Client_Project__c, '+
                        'Project_Profile__r.Invoice_Format__c, Service_Category__c, Service_Filling_Status__c, Project_Profile_No_Document_Shredding__c, Service_Type__c, Municipal_Agency_ID__c,' +
                        'Project_Profile__r.Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Billing_Company_Name__c, Pro_forma_Invoice__r.Project_Profile__c, ' +
                        'Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Project_Profile__r.Interval__c, Sales_Tax_Amount__c, ' +
                        'CreatedDate, Project_Profile__r.No_Met_Data_Scanning__c, Project_Profile__r.Separate_Phases__c, Project_Profile__r.Separate_Reimbursables__c, isReimbursable__c ' +
                        'FROM Billing_Line_Item__c Where isReimbursable__c = true ORDER BY Name LIMIT 1000';
        String queryWhere = 'Where isReimbursable__c = true' ;
        String sortBy = 'Name' ;

        Test.startTest();
            String testString  = BillingLineItemServices.buildQuery(queryWhere, sortBy);
        Test.stopTest();

    }

    private static testMethod void testBuildQueryWhere(){
        String testParameter = 'Test';
        String expectedRes = 'WHERE Project_Number__c LIKE \'%' + testParameter + '%\' AND Project_Address__r.Name LIKE \'%'+
                                    testParameter +'%\' AND Billing_Client__r.Name LIKE \'%'+
                                    testParameter +'%\' AND Accounting_Contact_Company__r.Name LIKE \'%'+ testParameter +
                                    '%\' AND Service_Item__r.Name LIKE \'%'+ testParameter +'%\' AND Purchase_Order__r.Name LIKE \'%'+ 
                                    testParameter +'%\' AND Project_Profile__r.Billing_Method__c =\''+ testParameter +
                                    '\' AND Billed__c = false AND Active_Billing_Line_Item__c = true AND isReimbursable__c = true ' +
                                    ' AND Reimb_Billable_Type__c =\'' + testParameter + '\'';

        Test.startTest();

            String testString2 = BillingLineItemServices.buildQueryWhere(testParameter, testParameter, testParameter, testParameter, testParameter, testParameter, testParameter, true, testParameter, true);
            String testString = BillingLineItemServices.buildQueryWhere(testParameter, testParameter, testParameter, testParameter, testParameter, testParameter, testParameter, true, testParameter, false);

        Test.stopTest();
        System.debug(LoggingLevel.error, '@@@expectedRes'+ expectedRes);
        System.debug(LoggingLevel.error, '@@@testString'+ testString);
        System.assert (!String.isEmpty(testString));
//        System.assertEquals (expectedRes, testString);
    }

    private static testMethod void testGenerateBillingLineItemsForMailroomTriggerWithPurchaseOrder(){
        setupData();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testMailroomList = new List<Mailroom__c>();
        for (Project_profile__c projectProfileItem : testProjectProfileList){
            for (Mailroom__c mailroomItem : TestingUtils.createMailRoomList(NUMBER_TO_CREATE_MAILROOM, false)){
                mailroomItem.Date_created__c = DateTime.now();
                mailroomItem.Project_Profile__c = projectProfileItem.Id;
                testMailroomList.add(mailroomItem);
            }
        }
        insert testMailroomList;

        testPurchaseOrderList = new List<Purchase_Order__c>();

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Purchase_Order__c purchaseOrderItem : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(),false)){
                purchaseOrderItem.Project_Profile__c = projectProfileItem.Id;
                purchaseOrderItem.NTE_Includes_Reimbursables__c = true;
                testPurchaseOrderList.add(purchaseOrderItem);
            }
        }
        insert testPurchaseOrderList;

        Test.startTest();

            BillingLineItemServices.generateBillingLineItemsForMailroomTrigger (new Map<Id, Mailroom__c>(testMailroomList));

        Test.stopTest();
    }

    private static testmethod void testUpdateBLIAfterProformaDeleted(){
        setupData();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    TestingUtils.testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProFormaInvoiceList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();

        for (Pro_forma_Invoice__c proformaInvoiceItem : testProFormaInvoiceList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false)){
                billingLineItem.Pro_forma_Invoice__c = proformaInvoiceItem.Id;
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Billed__c = false;
                testBillingLineItemList.add (billingLineItem);
            }
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false)){
                billingLineItem.Pro_forma_Invoice__c = proformaInvoiceItem.Id;
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING;
                billingLineItem.Billed__c = false;
                testBillingLineItemList.add (billingLineItem);
            }
        }
        insert testBillingLineItemList;
 
        Test.startTest();

            BillingLineItemServices.updateBLIAfterProformaDeleted(new Map<Id, Pro_forma_Invoice__c>(testProFormaInvoiceList));

        Test.stopTest();
 
        List <Billing_Line_Item__c> resultBillingLineItemList = [SELECT Id, Billed__c
                                                                 FROM Billing_Line_Item__c
                                                                 WHERE Pro_forma_Invoice__c IN : testProFormaInvoiceList AND
                                                                        Id IN : testBillingLineItemList AND
                                                                        Billed__c = true];

        System.assert(resultBillingLineItemList != null && resultBillingLineItemList.isEmpty());
    }
    
    private static testmethod void testNewInstance() {
        Task_Item__c taskItem    = new Task_Item__c();
        Vendor_Request__c vendor = new Vendor_Request__c();
        Billing_Line_Item__c bli = BillingLineItemServices.newInstance(taskItem, vendor);
    
    }
    
    private static testmethod void testupdateBLIisActiveField() {
        testTaskitemList = TestingUtils.createTaskItemList(2, true);

        BillingLineItemServices.updateBLIisActiveField(new Set<Id>(), new Set<Id>());
        BillingLineItemServices.updateBLIisActiveField(new Set<Id>{testTaskitemList[0].Id}, new Set<Id>{testTaskitemList[1].Id}, false);

        Test.startTest();
            BillingLineItemServices.updateBLIisActiveField(new Set<Id>{testTaskitemList[0].Id}, new Set<Id>{testTaskitemList[1].Id}, true);
        Test.stopTest();
    }
    
    private static testmethod void testDeActiveBillingLineItem() {
        Task_Item__c t = new Task_Item__c();
        insert t;
        
        BillingLineItemServices.deActiveBillingLineItem(new Set<Id> { t.Id });
    
    }


    private static testMethod void testDeActiveBillingLineItemDiffMethod() {
        prepareProjectsWithDifferentMethods();

        Test.startTest();

            BillingLineItemServices.deActiveBillingLineItem(new Map<Id, Task_Item__c>(testTaskitemList).keySet());

        Test.stopTest();
    }

    private static testmethod void testActiveBillingLineItem() {
        Task_Item__c t = new Task_Item__c();
        insert t;
        
        BillingLineItemServices.activeBillingLineItem(new Set<Id> { t.Id });
    
    }

    private static testMethod void testActiveBillingLineItemDiffMethod() {
        prepareProjectsWithDifferentMethods();

        Test.startTest();

            BillingLineItemServices.activeBillingLineItem(new Map<Id, Task_Item__c>(testTaskitemList).keySet());

        Test.stopTest();
    }

//public static Billing_Line_Item__c initRemainingHoursBli( Task_Item__c taskItem, Service_Item__c serviceItem, Project_Profile__c projectProfile, Map<Id, Service_Item__c> serviceItemMap, Boolean isCurrentlyPrebilling )

    private static testMethod void testInitRemainingHoursBli() {
        prepareProjectsWithDifferentMethods();

        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>(testProjectProfileList);
        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>(testServiceItemList);
        Task_Item__c processingTaskItem;
        Service_Item__c processingServiceItem;
        Project_Profile__c processingProjectProfile;
        for (Task_Item__c ti : testTaskitemList){
            if (ti.RecordTypeId == performHourlyConsultingRecordTypeId){
                processingTaskItem = ti;
                processingServiceItem = serviceItemMap.get(ti.Service_Item__c);
                processingProjectProfile = projectProfileMap.get(ti.Project_Profile__c);
                break;
            }
        }

        Test.startTest();

            BillingLineItemServices.initRemainingHoursBli(processingTaskItem, processingServiceItem, processingProjectProfile, serviceItemMap, true);
            BillingLineItemServices.initRemainingHoursBli(processingTaskItem, processingServiceItem, processingProjectProfile, serviceItemMap, false);

        Test.stopTest();
    }

    @isTest
    private static void testBuildQueryForBatch(){
        setupData();
        prepareData(50,true);

        List<Billing_Line_Item__c> billingLineItems = getAllBillingLineItems();
        System.assert(! billingLineItems.isEmpty());

        String fakeWhereClause = ' WHERE Id != null ';
        String queryStr = BillingLineItemServices.buildQueryForBatch(fakeWhereClause);

        billingLineItems = Database.query(queryStr);
        System.assert(! billingLineItems.isEmpty());
    }


    @isTest
    private static void testNewReimbursableLineItemShredding(){
        setupData();
        prepareData(50,true);      
        moreData();

        System.assert(! testServiceItemList.isEmpty());
        System.assert(! testProjectProfileList.isEmpty());

        testProjectProfileList.get(0).Reimbursable2__c = 5;
        Billing_Line_Item__c testLineItem = BillingLineItemServices.newReimbursableLineItemShredding(
                testServiceItemList.get(0),
                testProjectProfileList.get(0) );

        System.assert(testLineItem != null);
    }


    @isTest
    private static void testGetBillingLineItemListForTaskItemId(){
        setupData();
        prepareData(50,true);
        moreData();

        List<Billing_Line_Item__c> billingLineItems = getAllBillingLineItems();
        System.assert(! billingLineItems.isEmpty());

        System.assert(! testTaskitemList.isEmpty());
        
        billingLineItems.get(0).Task_Item__c = testTaskitemList.get(0).Id;
        update billingLineItems;

        List<Billing_Line_Item__c> items = BillingLineItemServices.getBillingLineItemListForTaskItemId(testTaskitemList.get(0).Id);
        System.assert(! items.isEmpty());
    }    

    @isTest
    private static void testGetBillingLineItemForMilstone(){
        setupData();
        prepareData(50,true);
        moreData();

        System.assert(! testServiceItemList.isEmpty());
        
        Set<Id> servItemIds = new Map<Id, Service_Item__c>(testServiceItemList).keySet();

        List<Billing_Line_Item__c> lineItems = BillingLineItemServices.getBillingLineItemForMilstone(servItemIds);
        //System.assert(lineItems.isEmpty());
    }

    @isTest
    private static void testGetBLIForMilstone(){
        setupData();
        prepareData(50,true);
        moreData();

        List<Billing_Line_Item__c> billingLineItems = getAllBillingLineItems();
        System.assert(! billingLineItems.isEmpty());
        System.assert(! testServiceItemList.isEmpty());
        System.assert(! testTaskitemList.isEmpty());

        Billing_Line_Item__c lineItem = BillingLineItemServices.getBLIForMilstone(
            billingLineItems, testTaskitemList.get(0).Id, testServiceItemList.get(0).Id);

    }    

    @isTest
    private static void testSetChangeOrderLookupAndServiceName(){
        setupData();
        prepareData(50,true);
        moreData();

        List<Billing_Line_Item__c> billingLineItems = getAllBillingLineItems();
        System.assert(! billingLineItems.isEmpty());

        billingLineItems.get(0).Task_Item__c = testTaskitemList.get(0).Id;
        update billingLineItems;

        BillingLineItemServices.setChangeOrderLookupAndServiceName(billingLineItems, false);   

    }
    
    @isTest
    private static void testGetReimbursableCreatedByClickLinkBLIByRelatedServiceId() {
        List<Billing_Line_Item__c> blis = BillingLineItemServices.getReimbursableCreatedByClickLinkBLIByRelatedServiceId(null);
        
        setupData();
        prepareData(50, true);
        
        Map<Id, Billing_Line_Item__c> bliMap = new Map<Id, Billing_Line_Item__c>(testBillingLineItemList);
        blis = BillingLineItemServices.getReimbursableCreatedByClickLinkBLIByRelatedServiceId(bliMap.keySet());
    
    }
    
    @isTest
    private static void testupdateBLIByMunicipalityIDForCreatedByClickLink() {
        setupData();
        prepareData(50,true);
        moreData();

        testServiceItemList[0].Municipal_Agency_ID__c = 'temp ID';

        Test.startTest();

            update testServiceItemList;

            BillingLineItemServices.updateBLIByMunicipalityIDForCreatedByClickLink(new List<Service_Item__c>(), new Map<Id, Service_Item__c>());

        Test.stopTest();
    }

    @isTest
    private static void testCalculateAmountsForBLI(){
        setupData();
        prepareData(50,true);
        moreData();

        System.assert(! testProjectProfileList.isEmpty() );

        List<Billing_Line_Item__c> billingLineItems = getAllBillingLineItems();

        Map<String, Decimal> amountTypeToAmount = new Map<String, Decimal>{
            BillingLineItemServices.UNBILLED_PERCENTAGE => 100,
            BillingLineItemServices.BILLED_AMOUNT => 100,
            BillingLineItemServices.BILLED_TAX1_AMOUNT => 100,
            BillingLineItemServices.BILLED_TAX2_AMOUNT => 100,
            BillingLineItemServices.TOTAL_TAX1_AMOUNT => 100,
            BillingLineItemServices.TOTAL_TAX2_AMOUNT => 100
        };

        //set required values
        billingLineItems.get(0).Unit_Price__c = 50.00;
        billingLineItems.get(0).Quantity__c = 100.00;
        billingLineItems.get(0).Sales_Tax_Amount_1__c = 100;
        billingLineItems.get(0).Sales_Tax_Amount_2__c = 200;

        testServiceItemList.get(0).Tax_Percent_1__c = 10;
        testServiceItemList.get(0).Tax_Percent_2__c = 20;
        testServiceItemList.get(0).Quantity__c = 100;
        testServiceItemList.get(0).Unit_Price__c = 50;
        testServiceItemList.get(0).Discount_Percentage__c = 2;

        testTaskitemList.get(0).Billing_Percentage__c = 15;

        UPSERT testServiceItemList.get(0);
        testServiceItemList[0] = [SELECT Id, Tax_Percent_1__c, Tax_Percent_2__c, Quantity__c, Unit_Price__c, Discount_Percentage__c, Discounted_Unit_Price__c
                                        FROM Service_Item__c
                                        WHERE Id = : testServiceItemList[0].Id];

        testProjectProfileList = [SELECT Id, Discounted_Total_Service_Amount__c, Billing_Method__c, Interval__c, Total_Service_Amount__c
                                  FROM Project_Profile__c
                                  WHERE Id = : testProjectProfileList[0].Id];

        BillingLineItemServices.calculateAmountsForBLI(
            testProjectProfileList.get(0),
            billingLineItems.get(0),
            testTaskitemList.get(0),
            testBlllingDateList.get(0),
            testServiceItemList.get(0),
            amountTypeToAmount );

        testProjectProfileList[0].Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
        testProjectProfileList[0].Interval__c = false;
        testProjectProfileList[0].Total_Service_Amount__c = 1000;
        testTaskitemList.get(0).Billing_Percentage__c = 20;
        BillingLineItemServices.calculateAmountsForBLI(
            testProjectProfileList.get(0),
            billingLineItems.get(0),
            testTaskitemList.get(0),
            testBlllingDateList.get(0),
            testServiceItemList.get(0),
            amountTypeToAmount );

        testProjectProfileList[0].Interval__c = true;
        BillingLineItemServices.calculateAmountsForBLI(
            testProjectProfileList.get(0),
            billingLineItems.get(0),
            testTaskitemList.get(0),
            testBlllingDateList.get(0),
            testServiceItemList.get(0),
            amountTypeToAmount );


        testProjectProfileList[0].Billing_Method__c = ProjectProfileServices.BILLINGMETHODINSTALLMENT;
        testProjectProfileList[0].Total_Service_Amount__c = 1000;
        testBlllingDateList.get(0).Percentage__c = 20;
        BillingLineItemServices.calculateAmountsForBLI(
            testProjectProfileList.get(0),
            billingLineItems.get(0),
            testTaskitemList.get(0),
            testBlllingDateList.get(0),
            testServiceItemList.get(0),
            amountTypeToAmount );

    }
}