global class ProjectAssignmentBatch implements Database.Batchable<sObject> {
	String query;

	global ProjectAssignmentBatch(Set<Id> projectTeamSetId) {
		List<String> allowedStatuses = new List<String>{ProjectProfileServices.PROJECT_STATE_NOT_STARTED,
														ProjectProfileServices.PROJECT_STATE_IN_PROCESS,
														ProjectProfileServices.PROJECT_STATE_ON_HOLD};

		List<Id> ids = new List<Id>();
		ids.addAll(projectTeamSetId);

		query = 'SELECT Id, OwnerId, Project_State__c, Project_Manager__c, Project_Team__c, Project_Member__c, FREP__c, Production_Manager__c, Avoid_Validation_Rules__c, ' +
				'        Project_Team__r.Project_Manager__c, Project_Team__r.FREP__c, Project_Team__r.Project_Member__c, Project_Team__r.Production_Manager__c ' +
				'FROM Project_Profile__c ' +
				'WHERE (Project_State__c IN (\'' +  String.join(allowedStatuses, '\',\'') + '\')) AND ' +
				'      (Project_Team__c IN (\'' + String.join(ids, '\',\'') + '\'))';

		System.Debug(LoggingLevel.ERROR, 'Query String = ' + query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Project_Profile__c> projectProfileList = (List<Project_Profile__c>)scope;

		List<Project_Profile__c> projectWithChangedUsers = ProjectProfileServices.updateProjectTeamAssignment(projectProfileList);
		ProjectProfileServices.updateServiceItemTaskItemOwnerChangeProjectTeam(projectWithChangedUsers, null, true);
	}
	
	global void finish(Database.BatchableContext BC) {}
}