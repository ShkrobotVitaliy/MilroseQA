public with sharing class RFIDescriptionLIServices {
    public static void insertRFIDescriptionForLIRegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_Long_Island__c> rfiDescriptions = new List<RFI_Scope_Description_Long_Island__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_Long_Island__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;

                Integer index = 0;
                for (RFI_Scope_Description_Long_Island__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_Long_Island__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description for LI Region: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionLongIsland {
        get{
            if( describeDescriptionLongIsland == null ){
                describeDescriptionLongIsland = RFI_Scope_Description_Long_Island__c.getSObjectType().getDescribe();
            }
            return describeDescriptionLongIsland;
        }
        private set;
    }

    public static String liRegionFieldsQuery(){
    	String query = ', RFI_Scope_Description_Long_Island__r.';
        query += String.join( new List<String>( describeDescriptionLongIsland.fields.getMap().keySet() ), ', RFI_Scope_Description_Long_Island__r.' );
        query += ', RFI_Scope_Description_Long_Island__c';
        
        return query;
    }
}