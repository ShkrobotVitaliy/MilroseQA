///******************************************************************************************************************************************************************
/// due to triggers exceprions of FF job has to be run with 1 pcs scopes only
/// Database.executeBatch( new PopulateAppliedFieldsOnCashHistories(), 1 );
///******************************************************************************************************************************************************************
global class PopulateAppliedFieldsOnCashHistories implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	
	private final String BATCH_JOB_TITLE = 'Populate Credit/Cash/Journals Applied field on Cash Histories';

	String query;
	private Id batchProcessId;
	
	global PopulateAppliedFieldsOnCashHistories(String taskItemsQuery) {
		this.query = taskItemsQuery;	
	}

	global PopulateAppliedFieldsOnCashHistories() {
		this.query = 'SELECT Id FROM c2g__codaMatchingReference__c';	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Map<Id, Map<String, Boolean>> matReferenceIdToStatusesMap = new Map<Id, Map<String, Boolean>> ();

   		Set<Id> matchingReferenceIdxSet = new Set<Id>();
   		for( c2g__codaMatchingReference__c matchingReference : (List<c2g__codaMatchingReference__c>)scope ) {
   			matchingReferenceIdxSet.add( matchingReference.Id);
   		}

   		List<c2g__codaCashMatchingHistory__c> cashHistoriesList = [SELECT Cash_Applied__c, Credits_Applied__c, Journals_Applied__c, Document_Number__c, c2g__MatchingReference__c,
   																   c2g__Period__r.c2g__Closed__c
   																   FROM c2g__codaCashMatchingHistory__c
   																   WHERE c2g__Period__r.c2g__Closed__c = false
   																   	 AND c2g__MatchingReference__c IN :matchingReferenceIdxSet];
      	if(!cashHistoriesList.isEmpty()) {
	    	for( c2g__codaCashMatchingHistory__c cashHistoryItem : cashHistoriesList ) {
	    		if( !matReferenceIdToStatusesMap.containsKey( cashHistoryItem.c2g__MatchingReference__c ) ) {
	    			matReferenceIdToStatusesMap.put( cashHistoryItem.c2g__MatchingReference__c, new Map<String, Boolean> {
								'cashApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('CSH') ? true : false,
								'creditsApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('SCR') ? true : false,
								'journalsApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('JNL') ? true : false });
	    		} else {
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'cashApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'cashApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('CSH') ? true : false );
	    			}
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'creditsApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'creditsApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('SCR') ? true : false );
	    			}
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'journalsApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'journalsApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('JNL') ? true : false );
	    			}
	    		}
	    	}
	    	for( c2g__codaCashMatchingHistory__c cashHistoryItem : cashHistoriesList ) {
	    		cashHistoryItem.Cash_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'cashApplied' );
	    		cashHistoryItem.Credits_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'creditsApplied' );
	    		cashHistoryItem.Journals_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'journalsApplied' );
	    	}

	    	Database.SaveResult[] srList = Database.update(cashHistoriesList, false);
	    }
	}
	
	global void finish(Database.BatchableContext BC) {}
	
	//Scheduler Method
    global void execute(SchedulableContext sc) {
        PopulateAppliedFieldsOnCashHistories job = new PopulateAppliedFieldsOnCashHistories();
        batchProcessId = Database.executeBatch( job , Integer.valueOf( Label.AmOfMatchReferencesInPopulateAppliedFieldsOnCashHistory ) );
    }
}

