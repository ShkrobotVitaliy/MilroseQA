@isTest
private class TestRfiInputController {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_RFI_SCOPE = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 1;
    private static final Integer NUMBER_TO_CREATE_RFI_SCOPE_DESCRIPTION_NEW_YORK = 3;
    private static final Integer NUMBER_TO_CREATE_RFI_WORK = 4;
    private static final Integer NUMBER_TO_CREATE_MONITOR_RFI_SCOPE = 1;
    private static final Integer NUMBER_TO_CREATE_NOTE = 4;
    private static final Integer NUMBER_TO_CREATE_EVENT = 5;
    private static final String REGION_NY_RFI_SCOPE_RECORD_TYPE_VALUE = 'NY Region';
    private static final String STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE = 'Standard RFI Scope';
    private static final String TEST_EMAIL_TEMPLATE_PREFIX = '@gmail.com';
    private static final String TEST_TENANT_SCOPE_VALUE = 'Tenant Scope';
    private static final String TEST_CONTRACTOR_SCOPE_VALUE = 'Contractor Scope';
    private static final String RFI_STATUS_SENT = 'Sent';
    private static final String TEST_NOTE_TITLE_VALUE = 'TestTitle';
    private static final String ADDITIONAL_DOCUMENTS_VALUE = 'Additional Documents';
    private static final String DRAVINGS_VALUE = 'Drawings';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<RFI_Scope__c> testRegionRFIScopeList;
    private static List<RFI_Scope__c> testRFIScopeList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<RFI_Scope_Description_New_York__c> testRFIScopeDescriptionNewYorkList;
    private static List<RFI_Work__c> testRFIWorkList;
    private static List<Monitor_RFI_Scope__c> testMonitorRFIScopeList;
    private static List<Note> testNoteList;
    private static List<Event> testEventList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static List<String> testProjectLevelRFIValuesList;
    private static List<String> testServiceLevelRFIValuesList;
    private static List<String> testProjectRosterRoleRFIValuesList;

    private static String testProjectLevelRFIValuesString;
    private static String testServiceLevelRFIValuesString;

