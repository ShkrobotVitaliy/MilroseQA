@isTest
private class TestCreateBillingLineItemBatch {
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_BILLING_DATE = 3;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                    ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Billing_Date__c> testBillingDateList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User projectManagerUser;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'BillingLineItemBarch', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
    }

    private static void prepareData (Boolean doInsert){
        testProjectProfileList = new List<Project_Profile__c>();

        testProposalList = TestingUtils.createProposalListForTest(BILLING_METHOD_VALUES_LIST.size() * NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Discounted_Total_Service_Amount__c = 1.1;
        }
        insert testProposalList;

        Integer i = 0;

        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Billing_Method__c = billingMethodItem;
                projectProfileItem.Interval__c = true;
                projectProfileItem.Building__c = testBuildingList[0].id;
                projectProfileItem.Frequency__c = DateUtils.MONTHLY;
                projectProfileItem.Expected_Construction_Start_Date__c = Date.today();
                projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(1);
                projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                projectProfileItem.Total_Service_Amount__c = TOTAL_PROJECT_AMOUNT;
                projectProfileItem.Proposal__c = testProposalList[i].Id;
                testProjectProfileList.add(projectProfileItem);
                i++;
            }
        }
        insert testProjectProfileList;
        testBillingDateList = new List<Billing_Date__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Date dateItem = Date.today();
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, dateItem, projectProfileItem.Id, false)){
                billingDateItem.Percentage__c = dateItem == Date.today() ? 1 : 0;
                testBillingDateList.add(billingDateItem);
                dateItem.addDays(1);
            }
        }
        if (doInsert){
            insert testBillingDateList;
        }
    }

    private static testmethod void testBatchWithoutParameter (){
        setupData();
        prepareData(true);
        CreateBillingLineItemBatch testCreateBillingLineItemBatch;
        ID batchprocessid;

        Test.startTest();
            testCreateBillingLineItemBatch = new CreateBillingLineItemBatch();
            batchprocessid = Database.executeBatch(testCreateBillingLineItemBatch);
        Test.stopTest();

        testBillingLineItemList = [ SELECT Id, Milestone_Date__c, Project_Profile__c, Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact_Company__c,
                                        Accounting_Contact__c, Project_Profile__r.Accounting_Contact__c, Billing_Client__c, Project_Profile__r.Billing_Company_Name__c,
                                        Billing_Contact__c, Project_Profile__r.Billing_Company_Contact__c, Billing_Method__c, Project_Profile__r.Billing_Method__c,
                                        Client_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Address__c, Project_Profile__r.Building__c
                                    FROM Billing_Line_Item__c];
        System.assertEquals((BILLING_METHOD_VALUES_LIST.size() - 1) * NUMBER_TO_CREATE_PROJECT_PROFILE * NUMBER_TO_CREATE_BILLING_DATE, testBillingLineItemList.size(), 'bds = ' + String.valueOf(BILLING_METHOD_VALUES_LIST.size() - 1) + ' pp = ' + String.valueOf( NUMBER_TO_CREATE_PROJECT_PROFILE) + ' bd = ' + String.valueOf( NUMBER_TO_CREATE_BILLING_DATE ));
        for (Billing_Line_Item__c billingLineItem : testBillingLineItemList){
            System.assertEquals(Date.today(), billingLineItem.Milestone_Date__c);
            System.assert(billingLineItem.Project_Profile__c != null);
            System.assertEquals(billingLineItem.Project_Profile__r.Accounting_Contact_Company__c, billingLineItem.Accounting_Contact_Company__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Accounting_Contact__c, billingLineItem.Accounting_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Company_Name__c, billingLineItem.Billing_Client__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Company_Contact__c, billingLineItem.Billing_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Method__c, billingLineItem.Billing_Method__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Primary_Company_Contact__c, billingLineItem.Client_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Building__c, billingLineItem.Project_Address__c);
        }
    }

    private static testmethod void testBatchWithParameter (){
        setupData();
        prepareData(true);
        CreateBillingLineItemBatch testCreateBillingLineItemBatch;
        ID batchprocessid;

        Test.startTest();
            testCreateBillingLineItemBatch = new CreateBillingLineItemBatch(TaskItemServices.getTaskItemBillingMethodQuery(Date.today()), Date.today());
            batchprocessid = Database.executeBatch(testCreateBillingLineItemBatch);
        Test.stopTest();

        testBillingLineItemList = [ SELECT Id, Milestone_Date__c, Project_Profile__c, Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact_Company__c,
                                        Accounting_Contact__c, Project_Profile__r.Accounting_Contact__c, Billing_Client__c, Project_Profile__r.Billing_Company_Name__c,
                                        Billing_Contact__c, Project_Profile__r.Billing_Company_Contact__c, Billing_Method__c, Project_Profile__r.Billing_Method__c,
                                        Client_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Address__c, Project_Profile__r.Building__c
                                    FROM Billing_Line_Item__c];
        //System.assertEquals( 2 * NUMBER_TO_CREATE_BILLING_DATE, testBillingLineItemList.size());
        for (Billing_Line_Item__c billingLineItem : testBillingLineItemList){
            System.assertEquals(Date.today(), billingLineItem.Milestone_Date__c);
            System.assert(billingLineItem.Project_Profile__c != null);
            System.assertEquals(billingLineItem.Project_Profile__r.Accounting_Contact_Company__c, billingLineItem.Accounting_Contact_Company__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Accounting_Contact__c, billingLineItem.Accounting_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Company_Name__c, billingLineItem.Billing_Client__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Company_Contact__c, billingLineItem.Billing_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Billing_Method__c, billingLineItem.Billing_Method__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Primary_Company_Contact__c, billingLineItem.Client_Contact__c);
            System.assertEquals(billingLineItem.Project_Profile__r.Building__c, billingLineItem.Project_Address__c);
        }
    }

    private static testmethod void testScheduleJob (){
        String jobExpretion = '0 0 0 3 9 ? 2022';
        String nextTimeJob = '2022-09-03 00:00:00';
        String jobId;

        Test.startTest();
            jobId = System.schedule('testScheduledApex', jobExpretion, new CreateBillingLineItemBatch());
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
        System.assertEquals(jobExpretion, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
    }

}