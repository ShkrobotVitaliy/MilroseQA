public with sharing class PickupAnalyzeArtifactsFromAuthorityCon {
    private static Integer MINUTES_DELAY = 10;

    public final Task_Item__c taskItem { get; set; }
    public List<Task_Item_Functionality__c> taskItemFunctionalityList {get; set;}

    public PickupAnalyzeArtifactsFromAuthorityCon(ApexPages.StandardController controller) {
        Id taskItemId = ((Task_Item__c)controller.getRecord()).Id;

        if ( taskItemId != null ){
            this.taskItem = [SELECT Id, Status__c, Service_Item__r.Status__c, X3rd_Party_Disapproved_Date__c,
                                (Select Id, Disapproved_Date__c, Comments__c, Appointment_Date_Time__c, Examiner__c,
                                        Additional_Notes__c, Is_Saved__c, CreatedDate, LastModifiedDate
                                 From Task_Item_Functionality__r
                                        Order By CreatedDate DESC, Disapproved_Date__c DESC NULLS FIRST)
                             FROM Task_Item__c
                             WHERE Id = : taskItemId][0];

            this.taskItemFunctionalityList = taskItem.Task_Item_Functionality__r;
        }
    }

    public void addRequaredTIF(){
        if ([SELECT Id From Task_Item_Functionality__c WHERE Task_Item__c = : taskItem.Id].isEmpty()){
            addNewLineAction();
        }
    }

    public void addNewLineAction(){
        Task_Item_Functionality__c newItem = new Task_Item_Functionality__c(Task_Item__c = taskItem.Id,
                                                                            Disapproved_Date__c = null,
                                                                            Appointment_Date_Time__c = null,
                                                                            Examiner__c = '',
                                                                            Additional_Notes__c = '',
                                                                            Is_Saved__c = false,
                                                                            Comments__c = '');

        insert newItem;
        List<Task_Item_Functionality__c> tmpTIFList = taskItemFunctionalityList;
        taskItemFunctionalityList = new List<Task_Item_Functionality__c>{newItem};
        taskItemFunctionalityList.addAll(tmpTIFList);
    }

    public void saveTasktemFunctionality(){
        for (Task_Item_Functionality__c tifItem : taskItemFunctionalityList){
            if ( !tifItem.Is_Saved__c &&
                 (String.isEmpty(tifItem.Comments__c) ||
                  tifItem.Disapproved_Date__c == null) ){

                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You should populate all required fields in table'));
                    return;

            }
        }
        List<Task_Item_Functionality__c> tifUpdateList = new List<Task_Item_Functionality__c>();

        Boolean doUpdateDisapprovedDate = false;

        for (Task_Item_Functionality__c tifItem : taskItemFunctionalityList){
            if (!tifItem.Is_Saved__c){
                tifItem.Is_Saved__c = true;
                tifUpdateList.add(tifItem);
                doUpdateDisapprovedDate = true;
            } else {
                tifUpdateList.add( new Task_Item_Functionality__c ( Id = tifItem.id,
                                                                    Additional_Notes__c = tifItem.Additional_Notes__c,
                                                                    Appointment_Date_Time__c = tifItem.Appointment_Date_Time__c,
                                                                    Examiner__c = tifItem.Examiner__c ) );
            }
        }

        try{

            update tifUpdateList;

            if (taskItem.Status__c == TaskItemServices.TASK_ITEM_STATUS_DISAPPROVED && doUpdateDisapprovedDate){
                taskItem.X3rd_Party_Disapproved_Date__c = !tifUpdateList.isEmpty() && tifUpdateList[0].Disapproved_Date__c != null ? tifUpdateList[0].Disapproved_Date__c : taskItem.X3rd_Party_Disapproved_Date__c;
                update new Task_Item__c (Id = taskItem.Id, X3rd_Party_Disapproved_Date__c = taskItem.X3rd_Party_Disapproved_Date__c);
            }

        } catch (DMLException ex){

            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Can not save changes: ' + ex.getMessage()));
            return;

        }

        if (!tifUpdateList.isEmpty() && taskItem.Status__c != TaskItemServices.TASK_ITEM_STATUS_DISAPPROVED){
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.INFO, 'Your changes had been saved. Please update current Task with "Disapproved" Status.'));
            return;
        }
    }

    public String tifRecordId{ get; set; }
/*
    public void updateFieldValuesOnChange(){
        Map<Id, Task_Item_Functionality__c> tifMap = new Map<Id, Task_Item_Functionality__c>(taskItemFunctionalityList);
        Id recordToUpdateId = String.isEmpty(tifRecordId) ? null : Id.valueOf(tifRecordId);
        tifRecordId = '';
        if (tifMap.containsKey(recordToUpdateId)){
            try{
                update tifMap.get(recordToUpdateId);
            } catch (DMLException ex){
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Incorrect value: ' + ex.getMessage()));
                return;
            }
        } else {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Record has been removed'));
            return;
        }
    }
*/
    public void deleteRecordAction(){
        Map<Id, Task_Item_Functionality__c> tifMap = new Map<Id, Task_Item_Functionality__c>(this.taskItemFunctionalityList);
        Id recordToUpdateId = String.isEmpty(tifRecordId) ? null : Id.valueOf(tifRecordId);
        tifRecordId = '';
        if (tifMap.containsKey(recordToUpdateId)){
            try{
                delete new Task_Item_Functionality__c(Id = recordToUpdateId);
            } catch (DMLException ex){
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Can not delete record: ' + ex.getMessage()));
                return;
            }
        } else {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Record already has been removed'));
            return;
        }
        tifMap.remove(recordToUpdateId);
        taskItemFunctionalityList = tifMap.values();
    }
}