@isTest
private class TestTaskManagementServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 4;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 4;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 5;
    private static final String TASK_TEMPLATE_NAME = 'test task template name';
    private static final String TEST_SUCCESSOR_MILESTONE = 'test succesoor';
    private static final String TEST_PREDECESSOR_MILESTONE = 'test prodecessor';
    private static final Integer PLANED_DURATION = 3;
    private static final Date START_DATE = Date.today();
    private static final Date END_DATE = Date.today().addDays(5);
    private static final String DELEY_END_DAY = '1d 1h';
    private static final String TEST_START_EXPECTED_DURATION = '5d 6h';
    private static final String TEST_START_DELAY_END_DATE = '3d 4h';
    private static final String TEST_DURATION_INCREMENT = '1d 2h';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Item__c> testPredecosserSuccessorTaskItemList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static User projectManagerUser;
    private static final BusinessHours bizHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

    private static void setupData(Date projectProfileStartDate){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'TaskManagementServices', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectProfileList = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false );
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Start_Date__c = projectProfileStartDate;
        }
        insert testProjectProfileList;
    }

    private static testmethod void testFindLongestDateForTask(){
        Set<id> setTaskItemId = new Set<Id>();
        String serviceName = 'some value';
        Datetime rusaltDatetime;
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Integer i = 0; i < testTaskItemList.size(); i++){
            testTaskItemList[i].Expected_End_Date__c = END_DATE.addDays(i);
            testTaskItemList[i].Delay_End_Date__c = i + 'h';
        }
        insert testTaskItemList;
        //populate TaskManagementServices.taskIdToTask map for test
        for (Task_Item__c taskItemItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItemItem.Id, taskItemItem);
            setTaskItemId.add(taskItemItem.Id);
        }

        Test.startTest();
            rusaltDatetime = TaskManagementServices.findLongestDateForTask(setTaskItemId, serviceName, null);
        Test.stopTest();

        System.assert(rusaltDatetime != null);

