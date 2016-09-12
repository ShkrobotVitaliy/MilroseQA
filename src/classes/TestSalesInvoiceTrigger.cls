@isTest
private class TestSalesInvoiceTrigger {

@isTest(seeAllData = true)
    private static void testInsertCodaInvoice(){
        Boolean hasClosedPeriodErrors = false;
        Account accountItem = TestingUtils.createAccountList(1, null, false)[0];

        //Account Name should be unique
        accountItem.Name = 't' + String.valueOf( System.now().millisecond() ) + 'est';

        while ( ![SELECT Id, Name FROM Account WHERE Name = : accountItem.Name].isEmpty() ){
            accountItem.Name = accountItem.Name + '1';
        }
        insert accountItem;

        c2g__codaInvoice__c codaInvoiceItem = new c2g__codaInvoice__c(c2g__Account__c = accountItem.Id);

        User ffUser = TestingUtils.getFFUser ();

        Test.startTest();
            System.runAs(ffUser) {

                try {
                    insert codaInvoiceItem;
                } catch( DmlException e ) {
                    if( e.getMessage().contains( TestingUtils.CLOSED_PERIOD_ERROR ) ) {
                        hasClosedPeriodErrors = true;
                    } else {
                        Throw new ErrorException( e.getMessage() );
                    }
                }
            }

        Test.stopTest();
    }
}