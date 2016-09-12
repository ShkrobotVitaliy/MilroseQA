trigger ProjectRosterTrigger on Project_Roster__c (before insert, before update, after insert, after update, after delete) {

	if (Trigger.isBefore){
		if (Trigger.isUpdate || Trigger.isInsert){
	        ProjectRosterServices.setKey( Trigger.new );
	        ProjectRosterServices.populateProposal( Trigger.new );
	    }
	    if(Trigger.isUpdate){
	    	ProjectRosterServices.populateDeactivationDate( Trigger.new, Trigger.oldMap );
	    }
    }

    if (Trigger.isAfter){
    	if (Trigger.isInsert){
    		ProjectRosterServices.deactivateOldRosters( ProjectRosterServices.filteredProjectsWithManualyAddedRosters( Trigger.new ) );
    		if( ProjectRosterServices.rosterIsGoingFromWizard ) ProjectRosterServices.createSIPSTeamRosters( ProjectRosterServices.filteredSIPSManagerProjectRosters( Trigger.new ) );//MRS-7487
    	}
    	//MRS-6851
    	if ( Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete ){
    		if (ProjectProfileServices.preventToUpdateProjectAssignment){
	    		ProjectProfileServices.populateUsersFieldOnProject(null, null, ProjectRosterServices.filteredProjectRosterForProjectAssignment(Trigger.new, Trigger.oldMap));
	    	}
    	}
    }
}