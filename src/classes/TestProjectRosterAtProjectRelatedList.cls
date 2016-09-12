@isTest
private class TestProjectRosterAtProjectRelatedList {
    private static ApexPages.Standardcontroller sc;
    private static ProjectRosterAtProjectRelatedListContExt projectRosterContEx;
    private static final Integer NUMBER_TO_CREATE = 5;
    private static Integer TEST_INTEGER= 1;
    private static Integer ANOTHER_TEST_INTEGER= 5;
    private static User projectManagerUser;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProject;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Project_Roster__c> secondProjectRosterList;
    private static String testSortExp = 'Name__c';
    private static List<Contact> testContactList;
    private static ProjectRosterObject__c testProjectRosterObject;

    public static void setUp(){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, false);
            for(Contact item : testContactList){
                item.LastName = 'Name' + TEST_INTEGER++;
            }
            insert testContactList;
        testContact = testContactList[0];
        testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE,
                                                           testAccount.Id,
                                                           testContact.Id,
                                                           testAccount.Id,
                                                           testContact.Id,
                                                           testAccount.Id,
                                                           testContact.Id,
                                                           projectManagerUser.Id,
                                                           false)[0];
        testProject.Project_Name__c = 'TestName';
            insert testProject;                                               

        testProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false);
            for(Project_Roster__c item : testProjectRosterList){
                item.Project_Profile__c = testProject.Id;
                item.Contact__c = testContact.Id;
                item.Is_Read__c = false;
            }
            testProjectRosterList.get(NUMBER_TO_CREATE-1).Active__c = false;
            insert testProjectRosterList;

            testProjectRosterList[1].Contact__c = testContactList[1].Id;
            update testProjectRosterList;

        testProjectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c,
                                    Name__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, Contact__r.Name, User__r.Name, Send_Reminder__c
                                 From Project_Roster__c
                                 Where Project_Profile__c = : testProject.Id];
                                 System.debug(LoggingLevel.error,'@@@testProjectRosterList'+ testProjectRosterList);

        secondProjectRosterList = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false);
            for(Project_Roster__c item : secondProjectRosterList){
                item.Contact__c = testContact.Id;
                item.Is_Read__c = false;
            }
            insert secondProjectRosterList;


        Integer num = 1;    
        testProjectRosterObject = TestingUtils.createProjectRosterObjectList(1, false)[0];        
            testProjectRosterObject.Name = 'Project_Roster_Recort_Type_Ent_Prefix';
            testProjectRosterObject.Project_Roster_Object_Id__c = 'Test';
            testProjectRosterObject.ProjectRoster_Field_Id__c = 'Test';
            insert testProjectRosterObject;
    }

    @isTest( seeAllData = false ) private static void testUncoveredPart() {
        setUp();
        Test.startTest();

            Test.setCurrentPageReference(Page.ProjectRosterAtProjectRelatedListPage);                    
            sc = new ApexPages.Standardcontroller(testProject);
            ProjectRosterAtProjectRelatedListContExt pRCE = new ProjectRosterAtProjectRelatedListContExt(sc);
            
            String primaryClientContact = pRCE.primaryClientContact;
            String billingClientContact = pRCE.billingClientContact;
            Boolean isPlatformSystemAdmin = pRCE.isPlatformSystemAdmin;

            pRCE.rosterIdToDelete = [SELECT Id FROM Project_Roster__c WHERE Active__c = true LIMIT 1].Id;
            pRCE.removeRosterAction();

            pRCE.rosterIdToActivationOrDeactivation = [SELECT Id FROM Project_Roster__c WHERE Active__c = true LIMIT 1].Id;
            pRCE.activateRosterAction();

            pRCE.rosterIdToActivationOrDeactivation = [SELECT Id FROM Project_Roster__c WHERE Active__c = false LIMIT 1].Id;
            pRCE.activateRosterAction();


        Test.stopTest();
    }

    @isTest( seeAllData = false) private static void testProjectRosterAtProjectRelatedListContExt(){
        setUp();
        
        Test.startTest();
            Test.setCurrentPageReference(Page.ProjectRosterAtProjectRelatedListPage);                    
            sc = new ApexPages.Standardcontroller(testProject);
            projectRosterContEx = new ProjectRosterAtProjectRelatedListContExt(sc);
        Test.stopTest();

        //System.assertEquals(testProjectRosterList.size(), projectRosterContEx.projectRosterList.size());
        
        testProjectRosterList = [SELECT Name,Company_Name__c,RecordTypeId,Project_Profile__c,Is_Read__c,Name__c,User_Contact__c,Id,Contact__c FROM Project_Roster__c Where Project_Profile__c = : testProject.Id];
        Map<Id,Project_Roster__c> testMap = new Map<Id,Project_Roster__c>();
            for(Project_Roster__c item : testProjectRosterList){
                testMap.put(item.Id,item);
            }
         
        for(Project_Roster__c item : projectRosterContEx.projectRosterList){
            System.assertEquals(testMap.get(item.Id).Id, item.Id);
            System.assertEquals(testMap.get(item.Id).Name, item.Name);
            System.assertEquals(testMap.get(item.Id).Company_Name__c, item.Company_Name__c);
            System.assertEquals(testMap.get(item.Id).RecordTypeId, item.RecordTypeId);
            System.assertEquals(testMap.get(item.Id).Project_Profile__c, item.Project_Profile__c);
            System.assertEquals(testMap.get(item.Id).Is_Read__c, item.Is_Read__c);
            System.assertEquals(testMap.get(item.Id).Name__c, item.Name__c);
            System.assertEquals(testMap.get(item.Id).User_Contact__c, item.User_Contact__c);
            System.assertEquals(testMap.get(item.Id).Contact__c, item.Contact__c);          
        }

//        projectRosterContEx.sortExpression = 'Name__c';
//        System.assertEquals('DESC', projectRosterContEx.getSortDirection());

//        System.assertEquals(testSortExp, projectRosterContEx.sortExpression);
//        projectRosterContEx.setSortDirection('ASC');
//        System.assertEquals('ASC', projectRosterContEx.getSortDirection());

//        projectRosterContEx.sortExpression = null;
//        System.assertEquals('ASC', projectRosterContEx.getSortDirection());

        System.assertEquals(null, projectRosterContEx.addToTheRosterAction());


        System.assert( projectRosterContEx.redirectUrl.contains(testProjectRosterObject.Project_Roster_Object_Id__c ) );
//        System.assert( projectRosterContEx.redirectUrl.contains(testProject.Project_Name__c ) );
        System.assert( projectRosterContEx.redirectUrl.contains(testProjectRosterObject.ProjectRoster_Field_Id__c ) );
        System.assert( projectRosterContEx.redirectUrl.contains(testProject.Id  ) );
        System.assert( projectRosterContEx.redirectUrl.contains(Schema.SObjectType.Project_Roster__c.getKeyPrefix() ) );
    }

    @isTest( seeAllData = false) private static void testRemoveRosterAction(){
        setUp();


        Test.setCurrentPageReference(Page.ProjectRosterAtProjectRelatedListPage);
        sc = new ApexPages.Standardcontroller(testProject);
        projectRosterContEx = new ProjectRosterAtProjectRelatedListContExt(sc);
        ApexPages.currentPage().getParameters().put('rosterId',testProjectRosterList[0].Id);

        Test.startTest();
            projectRosterContEx.removeRosterAction();
        Test.stopTest();

        //System.assertEquals(testProjectRosterList.size(), projectRosterContEx.projectRosterList.size());
    }

    @isTest( seeAllData = false) private static void testSortAction(){
        setUp();

        Test.setCurrentPageReference(Page.ProjectRosterAtProjectRelatedListPage);
        sc = new ApexPages.Standardcontroller(testProject);
        projectRosterContEx = new ProjectRosterAtProjectRelatedListContExt(sc);

//        projectRosterContEx.setSortDirection('ASC');
        System.assert(projectRosterContEx != null);

        Test.startTest();
            projectRosterContEx.sortAction();
        Test.stopTest();

        //System.assertEquals('Name2' , projectRosterContEx.projectRosterList[4].Name__c);



    }


}