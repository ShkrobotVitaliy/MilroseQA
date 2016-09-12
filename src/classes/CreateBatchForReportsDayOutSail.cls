global class CreateBatchForReportsDayOutSail implements Schedulable{

    global CreateBatchForReportsDayOutSail() {}

    global void execute(SchedulableContext sc) {
        CreateBatchForReportsDayOutSail job = new CreateBatchForReportsDayOutSail();
        job.execute();
    }

    @future
    public static void futureExecution(){
        List<c2g__codaPeriod__c> periods = [Select Name, Id, Accounts_Receivable_CY__c, Accounts_Receivable_PY__c, Accounts_Receivable_Month__c,
                                                Total_Billed_Amount_Numbers_Old_PY__c, Total_Billed_Amount_Numbers_Old__c, Total_Billed_Amount_Month__c, Day_Sales_Outstanding_CY__c, Day_Sales_Outstanding_PY__c,
                                                c2g__StartDate__c, c2g__EndDate__c, c2g__YearName__r.Name
                                            From c2g__codaPeriod__c
                                            Where c2g__StartDate__c >: Date.today().addYears(-3) AND c2g__PeriodNumber__c != '000' AND
                                                c2g__PeriodNumber__c != '100' AND
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
system.debug('item'+item.Name);
            List<AggregateResult> trailings4_5 = [Select SUM(Total_Billed_Amount_Month__c) value4
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-1) AND c2g__StartDate__c >: date.newinstance( 2014, 6, 30 ) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000' AND
                                                    c2g__PeriodNumber__c != '100'];

            List<AggregateResult> trailings4_5Old = [Select SUM(Total_Billed_Amount_Month__c) value4
                                                From c2g__codaPeriod__c
                                                Where c2g__StartDate__c >: item.c2g__StartDate__c.addYears(-2) AND c2g__StartDate__c >: date.newinstance( 2014, 6, 30 ) AND
                                                    c2g__StartDate__c <: item.c2g__EndDate__c.addYears(-1) AND
                                                    c2g__PeriodNumber__c != '101' AND c2g__PeriodNumber__c != '000'AND
                                                    c2g__PeriodNumber__c != '100'];

system.debug('trailings4_5='+trailings4_5);
system.debug('trailings4_5Old='+trailings4_5Old);
            //Day Sales Outstanding
            Decimal total_Billed_Amount_Numbers_Old = 0;
            Decimal total_Billed_Amount_Numbers_Old_PY = 0;
            Decimal trailing12ProformaInvoiceTotalCY = ( (Decimal)trailings4_5[0].get('value4') != null ) ? (Decimal)trailings4_5[0].get('value4') : 0;
            Decimal trailing12ProformaInvoiceTotalPY = ( (Decimal)trailings4_5Old[0].get('value4') != null ) ? (Decimal)trailings4_5Old[0].get('value4') : 0;

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
            	 item.c2g__StartDate__c < date.newinstance(2015, 6, 1) &&
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

    //Execute method
    global void execute() {
        futureExecution();
    }

}