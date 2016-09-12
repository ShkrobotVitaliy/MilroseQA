public with sharing class ProjectServiceModel {
    public List<Service_Item__c> serviceItems { get; set; }

    public Id phaseId { get; set; }
    public String phaseName { get; set; }
    public Integer changeOrderNumber { get; set; }
    public String changeOrderDate { get; set; }
    public String changeOrderStatus { get; set; }
	//public String activityStatus { get; set; }

    public transient Boolean isApproved;
    public Boolean getIsApproved() { return changeOrderStatus == 'Approved'; }

    public transient Boolean isPending;
    public Boolean getIsPending() { return changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT; }

    public transient Boolean isCanceled;
    public Boolean getIsCanceled() { return changeOrderStatus == ChangeOrderServices.STATUS_CANCELED; }

    public void rearrangeServiceItems() {
        Map<Integer, Service_Item__c> serviceItemPositionToServiceItem = new Map<Integer, Service_Item__c>();
        List<Integer> serviceItemsPositions = new List<Integer>();
        for( Service_Item__c si : serviceItems ) {
            serviceItemPositionToServiceItem.put( Integer.valueOf(si.Row_Position_Project__c), si );
            serviceItemsPositions.add( Integer.valueOf(si.Row_Position_Project__c) );
        }
        serviceItemsPositions.sort();
        serviceItems = new List<Service_Item__c>();
        for( Integer position : serviceItemsPositions ) {
            serviceItems.add( serviceItemPositionToServiceItem.get(position) );
        }

    }

    public ProjectServiceModel( Service_Item__c serviceItem, Boolean isAmendment ) {
        if( isAmendment ) {
            changeOrderNumber = serviceItem.Change_Order__r.Number__c != null ? Integer.valueof( serviceItem.Change_Order__r.Number__c ) : null;
            changeOrderDate = serviceItem.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED
                              ? ( serviceItem.Change_Order__r.Approved_Date__c != null
                                  ? serviceItem.Change_Order__r.Approved_Date__c.format()
                                  : '' )
                              : ( serviceItem.Change_Order__r.Last_Change_Date__c != null
                                  ? serviceItem.Change_Order__r.Last_Change_Date__c.format()
                                  : serviceItem.Change_Order__r.CreatedDate.date().format() );
            changeOrderStatus = serviceItem.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED
                                ? 'Approved'
                                : serviceItem.Change_Order__r.Status__c;
        }

        phaseName = serviceItem.Phase__r.Name__c;
        phaseId = serviceItem.Phase__c;
        
		/*activityStatus = ( serviceItem.Is_Amendmend_Deleted__c 
									? ServiceItemServices.SERVICE_STATUS_INACTIVE 
									: serviceItem.Actual_End_Date__c != null 
											? ServiceItemServices.SERVICE_STATUS_COMPLETED
											: serviceItem.Actual_Start_Date__c != null 
													? ServiceItemServices.SERVICE_STATUS_ACTIVE 
													: ServiceItemServices.SERVICE_STATUS_NOTSTARTED );*/


        serviceItems = new List<Service_Item__c>{ serviceItem };
    }
}