//  System.assertEquals(Datetime.newInstance(END_DATE.year(),
//                                                 END_DATE.month(),
//                                                 END_DATE.day(),
//                                                 NUMBER_TO_CREATE_TASK_ITEM - 1, 0, 0).addDays(NUMBER_TO_CREATE_TASK_ITEM - 1), rusaltDatetime);
    }

    private static testmethod void testFindLongestDateForTaskWithNullTaskId(){
        Set<id> setTaskItemId = new Set<Id>();
        String serviceName = 'some value';
        String exceptionValue;
        Datetime rusaltDatetime;
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Integer i = 0; i < testTaskItemList.size(); i++){
            testTaskItemList[i].Expected_End_Date__c = END_DATE.addDays(i);
            testTaskItemList[i].Delay_End_Date__c = i + 'h';
        }
        insert testTaskItemList;
        //populate TaskManagementServices.taskIdToTask map for test
        for (Task_Item__c taskItemItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItemItem.Id, taskItemItem);
            setTaskItemId.add(taskItemItem.Id);
        }
        setTaskItemId.add(null);//add null task Id

        Test.startTest();
            try{
                rusaltDatetime = TaskManagementServices.findLongestDateForTask(setTaskItemId, serviceName, testTaskItemList[0].Id);
                System.assert(false);
            } catch (TaskManagementServices.MilestoneException mEx){
                exceptionValue = mEx.getMessage();
            }
        Test.stopTest();

        System.assertEquals('Task Predecessors/Successor is not defined for Task in [' + serviceName + '] Service', exceptionValue);
    }

    private static testmethod void testFindLongestDateForTaskWithNullExpectedEndDate(){
        Set<id> setTaskItemId = new Set<Id>();
        String serviceName = 'some value';
        String exceptionValue;
        Datetime rusaltDatetime;
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Expected_End_Date__c = null;
        }
        insert testTaskItemList;
        //populate TaskManagementServices.taskIdToTask map for test
        for (Task_Item__c taskItemItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItemItem.Id, taskItemItem);
            setTaskItemId.add(taskItemItem.Id);
        }

        Test.startTest();
            try{
                rusaltDatetime = TaskManagementServices.findLongestDateForTask(setTaskItemId, serviceName, null);
                System.assert(false);
            } catch (TaskManagementServices.MilestoneException mEx){
                exceptionValue = mEx.getMessage();
            }
        Test.stopTest();

        System.assertEquals('[' + serviceName + '] Service cannot be processed. Maybe some of the Milestones are missing. Please recheck and finish setting up Milestones', exceptionValue);
    }

    private static testmethod void testCalculatePlannedDatesForTasks(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Expected_Start_Date__c = START_DATE;
        }
        insert testServiceItemList;
        testPredecosserSuccessorTaskItemList = new List<Task_Item__c>();
        Map<Id, Map<Boolean, Task_Item__c>> temporaryMapServiceSequenceTaskItem = new Map<Id, Map<Boolean, Task_Item__c>>();
        for (Service_Item__c serviceItem : testServiceItemList){
            List<Task_Item__c> temporaryItemPredecessorSuccessorTaskItemList = TestingUtils.createTaskItemList(2, serviceItem.Id, null, false);
            temporaryItemPredecessorSuccessorTaskItemList[0].Name = TEST_PREDECESSOR_MILESTONE;
            temporaryItemPredecessorSuccessorTaskItemList[1].Name = TEST_SUCCESSOR_MILESTONE;
            temporaryMapServiceSequenceTaskItem.put(serviceItem.Id, new Map<Boolean, Task_Item__c>{ true => temporaryItemPredecessorSuccessorTaskItemList[0],
                                                                                                    false => temporaryItemPredecessorSuccessorTaskItemList[1] });
            testPredecosserSuccessorTaskItemList.addAll(temporaryItemPredecessorSuccessorTaskItemList);
        }
        insert testPredecosserSuccessorTaskItemList;
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            TaskManagementServices.seqNumberToTaskItemForService.put(serviceItem.Id, new Map<Integer, Task_Item__c>());
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Predecessor_Milestone__c = sequenceNumber == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ?
                                                        (temporaryMapServiceSequenceTaskItem.get(serviceItem.Id).get(true)).Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumber == NUMBER_TO_CREATE_TASK_ITEM ?
                                                        (temporaryMapServiceSequenceTaskItem.get(serviceItem.Id).get(false)).Id : null;
                taskItemItem.Service_Item__c = serviceItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumber;
                taskItemItem.Name = 'test task name';
