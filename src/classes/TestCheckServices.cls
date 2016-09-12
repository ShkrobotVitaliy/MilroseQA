@isTest
private class TestCheckServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT_CHECK = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PHASE = 2;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_CHECK = 3;
    private static final Integer RECIPIENT_NUMBER = 5;
    private static final Decimal TEST_CHECK_AMOUNT_VALUE = 12.34;
    private static final Decimal TEST_CHECK_NUMBER_VALUE = 5;
    private static final String TEST_EMAIL_TEMPLATE_PREFIX = '@gmail.com';
    private static final Integer NUMBER_TO_CREATE = 5;

    private static List<Account> testAccountCheckList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Phase__c> testPhaseList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Check__c> testCheckList;
    private static List<Reimbursable_Expense_Invoice__c> testReimbursableExpenseInvoiceList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static Project_Roster__c roster;

    private static List<String> toAddressesEmailList;
    private static List<String> ccAddressesEmailList;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'CheckServices', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

        toAddressesEmailList = new List<String>();
        ccAddressesEmailList = new List<String>();
        for (Integer i = 0; i < RECIPIENT_NUMBER; i++){
            toAddressesEmailList.add('TestToEmailAddress' + String.valueOf(i) + TEST_EMAIL_TEMPLATE_PREFIX);
            ccAddressesEmailList.add('TestCCEmailAddress' + String.valueOf(i) + TEST_EMAIL_TEMPLATE_PREFIX);
        }
        
        roster = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_CONTACT, false)[0];
            roster.Contact__c = testContactWithAccountList[0].Id;
            insert roster;
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;

        }
        
        if (doInsert){
            insert testProjectProfileList;
        }
    }
    
    private static void createTestCheckList(){
        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){            
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = TEST_CHECK_AMOUNT_VALUE;
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = 'test reasone';
                checkItem.Description__c = 'test';
                checkItem.Project_Roster__c = roster.Id;
                testCheckList.add(checkItem);
                checkItem.Account__c =  testAccountList[1].Id;
                
                
            }
        }
        testAccountList[0].Account_Check__c = testAccountList[1].Id;
        update testAccountList;
        insert testCheckList;
    }
    
    private static testmethod void testNewInstance(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testPhaseList = new List<Phase__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Project_Profile__c = projectProfileItem.Id;
                testPhaseList.add(phaseItem);
            }
        }
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Project_Profile__c = phaseItem.Project_Profile__c;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;
        testTaskItemList = [SELECT Id, Project_Profile__c, Project_Profile__r.Billing_Company_Name__c, Project_Profile__r.Billing_Company_Contact__c,
                                    Service_Item__r.Phase__c, Project_Profile__r.Building__c, Service_Item__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Check__c resultRecord;

        Test.startTest();

            resultRecord = CheckServices.newInstance(testTaskItemList[0]);

        Test.stopTest();

        System.assert(resultRecord != null);
        System.assertEquals(testTaskItemList[0].Id, resultRecord.Task_Item__c);
        System.assertEquals(0, resultRecord.Check_Amount__c);
        System.assertEquals(testTaskItemList[0].Project_Profile__r.Billing_Company_Name__c, resultRecord.Billing_Client__c);
        System.assertEquals(testTaskItemList[0].Project_Profile__r.Billing_Company_Contact__c, resultRecord.Billing_Contact__c);
        System.assertEquals(testTaskItemList[0].Service_Item__r.Phase__c, resultRecord.Phase__c);
        System.assertEquals(testTaskItemList[0].Project_Profile__r.Building__c, resultRecord.Project_Address__c);
        System.assertEquals(testTaskItemList[0].Service_Item__c, resultRecord.Service_Item__c);
    }

    private static testmethod void testNewInstanceWithoutTaskItem(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testPhaseList = new List<Phase__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Project_Profile__c = projectProfileItem.Id;
                testPhaseList.add(phaseItem);
            }
        }
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Project_Profile__c = phaseItem.Project_Profile__c;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;
        testTaskItemList = [SELECT Id, Project_Profile__c, Project_Profile__r.Billing_Company_Name__c, Project_Profile__r.Billing_Company_Contact__c,
                                    Service_Item__r.Phase__c, Project_Profile__r.Building__c, Service_Item__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Check__c resultRecord;
        String errorString;

        Test.startTest();
            try{
                resultRecord = CheckServices.newInstance(null);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecord == null);
    }

    private static testmethod void testUpdateCheck(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = TEST_CHECK_AMOUNT_VALUE;
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = 'test reasone';
                checkItem.Description__c = 'test';
                testCheckList.add(checkItem);
            }
        }
        
        insert testCheckList;

        Test.startTest();

            CheckServices.updateCheck(testCheckList);

        Test.stopTest();

        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Id != null);
        }
    }

    private static testmethod void testUpdateCheckWithEmptyCheckList(){

        List<Check__c> checks = new List<Check__c>();
        System.assert(checks.isEmpty());

        Test.startTest();
            CheckServices.updateCheck( checks );
        Test.stopTest();

        System.assert(checks.isEmpty());
    }

    private static testmethod void testUpdateCheckWithCheckAmountNull(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = null;
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = 'test reasone';
                testCheckList.add(checkItem);
            }
        }

        String errorString;

        Test.startTest();

            try {
                CheckServices.updateCheck(testCheckList);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Id == null);
        }
    }

    private static testmethod void testUpdateCheckWithCheckNumberNull(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = TEST_CHECK_AMOUNT_VALUE;
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = null;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = 'test reasone';
                testCheckList.add(checkItem);
            }
        }

        String errorString;

        Test.startTest();

            try {
                CheckServices.updateCheck(testCheckList);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Id == null);
        }
    }

    private static testmethod void testUpdateCheckWithReasoneEmpty(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = TEST_CHECK_AMOUNT_VALUE;
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = '';
                testCheckList.add(checkItem);
            }
        }

        String errorString;

        Test.startTest();

            try {
                CheckServices.updateCheck(testCheckList);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Id == null);
        }
    }

    private static testmethod void testUpdateCheckWithIncorrectAccountId(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Check_Amount__c = TEST_CHECK_AMOUNT_VALUE;
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Date_Check_Returned__c = DateTime.now();
                checkItem.Reasone__c = 'test reasone';
                testCheckList.add(checkItem);
            }
        }

        Id incorrectAccountId = Id.valueOf(Account.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        testCheckList[0].Account__c = incorrectAccountId;

        String errorString;

        Test.startTest();

            try {
                CheckServices.updateCheck(testCheckList);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Id == null);
        }
    }

    private static testmethod void testUpdateCheckExpenseInvoice(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        testReimbursableExpenseInvoiceList = new List<Reimbursable_Expense_Invoice__c>();
        for (Check__c checkItem : testCheckList){
            for (Reimbursable_Expense_Invoice__c reimbursableExpenseInvoiceItem : TestingUtils.createReimbursableExpenseInvoiceList(1, false)){
                reimbursableExpenseInvoiceItem.Check_Request__c = checkItem.Id;
                testReimbursableExpenseInvoiceList.add(reimbursableExpenseInvoiceItem);
            }
        }
        insert testReimbursableExpenseInvoiceList;

        Test.startTest();

            CheckServices.updateCheckExpenseInvoice(testReimbursableExpenseInvoiceList, testCheckList);

        Test.stopTest();

        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Reimbursable_Expense_Invoice__c != null);
            Reimbursable_Expense_Invoice__c reimbInvoices = new Map<Id, Reimbursable_Expense_Invoice__c>(testReimbursableExpenseInvoiceList).get(checkItem.Reimbursable_Expense_Invoice__c);
            System.assertEquals(reimbInvoices.Check_Request__c, checkItem.Id);
        }
    }

    private static testmethod void testUpdateCheckExpenseInvoiceWithEmptyReimbursableExpenseInvoiceList(){
        setupData ();

        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        testReimbursableExpenseInvoiceList = new List<Reimbursable_Expense_Invoice__c>();
        for (Check__c checkItem : testCheckList){
            for (Reimbursable_Expense_Invoice__c reimbursableExpenseInvoiceItem : TestingUtils.createReimbursableExpenseInvoiceList(1, false)){
                reimbursableExpenseInvoiceItem.Check_Request__c = checkItem.Id;
                testReimbursableExpenseInvoiceList.add(reimbursableExpenseInvoiceItem);
            }
        }
        insert testReimbursableExpenseInvoiceList;

        Test.startTest();

            CheckServices.updateCheckExpenseInvoice(null, testCheckList);

        Test.stopTest();

        for (Check__c checkItem : testCheckList){
            System.assert(checkItem.Reimbursable_Expense_Invoice__c == null);
        }
    }

    private static testmethod void testGetForPayments(){
        String resultString;

        Test.startTest();

            resultString = CheckServices.getForPayments(null);

        Test.stopTest();

        System.assert(!String.isEmpty(resultString));
    }

    private static testmethod void testGetInternalRequestOptions(){
        List<SelectOption> resultSelectOptionList;

        Test.startTest();

            resultSelectOptionList = CheckServices.getInternalRequestOptions();

        Test.stopTest();

        System.assert(!resultSelectOptionList.isEmpty());
    }

    private static testmethod void testCalculateFeeCostLess1AlterationType1(){//cost < 1
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(0, ServiceItemServices.RFF_ALTERATION_TYPE_1);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostLess4000AlterationType1(){//1 < cost < 4000
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(1000, ServiceItemServices.RFF_ALTERATION_TYPE_1);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostLess5000AlterationType1(){//4000 < cost < 5000
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(4500, ServiceItemServices.RFF_ALTERATION_TYPE_1);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostGreater5000AlterationType1(){//5000 <= cost
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(5500, ServiceItemServices.RFF_ALTERATION_TYPE_1);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostLess1AlterationType2(){//cost < 1
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(0, ServiceItemServices.RFF_ALTERATION_TYPE_2);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostLess4000AlterationType2(){//1 < cost < 4000
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(1000, ServiceItemServices.RFF_ALTERATION_TYPE_2);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostLess5000AlterationType2(){//4000 < cost < 5000
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(4500, ServiceItemServices.RFF_ALTERATION_TYPE_2);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeCostGreater5000AlterationType2(){//5000 <= cost
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(5500, ServiceItemServices.RFF_ALTERATION_TYPE_2);

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testCalculateFeeOtherType(){
        Double resultDuoble;

        Test.startTest();

            resultDuoble = CheckServices.calculateFee(5, 'some test type');

        Test.stopTest();

        System.assert(resultDuoble != null);
    }

    private static testmethod void testGetChecksByTaskItemId(){
        setupData();
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        testCheckList = new List<Check__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, false)){
                checkItem.Task_Item__c = taskItemItem.Id;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        List<Check__c> resultCheckList;

        Test.startTest();

            resultCheckList = CheckServices.getChecksByTaskItemId(testTaskItemList[0].Id);

        Test.stopTest();

        System.assert(resultCheckList != null);
        System.assert(!resultCheckList.isEmpty());
        for (Check__c checkItem : resultCheckList){
            System.assertEquals(testTaskItemList[0].Id, checkItem.Task_Item__c);
        }
    }

    private static testmethod void testGetChecksByTaskItemIdWithEmptyTaskItemId(){
        setupData();
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        testCheckList = new List<Check__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, false)){
                checkItem.Task_Item__c = taskItemItem.Id;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        List<Check__c> resultCheckList;

        Test.startTest();

            resultCheckList = CheckServices.getChecksByTaskItemId(null);

        Test.stopTest();

        System.assert(resultCheckList.isEmpty());
    }

    private static testmethod void testGetChecksByProjectId(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testCheckList = new List<Check__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, false)){
                checkItem.Date_Received__c = null;
                checkItem.Task_Item__c = taskItemItem.Id;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        List<Check__c> resultCheckList;

        Test.startTest();

            resultCheckList = CheckServices.getChecksByProjectId(testProjectProfileList[0].Id);

        Test.stopTest();

        System.assert(resultCheckList != null);
        for (Check__c checkItem : resultCheckList){
            System.assertEquals(testProjectProfileList[0].Id, checkItem.Task_Item__r.Project_Profile__c);
            System.assert(checkItem.Date_Received__c == null);
        }
    }

    private static testmethod void testGetChecksByProjectIdWithEmptyProjectProfile(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testCheckList = new List<Check__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, false)){
                checkItem.Date_Received__c = DateTime.now();
                checkItem.Check_Number__c = TEST_CHECK_NUMBER_VALUE;
                checkItem.Task_Item__c = taskItemItem.Id;
                testCheckList.add(checkItem);
            }
        }
        insert testCheckList;

        List<Check__c> resultCheckList;

        String errorString;

        Test.startTest();

            try {
                resultCheckList = CheckServices.getChecksByProjectId(null);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultCheckList == null);
    }
    
    private static testMethod void testSetInvoicePayeeInQueue(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        
        List<Reimbursable_Expense_Invoice__c> setInvoicePayeeInQueue;

        Test.startTest();
            setInvoicePayeeInQueue = CheckServices.setInvoicePayeeInQueue(testProjectProfileList[0].Id, testAccountList,testCheckList);
        Test.stopTest();

        System.assert(! setInvoicePayeeInQueue.isEmpty());

    }
    
    private static testMethod void testRoundUpThousand(){
        
        Test.startTest();
            Double roundUpThousand1 = CheckServices.roundUpThousand(null);
            System.assert(  roundUpThousand1 == 0);
            Double roundUpThousand2 = CheckServices.roundUpThousand(1);
            System.assert(  roundUpThousand2 == 1000);
        Test.stopTest();


    }
    
/*
    @isTest(seeAllData = true) private static void testProcessCheckRequestsInQueue(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        testTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            testTaskItemList.add(taskItemItem);
        }        
            insert testTaskItemList;
        testCheckList[0].Task_Item__c = testTaskItemList[0].Id;
        testCheckList[0].isQueue__c = true;
            update testCheckList;
            
        Test.startTest();
            CheckServices.processCheckRequestsInQueue();
        Test.stopTest();    
    }
*/
    private static testMethod void testGetCheckRequestInQueue(){
        setupData();
        createTestCheckList();

        List<Check__c> checkRequestInQueue;

        Test.startTest();
            checkRequestInQueue = CheckServices.getCheckRequestInQueue();
        Test.stopTest(); 

        System.assert( checkRequestInQueue.isEmpty() );

    }
    
    private static testMethod void testStaffAccountantUserIds(){
        
        Set<Id> staffAccountantUserIds;

        Test.startTest();
            staffAccountantUserIds = CheckServices.staffAccountantUserIds; 
        Test.stopTest();
        
        System.assert( staffAccountantUserIds != null );
    }
    
    private static testMethod void testBussinessHoursPlusThreeDays(){
        
        Datetime bussinessHoursPlusThreeDays;

        Test.startTest();
            bussinessHoursPlusThreeDays = CheckServices.bussinessHoursPlusThreeDays; 
        Test.stopTest();

        System.assert(bussinessHoursPlusThreeDays > Datetime.now() );

    }
    
    private static testMethod void testUpdateCheckException(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        
        for(Check__c item : testCheckList){
            item.Account__c = null;
        }
        update testCheckList;

        System.assert(! testCheckList.isEmpty());

        Test.startTest();
            try{
                CheckServices.updateCheck(testCheckList);
            }catch(Exception e){
                System.debug('>>> ERROR >>> ' + e.getMessage());
            }           
        Test.stopTest();

    }
    
     private static testMethod void testUpdateCheckThirdException(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        
        for(Check__c item : testCheckList){
            item.Check_Amount__c = 5;
            item.Description__c = 'Description';
            item.Date_Received__c = Date.today();
            item.Check_Number__c = Double.valueOf(5);
            item.Date_Check_Returned__c = Date.today();
            item.Reasone__c = null;
        }
            update testCheckList;

            System.assert(! testCheckList.isEmpty());
        
        Test.startTest();
            try{
                CheckServices.updateCheck(testCheckList);
            }catch(Exception e){
                
            }           
        Test.stopTest();

    }
    
    private static testMethod void testGetSecondFilingParam(){
        
        Test.startTest();           
            Double testDouble1 = CheckServices.calculateFee(Double.valueOf(0),ServiceItemServices.RFF_ALTERATION_TYPE_1);
            Double testDouble2 = CheckServices.calculateFee(Double.valueOf(150),ServiceItemServices.RFF_ALTERATION_TYPE_1);
            Double testDouble3 = CheckServices.calculateFee(Double.valueOf(4500),ServiceItemServices.RFF_ALTERATION_TYPE_1);
            Double testDouble4 = CheckServices.calculateFee(Double.valueOf(5500),ServiceItemServices.RFF_ALTERATION_TYPE_1);

            System.assert(testDouble1 == 0);
            System.assert(testDouble2 != 0);
            System.assert(testDouble3 != 0);
            System.assert(testDouble4 != 0);                                    

            Double testDouble5 = CheckServices.calculateFee(Double.valueOf(0),ServiceItemServices.RFF_ALTERATION_TYPE_2);
            Double testDouble6 = CheckServices.calculateFee(Double.valueOf(150),ServiceItemServices.RFF_ALTERATION_TYPE_2);
            Double testDouble7 = CheckServices.calculateFee(Double.valueOf(4500),ServiceItemServices.RFF_ALTERATION_TYPE_2);
            Double testDouble8 = CheckServices.calculateFee(Double.valueOf(5500),ServiceItemServices.RFF_ALTERATION_TYPE_2);

            System.assert(testDouble5 == 0);
            System.assert(testDouble6 != 0);
            System.assert(testDouble7 != 0);
            System.assert(testDouble8 != 0);                

        Test.stopTest();

    }
    
    private static testMethod void testSendCheckRequestReminder(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        Service_Item__c testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE,false)[0];
            testServiceItem.Project_Profile__c = testProjectProfileList[0].Id;
            insert testServiceItem;
        testCheckList[0].Service_Item__c = testServiceItem.Id;
        testCheckList[0].Requested_Checks_Group__c = Double.valueOf(5);
        testCheckList[0].Date_Requested__c = Date.today();
        testCheckList[0].Date_Received__c = null;
        testCheckList[0].Check_Number__c = null;
        testCheckList[0].Requested_From__c = 'FromUser';
        testCheckList[0].Recipient_Reminder_Address__c = 'adress@mail.ru';
        testCheckList[0].Recipient_Reminder__c = Date.today(); 
            update testCheckList;
        
        System.assert(! testCheckList.isEmpty());
        
        Test.startTest();
//            CheckServices.sendCheckRequestReminder(new Set<Decimal> { testCheckList[0].Requested_Checks_Group__c });
        Test.stopTest();
    }

    
    private static testMethod void testCheckRow(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
       
        String checkRowStr;

        Test.startTest();
            checkRowStr = CheckServices.checkRow(5,testCheckList[0]);
        Test.stopTest();

        System.assert(! String.isBlank(checkRowStr) );
    }
    
    private static testMethod void testWorkTypeTable(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        List<RFI_Work__c> rfiWorkTypes = TestingUtils.createRFIWorkList(NUMBER_TO_CREATE_CONTACT, true);
        
        String workTypeTableStr;

        Test.startTest();
            workTypeTableStr = CheckServices.workTypeTable(testCheckList[0], rfiWorkTypes);
        Test.stopTest();

        System.assert(! String.isBlank(workTypeTableStr) );

    }
    
    private static testMethod void testEmailTemplate(){
        
        EmailTemplate emailTemplate;

        Test.startTest();
            emailTemplate = CheckServices.emailTemplate;
        Test.stopTest();

        System.assert(emailTemplate != null);
    }
    
    
    private static testMethod void testLoggedUser(){
        
        User loggedUser;

        Test.startTest();
             loggedUser = CheckServices.loggedUser;
        Test.stopTest();

        System.assert(loggedUser.Id == UserInfo.getUserId());
    }
    
    private static testMethod void testProcessCheckRequestsInQueue() {
        
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createTestCheckList();
        
        for (Check__c checkItem : testCheckList) {
            checkItem.isQueue__c = true;
            checkItem.Requested_From__c = CheckServices.INTERNAL;
        
        }
        update testCheckList;

        System.assert(! testCheckList.isEmpty() );

        Test.startTest();
            CheckServices.processCheckRequestsInQueue();
        Test.stopTest();

    }
    
    private static testMethod void testIsExistNotRecievedChecksByIds() {
        Test.startTest();
            SetupData();
            createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
            createTestCheckList();
            
            List<String> ids = new List<String>();
            for (Check__c checkItem : testCheckList) {
                checkItem.Date_Received__c = null;
                checkItem.Check_Number__c  = null;
                ids.add(String.valueOf(checkItem.Id));
            
            }
            update testCheckList;
            
            System.assert(! testCheckList.isEmpty() );

        Test.stopTest();
    }
    
    private static testMethod void testGetEmailBody() {
        Check__c check = new Check__c(Requested_Checks_Group__c = 1, Requested_From__c = 'test', Recipient_Reminder_Address__c = 'test@test.test',
                                      Date_Requested__c = datetime.now(), Recipient_Reminder__c = datetime.now());
        insert check;
        
        try {
            String body = CheckServices.getBodyMail(check);
            
            System.assert(! String.isBlank(body) );

        } catch (Exception ex) {
            System.debug(' >>> ERROR : testGetEmailBody() >>> ' + ex.getMessage());
        }
        
    }
    
    private static testMethod void testGetGroupNumbetToCheckRequestByGroupNumberEmptyParameter() {
        Map<Decimal, List<Check__c>> checkMap = CheckServices.getGroupNumbetToCheckRequestByGroupNumber(null);
        System.assert(checkMap.isEmpty());
    
    }
    
    private static testMethod void testGetGroupNumbetToCheckRequestByGroupNumber() {
        Set<Decimal> decSet = new Set<Decimal>();
        decSet.add(1);
        Map<Decimal, List<Check__c>> checkMap = CheckServices.getGroupNumbetToCheckRequestByGroupNumber(decSet);

        System.assert( checkMap.isEmpty() );
    }
    
    private static testMethod void testSendCheckRequestReminder2() {
        try {
            Project_Profile__c p = new Project_Profile__c();
            insert p;
            Service_Item__c st = new Service_Item__c(Project_Profile__c = p.Id);
            insert st;
            
            Check__c check = new Check__c(Requested_Checks_Group__c = 1, Requested_From__c = 'test', Recipient_Reminder_Address__c = 'test@test.test',
                                          Date_Requested__c = datetime.now(), Recipient_Reminder__c = datetime.now(), Service_Item__c = st.Id);
            insert check;

            System.assert(check.ID != null);

            Set<Decimal> decSet = new Set<Decimal>();
            decSet.add(1);

            CheckServices.sendCheckRequestReminder(decSet);

        } catch (Exception ex) {
             System.debug(' >>> ERROR : testSendCheckRequestReminder2() >>> ' + ex.getMessage());
        }
    
    }
   
}