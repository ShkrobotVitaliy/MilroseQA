public with sharing class SubmitFilingPackageToAuthorityController {
    public Task_Item__c taskItem { get; set; }
    public List<Form_Item__c> formItemsList {get; set;}
    
    public SubmitFilingPackageToAuthorityController (ApexPages.StandardController controller) {
        taskItem = (Task_Item__c)controller.getRecord();

        formItemsList = [ Select Form_Id__c, Id, Form_Name__c
                          From Form_Item__c
                          Where Service_Item__c =: taskItem.Service_Item__c Order by Form_Name__c ];
    }
    
	public PageReference updateStatus(){
		upsert taskItem;
		return null;
	}

}