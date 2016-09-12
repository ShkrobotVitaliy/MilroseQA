public with sharing class SendLetterAsAttachmentController {
    public final Id projectId { 
        get;
        private set;
    
    }
    
    public String drawloopName {
        get {
            return DDPEmailServices.DDP_NAME_SEND_LETTER;
        
        }
        private set;
        
    }
    
    public String letterEmailType {
        get {
            return MergeEmailTemplate.LETTER_EMAIL;
        
        }
        private set;
    }
    
    public String templateName { 
        get { 
            return FormTemplatesServices.FORM_LETTER_WITH_ATTACHMENTS_TEMPLATE_NAME;
        
        }
        private set; 
    }
    
    public String templateDraftName { 
        get { 
            return FormTemplatesServices.FORM_LETTER_TEMPLATE_NAME;
        
        }
        private set; 
    }
    
    public List<Id> parentDocumentIds {
        get {
            if (null == this.parentDocumentIds) {
                this.parentDocumentIds = new List<Id>();
                this.parentDocumentIds.add(this.projectId);
                
                for (Service_Item__c service : this.project.Service_Items__r) {
                    this.parentDocumentIds.add(String.valueOf(service.Id));
                
                }
                
                for (Task_Item__c task : this.project.Task_Items__r) {
                    this.parentDocumentIds.add(String.valueOf(task.Id));
                
                }
                
            }
            return this.parentDocumentIds;
        
        }
        private set;
    
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
    
    public SendLetterAsAttachmentController() {
        this.projectId = ApexPages.currentPage().getParameters().get('projectId');
    
    }
    /* -------------------------------------------- Begin Set Email To/CC Section --------------------------------------------------- */

    public String emailsToDDP { get; set; }
    public String emailsCCDDP { get; set; }
    
    //Action: Update Send To Email Address in Component
    public void updateRecordTOField(){
        try {
            this.project.Email_To_Letter__c = this.emailsToDDP;
            update this.project;
        
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
   
    }
    
    //Action: Update CC To Email Address in Component    
    public void updateRecordCCField(){
        try {
            this.project.Email_CC_Letter__c = this.emailsCCDDP;
            update this.project;
        
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        
        }
    
    }
    /* -------------------------------------------- End Set Email To/CC Section --------------------------------------------------- */
    
    //Action: Close button
    public PageReference close() {
        PageReference page = new PageReference('/' + this.projectId);
        page.setRedirect(true);
        return page;
    
    }

}