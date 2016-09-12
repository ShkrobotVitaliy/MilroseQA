@isTest
private class TestServiceItemTrigger {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 4;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 5;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Item__c> testMilestoneList;
    private static List<RecordType> recordTypeList;
    private static Id milestoneRecordTypeId;
    private static Id notMilestoneRecordTypeId;
    private static User projectManagerUser;

    //get Manager User and  TaskItem RecordType Ids for test
    private static void prepareData(){
        Map<String, Id> taskItemRecordTypeNameIdMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c');
        for (String recordTypeNameItem : taskItemRecordTypeNameIdMap.keySet()){
            if (recordTypeNameItem == TaskManagementServices.MILESTONE_RECORDTYPE_NAME){
                milestoneRecordTypeId = taskItemRecordTypeNameIdMap.get(recordTypeNameItem);
            } else {
                notMilestoneRecordTypeId = taskItemRecordTypeNameIdMap.get(recordTypeNameItem);
            }
        }
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
    }

    private static void setupData(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectProfileList = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, true );
    }

    private static void createServiceItemWithTaskItemForProjectProfile(Integer numberForCreateGroupsProjectWithServices){
        testServiceItemList = new List<Service_Item__c>();
        for (Integer i = 0; i < numberForCreateGroupsProjectWithServices; i++){
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItem.Project_Profile__c = projectProfileItem.Id;
                    serviceItem.Forms__c = 'TestForms';
                    testServiceItemList.add(serviceItem);
                }
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        Map<Id, Map<Integer, Task_Item__c>> temporaryMapServicesTasksSequenceNumberTasks = new Map<Id, Map<Integer, Task_Item__c>>();
        for (Service_Item__c serviceItem : testServiceItemList){
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            temporaryMapServicesTasksSequenceNumberTasks.put(serviceItem.Id, new Map<Integer, Task_Item__c>());
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Sequence_Number__c = sequenceNumber;
                taskItem.RecordTypeId = notMilestoneRecordTypeId;
                //taskItem.RecordTypeId = milestoneRecordTypeId;
                temporaryMapServicesTasksSequenceNumberTasks.get(serviceItem.Id).put(sequenceNumber, taskItem);
                testTaskItemList.add(taskItem);
                sequenceNumber++;
            }
        }
        insert testTaskItemList;
    }

    private static testmethod void testUpdateServiceItemChangePredecessoerSuccessorValuesWithExistingMilestones(){
        Map<Id, Map<String, Task_Item__c>> projectIdMilestoneTaskItem = new Map<Id, Map<String, Task_Item__c>>();
        List<Task_Item__c> tasksToUpdate = new List<Task_Item__c>();
        Set<String> milestoneTaskItemName = new Set<String>();        
        Integer sequenceNumber = 1;
        Integer sequenceNumber1 = 1;
        Integer succAndPredNubmer = 10;
        testMilestoneList = new List<Task_Item__c>();
        //get Manager User and  TaskItem RecordType Ids for test
        prepareData();
        //create Project Profiles for test
        setupData();      
        testServiceItemList = new List<Service_Item__c>();
        for (Integer i = 0; i < 5; i++){
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItem.Project_Profile__c = projectProfileItem.Id;
                    serviceItem.Forms__c = 'TestForms';
                    serviceItem.Predecessor_Milestone__c = 'Predecessor' + succAndPredNubmer;
                    serviceItem.Successor_Milestone__c = 'Successor' + succAndPredNubmer;
                    testServiceItemList.add(serviceItem);
                    milestoneTaskItemName.add(serviceItem.Predecessor_Milestone__c);
                    milestoneTaskItemName.add(serviceItem.Successor_Milestone__c);
                    succAndPredNubmer++;
                }
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        Map<Id, Map<Integer, Task_Item__c>> temporaryMapServicesTasksSequenceNumberTasks = new Map<Id, Map<Integer, Task_Item__c>>();
        for (Service_Item__c serviceItem : testServiceItemList){
            //Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            temporaryMapServicesTasksSequenceNumberTasks.put(serviceItem.Id, new Map<Integer, Task_Item__c>());
            projectIdMilestoneTaskItem.put(serviceItem.Project_Profile__c, new Map<String, Task_Item__c>());
            System.debug(Logginglevel.Error,'@@@projectIdMilestoneTaskItem' + projectIdMilestoneTaskItem);
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Name = 'Successor' + sequenceNumber;
                taskItem.Sequence_Number__c = sequenceNumber;
                taskItem.RecordTypeId = notMilestoneRecordTypeId;
                //taskItem.RecordTypeId = milestoneRecordTypeId;
                temporaryMapServicesTasksSequenceNumberTasks.get(serviceItem.Id).put(sequenceNumber, taskItem);
                testTaskItemList.add(taskItem);
                sequenceNumber++;
            }
        }
       
        for (Service_Item__c serviceItem : testServiceItemList){               
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Name = 'Predecessor' + sequenceNumber1;
                taskItem.Sequence_Number__c = sequenceNumber1;               
                taskItem.RecordTypeId = milestoneRecordTypeId;                
                testMilestoneList.add(taskItem);
                sequenceNumber1++;
            }
        }
            insert testMilestoneList;
        System.debug(Logginglevel.Error,'@@@testMilestoneList' + testMilestoneList);    
        for(Integer i = 0; i <= testMilestoneList.size()-2; i++){
            testTaskItemList[i].Successor_Milestone__c = testMilestoneList[i+1].Id;
            testTaskItemList[i+1].Predecessor_Milestone__c = testMilestoneList[i].Id;
        } 
            insert testTaskItemList;
        
        Integer updatedSuccAndPredNubmer = 1;
        for(Service_Item__c item : testServiceItemList){
            item.Predecessor_Milestone__c = 'Predecessor' + updatedSuccAndPredNubmer;
            item.Successor_Milestone__c = 'Successor' + updatedSuccAndPredNubmer;
            updatedSuccAndPredNubmer++;
        }
        List<Task_Item__c>  ttt = [SELECT Id, Name, Project_Profile__c, Service_Item__c, RecordTypeId, RecordType.Name, Sequence_Number__c,
                                                                                Predecessor_Milestone__c, Successor_Milestone__c, Service_Item__r.Predecessor_Milestone__c,
                                                                                Service_Item__r.Successor_Milestone__c
                                                                        FROM Task_Item__c
                                                                        WHERE Project_Profile__c IN :projectIdMilestoneTaskItem.keySet() AND
                                                                            ( ( RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME AND Name IN : milestoneTaskItemName )
                                                                                OR ( Service_Item__c IN: temporaryMapServicesTasksSequenceNumberTasks.KeySet() AND
                                                                                     ( Predecessor_Milestone__c != null OR Successor_Milestone__c != null )
                                                                            ) ) ];
        System.debug(Logginglevel.Error,'@@@ttt' + ttt);
        
        Test.startTest();
            update testServiceItemList;
        Test.stopTest();
        
        for (Task_Item__c taskItem : [SELECT Id, Name, Project_Profile__c, Service_Item__c, RecordTypeId, RecordType.Name, Sequence_Number__c,
                                                                                Predecessor_Milestone__c, Successor_Milestone__c, Service_Item__r.Predecessor_Milestone__c,
                                                                                Service_Item__r.Successor_Milestone__c
                                                                        FROM Task_Item__c
                                                                        WHERE Project_Profile__c IN :projectIdMilestoneTaskItem.keySet() AND
                                                                            ( ( RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME AND Name IN : milestoneTaskItemName )
                                                                                OR ( Service_Item__c IN: temporaryMapServicesTasksSequenceNumberTasks.KeySet() AND
                                                                                     ( Predecessor_Milestone__c != null OR Successor_Milestone__c != null )
                                                                            ) ) ] ) {
            if ( taskItem.RecordType.Name == TaskManagementServices.MILESTONE_RECORDTYPE_NAME ) {
                projectIdMilestoneTaskItem.get(taskItem.Project_Profile__c).put(taskItem.Name, taskItem);
            } else {
                tasksToUpdate.add( taskItem );
            }
        } 
        
        
        /*for(Task_Item__c taskItem : tasksToUpdate){         
            
            if( taskItem.Predecessor_Milestone__c != null ) {
                if( projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).containsKey( taskItem.Service_Item__r.Predecessor_Milestone__c ) ) {
                    System.assertEquals(projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Predecessor_Milestone__c ).Id, taskItem.Predecessor_Milestone__c);
                }
            }
            if( taskItem.Successor_Milestone__c != null ) {
                if( projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).containsKey( taskItem.Service_Item__r.Successor_Milestone__c ) ) {
                     System.assertEquals(projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Successor_Milestone__c ).Id, taskItem.Successor_Milestone__c);
                }
            }
            
        }*/
    }     
}