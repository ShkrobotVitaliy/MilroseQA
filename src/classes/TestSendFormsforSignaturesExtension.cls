@isTest
private class TestSendFormsforSignaturesExtension {
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
    private static final Integer NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1 = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_SIGNATURE = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_ASSIGNMENT = 1;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 3;
    private static final String TEST_FORM_TEMPLATE_START_NAME = 'F';
    private static final Integer NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL = 1;
    private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';
    private final static String TEST_SHORT_NAME = 'test short name';
    private final static String TEST_DESCRIPTION = 'test description';
    private final static String TEST_PROJECT_ROSTER_ROLE = 'test Project Roster Role';

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
    private static List<Form_Assignment__c> testFormAssignmentList;
    private static List<Form_Meta_Data_Object_1__c> testFormMetadataObject1List;
    private static List<LStore__Stored_Document__c> testStoredDocumentList;
    private static List<Comments_Transmittal__c> testCommentsTransmittalList;
    private static List<Transmittal__c> testTransmittalList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Id projectRosterUserRecordTypeId;
    private static Id projectRosterContactRecordTypeId;

    private static PageReference testPage;
    //private static SendFormsforSignaturesTaskItemExtension testController;
    private static ApexPages.StandardController testStandardController;
    private static SendFormsforSignaturesTaskItemExtension testSendFormsforSignaturesTaskItemExtension;
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

    private static void preparePageController (Task_Item__c taskItemForStandardController){
        testPage = Page.SendFormsforSignaturesSealsTaskItem;
        Test.setCurrentPage(testPage);
        if (taskItemForStandardController != null) {
            testStandardController = new ApexPages.standardController( taskItemForStandardController );
            testSendFormsforSignaturesTaskItemExtension = new SendFormsforSignaturesTaskItemExtension(testStandardController);
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
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;

        testCommentsTransmittalList = TestingUtils.createCommnetsTransmittal(NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL, false);
        for (Comments_Transmittal__c commentsTransmittalItem : testCommentsTransmittalList){
            commentsTransmittalItem.Short_Name__c = TEST_SHORT_NAME;
            commentsTransmittalItem.Description__c = TEST_DESCRIPTION;
        }
        insert testCommentsTransmittalList;

        testMunucipalitiesList = [SELECT Id, Name, Region__c, Region__r.Name
                                  FROM Munucipalities__c
                                  WHERE Id IN : testMunucipalitiesList];

        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, false);
        for (Integer i = 0; i < testContactWithAccountList.size(); i++){
            testContactWithAccountList[i].Email = 'test' + String.valueOf(i) + 'test@gmail.com';
        }
        insert testContactWithAccountList;
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROJECT_PROFILE);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
        }
        update testProjectProfileList;

        testTransmittalList = new List<Transmittal__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for(Transmittal__c transmittalItem : TestingUtils.createTransmital(1, false)){
                transmittalItem.Project_Profile__c = projectProfileItem.Id;
                transmittalItem.VIA__c = 'Messenger';
            }
        }
        insert testTransmittalList;
