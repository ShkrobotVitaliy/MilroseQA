@isTest
private class TestChangeOrderTrigger {
	
	@isTest static void TestChangeOrderTriggerMethodOne() {
		List<Change_Order__c> changeOrders = TestingUtils.createChangeOrderList(5, false);
		INSERT changeOrders;
		PreventTwiceExecution.changeOrderFirstRun = true;
		for(Change_Order__c cO : changeOrders) {
			cO.Status__c = 'Canceled';
		}
		UPDATE changeOrders;
		PreventTwiceExecution.changeOrderFirstRun = true;
		DELETE changeOrders;
	}
	
}