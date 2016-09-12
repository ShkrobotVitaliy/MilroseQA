public with sharing class UpdateActiveBillingItem {
    
    private final String lineItemId;
    
    public UpdateActiveBillingItem(ApexPages.StandardController controller) {        
         this.lineItemId = ApexPages.currentPage().getParameters().get('id');
    
    }
    
    public PageReference updateActiveField() {
        
        final Billing_Line_Item__c lineItem;
        
        if (null == this.lineItemId || String.isBlank(this.lineItemId)) {
            return null;
        
        }
        
        lineItem = [Select b.Id, b.Active_Billing_Line_Item__c
                    From Billing_Line_Item__c b 
                    Where b.Id =: this.lineItemId limit 1];
        
        if(null == lineItem) {
            return null;
        
        }      
        
        try {
            lineItem.Active_Billing_Line_Item__c = lineItem.Active_Billing_Line_Item__c ? false : true;
            update lineItem;
        
        } catch (DMLException ex) {
            system.debug('Exception: ' + ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
            
        }
        
        PageReference page = new PageReference('/' + this.lineItemId);
        page.setRedirect(true);
        return page;

    }

}