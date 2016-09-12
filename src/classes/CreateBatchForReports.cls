global class CreateBatchForReports implements Schedulable, Database.Batchable<Sobject>{

    public static final String BATCH_JOB_TITLE = 'Creates Batch For Partner Reports';

    global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateBatchForReports(), Integer.valueOf(Label.CreateBatchForReports) );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator('SELECT Id ' +
                                       'FROM c2g__codaPeriod__c ' +
                                       'WHERE c2g__PeriodNumber__c != \'000\' AND c2g__PeriodNumber__c != \'100\' AND c2g__PeriodNumber__c != \'101\' ' +
//                                       '       AND c2g__StartDate__c < today ' +
                                       '       Order by Name');
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        List<c2g__codaPeriod__c> scopeList = ( List<c2g__codaPeriod__c> ) scope;

        List<c2g__codaPeriod__c> periods = [Select Name, Id, Trailing_12_Month_Revenue_PY__c, Trailing_12_Month_Revenue_CY__c, Trailing_12_Month_Revenue_Month__c,
                                                Accounts_Receivable_CY__c, Accounts_Receivable_PY__c, Accounts_Receivable_Month__c,
                                                Cash_Balances_CY__c, Cash_Balances_PY__c, Cash_Balances_Month__c,
                                                Total_Billed_Amount_Numbers_Old_PY__c, Total_Billed_Amount_Numbers_Old__c, Total_Billed_Amount_Month__c, Day_Sales_Outstanding_CY__c, Day_Sales_Outstanding_PY__c,
                                                Trailing_12_Month_Awarded_Proposals_CY__c, Trailing_12_Month_Awarded_Proposals_PY__c, Trailing_12_Month_Awarded_Proposal_Month__c,
                                                c2g__StartDate__c, c2g__EndDate__c, c2g__YearName__r.Name
                                            From c2g__codaPeriod__c
                                            Where Id IN : scopeList];

        Map<String, c2g__codaPeriod__c> yearToPeriod = new Map<String, c2g__codaPeriod__c>();

        for( c2g__codaPeriod__c item: [Select Name, Id, Trailing_12_Month_Revenue_PY__c, Trailing_12_Month_Revenue_CY__c, Trailing_12_Month_Revenue_Month__c,
                                            Accounts_Receivable_CY__c, Accounts_Receivable_PY__c, Accounts_Receivable_Month__c,
                                            Cash_Balances_CY__c, Cash_Balances_PY__c, Cash_Balances_Month__c,
                                            Total_Billed_Amount_Numbers_Old_PY__c, Total_Billed_Amount_Numbers_Old__c, Total_Billed_Amount_Month__c, Day_Sales_Outstanding_CY__c, Day_Sales_Outstanding_PY__c,
                                            Trailing_12_Month_Awarded_Proposals_CY__c, Trailing_12_Month_Awarded_Proposals_PY__c, Trailing_12_Month_Awarded_Proposal_Month__c,
                                            c2g__StartDate__c, c2g__EndDate__c, c2g__YearName__r.Name
                                       From c2g__codaPeriod__c
                                       Where c2g__PeriodNumber__c = '000'] ){
            yearToPeriod.put( item.c2g__YearName__r.Name, item );
        }

        for(c2g__codaPeriod__c item: periods){
            if (item.c2g__StartDate__c < Date.today()){
                List<AggregateResult> trailings1 = [Select SUM(Trailing_12_Month_Revenue_Month__c) value1
                                                    From c2g__codaPeriod__c
                                                    Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND
                                                        c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                        c2g__PeriodNumber__c != '000'AND
                                                        c2g__PeriodNumber__c != '101' ];

                List<AggregateResult> trailings1Old = [Select SUM(Trailing_12_Month_Revenue_Month__c) value1
                                                       From c2g__codaPeriod__c
                                                       Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND
                                                            c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                            c2g__PeriodNumber__c != '000'AND
                                                            c2g__PeriodNumber__c != '101' ];

                List<AggregateResult> trailings2_3 = [Select SUM(Accounts_Receivable_Month__c) value2,
                                                            SUM(Cash_Balances_Month__c) value3
                                                      From c2g__codaPeriod__c
                                                      Where c2g__StartDate__c >=: yearToPeriod.get(item.c2g__YearName__r.Name).c2g__StartDate__c AND
                                                            c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                            c2g__PeriodNumber__c != '101' ];

                List<AggregateResult> trailings2_3Old = [Select SUM(Accounts_Receivable_Month__c) value2,
                                                            SUM(Cash_Balances_Month__c) value3
                                                         From c2g__codaPeriod__c
                                                         Where c2g__StartDate__c >=: yearToPeriod.get(item.c2g__YearName__r.Name).c2g__StartDate__c.addYears(-1) AND
                                                            c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                            c2g__PeriodNumber__c != '101' ];

                List<AggregateResult> trailings4_5 = [Select SUM(Trailing_12_Month_Awarded_Proposal_Month__c) value5
                                                      From c2g__codaPeriod__c
                                                      Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND
                                                            c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                            c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000' AND
                                                            c2g__PeriodNumber__c != '100'];

                List<AggregateResult> trailings4_5Old = [Select SUM(Trailing_12_Month_Awarded_Proposal_Month__c) value5
                                                    From c2g__codaPeriod__c
                                                    Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND
                                                        c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                        c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000'AND
                                                        c2g__PeriodNumber__c != '100'];

                //Trailing 12 Month Revenue
                item.Trailing_12_Month_Revenue_CY__c = (Decimal)trailings1[0].get('value1');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Trailing_12_Month_Revenue_CY__c);

                item.Trailing_12_Month_Revenue_PY__c = (Decimal)trailings1Old[0].get('value1');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Trailing_12_Month_Revenue_CY__c);

                //Accounts Receivable
                item.Accounts_Receivable_CY__c = (Decimal)trailings2_3[0].get('value2');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Accounts_Receivable_CY__c);

                item.Accounts_Receivable_PY__c = (Decimal)trailings2_3Old[0].get('value2');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Accounts_Receivable_PY__c);

                //Cash Balances
                item.Cash_Balances_CY__c = (Decimal)trailings2_3[0].get('value3');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Cash_Balances_CY__c);

                item.Cash_Balances_PY__c = (Decimal)trailings2_3Old[0].get('value3');
                system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Cash_Balances_PY__c);

                //Trailing 12 Month Awarded Proposals
                item.Trailing_12_Month_Awarded_Proposals_CY__c = (Decimal)trailings4_5[0].get('value5');
                system.debug('item.Trailing_12_Month_Awarded_Proposals_CY__c'+item.Trailing_12_Month_Awarded_Proposals_CY__c);

                item.Trailing_12_Month_Awarded_Proposals_PY__c = (Decimal)trailings4_5Old[0].get('value5');
                system.debug('item.Trailing_12_Month_Awarded_Proposals_PY__c'+item.Trailing_12_Month_Awarded_Proposals_PY__c);
            }

            List<AggregateResult> trailings5_5 = [Select SUM(Total_Billed_Amount_Month__c) value5_5
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND c2g__StartDate__c >: date.newinstance( 2014, 6, 30 ) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000' AND
                                                    c2g__PeriodNumber__c != '100'];

            List<AggregateResult> trailings5_5Old = [Select SUM(Total_Billed_Amount_Month__c) value5_5
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND c2g__StartDate__c >: date.newinstance( 2014, 6, 30 ) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000'AND
                                                    c2g__PeriodNumber__c != '100'];

