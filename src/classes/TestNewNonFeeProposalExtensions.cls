@isTest
private class TestNewNonFeeProposalExtensions {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 6;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 7;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;
    private static final Integer NUMBER_TO_CREATE_EVENT = 2;
    private static final List<String> TASK_TEMPLATE_NAME_LIST = new List<String>{'first', 'second', 'third', 'fourth'};

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Event> testEventList;
    private static List<Task> testTaskList;
    private static List<Proposal_Historical__c> testProposalHistoricalList;
    private static List<Service_Historical__c> testServiceHistoricalList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static Loop__DDP__c testLoopDDP;
    private static List<Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOptionList;
    private static RecordType testRecordType;
    private static List <Phase__c> testPhaseList;
    private static List <Service_Item__c> testServiceItemList;
    

    private static void setupData (){
        partnerUser = TestingUtils.userWithProfile('Partner');
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testRecordType = [SELECT Name,SObjectType FROM RecordType WHERE SObjectType = 'Loop__DDP_Integration_Option__c' AND Name = :NewNonFeeProposalExtensions.DELIVERY_METHOD_NAME];  
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0];
            testLoopDDP.Name = NewNonFeeProposalExtensions.DDP_NAME;
            insert testLoopDDP;
        testLoopDDPIntegrationOptionList = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, true);
    }

    private static void createProposalsForTest(Integer numberToCreate, Id projectProfileId, Boolean doInsert){
        testProposalList = TestingUtils.createProposalList (numberToCreate, projectProfileId, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        for(Proposal__c item :testProposalList){
            item.Primary_Company_Contact__c = testContactWithAccountList[0].Id;
        }                                               

        if(doInsert){
            insert testProposalList;
        }
    }
    
    private static void insertAdditionalData(){ 
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0];
            testLoopDDP.Name = NewNonFeeProposalExtensions.DDP_NAME;
            insert testLoopDDP;
        testLoopDDPIntegrationOptionList = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, false);
        for(Loop__DDP_Integration_Option__c item : testLoopDDPIntegrationOptionList){
            item.Name =  NewNonFeeProposalExtensions.DELIVERY_METHOD_NAME;
        }
            insert testLoopDDPIntegrationOptionList;
        
        testPhaseList = TestingUtils.createPhaseList(NUMBER_TO_CREATE, false);
        for(Phase__c item : testPhaseList){
            item.Proposal__c = testProposalList[0].Id; 
        }   
            insert testPhaseList;
            
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE,  testProposalList[0].Id, false);
        for(Service_Item__c item : testServiceItemList){
            item.Phase__c = testPhaseList[0].Id;
            item.Service_Name_Full__c = 'TestName';
            item.Abbreviation__c = 'TestAbb';
            item.Quantity__c = 1.1;
            item.Unit_Price__c = Double.valueOf(5);
            item.Discount_Percentage__c = Double.valueOf(5);
        }   
            insert testServiceItemList;
    }

    private static ApexPages.StandardController testController;
    private static NewNonFeeProposalExtensions testNewNonFeeProposalExtensions;

    private static testMethod void testNewNonFeeProposal() {
        setupData ();
        createProposalsForTest(1, null, true);
        Test.setCurrentPageReference(Page.NewNonFeeProposal);
        testController = new ApexPages.StandardController( testProposalList[0] );

        Test.startTest();
            testNewNonFeeProposalExtensions = new NewNonFeeProposalExtensions(testController);
            System.assert(testNewNonFeeProposalExtensions != null);
        Test.stopTest();

    }
    
    private static testmethod void testCreateNewNonFeeProposal(){
        setupData ();
        createProposalsForTest(1, null, true);      
        insertAdditionalData();
        Test.setCurrentPageReference(Page.NewNonFeeProposal);
        testController = new ApexPages.StandardController( testProposalList[0] );
        testNewNonFeeProposalExtensions = new NewNonFeeProposalExtensions(testController);
        
        Test.startTest();
             PageReference createNewNonFeeProposal = testNewNonFeeProposalExtensions.createNewNonFeeProposal();
             System.assert(createNewNonFeeProposal != null);
        Test.stopTest();
    }
    
    private static testmethod void testCreateNewNonFeeProposalDeliveryIsNull(){
        setupData ();
        createProposalsForTest(1, null, true);      
        Test.setCurrentPageReference(Page.NewNonFeeProposal);
        testController = new ApexPages.StandardController( testProposalList[0] );
        testNewNonFeeProposalExtensions = new NewNonFeeProposalExtensions(testController);
        
        Test.startTest();
             PageReference createNewNonFeeProposal = testNewNonFeeProposalExtensions.createNewNonFeeProposal();
             System.assert(createNewNonFeeProposal == null);
        Test.stopTest();
    }
    
    private static testmethod void testCreateNewNonFeeProposalPrimaryIsNull(){
        setupData ();       
        createProposalsForTest(1, null, true);  
        insertAdditionalData();
        for(Phase__c item : testPhaseList){
            item.Proposal__c = null;
        }
            update testPhaseList;
        Test.setCurrentPageReference(Page.NewNonFeeProposal);
        testController = new ApexPages.StandardController( testProposalList[0] );
        testNewNonFeeProposalExtensions = new NewNonFeeProposalExtensions(testController);
        
        Test.startTest();
             PageReference createNewNonFeeProposal = testNewNonFeeProposalExtensions.createNewNonFeeProposal();
             System.assert(createNewNonFeeProposal != null);
        Test.stopTest();
    }
}