//      
       testProjectRosterList = new List<Project_Roster__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Integer i = 0;
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                projectRosterItem.User__c = currentUserId;
                projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(i++);
                testProjectRosterList.add(projectRosterItem);
            }
            for (Contact contactItem : testContactWithAccountList){
                for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                    projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
                    projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                    projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
                    projectRosterItem.Contact__c = contactItem.Id;
                    projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(i++);
                    testProjectRosterList.add(projectRosterItem);
                }
            }
        }
        insert testProjectRosterList;

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, projectProfileItem.Proposal__c, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, false);
        for (Form_Template__c formTemplateItem : testFormTemplateList){
            formTemplateItem.Name = formTemplateItem.Form_ID__c;
            formTemplateItem.Form_Name__c = formTemplateItem.Form_ID__c;
            formTemplateItem.Municipality__c = testMunucipalitiesList[0].Name;
            formTemplateItem.Region__c = RegionServices.REGION_NAME_NY;
            formTemplateItem.Form_Type__c = FormTemplatesServices.FORM_TYPE_LETTER;
        }
        insert testFormTemplateList;

        testFormItemList = new List<Form_Item__c>();
        for (Form_Template__c formTemplateItem : testFormTemplateList){
            for (Task_Item__c taskItemItem : testTaskItemList){
                for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
                    formItemItem.Service_Item__c = taskItemItem.Service_Item__c;
                    formItemItem.Project__c = taskItemItem.Project_Profile__c;
                    formItemItem.Complete_Forms__c = taskItemItem.Id;
                    formItemItem.Form_Template__c = formTemplateItem.Id;
                    formItemItem.Form_Id__c = formTemplateItem.Form_ID__c;
                    testFormItemList.add(formItemItem);
                }
            }
        }
        insert testFormItemList;

        testFormMetadataObject1List = new List<Form_Meta_Data_Object_1__c>();
        for (Form_Item__c formItemItem : testFormItemList){
            for (Form_Meta_Data_Object_1__c fmdo : TestingUtils.createFormMetaDataObject1List(NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1, formItemItem.Id, false)){
                fmdo.Service_Item__c = formItemItem.Service_Item__c;
                fmdo.Task_Item__c = formItemItem.Complete_Forms__c;
                testFormMetadataObject1List.add(fmdo);
            }
        }
        insert testFormMetadataObject1List;

        testFormAssignmentList = new List<Form_Assignment__c>();
        for (Form_Item__c formItemItem : testFormItemList){
            for (Project_Roster__c projectRosterItem : testProjectRosterList){
                for (Form_Assignment__c formAssignmentItem : TestingUtils.createFormAssignmentList(NUMBER_TO_CREATE_FORM_ASSIGNMENT, new List<Form_Item__c>{formItemItem}, false)){
                    formAssignmentItem.Recipient_Role__c = projectRosterItem.Id;
                    formAssignmentItem.Project__c = formItemItem.Project__c;
                    testFormAssignmentList.add(formAssignmentItem);
                }
            }
        }
        insert testFormAssignmentList;
    }

    private static testMethod void testSendFormsforSignaturesTaskItemExtension() {
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        preparePageController(testTaskItemList[0]);
        System.assert(testSendFormsforSignaturesTaskItemExtension != null);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty());
              
        Test.startTest();
            
            testSendFormsforSignaturesTaskItemExtension = new SendFormsforSignaturesTaskItemExtension(testStandardController);
            Project_Roster__c itemRoster = TestingUtils.createProjectRosterList(1, false)[0];
            itemRoster.Contact__c = testContactWithAccountList[0].Id;
            itemRoster.Role__c = 'Project manager 1';
            itemRoster.RecordTypeId = projectRosterContactRecordTypeId;
            insert itemRoster;
            String teststoredDocumentId = testSendFormsforSignaturesTaskItemExtension.storedDocumentId;
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedIdRolesSet.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedFormItemsList.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedFormAssignmentsList.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.transmittal != null);
            testSendFormsforSignaturesTaskItemExtension.formRef = 'F1_001';
            testSendFormsforSignaturesTaskItemExtension.formItemId= testFormItemList[0].Id;
            Boolean testisInactiveService = testSendFormsforSignaturesTaskItemExtension.isInactiveService;
//            testSendFormsforSignaturesTaskItemExtension.formItemsList.add(testFormItemList[0]);
            
            testSendFormsforSignaturesTaskItemExtension.selectedFormItemId  = testFormItemList[0].Id;
            testSendFormsforSignaturesTaskItemExtension.getFullWrapper();
    
            testSendFormsforSignaturesTaskItemExtension.orderedForm  = 'testString';

            System.debug('!!!!! testFormItemList.size() = ' + testFormItemList.size());


            Form_Item__c testFormItem = testSendFormsforSignaturesTaskItemExtension.newFormItem;
