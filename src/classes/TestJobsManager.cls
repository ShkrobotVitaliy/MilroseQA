@isTest
private class TestJobsManager{

    // Tests for SchedulableJobServices class
    /*static final String TEST_JOB_NAME = 'Test Job Name';
    static final String TEST_CRON_EXP = '0 0 0 ? * 1';
    static final String TESTED_SCHEDULABLE_CLASS_NAME = 'Dummy_Schedulable_Job_For_Test';
    
    static ApexClass testedSchedulableClass {
        get {
            if ( testedSchedulableClass == null )
                testedSchedulableClass = [ SELECT Id, Name, NamespacePrefix FROM ApexClass WHERE Name = :TESTED_SCHEDULABLE_CLASS_NAME ];
            return testedSchedulableClass;
            
        }
        set;
    }

    static String testedSchedulableClassPrefix {
        get {
            return testedSchedulableClass.NamespacePrefix == null ? 'null' : testedSchedulableClass.NamespacePrefix;
        }
        set;
    }

    static String testedSchedulableClassFullName {
        get {
            return ( testedSchedulableClass.NamespacePrefix == null ? '' : testedSchedulableClass.NamespacePrefix + '.' ) + testedSchedulableClass.Name;
        }
        set;
    }
    
    private static Id safeSchedule() {
        Integer start = System.Now().second();
        while( System.Now().second() == start ) {
        }
        return System.schedule( TEST_JOB_NAME, TEST_CRON_EXP, new Dummy_Schedulable_Job_For_Test() );
    }
    
    */private static testmethod void testRetrieveCurrentScheduledJobs() {
        /*Id testCronTriggerId = safeSchedule();
        DateTime testCreatedDate = [ select CreatedDate from CronTrigger where Id = :testCronTriggerId].CreatedDate;//DateTime.now();
        //Id testAsyncApexJobId = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ][0].Id;

        List<AsyncApexJob> allAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' ];
        List<AsyncApexJob> curAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ];
        System.assertEquals( allAAJ.size(), curAAJ.size() );

        List<SchedulableJobModel> currentSchedulesJobsModels;
        Test.startTest();
            currentSchedulesJobsModels = SchedulableJobServices.retrieveCurrentScheduledJobs();
        Test.stopTest();
        System.assertNotEquals( null, currentSchedulesJobsModels );
        System.assertEquals( 1, currentSchedulesJobsModels.size() );
        
        Schedulable_Job__c testedJob = currentSchedulesJobsModels[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( testCreatedDate, testedJob.CreatedDate__c );
        System.assertEquals( testCronTriggerId, testedJob.CronTriggerId__c );
        //System.assertEquals( testAsyncApexJobId, testedJob.AsyncApexJobId__c );
        System.assertEquals( true, testedJob.Active__c );
        System.assertEquals( 'RETRIEVED', testedJob.Status__c );*/
    }
    
