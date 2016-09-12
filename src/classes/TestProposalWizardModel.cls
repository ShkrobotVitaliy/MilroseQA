@isTest
private class TestProposalWizardModel {
    private static final Integer NUMBER_TO_CREATE = 1;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Service_Item__c> testServiceItemList;
    private static Service_Item__c testServiceItem;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Proposal__c> testProposalList;
    private static List<Building__c> testBuildingList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Last_Proposal_Price__c> testLastProposalPrice;
    private static Region__c testRegion;
    private static Service_Template__c testServiceTemplate;
    private static Client_Price__c testClientPrice;
    private static Proposal__c testProposalDraft;
    private static String testProfile = 'TestProfile';
    private static ProposalWizardModel proposalWizModel;
    private static List<Floor__c> testFloorList;
    private static Phase__c testPhase;
    private static List<FloorWrapper> floorModels;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Additional_Reimbursable__c> testAdditionalReimbursableList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;

    private static void setUp(){
        floorModels = new List<FloorWrapper>();
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testProductionManagerUser = TestingUtils.testProductionManagerUser = TestingUtils.userWithProfile (UserServices.PROFILE_PRODUCTION_MANAGER);
        currentUserId = UserInfo.getUserId();
        testProjectTeamList = TestingUtils.createProjectTeamList (1, testProductionManagerUser.Id, projectManagerUser.Id, true);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        for (Proposal__C proposalItem : testProposalList){
            proposalItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODMILESTONE;
            proposalItem.is_Change_Order__c = true;
        }
        insert testProposalList;

        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, false);

            for (Integer i = 0; i < testProposalList.size(); i++){
                testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
                 testProjectProfileList[i].Billing_Method__c = testProposalList[i].Billing_Method__c;
            }
        insert testProjectProfileList;

            for (Integer i = 0; i < testProposalList.size(); i++){
                testProposalList[i].Project_Profile__c = testProjectProfileList[i].Id;
                testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            }
        update testProposalList;

