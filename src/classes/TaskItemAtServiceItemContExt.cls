public with sharing class TaskItemAtServiceItemContExt {
    public Service_Item__c serviceItem { get; set; }
    public List<Task_Item__c> taskItemList { get; set; }

    public TaskItemAtServiceItemContExt( ApexPages.StandardController controller ) {
        serviceItem = (Service_Item__c) controller.getRecord();
        if( String.isNotBlank(serviceItem.Id) ) {
            taskItemList = TaskItemServices.getTaskItemByServiceItemId(serviceItem.Id);
        }
    }
}