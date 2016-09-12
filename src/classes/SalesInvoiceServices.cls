public with sharing class SalesInvoiceServices {
    public static final String PAYMENT_STATUS_PART_PAID = 'Part Paid';
    public static final String PAYMENT_STATUS_UNPAID = 'Unpaid';
    public static final String PAYMENT_STATUS_PAID = 'Paid';
    
    public static final String SALES_CREDIT_NOTES_PREFIX_SCR = 'SCR';

    public static List<c2g__codaInvoice__c> getImportedInvoices(final String projectNumber) {
        if (String.isBlank(projectNumber)) {
            return new List<c2g__codaInvoice__c>();
        
        }
        return new List<c2g__codaInvoice__c>([SELECT c2g__PaymentStatus__c, c2g__OutstandingValue__c, c2g__InvoiceDate__c, Id, Project_Reference__c 
                                              FROM c2g__codaInvoice__c
                                              WHERE Project_Reference__c =: projectNumber AND (c2g__PaymentStatus__c =: PAYMENT_STATUS_PART_PAID OR c2g__PaymentStatus__c =: PAYMENT_STATUS_UNPAID)]);
    
    }
    
    public static List<c2g__codaInvoice__c> filterSalesInvoicesForTaskCreation( List<c2g__codaInvoice__c> newItems, Map<Id, c2g__codaInvoice__c> oldItemsMap ) {
        List<c2g__codaInvoice__c> filteredInvoices = new List<c2g__codaInvoice__c>();
        for( c2g__codaInvoice__c invoiceItem : newItems ) {
            c2g__codaInvoice__c oldInvoice = oldItemsMap == null ? new c2g__codaInvoice__c() : oldItemsMap.get( invoiceItem.Id );
            if( invoiceItem.Deposit_On_Account__c && ( !String.isBlank( invoiceItem.c2g__Transaction__c ) && String.isBlank( oldInvoice.c2g__Transaction__c ) ) ) {
                filteredInvoices.add( invoiceItem );
            }
        }
        return filteredInvoices;
    }

    public static List<c2g__codaInvoice__c> filterInvoicesForFieldsPopulationOnTransaction( List<c2g__codaInvoice__c> newItems ) {
        List<c2g__codaInvoice__c> filteredInvoices = new List<c2g__codaInvoice__c>();
        for( c2g__codaInvoice__c invoice : newItems ) {
            if( invoice.Populate_Transaction_Fields__c ) {
                filteredInvoices.add( invoice );
            }
        }
        return filteredInvoices;
    }

}