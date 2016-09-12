//MRS 6043
global without sharing class BillingLineItemServices {
    private static final String REIMBURSABLE_LINE_ITEM_DESCRIPTION                 = 'Document Shredding';
    private static final String REIMBURSABLE_LINE_ITEM_DESCRIPTION_MUNICIPAL       = 'Municipal Fees';
    private static final String REIMBURSABLE_LINE_ITEM_DESCRIPTION_MESSENGER       = 'Messenger Fees';
    private static final String REIMBURSABLE_BLI_NO_MET_DATA_SCANNING_PRODUCT_NAME = '20105 - A\\P Metropolitan Archives';
    private static final String REIMBURSABLE_BLI_NO_MET_DATA_SREDDING_PRODUCT_NAME = '41108 - Net Reimbursable Income:Other';
    private static final String REIMBURSABLE_BLI_NO_MET_DATA_SCANNING_DESCRIPTION  = 'Digital Asset Management - Document Scanning';

    private static final String BILLING_LINE_ITEM_INCOMPLETE = 'The task that triggered this billing line item has been changed back to an incomplete status. This invoice may have been sent in error. Please review and take the appropriate actions.';

    public static final String CONSULTING_INCOME_PRODUCT_NAME  = '40100 - Consulting Income';
    public static final String NON_BILLABLE_CONSULTING         = 'NON-BILLABLE CONSULTING ';
    public static final String MAILROOM_LINE_ITEM_PRODUCT_NAME = '41105 - Net Reimbursable Income:Messenger Fees';
    public static final String REIMBURSABLE_TYPE_SHREDDING     = 'Shredding';
    public static final String REIMBURSABLE_TYPE_SCANNING      = 'Scanning';
    public static final String REIMBURSABLE_TYPE_MAILROOM      = 'Mailroom';
    public static final String REIMBURSABLE_TYPE_MUNICIPAL     = 'Municipal';
    public static final String FEDEX_FILTER                    = 'FED EX';
    public static final String FEDEX_AIRBORNE_FILTER           = 'AIRBORNE'; // MRS 6707
    public static final String SUPREME_SYSTEMS_FILTER          = 'MESS';

    public static final String UNBILLED_PERCENTAGE = 'Unbilled Percentage';
    public static final String TOTAL_AMOUNT = 'Total Amount';
    public static final String BILLED_AMOUNT = 'Billed Amount';
    public static final String BILLED_TAX1_AMOUNT = 'Billed Tax1 Amount';
    public static final String BILLED_TAX2_AMOUNT = 'Billed Tax2 Amount';
    public static final String TOTAL_TAX1_AMOUNT = 'Total Tax1 Amount';
    public static final String TOTAL_TAX2_AMOUNT = 'Total Tax2 Amount';

    public static final String UNUSED_CONSULTING_HOURS_DESCRIPTION = 'Unused Consulting Hours';
    public static final String PREBILLED_HOURS_DESCRIPTION = 'Prebilled Hours';

    public static List<Billing_Line_Item__c> billingLineItemsToCreateInvoicesInReduBilling = new List<Billing_Line_Item__c>();

    public static void preventCheckHideFromRecap(List<Billing_Line_Item__c> newBLIList, Map<Id, Billing_Line_Item__c> oldBLIMap) { //MRS 7140
        Set<Id> idxSetAffectedInvoices = new Set<Id> ();
        List<Billing_Line_Item__c> updatedBlisToCheck = new List<Billing_Line_Item__c> ();
        for(Billing_Line_Item__c bli : newBLIList) {
            if(bli.Hide_from_Recap__c) {
                if(String.isBlank(bli.Pro_forma_Invoice__c)) {
                    bli.Hide_from_Recap__c = false;
                    bli.addError('Hide from Recap/PO can\'t be checked unless there is a Sales Invoice related to the PFI.'); // MRS 7256
                } else if(String.isEmpty(bli.Id) || !oldBLIMap.get(bli.Id).Hide_from_Recap__c) {
                    updatedBlisToCheck.add(bli);
                    idxSetAffectedInvoices.add(bli.Pro_forma_Invoice__c);
                }
            }
        }
        if(!idxSetAffectedInvoices.isEmpty()) {
            List<AggregateResult> ars = [SELECT cl_Pro_forma_Invoice__c, COUNT(Id)amount
                                          FROM c2g__codaInvoice__c
                                          WHERE cl_Pro_forma_Invoice__c IN :idxSetAffectedInvoices
                                          GROUP BY cl_Pro_forma_Invoice__c];
            Set<Id> idxProformaWithFFInvoiceSet = new Set<Id> ();
            for(AggregateResult ar : ars) if((Integer)ar.get('amount') > 0) idxProformaWithFFInvoiceSet.add((Id)ar.get('cl_Pro_forma_Invoice__c'));
            for(Billing_Line_Item__c bli : updatedBlisToCheck) if(!idxProformaWithFFInvoiceSet.contains(bli.Pro_forma_Invoice__c)) {
                bli.Hide_from_Recap__c = false;
                bli.addError('Hide from Recap/PO can\'t be checked unless there is a Sales Invoice related to the PFI.'); // MRS 7256
            }
        }
    }

    // MRS-6939
    public static Set<Id> filteredIdxOfPOsToUpdate( Map<Id, Billing_Line_Item__c> newBLIs, Map<Id, Billing_Line_Item__c> oldBLIs ) {
        Set<Id> res = new Set<Id> ();

        if(newBLIs != null) {
            for(Id idx : newBLIs.keySet()) {
                if(( oldBLIs == null || oldBLIs.get(idx) == null)) {
                    if(newBLIs.get(idx).Purchase_Order__c != null) res.add(newBLIs.get(idx).Purchase_Order__c);
                    continue;
                }
                if( newBLIs.get(idx).Amount__c != oldBLIs.get(idx).Amount__c
                    || newBLIs.get(idx).Pro_forma_Invoice__c != oldBLIs.get(idx).Pro_forma_Invoice__c
                    || newBLIs.get(idx).Purchase_Order__c != oldBLIs.get(idx).Purchase_Order__c
                    || newBLIs.get(idx).IsReimbursable__c != oldBLIs.get(idx).IsReimbursable__c
                    || newBLIs.get(idx).Billed__c != oldBLIs.get(idx).Billed__c
                    || newBLIs.get(idx).Hide_from_Recap__c != oldBLIs.get(idx).Hide_from_Recap__c) { // MRS 7140
                    if (newBLIs.get(idx).Purchase_Order__c != null) res.add(newBLIs.get(idx).Purchase_Order__c);
                    if (oldBLIs.get(idx).Purchase_Order__c != null) res.add(oldBLIs.get(idx).Purchase_Order__c);
                    continue;
                }
            }
        }
        if(oldBLIs != null) {
            for(Id idx : oldBLIs.keySet()) {
                if( newBLIs == null || !newBLIs.keySet().contains(idx) ) {
                    if( oldBLIs.get(idx).Purchase_Order__c != null ) {
                        res.add(oldBLIs.get(idx).Purchase_Order__c);
                    }
                }
            }
        }

        return res;
    }

    public static String buildQueryWhere(final String billingClientCompanyFilter, final String accountingContactCompanyFilter,
                                         final String projectNamberFilter, final String projectAddressFilter,
                                         final String billingMethod, final String serviceNameFilter,
                                         final String poFilter, final Boolean isReimbursables, final String reimbBillableType, final Boolean isScheduledFilter) {
        String queryWhere = '';

        if (!String.isBlank(projectNamberFilter)) {
            queryWhere = 'WHERE Project_Number__c LIKE \'%' + projectNamberFilter + '%\' ';

        }

        if (!String.isBlank(projectAddressFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Project_Address__r.Name LIKE \'%' + projectAddressFilter + '%\' ';

        }

        if (!String.isBlank(billingClientCompanyFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Billing_Client__r.Name LIKE \'%' + billingClientCompanyFilter + '%\' ';

        }

        if (!String.isBlank(accountingContactCompanyFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Accounting_Contact_Company__r.Name LIKE \'%' + accountingContactCompanyFilter + '%\' ';

        }

        if (!String.isBlank(serviceNameFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Service_Item__r.Service_Name_Full__c LIKE \'%' + serviceNameFilter + '%\' ';

        }

        if (!String.isBlank(poFilter)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Purchase_Order__r.Name LIKE \'%' + poFilter + '%\' ';

        }

        if (!String.isBlank(billingMethod)) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' Project_Profile__r.Billing_Method__c =\'' + billingMethod + '\' ';

        }

        queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND'; //MRS-6237
        queryWhere += ' Department_Based__c = false '; //MRS-6237

        queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
        queryWhere += ' Billed__c = false AND Active_Billing_Line_Item__c = true AND Superceded__c = false ';
        queryWhere += ' AND ( Requires_Check_Image__c = false OR Check_Image_Attached__c = true ) ';

        if (isReimbursables) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            queryWhere += ' isReimbursable__c = true ';

            if (!String.isBlank(reimbBillableType)) {
                queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
                queryWhere += ' Reimb_Billable_Type__c =\'' + reimbBillableType + '\' ';

            }

        }
        //MRS-6396
        if (isScheduledFilter){
            queryWhere += String.isBlank(queryWhere) ? 'WHERE' : 'AND';
            String dayOfWeek = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('EEEE');
            String dayOfMonth = String.valueOf (Date.today().day() );//DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('dd');

            queryWhere += ' ( NOT ( (Project_Profile__r.Frequency__c = \'' + ProjectProfileServices.FREQUENCY_WEEKLY + '\' AND Project_Profile__r.Billing_day__c != \'' + dayOfWeek + '\') OR';
            queryWhere += ' (Project_Profile__r.Frequency__c = \'' + ProjectProfileServices.FREQUENCY_MONTHLY + '\' AND Project_Profile__r.Billing_day__c != \'' + dayOfMonth + '\') ) ) ';
        }
        return queryWhere;

    }

    public static String buildQuery(final String queryWhere, final String sortBy) {
        return  'SELECT Id, Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Project_Address__r.Name, Project_Address__c, Billing_Client__r.Name, Purchase_Order__r.Override_Billing_Restrictions__c, '+ /*MRS 7156 */
                        'Billing_Client__c, Accounting_Contact__c, Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name, Project_Profile__r.Billing_Method__c, Project_Profile__r.Pre_billed__c, '+
                        'Unit_Price__c, Quantity__c, Milestone_Date__c, Purchase_Order__r.Purchase_Order__c, Purchase_Order__c, Reimb_Billable_Type__c, Service_Item__r.Service_Name_Full__c, Purchase_Order__r.Purchase_Order_Number__c, '+
                        'Service_Name__c, Service_Item__c, Service_Item__r.Name, Service_Item__r.Phase__c, Phase__c, Project_Profile__r.Billing_Day__c, Project_Profile__r.Floor_s__c, Amount__c, Superceded__c, '+
                        'Project_Profile__r.Special_Instructions_Long__c, Project_Profile__r.Account_Executive__c, Project_Profile__r.Frequency__c, Project_Profile__r.Quarterly_Month__c, Purchase_Order__r.Name, '+
                        'Billing_Contact__c, Client_Contact__c, Pro_forma_Invoice__c, Phase__r.Name__c, Project_Profile__r.Total_Service_Amount__c, Project_Profile__r.Client_Project__c, Project_Profile__r.PO_Required__c, Project_Profile__r.PO_Not_Required__c,' +
                        'Project_Profile__r.Invoice_Format__c, Service_Category__c, Service_Filling_Status__c, Project_Profile_No_Document_Shredding__c, Service_Type__c, Municipal_Agency_ID__c, Project_Profile__r.Discounted_Total_Service_Amount__c, ' +
                        'Project_Profile__r.Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Billing_Company_Name__c, Pro_forma_Invoice__r.Project_Profile__c, ' +
                        'Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Project_Profile__r.Interval__c, Sales_Tax_Amount__c, Is_Check_Processing_Fee__c,' +
                        'CreatedDate, Project_Profile__r.No_Met_Data_Scanning__c, Project_Profile__r.Separate_Phases__c, Project_Profile__r.Separate_Reimbursables__c, isReimbursable__c, isReimbursableOnProjectLevel__c, Service_Shredding_Fee__c, Hide_From_Recap__c ' + /*MRS 7550*/
                'FROM Billing_Line_Item__c '+ queryWhere +' ORDER BY '+ sortBy +' LIMIT ' + Label.buildQueryLimit;

    }

    public static String buildQueryForBatch(final String queryWhere) {

        return  'SELECT Id, Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Project_Address__r.Name, Project_Address__c, Billing_Client__r.Name, Purchase_Order__r.Override_Billing_Restrictions__c, '+ /*MRS 7156 */
                        'Billing_Client__c, Accounting_Contact__c, Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name, Project_Profile__r.Billing_Method__c, Project_Profile__r.Pre_billed__c, '+
                        'Unit_Price__c, Quantity__c, Milestone_Date__c, Purchase_Order__r.Purchase_Order__c, Purchase_Order__c, Reimb_Billable_Type__c, Service_Item__r.Service_Name_Full__c, Purchase_Order__r.Purchase_Order_Number__c, '+
                        'Service_Name__c, Service_Item__c, Service_Item__r.Name, Service_Item__r.Phase__c, Phase__c, Project_Profile__r.Billing_Day__c, Project_Profile__r.Floor_s__c, Amount__c, Superceded__c, '+
                        'Project_Profile__r.Special_Instructions_Long__c, Project_Profile__r.Account_Executive__c, Project_Profile__r.Frequency__c, Project_Profile__r.Quarterly_Month__c, Purchase_Order__r.Name, '+
                        'Billing_Contact__c, Client_Contact__c, Pro_forma_Invoice__c, Phase__r.Name__c, Project_Profile__r.Total_Service_Amount__c, Project_Profile__r.Client_Project__c, Project_Profile__r.PO_Required__c, Project_Profile__r.PO_Not_Required__c,'+
                        'Project_Profile__r.Invoice_Format__c, Service_Category__c, Service_Filling_Status__c, Project_Profile_No_Document_Shredding__c, Service_Type__c, Municipal_Agency_ID__c, Project_Profile__r.Discounted_Total_Service_Amount__c, ' +
                        'Project_Profile__r.Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Billing_Company_Name__c, Pro_forma_Invoice__r.Project_Profile__c, ' +
                        'Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Project_Profile__r.Interval__c, Sales_Tax_Amount__c, Is_Check_Processing_Fee__c,' +
                        'CreatedDate, Project_Profile__r.No_Met_Data_Scanning__c, Project_Profile__r.Separate_Phases__c, Project_Profile__r.Separate_Reimbursables__c, isReimbursable__c, isReimbursableOnProjectLevel__c, Service_Shredding_Fee__c, Hide_From_Recap__c ' + /*MRS 7550*/
                'FROM Billing_Line_Item__c '+ queryWhere + 'AND (NOT( Project_Profile__r.PO_Required__c = true AND Purchase_Order__c = null)) AND Reimb_Billable_Type__c != \'' + 'Pre-paid' + '\' ORDER BY CreatedDate DESC limit ' + Label.buildQueryForBatchLimit;

    }

    public static List<Billing_Line_Item__c> bliForBatchList(List<Project_Profile__c> projectProfileList, Boolean isDailyBillingJob ) {
        if ( projectProfileList == null || projectProfileList.isEmpty() ){ return new List<Billing_Line_Item__c>(); }

        List<Billing_Line_Item__c> filteredBLIs = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c item: [SELECT Id, Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Project_Address__r.Name, Project_Profile__r.Discounted_Total_Service_Amount__c,
                                                Project_Address__c, Billing_Client__r.Name, Billing_Client__c, Accounting_Contact__c, Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name, Purchase_Order__r.Override_Billing_Restrictions__c, // MRS 7156
                                                Project_Profile__r.Billing_Method__c, Project_Profile__r.Pre_billed__c, Unit_Price__c, Quantity__c, Milestone_Date__c, Purchase_Order__r.Purchase_Order__c,
                                                Purchase_Order__c, Reimb_Billable_Type__c, Service_Item__r.Service_Name_Full__c, Purchase_Order__r.Purchase_Order_Number__c, Service_Name__c, Service_Item__c,
                                                Service_Item__r.Name, Service_Item__r.Phase__c, Phase__c, Project_Profile__r.Billing_Day__c, Project_Profile__r.Floor_s__c, Amount__c, Superceded__c,
                                                Project_Profile__r.Special_Instructions_Long__c, Project_Profile__r.Account_Executive__c, Project_Profile__r.Frequency__c, Project_Profile__r.PO_Not_Required__c,
                                                Project_Profile__r.Quarterly_Month__c, Purchase_Order__r.Name, Billing_Contact__c, Client_Contact__c, Pro_forma_Invoice__c, Phase__r.Name__c,
                                                Project_Profile__r.Total_Service_Amount__c, Project_Profile__r.Client_Project__c, Project_Profile__r.PO_Required__c, Project_Profile__r.Invoice_Format__c,
                                                Service_Category__c, Service_Filling_Status__c, Project_Profile_No_Document_Shredding__c, Service_Type__c, Municipal_Agency_ID__c,Project_Profile__r.Accounting_Contact_Company__c,
                                                Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Billing_Company_Name__c, Pro_forma_Invoice__r.Project_Profile__c, Project_Profile__r.Billing_Company_Contact__c,
                                                Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Project_Profile__r.Interval__c, Sales_Tax_Amount__c, CreatedDate,
                                                Project_Profile__r.No_Met_Data_Scanning__c, Project_Profile__r.Separate_Phases__c, Project_Profile__r.Separate_Reimbursables__c, isReimbursable__c,
                                                isReimbursableOnProjectLevel__c, Service_Shredding_Fee__c, Is_Check_Processing_Fee__c, Hide_from_Recap__c /*MRS 7550*/
                                        FROM Billing_Line_Item__c
                                        WHERE Billed__c = false AND
                                                Project_Profile__c IN : projectProfileList AND
                                                Quantity__c != null AND
                                                Quantity__c > 0 AND
                                                Department_Based__c = false AND
                                                Active_Billing_Line_Item__c = true AND
                                                Superceded__c = false AND
                                                ( Requires_Check_Image__c = false OR Check_Image_Attached__c = true ) /*AND
                                                ( ( NOT ( Project_Profile__r.PO_Required__c = true AND Purchase_Order__c = null ) ) OR
                                                      ( Project_Profile__r.PO_Not_Required__c = true AND isReimbursable__c = true ) )*/ AND
                                                Reimb_Billable_Type__c != 'Pre-paid']){

            if( isDailyBillingJob ){
                if( item.Project_Profile__r.Frequency__c == ProjectProfileServices.FREQUENCY_MONTHLY ){
                        Integer billingDayNumber = Integer.valueOf( item.Project_Profile__r.Billing_Day__c );

                        if( billingDayNumber == Date.today().day() || ( Date.today().addDays(1).month() != Date.today().month() && billingDayNumber >= Date.today().day() ) ){
                            filteredBLIs.add( item );
                        }
                    }else if( item.Project_Profile__r.Frequency__c == ProjectProfileServices.FREQUENCY_WEEKLY ){
                        Integer billingDateNumber = DateUtils.WEEK_DAY_NUMBER_MAP.get( item.Project_Profile__r.Billing_Day__c );
                        Integer currentDateNumber = DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('EEEE') );

                        if( billingDateNumber == currentDateNumber ){
                            filteredBLIs.add( item );
                        }
                    }else if( item.Project_Profile__r.Frequency__c == ProjectProfileServices.FREQUENCY_QUARTERLY  ) {
                        Integer billingDayNumber = Integer.valueOf( item.Project_Profile__r.Billing_Day__c );
                        Integer monthInQuarted = 0;

                        if( item.Project_Profile__r.Quarterly_Month__c.equals( '1st' ) || item.Project_Profile__r.Quarterly_Month__c == null ) monthInQuarted = 1;
                            else if( item.Project_Profile__r.Quarterly_Month__c.equals( '2nd' ) ) monthInQuarted = 2;
                            else if( item.Project_Profile__r.Quarterly_Month__c.equals( '3rd' ) ) monthInQuarted = 3;

                        Date startDate = DateUtils.getDateStart( Date.today(), ProjectProfileServices.FREQUENCY_QUARTERLY, monthInQuarted ).addDays( billingDayNumber );

                        if( monthInQuarted == DateUtils.getQuarterNumber( Date.today() ) &&
                            ( billingDayNumber == Date.today().day() || ( Date.today().addDays(1).month() != Date.today().month() && billingDayNumber >= Date.today().day() ) ) ){

                            filteredBLIs.add( item );
                        }
                    }
            }else{
                if( item.Project_Profile__r.Frequency__c == null ){
                    filteredBLIs.add( item );
                }else{
                    if( item.Project_Profile__r.Frequency__c == ProjectProfileServices.FREQUENCY_MONTHLY ){
                        Integer billingDayNumber = Integer.valueOf( item.Project_Profile__r.Billing_Day__c );
                        Date startDate = DateUtils.getDateStart( Date.today(), ProjectProfileServices.FREQUENCY_MONTHLY, 0 ).addDays( math.min( billingDayNumber ,date.daysInMonth(Date.today().year(), Date.today().month()) ) );

                        if( ( item.CreatedDate < startDate && startDate.addDays(-1) <= Date.today() )
                                || item.CreatedDate.addMonths(1) <= Date.today()
                                || ( item.CreatedDate.Day() <= billingDayNumber && Date.newInstance(item.CreatedDate.year(), item.CreatedDate.month(), billingDayNumber) <= Date.today() ) ){

                            filteredBLIs.add( item );
                        }
                    }else if( item.Project_Profile__r.Frequency__c == ProjectProfileServices.FREQUENCY_WEEKLY ){
                        Integer billingDateNumber = DateUtils.WEEK_DAY_NUMBER_MAP.get( item.Project_Profile__r.Billing_Day__c );
                        Integer creatingDateNumber = DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(Date.newInstance( item.CreatedDate.year(), item.CreatedDate.month(), item.CreatedDate.day() ), Time.newInstance(0, 0, 0, 0)).format('EEEE') );
                        Integer currentDateNumber = DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('EEEE') );

                        if( item.CreatedDate.addDays(7) <= Date.today()
                            || ( creatingDateNumber <= billingDateNumber && billingDateNumber <= currentDateNumber )
                            || billingDateNumber == currentDateNumber ){

                            filteredBLIs.add( item );
                        }
                    }else if( item.Project_Profile__r.Frequency__c.equals(ProjectProfileServices.FREQUENCY_QUARTERLY)) {
                        Integer billingDayNumber = Integer.valueOf( item.Project_Profile__r.Billing_Day__c );
                        Integer monthInQuarted = 0;

                        if( item.Project_Profile__r.Quarterly_Month__c.equals( '1st' ) || item.Project_Profile__r.Quarterly_Month__c == null ) monthInQuarted = 1;
                            else if( item.Project_Profile__r.Quarterly_Month__c.equals( '2nd' ) ) monthInQuarted = 2;
                            else if( item.Project_Profile__r.Quarterly_Month__c.equals( '3rd' ) ) monthInQuarted = 3;

                        Date startDate = DateUtils.getDateStart( Date.today(), ProjectProfileServices.FREQUENCY_QUARTERLY, monthInQuarted ).addDays( math.min( billingDayNumber ,date.daysInMonth(Date.today().year(), Date.today().month())) );

                        if( ( item.CreatedDate < startDate && startDate.addDays(-1) <= Date.today() ) || item.CreatedDate.addMonths(3) <= Date.today() ){
                            filteredBLIs.add( item );
                        }
                    }
                }
            }
        }
        return filteredBLIs;
    }

    public static Map<Id, Set<Id>> filterBillingLineItemTotalAmountForProformaInvoice( List<Billing_Line_Item__c> newBillingLineItemList, Map<Id, Billing_Line_Item__c> oldBillingLineItemMap ) {
        Map<Id, Set<Id>> billinLineItemToProFormaMap = new Map<Id, Set<Id>>();
        for(Billing_Line_Item__c newBli : newBillingLineItemList) {
            if( newBli.Superceded__c ) continue;
            if(oldBillingLineItemMap == null) {
                if(newBli.Pro_forma_Invoice__c != null && newBli.Amount__c > 0) {
                    if (newBli.Pro_forma_Invoice__c != null){
                        if (!billinLineItemToProFormaMap.containsKey(newBli.Pro_forma_Invoice__c)){
                            billinLineItemToProFormaMap.put( newBli.Pro_forma_Invoice__c, new Set<Id>() );
                        }
                        billinLineItemToProFormaMap.get( newBli.Pro_forma_Invoice__c).add(newBli.Id);
                    }
                }
            } else {
                Id oldProFormaInvoiceId = oldBillingLineItemMap.get(newBli.Id).Pro_forma_Invoice__c;
                if( ( newBli.Pro_forma_Invoice__c != oldProFormaInvoiceId ) || (newBli.Amount__c != oldBillingLineItemMap.get(newBli.Id).Amount__c) ||
                    (newBli.cl_Credit_1_Amount__c != oldBillingLineItemMap.get(newBli.Id).cl_Credit_1_Amount__c) ||
                    (newBli.cl_Credit_2_Amount__c != oldBillingLineItemMap.get(newBli.Id).cl_Credit_2_Amount__c) ) {

                    if (newBli.Pro_forma_Invoice__c != null){
                        if (!billinLineItemToProFormaMap.containsKey(newBli.Pro_forma_Invoice__c)){
                            billinLineItemToProFormaMap.put( newBli.Pro_forma_Invoice__c, new Set<Id>() );
                        }
                        billinLineItemToProFormaMap.get( newBli.Pro_forma_Invoice__c).add(newBli.Id);
                    }
                    if (oldProFormaInvoiceId != null){
                        if (!billinLineItemToProFormaMap.containsKey(oldProFormaInvoiceId)){
                            billinLineItemToProFormaMap.put( oldProFormaInvoiceId, new Set<Id>() );
                        }
                        billinLineItemToProFormaMap.get( oldProFormaInvoiceId ).add(newBli.Id);
                    }
                }
            }
        }
        return billinLineItemToProFormaMap;
    }

    public static List<Billing_Line_Item__c> filteredBLIWithChangedProjectPoOrAmounts(List<Billing_Line_Item__c> newList, Map<Id, Billing_Line_Item__c> oldMap){
        if( oldMap == null ) return newList;

        List<Billing_Line_Item__c> filteredBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Billing_Line_Item__c billingLineItem : newList){
            if( billingLineItem.Project_Profile__c == null ){
                continue;
            }
            if (billingLineItem.Project_Profile__c != oldMap.get(billingLineItem.Id).Project_Profile__c ||
                ( billingLineItem.Purchase_Order__c != oldMap.get(billingLineItem.Id).Purchase_Order__c && oldMap.get(billingLineItem.Id).Purchase_Order__c != null ) ){
                if ( billingLineItem.Pro_forma_Invoice__c != null && oldMap.get(billingLineItem.Id).Pro_forma_Invoice__c != null ){
                    billingLineItem.addError('You can not update Project or Purchase Order on Billing Line Item if Pro-forma Invoice is populated');
                }
                filteredBillingLineItemList.add(billingLineItem);
            }
        }
        return filteredBillingLineItemList;
    }

    public static void populateBLIWithProjectData(Billing_Line_Item__c lineItem, Project_Profile__c project) {
        lineItem.Project_Profile__c            = project.Id;
        lineItem.Accounting_Contact_Company__c = project.Accounting_Contact_Company__c;
        lineItem.Accounting_Contact__c         = project.Accounting_Contact__c;
        lineItem.Billing_Client__c             = project.Billing_Company_Name__c;
        lineItem.Billing_Contact__c            = project.Billing_Company_Contact__c;
        lineItem.Billing_Method__c             = project.Billing_Method__c;
        lineItem.Client_Contact__c             = project.Primary_Company_Contact__c;
        lineItem.Project_Address__c            = project.Building__c;

    }

    public static Billing_Line_Item__c newReimbursableLineItem( Task_Item__c taskItem, Service_Item__c serviceItem, Project_Profile__c projectProfile,
                                                                Billing_Date__c billingDate, String productName, String description, String rtype ) {
        Billing_Line_Item__c reimbursableLineItem = new Billing_Line_Item__c();
        reimbursableLineItem.Is_Manualy_Created__c = false;

        reimbursableLineItem = initBillingLineItem( null, taskItem, serviceItem, projectProfile, billingDate );
        reimbursableLineItem.isReimbursable__c = true;

        reimbursableLineItem.Product_Name__c = productName;
        reimbursableLineItem.Description__c =  Description;
        reimbursableLineItem.Milestone_Date__c = Date.today();
        reimbursableLineItem.Reimbursable_Type__c = rtype;
        reimbursableLineItem.Service_Item__c = null;
        //'Related Service Item' MRS-3743
        if( serviceItem != null ) {
            reimbursableLineItem.Related_Service_Item__c = serviceItem.Id;
            reimbursableLineItem.Phase__c = serviceItem.Phase__c;
        }

        return reimbursableLineItem;
    }

    public static Billing_Line_Item__c newReimbursableLineItemShredding( Service_Item__c serviceItem, Project_Profile__c projectProfile ) {
        Billing_Line_Item__c reimbursableLineItem = newReimbursableLineItem( null, serviceItem, projectProfile,
                                                                             null, REIMBURSABLE_BLI_NO_MET_DATA_SREDDING_PRODUCT_NAME,
                                                                             REIMBURSABLE_LINE_ITEM_DESCRIPTION, REIMBURSABLE_TYPE_SHREDDING );

        Decimal unitPrice = ( serviceItem != null ? serviceItem.Shredding_Fees__c : 0);

        reimbursableLineItem.Unit_Price__c = ( projectProfile.Reimbursable2__c != null && projectProfile.Reimbursable2__c > 0 ) ? projectProfile.Reimbursable2__c : unitPrice;
        reimbursableLineItem.Pre_billed__c = projectProfile.Pre_billed__c;
        reimbursableLineItem.Quantity__c = 1;
        reimbursableLineItem.Amount__c = reimbursableLineItem.Quantity__c * reimbursableLineItem.Unit_Price__c;
        reimbursableLineItem.Milestone_Date__c = ( serviceItem != null ? ProformaInvoiceServices.projectIdToInvoiceCutoffDateMap.get( projectProfile.Id ) : Date.today() );

        return reimbursableLineItem ;
    }

    public static Billing_Line_Item__c newReimbursableLineItemMunicipal( Project_Profile__c projectProfile ) {
        Billing_Line_Item__c reimbursableLineItem = newReimbursableLineItem( null, null, projectProfile,
                                                                             null, REIMBURSABLE_BLI_NO_MET_DATA_SREDDING_PRODUCT_NAME,
                                                                             REIMBURSABLE_LINE_ITEM_DESCRIPTION_MUNICIPAL, REIMBURSABLE_LINE_ITEM_DESCRIPTION_MUNICIPAL );
        reimbursableLineItem.Unit_Price__c = ( projectProfile.Reimbursable3__c != null && projectProfile.Reimbursable3__c > 0 ) ? projectProfile.Reimbursable3__c : 25;
        reimbursableLineItem.Pre_billed__c = projectProfile.Pre_billed__c;
        reimbursableLineItem.Quantity__c = 1;
        reimbursableLineItem.Amount__c = reimbursableLineItem.Quantity__c * reimbursableLineItem.Unit_Price__c;

        return reimbursableLineItem ;
    }

    public static Billing_Line_Item__c newReimbursableLineItemMessenger( Project_Profile__c projectProfile ) {
        Billing_Line_Item__c reimbursableLineItem = newReimbursableLineItem( null, null, projectProfile,
                                                                             null, REIMBURSABLE_BLI_NO_MET_DATA_SREDDING_PRODUCT_NAME,
                                                                             REIMBURSABLE_LINE_ITEM_DESCRIPTION_MESSENGER, REIMBURSABLE_LINE_ITEM_DESCRIPTION_MESSENGER );
        reimbursableLineItem.Unit_Price__c = ( projectProfile.Reimbursable4__c != null && projectProfile.Reimbursable4__c > 0 ) ? projectProfile.Reimbursable4__c : 25;
        reimbursableLineItem.Pre_billed__c = projectProfile.Pre_billed__c;
        reimbursableLineItem.Quantity__c = 1;
        reimbursableLineItem.Amount__c = reimbursableLineItem.Quantity__c * reimbursableLineItem.Unit_Price__c;

        return reimbursableLineItem ;
    }

    public static Billing_Line_Item__c newReimbursableLineItemScanning ( Task_Item__c taskItem, Service_Item__c serviceItem, Project_Profile__c projectProfile, Billing_Date__c billingDate ) {
        Billing_Line_Item__c reimbursableLineItem = newReimbursableLineItem( taskItem, serviceItem, projectProfile,
                                                                            billingDate, REIMBURSABLE_BLI_NO_MET_DATA_SCANNING_PRODUCT_NAME,
                                                                            REIMBURSABLE_BLI_NO_MET_DATA_SCANNING_DESCRIPTION, REIMBURSABLE_TYPE_SCANNING );
        Decimal unitPrice = 0;
        if(taskItem != null) {
            unitPrice = taskItem.Met_Data_Scanning_Fee__c;
        } else if(serviceItem != null) {
            unitPrice = serviceItem.Met_Data_Scanning_Fee__c;
        }
        reimbursableLineItem.Unit_Price__c = ( projectProfile.Reimbursable1__c != null && projectProfile.Reimbursable1__c > 0 ) ? projectProfile.Reimbursable1__c : unitPrice;
        reimbursableLineItem.Pre_billed__c = projectProfile.Pre_billed__c;
        reimbursableLineItem.Quantity__c = 1;
        reimbursableLineItem.Amount__c = reimbursableLineItem.Quantity__c * reimbursableLineItem.Unit_Price__c;

        return reimbursableLineItem ;
    }

    public static void populateReimbursableLineItemsPurchaseOrder( List<Billing_Line_Item__c> lineItems, List<Purchase_Order__c> purchaseOrders ){
        for( Billing_Line_Item__c bli: lineItems ){
            bli.Purchase_Order__c = getPurchaseOrderForReimbursableLineItem( purchaseOrders, bli, null );
        }
    }

    public static void populatePOForHiddenBLIs( List<Billing_Line_Item__c> lineItems ){
        Map<Id, Id> idOfMainBLIToPOid = new Map<Id, Id>();
        for( Billing_Line_Item__c bli: lineItems ){
            if( bli.Department_Based__c && bli.Main_Billing_Line_Item__c != null ) idOfMainBLIToPOid.put( bli.Main_Billing_Line_Item__c, null );
        }

        if( !idOfMainBLIToPOid.isEmpty() ){
            for( Billing_Line_Item__c item: [Select Id, Purchase_Order__c From Billing_Line_Item__c Where Id IN: idOfMainBLIToPOid.keySet() ] ){
                idOfMainBLIToPOid.put( item.Id, item.Purchase_Order__c );
            }
        }

        for( Billing_Line_Item__c bli: lineItems ){
            if( bli.Department_Based__c && bli.Main_Billing_Line_Item__c != null ) bli.Purchase_Order__c = idOfMainBLIToPOid.get( bli.Main_Billing_Line_Item__c );
        }

    }

    public static void setBillingLineItemIsActive(List<Billing_Line_Item__c> newList) { //MRS 7459
        for(Billing_Line_Item__c bli : newList) {
            if(bli.Amount__c == null || bli.Amount__c == 0) bli.Active_Billing_Line_Item__c = false;
        }
    }

    public static Billing_Line_Item__c initBillingLineItem( Mailroom__c mailroomItem, Task_Item__c taskItem, Service_Item__c serviceItem,
                                                            Project_Profile__c projectProfile, Billing_Date__c billingDate ) {
        Billing_Line_Item__c billingLineItem = new Billing_Line_Item__c();
        billingLineItem.Is_Manualy_Created__c = false;

        //from Mail Room
        if (null != mailroomItem) {
            billingLineItem.Project_Profile__c = mailroomItem.Project_Profile__c;
            if( mailroomItem.Date_created__c != null ){
                billingLineItem.Milestone_Date__c = Date.newinstance(mailroomItem.Date_created__c.year(), mailroomItem.Date_created__c.month(), mailroomItem.Date_created__c.day());
            }
            billingLineItem.Mailroom__c  = mailroomItem.Id;
            billingLineItem.Description__c = mailroomItem.Description__c;

        }

        //from Task Item
        if( taskItem != null ) {
            if( taskItem.Actual_End_Date__c != null ) {
                billingLineItem.Milestone_Date__c = Date.newInstance( taskItem.Actual_End_Date__c.year(),
                                                                      taskItem.Actual_End_Date__c.month(),
                                                                      taskItem.Actual_End_Date__c.day() );
            }
            billingLineItem.Project_Profile__c = taskItem.Project_Profile__c;
            billingLineItem.Service_Item__c = taskItem.Service_Item__c;
            billingLineItem.Task_Item__c = taskItem.Id;
        }

        // from Project Profile
        if( projectProfile != null ) {
            populateBLIWithProjectData( billingLineItem, projectProfile );
        }

        // from Service Item
        if( serviceItem != null ) {
            //billingLineItem.Purchase_Order__c = serviceItem.Purchase_Order__c;
            billingLineItem.Service_Name__c = serviceItem.Service_Name_Full__c;
            billingLineItem.Description__c = serviceItem.Description__c;
            billingLineItem.Phase__c = serviceItem.Phase__c;
            if (Schema.sObjectType.Product2.isAccessible()) {
                billingLineItem.Product_Name__c =  serviceItem.GLA_Product__r.Name;
            }
        } else {
            billingLineItem.Product_Name__c = CONSULTING_INCOME_PRODUCT_NAME;
        }

        //from Billing Date
        if( billingDate != null ) {
            billingLineItem.Milestone_Date__c = billingDate.Processing_Day__c;
            billingLineItem.Project_Profile__c = billingDate.Project_Profile__c;
            billingLineItem.Billing_Date_Step_Number__c = billingDate.Step_Number__c;
        }
        return billingLineItem;
    }



    public static Id getPurchaseOrderForMailroomLimeItem ( List<Purchase_Order__c> purchaseOrders, Id projectId, Billing_Line_Item__c bli ) {
        Set<Id> sutablePurchaseOrdersId = new Set<Id>();

        for (Purchase_Order__c purchaseOrder : purchaseOrders ) {
            if( purchaseOrder.Project_Profile__c == projectId &&
                isPOValidForBliAssignment( bli, purchaseOrder, true ) ) {
                //MRS-5940
                if( !purchaseOrder.Covered_Services__r.isEmpty() ){
                    purchaseOrder.Purchase_Order_Amount__c -= bli.Amount__c;
                    return purchaseOrder.Id;
                }else{
                    sutablePurchaseOrdersId.add(purchaseOrder.Id);
                }

            }
        }

        if( !sutablePurchaseOrdersId.isEmpty() ){
            List<Id> purchaseOrdersIdList = new List<Id>(sutablePurchaseOrdersId);
            Map<Id, Purchase_Order__c> purchaseOrderMap = new Map<Id, Purchase_Order__c>(purchaseOrders);
            purchaseOrderMap.get(purchaseOrdersIdList[0]).Purchase_Order_Amount__c -= bli.Amount__c;
            return purchaseOrdersIdList[0];
        }

        return null;
    }



    public static List<Billing_Line_Item__c> getBillingLineItemListForTaskItemId(Id taskItemId) {
        return [ SELECT Task_Item__c, Quantity__c, Milestone_Date__c, Name, Id, Description__c, Billing_Date__c, Owner.FirstName, Owner.LastName
                 FROM Billing_Line_Item__c
                 WHERE Task_Item__c = :taskItemId
                 ORDER BY Milestone_Date__c DESC, CreatedDate DESC LIMIT 1000 ];
    }

    public static List<Billing_Line_Item__c> getBillingLineItemByInvoiceId(Id invoiceId) {
        if (String.isBlank(invoiceId)) {
            throw new ErrorException(ErrorException.INVOICE_ID_EMPTY);

        }

        return new List<Billing_Line_Item__c>([SELECT Name, Unit_Price__c, Quantity__c, Amount__c, Id, Pro_forma_Invoice__c, Reimbursable_Type__c,
                                                      Service_Item__c, Service_Item__r.Service_Name_Full__c, Milestone_Date__c, Related_Service_Item__c
                                               FROM Billing_Line_Item__c
                                               WHERE Pro_forma_Invoice__c =: invoiceId]);


    }

    public static List<Billing_Line_Item__c> getBillingLineItemForMilstone( Set<Id> serviceItemIds ) {
        return new List<Billing_Line_Item__c>( [ SELECT Name, Unit_Price__c, Quantity__c, Amount__c, Id, Task_Item__c, isReimbursable__c,
                                                       Service_Item__c, Service_Item__r.Service_Name_Full__c, Milestone_Date__c, Pro_forma_Invoice__c, Superceded__c
                                                 FROM Billing_Line_Item__c
                                                 WHERE Pro_forma_Invoice__c = null
                                                       AND Service_Item__c IN: serviceItemIds
                                                       AND isReimbursable__c = false
                                                       AND Project_Profile__r.Billing_Method__c =: ProjectProfileServices.BILLINGMETHODMILESTONE
                                                       AND Superceded__c =: false ] );
    }

    public static List<Billing_Line_Item__c> getBillingLineItemWithProformaInvoice( Set<Id> serviceItemIds ) {
        return new List<Billing_Line_Item__c>( [ SELECT Name, Unit_Price__c, Quantity__c, Amount__c, Id, Task_Item__c, isReimbursable__c, Reimbursable_Type__c, Related_Service_Item__c,
                                                       Service_Item__c, Service_Item__r.Service_Name_Full__c, Milestone_Date__c, Pro_forma_Invoice__c, Superceded__c
                                                 FROM Billing_Line_Item__c
                                                 WHERE Pro_forma_Invoice__c != null
                                                       AND ( Service_Item__c IN: serviceItemIds
                                     OR Related_Service_Item__c IN: serviceItemIds ) ] );
    }

    public static Billing_Line_Item__c getBLIForMilstone(List<Billing_Line_Item__c> blis, Id taskItemId, Id serviceItemId) {
        for (Billing_Line_Item__c bli : blis) {
            if (bli.Service_Item__c == serviceItemId) {
                return bli;
            }

        }
        return null;

    }

    @TestVisible
    private static Map<Id, Project_Profile__c> getProjectProfileByMailroomItems(List<Mailroom__c> mailroomList) {

        if (null == mailroomList || mailroomList.isEmpty()) {
            return new Map<Id, Project_Profile__c>();

        }

        Set<Id> ppIds = new Set<Id>();

        //Get Project_Profile__c Ids
        for (Mailroom__c mailroomItem : mailroomList){
            if (!ppIds.contains(mailroomItem.Project_Profile__c)) {
                ppIds.add(mailroomItem.Project_Profile__c);

            }
        }

        return ProjectProfileServices.getProgectProfileMap(ppIds);
    }

    public static void generateBillingLineItemsForMailroomTrigger(Map<Id, Mailroom__c> mailroomMap) {
        List<Billing_Line_Item__c> billingLineItems = new List<Billing_Line_Item__c>();
        Map<Id, Project_Profile__c> projectProfileMap = getProjectProfileByMailroomItems( mailroomMap.values() );
        //List<Purchase_Order__c> purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems( projectProfileMap.keySet() );

        for (Mailroom__c mailroomItem : mailroomMap.values() ) {
            Project_Profile__c projectProfile = projectProfileMap.get( mailroomItem.Project_Profile__c );
            if (null != projectProfile && !projectProfile.No_Messenger_Fedex__c) {//MRS-6668 !projectProfile.Pre_billed__c condition
                Billing_Line_Item__c billingLineItem = initBillingLineItem( mailroomItem, null, null, projectProfile, null );
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Quantity__c = 1;
                billingLineItem.Unit_Price__c = mailroomItem.Price__c;
                billingLineItem.Product_Name__c = MAILROOM_LINE_ITEM_PRODUCT_NAME;
                billingLineItem.Description__c = mailroomItem.Description__c;
                billingLineItem.Amount__c = mailroomItem.Price__c;
                //billingLineItem.Purchase_Order__c = getPurchaseOrderForMailroomLimeItem( purchaseOrders, mailroomItem.Project_Profile__c, billingLineItem );
                billingLineItem.Reimbursable_Type__c = REIMBURSABLE_TYPE_MAILROOM;
                billingLineItems.add(billingLineItem);

            }
        }
        if( !billingLineItems.isEmpty() ){
            try {
                insert billingLineItems;
            } catch( DMLException dmlEx ){
                for( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    mailroomMap.get(billingLineItems[dmlEx.getDmlIndex(i)].Mailroom__c).addError('Error Occured While Inserting Billing Line Items: ' + dmlEx.getMessage());
                }
            }
        }
    }

    public static void populatePurchaseOrderOnBLIs( List<Billing_Line_Item__c> lineItems, List<Purchase_Order__c> purchaseOrders ) {
        if( lineItems.isEmpty() || purchaseOrders.isEmpty() ) return;

        Map<Id, Id> sliIdToPoIdMap = new Map<Id, Id> ();
        Map<Id, Decimal> poIdToUnallocatedBalanceMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> poIdToReimbursablesBalanceMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> poIdToMaxServicesBillingTotalDiscBalanceBillingBalanceMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> poIdToServicesBalanceMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> poIdToMunicipalFeesBalanceMap = new Map<Id, Decimal> ();
        Map<Id, Decimal> poIdToUnallocatedBalanceWIthoutServiceAmountMap = new Map<Id, Decimal> ();
        Map<Id, List<Purchase_Order__c>> projectIdToListOfPurchaseOrders = new Map<Id, List<Purchase_Order__c>> ();

        for( Purchase_Order__c pO : purchaseOrders ) {
            for( Service_Item__c sli : pO.Covered_Services__r ) {
                sliIdToPoIdMap.put( sli.Id, pO.Id );
            }
            if( projectIdToListOfPurchaseOrders.get( pO.Project_Profile__c ) == null ) projectIdToListOfPurchaseOrders.put( pO.Project_Profile__c, new List<Purchase_Order__c> () );
            projectIdToListOfPurchaseOrders.get( pO.Project_Profile__c ).add( pO );

            poIdToUnallocatedBalanceMap.put( pO.Id, pO.Unallocated_Balance__c );
            poIdToMaxServicesBillingTotalDiscBalanceBillingBalanceMap.put( pO.Id, ( pO.Service_Billing__c > pO.Total_Disc_Serv_Bal__c ? pO.Service_Billing__c : pO.Total_Disc_Serv_Bal__c ) );
            poIdToUnallocatedBalanceWIthoutServiceAmountMap.put( pO.Id, pO.Unallocated_Balance_Without_Service_Am__c );

            poIdToServicesBalanceMap.put( pO.Id, null );
            poIdToReimbursablesBalanceMap.put( pO.Id, null );
            poIdToMunicipalFeesBalanceMap.put( pO.Id, null );
            if( pO.Services__c != null ) poIdToServicesBalanceMap.put( pO.Id, pO.Services__c - (pO.Service_Billing__c != null ? pO.Service_Billing__c : 0 ) );
            if( pO.Reimbursables__c != null ) poIdToReimbursablesBalanceMap.put( pO.Id, pO.Reimbursables__c - (pO.Reimbursable_Billing__c != null ? pO.Reimbursable_Billing__c : 0 ) );
            if( pO.Municipal_Fees__c != null ) poIdToMunicipalFeesBalanceMap.put( pO.Id, pO.Municipal_Fees__c - (pO.Municipal_Fees_Billing__c != null ? pO.Municipal_Fees_Billing__c : 0 ) );
        }

        Map<Boolean, List<Billing_Line_Item__c>> isReimbursableToBLIsMap = new Map<Boolean, List<Billing_Line_Item__c>> {
            true => new List<Billing_Line_Item__c>(),
            false => new List<Billing_Line_Item__c>()};

        for(Billing_Line_Item__c bli: lineItems) {
           isReimbursableToBLIsMap.get(bli.isReimbursable__c).add(bli);
        }

        List<Boolean> bools = new List<Boolean> {false, true};
        for( Boolean bool : bools ) {
            for( Billing_Line_Item__c bli: isReimbursableToBLIsMap.get(bool) ) {
                system.debug(LoggingLevel.Error,'### BLI ='+ bli);

                //for regular BLI and Milestone method
                if( bli.Service_Item__c != null
                        && sliIdToPoIdMap.get( bli.Service_Item__c ) != null
                        && poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) >= bli.Amount__c
                        && ( poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) == null
                    || poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) >= bli.Amount__c ) ) {

                    bli.Purchase_Order__c = sliIdToPoIdMap.get( bli.Service_Item__c );
                    system.debug(LoggingLevel.Error,'### BLI2 =' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);
                    poIdToUnallocatedBalanceWIthoutServiceAmountMap.put( sliIdToPoIdMap.get( bli.Service_Item__c ), poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) - bli.Amount__c );
                    if( poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) != null ) poIdToServicesBalanceMap.put( sliIdToPoIdMap.get( bli.Service_Item__c ), poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Service_Item__c ) ) - bli.Amount__c );
                    continue;
                }

                if( bli.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE || bli.Service_Item__c == null ){
                    //for regular BLIs with Billing Date
                    if( bli.Billing_Date__c != null && !bli.isReimbursable__c ){
                        if( projectIdToListOfPurchaseOrders.containsKey(bli.Project_Profile__c) ){
                            for( Purchase_Order__c item: projectIdToListOfPurchaseOrders.get(bli.Project_Profile__c) ){
                                if( poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( item.Id ) >= bli.Amount__c
                                    && ( poIdToServicesBalanceMap.get( item.Id ) == null
                                        || poIdToServicesBalanceMap.get( item.Id ) >= bli.Amount__c ) ){

                                    bli.Purchase_Order__c = item.Id;
                                    system.debug(LoggingLevel.Error,'### BLI3 ='+ bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);
                                    poIdToUnallocatedBalanceMap.put( item.Id, poIdToUnallocatedBalanceMap.get( item.Id ) - bli.Amount__c + poIdToMaxServicesBillingTotalDiscBalanceBillingBalanceMap.get( item.Id ));//MRS-7410
                                    poIdToUnallocatedBalanceWIthoutServiceAmountMap.put( item.Id, poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( item.Id ) - bli.Amount__c );
                                    if( poIdToServicesBalanceMap.get( item.Id ) != null ) poIdToServicesBalanceMap.put( item.Id, poIdToServicesBalanceMap.get( item.Id ) - bli.Amount__c );
                                    break;
                                }
                            }
                        }
                        continue;
                    }

                    if( bli.Related_Service_Item__c != null && !bli.Is_Check_Processing_Fee__c && !bli.isReimbursable__c
                            && sliIdToPoIdMap.get( bli.Related_Service_Item__c ) != null
                            && poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c
                            && ( ( poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) == null
                        || poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c )
                            && !bli.isReimbursable__c && !bli.Is_Check_Processing_Fee__c) ) { //MRS 7281

                        bli.Purchase_Order__c = sliIdToPoIdMap.get( bli.Related_Service_Item__c );
                        system.debug(LoggingLevel.Error,'### BLI4 =' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);
                        poIdToUnallocatedBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                        poIdToUnallocatedBalanceWIthoutServiceAmountMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToUnallocatedBalanceWIthoutServiceAmountMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                        if( poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) != null ) poIdToServicesBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToServicesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );

		                continue;
		            }
