public with sharing class RFIDescriptionNJServices {
	public static void insertRFIDescriptionForNJRegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_New_Jersey__c> rfiDescriptions = new List<RFI_Scope_Description_New_Jersey__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_New_Jersey__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;
                
                Integer index = 0;
                for (RFI_Scope_Description_New_Jersey__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_New_Jersey__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionNewJersey {
        get{
            if( describeDescriptionNewJersey == null ){
                describeDescriptionNewJersey = RFI_Scope_Description_New_Jersey__c.getSObjectType().getDescribe();
            }
            return describeDescriptionNewJersey;
        }
        private set;
    }

    public static String njRegionFieldsQuery() {
        String query = ', RFI_Scope_Description_New_Jersey__r.';
        query += String.join( new List<String>( describeDescriptionNewJersey.fields.getMap().keySet() ), ', RFI_Scope_Description_New_Jersey__r.' );
        query += ', RFI_Scope_Description_New_Jersey__c';

        return query;
    }
}