public with sharing class OpportunityCommentsController {
	
	public Opportunity opp {set; get;}
	public String newInstruction {set; get; }

	private String dateStampUser() {
	    return Datetime.now().format('\'- \'MM/dd/yyyy hh:mm:ss\' - \'') + userinfo.getName();
	}

	public OpportunityCommentsController(ApexPages.StandardController stdController) {
		sObject mysObject = (Opportunity)stdController.getRecord();
    
	    opp = [SELECT Comments__c FROM Opportunity WHERE id =:(Id)mysObject.get('Id')];
		newInstruction = '';		
	}

	public void addNewInstruction() {
	    opp.Comments__c = opp.Comments__c == null ? newInstruction + 
	    		dateStampUser() : opp.Comments__c +'\n' + newInstruction + dateStampUser();
		newInstruction = '';
	    Opportunity oppToUpdate = new Opportunity(Id = opp.Id, Comments__c = opp.Comments__c);
	    UPDATE oppToUpdate;
  	}
}