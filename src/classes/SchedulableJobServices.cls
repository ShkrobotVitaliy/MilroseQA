global class SchedulableJobServices{

    public static List<SchedulableJobModel> retrieveCurrentScheduledJobs() {
        List<Schedulable_Job__c> currentSchedulesJobs = new List<Schedulable_Job__c>();
		List<Schedulable_Job__c> esj = new List<Schedulable_Job__c>();
		List<CronTrigger> newCronTriggerList = new List<CronTrigger>();
		List<CronTrigger> sj = new List<CronTrigger>();
		
		newCronTriggerList.addAll( findNewAndExistingScheduledJobs( sj, esj ) );

        if (newCronTriggerList.isEmpty()) {
            return prepareModelListFromJobsList( esj );
        }
        currentSchedulesJobs.addAll( esj );

        String s = '';
        List<DateTime> dates = new List<DateTime>();
        List<Id> IdList = new List<Id>();
        for ( CronTrigger j : newCronTriggerList ) {
            dates.add( j.CreatedDate );
        }
        List<AsyncApexJob> aj = [ SELECT a.Id, a.CreatedDate, a.ApexClassId FROM AsyncApexJob a WHERE a.CreatedDate IN :dates ];
        for ( AsyncApexJob j : aj ) {
            IdList.add( j.ApexClassId );
        }
        
        Map<Id, ApexClass> clsNames = new Map<Id, ApexClass>( [ SELECT Id, Name, NamespacePrefix FROM ApexClass WHERE Id in :IdList ] );
        
        currentSchedulesJobs.addall( crossReferenceCronTriggersWithAsyncApexJobs( sj, aj, clsNames ) );

        return prepareModelListFromJobsList( currentSchedulesJobs );
    }
    
    public static List<CronTrigger> findNewAndExistingScheduledJobs( List<CronTrigger> sj, List<Schedulable_Job__c> esj )
    {
        List<CronTrigger> newCronTriggerList = new List<CronTrigger>();
        
    	for(CronTrigger ct:  [ SELECT c.Id, c.TimeZoneSidKey, c.CreatedById, 
        						c.CreatedBy.Name, c.CreatedDate, 
        						c.CronExpression, c.CronJobDetail.Name 
        						FROM CronTrigger c 
        						WHERE c.CronJobDetail.JobType = '7' 
        						AND CronExpression != 'SimpleTrigger'] )
        sj.add( ct );
		
        List<Id> ctIdList = new List<Id>();

        for ( CronTrigger j : sj ) {
            ctIdList.add( j.Id );
        }
        
        for( Schedulable_Job__c scFound : [ SELECT Name, TimeZoneSidKey__c, TimeZoneOffset__c, Scheduler__r.Id, Scheduler__r.Name, 
        								Status__c, CronExpression__c, ApexClassId__c,  NamespacePrefix__c,  ApexClassName__c,  CompleteApexClassName__c,  
        								CreatedDate__c,  CronTriggerId__c,  AsyncApexJobId__c, Active__c 
        								FROM Schedulable_Job__c 
        								WHERE CronTriggerId__c 
        								IN :ctIdList 
        								AND Active__c = true ] )
        esj.add( scFound );
        
        Map<Id, Schedulable_Job__c> cronTriggerToSchedulableJobMap = new Map<Id, Schedulable_Job__c>();
        for ( Schedulable_Job__c j : esj ) {
            cronTriggerToSchedulableJobMap.put( j.CronTriggerId__c, j);
        }
        for ( CronTrigger j : sj ) {
            if (! cronTriggerToSchedulableJobMap.keySet().contains( j.Id ) ) {
                newCronTriggerList.add( j );
            }
        }
        
        return newCronTriggerList;
    }

	public static list<Schedulable_Job__c> crossReferenceCronTriggersWithAsyncApexJobs( List<CronTrigger> sj, List<AsyncApexJob> aj, Map<Id, ApexClass> clsNames )
	{
		list<Schedulable_Job__c> jobs = new List<Schedulable_Job__c>();
		
		String prefix, className, fullName;
        for ( CronTrigger j : sj ) {
            for ( AsyncApexJob a : aj ) {
                if ( a.CreatedDate == j.CreatedDate ) {
                    prefix = clsNames.get( a.ApexClassId ).NamespacePrefix;
                    className = clsNames.get( a.ApexClassId ).Name;
                    fullName = ( ( prefix != '' && prefix != null ) ? prefix + '.' : '') + className;


                    jobs.add( new Schedulable_Job__c(
                        Name = j.CronJobDetail.Name,
                        CronExpression__c = j.CronExpression,
                        ApexClassId__c = a.ApexClassId,
                        NamespacePrefix__c = ( prefix != null ) ? prefix : 'null',
                        ApexClassName__c = className,
                        CompleteApexClassName__c = fullName,
                        CreatedDate__c = j.CreatedDate,
                        CronTriggerId__c = j.Id,
                        AsyncApexJobId__c = a.Id,
                        Active__c = true,
                        TimeZoneSidKey__c = j.TimeZoneSidKey,
                        TimeZoneOffset__c = TimeZone.getTimeZone( j.TimeZoneSidKey ).getOffset( DateTime.now() ) / 3600000,
                        Scheduler__c = j.CreatedById,
                        Scheduler__r = j.CreatedBy,
                        Status__c = 'RETRIEVED'
                    ) );
                    break;
                }
            }
        }
        
        return jobs;
	}

    public static List<SchedulableJobModel> prepareModelListFromJobsList( List<Schedulable_Job__c> jobsList) {
        List<SchedulableJobModel> result = new List<SchedulableJobModel>();
        for ( Schedulable_Job__c job: jobsList ) {
            result.add( new SchedulableJobModel( job ) );
        }
        return result;
    }

    public static List<SchedulableJobModel> filterSelectedJobModelList( List<SchedulableJobModel> sourceList ) {
        List<SchedulableJobModel> destList = new List<SchedulableJobModel>();
        for ( SchedulableJobModel sjm: sourceList ) {
            if ( sjm.isSelected ) {
                destList.add( sjm );
            }
        }
        return destList;
    }

    public static List<Schedulable_Job__c> retrieveJobsListFromModelList( List<SchedulableJobModel> modelList) {
        List<Schedulable_Job__c> result = new List<Schedulable_Job__c>();
        for ( SchedulableJobModel model: modelList ) {
            result.add( model.record );
        }
        return result;
    }

    public static String retrieveJobsNamesStringFromModelList( List<SchedulableJobModel> modelList) {
        String result = '';
        for ( SchedulableJobModel model: modelList ) {
            result += model.record.Name + '; ';
        }
        return result;
    }

    public static List<SchedulableJobModel> retrieveScheduledJobsHistory() {
        return prepareModelListFromJobsList( [ SELECT Name, TimeZoneSidKey__c, TimeZoneOffset__c, Scheduler__r.Id, Scheduler__r.Name, Status__c, CronExpression__c, ApexClassId__c,  NamespacePrefix__c,  ApexClassName__c,  CompleteApexClassName__c,  CreatedDate__c,  CronTriggerId__c,  AsyncApexJobId__c, Active__c FROM Schedulable_Job__c WHERE Active__c = false ] );
    }

}