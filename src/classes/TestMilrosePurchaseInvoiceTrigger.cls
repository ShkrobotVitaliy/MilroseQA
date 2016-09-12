@isTest (seeAllData = true)
private class TestMilrosePurchaseInvoiceTrigger {
    
    private static testmethod void testInsertCodaPurchaseInvoice(){
        Boolean hasClosedPeriodErrors = false;
        Account accountItem = TestingUtils.createAccountList(1, null, false)[0];
        accountItem.c2g__CODABaseDate1__c = 'Invoice Date';

        //Account Name should be unique
        accountItem.Name = 'tes' + String.valueOf( System.now().millisecond() ) + 't';

        while ( ![SELECT Id, Name FROM Account WHERE Name = : accountItem.Name].isEmpty() ){
            accountItem.Name = accountItem.Name + '1';
        }
        insert accountItem;

        c2g__codaPurchaseInvoice__c purchaseInvoice = new c2g__codaPurchaseInvoice__c(c2g__Account__c = accountItem.Id, c2g__AccountInvoiceNumber__c = '1', c2g__DueDate__c = Date.today()+1, c2g__InvoiceDate__c =Date.today()+1, c2g__RegisteredDate__c =Date.today()+1  );

        User ffUser = TestingUtils.getFFUser ();

        Test.startTest();

            System.runAs(ffUser) {
                try {
                    insert purchaseInvoice;
                } catch( DmlException e ) {
                    if( e.getMessage().contains( TestingUtils.CLOSED_PERIOD_ERROR ) ) {
                        hasClosedPeriodErrors = true;
                    } else {
                        Throw new ErrorException( e.getMessage() );
                    }
                }
            }

        Test.stopTest();

        if( !hasClosedPeriodErrors ) {
            System.assert(purchaseInvoice.Id != null);
        }
    }
}