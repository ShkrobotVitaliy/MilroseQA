@isTest
private class TestAdditionalReimbursableServices {
	
	@isTest static void testUncoveredParts() {
		Proposal__c proposal = TestingUtils.createProposalListForTest(1, true)[0];
		Additional_Reimbursable__c addReimb = new Additional_Reimbursable__c( Proposal__c = proposal.Id );
		Map<Id, Additional_Reimbursable__c> getRecordsByProposalId = AdditionalReimbursableServices.getRecordsByProposalId( proposal.Id );
		List<Additional_Reimbursable__c> getAdditionalReimbursablesByProposalId = AdditionalReimbursableServices.getAdditionalReimbursablesByProposalId( null );
		getRecordsByProposalId = AdditionalReimbursableServices.getRecordsByProposal( proposal );
		getRecordsByProposalId = AdditionalReimbursableServices.getRecordsByProposal( null );
	}
}