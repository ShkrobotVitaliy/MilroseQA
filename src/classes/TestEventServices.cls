@isTest
private class TestEventServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_EVENT = 2;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Form_Item__c> testFormItemList;
    private static List<Form_Assignment__c> testFormAssignmentList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Event> testEventList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        
        
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, false);
        for (Project_Team__c projectTeamItem : testProjectTeamList){
            projectTeamItem.Project_Member__c = projectManagerUser.Id;
        }
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

    private static testmethod void testCreateEventsFromTaskItemIfAlertIfNotification(){
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

        testTaskItemList = [SELECT Id, OwnerId, Task_Alert__c, Task_Notification__c, Expected_Start_Date__c, Expected_End_Date__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Map<String, List<Task_Item__c>> eventSubjectToTaskItemsList = new Map<String, List<Task_Item__c>>{EventServices.TASK_ALERT_SUBJECT => testTaskItemList,
                                                                                                          EventServices.TASK_NOTIFICATION_SUBJECT => testTaskItemList};

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Task_Alert__c = true;
            taskItemItem.Task_Notification__c = true;
            taskItemItem.Expected_Start_Date__c = DateTime.now();
            taskItemItem.Expected_End_Date__c = DateTime.now();
        }

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList];

        System.assert(testEventList.isEmpty());

        Test.startTest();

            EventServices.createEventsFromTaskItemIfAlertIfNotification(eventSubjectToTaskItemsList);

        Test.stopTest();

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList];

        System.assert(!testEventList.isEmpty());
        System.assertEquals(testTaskItemList.size() * 2, testEventList.size());
    }
    //just for code coverage
    private static testmethod void testCreateEventsFromTaskItemIfAlertIfNotificationWithEmptyData(){
        Test.startTest();

            EventServices.createEventsFromTaskItemIfAlertIfNotification(null);

        Test.stopTest();

        System.assert( getAllEvents().isEmpty() );
    }

    private static testmethod void testCreateEventsFromTaskItemIfAlertIfNotificationWithIncorrectData(){
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

        testTaskItemList = [SELECT Id, OwnerId, Task_Alert__c, Task_Notification__c, Expected_Start_Date__c, Expected_End_Date__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Id incorrectTaskItemId = Id.valueOf(Task_Item__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        testTaskItemList.add(new Task_Item__c(Id = incorrectTaskItemId));

        Map<String, List<Task_Item__c>> eventSubjectToTaskItemsList = new Map<String, List<Task_Item__c>>{EventServices.TASK_ALERT_SUBJECT => testTaskItemList,
                                                                                                          EventServices.TASK_NOTIFICATION_SUBJECT => testTaskItemList};

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Task_Alert__c = true;
            taskItemItem.Task_Notification__c = true;
            taskItemItem.Expected_Start_Date__c = DateTime.now();
            taskItemItem.Expected_End_Date__c = DateTime.now();
        }

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList];

        System.assert(testEventList.isEmpty());

        String errorString = '';

        Test.startTest();

            try {
                EventServices.createEventsFromTaskItemIfAlertIfNotification(eventSubjectToTaskItemsList);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList];

        System.assert(testEventList.isEmpty());
        System.assert(errorString != null && !String.isEmpty(errorString));
    }

    private static testmethod void testDeleteEventsFromTaskItemIfAlertIfNotification(){
        setupData ();
                
        testTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
            taskItemItem.RecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get( TaskItemServices.SEND_FORMS_TASK_NAME );
            taskItemItem.Task_Alert__c = false;
            taskItemItem.Task_Notification__c = false;
            testTaskItemList.add(taskItemItem);
        }
        insert testTaskItemList;
        
        testFormItemList = new List<Form_Item__c>();
        for( Form_Item__c item: TestingUtils.createFormItemList(1, false)){
            item.Complete_Forms__c = testTaskItemList[0].Id;
            testFormItemList.add(item);
        }
        insert testFormItemList;
        testFormAssignmentList = TestingUtils.createFormAssignmentList(1, testFormItemList, true);
        for( Form_Assignment__c item: testFormAssignmentList){
            item.Alert_Calendar__c = Date.today();
            update item;
        }
        
        testEventList = new List<Event>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_ALERT_SUBJECT;
                testEventList.add(eventItem);
            }
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_NOTIFICATION_SUBJECT;
                testEventList.add(eventItem);
            }
        }
        insert testEventList;

        Test.startTest();
            EventServices.manageEventsForSignatureSealsTaskItem( testFormAssignmentList );
            EventServices.deleteEventsFromTaskItemIfAlertIfNotification(testTaskItemList);
            EventServices.deleteEventsFromTaskItemIfAlertIfNotification(testTaskItemList);

        Test.stopTest();

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList
                            AND (Subject =: EventServices.TASK_ALERT_SUBJECT Or Subject =: EventServices.TASK_NOTIFICATION_SUBJECT)];

        System.assert(testEventList.isEmpty());
    }

    private static testmethod void testDeleteEventsFromTaskItemIfAlertIfNotificationWithEmptyTaskItemList(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);
        testEventList = new List<Event>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_ALERT_SUBJECT;
                testEventList.add(eventItem);
            }
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_NOTIFICATION_SUBJECT;
                testEventList.add(eventItem);
            }
        }
        insert testEventList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Task_Alert__c = false;
            taskItemItem.Task_Notification__c = false;
        }

        Test.startTest();

            EventServices.deleteEventsFromTaskItemIfAlertIfNotification(new List<Task_Item__c>());

        Test.stopTest();

        testEventList = [SELECT Id
                         FROM Event
                         WHERE WhatId IN : testTaskItemList
                            AND (Subject =: EventServices.TASK_ALERT_SUBJECT Or Subject =: EventServices.TASK_NOTIFICATION_SUBJECT)];

        System.assert(!testEventList.isEmpty());
    }
    
    private static testmethod void testUpdateAssignedTo() {
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);
        testEventList = new List<Event>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_ALERT_SUBJECT;
                eventItem.Activitie_Id__c = Userinfo.getUserId();
                testEventList.add(eventItem);
            }
            for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                eventItem.WhatId = taskItemItem.Id;
                eventItem.Subject = EventServices.TASK_NOTIFICATION_SUBJECT;
                eventItem.Activitie_Id__c = Userinfo.getUserId();            
                testEventList.add(eventItem);
            }
        }
        insert testEventList;
        testEventList = [SELECT Id, Activitie_Id__c, OwnerId FROM Event WHERE WhatId IN : testTaskItemList]; 
        System.assert(testEventList[0].OwnerId == Userinfo.getUserId());      
    }    

    //helper DAO methods

    private static List<Event> getAllEvents(){
        return [SELECT Id, WhatId, Subject
                FROM Event];
    }

}