//        taskItemItem.Expected_Start_Date__c = START_DATE.addDays(sequenceNumber);
//        taskItemItem.Expected_End_Date__c = END_DATE.addDays(sequenceNumber);
                taskItemItem.Expected_End_Date__c = sequenceNumber == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ?
                                                    END_DATE : null;
                taskItemItem.Delay_End_Date__c = DELEY_END_DAY;
                taskItemItem.Successor_Task__c = null;
                taskItemItem.Predecessor_Task__c = null;
                testTaskItemList.add(taskItemItem);
                TaskManagementServices.seqNumberToTaskItemForService.get(serviceItem.Id).put(sequenceNumber, taskItemItem);
                sequenceNumber++;
            }
        }
        insert testTaskItemList;
        for (Task_Item__c taskItemItem : testTaskItemList){
            Integer sequenceNumber = Integer.valueOf(taskItemItem.Sequence_Number__c);
            if (TaskManagementServices.seqNumberToTaskItemForService.get(taskItemItem.Service_Item__c).containsKey(sequenceNumber + 1)){
                taskItemItem.Successor_Task__c = (TaskManagementServices.seqNumberToTaskItemForService.get(taskItemItem.Service_Item__c).get(sequenceNumber + 1)).Id;
            }
            if (TaskManagementServices.seqNumberToTaskItemForService.get(taskItemItem.Service_Item__c).containsKey(sequenceNumber - 1)){
                taskItemItem.Predecessor_Task__c = (TaskManagementServices.seqNumberToTaskItemForService.get(taskItemItem.Service_Item__c).get(sequenceNumber - 1)).Id;
            }
        }
        update testTaskItemList;
        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, taskItem);
            if(taskItem.Predecessor_Task__c != null){
                if (!TaskManagementServices.taskIdWithPredecessors.containsKey(taskItem.Id)){
                    TaskManagementServices.taskIdWithPredecessors.put(taskItem.Id, new Set<Id>());
                }
                TaskManagementServices.taskIdWithPredecessors.get(taskItem.Id).add(taskItem.Predecessor_Task__c);
            }
            if(taskItem.Successor_Task__c != null){
                if (!TaskManagementServices.taskIdWithSuccessors.containsKey(taskItem.Successor_Task__c)){
                    TaskManagementServices.taskIdWithSuccessors.put(taskItem.Successor_Task__c, new Set<Id>());
                }
                TaskManagementServices.taskIdWithSuccessors.get(taskItem.Successor_Task__c).add(taskItem.Id);
            }
        }

        Map<Id, Service_Item__c> mapIdServiceItem = new Map<Id, Service_Item__c>(testServiceItemList);

        Test.startTest();
            TaskManagementServices.calculatePlannedDatesForTasks(mapIdServiceItem, null, null);
        Test.stopTest();

        List<Task_Item__c> resultTaskItemList = [SELECT Id, Service_Item__c, Expected_Start_Date__c, Service_Item__r.Expected_Start_Date__c,
                                                        Sequence_Number__c, Expected_End_Date__c, Planned_Start_Date__c, Planned_End_Date__c, Planned_Durration__c
                                                 FROM Task_Item__c
                                                 WHERE Service_Item__c IN : testServiceItemList];

        System.assert(! resultTaskItemList.isEmpty());

        //for (Task_Item__c taskItem : resultTaskItemList){
          //  System.assert(taskItem.Expected_Start_Date__c != null && taskItem.Planned_Start_Date__c != null, taskItem);
          //  System.assertEquals(taskItem.Expected_Start_Date__c, taskItem.Planned_Start_Date__c, taskItem);
        
           // System.assert(taskItem.Expected_End_Date__c != null && taskItem.Planned_End_Date__c != null, taskItem);
           // System.assertEquals(taskItem.Expected_End_Date__c, taskItem.Planned_End_Date__c, taskItem);
           // System.assert(taskItem.Expected_Duration__c != null && taskItem.Planned_Durration__c != null, taskItem);
           // System.assertEquals(taskItem.Expected_Duration__c, taskItem.Planned_Durration__c, taskItem);
        //}
    }

    private static testmethod void testCollectTaskPredecessorsAndSuccessorsWithOnePredSuccessorForEachTask(){
        setupData(null);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItem :testServiceItemList){
            serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testServiceItemList;

        String testResultStringValue = '0d + 0h';

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            TaskManagementServices.seqNumberToTaskItemForService.put(serviceItem.Id, new Map<Integer, Task_Item__c>());

            String currentDuration = TEST_START_EXPECTED_DURATION;
            String currentDelayEndDate = TEST_START_DELAY_END_DATE;
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, testServiceItemList[0].Id, serviceItem.Project_Profile__c, false)){
                taskItem.Sequence_Number__c = sequenceNumber++;
                taskItem.Expected_Duration__c = currentDuration;
                taskItem.Delay_End_Date__c = currentDelayEndDate;
                taskItem.Predecessor_Task__c = null;
                taskItem.Successor_Task__c = null;

                TaskManagementServices.seqNumberToTaskItemForService.get(serviceItem.Id).put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);

                testTaskItemList.add(taskItem);
                currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
                currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

                testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
                testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
            }
        }
        insert testTaskItemList;

        for (Id serviceItemId : TaskManagementServices.seqNumberToTaskItemForService.keySet()){
            map<Integer, Task_Item__c> sequenceNumberTaskItemMap = TaskManagementServices.seqNumberToTaskItemForService.get(serviceItemId);
            for (Task_Item__c taskItem : sequenceNumberTaskItemMap.values()){
                Integer sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
                taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
                taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
            }
        }

        update testTaskItemList;

        Map<Id, Service_Item__c> testMapIdServiceItem = new Map<Id, Service_Item__c>(testServiceItemList);
        Test.startTest();
            TaskManagementServices.collectTaskPredecessorsAndSuccessors(testMapIdServiceItem, null, true, true);
        Test.stopTest();
    }

    private static testmethod void testCollectTaskPredecessorsAndSuccessors(){
        setupData(null);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItem :testServiceItemList){
            serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testServiceItemList;

        String testResultStringValue = '0d + 0h';

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            TaskManagementServices.seqNumberToTaskItemForService.put(serviceItem.Id, new Map<Integer, Task_Item__c>());

            String currentDuration = TEST_START_EXPECTED_DURATION;
            String currentDelayEndDate = TEST_START_DELAY_END_DATE;
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 3, testServiceItemList[0].Id, serviceItem.Project_Profile__c, false)){
                taskItem.Sequence_Number__c = sequenceNumber++;
                taskItem.Expected_Duration__c = currentDuration;
                taskItem.Delay_End_Date__c = currentDelayEndDate;
                taskItem.Predecessor_Task__c = null;
                taskItem.Successor_Task__c = null;

                TaskManagementServices.seqNumberToTaskItemForService.get(serviceItem.Id).put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);

                testTaskItemList.add(taskItem);
                currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
                currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

                testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
                testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
            }
        }
        insert testTaskItemList;

        for (Id serviceItemId : TaskManagementServices.seqNumberToTaskItemForService.keySet()){
            Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = TaskManagementServices.seqNumberToTaskItemForService.get(serviceItemId);
            for (Task_Item__c taskItem : sequenceNumberTaskItemMap.values()){
                Integer sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
                taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
                taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
            }
        }
        update testTaskItemList;

        for (Id serviceItemId : TaskManagementServices.seqNumberToTaskItemForService.keySet()){
            Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = TaskManagementServices.seqNumberToTaskItemForService.get(serviceItemId);

            sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 - 1).Id;
            sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM + 1).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM - 1).Id;
            sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 - 1).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM).Id;

            sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 1).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 3 - 1).Id;
            sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 2).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2).Id;
