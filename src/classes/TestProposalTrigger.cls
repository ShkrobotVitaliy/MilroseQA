@isTest
private class TestProposalTrigger {
	
	@isTest static void testProposalDMLOperations() {
		Proposal__c proposal = TestingUtils.createProposalListForTest( 1, false)[0];
		INSERT proposal;

		PreventTwiceExecution.proposalFirstRun = true;
		proposal.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
		proposal.Is_Draft__c = false;
		UPDATE proposal;
		UPDATE proposal;
		
		PreventTwiceExecution.proposalFirstRun = true;
		DELETE proposal;
	}
	
}