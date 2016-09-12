global class CreatePreBatchFullRecalculation implements  Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{

    global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreatePreBatchFullRecalculation(), 2000 );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator('Select Name, Id, c2g__StartDate__c, Trailing_12_Month_Revenue_PY__c, Trailing_12_Month_Revenue_CY__c, Cash_Balances_CY__c, Trailing_12_Month_Awarded_Proposals_PY__c, ' +
                                       '     Trailing_12_Month_Awarded_Proposals_CY__c, Day_Sales_Outstanding_PY__c, Day_Sales_Outstanding_CY__c, Cash_Balances_PY__c, Accounts_Receivable_PY__c, Accounts_Receivable_CY__c, ' +
                                       '     Accounts_Receivable_Month__c, Cash_Balances_Month__c, Trailing_12_Month_Awarded_Proposal_Month__c, Trailing_12_Month_Revenue_Month__c, Total_Billed_Amount_Month__c, Awarded_Proposal_History__c ' +
                                       'From c2g__codaPeriod__c');
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        List<c2g__codaPeriod__c> scopeList = ( List<c2g__codaPeriod__c> ) scope;

        for( c2g__codaPeriod__c item: scopeList ){
            item.Accounts_Receivable_Month__c = 0;
            item.Cash_Balances_Month__c = 0;
            item.Trailing_12_Month_Awarded_Proposal_Month__c = (item.Awarded_Proposal_History__c != null) ? item.Awarded_Proposal_History__c : 0; //MRS-6785
            item.Trailing_12_Month_Revenue_Month__c = 0;
            item.Total_Billed_Amount_Month__c = 0;
            item.Accounts_Receivable_CY__c = 0;
            item.Accounts_Receivable_PY__c = 0;
            item.Cash_Balances_CY__c = 0;
            item.Cash_Balances_PY__c = 0;
            item.Day_Sales_Outstanding_CY__c = 0;
            item.Day_Sales_Outstanding_PY__c = 0;
            item.Trailing_12_Month_Awarded_Proposals_CY__c = 0;
            item.Trailing_12_Month_Awarded_Proposals_PY__c = 0;
            item.Trailing_12_Month_Revenue_CY__c = 0;
            item.Trailing_12_Month_Revenue_PY__c = 0;
            item.Trailing_12_Month_Awarded_Proposal_Pmnth__c= 0;
            item.Trailing_12_Month_Revenue_Pmnth__c= 0;
        }

        update scopeList;
    }

    global void finish(Database.BatchableContext BC){

    }
}