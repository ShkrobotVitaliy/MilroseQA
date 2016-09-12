@isTest
private class TestRedirectBillingTriggersController {
	private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
	private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 3;
	private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 4;
	private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 5;
	private static final Decimal TEST_BILLING_PERCENTAGE_VALUE = 1.2;

	private static List<Project_Team__c> testProjectTeamList;
	private static List<Proposal__c> testProposalList;
	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;

	private static List<Service_Template__c> testServiceTemplateList;
	private static List<Task_Template__c> testTaskTemplateList;
	private static List<Change_Order__c> testChangeOrderList;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Task_Item__c> testTaskItemList;
	private static List<DDP_Helper__c> testDDPHelperList;

	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static PageReference testPage;
	private static ApexPages.StandardController testStandardController;
	private static RedirectBillingTriggersController testController;

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

	private static void prerareDataForTest(){
		testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);

		Map<Id, List<Task_Template__c>> serviceTemplateWithTaskTemplate = new Map<Id, List<Task_Template__c>>();
		testTaskTemplatelist = new List<Task_Template__c>();
		for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
			serviceTemplateWithTaskTemplate.put(serviceTemplateItem.Id, new List<Task_Template__c>());
			for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
				taskTemplateItem.Service__c = serviceTemplateItem.Id;
				testTaskTemplatelist.add(taskTemplateItem);
				serviceTemplateWithTaskTemplate.get(serviceTemplateItem.Id).add(taskTemplateItem);
			}
		}
		insert testTaskTemplatelist;

		testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

		testChangeOrderList = new List<Change_Order__c>();
		for (Proposal__c proposalItem : testProposalList){
			for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
				changeOrderItem.Status__c = 'Not equals ' + ChangeOrderServices.STATUS_CANCELED;
				changeOrderItem.Proposal__c = proposalItem.Id;
				testChangeOrderList.add(changeOrderItem);
			}
			for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
				changeOrderItem.Status__c = 'Not equals ' + ChangeOrderServices.STATUS_APPROVED;
				changeOrderItem.Proposal__c = proposalItem.Id;
				testChangeOrderList.add(changeOrderItem);
			}
		}
		insert testChangeOrderList;

		testServiceItemList = new List<Service_Item__c>();
		for(Change_Order__c changeOrderItem : testChangeOrderList){
			for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
				for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, changeOrderItem.Proposal__c, false)){
					serviceItemItem.Is_Alternative__c = false;
					serviceItemItem.Is_Amendmend_Deleted__c = false;
					serviceItemItem.Change_Order__c = changeOrderItem.Id;
					serviceItemItem.Service_template__c = serviceTemplateItem.Id;
					testServiceItemList.add(serviceItemItem);
				}
			}
			for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
				for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, changeOrderItem.Proposal__c, false)){
					serviceItemItem.Is_Alternative__c = false;
					serviceItemItem.Is_Amendmend_Deleted__c = false;
					serviceItemItem.Change_Order__c = changeOrderItem.Id;
					serviceItemItem.Quantity_Old__c = 1.2;
					serviceItemItem.Service_template__c = serviceTemplateItem.Id;
					testServiceItemList.add(serviceItemItem);
				}
			}
			for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
				for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(1, changeOrderItem.Proposal__c, false)){
					serviceItemItem.Is_Alternative__c = false;
					serviceItemItem.Is_Amendmend_Deleted__c = true;
					serviceItemItem.Change_Order__c = changeOrderItem.Id;
					serviceItemItem.Service_template__c = serviceTemplateItem.Id;
					testServiceItemList.add(serviceItemItem);
				}
			}
		}
		insert testServiceItemList;

		testTaskItemList = new List<Task_Item__c>();
		for (Service_Item__c serviceItemItem : testServiceItemList){
			for (Task_Template__c taskTemplateItem : serviceTemplateWithTaskTemplate.get(serviceItemItem.Service_Template__c)){
				for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
					taskItemItem.Task_Template__c = taskTemplateItem.Id;
					taskItemItem.Billing_Trigger__c = false;
					taskItemItem.Billing_Percentage__c = TEST_BILLING_PERCENTAGE_VALUE;
					testTaskItemList.add(taskItemItem);
				}
			}
			for (Task_Template__c taskTemplateItem : serviceTemplateWithTaskTemplate.get(serviceItemItem.Service_Template__c)){
				for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
					taskItemItem.Task_Template__c = taskTemplateItem.Id;
					taskItemItem.Billing_Trigger__c = true;
					taskItemItem.Is_Locked__c = false;
					taskItemItem.Billing_Percentage__c = TEST_BILLING_PERCENTAGE_VALUE;
					testTaskItemList.add(taskItemItem);
				}
			}
		}
		insert testTaskItemList;
	}

	private static void createController(String proposalItemId, String changeOrderId){
		testPage = Page.Proposal;
		Test.setCurrentPage(testPage);
		ApexPages.currentPage().getParameters().put('p', proposalItemId);
		ApexPages.currentPage().getParameters().put('co', changeOrderId);
		testController = new RedirectBillingTriggersController();
	}

	private static testmethod void testInitController(){
		setupData();
		prerareDataForTest();

		Test.startTest();

			createController(testChangeOrderList[0].Proposal__c, testChangeOrderList[0].Id);

		Test.stopTest();
	}

	private static testmethod void testInitControllerWithEmptyParameter(){
		setupData();
		prerareDataForTest();

		Test.startTest();

			createController('', '');

		Test.stopTest();
	}

	private static testmethod void testGetPicklistForServices(){
		setupData();
		prerareDataForTest();
		createController(testChangeOrderList[0].Proposal__c, testChangeOrderList[0].Id);

		List<SelectOption> resultPicklistForServices;

		Test.startTest();

			resultPicklistForServices = testController.getPicklistForServices();

		Test.stopTest();

		System.assert(!resultPicklistForServices.isEmpty());
	}

	private static testmethod void testPicklistForTasksFirst(){
		setupData();
		prerareDataForTest();
		createController(testServiceItemList[0].Proposal__c, testServiceItemList[0].Change_Order__c);

		for (Service_Item__c serviceItemItem : testServiceItemList){
			if (serviceItemItem.Proposal__c == testServiceItemList[0].Proposal__c && serviceItemItem.Change_Order__c != testServiceItemList[0].Change_Order__c){
				testController.serviceIdChosen = String.valueOf(serviceItemItem.Id);
				break;
			}
		}

		List<SelectOption> resultPicklistForTasks;

		Test.startTest();

			resultPicklistForTasks = testController.getPicklistForTasks();

		Test.stopTest();
	}

	private static testmethod void testPicklistForTasksSecond(){
		setupData();
		prerareDataForTest();

		Service_Item__c serviceItemForTest;

		for (Service_Item__c serviceItemItem : testServiceItemList){
			if (!serviceitemItem.Is_Amendmend_Deleted__c && serviceitemItem.Service_Template__c != null && (serviceitemItem.Quantity_Old__c == null || serviceitemItem.Quantity_Old__c == 0) ){
				serviceItemForTest = serviceitemItem;
				break;
			}
		}

		createController(serviceItemForTest.Proposal__c, serviceItemForTest.Change_Order__c);

		testController.serviceIdChosen = String.valueOf(serviceItemForTest.Id);

		List<SelectOption> resultPicklistForTasks;

		Test.startTest();

			resultPicklistForTasks = testController.getPicklistForTasks();

		Test.stopTest();
	}

	private static testmethod void testForTestCoverage(){
		setupData();
		prerareDataForTest();
		createController(testChangeOrderList[0].Proposal__c, testChangeOrderList[0].Id);

		Test.startTest();

			testController.taskIdToBillingTrigger.values()[0].serviceIdChosen = null;
			Boolean boolResult = testController.allValuesSet;

			testController.taskIdActive = testController.taskIdToBillingTrigger.values()[0].taskId;

			testController.pickService();

			testController.setService();
			testController.setTask();

			testController.taskIdToBillingTrigger.values()[0].setActiveService(null, null);
			testController.taskIdToBillingTrigger.values()[0].setActiveTask(null, null);

		Test.stopTest();
	}

	private static testmethod void testApplySelection(){
		setupData();
		prerareDataForTest();
		createController(testChangeOrderList[0].Proposal__c, testChangeOrderList[0].Id);

		Test.startTest();

			testController.applySelection();

		Test.stopTest();
	}
}