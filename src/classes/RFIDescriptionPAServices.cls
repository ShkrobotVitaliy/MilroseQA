public with sharing class RFIDescriptionPAServices {
	public static void insertRFIDescriptionForPARegion(List<RFI_Scope__c> rfiScopes) {
        if( rfiScopes.isEmpty() ) return;
        List<RFI_Scope_Description_PA__c> rfiDescriptions = new List<RFI_Scope_Description_PA__c>();

        for (RFI_Scope__c rfi : rfiScopes) {
            rfiDescriptions.add( new RFI_Scope_Description_PA__c() );
        }
        
        if (!rfiDescriptions.isEmpty()) {
            try {
                insert rfiDescriptions;

                Integer index = 0;
                for (RFI_Scope_Description_PA__c description : rfiDescriptions) {
                    rfiScopes.get(index++).RFI_Scope_Description_PA__c = description.Id;
                }
            } catch(Exception ex) {
                throw new ErrorException('Exception occured during insert rfi description for PENN/MD/DE  Region: ' + ex.getMessage());
            }
        }
    }

    @TestVisible
    private static Schema.DescribeSObjectResult describeDescriptionPa {
        get{
            if( describeDescriptionPa == null ){
                describeDescriptionPa = RFI_Scope_Description_PA__c.getSObjectType().getDescribe();
            }
            return describeDescriptionPa;
        }
        private set;
    }

    public static String paRegionFieldsQuery() {
        String query = ', RFI_Scope_Description_PA__r.';
        query += String.join( new List<String>( describeDescriptionPa.fields.getMap().keySet() ), ', RFI_Scope_Description_PA__r.' );
        query += ', RFI_Scope_Description_PA__c';

        return query;
    }
}