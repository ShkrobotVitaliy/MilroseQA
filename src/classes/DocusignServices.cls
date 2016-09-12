public with sharing class DocusignServices {
    private static final String VOID_ENVELOPE_ERROR = 'An error occurred while voiding the document: ';
    private static final String GET_ENVELOPE_NOTIFICATION_ERROR = 'An error occurred while retrieving envelope notifications information: ';
    private static final String GET_ENVELOPE_RECIPIENT_ERROR = 'An error occurred while retrieving envelope recipient information: ';

    private static final String ENVELOPE_STATUS_SENT = 'Sent';
    private static final String ENVELOPE_STATUS_VOIDED = 'Voided';
    private static final String ENVELOPE_STATUS_REJECTED = 'Rejected';
    private static final String ENVELOPE_STATUS_COMPLETED = 'Completed';
    private static final String ENVELOPE_STATUS_DECLINED = 'Declined';

    private static final Integer OK_STATUS = 200;

    private static final String API_ACCOUNTID = 'Api_Account_Id';
    private static final String API_VERSION = 'Api_Version';
    private static final String ENVIRONMENT = 'Environment';
    private static final String USERNAME = 'Username';
    private static final String PASSWORD = 'Password';
    private static final String INTEGRATOR_KEY = 'Integrator_Key';

    public static final String VOID_REASON_UNKNOWN = 'The document has been voided.';
    public static final String VOID_REASON_RESEND = 'A new document will be sent for signing instead of this one.';
    public static final String VOID_REASON_PROPOSAL_EXPIRED = 'The Proposal has been expired.';
    public static final String VOID_REASON_PROPOSAL_CANCELED = 'The Proposal has been canceled.';
    public static final String VOID_REASON_PROPOSAL_REJECTED = 'The Proposal has been rejected.';
    public static final String VOID_REASON_PROPOSAL_WITHDRAWN = 'The Proposal has been withdrawn.';
    public static final String VOID_REASON_PROPOSAL_NOT_AWARDED = 'The Proposal has not been awarded.';
    public static final String VOID_REASON_CHANGE_ORDER_CANCELED = 'The Change Order has been canceled.';
    public static final String VOID_REASON_CHANGE_ORDER_REJECTED = 'The Change Order has been rejected.';

    public static final String ESIGNED = 'eSigned';

    public static String docusignStatusPrefix { get { if( docusignStatusPrefix == null ) docusignStatusPrefix = dsfs__DocuSign_Status__c.sObjectType.getDescribe().getKeyPrefix(); return docusignStatusPrefix; } private set; }

    private static Map<String, String> docusignCreds {
        get {
            if( docusignCreds == null ) {
                docusignCreds = new Map<String, String>();
                for( Docusign_Settings__c setting : Docusign_Settings__c.getall().values() ) {
                    docusignCreds.put( API_ACCOUNTID, setting.Api_Account_Id__c );
                    docusignCreds.put( API_VERSION, setting.Api_Version__c );
                    docusignCreds.put( INTEGRATOR_KEY, setting.Integrator_Key__c );
                    docusignCreds.put( PASSWORD, setting.Password__c );
                    docusignCreds.put( USERNAME, setting.Username__c );
                    if( String.isEmpty( setting.Environment__c ) ) {
                        docusignCreds.put( ENVIRONMENT, '' );
                    } else {
                        docusignCreds.put( ENVIRONMENT, setting.Environment__c + '.' );
                    }
                    return docusignCreds;
                }
            }
            return docusignCreds;
        } private set;
    }

    public static void voidEnvelopes( Map<String, String> envelopeIdToRecordId, Map<String, String> recordIdToVoidReason ) {
        for( String envelopeId : envelopeIdToRecordId.keySet() ) {
            String recordId = envelopeIdToRecordId.get( envelopeId );
            String voidReason = VOID_REASON_UNKNOWN;
            if( recordIdToVoidReason != null && recordIdToVoidReason.get( recordId ) != null ) {
                voidReason = recordIdToVoidReason.get( recordId );
            }
            voidEnvelopes( new List<String>{ envelopeId }, voidReason );
        }
    }

    @future(callout=true)
    public static void voidEnvelopes( List<String> envelopeIds, String voidReason ) {
        if( String.isBlank( voidReason ) ) {
            voidReason = 'Unknown Reason';
        }
        for( String envelopeId : envelopeIds ) {
            validateEnvelope( envelopeId, VOID_ENVELOPE_ERROR );
            voidReason = String.escapeSingleQuotes( voidReason );

            HttpRequest request = new HttpRequest();
            request.setMethod( 'PUT' );
            constructEndPoint( request, envelopeId, null );
            constructHeader( request );
            constructBody( request, new Map<String, String>{ 'status' => 'voided', 'voidedReason' => voidReason } );
            System.debug( LoggingLevel.Error, 'xxx request.getMethod(): ' + request.getMethod() );
            System.debug( LoggingLevel.Error, 'xxx request.getEndpoint(): ' + request.getEndpoint() );
            System.debug( LoggingLevel.Error, 'xxx request.getHeader(): ' + request.getHeader('X-DocuSign-Authentication') );
            System.debug( LoggingLevel.Error, 'xxx request.getBody(): ' + request.getBody() );
            System.debug( LoggingLevel.Error, 'xxx request.toString(): ' + request.toString() );
            sendRequest( request, VOID_ENVELOPE_ERROR );
        }
    }

    public static void resendEnvelopes( Set<String> envelopeIds ) {
        List<String> envelopeIdsAsList = new List<String>();
        envelopeIdsAsList.addAll( envelopeIds );
        resendEnvelopes( envelopeIdsAsList );
    }

    @future(callout=true)
    public static void resendEnvelopes( List<String> envelopeIds ) {
        Map<String, String> envelopeIdToSenderEmail = getEnvelopeSenders( envelopeIds );

        for( String envelopeId : envelopeIds ) {
            validateEnvelope( envelopeId, GET_ENVELOPE_RECIPIENT_ERROR );

            HttpRequest request = new HttpRequest();
            request.setMethod( 'GET' );
            constructEndPoint( request, envelopeId, 'recipients' );
            constructHeader( request );
            System.debug( LoggingLevel.Error, 'xxx request.getMethod(): ' + request.getMethod() );
            System.debug( LoggingLevel.Error, 'xxx request.getEndpoint(): ' + request.getEndpoint() );
            System.debug( LoggingLevel.Error, 'xxx request.getHeader(): ' + request.getHeader('X-DocuSign-Authentication') );
            System.debug( LoggingLevel.Error, 'xxx request.toString(): ' + request.toString() );
            HttpResponse response = sendRequest( request, GET_ENVELOPE_RECIPIENT_ERROR );

            String responseBody = response.getBody();
            String signersOnly = '{\n  "signers": [' + responseBody.substringBetween('"signers": [', ']') + ']\n}';

            request = new HttpRequest();
            request.setMethod( 'PUT' );
            constructEndPoint( request, envelopeId, 'recipients?resend_envelope=true' );
            constructHeader( request, ',\"SendOnBehalfOf\":\"' + envelopeIdToSenderEmail.get( envelopeId ) + '\"' );
            constructBody( request, signersOnly );
            System.debug( LoggingLevel.Error, 'xxx request.getMethod(): ' + request.getMethod() );
            System.debug( LoggingLevel.Error, 'xxx request.getEndpoint(): ' + request.getEndpoint() );
            System.debug( LoggingLevel.Error, 'xxx request.getHeader(): ' + request.getHeader('X-DocuSign-Authentication') );
            System.debug( LoggingLevel.Error, 'xxx request.getBody(): ' + request.getBody() );
            System.debug( LoggingLevel.Error, 'xxx request.toString(): ' + request.toString() );
            sendRequest( request, GET_ENVELOPE_RECIPIENT_ERROR );
        }
    }

    public static Map<String, String> getEnvelopeSenders( List<String> envelopeIds ) {
        Map<String, String> envelopeIdToSenderEmail = new Map<String, String>();
        for( dsfs__DocuSign_Status__c status : [ SELECT dsfs__Sender_Email__c, dsfs__DocuSign_Envelope_ID__c FROM dsfs__DocuSign_Status__c WHERE dsfs__DocuSign_Envelope_ID__c IN : envelopeIds ] ) {
            envelopeIdToSenderEmail.put( status.dsfs__DocuSign_Envelope_ID__c, status.dsfs__Sender_Email__c );
        }
        return envelopeIdToSenderEmail;
    }

    public static Map<String, Object> getEnvelopeNotifications( String envelopeId ) {
        validateEnvelope( envelopeId, GET_ENVELOPE_NOTIFICATION_ERROR );

        HttpRequest request = new HttpRequest();
        request.setMethod( 'GET' );
        constructEndPoint( request, envelopeId, 'notification' );
        constructHeader( request );
        System.debug( LoggingLevel.Error, 'xxx request.getMethod(): ' + request.getMethod() );
        System.debug( LoggingLevel.Error, 'xxx request.getEndpoint(): ' + request.getEndpoint() );
        System.debug( LoggingLevel.Error, 'xxx request.getHeader(): ' + request.getHeader('X-DocuSign-Authentication') );
        System.debug( LoggingLevel.Error, 'xxx request.toString(): ' + request.toString() );
        HttpResponse response = sendRequest( request, GET_ENVELOPE_NOTIFICATION_ERROR );
        return (Map<String, Object>)JSON.deserializeUntyped( response.getBody() );
    }

    public static void setEnvelopeNotifications( String envelopeId ) {
        validateEnvelope( envelopeId, GET_ENVELOPE_NOTIFICATION_ERROR );

        HttpRequest request = new HttpRequest();
        request.setMethod( 'PUT' );
        constructEndPoint( request, envelopeId, '' );
        constructHeader( request );
        request.setBody( '\"notification\":{\"useAccountDefaults\":\"false\",\"reminders\":{\"reminderEnabled\":\"true\",\"reminderDelay\":\"4\",\"reminderFrequency\":\"4\"},\"expirations\":{\"expireEnabled\":\"true\",\"expireAfter\":\"40\",\"expireWarn\":\"true\"}}' );
        System.debug( LoggingLevel.Error, 'xxx request.getMethod(): ' + request.getMethod() );
        System.debug( LoggingLevel.Error, 'xxx request.getEndpoint(): ' + request.getEndpoint() );
        System.debug( LoggingLevel.Error, 'xxx request.getHeader(): ' + request.getHeader('X-DocuSign-Authentication') );
        System.debug( LoggingLevel.Error, 'xxx request.getBody(): ' + request.getBody() );
        System.debug( LoggingLevel.Error, 'xxx request.toString(): ' + request.toString() );
        HttpResponse response = sendRequest( request, GET_ENVELOPE_NOTIFICATION_ERROR );
    }

    private static HttpResponse sendRequest( HttpRequest request, String errorMessage ) {
        Http http = new Http();
        HttpResponse response = http.send( request );
        System.debug( LoggingLevel.Error, 'xxx response.getStatusCode(): ' + response.getStatusCode() );
        System.debug( LoggingLevel.Error, 'xxx response.getStatus(): ' + response.getStatus() );
        System.debug( LoggingLevel.Error, 'xxx response.getBody(): ' + response.getBody() );
        System.debug( LoggingLevel.Error, 'xxx response.toString(): ' + response.toString() );
        if( response.getStatusCode() != OK_STATUS ) {
            throw new ErrorException( errorMessage + response.getStatus() );
        }
        return response;
    }

    private static void validateEnvelope( String envelopeId, String errorMessage ) {
        if( String.isBlank( envelopeId ) ) {
            throw new ErrorException( errorMessage + 'Envelope Id can not be empty.' );
        }
    }

    public static void constructHeader( HttpRequest request ) {
        constructHeader( request, null );
    }

    public static void constructHeader( HttpRequest request, String additionalString ) {
        if( String.isBlank( additionalString ) ) {
            additionalString = '';
        }
        request.setHeader( 'X-DocuSign-Authentication', '{\"Username\":\"' + docusignCreds.get( USERNAME ) + '\",\"Password\":\"' + docusignCreds.get( PASSWORD ) + '\",\"IntegratorKey\":\"' + docusignCreds.get( INTEGRATOR_KEY ) + '\"' + additionalString + '}' );
    }

    private static void constructEndPoint( HttpRequest request, String envelopeId, String additionalString ) {
        if( String.isBlank( additionalString ) ) {
            additionalString = '';
        } else {
            additionalString = '/' + additionalString;
        }
        request.setEndpoint( String.format( 'https://{0}docusign.net/restapi/v{1}/accounts/{2}/envelopes/{3}{4}', new String[] { docusignCreds.get( ENVIRONMENT ), docusignCreds.get( API_VERSION ), docusignCreds.get( API_ACCOUNTID ), envelopeId, additionalString } ) );
    }

    private static void constructBody( HttpRequest request, String serializedParams ) {
        request.setBody( serializedParams );
    }

    private static void constructBody( HttpRequest request, Map<String, String> params ) {
        request.setBody( JSON.serialize( params ) );
    }

    public static List<String> getEnvelopesFromDocusignStatusesForObject( sObject inputObject ) {
        Map<String, String> envelopeIdToRecordId = getEnvelopesFromDocusignStatusesForObjects( new List<sObject>{ inputObject } );
        List<String> envelopeIds = new List<String>();
        if( envelopeIdToRecordId != null ) {
            envelopeIds.addAll( envelopeIdToRecordId.keySet() );
        }
        return envelopeIds;
    }

    public static List<String> getEnvelopesFromDocusignStatusesForObject( sObject inputProposal, sObject inputChangeOrder ) {
        Map<String, String> envelopeIdToRecordId;
        if( inputChangeOrder.get('Id') == null ) {
            envelopeIdToRecordId = getEnvelopesFromDocusignStatusesForObjects( new List<sObject>{ inputProposal } );
        } else {
            envelopeIdToRecordId = getEnvelopesFromDocusignStatusesForObjects( new List<sObject>{ inputChangeOrder } );
        }
        List<String> envelopeIds = new List<String>();
        if( envelopeIdToRecordId != null ) {
            envelopeIds.addAll( envelopeIdToRecordId.keySet() );
        }
        return envelopeIds;
    }

    public static Map<String, String> getEnvelopesFromDocusignStatusesForObjects( List<sObject> inputObjects ) {
        Map<String, String> envelopeIdToRecordId = new Map<String, String>();
        Map<String, Set<String>> objectTypeToObjectId = new Map<String, Set<String>>();

        for( sObject inputObject : inputObjects ) {
            String sObjectType = String.valueOf( inputObject.getSObjectType() );
            String sObjectId = (String)inputObject.get('Id');
            if( String.isNotBlank( sObjectId ) && ( sObjectType == ProposalServices.PROPOSAL_OBJECT_API_NAME || sObjectType == ChangeOrderServices.CHANGE_ORDER_OBJECT_API_NAME ) ) {
                String objectType = sObjectType.removeEnd('__c') + '_Docusign_Status__c';
                if( objectTypeToObjectId.get( objectType ) == null ) {
                    objectTypeToObjectId.put( objectType, new Set<String>() );
                }
                objectTypeToObjectId.get( objectType ).add( sObjectId );
            }
        }

        String query = 'SELECT Id, dsfs__DocuSign_Envelope_ID__c, Proposal_Docusign_Status__c, Change_Order_Docusign_Status__c FROM dsfs__DocuSign_Status__c WHERE ( ';
        String queryWhere = '';
        String queryEnd = ' ) AND ( dsfs__Envelope_Status__c != \'' + ENVELOPE_STATUS_COMPLETED + '\' AND dsfs__Envelope_Status__c != \'' + ENVELOPE_STATUS_VOIDED + '\' AND dsfs__Envelope_Status__c != \'' + ENVELOPE_STATUS_DECLINED + '\' AND dsfs__Envelope_Status__c != \'' + ENVELOPE_STATUS_REJECTED + '\' )';
        for( String sObjectType : objectTypeToObjectId.keySet() ) {
            List<String> objectIds = new List<String>();
            objectIds.addAll( objectTypeToObjectId.get( sObjectType ) );
            queryWhere += ' ( ' + sObjectType + ' = \'' + String.join( objectIds, '\' OR ' + sObjectType + ' = \'' ) + '\' ) OR ';
        }
        queryWhere = queryWhere.removeEnd( ' OR ' );
        if( !String.isBlank( queryWhere ) ) {
            query += queryWhere + queryEnd;
            for( dsfs__DocuSign_Status__c docusignStatus : Database.query( query ) ) {
                envelopeIdToRecordId.put( docusignStatus.dsfs__DocuSign_Envelope_ID__c,
                                          ( !String.isBlank( docusignStatus.Proposal_Docusign_Status__c ) )
                                            ? docusignStatus.Proposal_Docusign_Status__c
                                            : docusignStatus.Change_Order_Docusign_Status__c );
            }
            
        }
        return envelopeIdToRecordId;
    }

    public static Map<String, String> getEnvelopeVoidReasons( List<sObject> filteredObjects, Map<Id, sObject> oldObjects ) {
        Map<String, String> sObjectIdToRejectReason = new Map<String, String>();
        if( oldObjects != null ) {
            for( sObject filteredObject : filteredObjects ) {
                String sObjectType = String.valueOf( filteredObject.getSObjectType() );
                String filteredObjectId = (String)filteredObject.get('Id');
                sObject oldObject = oldObjects.get( Id.valueOf( filteredObjectId ) );
                if( String.isNotBlank( filteredObjectId ) && String.isNotBlank( (String)oldObject.get('Id') ) ) {
                    if( sObjectType == ProposalServices.PROPOSAL_OBJECT_API_NAME ) {
                        String newStatus = (String)filteredObject.get('Status__c');
                        String rejectionReason = '';
                        if( newStatus == ProposalServices.PROPOSAL_STATUS_CANCELLED ) {
                            rejectionReason = VOID_REASON_PROPOSAL_CANCELED;
                        } else if( newStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) {
                            rejectionReason = VOID_REASON_PROPOSAL_REJECTED;
                        } else if( newStatus == ProposalServices.PROPOSAL_STATUS_WITHDRAWN ) {
                            rejectionReason = VOID_REASON_PROPOSAL_WITHDRAWN;
                        } else if( newStatus == ProposalServices.PROPOSAL_STATUS_NOT_AWARDED ) {
                            rejectionReason = VOID_REASON_PROPOSAL_NOT_AWARDED;
                        } else if( newStatus == ProposalServices.PROPOSAL_STATUS_EXPIRED ) {
                            rejectionReason = VOID_REASON_PROPOSAL_EXPIRED;
                        } else {
                            rejectionReason = VOID_REASON_UNKNOWN;
                        }
                        sObjectIdToRejectReason.put( filteredObjectId, rejectionReason );
                    } else if( sObjectType == ChangeOrderServices.CHANGE_ORDER_OBJECT_API_NAME ) {
                        String newStatus = (String)filteredObject.get('Status__c');
                        String rejectionReason = '';
                        if( newStatus == ChangeOrderServices.STATUS_CANCELED ) {
                            rejectionReason = VOID_REASON_CHANGE_ORDER_CANCELED;
                        } else if( newStatus == ChangeOrderServices.STATUS_REJECTED ) {
                            rejectionReason = VOID_REASON_CHANGE_ORDER_REJECTED;
                        } else {
                            rejectionReason = VOID_REASON_UNKNOWN;
                        }
                        sObjectIdToRejectReason.put( filteredObjectId, rejectionReason );
                    }
                }
            }
        }
        return sObjectIdToRejectReason;
    }

    public static List<dsfs__DocuSign_Status__c> filterCompletedDocusignStatuses( List<dsfs__DocuSign_Status__c> newStatuses, Map<Id, dsfs__DocuSign_Status__c> oldStatusesMap ) {
        List<dsfs__DocuSign_Status__c> filteredStatuses = new List<dsfs__DocuSign_Status__c>();
        for( dsfs__DocuSign_Status__c status : newStatuses ) {
            if( status.dsfs__Envelope_Status__c == ENVELOPE_STATUS_COMPLETED && oldStatusesMap.get( status.Id ).dsfs__Envelope_Status__c != ENVELOPE_STATUS_COMPLETED ) {
                filteredStatuses.add( status );
            }
        }
        return filteredStatuses;
    }

    public static List<dsfs__DocuSign_Status__c> filterDocusignStatusesToRemoveReminders( List<dsfs__DocuSign_Status__c> newStatuses, Map<Id, dsfs__DocuSign_Status__c> oldStatusesMap ) {
        List<dsfs__DocuSign_Status__c> filteredStatuses = new List<dsfs__DocuSign_Status__c>();
        for( dsfs__DocuSign_Status__c status : newStatuses ) {
            if( ( status.dsfs__Envelope_Status__c == ENVELOPE_STATUS_COMPLETED && oldStatusesMap.get( status.Id ).dsfs__Envelope_Status__c != ENVELOPE_STATUS_COMPLETED ) ||
                ( status.dsfs__Envelope_Status__c == ENVELOPE_STATUS_DECLINED && oldStatusesMap.get( status.Id ).dsfs__Envelope_Status__c != ENVELOPE_STATUS_DECLINED ) ) {
                filteredStatuses.add( status );
            }
        }
        return filteredStatuses;
    }

    public static void setEsignedFlagOnProposalOrChangeOrder( List<dsfs__DocuSign_Status__c> filteredStatuses ) {
        Map<Id, sObject> proposals = new Map<Id, sObject>();
        Map<Id, sObject> changeOrders = new Map<Id, sObject>();
        List<sObject> objectsToUpdate = new List<sObject>();
        for( dsfs__DocuSign_Status__c status : filteredStatuses ) {
            proposals.put( status.Proposal_Docusign_Status__c, new Proposal__c( Id = status.Proposal_Docusign_Status__c, eSigned__c = ESIGNED, Received_Signed_Proposal__c = true) ); // MRS 7170
            changeOrders.put( status.Change_Order_Docusign_Status__c, new Change_Order__c( Id = status.Change_Order_Docusign_Status__c, eSigned__c = ESIGNED, Received_Signed_CO__c = true) );
        }
        proposals.remove( null );
        changeOrders.remove( null );
        objectsToUpdate.addAll( proposals.values() );
        objectsToUpdate.addAll( changeOrders.values() );
        if( !objectsToUpdate.isEmpty() ) {
            Database.update( objectsToUpdate, false );
        }
    }

    public static void removeUnfinishedFollowUpReminders( List<dsfs__DocuSign_Status__c> filteredStatuses ) {
        Set<Id> proposalIds = new Set<Id>();
        Set<Id> changeOrderIds = new Set<Id>();
        for( dsfs__DocuSign_Status__c status : filteredStatuses ) {
            if( status.Proposal_Docusign_Status__c != null ) {
                proposalIds.add( status.Proposal_Docusign_Status__c );
            }
            if( status.Change_Order_Docusign_Status__c != null ) {
                changeOrderIds.add( status.Change_Order_Docusign_Status__c );
            }
        }
        if( !proposalIds.isEmpty() || !changeOrderIds.isEmpty() ) {
            String query = 'SELECT Id FROM Roster_Email_Junction__c WHERE';
            if( !proposalIds.isEmpty() ) {
                query += ' ( Proposal__c IN : proposalIds AND Change_Order__c = null )';
            }
            if( !proposalIds.isEmpty() && !changeOrderIds.isEmpty() ) {
                query += ' OR';
            }
            if( !changeOrderIds.isEmpty() ) {
                query += ' ( Change_Order__c IN : changeOrderIds )';
            }
            List<Roster_Email_Junction__c> junctions = Database.query( query );
            if( !junctions.isEmpty() ) {
                Database.delete( junctions, false );
            }
        }
    }

}