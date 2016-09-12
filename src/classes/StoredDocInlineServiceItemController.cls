public class StoredDocInlineServiceItemController {

    public Service_Item__c serviceItem {get; set;}
    public Boolean isShowButton {
        get {
            if(isShowButton == null) {
                isShowButton = UserServices.isAddDocument(UserServices.PROFILE_PROJECT_MANAGER, serviceItem.Project_Profile__r.Project_Team__r.Project_Manager__c);
            }
            return isShowButton;
        }
        set;
    }

    public StoredDocInlineServiceItemController(ApexPages.StandardController controller) {
        serviceItem = (Service_Item__c)controller.getRecord();
    }
    
    public String getLstoreUrl {
        get {
            String host = URL.getSalesforceBaseUrl().getHost();
            return 'https://lstore.'+host.removeStart('c.');
            
        }
    }

}