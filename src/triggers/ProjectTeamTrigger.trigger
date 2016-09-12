trigger ProjectTeamTrigger on Project_Team__c (before insert, before update, after update) {

    if( Trigger.isBefore )ProjectTeamServices.updateProjectTeamOwner( Trigger.new );

    if (Trigger.isUpdate){
        if ( Trigger.isAfter ) {
        	Map<Id, Project_Team__c> projectTeamsWithChangedUsers = ProjectTeamServices.filteredProjectTeamsByChangedUsers(Trigger.new, Trigger.oldMap);
            if( !projectTeamsWithChangedUsers.isEmpty() ){
            	//MRS-7529
                Database.executeBatch(new ProjectAssignmentBatch(projectTeamsWithChangedUsers.keySet()), 15);
            }
        }
    }
}