public with sharing class MassCreateAndSendInvoiceController {
    private String INVOICES_WITHOUT_FF_MESSAGE = '{0} [{1}] {2} not sent. You may only send invoices after they have been created in Financial Force.';
    private String INVOICES_NOT_VALID_MESSAGE = '{0} [{1}] {2} either Invoice Format or Accounting Contact fields not populated.';
    private String INVOICES_PROCESSED_MESSAGE = '{0} for following {1} were created and sent successfully: [{2}].';

    public List<Pro_forma_Invoice__c> proFormaInvoiceList = new List<Pro_forma_Invoice__c>();
    public Map<Id, Pro_forma_Invoice__c> proFormaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>();
    public List<String> invoicesWithoutFFNames = new List<String>();
    public List<String> notValidInvoicesNames = new List<String>();
    public Map<Id, Pro_forma_Invoice__c> validInvoicesMap = new Map<Id, Pro_forma_Invoice__c>();
    public List<String> validInvoicesNames = new List<String>();

    public MassCreateAndSendInvoiceController(ApexPages.StandardSetController controller) {
        controller.setPageSize(1000);
        proFormaInvoiceList = (List<Pro_forma_Invoice__c>)controller.getSelected();
    }

    public void autorun() {
        if( proFormaInvoiceList.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please select Invoices.'));
            return;
        }
        proFormaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>([SELECT Id, Name, cl_FFA_Invoice_Created__c, Accounting_Contact__c, Invoice_Format__c, Contains_Hourly_Consulting__c,
                                                                Contains_Fedex_Mailroom__c, Contains_Mess_Meilroom__c, Contains_Sredding__c, Contains_Scanning__c, Sent_To_Client__c
                                                                FROM Pro_forma_Invoice__c 
                                                                WHERE Id IN: proFormaInvoiceList]);

        for( Pro_forma_Invoice__c invoice : proFormaInvoiceMap.values() ){
            if(!invoice.cl_FFA_Invoice_Created__c) {
                invoicesWithoutFFNames.add(invoice.Name);
            }else if( String.isEmpty(invoice.Invoice_Format__c) || String.isEmpty(Invoice.Accounting_Contact__c)){
                notValidInvoicesNames.add(invoice.Name);
            }else{
                validInvoicesMap.put(invoice.Id, invoice);
                validInvoicesNames.add(invoice.Name);
            }
        }

        if( !validInvoicesMap.isEmpty() ){
            //Update invoice PDF data
            Boolean updateInvoicesStatus = ProformaInvoiceServices.updateInvoicesDataForPDF(validInvoicesMap, true);
            if( !updateInvoicesStatus ){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occurred While Updating Pro-Forma Invoices'));
                return;
            }
            Map<String, Map<String, String>> invoiceIdToAttachmentIdToParentId = StoredDocumentServices.getParentIdsAndAttachmentIdsForUploadedChecks( validInvoicesMap.keySet() );

            DDPRequest request = new DDPRequest();
            for( Pro_forma_Invoice__c invoice : validInvoicesMap.values() ) {
                request.addConfiguration( invoice.Id,
                                          DDPEmailServices.DDP_NAME_CREATE_INVOICES,
                                          DDPEmailServices.DELIVERY_METHOD_EMAIL,
                                          null,
                                          invoice.Accounting_Contact__c,
                                          null,
                                          StoredDocumentServices.getAttachmentIdsForInvoice( invoiceIdToAttachmentIdToParentId, invoice.Id ) );
            }
            request.sendRequest();
        }

        //Final messages
        List<String> messageParameters;
        if( !invoicesWithoutFFNames.isEmpty() ){
            messageParameters = new List<String>{invoicesWithoutFFNames.size() == 1 ? 'Invoice' : 'Invoices', String.join(invoicesWithoutFFNames, ', '), invoicesWithoutFFNames.size() == 1 ? 'was' : 'were'};
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(INVOICES_WITHOUT_FF_MESSAGE, messageParameters) ) );
        }
        if( !notValidInvoicesNames.isEmpty() ){
            messageParameters = new List<String>{notValidInvoicesNames.size() == 1 ? 'Invoice' : 'Invoices', String.join(notValidInvoicesNames, ', '), notValidInvoicesNames.size() == 1 ? 'has' : 'have'};            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, String.format(INVOICES_NOT_VALID_MESSAGE, messageParameters) ) );
        }
        if( !validInvoicesNames.isEmpty() ){
            messageParameters = new List<String>{validInvoicesNames.size() == 1 ? 'Document' : 'Documents', validInvoicesNames.size() == 1 ? 'Invoice' : 'Invoices', String.join(validInvoicesNames, ', ')};            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.format(INVOICES_PROCESSED_MESSAGE, messageParameters) ) );
        }
    }

    public PageReference backToInvoicesAction() {
        PageReference pReference = new PageReference('/apex/ProFormaInvoicesTab');
        pReference.setRedirect(true);
        return pReference;
    }
}