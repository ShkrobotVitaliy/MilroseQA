@isTest
private class TestTaskItemExtension {

    private static ApexPages.StandardController testController;
    private static TaskItemExtension testTaskItemExtension;

    private static testMethod void testTaskItemExtension() {
        Service_Item__c currentServiceItem;
        
        for(Service_Item__c item: TestingUtils.createServiceItemList(1, false)){
            item.Subtype__c = ServiceItemServices.RFF_ALTERATION_TYPE_1; 
            insert item;
            currentServiceItem = item;   
        }
               
        for(Task_Item__c item: TestingUtils.createTaskItemList(1, false)){
            item.Service_Item__c = currentServiceItem.Id; 
            insert item;
        }
        
        
        
        List<Task_Item__c> currentTaskItem = [Select Id, Service_Item__c, Service_Item__r.Subtype__c,
                                                Project_Profile__r.Billing_Company_Name__c, Project_Profile__r.Billing_Company_Contact__c,
                                                Service_Item__r.Phase__c, Project_Profile__r.Building__c 
                                              From Task_Item__c ];
                                              
        Check__c currentCheck;
        for(Check__c item: TestingUtils.createCheckList(1, null, false)){
            item.Task_Item__c = currentTaskItem[0].Id; 
            insert item;
            currentCheck = item;
        }
        
        Test.setCurrentPageReference(Page.RequestFilingFeesTaskItem);
        testController = new ApexPages.StandardController( currentTaskItem[0] );

        Test.startTest();
            testTaskItemExtension = new TaskItemExtension(testController);
            Double test1 = testTaskItemExtension.totalFee;
            RFI_Work__c rfiWorkType = new RFI_Work__c();
            insert rfiWorkType;
            testTaskItemExtension.rfiWorkTypes.add(rfiWorkType);
            List<RFI_Work__c> test2 = testTaskItemExtension.rfiWorkTypes;
            Check__c check = new Check__c();
            insert check;
            testTaskItemExtension.checksRequest.add(check);
            List<Check__c> test5 = testTaskItemExtension.checksRequest;
            testTaskItemExtension.applyFeeCalculator();
            testTaskItemExtension.displayFeeCalculator();
            testTaskItemExtension.hideFeeCalculator() ;
            testTaskItemExtension.calculatorFee();
            testTaskItemExtension.calcualteSumFee();
            testTaskItemExtension.updateCheck();
            testTaskItemExtension.addNewCheck();
            
            testTaskItemExtension.checkIdForEditAmount = '';
            
            testTaskItemExtension.checkIdForEditAmount = check.Id;
            
        Test.stopTest();

    }
    
    private static testMethod void testForCoverage() {
        Service_Item__c currentServiceItem;
        
        for(Service_Item__c item: TestingUtils.createServiceItemList(1, false)){
            item.Subtype__c = 'test'; 
            insert item;
            currentServiceItem = item;   
        }
               
        for(Task_Item__c item: TestingUtils.createTaskItemList(1, false)){
            item.Service_Item__c = currentServiceItem.Id; 
            insert item;
        }
        
        List<Task_Item__c> currentTaskItem = [Select Id, Service_Item__c, Service_Item__r.Subtype__c,
                                                Project_Profile__r.Billing_Company_Name__c, Project_Profile__r.Billing_Company_Contact__c,
                                                Service_Item__r.Phase__c, Project_Profile__r.Building__c 
                                              From Task_Item__c ];
                                              
        Check__c currentCheck;
        for(Check__c item: TestingUtils.createCheckList(2, null, false)){
            item.Task_Item__c = currentTaskItem[0].Id; 
            insert item;
            currentCheck = item;
        }
        
        Test.setCurrentPageReference(Page.RequestFilingFeesTaskItem);
        testController = new ApexPages.StandardController( currentTaskItem[0] );

        Test.startTest();
            testTaskItemExtension = new TaskItemExtension(testController);
            testTaskItemExtension.applyFeeCalculator();
            testTaskItemExtension.displayFeeCalculator();
            testTaskItemExtension.hideFeeCalculator() ;
            testTaskItemExtension.calculatorFee();
            testTaskItemExtension.calcualteSumFee();
            testTaskItemExtension.removeCheck();
            testTaskItemExtension.checkIdToRemove = currentCheck.Id;
            testTaskItemExtension.removeCheck();
            List<SelectOption> options = testTaskItemExtension.idToAccount;
            
            Boolean test4 = testTaskItemExtension.isNotSupportServiceItem(); 
        Test.stopTest();

    }
}