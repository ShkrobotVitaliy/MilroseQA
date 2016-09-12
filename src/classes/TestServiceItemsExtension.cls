@isTest
private class TestServiceItemsExtension {
    private static final Integer NUMBER_TO_CREATE_RECORDS = 5;
    
    private static ApexPages.StandardController testController;
    private static ServiceItemsExtension testServiceItemsExtension;
    
    private static Project_Profile__c testingProject;
    private static Change_Order__c testingCO;
    private static TAsk_Item__c testingMilestone;
    private static List<Service_Item__c> testingServices;
    private static List<Service_Item__c> testingCOServices;
    
    private static testMethod void testServiceItemsExtension() {
        testingProject = TestingUtils.createProjectProfileList(1, null, null, null, null, null, null, null, false)[0];
        testingProject.Project_Manager__c = testingProject.OwnerId;
        insert testingProject;
        testingServices = TestingUtils.createServiceItemList( NUMBER_TO_CREATE_RECORDS, false );
        for( Service_Item__c si : testingServices ){
            si.Is_Alternative__c = false;
            si.Original__c = true;
            si.Project_Profile__c = testingProject.Id;
        }
        
        testingCO = TestingUtils.createChangeOrderList(1, false)[0];
        testingCO.Status__c = ChangeOrderServices.STATUS_APPROVED;
        testingCO.Project_Profile__c = testingProject.Id;
        insert testingCO;
        
        RecordType milestoneRT = [Select Id From RecordType Where Name = 'Milestone' limit 1];
        testingMilestone = TestingUtils.createTaskItemList( 1, false )[0];
        testingMilestone.Name = 'Test MIl';
        testingMilestone.OwnerId = UserInfo.getUserId();
        testingMilestone.Project_Profile__c = testingProject.Id;
        testingMilestone.RecordTypeId = milestoneRT.Id;
        insert testingMilestone;
        
        testingCOServices = TestingUtils.createServiceItemList( NUMBER_TO_CREATE_RECORDS, false );
        for( Service_Item__c si : testingCOServices ){
            si.Is_Alternative__c = false;
            si.Original__c = true;
            si.Project_Profile__c = testingProject.Id;
            si.Change_Order__c =  testingCO.Id;
            si.Successor_Milestone__c = 'Test MIl';
            si.Predecessor_Milestone__c = 'Test MIl';
        }
        
        testingServices.addAll( testingCOServices );
        insert testingServices;
        

        
        Test.setCurrentPageReference(Page.ServiceItemsRelatedList);
        testController = new ApexPages.StandardController( testingProject );

        Test.startTest();
            testServiceItemsExtension = new ServiceItemsExtension(testController);
        
            testServiceItemsExtension.serviceIdToApply = testingCOServices[0].Id;
            testServiceItemsExtension.applyService();
        
            testServiceItemsExtension.milestoneIdToProcess = testingMilestone.Id;
            testServiceItemsExtension.applyMilestoneName();

            testServiceItemsExtension.selectedPredecessorServiceId = testingServices[0].Id;
            testServiceItemsExtension.editPredecessorNameOnAction();

            testServiceItemsExtension.milestoneSelectedNameValue = testingMilestone.Name;
            testServiceItemsExtension.updatePredecessorMilestoneAction();
            testServiceItemsExtension.selectedSuccessorServiceId = testingServices[0].Id;
            testServiceItemsExtension.editSuccessorNameOnAction();
            testServiceItemsExtension.milestoneSelectedNameValue = testingMilestone.Name;
            testServiceItemsExtension.updateSuccessorMilestoneAction();
        
            testServiceItemsExtension.editMilestoneName();
            testServiceItemsExtension.cancelMilestoneNameChanges();
        
            testServiceItemsExtension.createNewMilestone();
            testServiceItemsExtension.newMilestone.Name = 'New MI';
            testServiceItemsExtension.saveAndNew = true;
            testServiceItemsExtension.saveNewMilestoneAction();
            
            testServiceItemsExtension.milestoneIdToProcess = testingMilestone.Id;
            testServiceItemsExtension.deleteMilestone();
        
            testServiceItemsExtension.cancelNewMilestoneAction();
            testServiceItemsExtension.serializedServiceIds = testingCOServices[0].Id;
            testServiceItemsExtension.updateServiceRowPositions();

            testServiceItemsExtension.cancelPredecessorMilestoneAction();
            testServiceItemsExtension.cancelSuccessorMilestoneAction();
            
            //Boolean enableEdit = testServiceItemsExtension.enableEditAction;
        Test.stopTest();

    }
}