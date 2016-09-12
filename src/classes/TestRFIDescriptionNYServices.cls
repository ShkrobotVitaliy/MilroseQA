@isTest
private class TestRFIDescriptionNYServices {
	private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 5;

	private static List<RFI_Scope__c> testRFIScopeList;

	private static void setupData(){
		testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);
	}

	private static testmethod void testInsertRFIDescriptionForNYRegion(){
		setupData();

		Test.startTest();

			RFIDescriptionNYServices.insertRFIDescriptionForNYRegion(testRFIScopeList);

		Test.stopTest();
	}

	private static testmethod void testNyRegionFieldsQuery(){
		String resultString;

		Test.startTest();

			resultString = RFIDescriptionNYServices.nyRegionFieldsQuery();

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}
}