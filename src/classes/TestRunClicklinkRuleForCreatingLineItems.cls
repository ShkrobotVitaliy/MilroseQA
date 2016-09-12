@isTest
private class TestRunClicklinkRuleForCreatingLineItems {
    
    private static final String TEST_CRON_EXPRESSION = '0 0 0 15 3 ? 2022';
    private static final Integer NUMBER_TO_CREATE_INTEGRATION_RULE = 1;
    private static final Integer NUMBER_TO_CREATE_INTEGRATION_RULE_JOB = 1;

    @isTest 
    private static void test_method_one() {
        
        setup();

        Test.startTest();

        String jobId = System.schedule('testBasicScheduledApex',
            TEST_CRON_EXPRESSION, 
            new RunClicklinkRuleForCreatingLineItems());

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                            FROM CronTrigger 
                            WHERE id = :jobId];

        System.assertEquals(TEST_CRON_EXPRESSION, ct.CronExpression);

        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
    

    private static void setup(){

        List<ffirule__IntegrationRule__c> testIntegrationRuleList = TestingUtils.createIntegrationRuleList(NUMBER_TO_CREATE_INTEGRATION_RULE, 'Name', 'Pro_forma_Invoice__c', 'Name', 'c2g__codaInvoice__c', false);
        insert testIntegrationRuleList;

        List<ffirule__IntegrationRuleJob__c> testIntegrationRuleJobList = new List<ffirule__IntegrationRuleJob__c>();

        for (ffirule__IntegrationRule__c integrationRuleItem : testIntegrationRuleList){
            for (ffirule__IntegrationRuleJob__c integrationRuleJobItem : TestingUtils.createIntegrationRuleJobList(NUMBER_TO_CREATE_INTEGRATION_RULE_JOB, integrationRuleItem.Id, 'test', false)){
                integrationRuleJobItem.Name = PurchaseInvoiceServices.CREATE_BLI_JOB_NAME;
                testIntegrationRuleJobList.add(integrationRuleJobItem);
            }
            for (ffirule__IntegrationRuleJob__c integrationRuleJobItem : TestingUtils.createIntegrationRuleJobList(NUMBER_TO_CREATE_INTEGRATION_RULE_JOB, integrationRuleItem.Id, 'test', false)){
                integrationRuleJobItem.Name = PurchaseInvoiceServices.CREATE_LEGACY_BILLING_ITEM_JOB_NAME;
                testIntegrationRuleJobList.add(integrationRuleJobItem);
            }           
        }

        insert testIntegrationRuleJobList;
    }

    
}