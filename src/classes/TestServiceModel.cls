@isTest
private class TestServiceModel {
    private static final Integer NUMBER_TO_CREATE = 1;
    private static ServiceModel sModel;
    private static ServiceModel secondSModel;
    private static Project_Profile__c testProjectProfile;
    private static Service_Item__c testServiceItem;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId; 
    private static Account testAccount;
    private static Contact testContact;
    private static List<Proposal__c> testProposalList;
    private static Change_Order__c testChangeOrder;
    private static List<Building__c> testBuildingList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static Region__c testRegion;
    private static Service_Template__c testServiceTemplate;
    private static Service_Template__c testServiceTemplateItem;
    private static Client_Price__c testClientPrice;
    private static List<Floor__c> testFloorList;
    private static Phase__c testPhase;
    private static List<FloorWrapper> floorModels;
    private static Proposal__c testProposalDraft;
    private Static Last_Proposal_Price__c previousProposalPrice;


    private static void setUp(){
        floorModels = new List<FloorWrapper>();
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true)[0];
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
        testChangeOrder = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE, false)[0];
            testChangeOrder.Approved_Date__c = Date.today();
            testChangeOrder.Status__c = 'Draft';
            testChangeOrder.Project_Profile__c = testProjectProfile.Id;
            testChangeOrder.Proposal__c = testProposalList[0].Id;
            testChangeOrder.Services_Total__c = 15;
            testChangeOrder.Number__c = Double.valueOf(5);
            testChangeOrder.Internal_Reviewer__c = partnerUser.Id;
            testChangeOrder.Internal_Reviewer_Reminder__c = Date.today();
        insert testChangeOrder;
        
        testProposalDraft = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE, true)[0];
        testServiceTemplateItem = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE, true)[0];
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, testProposalList[0].Id, false)[0];
        testServiceItem.Service_Template__c = testServiceTemplateItem.Id;
        insert testServiceItem;

        testServiceTemplate = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE, true)[0];
        testClientPrice = TestingUtils.createClientPriceList(NUMBER_TO_CREATE, true)[0];
        testFloorList = TestingUtils.createFloorList(NUMBER_TO_CREATE, true);
        previousProposalPrice = new Last_Proposal_Price__c();
        for(Floor__c item : testFloorList){
            floorModels.add(new FloorWrapper(item));
        }
        testPhase = TestingUtils.createPhaseList(NUMBER_TO_CREATE, true)[0];
           
    }
    
    private static void initiliazeClass(){
        sModel = new ServiceModel(testServiceTemplate,testClientPrice); 
        
    }
    private static void initiliazeSecondSModelClass(){
        secondSModel = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, previousProposalPrice );
    }
    private static testMethod void testGettersAndSetters(){
        setUp();
        
        
        Test.startTest();
            initiliazeClass();          
        Test.stopTest();
        testServiceItem.Actual_End_Date__c  = Date.today();
        update testServiceItem;

        Integer rowNumber = sModel.rowNumber;
        Id      changeOrderId = sModel.changeOrderId;
        Id      changeOrderOldId = sModel.changeOrderOldId;
        Id      recordId = sModel.recordId;
        sModel.isTemplate = false;
        Boolean isTemplate = sModel.isTemplate;
        Boolean pendingPhaseSaveTest = sModel.pendingPhaseSave;
        Boolean testgetPendingPhaseSave = sModel.getPendingPhaseSave();
        String  serviceGroup = sModel.serviceGroup;
        String  unitOfService = sModel.unitOfService;
        String  municipalAgency = sModel.municipalAgency;
        Boolean isAlternative = sModel.isAlternative;
        Boolean isOriginal = sModel.isOriginal;
        Decimal discount = sModel.discount;
        Boolean isAddedToPurchaseOrder = sModel.isAddedToPurchaseOrder;
        Boolean checked = sModel.checked;
        Boolean pendingPhaseSave = sModel.pendingPhaseSave;
        String  phaseId = sModel.phaseId;
        Decimal totalServicePriceOld = sModel.totalServicePriceOld;
        Boolean hasClientPrice = sModel.hasClientPrice;
        // Temporary comented due to development needs
        smodel.quantity = 10;
        smodel.quantityOld = 100;        
        String  purchaseOrderNumber = sModel.purchaseOrderNumber;
        Decimal totalServicePrice = sModel.totalServicePrice;
        Decimal totalDiscountedServicePrice = sModel.getTotalDiscountedServicePrice();
        Decimal servicePrice = sModel.servicePrice;
        Decimal quantity = sModel.quantity;
        smodel.isAmendmendDeleted = true;
        String activityStatus = sModel.activityStatus;
        smodel.isAmendmendDeleted = false;
        String activityStatus1 = sModel.activityStatus;

        smodel.servicePrice = 10.055;
        smodel.servicePriceStr = '100.0055';
        String servicePriceStr = sModel.servicePriceStr; 

        smodel.quantityDiff = 10.055;
        smodel.quantityDiffStr = '100.055';

        String quantityDiffStr = sModel.quantityDiffStr;
        smodel.quantityOldStr = '101';
        String quantityOldStr = sModel.quantityOldStr;

        sModel.quantityStr = '99';
        String quantityStr = sModel.quantityStr;

        Decimal getTotalDiscountedServicePriceOld = sModel.getTotalDiscountedServicePriceOld();
        Boolean isAmendmendAdded = sModel.isAmendmendAdded;
        //Temporary comented due to development needs
        Decimal getTotalServicePriceDiff = sModel.getTotalServicePriceDiff();
        Decimal getTotalDiscountedServicePriceDiff = sModel.getTotalDiscountedServicePriceDiff();
        Decimal getSalesTaxOld = sModel.getSalesTaxOld();
        Decimal getSalesTaxDiff = sModel.getSalesTaxDiff();
        smodel.quantity = 10;
        smodel.quantityOld = 110;
        Decimal quantityDiff = sModel.quantityDiff;
        
        Boolean getIsQuantityChangeOrder = sModel.getIsQuantityChangeOrder();

        Boolean isServiceGroupRequired = sModel.getIsServiceGroupRequired() ;
        Boolean isUnitPriceRequired = sModel.getIsUnitPriceRequired() ;

        smodel.IsFloorsEditable = true;
        smodel.isPurchaseOrderEditable = true;
        smodel.isServiceGroupEditable = true;

        smodel.profileName = UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN;
        smodel.userRoleName = 'test role';
        smodel.proposalStatus = ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
        smodel.proposalIsChangeOrder = true;
        smodel.changeOrderIdForCells = testChangeOrder.Id;
        smodel.status = 'test status';
        smodel.userId = userinfo.getuserid();
        smodel.internalReviewerForCells = userinfo.getuserid();
        smodel.proposalCreator = userinfo.getuserid();
        smodel.isMi3 = true;
        smodel.isProductionManager = true;
        smodel.isSsmOrOmOrSscOwner = true;
        smodel.isAssignedCZAnalyst = true;
        smodel.isAssignedSIPS = true;
        smodel.isChangeOrderAllowedOnProjectOrServiceItemLevel = true;
        smodel.canCreateNewCo = true;
        
        Boolean testgetIsFloorsEditable = smodel.getIsFloorsEditable();
        Boolean testgetIsPhasesEditable = smodel.getIsPhasesEditable();
        Boolean testisServiceGroupEditable = sModel.getIsServiceGroupEditable();
       
        Boolean testisServiceGroupRequired = sModel.getIsServiceGroupRequired() ;
        Boolean testisPurchaseOrderEditable = sModel.getIsPurchaseOrderEditable();
        Boolean testisMunicipalAgencyEditable = sModel.getIsMunicipalAgencyEditable();
        Boolean testisQuantityEditable= sModel.getIsQuantityEditable();
        Boolean testisRemoveEditable = sModel.getIsRemoveEditable() ;
        Boolean testisUnitPriceEditable = sModel.getIsUnitPriceEditable();
        Boolean testgetIsQuantityEditableForSIPS = sModel.getIsQuantityEditableForSIPS();
        
        Boolean isAmendmendDeleted = sModel.isAmendmendDeleted;
        
        String servicePriceStr1 = sModel.servicePriceStr;    
        
        sModel.isAmendmendDeleted = true;
        sModel.isAlternative = true;
        Decimal salesTax = sModel.getSalesTax();
    }
    
    private static testMethod void testGetServiceItem(){
        setUp();
        initiliazeSecondSModelClass();
        
        Test.startTest();
            secondSModel.getServiceItem(true);
        Test.stopTest();
    }
}