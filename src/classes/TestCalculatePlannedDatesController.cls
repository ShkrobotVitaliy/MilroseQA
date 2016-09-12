@isTest
private class TestCalculatePlannedDatesController {
    public static CalculatePlannedDatesController calcPlannedDatesController;
    public static final Integer NUMBER_TO_CREATE = 3;
    public static String testProjectProfileId;
    public static Map<Id, Service_Item__c> testServicesWithTasks;
    
    public static String INVALID_PROJECT_PROFILE = 'Invalid Project Profile';
    public static String NO_SERVICES_FOR_PROJECT_PROFILE = 'No Services for Project Profile';
    public static String PLANNED_DATES_SUBMITTED_FOR_PROJECT_PROFILE = 'Planned Dates already committed for given Project Profile';
    public static String PROJECT_START_DATE_IS_NOT_SPECIFIED = 'Project Start Date has not been specified. Please do it before Project Expected Dates calculation.';
    public static Map<Id, Set<Id>> testTaskIdWithPredecessors = new Map<Id, Set<Id>>();
    public static Map<Id, Set<Id>> testTaskIdWithSuccessors = new Map<Id, Set<Id>>();
    public static Map <Id, Map<Integer, Task_Item__c>> taskManMap = new Map <Id, Map<Integer, Task_Item__c>>();
    public static Map<Id, Task_Item__c> testTaskIdToTask = new Map<Id, Task_Item__c>();
    public static User testUser;
    public static Account testAccount;
    public static Contact testContact;
    public static List<Project_Profile__c> projectProfileList;
    public static List<Service_Item__c> testServiceItemList;   
    public static List<Task_Item__c> testTaskItem;    
    public static List<Service_Item__c> secondTestServiceItemList;   
    public static List<Task_Item__c> taskItemMilstoneList; 
    public static  Project_Profile__c testCurrentProject;
    public static Integer SequenceTestNumber = 0; 
    private static final String IS_SUBMIT ='isSubmit';
    private static BusinessHours bizHours;
    private static Integer seqNumber = 1;
    private static Set<Id> serviceIdSet;
    private static RecordType testRecordType;
    
    public static void setUp(){
        testServiceItemList = new List<Service_Item__c>();
        testTaskItem = new List<Task_Item__c>();
        serviceIdSet = new Set<Id>();
        testUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
            testContact.AccountId = testAccount.Id;
            insert testContact;
        Building__c testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, null, 'TestStreet', 'TestHouse', 'TestCity', 'TestZip', true)[0];  
        Proposal__c testProposal = TestingUtils.createProposalList(NUMBER_TO_CREATE, 
                                                                   'testProject', 
                                                                   testAccount.Id, 
                                                                   testContact.Id, 
                                                                   testAccount.Id, 
                                                                   testContact.Id, 
                                                                   testBuilding.Id, 
                                                                   Date.today(), 
                                                                   null, 
                                                                   Date.today(), 
                                                                   Date.today(), 
                                                                   null, 
                                                                   null, 
                                                                   null, 
                                                                   false)[0];
            testProposal.Proposal_Awarded_Date__c = date.today();
            testProposal.Proposal_RFP_Request_Date__c = date.today();
            
