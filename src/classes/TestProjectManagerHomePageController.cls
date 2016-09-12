@isTest
private class TestProjectManagerHomePageController {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 3;

    private static  ProjectManagerHomePageController projectPageController;
    private static Integer numberToCreate = 5;
    private static final Integer ONE_USER = 1;
    private static String projectName = 'Test Project';
    private static List<Event> eventList;
    private static List<Task> taskListForPM;
    private static List<Task_Item__c> taskItemListForPM;
    private static List<Task> taskListByPM ;
    private static List<Task_Item__c> taskItemListByPM;
    private static List<Project_Profile__c> testProjectPRofileList;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProject;
    private static Project_Team__c testProjectTeam;
    private static Proposal__c testProposal;
    private static Building__c testBuilding;
    private static Map<Id, Project_Profile__c> testNotStartedProjectsForProjectManagerMap;
    private static Map<Id, Proposal__c> testProposalAndChangeOrderTracking;
    private static Service_Item__c testServiceItem;
    private static Map<Id,Service_Item__c> testUpcomingExpirations;
    private static List<Proposal__c> testPsRFPProposalChangeOrderWithOwner;
    private static Proposal__c testPsRFPProposalDraft;
    private static List<Proposal__c> testPsRFPProposalDraftsList;
    private static Map<Id,Project_Profile__c> testNewProjectAssignmentsForProdM;
    private static User projectManager;
    private static User partnerUser;
    private static User testUser;
    private static User testUserExecutive;
    private static User accountManager;
    private static User admin;
    private static User testProposalSpecialist;
    private static Set<String> testStatuses;
    private static Set<String> testDraftStatuses;
    private static List<Proposal__c> testAssignNewProjectsOMSS;
    private static Date testExpectedDate1 = Date.today();
    private static Date testExpectedDate2 = Date.today().addDays(5);
    private static List<Task_Item__c> testMileStoneTaskItemList;
    private static Id testRecordTypeId;
    private static String recordType = TaskManagementServices.MILESTONE_RECORDTYPE_NAME;
    private static Munucipalities__c testMunucipality;
    private static Region__c testRegion;
    private static List<RFI_Scope__c> testRFI_ScopeList;
    private static Id standardRecordTypeId;

    public static void setUp(){
        testProposalSpecialist = TestingUtils.userWithProfile(UserServices.PROFILE_PROPOSAL_SPECIALIST);
        admin = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);
        testStatuses = new Set<String>{ ProposalServices.PROPOSAL_STATUS_IN_REVIEW, ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT,
                                                ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW, ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW,
                                                ProposalServices.PROPOSAL_STATUS_REJECTED, ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED,
                                                ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE, ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW};
        testDraftStatuses = new Set<String>{ProposalServices.PROPOSAL_STATUS_NEW, ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE, ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW };

        projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
            
       
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        
        testUser = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);                                         

        testUserExecutive = TestingUtils.userWithProfile(UserServices.EXECUTIVE_ADMIN_PROFILE_NAME);

        System.runAs(testUser){
            //standardRecordTypeId = [Select Id From RecordType Where Name = 'Region RFI Scope'][0];
            for (Id rfiRecordTypeId : TestingUtils.getRecordTypeNameIdByObjecttypename('RFI_Scope__c').values()){
                standardRecordTypeId = rfiRecordTypeId;
                break;
            }
            System.debug(LoggingLevel.Error,'@@@standardRecordTypeId' + standardRecordTypeId);
            testAccount = TestingUtils.createAccountList(numberToCreate, 'TestAccount', true)[0];
            testContact = TestingUtils.createContactList(numberToCreate, testAccount.Id, true)[0];
            testProjectTeam = TestingUtils.createProjectTeamList(numberToCreate, testUser.Id, projectManager.id, false)[0];
                testProjectTeam.Project_Member__c = testUser.Id;
                insert testProjectTeam;
            testRegion = TestingUtils.createRegionList(numberToCreate, 'testRegion', true)[0];
            testRFI_ScopeList = TestingUtils.createRFI_ScopeList(numberToCreate, testRegion.Id, false);
                for(RFI_Scope__c item : testRFI_ScopeList){
                    item.RecordTypeId = standardRecordTypeId;
                }
                insert testRFI_ScopeList;
            testMunucipality = TestingUtils.createMunicipalitiesList(numberToCreate, 'testmunicipality', testRegion.Id, true)[0];
            testBuilding = TestingUtils.createBuildingList(numberToCreate, testMunucipality.Id, 'TestStreet', 'TestHouse', 'TestCity', '77777', true)[0];

            testProposal = TestingUtils.createProposalList( numberToCreate,
                                                            'Test Project',
                                                            testAccount.Id,
                                                            testContact.Id,
                                                            testAccount.Id,
                                                            testContact.Id,
                                                            testBuilding.Id,
                                                            Date.today().addDays(10),
                                                            10,
                                                            Date.today().addDays(5),
                                                            Date.today().addDays(7),
                                                            partnerUser.Id,
                                                            partnerUser.Id,
                                                            projectManager.Id,
                                                            false)[0];
               // testProposal.Project_Team__c =  testProjectTeam.Id;
                testProposal.Proposal_Awarded_Date__c = Date.today();
                
                //testProposal.Project_Profile__c = testProject.Id;
               // testProposal.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
                testProposal.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
                testProposal.Assigner_OM__c = true;
                insert  testProposal;
            
            //create proposals
            List<Proposal__c> proposalsToSetup = new List<Proposal__c>();
            List<String> proposalStatuses = new List<String> {  ProposalServices.PROPOSAL_STATUS_IN_REVIEW,
                                                                ProposalServices.PROPOSAL_STATUS_AWARDED,
                                                                ProposalServices.PROPOSAL_STATUS_EXPIRED};
            //create respective number of proposals for each status
            for(String status : proposalStatuses){
                List<Proposal__c> proposals = TestingUtils.createProposalList( numberToCreate, 'Test Project', testAccount.Id, testContact.Id, testAccount.Id,
                                                            testContact.Id, testBuilding.Id,  Date.today().addDays(10), 10,  Date.today().addDays(5), Date.today().addDays(7),
                                                            partnerUser.Id, partnerUser.Id, projectManager.Id, false);
                //set status
                for (Proposal__c prop : proposals){
                    prop.Status__c = status;
                    prop.Assigner_OM__c = true;
                    testProposal.Proposal_Awarded_Date__c = Date.today();
                }
                proposalsToSetup.addAll(proposals);
            }
            insert proposalsToSetup;
            
            testPsRFPProposalDraft = TestingUtils.createProposalDraftList( numberToCreate, partnerUser.Id, false)[0];
                testPsRFPProposalDraft.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
                testPsRFPProposalDraft.OwnerId = admin.Id;
                insert testPsRFPProposalDraft;
            testProject = TestingUtils.createProjectProfileList(numberToCreate,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                testAccount.Id,
                                                                testContact.Id,
                                                                null,
                                                                false)[0];
            testProject.OwnerId = projectManager.Id;
            testProject.Proposal__c = testProposal.Id;
            testProject.Building__c = testBuilding.Id;
            testProject.Project_Manager__c = projectManager.Id;
            testProject.Project_Team__c = testProjectTeam.Id;
            insert testProject;

            testServiceItem = TestingUtils.createServiceItemList(numberToCreate, testProposal.Id, false)[0];
                testServiceItem.Project_Profile__c = testProject.Id;
                testServiceItem.Expiration_Date__c = Date.today().addDays(25);
                insert testServiceItem;

            List<Task> taskListBad = TestingUtils.createTaskList(numberToCreate, true);
            List<Task_Item__c> taskItemListBad = TestingUtils.createTaskItemList(numberToCreate, true);
            eventList = TestingUtils.createEventList(numberToCreate, true);

            eventList = [ Select WhoId, WhatId, Subject, OwnerId, Id, Description, CreatedDate, CreatedById From Event];
            taskListForPM = TestingUtils.createTaskList(numberToCreate, false);
            for(Task item : taskListForPM){
                item.OwnerId = testUser.Id;
            }
            insert taskListForPM;

            //testRecordType = [SELECT Id,SobjectType,Name From RecordType Where SobjectType ='Task_Item__c' AND RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME][0];
            testRecordTypeId = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c').get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);

            taskItemListForPM = TestingUtils.createTaskItemList(numberToCreate, false);
            for(Task_Item__c item : taskItemListForPM){
                item.OwnerId = testUser.Id;
                item.RecordTypeId = testRecordTypeId;
                //item.Name = TaskManagementServices.MILESTONE_RECORDTYPE_NAME;
                item.Expected_Start_Date__c=Date.today().addDays(1);                
            }

            insert taskItemListForPM;

            for(Integer i = 0; i <= taskItemListForPM.size()-2;i++ ){
                taskItemListForPM[i].Name = 'TestName' + i;
                taskItemListForPM[i+1].Name = 'TestName' + i;
                taskItemListForPM[i].Successor_Milestone__c = taskItemListForPM[i+1].Id;
                taskItemListForPM[i+1].Predecessor_Milestone__c = taskItemListForPM[i].Id;
            }
            update taskItemListForPM;


            taskListForPM = [Select WhatId,  ActivityDate, What.Name, Priority, Subject, Status, OwnerId, Id, Description, CreatedDate, CreatedById, ReminderDateTime
                             From Task t Where OwnerId =: testUser.Id ];

            taskItemListForPM = [ Select Status__c, Spent_Hours__c, Project_Start_Date__c, Project_Profile__c, Planned_Start_Date__c, Planned_End_Date__c, Planned_Durration__c, OwnerId,
                                     Name, LastModifiedDate, Id, Description__c, CreatedDate, CreatedById, Comments__c, Actual_Start_Date__c, Actual_End_Date__c, Actual_Duration__c,
                                     Action__c From Task_Item__c Where OwnerId =: testUser.Id ];




            taskListByPM = [Select WhatId,  ActivityDate, What.Name, Priority, Subject, Status, OwnerId, Id, Description, CreatedDate, CreatedById, ReminderDateTime
                                          From Task
                                          Where CreatedById =: testUser.Id ];

            taskItemListByPM = [SELECT Id,OwnerId,Name,CreatedById,CreatedDate,LastModifiedDate FROM Task_Item__c WHERE CreatedById =: testUser.Id];


            testNotStartedProjectsForProjectManagerMap = new Map<Id, Project_Profile__c>([ Select Id, Name, Primary_Company_Name__r.Name, Building__r.Name,
                 Proposal__c, Proposal__r.Proposal_Awarded_Date__c, Project_Team__r.Project_Manager__c, Project_Team__r.Project_Member__c
             From Project_Profile__c
             Where Submitted_Planned_Dates__c = false AND (Project_Team__r.Project_Manager__c = :projectManager.Id OR Project_Team__r.Project_Member__c = :testUser.Id) AND
                 Proposal__r.Proposal_Awarded_Date__c != null
             limit 1000]);

             testProposalAndChangeOrderTracking = new Map<Id, Proposal__c> ([ Select p.Version__c, p.Status__c, p.Proposal_RFP_Request_Date__c, p.Proposal_Awarded_Date__c, p.Project_Team__r.Project_Manager__c,
                                                                            p.Project_Team__c, p.Project_Profile__r.Proposal_Awarded_Date__c, p.Project_Profile__r.Building__c,
                                                                            p.Project_Profile__r.Name, p.Project_Profile__c, p.OwnerId, p.Name, p.Id, p.CreatedDate, p.CreatedById,
                                                                            p.Change_History__c, p.Change_Request_Date__c, p.Last_Change_Approved_Date__c
                                                                            From Proposal__c p
                                                                            Where (p.Project_Team__r.Project_Manager__c = :testUser.Id OR p.Project_Team__r.Project_Member__c = :testUser.Id) AND
                                                                                (p.Status__c =: ProposalServices.PROPOSAL_STATUS_AWARDED OR p.Status__c =: ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED OR
                                                                                p.Status__c =: ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED)
                                                                            limit 1000]);

            testUpcomingExpirations = new Map<Id, Service_Item__c>([ Select Proposal__r.Expiration_Date__c, Proposal__r.Floor_s__c, Proposal__r.Address__c, Proposal__r.Project_Name__c, Proposal__r.Name, Proposal__r.Primary_Company_Name__c, 
                                                Proposal__r.Id, Proposal__c, Project_Profile__r.Building__c, Project_Profile__r.Primary_Company_Name__c, Project_Profile__r.Municipal_Agency_ID__c, 
                                                Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__c, Project_Number__c, Name, Id, Expiration_Date__c,
                                                Proposal__r.Project_Team__r.Project_Manager__c, Proposal__r.Project_Team__r.Project_Member__c, Proposal__r.Primary_Company_Name__r.Name,
                                                Project_Profile__r.Building__r.Name, Service_Name_Full__c 
                                            From Service_Item__c s 
                                            Where (Expiration_Date__c <=: Date.today().addDays(30) AND Expiration_Date__c >=: Date.today()) AND 
                                                (Project_Profile__r.Project_Team__r.Project_Manager__c = :projectManager.Id OR Project_Profile__r.Project_Team__r.Project_Member__c = :testUser.Id)
                                            limit 1000]);
            System.debug(LoggingLevel.error,'@@@testUpcomingExpirations'+ testUpcomingExpirations);

            testPsRFPProposalChangeOrderWithOwner =[Select Version__c, Status__c, Proposal_Type__c, Proposal_RFP_Request_Date__c, Project_Profile__r.Name, Project_Profile__c, Project_Name__c, Name, Address__c,  OwnerId 
                                                    From Proposal__c
                                                    Where OwnerId = : testUser.Id
                                                    AND (Status__c IN: testStatuses) limit 1000];
            System.debug(LoggingLevel.error,'@@@testPsRFPProposalChangeOrderWithOwner'+ testPsRFPProposalChangeOrderWithOwner);


            testPsRFPProposalDraftsList = [Select Version__c, Status__c, Requested_By__c, Primary_Company_Name__c, OwnerId, Name, Account_Executive__c, Proposal_RFP_Request_Date__c, Internal_Reviewer__c, Id, Floor_s__c, Description__c, Address__c, Project_Name__c From Proposal__c
                                       Where OwnerId = : testUser.Id
                                       AND (Status__c IN: testDraftStatuses) limit 1000];
            System.debug(LoggingLevel.error,'@@@testPsRFPProposalDraftsList'+ testPsRFPProposalDraftsList);
            List<Project_Profile__c> testListProfile = [Select Id,Proposal__r.Proposal_Awarded_Date__c,Submitted_Planned_Dates__c,Project_Team__r.Production_Manager__c from Project_Profile__c];
            System.debug(LoggingLevel.error,'@@@testListProfile'+ testListProfile);
            testNewProjectAssignmentsForProdM = new Map<Id, Project_Profile__c>([Select Id, Name, Primary_Company_Name__r.Name, Building__r.Name,
                                                                                     Proposal__c, Proposal__r.Proposal_Awarded_Date__c, Project_Team__r.Project_Manager__c, Project_Team__r.Project_Member__c, Project_Team__r.Name, Project_Team__r.Id
                                                                                 From Project_Profile__c
                                                                                 Where Submitted_Planned_Dates__c = false AND (Project_Team__r.Production_Manager__c = :projectManager.Id) AND
                                                                                     Proposal__r.Proposal_Awarded_Date__c != null
                                                                                 limit 1000]);

            System.debug(LoggingLevel.error,'@@@testNewProjectAssignmentsForProdM'+ testNewProjectAssignmentsForProdM);

            testAssignNewProjectsOMSS = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c, Description__c, Name, Address__c,  OwnerId 
                                         From Proposal__c
                                         Where Status__c = : ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null limit 1000];
             

            //testMileStoneTaskItemList = TestingUtils.createTaskItemList(numberToCreate, true);
        }
    }

    private static testmethod void testUncoveredParts() {
        setUp();
        System.runAs( testUser ) {
            Test.startTest();
            String curUserName = ProjectManagerHomePageController.currentUserName;
            String curProfile = ProjectManagerHomePageController.currentUserProfileName;
            Set<ID> roleSubUsers = ProjectManagerHomePageController.getRoleSubordinateUsers( ProjectManagerHomePageController.currentUserId );
            List<UserRole> reportToCurRole = ProjectManagerHomePageController.reportToCurrentRole;
        }
    }

    private static testmethod void testUncoveredPartsExecutive() {
        setUp();
        System.runAs( testUserExecutive ) {
            Test.startTest();
            
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            ProjectManagerHomePageController pmhpc = new ProjectManagerHomePageController();

            List<Proposal__c> processProposals = pmhpc.processingProposals;
            Boolean needProp = pmhpc.needProposal;
            Boolean isSIPSUser = pmhpc.isSIPSUser;
            Boolean isProjectManager1 = pmhpc.isProjectManager1;
            Boolean isPartner = pmhpc.isPartner;
            List<selectOption> partnerOptions = pmhpc.partnerOptions;
            String partnerId = pmhpc.partnerId;
            String colorPartner = pmhpc.colorPartner;
            PageReference refreshPartner = pmhpc.refreshPartner();
            List<Admin_Service__c> adminServiceListForOM = pmhpc.adminServiceListForOM;
            List<Proposal_Request__c> proposalRequestListForOM  = pmhpc.proposalRequestListForOM;
            List<Change_Order__c> partnerChangeOrders = pmhpc.partnerChangeOrders;
            pmhpc.partnerChangeOrdersDefault();
            pmhpc.executiveAdminsChangeOrdersDefault();
            List<Proposal__c> partnerRFPProposalsInProcess = pmhpc.partnerRFPProposalsInProcess;
            pmhpc.partnerRFPProposalsInProcessDefault();
            List<Proposal__c> proposalsInInternalReviewSIPS = pmhpc.proposalsInInternalReviewSIPS;
            List<Service_Item__c> upcomingExpirationsList = pmhpc.upcomingExpirationsList;
            List<Service_Item__c> partnerServices = pmhpc.partnerServices;
            String partnerServicesSeqNumber = pmhpc.partnerServicesSeqNumber;
            pmhpc.partnerServicesDefault();
            List<Service_Item__c> executiveAdminMyServices = pmhpc.executiveAdminMyServices;
            Map<Id, Project_Profile__c> newProjectAssignmentsForProdM = pmhpc.newProjectAssignmentsForProdM;
            List<Project_Profile__c> partnerActiveProjects = pmhpc.partnerActiveProjects;
            pmhpc.partnerActiveProjectsDefaults();
            List<Task_Item__c> getMilestones = pmhpc.getMilestones();
            pmhpc.executiveAdminMyServicesDefault();

            Test.stopTest();
        }
    }

        private static testmethod void testTaskItemListForPM(){
            setUp();
            System.runAs(testUser){

                Test.startTest();
                    Test.setCurrentPageReference(Page.PMSFTaskActivities);
                    projectPageController =  new ProjectManagerHomePageController();
                    Map<Id, Service_Item__c> upcomingExpirationsAdmDepartmentManager = projectPageController.upcomingExpirationsAdmDepartmentManager;
                    List<Service_Item__c> serviceAssignmentsAdmDepartmentManager = projectPageController.serviceAssignmentsAdmDepartmentManager;
                    List<Proposal__c> assignNewProjectsOMSS = projectPageController.assignNewProjectsOMSS;
                Test.stopTest();

                System.assertEquals(taskListForPM.size(), projectPageController.tasksForProjectManager.size());

               
               Map<Id,Task_Item__c> taskItemMapForPm = new Map<Id,Task_Item__c>();
                for(Task_Item__c item : taskItemListForPM){
                    taskItemMapForPm.put(item.id,item);
                }
               
            }

        }

        private static testmethod void testTaskItemListByPM(){
            setUp();
            System.runAs(testUser){

                Test.startTest();
                    Test.setCurrentPageReference(Page.PMSFTaskActivities);
                    projectPageController =  new ProjectManagerHomePageController();
                Test.stopTest();

                System.assertEquals(taskListByPM.size(), projectPageController.tasksByProjectManager.size());

               
                for(Task item : taskListByPM){
                    System.Assert( projectPageController.tasksByProjectManager.get(item.id)==item);
                }


                Map<Id, Task_Item__c> TaskItemMapByPm = new Map<Id, Task_Item__c> ();
                for(Task_Item__c item : taskItemListByPM){
                    TaskItemMapByPm.put(item.id,item);
                }
           }
        }

        private static testmethod void testProposalAndChangeOrderTracking(){
            setUp();
            System.runAs(testUser){

                Test.startTest();
                    Test.setCurrentPageReference(Page.PMNewProjectNotifications);
                    projectPageController =  new ProjectManagerHomePageController();
                Test.stopTest();

                System.assertEquals(testNotStartedProjectsForProjectManagerMap.size(), projectPageController.notStartedProjectsForProjectManagerMap.size());

                }
        }

        

    

        private static testmethod void testNewProjectAssignmentsForProdM(){
            setUp();
            System.runAs(admin){

                Test.startTest();
                    Test.setCurrentPageReference(Page.ProdMNewProjectAssignments);
                    projectPageController =  new ProjectManagerHomePageController();
                Test.stopTest();
                List<Profile> testprofList =[SELECT Id, Name, UserLicense.Name FROM Profile WHERE Name = 'Account Manager'];
                 System.debug(LoggingLevel.Error,'@@@currentProfileList'+ testprofList);

 
            }
        }
        
