@isTest
private class TestProposalController {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
    private static final Integer NUMBER_TO_CREATE_PHASE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Decimal TEST_PROPOSAL_COST = 1.2;
    private static final Decimal TEST_PROPOSAL_SALES_TAX = 5.6;
    private static final Decimal TEST_SERVICE_UNIT_PRICE = 250;
    private static final Decimal TEST_PROPOSAL_TOTAL_SERVICE_AMOUNT = TEST_SERVICE_UNIT_PRICE * NUMBER_TO_CREATE_SERVICE_ITEM * 3;
    private static final String TEST_FULFILLMENT_OFFICE = 'test ffo';

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;

    private static List<Phase__c> testPhaseList;
    private static List<Service_Item__c> testServiceItemList;

    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPage;
    private static ApexPages.StandardController testStandardController;
    private static ProposalController testController;

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void prepareCastomSettingForTest(){
        FulfillmentOfficeAddresses__c ffo = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE);
        insert ffo;
    }

    private static void prerareDataForTest(){
        prepareCastomSettingForTest();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
            proposalItem.Cost__c = TEST_PROPOSAL_COST;
            proposalItem.Total_Service_Amount__c = TEST_PROPOSAL_TOTAL_SERVICE_AMOUNT;
            proposalItem.Sales_Tax__c = TEST_PROPOSAL_SALES_TAX;
        }
        insert testProposalList;

        testServiceItemList = new List<Service_Item__c>();
        testPhaseList = new List<Phase__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false)){
                serviceItemItem.Is_Alternative__c = true;
                serviceItemItem.Quantity__c = 1;
                serviceItemItem.Discount_Percentage__c = 0.1;
                serviceItemItem.Unit_Price__c = 250;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testPhaseList;


        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, phaseItem.Proposal__c, false)){
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Is_Alternative__c = false;
                serviceItemItem.Quantity__c = 1;
                serviceItemItem.Discount_Percentage__c = 0.1;
                serviceItemItem.Unit_Price__c = 250;
                testServiceItemList.add(serviceItemItem);
            }
            integer serviceGroupKeyItem = 1;
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, phaseItem.Proposal__c, false)){
                serviceItemItem.Service_Group_Key__c = String.valueOf(serviceGroupKeyItem);
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Is_Alternative__c = false;
                serviceItemItem.Quantity__c = 1;
                serviceItemItem.Discount_Percentage__c = 0.1;
                serviceItemItem.Unit_Price__c = 250;
                testServiceItemList.add(serviceItemItem);
                serviceGroupKeyItem++;
            }
        }
        insert testServiceItemList;
    }

    private static void createController(String proposalItemId){
        testPage = Page.Proposal;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('p', String.valueOf(proposalItemId));
        ApexPages.currentPage().getParameters().put('dp', 'false');

        testController = new ProposalController();
    }

    private static testmethod void testUncoveredPart() {
        Test.startTest();
            setupData();
            prerareDataForTest();
			testProposalList[0].Reimbursable_Items_Basis__c = true;
			UPSERT testProposalList[0];
            String proposalItemId = testProposalList[0].Id;
            testPage = Page.Proposal;
            Test.setCurrentPage(testPage);
            ApexPages.currentPage().getParameters().put('p', String.valueOf(proposalItemId));
            ApexPages.currentPage().getParameters().put('dp', 'false');
            ProposalController tC = new ProposalController();

            String address1 = tC.address1;
            String address2 = tC.address2; 
            String partnerImage  = tC.partnerImage ;
            String firstTimeSendToClientDate  = tC.firstTimeSendToClientDate;
            Decimal salesTax  = tC.salesTax;
            Decimal reimbursable  = tC.reimbursable;
            Decimal servicesTotal  = tC.servicesTotal;
            Decimal servicesTotalWithTax  = tC.servicesTotalWithTax;
            Decimal grandTotal  = tC.grandTotal;
			Decimal retainer = tC.retainer;
			List<Additional_Reimbursable__c> reimbursableList = tC.reimbursableList;

			ApexPages.currentPage().getParameters().put('type','previewtnc');
			ApexPages.currentPage().getParameters().put('previewacc','000000000000000000');
			tC = new ProposalController();
        Test.stopTest();
    }

    private static testmethod void testInitController(){
        setupData();
        prerareDataForTest();

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            createController(testProposalList[0].Id);
            System.assert(testController != null);

            Boolean testBoolean;
            testBoolean = testController.isPreview == null;
            testBoolean = testController.officeAddress  == null;

        Test.stopTest();
    }

    private static testmethod void testInitControllerWithEmptyParameter(){
//        setupData();
//        prerareDataForTest();

        Test.startTest();

            createController('');

        Test.stopTest();

        System.assert(testController != null);
        System.assert(! testController.isValid);
    }

    private static testmethod void testInitControllerWithIncorrectParameter(){
//        setupData();
//        prerareDataForTest();

        Id incorrectProposalId = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        System.assert(incorrectProposalId != null);

        Test.startTest();

            createController(incorrectProposalId);

        Test.stopTest();

        System.assert(! testController.isValid);
    }
}