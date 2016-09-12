public with sharing class LegacyInvoicePDFComponentController {
    private Legacy_Pro_forma_Invoice__c legacyInvoiceRecord;
    
    public String address1 { get { return legacyInvoiceRecord.Project_Address__r.Name != null ? legacyInvoiceRecord.Project_Address__r.Name : ''; } }
    public String address2 { get { return getAddress2(); } }

    private String getAddress2() {
        String address = ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.City__c) ? legacyInvoiceRecord.Project_Address__r.City__c : '' ) +
                         ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.City__c) && ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.State__c) || !String.isEmpty(legacyInvoiceRecord.Project_Address__r.PostalCode__c) ) ? ', ' : '') +
                         ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.State__c) ? legacyInvoiceRecord.Project_Address__r.State__c : '' ) +
                         ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.State__c) && !String.isEmpty(legacyInvoiceRecord.Project_Address__r.PostalCode__c) ? ' ' : '' ) +
                         ( !String.isEmpty(legacyInvoiceRecord.Project_Address__r.PostalCode__c) ? legacyInvoiceRecord.Project_Address__r.PostalCode__c : '' );
        return address;
    }

    public Decimal currentAmount {
        get {
            if (null == this.currentAmount) {
                this.currentAmount = (null == this.legacyInvoiceRecord.Outstanding_Amount_Today__c) ? 0.00 : this.legacyInvoiceRecord.Outstanding_Amount_Today__c;
                
                for (c2g__codaInvoice__c invoice : importedInvoices) {
                    this.currentAmount += (null != invoice.c2g__OutstandingValue__c && Date.today() == invoice.c2g__InvoiceDate__c) ? invoice.c2g__OutstandingValue__c : 0.00;
                    
                }
                
            }
            return this.currentAmount;
        
        }
        set;
    
    }
    
    public Decimal out30Amount {
        get {
            if (null == this.out30Amount) {
                this.out30Amount = null == this.legacyInvoiceRecord.Outstanding_Amount_1_To_30_Days__c ? 0.00 : this.legacyInvoiceRecord.Outstanding_Amount_1_To_30_Days__c;
                
                for (c2g__codaInvoice__c invoice : importedInvoices) {
                    this.out30Amount += (null != invoice.c2g__OutstandingValue__c && invoice.c2g__InvoiceDate__c < Date.today() && invoice.c2g__InvoiceDate__c >= Date.today().addDays(-30)) ? invoice.c2g__OutstandingValue__c : 0.00;
                
                }
            
            }
            return this.out30Amount;
        
        }
        set;
    
    }
    
    public Decimal out60Amount {
        get {
            if (null == this.out60Amount) {
                this.out60Amount = null == this.legacyInvoiceRecord.Outstanding_Amount_31_To_60_Days__c ? 0.00 : this.legacyInvoiceRecord.Outstanding_Amount_31_To_60_Days__c;
                
                for (c2g__codaInvoice__c invoice : importedInvoices) {
                    this.out60Amount += (null != invoice.c2g__OutstandingValue__c && invoice.c2g__InvoiceDate__c < Date.today().addDays(-30) && invoice.c2g__InvoiceDate__c >= Date.today().addDays(-60)) ? invoice.c2g__OutstandingValue__c : 0.00;
                
                }
            
            }
            return this.out60Amount;
            
        }
        set;
    
    }
    
    public Decimal out90Amount {
        get {
            if (null == this.out90Amount) {
                this.out90Amount = null == this.legacyInvoiceRecord.Outstanding_Amount_61_To_90_Days__c ? 0.00 : this.legacyInvoiceRecord.Outstanding_Amount_61_To_90_Days__c;
                
                for (c2g__codaInvoice__c invoice : importedInvoices) {
                    this.out90Amount += (null != invoice.c2g__OutstandingValue__c && invoice.c2g__InvoiceDate__c < Date.today().addDays(-60) && invoice.c2g__InvoiceDate__c >= Date.today().addDays(-90)) ? invoice.c2g__OutstandingValue__c : 0.00;
                
                }
            
            }
            return this.out90Amount;
        
        }
        set;
    
    }
    
    public Decimal out90PlusAmount {
        get {
            if (null == this.out90PlusAmount) {
                this.out90PlusAmount = null == this.legacyInvoiceRecord.Outstanding_Amount_90_Days__c ? 0.00 : this.legacyInvoiceRecord.Outstanding_Amount_90_Days__c;
                
                for (c2g__codaInvoice__c invoice : importedInvoices) {
                    this.out90PlusAmount += (null != invoice.c2g__OutstandingValue__c && invoice.c2g__InvoiceDate__c < Date.today().addDays(-90)) ? invoice.c2g__OutstandingValue__c : 0.00;
                    
                }
            
            }
            return this.out90PlusAmount;
        
        }
        set;
    
    }
    
    public Decimal outstandingAmountDueSum {
        get {
            return this.currentAmount + this.out30Amount + this.out60Amount + this.out90Amount + this.out90PlusAmount;
        
        }
        set;
    
    }
    
    public void setLegacyInvoiceRecord(Legacy_Pro_forma_Invoice__c legacyInvoiceRecord) {
        this.legacyInvoiceRecord = legacyInvoiceRecord;
        
    }
    
    public Legacy_Pro_forma_Invoice__c getLegacyInvoiceRecord() {
        return this.legacyInvoiceRecord;
    
    }
    
    private List<c2g__codaInvoice__c> importedInvoices {
        get {
            if (null == this.importedInvoices) {
                this.importedInvoices = SalesInvoiceServices.getImportedInvoices(this.legacyInvoiceRecord.Project_Number__c);
                
            }
            return this.importedInvoices;
        
        }
        set;
    
    }
    
}