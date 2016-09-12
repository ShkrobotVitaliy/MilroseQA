@isTest
private class TestProposalServices{
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 6;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 7;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;
    private static final Integer NUMBER_TO_CREATE_EVENT = 2;
    private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 3;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 3;
    private static final String PROJECT_MANAGER_PROFILE_NAME = 'Project Manager 2';
    private static final List<String> TASK_TEMPLATE_NAME_LIST = new List<String>{'first', 'second', 'third', 'fourth'};

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Event> testEventList;
    private static List<Task> testTaskList;
    private static List<Proposal_Historical__c> testProposalHistoricalList;
    private static List<Service_Historical__c> testServiceHistoricalList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Proposal__c> testProposalDraftList;
    private static List<LStore__Stored_Document__c> testLStoreStoredDocumentList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void createProposalsForTest(Integer numberToCreate, Id projectProfileId, Boolean doInsert){
        testProposalList = TestingUtils.createProposalListForTest(numberToCreate, doInsert);
    }

    // create Proposal and Project Profile objects
    private static void prepareData(Integer numberToCreate, Boolean doInsert){
        TestingUtils.createProposalWithProjectProfileList(numberToCreate);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
    }

    @isTest static void testFilterProposalsWithChangedTaxStatus() {
        List<Account> accounts = TestingUtils.createAccountList(2, null, false);
        accounts[0].c2g__CODASalesTaxStatus__c = 'Exempt';
        accounts[1].c2g__CODASalesTaxStatus__c = 'Taxable';
        INSERT accounts;

        List<Proposal__c> proposals = TestingUtils.createProposalListForTest(1, true);
        proposals[0].Billing_Company_Name__c = accounts[0].Id;

        Proposal__c singlProposal = new Proposal__c(Id = proposals[0].Id, Billing_Company_Name__c = accounts[1].Id);

        List<Set<Id>> result = ProposalServices.filterProposalsWithChangedTaxStatus(new List<Proposal__c> {singlProposal}, new Map<Id, Proposal__c> { proposals[0].Id => proposals[0]});
        result = ProposalServices.filterProposalsWithChangedTaxStatus(new List<Proposal__c> {proposals[0]}, new Map<Id, Proposal__c> { singlProposal.Id => singlProposal});
    }

