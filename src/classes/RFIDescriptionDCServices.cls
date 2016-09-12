public with sharing class RFIDescriptionDCServices {
	public static void insertRFIDescriptionForDCRegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_DC__c> rfiDescriptions = new List<RFI_Scope_Description_DC__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_DC__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;
                
                Integer index = 0;
                for (RFI_Scope_Description_DC__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_DC__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionDC {
        get{
            if( describeDescriptionDC == null ){
                describeDescriptionDC = RFI_Scope_Description_DC__c.getSObjectType().getDescribe();
            }
            return describeDescriptionDC;
        }
        private set;
    }

    public static String dcRegionFieldsQuery() {
        String query = ', RFI_Scope_Description_DC__r.';
        query += String.join( new List<String>( describeDescriptionDC.fields.getMap().keySet() ), ', RFI_Scope_Description_DC__r.' );
        query += ', RFI_Scope_Description_DC__c';

        return query;
    }
}