@isTest
private class TestCreateBatch1FullRecalculation {
	private static CreateBatch1FullRecalculation testBatch;

	private static testmethod void testCreation(){
		testBatch = new CreateBatch1FullRecalculation();
		System.assert(testBatch != null);

		Test.startTest();
			Database.executeBatch(testBatch);
		Test.stopTest();
	}


	private static testmethod void testScheduleJob (){
		String jobExpretion = '0 0 0 3 9 ? 2022';
		String nextTimeJob = '2022-09-03 00:00:00';
		String jobId;

		testBatch = new CreateBatch1FullRecalculation();

		Test.startTest();
			jobId = System.schedule('testScheduledApex', jobExpretion, testBatch);
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
		System.assertEquals(jobExpretion, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
	}
}