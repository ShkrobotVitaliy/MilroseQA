@isTest
private class TestScheduledBillingJobController {
    private static PageReference testPage;
    private static ScheduledBillingJobController testController;
    private static void setupData (){
        insert new DDP_Helper__c( Type__c = DDPHelperServices.TYPE_BILLING_JOB_SUPPORT );    
    }

    private static void preparePageController (){
        testPage = Page.ScheduledBillingJob;
        Test.setCurrentPage(testPage);
        testController = new ScheduledBillingJobController();
    }

    private static testmethod void testCreatePage (){
        setupData();
        Test.startTest();
            preparePageController();
            List<ScheduledBillingJobController.CronTriggerWrapper> test1 =  testController.billingJob;
            testController.getBillingJob();
            String test2 =  testController.dateTim;
            List<SelectOption> test3 =  testController.getdateTimOptions();
            String  test4 =  testController.dayInMonth;
            List<SelectOption> test5 =  testController.getdayInMonthOptions();
            String test6 =  testController.dayOfWeekInMonth;
            List<SelectOption> test7 =  testController.getdayOfWeekInMonthOptions();
            String test8 =  testController.dayInWeek;
            List<SelectOption> test9 =  testController.getdayInWeekOptions();
            testController.isWeekly = false;
            testController.WeeklyPanel();
            testController.MonthlyPanel();
            testController.isOnDateInMonth = false;
            testController.onDayOfEveryMonth();
            testController.onOfEveryMonth();

            if (!testController.billingJob.isEmpty()){
                testController.abortJob();
            }
            testController.startJob();

            ScheduledBillingJobController.CronTriggerWrapper bJ = testController.billingJob.get(0);
            String getJobName = bJ.getJobName();
            String getCronExpression = bJ.getCronExpression();
            String getStartTime = bJ.getStartTime();
            String getPreviousFireTime = bJ.getPreviousFireTime();
            String getNextFireTime = bJ.getNextFireTime();

            //PageReference startJob = testController.startJob();
            PageReference scheduleJob = testController.scheduleJob();
            String message = testController.message;
            PageReference applyChanges = testController.applyChanges();
            String dateTimES = testController.dateTimES;
            Boolean isOnDayInMonthES = testController.isOnDayInMonthES;
            Boolean isOnDateInMonthES = testController.isOnDateInMonthES;
            PageReference onDayOfEveryMonthES = testController.onDayOfEveryMonthES();
            PageReference onOfEveryMonthES = testController.onOfEveryMonthES();
            List<SelectOption> getdateTimESOptions = testController.getdateTimESOptions();
            String dayInMonthES = testController.dayInMonthES;
            List<SelectOption> getdayInMonthESOptions = testController.getdayInMonthESOptions();
            String dayOfWeekInMonthES = testController.dayOfWeekInMonthES;
            List<SelectOption> getdayOfWeekInMonthESOptions = testController.getdayOfWeekInMonthESOptions();
            String dayInWeekES = testController.dayInWeekES;
            List<SelectOption> getdayInWeekESOptions = testController.getdayInWeekESOptions();

            testController.ddpHelper.Automatically_Email_Statements__c = false;
            PageReference startJobEmailStatements = testController.startJobEmailStatements();
            testController.ddpHelper.Automatically_Email_Statements__c = true;
            startJobEmailStatements = testController.startJobEmailStatements();
            
            PageReference getCronTabES = testController.getCronTabES();
            PageReference applyChangesES = testController.applyChangesES();
            PageReference applyChangesUsersES = testController.applyChangesUsersES();

            if (!testController.billingJob.isEmpty()){
                testController.abortJob();
            }

            /*testController.startJob();
            testController.abortJob();
            testController.startJob();
            testController.abortJob();
            testController.scheduleJob();
            testController.getCronTab();*/
        Test.stopTest();
    }
    
}