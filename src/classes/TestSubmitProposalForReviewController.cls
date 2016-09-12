@isTest
private class TestSubmitProposalForReviewController {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
    private static final Integer NUMBER_TO_CREATE = 5;

    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static User testUser;
    private static List<Project_Team__c> testProjectTeamList;
    private static PageReference testPage;
    private static SubmitProposalForReviewController testController;

    private static void setupData (Boolean doInsert){
        testUser = TestingUtils.createUsers(1,
                                                 'PrSorRevTestUserName@gmail.com',
                                                 'PrSorRevTestUserSurname',
                                                 'PrSorRevTestUserEmail@gmail.com',
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 null,
                                                 true)[0];
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true);
        testContactWithAccountList = TestingUtils.createContactList(1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'Test region', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE, projectManagerUser.Id, projectManagerUser.Id, false);
        for(Project_Team__c item : testProjectTeamList){
            item.Project_Member__c = projectManagerUser.Id;
        }
            insert testProjectTeamList;           
        
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[0].Id, testContactWithAccountList[0].Id, testAccountList[0].Id,
                                                                        testContactWithAccountList[0].Id, projectManagerUser.Id, doInsert);

        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[0].Id, testContactWithAccountList[0].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, testUser.Id, projectManagerUser.Id, false);
        for(Proposal__c item : testProposalList){
            item.Project_Team__c = testProjectTeamList[0].Id;  
            item.Resource__c =   projectManagerUser.Id;
            item.Status__c =  ProposalServices.PROPOSAL_STATUS_NEW;
            item.Billing_Method__c = 'Milestone';
        } 
        if(doInsert){
            insert testProposalList;  
        }
                                                                       
    }

    private static void prepareData(Boolean toClientParam){
        testPage = Page.SubmitProposalForReview;
        Test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('Id', testProposalList[0].Id);
        if (toClientParam){
            ApexPages.currentPage().getParameters().put('toClient', '1');
        }
        testController = new SubmitProposalForReviewController();
    }

    private static testmethod void testIncorrectProposalId (){
        testPage = Page.SubmitProposalForReview;
        Test.setCurrentPage(testPage);

        Test.startTest();
            testController = new SubmitProposalForReviewController();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals (SubmitProposalForReviewController.INVALID_PROPOSAL, msgList[0].getDetail());
    }

    private static testmethod void testSubmitRequestForPartnerReviewWithRevieIsNotNeed (){
        setupData (false);
        testProposalList[0].Partner_Approval_Required__c = false;
        insert testProposalList;
        prepareData(false);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals (SubmitProposalForReviewController.PARTNER_REVIEW_IS_NOT_NEEDED_ERROR, msgList[0].getDetail());
    }

    private static testmethod void testSubmitRequestForPartnerReviewWithRevieIsNeedStatusIncorrect (){
        setupData (false);
        testProposalList[0].Partner_Approval_Required__c = true;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        testProposalList[0].Internal_Reviewer__c = partnerUser.Id;
        insert testProposalList;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
        update testProposalList;
        prepareData(false);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        //System.assertEquals (SubmitProposalForReviewController.WRONG_STATUS_ERROR, msgList[0].getDetail());
    }

    private static testmethod void testSubmitRequestForPartnerReviewWithRevieIsNeedStatusCorrect (){
        setupData (false);
        testProposalList[0].Partner_Approval_Required__c = true;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        testProposalList[0].Internal_Reviewer__c = partnerUser.Id;
        insert testProposalList;
        prepareData(false);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        //System.assert (msgList.isEmpty());
        List<ProcessInstance> processInstanceList = [ SELECT TargetObject.Name, TargetObject.Id, TargetObjectId, Status, Id,
                                                             (Select StepStatus, Comments, CreatedDate From Steps Order By CreatedDate DESC Limit 1)
                                                      FROM ProcessInstance
                                                      WHERE TargetObjectId = : testProposalList[0].Id ];
        for( ProcessInstance itemPrIns: processInstanceList){
            System.assertEquals (SubmitProposalForReviewController.SUBMITTED_FOR_APPROVAL, itemPrIns.Steps[0].Comments);
        }
    }

    private static testmethod void testSubmitRequestNeedApproveFromPartnerError (){
        setupData (false);
        testProposalList[0].Partner_Approval_Required__c = true;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        testProposalList[0].Internal_Reviewer__c = partnerUser.Id;
        insert testProposalList;
        prepareData(true);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals (Label.Need_Approved_By_Partner, msgList[0].getDetail());
    }

    private static testmethod void testSubmitRequestWithPendingClient (){
        setupData (false);
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        insert testProposalList;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW;
        update testProposalList;
        prepareData(true);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        testProposalList = [SELECT Id, Status__c, Proposal_Sent_Date__c
                            FROM Proposal__c
                            WHERE Id = : testProposalList[0].Id];
        System.assert (!testProposalList.isEmpty() && testProposalList.size() == 1);
        System.assertEquals (ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, testProposalList[0].Status__c);
        System.assertEquals (Date.today(), testProposalList[0].Proposal_Sent_Date__c);
    }

    private static testmethod void testSubmitRequestWrongStatusError (){
        setupData (false);
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        insert testProposalList;
        testProposalList[0].Status__c = ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
        update testProposalList;
        prepareData(true);

        Test.startTest();
            testController.submitRequest();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals (SubmitProposalForReviewController.WRONG_STATUS_ERROR, msgList[0].getDetail());
    }
}