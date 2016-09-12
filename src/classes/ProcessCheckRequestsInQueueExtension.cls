public with sharing class ProcessCheckRequestsInQueueExtension {
    //private Prevent_More_Than_One_Click__c preventorClick;

    public processCheckRequestsInQueueExtension( ApexPages.StandardSetController controller ) {
        //this.preventorClick = Prevent_More_Than_One_Click__c.getValues(ReimbursableExpenseInvoiceServices.CUSTOM_SETTING_IS_PROCESS_CHECKED);
    }

    public PageReference processCheckRequestsInQueue() {
        //if( !this.preventorClick.Is_Clicked__c ) {
        //    this.preventorClick.Is_Clicked__c = true;
        //    update this.preventorClick;
        try {
            CheckServices.processCheckRequestsInQueue();
            ReimbursableExpenseInvoiceServices.runPayableInvoiceClickRule(); //Trigger Clicklink Rule for creating Payable Invoices
        } catch( Exception ex ) {
            //ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
            //return null;
        }
        //this.preventorClick.Is_Clicked__c = false;
        //update this.preventorClick;
        //}
        PageReference page = new PageReference( '/' + c2g__codaPurchaseInvoice__c.sObjectType.getDescribe().getKeyPrefix() );
        page.setRedirect(true);
        return page;
    }
}