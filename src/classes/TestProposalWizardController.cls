@isTest
private class TestProposalWizardController {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 4;
    private static final Integer NUMBER_TO_CREATE_PHASE = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_FLOOR = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 1;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 1;
    private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Floor__c> testFloorList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Proposal__c> testProposalDraftList;
    private static List<Phase__c> testPhaseList;
    private static List<Client_Price__c> testClientPriceList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static List<Service_Bundle__c> testServiceBundleList;
    private static List<Service_Bundle_Item__c> testServiceBundleItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Id projectRosterUserRecordTypeId;
    private static Id serviceTemplateAPSRecordTypeId;
    private static Id serviceTemplateOSRecordTypeId;

    private static PageReference testPage;
    private static ProposalWizardController testController;
    private static ApexPages.StandardController testStandardController;

    private static List<String> projectRosterRoleValuesList;

    private static void prepareRecordTypePickListValuesForTest(){
        //prepare Project Roster Record Type
        Map<String, Id> projectRosterRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Project_Roster__c');
        for (String projectRosterRecordTypeNameValue : projectRosterRecordTypesMap.keySet()){
            if (projectRosterRecordTypeNameValue == 'User') {
                projectRosterUserRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
                break;
            }
        }
        projectRosterRoleValuesList = new List<String>();
        for (Schema.PicklistEntry ple : Project_Roster__c.Role__c.getDescribe().getPicklistValues()){
            projectRosterRoleValuesList.add(ple.getValue());
        }
        //prepare Srvice Template RecordType
        serviceTemplateAPSRecordTypeId = TestingUtils.getRecordTypeNameIdByObjecttypename('Service_Template__c').get('Application & Permit Services');
        serviceTemplateOSRecordTypeId = TestingUtils.getRecordTypeNameIdByObjecttypename('Service_Template__c').get('Other Services');
    }

