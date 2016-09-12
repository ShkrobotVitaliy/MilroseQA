@isTest
private class TestPreviewAndSendEmailController {
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
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Id projectRosterUserRecordTypeId;
    private static Id projectRosterContactRecordTypeId;

    private static List<String> projectRosterRoleValuesList;

    private static void prepareRecordTypePickListValuesForTest(){
        //prepare Project Roster Record Type
        Map<String, Id> projectRosterRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Project_Roster__c');
        for (String projectRosterRecordTypeNameValue : projectRosterRecordTypesMap.keySet()){
            if (projectRosterRecordTypeNameValue == 'User') {
                projectRosterUserRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
            }
            if (projectRosterRecordTypeNameValue == 'Contact') {
                projectRosterContactRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
            }
        }
        projectRosterRoleValuesList = new List<String>();
        for (Schema.PicklistEntry ple : Project_Roster__c.Role__c.getDescribe().getPicklistValues()){
            projectRosterRoleValuesList.add(ple.getValue());
        }
    }

    private static void setupData(){
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
        setupData();
        createProjectProfileForTest(1, true);
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
            }
        }
        insert testProjectRosterList;
    }

    private static ApexPages.StandardController testController;
    private static PreviewAndSendEmailController testPreviewAndSendEmailController;

    private static testMethod void testPreviewAndSendEmailController() {

        prepareDataForTest();

        Test.startTest();
            testPreviewAndSendEmailController = new PreviewAndSendEmailController();
            testPreviewAndSendEmailController.setProject(testProjectProfileList[0]);
            System.assert( testPreviewAndSendEmailController.setLinkForRFI('http://lch-free-12415f14c3a-124e539428a-12882cef16f.cs9.force.com/?u=gr58mYa7jYq7n5j6BJEXcB_2FPouQNbe9spyBF65AkjwM_3D&o=gmN0GsuuYBczYh7k03gWT9J_2Fvg_2BS6XbstdUTUAV24o8_3D&type=Application') == null);
            testPreviewAndSendEmailController.getLinkForRFI();
            testPreviewAndSendEmailController.setEmailType( 'RFI' );
            testPreviewAndSendEmailController.getEmailType();
            testPreviewAndSendEmailController.setParentRecordId(TestingUtils.createTaskItemList(1, true)[0].Id);
            testPreviewAndSendEmailController.getParentRecordId();
            testPreviewAndSendEmailController.setShowReminders(true);
            testPreviewAndSendEmailController.setShowReminders(false);
            testPreviewAndSendEmailController.getShowReminders();
            testPreviewAndSendEmailController.setTaskItem (TestingUtils.createTaskItemList(1, true)[0]);
            Task_Item__c testTaskItem = testPreviewAndSendEmailController.getTaskItem();
            testPreviewAndSendEmailController.setProject(null);
            Project_Profile__c testProject = testPreviewAndSendEmailController.getProject();
            testPreviewAndSendEmailController.setDDPName('test');
            String testDDP = testPreviewAndSendEmailController.getDDPName();
            testPreviewAndSendEmailController.setSendTo ('test@gmail.com');
            testPreviewAndSendEmailController.getSendTo();
            testPreviewAndSendEmailController.getTaskDescriptionForFollowUp();
            testPreviewAndSendEmailController.setEmailTemplateName('Request Filing Fees Task Item');
            testPreviewAndSendEmailController.skipEmailSelection();
            testPreviewAndSendEmailController.setEmailTemplateName('testEmailTemplate');
            String testStringEmailTemplate = testPreviewAndSendEmailController.getEmailTemplateName();

            testPreviewAndSendEmailController.setDraftTemplateName('Request Filing Fees Task Item');
            String testDraftTemplateName = testPreviewAndSendEmailController.getDraftTemplateName();
            List<Id> testAttachs = new List<Id>{TestingUtils.createTaskItemList(1, true)[0].Id};
            testPreviewAndSendEmailController.setAttachmentIds(testAttachs );
            List<Id> testResultsIds = testPreviewAndSendEmailController.getAttachmentIds();

            String test1 = testPreviewAndSendEmailController.loggedUserName;
            String test2 = testPreviewAndSendEmailController.subject;
            String test3 = testPreviewAndSendEmailController.innerTemplateBody;
            Boolean test5 = testPreviewAndSendEmailController.showTemplateSelector;
            Datetime dtNow = datetime.now();
            dtNow = dtNow.addDays(1);
            testPreviewAndSendEmailController.followUpAndReminder.Follow_Up_Alert_DateTime__c = dtNow;
            testPreviewAndSendEmailController.followUpAndReminder.Recipient_Reminder_DateTime__c = dtNow;
            testPreviewAndSendEmailController.updateEmailContent();
            testPreviewAndSendEmailController.sendDDPEmail();
            testPreviewAndSendEmailController.createTasks();
            String test7 = testPreviewAndSendEmailController.emailsToCC; 
            String test8 = testPreviewAndSendEmailController.emailsForRecordFieldCC;
            testPreviewAndSendEmailController.addEmailToCC();
            Map<String, ProjectRosterWrapper> test9 = testPreviewAndSendEmailController.nameToRosterMap;
            List<LStore__Stored_Document__c> test10 = testPreviewAndSendEmailController.storeDocAttachment;
            List<SelectOption> test11 = testPreviewAndSendEmailController.itemsRelatedToAttachments;
            String test12 = testPreviewAndSendEmailController.documentRelatedTo;
            Boolean test13 = testPreviewAndSendEmailController.showAttachment;
            Map<Id, FileWrapper> test14 = testPreviewAndSendEmailController.attachedDocumentsMap;
            List<FileWrapper> test15 = testPreviewAndSendEmailController.documents; 
            testPreviewAndSendEmailController.displayDocument() ;
            testPreviewAndSendEmailController.attach();
            RFI_Scope__c test16 =testPreviewAndSendEmailController.followUpAndReminder;
            testPreviewAndSendEmailController.setReminderDate();
            testPreviewAndSendEmailController.setFollowUpDate();
            testPreviewAndSendEmailController.updateDate();
            testPreviewAndSendEmailController.saveRecipientAddress();
            testPreviewAndSendEmailController.displayAttachFormItem();
            List<SelectOption> test17 = testPreviewAndSendEmailController.rostersSendTo;
            List<selectOption> test18 = testPreviewAndSendEmailController.regionOptions;
            testPreviewAndSendEmailController.searchAction();
            testPreviewAndSendEmailController.setEmailTemplate();
        Test.stopTest();

    }

    private static testMethod void testForCoverage() {

        prepareDataForTest();

        Test.startTest();
            List<Contact> listContacts = TestingUtils.createContactList(1, false);
            listContacts[0].Is_Active__c = true;
            insert listContacts;

            testPreviewAndSendEmailController = new PreviewAndSendEmailController();
            testPreviewAndSendEmailController.setProject(testProjectProfileList[0]);
            testPreviewAndSendEmailController.setTaskItem(TestingUtils.createTaskItemList(1, true)[0]);
            Task_Item__c testTaskItem = testPreviewAndSendEmailController.getTaskItem();
            List<Id> testAttachs = new List<Id>{TestingUtils.createTaskItemList(1, true)[0].Id};
            testPreviewAndSendEmailController.setAttachmentIds(testAttachs );
            //testPreviewAndSendEmailController.setAttachmentIds(null);
            testPreviewAndSendEmailController.getAttachmentIds();
            testPreviewAndSendEmailController.sendDDPEmail();
            testPreviewAndSendEmailController.setShowReminders(true);
            Boolean testvalidDatetiemReminder = testPreviewAndSendEmailController.validDatetiemReminderFollowUp;

            testPreviewAndSendEmailController.allowSendingEmail = true;
            Boolean testAllowSend = testPreviewAndSendEmailController.allowSendingEmail;
            System.debug('!!!!!! testAllowSend = ' + testAllowSend);

            testPreviewAndSendEmailController.setDDPName('testDDPName');
            String testDDP = testPreviewAndSendEmailController.getDDPName();

            Task_Item__c ti = testPreviewAndSendEmailController.gettaskItem();
            List<EmailTemplate> testEmails = [SELECT Id FROM EmailTemplate LIMIT 1];//TestingUtils.createEmailTemplateList(1, 'test', null, 'text', true);
            testPreviewAndSendEmailController.emailTemplateDraftId = 'test string';

            Loop__DDP__c testLoopDDP = new Loop__DDP__c();
            testLoopDDP.Name = testDDP;
            insert testLoopDDP;
            List<Loop__DDP_Integration_Option__c> listLoopDDPIntOptions = TestingUtils.createLoopDDPIntegrationOptionList(1, testLoopDDP.Id, false);
            listLoopDDPIntOptions[0].Name = DDPEmailServices.DELIVERY_METHOD_EMAIL;
            listLoopDDPIntOptions[0].Loop__Template__c = testEmails[0].Id;
            insert listLoopDDPIntOptions;

            testPreviewAndSendEmailController.setAdditionalSubject('test');
            testPreviewAndSendEmailController.setAdditionalBody('testBody');
            testPreviewAndSendEmailController.setAdditionalBody('testAdditionalBody');
            String test1 = testPreviewAndSendEmailController.getAdditionalBody();

            testPreviewAndSendEmailController.setAdditionalSubject('testadditionalSubject');
            testPreviewAndSendEmailController.getAdditionalSubject();
            //Boolean isAttach = testPreviewAndSendEmailController.isAttachDocFromItem('tempDoc');
            testPreviewAndSendEmailController.setlinkToClose('testLink');
            Boolean showRedirect = testPreviewAndSendEmailController.showRedirect;

            List<Project_Profile__c> listProjProfiles = TestingUtils.createProjectProfileForTest(1, false);
            listProjProfiles[0].Project_Member__c = userinfo.getuserid();
            insert listProjProfiles;
            testPreviewAndSendEmailController.setProject(listProjProfiles[0]);

            List<Project_Roster__c> testListProjRoserts = TestingUtils.createProjectRosterList(1, false);
            testListProjRoserts[0].Contact__c = listContacts[0].Id;
            testListProjRoserts[0].Project_Profile__c = listProjProfiles[0].Id;
            insert testListProjRoserts;

            testPreviewAndSendEmailController.rosterEmailAddress = 'test@gmail.com';
            String testrosterEmailAddress = testPreviewAndSendEmailController.rosterEmailAddress;

            String testFullName = 'test@test.net';
            testPreviewAndSendEmailController.setSendToFullName(testFullName);
            System.assertEquals(testFullName, testPreviewAndSendEmailController.getSendToFullName());

            testPreviewAndSendEmailController.setEmailType( MergeEmailTemplate.RFI_EMAIL );
            testPreviewAndSendEmailController.getEmailType();
            
            //testPreviewAndSendEmailController.setProject(null);
            testPreviewAndSendEmailController.setToContact(listContacts[0]);
            Contact tectContact = testPreviewAndSendEmailController.getToContact();

            String testOrderedFormsScanAndSend = 'orderedFormsScanAndSend';
            testPreviewAndSendEmailController.orderedFormsScanAndSend = testOrderedFormsScanAndSend;

            List<SelectOption> testRosterSendTo = testPreviewAndSendEmailController.rostersSendTo;

            Map<String, String> testExtURLMap = new Map<String, String>();
            testExtURLMap.put('test1', 'testurl1');
            testExtURLMap.put('test2', 'testurl2');

            Map<String, String> mapDocumentNameToExternalURLMap = new Map<String, String>();
            mapDocumentNameToExternalURLMap.put('doc1', 'http://test');
            testPreviewAndSendEmailController.documentNameToExternalURLMap = mapDocumentNameToExternalURLMap;

            testPreviewAndSendEmailController.followUpAndReminder.Recipient_Reminder__c = true;
            testPreviewAndSendEmailController.followUpAndReminder.Follow_Up_Alert__c = true;
            Datetime dtNow = datetime.now();
            dtNow = dtNow.addDays(1);
            testPreviewAndSendEmailController.followUpAndReminder.Recipient_Reminder_DateTime__c = dtNow;
            testPreviewAndSendEmailController.followUpAndReminder.Follow_Up_Alert_DateTime__c = dtNow;
            RFI_Scope__c testRFI = testPreviewAndSendEmailController.followUpAndReminder;

            testPreviewAndSendEmailController.updateEmailContent();
            testPreviewAndSendEmailController.createTasks();

            testPreviewAndSendEmailController.setEmailType( MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL );
            testPreviewAndSendEmailController.createTasks();

            testPreviewAndSendEmailController.setAllowSendForClosedProject(true);
            System.assertEquals(true, testPreviewAndSendEmailController.getAllowSendForClosedProject());

            String taskItemFD = testPreviewAndSendEmailController.getTaskItemFollowUpDescription(testTaskItem);

            testPreviewAndSendEmailController.setisEntityLevel(true);
            System.assertEquals(true, testPreviewAndSendEmailController.getisEntityLevel());

            String testSubject = testPreviewAndSendEmailController.subject;

            testPreviewAndSendEmailController.setEmailType( MergeEmailTemplate.FORM_FOR_SIGNATURES );
            List<LStore__Stored_Document__c> listLStoreDocs = TestingUtils.createLStoreStoredDocumentList (2, '', true);

            testPreviewAndSendEmailController.storeDocAttachment = listLStoreDocs;

            Map<String, ProjectRosterWrapper> mapProjRosters = testPreviewAndSendEmailController.nameToRosterForSelection;
            Map<String, ProjectRosterWrapper> test9 = testPreviewAndSendEmailController.nameToRosterMap;

            List<FileWrapper> testListWrappers = testPreviewAndSendEmailController.documents;
            testPreviewAndSendEmailController.attach();
            List<FileWrapper> testListFileWrapper = testPreviewAndSendEmailController.sorteredFileWrapperList;
            Boolean testUSeAttachments = testPreviewAndSendEmailController.useAttachmentsUrl();

            String testSendFrom = 'testForm';
            testPreviewAndSendEmailController.setSendFrom(testSendFrom);
            System.assertEquals(testSendFrom, testPreviewAndSendEmailController.getSendFrom());
            Boolean testIsAttachDoc = testPreviewAndSendEmailController.isAttachDocFromItem(listLStoreDocs[0].Id);

            String testEmailType = 'email';
            testPreviewAndSendEmailController.setEmailType(testEmailType);

            String testemailsToCC = 'testaddress@test.com';
            testPreviewAndSendEmailController.emailsToCC = testemailsToCC;

            String testemailsForRecordFieldCC = 'testaddress@test.com';
            testPreviewAndSendEmailController.emailsForRecordFieldCC = testemailsForRecordFieldCC;

            String testsendToAddress = 'testaddress@test.com';
            testPreviewAndSendEmailController.sendToAddress = testsendToAddress;
            testPreviewAndSendEmailController.addEmailTo();

            testPreviewAndSendEmailController.displayAttachLetter();

            //List<LStore__Stored_Document__c> testListLStore = testPreviewAndSendEmailController.storeDocAttachment;

        Test.stopTest();

    }
}