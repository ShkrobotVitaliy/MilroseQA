@isTest
private class TestVendorRequestServices {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_VENDOR_REQUEST = 3;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;

    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Vendor_Request__c> testVendorList;

    private static Id taskItemMilestoneRecordTypeId;
    private static Id taskItemVendorRequestRecordTypeId;

    private static void getRecordTypes(){
        //get Task Item Record Type
        Map<String, Id> taskItemRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c');
        taskItemVendorRequestRecordTypeId = taskItemRecordTypesMap.get(VendorRequestServices.VENDOR_REQUEST_RECORD_TYPE_NAME);
        taskItemMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
    }

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        testProductionManagerUser = TestingUtils.testProductionManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static testMethod void testCreateVendorReimbursableLineItemEmptyParameter() { 
        VendorRequestServices.createVendorReimbursableLineItem(null);
    
    }
    
    private static testMethod void testCreateVendorReimbursableLineItemEmpty() { 
    
    }
    
    private static testMethod void testNewInstanceEmptyParameter() { 
        String errorString;

        Vendor_Request__c vendor;

        try {
            vendor = VendorRequestServices.newInstance(null);
        } catch (Exception ex) {
            errorString = ex.getMessage();
        }
        System.assert(!String.isEmpty(errorString));
        System.assertEquals(null, vendor);
    }

    private static testMethod void testNewInstance() { 
        Task_Item__c taskItem = new Task_Item__c();
        Vendor_Request__c vendor = VendorRequestServices.newInstance(taskItem);
        System.assert(vendor != null);
    }
    
    private static testMethod void testgetVendorsByTaskItemIdEmptyParameter() { 
        String errorString;

        List<Vendor_Request__c> vendors;

        try {
            vendors = VendorRequestServices.getVendorsByTaskItemId(null);
        } catch (Exception ex) {
            errorString = ex.getMessage();
        }

        System.assert(!String.isEmpty(errorString));
        System.assertEquals(null, vendors);
    }
    
    private static testMethod void testgetVendorsByTaskItemId() {
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        testVendorList = new List<Vendor_Request__c>();

        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Vendor_Request__c vendorRequestItem : TestingUtils.createVendorRequestList(NUMBER_TO_CREATE_VENDOR_REQUEST, false)){
                vendorRequestItem.Task_Item__c = taskItemItem.Id;
                testVendorList.add(vendorRequestItem);
            }
        }
        insert testVendorList;

        List<Vendor_Request__c> resultVendorRequestList;

        Test.startTest();
            resultVendorRequestList = VendorRequestServices.getVendorsByTaskItemId(testTaskItemList[0].Id);
        Test.stopTest();

        System.assert (resultVendorRequestList != null);
        System.assert (!resultVendorRequestList.isEmpty());
        for (Vendor_Request__c vendorRequestItem : resultVendorRequestList){
            System.assertEquals (testTaskItemList[0].Id, vendorRequestItem.Task_Item__c);
        }
    }
    
    private static testMethod void testcreateVendorReimbursableLineItem() { 
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Map<Id, List<Task_Item__c>> projectProfileWithMilestonMap = new Map<Id, List<Task_Item__c>>();
        List<Task_Item__c> milestoneTaskItem = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Name = TaskManagementServices.MILESTONE_PROJECT_START;
                taskItemItem.recordTypeId = taskItemMilestoneRecordTypeId;
                milestoneTaskItem.add(taskItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Name = 'Project End';
                taskItemItem.recordTypeId = taskItemMilestoneRecordTypeId;
                milestoneTaskItem.add(taskItemItem);
            }
        }
        insert milestoneTaskItem;

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
            Integer sequenceNumberValue = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Sequence_Number__c = sequenceNumberValue;
                taskItemItem.Expected_Start_Date__c = Datetime.now();
                taskItemItem.Planned_Start_Date__c = Datetime.now();
                taskItemItem.Expected_Duration__c = '1d';
                taskItemItem.Planned_Durration__c = '1d';
                taskItemItem.Expected_End_Date__c = DateTime.now();
                taskItemItem.Planned_End_Date__c = DateTime.now();
                taskItemItem.Status__c = '';
                taskItemItem.RecordTypeId = TestingUtils.getRecordTypeIdByObjecttypenameRecordTypeName('Task_Item__c', VendorRequestServices.VENDOR_REQUEST_RECORD_TYPE_NAME);
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testVendorList = new List<Vendor_Request__c>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            for (Vendor_Request__c vendorRequestItem : TestingUtils.createVendorRequestList(NUMBER_TO_CREATE_VENDOR_REQUEST, false)){
                vendorRequestItem.Task_Item__c = taskItemItem.Id;
                vendorRequestItem.Pass_Through_Expense__c = true;
                vendorRequestItem.Is_Reimbursable_Line_Item_Created__c = false;
                testVendorList.add(vendorRequestItem);
            }
        }
        insert testVendorList;

        Test.startTest();

            VendorRequestServices.createVendorReimbursableLineItem(new Map<Id, Task_Item__c>(testTaskItemList).keySet());

        Test.stopTest();

        System.assertEquals(new Map<Id, Vendor_Request__c>(testVendorList).keySet(), new Map<Id, Vendor_Request__c>([SELECT Id, Is_Reimbursable_Line_Item_Created__c FROM Vendor_Request__c WHERE Id IN : testVendorList AND Is_Reimbursable_Line_Item_Created__c = true]).keySet());

        List<Billing_Line_Item__c> resultBLIList = [SELECT Id FROM Billing_Line_Item__c WHERE Project_Profile__c IN : testProjectProfileList];
        System.assert(!resultBLIList.isEmpty());
    }
}