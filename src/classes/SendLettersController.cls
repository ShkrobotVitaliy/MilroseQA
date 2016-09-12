public with sharing class SendLettersController {
    private static final String TASK_ITEM_OBJECT_LABEL    = 'Task Item';
    private static final String SERVICE_ITEM_OBJECT_LABEL = 'Service Item';

    public final Id projectId { 
        get;
        private set;
    }
    
    public final Id recordId {
        get;
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

    public Boolean allowToSendLetter {
        get {
            if (null == allowToSendLetter) {
                allowToSendLetter = true;
            }
            return allowToSendLetter;
        }
        set;
    }

    public SendLettersController() {
        this.recordId  = ApexPages.currentPage().getParameters().get('id');
        this.projectId = ApexPages.currentPage().getParameters().get('projectId');
        
        try{
            checkInactiveService(this.recordId);
        }catch( Exception ex ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            this.allowToSendLetter = false;
            return;
        }
    }


    @TestVisible
    private void checkInactiveService(Id recordId) {
        if (recordId == null){ return; }

        String objectLabel = AttachmentServices.getObjectName(recordId);

        if (SERVICE_ITEM_OBJECT_LABEL.equals(objectLabel)) {
            Service_Item__c serviceItem = ServiceItemServices.getServiceItemById(recordId);

            if (serviceItem.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE){
                throw new ErrorException( 'Can not create letter if Service Item is in "Inactive" status' );
            }
        } else if (TASK_ITEM_OBJECT_LABEL.equals(objectLabel)) {
            Task_Item__c taskItem = TaskItemServices.getTaskItemById(recordId);

            if (taskItem.Service_Item__r.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE){
                throw new ErrorException( 'Can not create letter if Service Item is in "Inactive" status' );
            }

        }
    }


    //Action: Clear Email Address
    public void autorun() {
        if (null == this.project.Id) { 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Parameter is empty.'));
            return;
        
        }
        
        try {
            this.project.Email_To_Letter__c = '';
            this.project.Email_CC_Letter__c = '';
            update this.project;
        
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }
    
    }
    
    //Action: Close button
    public PageReference close() {
        PageReference page = new PageReference('/' + this.recordId);
        page.setRedirect(true);
        return page;
    
    }
    
}