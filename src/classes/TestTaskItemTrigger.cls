@isTest
private class TestTaskItemTrigger {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
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
    private static final Decimal TASK_ITEM_PERCENTAGE = 0.5;
    private static final Decimal ITEM_ITEM_QUANTITY = 10;
    private static final Decimal PROJECT_PROFILE_TOTAL_SERVICE_AMOUNT = 50;
    private static final Decimal DISCOUNT_PERCENTAGE = 25;
    private static final Decimal UNIT_PRICE = 25;
    private static final String TEST_DESCRIPTION = 'Test description';
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
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static List<Project_Team__c> testProjectTeamList;
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
        testPhaseList = TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void prepareData(){
        testProjectProfileList = new List<Project_Profile__c>();
        for (Integer i = 0; i < PROJECT_PROFILE_BILLING_METHOD_LIST.size(); i++){
            for (Project_Profile__c projectProfileItem : TestingUtils.createProjectProfileList (NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id,
                                                                                                testContactWithAccountList[0].Id, testAccountList[1].Id,
                                                                                                testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                                testContactWithAccountList[2].Id, projectManagerUser.Id, false)){
                projectProfileItem.Billing_Method__c = PROJECT_PROFILE_BILLING_METHOD_LIST[i];
                projectProfileItem.Frequency__c = PROJECT_PROFILE_BILLING_METHOD_LIST[i] == ProjectProfileServices.BILLINGMETHODPERCENTAGE ? null : DateUtils.WEEKLY;
                projectProfileItem.Billing_day__c = DateTime.now().format('EEEE');
                projectProfileItem.Total_Service_Amount__c = PROJECT_PROFILE_TOTAL_SERVICE_AMOUNT;
                projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
                testProjectProfileList.add (projectProfileItem);
            }
        }
        insert testProjectProfileList;
        testProposalList = new List<Proposal__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Decimal proposalVersion = 0;
            for (Proposal__c proposalItem : TestingUtils.createProposalList(NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id,
                                                                            testContactWithAccountList[0].Id, testAccountList[1].Id,
                                                                            testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                            null, null, null, null, partnerUser.Id,
                                                                            currentUserId, projectManagerUser.Id, false)){
                proposalVersion += ProposalServices.VERSION_MAJOR_STEP + ProposalServices.VERSION_MINOR_STEP;
                proposalItem.Version__c = proposalVersion;
                proposalItem.Status__c = 'test';//ProposalServices.PROPOSAL_STATUS_NEW;
                proposalItem.Project_Profile__c = projectProfileItem.Id;
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;
        testProposalList = new List<Proposal__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Proposal__c proposalItem : TestingUtils.createProposalList(1, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                            testAccountList[1].Id, testContactWithAccountList[1].Id,
                                                                            testBuildingList[0].Id, null, null, null, null, partnerUser.Id,
                                                                            currentUserId, projectManagerUser.Id, false)){
                proposalItem.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
                proposalItem.Project_Profile__c = projectProfileItem.Id;
                testProposalList.add(proposalItem);
            }
        }
        insert testProposalList;
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, testProposalList, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Quantity__c = ITEM_ITEM_QUANTITY;
            serviceItem.Unit_Price__c = UNIT_PRICE;
            serviceItem.Description__c = TEST_DESCRIPTION;
            serviceItem.Discount_Percentage__c = DISCOUNT_PERCENTAGE;
            serviceItem.Actual_Start_Date__c = DateTime.now();
            serviceItem.Met_Data_Scanning_Fee__c = 1.1;
            serviceItem.Phase__c = testPhaseList[0].Id;
        }
        insert testServiceItemList;
        testTaskItemList = new List<Task_Item__c>();
    }

    /*private static testmethod void testCreateBillingLineItemsForTaskItemTrigger(){
        setupData();
        prepareData();

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
                taskItem.Status__c = 'some test status';
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;
        Map<Id, Task_Item__c> tm = new Map<Id, Task_Item__c>([SELECT Id, Actual_End_Date__c FROM Task_Item__c]);
        for (Task_Item__c taskItem : testTaskItemList){
            taskItem.Is_Locked__c = false;
            taskItem.Billing_Trigger__c = true;
            taskItem.Status__c = 'RFI Complete';
            taskItem.Actual_End_Date__c = DateTime.now().addDays(1);
        }

        TaskItemServices.preventor = false;

        Test.startTest();
            update testTaskItemList;
        Test.stopTest();

        testBillingLineItemList = [ SELECT Id, Task_Item__c, Project_Profile__c,  Service_Item__c, Purchase_Order__c, Phase__c, Accounting_Contact__c,
                                            Task_Item__r.Actual_End_Date__c, Task_Item__r.Project_Profile__c, Task_Item__r.Service_Item__c, Project_Profile__r.Accounting_Contact_Company__c,
                                            Project_Profile__r.Primary_Company_Name__c, Accounting_Contact_Company__c, Milestone_Date__c, Project_Profile__r.Accounting_Contact__c,
                                            Billing_Client__c, Billing_Contact__c, Billing_Method__c, Client_Contact__c, Project_Address__c, Service_Name__c,
                                            Description__c, External_ID__c, Sales_Tax_Amount__c,
                                            Quantity__c, Unit_Price__c, Amount__c
                                    FROM Billing_Line_Item__c
                                    WHERE Task_Item__c IN : testTaskItemList];
        System.assert (!testBillingLineItemList.isEmpty());
//      System.assertEquals ((PROJECT_PROFILE_BILLING_METHOD_LIST.size() - 1) * NUMBER_TO_CREATE_PROJECT_PROFILE * NUMBER_TO_CREATE_SERVICE_ITEM * NUMBER_TO_CREATE_TASK_ITEM, testBillingLineItemList.size());
        for (Billing_Line_Item__c billingLineItem : testBillingLineItemList){
            System.assertEquals (null, billingLineItem.External_ID__c);
//  System.assertEquals (null, billingLineItem.Sales_Tax_Amount__c);//actual 0.00
//          System.assertEquals (Date.newInstance(billingLineItem.Task_Item__r.Actual_End_Date__c.year(), billingLineItem.Task_Item__r.Actual_End_Date__c.month(), billingLineItem.Task_Item__r.Actual_End_Date__c.day()), billingLineItem.Milestone_Date__c);
            System.assertEquals (billingLineItem.Task_Item__r.Project_Profile__c, billingLineItem.Project_Profile__c);
            System.assertEquals (billingLineItem.Task_Item__r.Service_Item__c, billingLineItem.Service_Item__c);
            System.assertEquals (testPhaseList[0].Id, billingLineItem.Phase__c);
            System.assertEquals (billingLineItem.Project_Profile__r.Accounting_Contact_Company__c, billingLineItem.Accounting_Contact_Company__c);
            System.assertEquals (billingLineItem.Project_Profile__r.Accounting_Contact__c, billingLineItem.Accounting_Contact__c);
        }
    }*/

    private static testmethod void testUpdateServiceItemPredecessorSuccessorChange(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, true);
        Set<Id> serviceItemResultSetId = new Set<Id>();

        Map<Id, List<Task_Item__c>> mapServiceIdMilestones = new Map<Id, List<Task_Item__c>>();
        testMilestonesList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            Integer i = 1;
            mapServiceIdMilestones.put(serviceItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_MILESTONES * 2, false)){
                taskItem.Name = serviceItem.Name + i;
                testMilestonesList.add(taskItem);
                mapServiceIdMilestones.get(serviceItem.Id).add(taskItem);
            }
        }
        insert testMilestonesList;
        testTaskItemList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> mapServiceIdTaskItemList = new Map<Id, List<Task_Item__c>>();
        for (Service_Item__c serviceItem : testServiceItemList){
            mapServiceIdTaskItemList.put(serviceItem.Id, new List<Task_Item__c>());
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, null, false)){
                taskItem.Predecessor_Milestone__c = null;
                taskItem.Successor_Milestone__c = null;
                testTaskItemList.add(taskItem);
                mapServiceIdTaskItemList.get(serviceItem.Id).add(taskItem);
            }
        }
        insert testTaskItemList;

        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            Id serviceId = testServiceItemList[i].id;
            serviceItemResultSetId.add(serviceId);
            Task_Item__c taskItem = mapServiceIdTaskItemList.get(serviceId)[0];
            taskItem.Predecessor_Milestone__c = (mapServiceIdMilestones.get(serviceId)[0]).Id;
            taskItem.Successor_Milestone__c = (mapServiceIdMilestones.get(serviceId)[1]).Id;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            Id serviceId = testServiceItemList[i].id;
            serviceItemResultSetId.add(serviceId);
            Task_Item__c taskItem = mapServiceIdTaskItemList.get(serviceId)[0];
            taskItem.Predecessor_Milestone__c = (mapServiceIdMilestones.get(serviceId)[0]).Id;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2; i < NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            Id serviceId = testServiceItemList[i].id;
            serviceItemResultSetId.add(serviceId);
            Task_Item__c taskItem = mapServiceIdTaskItemList.get(serviceId)[0];
            taskItem.Successor_Milestone__c = (mapServiceIdMilestones.get(serviceId)[1]).Id;
        }

        Test.startTest();
            update testTaskItemList;
        Test.stopTest();

        testTaskItemList = [SELECT Id, Predecessor_Milestone__c, Predecessor_Milestone__r.Name, Successor_Milestone__c,
                                    Successor_Milestone__r.Name, Service_Item__r.Predecessor_Milestone__c,
                                    Service_Item__r.Successor_Milestone__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList
                                AND (Predecessor_Milestone__c != null OR Successor_Milestone__c != null)];
        /*System.assert(!testTaskItemList.isEmpty());
        for (Task_Item__c taskItem : testTaskItemList){
            if (taskItem.Predecessor_Milestone__c != null){
                System.assert(!String.isEmpty(taskItem.Service_Item__r.Predecessor_Milestone__c));
                System.assertEquals(taskItem.Predecessor_Milestone__r.Name, taskItem.Service_Item__r.Predecessor_Milestone__c);
            }
            if (taskItem.Successor_Milestone__c != null){
                System.assert(!String.isEmpty(taskItem.Service_Item__r.Successor_Milestone__c));
                System.assertEquals(taskItem.Successor_Milestone__r.Name, taskItem.Service_Item__r.Successor_Milestone__c);
            }
        }*/
    }
}