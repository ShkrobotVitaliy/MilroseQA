@isTest
private class TestInvoiceController {
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PHASE = 4;
	private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 5;
	private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 5;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
	private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 3;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUBMER_TO_CREATE_SALES_INVOICE = 5;
	private static final Integer NUBMER_TO_CREATE_TRANSACTION = 5;
	private static final Integer NUBMER_TO_CREATE_COMPANY = 5;
	private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
	private static final Decimal TOTAL_SERVICE_AMOUNT = 4.5;
	private static final Decimal BILLING_LINE_ITEM_QUANTITY = 3.4;
	private static final Decimal BILLING_LINE_ITEM_UNIT_PRICE = 1.3;
	private static final String TEST_INVOICE_FORMAT = 'Standard';
	private static final String TEST_FLOOR_VALUE = '1';
	private static final String DAY_OF_WEEK_TODAY = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('EEEE');
	private static final Double SERVICE_ITEM_SHREDDING_FEES_TEST_VALUE = 1.2;
	private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
																					ProjectProfileServices.BILLINGMETHODMILESTONE,
																					ProjectProfileServices.BILLINGMETHODPERCENTAGE};
	private static final String FIRST_QUARTERLY_MONTH_VALUE = '1st';
	private static final Decimal PURCHASE_ORDER_AMOUNT = 10000;

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Phase__c> testPhaseList;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Billing_Line_Item__c> testBillingLineItemList;
	private static List<Purchase_Order__c> testPurchaseOrderList;
	private static List<Pro_forma_Invoice__c> testProformaInvoiceList;
	private static List<Deposit_Invoice__c> testDepositInvoiceList;
	private static List<Floor__c> testFloorList;
	private static User projectManagerUser;
	private static User partnerUser;

	private static PageReference testPage;
	private static InvoiceController testController;
	private static ApexPages.StandardController testStandardController;

	private static void setupData (List<String> billingMethodList, String projectFrequencyValue){
		projectFrequencyValue = String.isEmpty(projectFrequencyValue) ? DateUtils.WEEKLY : projectFrequencyValue;

		Id testUserId = UserInfo.getUserId();
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		//create Accounts for test
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		//create Contacts with accounts for test
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT,
																	new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
		//create Region, Municipality, Building, Phases for test
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, null, null, null, null, false);
		for(Building__c item : testBuildingList){
			item.Name = 'testBuilding';
		}
		insert testBuildingList;

		testProposalList = new List<Proposal__c>();
		for (String stringItem : billingMethodList){
			for (Proposal__c proposalItem : TestingUtils.createProposalList (NUMBER_TO_CREATE_PROJECT_PROFILE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
																				testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
																				null, null, null, null, partnerUser.Id, testUserId, projectManagerUser.Id, false)){
				proposalItem.Is_Floors_To_Services__c = true;
				proposalItem.Billing_Method__c = stringItem;
				proposalItem.Frequency__c = projectFrequencyValue;
				if (projectFrequencyValue == DateUtils.WEEKLY){
					proposalItem.Billing_day__c = DAY_OF_WEEK_TODAY;
				}
				if (projectFrequencyValue == DateUtils.MONTHLY){
					proposalItem.Billing_day__c = String.valueOf(Date.today().day());
				}
				if (projectFrequencyValue == DateUtils.QUARTERLY){
					proposalItem.Billing_day__c = String.valueOf(Date.today().day());
					proposalItem.Quarterly_Month__c = FIRST_QUARTERLY_MONTH_VALUE;
				}
				testProposalList.add(proposalItem);
			}
		}
		insert testProposalList;
		//create Project Profile for test
		testProjectProfileList = new List<Project_Profile__c>();
		for (Proposal__c proposalItem : testProposalList){
			for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( 1, testAccountList[0].Id, testContactWithAccountList[0].Id,
																								testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
																								testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
				projectProfileItem.Proposal__c = proposalItem.Id;
				projectProfileItem.Frequency__c = projectFrequencyValue;
				if (projectFrequencyValue == DateUtils.WEEKLY){
					projectProfileItem.Billing_day__c = DAY_OF_WEEK_TODAY;
				}
				if (projectFrequencyValue == DateUtils.MONTHLY){
					projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
				}
				if (projectFrequencyValue == DateUtils.QUARTERLY){
					projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
					projectProfileItem.Quarterly_Month__c = FIRST_QUARTERLY_MONTH_VALUE;
				}
				projectProfileItem.Total_Service_Amount__c = TOTAL_SERVICE_AMOUNT;
				projectProfileItem.Invoice_Format__c = TEST_INVOICE_FORMAT;
				projectProfileItem.Floor_s__c = TEST_FLOOR_VALUE;
				projectProfileItem.Account_Executive__c = testUserId;
				projectProfileItem.Billing_Method__c = proposalItem.Billing_Method__c;
				projectProfileItem.Project_Name__c = 'TestProject';
				projectProfileItem.Building__c = testBuildingList[0].Id;
				testProjectProfileList.add(projectProfileItem);
			}
		}
		insert testProjectProfileList;

		Map<Id, Proposal__c> temporaryPrfoposalMap = new Map<Id, Proposal__c>(testProposalList);
		Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>(testProjectProfileList);

		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			 temporaryPrfoposalMap.get(projectProfileItem.Proposal__c).Project_Profile__c = projectProfileItem.Id;
		}
		update testProjectProfileList;

		Map<Id, Purchase_Order__c> projectWithPurchaseOrderMap = new Map<Id, Purchase_Order__c>();
		Map<Id, Phase__c> projectWithPhaseMap = new Map<Id, Phase__c>();
		Map<Id, Service_Item__c> projectWithServiceItemMap = new Map<Id, Service_Item__c>();
		Map<Id, Floor__c> projectWithFloorMap = new Map<Id, Floor__c>();

		testDepositInvoiceList = new List<Deposit_Invoice__c>();
		testPhaseList = new List<Phase__c>();
		testFloorList = new List<Floor__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList) {
			for (Phase__c phaseItem : TestingUtils.createPhaseList(1, false)){
				phaseItem.Project_Profile__c = projectProfileItem.Id;
				phaseItem.Is_default__c = true;
				phaseItem.Name__c = 'test phase';
				projectWithPhaseMap.put(projectProfileItem.Id, phaseItem);
				testPhaseList.add(phaseItem);
			}
			Integer invoiceNumber = 1;
			for (Deposit_Invoice__c depositInvoiceItem : TestingUtils.createDepostiInvoiceList(2,false)){
				depositInvoiceItem.Project_Profile__c = projectProfileItem.Id;
				depositInvoiceItem.Deposit_Invoice_Type__c = invoiceNumber++ == 1 ? DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE : DepositInvoiceServices.SERVICE_RETAINER_TYPE;
				testDepositInvoiceList.add(depositInvoiceItem);
			}
			for (Floor__c floorItem : testingUtils.createFloorList(1, false)){
				floorItem.Project__c = projectProfileItem.Id;
				projectWithFloorMap.put(projectProfileItem.Id, floorItem);
				testFloorList.add(floorItem);
			}
		}
		insert testPhaseList;
		insert testDepositInvoiceList;
		insert testFloorList;

		testServiceItemList = new List<Service_Item__c>();
		testPurchaseOrderList = new List<Purchase_Order__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList) {
			for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
				serviceItemItem.Project_Profile__c = projectProfileItem.Id;
				serviceItemItem.Proposal__c = projectProfileItem.Proposal__c;
				serviceItemItem.Phase__c = projectWithPhaseMap.get(projectProfileItem.Id).Id;
				serviceItemItem.Subtype__c = ServiceItemServices.SUBTYPE_AHV;
				serviceItemItem.Floor__c = projectWithFloorMap.get(projectProfileItem.Id).Id;
				serviceItemItem.Original__c = true;
				projectWithServiceItemMap.put(projectProfileItem.Id, serviceItemItem);
				testServiceItemList.add(serviceItemItem);
			}
			for (Purchase_Order__c po : TestingUtils.createPurchaseOrderList(1, Date.today(), false)){
				po.Project_Profile__c = projectProfileItem.Id;
				projectWithPurchaseOrderMap.put(projectProfileItem.Id, po);
				testPurchaseOrderList.add(po);
			}
		}
		insert testServiceItemList;
		insert testPurchaseOrderList;

		testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList) {
			for (Pro_forma_Invoice__c pfi : TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE_PRO_FORMA_INVOICE, projectProfileItem.Billing_Company_Name__c, projectProfileItem.Billing_Company_Contact__c, testBuildingList[0].Id, false)){
				pfi.Project_Profile__c = projectProfileItem.Id;
				pfi.Tax__c = 0.1;
				pfi.Subtotal__c = 100;
				pfi.Invoice_Date__c = Date.today().addDays(30);
				pfi.Purchase_Order__c = projectWithPurchaseOrderMap.get(projectProfileItem.Id).Id;
				testProformaInvoiceList.add(pfi);
			}
		}
		insert testProformaInvoiceList;

		testBillingLineItemList = new List<Billing_Line_Item__c>();
		for(Pro_forma_Invoice__c pfi : testProformaInvoiceList){
			for(Billing_Line_Item__c bli : TestingUtils.createBillingLineItemList(1, pfi.Project_Profile__c, pfi.Billing_Client_Company__c, pfi.Billing_Contact__c, false)){
				bli.Pro_forma_Invoice__c = pfi.Id;
				bli.Description__c = 'test description';
				bli.Service_Item__c = projectWithServiceItemMap.get(pfi.Project_Profile__c).Id;
				testBillingLineItemList.add(bli);
			}
		}
		insert testBillingLineItemList;
	}

	private static List<Billing_Line_Item__c> createBillingLineItem (Integer numberToCreate, List<Service_Item__c> serviceItemList, Boolean doInsert){
		Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>(testProjectProfileList);

		List<Billing_Line_Item__c> resultBillingLineItemList = new List<Billing_Line_Item__c>();
		for (Service_Item__c serviceItemItem : serviceItemList){
			Project_Profile__c projectProfileItem = projectProfileMap.get(serviceItemItem.Project_Profile__c);
			for (Billing_Line_Item__c billingLineItemItem : TestingUtils.createBillingLineItemList (numberToCreate,
																									serviceItemItem.Project_Profile__c,
																									projectProfileItem.Billing_Company_Name__c,
																									projectProfileItem.Billing_Company_Contact__c,
																									false)){
				billingLineItemItem.Milestone_Date__c = DateUtils.getDateWithPeriodAndStartDay(Date.today(), projectProfileItem.Frequency__c, projectProfileItem.Billing_day__c, projectProfileItem.Quarterly_Month__c).addDays(-1);
				billingLineItemItem.Project_Address__c = projectProfileItem.Building__c;
				billingLineItemItem.Service_Item__c = serviceItemItem.Id;
				billingLineItemItem.Phase__c = serviceItemItem.Phase__c;
				resultBillingLineItemList.add(billingLineItemItem);
			}
		}
		if(doInsert){
			insert resultBillingLineItemList;
		}

		return resultBillingLineItemList;
	}

	private static void preparePageController (Pro_forma_Invoice__c proformaInvoiceForStandardController){
		testPage = Page.Invoice;
		Test.setCurrentPage(testPage);
		if (proformaInvoiceForStandardController != null) {
			ApexPages.currentPage().getParameters().put('p', proformaInvoiceForStandardController.Id);
			testStandardController = new ApexPages.standardController(proformaInvoiceForStandardController);
			testController = new InvoiceController();
		}
	}

	private static testmethod void testInitController(){
		setupData(BILLING_METHOD_VALUES_LIST, null);

		Test.startTest();

			for(Pro_forma_Invoice__c pfi : testProformaInvoiceList) {
				preparePageController( pfi );	
			}
			preparePageController(testProformaInvoiceList[0]);
			System.assert(testController != null );

			//for test coverage
			System.assert(testController.content != null);

			Boolean testBolean;
			String testString;
			Decimal testDecimal;

			testBolean = testController.address1 == null;
			testBolean = testController.address2 == null;
			testBolean = testController.content.outstAmt30 == null;
			testBolean = testController.content.outstAmt60 == null;
			testBolean = testController.content.outstAmt90 == null;
			testBolean = testController.content.outstAmt90plus == null;
			testBolean = testController.content.outstAmtTotal == null;
			testBolean = testController.content.poUnbilled == null;
			testBolean = testController.content.srvDepositShow == null;
			testBolean = testController.content.srvDepositPaid == null;
			testBolean = testController.content.srvDepositApplied == null;
			testBolean = testController.content.srvDepositRemaining == null;
			testBolean = testController.content.showPRArea;
			testString = testController.content.prTitle;
			testString = testController.content.prPhone;
			testString = testController.content.lines.get(0).serviceNameShort;
			testString = testController.content.lines.get(0).description;
			testDecimal = testController.content.lines.get(0).unitPrice;
			testDecimal = testController.content.lines.get(0).amount;
			Boolean showUnitPrice = testController.content.lines.get(0).showUnitPrice;
			List<Billing_Line_Item__c> hourlyBlis = testController.content.hourlyBlis;
			Boolean hourlyInvoiceDescriptionRendered = testController.content.hourlyInvoiceDescriptionRendered;

			Building__c building = TestingUtils.createBuildingList (1, null, null, null, null, null, true)[0];
			Building_AKA__c bAKA = new Building_AKA__c(Building__c=building.Id);
			INSERT bAKA;

			Project_Profile__c profile = TestingUtils.createProjectProfileForTest( 1, false)[0];
			profile.Building_AKA__c = bAKA.Id;
			INSERT profile;

			testProformaInvoiceList[0].Project_Profile__c = profile.Id; 
			UPSERT testProformaInvoiceList[0];

			preparePageController( testProformaInvoiceList[0] );

		Test.stopTest();
	}
}