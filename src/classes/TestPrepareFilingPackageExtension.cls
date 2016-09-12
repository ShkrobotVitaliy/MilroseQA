@isTest
private class TestPrepareFilingPackageExtension {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_APPLICATION_FILLING_CHECKLIST = 1;
    private static final Integer NUMBER_TO_CREATE_WORK_PERMIT_FILLING_CHECKLIST = 1;
    private static final Integer NUMBER_TO_CREATE_APPLICATION_SIGN_OFF_SCOPE = 1;
    private static final List<String> WORK_TYPE_VALUES_LIST = new List<String> {PrepareFilingPackageExtension.GENERAL_CONSTRUCTION,
                                                                                PrepareFilingPackageExtension.MECHANICAL,
                                                                                PrepareFilingPackageExtension.PLUMBING,
                                                                                PrepareFilingPackageExtension.STRUCTURAL,
                                                                                PrepareFilingPackageExtension.SPRINKLER,
                                                                                PrepareFilingPackageExtension.FIRE_ALARM};

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Application_Filing_Checklist__c> testApplicationFillingChecklistList;
    private static List<Work_Permit_Filing_Checklist__c> testWorkPermitFillingCheklistList;
    private static List<Application_Sign_Off_Scope__c> testApplicationSignOffScopeList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Id applicationFillingChecklistChecklistDescriptionsRecordTypeId;
    private static Id workPermitFillingChecklistChecklistDescriptionsRecordTypeId;
    private static Id applicationSignOffScopeDescriptionsRecordTypeId;
    private static Id applicationFillingChecklistChecklistNotDescriptionsRecordTypeId;
    private static Id workPermitFillingChecklistChecklistNotDescriptionsRecordTypeId;
    private static Id applicationSignOffScopeNotDescriptionsRecordTypeId;

    private static PageReference testPage;
    private static PrepareFilingPackageExtension testController;
    private static ApexPages.StandardController testStandardController;

    private static void prepareRecordTypePickListValuesForTest(){
        Map<String, Id> applicationFillingChecklistRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Application_Filing_Checklist__c');
        for (String applicationFillingChecklistRecordTypeNameValue : applicationFillingChecklistRecordTypesMap.keySet()){
            if (applicationFillingChecklistRecordTypeNameValue == PrepareFilingPackageExtension.CHECKLIST_DESCRIPTIONS_RECORD_TYPE) {
                applicationFillingChecklistChecklistDescriptionsRecordTypeId = applicationFillingChecklistRecordTypesMap.get(applicationFillingChecklistRecordTypeNameValue);
            } else {
                applicationFillingChecklistChecklistNotDescriptionsRecordTypeId = applicationFillingChecklistRecordTypesMap.get(applicationFillingChecklistRecordTypeNameValue);
            }
        }
        Map<String, Id> workPermitFillingChecklistRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Work_Permit_Filing_Checklist__c');
        for (String workPermitFillingChecklistRecordTypeNameValue : workPermitFillingChecklistRecordTypesMap.keySet()){
            if (workPermitFillingChecklistRecordTypeNameValue == PrepareFilingPackageExtension.CHECKLIST_DESCRIPTIONS_RECORD_TYPE) {
                workPermitFillingChecklistChecklistDescriptionsRecordTypeId = workPermitFillingChecklistRecordTypesMap.get(workPermitFillingChecklistRecordTypeNameValue);
            } else {
                workPermitFillingChecklistChecklistNotDescriptionsRecordTypeId = workPermitFillingChecklistRecordTypesMap.get(workPermitFillingChecklistRecordTypeNameValue);
            }
        }
        Map<String, Id> applicationSignOffScopeRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Application_Sign_Off_Scope__c');
        for (String applicationSignOffScopeRecordTypeNameValue : applicationSignOffScopeRecordTypesMap.keySet()){
            if (applicationSignOffScopeRecordTypeNameValue == PrepareFilingPackageExtension.CHECKLIST_DESCRIPTIONS_RECORD_TYPE) {
                applicationSignOffScopeDescriptionsRecordTypeId = applicationSignOffScopeRecordTypesMap.get(applicationSignOffScopeRecordTypeNameValue);
            } else {
                applicationSignOffScopeNotDescriptionsRecordTypeId = applicationSignOffScopeRecordTypesMap.get(applicationSignOffScopeRecordTypeNameValue);
            }
        }
    }

