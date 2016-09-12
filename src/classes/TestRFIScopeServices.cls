@isTest
private class TestRFIScopeServices {
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
    private static final String STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE = RFIScopeServices.RECORD_TYPE_NAME_STANDARD;
    private static final String TEST_EMAIL_TEMPLATE_PREFIX = '@gmail.com';
    private static final String TEST_TENANT_SCOPE_VALUE = 'Tenant Scope';
    private static final String TEST_CONTRACTOR_SCOPE_VALUE = 'Contractor Scope';
    private static final String RFI_STATUS_SENT = 'Sent';

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
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
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
            if (rfiScopeRecordTypeNameValue != STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE) {
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
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProductionManagerUser = TestingUtils.testProductionManagerUser;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        for (Contact contactItem : TestingUtils.testContactWithAccountList){
            contactItem.Email = String.valueOf(contactItem.Account.Id) + TEST_EMAIL_TEMPLATE_PREFIX;
        }
        update TestingUtils.testContactWithAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
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

    private static testmethod void testInsertRFIScopesForProjects(){
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        createServiceItemForTest();

        Test.startTest();

            RFIScopeServices.insertRFIScopesForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        Test.stopTest();

        testRFIScopeList = [SELECT Id
                            FROM RFI_Scope__c
                            WHERE RecordType.Name = : STANDARD_RFI_SCOPE_RECORD_TYPE_VALUE];

    }

    private static testmethod void testCreateRFIForChangeOrder(){
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        createServiceItemForTest();

        Map<Id, List<Service_Item__c>> ProjectProfileWithServiceItemsMap = new Map<Id, List<Service_Item__c>>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            if (!ProjectProfileWithServiceItemsMap.containsKey(serviceItemItem.Project_Profile__c)){
                ProjectProfileWithServiceItemsMap.put(serviceItemItem.Project_Profile__c, new List<Service_Item__c>());
            }
            ProjectProfileWithServiceItemsMap.get(serviceItemItem.Project_Profile__c).add(serviceItemItem);
        }

        Test.startTest();

            RFIScopeServices.createRFIForChangeOrder(new Map<Id, Service_Item__c>(testServiceItemList).keySet());

        Test.stopTest();
    }

