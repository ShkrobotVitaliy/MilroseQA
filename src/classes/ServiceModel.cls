public class ServiceModel {
    public Service_Item__c serviceItemRecord { get { if ( serviceItemRecord == null ) serviceItemRecord = new Service_Item__c(); return serviceItemRecord; } set; }
    public Service_Template__c serviceTemplateRecord { get { if ( serviceTemplateRecord == null ) serviceTemplateRecord = new Service_Template__c(); return serviceTemplateRecord; } set; }
    public Client_Price__c priceRecord { get { if ( priceRecord == null ) priceRecord = new Client_Price__c(); return priceRecord; } set; }
    //public Service_Template__c availableService { get; set; }

    public Integer rowNumber { get { if(rowNumber == null) rowNumber = 0; return rowNumber; } set; }
    public Id      changeOrderId { get; set; }
    public Id      changeOrderOldId { get; set; }
    public Id      recordId { get;set; }
    public Boolean isTemplate { get; set; }
    //public String  recordName { get; set; }
    public String  serviceGroup { get; set; }
    public String  municipalAgency { get; set; }
    public Boolean isAlternative { get; set; }
    public Boolean isOriginal { get; set; }
    public Decimal discount { get; set; }
    public Boolean isAddedToPurchaseOrder { get { if(isAddedToPurchaseOrder== null) isAddedToPurchaseOrder = false; return isAddedToPurchaseOrder; } set; }
    public Boolean checked { get { if( checked== null ) checked = false; return checked; } set; }

    public transient Boolean pendingPhaseSave;
    public Boolean getPendingPhaseSave() { return !isTemplate && phaseId != serviceItemRecord.Phase__c; }

    public Id phaseId { get; set; }
    //public String  phaseName { get; set; }
    //public Integer phaseStep { get; set; }

    public transient Boolean hasClientPrice;
    public Boolean getHasClientPrice() { return !String.isBlank( priceRecord.Id ); }

    //public String amendmendModificationDate { get; set; }
    public String  purchaseOrderNumber { get;set; }

    public Boolean isHourlyService { get; set; }
    public transient String unitOfService;
    public String getUnitOfService() { return isHourlyService == true ? ServiceItemServices.UNIT_OF_SERVICE_HOUR : ServiceItemServices.UNIT_OF_SERVICE_FILING; }

    public transient Decimal totalServicePrice;
    public Decimal getTotalServicePrice() { return (servicePrice == null ? 0.00 : servicePrice) * quantity; }

    //public transient Decimal totalDiscountedServicePrice;
    public Decimal getTotalDiscountedServicePrice() {
        return getTotalServicePrice() * (100 - discount) / 100;
    }

    public transient Decimal totalServicePriceOld;
    public Decimal getTotalServicePriceOld() {
        return (servicePrice == null ? 0.00 : servicePrice) * quantityOld;
    }

    //public transient Decimal totalDiscountedServicePriceOld;
    public Decimal getTotalDiscountedServicePriceOld() {
        return getTotalServicePriceOld() * (100 - discount) / 100;
    }

    public transient Decimal totalServicePriceDiff;
    public Decimal getTotalServicePriceDiff() { return (servicePrice == null ? 0.00 : servicePrice) * (quantity - quantityOld); }

    //public transient Decimal totalDiscountedServicePriceDiff;
    public Decimal getTotalDiscountedServicePriceDiff() {
        return getTotalServicePriceDiff() * (100 - discount) / 100;
    }

    //public transient Decimal salesTax;
    public Decimal getSalesTax() {
        return ServiceItemServices.calculateSalesTax( serviceItemRecord, isAlternative, getTotalDiscountedServicePrice() );
    }

    //public transient Decimal salesTaxOld;
    public Decimal getSalesTaxOld() {
        return ServiceItemServices.calculateSalesTax( serviceItemRecord, isAlternative, getTotalDiscountedServicePriceOld() );
    }

    //public transient Decimal salesTaxDiff;
    public Decimal getSalesTaxDiff() {
        return ServiceItemServices.calculateSalesTax( serviceItemRecord, isAlternative, getTotalDiscountedServicePriceDiff() );
    }

    public Decimal servicePrice { get; set; }
    public Decimal quantity { get; set; }
    public Decimal quantityOld { get; set; }
    public Decimal quantityDiff {
        get {
            return quantityOld - quantity;
        }
        set {
            quantityDiff = value;
            quantity = quantityOld - value;
        }
    }

    //public Boolean canDelete { get { return activityStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED; } private set; }
    public Boolean isAmendmendAdded { get; set; }
    public Boolean isAmendmendDeleted { get; set; }
    public Id      lastProposalPriceId { get; set; }
    public Decimal lastProposalPrice { get; set; }
    public Id      lastProposalId { get; set; }

    public transient Boolean isQuantityChangeOrder;
    public Boolean getIsQuantityChangeOrder() {
        return /*changeOrderId != changeOrderOldId && quantity != quantityOld &&*/ quantityOld != null && quantityOld != 0 /*&& !isAmendmendDeleted && !isAmendmendAdded*/;
    }

    public String activityStatus {
        get {
            if( isAmendmendDeleted ) {
                activityStatus = ServiceItemServices.SERVICE_STATUS_INACTIVE;
                return activityStatus;
            }
            //activityStatus = serviceItemRecord.Status__c;
            if( serviceItemRecord.Actual_End_Date__c != null ) {
                activityStatus = ServiceItemServices.SERVICE_STATUS_COMPLETED;
            } else {
                activityStatus = serviceItemRecord.Actual_Start_Date__c == null ?  ServiceItemServices.SERVICE_STATUS_NOTSTARTED : ServiceItemServices.SERVICE_STATUS_ACTIVE;
            }
            return activityStatus;
        } set;
    }

    public String servicePriceStr {
        get {
            if( servicePrice == null ) {
                return '';
            } else {
                return String.valueOf((servicePrice).setScale(2));
            }
        }
        set {
            try {
                if( !String.isEmpty( value ) ) {
                    if( Decimal.valueOf(value).setScale(2) >= 0 ) {
                        servicePrice = Decimal.valueOf(value).setScale(2);
                    }
                } else if( !getIsUnitPriceRequired() && String.isEmpty( value ) ) {
                    servicePrice = null;
                }
            } catch ( exception e ) {
            }
        }
    }

    public String quantityDiffStr {
        get {
            return String.valueOf(quantityDiff);
        }
        set {
            if( value.isNumeric() && Integer.valueOf(value) > 0 ) {
                quantityDiffStr = value;
                quantityDiff = Decimal.valueOf(value);
            } else {
                quantityDiffStr = String.valueOf( quantityDiff );
            }
        }
    }

    public String quantityOldStr {
        get {
            return String.valueOf(quantityOld);
        }
        set {
            if( value.isNumeric() && Integer.valueOf(value) > 0 ) {
                quantityOldStr = value;
                quantityOld = Decimal.valueOf(value);
            } else {
                quantityOldStr = String.valueOf( quantityOld );
            }
        }
    }

    public String quantityStr {
        get {
            return String.valueOf(quantity);
        }
        set {
            if( value.isNumeric() && Integer.valueOf(value) > 0 ) {
                quantityStr = value;
                quantity = Decimal.valueOf(value);
            } else {
                quantityStr = String.valueOf( quantity );
            }
        }
    }

    public Service_Item__c getServiceItem( Boolean isUpsert ) {
        return getServiceItem( null, isUpsert );
    }

    public Service_Item__c getServiceItem( Proposal__c proposal, Boolean isUpsert ) {
        Service_Item__c service = new Service_Item__C( Id = serviceItemRecord.Id );
        //Service_Item__c service = serviceItemRecord.clone(true, true, true, true);
        service.Quantity__c = quantity;
        service.Quantity_Old__c = quantityOld;
        service.Phase__c = phaseId;
        service.Unit_Price__c = servicePrice;
        if( proposal != null ) service.Proposal__c = proposal.Id;
        service.Discount_Percentage__c = discount;
        service.Row_Position__c = rowNumber;
        service.Service_Group__c = serviceGroup.isNumeric() ? Integer.valueOf(serviceGroup) : null;
        service.Change_Order__c = changeOrderId;
        service.Change_Order_Old__c = changeOrderOldId;
        service.Is_Amendmend_Added__c = isAmendmendAdded;
        service.Is_Amendmend_Deleted__c = isAmendmendDeleted;
        service.Municipal_Agency_ID__c = municipalAgency;
        if( isUpsert ) upsertServiceModel( service );
        return service;
    }

    private Boolean upsertServiceModel( Service_Item__c service ) {
        try {
            upsert service;
            return true;
        } catch ( dmlException ex ) {
            system.debug( 'Exception upserting change order: ' + ex );
            return false;
        }
        return false;
    }

    /* Cells editability markers ----> populated in ChangeOrderModel*/
    public String profileName;
    public String userRoleName;
    public String proposalStatus;
    public Boolean proposalIsChangeOrder;
    public String changeOrderIdForCells;
    public String status;
    public Id userId;
    public Id internalReviewerForCells;
    public Id proposalCreator;
    public Boolean isMi3;
    public Boolean isProductionManager;
    public Boolean isSsmOrOmOrSscOwner;
    public Boolean isAssignedCZAnalyst;
    public Boolean isAssignedSIPS;
    public Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel;
    public Boolean canCreateNewCo;

    public transient Boolean isPhasesEditable;
    public Boolean getIsPhasesEditable() {
        return ProposalWizardServices.isPhasesEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                        proposalCreator, activityStatus,isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                        isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    public transient Boolean isFloorsEditable;
    public Boolean getIsFloorsEditable() {
        return ProposalWizardServices.isFloorsEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                        proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                        isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    public transient Boolean isServiceGroupEditable;
    public Boolean getIsServiceGroupEditable() {
        return ProposalWizardServices.isServiceGroupEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                              proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                              isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }

    public transient Boolean isSIPSService;
    public Boolean getIsSIPSService() {
        return serviceItemRecord.Is_Sips_Service__c;
               /*serviceItemRecord.Category__c == ServiceItemServices.CATEGORY_CONSULTING &&
               serviceItemRecord.Type__c == ServiceItemServices.TYPE_SPECIAL_INSPECTION; */

               // this was disabled prior to removing fields from SELECT
               // &&serviceItemRecord.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION;
    }
    private Boolean getIsSIPSServiceTemplate() {
        return serviceTemplateRecord.Category__c == ServiceItemServices.CATEGORY_CONSULTING &&
               serviceTemplateRecord.Type__c == ServiceItemServices.TYPE_SPECIAL_INSPECTION;// &&
               //serviceTemplateRecord.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION;
    }

    public transient Boolean isServiceGroupRequired;
    public Boolean getIsServiceGroupRequired() {
        return ProposalWizardServices.isServiceGroupRequired( getIsSIPSService(), isAssignedSIPS, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells );
    }

    public transient Boolean isPurchaseOrderEditable;
    public Boolean getIsPurchaseOrderEditable() {
        return ProposalWizardServices.isPurchaseOrderEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                               proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst );
    }
    public transient Boolean isMunicipalAgencyEditable;
    public Boolean getIsMunicipalAgencyEditable() {
        return ProposalWizardServices.isMunicipalAgencyEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                                 proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                                 isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    public transient Boolean isQuantityEditable;
    public Boolean getIsQuantityEditable() {
        return ProposalWizardServices.isQuantityEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                          proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                          isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    public transient Boolean isQuantityEditableForSIPS;
    public Boolean getIsQuantityEditableForSIPS() {
        return ProposalWizardServices.isEditableForSIPS( isAssignedSIPS, getIsSIPSService(), proposalStatus, activityStatus, status, proposalIsChangeOrder, changeOrderIdForCells,
                                                         isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }
    public transient Boolean isUnitPriceRequired;
    public Boolean getIsUnitPriceRequired() {
        return ProposalWizardServices.isUnitPriceRequired( profileName, userRoleName, isMi3, isAssignedSIPS, isTemplate ? getIsSIPSServiceTemplate() : getIsSIPSService() );
    }
    public transient Boolean isUnitPriceEditable;
    public Boolean getIsUnitPriceEditable() {
        return ProposalWizardServices.isUnitPriceEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                           proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                           isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    public transient Boolean isRemoveEditable;
    public Boolean getIsRemoveEditable() {
        return ProposalWizardServices.isRemoveEditable( profileName, userRoleName, proposalStatus, proposalIsChangeOrder, changeOrderIdForCells, status, userId, internalReviewerForCells,
                                                        proposalCreator, activityStatus, isMi3, isProductionManager, isSsmOrOmOrSscOwner, isAssignedCZAnalyst,
                                                        isAssignedSIPS, getIsSIPSService(), isChangeOrderAllowedOnProjectOrServiceItemLevel, canCreateNewCo );
    }
    /* End Cells editability markers */
    public ServiceModel( Service_Template__c service, Client_Price__c clientPrice ) {
        isTemplate = true;
        if( service != null ) {
            serviceTemplateRecord = service;
            recordId = service.Id;
            isHourlyService = service.Unit_of_Service__c == ServiceItemServices.UNIT_OF_SERVICE_HOUR;
            //phaseName = '';
            phaseId = null;
            municipalAgency = '';
            rowNumber = 0;
            //phaseStep = 1;
            isAlternative = false;
            serviceGroup = '';
        }
        if( clientPrice != null ) {
            priceRecord = clientPrice;
            servicePrice = !String.isBlank(String.valueOf(priceRecord.Medium_Price__c)) ? priceRecord.Medium_Price__c : (getIsSIPSServiceTemplate() ? null : 0.00);
        } else {
            servicePrice = !String.isBlank(String.valueOf(serviceTemplateRecord.Medium_Price__c)) ? serviceTemplateRecord.Medium_Price__c : (getIsSIPSServiceTemplate() ? null : 0.00);
        }
        quantity = 0;
        discount = 0;
    }

    public ServiceModel( Service_Item__c service, Service_Template__c template, Client_Price__c clientPrice, Last_Proposal_Price__c previousProposalPrice ){
        isTemplate = false;
        if( service != null ) {
            serviceItemRecord = service;
            recordId = serviceItemRecord.Id;
            isHourlyService = serviceItemRecord.Is_Hourly_Service__c;
            //phaseName = serviceItemRecord.Phase__r.Name__c;
            phaseId = serviceItemRecord.Phase__c;
            rowNumber = Integer.valueOf(serviceItemRecord.Row_Position__c);
            //phaseStep = Integer.valueOf(serviceItemRecord.Phase__r.Number__c);
            municipalAgency = serviceItemRecord.Municipal_Agency_ID__c;
            isAmendmendAdded = serviceItemRecord.Is_Amendmend_Added__c;
            isAmendmendDeleted = serviceItemRecord.Is_Amendmend_Deleted__c;
            activityStatus = serviceItemRecord.Status__c;
            purchaseOrderNumber = serviceItemRecord.Purchase_Order__r.Name == null ? '' : serviceItemRecord.Purchase_Order__r.Name;
            isAlternative = serviceItemRecord.Is_Alternative__c;
            isOriginal = serviceItemRecord.Original__c;
            serviceGroup = serviceItemRecord.Service_Group__c == null ? '' : String.valueOf(serviceItemRecord.Service_Group__c);
            changeOrderId = serviceItemRecord.Change_Order__c;
            changeOrderOldId = serviceItemRecord.Change_Order_Old__c;
        }
        quantity = !String.isBlank(String.valueOf(serviceItemRecord.Quantity__c)) ? serviceItemRecord.Quantity__c : 0;
        quantityOld = !String.isBlank(String.valueOf(serviceItemRecord.Quantity_Old__c)) ? serviceItemRecord.Quantity_Old__c : 0;
        discount = !String.isBlank(String.valueOf(serviceItemRecord.Discount_Percentage__c)) ? serviceItemRecord.Discount_Percentage__c : 0;
        if( !getIsSIPSService() || ( getIsSIPSService() && serviceItemRecord.Unit_Price__c != null ) ) {
            servicePrice = !String.isBlank(String.valueOf(serviceItemRecord.Unit_Price__c)) ? serviceItemRecord.Unit_Price__c : 0.00;
        } else {
            servicePrice = null;
        }
        if( clientPrice != null ) priceRecord = clientPrice;
        if( previousProposalPrice != null ) {
            lastProposalPriceId = previousProposalPrice.Id;
            lastProposalPrice = previousProposalPrice.Last_Proposed_Price__c;
            lastProposalId = previousProposalPrice.Last_Proposal__c;
        }
    }

}