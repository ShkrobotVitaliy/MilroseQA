@isTest
private class TestFloorServices {
    private static final Integer NUMBER_TO_CREATE = 3;
    private static Integer floorNumber = 3; 
    private static List<Floor__c> testFloorList;
    private static User testUser;
    private static User projectManagerUser;
    private static Account testAccount;
    private static Contact testContact;
    private static Building__c testBuilding;
    private static Proposal__c testProposal;
//^^^    private static Proposal__c testProposalDraft;
    private static List <Project_Profile__c> testProjectProfileList;

    private static void setUp(Boolean doInsert){
        testFloorList = TestingUtils.createFloorList(NUMBER_TO_CREATE, false);
        if(doInsert){
            insert testFloorList;
        }
    }
    private static void insertData(){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testUser = TestingUtils.createUsers(1, true)[0];
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
            testContact.AccountId = testAccount.Id;
            insert testContact;
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, null, 'TestStreet', 'TestHouse', 'TestCity', 'TestZip', true)[0];  
        testProposal = TestingUtils.createProposalList(NUMBER_TO_CREATE, 
                                                                   'testProject', 
                                                                   testAccount.Id, 
                                                                   testContact.Id, 
                                                                   testAccount.Id, 
                                                                   testContact.Id, 
                                                                   testBuilding.Id, 
                                                                   Date.today(), 
                                                                   null, 
                                                                   Date.today(), 
                                                                   Date.today(), 
                                                                   null, 
                                                                   null, 
                                                                   null, 
                                                                   true)[0];
        
//^^^        testProposalDraft = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE, true)[0];
    }
    
    private static void createProjectProfile(){
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
    }
        
    @isTest ( seeAllData = false ) private static void testFloorContains_ifFloorItemCountMatchesIsOne(){        
        setUp(false);
        testFloorList[0].Floor_Type__c = FloorServices.FLOOR_TYPE_ATTIC;
        testFloorList[0].Specification_Name__c = 'TestName 1-5';
        insert testFloorList;
        
        Test.startTest();
            Boolean testBoolean = FloorServices.floorContains(FloorServices.FLOOR_TYPE_ATTIC, floorNumber, testFloorList);
        Test.stopTest();
        
        System.debug('@@@testBoolean' + ' ' + testBoolean);
        System.assertEquals(true, testBoolean);
        
    }
    
    @isTest ( seeAllData = false ) private static void testFloorContains_ifFloorItemCountMatchesIsZero(){
        setUp(false);   
        testFloorList[0].Floor_Type__c = FloorServices.FLOOR_TYPE_ATTIC;
        testFloorList[0].Specification_Name__c = 'TestName 3';
        insert testFloorList;
            
        Test.startTest();
            Boolean testBoolean = FloorServices.floorContains(FloorServices.FLOOR_TYPE_ATTIC, floorNumber, testFloorList);
        Test.stopTest();
        
        System.debug('@@@testBoolean' + ' ' + testBoolean);
        System.assertEquals(true, testBoolean);
    }
    
    @isTest ( seeAllData = false ) private static void testFloorContains_False(){
        setUp(false);   
        testFloorList[0].Floor_Type__c = FloorServices.FLOOR_TYPE_ATTIC;
        testFloorList[0].Specification_Name__c = 'TestName 5';
        insert testFloorList;
            
        Test.startTest();
            Boolean testBoolean = FloorServices.floorContains(FloorServices.FLOOR_TYPE_ATTIC, floorNumber, testFloorList);
        Test.stopTest();
        
        System.debug('@@@testBoolean' + ' ' + testBoolean);
        System.assertEquals(false, testBoolean);
    }
    
    @isTest ( seeAllData = false ) private static void testIsThereFloorWithType_True(){
        setUp(false);   
        testFloorList[0].Floor_Type__c = FloorServices.FLOOR_TYPE_ATTIC;            
        insert testFloorList;
            
        Test.startTest();
            Boolean testBoolean = FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_ATTIC,testFloorList);
        Test.stopTest();
        
        System.assertEquals(true, testBoolean);
    }
    
    @isTest ( seeAllData = false ) private static void testIsThereFloorWithType_False(){
        setUp(true);                
            
        Test.startTest();
            Boolean testBoolean = FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_ATTIC,testFloorList);
        Test.stopTest();
        
        System.assertEquals(false, testBoolean);
    }
    
    @isTest ( seeAllData = false ) private static void testGetFullFloorNameNullTest(){
        String testFloorNumber = '5';
        
        Test.startTest();
            String ActRes = FloorServices.getFullFloorName(null, testFloorNumber);
        Test.stopTest();
        
        System.assertEquals('',ActRes);     
    }
    
    @isTest ( seeAllData = false ) private static void testGetFullFloorNameNullTest_specificationNamesMapFixed(){
        String testFloorNumber = '5';
        
        Test.startTest();
            String ActRes = FloorServices.getFullFloorName(FloorServices.FLOOR_TYPE_ATTIC,testFloorNumber);
        Test.stopTest();
        
        System.assertEquals('ATT',ActRes);
        
    }
    
    
    
    @isTest ( seeAllData = false ) private static void testGetFullFloorNameNullTest_specificationNamesvariable_False(){
        String testFloorNumber = '5';
        
        Test.startTest();
            String ActRes = FloorServices.getFullFloorName(FloorServices.FLOOR_TYPE_MEZZANINE, testFloorNumber);
        Test.stopTest();
        
        System.assertEquals('MZ5',ActRes);
    }
    
    @isTest ( seeAllData = false ) private static void testGetFullFloorNameNullTest_specificationNamesMezzaninePenthouse(){
        String testFloorNumber = '5';
        
        Test.startTest();
            String ActRes = FloorServices.getFullFloorName(FloorServices.FLOOR_TYPE_PENTHOUSE,'' );
        Test.stopTest();
        
        System.assertEquals('PEN',ActRes);
    }
    
    @isTest (seeAllData = false) private static void testSortFloorType(){
        setUp(false);       
            testFloorList[0].Floor_Type__c = 'Roof';            
            insert  testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }
        
        Test.startTest();
            List<FloorWrapper> testFloorWrapperListNew = FloorServices.sortFloorType(floorWrapperList);
        Test.stopTest();
        
        System.assertEquals(1, testFloorWrapperListNew.size());
        System.assertEquals('Roof', testFloorWrapperListNew[0].floor.Floor_Type__c);
    }
    
    @isTest (seeAllData = false) private static void testSortFloorType_WithZeroFloorWrap(){
        String firstPickListValue = Floor__c.Floor_Type__c.getDescribe().getPicklistValues()[0].getValue();
        String lastPickListValue = Floor__c.Floor_Type__c.getDescribe().getPicklistValues()[Floor__c.Floor_Type__c.getDescribe().getPicklistValues().size() - 1].getValue();

        setUp(false);
            testFloorList[0].Floor_Type__c = lastPickListValue;
            testFloorList[2].Floor_Type__c = firstPickListValue;
            insert  testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }
        
        Test.startTest();
            List<FloorWrapper> testFloorWrapperListNew = FloorServices.sortFloorType(floorWrapperList);
        Test.stopTest();
        
        System.assertEquals(2, testFloorWrapperListNew.size());
        System.assertEquals(lastPickListValue, testFloorWrapperListNew[0].floor.Floor_Type__c);
        System.assertEquals(firstPickListValue, testFloorWrapperListNew[1].floor.Floor_Type__c);
    }
    
    @isTest(seeAllData = false) private static void testCreateFloorsString(){
        setUp(false);       
            testFloorList[0].Floor_Type__c = 'Roof';
            testFloorList[2].Floor_Type__c = 'Attic';           
            insert  testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }
        
        Test.startTest();
            String testString = FloorServices.createFloorsString(floorWrapperList, true);
        Test.stopTest();
        
        System.assert(testString.contains(String.valueOf(testFloorList[0].Id)));
        System.assert(testString.contains(String.valueOf(testFloorList[2].Id)));
        
        
    }
    
    @isTest(seeAllData = false) private static void testCreateFloorsStringSecondCondition(){
        setUp(false);       
            testFloorList[0].Floor_Type__c = 'Roof';
            testFloorList[2].Floor_Type__c = 'Attic';           
            insert  testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }
        
        Test.startTest();
            String testString = FloorServices.createFloorsString(floorWrapperList, false);
        Test.stopTest();
        
        System.assertEquals('', testString);
    }