    private static testmethod void testCreateAdditionalRfiScopes(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
            serviceItemItem.Type__c = RFIScopeServices.PLAN_APPROVAL;
            testServiceItemList.add(serviceItemItem);
        }
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
            serviceItemItem.Type__c = RFIScopeServices.WORK_PERMIT;
            testServiceItemList.add(serviceItemItem);
        }
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            serviceItemItem.Type__c = 'Not equals ' + RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        Test.startTest();

            RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, testRegionRFIScopeList[0], testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);

        Test.stopTest();
    }

    private static testmethod void testCreateAdditionalRfiScopesForServiceListSizeTwo(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(2, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_WORK_PERMIT;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        testRegionRFIScopeList[0].RFI_Section__c = TEST_CONTRACTOR_SCOPE_VALUE;

        Test.startTest();

            RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, testRegionRFIScopeList[0], testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);

        Test.stopTest();
    }

    private static testmethod void testCreateAdditionalRfiScopesForServiceListSizeOne(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_FILING;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_WORK_PERMIT;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        Test.startTest();

            RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, testRegionRFIScopeList[0], testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);

        Test.stopTest();
    }

    private static testmethod void testCreateAdditionalRfiScopesForServiceListForSingleLetterSizeOne(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        Test.startTest();

            RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, testRegionRFIScopeList[0], testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);

        Test.stopTest();
    }

    private static testmethod void testCreateAdditionalRfiScopesWithEmptyRFITemplate(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        String errorString;

        Test.startTest();

            try{
                RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, null, testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testCreateAdditionalRfiScopesWithEmptyServiceItemList(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        String errorString;

        Test.startTest();

            try{
                RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, testProjectProfileList[0].Id, testRegionRFIScopeList[0], null, testProjectRosterList, RegionServices.REGION_NAME_NY);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testCreateAdditionalRfiScopesWithIncorrectData(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();

        testServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
            serviceItemItem.Project_Level_RFI__c = testProjectLevelRFIValuesString;
            serviceItemItem.Service_Level_RFI__c = testServiceLevelRFIValuesString;
            serviceItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            serviceItemItem.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
            serviceItemItem.Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION;
            testServiceItemList.add(serviceItemItem);
        }
        insert testServiceItemList;

        String errorString;

        Id incorrectProjectProfileId = Id.valueOf(Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        Test.startTest();

            try{
                RFIScopeServices.createAdditionalRfiScopes(testRegionList[0].Id, incorrectProjectProfileId, testRegionRFIScopeList[0], testServiceItemList, testProjectRosterList, RegionServices.REGION_NAME_NY);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testInsertRFIDescriptions(){
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false);

        Test.startTest();

            RFIScopeServices.insertRFIDescriptions(testRFIScopeList);

        Test.stopTest();

        for (RFI_Scope__c rfiScopeItem : testRFIScopeList) {
            //System.assert(rfiScopeItem.RFI_Scope_Description_New_York__c != null);
        }
    }

    private static testmethod void testCopyAppToSignOff(){
        testRFIScopeDescriptionNewYorkList = TestingUtils.createRFIScopeDescriptionNewYorkList(NUMBER_TO_CREATE_RFI_SCOPE_DESCRIPTION_NEW_YORK, false);

        testRFIWorkList = TestingUtils.createRFIWorkList(NUMBER_TO_CREATE_RFI_WORK, false);

        test.startTest();

            RFIScopeServices.copyAppToSignOff(testRFIScopeDescriptionNewYorkList[0], testRFIWorkList, true);
            RFIScopeServices.copyAppToSignOff(testRFIScopeDescriptionNewYorkList[0], testRFIWorkList, false);

        test.stopTest();
    }

    private static testmethod void testGetRFIScopeWithServiceItemById(){
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);

        Map<Id, RFI_Scope__c> resultRFIScopeMap;

        Test.startTest();

            resultRFIScopeMap = RFIScopeServices.getRFIScopeWithServiceItemById(new Map<Id, RFI_Scope__c>(testRFIScopeList).keySet());

        Test.stopTest();

        System.assert(!resultRFIScopeMap.isEmpty());
        System.assertEquals(new Map<Id, RFI_Scope__c>(testRFIScopeList).keySet(), resultRFIScopeMap.keySet());
    }

    private static testmethod void testGetRFIScopeWithServiceItemByIdWithEmptyRFIScopeSet(){
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);

        Map<Id, RFI_Scope__c> resultRFIScopeMap;

        Test.startTest();

            resultRFIScopeMap = RFIScopeServices.getRFIScopeWithServiceItemById(null);

        Test.stopTest();

        System.assert(resultRFIScopeMap.isEmpty());
    }

    private static testmethod void testGetProjectRFIScopesByRegionId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false);
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            rifScopeItem.Project__c = testProjectProfileList[0].id;
            rifScopeItem.Region__c = testRegionList[0].id;
            rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getProjectRFIScopesByRegionId(testRegionList[0].id, testProjectProfileList[0].id);

        Test.stopTest();

        System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testGetSignOfSubmittedRFIScopesByProjectId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false);
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            rifScopeItem.Project__c = testProjectProfileList[0].id;
            rifScopeItem.Region__c = testRegionList[0].id;
            rifScopeItem.Submit_Sign_Off__c = true;
            rifScopeItem.Status__c = 'not equals' + RFI_STATUS_SENT;
            rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getSignOfSubmittedRFIScopesByProjectId(testProjectProfileList[0].id);

        Test.stopTest();

        System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testGetApplicationSubmittedRFIScopesByProjectId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false);
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            rifScopeItem.Project__c = testProjectProfileList[0].id;
            rifScopeItem.Region__c = testRegionList[0].id;
            rifScopeItem.Submit_Application__c = true;
            rifScopeItem.Status__c = 'not equals' + RFI_STATUS_SENT;
            rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getApplicationSubmittedRFIScopesByProjectId(testProjectProfileList[0].id);

        Test.stopTest();

//      System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testGetSignOffRFIByProjectIdServiceId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testServiceItemList = new List <Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = serviceItemItem.Project_Profile__c;
                rifScopeItem.Sign_Off_Service_Item__c = serviceItemItem.Id;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
            }
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getSignOffRFIByProjectIdServiceId(testServiceItemList[0].Project_Profile__c, testServiceItemList[0].id);

        Test.stopTest();

//      System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testGetAppWorkPermitRFIByProjectIdServiceId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testServiceItemList = new List <Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = serviceItemItem.Project_Profile__c;
                rifScopeItem.Application_Work_Permit_Service_Item__c = serviceItemItem.Id;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
            }
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getAppWorkPermitRFIByProjectIdServiceId(testServiceItemList[0].Project_Profile__c, testServiceItemList[0].id);

        Test.stopTest();

