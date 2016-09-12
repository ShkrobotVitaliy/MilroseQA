@isTest
private class TestLegacyBillingItemWrapper {
	private static final Integer NUMBER_TO_CREATE = 5;
	private static List<Legacy_Billing_Item__c> testLegacyBillingItemList;
	private static LegacyBillingItemWrapper legBilItemWrap;
	
	private static void setUp(){
		testLegacyBillingItemList = TestingUtils.createLegacyBillingItemList(NUMBER_TO_CREATE, null, null, null, null, null, null, true);
	}
	
	
	private static testMethod void testLegacyBillingItemWrap(){
		setUp();
		
		Test.startTest();
			legBilItemWrap = new LegacyBillingItemWrapper(testLegacyBillingItemList[0]);
		Test.stopTest();

		System.assert(legBilItemWrap != null);

	}

	private static testMethod void testGetLegacyBillingItemWrapper(){
		setUp();
	
		Test.startTest();
			System.assert(! testLegacyBillingItemList.isEmpty() );

			List<LegacyBillingItemWrapper> wraps = 
				LegacyBillingItemWrapper.getLegacyBillingItemWrapper(testLegacyBillingItemList);

			System.assert(! wraps.isEmpty() );

		Test.stopTest();	

	}
	
	private static testMethod void testNullTests(){		
	
		Test.startTest();
			List<LegacyBillingItemWrapper> wraps =
				LegacyBillingItemWrapper.getLegacyBillingItemWrapper(new List<Legacy_Billing_Item__c>());

			LegacyBillingItemWrapper.updateLegacyBillingItemWrapper(new List<LegacyBillingItemWrapper>());

			List<Legacy_Billing_Item__c> items = 
				LegacyBillingItemWrapper.getSelectedBillingItemWrapper(new List<LegacyBillingItemWrapper>());	


			System.assert(wraps.isEmpty());
			System.assert(items.isEmpty());

		Test.stopTest();	
	}
	
	private static testMethod void testUpdateLegacyBillingItemWrapper(){
		setUp();
		List<LegacyBillingItemWrapper> getLegacyBillingItemWrapper = LegacyBillingItemWrapper.getLegacyBillingItemWrapper(testLegacyBillingItemList);
		
		Test.startTest();
			LegacyBillingItemWrapper.updateLegacyBillingItemWrapper(getLegacyBillingItemWrapper);
		Test.stopTest();

		System.assert(! getLegacyBillingItemWrapper.isEmpty() );
	}
	
	private static testMethod void testGetSelectedBillingItemWrapper(){
		setUp();
		List<LegacyBillingItemWrapper> getLegacyBillingItemWrapper = LegacyBillingItemWrapper.getLegacyBillingItemWrapper(testLegacyBillingItemList);
		
		Test.startTest();
			List<Legacy_Billing_Item__c> items = LegacyBillingItemWrapper.getSelectedBillingItemWrapper(getLegacyBillingItemWrapper);

			System.assert( items.isEmpty() );
		Test.stopTest();
	}
}