public with sharing class ProposalAssignmentContExt {
	
	public transient Proposal__c assingmentProposal { get; set; }
	
	public ProposalAssignmentContExt(ApexPages.StandardController controller) {
        Id parentId = controller.getRecord().Id;
        assingmentProposal = [
        	SELECT Account_Executive__c, Partner__c, Salesperson__c,
        		Project_Profile__r.Production_Manager__c, Project_Profile__r.Project_Manager__c,
        		Project_Profile__r.Project_Member__c, Project_Profile__r.FREP__c,
        		Project_Profile__r.Project_Team__c, CreatedById, OwnerId, Proposal_Specialist__c
        	FROM Proposal__c
        	WHERE Id = :parentId
        ];
    }
}