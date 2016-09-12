public with sharing class SendFormOutboundEmailProjectController {
    private final Id projectId;
    @TestVisible private String formIds;
    
    public String sendTo { get; set; }
    public String formItemsName { 
        get {
            Set<Id> formItemIds = new Set<Id>();
            for (Form_Item__c formItem : getEmailToFormItems().get(this.sendTo)) {
                formItemIds.add(formItem.Id);
            
            }
            this.formItemsName = '';
            
            for (Form_Item__c form : [ SELECT Id, Form_Name__c, 
                                              ( SELECT Id, Name, CreatedDate, Form_PDF_Name__c, Form_PDF_Version__c 
                                                FROM Form_Meta_Data_Objects_1__r ORDER BY Page_Number__c DESC ) 
                                       FROM Form_Item__c f 
                                       WHERE Id IN: formItemIds ]) {
                for( Form_Meta_Data_Object_1__c fmdo : form.Form_Meta_Data_Objects_1__r ){
                     if( ![ Select Id From LStore__Stored_Document__c Where Related_Object_Id__c = :fmdo.Id ].isEmpty() ){
                        this.formItemsName += fmdo.Id + ';';
                        break;
                     }
                }
            }
            return this.formItemsName;
            
        }
        private set; 
    }
    
    public Id getProjectId() { return projectId; }

    public String getFormIds() { return formIds; }

    public Boolean reviewEmail { 
        get;
        private set;
    }
    
    public String drawloopName { 
        get {
            return DDPEmailServices.DDP_NAME_SEND_ATTACHMENT_FORMS_FOR_PROJECT;
        }
        set; 
    }
    
    public String emailTemplateName {
        get {
            return FormItemsServices.FORM_ITEM_EMAIL_TEMPLATE_NAME;
        }
        set;
    }
    
    public String draftTemplateName {
        get {
            return FormItemsServices.FORM_ITEM_EMAIL_TEMPLATE_DRAFT_NAME;
        }
        set;
    }
    
    public String formForSignatures {
        get {
            return MergeEmailTemplate.FORM_FOR_SIGNATURES;
        }
        set;
    }
    
    public Project_Profile__c project { 
        get {
            if( null == this.project ) {
                this.project = ProjectProfileServices.getProjectById( this.projectId );
            }
            return this.project;
        } 
        set; 
    }
    
    public Contact contactRecipient { 
        get {
            if (null == this.contactRecipient) {
                if( formItems != null && !formItems.isEmpty() && !formItems[0].Form_Assignments__r.isEmpty() && formItems[0].Form_Assignments__r[0].Recipient_Role__r.Contact__c != null ){
                    Id contactId = formItems[0].Form_Assignments__r[0].Recipient_Role__r.Contact__c;
                    this.contactRecipient = ContactServices.getContactsByIds( new Set<Id>{ contactId } )[0];
                } else {
                    this.contactRecipient = new Contact();    
                }
            }
            return this.contactRecipient;
        } 
        set; 
    }
    
    @TestVisible private List<Form_Item__c> formItems {
        get {
            if (null == this.formItems) {
                this.formItems = FormItemsServices.getFormItemsByFormIds(getSetOfIds()).values();
            }
            return this.formItems;
        }
        set;
    }
    
    @TestVisible private EmailTemplate emailTemplate {
        get {
            if (null == this.emailTemplate) {
                this.emailTemplate = EmailMessageService.getEmailTemplateByName(FormItemsServices.FORM_ITEM_EMAIL_TEMPLATE_NAME);             
            }
            return this.emailTemplate;
        }
        set;
    }

    @TestVisible private EmailTemplate emailTemplateDraft {
        get {
            if (null == this.emailTemplateDraft) {
                this.emailTemplateDraft = EmailMessageService.getEmailTemplateByName(FormItemsServices.FORM_ITEM_EMAIL_TEMPLATE_DRAFT_NAME); 
            }
            return this.emailTemplateDraft;
        }
        set;
    }
    
    @TestVisible private Id proposalId {
        get {
            if (null == this.proposalId) {
                this.proposalId = ProposalServices.getProposalIdByProjectId(this.projectId);
            }
            return this.proposalId;
        }
        set;
    }
    
    public String contactEmail {
        get {
            for (Form_Item__c form : this.formItems) {
                for (Form_Assignment__c formAssgn : form.Form_Assignments__r) {
                    if (this.sendTo == formAssgn.Recipient_Name__c && null == formAssgn.Sent_Date__c) {
                        return formAssgn.Recipient_Email__c;
                    }
                }
            }
            return '';
        }
        private set;
    }
    
    public String loggedUserName {
        get {
            return UserInfo.getName();
        }
        private set;
    }
    
    public String linkToCloseTemplate { get; private set;}
    
    public SendFormOutboundEmailProjectController() {
        this.projectId           = ApexPages.currentPage().getParameters().get('projectId');
        this.formIds             = ApexPages.currentPage().getParameters().get('formIds');
        this.reviewEmail         = false;
        this.linkToCloseTemplate =  '/' + String.valueOf(this.projectId);
    }
    
    public void clearEmailAddress() {
        try {
            project.Email_To_Form__c = '';
            project.Email_Cc_Form__c = '';
            UPDATE new Project_Profile__c( Id = projectId, Email_To_Form__c = '', Email_Cc_Form__c = '' );
        } catch( Exception ex ) {
             ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
             return;
        }
    }
    
    @TestVisible private Set<Id> getSetOfIds() {
        Set<Id> formIdSet = new Set<Id>();
        for (String formId : this.formIds.split(',', -1)) {
            if (!String.isBlank(formId)) {
                formIdSet.add(formId);
            }
        }
        return formIdSet; 
    }
    
    public Map<String, List<Form_Item__c>> getEmailToFormItems() {
        Map<String, List<Form_Item__c>> contactNameToFormItem = new Map<String, List<Form_Item__c>>();
        
        try {
            for (Form_Item__c form : this.formItems) {
                for (Form_Assignment__c formAssgn : form.Form_Assignments__r) {
                    if (!contactNameToFormItem.containsKey(formAssgn.Recipient_Name__c)) {
                        contactNameToFormItem.put(formAssgn.Recipient_Name__c, new List<Form_Item__c>());
                    }
                    contactNameToFormItem.get(formAssgn.Recipient_Name__c).add(form);
                }
            }
        } catch(Exception ex) {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You did not select form item(s)!'));
             return null;
        }
        return contactNameToFormItem;
    }

    /* -------------------------- Begin Target Ids for Documents  -------------------------- */
    public List<Id> attachmentIds {
        get {
            if( null == this.attachmentIds ) {
                this.attachmentIds = new List<Id>();
                Set<Id> serviceItemIdsForAttachmentIds = new Map<Id, Service_Item__c>( [ SELECT Id
                                                                                         FROM Service_Item__c
                                                                                         WHERE Project_Profile__c = : this.projectId
                                                                                           AND Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE ] ).keySet();
                this.attachmentIds.addAll( serviceItemIdsForAttachmentIds );
                Set<Id> taskItemIdsForAttachments = new Map<Id, Task_Item__c>( [ SELECT Id
                                                                                 FROM Task_Item__c
                                                                                 WHERE Service_Item__c IN : serviceItemIdsForAttachmentIds ] ).keySet();
                this.attachmentIds.addAll( taskItemIdsForAttachments );
                Set<Id> formItemIdsForAttachments = new Map<Id, Form_Meta_Data_Object_1__c>( [ SELECT Id
                                                                                               FROM Form_Meta_Data_Object_1__c
                                                                                               WHERE Task_Item__c IN : taskItemIdsForAttachments ] ).keySet();
                this.attachmentIds.addAll( formItemIdsForAttachments );
                /*if (null != this.serviceItemId && null != this.taskItem.Predecessor_Task__c) {
                    for (Form_Meta_Data_Object_1__c fmdo : [SELECT Id 
                                                            FROM Form_Meta_Data_Object_1__c 
                                                            WHERE Service_Item__c =: this.serviceItemId AND Task_Item__c =: this.taskItem.Predecessor_Task__c]) {
                        this.attachmentIds.add(fmdo.Id);
                    }
                }*/
                this.attachmentIds.add( this.projectId );
                this.attachmentIds.add( this.proposalId );
            }
            return this.attachmentIds; 
        }
        set;
    }
    /* -------------------------- End Target Ids for Documents  -------------------------- */

    /* -------------------------- Begin Sending Email -------------------------- */        
    public void onCompleteReview() {
        if( null == this.contactRecipient.Id ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
            return;
        }
        try {
            this.project.Email_To_Form__c = contactEmail;
            UPDATE new Project_Profile__c( Id = projectId, Email_To_Form__c = contactEmail );
        } catch( Exception ex ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Emails have not be added to CC! Please try again!'));
            return;
        }
    }

    @TestVisible private static Set<Id> getSetOfIdsForFuture(String formIds) {
        Set<Id> formIdSet = new Set<Id>();
        for (String formId : formIds.split(',', -1)) {
            if (!String.isBlank(formId)) {
                formIdSet.add(formId);
            }
        }
        return formIdSet; 
    }
    /* -------------------------- End Sending Email -------------------------- */

    /* -------------------------- Begin Button(s) Event(s)  -------------------------- */
    public void showReviewEmail() {
        if( null == this.contactRecipient.Id ) {
            return;
        }
        this.reviewEmail = true;
    }
    
    public PageReference goBack() {
        PageReference page = new PageReference( '/apex/SendFormsforSignaturesSealsProject?id=' + this.projectId );
        page.setRedirect(true);
        return page;
    }
    /* -------------------------- End Button(s) Event(s)  -------------------------- */

    public String emailsAddressForDrawLoop { get; set; }
    
    //Callback Action: save CC Emails Address
    public void updateCCEmailsAddressForDrawLoop () {
        try {
            this.project.Email_Cc_Form__c = this.emailsAddressForDrawLoop;
            UPDATE new Project_Profile__c( Id = projectId, Email_Cc_Form__c = this.emailsAddressForDrawLoop );
        } catch( Exception ex ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
            return;
        }
    }
    
    //Callback Action: update record
    public PageReference updateAfterSend() {
        List<Form_Assignment__c> formToUpdate = new List<Form_Assignment__c>();
        Datetime dateSend = datetime.now();
        for( Form_Item__c form : FormItemsServices.getFormItemsByFormIds( getSetOfIdsForFuture( this.formIds ) ).values() ) {
            for( Form_Assignment__c formAssign : form.Form_Assignments__r ) {
                if( this.sendTo == formAssign.Recipient_Name__c && null == formAssign.Sent_Date__c ) {
                    formAssign.Status__c    = 'Sent';
                    formAssign.Sent_Date__c = dateSend;
                    formAssign.Sent_VIA__c  = 'Email';
                    formToUpdate.add(formAssign);
                }
            }
        }
        try {
            UPDATE formToUpdate;
        } catch( Exception ex ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
            return null;
        } finally {
            this.reviewEmail = false;
        }
        return goBack();
    }

}