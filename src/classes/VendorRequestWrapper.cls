public with sharing class VendorRequestWrapper {
    public Vendor_Request__c vendor { get; set; }
    public Boolean isSelected { get; set; }
    
    public VendorRequestWrapper(Vendor_Request__c vendor) {
        this.vendor = vendor;
        this.isSelected = false;
    
    }
    
    public static List<Vendor_Request__c> getVendorFromWrapper(List<VendorRequestWrapper> vendorsWrapper) {
        if (null == vendorsWrapper || vendorsWrapper.isEmpty()) {
            return new List<Vendor_Request__c>();
        
        }
        
        List<Vendor_Request__c> vendorRequests = new List<Vendor_Request__c>(); 
        
        for (VendorRequestWrapper wrap : vendorsWrapper) {
            vendorRequests.add(wrap.vendor);
        
        }
        return vendorRequests;
    
    }
    
    public static List<Vendor_Request__c> getSelectedVendorFromWrapper(List<VendorRequestWrapper> vendorsWrapper) {
        if (null == vendorsWrapper || vendorsWrapper.isEmpty()) {
            return new List<Vendor_Request__c>();
        
        }
        
        List<Vendor_Request__c> vendorRequests = new List<Vendor_Request__c>(); 
        
        for (VendorRequestWrapper wrap : vendorsWrapper) {
            if (wrap.isSelected) {
                vendorRequests.add(wrap.vendor);
                
            }
        
        }
        return vendorRequests;
    
    }
    
    public static Set<Id> getContactIdsFromSelectedVendors(List<VendorRequestWrapper> vendorsWrapper) {
        if (null == vendorsWrapper || vendorsWrapper.isEmpty()) {
            return new Set<Id>();
        
        }
        
        Set<Id> vendorIds = new Set<Id>(); 
        
        for (VendorRequestWrapper vendor : vendorsWrapper) {
            if (vendor.isSelected) {
                vendorIds.add(Id.valueOf(vendor.vendor.Vendor_Contact__c));
            
            }
        
        }
        return vendorIds;
    
    }

}