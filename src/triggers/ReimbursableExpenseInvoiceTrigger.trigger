trigger ReimbursableExpenseInvoiceTrigger on Reimbursable_Expense_Invoice__c (before insert, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        MilroseDevHelper.setWorkType( Trigger.new );
    }

}