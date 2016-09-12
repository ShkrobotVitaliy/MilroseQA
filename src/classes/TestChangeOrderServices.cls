@isTest
private class TestChangeOrderServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_CLIENT_PRICE = 3;
    private static final Integer NUMBER_OF_SERVICES_TO_INSERT = 5;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Proposal_Historical__c> testProposalsHistoricalList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Client_Price__c> testClientPriceList;
    private static List<ServiceModel> testServiceModelList;
    private static List<ChangeOrderModel> testChangeOrderModelList;
    private static List<Billing_Date__c> testBillingDateList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        testProductionManagerUser = TestingUtils.testProductionManagerUser = TestingUtils.userWithProfile (UserServices.PROFILE_PRODUCTION_MANAGER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, false);
        for(Account accountItem : testAccountList){
            accountItem.A_R_coordinator__c = currentUserId;
        }
        insert testAccountList;
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, testProductionManagerUser.id, projectManagerUser.Id, true);
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

    private static void createProposalListForTest(Integer numberToCreate, Boolean doInsert){
        testProposalList = TestingUtils.createProposalList (numberToCreate, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        if(doInsert){
            insert testProposalList;
        }
    }

    private static void setupChangeOrders(){
        testChangeOrderList = new List<Change_Order__c>();
        Map<Id, List<Change_Order__c>> projectProfileWithChangeOrderList = new Map<Id, List<Change_Order__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileWithChangeOrderList.put(projectProfileItem.Id, new List<Change_Order__c>());
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER * 2, false)){
                changeOrderItem.Project_Profile__c = projectProfileItem.Id;
                changeOrderItem.Proposal__c = projectProfileItem.Proposal__c;
                changeOrderItem.Approved_Date__c = null;
                changeOrderItem.Number__c = 0;
                testChangeOrderList.add(changeOrderItem);
                projectProfileWithChangeOrderList.get(projectProfileItem.Id).add(changeOrderItem);
            }
        }
        insert testChangeOrderList;
    }

    @isTest static void testUncoveredParts() {
        
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        testProductionManagerUser = TestingUtils.testProductionManagerUser = TestingUtils.userWithProfile (UserServices.PROFILE_PRODUCTION_MANAGER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, testProductionManagerUser.id, projectManagerUser.Id, true);

        setupData();
        createProposalListForTest( NUMBER_TO_CREATE_PROJECT_PROFILE, true );
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
            testProjectProfileList[i].Billing_Method__c = ProjectProfileServices.BILLINGMETHODINSTALLMENT;
            testProjectProfileList[i].Interval__c = true;
            testProjectProfileList[i].Frequency__c = ProjectProfileServices.FREQUENCY_MONTHLY;
            testProjectProfileList[i].Billing_day__c = '1';
        }
        insert testProjectProfileList;

        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>(testProjectProfileList);

        testBillingDateList = new List<Billing_Date__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(2, Date.today(), projectProfileItem.Id, false)){
                billingDateItem.Percentage__c = 55;
                billingDateItem.Billed__c = true;
                testBillingDateList.add(billingDateItem);
            }
        }
        insert testBillingDateList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Billing_Date__c billingDateItem : testBillingDateList){
            Project_Profile__c project = projectProfileMap.get(billingDateItem.Project_Profile__c);
            for(Billing_Line_Item__c bli : TestingUtils.createBillingLineItemList(1, billingDateItem.Project_Profile__c, project.Billing_Company_Name__c, project.Billing_Company_Contact__c, false)){
                bli.Billing_Date__c = billingDateItem.Id;
                bli.Description__c = 'test description';
                testBillingLineItemList.add(bli);
            }
        }
        insert testBillingLineItemList;

        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProposalList[i].Project_Profile__c = testProjectProfileList[i].Id;
        }
        update testProposalList;

        setupChangeOrders();
        testChangeOrderList = [SELECT Services_Total__c, Proposal__c, Project_Profile__c, Number__c, Internal_Reviewer__c,
                                        Id, CreatedDate, Approved_Date__c, Status__c
                               FROM Change_Order__c
                               WHERE Id IN : testChangeOrderList];

        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for(Service_Item__c si : TestingUtils.createServiceItemList( 2, projectProfileItem.Proposal__c, false)){
                si.Project_Profile__c = projectProfileItem.Id;
                serviceItemList.add(si);
            }
        }
        insert serviceItemList;

        Proposal_Historical__c proposalHistorical = new Proposal_Historical__c();
        proposalHistorical.Project_Name__c = 'test_project_name';
        INSERT proposalHistorical;

        Test.startTest();
            String changeOrderPrefix = ChangeOrderServices.changeOrderPrefix;
            SObject prepareProposalData = ChangeOrderServices.prepareProposalData( proposalHistorical.Id, true );
            ChangeOrderServices.updateChangeOrderNumber( testChangeOrderList );
            Map<Id, Change_Order__c> idToChangeOrderMap = new Map<Id, Change_Order__c> ();
            for(Change_Order__c cO : testChangeOrderList) {
                idToChangeOrderMap.put(cO.Id, cO);
                idToChangeOrderMap.get(cO.Id).Status__c = 'Draft';
                cO.Status__c = ChangeOrderServices.STATUS_PENDING_CLIENT;
            }
            Map<Id, Change_Order__c> filterPendingClientApprovalCO = ChangeOrderServices.filterPendingClientApprovalCO( testChangeOrderList, idToChangeOrderMap );
            ChangeOrderServices.populateChangeOrderSentDateField( new Map<Id, Change_Order__c> { testChangeOrderList[0].Id => testChangeOrderList[0] } );


            for(Service_Item__c sI : serviceItemList) {
                sI.Change_Order__c = testChangeOrderList[0].Id;
            }
            UPSERT serviceItemList;
            Map<Id, Map<String, Decimal>> getProjectIdToAmountTypeToAmountCO = ChangeOrderServices.getProjectIdToAmountTypeToAmountCO( new Set<Id> { testChangeOrderList[0].Id } );
            List<Roster_Email_Junction__c> filterEmailJunctionsAfterPendingClientApproval =
                                                    ChangeOrderServices.filterEmailJunctionsAfterPendingClientApproval( testChangeOrderList, idToChangeOrderMap );
            List<Change_Order__c> filterChangeOrdersAfterPendingClientApprovalToVoidEnvelopes = 
                                       ChangeOrderServices.filterChangeOrdersAfterPendingClientApprovalToVoidEnvelopes( testChangeOrderList, idToChangeOrderMap );
            ChangeOrderServices.updateReceivedPO( new Set<Id> { testChangeOrderList[0].Id } , serviceItemList );
            List<Change_Order__c> filterChangeOrdersChangesFromDraftToRequested =
                                                     ChangeOrderServices.filterChangeOrdersChangesFromDraftToRequested( testChangeOrderList, idToChangeOrderMap );
            ChangeOrderServices.updateProjectCompletedProjectState( testChangeOrderList );
            Set<Id> filteredComplatedApprovedChangeOrders = ChangeOrderServices.filteredComplatedApprovedChangeOrders( testChangeOrderList, idToChangeOrderMap );
            List<Change_Order__c> filterChangeOrdersWithoutNumbers = ChangeOrderServices.filterChangeOrdersWithoutNumbers( testChangeOrderList );

            UPSERT idToChangeOrderMap.values();

            for(Service_Item__c sI : serviceItemList) {
                sI.Unit_Price__c = 100;
                sI.Quantity__c = 5;
                sI.Discount_Percentage__c = 5;
                sI.Tax_Percent_1__c = 4;
                sI.Tax_Percent_2__c = 5;
//                sI.Is_Amendmend_Deleted__c = true;
            }
            UPSERT serviceItemList;

            ChangeOrderServices.createBliOrTaskForApprovedChangeOrders( idToChangeOrderMap );
        Test.stopTest();
    }

    private static testmethod void testUpdateChangeOrderNumbers(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testChangeOrderList = new List<Change_Order__c>();
        Map<Id, List<Change_Order__c>> projectProfileWithChangeOrderList = new Map<Id, List<Change_Order__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileWithChangeOrderList.put(projectProfileItem.Id, new List<Change_Order__c>());
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER * 2, false)){
                changeOrderItem.Project_Profile__c = projectProfileItem.Id;
                changeOrderItem.Approved_Date__c = null;
                changeOrderItem.Number__c = null;
                testChangeOrderList.add(changeOrderItem);
                projectProfileWithChangeOrderList.get(projectProfileItem.Id).add(changeOrderItem);
            }
        }
        insert testChangeOrderList;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            List<Change_Order__c> changeOrderListItem = projectProfileWithChangeOrderList.get(projectProfileItem.Id);
            for (Integer i = 0; i < NUMBER_TO_CREATE_CHANGE_ORDER; i++){
                changeOrderListItem[i].Approved_Date__c = Date.today().addDays(i);
                changeOrderListItem[i].Status__c = ChangeOrderServices.STATUS_APPROVED;
            }
        }
        update testChangeOrderList;

        Test.startTest();
            ChangeOrderServices.updateChangeOrderNumbers(new Map<Id, Change_Order__c>(testChangeOrderList));
        Test.stopTest();

        List<Change_Order__c> resultChangeOrderList = [SELECT Id, Approved_Date__c, Number__c, Project_Profile__c
                                                       FROM Change_Order__c
                                                       WHERE Project_Profile__c IN : testProjectProfileList Order By Number__c];
        Map <Id, List<Change_Order__c>> resultProjectWithChangOrderMap = new Map<Id, List<Change_Order__c>>();
        for (Change_Order__c changeOrderItem : resultChangeOrderList){
            if (!resultProjectWithChangOrderMap.containsKey(changeOrderItem.Project_Profile__c)){
                resultProjectWithChangOrderMap.put(changeOrderItem.Project_Profile__c, new List<Change_Order__c>());
            }
            System.assert(changeOrderItem.Number__c != null);
            resultProjectWithChangOrderMap.get(changeOrderItem.Project_Profile__c).add(changeOrderItem);
        }

        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), resultProjectWithChangOrderMap.keySet());
    }

    private static testmethod void testFilterApprovedChangeOrdersInsert(){
        testChangeOrderList = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER * 2, true);

        Set<Id> resultSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_CHANGE_ORDER; i++){
            testChangeOrderList[i].Status__c = ChangeOrderServices.STATUS_APPROVED;
            resultSetId.add(testChangeOrderList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_CHANGE_ORDER; i < NUMBER_TO_CREATE_CHANGE_ORDER * 2; i++){
            testChangeOrderList[i].Status__c = 'test status';
            resultSetId.add(testChangeOrderList[i].Id);
        }

        Map<Id, Change_Order__c> resultChangOrderMap;

        Test.startTest();
            resultChangOrderMap = ChangeOrderServices.filterApprovedChangeOrders(testChangeOrderList, null);
        Test.stopTest();

        System.assert(resultChangOrderMap != null);
        System.assert(!resultChangOrderMap.isEmpty());
        //System.assertEquals(resultSetId, new Map<Id, Change_Order__c>(testChangeOrderList).keySet());
    }


    private static testmethod void testFilterApprovedChangeOrdersUpdate(){
        testChangeOrderList = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER * 2, true);

        testChangeOrderList = [SELECT Id, Status__c
                               FROM Change_Order__c
                               WHERE Id IN : testChangeOrderList];

        Map<Id, Change_Order__c> changeOrderMapOld = new Map<Id, Change_Order__c>(testChangeOrderList.deepClone(true));

        Set<Id> resultSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_CHANGE_ORDER; i++){
            testChangeOrderList[i].Status__c = ChangeOrderServices.STATUS_APPROVED;
            resultSetId.add(testChangeOrderList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_CHANGE_ORDER; i < NUMBER_TO_CREATE_CHANGE_ORDER * 2; i++){
            testChangeOrderList[i].Status__c = 'test status';
            resultSetId.add(testChangeOrderList[i].Id);
        }

        Map<Id, Change_Order__c> resultChangOrderMap;

        Test.startTest();
            resultChangOrderMap = ChangeOrderServices.filterApprovedChangeOrders(testChangeOrderList, changeOrderMapOld);
        Test.stopTest();

        System.assert(resultChangOrderMap != null);
        System.assert(!resultChangOrderMap.isEmpty());
    }

    private static testmethod void testGetServicesTotal(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testClientPriceList = TestingUtils.createClientPriceList(NUMBER_TO_CREATE_CLIENT_PRICE, false);
        testServiceModelList = new List<ServiceModel>();

        testChangeOrderList = TestingUtils.createChangeOrderList(1, true);

        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Client_Price__c clientPriceItem : testClientPriceList){
                ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.quantityOld = 100;
                serviceModelItem.changeOrderId = testChangeOrderList[0].Id;
                testServiceModelList.add(serviceModelItem);

                serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.quantityOld = 100;
                serviceModelItem.changeOrderId = null;
                testServiceModelList.add(serviceModelItem);

                serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.quantityOld = 0;
                serviceModelItem.isAmendmendDeleted = true;
                serviceModelItem.changeOrderId = testChangeOrderList[0].Id;
                testServiceModelList.add(serviceModelItem);

                serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.quantityOld = 0;
                serviceModelItem.isAmendmendDeleted = false;
                serviceModelItem.changeOrderId = testChangeOrderList[0].Id;
                testServiceModelList.add(serviceModelItem);
            }
        }

        Decimal resultDecimal;

        Test.startTest();
            resultDecimal = ChangeOrderServices.getServicesTotal(testServiceModelList, testChangeOrderList[0].Id);
        Test.stopTest();

        System.assert(resultDecimal != null);
    }

    private static testmethod void testGetServicesTotalDiscounted(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        setupChangeOrders();

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testClientPriceList = TestingUtils.createClientPriceList(NUMBER_TO_CREATE_CLIENT_PRICE, false);
        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Client_Price__c clientPriceItem : testClientPriceList){
                ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.isAmendmendDeleted = false;
                testServiceModelList.add(serviceModelItem);
            }
        }

        testServiceModelList.get(0).quantityOld = 10;
        testServiceModelList.get(0).changeOrderId = null;

        testServiceModelList.get(1).quantityOld = 10;
        testServiceModelList.get(1).changeOrderId = testChangeOrderList[0].Id;

        testServiceModelList.get(2).isAmendmendDeleted = true;

        Decimal resultDecimal;

        Test.startTest();
            resultDecimal = ChangeOrderServices.getServicesTotalDiscounted(testServiceModelList, testChangeOrderList[0].Id);
        Test.stopTest();

        System.assert(resultDecimal != null);
    }

    private static testmethod void testGetServicesTotalSalesTax(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        setupChangeOrders();

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testClientPriceList = TestingUtils.createClientPriceList(NUMBER_TO_CREATE_CLIENT_PRICE, false);
        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Client_Price__c clientPriceItem : testClientPriceList){
                ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.isAmendmendDeleted = false;
                testServiceModelList.add(serviceModelItem);
            }
        }

        testServiceModelList.get(0).quantityOld = 10;
        testServiceModelList.get(0).changeOrderId = null;

        testServiceModelList.get(1).quantityOld = 10;
        testServiceModelList.get(1).changeOrderId = testChangeOrderList[0].Id;

        //isQuantityChangeOrder == false;
        testServiceModelList.get(2).isAmendmendDeleted = true;

        Decimal resultDecimal;

        testChangeOrderList = TestingUtils.createChangeOrderList(1, true);

        Test.startTest();
            resultDecimal = ChangeOrderServices.getServicesTotalSalesTax(testServiceModelList, testChangeOrderList[0].Id);
        Test.stopTest();

        System.assert(resultDecimal == 0);
    }

    private static testmethod void testAreThereOnlyDraftCOsStatusDraft(){
        setupData ();
        testChangeOrderList = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, true);
        testChangeOrderList = [SELECT Services_Total__c, Proposal__c, Project_Profile__c, Number__c, Internal_Reviewer__c,
                                        Id, CreatedDate, Approved_Date__c
                               FROM Change_Order__c
                               WHERE Id IN : testChangeOrderList];
        testChangeOrderModelList = new List<ChangeOrderModel>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            changeOrderItem.Status__c = ChangeOrderServices.STATUS_DRAFT;
            changeOrderItem.Number__c = 0;
            ChangeOrderModel changeOrderModelItem = new ChangeOrderModel( changeOrderItem,
                                                                          UserServices.PROFILE_PROJECT_MANAGER_2,
                                                                          UserServices.ROLE_CZ_MANAGER,
                                                                          null,
                                                                          TestingUtils.createProposalList(1, null,null,null,null, null,null,null,null,null, null, null,null,null, true)[0],
                                                                          true,
                                                                          testProjectTeamList[0],
                                                                          true,
                                                                          true,
                                                                          true );
            testChangeOrderModelList.add(changeOrderModelItem);
        }

        Boolean resultBoolean;

        Test.startTest();
            resultBoolean = ChangeOrderServices.areThereOnlyDraftCOs(testChangeOrderModelList);
        Test.stopTest();

        System.assert(resultBoolean);
    }

    private static testmethod void testAreThereOnlyDraftCOsStatusNotDraft(){
        setupData ();
        testChangeOrderList = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, true);
        testChangeOrderList = [SELECT Services_Total__c, Proposal__c, Project_Profile__c, Number__c, Internal_Reviewer__c,
                                        Id, CreatedDate, Approved_Date__c
                               FROM Change_Order__c
                               WHERE Id IN : testChangeOrderList];

        testChangeOrderModelList = new List<ChangeOrderModel>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            changeOrderItem.Status__c = 'test status';
            changeOrderItem.Number__c = 0;
            ChangeOrderModel changeOrderModelItem = new ChangeOrderModel ( changeOrderItem,
                                                                           UserServices.PROFILE_PROJECT_MANAGER_2,
                                                                           UserServices.ROLE_CZ_MANAGER,
                                                                           null,
                                                                           TestingUtils.createProposalList(1, null,null,null,null, null,null,null,null,null, null, null,null,null, true)[0],
                                                                           true,
                                                                           testProjectTeamList[0],
                                                                           true,
                                                                           true,
                                                                           true );

            testChangeOrderModelList.add(changeOrderModelItem);
        }

        Boolean resultBoolean;

        Test.startTest();
            resultBoolean = ChangeOrderServices.areThereOnlyDraftCOs(testChangeOrderModelList);
            //for coverage
            SObject test1 = ChangeOrderServices.prepareProposalData( TestingUtils.createProposalListForTest(1, true)[0].Id, false );
            //SObject test2 = ChangeOrderServices.prepareProposalData( TestingUtils.createProposalListForTest(1, true)[0].Id, true );
            ChangeOrderServices.prepareProposalGeneralData( TestingUtils.createProposalListForTest(1, true) );
        Test.stopTest();

        System.assert(!resultBoolean);
    }

    private static testmethod void testGetProposalsFromChangeOrders(){
        setupData();
        createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        Map<Id, Proposal__c> resultProposalMap;

        Test.startTest();
            resultProposalMap = ChangeOrderServices.getProposalsFromChangeOrders(testChangeOrderList);
        Test.stopTest();

        System.assert(resultProposalMap != null && !resultProposalMap.isEmpty());
        System.assertEquals(new Map<Id, Proposal__c>(testProposalList).keySet(), resultProposalMap.keySet());
    }

    private static testmethod void testFilterChangeOrdersInCZScopingReview(){
        testChangeOrderList = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER * 2, true);
        testChangeOrderList = [SELECT Id, Status__c FROM Change_Order__c WHERE Id IN : testChangeOrderList];

        Map<Id, Change_Order__c> changeOrderMapOld = new Map<Id, Change_Order__c>(testChangeOrderList.deepClone(true));

        Set<Id> resultSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_CHANGE_ORDER; i++){
            testChangeOrderList[i].Status__c = ChangeOrderServices.STATUS_IN_CZ_REVIEW;
            resultSetId.add(testChangeOrderList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_CHANGE_ORDER; i < NUMBER_TO_CREATE_CHANGE_ORDER * 2; i++){
            testChangeOrderList[i].Status__c = 'test status';
            resultSetId.add(testChangeOrderList[i].Id);
        }

        Map<Id, Change_Order__c> resultChangOrderMap;

        Test.startTest();
            resultChangOrderMap = ChangeOrderServices.filterChangeOrdersInCZScopingReview(new Map<Id, Change_Order__c>(testChangeOrderList), changeOrderMapOld);
        Test.stopTest();

        System.assert(resultChangOrderMap != null);
        System.assert(!resultChangOrderMap.isEmpty());
    }

    private static testmethod void testIsMaxCompletness(){
        setupData();

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testClientPriceList = TestingUtils.createClientPriceList(NUMBER_TO_CREATE_CLIENT_PRICE, false);
        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Client_Price__c clientPriceItem : testClientPriceList){
                ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, clientPriceItem);
                serviceModelItem.isAmendmendDeleted = false;
                testServiceModelList.add(serviceModelItem);
            }
        }

        Boolean result;

        Test.startTest();
            result = ChangeOrderServices.isMaxCompleteness(testServiceModelList);
        Test.stopTest();

        System.assert(! result);
    }

    private static testmethod void testGetChangeOrders(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
		Proposal__c proposal = TestingUtils.createProposalListForTest(1, false)[0];
		proposal.Project_Profile__c = testProjectProfileList.get(0).Id;
		INSERT proposal;

        List<Change_Order__c> results;

        Test.startTest();
             results = ChangeOrderServices.getChangeOrdersByProjectProfileId(testProjectProfileList.get(0).Id, proposal);
        Test.stopTest();

        System.assert(results.isEmpty() );
    }


    private static testmethod void testCreateBliOrTaskForApprovedChangeOrders(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
            projectProfileItem.Frequency__c = ProjectProfileServices.FREQUENCY_MONTHLY;
            projectProfileItem.Billing_day__c = '1';
        }
        insert testProjectProfileList;
        setupChangeOrders();

        System.assert(! testChangeOrderList.isEmpty() );

        Test.startTest();
             ChangeOrderServices.createBliOrTaskForApprovedChangeOrders( new Map<Id, Change_Order__c>(testChangeOrderList) );
        Test.stopTest();
    }

    private static testmethod void testGetProjectIdToAmountTypeToAmountCO(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
            projectProfileItem.Frequency__c = ProjectProfileServices.FREQUENCY_MONTHLY;
            projectProfileItem.Billing_day__c = '1';
        }
        insert testProjectProfileList;
        setupChangeOrders();

        System.assert(! testChangeOrderList.isEmpty() );

        Test.startTest();

             Map<Id, Map<String, Decimal>> result = ChangeOrderServices.getProjectIdToAmountTypeToAmountCO( new Map<Id, Change_Order__c>(testChangeOrderList).keySet() );
             System.assert(! result.isEmpty());

        Test.stopTest();
    }
}