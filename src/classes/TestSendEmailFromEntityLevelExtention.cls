@isTest
private class TestSendEmailFromEntityLevelExtention {
    private static final Integer NUMBER_TO_CREATE = 5 ;
    private static Project_Profile__c testProjectProfile;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId; 
    private static Account testAccount;
    private static Contact testContact;
    private static List<Proposal__c> testProposalList;
    private static Proposal__c testProposal;
    private static List<Building__c> testBuildingList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static Region__c testRegion;
    private static sendEmailFromEntityLevelExtention sendEmailController;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Service_Item__c> testServiceItemList;

    private static void setUp(){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true)[0];
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];                                                                           
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);       
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false);
        for(Service_Item__c item : testServiceItemList){
            item.Project_Profile__c = testProjectProfile.Id;
            item.Proposal__c = testProposalList[0].Id;
        }                                                   
            insert testServiceItemList;       
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, null, testProjectProfile.Id, true);
                                                                    
    }

    private static void getPage(){
        Test.setCurrentPageReference(Page.SendEmailFromEntityLevel);
    }
    
    private static void initializeController(){
        sendEmailController = new sendEmailFromEntityLevelExtention();
    }
    
    private static testMethod void testGettersAndSetters(){
        setUp();
        getPage();      
        ApexPages.currentPage().getParameters().put('Id',testProjectProfile.Id);    
        initializeController();
        
        Test.startTest();
            Project_Profile__c projectProfileItem = sendEmailController.project;
            Boolean showSendEmailComponent = sendEmailController.showSendEmailComponent;
            String emailTypeRecord = sendEmailController.emailTypeRecord;
            String DDPName = sendEmailController.DDPName;
            String draftTemplateName = sendEmailController.draftTemplateName;
            String emailTemplateName = sendEmailController.emailTemplateName;
            List<String> recordsForAttachmentsIds = sendEmailController.recordsForAttachmentsIds;
            User user = TestingUtils.userWithProfile( UserServices.PROFILE_CODE_ZONING_ANALYST );
            System.runAs( user ) {
                sendEmailController.clearEmailAddress();
                sendEmailController.showSendEmailComponent = false;
                sendEmailController.clearEmailAddress();
            }
        Test.stopTest();
        
    }
    
    private static testMethod void testEmptyMethodsForCoverage(){
        setUp();
        getPage();      
        ApexPages.currentPage().getParameters().put('Id',testServiceItemList[0].Id);    
        initializeController();
        
        Test.startTest();
            sendEmailController.clearEmailAddress();
        Test.stopTest();
        
    }
    
    private static testMethod void testUpdateRecordTOField(){
        setUp();
        getPage();      
        ApexPages.currentPage().getParameters().put('Id',testTaskItemList[0].Id);   
        initializeController();     
        sendEmailController.emailsToDDP = 'TestString';
        
        Test.startTest();
            sendEmailController.updateRecordTOField();
        Test.stopTest();
        
    }
    
    private static testMethod void testUpdateRecordCCField(){
        setUp();
        getPage();      
        ApexPages.currentPage().getParameters().put('Id',testProjectProfile.Id);    
        initializeController();
        sendEmailController.emailsCCDDP = 'TestString';
        
        Test.startTest();
            sendEmailController.updateRecordCCField();
        Test.stopTest();
        
    }
    
    private static testMethod void testCancelAction(){
        setUp();
        getPage();      
        ApexPages.currentPage().getParameters().put('Id',testProjectProfile.Id);    
        initializeController();
        
        Test.startTest();
            PageReference cancelAction = sendEmailController.cancelAction();
            Boolean showSendEmailComponent = sendEmailController.showSendEmailComponent;
            
            try {
                sendEmailController.setObjectIds(null);
            
            } catch(Exception ex) {}
            
            sendEmailController.clearEmailAddress();
            
            PageReference pr = sendEmailController.doFinalActions();
        Test.stopTest();
        
    }
    
    
}