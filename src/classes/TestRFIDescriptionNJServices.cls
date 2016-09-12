@isTest
private class TestRFIDescriptionNJServices {
	private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 5;

	private static List<RFI_Scope__c> testRFIScopeList;

	private static void setupData(){
		testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);
	}

	private static testmethod void testInsertRFIDescriptionForNJRegion(){
		setupData();

		Test.startTest();

			RFIDescriptionNJServices.insertRFIDescriptionForNJRegion(testRFIScopeList);

		Test.stopTest();
	}

	private static testmethod void testNJRegionFieldsQuery(){
		String resultString;

		Test.startTest();

			resultString = RFIDescriptionNJServices.njRegionFieldsQuery();

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}
}