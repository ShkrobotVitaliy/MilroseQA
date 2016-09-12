@isTest
private class TestCustomTncEditor {
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 1;
	private static final Integer NUMBER_TO_CREATE_TERMS_AND_CONDITIONS = 1;
	private static final List<String> TERMS_AND_CONDITIONS_TYPE_LIST = new List<String>{CustomTncEditor.CONTRACT_CLAUSES,
																						CustomTncEditor.TERMS_AND_CONDITIONS,
																						'test type'};

	private static List<Account> testAccountListWithTermsList;
	private static List<Terms_And_Conditions__c> testTermsAndConditionsList;

	private static PageReference testPage;
	private static CustomTncEditor testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		testAccountListWithTermsList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, 'Account with terms', false);
		for (Account accountItem : testAccountListWithTermsList){
			accountItem.TncStartDate__c = Date.today();
			accountItem.TncEndDate__c = Date.today().addDays(5);
		}
		insert testAccountListWithTermsList;

		testTermsAndConditionsList = new List<Terms_And_Conditions__c>();
		for (Account accountItem : testAccountListWithTermsList){
			for (String typeItem : TERMS_AND_CONDITIONS_TYPE_LIST){
				for(Terms_And_Conditions__c termsAndConditionsItem : TestingUtils.createTermsAndConditionsList(NUMBER_TO_CREATE_TERMS_AND_CONDITIONS, accountItem.Id, false)){
					termsAndConditionsItem.Type__c = typeItem;
					termsAndConditionsItem.Page_Number__c = 1;
					testTermsAndConditionsList.add(termsAndConditionsItem);
				}
			}
		}
		insert testTermsAndConditionsList;
	}

	private static void preparePageController (Account accountItem){
		testPage = Page.CustomTncEditor;
		Test.setCurrentPage(testPage);
		testStandardController = new ApexPages.standardController(accountItem);
		testController = new CustomTncEditor(testStandardController);
	}

	private static testMethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			preparePageController(testAccountListWithTermsList[0]);

			System.assert(testController != null);
			Boolean testBool = testController.addPage() == null;
			testController.pageNumberToDelete = 2;
			testBool = testController.deletePage() == null;
			testBool = testController.populateDefault() == null;
			testBool = testController.goBack() == null;
			testBool = testController.preview() == null;
			testBool = testController.save() == null;

		Test.stopTest();
	}

	private static testMethod void testInitControllerWithoutAccountId(){
		Test.startTest();

			preparePageController(new Account ());

			System.assert(testController != null);

		Test.stopTest();
	}

	private static testMethod void testInitControllerWithIncorrectData(){
		Id fakeAccountId = Id.valueOf(Account.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

		Test.startTest();

			preparePageController(new Account (Id = fakeAccountId));

			System.assert(testController != null);

		Test.stopTest();
	}
}