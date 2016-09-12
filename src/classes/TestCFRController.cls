@isTest
private class TestCFRController {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 1;
    private static final Integer SERVICE_GROUP_NUMBER = 1;
    private static final String TEST_MUNICIPAL_AGENCY_ID_VALUE = '1';
    private static final String SCROLE_STRING_VALUE = '_';
    private static final String SERVICE_CATEGORY_APPLICATION_SIGN_OFF = 'Application Signoff';
    private static final String SERVICE_CATEGORY_AMENDMENT_APPLICATION_FILING = 'Amendment-Application Filing';
    private static final String SERVICE_TYPE_ASBESTOS_ASSESSMENT = 'Asbestos Assessment';
    private static final String TRACK_FORM_PROCESSING_THROUGH_AUTHORITY_TASK_NAME = 'Track Form Processing through Authority';
    private static final String SUBMIT_FILING_PACKAGE_TO_AUTHORITY_TASK_NAME = 'Submit Filing Package to Authority';
    private static final String PROJECT_END_MILESTONE_TASK_NAME = 'Milrose Project End';
    private static final String SERVICE_FLOOR_NAME = 'Test Floor';
    private static final String SUBTYPE_NAME = 'Test Subtype';

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;

    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;

    private static Map<String, Id> taskItemRecordTypesMap;

    private static PageReference testPage;
    private static CFRController testController;

