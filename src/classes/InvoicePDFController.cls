public with sharing class InvoicePDFController {
    private final String invoiceId;
    private final String creditNumber;
    
    public String address1 { get { return proformaInvoice.Project_Profile__r.Project_Address__c != null ? proformaInvoice.Project_Profile__r.Project_Address__c : ''; } }
    public String address2 { get { return getAddress2(); } }

    public Boolean isCredit1 { 
        get {
            return !String.isBlank(this.creditNumber) && this.creditNumber == '1';
        
        }
        private set; 
    }
    
    public Boolean isCredit2 { 
        get {
            return !String.isBlank(this.creditNumber) && this.creditNumber == '2';
        
        }
        private set; 
    }
    
    public Pro_forma_Invoice__c proformaInvoice {
        get {
            if (null == this.proformaInvoice) {
                List<Pro_forma_Invoice__c> invoices = ProformaInvoiceServices.getProformaInvoiceByIds(new Set<Id> { this.invoiceId });
                this.proformaInvoice = invoices.isEmpty() ? new Pro_forma_Invoice__c() : invoices.get(0);
            
            }
            return this.proformaInvoice;
        
        }
        private set;
    
    }

    public Decimal unbilledBalance {
        get {
            return proformaInvoice.Purchase_Order_Amount__c - proformaInvoice.Total_Billed_Amount__c;
        
        }
        private set;
    }
    
    public Boolean isServicesExist { 
        get {
            return this.proformaInvoice.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE || 
                   (this.proformaInvoice.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !this.proformaInvoice.Project_Profile__r.Interval__c);
        
        }
        private set; 
    }

    public Integer countBLIs {
       get {
           if (null == proformaInvoice.Billing_Line_Items__r || proformaInvoice.Billing_Line_Items__r.isEmpty()) {
               return 0;
               
           }
           
           this.countBLIs = 0;
           for (Billing_Line_Item__c bli : proformaInvoice.Billing_Line_Items__r) {
               if (!bli.isReimbursable__c) {
                   this.countBLIs += 1;
               
               }    
               
           }    
           return this.countBLIs;
       
       }
       set;
    
    }

    public InvoicePDFController() {
        this.invoiceId       = ApexPages.currentPage().getParameters().get('invoiceId');
        this.creditNumber    = ApexPages.currentPage().getParameters().get('creditNumber');
        
    }

    private String getAddress2() {
        Pro_forma_Invoice__c inv = new Pro_forma_Invoice__c();
        if( proformaInvoice.Id != null ) {
            inv = [ SELECT Project_Profile__r.Building_AKA__c, Project_Profile__r.Building_AKA__r.Building__r.City__c, Project_Profile__r.Building_AKA__r.Building__r.State__c, Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c,
                           Project_Address__r.City__c, Project_Address__r.State__c, Project_Address__r.PostalCode__c
                    FROM Pro_forma_Invoice__c
                    WHERE Id = : proformaInvoice.Id ];
        }

        String address = '';
        if( inv.Project_Profile__r.Building_AKA__c != null ) {
            address = ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.City__c) ? inv.Project_Profile__r.Building_AKA__r.Building__r.City__c : '' ) +
                      ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.City__c) && ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.State__c) || !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.State__c) ? inv.Project_Profile__r.Building_AKA__r.Building__r.State__c : '' ) +
                      ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.State__c) && !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(inv.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ? inv.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c : '' );
        } else {
            address = ( !String.isEmpty(inv.Project_Address__r.City__c) ? inv.Project_Address__r.City__c : '' ) +
                      ( !String.isEmpty(inv.Project_Address__r.City__c) && ( !String.isEmpty(inv.Project_Address__r.State__c) || !String.isEmpty(inv.Project_Address__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(inv.Project_Address__r.State__c) ? inv.Project_Address__r.State__c : '' ) +
                      ( !String.isEmpty(inv.Project_Address__r.State__c) && !String.isEmpty(inv.Project_Address__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(inv.Project_Address__r.PostalCode__c) ? inv.Project_Address__r.PostalCode__c : '' );
        }
        return address;
    }

}