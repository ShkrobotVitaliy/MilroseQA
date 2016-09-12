@isTest
private class TestBuildingServices {

    @isTest
    private static void testGetBuildinOptionsByBuildingIdEmptyParameter() {
        Test.startTest();
            List<SelectOption> options = BuildingServices.getBuildinOptionsByBuildingId(null);

            System.assert(options != null);
            System.assert(! options.isEmpty());

        Test.stopTest();



    }
    
    @isTest
    private static void testGetBuildinOptionsByBuildingId() {
        TestingUtils.setupData();
        
        Test.startTest();
            Building_AKA__c buildingAKA = new Building_AKA__c(Name = 'Lviv Test', Building__c = TestingUtils.testBuildingList[0].Id);
            insert buildingAKA;
            
            List<SelectOption> options = BuildingServices.getBuildinOptionsByBuildingId(TestingUtils.testBuildingList[0].Id);

            System.assert(options != null);
            System.assert(! options.isEmpty());

        Test.stopTest();

    }

    @isTest
    private static void testGetBuildingAKAByBuildingIdEmptyParameter() {
        Test.startTest();

            List<Building_AKA__c> buildingAKA;

            try {
                buildingAKA = BuildingServices.getBuildingAKAByBuildingId(null);
            
            } catch (ErrorException ex) {
                System.debug('ERROR >>> ' + ex.getMessage());
            }
        Test.stopTest();
    
        System.assert(buildingAKA == null);
    }
}