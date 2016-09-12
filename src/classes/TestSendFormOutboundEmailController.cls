@isTest
private class TestSendFormOutboundEmailController {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_SIGNATURE = 3;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 3;
    private static final String TEST_FORM_TEMPLATE_START_NAME = 'F';

    private static final List<String> FORM_TYPE_VALUES_LIST = new List<String> {FormTemplatesServices.FORM_TYPE_EMAIL,
                                                                                FormTemplatesServices.FORM_TYPE_FORM,
                                                                                FormTemplatesServices.FORM_TYPE_LETTER};

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Form_Template__c> testFormTemplateList;
    private static List<Form_Item__c> testFormItemList;
    private static List<Form_Signature__c> testFormSignatureList;
    private static List<LStore__Stored_Document__c> testLStoreStoredDocumentList;
    private static List<Loop__DDP__c> testLoopDDPList;
    private static List<Loop__DDP_Integration_Option__c> testLoopDDPIntegrationList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Id projectRosterUserRecordTypeId;

    private static PageReference testPage;
    

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
    }

    private static void setupData (){
        testProposalList = TestingUtils.createProposalListForTest( 1, true );
        prepareRecordTypePickListValuesForTest();
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'TaskItem5', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
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

    //create Project Roster, Service Item with Form Items and Task Items
    private static void prepareDataForTest(){
        testMunucipalitiesList = [SELECT Id, Name, Region__c, Region__r.Name
                                  FROM Munucipalities__c
                                  WHERE Id IN : testMunucipalitiesList];

        testFormTemplateList = new List<Form_Template__c>();
        String formTempleteId = '';
        Integer i = 1;
        for (String formTypeItem : FORM_TYPE_VALUES_LIST){
            for (Form_Template__c formTemplateItem : TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, TEST_FORM_TEMPLATE_START_NAME + String.valueOf(i), false)){
                formTemplateItem.Name = formTemplateItem.Form_ID__c;
                formTemplateItem.Form_Name__c = formTemplateItem.Form_ID__c;
                formTempleteId += formTemplateItem.Form_ID__c + ';';
                formTemplateItem.Form_Type__c = formTypeItem;
                formTemplateItem.Region__c = testMunucipalitiesList[0].Region__r.Name;
                formTemplateItem.Region_Lookup__c = testMunucipalitiesList[0].Region__c;
                formTemplateItem.Municipality__c = testMunucipalitiesList[0].Name;
                testFormTemplateList.add(formTemplateItem);
            }
            i++;
        }
        insert testFormTemplateList;

        formTempleteId.removeEnd(';');

        List<sObject> sObjectInsertList = new List<sObject>();
        testProjectRosterList = new List<Project_Roster__c>();
        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.User__c = projectProfileItem.OwnerId;
                projectRosterItem.User_Contact__c = 'User';
                projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                testProjectRosterList.add(projectRosterItem);
                sObjectInsertList.add(projectRosterItem);
            }
        }
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Proposal__c = testProposalList[0].Id;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Form_Id__c = formTempleteId;
                serviceItemItem.Forms__c = formTempleteId;
                testServiceItemList.add(serviceItemItem);
                
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList (NUMBER_TO_CREATE_TASK_ITEM,
                                                                              serviceItemItem.Id,
                                                                              serviceItemItem.Project_Profile__c,
                                                                              false)){
                testTaskItemList.add(taskItemItem);
                
            }
        }
        insert testTaskItemList;
        
        testFormItemList = new List<Form_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Form_Template__c formTemplateItem : testFormTemplateList){
                i = 0;
                for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)) {
                    formItemItem.Service_Item__c = serviceItemItem.Id;
                    formItemItem.Complete_Forms__c = testTaskItemList[0].Id;
                    formItemItem.Project__c = serviceItemItem.Project_Profile__c;
                    formItemItem.Form_Template__c = formTemplateItem.Id;
                    formItemItem.Short_Form_Name__c = i == 0 ? formTemplateItem.Form_ID__c : formTemplateItem.Form_ID__c + '_00' + String.valueOf(i);
                    formItemItem.Form_ID__c = formTemplateItem.Form_ID__c;
                    testFormItemList.add(formItemItem);
                    
                    i++;
                }
            }
        }
        insert testFormItemList;
        
        
    }
    
    private static ApexPages.StandardController testController;
    private static SendFormOutboundEmailController testSendFormOutboundEmailController;

    private static testMethod void testSendFormOutboundEmailController() {
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        
        Test.setCurrentPageReference(Page.SendFormOutboundEmail);
        List<Form_Item__c> testFormItemListSelected = [Select Id, Name From Form_Item__c Where Id IN: testFormItemList];

        Test.startTest();
            testSendFormOutboundEmailController = new SendFormOutboundEmailController();
            testSendFormOutboundEmailController.formIds = testFormItemListSelected[0].Id;
            Set<Id> test15 = SendFormOutboundEmailController.getSetOfIdsForFuture(testFormItemListSelected[0].Id);
            Boolean test1 = testSendFormOutboundEmailController.reviewEmail;
            String test2 = testSendFormOutboundEmailController.emailTemplateName;
            testSendFormOutboundEmailController.proposalId = testFormItemListSelected[0].Id;
            EmailTemplate test8 = testSendFormOutboundEmailController.emailTemplate;
            EmailTemplate test9 = testSendFormOutboundEmailController.emailTemplateDraft;
            List<Id> test12 = testSendFormOutboundEmailController.attachmentIds;
            String test3 = testSendFormOutboundEmailController.draftTemplateName;
            String test4 = testSendFormOutboundEmailController.formForSignatures;
            String test5 = testSendFormOutboundEmailController.drawloopName;
            String test6 = testSendFormOutboundEmailController.loggedUserName;
            testSendFormOutboundEmailController.clearEmailAddress();
            Map<String, List<Form_Item__c>> test7 = testSendFormOutboundEmailController.getEmailToFormItems();
            testSendFormOutboundEmailController.project = testProjectProfileList[0];
            testSendFormOutboundEmailController.onCompleteReview() ;
            testSendFormOutboundEmailController.sendEmail();
            testSendFormOutboundEmailController.showReviewEmail();
            testSendFormOutboundEmailController.backToTaskItem();
            testSendFormOutboundEmailController.updateCCEmailsAddressForDrawLoop();
            testSendFormOutboundEmailController.updateAfterSend();
            testSendFormOutboundEmailController.sendTo = 'test';
            String sendTo = testSendFormOutboundEmailController.sendTo;
            String getFormIds = testSendFormOutboundEmailController.getFormIds();
            testSendFormOutboundEmailController.project = null;
            try { Project_Profile__c projectTest = testSendFormOutboundEmailController.project; } catch ( Exception ex ) {}
            String contactEmail = testSendFormOutboundEmailController.contactEmail;
            testSendFormOutboundEmailController.contactRecipient = TestingUtils.createContactList( 1, true)[0];
            testSendFormOutboundEmailController.onCompleteReview();
            Project_Roster__c projectRoster = TestingUtils.createProjectRosterList(1, false)[0];
                projectRoster.Contact__c = TestingUtils.createContactList( 1, true)[0].Id;
            UPSERT projectRoster;
            List<Form_Assignment__c> assignmentsList = TestingUtils.createFormAssignmentList (5, testFormItemList, false);
            for(Form_Assignment__c formAssignment : assignmentsList ) {
                formAssignment.Recipient_Role__c = projectRoster.Id;
            }
            UPSERT assignmentsList;
            testFormItemList = [SELECT Id, Name, ( SELECT Recipient_Name__c FROM Form_Assignments__r ) FROM Form_Item__c];
            testSendFormOutboundEmailController.formItems = testFormItemList;
            testSendFormOutboundEmailController.sendTo = assignmentsList[0].Recipient_Name__c;
            try { String formItemsName = testSendFormOutboundEmailController.formItemsName; } catch ( Exception ex ) {}
        Test.stopTest();
    }
    
    private static testMethod void testSendFormOutboundEmailController1() {
                
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        
        Test.setCurrentPageReference(Page.SendFormOutboundEmail);
        List<Form_Item__c> testFormItemListSelected = [Select Id, Name From Form_Item__c Where Id IN: testFormItemList];
        
        Test.startTest();
            testSendFormOutboundEmailController = new SendFormOutboundEmailController();
            
            //SendFormOutboundEmailController.updateFormAssignItems('test', testFormItemListSelected[0].Id );
            
        Test.stopTest();

    }
}