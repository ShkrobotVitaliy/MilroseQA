@isTest
private class TestBatchForCalculationProjectsPerTeam {
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;

	private static List<Project_Team__c> testProjectTeamList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;
	public static User testProductionManagerUser;

	private static CreateBatchForCalculationProjectsPerTeam testBatch;

	private static void setupData (){
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
	}

	private static testmethod void testCreation(){

		Test.startTest();
			testBatch = new CreateBatchForCalculationProjectsPerTeam();
		Test.stopTest();

		System.assert(testBatch != null);
	}

	private static testmethod void testCreateBatchForCalculationProjectsPerTeam(){
		setupData();
		testProjectTeamList = TestingUtils.createProjectTeamList (NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
		testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE * NUMBER_TO_CREATE_PROJECT_TEAM, false);
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_NOT_STARTED;
		}
		for (Integer i = 0; i < NUMBER_TO_CREATE_PROJECT_TEAM; i++){
			for (Integer j = 0; j < NUMBER_TO_CREATE_PROJECT_TEAM; j++){
				testProjectProfileList[i * NUMBER_TO_CREATE_PROJECT_PROFILE + j].Project_Team__c = testProjectTeamList[i].Id;
			}
		}
		insert testProjectProfileList;

		testBatch = new CreateBatchForCalculationProjectsPerTeam();

		Test.startTest();
			Database.executeBatch(testBatch);
		Test.stopTest();

		List<Project_Team__c> testResultProjectTeamList = [ SELECT Id,  Number_Of_Projects__c,
																(Select Id From Projects__r Where Project_State__c = : ProjectProfileServices.PROJECT_STATE_NOT_STARTED OR Project_State__c = : ProjectProfileServices.PROJECT_STATE_IN_PROCESS)
															FROM Project_Team__c
															WHERE Id IN : testProjectTeamList ];

		System.assert(!testResultProjectTeamList.isEmpty());
		System.assertEquals( new Map<Id, Project_Team__c>(testProjectTeamList).keySet(), new Map<Id, Project_Team__c>(testResultProjectTeamList).keySet() );

		for (Project_Team__c projectTeamItem : testResultProjectTeamList){
			System.assertEquals(projectTeamItem.Projects__r.size(), projectTeamItem.Number_Of_Projects__c);
		}
	}


	private static testmethod void testScheduleJob (){
		String jobExpretion = '0 0 0 3 9 ? 2022';
		String nextTimeJob = '2022-09-03 00:00:00';
		String jobId;

		testBatch = new CreateBatchForCalculationProjectsPerTeam();

		Test.startTest();
			jobId = System.schedule('testScheduledApex', jobExpretion, testBatch);
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
		System.assertEquals(jobExpretion, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
	}
}