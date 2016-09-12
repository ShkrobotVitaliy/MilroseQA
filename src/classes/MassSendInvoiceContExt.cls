public with sharing class MassSendInvoiceContExt {
    private String messageInfo;
    private Datetime generatedDate;

    private final Map<Id, Pro_forma_Invoice__c> invoices;
    private Map<Id, Pro_forma_Invoice__c> invoiceDataMap = new Map<Id, Pro_forma_Invoice__c>();
    
    @testVisible
    private Set<Id> projectIds { 
        get {
            if (null == this.projectIds) {
                this.projectIds = new Set<Id>();
            
            }
            return this.projectIds;
        
        }
        set; 
    }

    @testVisible    
    private String invoicePrefix {
        get {
            if (String.isBlank(this.invoicePrefix)) {
                Schema.DescribeSObjectResult r = Pro_forma_Invoice__c.sObjectType.getDescribe();
                this.invoicePrefix = r.getKeyPrefix();
            
            }
            return this.invoicePrefix;
            
        }
        set;
    }
    
    public String deliveryOption { get; set; }
    /* ------------------------- */
    
    public MassSendInvoiceContExt(ApexPages.StandardSetController stdController) {
        stdController.setPageSize(1000);
        this.messageInfo   = '';
        this.generatedDate = datetime.now();
        this.invoices      = new Map<Id, Pro_forma_Invoice__c>((List<Pro_forma_Invoice__c>)stdController.getSelected());

    }

    public void autorun() {
        try {
            this.invoiceDataMap = getInvoicesData(this.invoices.keySet());
            
            if (!String.isBlank(this.messageInfo)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, this.messageInfo));
            
            }
            
            if (this.invoiceDataMap.isEmpty()) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.PROFORMA_PLEASE_SELECT_ONE_INVOICE));
                return;
        
            }
            
            //Recalculate Outstanding Invoice
            ProjectProfileServices.calculateOutstandingAmountsByDate(this.projectIds);
            
            //Update Invoices
            updateInvoiceBLIDataForPDF();
            
            //Send DDP Request
            runDDP(this.invoiceDataMap.keySet());
            
        } catch (Exception ex) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
             
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.OPERATION_WAS_SUCCEEDED));
    
    }
    
    @testVisible
    private Map<Id, Pro_forma_Invoice__c> getInvoicesData(Set<Id> ids) {
        Map<Id, Pro_forma_Invoice__c> invoicesMap = new Map<Id, Pro_forma_Invoice__c>();
        this.projectIds = new Set<Id>();
        
        if (this.deliveryOption.equals(DDPEmailServices.DELIVERY_METHOD_ATTACH)) {
            for (Pro_forma_Invoice__c invoice : ProformaInvoiceServices.getProformaInvoiceByIds(ids)) {
                invoicesMap.put(invoice.Id, invoice);
                this.projectIds.add(invoice.Project_Profile__c);
                        
            }
            return invoicesMap;
        
        }
        return invoicesMap;
    
    }
    
    @testVisible
    private void runDDP( Set<Id> invoiceIds ) {
        Map<String, Map<String, String>> invoiceIdToAttachmentIdToParentId = StoredDocumentServices.getParentIdsAndAttachmentIdsForUploadedChecks( invoiceIds );

        DDPRequest ddpRequest = new DDPRequest();
        
        for( Id invoiceId : invoiceIds ) {
            ddpRequest.addConfiguration( invoiceId,
                                         DDPEmailServices.DDP_NAME_CREATE_INVOICES,
                                         this.deliveryOption,
                                         null,
                                         null,
                                         null,
                                         StoredDocumentServices.getAttachmentIdsForInvoice( invoiceIdToAttachmentIdToParentId, invoiceId ) );
        }
        ddpRequest.sendRequest();
    
    }
    
    //Action: Download
    public PageReference downloadPdf() {
        try {
            String parentIds = '';
            String docIds    = '';
        
            for (Id proformaId : this.invoices.keySet()) {
                parentIds += String.valueOf(proformaId) + ',';
            
            }
            
            Set<String> relatedIds = new Set<String>();
            for (LStore__Stored_Document__c doc : StoredDocumentServices.getStoredDocumentByRelatedIds(this.invoices.keySet(), this.invoices.size(), this.generatedDate)) {
                if (!relatedIds.contains(doc.Related_Object_Id__c)) {
                    docIds += doc.Id + ',';
                    relatedIds.add(doc.Related_Object_Id__c);
                
                }
                            
            }
            
            if (String.isBlank(docIds) || relatedIds.size() < this.invoices.size()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.DOCUMENTS_IS_NOT_GENERATED));
                return null;
            
            }
            
            return DDPEmailServices.createDDPLoopPlus(DDPEmailServices.DDP_NAME_JOIN_INVOICE_PDF, 
                                                      DDPEmailServices.DELIVERY_METHOD_DOWNLOAD, 
                                                      String.valueOf(new List<Id>(this.invoices.keySet())[0]), 
                                                      null, 
                                                      parentIds.removeEnd(','), 
                                                      String.format('/{0}', new List<String> { this.invoicePrefix }), 
                                                      docIds.removeEnd(','), 
                                                      true);
             
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
             
        }
        return null;
             
    }
    
    //Action: Back
    public PageReference back() {
        return new PageReference(String.format('/{0}', new List<String> { this.invoicePrefix }));
    
    }

    @TestVisible
    private void updateInvoiceBLIDataForPDF(){
        Map<Id, Billing_Line_Item__c> lineItemsForPDF = BillingLineItemServices.getBLIForInvoicesToGeneratePDF( this.invoiceDataMap.keySet() );
        Map<Id, Pro_forma_Invoice__c> invoicesToUpdate = new Map<Id, Pro_forma_Invoice__c>();
        
        for (Billing_Line_Item__c bli: lineItemsForPDF.values()) {
            if (!this.invoiceDataMap.containsKey(bli.Pro_forma_Invoice__c)) {
                continue;
            }
            Boolean updateInvoice = false;
            Pro_forma_Invoice__c invoice = this.invoiceDataMap.get(bli.Pro_forma_Invoice__c);
            /*if (invoice.cl_Create_FFA_Invoice__c) {
                continue;
            
            }*/
            if (BillingLineItemServices.FEDEX_FILTER == bli.Mailroom_COSTCATID_Service_Type__c && !invoice.Contains_Fedex_Mailroom__c) {
                invoice.Contains_Fedex_Mailroom__c = true;
                updateInvoice = true;
            }
            if (null != bli.Mailroom_COSTCATID_Service_Type__c&& bli.Mailroom_COSTCATID_Service_Type__c.startsWith(BillingLineItemServices.SUPREME_SYSTEMS_FILTER) && !invoice.Contains_Mess_Meilroom__c) {
                invoice.Contains_Mess_Meilroom__c = true;
                updateInvoice = true;
            }
            if (BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING == String.valueOf(bli.Reimbursable_Type__c) && !invoice.Contains_Sredding__c) {
                invoice.Contains_Sredding__c = true;
                updateInvoice = true;
            }
            if (BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING == String.valueOf(bli.Reimbursable_Type__c) && !invoice.Contains_Scanning__c) {
                invoice.Contains_Scanning__c = true;
                updateInvoice = true;
            }
            if (bli.isHourlyConsulting__c && !invoice.Contains_Hourly_Consulting__c) {
                invoice.Contains_Hourly_Consulting__c = true;
                updateInvoice = true;
            }
            if ( updateInvoice ) {
                invoicesToUpdate.put( invoice.Id, invoice );
            }
        }

        for( Id invoiceId : BillingLineItemServices.getInvoiceIdsThatHaveChargeChecks( this.invoiceDataMap.keySet() ) ) {
            Pro_forma_Invoice__c invoice = this.invoiceDataMap.get( invoiceId );
            if( invoice != null && !invoice.Contains_AmEx_Checks__c ) {
                invoice.Contains_AmEx_Checks__c = true;
                invoicesToUpdate.put( invoice.Id, invoice );
            }
        }

        try {
            UPSERT invoicesToUpdate.values();
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occured While Updating Pro-Forma Invoice: ' + ex.getMessage()));
        
        }
        
    }

}