//      System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testAppPlanApproveRFIScopesByProjectIdServiceId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testServiceItemList = new List <Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = serviceItemItem.Project_Profile__c;
                rifScopeItem.Application_Service_Item__c = serviceItemItem.Id;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
            }
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getAppPlanApproveRFIScopesByProjectIdServiceId(testServiceItemList[0].Project_Profile__c, testServiceItemList[0].id);
            //for coverage
            Set<Id> test1 = RFIScopeServices.getRFIScopeIdsByServiceItemIds(new Set<Id>{testServiceItemList[0].Id});
            Set<Id> test2 = RFIScopeServices.getRFIScopeIdsByServiceItemIds(null);
            Set<Id> test3 = RFIScopeServices.getRFIScopeIdsByServiceItemId(null);
            Set<Id> test4 = RFIScopeServices.getRFIScopeIdsByServiceItemId(testServiceItemList[0].Id);

        Test.stopTest();

//      System.assert(!resultRFIScopeList.isEmpty());
    }

    private static testmethod void testGetProjectRFIScopesByProjectId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false);
        for (RFI_Scope__c rifScopeItem : testRFIScopeList){
            rifScopeItem.Project__c = testProjectProfileList[0].id;
            rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);

        Test.startTest();

            RFI_Scope__c resultRFIScopeRecord = RFIScopeServices.getRFIScopeById(resultRFIScopeList[0].Id);
            List<RFI_Scope__c> rfiIds         = RFIScopeServices.getRFIScopesOrderedByGroupNumber(testProjectProfileList[0].id);

        Test.stopTest();

        System.assert(resultRFIScopeRecord != null);
        System.assertEquals(resultRFIScopeList[0].id, resultRFIScopeRecord.Id);
        
    }

    private static testmethod void testGetProjectRFIScopesByProjectIdAndRosterId(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = projectRosterItem.id;
                rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                rifScopeItem.Status__c = RFI_STATUS_SENT;
                rifScopeItem.Submit_Application__c = true;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
            }
        }
        insert testRFIScopeList;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();

            resultRFIScopeList = RFIScopeServices.getProjectRFIScopesByProjectIdAndRosterId(new Set<Id>{testProjectRosterList[0].Id}, null, testRegionList[0].Name);

        Test.stopTest();
    }

    private static testmethod void testGetRFIScopesById(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        testRegionList[0].Name = RegionServices.REGION_NAME_NY;
        update testRegionList;
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = projectRosterItem.id;
                rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                rifScopeItem.Status__c = RFI_STATUS_SENT;
                rifScopeItem.Submit_Application__c = true;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
                testRFIScopeList.add(rifScopeItem);
            }
        }
        insert testRFIScopeList;

        RFI_Scope__c resultRFIScope;

        Test.startTest();

            resultRFIScope = RFIScopeServices.getRFIScopesById(testRFIScopeList[0].Id, RegionServices.REGION_NAME_NY);

        Test.stopTest();
    }

    private static testmethod void testGetProjectRFIScopesByProjectIdAndRosterIdWithEmptyInputSet(){
        prepareRecordTypePickListValuesForTest();
        setupData();
        createRegionRFIScopeForTest();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        createProjectRosterForTest();
        testRFIScopeList = new List<RFI_Scope__c>();
        for (Project_Roster__c projectRosterItem : testProjectRosterList){
            for (RFI_Scope__c rifScopeItem : TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, false)){
                rifScopeItem.Project__c = projectRosterItem.id;
                rifScopeItem.Project__c = projectRosterItem.Project_Profile__c;
                rifScopeItem.Status__c = RFI_STATUS_SENT;
                rifScopeItem.Submit_Application__c = true;
                rifScopeItem.RecordTypeId = rfiScopeStandardRFIScopeRecordTypeId;
            }
        }
        insert testRFIScopeList;

        String errorString;

        List<RFI_Scope__c> resultRFIScopeList;

        Test.startTest();
            try{
                resultRFIScopeList = RFIScopeServices.getProjectRFIScopesByProjectIdAndRosterId(new Set<Id>(), null, testRegionList[0].Name);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testGetRFIScopeById(){
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);

        RFI_Scope__c resultRFIScopeRecord;

        Test.startTest();

            resultRFIScopeRecord = RFIScopeServices.getRFIScopeById(testRFIScopeList[0].id);

        Test.stopTest();

        System.assert(resultRFIScopeRecord != null);
        System.assertEquals(testRFIScopeList[0].id, resultRFIScopeRecord.Id);
    }
    
    private static testmethod void testGetOrderedRFIScopeById(){
        Set<Id> rfiIds = new Set<Id>();
        
        testRFIScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE_RFI_SCOPE, true);
        
        for (RFI_Scope__c rfi : testRFIScopeList) {
            rfiIds.add(rfi.Id);
        } 

        Test.startTest();

            List<RFI_Scope__c> resultRFIScopeRecords = RFIScopeServices.getRFIScopesSiteOrderedByGroupNumber(rfiIds);

        Test.stopTest();

        System.assert(resultRFIScopeRecords != null);
    
    }
    
    private static testmethod void testStaticMethods() {
        RFIScopeServices.createRFIForChangeOrder(null);
        
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service    = new Service_Item__c();
        Project_Profile__c project = new Project_Profile__c();
        Decimal groupNumber        = 1;
        Id standardRecordTypeId    = null;
        Map<Decimal, List<Service_Item__c>> groupMap = new Map<Decimal, List<Service_Item__c>>();
        groupMap.put(groupNumber, new List<Service_Item__c>());
        
        RFI_Scope__c rfiItem = RFIScopeServices.createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        groupMap.get(groupNumber).add(service);
        rfiItem = RFIScopeServices.createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.SINGLE_WORK_PERMIT);
        Service_Item__c service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION);
        groupMap.get(groupNumber).add(service2);
        rfiItem = RFIScopeServices.createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.SINGLE_WORK_PERMIT);
        groupMap = new Map<Decimal, List<Service_Item__c>>();
        groupMap.put(groupNumber, new List<Service_Item__c>());
        groupMap.get(groupNumber).add(service);
        rfiItem = RFIScopeServices.createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.SINGLE_LETTER_OF_COMPLETION);
        groupMap = new Map<Decimal, List<Service_Item__c>>();
        groupMap.put(groupNumber, new List<Service_Item__c>());
        groupMap.get(groupNumber).add(service);
        rfiItem = RFIScopeServices.createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
