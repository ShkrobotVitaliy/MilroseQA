public with sharing class ManageResponseFromAuthorityExtention {
    public final Task_Item__c taskItem { get; set; }
    public Map<Id, Manage_Response_From_Authority__c> authorityResponseDataMap {get{ return new Map<Id, Manage_Response_From_Authority__c>( authorityResponseDataRows );} set;}
    public List<Manage_Response_From_Authority__c> authorityResponseDataRows {get; set;}
    
    public Contact contactRecipient {
        get {
            if (null == this.contactRecipient) {
                this.contactRecipient = new Contact();
        
            }
            return this.contactRecipient;
        }
        set;
    }
    
    public Project_Profile__c projectProfileItem {
        get {
            if (null == this.projectProfileItem) {
                 this.projectProfileItem = ProjectProfileServices.getProjectById(taskItem.Project_Profile__c);
            
            }
            return this.projectProfileItem;
        }
        set;
    }
    
    public Id manageResponseItemToSendEmailId {
        get{ 
            manageResponseItemToSendEmailId = null;
            for( Manage_Response_From_Authority__c recordItem: authorityResponseDataRows ){
                if( recordItem.Sent_VIA__c == ManageResponseFromAuthorityServices.SENT_VIA_EMAIL && !recordItem.Is_Email_Sent__c){
                    manageResponseItemToSendEmailId = recordItem.Id;
                    break;
                }
            }
            return manageResponseItemToSendEmailId;
        }
        set;
    }
    public Manage_Response_From_Authority__c manageResponseItemToSendEmail {
        get{
            return authorityResponseDataMap.containsKey(manageResponseItemToSendEmailId) ? authorityResponseDataMap.get(manageResponseItemToSendEmailId) : new Manage_Response_From_Authority__c();
        } 
        set;
    }
    
    public List<SelectOption> rosterIdToRoleOptions {
        get {
            if (null == this.rosterIdToRoleOptions) {
                this.rosterIdToRoleOptions = new List<SelectOption>();
                this.rosterIdToRoleOptions.add(new SelectOption ('', '-- None --'));
                
                for (Project_Roster__c roster : projectRostersMap.values()) {                
                    if (!String.isBlank(roster.Role__c)) {
                        rosterIdToRoleOptions.add(new SelectOption(roster.Id, roster.Role__c + ' ' + roster.Name__c, !roster.Active__c)); //MRS-6868
                    
                    }
                
                }
            
            }
            return this.rosterIdToRoleOptions;
            
        } 
        set;
    }
    
    public String linkToCloseTemplate { get; private set;}
    
    public ManageResponseFromAuthorityExtention (ApexPages.StandardController controller) {
        this.taskItem            = (Task_Item__c)controller.getRecord();
        this.linkToCloseTemplate =  '/' + String.valueOf(this.taskItem.Id);
        
        initResponseDataRows();
        
    }
    
    
    private void initResponseDataRows() {
        findRecordToSendEmail = false;
        showTemplateEditor = false;
        authorityResponseDataRows = new List<Manage_Response_From_Authority__c>([SELECT Id, Use_Alert__c, Task_Item__c, Sent_VIA__c, Sent_Tracking__c, Sent_Date_Time__c, 
                                                                                    Received_VIA__c, Received_Tracking__c, Received_Date_Time__c, Project_Roster__c, Project_Roster_Name__c, 
                                                                                    Is_Email_Sent__c, Artifacts__c, Alert_Time__c, Email_To__c, Email_To_CC__c, Project_Roster__r.Contact__c
                                                                                FROM Manage_Response_From_Authority__c
                                                                                WHERE Task_Item__c =: taskItem.Id ORDER BY CreatedDate]);
    }
    
    private Map<Id, Project_Roster__c> projectRostersMap {
        get {
            if (null == this.projectRostersMap) {
                this.projectRostersMap = new Map<Id, Project_Roster__c>(ProjectRosterServices.getRosterByProjectId(taskItem.Project_Profile__c)); 
                                                             
            }
            return this.projectRostersMap;
        
        }
        set;
    }

    public String manageResponseItemId {get; set;}
    public void updateDataRowsAction() {
        for( Manage_Response_From_Authority__c record : authorityResponseDataRows ) {
            if( record.Alert_Time__c != null && record.Received_Date_Time__c != null ) {
                if( record.Alert_Time__c > record.Received_Date_Time__c ) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, '"Received Date Time" cannot be less than "Alert DateTime".'));
                    return; 
                }
            }
        }
        try {
            upsert authorityResponseDataRows;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        initResponseDataRows();
    }
    public void addNewDataRowAction (){
        Manage_Response_From_Authority__c manageResponseRecord = new Manage_Response_From_Authority__c(Task_Item__c = taskItem.Id);
        try {
            insert manageResponseRecord;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        authorityResponseDataRows.add( manageResponseRecord );
    }
    public void deleteDataRowAction (){
        try {
            delete authorityResponseDataMap.get( manageResponseItemId );
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        initResponseDataRows();
    }

    /* Email Section --------------------------------------------------------------------------------------- */
  
    private final String EMAIL_TEMPLATE_DRAFT_NAME = 'Manage Response from Authority Draft';
    private final String EMAIL_TEMPLATE_NAME = 'Manage Response from Authority';

    public String DDPName {get{ return DDPEmailServices.DDP_NAME_MANAGE_RESPONSE_FROM_AUTHORITY;}}
    public String emailTemplateName { get{ return EMAIL_TEMPLATE_NAME;} }
    public String draftTemplateName { get{ return EMAIL_TEMPLATE_DRAFT_NAME;} }

    public List<String> recordsForAttachmentsIds {
        get{
            if( recordsForAttachmentsIds == null ){
                recordsForAttachmentsIds = new List<String>{taskItem.Id, taskItem.Service_Item__c, taskItem.Project_Profile__c, taskItem.Project_Profile__r.Proposal__c};
                for( RFI_Scope__c rfi: projectProfileItem.RFI_Scopes__r){
                    recordsForAttachmentsIds.add(rfi.Id);
                }
            }
            return recordsForAttachmentsIds;
        }
        set;
    }

    public String emailTypeRecord { get{ return MergeEmailTemplate.STANDARD_PARSING_EMAIL; } set; }

    public Boolean showTemplateEditor {get{if(showTemplateEditor == null) showTemplateEditor = false; return showTemplateEditor;}  set;}
    private Boolean findRecordToSendEmail = false;
    
    public void previewEmailForCurrentRecordAction(){
        //System can send email only to contact, NOT User.
        if (null == this.manageResponseItemToSendEmail.Project_Roster__r.Contact__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
            return;
        
        }
        this.contactRecipient.Id = this.manageResponseItemToSendEmail.Project_Roster__r.Contact__c;
        
        showTemplateEditor = false;
        
        if( emailTemplate.Id == null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are not available email templates.'));
            return;
        }
        
        findRecordToSendEmail = true;
        
        if( manageResponseItemToSendEmailId == null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are no records to send Email( \'VIA\' should be Email and \'Email Sent\' should be unchecked)'));
            return;
        }
        
        if( String.isBlank( manageResponseItemToSendEmail.Artifacts__c ) ||  String.isBlank( manageResponseItemToSendEmail.Project_Roster__c ) ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please specify \'Artifacts\' and \'Role\' fields for current record in order to send Email)'));
            return;
        }
        
        updateDataRowsAction();
        showTemplateEditor = true;
    
    }

    public String emailsToDDP {get; set;}
    public void updateRecordCCField(){
        if( !String.isBlank(emailsToDDP) ){
            try {
                Manage_Response_From_Authority__c recordToUpdate = new Manage_Response_From_Authority__c( Id = manageResponseItemToSendEmailId, Email_To_CC__c = emailsToDDP );
                update recordToUpdate;
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Emails were not added to CC! Please try again!'));
                return;
            }
        }
    }
    public void updateRecordToSendEmail(){
        try{
            Manage_Response_From_Authority__c recordToUpdate = new Manage_Response_From_Authority__c( Id = manageResponseItemToSendEmailId, Is_Email_Sent__c = true, Sent_Date_Time__c = datetime.now() );
            upsert recordToUpdate;
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occured during sending email: ' + ex.getMessage()));
            return;
        }
        initResponseDataRows();
    }

    /* End Email Functionality -------------------------------------------------------------------------------------------------------------- */
}