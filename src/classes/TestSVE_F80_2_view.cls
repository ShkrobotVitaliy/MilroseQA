@isTest
private class TestSVE_F80_2_view {
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 2;
	private static final Integer NUMBER_TO_CREATE_FMDO1 = 2;
	private static final String FIVE_WHITE_SPACES = '     ';

	private static List<Form_Item__c> testFormItemList;
	private static List<Form_Meta_Data_Object_1__c> testFMDOList;

	private static PageReference testPage;
	private static SVE_F80_2_view testController;
	private static ApexPages.StandardController testStandardController;

	private static void setupData(){
		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

		testFMDOList = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItem : testFormItemList){
			Integer i = 0;
			for (Form_Meta_Data_Object_1__c fmdoItem : TestingUtils.createFormMetaDataObject1List(NUMBER_TO_CREATE_FMDO1, formItem.Id, false )){
				fmdoItem.Page_Number__c = i;
				fmdoItem.Visualforce_Page__c = 'TestPagaName' + String.valueOf(i);
				fmdoItem.TEXT_Area_LONG__c = 'test1 text' + FIVE_WHITE_SPACES + 'test2 text';
				testFMDOList.add(fmdoItem);
			}
		}
		insert testFMDOList;
	}

	private static void preparePageController (Form_Meta_Data_Object_1__c fmdoForStandardController){
		testPage = Page.SVE_F80_2_2_view;
		Test.setCurrentPage(testPage);
		if (fmdoForStandardController != null) {
			testStandardController = new ApexPages.standardController(fmdoForStandardController);
			testController = new SVE_F80_2_view(testStandardController);
		}
	}

	private static testmethod void testInitController() {
		setupData();

		Test.startTest();

			preparePageController(testFMDOList[0]);
			System.assert(testController != null);

			//for test coverage
			Boolean testBool;
			testBool = testController.dataItemWrapper == null;
			testBool = testController.Label == null;
			testBool = testController.hidePageBody == null;

			testBool = testController.updateTEXTAreaLONGField() == null;

		Test.stopTest();
	}
}