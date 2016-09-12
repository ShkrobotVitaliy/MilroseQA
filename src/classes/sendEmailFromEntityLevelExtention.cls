public with sharing class sendEmailFromEntityLevelExtention {
    private static final String PROJECT_OBJECT_LABEL      = 'Project';
    private static final String TASK_ITEM_OBJECT_LABEL    = 'Task Item';
    private static final String SERVICE_ITEM_OBJECT_LABEL = 'Service Item';

    private final String recordId;

    private String projectId     = '';

    private List<String> serviceItemIds;
    private List<String> taskItemIds;
    private List<String> fmdoIds;//MRS-4835

    public String emailsToDDP { get; set; }
    public String emailsCCDDP { get; set; }
    public Boolean showCopyrightInfo {
        get {
            if ( this.showCopyrightInfo == null ){
                this.showCopyrightInfo = false;
            }
            return this.showCopyrightInfo;
        }
        private set;
    }

    public String emailTypeRecord {
        get {
            return MergeEmailTemplate.STANDARD_PARSING_EMAIL;
        }
        private set;
    }

    public String DDPName {
        get {
            return DDPEmailServices.DDP_NAME_SEND_EMAIL_FROM_ENTITY;
        }
        private set;
    }

    public String draftTemplateName {
        get {
            return 'Task Item Functionality Draft';
        }
        private set;
    }

    public String emailTemplateName {
        get {
            return 'Task Item Functionality';
        }
        private set;
    }

    public List<String> recordsForAttachmentsIds {
        get {
            if (null == this.recordsForAttachmentsIds) {
                this.recordsForAttachmentsIds = new List<String> { this.project.Id, this.project.Proposal__c };

                if (null != this.serviceItemIds) {
                    this.recordsForAttachmentsIds.addall(this.serviceItemIds);

                }

                if (null != this.taskItemIds) {
                   this.recordsForAttachmentsIds.addall(this.taskItemIds);

                }

                if (null != this.fmdoIds) {//MRS-4835
                   this.recordsForAttachmentsIds.addall(this.fmdoIds);

                }

            }
            return this.recordsForAttachmentsIds;

        }
        private set;
    }


    public Project_Profile__c project {
        get {
            if (null == this.project){
                this.project = ProjectProfileServices.getProjectById( this.projectId, false );

            }
            return this.project;
        }
        set;
    }

    public List<Service_Item__c> serviceItems {
        get {
            if( serviceItems == null ) {
                return new List<Service_Item__c>( [ SELECT Id FROM Service_Item__c WHERE Project_Profile__c = : this.project.Id ] );
            }
            return serviceItems;
        }
    }

    public List<Task_Item__c> taskItems {
        get {
            if( taskItems == null ) {
                return new List<Task_Item__c>( [ SELECT Id FROM Task_Item__c WHERE Project_Profile__c = : this.project.Id ] );
            }
            return taskItems;
        }
    }

    public Boolean showSendEmailComponent {
        get {
            if (null == this.showSendEmailComponent) {
                this.showSendEmailComponent = false;

            }
            return this.showSendEmailComponent;

        }
        set;
    }

    public sendEmailFromEntityLevelExtention() {
        this.recordId = ApexPages.currentPage().getParameters().get('Id');
        this.showSendEmailComponent = false;

        try {

            setObjectIds(this.recordId);

            if (null == this.project.Id) {
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, 'Item that is used to send email should be Project or be the child of a valid Project.'));
                return;

            }

            if ( this.project.Project_State__c == ProjectProfileServices.PROJECT_STATE_CLOSED ){
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, 'You can not send Email if Project State is "Closed"'));
                return;
            }

            if ( this.project.Project_State__c == ProjectProfileServices.PROJECT_STATE_ON_HOLD ){//MRS-6683
                ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, 'You can not send Email if Project State is "On Hold"'));
                return;
            }

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return;

        }
        this.showSendEmailComponent = true;

    }

    @TestVisible
    private void setObjectIds(Id recordId) {
        if (!(this.recordId instanceof Id)) {
             throw new ErrorException('Parameter Id has not valid format.');

        }

        String objectLabel = AttachmentServices.getObjectName(recordId);
        this.serviceItemIds = new List<String>();
        this.taskItemIds    = new List<String>();
        this.fmdoIds        = new List<String>();//MRS-4835

        if (PROJECT_OBJECT_LABEL.equals(objectLabel)) {
            this.projectId = recordId;
            this.showCopyrightInfo = true;

            for (Service_Item__c service : this.serviceItems) {
                this.serviceItemIds.add(String.valueOf(service.Id));

            }

            for (Task_Item__c task : this.taskItems) {
                this.taskItemIds.add(String.valueOf(task.Id));

            }

        } else if (SERVICE_ITEM_OBJECT_LABEL.equals(objectLabel)) {
            Service_Item__c serviceItem = ServiceItemServices.getServiceItemById(recordId);

            if (serviceItem.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE){
                throw new ErrorException( 'Can not send email if Service Item is in "Inactive" status' );
            }

            this.projectId = serviceItem.Project_Profile__c;
            this.serviceItemIds.add(String.valueOf(serviceItem.Id));

            for (Task_Item__c task : serviceItem.Task_Items__r) {
                this.taskItemIds.add(String.valueOf(task.Id));

            }

        } else if (TASK_ITEM_OBJECT_LABEL.equals(objectLabel)) {
            Task_Item__c taskItem = TaskItemServices.getTaskItemById(recordId);
            this.showCopyrightInfo = true;

            if (taskItem.Service_Item__r.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE){
                throw new ErrorException( 'Can not send email if Service Item is in "Inactive" status' );
            }

            if (null != taskItem) {
                this.projectId = taskItem.Project_Profile__c;
                this.serviceItemIds.add(String.valueOf(taskItem.Service_Item__c));
                this.taskItemIds.add(String.valueOf(taskItem.Id));

            }

        }

        for (Form_Meta_Data_Object_1__c fmdoItem : [SELECT Id FROM Form_Meta_Data_Object_1__c WHERE Service_Item__r.Project_Profile__c = : this.projectId AND Service_Item__c IN : this.serviceItemIds]){//MRS-4835
            this.fmdoIds.add(String.valueOf(fmdoItem.Id));
        }
    }

    public Boolean allowToSendEmail {get; set;}
    //Action: autorun during loading page
    public void clearEmailAddress() {
        if (!this.showSendEmailComponent){
            return;
        }
        //MRS-4454
        Boolean isUserInRoster = false;
        Id currentUserId = UserInfo.getUserId();
        if( currentUserId == this.project.OwnerId || UserServices.getProfile().Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ){
            isUserInRoster = true;
        } else {
            List<Project_Roster__c> projectRostes = new List<Project_Roster__c>(ProjectRosterServices.getProjectRosterByProjectProfileId(this.project.Id));
            for( Project_Roster__c rosterItem: projectRostes ){
                if( rosterItem.User__c == currentUserId ){
                    isUserInRoster = true;
                    break;
                }
            }
        }

        allowToSendEmail = isUserInRoster;
        if( !isUserInRoster ){
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.Error, 'You don\'t have permissions to Send Emails from this project since you\'re not a part of Project Roster.'));
            return;
        }

        if (null == this.project.Id) {
            return;
        }

        try {
            this.project.EmailToRfi__c   = '';
            this.project.EmailToCCRfi__c = '';
            update this.project;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }

    }

    //Action: OnComplete Send Email
    public PageReference doFinalActions() {
        showSendEmailComponent = false;
        PageReference page = new PageReference( '/' + this.recordId);
        page.setRedirect(true);
        return page;

    }

    //Action: Update Send To Email Address in Component
    public void updateRecordTOField(){
        try {
            this.project.EmailToRfi__c = this.emailsToDDP != null ? this.emailsToDDP.substringAfter(';') : '';//MRS-6732

            update this.project;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        }

    }

    //Action: Update CC To Email Address in Component
    public void updateRecordCCField(){
        try {
            this.project.EmailToCCRfi__c = this.emailsCCDDP;
            update this.project;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        }

    }

    //Action: Close button
    public PageReference cancelAction() {
        PageReference page = new PageReference('/' + this.recordId);
        page.setRedirect(true);
        return page;

    }

}