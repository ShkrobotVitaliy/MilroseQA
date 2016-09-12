public with sharing class RegionServices {

    public static final String REGION_NAME_CT            = 'Connecticut';
    public static final String REGION_NAME_DE            = 'Delaware';
    public static final String REGION_NAME_LI            = 'Long Island';
    public static final String REGION_NAME_MD            = 'Maryland';
    public static final String REGION_NAME_NJ            = 'New Jersey';
    public static final String REGION_NAME_NY            = 'New York';
    public static final String REGION_NAME_PENN          = 'Pennsylvania';
    public static final String REGION_NAME_WASH          = 'Washington DC';
    public static final String REGION_NAME_WESTCHESTER   = 'Westchester';
    public static final String REGION_NAME_MASSACHUSETTS = 'Massachusetts';
    public static final String REGION_NAME_PHILADELPHIA  = 'Philadelphia';
    public static final String REGION_NAME_VIRGINIA      = 'Virginia';
    public static final String REGION_NAME_MAINE         = 'Maine'; // MRS 6581
    public static final String REGION_NAME_VERMONT       = 'Vermont';
    public static final String REGION_NAME_NEW_HAMPSHIRE = 'New Hampshire';
    public static final String REGION_NAME_RHODE_ISLAND  = 'Rhode Island';

    public static Map<Id, Region__c> getRegionsMap() {
        return new Map<Id, Region__c>([SELECT Id, Name
                                       FROM Region__c LIMIT 1000]);

    }
    
    public static Map<Id, Map<String, RFI_Scope__c>> getRegionIdToNameToRFIScope(Set<Id> regionIds) {
        Map<Id, Map<String, RFI_Scope__c>> regionIdToNameToRFIScope = new Map<Id, Map<String, RFI_Scope__c>>();
        
        for (RFI_Scope__c rfi : RFIScopeServices.getRFIScopesByRegionIds(regionIds).values()) {
            if (!regionIdToNameToRFIScope.containsKey(rfi.Region__c)) {
                regionIdToNameToRFIScope.put(rfi.Region__c, new Map<String, RFI_Scope__c>());

            }
            regionIdToNameToRFIScope.get(rfi.Region__c).put(rfi.Name, rfi);

       }
       return regionIdToNameToRFIScope;
    
    }
    
    public static List<SelectOption> getRegionOptions() {
        List<SelectOption> regionOptions = new List<SelectOption>();
        
        for (Region__c region : RegionServices.getRegionsMap().values()) {
            regionOptions.add(new SelectOption(region.Name, region.Name));    
        
        }
        return regionOptions;
        
    }
    
    public static Set<Id> getRegionIdsByProjects(List<Project_Profile__c> projects) {
        Set<Id> regionIds = new Set<Id>();
        for (Project_Profile__c project : projects) {
            regionIds.add(project.Region_ID__c);

        }
        return regionIds;
    
    }

}