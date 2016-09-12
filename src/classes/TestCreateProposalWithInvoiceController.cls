@isTest
private class TestCreateProposalWithInvoiceController {
	private static final Integer NUMBER_TO_CREATE = 5 ;
	private static Project_Profile__c testProjectProfile;
	private static User partnerUser;
	private static User projectManagerUser;
    private static Id currentUserId; 
    private static Account testAccount;
    private static Contact testContact;
    private static List<Proposal__c> testProposalList;
    private static Proposal__c testProposal;
    private static List<Building__c> testBuildingList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static Region__c testRegion;
    private static CreateProposalWithInvoiceController createPropController;
    private static Deposit_Invoice__c testDepositInvoice;
    private static LStore__Stored_Document__c testLStoreDocument;
    private final static String PROPOSAL_INVOICE_DDP = 'Proposal Document';
    private final static String EMAIL_DELIVERY_METHOD = 'Email';
    private static List <Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOption;
    private static List <Loop__DDP__c> testLoopDDP;
    
	private static void setUp(){
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
		testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true)[0];
		testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];                                                                           
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);       
		testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
		testDepositInvoice = TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE, testProposalList[0].Id, null, false)[0];
			testDepositInvoice.Is_Created_From_Code__c = true;
			insert testDepositInvoice;
		testLStoreDocument = TestingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE, false)[0];
			testLStoreDocument.Related_Object_Id__c = testDepositInvoice.Id;
			testLStoreDocument.LStore__Related_Object_Id__c = testDepositInvoice.Id;
			testLStoreDocument.LStore__Type__c = 'pdf';
			testLStoreDocument.LStore__File_Name__c = 'test file name';
			insert testLStoreDocument;
		 testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false);
            testLoopDDP[0].Name = PROPOSAL_INVOICE_DDP;
            insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP[0].Id, false);
            testLoopDDPIntegrationOption[0].Name = EMAIL_DELIVERY_METHOD; 
            insert testLoopDDPIntegrationOption;
			                                                            
	}
	private static void getPage(){
		Test.setCurrentPageReference(Page.CreateProposalWithInvoice);
	}
	
	private static void initializeController(){
		createPropController = new CreateProposalWithInvoiceController(new ApexPages.StandardController(testProposalList[0]));
	}
	
	private static testMethod void testInitControllerWithoutProposalException(){
		setUp();
		getPage();

		ApexPages.StandardController standContr = new ApexPages.StandardController(testProposalList[0]);
		delete testProposalList[0];

		System.assert(! ApexPages.hasMessages() );

		createPropController = new CreateProposalWithInvoiceController(standContr);
		System.assert( ApexPages.hasMessages() );
	}

	private static testMethod void testInitControllerWithoutDepositInvoicesException(){
		setUp();
		getPage();

		//set value that do not meet controller's criteria
		testDepositInvoice.Is_Created_From_Code__c = false;
		update testDepositInvoice;

		System.assert(! ApexPages.hasMessages() );

		createPropController = new CreateProposalWithInvoiceController(new ApexPages.StandardController(testProposalList[0]));
		System.assert( ApexPages.hasMessages() );
	}

	private static testMethod void testAutoRun(){
		setUp();
		getPage();
		initializeController();
		
		PageReference pr = null;

		Test.startTest();
			pr = createPropController.autoRun();
		Test.stopTest();
		
		System.assert( pr.getUrl().contains(testProposalList[0].Id) );
		System.assert(! ApexPages.hasMessages() );
		
	}
	
	private static testMethod void testAutoRunDepositException(){
		setUp();
		testDepositInvoice.Proposal__c = null;
		testDepositInvoice.Project_Profile__c = testProjectProfile.Id;
			update testDepositInvoice;
		getPage();
		initializeController();
		
		PageReference pr = null;

		Test.startTest();
			pr = createPropController.autoRun();
		Test.stopTest();	
		
		System.assert(pr == null);
		System.assert(ApexPages.hasMessages());
	}
	
	

}