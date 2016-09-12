@isTest
private class TestChangeOrderModel {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static Proposal__c testProposal;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Team__c> testProjectTeamList;
    private static Proposal__c testProposalDraft;
    private static User adminUser;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;
    private static ChangeOrderModel changeOrdMod;
    private static String testProfile = 'TestProfile';
    private static Change_Order__c testChangeOrder;
    private static Project_Profile__c testProjectProfile;
    private static Service_Template__c testServiceTemplateItem;
    private static Service_Item__c testServiceItem;
    private static Floor__c testFloor;
    private static Client_Price__c testClientPrice;

    private static void setUp(){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testProductionManagerUser = TestingUtils.userWithProfile (UserServices.PROFILE_PRODUCTION_MANAGER);
        currentUserId = UserInfo.getUserId();
        testProjectTeamList = TestingUtils.createProjectTeamList(1, testProductionManagerUser.Id, projectManagerUser.Id, true);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProposal = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id, null,
                                                            null, null, null, partnerUser.Id, currentUserId, projectManagerUser.id, true)[0];
        testProposalDraft = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE, true)[0];
        testProjectProfile = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, null, testContact.id, null, null, null, null, projectManagerUser.id, true)[0];
        testChangeOrder = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE, false)[0];
            //testChangeOrder.CreatedDate = Date.today();
            testChangeOrder.Approved_Date__c = Date.today();
            testChangeOrder.Status__c = 'Draft';
            testChangeOrder.Project_Profile__c = testProjectProfile.Id;
            testChangeOrder.Proposal__c = testProposal.Id;
            testChangeOrder.Services_Total__c = 15;
            testChangeOrder.Number__c = Double.valueOf(5);
            testChangeOrder.Internal_Reviewer__c = partnerUser.Id;
            testChangeOrder.Internal_Reviewer_Reminder__c = Date.today();
            insert testChangeOrder;
        testServiceTemplateItem = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE, true)[0];
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, testProposal.Id, false)[0];
            testServiceItem.Is_Amendmend_Deleted__c = true;
            testServiceItem.Shredding_Fees__c = 5;
            testServiceItem.Service_Template__c = testServiceTemplateItem.Id;
            insert testServiceItem;
        testFloor = testingUtils.createFloorList(NUMBER_TO_CREATE, true)[0];
        testClientPrice = TestingUtils.createClientPriceList(NUMBER_TO_CREATE, true)[0];

    }

    private static void initiliazeChangeOrderModel(){
        testChangeOrder = [ SELECT Id,Approved_Date__c, Status__c, Project_Profile__c, Proposal__c, Services_Total__c, Number__c, Internal_Reviewer__c,
                                    Internal_Reviewer_Reminder__c, CreatedDate, SIPS_Coordinator__c, Reminder_for_Creator__c, Change_Request_Date__c, Document_Type__c
                            FROM Change_Order__c ];
        changeOrdMod = new ChangeOrderModel( testChangeOrder, testProfile, UserServices.ROLE_CZ_MANAGER, currentUserId, testProposal, true, testProjectTeamList[0], true, true, true );
    }

    private static testMethod void testGettersAndSetters(){
        setUp();

        Test.startTest();
            initiliazeChangeOrderModel();
        Test.stopTest();

        System.assert(changeOrdMod != null);

        Change_Order__c changeOrderRecord = changeOrdMod.changeOrderRecord;
        List<ServiceModel> serviceModels = changeOrdMod.serviceModels;
        Boolean isOriginal = changeOrdMod.isOriginal;
        Boolean isAlternative = changeOrdMod.isAlternative;
//        Date approvedDate = changeOrdMod.approvedDate;
//        Date createdDate = changeOrdMod.createdDate;
//        Boolean isActive = changeOrdMod.isActive;
//      Id projectId = changeOrdMod.projectId;
//      Id proposalId = changeOrdMod.proposalId;
//      Id changeOrderId = changeOrdMod.changeOrderId;
        Decimal servicesTotal = changeOrdMod.getServicesTotal();
        Decimal servicesTotalDiscounted = changeOrdMod.getServicesTotalDiscounted();
        Decimal servicesTotalSalesTax = changeOrdMod.getServicesTotalSalesTax();
//        Integer changeOrderNumber = changeOrdMod.changeOrderNumber;

//      String profileName = changeOrdMod.profileName;
        String status = changeOrdMod.status;
//      Id userId = changeOrdMod.userId;
        Id internalReviewer = changeOrdMod.internalReviewer;
        DateTime internalReviewerReminder = changeOrdMod.internalReviewerReminder;
//      Id proposalCreator = changeOrdMod.proposalCreator;
        String proposalStatus = changeOrdMod.proposalStatus;
//      Boolean proposalIsChangeOrder = changeOrdMod.proposalIsChangeOrder;
//      String changeOrderIdForCells = changeOrdMod.changeOrderIdForCells;
        Id internalReviewerForCells = changeOrdMod.internalReviewerForCells;
        Boolean isMaxCompleteness = changeOrdMod.isMaxCompleteness;


        // Buttons markers
        Boolean showMoveServices = changeOrdMod.showMoveServices;
        Boolean showRemoveChangeOrder = changeOrdMod.showRemoveChangeOrder;
        Boolean showSaveServiceBundle = changeOrdMod.showSaveServiceBundle;
        Boolean showAddNewService = changeOrdMod.showAddNewService;
        Boolean showInsertServiceBundle = changeOrdMod.showInsertServiceBundle;
        Boolean showSubmitCORequest = changeOrdMod.showSubmitCORequest;
        Boolean showCancelCORequest = changeOrdMod.showCancelCORequest;
        Boolean showSendForCZReview = changeOrdMod.showSendForCZReview;
        Boolean showComplete = changeOrdMod.showComplete;
        Boolean showSendForInternalReview = changeOrdMod.showSendForInternalReview;
        Boolean showSendToClient = changeOrdMod.showSendToClient;
        Boolean showApproveChangeOrderIR = changeOrdMod.showApproveChangeOrderIR;
        Boolean showApproveChangeOrderPS = changeOrdMod.showApproveChangeOrderPS;
        Boolean showRejectChangeOrderIR = changeOrdMod.showRejectChangeOrderIR;
        Boolean showRejectChangeOrderPS = changeOrdMod.showRejectChangeOrderPS;

        Boolean enableRemoveChangeOrder = changeOrdMod.enableRemoveChangeOrder;
        Boolean enableSaveServiceBundle = changeOrdMod.enableSaveServiceBundle;
        Boolean enableAddNewService = changeOrdMod.enableAddNewService;
        Boolean enableInsertServiceBundle = changeOrdMod.enableInsertServiceBundle;
        Boolean enableSubmitCORequest = changeOrdMod.enableSubmitCORequest;
        Boolean enableCancelCORequest = changeOrdMod.enableCancelCORequest;
        Boolean enableSendForCZReview = changeOrdMod.enableSendForCZReview;
        Boolean enableComplete = changeOrdMod.enableComplete;
        Boolean enableSendForInternalReview = changeOrdMod.enableSendForInternalReview;
        Boolean enableSendToClient = changeOrdMod.enableSendToClient;
        Boolean enableApproveChangeOrderIR = changeOrdMod.enableApproveChangeOrderIR;
        Boolean enableApproveChangeOrderPS = changeOrdMod.enableApproveChangeOrderPS;
        Boolean enableRejectChangeOrderIR = changeOrdMod.enableRejectChangeOrderIR;
        Boolean enableRejectChangeOrderPS = changeOrdMod.enableRejectChangeOrderPS;
        Boolean enableOriginalApprovedCO = changeOrdMod.enableOriginalApprovedCO;
        // End Buttons markers

        // Cells markers
        Boolean isPhasesVisible = changeOrdMod.isPhasesVisible;
        Boolean isFloorsVisible = changeOrdMod.isFloorsVisible;
        Boolean isServiceGroupVisible = changeOrdMod.isServiceGroupVisible;
        Boolean isPurchaseOrderVisible = changeOrdMod.isPurchaseOrderVisible;
        Boolean isMunicipalAgencyVisible = changeOrdMod.isMunicipalAgencyVisible;
        Boolean isUnitOfServiceVisible = changeOrdMod.isUnitOfServiceVisible;
        Boolean isQuantityVisible = changeOrdMod.isQuantityVisible;
        Boolean isUnitPriceVisible = changeOrdMod.isUnitPriceVisible;
        Boolean isLastPriceVisible = changeOrdMod.isLastPriceVisible;
        Boolean isTotalPriceVisible = changeOrdMod.isTotalPriceVisible;
        Boolean isActivityStatusVisible = changeOrdMod.isActivityStatusVisible;
        Boolean isRemoveVisible = changeOrdMod.isRemoveVisible;
        // End Cells markers

        // Boolean geters
        showMoveServices = changeOrdMod.getShowMoveServices();
        showRemoveChangeOrder = changeOrdMod.getShowRemoveChangeOrder();
        showSaveServiceBundle = changeOrdMod.getShowSaveServiceBundle();
        showAddNewService = changeOrdMod.getShowAddNewService();
        showInsertServiceBundle = changeOrdMod.getShowInsertServiceBundle();
        showSubmitCORequest = changeOrdMod.getShowSubmitCORequest();
        showCancelCORequest = changeOrdMod.getShowCancelCORequest();
        showSendForCZReview = changeOrdMod.getShowSendForCZReview();
        showComplete = changeOrdMod.getShowComplete();
        showSendForInternalReview = changeOrdMod.getShowSendForInternalReview();
        showSendToClient = changeOrdMod.getShowSendToClient();
        showApproveChangeOrderIR = changeOrdMod.getShowApproveChangeOrderIR();
        showApproveChangeOrderPS = changeOrdMod.getShowApproveChangeOrderPS();
        showRejectChangeOrderIR = changeOrdMod.getShowRejectChangeOrderIR();
        showRejectChangeOrderPS = changeOrdMod.getShowRejectChangeOrderPS();

        enableRemoveChangeOrder = changeOrdMod.getEnableRemoveChangeOrder();
        enableSaveServiceBundle = changeOrdMod.getEnableSaveServiceBundle();
        enableAddNewService = changeOrdMod.getEnableAddNewService();
        enableInsertServiceBundle = changeOrdMod.getEnableInsertServiceBundle();
        enableSubmitCORequest = changeOrdMod.getEnableSubmitCORequest();
        enableCancelCORequest = changeOrdMod.getEnableCancelCORequest();
        enableSendForCZReview = changeOrdMod.getEnableSendForCZReview();
        enableComplete = changeOrdMod.getEnableComplete();
        enableSendForInternalReview = changeOrdMod.getEnableSendForInternalReview();
        enableSendToClient = changeOrdMod.getEnableSendToClient();
        enableApproveChangeOrderIR = changeOrdMod.getEnableApproveChangeOrderIR();
        enableApproveChangeOrderPS = changeOrdMod.getEnableApproveChangeOrderPS();
        enableRejectChangeOrderIR = changeOrdMod.getEnableRejectChangeOrderIR();
        enableRejectChangeOrderPS = changeOrdMod.getEnableRejectChangeOrderPS();
        enableOriginalApprovedCO = changeOrdMod.getEnableOriginalApprovedCO();

        isPhasesVisible = changeOrdMod.getIsPhasesVisible();
        isFloorsVisible = changeOrdMod.getIsFloorsVisible();
        isServiceGroupVisible = changeOrdMod.getIsServiceGroupVisible();
        isPurchaseOrderVisible = changeOrdMod.getIsPurchaseOrderVisible();
        isMunicipalAgencyVisible = changeOrdMod.getIsMunicipalAgencyVisible();
        isUnitOfServiceVisible = changeOrdMod.getIsUnitOfServiceVisible();
        isQuantityVisible = changeOrdMod.getIsQuantityVisible();
        isUnitPriceVisible = changeOrdMod.getIsUnitPriceVisible();
        isLastPriceVisible = changeOrdMod.getIsLastPriceVisible();
        isTotalPriceVisible = changeOrdMod.getIsTotalPriceVisible();
        isActivityStatusVisible = changeOrdMod.getIsActivityStatusVisible();
        isRemoveVisible = changeOrdMod.getIsRemoveVisible();
        // End Boolean getters

    }

    private static testMethod void testAddServiceModel(){
        setUp();
        List<ServiceModel> serviceModelList = new List<ServiceModel>();
            serviceModelList.add(new ServiceModel(testServiceTemplateItem,testClientPrice));
        initiliazeChangeOrderModel();

        System.assert(changeOrdMod != null);

        Test.startTest();
            changeOrdMod.addServiceModel(serviceModelList);
        Test.stopTest();
    }

    private static testMethod void testSortServiceModel(){
        setUp();
        List<ServiceModel> serviceModelList = new List<ServiceModel>();
            serviceModelList.add(new ServiceModel ( testServiceItem,
                                                    testServiceTemplateItem,
                                                    testClientPrice,
                                                    TestingUtils.createLastProposalPriceList(1, true)[0]));
        initiliazeChangeOrderModel();
        changeOrdMod.addServiceModel(serviceModelList);

        System.assert(changeOrdMod != null);

        Test.startTest();
            changeOrdMod.sortSeviceModels();
        Test.stopTest();
    }

    private static testMethod void testGetChangeOrder(){
        setUp();
        initiliazeChangeOrderModel();

        System.assert(changeOrdMod != null);

        Test.startTest();
            changeOrdMod.getChangeOrder(testProposal, false);
        Test.stopTest();
    }

    private static testMethod void testUpsertChangeOrder(){
        setUp();
        initiliazeChangeOrderModel();

        System.assert(changeOrdMod != null);

        Test.startTest();
            changeOrdMod.getChangeOrder(testProposal, true);
        Test.stopTest();
    }
}