//this does not work
//        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 2).Id;
        }

        Map<Id, Service_Item__c> testMapIdServiceItem = new Map<Id, Service_Item__c>(testServiceItemList);
        Test.startTest();
            TaskManagementServices.collectTaskPredecessorsAndSuccessors(testMapIdServiceItem, null, true, true);
        Test.stopTest();
    }

    private static testmethod void testGetTotalDurationForServiceMi3(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        testTaskItemList = new List<Task_Item__c>();
        Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
        Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = new Map<Integer, Task_Item__c>();

        String testResultStringValue = '0d + 0h';

        String currentDuration = TEST_START_EXPECTED_DURATION;
        for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, testServiceItemList[0].Id, null, false)){
            taskItem.Sequence_Number__c = sequenceNumber++;
            taskItem.Expected_Duration__c = currentDuration;
            taskItem.Delay_End_Date__c = null;
            taskItem.Predecessor_Task__c = null;
            taskItem.Successor_Task__c = null;
            taskItem.Expected_Start_Date__c = Datetime.now();
            taskItem.Expected_End_Date__c = Datetime.now().addDays(30);
            sequenceNumberTaskItemMap.put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);
            testTaskItemList.add(taskItem);
            currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);

            testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
        }
        insert testTaskItemList;
        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
            sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
            taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
            taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
        }

        for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= testTaskItemList.size(); i++){
            Task_Item__c taskItem = sequenceNumberTaskItemMap.get(i);

            // Collect Predecessor Tasks for Successor
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

            // Collect Successor Tasks for Predecessor
            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );
        }
        TaskManagementServices.taskIdWithPredecessors.remove( null );
        TaskManagementServices.taskIdWithSuccessors.remove( null );

        String resultString;

        Test.startTest();

            resultString = TaskManagementServices.getTotalDurationForServiceMi3(sequenceNumberTaskItemMap, testTaskItemList[1].Id, false);

        Test.stopTest();
    }

    private static testmethod void testGetTotalDurationForServiceWithOneTaskItem(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        testTaskItemList = new List<Task_Item__c>();
        Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
        Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = new Map<Integer, Task_Item__c>();

        String testResultStringValue = '0d + 0h';

        String currentDuration = TEST_START_EXPECTED_DURATION;
        String currentDelayEndDate = TEST_START_DELAY_END_DATE;
        for (Task_Item__c taskItem : TestingUtils.createTaskItemList(1, testServiceItemList[0].Id, null, false)){
            taskItem.Sequence_Number__c = sequenceNumber++;
            taskItem.Expected_Duration__c = currentDuration;
            taskItem.Delay_End_Date__c = currentDelayEndDate;
            taskItem.Predecessor_Task__c = null;
            taskItem.Successor_Task__c = null;
            sequenceNumberTaskItemMap.put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);
            testTaskItemList.add(taskItem);
            currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
            currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

            testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
            testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
        }
        insert testTaskItemList;
        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
            sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
            taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
            taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
        }

        for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= testTaskItemList.size(); i++){
            Task_Item__c taskItem = sequenceNumberTaskItemMap.get(i);

            // Collect Predecessor Tasks for Successor
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

            // Collect Successor Tasks for Predecessor
            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );
        }
        TaskManagementServices.taskIdWithPredecessors.remove( null );
        TaskManagementServices.taskIdWithSuccessors.remove( null );

        String resultString;

        Test.startTest();
            resultString = TaskManagementServices.getTotalDurationForService(sequenceNumberTaskItemMap, null);
        Test.stopTest();

        System.assertEquals(testResultStringValue, resultString);
    }

    private static testmethod void testGetTotalDurationForServiceWithoutDelayEndDate(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        testTaskItemList = new List<Task_Item__c>();
        Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
        Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = new Map<Integer, Task_Item__c>();

        String testResultStringValue = '0d + 0h';

        String currentDuration = TEST_START_EXPECTED_DURATION;
        for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, testServiceItemList[0].Id, null, false)){
            taskItem.Sequence_Number__c = sequenceNumber++;
            taskItem.Expected_Duration__c = currentDuration;
            taskItem.Delay_End_Date__c = null;
            taskItem.Predecessor_Task__c = null;
            taskItem.Successor_Task__c = null;
            sequenceNumberTaskItemMap.put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);
            testTaskItemList.add(taskItem);
            currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);

            testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
        }
        insert testTaskItemList;
        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
            sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
            taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
            taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
        }

        for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= testTaskItemList.size(); i++){
            Task_Item__c taskItem = sequenceNumberTaskItemMap.get(i);

            // Collect Predecessor Tasks for Successor
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

            // Collect Successor Tasks for Predecessor
            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );
        }
        TaskManagementServices.taskIdWithPredecessors.remove( null );
        TaskManagementServices.taskIdWithSuccessors.remove( null );

        String resultString;

        Test.startTest();
            resultString = TaskManagementServices.getTotalDurationForService(sequenceNumberTaskItemMap, null);
        Test.stopTest();

        System.assertEquals(testResultStringValue, resultString);
    }

    private static testmethod void testGetTotalDurationForServiceWithDelayEndDate(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        testTaskItemList = new List<Task_Item__c>();
        Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
        Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = new Map<Integer, Task_Item__c>();

        String testResultStringValue = '0d + 0h';

        String currentDuration = TEST_START_EXPECTED_DURATION;
        String currentDelayEndDate = TEST_START_DELAY_END_DATE;
        for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, testServiceItemList[0].Id, null, false)){
            taskItem.Sequence_Number__c = sequenceNumber++;
            taskItem.Expected_Duration__c = currentDuration;
            taskItem.Delay_End_Date__c = currentDelayEndDate;
            taskItem.Predecessor_Task__c = null;
            taskItem.Successor_Task__c = null;
            sequenceNumberTaskItemMap.put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);
            testTaskItemList.add(taskItem);
            currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
            currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

            testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
            testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
        }
        insert testTaskItemList;
        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
            sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
            taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
            taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
        }

        for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= testTaskItemList.size(); i++){
            Task_Item__c taskItem = sequenceNumberTaskItemMap.get(i);

            // Collect Predecessor Tasks for Successor
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

            // Collect Successor Tasks for Predecessor
            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );
        }
        TaskManagementServices.taskIdWithPredecessors.remove( null );
        TaskManagementServices.taskIdWithSuccessors.remove( null );

        String resultString;

        Test.startTest();
            resultString = TaskManagementServices.getTotalDurationForService(sequenceNumberTaskItemMap, null);
        Test.stopTest();

        System.assertEquals(testResultStringValue, resultString);
    }

    private static testmethod void testGetTotalDuration(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        testTaskItemList = new List<Task_Item__c>();
        Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
        Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = new Map<Integer, Task_Item__c>();

        String testResultStringValue = '0d + 0h';

        String currentDuration = TEST_START_EXPECTED_DURATION;
        String currentDelayEndDate = TEST_START_DELAY_END_DATE;
        for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 3, testServiceItemList[0].Id, null, false)){
            taskItem.Sequence_Number__c = sequenceNumber++;
            taskItem.Expected_Duration__c = currentDuration;
            taskItem.Delay_End_Date__c = currentDelayEndDate;
            taskItem.Predecessor_Task__c = null;
            taskItem.Successor_Task__c = null;
            sequenceNumberTaskItemMap.put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);
            testTaskItemList.add(taskItem);
            currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
            currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

            testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
            testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
        }
        insert testTaskItemList;

        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
            sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
            taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
            taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                    sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
        }

        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 - 1).Id;
        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM + 1).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM - 1).Id;
        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 - 1).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM).Id;

        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 1).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 3 - 1).Id;
        sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 2).Predecessor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2).Id;
