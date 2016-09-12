@isTest
private class TestScanAndSendToClientExtention {
    private static final String CONTACT_TEST_FIRST_NAME = 'TestFirstName'; 
    private static final String CONTACT_TEST_LAST_NAME = 'TestlastName';
    private static final String CONTACT_EMAIL = 'testemail@mail.com';  
    private static final String TASK_ITEM_FUNCTIONALITY_OBJECT_NAME = 'Task_Item_Functionality__c';
    private static final String RECORD_TYPE_NAME = 'Scan and Send to Client';
    private static final String EMAIL_TO_DDP = 'TestEmailToDDP';
    private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';
    
    private static final Integer NUMBER_TO_CREATE = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private static Account testAccount;
    private static Contact testContact;
    private static ApexPages.StandardController testController;
    private static ScanAndSendToClientExtention testScanAndSendToClientExt;
    private static User projectManagerUser;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Task_Item__c> testTaskItemList; 
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Comments_Transmittal__c> testCommnetsTransmittalList;
    private static List<Transmittal__c> testTransmitalList;
    private static List<Form_Item__c> testFormList;
    private static Service_Item__c testService;
    private static LStore__Stored_Document__c testStoredDoc;
    private static Loop__DDP__c testLoopDDP;
    private static List<Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOptionList;
    private static RecordType testRecordType;
    private static RecordType testRecordTypeContact;
    private static RecordType testRecordTypetaskItemFunctionality;
    private static List<Task_Item_Functionality__c> testTaskItemFunctionality;
      
    
    private static void setUp(){
        FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
                                                                                                         City__c = 'city',
                                                                                                         Street__c = 'street',
                                                                                                         Phone__c = '888-999-666',
                                                                                                         Fax__c = '111-222-333');
        Insert testFulfillmentOfficeAddresses;

        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, false)[0];
            testContact.FirstName = CONTACT_TEST_FIRST_NAME;  
            testContact.LastName = CONTACT_TEST_LAST_NAME; 
            testContact.Email = CONTACT_EMAIL;
            testContact.MailingCity  = 'TestCity';
            testContact.MailingStreet = 'TestStreet';
            insert testContact;    
        TestingUtils.createProposalWithProjectProfileList (NUMBER_TO_CREATE);
        testProjectProfileList = TestingUtils.testProjectProfileList;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
        }
        update testProjectProfileList;

        testService = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false)[0];
        testService.Project_Profile__c = testProjectProfileList[0].Id;
        testService.Proposal__c = testProjectProfileList[0].Proposal__c;
        insert testService;

        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, testService.Id, testProjectProfileList[0].Id, true);  
        testRecordTypeContact = [SELECT DeveloperName ,SObjectType FROM RecordType WHERE SObjectType = 'Project_Roster__c' AND DeveloperName  = 'Contact' limit 1];   
        testRecordTypetaskItemFunctionality = [Select Id From RecordType where SobjectType =: TASK_ITEM_FUNCTIONALITY_OBJECT_NAME AND Name =: RECORD_TYPE_NAME limit 1];
    }

    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.ScanAndSendToClient);
        testController = new ApexPages.StandardController(testTaskItemList[0]);
        testScanAndSendToClientExt= new ScanAndSendToClientExtention(testController);
    }
    
    private static void insertAdditionalData(Boolean doInsert){
        testProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false);
            for(Project_Roster__c item : testProjectRosterList){
                item.Project_Profile__c = testProjectProfileList[0].Id;
                item.Contact__c = testContact.Id;
                item.Role__c = 'test roster role';
                item.RecordTypeId = testRecordTypeContact.Id;
            }
            if(doInsert){
                insert testProjectRosterList;
            }
        testCommnetsTransmittalList = TestingUtils.createCommnetsTransmittal(NUMBER_TO_CREATE, false);
        for(Comments_Transmittal__c item : testCommnetsTransmittalList){
            item.Description__c = 'TestDescript';
            item.Short_Name__c = 'Testname';
        }  
            insert testCommnetsTransmittalList;
            
        testTransmitalList = TestingUtils.createTransmital(NUMBER_TO_CREATE, false);
        for(Transmittal__c item : testTransmitalList){
            item.Task_Item__c = testTaskItemList[0].Id;
        }  
            insert testTransmitalList;
        testStoredDoc = testingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE, false)[0];    
            testStoredDoc.LStore__File_Name__c = 'TestName';
            insert testStoredDoc;
        testFormList = TestingUtils.createFormItemList(NUMBER_TO_CREATE, false);
        for(Form_Item__c item : testFormList){
            item.Form_Name__c = 'TestName';
            item.Stored_Document__c = testStoredDoc.Id;
            item.Service_Item__c = testService.Id;
            item.Quantity_For_Transmittal__c = 3;
            item.Short_Form_Name__c = 'TestName';
        }
            insert testFormList;
        testRecordType = [SELECT Name,SObjectType FROM RecordType WHERE SObjectType = 'Loop__DDP_Integration_Option__c' AND Name = :DDPEmailServices.DELIVERY_METHOD_ATTACH];   
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false)[0];
            testLoopDDP.Name = DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT;
            insert testLoopDDP;
        testLoopDDPIntegrationOptionList = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP.Id, true);  
        
        testTaskItemFunctionality = TestingUtils.createTaskItemFunctionality(NUMBER_TO_CREATE, false);
        for(Task_Item_Functionality__c item : testTaskItemFunctionality){
            item.Task_Item__c = testTaskItemList[0].Id;
            item.RecordTypeId = testRecordTypetaskItemFunctionality.Id;
            item.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            item.Is_Email_Sent__c = false;
            item.Project_Roster__c = testProjectRosterList[0].Id;
        }     
            insert testTaskItemFunctionality; 
            
    }

    private static testmethod void testInitController(){
        setUp();
        insertAdditionalData(true);

        Test.startTest();
            getPageWithController();

            System.assert(testScanAndSendToClientExt != null);

            Boolean testBoolean;
            testBoolean = testScanAndSendToClientExt.emailTypeRecord == null;
            testBoolean = testScanAndSendToClientExt.disabledButton == null;
            testBoolean = testScanAndSendToClientExt.isInactiveService == null;
            testBoolean = testScanAndSendToClientExt.isShippingRequestPanel == null;
            testBoolean = testScanAndSendToClientExt.shippingRequest == null;
            testBoolean = testScanAndSendToClientExt.scanAndSaveDataMap == null;
            testBoolean = testScanAndSendToClientExt.projectProfileItem == null;
            testBoolean = testScanAndSendToClientExt.recordsForAttachmentsIds == null;
            testBoolean = testScanAndSendToClientExt.contactRecipient == null;
            testBoolean = testScanAndSendToClientExt.scanAndSaveItemId == null;
            testBoolean = testScanAndSendToClientExt.projectProfileItem == null;
            testScanAndSendToClientExt.scanAndSaveDataRows = testTaskItemFunctionality;
            testBoolean = testScanAndSendToClientExt.updateDataRowsAction() == null;
            testScanAndSendToClientExt.scanAndSaveItemId = String.valueOf(testTaskItemFunctionality[0].Id);
            testBoolean = testScanAndSendToClientExt.deleteDataRowAction() == null;
            Id incorrectTIFId = Id.valueOf(Task_Item_Functionality__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
            testScanAndSendToClientExt.scanAndSaveDataRows.add(new Task_Item_Functionality__c(Id = incorrectTIFId));
            testScanAndSendToClientExt.scanAndSaveItemId = incorrectTIFId;
            testBoolean = testScanAndSendToClientExt.deleteDataRowAction() == null;
            for( Task_Item_Functionality__c recordItem : testScanAndSendToClientExt.scanAndSaveDataRows ){
                recordItem.Is_Email_Sent__c = true;
            }
            testBoolean = testScanAndSendToClientExt.populateRecordsToSendMap() == null;
            testBoolean = testScanAndSendToClientExt.recordsToSendMap == null;
            testBoolean = testScanAndSendToClientExt.DDPName == null;
            testBoolean = testScanAndSendToClientExt.draftTemplateName == null;
            testBoolean = testScanAndSendToClientExt.emailTemplateName == null;
            for( Task_Item_Functionality__c recordItem: testScanAndSendToClientExt.scanAndSaveDataRows ){
                recordItem.Is_Email_Sent__c = true;
                recordItem.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            }
            testBoolean = testScanAndSendToClientExt.recordToSendEmailId == null;
            testBoolean = testScanAndSendToClientExt.recordToSendEmail == null;

            testBoolean = testScanAndSendToClientExt.showTemplateEditor == null;
            testBoolean = testScanAndSendToClientExt.previewEmailForCurrentRecordAction() == null;
            testBoolean = testScanAndSendToClientExt.emailsToDDP == null;
            testScanAndSendToClientExt.emailsToDDP = 'test value';
            testBoolean = testScanAndSendToClientExt.updateRecordCCField() == null;
            testBoolean = testScanAndSendToClientExt.addNewDataRowAction() == null;
            testBoolean = testScanAndSendToClientExt.updateRecordToSendEmail() == null;
            testScanAndSendToClientExt.rosterId = testProjectRosterList[0].Id;
            testBoolean = testScanAndSendToClientExt.rosterSendToAction() == null;
            testBoolean = testScanAndSendToClientExt.rosterReplyToAction() == null;
            testScanAndSendToClientExt.rosterReplyToId = ProjectRosterServices.getRosterByProjectId(testScanAndSendToClientExt.taskItem.Project_Profile__c)[0].Id;
            testBoolean = testScanAndSendToClientExt.rosterReplyToAction() == null;
            testBoolean = testScanAndSendToClientExt.rosterCCToAction() == null;
            Project_Roster__c projectRoster = ProjectRosterServices.getRosterByProjectId(testScanAndSendToClientExt.taskItem.Project_Profile__c)[0];
            testScanAndSendToClientExt.wrapoutRosters.add(new ScanAndSendToClientExtention.rosterWrapper(projectRoster.Id, projectRoster));
            testBoolean = testScanAndSendToClientExt.rosterCCToAction() == null;
            testBoolean = testScanAndSendToClientExt.addCCToRoster() == null;
            testBoolean = testScanAndSendToClientExt.disableAddCCButton == null;
            testBoolean = testScanAndSendToClientExt.rosterIdToRoleOptions == null;
            testBoolean = testScanAndSendToClientExt.commentsShortName == null;
            testBoolean = testScanAndSendToClientExt.transmittal == null;
            testBoolean = testScanAndSendToClientExt.nameToRosterMap == null;
            testBoolean = testScanAndSendToClientExt.previewTransmittal() == null;
            testBoolean = testScanAndSendToClientExt.filledOutTransmittalRecord() == null;
            testBoolean = testScanAndSendToClientExt.cancelAction() == null;
            testBoolean = testScanAndSendToClientExt.saveTransmittal() == null;
            testBoolean = testScanAndSendToClientExt.attachPDF() == null;
            testBoolean = testScanAndSendToClientExt.shippingRequestAction() == null;
            testBoolean = testScanAndSendToClientExt.sendShippingRequestAction() == null;
            testBoolean = testScanAndSendToClientExt.cancelFromShipping() == null;

        Test.stopTest();
    }
}