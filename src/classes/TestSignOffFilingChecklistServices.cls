@isTest
private class TestSignOffFilingChecklistServices {
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
	private static final Integer NUMBER_TO_CREATE_APPLICATION_SIGN_OFF_SCOPE = 4;

	private static List<Task_Item__c> testTaskItemList;
	private static List<Application_Sign_Off_Scope__c> testApplicationSignOffScopeList;

	private static void setupData(Boolean doCreateApplicationSingOffScope){
		testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);
		if(doCreateApplicationSingOffScope){
			testApplicationSignOffScopeList = new List<Application_Sign_Off_Scope__c>();
			for (Task_Item__c taskItemItem : testTaskItemList){
				for (Application_Sign_Off_Scope__c applicationSingOffScopeItem : TestingUtils.createApplicationSignOffScopeList(NUMBER_TO_CREATE_APPLICATION_SIGN_OFF_SCOPE, false)){
					applicationSingOffScopeItem.Task_Item__c = taskItemItem.Id;
					testApplicationSignOffScopeList.add(applicationSingOffScopeItem);
				}
			}
			insert testApplicationSignOffScopeList;
		}
	}

	private static testmethod void testGetSignOffFillingChecklistByTaskItemId(){
		setupData(true);

		Application_Sign_Off_Scope__c resultRecord;

		Test.startTest();

			resultRecord = SignOffFilingChecklistServices.getSignOffFillingChecklistByTaskItemId(testTaskItemList[0].Id);

		Test.stopTest();

		System.assert(resultRecord != null);
		System.assertEquals(testTaskItemList[0].Id, new Map<Id, Application_Sign_Off_Scope__c>(testApplicationSignOffScopeList).get(resultRecord.Id).Task_Item__c);
	}

	private static testmethod void testGetSignOffFillingChecklistByTaskItemIdWithoutApplicationSignOffScope(){
		setupData(false);

		Application_Sign_Off_Scope__c resultRecord;

		Test.startTest();

			resultRecord = SignOffFilingChecklistServices.getSignOffFillingChecklistByTaskItemId(testTaskItemList[0].Id);

		Test.stopTest();

		System.assert(resultRecord == null);
	}

	private static testmethod void testGetSignOffFillingChecklistByTaskItemIdWithoutTaskItem(){
		setupData(true);

		Application_Sign_Off_Scope__c resultRecord;
		String errorString;

		Test.startTest();
			try{
				resultRecord = SignOffFilingChecklistServices.getSignOffFillingChecklistByTaskItemId(null);
			} catch (Exception ex) {
				errorString = ex.getMessage();
			}

		Test.stopTest();

		System.assert(!String.isEmpty(errorString));
		System.assert(resultRecord == null);
	}

	private static testmethod void testGetSignOffFillingChecklistListByTaskItemId(){
		setupData(true);

		List<Application_Sign_Off_Scope__c> resultList;

		Test.startTest();

			resultList = SignOffFilingChecklistServices.getSignOffFillingChecklistListByTaskItemId(testTaskItemList[0].Id);

		Test.stopTest();

		System.assert(resultList != null);
		System.assert(!resultList.isEmpty());
		System.assertEquals(NUMBER_TO_CREATE_APPLICATION_SIGN_OFF_SCOPE, resultList.size());
		for (Application_Sign_Off_Scope__c applicationSingOffScopeItem : resultList){
			System.assertEquals(testTaskItemList[0].Id, new Map<Id, Application_Sign_Off_Scope__c>(testApplicationSignOffScopeList).get(applicationSingOffScopeItem.Id).Task_Item__c);
		}
	}

	private static testmethod void testGetSignOffFillingChecklistListByTaskItemIdWithoutApplicationSignOffScope(){
		setupData(false);

		List<Application_Sign_Off_Scope__c> resultList;

		Test.startTest();

			resultList = SignOffFilingChecklistServices.getSignOffFillingChecklistListByTaskItemId(testTaskItemList[0].Id);

		Test.stopTest();

		System.assert(resultList == null || resultList.isEmpty());
	}

	private static testmethod void testGetSignOffFillingChecklistListByTaskItemIdWithoutTaskItem(){
		setupData(true);

		List<Application_Sign_Off_Scope__c> resultList;
		String errorString;

		Test.startTest();
			try{
				resultList = SignOffFilingChecklistServices.getSignOffFillingChecklistListByTaskItemId(null);
			} catch (Exception ex) {
				errorString = ex.getMessage();
			}

		Test.stopTest();

		System.assert(!String.isEmpty(errorString));
		System.assert(resultList == null);
	}
}