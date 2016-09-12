@isTest
private class TestProcessCheckRequestForCheckView {
    
    private static testMethod void testProcessCheckRequestsInQueueExtensionActionForSetCtrl(){
        Prevent_More_Than_One_Click__c customSitting = new Prevent_More_Than_One_Click__c(Name = ReimbursableExpenseInvoiceServices.CUSTOM_SETTING_IS_PROCESS_CHECKED, Is_Clicked__c = false);
        insert customSitting;

        Check__c checkRequest        = new Check__c();
        List<Check__c> checkRequests = new List<Check__c>();
        checkRequests.add(checkRequest);
        
        ApexPages.StandardSetController stdController       = new ApexPages.StandardSetController(checkRequests);
        ProcessCheckRequestForCheckRequestView processCheck = new ProcessCheckRequestForCheckRequestView(stdController);
        
        
        Test.startTest();
            processCheck.processCheckRequestsInQueue();
        Test.stopTest();
        
        System.assert(processCheck != null);
        System.assert(! checkRequests.isEmpty() );
    }
    
}