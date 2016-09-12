@isTest
private class TestCreateFormItemPDFController {
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 2;
	private static final Integer NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1 = 5;

	private static List<Task_item__c> testTaskItemList;
	private static List<Form_Item__c> testFormItemList;
	private static List<Form_Meta_Data_Object_1__c> testFormMetaDataObject1List;

	private static CreateFormItemPDFController testController;

	private static void prepareData(){
		testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);
		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();

		testFormItemList = new List<Form_Item__c>();
		for (Task_Item__c taskItemItem : testTaskItemList){
			for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
				formItemItem.Complete_Forms__c = taskItemItem.Id;
				testFormItemList.add(formItemItem);
			}
		}
		insert testFormItemList;

		for (Form_Item__c formItemItem : testFormItemList){
			Integer versionItem = 1;
			for (Form_Meta_Data_Object_1__c testFormMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1, formItemItem.Id, false)){
				testFormMetaDataObject1Item.Task_Item__c = formItemItem.Complete_Forms__c;
				testFormMetaDataObject1Item.Version__c = versionItem++;
				testFormMetaDataObject1List.add(testFormMetaDataObject1Item);
			}
		}
		insert testFormMetaDataObject1List;
	}

	private static void createController(Form_Meta_Data_Object_1__c formMetadataObject1){
		Test.setCurrentPage(Page.CreateFormItemPDFHelper);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(formMetadataObject1.Id));
		testController = new CreateFormItemPDFController();
	}

	private static testmethod void testInitController(){
		prepareData();

		Test.startTest();
			createController(testFormMetaDataObject1List[0]);
		Test.stopTest();

		System.assert(testController.isValid);
	}

	private static testmethod void testrGoBack(){
		prepareData();

		createController(testFormMetaDataObject1List[0]);
		testController.formMetaData = testFormMetaDataObject1List[0];

		PageReference resultPageReference;

		Test.startTest();
			resultPageReference = testController.goBack();
		Test.stopTest();

		System.assert(resultPageReference != null);
	}

	private static testmethod void testrUNdDP(){
		prepareData();

		createController(testFormMetaDataObject1List[0]);

		PageReference resultPageReference;

		Test.startTest();
			resultPageReference = testController.runDdp();
		Test.stopTest();

		System.assert(resultPageReference != null);
	}
}