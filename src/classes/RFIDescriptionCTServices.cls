public with sharing class RFIDescriptionCTServices {
    public static void insertRFIDescriptionForCTRegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_CT__c> rfiDescriptions = new List<RFI_Scope_Description_CT__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_CT__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;

                Integer index = 0;
                for (RFI_Scope_Description_CT__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_CT__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description for CT Region: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionCT {
        get{
            if( describeDescriptionCT == null ){
                describeDescriptionCT = RFI_Scope_Description_CT__c.getSObjectType().getDescribe();
            }
            return describeDescriptionCT;
        }
        private set;
    }

    public static String ctRegionFieldsQuery() {
        String query = ', RFI_Scope_Description_CT__r.';
        query += String.join( new List<String>( describeDescriptionCT.fields.getMap().keySet() ), ', RFI_Scope_Description_CT__r.' );
        query += ', RFI_Scope_Description_CT__c';

        return query;
    }
}