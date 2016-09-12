@isTest
private class TestTaskItemServices {
    private static final String TEST_DESCRIPTION = 'test description';
    private static final String TEST_NOTE_TEXT = 'test note text';
    private static final String NORMAL_PRIORITY = 'Normal';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String TASK_ITEM_NAME = 'test task item name';
    private static final String TASK_TEMPLATE_NAME = 'test task template name';
    private static final String TEST_SUCCESSOR_MILESTONE = 'test succesoor';
    private static final String TEST_PREDECESSOR_MILESTONE = 'test prodecessor';
    private static final String DISAPPROVED_STATUS_VALUE = 'Disapproved';
    private static final Integer NUMBER_TO_CREATE_TASK = 5;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_BILLING_DATE = 3;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PHASE = 2;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 2;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 2;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_MILESTONES = 5;
    private static final Integer NUMBER_TO_CREATE_EVENT = 3;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE_FOR_PROPOSAL = 1;
    private static final Integer TEST_TOTAL_DURATION = 10;
    private static final Decimal TOTAL_PROJECT_AMOUNT = 2.3;
    private static final Decimal TEST_QUANTITY = 3.4;
    private static final Decimal TEST_UNIT_PRICE = 4.5;
    private static final Decimal TEST_DISCOUNTED_RERCENTAGE = 8.00;
    private static final Decimal TEST_PERCENTAGE = 5.0;
    private static final Decimal TEST_BILLING_PERCENTAGE = 8.0;
    private static final Decimal TEST_REMINDER_OFFSET = 5.3;
    private static final Date TEST_CURRENT_DATE = Date.newInstance(7, 8, 2010);
    //Service Template Record Type Names
    private static final String SERVICE_TEMPLATE_APS_RECORD_TYPE_NAME = 'Application & Permit Services';
    private static final String SERVICE_TEMPLATE_OS_RECORD_TYPE_NAME = 'Other Services';
    private static final String SERVICE_TEMPLATE_SUBSERVICE_RECORD_TYPE_NAME = 'Subservice';
    private static final String SUBJECT_REMINDER_FOR_PROJECT_MANAGER = 'Reminder for Project Manager';
    private static final String TEST_CATEGORY_VALUE = 'test category';
    private static final String TEST_TYPE_VALUE = 'test type';
    private static final String TEST_SUBTYPE_VALUE = 'test subtype';
    private static final String TEST_PLAN_SUBMISSION_TYPE_VALUE = 'test plan submission type';
    //Task Template Record Type Names
    private static final String TASK_TEMPLATE_TASK_TEMPLATE_RECORD_TYPE_NAME = 'Task Template';
    private static final String TASK_TEMPLATE_SUPER_TEMPLATE_RECORD_TYPE_NAME = 'Super-template';
    private static final List<String> BILLING_METHOD_VALUES_LIST = new List<String>{ProjectProfileServices.BILLINGMETHODINSTALLMENT,
                                                                                    ProjectProfileServices.BILLINGMETHODMILESTONE,
                                                                                    ProjectProfileServices.BILLINGMETHODPERCENTAGE};

    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Item__c> testMilestonesList;
    private static List<Task> testTaskList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Billing_Date__c> testBillingDateList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Service_Template__c> testServiceTemplateAlternativeList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Task_Template__c> testTaskTemplateAlternativeList;
    private static List<Phase__c> testPhaseList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Task_State_Change__c> testTaskStateChangeList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Event> testEventList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static BusinessHours testBusinessHours;

    private static Id serviceTemplateAPSRecordTypeId;
    private static Id serviceTemplateOSRecordTypeId;
    private static Id serviceTemplateSubserviceRecordTypeId;
    private static Id taskTemplateTaskTemplateRecordTypeId;
    private static Id taskTemplateSuperTemplateRecordTypeId;
    private static Id taskItemMilestoneRecordTypeId;
    private static Id taskItemNotMilestoneRecordTypeId;

    private static void setupData (){
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

    private static List<Project_Profile__c> createProjectProfileProposalListsForTest( Boolean needUpdate ){
        testProposalList = new List<Proposal__c>();
        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            for ( Proposal__c proposalItem : TestingUtils.createProposalList ( NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                               testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                               null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false ) ){
                proposalItem.Apply_Discount__c = false;
                proposalItem.Status__c = 'new';
                proposalItem.Billing_Method__c = billingMethodItem;
                proposalItem.Frequency__c = DateUtils.MONTHLY;
                proposalItem.Billing_day__c = String.valueOf(Date.today().day());
                proposalItem.Interval__c = billingMethodItem != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                proposalItem.No_Met_Data_Scanning__c = billingMethodItem != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                proposalItem.Discounted_Total_Service_Amount__c = 1.1;
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;

        testProjectProfileList = new List<Project_Profile__c>();
        Map<Id, Project_Profile__c> proposalWithProjectProfileMap = new Map<Id, Project_Profile__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( NUMBER_TO_CREATE_PROJECT_PROFILE_FOR_PROPOSAL, proposalItem.Primary_Company_Name__c, proposalItem.Primary_Company_Contact__c,
                                                                                                proposalItem.Billing_Company_Name__c, proposalItem.Billing_Company_Contact__c, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
                projectProfileItem.Project_Manager__c = projectManagerUser.Id;
                projectProfileItem.Billing_Method__c = proposalItem.Billing_Method__c;
                projectProfileItem.Building__c = testBuildingList[0].id;
                projectProfileItem.Frequency__c = proposalItem.Frequency__c;
                projectProfileItem.Expected_Construction_Start_Date__c = Date.today();
                projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(1);
                projectProfileItem.Billing_day__c = proposalItem.Billing_day__c;
                projectProfileItem.Total_Service_Amount__c = TOTAL_PROJECT_AMOUNT;
                projectProfileItem.Interval__c = proposalItem.Interval__c;
                projectProfileItem.Proposal__c = proposalItem.Id;
                projectProfileItem.Submitted_Planned_Dates__c = needUpdate;
                projectProfileItem.No_Met_Data_Scanning__c = proposalItem.No_Met_Data_Scanning__c;
                proposalWithProjectProfileMap.put(proposalItem.Id, projectProfileItem);
                testProjectProfileList.add(projectProfileItem);
            }
        }
        insert testProjectProfileList;

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Profile__c = proposalWithProjectProfileMap.get(proposalItem.Id).Id;
        }

        update testProposalList;

        return testProjectProfileList;
    }

    private static List<Project_Profile__c> createProjectProfileListsForTest(Integer numberToCreate, Boolean doInsert){
        testProposalList = new List<Proposal__c>();
        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            for ( Proposal__c proposalItem : TestingUtils.createProposalList ( numberToCreate, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                               testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                               null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false ) ){
                proposalItem.Apply_Discount__c = false;
                proposalItem.Status__c = 'new';
                proposalItem.Billing_Method__c = billingMethodItem;
                proposalItem.Frequency__c = DateUtils.MONTHLY;
                proposalItem.Billing_day__c = String.valueOf(Date.today().day());
                proposalItem.Interval__c = billingMethodItem != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                proposalItem.No_Met_Data_Scanning__c = billingMethodItem != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                proposalItem.Discounted_Total_Service_Amount__c = 1.1;
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;

        Integer i = 0;

        testProjectProfileList = new List<Project_Profile__c>();
        for (String billingMethodItem : BILLING_METHOD_VALUES_LIST){
            
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                                testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
                projectProfileItem.Project_Manager__c = projectManagerUser.Id;
                projectProfileItem.Billing_Method__c = billingMethodItem;
                projectProfileItem.Building__c = testBuildingList[0].id;
                projectProfileItem.Frequency__c = DateUtils.MONTHLY;
                projectProfileItem.Expected_Construction_Start_Date__c = Date.today();
                projectProfileItem.Expected_Construction_End_Date__c = Date.today().addMonths(1);
                projectProfileItem.Billing_day__c = String.valueOf(Date.today().day());
                projectProfileItem.Total_Service_Amount__c = TOTAL_PROJECT_AMOUNT;
                projectProfileItem.Interval__c = projectProfileItem.Billing_Method__c != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                projectProfileItem.No_Met_Data_Scanning__c = projectProfileItem.Billing_Method__c != ProjectProfileServices.BILLINGMETHODPERCENTAGE;
                projectProfileItem.Proposal__c = testProposalList[i].Id;
                testProjectProfileList.add(projectProfileItem);
                i++;
            }
        }
        if(doInsert){
            insert testProjectProfileList;
        }
        
        return testProjectProfileList;
    }

