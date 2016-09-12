public class StoredDocsInlineTaskItemController {

    public Task_Item__c taskItem {get; set;}
    public Boolean isShowButton {
        get {
            if(isShowButton == null) {
                isShowButton = UserServices.isAddDocument(UserServices.PROFILE_PROJECT_MANAGER, taskItem.Project_Profile__r.Project_Team__r.Project_Manager__c);
            }
            return isShowButton;
        }
        set;
    }

    public StoredDocsInlineTaskItemController(ApexPages.StandardController controller) {
        taskItem = (Task_Item__c)controller.getRecord();
    }

}