    private static void setupGeneralData() {
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;

        TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROPOSAL);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Building__c = testBuildingList[0].Id;
        }
        update testProjectProfileList;

        prepareRecordTypes();
    }

    private static void prepareRecordTypes(){
        taskItemRecordTypesMap = new Map<String, Id>();
        for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Task_Item__c.SObjectType.getDescribe().getRecordTypeInfos()){
            taskItemRecordTypesMap.put(schemaRecordTypeInfoItem.getName(), schemaRecordTypeInfoItem.getRecordTypeId());
        }
    }

    private static void prepareServiceWithTasks(){
        List<Task_Item__c> testTaskItemMilestoneList = new List<Task_Item__c>();
        Map<Id, Map<String, Task_Item__c>> projectWithMilestoneMap = new Map<Id, Map<String, Task_Item__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectWithMilestoneMap.put(projectProfileItem.Id, new Map<String, Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Name = TaskManagementServices.MILESTONE_PROJECT_START;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
                testTaskItemMilestoneList.add(taskItemItem);
                projectWithMilestoneMap.get(projectProfileItem.Id).put(TaskManagementServices.MILESTONE_PROJECT_START, taskItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Name = PROJECT_END_MILESTONE_TASK_NAME;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
                testTaskItemMilestoneList.add(taskItemItem);
                projectWithMilestoneMap.get(projectProfileItem.Id).put(PROJECT_END_MILESTONE_TASK_NAME, taskItemItem);
            }
        }
        insert testTaskItemMilestoneList;

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            //first condition
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Successor_Milestone__c = PROJECT_END_MILESTONE_TASK_NAME;
                serviceItemItem.Proposal__c = projectProfileItem.Proposal__c;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Is_Amendmend_Deleted__c = false;
                serviceItemItem.Category__c = ServiceItemServices.CATEGORY_APPLICATION_FILING;
                serviceItemItem.Type__c = ServiceItemServices.TYPE_PLAN_APPROVAL;
                serviceItemItem.Service_Group__c = SERVICE_GROUP_NUMBER;
                serviceItemItem.Municipal_Agency_ID__c = TEST_MUNICIPAL_AGENCY_ID_VALUE;
                serviceItemItem.Floor__c = SERVICE_FLOOR_NAME;
                serviceItemItem.Subtype__c = SUBTYPE_NAME;
                testServiceItemList.add(serviceItemItem);
            }
            //second condition
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Successor_Milestone__c = PROJECT_END_MILESTONE_TASK_NAME;
                serviceItemItem.Proposal__c = projectProfileItem.Proposal__c;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Is_Amendmend_Deleted__c = false;
                serviceItemItem.Category__c = SERVICE_CATEGORY_AMENDMENT_APPLICATION_FILING;
                serviceItemItem.Type__c = SERVICE_TYPE_ASBESTOS_ASSESSMENT;
                serviceItemItem.Service_Group__c = SERVICE_GROUP_NUMBER;
                serviceItemItem.Municipal_Agency_ID__c = TEST_MUNICIPAL_AGENCY_ID_VALUE;
                serviceItemItem.Floor__c = SERVICE_FLOOR_NAME;
                serviceItemItem.Subtype__c = SUBTYPE_NAME;
                testServiceItemList.add(serviceItemItem);
            }
            //additional Service Items for test
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Successor_Milestone__c = PROJECT_END_MILESTONE_TASK_NAME;
                serviceItemItem.Proposal__c = projectProfileItem.Proposal__c;
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Is_Amendmend_Deleted__c = false;
                serviceItemItem.Category__c = 'test';
                serviceItemItem.Type__c = 'test';
                serviceItemItem.Service_Group__c = SERVICE_GROUP_NUMBER;
                serviceItemItem.Municipal_Agency_ID__c = TEST_MUNICIPAL_AGENCY_ID_VALUE;
                serviceItemItem.Floor__c = SERVICE_FLOOR_NAME;
                serviceItemItem.Subtype__c = SUBTYPE_NAME;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            Integer sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(TaskManagementServices.MILESTONE_PROJECT_START).Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(PROJECT_END_MILESTONE_TASK_NAME).Id : null;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Name = TaskItemServices.PICKUP_ANALIZE_TASK_NAME;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TaskItemServices.PICKUP_ANALIZE_TASK_NAME);
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
            sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(TaskManagementServices.MILESTONE_PROJECT_START).Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(PROJECT_END_MILESTONE_TASK_NAME).Id : null;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Name = TRACK_FORM_PROCESSING_THROUGH_AUTHORITY_TASK_NAME;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TRACK_FORM_PROCESSING_THROUGH_AUTHORITY_TASK_NAME);
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
            sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(TaskManagementServices.MILESTONE_PROJECT_START).Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(PROJECT_END_MILESTONE_TASK_NAME).Id : null;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Name = TaskItemServices.REQUEST_FOR_INFORMATION_TASK_NAME;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TaskItemServices.REQUEST_FOR_INFORMATION_TASK_NAME);
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
            sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(TaskManagementServices.MILESTONE_PROJECT_START).Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM ? projectWithMilestoneMap.get(serviceItemItem.Project_Profile__c).get(PROJECT_END_MILESTONE_TASK_NAME).Id : null;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Name = TaskItemServices.REQUEST_FOR_INFORMATION_TASK_NAME;
                taskItemItem.RecordTypeId = taskItemRecordTypesMap.get(TaskItemServices.REQUEST_FOR_INFORMATION_TASK_NAME);
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
        }
        insert testTaskItemList;
    }

    private static void populateDatesForTaskProject(){
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        update testProjectProfileList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Expected_Start_Date__c = Datetime.now();
            taskItemItem.Expected_End_Date__c = Datetime.now();
            taskItemItem.Expected_Duration__c = '1m';
            taskItemItem.Planned_Start_Date__c = Datetime.now();
            taskItemItem.Planned_End_Date__c = Datetime.now();
            taskItemItem.Planned_Durration__c = '1m';
            taskItemItem.Actual_Start_Date__c = Datetime.now();
            taskItemItem.Status__c = 'Started';
        }
        update testTaskItemList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            if (taskItemItem.Name == TaskItemServices.PICKUP_ANALIZE_TASK_NAME) taskItemItem.Status__c = 'Approved';
            if (taskItemItem.Name == TRACK_FORM_PROCESSING_THROUGH_AUTHORITY_TASK_NAME) taskItemItem.Status__c = 'Response Received';
            taskItemItem.Actual_End_Date__c = Datetime.now();
        }
    }

    private static void preparePageController (Project_Profile__c projectProfile){
        testPage = Page.CFR;
        Test.setCurrentPage(testPage);
        if ( projectProfile != null ){
            ApexPages.currentPage().getParameters().put('p1', SCROLE_STRING_VALUE + projectProfile.Id);
            ApexPages.currentPage().getParameters().put('p3', SCROLE_STRING_VALUE + projectProfile.Primary_Company_Name__c);
            ApexPages.currentPage().getParameters().put('p2', SCROLE_STRING_VALUE + projectProfile.Building__c);
            ApexPages.currentPage().getParameters().put('p4', SCROLE_STRING_VALUE + projectProfile.Billing_Company_Name__c);
            ApexPages.currentPage().getParameters().put('p5', SCROLE_STRING_VALUE + projectProfile.Accounting_Contact_Company__c);
        }
        testController = new CFRController();
    }

    private static testmethod void testCreateController(){
        setupGeneralData();

        Test.startTest();
            preparePageController(testProjectProfileList[0]);
        Test.stopTest();

        System.assert(testController != null);
    }

    private static testmethod void testCreateControllerWithCreatedLevel(){
        setupGeneralData();
        prepareServiceWithTasks();

        Test.startTest();
            preparePageController(testProjectProfileList[0]);
        Test.stopTest();

        System.assert(testController != null);
    }
}