public with sharing class StoreDocOpportunityForProjectCont {
	
	public PageReference iFrameDocumentPageReference { get; set; }
    public Project_Profile__c projectProfile {get;set;}

	public StoreDocOpportunityForProjectCont(ApexPages.StandardController controller) {
        projectProfile = (Project_Profile__c)controller.getRecord();
        getStoreDocuments();
    }

	public void getStoreDocuments() {
        if(String.isBlank(projectProfile.Proposal__c)) return;
		Proposal__c proposal = [SELECT Id, Opportunity__c FROM Proposal__c WHERE Id = :projectProfile.Proposal__c];
		if(String.isBlank(proposal.Opportunity__c)) return;
        PageReference pr;
        pr = new PageReference('/apex/StoreDocOpportunityForProject');
        pr.getParameters().put('id', proposal.Opportunity__c);
        iFrameDocumentPageReference = pr;
    }
}