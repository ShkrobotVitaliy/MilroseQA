public with sharing class ProFormaLegacyBillingItemController {
    private static final Integer COUNT_RECORDS = Integer.valueOf(MilroseSetting__c.getInstance('Number_of_Rows_in_Legacy_Generator').Custom_Number__c);
    
    private String queryWhere;
    
    /* Filter fields */
    public String billingClientCompanyFilter { get; set; }
    public String accountingContactCompanyFilter { get; set; }
    public String mrcFilter { get; set; }
    public String projectAddressFilter { get; set; }
    public String deliveryMethodFilter { get; set; }
    public Boolean notBilliableFilter { get; set; }
    
    public Boolean isVisibleSaveButton {
        get {
            return UserServices.getProfile().Name.equals(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) ||
                   UserServices.getProfile().Name.equals(UserServices.PROFILE_DIRECTOR_OF_OPERATIONS) || //MRS-6507
                   UserServices.getProfile().Name.contains(UserServices.PROFILE_STAFF_ACCOUNTANT);
        
        }
        private set;
    
    }
    
    public Boolean availableGenerateInvoice { 
        get {
            return null == this.legacyBillingItems || this.legacyBillingItems.isEmpty();
        
        }
        set; 
    }
    
    public List<LegacyBillingItemWrapper> legacyBillingItems { 
        get;
        set; 
    }
    
    public List<SelectOption> deliveryMethodOptions {
        get {
            if (null == this.deliveryMethodOptions) {
                this.deliveryMethodOptions = new List<SelectOption>();

                Schema.DescribeSObjectResult objDescribe = Legacy_Billing_Item__c.SObjectType.getDescribe();
                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                
                for (Schema.PicklistEntry a : fieldMap.get('Delivery_Method_Formula__c').getDescribe().getPickListValues()) {
                    deliveryMethodOptions.add(new SelectOption(a.getLabel(), a.getValue()));
                
                }
                this.deliveryMethodOptions.add(new SelectOption('', 'All'));
                this.deliveryMethodOptions.sort();
            
            }
            return this.deliveryMethodOptions;
        
        }
        set;
    }
    
    public ProFormaLegacyBillingItemController() {
    
    }

    public void search() {
        try {
            createLegacyBillingItemsView();
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
     
    }
    
    private void createLegacyBillingItemsView() {
        String sortBy = 'MRC__c ASC';
        
        this.queryWhere = LegacyBillingItemServices.buildQueryWhere(this.billingClientCompanyFilter, this.accountingContactCompanyFilter, this.mrcFilter, 
                                                                    this.projectAddressFilter, this.deliveryMethodFilter, this.notBilliableFilter);
        
        this.legacyBillingItems = null;
        this.legacyBillingItems = new List<LegacyBillingItemWrapper>(LegacyBillingItemWrapper.getLegacyBillingItemWrapper(Database.query(LegacyBillingItemServices.buildQuerySelect(this.queryWhere, sortBy))));
       
    }
    
    //Action: Generate Invoices Button
    public void generateInvoices() {
        List<Legacy_Billing_Item__c> items = LegacyBillingItemWrapper.getSelectedBillingItemWrapper(this.legacyBillingItems);
         
        if (items.isEmpty()) {
            return;
        
        }
        
        Map<Id, Legacy_Billing_Item__c> lbiMap = new Map<Id, Legacy_Billing_Item__c>(items);
        if (LegacyBillingItemWrapper.isLBIsBilled(lbiMap.keySet())) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ErrorException.LEGACY_BILLED_SELECTED_RECORDS));
            return;
        
        }
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            //Generate Legacy Proforma Invoices
            LegacyProformaInvoiceServices.generateLegacyInvoices(items);
        
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        } finally {
            //Refresh View Legacy Billing Items
            createLegacyBillingItemsView();
      
        }
    
    }
    
    //Action: Save Changes Button
    public void saveChanges() {
        try {
            //Save changes
            LegacyBillingItemWrapper.updateLegacyBillingItemWrapper(this.legacyBillingItems);
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
    
    }

}