//        RFI_Scope__c rfi1 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_NY);
//        RFI_Scope__c rfi2 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_CT);
                
    }
    
    private static testmethod void testLongIslandMethods() {
        RFIScopeServices.createRFIForChangeOrder(null);
        
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service    = new Service_Item__c();
        Project_Profile__c project = new Project_Profile__c();
        Decimal groupNumber        = 1;
        Id standardRecordTypeId    = null;
        Map<Decimal, List<Service_Item__c>> groupMap = new Map<Decimal, List<Service_Item__c>>();
        groupMap.put(groupNumber, new List<Service_Item__c>());
        
        RFI_Scope__c rfiItem = RFIScopeServices.createLongIslandRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        groupMap.get(groupNumber).add(service);
        rfiItem = RFIScopeServices.createLongIslandRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        Service_Item__c service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_APPROVAL_COMPLETION);
        groupMap.get(groupNumber).add(service2);
        rfiItem = RFIScopeServices.createLongIslandRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        Service_Item__c service3 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION);
        groupMap.get(groupNumber).add(service3);
        rfiItem = RFIScopeServices.createLongIslandRFI(rfi, service3, project, groupNumber, standardRecordTypeId, groupMap);
        
        
//        RFI_Scope__c rfi1 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_LI);
//        RFI_Scope__c rfi2 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_NJ);
                
    }
    
    private static testmethod void testNewJersyMethods() {
        RFIScopeServices.createRFIForChangeOrder(null);
        
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service    = new Service_Item__c();
        Project_Profile__c project = new Project_Profile__c();
        Decimal groupNumber        = 1;
        Id standardRecordTypeId    = null;
        Map<Decimal, List<Service_Item__c>> groupMap = new Map<Decimal, List<Service_Item__c>>();
        groupMap.put(groupNumber, new List<Service_Item__c>());
        
        RFI_Scope__c rfiItem = RFIScopeServices.createNewJerseyRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        groupMap.get(groupNumber).add(service);
        rfiItem = RFIScopeServices.createNewJerseyRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        Service_Item__c service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        groupMap.get(groupNumber).add(service2);
        rfiItem = RFIScopeServices.createNewJerseyRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        Service_Item__c service3 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIIFCATE_OF_COMPLETION);
        groupMap.get(groupNumber).add(service3);
        rfiItem = RFIScopeServices.createNewJerseyRFI(rfi, service3, project, groupNumber, standardRecordTypeId, groupMap);
        