    private static void prepareData (){
        createProjectProfileProposalListsForTest( false );
        update testProjectProfileList;
        testBillingDateList = new List<Billing_Date__c>();
        testPhaseList = new List<Phase__c>();// = TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false);
        Map<Id, List<Phase__c>> projectWithPhaseMap = new Map<Id, List<Phase__c>>();
        Map<Id, List<Purchase_Order__c>> projectProfileWithPurchaseOrderMap = new Map<Id, List<Purchase_Order__c>>();
        testPurchaseOrderList = new List<Purchase_Order__c>();
        testServiceItemList = new List<Service_Item__c>();
        //create Billing Date and PurchaseOrder records
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Date dateItem = Date.today();
            for (Billing_Date__c billingDateItem : TestingUtils.createBillingDateList(NUMBER_TO_CREATE_BILLING_DATE, dateItem, projectProfileItem.Id, false)){
                billingDateItem.Percentage__c = dateItem == Date.today() ? TEST_PERCENTAGE : 0;
                billingDateItem.Processing_Day__c = Date.today();
                testBillingDateList.add(billingDateItem);
                dateItem.addDays(1);
            }
            projectProfileWithPurchaseOrderMap.put(projectProfileItem.Id, new List<Purchase_Order__c>());
            for (Purchase_Order__c purchaseOrderItem : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, Date.today(), false)){
                purchaseOrderItem.Project_Profile__c = projectProfileItem.Id;
                purchaseOrderItem.Proposal__c = projectProfileItem.Proposal__c;
                projectProfileWithPurchaseOrderMap.get(projectProfileItem.Id).add(purchaseOrderItem);
                testPurchaseOrderList.add(purchaseOrderItem);
            }
            projectWithPhaseMap.put(projectProfileItem.Id, new List<Phase__c>());
            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Proposal__c = projectProfileItem.Proposal__c;
                phaseItem.Project_Profile__c = projectProfileItem.Id;
                testPhaseList.add(phaseItem);
                projectWithPhaseMap.get(projectProfileItem.Id).add(phaseItem);
            }
        }

        insert testBillingDateList;
        insert testPurchaseOrderList;
        insert testPhaseList;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Phase__c = projectWithPhaseMap.get(projectProfileItem.Id)[0].Id;
                serviceItem.Purchase_Order__c = projectProfileWithPurchaseOrderMap.get(projectProfileItem.Id)[0].Id;
                serviceItem.Project_Profile__c = projectProfileItem.Id;
                serviceItem.Description__c = TEST_DESCRIPTION;
                serviceItem.Quantity__c = TEST_QUANTITY;
                serviceItem.Unit_Price__c = TEST_UNIT_PRICE;
                serviceItem.Discount_Percentage__c = TEST_DISCOUNTED_RERCENTAGE;
                serviceItem.Met_Data_Scanning_Fee__c = 10;
                serviceItem.Met_Data_BLI_Created__c = false;
                serviceItem.Original__c = true;
                serviceItem.Applied_Amendment__c = false;
                serviceItem.Proposal__c = projectProfileItem.Proposal__c;
                testServiceItemList.add(serviceItem);
            }
        }
        insert testServiceItemList;
        //create Task Item
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem :testServiceItemList){
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Actual_End_Date__c = Date.today();
                taskItem.Actual_Start_Date__c = Date.today();
		taskItem.Status__c = 'Not Started';
                taskItem.Billing_Percentage__c = TEST_BILLING_PERCENTAGE;
		taskItem.Name = TASK_ITEM_NAME;
		taskItem.Project_Profile__c = testProjectProfileList[0].Id;
		testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;
	
	testProjectRosterList = TestingUtils.createProjectRosterList(5, false);
	Id userProjectRosterRecordTypeId;
        for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
            if (schemaRecordTypeInfoItem.getName() == 'User'){ userProjectRosterRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId(); }
        }
        
	for( Project_Roster__c item: testProjectRosterList ){
		item.Project_Profile__c = testProjectProfileList[0].Id;	
		item.Contact__c = testContactWithAccountList[0].Id;
            	item.User__c = UserInfo.getUserId();
            	item.User_Type__c = 'Internal';
            	item.User_Contact__c = 'User';
            	item.RecordTypeId = userProjectRosterRecordTypeId;
	}
	INSERT testProjectRosterList;
    }

    private static void getRecordTypes(){
        //get Service Template RecordType
        Map<String, Id> serviceTemplateRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Service_Template__c');
        serviceTemplateAPSRecordTypeId = serviceTemplateRecordTypesMap.get(SERVICE_TEMPLATE_APS_RECORD_TYPE_NAME);
        serviceTemplateOSRecordTypeId = serviceTemplateRecordTypesMap.get(SERVICE_TEMPLATE_OS_RECORD_TYPE_NAME);
        serviceTemplateSubserviceRecordTypeId = serviceTemplateRecordTypesMap.get(SERVICE_TEMPLATE_SUBSERVICE_RECORD_TYPE_NAME);
        //get Task Template Record Type
        Map<String, Id> taskTemplateRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Template__c');
        taskTemplateTaskTemplateRecordTypeId = taskTemplateRecordTypesMap.get(TASK_TEMPLATE_TASK_TEMPLATE_RECORD_TYPE_NAME);
        taskTemplateSuperTemplateRecordTypeId = taskTemplateRecordTypesMap.get(TASK_TEMPLATE_SUPER_TEMPLATE_RECORD_TYPE_NAME);
        //get Task Item Record Type
        Map<String, Id> taskItemRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c');
        taskItemNotMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
        for (String taskItemRecordTypeNameValue : taskItemRecordTypesMap.keySet()){
            if (taskItemRecordTypeNameValue != TaskManagementServices.MILESTONE_RECORDTYPE_NAME){
                taskItemNotMilestoneRecordTypeId = taskItemRecordTypesMap.get(taskItemRecordTypeNameValue);
                break;
            }
        }
        taskItemMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
    }

    private static void createTaskTemplateList(Boolean doInsert){
        List<String> taskItemNameList = new List<String>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_TEMPLATE; i++){
            taskItemNameList.add(TASK_TEMPLATE_NAME + i);
        }
        testTaskTemplateList = TestingUtils.createTaskTemplateList(1, taskItemNameList, doInsert);
    }

    private static void createTaskItemList(Integer numberToCreate, Boolean doInsert){
        testTaskItemList = TestingUtils.createTaskItemList(numberToCreate, false);
        for(Integer i = 0; i < numberToCreate; i++){
            testTaskItemList[i].Name = TASK_ITEM_NAME + i;
            testTaskItemList[i].Description__c = TEST_DESCRIPTION + i;
        }
        if (doInsert)
            {insert testTaskItemList;}
    }

    private static testMethod void testForCoverage(){
        setupData ();
        prepareData ();
        
        Test.startTest();
            Service_Item__c test1 = TaskItemServices.getServiceItem( testProjectProfileList[0] );
	    TaskItemServices.updatePickupAnalyze( testTaskItemList );
	    Set<Id> servicesIds = new Set<Id>();
	    servicesIds.add(testTaskItemList[0].Service_Item__c);
            TaskItemServices.createProjectRostersForNewTaskItemsFuture( servicesIds );
	    TaskItemServices.createProjectRostersForNewTaskItemsFuture( null );
            TaskItemServices.createChangeOrderForRenewableTasks ( new Map<Id, Task_Item__c>( testTaskItemList ) );
            TaskItemServices.updateMunicipalAgencyForAllTask( new Map<Id, Task_Item__c>( testTaskItemList ) );
	    TaskItemServices.upsertProjectRosterList( testTaskItemList );
	    TaskItemServices.calculateExpectedDateFutureMethod( servicesIds );
            TaskItemServices.avoidValidationRuleInFuture( testTaskItemList );
	    TaskItemServices.updateServiceItemExpirationDate( testTaskItemList );
	    TaskItemServices.updateDisapprovedDate( testTaskItemList );
	    List<Task_Item__c> test2 = TaskItemServices.filteredTaskItemForRecalculateProjectTeamExpectedDuration(testTaskItemList, new Map<Id, Task_Item__c>(testTaskItemList));
            TaskItemServices.updateProjectTeamExpectedDuration(testTaskItemList, new Map<Id, Task_Item__c>(testTaskItemList));
	    TaskItemServices.updateProjectTeamExpectedDuration(testTaskItemList, null);
	    TaskItemServices.prepareDataAndRunFutureMethod(testTaskItemList, new Map<Id, Task_Item__c>(testTaskItemList),new Map<Id, Task_Item__c>(testTaskItemList));
	    
	Test.stopTest();
    }
    
    private static testmethod void testGetTaskItemIdsByProjectId(){
        setupData ();
        createProjectProfileProposalListsForTest( true );
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testTaskItemList;

        Set<Id> resultSetId;

        Test.startTest();
            resultSetId = TaskItemServices.getTaskItemIdsByProjectId(testProjectProfileList[0].Id);
        Test.stopTest();

        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), resultSetId);
    }

    private static testmethod void testGetTaskItemIdsByProjectIdWithNull(){
        setupData ();
        createProjectProfileProposalListsForTest( true );
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testTaskItemList;

        Set<Id> resultSetId;

        Test.startTest();
            try{
                resultSetId = TaskItemServices.getTaskItemIdsByProjectId(null);
            }catch(Exception e){}
        Test.stopTest();
    }

    private static testmethod void testGetUnfinishedTaskItemByProjectIds(){
        setupData ();
        createProjectProfileProposalListsForTest( true );
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            taskItemItem.Actual_End_Date__c = null;
        }
        insert testTaskItemList;

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.getUnfinishedTaskItemByProjectIds(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());
        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(testTaskItemList.size(), resultTaskItemList.size());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    private static testmethod void testGetUnfinishedTaskItemByProjectTeamIds(){
        setupData ();
        createProjectProfileProposalListsForTest( true );
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        Id notMilestoneRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task_Item__c' AND Name != 'Milestone'][0].Id;
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
            taskItemItem.Actual_End_Date__c = null;
            taskItemItem.RecordTypeId = notMilestoneRecordTypeId;
        }
        insert testTaskItemList;

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.getUnfinishedTaskItemByProjectTeamIds(new Map<Id, Project_Team__c>(testProjectTeamList).keySet());
        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(testTaskItemList.size(), resultTaskItemList.size());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    private static testmethod void testFilterTaskItemsForBillingLineItemsCreation(){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(1, false);
        testProjectProfileList[0].Pre_billed__c = false;
        createtaskItemList(4 * NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Project_Profile__c = testProjectProfileList[0].Id;
        }
        insert testTaskItemList;
        List<Task_Item__c> testTaskItemListnew = [SELECT Id, Billing_Trigger__c, Is_Locked__c, Actual_End_Date__c, Name, Pre_billed__c, Status__c
                                                  FROM Task_Item__c
                                                  WHERE Id IN : testTaskItemList];

        String complStatus = '';
        for (String s : TaskItemServices.TASK_ITEM_END_STATUS_VALUES){
            complStatus = s;
        }

        Map<Id, Task_Item__c> testMapIdTaskItemOld = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));
        Map<Id, Task_Item__c> testMapIdTaskItemResult;
        Set<Id> resultTaskItemSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemListnew[i].Billing_Trigger__c = false;
            testTaskItemListnew[i].Is_Locked__c = true;
        }
        //this Task Item will be in test result
        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
            testTaskItemListnew[i].Billing_Trigger__c = true;
            testTaskItemListnew[i].Is_Locked__c = false;
            testTaskItemListnew[i].Actual_End_Date__c = Date.today();
            testTaskItemListnew[i].Status__c = complStatus;
            testTaskItemListnew[i].Name = 'test';//doesn't contains TaskServices.TERMINATED_TASK_NAME_PREFIX
            testMapIdTaskItemOld.get(testTaskItemListnew[i].Id).Actual_End_Date__c = null;
            testMapIdTaskItemOld.get(testTaskItemListnew[i].Id).Status__c = 'test not compl status';
            resultTaskItemSetId.add(testTaskItemListnew[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 2; i < NUMBER_TO_CREATE_TASK_ITEM * 3; i++){
            testTaskItemListnew[i].Billing_Trigger__c = true;
            testTaskItemListnew[i].Is_Locked__c = false;
            testTaskItemListnew[i].Actual_End_Date__c = null;
            testMapIdTaskItemOld.get(testTaskItemListnew[i].Id).Actual_End_Date__c = null;
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 3; i < NUMBER_TO_CREATE_TASK_ITEM * 4; i++){
            testTaskItemListnew[i].Billing_Trigger__c = true;
            testTaskItemListnew[i].Is_Locked__c = false;
            testTaskItemListnew[i].Actual_End_Date__c = Date.today();
            testMapIdTaskItemOld.get(testTaskItemListnew[i].Id).Actual_End_Date__c = Date.today();
        }

        Test.startTest();
            testMapIdTaskItemResult = TaskItemServices.filterTaskItemsForBillingLineItemsCreation(testTaskItemListnew, testMapIdTaskItemOld);
        Test.stopTest();

        System.assertEquals(NUMBER_TO_CREATE_TASK_ITEM, testMapIdTaskItemResult.size());
        System.assertEquals(resultTaskItemSetId, testMapIdTaskItemResult.keySet());
    }

    private static testmethod void testGetTaskItemBillingMethodQuery(){
        String testStringResult;

        Test.startTest();
            testStringResult = TaskItemServices.getTaskItemBillingMethodQuery(Date.today());
        Test.stopTest();

        System.assert(!String.isEmpty(testStringResult));
    }

    private static testmethod void testCreateBilingLineItemsForBillingDatesBatch(){
        setupData();
        prepareData();
        List<Billing_Line_Item__c> testBLIResult;

        String errorString;

        Test.startTest();

                testBLIResult = TaskItemServices.createBilingLineItemsForBillingDatesBatch(testBillingDateList, Date.today(), null);

        Test.stopTest();

    }

    private static testmethod void testCreateBilingLineItemsForBillingDatesBatchWithProjectProfile(){
        setupData();
        prepareData();

        List<Billing_Line_Item__c> testBLIResult;

        Map <Id, Project_Profile__c> testProjectProfileMap = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            testProjectProfileMap.put(projectProfileItem.Id, null);
        }
        testProjectProfileMap = ProjectProfileServices.getProgectProfileMap(testProjectProfileMap.keySet());

        Test.startTest();
            testBLIResult = TaskItemServices.createBilingLineItemsForBillingDatesBatch(testBillingDateList, Date.today(), testProjectProfileMap);
        Test.stopTest();


    }

    private static testmethod void testCreateTaskItemFromTaskTemplate(){
        createTaskTemplateList(false);
        testTaskTemplateList[0].Billing_Trigger__c = true;
        testTaskTemplateList[0].Billing_Percentage__c = TEST_BILLING_PERCENTAGE;
        testTaskTemplateList[0].Description__c = TEST_DESCRIPTION;
        testTaskTemplateList[0].Notes__c = TEST_NOTE_TEXT;
        testTaskTemplateList[0].Task_Action__c = 'test task action';
        testTaskTemplateList[0].Input__c = 'test input text';
        testTaskTemplateList[0].Manager_Role__c = 'test role';
        testTaskTemplateList[0].Resources__c = 'test resource';
        testTaskTemplateList[0].Artifacts__c = 'test artifact';
        testTaskTemplateList[0].Results__c = 'test result';
        testTaskTemplateList[0].Sequence_Number__c = 1;
        testTaskTemplateList[0].Standard_Duration__c = '0d 0h 0m';
        testTaskTemplateList[0].Predecessor_Milestone__c = 'test predecessor';
        testTaskTemplateList[0].Successor_Milestone__c = 'test successor';
        insert testTaskTemplateList;
        Task_Item__c resultTaskItem;

        Test.startTest();
            resultTaskItem = TaskItemServices.createTaskItemFromTaskTemplate(testTaskTemplateList[0]);
        Test.stopTest();

        System.assertEquals(testTaskTemplateList[0].Name, resultTaskItem.Name);
        System.assertEquals(testTaskTemplateList[0].Billing_Trigger__c, resultTaskItem.Billing_Trigger__c);
        System.assertEquals(testTaskTemplateList[0].Billing_Percentage__c, resultTaskItem.Billing_Percentage__c);
        System.assertEquals(testTaskTemplateList[0].Id, resultTaskItem.Task_Template__c);
        System.assertEquals(testTaskTemplateList[0].Description__c, resultTaskItem.Description__c);
        System.assertEquals(testTaskTemplateList[0].Notes__c, resultTaskItem.Notes__c);
        System.assertEquals(testTaskTemplateList[0].Task_Action__c, resultTaskItem.Action__c);
        System.assertEquals(testTaskTemplateList[0].Input__c, resultTaskItem.Input__c);
        
        System.assertEquals(testTaskTemplateList[0].Resources__c, resultTaskItem.Resources__c);
        System.assertEquals(testTaskTemplateList[0].Artifacts__c, resultTaskItem.Artifacts__c);
        System.assertEquals(testTaskTemplateList[0].Financial_Force_Integration__c, resultTaskItem.Financial_Force_Integration__c);
        System.assertEquals(testTaskTemplateList[0].Results__c, resultTaskItem.Results__c);
        System.assertEquals(testTaskTemplateList[0].Sequence_Number__c, resultTaskItem.Sequence_Number__c);
        System.assertEquals(testTaskTemplateList[0].Standard_Duration__c, resultTaskItem.Planned_Durration__c);
        System.assertEquals(testTaskTemplateList[0].Standard_Duration__c, resultTaskItem.Expected_Duration__c);
        System.assertEquals(testTaskTemplateList[0].Predecessor_Milestone__c, resultTaskItem.Predecessor_Milestone_from_Template__c);
        System.assertEquals(testTaskTemplateList[0].Successor_Milestone__c, resultTaskItem.Successor_Milestone_from_Template__c);
    }
    
    private static testmethod void testCreateTaskItemFromTaskTemplate1(){
        setupData();
        prepareData();
	createTaskTemplateList(false);
        testTaskTemplateList[0].Billing_Trigger__c = true;
        testTaskTemplateList[0].Billing_Percentage__c = TEST_BILLING_PERCENTAGE;
        testTaskTemplateList[0].Description__c = TEST_DESCRIPTION;
        testTaskTemplateList[0].Notes__c = TEST_NOTE_TEXT;
        testTaskTemplateList[0].Task_Action__c = 'test task action';
        testTaskTemplateList[0].Input__c = 'test input text';
        testTaskTemplateList[0].Manager_Role__c = 'test role';
        testTaskTemplateList[0].Resources__c = 'test resource';
        testTaskTemplateList[0].Artifacts__c = 'test artifact';
        testTaskTemplateList[0].Results__c = 'test result';
        testTaskTemplateList[0].Sequence_Number__c = 1;
        testTaskTemplateList[0].Standard_Duration__c = '0d 0h 0m';
        testTaskTemplateList[0].Predecessor_Milestone__c = 'test predecessor';
        testTaskTemplateList[0].Successor_Milestone__c = 'test successor';
        insert testTaskTemplateList;
        Task_Item__c resultTaskItem;

        Test.startTest();
            Task_Item__c testTaskItem = TaskItemServices.createAndPrepareTaskForInsertion( testTaskTemplateList[0], testServiceItemList[0], testProposalList[0], testProjectTeamList[0], UserInfo.getUserId(), null );
        Test.stopTest();

        
    }

    private static testmethod void testPrepareTaskMilestonePredecessorsSuccessors(){
        setupData();
        createProjectProfileProposalListsForTest( true );
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testTaskTemplateList = new List<Task_Template__c>();
        Map<Id, List<Task_Template__c>> temporaryMapServiceTemplateToListTaskTemplate = new Map<Id, List<Task_Template__c>>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            temporaryMapServiceTemplateToListTaskTemplate.put(serviceTemplateItem.Id, new List<Task_Template__c>());
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, serviceTemplateItem.Name + TASK_TEMPLATE_NAME, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.Successor_Milestone__c = TEST_SUCCESSOR_MILESTONE;
                taskTemplateItem.Predecessor_Milestone__c = TEST_PREDECESSOR_MILESTONE;
                temporaryMapServiceTemplateToListTaskTemplate.get(serviceTemplateItem.Id).add(taskTemplateItem);
                testTaskTemplateList.add(taskTemplateItem);
            }
        }
        insert testTaskTemplateList;

        Map<Id, Map<Id, Task_Template__c>> testServiceTemplateIdToTasksTemplates = new Map<Id, Map<Id, Task_Template__c>>();
        for (Task_Template__c taskTemplateItem : testTaskTemplateList){
            if (!testServiceTemplateIdToTasksTemplates.containsKey(taskTemplateItem.Service__c)){
                testServiceTemplateIdToTasksTemplates.put(taskTemplateItem.Service__c, new Map<Id, Task_Template__c>());
            }
            testServiceTemplateIdToTasksTemplates.get(taskTemplateItem.Service__c).put(taskTemplateItem.Id, taskTemplateItem);
        }
        testServiceItemList = new List<Service_Item__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Proposal__c proposalItem : testProposalList){
                for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItem.Proposal__c = proposalItem.Id;
                    serviceItem.Project_Profile__c = proposalItem.Project_Profile__c;
                    testServiceItemList.add(serviceItem);
                }
            }
        }
        insert testServiceItemList;
        testServiceItemList = [SELECT Id, Proposal__r.Project_Team__r.Project_Manager__c, Service_Template__c, Project_Profile__c
                               FROM Service_Item__c
                               WHERE Id In : testServiceItemList];

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            TaskManagementServices.seqNumberToTaskItemForService.put(serviceItem.Id, new Map<Integer, Task_Item__c>());
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Template__c taskTemplateItem : temporaryMapServiceTemplateToListTaskTemplate.get(serviceItem.Service_Template__c)){
                Task_Item__c taskItemItem = new Task_Item__c(Predecessor_Milestone_from_Template__c = taskTemplateItem.Predecessor_Milestone__c,
                                                             Successor_Milestone_from_Template__c= taskTemplateItem.Successor_Milestone__c,
                                                             Service_Item__c = serviceItem.Id, Project_Profile__c = serviceItem.Project_Profile__c,
                                                             Sequence_Number__c = sequenceNumber, Task_Template__c = taskTemplateItem.Id);
                testTaskItemList.add(taskItemItem);
                TaskManagementServices.seqNumberToTaskItemForService.get(serviceItem.Id).put(sequenceNumber, taskItemItem);
                sequenceNumber++;
            }
        }
        insert testTaskItemList;

        Test.startTest();
            TaskItemServices.prepareTaskMilestonePredecessorsSuccessors(new Map<Id, Service_Item__c> (testServiceItemList), testServiceTemplateIdToTasksTemplates);
        Test.stopTest();
    }

    private static testmethod void testUpdateServiceItemMilestonesPredecessorSuccessorChangeWithIncorrectData(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        // create Milestones
        testMilestonesList = TestingUtils.createTaskItemList(2, true);
        // create Task Items
        testTaskItemList = TestingUtils.createTaskItemList(2, false);
        testTaskItemList[0].Service_Item__c = testServiceItemList[0].Id;
        testTaskItemList[0].Predecessor_Milestone__c = testMilestonesList[0].Id;
        testTaskItemList[0].Successor_Milestone__c = testMilestonesList[1].Id;
        insert testTaskItemList;

        //create fake Service Item id
        String fakeServiceItemId = testServiceItemList[0].getsObjectType().getDescribe().getKeyPrefix() + '000000000000';
        testTaskItemList[1].Service_Item__c = fakeServiceItemId;// set incorrectId
        testTaskItemList[1].Successor_Milestone__c = testMilestonesList[1].Id;

        Test.startTest();
            //TaskItemServices.updateServiceItemMilestonesPredecessorSuccessorChange(testTaskItemList);
        Test.stopTest();
    }

    private static testmethod void testFilterTasksWithUpdatedActualDateIsStartDate(){
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, false);
        Id notMilestoneRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task_Item__c' AND Name != 'Milestone'][0].Id;
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.RecordTypeId = notMilestoneRecordTypeId;
            taskItemItem.Actual_Start_Date__c = null;
            taskItemItem.Actual_End_Date__c = null;
        }
        insert testTaskItemList;
        Map<Id, Task_Item__c> testOldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> taskResultSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemList[i].Actual_Start_Date__c = DateTime.now();
            taskResultSetId.add(testTaskItemList[i].Id);
        }

        Map<Id, Task_Item__c> resultTaskItemMap;

        Test.startTest();

            resultTaskItemMap = TaskItemServices.filterTasksWithUpdatedActualDate(testTaskItemList, testOldTaskItemMap, true);

        Test.stopTest();

        System.assert(!resultTaskItemMap.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_TASK_ITEM, resultTaskItemMap.size());
        System.assertEquals(taskResultSetId, resultTaskItemMap.keySet());
    }

    private static testmethod void testFilterTasksWithUpdatedActualDateNotIsStartDate(){
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, false);
        Id notMilestoneRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Task_Item__c' AND Name != 'Milestone'][0].Id;
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.RecordTypeId = notMilestoneRecordTypeId;
            taskItemItem.Actual_Start_Date__c = null;
            taskItemItem.Actual_End_Date__c = null;
        }
        insert testTaskItemList;
        Map<Id, Task_Item__c> testOldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> taskResultSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemList[i].Actual_End_Date__c = DateTime.now();
            taskResultSetId.add(testTaskItemList[i].Id);
        }

        Map<Id, Task_Item__c> resultTaskItemMap;

        Test.startTest();

            resultTaskItemMap = TaskItemServices.filterTasksWithUpdatedActualDate(testTaskItemList, testOldTaskItemMap, false);

        Test.stopTest();

        System.assert(!resultTaskItemMap.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_TASK_ITEM, resultTaskItemMap.size());
        System.assertEquals(taskResultSetId, resultTaskItemMap.keySet());
    }

    private static testmethod void testCalculateActualDurationForTasks(){
        createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_Start_Date__c = null;
            taskItemItem.Actual_End_Date__c = null;
            taskItemItem.Actual_Duration__c = '';
        }
        insert testTaskItemList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_Start_Date__c = DateTime.now();
            taskItemItem.Actual_End_Date__c = DateTime.now().addDays(20);
        }

        Test.startTest();

            TaskItemServices.calculateActualDurationForTasks(new Map<Id, Task_Item__c>(testTaskItemList));

        Test.stopTest();

        for (Task_Item__c taskItemItem : testTaskItemList){
            System.assert(!String.isEmpty(taskItemItem.Actual_Duration__c));
        }
    }

    private static testmethod void testGetTaskLinesForConditionalTaskTemplates(){
        getRecordTypes();
        List<sObject> testListForUpsert = new List<sObject>();
        Map<Id, List<Task_Template__c>> serviceTemplateWithTaskTemplate = new Map<Id, List<Task_Template__c>>();
        //create Service Templates
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testServiceTemplateAlternativeList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
            testListForUpsert.add(serviceTemplateItem);
        }
        for (Service_Template__c serviceTemplateItem : testServiceTemplateAlternativeList){
            serviceTemplateItem.RecordTypeId = serviceTemplateSubserviceRecordTypeId;
            testListForUpsert.add(serviceTemplateItem);
        }
        insert testListForUpsert;

        testListForUpsert = new List<sObject>();
        //create Task Templates
        testTaskTemplateList = new List<Task_Template__c>();
        testTaskTemplateAlternativeList = new List<Task_Template__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateWithTaskTemplate.put(serviceTemplateItem.Id, new List<Task_Template__c>());
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.RecordTypeId = taskTemplateTaskTemplateRecordTypeId;
                testTaskTemplateList.add(taskTemplateItem);
                testListForUpsert.add(taskTemplateItem);
                serviceTemplateWithTaskTemplate.get(serviceTemplateItem.Id).add(taskTemplateItem);
            }
        }
        for (Service_Template__c serviceTemplateItem : testServiceTemplateAlternativeList){
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.RecordTypeId = taskTemplateTaskTemplateRecordTypeId;
                testTaskTemplateAlternativeList.add(taskTemplateItem);
                testListForUpsert.add(taskTemplateItem);
            }
        }
        insert testListForUpsert;

        testTaskStateChangeList = TestingUtils.createTaskStateChangeList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_TEMPLATE; i++){
            testTaskStateChangeList[i].Service__c = testServiceTemplateList[i].Id;
            testTaskStateChangeList[i].Task_Line__c = testServiceTemplateAlternativeList[i].Id;
            testTaskStateChangeList[i].Related_Task__c = serviceTemplateWithTaskTemplate.get(testServiceTemplateList[i].Id)[0].Id;
            testTaskStateChangeList[i].Condition__c = DISAPPROVED_STATUS_VALUE;
        }
        insert testTaskStateChangeList;

        testTaskItemList = new List<Task_Item__c>();
        for (Task_Template__c taskTemplateItem : testTaskTemplateList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Task_Template__c = taskTemplateItem.Id;
                taskItemItem.Status__c = 'some test status';
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, List<Id>> taskTemplateWithTaskItemMap = new Map<Id, List<Id>>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            if (!taskTemplateWithTaskItemMap.containsKey(taskItemItem.Task_Template__c)){
                taskTemplateWithTaskItemMap.put(taskItemItem.Task_Template__c, new List<Id>());
            }
            taskTemplateWithTaskItemMap.get(taskItemItem.Task_Template__c).add(taskItemItem.Id);
        }

        Map<Id, Id> resultMap;

        Test.startTest();

            resultMap = TaskItemServices.getTaskLinesForConditionalTaskTemplates(taskTemplateWithTaskItemMap, new Map<Id, Task_Item__c>(testTaskItemList));
	    resultMap = TaskItemServices.getTaskLinesForConditionalTaskTemplates(null, new Map<Id, Task_Item__c>(testTaskItemList));
        Test.stopTest();

        
    }

    private static testmethod void testFilteredTaskForServiceItemUpdate(){
        testServiceItemList = TestingUtils.createServiceItemList(1, true);
        List<Task_Item__c> temporaryTaskItemInsertList = new List<Task_Item__c>();
        testMilestonesList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_MILESTONES, false);
        temporaryTaskItemInsertList.addAll(testMilestonesList);
        testTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 4, false)){
            taskItemItem.Predecessor_Milestone__c = null;
            taskItemItem.Successor_Milestone__c = null;
            taskItemItem.Service_Item__c = testServiceItemList[0].Id;
            testTaskItemList.add(taskItemItem);
        }
        temporaryTaskItemInsertList.addAll(testTaskItemList);
        insert temporaryTaskItemInsertList;

        Map<Id, Task_Item__c> oldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> resultSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemList[i].Predecessor_Milestone__c = testMilestonesList[0].Id;
            resultSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
            testTaskItemList[i].Successor_Milestone__c = testMilestonesList[0].Id;
            resultSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 2; i < NUMBER_TO_CREATE_TASK_ITEM * 3; i++){
            testTaskItemList[i].Predecessor_Milestone__c = testMilestonesList[0].Id;
            testTaskItemList[i].Successor_Milestone__c = testMilestonesList[0].Id;
            resultSetId.add(testTaskItemList[i].Id);
        }

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();

            resultTaskItemList = TaskItemServices.filteredTaskForServiceItemUpdate(testTaskItemList, oldTaskItemMap);

        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(resultSetId.size(), resultTaskItemList.size());
        System.assertEquals(resultSetId, new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    private static testmethod void testUpdateServiceActualEndDateOnly(){
        testBusinessHours = [SELECT Id
                             FROM BusinessHours
                             WHERE IsDefault=true];

        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Actual_Start_Date__c = null;
            serviceItemItem.Actual_End_Date__c = null;
            serviceItemItem.Actual_Duration__c = null;
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> serviceItemIdWithTaskItems = new Map<Id, List<Task_Item__c>>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemIdWithTaskItems.put(serviceItemItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, false)){
                taskItemItem.Actual_Start_Date__c = null;
                taskItemItem.Actual_End_Date__c = null;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Status__c = 'RFI in Process';
                testTaskItemList.add(taskItemItem);
                serviceItemIdWithTaskItems.get(serviceItemItem.Id).add(taskItemItem);
            }
        }
        insert testTaskItemList;

        for (Service_Item__c serviceItemItem : testServiceItemList){
            List<Task_Item__c> temporaryTaskItemList = serviceItemIdWithTaskItems.get(serviceItemItem.Id);
            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){//2
                temporaryTaskItemList[i].Actual_Start_Date__c = DateTime.now().addDays(-(i * 2));
                temporaryTaskItemList[i].Actual_End_Date__c = DateTime.now().addDays(-i);
                temporaryTaskItemList[i].Status__c = 'Completed';
            }

            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){//3.1
                temporaryTaskItemList[i].Actual_Start_Date__c = DateTime.now().addDays(-(i * 2));
                temporaryTaskItemList[i].Actual_End_Date__c = DateTime.now().addDays(-i);
                temporaryTaskItemList[i].Status__c = 'Completed';
            }
        }

        update testTaskItemList;

        for (Service_Item__c serviceItemItem : testServiceItemList){
            List<Task_Item__c> temporaryTaskItemList = serviceItemIdWithTaskItems.get(serviceItemItem.Id);
            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){//2
                temporaryTaskItemList[i].Actual_End_Date__c = temporaryTaskItemList[i].Actual_End_Date__c.addDays(-i);
            }

            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){//3.1
                temporaryTaskItemList[i].Actual_End_Date__c = temporaryTaskItemList[i].Actual_End_Date__c.addDays(i);
            }
        }

        Test.startTest();
            update testTaskItemList;
        Test.stopTest();
        List<Service_Item__c> testResultServiceItemList = [ SELECT Id, Actual_Start_Date__c, Actual_End_Date__c, Actual_Duration__c,
                                                                (Select Id, Actual_Start_Date__c, Actual_End_Date__c, Actual_Duration__c
                                                                 From Task_Items__r)
                                                            FROM Service_Item__c
                                                            WHERE Id IN: testServiceItemList ];

        System.assert(!testResultServiceItemList.isEmpty());
        System.assertEquals(testServiceItemList.size(), testResultServiceItemList.size());


    }

    private static testmethod void testFilterTaskItemsToCreateReminders(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWABLE_SERVICE;
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> serviceItemIdWithTaskItems = new Map<Id, List<Task_Item__c>>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemIdWithTaskItems.put(serviceItemItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 4, false)){
                taskItemItem.Reminder_Offset__c = 0.0;
                taskItemItem.Expiration_Date__c = null;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Service_Issuance__c, Reminder_Offset__c, Expiration_Date__c, Service_Item__c, Disable_Reminder__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Map<Id, Task_Item__c> testOldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        for (Task_Item__c taskItemItem : testTaskItemList){
            serviceItemIdWithTaskItems.get(taskItemItem.Service_Item__c).add(taskItemItem);
        }

        Set<Id> resultSetId = new Set<Id>();

        for (Service_Item__c serviceItemItem : testServiceItemList){
            List<Task_Item__c> temporaryTaskItemList = serviceItemIdWithTaskItems.get(serviceItemItem.Id);
            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
                temporaryTaskItemList[i].Reminder_Offset__c = TEST_REMINDER_OFFSET;
                resultSetId.add(temporaryTaskItemList[i].Id);
            }

            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
                temporaryTaskItemList[i].Expiration_Date__c = DateTime.now();
                resultSetId.add(temporaryTaskItemList[i].Id);
            }

            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
                temporaryTaskItemList[i].Reminder_Offset__c = TEST_REMINDER_OFFSET;
                temporaryTaskItemList[i].Expiration_Date__c = DateTime.now();
                resultSetId.add(temporaryTaskItemList[i].Id);
            }
        }

        Map<Id, Task_Item__c> testResultTaskItemMap;

        Test.startTest();
            testResultTaskItemMap = TaskItemServices.filterTaskItemsToCreateReminders(new Map<Id, Task_Item__c>(testTaskItemList), testOldTaskItemMap);
        Test.stopTest();

        System.assert(!testResultTaskItemMap.isEmpty());
        System.assertEquals(resultSetId, testResultTaskItemMap.keySet());
    }

    private static testmethod void testCreateEventRemindersForProjectManager(){
        setupData();
        createProjectProfileProposalListsForTest( true );

        Map<Id, Map<Id, List<Task_Item__c>>> ProjectProfileWithServiceWithTask = new Map<Id, Map<Id, List<Task_Item__c>>>();

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            ProjectProfileWithServiceWithTask.put(projectProfileItem.Id, new Map<Id, List<Task_Item__c>>());
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWABLE_SERVICE;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            ProjectProfileWithServiceWithTask.get(serviceItemItem.Project_Profile__c).put(serviceItemItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 3, false)){
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Activation_Date__c = null;
                taskItemItem.Expiration_Date__c = null;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Project_Profile__c, Service_Item__c, Activation_Date__c, Expiration_Date__c,
                                    Service_Issuance__c, Reminder_Offset__c, Project_Profile__r.Project_Manager__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        for (Task_Item__c taskItemItem :testTaskItemList){
            ProjectProfileWithServiceWithTask.get(taskItemItem.Project_Profile__c).get(taskItemItem.Service_Item__c).add(taskItemItem);
        }

        testEventList = new List<Event>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            List<Task_Item__c> temporaryTaskItemList = ProjectProfileWithServiceWithTask.get(serviceItemItem.Project_Profile__c).get(serviceItemItem.Id);

            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
                temporaryTaskItemList[i].Reminder_Offset__c = null;
                temporaryTaskItemList[i].Expiration_Date__c = DateTime.now();
                temporaryTaskItemList[i].Activation_Date__c = DateTime.now();
                temporaryTaskItemList[i].Disable_Reminder__c = false;
            }
            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
                temporaryTaskItemList[i].Reminder_Offset__c = TEST_REMINDER_OFFSET;
                temporaryTaskItemList[i].Expiration_Date__c = DateTime.now().addDays(TEST_REMINDER_OFFSET.IntValue() + 2);
                temporaryTaskItemList[i].Activation_Date__c = DateTime.now();
                temporaryTaskItemList[i].Disable_Reminder__c = false;
            }
            for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 2; i < NUMBER_TO_CREATE_TASK_ITEM * 3; i++){
                temporaryTaskItemList[i].Reminder_Offset__c = TEST_REMINDER_OFFSET;
                temporaryTaskItemList[i].Expiration_Date__c = DateTime.now();
                temporaryTaskItemList[i].Activation_Date__c = DateTime.now();
                temporaryTaskItemList[i].Disable_Reminder__c = false;
            }
            //create Event for I and II Task Item group
            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
                for (Event eventItem : TestingUtils.createEventList(NUMBER_TO_CREATE_EVENT, false)){
                    eventItem.Subject = SUBJECT_REMINDER_FOR_PROJECT_MANAGER;
                    eventItem.OwnerId = temporaryTaskItemList[i].Project_Profile__r.Project_Manager__c;
                    eventItem.WhatId = temporaryTaskItemList[i].Id;
                    eventItem.StartDateTime = null;
                    eventItem.ReminderDateTime = null;
                    eventItem.DurationInMinutes = 0;
                    testEventList.add(eventItem);
                }
            }
        }
        insert testEventList;

        Map<Id, Task_Item__c> testTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList);

        Test.startTest();

            TaskItemServices.createEventRemindersForProjectManager(testTaskItemMap);

        Test.stopTest();

        List<Event> resultEventList = [SELECT Id, WhatId, Subject, StartDateTime, EndDateTime, OwnerId, Description
                                       FROM Event];

        System.assert(!resultEvEntList.isEmpty());

        for (Event eventItem : resultEventList){
            System.assert(testTaskItemMap.containsKey(eventItem.WhatId));
            Task_Item__c taskItemItem = testTaskItemMap.get(eventItem.WhatId);
            System.assertEquals(taskItemItem.Project_Profile__r.Project_Manager__c, eventItem.OwnerId);
        }
    }

    private static testmethod void testFilterTaskItemsToCreateChangeOrderWithOldMap(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWABLE_SERVICE;
        }
        insert testServiceItemList;

        Map<Id, List<Task_Item__c>> serviceWithTaskItem = new Map<Id, List<Task_Item__c>>();

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceWithTaskItem.put(serviceItemItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Request_Renewal_CO_Now__c = false;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Service_Issuance__c, Request_Renewal_CO_Now__c, Service_Item__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        Map<Id, Task_Item__c> taskItemOldMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        for (Task_Item__c taskItemItem : testTaskItemList){
            serviceWithTaskItem.get(taskItemItem.Service_Item__c).add(taskItemItem);
        }

        Set<Id> resultSetId = new Set<Id>();

        for (Service_Item__c serviceItemItem : testServiceItemList){
            List<Task_Item__c> temporaryTaskItemList = serviceWithTaskItem.get(serviceItemItem.Id);

            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
                temporaryTaskItemList[i].Request_Renewal_CO_Now__c = true;
                resultSetId.add(temporaryTaskItemList[i].Id);
            }
        }

        Map<Id, Task_Item__c> testResultTaskItemMap;

        Test.startTest();
            testResultTaskItemMap = TaskItemServices.filterTaskItemsToCreateChangeOrder(new Map<Id, Task_Item__c>(testTaskItemList), taskItemOldMap);
        Test.stopTest();

        System.assert(!testResultTaskItemMap.isEmpty(), testTaskItemList);
        System.assertEquals(resultSetId, testResultTaskItemMap.keySet());
    }
    private static testmethod void testcreateChangeOrderForRenewableTasks(){
        setupData();
        getRecordTypes();
        createProjectProfileProposalListsForTest( true );

        Integer temporaryIntegerValue = 0;

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
            serviceTemplateItem.Region__c = testRegionList[0].Id;
            serviceTemplateItem.Category__c = TEST_CATEGORY_VALUE + String.valueOf(temporaryIntegerValue);
            serviceTemplateItem.Type__c = TEST_TYPE_VALUE;
            serviceTemplateItem.Subtype__c = TEST_SUBTYPE_VALUE;
            serviceTemplateItem.Plan_Submission_Type__c = TEST_PLAN_SUBMISSION_TYPE_VALUE;
            serviceTemplateItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWAL_SERVICE;
            temporaryIntegerValue++;
        }
        insert testServiceTemplateList;

        testTaskTemplateList = new List<Task_Template__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                testTaskTemplateList.add(taskTemplateItem);
            }
        }
        insert testTaskTemplateList;

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem :testProposalList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = proposalItem.Id;
                    serviceItemItem.Project_Profile__c = proposalItem.Project_Profile__c;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = new List<Task_Item__c>();

        Test.startTest();
            TaskItemServices.createChangeOrderForRenewableTasks(new Map<Id, Task_Item__c>(testTaskItemList));
        Test.stopTest();
    }

    private static testmethod void testEventSubjectTofilterTaskItemsForEventAlertNotification(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 4, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Task_Alert__c = false;
            taskItemItem.Task_Notification__c = false;
        }
        insert testTaskItemList;

        Map<Id, Task_Item__c> oldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> resultTaskAlertSetId = new Set<Id>();
        Set<Id> resultTaskNotificationSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemList[i].Task_Alert__c = true;
            resultTaskAlertSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
            testTaskItemList[i].Task_Notification__c = true;
            resultTaskNotificationSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 2; i < NUMBER_TO_CREATE_TASK_ITEM * 3; i++){
            testTaskItemList[i].Task_Alert__c = true;
            testTaskItemList[i].Task_Notification__c = true;
            resultTaskAlertSetId.add(testTaskItemList[i].Id);
            resultTaskNotificationSetId.add(testTaskItemList[i].Id);
        }

        Map<String, List<Task_Item__c>> resultMap;

        Test.startTest();
            resultMap = TaskItemServices.eventSubjectTofilterTaskItemsForEventAlertNotification(testTaskItemList, oldTaskItemMap);
        Test.stopTest();

        System.assert(!resultMap.isEmpty());
        System.assertEquals(2, resultMap.size());
        System.assert(resultMap.containsKey(EventServices.TASK_ALERT_SUBJECT) && resultMap.containsKey(EventServices.TASK_NOTIFICATION_SUBJECT));
        System.assertEquals(resultTaskAlertSetId, new Map<Id, Task_Item__c>(resultMap.get(EventServices.TASK_ALERT_SUBJECT)).keySet());
        System.assertEquals(resultTaskNotificationSetId, new Map<Id, Task_Item__c>(resultMap.get(EventServices.TASK_NOTIFICATION_SUBJECT)).keySet());
    }

    private static testmethod void testFilterTaskItemsForEventAlertNotificationDelete(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 4, false);
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Task_Alert__c = true;
            taskItemItem.Task_Notification__c = true;
        }
        insert testTaskItemList;

        Map<Id, Task_Item__c> oldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> resultTaskSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            testTaskItemList[i].Task_Alert__c = false;
            resultTaskSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
            testTaskItemList[i].Task_Notification__c = false;
            resultTaskSetId.add(testTaskItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM * 2; i < NUMBER_TO_CREATE_TASK_ITEM * 3; i++){
            testTaskItemList[i].Task_Alert__c = false;
            testTaskItemList[i].Task_Notification__c = false;
            resultTaskSetId.add(testTaskItemList[i].Id);
        }

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.filterTaskItemsForEventAlertNotificationDelete(testTaskItemList, oldTaskItemMap);
        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(resultTaskSetId.size(), resultTaskItemList.size());
        System.assertEquals(resultTaskSetId, new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    private static testmethod void testGetTaskItemByServiceItemId(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, true);
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.getTaskItemByServiceItemId(testServiceItemList[0].Id);
        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_TASK_ITEM, resultTaskItemList.size());
        for (Task_Item__c taskItemItem : resultTaskItemList){
            System.assertEquals(testServiceItemList[0].Id, taskItemItem.Service_Item__c);
        }
    }

    private static testmethod void testFilterCompleteFormsTaskItems(){
        testTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
            taskItemItem.Name = TaskItemServices.COMPLETE_FORMS_TASK_NAME;
            testTaskItemList.add(taskItemItem);
        }

        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
            taskItemItem.Name = 'same test Task Item Name';
            testTaskItemList.add(taskItemItem);
        }

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.filterCompleteFormsTaskItems(testTaskItemList);
        Test.stopTest();

        System.assert(!resultTaskItemList.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_TASK_ITEM, resultTaskItemList.size());
        for (Task_Item__c taskItemItem : resultTaskItemList){
            System.assertEquals(TaskItemServices.COMPLETE_FORMS_TASK_NAME, taskItemItem.Name);
        }
    }

    private static testmethod void testGetTaskItemById(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        Task_Item__c resultTaskItem;

        Test.startTest();
            resultTaskItem = TaskItemServices.getTaskItemById(testTaskItemList[0].Id);
        Test.stopTest();

        System.assert(resultTaskItem != null);
        System.assertEquals(testTaskItemList[0].Id, resultTaskItem.Id);
    }

    private static testmethod void testFilterExpectedEndDateTasks(){
        setupData ();
        createProjectProfileListsForTest(NUMBER_TO_CREATE_PROJECT_PROFILE * 2, true);
        Map<Id, List<Task_Item__c>> projectWithTaskItems = new Map<Id, List<Task_Item__c>>();
        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c prijectProfileItem : testProjectProfileList){
            projectWithTaskItems.put(prijectProfileItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, false)){
                taskItemItem.Expected_End_Date__c = null;
                taskItemItem.Project_Profile__c = prijectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
                projectWithTaskItems.get(prijectProfileItem.Id).add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, Task_Item__c> oldTaskItemMap = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        Set<Id> resultProjectProfileSetId = new Set<Id>();

        for (Integer j = 0; j < NUMBER_TO_CREATE_PROJECT_PROFILE; j++){
            for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
                projectWithTaskItems.get(testProjectProfileList[j].Id)[i].Expected_End_Date__c = DateTime.now();
            }
            resultProjectProfileSetId.add(testProjectProfileList[j].Id);
        }

        Set<Id> resultSet;

        Test.startTest();
            resultSet = TaskItemServices.filterExpectedEndDateTasks(testTaskItemList, oldTaskItemMap);
        Test.stopTest();

        System.assert(!resultSet.isEmpty());
        System.assertEquals(resultProjectProfileSetId.size(), resultSet.size());
        System.assertEquals(resultProjectProfileSetId, resultSet);
    }
    
    private static testmethod void testCreateBillingLineItemsFromTaskItems(){
        setupData ();
	prepareData ();

        Test.startTest();
	    testTaskItemList[0].RecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get( TaskItemServices.PERFORM_HOURLY_CONSULTING_TASK_NAME );
            TaskItemServices.createBillingLineItemsFromTaskItems( new Map<Id, Task_Item__c>(testTaskItemList), null);
	    TaskItemServices.createBillingLineItemsFromTaskItems( new Map<Id, Task_Item__c>(testTaskItemList), new Map<Id, Project_Profile__c>(testProjectProfileList));
        Test.stopTest();
    }
    
    private static testMethod void testAttachTasksToProjectProfiles(){
        setupData ();
        prepareData ();
        createTaskTemplateList(false);
        for (Task_Template__c taskTemplateItem : testTaskTemplateList){
            taskTemplateItem.Resources__c = 'NY' + UserServices.ROLE_OPERATIONS_MANAGER;
        }
        insert testTaskTemplateList;
        
        Map<Id, String> taskTemplIdToTotalDuration = new Map<Id, String>();
        Map<Id, Map<Id, Task_Template__c>> serviceIdToTasksTemplates = new Map<Id, Map<Id, Task_Template__c>>();
        for( Task_Template__c tmpl : testTaskTemplateList){
            taskTemplIdToTotalDuration.put(tmpl.Id, '1d');
            
            if( !serviceIdToTasksTemplates.containsKey( tmpl.Service__c ) ) {
                serviceIdToTasksTemplates.put( tmpl.Service__c, new Map<Id, Task_Template__c>() );
            }
            serviceIdToTasksTemplates.get( tmpl.Service__c ).put( tmpl.Id, tmpl );
        }

        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.OwnerId = UserInfo.getUserId();
        }

        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
        }

        Test.startTest();
            TaskItemServices.attachTasksToProjectProfiles( new Map<Id, Service_Item__c>(testServiceItemList),
                                                           serviceIdToTasksTemplates,
                                                           taskTemplIdToTotalDuration,
                                                           testProposalList,
                                                           new Map<Id, Project_Roster__c>(),
                                                           false );
							   
	    TaskItemServices.attachTasksToProjectProfiles( new Map<Id, Service_Item__c>(testServiceItemList),
                                                           serviceIdToTasksTemplates,
                                                           taskTemplIdToTotalDuration,
                                                           testProposalList,
                                                           new Map<Id, Project_Roster__c>(),
                                                           true );
        Test.stopTest();
    }
    
    private static testMethod void testInsertAlternativeTaskLineToConditionalTasks(){
        setupData();
        getRecordTypes();
        List<sObject> testListForUpsert = new List<sObject>();
        Map<Id, List<Task_Template__c>> serviceTemplateWithTaskTemplate = new Map<Id, List<Task_Template__c>>();
        //create Service Templates
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        testServiceTemplateAlternativeList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
            testListForUpsert.add(serviceTemplateItem);
        }
        for (Service_Template__c serviceTemplateItem : testServiceTemplateAlternativeList){
            serviceTemplateItem.RecordTypeId = serviceTemplateSubserviceRecordTypeId;
            testListForUpsert.add(serviceTemplateItem);
        }
        insert testListForUpsert;

        testListForUpsert = new List<sObject>();
        //create Task Templates
        testTaskTemplateList = new List<Task_Template__c>();
        testTaskTemplateAlternativeList = new List<Task_Template__c>();
        Integer taskSeqNumber;
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            taskSeqNumber = 1;
            serviceTemplateWithTaskTemplate.put(serviceTemplateItem.Id, new List<Task_Template__c>());
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                if (taskSeqNumber == 1) taskTemplateItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.RecordTypeId = taskTemplateTaskTemplateRecordTypeId;
                taskTemplateItem.Sequence_Number__c = taskSeqNumber++;
                testTaskTemplateList.add(taskTemplateItem);
                testListForUpsert.add(taskTemplateItem);
                serviceTemplateWithTaskTemplate.get(serviceTemplateItem.Id).add(taskTemplateItem);
            }
        }
        for (Service_Template__c serviceTemplateItem : testServiceTemplateAlternativeList){
            taskSeqNumber = NUMBER_TO_CREATE_TASK_TEMPLATE+1;
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.RecordTypeId = taskTemplateTaskTemplateRecordTypeId;
                taskTemplateItem.Sequence_Number__c = taskSeqNumber++;
                testTaskTemplateAlternativeList.add(taskTemplateItem);
                testListForUpsert.add(taskTemplateItem);
            }
        }
        insert testListForUpsert;

        testTaskStateChangeList = TestingUtils.createTaskStateChangeList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_TEMPLATE; i++){
            testTaskStateChangeList[i].Service__c = testServiceTemplateList[i].Id;
            testTaskStateChangeList[i].Task_Line__c = testServiceTemplateAlternativeList[i].Id;
            testTaskStateChangeList[i].Related_Task__c = serviceTemplateWithTaskTemplate.get(testServiceTemplateList[i].Id)[0].Id;
            testTaskStateChangeList[i].Condition__c = DISAPPROVED_STATUS_VALUE;
        }
        insert testTaskStateChangeList;

        testTaskItemList = new List<Task_Item__c>();
        for (Task_Template__c taskTemplateItem : testTaskTemplateList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Task_Template__c = taskTemplateItem.Id;
                taskItemItem.Status__c = 'some test status';
                taskItemItem.Sequence_Number__c = taskTemplateItem.Sequence_Number__c;
                taskItemItem.OwnerId = projectManagerUser.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, Id> testTaskTemplateIdTaskItemIdMap = new Map<Id, Id>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            testTaskTemplateIdTaskItemIdMap.put(taskItemItem.Task_Template__c, taskItemItem.Id);
            taskItemItem.Status__c = DISAPPROVED_STATUS_VALUE;
        }
        
        Test.startTest();
            TaskItemServices.insertAlternativeTaskLineToConditionalTasks(new Map<Id, Task_Item__c>(testTaskItemList));
	    TaskItemServices.runInFutureMethod = true;
	    TaskItemServices.insertAlternativeTaskLineToConditionalTasks(new Map<Id, Task_Item__c>(testTaskItemList));
        Test.stopTest();
    }
    
    private static testMethod void testUpdateServiceItemPredecessorSuccessor(){
        setupData ();
        prepareData ();
        
        Test.startTest();
            TaskItemServices.updateServiceItemPredecessorSuccessor( testTaskItemList);
        Test.stopTest();
        
    }

    private static testMethod void testUpdateServiceActualStartDateActualEndDate(){
        setupData ();
        prepareData ();

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Planned_Start_Date__c = Date.today();
        }
        update testTaskItemList;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        update testProjectProfileList;

        Map<String, Map<Id, Task_Item__c>> changedTaskStartEndDateMap = new Map<String, Map<Id, Task_Item__c>> {TaskItemServices.START_DATE_FIELD => new Map<Id, Task_Item__c>(testTaskItemList),
                                                                                                                TaskItemServices.END_DATE_FIELD => new Map<Id, Task_Item__c>()};

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Status__c = 'RFI in Process';
            taskItemItem.Actual_Start_Date__c = DateTime.now().addDays(-1);
        }
        update testTaskItemList;

        Test.startTest();
            TaskItemServices.updateServiceActualStartDateActualEndDate (changedTaskStartEndDateMap, null);
        Test.stopTest();
    }

    //+== ProjectProfileServices.BILLINGMETHODMILESTONE
    private static testmethod void testCreateBillingLineItemsFromTaskItemsBILLINGMETHODMILESTONE(){
        setupData ();
        prepareData ();

        Test.startTest();
            TaskItemServices.createBillingLineItemsFromTaskItems( new Map<Id, Task_Item__c>(testTaskItemList), null);
        Test.stopTest();
    }
    
     private static testmethod void testCreateBillingLineItemsFromTaskItemsBILLINGMETHODMILESTONESecondCondtion(){
        setupData ();
        prepareData ();

        Test.startTest();
            TaskItemServices.createBillingLineItemsFromTaskItems( new Map<Id, Task_Item__c>(testTaskItemList), null);
        Test.stopTest();
    }