///******************************************************************************************************************************************************************
/// due to triggers exceprions of FF job has to be run with 1 pcs scopes only
/// Database.executeBatch( new PopulateAppliedFieldsOnCashHistories(), 1 );
///******************************************************************************************************************************************************************
/// ******************************************************* CODE TO BE RUN FOR ALL = OPENED AND CLOSED PERIODS ******************************************************
///******************************************************************************************************************************************************************
/*global class PopulateAppliedFieldsOnCashHistories implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	
	private final String BATCH_JOB_TITLE = 'Populate Credit/Cash/Journals Applied field on Cash Histories';
	private List<c2g__codaYear__c> yearsOldValues { set; get { if( yearsOldValues == null ) yearsOldValues = new List<c2g__codaYear__c>(); return yearsOldValues; } }
	private List<c2g__codaYear__c> yearsValues { set; get { if( yearsValues == null ) yearsValues = new List<c2g__codaYear__c>(); return yearsValues; } }
	private List<c2g__codaPeriod__c> closedPeriods { set; get { if( closedPeriods == null ) closedPeriods = new List<c2g__codaPeriod__c>(); return closedPeriods; } }

	String query;
	private Id batchProcessId;
	
	global PopulateAppliedFieldsOnCashHistories(String taskItemsQuery) {
		this.query = taskItemsQuery;	
	}

	global PopulateAppliedFieldsOnCashHistories() {
		this.query = 'SELECT Id FROM c2g__codaMatchingReference__c';	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		this functionality is not working on POC but needed on QA and higher
		this.yearsValues = [SELECT c2g__Status__c FROM c2g__codaYear__c];
		for( c2g__codaYear__c year : yearsValues) {
			yearsOldValues.add(new c2g__codaYear__c (Id = year.Id, c2g__Status__c = year.c2g__Status__c));
			year.c2g__Status__c = 'Open';
		}
		Database.update( yearsValues, false );
		this.closedPeriods = [SELECT c2g__Closed__c FROM c2g__codaPeriod__c WHERE c2g__Closed__c =: true];
		for( c2g__codaPeriod__c period : closedPeriods ) {
			period.c2g__Closed__c = false;
		}
		Database.update( closedPeriods, false );
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		Map<Id, Map<String, Boolean>> matReferenceIdToStatusesMap = new Map<Id, Map<String, Boolean>> ();

   		Set<Id> matchingReferenceIdxSet = new Set<Id>();
   		for( c2g__codaMatchingReference__c matchingReference : (List<c2g__codaMatchingReference__c>)scope ) {
   			matchingReferenceIdxSet.add( matchingReference.Id);
   		}

   		List<c2g__codaCashMatchingHistory__c> cashHistoriesList = [SELECT Cash_Applied__c, Credits_Applied__c, Journals_Applied__c, Document_Number__c, c2g__MatchingReference__c
   																   FROM c2g__codaCashMatchingHistory__c
   																   WHERE c2g__MatchingReference__c IN :matchingReferenceIdxSet];
      	if( cashHistoriesList != null ) {
	    	for( c2g__codaCashMatchingHistory__c cashHistoryItem : cashHistoriesList ) {
	    		if( !matReferenceIdToStatusesMap.containsKey( cashHistoryItem.c2g__MatchingReference__c ) ) {
	    			matReferenceIdToStatusesMap.put( cashHistoryItem.c2g__MatchingReference__c, new Map<String, Boolean> {
								'cashApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('CSH') ? true : false,
								'creditsApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('SCR') ? true : false,
								'journalsApplied' => cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('JNL') ? true : false });
	    		} else {
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'cashApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'cashApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('CSH') ? true : false );
	    			}
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'creditsApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'creditsApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('SCR') ? true : false );
	    			}
	    			if( matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'journalsApplied') == false ) { 
	    				matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).put( 'journalsApplied',
	    					cashHistoryItem.Document_Number__c != null && cashHistoryItem.Document_Number__c.left(3).equals('JNL') ? true : false );
	    			}
	    		}
	    	}
	    	for( c2g__codaCashMatchingHistory__c cashHistoryItem : cashHistoriesList ) {
	    		cashHistoryItem.Cash_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'cashApplied' );
	    		cashHistoryItem.Credits_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'creditsApplied' );
	    		cashHistoryItem.Journals_Applied__c = matReferenceIdToStatusesMap.get( cashHistoryItem.c2g__MatchingReference__c ).get( 'journalsApplied' );
	    	}

	    	Database.SaveResult[] srList = Database.update(cashHistoriesList, false);
	    }
	}
	
	global void finish(Database.BatchableContext BC) {
		if( !this.closedPeriods.isEmpty() ) {
			for( c2g__codaPeriod__c period : closedPeriods ) {
				period.c2g__Closed__c = true;
			}
			Database.update( closedPeriods );
		}
		if( !this.yearsOldValues.isEmpty() ) {
			Database.update( yearsOldValues );
		}
	}
	
	//Scheduler Method
    global void execute(SchedulableContext sc) {
        PopulateAppliedFieldsOnCashHistories job = new PopulateAppliedFieldsOnCashHistories();
        batchProcessId = Database.executeBatch( job , 1 );
    }
}*/
///******************************************************************************************************************************************************************