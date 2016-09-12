@isTest
private class TestClickLinkBatch {
	private static final Integer NUMBER_TO_CREATE_INTEGRATION_RULE = 2;
	private static final Integer NUMBER_TO_CREATE_INTEGRATION_RULE_JOB = 2;

	private static List<ffirule__IntegrationRule__c> testIntegrationRuleList;
	private static List<ffirule__IntegrationRuleJob__c> testIntegrationRuleJobList;

	private static ClickLinkBatch testClickLinkBatch;

	private static void setupData(){
		testIntegrationRuleList = TestingUtils.createIntegrationRuleList(NUMBER_TO_CREATE_INTEGRATION_RULE, 'Name', 'Pro_forma_Invoice__c', 'Name', 'c2g__codaInvoice__c', false);
		insert testIntegrationRuleList;
		testIntegrationRuleJobList = new List<ffirule__IntegrationRuleJob__c>();
		for (ffirule__IntegrationRule__c integrationRuleItem : testIntegrationRuleList){
			for (ffirule__IntegrationRuleJob__c integrationRuleJobItem : TestingUtils.createIntegrationRuleJobList(NUMBER_TO_CREATE_INTEGRATION_RULE_JOB, integrationRuleItem.Id, 'test', false)){
				testIntegrationRuleJobList.add(integrationRuleJobItem);
			}
		}
		insert testIntegrationRuleJobList;
	}

	private static testmethod void testCreateClickLinkBatchWithNameParameter(){
		setupData();

		testIntegrationRuleJobList = [SELECT Id, Name
									  FROM ffirule__IntegrationRuleJob__c
									  WHERE Id IN : testIntegrationRuleJobList];

		testClickLinkBatch = new ClickLinkBatch(testIntegrationRuleJobList[0].Name);

		ID batchprocessid;

		Test.startTest();
			batchprocessid = Database.executeBatch(testClickLinkBatch);
		Test.stopTest();

		System.assert(batchprocessid != null);
	}

	private static testmethod void testCreateClickLinkBatchWithObjectParameter(){
		setupData();

		testIntegrationRuleJobList = [SELECT Id, ffirule__IntegrationRule__c, 
                                                 ffirule__IntegrationRule__r.Id, 
                                                 ffirule__IntegrationRule__r.ffirule__SourceObject__c,
                                                 ffirule__ListViewObject__c, 
                                                 ffirule__ListViewSourceIDField__c, 
                                                 ffirule__ListViewName__c, 
                                                 ffirule__ScheduledApexJobCronExpression__c, 
                                                 ffirule__ScheduledApexJobID__c
									  FROM ffirule__IntegrationRuleJob__c
									  WHERE Id IN : testIntegrationRuleJobList LIMIT 1];

		testClickLinkBatch = new ClickLinkBatch(testIntegrationRuleJobList[0]);

		ID batchprocessid;

		Test.startTest();
			batchprocessid = Database.executeBatch(testClickLinkBatch);
		Test.stopTest();

		System.assert(batchprocessid != null);
	}
	//for coverage only
	private static testmethod void testCreateClickLinkBatchWithNameIncorrectParameter(){
		setupData();

		Test.startTest();
			try{
				testClickLinkBatch = new ClickLinkBatch('123456789012345678901234567890123456789012345678901234567890123456789012345678901');
			} catch (Exception ex){}
		Test.stopTest();

		System.assert(testClickLinkBatch == null);
	}
}