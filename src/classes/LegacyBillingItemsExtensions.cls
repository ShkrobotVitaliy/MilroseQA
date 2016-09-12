public with sharing class LegacyBillingItemsExtensions {
    public Id legacyBillingItemId { get; set; }
    public final Legacy_Pro_forma_Invoice__c legacyProformaInvoice { get; private set; }    
    public List<Legacy_Billing_Item__c> legacyBillingItems { get; private set; }

    public LegacyBillingItemsExtensions (ApexPages.StandardController controller) {
        this.legacyProformaInvoice = (Legacy_Pro_forma_Invoice__c)controller.getRecord();
    }

    public List<Legacy_Billing_Item__c> getLegacyBillingItemList() {
        try {
            this.legacyBillingItems = LegacyBillingItemServices.getAllLegacyLineItemByInvoiceIds(this.legacyProformaInvoice.Id);
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        }

        return this.legacyBillingItems;
    }

    public PageReference removeLegacyProformaInvoiceLookUp() {
        if( legacyProformaInvoice.FF_Sales_Invoice__c != null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'FF invoice is generated. You don’t have ability to remove LBI. Please contact Your administrator.'));
            return null;
        }

        if (String.isBlank(this.legacyBillingItemId)) {
            return null;
        }

        try {
            update new Legacy_Billing_Item__c( Id = legacyBillingItemId, Legacy_Pro_forma_Invoice__c = null, Billed__c = false );
            
            //Update Total Commissionable Amount on Legacy Invoice
            Map<Id, Legacy_Billing_Item__c> legacyMap = new Map<Id, Legacy_Billing_Item__c>(this.legacyBillingItems);
                        
            if (legacyMap.containsKey(this.legacyBillingItemId)) {
                Id invoiceId = legacyMap.get(this.legacyBillingItemId).Legacy_Pro_forma_Invoice__c;
                LegacyBillingItemServices.updateTotalCommissionableAmount(new Map<Id, Legacy_Pro_forma_Invoice__c>(LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(new Set<Id> { invoiceId })));
           
            }
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        
        }
        PageReference pageRef = new PageReference('/' + this.legacyProformaInvoice.Id);
        pageRef.setRedirect(true);
        return pageRef;
    
    }

}