trigger DepositInvoiceTrigger on Deposit_Invoice__c (before insert, before update, after update) {

    if( Trigger.isBefore ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            DepositInvoiceServices.populateProposalOrProject( DepositInvoiceServices.filterDepositInvoicesForPopulateProposalOrProject( Trigger.new, Trigger.oldMap ) );
        }
        if( Trigger.isInsert ) {
            DepositInvoiceServices.populateCompanyData( DepositInvoiceServices.filterDepositInvoicesForPopulateCompanyData( Trigger.new ) );
        }
    }
    //if( Trigger.isAfter && ( Trigger.isInsert || Trigger.isUpdate ) ) DepositInvoiceServices.sendEmailsWhenRamainingLess15perOfPaid( Trigger.New, Trigger.oldMap ); //MRS 6688

}