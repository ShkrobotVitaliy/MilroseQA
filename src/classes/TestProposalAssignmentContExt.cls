@isTest
private class TestProposalAssignmentContExt {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;

    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPage;
    private static ApexPages.StandardController testStandardController;
    private static ProposalAssignmentContExt testController;

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

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
    }

    private static void preparePageController (Proposal__c proposalItem){
        testPage = Page.ProposalAssignment;
        Test.setCurrentPage(testPage);
        testStandardController = new ApexPages.StandardController(proposalItem);
        testController = new ProposalAssignmentContExt(testStandardController);
    }

    private static testmethod void testInitController (){
        setupData ();

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            preparePageController(testProposalList[0]);

        Test.stopTest();

        System.assert(testController != null);
    }
}