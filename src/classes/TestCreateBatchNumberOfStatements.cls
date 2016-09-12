@isTest
private class TestCreateBatchNumberOfStatements {
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 1;
	private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 3;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
	private static final Decimal BILLING_LINE_ITEM_AMOUNT = 10.1;
	private static final Integer PURCHASE_ORDER_NUMBER = 3;
	private static final Integer TAKS_ITEM_NUMBER = 3;

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Billing_Line_Item__c> testBillingLineItemList;
	private static List<Pro_forma_Invoice__c> testProFormaInvoiceList;
	private static List<Proposal__c> testProposalList;
	private static User projectManagerUser;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Billing_Line_Item__c> oldTestBillingLineItemList;
	private static List<DDP_Helper__c> testDDPHelperList;
	private static List<Contact> testContactList;

	private static CreateBatchNumberOfStatements testBatch;

	private static void setupData(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, false);
		for(Account accountItem : testAccountList){
			accountItem.Do_Not_Send_Statements_Automatically__c = false;
		}
		insert testAccountList;

		Integer emailPref = 1;
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, testAccountList[0].Id, false);
		for (Contact contactItem : testContactWithAccountList){
			contactItem.Is_Active__c = true;
			contactItem.Email = 'test' + String.valueOf(emailPref++) + '@gmail.com';
		}
		testContactList = TestingUtils.createContactList(1, false);
		for (Contact contactItem : testContactList){
			contactItem.Email_Statements_Job_Error__c = true;
			contactItem.Email_Statement_Sent_Date_Time__c = DateTime.now().addDays(5);
		}
		testContactList.addAll(testContactWithAccountList);
		insert testContactList;

		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'BillingLineItem', true);
		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectProfileList = TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
																		testAccountList[0].Id, testContactWithAccountList[0].Id, testAccountList[0].Id,
																		testContactWithAccountList[0].Id, projectManagerUser.Id, false );
		testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
		for(Integer i = 0; i < testProjectProfileList.size(); i++) {
			testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
		}
		insert testProjectProfileList;
	}

	private static void prepareData(){
		Site_URL__c site = new Site_URL__c();
		site.Name = String.valueOf(UserInfo.getOrganizationId().subString(0, 15));
		site.Token_Endpoint__c = 'https://test.salesforce.com/';
		site.Login_to_SF__c = 'test@login.com';
		site.Password__c = 'testPassword';
		site.Client_Id__c = 'testclientid';
		site.Client_Secret__c = 'testclientsecret';
//		insert site;

		setupData();
		testBillingLineItemList = new List<Billing_Line_Item__c>();
		testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
		testServiceItemList = new List<Service_Item__c>();

		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Pre_billed__c = false;
			projectProfileItem.Billing_Method__c = 'Milestone';
			for(Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
				serviceItem.Project_Profile__c =    projectProfileItem.Id;
				serviceItem.Proposal__c = projectProfileItem.Proposal__c;
				serviceItem.Met_Data_Scanning_Fee__c = 10;
				serviceItem.Quantity__c = 100;
				serviceItem.Tax_Percent_1__c = 15;
				serviceItem.Tax_Percent_2__c = 15;
				testServiceItemList.add(serviceItem);
			}
			for(Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList ( NUMBER_TO_CREATE_PRO_FORMA_INVOICE, projectProfileItem.Billing_Company_Name__c,
																									projectProfileItem.Billing_Company_Contact__c, testBuildingList[0].Id, false )){
				proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
				testProFormaInvoiceList.add(proformaInvoiceItem);
			}

		}
		update testProjectProfileList;
		insert testServiceItemList;
		insert testProFormaInvoiceList;

		for (Pro_forma_Invoice__c proFormaInvoiceItem : testProFormaInvoiceList){
			for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( NUMBER_TO_CREATE_BILLING_LINE_ITEM, proFormaInvoiceItem.Project_Profile__c,
																								proFormaInvoiceItem.Billing_Client_Company__c,
																								proFormaInvoiceItem.Billing_Contact__c, false)){
				billingLineItem.Pro_forma_Invoice__c = proFormaInvoiceItem.Id;
				billingLineItem.Amount__c = 0.25;
				billingLineItem.Service_Item__c = testServiceItemList[0].Id;
				billingLineItem.Quantity__c = 150;
				billingLineItem.Unit_Price__c = 300;
				billingLineItem.Accounting_Contact__c = proFormaInvoiceItem.Billing_Contact__c;
				billingLineItem.Accounting_Contact_Company__c = proFormaInvoiceItem.Billing_Client_Company__c;
				testBillingLineItemList.add(billingLineItem);
			}
		}
	}

	private static testmethod void testRunBatch(){
		prepareData();

		Test.startTest();
			testBatch = new CreateBatchNumberOfStatements();
			System.assert(testBatch != null);
			Database.executeBatch( testBatch, 1 );
		Test.stopTest();
	}

	private static testmethod void testScheduleJob (){
		String jobExpretion = '0 0 0 3 9 ? 2022';
		String nextTimeJob = '2022-09-03 00:00:00';
		String jobId;

		testBatch = new CreateBatchNumberOfStatements();

		Test.startTest();
			jobId = System.schedule('testScheduledApex', jobExpretion, testBatch);
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
		System.assertEquals(jobExpretion, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
	}
}