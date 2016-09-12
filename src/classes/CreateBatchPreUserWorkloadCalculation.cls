global with sharing class CreateBatchPreUserWorkloadCalculation implements  Schedulable {

	global void execute(SchedulableContext sc) {
        CreateBatchPreUserWorkloadCalculation job = new CreateBatchPreUserWorkloadCalculation();
        job.execute();
    }

    global void execute(){
	    List<User> usersList = new List<User>();
	    List<Project_Team__c> teamsList = new List<Project_Team__c>();

		for( Project_Team__c item: [ Select Id, Name, Expected_Duration__c, Total_Duration__c From Project_Team__c limit 100 ] ){
			item.Expected_Duration__c = 0;
			teamsList.add( item );
		}

		for( User item: [ Select Id, Name, Expected_Duration__c, Total_Duration__c From User Where isActive = true ] ){
			item.Expected_Duration__c = 0;
			usersList.add( item );
		}

		update teamsList;

	    update usersList;
    }

}