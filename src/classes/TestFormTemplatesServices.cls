@isTest
private class TestFormTemplatesServices {
	private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 4;
	private static final Integer NUMBER_TO_CREATE_REGION = 3;
	private static final Integer NUMBER_TO_CREATE_LOOP_DDP = 4;
	private static final String TEST_FORM_TEMPLATE_START_NAME = 'F';

	private static List<Form_Template__c> testFormTemplateList;
	private static List<Region__c> testRegionList;
	private static List<Loop__DDP__c> testLoopDDPList;

	private static testmethod void testGetFormTemplatesByFormId(){
		testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, TEST_FORM_TEMPLATE_START_NAME, true);

		Set<String> formsIdSet = new Set<String>();

		for (Form_Template__c formTemplateItem : testFormTemplateList){
			formsIdSet.add(formTemplateItem.Form_ID__c);
		}

		Map<String, Form_Template__c> resaltFormTemplateFormIdWithFormTemplateMap;

		Test.startTest();

			resaltFormTemplateFormIdWithFormTemplateMap = FormTemplatesServices.getFormTemplatesByFormId(formsIdSet);

		Test.stopTest();

		System.assert(!resaltFormTemplateFormIdWithFormTemplateMap.isEmpty());
		System.assertEquals(formsIdSet, resaltFormTemplateFormIdWithFormTemplateMap.keySet());
	}

	private static testmethod void testBuildQueryWhereForm(){
		testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, TEST_FORM_TEMPLATE_START_NAME, false);
		for (Integer i = 0; i < testFormTemplateList.size(); i++){
			testFormTemplateList[i].Name = testFormTemplateList[i].Form_ID__c;
			testFormTemplateList[i].Form_Name__c = testFormTemplateList[i].Form_ID__c;
			testFormTemplateList[i].Municipality__c = testFormTemplateList[i].Form_ID__c;
			testFormTemplateList[i].Region__c = testFormTemplateList[i].Form_ID__c;
		}

		String resultString;

		Test.startTest();

			resultString = FormTemplatesServices.buildQueryWhere (testFormTemplateList[0].Form_ID__c,
																  testFormTemplateList[0].Name,
																  testFormTemplateList[0].Form_Name__c,
																  testFormTemplateList[0].Municipality__c,
																  testFormTemplateList[0].Region__c,
																  true,
																  true,
																  true);

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}

	private static testmethod void testBuildQuery(){
		String resultString;

		Test.startTest();

			resultString = FormTemplatesServices.buildQuery ('');

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}

	private static testmethod void testAttachDDPToFormTemplate(){
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
		testRegionList = [SELECT Id, Name
						  FROM Region__c
						  WHERE Id IN : testRegionList];

		testLoopDDPList = new List<Loop__DDP__c>();
		for (Region__c regionItem : testRegionList) {
			testLoopDDPList.addAll(TestingUtils.createLoopDDPList(NUMBER_TO_CREATE_LOOP_DDP, false));
		}
		insert testLoopDDPList;
		testLoopDDPList = [SELECT Id, Name
						   FROM Loop__DDP__c
						   WHERE Id IN : testLoopDDPList];

		testFormTemplateList = new List<Form_Template__c>();
		for (Region__c regionItem : testRegionList){
			integer i = 1;
			for (Loop__DDP__c loopDDPItem : testLoopDDPList){
				for(Form_Template__c formTemplateItem : TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, TEST_FORM_TEMPLATE_START_NAME + String.valueOf(i), false)){
					formTemplateItem.Region__c = regionItem.Name;
					formTemplateItem.Name = loopDDPItem.Name;
					testFormTemplateList.add(formTemplateItem);
				}
			}
		}

		Test.startTest();

			FormTemplatesServices.attachDDPToFormTemplate(testFormTemplateList);

		Test.stopTest();

		for (Form_Template__c formTemplateItem : testFormTemplateList){
			System.assert(formTemplateItem.Region_Lookup__c != null);
			System.assert(formTemplateItem.PDF_Template__c != null);
		}
	}
}