@isTest
private class TestProjectProfileServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 5;
    private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 5;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 5;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 4;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 6;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;
    private static final Integer NUMBER_TO_CREATE_NOTE = 2;
    private static final Integer NUMBER_TO_CREATE_FLOOR = 2;
    private static final Integer NUMBER_TO_CREATE_PHASE = 2;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 2;
    private static final Integer NUMBER_TO_CREATE_CHANGE_ORDER = 3;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 3;
    private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 1;
    private static final String TEST_ROLE_ASSIGNMENT = 'test role';
    private static final String TEST_CONDITION_TASK_STATUS_DISAPPROVED = 'Disapproved';
    private static final Integer NUMBER_DAY_30 = 30;
    private static final Integer NUMBER_DAY_60 = 60;
    private static final Integer NUMBER_DAY_90 = 90;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Note> testNoteList;
    private static List<Floor__c> testFloorList;
    private static List<Phase__c> testPhaseList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<LStore__Stored_Document__c> testLStoreStoredDocumentList;
    private static List<Pro_forma_Invoice__c> testProFormaInvoiceList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    public static User testProductionManagerUser;
    private static Id currentUserId;

    private static BusinessHours bizHours;

    //Service Template Record Type Names
    private static final String SERVICE_TEMPLATE_APS_RECORD_TYPE_NAME = 'Application & Permit Services';
    private static final String SERVICE_TEMPLATE_OS_RECORD_TYPE_NAME = 'Other Services';
    private static final String SERVICE_TEMPLATE_SUBSERVICE_RECORD_TYPE_NAME = 'Subservice';
    //Task Template Record Type Names
    private static final String TASK_TEMPLATE_TASK_TEMPLATE_RECORD_TYPE_NAME = 'Task Template';
    private static final String TASK_TEMPLATE_SUPER_TEMPLATE_RECORD_TYPE_NAME = 'Super-template';

    private static Id serviceTemplateAPSRecordTypeId;
    private static Id serviceTemplateOSRecordTypeId;
    private static Id serviceTemplateSubserviceRecordTypeId;
    private static Id taskTemplateTaskTemplateRecordTypeId;
    private static Id taskTemplateSuperTemplateRecordTypeId;
    private static Id taskItemMilestoneRecordTypeId;
    private static Id taskItemNotMilestoneRecordTypeId;

    private static Id projectRosterUserRecordTypeId;
    private static Id projectRosterContactRecordTypeId;

    private static List<String> projectRosterRoleValuesList;

    private static void prepareRecordTypePickListValuesForTest(){
        //prepare Project Roster Record Type
        Map<String, Id> projectRosterRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Project_Roster__c');
        for (String projectRosterRecordTypeNameValue : projectRosterRecordTypesMap.keySet()){
            if (projectRosterRecordTypeNameValue == ProjectRosterServices.TYPE_USER) {
                projectRosterUserRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
            }
            if (projectRosterRecordTypeNameValue == ProjectRosterServices.TYPE_CONTACT) {
                projectRosterContactRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
            }
        }
        projectRosterRoleValuesList = new List<String>();
        for (Schema.PicklistEntry ple : Project_Roster__c.Role__c.getDescribe().getPicklistValues()){
            projectRosterRoleValuesList.add(ple.getValue());
        }
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
        taskItemMilestoneRecordTypeId = taskItemRecordTypesMap.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
        for (String taskItemRecordTypeNameValue : taskItemRecordTypesMap.keySet()){
            if (taskItemRecordTypeNameValue != TaskManagementServices.MILESTONE_RECORDTYPE_NAME){
                taskItemNotMilestoneRecordTypeId = taskItemRecordTypesMap.get(taskItemRecordTypeNameValue);
                break;
            }
        }
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

    private static void createServiceTemplateForTest(Boolean createOSService, Boolean createAPSService, Boolean createSubservice){
        if (serviceTemplateOSRecordTypeId == null){
            prepareRecordTypePickListValuesForTest();
        }

        List<Service_Template__c> serviceTemplateListForInsert = new List<Service_Template__c>();

        testServiceTemplateList = new List<Service_Template__c>();
        if (createOSService){
            if (UserServices.getUserRoleNameToUserId().isEmpty()){
                UserServices.userRoleNameToUserId = new Map<String, Id>{TEST_ROLE_ASSIGNMENT => UserInfo.getUserId ()};
            }

            String roleStringValue;

            for (String stringItem : UserServices.userRoleNameToUserId.keySet()){
                roleStringValue = stringItem;
                break;
            }

            Integer i = 1;
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false)){
                serviceTemplateItem.RecordTypeId = serviceTemplateOSRecordTypeId;
                serviceTemplateItem.Service_Row_Number__c = ServiceItemServices.OS_SERVICE + String.valueOf(i++);
                serviceTemplateItem.Role_Assignment__c = roleStringValue;
                testServiceTemplateList.add(serviceTemplateItem);
            }
        }
        if (createAPSService){
            Integer i = 1;
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false)){
                serviceTemplateItem.RecordTypeId = serviceTemplateAPSRecordTypeId;
                serviceTemplateItem.Service_Row_Number__c = ServiceItemServices.APS_SERVICE + String.valueOf(i++);
                testServiceTemplateList.add(serviceTemplateItem);
            }
        }
        List<Service_Template__c> testServiceTemplateSubserviceList = new List<Service_Template__c>();
        if (createSubservice){
            for (Service_Template__c serviceItem : testServiceTemplateList){
                for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(1, false)){
                    serviceTemplateItem.RecordTypeId = serviceTemplateSubserviceRecordTypeId;
                    serviceTemplateItem.Service_Row_Number__c = serviceItem.Service_Row_Number__c + '_01';
                    testServiceTemplateSubserviceList.add(serviceTemplateItem);
                }
            }
            serviceTemplateListForInsert.addAll(testServiceTemplateSubserviceList);
        }
        serviceTemplateListForInsert.addAll(testServiceTemplateList);
        insert serviceTemplateListForInsert;

        Map<Id, Task_Template__c> serviceTemplateIdToFirstTaskTemplate = new Map<Id, Task_Template__c>();

        testTaskTemplateList = new List<Task_Template__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            Integer i = 1;
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                taskTemplateItem.Service__c = serviceTemplateItem.Id;
                taskTemplateItem.Sequence_Number__c = i;
                testTaskTemplateList.add(taskTemplateItem);
                if (i == 1){
                    serviceTemplateIdToFirstTaskTemplate.put(serviceTemplateItem.Id, taskTemplateItem);
                    taskTemplateItem.Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
                }
                i++;
            }
        }

        if (createSubservice){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateSubserviceList){
                Integer i = NUMBER_TO_CREATE_TASK_TEMPLATE;
                for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(NUMBER_TO_CREATE_TASK_TEMPLATE, false)){
                    taskTemplateItem.Service__c = serviceTemplateItem.Id;
                    taskTemplateItem.Sequence_Number__c = i;
                    testTaskTemplateList.add(taskTemplateItem);
                }
            }
        }

        insert testTaskTemplateList;

        if (createSubservice){
            List<Task_State_Change__c> taskStateChangeList = new List<Task_State_Change__c>();
            for (Integer i = 0; i < testServiceTemplateList.size(); i++){
                Task_State_Change__c taskStateChangeItem = TestingUtils.createTaskStateChangeList(1, false)[0];
                taskStateChangeItem.Service__c = testServiceTemplateList[i].Id;
                taskStateChangeItem.Task_Line__c = testServiceTemplateSubserviceList[i].Id;
                taskStateChangeItem.Related_Task__c = serviceTemplateIdToFirstTaskTemplate.get(testServiceTemplateList[i].Id).id;
                taskStateChangeItem.Condition__c = TEST_CONDITION_TASK_STATUS_DISAPPROVED;
                taskStateChangeList.add(taskStateChangeItem);
            }
            insert taskStateChangeList;
        }
    }

    private static void createProposalProjectPropfileForTest(Integer numberToCreate){
        TestingUtils.createProposalWithProjectProfileList(numberToCreate);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
    createServiceTemplateForTest(true, true, true);
    
    testChangeOrderList = new List<Change_Order__c>();
    for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                changeOrderItem.Project_Profile__c = proposalItem.Project_Profile__c;
                changeOrderItem.Status__c = ChangeOrderServices.STATUS_APPROVED;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;
    
    testServiceItemList = new List<Service_Item__c>();
        Proposal__c tempProposal = TestingUtils.createProposalListForTest( 1, true)[0];
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, tempProposal.Id, false)){
                    serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                    serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                    serviceItemItem.Change_Order__c = changeOrderItem.Id;
                    serviceItemItem.Applied_Amendment__c = false;
                    serviceItemItem.Is_Alternative__c = false;
                    serviceItemItem.Original__c = false;
                    serviceItemItem.Is_Amendmend_Added__c = true;
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.OwnerId = UserInfo.getUserId();
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;
    }

    private static void createProjectRosterForTest(Boolean createForProposal, Boolean createForProjectProfile, Boolean doInsert){
        if (projectRosterUserRecordTypeId == null){
            prepareRecordTypePickListValuesForTest();
        }
        testProjectRosterList = new List<Project_Roster__c>();
        if (createForProposal && !createForProjectProfile){
            for (Proposal__c proposalItem : testProposalList){
                for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                    projectRosterItem.Proposal__c = proposalItem.Id;
                    projectRosterItem.User__c = UserInfo.getUserId ();
                    projectRosterItem.User_Contact__c = ProjectRosterServices.TYPE_USER;
                    projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                    projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                    testProjectRosterList.add(projectRosterItem);
                }
            }
        }
        if (!createForProposal && createForProjectProfile){
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                    projectRosterItem.Project_Profile__c = projectProfileItem.Id;
                    projectRosterItem.User__c = UserInfo.getUserId ();
                    projectRosterItem.User_Contact__c = ProjectRosterServices.TYPE_USER;
                    projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                    projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                    testProjectRosterList.add(projectRosterItem);
                }
            }
        }
        if (createForProposal && createForProjectProfile){
            for (Proposal__c proposalItem : testProposalList){
                for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                    projectRosterItem.Proposal__c = proposalItem.Id;
                    projectRosterItem.Project_Profile__c = proposalItem.Project_Profile__c;
                    projectRosterItem.User__c = UserInfo.getUserId ();
                    projectRosterItem.User_Contact__c = ProjectRosterServices.TYPE_USER;
                    projectRosterItem.Role__c = projectRosterRoleValuesList[0];
                    projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                    testProjectRosterList.add(projectRosterItem);
                }
            }
        }
        if (doInsert){
            insert testProjectRosterList;
        }
    }

    private static testmethod void testForCoverage(){
        setupData ();
        createProposalProjectPropfileForTest( 2 );
        createProjectRosterForTest(true, true, true);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
            insert projectTeamItem;

            testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                                FROM Proposal__c
                                WHERE Id IN : testProposalList];

            for (Proposal__c proposalItem : testProposalList){
                proposalItem.Project_Team__c = projectTeamItem.Id;
                proposalItem.Resource__c = currentUserId;
            }
        update testProposalList;
        testProjectProfileList = TestingUtils.createProjectProfileForTest( NUMBER_TO_CREATE_PROJECT_PROFILE, false) ;

        for(Project_Profile__c pp : testProjectProfileList){
            pp.Billing_Method__c = ProjectProfileServices.BILLINGMETHODINSTALLMENT;
            pp.Frequency__c = 'Monthly';
            pp.Billing_day__c = '20';
            pp.Reimbursable1__c = 10.0;
            pp.Reimbursable2__c = 10.0;
            pp.Reimbursable3__c = 10.0;
            pp.Reimbursable4__c = 10.0;
            pp.Pre_billed__c = false;
        }
        insert testProjectProfileList;

        Set<Id> idsOfProjects = new Set<Id>();
        idsOfProjects.add( testProjectProfileList[0].Id );
        Set<Id> idsOfProposals = new Set<Id>();
        idsOfProposals.add( testProposalList[0].Id );
        Set<Id> idsOfCOs = new Set<Id>();
        idsOfCOs.add( testChangeOrderList[0].Id) ;
        Set<Id> idsOfSIs = new Set<Id>();
        idsOfSIs.add( testServiceItemList[0].Id) ;
        
		testChangeOrderList[0].Project_Profile__c = testProjectProfileList[0].Id;
		UPSERT testChangeOrderList[0];
        
        Project_Profile__c resultProjectProfile;
        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
            }

        Billing_Date__c testcreateBillingDate = TestingUtils.createBillingDateList(1, Date.today(), testProjectProfileList[0].Id, false)[0];
        testcreateBillingDate.Billed__c = false;
        insert testcreateBillingDate;

        testProjectProfileList =   [SELECT Id, Billing_Method__c, Reimbursable1__c, Reimbursable2__c,Reimbursable3__c,Reimbursable4__c, 
                                    Pre_billed__c, Accounting_Contact_Company__c, Accounting_Contact__c, Billing_Company_Name__c, Billing_Company_Contact__c,
                                    Primary_Company_Contact__c, Building__c, No_Messenger_Fedex__c
                                    FROM Project_Profile__c
                                    WHERE Id IN : testProjectProfileList];

        testServiceItemList = new List<Service_Item__c>();

            for (Change_Order__c changeOrderItem : testChangeOrderList){
                for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                    for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                        serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                        serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                        serviceItemItem.Change_Order__c = changeOrderItem.Id;
                        serviceItemItem.Applied_Amendment__c = false;
                        serviceItemItem.Is_Alternative__c = false;
                        serviceItemItem.Original__c = false;
                        serviceItemItem.Is_Amendmend_Added__c = true;
                        serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                        serviceItemItem.Manager_Lookup__c = currentUserId;
                        serviceItemItem.Region__c = RegionServices.REGION_NAME_NY;
                        serviceItemItem.Type__c = ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY;
                        serviceItemItem.Applied_Amendment__c = true;
                        serviceItemItem.Is_Amendmend_Deleted__c  = false;
                        testServiceItemList.add(serviceItemItem);
                    }
            }
        }

        insert testServiceItemList;
        ProjectProfileServices.isAllowedPreBillGenerated = true;

        testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,Service_Name_Full__c,X3rd_Party_Disapproved_Date__c,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,Municipal_Agency_ID__c,X3rd_Party_Issue_Date__c,Type_in_Municipal_Agency_Name__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId, X3rd_Party_Description__c, Proposal__r.Region__c
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];

        Test.startTest();

        resultProjectProfile = ProjectProfileServices.getProjectWithAssignmentsById( testProjectProfileList[0].Id );
        Map<Id, Project_Profile__c> tesProjectMap = ProjectProfileServices.getProgectProfileMapForprocessProforma( idsOfProjects );
        Map<Id, Project_Profile__c> tesProjectMapNull = ProjectProfileServices.getProgectProfileMapForprocessProforma( idsOfProjects );
        ProjectProfileServices.createAndManipulateWithTaskItemsInFuture( idsOfProposals, idsOfCOs, idsOfSIs, true );
        ProjectProfileServices.createAndManipulateWithTaskItemsInFuture( idsOfProposals, idsOfCOs, idsOfSIs, false );
	    ProjectProfileServices.prebillProjects( testProjectProfileList, false );
        testProjectProfileList[0].Billing_Method__c = ProjectProfileServices.BILLINGMETHODMILESTONE;
        ProjectProfileServices.prebillProjects( testProjectProfileList, false );
        testProjectProfileList[0].Billing_Method__c = ProjectProfileServices.BILLINGMETHODINSTALLMENT;
        ProjectProfileServices.prebillProjects( testProjectProfileList, false );
        testProjectProfileList[0].Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
        ProjectProfileServices.prebillProjects( testProjectProfileList, false );
        ProjectProfileServices.prebillProjects( testProjectProfileList, true );
        
        ProjectProfileServices.processTaskItemsForProjects( new Map<Id, Service_Item__c>(testServiceItemList), new Map<Id, Proposal__c>(testProposalList), true );
        ProjectProfileServices.processTaskItemsForProjects( new Map<Id, Service_Item__c>(testServiceItemList), new Map<Id, Proposal__c>(testProposalList), false );
        Map<Id, Map<String, Project_Roster__c>> testMap = ProjectProfileServices.getProjectIdToRoleToRosterForProjects( testProjectProfileList, new Map<Id, Project_Profile__c>(testProjectProfileList) );
                                      
			Project_Roster__c createAfterAssignProjectRosterContact = ProjectProfileServices.createAfterAssignProjectRosterContact(Id.valueOf('000000000000000000'), Id.valueOf('000000000000000000'), Id.valueOf('000000000000000000'), Id.valueOf('000000000000000000'), ProjectRosterServices.ACCOUNT_MANAGER); //MRS 6888
           
        Test.stopTest();

        
    }
    
    private static testmethod void testUpdateProjectRoster(){
        setupData ();
        createProposalProjectPropfileForTest( 2 );
        createProjectRosterForTest(true, true, false);
        for(Project_Roster__c pr: testProjectRosterList){
            pr.Role__c = 'Production Manager';
        }
        insert testProjectRosterList;

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
            insert projectTeamItem;

            testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                                FROM Proposal__c
                                WHERE Id IN : testProposalList];

            for (Proposal__c proposalItem : testProposalList){
                proposalItem.Project_Team__c = projectTeamItem.Id;
                proposalItem.Resource__c = currentUserId;
            }
        update testProposalList;

        Contact testContact = testContactWithAccountList[0];
        testContact.AccountId = testAccountList[0].Id;
        upsert testContact;

        User newpartnerUser = TestingUtils.createUsers( 1, 'nuName@test.com', 'nuLName', 'nuName@test.com', 'nualias', null, null, null, null, null, null, true)[0];

        testProjectProfileList = TestingUtils.createProjectProfileForTest( NUMBER_TO_CREATE_PROJECT_PROFILE, false) ;

        for(Project_Profile__c p : testProjectProfileList){
            p.Billing_Method__c = ProjectProfileServices.BILLINGMETHODMILESTONE;
            p.Frequency__c = 'Monthly';
            p.Billing_day__c = '20';
            p.Reimbursable1__c = 10.0;
            p.Reimbursable2__c = 10.0;
            p.Reimbursable3__c = 10.0;
            p.Reimbursable4__c = 10.0;
            p.Pre_billed__c = false;
            p.OwnerId = currentUserId;
            p.Partner__c = currentUserId;
            p.Account_Executive__c = currentUserId;
            p.Proposal_Specialist__c = currentUserId;
            p.Salesperson__c = currentUserId;
            p.Primary_Company_Name__c = testAccountList[0].Id;
            p.Primary_Company_Contact__c = testContact.Id;
            p.Interval__c = true;
            p.Billing_Company_Name__c = testAccountList[0].Id;
            p.Billing_Company_Contact__c =  testContact.Id;
            p.FREP__c = currentUserId;
            p.Production_Manager__c = newpartnerUser.Id;
                       
        }
        insert testProjectProfileList;
        
        Project_Profile__c resultProjectProfile;
        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
            }

        Billing_Date__c testcreateBillingDate = TestingUtils.createBillingDateList(1, Date.today(), testProjectProfileList[0].Id, false)[0];
        testcreateBillingDate.Billed__c = false;
        insert testcreateBillingDate;

        testProjectProfileList =   [SELECT Id, Billing_Method__c, Reimbursable1__c, Reimbursable2__c,Reimbursable3__c,Reimbursable4__c, 
                                    Pre_billed__c, Accounting_Contact_Company__c, Accounting_Contact__c, Billing_Company_Name__c, Billing_Company_Contact__c,
                                    Primary_Company_Contact__c, Building__c, No_Messenger_Fedex__c, Interval__c
                                    FROM Project_Profile__c
                                    WHERE Id IN : testProjectProfileList];

        testServiceItemList = new List<Service_Item__c>();

            for (Change_Order__c changeOrderItem : testChangeOrderList){
                for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                    for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                        serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                        serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                        serviceItemItem.Change_Order__c = changeOrderItem.Id;
                        serviceItemItem.Applied_Amendment__c = true;
                        serviceItemItem.Is_Alternative__c = false;
                        serviceItemItem.Original__c = false;
                        serviceItemItem.Is_Amendmend_Added__c = true;
                        serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                        serviceItemItem.Manager_Lookup__c = currentUserId;
                        serviceItemItem.Region__c = RegionServices.REGION_NAME_NY;
                        serviceItemItem.Type__c = ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY;
                        serviceItemItem.Is_Amendmend_Deleted__c  = false;
                        //serviceItemItem.Role_Assignment__c = UserServices.ROLE_FDNY_DEPARTMENT_MANAGER;
                        testServiceItemList.add(serviceItemItem);
                    }
                }
            }
        insert testServiceItemList;

        testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,Service_Name_Full__c,X3rd_Party_Disapproved_Date__c,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,Municipal_Agency_ID__c,X3rd_Party_Issue_Date__c,Type_in_Municipal_Agency_Name__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId, X3rd_Party_Description__c, Is_Amendmend_Deleted__c
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];

        //Profile profiles = [ SELECT Id, Name FROM Profile WHERE Name = : 'Standard User' LIMIT 1];
        //Id profileID = TestingUtils.getProfileId( 'Standard User' );
        //System.debug('!!!!!! profileID = ' + profileID);
        
        Contact testcreateContact =  TestingUtils.createContactList(1, false)[0];
        testcreateContact.AccountId = testAccountList[1].Id;
        insert testcreateContact;
        Map<Id, Project_Profile__c> testprojectProfileMapOld = new Map<Id, Project_Profile__c>(testProjectProfileList);

        for(Project_Profile__c pp : testProjectProfileList){
            //pp.OwnerId = newpartnerUser.Id;
            pp.Partner__c = newpartnerUser.Id;
            pp.Account_Executive__c = newpartnerUser.Id;
            pp.Proposal_Specialist__c = newpartnerUser.Id;
            pp.Salesperson__c = newpartnerUser.Id;
            pp.FREP__c = newpartnerUser.Id;
            //pp.Production_Manager__c = newpartnerUser.Id;

        }
        update testProjectProfileList;

        

        Test.startTest();
            ProjectProfileServices.updateProjectRoster(testProjectProfileList, testprojectProfileMapOld );
            Set<Id> testfilterProjectsWithChangedFrep = ProjectProfileServices.filterProjectsWithChangedFrep(testProjectProfileList, testprojectProfileMapOld );
            Set<Id> testfilterProjectsWithChangedProductionManager = ProjectProfileServices.filterProjectsWithChangedProductionManager(testProjectProfileList, testprojectProfileMapOld );
            for(Project_Profile__c pp : testProjectProfileList){
                pp.Primary_Company_Name__c = testAccountList[1].Id;
                pp.Billing_Company_Name__c = testAccountList[1].Id;
                pp.Primary_Company_Contact__c = testcreateContact.Id;
                pp.Billing_Company_Contact__c = testcreateContact.Id;
            }
            update testProjectProfileList;
            ProjectProfileServices.prebillProjects( testProjectProfileList, false );
            ProjectProfileServices.prebillProjects( testProjectProfileList, true );

            //Project_Profile__c testinitProjectProfile = ProjectProfileServices.initProjectProfile(testProposalList[0]);

            ProjectProfileServices.createProjectRosterForChangedContact(testProjectProfileList, testprojectProfileMapOld);
            Map<Id, Map<String, Project_Roster__c>> testMap = ProjectProfileServices.getProjectIdToRoleToRosterForProjects( testProjectProfileList, testprojectProfileMapOld );             
        Test.stopTest();
     
    }
    private static testmethod void testForCoverage2(){
        setupData ();
        createProposalProjectPropfileForTest( 2 );
        createProjectRosterForTest(true, true, true);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
            insert projectTeamItem;

            testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                                FROM Proposal__c
                                WHERE Id IN : testProposalList];

            for (Proposal__c proposalItem : testProposalList){
                proposalItem.Project_Team__c = projectTeamItem.Id;
                proposalItem.Resource__c = currentUserId;
            }
        update testProposalList;

        Contact testContact = testContactWithAccountList[0];
        testContact.AccountId = testAccountList[0].Id;
        upsert testContact;

        testProjectProfileList = TestingUtils.createProjectProfileForTest( NUMBER_TO_CREATE_PROJECT_PROFILE, false) ;

        for(Project_Profile__c p : testProjectProfileList){
            p.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
            p.Pre_billed__c = false;
            p.OwnerId = currentUserId;
            p.Partner__c = currentUserId;
            p.Account_Executive__c = currentUserId;
            p.Proposal_Specialist__c = currentUserId;
            p.Salesperson__c = currentUserId;
            p.Primary_Company_Name__c = testAccountList[0].Id;
            p.Primary_Company_Contact__c = testContact.Id;
            p.Interval__c = false;

                       
        }
        insert testProjectProfileList;
        
        Project_Profile__c resultProjectProfile;
        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
            }

        Billing_Date__c testcreateBillingDate = TestingUtils.createBillingDateList(1, Date.today(), testProjectProfileList[0].Id, false)[0];
        testcreateBillingDate.Billed__c = false;
        insert testcreateBillingDate;

        testProjectProfileList =   [SELECT Id, Billing_Method__c, Reimbursable1__c, Reimbursable2__c,Reimbursable3__c,Reimbursable4__c, 
                                    Pre_billed__c, Accounting_Contact_Company__c, Accounting_Contact__c, Billing_Company_Name__c, Billing_Company_Contact__c,
                                    Primary_Company_Contact__c, Building__c, No_Messenger_Fedex__c, Interval__c
                                    FROM Project_Profile__c
                                    WHERE Id IN : testProjectProfileList];

        testServiceItemList = new List<Service_Item__c>();

            for (Change_Order__c changeOrderItem : testChangeOrderList){
                for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                    for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                        serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                        serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                        serviceItemItem.Change_Order__c = changeOrderItem.Id;
                        serviceItemItem.Applied_Amendment__c = true;
                        serviceItemItem.Is_Alternative__c = false;
                        serviceItemItem.Original__c = false;
                        serviceItemItem.Is_Amendmend_Added__c = true;
                        serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                        serviceItemItem.Manager_Lookup__c = currentUserId;
                        serviceItemItem.Region__c = RegionServices.REGION_NAME_NY;
                        serviceItemItem.Type__c = ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY;
                        //serviceItemItem.Is_Amendmend_Deleted__c  = false;
                        testServiceItemList.add(serviceItemItem);
                    }
                }
            }
        insert testServiceItemList;

        testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,Service_Name_Full__c,X3rd_Party_Disapproved_Date__c,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,Municipal_Agency_ID__c,X3rd_Party_Issue_Date__c,Type_in_Municipal_Agency_Name__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId, X3rd_Party_Description__c
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];   

        Test.startTest();

            ProjectProfileServices.prebillProjects( testProjectProfileList, false );
            ProjectProfileServices.prebillProjects( testProjectProfileList, true );             
        Test.stopTest();
     
    }


    private static testmethod void testForCoverage1(){
        setupData ();
    createProposalProjectPropfileForTest( 2 );
    createProjectRosterForTest(true, true, true);
    testProjectProfileList = TestingUtils.createProjectProfileForTest( NUMBER_TO_CREATE_PROJECT_PROFILE, true) ;
    Set<Id> idsOfProjects = new Set<Id>();
    idsOfProjects.add( testProjectProfileList[0].Id );
    Set<Id> idsOfProposals = new Set<Id>();
    idsOfProposals.add( testProposalList[0].Id );
    Set<Id> idsOfCOs = new Set<Id>();
    idsOfCOs.add( testChangeOrderList[0].Id) ;
    Set<Id> idsOfSIs = new Set<Id>();
    idsOfSIs.add( testServiceItemList[0].Id) ;
    
        Project_Profile__c resultProjectProfile;

        Test.startTest();

            
        Project_Roster__c test1 = ProjectProfileServices.createProjectRosterForContact( testContactWithAccountList[0].Id, testProjectProfileList[0].Id, testProposalList[0].Id, 'Project Manager 1', ProjectRosterServices.getRecordTypeByObjectNameId ('Project_Roster__c', 'Contact'), testProjectRosterList[0] );
        List<Project_Profile__c> test2 = ProjectProfileServices.updateProjectTeamAssignment ( idsOfProjects );
        ProjectProfileServices.updateProjectStage( idsOfProjects, testServiceItemList, testChangeOrderList );
        ProjectProfileServices.createProformaInvoicesForBillingLineItems( new List<Billing_Line_Item__c>() );
        ProjectProfileServices.createBLIForMilestoneProjects( new Map<Id, Project_Profile__c>(testProjectProfileList) );
        Boolean test3 = ProjectProfileServices.removeBillingDatesForProjects( new Map<Id, Project_Profile__c>(testProjectProfileList) );
        List<Billing_Line_Item__c> test4 = ProjectProfileServices.createBLIForInstallmentProjects( new Map<Id, Project_Profile__c>(testProjectProfileList) );
        Map<Id, Map<String, Decimal>> test5 = ProjectProfileServices.getProjectIdToAmountTypeToAmount( idsOfProjects ) ;
        Map <Id, Project_Roster__c> test6 = ProjectProfileServices.getProjectRosterStatusOnlyValid ( testProjectProfileList[0] );
        ProjectProfileServices.checkIfCurrentUserCanEditFields ( testProjectProfileList, new Map<Id, Project_Profile__c>(testProjectProfileList) );
        Boolean test7 = ProjectProfileServices.isUserInProjectRosterList ( testProjectProfileList[0], UserInfo.getUserId(), 'Platform System Admin', 'System Administrator', true );
        Boolean test8 = ProjectProfileServices.isUserInProjectRosterList ( testProjectProfileList[0], UserInfo.getUserId(), 'Platform System Admin', 'System Administrator', false );
        Map<Id, Project_Profile__c> test9 = ProjectProfileServices.getProjectWithRostersTaskServices( testProjectProfileList, UserInfo.getUserId() );
        List<Project_Profile__c> test10 = ProjectProfileServices.getPreBilledProjectByIds( idsOfProjects );
        Project_Profile__c test11 = ProjectProfileServices.getProjectForSendLetterById( testProjectProfileList[0].Id );
        List<Project_Profile__c> test12 = ProjectProfileServices.filteredProjectWithChangedOwner( testProjectProfileList, new Map<Id, Project_Profile__c>(testProjectProfileList) );
        ProjectProfileServices.projectWithChangedOwnerValidation ( testProjectProfileList, new Map<Id, Project_Profile__c>(testProjectProfileList) );
        ProjectProfileServices.processingOnHoldAccountingNotification( testProjectProfileList );
        ProjectProfileServices.populateUsersFieldOnProject( testProposalList, testServiceItemList, testProjectRosterList);

                                  
        Test.stopTest();

        
    }
    
    private static void testUncoveredParts() {
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        
        Set<Id> projectIds = new Set<Id>();
        for(Project_Profile__c pP : testProjectProfileList) projectIds.add( pP.Id );

        List<Change_Order__c> changeOrders = TestingUtils.createChangeOrderList(5, false);
        for(Change_Order__c cO : changeOrders) {
            cO.Project_Profile__c = testProjectPRofileList[0].Id;
            cO.Status__c = ChangeOrderServices.STATUS_DRAFT;
        }
        INSERT changeOrders;

        List<Service_Item__c> serviceItems = TestingUtils.createServiceItemList( 5, false);
        for(Service_Item__c sI : serviceItems) {
            sI.Project_Profile__c = testProjectPRofileList[0].Id;
        }
        INSERT serviceItems;

        Test.startTest();

            List<Project_Profile__c> getProjectsWithServiceItemsById = ProjectProfileServices.getProjectsWithServiceItemsById( projectIds ); 

            testProjectPRofileList[0].Project_State__c = ProjectProfileServices.PROJECT_STATE_CLOSED;
            UPSERT testProjectPRofileList[0];
            ProjectProfileServices.updateChangeOrderIfCloseProject( testProjectPRofileList );

        Test.stopTest();
    }

    private static testmethod void testGetProjectById(){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Project_Profile__c resultProjectProfile;

        Test.startTest();

            resultProjectProfile = ProjectProfileServices.getProjectById(testProjectProfileList[0].Id);

        Test.stopTest();

        System.assert(resultProjectProfile != null);
        System.assertEquals(testProjectProfileList[0].Id, resultProjectProfile.Id);
    }

    private static testmethod void testGetProjectByIdWithoutProjectProfile(){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Project_Profile__c resultProjectProfile;

        String errorString;

        Test.startTest();

            try{
                resultProjectProfile = ProjectProfileServices.getProjectById(null);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultProjectProfile == null);
    }

    private static testmethod void testGetProjectsWithServiceItemsById(){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        createProjectRosterForTest(false, true, true);
        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true )[0];
        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Proposal__c = proposal.Id;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        List<Project_Profile__c> resultProjectProfileList;

        Test.startTest();

            resultProjectProfileList = ProjectProfileServices.getProjectsWithServiceItemsById(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        Test.stopTest();

        System.assert(resultProjectProfileList != null);
        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), new Map<Id, Project_Profile__c>(resultProjectProfileList).keySet());
        for (Project_Profile__c projectProfileItem : resultProjectProfileList){
            System.assert(projectProfileItem.Service_Items__r != null);
            System.assert(!projectProfileItem.Service_Items__r.isEmpty());
            System.assert(projectProfileItem.Project_Rosters__r != null);
            System.assert(!projectProfileItem.Project_Rosters__r.isEmpty());
        }
    }

    private static testmethod void testGetProjectsWithServiceItemsByIdWithNullParameterValue(){
        List<Project_Profile__c> resultProjectProfileList;

        String errorString;

        Test.startTest();
            try{
                resultProjectProfileList = ProjectProfileServices.getProjectsWithServiceItemsById(null);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultProjectProfileList == null);
    }

    private static testmethod void testGetProgectProfileMap(){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true )[0];
        testServiceItemList = new List<Service_Item__c>();
        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Proposal__c = proposal.Id;
                testServiceItemList.add(serviceItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testServiceItemList;


        for (Service_Item__c serviceItemItem : testServiceItemList){
            testTaskItemList.addAll(TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false));
        }
        insert testTaskItemList;

        Map<Id, Project_Profile__c> resultProjectProfileMap;

        Test.startTest();

            resultProjectProfileMap = ProjectProfileServices.getProgectProfileMap(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        Test.stopTest();

        System.assert(resultProjectProfileMap != null);
        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), resultProjectProfileMap.keySet());
        for (Project_Profile__c projectProfileItem : resultProjectProfileMap.values()){
            System.assert(projectProfileItem.Service_Items__r != null);
            System.assert(!projectProfileItem.Service_Items__r.isEmpty());
            System.assert(projectProfileItem.Task_Items__r != null);
            System.assert(!projectProfileItem.Task_Items__r.isEmpty());
        }
    }

    private static testmethod void testGetProgectProfileMapWithNullParameter(){
        Map<Id, Project_Profile__c> resultProjectProfileMap;

        String errorString;

        Test.startTest();

            try{
                resultProjectProfileMap = ProjectProfileServices.getProgectProfileMap(null);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultProjectProfileMap == null);
    }

    private static testmethod void testInitProjectProfileAllOSServices(){
        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        createServiceTemplateForTest(true, false, false);

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = proposalItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        ProposalServices.proposalIdToAllOSProposalFlag = new Map<Id, Boolean>();//{testProposalList[0].Id => true};
        for (Proposal__c proposalItem : testProposalList){
            ProposalServices.proposalIdToAllOSProposalFlag.put(proposalItem.Id, true);
        }

        ProposalServices.proposalIdToServiceItems = ServiceItemServices.getServiceItemsByProposalsIdList (testProposalList);

        Project_Profile__c resultProjectProfile;

        ProjectProfileServices.proposalIdToMi3RecordTypeId = ProjectProfileServices.prepareMi3ProposalsMap(testProposalList);
        ProposalServices.initVariablesForRoleAssignment( testProposalList );

        Test.startTest();

            resultProjectProfile = ProjectProfileServices.initProjectProfile(testProposalList[0]);

        Test.stopTest();

        System.assert(resultProjectProfile != null);
    }

    private static testmethod void testInitProjectProfileNotAllOSServicesWithProjectTeam(){
        setupData ();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c propsoalItem : testProposalList){
            propsoalItem.Project_Team__c = testProjectTeamList[0].Id;
        }
        insert testProposalList;

        createServiceTemplateForTest(false, true, false);

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = proposalItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        ProposalServices.proposalIdToAllOSProposalFlag = new Map<Id, Boolean>();//{testProposalList[0].Id => true};
        for (Proposal__c proposalItem : testProposalList){
            ProposalServices.proposalIdToAllOSProposalFlag.put(proposalItem.Id, false);
        }

        ProjectProfileServices.projectTeamIdToProjectTeam = ProjectTeamServices.getProposalIdToProjectTeam( testProposalList );

        Project_Profile__c resultProjectProfile;

        ProjectProfileServices.proposalIdToMi3RecordTypeId = ProjectProfileServices.prepareMi3ProposalsMap(testProposalList);
        ProposalServices.initVariablesForRoleAssignment( testProposalList );

        Test.startTest();

            resultProjectProfile = ProjectProfileServices.initProjectProfile(testProposalList[0]);

        Test.stopTest();

        System.assert(resultProjectProfile != null);
    }

    private static testmethod void testInitProjectProfileNotAllOSServicesWithoutProjectTeam(){
        setupData ();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        createServiceTemplateForTest(false, true, false);

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = proposalItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        ProposalServices.proposalIdToAllOSProposalFlag = new Map<Id, Boolean>();
        for (Proposal__c proposalItem : testProposalList){
            ProposalServices.proposalIdToAllOSProposalFlag.put(proposalItem.Id, false);
        }

        ProjectProfileServices.projectTeamIdToProjectTeam = ProjectTeamServices.getProposalIdToProjectTeam( testProposalList );

        Project_Profile__c resultProjectProfile;

        ProjectProfileServices.proposalIdToMi3RecordTypeId = ProjectProfileServices.prepareMi3ProposalsMap(testProposalList);
        ProposalServices.initVariablesForRoleAssignment( testProposalList );

        Test.startTest();

            resultProjectProfile = ProjectProfileServices.initProjectProfile(testProposalList[0]);

        Test.stopTest();

        System.assert(resultProjectProfile != null);
    }

    private static testmethod void testCreateNewProjectProfile(){
        setupData ();

        testProposalList = TestingUtils.createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, false);
        for (Proposal__c propsalItem : testProposalList){
            propsalItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODMILESTONE;//set Billing Method 'Milestone' for Purchase Order
            propsalItem.Project_Team__c = testProjectTeamList[0].Id;
        }
        insert testProposalList;

        createServiceTemplateForTest(false, true, false);

        createProjectRosterForTest(true, false, true);

        //attach Service Item, Note, Project Roster, Phase
        testServiceItemList = new List<Service_Item__c>();
        testNoteList = new List<Note>();
        testFloorList = new List<Floor__c>();
        testPhaseList = new List<Phase__c>();
        testPurchaseOrderList = new List<Purchase_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            testNoteList.addAll(TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE, proposalItem.Id, null, false));

            for (Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
                floorItem.Proposal__c = proposalItem.Id;
                testFloorList.add(floorItem);
            }

            for (Phase__c phaseItem : TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE, false)){
                phaseItem.Proposal__c = proposalItem.Id;
                testPhaseList.add(phaseItem);
            }

            for (Purchase_Order__c purchaseOrderItem : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, null, false)){
                purchaseOrderItem.Proposal__c = proposalItem.Id;
                testPurchaseOrderList.add(purchaseOrderItem);
            }
        }
        insert testNoteList;
        insert testFloorList;
        insert testPhaseList;
        insert testPurchaseOrderList;

        for (Phase__c phaseItem : testPhaseList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = phaseItem.Proposal__c;
                    serviceItemItem.Phase__c = phaseItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }

        ProposalServices.proposalIdToAllOSProposalFlag = ProposalServices.proposalIdToAllOSProposalFlag = new Map<Id, Boolean>();
        for (Proposal__c proposalItem : testProposalList){
            ProposalServices.proposalIdToAllOSProposalFlag.put(proposalItem.Id, false);
        }

        ProposalServices.mapProposalWithNotesAndRosters = ProposalServices.getProposalsWithRelatedLists(testProposalList);

        Map<Id, Project_Profile__c> resultProjectProfileMap;

        Test.startTest();

            resultProjectProfileMap = ProjectProfileServices.createNewProjectProfile(new Map<Id, Proposal__c>(testProposalList));

        Test.stopTest();

        System.assert(resultProjectProfileMap != null);
        System.assert(!resultProjectProfileMap.isEmpty());

        testProposalList = [SELECT Id, Project_Profile__c,
                                    (Select Id, Project_Profile__c From Project_Rosters__r),
                                    (Select Id, Project__c From Floors__r),
                                    (Select Id, Project_Profile__c From Purchase_Orders__r),
                                    (Select Id, Project_Profile__c From Phases__r)
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        for (Proposal__c proposalItem : testProposalList){
            System.assert (proposalItem.Project_Profile__c != null);
            System.assertEquals (resultProjectProfileMap.get(proposalItem.Id).Id, proposalItem.Project_Profile__c);

            System.assert(!proposalItem.Floors__r.isEmpty());
            for (Floor__c floorItem : proposalItem.Floors__r){
                System.assert (floorItem.Project__c != null);
                System.assertEquals (proposalItem.Project_Profile__c, floorItem.Project__c);
            }
            System.assert(!proposalItem.Purchase_Orders__r.isEmpty());
            for (Purchase_Order__c purchaseOrderItem : proposalItem.Purchase_Orders__r){
                System.assert (purchaseOrderItem.Project_Profile__c != null);
                System.assertEquals (proposalItem.Project_Profile__c, purchaseOrderItem.Project_Profile__c);
            }
            System.assert(!proposalItem.Phases__r.isEmpty());
            for (Phase__c phaseItem : proposalItem.Phases__r){
                System.assert (phaseItem.Project_Profile__c != null);
                System.assertEquals (proposalItem.Project_Profile__c, phaseItem.Project_Profile__c);
            }
        }
    }

    private static testmethod void testAppendToExistingProjectProfileIsAmendmentFalse(){
        setupData ();

        createServiceTemplateForTest(true, true, true);

        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROPOSAL);
        Map<Id, Project_Profile__c> testProposalIdToProjectProfile = new Map<Id, Project_Profile__c>();

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
        insert projectTeamItem;

        testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = projectTeamItem.Id;
            proposalItem.Resource__c = currentUserId;
        }
        update testProposalList;

        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList) {
            testProposalIdToProjectProfile.put(projectProfileItem.Proposal__c, projectProfileItem);
            ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
        }
        update testProjectProfileList;

        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                changeOrderItem.Project_Profile__c = proposalItem.Project_Profile__c;
                changeOrderItem.Status__c = ChangeOrderServices.STATUS_APPROVED;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        testServiceItemList = new List<Service_Item__c>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                    serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                    serviceItemItem.Change_Order__c = changeOrderItem.Id;
                    serviceItemItem.Applied_Amendment__c = false;
                    serviceItemItem.Is_Alternative__c = false;
                    serviceItemItem.Original__c = false;
                    serviceItemItem.Is_Amendmend_Added__c = true;
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Manager_Lookup__c = currentUserId;
                    serviceItemItem.Region__c = RegionServices.REGION_NAME_NY;
                    serviceItemItem.Type__c = ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY;
                    //serviceItemItem.OwnerId = currentUserId;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testServiceItemList.isEmpty());

        UserServices.prepareUserRoleNameToUserId();

        testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];

        Set<Id> changeOrdersIds = new Set<Id>();
        for (Change_Order__c cho : testChangeOrderList){
            changeOrdersIds.add(cho.Id);
        }


        Test.startTest();

            ProjectProfileServices.attachServicesToProjectProfiles(new Map<Id, Proposal__c>(testProposalList), testProposalIdToProjectProfile, changeOrdersIds, new Map<Id, Service_Item__c>(testServiceItemList), true);

            for ( Service_Template__c serviceTemplateItem : testServiceTemplateList ) {
                serviceTemplateItem.Role_Assignment__c = UserServices.ROLE_MANAGER_OF_ACCOUNTS;
            }
            UPSERT testServiceTemplateList;

            testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];

            ProjectProfileServices.attachServicesToProjectProfiles(new Map<Id, Proposal__c>(testProposalList), testProposalIdToProjectProfile, changeOrdersIds, new Map<Id, Service_Item__c>(testServiceItemList), true);

            Set<Id> projectIdxSet = new Set<Id> ();
            for (Project_Profile__c projectProfileItem : testProjectProfileList){
                projectIdxSet.add( projectProfileItem.Id );
                projectProfileItem.Project_State__c = ProjectProfileServices.PROJECT_STATE_NOT_STARTED;
                projectProfileItem.Project_Team__c = projectTeamItem.Id;
            }
            update testProjectProfileList;

            List<Project_Profile__c> updateProjectTeamAssignment = new List<Project_Profile__c> ();
            updateProjectTeamAssignment.addAll( ProjectProfileServices.updateProjectTeamAssignment( projectIdxSet ) );
            updateProjectTeamAssignment.addAll( ProjectProfileServices.updateProjectTeamAssignment ( new Map<Id, Project_Team__c> { projectTeamItem.Id => projectTeamItem }, 
                                                                                                     new Map<Id, Project_Team__c> { projectTeamItem.Id => projectTeamItem } ) );
            testTaskItemList = new List<task_Item__c>();
            for (Id idx : projectIdxSet){
                for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                    taskItemItem.Project_Profile__c = idx;
                    taskItemItem.Service_Item__c = testServiceItemList[0].Id;
                    taskItemItem.Resources__c = ProjectTeamServices.RESOURCE_ROLE_MANAGER;
                    taskItemItem.Actual_End_Date__c = null;
                    testTaskItemList.add (taskItemItem);
                }
            }
            UPSERT testTaskItemList;

            ProjectProfileServices.updateServiceItemTaskItemOwnerChangeProjectTeam( testProposalIdToProjectProfile.values(), testProposalIdToProjectProfile, true );

            User u = TestingUtils.userWithProfile( UserServices.PROFILE_PRODUCTION_MANAGER );
            createProjectRosterForTest( true, true, true);
            for(Project_Roster__c pR : testProjectRosterList ) {
                pR.Project_Profile__c =  testProjectProfileList[0].Id;
            }
            UPSERT testProjectRosterList;
            System.runAs( u ) {
                ProjectProfileServices.checkIfCurrentUserCanEditFields( testProjectProfileList, new Map<Id, Project_Profile__c> ( testProjectProfileList ) );
                Boolean isUserInProjectRosterList = ProjectProfileServices.isUserInProjectRosterList( testProjectProfileList[0], u.Id, UserServices.PROFILE_PRODUCTION_MANAGER, UserServices.ROLE_DIRECTOR_OF_OPERATIONS, false);
            }
            User sharedServicesManagerUser = TestingUtils.userWithProfile(  UserServices.PROFILE_SHARED_SERVICES_MANAGER );
            System.runAs( sharedServicesManagerUser ) {
                ProjectProfileServices.projectWithChangedOwnerValidation( testProjectProfileList, new Map<Id, Project_Profile__c> ( testProjectProfileList ) );
            }

            ProjectProfileServices.updateChangeOrderIfCloseProject( testProjectProfileList );
            
            for(Proposal__c proposal : testProposalList ) {
                proposal.Project_Profile__c = testProjectProfileList[0].Id;
            }
            UPSERT testProposalList;
            for(Project_Roster__c pR : testProjectRosterList ) {
                pR.Project_Profile__c =  testProjectProfileList[0].Id;
                pR.Active__c = true;
                pR.User__c = u.Id;
                pR.Role__c = UserServices.ROLE_FDNY_DEPARTMENT_MANAGER;
            }
            UPSERT testProjectRosterList;
            for (Service_Item__c si : testServiceItemList){
                si.Is_Alternative__c = false;
                si.Project_Profile__c = testProjectProfileList[0].Id;
                si.Original__c = true;
                si.Role_Assignment__c = UserServices.ROLE_CZ_MANAGER;
                si.OwnerId = u.Id;
            }
            UPSERT testServiceItemList;

            ProjectProfileServices.populateUsersFieldOnProject( testProposalList, testServiceItemList, testProjectRosterList );
        Test.stopTest();
    }

    private static testmethod void testAppendToExistingProjectProfileIsAmendmentTrue(){
        setupData ();

        createServiceTemplateForTest(true, true, true);
        for(integer st=0; st < testServiceTemplateList.size(); st++){
            testServiceTemplateList[st].Role_Assignment__c = UserServices.ROLE_MANAGER_OF_ACCOUNTS;
        }
        update testServiceTemplateList;

        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROPOSAL);
        Map<Id, Project_Profile__c> testProposalIdToProjectProfile = new Map<Id, Project_Profile__c>();

        System.debug('!!!!!! testServiceTemplateList.size() = ' + testServiceTemplateList.size());

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
        insert projectTeamItem;

        testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = projectTeamItem.Id;
            proposalItem.Resource__c = currentUserId;
        }
        update testProposalList;

        ProjectProfileServices.idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            testProposalIdToProjectProfile.put(projectProfileItem.Proposal__c, projectProfileItem);
            ProjectProfileServices.idProposalToNewProjectProfiles.put(projectProfileItem.Proposal__c, projectProfileItem);
        }

        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(NUMBER_TO_CREATE_CHANGE_ORDER, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                changeOrderItem.Project_Profile__c = proposalItem.Project_Profile__c;
                changeOrderItem.Status__c = ChangeOrderServices.STATUS_APPROVED;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        testServiceItemList = new List<Service_Item__c>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Proposal__c = changeOrderItem.Proposal__c;
                    serviceItemItem.Project_Profile__c = changeOrderItem.Project_Profile__c;
                    serviceItemItem.Change_Order__c = changeOrderItem.Id;
                    serviceItemItem.Applied_Amendment__c = false;
                    serviceItemItem.Is_Alternative__c = false;
                    serviceItemItem.Original__c = false;
                    serviceItemItem.Is_Amendmend_Added__c = true;
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Region__c = RegionServices.REGION_NAME_NY;
                    serviceItemItem.Type__c = ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;


        System.assert(! testServiceItemList.isEmpty());

        UserServices.prepareUserRoleNameToUserId();

        testServiceItemList = [ SELECT Id, Proposal__c, Project_Profile__c, Service_Template__r.RecordType.Name,
                                    Change_Order__c, Applied_Amendment__c, Is_Alternative__c, Original__c,
                                    Is_Amendmend_Added__c, Region__c, Type__c, Service_Template__r.Role_Assignment__c, OwnerId
                                FROM Service_Item__c 
                                WHERE Id IN : testServiceItemList];

        Set<Id> changeOrdersIds = new Set<Id>();
        for (Change_Order__c cho : testChangeOrderList){
            changeOrdersIds.add(cho.Id);
        }

        Test.startTest();

            ProjectProfileServices.attachServicesToProjectProfiles(new Map<Id, Proposal__c>(testProposalList), testProposalIdToProjectProfile, changeOrdersIds, new Map<Id, Service_Item__c>(testServiceItemList), true);

        Test.stopTest();
        
    }

    //test method for coverage only, method setProjectManagerField in ProjectProfileServices does not used
    private static testmethod void testSetProjectManagerField(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testProjectProfileList = [SELECT Id, Project_Team__r.Production_Manager__c, OwnerId
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];
        
        System.assert(! testProjectProfileList.isEmpty());

        Test.startTest();

            ProjectProfileServices.setProjectManagerField(testProjectProfileList);

        Test.stopTest();
    }
    //test method for coverage only, method updateAssigneeProject in ProjectProfileServices does not used
    private static testmethod void testUpdateAssigneeProject(){
        setupData ();

        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROPOSAL);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.Project_Manager__c;
        insert projectTeamItem;

        testProposalList = [SELECT Id, Project_Team__c, Resource__c, OwnerId
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        for (Proposal__c proposalItem : testProposalList){
            proposalItem.Project_Team__c = projectTeamItem.Id;
            proposalItem.Resource__c = currentUserId;
        }

        System.assert(! testProposalList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateAssigneeProject(new Map<Id, Proposal__c>(testProposalList));

        Test.stopTest();
    }

    private static testmethod void testCalculateOutstandingAmountsByDate(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Building__c = testBuildingList[0].Id;
        }
        insert testProjectProfileList;

        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    projectProfileItem.Building__c,
                                                                                                    false)){
                proFormaInvoiceItem.Subtotal__c = 10;
                proFormaInvoiceItem.Tax__c = 10;
                proFormaInvoiceItem.Invoice_Date__c = Date.today();
                proFormaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    projectProfileItem.Building__c,
                                                                                                    false)){
                proFormaInvoiceItem.Subtotal__c = 10;
                proFormaInvoiceItem.Tax__c = 10;
                proFormaInvoiceItem.Invoice_Date__c = Date.today() - NUMBER_DAY_30;
                proFormaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    projectProfileItem.Building__c,
                                                                                                    false)){
                proFormaInvoiceItem.Subtotal__c = 10;
                proFormaInvoiceItem.Tax__c = 10;
                proFormaInvoiceItem.Invoice_Date__c = Date.today() - NUMBER_DAY_60;
                proFormaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    projectProfileItem.Building__c,
                                                                                                    false)){
                proFormaInvoiceItem.Subtotal__c = 10;
                proFormaInvoiceItem.Tax__c = 10;
                proFormaInvoiceItem.Invoice_Date__c = Date.today() - NUMBER_DAY_90;
                proFormaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    projectProfileItem.Building__c,
                                                                                                    false)){
                proFormaInvoiceItem.Subtotal__c = 10;
                proFormaInvoiceItem.Tax__c = 10;
                proFormaInvoiceItem.Invoice_Date__c = Date.today() - (NUMBER_DAY_90 + 10);
                proFormaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
        }
        insert testProFormaInvoiceList;

        System.assert(! testProFormaInvoiceList.isEmpty());

        Test.startTest();

            ProjectProfileServices.calculateOutstandingAmountsByDate(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        Test.stopTest();
    }

    private static testmethod void testFilteredProjectTeamsIdList(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest (NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, true)[0];

        Map<Id, Project_Profile__c> testProjectProfileOldMap = new Map<Id, Project_Profile__c>(testProjectProfileList.deepClone(true));

        Set<Id> testCheckResultProjectTeamSetId = new Set<Id>();

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            testCheckResultProjectTeamSetId.add (projectProfileItem.Project_Team__c);
            testCheckResultProjectTeamSetId.add (projectTeamItem.Id);
            projectProfileItem.Project_Team__c = projectTeamItem.Id;
        }

        Set<Id> resultProjectTeamSetId;

        Test.startTest();

            resultProjectTeamSetId = ProjectProfileServices.filteredProjectTeamsIdList(testProjectProfileList, testProjectProfileOldMap);

        Test.stopTest();

        System.assert (resultProjectTeamSetId != null);
        System.assert (!resultProjectTeamSetId.isEmpty());

        System.assertEquals (testCheckResultProjectTeamSetId, resultProjectTeamSetId);
    }

    private static testmethod void testFilterProjectsWithChangedProjectTeams (){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest (NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, true)[0];

        Map<Id, Project_Profile__c> testProjectProfileOldMap = new Map<Id, Project_Profile__c>(testProjectProfileList.deepClone(true));

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = projectTeamItem.Id;
        }

        List<Project_Profile__c> resultProjectProfileList;

        Test.startTest();

            resultProjectProfileList = ProjectProfileServices.filterProjectsWithChangedProjectTeamsOrOtherLookupFields(testProjectProfileList, testProjectProfileOldMap);

        Test.stopTest();

        System.assert (resultProjectProfileList != null);
        System.assert (!resultProjectProfileList.isEmpty());
        System.assertEquals (new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), new Map<Id, Project_Profile__c>(resultProjectProfileList).keySet());
    }

    private static testmethod void testUpdateProjectTeam (){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Project_Team__c projectTeamItem = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItem.Project_Member__c = projectTeamItem.FREP__c = projectTeamItem.Project_Manager__c;
        insert projectTeamItem;

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = projectTeamItem.Id;
        }

        Test.startTest();

            //ProjectProfileServices.updateProjectTeam ( testProjectProfileList );

        Test.stopTest();

        
    }

    private static testmethod void testUpdateProjectTeamAssignment(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        for (Project_Team__c projectTeamItem : testProjectTeamList){
            projectTeamItem.Project_Member__c = projectTeamItem.FREP__c = projectTeamItem.Project_Manager__c;
        }

        System.assert(! testProjectTeamList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateProjectTeamAssignment (new Map<Id, Project_Team__c>(testProjectTeamList), null);

        Test.stopTest();
    }

    private static testmethod void testUpdateProjectStateComplete(){
        prepareRecordTypePickListValuesForTest();

        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<task_Item__c>();
        for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_PROJECT_PROFILE, false)){
            taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
            testTaskItemList.add (taskItemItem);
        }
        insert testTaskItemList;

        System.assert(! testTaskItemList.isEmpty());

        for (Integer i = 0; i < testTaskItemList.size(); i++){
            testTaskItemList[i].Project_Profile__c = testProjectProfileList[i].id;
        }

        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>(testTaskItemList);

        Test.startTest();

            ProjectProfileServices.updateProjectStage (taskItemMap);

        Test.stopTest();

        for (Project_Profile__c projectProfileItem : [SELECT Id, Project_State__c
                                                      FROM Project_Profile__c
                                                      WHERE Id IN : testProjectProfileList]){
            System.assertEquals (ProjectProfileServices.PROJECT_STATE_COMPLETE, projectProfileItem.Project_State__c);
        }
    }

    private static testmethod void testUpdateProjectStateNotComplete(){
        prepareRecordTypePickListValuesForTest();

        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                testTaskItemList.add (taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>(testTaskItemList);

        Test.startTest();

            ProjectProfileServices.updateProjectStage (taskItemMap);

        Test.stopTest();

        System.assert ([SELECT Id
                        FROM Project_Profile__c
                        WHERE Id IN : testProjectProfileList AND
                                Project_State__c = : ProjectProfileServices.PROJECT_STATE_COMPLETE].isEmpty());
    }

    private static testmethod void testSetKey(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);

        Test.startTest();

            ProjectProfileServices.setKey ( testProjectProfileList );

        Test.stopTest();

        System.assert(! testProjectProfileList.isEmpty());

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            System.assert ( !String.isEmpty (projectProfileItem.Key__c) );
        }
    }

    private static testmethod void testUpdateExpectedProjectEndDate(){
        prepareRecordTypePickListValuesForTest();

        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                Integer i = 0;
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Expected_Start_Date__c = DateTime.now();
                taskItemItem.Expected_End_Date__c = DateTime.now().addDays(i);
                testTaskItemList.add (taskItemItem);
            }
        }
        insert testTaskItemList;

        System.assert(! testTaskItemList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateExpectedProjectEndDate ( new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), null );

        Test.stopTest();
    }

    private static testmethod void testUpdateServiceItemTaskItemOwnerChangeProjectTeamForAPSServices (){
        setupData ();

        for (Project_Team__c projectTeamItem : testProjectTeamList){
            projectTeamItem.Project_Member__c = projectTeamItem.FREP__c = projectTeamItem.Project_Manager__c;
        }
        update testProjectTeamList;

        createServiceTemplateForTest (false, true, false);

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true )[0];

        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                    serviceItemItem.Proposal__c = proposal.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        System.assert(! testServiceItemList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateServiceItemTaskItemOwnerChangeProjectTeam(testProjectProfileList, null);

        Test.stopTest();
    }

    /*private static testmethod void testUpdateServiceItemTaskItemOwnerChangeProjectTeamForTaskItem (){
        prepareRecordTypePickListValuesForTest();

        setupData ();

        for (Project_Team__c projectTeamItem : testProjectTeamList){
            projectTeamItem.Project_Member__c = projectTeamItem.FREP__c = projectTeamItem.Project_Manager__c;
        }
        update testProjectTeamList;

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (String stirngResourcesItem : ProjectTeamServices.PROJECT_TEAM_USERS){
                for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    taskItemItem.Project_Profile__c = projectProfileItem.Id;
                    taskItemItem.RecordTypeId = taskItemMilestoneRecordTypeId;
                    taskItemItem.Resources__c = stirngResourcesItem;
                    testTaskItemList.add(taskItemItem);
                }
                for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    taskItemItem.Project_Profile__c = projectProfileItem.Id;
                    taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                    taskItemItem.Resources__c = stirngResourcesItem;
                    testTaskItemList.add(taskItemItem);
                }
            }
        }
        insert testTaskItemList;

        System.assert(! testTaskItemList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateServiceItemTaskItemOwnerChangeProjectTeam(testProjectProfileList, null);

        Test.stopTest();
    }*/

    private static testmethod void testUpdateProjectTeamExpectedDuration(){
        prepareRecordTypePickListValuesForTest();

        bizHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true];

        setupData ();

        for (Project_Team__c projectTeamItem : testProjectTeamList){
            projectTeamItem.Expected_Duration__c = 10000000;
        }
        update testProjectTeamList;

        Project_Team__c projectTeamItemAdditional = TestingUtils.createProjectTeamList (1, currentUserId, projectManagerUser.Id, false)[0];
        projectTeamItemAdditional.Project_Member__c = projectTeamItemAdditional.FREP__c = projectTeamItemAdditional.Project_Manager__c;
        projectTeamItemAdditional.Expected_Duration__c = 0;
        insert projectTeamItemAdditional;

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        Map<Id, Project_Profile__c> projectProfileOldMap = new Map<Id, Project_Profile__c>([SELECT Id, Project_Team_Duration__c, Project_Team__c
                                                                                            FROM Project_Profile__c
                                                                                            WHERE Id IN : testProjectProfileList]);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = projectTeamItemAdditional.Id;
        }
        update testProjectProfileList;

        testProjectProfileList = [SELECT Id, Project_Team_Duration__c, Project_Team__c
                                  FROM Project_Profile__c
                                  WHERE Id IN : testProjectProfileList];

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            Integer i = 1;
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                taskItemItem.RecordTypeId = taskItemNotMilestoneRecordTypeId;
                taskItemItem.Expected_Start_Date__c = DateTime.now();
                taskItemItem.Expected_Duration__c = String.valueOf(i) + 'd ' + String.valueOf(i) + 'h ' + String.valueOf(i) + 'm';
                taskItemItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours(taskItemItem.Expected_Start_Date__c, taskItemItem.Expected_Duration__c);
                i++;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        System.assert(! testTaskItemList.isEmpty());

        Test.startTest();

            ProjectProfileServices.updateProjectTeamExpectedDuration(testProjectProfileList, projectProfileOldMap);

        Test.stopTest();
    }

    private static testmethod void testSendReportProject(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Billing_Method__c = 'Installment';
            projectProfileItem.Frequency__c = 'Monthly';
            projectProfileItem.Billing_day__c = '1';
        }
        insert testProjectProfileList;

        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false)){
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;

        System.assert(! testBillingLineItemList.isEmpty());
        
        Test.startTest();

            ProjectProfileServices.SendReportProject(testBillingLineItemList);

        Test.stopTest();
    }

    private static testmethod void testEmailBodyByProjectReport(){
        setupData ();

        testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Billing_Method__c = 'Installment';
            projectProfileItem.Frequency__c = 'Monthly';
            projectProfileItem.Billing_day__c = '1';
        }
        insert testProjectProfileList;

        Map<Id, List<Billing_Line_Item__c>> projectIdByBLI = new Map<Id, List<Billing_Line_Item__c>>();

        Map<Id, List<Service_Item__c>> projectWithServiceItemMap = new Map<Id, List<Service_Item__c>>();
        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true )[0];
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        testServiceItemList = new List<Service_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectIdByBLI.put(projectProfileItem.Id, new List<Billing_Line_Item__c>());
            projectWithServiceItemMap.put(projectProfileItem.Id, new List<Service_Item__c>());
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Proposal__c = proposal.Id;
                testServiceItemList.add(serviceItemItem);
                projectWithServiceItemMap.get(projectProfileItem.Id).add(serviceItemItem);
            }
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
        }
        insert testProformaInvoiceList;
        insert testServiceItemList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            for (Service_Item__c serviceItemItem : projectWithServiceItemMap.get(proformaInvoiceItem.Project_Profile__c)){
                for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                    proformaInvoiceItem.Project_Profile__c,
                                                                                                    proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                    proformaInvoiceItem.Billing_Contact__c,
                                                                                                    false)){
                    billingLineItem.Service_Item__c = serviceItemItem.Id;
                    testBillingLineItemList.add(billingLineItem);
                    projectIdByBLI.get(proformaInvoiceItem.Project_Profile__c).add(billingLineItem);
                }
            }
        }
        insert testBillingLineItemList;

        String testResult;

        Test.startTest();

            testResult = ProjectProfileServices.emailBodyByProjectReport(projectIdByBLI);

        Test.stopTest();

        system.assert( !String.isEmpty(testResult) );
    }

    //Project Profile Pre_billed__c == true
    private static testmethod void testGetProjectIdToAmountTypeToAmountIsPreBilled (){
        prepareRecordTypePickListValuesForTest();
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Pre_billed__c = true;
        }
    ProjectProfileServices.isAllowedPreBillGenerated = true;
        update testProjectProfileList;
    testServiceItemList[0].Project_Profile__c = testProjectProfileList[0].Id;
        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Project_Profile__c ProjectProfileItem : testProjectProfileList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                ProjectProfileItem.Id,
                                                                                                ProjectProfileItem.Billing_Company_Name__c,
                                                                                                ProjectProfileItem.Billing_Company_Contact__c,
                                                                                                false)){
                billingLineItem.IsReimbursable__c = false;
                billingLineItem.Active_Billing_Line_Item__c = true;
                billingLineItem.isHourlyConsulting__c = false;
        billingLineItem.Project_Profile__c = testProjectProfileList[0].Id;
        billingLineItem.Service_Item__c = testServiceItemList[0].Id;
        
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;

        Map<Id, Map<String, Decimal>> resultMap;

        Test.startTest();
            resultMap = ProjectProfileServices.getProjectIdToAmountTypeToAmount(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), false);
        Test.stopTest();

        System.assert(resultMap != null && !resultMap.isEmpty());
        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), resultMap.keySet());
    }

    //Project Profile Pre_billed__c = false, Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE, Interval__c = true;
    private static testmethod void testGetProjectIdToAmountTypeToAmountNotIsPreBilled (){
        prepareRecordTypePickListValuesForTest();
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Pre_billed__c = false;
            projectProfileItem.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
            projectProfileItem.Interval__c = true;
        projectProfileItem.Allow_To_Change_Billing_Method__c = true;
        }
        update testProjectProfileList;

        testBillingLineItemList = new List<Billing_Line_Item__c>();
        for (Project_Profile__c ProjectProfileItem : testProjectProfileList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                ProjectProfileItem.Id,
                                                                                                ProjectProfileItem.Billing_Company_Name__c,
                                                                                                ProjectProfileItem.Billing_Company_Contact__c,
                                                                                                false)){
                billingLineItem.IsReimbursable__c = false;
                billingLineItem.Active_Billing_Line_Item__c = true;
                billingLineItem.isHourlyConsulting__c = false;
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;

        Map<Id, Map<String, Decimal>> resultMap;

        Test.startTest();
            resultMap = ProjectProfileServices.getProjectIdToAmountTypeToAmount(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), true);
        Test.stopTest();

        System.assert(resultMap != null && !resultMap.isEmpty());
        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), resultMap.keySet());
    }

    private static testmethod void testBlockFutureBillingDatesForProjects (){
        prepareRecordTypePickListValuesForTest();
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);

        List<Project_Profile__c> projectProfilesResultList;

        Test.startTest();
            projectProfilesResultList = ProjectProfileServices.blockFutureBillingDatesForProjects(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());
        Test.stopTest();

        System.assert(projectProfilesResultList != null && !projectProfilesResultList.isEmpty());
        System.assertEquals(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(), new Map<Id, Project_Profile__c>(projectProfilesResultList).keySet());
        for(Project_Profile__c projectProfileItem : projectProfilesResultList){
            System.assert(projectProfileItem.Billing_Dates_Blocked__c);
        }
    }


    private static testmethod void testFilterProjectsWithChangedProposalCreator (){
        prepareRecordTypePickListValuesForTest();
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE * 2);

        Map<Id, Project_Profile__c> projectProfileOldMap = new Map <Id, Project_Profile__c>(testProjectProfileList.deepClone(true));
        for (Project_Profile__c projectProfileItem : projectProfileOldMap.values()){
            projectProfileItem.Proposal_Specialist__c = null;
        }

        Set<Id> checkProjectProfileSetId = new Set<Id>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_PROJECT_PROFILE; i++){
            testProjectProfileList[i].Proposal_Specialist__c = currentUserId;
            checkProjectProfileSetId.add(testProjectProfileList[i].Id);
        }

        List<Project_Profile__c> resultProjectProfileList;

        Test.startTest();
            resultProjectProfileList = ProjectProfileServices.filterProjectsWithChangedProposalCreator(testProjectProfileList, projectProfileOldMap);
        Test.stopTest();

        System.assert(resultProjectProfileList != null && !resultProjectProfileList.isEmpty());
        System.assertEquals(checkProjectProfileSetId, new Map<Id, Project_Profile__c>(resultProjectProfileList).keySet());
    }

    private static testmethod void testGetProjectRosterStatus (){
        prepareRecordTypePickListValuesForTest();
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);
        createProjectRosterForTest(true, true, true);

        testServiceItemList = new List<Service_Item__c>();
        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Project_Profile__c = projectProfileItem.Id;
                serviceItemItem.Proposal__c = projectProfileItem.Proposal__c;
                testServiceItemList.add(serviceItemItem);
            }
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testServiceItemList;
        insert testTaskItemList;

        List<Project_Roster__c> additionalProjectRosterList = new List<Project_Roster__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(1, false)){
                projectRosterItem.User__c = projectManagerUser.Id;
                projectRosterItem.Role__c = ProjectRosterServices.PROJECT_OWNER_ROLE;
                projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
                additionalProjectRosterList.add(projectRosterItem);
            }
        }
        insert additionalProjectRosterList;

        Map<Id, boolean> resultProjectRosterStatusMap;

        Test.startTest();
            resultProjectRosterStatusMap = ProjectProfileServices.getProjectRosterStatus(testProjectProfileList[0].Id);
        Test.stopTest();

        System.assert(resultProjectRosterStatusMap != null && !resultProjectRosterStatusMap.isEmpty());
        List<Project_Roster__c> projectRosterCheckList = [SELECT Id FROM Project_Roster__c WHERE Project_Profile__c =: testProjectProfileList[0].Id];

    }

    private static testmethod void testGroupTaskItemsByProjectId (){
        setupData ();
        createProposalProjectPropfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        Map<Id, List<Task_Item__c>> resultProjectWithTaskMap;

        Test.startTest();
            resultProjectWithTaskMap = ProjectProfileServices.groupTaskItemsByProjectId(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());
        Test.stopTest();

        Map<Id, Set<Id>> projectWithTaskCheckMap = new Map<Id, Set<Id>>();
        for (Project_Profile__c projectProfileItem : [SELECT Id,
                                                            (Select Id From Task_Items__r)
                                                      FROM Project_Profile__c
                                                      WHERE Id IN : testProjectProfileList]){
            projectWithTaskCheckMap.put(projectProfileItem.Id, new Map<Id, Task_Item__c>(projectProfileItem.Task_Items__r).keySet());
        }
    }

	private static testmethod void testFiltersMethod () {   //MRS 7282     
		Project_Profile__c pp = TestingUtils.createProjectProfileForTest(1, true)[0];
		pp.Billing_Method__c = ProjectProfileServices.BILLINGMETHODPERCENTAGE;
		pp.Interval__c = true;
		pp.Billing_day__c = '2';
		ProjectProfileServices.filterProjectsPercentageToChangeDateOfBillingDates(new List<Project_Profile__c> { pp },
																					new Map<Id, Project_Profile__c> { pp.Id => new Project_Profile__c(Billing_day__c = '3') } );

		Change_Order__c co = new Change_Order__c (Project_Profile__c = pp.Id);
		UPSERT co;

		ProjectProfileServices.updateProjectStatus(new Map<Id, Change_Order__c> { co.Id => co });
    }
}