// never Used just for small coverage
        private static testmethod void testDoSearch(){
            //String recordType = TaskManagementServices.MILESTONE_RECORDTYPE_NAME;
            setUp();
            Id projectManagerId = projectManager.Id;
            System.runAs(admin){

                Test.startTest();
                    Test.setCurrentPageReference(Page.ProdMMilestoneActionView);
                    projectPageController =  new ProjectManagerHomePageController();
                Test.stopTest();

                for(Integer a = 0; a<=3; a++){
                    if(a == 0 ){
                        projectPageController.expectedDate1 = null;
                        projectPageController.expectedDate2 = null;
                    }else if(a == 1){
                        projectPageController.expectedDate1 = testExpectedDate1;
                        projectPageController.expectedDate2 = null;
                    }else if(a == 2){
                        projectPageController.expectedDate1 = null;
                        projectPageController.expectedDate2 = testExpectedDate2;
                    }else if(a == 3){
                        projectPageController.expectedDate1 = testExpectedDate1;
                        projectPageController.expectedDate2 = testExpectedDate2;
                    }
                    
                   String tasksQuery = 'SELECT Id, Name, Expected_Start_Date__c, Planned_Start_Date__c, Actual_Start_Date__c, Project_Profile__r.Project_Team__c, Project_Profile__r.Floor_s__c, Project_Profile__r.Expected_Occupancy_Date__c, '; 
                   tasksQuery += 'Project_Profile__r.Expected_Construction_Start_Date__c, Project_Profile__r.Building__c, Project_Profile__r.Primary_Company_Name__c, Project_Profile__r.OwnerId, Project_Profile__r.Id, Project_Profile__c,Project_Profile__r.Primary_Company_Name__r.Name, ';
                   tasksQuery += 'Project_Profile__r.Building__r.Name, Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Task_Status_Color__c, Expected_End_Date__c, Actual_End_Date__c '; 
                   tasksQuery += 'FROM Task_Item__c WHERE RecordType.Name =: recordType AND Project_Profile__r.Project_Team__r.Production_Manager__c =: projectManagerId AND Expected_Start_Date__c != null ';
                   
                    if ( projectPageController.expectedDate1 != null && projectPageController.expectedDate2 != null ) {
                    System.debug(LoggingLevel.Error,'@@@Stage 2');
                       tasksQuery += 'AND Expected_Start_Date__c >=: testExpectedDate1 AND Expected_Start_Date__c <=: testExpectedDate2 limit 1000';
                      
                   } else if ( projectPageController.expectedDate1 == null && projectPageController.expectedDate2 != null ){
                    System.debug(LoggingLevel.Error,'@@@Stage 3');
                       tasksQuery += 'AND Expected_Start_Date__c <=: testExpectedDate2 limit 1000';
                      
                   } else if ( projectPageController.expectedDate1 != null && projectPageController.expectedDate2 == null ){
                    System.debug(LoggingLevel.Error,'@@@Stage 4');
                       tasksQuery += 'AND Expected_Start_Date__c >=: testExpectedDate1 limit 1000 ';
                       
                   } else {
                    System.debug(LoggingLevel.Error,'@@@Stage 5');
                       tasksQuery += 'limit 1000';                     
                   }
                   List<Task_Item__c> testList = DataBase.query(tasksQuery);
                   System.debug(LoggingLevel.Error,'@@@testList'+ testList);
                   
                    testList = [SELECT Id,Name From Task_Item__c Where RecordType.Name =: recordType];
                    System.debug(LoggingLevel.Error,'@@@testList'+ testList );
                    List<Task_Item__c> testTaskItemList = DataBase.query(tasksQuery);
                    projectPageController.doSearch();
                    System.debug(LoggingLevel.Error,'@@@projectPageController.milestones;'+projectPageController.milestones);


                    Map<String, Task_Item__c> testTaskItemNameTaskItemMap = new Map<String, Task_Item__c>();
                    Map<Id, Task_Item__c> testMap = new Map<Id, Task_Item__c>();
                    for(Task_Item__c item : projectPageController.milestones){
                         testMap.put(item.id,item);
                    }
                    for(Task_Item__c  milestoneTaskItem : testTaskItemList) {
                        if (testTaskItemNameTaskItemMap.containsKey(milestoneTaskItem.Name)){
                            continue;
                        }
                        if (milestoneTaskItem.Task_Items1__r.isEmpty() && milestoneTaskItem.Successor_Milestones__r.isEmpty()){
                            testTaskItemNameTaskItemMap.put(milestoneTaskItem.Name, milestoneTaskItem);
                            continue;
                        }
                        Task_Item__c testTaskItem = milestoneTaskItem.Task_Items1__r.isEmpty() ?  milestoneTaskItem.Successor_Milestones__r[0] : milestoneTaskItem.Task_Items1__r[0];


                        System.assertEquals(testTaskItem.Actual_Start_Date__c, testMap.get(testTaskItem.Id).Actual_Start_Date__c);
                        System.assertEquals(testTaskItem.Expected_Start_Date__c, testMap.get(testTaskItem.Id).Expected_Start_Date__c);
                        System.assertEquals(testTaskItem.Actual_End_Date__c, testMap.get(testTaskItem.Id).Actual_End_Date__c);
                        System.assertEquals(testTaskItem.Expected_End_Date__c, testMap.get(testTaskItem.Id).Expected_End_Date__c);

                        
                    }
                }
                
            }
        }
         
   private static testmethod void testAssignNewProjectsOMSS(){
        accountManager = TestingUtils.userWithProfile('Account Manager');
        setUp();
            for(Task_Item__c item : taskItemListForPM){
                item.Project_Profile__c = testProject.Id;
            }
            update taskItemListForPM;
        testProposal.Project_Team__c = null;
        testProposal.Assigner_OM__c = false;
        testProposal.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            update testProposal;
            
        testAssignNewProjectsOMSS = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c, Description__c, Name, Address__c,  OwnerId 
                                     From Proposal__c
                                     Where Status__c = : ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null limit 1000];
        
        
        
        System.runAs(admin){

            Test.startTest();
                Test.setCurrentPageReference(Page.OMNewProjectAssignments);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();

            // testAssignNewProjectsOMSS
//            System.assertEquals(testAssignNewProjectsOMSS.size(), projectPageController.countAssignNewProjectsOMSS);
            Map<Id,Proposal__c> testMapProposal = new Map<Id,Proposal__c>();
            for(Proposal__c item : testAssignNewProjectsOMSS){
                testMapProposal.put(item.Id,item);
            }
            for(Proposal__c item : projectPageController.assignNewProjectsOMSS){
                System.assertEquals(testMapProposal.get(item.id), item);
            }
        }
    }
    
    private static testmethod void testsIsProposalSpecialist (){
        setUp();
        System.runAs(testProposalSpecialist ){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testBoolean = projectPageController.isProposalSpecialist; 
            Test.stopTest();
            
            
        }
        
    }
    
    private static testmethod void testsIsProposalSpecialistFalse (){
        setUp();
        System.runAs(admin ){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testBoolean = projectPageController.isProposalSpecialist; 
            Test.stopTest();
            
            
        }
        
    }
    
     private static testmethod void testCurrentProfile (){
        setUp();
        System.runAs(admin){
            
            
            Test.startTest();
                Test.setCurrentPageReference(Page.PMSFTaskActivities);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();
            
            
            List<Profile> testCurrentProfile = new List<Profile>();
           // testCurrentProfile = projectPageController.currentProfile;
        }
    }
    
    private static testmethod void testChangeOrders (){
        setUp();
        System.runAs(admin){
            Test.startTest();
                Test.setCurrentPageReference(Page.PMChangeOrderTracking);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();
            
            List<Change_Order__c> changeOrders = projectPageController.changeOrders; 
        }
    }
    
    private static testmethod void testChangeOrdersAccountManager (){
        setUp();
        User accMan = TestingUtils.userWithProfile(UserServices.PROFILE_ACCOUNT_MANAGER);
        System.runAs(accMan){
            Test.startTest();
                Test.setCurrentPageReference(Page.PMChangeOrderTracking);
                projectPageController =  new ProjectManagerHomePageController();
                MilroseSetting__c milroseSetting = new MilroseSetting__c(Name = 'ARReportID');
                insert milroseSetting;
                String arUrl = projectPageController.arURL;
            Test.stopTest();
            
            List<Change_Order__c> changeOrders = projectPageController.changeOrders; 
        }
    }
    
    private static testmethod void testChangeOrdersProposalSpecialist (){
        setUp();
        User proposalSpec = TestingUtils.userWithProfile(UserServices.PROFILE_PROPOSAL_SPECIALIST );
        System.runAs(proposalSpec){
            Test.startTest();
                Test.setCurrentPageReference(Page.PMChangeOrderTracking);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();
            
            List<Change_Order__c> changeOrders = projectPageController.changeOrders; 
        }
    }
    
    private static testmethod void testChangeOrdersProjectManager (){
        setUp();
        System.runAs(projectManager){
            Test.startTest();
                Test.setCurrentPageReference(Page.PMChangeOrderTracking);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();
            
            List<Change_Order__c> changeOrders = projectPageController.changeOrders; 
        }
    }
    
    private static testmethod void testChangeOrdersZonningAnalyst(){
        setUp();
        User zonningAnalist = TestingUtils.userWithProfile(UserServices.PROFILE_CODE_ZONING_ANALYST);

        UserRole roleCZManager = new UserRole(Name = UserServices.ROLE_CZ_MANAGER);
        insert roleCZManager;
        zonningAnalist.UserRoleId = roleCZManager.Id;
        update zonningAnalist;

        System.runAs(zonningAnalist){
            Test.startTest();
                Test.setCurrentPageReference(Page.PMChangeOrderTracking);
                projectPageController =  new ProjectManagerHomePageController();
            Test.stopTest();
            
            List<Change_Order__c> changeOrders = projectPageController.changeOrders; 
        }
    }
    
    /*private static testMethod void testIsCZAnalyst(){
        setUp();
        User isCZAnalyst = TestingUtils.userWithProfile(UserServices.PROFILE_CODE_ZONING_ANALYST);
        System.runAs(isCZAnalyst){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testCZAnalyst = projectPageController.isCZAnalyst; 
            Test.stopTest();
        }
    }*/
    
    private static testMethod void testIsCZAnalystFalse(){
        setUp();
        User isCZAnalyst = TestingUtils.userWithProfile(UserServices.PROFILE_CODE_ZONING_ANALYST);
        System.runAs(admin){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testCZAnalyst = projectPageController.isCZAnalyst; 
            Test.stopTest();
        }
    }
    
    private static testMethod void testIsFREP(){
        setUp();
        User isFREP = TestingUtils.userWithProfile(UserServices.PROFILE_FREP);
        System.runAs(isFREP){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testFREP = projectPageController.isFREP; 
            Test.stopTest(); 
        }
    }
    
    private static testMethod void testIsFREPFalse(){
        setUp();
        User isFREP = TestingUtils.userWithProfile(UserServices.PROFILE_FREP);
        System.runAs(admin){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                Boolean testFREP = projectPageController.isFREP; 
            Test.stopTest(); 
        }
    }
    
    private static testMethod void testPsRFPProposalsZonningAnalyst(){
        setUp();
        User zonningAnalist = TestingUtils.userWithProfile(UserServices.PROFILE_CODE_ZONING_ANALYST);

        UserRole roleCZManager = new UserRole(Name = UserServices.ROLE_CZ_MANAGER);
        insert roleCZManager;
        zonningAnalist.UserRoleId = roleCZManager.Id;
        update zonningAnalist;

        System.runAs(zonningAnalist){ 
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                List<Proposal__c> psRFPProposals  = projectPageController.psRFPProposals;
            Test.stopTest();
        }
    }
    
    private static testMethod void testPsRFPProposalsTracking(){
        setUp();
        User accManager = TestingUtils.userWithProfile(UserServices.PROFILE_ACCOUNT_MANAGER);
        
        List<Proposal__c> proposals = [select id from Proposal__c];
        
        for (Proposal__c prop : proposals){
            prop.Internal_Reviewer__c = accManager.Id;
        }
        update proposals;
        
        System.runAs(accManager){ 
            Test.setCurrentPageReference(Page.PSRPFProposalTracking);
            projectPageController =  new ProjectManagerHomePageController();
             
            List<Proposal__c> psRFPProposals  = projectPageController.proposalsTraking;
            System.assert(psRFPProposals.size() != 0);  
        }
    }
 
    private static testmethod void testAssignNewProjectsOMSSServiceManager(){
        User operationManager = TestingUtils.userWithProfile(UserServices.PROFILE_OPERATIONS_MANAGER );
        setUp();
            for(Task_Item__c item : taskItemListForPM){
                item.Project_Profile__c = testProject.Id;
            }
            update taskItemListForPM;
        testProposal.Project_Team__c = null;
        testProposal.Assigner_OM__c = false;
        testProposal.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            update testProposal;
            
        testAssignNewProjectsOMSS = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c, Description__c, Name, Address__c,  OwnerId 
                                     From Proposal__c
                                     Where Status__c = : ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null limit 1000];
                                     
                                     
        System.runAs(operationManager){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                List<Proposal__c> assignNewProjectsOMSS = projectPageController.assignNewProjectsOMSS;
            Test.stopTest();            
        }                             
    }
    
    private static testmethod void testAssignNewProjectsOMSSOperationManager(){
        User serviceManager = TestingUtils.userWithProfile(UserServices.PROFILE_SHARED_SERVICES_MANAGER );
        setUp();
            for(Task_Item__c item : taskItemListForPM){
                item.Project_Profile__c = testProject.Id;
            }
            update taskItemListForPM;
        testProposal.Project_Team__c = null;
        testProposal.Assigner_OM__c = false;
        testProposal.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
            update testProposal;
            
        testAssignNewProjectsOMSS = [Select Id, Assigner_OM__c, Assigner_SS__c, Proposal_Awarded_Date__c, Primary_Company_Name__c, Floor_s__c, Description__c, Name, Address__c,  OwnerId 
                                     From Proposal__c
                                     Where Status__c = : ProposalServices.PROPOSAL_STATUS_AWARDED AND Proposal_Awarded_Date__c != null AND Project_Team__c = null limit 1000];
                                     
                                     
        System.runAs(serviceManager){
            Test.setCurrentPageReference(Page.PMSFTaskActivities);
            projectPageController =  new ProjectManagerHomePageController();
            
            Test.startTest();
                List<Proposal__c> assignNewProjectsOMSS = projectPageController.assignNewProjectsOMSS;
            Test.stopTest();            
        }                             
    }
}