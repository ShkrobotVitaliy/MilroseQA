@isTest
private class TestRFIComponentController {
    private static final Integer NUMBER_TO_CREATE_REGION = 2;
    private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 3;
    private static final Integer NUMBER_TO_CREATE_RFI_WORK = 4;

    private static List<Region__c> testRegionList;
    private static List<RFI_Scope__c> testRFIScopeList;
    private static List<RFI_Work__c> testRFIWorkList;
    private static RFIComponentController testRFIComponentController;

    private static testmethod void testSetRfiScopeRecordId(){
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'test region', true);
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Region__c regionItem : testRegionList){
            testRFIScopeList.addAll(TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE_RFI_SCOPE, regionItem.Id, false));
        }
        insert testRFIScopeList;

        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rfiScopeItem : testRFIScopeList){
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(NUMBER_TO_CREATE_RFI_WORK, false)){
                rfiWorkItem.RFI_Scope__c = rfiScopeItem.Id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testRFIWorkList;

        testRFIScopeList = [SELECT Id,
                                (Select Id
                                 From RFI_Work_Types__r)
                            FROM RFI_Scope__c
                            WHERE Id IN : testRFIScopeList];
        
        RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList[0];
        
        testRFIComponentController = new RFIComponentController();

        Test.startTest();

            testRFIComponentController.setRfiScopeRecordId(String.valueOf(testRFIScopeList[0].Id));

        Test.stopTest();
    }

    private static testmethod void testGetRfiScopeRecord(){
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'test region', true);

        RFI_Scope_Description_New_York__c rfiNY = new RFI_Scope_Description_New_York__c();
        Insert rfiNY;
        RFI_Scope_Description_Long_Island__c rfiLI = new RFI_Scope_Description_Long_Island__c();
        Insert rfiLI;
        RFI_Scope_Description_CT__c rfiCT = new RFI_Scope_Description_CT__c();
        Insert rfiCT;
        RFI_Scope_Description_New_Jersey__c rfiNJ = new RFI_Scope_Description_New_Jersey__c();
        Insert rfiNJ;

        testRFIScopeList = new List<RFI_Scope__c>();
        for (Region__c regionItem : testRegionList){
            for (RFI_Scope__c rfiScope : TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE_RFI_SCOPE, regionItem.Id, false)){
                rfiScope.RFI_Scope_Description_New_York__c = rfiNY.Id;
                rfiScope.RFI_Scope_Description_Long_Island__c = rfiLI.Id;
                rfiScope.RFI_Scope_Description_CT__c = rfiCT.Id;
                rfiScope.RFI_Scope_Description_New_Jersey__c = rfiNJ.Id;
                testRFIScopeList.add(rfiScope);
            }
        }
        insert testRFIScopeList;

        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rfiScopeItem : testRFIScopeList){
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(NUMBER_TO_CREATE_RFI_WORK, false)){
                rfiWorkItem.RFI_Scope__c = rfiScopeItem.Id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testRFIWorkList;

        String queryString = 'SELECT Id, ';

        Map<String, Schema.SObjectField> fiedlsMap = rfiNY.getSObjectType().getDescribe().Fields.getMap();
        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            queryString += 'RFI_Scope_Description_New_York__r.' + fieldNameValue + ',';
        }

        fiedlsMap = rfiLI.getSObjectType().getDescribe().Fields.getMap();
        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            queryString += 'RFI_Scope_Description_Long_Island__r.' + fieldNameValue + ',';
        }

        fiedlsMap = rfiCT.getSObjectType().getDescribe().Fields.getMap();
        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            queryString += 'RFI_Scope_Description_CT__r.' + fieldNameValue + ',';
        }

        fiedlsMap = rfiNJ.getSObjectType().getDescribe().Fields.getMap();
        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            queryString += 'RFI_Scope_Description_New_Jersey__r.' + fieldNameValue + ',';
        }

        queryString += '(Select Id From RFI_Work_Types__r) FROM RFI_Scope__c WHERE Id = \'' + testRFIScopeList[0].Id + '\'';

        testRFIScopeList = Database.query(queryString);

        RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList[0];

        testRFIComponentController = new RFIComponentController();
        testRFIComponentController.setRfiScopeRecordId(String.valueOf(testRFIScopeList[0].Id));

        RFI_Scope__c resultRFIScope;

        Test.startTest();

            resultRFIScope = testRFIComponentController.rfiScopeRecord;

        Test.stopTest();

        System.assert(testRFIComponentController.getRfiScopeRecordId() != null);
        System.assert(resultRFIScope != null);
        System.assertEquals(testRFIScopeList[0].Id, resultRFIScope.Id);
    }

    private static testmethod void testIsEmptyWorkType(){
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'test region', true);
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Region__c regionItem : testRegionList){
            testRFIScopeList.addAll(TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE_RFI_SCOPE, regionItem.Id, false));
        }
        insert testRFIScopeList;

        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rfiScopeItem : testRFIScopeList){
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(NUMBER_TO_CREATE_RFI_WORK, false)){
                rfiWorkItem.RFI_Scope__c = rfiScopeItem.Id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testRFIWorkList;

        testRFIScopeList = [SELECT Id,
                                (Select Id
                                 From RFI_Work_Types__r)
                            FROM RFI_Scope__c
                            WHERE Id IN : testRFIScopeList];
            
        RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList[0];
        testRFIComponentController = new RFIComponentController();
        testRFIComponentController.setRfiScopeRecordId(String.valueOf(testRFIScopeList[0].Id));

        Boolean resultBoolean;

        Test.startTest();

            resultBoolean = testRFIComponentController.isEmptyWorkType;

        Test.stopTest();

        System.assert(!resultBoolean);
    }

    private static testmethod void testGetProperty(){
        testRFIComponentController = new RFIComponentController();
        
        Test.startTest();
            String param1 = testRFIComponentController.TR1Hyperlink; 
            String param2 = testRFIComponentController.TCSPHyperlink;
            String param3 = testRFIComponentController.TR8Hyperlink;
            String param4 = testRFIComponentController.PW3Hyperlink;
            String param5 = testRFIComponentController.notRequiredPermission;
            String param6 = testRFIComponentController.noteRequieredNBandAlt1;
            String param7 = testRFIComponentController.SchBHyperlink;
            String param8 = testRFIComponentController.notRequiredPermissionSignOff;
            System.assert(param1 != null);
            System.assert(param2 != null);
            System.assert(param3 != null);
            System.assert(param4 != null);
            System.assert(param5 != null);
            System.assert(param6 != null);
            System.assert(param7 != null);
            System.assert(param8 != null);
        Test.stopTest();
    
    }
}