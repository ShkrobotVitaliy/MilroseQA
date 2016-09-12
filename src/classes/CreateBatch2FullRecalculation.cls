global class CreateBatch2FullRecalculation implements  Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{
    //before batch execute set all values on period to 0!

    global void execute(SchedulableContext sc) { // MRS 7333
        Database.executeBatch( new CreateBatch2FullRecalculation(), 2000 );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator('Select Id, Base_Services_Total__c, Proposal_Awarded_Date__c'
										+' From Proposal__c'
										+' Where Mi3_MRC__c=null and Status__c=\'Awarded\' and Proposal_Awarded_Date__c!=null');
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Map<Date, c2g__codaPeriod__c> periodsMap = new Map<Date, c2g__codaPeriod__c>();

        for( c2g__codaPeriod__c item: [ Select Id, Name, c2g__StartDate__c, Trailing_12_Month_Awarded_Proposal_Month__c
                                        From c2g__codaPeriod__c
                                        Where c2g__PeriodNumber__c != '000' And c2g__PeriodNumber__c != '100' And c2g__PeriodNumber__c != '101' ] ){
            periodsMap.put( Date.newInstance(item.c2g__StartDate__c.year(), item.c2g__StartDate__c.month(), 1), item );
        }

		List<Proposal__c> scopeList = ( List<Proposal__c> ) scope;
		for(Proposal__c p : scopeList) {
			if(periodsMap.get( Date.newInstance(p.Proposal_Awarded_Date__c.year(), p.Proposal_Awarded_Date__c.month(), 1) ) != null && p.Base_Services_Total__c != null) {
				periodsMap.get( Date.newInstance(p.Proposal_Awarded_Date__c.year(), p.Proposal_Awarded_Date__c.month(), 1) ).Trailing_12_Month_Awarded_Proposal_Month__c += p.Base_Services_Total__c;
            }
        }

        update periodsMap.values();
    }

    global void finish(Database.BatchableContext BC){

    }
}