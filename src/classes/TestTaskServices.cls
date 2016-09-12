@isTest
private class TestTaskServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_COMMENT = 4;
    private static final Integer NUMBER_TO_CREATE_CHECK = 3;
    private static final String TEST_STATUS = 'In Progress';
    private static final String TEST_PRIORITY = 'High';
    private static final String TEST_SUBJECT = 'Test Subject';
    private static final String TEST_HTML_BODY = 'TestHtmlBody';
    private static final String TEST_DESCRIPTION = 'test description';
    private static Task_Item__c testOldTask;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Check__c> testCheckList;
    private static List<Opportunity> testOpportunityList;
    private static List<Account> testAccountList;
    private static DateTime testReminder;
    private static Date testActivityDate;

    private static void setUp(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestName', true);
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, true);
        testOldTask = new Task_Item__c();
        insert testOldTask;
        testCheckList = new List<Check__c>();
        for (Account accountItem : testAccountList){
            for (Task_Item__c taskItemItem : testTaskItemList){
                for (Check__c checkItem : TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, accountItem.Id, false)){
                    checkItem.Task_Item__c = taskItemItem.Id;
                    testCheckList.add(checkItem);
                }
            }
        }
        insert testCheckList;


        testReminder = DateTime.now().addDays(1);
        testActivityDate = Date.today();
    }

    @isTest( SeeAllData = true ) static void testUncoveredParts() {
        setUp();
        Dummy_Sharing__c dummySharing = new Dummy_Sharing__c();
        INSERT dummySharing;

        Project_Profile__c project = TestingUtils.createProjectProfileForTest( 1, true)[0];
        User user = TestingUtils.createUsers( 1, true)[0];
        Service_Item__c serviceItem = TestingUtils.createServiceItemList( 1, true)[0];

        Account testAccount = TestingUtils.createAccountList(1, 'TestAcc', false)[0];
        INSERT testAccount;

        Test.startTest();
            TaskServices.connectDummySharingRecordToTask( new List<Task> { new Task() } );
            String buildSelectByRelatedIds1 = TaskServices.buildSelectByRelatedIds( new Set<Id> { testCheckList[0].Id } );
            String buildSelectByRelatedIds2 = TaskServices.buildSelectByRelatedIds( new Set<Id>() );
            TaskServices.createTasksForARCoordinatorAfterCO( new Set<Id> { serviceItem.Id }, new Set<Id> { user.Id }, project.Id);

            c2g__codaInvoice__c salesInvoice;
            salesInvoice = TestingUtils.createSalesInvoiceList( 1, testAccount.Id, Date.today(), Date.today(), false)[0];
            salesInvoice.Billing_Company_Reference__c = testAccount.Id;
            salesInvoice.c2g__Account__c = testAccount.Id;
            salesInvoice.c2g__InvoiceStatus__c = 'In Progress';
            INSERT salesInvoice;



            TaskServices.createTasksForStaffAccountantsForSalesInvoices( new List<c2g__codaInvoice__c> { salesInvoice } );
        Test.stopTest();
    }

    private static testMethod void testCreateTask(){
        setUp();

        Test.startTest();

                TaskServices.createTask(UserInfo.getUserId (), TEST_STATUS, TEST_PRIORITY, testCheckList[0].Account__c, testReminder, testActivityDate, TEST_SUBJECT, TEST_DESCRIPTION, String.valueOf(testCheckList[0].Id));

        Test.stopTest();

        List<Task> resultTask = [SELECT Id
                                 FROM Task
                                 WHERE OwnerId =: UserInfo.getUserId () AND 
                                        Status =: TEST_STATUS AND
                                        Priority =: TEST_PRIORITY AND
                                        WhatId =: testAccountList[0].Id AND
                                        ReminderDateTime =: testReminder AND
                                        ActivityDate =: testActivityDate AND
                                        Subject =: TEST_SUBJECT];

        System.assert(resultTask != null && !resultTask.isEmpty());
        System.assertEquals (1, resultTask.size());
    }

    private static testMethod void testCreateTaskWithIncorrectData(){
        Id incorrectUserId = Id.valueOf(User.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        setUp();

        String errorStringValue;

        Test.startTest();

            try {
                TaskServices.createTask(incorrectUserId, TEST_STATUS, TEST_PRIORITY, testCheckList[0].Account__c, testReminder, testActivityDate, TEST_SUBJECT, TEST_DESCRIPTION, String.valueOf(testCheckList[0].Id));
            } catch (Exception ex) {
                errorStringValue = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorStringValue));
    }

    private static testMethod void testCreateTasksForStaffAccounts(){
        setUp();

        Map<Id, List<String>> testTaskItemWithComentsMap = new Map<Id, List<String>>();

        for (Task_Item__c taskItemItem : testTaskItemList){
            testTaskItemWithComentsMap.put(taskItemItem.Id, new List<String>());
            for (Integer i = 0; i <= NUMBER_TO_CREATE_COMMENT; i++){
                testTaskItemWithComentsMap.get(taskItemItem.Id).add('test comment' + String.valueOf(i));
            }
        }

        Map<Id, List<String>> testTaskItemWithRecordId = new Map<Id, List<String>>();
        for (Check__c checkItem : testCheckList){
            if (!testTaskItemWithRecordId.containsKey(checkItem.Task_Item__c)){
                testTaskItemWithRecordId.put(checkItem.Task_Item__c, new List<String>());
            }
            testTaskItemWithRecordId.get(checkItem.Task_Item__c).add(String.valueOf(checkItem.Id));
        }

        Set<Id> testSetUserId = new Map<Id, User> ([SELECT Id
                                                    FROM User
                                                    WHERE IsActive = true LIMIT 5]).keySet();

        List<Task> taskResultList;

        Test.startTest();
            taskResultList = TaskServices.createTasksForStaffAccounts(testSetUserId, TEST_STATUS, TEST_PRIORITY, testReminder, testActivityDate, TEST_SUBJECT, testTaskItemWithComentsMap, testTaskItemWithRecordId);
        Test.stopTest();

        System.assert(taskResultList != null && !taskResultList.isEmpty());
    }

    private static testMethod void testCreateTasksForStaffAccountsWithotParameter(){
        Map<Id, List<String>> testTaskItemWithComentsMap = new Map<Id, List<String>>();
        Map<Id, List<String>> testTaskItemWithRecordId = new Map<Id, List<String>>();

        Set<Id> testSetUserId = new Set<Id>();

        List<Task> taskResultList;

        Test.startTest();
            taskResultList = TaskServices.createTasksForStaffAccounts(testSetUserId, TEST_STATUS, TEST_PRIORITY, testReminder, testActivityDate, TEST_SUBJECT, testTaskItemWithComentsMap, testTaskItemWithRecordId);
        Test.stopTest();

        System.assert(taskResultList != null && taskResultList.isEmpty());
    }
    
    private static testMethod void testCreateTasksForARCoordinatorAfterCO() { 
        TaskServices.createTasksForARCoordinatorAfterCO(null, null, null);
    
    }
}