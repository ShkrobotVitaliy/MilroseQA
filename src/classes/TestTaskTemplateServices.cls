@isTest
private class TestTaskTemplateServices {
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_STATE_CHANGE = 1;

    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Task_State_Change__c> testTaskStateChangeList;

    @isTest static void testUncoveredParts() {
        Service_Template__c serviceTemplate = TestingUtils.createServiceTemplateList(1, true)[0];
        Task_Template__c taskTemplate = TestingUtils.createTaskTemplateList(1, false)[0];
        taskTemplate.Service__c = serviceTemplate.Id;
        taskTemplate.Sequence_Number__c = 5;
        INSERT taskTemplate;

        Task_Template__c taskTemplate2 = TestingUtils.createTaskTemplateList(1, false)[0];
        taskTemplate2.Service__c = serviceTemplate.Id;
        taskTemplate2.Sequence_Number__c = 4;
        INSERT taskTemplate2;

        Task_Template__c taskTemplate3 = TestingUtils.createTaskTemplateList(1, false)[0];
        taskTemplate3.Service__c = serviceTemplate.Id;
        taskTemplate3.Sequence_Number__c = 6;
        INSERT taskTemplate3;

        Test.startTest();
            taskTemplate.Is_Manually_Created__c = false;
            TaskTemplateServices.populateSuccessorPredecessorTasks( new List<Task_Template__c> { taskTemplate } );
            taskTemplate.Is_Manually_Created__c = true;
            TaskTemplateServices.populateSuccessorPredecessorTasks( new List<Task_Template__c> { taskTemplate } );
        Test.stopTest();
    }

    private static testmethod void testGetTasksWithDurrationByServiceIds(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);

        List<Id> serviceTemplateListId = new List<Id>();

        testTaskTemplateList = new List<Task_Template__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateListId.add(serviceTemplateItem.Id);
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                testTaskTemplateList.add(taskTemplateItem);
            }
        }
        insert testTaskTemplateList;

        List<Task_Template__c> resultTaskTemplateList;

        Test.startTest();

            resultTaskTemplateList = TaskTemplateServices.getTasksWithDurrationByServiceIds(serviceTemplateListId);

        Test.stopTest();

        System.assert(resultTaskTemplateList != null);
        System.assert(!resultTaskTemplateList.isEmpty());
        System.assertEquals(new Map<Id, Task_Template__c>(testTaskTemplateList).keySet(), new Map<Id, Task_Template__c>(resultTaskTemplateList).keySet());
    }

    private static testmethod void testGetServiceTemplatesWithTaskStateChangesAndActualTaskTemplatesEmptyParameter(){
        List<Task_Template__c> resultTaskTemplateList;

        Test.startTest();

            resultTaskTemplateList = TaskTemplateServices.getTasksWithDurrationByServiceIds(null);

        Test.stopTest();

        System.assert(resultTaskTemplateList != null);
        System.assert(resultTaskTemplateList.isEmpty());
    }

    private static testmethod void testGetTaskStateChangesByServiceIdsEmptyParameter(){
        List<Service_Template__c> resultServicetemplateList;

        Test.startTest();

            resultServicetemplateList = TaskTemplateServices.getServiceTemplatesWithTaskStateChangesAndActualTaskTemplates(new Set<Id>());

        Test.stopTest();

        System.assert(resultServicetemplateList == null || resultServicetemplateList.isEmpty());
    }

    private static testmethod void testGetServiceTemplatesWithTaskStateChangesAndActualTaskTemplates(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);

        testTaskStateChangeList = new List<Task_State_Change__c>();
        testTaskTemplateList = new List<Task_Template__c>();
        for (Service_Template__c serviceTempleteItem : testServiceTemplateList){
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTempleteItem.Id;
                testTaskTemplateList.add(taskTemplateItem);
            }
            for (Task_State_Change__c taskStateChangeItem : TestingUtils.createTaskStateChangeList(NUMBER_TO_CREATE_TASK_STATE_CHANGE, false)){
                taskStateChangeItem.Service__c = serviceTempleteItem.Id;
                testTaskStateChangeList.add(taskStateChangeItem);
            }
        }
        insert testTaskTemplateList;
        insert testTaskStateChangeList;

        List<Service_Template__c> resultServicetemplateList;

        Test.startTest();

            resultServicetemplateList = TaskTemplateServices.getServiceTemplatesWithTaskStateChangesAndActualTaskTemplates(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet());

        Test.stopTest();

        System.assert(resultServicetemplateList != null && !resultServicetemplateList.isEmpty());
        System.assertEquals(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), new Map<Id, Service_Template__c>(resultServicetemplateList).keySet());
    }
}