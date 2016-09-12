@isTest
private class TestProposalWizardStep2Controller {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
	private static final Integer NUMBER_TO_CREATE_PHASE = 3;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
	private static final Decimal TEST_PROPOSAL_COST = 1.2;
	private static final Decimal TEST_PROPOSAL_TOTAL_SERVICE_AMOUNT = 3.4;
	private static final Decimal TEST_PROPOSAL_SALES_TAX = 5.6;

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
	private static ProposalWizardStep2Controller testController;

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

	private static void prepareDataForTest(){
		testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
		for (Proposal__c proposalItem : testProposalList){
			proposalItem.Cost__c = TEST_PROPOSAL_COST;
			proposalItem.Total_Service_Amount__c = TEST_PROPOSAL_TOTAL_SERVICE_AMOUNT;
			proposalItem.Sales_Tax__c = TEST_PROPOSAL_SALES_TAX;
			proposalItem.sowNoneOfTheAbove__c = true;
			proposalItem.Is_Draft__c = true;
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
				testServiceItemList.add(serviceItemItem);
			}
		}
		insert testPhaseList;


		for (Phase__c phaseItem : testPhaseList){
			for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, phaseItem.Proposal__c, false)){
				serviceItemItem.Phase__c = phaseItem.Id;
				serviceItemItem.Is_Alternative__c = false;
				testServiceItemList.add(serviceItemItem);
			}
			integer serviceGroupKeyItem = 1;
			for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, phaseItem.Proposal__c, false)){
				serviceItemItem.Service_Group_Key__c = String.valueOf(serviceGroupKeyItem);
				serviceItemItem.Phase__c = phaseItem.Id;
				serviceItemItem.Is_Alternative__c = false;
				testServiceItemList.add(serviceItemItem);
				serviceGroupKeyItem++;
			}
		}
		insert testServiceItemList;
	}

	private static void preparePageController (Proposal__c proposalForStandardController){
		testPage = Page.ProposalWizardStep2;
		Test.setCurrentPage(testPage);
		if (proposalForStandardController != null) {
			testStandardController = new ApexPages.standardController(proposalForStandardController);
			testController = new ProposalWizardStep2Controller(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		setupData();
		prepareDataForTest();

		Test.startTest();

			preparePageController(testProposalList[0]);
			System.assert(testController != null);

			//for test coverage
			Boolean testBoolean;
			testBoolean = testController.serializedProposal == null;
			testBoolean = testController.disableInputs == null;
			testBoolean = testController.viewOnly == null;
			testBoolean = testController.getViewOnly() == null;
			testBoolean = testController.getIsScopeOfWorkRequired() == null;
			testBoolean = testController.getIsIrValid() == null;
			testBoolean = testController.getIsIdValid() == null;
			testBoolean = testController.getIsErValid() == null;
			testBoolean = testController.getIsFaValid() == null;
			testBoolean = testController.getIsSpValid() == null;
			testBoolean = testController.getIsSmValid() == null;
			testBoolean = testController.getIsIrValidEmpty() == null;
			testBoolean = testController.getIsIdValidEmpty() == null;
			testBoolean = testController.getIsErValidEmpty() == null;
			testBoolean = testController.getIsFaValidEmpty() == null;
			testBoolean = testController.getIsSpValidEmpty() == null;
			testBoolean = testController.getIsSmValidEmpty() == null;
			testBoolean = testController.additionalScopeFirstQuestionsAction() == null;
			testBoolean = testController.additionalScopeLastQuestionAction() == null;
			testBoolean = testController.getQuestionList() == null;
			testBoolean = testController.getEnableStep2Summary() == null;
			testBoolean = testController.getSowScopeOfWork() == null;
			testBoolean = testController.getSowAsbestosInvestigationOptions() == null;
			testController.sowSpaceAlterTypeSelected = new List<String>{'1'};
			testBoolean = testController.sowSpaceAlterTypeSelected == null;
			testBoolean = testController.getSowSpaceAlterType() == null;
			testController.sowACUnitsNumber = '1';
			testBoolean = testController.sowACUnitsNumber == null;
			testController.sowErBasSelected = new List<String>{'1'};
			testBoolean = testController.sowErBasSelected == null;
			testBoolean = testController.getSowErBas() == null;
			testBoolean = testController.getSow_ir_override() == null;
			testBoolean = testController.getSow_id_override() == null;
			testBoolean = testController.getSow_er_override() == null;
			testBoolean = testController.getSow_sp_override() == null;
			testBoolean = testController.getSow_sm_override() == null;
			testBoolean = testController.profileName == null;
			testBoolean = testController.currentUserRoleName == null;
			testBoolean = testController.getIsCZAnalyst() == null;
			testBoolean = testController.getIsAdmin() == null;
			testBoolean = testController.getIsPS() == null;
			testBoolean = testController.getIsCZSpesialistRequired() == null;
			testBoolean = testController.getAdditionalProposalFields(testController.proposal.Id) == null;

		Test.stopTest();
	}
}