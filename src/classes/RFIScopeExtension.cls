public with sharing class RFIScopeExtension {
    private String SUBMITTED_RFI_SCOPE = 'You have already submitted {0} .Are you sure you want to submit it again?';
    private String RFI_SECTION_EXIST   = 'This RFI Scope already exists for the specified Service Group.';
    private final Id regionId;
    private final String regionName;
    private final Project_Profile__c project;
    private String publishType = null;

    private Map<Id, RFI_Scope__c> rfiRegionScopes;
    private transient Map<Id, Service_Item__c> serviceItemGroup;
    private transient Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItems;

    private List<Project_Roster__c> rosters {
        get {
            if (null == this.rosters) {
                this.rosters = ProjectRosterServices.getRosterByProjectId(this.projectId);

            }
            return this.rosters;

        }
        set;
    }

    public Boolean renderedUploadPanel {
        get {
            if (null == this.renderedUploadPanel) {
                this.renderedUploadPanel = true;
                Profile profile = UserServices.getProfile();
                
                if ( ( profile.Name.equals(UserServices.PROFILE_PROJECT_MANAGER_1) || profile.Name.equals(UserServices.PROFILE_PROJECT_MANAGER_1_QA) ) ||
                    (profile.Name.equals(UserServices.PROFILE_PROJECT_MANAGER_2) || profile.Name.equals(UserServices.PROFILE_PROJECT_MANAGER_2_QA)) ) {
                    this.renderedUploadPanel = false;
                
                }
            }
            return this.renderedUploadPanel;
        }
        set;
    }

    public String getPublishType() {
        return this.publishType;

    }

    public void setPublishType(String publishType) {
        this.publishType = publishType;

    }

    public String currentRFIScope {
        get;
        set;
    }

    public RFI_Scope__c rfiScopeItem {
        get {
            if (null == this.rfiScopeItem &&!String.isBlank(this.currentRFIScope)) {
                this.rfiScopeItem = RFIScopeServices.getRFIScopesById(this.currentRFIScope, this.regionName);

            }
            return this.rfiScopeItem;
        }
        set;
    }

    public final String projectId { get; private set; }
    public String monitorItemId { get; set; }
    public PageReference iFrameDocuments { get; set; }
    public PageReference iFrameDrawings { get; set; }
    public String storageFolderName { get; set; }

    public String selectedRegionRfi { get; set; }
    public String selectedServiceGroupNumber { get; set; }

    public List<SelectOption> rosterIdToContact {
        get {
            if (null == this.rosterIdToContact) {
                this.rosterIdToContact = new List<SelectOption>();
                this.rosterIdToContact.add(new SelectOption ('', '-- None --'));

                for (Project_Roster__c roster : this.rosters) {
                    if (!String.isBlank(roster.Role__c)) {
                        this.rosterIdToContact.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c)); //MRS-6868

                    }

                }

            }
            return this.rosterIdToContact;
        }
        set;
    }

    public Map<String, String> rosterIdToEmail {
        get {
            if (null == this.rosterIdToEmail) {
                this.rosterIdToEmail = new Map<String, String>();

                for (Project_Roster__c roster : this.rosters) {
                    if (!String.isBlank(roster.Role__c) && !this.rosterIdToEmail.containsKey(roster.Id)) {
                        this.rosterIdToEmail.put(roster.Id, String.isBlank(roster.Email__c) ? '' : roster.Email__c);

                    }

                }

            }
            return this.rosterIdToEmail;

        }
        set;
    }

    public String typeSubmit { get; set; }
    public Boolean isCheckedAlert { get; set; }

    public String rfiIdToNotes {
        get {
            Id rfiId = getRFIScope().Id;

            if (null != rfiId) {
                //Populate Notes
                List<Note> parentIdToNote = getParentIdToNoteList(rfiId);
                return !parentIdToNote.isEmpty() ? NotesServices.joinNotes(parentIdToNote) : '';

            }
            return '';

        }
        set;
    }

    public List<selectOption> getSubmitedType {
        get {
            List<SelectOption> submitedType = new List<SelectOption>();
            submitedType.add(new SelectOption ('Application', 'Publish Pending Application'));
            submitedType.add(new SelectOption ('SignOff', 'Publish Pending Sign-Off'));
            return submitedType;

        }
        private set;

    }

    public List<selectOption> getSendViaType {
        get {
            List<SelectOption> sendViaType = new List<SelectOption>();
            sendViaType.add(new SelectOption('Call', 'Call'));
            sendViaType.add(new SelectOption('Email', 'Email'));
            sendViaType.add(new SelectOption('Other', 'Other'));
            return sendViaType;

        }
        private set;

    }

    public List<RFI_Scope__c> orderRFIScopes {
        get {
            if (null == this.orderRFIScopes) {
                this.orderRFIScopes = RFIScopeServices.getRFIScopesOrderedByGroupNumber(this.project.Id);

            }
            return this.orderRFIScopes;
        }
        private set;
    }

    public List<Monitor_RFI_Scope__c> rfiIdToApplicationSubmitScope {
        get {
            if (null == this.rfiIdToApplicationSubmitScope) {
                this.rfiIdToApplicationSubmitScope = new List<Monitor_RFI_Scope__c>();

            }
            return this.rfiIdToApplicationSubmitScope;
        }
        set;
    }

    public List<Monitor_RFI_Scope__c> rfiIdToSignOffSubmitScope {
        get {
            if (null == this.rfiIdToSignOffSubmitScope) {
                this.rfiIdToSignOffSubmitScope = new List<Monitor_RFI_Scope__c>();

            }
            return this.rfiIdToSignOffSubmitScope;
        }
        set;
    }

    public RFIScopeExtension(ApexPages.StandardController controller) {
        this.project    = (Project_Profile__c)controller.getRecord();
        this.projectId  = this.project.Id;
        this.regionId   = this.project.Building__r.Municipality__r.Region__r.Id;
        this.regionName = this.project.Building__r.Municipality__r.Region__r.Name;

    }

    private Map<Id, RFI_Scope__c> getRegionRFIScopes() {
        if (null == this.rfiRegionScopes) {
            this.rfiRegionScopes = RFIScopeServices.getRFIScopesByRegionIds(new Set<Id>{ this.regionId });

        }
        return this.rfiRegionScopes;

    }

    public List<SelectOption> getListRfiRegionScopes() {
        List<SelectOption> rfiRegionOptions = new List<SelectOption>();

        for (RFI_Scope__c rfi : getRegionRFIScopes().values()) {
            rfiRegionOptions.add(new SelectOption(rfi.Id, rfi.RFI_Section__c));

        }
        return rfiRegionOptions;

    }

    private Map<Id, Service_Item__c> getServiceItemGroup() {
        if (null == this.serviceItemGroup) {
            this.serviceItemGroup = ServiceItemServices.getServiceItemsByProjectId(this.projectId);

        }
        return this.serviceItemGroup;

    }

    public List<SelectOption> getListServiceItemGroupNumbers() {
        List<SelectOption> groupNumberOptions = new List<SelectOption>();
        this.serviceGroupNumberToServiceItems = new Map<Decimal, List<Service_Item__c>>();

        //Group Service Items by Group Number
        for (Service_Item__c serviceItem : this.getServiceItemGroup().values()) {
            if (null != serviceItem.Service_Group__c) {
                if (!this.serviceGroupNumberToServiceItems.containsKey(serviceItem.Service_Group__c)) {
                    this.serviceGroupNumberToServiceItems.put(serviceItem.Service_Group__c, new List<Service_Item__c>());

                }
                this.serviceGroupNumberToServiceItems.get(serviceItem.Service_Group__c).add(serviceItem);

            }

        }

        for (Decimal key : this.serviceGroupNumberToServiceItems.keySet()) {
            groupNumberOptions.add(new SelectOption(String.ValueOf(key), String.valueOf(key)));

        }
        return groupNumberOptions;

    }

    public RFI_Scope__c getRFIScope() {
        RFISingletonInstance.INSTANCE.rfiScope = this.rfiScopeItem;
        return RFISingletonInstance.INSTANCE.rfiScope;

    }

    public void selectRFIScope() {
        if (String.isBlank(this.currentRFIScope)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'RFI Scope Id is empty.'));
            return;

        }

        this.rfiScopeItem = null;
        RFISingletonInstance.INSTANCE.rfiScope = this.rfiScopeItem;

        //Populate Monitoring RFI Scopes
        this.rfiIdToApplicationSubmitScope = new List<Monitor_RFI_Scope__c>();
        this.rfiIdToSignOffSubmitScope     = new List<Monitor_RFI_Scope__c>();

        for (Monitor_RFI_Scope__c monitor : RFISingletonInstance.INSTANCE.rfiScope.Monitor_RFI_Scopes__r) {
            if (monitor.Submit_Type__c.equals(RFIScopeServices.APPLICATION_TYPE)) {
                this.rfiIdToApplicationSubmitScope.add(monitor);

            } else if (monitor.Submit_Type__c.equals(RFIScopeServices.SIGN_OFF_TYPE)) {
                this.rfiIdToSignOffSubmitScope.add(monitor);

            }

        }

    }

    private List<Note> getParentIdToNoteList(Id parentId) {
        return NotesServices.retrieveNotes(parentId);
    
    }

    //Action Button: Copy to Sign Off
    public void CopyToSignOff() {
        SObject rfiDescr;
        
        if (null != RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_New_York__r) {
            rfiDescr = RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_New_York__r;
        
        } else if (null != RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_Long_Island__r) {
            rfiDescr = RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_Long_Island__r;
        
        } else if (null != RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_New_Jersey__r) {
            rfiDescr = RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_New_Jersey__r;
        
        } else if (null != RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_CT__r) {
            rfiDescr = RFISingletonInstance.INSTANCE.rfiScope.RFI_Scope_Description_CT__r;
        
        }
        
        RFIScopeServices.copyAppToSignOff(rfiDescr, RFISingletonInstance.INSTANCE.rfiScope.RFI_Work_Types__r, true);
        updateRFI(RFISingletonInstance.INSTANCE.rfiScope);

    }

    //Action Button: Save
    public void updateRfiScopes() {
        updateRFI(RFISingletonInstance.INSTANCE.rfiScope);

    }

    //Action: Save Changes
    private void updateRFI(RFI_Scope__c rfi) {
        rfi.Documents__c = false;
        rfi.Drawings__c  = false;

        Savepoint sp = Database.setSavepoint();
        
        try {

            String currentNode = rfi.Notes__c;

            List<Note> notes = getParentIdToNoteList(rfi.Id);

            if (!String.isBlank(currentNode)) {
                NotesServices.filterAndSaveNotes(rfi.Id, notes, new Note(parentId = rfi.Id, Title = 'RFI Scope Note'), currentNode);

            }
            //Clear Note Value
            rfi.Notes__c = '';

            update rfi;
            
            if (null != rfi.RFI_Scope_Description_New_York__r) {
                update rfi.RFI_Scope_Description_New_York__r;
            
            }
            
            if (null != rfi.RFI_Scope_Description_Long_Island__r) {
                update rfi.RFI_Scope_Description_Long_Island__r;
            
            }
            
            if (null != rfi.RFI_Scope_Description_New_Jersey__r) {
                update rfi.RFI_Scope_Description_New_Jersey__r;
            
            }
            
            if (null != rfi.RFI_Scope_Description_CT__r) {
                update rfi.RFI_Scope_Description_CT__r;
            
            }
            
            if (null != rfi.RFI_Scope_Description_PA__r) {
                update rfi.RFI_Scope_Description_PA__r;
            
            }
            
            if (null != rfi.RFI_Scope_Description_DC__r) {
                update rfi.RFI_Scope_Description_DC__r;
            
            }
            update rfi.RFI_Work_Types__r;
            update rfi.Monitor_RFI_Scopes__r;

        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception occured during update rfi scope item: ' + ex.getMessage()));
            return;
        
        }
    
    }

    //Action: Upload documents
    public void manageFileUpload() {
        List<LStore__Stored_Document__c> storedDocsFolder = StoredDocumentServices.getStoredDocumentFolder(StoredDocumentServices.FOLDER_RECORD_TYPE_ID, this.storageFolderName, String.valueOf(RFISingletonInstance.INSTANCE.rfiScope.Id));

        if (storedDocsFolder.isEmpty()) {
            LStore__Stored_Document__c newDocsFolder = new LStore__Stored_Document__c(RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID, LStore__File_Name__c = this.storageFolderName,
                                                                                      LStore__Related_Object_Id__c = String.valueOf(RFISingletonInstance.INSTANCE.rfiScope.Id), LStore__Keywords__c = this.storageFolderName);

            try {
                insert newDocsFolder;
                storedDocsFolder.add(newDocsFolder);

            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception occured during insert folder: ' + ex.getMessage()));
                return;

            }

        }
        PageReference page = new PageReference('/apex/storedDocInlineRFIScope');
        
        if (this.storageFolderName.equals('Additional Documents')) {
            page.getParameters().put('fid', storedDocsFolder[0].Id);
            page.getParameters().put('eid', String.valueOf(RFISingletonInstance.INSTANCE.rfiScope.Id).left(15));
            page.getParameters().put('fileTypesName', StoredDocumentServices.DOCUMENTS_FILE_TYPE);

            this.iFrameDocuments = page;

        } else if (this.storageFolderName.equals('Drawings')) {
            page.getParameters().put('fid', storedDocsFolder[0].Id);
            page.getParameters().put('eid', String.valueOf(RFISingletonInstance.INSTANCE.rfiScope.Id).left(15));
            page.getParameters().put('fileTypes', '*.dwg; *.dxf; *.pdf; *.jpg; *.tif; *.tiff');
            page.getParameters().put('fileTypesName', StoredDocumentServices.DRAWINGS_FILE_TYPE);

            this.iFrameDrawings = page;

        }

    }

    //Acrion: Add rfi scope
    public void addRfiScopes() {
        if (String.isBlank(this.selectedRegionRfi)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'RFI Scope does not exist.'));
            return;

        }

        if (String.isBlank(this.selectedServiceGroupNumber)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Group Number does not exist.'));
            return;

        }
                
        RFI_Scope__c rfiTemplate;
        List<Service_Item__c> serviceItems;

        if (this.rfiRegionScopes.containsKey(this.selectedRegionRfi)) {
            rfiTemplate = this.rfiRegionScopes.get(this.selectedRegionRfi);

        }
        
        if (null == rfiTemplate ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'System cannot find RFI Scope Template.'));
            return;
        
        }
        
        if (isRFISectionExist(rfiTemplate.Name, Decimal.valueOf(this.selectedServiceGroupNumber))) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, RFI_SECTION_EXIST));
            return;
        
        }
        
        if (this.serviceGroupNumberToServiceItems.containsKey(Decimal.valueOf(this.selectedServiceGroupNumber))) {
            serviceItems = this.serviceGroupNumberToServiceItems.get(Decimal.valueOf(this.selectedServiceGroupNumber));

        }

        try {
            RFIScopeServices.createAdditionalRfiScopes(this.regionId, this.projectId, rfiTemplate, serviceItems, this.rosters, this.regionName);

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ' Exception occured during create additional rfi scope items: ' + ex.getMessage()));
            return;

        } finally {
            this.orderRFIScopes = null;
            RFISingletonInstance.INSTANCE.rfiScope = null;
            this.currentRFIScope = null;

        }

    }
    
    @testVisible
    private Boolean isRFISectionExist(final String rfiTemplateName, final Decimal groupNumber) {
        for (RFI_Scope__c rfiItem : orderRFIScopes) {
            if (rfiItem.Name.equals(rfiTemplateName) && rfiItem.Group_Number__c == groupNumber) {
                return true;

            }
        
        }
        return false;
    
    }
    
    //Action Button: Submit Application
    public void submitApp() {
        if (String.isBlank(RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__c)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please populate Send to Contact field!'));
            return;

        }

        if (String.isBlank(rosterIdToEmail.get(RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__c))) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Roster does not have email address!'));
            return;

        }

        if (RFISingletonInstance.INSTANCE.rfiScope.Submit_Application__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, String.format(SUBMITTED_RFI_SCOPE, new String[] { RFISingletonInstance.INSTANCE.rfiScope.RFI_Section__c }) ));
            return;
        
        }

        RFISingletonInstance.INSTANCE.rfiScope.Submit_Application__c = true;
        RFISingletonInstance.INSTANCE.rfiScope.App_Status__c         = 'Received';
        RFISingletonInstance.INSTANCE.rfiScope.Status__c             = 'Received';
        updateRFI(RFISingletonInstance.INSTANCE.rfiScope);

    }

    //Action Button: Submit Sign Off
    public void submitSignOff() {
        if (String.isBlank(RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__c)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please populate Send to Contact field!'));
            return;

        }

        if (String.isBlank(rosterIdToEmail.get(RFISingletonInstance.INSTANCE.rfiScope.Project_Roster__c))) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Roster does not have email address!'));
            return;

        }
        
        if (RFISingletonInstance.INSTANCE.rfiScope.Submit_Sign_Off__c) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, String.format(SUBMITTED_RFI_SCOPE, new String[] { RFISingletonInstance.INSTANCE.rfiScope.RFI_Section__c }) ));
            return;
        
        }
        
        RFISingletonInstance.INSTANCE.rfiScope.Submit_Sign_Off__c = true;
        RFISingletonInstance.INSTANCE.rfiScope.Sign_Off_Status__c = 'Received';
        RFISingletonInstance.INSTANCE.rfiScope.Status__c          = 'Received';
        updateRFI(RFISingletonInstance.INSTANCE.rfiScope);

    }

    //Action: Set Recieved Date
    public void setLastReceived() {
        try {
            Map<Id, Monitor_RFI_Scope__c> trackingMap = new Map<Id, Monitor_RFI_Scope__c>(RFISingletonInstance.INSTANCE.rfiScope.Monitor_RFI_Scopes__r);

            if (this.typeSubmit.equals('App')) {
                RFISingletonInstance.INSTANCE.rfiScope.Last_RFI_Received__c  = trackingMap.get(this.monitorItemId).Received__c;
                RFISingletonInstance.INSTANCE.rfiScope.Status__c             = 'Received';
                RFISingletonInstance.INSTANCE.rfiScope.App_Status__c         = 'Received';
                RFISingletonInstance.INSTANCE.rfiScope.Submit_Application__c = false;

            } else if (this.typeSubmit.equals('SignOff')) {
                RFISingletonInstance.INSTANCE.rfiScope.Last_SignOff_RFI_Received__c = trackingMap.get(this.monitorItemId).Received__c;
                RFISingletonInstance.INSTANCE.rfiScope.Status__c                    = 'Received';
                RFISingletonInstance.INSTANCE.rfiScope.Sign_Off_Status__c           = 'Received';
                RFISingletonInstance.INSTANCE.rfiScope.Submit_Sign_Off__c           = false;

            }

            for (Monitor_RFI_Scope__c trackItem : RFISingletonInstance.INSTANCE.rfiScope.Monitor_RFI_Scopes__r) {
                if (trackItem.Id == this.monitorItemId) {
                    trackItem.Is_Lock__c = true;

                }

            }

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Date time format is not valid!'));
            return;

        }

    }

}