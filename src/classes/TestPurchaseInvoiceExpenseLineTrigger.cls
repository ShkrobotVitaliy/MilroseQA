@isTest(seeAllData = true)
private class TestPurchaseInvoiceExpenseLineTrigger {

    private static testmethod void testInsertPurchaseInvoiceExpenseLineItem(){

        User ffUser =TestingUtils.getFFUser ();

        System.runAs(ffUser) {
            Boolean hasClosedPeriodErrors = false;
            c2g__codaGeneralLedgerAccount__c generalLedgerAccount = new c2g__codaGeneralLedgerAccount__c(c2g__Type__c = 'Balance Sheet', c2g__ReportingCode__c = '12345');
            insert generalLedgerAccount;

            Account accountItem = TestingUtils.createAccountList(1, null, false)[0];
            accountItem.c2g__CODABaseDate1__c = 'Invoice Date';
            accountItem.c2g__CODADefaultExpenseAccount__c = generalLedgerAccount.id;

            //Account Name should be unique
            accountItem.Name = 'te' + String.valueOf( System.now().millisecond() ) + 'st';

            while ( ![SELECT Id, Name FROM Account WHERE Name = : accountItem.Name].isEmpty() ){
                accountItem.Name = accountItem.Name + '1';
            }
            insert accountItem;

            c2g__codaPurchaseInvoice__c purchaseInvoice = new c2g__codaPurchaseInvoice__c(c2g__Account__c = accountItem.Id, c2g__AccountInvoiceNumber__c = '1', c2g__DueDate__c = Date.today() + 1, c2g__InvoiceDate__c =Date.today() + 1, c2g__RegisteredDate__c =Date.today() + 1);

            try {
                insert purchaseInvoice;
            } catch( DmlException e ) {
                if( e.getMessage().contains( TestingUtils.CLOSED_PERIOD_ERROR ) ) {
                    hasClosedPeriodErrors = true;
                } else {
                    Throw new ErrorException( e.getMessage() );
                }
            }

            c2g__codaPurchaseInvoiceExpenseLineItem__c purchaseInvoiceExpenseLineItem = new c2g__codaPurchaseInvoiceExpenseLineItem__c(c2g__PurchaseInvoice__c = purchaseInvoice.id, c2g__NetValue__c = 1);

            Test.startTest();

                if( !hasClosedPeriodErrors ) {
                    insert purchaseInvoiceExpenseLineItem;
                }

            Test.stopTest();

        }
    }
}