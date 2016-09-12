global class CreateBillingLineItemBatch implements Database.Batchable<sObject>,Database.Stateful, Schedulable {
    global String taskItemsQuery;
    global String errors;

    private Id batchProcessId;
    private final String BATCH_JOB_TITLE = 'Creates Billing Line Item Batch Job ';
    private List<Billing_Line_Item__c> billingLineItemList;

    private Date currentDate = Date.today();

    global CreateBillingLineItemBatch( String taskItemsQuery, Date currDate ) {
        this.currentDate = currDate;
        this.taskItemsQuery = taskItemsQuery;
        this.errors = '';
    }

    global CreateBillingLineItemBatch() {
    system.debug(currentDate);
        this.taskItemsQuery = TaskItemServices.getTaskItemBillingMethodQuery(currentDate);
        List<Billing_Date__c> billingDateList = ( List<Billing_Date__c> ) Database.query( taskItemsQuery );
        this.errors = '';

    }

    global database.querylocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( taskItemsQuery );
    }

    global void execute( Database.BatchableContext bc, Sobject[] scope ) {
        List<Billing_Date__c> billingDateList = ( List<Billing_Date__c> ) scope;
        billingLineItemList = TaskItemServices.createBilingLineItemsForBillingDatesBatch( billingDateList, currentDate, null );

    }

    global void finish(Database.BatchableContext bc) {

            AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id =:bc.getJobId()];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] {job.CreatedBy.Email});
            mail.setSaveAsActivity( false );
            mail.setSubject(BATCH_JOB_TITLE + job.Status);

            String emailBody = BATCH_JOB_TITLE + ' processed ' + job.TotalJobItems + ' batches with '+ job.NumberOfErrors + ' failures.';
            if( billingLineItemList != null ) {
                ProjectProfileServices.sendReportProject(billingLineItemList);
            }
            if( !errors.equals( '' ) ) {
                emailBody += '\n\n\nThe following errors occured:\n'+ errors;
            }
            mail.setPlainTextBody(emailBody);
    }

    //Scheduler Method
    global void execute(SchedulableContext sc) {
        CreateBillingLineItemBatch job = new CreateBillingLineItemBatch();
        batchProcessId = Database.executeBatch(job);
    }
}