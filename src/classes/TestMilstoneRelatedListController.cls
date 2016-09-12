@isTest
private class TestMilstoneRelatedListController {
    private static ApexPages.Standardcontroller sc;
    private static MilstoneRelatedListController milstoneContr;
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer ONE_USER  = 1;
    private static Integer sequenceNumber =  1;
    private static User projectManagerUser;
    private static Account testAccount;
    private static Contact testContact;
    private static Project_Profile__c testProject;
    private static Service_Item__c testServiceItem;
    private static List<Task_Item__c> testTaskItemList;
    private static RecordType testRecordType;
    private static List <Task_Item__c> testSelectedTaskItemList;
    private static List<Task_Item__c> taskItemMilstoneList;
    private static List<Task_Item__c> testTaskItemListForTestMethod ;
    private static Set<String> testNameSet;
    
    

        private static void setUp(){
            projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);                                                
            testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
            testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, false)[0];
                testContact.AccountId = testAccount.Id;
                insert testContact;
            testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE, 
                                                                                   testAccount.Id, 
                                                                                   testContact.Id, 
                                                                                   testAccount.Id, 
                                                                                   testContact.Id, 
                                                                                   testAccount.Id, 
                                                                                   testContact.Id, 
                                                                                   projectManagerUser.Id, 
                                                                                   true)[0];    
            testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false)[0];
                    testServiceItem.Predecessor_Milestone__c =  ProjectProfileServices.PROJECT_MILESTONE_PROJECT_START;
                    insert  testServiceItem;                                                                
            
                                                                       
            testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, false);
                for(Task_Item__c item : testTaskItemList){
                    item.Service_Item__c = testServiceItem.Id;
                    item.Project_Profile__c = testProject.Id;
                    item.Sequence_Number__c = sequenceNumber++;     
                    item.Actual_Start_Date__c = Date.today();
                    item.Expected_Start_Date__c = Date.today();
                    item.Planned_Start_Date__c = Date.today();          
                    item.Name = ProjectProfileServices.PROJECT_MILESTONE_PROJECT_START;            
                            
                }                                                                             
                insert testTaskItemList;
                
            testRecordType = [SELECT Id,SobjectType,Name From RecordType Where SobjectType ='Task_Item__c' AND RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME][0];
            
            taskItemMilstoneList = TestingUtils.createTaskItemList(2, null, testProject.Id, false);
                for(Task_Item__c item : taskItemMilstoneList){
                    item.RecordTypeId = testRecordType.Id;                    
                    item.Actual_Start_Date__c = Date.today();
                    item.Expected_Start_Date__c = Date.today();
                    item.Planned_Start_Date__c = Date.today();  
                }
                insert taskItemMilstoneList;
                
                taskItemMilstoneList[0].Name = ProjectProfileServices.PROJECT_MILESTONE_PROJECT_START;
                taskItemMilstoneList[1].Name = ProjectProfileServices.PROJECT_MILESTONE_CUNSTRUCTION_DOCUMENT_APPROVAL;
                update taskItemMilstoneList;
                
                
            testTaskItemList[0].Predecessor_Milestone__c = taskItemMilstoneList[0].Id;          
            testTaskItemList[1].Successor_Milestone__c = taskItemMilstoneList[1].Id;               
            update testTaskItemList; 
            
            testSelectedTaskItemList = [SELECT Id, Name, Expected_Start_Date__c, Planned_Start_Date__c, Actual_Start_Date__c,
                                                (Select Id, Expected_Start_Date__c, Service_Item__r.Milestone_Sequence_Number__c, Planned_Start_Date__c, Actual_Start_Date__c
                                                 From Task_Items1__r Order By Sequence_Number__c limit 1),
                                                (Select Id, Expected_Start_Date__c, Service_Item__r.Milestone_Sequence_Number__c, Planned_Start_Date__c, Actual_Start_Date__c
                                                 From Successor_Milestones__r Order By Sequence_Number__c limit 1)
                                        FROM Task_Item__c
                                        WHERE RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME
                                        AND Project_Profile__c = : testProject.Id ORDER BY Sequence_Number__c ASC];
     
            testTaskItemListForTestMethod = new List<Task_Item__c>();
            testNameSet = new Set<String>();
                for(Task_Item__c item : testSelectedTaskItemList){
                    if(!testNameSet.contains(item.Name)){
                        testTaskItemListForTestMethod.add(item);
                        testNameSet.add(item.Name);
                    }
                }
        }
      
        private static testmethod void testMilstoneRelListController() {
            setUp();           
               
            Test.startTest();
                Test.setCurrentPageReference(Page.MilestonesRelatedList);
                sc = new ApexPages.Standardcontroller(testProject);
                milstoneContr = new MilstoneRelatedListController(sc);
            Test.stopTest();        
            
            System.assertEquals(testTaskItemListForTestMethod.size(), milstoneContr.milestoneTaskItemList.size());    
            
            Map<Id,Task_Item__c> testMap = new Map<Id,Task_Item__c>();
            for(Task_Item__c item : testTaskItemListForTestMethod){         
                for(Task_Item__c itemR : item.Task_Items1__r){
                    testMap.put(itemR.Id,item);
                }
                
            }       
            
            for (Task_Item__c milestoneTaskItem : milstoneContr.milestoneTaskItemList){                 
                 for (Task_Item__c taskItem : milestoneTaskItem.Task_Items1__r){
                    System.assertEquals(testMap.get(taskItem.Id).Actual_Start_Date__c, milestoneTaskItem.Actual_Start_Date__c);
                    System.assertEquals(testMap.get(taskItem.Id).Expected_Start_Date__c, milestoneTaskItem.Expected_Start_Date__c);
                    System.assertEquals(testMap.get(taskItem.Id).Planned_Start_Date__c, milestoneTaskItem.Planned_Start_Date__c);
                    System.assertEquals(1, milestoneTaskItem.Sequence_Number__c);
    
                 }          
            }      
                    
            Map<Id,Task_Item__c> secondTestMap = new Map<Id,Task_Item__c>();
            for(Task_Item__c item : testTaskItemListForTestMethod){                   
                for(Task_Item__c itemR : item.Successor_Milestones__r){
                    secondTestMap.put(itemR.Id,item);
                }
                
            }
            
            System.assert(! secondTestMap.isEmpty() );

            for (Task_Item__c milestoneTaskItem : milstoneContr.milestoneTaskItemList){                    
                 for (Task_Item__c taskItem : milestoneTaskItem.Successor_Milestones__r){                              
                    System.assertEquals(secondTestMap.get(taskItem.Id).Actual_Start_Date__c, milestoneTaskItem.Actual_Start_Date__c);
                    System.assertEquals(secondTestMap.get(taskItem.Id).Expected_Start_Date__c, milestoneTaskItem.Expected_Start_Date__c);
                    System.assertEquals(secondTestMap.get(taskItem.Id).Planned_Start_Date__c, milestoneTaskItem.Planned_Start_Date__c);
                    System.assertEquals(1, milestoneTaskItem.Sequence_Number__c);
                    
                 }
                
            }
            
        }
        
        private static testmethod void testSaveAndNewMilestoneAction(){
            setUp(); 
            Test.setCurrentPageReference(Page.MilestonesRelatedList);
            sc = new ApexPages.Standardcontroller(testProject);
            milstoneContr = new MilstoneRelatedListController(sc);  
            milstoneContr.creatingActionOn();
            milstoneContr.newMilestone.Name = 'TestName';         
               
            Test.startTest();
               milstoneContr.saveAndNewMilestoneAction(); 
            Test.stopTest(); 
            
            System.assertEquals(testProject.Id, milstoneContr.newMilestone.Project_Profile__c);
            System.assertEquals(TaskManagementServices.MILESTONE_RECORDTYPE_ID, milstoneContr.newMilestone.RecordTypeId);
            
        }
         
         private static testmethod void testSaveAndNewMilestoneAction_Error_Name(){
            setUp(); 
            Test.setCurrentPageReference(Page.MilestonesRelatedList);
            sc = new ApexPages.Standardcontroller(testProject);            
            milstoneContr = new MilstoneRelatedListController(sc);
            milstoneContr.creatingActionOn();
            milstoneContr.cancelNewMilestoneAction();
                milstoneContr.saveNewMilestoneAction();
                milstoneContr.setEditbeValue();
                milstoneContr.unSetEditbeValue();
                milstoneContr.updateName();
                milstoneContr.updateNameAction();
                milstoneContr.taskIdToUpdate = null;
                milstoneContr.deleteMilestone();
                milstoneContr.deleteMilestoneAction();                    
               
            Test.startTest();
               milstoneContr.saveAndNewMilestoneAction(); 
            Test.stopTest(); 
            
            System.assert(TestingUtils.pageMessagesContain('Please input new Milestones name'));
            
        }
         
       private static void testMilstoneRelListControllerTaskItemTest() {
            setUp();
            
             taskItemMilstoneList[0].Name = ProjectProfileServices.PROJECT_MILESTONE_CUNSTRUCTION_DOCUMENT_APPROVAL;
             taskItemMilstoneList[1].Name = ProjectProfileServices.PROJECT_MILESTONE_PROJECT_START;
                update taskItemMilstoneList;
                
                
            testTaskItemList[0].Predecessor_Milestone__c = taskItemMilstoneList[0].Id;          
            testTaskItemList[1].Predecessor_Milestone__c = taskItemMilstoneList[1].Id;
            testTaskItemList[0].Name = ProjectProfileServices.PROJECT_MILESTONE_CUNSTRUCTION_DOCUMENT_APPROVAL;              
                 update testTaskItemList; 
                 
            Test.startTest();
                Test.setCurrentPageReference(Page.MilestonesRelatedList);
                sc = new ApexPages.Standardcontroller(testProject);
                milstoneContr = new MilstoneRelatedListController(sc);
                milstoneContr.cancelNewMilestoneAction();
                milstoneContr.saveNewMilestoneAction();
                milstoneContr.setEditbeValue();
                milstoneContr.unSetEditbeValue();
                milstoneContr.updateName();
                milstoneContr.updateNameAction();
                milstoneContr.deleteMilestone();
                milstoneContr.deleteMilestoneAction();
                
            Test.stopTest();
            
            System.assert(milstoneContr != null);
        }
        
}