    private static Id rfiScopeRegionRFIScopeRecordTypeId;
    private static Id rfiScopeStandardRFIScopeRecordTypeId;
    private static Id projectRosterUserRecordTypeId;
    private static Id projectRosterContactRecordTypeId;

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
        //prepare RFI Scope Record Type
        Map<String, Id> rfiScopeRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('RFI_Scope__c');
        for (String rfiScopeRecordTypeNameValue : rfiScopeRecordTypesMap.keySet()){
            if (rfiScopeRecordTypeNameValue == REGION_NY_RFI_SCOPE_RECORD_TYPE_VALUE) {
                rfiScopeRegionRFIScopeRecordTypeId = rfiScopeRecordTypesMap.get(rfiScopeRecordTypeNameValue);
            }
            if (rfiScopeRecordTypeNameValue == STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE) {
                rfiScopeStandardRFIScopeRecordTypeId = rfiScopeRecordTypesMap.get(rfiScopeRecordTypeNameValue);
            }
        }
        testProjectLevelRFIValuesString = '';
        //prepare Project Level RFI values list
        testProjectLevelRFIValuesList = new List<String>();
        for (Schema.PicklistEntry ple : Service_Item__c.Project_Level_RFI__c.getDescribe().getPicklistValues()){
            testProjectLevelRFIValuesString += ple.getValue() + ';';
            testProjectLevelRFIValuesList.add(ple.getValue());
        }
        testProjectLevelRFIValuesString = testProjectLevelRFIValuesString.removeEnd(';');
        testServiceLevelRFIValuesString = '';
        //prepare Service Level RFI values list
        testServiceLevelRFIValuesList = new List<String>();
        for (Schema.PicklistEntry ple : Service_Item__c.Service_Level_RFI__c.getDescribe().getPicklistValues()){
            testServiceLevelRFIValuesString += ple.getValue() + ';';
            testServiceLevelRFIValuesList.add(ple.getValue());
        }
        testServiceLevelRFIValuesString = testServiceLevelRFIValuesString.removeEnd(';');
        //prepare Project Roster Role List values from RFI Scope
        testProjectRosterRoleRFIValuesList = new List<String>();
        for (Schema.PicklistEntry ple : RFI_Scope__c.Project_Roster_Role__c.getDescribe().getPicklistValues()){
            testProjectRosterRoleRFIValuesList.add(ple.getValue());
        }
    }

    private static void setupData (){
        prepareRecordTypePickListValuesForTest();
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, false);
        for (Contact contactItem : testContactWithAccountList){
            contactItem.Email = String.valueOf(contactItem.Account.Id) + TEST_EMAIL_TEMPLATE_PREFIX;
        }
        insert testContactWithAccountList;
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, false);
        testRegionList[0].Name = RegionServices.REGION_NAME_NY;
        insert testRegionList;
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void createRegionRFIScopeForTest(){
        testRegionRFIScopeList = new List<RFI_Scope__c>();
        for (Region__c regionItem : testRegionList){
            for (String regionLevelRFIItem : testProjectLevelRFIValuesList){
                for (RFI_Scope__c rfiScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rfiScopeItem.Name = regionLevelRFIItem;
                    rfiScopeItem.Region__c = regionItem.Id;
                    rfiScopeItem.RecordTypeId = rfiScopeRegionRFIScopeRecordTypeId;
                    rfiScopeItem.Project_Roster_Role__c = testProjectRosterRoleRFIValuesList[0];
                    rfiScopeItem.RFI_Section__c = TEST_TENANT_SCOPE_VALUE;
                    testRegionRFIScopeList.add(rfiScopeItem);
                }
                for (RFI_Scope__c rfiScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rfiScopeItem.Name = regionLevelRFIItem;
                    rfiScopeItem.Region__c = regionItem.Id;
                    rfiScopeItem.RecordTypeId = rfiScopeRegionRFIScopeRecordTypeId;
                    rfiScopeItem.Project_Roster_Role__c = testProjectRosterRoleRFIValuesList[0];
                    rfiScopeItem.RFI_Section__c = TEST_CONTRACTOR_SCOPE_VALUE;
                    testRegionRFIScopeList.add(rfiScopeItem);
                }
            }
            for (String regionLevelRFIItem : testServiceLevelRFIValuesList){
                for (RFI_Scope__c rfiScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rfiScopeItem.Name = regionLevelRFIItem;
                    rfiScopeItem.Region__c = regionItem.Id;
                    rfiScopeItem.Project_Roster_Role__c = testProjectRosterRoleRFIValuesList[0];
                    rfiScopeItem.RecordTypeId = rfiScopeRegionRFIScopeRecordTypeId;
                    rfiScopeItem.RFI_Section__c = TEST_CONTRACTOR_SCOPE_VALUE;
                    testRegionRFIScopeList.add(rfiScopeItem);
                }
            }
        }
        insert testRegionRFIScopeList;
        
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        Integer i = 0;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;
            projectProfileItem.Building__c = testBuildingList[0].Id;
            projectProfileItem.Key__c = 'test' + String.valueOf(i++);
        }
        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static void createProjectRosterForTest(){
        testProjectRosterList = new List<Project_Roster__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            integer i = 0;
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.Contact__c = testContactWithAccountList[0].Id;
                projectRosterItem.Role__c = testProjectRosterRoleRFIValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
                projectRosterItem.Key__c = projectProfileItem.Key__c + String.valueOf(i++);
                testProjectRosterList.add(projectRosterItem);
            }
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.User__c = currentUserId;
                projectRosterItem.Role__c = testProjectRosterRoleRFIValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                projectRosterItem.Key__c = projectProfileItem.Key__c + String.valueOf(i++);
                testProjectRosterList.add(projectRosterItem);
            }
        }
        insert testProjectRosterList;
    }

    private static void prepareRFIScopeMonitorRFIScope(Boolean monitorRFILocked){
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (RFI_Scope__c rfiScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rfiScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                rfiScopeItem.Project__c = projectProfileItem.Id;
                testRFIScopeList.add(rfiScopeItem);
            }
        }
        insert testRFIScopeList;

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            Integer i = 0;
            for (Monitor_RFI_Scope__c monitorRFIScopeItem : TestingUtils.createMonitorRFIWorkList(1, rifScopeItem.Id, false)){
                monitorRFIScopeItem.Key__c = String.valueOf(rifScopeItem.Id) + String.valueOf(i++);
                monitorRFIScopeItem.Is_Lock__c = monitorRFILocked;
                testMonitorRFIScopeList.add(monitorRFIScopeItem);
            }
        }
        insert testMonitorRFIScopeList;
    }

    private static PageReference testPage;
    private static RfiInputController testController;

    private static void preparePageController (String urikeyStringValue, String uriobjStringValue, String publishTypeStringValue){
        testPage = Page.RfiInput;
        Test.setCurrentPage(testPage);
        if (!String.isEmpty(urikeyStringValue)){
            ApexPages.currentPage().getParameters().put('u', String.valueOf(urikeyStringValue));
        }
        if (!String.isEmpty(uriobjStringValue)){
            ApexPages.currentPage().getParameters().put('o', String.valueOf(uriobjStringValue));
        }
        if (!String.isEmpty(publishTypeStringValue)){
            ApexPages.currentPage().getParameters().put('type', String.valueOf(publishTypeStringValue));
        }
        testController = new RfiInputController();
    }

    private static testMethod void testInitController() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        prepareRFIScopeMonitorRFIScope(false);

        Test.startTest();

            preparePageController(null, null, null);
            Boolean testBoolean;
            testBoolean = testController.isApplication;
            testBoolean = testController.isSignOff;
            testBoolean = testController.isSubmitted;
            testBoolean = testController.isValid;

        Test.stopTest();

    }

    private static testMethod void testAutorunWithoutParameter() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        prepareRFIScopeMonitorRFIScope(false);

        preparePageController(null, null, null);

        Test.startTest();

            testController.autorun();

        Test.stopTest();

    }

    private static testMethod void testAutorunWithParameter() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        prepareRFIScopeMonitorRFIScope(false);

        preparePageController(testProjectRosterList[0].Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : testProjectRosterList[0].Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            testController.autorun();

        Test.stopTest();

    }

    private static testMethod void testAutorunWithParameterMonitorRFIScopeKey() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        prepareRFIScopeMonitorRFIScope(false);

        preparePageController(testMonitorRFIScopeList[0].Key__c, 'empty', RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            testController.autorun();

        Test.stopTest();


        System.assert(testController.project != null);
    }

    private static testMethod void testAutorunWithParameterMonitorRFIScopeKeyLocked() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        prepareRFIScopeMonitorRFIScope(true);

        preparePageController(testMonitorRFIScopeList[0].Key__c, 'empty', RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            testController.autorun();

        Test.stopTest();
    }

    private static testMethod void testAutorunWithParameterProjectEmpty() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        preparePageController(testProjectRosterList[0].Key__c, testProjectRosterList[0].Key__c + 'somevalue', RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            testController.autorun();

        Test.stopTest();
    }

    private static testMethod void testAutorunWithParameterIncorrect() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        preparePageController(testProjectRosterList[0].Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id != : testProjectRosterList[0].Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);

        Test.startTest();

            testController.autorun();

        Test.stopTest();
    }

    private static testMethod void testSaveScope() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        preparePageController(testProjectRosterList[0].Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : testProjectRosterList[0].Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);

        testController.autorun();

        Test.startTest();

            testController.saveScope();

        Test.stopTest();
    }

    private static testMethod void testSaveScopeWithUser() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        Project_Roster__c projectRosterForTest;

        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            if (projectRosterItem.User__c != null){
                for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rifScopeItem.Project_Roster__c = projectRosterItem.id;
                    rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                    rifScopeItem.Status__c = RFI_STATUS_SENT;
                    rifScopeItem.Submit_Application__c = true;
                    rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                    projectRosterForTest = projectRosterItem;
                    testRFIScopeList.add(rifScopeItem);
                }
            }
        }
        insert testRFIScopeList;

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            testMonitorRFIScopeList.addAll(TestingUtils.createMonitorRFIWorkList(1, rifScopeItem.Id, false));
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(1, false)){
                rfiWorkItem.RFI_Scope__c = rifScopeItem.id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testRFIWorkList;

        preparePageController(projectRosterForTest.Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : projectRosterForTest.Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);

        testController.autorun();

        Test.startTest();

            testController.saveScope();

        Test.stopTest();
    }

    private static testMethod void testSaveScopeWithUserSignOffType() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        Project_Roster__c projectRosterForTest;

        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            if (projectRosterItem.User__c != null){
                for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rifScopeItem.Project_Roster__c = projectRosterItem.id;
                    rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                    rifScopeItem.Status__c = RFI_STATUS_SENT;
                    rifScopeItem.Submit_Application__c = true;
                    rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                    projectRosterForTest = projectRosterItem;
                    testRFIScopeList.add(rifScopeItem);
                }
            }
        }
        insert testRFIScopeList;

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            testMonitorRFIScopeList.addAll(TestingUtils.createMonitorRFIWorkList(1, rifScopeItem.Id, false));
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(1, false)){
                rfiWorkItem.RFI_Scope__c = rifScopeItem.id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testRFIWorkList;

        preparePageController(projectRosterForTest.Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : projectRosterForTest.Project_Profile__c][0].Key__c, RFIScopeServices.SIGN_OFF_TYPE);
        
        testController.autorun();
        
        Test.startTest();
            RFI_Scope_Description_New_York__c descr = new RFI_Scope_Description_New_York__c();
            insert descr;
            
            RFI_Scope__c rfiScope = new RFI_Scope__c();
            rfiScope.RFI_Scope_Description_New_York__c = descr.Id;
            insert rfiScope;
            
            RFISingletonInstance.INSTANCE.rfiScope = rfiScope;
            
            testController.saveScope();

        Test.stopTest();
    }
    
    private static testMethod void testSaveScopeWithUserAppType() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        Project_Roster__c projectRosterForTest;

        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            if (projectRosterItem.User__c != null){
                for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rifScopeItem.Project_Roster__c = projectRosterItem.id;
                    rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                    rifScopeItem.Status__c = RFI_STATUS_SENT;
                    rifScopeItem.Submit_Application__c = true;
                    rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                    projectRosterForTest = projectRosterItem;
                    testRFIScopeList.add(rifScopeItem);
                }
            }
        }
        insert testRFIScopeList;

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            testMonitorRFIScopeList.addAll(TestingUtils.createMonitorRFIWorkList(1, rifScopeItem.Id, false));
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(1, false)){
                rfiWorkItem.RFI_Scope__c = rifScopeItem.id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testRFIWorkList;

        preparePageController(projectRosterForTest.Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : projectRosterForTest.Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);
        
        testController.autorun();
        
        Test.startTest();
            RFI_Scope_Description_New_York__c descr = new RFI_Scope_Description_New_York__c();
            insert descr;
            
            RFI_Scope__c rfiScope = new RFI_Scope__c();
            rfiScope.RFI_Scope_Description_New_York__c = descr.Id;
            insert rfiScope;
            
            RFISingletonInstance.INSTANCE.rfiScope = rfiScope;
            
            testController.saveScope();
           
        Test.stopTest();
    }
    
    private static testMethod void testGetRFIScope() {
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        Project_Roster__c projectRosterForTest;

        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            if (projectRosterItem.User__c != null){
                for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(1, false)){
                    rifScopeItem.Project_Roster__c = projectRosterItem.id;
                    rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                    rifScopeItem.Status__c = RFI_STATUS_SENT;
                    rifScopeItem.Submit_Application__c = true;
                    rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                    projectRosterForTest = projectRosterItem;
                    testRFIScopeList.add(rifScopeItem);
                }
            }
        }
        insert testRFIScopeList;

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testRFIWorkList = new List<RFI_Work__c>();
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            testMonitorRFIScopeList.addAll(TestingUtils.createMonitorRFIWorkList(1, rifScopeItem.Id, false));
            for (RFI_Work__c rfiWorkItem : TestingUtils.createRFIWorkList(1, false)){
                rfiWorkItem.RFI_Scope__c = rifScopeItem.id;
                testRFIWorkList.add(rfiWorkItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testRFIWorkList;

        preparePageController(projectRosterForTest.Key__c, [SELECT Id, Key__c FROM Project_Profile__c WHERE Id = : projectRosterForTest.Project_Profile__c][0].Key__c, RFIScopeServices.APPLICATION_TYPE);
        
        RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList.get(0);
        
        testController.autorun();
        
        Test.startTest();
            RFI_Scope_Description_New_York__c descr = new RFI_Scope_Description_New_York__c();
            insert descr;
            
            RFI_Scope__c rfiScope = new RFI_Scope__c();
            rfiScope.RFI_Scope_Description_New_York__c = descr.Id;
            insert rfiScope;
            
            RFISingletonInstance.INSTANCE.rfiScope = rfiScope;
            
            RFI_Scope__c temp = testController.getRFIScope();
            testController.saveScope();
           
        Test.stopTest();
    }
}