    @isTest static void testUncoveredParts() {
        User user = TestingUtils.userWithProfile( UserServices.PROFILE_PRODUCTION_MANAGER );
        List<Proposal__c> listNew = TestingUtils.createProposalListForTest( 1, false);
        for( Proposal__c p : listNew ) {
            p.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        UPSERT listNew;
        List<Id> setProposalIds = new List<Id> ();
        Map<Id, Proposal__c> mapOfProposals = new Map<Id, Proposal__c> ();
        for( Proposal__c p : listNew ) {
            mapOfProposals.put( p.Id, p );
            setProposalIds.add( p.Id );
        }
        mapOfProposals.get(listNew[0].Id).Status__c = ProposalServices.PROPOSAL_STATUS_CANCELLED;
        List<Project_Profile__c> projectList = TestingUtils.createProjectProfileForTest( 1, false);
        UPSERT projectList;
        List<Project_Profile__c> oldProjects = TestingUtils.createProjectProfileForTest( 1, false);
        for( Project_Profile__c pP : oldProjects ) {
            pP.Proposal_Specialist__c = user.Id;
        }
        UPSERT oldProjects;
        Map<Id, Project_Profile__c> mapOfProjects = new Map<Id, Project_Profile__c> ();
        for( Project_Profile__c p : projectList ) {
            mapOfProjects.put( p.Id, new Project_Profile__c( Id=p.Id, Production_Manager__c = user.Id ) );
        }

        String proposalPrefix = ProposalServices.proposalPrefix;
        List<Proposal__c> filterProposalsToChangeVersion = ProposalServices.filterProposalsToChangeVersion( listNew, mapOfProposals );
        List<Proposal__c> filterProposalsAfterPendingClientApprovalToVoidEnvelopes = ProposalServices.filterProposalsAfterPendingClientApprovalToVoidEnvelopes( listNew, mapOfProposals );
        ProposalServices.addRejectionReasonAfterReject( listNew );
        ProposalServices.syncProposalFields( projectList, oldProjects, oldProjects, oldProjects, mapOfProjects);
        List<Change_Order__c> coList = TestingUtils.createChangeOrderList( 1, true);
        coList[0].Proposal__c = listNew[0].Id;
        ProposalServices.cleanUpCZAnalystData( new Map <Id, Change_Order__c> { coList[0].Id => coList[0] } );
        List<Roster_Email_Junction__c> filterEmailJunctionsAfterPendingClientApproval = ProposalServices.filterEmailJunctionsAfterPendingClientApproval( listNew, mapOfProposals);
        ProposalServices.updateBaseServicesTotal( setProposalIds );
    }

    private static testmethod void testFilterProposalWithStatusAwardedForProjectProfileCreation(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL * 3, null, true);

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Map<Id, Proposal__c> oldProposalMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));

        Set<Id> resultSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_PROPOSAL; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            testProposalList[i].Project_Profile__c = null;
            resultSetId.add(testProposalList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_PROPOSAL; i < NUMBER_TO_CREATE_PROPOSAL * 2; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            testProposalList[i].Project_Profile__c = testProjectProfileList[0].Id;
        }

        for (Integer i = NUMBER_TO_CREATE_PROPOSAL * 2; i < NUMBER_TO_CREATE_PROPOSAL * 3; i++){
            testProposalList[i].Status__c = 'test status value';
            testProposalList[i].Project_Profile__c = testProjectProfileList[0].Id;
        }

        Map<Id, Proposal__c> resultProposalMap;

        Test.startTest();
            resultProposalMap = ProposalServices.filterProposalWithStatusAwardedForProjectProfileCreation(testProposalList, oldProposalMap);
        Test.stopTest();

        System.assert(!resultProposalMap.isEmpty());
        System.assertEquals(resultSetId.size(), resultProposalMap.keySet().size());
        System.assertEquals(resultSetId, resultProposalMap.keySet());
    }

    private static testmethod void testFilterProposalWithStatusFailedInternalReviewForAddRejectionReasonAfterReject(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < 5; i++){
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW, Rejection_Reason__c = ''));
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW, Rejection_Reason__c = 'some reason'));
            testProposalList.add(new Proposal__c(Status__c = 'test status value', Rejection_Reason__c = 'some reason'));
            testProposalList.add(new Proposal__c(Status__c = 'test status value', Rejection_Reason__c = ''));
        }

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.filterProposalWithStatusFailedInternalReviewForAddRejectionReasonAfterReject(testProposalList);
        Test.stopTest();

        System.assert(! resultProposalList.isEmpty());

        for (Proposal__c proposalItem : resultProposalList){
            System.assert((proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW) && String.isEmpty(proposalItem.Rejection_Reason__c));
        }
    }

    private static testmethod void testFilterProposalWithStatusRejectedForProposalHistoricalCreation(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < 5; i++){
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED));
            testProposalList.add(new Proposal__c(Status__c = 'test status value'));
        }

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.filterProposalWithStatusRejectedForProposalHistoricalCreation(testProposalList);
        Test.stopTest();

        System.assert(! resultProposalList.isEmpty());

        for (Proposal__c proposalItem : resultProposalList){
            System.assert(proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED);
        }
    }

    private static testmethod void testFilterProposalWithStatusPendingClientApproval(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < 5; i++){
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT));
            testProposalList.add(new Proposal__c(Status__c = 'test status value'));
        }

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.filterProposalWithStatusPendingClientApproval(testProposalList);
        Test.stopTest();

        System.assert(! resultProposalList.isEmpty());

        for (Proposal__c proposalItem : resultProposalList){
            System.assert(proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT);
        }
    }

    private static testmethod void testFilterProposalWithStatusChangeOrderApproved(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < 5; i++){
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED));
            testProposalList.add(new Proposal__c(Status__c = 'test status value'));
        }

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.filterProposalWithStatusChangeOrderApproved(testProposalList);
        Test.stopTest();

        System.assert(! resultProposalList.isEmpty());

        for (Proposal__c proposalItem : resultProposalList){
            System.assert(proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED);
        }
    }

    private static testmethod void testFilteredProposalsForStatusAwardwd(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < 5; i++){
            testProposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED, Project_Profile__c = null));
            testProposalList.add(new Proposal__c(Status__c = 'test status value', Project_Profile__c = null));
        }

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.filteredProposals(testProposalList, ProposalServices.PROPOSAL_STATUS_AWARDED);
        Test.stopTest();

        System.assert(! resultProposalList.isEmpty());

        for (Proposal__c proposalItem : resultProposalList){
            System.assert(proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED && proposalItem.Project_Profile__c == null);
        }
    }

    private static testmethod void testCreateProposalHistorical(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL * 2, null, false);
        for (Integer i = 0; i < NUMBER_TO_CREATE_PROPOSAL; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            testProposalList[i].Change_History__c = null;
        }
        for (Integer i = NUMBER_TO_CREATE_PROPOSAL; i < NUMBER_TO_CREATE_PROPOSAL * 2; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            testProposalList[i].Change_History__c = 'some text';
        }
        insert testProposalList;
        testProposalList = [SELECT Id, Name, Project_Name__c, Version__c, Change_History__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        Map<Id, Proposal__c> oldProposalMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));

        testServiceItemList = new List<Service_Item__c>();

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED;
            testServiceItemList.addAll(TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false));
        }
        insert testServiceItemList;

        Test.startTest();
            ProposalServices.createProposalHistorical(testProposalList, oldProposalMap);
        Test.stopTest();

        testProposalHistoricalList = [SELECT Id, Proposal__c, Name, Proposal__r.Name, Version__c, Proposal__r.Version__c,
                                            Project_Name__c, Proposal__r.Project_Name__c
                                      FROM Proposal_Historical__c];

        System.assert(!testProposalHistoricalList.isEmpty());
        System.assertEquals(testProposalList.size(), testProposalHistoricalList.size());

        Set<Id> assertionSetId = new Set<Id>();

        for (Proposal_Historical__c proposalHistoricalItem : testProposalHistoricalList){
            System.assert(proposalHistoricalItem.Proposal__c != null);
            assertionSetId.add(proposalHistoricalItem.Proposal__c);
            System.assertEquals(proposalHistoricalItem.Proposal__r.Name, proposalHistoricalItem.Name);
            System.assertEquals(proposalHistoricalItem.Proposal__r.Version__c, proposalHistoricalItem.Version__c);
            System.assertEquals(proposalHistoricalItem.Proposal__r.Project_Name__c, proposalHistoricalItem.Project_Name__c);
        }

        System.assertEquals(oldProposalMap.keySet(), assertionSetId);

        testServiceHistoricalList = [SELECT Id, Proposal_Historical__c, Proposal_Historical__r.Proposal__c, Service_Item__c,
                                            Service_Item__r.Proposal__c
                                     FROM Service_Historical__c
                                     WHERE Proposal_Historical__c IN : testProposalHistoricalList];

        System.assert(!testServiceHistoricalList.isEmpty());
        System.assertEquals(testServiceItemList.size(), testServiceHistoricalList.size());

        assertionSetId = new Set<Id>();

        for (Service_Historical__c serviceHistoricalItem : testServiceHistoricalList){
            System.assert(serviceHistoricalItem.Proposal_Historical__c != null && serviceHistoricalItem.Service_Item__c != null);
            assertionSetId.add(serviceHistoricalItem.Service_Item__c);
            System.assertEquals(serviceHistoricalItem.Proposal_Historical__r.Proposal__c, serviceHistoricalItem.Service_Item__r.Proposal__c);
        }

        System.assertEquals(assertionSetId, new Map<Id, Service_Item__c>(testServiceItemList).keySet());
    }

    private static testmethod void testCreateProposalHistoricalWithIncorrectData(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL * 2, null, false);
        for (Integer i = 0; i < NUMBER_TO_CREATE_PROPOSAL; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            testProposalList[i].Change_History__c = null;
        }
        for (Integer i = NUMBER_TO_CREATE_PROPOSAL; i < NUMBER_TO_CREATE_PROPOSAL * 2; i++){
            testProposalList[i].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
            testProposalList[i].Change_History__c = 'some text';
        }
        insert testProposalList;
        testProposalList = [SELECT Id, Name, Project_Name__c, Version__c, Change_History__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        Id proposalIncorrecrId = Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000';
        Proposal__c incorrectProposal = testProposalList[0].clone(true, true, true);
        incorrectProposal.Id = proposalIncorrecrId;
        testProposalList.add(incorrectProposal);

        Map<Id, Proposal__c> oldProposalMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));

        Test.startTest();
            ProposalServices.createProposalHistorical(testProposalList, oldProposalMap);
        Test.stopTest();

        testProposalHistoricalList = [SELECT Id, Proposal__c, Name, Proposal__r.Name, Version__c, Proposal__r.Version__c,
                                            Project_Name__c, Proposal__r.Project_Name__c
                                      FROM Proposal_Historical__c];

        System.assert( testProposalHistoricalList.isEmpty());
    }

    private static testmethod void testPreventDeleteProposalIfStatusAwarded(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            ProposalServices.preventDeleteProposalIfStatusAwarded(testProposalList);
        Test.stopTest();
        
    }

    private static testmethod void testPreventDeleteProposalIfStatusAwardedOnTrigger(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
        }
        update testProposalList;

        testProposalList = [SELECT Id, Status__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        for (Proposal__c proposalItem : testProposalList){
            System.assert(proposalItem.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED);
        }

        System.assert(! testProposalList.isEmpty());

        String errorString;

        Test.startTest();
            try{
                delete testProposalList;
            } catch (DMLException dmlEx){
                errorString = dmlEx.getMessage();
            }
        Test.stopTest();

//      System.assert(!String.isEmpty(errorString));
//      System.assert(errorString.contains(Label.Delete_Awarded_Proposal_Error));
//      List<Proposal__c> testresultProposalList = [SELECT Id
//                                                  FROM Proposal__c
//                                                  WHERE Id IN : testProposalList];

//      System.assert(!testresultProposalList.isEmpty());
//      System.assertEquals(testProposalList.size(), testresultProposalList.size());
//      System.assertEquals(new Map<Id, Proposal__c>(testProposalList).keySet(), new Map<Id, Proposal__c>(testresultProposalList).keySet());
    }

    private static testmethod void testFilterProposalDraftWithChangedStatus(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        Map<Id, Proposal__c> proposalsNewMap = new Map<Id, Proposal__c>();
        Map<Id, Proposal__c> proposalsOldMap = new Map<Id, Proposal__c>();

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = 'old status';
            proposalsOldMap.put(proposalItem.Id, proposalItem);
        }

        for (Proposal__c proposalItem : testProposalList.deepClone(true)){
            proposalItem.Status__c = 'new status';
            proposalsNewMap.put(proposalItem.Id, proposalItem);
        }

        Map<Id, Proposal__c> resultProposalsMap;

        Test.startTest();
            resultProposalsMap = ProposalServices.filterProposalsWithChangedStatus(proposalsNewMap, proposalsOldMap);
        Test.stopTest();

        System.assert(!resultProposalsMap.isEmpty());
        System.assertEquals(new Map<Id, Proposal__c>(testProposalList).keySet(), resultProposalsMap.keySet());
    }

    private static testmethod void testChangedAssigneeOnProposal(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = null;
        }
        insert testProposalList;

        testProposalList = [SELECT Id, Project_Team__c, Resource__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        Map<Id, Proposal__c> oldProposalMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = testProjectTeamList[0].Id;
            proposalItem.Resource__c = currentUserId;
        }

        Map<Id, Proposal__c> resultProposalMap;

        Test.startTest();
            resultProposalMap = ProposalServices.changedAssigneeOnProposal(testProposalList, oldProposalMap);
        Test.stopTest();

        System.assert(!resultProposalMap.isEmpty());
        System.assertEquals(new Map<Id, Proposal__c>(testProposalList).keySet(), resultProposalMap.keySet());
    }

    private static testmethod void testDummyUpdateRostersForWorkflowReminders(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, true);

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            ProposalServices.dummyUpdateRostersForWorkflowReminders(testProposalList);
        Test.stopTest();

    }

    private static testmethod void testGetProposalById(){
        setupData();
        createProposalsForTest(NUMBER_TO_CREATE_PROPOSAL, null, true);

        List<Proposal__c> resultProposalList;

        Test.startTest();
            resultProposalList = ProposalServices.getProposalById(testProposalList[0].Id);
        Test.stopTest();

        System.assert(!resultProposalList.isEmpty());
        System.assertEquals(1, resultProposalList.size());
        System.assertEquals(testProposalList[0].Id, resultProposalList[0].Id);
    }

    private static testmethod void testGetProposalIdByProjectId(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        Id resultProposalId;

        Test.startTest();
            resultProposalId = ProposalServices.getProposalIdByProjectId(testProjectProfileList[0].Id);
        Test.stopTest();

        System.assert(resultProposalId != null);
        //System.assertEquals(testProjectProfileList[0].Id, new Map<Id, Proposal__c>(testProposalList).get(resultProposalId).Project_Profile__c);
    }

    private static testmethod void testGetProposalIdByProjectIdWithoutProjectProfile(){
        String errorString;

        Id resultProposalId;

        Test.startTest();

            try{
                resultProposalId = ProposalServices.getProposalIdByProjectId(null);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(resultProposalId == null);
        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testGetProposalIdByProjectIdWithProjectProfileWithoutProposal(){
        Id projectProfileId = Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000';

        String errorString;

        Id resultProposalId;

        Test.startTest();

            try{
                resultProposalId = ProposalServices.getProposalIdByProjectId(projectProfileId);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(resultProposalId == null);
        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testUpdateProposalVersionForNewWithProjectProfile(){
        // create test Account, Contact, Building
        setupData();

        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            ProposalServices.updateProposalVersion(testProposalList);

        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
//            System.assertEquals (ProposalServices.VERSION_MINOR_STEP, proposalItem.Version__c);
        }
    }

    private static testmethod void testUpdateProposalVersionForAwardedProjectProfile(){
        // create test Account, Contact, Building
        setupData();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        Map<Id, Proposal__c> proposalOldMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));
        for (Proposal__c proposalItem : proposalOldMap.values()){
            proposalItem.Status__c = 'test';
        }

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            proposalItem.Version__c = 1.1;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            ProposalServices.updateProposalVersion(testProposalList);

        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
//            System.assertEquals (ProposalServices.VERSION_MINOR_STEP, proposalItem.Version__c);
        }
    }

    private static testmethod void testUpdateProposalVersionForRejectedProjectProfile(){
        // create test Account, Contact, Building
        setupData();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        Map<Id, Proposal__c> proposalOldMap = new Map<Id, Proposal__c>(testProposalList.deepClone(true));
        for (Proposal__c proposalItem : proposalOldMap.values()){
            proposalItem.Status__c = 'test';
        }

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED;
            proposalItem.Version__c = 1.1;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            ProposalServices.updateProposalVersion(testProposalList);

        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
//            System.assertEquals (ProposalServices.VERSION_MINOR_STEP, proposalItem.Version__c);
        }
    }

    private static testmethod void testUpdateProposalVersionForNewWithProjectProfileUpdate(){
        setupData();
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
            //System.assertEquals (NUMBER_TO_CREATE_PROPOSAL + Decimal.valueOf(NUMBER_TO_CREATE_PROPOSAL + ProposalServices.VERSION_MAJOR_STEP).Divide(10, 1), proposalItem.Version__c.setScale(1));
        }
    }

    private static testmethod void testUpdateProposalVersionForNewWithProjectProfileOnUpdate(){
        setupData();
        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
            //System.assertEquals (NUMBER_TO_CREATE_PROPOSAL + Decimal.valueOf(NUMBER_TO_CREATE_PROPOSAL + ProposalServices.VERSION_MAJOR_STEP).Divide(10, 1), proposalItem.Version__c.setScale(1));
        }
    }

    private static testmethod void testUpdateProposalVersionForNotAwardedWithProjectProfileUpdate(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
            //System.assertEquals (NUMBER_TO_CREATE_PROPOSAL + Decimal.valueOf(NUMBER_TO_CREATE_PROPOSAL + 1).Divide(10, 1), proposalItem.Version__c);
        }
    }

    private static testmethod void testUpdateProposalVersionForAwardedWithProjectProfileUpdate(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
             System.debug(LoggingLevel.Error,'@@@proposalItem.Status__c ' + proposalItem.Status__c );
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        for (Proposal__c proposalItem : [SELECT Id, Version__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
//          System.assertEquals (Decimal.valueOf(NUMBER_TO_CREATE_PROPOSAL + ProposalServices.VERSION_MAJOR_STEP).setScale(1), proposalItem.Version__c);
        }
    }

    private static testmethod void testUpdateProposalVersionChangeOrder(){
        setupData();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Version__c = 1.1;
        }
        insert testproposalList;

        Map<Id, List<Change_Order__c>> proposalWithChangeOrderList = new Map<Id, List<Change_Order__c>>();

        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            proposalWithChangeOrderList.put(proposalItem.Id, new List<Change_Order__c>());
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                changeOrderItem.Status__c = ChangeOrderServices.STATUS_APPROVED;
                testChangeOrderList.add(changeOrderItem);
                proposalWithChangeOrderList.get(proposalItem.Id).add(changeOrderItem);
            }
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                changeOrderItem.Status__c = 'not equals ' + ChangeOrderServices.STATUS_APPROVED;
                testChangeOrderList.add(changeOrderItem);
                proposalWithChangeOrderList.get(proposalItem.Id).add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        System.assert(! testChangeOrderList.isEmpty());
        System.assert(! proposalWithChangeOrderList.isEmpty());

        Test.startTest();

            ProposalServices.updateProposalVersion(proposalWithChangeOrderList);

        Test.stopTest();
    }

    public static testmethod void testCreateEvents(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        testEventList = [SELECT Id, WhatId, Description, WhoId, Subject, StartDateTime, ReminderDateTime, EndDateTime
                         FROM Event
                         WHERE WhatId IN : testProposalList];
        //System.assertEquals(testProposalList.size() * 2, testEventList.size());

        Map<Id, Proposal__c> mapIdProposal = new Map<Id, Proposal__c>([SELECT Id, Proposal_Send_Reminder__c, Proposal_Expiration_Date__c FROM Proposal__c WHERE Id IN : testProposalList]);
        /*for (Event eventItem : testEventList){
            Proposal__c proposalItem = mapIdProposal.get(eventItem.WhatId);
            System.assert (eventItem.Description == 'Reminder for Client' || eventItem.Description == 'Cancel Proposal');
            System.assert (eventItem.Subject == 'Reminder for Client' || eventItem.Subject == 'Cancel Proposal');
            System.assertEquals (eventItem.Description == 'Reminder for Client' ? proposalItem.Proposal_Send_Reminder__c : proposalItem.Proposal_Send_Reminder__c, eventItem.StartDateTime);
            System.assertEquals (eventItem.Description == 'Reminder for Client' ? proposalItem.Proposal_Send_Reminder__c : proposalItem.Proposal_Send_Reminder__c, eventItem.EndDateTime);
        }*/
    }


    public static testmethod void testDeleteEvents(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;

        }
        update testProposalList;

        testEventList = [SELECT Id, WhatId
                         FROM Event
                         WHERE WhatId IN : testProposalList];
        //System.assertEquals(testProposalList.size() * 2, testEventList.size());

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NOT_AWARDED;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        testEventList = [SELECT Id, WhatId
                         FROM Event
                         WHERE WhatId IN : testProposalList];
        //System.assert(testEventList.isEmpty());
    }

