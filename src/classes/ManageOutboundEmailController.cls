public with sharing class ManageOutboundEmailController {
    public final String projectId { get; set; }
    @TestVisible private final String submitType { get; set; }

    private List<RFI_Scope__c> rfiScopes;
    private static Map<String, List<RFI_Scope__c>> contactToRFIScopes;

    private String projectKey;
    private String rosterKey;

    private String emailsToDDP { get; set; }

    @TestVisible
    private Map<Id, List<RFI_Scope__c>> rosterIdToRFIScopes {
        get {
            if( null == this.rosterIdToRFIScopes ) {
                getRosterIdToScopes();
            }
            return this.rosterIdToRFIScopes;
        }
        set;
    }

    public String emailTemplateName {
        get {
            //KDI 23.10.2015 - more readable code is here:
            Map<String, Map<String, String>> typeToRegionNameToTemplateName = new Map<String, Map<String, String>>{
                RFIScopeServices.SIGN_OFF_TYPE => new Map<String, String>{
                                                      RegionServices.REGION_NAME_NY   => RFIScopeServices.EMAIL_TEMPLATE_NEW_YORK_SIGN_OFF,
                                                      RegionServices.REGION_NAME_NJ   => RFIScopeServices.EMAIL_TEMPLATE_RFI_NEW_JERSEY_SIGN_OFF,
                                                      RegionServices.REGION_NAME_PHILADELPHIA => RFIScopeServices.EMAIL_TEMPLATE_RFI_PHILADELPHIA_SIGN_OFF,
                                                      RegionServices.REGION_NAME_PENN => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF,
                                                      RegionServices.REGION_NAME_WASH => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF,
                                                      RegionServices.REGION_NAME_MD   => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF,
                                                      RegionServices.REGION_NAME_DE   => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF,
                                                      RegionServices.REGION_NAME_LI   => RFIScopeServices.EMAIL_TEMPLATE_RFI_LONG_ISLAND_SIGN_OFF,
                                                      RegionServices.REGION_NAME_CT   => RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_SIGN_OFF,
                                                      RegionServices.REGION_NAME_WESTCHESTER => RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_SIGN_OFF },
                RFIScopeServices.APPLICATION_TYPE => new Map<String, String>{
                                                      RegionServices.REGION_NAME_NY   => RFIScopeServices.EMAIL_TEMPLATE_NEW_YORK_APP,
                                                      RegionServices.REGION_NAME_NJ   => RFIScopeServices.EMAIL_TEMPLATE_RFI_NEW_JERSEY_APP,
                                                      RegionServices.REGION_NAME_PHILADELPHIA => RFIScopeServices.EMAIL_TEMPLATE_RFI_PHILADELPHIA_APP,
                                                      RegionServices.REGION_NAME_PENN => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP,
                                                      RegionServices.REGION_NAME_WASH => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP,
                                                      RegionServices.REGION_NAME_MD   => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP,
                                                      RegionServices.REGION_NAME_DE   => RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP,
                                                      RegionServices.REGION_NAME_LI   => RFIScopeServices.EMAIL_TEMPLATE_RFI_LONG_ISLAND_APP,
                                                      RegionServices.REGION_NAME_CT   => RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_APP,
                                                      RegionServices.REGION_NAME_WESTCHESTER => RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_APP } };
            if( typeToRegionNameToTemplateName.get( this.submitType ) != null ) {
                if( typeToRegionNameToTemplateName.get( this.submitType ).get( this.project.Building__r.Municipality__r.Region__r.Name ) != null ) {
                    return typeToRegionNameToTemplateName.get( this.submitType ).get( this.project.Building__r.Municipality__r.Region__r.Name );
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format('System can not find RFI email template for combination of region {0} and submit type {1}!', new String[]{ this.project.Building__r.Municipality__r.Region__r.Name, this.submitType })));
                }
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please provide submit type!'));
            }
            return null;

            /*if(this.submitType.equals(RFIScopeServices.SIGN_OFF_TYPE)) {
                if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_NY ){
                    return RFIScopeServices.EMAIL_TEMPLATE_NEW_YORK_SIGN_OFF;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_NJ ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_NEW_JERSEY_SIGN_OFF;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_PHILADELPHIA ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_PHILADELPHIA_SIGN_OFF;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_PENN ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_WASH ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_MD ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_DE){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_LI ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_LONG_ISLAND_SIGN_OFF;
                }
                else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_CT ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_WESTCHESTER ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_SIGN_OFF;
                }
            }else if(this.submitType.equals(RFIScopeServices.APPLICATION_TYPE)) {
                if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_NY ){
                    return RFIScopeServices.EMAIL_TEMPLATE_NEW_YORK_APP;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_NJ ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_NEW_JERSEY_APP;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_PHILADELPHIA ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_PHILADELPHIA_APP;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_PENN ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_WASH ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_MD ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_DE){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP;
                }else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_LI ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_LONG_ISLAND_APP;
                }
                else if( this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_CT ||
                  this.project.Building__r.Municipality__r.Region__r.Name == RegionServices.REGION_NAME_WESTCHESTER ){
                    return RFIScopeServices.EMAIL_TEMPLATE_RFI_CONNECTICUT_APP;
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please provide submit type!'));
                return null;
            }

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, string.format('System can not find RFI email template for combination of region {0} and submit type {1}!', new String[]{ this.project.Building__r.Municipality__r.Region__r.Name, this.submitType })));
            return null;*/
        }
        set;
    }

    public String draftTemplateName {
        get {
            return RFIScopeServices.EMAIL_TEMPLATE_DRAFT_NAME;
        }
        set;
    }

    public String drawloopName {
        get {
            return DDPEmailServices.DDP_NAME_SEND_ATTACHMENT_PROJECT;
        }
        set;
    }

    @TestVisible private Site_URL__c site {
        get {
            if (null == this.site) {
                try {
                    this.site = Site_URL__c.getValues(UserInfo.getOrganizationId().subString(0, 15));

                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sorry, system cannot find current URL!'));
                    return null;
                }
            }
            return this.site;
        }
        set;
    }

    public String linkToSite {
        get {
            return '<a href="' + this.site.URL__c + '?u=' + this.keyMonitor + '&type=' + this.submitType + '">LINK TO RFI FORM</a>';
        }
        set;
    }

    public Project_Profile__c project {
        get {
            if (null == this.project) {
                this.project = ProjectProfileServices.getProjectById(this.projectId);

            }
            return this.project;
        }
        set;
    }

    public Contact contactRecipient {
        get {
            Map<String, List<RFI_Scope__c>> contactToRFIs = getContactToRFIScopes();

            if( contactToRFIs.get( this.sendToName ) != null && !contactToRFIs.get( this.sendToName ).isEmpty() ) {
                Id contactId          = contactToRFIs.get(this.sendToName)[0].Project_Roster__r.Contact__c;
                this.contactRecipient = (null != contactId) ? ContactServices.getContactsByIds(new Set<Id> { contactId })[0] : new Contact();
            } else {
                this.contactRecipient = new Contact();
            }
            return this.contactRecipient;
        }
        set;
    }

    @TestVisible private Set<Id> serviceItemIds {
        get {
            if (null == this.serviceItemIds) {
                this.serviceItemIds = ServiceItemServices.getServiceItemIdsByProjectId(this.projectId);
            }
            return this.serviceItemIds;
        }
        set;
    }

    @TestVisible private Set<Id> taskItemIds {
        get {
            if (null == this.taskItemIds) {
                this.taskItemIds = TaskItemServices.getTaskItemIdsByProjectId(this.projectId);
            }
            return this.taskItemIds;
        }
        set;
    }

    public Boolean reviewEmail { get; set;}
    public String sendToName { get; set; }
    public String sendToFullName { get; set; }
    public String sendToId { get; set; }
    public String emailsAddressForDrawLoop { get; set; }
    public Map<String, ProjectRosterWrapper> rostersToCC;

    public String contactEmail {
        get {
            for (RFI_Scope__c rfi : getRFIScopes()) {
                if (this.sendToName.equals(rfi.Project_Roster__r.Name__c)) {
                    return rfi.Project_Roster__r.Email__c;
                }
            }
            return '';
        }
        set;
    }

    public String loggedUserName {
        get {
            return UserInfo.getName();
        }
        set;
    }

    public String rfiEmailType {
        get {
            return MergeEmailTemplate.RFI_EMAIL;
        }
        private set;
    }

    public String linkToCloseTemplate { get; private set; }

    public ManageOutboundEmailController(ApexPages.StandardController controller) {
        this.projectId  = ApexPages.currentPage().getParameters().get('projectId');
        this.submitType = ApexPages.currentPage().getParameters().get('type');

        this.reviewEmail = false;
        this.linkToCloseTemplate = URL.getCurrentRequestUrl().toExternalForm();
    }

    public void clearEmailAddress() {
        try {
            this.project.EmailToRfi__c   = '';
            this.project.EmailToCCRfi__c = '';

            update this.project;
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }
    }

    @TestVisible private List<RFI_Scope__c> getRFIScopes() {
        if (null == this.rfiScopes) {
            this.rfiScopes = new List<RFI_Scope__c>();

            if (this.submitType.equals(RFIScopeServices.SIGN_OFF_TYPE)) {
                this.rfiScopes = RFIScopeServices.getSignOfSubmittedRFIScopesByProjectId(this.projectId);
            } else if (this.submitType.equals(RFIScopeServices.APPLICATION_TYPE)) {
                this.rfiScopes = RFIScopeServices.getApplicationSubmittedRFIScopesByProjectId(this.projectId);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You have not chosen Publishing type!'));
            }
        }
        return this.rfiScopes;
    }

    public Map<Id, List<RFI_Scope__c>> getRosterIdToScopes() {
        this.rosterIdToRFIScopes = new Map<Id, List<RFI_Scope__c>>();

        for( RFI_Scope__c rfi : getRFIScopes() ) {
            if( rfi.Project_Roster__c != null ){
		    if( !this.rosterIdToRFIScopes.containsKey( rfi.Project_Roster__c ) ) {
	                this.rosterIdToRFIScopes.put( rfi.Project_Roster__c, new List<RFI_Scope__c>() );
	            }
	            this.rosterIdToRFIScopes.get( rfi.Project_Roster__c ).add( rfi );
	    }
        }
        return this.rosterIdToRFIScopes;
    }

    public Map<Id, Project_Roster__c> getRosterIdToRoster() {
        Map<Id, Project_Roster__c> rosterIdToRosterMap = new Map<Id, Project_Roster__c>();

        for( RFI_Scope__c rfi : getRFIScopes() ) {
            if( !rosterIdToRosterMap.containsKey( rfi.Project_Roster__c ) ) {
                rosterIdToRosterMap.put( rfi.Project_Roster__c, null );
            }
            rosterIdToRosterMap = new Map<Id, Project_Roster__c>( [ SELECT Id, Name__c, Name_Full__c FROM Project_Roster__c WHERE Id IN : rosterIdToRosterMap.keySet() ] );
        }
        return rosterIdToRosterMap;
    }

    public PageReference backToProject() {
        PageReference page = new PageReference('/' + this.projectId);
        page.setRedirect(true);
        return page;
    }

    @TestVisible
    private String keyMonitor {
        get {
            if (null == this.keyMonitor) {
                this.keyMonitor = MilroseDevHelper.getUniqueKey();
            }
            return this.keyMonitor;
        }
        set;
    }

    @TestVisible private List<Monitor_RFI_Scope__c> monitoringList { get; set; }

    public String additionalSubject { get; set; }

    public void showReviewEmail() {
        if (null == contactRecipient.Id) {
            return;
        }

        this.reviewEmail = true;
        this.additionalSubject = '';

        this.monitoringList = new List<Monitor_RFI_Scope__c>();
        Map<String, List<RFI_Scope__c>> contactToRFIs = getContactToRFIScopes();

        for (RFI_Scope__c rfi : contactToRFIs.get(this.sendToName)) {
            this.additionalSubject += rfi.Id + ';';
            this.monitoringList.add(MonitorRFIScopeServices.newInstance(this.sendToName, rfi.Id, this.keyMonitor, this.submitType, rfi.Project_Roster__c, this.site.URL__c + '?u=' + this.keyMonitor + '&type=' + this.submitType));
        }
    }

    public void onCompleteReview() {
        if (null == this.contactRecipient.Id) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
            return;
        }
    }

    //Callback Action: save CC Emails Address
    public void updateCCEmailsAddressForDrawLoop () {
        try {
            this.project.EmailToCCRfi__c = this.emailsAddressForDrawLoop;
            update this.project;
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }
    }

    public Datetime reminderDatetime { get; set; }

    //Callback Action: update record
    public PageReference  updateAfterSend() {
        PageReference pref = new PageReference('/' + this.projectId);
        pref.setRedirect(true);
        try {
            createTrackingRFIScope();
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return pref;
        }
        return pref;
    }

    public String usedEmailTemplateId { get; set; }

    @TestVisible private void createTrackingRFIScope() {
        if (monitoringList.isEmpty()) {
            return;
        }

        List<RFI_Scope__c> rfiScopes = new List<RFI_Scope__c>();
        Map<String, List<RFI_Scope__c>> contactToRFIs = getContactToRFIScopes();

        Id contactId;
        Id userId;

        for (RFI_Scope__c rfi : contactToRFIs.get(this.sendToName)) {
            contactId = rfi.Project_Roster__r.Contact__c;
            userId = rfi.Project_Roster__r.User__c;

            if (RFIScopeServices.APPLICATION_TYPE == this.submitType) {
                rfi.Last_RFI_Sent__c      = this.monitoringList.get(0).Sent__c;
                rfi.Last_RFI_Received__c  = null;
                rfi.Submit_Application__c = false;
                rfi.App_Status__c         = 'Sent';
            } else if (RFIScopeServices.SIGN_OFF_TYPE == this.submitType) {
                rfi.Last_SignOff_RFI_Sent__c     = this.monitoringList.get(0).Sent__c;
                rfi.Last_SignOff_RFI_Received__c = null;
                rfi.Submit_Sign_Off__c           = false;
                rfi.Sign_Off_Status__c           = 'Sent';
            }
            rfi.Status__c = 'Sent';

            //Fill in Email address from Project Assignment section
            rfi.Email_Address_For_Submit_Notification__c = '';

            if (null == this.project.Project_Team__c) {
                if (null != this.project.Project_Member__c && null != this.project.Project_Member__r.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Project_Member__r.Email + ';';
                }

                if (null != this.project.Project_Manager__c && null != this.project.Project_Manager__r.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Project_Manager__r.Email + ';';
                }

                if (null != this.project.Owner.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Owner.Email + ';';
                }
            } else {
                if (null != this.project.Project_Team__r.Project_Member__c && null != this.project.Project_Team__r.Project_Member__r.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Project_Team__r.Project_Member__r.Email + ';';
                }

                if (null != this.project.Project_Team__r.Project_Manager__c && null != this.project.Project_Team__r.Project_Manager__r.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Project_Team__r.Project_Manager__r.Email + ';';
                }

                if (null != this.project.Project_Team__r.Owner.Email) {
                    rfi.Email_Address_For_Submit_Notification__c += this.project.Project_Team__r.Owner.Email + ';';
                }
            }
            rfiScopes.add(rfi);
        }

        //Customize Email Alert Reminder
        this.monitoringList.get(0).Send_Reminder__c = true;
        this.monitoringList.get(0).Reminder_Date__c = this.reminderDatetime;

        if (null != userId) {
            this.monitoringList.get(0).User__c = userId;
        } else if (null != contactId) {
            this.monitoringList.get(0).Contact__c = contactId;
        }

        fillCCEmailAddress(this.monitoringList.get(0), this.emailsAddressForDrawLoop);
        EmailTemplate emailTemplateDraft = EmailMessageService.getEmailTemplateById(usedEmailTemplateId);
        this.monitoringList.get(0).Reminder_Subject__c = emailTemplateDraft.Subject;
        this.monitoringList.get(0).Reminder_Body__c    = emailTemplateDraft.Body;

        Savepoint sp = Database.setSavepoint();
        try {
            update rfiScopes;
            insert this.monitoringList;
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new ErrorException('Exception occured during insert monitoring elements: ' + ex.getMessage());
        }
    }

    @TestVisible
    private void fillCCEmailAddress(Monitor_RFI_Scope__c monitorRFI, String emailAddress) {
        if (String.isBlank(emailAddress)) {
            return;
        }

        Integer index = 0;
        for (String email : emailAddress.split(';')) {
            if (0 == index) {
                monitorRFI.Email_Address_CC1__c = email;
            } else if (1 == index) {
                monitorRFI.Email_Address_CC2__c = email;
            } else if (2 == index) {
                monitorRFI.Email_Address_CC3__c = email;
            } else if (3 == index) {
                monitorRFI.Email_Address_CC4__c = email;
            } else if (4 == index) {
                monitorRFI.Email_Address_CC5__c = email;
            }
            index++;
        }
    }

    @TestVisible
    private Map<String, List<RFI_Scope__c>> getContactToRFIScopes() {
        contactToRFIScopes = new Map<String, List<RFI_Scope__c>>();

        if (this.submitType.equals(RFIScopeServices.SIGN_OFF_TYPE)) {
            for (RFI_Scope__c rfi : RFIScopeServices.getSignOfSubmittedRFIScopesByProjectId(this.projectId)) {
                if (!contactToRFIScopes.containsKey(rfi.Project_Roster__r.Name__c)) {
                    contactToRFIScopes.put(rfi.Project_Roster__r.Name__c, new List<RFI_Scope__c>());
                }
                contactToRFIScopes.get(rfi.Project_Roster__r.Name__c).add(rfi);
            }
        } else if (this.submitType.equals(RFIScopeServices.APPLICATION_TYPE)) {
            for (RFI_Scope__c rfi : RFIScopeServices.getApplicationSubmittedRFIScopesByProjectId(this.projectId)) {
                if (!contactToRFIScopes.containsKey(rfi.Project_Roster__r.Name__c)) {
                    contactToRFIScopes.put(rfi.Project_Roster__r.Name__c, new List<RFI_Scope__c>());
                }
                contactToRFIScopes.get(rfi.Project_Roster__r.Name__c).add(rfi);
            }
        }
        return contactToRFIScopes;
    }

    //------------------------------ Begin Attach Document(s) to Email ------------------------------//
    public List<Id> parentDocumentIds {
        get {
            if (null == this.parentDocumentIds) {
                this.parentDocumentIds = new List<Id>();

                this.parentDocumentIds.add(this.projectId);

                if (this.rosterIdToRFIScopes.containsKey(sendToId)) {
                    for (RFI_Scope__c rfi : this.rosterIdToRFIScopes.get(sendToId)) {
                        this.parentDocumentIds.add(rfi.Proposal_Id__c);
                    }
                }

                if (this.rosterIdToRFIScopes.containsKey(sendToId)) {
                    for (RFI_Scope__c rfi : this.rosterIdToRFIScopes.get(sendToId)) {
                        this.parentDocumentIds.add(rfi.Id);
                    }
                }

                for (Id serviceItemId : this.serviceItemIds) {
                    this.parentDocumentIds.add(serviceItemId);
                }

                for (Id taskItemId : this.taskItemIds) {
                    this.parentDocumentIds.add(taskItemId);
                }

            }
            return this.parentDocumentIds;
        }
        set;
    }
    //------------------------------ End Attach Document(s) to Email ------------------------------//

}