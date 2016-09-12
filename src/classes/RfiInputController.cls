public with sharing class RfiInputController {
    private static final String NO_SCOPES_MESSAGE     = 'This one-time use Milrose RFI Link has already been accessed. If you need to supply more information, please contact your Milrose Project Manager and request a new RFI Link.';
    private static final String EXPIRATION_VALIDATION = 'This link has expired. Please contact your project manager.';
    private static final String REVIEW_ALL_SCOPES     = 'Please note that there are multiple RFI sections on the left that should be filled out.';
    private static final String SUBMIT_ERROR          = 'Oops! Something went very wrong. The data you\'ve posted was not sumbitted successfully. Please contact your representative or try to resubmit again.';
    private static final String ALREADY_SUBMITTED     = 'You can not submit this information since you have already done this.';
    private static final String ERROR                 = 'Error';
    private static final String INFO                  = 'INFO';

    private final String urikey;
    private final String publishType;

    private Id projectId;
    private Set<Id> rfiScopeIds = new Set<Id>();

    private Set<String> visitedScopeIds {
        get {
            if( null == this.visitedScopeIds ) {
                this.visitedScopeIds = new Set<String>();
            }
            return this.visitedScopeIds;
        }
        set;
    }

    public transient Map<Id, Boolean> scopeIdToIsVisited;
    public Map<Id, Boolean> getScopeIdToIsVisited() {
        Map<Id, Boolean> scopeIdToIsVisitedMap = new Map<Id, Boolean>();
        for( RFI_Scope__c scope : orderRFIScopesList ) {
            scopeIdToIsVisitedMap.put( scope.Id, visitedScopeIds.contains( scope.Id ) ? true : false );
        }
        return scopeIdToIsVisitedMap;
    }

    public String currentRFIScope { get; set; }

    public Boolean isApplication {
        get {
            return RFIScopeServices.APPLICATION_TYPE == this.publishType; 
        }
        private set;
    }

    public Boolean isSignOff {
        get {
            return RFIScopeServices.SIGN_OFF_TYPE == this.publishType; 
        }
        private set;
    }

    public Project_Profile__c project { 
        get { 
            if( null == this.project ) { 
                this.project = ProjectProfileServices.getProjectById( this.projectId );
            }
            return this.project; 
        } 
        private set; 
    }

    public Boolean isValid { 
        get { 
            if( null == this.isValid ) { 
                this.isValid = false; 
            }
            return this.isValid; 
        } 
        private set; 
    }

    public Boolean isSubmitted { 
        get { 
            if( null == this.isSubmitted ) { 
                this.isSubmitted = false; 
            }
            return this.isSubmitted; 
        } 
        private set; 
    }

    public List<RFI_Scope__c> orderRFIScopesList {
        get {
            if( null == this.orderRFIScopesList ) {
                this.orderRFIScopesList = RFIScopeServices.getRFIScopesSiteOrderedByGroupNumber( this.rfiScopeIds );
            }
            return this.orderRFIScopesList;
        }
        private set;
    }

    public RfiInputController() {
        this.urikey      = ApexPages.currentPage().getParameters().get('u');
        this.publishType = ApexPages.currentPage().getParameters().get('type');
    }

    public RFI_Scope__c getRFIScope() {
        if( null != RFISingletonInstance.INSTANCE.rfiScope) {
            this.additionalRFIScopeMap.put( RFISingletonInstance.INSTANCE.rfiScope.Id, RFISingletonInstance.INSTANCE.rfiScope );
        }
        if( !String.isBlank( this.currentRFIScope ) ) {
            if( this.additionalRFIScopeMap.containsKey( this.currentRFIScope ) ) {
                RFISingletonInstance.INSTANCE.rfiScope = this.additionalRFIScopeMap.get( this.currentRFIScope );
            } else {
                RFISingletonInstance.INSTANCE.rfiScope = getScopes().get( this.currentRFIScope );
            }
        }
        return RFISingletonInstance.INSTANCE.rfiScope;
    }

    private Map<Id, RFI_Scope__c> additionalRFIScopeMap {
        get {
            if( null == this.additionalRFIScopeMap ) {
                this.additionalRFIScopeMap = new Map<Id, RFI_Scope__c>();
            }
            return this.additionalRFIScopeMap;
        }
        set;
    }

    public PageReference autorun() {
        if( String.isBlank( this.urikey ) ) {
            setMessage( NO_SCOPES_MESSAGE, ERROR );
            return null;
        }

        if( MonitorRFIScopeServices.isNotValidLink( this.urikey ) ) {
            setMessage( EXPIRATION_VALIDATION, ERROR );
            return null;
        }

        try {
            List<Monitor_RFI_Scope__c> unlockedRFIs = MonitorRFIScopeServices.getUnlockedRFIMonitorByUniqeKey( this.urikey );
            if( null == unlockedRFIs || unlockedRFIs.isEmpty() ) {
                setMessage( NO_SCOPES_MESSAGE, INFO );
                return null;
            }

            for( Monitor_RFI_Scope__c track : unlockedRFIs ) {
                rfiScopeIds.add( track.RFI_Scope__c );
            }

            this.projectId = unlockedRFIs.get(0).RFI_Scope__r.Project__c;

            if( getScopes().values().isEmpty() ) {
                setMessage( NO_SCOPES_MESSAGE, INFO );
                return null;
            }

            this.currentRFIScope = this.orderRFIScopesList.get(0).Id;

            this.visitedScopeIds.add( this.currentRFIScope );

            this.isValid = true;
            this.isSubmitted = false;
            return null;
        } catch( Exception ex ) {
            setMessage( ex.getMessage(), ERROR );
            return null;
        }
    }
    
    public void saveScope() {
        //Save last changes
        if( null != RFISingletonInstance.INSTANCE.rfiScope ) {
            this.additionalRFIScopeMap.put( RFISingletonInstance.INSTANCE.rfiScope.Id, RFISingletonInstance.INSTANCE.rfiScope );
        }

        //allowing to save scopes which were partially reviewed
        /*if( this.visitedScopeIds.size() != this.orderRFIScopesList.size() ) {
            setMessage( REVIEW_ALL_SCOPES, INFO );
            return;
        }*/

        if( this.isSubmitted ) {
            setMessage( ALREADY_SUBMITTED, INFO );
            return;
        }

        this.isSubmitted = true;

        //List<RFI_Scope_Description_New_York__c> descriptions = new List<RFI_Scope_Description_New_York__c>();
        List<sObject> descriptions = new List<sObject>();
        List<Monitor_RFI_Scope__c> monitoringRFI = new List<Monitor_RFI_Scope__c>();
        List<RFI_Work__c> workTypeItems = new List<RFI_Work__c>();

        Datetime receivedTime;
        for( RFI_Scope__c scopeItem : this.additionalRFIScopeMap.values() ) {
            receivedTime = datetime.now();

            if( this.isApplication ) {
                scopeItem.Submit_Application__c = false;
                scopeItem.Last_RFI_Received__c  = receivedTime;
                scopeItem.App_Status__c         = 'Received';
                scopeItem.Status__c             = 'Received';
            } else if( this.isSignOff ) {
                scopeItem.Submit_Sign_Off__c           = false;
                scopeItem.Last_SignOff_RFI_Received__c = receivedTime;
                scopeItem.Sign_Off_Status__c           = 'Received';
                scopeItem.Status__c                    = 'Received';
            }

            if( null != scopeItem.RFI_Scope_Description_New_York__r ) {
                descriptions.add(scopeItem.RFI_Scope_Description_New_York__r );
            }

            if( null != scopeItem.RFI_Scope_Description_Long_Island__r ) {
                descriptions.add( scopeItem.RFI_Scope_Description_Long_Island__r );
            }

            if( null != scopeItem.RFI_Scope_Description_New_Jersey__r ) {
                descriptions.add( scopeItem.RFI_Scope_Description_New_Jersey__r );
            }

            if( null != scopeItem.RFI_Scope_Description_CT__r ) {
                descriptions.add( scopeItem.RFI_Scope_Description_CT__r );
            }

            if( null != scopeItem.RFI_Scope_Description_PA__r ) {
                UPDATE scopeItem.RFI_Scope_Description_PA__r;
            }

            if( null != scopeItem.RFI_Scope_Description_DC__r ) {
                UPDATE scopeItem.RFI_Scope_Description_DC__r;
            }

            //Update monitoring items
            if( null != scopeItem.Monitor_RFI_Scopes__r && !scopeItem.Monitor_RFI_Scopes__r.isEmpty() ) {
                scopeItem.Monitor_RFI_Scopes__r.get(0).Received__c = receivedTime;
                scopeItem.Monitor_RFI_Scopes__r.get(0).Send_Via__c = 'Web';
                //scopeItem.Monitor_RFI_Scopes__r.get(0).Is_Lock__c  = true; //MRS-6516

                monitoringRFI.add( scopeItem.Monitor_RFI_Scopes__r.get(0) );
            }

            //Update work type
            if( null != scopeItem.RFI_Work_Types__r && !scopeItem.RFI_Work_Types__r.isEmpty() ) {
                workTypeItems.addall( scopeItem.RFI_Work_Types__r );
            }
        }

        Savepoint sp = Database.setSavepoint();
        try {
            this.additionalRFIScopeMap.remove( null );
        
            UPDATE this.additionalRFIScopeMap.values();
            UPDATE monitoringRFI;
            UPDATE workTypeItems;
            UPDATE descriptions;

            sendReminder();
        } catch( exception Ex ) {
            system.debug( ex.getMessage() );
            this.isSubmitted = false;
            Database.rollback(sp);
            setMessage( SUBMIT_ERROR, ERROR );
            return;
        }
    }

    public void sendReminder() {
        if( !String.isEmpty( RFISingletonInstance.INSTANCE.rfiScope.Email_Address_For_Submit_Notification__c ) ) {
            String[] address = new List<String>();

            //for (String emailAddress : RFISingletonInstance.INSTANCE.rfiScopesMap.values().get(0).Email_Address_For_Submit_Notification__c.split(';')) {
            for( String emailAddress : RFISingletonInstance.INSTANCE.rfiScope.Email_Address_For_Submit_Notification__c.split(';') ) {
                address.add( emailAddress );
            }
            String firstPart = URL.getSalesforceBaseUrl().toExternalForm().substring( URL.getSalesforceBaseUrl().toExternalForm().indexOf('.') + 1, URL.getSalesforceBaseUrl().toExternalForm().length() );
            String instanceName = firstPart.subString( 0, firstPart.indexOf('.') );
            
            if( 'force' == instanceName ) {
                instanceName = 'na7';
            }

            EmailMessageService.sendSingleMailToDistribution( address, new String[] {} , this.project.Name + ' RFI section submitted', 
                                                              '<html><header></header><body>' + 
                                                              '<a href="' +  instanceName + '.salesforce.com/' + this.project.Id + '">' + this.project.Name + '</a>' +
                                                              ' <br/> ' + this.project.Project_Name__c + ' <br/> ' +
                                                              //this.project.Building__r.Name + ' <br/> ' + this.project.Floor_s__c + ' <br/> Recipient ' + RFISingletonInstance.INSTANCE.rfiScopesMap.values().get(0).Project_Roster__r.Contact_Full_Name__c + ' has submitted RFI. Please check.</body></html>' + 
                                                              this.project.Building__r.Name + ' <br/> ' + this.project.Floor_s__c + ' <br/> Recipient ' + RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__r.Contact_Full_Name__c + ' has submitted RFI. Please check.</body></html>' + 
                                                              ' <br/> ' + MergeEmailTemplate.legalFooter() );
        }
    }

    public void selectRFIScope() {
        if( !String.isBlank( this.currentRFIScope ) ) {
            this.visitedScopeIds.add( this.currentRFIScope );
        }
    }

    private void setMessage(String message, String type ) {
        if( type == ERROR ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, message ) );
            return;
        }
        if( type == INFO ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Info, message ) );
            return;
        }
    }

    private Map<Id, RFI_Scope__c> getScopes() {
         if( null == RFISingletonInstance.INSTANCE.rfiScopesMap || RFISingletonInstance.INSTANCE.rfiScopesMap.isEmpty() ) {
            for( RFI_Scope__c rfi : RFIScopeServices.getProjectRFIScopesByProjectIdAndRosterId(this.rfiScopeIds, this.urikey, this.project.Building__r.Municipality__r.Region__r.Name ) ) {
                if( !RFISingletonInstance.INSTANCE.rfiScopesMap.containsKey( rfi.Id ) ) {
                    RFISingletonInstance.INSTANCE.rfiScopesMap.put( rfi.Id, rfi );
                }
            }
        }
        return RFISingletonInstance.INSTANCE.rfiScopesMap;
    }

}