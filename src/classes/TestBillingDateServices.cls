@isTest
private class TestBillingDateServices {
    private static final Integer NUMBER_TO_CREATE_BILLING_DATE = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Decimal TEST_TOTAL_AMOUNT = 12.34;
    private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
    private static final Decimal TEST_BILLING_PERCENTAGE = 4.5;
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                    ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Billing_Date__c> testBillingDateList;
    private static List<BillingDateWrapper> testBillingDateWrapperList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData(){
        projectManagerUser = TestingUtils.userWithProfile( UserServices.PROFILE_PROJECT_MANAGER_2 );
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void createProjectProfile(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = new List<Project_Profile__c>();
        testProposalList = new List<Proposal__c>();
        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            for (Proposal__c proposalItem : TestingUtils.createProposalListForTest(numberToCreate, false) ){
                proposalItem.Discounted_Total_Service_Amount__c = 1;
                testProposalList.add(proposalItem);
            }

            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Billing_Method__c = billingMethodItem;
                projectProfileItem.Building__c = testBuildingList[0].id;
                projectProfileItem.Frequency__c = DateUtils.MONTHLY;
                projectProfileItem.Expected_Construction_Start_Date__c = Date.today();
                projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(1);
                projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                projectProfileItem.Total_Service_Amount__c = TOTAL_PROJECT_AMOUNT;
                projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
                projectProfileItem.Project_Manager__c = projectManagerUser.Id;
                testProjectProfileList.add(projectProfileItem);
            }
        }

        insert testProposalList;

