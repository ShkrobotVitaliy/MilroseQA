@isTest
private class TestProcessCheckRequestsInQueueExtension {
    
    private static testMethod void testProcessCheckRequestsInQueueExtensionActionForSetCtrl(){
        Prevent_More_Than_One_Click__c customSitting = new Prevent_More_Than_One_Click__c(Name = ReimbursableExpenseInvoiceServices.CUSTOM_SETTING_IS_PROCESS_CHECKED, Is_Clicked__c = false);
        insert customSitting;

        c2g__codaPurchaseInvoice__c purchaseInvoice = new c2g__codaPurchaseInvoice__c();
        List<c2g__codaPurchaseInvoice__c> purchaseInvoices = new List<c2g__codaPurchaseInvoice__c>();
        purchaseInvoices.add(purchaseInvoice);       
        ApexPages.StandardSetController stdController = new ApexPages.StandardSetController(purchaseInvoices);
        processCheckRequestsInQueueExtension processCheck = new processCheckRequestsInQueueExtension(stdController);
        
        System.assert(processCheck != null);
        System.assert(! purchaseInvoices.isEmpty() );
        
        Test.startTest();
            processCheck.processCheckRequestsInQueue();
        Test.stopTest();

    }

}