//        RFI_Scope__c rfi1 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_LI);
//        RFI_Scope__c rfi2 = RFIScopeServices.createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap, RegionServices.REGION_NAME_NJ);
                
    }
    
    private static testmethod void testGetRFIScopesByIdEmptyParameter() {
        try {
            RFI_Scope__c rfi = RFIScopeServices.getRFIScopesById(null, '');
        
        } catch (Exception ex) {
        
        }
        List<RFI_Scope__c> rfis = RFIScopeServices.getRFIScopesOrderedByGroupNumber(null);
        Boolean isExistRecievedRFIScopesByIds = RFIScopeServices.isExistRecievedRFIScopesByIds(null);
    
    }
    
    private static testmethod void testIsExistRecievedRFIScopesByIdsEmptyParameter() {
        Boolean isExistRecievedRFIScopesByIds = RFIScopeServices.isExistRecievedRFIScopesByIds(null);
    
    }
    
    private static testmethod void testIsExistRecievedRFIScopesByIds() {
        RFI_Scope__c rfi = new RFI_Scope__c(Last_RFI_Received__c = datetime.now(), Last_SignOff_RFI_Received__c = datetime.now());
        insert rfi;
        Boolean isExistRecievedRFIScopesByIds = RFIScopeServices.isExistRecievedRFIScopesByIds(new List<String> { String.valueOf(rfi.Id)});
    
    }
    
    private static testmethod void testGetProjectIdToGroupNumbers() {
        Map<Id, Set<Decimal>> ProjectIdToGroupNumbers = RFIScopeServices.getProjectIdToGroupNumbers(null);
    
    }
    
    private static testmethod void testPopulateServiceItemsLookUpForAdditionalRFI() {
        List<Service_Item__c> serviceList  = new List<Service_Item__c>();
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI(serviceList, RegionServices.REGION_NAME_CT, new RFI_Scope__c());
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI(serviceList, RegionServices.REGION_NAME_LI, new RFI_Scope__c());
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI(serviceList, RegionServices.REGION_NAME_NJ, new RFI_Scope__c());
       
    }
    
    private static testmethod void testCompleteTasks() {
        RFIScopeServices.completeTasks(new List<RFI_Scope__c>(), new Map<Id, RFI_Scope__c>());
       
    }

    private static testmethod void testcreateWest_CT_MA_RFI() {
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service;
        Service_Item__c service2;
        Service_Item__c service3;
        Project_Profile__c project = new Project_Profile__c();
        Decimal groupNumber        = 1;
        Id standardRecordTypeId    = null;
        Map<Decimal, List<Service_Item__c>> groupMap = new Map<Decimal, List<Service_Item__c>>();
        
        groupMap.put(groupNumber, new List<Service_Item__c>());
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        groupMap.get(groupNumber).add(service);
        RFI_Scope__c rfi1 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY;
        RFI_Scope__c rfi2 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY;
        RFI_Scope__c rfi3 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        groupMap.get(groupNumber).add(service2);
        RFI_Scope__c rfi4 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        RFI_Scope__c rfi5 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        RFI_Scope__c rfi6 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        RFI_Scope__c rfi7 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);

        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        RFI_Scope__c rfi8 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service3 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        groupMap.get(groupNumber).add(service3);
        RFI_Scope__c rfi9 = RFIScopeServices.createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
        
        
    }
    
    private static testmethod void testPopulateServiceItemsLookUpForAdditionalRFI_West_CT_MA() {
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service;
        Service_Item__c service2;
        Service_Item__c service3;
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        serviceItems.add(service);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        serviceItems.add(service2);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);

        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
        
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.TEMPORARY_CERTIFICATE_OF_OCCUPANCY);
        service3 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY);
        serviceItems.add(service3);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, rfi);
            
    }
    
    private static testmethod void testPopulateServiceItemsLookUpForAdditionalRFI_LI() {
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service;
        Service_Item__c service2;
        Service_Item__c service3;
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        serviceItems.add(service);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFILongIsland(serviceItems, rfi);

        service.Category__c = RFIScopeServices.APPLICATION_FILING;
        service.Type__c = RFIScopeServices.SINGLE_WORK_PERMIT;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFILongIsland(serviceItems, rfi);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFILongIsland(serviceItems, rfi);
            
    }
    
    private static testmethod void testPopulateServiceItemsLookUpForAdditionalRFI_NJ() {
        RFI_Scope__c rfi           = new RFI_Scope__c();
        Service_Item__c service;
        Service_Item__c service2;
        Service_Item__c service3;
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        serviceItems.add(service);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, rfi);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, rfi);
        
        service.Category__c = RFIScopeServices.APPLICATION_SIGN_OFF;
        service.Type__c = RFIScopeServices.CERTIFICATE_OF_OCCUPANCY;
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, rfi);
        
        service = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_FILING, Type__c = RFIScopeServices.PLAN_APPROVAL);
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIIFCATE_OF_APPROVAL);
        serviceItems.add(service2);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, rfi);
        
        service2 = new Service_Item__c(Category__c = RFIScopeServices.APPLICATION_SIGN_OFF, Type__c = RFIScopeServices.CERTIIFCATE_OF_COMPLETION);
        RFIScopeServices.populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, rfi);
            
    }
    
}