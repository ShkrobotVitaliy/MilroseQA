@isTest
private class TestRegionServices {
    
    private static testmethod void testGetRegionsMap() {
         Map<Id, Region__c> regionMap = RegionServices.getRegionsMap();
    
    }
    
    private static testmethod void testGetRegionIdToNameToRFIScope() {
        Map<Id, Map<String, RFI_Scope__c>> idToRFIMap = RegionServices.getRegionIdToNameToRFIScope(new Set<Id>()); 
    
    }
    
    private static testmethod void testGetRegionIdsByProjects() {
        Set<Id> regionIds  = RegionServices.getRegionIdsByProjects(new List<Project_Profile__c>());
    
    }

}