@isTest
private class TestOpportunityTrigger {
	
	@isTest static void testEmailNotification() {
		List<Opportunity> opportunities = new List<Opportunity>();
		opportunities.add(new Opportunity(Name = 'TestOpportunity', StageName = 'Scope Review Required', CloseDate = Date.today().addDays(30)));
		opportunities.add(new Opportunity(Name = 'TestOpportunity', StageName = 'Proposal Required', CloseDate = Date.today().addDays(30)));
		opportunities.add(new Opportunity(Name = 'TestOpportunity', StageName = 'Proposal Sent', CloseDate = Date.today().addDays(30)));
		INSERT opportunities;
	}
	
}