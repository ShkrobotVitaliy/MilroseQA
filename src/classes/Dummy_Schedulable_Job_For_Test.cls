global class Dummy_Schedulable_Job_For_Test implements Schedulable, Database.Batchable<SObject>{
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Dummy_Schedulable_Job_For_Test(), 1);
    }
    
    public Dummy_Schedulable_Job_For_Test( ) {
    }

    global void finish( Database.BatchableContext bc ) {
    }
    
    global void execute( Database.BatchableContext bc, SObject[] scope ) {
    }
    
    global Database.QueryLocator start( Database.BatchableContext bc ) {
        return Database.getQueryLocator( 'SELECT Name FROM Schedulable_Job__c' );
    }

}