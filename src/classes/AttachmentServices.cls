public class AttachmentServices {
    private static List<SelectOption> itemsRelatedToAttach;
    private static Set<Id> documentIds;

    public static List<SelectOption> getItemsRelatedToAttach() {
        if( null == itemsRelatedToAttach ) {
            itemsRelatedToAttach = new List<SelectOption>();
            itemsRelatedToAttach.add( new SelectOption ( '- None -', '- None -' ) );
        }
        itemsRelatedToAttach.add( new SelectOption( 'Project', 'Project' ) );
        itemsRelatedToAttach.add( new SelectOption( 'Proposal', 'Proposal' ) );
        itemsRelatedToAttach.add( new SelectOption( 'Service Item', 'Service Item' ) );
        itemsRelatedToAttach.add( new SelectOption( 'Task Item', 'Task Item' ) );
        itemsRelatedToAttach.add( new SelectOption( 'RFI', 'RFI' ) );
        return itemsRelatedToAttach;
    }

    public static void setItemsRelatedToAttach( SelectOption option ) {
        if( null == option ) {
            return;
        }
        if( null == itemsRelatedToAttach ) {
            itemsRelatedToAttach = new List<SelectOption>();
            itemsRelatedToAttach.add( new SelectOption ( '- None -', '- None -' ) );
        }
        itemsRelatedToAttach.add( option );
    }

    public static Set<Id> getDocumentIds() {
        if( null == documentIds ) {
            documentIds = new Set<Id>();
        }
        return documentIds;
    }

    public static void setDocumentIds(Id documentId) {
        if( null == documentId ) {
            return;
        }
        if( null == documentIds ) {
            documentIds = new Set<Id>();
        }
        documentIds.add( documentId );
    }

    public static String attachmentParentIds {
        get {
            if( String.isBlank( attachmentParentIds ) ) {
                attachmentParentIds = '';
            }
            for( Id docId : getDocumentIds() ) {
                attachmentParentIds += String.valueOf( docId ) + ',';
            }
            return attachmentParentIds;
        }
        private set;
    }

    public static String getObjectName( Id objectId ) {
        if( null == objectId ) {
            throw new ErrorException( ErrorException.ATTACHMENT_EMPTY_OBJECT_ID );
        }
        try {
            return objectId.getSObjectType().getDescribe().getLabel();
        } catch( Exception ex ) {
            throw new ErrorException( ErrorException.ATTACHMENT_INVALID_OBJECT_ID );
        }
    }

    //Proposal:
    //+ projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf

    //Proposal + Docs:
    //+ projname CN00000xxxx v.01.00 - Proposal - Proposal.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Proposal - Internal Check Request Backup.pdf_Completed.pdf

    //Proposal + Retainer:
    //+ projname CN00000xxxx v.01.00 - Proposal - Proposal.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Proposal - Retainer Invoice.pdf_Completed.pdf

    //Proposal + Retainer + Docs:
    //+ projname CN00000xxxx v.01.00 - Proposal - Proposal.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Proposal - Retainer Invoice.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Proposal - Internal Check Request Backup.pdf_Completed.pdf

    //CO:
    //+ projname CN00000xxxx v.01.00 - Change Order#1.pdf_Completed.pdf

    //CO + Docs:
    //+ projname CN00000xxxx v.01.00 - Change Order#1 - Change Order.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Internal Check Request Backup.pdf_Completed.pdf

    //CO + Retainer:
    //+ projname CN00000xxxx v.01.00 - Change Order#1 - Change Order.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Retainer Invoice.pdf_Completed.pdf

    //CO + Retainer + Docs:
    //+ projname CN00000xxxx v.01.00 - Change Order#1 - Change Order.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Retainer Invoice.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Internal Check Request Backup.pdf_Completed.pdf

    //Proposal Signed on Paper:
    //+ projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf (remove from stored docs if signed on paper found)
    //+ Signed-on-Paper_f61e2332-b005-46f1-a548-4e53d81835d5_Completed.pdf

    //CO Signed On Paper + Retainer + Docs:
    //+ projname CN00000xxxx v.01.00 - Change Order#1 - Change Order.pdf_Completed.pdf (remove from stored docs if signed on paper found)
    //+ Signed-on-Paper_10ab01c5-ac85-4ba4-af4e-a9f61aa34a84_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Retainer Invoice.pdf_Completed.pdf
    //- projname CN00000xxxx v.01.00 - Change Order#1 - Internal Check Request Backup.pdf_Completed.pdf

    public static List<Attachment> filterSignedAttachmentsForRenaming( List<Attachment> newAttachments ) {
        List<Attachment> filteredAttachments = new List<Attachment>();
        for( Attachment att : newAttachments ) {
            String attName = att.Name.replaceAll( StoredDocumentServices.CHANGE_ORDER_DOCUMENT + '\\d+', StoredDocumentServices.CHANGE_ORDER_FILENAME ); //replace 'Change Order#1' with 'Change Order' for comparison

            if( !att.IsPrivate &&
                String.valueOf( att.parentId ).startsWith( DocusignServices.docusignStatusPrefix ) &&
                attName.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.' ) && //'_Completed'
                ( attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + StoredDocumentServices.PDF_EXTENSION ) ||     //projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf
                                                                                                                                     //projname CN00000xxxx v.01.00 - Proposal - Proposal.pdf_Completed.pdf
                  attName.contains( ' - ' + StoredDocumentServices.CHANGE_ORDER_FILENAME + StoredDocumentServices.PDF_EXTENSION ) || //projname CN00000xxxx v.01.00 - Change Order.pdf_Completed.pdf
                                                                                                                                     //projname CN00000xxxx v.01.00 - Change Order - Change Order.pdf_Completed.pdf
                  attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //projname CN00000xxxx v.01.00 - Proposal_Completed.pdf
                  attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + '.pd' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + '.p' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + '.' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + StoredDocumentServices.PROPOSAL_DOCUMENT + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + 'Proposa' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Propos' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Propo' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Prop' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Pro' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Pr' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'P' + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + StoredDocumentServices.CHANGE_ORDER_FILENAME + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //projname CN00000xxxx v.01.00 - Change Order - Change Order_Completed.pdf
                  attName.contains( ' - ' + StoredDocumentServices.CHANGE_ORDER_FILENAME + '.pd' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + StoredDocumentServices.CHANGE_ORDER_FILENAME + '.p' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + StoredDocumentServices.CHANGE_ORDER_FILENAME + '.' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) || //MRS-7284
                  attName.contains( ' - ' + 'Change Orde' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Change Ord' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Change Or' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Change O' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Change ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Change' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.contains( ' - ' + 'Chang' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + StoredDocumentServices.PDF_EXTENSION ) || //MRS-7233
                  attName.startsWith( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_OLD ) ) ) {                                    //Signed-on-Paper_f61e2332-b005-46f1-a548-4e53d81835d5_Completed.pdf
                        filteredAttachments.add( att );
            }
        }
        return filteredAttachments;
    }

    public static void renameSignedAttachments( List<Attachment> filteredAttachments ) {
        for( Attachment att : filteredAttachments ) {
            if( att.Name.startsWith( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_OLD ) ) {
                //signed on paper files
                //Signed-on-Paper_f61e2332-b005-46f1-a548-4e53d81835d5_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed on Paper.pdf
                //Signed-on-Paper_f61e2332-b005-46f1-a548-4e53d81835d5_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal - Proposal Signed on Paper.pdf
                //Signed-on-Paper_10ab01c5-ac85-4ba4-af4e-a9f61aa34a84_Completed.pdf -> projname CN00000xxxx v.01.00 - Change Order#1 Signed on Paper.pdf
                //Signed-on-Paper_10ab01c5-ac85-4ba4-af4e-a9f61aa34a84_Completed.pdf -> projname CN00000xxxx v.01.00 - Change Order#1 - Change Order Signed on Paper.pdf
                List<dsfs__DocuSign_Status__c> statusRecord = [ SELECT Proposal_Docusign_Status__c, Change_Order_Docusign_Status__c FROM dsfs__DocuSign_Status__c WHERE Id = : att.parentId ];
                if( !statusRecord.isEmpty() ) {
                    List<String> splitFileName = att.Name.split('\\.');
                    String fileExtension = '';
                    if( !splitFileName.isEmpty() ) {
                        fileExtension = '.' + splitFileName[ splitFileName.size() - 1 ];
                    }
                    if( statusRecord[0].Change_Order_Docusign_Status__c != null ) {
                        List<Change_Order__c> changeOrder = [ SELECT DDP_Project_Name__c, Proposal__r.Name, Proposal__r.Version_Text__c, Number__c, DDP_Include_Retainer_Invoice__c
                                                              FROM Change_Order__c
                                                              WHERE Id = : statusRecord[0].Change_Order_Docusign_Status__c ];
                        if( !changeOrder.isEmpty() ) {
                            att.Name = changeOrder[0].DDP_Project_Name__c + ' ' + changeOrder[0].Proposal__r.Name + ' v.' + changeOrder[0].Proposal__r.Version_Text__c + ' - Change Order#' + String.valueOf(changeOrder[0].Number__c) +
                                       ( changeOrder[0].DDP_Include_Retainer_Invoice__c ? ' - Change Order' : '' ) +
                                       ' ' + StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + fileExtension;
                        }
                    } else if( statusRecord[0].Proposal_Docusign_Status__c != null ) {
                        List<Proposal__c> proposal = [ SELECT DDP_Project_Name__c, Name, Version_Text__c, DDP_Include_Retainer_Invoice__c
                                                       FROM Proposal__c
                                                       WHERE Id = : statusRecord[0].Proposal_Docusign_Status__c ];
                        if( !proposal.isEmpty() ) {
                            att.Name = proposal[0].DDP_Project_Name__c + ' ' + proposal[0].Name + ' v.' + proposal[0].Version_Text__c + ' - Proposal' +
                                       ( proposal[0].DDP_Include_Retainer_Invoice__c ? ' - Proposal' : '' ) +
                                       ' ' + StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + fileExtension;
                        }
                    }
                }
            } else if( att.Name.contains( StoredDocumentServices.PDF_EXTENSION + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) ) {
                //regular signed files
                //'.pdf_Completed.'' -> ' Signed.': projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                att.Name = att.Name.replace( StoredDocumentServices.PDF_EXTENSION + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.', ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
            }else if( att.Name.contains( 'Change Order.pd' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) ) {
                //'.pd_Completed.'' -> ' Signed.': projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                att.Name = att.Name.replace( '.pd' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.', ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
            }else if( att.Name.contains( 'Change Order.p' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) ) {
                //'.p_Completed.'' -> ' Signed.': projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                att.Name = att.Name.replace( '.p' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.', ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
            }else if( att.Name.contains( 'Change Order.' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) ) {
                //'._Completed.'' -> ' Signed.': projname CN00000xxxx v.01.00 - Proposal.pdf_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                att.Name = att.Name.replace( '.' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.', ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
            } else if( att.Name.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.' ) ) {
                //regular signed files
                //'_Completed.'' -> ' Signed.': projname CN00000xxxx v.01.00 - Proposal_Completed.pdf -> projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                att.Name = att.Name.replace( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.', ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
            } else if( att.Name.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD ) ) {
                //all other files
                //'_Completed' -> ' Signed'
                att.Name = att.Name.replace( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD, ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW );
            }
	    /*att.Name = att.Name.replace( 'Change Order.pd', 'Change Order ' ); //MRS-7284
	    att.Name = att.Name.replace( 'Change Order.p', 'Change Order ' ); //MRS-7284
	    att.Name = att.Name.replace( 'Change Order.', 'Change Order ' ); //MRS-7284*/
	    
        }
    }

    public static Map<Id, List<Id>> findAttachmentsForTasks( List<Task> parentTasks ) {
        Map<Id, List<Id>> taskIdToAttachmentIds = new Map<Id, List<Id>>();
        for( Attachment attachment : [ SELECT Id, ParentId FROM Attachment WHERE ParentId IN : parentTasks ] ) {
            if( taskIdToAttachmentIds.get( attachment.ParentId ) == null ) {
                taskIdToAttachmentIds.put( attachment.ParentId, new List<Id>() );
            }
            taskIdToAttachmentIds.get( attachment.ParentId ).add( attachment.Id );
        }
        return taskIdToAttachmentIds;
    }

    public static Map<Id, List<Id>> filterAttachmentIdsForMovingToStoredDocuments( List<Attachment> newAttachments, Boolean isFilterForFoldersCreation ) {
        Map<Id, List<Id>> parentIdToAttachmentIds = new Map<Id, List<Id>>();
        for( Attachment att : newAttachments ) {
            String attName = att.Name.replaceAll( StoredDocumentServices.CHANGE_ORDER_DOCUMENT + '\\d+', StoredDocumentServices.CHANGE_ORDER_FILENAME ); //replace 'Change Order#1' with 'Change Order' for comparison
            if( !att.IsPrivate &&
                ( //Docusign Status Proposal/CO Attachments Upload
                  ( String.valueOf( att.parentId ).startsWith( DocusignServices.docusignStatusPrefix ) &&
                    ( attName.contains( StoredDocumentServices.PROPOSAL_DOCUMENT + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||     //projname CN00000xxxx v.01.00 - Proposal Signed.pdf
                                                                                                                                                             //projname CN00000xxxx v.01.00 - Proposal - Proposal Signed.pdf
                      attName.contains( StoredDocumentServices.PROPOSAL_DOCUMENT + '.pd ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( StoredDocumentServices.PROPOSAL_DOCUMENT + '.p ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( StoredDocumentServices.PROPOSAL_DOCUMENT + '. ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( 'Proposa' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Propos' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Propo' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Prop' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Pro' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Pr' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'P' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233

                      attName.contains( StoredDocumentServices.CHANGE_ORDER_FILENAME + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) || //projname CN00000xxxx v.01.00 - Change Order#1 Signed.pdf
                                                                                                                                                             //projname CN00000xxxx v.01.00 - Change Order#1 - Change Order Signed.pdf
                      attName.contains( StoredDocumentServices.CHANGE_ORDER_FILENAME + '.pd ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( StoredDocumentServices.CHANGE_ORDER_FILENAME + '.p ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( StoredDocumentServices.CHANGE_ORDER_FILENAME + '. ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7284
                      attName.contains( 'Change Orde' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Change Ord' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Change Or' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Change O' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Change ' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Change' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( 'Chang' + ' ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ||//MRS-7233
                      attName.contains( StoredDocumentServices.PROPOSAL_DOCUMENT + ' ' + StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' ) ||      //projname CN00000xxxx v.01.00 - Proposal Signed on Paper.pdf
                                                                                                                                                             //projname CN00000xxxx v.01.00 - Proposal - Proposal Signed on Paper.pdf
                      attName.contains( StoredDocumentServices.CHANGE_ORDER_FILENAME + ' ' + StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' )     //projname CN00000xxxx v.01.00 - Change Order#1 Signed on Paper.pdf
                                                                                                                                                             //projname CN00000xxxx v.01.00 - Change Order#1 - Change Order Signed on Paper.pdf
                    )
                  ) ||

                   //Task Attachment Upload
                  ( !isFilterForFoldersCreation && //no need to create folders for Task Attachments
                    String.valueOf( att.parentId ).startsWith( TaskServices.taskPrefix )
                  )
                )
              ) {

                if( parentIdToAttachmentIds.get( att.ParentId ) == null ) {
                    parentIdToAttachmentIds.put( att.ParentId, new List<Id>() );
                }
                parentIdToAttachmentIds.get( att.ParentId ).add( att.Id );
            }
        }
        return parentIdToAttachmentIds;
    }

    public static void moveAttachmentsToStoredDocuments( Map<Id, List<Id>> parentIdToAttachmentIds ) {
        Set<Id> docusignStatusIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();

        for( Id parentId : parentIdToAttachmentIds.keySet() ) {
            if( parentId != null && parentIdToAttachmentIds.get( parentId ) != null && !parentIdToAttachmentIds.get( parentId ).isEmpty() ) {
                if( String.valueOf( parentId ).startsWith( DocusignServices.docusignStatusPrefix ) ) {
                    docusignStatusIds.add( parentId );
                } else if( String.valueOf( parentId ).startsWith( TaskServices.taskPrefix ) ) {
                    taskIds.add( parentId );
                }
            }
        }

        DDPRequest request = new DDPRequest();

        if( !docusignStatusIds.isEmpty() ) {
            for( dsfs__DocuSign_Status__c status : [ SELECT Proposal_Docusign_Status__c, Change_Order_Docusign_Status__r.Proposal__c
                                                     FROM dsfs__DocuSign_Status__c
                                                     WHERE Id IN : docusignStatusIds
                                                       AND ( Proposal_Docusign_Status__c != null OR Change_Order_Docusign_Status__r.Proposal__c != null ) ] ) {
                request.addConfiguration( status.Proposal_Docusign_Status__c != null ? status.Proposal_Docusign_Status__c : status.Change_Order_Docusign_Status__r.Proposal__c,
                                          DDPEmailServices.DDP_NAME_UPLOAD_DOC_FROM_ATTACHMENT_TO_PROPOSAL,
                                          DDPEmailServices.DELIVERY_METHOD_ATTACH,
                                          null,
                                          null,
                                          status.Id,
                                          parentIdToAttachmentIds.get( status.Id ) );
            }
        }

        for( Id taskId : taskIds ) {
            request.addConfiguration( taskId,
                                      DDPEmailServices.DDP_NAME_UPLOAD_DOC_FROM_ATTACHMENT_TO_TASK,
                                      DDPEmailServices.DELIVERY_METHOD_ATTACH,
                                      null,
                                      null,
                                      null,
                                      parentIdToAttachmentIds.get( taskId ) );
        }

        request.sendRequest();
    }

    public static List<Id> filterUnneededAttachmentsForDeletion( List<Attachment> newAttachments, Map<Id, List<Id>> filteredAttachmentIdsForMovingToStoredDocuments ) {
        Set<Id> attachmentsQueuedForUpload = new Set<Id>();
        List<Id> attachmentIdsToDelete = new List<Id>();
        for( List<Id> attachmentIds : filteredAttachmentIdsForMovingToStoredDocuments.values() ) {
            attachmentsQueuedForUpload.addAll( attachmentIds );
        }
        for( Attachment att : newAttachments ) {
            if( !att.IsPrivate &&
                String.valueOf( att.parentId ).startsWith( DocusignServices.docusignStatusPrefix ) &&
                !attachmentsQueuedForUpload.contains( att.Id ) ) {
                attachmentIdsToDelete.add( att.Id );
            }
        }
        return attachmentIdsToDelete;
    }

    @future
    public static void deleteUnneededAttachments( List<Id> attachmentIds ) {
        if( !attachmentIds.isEmpty() ) {
            List<Attachment> attachmentsToDelete = new List<Attachment>();
            for( Id attachmentId : attachmentIds ) {
                attachmentsToDelete.add( new Attachment( Id = attachmentId ) );
            }
            Database.delete( attachmentsToDelete, false );
        }
    }

    public static void deleteAttachmentsByName( Map<Id, Set<String>> parentIdToAttachmentNames ) {
        Set<Id> proposalOrCoIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();

        for( Id parentId : parentIdToAttachmentNames.keySet() ) {
            if( parentId != null && parentIdToAttachmentNames.get( parentId ) != null && !parentIdToAttachmentNames.get( parentId ).isEmpty() ) {
                if( String.valueOf( parentId ).startsWith( ProposalServices.proposalPrefix ) ) {
                    proposalOrCoIds.add( parentId );
                } else if( String.valueOf( parentId ).startsWith( TaskServices.taskPrefix ) ) {
                    taskIds.add( parentId );
                }
            }
        }

        Map<Id, Id> docusignStatusIdToProposalOrCoId = new Map<Id, Id>();
        if( !proposalOrCoIds.isEmpty() ) {
            for( dsfs__DocuSign_Status__c status : [ SELECT Proposal_Docusign_Status__c, Change_Order_Docusign_Status__r.Proposal__c
                                                     FROM dsfs__DocuSign_Status__c
                                                     WHERE ( Proposal_Docusign_Status__c IN : proposalOrCoIds OR Change_Order_Docusign_Status__r.Proposal__c IN : proposalOrCoIds )
                                                       AND ( Proposal_Docusign_Status__c != null OR Change_Order_Docusign_Status__r.Proposal__c != null ) ] ) {
                docusignStatusIdToProposalOrCoId.put( status.Id, status.Proposal_Docusign_Status__c != null ? status.Proposal_Docusign_Status__c : status.Change_Order_Docusign_Status__r.Proposal__c );
            }
        }

        if( !docusignStatusIdToProposalOrCoId.keySet().isEmpty() || !taskIds.isEmpty() ) {
            List<Attachment> attachmentsToDelete = new List<Attachment>();
            for( Attachment att : [ SELECT ParentId, Name
                                    FROM Attachment
                                    WHERE IsPrivate = false
                                      AND ( ParentId IN : docusignStatusIdToProposalOrCoId.keySet() OR ParentId IN : taskIds ) ] ) {
                if( ( String.valueOf( att.ParentId ).startsWith( DocusignServices.docusignStatusPrefix ) &&
                      docusignStatusIdToProposalOrCoId.get( att.ParentId ) != null &&
                      parentIdToAttachmentNames.get( docusignStatusIdToProposalOrCoId.get( att.ParentId ) ) != null &&
                      parentIdToAttachmentNames.get( docusignStatusIdToProposalOrCoId.get( att.ParentId ) ).contains( att.Name ) ) ||
                    ( String.valueOf( att.ParentId ).startsWith( TaskServices.taskPrefix ) &&
                      parentIdToAttachmentNames.get( att.ParentId ) != null &&
                      parentIdToAttachmentNames.get( att.ParentId ).contains( att.Name ) ) ) {
                    attachmentsToDelete.add( att );
                }
            }
            if( !attachmentsToDelete.isEmpty() ) {
                Database.delete( attachmentsToDelete, false );
            }
        }
    }

}