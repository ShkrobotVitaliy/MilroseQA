public with sharing class PreviewAndSendEmailController{
    @TestVisible private String ATTACHED_DOCUMENTS_MESSAGE = '<br/><br/><br/>' + Label.Find_Attached_Documents_Message + '<br/>';
    @TestVisible private List<String> documentsExternalURL;
    @TestVisible private Map<String, String> documentNameToExternalURLMap;

    /* -------------------------- Begin Component Parameters ----------------------------------------- */
    private String parentRecordId;
    private String ddpName;
    private String emailTemplateName;
    private String draftTemplateName;
    private String sendTo;
    private String sendToFullName;
    private String sendFrom;
    private String attachmentParentIds;
    private String emailType;
    private String linkForRFI;
    private String additionalSubject;
    private String additionalBody;
    private String linkToClose;
    @TestVisible
    private Boolean showReminders;
    private Project_Profile__c project;
    private Task_Item__c taskItem;
    private List<Id> attachmentIds;
    private Contact toContact;
    private Boolean allowSendForClosedProject;
    private Boolean isEntityLevel;//MRS-4835
    private List<String> sentEmailBody;//MRS-7494

    public Boolean getAllowSendForClosedProject() { if ( this.allowSendForClosedProject == null ) { this.allowSendForClosedProject = false; } return this.allowSendForClosedProject; }
    public void setAllowSendForClosedProject(Boolean allowSendForClosedProject) { this.allowSendForClosedProject = allowSendForClosedProject; }
    public Boolean getisEntityLevel() { if ( this.isEntityLevel == null ) { this.isEntityLevel = false; } return this.isEntityLevel; }//MRS-4835
    public void setisEntityLevel(Boolean isEntityLevel) { this.isEntityLevel = isEntityLevel; }

    public Boolean allowSendingEmail{
        get{
            if( allowSendingEmail == null ) {
                if ( getAllowSendForClosedProject() ){
                    allowSendingEmail = true;
                } else {
                    allowSendingEmail = this.project.Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED && this.project.Project_State__c != ProjectProfileServices.PROJECT_STATE_ON_HOLD; //MRS-6683
                }
            }
            if ( !allowSendingEmail ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ' You can not send Email if Project State is "Closed" or "On Hold" ' ) ); }
            return allowSendingEmail;
        }
        set{}
    }

    public Boolean showRedirect { get { return !String.isBlank(getLinkToClose()); } private set; }
    public String getLinkToClose() { return this.linkToClose; }
    public void setLinkToClose(String linkToClose) { this.linkToClose = linkToClose; }
    public String getAdditionalSubject() { return this.additionalSubject; }
    public void setAdditionalSubject(String additionalSubject) { this.additionalSubject = additionalSubject; }
    public String getAdditionalBody() { return this.additionalBody; }
    public void setAdditionalBody(String additionalBody) { this.additionalBody = additionalBody; }
    public String getLinkForRFI() { return this.linkForRFI; }
    public void setLinkForRFI(String linkForRFI) { this.linkForRFI = linkForRFI; }
    public String getEmailType() { return this.emailType; }
    public void setEmailType(String emailType) { this.emailType = emailType; }
    public String getParentRecordId() { return this.parentRecordId; }
    public void setParentRecordId (String parentRecordId) { this.parentRecordId = parentRecordId; }
    public Boolean getShowReminders() { return this.showReminders; }
    public void setShowReminders(Boolean showReminder) { this.showReminders = showReminder; }
    public Task_Item__c getTaskItem() { if (null == this.taskItem) { this.taskItem = new Task_Item__c(); } return this.taskItem; }
    public void setTaskItem (Task_Item__c taskItemRec) { if (null == taskItemRec) { return; } this.taskItem = taskItemRec; }
    public Project_Profile__c getProject() { if (null == this.project) { this.project = new Project_Profile__c(); } return this.project; }
    public void setProject(Project_Profile__c projectItem) { if (null == projectItem) { return; } this.project = projectItem; }
    public Contact getToContact() { if (null == this.toContact) { this.toContact = new Contact(); } return this.toContact; }
    public void setToContact(Contact toContact) { if (null == toContact) { return; } this.toContact = toContact; }
    public String getDDPName() { return this.ddpName; }
    public void setDDPName (String ddpName) { this.ddpName = ddpName; }
    public String getSendTo() { return this.sendTo; }
    public void setSendTo (String sendTo) { this.sendTo = sendTo; }
    public String getSendToFullName() { return this.sendToFullName; }
    public void setSendToFullName (String sendToFullName) { this.sendToFullName = sendToFullName; }
    public String getSendFrom() { return this.sendFrom; }
    public void setSendFrom ( String sendFrom ) { this.sendFrom = sendFrom; }
    public String getEmailTemplateName() { return String.isBlank(emailTemplateNameFromSearch) ? this.emailTemplateName : emailTemplateNameFromSearch; }
    public void setEmailTemplateName(String emailTemplateName) { this.emailTemplateName = emailTemplateName; }
    public String getDraftTemplateName() { return this.draftTemplateName; }
    public void setDraftTemplateName(String draftTemplateName) { this.draftTemplateName = draftTemplateName; }
    public void setAttachmentIds(List<Id> attachtIds) { this.attachmentIds = new List<Id>(); if (null == attachtIds) { return; } this.attachmentIds.addall(attachtIds); }
    public List<Id> getAttachmentIds() { if (null == this.attachmentIds) { this.attachmentIds = new List<Id>(); } return this.attachmentIds; }
    public Boolean emptyBody { get; set; }
    public Boolean validDatetiemReminderFollowUp { get { if (null == this.validDatetiemReminderFollowUp) { this.validDatetiemReminderFollowUp = true; } return this.validDatetiemReminderFollowUp; } private set; }
    public List<String> getSentEmailBody() { return this.sentEmailBody; }//MRS-7494
    public void setSentEmailBody(List<String> sentEmailBody) { this.sentEmailBody = sentEmailBody; }
    /* -------------------------- End Component Parameters ----------------------------------------- */

    /* ---------------------------- Begin Sent To Roster Contact -------------------------- */
    public List<SelectOption> rostersSendTo {
        get {
            if (null == this.rostersSendTo) {
                this.rostersSendTo = new List<SelectOption>();
                this.rostersSendTo.add(new SelectOption ('', '-- None --'));
                if( getProject().Id != null ){
                    for (Project_Roster__c roster : ProjectRosterServices.getRosterByProjectId(getProject().Id)) {
                        if( roster.Email__c != null ){
                            this.rostersSendTo.add(new SelectOption(roster.Email__c, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c));
                        }
                    }
                }
            }
            return this.rostersSendTo;
        }
        private set;
    }

    public String rosterEmailAddress { get; set; }
    public void saveRecipientAddress() {
    }
    /* ---------------------------- End Sent To Roster Contact -------------------------- */

    /* -------------------------- Begin Email Template Section ----------------------------------------- */
    private MergeEmailTemplate mergeTemplateInstance {
        get {
            if (null == this.mergeTemplateInstance || emptyBody) {
                if (getEmailType().equals(MergeEmailTemplate.RFI_EMAIL)) {
                    this.mergeTemplateInstance = new MergeEmailTemplate( getEmailTemplateName(),
                                                                         getProject(),
                                                                         getSendToFullName() != null ? getSendToFullName() : getSendTo(),
                                                                         getEmailType(),
                                                                         getLinkForRFI() );
                } else {
                    this.mergeTemplateInstance = new MergeEmailTemplate( getEmailTemplateName(),
                                                                         getProject(),
                                                                         getSendToFullName() != null ? getSendToFullName() : getSendTo(),
                                                                         getEmailType(),
                                                                         getAdditionalSubject(),
                                                                         getAdditionalBody(),
                                                                         toContact );
                }
            }
            return  this.mergeTemplateInstance;
        } set;
    }

    public String loggedUserName {
        get {
            if (null == this.loggedUserName) {
                if( sendFrom == null ){
                    this.loggedUserName = UserInfo.getName();
                } else {
                    this.loggedUserName = sendFrom.split('|')[0];
                }
            }
            return this.loggedUserName;
        } set;
    }

    public String subject {
        get {
            if (String.isBlank(this.subject) || emptyBody) {
                try {
                    this.subject = this.mergeTemplateInstance.subject;

                } catch(Exception ex) {
                    this.subject = '';
                }
            }
            return this.subject;
        } set;
    }

    public String innerTemplateBody {
        get {
            if (String.isBlank(this.innerTemplateBody) || emptyBody) {
                try {
                    this.innerTemplateBody = this.mergeTemplateInstance.body;
                } catch(Exception ex) {
                    this.innerTemplateBody = '';
                }
            }
            return this.innerTemplateBody;
        } set;
    }

    public Boolean showTemplateSelector {
        get {
            if (null == this.showTemplateSelector) {
                this.showTemplateSelector = false;
            }
            return this.showTemplateSelector;
        } private set;
    }

    public String orderedFormsScanAndSend {
        get {
            if (null == this.orderedFormsScanAndSend) {
                this.orderedFormsScanAndSend = '';
            }
            return this.orderedFormsScanAndSend;
        } public set;
    }

    public String emailTemplateDraftId { get; set; }
    private Id deliveryMethodId;

    public void updateEmailContent() {
        List<Integer> biggestNumbers = new List<Integer>();
        //emailSetupData = Biggest Email Template number (for the earliest Email Template) - to Delivery Method Id - to Email Template (the oldest one)
        Map<Integer, Map<Id, EmailTemplate>> emailSetupData = EmailMessageService.getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( ddpName );
        if( emailSetupData != null ) {
            biggestNumbers = new List<Integer>( emailSetupData.keySet() );
            biggestNumbers.sort();
        }
        Map<Id, EmailTemplate> deliveryMethodIdToEmailTemplate = !biggestNumbers.isEmpty()
                                                                 ? emailSetupData.get( biggestNumbers[biggestNumbers.size() - 1] )
                                                                 : null;
        Integer oldestTemplateNumber = !biggestNumbers.isEmpty()
                                       ? biggestNumbers[biggestNumbers.size() - 1]
                                       : null;
        this.deliveryMethodId = deliveryMethodIdToEmailTemplate != null
                                ? ( new List<Id>( deliveryMethodIdToEmailTemplate.keySet() ) )[0]
                                : null;
        EmailTemplate emailTemplateDraft = deliveryMethodIdToEmailTemplate != null
                                           ? deliveryMethodIdToEmailTemplate.get( this.deliveryMethodId )
                                           : null;

        if( emailTemplateDraft != null && this.deliveryMethodId != null ) {
            emailTemplateDraftId = emailTemplateDraft.Id != null ? emailTemplateDraft.Id : '';
            this.emptyBody = false;
            //Validation Follow Up & Reminder Datetime
            Datetime currentDay = Datetime.now();
            if( null != this.followUpAndReminder.Follow_Up_Alert_DateTime__c && currentDay > this.followUpAndReminder.Follow_Up_Alert_DateTime__c ) {
                this.validDatetiemReminderFollowUp = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ErrorException.EMAIL_MESSAGE_FOLLOW_UP_PAST_TIME ) );
                return;
            }
            if( null != this.followUpAndReminder.Recipient_Reminder_DateTime__c && currentDay > this.followUpAndReminder.Recipient_Reminder_DateTime__c ) {
                this.validDatetiemReminderFollowUp = false;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ErrorException.EMAIL_MESSAGE_REMINDER_PAST_TIME ) );
                return;
            }
            this.validDatetiemReminderFollowUp = true;
            String findAttachedDocumentsMessage = useAttachmentsUrl() ? getAttachmentsSection( documentNameToExternalURLMap ) : '';
            try {
                emailTemplateDraft.Subject = this.subject;
                if( getEmailType().equals( MergeEmailTemplate.RFI_EMAIL ) ) {
                    this.innerTemplateBody = MergeEmailTemplate.getValidOutlookBody( this.innerTemplateBody );
                }
                emailTemplateDraft.HtmlValue = this.mergeTemplateInstance.headerBody +
                                               this.innerTemplateBody +
                                               findAttachedDocumentsMessage +
                                               MergeEmailTemplate.legalFooter() +
                                               this.mergeTemplateInstance.footerBody;
                emailTemplateDraft.Description = String.valueOf( oldestTemplateNumber + 1 ); //description field is used to find the earliest unused template
                if ( getSentEmailBody() != null ){getSentEmailBody().add(emailTemplateDraft.HtmlValue);}//MRS-7494 returns sent email body
                UPDATE emailTemplateDraft;
            } catch( Exception ex ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error updating email template. ' + ex.getMessage() ) );
            }
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'No email template was found for sending.' ) );
        }
    }

    private String getAttachmentsSection( Map<String, String> externalURLMap ){
        String attachmentBody = ATTACHED_DOCUMENTS_MESSAGE + '<br/><ol>';
        for( String extUrl : externalURLMap.keySet() ){
            attachmentBody += '<li><a href=\"' + extUrl +'\" style=\"color: blue;\">' + externalURLMap.get(extUrl) + '</li>';
        }
        return attachmentBody + '</ol>';
    }

    @TestVisible
    private Boolean useAttachmentsUrl(){
        Double totalAttachmentsSize = 0;
        documentsExternalURL = new List<String>();
        documentNameToExternalURLMap = new Map<String, String>();
        Boolean unpredictableFilesAttached = false;
        for( FileWrapper item: attachedDocumentsMap.values() ){
            totalAttachmentsSize += item.document.LStore__File_Size__c;
            documentsExternalURL.add(item.externalURL);
            documentNameToExternalURLMap.put( item.externalURL, ( item.document.Drawings_Title__c != null ? item.document.Drawings_Title__c : item.document.Name ) );
            if( EmailMessageService.unpredictableFilesEtentions.contains( item.document.LStore__Type__c ) ) unpredictableFilesAttached = true;
        }
        if( totalAttachmentsSize >= EmailMessageService.ATTACHMENT_LIMIT || unpredictableFilesAttached ){
            attachedDocumentsMap = new Map<Id, FileWrapper>();
            return true;
        }
        return false;
    }

    public void sendDDPEmail() {
        try {
            DDPRequest request = new DDPRequest();

            List<Id> attachmentListId = new List<Id>();
            if (!String.isEmpty(orderedFormsScanAndSend)){
                for (FileWrapper doc : sorteredFileWrapperList){
                    attachmentListId.add(doc.document.Id);
                }
            } else {
                attachmentListId.addAll(attachedDocumentsMap.keySet());
            }

            request.addConfiguration(parentRecordId, DDPName, deliveryMethodId, null, null == toContact ? null : toContact.Id, null, attachmentListId);
            request.sendRequest();
            //Create Follow Up Task Alert
            createTasks();
            isEmailTemplateSet = false;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occured during sending email: ' + ex.getMessage()));
        } finally {
            this.subject = '';
            this.innerTemplateBody = '';
            this.emailsToCC = '';
            this.emailTemplateNameFromSearch = '';
        }
    }

    @TestVisible
    private String getTaskDescriptionForFollowUp(){
        String description = 'ALERT: ';
        description       += 'Please follow up on RFI sent to ';
        description       += sendTo;
        description       += ' for ' + project.Name + ' at ' + project.Project_Address__c;
        description       += ' if no response has been received.';
        return description;
    }

    @TestVisible
    private String getTaskItemFollowUpDescription( Task_Item__c task ){
        String description = 'ALERT: ';
        description       += 'Please follow up on Taks Item ' + task.Name + ' available on ' +  Url.getSalesforceBaseUrl().toExternalForm() + '/' + task.Id;
        description       += + ' sent to ' + sendTo;
        description       += ' for ' + project.Name + ' at ' + project.Project_Address__c;
        description       += ' if no response has been received.';
        return description;
    }

    @TestVisible
    private void createTasks() {
        if (this.showReminders) {
            if (null != this.followUpAndReminder.Follow_Up_Alert_DateTime__c && this.followUpAndReminder.Follow_Up_Alert__c) {
                //Task for RFI functionality
                if (getEmailType().equals(MergeEmailTemplate.RFI_EMAIL)) {
                    DateTime dT = this.followUpAndReminder.Follow_Up_Alert_DateTime__c;
                    TaskServices.createTask(UserInfo.getUserId(), 'Not Started', 'Normal', getParentRecordId(), dT, date.newinstance(dT.year(), dT.month(), dT.day()), 'RFI subject', getTaskDescriptionForFollowUp(), getAdditionalSubject());

                //Tasks for RFF
                } else if (getEmailType().equals(MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL)) {
                    DateTime dT = this.followUpAndReminder.Follow_Up_Alert_DateTime__c;

                    String rffFollowUpMessage = String.format(CheckServices.RFF_FOLLOW_UP_MESSAGE, new String[]{ getProject().Name });

                    //Create Task for Current User
                    TaskServices.createTask(UserInfo.getUserId(), 'Not Started', 'Normal', getParentRecordId(),
                                            this.followUpAndReminder.Follow_Up_Alert_DateTime__c,
                                            date.newinstance(dT.year(), dT.month(), dT.day()),
                                            rffFollowUpMessage,
                                            rffFollowUpMessage,
                                            getAdditionalSubject());

                    //Create the same Task for Project Manager - 1
                    if (null != getProject().Project_Member__c) {
                        TaskServices.createTask(getProject().Project_Member__c, 'Not Started', 'Normal', getParentRecordId(),
                                                this.followUpAndReminder.Follow_Up_Alert_DateTime__c,
                                                date.newinstance(dT.year(), dT.month(), dT.day()),
                                                rffFollowUpMessage,
                                                rffFollowUpMessage,
                                                getAdditionalSubject());

                    }

                } else if (getParentRecordId().startsWith(Task_Item__c.sObjectType.getDescribe().getKeyPrefix())) {
                    List<Task_Item__c> taskItems = new List<Task_Item__c>([SELECT id, Name FROM Task_Item__c WHERE Id =: getParentRecordId()]);

                    if (!taskItems.isEmpty() && taskItems[0].Name == TaskItemServices.REQUEST_ASSIGN_VENDOR_ACTIVITY) {
                        DateTime dT = this.followUpAndReminder.Follow_Up_Alert_DateTime__c;
                        TaskServices.createTask(UserInfo.getUserId(), 'Not Started', 'Normal', getParentRecordId(), this.followUpAndReminder.Follow_Up_Alert_DateTime__c, date.newinstance(dT.year(), dT.month(), dT.day()), 'Follow-Up ' + getProject().Name, getTaskItemFollowUpDescription(taskItems[0]), getAdditionalSubject());

                    }

                }
            }
        }
    }
    /* -------------------------- End Email Template Section ----------------------------------------- */

    /* -------------------------- Begin Add CC to Email Section ----------------------------------------- */
    public String emailsToCC { get; set; }
    public String emailsForRecordFieldCC { get { if (String.isBlank(this.emailsForRecordFieldCC)) { this.emailsForRecordFieldCC = ''; } return this.emailsForRecordFieldCC; } set; }
    public String sendToAddress { get; set; }

    public void addEmailTo() {
        this.rosterEmailAddress = '';
        this.sendToAddress      = '';
        this.toContact = null;//MRS-6732
        for (ProjectRosterWrapper rosterModel : this.nameToRosterForSelection.values()) {
            if (rosterModel.isSelect && !String.isBlank(rosterModel.email)) {
                this.sendToAddress      += rosterModel.name + ' (' + rosterModel.email + '); ';
                this.rosterEmailAddress += rosterModel.email + ';';
                if( this.toContact == null && rosterModel.contact != null ){
                    this.toContact = rosterModel.contact;
                }
            }
        }
    }

    public void addEmailToCC() {
        this.emailsToCC             = '';
        this.emailsForRecordFieldCC = '';
        for (ProjectRosterWrapper rosterModel : this.nameToRosterMap.values()) {
            if (rosterModel.isSelect) {
                this.emailsToCC             += rosterModel.name + ' (' + rosterModel.email + '); ';
                this.emailsForRecordFieldCC += rosterModel.email + ';';
            }
        }
    }

    private List<Project_Roster__c> rostersFromProject {
        get {
            if( null == this.rostersFromProject ) {
                this.rostersFromProject = new List<Project_Roster__c>();
                for( Project_Roster__c roster : ProjectRosterServices.getRosterByProjectId( getProject().Id ) ) {
                    if( !String.isBlank( roster.Email__c ) && roster.Active__c ) { //MRS-6868
                        this.rostersFromProject.add( roster );
                    }
                }
            }
            return this.rostersFromProject;
        } set;
    }

    private Set<Id> contactsIds {
        get {
            if ( null == this.contactsIds ) {
                this.contactsIds = new Set<Id>();
                for( Project_Roster__c roster : this.rostersFromProject ) {
                    if( roster.Contact__c != null ) this.contactsIds.add( roster.Contact__c );
                }
            }
            return this.contactsIds;
        } set;
    }

    private Map<Id, Contact> contactsFromProject {
    	get {
    		if( this.contactsFromProject == null ){
    			contactsFromProject = ContactServices.getContactsByIdsFromProjectRosters( contactsIds );
    		}
    		return contactsFromProject;
    	}
    	set;
    }

    public Map<String, ProjectRosterWrapper> nameToRosterMap {
        get{
            if (null == this.nameToRosterMap) {
                this.nameToRosterMap = new Map<String, ProjectRosterWrapper>();
                for (Project_Roster__c roster : this.rostersFromProject) {
                    this.nameToRosterMap.put(roster.Name__c, new ProjectRosterWrapper( roster.Name__c, roster.Email__c, contactsFromProject.get( roster.Contact__c ), roster.Role__c ));
                }
            }
            return nameToRosterMap;
        } set;
    }

    public Map<String, ProjectRosterWrapper> nameToRosterForSelection {
        get{
            if (null == this.nameToRosterForSelection) {
                this.nameToRosterForSelection = new Map<String, ProjectRosterWrapper>();
                for (Project_Roster__c roster : this.rostersFromProject) {
                    if (null != roster.Contact__c) {
                        this.nameToRosterForSelection.put(roster.Name__c, new ProjectRosterWrapper(roster.Name__c, roster.Email__c, contactsFromProject.get( roster.Contact__c ), roster.Role__c));
                    }
                }
            }
            return nameToRosterForSelection;
        } set;
    }
    /* -------------------------- End Add CC to Email Section ----------------------------------------- */

    /*------------------------------ Begin Attach Document(s) to Email ------------------------------ */
    Map<String, LStore__Stored_Document__c> parentIdToOlderDocument = new Map<String, LStore__Stored_Document__c>();

    @TestVisible
    private List<LStore__Stored_Document__c> storeDocAttachment {
        get {
            if (null == this.storeDocAttachment || this.storeDocAttachment.isEmpty()) {
                if (null != getAttachmentIds()) {
                    for (Id attachId : getAttachmentIds()) {
                        AttachmentServices.setDocumentIds(attachId);
                    }
                }
                this.storeDocAttachment = StoredDocumentServices.getStoredDocumentsNotFinancial(AttachmentServices.getDocumentIds());
                //Populate Map if Task is Send Forms for Signatures/Seals
                if (getEmailType().equals(MergeEmailTemplate.FORM_FOR_SIGNATURES) || getisEntityLevel()) {//MRS-4835
                    for (LStore__Stored_Document__c doc : this.storeDocAttachment) {
                        if (!parentIdToOlderDocument.containsKey(doc.LStore__Related_Object_Id__c)) {
                            parentIdToOlderDocument.put(doc.LStore__Related_Object_Id__c, doc);
                        } else if (parentIdToOlderDocument.get(doc.LStore__Related_Object_Id__c).CreatedDate < doc.CreatedDate) {
                            parentIdToOlderDocument.put(doc.LStore__Related_Object_Id__c, doc);
                        }
                    }
                }
            }
            return this.storeDocAttachment;
        } set;
    }

    public List<SelectOption> itemsRelatedToAttachments {
        get {
            if (null == this.itemsRelatedToAttachments) {
                this.itemsRelatedToAttachments = new List<SelectOption>();
                this.itemsRelatedToAttachments.addall(AttachmentServices.getItemsRelatedToAttach());
                if (getEmailType().equals(MergeEmailTemplate.FORM_FOR_SIGNATURES) || getisEntityLevel()) {//MRS-4835
                    this.itemsRelatedToAttachments.add(new SelectOption('Form Meta Data Object 1', 'Form Items'));
                }
            }
            return this.itemsRelatedToAttachments;
        } private set;
    }

    public String documentRelatedTo { get { if (String.isBlank(this.documentRelatedTo)) { this.documentRelatedTo = ''; } return this.documentRelatedTo; } set; }

    public Boolean showAttachment {
        get {
            if (null == this.showAttachment) {
                this.showAttachment = false;
                if ((getEmailType().equals(MergeEmailTemplate.FORM_FOR_SIGNATURES) || getisEntityLevel()) && !this.attachedDocumentsMap.isEmpty()) {//MRS-4835
                    this.showAttachment = true;
                }
            }
            return this.showAttachment;
        } private set;
    }

    public Map<Id, FileWrapper> attachedDocumentsMap {
        get {
            if (null == this.attachedDocumentsMap) {
                this.attachedDocumentsMap = new Map<Id, FileWrapper>();
                if (getEmailType().equals(MergeEmailTemplate.FORM_FOR_SIGNATURES) || getisEntityLevel()) {//MRS-4835
                    displayAttachFormItem();
                }
            }
            return this.attachedDocumentsMap;
        } set;
    }

    public List<FileWrapper> sorteredFileWrapperList {
        get{
            this.sorteredFileWrapperList = new List<FileWrapper>();
            if ( !String.isEmpty(orderedFormsScanAndSend) ){
                Map<Id, Set<Id>> formItemToFormMetaDateIdMap = new Map<Id, Set<Id>>();
                for ( FileWrapper fileWrapperItem : attachedDocumentsMap.values() ){
                    if ( fileWrapperItem.document.Form_Item_Copy__c != null ){
                        if ( !formItemToFormMetaDateIdMap.containsKey( fileWrapperItem.document.Form_Item_Copy__c ) ){
                            formItemToFormMetaDateIdMap.put( fileWrapperItem.document.Form_Item_Copy__c, new Set<Id>{fileWrapperItem.document.Id} );
                        } else {
                            formItemToFormMetaDateIdMap.get( fileWrapperItem.document.Form_Item_Copy__c).add(fileWrapperItem.document.Id);
                        }
                    }
                }

                Set<Id> documentIdSetIds = new Set<Id>();

                for ( String formIdValue : orderedFormsScanAndSend.split(',', 1000) ){
                    if ( formIdValue.trim() instanceof Id ){
                        Id formItemId = Id.valueOf(formIdValue.trim());
                        if ( formItemToFormMetaDateIdMap.containsKey( formItemId ) ){
                            for ( Id docId : formItemToFormMetaDateIdMap.get(formItemId) ){
                                this.sorteredFileWrapperList.add( attachedDocumentsMap.get(docId) );
                            }
                            documentIdSetIds.addAll( formItemToFormMetaDateIdMap.get(formItemId) );
                        }
                    }
                }

                List<FileWrapper> notSorteredFileWrapperList = new List<FileWrapper>();
                for ( FileWrapper fileWrapperItem : attachedDocumentsMap.values() ){
                    if ( !documentIdSetIds.contains( fileWrapperItem.document.Id ) ){
                        this.sorteredFileWrapperList.add(fileWrapperItem);
                    }
                }
            } else {
                this.sorteredFileWrapperList = attachedDocumentsMap.values();
            }

            return this.sorteredFileWrapperList;
        } set;
    }

    @TestVisible
    private void displayAttachLetter() {
        for (LStore__Stored_Document__c doc : this.storeDocAttachment) {
            if (!String.isBlank(doc.LStore__File_Name__c) && doc.LStore__File_Name__c.contains(String.valueOf(date.today()))) {
                this.attachedDocumentsMap.put(doc.Id, new FileWrapper(doc, AttachmentServices.getObjectName(doc.LStore__Related_Object_Id__c)));
            }
        }
    }

    @TestVisible
    private void displayAttachFormItem() {
        for (LStore__Stored_Document__c doc : this.storeDocAttachment) {
            if (isAttachDocFromItem(doc.Id)) { //MRS-6804
                this.attachedDocumentsMap.put(doc.Id, new FileWrapper(doc, AttachmentServices.getObjectName(doc.LStore__Related_Object_Id__c)));
            }
        }
    }

    @TestVisible
    private Boolean isAttachDocFromItem(Id docFormId) { //MRS-6804
        if ( String.isBlank(getAdditionalBody()) || docFormId == null ) {
            return false;
        }
        for (String recordId : getAdditionalBody().split(';')) {
            if (parentIdToOlderDocument.containsKey(recordId) && parentIdToOlderDocument.get(recordId).Id == docFormId) {
                return true;
            }
        }
        return false;
    }

    public List<FileWrapper> documents { get { if (null == this.documents) { this.documents = new List<FileWrapper>(); } return this.documents; } set; }

    public void displayDocument() {
        if (null == this.documents || this.documents.isEmpty()) {
            this.documents = new List<FileWrapper>();
            try {
                FileWrapper wrapper;
                for (LStore__Stored_Document__c doc : this.storeDocAttachment) {
                    wrapper = new FileWrapper(doc, AttachmentServices.getObjectName(doc.LStore__Related_Object_Id__c));
                    wrapper.isSelect = ( getEmailType().equals(MergeEmailTemplate.FORM_FOR_SIGNATURES) || getisEntityLevel() ) && isAttachDocFromItem(doc.Id);//MRS-4835, MRS-6804
                    this.documents.add(wrapper);
                }
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                return;
            }
        }
    }

    public void attach() {
        for (FileWrapper file : this.documents) {
            if (file.isSelect) {
                this.attachedDocumentsMap.put(file.document.Id, file);
            } else {
                this.attachedDocumentsMap.remove(file.document.Id);
            }
        }
        this.showAttachment = !this.attachedDocumentsMap.isEmpty();
    }

    /* ------------------------------ End Attach Document(s) to Email ------------------------------ */

    /* ------------------------------------- Begin Reminder & FollowUp ------------------------------------- */
    /* Temporary Object which help take datetime for follow up & reminder */
    public RFI_Scope__c followUpAndReminder { get { if (null == this.followUpAndReminder) { this.followUpAndReminder = new RFI_Scope__c(); } return this.followUpAndReminder; } set; }

    public void setReminderDate() {
        if (this.followUpAndReminder.Recipient_Reminder__c) {
            Datetime businessHour = DateUtils.getDatetimeWithTimeShiftByBusinessHours(datetime.now(), '3d');
            this.followUpAndReminder.Recipient_Reminder_DateTime__c = date.newinstance(businessHour.year(), businessHour.month(), businessHour.day());
        } else {
            this.followUpAndReminder.Recipient_Reminder_DateTime__c = null;
        }
    }

    public void setFollowUpDate() {
        if (this.followUpAndReminder.Follow_Up_Alert__c) {
            Datetime businessHour = DateUtils.getDatetimeWithTimeShiftByBusinessHours(datetime.now(), '3d');
            this.followUpAndReminder.Follow_Up_Alert_DateTime__c = date.newinstance(businessHour.year(), businessHour.month(), businessHour.day());
        } else {
            this.followUpAndReminder.Follow_Up_Alert_DateTime__c = null;
        }
    }

    public void updateDate() {
        this.followUpAndReminder.Follow_Up_Alert__c    = (null == this.followUpAndReminder.Follow_Up_Alert_DateTime__c) ? false : true;
        this.followUpAndReminder.Recipient_Reminder__c = (null == this.followUpAndReminder.Recipient_Reminder_DateTime__c) ? false : true;
    }
    /* ------------------------------------- End Reminder & FollowUp ------------------------------------- */

    /* ------------------------------------- Begin Search Template --------------------------------------- */
    private Map<Id, Form_Template__c> formTemplatesMap { get { return new Map<Id, Form_Template__c>(this.formTemplatesList); } set; }
    private String emailTemplateNameFromSearch { get { if (String.isBlank(this.emailTemplateNameFromSearch)) { this.emailTemplateNameFromSearch = ''; } return this.emailTemplateNameFromSearch; } set; }
    public List<selectOption> regionOptions { get{ if (null == this.regionOptions) { this.regionOptions = RegionServices.getRegionOptions(); } return this.regionOptions; } set; }
    public List<Form_Template__c> formTemplatesList { get { if (null == this.formTemplatesList) { this.formTemplatesList = new List<Form_Template__c>(); } return this.formTemplatesList; } set; }
    public Boolean isEmailTemplateSet { get { if (null == this.isEmailTemplateSet) { this.isEmailTemplateSet = false; } return this.isEmailTemplateSet; } set; }
    public String municipalityFilter { get; set { municipalityFilter = value; } }
    public String refNumberFilter { get; set; }
    public String shortNameFilter { get; set; }
    public String fullNameFilter { get; set; }
    public String regionId { get { if( String.isEmpty( regionId ) ) { regionId = RegionServices.REGION_NAME_NY; } return regionId; } set; }
    public String emailTemplateRecordId { get; set; }

    public void searchAction() {
        formTemplateslIST = new List<Form_Template__c>();
        String queryWhere = FormTemplatesServices.buildQueryWhere( refNumberFilter, ''/*MRS-5183*/, fullNameFilter, municipalityFilter, regionId, false, true, false );
        String query      = FormTemplatesServices.buildQuery(queryWhere);
        formTemplatesList = Database.query(query);
        if (formTemplatesList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No results found. Please specify another search criteria.'));
        }
    }

    public void setEmailTemplate() {
        this.emailTemplateNameFromSearch = '';
        if (!formTemplatesMap.containsKey(emailTemplateRecordId)) {
            return;
        }
        this.emailTemplateNameFromSearch = formTemplatesMap.get(emailTemplateRecordId).Form_ID__c + '-%';
        this.isEmailTemplateSet          = String.isNotBlank(this.emailTemplateNameFromSearch);
    }

    /* ------------------------------------- End Search Template --------------------------------------- */

    public void skipEmailSelection() {
        this.isEmailTemplateSet = true;
    }

}