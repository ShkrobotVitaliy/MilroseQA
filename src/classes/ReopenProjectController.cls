public with sharing class ReopenProjectController {
	public Project_Profile__c currentProject{get; set;}
	public Boolean isValid{get; set;}
	User currentUser;
	//MRS-6467
	Set<String> userProfiles = new Set<String>{ UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
												UserServices.PROFILE_OPERATIONS_MANAGER,
												UserServices.PROFILE_DIRECTOR_OF_OPERATIONS, //MRS-6507
												UserServices.PROFILE_SHARED_SERVICES_MANAGER,
												UserServices.PROFILE_FINANCE_MANAGER,
												UserServices.PROFILE_CFO,
												UserServices.PROFILE_A_R_CORDINATOR,
												UserServices.PROFILE_STAFF_ACCOUNTANT,
												UserServices.PROFILE_ACCOUNTING_SUPERVISOR };

	public ReopenProjectController(ApexPages.StandardController controller) {
		currentUser = [SELECT Id, Name, Profile.Name, UserRole.Name
					   FROM User
					   WHERE Id =: Userinfo.getUserId()][0];
		isValid = true;
		currentProject = (Project_Profile__c)controller.getRecord();
		currentProject = [SELECT Id, Project_State__c, Reopen_Project_Reason__c, Submitted_Planned_Dates__c, Project_Team__c,
								OwnerId, FREP__c, Production_Manager__c, Project_Member__c, Project_Manager__c,
								Project_Team__r.Project_Manager__c, Project_Team__r.Project_Member__c, Project_Team__r.FREP__c, Project_Team__r.Production_Manager__c
						  FROM Project_Profile__c
						  WHERE Id =: currentProject.Id];
		if (currentProject.Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED){
			isValid = false;
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Project is not Closed' ) );
		}
		if ( !userProfiles.contains(currentUser.Profile.Name) &&
			 currentUser.Id != currentProject.OwnerId && //MRS-7078
			 currentUser.Id != currentProject.Production_Manager__c &&
			 currentUser.Id != currentProject.Project_Member__c &&
			 currentUser.Id != currentProject.Project_Manager__c ){

			isValid = false;
			ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'You haven\'t got permission to reopen current Project' ) );
		}
	}

	public PageReference reopenCurrentProject (){
		if ( isValid ){
			try{
				List<Task_Item__c> taskItemNotComplitedList = [SELECT Id, Actual_End_Date__c
															   FROM Task_Item__c
															   WHERE Actual_End_Date__c = null AND
																	Project_Profile__c =: currentProject.Id AND
																	RecordType.Name !=:TaskManagementServices.MILESTONE_RECORDTYPE_NAME LIMIT 1];

				if (taskItemNotComplitedList.isEmpty()){
					currentProject.Project_State__c = ProjectProfileServices.PROJECT_STATE_COMPLETE;
				} else if ( currentProject.Submitted_Planned_Dates__c ){
					currentProject.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
				} else {
					currentProject.Project_State__c = ProjectProfileServices.PROJECT_STATE_NOT_STARTED;
				}
				ProjectProfileServices.isReopenProject = true;//MRS-6467
				update currentProject;

				return cancelAction();
			} catch (Exception ex){
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Can not Reopen curent Project ' + ex.getMessage() ) );
			} finally {
				ProjectProfileServices.isReopenProject = false;
			}
		}
		return null;
	}

	public PageReference cancelAction() {
		PageReference pReference = new ApexPages.StandardController(currentProject).view();
		pReference.setRedirect(true);
		return pReference;
	}
}