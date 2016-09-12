@isTest
private class TestPerformHourlyConsultingSubmitCont {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 4;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 5;
    private static final Integer NUMBER_TO_CREATE_MILESTONES = 5;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PHASE = 1;
    private static final Integer NUMBER_TO_CREATE_FLOOR = 1;
    private static final Decimal TASK_ITEM_PERCENTAGE = 0.5;
    private static final Decimal ITEM_ITEM_QUANTITY = 10;
    private static final Decimal PROJECT_PROFILE_TOTAL_SERVICE_AMOUNT = 50;
    private static final Decimal DISCOUNT_PERCENTAGE = 25;
    private static final Decimal UNIT_PRICE = 25;
    private static final String TEST_DESCRIPTION = 'Test description';
    private static final String TEST_UNIT_OF_SERVICE_HOUR = 'Hour';
    private static final List<String> PROJECT_PROFILE_BILLING_METHOD_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                             ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                             ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Phase__c> testPhaseList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Item__c> testMilestonesList;
    private static List<Task_Item__c> testTaskItemListSelected; 
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Floor__c> testFloorList;
    private static List<Service_Floor_Junction__c> testServiceFloorJunctionForInsertList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void prepareData(){
        testProposalList = new List<Proposal__c>();
        for (Integer i = 0; i < PROJECT_PROFILE_BILLING_METHOD_LIST.size(); i++){
            for (Proposal__c proposalItem : TestingUtils.createProposalList(NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id,
                                                                            testContactWithAccountList[0].Id, testAccountList[1].Id,
                                                                            testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                            null, null, null, null, partnerUser.Id,
                                                                            currentUserId, projectManagerUser.Id, false)){
                proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
                proposalItem.Billing_Method__c = PROJECT_PROFILE_BILLING_METHOD_LIST[i];
                proposalItem.Frequency__c = PROJECT_PROFILE_BILLING_METHOD_LIST[i] == ProjectProfileServices.BILLINGMETHODPERCENTAGE ? null : DateUtils.WEEKLY;
                proposalItem.Billing_day__c = DateTime.now().format('EEEE');
                proposalItem.Is_Floors_To_Services__c = true;
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;

        testProjectProfileList = new List<Project_Profile__c>();
        Map<Id, Project_Profile__c> proposalIdWithProjectProfileMap = new Map<Id, Project_Profile__c>();

        for (Proposal__c proposalItem : testProposalList){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList (NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id,
                                                                                                testContactWithAccountList[0].Id, testAccountList[1].Id,
                                                                                                testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Billing_Method__c = proposalItem.Billing_Method__c;
                projectProfileItem.Frequency__c = proposalItem.Frequency__c;
                projectProfileItem.Billing_day__c = proposalItem.Billing_day__c;
                projectProfileItem.Total_Service_Amount__c = PROJECT_PROFILE_TOTAL_SERVICE_AMOUNT;
                projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
                projectProfileItem.Submitted_Planned_Dates__c = true;
                projectProfileItem.Project_Start_Date__c = Date.Today();
                projectProfileItem.Project_Expected_End_Date__c = Date.Today() + 1;
                projectProfileItem.Proposal__c = proposalItem.Id;
                proposalIdWithProjectProfileMap.put(proposalItem.Id, projectProfileItem);
                testProjectProfileList.add (projectProfileItem);
            }
        }
        insert testProjectProfileList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Profile__c = proposalIdWithProjectProfileMap.get(proposalItem.Id).Id;
        }
        update testProposalList;

        Map<Id, List<Phase__c>> proposalWithPhaseMap = new Map<Id, List<Phase__c>>();
        testPhaseList = new List<Phase__c>();
        testFloorList = new List<Floor__c>();
        for (Proposal__c proposalItem : testProposalList){
            proposalWithPhaseMap.put(proposalItem.Id, new List<Phase__c>());
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Proposal__c = proposalItem.Id;
                phaseItem.Project_Profile__c = proposalItem.Project_Profile__c;
                testPhaseList.add(phaseItem);
                proposalWithPhaseMap.get(proposalItem.Id).add(phaseItem);
            }
            for(Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                floorItem.Project__c = proposalItem.Project_Profile__c;
                testFloorList.add(floorItem);
            }
        }
        insert testPhaseList;
        insert testFloorList;

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, proposalItem.Id, false)){
                serviceItem.Quantity__c = ITEM_ITEM_QUANTITY;
                serviceItem.Unit_Price__c = UNIT_PRICE;
                serviceItem.Description__c = TEST_DESCRIPTION;
                serviceItem.Discount_Percentage__c = DISCOUNT_PERCENTAGE;
                serviceItem.Actual_Start_Date__c = DateTime.now();
                serviceItem.Met_Data_Scanning_Fee__c = 1.1;
                serviceItem.Phase__c = testPhaseList[0].Id;
                serviceItem.Service_Template__c = TestingUtils.createServiceTemplateList(1, true)[0].Id;
                serviceItem.Project_Profile__c = proposalItem.Project_Profile__c;
                serviceItem.Unit_of_Service__c = TEST_UNIT_OF_SERVICE_HOUR;
                serviceItem.Phase__c = proposalWithPhaseMap.get(proposalItem.Id)[0].Id;
                testServiceItemList.add(serviceItem);
            }
        }

        insert testServiceItemList;

        testServiceFloorJunctionForInsertList = new List<Service_Floor_Junction__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Floor__c floorItem : testFloorList){
                if (serviceItem.Proposal__c == floorItem.Proposal__c){
                    testServiceFloorJunctionForInsertList.addAll(TestingUtils.createServiceFloorJunctionList(1, serviceItem.Id, floorItem.Id, false));
                }
            }
        }
        insert testServiceFloorJunctionForInsertList;
    }

    private static ApexPages.StandardController testController;
    private static PerformHourlyConsultingSubmitCont testPerformHourlyConsultingSubmitCont;

    private static testMethod void testPerformHourlyConsultingSubmitCont() {
        setupData();
        prepareData();
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItem.Service_Item__c = serviceItem.Id;
                taskItem.Is_Locked__c = true;
                taskItem.Billing_Trigger__c = true;
                taskItem.Billing_Percentage__c = TASK_ITEM_PERCENTAGE;
                taskItem.Actual_Start_Date__c = DateTime.now();
                taskItem.Actual_End_Date__c = null;
                taskItem.No_Met_Data_Scanning__c = false;
                taskItem.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Hours_Reported_Now__c = 1;
                taskItem.Activity_Date__c = Date.Today();
                taskItem.Activity_Notes_Long__c = '';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        testTaskItemListSelected = [Select Id, Project_Profile__c, Type_of_Billable_Hours_Template__c,
                                        Service_Item__r.Phase__c, Region__c, Service_Item__r.Proposal__c, Service_Item__c,
                                        Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c, Service_Item__r.Floor__c,
                                        Service_Item__r.Proposal__r.Is_Change_Order__c, Service_Item__r.Proposal__r.Apply_Discount__c,
                                        Service_Item__r.Proposal__r.Discount_Percentage__c, Service_Item__r.Proposal__r.Reimbursable_Items_Basis__c,
                                        Service_Item__r.Proposal__r.Reimbursable_Percentage__c, Service_Item__r.Proposal__r.Is_Floors_To_Services__c
                                    From Task_Item__c Where Id IN: testTaskItemList];

        Test.setCurrentPageReference(Page.PerformHourlyCunsultingSubmit);
        testController = new ApexPages.StandardController( testTaskItemListSelected[0] );

        Test.startTest();
            testPerformHourlyConsultingSubmitCont = new PerformHourlyConsultingSubmitCont(testController);
            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList!= null );
            System.assert( testPerformHourlyConsultingSubmitCont.getBillingLineItemList() != null );
            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList != null );
            testPerformHourlyConsultingSubmitCont.submit();
            testPerformHourlyConsultingSubmitCont.currentTaskItem.Activity_Notes_Long__c = 'test activity note';
            testPerformHourlyConsultingSubmitCont.currentTaskItem.Hours_Reported_For__c = partnerUser.Id;
            testPerformHourlyConsultingSubmitCont.submit();
            testPerformHourlyConsultingSubmitCont.submitRequest();
            testPerformHourlyConsultingSubmitCont.currentTaskItem.Request_Billable_Hours__c = 4;
            testPerformHourlyConsultingSubmitCont.currentTaskItem.Reason_For_Billable_Hours__c = 'test reason';
            testPerformHourlyConsultingSubmitCont.submitRequest();
            testPerformHourlyConsultingSubmitCont.getServiceForProject();
            testPerformHourlyConsultingSubmitCont.createChangeOrderForBillableHours( testTaskItemListSelected[0], 1, '', null );
        Test.stopTest();

    }

    private static testMethod void testForCoverage() {
        setupData();
        prepareData();
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItem.Service_Item__c = serviceItem.Id;
                taskItem.Is_Locked__c = true;
                taskItem.Billing_Trigger__c = false;
                taskItem.Billing_Percentage__c = TASK_ITEM_PERCENTAGE;
                taskItem.Actual_Start_Date__c = DateTime.now();
                taskItem.Actual_End_Date__c = null;
                taskItem.No_Met_Data_Scanning__c = false;
                taskItem.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Hours_Reported_Now__c = 1;
                taskItem.Activity_Date__c = Date.Today();
                taskItem.Activity_Notes_Long__c = '';
                taskItem.Request_Billable_Hours__c = 1;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Reason_For_Billable_Hours__c = '';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        testTaskItemListSelected = [Select Id, Project_Profile__c, Type_of_Billable_Hours_Template__c, Service_Item__r.Floor__c,
                                        Service_Item__r.Phase__c, Region__c, Service_Item__r.Proposal__c, Service_Item__c,
                                        Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c,
                                        Project_Profile__r.Submitted_Planned_Dates__c, Hours_Reported_Now__c, Activity_Date__c,
                                        Activity_Notes_Long__c, Request_Billable_Hours__c, Type_of_Billable_Hours__c, Reason_For_Billable_Hours__c,
                                        Service_Item__r.Proposal__r.Is_Change_Order__c, Service_Item__r.Proposal__r.Apply_Discount__c, Service_Item__r.Proposal__r.Discount_Percentage__c,
                                        Service_Item__r.Proposal__r.Reimbursable_Items_Basis__c, Service_Item__r.Proposal__r.Reimbursable_Percentage__c, Service_Item__r.Proposal__r.Is_Floors_To_Services__c
                                    From Task_Item__c Where Id IN: testTaskItemList];
        
        Test.setCurrentPageReference(Page.PerformHourlyCunsultingSubmit);
        testController = new ApexPages.StandardController( testTaskItemListSelected[0] );

        Test.startTest();

            testPerformHourlyConsultingSubmitCont = new PerformHourlyConsultingSubmitCont(testController);

            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList!= null );
            System.assert( testPerformHourlyConsultingSubmitCont.getBillingLineItemList() != null );
            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList != null );
            testPerformHourlyConsultingSubmitCont.currentTaskItem = testTaskItemList[0];
            testPerformHourlyConsultingSubmitCont.submit();
            testPerformHourlyConsultingSubmitCont.submitRequest();
            testPerformHourlyConsultingSubmitCont.getServiceForProject();
            testPerformHourlyConsultingSubmitCont.createChangeOrderForBillableHours( testTaskItemListSelected[0], 1, '', null );
        Test.stopTest();

    }

    private static testMethod void testForCoverage1() {
        setupData();
        prepareData();
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItem.Service_Item__c = serviceItem.Id;
                taskItem.Is_Locked__c = true;
                taskItem.Billing_Trigger__c = false;
                taskItem.Billing_Percentage__c = TASK_ITEM_PERCENTAGE;
                taskItem.Actual_Start_Date__c = DateTime.now();
                taskItem.Actual_End_Date__c = null;
                taskItem.No_Met_Data_Scanning__c = false;
                taskItem.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Hours_Reported_Now__c = 10;
                taskItem.Activity_Date__c = Date.Today();
                taskItem.Activity_Notes_Long__c = 'test';
                taskItem.Request_Billable_Hours__c = null;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Reason_For_Billable_Hours__c = 'test';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        testTaskItemListSelected = [Select Id, Project_Profile__c, Type_of_Billable_Hours_Template__c, Service_Item__r.Purchase_Order__c, Service_Item__r.Service_Name_Full__c, Service_Item__c,
                                        Service_Item__r.Phase__c, Region__c, Service_Item__r.Proposal__c, Project_Profile__r.Accounting_Contact_Company__c, Project_Profile__r.Accounting_Contact__c,
                                        Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c, Project_Profile__r.Billing_Company_Name__c, Project_Profile__r.Billing_Company_Contact__c,
                                        Project_Profile__r.Submitted_Planned_Dates__c, Hours_Reported_Now__c, Hours_Remaining__c, Activity_Date__c, Project_Profile__r.Billing_Method__c,
                                        Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Building__c, Actual_Start_Date__c, Actual_End_Date__c, Service_Item__r.GLA_Product__r.Name,
                                        Activity_Notes_Long__c, Request_Billable_Hours__c, Type_of_Billable_Hours__c, Reason_For_Billable_Hours__c, Hours_Reported_For__c, Billing_Trigger__c, Service_Item__r.Floor__c,
                                        Service_Item__r.Unit_Price__c, Service_Item__r.Quantity__c, Worked_to_Date__c, Status__c, OwnerId, Manager_Lookup__c, Service_Item__r.Proposal__r.Is_Change_Order__c,
                                        Service_Item__r.Proposal__r.Apply_Discount__c, Service_Item__r.Proposal__r.Discount_Percentage__c,
                                        Service_Item__r.Proposal__r.Reimbursable_Items_Basis__c, Service_Item__r.Proposal__r.Reimbursable_Percentage__c, Service_Item__r.Proposal__r.Is_Floors_To_Services__c
                                    From Task_Item__c Where Id IN: testTaskItemList];

        Test.setCurrentPageReference(Page.PerformHourlyCunsultingSubmit);
        testController = new ApexPages.StandardController( testTaskItemListSelected[0] );

        Test.startTest();

            testPerformHourlyConsultingSubmitCont = new PerformHourlyConsultingSubmitCont(testController);
            testPerformHourlyConsultingSubmitCont.submit();
            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList!= null );
            System.assert( testPerformHourlyConsultingSubmitCont.getBillingLineItemList() != null );
            System.assert( testPerformHourlyConsultingSubmitCont.taskItemList != null );
            testPerformHourlyConsultingSubmitCont.currentTaskItem = testTaskItemListSelected[0];
            testPerformHourlyConsultingSubmitCont.submit();
            testPerformHourlyConsultingSubmitCont.submitRequest();
            testPerformHourlyConsultingSubmitCont.getServiceForProject();
            testPerformHourlyConsultingSubmitCont.createChangeOrderForBillableHours( testTaskItemListSelected[0], 1, '', null );
        Test.stopTest();

    }

    private static testMethod void testForCoverage2() {
        setupData();
        prepareData();
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItem.Service_Item__c = serviceItem.Id;
                taskItem.Is_Locked__c = true;
                taskItem.Billing_Trigger__c = false;
                taskItem.Billing_Percentage__c = TASK_ITEM_PERCENTAGE;
                taskItem.Actual_Start_Date__c = DateTime.now();
                taskItem.Actual_End_Date__c = null;
                taskItem.No_Met_Data_Scanning__c = false;
                taskItem.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                taskItem.Hours_Reported_Now__c = 10;
                taskItem.Activity_Date__c = Date.Today();
                taskItem.Activity_Notes_Long__c = 'test';
                taskItem.Request_Billable_Hours__c = 1;
                taskItem.Type_of_Billable_Hours__c = null;
                taskItem.Reason_For_Billable_Hours__c = 'test';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        testTaskItemListSelected = [Select Id, Project_Profile__c, Type_of_Billable_Hours_Template__c,
                                        Service_Item__r.Phase__c, Region__c, Service_Item__r.Proposal__c, 
                                        Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c,
                                        Project_Profile__r.Submitted_Planned_Dates__c, Hours_Reported_Now__c, Hours_Remaining__c, Activity_Date__c,
                                        Activity_Notes_Long__c, Request_Billable_Hours__c, Type_of_Billable_Hours__c, Reason_For_Billable_Hours__c  
                                    From Task_Item__c Where Id IN: testTaskItemList];
        
        Test.setCurrentPageReference(Page.PerformHourlyCunsultingSubmit);
        testController = new ApexPages.StandardController( testTaskItemListSelected[0] );

        Test.startTest();

            testPerformHourlyConsultingSubmitCont = new PerformHourlyConsultingSubmitCont(testController);

            testPerformHourlyConsultingSubmitCont.submitRequest();

        Test.stopTest();

    }

    private static testMethod void testForCoverage3() {
        setupData();
        prepareData();
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItem.Project_Profile__c = serviceItem.Project_Profile__c;
                taskItem.Service_Item__c = serviceItem.Id;
                taskItem.Is_Locked__c = true;
                taskItem.Billing_Trigger__c = false;
                taskItem.Billing_Percentage__c = TASK_ITEM_PERCENTAGE;
                taskItem.Actual_Start_Date__c = DateTime.now();
                taskItem.Actual_End_Date__c = null;
                taskItem.No_Met_Data_Scanning__c = false;
                taskItem.Status__c = TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS;
                taskItem.Type_of_Billable_Hours__c = serviceItem.Id;
                //taskItem.Hours_Reported_Now__c = 10;
                taskItem.Activity_Date__c = Date.Today();
                taskItem.Activity_Notes_Long__c = 'test';
                taskItem.Request_Billable_Hours__c = 1;
                taskItem.Type_of_Billable_Hours__c = null;
                taskItem.Reason_For_Billable_Hours__c = 'test';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        testTaskItemListSelected = [Select Id, Project_Profile__c, Type_of_Billable_Hours_Template__c,
                                        Service_Item__r.Phase__c, Region__c, Service_Item__r.Proposal__c, 
                                        Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c,
                                        Project_Profile__r.Submitted_Planned_Dates__c, Hours_Reported_Now__c, Hours_Remaining__c, Activity_Date__c,
                                        Activity_Notes_Long__c, Request_Billable_Hours__c, Type_of_Billable_Hours__c, Reason_For_Billable_Hours__c  
                                    From Task_Item__c Where Id IN: testTaskItemList];

        Test.setCurrentPageReference(Page.PerformHourlyCunsultingSubmit);
        testController = new ApexPages.StandardController( testTaskItemListSelected[0] );

        Test.startTest();

            testPerformHourlyConsultingSubmitCont = new PerformHourlyConsultingSubmitCont(testController);

            testPerformHourlyConsultingSubmitCont.submit();

            testPerformHourlyConsultingSubmitCont.currentTaskItem.Status__c = 'test status';
            Boolean testBoolean = testPerformHourlyConsultingSubmitCont.isValidStatus;
            testBoolean = testPerformHourlyConsultingSubmitCont.isValidSubmitStatus;

        Test.stopTest();

    }
}