    private static void setupData (){
        prepareRecordTypePickListValuesForTest();
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

    private static void prepareDataForTest(){
        testApplicationFillingChecklistList = TestingUtils.createApplicationFillingChecklistList(NUMBER_TO_CREATE_APPLICATION_FILLING_CHECKLIST, false);
        testApplicationFillingChecklistList[0].RecordTypeId = applicationFillingChecklistChecklistDescriptionsRecordTypeId;
        insert testApplicationFillingChecklistList;

        testWorkPermitFillingCheklistList = TestingUtils.createWorkPermitFillingChecklistList(NUMBER_TO_CREATE_WORK_PERMIT_FILLING_CHECKLIST, false);
        testWorkPermitFillingCheklistList[0].RecordTypeId = workPermitFillingChecklistChecklistDescriptionsRecordTypeId;
        insert testWorkPermitFillingCheklistList;

        testApplicationSignOffScopeList = TestingUtils.createApplicationSignOffScopeList(NUMBER_TO_CREATE_APPLICATION_SIGN_OFF_SCOPE, false);
        testApplicationSignOffScopeList[0].RecordTypeId = applicationSignOffScopeDescriptionsRecordTypeId;
        insert testApplicationSignOffScopeList;

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList (NUMBER_TO_CREATE_TASK_ITEM,
                                                                              serviceItemItem.Id,
                                                                              serviceItemItem.Project_Profile__c,
                                                                              false)){
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;
    }

    private static void preparePageController (Task_Item__c taskItemForStandardController){
        testPage = Page.PrepareFilingPackageSection;
        Test.setCurrentPage(testPage);
        if (taskItemForStandardController != null) {
            testStandardController = new ApexPages.standardController(taskItemForStandardController);
            testController = new PrepareFilingPackageExtension(testStandardController);
        }
    }

    private static testmethod void testInitController(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        Test.startTest();

            preparePageController (testTaskItemList[0]);

        Test.stopTest();

        System.assert(testController != null);
    }

    private static testmethod void testInitControllerWithApplicationSignOffScope(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        testApplicationSignOffScopeList = new List<Application_Sign_Off_Scope__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (String stringItem : WORK_TYPE_VALUES_LIST){
                for (Application_Sign_Off_Scope__c applicationSingOffScopeItem : TestingUtils.createApplicationSignOffScopeList(1, false)){
                    applicationSingOffScopeItem.Work_Type__c = stringItem;
                    applicationSingOffScopeItem.Task_Item__c = taskItemItem.Id;
                    if (applicationSignOffScopeNotDescriptionsRecordTypeId != null){
                        applicationSingOffScopeItem.RecordTypeId = applicationSignOffScopeNotDescriptionsRecordTypeId;
                    }
                    testApplicationSignOffScopeList.add(applicationSingOffScopeItem);
                }
            }
        }
        insert testApplicationSignOffScopeList;

        System.assert(! testTaskItemList.isEmpty() );

        Test.startTest();

            preparePageController (testTaskItemList[0]);

        Test.stopTest();

        System.assert(testController != null);
    }

