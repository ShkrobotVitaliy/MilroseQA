public with sharing class BillingLineItemsExtensions {
    public Id billItemId { get; set; }
    public final Pro_forma_invoice__c invoice { get; private set; }    
    public List<Billing_Line_Item__c> billingItems { get; private set; }
    
    public BillingLineItemsExtensions (ApexPages.StandardController controller) {
        this.invoice = (Pro_forma_invoice__c)controller.getRecord();
    
    }
    
    public List<Billing_Line_Item__c> getBillingLineItems() {
        try {
            this.billingItems = BillingLineItemServices.getBillingLineItemByInvoiceId(this.invoice.Id);
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        
        }
        return this.billingItems;
    
    }
    
    public PageReference editBillItem() {
        if (String.isBlank(this.billItemId)) {
            return null;
            
        }
        
        Billing_Line_Item__c billingLineItem;
        
        for (Billing_Line_Item__c item : this.billingItems) {
            if (this.billItemId == item.Id) {
                billingLineItem = item;
                break;
            
            }        
        
        }
        
        if (null != billingLineItem) {
            PageReference page = new ApexPages.StandardController(billingLineItem).edit();
            return page;
            
        }
        return null;    
    
    }
    
    public PageReference removeBillItemLookUp() {
        if( invoice.Sales_Invoice__c != null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'FF invoice is generated. You don’t have ability to remove BLI. Please contact Your administrator.'));
            return null;    
        }
        
        if (String.isBlank(this.billItemId)) {
            return null;
            
        }
        
        Billing_Line_Item__c billingLineItem;
        
        for (Billing_Line_Item__c item : this.billingItems) {
            if (this.billItemId == item.Id) {
                billingLineItem = item;
                break;
            
            }        
        
        }
        
        if (null == billingLineItem) {
            return null;
            
        }
        
        try {
            if( billingLineItem.Reimbursable_Type__c == BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING ){
                delete billingLineItem;

                update new Service_Item__c( Id = billingLineItem.Related_Service_Item__c, Doc_Shredding_BLI_Created__c = false );
            } else {
                update new Billing_Line_Item__c(Id = billingLineItem.Id, Pro_forma_Invoice__c = null, Billed__c = false);
            }
            
            
             //Recalculate Total Commissionable Amount
            BillingLineItemServices.updateTotalCommissionableAmount( new Map<Id, Pro_forma_Invoice__c>(ProformaInvoiceServices.getProformaInvoiceByIds(new Set<Id> { billingLineItem.Pro_forma_Invoice__c })));
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
    
        }
        PageReference pageRef = new PageReference('/' + this.invoice.Id);
        pageRef.setRedirect(true);
        return pageRef;
    
    }

}