//            testSendFormsforSignaturesTaskItemExtension.formWrapperList.add( new SendFormsforSignaturesTaskItemExtension.FormWrapper( testFormItemList[0] ) );
            for( SendFormsforSignaturesTaskItemExtension.FormWrapper item: testSendFormsforSignaturesTaskItemExtension.formWrapperList ){
                item.isSelected = true;
            }

            Shipping_Request__c testShipmentRequest = testSendFormsforSignaturesTaskItemExtension.shippingRequest;
            testSendFormsforSignaturesTaskItemExtension.shippingRequest = testShipmentRequest;
            testSendFormsforSignaturesTaskItemExtension.rosters.add( itemRoster );
            testSendFormsforSignaturesTaskItemExtension.rosterId = itemRoster.Id;
            testSendFormsforSignaturesTaskItemExtension.saveAction();
            testSendFormsforSignaturesTaskItemExtension.printPendingForms();
            testSendFormsforSignaturesTaskItemExtension.getSelectedFormItems();

            testSendFormsforSignaturesTaskItemExtension.saveNewFormItem();
            testSendFormsforSignaturesTaskItemExtension.cancelSaveNewFormItem();

            testSendFormsforSignaturesTaskItemExtension.copyFormItem();
            testSendFormsforSignaturesTaskItemExtension.forwardFormAssignment(); 
            testSendFormsforSignaturesTaskItemExtension.saveAction();

            testSendFormsforSignaturesTaskItemExtension.changeSendToAction();
            
            testSendFormsforSignaturesTaskItemExtension.getFullWrapper();
            
//            testSendFormsforSignaturesTaskItemExtension.formWrapperList.add( new SendFormsforSignaturesTaskItemExtension.FormWrapper( testFormItemList[0] ) );
            for( SendFormsforSignaturesTaskItemExtension.FormWrapper item: testSendFormsforSignaturesTaskItemExtension.formWrapperList ){
                item.isSelected = true;
            }
            
            testSendFormsforSignaturesTaskItemExtension.rosters.add( itemRoster );
            testSendFormsforSignaturesTaskItemExtension.rosterId = itemRoster.Id;
            testSendFormsforSignaturesTaskItemExtension.selectedFormItemsList.add(testFormItemList[0]);
            
            testSendFormsforSignaturesTaskItemExtension.printPendingForms();
            testSendFormsforSignaturesTaskItemExtension.rosterSendToAction();
            testSendFormsforSignaturesTaskItemExtension.rosterReplyToAction();
            testSendFormsforSignaturesTaskItemExtension.rosterCCToAction();
            testSendFormsforSignaturesTaskItemExtension.addCCToRoster();
            testSendFormsforSignaturesTaskItemExtension.saveTransmittalAction();
            testSendFormsforSignaturesTaskItemExtension.attachPDF();
            
            testSendFormsforSignaturesTaskItemExtension.wrapoutRosters.add( new SendFormsforSignaturesTaskItemExtension.rosterWrapper( null, itemRoster ) );
            
            testSendFormsforSignaturesTaskItemExtension.filledOutTransmittalRecord();
            testSendFormsforSignaturesTaskItemExtension.cancelAction();
            testSendFormsforSignaturesTaskItemExtension.formItemId= testFormItemList[0].Id;
            testSendFormsforSignaturesTaskItemExtension.formItemsList.add(testFormItemList[0]);
            testSendFormsforSignaturesTaskItemExtension.getFullWrapper();

            Id testIDformAssignmentId = testSendFormsforSignaturesTaskItemExtension.formAssignmentId;
