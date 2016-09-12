@isTest
private class TestChangeOrderRequest {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ApexPages.StandardController controller;
    private static ChangeOrderRequest changeOrderController;
    private static List<Proposal__c> testProposalList;
    private static User testUser;
    private static User partnerUser;
    private static User projectManagerUser;
    private static User projectMember;
    private static Proposal__c testProposal;
    private static List<Account> testAccountList;
    private static List<Contact> testContactList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunicipalitiesList;
    private static List<Building__c> testBuildingList;
    
    
    private static void setUp(Boolean doInsert){        
        projectMember = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testUser = TestingUtils.createUsers(1, true)[0];
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true);
        testContactList = TestingUtils.createContactList(1, testAccountList[0].Id, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'Test region', true);
        testMunicipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunicipalitiesList[0].Id, null, null, null, null, true);
        testProposal = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccountList[0].Id, testContactList[0].Id,
                                                            testAccountList[0].Id, testContactList[0].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, testUser.Id, projectManagerUser.Id, true)[0];
        
        
    }
    
    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.ChangeOrderRequest);
        controller = new ApexPages.StandardController( testProposal );
        changeOrderController = new ChangeOrderRequest( controller );
        String changeOrderReason = changeOrderController.changeOrderReason;
    }

    @isTest static void testUncoveredParts() {
        setUp( false );
        User uStaffAccountant = TestingUtils.userWithProfile( UserServices.PROFILE_STAFF_ACCOUNTANT );
        User uFREP = TestingUtils.userWithProfile( UserServices.PROFILE_FREP );
        System.runAs( uStaffAccountant ) {
            Test.setCurrentPageReference(Page.ChangeOrderRequest);
            controller = new ApexPages.StandardController( testProposal );
            changeOrderController = new ChangeOrderRequest( controller );
        }
        System.runAs( uFREP ) {
            Test.setCurrentPageReference(Page.ChangeOrderRequest);
            controller = new ApexPages.StandardController( testProposal );
            changeOrderController = new ChangeOrderRequest( controller );
        }
    }
    
    @isTest(seeAllData = false) private static void testChangeOrderRequestFirstMessage(){
        setUp(false);
        System.runAs(projectMember){
            Test.setCurrentPageReference(Page.ChangeOrderRequest);
            controller = new ApexPages.StandardController(testProposal);
            
            Test.startTest();
                changeOrderController = new ChangeOrderRequest(controller);
            Test.stopTest();
            
            
            System.debug(LoggingLevel.error,'@@@' + [SELECT  Name  FROM Profile]);
            System.assertEquals(testProposal.Id, changeOrderController.proposal.Id);
            System.assertEquals('Change Order Reason', changeOrderController.proposalNote.Title);
            //System.assert(TestingUtils.pageMessagesContain('Only Project Manager can request a Change Order.'));
            System.assertEquals(true, changeOrderController.disableSaveButton);
        }
    }
    
    @isTest(seeAllData = false) private static void testChangeOrderRequestSecondMessage(){
        setUp(false);
        testProposal.Status__c = null;
            update testProposal;
        Test.setCurrentPageReference(Page.ChangeOrderRequest);
        controller = new ApexPages.StandardController(testProposal);
        
        Test.startTest();
            changeOrderController = new ChangeOrderRequest(controller);
        Test.stopTest();        

        System.assertEquals(true, changeOrderController.disableSaveButton); 
    }
    
    @isTest(seeAllData = false) private static void testChangeOrderRequestThirdMessage(){
        setUp(false);
        Test.setCurrentPageReference(Page.ChangeOrderRequest);
        controller = new ApexPages.StandardController(testProposal);
        
        Test.startTest();
            changeOrderController = new ChangeOrderRequest(controller);
        Test.stopTest();        
        
        System.assert(TestingUtils.pageMessagesContain('Change Order can not be applied to Proposal without Project.'));
        System.assertEquals(true, changeOrderController.disableSaveButton); 
    }
    
    @isTest(seeAllData = false) private static void testAddChangeOrderReasonActionBodyisNull(){
        setUp(false);
        getPageWithController();
        
        Test.startTest();
            changeOrderController.addChangeOrderReasonAction();
        Test.stopTest();
        
        System.assert(TestingUtils.pageMessagesContain('Change Order Reason Note is required.'));
    }
    
    @isTest(seeAllData = false) private static void testAddChangeOrderReasonActionBodyisNotNull(){
        setUp(false);
        getPageWithController();
        changeOrderController.proposalNote.Body = 'TestBody';
        
        Test.startTest();
            PageReference testPagereference = changeOrderController.addChangeOrderReasonAction();
        Test.stopTest();
        
        System.assertEquals(testProposal.Id, changeOrderController.proposalNote.ParentId);
        System.assertEquals(true, changeOrderController.proposal.is_Change_Order__c);
        System.assertEquals(false, changeOrderController.proposal.Locked__c);
        System.assert(String.valueOf(testPagereference).contains(String.valueOf(testProposal.Id)));
        System.assert(String.valueOf(testPagereference).contains('/apex/ProposalWizard'));  
    }
    
    
    @isTest(seeAllData = false) private static void testCancelAction(){
        setUp(false);
        getPageWithController();
        
        Test.startTest();
            PageReference testPagereference = changeOrderController.cancelAction();
        Test.stopTest();
                
        System.assert(String.valueOf(testPagereference).contains(String.valueOf(testProposal.Id).subString(0,14)));
    }
    
}