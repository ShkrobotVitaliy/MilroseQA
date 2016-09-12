public class VendorRequestServices {
    public static final String VENDOR_ACTIVITY_TEMPLATE_NAME       = 'Request/Assign Vendor Activity';
    public static final String VENDOR_ACTIVITY_DRAFT_TEMPLATE_NAME = 'Request/Assign Vendor Activity Draft';
    public static final String VENDOR_ACTIVITY_TEMPLATE_ACCEPTED   = 'Request/Assign Vendor Accepted';
    public static final String VENDOR_ACTIVITY_TEMPLATE_DECLINED   = 'Request/Assign Vendor Declined';
    public static final String VENDOR_ACTIVITY_DRAWLOOP_NAME       = 'Send Attachments (Vendor Activity)';
    public static final String VENDOR_PROPOSAL_ACCEPTED            = 'Vendor Proposal Accepted';
    public static final String VENDOR_PROPOSAL_DECLINED            = 'Vendor Proposal Declined';
    public static final String VENDOR_REQUEST_RECORD_TYPE_NAME     = 'Request/Assign Vendor Activity';
    public static final String VENDOR_STATUS_OF_REQUEST_RECEIVED   = 'Vendor Proposal Received';
    public static final String VENDOR_ACTIVITY_STATUS_SENT         = 'Request Sent';
    
    /* ------------------------------------------- Begin Business logic Methods -------------------------------------------------------------------*/
    
    public static Vendor_Request__c newInstance(final Task_Item__c taskItem) {
        if (null == taskItem) {
            throw new ErrorException(ErrorException.TASK_ITEM_EMPTY);
            
        }
        
        Vendor_Request__c vendor = new Vendor_Request__c(Task_Item__c = taskItem.Id, Activity_Status__c = 'Unscheduled'); //Status_of_Request__c = 'Request Sent', 
        insert vendor;
        return vendor;
    }
    
    public static void updateVendors(List<Vendor_Request__c> vendors) {
        for (Vendor_Request__c vendor : vendors) {
            if ((null == vendor.Cost__c || 0 == vendor.Cost__c) && vendor.Pass_Through_Expense__c) {
                throw new ErrorException(ErrorException.VENDOR_REQUEST_CANNOT_FILL_COST);
            
            }
            
            if (null != vendor.Scheduled_Start_Date__c && 'Vendor Proposal Accepted' != vendor.Status_of_Request__c) {
                throw new ErrorException(ErrorException.VENDOR_REQUEST_CANNOT_FILL_START_DATE);
            
            }
            
            if (null != vendor.Scheduled_End_Date__c && 'Vendor Proposal Accepted' != vendor.Status_of_Request__c) {
                throw new ErrorException(ErrorException.VENDOR_REQUEST_CANNOT_FILL_END_DATE);
            
            }
            
            if (null != vendor.Scheduled_End_Date__c && null != vendor.Scheduled_End_Date__c && vendor.Scheduled_End_Date__c < vendor.Scheduled_Start_Date__c) {
                throw new ErrorException(ErrorException.VENDOR_REQUEST_START_DATE_LESS_END_DATE);
            
            }
            
            if (null == vendor.Vendor__c) {
                vendor.Vendor_Contact__c = null;
            
            }
        
        }
        
        update vendors;
    
    }
    
    public static void createVendorReimbursableLineItem(final Set<Id> filteredTaskItemIds) {
        if (null == filteredTaskItemIds || filteredTaskItemIds.isEmpty()) {
            return;
        
        }
        
        List<Task_Item__c> taskItems         = TaskItemServices.getTaskItemsByIdsForVendorRequests(filteredTaskItemIds);        
        List<Billing_Line_Item__c> lineItems = new List<Billing_Line_Item__c>();
        List<Vendor_Request__c> vendorItems  = new List<Vendor_Request__c>();
        
        for (Task_Item__c taskItem : taskItems) {
            if (null == taskItem.Vendor_Requests__r || taskItem.Vendor_Requests__r.isEmpty()) {
                continue;
            
            }
            for (Vendor_Request__c vendor : taskItem.Vendor_Requests__r) {
                lineItems.add(BillingLineItemServices.newInstance(taskItem, vendor));
                vendor.Is_Reimbursable_Line_Item_Created__c = true;
                vendorItems.add(vendor);
            
            }
        
        }
        
        Savepoint sp = Database.setSavepoint();
        try {
            insert lineItems;
            update vendorItems;
            
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new ErrorException(ex.getMEssage());
        
        } 
    
    }
    
    public static Set<Id> filteredTaskItemIdsForReimbursableLineItem(final Map<Id, Task_Item__c> oldMap, final List<Task_Item__c> newList) {
        Set<Id> filteredTaskItemIds = new Set<Id>();
        
        for (Task_Item__c taskItem : newList) {
            if (null != taskItem.Actual_End_Date__c && null == oldMap.get(taskItem.Id).Actual_End_Date__c) {
                filteredTaskItemIds.add(taskItem.Id);
            
            }
        
        }
        return filteredTaskItemIds;
    
    }
    /* ------------------------------------------- End Business logic Methods -------------------------------------------------------------------*/
    
    /* ------------------------------------------- Begin DAO Methods -------------------------------------------------------------------*/
    
    public static List<Vendor_Request__c> getVendorsByTaskItemId(Id taskItemId) {
        if (String.isBlank(taskItemId)) {
            throw new ErrorException(ErrorException.TASK_ITEM_ID_EMPTY);
        
        }
        
        return new List<Vendor_Request__c>([SELECT Vendor__c, Vendor_Notified__c, Vendor_Contact__c, Task_Item__c, Status_of_Request__c, Scheduled_Start_Date__c, 
                                                   Scheduled_End_Date__c, Proposal_Received_Date__c, Pass_Through_Expense__c, Name, Id, Description_of_Work__c, 
                                                   Cost__c, Activity_Status__c, Activity_Request_Date__c, Is_Reimbursable_Line_Item_Created__c
                                            FROM Vendor_Request__c
                                            WHERE Task_Item__c =: taskItemId]);
    
    }
    
    /* ------------------------------------------- End DAO Methods -------------------------------------------------------------------*/

}