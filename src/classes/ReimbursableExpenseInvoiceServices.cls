public with sharing class ReimbursableExpenseInvoiceServices {
     private final static Integer MAX_BATCH_CALLS = 5;

   private final static String BATCH_STATUS_PROCESSING = 'Processing';
   private final static String BATCH_STATUS_PREPARING  = 'Preparing';
   private final static String BATCH_STATUS_QUEUED     = 'Queued';
   private final static String BATCH_JOB               = 'BatchApex';

   public final static String CREATE_PAYABLE_INVOICE_JOB_NAME   = 'Create Payable Invoice Job';
   public final static String CUSTOM_SETTING_IS_PROCESS_CHECKED = 'Is Already Clicked';

   public static void runPayableInvoiceClickRule() {
        if (!getReimbursableInvoicesForCreatePayableInvoices().isEmpty() && !system.isBatch() && !system.isScheduled() &&
            [SELECT count() FROM AsyncApexJob WHERE JobType =: BATCH_JOB AND (Status =: BATCH_STATUS_PROCESSING OR Status =: BATCH_STATUS_PREPARING OR Status =: BATCH_STATUS_QUEUED)] < MAX_BATCH_CALLS) {
                Database.executeBatch(new ClickLinkBatch(CREATE_PAYABLE_INVOICE_JOB_NAME), 1);

        }

    }

    public static Reimbursable_Expense_Invoice__c newInstance(Check__c check, Id projectId) {
        if (null == check) {
            throw new ErrorException(ErrorException.CHECK_REQUEST_EMPTY);

        }

        if (null == projectId) {
            throw new ErrorException(ErrorException.PROJECT_ID_EMPTY);

        }

        return pupolatedReimbursableExpenseInvoiceFiled(check, projectId, null);

    }

    public static Reimbursable_Expense_Invoice__c pupolatedReimbursableExpenseInvoiceFiled (Check__c check, Id projectId, Reimbursable_Expense_Invoice__c reimbursableExpenseInvoice){
        Reimbursable_Expense_Invoice__c returnReimbursableExpenseInvoice = reimbursableExpenseInvoice == null ? new Reimbursable_Expense_Invoice__c() : reimbursableExpenseInvoice;

        returnReimbursableExpenseInvoice.Billing_Client__c      = check.Billing_Client__c;
        returnReimbursableExpenseInvoice.Billing_Contact__c     = check.Billing_Contact__c;
        returnReimbursableExpenseInvoice.Check_Request__c       = check.Id;
        returnReimbursableExpenseInvoice.Description__c         = check.Description__c;
        returnReimbursableExpenseInvoice.Invoice_Payee__c       = check.Invoice_Payee__c;
        returnReimbursableExpenseInvoice.Municipal_Agency_ID__c = check.Municipal_Agency_ID__c;
        returnReimbursableExpenseInvoice.Phase__c               = check.Phase__c;
        returnReimbursableExpenseInvoice.Product_Name__c        = check.Product_Name__c;
        returnReimbursableExpenseInvoice.Project_Address__c     = check.Project_Address__c;
        returnReimbursableExpenseInvoice.Project_Profile__c     = projectId;
        returnReimbursableExpenseInvoice.Reimb_Billable_Type__c = 'Standard';
        returnReimbursableExpenseInvoice.Requester__c           = check.ownerId;
        returnReimbursableExpenseInvoice.Service_Item__c        = check.Service_Item__c;
        returnReimbursableExpenseInvoice.Check_Amount__c        = check.Check_Amount__c;

        return returnReimbursableExpenseInvoice;
    }

    /* ------------------------------------------ Begin DAO Methods ------------------------------------------------- */
    private static List<Reimbursable_Expense_Invoice__c> getReimbursableInvoicesForCreatePayableInvoices() {
        return new List<Reimbursable_Expense_Invoice__c>([SELECT Id, Invoice_Payee__c, Create_FFA_PIN__c, FFA_PIN_Created__c
                                                          FROM Reimbursable_Expense_Invoice__c
                                                          WHERE Create_FFA_PIN__c = true AND FFA_PIN_Created__c = false AND Invoice_Payee__c != null AND Payable_Invoice__c = null]);

    }
    /* ------------------------------------------ End DAO Methods ------------------------------------------------- */

}