//this does not work
//    sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2).Successor_Task__c = sequenceNumberTaskItemMap.get(NUMBER_TO_CREATE_TASK_ITEM * 2 + 2).Id;

        for (Task_Item__c taskItem : testTaskItemList){
            TaskManagementServices.taskIdToTask.put(taskItem.Id, TaskItem);
        }

        for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= testTaskItemList.size(); i++){
            Task_Item__c taskItem = sequenceNumberTaskItemMap.get(i);

            // Collect Predecessor Tasks for Successor
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
            if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
            }
            TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

            // Collect Successor Tasks for Predecessor
            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

            if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
            }
            TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );
        }
        TaskManagementServices.taskIdWithPredecessors.remove( null );
        TaskManagementServices.taskIdWithSuccessors.remove( null );

        String resultString;

        Test.startTest();
            resultString = TaskManagementServices.getTotalDurationForService(sequenceNumberTaskItemMap, null);
        Test.stopTest();

        //System.assertEquals(testResultStringValue, resultString);
    }

    private static testmethod void testCalculatePlannedExpectedDatesForServices(){
        setupData(Date.today());
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItem.Predecessor_Milestone__c = null;
            serviceItem.Successor_Milestone__c = null;
        }
        testServiceItemList[0].Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
        insert testServiceItemList;
        testServiceItemList = [ SELECT Id, Name, Expected_Start_Date__c, Expected_End_Date__c, Expected_Service_Duration__c, Successor_Milestone__c, Predecessor_Milestone__c,
                                        Planned_Start_Date__c, Planned_End_Date__c, Total_Planned_Service_Duration__c, Project_Profile__r.Project_Start_Date__c,
                                        Project_Profile__r.Submitted_Planned_Dates__c, Actual_Start_Date__c, Actual_Start_Date_Is_From_Terminator__c
                                FROM Service_Item__c
                                WHERE Id IN : testServiceItemList];

        String testResultStringValue = '0d + 0h';

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            TaskManagementServices.seqNumberToTaskItemForService.put(serviceItem.Id, new Map<Integer, Task_Item__c>());

            String currentDuration = TEST_START_EXPECTED_DURATION;
            String currentDelayEndDate = TEST_START_DELAY_END_DATE;
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 3, testServiceItemList[0].Id, serviceItem.Project_Profile__c, false)){
                taskItem.Sequence_Number__c = sequenceNumber++;
                taskItem.Expected_Duration__c = currentDuration;
                taskItem.Delay_End_Date__c = currentDelayEndDate;
                taskItem.Predecessor_Task__c = null;
                taskItem.Successor_Task__c = null;

                TaskManagementServices.seqNumberToTaskItemForService.get(serviceItem.Id).put(Integer.valueOf(taskItem.Sequence_Number__c), taskItem);

                testTaskItemList.add(taskItem);
                currentDuration = DateUtils.appendDurations(currentDuration, TEST_DURATION_INCREMENT);
                currentDelayEndDate = DateUtils.appendDurations(currentDelayEndDate, TEST_DURATION_INCREMENT);

                testResultStringValue = DateUtils.appendDurations(taskItem.Delay_End_Date__c, testResultStringValue);
                testResultStringValue = DateUtils.appendDurations(taskItem.Expected_Duration__c, testResultStringValue);
            }
        }
        insert testTaskItemList;

        for (Id serviceItemId : TaskManagementServices.seqNumberToTaskItemForService.keySet()){
            Map<Integer, Task_Item__c> sequenceNumberTaskItemMap = TaskManagementServices.seqNumberToTaskItemForService.get(serviceItemId);
            for (Task_Item__c taskItem : sequenceNumberTaskItemMap.values()){
                Integer sequenceNumber = Integer.valueOf(taskItem.Sequence_Number__c);
                if(sequenceNumber == TaskManagementServices.FIRST_TASK_IN_SEQUENCE){
                    taskItem.Predecessor_Milestone_from_Template__c = 'test Predecessor milestone';
                }
                if(sequenceNumber == sequenceNumberTaskItemMap.size()){
                    taskItem.Successor_Milestone_from_Template__c = 'test Successor milestone';
                }
                taskItem.Predecessor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber - 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber - 1).Id : null;
                taskItem.Successor_Task__c = sequenceNumberTaskItemMap.containsKey(sequenceNumber + 1) ?
                                                        sequenceNumberTaskItemMap.get(sequenceNumber + 1).Id : null;
            }
        }
        update testTaskItemList;

        for( Id serviceId : TaskManagementServices.seqNumberToTaskItemForService.keySet() ) {
            Map<Integer, Task_Item__c> orderedListOfTasks = TaskManagementServices.seqNumberToTaskItemForService.get( serviceId );
            List<Integer> ranksList = new List<Integer>();
            ranksList.addAll( orderedListOfTasks.keySet() );
            ranksList.sort();

            for( Integer sequenceNumber : ranksList ) {
                Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );

                // Collect Predecessor Tasks for Successor
                if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                    TaskManagementServices.taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
                }
                TaskManagementServices.taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
                if( !TaskManagementServices.taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                    TaskManagementServices.taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
                }
                TaskManagementServices.taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

                // Collect Successor Tasks for Predecessor
                if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                    TaskManagementServices.taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
                }
                TaskManagementServices.taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

                if( !TaskManagementServices.taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                    TaskManagementServices.taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
                }
                TaskManagementServices.taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );

                //Prepare Task map
                TaskManagementServices.taskIdToTask.put( taskItem.Id, taskItem );
            }
            TaskManagementServices.taskIdWithPredecessors.remove( null );
            TaskManagementServices.taskIdWithSuccessors.remove( null );
        }

        Test.startTest();
            TaskManagementServices.calculatePlannedExpectedDatesForServices(new Map<Id, Service_Item__c>(testServiceItemList), null, null );
        Test.stopTest();
    }
}