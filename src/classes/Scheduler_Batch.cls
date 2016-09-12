global class Scheduler_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

    global Integer counter = 0;
    
    global void finish( Database.BatchableContext bc ) {
        Integer countLeft = [ SELECT Count() FROM Schedulable_Job__c WHERE Active__c = false AND Status__c = 'TO BE SCHEDULED' ];
        if (countLeft > 0) {
            System.scheduleBatch( new Scheduler_Batch(), 'Scheduler batch', 0, 1 );
        } else {
            System.scheduleBatch( new Updater_Batch(), 'Updater batch', 2, 100 );
        }
    }

    global void execute( Database.BatchableContext bc, SObject[] scope ) {
        Map<Id, CronTrigger> chunkedIdToFull = new Map<Id, CronTrigger>();
        Integer start = System.Now().second();
        for ( Schedulable_Job__c job : (Schedulable_Job__c[]) scope ) {
            System.debug(LoggingLevel.ERROR, 'job : ' + job );
            Type t = Type.forName( job.CompleteApexClassName__c );
            System.debug(LoggingLevel.ERROR, 'CompleteApexClassName : ' + job.CompleteApexClassName__c );
            System.debug(LoggingLevel.ERROR, 't : ' + t );


            Schedulable so = (Schedulable) t.newInstance();
            System.debug(LoggingLevel.ERROR, 'so : ' + so );
            while( System.Now().second() == start ) {
            }
            job.CronTriggerId__c = System.schedule( job.Name, job.CronExpression__c, so );
            job.Active__c = true;
            counter++;
            start = System.Now().second();
            chunkedIdToFull.put( job.CronTriggerId__c, null );
        }
        chunkedIdToFull = new Map<Id, CronTrigger>( [ SELECT Id, CreatedDate FROM CronTrigger WHERE Id IN :chunkedIdToFull.keySet() ] );




        for ( Schedulable_Job__c job : (Schedulable_Job__c[]) scope ) {
            job.CronTriggerId__c = chunkedIdToFull.get( job.CronTriggerId__c ).Id;
            job.CreatedDate__c = chunkedIdToFull.get( job.CronTriggerId__c ).CreatedDate;
            job.Status__c = 'SCHEDULING...';
        }
        update scope;
    }

    global Database.QueryLocator start( Database.BatchableContext bc ) {
        return Database.getQueryLocator( 'SELECT Name, CronExpression__c, ApexClassId__c, NamespacePrefix__c, ApexClassName__c, CompleteApexClassName__c, Active__c FROM Schedulable_Job__c WHERE Active__c = false AND Status__c = \'TO BE SCHEDULED\' limit ' + ( Test.isRunningTest() ? '1' : '40') );
    }

}