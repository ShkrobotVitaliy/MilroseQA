public with sharing class CloseProjectController {
    public Project_Profile__c currentProject { get; private set; }
    public Boolean disableSaveButton {get; set;}
    public Boolean isValid {get; set;}
    
    public Boolean closeProjectAction {
        get {
            if ( closeProjectAction == null ) {
                closeProjectAction = false;

            }
            return closeProjectAction;
        }
        set;
    }
    
    public static String INVALID_PROJECT_PROFILE = 'Invalid Project Profile: ';
    public static String PROJECT_PROFILE_IS_CLOSED = 'Project Profile is already closed.';
    //MRS-6467
    public static String INVALID_PROJECT_ROLE = 'You have no permissions. Only Project Manager 2 and Product Manager assigned to Project, Operation Manager, SS Manager and Accounting Department users can close Project';

    public CloseProjectController( ApexPages.StandardController controller ) {
        isValid = true;
        try{
	        disableSaveButton = false;
	        currentProject = (Project_Profile__c)controller.getRecord();
	        
	        currentProject = [ Select Id, Project_Closure_Reason__c, Project_State__c, Production_Manager__c, Project_Manager__c, 
                                      Project_Member__c, FREP__c, OwnerId, Proposal_Specialist__c, Proposal__r.Region__c
			                   From Project_Profile__c 
			                   Where Id = :currentProject.Id ];

            //MRS-6467
            if (UserServices.isValidUserForProject( UserInfo.getUserId(), currentProject, null, null, true, true )) {
				if( currentProject.Project_State__c != null && currentProject.Project_State__c.equals( ProjectProfileServices.PROJECT_STATE_CLOSED ) ) {
					isValid = false;
	            	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, PROJECT_PROFILE_IS_CLOSED ) );
				}
             } else {
				isValid = false;
            	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, INVALID_PROJECT_ROLE ) );
             }
        } catch (Exception e){
            isValid = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, INVALID_PROJECT_ROLE + e.getMessage()));
        }
    }
    
    public PageReference addProjectClosingReasonAction(){
        if ( String.isBlank( currentProject.Project_Closure_Reason__c ) ) {
        	this.closeProjectAction = false;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Project Closure Reason is required' ) );
            return null;
        }

        currentProject.Project_State__c = ProjectProfileServices.PROJECT_STATE_CLOSED;
        try {
            update currentProject;
        } catch(System.DMLException ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Error updating Proposal: ' + ex.getDmlMessage(0) ) );
            return null;
        }
        return cancelAction();
    }
    
    public PageReference cancelAction() {
        PageReference pReference = new ApexPages.StandardController(currentProject).view();
        pReference.setRedirect(true);
        return pReference;
    } 
    
    public void showDialogCloseProject() {
        this.closeProjectAction = true;
    }
    
    public void cancelCloseProject() {
        this.closeProjectAction = false;
    }
}