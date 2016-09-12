@isTest
private class TestRequestFilingFeeExtension {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static ApexPages.StandardController controller;
    private static RequestFilingFeeExtension testRequestExtension;
    private static User partnerUser;    
    private static User projectManagerUser;
    private static User adminUser;
    private static User productionManager;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Project_Profile__c> testProjectProfileList; 
    private static List<EmailTemplate> testEmailtemplateList;
    private static List<Check__c> testCheckRequested;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<RFI_Work__c> testRfiWorkList;
    private static List <Service_Item__c> testServiceItemList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Floor__c> testFloorList;
    private static List<Project_Team__c> testProjectTeam;
    private static List<Contact> testContactWithAccountList;
    private static List<Account> testAccountList;
    private static List<Task_Item__c> testTaskItemList;

    private static Id projectRosterUserRecordTypeId;
    private static Id projectRosterContactRecordTypeId;
    private static List<String> projectRosterRoleValuesList;
    private static Id currentUserId;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private final static String TEST_PROJECT_ROSTER_ROLE = 'test Project Roster Role';
    
    private static void setUp(Boolean doInsert){
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        adminUser = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);
        productionManager = TestingUtils.userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, false)[0];
        testAccount.Name = 'American Express';
        insert testAccount;
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, false)[0];
        testContact.Email = 'test@test.com';
        insert testContact;
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'Test region', true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);  
        testFloorList = TestingUtils.createFloorList(NUMBER_TO_CREATE, true);
        testProjectTeam = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE, productionManager.Id, projectManagerUser.Id, false);
        for(Project_Team__c item : testProjectTeam){
            item.Email_Distribution__c = 'TestDistrib@testmail.com';
        }   
            insert testProjectTeam;

        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, doInsert);
                                                                              
       // testEmailtemplateList = TestingUtils.createEmailTemplateList(NUMBER_TO_CREATE, null, null, null, true);
       /* for(EmailTemplate item : testEmailtemplateList){
            item.Subject = '{CustomName}';
        }
            insert testEmailtemplateList;*/

        
        testCheckRequested = TestingUtils.createCheckList(NUMBER_TO_CREATE, testAccount.Id, true);      
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true);
        testRfiWorkList = TestingUtils.createRFIWorkList(NUMBER_TO_CREATE, false);
        for(RFI_Work__c item : testRfiWorkList){
            item.Application_Service_Item__c = testServiceItemList[0].Id;
        }
            insert testRfiWorkList;
          
                                                                                  
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
    
    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.RequestFilingFeesSummarySection);
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        testRequestExtension = new RequestFilingFeeExtension(controller);
        
    }
    
    private static testmethod void testRequestFilingFeeExt(){
        setUp(true);
        Test.setCurrentPageReference(Page.RequestFilingFeesSummarySection);
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        
        Test.startTest();
            testRequestExtension = new RequestFilingFeeExtension(controller);
        Test.stopTest();
        
            
    }
    
    private static testmethod void testLoggedUserName(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            String userName = testRequestExtension.loggedUserName;
        Test.stopTest();
    }
    
    private static testmethod void testOptions(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            List<SelectOption> options = testRequestExtension.options;
        Test.stopTest();
    }
    
    private static testmethod void testSendChecks(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            List<CheckRequestWrapper> sendChecks = testRequestExtension.sendChecks;
        Test.stopTest();
    }
    
    private static testmethod void testTrackSendChecks(){
        setUp(true);
        getPageWithController();
//        
        Test.startTest();
            List<Check__c> trackSendChecks = testRequestExtension.trackSendChecks;
        Test.stopTest();
    }
    
    private static testmethod void testSendInternalRequestErrorCheck(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            testRequestExtension.sendInternalRequest();
        Test.stopTest();
    }
    
    private static testmethod void testSendInternalRequestInternalStandartRequest(){
        setUp(false);
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
            item.Project_Team__c = testProjectTeam[0].Id;
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name,Email_Distribution__c FROM Project_Profile__c];
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        testRequestExtension.selectedInternalRequest = CheckServices.INTERNAL_STANDARD_REQUEST;
        
        Test.startTest();
            testRequestExtension.sendInternalRequest();
        Test.stopTest();
    }
    
    private static testmethod void testSendInternalRequestInternalStandartRequest1(){
        setUp(false);
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
            item.Project_Team__c = testProjectTeam[0].Id;
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name,Email_Distribution__c FROM Project_Profile__c];
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        testRequestExtension.selectedInternalRequest = CheckServices.INTERNAL_CHARGED_TO_CORPORATE_CARD;
        
        Test.startTest();
            testRequestExtension.sendInternalRequest();
        Test.stopTest();
    }
    
    private static testmethod void testSendInternalRequestInternalRushRequest(){
        setUp(false);
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
            item.Project_Team__c = testProjectTeam[0].Id;
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name,Email_Distribution__c FROM Project_Profile__c];
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        testRequestExtension.selectedInternalRequest = CheckServices.INTERNAL_RUSH_REQUEST;
        
        Test.startTest();
            testRequestExtension.sendInternalRequest();
        Test.stopTest();
    }
    
    
    
    private static testmethod void testUpdateSendCheckRequests(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            testRequestExtension.updateSendCheckRequests();
        Test.stopTest();
        
    }
    
    private static testmethod void testUpdateTrackSendCheckRequests(){
        setUp(true);
        getPageWithController();
        
        Test.startTest();
            testRequestExtension.updateTrackSendCheckRequests();
        Test.stopTest();
    }
    
    private static testmethod void testDisplayEmailPreview(){
        setUp(false);
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        testProjectProfileList = [SELECT Id,Name,Project_Name__c, Proposal__c, Floor_s__c,Building__r.Name FROM Project_Profile__c];
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        
        testRequestExtension.bodyMail = 'test<table>test</table>';
        
        Test.startTest();
            testRequestExtension.updateSendCheckRequests();
            testRequestExtension.updateTrackSendCheckRequests();
        Test.stopTest();
    }
    
    private static testmethod void testDisplayEmailPreviewFirstError(){
        setUp(false);
        Proposal__c testProposal = TestingUtils.createProposalListForTest(1,true)[0];
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProjectProfileList[i].Proposal__c = testProposal.Id;
        }
        update testProjectProfileList;

        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name FROM Project_Profile__c];      
        getPageWithController();    
        
        
        Test.startTest();
            testRequestExtension.displayEmailPreview();
        Test.stopTest();
    }
    
    private static testmethod void testDisplayEmailPreviewSecondError(){
        setUp(false);
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name FROM Project_Profile__c];
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Check_Amount__c = 1;
        }
            testCheckRequested[0].Project_Roster__c = null;
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        
        Test.startTest();
            String testtextContext = testRequestExtension.textContext;
            String testtableHeader = testRequestExtension.tableHeader;
            testRequestExtension.updateTrackSendCheckRequests();
        Test.stopTest();
    }
    
    private static testmethod void testDisplayEmailPreviewThirdError(){
        setUp(false);

        Proposal__c testProposal = TestingUtils.createProposalListForTest(1,true)[0];
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
        }
            insert testProjectProfileList;
        insertAdditionalData(true);

        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name FROM Project_Profile__c];

        for (Integer i = 0; i < testProjectProfileList.size(); i++){
            testProjectProfileList[i].Proposal__c = testProposal.Id;
        }
        update testProjectProfileList;

        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            testCheckRequested[0].Project_Roster__c = testProjectRosterList[1].Id;
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        
        Test.startTest();
            testRequestExtension.displayEmailPreview();
        Test.stopTest();
    }
    
    private static testmethod void testForCoverage1(){
        setUp(false);
        
        for(Project_Profile__c item : testProjectProfileList){
            item.Project_Name__c = 'TestCustname';
            item.Building__c = testBuildingList[0].Id;
            item.Floor_s__c = 'TestFloor';
        }
            insert testProjectProfileList;
        insertAdditionalData(true);
        
        testProjectProfileList = [SELECT Id,Name,Project_Name__c,Floor_s__c,Building__r.Name FROM Project_Profile__c];
        
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }
        
        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        Decimal amountRemaining  = testRequestExtension.amountRemaining;
        
        Test.startTest();
            List<Project_Roster__c> testRosterList = testRequestExtension.rosters;
            String tes1 = testRequestExtension.drawloopName;
            String test2 = testRequestExtension.emailTemplateName;
            String test3 = testRequestExtension.draftTemplateName;
            String test4 = testRequestExtension.rffEmailType;
            List<SelectOption> test5 = testRequestExtension.rostersSendTo;

            testRequestExtension.updateAfterSend();
        Test.stopTest();
    }
    
    private static testmethod void testForCoverage(){
        Proposal__c testProposal = TestingUtils.createProposalListForTest(1,true)[0];

        setUp(true);
        getPageWithController();

        for (Integer i = 0; i < NUMBER_TO_CREATE; i++){
            testProjectProfileList[i].Proposal__c = testProposal.Id;
        }
        update testProjectProfileList;

        testProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false);
            for(Project_Roster__c item : testProjectRosterList){
                item.Project_Profile__c = testProjectProfileList[0].Id;
                item.Contact__c = testContact.Id;


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

    
            Integer i = 0;
        for(Check__c item : testCheckRequested){
            item.Project_Roster__c = testProjectRosterList[i].Id;
            item.Service_Item__c = testServiceItemList[0].Id;
            item.Include_Estimated_Cost_Detail__c = true;
            item.Task_Item__c = testTaskItemList[0].Id;
            item.Date_Requested__c = Datetime.now();
            item.Check_Number__c = 1;
            item.Internal__c = true;
            item.Check_Amount__c = 100;
            i++;
        }
            update testCheckRequested;
        getPageWithController();
        for(Check__c item : testCheckRequested){
            testRequestExtension.sendChecks.add(new CheckRequestWrapper(item));
        }

        for (CheckRequestWrapper item : testRequestExtension.sendChecks){
            item.isSelected = true;
        }
        testRequestExtension.selectedInternalRequest = CheckServices.INTERNAL_STANDARD_REQUEST;
        List<Reimbursable_Expense_Invoice__c> testcreateReimbursableExpenseInvoiceList = TestingUtils.createReimbursableExpenseInvoiceList(5, false);
        Integer ki=0;
        for(Reimbursable_Expense_Invoice__c rei : testcreateReimbursableExpenseInvoiceList){
            testcreateReimbursableExpenseInvoiceList[ki].Check_Request__c = testCheckRequested[ki].Id;
            testcreateReimbursableExpenseInvoiceList[ki].FFA_PIN_Created__c = true;
            ki++;
        }
        
        insert testcreateReimbursableExpenseInvoiceList;
        List<CheckRequestWrapper> testsendChecks = testRequestExtension.sendChecks;
        System.debug('!!!!!! testsendChecks.Size() = '+ testsendChecks.Size());

        testRequestExtension.isCheckProcessingFeeOptionNeeded = true;
        List<Check__c> testcheckTrackRequested = testRequestExtension.checkTrackRequested;
        

        
        Test.startTest();
            testRequestExtension.checkRequestId = testCheckRequested[0].Id;
            testRequestExtension.selectInternalRequest();
            testRequestExtension.trackSendChecks = testCheckRequested;
            List<Check__c> testtrackSendChecks = testRequestExtension.trackSendChecks;
            
            Boolean testgetIsCheckProcessingFeeOptionAvailable = testRequestExtension.getIsCheckProcessingFeeOptionAvailable();
            Contact tectContact = testRequestExtension.contactRecipient;
            String testemailTo = testRequestExtension.emailTo;
            String testsendCC = testRequestExtension.sendCC;

            String testadditionalSubject = testRequestExtension.additionalSubject;
            String testbodyMail = testRequestExtension.bodyMail;
            String testtextContext = testRequestExtension.textContext;
            String testtableHeader = testRequestExtension.tableHeader;
            
            testRequestExtension.subject = 'Test subject';
            testRequestExtension.editedTemplate =  'Test editedTemplate';
            testRequestExtension.reminderDatetime = Datetime.now() + 1;

            testRequestExtension.updateSendCheckRequests();
            testRequestExtension.updateTrackSendCheckRequests();
            testRequestExtension.updateCCEmailsAddressForDrawLoop();
            List<Id> testparentDocumentIds = testRequestExtension.parentDocumentIds;
            testRequestExtension.updateAfterSend();
            testRequestExtension.displayEmailPreview();
        Test.stopTest();
    }
        
}