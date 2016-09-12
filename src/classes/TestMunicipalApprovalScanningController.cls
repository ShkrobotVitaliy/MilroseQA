@isTest
private class TestMunicipalApprovalScanningController {
	
	private static ApexPages.StandardController testController;

	@isTest static void test_method_one() {
		Task_Item__c taskItem = TestingUtils.createTaskItemList(1, false)[0];
		INSERT taskItem;
		testController = new ApexPages.StandardController( taskItem );
		MunicipalApprovalScanningController municApprScannContr = new MunicipalApprovalScanningController( testController );
		String retURL = municApprScannContr.retURL;
	}
	
}