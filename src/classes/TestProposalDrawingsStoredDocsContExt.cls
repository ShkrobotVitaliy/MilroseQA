@isTest
private class TestProposalDrawingsStoredDocsContExt {

    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 6;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 7;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;
    private static final Integer NUMBER_TO_CREATE_EVENT = 2;
    private static final List<String> TASK_TEMPLATE_NAME_LIST = new List<String>{'first', 'second', 'third', 'fourth'};

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Event> testEventList;
    private static List<Task> testTaskList;
    private static List<Proposal_Historical__c> testProposalHistoricalList;
    private static List<Service_Historical__c> testServiceHistoricalList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        partnerUser = TestingUtils.userWithProfile('Partner');
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
    }

    private static void createProposalsForTest(Integer numberToCreate, Id projectProfileId, Boolean doInsert){
        testProposalList = TestingUtils.createProposalList (numberToCreate, projectProfileId, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);

        if(doInsert){
            insert testProposalList;
        }
    }

    private static ApexPages.StandardController testController;
    private static ProposalDrawingsStoredDocsContExt testProposalDrawingsStoredDocsContExt;

    private static testMethod void testProposalDrawingsStoredDocsContExt() {
        setupData ();
        createProposalsForTest(1, null, true);
        Test.setCurrentPageReference(Page.ProposalDrawingsStoredDocs);
        testController = new ApexPages.StandardController( testProposalList[0] );

        Test.startTest();
            testProposalDrawingsStoredDocsContExt = new ProposalDrawingsStoredDocsContExt(testController);
        Test.stopTest();

        System.assert(testProposalDrawingsStoredDocsContExt != null);

    }
}