    private static void setupData (){
        prepareRecordTypePickListValuesForTest();
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void prepareServiceTemplate(){
        testServiceTemplateList = new List<Service_Template__c>();
        for (Region__c regionItem : testRegionList){
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(1, false)){
                serviceTemplateItem.Category__c = 'test category';
                serviceTemplateItem.Type__c = 'test type';
                serviceTemplateItem.Subtype__c = 'test subtype';
                serviceTemplateItem.Plan_Submission_Type__c = 'test plan submission';
                serviceTemplateItem.Region__c = regionItem.Id;
                serviceTemplateItem.Service_Row_Number__c = serviceTemplateItem.Service_Name_Full__c = 'APS30';
                serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
                testServiceTemplateList.add(serviceTemplateItem);
            }
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(1, false)){
                serviceTemplateItem.Category__c = 'test category';
                serviceTemplateItem.Type__c = 'test type';
                serviceTemplateItem.Subtype__c = 'test subtype';
                serviceTemplateItem.Plan_Submission_Type__c = 'test plan submission';
                serviceTemplateItem.Region__c = regionItem.Id;
                serviceTemplateItem.Service_Row_Number__c = serviceTemplateItem.Service_Name_Full__c = 'APS76';
                serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
                testServiceTemplateList.add(serviceTemplateItem);
            }
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(1, false)){
                serviceTemplateItem.Category__c = 'test category';
                serviceTemplateItem.Type__c = 'test type';
                serviceTemplateItem.Subtype__c = 'test subtype';
                serviceTemplateItem.Plan_Submission_Type__c = 'test plan submission';
                serviceTemplateItem.Region__c = regionItem.Id;
                serviceTemplateItem.Service_Row_Number__c = serviceTemplateItem.Service_Name_Full__c = 'APS32';
                serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
                testServiceTemplateList.add(serviceTemplateItem);
            }
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(1, false)){
                serviceTemplateItem.Category__c = 'test category';
                serviceTemplateItem.Type__c = 'test type';
                serviceTemplateItem.Subtype__c = 'test subtype';
                serviceTemplateItem.Plan_Submission_Type__c = 'test plan submission';
                serviceTemplateItem.Region__c = regionItem.Id;
                serviceTemplateItem.Service_Row_Number__c = serviceTemplateItem.Service_Name_Full__c = 'OS13';
                serviceTemplateItem.RecordTypeId = serviceTemplateOSRecordTypeId;
                testServiceTemplateList.add(serviceTemplateItem);
            }
        }
        insert testServiceTemplateList;

        testClientPriceList = new List<Client_Price__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Account accountItem : testAccountList){
                for (Client_Price__c clientPriceItem : TestingUtils.createClientPriceList(1, false)){
                    clientPriceItem.Medium_Price__c = 123.45;
                    clientPriceItem.Service__c = serviceTemplateItem.Id;
                    clientPriceItem.Client__c = accountItem.Id;
                    testClientPriceList.add(clientPriceItem);
                }
            }
        }
        insert testClientPriceList;
    }

    private static void createServiceBundleForTest(){
        testServiceBundleList = new List<Service_Bundle__c>();
        for (Region__c regionItem : testRegionList){
            for (Service_Bundle__c serviceBundle : TestingUtils.createServiceBundleList(1, null, false)){
                serviceBundle.Region__c = regionItem.Name;
                testServiceBundleList.add(serviceBundle);
            }
        }
        insert testServiceBundleList;

        testServiceBundleItemList = new List<Service_Bundle_Item__c>();
        for (Service_Bundle__c serviceBundle : testServiceBundleList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Bundle_Item__c serviceBundleItem : TestingUtils.createServiceBundleItemList(serviceTemplateItem.Id, serviceBundle.Id, false)){
                    testServiceBundleItemList.add(serviceBundleItem);
                }
            }
        }
        insert testServiceBundleItemList;
    }

    private static void createProposalsForTest(Integer numberToCreate, Boolean doInsert){
        testProposalList = TestingUtils.createProposalList (numberToCreate, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);

        if(doInsert){
            insert testProposalList;
        }
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;
        }
        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static void preparePageController (Proposal__c proposalForStandardController, Id proposalDraftId){
        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        if (proposalDraftId != null){
            ApexPages.currentPage().getParameters().put('draftid', String.valueOf(proposalDraftId));
        }
        if (proposalForStandardController != null) {
            testStandardController = new ApexPages.standardController(proposalForStandardController);
            ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(proposalForStandardController.Address__c));
        } else {
            testStandardController = new ApexPages.standardController(new Proposal__c());
        }
        testController = new ProposalWizardController(testStandardController);
    }

    private static testmethod void testInitControllerWithProposalDraft(){
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        for (Proposal__c proposalItem : testProposalDraftList){
            proposalItem.Provided_Documents__c = true;
            proposalItem.Provided_Drawings__c = true;
        }

        Test.startTest();
            preparePageController (null, testProposalDraftList[0].Id);
        Test.stopTest();

        System.assert(testController != null);
    }

    private static testmethod void testInitControllerWithProposal(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;
        setupData ();
        Building_AKA__c testBuildingAKA = new Building_AKA__c(Building__c = testBuildingList[0].Id);
        insert testBuildingAKA;
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testChangeOrderList = new List<Change_Order__c>();
        testFloorList = new List<Floor__c>();
        testPhaseList = new List<Phase__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c co : TestingUtils.createChangeOrderList(1, false)){
                co.Proposal__c = proposalItem.Id;
                testChangeOrderList.add(co);
            }
            for (Floor__c floorItem : TestingUtils.createFloorList(1, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
            for (Phase__c phaseItem : TestingUtils.createPhaseList(1, false)){
                phaseItem.Proposal__c = proposalItem.Id;
                phaseItem.Number__c = 1;
                phaseItem.Start_Date__c = Date.today();
                testPhaseList.add(phaseItem);
            }
        }
        insert testChangeOrderList;
        insert testFloorList;
        insert testPhaseList;

        Service_Item__c si = TestingUtils.createServiceItemList(1, testProposalList[0].Id, false)[0];
        si.Change_Order__c = testChangeOrderList[0].Id;
        si.Quantity_Old__c = null;
        insert si;

        List<Service_Floor_Junction__c> testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            for (Service_Floor_Junction__c sfjItem : TestingUtils.createServiceFloorJunctionList(1, si.Id, floorItem.Id, false)){
                testServiceFloorJunctionList.add(sfjItem);
            }
        }
        insert testServiceFloorJunctionList;

        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('co', String.valueOf(testChangeOrderList[0].Id));
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        Test.startTest();
            System.assert(testController != null);

            Boolean testBoolean;
            testBoolean = testController.approveChangeOrderBeforeRedirectBillingTriggers() == null;
            testBoolean = testController.redirectBillingTriggers() == null;
            testBoolean = testController.addErrorMessageRedirectTriggers() == null;
            testBoolean = ProposalWizardController.checkNewTasksExistance(String.valueOf(testChangeOrderList[0].Id)) == null;
            testBoolean = testController.getUserName() == null;
            testBoolean = testController.setUserName('test name') == null;
            testBoolean = testController.getBuilding_AKA_Id() == null;
            testBoolean = testController.setBuilding_AKA_Id(String.valueOf(testBuildingAKA.Id)) == null;
            testBoolean = testController.getBuildingAKAs() == null;
            testBoolean = testController.getPrimaryContacts() == null;
            testBoolean = testController.getBillingContacts() == null;
            testBoolean = testController.getAccountingContacts() == null;
            testBoolean = testController.getPartners() == null;
            testBoolean = testController.getAccountManagers() == null;
            testBoolean = testController.getSalespersons() == null;
            testBoolean = testController.getCZAnalysts() == null;
            testBoolean = testController.getSipsCoordinators() == null;
            testBoolean = testController.getFulfillmentOffices() == null;
            testBoolean = testController.getDeliveryMethods() == null;
            testBoolean = testController.getBillingMethods() == null;
            testBoolean = testController.getFrequencies() == null;
            testBoolean = testController.getQuarterlyMonths() == null;
            testBoolean = testController.getBillingDaysAllPossible()  == null;
            testBoolean = testController.getInvoiceFormats() == null;
            testBoolean = testController.getProposalTypes() == null;
            String tmpPropType = testController.proposal.Proposal_Type__c;
            testController.proposal.Proposal_Type__c = ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER;
            testBoolean = testController.getProposalTypes() == null;
            testController.proposal.Proposal_Type__c = tmpPropType;
            testBoolean = testController.getOriginalChangeOrderKey() == null;
            testBoolean = testController.getAlternativeChangeOrderKey() == null;
            testBoolean = testController.getServiceInfo() == null;
            testBoolean = testController.rFPAttachmentsOption == null;
            testBoolean = testController.rosterContactsOption == null;
            testBoolean = testController.chosenPhase == null;
            testBoolean = testController.getRenderQuarterlyMonthPicklist() == null;
            testBoolean = testController.getRenderBillingDayPicklist() == null;
            testBoolean = testController.getChangeOrderSplitter() == null;
            testBoolean = testController.getChangeOrderContent() == null;
            testBoolean = testController.getServiceItemSplitter() == null;
            testBoolean = testController.changeProposalReceivedDocumentStatus() == null;
            testBoolean = testController.changeCOReceivedDocumentStatus() == null;
            testBoolean = testController.getChangeOrderReimbursableMap() == null;
            testBoolean = testController.reimbursableToCreate == null;
            testBoolean = testController.addReimbursableAction() == null;
            testController.reimbursableToCreate.Description__c = 'test';
            testBoolean = testController.addReimbursableAction() == null;
            testController.reimbursableToCreate.Amount__c = 1;
            testBoolean = testController.addReimbursableAction() == null;
            testBoolean = testController.addAndNewReimbursableAction() == null;
            testController.reimbursableIdToRemove = testController.pwm.reimbursableList[0].Id;
            testBoolean = testController.deleteReimbursableAction() == null;
            testBoolean = testController.updateChangeOrderReimbursableData() == null;
            testBoolean = testController.updateChangeOrderDiscountData() == null;
            testBoolean = testController.getProposalVersion() == null;
            testBoolean = testController.setProposalVersion('00.01') == null;
            testBoolean = testController.getPhaseInfo() == null;
            testBoolean = testController.getRenderedPhaseAction() == null;
            testBoolean = testController.getPhaseSelectOption() == null;
            testBoolean = testController.getIsAnyServiceItems() == null;
            testBoolean = testController.manageServiceFloorJunctions() == null;
            testController.serviceIdsForMultiAction = String.valueOf(si.Id);
            testBoolean = testController.populateServiceFloorJunctionsIds() == null;
            testBoolean = testController.getShowProposalAwardedDate() == null;
            testBoolean = testController.getFloorCountingOptions() == null;
            testBoolean = testController.getProjectTeams() == null;
            testBoolean = testController.getFreps() == null;
            testBoolean = testController.getProdManagers() == null;
            testBoolean = testController.setDefaultFrep() == null;
            testBoolean = testController.setDefaultProdManager() == null;
            testBoolean = testController.assignmentSortField == null;
            testController.assignmentSortField = MilroseDevHelper.SORT_ASC;
            testBoolean = testController.assignmentSortDirection == null;
            testBoolean = testController.getAssignmentDirectionMark() == null;
            testBoolean = testController.getAssignments() == null;
            testBoolean = testController.frepSortField == null;
            testController.frepSortField = MilroseDevHelper.SORT_ASC;
            testBoolean = testController.frepSortDirection == null;
            testBoolean = testController.getFrepDirectionMark() == null;
            testBoolean = testController.getFrepAssignments() == null;
            testController.proposal.Is_Change_Order__c = true;
            testBoolean = testController.getIsExistAPSService() == null;
            testBoolean = testController.getIsAllOSServices() == null;
            testBoolean = testController.getCanShowAssignment() == null;
            testBoolean = testController.getShowAssignProjectTeamButton() == null;
            testBoolean = testController.getHideErrorCodes() == null;
            try{
                Id incorrectTaskId = Id.valueOf(Task.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
                delete new Task(Id = incorrectTaskId);
            }catch(DMLException dmlEx){
                testBoolean = testController.addErrorsWhenCreatingProject(dmlEx, true) == null;
            }
            testBoolean = testController.getCanAssignCZAnalyst() == null;
            testBoolean = testController.assignCZAnalyst() == null;
            testBoolean = testController.saveNotes() == null;
            testBoolean = testController.getCanAssignSIPSCoordinator() == null;
            testBoolean = testController.assignSIPSCoordinator() == null;
            testBoolean = testController.viewOnly == null;
            testBoolean = testController.getViewOnly() == null;
            testBoolean = testController.getHasNoID() == null;
            testBoolean = testController.getShowServicesPrices() == null;
            testBoolean = testController.serviceIdsSerialized == null;
            testBoolean = testController.isConfirmationNeeded == null;
            testBoolean = testController.serviceIdToChange == null;
            testBoolean = testController.newQuantity == null;
            testBoolean = testController.oldQuantity == null;
            testBoolean = testController.isDiff == null;
            testController.newQuantity = '20';
            testController.oldQuantity = '15';
            testController.isDiff = true;
            testBoolean = testController.changeQuantity() == null;
            testBoolean = testController.changeQuantityApprove() == null;
            testBoolean = testController.changeQuantityCancel() == null;
            testBoolean = testController.changeQuantityInServiceModel() == null;
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testController.serviceIdToChange = String.valueOf(si.Id);
            testBoolean = testController.changeUnitPriceInServiceModel() == null;
            testBoolean = testController.skipSendingToCZSpecialist() == null;
            testBoolean = testController.updateCZAnalystEmailOnChangeOrder() == null;
            testBoolean = testController.updateSIPSCoordinatorOnChangeOrder() == null;
            testBoolean = testController.moveServiceToPhase() == null;
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testController.serviceIdsForMultiAction = String.valueOf(si.Id);
            testBoolean = testController.deleteMultipleServices() == null;
            testController.setProjectTeam();

            testController.proposal.Id = null;
            testBoolean = testController.addReimbursableAction() == null;
            testController.proposal.Id = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
            testBoolean = testController.addReimbursableAction() == null;
            testController.reimbursableIdToRemove = Additional_Reimbursable__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000';
            testBoolean = testController.deleteReimbursableAction() == null;

            testController.proposal.Project_Team__c = Id.valueOf(Project_Team__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
            testController.setProjectTeam();
        Test.stopTest();

    }

    private static testmethod void testInitControllerWithProposal1(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;
        setupData ();
        Building_AKA__c testBuildingAKA = new Building_AKA__c(Building__c = testBuildingList[0].Id);
        insert testBuildingAKA;
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testBuildingList = TestingUtils.testBuildingList;
        for(Building__c buildingItem : testBuildingList){
            buildingItem.Proposal_Instructions__c = 'test building instruction';
        }
        update testBuildingList;
        testAccountList = TestingUtils.testAccountList;
        for(Account accountItem : testAccountList){
            accountItem.Proposal_Instructions__c = 'test account instruction';
        }
        update testAccountList;
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Accounting_Contact_Company__c = proposalItem.Primary_Company_Name__c;
            proposalItem.Address__c = testBuildingList[0].Id;
        }
        update testProposalList;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Building__c = testBuildingList[0].Id;
        }
        update testProjectTeamList;
        testChangeOrderList = new List<Change_Order__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c co : TestingUtils.createChangeOrderList(1, false)){
                co.Proposal__c = proposalItem.Id;
                co.Project_Profile__c = proposalItem.Project_Profile__c;
                testChangeOrderList.add(co);
            }
            for (Floor__c floorItem : TestingUtils.createFloorList(1, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
        }
        insert testChangeOrderList;
        insert testFloorList;

        Service_Item__c si = TestingUtils.createServiceItemList(1, testProposalList[0].Id, false)[0];
        si.Change_Order__c = testChangeOrderList[0].Id;
        si.Quantity_Old__c = null;
        si.Project_Profile__c = testProposalList[0].Project_Profile__c;
        insert si;

        List<Service_Floor_Junction__c> testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            for (Service_Floor_Junction__c sfjItem : TestingUtils.createServiceFloorJunctionList(1, si.Id, floorItem.Id, false)){
                testServiceFloorJunctionList.add(sfjItem);
            }
        }
        insert testServiceFloorJunctionList;

        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('co', String.valueOf(testChangeOrderList[0].Id));
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        List<Document> testDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name =: 'RFP Artifacts' LIMIT 1];//this query is from ProposalWizardServices.getDocumentsFromDirectory() method

        Test.startTest();
            System.assert(testController != null);

            Boolean testBoolean;
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{String.valueOf(testChangeOrderList[0].Id) => new ChangeOrderModel(testChangeOrderList[0],
                                                                                                                                                        UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                                                        'test user role',
                                                                                                                                                        currentUserId,
                                                                                                                                                        testProposalList[0],
                                                                                                                                                        true,
                                                                                                                                                        testProjectTeamList[0],
                                                                                                                                                        true, true, true)};
            testController.pwm.documentWrapperList = new List<DocumentWrapper>();
            if (!testDocument.isEmpty()){
                DocumentWrapper docWrapp = new DocumentWrapper(testDocument[0]);
                docWrapp.isAttached = true;
                testController.pwm.documentWrapperList.add(docWrapp);
            }
            testBoolean = testController.getDocumentInfo() == null;
            testBoolean = ProposalWizardController.saveGeneralChangeOrderNotes(String.valueOf(testChangeOrderList[0].Id), 'test value') == null;
            testController.proposal.Is_Change_Order__c = true;
            testController.proposal.Proposal_Type__c = ProposalServices.PROPOSAL_TYPE_RFP;
            testBoolean = testController.getChangeOrderInfo() == null;
            testBoolean = ProposalWizardController.clearTemporaryInstructionsFields(String.valueOf(testProposalList[0].Id)) == null;
            testController.primaryCInstructions = 'test value';
            testBoolean = testController.saveInstructions() == null;
            testBoolean = ProposalWizardController.checkAndUpdateInstructions( String.valueOf(testProposalList[0].Id), 'ProposalWizardPage:theForm:primaryCInstructions', 'test value 1',
                                                                               String.valueOf(testProposalList[0].Primary_Company_Name__c), String.valueOf(testProposalList[0].Billing_Company_Name__c),
                                                                               String.valueOf(testProposalList[0].Accounting_Contact_Company__c), String.valueOf(testProposalList[0].Address__c)) == null;
            testBoolean = ProposalWizardController.checkAndUpdateInstructions( String.valueOf(testProposalList[0].Id), 'ProposalWizardPage:theForm:billingCInstructions', 'test value 2',
                                                                               String.valueOf(testProposalList[0].Primary_Company_Name__c), String.valueOf(testProposalList[0].Billing_Company_Name__c),
                                                                               String.valueOf(testProposalList[0].Accounting_Contact_Company__c), String.valueOf(testProposalList[0].Address__c)) == null;
            testBoolean = ProposalWizardController.checkAndUpdateInstructions( String.valueOf(testProposalList[0].Id), 'ProposalWizardPage:theForm:accountingCInstructions', 'test value 3',
                                                                               String.valueOf(testProposalList[0].Primary_Company_Name__c), String.valueOf(testProposalList[0].Billing_Company_Name__c),
                                                                               String.valueOf(testProposalList[0].Accounting_Contact_Company__c), String.valueOf(testProposalList[0].Address__c)) == null;
            testBoolean = ProposalWizardController.checkAndUpdateInstructions( String.valueOf(testProposalList[0].Id), 'ProposalWizardPage:theForm:buildingInstructions', 'test value 4',
                                                                               String.valueOf(testProposalList[0].Primary_Company_Name__c), String.valueOf(testProposalList[0].Billing_Company_Name__c),
                                                                               String.valueOf(testProposalList[0].Accounting_Contact_Company__c), String.valueOf(testProposalList[0].Address__c)) == null;
            testBoolean = ProposalWizardController.checkAndUpdateInstructions( String.valueOf(testProposalList[0].Id), 'ProposalWizardPage:theForm:billingInstructions', 'test value 5',
                                                                               String.valueOf(testProposalList[0].Primary_Company_Name__c), String.valueOf(testProposalList[0].Billing_Company_Name__c),
                                                                               String.valueOf(testProposalList[0].Accounting_Contact_Company__c), String.valueOf(testProposalList[0].Address__c)) == null;
            testBoolean = testController.getBuildingProjectsData() == null;
            testBoolean = testController.getProposalOwnInstructions() == null;
            testBoolean = testController.getProposalInstructions() == null;
            testBoolean = testController.getBuildingProjectsData() == null;
            testBoolean = testController.getBuildingHint() == null;
            testBoolean = testController.getShowBuildingHint() == null;
            testBoolean = testController.changeRightPanelToReimbursable() == null;
            testBoolean = testController.getIsMaxCompleteness() == null;
            testBoolean = testController.getCompleteness() == null;
            testBoolean = testController.getProposalRfpRequestDate() == null;
            testBoolean = testController.setProposalRfpRequestDate(null) == null;
            testBoolean = testController.getProposalExpirationDate() == null;
            testBoolean = testController.setProposalExpirationDate(null) == null;
            testBoolean = testController.iFrameDocumentsPageReference == null;
            testBoolean = testController.iFrameDrawingsPageReference == null;
            testBoolean = testController.iFrameDrawingsFileListPageReference == null;
            testBoolean = testController.getIFrameAdditionalDocumentsPageReference() == null;
            testBoolean = testController.proposal.Additional_Documents__c = true;
            testBoolean = testController.createDeleteAdditionalDocumentsFolder() == null;
            testBoolean = testController.proposal.Additional_Documents__c = false;
            testBoolean = testController.createDeleteAdditionalDocumentsFolder() == null;
            testController.pwm.serviceModels.values()[0].municipalAgency = 'test';
            testBoolean = testController.updateProposalMunicipalAgency() == null;
            testBoolean = testController.complete(true) == null;
            testController.drawings = null;
            testBoolean = testController.drawings == null;
            testController.additionalDocuments = null;
            testBoolean = testController.additionalDocuments == null;
            testController.proposal.Is_Draft__c = true;
            testController.proposal.Status__c = 'test status';
            testBoolean = testController.getShowBuildingHint() == null;
            testController.proposal.Id = null;
            testBoolean = testController.getProposalOwnInstructions() == null;
            testBoolean = testController.manageFileUpload(true) == null;

            testController.proposal.Id = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
            testBoolean = testController.changeRightPanelToReimbursable() == null;
            testBoolean = testController.changeRightPanelToFloor() == null;
            testBoolean = testController.checkSendCopyToEmails(true) == null;

        Test.stopTest();

    }

    private static testmethod void testInitControllerWithProposal2(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;
        setupData ();

        testServiceBundleList = new List<Service_Bundle__c>();
        for (Region__c regionItem : testRegionList){
            Integer namePrefixItem = 0;
            for (Service_Bundle__c serviceBundleItem : TestingUtils.createServiceBundleList(1, regionItem.Name + String.valueOf(namePrefixItem++), false)){
                serviceBundleItem.Region__c = regionItem.Name;
                testServiceBundleList.add(serviceBundleItem);
            }
        }
        insert testServiceBundleList;

        Building_AKA__c testBuildingAKA = new Building_AKA__c(Building__c = testBuildingList[0].Id);
        insert testBuildingAKA;
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Accounting_Contact_Company__c = proposalItem.Primary_Company_Name__c;
        }
        update testProposalList;
        testChangeOrderList = new List<Change_Order__c>();
        testFloorList = new List<Floor__c>();
        testPurchaseOrderList = new List<Purchase_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c co : TestingUtils.createChangeOrderList(1, false)){
                co.Proposal__c = proposalItem.Id;
                co.Project_Profile__c = proposalItem.Project_Profile__c;
                testChangeOrderList.add(co);
            }
            for (Floor__c floorItem : TestingUtils.createFloorList(1, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
            for (Purchase_Order__c purchaseOrderItem : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false)){
                purchaseOrderItem.Proposal__c = proposalItem.Id;
                purchaseOrderItem.Name = 'test purchase order name';
                testPurchaseOrderList.add(purchaseOrderItem);
            }
        }
        insert testChangeOrderList;
        insert testFloorList;
        insert testPurchaseOrderList;

        Service_Item__c si = TestingUtils.createServiceItemList(1, testProposalList[0].Id, false)[0];
        si.Change_Order__c = testChangeOrderList[0].Id;
        si.Quantity_Old__c = null;
        si.Project_Profile__c = testProposalList[0].Project_Profile__c;
        insert si;

        List<Service_Floor_Junction__c> testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            for (Service_Floor_Junction__c sfjItem : TestingUtils.createServiceFloorJunctionList(1, si.Id, floorItem.Id, false)){
                testServiceFloorJunctionList.add(sfjItem);
            }
        }
        insert testServiceFloorJunctionList;

        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('co', String.valueOf(testChangeOrderList[0].Id));
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        List<Document> testDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name =: 'RFP Artifacts' LIMIT 1];//this query is from ProposalWizardServices.getDocumentsFromDirectory() method

        Test.startTest();
            System.assert(testController != null);

            Boolean testBoolean;
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testBoolean = testController.getDisableFloorAction() == null;
            testBoolean = testController.getFloorTypeOptions() == null;
            testBoolean = testController.getTenantFloorTypeOptions() == null;
            testController.floorToCreate.Floor_Type__c = 'test';
            testController.floorToCreate.Floor_Number__c = '4';
            testBoolean = testController.saveFloorAndCloseTab() == null;
            testBoolean = testController.saveFloorAndDoNotCloseTab() == null;
            testBoolean = testController.serviceTemplate == null;
            testBoolean = testController.getApprovedVendorsOptions() == null;
            testBoolean = testController.getServiceTypeOption() == null;
            testController.serializedProposal = null;
            testBoolean = testController.getIsSinglePermit() == null;
			testController.serviceTemplate.Subtype__c = null;
            testBoolean = testController.getRequiredSIPSFieldsPopulated(ServiceItemServices.SERVICE_NAME_SPECIAL_INSPECTION_PROJECT_COORDINATION) == null;
            testBoolean = testController.selectedVendor == null;
            testBoolean = testController.quantityOfServicesToInsert == null;
            testBoolean = testController.getAvailablePhases() == null;
            testBoolean = testController.serviceType == null;
            testBoolean = testController.getDisableAddPurchaseOrderButton() == null;
            testBoolean = testController.purchaseOrderCreated == null;
            testBoolean = testController.updateServiceTable == null;
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testController.pwm.serviceModels.values()[0].isAddedToPurchaseOrder = true;
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{String.valueOf(testChangeOrderList[0].Id) => new ChangeOrderModel(testChangeOrderList[0],
                                                                                                                                                        UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                                                        'test user role',
                                                                                                                                                        currentUserId,
                                                                                                                                                        testProposalList[0],
                                                                                                                                                        true,
                                                                                                                                                        testProjectTeamList[0],
                                                                                                                                                        true, true, true)};
            testBoolean = testController.addAllServicesToPurchaseOrder() == null;
            testBoolean = testController.cleanUpPurchaseOrder() == null;
            testBoolean = testController.cancelPurchaseOrderAction() == null;
            testBoolean = testController.prepareFileUploadPageForCurrentPO() == null;
            testBoolean = testController.prepareCurrentPurchaseOrder() == null;
            testBoolean = testController.editPurchaseOrderBlockTitle == null;
            testBoolean = testController.getAddPurchaseOrderButtonTitle() == null;
            testBoolean = testController.getAddAndNewPurchaseOrderButtonTitle() == null;
            testBoolean = testController.purchaseOrderToUpdate == null;
            testBoolean = testController.purchaseOrderStorageIframe == null;
            testBoolean = testController.cleanUpPurchaseOrder() == null;
            testController.purchaseOrderToUpdate = String.valueOf(testPurchaseOrderList[0].Id);
            testBoolean = testController.updatePurchaseOrderAction() == null;
            testBoolean = testController.saveAndNewPurchaseOrderAction() == null;
            testController.currentPurchaseOrder = testPurchaseOrderList[0];
            testController.currentPurchaseOrder.Purchase_Order_Amount__c = 1;
            testBoolean = testController.savePurchaseOrderAction() == null;
            testBoolean = testController.deletePurchaseOrderAction() == null;
            testBoolean = testController.getServiceBundleChosenCanBeDeleted() == null;
            testBoolean = testController.getServiceBundlesToChoose() == null;
            testBoolean = testController.getIsStatusInInternalReview() == null;
            testBoolean = testController.getAssignedIrId() == null;
            testBoolean = testController.getIsSaveDraftButtonVisible() == null;
            testBoolean = testController.getIsSendForInternalReviewButtonVisible() == null;
            testBoolean = testController.getIsSendToClientButtonVisible() == null;
            testBoolean = testController.getIsReSendToClientButtonVisible() == null;
            testBoolean = testController.getIsFollowUpButtonVisible() == null;
            testBoolean = testController.getIsSendForCZScopingReviewButtonVisible() == null;
            testBoolean = testController.getIsSubmitButtonVisible() == null;
            testBoolean = testController.getIsCompleteButtonVisible() == null;
            testBoolean = testController.getIsSaveButtonVisible() == null;
            testBoolean = testController.getIsApproveButtonVisible() == null;
            testBoolean = testController.getIsRejectButtonVisible() == null;
            testBoolean = testController.getIsChangeOrderApprovedButtonVisible() == null;
            testBoolean = testController.getIsRejectedWithNotesButtonVisible() == null;
            testBoolean = testController.getIsWithdrawnButtonVisible() == null;
            testBoolean = testController.getIsCanceledButtonVisible() == null;
            testBoolean = testController.getIsAwardedButtonVisible() == null;
            testBoolean = testController.getIsNotAwardedButtonVisible() == null;
            testBoolean = testController.getIsSumbitChangeOrderButtonVisible() == null;
            testBoolean = testController.getIsAnyAllowedProfile() == null;
            testBoolean = testController.getIsApproveButtonEnabled() == null;
            testBoolean = testController.getIsRejectButtonEnabled() == null;
            testBoolean = testController.getAreServiceButtonsEnabled() == null;
            testBoolean = testController.getArePhasesButtonsEnabled() == null;
            testBoolean = testController.getAreFloorButtonsEnabled() == null;
            testBoolean = testController.getAreContactButtonsEnabled() == null;
            testBoolean = testController.getIsFulfillmentOfficeEnabled() == null;
            testBoolean = testController.getIsClientProjectEnabled() == null;
            testBoolean = testController.getIsRejectedWithNotesButtonVisible() == null;
            testBoolean = testController.getIsAddPurchaseOrderButtonEnabled() == null;
            testBoolean = testController.getEnableBillingPreferences() == null;
            testBoolean = testController.getEnableBillingPreferencesGroupTwo() == null;
            testBoolean = testController.hasBillingOccurredOnProject == null;
            testBoolean = testController.getEnableAccountManager() == null;
            testController.proposal.Status__c = ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
            testBoolean = testController.getIsThisUserAssignedSIPSUser() == null;
            testBoolean = testController.getIsCreateNewChangeOrderVisible() == null;
            testController.profileName = 'test fake profile name';
            testController.proposal.is_Change_Order__c = true;
            testBoolean = testController.canCreateNewCo() == null;
            testController.profileName = UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN;
            testBoolean = testController.getIsSubmitButtonEnabled() == null;
            testBoolean = testController.getIsIrValid() == null;
            testBoolean = testController.getIsIdValid() == null;
            testBoolean = testController.getIsErValid() == null;
            testBoolean = testController.getIsFaValid() == null;
            testBoolean = testController.getIsSpValid() == null;
            testBoolean = testController.getIsSmValid() == null;
            testBoolean = testController.removeChangeOrder() == null;
            testBoolean = testController.getIsPManager1() == null;
            testBoolean = testController.getIsPManager2() == null;
            testBoolean = testController.getIsAM() == null;
            testBoolean = testController.getIsAssignedInternalReviewer() == null;
            testBoolean = testController.getIsPreviewPdfDisabled() == null;
            testBoolean = testController.getShowAlternativeServicesTable() == null;
            testBoolean = testController.getDisableReceivedSignedProposalCheckbox() == null;
            testBoolean = testController.manageFollowups() == null;
            testBoolean = testController.getEnableAutomaticFollowUps() == null;
            testBoolean = testController.getHasPendingChangeOrders() == null;
            testBoolean = testController.getIsUseDocusignEditable() == null;
            testController.proposal.Id = null;
            testBoolean = testController.saveDraft() == null;


        Test.stopTest();

    }

    private static testmethod void testInitControllerWithProposal3(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;
        setupData ();

        testServiceBundleList = new List<Service_Bundle__c>();
        for (Region__c regionItem : testRegionList){
            Integer namePrefixItem = 0;
            for (Service_Bundle__c serviceBundleItem : TestingUtils.createServiceBundleList(1, regionItem.Name + String.valueOf(namePrefixItem++), false)){
                serviceBundleItem.Region__c = regionItem.Name;
                testServiceBundleList.add(serviceBundleItem);
            }
        }
        insert testServiceBundleList;

        Building_AKA__c testBuildingAKA = new Building_AKA__c(Building__c = testBuildingList[0].Id);
        insert testBuildingAKA;
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Accounting_Contact_Company__c = proposalItem.Primary_Company_Name__c;
            proposalItem.Mi3_MRC__c = 'test mi3';
            proposalItem.Is_Mi3_Project_Created__c = false;
            proposalItem.FREP__c = userinfo.getUserId();
            proposalItem.Project_Team__c = testProjectTeamList[0].Id;
        }
        insert testProposalList;
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Floor__c floorItem : TestingUtils.createFloorList(1, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;

        Service_Item__c si = TestingUtils.createServiceItemList(1, testProposalList[0].Id, false)[0];
        si.Quantity_Old__c = null;
        si.Project_Profile__c = testProposalList[0].Project_Profile__c;
        insert si;

        List<Service_Floor_Junction__c> testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            for (Service_Floor_Junction__c sfjItem : TestingUtils.createServiceFloorJunctionList(1, si.Id, floorItem.Id, false)){
                testServiceFloorJunctionList.add(sfjItem);
            }
        }
        insert testServiceFloorJunctionList;

        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        List<Document> testDocument = [SELECT Id, Name, Description FROM Document WHERE Folder.Name =: 'RFP Artifacts' LIMIT 1];//this query is from ProposalWizardServices.getDocumentsFromDirectory() method

        Test.startTest();
            System.assert(testController != null);

            Boolean testBoolean;
            testBoolean = testController.createMI3Project() == null;
            testController.proposal.Expected_Construction_Start_Date__c = Date.today();
            testBoolean = testController.createMI3Project() == null;
            testBoolean = testController.createMI3ProjectStage2() == null;
            testBoolean = testController.undoCreateMI3Project() == null;

        Test.stopTest();

    }

    private static testmethod void testInitControllerWithProposalAndProposalDraft(){
        setupData ();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        Test.startTest();
            preparePageController (testProposalList[0], testProposalDraftList[0].Id);
        Test.stopTest();

        System.assert(testController != null);
    }

    /*private static testmethod void testCoveredGetterSetter1(){
        setupData ();
        prepareServiceTemplate();
        createServiceBundleForTest();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Specification_Name__c = 'test';
                testFloorList.add(floorItem);
            }
            for (Change_Order__c co : TestingUtils.createChangeOrderList(1, false)){
                co.Proposal__c = proposalItem.Id;
                co.Project_Profile__c = proposalItem.Project_Profile__c;
                testChangeOrderList.add(co);
            }
        }
        insert testFloorList;
        insert testPhaseList;
        insert testChangeOrderList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testProposalList.isEmpty());

        preparePageController (testProposalList[0], null);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('co', String.valueOf(testChangeOrderList[0].Id));
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        System.assert(testController != null);

        Boolean boolRes;

        testController.getChangeHistory();
        boolRes = testController.renderedPhaseAction == null;
        boolRes = testController.phaseSelectOption == null;
        testController.proposal.Id = null;
        testController.projectAddressAction();
        testController.proposal.Id = testProposalList[0].Id;
        testController.projectAddressAction();
        testController.associateFloorsWithServicesAction();
        boolRes = testController.isLandmark == null;
        testController.isLandmark = true;
        boolRes = testController.isMTA == null;
        testController.isMTA = true;
        boolRes = testController.projectTeams == null;
        boolRes = testController.projectTeams == null;
        boolRes = testController.assignments == null;
        Boolean boolValue = testController.canShowAssignment;
        boolValue = testController.canAssignProjectTeam;
        boolValue = testController.canAssignResource;
        testController.proposal.Project_Team__c = testProjectTeamList[0].Id;
        testController.setProjectTeam();

        Test.startTest();
            boolValue = testController.showServicesPrices;
            testController.updateAttachedDocuments();
            testController.building.Is_Landmark__c = true;
            testController.building.Is_MTA__c = true;
            testController.proposal.sowServicesNeededAPS__c = true;
            testController.proposal.sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
            testController.serviceBundleChosen = testServiceBundleList[0].Id;
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{String.valueOf(testChangeOrderList[0].Id) => new ChangeOrderModel(testChangeOrderList[0],
                                                                                                                                                UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                                                'test user role',
                                                                                                                                                currentUserId,
                                                                                                                                                testProposalList[0],
                                                                                                                                                true,
                                                                                                                                                testProjectTeamList[0],
                                                                                                                                                true, true, true)};
            testController.createServiceItemsFromRowList(true);
            testController.createServiceItemsFromRowList(false);
            testController.serviceBundleChosen = '';
            testController.createServiceItemsFromRowList(true);
            testController.removeServiceModel();
            testController.setConfirmServiceTune();
            testController.setConfirmServiceTuneSubmit();
            testController.sendToCZSpecialist();
            testController.proposal.Id = testProposalDraftList[0].Id;
            testController.sendToCZSpecialist();
            testController.moveServicesToPhase();
            testController.showPhasesOutputPanel();
            boolValue = testController.isCZSpesialistRequired;
            boolValue = testController.canUseSendToCZSpecialistButton;
            boolValue = testController.canUseCreateServicesButton;
            testController.changeCoStatusNewStatus = 'test';
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{ChangeOrderServices.STATUS_DRAFT => new ChangeOrderModel(null,
                                                                                                                                                UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                                                'test user role',
                                                                                                                                                currentUserId,
                                                                                                                                                testProposalList[0],
                                                                                                                                                true,
                                                                                                                                                testProjectTeamList[0],
                                                                                                                                                true, true, true)};
            testController.changeCoStatusCoId = ChangeOrderServices.STATUS_DRAFT;
            testController.changeCOStatus();
            testController.cancelChangeOrderInternalReviewer();
            String testString;
            testString = testController.retrieveReimbursableQuantity;
            testController.retrieveReimbursableQuantity = 'test';
            testString = testController.retrieveDiscountQuantity;
            testController.retrieveDiscountQuantity = 'test';
            testController.proposal.Reimbursable_Percentage__c = null;
            testController.recalculateReimbursables();
            testString = testController.getTotalNotesText();
            testController.updateProjectLocation();
            testController.changeRightPanelToNotes();
            boolValue = testController.floorTypeOptions == null;
            boolValue = testController.tenantFloorTypeOptions == null;
            testController.updateFloorNumber();
            testController.updateTenantFloorNumber();
            testController.proposalStatus = 'In Internal Review';
            testController.changeProposalStatus();
            testController.proposalStatus = 'Passed Internal Review';
            testController.changeProposalStatus();
            testController.proposalStatus = 'C&Z Scope Review Complete';
            testController.changeProposalStatus();
            testController.proposalStatus = 'Pending Client Approval';
            testController.changeProposalStatus();
            ChangeOrderModel comod = new ChangeOrderModel(null,
                                                        UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                        'test user role',
                                                        currentUserId,
                                                        testProposalList[0],
                                                        true,
                                                        testProjectTeamList[0],
                                                        true, true, true);
            comod.changeOrderRecord.UseDocusign__c = true;
            testController.pwm.changeOrderModelMap.put(ChangeOrderServices.ORIGINAL_CHANGE_ORDER, comod);
            testController.pwm.changeOrderModelMap.put(comod.changeOrderRecord.Id, comod);
	    testController.proposalStatus = 'Awarded';
            testController.changeProposalStatus();
            testController.proposalStatus = 'test';
            testController.changeProposalStatus();
            testController.proposalStatus = 'Change Order Requested';
            testController.changeProposalStatus();
            testController.reSendPdf();
            testController.proposal.UseDocusign__c = true;
            testController.changeCoStatusCoId = comod.changeOrderRecord.Id;
            testController.prepareProposalPdf();
            testController.sendProposalPdf();
            testController.pwm.approvedChangeOrders = new List<ChangeOrderModel>();
            testController.pwm.notApprovedChangeOrders = new List<ChangeOrderModel>{new ChangeOrderModel(null,
                                                                                    UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                    'test user role',
                                                                                    currentUserId,
                                                                                    testProposalList[0],
                                                                                    true,
                                                                                    testProjectTeamList[0],
                                                                                    true, true, true)};
            testController.pwm.notApprovedChangeOrders[0].status = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testController.doSendChangeOrderPdf();
            testController.getEnableSendProposalPdf();
            testController.createNonFeeProposalPDF();
            boolValue = testController.disableGeneralProposalNotes == null;
            testController.profileName = 'test name';
            testController.enableStep3Inputs();
            testController.profileName = UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN;
            testController.getRejectedOrFailedStatus();
            testController.changeProductionManagerAction();
            testController.changePrimaryContactAction();
            testController.changeBillingContactAction();
            testController.changeAccountingContactAction();
            testController.primaryCompanyAction();
            testController.billingCompanyAction();
            testController.accountingCompanyAction();
            testController.primaryCompanyIsBillingCompanyAction();
            testController.sendInvoicesToDifferentContactAction();
            testController.addContactToRosterAction();
            testController.checkSeparatePhases();
            testController.getValidPhaseDate();
            ChangeOrderModel coModelItem = new ChangeOrderModel(testChangeOrderList[0],
                                                                UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                'test user role',
                                                                currentUserId,
                                                                testProposalList[0],
                                                                true,
                                                                testProjectTeamList[0],
                                                                true, true, true);
            testController.pwm.notApprovedChangeOrders = new List<ChangeOrderModel>{coModelItem};
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>();
            testController.pwm.changeOrderModelMap.put( String.valueOf(testChangeOrderList[0].Id), coModelItem);
            testController.changeCoStatusCoId = String.valueOf(testChangeOrderList[0].Id);
            try{
                testController.approveChangeOrderBeforeRedirectBillingTriggers();
            }catch(Exception ex){}
        Test.stopTest();
    }*/

    private static testmethod void testTestCoveredGetterSetter2(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        List<Phase__c> testPhaseToInsertList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
                testPhaseToInsertList.add(phaseItem);
            }
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseToInsertList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseToInsertList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testServiceItemList.isEmpty());

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();
            testController.changeRightPanelToFloor();
            testController.proposal.Send_Copy_To__c = 'email';
            testController.checkSendCopyToEmails(true);
            testController.proposal.Send_Copy_To__c = 'email@test.com';
            testController.checkSendCopyToEmails(true);
            testController.showSendCopyTo();
            testController.populateReminderForCreatorFields();
            testController.cancelSendCopyTo();
            testController.updateSendCopyTo();
            testController.getBillingAccount();
            testController.proposal.Provided_Drawings__c = true;
            testController.currentStorageFolder = StoredDocumentServices.DRAWINGS_FILE_TYPE;
            testController.manageFileUpload();
            testController.manageFileUpload(false);
            testController.proposal.Provided_Documents__c = true;
            testController.currentStorageFolder = StoredDocumentServices.DOCUMENTS_FILE_TYPE;
            testController.manageFileUpload(true);
            testController.setServiceTypesOverride();
            testController.proposal.Expected_Construction_Start_Date__c = Date.today();
            testController.setServiceTypesOverride();
            testController.proposal.Expected_Construction_Start_Date__c = Date.today().addDays(90);
            testController.setServiceTypesOverride();
            Boolean boolValue;
            testController.close();
            testController.setRejectionReasonPanelView();
            testController.proposal.Primary_Client_is_Billing_Client__c = true;
            testController.proposal.Primary_Client_is_Billing_Client__c = false;
            boolValue = testController.isSubmitButtonEnabled;
            boolValue = testController.enableStep3Inputs();
            boolValue = testController.renderedLinkPhaseDelete;
            boolValue = testController.disablePhasesCheckbox;
            boolValue = testController.renderedPhasesAction;
            testController.proposal.sowUseEgressOccupancy__c = true;
            testController.proposal.sowNoneOfTheAbove__c = true;
            boolValue = testController.validPhaseDate;
            testController.newPhaseAction();
            testController.deletePhaseAction();
            testController.phaseIdsSerialized = String.valueOf([SELECT Id FROM Phase__c WHERE Proposal__c = : testProposalList[0].Id][0].Id);
            System.assert(!String.isBlank(testController.phaseIdsSerialized));
            testController.updatePhaseNumbers('');
            boolValue = testController.serviceTypeOption == null;
            boolValue = testController.isSinglePermit;
            boolValue = testController.isRecordTypeSelectionDisabled;
            testController.addServiceAction();
            boolValue = testController.serviceTemplatesForNewServices == null;
            boolValue = testController.availablePhases == null;
            boolValue = testController.enableStep2Summary;
            boolValue = testController.existingPurchaseOrders == null;
            testController.blanketPOAction();
            testController.loadServiceBundle();
            boolValue = testController.serviceBundlesToChoose == null;
            testController.saveServiceBundle();
            testController.updateArtifacts();
            testController.addChangeOrder();
            testController.currentPurchaseOrder.Purchase_Order_Amount__c = 12.34;
            testController.changePartnerAction();
            testController.changeSalespersonAction();
            testController.changeAccountManagerAction();
        Test.stopTest();
    }

    private static testmethod void testPopulateServicesFromStepTwo(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testProposalList.isEmpty());

        preparePageController (testProposalList[0], null);

        System.assert(testController != null);

        Test.startTest();
            testController.populateServicesFromStepTwo();
        Test.stopTest();
    }

    private static testmethod void testComplete(){
        setupData ();
        prepareServiceTemplate();
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.FREP__c = userinfo.getUserId();
            proposalItem.Production_Manager__c = userinfo.getUserId();
            proposalItem.Project_Team__c = testProjectTeamList[0].Id;
        }
        update testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testProposalList.isEmpty());

        preparePageController (testProposalList[0], null);

        System.assert(testController != null);

        Test.startTest();
            testController.complete();
            testController.doCompletenessChecks = true;
            testController.proposal.Send_Copy_To__c = 'email@test.com';
            testController.complete();
            testController.doCompletenessChecks = false;
            testController.proposal.Send_Copy_To__c = 'email@test.com';
            testController.complete();
            testController.proposal.Expected_Construction_Start_Date__c = Date.today();
            testController.complete();
            testController.proposal.Send_Invoices_to_Different_Contact__c = false;
            testController.complete();
            testController.proposal.Fulfillment_Office__c = 'test';
            testController.isChangeOrder = true;
            testController.proposal.FREP__c = userinfo.getUserId();
            testController.complete();
            testController.proposal.Production_Manager__c = userinfo.getUserId();
            testController.complete();
            testController.proposal.Project_Team__c = testProjectTeamList[0].Id;
            testController.complete();
        Test.stopTest();

        testController.proposal.FREP__c = userinfo.getUserId();
        testController.complete();
        testController.proposal.FREP__c = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        testController.complete();
        
    }

    private static testmethod void testSavePhaseAction(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();
            testController.phaseToCreate.Name__c = 'test';
            testController.phaseToCreate.Start_Date__c = Date.today();
            testController.phaseToCreate.End_Date__c = Date.today().addDays(1);
            testController.isSavePhase = true;
            testController.savePhaseAction();
            testController.editPhaseAction();
            testController.phaseEditId = String.valueOf([SELECT Id FROM Phase__c WHERE Proposal__c = : testProposalList[0].Id][0].Id);
            testController.phaseDelId = testController.phaseEditId;
            testController.editPhaseAction();
            testController.changeRightPanelToPhase();
            testController.phaseEditId = testController.phaseDelId;
            testController.deletePhaseAction();
            testController.phaseDelId = String.valueOf(TestingUtils.createPhaseList(1, true)[0].Id);
            testController.deletePhaseAction();
        Test.stopTest();
    }

    private static testmethod void testSaveFloor(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();
            testController.cancelFloorAction();
            testController.saveFloor();
            testController.floorToCreate.Floor_Type__c = 'test';
            testController.saveFloor();
            testController.floorToCreate.Tenant_Type__c = 'test';
            testController.saveFloor();
            testController.floorToCreate.Tenant_Type__c = '10';
            testController.saveFloor();
            testController.floorToCreate.Floor_Number__c = '10';
            testController.saveFloor();
            testController.floorIdToRemove = String.valueOf([SELECT Id FROM Floor__c WHERE Proposal__c = : testProposalList[0].Id][0].Id);
            testController.removeFloorAction();
//            testController.selectedFloorsForService = String.valueOf([SELECT Id FROM Floor__c WHERE Proposal__c = : testProposalList[0].Id][0].Id);

        Test.stopTest();
    }

    private static testmethod void testNewServiceItem(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();
            testController.proposal.Id = null;
            testController.proposal.sowScopeOfWork__c = 'Existing Space';
            testController.proposal.sowServicesNeededAPS__c = true;
            testController.proposal.sowNoneOfTheAbove__c = true;
            testController.proposal.sowSpaceAlterType__c = 'Single Permit';
        Test.stopTest();
    }

    private static testmethod void testChangeServiceTemplate(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();
            testController.building = [SELECT Id, Municipality__r.Region__r.Name, Municipality__r.Region__c, Region__c FROM Building__c WHERE id = : testBuildingList[0].Id][0];
            testController.serviceTemplate = new Service_Template__c(RecordTypeId = serviceTemplateAPSRecordTypeId);
        Test.stopTest();
    }

    private static testmethod void testPopulateServiceModels(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);

        Test.startTest();

            for (ServiceModel sm : testController.pwm.serviceModels.values()){
                sm.isTemplate = false;
                sm.isAssignedSIPS = true;
                sm.isTemplate = true;
            }

            testController.createPhasesAndServiceItems(true, null);
            testController.createPhasesAndServiceItems(false, null);

            for (ServiceModel sm : testController.pwm.serviceModels.values()){
                sm.isTemplate = true;
            }

            testController.createPhasesAndServiceItems(true, null);
            testController.createPhasesAndServiceItems(false, null);

        Test.stopTest();
    }

    private static testmethod void testSaveServiceItem(){
        setupData ();
        prepareServiceTemplate();
        createProposalsForTest (NUMBER_TO_CREATE_PROPOSAL, true);
        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            Integer i = 1;
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Number__c = i++;
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }
        }
        insert testFloorList;
        insert testPhaseList;

        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        preparePageController (testProposalList[0], null);
        System.assert(testController != null);
        
        Test.startTest();

            testController.building = [SELECT Id, Municipality__r.Region__r.Name, Municipality__r.Region__c, Region__c FROM Building__c WHERE id = : testBuildingList[0].Id][0];
            testController.serviceTemplate = [SELECT Id, Category__c, Type__c, Subtype__c, Plan_Submission_Type__c, RecordTypeId, Service_Name_Full__c, Region__c
                                              FROM Service_Template__c
                                              WHERE Region__c =: testController.building.Municipality__r.Region__c LIMIT 1][0];
            testController.searchField = testController.serviceTemplate.Service_Name_Full__c;
            testController.addServiceAction();

            testController.activeChangeOrderId = TestingUtils.createChangeOrderList(1, true)[0].id;
            testController.addServiceAction();

        Test.stopTest();
    }

    private static testmethod void testChangeCOStatus(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;
        setupData ();
        Building_AKA__c testBuildingAKA = new Building_AKA__c(Building__c = testBuildingList[0].Id);
        insert testBuildingAKA;
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        testChangeOrderList = new List<Change_Order__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c co : TestingUtils.createChangeOrderList(1, false)){
                co.Proposal__c = proposalItem.Id;
                co.Project_Profile__c = proposalItem.Project_Profile__c;
                testChangeOrderList.add(co);
            }
            for (Floor__c floorItem : TestingUtils.createFloorList(1, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
        }
        insert testChangeOrderList;
        insert testFloorList;

        Service_Item__c si = TestingUtils.createServiceItemList(1, testProposalList[0].Id, false)[0];
        si.Change_Order__c = testChangeOrderList[0].Id;
        si.Quantity_Old__c = null;
        si.Project_Profile__c = testProposalList[0].Project_Profile__c;
        insert si;

        List<Service_Floor_Junction__c> testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Floor__c floorItem : testFloorList){
            for (Service_Floor_Junction__c sfjItem : TestingUtils.createServiceFloorJunctionList(1, si.Id, floorItem.Id, false)){
                testServiceFloorJunctionList.add(sfjItem);
            }
        }
        insert testServiceFloorJunctionList;

        testPage = Page.ProposalWizard;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION);
        ApexPages.currentPage().getParameters().put('co', String.valueOf(testChangeOrderList[0].Id));
        ApexPages.currentPage().getParameters().put('id', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('data', String.valueOf(testProposalList[0].Id));
        ApexPages.currentPage().getParameters().put('buildingId', String.valueOf(testProposalList[0].Address__c));
        testStandardController = new ApexPages.standardController(testProposalList[0]);
        testController = new ProposalWizardController(testStandardController);

        Test.startTest();
            System.assert(testController != null);

            Boolean testBoolean;
            testController.whereToMoveDestination = 'MoveToServicesTable';
            testController.pwm = new ProposalWizardModel(testProposalList[0], testProjectTeamList[0], UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, UserServices.SYSTEM_ADMINISTRATOR);
            testController.pwm.serviceModels = new Map<Id, ServiceModel>();
            testController.pwm.serviceModels.put(si.Id, new ServiceModel(si, null, null, null));
            testController.serviceIdsForMultiAction = String.valueOf(si.Id);
            testBoolean = testController.moveServicesBetweenTables() == null;
            testBoolean = testController.getEnableStep2Summary() == null;
            testBoolean = testController.getIsCZSpesialistRequired() == null;
            testBoolean = testController.getIsCZAssignmentVisible() == null;


            testBoolean = testController.getIsSIPSAssignmentVisible() == null;
            testBoolean = testController.getIsNoteBodyEmpty() == null;
            testController.noteBody = 'test note body';
            testBoolean = testController.getCanUseSendToCZSpecialistButton() == null;
            testBoolean = testController.getCanUseCreateServicesButton() == null;
            testBoolean = testController.changeCoStatusIsLightDoc == null;
            testController.changeCoStatusDisableFollowUps = false;
            String coId = String.valueOf(testChangeOrderList[0].Id);
            testController.changeCoStatusCoId = coId;
            testController.changeCoStatusNewStatus = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{coId => new ChangeOrderModel(testChangeOrderList[0],
                                                                                                                    UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                    'test user role',
                                                                                                                    currentUserId,
                                                                                                                    testProposalList[0],
                                                                                                                    true,
                                                                                                                    testProjectTeamList[0],
                                                                                                                    true, true, true)};
            testController.pwm.changeOrderModelMap.get(coId).status = 'test status';
            testBoolean = testController.changeCOStatus() == null;
            testController.changeCoStatusNewStatus = testController.pwm.changeOrderModelMap.get(coId).status = 'test status';
            testController.changeCoStatusCoId = coId;
            testBoolean = testController.changeCOStatus() == null;

            testController.pwm.changeOrderModelMap = new Map<String, ChangeOrderModel>{coId => new ChangeOrderModel(testChangeOrderList[0],
                                                                                                                    UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                                    'test user role',
                                                                                                                    currentUserId,
                                                                                                                    testProposalList[0],
                                                                                                                    true,
                                                                                                                    testProjectTeamList[0],
                                                                                                                    true, true, true)};
            testController.changeCoStatusNewStatus = ChangeOrderServices.STATUS_APPROVED;
            testController.pwm.changeOrderModelMap.get(coId).status = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testController.changeCoStatusCoId = coId;
            testBoolean = testController.changeCOStatus() == null;
            testController.changeCoStatusNewStatus = ChangeOrderServices.STATUS_CANCELED;
            testController.pwm.changeOrderModelMap.get(coId).status = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testController.noteBody = '';
            testController.changeCoStatusCoId = coId;
            testBoolean = testController.changeCOStatus() == null;
            testController.changeCoStatusNewStatus = ChangeOrderServices.STATUS_CANCELED;
            testController.pwm.changeOrderModelMap.get(coId).status = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testController.noteBody = 'test reason';
            testController.changeCoStatusCoId = coId;
            testBoolean = testController.changeCOStatus() == null;
        Test.stopTest();

    }
}