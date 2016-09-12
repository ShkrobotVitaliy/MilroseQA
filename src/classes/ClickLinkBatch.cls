global class ClickLinkBatch implements Database.Batchable<SObject>, Database.Stateful {
    ffirule.IntegrationRuleEngine engine;

    global ClickLinkBatch() { 
        // initialise job with Scheduled Job ID 
    }

    global ClickLinkBatch(String jobName) {
        // initialise job with Scheduled Job ID
        this.engine = new ffirule.IntegrationRuleEngine(getJobById(jobName));
    
    }

    global ClickLinkBatch(ffirule__IntegrationRuleJob__c job) {
        this.engine = new ffirule.IntegrationRuleEngine(job);
    
    }

    private ffirule__IntegrationRuleJob__c getJobById(String jobName) {
        List<ffirule__IntegrationRuleJob__c> jobs = new List<ffirule__IntegrationRuleJob__c>([SELECT Id, 
                                                                                                     ffirule__IntegrationRule__c, 
                                                                                                     ffirule__IntegrationRule__r.Id, 
                                                                                                     ffirule__IntegrationRule__r.ffirule__SourceObject__c,
                                                                                                     ffirule__ListViewObject__c, 
                                                                                                     ffirule__ListViewSourceIDField__c, 
                                                                                                     ffirule__ListViewName__c, 
                                                                                                     ffirule__ScheduledApexJobCronExpression__c, 
                                                                                                     ffirule__ScheduledApexJobID__c
                                                                                              FROM ffirule__IntegrationRuleJob__c 
                                                                                              WHERE Name =: jobName]);                            
        
        if (jobs.isEmpty()) {
            return new ffirule__IntegrationRuleJob__c();
        
        }
        return jobs.get(0);
    
    }
    
    global Database.QueryLocator start(Database.BatchableContext ctx) {
        // delegate to ClickLink
        return engine.start(ctx);
    
    }

    global void execute(Database.BatchableContext ctx, List<SObject> scope) {
        // delegate to ClickLink
        engine.execute(ctx, scope);
    
    }

    global void finish(Database.BatchableContext ctx) {
        // delegate to ClickLink if no more companies to process
        engine.finish(ctx);
    
    }

}