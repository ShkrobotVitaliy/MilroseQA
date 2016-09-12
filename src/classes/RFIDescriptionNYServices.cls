public with sharing class RFIDescriptionNYServices {
    public static void insertRFIDescriptionForNYRegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_New_York__c> rfiDescriptions = new List<RFI_Scope_Description_New_York__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_New_York__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;
                
                Integer index = 0;
                for (RFI_Scope_Description_New_York__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_New_York__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionNewYork {
        get{
            if( describeDescriptionNewYork == null ){
                describeDescriptionNewYork = RFI_Scope_Description_New_York__c.getSObjectType().getDescribe();
            }
            return describeDescriptionNewYork;
        }
        private set;
    }

    public static String nyRegionFieldsQuery() {
        String query = ', RFI_Scope_Description_New_York__r.';
        query += String.join( new List<String>( describeDescriptionNewYork.fields.getMap().keySet() ), ', RFI_Scope_Description_New_York__r.' );
        query += ', RFI_Scope_Description_New_York__c';

        return query;
    }
}