public with sharing class StoreDocOpportunityForProposalCont {
	
	public PageReference iFrameDocumentPageReference { get; set; }
    public Proposal__c proposal {get;set;}

	public StoreDocOpportunityForProposalCont(ApexPages.StandardController controller) {
        proposal = (Proposal__c)controller.getRecord();
        getStoreDocuments();
    }

	public void getStoreDocuments() {
        if(String.isBlank(proposal.Opportunity__c)) return;
        PageReference pr;
        pr = new PageReference('/apex/StoreDocOpportunityForProposal');
        pr.getParameters().put('id', proposal.Opportunity__c);
        iFrameDocumentPageReference = pr;
    }
}