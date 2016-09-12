trigger ProjectProfileTrigger on Project_Profile__c (before insert, after insert, after update, before update) {

	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) { //MRS 7400
		ProjectProfileServices.setQuarterlyMonthAccordinglyToFrequency(Trigger.New);
	}

    if( Trigger.isInsert ) {
        if( Trigger.isBefore ) {
            ProjectProfileServices.setKey( trigger.new );
            ProjectProfileServices.setProjectStatus( Trigger.new ); // MRS 7062
        }

        if ( Trigger.isAfter ) {
            ProposalServices.updateProposalsWithProjectProfile( Trigger.new );
            StoredDocumentServices.createFolders(StoredDocumentServices.filterIfFoldersCreated(Trigger.newMap.keySet()));
        }
    }

    if ( Trigger.isUpdate ) {
        if( Trigger.isBefore ) {
            ProjectProfileServices.projectProfilesWithChangedProjectTeam = ProjectProfileServices.filterProjectsWithChangedProjectTeamsOrOtherLookupFields( Trigger.new, Trigger.oldMap );
            ProjectProfileServices.updateProjectTeam( ProjectProfileServices.projectProfilesWithChangedProjectTeam,
                                                      ProjectProfileServices.filterProjectsWithChangedFrep( Trigger.new, Trigger.oldMap ),
                                                      ProjectProfileServices.filterProjectsWithChangedProductionManager( Trigger.new, Trigger.oldMap ) );

            //Undo Project Billing
            Map<Id, Project_Profile__c> filterProjectsWithChangedBillingMethod = ProjectProfileServices.filterProjectsWithChangedBillingMethod( Trigger.new, Trigger.oldMap );
            ProformaInvoiceServices.undoPriorBilling( filterProjectsWithChangedBillingMethod );
            ProjectProfileServices.prepareProjectsToChangeBillingMethod( filterProjectsWithChangedBillingMethod );

            //Create/Update Billing Dates
            BillingDateServices.createBillingDateForProjects( ProjectProfileServices.filterProjectsToCreateBillingDates( Trigger.new, Trigger.oldMap ) );
			BillingDateServices.updateBillingDateFprProjectsPercentage(ProjectProfileServices.filterProjectsPercentageToChangeDateOfBillingDates(Trigger.new, Trigger.oldMap)); //MRS 7282

            ProjectProfileServices.checkIfCurrentUserCanEditFields( ProjectProfileServices.filtereProjectWithChangedFieldsValues( Trigger.new, Trigger.oldMap ), Trigger.oldMap );

            //MRS-6545, removed MRS-6625
            //ProjectProfileServices.projectWithChangedOwnerValidation( ProjectProfileServices.filteredProjectWithChangedOwner( Trigger.new, Trigger.oldMap ), Trigger.oldMap );

            //MRS-6242
            ProjectProfileServices.uncheckNoReimbursablesAfterPreBill( Trigger.new, Trigger.oldMap );

            //MRS-6683
            ProjectProfileServices.projectWhithChangedAccountingHoldList = ProjectProfileServices.filterProjectWithBillingCompanyHold( Trigger.new, Trigger.oldMap );
        }

        if( Trigger.isAfter ) {
            ProposalServices.syncProposalFields( ProjectProfileServices.projectProfilesWithChangedProjectTeam, //update Project Team field for related Proposals
                                                 ProjectProfileServices.filterProjectWithChangedName( Trigger.new, Trigger.oldMap ), //MRS-6422
                                                 ProjectProfileServices.filterProjectsWithChangedProposalCreator( Trigger.new, Trigger.oldMap ),
                                                 ProjectProfileServices.filterProjectsWithChangedClientProject( Trigger.new, Trigger.oldMap ),
                                                 Trigger.oldMap );

            //update Task Item and Service Item the OwnerId field values if Project Team has been changed
            ProjectProfileServices.updateServiceItemTaskItemOwnerChangeProjectTeam( ProjectProfileServices.projectProfilesWithChangedProjectTeam, Trigger.newMap );

            ProjectProfileServices.updateProjectRoster( ProjectProfileServices.filterProjectsWithChangedProjectOwner( Trigger.new, Trigger.oldMap ), Trigger.oldMap );

            ProjectProfileServices.createProjectRosterForChangedContact( Trigger.new, Trigger.oldMap );

            ProformaInvoiceServices.updateProformaInvoicesFormatAndSendCopyTo( ProjectProfileServices.filterProjectsWithChangedInvoiceFormat( Trigger.new, Trigger.oldMap ),
                                                                               ProjectProfileServices.filterProjectsWithChangedSendCopyTo( Trigger.new, Trigger.oldMap ) );
            //Pre-bill Projects
            ProjectProfileServices.prebillProjects( ProjectProfileServices.filterProjectsForPrebilled( Trigger.new, Trigger.oldMap ), false );//MRS-6627

            //Update unbilled BLI when accounting or billing information is changed
            BillingLineItemServices.updateBLIAfterAccountingBillingInfoChanged( ProjectProfileServices.filterProjectsWithChangedBillingAccountsContacts( Trigger.new, Trigger.oldMap ) );

            //MRS-6610 Update Pro-forma Invoices when accounting or billing information is changed
            ProformaInvoiceServices.updateChangedBillingAccountingInformation( ProjectProfileServices.filteredProjectWithChangedBillingAccountingInformation( Trigger.new, Trigger.oldMap ), Trigger.oldMap );

            //MRS-6078
            BillingLineItemServices.uncheckedIsActiveBLI( ProjectProfileServices.filteredProjectWithCheckedNoMessengerFedex( Trigger.new, Trigger.oldMap ) );

            //MRS-6683
            ProjectProfileServices.processingOnHoldAccountingNotification(ProjectProfileServices.projectWhithChangedAccountingHoldList);

            //MRS-6871
            ProjectProfileServices.updateChangeOrderIfCloseProject( ProjectProfileServices.filteredChangeClosedProject( Trigger.new, Trigger.oldMap ) );
        }
    }
}