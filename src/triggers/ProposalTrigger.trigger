trigger ProposalTrigger on Proposal__c (before insert, before update, before delete, after insert, after update) {
    if( PreventTwiceExecution.proposalFirstRun ) {
        List<Proposal__c> proposalsNotDraft = ProposalServices.filterProposalsNotDraft( Trigger.new );
        List<Proposal__c> proposalsWithChangedProposalCreator = ProposalServices.filterProposalsWithChangedProposalCreator( Trigger.new, Trigger.oldMap );
        List<Proposal__c> proposalsWithChangedOwner = ProposalServices.filterProposalsWithChangedOwner( Trigger.new, Trigger.oldMap );

        if( Trigger.isBefore ) {
            if( Trigger.isInsert || Trigger.isUpdate ) {
				ProposalServices.setQuarterlyMonthAccordinglyToFrequency(Trigger.New); //MRS 7400
                if( Trigger.isInsert ) {
                    ProposalServices.setDefaultRetainerAmountValue( ProposalServices.filterProposalsWithEmptyRetainerAmount(Trigger.new) );
                }
                ProposalServices.checkRequiredFields( proposalsNotDraft );
                ProposalServices.updateProposalVersion( ProposalServices.filterProposalsToChangeVersion( Trigger.new, Trigger.OldMap ) );
                ProposalServices.changeProposalCreatorOwnerOnProposal( proposalsWithChangedProposalCreator, proposalsWithChangedOwner );
                ProposalServices.updateRequestDate( Trigger.new, Trigger.oldMap );
                ProposalServices.updateRecordTypeForLayoutChange( ProposalServices.filterProposalsToChangeRecordType( Trigger.new, Trigger.oldMap ) );
            } else if( Trigger.isDelete && !proposalsNotDraft.isEmpty() ) {
                ProposalServices.preventDeleteProposalIfStatusAwarded( Trigger.old );
            }
            if(Trigger.isUpdate) {
                ProposalServices.updateLastStatusChange( Trigger.new, Trigger.oldMap ); //MRS 7165
            }
        }
        if( Trigger.isAfter ) {
            if( Trigger.isUpdate ){
                RosterEmailJunctionServices.deleteJunctions( ( ProposalServices.filterEmailJunctionsAfterPendingClientApproval( Trigger.new, Trigger.oldMap ) ) );
                List<Proposal__c> proposalsToVoidEnvelopes = ProposalServices.filterProposalsAfterPendingClientApprovalToVoidEnvelopes( Trigger.new, Trigger.oldMap );
                DocusignServices.voidEnvelopes( DocusignServices.getEnvelopesFromDocusignStatusesForObjects( proposalsToVoidEnvelopes ),
                                                DocusignServices.getEnvelopeVoidReasons( proposalsToVoidEnvelopes, Trigger.oldMap ) );
                List<Set<Id>> proposalsIdx = ProposalServices.filterProposalsWithChangedTaxStatus(Trigger.new, Trigger.oldMap );
                if(!proposalsIdx.get(0).isEmpty() || !proposalsIdx.get(1).isEmpty()) { // MRS 7096
                    PopulateTaxesOnBlisAndServiceItemsBatch job = new PopulateTaxesOnBlisAndServiceItemsBatch(proposalsIdx);
                    Database.executeBatch(job);
                }
				ProposalServices.sendEmailAboutContactsChanging(Trigger.new, Trigger.oldMap); //MRS 7336
                ProposalServices.changePONotesOnProject(Trigger.new, Trigger.oldMap); // MRS 7238
            }
            if( Trigger.isInsert || Trigger.isUpdate ) {
                ProposalServices.changeProposalCreatorOnProject( proposalsWithChangedProposalCreator, proposalsWithChangedOwner );
                ProjectRosterServices.updateProjectRosterWithProposalCreatorDataFromProposal( proposalsWithChangedProposalCreator, proposalsWithChangedOwner );
                ProposalServices.updateChangeHistory( ProposalServices.filterProposalsWithChangedStatus( Trigger.newMap, Trigger.OldMap ) );
            }
            if( Trigger.isUpdate && !proposalsNotDraft.isEmpty() ) {
                // Create new Project Profile
                Map<Id, Proposal__c> filteredAwardedProposals = ProposalServices.filterProposalWithStatusAwardedForProjectProfileCreation( Trigger.new, Trigger.oldMap );
                if( !filteredAwardedProposals.keySet().isEmpty() ) {
                    UserServices.prepareUserRoleNameToUserId();
                    Map<Id, Project_Profile__c> proposalIdToProjectProfile = ProjectProfileServices.createNewProjectProfile( filteredAwardedProposals );
                    ProjectProfileServices.attachServicesToProjectProfiles( filteredAwardedProposals,
                                                                            proposalIdToProjectProfile,
                                                                            null,
                                                                            ServiceItemServices.getServiceItemsMapForAttachServicesToProjectProfiles( filteredAwardedProposals.keySet(), null, null, false ),
                                                                            false );
                    Set<Id> projectIds = new Set<Id>();
                    for (Project_Profile__c project : ProjectProfileServices.idProposalToNewProjectProfiles.values() ) {
                        projectIds.add(project.Id);
                    }
                    //Insert RFIs scopes: should be here because Services are created before
                    RFIScopeServices.insertRFIScopesForProjects( projectIds );
                    EmailMessageService.sendEmailNotification( projectIds );
                }
                //ServiceItemServices.updateMunicipalAgencyOnServiceItems( ProposalServices.filterProposalsWithChangedMunicipalityId( Trigger.new, Trigger.oldMap ) );
                BillingLineItemServices.updateReimbursableBLIsForKinkingOrUnkinkingPOs( ProposalServices.filterProposalsWithChangedPONotRequiredCheckbox( Trigger.new, Trigger.OldMap ) );//MRS-7313
            }
        }
    }

    if( Trigger.isAfter ) PreventTwiceExecution.proposalFirstRun = false;
}