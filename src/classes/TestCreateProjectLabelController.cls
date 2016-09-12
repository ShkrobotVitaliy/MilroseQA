@isTest
private class TestCreateProjectLabelController {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ApexPages.StandardController controller;
    private static CreateProjectLabelController testCreateProjectLabelCont;
    private static User projectManagerUser;
    private static List<Project_Profile__c> testProjectProfileList; 
    private static List<Account> testAccountList;
    private static List<Contact> testContactList;
    private static List<Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOption;
    private static List<Loop__DDP__c> testLoopDDP;
    private static void setUp(Boolean doInsert){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true);
        testContactList = TestingUtils.createContactList(1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccountList[0].Id, testContactList[0].Id,
                                                                        testAccountList[0].Id, testContactList[0].Id, testAccountList[0].Id,
                                                                        testContactList[0].Id, projectManagerUser.Id, true);
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, true);                                                                        
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE, testLoopDDP[0].Id, doInsert);                                                                      
    }
    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.CreateProjectLabel);
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        testCreateProjectLabelCont = new CreateProjectLabelController(controller);      
    }
    
    @isTest(seeAllData = false) private static void testCreateProjectLabelController(){
        setUp(false);
        Test.setCurrentPageReference(Page.CreateProjectLabel);
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        
        Test.startTest();
            testCreateProjectLabelCont = new CreateProjectLabelController(controller);
        Test.stopTest();
        
        System.assertEquals(testProjectProfileList[0].Id, testCreateProjectLabelCont.project.Id);
    }
    
    @isTest(seeAllData = false) private static void testRunDDPdeliveryMethodIsNotEmpty(){
        setUp(false);
        testLoopDDPIntegrationOption[0].Name = 'Attach';
            insert testLoopDDPIntegrationOption;
        testLoopDDP[0].Name = 'Create Project Label';
            update testLoopDDP;
        getPageWithController();    
        
        Test.startTest();
            PageReference testPageUrl = testCreateProjectLabelCont.autorun();
        Test.stopTest();
        
        List<Loop__DDP_Integration_Option__c> deliveryMethod  = [SELECT Id
                                                                 FROM Loop__DDP_Integration_Option__c
                                                                 WHERE Loop__DDP__r.Name = 'Create Project Label'
                                                                 AND Name = : 'Attach'];        
        
        System.assert(String.valueOf(testPageUrl).contains(String.valueOf(testProjectProfileList[0].Id)));
        System.assert(String.valueOf(testPageUrl).contains(String.valueOf(true)));
        System.assert(String.valueOf(testPageUrl).contains(String.valueOf(deliveryMethod[0].Id)));
    
    }
}