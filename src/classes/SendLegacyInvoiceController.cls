public with sharing class SendLegacyInvoiceController {
    private final Legacy_Pro_forma_Invoice__c legacyInvoice;
    private final String ddpNameParam;
    private final String actionParam;
    
    @TestVisible
    private String ddpName { 
        get {
            if (String.isBlank(this.ddpNameParam)) {
                return '';
            
            }
        
            if (this.ddpNameParam.equals('CreateInvoices')) {
                return DDPEmailServices.DDP_NAME_CREATE_LEGACY_INVOICE;
            
            } else if (this.ddpNameParam.equals('CreateSendInvoices')) {
                return DDPEmailServices.DDP_NAME_CREATE_SEND_LEGACY_INVOICE;
            
            } else if (this.ddpNameParam.equals('CreateCreditNote1')) {
                return DDPEmailServices.DDP_NAME_CREATE_LEGACY_CREDIT_1;
            
            } else if(this.ddpNameParam.equals('CreateCreditNote2')) {
                return DDPEmailServices.DDP_NAME_CREATE_LEGACY_CREDIT_2;
            
            }
            return '';
        
        }
        set; 
    }
    
    @TestVisible
    private String deliveryOption { 
        get {
            if (String.isBlank(this.actionParam)) {
                return '';
            
            }
        
            if (this.actionParam.equals('Send')) {
                return DDPEmailServices.DELIVERY_METHOD_EMAIL;
            
            } else if (this.actionParam.equals('Create')) {
                return DDPEmailServices.DELIVERY_METHOD_ATTACH;
            
            }
            return '';
        
        }
        set; 
    }
    
    public SendLegacyInvoiceController(ApexPages.StandardController controller) {
        this.legacyInvoice = (Legacy_Pro_forma_Invoice__c)controller.getRecord();
        this.ddpNameParam  = ApexPages.currentPage().getParameters().get('ddpName');
        this.actionParam   = ApexPages.currentPage().getParameters().get('action');
        
    }
    
    public PageReference autorun() {
        try {
            if (!this.legacyInvoice.FFA_Invoice_Created__c && this.deliveryOption.equals(DDPEmailServices.DELIVERY_METHOD_EMAIL)) {
                throw new ErrorException(String.format(LegacyProformaInvoiceServices.INVOICE_WAS_NOT_SEND, new string[] { this.legacyInvoice.Name } ));
            
            }
            
            if (!this.legacyInvoice.cl_FFA_Credit_Note_1_Created__c && this.ddpName.equals(DDPEmailServices.DDP_NAME_CREATE_LEGACY_CREDIT_1)) {
                throw new ErrorException(ErrorException.LEGACY_CANNOT_GENERATE_NOTE_1_PDF);
            
            }
            
            if (!this.legacyInvoice.cl_FFA_Credit_Note_2_Created__c && this.ddpName.equals(DDPEmailServices.DDP_NAME_CREATE_LEGACY_CREDIT_2)) {
                throw new ErrorException(ErrorException.LEGACY_CANNOT_GENERATE_NOTE_2_PDF);
            
            }
        
            //Recalculate Outstanding Invoice
            ProjectMi7Services.calculateOutstandingAmounts(new Set<Id> { this.legacyInvoice.Project_Native__c } );
            
            //If user click Create & Send PDF, system checks checkbox. 
            if (this.actionParam.equals('Send')) {
                //Update invoice PDF data
                LegacyProformaInvoiceServices.updateSentToClientField( new List<Legacy_Pro_forma_Invoice__c>{ legacyInvoice } );
            
            }
            
            //Update mailroom checkbox
            Map<Id, Legacy_Pro_forma_Invoice__c> legacyMap = new Map<Id, Legacy_Pro_forma_Invoice__c>();
            legacyMap.put(legacyInvoice.Id, legacyInvoice);
            LegacyProformaInvoiceServices.updateMailroomProperties(legacyMap);
            
            //Run DrawLoop Plus
            return DDPEmailServices.createDDPLoopPlus(this.ddpName, this.deliveryOption, this.legacyInvoice.Id, this.legacyInvoice.Accounting_Contact__c, null, null, null, true);       
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;

        }
        
    }
    
    //Action: Back
    public PageReference back() {
        return new PageReference(String.format('/{0}', new List<String> { this.legacyInvoice.Id }));
    
    }

}