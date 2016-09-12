@isTest
private class TestInvoicePDFController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 2;
    private static final Decimal TOTAL_SERVICE_AMOUNT = 4.5;
    private static final String TEST_INVOICE_FORMAT = 'Standard';


	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<Pro_forma_Invoice__c> testProformaInvoiceList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;


	private static PageReference testPage;
	private static InvoicePDFController testController;
	private static ApexPages.StandardController testStandardController;

	private static void setupData(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

		testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);

		for(Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
			projectProfileItem.Frequency__c = DateUtils.MONTHLY;
			projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
			projectProfileItem.Total_Service_Amount__c = TOTAL_SERVICE_AMOUNT;
			projectProfileItem.Invoice_Format__c = TEST_INVOICE_FORMAT;
			projectProfileItem.Account_Executive__c = currentUserId;
		}
		insert testProjectProfileList;

		testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Pro_forma_Invoice__c pfi : TestingUtils.createProFormaInvoiceList(NUMBER_TO_CREATE_PRO_FORMA_INVOICE, projectProfileItem.Billing_Company_Name__c, projectProfileItem.Billing_Company_Contact__c, testBuildingList[0].Id, false)){
				pfi.Project_Profile__c = projectProfileItem.Id;
				testProformaInvoiceList.add(pfi);
			}
		}
		insert testProformaInvoiceList;

	}

	private static void preparePageController (Pro_forma_Invoice__c proformaInvoiceForStandardController, String creditNumber){
		testPage = Page.InvoiceCreditPDF;
		Test.setCurrentPage(testPage);
		if (proformaInvoiceForStandardController != null) {
			ApexPages.currentPage().getParameters().put('invoiceId', proformaInvoiceForStandardController.Id);
			ApexPages.currentPage().getParameters().put('creditNumber', !String.isEmpty(creditNumber) ? creditNumber : '1');
			testController = new InvoicePDFController();
		}
	}

	private static testmethod void testInitController(){
		setupData();

		Test.startTest();

			Pro_forma_Invoice__c pfi = testProformaInvoiceList[0]; 

			preparePageController( pfi, null);
			System.assert(testController != null);

			//for test coverage
			Boolean testBoolean = testController.address1 == null;
			testBoolean = testController.address2 == null;
			testBoolean = testController.isCredit1 == null;
			testBoolean = testController.isCredit2 == null;
			testBoolean = testController.proformaInvoice == null;
			testBoolean = testController.isServicesExist == null;
			testBoolean = testController.countBLIs == null;

			Building__c building = TestingUtils.createBuildingList (1, null, null, null, null, null, true)[0];
			Building_AKA__c bAKA = new Building_AKA__c(Building__c=building.Id);
			INSERT bAKA;

			Project_Profile__c profile = TestingUtils.createProjectProfileForTest( 1, false)[0];
			profile.Building_AKA__c = bAKA.Id;
			INSERT profile;

			pfi.Project_Profile__c = profile.Id; 
			UPSERT pfi;

			preparePageController( pfi, '2');
			String address2 = testController.address2;

		Test.stopTest();
	}
}