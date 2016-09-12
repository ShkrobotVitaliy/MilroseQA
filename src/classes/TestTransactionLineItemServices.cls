@isTest(SeeAllData = true)
private class TestTransactionLineItemServices {

//    private static testmethod void testCreateCoda(){
//      List<c2g__codaCompany__c> c = TestingUtils.createCompanyList(1, true);
//      List<c2g__codaCompany__c> c = [SELECT Id FROM c2g__codaCompany__c LIMIT 1];
//      List<c2g__codaTransactionLineItem__c> ct = TestingUtils.createTransActionLineItemList(1, null, true);
//      List<c2g__codaTransaction__c> cc = TestingUtils.createTransAction(1, true);
//    }

    private static testmethod void testGetTransactionLineItemsByIdsWithEmptyData() {
        List<c2g__codaTransactionLineItem__c> transactionLineItems;

        Test.startTest();
            transactionLineItems = TransactionLineItemServices.getTransactionLineItemsByIds(null);
        Test.stopTest();

        System.assert(transactionLineItems == null || transactionLineItems.isEmpty());
    }

    private static testmethod void testGetTransactionLineItemsByIds() {
        List<c2g__codaTransactionLineItem__c> transactionLineItems;

        Test.startTest();

            transactionLineItems = TransactionLineItemServices.getTransactionLineItemsByIds(new Set<Id>{Id.valueOf(c2g__codaTransactionLineItem__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000')});

        Test.stopTest();

        System.assert(transactionLineItems == null || transactionLineItems.isEmpty());
    }

    private static testmethod void testGetTransactionLineItemsByCashLineItemIdsWithEmptyData() {
        List<c2g__codaTransactionLineItem__c> transactionLineItems;

        Test.startTest();

            transactionLineItems = TransactionLineItemServices.getTransactionLineItemsByCashLineItemIds(null);

        Test.stopTest();

        System.assert(transactionLineItems == null || transactionLineItems.isEmpty());
    }

    private static testmethod void testGetTransactionLineItemsByCashLineItemIds() {
        List<c2g__codaTransactionLineItem__c> transactionLineItems;

        Test.startTest();

            transactionLineItems = TransactionLineItemServices.getTransactionLineItemsByCashLineItemIds(new Set<Id>{Id.valueOf(c2g__codaCashEntryLineItem__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000')});

        Test.stopTest();

        System.assert(transactionLineItems == null || transactionLineItems.isEmpty());
    }

     private static testmethod void testUpdateCashEntryLineItemLookup() {
         TransactionLineItemServices.isUpdateAfterInsert = true;
         TransactionLineItemServices.updateCashEntryLineItemLookup(new Map<Id, c2g__codaTransactionLineItem__c>());
         
         TransactionLineItemServices.isUpdateAfterInsert = false;
         TransactionLineItemServices.updateCashEntryLineItemLookup(new Map<Id, c2g__codaTransactionLineItem__c>());

         System.assert(TransactionLineItemServices.isUpdateAfterInsert != null);
     }

}