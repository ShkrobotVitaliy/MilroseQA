@isTest
private class TestSendOpportunitiesFollowUps {
	private static final Integer NUMBER_TO_CREATE_OPPORTUNITY = 2;
	private static List<Opportunity> testOpportunityList;

	private static void setupData(){
		testOpportunityList = TestingUtils.createOpportunityList(NUMBER_TO_CREATE_OPPORTUNITY, 'test Name', 'Test Stage Name', Date.today().addDays(1), false);
		for (Opportunity opp : testOpportunityList){
			opp.Salesperson__c            = UserInfo.getUserId();
			opp.Date_of_Next_Follow_up__c = Datetime.now().addDays(1);
		}

		insert testOpportunityList;
	}

	private static testmethod void  testschedule(){
		setupData();

		Test.StartTest();

			SendOpportunitiesFollowUps sh1 = new SendOpportunitiesFollowUps();
			String sch = '0  00 1 3 * ?';
			system.schedule('Test', sch, sh1);
		Test.stopTest();

	}
}