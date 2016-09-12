public with sharing class LegacyInvoicePDFController {
    private final String legacyId;
    private final String action;

    public Boolean isDisplayMailTo { 
        get {
            return !String.isBlank(this.action) && this.action == 'create';
        
        }
        private set; 
    }
    
    public Boolean isCredit1 { 
        get {
            return !String.isBlank(this.action) && this.action == 'credit1';
        
        }
        private set; 
    }
    
    public Boolean isCredit2 { 
        get {
            return !String.isBlank(this.action) && this.action == 'credit2';
        
        }
        private set; 
    }

    public String creditNoteNumberShort {
        get {
            this.creditNoteNumberShort = '';
            
            if (null != this.legacyInvoice) {
            
                if (this.isCredit1) {
                    this.creditNoteNumberShort = this.legacyInvoice.cl_FF_Sales_Credit_Note_1__r.Name;
                
                } else if (this.isCredit2) {
                    this.creditNoteNumberShort = legacyInvoice.cl_FF_Sales_Credit_Note_2__r.Name;
                
                } else {
                    this.creditNoteNumberShort = this.legacyInvoice.Name_without_Prefix__c;
                
                }
                
            }
            
            if ((this.isCredit1 || this.isCredit2) && !String.isBlank(this.creditNoteNumberShort) && (this.creditNoteNumberShort.removeStartIgnoreCase('SCR') ).isAlphanumeric() ) {
                this.creditNoteNumberShort = SalesInvoiceServices.SALES_CREDIT_NOTES_PREFIX_SCR + String.valueOf(Integer.valueOf(this.creditNoteNumberShort.removeStartIgnoreCase('SCR')));
            
            }
            return this.creditNoteNumberShort;
        
        }
        private set;
    
    }

    public Legacy_Pro_forma_Invoice__c legacyInvoice { 
        get {
            if (null == this.legacyInvoice) {
                try {
                    this.legacyInvoice = LegacyProformaInvoiceServices.getLegacyProformaInvoiceById(this.legacyId);
            
                } catch(Exception ex) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                    return null;
                
                }
            
            }
            return this.legacyInvoice;
        
        }
        private set; 
    }
    
    public LegacyInvoicePDFController() {
        this.legacyId = ApexPages.currentPage().getParameters().get('legacyId');
        this.action   = ApexPages.currentPage().getParameters().get('action');
    
    }

}