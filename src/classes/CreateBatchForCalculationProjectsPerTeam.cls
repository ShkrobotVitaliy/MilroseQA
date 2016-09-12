global with sharing class CreateBatchForCalculationProjectsPerTeam implements Schedulable, Database.Batchable<Sobject>{

	global void execute(SchedulableContext sc) {
		Database.executeBatch( new CreateBatchForCalculationProjectsPerTeam(), 2000 );
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		String queryString = 'SELECT Id, Number_Of_Projects__c ';
		queryString +=       'FROM Project_Team__c';

		return Database.getQueryLocator(queryString);
	}

	global void execute(Database.BatchableContext BC, List<Sobject> scope){
		List<Project_Team__c> projectTeamList = (List<Project_Team__c>)scope;

		Map<Id, Project_Team__c> projectTeamMap = new Map<Id, Project_Team__c>();
		for (Project_Team__c projectTeam : projectTeamList){
		    projectTeamMap.put(projectTeam.Id, new Project_Team__c(Id = projectTeam.Id, Number_Of_Projects__c = 0));
		}

		for(AggregateResult ar : [SELECT Count (Id) projectCount, Project_Team__c
								  FROM Project_Profile__c
								  WHERE (Project_State__c = : ProjectProfileServices.PROJECT_STATE_NOT_STARTED OR Project_State__c = : ProjectProfileServices.PROJECT_STATE_IN_PROCESS) AND
										Project_Team__c IN : projectTeamMap.keySet()
										GROUP BY Project_Team__c]){
			Id projectTeamId = (Id)ar.get('Project_Team__c');
			projectTeamMap.put(projectTeamId, new Project_Team__c(Id = projectTeamId, Number_Of_Projects__c = (Integer)ar.get('projectCount')));
		}

		update projectTeamMap.values();
	}

	global void finish(Database.BatchableContext BC){}
}