@isTest
private class TestRFIScopeExtension {
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
    private static final String REGION_RFI_SCOPE_NY_RECORD_TYPE_VALUE = 'NY Region';
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
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPage;
    private static RFIScopeExtension testController;
    private static ApexPages.StandardController testStandardController;

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
            if (rfiScopeRecordTypeNameValue == REGION_RFI_SCOPE_NY_RECORD_TYPE_VALUE) {
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
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
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
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;
            projectProfileItem.Building__c = testBuildingList[0].Id;
        }
        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static void preparePageController (Project_Profile__c projectProfileForStandardController){
        testPage = Page.RFISummarySections;
        Test.setCurrentPage(testPage);
        if (projectProfileForStandardController != null) {
            testStandardController = new ApexPages.standardController(projectProfileForStandardController);
            testController = new RFIScopeExtension(testStandardController);
        }
    }

    private static void createProjectRosterForTest(){
        testProjectRosterList = new List<Project_Roster__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
                projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                projectRosterItem.Contact__c = testContactWithAccountList[0].Id;
                projectRosterItem.Role__c = testProjectRosterRoleRFIValuesList[0];
                projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
                testProjectRosterList.add(projectRosterItem);
            }
        }
        insert testProjectRosterList;
    }

    private static void createServiceItemForTest(){
        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
                serviceItemItem.Service_Group__c = 1;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
                serviceItemItem.Type__c = RFIScopeServices.PLAN_APPROVAL;
                serviceItemItem.Service_Group__c = 2;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(2, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
                serviceItemItem.Type__c = RFIScopeServices.SINGLE_WORK_PERMIT;
                serviceItemItem.Service_Group__c = 3;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
                serviceItemItem.Type__c = RFIScopeServices.SINGLE_WORK_PERMIT;
                serviceItemItem.Service_Group__c = 4;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
                serviceItemItem.Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
                serviceItemItem.Service_Group__c = 5;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
                serviceItemItem.Type__c = RFIScopeServices.WORK_PERMIT;
                serviceItemItem.Service_Group__c = 6;
                serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
                serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;
    }

    private static testmethod void testInitController(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        createServiceItemForTest();

        RFIScopeServices.insertRFIScopesForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        testProjectProfileList = [SELECT Id, Building__r.Municipality__r.Region__r.Id, Building__r.Municipality__r.Region__r.Name
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        testRFIScopeList = [SELECT Id
                            FROM RFI_Scope__c
                            WHERE Project__c In : testProjectProfileList AND
                                    RecordType.Name = : STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE];

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testNoteList = new List<Note>();
        for (RFI_Scope__c rfiScopeItem : testRFIScopeList){
            for (Monitor_RFI_Scope__c monitorRFIScopeItem : TestingUtils.createMonitorRFIWorkList(NUMBER_TO_CREATE_MONITOR_RFI_SCOPE, rfiScopeItem.Id, false)){
                monitorRFIScopeItem.Submit_Type__c = RFIScopeServices.APPLICATION_TYPE;
                testMonitorRFIScopeList.add(monitorRFIScopeItem);
            }
            for (Monitor_RFI_Scope__c monitorRFIScopeItem : TestingUtils.createMonitorRFIWorkList(NUMBER_TO_CREATE_MONITOR_RFI_SCOPE, rfiScopeItem.Id, false)){
                monitorRFIScopeItem.Submit_Type__c = RFIScopeServices.SIGN_OFF_TYPE;
                testMonitorRFIScopeList.add(monitorRFIScopeItem);
            }
            for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE, rfiScopeItem.Id, TEST_NOTE_TITLE_VALUE, false)){
                testNoteList.add(noteItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testNoteList;

        Test.startTest();
            preparePageController (testProjectProfileList[0]);
            if( testRFIScopeList.isEmpty() ){
                RFISingletonInstance.INSTANCE.rfiScope = TestingUtils.createRFIScopeList( 1, true )[0]; 
            }else {
                RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList[0]; 
            }
            
        Test.stopTest();

        testController.setPublishType('test publish type');
        System.assert(testController.getPublishType() != null);
        System.assert(testController.getSubmitedType != null);
        System.assert(testController.getSendViaType != null);
        System.assert(testController.getListRfiRegionScopes() != null);
        System.assert(testController.getListServiceItemGroupNumbers() != null);
        testController.updateRfiScopes();
        
        Map<Id, Monitor_RFI_Scope__c> trackingMap = new Map<Id, Monitor_RFI_Scope__c>(RFISingletonInstance.INSTANCE.rfiScope.Monitor_RFI_Scopes__r);
        testController.updateRfiScopes();
        testController.storageFolderName = '';
        testController.manageFileUpload();
        testController.storageFolderName = ADDITIONAL_DOCUMENTS_VALUE;
        testController.manageFileUpload();
        testController.storageFolderName = DRAVINGS_VALUE;
        testController.manageFileUpload();
        testController.submitApp();
        testController.submitSignOff();
        RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__c = testProjectRosterList[0].Id;
        testController.submitApp();
        testController.submitSignOff();
        testController.typeSubmit = 'App';
        testController.setLastReceived();
        for (Id monitorRFIScopeItem : trackingMap.keySet()){
            testController.monitorItemId = monitorRFIScopeItem;
        }
        testController.setLastReceived();
        testController.typeSubmit = 'SignOff';
        testController.setLastReceived();
        testController.isCheckedAlert = true;
        RFI_Scope__c rfi = testController.getRFIScope();
        testController.selectRFIScope();
        testController.isCheckedAlert = false;
        List<SelectOption> rosterOptions = testController.rosterIdToContact;
        List<SelectOption> submitType = testController.getSubmitedType;
        List<SelectOption> submitSendViaType = testController.getSendViaType;
        List<RFI_Scope__c> scopes = testController.orderRFIScopes;
        List<Monitor_RFI_Scope__c> rfiScopesListApp     = testController.rfiIdToApplicationSubmitScope;
        List<Monitor_RFI_Scope__c> rfiScopesListSignOff = testController.rfiIdToSignOffSubmitScope;
        
    }

    private static testmethod void testAddRfiScopes(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        createServiceItemForTest();

        RFIScopeServices.insertRFIScopesForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        testProjectProfileList = [SELECT Id, Building__r.Municipality__r.Region__r.Id, Building__r.Municipality__r.Region__r.Name
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        testRFIScopeList = [SELECT Id
                            FROM RFI_Scope__c
                            WHERE Project__c In : testProjectProfileList AND
                                    RecordType.Name = : STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE];

        testMonitorRFIScopeList = new List<Monitor_RFI_Scope__c>();
        testNoteList = new List<Note>();
        for (RFI_Scope__c rfiScopeItem : testRFIScopeList){
            for (Monitor_RFI_Scope__c monitorRFIScopeItem : TestingUtils.createMonitorRFIWorkList(NUMBER_TO_CREATE_MONITOR_RFI_SCOPE, rfiScopeItem.Id, false)){
                monitorRFIScopeItem.Submit_Type__c = RFIScopeServices.APPLICATION_TYPE;
                testMonitorRFIScopeList.add(monitorRFIScopeItem);
            }
            for (Monitor_RFI_Scope__c monitorRFIScopeItem : TestingUtils.createMonitorRFIWorkList(NUMBER_TO_CREATE_MONITOR_RFI_SCOPE, rfiScopeItem.Id, false)){
                monitorRFIScopeItem.Submit_Type__c = RFIScopeServices.SIGN_OFF_TYPE;
                testMonitorRFIScopeList.add(monitorRFIScopeItem);
            }
            for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE, rfiScopeItem.Id, TEST_NOTE_TITLE_VALUE, false)){
                testNoteList.add(noteItem);
            }
        }
        insert testMonitorRFIScopeList;
        insert testNoteList;

        preparePageController (testProjectProfileList[0]);

        testController.getListRfiRegionScopes();
        testController.getListServiceItemGroupNumbers();
        testController.addRfiScopes();
        testController.selectedRegionRfi = testProjectProfileList[0].Building__r.Municipality__r.Region__r.Id;
        testController.addRfiScopes();

        testController.selectedServiceGroupNumber = '1';

        Test.startTest();
            if( testRFIScopeList.isEmpty() ){
                RFISingletonInstance.INSTANCE.rfiScope = TestingUtils.createRFIScopeList( 1, true )[0]; 
            }else {
                RFISingletonInstance.INSTANCE.rfiScope = testRFIScopeList[0]; 
            }
            
            testController.addRfiScopes();
            Boolean renderedUploadPanel = testController.renderedUploadPanel;
            //testController.CopyToSignOff();
            
        Test.stopTest();
    }
    
    private static testmethod void testCopyToSignOff() {
        testPage = Page.RFISummarySections;
        Test.setCurrentPage(testPage);
        Project_Profile__c projectProfileForStandardController = new Project_Profile__c();
        
        testStandardController = new ApexPages.standardController(projectProfileForStandardController);
        testController         = new RFIScopeExtension(testStandardController);
        
        Test.startTest();
            testController.copyToSignOff();
        Test.stopTest();
        
    }
}