/*^^^
    @isTest(seeAllData = false) private static void testUpdateFloorsString_Proposal(){
        String expRes = '(Tenant Flr. Roof, Tower)';
        String expSpecRes = 'TestSpecName2, TestSpecName1 ' + expRes;
        insertData();
        setUp(false);
            testFloorList[0].Floor_Type__c = 'Roof';
            testFloorList[1].Floor_Type__c = 'Attic';   
            testFloorList[0].Specification_Name__c = 'TestSpecName1';
            testFloorList[1].Specification_Name__c = 'TestSpecName2';
            testFloorList[0].Tenant_Type__c = 'Tower';
            testFloorList[1].Tenant_Type__c = 'Roof';       
            insert testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }   
        createProjectProfile();
            
        Test.startTest();
            String testProposalDraftFloors = FloorServices.updateFloorsString(testProposal.Id, testProposalDraft.Id,testProjectProfileList[0].Id, floorWrapperList, true);
        Test.stopTest();
        
        Project_Profile__c testProject = [SELECT Id,Floor_s__c FROM Project_Profile__c WHERE Id =: testProjectProfileList[0].Id limit 1];
        System.assert(testProject != null);
        System.assertEquals(expSpecRes, testProject.Floor_s__c);
        System.assertEquals(expSpecRes, testProposalDraftFloors);
        testProposal = [SELECT Id,Floor_s__c FROM Proposal__c WHERE Id = : testProposal.Id][0];
        System.assertEquals(expSpecRes, testProposal.Floor_s__c);   
        
    }

    @isTest(seeAllData = false) private static void testUpdateFloorsString_Porposal_Draft(){
        String expRes = '(Tenant Flr. Roof, Tower)';
        String expSpecRes = 'TestSpecName2, TestSpecName1 ' + expRes;
        insertData();
        setUp(false);
            testFloorList[0].Floor_Type__c = 'Roof';
            testFloorList[1].Floor_Type__c = 'Attic';   
            testFloorList[0].Specification_Name__c = 'TestSpecName1';
            testFloorList[1].Specification_Name__c = 'TestSpecName2';
            testFloorList[0].Tenant_Type__c = 'Tower';
            testFloorList[1].Tenant_Type__c = 'Roof';       
            insert testFloorList;
        List<FloorWrapper>floorWrapperList = new List<FloorWrapper>();
        for(Floor__c item : testFloorList){
            floorWrapperList.add(new FloorWrapper(item));
        }   
            
        Test.startTest();
            String testProposalDraftFloors = FloorServices.updateFloorsString(null, testProposalDraft.Id, null, floorWrapperList, true);
        Test.stopTest();        
                
        testProposalDraft = [SELECT Id,Floor_s__c FROM Proposal__c WHERE Id = : testProposalDraft.Id][0];     
        System.assertEquals(expSpecRes, testProposalDraft.Floor_s__c);  
        
    }
^^^*/
}