@isTest
private class TestSendInvoiceController {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ApexPages.StandardController testController;
    private static SendInvoiceController testSendInvoiceController;
    private static Pro_forma_Invoice__c testProFormaInvoice;
    private static Mailroom__c testMailRoom;
    private static Billing_Line_Item__c  testBillingLineItem;
    private static Region__c testRegion;
    private static Munucipalities__c testMunucipality;
    private static Building__c testBuilding;
    private static User projectManager;
    private static Project_Profile__c testProject;
    private static Account testAccount;
    private static Contact testContact;
    private static Service_Item__c testServiceItem;
    private static Loop__DDP_Integration_Option__c testDDPIntegrationOption;
    private static Loop__DDP__c testDDP; 
    private static DDP_Helper__c testDDPHelper;
    private static Deposit_Invoice__c testDepositInvoice;
    
    private final static String SUPREME_SYSTEMS_FILTER = 'MESS';    
    private final static String ACTION = 'action';
    private final static String ATTACH_ACTION = 'Create';
    private final static String ATTACH_OPTION = 'Attach';
    private final static String CREATE_INVOICES_DDPNAME = 'CreateInvoices';
    private final static String CREATE_INVOICES = 'Create Invoices';
    private final static String DDPNAME = 'ddpName';
    private final static String EMAIL_OPTION = 'Email';
    private final static String EMAIL_ACTION = 'Send';
    
