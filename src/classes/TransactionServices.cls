public with sharing class TransactionServices {
    public final static String INVOICE_TRANSACTION_TYPE = 'Invoice';

    public static void updateTransactionFieldsFromSalesInvoices( List<c2g__codaInvoice__c> invoices ) {
        Map<Id, c2g__codaInvoice__c> transactionIdToInvoice = new Map<Id, c2g__codaInvoice__c>();
        Map<Id, c2g__codaTransaction__c> transactionIdToTransaction = new Map<Id, c2g__codaTransaction__c>();
        for( c2g__codaInvoice__c invoice : invoices ) {
            invoice.Populate_Transaction_Fields__c = false;
            transactionIdToInvoice.put( invoice.c2g__Transaction__c, invoice );
            transactionIdToTransaction.put( invoice.c2g__Transaction__c,
                                            new c2g__codaTransaction__c( Id = invoice.c2g__Transaction__c,
                                                                         Invoice_Reference__c = invoice.Invoice_Reference__c,
                                                                         PO_Reference__c = invoice.PO_Reference__c,
                                                                         Project_Reference__c = invoice.Project_Reference__c,
                                                                         Project_Info_Reference__c = invoice.Project_Info_Reference__c,
                                                                         Client_Project_Reference__c = invoice.Client_Project_Reference__c,
                                                                         Billing_Company_Reference__c = invoice.Billing_Company_Reference__c,
                                                                         Billing_Contact_Reference__c = invoice.Billing_Contact_Reference__c,
                                                                         Accounting_Contact_Company_Reference__c = invoice.Accounting_Contact_Company_Reference__c,
                                                                         Accounting_Contact_Reference__c = invoice.Accounting_Contact_Reference__c,
                                                                         Project_Address_Reference__c = invoice.Project_Address_Reference__c ) );
        }
        transactionIdToTransaction.remove( null );
        try {
            UPDATE transactionIdToTransaction.values();
        } catch( dmlException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                transactionIdToInvoice.get( dmlEx.getDmlId(i) ).addError( 'Error Updating Transaction Reference Fields: ' + dmlEx.getDmlMessage(i) );
            }
        }
    }
    
    public static List<c2g__codaTransaction__c> getTransactionsWithImportedInvoicesByAccountId(Id accountId, String referenceNumber) {
         if (null == accountId) {
             return new List<c2g__codaTransaction__c>();
         
         }
         return new List<c2g__codaTransaction__c>([SELECT c2g__TransactionType__c, Project_Profile__c, Project_Name_Mi7__c, Id, Project_Reference__c, 
                                                             (SELECT Id, c2g__HomeOutstandingValue__c, c2g__LineType__c, c2g__MatchingStatus__c 
                                                              FROM c2g__TransactionLineItems__r
                                                              WHERE c2g__LineType__c =: 'Account' AND c2g__MatchingStatus__c =: 'Available' AND c2g__HomeOutstandingValue__c !=: 0), 
                                                             (SELECT Id, c2g__InvoiceDate__c, Billing_Company_Reference__c, Legacy_Pro_forma_Invoice__c, Project_Reference__c 
                                                              FROM c2g__Invoices__r
                                                              WHERE Billing_Company_Reference__c =: accountId AND Project_Reference__c !=: null) 
                                                      FROM c2g__codaTransaction__c
                                                      WHERE c2g__TransactionType__c =: 'Invoice' AND Project_Profile__c =: null AND Project_Name_Mi7__c =: null AND Project_Reference__c =: referenceNumber]);
    
    }

}