//test updateExpectedDatesForAllServices method for updating Actual Start Date
    private static testmethod void testUpdateExpectedDatesForAllServicesChangeActualStartDate(){
        getRecordTypes ();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(1, false);//method works with one Project Profile
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_Start_Date__c = Date.today().addDays(-1);
        }
        insert testProjectProfileList;

        testMilestonesList = new List<Task_Item__c>();

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Is_Alternative__c = false;
                serviceItemItem.Original__c = true;
                serviceItemItem.Successor_Milestone__c = 'Project End';
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            Integer taskSequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;//using for populated Sequence Number
            for(Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Sequence_Number__c = taskSequenceNumberItem;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Planned_Start_Date__c = Date.today();
                taskItemItem.Predecessor_Milestone_from_Template__c = (taskSequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE) ?
                                                                                                    TaskManagementServices.MILESTONE_PROJECT_START : '';
                taskItemItem.Successor_Milestone_from_Template__c = (taskSequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM) ?
                                                                                                    'Project End' : '';
                taskSequenceNumberItem++;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        update testProjectProfileList;

        testTaskItemList[0].Actual_Start_Date__c = DateTime.now();
        testTaskItemList[0].Status__c = 'Started';

        Test.startTest();

            update testTaskItemList[0];
	    TaskItemServices.updateExpectedDatesForAllServices( new Map<Id, Task_Item__c>(testTaskItemList), true );
	    TaskItemServices.updateExpectedDatesForAllServices( new Map<Id, Task_Item__c>(testTaskItemList), false );

        Test.stopTest();
    }

