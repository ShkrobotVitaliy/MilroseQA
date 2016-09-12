global class DDPSender {
    public static String MAIN_RECORD_ID_OPTION = 'mainRecordId';
    public static String DDP_ID_OPTION = 'ddpId';

    WebService static string prepareAndSendRequest( String configurationString ) {
        DDPSender.sendRequests( configurationString, userInfo.getSessionId() );
        ErrorException.addLog( 'DDPSender: DDP ' + String.valueOf(configurationString), 'DDPSender' );
        return 'Your requests are being processed.';
    }
    
    @future(callout=true)
    private static void sendRequests( String configurationString, String sessionId ) {
        //DO NOT PERFORM DML OPERATIONS IN THIS METHOD!!!
        List<Map<String, String>> configurationList = (List<Map<String, String>>)JSON.deserialize(configurationString, List<Map<String, String>>.class);
        Loop.loopMessage lm = new Loop.loopMessage();
        
        // SESSION ID NEEDED IF IT CANNOT BE DETERMINED FROM UserInfo.getSessionId()
        if( sessionId != null ){
            lm.sessionId = sessionId;
        } else {
            Site_URL__c site = Site_URL__c.getValues( UserInfo.getOrganizationId().subString(0, 15) );
            if( site != null ) {
                UsernamePasswordFlow upf = new UsernamePasswordFlow( site.Token_Endpoint__c, site.Login__c, site.Password__c, site.Client_Id__c, site.Client_Secret__c );
                String newSessionId = upf.requestAccessToken();
                System.debug( Logginglevel.Error, 'Session Id: ' + newSessionId );
                lm.sessionId = newSessionId;
            } else {
                System.debug( Logginglevel.Error, 'The system can not find the Site_URL__c Custom Settings record for ' + UserInfo.getOrganizationId().subString(0, 15) + ' organization!' );
            }
        }
        
        for( Map<String, String> configuration: configurationList ){
            String ddpId = configuration.get(DDP_ID_OPTION);
            String mainRecordId = configuration.get(MAIN_RECORD_ID_OPTION);
            configuration.remove(DDP_ID_OPTION);
            configuration.remove(MAIN_RECORD_ID_OPTION);


            // ADD A DDP RUN REQUEST
                lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                    mainRecordId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                    ddpId, // DDP ID
                    configuration
                ));
        }
        
        // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
        if (!Test.isRunningTest()) lm.sendAllRequests();
    }
}