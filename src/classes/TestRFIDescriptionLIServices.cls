@isTest
private class TestRFIDescriptionLIServices {
	private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 5;

	private static List<RFI_Scope__c> testRFIScopeList;

	private static void setupData(){
		testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);
	}

	private static testmethod void testInsertRFIDescriptionForLIRegion(){
		setupData();

		Test.startTest();

			RFIDescriptionLIServices.insertRFIDescriptionForLIRegion(testRFIScopeList);

		Test.stopTest();
	}

	private static testmethod void testLiRegionFieldsQuery(){
		String resultString;

		Test.startTest();

			resultString = RFIDescriptionLIServices.liRegionFieldsQuery();

		Test.stopTest();

		System.assert(!String.isEmpty(resultString));
	}
}