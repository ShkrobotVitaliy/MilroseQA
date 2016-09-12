public class RFIWorkTypeServices {
     public static final String NYC_RFI05 = 'NYC_RFI05';
     public static final Set<String> rfiWithWorkTypes = new Set<String>{'NYC_RFI05', 'CT_RFI04', 'NJ_RFI04', 'DC_RFI02', 'PA_RFI02', 'LI_RFI04', 'PA_RFI02'};
     
     //---------------------------------------------------- Begin Business Logic Methods ----------------------------------------------------------------------------------------//
     public static void createRFIWorkType(Map<Id, RFI_Scope__c> rfiMap) {
        List<RFI_Work__c> rfiWorkTypes = new List<RFI_Work__c>();
        Set<String> workTypeSet;
        RFI_Work__c rfiWorkType;
        Boolean isApp, isSignOff;
           
        for (RFI_Scope__c rfi : RFIScopeServices.getRFIScopeWithServiceItemById(rfiMap.keySet()).values()) {
            if ( rfiWithWorkTypes.contains(rfi.Name) )  {
                isApp = false;
                isSignOff = false;
                workTypeSet = new Set<String>();
                
                if (!String.isBlank(rfi.Application_Service_Item__c) && null != rfi.Application_Service_Item__r && null != rfi.Application_Service_Item__r.Work_Type__c) {
                    isApp = true;
                    
                    for (String workTypeName : rfi.Application_Service_Item__r.Work_Type__c.split(';', -1)) {
                        workTypeSet.add(workTypeName.trim());
                        
                    }
                    
                }
                
                if (!String.isBlank(rfi.Sign_Off_Service_Item__c) && null != rfi.Sign_Off_Service_Item__r && null != rfi.Sign_Off_Service_Item__r.Work_Type__c) {
                    isSignOff = true;
                    
                    for (String workTypeName : rfi.Sign_Off_Service_Item__r.Work_Type__c.split(';', -1)) {
                        workTypeSet.add(workTypeName.trim());
                    
                    }
                
                }
                
                for (String workTypeName : workTypeSet) {
                    rfiWorkType = new RFI_Work__c(Name = workTypeName);
                    
                    rfiWorkType.RFI_Scope__c = rfi.Id;
                    rfiWorkType.Application_Service_Item__c = isApp ? rfi.Application_Service_Item__c : null;
                    rfiWorkType.Sign_Off_Service_Item__c    = isSignOff ? rfi.Sign_Off_Service_Item__c : null;
                    
                    rfiWorkTypes.add(rfiWorkType);
                
                }
                
            }
        
        }
        
        try {
            insert rfiWorkTypes;
        
        } catch(Exception ex) {
            throw new ErrorException(ex.getMessage());
        
        }
        
    }
    //---------------------------------------------------- End Business Logic Methods ----------------------------------------------------------------------------------------//
    
    /* ------------------------------------------------ Begin DAO Methods ----------------------------------------------------------------------- */
    public static List<RFI_Work__c> getWorkTypeByServiceItemId(Id serviceItemId) {
        if (String.isBlank(serviceItemId)) {
            throw new ErrorException(ErrorException.SERVICE_ITEM_EMPTY_ID);
        
        }
        
        return new List<RFI_Work__c>([SELECT Id, Name, Actual_Costs__c, Estimated_Cost__c, Filing_Fee__c, Application_Service_Item__c,
                                             Sign_Off_Service_Item__c
                                      FROM RFI_Work__c 
                                      WHERE (Application_Service_Item__c =: serviceItemId OR Sign_Off_Service_Item__c =: serviceItemId) 
                                             AND RFI_Scope__c =: RFIScopeServices.getRFIScopeIdsByServiceItemId(serviceItemId)]);
    }
    
    public static List<RFI_Work__c> getWorkTypeByServiceItemIds(Set<Id> serviceItemIds) {
        if (null == serviceItemIds || serviceItemIds.isEmpty()) {
            return new List<RFI_Work__c>();
            //throw new ErrorException(ErrorException.SERVICE_ITEM_EMPTY_ID);
        
        }
        
        return new List<RFI_Work__c>([SELECT Id, Name, Actual_Costs__c, Estimated_Cost__c, Filing_Fee__c, Application_Service_Item__c,
                                             Sign_Off_Service_Item__c 
                                      FROM RFI_Work__c 
                                      WHERE (Application_Service_Item__c IN: serviceItemIds OR Sign_Off_Service_Item__c IN: serviceItemIds)
                                             AND RFI_Scope__c =: RFIScopeServices.getRFIScopeIdsByServiceItemIds(serviceItemIds)]);
    }
    /* ------------------------------------------------ End DAO Methods ------------------------------------------------------------------------- */

}