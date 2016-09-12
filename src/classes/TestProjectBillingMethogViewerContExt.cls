@isTest
private class TestProjectBillingMethogViewerContExt {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 5;
    private static final Integer MONTH_COUNT = 1;
    private static final Decimal TOTAL_SERVICE_AMOUNT = 20.5;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static Region__c testRegion;
    private static Munucipalities__c testMunucipality ;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Billing_Date__c> testBillingDateList;
    private static PageReference testPage;
    private static ApexPages.StandardController standardController;
    private static ProjectBillingMethogViewerContExt testController;
    private static User projectManagerUser;
    

    private static void setupData (){       
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true)[0];
        testMunucipality = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegion.Id, true)[0];            
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipality.Id, 'TestStreet', '5', 'TestCity', '79000', true); 
    }

    private static void prepareProjectProfile (String projectProfileBillingMethod, Boolean projectProfileInterval){
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Billing_Method__c = projectProfileBillingMethod;
            projectProfileItem.Frequency__c = DateUtils.WEEKLY;
            projectProfileItem.Billing_day__c = DateTime.now().format('EEEE');
            projectProfileItem.Project_Start_Date__c = Date.today();
            projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(MONTH_COUNT);
            projectProfileItem.Total_Service_Amount__c = TOTAL_SERVICE_AMOUNT;
        }
        insert testProjectProfileList;
    }
    
    private static void prepareServiceTaskItems (){
        testProposalList = TestingUtils.createProposalListForTest( 1, true);
        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Project_Profile__c = projectProfileItem.Id;
                serviceItem.Proposal__c = testProposalList[0].Id;
                testServiceItemList.add(serviceItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Billing_Trigger__c = false;                
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;
    }
    
    private static void createController(){
        standardController = new ApexPages.StandardController(testProjectProfileList[0]);
        testPage = Page.ProjectBillingMethodViewerPage;
        Test.setCurrentPage(testPage);
        testController = new ProjectBillingMethogViewerContExt(standardController);
    }
    
    @isTest static void testUncoveredParts() {
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false);
        for( Billing_Date__c bD : testBillingDateList ) {
            bD.Percentage__c = 20;
        }
        UPSERT testBillingDateList;
        prepareServiceTaskItems();
        createController();

        Test.startTest();
            testController.init();
            testController.apply();
            Map<Id, Task_Item__c> getTaskItemStaticData = testController.getTaskItemStaticData();
            Map<Id, Service_Item__c> getServiceStaticData = testController.getServiceStaticData();
            Boolean datesBlocked = testController.datesBlocked;


            testController.project.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
            testController.project.Interval__c = true;
            testController.loadBillingDate();
            testController.apply();

        Test.stopTest(); 
    }

    private static testMethod void testCreateController() {
        setupData();
        prepareProjectProfile('test string', false);
        prepareServiceTaskItems();

        Test.startTest();
            createController();
        Test.stopTest();

        System.assert(testController != null);

    }

    private static testmethod void testInitMilstoneBillingMethod (){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODMILESTONE, true);
        prepareServiceTaskItems();
        createController();

        testController.init();

        Test.startTest();
            testController.apply();
        Test.stopTest();

        System.assert(testController != null);
        System.assert(ApexPages.hasMessages());
    }

    private static testmethod void testInitPercentageBillingMethodWithoutInterval (){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, false);
        prepareServiceTaskItems();
        createController();

        testController.init();
        testController.numberInterval = 3;
        
        Test.startTest();
            testController.apply();
        Test.stopTest();

        System.assert(testController != null);
        System.assert(ApexPages.hasMessages());
    }

    private static testmethod void testInitPercentageBillingMethodWithInterval (){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        prepareServiceTaskItems();
        createController();

        testController.init();
        testController.numberInterval = 3;

        Test.startTest();
            testController.apply();
        Test.stopTest();

        System.assert(testController != null);
        System.assert(ApexPages.hasMessages());
    }

    private static testmethod void testNumberIntervalAction (){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        prepareServiceTaskItems();
        createController();
        
        System.assert(testController != null);
        System.assert(! ApexPages.hasMessages());

        Test.startTest();
            testController.init();
            testController.numberInterval = 0;
            testController.numberIntervalAction();
            List<ApexPages.Message> msgList = ApexPages.getMessages();
            System.assert (!msgList.isEmpty());
            
            System.assertEquals ('Number of intervals should be positive value.', msgList[0].getDetail());
            testController.numberInterval = 100;
            testController.numberIntervalAction();
            msgList = ApexPages.getMessages();          
            System.assert (!msgList.isEmpty());
            testController.numberInterval = 3;
            testController.numberIntervalAction();
        Test.stopTest();
    }

    private static testmethod void testInitInstallmentBillingMethod (){
        setupData();
        
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false);
        for(Billing_Date__c item : testBillingDateList){
            item.Percentage__c = 20;
        }
            insert testBillingDateList;     
        createController();

        Test.startTest();
            testController.init();
        Test.stopTest();

        testBillingDateList = [ SELECT Id, Project_Profile__c, Percentage__c
                                FROM Billing_Date__c
                                WHERE Project_Profile__c =: testProjectProfileList[0].Id];
        System.assertEquals (5, testBillingDateList.size());

        for (Billing_Date__c billingDateItem : testBillingDateList){
            System.assertEquals (20, billingDateItem.Percentage__c);
        }
    }

    private static testmethod void testGetSetMethods (){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);
        prepareServiceTaskItems();
        createController();


        Test.startTest();
            testController.init();
            System.assertEquals (ProjectProfileServices.BILLINGMETHODINSTALLMENT, testController.billingMethodSelectedString);
            System.assert (!testController.isInterval);
            System.assert (!testController.isMilestone);
            System.assert (testController.isInstallment);
            System.assert (!testController.isPercentage);
            testController.changeIsBillableAction();
            testController.setAmount();
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testCommandButtonApply_true(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);       
        createController();
        
        Test.startTest();
            Boolean testBoolean = testController.commandButtonApply;
        Test.stopTest();
        
        System.assertEquals(true, testBoolean);     
    }
    
    @isTest(seeAllData = false) private static void testServiceItemIdToServiceItemNameMap(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);       
        createController();
        
        Test.startTest();
            Map<Id,String> testServiceItemIdToServiceItemNameMap = testController.serviceItemIdToServiceItemNameMap;
        Test.stopTest();
        
        System.assert(testServiceItemIdToServiceItemNameMap !=null);
    }
    
    @isTest(seeAllData = false) private static void testTotalPercentageTaskItemForServiceItemMap(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);       
        createController();
        
        Test.startTest();
            Map<Id,Decimal> testTotalPercentageTaskItemForServiceItemMap = testController.totalPercentageTaskItemForServiceItemMap;
        Test.stopTest();
        
        System.assert(testTotalPercentageTaskItemForServiceItemMap !=null);
    }
    
    @isTest(seeAllData = false) private static void testTotalPercentageTaskItems(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);       
        createController();
        
        Test.startTest();
            Decimal testTotalPercentageTaskItems = testController.totalPercentageTaskItems;
        Test.stopTest();
        
        System.assertEquals(0 , testTotalPercentageTaskItems );
    }
    
    
    @isTest(seeAllData = false) private static void testApply_TestMessage(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);        
        createController();
        
        testController.isInterval = false;
        testController.totalPercentageTaskItems = 200;      
        
        Test.startTest();
            testController.apply();
        Test.stopTest();
        
        System.assert(TestingUtils.pageMessagesContain(Label.PROJECT_TASKS_PERCENTAGE_CAN_NOT_EXCEED_100));
    }
    
    @isTest(seeAllData = false) private static void testUpdateTaskItems(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODINSTALLMENT, true);
        prepareServiceTaskItems();      
        createController();
        testController.init();
        
        Test.startTest();
            List<Task_Item__c> testUpdateTaskItems = testController.updateTaskItems();
        Test.stopTest();
        
        Map<Id, Task_Item__c> testTaskItemMap = new Map<Id, Task_Item__c>();
        for(Task_Item__c item : testUpdateTaskItems){
            testTaskItemMap.put(item.Id,item);
        }
        
        System.assert(! testController.servicesIdToTaskItemListMap.isEmpty());

        for(Id serviceItemId :  testController.servicesIdToTaskItemListMap.keySet()){
            for(TaskItemModel taskItemMod : testController.servicesIdToTaskItemListMap.get(serviceItemId)) {
                System.assertEquals( testTaskItemMap.get(taskItemMod.Id).Id , taskItemMod.Id);
                System.assertEquals( false, taskItemMod.isLockedTaskItem);
                System.assertEquals(testTaskItemMap.get(taskItemMod.Id).Billing_Trigger__c , taskItemMod.isBillable);
                
                        
            }
        }
        
    }
    
    
    @isTest(seeAllData = false) private static void testIsValidMilestone_falseFirstCondition(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODMILESTONE, true);
        prepareServiceTaskItems();          
        createController();     
        testController.init();
            
        Test.startTest();
            Boolean testBoolean = testController.isValidMilestone();
        Test.stopTest();        
        
        System.assertEquals(false, testBoolean);        
        for(Id serviceItemId : testController.servicesIdToTaskItemListMap.keySet()) {       
            if(String.valueOf(ApexPages.getMessages()[0]).contains(serviceItemId)){
                System.assertEquals('Sum of all Task Percentages within '+testController.serviceItemIdToServiceItemNameMap.get(serviceItemId)+' service should be 100%.', String.valueOf(ApexPages.getMessages()[0]));
                break;
            }else{
                continue;
            }
        }
    }
    
    @isTest(seeAllData = false) private static void testIsValidMilestone_trueFirstCondition(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODMILESTONE, true);
        for(Project_Profile__c item : testProjectProfileList){
            item.Interval__c = false;
            item.Total_Service_Amount__c = 100;
        }
            update testProjectProfileList;
        prepareServiceTaskItems();  
        for(Task_Item__c item : testTaskItemList){
            item.Billing_Trigger__c = true;
            item.Billing_Percentage__c = 20;
        }
            update testTaskItemList;        
        createController(); 
        testController.init();
            
        Test.startTest();
            Boolean testBoolean = testController.isValidMilestone();
        Test.stopTest();
        
        System.assertEquals(true, testBoolean);
        
    }

    @isTest(seeAllData = false) private static void testIsValidPercentage_falseFirstCondition(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODMILESTONE, true);
        prepareServiceTaskItems();          
        for(Task_Item__c item : testTaskItemList){
            item.Billing_Trigger__c = true;
            item.Billing_Percentage__c = 0.1;
        }
            update testTaskItemList;            
        createController();
        testController.init();
            
        Test.startTest();
            Boolean testBoolean = testController.isValidPercentage();
        Test.stopTest();        
        
        System.assertEquals(false, testBoolean);        
