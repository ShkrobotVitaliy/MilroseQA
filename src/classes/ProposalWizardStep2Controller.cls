public with sharing class ProposalWizardStep2Controller {

    public ProposalWizardStep2Controller( ApexPages.StandardController controller ) {
        proposal = getProposal( ((Proposal__c)controller.getRecord()).Id );
    }

    public Proposal__c proposal { get; set; }

    public String serializedProposal {
        get {
            return JSON.serialize( proposal ).replace( '\\', '\\\\' ).replace( '\'' , '\\\'' );
        }
    }

    /* disable inputs start */
    public Boolean disableInputs {
        get {
            if( disableInputs == null ) {
                Boolean isAccountingHold = ApexPages.currentPage().getParameters().get('accountingHold') == 'true';
                disableInputs = ProposalWizardServices.disableInputs( profileName,
                                                                      currentUserRoleName,
                                                                      proposal.Status__c,
                                                                      getIsThisUserCreator(),
                                                                      proposal.Internal_Reviewer__c == currentUserId,
                                                                      getIsMi3(),
                                                                      getIsThisUserAssignedCZAnalyst(),
                                                                      false ) || isAccountingHold;
            }
            return disableInputs;
        } private set;
    }

    public transient Boolean viewOnly { get; set; }
    public Boolean getViewOnly() {
        return proposal.is_Change_Order__c ||
               ( !proposal.is_Change_Order__c &&
                 getIsCZAnalyst() &&
                 proposal.Code_Zoning_Analyst__c != currentUserId &&
                 !getIsPS() );
    }

    private Id currentUserId {
        get {
            if( currentUserId == null ) {
                currentUserId = UserInfo.getUserId();
            }
            return currentUserId;
        } private set;
    }

    private Boolean getIsThisUserCreator() {
        return ProposalWizardServices.isCreator( proposal.Id, proposal.Proposal_Specialist__c, proposal.OwnerId, currentUserId ) || getIsAdmin();
    }

    private Boolean getIsMi3() {
        return !String.isBlank( proposal.Mi3_MRC__c );
    }

    private Boolean getIsThisUserAssignedCZAnalyst() {
        return getIsAdmin() ||
               proposal.Status__c != ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ||
               ( proposal.Code_Zoning_Analyst__c == currentUserId && proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW );
    }
    /* disable inputs end */

    public transient Boolean isScopeOfWorkRequired;
    public Boolean getIsScopeOfWorkRequired() {
        return ProposalWizardServices.isScopeOfWorkRequired( getIsMi3(), proposal.CreatedDate, proposal.Is_Draft__c );
    }

    public transient Boolean isIrValid;
    public Boolean getIsIrValid() { return !ProposalWizardServices.getIrServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isIdValid;
    public Boolean getIsIdValid() { return !ProposalWizardServices.getIdServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isErValid;
    public Boolean getIsErValid() { return !ProposalWizardServices.getErServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isFaValid;
    public Boolean getIsFaValid() { return !ProposalWizardServices.getFaServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isSpValid;
    public Boolean getIsSpValid() { return !ProposalWizardServices.getSpServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isSmValid;
    public Boolean getIsSmValid() { return !ProposalWizardServices.getSmServices( proposal, true, false, false ).isEmpty(); }

    public transient Boolean isIrValidEmpty;
    public Boolean getIsIrValidEmpty() { return ProposalWizardServices.isIrValidEmpty( proposal ); }

    public transient Boolean isIdValidEmpty;
    public Boolean getIsIdValidEmpty() { return ProposalWizardServices.isIdValidEmpty( proposal ); }

    public transient Boolean isErValidEmpty;
    public Boolean getIsErValidEmpty() { return ProposalWizardServices.isErValidEmpty( proposal ); }

    public transient Boolean isFaValidEmpty;
    public Boolean getIsFaValidEmpty() { return ProposalWizardServices.isFaValidEmpty( proposal ); }

    public transient Boolean isSpValidEmpty;
    public Boolean getIsSpValidEmpty() { return ProposalWizardServices.isSpValidEmpty( proposal ); }

    public transient Boolean isSmValidEmpty;
    public Boolean getIsSmValidEmpty() { return ProposalWizardServices.isSmValidEmpty( proposal ); }

    public void additionalScopeFirstQuestionsAction() {
        if( proposal.sowUseEgressOccupancy__c || proposal.sowMultiplePhases__c || proposal.sowOccupandLoadDiffers__c || proposal.sowMeetingConfRooms__c ||
            proposal.sowTemporarySprinkler__c || proposal.sowOpenFloorConnections__c || proposal.sowSpecialPlaces__c || proposal.sowTenantsWithGlassDoors__c ||
            proposal.sowExteriorSignage__c || proposal.sowFuelStorage__c || proposal.sowExteriorWork__c ) {
            proposal.sowNoneOfTheAbove__c = false;
        }
    }
    public void additionalScopeLastQuestionAction() {
        if( proposal.sowNoneOfTheAbove__c ) {
            proposal.sowUseEgressOccupancy__c = proposal.sowMultiplePhases__c = proposal.sowOccupandLoadDiffers__c = proposal.sowMeetingConfRooms__c =
            proposal.sowTemporarySprinkler__c = proposal.sowOpenFloorConnections__c = proposal.sowSpecialPlaces__c = proposal.sowTenantsWithGlassDoors__c =
            proposal.sowExteriorSignage__c = proposal.sowFuelStorage__c = proposal.sowExteriorWork__c = false;
        }
    }

    /* ----------------- C&Z Analyst  ----------------------------- */
    public transient List<String> questionList;
    public List<String> getQuestionList() {
        return ProposalWizardServices.getQuestionList( getIsCZSpesialistRequired(), proposal );
    }

    public transient Boolean enableStep2Summary;
    public Boolean getEnableStep2Summary() {
        return ProposalWizardServices.enableStep2Summary( proposal, getIsCZAnalyst(), getIsPS(), getIsAdmin() );
    }

    public transient List<SelectOption> sowScopeOfWork;
    public List<SelectOption> getSowScopeOfWork() {
        List<SelectOption> sowScopeOfWorks = new List<SelectOption>();
        if( proposal.Is_Draft__c ) {
            Map<String, String> sowScopeOfWorkOptions = ProposalWizardServices.getPicklistOptions(Proposal__c.SObjectType, 'sowScopeOfWork__c');
            if( ( String.isBlank( proposal.Address__r.Municipality__r.Region__r.Name ) || proposal.Address__r.Municipality__r.Region__r.Name != RegionServices.REGION_NAME_NY ) /*&& !String.isBlank(proposal.sowScopeOfWork__c)*/ ) {
                sowScopeOfWorkOptions.remove(ProposalWizardServices.SOW_HUB_PROJECT);
                if( proposal.sowScopeOfWork__c == ProposalWizardServices.SOW_HUB_PROJECT ) proposal.sowScopeOfWork__c = null;
            }
            sowScopeOfWorks = ProposalWizardServices.generateOptions(null, sowScopeOfWorkOptions, false, true, true);
        }
        return sowScopeOfWorks;
    }

    public transient List<SelectOption> sowAsbestosInvestigationOptions;
    public List<SelectOption> getSowAsbestosInvestigationOptions() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.SObjectType, 'Asbestos_Investigation_Options__c'), false, true, false);
    }

    public List<String> sowSpaceAlterTypeSelected {
        get { return proposal.sowSpaceAlterType__c != null ? (proposal.sowSpaceAlterType__c).split(';', 0) : new List<String>(); }
        set { proposal.sowSpaceAlterType__c = String.join(value, ';'); sowSpaceAlterTypeSelected = value; }
    }

    public transient List<SelectOption> sowSpaceAlterType;
    public List<SelectOption> getSowSpaceAlterType() {
        List<SelectOption> sowSpaceAlterTypes = new List<SelectOption>();
        if( proposal.Is_Draft__c ) {
            List<String> picklistValues = new List<String>();
            for( Schema.PicklistEntry item : Proposal__c.SObjectType.getDescribe().fields.getMap().get( 'sowSpaceAlterType__c' ).getDescribe().getPicklistValues() )
                picklistValues.add( item.getValue() );
            sowSpaceAlterTypes.addAll( ProposalWizardServices.generateOptions(picklistValues, false) );
        }
        return sowSpaceAlterTypes;
    }

    public String sowACUnitsNumber {
        get {
            if( proposal.sowACUnitsNumber__c == null ) proposal.sowACUnitsNumber__c = 1;
            return String.valueOf((proposal.sowACUnitsNumber__c).setScale(0));
        }
        set {
            if( !value.isNumeric() ) value = '1';
            Integer valueInt = Integer.valueOf(Decimal.valueOf(value).setScale(0));
            if( valueInt < 1 ) valueInt = 1;
            proposal.sowACUnitsNumber__c = valueInt;
            value = String.valueOf(valueInt);
        }
    }

    public List<String> sowErBasSelected {
        get { return proposal.sow_er_bas__c != null ? (proposal.sow_er_bas__c).split(';', 0) : new List<String>(); }
        set { proposal.sow_er_bas__c = String.join(value, ';'); sowErBasSelected = value; }
    }

    public transient List<SelectOption> sowErBas;
    public List<SelectOption> getSowErBas() {
        List<SelectOption> sowErBass = new List<SelectOption>();
        if( proposal.Is_Draft__c ) {
            List<String> picklistValues = new List<String>();
            for( Schema.PicklistEntry item : Proposal__c.SObjectType.getDescribe().fields.getMap().get( 'sow_er_bas__c' ).getDescribe().getPicklistValues() )
                picklistValues.add( item.getValue() );
            sowErBass.addAll( ProposalWizardServices.generateOptions(picklistValues, false) );
        }
        return sowErBass;
    }

    public transient List<SelectOption> sow_ir_override;
    public List<SelectOption> getSow_ir_override() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'sow_ir_override__c'), false, true, true);
    }

    public transient List<SelectOption> sow_id_override;
    public List<SelectOption> getSow_id_override() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'sow_id_override__c'), false, true, true);
    }

    public transient List<SelectOption> sow_er_override;
    public List<SelectOption> getSow_er_override() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'sow_er_override__c'), false, true, true);
    }

    public transient List<SelectOption> sow_sp_override;
    public List<SelectOption> getSow_sp_override() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'sow_sp_override__c'), false, true, true);
    }

    public transient List<SelectOption> sow_sm_override;
    public List<SelectOption> getSow_sm_override() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'sow_sm_override__c'), false, true, true);
    }

    public String profileName {
        get {
            if( profileName == null ) {
                profileName = ProposalWizardServices.getProfileNameById( UserInfo.getProfileId() );
            }
            return profileName;
        } set;
    }

    public String currentUserRoleName {
        get {
            if( currentUserRoleName == null ){
                UserRole currentUserRole = UserServices.getCurrentUserRole();
                currentUserRoleName = currentUserRole == null ? '' : currentUserRole.Name;
            }
            return currentUserRoleName;
        } set;
    }

    public transient Boolean isCZAnalyst;
    public Boolean getIsCZAnalyst() { return profileName == UserServices.PROFILE_CODE_ZONING_ANALYST; }

    public transient Boolean isAdmin;
    public Boolean getIsAdmin() { return profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN; }

    public transient Boolean isPS;
    public Boolean getIsPS() { return ProposalWizardServices.isPsExAdmOmLiCzAdmin( profileName, currentUserRoleName ); }

    public transient Boolean isCZSpesialistRequired;
    public Boolean getIsCZSpesialistRequired() {
        return ProposalWizardServices.isCZSpesialistRequired( proposal );
    }

    public Proposal__c getProposal( Id proposalId ) {
        Proposal__c proposal = ProposalWizardServices.getProposalForStep2( proposalId );
        if( proposalId != null ) {
            proposal.Is_Draft__c = proposal.Is_Draft__c;
        }
        return proposal;
    }

    public Proposal__c getAdditionalProposalFields( Id proposalId ) {
        Proposal__c proposal;
        if( proposalId != null ) {
            proposal = [ SELECT Id, Status__c
                         FROM Proposal__c
                         WHERE Id = : proposalId ];
        } else {
            proposal = new Proposal__c( Status__c = ProposalServices.PROPOSAL_STATUS_NEW );
        }
        return proposal;
    }







}