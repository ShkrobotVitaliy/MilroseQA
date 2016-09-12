global class CreateBatchFullRecalculation implements  Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{
    //before batch execute set all values on period to 0!

    global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateBatchFullRecalculation(), 2000 );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator('Select Id, Name, c2g__Period__c, c2g__HomeValue__c, General_Ledger_Account_Type__c, GLA_Trial_Balance_2__c, GLA_Trial_Balance_3__c, ' +
                                       '         c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c ' + //MRS-6597
                                       'From c2g__ReportingBalance__c ' +
                                       'Where c2g__Type__c = \'Actual\' AND c2g__HomeValue__c != 0');
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Map<Id, c2g__codaPeriod__c> periodsMap = new Map<Id, c2g__codaPeriod__c>( );
        Map<Date, Id> dateToPeriodsMap = new Map<Date, Id>( );
        
        for( c2g__codaPeriod__c item: [Select Name, Id, c2g__StartDate__c, Accounts_Receivable_Month__c, Cash_Balances_Month__c, Trailing_12_Month_Awarded_Proposal_Pmnth__c, c2g__PeriodNumber__c,
                                            Trailing_12_Month_Awarded_Proposal_Month__c, Trailing_12_Month_Revenue_Month__c, Total_Billed_Amount_Month__c, Trailing_12_Month_Revenue_Pmnth__c
                                        From c2g__codaPeriod__c ] ){
            periodsMap.put( item.Id, item );
            if (item.c2g__PeriodNumber__c != '000' && item.c2g__PeriodNumber__c != '100' && item.c2g__PeriodNumber__c != '101'){
	    	dateToPeriodsMap.put( item.c2g__StartDate__c, item.Id );
            }
        }

        List<c2g__ReportingBalance__c> scopeList = ( List<c2g__ReportingBalance__c> ) scope;

        for( c2g__ReportingBalance__c item: scopeList ){
            if( item.General_Ledger_Account_Type__c == ReportingBalancesServices.CLA_TYPE_PROFIT_AND_LOSS ){ // MRS 6895
                if( item.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c != null && ((String)item.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c).startsWith('401') ) {
                    periodsMap.get(item.c2g__Period__c).Trailing_12_Month_Revenue_Month__c -= item.c2g__HomeValue__c;
                }
            }else if( item.General_Ledger_Account_Type__c == ReportingBalancesServices.CLA_TYPE_BALANCE_SHEET &&
                      item.c2g__GeneralLedgerAccount__r.c2g__ReportingCode__c == ReportingBalancesServices.CLA_REPORTING_CODE_12100 ){ //MRS-6597
                periodsMap.get(item.c2g__Period__c).Accounts_Receivable_Month__c += item.c2g__HomeValue__c;
            }else if( item.General_Ledger_Account_Type__c == ReportingBalancesServices.CLA_TYPE_BALANCE_SHEET && item.GLA_Trial_Balance_3__c == ReportingBalancesServices.CLA_TRIAL_BALANCE2_CASH ){
                periodsMap.get(item.c2g__Period__c).Cash_Balances_Month__c +=item.c2g__HomeValue__c;
            }
        }

        for( c2g__codaPeriod__c item: periodsMap.values() ){
            if (item.c2g__PeriodNumber__c != '000' && item.c2g__PeriodNumber__c != '100' && item.c2g__PeriodNumber__c != '101'){
                item.Trailing_12_Month_Awarded_Proposal_Pmnth__c = ( dateToPeriodsMap.get( item.c2g__StartDate__c.addYears(-1) ) != null ) ? periodsMap.get( dateToPeriodsMap.get( item.c2g__StartDate__c.addYears(-1) ) ).Trailing_12_Month_Awarded_Proposal_Month__c : 0;
            	item.Trailing_12_Month_Revenue_Pmnth__c = ( dateToPeriodsMap.get( item.c2g__StartDate__c.addYears(-1) ) != null ) ? periodsMap.get( dateToPeriodsMap.get( item.c2g__StartDate__c.addYears(-1) ) ).Trailing_12_Month_Revenue_Month__c : 0;
            }
        }

        update periodsMap.values();
    }

    global void finish(Database.BatchableContext BC){

    }
}