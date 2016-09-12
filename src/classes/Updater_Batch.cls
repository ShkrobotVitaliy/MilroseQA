global class Updater_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    public Updater_Batch( ) {
    }

    global void finish( Database.BatchableContext bc ) {
    }

    global void execute( Database.BatchableContext bc, SObject[] scope ) {
        List<Schedulable_Job__c> jobs = (Schedulable_Job__c[]) scope;
        List<DateTime> dates = new List<DateTime>();
        Map<Datetime, AsyncApexJob> createdDateToAsyncApexJob = new Map<Datetime, AsyncApexJob>();
        for ( Schedulable_Job__c job : jobs ) {
            dates.add( job.CreatedDate__c );
        }
        for ( AsyncApexJob aj : [ SELECT CreatedDate, ApexClassId, Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate IN :dates] ) {
            createdDateToAsyncApexJob.put( aj.CreatedDate, aj );
        }

        AsyncApexJob newAj;

        for ( Schedulable_Job__c job : jobs ) {
            newAj = createdDateToAsyncApexJob.get( job.CreatedDate__c );
            job.AsyncApexJobId__c = newAj.Id;
            job.Status__c = 'SCHEDULED';
        }
        update jobs;
    }

    global Database.QueryLocator start( Database.BatchableContext bc ) {
        return Database.getQueryLocator( 'SELECT Name, CronExpression__c, ApexClassId__c,  NamespacePrefix__c,  ApexClassName__c,  CompleteApexClassName__c,  CreatedDate__c,  CronTriggerId__c,  AsyncApexJobId__c, Active__c FROM Schedulable_Job__c WHERE Status__c = \'SCHEDULING...\'' );
    }

}