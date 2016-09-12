@isTest
private class TestCompleteFormsTaskExtension {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_SIGNATURE = 1;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 1;
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
    private static CompleteFormsTaskExtension testController;
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
    }

    private static void setupData (){
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
                formTemplateItem.Municipality__c = testMunucipalitiesList[0].Name;
                formTemplateItem.sve_SVE_Visualforce_Page__c = 'Test_Page_' + String.valueOf(i);
                testFormTemplateList.add(formTemplateItem);
            }
            i++;
        }
        insert testFormTemplateList;

        formTempleteId.removeEnd(';');

        List<sObject> sObjectInsertList = new List<sObject>();
        testProjectRosterList = new List<Project_Roster__c>();
        testServiceItemList = new List<Service_Item__c>();
        Map<Id, List<Project_Roster__c>> projectWithRosterMap = new Map<Id, List<Project_Roster__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectWithRosterMap.put(projectProfileItem.Id, new List<Project_Roster__c>());
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.User__c = projectProfileItem.OwnerId;
                projectRosterItem.User_Contact__c = 'User';
                projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                testProjectRosterList.add(projectRosterItem);
                sObjectInsertList.add(projectRosterItem);
                projectWithRosterMap.get(projectProfileItem.Id).add(projectRosterItem);
            }
        }
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Form_Id__c = formTempleteId;
                serviceItemItem.Forms__c = formTempleteId;
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Successor_Milestone__c = 'ProjectEnd';
                testServiceItemList.add(serviceItemItem);
                sObjectInsertList.add(serviceItemItem);
            }
        }
        insert sObjectInsertList;

        sObjectInsertList = new List<sObject>();
        testFormItemList = new List<Form_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Form_Template__c formTemplateItem : testFormTemplateList){
                i = 0;
                for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)) {
                    formItemItem.Service_Item__c = serviceItemItem.Id;
                    formItemItem.Form_Signatories__c = 'Project Manager';
                    formItemItem.Project__c = serviceItemItem.Project_Profile__c;
                    formItemItem.Form_Template__c = formTemplateItem.Id;
                    formItemItem.Short_Form_Name__c = i == 0 ? formTemplateItem.Form_ID__c : formTemplateItem.Form_ID__c + '_00' + String.valueOf(i);
                    formItemItem.Form_ID__c = formTemplateItem.Form_ID__c;
                    formItemItem.sve_Meta_Data_Query__c = 'Select Id From Form_Item__c Where Id = ';
                    formItemItem.sve_SVE_Visualforce_Page__c = formTemplateItem.sve_SVE_Visualforce_Page__c;
                    testFormItemList.add(formItemItem);
                    sObjectInsertList.add(formItemItem);
                    i++;
                }
            }
        }
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList (NUMBER_TO_CREATE_TASK_ITEM,
                                                                              serviceItemItem.Id,
                                                                              serviceItemItem.Project_Profile__c,
                                                                              false)){
                testTaskItemList.add(taskItemItem);
                sObjectInsertList.add(taskItemItem);
            }
        }
        insert sObjectInsertList;

        for (Task_Item__c ti : testTaskItemList){
            ti.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
            ti.Actual_Start_Date__c = DateTime.now();
            ti.Expected_Start_Date__c = DateTime.now();
            ti.Expected_End_Date__c = DateTime.now();
            ti.Expected_Duration__c = TaskManagementServices.TIME_DURATION_PATTERN;
        }
        update testTaskItemList;

        testFormSignatureList = new List<Form_Signature__c>();
        for (Form_Item__c formItemItem : testFormItemList){
            for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList (NUMBER_TO_CREATE_FORM_SIGNATURE, formItemItem.Id, false)){
                formSignatureItem.Project_Roster__c = projectWithRosterMap.get(formItemItem.Project__c)[0].Id;
                formSignatureItem.Role__c = projectWithRosterMap.get(formItemItem.Project__c)[0].Role__c;
                formSignatureItem.Order__c = 0;
                testFormSignatureList.add(formSignatureItem);
            }
        }
        insert testFormSignatureList;
    }

    private static void preparePageController (Task_Item__c taskItemForStandardController){
        testPage = Page.CompleteFormsTaskItem;
        Test.setCurrentPage(testPage);
        if (taskItemForStandardController != null) {
            testStandardController = new ApexPages.standardController(taskItemForStandardController);
            testController = new CompleteFormsTaskExtension(testStandardController);
        }
    }

    private static testmethod void testInitCompleteFormsTaskExtension(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        Test.startTest();

            preparePageController (testTaskItemList[0]);
            System.assert(testController != null);
            testController.autorun();

        Test.stopTest();


        System.assert(!testController.regionOptions.isEmpty());
        System.assert(testController.FormTemplatesWrapperList != null);
    }

    private static testmethod void testSearchAction(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        testController.refNumberFilter = testFormTemplateList[0].Form_ID__c;
        testController.shortNameFilter = testFormTemplateList[0].Name;
        testController.fullNameFilter = testFormTemplateList[0].Form_Name__c;
        testController.municipalityFilter = testFormTemplateList[0].Municipality__c;
        testController.regionId = testFormTemplateList[0].Region__c;
        testController.isForms = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_FORM;
        testController.isEmails = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_EMAIL;
        testController.isLetters = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_LETTER;

        Test.startTest();

            testController.searchAction();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty());

        System.assert(!testController.formTemplatesList.isEmpty());
        System.assert(!testController.FormTemplatesWrapperList.isEmpty());
        System.assertEquals(1, testController.formTemplatesList.size());
        System.assertEquals(1, testController.FormTemplatesWrapperList.size());

        System.assertEquals(testFormTemplateList[0].Id, testController.formTemplatesList[0].Id);
    }

    private static testmethod void testSearchActionWithIncorrectFilterCriteria(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        testController.refNumberFilter = testFormTemplateList[0].Form_ID__c + String.valueOf(testFormTemplateList[0].Id);//incorrect filter criteria
        testController.shortNameFilter = testFormTemplateList[0].Name;
        testController.fullNameFilter = testFormTemplateList[0].Form_Name__c;
        testController.municipalityFilter = testFormTemplateList[0].Municipality__c + 'test text to get incorrect filter criteria';//incorrect filter criteria
        testController.regionId = testFormTemplateList[0].Region__c + 'test text to get incorrect filter criteria';//incorrect filter criteria
        testController.isForms = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_FORM;
        testController.isEmails = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_EMAIL;
        testController.isLetters = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_LETTER;

        Test.startTest();

            testController.searchAction();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());

        System.assert(testController.formTemplatesList.isEmpty());
    }

    private static testmethod void testGetSelectedFormTemplates(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        testController.refNumberFilter = testFormTemplateList[0].Form_ID__c;
        testController.shortNameFilter = testFormTemplateList[0].Name;
        testController.fullNameFilter = testFormTemplateList[0].Form_Name__c;
        testController.municipalityFilter = testFormTemplateList[0].Municipality__c;
        testController.regionId = testFormTemplateList[0].Region__c;
        testController.isForms = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_FORM;
        testController.isEmails = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_EMAIL;
        testController.isLetters = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_LETTER;
        testController.searchAction();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty());

        System.assert(!testController.formTemplatesList.isEmpty());
        System.assert(!testController.FormTemplatesWrapperList.isEmpty());
        System.assertEquals(testFormTemplateList[0].Id, testController.formTemplatesList[0].Id);

        for (CompleteFormsTaskExtension.FormTemplatesWrapper formTemplatesWrapperItem : testController.FormTemplatesWrapperList){
            formTemplatesWrapperItem.isSelected = true;
        }

        Test.startTest();

            testController.getSelectedFormTemplates();

        Test.stopTest();
    }

    private static testmethod void testcloneAction(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        Test.startTest();

            testController.cloneAction();
            testController.selectedFormItemIdForClone = testController.formWrapperList[0].formItemRecord.Id;
            testController.cloneAction();
            testController.formId = testController.formWrapperList[0].formItemRecord.Id;
            testController.updateMetaDataRecord();

        Test.stopTest();
    }

    private static testmethod void testForCoverage(){
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        List<Form_Meta_Data_Object_1__c> fmdoList = [SELECT Id FROM Form_Meta_Data_Object_1__c];
        testLStoreStoredDocumentList = new List<LStore__Stored_Document__c>();
        for (Form_Meta_Data_Object_1__c fmdo : fmdoList){
            for (LStore__Stored_Document__c storeDoc : TestingUtils.createLStoreStoredDocumentList(1, fmdo.Id, false)){
                storeDoc.RecordTypeId = StoredDocumentServices.FORMS_RECORD_TYPE_ID;
                testLStoreStoredDocumentList.add(storeDoc);
            }
        }
        insert testLStoreStoredDocumentList;

        preparePageController (testTaskItemList[0]);

        testController.refNumberFilter = testFormTemplateList[0].Form_ID__c;
        testController.shortNameFilter = testFormTemplateList[0].Name;
        testController.fullNameFilter = testFormTemplateList[0].Form_Name__c;
        testController.municipalityFilter = testFormTemplateList[0].Municipality__c;
        testController.regionId = testFormTemplateList[0].Region__c;
        testController.isForms = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_FORM;
        testController.isEmails = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_EMAIL;
        testController.isLetters = testFormTemplateList[0].Form_Type__c == FormTemplatesServices.FORM_TYPE_LETTER;
        testController.searchAction();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty());

        System.assert(!testController.formTemplatesList.isEmpty());
        System.assert(!testController.FormTemplatesWrapperList.isEmpty());
        System.assertEquals(testFormTemplateList[0].Id, testController.formTemplatesList[0].Id);

        for (CompleteFormsTaskExtension.FormTemplatesWrapper formTemplatesWrapperItem : testController.FormTemplatesWrapperList){
            formTemplatesWrapperItem.isSelected = true;
        }
        testController.formType = FormTemplatesServices.FORM_TYPE_FORM;
        testController.SelectedFormItemId = null;
        Test.startTest();
            List<LStore__Stored_Document__c> test1 = testController.lStoreDocumentList;

            testController.formId = testFormItemList[0].Id;
            testController.getStoreDocuments();
            testController.deleteFormItem();
            testController.SelectedFormItemId = testFormItemList[0].Id;
            testController.deleteFormItem();
            testController.submitAction();
            testController.addNewForm();
            testController.cancelAction();
            testController.storedDocumentId = 'testId';
            for (CompleteFormsTaskExtension.FormWrapper formWrapperItem : testController.formWrapperList){
                testController.formId = formWrapperItem.formItemRecord.Id;
                for (Form_Signature__c formSignatureItem : formWrapperItem.formSignatureList){
                    testController.formSignId = formSignatureItem.Id;
                }
            }
            testController.updateFormSignature();
            testController.disableAddNewButton();
            testController.saveAction();

            Boolean testBoolean;
            testBoolean = testController.iFrameDocumentPageReference == null;
            testBoolean = testController.selectedFormItemIdForClone == null;
            testBoolean = testController.serviceItemId == null;
            testBoolean = testController.formSignId == null;
            testBoolean = testController.formName == null;
            testBoolean = testController.formIdString == null;
            testBoolean = testController.isValid == null;
            testBoolean = testController.sveFormPage == null;
            testBoolean = testController.sveFormMetaData == null;
            testBoolean = testController.downloadPdfUrl == null;
            testBoolean = testController.isInactiveService == null;
            testBoolean = testController.regionName == null;
            testBoolean = testController.iframeUrl == null;
            testBoolean = testController.getRoster == null;
            testBoolean = testController.prepareDocumentUpload() == null;
            testBoolean = testController.projectRosterMap == null;
            testBoolean = testController.openPDF() == null;

            String testString = '';
            for (CompleteFormsTaskExtension.FormWrapper formWrapperItem : testController.formWrapperList){
                testString += formWrapperItem.formItemRecord.Id + ';';
            }
            testController.orderedForm = testString;
            testBoolean = testController.saveRowPosition() == null;
            testController.getStoreDocuments();
            for (LStore__Stored_Document__c storeDoc : testController.lStoreDocumentsForDisplay){
                testController.storedDocumentId = storeDoc.Id;
            }
            testBoolean = testController.deleteStoredDocument() == null;

        Test.stopTest();
    }
}