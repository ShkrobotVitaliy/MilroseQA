public with sharing class ChangeOrdersOnProposalController {

	public boolean canNotBeAdded {
		get {
			return !String.isBlank(newInstruction);
		}
		set;
	}

	public String newInstruction { set; get; }	
	public String currentCoId { set; get; }
	
	private String dateStampUser() {
	    return Datetime.now().format('\'- \'MM/dd/yyyy hh:mm:ss\' - \'') + userinfo.getName();
	}

	public Proposal__c proposal { get; set; }
	public Map<Id, Change_Order__c> changeOrders { set; get; }

	public ChangeOrdersOnProposalController(ApexPages.StandardController controller) {
		proposal = (Proposal__c) controller.getRecord();
		changeOrders = new Map<Id, Change_Order__c> ([SELECT Id, Number__c, Status__c, Follow_Ups_Count__c, Last_Follow_Up_Date__c, Manual_Follow_Up_Count__c, Follow_Up_Notes__c
									FROM Change_Order__c
									WHERE Proposal__c = :proposal.Id]);
		newInstruction = '';
		currentCoId = '';
	}
	
	public void setCurrentCoId() {
		this.currentCoId = currentCoId;
	}

	public void addNewInstruction() {
		if(!String.isBlank(currentCoId)) {
			changeOrders.get(currentCoId).Follow_Up_Notes__c = changeOrders.get(currentCoId).Follow_Up_Notes__c == null ? newInstruction + dateStampUser() : changeOrders.get(currentCoId).Follow_Up_Notes__c +'\n' + newInstruction + dateStampUser();
			UPDATE changeOrders.get(currentCoId);
		}
		newInstruction = '';
		currentCoId = '';
	}

	public void changeManualCount() {
		if(!String.isBlank(currentCoId)) {
			UPDATE changeOrders.get(currentCoId);
		}
		newInstruction = '';
		currentCoId = '';
	}

}