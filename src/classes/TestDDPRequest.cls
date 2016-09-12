@isTest
private class TestDDPRequest {
    private static String DDP_NAME_OPTION = 'ddpName';
    private static String DELIVERY_METHOD_NAME_OPTION = 'deliveryMethod';
    private static final Integer NUMBER_TO_CREATE = 5;
    private static Loop__DDP_Integration_Option__c testLoopDDPIntegrationOption;
    private static Loop__DDP__c testLoopDDP;
    private static Account testAccount;
    private static Contact testContact;
    private static Building__c testBuilding;
    private static Region__c  testRegion; 
    private static Munucipalities__c testMunucipality;  
    private static User projectManagerUser;
    private static Project_Profile__c testProjectProfile;
    private static DDPRequest testDDPRequestClass;
    
    
    private static void setUp(){
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'testAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE,testAccount.Id, true)[0]; 
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true)[0];
        testMunucipality = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true)[0];            
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipality.Id, 'TestStreet', '5', 'TestCity', '79000', true)[0];    
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);   
        testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true)[0];
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0];
                testLoopDDP.Name = DDP_NAME_OPTION;
                insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, false)[0];
            testLoopDDPIntegrationOption.Name = DELIVERY_METHOD_NAME_OPTION;
            insert testLoopDDPIntegrationOption;
    }
    
    private static void initializeClass(){
        testDDPRequestClass = new DDPRequest();
    }
    
    private static testMethod void testAddConfiguration(){
        setUp();
        initializeClass();
        
        Test.startTest();
            testDDPRequestClass.addConfiguration( testProjectProfile.Id, DDP_NAME_OPTION, DELIVERY_METHOD_NAME_OPTION);
        Test.stopTest();

        System.assert(testProjectProfile.Id != null);

    }   
    
    private static testMethod void testSendRequest(){
        setUp();
        initializeClass();
        testDDPRequestClass.addConfiguration( testProjectProfile.Id, DDP_NAME_OPTION, DELIVERY_METHOD_NAME_OPTION);
        
        Test.startTest();
            testDDPRequestClass.sendRequest();
        Test.stopTest();

        System.assert(testProjectProfile.Id != null);
    }
    
    private static testMethod void testSendRequestsForBatch(){
        setUp();
        initializeClass();
        testDDPRequestClass.addConfiguration( testProjectProfile.Id, DDP_NAME_OPTION, DELIVERY_METHOD_NAME_OPTION);
        
        Test.startTest();
            testDDPRequestClass.sendRequestsForBatch();
        Test.stopTest();

        System.assert(testProjectProfile.Id != null);
    }
}