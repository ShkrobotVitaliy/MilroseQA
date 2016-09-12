@isTest
private class TestServiceItemsExtensionMi3 {

    private static final String MILESTONE_START = 'Project Start';
    private static final String MILESTONE_END = 'Project End';
    private static final String MILESTONE_RT_NAME = 'Milestone';

    private static final String PREPARE_FILING_PACKAGE_TASK_NAME = 'Prepare Filing Package';
    private static final String TASK_ITEM_STATUS_COMPLETE = 'Complete';
    private static final String TASK_ITEM_STATUS_NOT_STARTED = 'Not Started';

    private static ServiceItemsExtensionMi3 testServiceItemsExtensionMi3;
    private static ApexPages.StandardController controller;
    
    private static Project_Profile__c project;
    private static Task_Item__c startMilestone;
    private static Task_Item__c endMilestone;
    private static Task_Item__c taskItem;
    private static Service_Item__c serviceItem;

    private static testMethod void testServiceItemsExtensionMi3() {
        INSERT new List<Tasks_Statuses__c>{ new Tasks_Statuses__c( Name = PREPARE_FILING_PACKAGE_TASK_NAME + '1',
                                                                   Task_Name__c = PREPARE_FILING_PACKAGE_TASK_NAME,
                                                                   IsComplete__c = true,
                                                                   Status__c = TASK_ITEM_STATUS_COMPLETE,
                                                                   IsPrevalent__c = true ),
                                            new Tasks_Statuses__c( Name = PREPARE_FILING_PACKAGE_TASK_NAME + '2',
                                                                   Task_Name__c = TASK_ITEM_STATUS_NOT_STARTED,
                                                                   IsComplete__c = false,
                                                                   Status__c = TASK_ITEM_STATUS_NOT_STARTED ),
                                            new Tasks_Statuses__c( Name = PREPARE_FILING_PACKAGE_TASK_NAME + '3',
                                                                   Task_Name__c = PREPARE_FILING_PACKAGE_TASK_NAME,
                                                                   IsComplete__c = true,
                                                                   Status__c = 'Some Random Status',
                                                                   IsPrevalent__c = false ) };

        project = TestingUtils.createProjectProfileList(1, null, null, null, null, null, null, null, false)[0];
        project.Project_Manager__c = project.OwnerId;
        project.Mi3_MRC__c = 'test';
        INSERT project;

        RecordType milestoneRt = [SELECT Id From RecordType WHERE SobjectType = 'Task_Item__c' AND DeveloperName = : MILESTONE_RT_NAME LIMIT 1];
        startMilestone = TestingUtils.createTaskItemList( 1, false )[0];
        startMilestone.Name = MILESTONE_START;
        startMilestone.OwnerId = UserInfo.getUserId();
        startMilestone.Project_Profile__c = project.Id;
        startMilestone.RecordTypeId = milestoneRt.Id;

        endMilestone = TestingUtils.createTaskItemList( 1, false )[0];
        endMilestone.Name = MILESTONE_END;
        endMilestone.OwnerId = UserInfo.getUserId();
        endMilestone.Project_Profile__c = project.Id;
        endMilestone.RecordTypeId = milestoneRT.Id;
        insert new List<Task_Item__c>{ startMilestone, endMilestone };

        serviceItem = TestingUtils.createServiceItemList( 1, false )[0];
        serviceItem.Is_Alternative__c = false;
        serviceItem.Original__c = true;
        serviceItem.Project_Profile__c = project.Id;
        serviceItem.Row_Position__c = 1;
        INSERT serviceItem;
        
        RecordType taskRt = [SELECT Id From RecordType WHERE SobjectType = 'Task_Item__c' AND Name = : PREPARE_FILING_PACKAGE_TASK_NAME LIMIT 1];
        taskItem = TestingUtils.createTaskItemList(1, serviceItem.Id, project.Id, false)[0];
        taskItem.Predecessor_Milestone__c = startMilestone.Id;
        taskItem.Successor_Milestone__c = endMilestone.Id;
        //taskItem.Status_Category__c = PREPARE_FILING_PACKAGE_TASK_NAME;
        taskItem.Status__c = TASK_ITEM_STATUS_NOT_STARTED;
        taskItem.RecordTypeId = taskRt.Id;
        INSERT taskItem;

        Test.setCurrentPageReference(Page.ServiceItemsRelatedListMi3);
        controller = new ApexPages.StandardController( project );

        Test.startTest();
            testServiceItemsExtensionMi3 = new ServiceItemsExtensionMi3( controller );
            List<SelectOption> options = testServiceItemsExtensionMi3.serviceItemWrappers[0].taskItemsOptions;

            testServiceItemsExtensionMi3.currentServiceId = serviceItem.Id;
            testServiceItemsExtensionMi3.currentTaskId = taskItem.Id;
            testServiceItemsExtensionMi3.setStatus();

            Boolean isValid = testServiceItemsExtensionMi3.isTerminateTasksButtonValid; // not valid at this moment
            testServiceItemsExtensionMi3.serviceItemWrappers[0].taskItemForDate.Actual_End_Date__c = Date.today();

            testServiceItemsExtensionMi3.calcutateDates();
        Test.stopTest();
    }
}