system.debug(LoggingLevel.Error,'### poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) = ' + poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ));
			    	if( bli.Related_Service_Item__c != null
		                    && sliIdToPoIdMap.get( bli.Related_Service_Item__c ) != null
		                    && poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c ){

                        if ( (!bli.isReimbursable__c && !bli.Is_Check_Processing_Fee__c) //MRS 7281
                            || poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) == null
                            || poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c
                            || poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) == null
                            || poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c ){

                            if( ( poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) == null
                        || poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c )
                                && !bli.IsMunicipalFee__c ){

                                system.debug(LoggingLevel.Error,'### BLI5 = ' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);
                                bli.Purchase_Order__c = sliIdToPoIdMap.get( bli.Related_Service_Item__c );

                                        poIdToUnallocatedBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                                if( poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) != null ) poIdToReimbursablesBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToReimbursablesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                            }

                            if( ( poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) == null
                                || poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) >= bli.Amount__c )
                                && bli.IsMunicipalFee__c ){

                                system.debug(LoggingLevel.Error,'### BLI6 = ' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);
                                bli.Purchase_Order__c = sliIdToPoIdMap.get( bli.Related_Service_Item__c );

                                        poIdToUnallocatedBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToUnallocatedBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                                if( poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) != null ) poIdToMunicipalFeesBalanceMap.put( sliIdToPoIdMap.get( bli.Related_Service_Item__c ), poIdToMunicipalFeesBalanceMap.get( sliIdToPoIdMap.get( bli.Related_Service_Item__c ) ) - bli.Amount__c );
                            }

                    continue;
                        }
                    }

                    if( bli.Project_Profile__c != null && projectIdToListOfPurchaseOrders.get( bli.Project_Profile__c ) != null ) {
                        for( Purchase_Order__c pO : projectIdToListOfPurchaseOrders.get( bli.Project_Profile__c ) ) {
                            if( poIdToUnallocatedBalanceMap.get( pO.Id ) >= bli.Amount__c ){
                                if ( (bli.isReimbursable__c || bli.Is_Check_Processing_Fee__c) && !bli.IsMunicipalFee__c && ( poIdToReimbursablesBalanceMap.get( pO.Id ) == null //MRS 7281
                                    || poIdToReimbursablesBalanceMap.get( pO.Id ) >= bli.Amount__c ) ) {

                                    bli.Purchase_Order__c = pO.Id;
                                    system.debug(LoggingLevel.Error, '### BLI7 = ' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);

                                    poIdToUnallocatedBalanceMap.put( pO.Id, poIdToUnallocatedBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    if( poIdToReimbursablesBalanceMap.get( pO.Id ) != null){
                                        poIdToReimbursablesBalanceMap.put( pO.Id, poIdToReimbursablesBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    }
                                } else if ( bli.isReimbursable__c && bli.IsMunicipalFee__c && ( poIdToMunicipalFeesBalanceMap.get( pO.Id ) == null
                                    || poIdToMunicipalFeesBalanceMap.get( pO.Id ) >= bli.Amount__c ) ) {

                                    bli.Purchase_Order__c = pO.Id;
                                    system.debug(LoggingLevel.Error, '### BLI8 = ' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);

                                    poIdToUnallocatedBalanceMap.put( pO.Id, poIdToUnallocatedBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    if( poIdToMunicipalFeesBalanceMap.get( pO.Id ) != null){
                                        poIdToMunicipalFeesBalanceMap.put( pO.Id, poIdToMunicipalFeesBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    }
                                }else if( !bli.Is_Check_Processing_Fee__c && !bli.isReimbursable__c && ( poIdToServicesBalanceMap.get( pO.Id ) == null //MRS 7281
                                            || poIdToServicesBalanceMap.get( pO.Id ) >= bli.Amount__c ) ) {

                                    bli.Purchase_Order__c = pO.Id;
                                    system.debug(LoggingLevel.Error, '### BLI9 = ' + bli + ' Purchase_Order__c =' + bli.Purchase_Order__c);

                                    poIdToUnallocatedBalanceMap.put( pO.Id, poIdToUnallocatedBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    if( poIdToServicesBalanceMap.get( pO.Id ) != null){
                                        poIdToServicesBalanceMap.put( pO.Id, poIdToServicesBalanceMap.get( pO.Id ) - bli.Amount__c );
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    public static void populatePayableReimbursableBLIPurchaseOrder( List<Billing_Line_Item__c> lineItemsNew ) { // MRS-7025
        if( lineItemsNew.isEmpty() ) return;

        Set<Id> projectsId = new Set<id>();
        List<Billing_Line_Item__c> blisNotDepartmentBased = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> finallyFilteredBLIs = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c bli: lineItemsNew ){
            projectsId.add( bli.Project_Profile__c );
            if( !bli.Department_Based__c && bli.Purchase_Order__c == null && !bli.Billed__c ) blisNotDepartmentBased.add( bli );
        }

        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>([Select Id, PO_Required__c, PO_Not_Required__c From Project_Profile__c Where Id IN: projectsId]);//7191

        for( Billing_Line_Item__c bli: blisNotDepartmentBased ){
            if( !(projectProfileMap.get(bli.Project_Profile__c).PO_Not_Required__c && (bli.isReimbursable__c || bli.Is_Check_Processing_Fee__c)) && bli.Active_Billing_Line_Item__c ) finallyFilteredBLIs.add( bli ); //MRS 7281
        }

        for( Billing_Line_Item__c bli: lineItemsNew ){//MRS-7313
            if( projectProfileMap.get(bli.Project_Profile__c).PO_Not_Required__c && (bli.isReimbursable__c || bli.Is_Check_Processing_Fee__c) && !bli.Billed__c ){ //MRS 7281
                bli.Purchase_Order__c = null;
            }
        }

        List<Purchase_Order__c> purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems( projectsId );
        if( purchaseOrders.isEmpty() ) return;

        populatePurchaseOrderOnBLIs( finallyFilteredBLIs, purchaseOrders );
    }

    public static void linkExistingBLIToNewPurchaseOrders( List<Purchase_Order__c> purchaseOrders ){
        if( purchaseOrders.isEmpty() ) return;

        Set<Id> projectsId = new Set<Id>();
        for( Purchase_Order__c poItem : purchaseOrders ){
            if( poItem.Project_Profile__c != null ){
                projectsId.add( poItem.Project_Profile__c );
            }
        }

        purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems( projectsId );
        List<Billing_Line_Item__c> lineItems = getBliWithoutPOListOrderedByAmount( projectsId );

        if( lineItems.isEmpty() ) return;
        populatePurchaseOrderOnBLIs( lineItems, purchaseOrders );

        List<Billing_Line_Item__c> bliToUpdate = new List<Billing_Line_Item__c>();
        for( Billing_Line_Item__c bli: lineItems ){
           if( !String.isBlank(bli.Purchase_Order__c )){
                bliToUpdate.add(bli);
            }
        }

        try{
            PurchaseOrderServices.preventDoubleLinkingBLIsToPO = true;
            update bliToUpdate;
        }catch( DMLException dmlEx ){
            for(Integer i=0; i < dmlEx.getNumDml(); i++){
                for( Purchase_Order__c poItem : purchaseOrders ) {
                    poItem.addError( 'Error occurred when updating billing line items' + dmlEx.getMessage() );
                }
            }
        }
    }

    public static void updateReimbursableBLIsForKinkingOrUnkinkingPOs( Set<Id> projectIds ){
        if( projectIds.isEmpty() ) return;

        List<Billing_Line_Item__c> lineItems = [SELECT Id, isReimbursable__c, Amount__c, Unit_Price__c, Project_Profile__c, Billing_Method__c, Billing_Date__c,
                                                        Service_Item__c, Purchase_Order__c, Is_Manualy_Created__c, Related_Service_Item__c, Is_Check_Processing_Fee__c, IsMunicipalFee__c
                                                    FROM Billing_Line_Item__c
                                                    WHERE Project_Profile__c IN: projectIds
                                                        AND ( isReimbursable__c = true OR Is_Check_Processing_Fee__c = true )
                                                        AND Billed__c =: false
                                                        AND Active_Billing_Line_Item__c =: true
                                                        AND Department_Based__c = false
                                                    Order by Amount__c DESC];

        if( lineItems.isEmpty() ) return;

        try{
            update lineItems;
        }catch (Exception ex) {
            throw new ErrorException(ex.getMessage());
        }
    }

    public static void updateBLIAfterProformaDeleted( Map<Id, Pro_forma_Invoice__c> deletedProformaInvoicesMap ) {
        List<Billing_Line_Item__c> bliForUpdate = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> bliForDelete = new List<Billing_Line_Item__c>();
        List<Service_Item__c> servicesToUpdate = new List<Service_Item__c>();

        Set<Id> servicesIds = new Set<Id>();

        for( Billing_Line_Item__c bliItem: [SELECT Id, Billed__c, Pro_forma_Invoice__c, isReimbursable__c, Reimbursable_Type__c,
                                            Related_Service_Item__c, Project_Profile__r.Pre_billed__c
                                            FROM Billing_Line_Item__c
                                            WHERE Pro_forma_Invoice__c IN: deletedProformaInvoicesMap.keySet()]){
            if( !bliItem.Project_Profile__r.Pre_billed__c &&  bliItem.isReimbursable__c && bliItem.Reimbursable_Type__c == REIMBURSABLE_TYPE_SHREDDING ){
                bliForDelete.add(bliItem);
			if( !servicesIds.contains(bliItem.Related_Service_Item__c) ){
				servicesIds.add(bliItem.Related_Service_Item__c);
	                	servicesToUpdate.add(new Service_Item__c( id = bliItem.Related_Service_Item__c, Doc_Shredding_BLI_Created__c = false ));
	            	}
		    }else{
                bliItem.Billed__c = false;
				bliItem.Pro_forma_Invoice__c = null; //MRS 7558
                bliForUpdate.add(bliItem);
            }
        }
        try{
            update bliForUpdate;
            update servicesToUpdate;
            delete bliForDelete;
        }catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                deletedProformaInvoicesMap.get(bliForUpdate[i].Pro_forma_Invoice__c).addError( 'Can not update Billing Line Item. ' + dmlEx.getMessage() );
            }
        }
    }

    public static void updateContactsAmountsAndPO(List<Billing_Line_Item__c> newLineItemList, Map<Id, Billing_Line_Item__c> oldMap) {
        if (newLineItemList.isEmpty()) return;

        Set<Id> projectProfileIds = new Set<Id>();
        for (Billing_Line_Item__c lineItem : newLineItemList) {
            if (null != lineItem.Project_Profile__c) {
                projectProfileIds.add(lineItem.Project_Profile__c);
            }
        }

        Map<Id, Project_Profile__c> progectProfileMap = new Map<Id, Project_Profile__c>([ SELECT Id, Billing_Company_Contact__c, Total_Service_Amount__c, Building__c,
                                                                 Billing_Company_Name__c, Discounted_Total_Service_Amount__c, Accounting_Contact_Company__c, Accounting_Contact__c
                                                          FROM Project_Profile__c
                                                          WHERE Id IN : projectProfileIds ]);
        if (progectProfileMap.isEmpty() ) return;

        List<Billing_Line_Item__c> bliToPopulatePO = new List<Billing_Line_Item__c>();
        for (Billing_Line_Item__c lineItem : newLineItemList) {
            if (progectProfileMap.containsKey(lineItem.Project_Profile__c)) {
                Project_Profile__c currentProject = progectProfileMap.get(lineItem.Project_Profile__c);

                //MRS-6112
                if( lineItem.Is_Manualy_Created__c ){
                    if((oldMap != null && lineItem.Amount__c != oldMap.get(lineItem.Id).Amount__c
                        && lineItem.Quantity__c == oldMap.get(lineItem.Id).Quantity__c
                        && lineItem.Unit_Price__c == oldMap.get(lineItem.Id).Unit_Price__c) ||
                        (oldMap == null && lineItem.Amount__c != null && lineItem.Quantity__c != null)) {
                        lineItem.Unit_Price__c = lineItem.Amount__c / lineItem.Quantity__c;
                    }else if((oldMap != null && (lineItem.Quantity__c != oldMap.get(lineItem.Id).Quantity__c
                                    || lineItem.Unit_Price__c != oldMap.get(lineItem.Id).Unit_Price__c)) ||
                            (oldMap == null && lineItem.Amount__c == null && lineItem.Quantity__c != null && lineItem.Unit_Price__c != null)) {
                        if (ProjectProfileServices.BILLINGMETHODMILESTONE.equals(lineItem.Billing_Project_Method__c) && lineItem.Unit_Price__c != null) {
                            lineItem.Amount__c = lineItem.Unit_Price__c * lineItem.Quantity__c;
                        }else if( ProjectProfileServices.BILLINGMETHODPERCENTAGE.equals(lineItem.Billing_Project_Method__c) ||
                            ProjectProfileServices.BILLINGMETHODINSTALLMENT.equals(lineItem.Billing_Project_Method__c) ){
                            lineItem.Amount__c = currentProject.Discounted_Total_Service_Amount__c * lineItem.Quantity__c;
                        }
                    }
                }

                lineItem.Billing_Contact__c = currentProject.Billing_Company_Contact__c;
                lineItem.Billing_Client__c = currentProject.Billing_Company_Name__c;
                lineItem.Project_Address__c = currentProject.Building__c;
                lineItem.Accounting_Contact__c = currentProject.Accounting_Contact__c;
                lineItem.Accounting_Contact_Company__c = currentProject.Accounting_Contact_Company__c;
            }

            if( lineItem.Is_Manualy_Created__c ) {
                bliToPopulatePO.add(lineItem);
            }
        }

        //if( !PurchaseOrderServices.preventDoubleLinkingBLIsToPO ) updateBLIPurchaseOrder(bliToPopulatePO, progectProfileMap);
    }

    public static void updateBLIPurchaseOrder( List<Billing_Line_Item__c> billingLineItemList, Map<Id, Project_Profile__c> projectProfileMap ){
        if( billingLineItemList.isEmpty() ) return;

        Set<Id> seviceItemIdSet = new Set<Id>();
        for( Billing_Line_Item__c bli : billingLineItemList ) {
            seviceItemIdSet.add(bli.Service_Item__c);
        }

        List<Purchase_Order__c> purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForBillingLineItems( projectProfileMap.keySet() );
        Map<Id, Purchase_Order__c> purchaseOrdersMap = new Map<Id, Purchase_Order__c>( purchaseOrders );
        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>( ServiceItemServices.getServiceItemMap( seviceItemIdSet ) );
        List<Billing_Line_Item__c> reimbursableLineItems = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c bli : billingLineItemList ) {
            String billingMethod = projectProfileMap.get(bli.Project_Profile__c).Billing_Method__c;
            Boolean interval = projectProfileMap.get(bli.Project_Profile__c).Interval__c;

            //MRS-6067 Validate if manualy updated PO or amount are valid
            if( bli.Is_Manualy_Created__c && !String.isEmpty( bli.Purchase_Order__c ) && purchaseOrdersMap.containsKey( bli.Purchase_Order__c ) ){
                if( !isPOValidForBliAssignment( bli, purchaseOrdersMap.get(bli.Purchase_Order__c), false ) ){
                    bli.addError( 'This BLI exceeds the available amount of the PO.' );
                }
            }

            if( bli.isReimbursable__c ){
                reimbursableLineItems.add( bli );
            }else{
                if( billingMethod == ProjectProfileServices.BILLINGMETHODMILESTONE ){
                    if( bli.Service_Item__c != null && serviceItemMap.containsKey( bli.Service_Item__c )
                        && purchaseOrdersMap.containsKey( serviceItemMap.get(bli.Service_Item__c).Purchase_Order__c ) ){

                        bli.Purchase_Order__c = getPurchaseOrderForRegularBLI( new List<Purchase_Order__c>{purchaseOrdersMap.get(serviceItemMap.get(bli.Service_Item__c).Purchase_Order__c)}, bli, false );
                    } else if ( bli.Service_Item__c == null ){
                        bli.Purchase_Order__c = getPurchaseOrderForRegularBLI( purchaseOrders, bli, true );
                    }
                }else {
                    bli.Purchase_Order__c = getPurchaseOrderForRegularBLI( purchaseOrders, bli, false );
                }
            }
        }

        for( Billing_Line_Item__c bli: reimbursableLineItems ){
            bli.Purchase_Order__c = getPurchaseOrderForReimbursableLineItem ( purchaseOrders, bli, projectProfileMap );
        }
    }

    public static Id getPurchaseOrderForRegularBLI ( List<Purchase_Order__c> purchaseOrders, Billing_Line_Item__c bli, Boolean includeServiceAmount ) {
        Set<Id> sutablePurchaseOrdersId = new Set<Id>();

        for (Purchase_Order__c purchaseOrder : purchaseOrders ) {
            if( purchaseOrder.Project_Profile__c == bli.Project_Profile__c &&
                isPOValidForBliAssignment( bli, purchaseOrder, includeServiceAmount ) ){
                 //MRS-5940
                if( !purchaseOrder.Covered_Services__r.isEmpty() && bli.Service_Item__c != null
            && purchaseOrder.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ){
                    system.debug(LoggingLevel.Error,'bli ='+bli);
                    //purchaseOrder.Purchase_Order_Amount__c -= bli.Amount__c;
                    system.debug(LoggingLevel.Error,'purchaseOrder.Purchase_Order_Amount__c ='+purchaseOrder.Purchase_Order_Amount__c);
                    return purchaseOrder.Id;
                }else{
                    system.debug(LoggingLevel.Error,'bli ='+bli);
                    sutablePurchaseOrdersId.add( purchaseOrder.Id );
                }
            }
        }

        if( !sutablePurchaseOrdersId.isEmpty() ){
            List<Id> purchaseOrdersIdList = new List<Id>(sutablePurchaseOrdersId);
            Map<Id, Purchase_Order__c> purchaseOrderMap = new Map<Id, Purchase_Order__c>(purchaseOrders);
            purchaseOrderMap.get(purchaseOrdersIdList[0]).Purchase_Order_Amount__c -= bli.Amount__c;
            system.debug(LoggingLevel.Error,'bli ='+bli);
            system.debug(LoggingLevel.Error,'purchaseOrdersIdList[0].Amount ='+purchaseOrderMap.get(purchaseOrdersIdList[0]).Purchase_Order_Amount__c);
            return purchaseOrdersIdList[0];
        }

        return null;
    }

    public static Boolean isPOValidForBliAssignment( Billing_Line_Item__c bli, Purchase_Order__c purchaseOrder, Boolean includeServices ){
        Decimal totalServiseAmount = 0;
        Decimal totalLineItemsAmount = 0;

        if( includeServices ){
            for( Service_Item__c serviceItem : purchaseOrder.Covered_Services__r ){
                totalServiseAmount += serviceItem.Total_Service_Price__c + serviceItem.Sales_Tax_Amount__c;
            }
        }

        for( Billing_Line_Item__c lineItem : purchaseOrder.Billing_Line_Items__r ){
            //if amount of manualy created bli has been changed
            if( bli.Id != lineItem.Id && ( lineItem.isReimbursable__c || lineItem.Service_Item__c == null ) ){
                totalLineItemsAmount += lineItem.Amount__c != null ? lineItem.Amount__c : 0;
            }
        }
        system.debug(LoggingLevel.Error,'purchaseOrder.Purchase_Order_Amount__c ='+purchaseOrder.Purchase_Order_Amount__c);
        system.debug(LoggingLevel.Error,'totalServiseAmount ='+totalServiseAmount);
        system.debug(LoggingLevel.Error,'totalLineItemsAmount ='+totalLineItemsAmount);
        return bli.Amount__c <= purchaseOrder.Purchase_Order_Amount__c - totalServiseAmount - totalLineItemsAmount;
    }

     @TestVisible
    private static Id getPurchaseOrderForReimbursableLineItem ( List<Purchase_Order__c> purchaseOrders, Billing_Line_Item__c bli, Map<Id, Project_Profile__c> projectProfileMap ) {
        Purchase_Order__c purchaseOrderRelatedToBliService = new Purchase_Order__c();
        Set<Id> sutablePurchaseOrdersId = new Set<Id>();
        Set<Id> idsOfServiceItemsFromPO = new Set<Id>();
        String billingMethod = projectProfileMap != null ? projectProfileMap.get(bli.Project_Profile__c).Billing_Method__c : '';


        for (Purchase_Order__c purchaseOrder : purchaseOrders ) {
            if( purchaseOrder.Project_Profile__c != bli.Project_Profile__c ) continue;
            Decimal totalServiseAmount = 0;
            Decimal totalLineItemsAmount = 0;

            for( Service_Item__c serviceItem : purchaseOrder.Covered_Services__r ){
                if( serviceItem.Id == bli.Related_Service_Item__c ){
                    purchaseOrderRelatedToBliService = purchaseOrder;
                }
        //if( billingMethod == ProjectProfileServices.BILLINGMETHODMILESTONE ){
                    totalServiseAmount += serviceItem.Total_Service_Price__c + serviceItem.Sales_Tax_Amount__c;
                idsOfServiceItemsFromPO.add( serviceItem.Id );
        //}
            }

        if ( purchaseOrder.Service_Billing__c > totalServiseAmount ) totalServiseAmount = purchaseOrder.Service_Billing__c;

            for( Billing_Line_Item__c lineItem : purchaseOrder.Billing_Line_Items__r ){
                totalLineItemsAmount += ( lineItem.Amount__c != null && !idsOfServiceItemsFromPO.contains(lineItem.Service_Item__c) ) ? lineItem.Amount__c : 0;
            }
            system.debug(LoggingLevel.Error,'purchaseOrder.Purchase_Order_Amount__c ='+purchaseOrder.Purchase_Order_Amount__c);

            if( (bli.Amount__c <=  purchaseOrder.Purchase_Order_Amount__c - totalServiseAmount - totalLineItemsAmount) && (bli.Amount__c <= purchaseOrder.Purchase_Order_Amount__c) ) {
                purchaseOrder.Purchase_Order_Amount__c -= bli.Amount__c;
                sutablePurchaseOrdersId.add(purchaseOrder.Id);
            }

            system.debug(LoggingLevel.Error,'totalServiseAmount ='+totalServiseAmount);
            system.debug(LoggingLevel.Error,'totalLineItemsAmount ='+totalLineItemsAmount);
        }

        if( !sutablePurchaseOrdersId.isEmpty() ){
            if( purchaseOrderRelatedToBliService.Id != null && sutablePurchaseOrdersId.contains(purchaseOrderRelatedToBliService.Id) ){
                system.debug(LoggingLevel.Error,'purchaseOrderRelatedToBliService.Id='+purchaseOrderRelatedToBliService.Id);
                return purchaseOrderRelatedToBliService.Id;
            }else{
                system.debug(LoggingLevel.Error,'sutablePurchaseOrdersId ='+sutablePurchaseOrdersId);
                List<Id> purchaseOrdersIdList = new List<Id>(sutablePurchaseOrdersId);
                return purchaseOrdersIdList[0];
            }
        }

        return null;
    }

    public static Map<Id, Billing_Line_Item__c> getBliWithoutPO( Set<Id> projectsId ){
        return new Map<Id, Billing_Line_Item__c>([SELECT Id, isReimbursable__c, Amount__c, Unit_Price__c, Project_Profile__c, Billing_Method__c, Billing_Date__c,
                                                        Service_Item__c, Purchase_Order__c, Is_Manualy_Created__c, Related_Service_Item__c, Is_Check_Processing_Fee__c, IsMunicipalFee__c
                                                    FROM Billing_Line_Item__c
                                                    WHERE Project_Profile__c IN: projectsId
                                                    AND Superceded__c =: false
                                                    AND Billed__c =: false
                                                    AND Active_Billing_Line_Item__c =: true
                                                    AND Purchase_Order__c =: null]);
    }

    public static List<Billing_Line_Item__c> getBliWithoutPOListOrderedByAmount( Set<Id> projectsId ){
        return new List<Billing_Line_Item__c>([SELECT Id, isReimbursable__c, Amount__c, Unit_Price__c, Project_Profile__c, Billing_Method__c, Billing_Date__c,
                                                        Service_Item__c, Purchase_Order__c, Is_Manualy_Created__c, Related_Service_Item__c, Is_Check_Processing_Fee__c, IsMunicipalFee__c
                                                    FROM Billing_Line_Item__c
                                                    WHERE Project_Profile__c IN: projectsId
                                                    AND ( Project_Profile__r.PO_Not_Required__c = false OR isReimbursable__c = false )
                                                    AND Billed__c =: false
                                                    AND Active_Billing_Line_Item__c =: true
                                                    AND Purchase_Order__c =: null
                                                    AND Department_Based__c = false
                            Order by Amount__c DESC]);
    }

    public static void setChangeOrderLookupAndServiceName( List<Billing_Line_Item__c> newsBlis, Boolean isInsert ) {
        Set<Id> serviceItemIds = new Set<Id>();
        for( Billing_Line_Item__c newsBlisItem : newsBlis ) {
            serviceItemIds.add( newsBlisItem.Service_Item__c );
        }
        serviceItemIds.remove( null );
        Map<Id, Service_Item__c> serviceItemIdToServiceItem = new Map<Id, Service_Item__c>( [ SELECT Change_Order__c, Service_Name_Full__c
                                                                                              FROM Service_Item__c
                                                                                              WHERE Id IN : serviceItemIds ] );
        for( Billing_Line_Item__c newsBlisItem : newsBlis ) {
            if( serviceItemIdToServiceItem.containsKey( newsBlisItem.Service_Item__c ) ) {
                newsBlisItem.Change_Order__c = serviceItemIdToServiceItem.get( newsBlisItem.Service_Item__c ).Change_Order__c;
                newsBlisItem.Service_Name__c = serviceItemIdToServiceItem.get( newsBlisItem.Service_Item__c ).Service_Name_Full__c;
            } else {
                newsBlisItem.Change_Order__c = null;
                newsBlisItem.Service_Name__c = null;
            }
        }
    }

    public static Map<Id, Billing_Line_Item__c> getNotSupercededBLIByProjectsId( Set<Id> projectsId ){
        return new Map<Id, Billing_Line_Item__c>([Select Id, Billing_Client__c, Billing_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c, Project_Profile__c,
                                                            Phase__c, Project_Address__c, Milestone_Date__c, Sales_Tax_Amount__c, Superceded__c, Service_Item__c,
                                                            Project_Profile_No_Document_Shredding__c, Service_Shredding_Fee__c, Service_Type__c, Service_Category__c,
                                                            isReimbursable__c, Purchase_Order__c, Name,
                                                            Project_Profile__r.Invoice_Format__c, Project_Profile__r.Floor_s__c, Project_Profile__r.Account_Executive__c, Project_Profile__r.Project_Name__c,
                                                            Project_Profile__r.Frequency__c, Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c, Project_Profile__r.Client_Project__c
                                                            From Billing_Line_Item__c
                                                            WHERE Project_Profile__c IN: projectsId
                                                            AND Superceded__c =: false]);
    }



    public static Map<Id, Billing_Line_Item__c> getBLIForInvoicesToGeneratePDF( Set<Id> proFormaInvoiceSet ){
        return new Map<Id, Billing_Line_Item__c>([SELECT Id, Pro_forma_Invoice__c, Mailroom__r.COSTCATID_Service_Type__c, Mailroom_COSTCATID_Service_Type__c, Reimbursable_Type__c,
                                                         isHourlyConsulting__c
                                                    FROM Billing_Line_Item__c
                                                    WHERE Pro_forma_Invoice__c IN : proFormaInvoiceSet AND
                                                          ( Mailroom__r.COSTCATID_Service_Type__c = : FEDEX_FILTER OR
                                                            Mailroom__r.COSTCATID_Service_Type__c = : FEDEX_AIRBORNE_FILTER OR /* MRS 6707 */
                                                            Mailroom__r.COSTCATID_Service_Type__c LIKE : SUPREME_SYSTEMS_FILTER + '%' OR
                                                            Reimbursable_Type__c =: REIMBURSABLE_TYPE_SHREDDING OR
                                                            Reimbursable_Type__c =: REIMBURSABLE_TYPE_SCANNING OR
                                                            isHourlyConsulting__c = true ) ] );
    }

    public static Set<Id> getInvoiceIdsThatHaveChargeChecks( Set<Id> proFormaInvoiceIds ){
        Set<Id> invoiceIdsThatHaveChargeChecks = new Set<Id>();
        for( c2g__codaPurchaseInvoice__c invoice : [ SELECT Billing_Line_Item__r.Pro_forma_Invoice__c
                                                     FROM c2g__codaPurchaseInvoice__c
                                                     WHERE Check_Request__r.Requested_From__c = : CheckServices.CHARGE
                                                       AND Billing_Line_Item__r.Pro_forma_Invoice__c IN : proFormaInvoiceIds ] ) {
            invoiceIdsThatHaveChargeChecks.add( invoice.Billing_Line_Item__r.Pro_forma_Invoice__c );
        }
        return invoiceIdsThatHaveChargeChecks;
    }

    public static Boolean serviceTriggerWillAttachPO = false;



    public static Map<Id, List<Billing_Line_Item__c>> filterBlisForSettingDepositOnAccountCheckbox( List<Billing_Line_Item__c> newBillingLineItemsList, Map<Id, Billing_Line_Item__c> oldBillingLineItemsMap ) {
        Map<Id, List<Billing_Line_Item__c>> proformaInvoiceIdToBillingLineItems = new Map<Id, List<Billing_Line_Item__c>>();
        for( Billing_Line_Item__c bli : newBillingLineItemsList ) {
            if( oldBillingLineItemsMap == null ) {
                if( !proformaInvoiceIdToBillingLineItems.containsKey( bli.Pro_forma_Invoice__c ) ) proformaInvoiceIdToBillingLineItems.put( bli.Pro_forma_Invoice__c, new List<Billing_Line_Item__c>() );
                proformaInvoiceIdToBillingLineItems.get( bli.Pro_forma_Invoice__c ).add( bli );
            } else {
                Billing_Line_Item__c oldBli = oldBillingLineItemsMap.get( bli.Id );
                if( bli.Pro_forma_Invoice__c != oldBli.Pro_forma_Invoice__c ) {
                    if( !proformaInvoiceIdToBillingLineItems.containsKey( bli.Pro_forma_Invoice__c ) ) proformaInvoiceIdToBillingLineItems.put( bli.Pro_forma_Invoice__c, new List<Billing_Line_Item__c>() );
                    proformaInvoiceIdToBillingLineItems.get( bli.Pro_forma_Invoice__c ).add( bli );
                    if( !proformaInvoiceIdToBillingLineItems.containsKey( oldBli.Pro_forma_Invoice__c ) ) proformaInvoiceIdToBillingLineItems.put( oldBli.Pro_forma_Invoice__c, new List<Billing_Line_Item__c>() );
                    proformaInvoiceIdToBillingLineItems.get( oldBli.Pro_forma_Invoice__c ).add( oldBli );
                }
            }
        }
        proformaInvoiceIdToBillingLineItems.remove(null);
        return proformaInvoiceIdToBillingLineItems;
    }

    public static void setDepositOnAccountCheckboxForProformaInvoices( Map<Id, List<Billing_Line_Item__c>> proformaInvoiceIdToBillingLineItems ) {
        Set<Id> projectProfileIdsNotReimbursable = new Set<Id>();
        Set<Id> projectProfileIdsMunicipalFee = new Set<Id>();
        Set<Id> proformaInvoiceIdsMunicipalFee = new Set<Id>();
        Set<Id> projectProfileIdsWithDepositInvoicesNotReimbursable = new Set<Id>();
        Set<Id> projectProfileIdsWithDepositInvoicesMunicipalFee = new Set<Id>();
        if( !proformaInvoiceIdToBillingLineItems.isEmpty() ) {
            List<Pro_forma_Invoice__c> proformaInvoices = [ SELECT Id, Project_Profile__c,
                                                                   ( SELECT Id, IsReimbursable__c, IsMunicipalFee__c
                                                                     FROM Billing_Line_Items__r
                                                                     WHERE IsReimbursable__c = false
                                                                        OR IsMunicipalFee__c = true )
                                                            FROM Pro_forma_Invoice__c
                                                            WHERE Id IN : proformaInvoiceIdToBillingLineItems.keySet() ];
            for( Pro_forma_Invoice__c pfi : proformaInvoices ) {
                for( Billing_Line_Item__c bli : pfi.Billing_Line_Items__r ){
                    if( !bli.IsReimbursable__c ) {
                        projectProfileIdsNotReimbursable.add( pfi.Project_Profile__c );
                    }
                    if( bli.IsMunicipalFee__c ) {
                        projectProfileIdsMunicipalFee.add( pfi.Project_Profile__c );
                        proformaInvoiceIdsMunicipalFee.add( pfi.Id );
                    }
                }
            }
            projectProfileIdsNotReimbursable.remove(null);
            projectProfileIdsMunicipalFee.remove(null);
            if( !projectProfileIdsNotReimbursable.isEmpty() || !projectProfileIdsMunicipalFee.isEmpty() ) {
                for( Deposit_Invoice__c depositInvoice : [ SELECT Project_Profile__c, Deposit_Invoice_Type__c
                                                           FROM Deposit_Invoice__c
                                                           WHERE ( Deposit_Invoice_Type__c = : DepositInvoiceServices.SERVICE_RETAINER_TYPE
                                                                OR Deposit_Invoice_Type__c = : DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE )
                                                             AND Amount_Remaining__c > 0
                                                             AND ( Project_Profile__c IN : projectProfileIdsNotReimbursable
                                                                OR Project_Profile__c IN : projectProfileIdsMunicipalFee ) ] ) {
                    if( depositInvoice.Deposit_Invoice_Type__c == DepositInvoiceServices.SERVICE_RETAINER_TYPE &&
                        projectProfileIdsNotReimbursable.contains( depositInvoice.Project_Profile__c ) ) {
                        projectProfileIdsWithDepositInvoicesNotReimbursable.add( depositInvoice.Project_Profile__c );
                    }
                    if( depositInvoice.Deposit_Invoice_Type__c == DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE &&
                        projectProfileIdsMunicipalFee.contains( depositInvoice.Project_Profile__c ) ) {
                        projectProfileIdsWithDepositInvoicesMunicipalFee.add( depositInvoice.Project_Profile__c );
                    }
                }
                for( Pro_forma_Invoice__c pfi : proformaInvoices ) {
                    pfi.Deposit_On_Account__c = projectProfileIdsWithDepositInvoicesNotReimbursable.contains( pfi.Project_Profile__c ) ||
                                                    ( projectProfileIdsWithDepositInvoicesMunicipalFee.contains( pfi.Project_Profile__c ) &&
                                                      proformaInvoiceIdsMunicipalFee.contains( pfi.Id ) );
                }
                try {
                    UPDATE proformaInvoices;
                } catch( DMLException dmlEx ) {
                    for ( Integer i = 0; i < dmlEx.getNumDml(); i++) {
                        for( Billing_Line_Item__c bli : proformaInvoiceIdToBillingLineItems.get( proformaInvoices[i].Id ) ) {
                            bli.addError( 'Can not update Billing Line Item: ' + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }
    }

    public static Billing_Line_Item__c newInstance(final Task_Item__c taskItem, final Vendor_Request__c vendor) {
        return new Billing_Line_Item__c( Accounting_Contact_Company__c = taskItem.Project_Profile__r.Accounting_Contact_Company__c,
                                         Accounting_Contact__c         = taskItem.Project_Profile__r.Accounting_Contact__c,
                                         Billing_Method__c             = taskItem.Project_Profile__r.Billing_Method__c,
                                         Project_Profile__c            = taskItem.Project_Profile__c,
                                         Project_Address__c            = taskItem.Project_Profile__r.Building__c,
                                         Client_Contact__c             = taskItem.Project_Profile__r.Primary_Company_Contact__c,
                                         Billing_Client__c             = taskItem.Project_Profile__r.Billing_Company_Name__c,
                                         Billing_Contact__c            = taskItem.Project_Profile__r.Billing_Company_Contact__c,
                                         Quantity__c                   = 1,
                                         Unit_Price__c                 = vendor.Cost__c,
                                         Amount__c                     = vendor.Cost__c,
                                         Milestone_Date__c             = date.today(),
                                         Service_Item__c               = null,
                                         Related_Service_Item__c       = taskItem.Service_Item__c,
                                         Description__c                = taskItem.Service_Item__r.Type__c + (String.isBlank(vendor.Description_of_Work__c) ? '' : ' - ' + vendor.Description_of_Work__c),
                                         Product_Name__c               = REIMBURSABLE_BLI_NO_MET_DATA_SREDDING_PRODUCT_NAME,
                                         //Phase__c                      = taskItem.Service_Item__r.Phase__c,
                                         isReimbursable__c             = true,
                                         Is_Manualy_Created__c         = false,
										 Reimbursable_Type__c		   = 'Request/Assign Vendor Activity'); //MRS 7518

    }

    public static void updateBLIisActiveField( Set<Id> idsToInCOmplete, Set<Id> idsToComplete ) {

        updateBLIisActiveField( idsToInCOmplete, idsToComplete, true );
    }

    public static void updateBLIisActiveField( Set<Id> idsToInCOmplete, Set<Id> idsToComplete, Boolean doRunInFuture ) {
        if( Limits.getLimitFutureCalls() - Limits.getFutureCalls() > 0 && idsToInCOmplete != null && !idsToInCOmplete.isEmpty() ) {
            if ( doRunInFuture ) {
                deActiveBillingLineItemFuture( idsToInCOmplete );
            } else {
                deActiveBillingLineItem( idsToInCOmplete );
            }

            List<Task_Item__c> taskItems = new List<Task_Item__c>();
            for( Id taskItemId : idsToInCOmplete ) {
                taskItems.add( new Task_Item__c( Id = taskItemId, Actual_End_Date__c = null, Actual_Duration__c = null, Is_Locked__c = false, Is_Future__c = true ) );
            }
            if( !taskItems.isEmpty() ) {
                UPDATE taskItems;
            }
        }

        if( Limits.getLimitFutureCalls() - Limits.getFutureCalls() > 0 && idsToComplete != null && !idsToComplete.isEmpty() ) {
            if( doRunInFuture ) {
                activeBillingLineItemFuture( idsToComplete );
            } else {
                activeBillingLineItem( idsToComplete );
            }
        }
    }

    @future
    public static void deActiveBillingLineItemFuture( Set<Id> taskItemIds ) {
        deActiveBillingLineItem(taskItemIds);
    }

    public static void deActiveBillingLineItem( Set<Id> taskItemIds ) {
        if ( taskItemIds.isEmpty() )  return;

        List<Task> tasks = new List<Task>();
        List<Task_Item__c> taskItems = [Select Id, Service_Item__c, Billing_Percentage__c, Billing_Line_Item__c
                    From Task_Item__c
                    Where Id IN: taskItemIds];
        List<Service_Item__c> serviceItemsWIthDeletedReimbursables = new List<Service_Item__c>();
        List<Billing_Line_Item__c> billingItems = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> billingItemsToRemove = new List<Billing_Line_Item__c>();
        Map<Id, List<String>> bliIdsToComments  = new Map<Id, List<String>>();
        Set<Id> idOfServices = new Set<Id>();
        for( Task_Item__c item: taskItems ){
            idOfServices.add( item.Service_Item__c );
        }
        Map<Id, Billing_Line_Item__c> bliIdTobli = getBillingLineItemMapByIds( idOfServices );
        Map<Id, List<Billing_Line_Item__c>> taskIdToReimbBLIs = new Map<Id, List<Billing_Line_Item__c>>();
        Set<Id> idsProformaForDelete = new Set<Id>();
        Map<Id, Pro_forma_Invoice__c> idToProformaForUpdateTotalComAmount = new Map<Id, Pro_forma_Invoice__c>();
        List<Pro_forma_Invoice__c> proFormaInvoicesForDelete = new List<Pro_forma_Invoice__c>();

        //Reimbursable BLIs for deletion
        for( Billing_Line_Item__c item: [SELECT Task_Item__c, Quantity__c, Milestone_Date__c, Name, Id, Active_Billing_Line_Item__c, Billing_Date__c,
                                                  Project_Number__c, Project_Name__c, Pro_forma_Invoice__r.Id, Pro_forma_Invoice__r.Sales_Invoice__c, Pro_forma_Invoice__r.Name,
                                                  Billed__c, Description__c, isHourlyConsulting__c,
                                                  Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c, Service_Item__c, isReimbursable__c, Related_Service_Item__c
                                           FROM Billing_Line_Item__c
                                           WHERE ( Related_Service_Item__c IN: idOfServices
                                                AND isReimbursable__c = true
                                            AND Billed__c = false
                                                AND Reimbursable_Type__c =: REIMBURSABLE_TYPE_SCANNING )
                                              OR ( Service_Item__c IN: idOfServices
                                AND isHourlyConsulting__c = true
                                                AND Active_Billing_Line_Item__c = false
                            AND Project_Profile__r.Billing_Method__c = 'Milestone' ) ] ){

            if( item.isReimbursable__c ){
                if( !taskIdToReimbBLIs.containsKey(item.Related_Service_Item__c) ){
                    taskIdToReimbBLIs.put(item.Related_Service_Item__c, new List<Billing_Line_Item__c>() );
                }
                taskIdToReimbBLIs.get(item.Related_Service_Item__c).add(item);
            }else if( item.isHourlyConsulting__c && !item.Active_Billing_Line_Item__c ) {
                billingItemsToRemove.add( item );
            }

        }


        String projectNumber = '';
        Map<String, String> bliNameToProformaName = new Map<String, String>();

        for ( Task_Item__c task : taskItems ) {
            Billing_Line_Item__c bli = bliIdTobli.get(task.Billing_Line_Item__c);
            //If BLI not billed, system deactive BLI.
            if ( bli != null ){
                if ( !bli.Billed__c || bli.Pro_forma_Invoice__r.Sales_Invoice__c == null ) {
                    if( !bli.isHourlyConsulting__c && !bli.isReimbursable__c ){
                        if( bli.Quantity__c - ( ( task.Billing_Percentage__c != null) ? task.Billing_Percentage__c/100 : 0 ) > 0 ){

                            if (bli.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !bli.Project_Profile__r.Interval__c){//MRS-7262
                                bli.Active_Billing_Line_Item__c = false;
                            } else {
                                bli.Quantity__c -= ( ( task.Billing_Percentage__c != null) ? task.Billing_Percentage__c/100 : 0 );
                                bli.Amount__c = bli.Quantity__c*bli.Unit_Price__c;
                            }

                            if( bli.Pro_forma_Invoice__c != null ) idsProformaForDelete.add( bli.Pro_forma_Invoice__c );

                        }else{

                            bli.Active_Billing_Line_Item__c = false;
                            if( bli.Pro_forma_Invoice__c != null ){
                                idsProformaForDelete.add( bli.Pro_forma_Invoice__c );

                                bli.Pro_forma_Invoice__c = null;
                                bli.Billed__c = false;

                            }

                        }
                        billingItems.add(bli);
                    } else if( bli.Description__c == UNUSED_CONSULTING_HOURS_DESCRIPTION ) {
                        billingItemsToRemove.add( bli );

                    }

                //If BLI is billed, system create standard task for staff accounter.
                } else {
                    if( !bli.isHourlyConsulting__c ){
                        projectNumber = bli.Project_Number__c;

                        if (!bliIdsToComments.containsKey(bli.Id)) {
                            bliIdsToComments.put(bli.Id, new List<String>());
                            bliNameToProformaName.put(bli.Name, bli.Pro_forma_Invoice__r.Name);
                        }
                        bliIdsToComments.get(bli.Id).add(BILLING_LINE_ITEM_INCOMPLETE);
                    }
                }
            }
            //MRS-6225 when the task status is changed to incomplete we should delete the scanning BLI associated with the service
            if( taskIdToReimbBLIs.containsKey( task.Service_Item__c ) && taskIdToReimbBLIs.get( task.Service_Item__c ) != null ) {
                billingItemsToRemove.addAll( taskIdToReimbBLIs.get( task.Service_Item__c ) );
                serviceItemsWIthDeletedReimbursables.add( new Service_Item__c( Id = task.Service_Item__c, Met_Data_BLI_Created__c = false ) );
            }
        }

        try {
            if (billingItems.size() > 0) {

                Map<Id,Billing_Line_Item__c> billingItemsMap = new Map<Id,Billing_Line_Item__c>(billingItems);

                for( Pro_forma_Invoice__c item: [Select Id, cl_Create_FFA_Invoice__c, Sales_Invoice__c, (Select Id From Billing_Line_Items__r) From Pro_forma_Invoice__c Where Id In: idsProformaForDelete] ){

                    if( item.Billing_Line_Items__r.isEmpty() ){
                        proFormaInvoicesForDelete.add(item);
                    }else{
                        item.cl_Create_FFA_Invoice__c = false;
                        idToProformaForUpdateTotalComAmount.put( item.Id, item );
                    }

                }

                if( !proFormaInvoicesForDelete.isEmpty() ) delete proFormaInvoicesForDelete;

                if( !idToProformaForUpdateTotalComAmount.isEmpty() ) update idToProformaForUpdateTotalComAmount.values();

                //MRS-7157
                for (Billing_Line_Item__c hiddenBli : [SELECT Id, Pro_forma_Invoice__c, Billed__c
                                                       FROM Billing_Line_Item__c
                                                       WHERE Main_Billing_Line_Item__c IN : billingItems AND
                                                            Department_Based__c = true AND
                                                            (Pro_forma_Invoice__c != null OR Billed__c = true) AND
                                                            (Project_Profile__r.Billing_Method__c = : ProjectProfileServices.BILLINGMETHODPERCENTAGE AND Project_Profile__r.Interval__c = false)]){

                    billingItems.add(new Billing_Line_Item__c(Id = hiddenBli.Id, Pro_forma_Invoice__c = null, Billed__c = false));

                }

            update billingItems;
        if( !idToProformaForUpdateTotalComAmount.isEmpty() ) BillingLineItemServices.updateTotalCommissionableAmount( idToProformaForUpdateTotalComAmount );

        proFormaInvoicesForDelete.clear();
        for( Pro_forma_Invoice__c item: [Select Id, cl_Create_FFA_Invoice__c, Sales_Invoice__c, (Select Id From Billing_Line_Items__r) From Pro_forma_Invoice__c Where Id In: idsProformaForDelete] ){
                    if( item.Billing_Line_Items__r.isEmpty() ){
                proFormaInvoicesForDelete.add(item);
            }

                }
        if( !proFormaInvoicesForDelete.isEmpty() ) delete proFormaInvoicesForDelete;


            }

            if (serviceItemsWIthDeletedReimbursables.size() > 0) {
                update serviceItemsWIthDeletedReimbursables;

            }

            if( !billingItemsToRemove.isEmpty() ){
                delete billingItemsToRemove;


            }

            if (bliIdsToComments.size() > 0) {
                for (String bliName : bliNameToProformaName.keySet()) {
                    tasks.addall(TaskServices.createTasksForStaffAccounts(CheckServices.staffAccountantUserIds, 'Not Started', 'Normal', datetime.now(), date.today(),
                                 String.format('{0} - {1} - {2}: Task has not been completed.', new String[] { projectNumber, bliNameToProformaName.get(bliName), bliName } ),
                                 bliIdsToComments, new Map<Id, List<String>>()));

                }
                insert tasks;


            }

        } catch (Exception ex) {
            throw new ErrorException(ex.getMessage());
        }

    }

    @future
    public static void activeBillingLineItemFuture(Set<Id> taskItemIds) {
        activeBillingLineItem(taskItemIds);
    }

    public static void activeBillingLineItem(Set<Id> taskItemIds) {
        if (null == taskItemIds || taskItemIds.isEmpty())  return;

        List<Task_Item__c> taskItems = [Select Id, Service_Item__c, Billing_Percentage__c, Billing_Line_Item__c
                        From Task_Item__c
                        Where Id IN: taskItemIds];
        List<Billing_Line_Item__c> billingItems = new List<Billing_Line_Item__c>();
        Set<Id> idOfServices = new Set<Id>();

        for( Task_Item__c item: taskItems ){
            idOfServices.add( item.Service_Item__c );
        }
        Map<Id, Billing_Line_Item__c> bliIdTobli = getBillingLineItemMapByIds( idOfServices );

        for ( Task_Item__c task : taskItems ) {
            Billing_Line_Item__c bli = bliIdTobli.get(task.Billing_Line_Item__c);

            if( bli != null && !bli.isReimbursable__c ){
                if( bli.isHourlyConsulting__c &&
                    ( bli.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ||
                      ( bli.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !bli.Project_Profile__r.Interval__c ) ) ) {

                        if ( bli.Project_Profile__r.Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE && bli.Description__c != UNUSED_CONSULTING_HOURS_DESCRIPTION ){
                            bli.Active_Billing_Line_Item__c = false;
                            billingItems.add(bli);
                        }
                } else {
                    //MRS-6400
                    if ( !(bli.isHourlyConsulting__c &&
                            (bli.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ||
                            ( bli.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && bli.Project_Profile__r.Interval__c ) ) ) ){

                        if (!bli.Active_Billing_Line_Item__c) {
                            bli.Active_Billing_Line_Item__c = true;
                            bli.Quantity__c = ( ( task.Billing_Percentage__c != null) ? task.Billing_Percentage__c/100 : 0 );
                            bli.Milestone_Date__c = date.today();

                            billingItems.add( bli );

                        } else if ( bli.Pro_forma_Invoice__c != null && bli.Pro_forma_Invoice__r.Sales_Invoice__c != null ){
                            Billing_Line_Item__c newBLI = bli.clone(false, true, false, false);
                            newBLI.Is_Manualy_Created__c = false;
                            newBLI.Task_Item__c = task.Id;
                            newBLI.Pro_forma_Invoice__c = null;
                            newBLI.Billed__c = false;
                            newBLI.Milestone_Date__c = date.today();
                            newBLI.Quantity__c = ( ( task.Billing_Percentage__c != null) ? task.Billing_Percentage__c/100 : 0 );
                            newBLI.Amount__c = newBLI.Quantity__c*newBLI.Unit_Price__c;

                            billingItems.add( newBLI );
                        }else {
                            bli.Quantity__c += ( ( task.Billing_Percentage__c != null) ? task.Billing_Percentage__c/100 : 0 );
                            bli.Amount__c = bli.Quantity__c*bli.Unit_Price__c;
                            billingItems.add( bli );
                        }
                    }
                }
            }
        }

        if (billingItems.size() > 0) {
            upsert billingItems;

        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>( taskItems );
            for( Billing_Line_Item__c bli : billingItems ) {
                if( !bli.isReimbursable__c && taskItemMap.containsKey( bli.Task_Item__c ) ) {
                    taskItemMap.get( bli.Task_Item__c ).Billing_Line_Item__c = bli.Id;
                }
            }
    }
    if( !taskItems.isEmpty() ) {
                update taskItems;
        }

    }

    public static List<Billing_Line_Item__c> getBillingLineItemByTaskItemIds(Set<Id> taskItemIds) {
        if (null == taskItemIds || taskItemIds.isEmpty())  return new List<Billing_Line_Item__c>();

        return new List<Billing_Line_Item__c>([SELECT Task_Item__c, Quantity__c, Milestone_Date__c, Name, Id, Active_Billing_Line_Item__c, Billing_Date__c,
                                                      Project_Number__c, Project_Name__c, Pro_forma_Invoice__c, Pro_forma_Invoice__r.Sales_Invoice__c,
                                                      Pro_forma_Invoice__r.Name, Billed__c, Description__c, isHourlyConsulting__c,
                                                      Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c
                                               FROM Billing_Line_Item__c
                                               WHERE Task_Item__c IN: taskItemIds]);

    }

    public static Map<Id, Billing_Line_Item__c> getBillingLineItemMapByIds( Set<Id> ids ) {
        if ( null == ids || ids.isEmpty() )  return new Map<Id, Billing_Line_Item__c>();

        return new Map<Id, Billing_Line_Item__c>([SELECT Task_Item__c, Quantity__c, Unit_Price__c, Amount__c, Milestone_Date__c, Name, Id, Active_Billing_Line_Item__c, Billing_Date__c,
                                                      Project_Number__c, Project_Name__c, Pro_forma_Invoice__c, Pro_forma_Invoice__r.Sales_Invoice__c,
                                                      Pro_forma_Invoice__r.Name, Billed__c, isHourlyConsulting__c,
                                                      Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c, Service_Item__c, isReimbursable__c,
                                                      Phase__c, Product_Name__c, Purchase_Order__c, Billing_Method__c, Service_Name__c, Work_Type__c,
                              Superceded__c, Service_Item_Tax_Value_2_Sum__c, Service_Item_Tax_Value_1_Sum__c,
                              Sales_Tax_Amount_2__c, Sales_Tax_Amount_1__c, Requires_Check_Image__c, Related_Service_Item__c,
                              Project_Address__c, Not_Billable_Reason__c, Hide_from_Recap__c, GLA_Product__c, External_ID__c,
                              Description__c, cl_Credit_2_Amount__c, cl_Credit_1_Amount__c, Check_Image_Attached__c, Change_Order__c
                           FROM Billing_Line_Item__c
                                               WHERE Service_Item__c IN: ids
                                                    AND isReimbursable__c = false]);

    }

    //this method calculates amounts for BLIs creation
    public static void calculateAmountsForBLI( Project_Profile__c projectProfile, Billing_Line_Item__c billingLineItem, Task_Item__c taskItem,
                                               Billing_Date__c billingDate, Service_Item__c serviceItem, Map<String, Decimal> amountTypeToAmount ) {
        Boolean useBillingDate = false;
        //Milestone
        if( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ) {
            billingLineItem.Unit_Price__c = serviceItem.Discounted_Unit_Price__c;
            billingLineItem.Quantity__c += ( serviceItem.Quantity__c * ( taskItem.Billing_Percentage__c / 100 ) ).setScale(2);
            billingLineItem.Amount__c = ( billingLineItem.Unit_Price__c * billingLineItem.Quantity__c ).setScale(2);
            billingLineItem.Sales_Tax_Amount_1__c = ( serviceItem.Tax_Percent_1__c != null ? serviceItem.Tax_Percent_1__c * billingLineItem.Amount__c / 100 : 0.00 ).setScale(2);
            billingLineItem.Sales_Tax_Amount_2__c = ( serviceItem.Tax_Percent_2__c != null ? serviceItem.Tax_Percent_2__c * billingLineItem.Amount__c / 100 : 0.00 ).setScale(2);
        } else {
            Boolean hasUnbilledPercentage = amountTypeToAmount.get( UNBILLED_PERCENTAGE ) > 0;
            //Percentage Without Interval
            if( ( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !projectProfile.Interval__c ) &&
                ( hasUnbilledPercentage && taskItem.Billing_Percentage__c != null && taskItem.Billing_Percentage__c > 0 && projectProfile.Total_Service_Amount__c != null && projectProfile.Total_Service_Amount__c != 0 ) ) {
                    billingLineItem.Amount__c = ( ( taskItem.Billing_Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                                  ( projectProfile.Discounted_Total_Service_Amount__c - amountTypeToAmount.get( BILLED_AMOUNT ) ) ).setScale(2);
                //MRS-6398
                billingLineItem.Quantity__c = ( billingLineItem.Amount__c / projectProfile.Discounted_Total_Service_Amount__c ).setScale(2);
                billingLineItem.Sales_Tax_Amount_1__c = ( ( taskItem.Billing_Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                                          ( amountTypeToAmount.get( TOTAL_TAX1_AMOUNT ) - amountTypeToAmount.get( BILLED_TAX1_AMOUNT ) ) ).setScale(2);
                billingLineItem.Sales_Tax_Amount_2__c = ( ( taskItem.Billing_Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                                          ( amountTypeToAmount.get( TOTAL_TAX2_AMOUNT ) - amountTypeToAmount.get( BILLED_TAX2_AMOUNT ) ) ).setScale(2);
                billingLineItem.Unit_Price__c = projectProfile.Discounted_Total_Service_Amount__c;
            //Percentage With Interval and Installment
            } else if( ( ( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && projectProfile.Interval__c ) ||
                         ( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) ) &&
                       ( hasUnbilledPercentage && billingDate.Percentage__c != null && billingDate.Percentage__c > 0 && projectProfile.Total_Service_Amount__c != null && projectProfile.Total_Service_Amount__c != 0 ) ) {
                useBillingDate = true;
                billingLineItem.Amount__c = ( ( billingDate.Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                              ( projectProfile.Discounted_Total_Service_Amount__c - amountTypeToAmount.get( BILLED_AMOUNT ) ) ).setScale(2);
                billingLineItem.Quantity__c = ( billingLineItem.Amount__c / projectProfile.Discounted_Total_Service_Amount__c ).setScale(2);
                billingLineItem.Sales_Tax_Amount_1__c = ( ( billingDate.Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                                          ( amountTypeToAmount.get( TOTAL_TAX1_AMOUNT ) - amountTypeToAmount.get( BILLED_TAX1_AMOUNT ) ) ).setScale(2);
                billingLineItem.Sales_Tax_Amount_2__c = ( ( billingDate.Percentage__c / amountTypeToAmount.get( UNBILLED_PERCENTAGE ) ) *
                                                          ( amountTypeToAmount.get( TOTAL_TAX2_AMOUNT ) - amountTypeToAmount.get( BILLED_TAX2_AMOUNT ) ) ).setScale(2);
                billingLineItem.Unit_Price__c = projectProfile.Discounted_Total_Service_Amount__c;
            }

            if( billingLineItem.Quantity__c == null ) billingLineItem.Quantity__c = 0.00;
            //update values in map in case we will receive another task for the same project in the same bunch
            if( billingLineItem.Quantity__c > 0 ) {
                amountTypeToAmount.put( UNBILLED_PERCENTAGE, amountTypeToAmount.get( UNBILLED_PERCENTAGE ) - ( useBillingDate ? billingDate.Percentage__c : taskItem.Billing_Percentage__c ) );
                amountTypeToAmount.put( BILLED_AMOUNT, amountTypeToAmount.get( BILLED_AMOUNT ) + billingLineItem.Amount__c );
                amountTypeToAmount.put( BILLED_TAX1_AMOUNT, amountTypeToAmount.get( BILLED_TAX1_AMOUNT ) + billingLineItem.Sales_Tax_Amount_1__c );
                amountTypeToAmount.put( BILLED_TAX2_AMOUNT, amountTypeToAmount.get( BILLED_TAX2_AMOUNT ) + billingLineItem.Sales_Tax_Amount_2__c );

            }
        }
    }

    public static void updateBLIByMunicipalityIDForCreatedByClickLink(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap) {
        Map<Id, String> serviceItemIdToMunicipalAgency = new Map<Id, String>();
        Map<Id, String> serviceItemIdToOldMunicipalAgency = new Map<Id, String>();

        for (Service_Item__c serviceItem : newList) {
            if (serviceItem.Municipal_Agency_ID__c != oldMap.get(serviceItem.Id).Municipal_Agency_ID__c) {
                serviceItemIdToMunicipalAgency.put(serviceItem.Id, serviceItem.Municipal_Agency_ID__c);
                serviceItemIdToOldMunicipalAgency.put(serviceItem.Id, oldMap.get(serviceItem.Id).Municipal_Agency_ID__c);

            }

        }

        List<Billing_Line_Item__c> blis = BillingLineItemServices.getReimbursableCreatedByClickLinkBLIByRelatedServiceId(serviceItemIdToMunicipalAgency.keySet());

        if (blis.isEmpty()) {
            return;

        }

        for (Billing_Line_Item__c bli : blis) {
            if (serviceItemIdToMunicipalAgency.containsKey(bli.Related_Service_Item__c)) {
                 if (null == serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c) && null != serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c)) {
                    if ( !bli.Payable_Invoices__r.isEmpty() && bli.Payable_Invoices__r[0].Municipal_Agency_ID__c != null && bli.Description__c.contains(bli.Payable_Invoices__r[0].Municipal_Agency_ID__c) ){
                        bli.Description__c = bli.Description__c.replace( bli.Payable_Invoices__r[0].Municipal_Agency_ID__c, serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c) );
                    } else{
                        bli.Description__c = bli.Description__c.trim() + ' ' + serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c);
                    }

                } else if (null != serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c) && null == serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c)) {
                    if (bli.Description__c.contains(serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c))){
                        bli.Description__c = bli.Description__c.replace(' ' + serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c), '' );
                    }

                } else if (null != serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c) && null != serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c)){
                    if (bli.Description__c.contains(serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c))){
                        bli.Description__c = bli.Description__c.replace( serviceItemIdToOldMunicipalAgency.get(bli.Related_Service_Item__c), serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c) );
                    } else {
                        bli.Description__c = bli.Description__c.trim() + ' ' + serviceItemIdToMunicipalAgency.get(bli.Related_Service_Item__c);
                    }

                }

            }

        }
        update blis;

    }

    public static List<Billing_Line_Item__c> getReimbursableCreatedByClickLinkBLIByRelatedServiceId(Set<Id> relatedServiceIds) {
        if (null == relatedServiceIds || relatedServiceIds.isEmpty()) {
            return new List<Billing_Line_Item__c>();

        }

        return new List<Billing_Line_Item__c>([SELECT isReimbursable__c, Related_Service_Item__c, Id, Created_by_ClickLink__c, Description__c,
                                                      (Select Id, Municipal_Agency_ID__c From Payable_Invoices__r Limit 1)
                                               FROM Billing_Line_Item__c
                                               WHERE Related_Service_Item__c IN: relatedServiceIds AND isReimbursable__c =: true AND Created_by_ClickLink__c =: true]);

    }

    public static Billing_Line_Item__c initRemainingHoursBli( Task_Item__c taskItem, Service_Item__c serviceItem, Project_Profile__c projectProfile, Map<Id, Service_Item__c> serviceItemMap ) {
        return initRemainingHoursBli( taskItem, serviceItem, projectProfile, serviceItemMap, false );
    }

    public static Billing_Line_Item__c initRemainingHoursBli( Task_Item__c taskItem, Service_Item__c serviceItem, Project_Profile__c projectProfile, Map<Id, Service_Item__c> serviceItemMap, Boolean isCurrentlyPrebilling ) {
        if( taskItem.Hours_Remaining__c > 0 ) {
            Billing_Line_Item__c bliForHourlyConsultingRemainingHours = BillingLineItemServices.initBillingLineItem( null, taskItem, serviceItem, projectProfile, null );
            bliForHourlyConsultingRemainingHours.Active_Billing_Line_Item__c = projectProfile.Pre_billed__c;
            bliForHourlyConsultingRemainingHours.Quantity__c = taskItem.Hours_Remaining__c;
            bliForHourlyConsultingRemainingHours.Description__c = isCurrentlyPrebilling
                                                                  ? PREBILLED_HOURS_DESCRIPTION
                                                                  : UNUSED_CONSULTING_HOURS_DESCRIPTION;
            bliForHourlyConsultingRemainingHours.Unit_Price__c = serviceItemMap.get( taskItem.Service_Item__c ) != null
                                                                 ? serviceItemMap.get( taskItem.Service_Item__c ).Discounted_Unit_Price__c
                                                                 : 0.00;
            bliForHourlyConsultingRemainingHours.Amount__c = bliForHourlyConsultingRemainingHours.Quantity__c * ( serviceItemMap.get( taskItem.Service_Item__c ) != null
                                                                                                                  ? ( serviceItemMap.get( taskItem.Service_Item__c ).Discounted_Unit_Price__c != null
                                                                                                                      ? serviceItemMap.get( taskItem.Service_Item__c ).Discounted_Unit_Price__c
                                                                                                                      : 0.00 )
                                                                                                                  : 0.00 );
            bliForHourlyConsultingRemainingHours.isHourlyConsulting__c = true;
            bliForHourlyConsultingRemainingHours.Milestone_Date__c = Date.today();
            bliForHourlyConsultingRemainingHours.Product_Name__c = serviceItemMap.get( taskItem.Service_Item__c ) != null
                                                                   ? serviceItemMap.get( taskItem.Service_Item__c ).GLA_Product__r.Name
                                                                   : null;

            //MRS 6043
            if( isCurrentlyPrebilling == true ) {
                Map<String,String> userIdToTaskExtId = new Map<String, String> { 'OS404' => UserServices.getUserIdByUserName('Louis Milo'),
                                                                             'OS405' => UserServices.getUserIdByUserName('Domenick Chieco'),
                                                                             'OS406' => UserServices.getUserIdByUserName('Gustavo Mazza'),
                                                                             'OS407' => UserServices.getUserIdByUserName('William Rose'),
                                                                             'OS408' => UserServices.getUserIdByUserName('Greg Tabone') };
                if( taskItem.Task_Template__r.External_ID__c != null &&
                                            userIdToTaskExtId.get( ((String) taskItem.Task_Template__r.External_ID__c).left(5) ) != null) {
                    bliForHourlyConsultingRemainingHours.OwnerId = userIdToTaskExtId.get( ((String) taskItem.Task_Template__r.External_ID__c).left(5) );
                } else {
                    bliForHourlyConsultingRemainingHours.OwnerId = taskItem.OwnerId;
                }
            } else {
                bliForHourlyConsultingRemainingHours.OwnerId = taskItem.Hours_Reported_For__c != null
                                                           ? taskItem.Hours_Reported_For__c
                                                           : UserInfo.getUserId();
            }

            return bliForHourlyConsultingRemainingHours;
        }
        return null;
    }

    //MRS 6043
    webservice static String cloneBLI( String idx ) {
        String request = '';
        Set<String> fieldsNames = new Set<String>();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get( 'Billing_Line_Item__c' ).getDescribe().Fields.getMap();
        if( fieldsMap != null ) {
            for( Schema.SObjectField fieldsMapItem : fieldsMap.values() ) {
                Schema.DescribeFieldResult fieldDescription = fieldsMapItem.getDescribe();
                if( fieldDescription.isCreateable() ) {
                    fieldsNames.add( fieldDescription.getName() );
                }
            }
        }
        if( !fieldsNames.isEmpty() ){
            for( String s : fieldsNames) {
                request += s + ',';
            }
            if ( request.endsWith( ',' ) ) {
                request = request.substring( 0, request.lastIndexOf( ',') );
            }
        }
        Billing_Line_Item__c bliTemp = [SELECT Pro_forma_Invoice__c, Pro_forma_Invoice__r.cl_Create_FFA_Invoice__c FROM Billing_Line_Item__c WHERE Id__c =: idx];
        Billing_Line_Item__c bli = (Billing_Line_Item__c) Database.query('SELECT ' + request + ' FROM Billing_Line_Item__c WHERE Id__c = \'' + idx + '\'');
        Billing_Line_Item__c newBli = bli.clone(false, true);
        if( bli.OwnerId != null ) { // MRS-7083
            User user = [SELECT isActive FROM User WHERE Id = :bli.OwnerId];
            newBli.OwnerId = user.isActive ? bli.OwnerId : UserInfo.getUserId();
        }
        newBli.Billed__c = false;
        newBli.Pro_forma_Invoice__c = null;
        newBli.cl_Sales_Invoice_Line_Item__c = null;

        UPSERT newBli;
        return newBli.Id;
    }

    public static void updateTotalCommissionableAmount(Map<Id, Pro_forma_Invoice__c> invoices) {
         if (null == invoices || invoices.isEmpty()) {
            return;

        }

        Set<Id> recalcualtedInvoices = new Set<Id>();
        List<Pro_forma_Invoice__c> proformaToUpdate = new List<Pro_forma_Invoice__c>();

        for (AggregateResult aggItem : getAggregatedLineItemsTotalCommissionableAmountByInvoiceIds(invoices.keySet())) {
            recalcualtedInvoices.add(invoices.get((Id)aggItem.get('Pro_forma_Invoice__c')).Id);
            invoices.get((Id)aggItem.get('Pro_forma_Invoice__c')).Total_Commissionable_Amount__c = (Decimal)aggItem.get('expr0');
            proformaToUpdate.add(invoices.get((Id)aggItem.get('Pro_forma_Invoice__c')));

        }

        for (Pro_forma_Invoice__c invoice : invoices.values()) {
            if (!recalcualtedInvoices.contains(invoice.Id) && !invoice.cl_Create_FFA_Invoice__c ) {
                invoice.Total_Commissionable_Amount__c = 0.00;
                proformaToUpdate.add(invoice);

            }

        }

        update proformaToUpdate;

    }

    public static Map<Id, Pro_forma_Invoice__c> filteredItemForTotalCommissionableAmount(List<Billing_Line_Item__c> lineItems) {
        Set<Id> invoiceIds = new Set<Id>();

        for (Billing_Line_Item__c lineItem : lineItems) {
            invoiceIds.add(lineItem.Pro_forma_Invoice__c);

        }
        invoiceIds.remove(null);

        return new Map<Id, Pro_forma_Invoice__c>(ProformaInvoiceServices.getProformaInvoiceByIds(invoiceIds));

    }

    @TestVisible
    private static AggregateResult[] getAggregatedLineItemsTotalCommissionableAmountByInvoiceIds(Set<Id> invoiceIds) {
        if (null == invoiceIds || invoiceIds.isEmpty()) {
            return new AggregateResult[] { };

        }

        AggregateResult[] groupedResults = [SELECT Pro_forma_Invoice__c, SUM(Amount__c)
                                            FROM Billing_Line_Item__c
                                            WHERE Pro_forma_Invoice__c IN: invoiceIds AND isReimbursable__c =: false AND  Pro_forma_Invoice__r.cl_Create_FFA_Invoice__c =: false
                                            GROUP BY Pro_forma_Invoice__c];

        return groupedResults;

    }

    public static void updateBLIAfterAccountingBillingInfoChanged( Map<Id, Project_Profile__c> filteredProjectsMap ) {
        List<Billing_Line_Item__c> bliForUpdate = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c bliItem: [SELECT Id, Billing_Contact__c, Billing_Client__c, Accounting_Contact_Company__c, Accounting_Contact__c, Project_Profile__c
                                            FROM Billing_Line_Item__c
                                            WHERE Billed__c = false AND Project_Profile__c IN: filteredProjectsMap.keySet()]){
            Project_Profile__c project = filteredProjectsMap.get( bliItem.Project_Profile__c );

            bliItem.Billing_Contact__c = project.Billing_Company_Contact__c;
            bliItem.Billing_Client__c = project.Billing_Company_Name__c;
            bliItem.Accounting_Contact_Company__c = project.Accounting_Contact_Company__c;
            bliItem.Accounting_Contact__c = project.Accounting_Contact__c;

            bliForUpdate.add( bliItem );
        }
        try{
            update bliForUpdate;

        }catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                filteredProjectsMap.get(bliForUpdate[i].Project_Profile__c).addError( 'Can not update Billing Line Item. ' + dmlEx.getMessage() );
            }
        }
    }

    //MRS-6078
    public static void uncheckedIsActiveBLI(List<Project_Profile__c> filteredProjectsList){
        if (filteredProjectsList == null || filteredProjectsList.isEmpty()){return;}

        List<Billing_Line_Item__c> billingLineItemUpdateList = [SELECT Id, Active_Billing_Line_Item__c, Project_Profile__c
                                                                FROM Billing_Line_Item__c
                                                                WHERE Project_Profile__c IN : filteredProjectsList AND
                                                                    Billed__c = false AND
                                                                    Active_Billing_Line_Item__c = true AND
                                                                    Reimbursable_Type__c =: REIMBURSABLE_TYPE_MAILROOM];

        if (!billingLineItemUpdateList.isEmpty()){
            for (Billing_Line_Item__c bli : billingLineItemUpdateList){
                bli.Active_Billing_Line_Item__c = false;
            }
            try{
                update billingLineItemUpdateList;
            } catch (DMLException dmlEx){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    new Map<Id, Project_Profile__c>(filteredProjectsList).get(billingLineItemUpdateList[i].Project_Profile__c).addError( 'Can not update Billing Line Item. ' + dmlEx.getMessage() );
                }
            }
        }
    }

    public static void setRequiresCheckImageField( List<Billing_Line_Item__c> blis ) { //MRS-6029
        List<Billing_Line_Item__c> blisWithCheckRequests = new List<Billing_Line_Item__c>();
        Set<Id> checkRequestIds = new Set<Id>();
        for( Billing_Line_Item__c bli : blis ) {
            if( !String.isBlank( bli.Check_Request__c ) ) {
                blisWithCheckRequests.add( bli );
                checkRequestIds.add( bli.Check_Request__c );
            }
        }
        if( !checkRequestIds.isEmpty() ) {
            Map<Id, Check__c> checkRequestIdToCheckRequest = new Map<Id, Check__c>( [ SELECT Id
                                                                                      FROM Check__c
                                                                                      WHERE Requested_From__c = : CheckServices.INTERNAL
                                                                                        AND Id IN : checkRequestIds ] );
            if( !checkRequestIdToCheckRequest.keySet().isEmpty() ) {
                for( Billing_Line_Item__c bli : blisWithCheckRequests ) {
                    if( checkRequestIds.contains( bli.Check_Request__c ) ) {
                        bli.Requires_Check_Image__c = true;
                    }
                }
            }
        }
    }

    public static void setCheckImageAttachedOnRelatedBli( List<LStore__Stored_Document__c> docs ) {
        String billingLineItemObjectPrefix = Billing_Line_Item__c.sObjectType.getDescribe().getKeyPrefix();
        Map<Id, Billing_Line_Item__c> billingLineItemIdToBillingLineItem = new Map<Id, Billing_Line_Item__c>();
        for( LStore__Stored_Document__c doc : docs ) {
            if( doc.Attach_to_Invoice__c &&
                !String.isBlank( doc.LStore__Related_Object_Id__c ) &&
                String.valueOf( doc.LStore__Related_Object_Id__c ).startsWith( billingLineItemObjectPrefix ) ) {
                billingLineItemIdToBillingLineItem.put( doc.LStore__Related_Object_Id__c,
                                                        new Billing_Line_Item__c( Id = doc.LStore__Related_Object_Id__c,
                                                                                  Check_Image_Attached__c = true ) );
            }
        }
        if( !billingLineItemIdToBillingLineItem.keySet().isEmpty() ) {
            Database.update( billingLineItemIdToBillingLineItem.values(), false );
            resetRequiresCheckImageForRelatedCheckProcessingFeeBlis( billingLineItemIdToBillingLineItem.keySet() );
        }
    }

    //MRS-6910: unlock the second check processing fee BLI that is related to the same Check Request
    //          for billing on PFI Generator when an image is uploaded to the first BLI (which is reimbursable)
    public static void resetRequiresCheckImageForRelatedCheckProcessingFeeBlis( Set<Id> billingLineItemIds ) {
        List<Billing_Line_Item__c> checkImageAttachedBlis = [ SELECT Check_Request__c
                                                              FROM Billing_Line_Item__c
                                                              WHERE Id IN : billingLineItemIds
                                                              AND Check_Request__c != null ];
        Set<Id> checkRequestIds = new Set<Id>();
        for( Billing_Line_Item__c checkImageAttachedBli : checkImageAttachedBlis ) {
            checkRequestIds.add( checkImageAttachedBli.Check_Request__c );
        }
        if( !checkRequestIds.isEmpty() ) {
            List<Billing_Line_Item__c> checkProcessingFeeBlisToUpdate = new List<Billing_Line_Item__c>();
            for( Billing_Line_Item__c checkProcessingFeeBli : [ SELECT Id
                                                                FROM Billing_Line_Item__c
                                                                WHERE Check_Request__c IN : checkRequestIds
                                                                  AND Id NOT IN : checkImageAttachedBlis
                                                                  AND Is_Check_Processing_Fee__c = true
                                                                  AND Requires_Check_Image__c = true
                                                                  AND Check_Image_Attached__c = false ] ) {
                checkProcessingFeeBlisToUpdate.add( new Billing_Line_Item__c( Id = checkProcessingFeeBli.Id,
                                                                              Requires_Check_Image__c = false ) );
                if( !checkProcessingFeeBlisToUpdate.isEmpty() ) {
                    Database.update( checkProcessingFeeBlisToUpdate, false );
                }
            }
        }
    }

    //MRS-6242
    public static void deactivateIsReimbursableNoAfterPrebiled(List<Billing_Line_Item__c> newBillingLineItemList){
        if ( !ProjectProfileServices.isAllowedPreBillGenerated ){
            for (Billing_Line_Item__c billingLineItem : newBillingLineItemList){
                if (billingLineItem.isReimbursable__c && billingLineItem.No_Reimbursables_After_Pre_Bill__c){
                    billingLineItem.Active_Billing_Line_Item__c = false;
                }
            }
        }
    }

    //MRS-6766
    public static List<Billing_Line_Item__c> filterBlisForCreatingCheckProcessingBli( List<Billing_Line_Item__c> blis ) {
        List<Billing_Line_Item__c> filteredBlis = new List<Billing_Line_Item__c>();
        for( Billing_Line_Item__c bli : blis ) {
            System.debug( LoggingLevel.Error, 'xxx bli.Check_Request__c: ' + bli.Check_Request__c );
            System.debug( LoggingLevel.Error, 'xxx bli.Add_Check_Processing_Fee__c: ' + bli.Add_Check_Processing_Fee__c );
            if( bli.Check_Request__c != null && bli.Add_Check_Processing_Fee__c ) {
                filteredBlis.add( bli );
            }
        }
        System.debug( LoggingLevel.Error, 'xxx filteredBlis: ' + filteredBlis.size() );
        return filteredBlis;
    }

    //MRS-6766
    public static void createCheckProcessingFeeBli( List<Billing_Line_Item__c> blis ) {
        System.debug( LoggingLevel.Error, 'xxx blis: ' + blis );
        List<Billing_Line_Item__c> checkProcessingFeeBlis = new List<Billing_Line_Item__c>();

        Boolean isNeeded = false;
        String processingFeeGla;
        Decimal checkAmount;

        DateTime lastCreatedDate;
        for( Check_Processing_Fee__c setting : Check_Processing_Fee__c.getall().values() ) {
            System.debug( LoggingLevel.Error, 'xxx setting: ' + setting );
            if( lastCreatedDate == null || setting.CreatedDate > lastCreatedDate ) {
                lastCreatedDate = setting.CreatedDate;
                isNeeded = setting.Charge_Check_Processing_Fee__c;
                processingFeeGla = setting.Processing_Fee_GLA__c;
                checkAmount = setting.Processing_Fee_Amount__c;
            }
        }

        System.debug( LoggingLevel.Error, 'xxx isNeeded: ' + isNeeded );
        System.debug( LoggingLevel.Error, 'xxx checkAmount: ' + checkAmount );
        System.debug( LoggingLevel.Error, 'xxx processingFeeGla: ' + processingFeeGla );
        if( isNeeded == true && checkAmount != null && processingFeeGla != null ) {
            for( Billing_Line_Item__c bli : blis ) {
                Billing_Line_Item__c clonedBli = bli.clone();
                System.debug( LoggingLevel.Error, 'xxx clonedBli: ' + clonedBli );
                clonedBli.Add_Check_Processing_Fee__c = false;
                clonedBli.Is_Check_Processing_Fee__c = true;
        clonedBli.Is_Manualy_Created__c = false;
                clonedBli.Amount__c = checkAmount;
                clonedBli.IsMunicipalFee__c = false;
                clonedBli.Description__c = 'Check Processing Fee';
                clonedBli.Product_Name__c = processingFeeGla;
                clonedBli.Unit_Price__c = checkAmount;
                clonedBli.Purchase_Order__c = null; //MRS 7281
                clonedBli.isReimbursable__c = false;
                System.debug( LoggingLevel.Error, 'xxx clonedBli: ' + clonedBli );
                checkProcessingFeeBlis.add( clonedBli );
            }
        }

        if( !checkProcessingFeeBlis.isEmpty() ) {
            INSERT checkProcessingFeeBlis;
        }
    }

    //MRS-7067
    public static List<Billing_Line_Item__c> filteredBLIWithBillingDate(List<Billing_Line_Item__c> bliList, Map<Id, Billing_Line_Item__c> bliMap){
        List<Billing_Line_Item__c> filteredList = new List<Billing_Line_Item__c>();

        for (Billing_Line_Item__c bli : (bliList != null) ? bliList : bliMap.values()){
            if ( bli.Billing_Date__c != null && ((bliList == null || bliMap == null) || (bli.Amount__c != bliMap.get(bli.Id).Amount__c || bliMap.get(bli.Id).Billing_Date__c == null)) ){
                filteredList.add(bli);
            }
        }

        return filteredList;
    }

    public static void updateBillingDateAmount(List<Billing_Line_Item__c> bliList, Boolean isDelete){
        if (bliList == null || bliList.isEmpty()) return ;

        Map<Id, Billing_Date__c> billingDateUpdateMap = new Map<Id, Billing_Date__c>();

        for (Billing_Line_Item__c bli : bliList){
            billingDateUpdateMap.put(bli.Billing_Date__c, new Billing_Date__c(Id = bli.Billing_Date__c, Amount__c = !isDelete ? bli.Amount__c : 0));
        }

        try{
            update billingDateUpdateMap.values();
        } catch (DMLException dmlEx){
            if (isDelete){
                throw new ErrorException('Can not update Billing Date Amount: ' + dmlEx.getMessage());
            } else {
                for( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Id billingDateId = billingDateUpdateMap.values()[dmlEx.getDmlIndex(i)].Id;
                    for (Billing_Line_Item__c bli : bliList){
                        if (bli.Billing_Date__c == billingDateId){
                            bli.addError('Can not update Billing Date Amount: ' + dmlEx.getMessage());
                        }
                    }
                }
            }
        }
    }

    //MRS-6237
    public static List<Billing_Line_Item__c> filteredBLIWithNewPFIpopulated( List<Billing_Line_Item__c> newBLIs, Map<Id, Billing_Line_Item__c> oldBLIs ) {
        List<Billing_Line_Item__c> filteredBLIIWithNewPFIpopulated = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c item: newBLIs ) {
            if( item.Quantity_for_FF__c == 0 && !item.Department_Based__c && item.Pro_forma_Invoice__c != null && item.Pro_forma_Invoice__c != oldBLIs.get(item.Id).Pro_forma_Invoice__c ){
                filteredBLIIWithNewPFIpopulated.add( item );
            }
        }

        return filteredBLIIWithNewPFIpopulated;
    }

    //MRS-7262
    public static List<Billing_Line_Item__c> filteredBLIWithChangedActive( List<Billing_Line_Item__c> newBLIs, Map<Id, Billing_Line_Item__c> oldBLIs ) {
        List<Billing_Line_Item__c> filteredBLIIWithNewPFIpopulated = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c item: newBLIs ) {
            if( item.Quantity_for_FF__c == 0 && !item.Department_Based__c && item.Active_Billing_Line_Item__c != oldBLIs.get(item.Id).Active_Billing_Line_Item__c ){
                filteredBLIIWithNewPFIpopulated.add( item );
            }
        }

        return filteredBLIIWithNewPFIpopulated;
    }

    //MRS-7262
    public static void setPFItoHiddenBLIs( List<Billing_Line_Item__c> bliListChangedPFI, List<Billing_Line_Item__c> bliListChangedActive ){
        if( ( bliListChangedPFI == null || bliListChangedPFI.isEmpty() ) && ( bliListChangedActive == null || bliListChangedActive.isEmpty() ) ) return ;

        Map<Id, Billing_Line_Item__c> bliMapChangedPFI    = new Map<Id, Billing_Line_Item__c>( (bliListChangedPFI == null)    ? new List<Billing_Line_Item__c>() : bliListChangedPFI );
        Map<Id, Billing_Line_Item__c> bliMapChangedActive = new Map<Id, Billing_Line_Item__c>( (bliListChangedActive == null) ? new List<Billing_Line_Item__c>() : bliListChangedActive );

        List<Billing_Line_Item__c> bliListForUpdate = new List<Billing_Line_Item__c>();

        for( Billing_Line_Item__c item: [SELECT Id, Main_Billing_Line_Item__c, Billed__c, Department_Based__c, Pro_forma_Invoice__c, Active_Billing_Line_Item__c,
                                            (Select Id, Main_Billing_Line_Item__c, Billed__c, Department_Based__c, Pro_forma_Invoice__c, Active_Billing_Line_Item__c
                                             From Department_Billing_Line_Items__r)
                                         FROM Billing_Line_Item__c
                                         WHERE Id IN : bliMapChangedPFI.keySet() OR
                                               Id IN : bliMapChangedActive.keySet()]){

            for( Billing_Line_Item__c itemChild: item.Department_Billing_Line_Items__r ){
                bliListForUpdate.add( itemChild );
                //PFI changed on the Parrent BLI.
                if (bliMapChangedPFI.containsKey(item.Id)){
                    itemChild.Pro_forma_Invoice__c = item.Pro_forma_Invoice__c;
                    itemChild.Billed__c            = item.Billed__c;
                }
                //Active_Billing_Line_Item__c changed on the parrent BLI.
                if (bliMapChangedActive.containsKey(item.Id)){
                    itemChild.Active_Billing_Line_Item__c = item.Active_Billing_Line_Item__c;
                }
            }
        }

        try{
            update bliListForUpdate;
        } catch ( DMLException dmlEx ){
            for( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                Id billingLineItemId = bliListForUpdate[dmlEx.getDmlIndex(i)].Main_Billing_Line_Item__c;
                Billing_Line_Item__c parentBLIWithError = bliMapChangedPFI.containsKey(billingLineItemId) ? bliMapChangedPFI.get(billingLineItemId) : bliMapChangedActive.get(billingLineItemId);
                parentBLIWithError.addError('Can not update Hidden BLIs: ' + dmlEx.getMessage());
            }
        }
    }

}