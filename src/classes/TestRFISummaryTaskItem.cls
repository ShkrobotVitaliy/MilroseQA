@isTest
private class TestRFISummaryTaskItem {

    private static ApexPages.StandardController testController;
    private static RFISummaryTaskItem testRFISummaryTaskItem;

    private static testMethod void testRFISummaryTaskItem() {

        Test.setCurrentPageReference(Page.RFISummaryOnTaskItem);
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for( Service_Item__c item: TestingUtils.createServiceItemList(1, false) ){
            item.Category__c = RFIScopeServices.APPLICATION_FILING;
            item.Type__c = RFIScopeServices.PLAN_APPROVAL;
            serviceItemList.add(item);   
        }
        insert serviceItemList;
        List<Task_Item__c> taskItemList = new List<Task_Item__c>();
        for( Task_Item__c item: TestingUtils.createTaskItemList(1, false) ){
            item.Service_Item__c = serviceItemList[0].Id;
            taskItemList.add(item);   
        }
        insert taskItemList;
        List<Task_Item__c> testTaskSelected = [Select Id, Name, Project_Profile__c, Service_Item__c, Service_Item__r.Category__c, Service_Item__r.Type__c From Task_Item__c Where Id IN: taskItemList ];
        
        testController = new ApexPages.StandardController( testTaskSelected[0] );

        Test.startTest();
            testRFISummaryTaskItem = new RFISummaryTaskItem(testController);
            List<RFI_Scope__c> test1 = testRFISummaryTaskItem.getRFIScopes();
        Test.stopTest();

    }
    
    private static testMethod void testRFISummaryTaskItem1() {

        Test.setCurrentPageReference(Page.RFISummaryOnTaskItem);
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for( Service_Item__c item: TestingUtils.createServiceItemList(1, false) ){
            item.Category__c = RFIScopeServices.APPLICATION_FILING;
            item.Type__c = RFIScopeServices.WORK_PERMIT;
            serviceItemList.add(item);   
        }
        insert serviceItemList;
        List<Task_Item__c> taskItemList = new List<Task_Item__c>();
        for( Task_Item__c item: TestingUtils.createTaskItemList(1, false) ){
            item.Service_Item__c = serviceItemList[0].Id;
            taskItemList.add(item);   
        }
        insert taskItemList;
        List<Task_Item__c> testTaskSelected = [Select Id, Name, Project_Profile__c, Service_Item__c, Service_Item__r.Category__c, Service_Item__r.Type__c From Task_Item__c Where Id IN: taskItemList ];
        
        testController = new ApexPages.StandardController( testTaskSelected[0] );

        Test.startTest();
            testRFISummaryTaskItem = new RFISummaryTaskItem(testController);
            List<RFI_Scope__c> test1 = testRFISummaryTaskItem.getRFIScopes();
        Test.stopTest();

    }
    
    private static testMethod void testRFISummaryTaskItem2() {

        Test.setCurrentPageReference(Page.RFISummaryOnTaskItem);
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for( Service_Item__c item: TestingUtils.createServiceItemList(1, false) ){
            item.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            item.Type__c = RFIScopeServices.PLAN_APPROVAL;
            serviceItemList.add(item);   
        }
        insert serviceItemList;
        List<Task_Item__c> taskItemList = new List<Task_Item__c>();
        for( Task_Item__c item: TestingUtils.createTaskItemList(1, false) ){
            item.Service_Item__c = serviceItemList[0].Id;
            taskItemList.add(item);   
        }
        insert taskItemList;
        List<Task_Item__c> testTaskSelected = [Select Id, Name, Project_Profile__c, Service_Item__c, Service_Item__r.Category__c, Service_Item__r.Type__c From Task_Item__c Where Id IN: taskItemList ];
        
        testController = new ApexPages.StandardController( testTaskSelected[0] );

        Test.startTest();
            testRFISummaryTaskItem = new RFISummaryTaskItem(testController);
            List<RFI_Scope__c> test1 = testRFISummaryTaskItem.getRFIScopes();
        Test.stopTest();

    }
}