//commented by pvl

/*
    public static testmethod void testUpdateChangeHistory(){
        // create test Account, Contact, Building
        setupData();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        List<sObject> testSObjectList = new List<sObject>();

        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);
        for (Proposal__c proposalDraftItem : testProposalDraftList){
            testSObjectList.add(proposalDraftItem);
        }

        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            testSObjectList.add(proposalItem);
            for (Change_Order__c cnangeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                cnangeOrderItem.Proposal__c = proposalItem.Id;
                testChangeOrderList.add(cnangeOrderItem);
                testSObjectList.add(cnangeOrderItem);
            }
        }
        insert testChangeOrderList;

        System.assert(! testChangeOrderList.isEmpty());
        System.assert(! testSObjectList.isEmpty());

        Test.startTest();

            ProposalServices.updateChangeHistory(testSObjectList);

        Test.stopTest();
    }
*/
    /*
    public static testmethod void testUpdateChangeHistoryWithIncorrectData(){
        List<sObject> testSObjectList = new List<sObject>();

        Id incorrectProposalId = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        Id incorrectProposalDraftId = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        Id incorrectChangeOrderId = Id.valueOf(Change_Order__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        testSObjectList.add(new Proposal__c (Id = incorrectProposalId));
        testSObjectList.add(new Proposal__c (Id = incorrectProposalDraftId));
        testSObjectList.add(new Change_Order__c (Id = incorrectChangeOrderId, Proposal__c = incorrectProposalId));
        testSObjectList.add(new Change_Order__c (Id = incorrectChangeOrderId, Proposal__c = null));

        System.assert(! testSObjectList.isEmpty());

        Test.startTest();

            ProposalServices.updateChangeHistory(testSObjectList);

        Test.stopTest();
    }
    */

    public static testmethod void testCreateTaskForProposalCreator(){
        setupData();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = 'test status';
            proposalItem.Send_Reminder_To_Creator__c = DateTime.now();
        }
        insert testProposalList;

        testProposalList = [SELECT Id, Status__c, OwnerId, Send_Reminder_To_Creator__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        Map<Id, Proposal__c> proposalMapOld = new Map<Id, Proposal__c>(testProposalList.deepClone(true));

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            ProposalServices.createTaskForProposalCreator(testProposalList, proposalMapOld);

        Test.stopTest();
    }

    /*public static testmethod void testPreventDeleteProposalIfStatusAwarded(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
        }
        update testProposalList;

        Test.startTest();
            try{
                delete testProposalList;
                System.assert (false);
            } catch (DMLException dmlEx){
                System.assert (dmlEx.getMessage().contains('Can not delete Proposal if status is Awarded'));
            }
        Test.stopTest();
        System.assertEquals (NUMBER_TO_CREATE_PROJECT_PROFILE, [SELECT Id FROM Proposal__c WHERE Id IN : testProposalList AND Status__c = : ProposalServices.PROPOSAL_STATUS_AWARDED].size());
    }*/


    /*public static testmethod void testCreateNewProjectProfile(){
        setupData();
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
        }

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        System.assertEquals (NUMBER_TO_CREATE_PROPOSAL, [SELECT Id FROM Project_Profile__c].size());

        for (Proposal__c proposalItem : [SELECT Project_Profile__r.Partner__c, Project_Profile__r.Account_Executive__c, Project_Profile__r.Expected_Occupancy_Date__c,
                                                Project_Profile__r.Expected_Construction_End_Date__c, Project_Profile__r.Expected_Construction_Start_Date__c,
                                                Project_Profile__r.Expected_Construction_Cost__c, Project_Profile__r.Construction_Budget__c, Project_Profile__r.Billing_Company_Name__c,
                                                Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c,
                                                Project_Profile__r.Primary_Company_Name__c, Project_Profile__r.Name, Project_Profile__c,
                                                Project_Name__c, Primary_Company_Name__c, Primary_Company_Contact__c, Billing_Company_Name__c, Billing_Company_Contact__c,
                                                Account_Executive__c, Partner__c, Address__c, Construction_Budget__c, Expected_Construction_End_Date__c,
                                                Expected_Construction_Start_Date__c, Expected_Occupancy_Date__c, Expected_Construction_Cost__c
                                         FROM Proposal__c
                                         WHERE Id IN : testProposalList]){
            System.assert (proposalItem.Project_Profile__c != null);
            System.assertEquals (proposalItem.Project_Name__c, proposalItem.Project_Profile__r.Name);
            System.assertEquals (proposalItem.Primary_Company_Name__c, proposalItem.Project_Profile__r.Primary_Company_Name__c);
            System.assertEquals (proposalItem.Primary_Company_Contact__c, proposalItem.Project_Profile__r.Primary_Company_Contact__c);
            System.assertEquals (proposalItem.Billing_Company_Name__c, proposalItem.Project_Profile__r.Billing_Company_Name__c);
            System.assertEquals (proposalItem.Billing_Company_Contact__c, proposalItem.Project_Profile__r.Billing_Company_Contact__c);
            System.assertEquals (proposalItem.Account_Executive__c, proposalItem.Project_Profile__r.Account_Executive__c);
            System.assertEquals (proposalItem.Partner__c, proposalItem.Project_Profile__r.Partner__c);
            System.assertEquals (proposalItem.Address__c, proposalItem.Project_Profile__r.Building__c);
            System.assertEquals (proposalItem.Construction_Budget__c, proposalItem.Project_Profile__r.Construction_Budget__c);
            System.assertEquals (proposalItem.Expected_Construction_End_Date__c, proposalItem.Project_Profile__r.Expected_Construction_End_Date__c);
            System.assertEquals (proposalItem.Expected_Construction_Start_Date__c, proposalItem.Project_Profile__r.Expected_Construction_Start_Date__c);
            System.assertEquals (proposalItem.Expected_Occupancy_Date__c, proposalItem.Project_Profile__r.Expected_Occupancy_Date__c);
            System.assertEquals (proposalItem.Expected_Construction_Cost__c, proposalItem.Project_Profile__r.Expected_Construction_Cost__c);
        }
    }*/


    /*public static testmethod void testCreateNewProjectProfileWithServiceAndTaskItems(){
        setupData();
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE_PROJECT_PROFILE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        testServiceItemList = new List<Service_Item__c>();

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            testServiceItemList.addAll(TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false));

        }
        insert testServiceItemList;

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        testTaskItemList = [SELECT Id, Project_Profile__c, Service_Item__r.Proposal__r.Project_Profile__c
                            FROM Task_Item__c
                            WHERE Service_Item__c IN : testServiceItemList];

        System.assert (!testTaskItemList.isEmpty());
        System.assertEquals (testServiceItemList.size(), testTaskItemList.size());

        for (Task_Item__c taskItem : testTaskItemList){//Id IN : testTaskItemList]){
            System.assert (taskItem.Project_Profile__c != null);
            System.assert (taskItem.Service_Item__r.Proposal__r.Project_Profile__c != null);
            System.assertEquals (taskItem.Project_Profile__c, taskItem.Service_Item__r.Proposal__r.Project_Profile__c);
        }
    }*/

    /*public static testmethod void testCreateNewProjectProfileWithTaskTemplate(){
        setupData();
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE_PROJECT_PROFILE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        }
        insert testProposalList;

        testTaskTemplateList = TestingUtils.createTaskTemplateList(1, TASK_TEMPLATE_NAME_LIST, true);

        testServiceItemList = new List<Service_Item__c>();

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            for (Service_Item__c seviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false)){
                testServiceItemList.add(seviceItem);
            }
        }
        insert testServiceItemList;

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        testTaskItemList = [SELECT Id, Project_Profile__c, Service_Item__r.Proposal__r.Project_Profile__c
                            FROM Task_Item__c
                            WHERE Service_Item__c IN : testServiceItemList];

        System.assert (!testTaskItemList.isEmpty());

        for (Task_Item__c taskItem : testTaskItemList){//Id IN : testTaskItemList]){
            System.assert (taskItem.Project_Profile__c != null);
            System.assert (taskItem.Service_Item__r.Proposal__r.Project_Profile__c != null);
            System.assertEquals (taskItem.Project_Profile__c, taskItem.Service_Item__r.Proposal__r.Project_Profile__c);
        }
    }*/


    /*private static testmethod void testCreateProposalHistorical(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED;
        }

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        List<Proposal_Historical__c> proposalHistoricalList = [ SELECT Id, Name, Proposal__c, Project_Name__c, Version__c,
                                                                       Proposal__r.Name, Proposal__r.Project_Name__c, Proposal__r.Version__c
                                                                FROM Proposal_Historical__c
                                                                WHERE Proposal__c IN : testProposalList];

        System.assertEquals (testProposalList.size(), proposalHistoricalList.size());
        for (Proposal_Historical__c proposalHistoricalItem : proposalHistoricalList){
            System.assertEquals (proposalHistoricalItem.Proposal__r.Name, proposalHistoricalItem.Name);
            System.assertEquals (proposalHistoricalItem.Proposal__r.Project_Name__c, proposalHistoricalItem.Project_Name__c);
            System.assertEquals (proposalHistoricalItem.Proposal__r.Version__c, proposalHistoricalItem.Version__c);
        }
    }*/


    private static testmethod void testCreateServiceHistorical(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        testServiceItemList = new List<Service_Item__c>();

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_REJECTED;
            testServiceItemList.addAll(TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false));
        }
        insert testServiceItemList;

        System.assert(! testProposalList.isEmpty());

        Test.startTest();
            update testProposalList;
        Test.stopTest();

        /*List<Service_Historical__c> testServiceHistoricalList = [SELECT Id, Service_Item__c, Name, Proposal_Historical__c,Service_Item__r.Name
                                                                 FROM Service_Historical__c
                                                                 WHERE Service_Item__c IN : testServiceItemList];
        System.assertEquals (testServiceItemList.size(), testServiceHistoricalList.size());
        for (Service_Historical__c serviceHistoricalItem : testServiceHistoricalList){
            System.assertEquals (serviceHistoricalItem.Service_Item__r.Name, serviceHistoricalItem.Name);
        }*/
    }


    /*private static testmethod void testAddRejectionReasonAfterReject(){
        setupData();
        prepareData(NUMBER_TO_CREATE_PROPOSAL, true);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
            proposalItem.Rejection_Reason__c = '';
        }
        update testProposalList;
        List<Approval.ProcessSubmitRequest> testAppList = new List<Approval.ProcessSubmitRequest>();
        for (Proposal__c proposalItem : testProposalList){
            Approval.ProcessSubmitRequest testApp = new Approval.ProcessSubmitRequest();
            testApp.setNextApproverIds(new List<Id>{UserInfo.getUserId()});
            testApp.setComments('some comment text');
            testApp.setObjectId(proposalItem.Id);
            testAppList.add (testApp);
        }
        //List<Approval.ProcessResult> result = Approval.process(testAppList);
        Map<Id, Id> newWorkItemIds = new Map<Id, Id>();

        List<ProcessInstanceWorkitem> processInstanceWorkitem = [ SELECT Id, ProcessInstance.TargetObjectId, OriginalActorId, ActorId
                                                                  FROM ProcessInstanceWorkitem
                                                                  WHERE ProcessInstance.TargetObjectId IN : testProposalList ];

        for (ProcessInstanceWorkitem proposInstanceWorkIt : processInstanceWorkitem){
            newWorkItemIds.put (proposInstanceWorkIt.ProcessInstance.TargetObjectId, proposInstanceWorkIt.Id);
        }
        List<Approval.ProcessWorkitemRequest> approvements = new List<Approval.ProcessWorkitemRequest>();
        for (Id procesWorkItemRequest : newWorkItemIds.values()){
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req2.setWorkitemId(procesWorkItemRequest);
            approvements.add (req2);
        }

        List<Approval.ProcessResult> result2 =  Approval.process(approvements);

        List<ProcessInstance> processInstances = [select Id, Status from ProcessInstance where TargetObjectId IN :testProposalList];

        for( ProcessInstance itemPrIns: [SELECT TargetObject.Name, TargetObject.Id, TargetObjectId, Status, Id,
                                                (Select StepStatus, Comments, CreatedDate From Steps)
                                         FROM ProcessInstance
                                         WHERE TargetObjectId IN: testProposalList]){
            if (itemPrIns.Steps.isEmpty()){
                System.assert (false);
            }
        }

        processInstances = [SELECT Id, Status
                            FROM ProcessInstance
                            WHERE TargetObjectId IN :testProposalList];
        System.assertNotEquals(0, processInstances.size());

        List<ProcessInstanceWorkitem> processInstanceWorkitem1 = [ SELECT Id, ProcessInstance.TargetObjectId
                                                                   FROM ProcessInstanceWorkitem
                                                                   WHERE ProcessInstance.TargetObjectId IN :testProposalList ];
        testProposalList = [SELECT Id, Rejection_Reason__c, Status__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];
        for (Proposal__c proposalItem : testProposalList){
            System.Debug('^^^409Proposal Rejection_Reason__c= ' + proposalItem.Rejection_Reason__c);
            System.Debug('^^^410Proposal Status__c= ' + proposalItem.Status__c);
        }

        System.assert (![Select TargetObject.Name, TargetObject.Id, TargetObjectId, Status, Id From ProcessInstance Where TargetObjectId IN: testProposalList].isEmpty());
    }*/

