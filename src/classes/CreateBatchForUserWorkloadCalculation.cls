global with sharing class CreateBatchForUserWorkloadCalculation implements  Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{

    global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateBatchForUserWorkloadCalculation(), 2000 );
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString = ' SELECT Id, RecordType.Name, Expected_Duration__c, Project_Profile__c, Actual_End_Date__c, OwnerId, Project_Profile__r.Project_Team__c ' +
                             ' FROM Task_Item__c ' +
                             ' WHERE ( Project_Profile__r.Project_State__c = \'' + ProjectProfileServices.PROJECT_STATE_NOT_STARTED + '\' OR ' +
                             '        Project_Profile__r.Project_State__c = \'' + ProjectProfileServices.PROJECT_STATE_IN_PROCESS + '\' ) AND ' +
                             '        Actual_End_Date__c = null AND ' +
                             '        RecordType.Name != \'' + TaskManagementServices.MILESTONE_RECORDTYPE_NAME + '\' AND ' +
                             '        Service_Item__r.Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\' limit 50000000';

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        Map<Id, User> usersMap = new Map<Id, User>();
        Map<Id, Project_Team__c> teamsMap = new Map<Id, Project_Team__c>();

        for( Project_Team__c item: [ Select Id, Name, Expected_Duration__c, Total_Duration__c From Project_Team__c limit 100 ] ){
            teamsMap.put( item.Id, item );
        }

        for( User item: [ Select Id, Name, Expected_Duration__c, Total_Duration__c From User Where isActive = true ] ){
            usersMap.put( item.Id, item );
        }

        List<Task_Item__c> scopeList = ( List<Task_Item__c> ) scope;

        for( Task_Item__c item: scopeList ){
            if( item.Expected_Duration__c != null && usersMap.get( item.OwnerId ) != null && usersMap.get( item.OwnerId ).Expected_Duration__c != null ) usersMap.get( item.OwnerId ).Expected_Duration__c += DateUtils.getMinute( item.Expected_Duration__c );
        }

        update usersMap.values();

        for( Task_Item__c item: scopeList ){
            if( item.Expected_Duration__c != null && item.Project_Profile__r.Project_Team__c != null ) teamsMap.get( item.Project_Profile__r.Project_Team__c ).Expected_Duration__c += DateUtils.getMinute( item.Expected_Duration__c );
        }

        update teamsMap.values();
    }

    global void finish(Database.BatchableContext BC){

    }
}