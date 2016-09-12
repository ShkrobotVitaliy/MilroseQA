global class CreateProformaInvoiceBatchJobDaily implements Schedulable{

	global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateProformaInvoicesBatch( true ), Integer.valueOf( Label.Batch_Size_For_PFI_Process ) );
    }

}