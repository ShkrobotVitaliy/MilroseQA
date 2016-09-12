@isTest
private class TestCreateBatchForReportsDayOutSail {
	private static CreateBatchForReportsDayOutSail testJob;

	private static void setupData (){
		TestingUtils.createGruopForFF();
		TestingUtils.createCodaCompany();
		TestingUtils.createCodaYear(false);
		TestingUtils.createCodaPeriod(false);

		List<c2g__codaYear__c> testCodaYearList = new List<c2g__codaYear__c>();

		c2g__codaYear__c yr= new c2g__codaYear__c();
		yr.Name = '2015';
		yr.c2g__AutomaticPeriodList__c =  true;
		yr.c2g__OwnerCompany__c = TestingUtils.company.id;
		yr.c2g__ExternalId__c = 'yzsd1234' + yr.Name;
		yr.c2g__NumberOfPeriods__c =11;
		yr.c2g__StartDate__c = Date.today().addYears(-4).addDays(10);
		yr.c2g__PeriodCalculationBasis__c = '445';
		yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
		yr.c2g__UnitOfWork__c = 12;
		yr.ownerid = TestingUtils.testGroup.Id;
		insert yr;

		List<c2g__codaPeriod__c> testCodaPeriodList = new List<c2g__codaPeriod__c>();

		c2g__codaPeriod__c prd000 = new c2g__codaPeriod__c();
		prd000.Name = yr.Name + '/000';
		prd000.c2g__ExternalId__c = yr.c2g__ExternalId__c + '000';
		prd000.c2g__StartDate__c = Date.today().addYears(-3);
		prd000.c2g__EndDate__c = Date.today().addYears(-3).addDays(9);
		prd000.c2g__OwnerCompany__c = TestingUtils.company.id;
		prd000.c2g__Description__c ='test Desc';
		prd000.c2g__PeriodGroup__c = 'Q1';
		prd000.c2g__PeriodNumber__c = '000';
		prd000.c2g__YearName__c = yr.id;
		testCodaPeriodList.add(prd000);

		c2g__codaPeriod__c prd001 = new c2g__codaPeriod__c();
		prd001.Name = yr.Name + '/001';
		prd001.c2g__ExternalId__c = yr.c2g__ExternalId__c + '001';
		prd001.c2g__StartDate__c = Date.today().addYears(-3).addDays(10);
		prd001.c2g__EndDate__c = Date.today().addYears(-2).addDays(9);
		prd001.c2g__OwnerCompany__c = TestingUtils.company.id;
		prd001.c2g__Description__c ='test Desc';
		prd001.c2g__PeriodGroup__c = 'Q1';
		prd001.c2g__PeriodNumber__c = '001';
		prd001.c2g__YearName__c = yr.id;
		testCodaPeriodList.add(prd001);

		c2g__codaPeriod__c prd002 = new c2g__codaPeriod__c();
		prd002.Name = yr.Name + '/002';
		prd002.c2g__ExternalId__c = yr.c2g__ExternalId__c + '002';
		prd002.c2g__StartDate__c = Date.today().addYears(-2).addDays(10);
		prd002.c2g__EndDate__c = Date.today().addYears(-1).addDays(9);
		prd002.c2g__OwnerCompany__c = TestingUtils.company.id;
		prd002.c2g__Description__c ='test Desc';
		prd002.c2g__PeriodGroup__c = 'Q1';
		prd002.c2g__PeriodNumber__c = '002';
		prd002.c2g__YearName__c = yr.id;
		testCodaPeriodList.add(prd002);

		c2g__codaPeriod__c prd003 = new c2g__codaPeriod__c();
		prd003.Name = yr.Name + '/003';
		prd003.c2g__ExternalId__c = yr.c2g__ExternalId__c + '003';
		prd003.c2g__StartDate__c = Date.today().addYears(-1).addDays(11);
		prd003.c2g__EndDate__c = Date.today().addDays(-12);
		prd003.c2g__OwnerCompany__c = TestingUtils.company.id;
		prd003.c2g__Description__c ='test Desc';
		prd003.c2g__PeriodGroup__c = 'Q1';
		prd003.c2g__PeriodNumber__c = '003';
		prd003.c2g__YearName__c = yr.id;
		testCodaPeriodList.add(prd003);

		c2g__codaPeriod__c prd004 = new c2g__codaPeriod__c();
		prd004.Name = yr.Name + '/004';
		prd004.c2g__ExternalId__c = yr.c2g__ExternalId__c + '004';
		prd004.c2g__StartDate__c = Date.today().addDays(-10);
		prd004.c2g__EndDate__c = Date.today().addDays(1);
		prd004.c2g__OwnerCompany__c = TestingUtils.company.id;
		prd004.c2g__Description__c ='test Desc';
		prd004.c2g__PeriodGroup__c = 'Q1';
		prd004.c2g__PeriodNumber__c = '004';
		prd004.c2g__YearName__c = yr.id;
		testCodaPeriodList.add(prd004);

		for (c2g__codaPeriod__c pr : testCodaPeriodList){
			pr.Accounts_Receivable_CY__c = 10;
			pr.Accounts_Receivable_PY__c = 10;
			pr.Accounts_Receivable_Month__c = 10;
			pr.Total_Billed_Amount_Numbers_Old_PY__c = 10;
			pr.Total_Billed_Amount_Numbers_Old__c = 10;
			pr.Total_Billed_Amount_Month__c = 10;
			pr.Day_Sales_Outstanding_CY__c = 10;
			pr.Day_Sales_Outstanding_PY__c = 10;
		}
		insert testCodaPeriodList;
		update testCodaPeriodList;
	}

	private static testmethod void testCreation(){
		setupData();

		Test.startTest();
			CreateBatchForReportsDayOutSail.futureExecution();
		Test.stopTest();
	}


	private static testmethod void testScheduleJob (){
		String jobExpretion = '0 0 0 3 9 ? 2022';
		String nextTimeJob = '2022-09-03 00:00:00';
		String jobId;

		testJob = new CreateBatchForReportsDayOutSail();

		Test.startTest();
				jobId = System.schedule('testScheduledApex', jobExpretion, testJob);
		Test.stopTest();

		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
		System.assertEquals(jobExpretion, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals(nextTimeJob, String.valueOf(ct.NextFireTime));
	}
}