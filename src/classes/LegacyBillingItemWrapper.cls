public with sharing class LegacyBillingItemWrapper {

    public Legacy_Billing_Item__c lbi { get; private set; }
    public Boolean selected { get; set; }

    public LegacyBillingItemWrapper(final Legacy_Billing_Item__c lbi) {
        this.lbi = lbi;
        this.selected = false;
        
    }
    
    public static List<LegacyBillingItemWrapper> getLegacyBillingItemWrapper(List<Legacy_Billing_Item__c> legacyItems) {
        if (null == legacyItems || legacyItems.isEMpty()) {
            return new List<LegacyBillingItemWrapper>();
        
        }
        
        List<LegacyBillingItemWrapper> legacyBillingItems = new List<LegacyBillingItemWrapper>();
        
        for(SObject lbi : legacyItems) {
            legacyBillingItems.add(new LegacyBillingItemWrapper((Legacy_Billing_Item__c)lbi));
        
        }
        return legacyBillingItems;
    
    }
    
    public static void updateLegacyBillingItemWrapper(List<LegacyBillingItemWrapper> legacyItems) {
        if (null == legacyItems || legacyItems.isEmpty()) {
            return;
        
        }
        
        List<Legacy_Billing_Item__c> legacyBillingItem = new List<Legacy_Billing_Item__c>();
        
        for (LegacyBillingItemWrapper item : legacyItems) {
            legacyBillingItem.add(item.lbi);
        
        }
        update legacyBillingItem;
    
    }
    
    public static List<Legacy_Billing_Item__c> getSelectedBillingItemWrapper(List<LegacyBillingItemWrapper> legacyItems) {
        if (null == legacyItems || legacyItems.isEmpty()) {
            return new List<Legacy_Billing_Item__c>();
        
        }
        
        List<Legacy_Billing_Item__c> legacyBillingItem = new List<Legacy_Billing_Item__c>();
        
        for (LegacyBillingItemWrapper item : legacyItems) {
            if (item.selected && !item.lbi.Not_Billable__c && !item.lbi.Project_Name_Mi7__r.Prebilled__c) {
                legacyBillingItem.add(item.lbi);
            
            }
        
        }
        return legacyBillingItem;
    
    }
    
    public static Boolean isLBIsBilled(Set<Id> lbiIds) {
        if (null == lbiIds || lbiIds.isEmpty()) {
            return false;
        
        }
        List<Legacy_Billing_Item__c> lbis = new List<Legacy_Billing_Item__c>([SELECT Id, Billed__c 
                                                                              FROM Legacy_Billing_Item__c 
                                                                              WHERE Id IN: lbiIds AND Billed__c = true]);
        
        return !lbis.isEmpty();
        
    }

}