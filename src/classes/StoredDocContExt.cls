global with sharing class StoredDocContExt { //MRS 6809
    public static final String NO_AUTHOR_MESSAGE = 'Authors cannot be displayed. There are no Project Rosters saved for current Proposal.';
    public static final String PROPOSAL_DOCUMENTS_FOLDER_NAME = 'Proposal & CO';

    private final Sobject sobj;
    private String folderDocName;
    private String folderDocId;
    public String profileName { get { if( profileName == null ) profileName = UserServices.getProfile().Name; return profileName; } private set; }

    public Date drawingsRevisionDate { get; set; }

    //This variable is used to show message when user works with Scan Request functionality.
    public Boolean isShowMeaageForScanRequest {
        get {
            if (null == this.isShowMeaageForScanRequest) {
                this.isShowMeaageForScanRequest = false;

            }
            return this.isShowMeaageForScanRequest;

        }
        private set;

    }

    public String getFolderDocName() {
         return this.folderDocName;
    }

    public void setFolderDocName(String s) {
         this.folderDocName = s;
    }

    public String getFolderDocId() {
         return this.folderDocId == null ? '' : this.folderDocId;
    }

    public void setFolderDocId(String s) {
         this.folderDocId = s == null ? '' : s;
    }

    public Scan_Request__c scanRequestDocument {
        get {
            if (null == this.scanRequestDocument) {
                this.scanRequestDocument = new Scan_Request__c();

            }
            return this.scanRequestDocument;
        }
        set;
    }

     public Scan_Request__c scanRequestDrawings {
        get {
            if (null == this.scanRequestDrawings) {
                this.scanRequestDrawings = new Scan_Request__c();

            }
            return this.scanRequestDrawings;
        }
        set;
    }

    public List<Scan_Request__c> scanDocumentRequests {
        get {
            if (null == this.scanDocumentRequests) {
                if (this.sobj instanceof Task_Item__c) {
                    this.scanDocumentRequests = ScanRequestServices.getScanRequestsByTaskItemId(taskItem.Id, StoredDocumentServices.DOCUMENT_TYPE);

                } else if (this.sobj instanceof Service_Item__c) {
                     this.scanDocumentRequests = ScanRequestServices.getScanRequestsByServiceItemId(this.serviceItem.Id, StoredDocumentServices.DOCUMENT_TYPE);

                } else if (this.sobj instanceof Project_Profile__c) {
                    this.scanDocumentRequests = ScanRequestServices.getScanRequestsByProjectId(this.projectProfile.Id, StoredDocumentServices.DOCUMENT_TYPE);

                } else if (this.sobj instanceof Proposal__c) {
                    this.scanDocumentRequests = ScanRequestServices.getScanRequestsByProposalId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DOCUMENT_TYPE);

                } else if (this.sobj instanceof Pro_forma_Invoice__c) {
                    this.scanDocumentRequests = ScanRequestServices.getScanRequestsByProformaId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DOCUMENT_TYPE);

                } else if (this.sobj instanceof Legacy_Pro_forma_Invoice__c) {
                    this.scanDocumentRequests = ScanRequestServices.getScanRequestsByLegacyProformaId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DOCUMENT_TYPE);

                } else {
                     this.scanDocumentRequests = new List<Scan_Request__c>();

                }

            }
            return this.scanDocumentRequests;

        }
        set;

    }

    public List<Scan_Request__c> scanDrawingsRequests {
        get {
            if (null == this.scanDrawingsRequests) {
                if (this.sobj instanceof Task_Item__c) {
                    this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByTaskItemId(taskItem.Id, StoredDocumentServices.DRAWING_TYPE);

                } else if (this.sobj instanceof Service_Item__c) {
                     this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByServiceItemId(this.serviceItem.Id, StoredDocumentServices.DRAWING_TYPE);

                } else if (this.sobj instanceof Project_Profile__c) {
                    this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByProjectId(this.projectProfile.Id, StoredDocumentServices.DRAWING_TYPE);

                } else if (this.sobj instanceof Proposal__c) {
                    this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByProposalId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DRAWING_TYPE);

                } else if (this.sobj instanceof Pro_forma_Invoice__c) {
                    this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByProformaId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DRAWING_TYPE);

                } else if (this.sobj instanceof Legacy_Pro_forma_Invoice__c) {
                    this.scanDrawingsRequests = ScanRequestServices.getScanRequestsByLegacyProformaId(ApexPages.currentPage().getParameters().get('eid'), StoredDocumentServices.DRAWING_TYPE);

                } else {
                     this.scanDrawingsRequests = new List<Scan_Request__c>();

                }

            }
            return this.scanDrawingsRequests;

        }
        set;

    }

    public Boolean isDocumentScanRequest {
        get {
            return StoredDocumentServices.DOCUMENTS_FILE_TYPE == this.folderDocName;

        }
        set;

    }

    public Boolean isDrawingsScanRequest {
        get {
            return StoredDocumentServices.DRAWINGS_FILE_TYPE == this.folderDocName;

        }
        set;

    }

    public Boolean isRestrictArtifactsVisibility {
        get {
            if( isRestrictArtifactsVisibility == null ) {
                if( profileName.contains( UserServices.PROFILE_PARTNER ) ||
                    profileName.contains( UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ) ||
                    profileName.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_SHARED_SERVICES_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_PROPOSAL_SPECIALIST ) ||
                    profileName.contains( UserServices.PROFILE_STAFF_ACCOUNTANT ) ||
                    profileName.contains( UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ||
                    profileName.contains( UserServices.PROFILE_A_R_CORDINATOR ) ||
                    profileName.contains( UserServices.PROFILE_FINANCE_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_CFO ) ||
                    profileName.contains( UserServices.PROFILE_ACCOUNT_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_PRODUCTION_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_CODE_ZONING_ANALYST ) ) {
                    isRestrictArtifactsVisibility = true;
                } else {
                    isRestrictArtifactsVisibility = isUserInRosterForProjectAndProposal(); /*MRS-6162*/
                }
            }
            return isRestrictArtifactsVisibility;
        }
        set;
    }

    public transient Boolean isAllowedToUploadDocsOnBuilding;
    public Boolean getIsAllowedToUploadDocsOnBuilding() {
        return profileName.contains( UserServices.PROFILE_ACCOUNT_MANAGER ) || //MRS-6776
               profileName.contains( UserServices.PROFILE_ACCOUNTING_SUPERVISOR ) ||
               profileName.contains( UserServices.PROFILE_CFO ) ||
               profileName.contains( UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) ||
               profileName.contains( UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ) ||
               profileName.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) ||
               profileName.contains( UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ||
               profileName.contains( UserServices.PROFILE_PRODUCTION_MANAGER ) ||
               profileName.contains( UserServices.PROFILE_CLIENT_SERVICE_MANAGER ) ||//MRS-6952
               profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||
               profileName.contains( UserServices.PROFILE_PROPOSAL_SPECIALIST ) ||
               profileName.contains( UserServices.PROFILE_SHARED_SERVICES_MANAGER ) ||
               profileName.contains( UserServices.SUPPORT_STAFF );
    }

    //true if user is in roster and parent is proposal or project, and false in other cases
    public Boolean isUserInRosterForProjectAndProposal() { /*MRS-6162*/
        Id parentRecordId = parentObjectId;
        String parentRecordIdString = parentRecordId != null ? String.valueOf( parentRecordId ) : null;
        if( parentRecordIdString != null &&
            ( parentRecordIdString.startsWith( Proposal__c.sObjectType.getDescribe().getKeyPrefix() ) ||
              parentRecordIdString.startsWith( Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() ) ) ) {
            String query = '';
            query += 'SELECT Id FROM Project_Roster__c WHERE User__c = \'' + UserInfo.getUserId() + '\' ';
            query +=    'AND ( Project_Profile__c = \'' + parentRecordIdString + '\' OR Proposal__c = \'' + parentRecordIdString + '\' )';
            List<Project_Roster__c> rosters = Database.query( query );
            if( !rosters.isEmpty() ) {
                return true;
            }
        }
        return false;
    }

    public transient Boolean enableViewProposalFolderForPM;
    public Boolean getEnableViewProposalFolderForPM() {
        return profileName.startsWith( UserServices.PROFILE_PROJECT_MANAGER );
    }

    public String proposalDocumentsFolderName {
        get{ return PROPOSAL_DOCUMENTS_FOLDER_NAME; }
        private set;
    }

    public List<SelectOption> getWorkType {
        get {
            return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Service_Template__c.SObjectType, 'Work_Type__c'), true, true, false);
        }
    }

    public String roleName {
        get {
            if( roleName == null ) {
                UserRole role = UserServices.getCurrentUserRole();
                roleName = role != null ? role.Name : null;
            }
            return roleName;
        }
        private set;
    }

    public Boolean projectProfileIsProjectManager {
        get {
            if(projectProfileIsProjectManager == null) {
                projectProfileIsProjectManager = true;
                if(projectProfile != null) {
                    if ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                         profileName == UserServices.SUPPORT_STAFF || //MRS-6682
                         profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME || //MRS-6779
                         profileName.contains(UserServices.PROFILE_CODE_ZONING_ANALYST) ) { //MRS-6544
                        projectProfileIsProjectManager = true;
                        return projectProfileIsProjectManager;
                    }

                    Map<Id, Project_Profile__c> projectWithRostersTaskServicesMap = ProjectProfileServices.getProjectWithRostersTaskServices ( new List<Project_Profile__c>{projectProfile}, UserInfo.getUserId() );

                    projectProfileIsProjectManager = ProjectProfileServices.isUserInProjectRosterList( projectWithRostersTaskServicesMap.get (projectProfile.Id), UserInfo.getUserId(),
                                                                                                       profileName, roleName, true );
                } else if(taskItem != null) {
                    if( (profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_2) || profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_2_QA)) ||
                        (profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_1) || profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_1_QA)) ) {
                        if( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                            taskItem.Project_Profile__r.Project_Team__r.Project_Manager__c == userinfo.getUserId() ||
                            taskItem.Project_Profile__r.Project_Team__r.Project_Member__c == userinfo.getUserId() ) {
                             projectProfileIsProjectManager = true;
                        } else {
                             projectProfileIsProjectManager = false;
                        }
                    }
                } else if(serviceItem != null) {
                    if( (profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_2) || profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_2_QA)) ||
                        (profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_1) || profileName.equals(UserServices.PROFILE_PROJECT_MANAGER_1_QA)) ) {
                        if( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                            serviceItem.Project_Profile__r.Project_Team__r.Project_Manager__c == userinfo.getUserId() ||
                            serviceItem.Project_Profile__r.Project_Team__r.Project_Member__c == userinfo.getUserId() ) {
                             projectProfileIsProjectManager = true;
                        } else {
                             projectProfileIsProjectManager = false;
                        }
                    }
                }
            }
            return projectProfileIsProjectManager;
        }
        set;
    }

    public List<SelectOption> scanRequestAuthors {
        get {
            if (null == this.scanRequestAuthors) {

                if (null != this.taskItem && !String.isEmpty(this.taskItem.Project_Profile__r.Proposal__c) ) {
                    projectRosterList = ProjectRosterServices.getProjectRosterByProposalId(this.taskItem.Project_Profile__r.Proposal__c);

                } else if (null != this.serviceItem && !String.isEmpty(this.serviceItem.Proposal__c)) {
                    projectRosterList = ProjectRosterServices.getProjectRosterByProposalId(this.serviceItem.Proposal__c);

                } else if (null != this.projectProfile && !String.isEmpty(this.projectProfile.Proposal__c)) {
                    projectRosterList = ProjectRosterServices.getProjectRosterByProposalId(this.projectProfile.Proposal__c);

                } else if (this.sobj instanceof Proposal__c && null != ApexPages.currentPage().getParameters().get('eid')) {
                    projectRosterList = ProjectRosterServices.getProjectRosterByProposalId(ApexPages.currentPage().getParameters().get('eid'));

                } else if (this.sobj instanceof Pro_forma_Invoice__c && null != ApexPages.currentPage().getParameters().get('eid')) {
                    List<Pro_forma_Invoice__c> tempProforma = new List<Pro_forma_Invoice__c>([SELECT Id, Project_Profile__c
                                                                                              FROM Pro_forma_Invoice__c
                                                                                              WHERE Id =: ApexPages.currentPage().getParameters().get('eid')]);

                    if (!tempProforma.isEmpty()) {
                        projectRosterList = ProjectRosterServices.getProjectRosterByProjectProfileId(tempProforma.get(0).Project_Profile__c);

                    }

                } else if (null != this.legacyProforma && !String.isEmpty(this.legacyProforma.Id)) {

                }

                this.scanRequestAuthors = new List<SelectOption>();
                this.scanRequestAuthors.add(new SelectOption( '', '-- None --' ));

                for (Project_Roster__c pr : projectRosterList) {
                    if( !String.isBlank( pr.Name__c ) ) {
                        this.scanRequestAuthors.add(new SelectOption(pr.Id, pr.Name__c));
                    }

                }

            }
            return this.scanRequestAuthors;

        }
        set;

    }

    public List<SelectOption> getAuthor {
        get {
            if(getAuthor == null) {
                getAuthor = new List<SelectOption>();
            }
            return getAuthor;
        }
        set;
    }
    private List<Project_Roster__c> projectRosterList = new List<Project_Roster__c>();

    public Project_Profile__c projectProfile;
    public Proposal__c proposal;
    public Service_Item__c serviceItem;
    public Task_Item__c taskItem;
    public Pro_forma_Invoice__c proforma;
    public Legacy_Pro_forma_Invoice__c legacyProforma;
	public Opportunity opportunity; // MRS 7225
	public Boolean isAnyFileAttached { set; get; }

    public map<Id, DateTime> lStoreDocIdByDatetimeMap {get; set;}
    public Boolean isLStoreDocIdByDatetimeMap {
        get {
            return lStoreDocIdByDatetimeMap.isEmpty();
        }
    }

    //MRS 6809
    @RemoteAction
    global static Boolean documentToSaveUpsert(Id idx, Boolean val) {
        UPSERT (new LStore__Stored_Document__c(Id = idx, To_Be_Sent_this_time__c = val));
        return true;
    }

	//MRS 7389
    @RemoteAction
    global static Boolean documentToSaveUpsertMass(String idx, Boolean val) {
		List<LStore__Stored_Document__c> documentsToUpsert = new List<LStore__Stored_Document__c>();
		for(String s : idx.split(';')) {
			if(!String.isBlank(s)) {
				documentsToUpsert.add(new LStore__Stored_Document__c(Id = Id.valueOf(s), To_Be_Sent_this_time__c = val));
			}
		}
		if(!documentsToUpsert.isEmpty()) {
        	UPSERT documentsToUpsert;
        }
        return true;
    }

    public transient Map<Id, LStore__Stored_Document__c> documentsToSaveStorage;
    public Map<Id, LStore__Stored_Document__c> getDocumentsToSaveStorage() {
            if((String.valueOf(parentObjectId)).left(3).equals(Proposal__c.sObjectType.getDescribe().getKeyPrefix()))
                return new Map<Id, LStore__Stored_Document__c>([SELECT id, To_Be_Sent_this_time__c
                                                                FROM LStore__Stored_Document__c
                                                                WHERE Related_Object_Id__c =: parentObjectId]);
            else
                return new  Map<Id, LStore__Stored_Document__c>();
    }
	public transient String allDocumentsIds;
	public String getAllDocumentsIds() {
		String res = '';
		for(LStore__Stored_Document__c lstd : getDocumentsToSaveStorage().values()) {
			res += String.valueOf(lstd.Id);
		}
		return res;
	}


    public StoredDocContExt(ApexPages.StandardController controller) {
        lStoreDocIdByDatetimeMap = new map<Id, DateTime>();
        this.sobj = controller.getRecord();

        if(sobj instanceof Project_Profile__c) {
           projectProfile = (Project_Profile__c)controller.getRecord();
        } else if(sobj instanceof Proposal__c) {
            proposal = (Proposal__c)controller.getRecord();
        } else if(sobj instanceof Task_Item__c) {
            taskItem = (Task_Item__c)controller.getRecord();
        } else if(sobj instanceof Service_Item__c) {
            serviceItem = (Service_Item__c)controller.getRecord();
            if(serviceItem.Id != null) {
                String idString = String.valueOf(serviceItem.Id);
                Id getId = Id.valueOf(idString);
                relatedId = String.valueOf(getId);
                List<LStore__Stored_Document__c> lStoreDocListDb = [SELECT Id, Drawings_Title__c, Drawing_Number__c, Drawing_Revision_Date__c, LStore__Keywords__c,
                                                                           LStore__Description__c, LStore__File_Name__c,  LStore__Folder__r.RecordTypeId, LastModifiedDate, RecordTypeId, LStore__File_Size_Calc__c,
                                                                           Folder_Name__c, LStore__Related_Object_Id__c, Comments__c
                                                                    FROM LStore__Stored_Document__c
                                                                    WHERE Related_Object_Id__c = : (Id)relatedId
                                                                      AND RecordTypeId != : StoredDocumentServices.FOLDER_RECORD_TYPE_ID];
                List<LStore__Stored_Document__c> lStoreDocList = new List<LStore__Stored_Document__c>();
                for( LStore__Stored_Document__c doc : lStoreDocListDb ) {
                    if( doc.Folder_Name__c != StoredDocumentServices.PROPOSALS_FILE_TYPE ) {
                        lStoreDocList.add( doc );
                    }
                }
                for(LStore__Stored_Document__c lsDoc : lStoreDocList) {
                   lStoreDocIdByDatetimeMap.put(lsDoc.Id, lsDoc.LastModifiedDate);
                }
            }

        } else if (this.sobj instanceof Pro_forma_Invoice__c) {
            this.proforma = (Pro_forma_Invoice__c)controller.getRecord();

        } else if (this.sobj instanceof Legacy_Pro_forma_Invoice__c) {
            this.legacyProforma = (Legacy_Pro_forma_Invoice__c)controller.getRecord();

        } else if(this.sobj instanceof Opportunity) { // MRS 7225
			this.opportunity = (Opportunity)controller.getRecord();
			isAnyFileAttached = ![SELECT Id FROM LStore__Stored_Document__c WHERE Related_Object_Id__c = :opportunity.Id AND RecordTypeId != :StoredDocumentServices.FOLDER_RECORD_TYPE_ID LIMIT 1].isEmpty();	
		}
    }

    public String authorSelect { get; set; }

    public LStore__Stored_Document__c lStoreDocumentSObject {
        get {
            if(lStoreDocumentSObject == null) {
                lStoreDocumentSObject = new LStore__Stored_Document__c();
            }
            return lStoreDocumentSObject;
        }
        set;
    }
    public void getProjectRoster() {

        System.debug(LoggingLevel.ERROR, '>>> relatedId >>>' + relatedId);
        System.debug(LoggingLevel.ERROR,'>>> projectRosterList >>>' + projectRosterList);
        System.debug(LoggingLevel.ERROR,'>>> serviceItem >>>' + serviceItem);
        System.debug(LoggingLevel.ERROR,'>>> projectProfile >>>' + projectProfile);
        System.debug(LoggingLevel.ERROR,'>>> taskItem >>>' + taskItem);

        if( projectRosterList.isEmpty() && !String.isBlank(relatedId) ) {
            if( relatedId.startsWith(Schema.SObjectType.Proposal__c.getKeyPrefix())) {
                projectRosterList = ProjectRosterServices.getProjectRosterByProposalId( (ID)relatedId );

            } else if ( relatedId.startsWith(Schema.SObjectType.RFI_Scope__c.getKeyPrefix()) ) {
               RFI_Scope__c rfiScope = RFIScopeServices.getRFIScopeById((Id)relatedId);

               if (rfiScope.Id != null && rfiScope.Project__c != null) {
                    projectRosterList = ProjectRosterServices.getRosterByProjectId( rfiScope.Project__c );
               }
            } else if( serviceItem != null && !String.isEmpty( serviceItem.Proposal__c ) ) {
                projectRosterList = ProjectRosterServices.getProjectRosterByProposalId( serviceItem.Proposal__c );

            } else if( projectProfile != null && !String.isEmpty( projectProfile.Proposal__c ) ) {
                projectRosterList = ProjectRosterServices.getProjectRosterByProposalId( projectProfile.Proposal__c );

            } else if( taskItem != null && ( !String.isEmpty( taskItem.Project_Profile__r.Proposal__c ) ) ) {
                projectRosterList = ProjectRosterServices.getProjectRosterByProposalId( taskItem.Project_Profile__r.Proposal__c );
            }
        }
        Map<String, String> projectRosterStringMap = new Map<String, String>();
        for(Project_Roster__c projectRoster : projectRosterList) {
            if( !String.isBlank(projectRoster.Name__c) ) {
                if( ProjectRosterServices.TYPE_CONTACT.equalsIgnoreCase( projectRoster.RecordType.Name ) ) {
                    projectRosterStringMap.put( projectRoster.Contact__c, projectRoster.Name__c );
                } else if( ProjectRosterServices.TYPE_USER.equalsIgnoreCase( projectRoster.RecordType.Name ) ) {
                    projectRosterStringMap.put( projectRoster.User__c, projectRoster.Name__c );
                }
            }
        }
        system.debug('projectRosterStringMap; ' + projectRosterStringMap);
        system.debug('getAuthor: ' + getAuthor);
        if( !projectRosterStringMap.isEmpty() ) {
            getAuthor = ProposalWizardServices.generateOptions(null, projectRosterStringMap, true, true, false);
        }
    }

    private List<LStore__Stored_Document__c> lStoreDocumentList = new List<LStore__Stored_Document__c>();
    public String relatedId;

    @TestVisible private void getFieldsByObject() {
        if(String.isBlank(relatedId)) return;
        List<Project_Roster__c> projectRosterList = new List<Project_Roster__c>();
        if(relatedId.startsWith(Schema.SObjectType.Proposal__c.getKeyPrefix())) {
            getFieldsByProposal();
        }
        if(relatedId.startsWith(Schema.SObjectType.Project_Profile__c.getKeyPrefix())) {
            getFieldsByProject();
        }
        if(relatedId.startsWith(Schema.SObjectType.Service_Item__c.getKeyPrefix())) {
            getFieldsByServiceItem();
        }
        if(relatedId.startsWith(Schema.SObjectType.Task_Item__c.getKeyPrefix())) {
            getFieldsByTaskItem();
        }
        if(relatedId.startsWith(Schema.SObjectType.RFI_Scope__c.getKeyPrefix())) {
            getFieldsByRFIScope();
        }
        if(relatedId.startsWith(Schema.SObjectType.Purchase_Order__c.getKeyPrefix())) {
            getFieldsByPurchaseOrder();
        }
        if(relatedId.startsWith(Schema.SObjectType.Building__c.getKeyPrefix())) {
            getFieldsByBuilding();
        }

    }
    @TestVisible private void getFieldsByProposal() {
        List<Proposal__c> proposalList = ProposalServices.getProposalById(relatedId);
        if(proposalList.size() == 0) return;
        Proposal__c proposal = proposalList.get(0);
        lStoreDocumentSObject.Proposal__c = proposal.id;
        lStoreDocumentSObject.Address__c  = proposal.Address__c;
        lStoreDocumentSObject.Project__c = proposal.Project_Profile__c;
        lStoreDocumentSObject.Floor__c = proposal.Floor_s__c;

    }
    @TestVisible private void getFieldsByProject() {
        Project_Profile__c project = ProjectProfileServices.getProjectById((Id)relatedId);
        if(project == null || project.Id == null) return;
        lStoreDocumentSObject.Project__c = project.id;
        lStoreDocumentSObject.Address__c  = project.Building__c;
        lStoreDocumentSObject.Proposal__c = project.Proposal__c;
        lStoreDocumentSObject.Floor__c = project.Floor_s__c;

        /*if( String.isEmpty(lStoreDocumentSObject.LStore__Description__c) ) {
            lStoreDocumentSObject.LStore__Description__c = 'Label';
        }
        if( String.isEmpty(lStoreDocumentSObject.LStore__Keywords__c) ) {
            lStoreDocumentSObject.LStore__Keywords__c = 'Label';
        }*/ /*MRS-6069*/
    }
    @TestVisible private void getFieldsByServiceItem() {
        Service_Item__c serviceItem = ServiceItemServices.getServiceItemById((Id)relatedId);
        if(serviceItem == null || serviceItem.Id == null) return;
        lStoreDocumentSObject.Service_Item__c = serviceItem.Id;
        lStoreDocumentSObject.Project__c = serviceItem.Project_Profile__c;
        lStoreDocumentSObject.Proposal__c = serviceItem.Proposal__c;
        lStoreDocumentSObject.Address__c  = serviceItem.Project_Profile__r.Building__c;
        lStoreDocumentSObject.Change_Order__c = serviceItem.Change_Order__c;
        lStoreDocumentSObject.Floor__c = serviceItem.Floor__c;
    }
    @TestVisible private void getFieldsByTaskItem() {
        Task_Item__c taskItem = TaskItemServices.getTaskItemById((Id)relatedId);
        if(taskItem == null || taskItem.Id == null) return;
        lStoreDocumentSObject.Task_Item__c = taskItem.Id;
        lStoreDocumentSObject.Project__c = taskItem.Project_Profile__c;
        lStoreDocumentSObject.Service_Item__c = taskItem.Service_Item__c;
        lStoreDocumentSObject.Proposal__c = taskItem.Project_Profile__r.Proposal__c;
        lStoreDocumentSObject.Address__c  = taskItem.Project_Profile__r.Building__c;
        lStoreDocumentSObject.Floor__c = taskItem.Project_Profile__r.Proposal__r.Floor_s__c;
    }
    @TestVisible private void getFieldsByRFIScope() {
        RFI_Scope__c rFIScope = RFIScopeServices.getRFIScopeById((Id)relatedId);
        if(rFIScope == null || rFIScope.Id == null) return;
        lStoreDocumentSObject.RFI_Scope__c = rFIScope.Id;
        lStoreDocumentSObject.Proposal__c = rFIScope.Proposal_Id__c;
        lStoreDocumentSObject.Project__c  = rFIScope.Project__c;
        lStoreDocumentSObject.Address__c  = rFIScope.Project__r.Building__c;
    }
    @TestVisible private void getFieldsByPurchaseOrder() {
        Purchase_Order__c purchaseOrder = PurchaseOrderServices.getPurchaseOrderById((Id)relatedId);
        if(purchaseOrder == null || purchaseOrder.Id == null) return;
        lStoreDocumentSObject.Purchase_Order__c = purchaseOrder.Id;
        lStoreDocumentSObject.Proposal__c = purchaseOrder.Proposal__c;
    }
    @TestVisible private void getFieldsByBuilding() {
        Building__c building = BuildingServices.getBuildingById((Id)relatedId);
        if(building == null || building.Id == null) return;
        lStoreDocumentSObject.Building__c = building.Id;
    }

    public void saveOtherFieldAction() {
        system.debug('start lStoreDocumentSObject: ' + lStoreDocumentSObject);
        Id getId = Id.valueOf(ApexPages.currentPage().getParameters().get('relatedObjectId'));
        relatedId = String.valueOf(getId);
        if(String.isNotBlank(relatedId)) {
           lStoreDocumentList = StoredDocumentServices.getStoredDocumentByRelatedId(relatedId);
           if( lStoreDocumentList.isEmpty() ) return;
           getFieldsByObject();
        }
        if(lStoreDocumentList.get(0).Folder_Name__c == StoredDocumentServices.DRAWINGS_FILE_TYPE) {
            lStoreDocumentSObject.Artifacts_Category__c = StoredDocumentServices.DRAWINGS_FILE_TYPE;
        } else if(lStoreDocumentList.get(0).Folder_Name__c == StoredDocumentServices.DOCUMENTS_FILE_TYPE) {
            lStoreDocumentSObject.Artifacts_Category__c = StoredDocumentServices.DOCUMENTS_FILE_TYPE;
        } else if(lStoreDocumentList.get(0).Folder_Name__c == StoredDocumentServices.FOLDER_FILE_TYPE) {
            lStoreDocumentSObject.Artifacts_Category__c = StoredDocumentServices.FOLDER_FILE_TYPE;
        }
        if( !StoredDocumentServices.DRAWINGS_FILE_TYPE.equalsIgnoreCase( lStoreDocumentSObject.Artifacts_Category__c ) ){
            setAuthorSelect();
        }
        system.debug('end lStoreDocumentSObject: ' + lStoreDocumentSObject);
        try {
            lStoreDocumentSObject.Id = lStoreDocumentList.get(0).Id;
            update lStoreDocumentSObject;
            lStoreDocumentSObject = null;
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error saving Stored Document.'));
        }
    }

    public void setAuthorSelect() {
        if (String.isBlank(authorSelect)) {
            return;

        }

        if (authorSelect.startsWith(Schema.SObjectType.User.getKeyPrefix())) {
            lStoreDocumentSObject.User__c = authorSelect;

        } else if (authorSelect.startsWith(Schema.SObjectType.Contact.getKeyPrefix())) {
            lStoreDocumentSObject.Contact__c = authorSelect;

        } else if (authorSelect.startsWith(Schema.SObjectType.Account.getKeyPrefix())) {
            lStoreDocumentSObject.Account__c = authorSelect;

        }

    }

    public void setFieldsByObjectAction() {
        Id getId;
        if( !String.isEmpty( ApexPages.currentPage().getParameters().get('relatedObjectId')) ) {
            getId = Id.valueOf(ApexPages.currentPage().getParameters().get('relatedObjectId'));
        } else if( !String.isBlank( ApexPages.currentPage().getParameters().get('eid') ) ) {
            getId = Id.valueOf(ApexPages.currentPage().getParameters().get('eid'));
        }
        if( String.isBlank(getId) ) return;
        relatedId = String.valueOf(getId);
        getFieldsByObject();
        getProjectRoster();
    }

    //Action: Button click Send Request
    public void createScanRequest() {
        this.isShowMeaageForScanRequest = false;

        if (String.isBlank(this.folderDocName)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ErrorException.SCAN_REQUEST_PLEASE_CHOOSE_FOLDER));
            return;

        }

        try {
            this.scanRequestDocument.Related_Folder_Id__c = getFolderDocId();
            if (this.isDocumentScanRequest) {
                preparateScanRequest(this.scanRequestDocument, StoredDocumentServices.DOCUMENT_TYPE);
                ScanRequestServices.insertScanRequest(this.scanRequestDocument);

            } else if (this.isDrawingsScanRequest) {
                preparateScanRequest(this.scanRequestDrawings, StoredDocumentServices.DRAWING_TYPE);
                ScanRequestServices.insertScanRequest(this.scanRequestDrawings);

            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ErrorException.SCAN_REQUEST_INCORRECT_FILE_TYPE));
                return;

            }
            this.scanRequestDocument  = null;
            this.scanRequestDrawings  = null;
            this.scanDocumentRequests = null;
            this.scanDrawingsRequests = null;

        } catch (Exception ex) {
            this.isShowMeaageForScanRequest = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        }
        this.isShowMeaageForScanRequest = false;
        this.folderDocName = null;
        this.folderDocId = null;
    }

    @testVisible
    private void preparateScanRequest(Scan_Request__c scanRequest, String fileType) {
        scanRequest.File_Type__c = fileType;
        scanRequest.User__c      = UserInfo.getUserId();

        if (sobj instanceof Project_Profile__c) {
           scanRequest.Project__c = this.projectProfile.Id;

        } else if (sobj instanceof Proposal__c) {
            scanRequest.Proposal__c = ApexPages.currentPage().getParameters().get('eid');

        } else if (sobj instanceof Task_Item__c) {
            scanRequest.Task_Item__c = this.taskItem.Id;

        } else if (sobj instanceof Service_Item__c) {
             scanRequest.Service_Item__c = this.serviceItem.Id;

        } else if (this.sobj instanceof Pro_forma_Invoice__c) {
            scanRequest.Pro_forma_Invoice__c = ApexPages.currentPage().getParameters().get('eid');

        } else if (this.sobj instanceof Legacy_Pro_forma_Invoice__c) {
            scanRequest.Legacy_Pro_forma_Invoice__c = ApexPages.currentPage().getParameters().get('eid');

        }

    }

    //Action: Set Folder Name
    public void scanRequest() {

    }

    public void cancelScanRequest() {
        this.folderDocName = null;
        this.folderDocId = null;
    }

    public Id parentObjectId {
        get {
            if( parentObjectId == null ) {
                Id getId;
                if( !String.isEmpty( this.sobj.Id ) ) {
                    getId = this.sobj.Id;
                } else if( !String.isEmpty( ApexPages.currentPage().getParameters().get('relatedObjectId') ) ) {
                    getId = Id.valueOf( ApexPages.currentPage().getParameters().get('relatedObjectId') );
                } else if( !String.isBlank( ApexPages.currentPage().getParameters().get('eid') ) ) {
                    getId = Id.valueOf( ApexPages.currentPage().getParameters().get('eid') );
                }
                parentObjectId = getId;
            }
            return parentObjectId;
        }
        set;
    }

    /*MRS-6069*/
    //public transient Map<Id, List<String>> documentOwners;
    public Map<Id, List<String>> documentOwners {
        get {
            Map<Id, List<String>> owners = new Map<Id, List<String>>();
            if( documentOwners == null ) {
                Map<Id, Id> scanRequestIdToDocId = new Map<Id, Id>();
                for( LStore__Stored_Document__c doc : [ SELECT Id, CreatedById, CreatedBy.Name, Scan_Request_Id__c
                                                        FROM LStore__Stored_Document__c
                                                        WHERE Related_Object_Id__c = : parentObjectId ] ) {
                    owners.put( doc.Id, new List<String>{ doc.CreatedBy.Name, doc.CreatedById } );
                    if( !String.isBlank( doc.Scan_Request_Id__c ) &&
                        doc.Scan_Request_Id__c instanceOf Id ) {
                        scanRequestIdToDocId.put( doc.Scan_Request_Id__c, doc.Id );
                    }
                }
                for( Scan_Request__c request : [ SELECT Id, CreatedById, CreatedBy.Name
                                                 FROM Scan_Request__c
                                                 WHERE Id IN : scanRequestIdToDocId.keySet() ] ) {
                    owners.put( scanRequestIdToDocId.get( request.Id ), new List<String>{ request.CreatedBy.Name, request.CreatedById } );
                }
            }
            return owners;
        } set;
    }

    public transient Map<Id, LStore__Stored_Document__c> lstoreDocuments;
    public Map<Id, LStore__Stored_Document__c> getLstoreDocuments() {
        return new Map<Id, LStore__Stored_Document__c>( [ SELECT Drawings_Title__c
                                                          FROM LStore__Stored_Document__c
                                                          WHERE Related_Object_Id__c = : parentObjectId ] );
    }
}