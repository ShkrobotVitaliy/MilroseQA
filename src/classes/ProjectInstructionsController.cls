public with sharing class ProjectInstructionsController {

  private class ProjectInstruction {
    public String type {set; get;}
    public Id objectId {set; get;}
    public String objectName {set; get;}
    public String instruction {set; get;}
    ProjectInstruction(String type, Id objectId, String objectName, String instruction) {
      this.type = type;
      this.objectId = objectId;
      this.objectName = objectName;
      this.instruction = instruction;
    }
  }

  public List<ProjectInstruction> mainProjectInstructions {set; get;}
  public List<ProjectInstruction> rosterProjectInstructions {set; get;}
  public Project_Profile__c projectProfile {set; get;}

  public ProjectInstructionsController(ApexPages.StandardController stdController) {
    sObject mysObject = (sObject)stdController.getRecord();
    
    projectProfile = [SELECT  Billing_Company_Name__c,       Billing_Company_Name__r.Special_Instructions__c,       Billing_Company_Name__r.Name,       Billing_Company_Name__r.Billing_Instructions__c,
                              Billing_Company_Contact__c,    Billing_Company_Contact__r.Special_Instructions__c,    Billing_Company_Contact__r.Name,
                              Primary_Company_Name__c,       Primary_Company_Name__r.Special_Instructions__c,       Primary_Company_Name__r.Name,
                              Primary_Company_Contact__c,    Primary_Company_Contact__r.Special_Instructions__c,    Primary_Company_Contact__r.Name,
                              Accounting_Contact_Company__c, Accounting_Contact_Company__r.Special_Instructions__c, Accounting_Contact_Company__r.Name,
                              Accounting_Contact__c,         Accounting_Contact__r.Special_Instructions__c,         Accounting_Contact__r.Name,
                              Building__c,                   Building__r.Special_Instructions__c,                   Building__r.Name,
                              (SELECT Contact__r.Account.Id, Contact__r.Account.Name, Contact__r.Account.Special_Instructions__c
                               FROM Project_Rosters__r WHERE Active__c = true)
                      FROM Project_Profile__c
                      WHERE id =:(Id)mysObject.get('Id')];

    mainProjectInstructions = new List<ProjectInstruction> ();
    rosterProjectInstructions = new List<ProjectInstruction> ();
	// MRS 7214
    mainProjectInstructions.add(new ProjectInstruction('Billing Client Company', projectProfile.Billing_Company_Name__c, projectProfile.Billing_Company_Name__r.Name, projectProfile.Billing_Company_Name__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Billing Client Contact', projectProfile.Billing_Company_Contact__c, projectProfile.Billing_Company_Contact__r.Name, projectProfile.Billing_Company_Contact__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Primary Client Company', projectProfile.Primary_Company_Name__c, projectProfile.Primary_Company_Name__r.Name, projectProfile.Primary_Company_Name__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Primary Client Contact', projectProfile.Primary_Company_Contact__c, projectProfile.Primary_Company_Contact__r.Name, projectProfile.Primary_Company_Contact__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Building Instructions', projectProfile.Building__c, projectProfile.Building__r.Name, projectProfile.Building__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Accounting Client Company', projectProfile.Accounting_Contact_Company__c, projectProfile.Accounting_Contact_Company__r.Name, projectProfile.Accounting_Contact_Company__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Accounting Client Contact', projectProfile.Accounting_Contact__c, projectProfile.Accounting_Contact__r.Name, projectProfile.Accounting_Contact__r.Special_Instructions__c));
    mainProjectInstructions.add(new ProjectInstruction('Billing Instructions', projectProfile.Billing_Company_Name__c, projectProfile.Billing_Company_Name__r.Name, projectProfile.Billing_Company_Name__r.Billing_Instructions__c));

    for(Project_Roster__c pr : projectProfile.Project_Rosters__r) {
      if(pr.Contact__r.Account.Id != null && isNotOnTheList(pr.Contact__r.Account.Id)) {
        rosterProjectInstructions.add(new ProjectInstruction('', pr.Contact__r.Account.Id, pr.Contact__r.Account.Name, pr.Contact__r.Account.Special_Instructions__c));  
      }
    }
    
  }

  private Boolean isNotOnTheList(Id idx) {
      for(ProjectInstruction pi : mainProjectInstructions) if(pi.objectId.equals(idx)) return false;
      for(ProjectInstruction pi : rosterProjectInstructions) if(pi.objectId.equals(idx)) return false;
      return true;
  }

}