            insert testProposal;  
         List<Project_Profile__c> badProjectProfileList = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, 
                                                                                               testAccount.id, 
                                                                                               testContact.Id, 
                                                                                               testAccount.id, 
                                                                                               testContact.Id, 
                                                                                               testAccount.Id, 
                                                                                               testContact.id, 
                                                                                               testUser.id, 
                                                                                               true);      
            
        projectProfileList = TestingUtils.createProjectProfileList( 1, 
                                                                    testAccount.id, 
                                                                    testContact.Id, 
                                                                    testAccount.id, 
                                                                    testContact.Id, 
                                                                    testAccount.Id, 
                                                                    testContact.id, 
                                                                    testUser.id, 
                                                                    true);
            for(Project_Profile__c item : projectProfileList){
                item.Project_Start_Date__c = Date.today();  
                item.Submitted_Planned_Dates__c = false;
                for(Service_Item__c serviceItem : TestingUtils.createServiceItemList(2, false)){
                    serviceItem.Proposal__c = testProposal.Id;
                    serviceItem.Project_Profile__c = item.id; 
                    serviceItem.Expected_Start_Date__c  = Date.today();
                    serviceItem.Is_Alternative__c = false;
                    serviceItem.Original__c = true;
                    testServiceItemList.add(serviceItem);
                }                 
            }
                update projectProfileList;
            testServiceItemList[0].Predecessor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;
            testServiceItemList[0].Successor_Milestone__c = TaskManagementServices.MILESTONE_PROJECT_START;         
             
                insert testServiceItemList; 
       
       for(Service_Item__c serviceItem : testServiceItemList){ 
            serviceIdSet.add(serviceItem.Id);    
            for(Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE, false)){
                taskItem.Service_Item__c = serviceItem.Id;
                if(seqNumber == 4) {
                    seqNumber = 1;  
                }
                taskItem.Sequence_Number__c = seqNumber; 
                taskItem.Predecessor_Milestone_from_Template__c = TaskManagementServices.MILESTONE_RECORDTYPE_NAME + ' ' + 'Task'+ ' ' + serviceItem.Id;
                taskItem.Successor_Milestone_from_Template__c = TaskManagementServices.MILESTONE_RECORDTYPE_NAME + ' ' + 'Task' + ' ' + serviceItem.Id;
                taskItem.Expected_Start_Date__c = Date.today();
                taskItem.Expected_Duration__c = '30d';
                taskItem.Expected_End_Date__c = Date.today().addDays(30);
                taskItem.Actual_Start_Date__c = Date.today();
                taskItem.Delay_End_Date__c = '5d';
                
                testTaskItem.add(taskItem); 
                seqNumber ++;               
            }
        }               
       // update testServiceItemList; 
        insert testTaskItem;  
         
        testTaskItem = [SELECT Id,Predecessor_Milestone_from_Template__c,Successor_Milestone_from_Template__c,Predecessor_Task__c,Successor_Task__c,Service_Item__c FROM Task_Item__c WHERE Service_Item__c IN : serviceIdSet];  
        
        for(Integer i = 0 ;i<=testTaskItem.size()-2;i++){
            testTaskItem[i+1].Predecessor_Task__c = testTaskItem[i].Id;
            testTaskItem[i].Successor_Task__c = testTaskItem[i+1].Id;   
        }                  
            update testTaskItem;
        List<Task_Item__c> testList = [SELECT Id,Predecessor_Task__c,Successor_Task__c,Sequence_Number__c,Expected_End_Date__c,Service_Item__c FROM Task_Item__c Where Service_Item__c =: testServiceItemList[0].Id OR Service_Item__c =: testServiceItemList[1].Id ];
      
        testList = [SELECT Id,Predecessor_Task__c,Expected_End_Date__c,Successor_Task__c FROM Task_Item__c  ];
        
        ApexPages.currentPage().getParameters().put('Id',projectProfileList[0].Id);                                                                                   
        testProjectProfileId = ApexPages.currentPage().getParameters().get('Id');          
                                                                                       
        testCurrentProject = [ Select Id, Submitted_Planned_Dates__c, Project_Start_Date__c
                                                  From Project_Profile__c 
                                                  Where Id = : testProjectProfileId ];  
                                                                                   
        
        testServicesWithTasks = new Map<Id, Service_Item__c>( [ SELECT Id, Proposal__c, Service_Template__c, Planned_Start_Date__c,
                                                                       Total_Planned_Service_Duration__c, Project_Profile__r.Project_Start_Date__c, 
                                                                       Expected_Start_Date__c, Expected_End_Date__c, Expected_Service_Duration__c,
                                                                       Project_Profile__r.Submitted_Planned_Dates__c, Name,
                                                                       Successor_Milestone__c, Predecessor_Milestone__c,
                                                                       ( Select Id, Planned_Durration__c, Name, Predecessor_Milestone__c, 
                                                                                Sequence_Number__c, Successor_Milestone__c, Predecessor_Task__c, 
                                                                                Successor_Task__c, Predecessor_Milestone_from_Template__c, 
                                                                                Successor_Milestone_from_Template__c, Service_Item__c,
                                                                                Expected_Duration__c, Expected_End_Date__c, Expected_Start_Date__c,
                                                                                Planned_Start_Date__c, Planned_End_Date__c, Delay_End_Date__c
                                                                         From Task_Items__r )
                                                                FROM Service_Item__c
                                                                WHERE Project_Profile__c = : testProjectProfileId ] );
        bizHours = [SELECT Id FROM BusinessHours WHERE IsDefault=true];                                                                
    
    }   

    private static void setupPage(Id projId, Boolean isSubmit, Id serviceItemId){

        Test.setCurrentPageReference(Page.CalculatePlannedDates);
        ApexPages.currentPage().getParameters().put('Id', projId);
        ApexPages.currentPage().getParameters().put(IS_SUBMIT, String.valueOf(isSubmit));
        ApexPages.currentPage().getParameters().put('serviceId', serviceItemId); 
    }
                                                
    private static testmethod void testCalculatePlannedDatesController(){   
        setUp();
        setupPage(testCurrentProject.Id, null, null);

        User profilePlatformManager = TestingUtils.userWithProfile(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN);

        System.RunAs( profilePlatformManager ){

            Map<Id,Service_Item__c> testMapWithServices = new Map<Id,Service_Item__c>();     
                                                                        
            Test.startTest();                   
                calcPlannedDatesController =  new CalculatePlannedDatesController();                
            Test.stopTest();
                
            System.assert(calcPlannedDatesController.isValidUser);
            System.assert(calcPlannedDatesController.project.Id != null );
            System.assert(! calcPlannedDatesController.servicesWithTasks.isEmpty() );         
        }
    }
    
    private static testmethod void testCalculatePlannedDatesControllerErrMsg(){   
        setup();
        setupPage(testCurrentProject.Id, null, null);

        User platfSysAdm = TestingUtils.userWithProfile(UserServices.PROFILE_FINANCE_MANAGER);
        //set no Proposal_Specialist__c 
 
        testCurrentProject.Proposal_Specialist__c = null;
        update testCurrentProject;

        System.runAs(platfSysAdm) {

          System.assert(! ApexPages.hasMessages());

          Test.startTest();                   
              calcPlannedDatesController =  new CalculatePlannedDatesController();                
          Test.stopTest();

          System.assert(calcPlannedDatesController != null);
//          System.assert(ApexPages.hasMessages());
//          System.assert( !calcPlannedDatesController.isValidUser );
        }
            
    }
   
     private static testmethod void testCalculatePlannedDatesController_calculatePlannedDatesForServices_successorTasksForCurrentIsNotNull(){
        setUp();
       
        Test.setCurrentPageReference(Page.CalculatePlannedDates);
        ApexPages.currentPage().getParameters().put('Id',projectProfileList[0].Id);
        ApexPages.currentPage().getParameters().put(IS_SUBMIT, null);
        ApexPages.currentPage().getParameters().put('serviceId',testServiceItemList[0].Id); 
        
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
        testServiceItemList = [Select Id, Predecessor_Milestone__c,Successor_Milestone__c,Planned_End_Date__c,Total_Planned_Service_Duration__c,
                               Project_Profile__c,Project_Profile__r.Project_Start_Date__c,Expected_Service_Duration__c,Expected_Start_Date__c,
                               Expected_End_Date__c,Planned_Start_Date__c,
                               (SELECT Id,Expected_Start_Date__c,Expected_Duration__c FROM Task_Items__r)                               
                               FROM Service_Item__c WHERE Project_Profile__c = : projectProfileList[0].Id];
        //Service_Item__c Predecessor_Milestone__c and  Successor_Milestone__c Assert   
        System.assertEquals(TaskManagementServices.MILESTONE_PROJECT_START, testServiceItemList[0].Predecessor_Milestone__c);
        System.assertEquals(TaskManagementServices.MILESTONE_PROJECT_START, testServiceItemList[0].Successor_Milestone__c);
        //System.assertEquals(TaskManagementServices.MILESTONE_RECORDTYPE_NAME + ' ' + 'Task'+ ' ' + testServiceItemList[1].Id, testServiceItemList[1].Predecessor_Milestone__c);
        //System.assertEquals(TaskManagementServices.MILESTONE_RECORDTYPE_NAME + ' ' + 'Task' + ' ' + testServiceItemList[1].Id, testServiceItemList[1].Successor_Milestone__c);
        
        /*for(Service_Item__c serviceItem : testServiceItemList){
            if( serviceItem.Predecessor_Milestone__c.contains( TaskManagementServices.MILESTONE_PROJECT_START ) ){              
               System.assertEquals(DateUtils.getDatetimeWithTimeShiftByBusinessHours ( bizHours, serviceItem.Project_Profile__r.Project_Start_Date__c, null ), serviceItem.Expected_Start_Date__c);
                System.assertEquals(DateUtils.getDatetimeWithTimeShiftByBusinessHours( bizHours, serviceItem.Expected_Start_Date__c, serviceItem.Expected_Service_Duration__c ), serviceItem.Expected_End_Date__c);
                System.assertEquals(serviceItem.Expected_Start_Date__c, serviceItem.Planned_Start_Date__c);
                System.assertEquals(serviceItem.Planned_End_Date__c, serviceItem.Expected_End_Date__c);
                System.assertEquals(serviceItem.Expected_Service_Duration__c, serviceItem.Total_Planned_Service_Duration__c);
                
            }
        }
        System.assert(ApexPages.currentPage().getURL().contains(testServiceItemList[0].Id));*/
    }
   
  
    private static testmethod void testCalculatePlannedDatesController_calculatePlannedDatesForServices_ProjectStartDateIsSubmitNotNull(){ 
        setUp();  
         for(Project_Profile__c item : projectProfileList){                 
                item.Project_Expected_End_Date__c = Date.today().addDays(45);
            }
            update projectProfileList;       
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Expected_End_Date__c = serviceItemItem.Expected_Start_Date__c.addDays(1);
        }
        update testServiceItemList;
        ApexPages.currentPage().getParameters().put(IS_SUBMIT, 'NotNull');
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
        testServicesWithTasks = new Map<Id, Service_Item__c>( [ SELECT Id, Proposal__c, Service_Template__c, Milestone_Sequence_Number__c, Planned_Start_Date__c,
                                                                       Total_Planned_Service_Duration__c, Project_Profile__r.Project_Start_Date__c, 
                                                                       Expected_Start_Date__c, Expected_End_Date__c, Expected_Service_Duration__c,
                                                                       Project_Profile__r.Submitted_Planned_Dates__c, Name,Predecessor_Milestone__c,Planned_End_Date__c,
                                                                       ( Select Id, Planned_Durration__c, Name, Predecessor_Milestone__c, 
                                                                                Sequence_Number__c, Successor_Milestone__c, Predecessor_Task__c, 
                                                                                Successor_Task__c, Predecessor_Milestone_from_Template__c, 
                                                                                Successor_Milestone_from_Template__c, Service_Item__c,
                                                                                Expected_Duration__c, Expected_End_Date__c, Expected_Start_Date__c,
                                                                                Planned_Start_Date__c, Planned_End_Date__c, Delay_End_Date__c
                                                                         From Task_Items__r )
                                                                FROM Service_Item__c
                                                                WHERE Project_Profile__c = : testProjectProfileId ] );
      
        testCurrentProject = [ Select Id, Submitted_Planned_Dates__c,Project_State__c,Project_Start_Date__c
                                                  From Project_Profile__c 
                                                  Where Id = : testProjectProfileId ]; 
                      
        System.assertEquals(true, testCurrentProject.Submitted_Planned_Dates__c); 
        System.assertEquals(ProjectProfileServices.PROJECT_STATE_IN_PROCESS, testCurrentProject.Project_State__c);
       
    } 
    
     private static testmethod void testCalculatePlannedDatesController_PlannedDatesSubmittedForProjectProfile_Error_ExpectedDateIsNull(){
        setUp();  
        for(Project_Profile__c item : projectProfileList){                 
                item.Submitted_Planned_Dates__c = true;
            }
            update projectProfileList;
        ApexPages.currentPage().getParameters().put(IS_SUBMIT, '');
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
//        System.assert(TestingUtils.pageMessagesContain(CalculatePlannedDatesController.DATES_ARE_NOT_CALCULATED));
        System.assertEquals(null,calcPlannedDatesController.calculateDates());
        
    } 
    private static testmethod void testCalculatePlannedDatesController_PlannedDatesSubmittedForProjectProfile_Error(){
        setUp();  
        for(Project_Profile__c item : projectProfileList){                 
                item.Submitted_Planned_Dates__c = true;
                item.Project_Expected_End_Date__c = Date.today().addDays(45);
            }
            update projectProfileList;
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Expected_End_Date__c = serviceItemItem.Expected_Start_Date__c.addDays(1);
        }
        update testServiceItemList;
        ApexPages.currentPage().getParameters().put(IS_SUBMIT, 'NotNull');
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
//        System.assert(TestingUtils.pageMessagesContain(CalculatePlannedDatesController.PLANNED_DATES_SUBMITTED_FOR_PROJECT_PROFILE));
        System.assertEquals(null,calcPlannedDatesController.calculateDates());
        
    } 
   
     private static testmethod void testCalculatePlannedDatesController_ProjectDateIsNull(){
        setUp();  
        for(Project_Profile__c item : projectProfileList){                 
                item.Project_Start_Date__c  = null;
            }
            update projectProfileList;  
        
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
//        System.assert(TestingUtils.pageMessagesContain(PROJECT_START_DATE_IS_NOT_SPECIFIED ));
        System.assertEquals(null, calcPlannedDatesController.calculateDates());            
     }
     
     private static testmethod void testCalculatePlannedDatesController_EmptyServiceTasks(){
        setUp();
        delete testTaskItem;
        delete testServiceItemList;
        
        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        Test.startTest();
            calcPlannedDatesController.calculateDates();
        Test.stopTest();
        
//        System.assert(TestingUtils.pageMessagesContain(NO_SERVICES_FOR_PROJECT_PROFILE  ));
        System.assertEquals(null, calcPlannedDatesController.calculateDates());  
        
     }

    private static testmethod void testCalculateDatesWithSuccessorChange(){ 
        setUp();  
        setupPage(testCurrentProject.Id, null, null);

        for(Project_Profile__c item : projectProfileList){                 
                item.Project_Expected_End_Date__c = Date.today().addDays(45);
        }
        update projectProfileList;       

        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Expected_End_Date__c = serviceItemItem.Expected_Start_Date__c.addDays(1);
            serviceItemItem.Predecessor_Milestone__c = 'Project Start';
            serviceItemItem.Successor_Milestone__c = 'test2';  
        }
        update testServiceItemList;

        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        PageReference pr;

        Test.startTest();
            pr = calcPlannedDatesController.calculateDates();
            CalculatePlannedDatesController.futureCalculation( projectProfileList[0].Id, testTaskItem[0].Id);
            calcPlannedDatesController.project.Project_State__c = ProjectProfileServices.PROJECT_STATE_ON_HOLD;
            PageReference calculateDates = calcPlannedDatesController.calculateDates();
        Test.stopTest();
      
        System.assert(! ApexPages.hasMessages(), ApexPages.getMessages() );
        System.assert(! String.isBlank(pr.getUrl()) );

    }

    private static testmethod void testCalculateDatesWithSuccessorMethods(){ 
        setUp();  
        setupPage(testCurrentProject.Id, true, null);

        for(Project_Profile__c item : projectProfileList){                 
                item.Project_Expected_End_Date__c = Date.today().addDays(45);
        }
        update projectProfileList;       

        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Expected_End_Date__c = serviceItemItem.Expected_Start_Date__c.addDays(1);
            serviceItemItem.Predecessor_Milestone__c = 'Project Start';
            serviceItemItem.Successor_Milestone__c = 'test2';  
        }
        update testServiceItemList;

        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        PageReference pr;

        Test.startTest();
            try {
              calcPlannedDatesController.project.Project_State__c = ProjectProfileServices.PROJECT_STATE_ON_HOLD;
              PageReference calculateDates = calcPlannedDatesController.calculateDates();
            } catch ( Exception ex) {}
        Test.stopTest();
    }

    private static testmethod void testCalculateDatesWithSuccessorFunctions(){ 
        setUp();  
        setupPage(testCurrentProject.Id, true, null);

        for(Project_Profile__c item : projectProfileList){                 
                item.Project_Expected_End_Date__c = Date.today().addDays(45);
        }
        update projectProfileList;       

        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Expected_End_Date__c = serviceItemItem.Expected_Start_Date__c.addDays(1);
            serviceItemItem.Predecessor_Milestone__c = 'Project Start';
            serviceItemItem.Successor_Milestone__c = 'test2';  
        }
        update testServiceItemList;

        calcPlannedDatesController =  new CalculatePlannedDatesController();    
        
        PageReference pr;

        Test.startTest();
            try {
              calcPlannedDatesController.project.Billing_Method__c  = ProjectProfileServices.BILLINGMETHODINSTALLMENT;
              calcPlannedDatesController.project.Billing_End_Date__c  = null;
              PageReference calculateDates = calcPlannedDatesController.calculateDates();
            } catch ( Exception ex) {}
        Test.stopTest();
    }          
      
}