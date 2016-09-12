public with sharing class StoreDocProposalForProjectCont {

    public PageReference iFrameDocumentPageReference { get; set; }
    public Project_Profile__c projectProfile {get;set;}

    public StoreDocProposalForProjectCont(ApexPages.StandardController controller) {
        projectProfile = (Project_Profile__c)controller.getRecord();
        getStoreDocuments();
    }
    
    public void getStoreDocuments() {
        if(String.isBlank(projectProfile.Proposal__c)) return;
        PageReference pr;
        pr = new PageReference('/apex/StoreDocProposalForProject');
        pr.getParameters().put('id', projectProfile.Proposal__c);
        iFrameDocumentPageReference = pr;

    }

}