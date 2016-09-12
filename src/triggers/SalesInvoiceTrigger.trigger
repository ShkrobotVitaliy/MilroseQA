trigger SalesInvoiceTrigger on c2g__codaInvoice__c (before insert, after insert, before update, after update) {

    if( Trigger.isBefore ) {
        if( Trigger.isUpdate ) {
            TransactionServices.updateTransactionFieldsFromSalesInvoices( SalesInvoiceServices.filterInvoicesForFieldsPopulationOnTransaction( Trigger.new ) );
        }
    }

    if( Trigger.isAfter ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            TaskServices.createTasksForStaffAccountantsForSalesInvoices( SalesInvoiceServices.filterSalesInvoicesForTaskCreation( Trigger.new, Trigger.oldMap ) );
        }
    }

}