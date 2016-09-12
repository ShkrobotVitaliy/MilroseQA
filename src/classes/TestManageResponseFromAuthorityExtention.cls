@isTest
private class TestManageResponseFromAuthorityExtention {
    private static ApexPages.StandardController testController;
    private static ManageResponseFromAuthorityExtention testManageResponseFromAuthorityExt;
    private static final Integer NUMBER_TO_CREATE = 5;   
    private static User projectManagerUser;
    private static User adminUser;
    private static User productionManager;
    private static List <Task_Item__c> testTaskItemList;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Project_Profile__c> testProjectProfileList;  
    private static List<Manage_Response_From_Authority__c> testmanaeResponceFromAuthorityList;
    private static List<Project_Roster__c> testProjectRosterList;
    
    private static void setUp(Boolean doInsert){        
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        adminUser = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);
        productionManager = TestingUtils.userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];        
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, null, testProjectProfileList[0].Id, doInsert);
        testmanaeResponceFromAuthorityList = TestingUtils.createManageResponceFromAuthority(NUMBER_TO_CREATE, false);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Task_Item__c = testTaskItemList[0].Id;
        }
            insert testmanaeResponceFromAuthorityList;
    }
    
    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.ManageResponseFromAuthority);
        testController = new ApexPages.StandardController(testTaskItemList[0]);
        testManageResponseFromAuthorityExt = new ManageResponseFromAuthorityExtention(testController);
    }
    
     private static void insertAdditionalData(Boolean doInsert){
        testProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false);
            for(Project_Roster__c item : testProjectRosterList){
                item.Project_Profile__c = testProjectProfileList[0].Id;
                item.Contact__c = testContact.Id; 
            }
            if(doInsert){
                insert testProjectRosterList;
            }
    }

    @isTest static void testUncoveredParts() {
        setUp( true );
        Test.setCurrentPageReference(Page.ManageResponseFromAuthority);
        testController = new ApexPages.StandardController(testTaskItemList[0]);
        testManageResponseFromAuthorityExt = new ManageResponseFromAuthorityExtention(testController);


        List<SelectOption> rosterIdToRoleOptions = testManageResponseFromAuthorityExt.rosterIdToRoleOptions;
        testManageResponseFromAuthorityExt.rosterIdToRoleOptions = null;
        rosterIdToRoleOptions = testManageResponseFromAuthorityExt.rosterIdToRoleOptions;

        Project_Profile__c projectProfileItem = testManageResponseFromAuthorityExt.projectProfileItem;
        testManageResponseFromAuthorityExt.projectProfileItem = null;
        projectProfileItem = testManageResponseFromAuthorityExt.projectProfileItem;
        
        Contact contactRecipient = testManageResponseFromAuthorityExt.contactRecipient;
        testManageResponseFromAuthorityExt.contactRecipient = null;
        contactRecipient = testManageResponseFromAuthorityExt.contactRecipient;

        String DDPName = testManageResponseFromAuthorityExt.DDPName;
        String emailTemplateName = testManageResponseFromAuthorityExt.emailTemplateName;
        String draftTemplateName = testManageResponseFromAuthorityExt.draftTemplateName;

        List<String> recordsForAttachmentsIds = testManageResponseFromAuthorityExt.recordsForAttachmentsIds;
        testManageResponseFromAuthorityExt.recordsForAttachmentsIds = null;
        recordsForAttachmentsIds = testManageResponseFromAuthorityExt.recordsForAttachmentsIds;

        String emailTypeRecord = testManageResponseFromAuthorityExt.emailTypeRecord;

        String emailsToDDP = testManageResponseFromAuthorityExt.emailsToDDP;
        testManageResponseFromAuthorityExt.emailsToDDP = '_failedEmailToCC';
        testManageResponseFromAuthorityExt.updateRecordCCField();

        testManageResponseFromAuthorityExt.manageResponseItemToSendEmailId = null;
        testManageResponseFromAuthorityExt.updateRecordToSendEmail();

        Manage_Response_From_Authority__c f = new Manage_Response_From_Authority__c( Received_Date_Time__c = Date.today(), Alert_Time__c = Date.today() + 1 );
        testManageResponseFromAuthorityExt.authorityResponseDataRows  = new List<Manage_Response_From_Authority__c> { f };
        testManageResponseFromAuthorityExt.updateDataRowsAction();


    }
    
    @isTest(seeAllData = false)private static void testManageResponseFromAuthorityExtention() {
        setUp(true);
        Test.setCurrentPageReference(Page.ManageResponseFromAuthority);
        testController = new ApexPages.StandardController(testTaskItemList[0]);

        Test.startTest();
            testManageResponseFromAuthorityExt = new ManageResponseFromAuthorityExtention(testController);
        Test.stopTest();

        System.assert(testManageResponseFromAuthorityExt != null);
    }
    
    @isTest(seeAllData = false)private static void testManageResponseItemToSendEmailId() {
        setUp(true);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            item.Is_Email_Sent__c = false;
        }
            update testmanaeResponceFromAuthorityList;
        getPageWithController();        

        Test.startTest();
            Id testManageId = testManageResponseFromAuthorityExt.manageResponseItemToSendEmailId;
            System.assert(testManageId != null);
        Test.stopTest();

    }
    
    @isTest(seeAllData = false)private static void testManageResponseItemToSendEmail() {
        setUp(true);
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            item.Is_Email_Sent__c = false;
        }
            update testmanaeResponceFromAuthorityList;
        getPageWithController();        

        Test.startTest();
            Manage_Response_From_Authority__c testManageResponse = testManageResponseFromAuthorityExt.manageResponseItemToSendEmail;
            System.assert(testManageResponse != null);
        Test.stopTest();

    }
    
    @isTest(seeAllData = false) private static void testUpdateDataRowsAction(){
        setUp(true);
        insertAdditionalData(true);
        getPageWithController();  
        
        
        Test.startTest();
            testManageResponseFromAuthorityExt.updateDataRowsAction();
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testAddNewDataRowAction(){
        setUp(true);
        insertAdditionalData(true);
        getPageWithController();  
        
        
        Test.startTest();
            testManageResponseFromAuthorityExt.addNewDataRowAction();
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );

    }
    
    @isTest(seeAllData = false) private static void testDeleteDataRowAction(){
        setUp(true);
        insertAdditionalData(true);
        getPageWithController();
        testManageResponseFromAuthorityExt.manageResponseItemId = String.valueOf(testmanaeResponceFromAuthorityList[0].Id);
                
        Test.startTest();
            testManageResponseFromAuthorityExt.deleteDataRowAction();
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testShowTemplateEditor(){
        setUp(true);
        insertAdditionalData(true);
        getPageWithController();  
        
        
        Test.startTest();
            Boolean testBoolean  = testManageResponseFromAuthorityExt.showTemplateEditor;
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testPreviewEmailForCurrentRecordActionFirstMessage(){
        setUp(true);          
        insertAdditionalData(true);
        getPageWithController();
        
        Test.startTest();
            testManageResponseFromAuthorityExt.previewEmailForCurrentRecordAction();
        Test.stopTest();

        System.assert( ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testPreviewEmailForCurrentRecordActionSecondMessage(){
        setUp(true);          
        insertAdditionalData(true);
        getPageWithController();
        
        Test.startTest();
            testManageResponseFromAuthorityExt.previewEmailForCurrentRecordAction();
        Test.stopTest();

        System.assert( ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testPreviewEmailForCurrentRecordActionThirdMessage(){
        setUp(true);          
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            item.Is_Email_Sent__c = false;
        }
            update testmanaeResponceFromAuthorityList;
        insertAdditionalData(true);
        getPageWithController();
        
        Test.startTest();
            testManageResponseFromAuthorityExt.previewEmailForCurrentRecordAction();
        Test.stopTest();

        System.assert( ApexPages.hasMessages() );
    }
    
    @isTest(seeAllData = false) private static void testUpdateRecordToSendEmail(){
        setUp(true);          
        for(Manage_Response_From_Authority__c item : testmanaeResponceFromAuthorityList){
            item.Sent_VIA__c = ManageResponseFromAuthorityServices.SENT_VIA_EMAIL;
            item.Is_Email_Sent__c = false;
        }
            update testmanaeResponceFromAuthorityList;
        insertAdditionalData(true);
        getPageWithController();
       
        Test.startTest();
            testManageResponseFromAuthorityExt.updateRecordToSendEmail();
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
}