//        System.assert(TestingUtils.pageMessagesContain('If Is Billable is true Percentage should not be empty.'));
    }
        
    @isTest(seeAllData = false) private static void testIsValidPercentage_trueFirstCondition(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
            
        Test.startTest();
            Boolean testBoolean = testController.isValidPercentage();
        Test.stopTest();        
        
        System.assertEquals(true, testBoolean);     
    }
    
    @isTest(seeAllData = false) private static void testIsValidPercentage_falseSecondCondition(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODMILESTONE, true);
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){          
            item.Total_Service_Amount__c = 100;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 20;
        }
            update testTaskItemList;        
        createController();
        testController.init();
        
            
        Test.startTest();
            Boolean testBoolean = testController.isValidPercentage();
        Test.stopTest();        
        
        System.assertEquals(false, testBoolean);        
        System.assert(TestingUtils.pageMessagesContain('Sum of all Service Percentages should be 100%.'));  
    }   
    
    @isTest(seeAllData = false) private static void testChangeIsBillableAction(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
        
        Test.startTest();
            testController.changeIsBillableAction();
        Test.stopTest();
        
        System.assertEquals(100, testController.totalPercentageTaskItems);
    }
    
    @isTest(seeAllData = false) private static void testSetAmount(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
        
        Test.startTest();
            testController.setAmount();
        Test.stopTest();
        
        System.assertEquals(100, testController.totalPercentageTaskItems);
    }
    
    @isTest(seeAllData = false) private static void testSelectBillingMethodAction(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false);
        for(Billing_Date__c item : testBillingDateList){
            item.Percentage__c = 20;
        }
            insert testBillingDateList; 
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
            item.Frequency__c = 'Weekly';
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
        
        Test.startTest();
            testController.selectBillingMethodAction();
        Test.stopTest();
        
        System.assertEquals(5, testController.numberInterval);
    }
    
    @isTest(seeAllData = false) private static void testNumberIntervalAction_equalsZero(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false);     
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
            item.Frequency__c = 'Weekly';           
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
        testController.selectBillingMethodAction();
        
        Test.startTest();
            testController.numberIntervalAction();
        Test.stopTest();
        
        System.assert(TestingUtils.pageMessagesContain('Number of intervals should be positive value.'));
        
        
        
    }
    
    @isTest(seeAllData = false) private static void testNumberIntervalAction_ProjectDAteIsNull(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false); 
        for(Billing_Date__c item : testBillingDateList){
            item.Percentage__c = 20;
        }
            insert testBillingDateList;     
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
            item.Frequency__c = 'Weekly';
            item.Project_Start_Date__c = null;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();
        testController.init();
        testController.selectBillingMethodAction();
        
        Test.startTest();
            testController.numberIntervalAction();
        Test.stopTest();
        
        
        System.assertEquals(false, BillingDateServices.isChangedNumberInterval);
