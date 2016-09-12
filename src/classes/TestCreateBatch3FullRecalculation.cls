@isTest
private class TestCreateBatch3FullRecalculation {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
	private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 1;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;

	private static List<Project_Team__c> testProjectTeamList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Change_Order__c> testChangeOrderList;
	private static List<Service_Item__c> testServiceItemList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;
	public static User testProductionManagerUser;

	private static CreateBatch3FullRecalculation testBatch;

	private static void setupData (){
		TestingUtils.prepareDataForFF();
		TestingUtils.prd.Trailing_12_Month_Awarded_Proposal_Month__c = 0;
		TestingUtils.prd.c2g__PeriodNumber__c = '001';
		update TestingUtils.prd;

		TestingUtils.setupData();
		partnerUser = TestingUtils.testPartnerUser;
		projectManagerUser = TestingUtils.testProjectManagerUser;
		currentUserId = TestingUtils.testCurrentUserId;
		testProductionManagerUser = TestingUtils.testProductionManagerUser;
		testProjectTeamList = TestingUtils.testProjectTeamList;
		testAccountList = TestingUtils.testAccountList;
		testContactWithAccountList = TestingUtils.testContactWithAccountList;
		testRegionList = TestingUtils.testRegionList;
		testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
		testBuildingList = TestingUtils.testBuildingList;

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
		testProposalList = TestingUtils.testProposalList;

		for (Proposal__c proposalItem : testProposalList){
			proposalItem.Proposal_Awarded_Date__c = Date.today();
			proposalItem.Status__c = 'Awarded'; //MRS 7333
			proposalItem.Mi3_MRC__c = null;
		}
		update testProposalList;

		testServiceItemList = new List<Service_Item__c>();
		testChangeOrderList = new List<Change_Order__c>();

		for (Proposal__c proposalItem : testProposalList){
			for(Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false)){
				serviceItemItem.Quantity__c = 2;
				serviceItemItem.Unit_Price__c = 10;
				serviceItemItem.Discount_Percentage__c = 5;
				serviceItemItem.Project_Profile__c = proposalItem.Project_Profile__c;
				testServiceItemList.add(serviceItemItem);
			}
			for (Change_Order__c co : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
				co.Proposal__c = proposalItem.Id;
				co.Project_Profile__c = proposalItem.Project_Profile__c;
				co.Status__c = ChangeOrderServices.STATUS_APPROVED;
				co.Approved_Date__c = Date.today();
				testChangeOrderList.add(co);
			}
		}
		insert testChangeOrderList;

		for (Change_Order__c co : testChangeOrderList){
			for(Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, co.Proposal__c, false)){
				serviceItemItem.Quantity__c = 2;
				serviceItemItem.Unit_Price__c = 10;
				serviceItemItem.Discount_Percentage__c = 5;
				serviceItemItem.Project_Profile__c = co.Project_Profile__c;
				serviceItemItem.Change_Order__c = co.Id;
				testServiceItemList.add(serviceItemItem);
			}
			for(Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, co.Proposal__c, false)){
				serviceItemItem.Quantity__c = 2;
				serviceItemItem.Unit_Price__c = 10;
				serviceItemItem.Discount_Percentage__c = 5;
				serviceItemItem.Project_Profile__c = co.Project_Profile__c;
				serviceItemItem.Change_Order_Old__c = co.Id;
				serviceItemItem.Is_Amendmend_Deleted__c = true;
				testServiceItemList.add(serviceItemItem);
			}
		}

		insert testServiceItemList;
	}

	private static testmethod void testCreation(){
		setupData();

		testBatch = new CreateBatch3FullRecalculation();
		System.assert(testBatch != null);

		Test.startTest();
			Database.executeBatch(testBatch);
		Test.stopTest();
	}


	private static testmethod void testScheduleJob (){
		String jobExpretion = '0 0 0 3 9 ? 2022';
		String nextTimeJob = '2022-09-03 00:00:00';
		String jobId;

		testBatch = new CreateBatch3FullRecalculation();

		Test.startTest();
			jobId = System.schedule('testScheduledApex', jobExpretion, testBatch);
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
		System.assertEquals(jobExpretion, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
	}
}