system.debug('item'+item.Name);
system.debug('trailings5_5='+trailings5_5);
system.debug('trailings5_5Old='+trailings5_5Old);
            //Day Sales Outstanding
            Decimal total_Billed_Amount_Numbers_Old = 0;
            Decimal total_Billed_Amount_Numbers_Old_PY = 0;
            Decimal trailing12ProformaInvoiceTotalCY = ( (Decimal)trailings5_5[0].get('value5_5') != null ) ? (Decimal)trailings5_5[0].get('value5_5') : 0;
            Decimal trailing12ProformaInvoiceTotalPY = ( (Decimal)trailings5_5Old[0].get('value5_5') != null ) ? (Decimal)trailings5_5Old[0].get('value5_5') : 0;

            if ( item.c2g__StartDate__c >= date.newinstance(2012, 1, 1) &&
                 item.c2g__StartDate__c < date.newinstance(2015, 6, 1) &&
                 item.Total_Billed_Amount_Numbers_Old__c != null &&
                 item.Total_Billed_Amount_Numbers_Old__c != 0 ){

                total_Billed_Amount_Numbers_Old = item.Total_Billed_Amount_Numbers_Old__c;
                system.debug('total_Billed_Amount_Numbers_Old='+total_Billed_Amount_Numbers_Old);
            }

            if( ( trailing12ProformaInvoiceTotalCY + total_Billed_Amount_Numbers_Old ) != 0 ) {
                if ( item.Accounts_Receivable_CY__c != null && item.Accounts_Receivable_CY__c != 0 ){
                    if ( item.c2g__StartDate__c >= date.newinstance( 2014, 7, 1 ) ){
                        item.Day_Sales_Outstanding_CY__c = 365 * item.Accounts_Receivable_CY__c / ( trailing12ProformaInvoiceTotalCY + total_Billed_Amount_Numbers_Old );
                    }else{
                        if( total_Billed_Amount_Numbers_Old != 0 ) item.Day_Sales_Outstanding_CY__c = 365 * item.Accounts_Receivable_CY__c / ( total_Billed_Amount_Numbers_Old );
                    }
                }

            }

            item.Day_Sales_Outstanding_CY__c = ( item.Day_Sales_Outstanding_CY__c == null ) ? 0 : item.Day_Sales_Outstanding_CY__c;

            system.debug('item.Day_Sales_Outstanding_CY__c='+item.Day_Sales_Outstanding_CY__c);

            if ( item.c2g__StartDate__c >= date.newinstance(2012, 1, 1) &&
                 item.c2g__StartDate__c < date.newinstance(2016, 6, 1) &&
                 item.Total_Billed_Amount_Numbers_Old_PY__c != null &&
                 item.Total_Billed_Amount_Numbers_Old_PY__c != 0 ){
                total_Billed_Amount_Numbers_Old_PY = item.Total_Billed_Amount_Numbers_Old_PY__c;
            }

            if( ( trailing12ProformaInvoiceTotalPY + total_Billed_Amount_Numbers_Old_PY ) != 0 ) {
                if ( item.Accounts_Receivable_PY__c != null && item.Accounts_Receivable_PY__c != 0 ){
                    if ( item.c2g__StartDate__c >= date.newinstance( 2014, 7, 1 ) ){
                        item.Day_Sales_Outstanding_PY__c = 365 * item.Accounts_Receivable_PY__c / ( trailing12ProformaInvoiceTotalPY + total_Billed_Amount_Numbers_Old_PY );
                    }else{
                        if( total_Billed_Amount_Numbers_Old_PY != 0 ) item.Day_Sales_Outstanding_PY__c = 365 * item.Accounts_Receivable_PY__c / total_Billed_Amount_Numbers_Old_PY;
                    }
                }

            }

            system.debug('item.Day_Sales_Outstanding_PY__c'+item.Day_Sales_Outstanding_PY__c);
        }

        update periods;
    }

    global void finish(Database.BatchableContext BC){

    }

