@isTest
private class TestProjectTeamServices {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 5;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;

    private static List<Task_Item__c> testTaskItemList;

    private static Id taskItemMilestoneRecordTypeId;
    private static Id taskItemNotMilestoneRecordTypeId;

    private static void getRecordTypes(){
        //get Task Item Record Type
        Map<String, Id> taskItemRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c');
        taskItemNotMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
        for (String taskItemRecordTypeNameValue : taskItemRecordTypesMap.keySet()){
        if (taskItemRecordTypeNameValue != TaskManagementServices.MILESTONE_RECORDTYPE_NAME){
            taskItemNotMilestoneRecordTypeId = taskItemRecordTypesMap.get(taskItemRecordTypeNameValue);
            break;
        }
        }
        taskItemMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
    }

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        testProductionManagerUser = TestingUtils.testProductionManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    @isTest static void testUncoveredParts() {

        List<User> users = new List<User> { TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2),
                                            TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2),
                                            TestingUtils.userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER),
                                            TestingUtils.userWithProfile(UserServices.PROFILE_FREP)};

        List<Project_Team__c> projectTeams = new List<Project_Team__c> { new Project_Team__c( FREP__c = users[3].Id, Project_Member__c = users[0].Id, Production_Manager__c = users[2].Id, Project_Manager__c = users[0].Id, OwnerId = users[0].Id ),
                                                                         new Project_Team__c( FREP__c = users[3].Id, Project_Member__c = users[0].Id, Production_Manager__c = users[2].Id, Project_Manager__c = users[1].Id, OwnerId = users[1].Id ),
                                                                         new Project_Team__c( FREP__c = users[3].Id, Project_Member__c = users[0].Id, Production_Manager__c = users[2].Id, Project_Manager__c = users[1].Id, OwnerId = users[1].Id ) };
        INSERT projectTeams;

        Test.startTest();
            System.runAs( users[0] ) {
                Map<Id, Project_Team__c> getAllProjectTeams = ProjectTeamServices.getAllProjectTeams();
                List<SelectOption> getProjectTeamOptions1 = ProjectTeamServices.getProjectTeamOptions( users[0].Id );
                List<SelectOption> getProjectTeamOptions2 = ProjectTeamServices.getProjectTeamOptions( users[1].Id );

                List<SelectOption> getFrepsOptions = ProjectTeamServices.getFrepsOptions( projectTeams[0].Id, users[3].Id);
                List<SelectOption> getProdManagersOptions = ProjectTeamServices.getProdManagersOptions( users[2].Id );
                Id getDefaultFrepForProjectTeam = ProjectTeamServices.getDefaultFrepForProjectTeam( projectTeams[0].Id );
                Id getDefaultProdManagerForProjectTeam = ProjectTeamServices.getDefaultProdManagerForProjectTeam( projectTeams[0].Id );
                Map<Id, Project_Team__c> filteredProjectTeamsByChangedUsers = ProjectTeamServices.filteredProjectTeamsByChangedUsers( projectTeams,
                                                                                new Map<Id, Project_Team__c> { projectTeams[0].Id => projectTeams[0],
                                                                                                               projectTeams[1].Id => projectTeams[1],
                                                                                                               projectTeams[2].Id => projectTeams[2] } );
                Project_Team__c getProjectTeam = ProjectTeamServices.getProjectTeam( projectTeams[0].Id, new List<String> {'Id'} );

                Proposal__c proposal = TestingUtils.createProposalListForTest(1,false)[0];
                proposal.sowScopeOfWork__c = ProposalWizardServices.SOW_NEW_BUILDING;
                proposal.Primary_Company_Contact__c = TestingUtils.createContactList(1, true)[0].Id;
                INSERT proposal;
                List<AssignmentWrapper> getAssignmentsForProjectTeam = ProjectTeamServices.getAssignmentsForProjectTeam( proposal );
                List<AssignmentWrapper> getAssignmentsForResource = ProjectTeamServices.getAssignmentsForResource ( proposal );
                List<AssignmentWrapper> getAssignmentsForFrep = ProjectTeamServices.getAssignmentsForFrep();
                ProjectTeamServices.updateProjectServiceTaskInFuture( new Set<Id> { projectTeams[0].Id, projectTeams[1].Id, projectTeams[2].Id } );
                ProjectTeamServices.updateProjectServiceTaskInFuture( projectTeams );
                ProjectTeamServices.updateProjectServiceTaskInFutureLoop( new Set<Id> { TestingUtils.createProjectProfileForTest(1,true)[0].Id } );
            }
        Test.stopTest();
    }

    private static testmethod void testGetProposalIdToProjectTeam(){
        setupData ();

        Set<Id> checkResultProjectTeamSetId = new Set<Id>();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = testProjectTeamList[0].Id;
            checkResultProjectTeamSetId.add(proposalItem.Project_Team__c);
        }
        insert testProposalList;

        Map<Id, Project_Team__c> resultProjectTeamMap;

        Test.startTest();

            resultProjectTeamMap = ProjectTeamServices.getProposalIdToProjectTeam(testProposalList);

        Test.stopTest();

        System.assert(resultProjectTeamMap != null);
        System.assertEquals(checkResultProjectTeamSetId, resultProjectTeamMap.keySet());
    }

    private static testmethod void testGetProjectIdToProjectTeam(){
        setupData ();

        Set<Id> checkResultProjectTeamSetId = new Set<Id>();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            checkResultProjectTeamSetId.add(projectProfileItem.Project_Team__c);
        }

        Map<Id, Project_Team__c> resultProjectTeamMap;

        Test.startTest();

            resultProjectTeamMap = ProjectTeamServices.getProjectIdToProjectTeam(testProjectProfileList);

        Test.stopTest();

        System.assert(resultProjectTeamMap != null);
        System.assertEquals(checkResultProjectTeamSetId, resultProjectTeamMap.keySet());
    }

    private static testmethod void testGetAllProjectTeams(){
        setupData ();

        List<Project_Team__c> resultProjectTeamList;

        Test.startTest();

            resultProjectTeamList = ProjectTeamServices.getAllProjectTeams(UserInfo.getUserId());

        Test.stopTest();

        System.assert(resultProjectTeamList != null);
        System.assertEquals(new Map<Id, Project_Team__c>([SELECT Id FROM Project_Team__c]).keySet(), new Map<Id, Project_Team__c>(resultProjectTeamList).keySet());
    }

    private static testmethod void testGetProjectTeamOptions(){
        setupData ();

        List<SelectOption> resultSelectOptionList;

        Test.startTest();

            resultSelectOptionList = ProjectTeamServices.getProjectTeamOptions(UserInfo.getUserId());

        Test.stopTest();

        System.assert(resultSelectOptionList != null);
    }
}