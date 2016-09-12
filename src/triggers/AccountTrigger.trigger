trigger AccountTrigger on Account (before insert, after insert, before update, after update) {

    if( trigger.isBefore ){
		AccountServices.updateAcountsRetainerAndReimbursable( Trigger.new );

		if ( Trigger.isUpdate ){
			AccountServices.filteredAccountsWithPORequiredNotCheckedAndSetPoNotRequiredCheckbox( Trigger.new, Trigger.oldMap );
		}
	}

    if( trigger.isAfter ) {
    	if ( Trigger.isUpdate ){
			ProformaInvoiceServices.updateARCoordinator( AccountServices.filteredAccountsWithChangedARCoordinator( Trigger.new, Trigger.oldMap ) );
			AccountServices.processingOnHoldAccounts( AccountServices.filteredOnHoldAccount(Trigger.new, Trigger.oldMap ) );

			List<Set<Id>> proposalsIdx = AccountServices.filterProposalsWithChangedAccountsTaxStatus(Trigger.new, Trigger.oldMap );
			if(!proposalsIdx.get(0).isEmpty() || !proposalsIdx.get(1).isEmpty()) { // MRS 7096
				PopulateTaxesOnBlisAndServiceItemsBatch job = new PopulateTaxesOnBlisAndServiceItemsBatch(proposalsIdx);
				Database.executeBatch(job);
			}

			AccountServices.validateAccountsWithAlternateARStatementRecipient( AccountServices.filterContactWithChangesActiveField( Trigger.new, Trigger.oldMap ) );//MRS-7337
		}
		if ( Trigger.isUpdate || Trigger.isInsert ){//send reminder event for MSA Account
			AccountServices.createReminderForAccountManagerMSAAccount (AccountServices.filteredAccountWithMSAEndDate( Trigger.new, Trigger.oldMap ), Trigger.oldMap);
		}
	}

}