        if(doInsert){
            for (Integer i = 0; i < testProjectProfileList.size(); i++){
                testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
            }
            insert testProjectProfileList;
        }
    }

    @isTest
    private static void testCheckTotalsPercentageCheked(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testBillingDateList = new List<Billing_Date__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, Date.today(), projectProfileItem.Id, false)){
                billingDateItem.Percentage__c = 0;
                testBillingDateList.add(billingDateItem);
            }
        }
        testBillingDateList[0].Percentage__c = 100;
        testBillingDateWrapperList = new List<BillingDateWrapper>();
        for (Billing_Date__c billingDateItem : testBillingDateList){
            testBillingDateWrapperList.add(new BillingDateWrapper(billingDateItem, TEST_TOTAL_AMOUNT, null));
        }

        Boolean resultCheck;

        Test.startTest();
            resultCheck = BillingDateServices.checkTotalsPercentage(testBillingDateWrapperList);
        Test.stopTest();

        System.assert(resultCheck);
    }

    @isTest
    private static void testCheckTotalsPercentageUncheked(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testBillingDateList = new List<Billing_Date__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, Date.today(), projectProfileItem.Id, false)){
                billingDateItem.Percentage__c = 0;
                testBillingDateList.add(billingDateItem);
            }
        }
        testBillingDateWrapperList = new List<BillingDateWrapper>();
        for (Billing_Date__c billingDateItem : testBillingDateList){
            testBillingDateWrapperList.add(new BillingDateWrapper(billingDateItem, TEST_TOTAL_AMOUNT, null));
        }

        Boolean resultCheck;

        Test.startTest();
            resultCheck = BillingDateServices.checkTotalsPercentage(testBillingDateWrapperList);
        Test.stopTest();

        System.assert(!resultCheck);
    }

    @isTest
    private static void testGetBillingDatesByProjectId(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testBillingDateList = new List<Billing_Date__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, Date.today(), projectProfileItem.Id, false)){
                testBillingDateList.add(billingDateItem);
            }
        }
        insert testBillingDateList;

        List<Billing_Date__c> resultBillingDateList;

        Test.startTest();
            resultBillingDateList = BillingDateServices.getBillingDatesByProjectId(testProjectProfileList[0].Id);
        Test.stopTest();

        System.assert(!resultBillingDateList.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_BILLING_DATE, resultBillingDateList.size());
        for (Billing_Date__c billingDateItem : resultBillingDateList){
            System.assertEquals(testProjectProfileList[0].Id, billingDateItem.Project_Profile__c);
        }

		testProjectProfileList[0].Billing_day__c = '31';
		BillingDateServices.updateBillingDateFprProjectsPercentage(new Map<Id, Project_Profile__c> { testProjectProfileList[0].Id => testProjectProfileList[0]});
    }

    @isTest
    private static void testCreateBillingDateForProjectsWithoutChange(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = null;
            projectProfileItem.Billing_End_Date__c = null;
            projectProfileItem.Number_Of_Intervals__c = 5;
        }
        insert testProjectProfileList;

        testProjectProfileList = [SELECT Id, Project_Start_Date__c, Billing_End_Date__c, Number_Of_Intervals__c, Billing_Method__c,
                                            Frequency__c, Quarterly_Month__c, Billing_day__c, Discounted_Total_Service_Amount__c
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        Map<Id, Project_Profile__c> testProjectProfileMapOld = new Map<Id, Project_Profile__c>(testProjectProfileList.deepClone(true));

        Test.startTest();
            BillingDateServices.createBillingDateForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList));
        Test.stopTest();

        testBillingDateList = [SELECT Id
                               FROM Billing_Date__c
                               WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(testBillingDateList.isEmpty());
    }

    @isTest
    private static void testCreateBillingDateForProjectsWithChangeWithoutBillingDate(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = null;
            projectProfileItem.Billing_End_Date__c = null;
            projectProfileItem.Number_Of_Intervals__c = 5;
        }
        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
        }
        insert testProjectProfileList;

        testProjectProfileList = [SELECT Id, Project_Start_Date__c, Billing_End_Date__c, Number_Of_Intervals__c, Billing_Method__c,
                                            Frequency__c, Quarterly_Month__c, Billing_day__c, Discounted_Total_Service_Amount__c
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        Map<Id, Project_Profile__c> testProjectProfileMapOld = new Map<Id, Project_Profile__c>(testProjectProfileList.deepClone(true));

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = Date.today();
            projectProfileItem.Billing_End_Date__c = Date.today().addMonths(10);
        }

        Test.startTest();
            BillingDateServices.createBillingDateForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList));
        Test.stopTest();

        testBillingDateList = [SELECT Id
                               FROM Billing_Date__c
                               WHERE Project_Profile__c IN : testProjectProfileList];

        System.assert(!testBillingDateList.isEmpty());
    }

    @isTest
    private static void testCreateBillingDateForProjectsWithChangeWithBillingDate(){
        setupData();
        createProjectProfile(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = null;
            projectProfileItem.Billing_End_Date__c = null;
            projectProfileItem.Number_Of_Intervals__c = 5;
        }
        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
        }
        insert testProjectProfileList;

        testProjectProfileList = [SELECT Id, Project_Start_Date__c, Billing_End_Date__c, Number_Of_Intervals__c, Billing_Method__c,
                                            Frequency__c, Quarterly_Month__c, Billing_day__c, Discounted_Total_Service_Amount__c
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        Map<Id, Project_Profile__c> testProjectProfileMapOld = new Map<Id, Project_Profile__c>(testProjectProfileList.deepClone(true));

        testBillingDateList = new List<Billing_Date__c>();
        Boolean booleanItem = true;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = Date.today();
            projectProfileItem.Billing_End_Date__c = Date.today().addMonths(10);
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, projectProfileItem.Project_Start_Date__c, projectProfileItem.Id, false)){
                billingDateItem.Billed__c = booleanItem;
                billingDateItem.Percentage__c = TEST_BILLING_PERCENTAGE;
                testBillingDateList.add(billingDateItem);
                booleanItem = !booleanItem;
            }
        }
        insert testBillingDateList;

        Test.startTest();
            BillingDateServices.createBillingDateForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList));
        Test.stopTest();

        testBillingDateList = [SELECT Id
                               FROM Billing_Date__c
                               WHERE Id IN : testBillingDateList];
        
        System.assert(! testBillingDateList.isEmpty());

    }
}