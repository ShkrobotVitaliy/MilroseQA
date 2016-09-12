@isTest
private class TestOpportunityCommentsController {
	
	@isTest static void testMainFunctionality() {
		Opportunity opp = new Opportunity(Name = 'testOpp', StageName = 'Initial Engagement', CloseDate = Date.TODAY());
		INSERT opp;
		ApexPages.StandardController cont = new ApexPages.standardController(opp);
		OpportunityCommentsController oppCont = new OpportunityCommentsController(cont);
		oppCont.addNewInstruction();
		oppCont.addNewInstruction();
	}
	
}