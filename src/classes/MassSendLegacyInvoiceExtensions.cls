public with sharing class MassSendLegacyInvoiceExtensions {
    private String messageInfo;
    private final Map<Id, Legacy_Pro_forma_Invoice__c> legacyInvoices;
    private Map<Id, Legacy_Pro_forma_Invoice__c> invoiceDataMap = new Map<Id, Legacy_Pro_forma_Invoice__c>();
    private Set<Id> selectedProformaIds = new Set<Id>();
    private Datetime generatedDate;
    
    private Set<Id> projectIds { 
        get {
            if (null == this.projectIds) {
                this.projectIds = new Set<Id>();
            
            }
            return this.projectIds;
        
        }
        set; 
    }
    
    private String legacyPrefix {
        get {
            if (String.isBlank(this.legacyPrefix)) {
                Schema.DescribeSObjectResult r = Legacy_Pro_forma_Invoice__c.sObjectType.getDescribe();
                this.legacyPrefix = r.getKeyPrefix();
            
            }
            return this.legacyPrefix;
            
        }
        set;
    }
    
    public String ddpNameParam { get; set; }
    public String actionParam { get; set; }

    public MassSendLegacyInvoiceExtensions(ApexPages.StandardSetController controller) {
        controller.setPageSize(1000);           
        this.messageInfo    = '';
        this.legacyInvoices = new Map<Id, Legacy_Pro_forma_Invoice__c>((List<Legacy_Pro_forma_Invoice__c>)controller.getSelected());
        this.generatedDate = datetime.now();
        
    }
    
    public void autorun() {
        try {
            this.invoiceDataMap = getLegacyInvoicesData(this.legacyInvoices.keySet());
            
            if (!String.isBlank(this.messageInfo)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, this.messageInfo));
            
            }
            
            if (this.invoiceDataMap.isEmpty()) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.SELECT_APPROPRIATE_ITEM));
                return;
        
            }
            
            //Recalculate Outstanding Invoice
            ProjectMi7Services.calculateOutstandingAmounts(this.projectIds);
            
            //If user click Create & Send PDF, system checks checkbox.
            if (this.actionParam.equals(DDPEmailServices.DELIVERY_METHOD_EMAIL)) {
                //Update invoice PDF data
                LegacyProformaInvoiceServices.updateSentToClientField( this.invoiceDataMap.size() > 1 ? this.invoiceDataMap.values() : new List<Legacy_Pro_forma_Invoice__c>{this.invoiceDataMap.values()} );
            
            }
            
            //Update mailroom checkbox
            LegacyProformaInvoiceServices.updateMailroomProperties(this.invoiceDataMap);
            
            //Send DDP Request
            runDDP(this.invoiceDataMap.keySet());
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return;
        
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.OPERATION_WAS_SUCCEEDED));
    
    }
   
    private Map<Id, Legacy_Pro_forma_Invoice__c> getLegacyInvoicesData(Set<Id> ids) {
        Map<Id, Legacy_Pro_forma_Invoice__c> invoicesMap = new Map<Id, Legacy_Pro_forma_Invoice__c>();
        this.projectIds = new Set<Id>();
        String invoiceNames = '';
        
        if (this.actionParam.equals(DDPEmailServices.DELIVERY_METHOD_ATTACH)) {
            for (Legacy_Pro_forma_Invoice__c invoice : LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(ids)) {
                this.selectedProformaIds.add(invoice.Id);
                invoicesMap.put(invoice.Id, invoice);
                this.projectIds.add(invoice.Project_Native__c);
                        
            }
            return invoicesMap;
        
        } else {
            for (Legacy_Pro_forma_Invoice__c invoice : LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(ids)) {
                if (invoice.FFA_Invoice_Created__c) {
                    this.selectedProformaIds.add(invoice.Id);
                    invoicesMap.put(invoice.Id, invoice);
                    this.projectIds.add(invoice.Project_Native__c);
                    
                } else {
                    invoiceNames += invoice.Name + ', ';
                    
                }
            
            }
        
        }
        
        if (!String.isBlank(invoiceNames)) {
            this.messageInfo = string.format(LegacyProformaInvoiceServices.INVOICE_WAS_NOT_SEND, new string[] { invoiceNames.subString(0, invoiceNames.length() - 2) } );
        
        }
        return invoicesMap;
    
    }
    
    private void runDDP(Set<Id> invoiceIds) {
        DDPRequest ddpRequest = new DDPRequest();
        
        for(Id invoiceId : invoiceIds) {
            ddpRequest.addConfiguration(invoiceId, this.ddpNameParam, this.actionParam, null, this.actionParam.equals(DDPEmailServices.DELIVERY_METHOD_EMAIL) ? this.invoiceDataMap.get(invoiceId).Accounting_Contact__c : null, null, null);
            
        }
        ddpRequest.sendRequest();
    
    }
    
    public PageReference downloadPdf() {
        try {
            String parentIds = '';
            String docIds    = '';
        
            for (Id proformaId : this.selectedProformaIds) {
                parentIds += String.valueOf(proformaId) + ',';
            
            }
            
            Set<String> relatedIds = new Set<String>();
            for (LStore__Stored_Document__c doc : StoredDocumentServices.getStoredDocumentByRelatedIds(this.selectedProformaIds, this.selectedProformaIds.size(), this.generatedDate)) {
                if (!relatedIds.contains(doc.Related_Object_Id__c)) {
                    docIds += doc.Id + ',';
                    relatedIds.add(doc.Related_Object_Id__c);
                
                }
                            
            }
            
            if (String.isBlank(docIds) || relatedIds.size() < this.selectedProformaIds.size()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.DOCUMENTS_IS_NOT_GENERATED));
                return null;
            
            }
            
            return DDPEmailServices.createDDPLoopPlus(DDPEmailServices.DDP_NAME_JOIN_LEGACY_PDF, 
                                                      DDPEmailServices.DELIVERY_METHOD_DOWNLOAD, 
                                                      String.valueOf(new List<Id>(this.selectedProformaIds)[0]), 
                                                      null, 
                                                      parentIds.removeEnd(','), 
                                                      String.format('/{0}', new List<String> { this.legacyPrefix }), 
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
        return new PageReference(String.format('/{0}', new List<String> { this.legacyPrefix }));
    
    }
    
}