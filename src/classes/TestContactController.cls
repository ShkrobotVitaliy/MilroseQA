@isTest
private class TestContactController {
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;

	private static List<Account> testAccountList;
	private static List<Contact> testContactList;
	private static ApexPages.StandardController standardController;
	private static ContactController testController;

	private static void setupData (){
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
	}

	private static void createController(){
		testContactList = new List<Contact>{new Contact()};
		standardController = new ApexPages.StandardController(testContactList[0]);
	}

	private static void setupPageAndUrlParams(Id clientCompany, Id billingCompany, Id contactCompany){
		PageReference testPage = Page.ProjectBillingMethodViewerPage;
		Test.setCurrentPage(testPage);

		ApexPages.currentPage().getParameters().put('primaryClientCompany', clientCompany);
		ApexPages.currentPage().getParameters().put('primaryBillingCompany', billingCompany);
		ApexPages.currentPage().getParameters().put('accountingContactCompany', contactCompany);
	}

	private static testmethod void testCreateControllerWithoutAccount(){
		setupData();
		createController();

		Test.startTest();
			testController = new ContactController(standardController);
		Test.stopTest();

		System.assert(testController.contact.Id == null);	
		System.assert(! String.isBlank(testController.selectedAccountId));	
	}

	private static testmethod void testCreateControllerWithAccount(){
		setupData();
		createController();
		setupPageAndUrlParams(testAccountList[0].id, testAccountList[1].id, testAccountList[2].id);

		Test.startTest();
			testController = new ContactController(standardController);
		Test.stopTest();

		System.assert(! String.isBlank(testController.selectedAccountId));		
	}

	private static testmethod void testGetAccountOptions(){
		setupData();
		createController();
		setupPageAndUrlParams(testAccountList[0].id, testAccountList[1].id, testAccountList[2].id);
		
		Test.startTest();
			testController = new ContactController(standardController);
		Test.stopTest();

		System.assertEquals (testAccountList.size() + 1, testController.getAccountOptions().size());

	}

	private static testmethod void testCompanyNameAction(){
		setupData();
		createController();
		setupPageAndUrlParams(testAccountList[0].id, testAccountList[1].id, testAccountList[2].id);

		testController = new ContactController(standardController);
		testController.selectedAccountId = testAccountList[0].id;

		Test.startTest();
			testController.companyNameAction();
		Test.stopTest();

		System.assertEquals (testAccountList[0].id, testController.contact.AccountId);
	}

	private static testmethod void testAddNewContactActionUnsuccessful(){
		setupData();
		createController();
		setupPageAndUrlParams(testAccountList[0].id, testAccountList[1].id, testAccountList[2].id);

		testController = new ContactController(standardController);
		testController.selectedAccountId = testAccountList[0].id;

		Test.startTest();
			testController.addNewContactAction();
		Test.stopTest();

		//Contact has not been created: required field Last Name is empty
		System.assertEquals (null, testController.contact.Id);
	}

	private static testmethod void testAddNewContactActionSuccessful(){
		setupData();
		createController();
		setupPageAndUrlParams(testAccountList[0].id, testAccountList[1].id, testAccountList[2].id);

		testController = new ContactController(standardController);
		testController.selectedAccountId = testAccountList[0].id;
		testController.contact.LastName = 'contact test name';
		testController.contact.FirstName = 'contact test name';

		Test.startTest();
			testController.addNewContactAction();
		Test.stopTest();

		System.assert (testController.contact.Id != null);
	}
}