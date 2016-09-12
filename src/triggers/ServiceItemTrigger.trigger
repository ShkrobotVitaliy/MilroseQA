trigger ServiceItemTrigger on Service_Item__c ( before insert, after insert, before update, after update, after delete ) {
    if( Trigger.isBefore ) {
        ServiceItemServices.populateShortServiceNameWorktypeField( Trigger.new );
        if( Trigger.isInsert ) {
            ServiceItemServices.serviceItemTaxCode( ServiceItemServices.filterServiceItemTax( trigger.new ), false );
        }
        if( Trigger.isUpdate ) {
            ServiceItemServices.serviceItemTaxCode(ServiceItemServices.filterTaxCodeInServiceItemsWasChanged(Trigger.new, Trigger.oldMap ), false); // MRS 7096
            ServiceItemServices.checkIfCommentsFieldEditable( ServiceItemServices.filteredServiceItemWhithChangedComment( trigger.new, trigger.oldMap ) );
			ServiceItemServices.preventChangingOwnerOnCopletedServices(Trigger.New, Trigger.oldMap); //MRS 7379
        }
    }

    if( trigger.isAfter ) {
        if( Trigger.isInsert ) {
            StoredDocumentServices.createFolders( StoredDocumentServices.filterIfFoldersCreated( Trigger.newMap.keySet() ) );
        }

        if( Trigger.isUpdate ) {
            ServiceItemServices.updateMunicipalAgencyOnTaskItems( ServiceItemServices.filterServiceItemsWithChangedMunicipalAgency( trigger.new, trigger.oldMap ) );
            ServiceItemServices.updatePredecessorSuccessorTaskItem( ServiceItemServices.filterServiceItemWithChangedMilestones( trigger.new, trigger.oldMap ), trigger.oldMap );
        
            //Update BLI Decription If Municipal Agency ID is changed.
            BillingLineItemServices.updateBLIByMunicipalityIDForCreatedByClickLink(Trigger.new, Trigger.oldMap);

            //update Task Item OwnerId attached to Service Item with Other Services record Type
            if( ServiceItemServices.preventorUpdateServiceItemOwner ) {
				ServiceItemServices.taskItemOwnerUpdatedFromServiceItemTrigger = true; //MRS 7379
                ServiceItemServices.updateTaskItemOwner(ServiceItemServices.filteredServiceItemWithChangedOwner( trigger.new, trigger.oldMap ), trigger.oldMap );
            }

            //MRS-6851
            if ( ServiceItemServices.preventorUpdateServiceItemOwner && ProjectProfileServices.preventToUpdateProjectAssignment ){
                ProjectProfileServices.populateUsersFieldOnProject(null, ServiceItemServices.filteredServiceItemForChangeUserFieldsOnProject(Trigger.new, Trigger.oldMap), null);
            }

            //MRS-6083 Link existing BLI to PO after services have been linked to PO (Milestone only) 
            BillingLineItemServices.linkExistingBLIToNewPurchaseOrders(PurchaseOrderServices.filterPOsWithLinkedServices( trigger.new, trigger.oldMap ));

            //MRS-6414
            ProjectProfileServices.updateProjectStage(ServiceItemServices.filteredComplatedServices(trigger.new, trigger.oldMap), trigger.new, null);
        }

		if(Trigger.isInsert || Trigger.isUpdate) { //MRS 7499
			ServiceItemServices.sendEmailToSipsIfConstructionServiceApproved(ServiceItemServices.filteredSiToSendEmailsToSips(Trigger.new, Trigger.oldMap));
		}

        if( Trigger.isDelete ){
            ProposalServices.updateBaseServicesTotal( ServiceItemServices.filterProposalsWithOriginalServices( Trigger.old, null ) );    
        } else {
            ProposalServices.updateBaseServicesTotal( ServiceItemServices.filterProposalsWithOriginalServices( Trigger.new, Trigger.oldMap ) );
        }
        if( Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete ) {
            ProposalServices.updateReceivedPO(ServiceItemServices.filterProposalsToUpdateReceivedPO(Trigger.new, Trigger.oldMap), Trigger.new);//MRS-6595
            ChangeOrderServices.updateReceivedPO(ServiceItemServices.filterCOToUpdateReceivedPO(Trigger.new, Trigger.oldMap), Trigger.new);//MRS-6595
            PurchaseOrderServices.updatePurchaseOrdersData(ServiceItemServices.filteredIdxOfPOsToUpdate(Trigger.newMap, Trigger.oldMap));//MRS-6939
        }
    }

}