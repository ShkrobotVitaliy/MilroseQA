global class RunClicklinkRuleForCreatingLineItems implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        RunClicklinkRuleForCreatingLineItems job = new RunClicklinkRuleForCreatingLineItems();
        job.execute();
    
    }
    
    global void execute() {
        //Run ClickLink: Create Billing Line Items
        Database.executeBatch(new ClickLinkBatch('Create BLI Job'), 1); //PurchaseInvoiceServices.CREATE_BLI_JOB_NAME
         
        //Run ClickLink: Create Legacy Billing Items
        Database.executeBatch(new ClickLinkBatch('Create Legacy Billing Item'), 1); //PurchaseInvoiceServices.CREATE_LEGACY_BILLING_ITEM_JOB_NAME

    }
    
}