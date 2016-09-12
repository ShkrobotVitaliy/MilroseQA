@isTest
private class TestRFIDescriptionCTServices {
	private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 5;

	private static List<RFI_Scope__c> testRFIScopeList;

	private static void setupData(){
		testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);
	}

	private static testmethod void testInsertRFIDescriptionForCTRegion(){
		setupData();

		Test.startTest();

			RFIDescriptionCTServices.insertRFIDescriptionForCTRegion(testRFIScopeList);

		Test.stopTest();
	}

	private static testmethod void testCtRegionFieldsQuery(){
		String resultString;

		Test.startTest();

			resultString = RFIDescriptionCTServices.ctRegionFieldsQuery();

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}
}