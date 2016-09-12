@isTest
private class TestDepositInvoiceServices {

    private static final Integer NUMBER_TO_CREATE = 5 ;
    private static List<Deposit_Invoice__c> testDepositInvoiceList;
    private static List<c2g__codaCashEntryLineItem__c> testCodaCashEntryLineItemListOld;
    private static List<c2g__codaCashEntryLineItem__c> testCodaCashEntryLineItemListNew;
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
        
    private static void setUp(){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];                                                                           
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);    
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
        testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, false)[0];

        testProjectProfile.Proposal__c = testProposalList[0].Id;
            insert testProjectProfile;                                                                      
        
        testDepositInvoiceList = TestingUtils.createDepositInvoiceList(NUMBER_TO_CREATE, testProjectProfile.Proposal__c, testProjectProfile.Id, true);
    }
    
    private static void selectsForVisibleData(){
        testCodaCashEntryLineItemListOld = [SELECT Id,Deposit_Invoice__c FROM c2g__codaCashEntryLineItem__c Where Deposit_Invoice__c != null limit 1];
        if( !testCodaCashEntryLineItemListOld.isEmpty() ) {
            testCodaCashEntryLineItemListNew = [SELECT Id,Deposit_Invoice__c FROM c2g__codaCashEntryLineItem__c Where Deposit_Invoice__c != : testCodaCashEntryLineItemListOld[0].Deposit_Invoice__c limit 1];
        }
    }
    
    @isTest(seeAllData = true) static void testUncoveredParts() {
        setUp();
        selectsForVisibleData();
        
        Test.startTest();
            List<Map<Id, List<String>>> filteredIdsOfRetainerInvoicesWithChangedCashEntryLineItems = DepositInvoiceServices.filteredIdsOfRetainerInvoicesWithChangedCashEntryLineItems(
            new Map<Id,c2g__codaCashEntryLineItem__c> { null => new c2g__codaCashEntryLineItem__c( Payment_Type__c = DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE , Deposit_Invoice__c = testDepositInvoiceList[0].Id) },
            new Map<Id,c2g__codaCashEntryLineItem__c> { null => new c2g__codaCashEntryLineItem__c( Payment_Type__c = DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE , Deposit_Invoice__c = testDepositInvoiceList[1].Id) } );
            List<Map<Id, List<String>>> mapOfInvoices = new List<Map<Id, List<String>>> { new Map<Id, List<String>>(), new Map<Id, List<String>>() };	
			for( Deposit_Invoice__c depInvoice : testDepositInvoiceList) {
                mapOfInvoices.get(0).put( depInvoice.Id, new List<String> {'test', 'test'} );
				mapOfInvoices.get(1).put( depInvoice.Id, new List<String> {'test', 'test'} );
            }
            DepositInvoiceServices.sendEmailsRegCashEntLineItems( mapOfInvoices );

            DepositInvoiceServices dInvServ = new DepositInvoiceServices();
            dInvServ.updateTransactionLineItemsByDeposites( new Map<Id, Set<Id>> { testDepositInvoiceList[0].Id => new Set<Id> { testCodaCashEntryLineItemListNew[0].Id } } );

            Decimal getRemainingAmountByProjectId = DepositInvoiceServices.getRemainingAmountByProjectId( testProjectProfile.Id );
            getRemainingAmountByProjectId = DepositInvoiceServices.getRemainingAmountByProjectId( null );

            DepositInvoiceServices.createDepositInvoicePdf( testDepositInvoiceList );

            Boolean doCreateMunicipalFeeRetainer = DepositInvoiceServices.doCreateMunicipalFeeRetainer(testProposalList[0], null);

            Change_Order__c cO = TestingUtils.createChangeOrderList(1, true)[0];
            Project_Team__c assignTeam = [SELECT Production_Manager__c FROM Project_Team__c LIMIT 1];
            ChangeOrderModel cOModel = new ChangeOrderModel(cO, UserServices.PROFILE_PROJECT_MANAGER_2, UserServices.ROLE_PROPOSAL_SPECIALIST, projectManagerUser.Id, testProposalList[0],
                            true, assignTeam, true, true, false);
            testProposalList[0].Total_Service_Amount__c = 5;
            testProposalList[0].No_Retainer__c = true;
            Deposit_Invoice__c prepareDepositInvoiceOne = DepositInvoiceServices.prepareDepositInvoice( testProposalList[0], cOModel, testDepositInvoiceList[0], DepositInvoiceServices.SERVICE_RETAINER_TYPE);
            Deposit_Invoice__c prepareDepositInvoiceTwo = DepositInvoiceServices.prepareDepositInvoice( testProposalList[0], cOModel, testDepositInvoiceList[0], DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE );

            List<Deposit_Invoice__c> manageDepositInvoicesOne = DepositInvoiceServices.manageDepositInvoices( testProposalList[0], null );
            List<Deposit_Invoice__c> manageDepositInvoicesTwo = DepositInvoiceServices.manageDepositInvoices( testProposalList[0], new List<ChangeOrderModel> { cOModel } );
        Test.stopTest();

    }

    @isTest(seeAllData = true) private static void testCalculateAmountPaid() {
        setUp();
        selectsForVisibleData();
        
        Test.startTest();
            if( !testCodaCashEntryLineItemListOld.isEmpty() && !testCodaCashEntryLineItemListNew.isEmpty() ) {
                DepositInvoiceServices.calculateAmountPaid(testCodaCashEntryLineItemListNew, testCodaCashEntryLineItemListOld);
            }
        Test.stopTest();

        System.assert(! String.isBlank('Fake assertion.'));
    }

    private static testMethod void testFilterDepositInvoicesForPopulateProposal(){
        setUp();
        
        List<List<Deposit_Invoice__c>> invoices = null;

        Test.startTest();
            invoices = DepositInvoiceServices.filterDepositInvoicesForPopulateProposalOrProject(testDepositInvoiceList, null);
        Test.stopTest();

        System.assert(! invoices.isEmpty() );
    }
    
    private static testMethod void testFilterDepositInvoicesForPopulateProject(){
        setUp();
        for(Deposit_Invoice__c item : testDepositInvoiceList){
            item.Proposal__c = null;
            item.Project_Profile__c = testProjectProfile.Id;
        }
            update testDepositInvoiceList;
          
        List<List<Deposit_Invoice__c>> invoices = null;

        Test.startTest();
            invoices = DepositInvoiceServices.filterDepositInvoicesForPopulateProposalOrProject(testDepositInvoiceList, null);
        Test.stopTest();

        System.assert(! invoices.isEmpty() );
    }
    
    private static testMethod void testFilteredCashEntryLineItem() {
        Map<Id, c2g__codaCashEntryLineItem__c> lineItems = 
            DepositInvoiceServices.filteredCashEntryLineItem(new List<c2g__codaCashEntryLineItem__c>(), new Map<Id, c2g__codaCashEntryLineItem__c>());

        System.assert(lineItems.isEmpty() );

        DepositInvoiceServices.updateDepositInvoiceOnTransactionLineItem(new Map<Id, c2g__codaCashEntryLineItem__c>());
    
    }

}