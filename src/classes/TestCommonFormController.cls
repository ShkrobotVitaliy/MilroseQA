@isTest
private class TestCommonFormController {
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 2;
	private static final Integer NUMBER_TO_CREATE_FMDO1 = 2;

	private static List<Form_Item__c> testFormItemList;
	private static List<Form_Meta_Data_Object_1__c> testFMDOList;

	private static PageReference testPage;
	private static CommonFormController testController;
	private static ApexPages.StandardController testStandardController;

	private static void setupData(){
		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

		testFMDOList = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItem : testFormItemList){
			Integer i = 0;
			for (Form_Meta_Data_Object_1__c fmdoItem : TestingUtils.createFormMetaDataObject1List(NUMBER_TO_CREATE_FMDO1, formItem.Id, false )){
				fmdoItem.Page_Number__c = i;
				fmdoItem.Visualforce_Page__c = 'TestPagaName' + String.valueOf(i);
				testFMDOList.add(fmdoItem);
			}
		}
		insert testFMDOList;
	}

	private static void preparePageController (Form_Meta_Data_Object_1__c fmdoForStandardController){
		testPage = Page.SVE_F1_1;
		Test.setCurrentPage(testPage);
		if (fmdoForStandardController != null) {
			testStandardController = new ApexPages.standardController(fmdoForStandardController);
			testController = new CommonFormController(testStandardController);
		}
	}

	private static testmethod void testInitController() {
		setupData();

		Test.startTest();

			preparePageController(testFMDOList[0]);
			System.assert(testController != null);

			//for test coverage
			Boolean testBool;
			testBool = testController.hidePageBody == null;
			testBool = testController.Label == null;
			testController.record.Page_Number__c = 0;
			testBool = testController.nextPage() == null;
			testController.record.Page_Number__c = 10;
			testBool = testController.prevPage() == null;
			testBool = testController.savePage() == null;
			testBool = testController.cancelPage() == null;
			testBool = testController.updateDocAndDdp() == null;

		Test.stopTest();
	}
}