    private static testmethod void testInitControllerWithApplicationSignOffScopeListWorkPermitFillingCheklist(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        testApplicationFillingChecklistList = new List<Application_Filing_Checklist__c>();
        testWorkPermitFillingCheklistList = new List<Work_Permit_Filing_Checklist__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Work_Permit_Filing_Checklist__c workPermitFilingChecklistItem : TestingUtils.createWorkPermitFillingChecklistList(1, false)){
                workPermitFilingChecklistItem.Task_Item__c = taskItemItem.Id;
                if (workPermitFillingChecklistChecklistNotDescriptionsRecordTypeId != null){
                    workPermitFilingChecklistItem.RecordTypeId = workPermitFillingChecklistChecklistNotDescriptionsRecordTypeId;
                }
                testWorkPermitFillingCheklistList.add(workPermitFilingChecklistItem);
            }
            for (Application_Filing_Checklist__c testApplicationFilingChecklistItem : TestingUtils.createApplicationFillingChecklistList(1, false)){
                testApplicationFilingChecklistItem.Task_Item__c = taskItemItem.Id;
                if (applicationFillingChecklistChecklistNotDescriptionsRecordTypeId != null){
                    testApplicationFilingChecklistItem.RecordTypeId = applicationFillingChecklistChecklistNotDescriptionsRecordTypeId;
                }
                testApplicationFillingChecklistList.add(testApplicationFilingChecklistItem);
            }
        }
        insert testWorkPermitFillingCheklistList;
        insert testApplicationFillingChecklistList;

        System.assert(! testTaskItemList.isEmpty() );

        Test.startTest();

            preparePageController (testTaskItemList[0]);

        Test.stopTest();

        System.assert(testController != null);
    }

    private static testmethod void testSetFilingChecklistStateTrue(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isAppChecklistNotRequired = true;
        testController.isConstructionChecklistNotRequired = true;
        testController.isSignOffChecklistNotRequired = true;
        
        System.assert(testController.isChecklistNotRequired);

        Test.startTest();

            System.assert(testController != null);

            testController.setFilingChecklistState();

        Test.stopTest();

        //System.assert (!testController.isAppChecklistNotRequired);
        //System.assert (!testController.isConstructionChecklistNotRequired);
        //System.assert (!testController.isSignOffChecklistNotRequired);
    }

    private static testmethod void testDefaultFilingCkecklistRecord(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        Application_Filing_Checklist__c resultRecord;

        Test.startTest();

            resultRecord = testController.defaultFilingCkecklistRecord;

        Test.stopTest();

        System.assert(resultRecord != null);
    }

    private static testmethod void testDefaultWorkPermitFilingCkecklistRecord(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        Work_Permit_Filing_Checklist__c resultRecord;

        Test.startTest();

            resultRecord = testController.defaultWorkPermitFilingCkecklistRecord;

        Test.stopTest();

        System.assert(resultRecord != null);
    }

    private static testmethod void testDefaultAppSignOffFilingCkecklistRecord(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        Application_Sign_Off_Scope__c resultRecord;

        Test.startTest();

            resultRecord = testController.defaultAppSignOffFilingCkecklistRecord;

        Test.stopTest();

        System.assert(resultRecord != null);
    }

    private static testmethod void testSetFilingChecklistStateFalse(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isAppChecklistNotRequired = false;
        testController.isConstructionChecklistNotRequired = false;
        testController.isSignOffChecklistNotRequired = false;
        System.assert (!testController.isChecklistNotRequired);

        Test.startTest();

            testController.setFilingChecklistState();

        Test.stopTest();

        System.assert(testController != null);

        //System.assert (testController.isAppChecklistNotRequired);
        //System.assert (testController.isConstructionChecklistNotRequired);
        //System.assert (testController.isSignOffChecklistNotRequired);
    }

    private static testmethod void testCompleteChecklists(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isAppChecklistNotRequired = true;
        testController.isConstructionChecklistNotRequired = true;
        testController.isSignOffChecklistNotRequired = true;

        Test.startTest();

            testController.completeChecklists();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        //System.assertEquals(1, msgList.size());
        //System.assert (msgList[0].getDetail().contains(PrepareFilingPackageExtension.FORM_SUCCESSFULLY_COMPLETED));
    }

    private static testmethod void testCompleteChecklistsWithRequiredFieldMessage(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);


        Test.startTest();

            testController.isAppChecklistNotRequired = false;
            testController.completeChecklists();

        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assert (msgList[0].getDetail().contains(PrepareFilingPackageExtension.REQUIRED_FILED_ERROR));
    }

    private static testmethod void testCompleteChecklistsWithRequiredFieldMessageForDifferentField(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);

        System.assert(testController != null);

        Test.startTest();

            testController.isAppChecklistNotRequired = false;
            testController.isNotPropertyRequired = false;
            testController.completeChecklists();

            testController.isAppChecklistNotRequired = false;
            testController.isNotPropertyRequired = true;
            testController.isNotScopeRequired = false;
            testController.completeChecklists();

            testController.isAppChecklistNotRequired = true;
            testController.isConstructionChecklistNotRequired = false;
            testController.isConstructionScopeNotRequired = false;
            testController.completeChecklists();

            testController.isConstructionScopeNotRequired = true;
            testController.isConstructionTechnicalReportsNotRequired = false;
            testController.completeChecklists();

            testController.isConstructionTechnicalReportsNotRequired = true;
            testController.isConstructionFeesNotRequired = false;
            testController.completeChecklists();

            testController.isConstructionChecklistNotRequired = true;
            testController.isConstructionFeesNotRequired = true;
            testController.isSignOffChecklistNotRequired = false;
            testController.isGeneralConstructionNotRequired = false;
            testController.completeChecklists();

            testController.isGeneralConstructionNotRequired = true;
            testController.isFireAlarmNotRequired = false;
            testController.completeChecklists();

            testController.isFireAlarmNotRequired = true;
            testController.isMechanicalNotRequired = false;
            testController.completeChecklists();

            testController.isMechanicalNotRequired = true;
            testController.isPlumbingNotRequired = false;
            testController.completeChecklists();

            testController.isPlumbingNotRequired = true;
            testController.isSprinklerNotRequired = false;
            testController.completeChecklists();

            testController.isSprinklerNotRequired = true;
            testController.isStructuralNotRequired = false;
            testController.completeChecklists();
        Test.stopTest();
    }

    private static testmethod void testSetAppFilingChecklistState(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isAppChecklistNotRequired = true;

        Test.startTest();

            testController.setAppFilingChecklistState();

        Test.stopTest();

        System.assert (!testController.isAppChecklistNotRequired);
    }

    private static testmethod void testSetConstructionFilingChecklistState(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isConstructionChecklistNotRequired = true;

        Test.startTest();

            testController.setConstructionFilingChecklistState();

        Test.stopTest();

        System.assert (!testController.isConstructionChecklistNotRequired);
    }

    private static testmethod void testSetAignOffChecklistState(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController (testTaskItemList[0]);
        testController.isSignOffChecklistNotRequired = true;

        Test.startTest();

            testController.setAignOffChecklistState();

        Test.stopTest();

        System.assert (!testController.isSignOffChecklistNotRequired);
    }
}