    /*private static testmethod void testSecondRetrieveCurrentScheduledJobs() {
        List<CronTrigger> cronTriggers = [ SELECT c.Id, c.CreatedDate, c.CronExpression, c.CronJobDetail.Name FROM CronTrigger c WHERE c.CronJobDetail.JobType = '7' AND CronExpression != 'SimpleTrigger'];
        for ( CronTrigger ct : cronTriggers ) {
            System.abortJob( ct.Id );
        }
        Id testCronTriggerId = safeSchedule();
        DateTime testCreatedDate = [ select CreatedDate from CronTrigger where Id = :testCronTriggerId].CreatedDate;
        
        List<AsyncApexJob> allAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' ];
        List<AsyncApexJob> curAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ];
        System.assertEquals( allAAJ.size(), curAAJ.size() );
        //Id testAsyncApexJobId = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ][0].Id;
        insert SchedulableJobServices.retrieveJobsListFromModelList( SchedulableJobServices.retrieveCurrentScheduledJobs() );
        
        List<SchedulableJobModel> currentSchedulesJobsModels;
        Test.startTest();
            currentSchedulesJobsModels = SchedulableJobServices.retrieveCurrentScheduledJobs();
        Test.stopTest();
        System.assertNotEquals( null, currentSchedulesJobsModels );
        System.assertEquals( 1, currentSchedulesJobsModels.size() );
        
        Schedulable_Job__c testedJob = currentSchedulesJobsModels[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( testCreatedDate, testedJob.CreatedDate__c );
        System.assertEquals( testCronTriggerId, testedJob.CronTriggerId__c );
        //System.assertEquals( testAsyncApexJobId, testedJob.AsyncApexJobId__c );
        System.assertEquals( true, testedJob.Active__c );
        System.assertEquals( 'RETRIEVED', testedJob.Status__c );
    }
    
    private static testmethod void testRetrieveScheduledJobsHistory() {
        insert new Schedulable_Job__c(Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        
        List<SchedulableJobModel> scheduledJobsHistoryModels;
        Test.startTest();
            scheduledJobsHistoryModels = SchedulableJobServices.retrieveScheduledJobsHistory();
        Test.stopTest();
        System.assertNotEquals( null, scheduledJobsHistoryModels );
        System.assertEquals( 1, scheduledJobsHistoryModels.size() );
        
        Schedulable_Job__c testedJob = scheduledJobsHistoryModels[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.CompleteApexClassName__c );
        System.assertEquals( false, testedJob.Active__c );
        System.assertEquals( 'CANCELED', testedJob.Status__c );
    }
    
    private static testmethod void testFilterSelectedJobModelList() {
        insert new Schedulable_Job__c(Name = 'First', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        insert new Schedulable_Job__c(Name = 'Second', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        List<SchedulableJobModel> testedSchedulableJobModels = SchedulableJobServices.retrieveScheduledJobsHistory();
        testedSchedulableJobModels[0].isSelected = true;
        Test.startTest();
            List<SchedulableJobModel> filteredModels = SchedulableJobServices.filterSelectedJobModelList( testedSchedulableJobModels );
        Test.stopTest();
        System.assertEquals( 1, filteredModels.size() );
        System.assertEquals( true, filteredModels[0].isSelected );
        System.assertEquals( 'First', filteredModels[0].record.Name );
    }
    
    private static testmethod void testRetrieveJobsListFromModelList() {
        insert new Schedulable_Job__c(Name = 'First', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        insert new Schedulable_Job__c(Name = 'Second', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        List<SchedulableJobModel> testedSchedulableJobModels = SchedulableJobServices.retrieveScheduledJobsHistory();
        Test.startTest();
            List<Schedulable_Job__c> jobs = SchedulableJobServices.retrieveJobsListFromModelList( testedSchedulableJobModels );
        Test.stopTest();
        System.assertEquals( 2, jobs.size() );
        System.assertEquals( 'First', jobs[0].Name );
        System.assertEquals( 'Second', jobs[1].Name );
    }
    
    private static testmethod void testRetrieveJobsNamesStringFromModelList() {
        insert new Schedulable_Job__c(Name = 'First', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        insert new Schedulable_Job__c(Name = 'Second', CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'CANCELED');
        List<SchedulableJobModel> testedSchedulableJobModels = SchedulableJobServices.retrieveScheduledJobsHistory();
        String jobsNames;
        Test.startTest();
            jobsNames = SchedulableJobServices.retrieveJobsNamesStringFromModelList( testedSchedulableJobModels );
        Test.stopTest();
        System.assertEquals( 'First; Second; ', jobsNames );
    }

    // Tests for ManageScheduledJobsController class

    private static testmethod void testDefaultControllerProperties() {
        ManageScheduledJobsController controller;
        Test.startTest();
            controller = new ManageScheduledJobsController();
        Test.stopTest();
        System.assertEquals( false, controller.hasScheduledJobs );
        System.assertEquals( false, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 0, controller.existingScheduledJobs.size() );
        System.assertEquals( 0, controller.scheduledJobsHistory.size() );
        System.assertEquals( 'No Schedulable Job is scheduled!', ManageScheduledJobsController.NO_SCHEDULED_JOBS );
        System.assertEquals( 'No Schedulable Job was scheduled or canceled using this page!', ManageScheduledJobsController.NO_SCHEDULABLE_JOBS_IN_HISTORY );
        System.assertEquals( 'No Schedulable Job is scheduled!', controller.noScheduledJobsMsg );
        System.assertEquals( 'No Schedulable Job was scheduled or canceled using this page!', controller.noSchedullableInHistoryMsg );
    }
    
    private static testmethod void testExistingScheduledJobs() {
        Id testCronTriggerId = safeSchedule();
        DateTime testCreatedDate = DateTime.now();
        //Id testAsyncApexJobId = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ][0].Id;

        
        ManageScheduledJobsController controller;
        Test.startTest();
            controller = new ManageScheduledJobsController();
        Test.stopTest();
        System.assertEquals( true, controller.hasScheduledJobs );
        System.assertEquals( false, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 1, controller.existingScheduledJobs.size() );
        System.assertEquals( 0, controller.scheduledJobsHistory.size() );
        
        Schedulable_Job__c testedJob = controller.existingScheduledJobs[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( testCreatedDate, testedJob.CreatedDate__c );
        System.assertEquals( testCronTriggerId, testedJob.CronTriggerId__c );
        //System.assertEquals( testAsyncApexJobId, testedJob.AsyncApexJobId__c );
        System.assertEquals( true, testedJob.Active__c );
        System.assertEquals( 'RETRIEVED', testedJob.Status__c );
    }
    
    private static testmethod void testCancelJobs() {
        Id testCronTriggerId = safeSchedule();
        DateTime testCreatedDate = [ select CreatedDate from CronTrigger where Id = :testCronTriggerId].CreatedDate;//DateTime.now();DateTime.now();
        //Id testAsyncApexJobId = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ][0].Id;

        
        ManageScheduledJobsController controller = new ManageScheduledJobsController();
        controller.selectAllExisting = true;
        controller.selectExisting();
        Test.startTest();
            controller.cancelJobs();
        Test.stopTest();
        System.assertEquals( false, controller.hasScheduledJobs );
        System.assertEquals( true, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 0, controller.existingScheduledJobs.size() );
        System.assertEquals( 1, controller.scheduledJobsHistory.size() );
        
        Schedulable_Job__c testedJob = controller.scheduledJobsHistory[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( testCreatedDate, testedJob.CreatedDate__c );
        System.assertEquals( testCronTriggerId, testedJob.CronTriggerId__c );
        //System.assertEquals( testAsyncApexJobId, testedJob.AsyncApexJobId__c );
        System.assertEquals( false, testedJob.Active__c );
        System.assertEquals( 'CANCELED', testedJob.Status__c );
    }
    
    private static ManageScheduledJobsController prepareHistoryForTest() {
        safeSchedule();
        
        ManageScheduledJobsController controller = new ManageScheduledJobsController();

        controller.selectAllExisting = true;
        controller.selectExisting();

        controller.cancelJobs();

        controller.selectAllHistory = true;
        controller.selectHistory();
        return controller;
    }
    
    private static testmethod void testScheduleJobs() {
        ManageScheduledJobsController controller = prepareHistoryForTest();
        Test.startTest();
            controller.scheduleJobs();
        Test.stopTest();
        DateTime testCreatedDate = DateTime.now();
        //Id testAsyncApexJobId = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ][0].Id;
        Id testCronTriggerId = [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name FROM CronTrigger c WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name = :TEST_JOB_NAME AND CronExpression = :TEST_CRON_EXP AND CreatedDate = :testCreatedDate ][0].Id;
        System.assertEquals( true, controller.hasScheduledJobs );
        System.assertEquals( false, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 1, controller.existingScheduledJobs.size() );
        System.assertEquals( 0, controller.scheduledJobsHistory.size() );
        
        Schedulable_Job__c testedJob = controller.existingScheduledJobs[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( testCreatedDate, testedJob.CreatedDate__c );
        System.assertEquals( testCronTriggerId, testedJob.CronTriggerId__c );
        //System.assertEquals( testAsyncApexJobId, testedJob.AsyncApexJobId__c );
        System.assertEquals( true, testedJob.Active__c );
        System.assertEquals( 'SCHEDULED', testedJob.Status__c );
    }
    
    private static testmethod void testScheduleJobsFuture() {
        insert new Schedulable_Job__c(Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'TO BE SCHEDULED');
        Test.startTest();
            ManageScheduledJobsController.scheduleJobsFuture();
        Test.stopTest();
        DateTime testCreatedDate = DateTime.now();
        //List<AsyncApexJob> asyncApexJobList = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ];
        
        List<CronTrigger> cronTriggerList = [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name FROM CronTrigger c WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name = :TEST_JOB_NAME AND CronExpression = :TEST_CRON_EXP AND CreatedDate = :DateTime.now() ];
        System.assertEquals( 1, cronTriggerList.size(), 'Correspondent Cron Trigger should have been created' );
        System.assertEquals( 'SCHEDULED', [select Status__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].Status__c, 'Batch should change status to SCHEDULED' );
        //System.assertEquals( asyncApexJobList[0].Id, [select AsyncApexJobId__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].AsyncApexJobId__c, 'Batch should update value of AsyncApexJobId__c to Id of corresponding AsyncApexJob object' );
        System.assertEquals( cronTriggerList[0].CreatedDate, [select CreatedDate__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].CreatedDate__c, 'Batch should change CreatedDate__c to CreatedDate of CronTrigger object' );
        System.assertEquals( cronTriggerList[0].Id, [select CronTriggerId__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].CronTriggerId__c, 'Batch should update value of CronTrigger__c to Id of corresponding CronTrigger object' );
    }
    
    private static testmethod void testClearHistory() {
        ManageScheduledJobsController controller = prepareHistoryForTest();
        Test.startTest();
            controller.clearHistory();
        Test.stopTest();
        System.assertEquals( false, controller.hasScheduledJobs );
        System.assertEquals( false, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 0, controller.existingScheduledJobs.size() );
        System.assertEquals( 0, controller.scheduledJobsHistory.size() );
    }

    private static testmethod void testCloneHistory() {
        ManageScheduledJobsController controller = prepareHistoryForTest();
        Test.startTest();
            controller.cloneHistory();
        Test.stopTest();
        System.assertEquals( false, controller.hasScheduledJobs );
        System.assertEquals( true, controller.hasScheduledJobsHistory );
        System.assertNotEquals( null, controller.existingScheduledJobs );
        System.assertNotEquals( null, controller.scheduledJobsHistory );
        System.assertEquals( 0, controller.existingScheduledJobs.size() );
        System.assertEquals( 2, controller.scheduledJobsHistory.size() );
        Schedulable_Job__c testedJob = controller.scheduledJobsHistory[0].record;
        System.assertEquals( TEST_JOB_NAME, testedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedJob.CompleteApexClassName__c );
        System.assertEquals( false, testedJob.Active__c );
        System.assertEquals( 'CANCELED', testedJob.Status__c );
        Schedulable_Job__c testedClonedJob = controller.scheduledJobsHistory[1].record;
        System.assertEquals( TEST_JOB_NAME + '_copy', testedClonedJob.Name );
        System.assertEquals( TEST_CRON_EXP, testedClonedJob.CronExpression__c );
        System.assertEquals( testedSchedulableClass.Id, testedClonedJob.ApexClassId__c );
        System.assertEquals( testedSchedulableClassPrefix, testedClonedJob.NamespacePrefix__c );
        System.assertEquals( 'Dummy_Schedulable_Job_For_Test', testedClonedJob.ApexClassName__c );
        System.assertEquals( testedSchedulableClassFullName, testedClonedJob.CompleteApexClassName__c );
        System.assertEquals( false, testedClonedJob.Active__c );
        System.assertEquals( 'CANCELED', testedClonedJob.Status__c );
    }    

    // Tests for Scheduler_Batch

    private static testmethod void testDatabaseExecuteBatch() {
        insert new Schedulable_Job__c(Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'TO BE SCHEDULED');
        Test.startTest();
            Database.executeBatch(new Scheduler_Batch(), 1);
        Test.stopTest();
        List<CronTrigger> cronTriggerList = [ SELECT Id, CreatedDate, CronExpression, CronJobDetail.Name
                                              FROM CronTrigger c
                                              WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name = :TEST_JOB_NAME AND CronExpression = :TEST_CRON_EXP AND CreatedDate = :DateTime.now() ];
        //System.assertEquals( 1, cronTriggerList.size(), 'Correspondent Cron Trigger should have been created' );
        //System.assertEquals( 'SCHEDULING...', [select Status__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].Status__c, 'Batch should change status to SCHEDULING...' );
        //System.assertEquals( cronTriggerList[0].CreatedDate, [select CreatedDate__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].CreatedDate__c, 'Batch should change CreatedDate__c to CreatedDate of CronTrigger object' );
        //System.assertEquals( cronTriggerList[0].Id, [select CronTriggerId__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].CronTriggerId__c, 'Batch should update value of CronTrigger__c to Id of corresponding CronTrigger object' );
    }
    
    private static testmethod void testSystemScheduleBatch() {
        List<Schedulable_Job__c> jobsList = new List<Schedulable_Job__c>();
        jobsList.add( new Schedulable_Job__c( Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP,  CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'TO BE SCHEDULED' ) );
        jobsList.add( new Schedulable_Job__c( Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP,  CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'TO BE SCHEDULED' ) );
        insert jobsList;
        Test.startTest();
            System.scheduleBatch( new Scheduler_Batch(), 'test Scheduler batch', 0, 1 );
        Test.stopTest();
        List<CronTrigger> cts = [ SELECT c.CronJobDetail.JobType, c.CronJobDetail.Name, c.TimesTriggered, c.TimeZoneSidKey, c.State, c.StartTime, c.PreviousFireTime, c.OwnerId, c.NextFireTime, c.LastModifiedById, c.Id, c.EndTime, c.CronExpression, c.CreatedDate, c.CreatedById 
                                  FROM CronTrigger c 
                                  WHERE c.CronJobDetail.Name = 'test Scheduler batch' ] ;
        System.assertEquals( 1, cts.size() );
        System.assertEquals( '7', cts[0].CronJobDetail.JobType );
        System.assertEquals( 'SimpleTrigger', cts[0].CronExpression );
        System.assertEquals( 'WAITING', cts[0].State );
    }

    // Tests for Updater_Batch

    private static testmethod void testTestUpdater_Batch() {
        safeSchedule();
        DateTime testCreatedDate = DateTime.now();
        insert new Schedulable_Job__c( CreatedDate__c = testCreatedDate, Name = TEST_JOB_NAME, CronExpression__c = TEST_CRON_EXP, CompleteApexClassName__c = 'Dummy_Schedulable_Job_For_Test', Status__c = 'SCHEDULING...' );
        //List<AsyncApexJob> asyncApexJobList = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ];
        //System.debug(LoggingLevel.ERROR, 'asyncApexJobList : ' + asyncApexJobList );

        List<AsyncApexJob> allAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' ];
        List<AsyncApexJob> curAAJ = [ SELECT Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate = :testCreatedDate ];
        System.assertEquals( allAAJ.size(), curAAJ.size() );

        Test.startTest();
            Database.executeBatch(new Updater_Batch(), 1);
        Test.stopTest();
        
        
        System.assertEquals( 'SCHEDULED', [select Status__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].Status__c, 'Batch should change status to SCHEDULED' );
        //System.assertEquals( asyncApexJobList[0].Id, [select AsyncApexJobId__c from Schedulable_Job__c where Name = :TEST_JOB_NAME][0].AsyncApexJobId__c, 'Batch should update value of AsyncApexJobId__c to Id of corresponding AsyncApexJob object' );
        
    }

    // Tests for SchedulableJobModel

    private static testmethod void testSchedulableJobModelConstructor() {
        Schedulable_Job__c testJob = new Schedulable_Job__c();
        SchedulableJobModel sjm;
        Test.startTest();
            sjm = new SchedulableJobModel( testJob );
        Test.stopTest();
        System.assertEquals( false, sjm.isSelected, 'Job Model should not be selected by default' );
        System.assertEquals( testJob, sjm.record, 'Job Model record should match to passed value' );
    }
    
    private static testmethod void testSchedulableJobModelConstructorPassNull() {
        SchedulableJobModel sjm;
        Test.startTest();
            sjm = new SchedulableJobModel( null );
        Test.stopTest();
        System.assertEquals( false, sjm.isSelected, 'Job Model should not be selected by default' );
        System.assertNotEquals( null, sjm.record, 'Even if we pass null Job Model record should not be null' );
    }*/
}