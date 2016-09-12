public with sharing class ServiceTemplateServices {
    public static final String LETTER_OF_COMPLETION = 'letter of completion';
    public static final String SINGLE_LETTER_OF_COMPLETION = 'single letter of completion';
    public static final String CONSTRUCTION_WORK_PERMIT = 'construction work permit';
    public static final String SINGLE_CONSTRUCTION_WORK_PERMIT = 'single construction work permit';
    public static final String AMENDMENT_APPLICATION_FILING  = 'Amendment-Application Filing';
    public static final String TYPE_CERTIFICATE_OF_APPROVAL_COMPLETION  = 'Certificate of Approval / Completion';
    public static final String TYPE_SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION  = 'Single Certificate of Approval / Completion';

    public static Map<Id, Service_Template__c> filterServiceTemplateTaxCode(List<Service_Template__c> newServiceTemplateList, Map<Id, Service_Template__c> oldServiceTemplateMap ) {
        Map<Id, Service_Template__c> serviceTemplateMap = new Map<Id, Service_Template__c>();
        for (Service_Template__c service : newServiceTemplateList) {   
            if( oldServiceTemplateMap.get( service.Id ).Tax_Code_1__c != service.Tax_Code_1__c || 
                oldServiceTemplateMap.get( service.Id ).Tax_Code_2__c != service.Tax_Code_2__c
             ) {
                serviceTemplateMap.put(service.Id, service);
            }      
        }
        return serviceTemplateMap;
    } 

    public static void updateServiceItemTaxCode( Map<Id, Service_Template__c> serviceTemplateMap ) {
        Map<Id, Service_Item__c> serviceItemMap = getServiceItemsMapByServiceId( serviceTemplateMap.keySet() );     
        List<Service_Item__c> serviceItems = serviceItemMap.values();   
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        Set<Id> taxCodeIdSet = new Set<Id>();

        List<AggregateResult> sumCompleteTaskItems = [SELECT Service_Item__c, SUM(Billing_Percentage__c) percentage 
                                                      FROM Task_Item__c 
                                                      WHERE Service_Item__c IN : serviceItemMap.keySet() AND Actual_End_Date__c != null
                                                      GROUP BY Service_Item__c];

        Map<Id, Decimal> serviceItemIdToTaskItemBillingPercentage = new Map<Id, Decimal>();
        for(AggregateResult agr : sumCompleteTaskItems) {
            serviceItemIdToTaskItemBillingPercentage.put( (Id)agr.get('Service_Item__c'), (Decimal)agr.get('percentage') );
        }
        for (Service_Item__c serviceItem : serviceItems ) {
            if( !serviceItemIdToTaskItemBillingPercentage.containsKey(serviceItem.Id) || 
                ( serviceItemIdToTaskItemBillingPercentage.containsKey(serviceItem.Id) && serviceItemIdToTaskItemBillingPercentage.get(serviceItem.Id) != 100 ) ) {
                if(serviceItem.Proposal__c != null && serviceItem.Proposal__r.Billing_Company_Name__c != null
                    && (serviceItem.Proposal__r.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c == 'Exempt'
                     || serviceItem.Proposal__r.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c == 'Exempt for Qualifying Products')) { // MRS 7096
                        serviceItem.Tax_Code_1__c = null;
                        serviceItem.Tax_Code_2__c = null;
                } else {
                serviceItem.Tax_Code_1__c = serviceTemplateMap.get(serviceItem.Service_Template__c).Tax_Code_1__c;
                serviceItem.Tax_Code_2__c = serviceTemplateMap.get(serviceItem.Service_Template__c).Tax_Code_2__c;
                serviceItemsToUpdate.add(serviceItem);
                taxCodeIdSet.add(serviceTemplateMap.get(serviceItem.Service_Template__c).Tax_Code_1__c);
                taxCodeIdSet.add(serviceTemplateMap.get(serviceItem.Service_Template__c).Tax_Code_2__c);                
            }
        }
        }
        ServiceItemServices.updateServiceItemTaxCode(serviceItemsToUpdate, taxCodeIdSet, true);
    }
    
    /**
     * Set default short service name for new service templates.
     * Called from insert before trigger.
     */
    public static void updateDefaultShortServiceName(List<Service_Template__c> newList) {
    	for (Service_Template__c st: newList) {
    		if ( String.isBlank(st.Short_Service_Name__c) ) {
    			String shortName = '';
    			if ( !String.isBlank(st.Short_Subtype__c) ) shortName += st.Short_Subtype__c;
    			if ( !String.isBlank(st.Short_Work_Type__c) ) {
    				String shWt = st.Short_Work_Type__c;
    				if ( !String.isBlank(shortName) ) shWt = ' for ' + shWt;
    				shortName += shWt;
    			}
    			if ( !String.isBlank(st.Short_Plan_Submission_Type__c) ) {
    				String shPst = st.Short_Plan_Submission_Type__c;
    				if ( !String.isBlank(shortName) ) shPst = ' - ' + shPst;
    				shortName += shPst;
    			}
    			if ( !String.isBlank(shortName) ) st.Short_Service_Name__c = shortName;
    		}
    	}
    }

    public static List<Service_Item__c> getServiceItemsByServiceId(Set<Id> ids) {
        return new List<Service_Item__c> ([SELECT Tax_Code_2__c, Tax_Code_1__c, Service_Template__c, Name, Service_Name_Short__c,
                                                Id, Met_Data_Scanning_Fee__c, Total_Service_Price__c, Tax_Value_1__c,
                                                Tax_Value_2__c,
                                                Proposal__c, Proposal__r.Billing_Company_Name__c, Proposal__r.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c, /* MRS 7096 */
                                                (SELECT Id__c FROM Billing_Line_Items_del__r)
                                           FROM Service_Item__c 
                                           WHERE Service_Template__c IN: ids]);
    }  

    public static Map<Id, Service_Item__c> getServiceItemsMapByServiceId(Set<Id> ids) {
        return new Map<Id, Service_Item__c> ([SELECT Tax_Code_2__c, Tax_Code_1__c, Service_Template__c, Name, Service_Name_Short__c,
                                                Id, Met_Data_Scanning_Fee__c, Total_Service_Price__c, Tax_Value_1__c,
                                                Tax_Value_2__c,
                                                Proposal__c, Proposal__r.Billing_Company_Name__c, Proposal__r.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c, /* MRS 7096 */
                                                (SELECT Id__c FROM Billing_Line_Items_del__r)
                                           FROM Service_Item__c 
                                           WHERE Service_Template__c IN: ids]);
    }  

    private static List<Id> getServiceIds(List<Service_Template__c> services) {
        List<Id> ids = new List<Id>();
        for (Service_Template__c service : services) {
            ids.add(service.Id);
        }
        return ids;
    }

    public static map<Id, Service_Template__c> filterMetDataScanningFee(map<Id, Service_Template__c> serviceTemplatesNew, map<Id, Service_Template__c> serviceTemplatesOld) {
        map<Id, Service_Template__c> serviceTemplateMap = new map<Id, Service_Template__c>();
        for(id serviceTemplateId : serviceTemplatesNew.keySet()) {
           if(serviceTemplatesOld != null && serviceTemplatesOld.containsKey( serviceTemplateId )  ) {
               if(serviceTemplatesOld.get(serviceTemplateId).Met_Data_Scanning_Fee__c != serviceTemplatesNew.get(serviceTemplateId).Met_Data_Scanning_Fee__c) {
                    serviceTemplateMap.put(serviceTemplateId, serviceTemplatesNew.get(serviceTemplateId));
               }
           } else if(serviceTemplatesNew.get(serviceTemplateId).Met_Data_Scanning_Fee__c != null ) {
               serviceTemplateMap.put(serviceTemplateId, serviceTemplatesNew.get(serviceTemplateId));
           }
        }
        return serviceTemplateMap;
    }

    public static void updateMetDataScanningFee(map<Id, Service_Template__c> serviceTemplatesMap) {
        List<Service_Item__c> serviceItemList = ServiceTemplateServices.getServiceItemsByServiceId(serviceTemplatesMap.keySet());
        for(Service_Item__c serviceItem : serviceItemList) {
            serviceItem.Met_Data_Scanning_Fee__c = serviceTemplatesMap.get(serviceItem.Service_Template__c).Met_Data_Scanning_Fee__c;
        }
        try {
            update serviceItemList;
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                for ( Service_Template__c serviceTemplate: serviceTemplatesMap.values() ){
                    serviceTemplate.addError( 'Error updating service items' + dmlEx.getMessage() );
                }
            }
        }
    }

	public class ServiceTempateWrapperSortable implements Comparable { // MRS 7246
		public Service_Template__c serviceItemTemplate;
		public serviceTempateWrapperSortable(Service_Template__c serviceItemTemplate) {
			this.serviceItemTemplate = serviceItemTemplate;
		}
		public Integer compareTo( Object compareTo ) {
	        ServiceTempateWrapperSortable compareToSITwrapper = (ServiceTempateWrapperSortable)compareTo;
	    	return serviceItemTemplate.Service_Name_Full__c < compareToSITwrapper.serviceItemTemplate.Service_Name_Full__c ? -1 : 1;
	        return 0;
	    }
	}

	public static List<List<String>> getSortedListOfServiceTempates(List<Service_Template__c> templates) { // MRS 7335
		List<ServiceTempateWrapperSortable> serviceTemplatesSortable = new List<ServiceTempateWrapperSortable>();
		for(Service_Template__c serviceTemplate : templates) serviceTemplatesSortable.add(new ServiceTempateWrapperSortable(serviceTemplate));
		serviceTemplatesSortable.sort();
		List<List<String>> res = new List<List<String>>();
		for(ServiceTempateWrapperSortable serviceSortableWrapper : serviceTemplatesSortable) {
			res.add(new List<String> { String.valueOf(serviceSortableWrapper.serviceItemTemplate.Id), serviceSortableWrapper.serviceItemTemplate.Service_Name_Full__c });
		}		
		return res;
	}

}