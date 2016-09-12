public class ChangeOrderModel {
    public Change_Order__c changeOrderRecord { get { if( changeOrderRecord == null ) changeOrderRecord = new Change_Order__c(); return changeOrderRecord; } set; }
    public List<ServiceModel> serviceModels { get { if( serviceModels == null ) { serviceModels = new List<ServiceModel>(); } return serviceModels; } set; }
    public Boolean isOriginal { get { if( isOriginal == null ) isOriginal = true; return isOriginal; } set; }
    public Boolean isAlternative { get { if( isAlternative == null ) isAlternative = false; return isAlternative; } set; }
    //public Date approvedDate { get; set; }
    //public Date createdDate { get; set; }
    //public Date requestDate { get; set; }
    //public Boolean isActive { get { if( isActive == null ) isActive = false; return isActive; } set; }
    //private Id projectId;
    //private Id proposalId;
    //public Id changeOrderId { get; set; }
    //public Integer changeOrderNumber { get; set; }

    //public transient Decimal servicesTotal;

    // MRS 7056
    public Boolean hasNonBillabale { set;
        get {
            if( changeOrderRecord.Status__c != ChangeOrderServices.STATUS_PENDING_CLIENT && changeOrderRecord.Status__c != ChangeOrderServices.STATUS_APPROVED ) {
                for( ServiceModel sM : serviceModels ) {
                    if(sM.servicePrice <= 0 || (sM.discount == 100 && changeOrderRecord.Apply_Discount__c)) return true; // MRS 7254
                }
            }
            return false;
        }
    }
    public Boolean hasNonBillableWithoutReason { set;
        get {
            for( ServiceModel sM : serviceModels ) { // MRS 7139				// MRS 7254
                if( !sM.isAmendmendDeleted && (sM.servicePrice <= 0 || (sM.discount == 100 && changeOrderRecord.Apply_Discount__c)) && String.isBlank( sM.serviceItemRecord.Non_Billable_Reason__c ) ) return true;
            }
            return false;
        }
    }

    public Decimal getServicesTotal() {
        return ChangeOrderServices.getServicesTotal( serviceModels, changeOrderRecord.Id );
    }

    //public transient Decimal servicesTotalDiscounted;
    public Decimal getServicesTotalDiscounted() {
        return ChangeOrderServices.getServicesTotalDiscounted( serviceModels, changeOrderRecord.Id );
    }

    //public transient Decimal servicesTotalSalesTax;
    public Decimal getServicesTotalSalesTax() {
        return ChangeOrderServices.getServicesTotalSalesTax( serviceModels, changeOrderRecord.Id );
    }

    private String profileName;
    private String userRoleName;
    public String status { get { if( String.isBlank(status) ) status = ChangeOrderServices.STATUS_DRAFT; return status; } set; }
    private Id userId;
    public Id internalReviewer { get; set; }
    public DateTime internalReviewerReminder { get; set; }
    public DateTime changeOrderCreatorReminder { get; set; }
    private Id proposalCreator;
    public String proposalStatus { get; set; }
    private Boolean proposalIsChangeOrder;
    private String changeOrderIdForCells;
    public Id internalReviewerForCells { get; set; }
    public Id sipsCoordinatorForCells { get; set; }
    private Boolean isMi3;

    public transient Boolean isMaxCompleteness;
    public Boolean getIsMaxCompleteness() {
        return ChangeOrderServices.isMaxCompleteness( serviceModels );
    }

    public transient Boolean enableAutomaticFollowUps;
    public Boolean getEnableAutomaticFollowUps() {
        return ProposalWizardServices.enableCreateAutomaticFollowUps( status, changeOrderRecord.Disable_Followups__c );
    }

    public transient Boolean isInternalReviewer;
    public Boolean getIsInternalReviewer() {
        return userId == internalReviewer;
    }

    public transient Boolean isSIPSOnly;
    public Boolean getIsSIPSOnly() {
        return isAssignedSIPS() && profileName != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN;
    }

    private Boolean isProductionManager;
    private Boolean isSsmOrOmOrSsc;
    private Boolean isProjectOwner;
    private Boolean isAssignedSIPS;

    private Boolean isSsmOrOmOrSscOwner() {
        return isSsmOrOmOrSsc && ( isProjectOwner || isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public Boolean isAssignedCZAnalyst() {
        return ( (profileName == UserServices.PROFILE_CODE_ZONING_ANALYST || profileName == UserServices.PROFILE_CODE_ZONING_ANALYST_QA) ) || profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN;
    }

    public Boolean isAssignedSIPS() {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( internalReviewerForCells == userId &&
                   profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ) ||
                 ( sipsCoordinatorForCells == userId &&
                   profileName.contains(UserServices.PROFILE_SIPS_COORDINATOR) ) );
    }

    private Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel;
    private Boolean isUserInRoster;
    public Boolean canCreateNewCo;

    public transient Boolean enableInternalCO;
    public Boolean getEnableInternalCO() {
        if( getIsFromChangeOrderRequestButton() ) {
            return true;
        }
        return false;
    }

    public transient Boolean enableOriginalApprovedCO;
    public Boolean getEnableOriginalApprovedCO() {
        if( status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
            return false;
        } else if( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN && status != ChangeOrderServices.STATUS_PENDING_CLIENT ) {
            return true;
        } else if( isChangeOrderAllowedOnProjectOrServiceItemLevel && status == ChangeOrderServices.STATUS_DRAFT ) {
            return true;
        } else if( profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ) {
            return status == ChangeOrderServices.STATUS_DRAFT;
        } else if( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST || profileName == UserServices.PROFILE_CODE_ZONING_ANALYST_QA ) {
            return status == ChangeOrderServices.STATUS_IN_CZ_REVIEW && ( userId == changeOrderRecord.Code_Zoning_Analyst__c );
        } else if( getIsInternalReviewer() ) {
            return status == ChangeOrderServices.STATUS_IN_INT_REVIEW;
        } else if( ProposalWizardServices.isAccManPartner( profileName ) ) {
            if( proposalCreator == userId ) {
                return status != ChangeOrderServices.STATUS_DRAFT &&
                       status != ChangeOrderServices.STATUS_IN_CZ_REVIEW &&
                       status != ChangeOrderServices.STATUS_IN_INT_REVIEW;
            } else {
                return false;
            }
        } else if( ProposalWizardServices.isPsExAdmOmLiCzAdmin( profileName, userRoleName ) ) {
            return status != ChangeOrderServices.STATUS_DRAFT &&
                   status != ChangeOrderServices.STATUS_IN_CZ_REVIEW &&
                   status != ChangeOrderServices.STATUS_IN_INT_REVIEW;
        } else if( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST || profileName == UserServices.PROFILE_CODE_ZONING_ANALYST_QA ) {
            return status != ChangeOrderServices.STATUS_DRAFT &&
                   status != ChangeOrderServices.STATUS_IN_CZ_REVIEW;
        } else if( canCreateNewCoOrUserInRoster() ) {
            if( status == ChangeOrderServices.STATUS_DRAFT ) {
                return true;
            } else {
                return false;
            }
        }
        return true;
    }

    public ChangeOrderModel( Change_Order__c co, String profileName, String userRoleName, Id userId, Proposal__c proposal,
                             Boolean isOriginalModel, Project_Team__c assignedProjectTeam, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo, Boolean isUserInRoster ) {
        this.userRoleName = userRoleName;
        this.profileName = profileName;
        this.userId = userId;
        this.isChangeOrderAllowedOnProjectOrServiceItemLevel = isChangeOrderAllowedOnProjectOrServiceItemLevel;
        this.isUserInRoster = isUserInRoster;
        this.canCreateNewCo = canCreateNewCo;
        proposalCreator = ( !String.isBlank( proposal.Id )
                            ? ( proposal.Proposal_Specialist__c != null
                                ? proposal.Proposal_Specialist__c
                                : proposal.OwnerId )
                            : UserInfo.getUserId() );
        if( co != null ) {
            isOriginal = false;
            changeOrderRecord = co;
            //changeOrderId = co.Id;
            //createdDate = co.CreatedDate.date();
            //requestDate = co.Change_Request_Date__c == null ? co.CreatedDate.date() : co.Change_Request_Date__c;
            status = co.Status__c;
            //approvedDate = co.Approved_Date__c;
            //projectId = co.Project_Profile__c;
            //proposalId = co.Proposal__c;
            //servicesTotal = co.Services_Total__c;
            //changeOrderNumber = co.Number__c != null ? Integer.valueOf(co.Number__c) : null;
            internalReviewer = co.Internal_Reviewer__c;
            sipsCoordinatorForCells = co.SIPS_Coordinator__c;
            internalReviewerReminder = co.Internal_Reviewer_Reminder__c;
            changeOrderCreatorReminder = co.Reminder_for_Creator__c;
            if( changeOrderRecord.Document_Type__c == null ) {
                changeOrderRecord.Document_Type__c = ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
            }
        } else {
            sipsCoordinatorForCells = proposal.SIPS_Coordinator__c;
            internalReviewer = proposal.Internal_Reviewer__c;
            if( isOriginalModel ){
                isOriginal = true;
            }else{
                isAlternative = true;
            }
        }

        isProductionManager = userId == assignedProjectTeam.get(ProjectTeamServices.PRODUCTION_MANAGER_FIELD);

        isSsmOrOmOrSsc = profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ||
                         profileName.contains(UserServices.PROFILE_OPERATIONS_MANAGER) || // MRS 7301
                         profileName == UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME ||
                         profileName.contains(UserServices.PROFILE_SIPS_COORDINATOR) ||
                         profileName == UserServices.SUPPORT_STAFF;
        isProjectOwner = !String.isBlank( proposal.Id ) && proposal.Project_Profile__r.OwnerId == userId;

        proposalStatus = proposal.Status__c;
        internalReviewerForCells = !String.isEmpty( internalReviewer ) ? internalReviewer : proposal.Internal_Reviewer__c;
        changeOrderIdForCells = !String.isEmpty( changeOrderRecord.Id ) ? String.valueOf( changeOrderRecord.Id ) : isAlternative ? ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER : ChangeOrderServices.ORIGINAL_CHANGE_ORDER;
        proposalIsChangeOrder = proposal.Is_Change_Order__c;
        isMi3 = !String.isBlank( proposal.Mi3_MRC__c );
    }

    public void addServiceModel( List<ServiceModel> serviceModelList ){
        for( ServiceModel sm : serviceModelList ) {
            sm.profileName = profileName;
            sm.userRoleName = userRoleName;
            sm.proposalStatus = proposalStatus;
            sm.proposalIsChangeOrder = proposalIsChangeOrder;
            sm.changeOrderIdForCells = changeOrderIdForCells;
            sm.status = status;
            sm.userId = userId;
            sm.internalReviewerForCells = internalReviewerForCells;
            sm.proposalCreator = proposalCreator;
            sm.isMi3 = isMi3;
            sm.isProductionManager = isProductionManager;
            sm.isSsmOrOmOrSscOwner= isSsmOrOmOrSscOwner();
            sm.isAssignedCZAnalyst = isAssignedCZAnalyst();
            sm.isAssignedSIPS = isAssignedSIPS();
            sm.isChangeOrderAllowedOnProjectOrServiceItemLevel = isChangeOrderAllowedOnProjectOrServiceItemLevel;
            sm.canCreateNewCo = canCreateNewCoOrUserInRoster();
        }
        serviceModels.addAll( serviceModelList );
    }

    public Boolean canCreateNewCoOrUserInRoster() {
        return canCreateNewCo || ( isUserInRoster && getIsFromChangeOrderRequestButton() );
    }

    public void sortSeviceModels() {
        List<ServiceModel> sortedServiceModels = new List<ServiceModel>();
        List<ServiceModel> deletedServiceModels = new List<ServiceModel>();
        Map<Integer, List<ServiceModel>> rowNumberToServiceModelMap = new Map<Integer, List<ServiceModel>>();
        List<Integer> rowNumbers = new List<Integer>();
        for( ServiceModel sm: serviceModels ){
            if( ( sm.isAmendmendDeleted || sm.getIsQuantityChangeOrder() ) && sm.changeOrderOldId != changeOrderRecord.Id ) {
                deletedServiceModels.add(sm);
                continue;
            }
            if( rowNumberToServiceModelMap.get( sm.rowNumber ) == null ) {
                rowNumberToServiceModelMap.put( sm.rowNumber, new List<ServiceModel>() );
                rowNumbers.add( sm.rowNumber );
            }
            rowNumberToServiceModelMap.get( sm.rowNumber ).add( sm );
        }
        rowNumbers.sort();

        Integer normalizedPosition = 0;
        for( Integer rowNumber: rowNumbers ) {
            for( ServiceModel serviceModelItem : rowNumberToServiceModelMap.get(rowNumber) ) {
                serviceModelItem.rowNumber = ++normalizedPosition;
                sortedServiceModels.add( serviceModelItem );
            }
        }
        sortedServiceModels.addAll( deletedServiceModels );
        serviceModels = sortedServiceModels;
    }

    public Change_Order__c getChangeOrder( Proposal__c proposal, Boolean isUpsert ) {
        Change_Order__c changeOrder = changeOrderRecord;
        //changeOrder.Status__c = status;
        //changeOrder.Approved_Date__c = approvedDate;
        changeOrder.Project_Profile__c = proposal.Project_Profile__c;
        changeOrder.Proposal__c = proposal.Id;
        changeOrder.Services_Total__c = getServicesTotalDiscounted();
        //changeOrder.Number__c = changeOrderNumber;
        changeOrder.Internal_Reviewer__c = internalReviewer;
        changeOrder.Internal_Reviewer_Reminder__c = internalReviewerReminder;
        changeOrder.Reminder_for_Creator__c = changeOrderCreatorReminder;
        if( sipsCoordinatorForCells!= null ) changeOrder.SIPS_Coordinator__c =  sipsCoordinatorForCells;
        if( isUpsert ) upsertChangeOrder( changeOrder );
        return changeOrderRecord;
    }

    private  Boolean upsertChangeOrder( Change_Order__c changeOrder ) {
        if( !isOriginal ) {
            try {
                upsert changeOrder;
                return true;
            } catch ( dmlException ex ) {
                system.debug( 'Exception upserting change order: ' + ex );
                return false;
            }
        }
        return false;
    }

    public void updateIsChangeOrderAllowedOnProjectOrServiceItemLevel( Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        this.isChangeOrderAllowedOnProjectOrServiceItemLevel = isChangeOrderAllowedOnProjectOrServiceItemLevel;
        Boolean isSsmOrOmOrSscOwnerForServiceModel = isSsmOrOmOrSscOwner();
        for( ServiceModel sm : serviceModels ) {
            sm.isSsmOrOmOrSscOwner = isSsmOrOmOrSscOwnerForServiceModel;
            sm.isChangeOrderAllowedOnProjectOrServiceItemLevel = isChangeOrderAllowedOnProjectOrServiceItemLevel;
        }
    }

    public void updateIsUserInRoster( Boolean isUserInRoster ) {
        this.isUserInRoster = isUserInRoster;
        for( ServiceModel sm : serviceModels ) {
            sm.canCreateNewCo = canCreateNewCoOrUserInRoster();
        }
    }

    public Boolean getIsFromChangeOrderRequestButton() {
        return !ApexPages.currentPage().getParameters().containsKey('mode');
    }

    /* Buttons markers */
    public transient Boolean showMoveServices;
    public Boolean getShowMoveServices() {
        return ProposalWizardServices.showMoveServices( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showSaveServiceBundle;
    public Boolean getShowSaveServiceBundle() {
        return ProposalWizardServices.showSaveServiceBundle( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                             proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showAddNewService;
    public Boolean getShowAddNewService() {
        return ProposalWizardServices.showAddNewService( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                         proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showInsertServiceBundle;
    public Boolean getShowInsertServiceBundle() {
        return ProposalWizardServices.showInsertServiceBundle( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                               proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showRemoveChangeOrder;
    public Boolean getShowRemoveChangeOrder() {
        return ProposalWizardServices.showRemoveChangeOrder( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showSubmitCORequest;
    public Boolean getShowSubmitCORequest() {
        return ProposalWizardServices.showSubmitCORequest( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showCancelCORequest;
    public Boolean getShowCancelCORequest() {
        return ProposalWizardServices.showCancelCORequest( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean showSendForCZReview;
    public Boolean getShowSendForCZReview() {
        return ProposalWizardServices.showSendForCZReview( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showSendForSIPSCoordinator;
    public Boolean getShowSendForSIPSCoordinator() {
        return ProposalWizardServices.getShowSendForSIPSCoordinator( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedSIPS() );
    }

    public transient Boolean showComplete;
    public Boolean getShowComplete() {
        return ProposalWizardServices.showComplete( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showCompleteSIPS;
    public Boolean getShowCompleteSIPS() {
        return ProposalWizardServices.showCompleteSIPS( status, isAssignedSIPS() );
    }

    public transient Boolean showSendForInternalReview;
    public Boolean getShowSendForInternalReview() {
        return ProposalWizardServices.showSendForInternalReview( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showSendToClient;
    public Boolean getShowSendToClient() {
        return ProposalWizardServices.showSendToClient( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showReSendToClient;
    public Boolean getShowReSendToClient() {
        return ProposalWizardServices.showReSendToClient( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showFollowUp;
    public Boolean getShowFollowUp() {
        return ProposalWizardServices.showFollowUp( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showApproveChangeOrderIR;
    public Boolean getShowApproveChangeOrderIR() {
        return ProposalWizardServices.showApproveChangeOrderIR( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showApproveChangeOrderPS;
    public Boolean getShowApproveChangeOrderPS() {
        return ProposalWizardServices.showApproveChangeOrderPS( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showRejectChangeOrderIR;
    public Boolean getShowRejectChangeOrderIR() {
        return ProposalWizardServices.showRejectChangeOrderIR( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean showRejectChangeOrderPS;
    public Boolean getShowRejectChangeOrderPS() {
        return ProposalWizardServices.showRejectChangeOrderPS( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean isCZAssignmentVisible;
    public Boolean getIsCZAssignmentVisible() {
        return ProposalWizardServices.isCZAssignmentVisible( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean isSIPSAssignmentVisible;
    public Boolean getIsSIPSAssignmentVisible() {
        return ProposalWizardServices.isSIPSAssignmentVisible( profileName, userId, internalReviewer, status );
    }

    public transient Boolean enableSaveServiceBundle;
    public Boolean getEnableSaveServiceBundle() {
        return ProposalWizardServices.enableSaveServiceBundle( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                               proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableAddNewService;
    public Boolean getEnableAddNewService() {
        return ProposalWizardServices.enableAddNewService( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                           proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableInsertServiceBundle;
    public Boolean getEnableInsertServiceBundle() {
        return ProposalWizardServices.enableInsertServiceBundle( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewer,
                                                                 proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableRemoveChangeOrder;
    public Boolean getEnableRemoveChangeOrder() {
        return ProposalWizardServices.enableRemoveChangeOrder( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableSubmitCORequest;
    public Boolean getEnableSubmitCORequest() {
        return ProposalWizardServices.enableSubmitCORequest( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableCancelCORequest;
    public Boolean getEnableCancelCORequest() {
        return ProposalWizardServices.enableCancelCORequest( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableSendForCZReview;
    public Boolean getEnableSendForCZReview() {
        return ProposalWizardServices.enableSendForCZReview( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableComplete;
    public Boolean getEnableComplete() {
        return ProposalWizardServices.enableComplete( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableSendForInternalReview;
    public Boolean getEnableSendForInternalReview() {
        return ProposalWizardServices.enableSendForInternalReview( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableSendToClient;
    public Boolean getEnableSendToClient() {
        return ProposalWizardServices.enableSendToClient( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableReSendToClient;
    public Boolean getEnableReSendToClient() {
        return ProposalWizardServices.enableReSendToClient( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableFollowUp;
    public Boolean getEnableFollowUp() {
        return ProposalWizardServices.enableFollowUp( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableApproveChangeOrderIR;
    public Boolean getEnableApproveChangeOrderIR() {
        return ProposalWizardServices.enableApproveChangeOrderIR( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableApproveChangeOrderPS;
    public Boolean getEnableApproveChangeOrderPS() {
        return ProposalWizardServices.enableApproveChangeOrderPS( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableRejectChangeOrderIR;
    public Boolean getEnableRejectChangeOrderIR() {
        return ProposalWizardServices.enableRejectChangeOrderIR( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean enableRejectChangeOrderPS;
    public Boolean getEnableRejectChangeOrderPS() {
        return ProposalWizardServices.enableRejectChangeOrderPS( profileName, userRoleName, status, userId, internalReviewer, proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean hasSIPSServices;
    public Boolean getHasSIPSServices() {
        return ProposalWizardServices.getHasSIPSServices( serviceModels, isAssignedSIPS() );
    }
    /* End Buttons markers */

    /* Cells markers */
    public transient Boolean isPhasesVisible;
    public Boolean getIsPhasesVisible() {
        return ProposalWizardServices.isPhasesVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                       proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                       isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isFloorsVisible;
    public Boolean getIsFloorsVisible() {
        return ProposalWizardServices.isFloorsVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                       proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                       isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isServiceGroupVisible;
    public Boolean getIsServiceGroupVisible() {
        return ProposalWizardServices.isServiceGroupVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                             proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                             isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isPurchaseOrderVisible;
    public Boolean getIsPurchaseOrderVisible() {
        return ProposalWizardServices.isPurchaseOrderVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                              proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst() );
    }

    public transient Boolean isMunicipalAgencyVisible;
    public Boolean getIsMunicipalAgencyVisible() {
        return ProposalWizardServices.isMunicipalAgencyVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                                proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                                isChangeOrderAllowedOnProjectOrServiceItemLevel, getIsFromChangeOrderRequestButton() );
    }

    public transient Boolean isUnitOfServiceVisible;
    public Boolean getIsUnitOfServiceVisible() {
        return ProposalWizardServices.isUnitOfServiceVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                              proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                              isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isQuantityVisible;
    public Boolean getIsQuantityVisible() {
        return ProposalWizardServices.isQuantityVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                         proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                         isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isUnitPriceVisible;
    public Boolean getIsUnitPriceVisible() {
        return ProposalWizardServices.isUnitPriceVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                          proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                          isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isLastPriceVisible;
    public Boolean getIsLastPriceVisible() {
        return ProposalWizardServices.isLastPriceVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                          proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(),
                                                          isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isTotalPriceVisible;
    public Boolean getIsTotalPriceVisible() {
        return ProposalWizardServices.isTotalPriceVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                           proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                           isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isActivityStatusVisible;
    public Boolean getIsActivityStatusVisible() {
        return ProposalWizardServices.isActivityStatusVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                               proposalCreator, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                               isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public transient Boolean isRemoveVisible;
    public Boolean getIsRemoveVisible() {
        return ProposalWizardServices.isRemoveVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                       proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                       isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }

    // MRS 6931
    public transient Boolean isMovableVisible;
    public Boolean getIsMovableVisible() {
        return ProposalWizardServices.isMovableVisible( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                       proposalCreator, isMi3, isProductionManager, isSsmOrOmOrSscOwner(), isAssignedCZAnalyst(), isAssignedSIPS(),
                                                       isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCoOrUserInRoster() );
    }
    /* End Cells markers */

}