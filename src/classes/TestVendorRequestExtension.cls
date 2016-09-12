@isTest
private class TestVendorRequestExtension {
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static List<Task_Item__c> testTaskItemList;

    private static ApexPages.StandardController testController;
    private static VendorRequestExtension testVendorRequestExtension;

    private static void setupData (){
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
    }

    private static void createControllerForTest(Task_Item__c taskItemItem){
        Test.setCurrentPageReference(Page.VendorRequestOnTaskItemLevel);
        testController = new ApexPages.StandardController( taskItemItem );
    }

    private static testMethod void testVendorRequestExtension() {
        setupData();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        createControllerForTest(testTaskItemList[0]);

        Test.startTest();
            testVendorRequestExtension = new VendorRequestExtension(testController);
            System.assert( testVendorRequestExtension.vendorRequests != null );
            Boolean test1 = testVendorRequestExtension.isNotifyVendor;
            testVendorRequestExtension.isNotifyVendor = true;
            Boolean test11 = testVendorRequestExtension.isNotifyVendor;
            Boolean test2 = testVendorRequestExtension.isRequestedVendor;
            testVendorRequestExtension.isRequestedVendor = true;
            Boolean test22 = testVendorRequestExtension.isRequestedVendor;
            String emailType = testVendorRequestExtension.emailTypeRecord;
            List<Vendor_Request__c> test3 = testVendorRequestExtension.vendorsToUpdate;
            testVendorRequestExtension.saveEmailAddress('test@gmail.com', 'test');
            
            //testVendorRequestExtension.getEmailAddrressToSend();
            System.assert( testVendorRequestExtension.draftTemplateName != null );
            System.assert( testVendorRequestExtension.drawloopName != null );
            System.assert( testVendorRequestExtension.vendors != null );
            testVendorRequestExtension.addVendor();
            testVendorRequestExtension.saveChanges();
            testVendorRequestExtension.showOnlyAcceptedActivities();
            testVendorRequestExtension.showTemplateEditing();
            testVendorRequestExtension.notifyVendor();
            testVendorRequestExtension.updateCCEmailsAddressForDrawLoop();
            testVendorRequestExtension.updateAfterSend();
            testVendorRequestExtension.passThroughExpenseAction();
            testVendorRequestExtension.fillScheduledDate();
            testVendorRequestExtension.fillProposalReceivedDate();
            List<Id> attachmentIds = testVendorRequestExtension.attachmentIds;
            
            testVendorRequestExtension.taskItem.Show_only_Accepted_Activities__c = true;
            testVendorRequestExtension.showOnlyAcceptedActivities();
        Test.stopTest();

    }
    
    private static testMethod void testProjectProperty() {
        Test.setCurrentPageReference(Page.VendorRequestOnTaskItemLevel);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );
        testVendorRequestExtension = new VendorRequestExtension(testController);
        
        Test.startTest();
            Project_Profile__c project = new Project_Profile__c();
            insert project;
            Task_Item__c taskItem = new Task_Item__c(Project_Profile__c = project.Id);
            insert taskItem;
            testVendorRequestExtension.taskItem = taskItem;
            Project_Profile__c p1 = testVendorRequestExtension.project;
        Test.stopTest();
        
    }
    
    private static testMethod void testGetReimbursableLineItemForPassExpanse() {
        Test.setCurrentPageReference(Page.VendorRequestOnTaskItemLevel);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );
        testVendorRequestExtension = new VendorRequestExtension(testController);
        
        Test.startTest();
            Project_Profile__c project = new Project_Profile__c();
            insert project;
            Task_Item__c taskItem = new Task_Item__c(Project_Profile__c = project.Id, Actual_Start_Date__c = datetime.now(), Actual_End_Date__c = datetime.now());
            insert taskItem;
            testVendorRequestExtension.taskItem = taskItem;
            Project_Profile__c p1 = testVendorRequestExtension.project;
            
            Vendor_Request__c vendor = new Vendor_Request__c(Task_Item__c = taskItem.Id, Pass_Through_Expense__c = true);
            insert vendor;
            
            testVendorRequestExtension.saveChanges();
            
            testVendorRequestExtension.selectedVendorId = vendor.Id;
            testVendorRequestExtension.fillScheduledDate();
            testVendorRequestExtension.fillProposalReceivedDate();
            
            testVendorRequestExtension.vendorsToUpdate = null;
            testVendorRequestExtension.updateAfterSend();
        Test.stopTest();
        
    }
    
    private static testMethod void testAddVendorException() {
        Test.setCurrentPageReference(Page.VendorRequestOnTaskItemLevel);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );
        testVendorRequestExtension = new VendorRequestExtension(testController);
        
        Test.startTest();
            testVendorRequestExtension.taskItem = null;
            testVendorRequestExtension.addVendor();
            
            Task_Item__c taskItem = new Task_Item__c(Actual_Start_Date__c = datetime.now(), Actual_End_Date__c = datetime.now());
            insert taskItem;
            
            taskItem.Actual_Start_Date__c = null;
            testVendorRequestExtension.taskItem = taskItem;
            
            testVendorRequestExtension.updateCCEmailsAddressForDrawLoop();
            
            testVendorRequestExtension.saveEmailAddress('test@gmail.com', 'test');
        Test.stopTest();
    }

}