        testProposalDraft = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE, true)[0];
        testServiceItemList = new List<Service_Item__c>();
        testChangeOrderList = new List<Change_Order__c>();
        testFloorList = new List<Floor__c>();

        for(Proposal__c proposalItem : testProposalList){
            for (Change_Order__c co : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE, false)){
                co.Proposal__c = proposalItem.Id;
                co.Project_Profile__c = proposalItem.Project_Profile__c;
                co.Apply_Reimbursable__c = true;
                co.Reimbursable_Percentage__c = 0.1;
                testChangeOrderList.add(co);
            }
            for (Service_Item__c si : TestingUtils.createServiceItemList(NUMBER_TO_CREATE, proposalItem.Id, false)){
                si.Is_Alternative__c = false;
                si.Original__c = true;
                testServiceItemList.add(si);
            }
            for (Floor__c floorItem : TestingUtils.createFloorList(2, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testChangeOrderList;

        for (Change_Order__c co : testChangeOrderList){
            for (Service_Item__c si : TestingUtils.createServiceItemList(NUMBER_TO_CREATE, co.Proposal__c, false)){
                si.Change_Order__c = co.Id;
                testServiceItemList.add(si);
            }
        }

        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, testChangeOrderList[0].Proposal__c, false)[0];
            testServiceItem.Is_Alternative__c = true;
            testServiceItem.Change_Order__c = testChangeOrderList[0].Id;
            testServiceItem.Change_Order_Old__c = testChangeOrderList[0].Id;
            testServiceItemList.add(testServiceItem);

        insert testServiceItemList;

        testServiceTemplate = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE, true)[0];
        testClientPrice = TestingUtils.createClientPriceList(NUMBER_TO_CREATE, true)[0];

        for(Floor__c item : testFloorList){
            floorModels.add(new FloorWrapper(item));
        }
        testPhase = TestingUtils.createPhaseList(NUMBER_TO_CREATE, true)[0];
        testLastProposalPrice = TestingUtils.createLastProposalPriceList(1, true);
    }

    private static void prepareAdditionalReimbursable(){
        testAdditionalReimbursableList = new List<Additional_Reimbursable__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Additional_Reimbursable__c additionalReimbursable : TestingUtils.createAdditionalReimbursableList(1, proposalItem.Id, false)){
                additionalReimbursable.Amount__c = 0.1;
                testAdditionalReimbursableList.add(additionalReimbursable);
            }
        }
        for (Change_Order__c colItem : testChangeOrderList){
            for (Additional_Reimbursable__c additionalReimbursable : TestingUtils.createAdditionalReimbursableList(1, colItem.Proposal__c, false)){
                additionalReimbursable.Change_Order__c = colItem.Id;
                additionalReimbursable.Amount__c = 0.1;
                testAdditionalReimbursableList.add(additionalReimbursable);
            }
        }
        insert testAdditionalReimbursableList;
    }

    private static void testPrepareBLI(){
        Map<Id, Project_Profile__c> proposalWithProjectProfileMap = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            proposalWithProjectProfileMap.put(projectProfileItem.Proposal__c, projectProfileItem);
        }

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        List<Service_Item__c> siUpdateList = new List<Service_Item__c>();
        for (Service_Item__c si : testServiceItemList){
            if (!si.Original__c) continue;
            Project_Profile__c projectProfileItem = proposalWithProjectProfileMap.get(si.Proposal__c);
            si.Project_Profile__c = projectProfileItem.Id;
            siUpdateList.add(si);
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList( 1, projectProfileItem.Id,
                                                                                                projectProfileItem.Billing_Company_Name__c,
                                                                                                projectProfileItem.Billing_Company_Contact__c, false)){
                billingLineItem.Amount__c = 0.3;
                billingLineItem.Service_Item__c = si.Id;
                billingLineItem.Quantity__c = 150;
                billingLineItem.Unit_Price__c = 300;

                testBillingLineItemList.add(billingLineItem);
            }
        }
        update siUpdateList;
        insert testBillingLineItemList;
    }

    private static void initiliazeClass(){
        proposalWizModel = new ProposalWizardModel( testProposalList[0], testProjectTeamList[0], testProfile, UserServices.ROLE_CZ_MANAGER);
    }

    private static testMethod void testGettersAndSetters(){
        setUp();
        prepareAdditionalReimbursable();

        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0])};

        Test.startTest();
            initiliazeClass();
        Test.stopTest();

        proposalWizModel.serviceModels = serviceModels;
        Map<String, Map<String, Decimal>> changeOrderTotalsMap = proposalWizModel.changeOrderTotalsMap;

        List<ChangeOrderModel> originalChangeOrders = proposalWizModel.originalChangeOrders;
        List<ChangeOrderModel> approvedChangeOrders = proposalWizModel.approvedChangeOrders;
        List<ChangeOrderModel> notApprovedChangeOrders = proposalWizModel.notApprovedChangeOrders;
        List<ChangeOrderModel> alternativeChangeOrders = proposalWizModel.alternativeChangeOrders;
        List<ChangeOrderModel> canceledChangeOrders = proposalWizModel.canceledChangeOrders;
        Change_Order__c dummyChangeOrder = proposalWizModel.dummyChangeOrder;
        testServiceItem.Is_Alternative__c = false;
        testServiceItem.Original__c = true;
        serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        initiliazeClass();
        testServiceItem.Is_Alternative__c = false;
        testServiceItem.Original__c = false;
        serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        initiliazeClass();
        testChangeOrderList[0].Status__c = ChangeOrderServices.STATUS_CANCELED;
        initiliazeClass();
        testChangeOrderList[0].Status__c = ChangeOrderServices.STATUS_APPROVED;
        initiliazeClass();

        proposalWizModel.updateChangeOrderReimbursableData(testChangeOrderList[0].Id);
        proposalWizModel.updateChangeOrderReimbursableData('');

        initiliazeClass();
        proposalWizModel.updateChangeOrderDiscountData(testChangeOrderList[0].Id);
        serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        try{
            proposalWizModel.updateChangeOrderDiscountData(testChangeOrderList[0].Id);
        } catch (Exception ex){}

        initiliazeClass();
        proposalWizModel.changeReceivedDocumentStatus(testChangeOrderList[0].Id);
        proposalWizModel.changeReceivedDocumentStatus('');
        proposalWizModel.updateCZAnalystEmailOnChangeOrder(testChangeOrderList[0].Id);
        proposalWizModel.updateSIPSCoordinatorOnChangeOrder(testChangeOrderList[0].Id);

        initiliazeClass();
        serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        proposalWizModel.removeServiceItems(new List<String>{String.valueOf(testServiceItem.Id)}, testChangeOrderList[0].Id);

        initiliazeClass();
        serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        proposalWizModel.deleteServiceItems(new List<String>{String.valueOf(testServiceItem.Id)}, testChangeOrderList[0].Id);
    }

    private static testMethod void testUpdateReimbursableAndDiscountData(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.updateReimbursableAndDiscountData(testProposalDraft, testAccount);
        Test.stopTest();
    }

    private static testMethod void testAddChangeOrder(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            Boolean addChangeOrder = proposalWizModel.addChangeOrder();
        Test.stopTest();
    }

    private static testMethod void testDeleteChangeOrder(){
        setUp();
        prepareAdditionalReimbursable();

        testServiceItem.Is_Amendmend_Deleted__c = true;
        update testServiceItem;
        Service_Item__c si1 = testServiceItem.clone(true, true, true, true);
        si1.Is_Amendmend_Deleted__c = true;
        si1.Id = null;
        Service_Item__c si2 = testServiceItem.clone(true, true, true, true);
        si2.Is_Amendmend_Deleted__c = false;
        si2.Id = null;
        insert new List<Service_Item__c>{si1, si2};

        initiliazeClass();
        ServiceModel serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        serviceModelItem.quantityOld = 1.1;
        ServiceModel serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        serviceModelItem1.quantityOld = null;
        ServiceModel serviceModelItem2 = new ServiceModel( si2, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        serviceModelItem2.quantityOld = null;


        proposalWizModel.serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1, si2.Id => serviceModelItem2};
        proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = new List<ServiceModel>{serviceModelItem, serviceModelItem1, serviceModelItem2};

        Test.startTest();
            Boolean deleteChangeOrder = proposalWizModel.deleteChangeOrder(testChangeOrderList[0].Id);
        Test.stopTest();
    }

    private static testMethod void testSaveChangeOrders(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            Boolean saveChangeOrders = proposalWizModel.saveChangeOrders( null );
        Test.stopTest();
    }

    private static testMethod void testCleanUpDummyChangeOrder(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.cleanUpDummyChangeOrder();
        Test.stopTest();
    }

    private static testMethod void testChangeCOStatus(){
        setUp();

        testServiceItem.Is_Amendmend_Deleted__c = true;
        testServiceItem.Service_Template__c = testServiceTemplate.Id;
        update testServiceItem;

        Service_Item__c si1 = testServiceItem.clone(true, true, true, true);
        si1.Is_Amendmend_Deleted__c = false;
        si1.Id = null;
        insert new List<Service_Item__c>{si1};

        initiliazeClass();
        ServiceModel serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );

        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1};
        proposalWizModel.serviceModels = serviceModels;
        proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = serviceModels.values();

        Test.startTest();
            Boolean addChangeOrder0 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), 'incorrect CO status', 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder1 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_DRAFT, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder2 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_REQUESTED, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder3 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_IN_CZ_REVIEW, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder4 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder5 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_IN_INT_REVIEW, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder6 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_PASSED_INT_REVIEW, 'incorrect CO old status', new List<FloorWrapper>());

            Boolean addChangeOrder8 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_FAILED_INT_REVIEW, 'incorrect CO old status', new List<FloorWrapper>());
            Boolean addChangeOrder9 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_PENDING_CLIENT, 'incorrect CO old status', new List<FloorWrapper>());

            initiliazeClass();
            serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1};
            proposalWizModel.serviceModels = serviceModels;
            proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = serviceModels.values();

            Boolean addChangeOrder10 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_APPROVED, 'incorrect CO old status', new List<FloorWrapper>());

            initiliazeClass();
            serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1};
            proposalWizModel.serviceModels = serviceModels;
            proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = serviceModels.values();

            Boolean addChangeOrder11 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_REJECTED, 'incorrect CO old status', new List<FloorWrapper>());

            initiliazeClass();
            serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
            serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1};
            proposalWizModel.serviceModels = serviceModels;
            proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = serviceModels.values();

            Boolean addChangeOrder12 = proposalWizModel.changeCOStatus(String.valueOf(testChangeOrderList[0].Id), ChangeOrderServices.STATUS_CANCELED, 'incorrect CO old status', new List<FloorWrapper>());
        Test.stopTest();

    }

    private static testMethod void testAreThereOnlyDraftCOs(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            Boolean areThereOnlyDraftCOs = proposalWizModel.areThereOnlyDraftCOs;
        Test.stopTest();
    }

    private static testMethod void testGetServiceMaxRowNumberInChangeOrder(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            Integer getServiceMaxRowNumberInChangeOrder = proposalWizModel.getServiceMaxRowNumberInChangeOrder(String.valueOf(testChangeOrderList[0].Id));
        Test.stopTest();
    }

    private static testMethod void testUpdateServiceRowPositions(){
        setUp();

        Service_Item__c si1 = testServiceItem.clone(true, true, true, true);
        si1.Is_Amendmend_Deleted__c = false;
        si1.Id = null;
        insert new List<Service_Item__c>{si1};

        initiliazeClass();
        ServiceModel serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );

        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1};
        proposalWizModel.serviceModels = serviceModels;
        proposalWizModel.changeOrderModelMap.get(testChangeOrderList[0].Id).serviceModels = serviceModels.values();

        Test.startTest();
            proposalWizModel.updateServiceRowPositions( testChangeOrderList[0].Id + ProposalWizardServices.CHANGE_ORDER_CONTENT + String.valueOf(testServiceItem.Id) + ProposalWizardServices.SERVICE_ITEM_SPLITTER + String.valueOf(si1.Id));
        Test.stopTest();
    }

    private static testMethod void testUpdateServiceClientPrices(){
        setUp();

        testClientPrice.Service__c = testServiceItem.Service_Template__c;
        testClientPrice.Client__c = testAccount.Id;
        update testClientPrice;

        testLastProposalPrice[0].Service__c = testServiceItem.Service_Template__c;
        testLastProposalPrice[0].Client__c = testAccount.Id;

        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.updateServiceClientPrices(testAccount.Id);
        Test.stopTest();
    }

    private static testMethod void testSaveServiceBundle(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            Boolean saveServiceBundle = proposalWizModel.saveServiceBundle(testChangeOrderList[0].Id, 'NY', '', String.valueOf(testRegion.Id), false);
        Test.stopTest();
    }

    private static testMethod void testGetServiceBundles(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;
        proposalWizModel.saveServiceBundle(testChangeOrderList[0].Id, 'NY', '', String.valueOf(testRegion.Id), false);

        Test.startTest();
            List<Service_Bundle__c> getServiceBundles = proposalWizModel.getServiceBundles('NY');
        Test.stopTest();
    }

    private static testMethod void testDocumentWrapperList(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            List<DocumentWrapper> documentWrapperList = proposalWizModel.documentWrapperList;
        Test.stopTest();
    }

    private static testMethod void testPopulateDocumentWrapperList(){
        setUp();
        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] )};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.populateDocumentWrapperList(testProposalDraft);
        Test.stopTest();
    }

    private static testMethod void testIsQuantityChangeNeedsConfirmation(){
        setUp();
        testPrepareBLI();
        Id testServiceItemId = testBillingLineItemList[0].Service_Item__c;

        initiliazeClass();
        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>();
        for (Service_Item__c si : testServiceItemList){
            serviceModels.put(si.Id, new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] ));
        }
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.isQuantityChangeNeedsConfirmation('10', '20', String.valueOf(testServiceItemId), true);
            proposalWizModel.isQuantityChangeNeedsConfirmation('10', '20', String.valueOf(testServiceItemId), false);
            try{
                proposalWizModel.isQuantityChangeNeedsConfirmation('incorrect decimal', '20', String.valueOf(testServiceItemId), false);
            } catch (Exception ex){}
            proposalWizModel.cancelQuantityChangeInServiceModel('20', String.valueOf(testServiceItemId), true);
            proposalWizModel.cancelQuantityChangeInServiceModel('20', String.valueOf(testServiceItemId), false);
        Test.stopTest();
    }

    private static testMethod void testChangeQuantityInServiceModel(){
        setUp();

        Service_Item__c si1 = testServiceItem.clone(true, true, true, true);
        si1.Id = null;
        Service_Item__c si2 = testServiceItem.clone(true, true, true, true);
        si2.Id = null;
        si2.Change_Order__c = null;
        insert new List<Service_Item__c>{si1, si2};

        initiliazeClass();
        ServiceModel serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem2 = new ServiceModel( si2, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );

        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1, si2.Id => serviceModelItem2};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.changeQuantityInServiceModel('10', '20', new List<String>{String.valueOf(testServiceItem.Id)}, String.valueOf(testServiceItem.Change_Order__c), true);
            proposalWizModel.changeQuantityInServiceModel('10', '20', new List<String>{String.valueOf(testServiceItem.Id)}, String.valueOf(testServiceItem.Change_Order__c), false);
            proposalWizModel.changeQuantityInServiceModel('10', '20', new List<String>{String.valueOf(testServiceItem.Id)}, null, false);
            proposalWizModel.changeQuantityInServiceModel('10', '20', new List<String>{String.valueOf(testServiceItem.Id)}, String.valueOf(testServiceItem.Change_Order__c), true, true);
        Test.stopTest();
    }

    private static testMethod void testManageServiceFloorJunctions(){
        setUp();

        Service_Item__c si1 = testServiceItem.clone(true, true, true, true);
        si1.Id = null;
        Service_Item__c si2 = testServiceItem.clone(true, true, true, true);
        si2.Id = null;
        si2.Change_Order__c = null;
        insert new List<Service_Item__c>{si1, si2};

        List<String> floorListId = new List<String>();
        for (Floor__c floorItem : testFloorList){
            if (floorItem.Proposal__c == testServiceItem.Proposal__c){
                floorListId.add(String.valueOf(floorItem.Id));
            }
        }
        List<Service_Floor_Junction__c> tmpSFJList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            if (floorItem.Proposal__c == testServiceItem.Proposal__c){
                floorListId.add(String.valueOf(floorItem.Id));
                tmpSFJList.add(TestingUtils.createServiceFloorJunctionList(1, testServiceItem.Id, floorItem.Id, false)[0]);
            }
        }
        insert tmpSFJList;

        String floorIdsString = String.join(floorListId, ';');
        String serviceIdsString = String.valueOf(testServiceItem.Id) + ';' + String.valueOf(si1.Id) + ';' + String.valueOf(si2.Id);

        initiliazeClass();
        ServiceModel serviceModelItem = new ServiceModel( testServiceItem, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem1 = new ServiceModel( si1, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );
        ServiceModel serviceModelItem2 = new ServiceModel( si2, testServiceTemplate, testClientPrice, testLastProposalPrice[0] );

        Map<Id, ServiceModel> serviceModels = new Map<Id, ServiceModel>{testServiceItem.Id => serviceModelItem, si1.Id => serviceModelItem1, si2.Id => serviceModelItem2};
        proposalWizModel.serviceModels = serviceModels;

        Test.startTest();
            proposalWizModel.manageServiceFloorJunctions('', null, null, new List<FloorWrapper>());
            try{
                proposalWizModel.manageServiceFloorJunctions(serviceIdsString, null, null, new List<FloorWrapper>());
            } catch (Exception ex){}
            proposalWizModel.manageServiceFloorJunctions(serviceIdsString, floorIdsString, floorIdsString, floorModels);
            ProposalWizardModel.updateRestOfServiceAndJunctions(testProposalList[0].Id);
        Test.stopTest();

    }
}