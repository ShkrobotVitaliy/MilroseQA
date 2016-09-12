public with sharing class ProjectSpecificNotesController {
	
	public Project_Profile__c projectProfile {set; get;}
	public String newInstruction {set; get; }

	private String dateStampUser() {
	    return Datetime.now().format('\'- \'MM/dd/yyyy hh:mm:ss\' - \'') + userinfo.getName();
	}

	public ProjectSpecificNotesController(ApexPages.StandardController stdController) {
		sObject mysObject = (sObject)stdController.getRecord();
    
	    projectProfile = [SELECT  Project_Specific_Notes__c
	                      FROM Project_Profile__c
	                      WHERE id =:(Id)mysObject.get('Id')];
		newInstruction = '';		
	}

	public void addNewInstruction() {
	    projectProfile.Project_Specific_Notes__c = projectProfile.Project_Specific_Notes__c == null ? newInstruction + 
	    		dateStampUser() : projectProfile.Project_Specific_Notes__c +'\n' + newInstruction + dateStampUser();
		newInstruction = '';
	    Project_Profile__c ppToUpdate = new Project_Profile__c(Id = projectProfile.Id, Project_Specific_Notes__c = projectProfile.Project_Specific_Notes__c);
	    UPDATE ppToUpdate;
  	}
}