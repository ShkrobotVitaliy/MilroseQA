trigger ChangeOrderTrigger on Change_Order__c ( before insert, after insert, before update, after update, after delete ) {
    if( PreventTwiceExecution.changeOrderFirstRun ) {
        Map<Id, Change_Order__c> filteredChangeOrders = new Map<Id, Change_Order__c>();

        if( !(Trigger.isBefore && Trigger.isInsert ) ) {
            filteredChangeOrders = ChangeOrderServices.filterApprovedChangeOrders( Trigger.new, Trigger.oldMap );
        }

        if( Trigger.isBefore ) {
            if( Trigger.isInsert || Trigger.isUpdate ) {
                ChangeOrderServices.updateChangeOrderNumber( ChangeOrderServices.filterChangeOrdersWithoutNumbers( Trigger.new ) );
            }
            if( Trigger.isUpdate ) {
				ChangeOrderServices.preventChangingStatusManually(Trigger.newMap, Trigger.oldMap); //MRS 7462
                ChangeOrderServices.createBliOrTaskForApprovedChangeOrders( filteredChangeOrders );
                ChangeOrderServices.populateChangeOrderSentDateField( ChangeOrderServices.filterPendingClientApprovalCO( Trigger.new, Trigger.oldMap ) );
            }
        }

        if( Trigger.isAfter ){
            if( Trigger.isUpdate ) {
                ProposalServices.cleanUpCZAnalystData( ChangeOrderServices.filterChangeOrdersInCZScopingReview( Trigger.newMap, Trigger.oldMap ) );
                RosterEmailJunctionServices.deleteJunctions( ( ChangeOrderServices.filterEmailJunctionsAfterPendingClientApproval( Trigger.new, Trigger.oldMap ) ) );

                List<Change_Order__c> changeOrdersToVoidEnvelopes = ChangeOrderServices.filterChangeOrdersAfterPendingClientApprovalToVoidEnvelopes( Trigger.new, Trigger.oldMap );
                DocusignServices.voidEnvelopes( DocusignServices.getEnvelopesFromDocusignStatusesForObjects( changeOrdersToVoidEnvelopes ),
                                                DocusignServices.getEnvelopeVoidReasons( changeOrdersToVoidEnvelopes, Trigger.oldMap ) );
                ServiceItemServices.populatePOReceivedFields(Trigger.new, Trigger.OldMap); // MRS 7074
				ChangeOrderServices.deleteTaskItemsWhenCoUnapprowed(Trigger.newMap, Trigger.oldMap); //MRS 7462
            }

            if( Trigger.isInsert || Trigger.isUpdate ) {
                ProposalServices.updateProposalVersion( ChangeOrderServices.filterChangeOrdersForVersionChange( Trigger.new, Trigger.oldMap ) );
            }

        	if( !filteredChangeOrders.isEmpty() ) {
        		//ChangeOrderServices.updateChangeOrderNumbers( filteredChangeOrders );
        		if( Trigger.isUpdate ) {
    	        	UserServices.prepareUserRoleNameToUserId();
                    Map<Id, Proposal__c> proposalsFromChangeOrders = ChangeOrderServices.getProposalsFromChangeOrders( filteredChangeOrders.values() );
                    Map<Id, Service_Item__c> affectedServiceItems = ServiceItemServices.getServiceItemsMapForAttachServicesToProjectProfiles( proposalsFromChangeOrders.keySet(), filteredChangeOrders.keySet(), null, true );
                    ProjectProfileServices.attachServicesToProjectProfiles( proposalsFromChangeOrders, null, filteredChangeOrders, affectedServiceItems, true );//MRS-7473
                    RFIScopeServices.createRFIForChangeOrder( affectedServiceItems.keySet() );
                    EmailMessageService.sendEmailNotificationChangeOrder(filteredChangeOrders.values(), proposalsFromChangeOrders); //MRS-6618
                    ProjectProfileServices.updateProjectStatus(filteredChangeOrders); // MRS 7062
        		}
            }
            if ( Trigger.isUpdate ) ChangeOrderServices.updateProjectCompletedProjectState( ChangeOrderServices.filterChangeOrdersChangesFromDraftToRequested( Trigger.new, Trigger.oldMap ) );

            //MRS-6414
            if( Trigger.isAfter && Trigger.isUpdate ) {
                ProjectProfileServices.updateProjectStage(ChangeOrderServices.filteredComplatedApprovedChangeOrders(trigger.new, trigger.oldMap), null, trigger.new);
            }

        }
    }
    if( Trigger.isAfter ) PreventTwiceExecution.changeOrderFirstRun = false;
}