//            testSendFormsforSignaturesTaskItemExtension.formWrapperList.add( new SendFormsforSignaturesTaskItemExtension.FormWrapper( testFormItemList[0] ) );
            for( SendFormsforSignaturesTaskItemExtension.FormWrapper item: testSendFormsforSignaturesTaskItemExtension.formWrapperList ){
                item.isSelected = true;
            }
            
            testSendFormsforSignaturesTaskItemExtension.rosters.add( itemRoster );
            testSendFormsforSignaturesTaskItemExtension.rosterId = itemRoster.Id;
            testSendFormsforSignaturesTaskItemExtension.selectedFormItemsList.add(testFormItemList[0]);
            
            testSendFormsforSignaturesTaskItemExtension.sendFormItems();
            testSendFormsforSignaturesTaskItemExtension.shippingRequestAction();
            testSendFormsforSignaturesTaskItemExtension.cancelFromShipping();
        Test.stopTest();

    }

    private static testMethod void testForCoverage() {
        setupData();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();


        preparePageController(testTaskItemList[0]);
        System.assert(testSendFormsforSignaturesTaskItemExtension != null);

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty());
              
        Test.startTest();
            Shipping_Request__c testShipmentRequest = testSendFormsforSignaturesTaskItemExtension.shippingRequest;

            Project_Roster__c itemRoster = TestingUtils.createProjectRosterList(1, false)[0];
            itemRoster.Contact__c = testContactWithAccountList[0].Id;
            itemRoster.Role__c = 'Project manager 1';
            itemRoster.RecordTypeId = projectRosterContactRecordTypeId;
            insert itemRoster;

            String testserviceItemId = testSendFormsforSignaturesTaskItemExtension.serviceItemId;
            testSendFormsforSignaturesTaskItemExtension.rosters.add( itemRoster );
            testSendFormsforSignaturesTaskItemExtension.rosterId = itemRoster.Id;
            testSendFormsforSignaturesTaskItemExtension = new SendFormsforSignaturesTaskItemExtension(testStandardController);
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedIdRolesSet.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedFormItemsList.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.selectedFormAssignmentsList.isEmpty());
            System.assert(testSendFormsforSignaturesTaskItemExtension.transmittal != null);
            testSendFormsforSignaturesTaskItemExtension.formItemId= testFormItemList[0].Id;
            testSendFormsforSignaturesTaskItemExtension.getSelectedFormItems();
            testSendFormsforSignaturesTaskItemExtension.formRef = 'test';
            testSendFormsforSignaturesTaskItemExtension.copyFormItem();
            testSendFormsforSignaturesTaskItemExtension.forwardFormAssignment(); 
            testSendFormsforSignaturesTaskItemExtension.saveAction();
            testSendFormsforSignaturesTaskItemExtension.saveNewFormItem();
            testSendFormsforSignaturesTaskItemExtension.cancelSaveNewFormItem();
            testSendFormsforSignaturesTaskItemExtension.printPendingForms();

            testSendFormsforSignaturesTaskItemExtension.changeSendToAction();
            testSendFormsforSignaturesTaskItemExtension.rosterSendToAction();
            testSendFormsforSignaturesTaskItemExtension.rosterReplyToAction();
            testSendFormsforSignaturesTaskItemExtension.rosterCCToAction();
            testSendFormsforSignaturesTaskItemExtension.addCCToRoster();
            Boolean testdisableAddCCButton = testSendFormsforSignaturesTaskItemExtension.disableAddCCButton;


            testSendFormsforSignaturesTaskItemExtension.saveTransmittalAction();
            testSendFormsforSignaturesTaskItemExtension.attachPDF();
            testSendFormsforSignaturesTaskItemExtension.filledOutTransmittalRecord();
            testSendFormsforSignaturesTaskItemExtension.cancelAction();
            testSendFormsforSignaturesTaskItemExtension.selectedFormItemsList.add(testFormItemList[0]);
            testSendFormsforSignaturesTaskItemExtension.sendFormItems();
            testSendFormsforSignaturesTaskItemExtension.shippingRequestAction();
            testSendFormsforSignaturesTaskItemExtension.cancelFromShipping();
        Test.stopTest();

    }
}