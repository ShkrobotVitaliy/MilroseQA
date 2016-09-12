public with sharing class ChangeOrderRequest {
    public Proposal__c proposal { get; private set; }
    private Proposal__c changeOrderProposal { get; set; }
    public String changeOrderReason {get; set;}
    public Note proposalNote {get; set;}
    private Set<String> allowedProposalStatuses = new Set<String>{ProposalServices.PROPOSAL_STATUS_AWARDED, ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED};
    public Boolean disableSaveButton {get; set;}
    private String profileName;
    private String roleName;

    public ChangeOrderRequest(ApexPages.StandardController controller) {
        Id currentUserId = UserInfo.getUserId();
        disableSaveButton = false;
        this.proposal = (Proposal__c)controller.getRecord();
        this.proposalNote = new Note( Title = 'Change Order Reason' );
        this.profileName = ProposalWizardServices.getProfileNameById( UserInfo.getProfileId() );
        UserRole userRole = UserServices.getCurrentUserRole();
        if( userRole != null ) {
            this.roleName = userRole.Name;
        } else {
            this.roleName = null;
        }
        this.proposal = [ SELECT is_Change_Order__c, Id, Status__c, Project_Profile__c, Project_Profile__r.Project_Manager__c, Region__c,
                                 Project_Profile__r.Project_Member__c, Project_Profile__r.OwnerId, Project_Profile__r.Production_Manager__c,
                                 Project_Profile__r.Account_Executive__c, Project_Profile__r.Submitted_Planned_Dates__c, Project_Profile__r.Project_State__c,
                                 Project_Profile__r.Proposal_Specialist__c, Project_Team__c,
                                 ( SELECT OwnerId__c, Manager_Lookup__c
                                   FROM Service_Items__r )
                          FROM Proposal__c
                          WHERE Id = : proposal.Id ];

        /*if( profileName != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN &&
            profileName != UserServices.PROFILE_DIRECTOR_OF_OPERATIONS && //MRS-6507
            profileName != UserServices.PROFILE_A_R_CORDINATOR && //MRS-5851
            profileName != UserServices.PROFILE_ACCOUNTING_SUPERVISOR && //MRS-5851
            profileName != UserServices.PROFILE_CFO && //MRS-5851
            profileName != UserServices.PROFILE_FINANCE_MANAGER && //MRS-5851
            profileName != UserServices.PROFILE_STAFF_ACCOUNTANT && //MRS-5851
            profileName != UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER && //MRS-6570
            proposal.Project_Profile__r.OwnerId != currentUserId &&
            !UserServices.isProjectManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Project_Manager__c, proposal.Project_Profile__r.Project_Member__c ) &&
            !UserServices.isProductionManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Production_Manager__c ) &&
            !ProjectRosterServices.isUserAllowedToChangeBillingPreferences( currentUserId, profileName, roleName, proposal, null, true ) && //MRS-6197
            !ProposalWizardServices.isUserAllowedToCreateChangeOrderOnProjectLevel( currentUserId, profileName, roleName, proposal ) &&
            !ProposalWizardServices.isUserAllowedToCreateChangeOrderOnServiceItemLevel( currentUserId, profileName, roleName, proposal, proposal.Service_Items__r, null )
          ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You have no permissions to request a Change Order.' ) );
            disableSaveButton = true;
        }*/

        Boolean isValidUserToCreateInternalCO = false;
        Boolean isValidUserToCreateExternalCO = false;
        if( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || //getIsAdmin
            profileName == UserServices.PROFILE_PROJECT_MANAGER_1 || //getIsPManager1
            profileName == UserServices.PROFILE_PROJECT_MANAGER_2 || //getIsPManager2
            profileName == UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME && proposal.Project_Profile__r.OwnerId == currentUserId || //isThisUserSharedServiceCoor
            profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //isThisUserSharedServiceDepartmentManager
                profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                profileName == UserServices.PROFILE_A_R_CORDINATOR || //MRS-5851
                profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || //MRS-5851
                profileName == UserServices.PROFILE_CFO || //MRS-5851
                profileName == UserServices.PROFILE_FINANCE_MANAGER || //MRS-5851
                profileName == UserServices.PROFILE_STAFF_ACCOUNTANT || //MRS-5851
                proposal.Project_Profile__r.OwnerId == currentUserId ) {
            isValidUserToCreateExternalCO = true;
        } else {
            if( UserServices.isProjectManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Project_Manager__c, proposal.Project_Profile__r.Project_Member__c ) ||
                UserServices.isProductionManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Production_Manager__c ) ) {
                isValidUserToCreateExternalCO = true;
            } else {
                if( currentUserId == ProjectTeamServices.getProjectTeam( proposal.Project_Team__c, new List<String>{ ProjectTeamServices.PRODUCTION_MANAGER_FIELD } ).get(ProjectTeamServices.PRODUCTION_MANAGER_FIELD) ) { //isThisUserProductionManager
                    isValidUserToCreateExternalCO = true;
                } else {
                    if( ProposalWizardServices.isUserAllowedToCreateChangeOrderOnProjectLevel( currentUserId, profileName, roleName, proposal ) || //getIsChangeOrderAllowedOnProjectOrServiceItemLevel
                        ProposalWizardServices.isUserAllowedToCreateChangeOrderOnServiceItemLevel( currentUserId, profileName, roleName, proposal, proposal.Service_Items__r, null ) ) {
                        isValidUserToCreateExternalCO = true;
                    } else {
                        for( Project_Roster__c roster : ProjectRosterServices.getProjectRosterById( proposal.Id ) ) {
                            if( roster.User__c == currentUserId &&
                                roster.User_Contact_IsActive__c &&
                                roster.Active__c ) { //MRS-6868
                                isValidUserToCreateExternalCO = true;
                                break;
                            }
                        }
                    }
                }
            }
        }

        if( ProjectRosterServices.isUserAllowedToChangeBillingPreferences( currentUserId, profileName, roleName, proposal, null, true ) ) { //MRS-6197
            isValidUserToCreateInternalCO = true;
        }

        if( !isValidUserToCreateExternalCO && !isValidUserToCreateInternalCO ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You cannot create COs. You are not an active user on the Project.' ) );
            disableSaveButton = true;
        }

        if( !allowedProposalStatuses.contains(this.proposal.Status__c) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Change Order Request can be applied only to Proposal with Statuses \'Awarded\'.' ) );
            disableSaveButton = true;
        }
        if( this.proposal.Project_Profile__c == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Change Order can not be applied to Proposal without Project.' ) );
            disableSaveButton = true;
        }
        if( this.proposal.Project_Profile__c != null && this.proposal.Project_Profile__r.Project_State__c == ProjectProfileServices.PROJECT_STATE_CLOSED ) {//MRS-6052
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You cannot request a Change Order on the "Closed" Project' ) );
            disableSaveButton = true;
        } else if ( this.proposal.Project_Profile__c != null && !this.proposal.Project_Profile__r.Submitted_Planned_Dates__c ) {//MRS-6039
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'You cannot request a Change Order on the non-committed Project' ) );
            disableSaveButton = true;
        }
    }

    public PageReference addChangeOrderReasonAction(){
        if (String.isBlank(proposalNote.Body)) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Change Order Reason Note is required.' ) );
            return null;
        }

        // Create Note for original Proposal
        proposalNote.ParentId = proposal.Id;
        String noteBody = proposalNote.Body; //DateTime.now() + ' | ' + UserInfo.getName() + ':\n' + proposalNote.Body;
        proposalNote.Body = noteBody;
        try {
            UPSERT proposalNote;
        } catch(System.DMLException ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Error saving Note: ' + ex.getDmlMessage(0) ) );
            return null;
        }

        proposal.is_Change_Order__c = true;
        proposal.Locked__c = false;
        //proposal.Proposal_Type__c = 'Change Order'; //MRS-7049
        try {
            UPSERT proposal;
        } catch(System.DMLException ex) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Error updating Proposal: ' + ex.getDmlMessage(0) ) );
            return null;
        }

        PageReference pReference = new PageReference('/apex/ProposalWizard');
        pReference.getParameters().put('id', proposal.Id);
        pReference.getParameters().put('core.apexpages.devmode.url', '1');
        pReference.setRedirect(true);
        return pReference;
    }

    public PageReference cancelAction() {
        PageReference pReference = new ApexPages.StandardController(proposal).view();
        pReference.setRedirect(true);
        return pReference;
    }
}