public with sharing class ScheduledBillingJobController {
    public Boolean isWeekly { get; set; }
    public Boolean isMonthly { get; set; }
    public Boolean isMonday { get; set; }
    public Boolean isTuesday { get; set; }
    public Boolean isWednesday { get; set; }
    public Boolean isThursday { get; set; }
    public Boolean isFriday { get; set; }
    public Boolean isOnDayInMonth { get{ if( isOnDayInMonth  == null) isOnDayInMonth = true; return isOnDayInMonth; } set; }
    public Boolean isOnDateInMonth { get; set; }

    private Boolean jobIsInProgress;
    private String minHoursTime;
    private String minHoursTimeForPost;

    private Integer nextFireTimeHour;
    private Integer nextFireTimeHourDaily;

    public class CronTriggerWrapper {
        public CronTrigger record;

        public transient String jobName;
        public String getJobName() {
            return ( this.record != null && this.record.CronJobDetail.Name != null )
                   ? this.record.CronJobDetail.Name
                   : '';
        }

        public transient String CronExpression;
        public String getCronExpression() {
            return ( this.record != null && this.record.CronExpression != null )
                   ? this.record.CronExpression
                   : '';
        }

        public transient String startTime;
        public String getStartTime() {
            return ( this.record != null && this.record.StartTime != null )
                   ? this.record.StartTime.format( DateUtils.DATETIME_USER_FRIENDLY_FORMAT )
                   : '';
        }

        public transient String previousFireTime;
        public String getPreviousFireTime() {
            return ( this.record != null && this.record.PreviousFireTime != null )
                   ? this.record.PreviousFireTime.format( DateUtils.DATETIME_USER_FRIENDLY_FORMAT )
                   : '';
        }

        public transient String nextFireTime;
        public String getNextFireTime() {
            return ( this.record != null && this.record.NextFireTime != null )
                   ? this.record.NextFireTime.format( DateUtils.DATETIME_USER_FRIENDLY_FORMAT )
                   : '';
        }

        public CronTriggerWrapper( CronTrigger cronTriggerRecord ) {
            this.record = cronTriggerRecord;
        }
    }

    public List<CronTriggerWrapper> billingJob {
        get {
            if( billingJob == null ) {
                billingJob = new List<CronTriggerWrapper>();
            }
            return billingJob;
        }
        set;
    }

    public List<CronTriggerWrapper> billingJobDaily {
        get {
            if( billingJobDaily == null ) {
                billingJobDaily = new List<CronTriggerWrapper>();
            }
            return billingJobDaily;
        }
        set;
    }

    public void getBillingJob() {
        billingJob = null;
        billingJobDaily = null;
        Integer dayOfJob = 0;
        for( CronTrigger cronTriggerRecord : [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name, StartTime, PreviousFireTime, NextFireTime, EndTime
                                               FROM CronTrigger
                                               WHERE CronJobDetail.Name =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_FFA_SALES_INVOICES OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES OR
                                                     CronJobDetail.Name =: DDPHelperServices.SEND_PROFORMA_INVOICES
                                               ORDER BY NextFireTime
                                               LIMIT 6 ] ) {
            if( cronTriggerRecord.CronJobDetail.Name == DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB ) nextFireTimeHour = cronTriggerRecord.NextFireTime.hour();
            if( dayOfJob == 0 ) dayOfJob = cronTriggerRecord.NextFireTime.day();
            jobIsInProgress = ( dayOfJob == cronTriggerRecord.NextFireTime.day() ) ? false : true;
            billingJob.add( new CronTriggerWrapper( cronTriggerRecord ) );
        }
        Integer dayOfJobDaily = 0;
        for( CronTrigger cronTriggerRecord : [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name, StartTime, PreviousFireTime, NextFireTime, EndTime
                                               FROM CronTrigger
                                               WHERE CronJobDetail.Name =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_DAILY OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST_DAILY OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_FFA_SALES_INVOICES_DAILY OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES_DAILY OR
                                                     CronJobDetail.Name =: DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES_DAILY OR
                                                     CronJobDetail.Name =: DDPHelperServices.SEND_PROFORMA_INVOICES_DAILY
                                               ORDER BY NextFireTime
                                               LIMIT 6 ] ) {
            if( cronTriggerRecord.CronJobDetail.Name == DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_DAILY ) nextFireTimeHourDaily = cronTriggerRecord.NextFireTime.hour();
            if( dayOfJobDaily == 0 ) dayOfJobDaily = cronTriggerRecord.NextFireTime.day();
            jobIsInProgress = ( dayOfJobDaily == cronTriggerRecord.NextFireTime.day() ) ? false : true;
            billingJobDaily.add( new CronTriggerWrapper( cronTriggerRecord ) );
        }
    }

    public String dateTim{
       get
        {
           if( dateTim == null )
               dateTim = '10';
           return dateTim;
        }
        set;
    }

    public String dateTimDaily{
       get
        {
           if( dateTimDaily == null )
               dateTimDaily = '21';
           return dateTimDaily;
        }
        set;
    }

    public List<SelectOption> getdateTimOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '0','12:00 AM' ) );
        for( Integer i = 1; i < 12; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i) + ':00 AM' ) );
        }
        options.add( new SelectOption( '12','12:00 PM' ) );
        for( Integer i = 13; i < 23; i++ ){
            if( i != 18 && i != 19 && i != 20 ) options.add( new SelectOption( String.valueOf(i),String.valueOf(i - 12) + ':00 PM' ) );
        }
        return options;
    }

    public List<SelectOption> getdateTimDailyOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '0','12:00 AM' ) );
        for( Integer i = 1; i < 12; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i) + ':00 AM' ) );
        }
        options.add( new SelectOption( '12','12:00 PM' ) );
        for( Integer i = 13; i < 23; i++ ){
            if( i != 18 && i != 19 && i != 20 ) options.add( new SelectOption( String.valueOf(i),String.valueOf(i - 12) + ':00 PM' ) );
        }
        return options;
    }

    public String dayInMonth{
       get
        {
           if( dayInMonth == null )
               dayInMonth = '1';
           return dayInMonth;
        }
        set;
    }

    public List<SelectOption> getdayInMonthOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for( Integer i = 1; i < 32; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i) ) );
        }
        options.add( new SelectOption( 'L','last' ) );
        return options;
    }

    public String dayOfWeekInMonth{
       get
        {
           if( dayOfWeekInMonth == null )
               dayOfWeekInMonth = '1';
           return dayOfWeekInMonth;
        }
        set;
    }

    public List<SelectOption> getdayOfWeekInMonthOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '1','the 1st' ) );
        options.add( new SelectOption( '2','the 2nd' ) );
        options.add( new SelectOption( '3','the 3rd' ) );
        options.add( new SelectOption( '4','the 4th' ) );
        options.add( new SelectOption( 'L','the last' ) );
        return options;
    }

    public String dayInWeek{
       get
        {
           if( dayInWeek == null )
               dayInWeek = '1';
           return dayInWeek;
        }
        set;
    }

    public List<SelectOption> getdayInWeekOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '2','Monday' ) );
        options.add( new SelectOption( '3','Tuesday' ) );
        options.add( new SelectOption( '4','Wednesday' ) );
        options.add( new SelectOption( '5','Thursday' ) );
        options.add( new SelectOption( '6','Friday' ) );
        return options;
    }

    private Map<Id, User> usersMap = new Map<Id, User>();

    public ScheduledBillingJobController(){
        getBillingJob();
        getCronTab();

        getBillingJobES();
        getCronTabES();


        selectedUsers = new List<SelectOption>();
        selectedUsersES = new List<SelectOption>();
        allUsers = new List<SelectOption>();

        for ( User u : [SELECT Name, Id, Email FROM User Where isActive = true Order by Name] ) {
            allUsers.add( new SelectOption( u.Id, u.Name ) );
            usersMap.put( u.Id, u );
        }

        if( ddpHelper.Id != null && ddpHelper.Text1__c != null ){
            for( String item: ddpHelper.Text1__c.split(',',1000) ){
                if(usersMap.get( item ) != null) selectedUsers.add( new SelectOption( item, usersMap.get( item ).Name ) );
            }
        }

        if( ddpHelper.Id != null && ddpHelper.Text5__c != null ){
            for( String item: ddpHelper.Text5__c.split(',',1000) ){
                if(usersMap.get( item ) != null) selectedUsersES.add( new SelectOption( item, usersMap.get( item ).Name ) );
            }
        }
    }

    public PageReference WeeklyPanel() {
        isMonthly = !isWeekly;
        return null;
    }

    public PageReference MonthlyPanel() {
        isWeekly = !isMonthly;
        return null;
    }

    public PageReference onDayOfEveryMonth() {
        isOnDateInMonth = !isOnDayInMonth;
        return null;
    }

    public PageReference onOfEveryMonth() {
        isOnDayInMonth = !isOnDateInMonth;
        return null;
    }

    public PageReference abortJob() {
        if( jobIsInProgress ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please wait until Billing Job is completed.' ) );
                return null;
        }
        for( CronTriggerWrapper cronTriggerWrapperItem : billingJob ) {
            System.abortJob( cronTriggerWrapperItem.record.Id );
        }
        getBillingJob();
        return null;
    }

    public PageReference abortJobDaily() {
        if( jobIsInProgress ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please wait until Billing Job is completed.' ) );
                return null;
        }
        for( CronTriggerWrapper cronTriggerWrapperItem : billingJobDaily ) {
            System.abortJob( cronTriggerWrapperItem.record.Id );
        }
        getBillingJob();
        return null;
    }

    public PageReference startJob() {
        if( Integer.valueOf(dateTim) == nextFireTimeHourDaily ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please select another hour. Other Billing job is scheduled for that time.' ) );
                return null;
        }

        System.schedule( DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB, '0 0 6 ? * 2,3,4,5,6', new CreateProformaInvoicesBatch( false ) );
        System.schedule( DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES, '0 10 6 ? * 2,3,4,5,6', new CreatePDFsForProformaInvoices() );
        System.schedule( DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES, '0 20 6 ? * 2,3,4,5,6', new CreatePDFsForGroupingInvoices() );

        if( ddpHelper.Create_FFA_Invoice__c ){
            System.schedule( DDPHelperServices.CREATE_FFA_SALES_INVOICES, '0 21 6 ? * 2,3,4,5,6', new CreateFFASalesInvoices() );
            System.schedule( DDPHelperServices.SEND_PROFORMA_INVOICES, '0 58 6 ? * 2,3,4,5,6', new CreateJobSendEmailInvoices() );
        	System.schedule( DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST, '0 59 7 ? * 2,3,4,5,6', new CreateBatchSalesInvoicesPost() );
        }
        if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
        upsert ddpHelper;

        getBillingJob();
        getCronTab();
        return null;
    }

    public PageReference startJobDaily() {
        if( Integer.valueOf(dateTimDaily) == nextFireTimeHour ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please select another hour. Other Billing job is scheduled for that time.' ) );
                return null;
        }

        System.schedule( DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_DAILY, '0 0 21 ? * 1,2,3,4,5,6,7', new CreateProformaInvoiceBatchJobDaily() );
        System.schedule( DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES_DAILY, '0 10 21 ? * 1,2,3,4,5,6,7', new CreatePDFsForProformaInvoices() );
        System.schedule( DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES_DAILY, '0 20 21 ? * 1,2,3,4,5,6,7', new CreatePDFsForGroupingInvoices() );

        if( ddpHelper.Create_FFA_Invoice__c ){
            System.schedule( DDPHelperServices.CREATE_FFA_SALES_INVOICES_DAILY, '0 21 21 ? * 1,2,3,4,5,6,7', new CreateFFASalesInvoices() );
            System.schedule( DDPHelperServices.SEND_PROFORMA_INVOICES_DAILY, '0 58 21 ? * 1,2,3,4,5,6,7', new CreateJobSendEmailInvoices() );
            System.schedule( DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST_DAILY, '0 59 22 ? * 1,2,3,4,5,6,7', new CreateBatchSalesInvoicesPost() );
        }
        if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
        upsert ddpHelper;

        getBillingJob();
        getCronTab();
        return null;
    }

    public PageReference scheduleJob() {
        if( Integer.valueOf(dateTim) == nextFireTimeHourDaily ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please select another hour. Other Billing job is scheduled for that time.' ) );
                return null;
        }

        if( jobIsInProgress ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please wait until Billing Job is completed.' ) );
                return null;
        }

        try{
            minHoursTime = '0 0 ';
            minHoursTime += dateTim + ' ';
            if( isWeekly ){
                minHoursTime += '? * ';
                if( !isMonday && !isTuesday && !isWednesday && !isThursday && !isFriday  ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Please select at least one day.' ) );
                    return null;
                } else {
                    if( isMonday ) minHoursTime += '2,';
                    if( isTuesday )  minHoursTime += '3,';
                    if( isWednesday ) minHoursTime += '4,';
                    if( isThursday ) minHoursTime += '5,';
                    if( isFriday ) minHoursTime += '6,';
                    minHoursTime = minHoursTime.removeEnd(',');
                }
                isOnDayInMonth = true;
                isOnDateInMonth = false;
                dayInMonth = '1';
                dayOfWeekInMonth = 'the 1st';
                dayInWeek = 'Monday';
            } else {
                isMonday = false;
                isTuesday = false;
                isWednesday = false;
                isThursday = false;
                isFriday = false;
                if( isOnDayInMonth ){
                    minHoursTime += dayInMonth;
                    minHoursTime += ' */1 ?';
                    dayOfWeekInMonth = 'the 1st';
                    dayInWeek = 'Monday';
                } else {
                    minHoursTime += '? * ';
                    minHoursTime += dayInWeek + '#' + dayOfWeekInMonth;
                    dayInMonth = '1';
                }
            }
	    
	    minHoursTimeForPost = minHoursTime.replaceFirst(dateTim,String.valueOf(Integer.valueOf(dateTim)+1));
	    
            for( CronTriggerWrapper cronTriggerWrapperItem : billingJob ) {
                System.abortJob( cronTriggerWrapperItem.record.Id );
            }

            System.schedule( DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB, minHoursTime , new CreateProformaInvoicesBatch( false ) );
            System.schedule( DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES, minHoursTime.substring(0,1) + ' 10' + minHoursTime.substring(3,minHoursTime.length()), new CreatePDFsForProformaInvoices() );
            System.schedule( DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES, minHoursTime.substring(0,1) + ' 20' + minHoursTime.substring(3,minHoursTime.length()), new CreatePDFsForGroupingInvoices() );

            if( ddpHelper.Create_FFA_Invoice__c ){
                System.schedule( DDPHelperServices.CREATE_FFA_SALES_INVOICES, minHoursTime.substring(0,1) + ' 21' + minHoursTime.substring(3,minHoursTime.length()), new CreateFFASalesInvoices() );
        if( ddpHelper.Email_Invoices__c ) System.schedule( DDPHelperServices.SEND_PROFORMA_INVOICES, minHoursTime.substring(0,1) + ' 58' + minHoursTime.substring(3,minHoursTime.length()), new CreateJobSendEmailInvoices() );
                System.schedule( DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST, minHoursTimeForPost.substring(0,1) + ' 59' + minHoursTimeForPost.substring(3,minHoursTime.length()), new CreateBatchSalesInvoicesPost() );
            }

            if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
            upsert ddpHelper;

            getBillingJob();
            getCronTab();

        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please contact your administrator. Error occured via rescheduling Billing job. ' + e ) );
        }
        return null;
    }

    public PageReference scheduleJobDaily() {
        if( Integer.valueOf(dateTimDaily) == nextFireTimeHour ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please select another hour. Other Billing job is scheduled for that time.' ) );
                return null;
        }

        if( jobIsInProgress ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please wait until Billing Job is completed.' ) );
                return null;
        }

        try{
            minHoursTime = '0 0 ';
	    minHoursTime += dateTimDaily + ' ? * 1,2,3,4,5,6,7 ';
	    minHoursTimeForPost = minHoursTime.replaceFirst(dateTimDaily,String.valueOf(Integer.valueOf(dateTimDaily)+1));
	    
            for( CronTriggerWrapper cronTriggerWrapperItem : billingJobDaily ) {
                System.abortJob( cronTriggerWrapperItem.record.Id );
            }

            System.schedule( DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_DAILY, minHoursTime , new CreateProformaInvoiceBatchJobDaily() );
            System.schedule( DDPHelperServices.CREATE_PDFS_FOR_PROFORMA_INVOICES_DAILY, minHoursTime.substring(0,1) + ' 10' + minHoursTime.substring(3,minHoursTime.length()), new CreatePDFsForProformaInvoices() );
            System.schedule( DDPHelperServices.CREATE_PDFS_FOR_GROUPING_INVOICES_DAILY, minHoursTime.substring(0,1) + ' 20' + minHoursTime.substring(3,minHoursTime.length()), new CreatePDFsForGroupingInvoices() );

            if( ddpHelper.Create_FFA_Invoice__c ){
                System.schedule( DDPHelperServices.CREATE_FFA_SALES_INVOICES_DAILY, minHoursTime.substring(0,1) + ' 21' + minHoursTime.substring(3,minHoursTime.length()), new CreateFFASalesInvoices() );
                        if( ddpHelper.Email_Invoices__c ) System.schedule( DDPHelperServices.SEND_PROFORMA_INVOICES_DAILY, minHoursTime.substring(0,1) + ' 58' + minHoursTime.substring(3,minHoursTime.length()), new CreateJobSendEmailInvoices() );
                System.schedule( DDPHelperServices.CREATE_BATCH_SALES_INVOICES_POST_DAILY, minHoursTimeForPost.substring(0,1) + ' 59' + minHoursTimeForPost.substring(3,minHoursTime.length()), new CreateBatchSalesInvoicesPost() );
            }

            if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
            upsert ddpHelper;

            getBillingJob();
            getCronTab();

        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please contact your administrator. Error occured via rescheduling Billing job. ' + e ) );
        }
        return null;
    }

    public PageReference getCronTab() {
        if( !billingJobDaily.isEmpty() ) {
            List<String> cronExpressionListDaily = billingJobDaily[0].record.CronExpression.split(' ', 7);
            dateTimDaily = cronExpressionListDaily[2];
        }
        if( !billingJob.isEmpty() ) {
            List<String> cronExpressionList = billingJob[0].record.CronExpression.split(' ', 7);
            dateTim = cronExpressionList[2];

            if( !cronExpressionList[3].equals('?') && !cronExpressionList[5].contains('#') && cronExpressionList[4].contains('/1') ){
                isOnDayInMonth = true;
                dayInMonth = cronExpressionList[3];
                isMonthly = true;
                isOnDayInMonth = true;
                isOnDateInMonth = false;
            }else if ( cronExpressionList[5].contains('#') ) {
                dayOfWeekInMonth = cronExpressionList[5].substringAfter('#');
                dayInWeek = cronExpressionList[5].substringBefore('#');
                isMonthly = true;
                isOnDateInMonth = true;
                isOnDayInMonth = false;
            } else {
                if( cronExpressionList[5].contains('2') ) isMonday = true;
                if( cronExpressionList[5].contains('3') ) isTuesday = true;
                if( cronExpressionList[5].contains('4') ) isWednesday = true;
                if( cronExpressionList[5].contains('5') ) isThursday = true;
                if( cronExpressionList[5].contains('6') ) isFriday = true;
                isWeekly = true;
            }

        }
        return null;
    }

    //For Multiselect Users
    public DDP_Helper__c ddpHelper {
        get{
            if ( ddpHelper == null ) {
                List<DDP_Helper__c> ddpHelperList = [Select Id, Type__c, Text1__c, Text2__c, Text5__c, Text4__c, Create_FFA_Invoice__c, Email_Invoices__c,
                                                        Automatically_Email_Statements__c, Exclude_Unapplied_Documents__c,
                                                        Is_Day_Of_Month__c, Day_Of_Month__c, Sunday_Or_Saturday__c, Number_Week__c, Email_Statements_Job_Hour__c
                                                    From DDP_Helper__c
                                                    Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1];
                if ( !ddpHelperList.isEmpty() ) {
                    ddpHelper = ddpHelperList[0];
                    if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
                }else{
                    ddpHelper = new DDP_Helper__c( Type__c = DDPHelperServices.TYPE_BILLING_JOB_SUPPORT,
                                                   Text1__c = '', Text2__c = '', Text5__c = '', Text4__c = '',
                                                   Automatically_Email_Statements__c = false,
                                                   Exclude_Unapplied_Documents__c = true,
                                                   Is_Day_Of_Month__c = false,
                                                   Day_Of_Month__c = '1',
                                                   Sunday_Or_Saturday__c = '2',
                                                   Number_Week__c = 'the 2nd',
                                                   Email_Statements_Job_Hour__c = '18');
                }
            }
            return ddpHelper;
        }
        set;
    }
    public SelectOption[] selectedUsers { get; set; }
    public SelectOption[] selectedUsersES { get; set; }
    public SelectOption[] allUsers { get; set; }

    public String message { get; set; }

    public PageReference applyChanges() {
        ddpHelper.Text1__c = '';
        ddpHelper.Text2__c = '';
        if( !ddpHelper.Create_FFA_Invoice__c ) ddpHelper.Email_Invoices__c = false;
        Boolean first = true;
        for ( SelectOption so : selectedUsers ) {
            if (!first) {
                ddpHelper.Text1__c += ',';
                ddpHelper.Text2__c += ',';
            }
            ddpHelper.Text1__c += so.getValue();
            ddpHelper.Text2__c += usersMap.get( so.getValue() ).Email;
            first = false;
        }
        upsert ddpHelper;
        return null;
    }

    //Email Statements functionality

    public String dateTimES{
       get
        {
           if( dateTimES == null )
               dateTimES = '18';
           return dateTimES;
        }
        set;
    }

    public Boolean isOnDayInMonthES { get{ if( isOnDayInMonthES  == null) isOnDayInMonthES = true; return isOnDayInMonthES; } set; }
    public Boolean isOnDateInMonthES { get; set; }

    public PageReference onDayOfEveryMonthES() {
        isOnDateInMonthES = !isOnDayInMonthES;
        return null;
    }

    public PageReference onOfEveryMonthES() {
        isOnDayInMonthES = !isOnDateInMonthES;
        return null;
    }

    public List<SelectOption> getdateTimESOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '0','12:00 AM' ) );
        for( Integer i = 1; i < 12; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i) + ':00 AM' ) );
        }
        options.add( new SelectOption( '12','12:00 PM' ) );
        for( Integer i = 13; i < 24; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i - 12) + ':00 PM' ) );
        }
        return options;
    }

    public String dayInMonthES{
       get
        {
           if( dayInMonthES == null )
               dayInMonthES = '1';
           return dayInMonthES;
        }
        set;
    }

    public List<SelectOption> getdayInMonthESOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for( Integer i = 1; i < 32; i++ ){
            options.add( new SelectOption( String.valueOf(i),String.valueOf(i) ) );
        }
        options.add( new SelectOption( 'L','last' ) );
        return options;
    }

    public String dayOfWeekInMonthES{
       get
        {
           if( dayOfWeekInMonthES == null )
               dayOfWeekInMonthES = '1';
           return dayOfWeekInMonthES;
        }
        set;
    }

    public List<SelectOption> getdayOfWeekInMonthESOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '1','the 1st' ) );
        options.add( new SelectOption( '2','the 2nd' ) );
        options.add( new SelectOption( '3','the 3rd' ) );
        options.add( new SelectOption( '4','the 4th' ) );
        options.add( new SelectOption( 'L','the last' ) );
        return options;
    }

    public String dayInWeekES{
       get
        {
           if( dayInWeekES == null )
               dayInWeekES = '1';
           return dayInWeekES;
        }
        set;
    }

    public List<SelectOption> getdayInWeekESOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '1','Sunday' ) );
        options.add( new SelectOption( '7','Saturday' ) );
        return options;
    }

    public List<CronTriggerWrapper> billingJobES {
        get {
            if( billingJobES == null ) {
                billingJobES = new List<CronTriggerWrapper>();
            }
            return billingJobES;
        }
        set;
    }

    public void getBillingJobES() {
        billingJobES = null;
        for( CronTrigger cronTriggerRecord : [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name, StartTime, PreviousFireTime, NextFireTime, EndTime
                                               FROM CronTrigger
                                               WHERE CronJobDetail.Name =: 'Email Statements Job' OR
					       		CronJobDetail.Name =: 'Email Statements Job Preparations'	
                                               ORDER BY NextFireTime
                                               LIMIT 2 ] ) {
            billingJobES.add( new CronTriggerWrapper( cronTriggerRecord ) );
        }
    }

    public PageReference startJobEmailStatements() {
        if( ddpHelper.Automatically_Email_Statements__c ){

            isOnDateInMonthES = true;
            ddpHelper.Is_Day_Of_Month__c = isOnDayInMonthES = false;
            ddpHelper.Email_Statements_Job_Hour__c = dateTimES = '18';
            ddpHelper.Day_Of_Month__c = dayInMonthES = '1';
            ddpHelper.Sunday_Or_Saturday__c = dayInWeekES = '7';
            ddpHelper.Number_Week__c = dayOfWeekInMonthES = '2';

            DDPHelperServices.calculateExecutionDateForDDP(ddpHelper, DateTime.now(), true);

            System.schedule( 'Email Statements Job', '0 0 18 ? * *', new CreateBatchStatementOfAccountsEmail() );
            System.schedule( 'Email Statements Job Preparations', '0 1 17 ? * *' , new CreateBatchNumberOfStatements() );
        } else {
            ddpHelper.Email_Statements_Job_Ex_DateTime__c = null;
            getBillingJobES();
            for( CronTriggerWrapper cronTriggerWrapperItem : billingJobES ) {
                System.abortJob( cronTriggerWrapperItem.record.Id );
            }
        }
        ddpHelper.Exclude_Unapplied_Documents__c = true;
        upsert ddpHelper;
        getBillingJobES();
        getCronTabES();

        return null;
    }

    private String minHoursTimeES;
    private String minHoursTimeESForPreparations;

    public PageReference applyChangesES() {
        try{
            minHoursTimeES = '0 0 ';
            minHoursTimeESForPreparations = '0 1 ';
            minHoursTimeES += String.valueOf(Integer.valueOf(dateTimES) + 1) + ' ? * *';
        	minHoursTimeESForPreparations += dateTimES + ' ? * *';

            for( CronTriggerWrapper cronTriggerWrapperItem : billingJobES ) {
                System.abortJob( cronTriggerWrapperItem.record.Id );
            }

            System.schedule( 'Email Statements Job', minHoursTimeES , new CreateBatchStatementOfAccountsEmail() );
			System.schedule( 'Email Statements Job Preparations', minHoursTimeESForPreparations , new CreateBatchNumberOfStatements() );

        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'Please contact your administrator. Error occured via rescheduling Billing job. ' + e ) );
        }

        ddpHelper.Is_Day_Of_Month__c = isOnDayInMonthES;
        ddpHelper.Day_Of_Month__c = dayInMonthES;
        ddpHelper.Sunday_Or_Saturday__c = dayInWeekES;
        ddpHelper.Number_Week__c = dayOfWeekInMonthES;
        ddpHelper.Email_Statements_Job_Hour__c = dateTimES;

        DDPHelperServices.calculateExecutionDateForDDP(ddpHelper, DateTime.now(), true);

        upsert ddpHelper;
        getBillingJobES();
        getCronTabES();
        return null;
    }

    public PageReference getCronTabES() {
        if (ddpHelper.Automatically_Email_Statements__c){
            isOnDateInMonthES = !ddpHelper.Is_Day_Of_Month__c;
            isOnDayInMonthES = ddpHelper.Is_Day_Of_Month__c;
            dayInMonthES = ddpHelper.Day_Of_Month__c;
            dayInWeekES = ddpHelper.Sunday_Or_Saturday__c;
            dayOfWeekInMonthES = ddpHelper.Number_Week__c;
            dateTimES = ddpHelper.Email_Statements_Job_Hour__c;
        }

        return null;
    }

    public PageReference applyChangesUsersES() {
        ddpHelper.Text5__c = '';
        ddpHelper.Text4__c = '';

        Boolean first = true;
        for ( SelectOption so : selectedUsersES ) {
            if (!first) {
                ddpHelper.Text5__c += ',';
                ddpHelper.Text4__c += ',';
            }
            ddpHelper.Text5__c += so.getValue();
            ddpHelper.Text4__c += usersMap.get( so.getValue() ).Email;
            first = false;
        }
        upsert ddpHelper;
        return null;
    }
}