//commented by pvl

/*
    private static testmethod void testStoredDocsOrFolder(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testLStoreStoredDocumentList = new List<LStore__Stored_Document__c>();
        for (Proposal__c proposalDraftItem : testProposalDraftList){
            for (LStore__Stored_Document__c lStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (1, false)){
                lStoreStoredDocumentItem.LStore__Related_Object_Id__c = proposalDraftItem.Id;
                lStoreStoredDocumentItem.RecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
                lStoreStoredDocumentItem.LStore__File_Name__c = proposalDraftItem.Id;
                testLStoreStoredDocumentList.add(lStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocumentList;

        List<LStore__Stored_Document__c> resultList;

        Test.startTest();
            resultList = ProposalServices.storedDocsOrFolder (Id.valueOf(testLStoreStoredDocumentList[0].LStore__Related_Object_Id__c),
                                                              testLStoreStoredDocumentList[0].RecordTypeId,
                                                              testLStoreStoredDocumentList[0].LStore__File_Name__c);
        Test.stopTest();

        System.assert(resultList.isEmpty());
    }
*/
    private static testmethod void testCleanUpCZAnalystData(){
        setupData();
        createProposalsForTest(2, null, false);
        
        List<Change_Order__c> changeOrders1 = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_PROPOSAL, true);
        List<Change_Order__c> changeOrders2 = TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_PROPOSAL, true);
        for( Change_Order__c changeOrder: changeOrders1 ){
            changeOrder.Proposal__c = testProposalList[0].Id;
        }
        for( Change_Order__c changeOrder: changeOrders2 ){
            changeOrder.Proposal__c = testProposalList[1].Id;
        }
        List<Change_Order__c> totalChangeOrders = new List<Change_Order__c>();
        totalChangeOrders.addAll(changeOrders1);
        totalChangeOrders.addAll(changeOrders2);
        for( Change_Order__c changeOrder: totalChangeOrders ){
            changeOrder.Status__c = ChangeOrderServices.STATUS_IN_CZ_REVIEW;
        }
        Test.startTest();
            upsert totalChangeOrders;
        Test.stopTest();
        List<Proposal__c> updatedProposals = new List<Proposal__c>( [ SELECT Id, Code_Zoning_Analyst__c, Code_Zoning_Analyst_Email__c FROM Proposal__c WHERE Id IN : testProposalList ] );

        System.assert(updatedProposals.isEmpty());
        
        for( Proposal__c proposal : updatedProposals ) {
            System.assert( String.IsBlank(proposal.Code_Zoning_Analyst__c) );
            System.assert( String.IsBlank(proposal.Code_Zoning_Analyst_Email__c) );
        }
    }
}