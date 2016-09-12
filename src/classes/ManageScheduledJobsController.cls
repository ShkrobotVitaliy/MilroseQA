public class ManageScheduledJobsController{

    public static final string NO_SCHEDULED_JOBS = 'No Schedulable Job is scheduled!';
    public static final string NO_SCHEDULABLE_JOBS_IN_HISTORY = 'No Schedulable Job was scheduled or canceled using this page!';
    public Boolean firstTime = true;

    public String noSchedullableInHistoryMsg {
        get {
            return NO_SCHEDULABLE_JOBS_IN_HISTORY;
        }
        set;
    }

    public String noScheduledJobsMsg {
        get {
            return NO_SCHEDULED_JOBS;
        }
        set;
    }

    public PageReference scheduleJobs() {
        selectAllExisting = false;
        selectAllHistory = false;

        List<SchedulableJobModel> filteredJobs = SchedulableJobServices.filterSelectedJobModelList( scheduledJobsHistory );

        Map<String, SchedulableJobModel> nameToExistingJobMap = new Map<String, SchedulableJobModel>();
        for ( SchedulableJobModel sjm: SchedulableJobServices.retrieveCurrentScheduledJobs() ) {
            nameToExistingJobMap.put( sjm.record.Name, sjm );
        }

        Map<String, SchedulableJobModel> nameToNewJobMap = new Map<String, SchedulableJobModel>();
        List<SchedulableJobModel> jobsWithConflictingNames = new List<SchedulableJobModel>();
        List<SchedulableJobModel> jobsWithConflictingNames2 = new List<SchedulableJobModel>();
        List<SchedulableJobModel> jobsWithConflictingTimeZone = new List<SchedulableJobModel>();
        List<SchedulableJobModel> complaintJobsList = new List<SchedulableJobModel>();
        String userTimeZone;
        for ( SchedulableJobModel sjm: filteredJobs ) {
            if ( nameToExistingJobMap.get( sjm.record.Name ) != null ) {
                jobsWithConflictingNames.add( sjm );
            } else if ( nameToNewJobMap.get( sjm.record.Name ) != null ) {
                jobsWithConflictingNames2.add( sjm );
            } else {
                if ( firstTime ) {
                    userTimeZone = UserInfo.getTimeZone().getID();
                    if ( userTimeZone != sjm.record.TimeZoneSidKey__c ) {
                        jobsWithConflictingTimeZone.add( sjm );
                        continue;
                    }
                }
                nameToNewJobMap.put( sjm.record.Name, sjm );
                complaintJobsList.add( sjm );
            }
        }
        firstTime = false;

        if ( complaintJobsList.size() < 10 ) {
            scheduleJobsInline( complaintJobsList );
        } else if ( complaintJobsList.size() < 30 ) {
            for ( SchedulableJobModel job : complaintJobsList ) {
                job.record.Status__c = 'TO BE SCHEDULED';
            }
            update SchedulableJobServices.retrieveJobsListFromModelList( complaintJobsList );

            scheduleJobsFuture( );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'You have selected more than ten jobs to schedule; please wait a minute and refresh page' ) );

        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, 'You have selected more than thirty jobs to schedule; please wait a couple of minutes and refresh page' ) );
            for ( SchedulableJobModel job : complaintJobsList ) {
                job.record.Status__c = 'TO BE SCHEDULED';
            }
            update SchedulableJobServices.retrieveJobsListFromModelList( complaintJobsList );
            Scheduler_Batch batch = new Scheduler_Batch();
            System.scheduleBatch( batch, 'Scheduler batch', 0, 1 );
        }



        if ( jobsWithConflictingTimeZone.size() > 0 ) {
            String msg = 'One or more schedulable jobs (' + SchedulableJobServices.retrieveJobsNamesStringFromModelList( jobsWithConflictingTimeZone ) + ') were originally scheduled in different time zone. Please change your timezone to schedule these jobs.';
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, msg ) );
        }
        if ( jobsWithConflictingNames.size() + jobsWithConflictingNames2.size() > 0 ) {
            String msg = 'Some jobs cannot be scheduled ';
            if ( jobsWithConflictingNames.size() > 0 ) {
                    msg += 'because their names are conflicting to already scheduled jobs (' + SchedulableJobServices.retrieveJobsNamesStringFromModelList( jobsWithConflictingNames ) + ')';
            }
            if ( jobsWithConflictingNames.size() * jobsWithConflictingNames2.size() > 0 ) {
                    msg += ' or ';
            }
            if ( jobsWithConflictingNames2.size() > 0 ) {
                msg += 'because their names are conflicting to other selected jobs to schedule (' + SchedulableJobServices.retrieveJobsNamesStringFromModelList( jobsWithConflictingNames2 ) + ')';
            }
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.WARNING, msg ) );
        }
        return null;
    }

    public void scheduleJobsInline(List<SchedulableJobModel> jobsList) {
        Map<Id, CronTrigger> chunkedIdToFull = new Map<Id, CronTrigger>();
        Map<Datetime, AsyncApexJob> createdDateToAsyncApexJob = new Map<Datetime, AsyncApexJob>();

        Integer start = System.Now().second();
        for ( SchedulableJobModel sjm: jobsList ) {
            sjm.record.Active__c = true;
            sjm.isSelected = false;
            Type t = Type.forName( sjm.record.CompleteApexClassName__c );

            Schedulable so = (Schedulable) t.newInstance();
            
            while( System.Now().second() == start ) {
            }
            
            sjm.record.CronTriggerId__c = System.schedule( sjm.record.Name, sjm.record.CronExpression__c, so );
            
            start = System.Now().second();

            chunkedIdToFull.put( sjm.record.CronTriggerId__c, null );
        }
        chunkedIdToFull = new Map<Id, CronTrigger>( [ SELECT Id, CreatedDate FROM CronTrigger WHERE Id IN :chunkedIdToFull.keySet() ] );

        List<DateTime> dates = new List<DateTime>();
        for ( CronTrigger j : chunkedIdToFull.values() ) {
            dates.add( j.CreatedDate );
        }

        /*for ( AsyncApexJob aj : [ SELECT CreatedDate, ApexClassId, Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND CreatedDate IN :dates] ) {
            createdDateToAsyncApexJob.put( aj.CreatedDate, aj );
        }

        AsyncApexJob newAj;*/

        for ( SchedulableJobModel job : jobsList ) {
            job.record.CronTriggerId__c = chunkedIdToFull.get( job.record.CronTriggerId__c ).Id;
            //newAj = createdDateToAsyncApexJob.get( chunkedIdToFull.get( job.record.CronTriggerId__c ).CreatedDate );
            job.record.CreatedDate__c = chunkedIdToFull.get( job.record.CronTriggerId__c ).CreatedDate;
            //job.record.AsyncApexJobId__c = newAj.Id;
            job.record.Status__c = 'SCHEDULED';
        }
        
        
        update SchedulableJobServices.retrieveJobsListFromModelList( jobsList );
        existingScheduledJobs.addAll( jobsList );
        scheduledJobsHistory = SchedulableJobServices.retrieveScheduledJobsHistory();
    }

    @future
    public static void scheduleJobsFuture() {
        Map<String, SchedulableJobModel> nameToExistingJobMap = new Map<String, SchedulableJobModel>();
        for ( SchedulableJobModel sjm: SchedulableJobServices.retrieveCurrentScheduledJobs() ) {
            nameToExistingJobMap.put( sjm.record.Name, sjm );
        }

        Map<String, SchedulableJobModel> nameToNewJobMap = new Map<String, SchedulableJobModel>();

        List<SchedulableJobModel> jobsList = SchedulableJobServices.prepareModelListFromJobsList( [ SELECT Name, CronExpression__c, ApexClassId__c,  NamespacePrefix__c,  ApexClassName__c,  CompleteApexClassName__c,  CreatedDate__c,  CronTriggerId__c,  AsyncApexJobId__c, Active__c FROM Schedulable_Job__c WHERE Active__c = false AND Status__c = 'TO BE SCHEDULED' ] );


        List<SchedulableJobModel> jobsWithConflictingNames = new List<SchedulableJobModel>();
        List<SchedulableJobModel> jobsWithConflictingNames2 = new List<SchedulableJobModel>();
        List<SchedulableJobModel> complaintJobsList = new List<SchedulableJobModel>();
        for ( SchedulableJobModel sjm: jobsList ) {
            if ( nameToExistingJobMap.get( sjm.record.Name ) != null ) {
                jobsWithConflictingNames.add( sjm );
            } else if ( nameToNewJobMap.get( sjm.record.Name ) != null ) {
                jobsWithConflictingNames2.add( sjm );
            } else {
                nameToNewJobMap.put( sjm.record.Name, sjm );
                complaintJobsList.add( sjm );
            }
        }
        jobsList = complaintJobsList;

        Map<Id, CronTrigger> chunkedIdToFull = new Map<Id, CronTrigger>();
        Map<Datetime, AsyncApexJob> createdDateToAsyncApexJob = new Map<Datetime, AsyncApexJob>();

        Integer start = System.Now().second();
        for ( SchedulableJobModel sjm: jobsList ) {
            sjm.record.Active__c = true;
            sjm.isSelected = false;
            Type t = Type.forName( sjm.record.CompleteApexClassName__c );

            Schedulable so = (Schedulable) t.newInstance();

            while( System.Now().second() == start ) {
            }

            sjm.record.CronTriggerId__c = System.schedule( sjm.record.Name, sjm.record.CronExpression__c, so );
            start = System.Now().second();

            chunkedIdToFull.put( sjm.record.CronTriggerId__c, null );
        }
        chunkedIdToFull = new Map<Id, CronTrigger>( [ SELECT Id, CreatedDate FROM CronTrigger WHERE Id IN :chunkedIdToFull.keySet() ] );

        List<DateTime> dates = new List<DateTime>();
        for ( CronTrigger j : chunkedIdToFull.values() ) {
            dates.add( j.CreatedDate );
        }

        for ( AsyncApexJob aj : [ SELECT CreatedDate, ApexClassId, Id FROM AsyncApexJob WHERE Status != 'Aborted' AND JobType = 'ScheduledApex' AND  CreatedDate IN :dates] ) {
            createdDateToAsyncApexJob.put( aj.CreatedDate, aj );
        }

        AsyncApexJob newAj;

        for ( SchedulableJobModel job : jobsList ) {
            job.record.CronTriggerId__c = chunkedIdToFull.get( job.record.CronTriggerId__c ).Id;
            newAj = createdDateToAsyncApexJob.get( chunkedIdToFull.get( job.record.CronTriggerId__c ).CreatedDate );
            job.record.CreatedDate__c = chunkedIdToFull.get( job.record.CronTriggerId__c ).CreatedDate;
            job.record.AsyncApexJobId__c = newAj.Id;
            job.record.Status__c = 'SCHEDULED';
        }


        update SchedulableJobServices.retrieveJobsListFromModelList( jobsList );
    }


    public PageReference cancelJobs() {
        selectAllExisting = false;
        selectAllHistory = false;
        Set<Id> ctIds = new Set<Id>();
        Set<Id> aajIds = new Set<Id>();
        for ( SchedulableJobModel sjm: existingScheduledJobs ) {
            if ( sjm.isSelected ) {
                sjm.record.Active__c = false;
                sjm.isSelected = false;
                scheduledJobsHistory.add(sjm);
                ctIds.add( sjm.record.CronTriggerId__c );
                aajIds.add( sjm.record.AsyncApexJobId__c );
                sjm.record.Status__c = 'CANCELED';
            }
        }
        upsert SchedulableJobServices.retrieveJobsListFromModelList( scheduledJobsHistory );

        List<CronTrigger> ctList = [ SELECT Id FROM CronTrigger WHERE Id IN :ctIds ];
        for ( CronTrigger ct: ctList) {
            System.abortJob( ct.Id );
        }
        existingScheduledJobs = SchedulableJobServices.retrieveCurrentScheduledJobs();

        return null;
    }

    public PageReference clearHistory() {
        selectAllExisting = false;
        selectAllHistory = false;
        List<SchedulableJobModel> jobsToDelete = SchedulableJobServices.filterSelectedJobModelList( scheduledJobsHistory );
        delete SchedulableJobServices.retrieveJobsListFromModelList( jobsToDelete );
        scheduledJobsHistory = SchedulableJobServices.retrieveScheduledJobsHistory();
        return null;
    }

    public PageReference cloneHistory() {
        selectAllExisting = false;
        selectAllHistory = false;
        List<SchedulableJobModel> jobsToClone = SchedulableJobServices.filterSelectedJobModelList( scheduledJobsHistory );
        for ( SchedulableJobModel job : jobsToClone ) {
            job.record.Name += '_copy';
            if (job.record.Name.length() > 80) {
                job.record.Name = job.record.Name.substring(0, 79);
            }
            job.record.Id = null;
        }
        insert SchedulableJobServices.retrieveJobsListFromModelList( jobsToClone );

        scheduledJobsHistory = SchedulableJobServices.retrieveScheduledJobsHistory();
        return null;
    }



    public Boolean selectAllExisting{get;set;}
    public Boolean selectAllHistory{get;set;}

    public List<SchedulableJobModel> existingScheduledJobs{get;set;}
    public List<SchedulableJobModel> scheduledJobsHistory{get;set;}


    public Boolean hasScheduledJobs{
        get {
            return existingScheduledJobs!=null && !existingScheduledJobs.isEmpty();
        }
        set;
    }

    public Boolean hasScheduledJobsHistory{
        get {
            return scheduledJobsHistory!=null && !scheduledJobsHistory.isEmpty();
        }
        set;
    }

    public ManageScheduledJobsController(){
        existingScheduledJobs = SchedulableJobServices.retrieveCurrentScheduledJobs();
        scheduledJobsHistory = SchedulableJobServices.retrieveScheduledJobsHistory();
    }

    public void selectExisting() {
        for (SchedulableJobModel sjm: existingScheduledJobs){
            sjm.isSelected = selectAllExisting;
        }
    }

    public void selectHistory() {
        for (SchedulableJobModel sjm: scheduledJobsHistory){
            sjm.isSelected = selectAllHistory;
        }
    }

}