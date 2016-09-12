global class CreateJobSendEmailInvoices implements Schedulable{

    global CreateJobSendEmailInvoices() {}

    global void execute(SchedulableContext sc) {
        CreateJobSendEmailInvoices job = new CreateJobSendEmailInvoices();
        job.execute();
    }

    //Execute method
    global void execute() {
    Integer ddpHelpersCount = new List<Schema.PicklistEntry>( Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ).size();
    List<DDP_Helper__c> ddpHelperList = [Select Id From DDP_Helper__c Where Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB AND CreatedDate = TODAY Order by CreatedDate DESC limit: ddpHelpersCount];

    if ( !ddpHelperList.isEmpty() ){ 

      DDPRequest request = new DDPRequest();

      Map<Id, Pro_forma_Invoice__c> validInvoicesMap = new Map<Id, Pro_forma_Invoice__c>( [ SELECT Id, Name, cl_FFA_Invoice_Created__c, Accounting_Contact__c, Invoice_Format__c, Contains_Hourly_Consulting__c,
                      Contains_Fedex_Mailroom__c, Contains_Mess_Meilroom__c, Contains_Sredding__c, Contains_Scanning__c, Sent_To_Client__c
                      FROM Pro_forma_Invoice__c
                                                                    WHERE DDP_Helper__c IN: ddpHelperList
                                                                      AND DDP_Helper__r.Delivery_Method__c = 'Email'
                                                                      AND DDP_Helper__r.Email_Invoices__c = true
                                                                      AND Sent_To_Client__c = false 
                      AND cl_FFA_Invoice_Created__c = true ] );

      if( !validInvoicesMap.isEmpty() ){
        //Update invoice PDF data
        Boolean updateInvoicesStatus = ProformaInvoiceServices.updateInvoicesDataForPDF(validInvoicesMap, true);

        Map<String, Map<String, String>> invoiceIdToAttachmentIdToParentId = StoredDocumentServices.getParentIdsAndAttachmentIdsForUploadedChecks( validInvoicesMap.keySet() );

        for( Pro_forma_Invoice__c invoice : validInvoicesMap.values() ) {
          request.addConfiguration( invoice.Id,
                        DDPEmailServices.DDP_NAME_CREATE_INVOICES,
                        'Email Automatic',
                        null,
                        invoice.Accounting_Contact__c,
                        null,
                        StoredDocumentServices.getAttachmentIdsForInvoice( invoiceIdToAttachmentIdToParentId, invoice.Id ) );

          system.debug(LoggingLevel.ERROR, 'invoice= '+invoice.Name);
        }
      }

      request.sendRequest();
    }
    }
}