    private static void setUp(){
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                projectManager.Id,
                                                                false)[0];
			testProject.Billing_Method__c = 'Milestone';
			insert testProject;                                                               
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true)[0];
        testMunucipality = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true)[0];            
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipality.Id, 'TestStreet', '5', 'TestCity', '79000', true)[0];        
        testProFormaInvoice = TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE, testAccount.Id, testContact.Id, testBuilding.Id, false)[0];
            testProFormaInvoice.Project_Profile__c = testProject.Id;   
            testProFormaInvoice.Billing_Contact__c = testContact.Id;   
            insert testProFormaInvoice;             
        testMailRoom = TestingUtils.createMailRoomList(NUMBER_TO_CREATE, false)[0];
            testMailRoom.COSTCATID_Service_Type__c =  'FED EX';
            insert testMailRoom;
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE,false)[0]; 
        	testServiceItem.Project_Profile__c = testProject.Id;
        	insert testServiceItem;  
        testBillingLineItem = TestingUtils.createBillingLineItemList(NUMBER_TO_CREATE, 
                                                                         testProject.Id, 
                                                                         testAccount.Id, 
                                                                         testContact.Id, 
                                                                         false)[0];
            testBillingLineItem.Pro_forma_Invoice__c = testProFormaInvoice.Id;
            testBillingLineItem.Mailroom__c = testMailRoom.Id;
            testBillingLineItem.Service_Item__c = testServiceItem.Id;
            insert testBillingLineItem;
            
        testDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0];
        	testDDP.Name = 'Mailroom FedEx';    
        	insert testDDP;  
        RecordType testRecType = [SELECT Id,Name,SObjectType FROM RecordType  WHERE SObjectType = 'Loop__DDP_Integration_Option__c' AND Name = 'Attach'][0];     
                                                         
        testDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testDDP.Id, false)[0];
        	 testDDPIntegrationOption.Name = 'Attach';
        	 //testDDPIntegrationOption.RecordTypeId = testRecType.Id;
        	 insert testDDPIntegrationOption;
        testDDPHelper = TestingUtils.createDDPHelperList(NUMBER_TO_CREATE, false)[0];
        	testDDPHelper.Pro_forma_Invoice__c = testProFormaInvoice.Id;
        	testDDPHelper.Text2__c = DepositInvoiceServices.SERVICE_RETAINER_TYPE;
        	testDDPHelper.Currency1__c = 1;
        	testDDPHelper.Currency2__c = 2;
        	testDDPHelper.Currency3__c = 3;
        	insert testDDPHelper;
        testDepositInvoice = TestingUtils.createDepostiInvoiceList(NUMBER_TO_CREATE, false)[0];
        	testDepositInvoice.Project_Profile__c = testProject.Id;
        	testDepositInvoice.Deposit_Invoice_Type__c = DepositInvoiceServices.SERVICE_RETAINER_TYPE;
        	testDepositInvoice.Amount_Paid__c = 5;
        	testDepositInvoice.Amount_Remaining__c = 5;
        	insert testDepositInvoice;
                                                                         
    }
    
    private static void initiliazeController(){
    	//Test.setCurrentPageReference(Page.SendInvoice);
    	//ApexPages.currentPage().getParameters().put(ACTION, 'Send');
    	testController = new ApexPages.StandardController( testProFormaInvoice );
    	testSendInvoiceController = new SendInvoiceController(testController);
    }
    
    private static testMethod void testSendInvoiceController() {
		setUp();        

        Test.startTest();
            initiliazeController();
        Test.stopTest();        
        
        ApexPages.currentPage().getParameters().put(DDPNAME, 'CreateCredit1');
        testSendInvoiceController = new SendInvoiceController(testController);
        ApexPages.currentPage().getParameters().put(DDPNAME, 'CreateCredit2');
        testSendInvoiceController = new SendInvoiceController(testController);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);
        testSendInvoiceController = new SendInvoiceController(testController);
        ApexPages.currentPage().getParameters().put(ACTION, '');
        testSendInvoiceController = new SendInvoiceController(testController);
		String  testString = testSendInvoiceController.retUrl;
    }
   
   
    private static testMethod void testAutoRunFirstSelect(){
        setUp(); 
        Test.setCurrentPageReference(Page.SendInvoice);
        ApexPages.currentPage().getParameters().put(ACTION, ATTACH_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);  
        initiliazeController(); 
        testSendInvoiceController.isValid = true;
        
        Test.startTest();
            testSendInvoiceController.prepareAndRunDDP();  
        Test.stopTest();    
        
    }
    
    private static testMethod void testAutoRunSecondSelect(){
        setUp();
        testDDP.Name = 'Mailroom Supreme Systems';    
        	update testDDP;
        testMailRoom.COSTCATID_Service_Type__c = SUPREME_SYSTEMS_FILTER + '%';
        	update testMailRoom;
        Test.setCurrentPageReference(Page.SendInvoice);	
        ApexPages.currentPage().getParameters().put(ACTION, ATTACH_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);  
        initiliazeController();	              
        testSendInvoiceController.isValid = true;
        
        Test.startTest();
            testSendInvoiceController.prepareAndRunDDP();  
        Test.stopTest();
        
        
    }
    
    private static testMethod void testAutoRunThirdSelect(){
        setUp();
        testDDP.Name ='Reimbursable Shredding';    
        	update testDDP;
        testMailRoom.COSTCATID_Service_Type__c = null;
        	update testMailRoom;
        testBillingLineItem.Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING;
        	update testBillingLineItem;
        Test.setCurrentPageReference(Page.SendInvoice);	
        ApexPages.currentPage().getParameters().put(ACTION, ATTACH_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);
        initiliazeController();	                
        testSendInvoiceController.isValid = true;
        
        Test.startTest();
            testSendInvoiceController.prepareAndRunDDP();  
        Test.stopTest();
        
        
    }
    
    private static testMethod void testAutoRunForthSelect(){
        setUp();
        testDDP.Name = 'Reimbursable Scanning';    
        	update testDDP;
        testMailRoom.COSTCATID_Service_Type__c = null;
        	update testMailRoom;
        testBillingLineItem.Reimbursable_Type__c = BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING ;
        	update testBillingLineItem;
        Test.setCurrentPageReference(Page.SendInvoice);	
        ApexPages.currentPage().getParameters().put(ACTION, ATTACH_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME); 
        initiliazeController();	               
        testSendInvoiceController.isValid = true;
        
        Test.startTest();
            testSendInvoiceController.prepareAndRunDDP();  
        Test.stopTest();
        
        
    }
    
    private static testMethod void testRunDDP(){
    	setUp();  
    	testMailRoom.COSTCATID_Service_Type__c = null;
        	update testMailRoom;
        testBillingLineItem.Reimbursable_Type__c = null ;
        	update testBillingLineItem;   
    	testDDP.Name = CREATE_INVOICES;    
        	update testDDP; 
		testDDPIntegrationOption.Name = ATTACH_OPTION; 
			update testDDPIntegrationOption; 
		Test.setCurrentPageReference(Page.SendInvoice);	   	 	
    	ApexPages.currentPage().getParameters().put(ACTION, ATTACH_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);  
    	testController = new ApexPages.StandardController( testProFormaInvoice );
    	testSendInvoiceController = new SendInvoiceController(testController);
    	testSendInvoiceController.isValid = true;
    	
    	Test.startTest();
    		testSendInvoiceController.prepareAndRunDDP();  
    	Test.stopTest();
    }
    
    private static testMethod void testControllerAttachOption(){
        setUp();
        Test.setCurrentPageReference(Page.SendInvoice);	   	 	
    	ApexPages.currentPage().getParameters().put(ACTION,ATTACH_ACTION);
    	ApexPages.currentPage().getParameters().put(DDPNAME,CREATE_INVOICES_DDPNAME);   
    	testController = new ApexPages.StandardController( testProFormaInvoice ); 	
        
        Test.startTest();
            testSendInvoiceController = new SendInvoiceController(testController);
        Test.stopTest();    
        
    }
    
    private static testMethod void testControllerEmailOption(){
        setUp();
        testProFormaInvoice.cl_FFA_Invoice_Created__c = true;
        	update testProFormaInvoice; 

        ApexPages.currentPage().getParameters().put(ACTION, EMAIL_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);
		initiliazeController();        		

        Test.startTest();
            testSendInvoiceController.autorun();
        Test.stopTest();    
        
    }
    
    private static testMethod void testPrepareDdpHelpers(){
    	setUp();
    	initiliazeController(); 
    	
    	Test.startTest();
            testSendInvoiceController.prepareDdpHelpers();
        Test.stopTest();
    }
    
    private static testMethod void testGoBack(){
        setUp();        
        Test.setCurrentPageReference(Page.SendInvoice);
        ApexPages.currentPage().getParameters().put(ACTION, EMAIL_ACTION);
        ApexPages.currentPage().getParameters().put(DDPNAME, CREATE_INVOICES_DDPNAME);  
        initiliazeController(); 
        testSendInvoiceController.isValid = true;
        
        Test.startTest();
            testSendInvoiceController.goBack();  
        Test.stopTest();    
     }
    
}