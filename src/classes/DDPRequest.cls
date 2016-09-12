public with sharing class DDPRequest {
    private String DDP_NAME_OPTION = 'ddpName';
    private String DELIVERY_METHOD_NAME_OPTION = 'deliveryMethod';
    private String RECIPIENT_PARAMETER_CC_START = 'cc';
    private String RECIPIENT_PARAMETER_APPROVER_START = 'appr';
    private String RECIPIENT_PARAMETER_MAIL_END = '_email';
    private String RECIPIENT_PARAMETER_NAME_END = '_name';

    private List<Map<String, String>> configurationList;
    private Set<String> ddpNames;

    public DDPRequest() {
        setupLoopMessenger();
    }

    public Boolean hasConfigurations() {
        return this.configurationList != null ? this.configurationList.size() > 0 : false;
    }

    @TestVisible
    private void setupLoopMessenger() {
        this.configurationList = new List<Map<String, String>>();
        this.ddpNames = new Set<String>();
    }

    public void addConfiguration( Id mainRecordId, String ddpName, String deliveryMethod ) {
        addConfiguration( mainRecordId, ddpName, deliveryMethod, null, null,
                          null, null, null, null );
    }

    public void addConfiguration( Id mainRecordId, String ddpName, String deliveryMethod, Id accountId, Id contactId, Id otherObjectId, List<Id> attachments ) {
        addConfiguration( mainRecordId, ddpName, deliveryMethod, accountId, contactId,
                          null, null, otherObjectId, attachments );
    }

    public void addConfiguration( Id mainRecordId, String ddpName, String deliveryMethod, Id accountId, Id contactId,
                                  Map<String, String> emailToNameForApprover, Map<String, String> emailToNameForCc, Id otherObjectId, List<Id> attachments ){
        if( String.isBlank( mainRecordId ) || String.isBlank( ddpName ) || String.isBlank( deliveryMethod ) ) {
            //Check if required configuration options were set
            return;
        }

        Map<String, String> configuration = new Map<String, String>();
        configuration.put( DDPSender.MAIN_RECORD_ID_OPTION, mainRecordId );
        configuration.put( DDP_NAME_OPTION, ddpName );
        configuration.put( DELIVERY_METHOD_NAME_OPTION, deliveryMethod );
        if( accountId != null ) configuration.put( 'SFAccount', accountId );
        if( contactId != null ) configuration.put( 'SFContact', contactId );
        if( otherObjectId != null ) configuration.put( 'SFOther_Object__c', otherObjectId );
        if( attachments != null ) configuration.put( 'attachIds', String.join( attachments, '|' ) );
        if( emailToNameForApprover != null ) {
            Integer recipientNumber = 1;
            for( String email : emailToNameForApprover.keySet() ) {
                configuration.put( RECIPIENT_PARAMETER_APPROVER_START + String.valueOf( recipientNumber ) + RECIPIENT_PARAMETER_MAIL_END, email );
                configuration.put( RECIPIENT_PARAMETER_APPROVER_START + String.valueOf( recipientNumber ) + RECIPIENT_PARAMETER_NAME_END, emailToNameForApprover.get( email ) );
                recipientNumber++;
            }
        }
        if( emailToNameForCc != null ) {
            Integer recipientNumber = 1;
            for( String email : emailToNameForCc.keySet() ) {
                configuration.put( RECIPIENT_PARAMETER_CC_START + String.valueOf( recipientNumber ) + RECIPIENT_PARAMETER_MAIL_END, email );
                configuration.put( RECIPIENT_PARAMETER_CC_START + String.valueOf( recipientNumber ) + RECIPIENT_PARAMETER_NAME_END, emailToNameForCc.get( email ) );
                recipientNumber++;
            }
        }

        configurationList.add( configuration );
        ddpNames.add( ddpName );
    }

    public void addConfiguration ( Id mainRecordId, String ddpName, Id deliveryMethodId, Id accountId, Id contactId, Id otherObjectId, List<Id> attachments ){
        addConfiguration( mainRecordId, ddpName, String.valueOf( deliveryMethodId ), accountId, contactId, otherObjectId, attachments );
    }

    @TestVisible
    private void prepareRequest() {
        List<Map<String, String>> validConfigurationList = new List<Map<String, String>>();
        Map<String, String> validConfiguration;

        Map<Id, Loop__DDP__c> ddpMap = DDPEmailServices.getDDPMap( ddpNames );
        for( Map<String, String> configuration: configurationList ) {
            String ddpName = configuration.get( DDP_NAME_OPTION );
            String deliveryOptionName = configuration.get( DELIVERY_METHOD_NAME_OPTION );
            Boolean ddpFound = false;

            for( Loop__DDP__c ddp: ddpMap.values() ) {
                if( ddpName == ddp.Name) {
                    for( Loop__DDP_Integration_Option__c integrationOption : ddp.Loop__Custom_Integration_Options__r ) {
                        if( ( deliveryOptionName instanceOf Id && deliveryOptionName == integrationOption.Id ) ||
                            deliveryOptionName == integrationOption.Name ) {
                            configuration.remove( DDP_NAME_OPTION );
                            configuration.remove( DELIVERY_METHOD_NAME_OPTION );
                            configuration.put( 'deploy', integrationOption.Id );
                            configuration.put( DDPSender.DDP_ID_OPTION, ddp.Id );

                            validConfigurationList.add(configuration);
                            ddpFound = true;
                            break;
                        }
                    }
                }
                if( ddpFound ) break;
            }
        }
        configurationList = validConfigurationList;
    }

    public void sendRequest() {
        if( hasConfigurations() ) {
            prepareRequest();
            DDPSender.prepareAndSendRequest( JSON.serialize(configurationList) );
        }
        setupLoopMessenger();
    }

    public void sendRequestsForBatch() {
        prepareRequest();

        Loop.loopMessage lm = new Loop.loopMessage();

        // SESSION ID NEEDED IF IT CANNOT BE DETERMINED FROM UserInfo.getSessionId()
        //lm.sessionId = userInfo.getSessionId();
        for( Map<String, String> configuration: configurationList ){
            String ddpId = configuration.get( DDPSender.DDP_ID_OPTION );
            String mainRecordId = configuration.get( DDPSender.MAIN_RECORD_ID_OPTION );
            configuration.remove( DDPSender.DDP_ID_OPTION );
            configuration.remove( DDPSender.MAIN_RECORD_ID_OPTION );

            // ADD A DDP RUN REQUEST
                lm.requests.add( new Loop.loopMessage.loopMessageRequest (
                    mainRecordId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                    ddpId, // DDP ID
                    configuration
                ) );
        }

        if (String.isEmpty(lm.sessionId)){
            String sessionId = userInfo.getSessionId();
            if(String.isEmpty(sessionId)){
                Site_URL__c site = Site_URL__c.getValues( UserInfo.getOrganizationId().subString(0, 15) );
                if( site != null ) {
                    UsernamePasswordFlow upf = new UsernamePasswordFlow( site.Token_Endpoint__c, site.Login__c, site.Password__c, site.Client_Id__c, site.Client_Secret__c );
                    sessionId = upf.requestAccessToken();
                }
            }
            System.Debug(Logginglevel.ERROR, '^^^ sessionId = ' + sessionId);
            lm.sessionId = sessionId;
        }


        // SEND ALL DDP RUN REQUESTS IN A SINGLE CALLOUT
        if( !Test.isRunningTest() ) lm.sendAllRequests();

        setupLoopMessenger();
    }

}