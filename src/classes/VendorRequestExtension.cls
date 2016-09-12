public with sharing class VendorRequestExtension {
    @TestVisible private List<Vendor_Request__c> vendorRequests {
        get {
            if (null == this.vendorRequests) {
                this.vendorRequests = VendorRequestServices.getVendorsByTaskItemId(this.taskItem.Id);
            
            }
            return this.vendorRequests;
        }
        set;
    }
    
    @TestVisible private Boolean isNotifyVendor {
        get {
            if (null == this.isNotifyVendor) {
                return false;
            
            }
            return this.isNotifyVendor;
        }
        set;
    }
    
    @TestVisible private Boolean isRequestedVendor {
        get {
            if (null == this.isRequestedVendor) {
                return false;
            
            }
            return this.isRequestedVendor;
        }
        set;
    }
    
    @TestVisible private List<Vendor_Request__c> vendorsToUpdate {
        get {
            if (null == this.vendorsToUpdate) {
                this.vendorsToUpdate = new List<Vendor_Request__c>();
            
            }
            return this.vendorsToUpdate;
        }
        set;
    }
    
    public Contact contactRecipient { 
        get {
            if (null == this.contactRecipient) {
                this.contactRecipient = new Contact();
            
            }
            return this.contactRecipient;
        
        }
        set;
    }
    
    public String emailTypeRecord { 
        get { 
            return MergeEmailTemplate.STANDARD_PARSING_EMAIL; 
        
        } 
        private set; 
    }

    public Task_Item__c taskItem { get; set; }
    public Boolean reviewEmail { get; set; }
    
    public String sendTo { get; set; }
    public String emailsAddressForDrawLoop { get; set; }
    public String emailTemplateName { get; set; }
    
    public String draftTemplateName { 
        get { 
            return VendorRequestServices.VENDOR_ACTIVITY_DRAFT_TEMPLATE_NAME;
        
        }
        private set; 
    }
    
    public String drawloopName { 
        get { 
            return VendorRequestServices.VENDOR_ACTIVITY_DRAWLOOP_NAME;
        
        }
        private set; 
    }
    
    public List<VendorRequestWrapper> vendors { 
        get {
            if (null == this.vendors) { 
                this.vendors = new List<VendorRequestWrapper>();
                
                if (this.taskItem.Show_only_Accepted_Activities__c) {
                    for (Vendor_Request__c vendor : this.vendorRequests) {
                        if (VendorRequestServices.VENDOR_PROPOSAL_ACCEPTED.equals(vendor.Status_of_Request__c)) {
                            this.vendors.add(new VendorRequestWrapper(vendor));
                            
                        }
                    
                    }
                
                } else {
                    for (Vendor_Request__c vendor : this.vendorRequests) {
                        this.vendors.add(new VendorRequestWrapper(vendor));
                    
                    }
                
                }
            
            }
            return this.vendors; 
        
        }
        set; 
    }
    
    public Project_Profile__c project {
        get {
            if (null == this.project) {
                this.project = ProjectProfileServices.getProjectById(this.taskItem.Project_Profile__c);
            
            }
            return this.project;
        
        }
        set;
    
    }
    
    public List<Id> attachmentIds {
        get {
            if (null == this.attachmentIds) {
                this.attachmentIds = new List<Id>();
                this.attachmentIds.add(this.taskItem.Project_Profile__c);
                this.attachmentIds.add(this.taskItem.Project_Profile__r.Proposal__c);
                this.attachmentIds.add(this.taskItem.Service_Item__c);
                this.attachmentIds.add(this.taskItem.Id);
                for( RFI_Scope__c rfi: project.RFI_Scopes__r){
                    this.attachmentIds.add(rfi.Id);
                }
            }
            return this.attachmentIds;
            
        }
        private set;
    }
    
    public String selectedVendorId { get; set; }
    public String linkToCloseTemplate { get; private set;}
    public Boolean displaySelectionTemplate { get; private set; }
    
    public VendorRequestExtension(ApexPages.StandardController controller) {
        this.taskItem            = (Task_Item__c)controller.getRecord();
        this.reviewEmail         = false;
        this.linkToCloseTemplate =  '/' + String.valueOf(this.taskItem.id);
        
    }
    
    //Button Action: Add new Vendor Request
    public void addVendor() {
        try {
            Vendor_Request__c vendor = VendorRequestServices.newInstance(this.taskItem);
            this.vendorRequests.add(vendor);
            this.vendors.add(new VendorRequestWrapper(vendor));
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
    
    }
    
    //Button Action: Save Changes Vendor Request
    public void saveChanges() {
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<Vendor_Request__c> vendors = VendorRequestWrapper.getVendorFromWrapper(this.vendors);
            
            VendorRequestServices.updateVendors(vendors);
            update this.taskItem;
            
            List<Billing_Line_Item__c> lineItems = getReimbursableLineItemForPassExpanse(vendors);
            if (lineItems.size() > 0) {
                insert lineItems;
                update vendors;
            
            }
            
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
    }
    
    @TestVisible
    private List<Billing_Line_Item__c> getReimbursableLineItemForPassExpanse(List<Vendor_Request__c> vendors) {
        if (null == this.taskItem.Actual_End_Date__c) {
            return new List<Billing_Line_Item__c>();
        
        }
        
        List<Billing_Line_Item__c> lineItems = new List<Billing_Line_Item__c>();
        
        for (Vendor_Request__c vendor : vendors) {
            if (!vendor.Is_Reimbursable_Line_Item_Created__c && vendor.Pass_Through_Expense__c) {
                vendor.Is_Reimbursable_Line_Item_Created__c = true;
                lineItems.add(BillingLineItemServices.newInstance(this.taskItem, vendor));
            
            }
        
        }
        return lineItems;
    
    }
    
    //Checkbox Action Show Only Accepted Vendor(s)
    public void showOnlyAcceptedActivities() {         
        this.vendors = new List<VendorRequestWrapper>();
        
        if (this.taskItem.Show_only_Accepted_Activities__c) {
            for (Vendor_Request__c vendor : this.vendorRequests) {
                if (VendorRequestServices.VENDOR_PROPOSAL_ACCEPTED.equals(vendor.Status_of_Request__c)) {
                    this.vendors.add(new VendorRequestWrapper(vendor));
                    
                }
            
            }
        
        } else {
            for (Vendor_Request__c vendor : this.vendorRequests) {
                this.vendors.add(new VendorRequestWrapper(vendor));
            
            }
        
        }
        
        update taskItem;
                
    }
    
    //Button Action: Email Request
    public void showTemplateEditing() {
        this.vendorsToUpdate = new List<Vendor_Request__c>();
        
        for (Vendor_Request__c vendor : VendorRequestWrapper.getSelectedVendorFromWrapper(this.vendors)) {
            this.vendorsToUpdate.add(vendor);
        
        }
        
        try {
            this.displaySelectionTemplate = true;
            this.isRequestedVendor   = true;
            this.isNotifyVendor      = false;
            saveEmailAddress(getEmailAddrressToSend(), VendorRequestServices.VENDOR_ACTIVITY_TEMPLATE_NAME);
    
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ex.getMessage()));
        
        }
    
    }
    
    //Button Action: Notify Vendor
    public void notifyVendor() {
        List<Id> acceptedVendorsContacts = new List<Id>();
        List<Id> declinedVendorsContacts = new List<Id>();
        this.vendorsToUpdate             = new List<Vendor_Request__c>();
        
        this.isRequestedVendor        = false;
        this.displaySelectionTemplate = false;
        
        for (Vendor_Request__c vendor : VendorRequestWrapper.getSelectedVendorFromWrapper(this.vendors)) {
            if (VendorRequestServices.VENDOR_PROPOSAL_ACCEPTED.equals(vendor.Status_of_Request__c)) {
                acceptedVendorsContacts.add(vendor.Vendor_Contact__c);
                this.vendorsToUpdate.add(vendor);

            } else if (VendorRequestServices.VENDOR_PROPOSAL_DECLINED.equals(vendor.Status_of_Request__c)) {
                declinedVendorsContacts.add(vendor.Vendor_Contact__c);
                this.vendorsToUpdate.add(vendor);
            
            }
        
        }
        
        if (acceptedVendorsContacts.isEmpty() && declinedVendorsContacts.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.VENDOR_REQUEST_NOT_VENDOR_FOR_NOTIFY));
            return;
        
        } else {
            this.isNotifyVendor = true;
        
        }
        
        try {
            if (!acceptedVendorsContacts.isEmpty() && declinedVendorsContacts.isEmpty()) {
                saveEmailAddress(getEmailAddrressToSend(), VendorRequestServices.VENDOR_ACTIVITY_TEMPLATE_ACCEPTED);
                
            } else if (!declinedVendorsContacts.isEmpty() && acceptedVendorsContacts.isEmpty()) {
                saveEmailAddress(getEmailAddrressToSend(), VendorRequestServices.VENDOR_ACTIVITY_TEMPLATE_DECLINED);

            } else {
               ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Accepted and Declined notifications cannot be send at the same time.'));
               return;
               
            }
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ex.getMessage()));
            return;
        
        }
        
    }
    
    @TestVisible private void saveEmailAddress(String emailsToSend, String templateName) {
        try {
            this.taskItem.DrawLoopEmailAddress__c   = emailsToSend;
            this.taskItem.DrawLoopEmailCCAddress__c = '';
            update this.taskItem;
            
            this.emailTemplateName = templateName;                            
            this.reviewEmail       = true;
        
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
    }
    
    @TestVisible private String getEmailAddrressToSend() {
        Set<Id> contactIds = VendorRequestWrapper.getContactIdsFromSelectedVendors(this.vendors);
        
        if (contactIds.isEmpty()) {
            throw new ErrorException(ErrorException.VENDOR_REQUEST_SELECT_AT_LEAST_ONE);

        }
                
        String emailsToSend     = '';
        this.sendTo             = '';
        Integer countEmptyEmail = 0;
        
        for (Contact cont : ContactServices.getContactsByIds(contactIds)) {    
            if (null != cont.Email) {
                emailsToSend += cont.Email + ';';
                this.sendTo  += cont.Name + '(' + cont.Email + ');';
            
            } else {
                countEmptyEmail +=1;
            
            }
        
        }
        
        if (String.isBlank(emailsToSend) || String.isBlank(this.sendTo) || countEmptyEmail > 0) {
            throw new ErrorException(ErrorException.VENDOR_REQUEST_EMPTY_EMAIL);

        }
        return emailsToSend;
    
    }
    
    //Checkbox Action: Pass Through Expense    
    public void passThroughExpenseAction() {
        
    }
    
    //Fill Scheduled Date
    public void fillScheduledDate() {
        if (String.isBlank(this.selectedVendorId)) {
            return;
        
        }
        
        Map<Id, Vendor_Request__c> vendorsMap = new Map<Id, Vendor_Request__c>(VendorRequestWrapper.getVendorFromWrapper(this.vendors));
    
        if (vendorsMap.containsKey(this.selectedVendorId) && (null != vendorsMap.get(this.selectedVendorId).Scheduled_Start_Date__c || null != vendorsMap.get(this.selectedVendorId).Scheduled_End_Date__c)) {
            vendorsMap.get(this.selectedVendorId).Activity_Status__c = 'Scheduled';
        
        }
    
    }
    
    //Fill Proposal Received Date
    public void fillProposalReceivedDate() {
        if (String.isBlank(this.selectedVendorId)) {
            return;
        
        }
        
        Map<Id, Vendor_Request__c> vendorsMap = new Map<Id, Vendor_Request__c>(VendorRequestWrapper.getVendorFromWrapper(this.vendors));
    
        if (vendorsMap.containsKey(this.selectedVendorId) && VendorRequestServices.VENDOR_STATUS_OF_REQUEST_RECEIVED.equals(vendorsMap.get(this.selectedVendorId).Status_of_Request__c)) {
            vendorsMap.get(this.selectedVendorId).Proposal_Received_Date__c = datetime.now();
        
        }
    
    }
    
    //Callback Action: save CC Emails Address
    public void updateCCEmailsAddressForDrawLoop () {
        try {
            this.taskItem.DrawLoopEmailCCAddress__c = this.emailsAddressForDrawLoop;
            update this.taskItem;
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
            
        }
    
    }
    public Datetime reminderDatetime { get; set; }

    //Callback Action: update record
    public void updateAfterSend() {
        try {
            if (null == this.vendorsToUpdate) {
                return;
            }
            Datetime currentDate = datetime.now();
            
            for (Vendor_Request__c vendor : this.vendorsToUpdate) {
                if (this.isRequestedVendor) {
                    vendor.Status_of_Request__c     = VendorRequestServices.VENDOR_ACTIVITY_STATUS_SENT;
                    vendor.Activity_Request_Date__c = currentDate;
                } else if (this.isNotifyVendor) {
                    this.isNotifyVendor       = false;
                    vendor.Vendor_Notified__c = currentDate;
                }

                //Set reminder data
                if( this.reminderDatetime != null ){
                    Integer index = 0;
                    for( String email : String.isBlank(emailsAddressForDrawLoop) ? new List<String>() : this.emailsAddressForDrawLoop.split(';') ) {
                        if (0 == index) {
                            vendor.Email_Address_CC1__c = email;
                        } else if (1 == index) {
                            vendor.Email_Address_CC2__c = email;
                        } else if (2 == index) {
                            vendor.Email_Address_CC3__c = email;
                        } else if (3 == index) {
                            vendor.Email_Address_CC4__c = email;
                        } else if (4 == index) {
                            vendor.Email_Address_CC5__c = email;
                        }
                        index++;
                    }

                    vendor.Send_Reminder__c = true;
                    vendor.Reminder_Date__c = this.reminderDatetime;
                }
            }
            
            update this.vendorsToUpdate;
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        } finally {
            this.reviewEmail = false;
        }
    }
        
}