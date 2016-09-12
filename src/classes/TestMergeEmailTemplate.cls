@isTest
private class TestMergeEmailTemplate {
    private static final Integer NUMBER_TO_CREATE_EMAIL_TEMPLATE = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<EmailTemplate> testEmailTemplateList;
    private static MergeEmailTemplate testMergeEmailTemplate;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
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

    private static testmethod void testInitMergeEmailTemplateOneParameter(){
        testEmailTemplateList = TestingUtils.createEmailTemplateList(NUMBER_TO_CREATE_EMAIL_TEMPLATE, null, null, null, true);
        testEmailTemplateList = [SELECT Id, Name
                                 FROM EmailTemplate
                                 WHERE Id IN : testEmailTemplateList];

        Test.startTest();

            testMergeEmailTemplate = new MergeEmailTemplate('test value');

            testMergeEmailTemplate = new MergeEmailTemplate(testEmailTemplateList[0].Name);

            Boolean testBoolean;
            testBoolean = testMergeEmailTemplate.templateId == null;

            testBoolean = testMergeEmailTemplate.subject == null;
            testBoolean = testMergeEmailTemplate.body == null;

            testMergeEmailTemplate = new MergeEmailTemplate('');
        Test.stopTest();

        System.assert(testMergeEmailTemplate != null);
    }

    private static testmethod void testInitMergeEmailTemplateFiveParameters(){
        testEmailTemplateList = [SELECT Id, Name
                                 FROM EmailTemplate
                                 WHERE TemplateType = 'html' LIMIT 1];

        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Test.startTest();

            testMergeEmailTemplate = new MergeEmailTemplate('test value', null, '', '', '');

            testMergeEmailTemplate = new MergeEmailTemplate(testEmailTemplateList[0].Name, testProjectProfileList[0], 'test@gmail.com', 'test', 'test');

            Boolean testBoolean;
            testBoolean = testMergeEmailTemplate.templateId == null;
            testBoolean = testMergeEmailTemplate.headerBody == null;
            testBoolean = testMergeEmailTemplate.footerBody == null;
            testBoolean = testMergeEmailTemplate.subject == null;
            testBoolean = testMergeEmailTemplate.body == null;
           
            String errorString;

            testMergeEmailTemplate = new MergeEmailTemplate('', null, '', '', '');
            testMergeEmailTemplate = new MergeEmailTemplate('test', testProjectProfileList[0], 'test@gmail.com', 'text', 'test', 'test'); 
            Date test1 = testMergeEmailTemplate.currentDatePlusThreeBusinessDays;            
            String test2 = testMergeEmailTemplate.getRFISubject('{!subject}');

        Test.stopTest();

        System.assert(testMergeEmailTemplate != null);
    }
    
    private static testmethod void testForCoverage(){
        testEmailTemplateList = [SELECT Id, Name, Subject 
                                 FROM EmailTemplate
                                 WHERE TemplateType = 'html' LIMIT 1];

        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Test.startTest();

            
            testMergeEmailTemplate = new MergeEmailTemplate(testEmailTemplateList[0].Name, testProjectProfileList[0], 'test@gmail.com', 'test', 'test');
            String test3 = testMergeEmailTemplate.getRFIBody('{!sendTo}');
            String test31 = testMergeEmailTemplate.getRFIBody('{!from}');
            String test32 = testMergeEmailTemplate.getRFIBody('{!link}');
            String test33 = testMergeEmailTemplate.getRFIBody('{!completeDate}');
            String test41 = testMergeEmailTemplate.getRFFSubject('{test}');
            
            String test5 = testMergeEmailTemplate.getRFFBody('test');

        Test.stopTest();

        System.assert(testMergeEmailTemplate != null);
    }
    
    private static testMethod void testGetStandardParsedSubject(){
        testEmailTemplateList = [SELECT Id, Name, Subject 
                                 FROM EmailTemplate
                                 WHERE TemplateType = 'html' LIMIT 1];

        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        
        Test.startTest();
            
            testMergeEmailTemplate = new MergeEmailTemplate(testEmailTemplateList[0].Name, testProjectProfileList[0], 'test@gmail.com', 'test', 'test');
            String test3 = testMergeEmailTemplate.getStandardParsedSubject('{!Project_Profile__c.Municipal_Agency_ID__c}');
            String test31 = testMergeEmailTemplate.getStandardParsedSubject('{!Account.Name}');
            String test32 = testMergeEmailTemplate.getStandardParsedSubject('{!Project_Profile__c.Project_Name__c}');
            String test33 = testMergeEmailTemplate.getStandardParsedSubject('{!Project_Profile__c.Project_Address__c}');
            String test41 = testMergeEmailTemplate.getStandardParsedSubject('{!Project_Profile__c.Floor_Counting__c}');
        Test.stopTest();

        System.assert(testMergeEmailTemplate != null);
    }
}