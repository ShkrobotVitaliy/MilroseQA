public with sharing class SendLettersComponentController {
    private String recordId;
    private String projectId;
     
    public void setRecordId (String recordId) {
        this.recordId = recordId;
    
    }
    
    public String getRecordId() {
        return this.recordId;
    
    }

    public void setProjectId (String projectId) {
        this.projectId = projectId;
    
    }
    
    public String getProjectId() {
        return this.projectId;
    
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
            return FormTemplatesServices.FORM_LETTER_TEMPLATE_NAME;
        
        }
        private set; 
    }
    
    public List<Id> parentDocumentIds {
        get {
            if( null == this.parentDocumentIds ) {
                this.parentDocumentIds = new List<Id>();
                this.parentDocumentIds.add( this.projectId );
                for( Service_Item__c service : this.serviceItems ) {
                    this.parentDocumentIds.add( String.valueOf( service.Id ) );
                }
                for( Task_Item__c task : this.taskItems ) {
                    this.parentDocumentIds.add( String.valueOf( task.Id ) );
                }
            }
            return this.parentDocumentIds;
        }
        private set;
    
    }
    
    public Boolean isDisplaySearchSection { 
        get {
            if (null == this.isDisplaySearchSection) {
                this.isDisplaySearchSection = true;
            
            }
            return this.isDisplaySearchSection;
        
        }
        private set;
    
    }
    
    public Boolean isDisplaySenderRecipientSection { 
        get {
            if (null == this.isDisplaySenderRecipientSection) {
                this.isDisplaySenderRecipientSection = false;
            
            }
            return this.isDisplaySenderRecipientSection;
        
        }
        private set;
    
    }
    
    public Boolean isDisplayEmailSection { 
        get {
            if (null == this.isDisplayEmailSection) {
                this.isDisplayEmailSection = false;
            
            }
            return this.isDisplayEmailSection;
        }
        private set;
    
    }
    
     public Boolean isDisplayButtonPanel { 
        get {
            if (null == this.isDisplayButtonPanel) {
                this.isDisplayButtonPanel = false;
            
            }
            return this.isDisplayButtonPanel;
        }
        private set;
    
    }
    
    //It's property is for get contact info from page.
    public Project_Roster__c contactInfo {
        get {
            if (null == this.contactInfo) {
                this.contactInfo = new Project_Roster__c();
            
            }
            return this.contactInfo;
            
        }
        set;
    }

    public Contact recipient {
        get {
            if (null == this.recipient ) {
                if( this.contactInfo.Contact__c != null ){
                    this.recipient = ContactServices.getContactsByIds(new Set<Id> { this.contactInfo.Contact__c }).get(0);
                } else {
                    this.recipient = new Contact();
                }
            }
            return this.recipient ;
        }
        set;
    }
    
    public User sender {
        get {
            if (null == this.sender ) {
                if( this.contactInfo.User__c != null ){
                    this.sender = UserServices.getUserById(this.contactInfo.User__c);
                } else {
                    this.sender = new User();
                }
            }
            return this.sender;
        }
        set;
    }
    
    public Boolean isDisplayLetterBody {
        get {
            if (null == this.isDisplayLetterBody) {
                this.isDisplayLetterBody = false;
            
            }
            return this.isDisplayLetterBody;
            
        }
        private set;
    }
    
    public String letterName { get; set; }
    
    public String innerTemplateBody {
        get {
            if (String.isBlank(this.innerTemplateBody)) {
                this.innerTemplateBody = '';
            
            }
            return this.innerTemplateBody;
            
        }
        set;
    }
    
    public Project_Profile__c project {
        get {
            if (null == this.project) {
                this.project = ProjectProfileServices.getProjectById( getProjectId(), false );
             
            }
            return this.project;
         
        }
        set;
    }

    public List<Service_Item__c> serviceItems {
        get {
            if( serviceItems == null ) {
                return new List<Service_Item__c>( [ SELECT Id FROM Service_Item__c WHERE Project_Profile__c = : getProjectId() ] );
            }
            return serviceItems;
        }
    }

    public List<Task_Item__c> taskItems {
        get {
            if( taskItems == null ) {
                return new List<Task_Item__c>( [ SELECT Id FROM Task_Item__c WHERE Project_Profile__c = : getProjectId() ] );
            }
            return taskItems;
        }
    }

    /* -------------------------------------------- Begin Search Section --------------------------------------------------- */
    public String regionName {
        get {
            if ( String.isEmpty ( regionName ) )
                { regionName = RegionServices.REGION_NAME_NY; }
            return regionName;
        }
        set;
    }
    public String municipalityFilter { get; set; }
    public String refNumberFilter { get; set; }
    public String shortNameFilter { get; set; }
    public String fullNameFilter { get; set; }
    public String letterRecordId { get; set; }
    
    public List<selectOption> regionOptions {
        get{
            if (null == this.regionOptions) {
                this.regionOptions = RegionServices.getRegionOptions();
            
            }
            return this.regionOptions;
        
        }
        private set;
    
    }
    
    public List<Form_Template__c> formTemplates {
        get { 
            if (null == this.formTemplates) { 
                this.formTemplates = new List<Form_Template__c>(); 
            
            }
            return this.formTemplates; 
        } 
        set;
    }
    
    //Action: button Search
    public void search() {
        String queryWhere = FormTemplatesServices.buildQueryWhere(this.refNumberFilter, this.shortNameFilter, this.fullNameFilter, this.municipalityFilter, this.regionName, false, false, true);
        String query      = FormTemplatesServices.buildQuery(queryWhere);
        this.formTemplates = Database.query(query);
        
    }
    
    //Action: Select Letter
    public void selectLetter() {
        Map<Id, Form_Template__c> formMap = new Map<Id, Form_Template__c>(this.formTemplates);

        if (!formMap.containsKey(this.letterRecordId)) {
            return;
        
        }        
        
        try {
            this.innerTemplateBody = formMap.get(this.letterRecordId).Letter_Body__c;
            this.letterName        = formMap.get(this.letterRecordId).Form_Name__c;
            
            this.isDisplaySearchSection          = false;
            this.isDisplaySenderRecipientSection = true;
            
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ex.getMessage()));
            return;
            
        }  
    
    }
    
    //Action: Back to Search Letter
    public void backToSearch() {
        this.isDisplaySearchSection          = true;
        this.isDisplaySenderRecipientSection = false;
            
    }
    
     //Action: Move to Letter
    public void moveToLetter() {
        if (null == contactInfo.Contact__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Please fill in field recipient.'));
            return;
        
        }
    
        if (null == contactInfo.User__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Please fill in field sender.'));
            return;
        
        }
        
        this.innerTemplateBody = MergeEmailTemplate.mergeLetterBody(this.innerTemplateBody, 
                                                                    this.project, 
                                                                    sender, 
                                                                    recipient);
        
        this.isDisplaySenderRecipientSection = false;
        this.isDisplayEmailSection           = false;
        this.isDisplayLetterBody             = true; 
        this.isDisplayButtonPanel            = true;
    
    }
    /* -------------------------------------------- End Search Section --------------------------------------------------- */
    
    /* --------------------------------------------- Begin Buttons Action --------------------------------------------------------------*/
    
    //Action: Back to Back to Choose Sender/Recipient
    public void backToChooseSenderRecipient() {
        this.isDisplaySenderRecipientSection = true;
        this.isDisplayEmailSection           = false; 
        this.isDisplayButtonPanel            = false;
        this.isDisplayLetterBody             = false;
    
    }
    
    //Action: Send as Email
    public void sendAsEmail() {
        this.isDisplayEmailSection = true;
        this.isDisplayLetterBody   = false;
        this.isDisplayButtonPanel  = false;
        this.isDisplayLetterBody   = false;
    
    }

    public Boolean isTaskItem { get { if( isTaskItem == null ) isTaskItem = String.valueOf( getRecordId() ).substring(0, 3).equals( Task_Item__c.SObjectType.getDescribe().getKeyPrefix() ); return isTaskItem; } set; }
    public Boolean isServiceItem { get { if( isServiceItem == null ) isServiceItem = String.valueOf( getRecordId() ).substring(0, 3).equals( Service_Item__c.SObjectType.getDescribe().getKeyPrefix() ); return isServiceItem; } set; }

    private static final Integer MAX_SUPPORTED_NUMBER_OF_MERGE_FIELDS = 3;
    
    //Action: Attach PDF
    public PageReference attachLetterAsPDF() {
       try {
            Id targetId = null;
            String ddpName = '';
            Integer latestFieldNumber = 0; /*MRS-6168*/
            Integer nextFieldNumber = 1;

            Project_Profile__c projectForLatestLetterNumber = [ SELECT Letter_Project_Latest_Number__c, Letter_Service_Latest_Number__c, Letter_Task_Latest_Number__c
                                                                FROM Project_Profile__c
                                                                WHERE Id = : this.project.Id ][0];

            String letterNameWithDate = this.letterName + ' - ' + String.valueOf( date.today() );

            if( this.isTaskItem ) {
                try {
                    latestFieldNumber = projectForLatestLetterNumber.Letter_Task_Latest_Number__c == null ? 0 : Integer.valueOf( projectForLatestLetterNumber.Letter_Task_Latest_Number__c );
                } catch( Exception e ) {
                    latestFieldNumber = 0;
                }
                nextFieldNumber = latestFieldNumber == MAX_SUPPORTED_NUMBER_OF_MERGE_FIELDS ? 1 : latestFieldNumber + 1;
                this.project.Letter_Task_Latest_Number__c = nextFieldNumber;

                targetId = this.recordId;
                ddpName = DDPEmailServices.DDP_NAME_ATTACH_LETTER_TASK + ' ' + String.valueOf( nextFieldNumber );
                if( nextFieldNumber == 1 ) {
                    this.project.Letter_Name_Task_1__c = letterNameWithDate;
                    this.project.Letter_Body_Task_1__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 2 ) {
                    this.project.Letter_Name_Task_2__c = letterNameWithDate;
                    this.project.Letter_Body_Task_2__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 3 ) {
                    this.project.Letter_Name_Task_3__c = letterNameWithDate;
                    this.project.Letter_Body_Task_3__c = this.innerTemplateBody;
                }
            } else if( this.isServiceItem ) {
                try {
                    latestFieldNumber = projectForLatestLetterNumber.Letter_Service_Latest_Number__c == null ? 0 : Integer.valueOf( projectForLatestLetterNumber.Letter_Service_Latest_Number__c );
                } catch( Exception e ) {
                    latestFieldNumber = 0;
                }
                nextFieldNumber = latestFieldNumber == MAX_SUPPORTED_NUMBER_OF_MERGE_FIELDS ? 1 : latestFieldNumber + 1;
                this.project.Letter_Service_Latest_Number__c = nextFieldNumber;

                targetId = this.recordId;
                ddpName  = DDPEmailServices.DDP_NAME_ATTACH_LETTER_SERVICE + ' ' + String.valueOf( nextFieldNumber );
                if( nextFieldNumber == 1 ) {
                    this.project.Letter_Name_Service_1__c = letterNameWithDate;
                    this.project.Letter_Body_Service_1__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 2 ) {
                    this.project.Letter_Name_Service_2__c = letterNameWithDate;
                    this.project.Letter_Body_Service_2__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 3 ) {
                    this.project.Letter_Name_Service_3__c = letterNameWithDate;
                    this.project.Letter_Body_Service_3__c = this.innerTemplateBody;
                }
            } else {
                try {
                    latestFieldNumber = projectForLatestLetterNumber.Letter_Project_Latest_Number__c == null ? 0 : Integer.valueOf( projectForLatestLetterNumber.Letter_Project_Latest_Number__c );
                } catch( Exception e ) {
                    latestFieldNumber = 0;
                }
                nextFieldNumber = latestFieldNumber == MAX_SUPPORTED_NUMBER_OF_MERGE_FIELDS ? 1 : latestFieldNumber + 1;
                this.project.Letter_Project_Latest_Number__c = nextFieldNumber;

                targetId = this.projectId;
                ddpName  = DDPEmailServices.DDP_NAME_ATTACH_LETTER_PROJECT + ' ' + String.valueOf( nextFieldNumber );
                if( nextFieldNumber == 1 ) {
                    this.project.Letter_Name_Project_1__c = letterNameWithDate;
                    this.project.Letter_Body_Project_1__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 2 ) {
                    this.project.Letter_Name_Project_2__c = letterNameWithDate;
                    this.project.Letter_Body_Project_2__c = this.innerTemplateBody;
                } else if( nextFieldNumber == 3 ) {
                    this.project.Letter_Name_Project_3__c = letterNameWithDate;
                    this.project.Letter_Body_Project_3__c = this.innerTemplateBody;
                }
            }
            UPDATE this.project;
            if( null == targetId || String.isBlank(ddpName) ) {
                ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ErrorException.REQUIRED_PARAMETER_DDP_EMPTY ) );
                return null;
            }

            DDPRequest request = new DDPRequest();
            request.addConfiguration( targetId, ddpName, DDPEmailServices.DELIVERY_METHOD_ATTACH );
            request.sendRequest();
            return close();
            //return DDPEmailServices.createDDPLoopPlus( ddpName, DDPEmailServices.DELIVERY_METHOD_ATTACH, targetId, null, null, '/' + this.recordId, null, true );

        } catch( Exception ex ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
            return null;
        }
    }
    
    //Action: Close button
    public PageReference close() {
        PageReference page = new PageReference('/' + this.recordId);
        page.setRedirect(true);
        return page;
    
    }
    /* --------------------------------------------- End Buttons Action --------------------------------------------------------------*/
    
    /* -------------------------------------------- Begin Set Email To/CC Section --------------------------------------------------- */

    public String emailsToDDP { get; set; }
    public String emailsCCDDP { get; set; }
    
    //Action: Update Send To Email Address in Component
    public void updateRecordTOField(){
        try {
            this.project.Email_To_Letter__c = this.emailsToDDP != null ? this.emailsToDDP.substringAfter(';') : '';//MRS-6732
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

}