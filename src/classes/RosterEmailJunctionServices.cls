public with sharing class RosterEmailJunctionServices {
    private static final String TO_KEYWORD = 'TO';
    private static final String CC_KEYWORD = 'CC';
    private static final String TRACKING_CONTACT_ID_KEYWORD = 'TRCONT';
    private static final String ROSTER_JUNCTION = 'Roster Email Junction'; //G300 MRS-6807
    private static final String SENDER_ID_KEYWORD = 'SENDID';
    private static final String CO_TYPE_KEYWORD = 'COTYPE';
    private static final String ADD_RETAINER_KEYWORD = 'ADDRET';
    private static final String CHANGE_ORDER = 'Change Order';
    private static final String PROPOSAL = 'Proposal';
    private static final String RETAINER = 'Retainer';
    private static final List<String> rolePriorityForEmail = new List<String>{ ProjectRosterServices.PRIMARY_CLIENT_CONTACT,
                                                                               ProjectRosterServices.BILLING_CLIENT_CONTACT,
                                                                               ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT };

    public static Map<String, Integer> getRolePriorityForEmail() {
        Map<String, Integer> rolePriority = new Map<String, Integer>();
        Integer priority = 1;
        for( String role : rolePriorityForEmail ) {
            rolePriority.put( role, priority++ );
        }
        return rolePriority;
    }

    public static Id getTrackingContactId( List<Roster_Email_Junction_Data__c> junctionDatas ) {
        Map<String, Integer> rolePriority = getRolePriorityForEmail();
        Integer trackingLevel;
        Id trackingContactId;
        Id alternativeTrackingContactId;
        for( Roster_Email_Junction_Data__c junctionData : junctionDatas ) {
            Integer junctionTrackingLevel = rolePriority.get( junctionData.Project_Roster__r.Role__c );
            if( !String.isEmpty( junctionData.Project_Roster__r.Contact__c ) &&
                 junctionData.Project_Roster__r.User_Contact_IsActive__c &&
                 junctionData.is_TO__c &&
                !String.isBlank( junctionData.Project_Roster__r.Email__c ) ) {
                if( /*junctionData.Project_Roster__r.Initially_Added_Roster__c &&*/ junctionTrackingLevel != null ) {
                    if( trackingLevel == null || junctionTrackingLevel < trackingLevel ) {
                        trackingLevel = junctionTrackingLevel;
                        trackingContactId = junctionData.Project_Roster__r.Contact__c;
                    }
                } else {
                    if( alternativeTrackingContactId == null ) {
                        alternativeTrackingContactId = junctionData.Project_Roster__r.Contact__c;
                    }
                }
                if( trackingLevel == 1 ) break;
            }
        }
        return trackingContactId != null ? trackingContactId : alternativeTrackingContactId;
    }

    public static Map<Id, Roster_Email_Junction__c> filterJunctionsToSendEmail( List<Roster_Email_Junction__c> newJunctionsList, Map<Id, Roster_Email_Junction__c> oldJunctionsMap){
        Set<Id> filteredJunctionIds = new Set<Id>();
        Map<Id, Roster_Email_Junction__c> automaticFollowupJunctionIdToJunction = new Map<Id, Roster_Email_Junction__c>();

        for( Roster_Email_Junction__c junction : newJunctionsList ) {
            if( junction.Send_Email__c && !oldJunctionsMap.get( junction.Id ).Send_Email__c ) {
                junction.is_Completed__c = true;
                filteredJunctionIds.add( junction.Id );
                if( junction.Is_Automatic_Follow_Up__c ) {
                    automaticFollowupJunctionIdToJunction.put( junction.Id, junction );
                }
            }
        }

        Map<Id, Roster_Email_Junction__c> junctionsFromDb; //re-select junctions to get related lists
        junctionsFromDb = new Map<Id, Roster_Email_Junction__c> ( [ SELECT /*is_Completed__c,*/ Proposal__c, Proposal__r.Proposal_Type__c, Proposal__r.RFP_Attachments__c,
                                                                           Proposal__r.Additional_Documents__c, Proposal__r.Project_Name__c, Proposal__r.Project_Profile__c,
                                                                           Proposal__r.Project_Profile__r.Name, Proposal__r.Address_Building_AKA__c, Proposal__r.Floor_s__c,
                                                                           Proposal__r.Billing_Company_Contact__r.Name, Proposal__r.is_Change_Order__c, Change_Order__c,
                                                                           Change_Order__r.Number__c, Reminder_Date_Time__c, Is_Automatic_Follow_Up__c, Document_Type__c,
                                                                           Change_Order__r.Document_Type__c, Sender__c, Proposal__r.DDP_Include_Retainer_Invoice__c,
                                                                           Change_Order__r.DDP_Include_Retainer_Invoice__c, Proposal__r.UseDocusign__c, Change_Order__r.UseDocusign__c,
                                                                           Proposal__r.Billing_Company_Name__r.Accounting_Hold__c, Proposal__r.Project_Profile__r.Project_State__c,
                                                                           ( SELECT Project_Roster__c, is_TO__c, is_CC__c, Roster_Email_Junction__c,
                                                                                    Project_Roster__r.Email__c, Project_Roster__r.Contact__c, Project_Roster__r.Name__c,
                                                                                    Project_Roster__r.User_Contact_IsActive__c, Project_Roster__r.Role__c,
                                                                                    Project_Roster__r.Initially_Added_Roster__c
                                                                             FROM Roster_Email_Junction_Data__r ),
                                                                           ( SELECT Stored_Document__c
                                                                               FROM Roster_StoredDocument_Junctions__r )
                                                                    FROM Roster_Email_Junction__c
                                                                    WHERE Id IN : filteredJunctionIds ] );

        Map<Id, Roster_Email_Junction__c> junctionFromDbIdToJunctionClone = new Map<Id, Roster_Email_Junction__c>();
        Map<Id, List<Roster_Email_Junction_Data__c>> junctionFromDbIdToJunctionDataClones = new Map<Id, List<Roster_Email_Junction_Data__c>>();

        List<Roster_StoredDocument_Junction__c> rosterSDocsToInsert = new List<Roster_StoredDocument_Junction__c>(); //G-300 MRS-6807


        for( Id followupJunctionId : automaticFollowupJunctionIdToJunction.keyset() ) {
            Roster_Email_Junction__c junction = junctionsFromDB.get( followupJunctionId );

            junctionFromDbIdToJunctionClone.put( followupJunctionId, createNewFollowUpRosterEmailJunction( junction ) );

            for( Roster_Email_Junction_Data__c junctionData : junction.Roster_Email_Junction_Data__r ) {
                if( !junctionFromDbIdToJunctionDataClones.containsKey( followupJunctionId ) ) {
                    junctionFromDbIdToJunctionDataClones.put( followupJunctionId, new List<Roster_Email_Junction_Data__c>() );
                }
                junctionFromDbIdToJunctionDataClones.get( followupJunctionId ).add( createNewFollowUpRosterEmailJunctionData( junctionData ) );
            }
        }

        try {
            INSERT junctionFromDbIdToJunctionClone.values();
            for( Id activeJunctionId : junctionFromDbIdToJunctionClone.keySet() ) { //set a link to next junction on an active one
                automaticFollowupJunctionIdToJunction.get( activeJunctionId ).Next_Trigger__c = junctionFromDbIdToJunctionClone.get( activeJunctionId ).Id;
            }
            List<Roster_Email_Junction_Data__c> junctionDataClones = new List<Roster_Email_Junction_Data__c>();
            for( Id junctionFromDbId : junctionFromDbIdToJunctionDataClones.keySet() ) {
                for( Roster_Email_Junction_Data__c junctionDataClone : junctionFromDbIdToJunctionDataClones.get( junctionFromDbId ) ) {
                    junctionDataClone.Roster_Email_Junction__c = junctionFromDbIdToJunctionClone.get( junctionFromDbId ).Id;
                    junctionDataClones.add( junctionDataClone );
                }
            }
            INSERT junctionDataClones;
            for(Id juncID : junctionFromDbIdToJunctionClone.keySet()) { //G300 MRS-6807
                Roster_Email_Junction__c newJunction = junctionFromDbIdToJunctionClone.get(juncID);
                for( Roster_StoredDocument_Junction__c tRSDJunc : junctionsFromDB.get(juncID).Roster_StoredDocument_Junctions__r ) {
                    rosterSDocsToInsert.add(new Roster_StoredDocument_Junction__c( Stored_Document__c = tRSDJunc.Stored_Document__c,
                                                                                   Roster_Email_Junction__c = newJunction.id));
                }
            }
            INSERT rosterSDocsToInsert;
        } catch( Exception e ) {
            System.debug( LoggingLevel.Error, e.getMessage() );
        }

        //don't work with junctions that have project on hold
	Map<Id, Roster_Email_Junction__c> junctionsFromDbWithoutAccountOnHold = new Map<Id, Roster_Email_Junction__c>();
	for( Roster_Email_Junction__c item: junctionsFromDb.values() ){
		if( !item.Proposal__r.Billing_Company_Name__r.Accounting_Hold__c &&
			!( item.Proposal__r.Project_Profile__r.Project_State__c == ProjectProfileServices.PROJECT_STATE_ON_HOLD ) ) junctionsFromDbWithoutAccountOnHold.put(item.Id, item);
	}

        return junctionsFromDbWithoutAccountOnHold;
    }

    public static Roster_Email_Junction__c createNewFollowUpRosterEmailJunction( Roster_Email_Junction__c junction ) {
        return new Roster_Email_Junction__c( Sender__c = junction.Sender__c,
                                             Proposal__c = junction.Proposal__c,
                                             Change_Order__c = junction.Change_Order__c,
                                             Reminder_Date_Time__c = BusinessHours.add( DateUtils.MILROSE_BUSINESS_HOURS_ID, junction.Reminder_Date_Time__c, 5 * DateUtils.ONE_DAY ),
                                             Is_Automatic_Follow_Up__c = true,
                                             Prev_Trigger__c = junction.Id, //set a link to active (old) junction for new one
                                             Document_Type__c = junction.Document_Type__c != null
                                                                ? junction.Document_Type__c
                                                                : ChangeOrderServices.CO_DOCUMENT_TYPE_FULL );
    }

    public static Roster_Email_Junction_Data__c createNewFollowUpRosterEmailJunctionData( Roster_Email_Junction_Data__c junction ) {
        return new Roster_Email_Junction_Data__c( Project_Roster__c = junction.Project_Roster__c,
                                                  is_TO__c = junction.is_TO__c,
                                                  is_CC__c = junction.is_CC__c );
    }

    public static void addJunctionDataToMap( Roster_Email_Junction__c junction, Roster_Email_Junction_Data__c junctionData, Id trackingContactId,
                                                                           Id senderId, Map<Id, Map<DateTime, Map<String, Set<String>>>> dataMap) {
        Id proposalOrCOId = String.isEmpty(junction.Change_Order__c) ? junction.Proposal__c : junction.Change_Order__c;

        if( !dataMap.containsKey(proposalOrCOId) ) {
            dataMap.put( proposalOrCOId, new Map<DateTime, Map<String, Set<String>>>() );
        }
        if( !dataMap.get(proposalOrCOId).containsKey( junction.Reminder_Date_Time__c ) ) {
            dataMap.get(proposalOrCOId).put( junction.Reminder_Date_Time__c, new Map<String, Set<String>>{ TO_KEYWORD => new Set<String>(),
                                                                                                           CC_KEYWORD => new Set<String>(),
                                                                                                           TRACKING_CONTACT_ID_KEYWORD => new Set<String>(),
                                                                                                           SENDER_ID_KEYWORD => new Set<String>(),
                                                                                                           CO_TYPE_KEYWORD => new Set<String>(),
                                                                                                           ADD_RETAINER_KEYWORD => new Set<String>(),
                                                                                                           ROSTER_JUNCTION => new Set<String>() } ); //G300 MRS-6807
        }

        Map<String, Set<String>> configMap = dataMap.get( proposalOrCOId ).get( junction.Reminder_Date_Time__c );
        if( !String.isBlank( junctionData.Project_Roster__r.Email__c ) ) {
            if( junctionData.is_TO__c ) {
                if( configMap.get( TRACKING_CONTACT_ID_KEYWORD ).isEmpty() &&
                    trackingContactId != null &&
                    /*!String.isEmpty( junctionData.Project_Roster__r.Contact__c ) &&*/
                    junctionData.Project_Roster__r.Contact__c == trackingContactId ) {
                    configMap.get( TRACKING_CONTACT_ID_KEYWORD ).add( String.valueOf( trackingContactId ) );
                } else {
                    configMap.get( TO_KEYWORD ).add( junctionData.Project_Roster__r.Email__c );
                }
            }
            if( junctionData.is_CC__c ) {
                configMap.get( CC_KEYWORD ).add( junctionData.Project_Roster__r.Email__c );
            }
        }

        if(configMap.get(ROSTER_JUNCTION).isEmpty()) { //G300 MRS-6807
            configMap.get( ROSTER_JUNCTION ).add(junction.id);
        }

        if( configMap.get( SENDER_ID_KEYWORD ).isEmpty() ) {
            configMap.get( SENDER_ID_KEYWORD ).add( senderId );
        }
        if( configMap.get( CO_TYPE_KEYWORD ).isEmpty() ) {
            configMap.get( CO_TYPE_KEYWORD ).add( junction.Document_Type__c != null
                                                  ? junction.Document_Type__c
                                                  : ChangeOrderServices.CO_DOCUMENT_TYPE_FULL );
        }
        if( configMap.get( ADD_RETAINER_KEYWORD ).isEmpty() &&
            ( (  String.isBlank( junction.Change_Order__c ) && junction.Proposal__r.DDP_Include_Retainer_Invoice__c == true ) ||
              ( !String.isBlank( junction.Change_Order__c ) && junction.Change_Order__r.DDP_Include_Retainer_Invoice__c == true ) ) ) {
            configMap.get( ADD_RETAINER_KEYWORD ).add( 'true' );
        }
        dataMap.get( proposalOrCOId ).put( junction.Reminder_Date_Time__c, configMap );
    }

    public static void sendEmailsToRecipients( Map<Id, Roster_Email_Junction__c> rosterEmailJunctions ) {
        if( rosterEmailJunctions == null || rosterEmailJunctions.isEmpty() ) return;

        List<Roster_Email_Junction__c> regularRosterEmailJunctions = new List<Roster_Email_Junction__c>();
        List<Roster_Email_Junction__c> docusignRosterEmailJunctions = new List<Roster_Email_Junction__c>();
        for( Id junctionId : rosterEmailJunctions.keySet() ) {
            Roster_Email_Junction__c junction = rosterEmailJunctions.get( junctionId );
            if( ( junction.Change_Order__c == null && junction.Proposal__r.UseDocusign__c ) ||
                ( junction.Change_Order__c != null && junction.Change_Order__r.UseDocusign__c ) ) {
                docusignRosterEmailJunctions.add( junction );
            } else {
                regularRosterEmailJunctions.add( junction );
            }
        }

        if( !docusignRosterEmailJunctions.isEmpty() ) {
            List<sObject> docusignEntities = new List<sObject>();
            for( Roster_Email_Junction__c junction : docusignRosterEmailJunctions ) {
                if( String.isBlank( junction.Change_Order__c ) ) {
                    docusignEntities.add( new Proposal__c( Id = junction.Proposal__c ) );
                } else {
                    docusignEntities.add( new Change_Order__c( Id = junction.Change_Order__c ) );
                }
            }
            DocusignServices.resendEnvelopes( DocusignServices.getEnvelopesFromDocusignStatusesForObjects( docusignEntities ).keySet() );
        }

        if( !regularRosterEmailJunctions.isEmpty() ) {
            /* proposalRelatedJunctions/changeOrderRelatedJunctions = Map<ProposalId/COId, Map<DateTime, Map<'TO/CC', Set<Email>>>> */
            Map<Id, Map<DateTime, Map<String, Set<String>>>> proposalRelatedJunctions = new Map<Id, Map<DateTime, Map<String, Set<String>>>>();
            Map<Id, Map<DateTime, Map<String, Set<String>>>> changeOrderRelatedJunctions = new Map<Id, Map<DateTime, Map<String, Set<String>>>>();

            Set<String> rfpDocumentsId = new Set<String>();
            Map<Id, Proposal__c> proposalsMap = new Map<Id, Proposal__c>();
            Map<Id, Change_Order__c> changeOrdersMap = new Map<Id, Change_Order__c>();

            Map<Id, List<LStore__Stored_Document__c>> additionalDocIdToDoc = new Map<Id, List<LStore__Stored_Document__c>>(); //G300 MRS-6807

            for( Roster_Email_Junction__c junction : rosterEmailJunctions.values() ) {

                additionalDocIdToDoc.put(junction.id, StoredDocumentServices.getDocumentsFromRosterSDocJunctions(junction)); //G300 MRS-6807

                if( junction.Proposal__r.Proposal_Type__c == ProposalServices.PROPOSAL_TYPE_RFP && !String.isEmpty( junction.Proposal__r.RFP_Attachments__c ) ) {
                    rfpDocumentsId.addAll( junction.Proposal__r.RFP_Attachments__c.split( ProposalServices.PROPOSAL_RFP_ATTACHMENTS_DELIMITER ) );
                }
                proposalsMap.put( junction.Proposal__c, new Proposal__c( Id = junction.Proposal__c,
                                                                         Proposal_Type__c = junction.Proposal__r.Proposal_Type__c,
                                                                         RFP_Attachments__c = junction.Proposal__r.RFP_Attachments__c,
                                                                         Additional_Documents__c = junction.Proposal__r.Additional_Documents__c,
                                                                         is_Change_Order__c = junction.Proposal__r.is_Change_Order__c ) );

                Id senderId = String.isBlank( junction.Sender__c ) ? UserInfo.getUserId() : junction.Sender__c;
                Id trackingContactId = getTrackingContactId( junction.Roster_Email_Junction_Data__r );


                for( Roster_Email_Junction_Data__c junctionData : junction.Roster_Email_Junction_Data__r ) {
                    if( junctionData.Project_Roster__r.User_Contact_IsActive__c ) {
                        if( String.isEmpty( junction.Change_Order__c ) ) {
                            addJunctionDataToMap( junction, junctionData, trackingContactId, senderId, proposalRelatedJunctions);

                        } else {
                            addJunctionDataToMap( junction, junctionData, trackingContactId, senderId, changeOrderRelatedJunctions);
                            if( !changeOrdersMap.containsKey( junction.Change_Order__c ) ) {
                                changeOrdersMap.put( junction.Change_Order__c, new Change_Order__c( Id = junction.Change_Order__c, Proposal__c = junction.Proposal__c, Number__c = junction.Change_Order__r.Number__c, Document_Type__c = junction.Change_Order__r.Document_Type__c ) );
                            }
                        }

                    }
                }
            }



            List<Document> documentList = [SELECT Id, Name, Description, Type FROM Document WHERE Folder.Name =: StoredDocumentServices.RFP_ARTIFACTS_FOLDER AND Id IN: rfpDocumentsId];
            Map<Id, List<LStore__Stored_Document__c>> proposalIdToDocumentFolderMap = StoredDocumentServices.getDocumentFoldersForProposals( proposalsMap.keySet() );

            if( !proposalRelatedJunctions.keySet().isEmpty() ) {
                Set<String> proposalIds = new Set<String>();
                for( Id proposalId : proposalRelatedJunctions.keySet() ) {
                    proposalIds.add( proposalId );
                }
                EmailTemplate sourceTemplate = EmailMessageService.getEmailTemplateByDeveloperName( EmailMessageService.EMAIL_TEMPLATE_DRAFT_PROPOSAL_FOLLOWUP );
                Map<Id, Proposal__c> proposalsForMerge = ProposalWizardServices.getProposalMergeFieldsById( proposalIds );
                Map<Id, MergeEmailTemplate> proposalIdToEmailTemplate = new Map<Id, MergeEmailTemplate>();

                for( Id proposalId : proposalRelatedJunctions.keySet() ) {
                    proposalIds.add( proposalId );
                    proposalIdToEmailTemplate.put( proposalId, proposalsForMerge.get( proposalId ) != null
                                                               ? new MergeEmailTemplate( sourceTemplate, proposalsForMerge.get( proposalId ), true )
                                                               : new MergeEmailTemplate( sourceTemplate ) );
                }
                sendEmailsForDataConfiguration( proposalRelatedJunctions,
                                                documentList,
                                                proposalsMap,
                                                changeOrdersMap,
                                                proposalIdToDocumentFolderMap,
                                                additionalDocIdToDoc, //G300 MRS-6807
                                                proposalIdToEmailTemplate );
            }
            if( !changeOrderRelatedJunctions.keySet().isEmpty() ) {
                Set<String> changeOrderIds = new Set<String>();
                for( Id changeOrderId : changeOrderRelatedJunctions.keySet() ) {
                    changeOrderIds.add( changeOrderId );
                }
                EmailTemplate sourceTemplate = EmailMessageService.getEmailTemplateByDeveloperName( EmailMessageService.EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER_FOLLOWUP );
                Map<Id, Change_Order__c> changeOrdersForMerge = ProposalWizardServices.getChangeOrderMergeFieldsById( changeOrderIds );
                Map<Id, MergeEmailTemplate> changeOrderIdToEmailTemplate = new Map<Id, MergeEmailTemplate>();
                for( Id changeOrderId : changeOrderRelatedJunctions.keySet() ) {
                    changeOrderIdToEmailTemplate.put( changeOrderId, changeOrdersForMerge.get( changeOrderId ) != null
                                                                     ? new MergeEmailTemplate( sourceTemplate, changeOrdersForMerge.get( changeOrderId ), true )
                                                                     : new MergeEmailTemplate( sourceTemplate ) );
                }
                sendEmailsForDataConfiguration( changeOrderRelatedJunctions,
                                                documentList,
                                                proposalsMap,
                                                changeOrdersMap,
                                                proposalIdToDocumentFolderMap,
                                                additionalDocIdToDoc, //G300 MRS-6807
                                                changeOrderIdToEmailTemplate );
            }
        }
    }

    public static void sendEmailsForDataConfiguration( Map<Id, Map<DateTime, Map<String, Set<String>>>> dataConfiguration,
                                                       List<Document> documentList, Map<Id, Proposal__c> proposalsMap,
                                                       Map<Id, Change_Order__c> changeOrdersMap,
                                                       Map<Id, List<LStore__Stored_Document__c>> proposalIdToDocumentFolderMap,
                                                       Map<Id, List<LStore__Stored_Document__c>> proposalAdditionalOffLimitDocuments, //G300 MRS-6807
                                                       Map<Id, MergeEmailTemplate> targetEmailTemplates ) {
        Map<String, String> listOfAdditionalFiles = new Map<String, String>(); //G300 MRS-6807
        for( Id proposalOrCOId: dataConfiguration.keySet()) {
            Boolean isProposalConfiguration = !changeOrdersMap.containsKey( proposalOrCOId );

            for( DateTime reminderDate : dataConfiguration.get( proposalOrCOId ).keySet() ) {

                String documentLinkForEmail; //MRS-7061
                Map<String, Set<String>> configMap = dataConfiguration.get( proposalOrCOId ).get( reminderDate );
                Id senderId = !configMap.get( SENDER_ID_KEYWORD ).isEmpty() ? ( new List<String>( configMap.get( SENDER_ID_KEYWORD ) ) )[0] : null;
                //Collect recipients
                Id trackingContactId = !configMap.get( TRACKING_CONTACT_ID_KEYWORD ).isEmpty() ? ( new List<String>( configMap.get( TRACKING_CONTACT_ID_KEYWORD ) ) )[0] : null;
                List<String> toRecipients = new List<String>( configMap.get( TO_KEYWORD ) );
                List<String> ccRecipients = new List<String>( configMap.get( CC_KEYWORD ) );
                if( toRecipients.isEmpty() && String.isBlank( trackingContactId ) ) {
                    if( ccRecipients.isEmpty() ) {
                        continue;
                    } else {
                        toRecipients.add( ccRecipients[0] );
                    }
                }

                List<Id> documentsId = new List<Id>();
                //Collect document Ids for attachements
                //commented out since with new attachment logic it will attach these files from LStore__Stored_Document__c as links
                /*if( isProposalConfiguration && proposalsMap.get( proposalOrCOId ).Proposal_Type__c == ProposalServices.PROPOSAL_TYPE_RFP && !String.isEmpty( proposalsMap.get( proposalOrCOId ).RFP_Attachments__c ) ) {
                    for( Document doc : documentList ) {
                        if( proposalsMap.get( proposalOrCOId ).RFP_Attachments__c.contains( doc.Id ) ) {
                            documentsId.add( doc.Id );
                        }
                    }
                }*/

                //Prepare attachemt document links
                //NOTE: we can not attach LStore__Stored_Document__c in SingleEmailMessage all such files will be presented like external links in email body
                Id proposalId = isProposalConfiguration ? proposalOrCOId : changeOrdersMap.get( proposalOrCOId ).Proposal__c;
                String coType = !configMap.get( CO_TYPE_KEYWORD ).isEmpty()
                                ? ( new List<String>( configMap.get( CO_TYPE_KEYWORD ) ) )[0]
                                : ChangeOrderServices.CO_DOCUMENT_TYPE_FULL;
                Boolean addRetainer = !configMap.get( ADD_RETAINER_KEYWORD ).isEmpty();
                Map<String, String> externalUrlToDocumentNameMap = new Map<String, String>();
                if( proposalIdToDocumentFolderMap.containsKey( proposalId ) ) {
                    for( LStore__Stored_Document__c folder : proposalIdToDocumentFolderMap.get( proposalId ) ) {
                        LStore__Stored_Document__c proposalDocument = new LStore__Stored_Document__c();
                        LStore__Stored_Document__c retainerDocument = new LStore__Stored_Document__c();
                        LStore__Stored_Document__c changeOrderDocument = new LStore__Stored_Document__c();
                        Map<String, LStore__Stored_Document__c> documentNameToDocument = new Map<String, LStore__Stored_Document__c>();

                        String versionNumber = '';
                        for( Change_History_Proposal__c changeHistory : [ SELECT Version_Text__c
                                                                          FROM Change_History_Proposal__c
                                                                          WHERE Proposal__c = : proposalOrCOId
                                                                             OR Change_Order__c = : proposalOrCOId
                                                                          ORDER BY Version_Text__c DESC NULLS LAST
                                                                          LIMIT 1 ] ) {
                            versionNumber = changeHistory.Version_Text__c;
                        }

                        for( LStore__Stored_Document__c document : folder.LStore__Stored_Documents__r ) {

                            if( document.LStore__File_Name__c.contains( 'v.' + versionNumber ) ) { //do not add docs that don't have an actual version number
                                //this is change order doc package
                                if( !isProposalConfiguration && document.LStore__File_Name__c.contains( CHANGE_ORDER ) && !document.LStore__File_Name__c.contains( PROPOSAL ) ) {
                                    String requiredDocumentNamePart = CHANGE_ORDER + '#' + String.valueOf( changeOrdersMap.get(proposalOrCOId).Number__c )/* + '.pdf'*/;
                                    if( document.LStore__File_Name__c.contains( requiredDocumentNamePart ) && document.LStore__File_Name__c.endsWith('.pdf') ) {
                                        //this is change order doc
                                        if( ( changeOrderDocument.Id == null || document.CreatedDate > changeOrderDocument.CreatedDate ) &&
                                            !document.LStore__File_Name__c.contains( RETAINER ) &&
                                            ( document.LStore__File_Name__c.endsWith( requiredDocumentNamePart + '.pdf' ) || document.LStore__File_Name__c.endsWith( requiredDocumentNamePart + ' - Change Order' + '.pdf' ) ) &&
                                            ( ( coType == ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT && document.Is_Light_Change_Order__c ) ||
                                              ( coType != ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT && !document.Is_Light_Change_Order__c ) ) ) {
                                            changeOrderDocument = document;
                                        }
                                        //this is retainer doc
                                        if( addRetainer && ( retainerDocument.Id == null || document.CreatedDate > retainerDocument.CreatedDate ) && document.LStore__File_Name__c.contains( RETAINER ) ) {
                                            retainerDocument = document;
                                        }
                                        //this is an additional doc
                                        if( document.LStore__File_Name__c.contains( requiredDocumentNamePart ) && !document.LStore__File_Name__c.endsWith( requiredDocumentNamePart + ' - Change Order' + '.pdf' ) ) {
                                            if( !documentNameToDocument.containsKey( document.LStore__File_Name__c ) || document.CreatedDate > documentNameToDocument.get( document.LStore__File_Name__c ).CreatedDate ) {
                                                documentNameToDocument.put( document.LStore__File_Name__c, document );
                                            }
                                        }
                                    }

                                //this is proposal doc package
                                } else if( isProposalConfiguration && !document.LStore__File_Name__c.contains( CHANGE_ORDER ) && document.LStore__File_Name__c.contains( PROPOSAL ) ) {
                                    //this is proposal doc
                                    if( ( proposalDocument.Id == null || document.CreatedDate > proposalDocument.CreatedDate ) &&
                                        !document.LStore__File_Name__c.contains( RETAINER ) &&
                                        ( document.LStore__File_Name__c.endsWith( PROPOSAL + '.pdf' ) || document.LStore__File_Name__c.endsWith( PROPOSAL + ' - Proposal' + '.pdf' ) ) ) {
                                        proposalDocument = document;
                                    }
                                    //this is retainer doc
                                    if( addRetainer && ( retainerDocument.Id == null || document.CreatedDate > retainerDocument.CreatedDate ) && document.LStore__File_Name__c.contains( RETAINER ) ) {
                                        retainerDocument = document;
                                    }
                                    //this is an additional doc
                                    if( document.LStore__File_Name__c.contains( PROPOSAL ) && !document.LStore__File_Name__c.endsWith( PROPOSAL + ' - Proposal' + '.pdf' ) ) {
                                        if( !documentNameToDocument.containsKey( document.LStore__File_Name__c ) || document.CreatedDate > documentNameToDocument.get( document.LStore__File_Name__c ).CreatedDate ) {
                                            documentNameToDocument.put( document.LStore__File_Name__c, document );
                                        }
                                    }
                                }
                            }
                        }

                        //attach proposal doc if found
                        if( proposalDocument.Id != null ) {
                            String externalUrl = EmailMessageService.getExternalURL( proposalDocument.LStore__External_Id__c );
                            externalUrlToDocumentNameMap.put( externalUrl, ( proposalDocument.Drawings_Title__c != null ? proposalDocument.Drawings_Title__c : proposalDocument.LStore__File_Name__c ) );
                            documentLinkForEmail = externalUrl; //MRS-7061
                        }

                        //attach retainer doc if found
                        if( retainerDocument.Id != null ) {
                            String externalUrl = EmailMessageService.getExternalURL( retainerDocument.LStore__External_Id__c );
                            externalUrlToDocumentNameMap.put( externalUrl, ( retainerDocument.Drawings_Title__c != null ? retainerDocument.Drawings_Title__c : retainerDocument.LStore__File_Name__c ) );
                        }

                        //attach change order doc if found
                        if( changeOrderDocument.Id != null ) {
                            String externalUrl = EmailMessageService.getExternalURL( changeOrderDocument.LStore__External_Id__c );
                            externalUrlToDocumentNameMap.put( externalUrl, ( changeOrderDocument.Drawings_Title__c != null ? changeOrderDocument.Drawings_Title__c : changeOrderDocument.LStore__File_Name__c ) );
                            documentLinkForEmail = externalUrl; //MRS-7061
                        }

                        //attach additional docs if found
                        if( !documentNameToDocument.keySet().isEmpty() ) {
                            for( String fileName : documentNameToDocument.keySet() ) {
                                String externalUrl = EmailMessageService.getExternalURL( documentNameToDocument.get( fileName ).LStore__External_Id__c );
                                externalUrlToDocumentNameMap.put( externalUrl, fileName );
                            }
                        }

                        //G300 MRS-6807
                        if(configMap.get(ROSTER_JUNCTION)!=null && !configMap.get(ROSTER_JUNCTION).isEmpty()) {
                            for( LStore__Stored_Document__c storedDoc : proposalAdditionalOffLimitDocuments.get(new List<String>(configMap.get(ROSTER_JUNCTION))[0]) ) {
                                listOfAdditionalFiles.put( EmailMessageService.getExternalURL( storedDoc.LStore__External_Id__c ), storedDoc.LStore__File_Name__c );
                            }
                        }
                    }
                }

                //Prepare email body
                MergeEmailTemplate targetEmailTemplate = targetEmailTemplates.get( proposalOrCOId );
                targetEmailTemplate.loggedUserId = senderId;
                targetEmailTemplate.documentLink = documentLinkForEmail; //MRS-7061
                String body = targetEmailTemplate.headerBody +
                               targetEmailTemplate.body +                                                                       //G300 MRS-6807
                               EmailMessageService.getAttachmentsEmailBodyPartForSendingInOrder(externalUrlToDocumentNameMap, listOfAdditionalFiles) +
                               targetEmailTemplate.legalFooterForProposalAndCOEmails() +
                               targetEmailTemplate.footerBody;

                /*List<String> contactNames = new List<String>(configMap.get(CONTACT_NAME_KEYWORD));
                List<String> subjects = new List<String>(configMap.get(SUBJECT_KEYWORD));
                body = body.replace('{!Proposal__c.Billing_Company_Contact__c}', contactNames[0]);*/
                body = body.replace('<![CDATA[', '');
                body = body.replace(']]>', '');

                //Send email
                EmailMessageService.sendSingleEmailMessage( toRecipients,
                                                            ccRecipients,
                                                            proposalId,
                                                            trackingContactId,
                                                            targetEmailTemplate.subject.left(225)/*subjects[0]*/,
                                                            body,
                                                            documentsId);
            }

        }
    }

    public static void deleteJunctions( List<Roster_Email_Junction__c> rosterEmailJunctions ){
        try {
            DELETE rosterEmailJunctions;
        } catch(Exception e) {
            //
        }
    }

    public static List<Roster_Email_Junction__c> filterJunctionsToCountReminders( List<Roster_Email_Junction__c> newJunctionsList, Map<Id, Roster_Email_Junction__c> oldJunctionsMap) {
         List<Roster_Email_Junction__c> filteredJunctions = new List<Roster_Email_Junction__c>();

         for( Roster_Email_Junction__c junction : newJunctionsList ) {
            if( junction.Send_Email__c && !oldJunctionsMap.get( junction.Id ).Send_Email__c ) {
                filteredJunctions.add( junction );
            }
        }

        return filteredJunctions;
    }

    public static void countRemindersForProposalsAndCOs( List<Roster_Email_Junction__c> rosterEmailJunctions ) {
        if( rosterEmailJunctions.isEmpty() ) return;
        List<Proposal__c> proposals = new List<Proposal__c>();
        List<Change_Order__c> changeOrders = new List<Change_Order__c>();

        for( Roster_Email_Junction__c item: rosterEmailJunctions ){
            if( item.Change_Order__c != null ){
                changeOrders.add( new Change_Order__c( Id = item.Change_Order__c, Follow_Ups_Count__c = (item.Follow_Ups_Count_CO__c + 1), Last_Follow_Up_Date__c = item.Reminder_Date_Time__c ) );
            }else{
                proposals.add( new Proposal__c( Id = item.Proposal__c, Follow_Ups_Count__c = (item.Follow_Ups_Count_Proposal__c + 1), Last_Follow_Up_Date__c = item.Reminder_Date_Time__c ) );
            }
        }

        try {
            update proposals;
            update changeOrders;
        } catch( Exception ex ) {
            system.debug(LoggingLevel.Error, ex.getMessage() );
        }
    }

    public static void changeRosterEmailJunctionType( Boolean isLightDoc, String changeOrderId ) {
        if( isLightDoc != null && !String.isBlank( changeOrderId ) ) {
            List<Roster_Email_Junction__c> junctions = [ SELECT Id FROM Roster_Email_Junction__c WHERE Change_Order__c = : changeOrderId ];
            for( Roster_Email_Junction__c junction : junctions ) {
                junction.Document_Type__c = isLightDoc
                                            ? ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT
                                            : ChangeOrderServices.CO_DOCUMENT_TYPE_FULL;
            }
            UPDATE junctions;
        }
    }

}