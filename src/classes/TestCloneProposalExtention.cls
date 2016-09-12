@isTest
private class TestCloneProposalExtention {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PHASE = 2;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FLOOR = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 2;


    private static List<Project_Team__c> testProjectTeamList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    public static User testProductionManagerUser;

    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Floor__c> testFloorList;
    private static List<Service_Floor_Junction__c> testServiceFloorJunctionList;
    private static List<Phase__c> testPhaseList;
    private static Id projectRosterUserRecordTypeId;
    private static List<String> projectRosterRoleValuesList;

    private static PageReference testPage;
    private static CloneProposalExtention testController;
    private static ApexPages.StandardController testStandardController;

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
    }

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProductionManagerUser = TestingUtils.testProductionManagerUser;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void prepareDataForTest(){
        testPhaseList = new List<Phase__c>();
        for (Proposal__c proposalItem : testProposalList){
            for(Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }
        }
        insert testPhaseList;

        Map<Id, List<Floor__c>> proposalWithFloorMap = new Map<Id, List<Floor__c>>();
        Map<Id, List<Service_Item__c>> proposalWithServiceItemMap = new Map<Id, List<Service_Item__c>>();
        //create Floor for test
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            proposalWithFloorMap.put(proposalItem.Id, new List<Floor__c>());
            for (Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
                proposalWithFloorMap.get(proposalItem.Id).add(floorItem);
            }
        }
        insert testFloorList;
        //create Service Item for test
        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            proposalWithServiceItemMap.put(proposalItem.Id, new List<Service_Item__c>());
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Proposal__c = proposalItem.Id;
                serviceItem.Original__c = true;
                testServiceItemList.add(serviceItem);
                proposalWithServiceItemMap.get(proposalItem.Id).add(serviceItem);
            }
        }
        insert testServiceItemList;
        //create Service Floor Junction for test
        testServiceFloorJunctionList = new List<Service_Floor_Junction__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Item__c serviceItemItem : proposalWithServiceItemMap.get(proposalItem.Id)){
                for (Floor__c floorItem : proposalWithFloorMap.get(proposalItem.Id)){
                    for (Service_Floor_Junction__c serviceFloorJunctionItem : TestingUtils.createServiceFloorJunctionList(1, serviceItemItem.Id, floorItem.Id, false)){
                        testServiceFloorJunctionList.add(serviceFloorJunctionItem);
                    }
                }
            }
        }
        insert testServiceFloorJunctionList;
        //create Project Roster for test
        testProjectRosterList = new List<Project_Roster__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                projectRosterItem.Proposal__c = proposalItem.Id;
                projectRosterItem.User__c = currentUserId;
                projectRosterItem.User_Contact__c = 'User';
                projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                testProjectRosterList.add(projectRosterItem);
            }
        }
        insert testProjectRosterList;
    }

    private static void preparePageController (Proposal__c proposalItem){
        testPage = Page.CloneProposal;
        Test.setCurrentPage(testPage);
        if (proposalItem != null) {
            testStandardController = new ApexPages.standardController(proposalItem);
            testController = new CloneProposalExtention(testStandardController);
        }
    }

    private static testmethod void testInitController(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        Test.startTest();

            preparePageController(testProposalList[0]);

        Test.stopTest();

        System.assert(testController != null);
        System.assert(testController.proposal != null);
        System.assertEquals(testProposalList[0].Id, testController.proposal.Id);
    }
    //whith Phase, Floor, Service Item, Service Floor Junction, Project Roster lists
    private static testmethod void testCreateCloneOfProposal(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
        prepareDataForTest();
        preparePageController(testProposalList[0]);

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.createCloneOfProposal();

        Test.stopTest();

        //System.assert(resultPageReference != null);
    }
    //whithout Phase, Floor, Service Item, Service Floor Junction, Project Roster lists
    private static testmethod void testCreateCloneOfProposalWithEmptyData(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
        preparePageController(testProposalList[0]);

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.createCloneOfProposal();

        Test.stopTest();

        //System.assert(resultPageReference != null);
    }

    private static testmethod void testBackAction(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
        preparePageController(testProposalList[0]);

        PageReference resultPageReference;

        Test.startTest();

            resultPageReference = testController.backAction();

        Test.stopTest();

        System.assert(testController != null);
        System.assert(testController.proposal != null);
        System.assertEquals(testProposalList[0].Id, testController.proposal.Id);
    }
}