@isTest
private class TestManageOutboundEmailController {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ApexPages.StandardController controller;
    private static ManageOutboundEmailController manageOutBoundContr;
    private static User projectManagerUser;
    private static User testUser;
    private static Account testAccount;
    private static Contact testContact;
    private static Building__c testBuilding;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List <Project_Profile__c> testProjectProfileList;
    private static List <RFI_Scope__c> testRFIScopeList;
    private static List <Project_Roster__c> testProjectRosterList;
    private static List <Project_Roster__c> testProjectRosterListAfterInsert;
    private static List <Region__c> testRegionList;
    private static RecordType testRec;
    private static RecordType testRFIRecordType;
    
    private static void setUp(){
        testRec = [SELECT DeveloperName ,SObjectType FROM RecordType WHERE SObjectType = 'Project_Roster__c' AND DeveloperName  = 'Contact' limit 1];
        testRFIRecordType = [SELECT SObjectType,Name FROM RecordType WHERE SObjectType = 'RFI_Scope__c' AND Name = 'Standard RFI Scope' limit 1];       
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testUser = TestingUtils.createUsers(1, true)[0];
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
            testContact.AccountId = testAccount.Id;
            testContact.Email = 'testEmail@test.com';
            testContact.FirstName = 'First';
            testContact.LastName = 'Second'; 
            insert testContact;

        testRegionList = TestingUtils.createRegionList(1, 'test region name', false);
        testRegionList[0].Name = RegionServices.REGION_NAME_NY;
        insert testRegionList;
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(1, null, testRegionList[0].Id, true);
        testBuilding = TestingUtils.createBuildingList(1, testMunucipalitiesList[0].Id, 'TestStreet', 'TestHouse', 'TestCity', 'TestZip', true)[0];  

        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, false);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Building__c = testBuilding.Id;
        }
        insert testProjectProfileList;

        testProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE,false);
        for(Project_Roster__c item : testProjectRosterList){
            item.Contact__c = testContact.Id;
            item.User__c = testUser.Id;
            item.RecordTypeId = testRec.Id;
            item.Project_Profile__c = testProjectProfileList[0].Id;
        }                              
            insert testProjectRosterList;
        testProjectRosterListAfterInsert = [Select Id, Name__c, Contact__c, User__c From Project_Roster__c Where Id IN: testProjectRosterList ];                            
        testRFIScopeList = TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE, testRegionList[0].Id, false);
        for(RFI_Scope__c item : testRFIScopeList){
            item.Project__c = testProjectProfileList[0].Id;
            item.Project_Roster__c = testProjectRosterList[0].Id;
            item.RecordTypeId = testRFIRecordType.Id;
            item.Submit_Sign_Off__c = true;
            item.Submit_Application__c = true;
            item.Status__c = 'Received';
        }
            insert testRFIScopeList;
    }

    private static void getPageWithController(String typeValue){
        Test.setCurrentPageReference(Page.ManageOutboundEmail);
        ApexPages.currentPage().getParameters().put('projectId',testProjectProfileList[0].Id);
        ApexPages.currentPage().getParameters().put('type', typeValue); 
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        manageOutBoundContr = new ManageOutboundEmailController(controller);
    }

    private static testMethod void testManageOutboundEmailController(){
        setUp();
        Test.setCurrentPageReference(Page.ManageOutboundEmail);
        ApexPages.currentPage().getParameters().put('projectId',testProjectProfileList[0].Id);
        ApexPages.currentPage().getParameters().put('submitType',RFIScopeServices.APPLICATION_TYPE);  
        controller = new ApexPages.StandardController(testProjectProfileList[0]);
        
        Test.startTest();
            manageOutBoundContr = new ManageOutboundEmailController(controller);
        Test.stopTest();
        
        System.assertEquals(false, manageOutBoundContr.reviewEmail);
        //System.assertEquals(false, manageOutBoundContr.showAttachment);
        //System.assert(manageOutBoundContr.documents != null);
        
    }

    @isTest static void testUncoveredParts() {
        setUp();
        String emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_NJ;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_PHILADELPHIA ;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_DE;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_LI;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;
    
        testRegionList[0].Name = RegionServices.REGION_NAME_WESTCHESTER;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_NJ;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_PHILADELPHIA;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_DE;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

        testRegionList[0].Name = RegionServices.REGION_NAME_LI;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;
    
        testRegionList[0].Name = RegionServices.REGION_NAME_WESTCHESTER;
        UPSERT testRegionList;
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        emailTemplateName  = manageOutBoundContr.emailTemplateName;

    }

    private static testMethod void testEmailTemplateNameSingOffType(){
        setUp();
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        String testString;
        Monitor_RFI_Scope__c monitorRFI = new Monitor_RFI_Scope__c();
        Test.startTest();
            testString = manageOutBoundContr.emailTemplateName;
            manageOutBoundContr.fillCCEmailAddress( monitorRFI, 'test1@test.com;test1@test.com;test1@test.com;test1@test.com;test1@test.com');
            Map<Id, Project_Roster__c> getRosterIdToRoster = manageOutBoundContr.getRosterIdToRoster();
        Test.stopTest();
        
        System.assert(!String.isEmpty(testString));
    }

    private static testMethod void testEmailTemplateNamApplicationType(){
        setUp();
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);
        String testString;

        Test.startTest();
            testString = manageOutBoundContr.emailTemplateName;
        Test.stopTest();

        System.assert(!String.isEmpty(testString));
    }
    //for test coverage only
    private static testMethod void testSite(){
        setUp();
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);

        List<Site_URL__c> siteUrlList = new List<Site_URL__c>();
        siteUrlList.add(new Site_URL__c(Name = 'Full Sandbox', URL__c = 'http://poc-free-12415f14c3a-124e539428a-12882cef16f.cs10.force.com/'));
        siteUrlList.add(new Site_URL__c(Name = 'LCH Sandbox', URL__c = 'http://lch-free-12415f14c3a-124e539428a-12882cef16f.cs9.force.com/'));
        siteUrlList.add(new Site_URL__c(Name = 'Production Sandbox', URL__c = 'http://free-12415f14c3a-124e539428a-12882cef16f/'));
        insert siteUrlList;

        Site_URL__c resultSiteUrl;

        Test.startTest();

            resultSiteUrl = manageOutBoundContr.site;

        Test.stopTest();

        System.assert(resultSiteUrl == null);
    }

    private static testMethod void testEmailTemplateNamIncorrectType(){
        setUp();
        getPageWithController('IncorrectType');
        String testString;
        Test.startTest();
            testString = manageOutBoundContr.emailTemplateName;
        Test.stopTest();
        
        System.assert(String.isEmpty(testString));
    }

    private static testMethod void testContactEmail(){
        setUp();
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);

        Project_Roster__c rpRosterItem = [SELECT Id, Name__c FROM Project_Roster__c WHERE Id = : testProjectRosterList[0].id][0];
        manageOutBoundContr.sendToName = rpRosterItem.Name__c;
        manageOutBoundContr.sendToId = rpRosterItem.Id;

        Test.startTest();
            String testString = manageOutBoundContr.contactEmail;
            System.assert( manageOutBoundContr.emailTemplateName != null );
        Test.stopTest();
        
        System.assertEquals('testemail@test.com', testString);
    }
    
    
    private static testMethod void testLoggedUserName(){
        setUp();
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        
        Test.startTest();
            Project_Roster__c rpRosterItem = [SELECT Id, Name__c FROM Project_Roster__c WHERE Id = : testProjectRosterList[0].id][0];
            manageOutBoundContr.sendToName = rpRosterItem.Name__c;
            manageOutBoundContr.sendToId = rpRosterItem.Id;
            String testString = manageOutBoundContr.contactEmail;
            String testUserName = manageOutBoundContr.loggedUserName;

            System.assert(! String.isBlank(testString) );
            System.assert(! String.isBlank(testUserName) );

        Test.stopTest();

//        System.assertEquals('Milrose Wave', testUserName);
    }
    
    private static testMethod void testClearEmailAddress(){
        setUp();
        testProjectProfileList[0].EmailToRfi__c = 'test';
        testProjectProfileList[0].EmailToCCRfi__c = 'test';
            update testProjectProfileList;
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
                    
        Test.startTest();   
            manageOutBoundContr.clearEmailAddress();
        Test.stopTest();
        
        testProjectProfileList = [SELECT EmailToRfi__c,EmailToCCRfi__c FROM Project_Profile__c];
        System.assertEquals(null, testProjectProfileList[0].EmailToRfi__c);
        System.assertEquals(null, testProjectProfileList[0].EmailToCCRfi__c);
    }
    
    
    private static testMethod void testForCoverage(){
        setUp();
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        
        Test.startTest();
            System.assert( manageOutBoundContr.emailTemplateName != null );
            System.assert( manageOutBoundContr.draftTemplateName != null );
            System.assert( manageOutBoundContr.drawloopName != null );
            System.assert( manageOutBoundContr.site == null );
            Project_Roster__c rpRosterItem = [SELECT Id, Name__c FROM Project_Roster__c WHERE Id = : testProjectRosterList[0].id][0];
            manageOutBoundContr.sendToName = rpRosterItem.Name__c;
            manageOutBoundContr.sendToId = rpRosterItem.Id;
            
            System.assert( manageOutBoundContr.linkToSite != null );
            System.assert( manageOutBoundContr.serviceItemIds != null );
            System.assert( manageOutBoundContr.taskItemIds != null );
            System.assert( manageOutBoundContr.rfiEmailType != null );
            manageOutBoundContr.backToProject();
            manageOutBoundContr.showReviewEmail(); 
            System.assert( manageOutBoundContr.reminderDatetime == null );
            manageOutBoundContr.onCompleteReview();
            manageOutBoundContr.updateCCEmailsAddressForDrawLoop ();
            manageOutBoundContr.updateAfterSend();
            
                        
            System.assert( manageOutBoundContr.parentDocumentIds != null );
        Test.stopTest();
        
        
    }

    private static testMethod void testForCoverage1(){
        setUp();
        getPageWithController(RFIScopeServices.SIGN_OFF_TYPE);
        
        Test.startTest();            
            manageOutBoundContr.emailsAddressForDrawLoop = 'test@test1.com;test@test2.com;test@test3.com;test@test4.com;test@test1.com;';
            Project_Roster__c rpRosterItem = [SELECT Id, Name__c FROM Project_Roster__c WHERE Id = : testProjectRosterList[0].id][0];
            manageOutBoundContr.sendToName = rpRosterItem.Name__c;
            manageOutBoundContr.sendToId = rpRosterItem.Id;
            manageOutBoundContr.showReviewEmail();
            //manageOutBoundContr.createTrackingRFIScope();
            //String test1 = manageOutBoundContr.keyMonitor;
            //System.assert( manageOutBoundContr.parentDocumentIds != null );
        Test.stopTest();
    }

    private static testMethod void testForCoverage2(){
        setUp();
        getPageWithController(RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            manageOutBoundContr.emailsAddressForDrawLoop = 'test@test1.com;test@test2.com;test@test3.com;test@test4.com;';
            Project_Roster__c rpRosterItem = [SELECT Id, Name__c FROM Project_Roster__c WHERE Id = : testProjectRosterList[0].id][0];
            manageOutBoundContr.sendToName = rpRosterItem.Name__c;
            manageOutBoundContr.sendToId = rpRosterItem.Id;

            System.assert(manageOutBoundContr.sendToId != null);

            manageOutBoundContr.showReviewEmail();
            //manageOutBoundContr.createTrackingRFIScope();

        Test.stopTest();
    }
}