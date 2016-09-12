global class CreateBatch1FullRecalculation implements  Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{
	//before batch execute set all values on period to 0!

	global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateBatch1FullRecalculation(), Integer.valueOf(Label.CreateBatch1FullRecalculation) );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator('SELECT Id, Name, Total_Billed_Amount_Month__c ' +
       								   'FROM c2g__codaPeriod__c ' +
       								   'Where (Not Name Like \'%/000\') AND (Not Name Like \'%/100\') AND (Not Name Like \'%/101\') ' +
       								   'Order by Name');
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
    	Map<Id, c2g__codaPeriod__c> periodMap = new Map<Id, c2g__codaPeriod__c>(( List<c2g__codaPeriod__c> ) scope);

    	for (c2g__codaInvoice__c invoice : [SELECT Id, c2g__Period__c, c2g__Period__r.Name, c2g__NetTotal__c
    										FROM c2g__codaInvoice__c
    										WHERE c2g__Period__c IN : periodMap.keySet() AND
    											c2g__NetTotal__c != null AND
    											c2g__NetTotal__c != 0]){

    		periodMap.get(invoice.c2g__Period__c).Total_Billed_Amount_Month__c = periodMap.get(invoice.c2g__Period__c).Total_Billed_Amount_Month__c + invoice.c2g__NetTotal__c;
    	}

	    System.Debug(LoggingLevel.ERROR, '^^^ periodMap.values() = ' + periodMap.values());

	    for (c2g__codaCreditNote__c creditNote : [SELECT Id, c2g__NetTotal__c, c2g__Period__r.Name
	    										FROM c2g__codaCreditNote__c 
	    										WHERE c2g__Period__c IN : periodMap.keySet() AND
	    											c2g__NetTotal__c != null AND
	    											c2g__NetTotal__c != 0]){

    		periodMap.get(creditNote.c2g__Period__c).Total_Billed_Amount_Month__c = periodMap.get(creditNote.c2g__Period__c).Total_Billed_Amount_Month__c - creditNote.c2g__NetTotal__c;
    	}

	    System.Debug(LoggingLevel.ERROR, '^^^ periodMap.values() = ' + periodMap.values());
	    update periodMap.values();
    }

    global void finish(Database.BatchableContext BC){

    }
}