//        System.assert(TestingUtils.pageMessagesContain('Project Start Date should be populated.'));
    }
    
    @isTest(seeAllData = false) private static void testNumberIntervalAction_ProjectBillingDAteIsNull(){
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false); 
        for(Billing_Date__c item : testBillingDateList){
            item.Percentage__c = 20;
        }
            insert testBillingDateList;     
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
            item.Frequency__c = 'Weekly';
            item.Billing_End_Date__c = null;
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();

        System.assert(! testTaskItemList.isEmpty() );
        System.assert(testController != null);

        testController.init();
        testController.selectBillingMethodAction();
        
        Test.startTest();
            testController.numberIntervalAction();
        Test.stopTest();        
        
//        System.assert(TestingUtils.pageMessagesContain('Billing End Date should be populated.'));
    }
    
    @isTest(seeAllData = false) private static void testNumberIntervalAction_createBillingDateForPercentage(){
        Date testDate = Date.today();
        Integer stepNumber = 1;
        setupData();
        prepareProjectProfile(ProjectProfileServices.BILLINGMETHODPERCENTAGE, true);
        testBillingDateList = TestingUtils.createBillingDateList(5, Date.today(), testProjectProfileList[0].Id, false); 
        for(Billing_Date__c item : testBillingDateList){
            item.Percentage__c = 20;
        }
            insert testBillingDateList;     
        prepareServiceTaskItems();
        for(Project_Profile__c item : testProjectProfileList){
            item.Total_Service_Amount__c = 100;
            item.Interval__c = false;
            item.Frequency__c = 'Weekly';           
            item.Billing_End_Date__c = Date.today().addDays(30);
        }
            update testProjectProfileList;
        for(Task_Item__c item : testTaskItemList){          
            item.Billing_Percentage__c = 10;
            item.Billing_Trigger__c = true; 
        }
            update testTaskItemList;        
        createController();

        System.assert(! testTaskItemList.isEmpty() );
        System.assert(testController != null);
                
        testController.init();
        testController.selectBillingMethodAction();
        
        Test.startTest();
            Integer numberInterval     = testController.numberInterval;
            Project_Profile__c project = testController.project;
            List<BillingDateWrapper> billingDateWrapperList = testController.billingDateWrapperList;
            Boolean isRenderedPrice = testController.isRenderedPrice;
            
            testController.numberIntervalAction();
            //testController.filterBillingDate();
            testController.createBillingDateForPercentage(); 
            //testController.endDateForPercentage(); 
            //testController.getPercentageByIntervalNumber(stepNumber);
        Test.stopTest();
        
        //System.assertEquals(5, testController.numberInterval);
        //System.assertEquals(5, testController.billingDateWrapperList.size());
        /*for(BillingDateWrapper item : testController.billingDateWrapperList){
            System.assertEquals(testDate, item.bd.Processing_Day__c);
            testDate = testDate.addDays(7);
            System.assertEquals(0.00, item.bd.Percentage__c);
            System.assertEquals(testProjectProfileList[0].Id, item.bd.Project_Profile__c);
            System.assertEquals(stepNumber, item.bd.Step_Number__c);
            stepNumber++;           
        }*/
        
    }

    
    
    
}