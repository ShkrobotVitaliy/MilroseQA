@isTest
private class TestManageScheduledJobsController {
	private static ManageScheduledJobsController testController;

	private static testmethod void testInitController (){
		Test.startTest();

			testController = new ManageScheduledJobsController();
			testController.scheduleJobs();
			ManageScheduledJobsController.scheduleJobsFuture();
			testController.cancelJobs();
			testController.cloneHistory();
			testController.clearHistory();
			Boolean testBool;
			testBool = testController.noSchedullableInHistoryMsg == null;
			testBool = testController.noScheduledJobsMsg == null;
			testBool = testController.hasScheduledJobs == null;
			testBool = testController.hasScheduledJobsHistory == null;
			testController.selectExisting();
			testController.selectHistory();

		Test.stopTest();
	}
}