/*
    global CreateBatchForReports() {}

    global void execute(SchedulableContext sc) {
        CreateBatchForReports job = new CreateBatchForReports();
        job.execute();
    }

    @future
    public static void futureExecution(){
        List<c2g__codaPeriod__c> periods = [Select Name, Id, Trailing_12_Month_Revenue_PY__c, Trailing_12_Month_Revenue_CY__c, Trailing_12_Month_Revenue_Month__c,
                                                Accounts_Receivable_CY__c, Accounts_Receivable_PY__c, Accounts_Receivable_Month__c,
                                                Cash_Balances_CY__c, Cash_Balances_PY__c, Cash_Balances_Month__c,
                                                Total_Billed_Amount_Numbers_Old_PY__c, Total_Billed_Amount_Numbers_Old__c, Total_Billed_Amount_Month__c, Day_Sales_Outstanding_CY__c, Day_Sales_Outstanding_PY__c,
                                                Trailing_12_Month_Awarded_Proposals_CY__c, Trailing_12_Month_Awarded_Proposals_PY__c, Trailing_12_Month_Awarded_Proposal_Month__c,
                                                c2g__StartDate__c, c2g__EndDate__c, c2g__YearName__r.Name
                                            From c2g__codaPeriod__c
                                            Where c2g__StartDate__c >: Date.today().addMonths(-32) AND
					    c2g__StartDate__c <: Date.today() AND 
					    c2g__PeriodNumber__c != '000' AND
                                                c2g__PeriodNumber__c != '100'AND
                                                c2g__PeriodNumber__c != '101'];
        Map<String, c2g__codaPeriod__c> yearToPeriod = new Map<String, c2g__codaPeriod__c>();
        for( c2g__codaPeriod__c item: [Select Name, Id, Trailing_12_Month_Revenue_PY__c, Trailing_12_Month_Revenue_CY__c, Trailing_12_Month_Revenue_Month__c,
                                                Accounts_Receivable_CY__c, Accounts_Receivable_PY__c, Accounts_Receivable_Month__c,
                                                Cash_Balances_CY__c, Cash_Balances_PY__c, Cash_Balances_Month__c,
                                                Total_Billed_Amount_Numbers_Old_PY__c, Total_Billed_Amount_Numbers_Old__c, Total_Billed_Amount_Month__c, Day_Sales_Outstanding_CY__c, Day_Sales_Outstanding_PY__c,
                                                Trailing_12_Month_Awarded_Proposals_CY__c, Trailing_12_Month_Awarded_Proposals_PY__c, Trailing_12_Month_Awarded_Proposal_Month__c,
                                                c2g__StartDate__c, c2g__EndDate__c, c2g__YearName__r.Name
                                            From c2g__codaPeriod__c
                                            Where c2g__PeriodNumber__c = '000'] ){
            yearToPeriod.put( item.c2g__YearName__r.Name, item );
        }

        for(c2g__codaPeriod__c item: periods){
            List<AggregateResult> trailings1 = [Select SUM(Trailing_12_Month_Revenue_Month__c) value1
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                    c2g__PeriodNumber__c != '000'AND
                                                    c2g__PeriodNumber__c != '101' ];

            List<AggregateResult> trailings1Old = [Select SUM(Trailing_12_Month_Revenue_Month__c) value1
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                    c2g__PeriodNumber__c != '000'AND
                                                    c2g__PeriodNumber__c != '101' ];

            List<AggregateResult> trailings2_3 = [Select SUM(Accounts_Receivable_Month__c) value2,
                                                    SUM(Cash_Balances_Month__c) value3
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >=: yearToPeriod.get(item.c2g__YearName__r.Name).c2g__StartDate__c AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                    c2g__PeriodNumber__c != '101' ];

            List<AggregateResult> trailings2_3Old = [Select SUM(Accounts_Receivable_Month__c) value2,
                                                    SUM(Cash_Balances_Month__c) value3
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >=: yearToPeriod.get(item.c2g__YearName__r.Name).c2g__StartDate__c.addYears(-1) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                    c2g__PeriodNumber__c != '101' ];

            List<AggregateResult> trailings4_5 = [Select SUM(Total_Billed_Amount_Month__c) value4,
                                                    SUM(Trailing_12_Month_Awarded_Proposal_Month__c) value5
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000' AND
                                                    c2g__PeriodNumber__c != '100'];

            List<AggregateResult> trailings4_5Old = [Select SUM(Total_Billed_Amount_Month__c) value4,
                                                    SUM(Trailing_12_Month_Awarded_Proposal_Month__c) value5
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000'AND
                                                    c2g__PeriodNumber__c != '100'];

            //Trailing 12 Month Revenue
            item.Trailing_12_Month_Revenue_CY__c = (Decimal)trailings1[0].get('value1');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Trailing_12_Month_Revenue_CY__c);

            item.Trailing_12_Month_Revenue_PY__c = (Decimal)trailings1Old[0].get('value1');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Trailing_12_Month_Revenue_CY__c);

            //Accounts Receivable
            item.Accounts_Receivable_CY__c = (Decimal)trailings2_3[0].get('value2');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Accounts_Receivable_CY__c);

            item.Accounts_Receivable_PY__c = (Decimal)trailings2_3Old[0].get('value2');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Accounts_Receivable_PY__c);

            //Cash Balances
            item.Cash_Balances_CY__c = (Decimal)trailings2_3[0].get('value3');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Cash_Balances_CY__c);

            item.Cash_Balances_PY__c = (Decimal)trailings2_3Old[0].get('value3');
            system.debug('item.Trailing_12_Month_Revenue_CY__c'+item.Cash_Balances_PY__c);

            //Trailing 12 Month Awarded Proposals
            item.Trailing_12_Month_Awarded_Proposals_CY__c = (Decimal)trailings4_5[0].get('value5');
            system.debug('item.Trailing_12_Month_Awarded_Proposals_CY__c'+item.Trailing_12_Month_Awarded_Proposals_CY__c);

            item.Trailing_12_Month_Awarded_Proposals_PY__c = (Decimal)trailings4_5Old[0].get('value5');
            system.debug('item.Trailing_12_Month_Awarded_Proposals_PY__c'+item.Trailing_12_Month_Awarded_Proposals_PY__c);

        }

        update periods;
    }

    //Execute method
    global void execute() {
        futureExecution();
    }
*/
}