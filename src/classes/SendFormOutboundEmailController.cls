public with sharing class SendFormOutboundEmailController {
    private final Id projectId;
    private final Id taskItemId;
    @TestVisible private String formIds;
    
    private Task_Item__c taskItem {
        get {
            if (null == this.taskItem) {
                 this.taskItem  = TaskItemServices.getTaskItemById(this.taskItemId);
            
            }
            return this.taskItem;
        
        }
        set;
    
    } 
    
    public Id serviceItemId { get; set; }
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
    
    public String getFormIds (){ return formIds; }

    public Boolean reviewEmail { 
        get;
        private set;
    }
    
    public String drawloopName { 
        get {
            return DDPEmailServices.DDP_NAME_SEND_ATTACHMENT_SERVICE_ITEM;
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
            if (null == this.project) {
                this.project = ProjectProfileServices.getProjectById(this.projectId);
            
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
    
    @TestVisible private Service_Item__c serviceItem {
        get {
            if (null == this.serviceItem) {
                this.serviceItem = ServiceItemServices.getServiceItemById(this.serviceItemId);
            
            }
            return this.serviceItem;
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
    
    public SendFormOutboundEmailController() {
        this.projectId           = ApexPages.currentPage().getParameters().get('projectId');
        this.serviceItemId       = ApexPages.currentPage().getParameters().get('serviceItemId');
        this.taskItemId          = ApexPages.currentPage().getParameters().get('taskItemId'); 
        this.formIds             = ApexPages.currentPage().getParameters().get('formIds');
        this.reviewEmail         = false;
        this.linkToCloseTemplate =  '/' + String.valueOf(this.taskItemId);
    
    }
    
    public void clearEmailAddress() {
        
        try {
            this.serviceItem.Email_To_Form__c    = '';
            this.serviceItem.Email_Cc_Form__c = '';
            
            update this.serviceItem;
        
        } catch(Exception ex) {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
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
            if (null == this.attachmentIds) {
                this.attachmentIds = new List<Id>();
                
                if (null != this.serviceItemId && null != this.taskItem.Predecessor_Task__c) {
                    for (Form_Meta_Data_Object_1__c fmdo : [SELECT Id 
                                                            FROM Form_Meta_Data_Object_1__c 
                                                            WHERE Service_Item__c =: this.serviceItemId AND Task_Item__c =: this.taskItem.Predecessor_Task__c]) {
                        this.attachmentIds.add(fmdo.Id);
                    
                    }
                
                }    
                this.attachmentIds.add(this.serviceItemId);
                this.attachmentIds.add(this.projectId);
                this.attachmentIds.add(this.taskItemId);
                this.attachmentIds.add(this.proposalId);
                
            }
            return this.attachmentIds; 
        }
        set;
    }
    /* -------------------------- End Target Ids for Documents  -------------------------- */

    /* -------------------------- Begin Sending Email -------------------------- */        
    public void onCompleteReview() {
        if (null == this.contactRecipient.Id) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
            return;
        
        }
        
        try {
            this.serviceItem.Email_To_Form__c = contactEmail;
            update this.serviceItem;
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Emails have not be added to CC! Please try again!'));
            return;
        
        }
        
    }
    
    public PageReference sendEmail() {
        try {
            //updateFormAssignItems(this.sendTo, this.formIds);
            return null;
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occured during sending email: ' + ex.getMessage()));
            return null;
        
        }
        return null;

    }
    
    /*@future
    static void updateFormAssignItems(String sendTo, String formIds) {
        List<Form_Assignment__c> formToUpdate = new List<Form_Assignment__c>();
        
        Datetime dateSend = datetime.now();
        
        for (Form_Item__c form : FormItemsServices.getFormItemsByFormIds(getSetOfIdsForFuture(formIds)).values() ) {
            for (Form_Assignment__c formAssign : form.Form_Assignments__r) {
                if (sendTo == formAssign.Recipient_Name__c && null == formAssign.Sent_Date__c) {
                    formAssign.Status__c    = 'Sent';
                    formAssign.Sent_Date__c = dateSend;
                    formAssign.Sent_VIA__c  = 'Email';
                   
                    formToUpdate.add(formAssign);
                    
                }
            
            }
            
        }
        
        try {
            update formToUpdate;
        
        } catch(Exception ex) {
            throw new ErrorException(ex.getMessage());
        
        }
            
    }*/
    
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
        if (null == this.contactRecipient.Id) {
            return;
        
        }
        this.reviewEmail = true;
        
    }
    
    public PageReference backToTaskItem() {
        PageReference page = new PageReference('/apex/SendFormsforSignaturesSealsTaskItem?id=' + this.taskItemId);
        page.setRedirect(true);
        return page;
    
    }
    /* -------------------------- End Button(s) Event(s)  -------------------------- */
    public String emailsAddressForDrawLoop { get; set; }
    
    //Callback Action: save CC Emails Address
    public void updateCCEmailsAddressForDrawLoop () {
        try {
            this.serviceItem.Email_Cc_Form__c = this.emailsAddressForDrawLoop;
            update this.serviceItem;
            
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
            
        }
    
    }
    
    //Callback Action: update record
    public PageReference updateAfterSend() {
        List<Form_Assignment__c> formToUpdate = new List<Form_Assignment__c>();
        Datetime dateSend = datetime.now();
        
        for (Form_Item__c form : FormItemsServices.getFormItemsByFormIds(getSetOfIdsForFuture(this.formIds)).values() ) {
            for (Form_Assignment__c formAssign : form.Form_Assignments__r) {
                if (this.sendTo == formAssign.Recipient_Name__c && null == formAssign.Sent_Date__c) {
                    formAssign.Status__c    = 'Sent';
                    formAssign.Sent_Date__c = dateSend;
                    formAssign.Sent_VIA__c  = 'Email';
                   
                    formToUpdate.add(formAssign);
                    
                }
            
            }
            
        }
        
        try {
            update formToUpdate;
        
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
        
        } finally {
            this.reviewEmail = false;
        
        }
        
        return backToTaskItem();
    
    }

}