//test updateExpectedDatesForAllServices method for updating Actual End Date
    private static testmethod void testUpdateExpectedDatesForAllServicesChangeActualEndDate(){
        getRecordTypes ();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(1, false);//method works with one Project Profile
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_Start_Date__c = Date.today().addDays(-1);
        }
        insert testProjectProfileList;

        testMilestonesList = new List<Task_Item__c>();

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                serviceItemItem.Is_Alternative__c = false;
                serviceItemItem.Original__c = true;
                serviceItemItem.Successor_Milestone__c = 'Project End';
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            Integer taskSequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;//using for populated Sequence Number
            for(Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Sequence_Number__c = taskSequenceNumberItem;
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Expected_Start_Date__c = Date.today();
                taskItemItem.Planned_Start_Date__c = Date.today();
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Predecessor_Milestone_from_Template__c = (taskSequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE) ?
                                                                                                    TaskManagementServices.MILESTONE_PROJECT_START : '';
                taskItemItem.Successor_Milestone_from_Template__c = (taskSequenceNumberItem == NUMBER_TO_CREATE_TASK_ITEM) ?
                                                                                                    'Project End' : '';
                taskSequenceNumberItem++;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Task_Item__c testTaskItemForUpdate = [SELECT Id, Status__c FROM Task_Item__c WHERE Id =: testTaskItemList[0].Id][0];

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        update testProjectProfileList;

        testTaskItemForUpdate.Status__c = 'Started';
        update testTaskItemForUpdate;

        testTaskItemForUpdate.Status__c = 'Complete';


        Test.startTest();

            update testTaskItemForUpdate;

        Test.stopTest();
    }

    private static testmethod void testUpdateTaskItemPackageStatus(){
        List<Service_Item__c> serviceItems = TestingUtils.createServiceItemList(1, true);
        Service_Item__c serviceItem = serviceItems[0];
        List<Task_Item__c> taskItems = TestingUtils.createTaskItemList(1, false);
        for(Task_Item__c taskItem : taskItems) {
            taskItem.Service_Item__c = serviceItem.Id;
        }
        insert taskItems;
        List<Form_Item__c> formItems = TestingUtils.createFormItemList(5, false);
        for(Form_Item__c formItem : formItems) {
            formItem.Service_Item__c = serviceItem.Id;
        }
        insert formItems;
        for(Task_Item__c taskItem : taskItems) {
            taskItem.Package_Status__c = 'Started';
        }
        Test.startTest();
            update taskItems;
        Test.stopTest();
    }

    private static testmethod void testFilteredProjectTeamIdToProjectProfileIdSet(){
        getRecordTypes();
        setupData ();
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testTaskItemList = new List<Task_Item__c>();
        for(Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, Task_Item__c> testMapIdTaskItemOld = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_End_Date__c = DateTime.now().addDays(-2);
            testMapIdTaskItemOld.get(taskItemItem.Id).Actual_End_Date__c = taskItemItem.Actual_End_Date__c.addDays(1);
        }

        Map<Id, Set<Id>> resultProjectTeamWithProjectProfiles;

        Test.startTest();

            resultProjectTeamWithProjectProfiles = TaskItemServices.filteredProjectTeamIdToProjectProfileIdSet(testTaskItemList, testMapIdTaskItemOld);

        Test.stopTest();

        System.assert(resultProjectTeamWithProjectProfiles != null && !resultProjectTeamWithProjectProfiles.isEmpty());
    }

    private static testmethod void testUpdateActualEndDateForMilestoneOneTaskItemProdecessorActualStartDateOneTask(){
        Integer taskItemCount = 1;
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testMilestonesList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> mapProjectWithMilestones = new Map<Id, List<Task_Item__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            mapProjectWithMilestones.put(projectProfileItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = TaskManagementServices.MILESTONE_PROJECT_START;
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = 'Project End';
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
        }
        insert testMilestonesList;

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Integer sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for(Task_Item__c taskItemItem : TestingUtils.createTaskItemList(taskItemCount, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? mapProjectWithMilestones.get(projectProfileItem.Id)[0].Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == taskItemCount ? mapProjectWithMilestones.get(projectProfileItem.Id)[1].Id : null;
                taskItemItem.Actual_Start_Date__c = DateTime.now();
                taskItemItem.Status__c = 'Started';
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
        }
        insert testTaskItemList;

        Task_Item__c resultTaskItem;

        Test.startTest();

            resultTaskItem = TaskItemServices.updateActualEndDateForMilestone(testTaskItemList[0], true);
	    resultTaskItem = TaskItemServices.updateActualEndDateForMilestone(testTaskItemList[0], false);

        Test.stopTest();

        Task_Item__c taskItemForCheckResult = [SELECT Id, Actual_Start_Date__c FROM Task_Item__c WHERE Id = : testTaskItemList[0].Id];

        System.assert(resultTaskItem != null);
        //System.assertEquals(taskItemForCheckResult.Actual_Start_Date__c, resultTaskItem.Actual_Start_Date__c);
    }

    private static testmethod void testUpdateActualEndDateForMilestoneActualStartDateMoreThenOneTask(){
        Integer taskItemCount = 2;
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testMilestonesList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> mapProjectWithMilestones = new Map<Id, List<Task_Item__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            mapProjectWithMilestones.put(projectProfileItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = TaskManagementServices.MILESTONE_PROJECT_START;
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = 'Project End';
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
        }
        insert testMilestonesList;

        Map<Id, Map<Integer, Task_Item__c>> serviceTaskItemMap = new Map<Id, Map<Integer, Task_Item__c>>();


        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Predecessor_Milestone__c = mapProjectWithMilestones.get(projectProfileItem.Id)[0].Name;
                serviceItemItem.Successor_Milestone__c = mapProjectWithMilestones.get(projectProfileItem.Id)[1].Name;
                serviceItemItem.Is_Alternative__c = false;
                serviceItemItem.Applied_Amendment__c = true;
                serviceItemItem.Submitted_CO_Planned_Dates__c = true;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceTaskItemMap.put(serviceItemItem.Id, new Map<Integer, Task_Item__c>());
            Integer sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for(Task_Item__c taskItemItem : TestingUtils.createTaskItemList(taskItemCount, false)){
                taskItemItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
                taskItemItem.Expected_Start_Date__c = Date.today();
                taskItemItem.Planned_Start_Date__c = Date.today();
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? mapProjectWithMilestones.get(serviceItemItem.Project_Profile__c)[0].Id : null;
                taskItemItem.Predecessor_Milestone_from_Template__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? mapProjectWithMilestones.get(serviceItemItem.Project_Profile__c)[0].Name : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == taskItemCount ? mapProjectWithMilestones.get(serviceItemItem.Project_Profile__c)[1].Id : null;
                taskItemItem.Successor_Milestone_from_Template__c = sequenceNumberItem == taskItemCount ? mapProjectWithMilestones.get(serviceItemItem.Project_Profile__c)[1].Name : null;
                testTaskItemList.add(taskItemItem);
                serviceTaskItemMap.get(serviceItemItem.Id).put(sequenceNumberItem, taskItemItem);
                sequenceNumberItem++;
            }

        }
        insert testTaskItemList;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Submitted_Planned_Dates__c = true;
            projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS;
        }
        update testProjectProfileList;

        for (Service_Item__c serviceItemItem : testServiceItemList){
            Map<Integer, Task_Item__c> temporarySequenceNumberTaskItemMap = serviceTaskItemMap.get(serviceItemItem.Id);
            for (Integer i = TaskManagementServices.FIRST_TASK_IN_SEQUENCE; i <= temporarySequenceNumberTaskItemMap.size(); i++){
                Task_Item__c taskItemItem = temporarySequenceNumberTaskItemMap.get(i);
                taskItemItem.Successor_Task__c = temporarySequenceNumberTaskItemMap.containsKey(i + 1) ? temporarySequenceNumberTaskItemMap.get(i + 1).Id : null;
                taskItemItem.Predecessor_Task__c = temporarySequenceNumberTaskItemMap.containsKey(i - 1) ? temporarySequenceNumberTaskItemMap.get(i - 1).Id : null;
            }
        }
        update testTaskItemList;

        TaskManagementServices.seqNumberToTaskItemForService = new Map<Id, Map<Integer, Task_Item__c>>();

        Task_Item__c testProcessingTaskItem = serviceTaskItemMap.get(testServiceItemList[0].Id).get(TaskManagementServices.FIRST_TASK_IN_SEQUENCE);
        testProcessingTaskItem.Status__c = 'Started';
        testProcessingTaskItem.Actual_Start_Date__c = dateTime.now();
        update testProcessingTaskItem;

        Task_Item__c resultTaskItem;

        Test.startTest();

            resultTaskItem = TaskItemServices.updateActualEndDateForMilestone(testProcessingTaskItem, true);

        Test.stopTest();

        Task_Item__c taskItemForCheckResult = [SELECT Id, Actual_Start_Date__c FROM Task_Item__c WHERE Id = : testTaskItemList[0].Id];

        System.assert(resultTaskItem != null);
        System.assertEquals(taskItemForCheckResult.Actual_Start_Date__c, resultTaskItem.Actual_Start_Date__c);
    }

    private static testmethod void testUpdateActualEndDateForMilestoneOneTaskItemProdecessorActualEndDateOneTask(){
        Integer taskItemCount = 1;
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testMilestonesList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> mapProjectWithMilestones = new Map<Id, List<Task_Item__c>>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            mapProjectWithMilestones.put(projectProfileItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = TaskManagementServices.MILESTONE_PROJECT_START;
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                taskItemItem.Name = 'Project End';
                testMilestonesList.add(taskItemItem);
                mapProjectWithMilestones.get(projectProfileItem.Id).add(taskItemItem);
            }
        }
        insert testMilestonesList;

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Integer sequenceNumberItem = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for(Task_Item__c taskItemItem : TestingUtils.createTaskItemList(taskItemCount, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Sequence_Number__c = sequenceNumberItem;
                taskItemItem.Predecessor_Milestone__c = sequenceNumberItem == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ? mapProjectWithMilestones.get(projectProfileItem.Id)[0].Id : null;
                taskItemItem.Successor_Milestone__c = sequenceNumberItem == taskItemCount ? mapProjectWithMilestones.get(projectProfileItem.Id)[1].Id : null;
                taskItemItem.Actual_Start_Date__c = DateTime.now();
                taskItemItem.Status__c = 'Started';
                testTaskItemList.add(taskItemItem);
                sequenceNumberItem++;
            }
        }
        insert testTaskItemList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_End_Date__c = DateTime.now();
            taskItemItem.Status__c = 'Complete';
        }

        Task_Item__c resultTaskItem;

        Test.startTest();

            resultTaskItem = TaskItemServices.updateActualEndDateForMilestone(testTaskItemList[0], true);

        Test.stopTest();

        Task_Item__c taskItemForCheckResult = [SELECT Id, Actual_End_Date__c, Successor_Milestone__c FROM Task_Item__c WHERE Id = : testTaskItemList[0].Id];

        System.assert(resultTaskItem != null);

    }

    private static testmethod void testFilterPickupAnalyzeFromTaskItems(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWABLE_SERVICE;
        }
        insert testServiceItemList;
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.RecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get(TaskItemServices.PICKUP_ANALIZE_TASK_NAME);
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testtaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.filterPickupAnalyze(testTaskItemList);
        Test.stopTest();

        System.assert(resultTaskItemList != null && !resultTaskItemList.isEmpty());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    private static testmethod void testFilterPickupAnalyzeFromServiceItems(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Issuance__c = TaskItemServices.TASK_STATUS_RENEWABLE_SERVICE;
        }
        insert testServiceItemList;
        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get(TaskItemServices.PICKUP_ANALIZE_TASK_NAME);
                taskItemItem.Name = TaskItemServices.PICKUP_ANALIZE_TASK_NAME;
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                testtaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        List<Task_Item__c> resultTaskItemList;

        Test.startTest();
            resultTaskItemList = TaskItemServices.filterPickupAnalyze(testServiceItemList);
        Test.stopTest();

        System.assert(resultTaskItemList != null && !resultTaskItemList.isEmpty());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskItemList).keySet());
    }

    //for test coverage only
    private static testmethod void testUpdatePickupAnalyze(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        Test.startTest();
	    testTaskItemList[0].RecordTypeId = TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get( TaskItemServices.PICKUP_ANALIZE_RENEWABLE_OR_RENEWAL_TASK_NAME );
            TaskItemServices.updatePickupAnalyze( testTaskItemList );
        Test.stopTest();
    }

    //for test coverage only
    private static testmethod void testUpdatePickupAnalyzeWithIncorrectData(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, true);

        Id incorrectId = Task_Item__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000';
        testTaskItemList.add(new Task_Item__c(Id = incorrectId));

        String errorString;

        Test.startTest();

            try{
                TaskItemServices.updatePickupAnalyze(testTaskItemList);
            } catch (Exception ex) {}

        Test.stopTest();
    }

    private static testmethod void testFilteredTaskItemForRecalculateProjectTeamExpectedDurationInsert(){
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Project_Team__c, Expected_Duration__c, RecordTypeId
                            FROM Task_Item__c
                            WHERE Id IN : TestTaskItemList];

        for(Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_End_Date__c = null;
            taskItemItem.Expected_Duration__c = '0d 0h 1m';
        }

        List<Task_Item__c> resultTaskitemList;

        Test.startTest();

            resultTaskitemList = TaskItemServices.filteredTaskItemForRecalculateProjectTeamExpectedDuration(testTaskItemList, null);

        test.stopTest();

        System.assert(!resultTaskitemList.isEmpty());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskitemList).keySet());
    }

    private static testmethod void testFilteredTaskItemForRecalculateProjectTeamExpectedDurationUpdate(){
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Project_Team__c, Expected_Duration__c, RecordTypeId
                            FROM Task_Item__c
                            WHERE Id IN : TestTaskItemList];

        Map<Id, Task_Item__c> testMapIdTaskItemOld = new Map<Id, Task_Item__c>(testTaskItemList.deepClone(true));

        for(Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Actual_End_Date__c = null;
            taskItemItem.Expected_Duration__c = '0d 0h 1m';
        }

        List<Task_Item__c> resultTaskitemList;

        Test.startTest();

            resultTaskitemList = TaskItemServices.filteredTaskItemForRecalculateProjectTeamExpectedDuration(testTaskItemList, testMapIdTaskItemOld);

        Test.stopTest();

        System.assert(!resultTaskitemList.isEmpty());
        System.assertEquals(new Map<Id, Task_Item__c>(testTaskItemList).keySet(), new Map<Id, Task_Item__c>(resultTaskitemList).keySet());
    }

    private static testmethod void testUpdateProjectTeamExpectedDurationInsert(){
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Actual_End_Date__c = null;
                taskItemItem.Expected_Duration__c = '0d 0h 1m';
                testTaskItemList.add(taskItemItem);
            }
        }

        Test.startTest();

            insert testTaskItemList;

        Test.stopTest();

        
    }

    private static testmethod void testUpdateProjectTeamExpectedDurationUpdate(){
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Actual_End_Date__c = null;
                taskItemItem.Expected_Duration__c = '0d 0h 1m';
                testTaskItemList.add(taskItemItem);
            }
        }

        insert testTaskItemList;

        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemItem.Expected_Duration__c = '0d 0h 15m';
        }

        Test.startTest();

            update testTaskItemList;

        Test.stopTest();

        
    }

    private static testmethod void testgetTaskItemsByIdsForVendorRequestsEmptyParameter() {
        Test.startTest();
            List<Task_Item__c> tskItems = TaskItemServices.getTaskItemsByIdsForVendorRequests(null);
	    Integer serviceItemCount = TaskItemServices.SERVICE_ITEM_COUNT;
        Test.stopTest();
    
    }
    
    private static testmethod void testgetTaskItemsByIdsForVendorRequests() {
        getRecordTypes();
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.Actual_End_Date__c = null;
                taskItemItem.Expected_Duration__c = '0d 0h 1m';
                testTaskItemList.add(taskItemItem);
            }
        }

        insert testTaskItemList;
        Set<Id> taskItemIds = new Set<Id>();
        
        for (Task_Item__c ti : testTaskItemList) {
            taskItemIds.add(ti.Id);
        
        }
        Test.startTest();
            List<Task_Item__c> tskItems = TaskItemServices.getTaskItemsByIdsForVendorRequests(taskItemIds);
        Test.stopTest();
    
    }
    
    private static testmethod void testConvertRecrdTypeNameToCustomSettingName() {
        String recordName;
        try {
            recordName = TaskItemServices.convertRecrdTypeNameToCustomSettingName(null);
        
        } catch (Exception ex) {}
        
        recordName = TaskItemServices.convertRecrdTypeNameToCustomSettingName(TaskItemServices.PICKUP_ANALYZE_ARTIFACTS_CUSTOM_SETTING_NAME);
        recordName = TaskItemServices.convertRecrdTypeNameToCustomSettingName(TaskItemServices.TRACK_FROM_PROCESSING_CUSTOM_SETTING_NAME);
        recordName = TaskItemServices.convertRecrdTypeNameToCustomSettingName('test');
    
    }
    
    private static testmethod void testfilteredTaskItemsToInCompleteStatusEmptyParam() {
        Set<Id> ids = TaskItemServices.filteredTaskItemsToInCompleteStatus(null, new List<Task_Item__c>());
    }
    
    private static testmethod void testfilteredTaskItemsToInCompleteStatus() {
        setupData ();
        prepareData ();
    	Map<Id, Task_Item__c> idToTaskItemsMap = new Map<Id, Task_Item__c>(testTaskItemList);
	testTaskItemList[0].Status__c = 'Complete';
    	Set<Id> ids = TaskItemServices.filteredTaskItemsToInCompleteStatus(idToTaskItemsMap, testTaskItemList);
    }
    
    private static testmethod void testfilteredTaskItemsToCompleteStatusEmptyParam() {
        setupData ();
        prepareData ();
	testTaskItemList[0].Status__c = 'Complete';
	Map<Id, Task_Item__c> idToTaskItemsMap = new Map<Id, Task_Item__c>(testTaskItemList);
	testTaskItemList[0].Status__c = 'In Progress';
	Set<Id> ids = TaskItemServices.filteredTaskItemsToCompleteStatus(idToTaskItemsMap, testTaskItemList);
    }
    

        
}