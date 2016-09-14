public with sharing class ProjectProfileServices {
    public static final String BILLINGMETHODMILESTONE   = 'Milestone';
    public static final String BILLINGMETHODPERCENTAGE  = 'Percentage';
    public static final String BILLINGMETHODINSTALLMENT = 'Installment';

    public static final String FREQUENCY_WEEKLY         = 'Weekly';
    public static final String FREQUENCY_MONTHLY        = 'Monthly';
    public static final String FREQUENCY_QUARTERLY      = 'Quarterly';

    public static final String PROJECT_STATE_NOT_STARTED = 'Not Started';
    public static final String PROJECT_STATE_IN_PROCESS  = 'In Process';
    public static final String PROJECT_STATE_COMPLETE    = 'Complete';
    public static final String PROJECT_STATE_CLOSED      = 'Closed';
    public static final String PROJECT_STATE_ON_HOLD      = 'On Hold';

    public static final String PROJECT_MILESTONE_PROJECT_START                  = 'Project Start';
    public static final String PROJECT_MILESTONE_CUNSTRUCTION_DOCUMENT_APPROVAL = 'Construction Document Approval';
    public static final String PROJECT_MILESTONE_CUNSTRUCTION_PERMIT            = 'Construction Permit';
    public static final String PROJECT_MILESTONE_EXPECTED_CONSTRUCTION_END_DATE = 'Expected Construction End';
    public static final String PROJECT_MILESTONE_CONSTRACTION_DOCUMENT_SIGN_OFF = 'Construction Document Sign off';
    public static final String PROJECT_MILESTONE_EXPECTED_TENANT_OCCUPANCY      = 'Expected Occupancy';
    public static final String PROJECT_MILESTONE_MILROSE_PROJECT_END            = 'Project End';

    public static final String PROJECT_SOBJECT_NAME                             = 'Project_Profile__c';
    public static final String PROJECT_STANDARD_DEVELOPERNAME                   = 'Standard';
    public static final String PROJECT_MI3_DEVELOPERNAME                        = 'Mi3';

    public static final String BILLING_METHOD = 'Billing Method';

    public static Set<String> ROLENAMESFORPROJECTASSIGNMENT = new Set<String>{UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER,
                                                                              UserServices.ROLE_C_OF_O_DEPARTMENT_COORDINATOR,
                                                                              UserServices.ROLE_CODE_ZONING_ANALYST,
                                                                              UserServices.ROLE_CODE_ZONING_DEPARTMENT_REVIEWER,
                                                                              UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER,
                                                                              UserServices.ROLE_SIPS_DEPARTMENT_COORDINATOR,
                                                                              UserServices.ROLE_FDNY_DEPARTMENT_MANAGER,
                                                                              UserServices.ROLE_FDNY_DEPARTMENT_REVIEWER,
                                                                              UserServices.ROLE_FDNY_DEPARTMENT_COORDINATOR};

    public static final String PROJECT_STATUS_SIGNOFF_PENDING = 'Signoff Pending'; //MRS-7062
    public static final String PROJECT_STATUS_SIGNOFF_PENDING_LS = 'Signoff Pending - Life Safety'; // MRS 7222

    public static Boolean twiceUpdatePreventor = false;
    public static Boolean doNotUpdateProjectRoster = false;
    public static Boolean isAllowedPreBillGenerated = false;
    public static Boolean isReopenProject = false;
    public static Boolean preventToUpdateProjectAssignment = true;

    public static Map<Id, Project_Profile__c> idProposalToNewProjectProfiles { get; set; }
    public static Map<Id, Project_Team__c> projectTeamIdToProjectTeam = new Map<Id, Project_Team__c>();
    public static Map<String, map<Id, Project_Roster__c>> projectRosterRoleToRecord = new Map<String, map<Id, Project_Roster__c>>();
    public static Map<Id, Id> proposalIdToMi3RecordTypeId;
    public static List<Project_Profile__c> projectProfilesWithChangedProjectTeam;
    public static List<Project_Profile__c> projectWhithChangedAccountingHoldList;

    public static Project_Profile__c getProjectById( Id projectId ) {
        return getProjectById( projectId, true );
    }

    public static Project_Profile__c getProjectById( Id projectId, Boolean doSelectRelatedLists ) {
        if( String.isBlank( projectId ) ) {
            throw new ErrorException('Parameter project id cannot be empty!');
        }
        String query = 'SELECT Id, EmailToCCRfi__c, Project_Name__c, Building__r.Name, Building__c, Floor_s__c, EmailToRfi__c, Email_To_Letter__c, Email_CC_Letter__c, ';
        query += 'Proposal__c, Name, Primary_Company_Name__c, Primary_Company_Name__r.Name, Project_Address__c, Municipal_Agency_ID__c, Letter_Body__c, ';
        query += 'Floor_Counting__c, No_Met_Data_Scanning__c, Fulfillment_Office__c, Building__r.Municipality__r.Region__r.Name, No_Messenger_Fedex__c, ';
        query += 'Submitted_Planned_Dates__c, Project_Start_Date__c, Project_Manager__c, Project_State__c, Project_Expected_End_Date__c, ';
        query += 'Production_Manager__c, Project_Member__c, FREP__c, OwnerId, Proposal_Specialist__c, Letter_Name__c, ';
        query += 'Building__r.Is_Landmark__c, Building__r.Municipality__r.Commissioner__r.Name, ';
        query += 'Building__r.Municipality__r.Commissioner_Name__c, Building__r.Municipality__r.Commissioner__r.Title, ';
        query += 'Building__r.Municipality__r.Commissioner__r.MailingStreet, Building__r.Municipality__r.Commissioner__r.MailingCity, ';
        query += 'Building__r.Municipality__r.Commissioner__r.MailingState,  Building__r.Municipality__r.Commissioner__r.MailingPostalCode, ';
        query += 'Project_Name_For_Email__c, '; // MRS 6259
        query += 'Project_Member__r.Email, Project_Manager__r.Email, Owner.Email, Project_Team__c, ';
        query += 'Project_Team__r.Owner.Email,  Project_Team__r.Project_Member__r.Email, Project_Team__r.Project_Manager__r.Email';

        if( doSelectRelatedLists == true ) {
            query += ', ';
            query += '( SELECT Id FROM RFI_Scopes__r ), ';
            query += '( SELECT Id FROM Task_Items__r ), ';
            query += '( SELECT Id FROM Service_Items__r )';
        }

        query += ' ';
        query += 'FROM Project_Profile__c ';
        query += 'WHERE Id = \'' + projectId + '\'';

        List<Project_Profile__c> projects = Database.query( query );
        if( projects.isEmpty() ) {
            throw new ErrorException('Project does not exist for' + projectId + ' id!');
        }
        return projects.get(0);
    }

    public static Project_Profile__c getProjectWithAssignmentsById( Id projectId ) {
        return [ SELECT Id, Proposal__r.Region__c, Project_Manager__c, Production_Manager__c, Project_Member__c, FREP__c, OwnerId, Proposal_Specialist__c
                 FROM Project_Profile__c
                 WHERE Id =: projectId ][0];
    }

    public static List<Project_Profile__c> getProjectsWithServiceItemsById(Set<Id> projectIds) {
        if (null == projectIds) {
            throw new ErrorException('Set of projects id cannot be empty!');

        }

        return new List<Project_Profile__c>([SELECT Region_ID__c, Id, Building__r.Municipality__r.Region__r.Name,
                                                (SELECT Id, Project_Level_RFI__c, Service_Level_RFI__c, Category__c, Type__c, Service_Group__c
                                                 FROM Service_Items__r),
                                                (SELECT Id, Project_Profile__c, Role__c, Contact_Full_Name__c, Name__c
                                                 FROM Project_Rosters__r)
                                             FROM Project_Profile__c WHERE Id IN: projectIds]);

    }

    public static Map<Id, Project_Profile__c> getProgectProfileMap(Set<Id> projectProfileIds) {
        if (null == projectProfileIds) {
            throw new ErrorException('Set of projects id cannot be empty!');
        }
        return new Map<Id, Project_Profile__c>( [ SELECT Id, Project_Name__c, Billing_Method__c, Frequency__c, Billing_Company_Contact__c, Total_Service_Amount__c, Building__c,
                                                         Billing_Company_Name__c, Primary_Company_Name__c, Quarterly_Month__c, Billing_day__c, Interval__c,  Address_Building_AKA__c,
                                                         Discounted_Total_Service_Amount__c, Pre_billed__c, Reimbursable1__c, Reimbursable2__c, Reimbursable3__c,
                                                         Expected_Construction_Start_Date__c, Expected_Construction_End_Date__c, Primary_Company_Contact__c, Send_Copy_To__c,
                                                         Accounting_Contact_Company__c, Accounting_Contact__c, No_Met_Data_Scanning__c, Billing_End_Date__c, No_Document_Shredding__c,
                                                         Separate_Reimbursables__c, Separate_Phases__c, Invoice_Format__c, Client_Project__c, Floor_s__c, Account_Executive__c,
                                                         Billing_Dates_Blocked__c, No_Messenger_Fedex__c, Delivery_Method__c,
                                                         ( SELECT Service_Item__c, Successor_Milestone__c, Is_Locked__c, Billing_Trigger__c, Billing_Percentage__c
                                                             FROM Task_Items__r ),
                                                         ( SELECT Id, Name, Quantity__c, Total_Service_Price__c, GLA_Product__c, GLA_Product__r.Name, Service_Name_Short__c,
                                                                  Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c, Discounted_Unit_Price__c,
                                                                  Work_Type__c, Proposal__c, Purchase_Order__c, Met_Data_BLI_Created__c, Type__c, Shredding_Fees__c, Category__c,
                                                                  Discount_Percentage__c, Met_Data_Scanning_Fee__c, Actual_End_Date__c, Doc_Shredding_BLI_Created__c,
                                                                  Tax_Percent_1__c, Tax_Percent_2__c, Department_Name__c,
                                                                  Sales_Tax_Amount_1__c, Sales_Tax_Amount_2__c, Total_Discounted_Price__c
                                                             FROM Service_Items__r ),
                                                         ( SELECT Id__c, isReimbursable__c, Service_Category__c, Service_Item__c, Service_Filling_Status__c, Service_Type__c, Pro_forma_Invoice__c, isReimbursableOnProjectLevel__c
                                                             FROM Billing_Line_Items__r ),
                                                         ( SELECT Id, Name, Invoice_End_Date__c, Purchase_Order__c, Project_Profile__c, Accounting_Contact__c, Phase__c, cl_Create_FFA_Invoice__c, Only_Reimb_In_Invoice__c
                                                             FROM Pro_forma_Invoices__r
                                                             ORDER BY Invoice_End_Date__c ),
                                                         ( SELECT Id, Billed__c
                                                             FROM Billing_Dates__r )
                                                  FROM Project_Profile__c
                                                  WHERE Id IN : projectProfileIds ] );
    }
    //MRS-6396
    public static Map<Id, Project_Profile__c> getProgectProfileMapForprocessProforma(Set<Id> projectProfileIds) {
        if (null == projectProfileIds) {
            throw new ErrorException('Set of projects id cannot be empty!');
        }
        return new Map<Id, Project_Profile__c>( [ SELECT Id, Project_Name__c, Billing_Method__c, Frequency__c, Billing_Company_Contact__c, Total_Service_Amount__c, Building__c,
                                                         Billing_Company_Name__c, Primary_Company_Name__c, Quarterly_Month__c, Billing_day__c, Interval__c,  Address_Building_AKA__c,
                                                         Discounted_Total_Service_Amount__c, Pre_billed__c, Reimbursable1__c, Reimbursable2__c, Reimbursable3__c,
                                                         Expected_Construction_Start_Date__c, Expected_Construction_End_Date__c, Primary_Company_Contact__c, Send_Copy_To__c,
                                                         Accounting_Contact_Company__c, Accounting_Contact__c, No_Met_Data_Scanning__c, Billing_End_Date__c, No_Document_Shredding__c,
                                                         Separate_Reimbursables__c, Separate_Phases__c, Invoice_Format__c, Client_Project__c, Floor_s__c, Account_Executive__c,
                                                         Billing_Dates_Blocked__c, No_Messenger_Fedex__c, Delivery_Method__c, PO_Required__c, PO_Not_Required__c, // MRS 7156 PO_Required__c
                                                         ( SELECT Id, Billed__c //MRS-6702
                                                             FROM Billing_Dates__r )
                                                  FROM Project_Profile__c
                                                  WHERE Id IN : projectProfileIds ] );
    }

    public static Map<Id, Project_Profile__c> createNewProjectProfile( Map<Id, Proposal__c> newProposalMap ) {
        List<Proposal__c> newProposalList = newProposalMap.values();
        List<Note> notesToProjectProfileList = new List<Note>();
        // projectTeamIdToProjectTeam is used in attachServicesToProjectProfiles() and initProjectProfile();
        projectTeamIdToProjectTeam = ProjectTeamServices.getProposalIdToProjectTeam( newProposalList );

        idProposalToNewProjectProfiles = new Map<Id, Project_Profile__c>();

        proposalIdToMi3RecordTypeId = prepareMi3ProposalsMap( newProposalList );

        for( Proposal__c proposalItem: newProposalList ) {
            idProposalToNewProjectProfiles.put( proposalItem.Id, initProjectProfile( proposalItem ) );//this Map using in TaskItemServices
        }

        try{
            if( !idProposalToNewProjectProfiles.isEmpty() ) {
                insert idProposalToNewProjectProfiles.values();
                for( Proposal__c proposalItem: newProposalList ) {
                    for (Note noteItem : ProposalServices.mapProposalWithNotesAndRosters.get(proposalItem.Id).Notes){
                        Note noteProject = new Note( Title = noteItem.Title, ParentId = idProposalToNewProjectProfiles.get(proposalItem.Id).Id, IsPrivate = noteItem.IsPrivate, Body = noteItem.Body );
                        notesToProjectProfileList.add(noteProject);
                    }
                }
            }
        }
        catch ( DMLException dmlEx ){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                Project_Profile__c itemProjectProfile = idProposalToNewProjectProfiles.values()[dmlEx.getDmlIndex(i)];
                Id proposalItemId = itemProjectProfile.Proposal__c;
                for( Proposal__c proposalItem: newProposalList ){
                    if( proposalItem.Id == proposalItemId ){
                        proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                    }
                }
            }
        }

        // create building instructions for created projects MRS-6930 *****
        List<Project_Instruction__c> instructionsToInsert = new List<Project_Instruction__c> ();
        for(Id idx : idProposalToNewProjectProfiles.keySet()) {

            instructionsToInsert.add(new Project_Instruction__c(Instruction__c = newProposalMap.get(idx).Billing_Instructions__c,
                                                                   ObjectID__c = newProposalMap.get(idx).Billing_Company_Name__c,
                                                                Object_Name__c = AccountServices.getAccountNameByIds(newProposalMap.get(idx).Billing_Company_Name__c),
                                                                       Type__c = 'Billing Instructions',
                                                                    Project__c = idProposalToNewProjectProfiles.get(idx).id));
        }
        try {
            insert instructionsToInsert;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error has occured during update of project instructions. '
                                                                      + 'Please contact your system administrator. ' + e.getMessage()));
        }

        try {
            // Create Notes for Projects
            if ( !notesToProjectProfileList.isEmpty() ) {
                INSERT notesToProjectProfileList;
                UserServices.getIdsOfInactiveUsersMap();
                List<Note> notesForOwnerIdUpdate = new List<Note>();
                Integer i = 0;
                for( Proposal__c proposalItem: newProposalList ) {
                    for (Note noteItem :ProposalServices.mapProposalWithNotesAndRosters.get(proposalItem.Id).Notes){
                        Id idOwner = (UserServices.idsOfInactiveUsersMap.get(noteItem.OwnerId) != null ? UserServices.idsOfInactiveUsersMap.get(noteItem.OwnerId) : false ) ? UserInfo.getUserId() : noteItem.OwnerId;
                        notesForOwnerIdUpdate.add( new Note( Id = notesToProjectProfileList[i].Id, OwnerId = idOwner ) );
                        i++;
                    }
                }
                UPDATE notesForOwnerIdUpdate;
            }
        }catch(DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                Id proposalId = new Map<Id, Project_Profile__c>(idProposalToNewProjectProfiles.values()).get(notesToProjectProfileList[dmlEx.getDmlIndex(i)].ParentId).Proposal__c;
                new Map<Id, Proposal__c>(newProposalList).get(proposalId).addError('Attach notes to Project Profile error' + dmlEx.getMessage());
            }
        }
        List<Floor__c> proposalFloors = new List<Floor__c>();
        List<Purchase_Order__c> purchaseOrders = new List<Purchase_Order__c>();
        List<Phase__c> phasesToUpdate = new List<Phase__c>();
        List<Deposit_Invoice__c> depositInvoicesToUpdate = new List<Deposit_Invoice__c>();
        List<LStore__Stored_Document__c> storedDocumentUpdateList = new List<LStore__Stored_Document__c>();
        Id userProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_USER);
        Id contactProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_CONTACT); //MRS 6888
        for ( Proposal__c proposalItem : ProposalServices.mapProposalWithNotesAndRosters.values() ){
            Project_Profile__c currProject = idProposalToNewProjectProfiles.get(proposalItem.Id);
            if( currProject.Project_Manager__c != null ){
                projectRosterRoleToRecord.put( UserServices.PROFILE_PROJECT_MANAGER_2, new Map<Id, Project_Roster__c>{currProject.Project_Manager__c => createAfterAssignProjectRoster( currProject.Project_Manager__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, UserServices.PROFILE_PROJECT_MANAGER_2, null )} );
            }else{
                projectRosterRoleToRecord.put( ProjectRosterServices.PROJECT_OWNER_ROLE, new Map<Id, Project_Roster__c>{currProject.OwnerId => createAfterAssignProjectRoster( currProject.OwnerId, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, ProjectRosterServices.PROJECT_OWNER_ROLE, null )} );
            }

            if( currProject.Project_Member__c != null ){
                projectRosterRoleToRecord.put( UserServices.PROFILE_PROJECT_MANAGER_1, new Map<Id, Project_Roster__c>{currProject.Project_Member__c => createAfterAssignProjectRoster( currProject.Project_Member__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, UserServices.PROFILE_PROJECT_MANAGER_1, null )} );
            }
            if( currProject.FREP__c != null ){
                projectRosterRoleToRecord.put( ProjectRosterServices.FILING_REP, new Map<Id, Project_Roster__c>{currProject.FREP__c => createAfterAssignProjectRoster( currProject.FREP__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, ProjectRosterServices.FILING_REP, null )} );
            }
            if( currProject.Production_Manager__c != null ){
                projectRosterRoleToRecord.put( UserServices.PROFILE_PRODUCTION_MANAGER, new Map<Id, Project_Roster__c>{currProject.Production_Manager__c => createAfterAssignProjectRoster( currProject.Production_Manager__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, UserServices.PROFILE_PRODUCTION_MANAGER, null )} );
            }
            if( proposalItem.Partner__c != null ){
                projectRosterRoleToRecord.put( ProjectRosterServices.PARTNER, new Map<Id, Project_Roster__c>{proposalItem.Partner__c => createAfterAssignProjectRoster( proposalItem.Partner__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, ProjectRosterServices.PARTNER, null )} );
            }
            if( proposalItem.Account_Executive__c != null ){
                projectRosterRoleToRecord.put( ProjectRosterServices.ACCOUNT_MANAGER, new Map<Id, Project_Roster__c>{proposalItem.Account_Executive__c => createAfterAssignProjectRoster( proposalItem.Account_Executive__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, ProjectRosterServices.ACCOUNT_MANAGER, null )} );
            }
            if( proposalItem.Proposal_Specialist__c != null ){
                projectRosterRoleToRecord.put( UserServices.PROFILE_PROPOSAL_SPECIALIST, new Map<Id, Project_Roster__c>{proposalItem.Proposal_Specialist__c => createAfterAssignProjectRoster( proposalItem.Proposal_Specialist__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, UserServices.PROFILE_PROPOSAL_SPECIALIST, null )} );
            }
            if( proposalItem.Salesperson__c != null ){
                projectRosterRoleToRecord.put( ProjectRosterServices.SALESPERSON, new Map<Id, Project_Roster__c>{proposalItem.Salesperson__c => createAfterAssignProjectRoster( proposalItem.Salesperson__c, currProject.Id, proposalItem.Id, userProjectRosterRecordTypeId, ProjectRosterServices.SALESPERSON, null )} );
            }
            if( proposalItem.Address__c != null) { //MRS 6888
                if(proposalItem.Address__r.Owner_Contact_1__c != null) {
                    projectRosterRoleToRecord.put(ProjectRosterServices.BUILDING_OWNER_1, new Map<Id, Project_Roster__c> {proposalItem.Address__r.Owner_Contact_1__c => createAfterAssignProjectRosterContact( proposalItem.Address__r.Owner_Contact_1__c, currProject.Id, proposalItem.Id, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_OWNER_1)});
                }
                if(proposalItem.Address__r.Owner_Contact_2__c != null) {
                    projectRosterRoleToRecord.put(ProjectRosterServices.BUILDING_OWNER_2, new Map<Id, Project_Roster__c> {proposalItem.Address__r.Owner_Contact_2__c => createAfterAssignProjectRosterContact( proposalItem.Address__r.Owner_Contact_2__c, currProject.Id, proposalItem.Id, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_OWNER_2)});
                }
                if(proposalItem.Address__r.Building_Manager__c != null) {
                    projectRosterRoleToRecord.put(ProjectRosterServices.BUILDING_MANAGER, new Map<Id, Project_Roster__c> {proposalItem.Address__r.Building_Manager__c => createAfterAssignProjectRosterContact( proposalItem.Address__r.Building_Manager__c, currProject.Id, proposalItem.Id, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_MANAGER)});
                }
            }

            for (Project_Roster__c projectRosterItem : proposalItem.Project_Rosters__r){
                if (projectRosterItem.Project_Profile__c == null ){
                    projectRosterItem.Project_Profile__c = currProject.Id;
                }
                //remove duplicates:
                Id userContactId = projectRosterItem.User__c != null ? projectRosterItem.User__c : projectRosterItem.Contact__c;
                if (!projectRosterRoleToRecord.containsKey(projectRosterItem.Role__c)){
                    projectRosterRoleToRecord.put(projectRosterItem.Role__c, new Map<Id, Project_Roster__c>());
                }
                if (!projectRosterRoleToRecord.get(projectRosterItem.Role__c).containsKey(userContactId)){
                    projectRosterRoleToRecord.get(projectRosterItem.Role__c).put(userContactId, projectRosterItem);
                }
                if (projectRosterRoleToRecord.get(projectRosterItem.Role__c).get(userContactId).Id == null){
                    projectRosterRoleToRecord.get(projectRosterItem.Role__c).get(userContactId).Id = projectRosterItem.Id;
                }
            }
            proposalFloors.addAll( proposalItem.Floors__r );
            purchaseOrders.addAll( proposalItem.Purchase_Orders__r );
            phasesToUpdate.addAll( proposalItem.Phases__r );
            depositInvoicesToUpdate.addAll( proposalItem.Deposit_Invoices__r );
            storedDocumentUpdateList.addAll(proposalItem.Doc_Storage__r);
        }

        //Populate Floors Project Profile Lookups
        for( Floor__c floor: proposalFloors){
            if( floor.Proposal__c != null && idProposalToNewProjectProfiles.containsKey(floor.Proposal__c) ){
                floor.Project__c = IdProposalToNewProjectProfiles.get(floor.Proposal__c).Id;
            }
        }
        try {
            update proposalFloors;
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                Project_Profile__c itemProjectProfile = idProposalToNewProjectProfiles.values()[dmlEx.getDmlIndex(i)];
                for( Proposal__c proposalItem: newProposalList ){
                    if( proposalItem.Project_Profile__c == itemProjectProfile.Id ){
                        proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                    }
                }
            }
        }
        //Populate Purchase Orders Project Profile Lookups
        for( Purchase_Order__c purchaseOrder: purchaseOrders){
            purchaseOrder.Project_Profile__c = idProposalToNewProjectProfiles.get(purchaseOrder.Proposal__c).Id;
        }
        if( !purchaseOrders.isEmpty() ){
            try {
                update purchaseOrders;
            } catch( DMLException dmlEx ) {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Purchase_Order__c pOrder = purchaseOrders[dmlEx.getDmlIndex(i)];
                    for( Proposal__c proposalItem: newProposalList ){
                        if( proposalItem.Id == pOrder.Id ){
                            proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }

        //Populate Phases Lookups on Project Profile
        for( Phase__c phase : phasesToUpdate ){
            phase.Project_Profile__c = idProposalToNewProjectProfiles.get( phase.Proposal__c ).Id;
        }
        if( !phasesToUpdate.isEmpty() ){
            try {
                update phasesToUpdate;
            } catch( DMLException dmlEx ) {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Project_Profile__c itemProjectProfile = idProposalToNewProjectProfiles.values()[dmlEx.getDmlIndex(i)];
                    for( Proposal__c proposalItem: newProposalList ){
                        if( proposalItem.Project_Profile__c == itemProjectProfile.Id ){
                            proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }

        //Populate Phases Lookups on Project Profile
        for( Deposit_Invoice__c depInvoice : depositInvoicesToUpdate ){
            depInvoice.Project_Profile__c = idProposalToNewProjectProfiles.get( depInvoice.Proposal__c ).Id;
        }
        if( !depositInvoicesToUpdate.isEmpty() ){
            try {
                update depositInvoicesToUpdate;
            } catch( DMLException dmlEx ) {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Project_Profile__c itemProjectProfile = idProposalToNewProjectProfiles.values()[dmlEx.getDmlIndex(i)];
                    for( Proposal__c proposalItem: newProposalList ){
                        if( proposalItem.Project_Profile__c == itemProjectProfile.Id ){
                            proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }

        //Populate Document Lookups on Project Profile
        for( LStore__Stored_Document__c docItem : storedDocumentUpdateList ){
            docItem.Project__c = idProposalToNewProjectProfiles.get( docItem.Proposal__c ).Id;
        }
        if( !storedDocumentUpdateList.isEmpty() ){
            try {
                update storedDocumentUpdateList;
            } catch( DMLException dmlEx ) {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Project_Profile__c itemProjectProfile = idProposalToNewProjectProfiles.values()[dmlEx.getDmlIndex(i)];
                    for( Proposal__c proposalItem: newProposalList ){
                        if( proposalItem.Project_Profile__c == itemProjectProfile.Id ){
                            proposalItem.addError( Label.Create_Project_Profile_Error + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }

        return idProposalToNewProjectProfiles;
    }

    public static Project_Roster__c createAfterAssignProjectRosterContact( Id contactId, Id projectId, Id proposalId, Id recordTypeId, String role){ //MRS 6888
        Project_Roster__c newAfterAssignProjectRoster = new Project_Roster__c();
        newAfterAssignProjectRoster.Active__c = true;
        newAfterAssignProjectRoster.Is_Read__c = true;
        newAfterAssignProjectRoster.Project_Profile__c = projectId;
        newAfterAssignProjectRoster.Proposal__c = proposalId;
        newAfterAssignProjectRoster.Role__c = role;
        newAfterAssignProjectRoster.Contact__c = contactId;
        newAfterAssignProjectRoster.User_Contact__c = ProjectRosterServices.TYPE_CONTACT;
        newAfterAssignProjectRoster.RecordTypeId = recordTypeId;
        if(role == ProjectRosterServices.BUILDING_OWNER_1 ||
           role == ProjectRosterServices.BUILDING_OWNER_2 ||
           role == ProjectRosterServices.BUILDING_MANAGER) {
            newAfterAssignProjectRoster.User_Type__c = ProjectRosterServices.USER_TYPE_EX;
        }
        return newAfterAssignProjectRoster;
    }

    public static Project_Roster__c createAfterAssignProjectRoster( Id userId, Id projectId, Id proposalId, Id recordTypeId, String role, Project_Roster__c currentProjectRoster ){
        Project_Roster__c newAfterAssignProjectRoster = ( currentProjectRoster != null ) ? currentProjectRoster : new Project_Roster__c( User__c = userId );

        newAfterAssignProjectRoster.Active__c = true;
        newAfterAssignProjectRoster.Is_Read__c = true;
        newAfterAssignProjectRoster.Project_Profile__c = projectId;
        newAfterAssignProjectRoster.Proposal__c = proposalId;
        newAfterAssignProjectRoster.Role__c = role;
        newAfterAssignProjectRoster.User__c = userId;
        newAfterAssignProjectRoster.User_Contact__c = ProjectRosterServices.TYPE_USER;
        newAfterAssignProjectRoster.User_Type__c = ProjectRosterServices.USER_TYPE_IN;
        newAfterAssignProjectRoster.RecordTypeId = recordTypeId;
        if( role == ProjectRosterServices.PROPOSAL_CREATOR_ROLE ||
            role == ProjectRosterServices.PARTNER ||
            role == ProjectRosterServices.SALESPERSON ||
            role == ProjectRosterServices.ACCOUNT_MANAGER ) {
            newAfterAssignProjectRoster.Initially_Added_Roster__c = true;
        }

        return newAfterAssignProjectRoster;
    }

    public static void attachServicesToProjectProfiles( Map<Id, Proposal__c> newProposalMap,
                                                        Map<Id, Project_Profile__c> proposalIdToProjectProfile,
                                                        Map<Id, Change_Order__c> changeOrdersMap, //MRS-7473
                                                        Map<Id, Service_Item__c> serviceItemMap,
                                                        Boolean isAmendment ) {
        //system.debug(LoggingLevel.Error, 'xxx newProposalMap: ' + newProposalMap);
        //system.debug(LoggingLevel.Error, 'xxx proposalIdToProjectProfile: ' + proposalIdToProjectProfile);
        //system.debug(LoggingLevel.Error, 'xxx changeOrders: ' + changeOrders);
        //system.debug(LoggingLevel.Error, 'xxx isAmendment: ' + isAmendment);
        //system.debug(LoggingLevel.Error, 'xxx serviceItemMap: ' + serviceItemMap);
        List<Project_Roster__c> rostersForServices = new List<Project_Roster__c>();
        ProjectRosterServices.rosterIsGoingFromWizard = true;//MRS-7487

        if( isAmendment == true ) { //if isAmendment == false then this map inits on project creation
            projectTeamIdToProjectTeam = ProjectTeamServices.getProposalIdToProjectTeam( newProposalMap.values() );
        }

        Id userProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_USER);

        Id coManagerId;
        Boolean isCoManagerIdSelected = false; //avoid 101 select

        Map<Id, String> userWithRoleMap = new Map<Id, String>();
        for (String roleName : UserServices.userRoleNameToUserId.keySet()){
            userWithRoleMap.put(UserServices.userRoleNameToUserId.get(roleName), roleName);
        }

        // Attach Services to Project Profiles and populated Owner Id
        for( Service_Item__c si : serviceItemMap.values() ) {
            if( isAmendment ) {
                si.Project_Profile__c = newProposalMap.get(si.Proposal__c).Project_Profile__c;
            } else {
                si.Project_Profile__c = proposalIdToProjectProfile.get( si.Proposal__c ).Id;
            }
            //system.debug(LoggingLevel.Error, 'xxx si: ' + si);
            Project_Team__c projectTeamItem;
            if( projectTeamIdToProjectTeam != null &&
                projectTeamIdToProjectTeam.containsKey( newProposalMap.get( si.Proposal__c ).Project_Team__c ) &&
                projectTeamIdToProjectTeam.get( newProposalMap.get( si.Proposal__c ).Project_Team__c ) != null ) {
                projectTeamItem = projectTeamIdToProjectTeam.get( newProposalMap.get( si.Proposal__c ).Project_Team__c );
            }

            if( si.Service_Template__r.RecordType.Name == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME ) {
                if( !String.isEmpty( si.Service_Template__r.Role_Assignment__c ) ) {
                    if( UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c ) ) {
                        if( si.Service_Template__r.Role_Assignment__c == UserServices.ROLE_MANAGER_OF_ACCOUNTS ) {
                            if( isAmendment && newProposalMap.get( si.Proposal__c ).Project_Profile__r.Account_Executive__c != null ) {
                                 si.OwnerId = newProposalMap.get( si.Proposal__c ).Project_Profile__r.Account_Executive__c;
                            } else if( !isAmendment && newProposalMap.get( si.Proposal__c ).Account_Executive__c != null ) {
                                 si.OwnerId = newProposalMap.get( si.Proposal__c ).Account_Executive__c;
                            } else {
                                 si.OwnerId = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                            }
                        } else {
                            si.OwnerId = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                        }
                        si.Manager_Lookup__c = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );
                    } else if( projectTeamItem != null ) {
                        if( si.Service_Template__r.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_FILLING_REP ) {
                            //si.OwnerId = projectTeamItem.FREP__c; //MRS-6571, MRS-6271
                            si.OwnerId = newProposalMap.get( si.Proposal__c ).FREP__c; //MRS-6571, MRS-6271
                        } else if( si.Service_Template__r.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_MEMBER ) {
                            si.OwnerId = projectTeamItem.Project_Member__c;
                        } else if( si.Service_Template__r.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_MANAGER ) {
                            si.OwnerId = projectTeamItem.Project_Manager__c;
                        } else if( si.Service_Template__r.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_PRODUCTION_MANAGER ) {
                            si.OwnerId = projectTeamItem.Production_Manager__c;
                        }
                        si.Manager_Lookup__c = si.OwnerId;
                    }
                } else {
                    if( isAmendment ) {
                        si.OwnerId = newProposalMap.get( si.Proposal__c ).Project_Profile__r.OwnerId;
                        si.Manager_Lookup__c = newProposalMap.get( si.Proposal__c ).Project_Profile__r.OwnerId;
                    } else {
                        si.OwnerId = proposalIdToProjectProfile.get( si.Proposal__c ).OwnerId;
                        si.Manager_Lookup__c = proposalIdToProjectProfile.get( si.Proposal__c ).OwnerId;
                    }
                }
                if( String.isEmpty( si.Service_Template__r.Role_Assignment__c ) ||
                        ( !UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c ) && si.Manager_Lookup__c == null ) ) {

                    for( String item: UserServices.userRoleNameToUserId.keySet() ){
                        if( item.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) ) {
                            si.OwnerId = UserServices.userRoleNameToUserId.get( item );
                            si.Manager_Lookup__c = UserServices.userRoleNameToUserId.get( item );
                            break;
                        }
                    }
                }
            } else if ( si.Service_Template__r.RecordType.Name == ServiceItemServices.APS_SERVICE_RECORD_TYPE_NAME && projectTeamItem != null ) {
                si.OwnerId                      = projectTeamItem.Project_Manager__c;
                si.Manager_Lookup__c            = projectTeamItem.Project_Manager__c;
                si.Role_Assignment__c           = ProjectTeamServices.RESOURCE_ROLE_MANAGER;
            }

            //MRS-6867
            if( !isAmendment && userWithRoleMap.containsKey(si.OwnerId) ){
                String serviceItemOwnerRole = userWithRoleMap.get(si.OwnerId);
                if( serviceItemOwnerRole != null ){
                    if ( !projectRosterRoleToRecord.containsKey( serviceItemOwnerRole ) ){
                        projectRosterRoleToRecord.put( serviceItemOwnerRole, new Map<Id, Project_Roster__c>() );
                    }
                    if ( !projectRosterRoleToRecord.get( serviceItemOwnerRole ).containsKey(si.OwnerId) ){
                        projectRosterRoleToRecord.get( serviceItemOwnerRole ).put( si.OwnerId, createAfterAssignProjectRoster( si.OwnerId,
                                                                                                                               si.Project_Profile__c,
                                                                                                                               si.Proposal__c,
                                                                                                                               userProjectRosterRecordTypeId,
                                                                                                                               serviceItemOwnerRole,
                                                                                                                               null ) );
                    }
                }
            }

            if( si.Region__c == RegionServices.REGION_NAME_NY &&
                ( si.Type__c == ServiceItemServices.TYPE_CERTIFICATE_OF_OCCUPANCY || si.Type__c == ServiceItemServices.TYPE_TEMPORARY_CERTIFICATE_OF_OCCUPANCY ) ) {
                if( !isCoManagerIdSelected ) { //avoid 101 select
                    Set<Id> users = UserServices.getUserIdsByRole( UserServices.ROLE_DEV_NAME_C_OF_O_DEPARTMENT_MANAGER );
                    coManagerId = users.isEmpty() ? null : new List<Id>(users)[0];
                    isCoManagerIdSelected = true;
                }
                if( coManagerId != null && !projectRosterRoleToRecord.containsKey( UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER ) ){
                    projectRosterRoleToRecord.put( UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER, new Map<Id, Project_Roster__c>{ coManagerId => createAfterAssignProjectRoster( coManagerId,
                                                                                                                                                                               si.Project_Profile__c,
                                                                                                                                                                               si.Proposal__c,
                                                                                                                                                                               userProjectRosterRecordTypeId,
                                                                                                                                                                               UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER,
                                                                                                                                                                               null ) } );
                }
            }
        }
        //system.debug(LoggingLevel.Error, 'xxx serviceItemMap: ' + serviceItemMap);
        system.debug(LoggingLevel.Error, 'xxx serviceItems.size(): ' + serviceItemMap.size());

        List<Project_Roster__c> projectRosterUpsertList = new List<Project_Roster__c>();
        for (String projectRosterRole : projectRosterRoleToRecord.keySet()){
            projectRosterUpsertList.addAll(projectRosterRoleToRecord.get(projectRosterRole).values());
        }

        // for Proposals with more than 100 services of for any CO - create Tasks in @future method
        if( serviceItemMap.size() > 100 ) {
            preventToUpdateProjectAssignment = isAmendment;
            update serviceItemMap.values();
            try {
                // Update Roters for Projects
                if (!projectRosterUpsertList.isEmpty()) {
                    upsert projectRosterUpsertList;
                }
            }catch(DMLException dmlEx){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    newProposalMap.get(projectRosterUpsertList[dmlEx.getDmlIndex(i)].Proposal__c).addError('Attach Project Roster to Project Profile error' + dmlEx.getMessage());
                }
            }
            preventToUpdateProjectAssignment = true;
            createAndManipulateWithTaskItemsInFuture( newProposalMap.keySet(), changeOrdersMap != null ? changeOrdersMap.keyset() : null, serviceItemMap.keySet(), true, isAmendment );
        } else { // REGULAR MODE
            preventToUpdateProjectAssignment = false;
            processTaskItemsForProjects( serviceItemMap, newProposalMap, changeOrdersMap != null ? changeOrdersMap.values() : null, isAmendment );
            if ( isAmendment ) createAndManipulateWithTaskItemsInFuture( newProposalMap.keySet(), changeOrdersMap != null ? changeOrdersMap.keyset() : null, serviceItemMap.keySet(), false, isAmendment );
            try {
                if (!projectRosterUpsertList.isEmpty()) {
                    upsert projectRosterUpsertList;
                }
                TaskItemServices.createProjectRostersForNewTaskItemsFuture( serviceItemMap.keySet() );
            }catch(DMLException dmlEx){
                Map<Id, List<Change_Order__c>> proposalWithCO = new Map<Id, List<Change_Order__c>>();
                if ( changeOrdersMap != null && !changeOrdersMap.isEmpty() ){
                    for (Change_Order__c co : changeOrdersMap.values()){
                        if (!proposalWithCO.containsKey(co.Proposal__c)){
                            proposalWithCO.put(co.Proposal__c, new List<Change_Order__c>());
                        }
                        proposalWithCO.get(co.Proposal__c).add(co);
                    }
                }
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    if ( changeOrdersMap != null && !changeOrdersMap.isEmpty() ){
                        for (Change_Order__c co : proposalWithCO.get(projectRosterUpsertList[dmlEx.getDmlIndex(i)].Proposal__c)){
                            co.addError('Attach Project Roster to Project Profile error' + dmlEx.getMessage());
                        }
                    } else {
                        newProposalMap.get(projectRosterUpsertList[dmlEx.getDmlIndex(i)].Proposal__c).addError('Attach Project Roster to Project Profile error' + dmlEx.getMessage());
                    }
                }
            }
            preventToUpdateProjectAssignment = true;
        }

    }

    @future(callout=true)
    public static void createAndManipulateWithTaskItemsInFuture( Set<Id> proposalIds, Set<Id> changeOrderIds, Set<Id> serviceItemIds, Boolean doCreateTasks, Boolean isAmendment ) {
        Map<Id, Service_Item__c> serviceItemMap = ServiceItemServices.getServiceItemsMapForAttachServicesToProjectProfiles( proposalIds, changeOrderIds, serviceItemIds, isAmendment );
        Map<Id, Proposal__c> newProposalMap = new Map<Id, Proposal__c>( [ Select Id, Project_Team__c, Project_Profile__c, Project_Profile__r.OwnerId, Account_Executive__c, Project_Profile__r.Project_Status__c /*MRS 7062*/,
                                                                                 Total_Service_Amount__c, Project_Profile__r.Billing_Method__c, Project_Profile__r.Account_Executive__c,
                                                                                 Project_Profile__r.Interval__c, Project_Profile__r.Total_Service_Amount__c, FREP__c, Project_Profile__r.Pre_billed__c,
                                                                                 Discounted_Total_Service_Amount__c, Project_Profile__r.Discounted_Total_Service_Amount__c,
                                                                                 ( Select Id, Role__c From Project_Rosters__r )
                                                                          From Proposal__c Where Id IN: proposalIds ] );
        try{
            if ( doCreateTasks ) processTaskItemsForProjects( serviceItemMap, newProposalMap, null, isAmendment );
            //MRS-5793
            if (isAmendment) {
                Set<Id> projectIds = new Set<Id>();
                List<Id> projectProfileListId = new List<Id>();

                for (Proposal__c p : newProposalMap.values()) {
                    projectProfileListId.add(p.Project_Profile__c);
                    if (p.Project_Profile__r.Pre_billed__c){
                        projectIds.add(p.Project_Profile__c);
                    }

                }

                if ( !projectIds.isEmpty() ){//MRS-6616
                    isAllowedPreBillGenerated = true;
                    prebillProjects( getPreBilledProjectByIds( projectIds ), true );
                }

                ProjectProfileServices.preventToUpdateProjectAssignment = false;
                ProjectRosterServices.updateRostersIsActiveState(projectProfileListId, null, true, true, true, true);
                ProjectProfileServices.preventToUpdateProjectAssignment = true;

                ProjectProfileServices.populateUsersFieldOnProject(newProposalMap.values(), null, null);
            }
        } catch (Exception ex){
            ErrorException.addLog(ex, null, 'Proposal Id = "' + proposalIds + '" Service Item Id = "' + serviceItemIds + '"', 'Future execution ProjectProfileServices.createAndManipulateWithTaskItemsInFuture');
        }

        List<Project_Profile__c> projectsToUpdate = new List<Project_Profile__c> (); //MRS 7062

    }

    public static void processTaskItemsForProjects( Map<Id, Service_Item__c> serviceItemMap, Map<Id, Proposal__c> newProposalMap, List<Change_Order__c> changeOrders, Boolean isChangeOrder ){
        List<Task_Template__c> taskTemplatesAll = new List<Task_Template__c>();
        Map<Id, String> taskLineToTotalDuration = new Map<Id, String>();
        Map<Id, Id> relatedTaskToTaskLine = new Map<Id, Id>();
        Map<Id, Map<Id, Task_Template__c>> serviceIdToTasksTemplates = new Map<Id, Map<Id, Task_Template__c>>();
        Set<Id> serviceTemplateIds = new Set<Id>();
        Map<Id, String> taskTemplIdToTotalDuration = new Map<Id, String>();

        Map<Id, Project_Roster__c> projectRostersForTaskItemsMap;
        if ( projectRosterRoleToRecord == null || projectRosterRoleToRecord.isEmpty()){
            Set<Id> projectProfilesSetId = new Set<Id>();
            for (Proposal__c proposalItem : newProposalMap.values()){
                projectProfilesSetId.add(proposalItem.Project_Profile__c);
            }
            projectRostersForTaskItemsMap = new Map<Id, Project_Roster__c>([SELECT Id, Role__c, User__c, Project_Profile__c
                                                                            FROM Project_Roster__c
                                                                            WHERE Project_Profile__c IN : projectProfilesSetId AND
                                                                            Project_Profile__c != null]);
        }

        for (Service_Item__c si : serviceItemMap.values()) {
            serviceTemplateIds.add( si.Service_Template__c );
        }

        for( Service_Template__c serviceTemplate : TaskTemplateServices.getServiceTemplatesWithTaskStateChangesAndActualTaskTemplates( serviceTemplateIds ) ){
            taskTemplatesAll.addAll( serviceTemplate.Tasks__r );
//MRS-7041
//            for( Task_State_Change__c tscItem : serviceTemplate.Task_State_Changes__r ) {
//                relatedTaskToTaskLine.put( tscItem.Related_Task__c, tscItem.Task_Line__c );
//            }
        }
        for ( Task_Template__c taskTemplItem : TaskTemplateServices.getTasksWithDurrationByServiceIds( relatedTaskToTaskLine.values() ) ) {
             if ( taskLineToTotalDuration.containsKey( taskTemplItem.Service__c ) ) {
                taskLineToTotalDuration.put( taskTemplItem.Service__c, DateUtils.appendDurations( taskLineToTotalDuration.get(taskTemplItem.Service__c), taskTemplItem.Standard_Duration__c ) );
            } else {
                taskLineToTotalDuration.put( taskTemplItem.Service__c, taskTemplItem.Standard_Duration__c );
            }
        }

        for (Task_Template__c taskTemp : taskTemplatesAll ) {
            if (!serviceIdToTasksTemplates.containsKey( taskTemp.Service__c ) ) {
                serviceIdToTasksTemplates.put( taskTemp.Service__c, new Map<Id, Task_Template__c>() );
            }
            serviceIdToTasksTemplates.get( taskTemp.Service__c ).put( taskTemp.Id, taskTemp );

            if ( relatedTaskToTaskLine.containsKey( taskTemp.Id ) ) {
                taskTemplIdToTotalDuration.put( taskTemp.Id, taskLineToTotalDuration.get( relatedTaskToTaskLine.get( taskTemp.Id ) ) );
            }
        }
        system.debug(LoggingLevel.Error, 'xxx serviceItemMap: ' + serviceItemMap);

        Savepoint sp = Database.setSavepoint();
        if ( !serviceItemMap.isEmpty() ) {
            try {
                // Attach tasks to Project and prepare Milestones
                TaskItemServices.attachTasksToProjectProfiles( serviceItemMap, serviceIdToTasksTemplates, taskTemplIdToTotalDuration, newProposalMap.values(), projectRostersForTaskItemsMap, isChangeOrder );
                // MILESTONE/TASK PREDECESSOR/SUCCESSOR PROCESSING
                TaskItemServices.prepareTaskMilestonePredecessorsSuccessors( serviceItemMap, serviceIdToTasksTemplates );
            } catch( DMLException dmlEx ) {
                Database.rollback(sp);
                if (Trigger.isExecuting){
                    String userNameValue;
                    if ( changeOrders != null && !changeOrders.isEmpty() ){
                        try{
                            Integer i = dmlEx.getMessage().indexOf('[005');
                            if ( (i != -1) && dmlEx.getMessage().contains('INACTIVE_OWNER_OR_USER') && ( (i + 16) <= dmlEx.getMessage().length() ) ){
                                String s = dmlEx.getMessage().substring( i + 1, i + 16 );
                                userNameValue = [SELECT Id, Name FROM User WHERE Id = : s][0].Name;
                            }
                        } catch (Exception ex){}
                    }
                    for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                        if ( changeOrders != null && !changeOrders.isEmpty() ){
                            for (Change_Order__c co : changeOrders){
                                if (!String.isEmpty(userNameValue)){
                                    co.addError( 'This document cannot be awarded because task item owner [' + userNameValue + '] is inactive. Please contact your system administrator to correct the error and try again.');
                                } else {
                                    co.addError( 'Can not prepare Task Items: ' + dmlEx.getMessage());
                                }
                            }
                        } else {
                            for( Proposal__c proposal : newProposalMap.values() ) {
                                proposal.addError( 'Can not prepare Task Items: ' + dmlEx.getMessage());
                            }
                        }
                    }
                } else {
                    throw new ErrorException( 'Can not prepare Task Items: ' + dmlEx.getMessage() );
                }
                return;
            }
            system.debug(LoggingLevel.Error, 'xxx serviceItemMap: ' + serviceItemMap);
            try {
                ServiceItemServices.preventorUpdateServiceItemOwner = false;//MRS-6268
                UPDATE serviceItemMap.values();

            } catch( DMLException dmlEx ) {
                Database.rollback(sp);
                if (Trigger.isExecuting){
                    for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                        if ( changeOrders != null && !changeOrders.isEmpty() ){
                            new Map<Id, Change_Order__c>(changeOrders).get(serviceItemMap.values()[dmlEx.getDmlIndex(i)].Change_Order__c ).addError( 'Can not update Service Item: ' + dmlEx.getMessage() );
                        } else {
                            newProposalMap.get( serviceItemMap.values()[dmlEx.getDmlIndex(i)].Proposal__c ).addError( 'Can not update Service Item: ' + dmlEx.getMessage() );
                        }
                    }
                } else {
                    throw new ErrorException( 'Can not update Service Item: ' + dmlEx.getMessage() );
                }
            } finally {
                ServiceItemServices.preventorUpdateServiceItemOwner = true;
            }
        }
    }

    //need Devs clarification
    public static void setProjectManagerField(List<Project_Profile__c> projectProfileList) {
        String userId;
        for(Project_Profile__c prjectprofile : projectProfileList) {
            userId = prjectprofile.OwnerId;
            if(userId.startsWith(Schema.SObjectType.User.getKeyPrefix())) {
                prjectprofile.Project_Team__r.Production_Manager__c = userId;
            }
        }
    }
    //need Devs clarification
    public static void updateAssigneeProject(Map<Id, Proposal__c> proposals) {
        List<Project_Profile__c> projects = new List<Project_Profile__c>();

        List<Project_Profile__c> projectList = new List<Project_Profile__c>([SELECT Proposal__c, Project_Team__c, Id, Resource__c
                                                                             FROM Project_Profile__c
                                                                             WHERE Proposal__c IN : proposals.keySet()]);

        for (Project_Profile__c p : projectList) {
            if (proposals.containsKey(p.Proposal__c)) {
                p.Project_Team__c = proposals.get(p.Proposal__c).Project_Team__c;
                p.Resource__c = proposals.get(p.Proposal__c).Resource__c;
                projects.add(p);

            }
        }

        //try {
            update projects;

        //} catch(Exception ex) {
            //system.debug('DML exception occured: ' + ex.getMessage());

        //}

    }

    public static void calculateOutstandingAmountsByDate( Set<Id> filteredProfileIds ) {
        List<Project_Profile__c> projectProfiles = [SELECT Outst_Amt_Today__c, Outst_Amt_30__c, Outst_Amt_60__c,
                                                           Outst_Amt_90__c, Outst_Amt_90_Plus__c, Total_Due__c,
                                                           Avoid_Validation_Rules__c,
                                                           (SELECT Invoice_Date__c, Amount_Due__c FROM Pro_forma_Invoices__r
                                                            WHERE Amount_Due__c != 0)
                                                    FROM Project_Profile__c
                                                    WHERE Id IN : filteredProfileIds];
        Date todayDate = Date.today();
        for( Project_Profile__c profileItem : projectProfiles ) {
            profileItem.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();
            profileItem.Outst_Amt_Today__c = profileItem.Outst_Amt_30__c = profileItem.Outst_Amt_60__c = profileItem.Outst_Amt_90__c = profileItem.Outst_Amt_90_Plus__c = 0;
            for( Pro_forma_Invoice__c invItem : profileItem.Pro_forma_Invoices__r ) {
                if( invItem.Amount_Due__c != null && invItem.Invoice_Date__c != null ) {
                    if( invItem.Invoice_Date__c >= todayDate )
                        profileItem.Outst_Amt_Today__c += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < todayDate && invItem.Invoice_Date__c >= (todayDate - 30) )
                        profileItem.Outst_Amt_30__c += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 30) && invItem.Invoice_Date__c >= (todayDate - 60) )
                        profileItem.Outst_Amt_60__c += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 60) && invItem.Invoice_Date__c >= (todayDate - 90) )
                        profileItem.Outst_Amt_90__c += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 90) )
                        profileItem.Outst_Amt_90_Plus__c += invItem.Amount_Due__c;
                }
            }
        }
        //This method can be called from ProjectProfileTrigger while generating Proforma Invoices
        if( !twiceUpdatePreventor ){
            if( !system.isBatch() && !system.isScheduled() ){
                update projectProfiles;
            }else{
                Database.update( projectProfiles, false );
            }
        }
    }

    public static List<Project_Profile__c> filterProjectsForPrebilled( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for ( Project_Profile__c item : projectProfileListNew ){
            if ( item.Pre_billed__c && !projectProfileMapOld.get(item.Id).Pre_billed__c ) {
                filteredProjects.add(item);
            }
        }
        return filteredProjects;
    }

    public static void prebillProjects( List<Project_Profile__c> filteredProjects, Boolean isChangeOrderAdded ){
        if ( filteredProjects.isEmpty() ) return;
        if ( !isAllowedPreBillGenerated ){
            for (Project_Profile__c projectProfileItem : filteredProjects){
                projectProfileItem.addError('Please use the Pre-bill button to pre-bill projects.');
            }
            return;
        }

        List<Project_Profile__c> projectsMilestone = new List<Project_Profile__c>();
        List<Project_Profile__c> projectsInstallmentOrPercentageWithInterval = new List<Project_Profile__c>();
        Map<Id, Project_Profile__c> projectsPercentageWithoutIntervalMap = new Map<Id, Project_Profile__c>();
        Map<Id, Task_Item__c> taskItemsMilestone = new Map<Id, Task_Item__c>();

        List<Billing_Line_Item__c> billingLineItemsList = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> billingLineItemFromBillingDateList = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> bliForHiddenBliCreation = new List<Billing_Line_Item__c>();//MRS-7157

        for( Project_Profile__c projectItem: filteredProjects ){
            if( projectItem.Billing_Method__c == BILLINGMETHODMILESTONE ){
                projectsMilestone.add( projectItem );
            }else if( projectItem.Billing_Method__c == BILLINGMETHODINSTALLMENT || ( projectItem.Billing_Method__c == BILLINGMETHODPERCENTAGE && projectItem.Interval__c )){
                projectsInstallmentOrPercentageWithInterval.add( projectItem );
            }else if( projectItem.Billing_Method__c == BILLINGMETHODPERCENTAGE && !projectItem.Interval__c ){
                projectsPercentageWithoutIntervalMap.put( projectItem.Id, projectItem );
            }

            //Reimbursables
            if( !isChangeOrderAdded ){//remove duplicates
                if( projectItem.Reimbursable1__c != null && projectItem.Reimbursable1__c > 0 ){
                    billingLineItemsList.add( BillingLineItemServices.newReimbursableLineItemScanning ( null, null, projectItem, null ) );
                }
                if( projectItem.Reimbursable2__c != null && projectItem.Reimbursable2__c > 0 ){
                    billingLineItemsList.add( BillingLineItemServices.newReimbursableLineItemShredding ( null, projectItem ) );
                }
                if( projectItem.Reimbursable3__c != null && projectItem.Reimbursable3__c > 0 ){
                    billingLineItemsList.add( BillingLineItemServices.newReimbursableLineItemMunicipal ( projectItem ) );
                }
                if( projectItem.Reimbursable4__c != null && projectItem.Reimbursable4__c > 0 && !projectItem.No_Messenger_Fedex__c ){//!projectItem.No_Messenger_Fedex__c add MRS-6078
                    billingLineItemsList.add( BillingLineItemServices.newReimbursableLineItemMessenger ( projectItem ) );
                }
            }
        }

        for (Billing_Line_Item__c bli : billingLineItemsList){//MRS-6627
            bli.Active_Billing_Line_Item__c = true;
        }

        //Installment and Percentage with interval
        if( !projectsInstallmentOrPercentageWithInterval.isEmpty() ){
            List<Billing_Date__c> billingDateList = new List<Billing_Date__c>();
            for( Billing_Date__c billingDateItem: [Select Id, Billed__c, Project_Profile__c, Percentage__c, Step_Number__c
                                                   From Billing_Date__c
                                                   Where Project_Profile__c IN: projectsInstallmentOrPercentageWithInterval AND
                                                        Billed__c = false] ){
                for( Project_profile__c item: projectsInstallmentOrPercentageWithInterval ){
                    if( !billingDateItem.Billed__c && item.Id == billingDateItem.Project_Profile__c ){
                        billingDateItem.Billed__c = true;
                        billingDateItem.Processing_Day__c = Date.today();

                        billingDateList.add( billingDateItem );
                    }
                }
            }
            TaskItemServices.createBilingLineItemsForBillingDatesBatch( billingDateList, Date.today(), null, true );
            if( !billingDateList.isEmpty() ) update billingDateList;
        }

        //Milestone
        if( !projectsMilestone.isEmpty() ){
            for( Task_Item__c taskItem: [Select Service_Item__c, Project_Profile__c, Pre_billed__c, Phase__c, No_Met_Data_Scanning__c, Name, Is_Locked__c, Id, Expiration_Date__c, Is_Change_Order__c,
                                            CreatedDate, Billing_Trigger__c, Billing_Percentage__c, Billing_Line_Item__c, Approved_Date__c, Actual_Start_Date__c, Actual_End_Date__c, RecordType.Name,
                                            Actual_Duration__c, Activity_Date__c, Hours_Remaining__c, Hours_Reported_For__c, RecordTypeId, Project_Profile__r.Pre_billed__c, Met_Data_Scanning_Fee__c,
                                            OwnerId, Task_Template__r.External_ID__c, Sequence_Number__c, /*MRS 6043*/
                                            (Select Id, Active_Billing_Line_Item__c, Billed__c, Description__c, Pro_forma_Invoice__c From Billing_Line_Items__r Where isHourlyConsulting__c = true)//MRS-6616
                                         From Task_Item__c
                                         Where Project_Profile__c IN: projectsMilestone AND
                                            Billing_Trigger__c = true AND
                                            Service_Item__c != null AND
                                            Service_Item__r.Status__c !=: ServiceItemServices.SERVICE_STATUS_INACTIVE AND
                                            Is_Locked__c = false AND
                                            ( Billing_Line_Item__c = null OR
                                              Hours_Remaining__c > 0 ) AND
                                            ( Service_Item__r.Original__c = true OR
                                              ( (Service_Item__r.Applied_Amendment__c = true OR (Service_Item__r.Applied_Amendment__c = false AND Project_Profile__r.Pre_billed__c = true)) AND
                                                ( Service_Item__r.Is_Amendmend_Deleted__c = false OR Service_Item__r.Change_Order__r.Approved_Date__c = null ) ) ) ] ){

                Boolean doAddtaskForPrebill = true;//MRS-6616

                if ( taskItem.RecordType.Name == TaskItemServices.PERFORM_HOURLY_CONSULTING_TASK_NAME && !taskItem.Billing_Line_Items__r.isEmpty() ){//MRS-6616
                    for (Billing_Line_Item__c bliItem : taskItem.Billing_Line_Items__r){
                        if ( bliItem.Description__c == BillingLineItemServices.PREBILLED_HOURS_DESCRIPTION ){
                            doAddtaskForPrebill = false;
                            continue;
                        }
                    }
                }

                if ( doAddtaskForPrebill ) {
                    taskItemsMilestone.put( taskItem.Id, taskItem );
                }
            }
            TaskItemServices.createBillingLineItemsFromTaskItems( taskItemsMilestone, null, true );
        }

        //Percentage without interval
        if( !projectsPercentageWithoutIntervalMap.isEmpty() ){
            Map<Id, Project_Profile__c> projectsMap = new Map<Id, Project_Profile__c>( filteredProjects );
            Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( projectsMap.keySet(), true );

            for( AggregateResult item: [Select Project_Profile__c proj, SUM( Billing_Line_Item__r.Quantity__c ) quant
                                        From Task_Item__c
                                        Where Project_Profile__c IN: projectsPercentageWithoutIntervalMap.keySet()
                                        GROUP BY Project_Profile__c] ){

                Map<String, Decimal> amountTypeToAmount = projectIdToAmountTypeToAmount.get( (Id)item.get('proj') );

                Billing_Line_Item__c billingLineItem;
                billingLineItem = BillingLineItemServices.initBillingLineItem( null, null, null, projectsPercentageWithoutIntervalMap.get( (Id)item.get('proj') ), null );

                //MRS-6368
                if( amountTypeToAmount.get(BillingLineItemServices.TOTAL_AMOUNT) > 0 || isChangeOrderAdded ){//MRS-7534
                    billingLineItem.Amount__c = amountTypeToAmount.get(BillingLineItemServices.TOTAL_AMOUNT) - amountTypeToAmount.get(BillingLineItemServices.BILLED_AMOUNT);
                    billingLineItem.Quantity__c = billingLineItem.Amount__c/amountTypeToAmount.get(BillingLineItemServices.TOTAL_AMOUNT);
                    billingLineItem.Unit_Price__c = projectsPercentageWithoutIntervalMap.get( (Id)item.get('proj') ).Discounted_Total_Service_Amount__c;

                    if( amountTypeToAmount != null ){

                        billingLineItem.Sales_Tax_Amount_1__c = ( ( billingLineItem.Quantity__c / amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) ) * 100 *
                                                                ( amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) ) ).setScale(2);
                        billingLineItem.Sales_Tax_Amount_2__c = ( ( billingLineItem.Quantity__c / amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) ) * 100 *
                                                                        ( amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) ) ).setScale(2);
                    }

                } 

                //MRS-6368 add condition
                if ( billingLineItem.Quantity__c != null && billingLineItem.Quantity__c > 0 && billingLineItem.Amount__c != null && billingLineItem.Amount__c > 0 ) {
                    billingLineItemsList.add( billingLineItem );
                    bliForHiddenBliCreation.add( billingLineItem );//MRS-7157
                }


            }
        }

        if( !billingLineItemsList.isEmpty() ) insert billingLineItemsList;

          if( !bliForHiddenBliCreation.isEmpty() ) {//MRS-7157
              HiddenBliCalculator hiddenBliCalculator = new HiddenBliCalculator( bliForHiddenBliCreation );
              Database.insert( hiddenBliCalculator.getHiddenBli(), false );
          }

    }

    public static Set<Id> filteredProjectTeamsIdList( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        Set<Id> filteredProjectTeamsIdList = new Set<Id>();
        for ( Project_Profile__c item : projectProfileListNew ){
            Id itemId = (projectProfileMapOld != null) ? projectProfileMapOld.get(item.id).Project_Team__c : null;
            if ( item.Project_Team__c != itemId ) {
                filteredProjectTeamsIdList.add(item.Project_Team__c);
                if( itemId != null ) filteredProjectTeamsIdList.add(itemId);
            }
        }
        return filteredProjectTeamsIdList;
    }

    public static List<Project_Profile__c> filterProjectsWithChangedProjectTeamsOrOtherLookupFields( List<Project_Profile__c> newProjects, Map<Id, Project_Profile__c> oldProjects ){
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for( Project_Profile__c project : newProjects ) {
            String oldProjectState = oldProjects.get( project.Id ).Project_State__c;//MRS-6358, MRS-6344
            if( ( project.Project_Team__c != null ||
                  project.FREP__c != null ||
                  project.Production_Manager__c != null ) && //MRS-6271
                ( ( project.Project_Team__c != oldProjects.get( project.Id ).Project_Team__c ||
                    project.FREP__c != oldProjects.get( project.Id ).FREP__c || //MRS-6271
                    project.Production_Manager__c != oldProjects.get( project.Id ).Production_Manager__c ) ||
                  ( project.Project_State__c != null &&
                    project.IsAssigmentsFromProjectTeam__c &&
                    ( ( oldProjectState == PROJECT_STATE_COMPLETE && project.Project_State__c == PROJECT_STATE_IN_PROCESS ) ||
                      ( oldProjectState == PROJECT_STATE_CLOSED && project.Project_State__c != oldProjectState ) ) ) ) ) {
                filteredProjects.add( project );
            }
        }
        return filteredProjects;
    }

    public static Set<Id> filterProjectsWithChangedFrep( List<Project_Profile__c> newProjects, Map<Id, Project_Profile__c> oldProjects ) {//MRS-6271
        Set<Id> filteredProjectProfileIds = new Set<Id>();
        for( Project_Profile__c project : newProjects ) {
            if( project.FREP__c != null && project.FREP__c != oldProjects.get( project.id ).FREP__c ) {
                filteredProjectProfileIds.add( project.Id );
            }
        }
        return filteredProjectProfileIds;
    }

    public static Set<Id> filterProjectsWithChangedProductionManager( List<Project_Profile__c> newProjects, Map<Id, Project_Profile__c> oldProjects ) {
        Set<Id> filteredProjectProfileIds = new Set<Id>();
        for( Project_Profile__c project : newProjects ) {
            if( project.Production_Manager__c != null && project.Production_Manager__c != oldProjects.get( project.id ).Production_Manager__c ) {
                filteredProjectProfileIds.add( project.Id );
            }
        }
        return filteredProjectProfileIds;
    }

    public static List<Project_Profile__c> filterProjectsWithChangedProjectOwner( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        List<Project_Profile__c> filteredProjectProfiles = new List<Project_Profile__c>();
        for ( Project_Profile__c item : projectProfileListNew ){
            if ( item.OwnerId != projectProfileMapOld.get(item.id).OwnerId ||
                 item.FREP__c != projectProfileMapOld.get(item.id).FREP__c ||
                 item.Production_Manager__c != projectProfileMapOld.get(item.id).Production_Manager__c ||
                 item.Project_Member__c != projectProfileMapOld.get(item.id).Project_Member__c ||
                 item.Project_Manager__c != projectProfileMapOld.get(item.id).Project_Manager__c ||
                 item.Partner__c != projectProfileMapOld.get(item.id).Partner__c ||
                 item.Account_Executive__c != projectProfileMapOld.get(item.id).Account_Executive__c ||
                 item.Proposal_Specialist__c != projectProfileMapOld.get(item.id).Proposal_Specialist__c ||
                 item.Salesperson__c != projectProfileMapOld.get(item.id).Salesperson__c ) {

                    filteredProjectProfiles.add( item );
            }
        }
        return filteredProjectProfiles;
    }

    public static Map<Id, Project_Profile__c> filterProjectsWithChangedBillingAccountsContacts( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        Map<Id, Project_Profile__c> filteredProjectProfilesMap = new Map<Id, Project_Profile__c>();
        for ( Project_Profile__c item : projectProfileListNew ){
            if ( item.Accounting_Contact__c != projectProfileMapOld.get(item.id).Accounting_Contact__c ||
                 item.Accounting_Contact_Company__c != projectProfileMapOld.get(item.id).Accounting_Contact_Company__c ||
                 item.Billing_Company_Contact__c != projectProfileMapOld.get(item.id).Billing_Company_Contact__c ||
                 item.Billing_Company_Name__c != projectProfileMapOld.get(item.id).Billing_Company_Name__c ) {

                    filteredProjectProfilesMap.put( item.Id, item );
            }
        }
        return filteredProjectProfilesMap;
    }

    public static void updateProjectTeam( List<Project_Profile__c> projectProfileListNew, Set<Id> projectsWithChangedFrep, Set<Id> projectsWithChangedProductionManager ) {
        if( projectProfileListNew.isEmpty() ) return;

        Map<Id, Project_Team__c> projectTeamIdToProjectTeamMap = ProjectTeamServices.getProjectIdToProjectTeam( projectProfileListNew );

        for( Project_Profile__c item : projectProfileListNew ) {
            Project_Team__c itemProjectTeam = projectTeamIdToProjectTeamMap.get( item.Project_Team__c );
            if( itemProjectTeam != null ) {
                item.Project_Team__c = itemProjectTeam.Id;
                if( item.OwnerId == item.Project_Manager__c || item.Project_Manager__c == null ) {
                    item.OwnerId = itemProjectTeam.Project_Manager__c ;
                }
                item.Project_Manager__c = itemProjectTeam.Project_Manager__c;
                item.Project_Member__c = itemProjectTeam.Project_Member__c;
                if( !projectsWithChangedFrep.contains( item.Id ) ) {//MRS-6271
                    item.FREP__c = itemProjectTeam.FREP__c;
                }
                if( !projectsWithChangedProductionManager.contains( item.Id ) ) {
                    item.Production_Manager__c = itemProjectTeam.Production_Manager__c;
                }
            }
        }
    }

    public static void updateProjectRoster( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        if( projectProfileListNew.isEmpty() ) return;

        Id userProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId( 'Project_Roster__c', ProjectRosterServices.TYPE_USER );
        List<Project_Roster__c> allRosters = new List<Project_Roster__c>();
        List<Id> projectProfileListId = new List<Id>();

        for ( Project_Profile__c item : projectProfileListNew ){
            projectProfileListId.add(item.Id);

            if( item.OwnerId != item.Project_Manager__c && item.OwnerId != projectProfileMapOld.get(item.id).OwnerId ){
                allRosters.add( createAfterAssignProjectRoster ( item.OwnerId,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 ProjectRosterServices.PROJECT_OWNER_ROLE,
                                                                 null ) );
            }

            if( item.Project_Manager__c != null && item.Project_Manager__c != projectProfileMapOld.get(item.id).Project_Manager__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Project_Manager__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 UserServices.PROFILE_PROJECT_MANAGER_2,
                                                                 null ) );

            }

            if( item.Project_Member__c != null && item.Project_Member__c != projectProfileMapOld.get(item.id).Project_Member__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Project_Member__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 UserServices.PROFILE_PROJECT_MANAGER_1,
                                                                 null ) );

            }
            if( item.FREP__c != null && item.FREP__c != projectProfileMapOld.get(item.id).FREP__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.FREP__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 ProjectRosterServices.FILING_REP,
                                                                 null ) );

            }
            if( item.Production_Manager__c != null && item.Production_Manager__c != projectProfileMapOld.get(item.id).Production_Manager__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Production_Manager__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 UserServices.PROFILE_PRODUCTION_MANAGER,
                                                                 null ) );

            }

            if( item.Partner__c != null && item.Partner__c != projectProfileMapOld.get(item.id).Partner__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Partner__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 ProjectRosterServices.PARTNER,
                                                                 null ) );

            }

            if( item.Account_Executive__c != null && item.Account_Executive__c != projectProfileMapOld.get(item.id).Account_Executive__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Account_Executive__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 ProjectRosterServices.ACCOUNT_MANAGER,
                                                                 null ) );

            }

            if( item.Proposal_Specialist__c != null && item.Proposal_Specialist__c != projectProfileMapOld.get(item.id).Proposal_Specialist__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Proposal_Specialist__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 UserServices.PROFILE_PROPOSAL_SPECIALIST,
                                                                 null ) );

            }

            if( item.Salesperson__c != null && item.Salesperson__c != projectProfileMapOld.get(item.id).Salesperson__c ){
                allRosters.add( createAfterAssignProjectRoster ( item.Salesperson__c,
                                                                 item.Id,
                                                                 item.Proposal__c,
                                                                 userProjectRosterRecordTypeId,
                                                                 ProjectRosterServices.SALESPERSON,
                                                                 null ) );

            }
        }

        try {
            insert allRosters;
            ProjectRosterServices.deactivateProjectRosters(allRosters);
        } catch ( DmlException dmlEx ){
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                new Map<Id, Project_Profile__c>(projectProfileListNew).get( allRosters[i].Project_Profile__c ).addError( 'Can not update Roster after changing Proposal Creator. ' + dmlEx.getMessage() );
            }
        }
        ProjectRosterServices.updateRostersIsActiveState(projectProfileListId, null, true, true, false, true);
    }

    public static void createProjectRosterForChangedContact( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        List<Project_Roster__c> rostersToInsert = new List<Project_Roster__c>();

        Map<Id, Map<String, Project_Roster__c>> projectIdToRoleToRoster;
        List<Id> projectProfileListId = new List<Id>();

        for( Project_Profile__c project : projectProfileListNew ) {
            projectProfileListId.add(project.Id);
            Project_Profile__c projectProfileOld = projectProfileMapOld.get(project.Id);
            if( project.Primary_Company_Contact__c != null && project.Primary_Company_Contact__c != projectProfileOld.Primary_Company_Contact__c ) {
                if( projectIdToRoleToRoster == null ) {
                    projectIdToRoleToRoster = getProjectIdToRoleToRosterForProjects( projectProfileListNew, projectProfileMapOld );
                }
                rostersToInsert.add( createProjectRosterForContact( project.Primary_Company_Contact__c,
                                                                    project.Id,
                                                                    project.Proposal__c,
                                                                    ProjectRosterServices.PRIMARY_CLIENT_CONTACT,
                                                                    null,
                                                                    projectIdToRoleToRoster.get( project.Id ).get( ProjectRosterServices.PRIMARY_CLIENT_CONTACT ) ) );
            }
            if( project.Billing_Company_Contact__c != null && project.Billing_Company_Contact__c != projectProfileOld.Billing_Company_Contact__c ) {
                if( projectIdToRoleToRoster == null ) {
                    projectIdToRoleToRoster = getProjectIdToRoleToRosterForProjects( projectProfileListNew, projectProfileMapOld );
                }
                rostersToInsert.add( createProjectRosterForContact( project.Billing_Company_Contact__c,
                                                                    project.Id,
                                                                    project.Proposal__c,
                                                                    ProjectRosterServices.BILLING_CLIENT_CONTACT,
                                                                    null,
                                                                    projectIdToRoleToRoster.get( project.Id ).get( ProjectRosterServices.BILLING_CLIENT_CONTACT ) ) );
            }
            if( project.Accounting_Contact__c != null && project.Accounting_Contact__c != projectProfileOld.Accounting_Contact__c ) {
                if( projectIdToRoleToRoster == null ) {
                    projectIdToRoleToRoster = getProjectIdToRoleToRosterForProjects( projectProfileListNew, projectProfileMapOld );
                }
                rostersToInsert.add( createProjectRosterForContact( project.Accounting_Contact__c,
                                                                    project.Id,
                                                                    project.Proposal__c,
                                                                    ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT,
                                                                    null,
                                                                    projectIdToRoleToRoster.get( project.Id ).get( ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT ) ) );
            }
        }

        if( !rostersToInsert.isEmpty() ) {
            Id projectRosterContactRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId( 'Project_Roster__c', ProjectRosterServices.TYPE_CONTACT );
            for( Project_Roster__c projectRosterItem : rostersToInsert ) {
                projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
            }
            try {
                INSERT rostersToInsert;
                ProjectRosterServices.deactivateProjectRosters(rostersToInsert);
            } catch( DMLException dmlEx ) {
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                    new Map<Id, Project_Profile__c>(projectProfileListNew).get( rostersToInsert[i].Project_Profile__c ).addError( 'Can not create Roster after changing Contact. ' + dmlEx.getMessage() );
                }
            }
        }
        ProjectRosterServices.updateRostersIsActiveState(projectProfileListId, null, false, false, true, false);
    }

    public static Map<Id, Map<String, Project_Roster__c>> getProjectIdToRoleToRosterForProjects( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        Map<Id, Map<String, Project_Roster__c>> projectIdToRoleToRoster = new Map<Id, Map<String, Project_Roster__c>>();
        for( Project_Profile__c project : projectProfileListNew ) {
            projectIdToRoleToRoster.put( project.Id, new Map<String, Project_Roster__c>() );
        }
        for( Project_Roster__c roster : [ SELECT Id, To__c, Cc__c, Role__c, Project_Profile__c, Contact__c, CreatedDate
                                          FROM Project_Roster__c
                                          WHERE Project_Profile__c IN : projectProfileListNew
                                            AND Is_Read__c = true
                                            /*AND Initially_Added_Roster__c = true*/
                                            AND Contact__c != null
                                            AND Is_Manually_Added_Roster__c = false
                                            AND Role__c IN : new List<String>{ ProjectRosterServices.PRIMARY_CLIENT_CONTACT,
                                                                               ProjectRosterServices.BILLING_CLIENT_CONTACT,
                                                                               ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT } ] ) {
            if( ( roster.Role__c == ProjectRosterServices.PRIMARY_CLIENT_CONTACT && projectProfileMapOld.get( roster.Project_Profile__c ).Primary_Company_Contact__c == roster.Contact__c ) ||
                ( roster.Role__c == ProjectRosterServices.BILLING_CLIENT_CONTACT && projectProfileMapOld.get( roster.Project_Profile__c ).Billing_Company_Contact__c == roster.Contact__c ) ||
                ( roster.Role__c == ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT && projectProfileMapOld.get( roster.Project_Profile__c ).Accounting_Contact__c == roster.Contact__c ) ) {
                Map<String, Project_Roster__c> roleToRoster = projectIdToRoleToRoster.get( roster.Project_Profile__c );
                if( roleToRoster.get( roster.Role__c ) == null ||
                    roleToRoster.get( roster.Role__c ).CreatedDate < roster.CreatedDate ) {
                    roleToRoster.put( roster.Role__c, roster );
                }
            }
        }
        return projectIdToRoleToRoster;
    }

    public static Project_Roster__c createProjectRosterForContact( Id contactId, Id projectId, Id proposalId, String role, Id recordTypeId, Project_Roster__c oldRoster ) {
        Project_Roster__c newAfterAssignProjectRoster = new Project_Roster__c();

        newAfterAssignProjectRoster.Active__c = true;
        newAfterAssignProjectRoster.Contact__c = contactId;
        newAfterAssignProjectRoster.Project_Profile__c = projectId;
        newAfterAssignProjectRoster.Proposal__c = proposalId;
        newAfterAssignProjectRoster.Role__c = role;
        newAfterAssignProjectRoster.User_Type__c = ProjectRosterServices.USER_TYPE_EX;
        newAfterAssignProjectRoster.RecordTypeId = recordTypeId;
        if( role == ProjectRosterServices.PRIMARY_CLIENT_CONTACT ||
            role == ProjectRosterServices.BILLING_CLIENT_CONTACT ||
            role == ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT ) {
            //newAfterAssignProjectRoster.Initially_Added_Roster__c = true;
            newAfterAssignProjectRoster.Is_Read__c = true;
        }
        if( oldRoster != null ) {
            newAfterAssignProjectRoster.To__c = oldRoster.To__c;
            newAfterAssignProjectRoster.Cc__c = oldRoster.Cc__c;
        }

        return newAfterAssignProjectRoster;
    }

    //MRS-7529
    public static List<Project_Profile__c> updateProjectTeamAssignment ( List<Project_Profile__c> projectProfiles ) {
        Map<Id, Project_Profile__c> projectForUpdateMap = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : projectProfiles){
            if ( projectProfileItem.Project_Manager__c == projectProfileItem.OwnerId &&
                  ( projectProfileItem.Project_State__c == PROJECT_STATE_NOT_STARTED ||
                    projectProfileItem.Project_State__c == PROJECT_STATE_IN_PROCESS ||
                    projectProfileItem.Project_State__c == PROJECT_STATE_ON_HOLD ) ){//MRS-7572
                projectProfileItem.OwnerId               = projectProfileItem.Project_Team__r.Project_Manager__c;
            }
            projectProfileItem.Project_Manager__c        = projectProfileItem.Project_Team__r.Project_Manager__c;
            projectProfileItem.Project_Member__c         = projectProfileItem.Project_Team__r.Project_Member__c;
            projectProfileItem.FREP__c                   = projectProfileItem.Project_Team__r.FREP__c;
            projectProfileItem.Production_Manager__c     = projectProfileItem.Project_Team__r.Production_Manager__c;
            projectProfileItem.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();//add for avoid validation rule for "On Hold" Projects
            projectForUpdateMap.put(projectProfileItem.Id, projectProfileItem);
        }

        List<Project_Profile__c> projectsToUpdate = new List<Project_Profile__c>();

        Database.SaveResult[] srList = Database.update(projectForUpdateMap.values(), false);

        for (Database.SaveResult sr : srList){
            if (sr.isSuccess()){
                projectsToUpdate.add( projectForUpdateMap.get( sr.getId() ) );
            }
        }

        return projectsToUpdate;
    }

    public static void updateProjectStage( Map<Id, Task_Item__c> upcommingTaskItemsMap ) {
        if( upcommingTaskItemsMap.isEmpty() ) return;

        Set<Id> projectIds = new Set<Id>();
        List<Project_Profile__c> projetProfilesWithStage = new List<Project_Profile__c>();

        for( Task_Item__c taskItem : upcommingTaskItemsMap.values() ) {
            projectIds.add( taskItem.Project_Profile__c );
        }

        for( Project_Profile__c proj : [ Select Id, Project_State__c,
                                                ( Select Id
                                                  From Task_Items__r
                                                  Where Actual_End_Date__c = null
                                                        And Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE
                                                        And RecordType.Name != :TaskManagementServices.MILESTONE_RECORDTYPE_NAME LIMIT 1)
                                         From Project_Profile__c
                                         Where Id IN :projectIds ] ) {
            Boolean noActualTasks = true;
            for( Task_Item__c ti : proj.Task_Items__r ){
                noActualTasks = false;
                break;
            }

           if( noActualTasks ){
                proj.Project_State__c = PROJECT_STATE_COMPLETE;
                projetProfilesWithStage.add( proj );
            }
        }
        update projetProfilesWithStage;
    }

    public static void updateProjectStage( Set<Id> projectProfileSetId, List<Service_Item__c> serviceItemListNew, List<Change_Order__c> changeOrderListNew ) {
        if( projectProfileSetId.isEmpty() ) return;

        List<Project_Profile__c> projetProfilesWithStage = new List<Project_Profile__c>();

        for (Project_Profile__c projectProfileItem : [SELECT Id, Project_State__c, Avoid_Validation_Rules__c,
                                                            (Select Id From Change_Orders__r Where Not Status__c IN : new List<String>{ChangeOrderServices.STATUS_APPROVED,  //MRS-6927
                                                                                                                                       ChangeOrderServices.STATUS_CANCELED,
                                                                                                                                       ChangeOrderServices.STATUS_DRAFT}
                                                                    Limit 1),
                                                            (Select Id
                                                             From Service_Items__r
                                                             Where Is_Alternative__c = false And
                                                                (Not (Is_Amendmend_Deleted__c = true And Change_Order__r.Status__c = : ChangeOrderServices.STATUS_APPROVED) ) And
                                                                (Not (Change_Order__c != null And Change_Order__r.Approved_Date__c = null And Change_Order__r.Status__c = : ChangeOrderServices.STATUS_CANCELED) ) And
                                                                ( (Original__c = true And Actual_End_Date__c = null) Or
                                                                  (Change_Order__c != null And Change_Order__r.Approved_Date__c != null And Actual_End_Date__c = null) Or
                                                                  (Change_Order__c != null And Change_Order__r.Approved_Date__c = null)
                                                                ) Limit 1)
                                                      FROM Project_Profile__c
                                                      WHERE Id IN : projectProfileSetId]){
            if ( projectProfileItem.Service_Items__r.isEmpty() && projectProfileItem.Change_Orders__r.isEmpty() ) {
                projectProfileItem.Project_State__c = PROJECT_STATE_COMPLETE;
                projectProfileItem.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();
                projetProfilesWithStage.add(projectProfileItem);
            } else if ( !projectProfileItem.Service_Items__r.isEmpty() && projectProfileItem.Project_State__c == PROJECT_STATE_COMPLETE ){//MRS-6669
                projectProfileItem.Project_State__c = PROJECT_STATE_IN_PROCESS;
                projectProfileItem.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();
                projetProfilesWithStage.add(projectProfileItem);
            }
        }

        try {
            if (!projetProfilesWithStage.isEmpty()){
                update projetProfilesWithStage;
            }
        } catch (DMLException dmlEx){
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                    if (serviceItemListNew != null && !serviceItemListNew.isEmpty()){
                        for (Service_Item__c si : serviceItemListNew){
                            if (si.Project_Profile__c == projetProfilesWithStage[i].Id){
                                si.addError('Can not Complete Project Profile. ' + dmlEx.getMessage());
                            }
                        }
                    } else if (changeOrderListNew != null && !changeOrderListNew.isEmpty()){
                        for (Change_Order__c co : changeOrderListNew){
                            if (co.Project_Profile__c == projetProfilesWithStage[i].Id){
                                co.addError('Can not Complete Project Profile. ' + dmlEx.getMessage());
                            }
                        }
                    }
                }
        }
    }

    public static void setKey( List<Project_Profile__c> projectsFromTrigger ) {
        for( Project_Profile__c item : projectsFromTrigger ) {
            item.Key__c = MilroseDevHelper.getUniqueKey();
        }
    }

    public static void updateExpectedProjectEndDate( Set<Id> projectIdSet, List<Task_Item__c> taskItemListNew ) {
        if( projectIdSet.isEmpty() ) return;

        List<Project_Profile__c> projectsToUpdate = [ Select Id, Project_Expected_End_Date__c,
                                                             ( Select Id, Expected_End_Date__c From Task_Items__r
                                                               Where Expected_End_Date__c != null Order By Expected_End_Date__c DESC limit 1)
                                                      From Project_Profile__c
                                                      Where Id IN: projectIdSet ];

        for( Project_Profile__c proj : projectsToUpdate ) {
            if( !proj.Task_Items__r.isEmpty() ) {
                proj.Project_Expected_End_Date__c = proj.Task_Items__r[0].Expected_End_Date__c;
            }
        }
        try {
            update projectsToUpdate;
        } catch (DMLException dmlEx){
            if ( Trigger.isExecuting && taskItemListNew != null ){
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                    Id projectProfileId = projectsToUpdate[dmlEx.getDmlIndex(i)].Id;
                    for ( Task_Item__c taskItem : taskItemListNew ){
                        if ( taskItem.Project_Profile__c == projectProfileId ) taskItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                    }
                }
            } else{
                throw new ErrorException ( dmlEx.getMessage() );
            }
        }
    }

    public static void updateServiceItemTaskItemOwnerChangeProjectTeam( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileNewMap ) {
        updateServiceItemTaskItemOwnerChangeProjectTeam( projectProfileListNew, projectProfileNewMap, false );
    }

    public static void updateServiceItemTaskItemOwnerChangeProjectTeam( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileNewMap, Boolean runsFromBatch ) {
        if( projectProfileListNew.isEmpty() ) return;

        // update Service Items
        //MRS-7529
        Set<String> resurces = ProjectTeamServices.PROJECT_TEAM_USERS;
        String serviceItemQuery = 'SELECT Id, OwnerId, Role_Assignment__c, Manager_Lookup__c, Project_Profile__r.Project_Team__r.Project_Manager__c, Project_Profile__r.Project_Team__r.FREP__c, ' +
                                  '       Project_Profile__r.Project_Team__r.Project_Member__c, Project_Profile__r.Project_Team__c, Project_Profile__c, Owner_Profile__c, Service_Name_Short__c, ' +
                                  '       Avoid_Validation_Rule__c, Project_Profile__r.Project_Team__r.Production_Manager__c, Service_Template__r.RecordType.Name ' +
                                  'FROM Service_Item__c ' +
                                  'WHERE Project_Profile__c IN : projectProfileListNew ' +
                                  '     AND ( ( Role_Assignment__c IN : resurces ) Or ' +
                                  '           ( Service_Template__r.RecordType.Name = \'' + ServiceItemServices.APS_SERVICE_RECORD_TYPE_NAME + '\' And Role_Assignment__c = null ) ) ';
        if ( !runsFromBatch ){
            serviceItemQuery += '       AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\' ';
            serviceItemQuery += '       AND Service_Template__r.RecordType.Name = \'' + ServiceItemServices.APS_SERVICE_RECORD_TYPE_NAME + '\' ';
            serviceItemQuery += '       AND Actual_End_Date__c = null';
        }
        List<Service_Item__c> serviceItemList = Database.query( serviceItemQuery );

        List<Service_Item__c> serviceItemUpdateList = new List<Service_Item__c>();
        for (Service_Item__c serviceItem: serviceItemList) {
            if ( serviceItem.Project_Profile__r.Project_Team__c == null ) continue;
            Boolean toUpdate = false;
            Project_Team__c team = serviceItem.Project_Profile__r.Project_Team__r;

            if ( serviceItem.Service_Template__r.RecordType.Name == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME ){
                if( serviceItem.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_FILLING_REP && serviceItem.Owner_Profile__c.contains( UserServices.PROFILE_FREP ) ) {

                    if ( serviceItem.OwnerId != team.FREP__c ) {
                        serviceItem.OwnerId = team.FREP__c;
                        serviceItem.Manager_Lookup__c = serviceItem.OwnerId;
                        toUpdate = true;
                    }
                }
                if( serviceItem.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_PRODUCTION_MANAGER && serviceItem.Owner_Profile__c.contains( UserServices.PROFILE_PRODUCTION_MANAGER ) ) {

                    if ( serviceItem.OwnerId != team.Production_Manager__c ) {
                        serviceItem.OwnerId = team.Production_Manager__c;
                        serviceItem.Manager_Lookup__c = serviceItem.OwnerId;
                        toUpdate = true;
                    }
                }
                if( (serviceItem.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_MANAGER || serviceItem.Role_Assignment__c == ProjectTeamServices.RESOURCE_ROLE_MEMBER) &&
                      serviceItem.Owner_Profile__c.contains( UserServices.PROFILE_PROJECT_MANAGER ) ){

                    if ( serviceItem.OwnerId != team.Project_Manager__c ) {
                        serviceItem.OwnerId = team.Project_Manager__c;
                        serviceItem.Manager_Lookup__c = serviceItem.OwnerId;
                        toUpdate = true;
                    }
                }
            } else {
                if( serviceItem.Owner_Profile__c.contains( UserServices.PROFILE_PROJECT_MANAGER ) || serviceItem.Role_Assignment__c == null ){
                    if ( serviceItem.OwnerId != team.Project_Manager__c ) {
                        serviceItem.OwnerId = team.Project_Manager__c;
                        toUpdate = true;
                    }
                }
                if ( serviceItem.Manager_Lookup__c != team.Project_Manager__c ) {
                    serviceItem.Manager_Lookup__c = team.Project_Manager__c;
                    if( serviceItem.Role_Assignment__c == null) serviceItem.Role_Assignment__c = UserServices.PROFILE_PROJECT_MANAGER_2;
                    toUpdate = true;
                }
            }

            if ( toUpdate ){
                serviceItemUpdateList.add( serviceItem );
            }
        }

        // update Task Items
        //MRS-7529
        String taskItemQuery = 'SELECT Id, OwnerId, Manager_Lookup__c, Project_Profile__c, Project_Profile__r.Project_Team__r.FREP__c, Resources__c, ' +
                               '    Project_Profile__r.Project_Team__r.Project_Member__c, Project_Profile__r.Project_Team__r.Project_Manager__c, ' +
                               '    Project_Profile__r.Project_Team__r.Production_Manager__c, RecordType.Name, Owner_Profile__c, Is_Roepen_Project__c, ' +
                               '    Project_Profile__r.FREP__c, Avoid_Validation_Rules__c ' +
                               'FROM Task_Item__c ' +
                               'WHERE Project_Profile__c IN  : projectProfileListNew ';
        if ( !runsFromBatch ){
            taskItemQuery += '       AND Service_Item__r.Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\' ';
            taskItemQuery += '       AND Resources__c IN : resurces ';
            taskItemQuery += '       AND Actual_End_Date__c = null ';
        }
        List<Task_Item__c> taskItemList = Database.query( taskItemQuery );

        List<Task_Item__c> taskItemUpdateList = new List<Task_Item__c>();
        for (Task_Item__c taskItem: taskItemList) {
            if ( taskItem.Project_Profile__r.Project_Team__c == null ) continue;
            Boolean toUpdate = false;
            Project_Team__c team = taskItem.Project_Profile__r.Project_Team__r;
            if (  taskItem.RecordType.Name.equals( TaskManagementServices.MILESTONE_RECORDTYPE_NAME ) &&
                  taskItem.OwnerId != team.Project_Member__c ) {
                taskItem.OwnerId = team.Project_Member__c;
                toUpdate = true;
            } else {
                if ( ProjectTeamServices.PROJECT_TEAM_USERS.contains( taskItem.Resources__c ) &&
                    ( ProjectTeamServices.PROJECT_TEAM_USERS.contains( taskItem.Owner_Profile__c ) || taskItem.Manager_Lookup__c == null ) ) {
                    if ( taskItem.Resources__c.equals( ProjectTeamServices.RESOURCE_ROLE_FILLING_REP ) ) {
                        if ( taskItem.OwnerId != taskItem.Project_Profile__r.FREP__c/*MRS-6271*//*team.FREP__c*/ || taskItem.Manager_Lookup__c != team.Project_Member__c ) {
                            taskItem.OwnerId = taskItem.Project_Profile__r.FREP__c/*MRS-6271*//*team.FREP__c*/;
                            taskItem.Manager_Lookup__c = team.Project_Member__c;
                            toUpdate = true;
                        }
                    } else if ( taskItem.Resources__c.equals( ProjectTeamServices.RESOURCE_ROLE_MEMBER ) ) {
                        if ( taskItem.OwnerId != team.Project_Member__c || taskItem.Manager_Lookup__c != team.Project_Manager__c) {
                            taskItem.OwnerId = team.Project_Member__c;
                            taskItem.Manager_Lookup__c = team.Project_Manager__c;
                            toUpdate = true;
                        }
                    } else if ( taskItem.Resources__c.equals( ProjectTeamServices.RESOURCE_ROLE_PRODUCTION_MANAGER ) ) {
                        if ( taskItem.OwnerId != team.Production_Manager__c || taskItem.Manager_Lookup__c != team.Production_Manager__c) {
                            taskItem.OwnerId = team.Production_Manager__c;
                            taskItem.Manager_Lookup__c = team.Production_Manager__c;
                            toUpdate = true;
                        }
                    } else if ( taskItem.Resources__c.equals( ProjectTeamServices.RESOURCE_ROLE_MANAGER ) ) {
                        if ( taskItem.OwnerId != team.Project_Manager__c || taskItem.Manager_Lookup__c != team.Project_Manager__c ) {
                            taskItem.OwnerId = team.Project_Manager__c;
                            taskItem.Manager_Lookup__c = team.Project_Manager__c;
                            toUpdate = true;
                        }
                    }
                }

            }

            if ( toUpdate ) {
                if (isReopenProject) taskItem.Is_Roepen_Project__c = taskItem.Is_Roepen_Project__c == null ? false : !taskItem.Is_Roepen_Project__c;
                if (runsFromBatch){//MRS-7529
                    taskItem.Avoid_Validation_Rules__c = !taskItem.Avoid_Validation_Rules__c;
                }
                taskItemUpdateList.add(taskItem);
            }
        }

        ServiceItemServices.preventorUpdateServiceItemOwner = false;

        if( runsFromBatch ) {
            Database.update( serviceItemUpdateList, false );
            Database.update( taskItemUpdateList, false );
        } else {
            try {
                UPDATE serviceItemUpdateList;
            } catch (DMLException dmlEx){
                if (Trigger.isExecuting){
                    Map<Id, Service_Item__c> serviceItemErrorHandleMap = new Map<Id, Service_Item__c>(serviceItemUpdateList);
                    for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                        projectProfileNewMap.get( serviceItemErrorHandleMap.get( serviceItemUpdateList[dmlEx.getDmlIndex(i)].Id ).Project_Profile__c ).addError( 'Can not update Service Item.' + dmlEx.getMessage() );
                    }
                } else {
                    ServiceItemServices.preventorUpdateServiceItemOwner = true;
                    throw new ErrorException ( 'Can not update Service Item.' + dmlEx.getMessage() );
                }
            }

            try {
                UPDATE taskItemUpdateList;
            } catch (DMLException dmlEx){
                if (Trigger.isExecuting){
                    Map<Id, Task_Item__c> taskItemErrorHandleMap = new Map<Id, Task_Item__c>(taskItemUpdateList);
                    for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                        projectProfileNewMap.get( taskItemErrorHandleMap.get( taskItemUpdateList[dmlEx.getDmlIndex(i)].Id ).Project_Profile__c ).addError(Label.Update_Task_Item_Error + dmlEx.getMessage());
                    }
                } else {
                    ServiceItemServices.preventorUpdateServiceItemOwner = true;
                    throw new ErrorException ( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                }
            }
        }

        ServiceItemServices.preventorUpdateServiceItemOwner = true;
    }

    public static void updateProjectTeamExpectedDuration( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        if ( projectProfileListNew.isEmpty() ) return;

        Map<Id, Integer> projectProfileWithTotalTaskItemDuration = new Map<Id, Integer>();
        Map<Id, Project_Team__c> projectTeamUpdatedMap = new Map<Id, Project_Team__c>();

        // Initialization of processing Project Teams with actual duration
        for ( Project_Profile__c projectProfileItem : projectProfileListNew ) {
            projectProfileWithTotalTaskItemDuration.put( projectProfileItem.Id, 0 );

            if( !projectTeamUpdatedMap.containsKey( projectProfileItem.Project_Team__c ) ){
                projectTeamUpdatedMap.put( projectProfileItem.Project_Team__c,
                                           new Project_Team__c( Id = projectProfileItem.Project_Team__c,
                                                                Expected_Duration__c = projectProfileItem.Project_Team_Duration__c ) );
            }

            Id oldProjectTeamId = projectProfileMapOld.get( projectProfileItem.Id ).Project_Team__c;
            if( !projectTeamUpdatedMap.containsKey( oldProjectTeamId ) ) {
                projectTeamUpdatedMap.put( oldProjectTeamId,
                                           new Project_Team__c( Id = oldProjectTeamId,
                                                                Expected_Duration__c = projectProfileMapOld.get( projectProfileItem.Id ).Project_Team_Duration__c ) );
            }
        }

        for ( Task_Item__c taskItemItem : [ SELECT Id, Expected_Duration__c, Project_Profile__c, Actual_End_Date__c
                                            FROM Task_Item__c
                                            WHERE Project_Profile__c IN : projectProfileListNew AND
                                                Actual_End_Date__c = null AND
                                                RecordType.Name != : TaskManagementServices.MILESTONE_RECORDTYPE_NAME ] ) {
            Integer durationValue = projectProfileWithTotalTaskItemDuration.get( taskItemItem.Project_Profile__c ) ;
            durationValue += DateUtils.getMinute( taskItemItem.Expected_Duration__c );
            projectProfileWithTotalTaskItemDuration.put( taskItemItem.Project_Profile__c, durationValue );
        }

        for ( Project_Profile__c projectProfileItem : projectProfileListNew ) {
            if ( projectProfileWithTotalTaskItemDuration.get( projectProfileItem.Id ) > 0 ) {
                Id oldProjectTeamId = projectProfileMapOld.get( projectProfileItem.Id ).Project_Team__c;

                projectTeamUpdatedMap.get( projectProfileItem.Project_Team__c ).Expected_Duration__c += projectProfileWithTotalTaskItemDuration.get( projectProfileItem.Id );
                projectTeamUpdatedMap.get( oldProjectTeamId ).Expected_Duration__c -= projectProfileWithTotalTaskItemDuration.get( projectProfileItem.Id );
            }
        }

        try{
            if ( !projectTeamUpdatedMap.isEmpty() ){
                update projectTeamUpdatedMap.values();
            }
        } catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                for (Project_Profile__c projectProfileItem : projectProfileListNew){
                    if(projectProfileItem.Project_Team__c == projectTeamUpdatedMap.values()[dmlEx.getDmlIndex(i)].Id || projectProfileMapOld.get(projectProfileItem.Id).Project_Team__c == projectTeamUpdatedMap.values()[dmlEx.getDmlIndex(i)].Id){
                        projectProfileItem.addError('Error updating Project Team: ' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static Project_Profile__c initProjectProfile( Proposal__c proposalItem ) {
        Project_Profile__c newProjProf = new Project_Profile__c();
        newProjProf.Project_Name__c = proposalItem.Project_Name__c;
        newProjProf.Send_Copy_To__c = proposalItem.Send_Copy_To__c;
        newProjProf.Municipal_Agency_ID__c = proposalItem.Municipal_Agency_ID__c;
        newProjProf.Primary_Company_Name__c = proposalItem.Primary_Company_Name__c;
        newProjProf.Primary_Company_Contact__c = proposalItem.Primary_Company_Contact__c;
        newProjProf.Billing_Company_Name__c = proposalItem.Billing_Company_Name__c;
        newProjProf.Billing_Company_Contact__c = proposalItem.Billing_Company_Contact__c;
        newProjProf.Accounting_Contact_Company__c = proposalItem.Accounting_Contact_Company__c;
        newProjProf.Accounting_Contact__c = proposalItem.Accounting_Contact__c;
        newProjProf.Account_Executive__c = proposalItem.Account_Executive__c;
        newProjProf.Partner__c = proposalItem.Partner__c;
        newProjProf.Building__c = proposalItem.Address__c;
        newProjProf.Region__c = proposalItem.Region__c;
        newProjProf.Floor_s__c = proposalItem.Floor_s__c;
        newProjProf.Fulfillment_Office__c = proposalItem.Fulfillment_Office__c;
        newProjProf.Expected_Construction_End_Date__c = proposalItem.Expected_Construction_End_Date__c;
        newProjProf.Expected_Construction_Start_Date__c = proposalItem.Expected_Construction_Start_Date__c;
        newProjProf.Billing_End_Date__c = proposalItem.Expected_Construction_End_Date__c;
        newProjProf.Expected_Occupancy_Date__c = proposalItem.Expected_Occupancy_Date__c;
        newProjProf.Expected_Construction_Cost__c = proposalItem.Expected_Construction_Cost__c;
        newProjProf.Deadlines__c = proposalItem.Deadlines__c;
        newProjProf.Costs__c = proposalItem.Costs__c;
        newProjProf.Drawings__c = proposalItem.Drawings__c;
        newProjProf.Total_Service_Amount__c = proposalItem.Total_Service_Amount__c;
        newProjProf.Cost__c = proposalItem.Cost__c;
        newProjProf.Client_Project__c = proposalItem.Client_Project__c;
        newProjProf.Description__c = proposalItem.Description__c;
        newProjProf.Proposal__c = proposalItem.Id;
        newProjProf.Salesperson__c = proposalItem.Salesperson__c;
        newProjProf.Proposal_Specialist__c = proposalItem.OwnerId;
        newProjProf.Project_State__c = PROJECT_STATE_NOT_STARTED;
        newProjProf.Mi3_MRC__c = proposalItem.Mi3_MRC__c;
        newProjProf.FREP__c = proposalItem.FREP__c; //MRS-6271
        if( proposalIdToMi3RecordTypeId.get( proposalItem.Id ) != null ) {
            newProjProf.RecordTypeId = proposalIdToMi3RecordTypeId.get( proposalItem.Id );
        }

        // Billing Preferences
        newProjProf.Billing_Method__c = proposalItem.Billing_Method__c;
        newProjProf.Delivery_Method__c = proposalItem.Delivery_Method__c;
        newProjProf.Frequency__c = proposalItem.Frequency__c;
        newProjProf.Billing_day__c = proposalItem.Billing_day__c;
        newProjProf.Quarterly_Month__c = proposalItem.Quarterly_Month__c;
        newProjProf.Interval__c = proposalItem.Interval__c;
        newProjProf.Invoice_Format__c = proposalItem.Invoice_Format__c;
        newProjProf.Separate_Reimbursables__c = proposalItem.Separate_Reimbursables__c;
        newProjProf.Separate_Phases__c = proposalItem.Separate_Phases__c;
        newProjProf.Special_Instructions_Long__c = proposalItem.Special_Instructions_Long__c;
        newProjProf.No_Document_Shredding__c = proposalItem.No_Document_Shredding__c;
        newProjProf.No_Met_Data_Scanning__c = proposalItem.No_Met_Data_Scanning__c;
        newProjProf.No_Messenger_Fedex__c = proposalItem.No_Messenger_Fedex__c;
        newProjProf.Floor_Counting__c = proposalItem.Floor_Counting__c;
        newProjProf.Building_AKA__c = proposalItem.Building_AKA__c;

        //MRS-6851
        if (ProposalServices.mapProposalWithNotesAndRosters.containsKey(proposalItem.Id)){
            UserServices.prepareUserRoleNameToUserId();
            for (Service_Item__c si : ProposalServices.mapProposalWithNotesAndRosters.get(proposalItem.Id).Service_Items__r){
                if (si.Role_Assignment__c != null && !si.Is_Alternative__c){ //MRS 7160
                    if ( (si.Role_Assignment__c == UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER ||
                          si.Role_Assignment__c == UserServices.ROLE_C_OF_O_DEPARTMENT_COORDINATOR ) &&
                          UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c) ){

                        newProjProf.C_of_O_Coordinator__c = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );

                    } else if( (si.Role_Assignment__c == UserServices.ROLE_CODE_ZONING_ANALYST ||
                                si.Role_Assignment__c == UserServices.ROLE_CODE_ZONING_DEPARTMENT_REVIEWER ||
                                si.Role_Assignment__c.contains(UserServices.ROLE_CZ_MANAGER) ) &&
                                UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c) ){

                        newProjProf.C_Z_Analyst__c = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c );

                    } else if( (si.Role_Assignment__c == UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER ||
                                si.Role_Assignment__c == UserServices.ROLE_SIPS_DEPARTMENT_COORDINATOR) &&
                                UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c) ){

                        newProjProf.SIPS_Coordinator__c = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c);

                    } else if( (si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_MANAGER ||
                                si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_REVIEWER ||
                                si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_COORDINATOR) &&
                                UserServices.userRoleNameToUserId.containsKey( si.Service_Template__r.Role_Assignment__c) ){

                        newProjProf.FDNY_Coordinator__c = UserServices.userRoleNameToUserId.get( si.Service_Template__r.Role_Assignment__c);
                    }
                }
            }
        }

        if( ProposalServices.proposalIdToAllOSProposalFlag.containsKey( proposalItem.Id ) &&
            ProposalServices.proposalIdToAllOSProposalFlag.get( proposalItem.Id ) ) { // KDI 11/12/13
            newProjProf.OwnerId = UserServices.getOwnerIdForAllOSProjectProfile( proposalItem );
            //newProjProf.Project_Manager__c = UserServices.getOwnerIdForAllOSProjectProfile( proposalItem );
        } else if ( proposalItem.Project_Team__c != null ) {
            Project_Team__c itemProjectTeam = projectTeamIdToProjectTeam.get( proposalItem.Project_Team__c );
            newProjProf.OwnerId = itemProjectTeam.Project_Manager__c ;
            newProjProf.Project_Manager__c = itemProjectTeam.Project_Manager__c;
            newProjProf.Project_Member__c = itemProjectTeam.Project_Member__c;
            //newProjProf.FREP__c = itemProjectTeam.FREP__c; //MRS-6271
            newProjProf.Production_Manager__c = itemProjectTeam.Production_Manager__c;
            newProjProf.Project_Team__c = proposalItem.Project_Team__c;
        } else{
            newProjProf.OwnerId = proposalItem.OwnerId;//for TaskItemsServices populating OwnerId Milestones if two previous conditions false
        }
        if( newProjProf.OwnerId == null) newProjProf.OwnerId = UserInfo.getUserId();
        return newProjProf;
    }

    public static void sendReportProject(List<Billing_Line_Item__c> billingLineItemList) {
        set<Id> bliIdSet = new set<Id>();
        for(Billing_Line_Item__c bli : billingLineItemList) {
            bliIdSet.add(bli.Id);
        }
        List<Billing_Line_Item__c> bLIList = [SELECT Name, Project_Profile__c, Project_Profile__r.Name, Unit_Price__c, Quantity__c, Amount__c, Id,
                                                               Service_Item__c, Service_Item__r.Service_Name_Full__c, Milestone_Date__c, Project_Profile__r.Project_Expected_End_Date__c
                                                         FROM Billing_Line_Item__c
                                                         WHERE Id IN : bliIdSet AND Project_Profile__r.Project_State__c != : PROJECT_STATE_COMPLETE AND Project_Profile__r.Project_State__c != : PROJECT_STATE_CLOSED];

        Map<Id, List<Billing_Line_Item__c>> projectIdByBLI = new Map<Id, List<Billing_Line_Item__c> >();
        for(Billing_Line_Item__c bli : bLIList) {
            if( !projectIdByBLI.containsKey( bli.Project_Profile__c ) ) {
               projectIdByBLI.put(bli.Project_Profile__c, new List<Billing_Line_Item__c>() );
            }
            projectIdByBLI.get( bli.Project_Profile__c ).add( bli );
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailBody = emailBodyByProjectReport(projectIdByBLI);

        if(String.isNotEmpty( emailBody ) ) {
            List<EmailTemplate> eTemplate = [Select id, name, HtmlValue, subject, body From EmailTemplate Where Name = 'Projects due for billing today' Limit 1];
            List<User> userList = [SELECT Id, Email, ProfileId
                                   FROM User
                                   WHERE (Profile.Name = : UserServices.PROFILE_STAFF_ACCOUNTANT OR Profile.Name = : UserServices.PROFILE_STAFF_ACCOUNTANT_QA) AND Email != ''];

            List<String> userEmails = new List<String>();
            for( User u : userList ) {
                userEmails.add(u.Email);
            }

            if( !userEmails.IsEmpty() && !eTemplate.isEmpty() ) {
                String mailBodyHTML = eTemplate[0].HtmlValue;
                mail.setToAddresses( userEmails );
                mail.setSubject( 'Projects due for billing today' );
                mailBodyHTML = mailBodyHTML.replace('<![CDATA[', '');
                mailBodyHTML = mailBodyHTML.replace(']]>', '');
                mail.setHtmlBody( mailBodyHTML.replace('{!list}', emailBody) );
                Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
            }
        }
    }

    public static String emailBodyByProjectReport(Map<Id, List<Billing_Line_Item__c>> projectIdByBLI) {
        String emailBody = '';
        String body = '';
        system.debug('projectIdByBLI: ' + projectIdByBLI);
        for( Id projectId : projectIdByBLI.keySet() ) {
            if( projectIdByBLI.containsKey(projectId) ) {
                for( Billing_Line_Item__c bli : projectIdByBLI.get(projectId) ) {
                    body += '<tr>';
                    body += '<td style="border: 1px solid;">'+bli.Project_Profile__r.Name+'</td>';
                    body += '<td style="border: 1px solid;">'+bli.Name+'</td>';
                    body += '</tr>';
                }
            }
        }
        if( !String.isEmpty(body) ) {
            emailBody += '<table style="border: 1px solid;font-size: 13px;font-weight: normal;border-collapse: collapse;">';
            emailBody += '    <thead>';
            emailBody += '        <tr>';
            emailBody += '            <th style="border: 1px solid;background-color:#E0F0F9;">MRC Number</th>';
            emailBody += '            <th style="border: 1px solid;background-color:#E0F0F9;">Billing Line Item Name</th>';
            emailBody += '        </tr>';
            emailBody += '    </thead>';
            emailBody += '    <tbody>';
            emailBody += body;
            emailBody += '    </tbody>';
            emailBody += '</table>';
        }
        return emailBody;
    }

    public static Map<Id, Project_Profile__c> filterProjectsWithChangedInvoiceFormat( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        Map<Id, Project_Profile__c> filteredProjects = new Map<Id, Project_Profile__c>();
        for( Project_Profile__c project : projectProfileListNew ) {
            if( project.Billing_Method__c == projectProfileMapOld.get( project.Id ).Billing_Method__c ) {
                if( project.Invoice_Format__c != projectProfileMapOld.get( project.Id ).Invoice_Format__c ) {
                    filteredProjects.put( project.Id, project );
                }
            }
        }
        return filteredProjects;
    }

    public static Map<Id, Project_Profile__c> filterProjectsWithChangedSendCopyTo( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        Map<Id, Project_Profile__c> filteredProjects = new Map<Id, Project_Profile__c>();
        for( Project_Profile__c project : projectProfileListNew ) {
            if( project.Billing_Method__c == projectProfileMapOld.get( project.Id ).Billing_Method__c ) {
                if( project.Send_Copy_To__c != projectProfileMapOld.get( project.Id ).Send_Copy_To__c ) {
                    filteredProjects.put( project.Id, project );
                }
            }
        }
        return filteredProjects;
    }

    private static Map<Id, Project_Profile__c> projectsFromInstallmentToMilestone = new Map<Id, Project_Profile__c>();
    private static Map<Id, Project_Profile__c> projectsFromMilestoneToInstallment = new Map<Id, Project_Profile__c>();
    private static Map<Id, Project_Profile__c> projectsFromPersentageToMilestone = new Map<Id, Project_Profile__c>();
    private static Map<Id, Project_Profile__c> projectsFromMilestoneToPersentage = new Map<Id, Project_Profile__c>();
    private static Map<Id, Project_Profile__c> projectsFromInstallmentToPersentage = new Map<Id, Project_Profile__c>();
    private static Map<Id, Project_Profile__c> projectsFromPersentageToInstallment = new Map<Id, Project_Profile__c>();

    public static Map<Id, Project_Profile__c> filterProjectsWithChangedBillingMethod (List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld){
        Map<Id, Project_Profile__c> filteredProjects = new Map<Id, Project_Profile__c>();

        String profileName = UserServices.getProfile().Name;
        Boolean allowToChangeBillingMethod = profileName == UserServices.SYSTEM_ADMINISTRATOR || profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS; //MRS-6507

        for( Project_Profile__c project : projectProfileListNew ){
            if( project.Billing_Method__c != projectProfileMapOld.get(project.Id).Billing_Method__c ){
                if( !allowToChangeBillingMethod ){
                    project.addError('Only System Administrator should be responsible to change Billing Method on the Project level');
                    continue;
                }
                if( project.Allow_To_Change_Billing_Method__c ){
                    Project_Profile__c oldProject = projectProfileMapOld.get(project.Id);
                    Boolean isProjectFromInstallment = oldProject.Billing_Method__c == BILLINGMETHODINSTALLMENT || (oldProject.Billing_Method__c == BILLINGMETHODINSTALLMENT && oldProject.Interval__c);
                    Boolean isProjectToInstallment = project.Billing_Method__c == BILLINGMETHODINSTALLMENT || (project.Billing_Method__c == BILLINGMETHODINSTALLMENT && project.Interval__c);
                    Boolean isProjectFromPersentage = oldProject.Billing_Method__c == BILLINGMETHODPERCENTAGE && !oldProject.Interval__c;
                    Boolean isProjectToPersentage = project.Billing_Method__c == BILLINGMETHODPERCENTAGE && !project.Interval__c;


                    if( project.Billing_Method__c == BILLINGMETHODMILESTONE && isProjectFromInstallment ){ /* milestone -> installment */
                        projectsFromInstallmentToMilestone.put( project.Id, project );
                    }else if( isProjectToInstallment && projectProfileMapOld.get(project.Id).Billing_Method__c == BILLINGMETHODMILESTONE ){ /* installment -> milestone */
                        projectsFromMilestoneToInstallment.put( project.Id, project );
                    }else if( isProjectFromPersentage && projectProfileMapOld.get(project.Id).Billing_Method__c == BILLINGMETHODMILESTONE ){ /* percentage -> milestone */
                        projectsFromPersentageToMilestone.put( project.Id, project );
                    }else if( project.Billing_Method__c == BILLINGMETHODMILESTONE && isProjectToPersentage ){ /* milestone -> percentage */
                        projectsFromMilestoneToPersentage.put( project.Id, project );
                    }else if( isProjectFromInstallment && isProjectToPersentage ){ /* installment -> percentage */
                        projectsFromInstallmentToPersentage.put( project.Id, project );
                    }else if( isProjectToPersentage && isProjectFromInstallment ){ /* percentage -> installment */
                        projectsFromPersentageToInstallment.put( project.Id, project );
                    }

                    filteredProjects.put( project.Id, project );
                }else{
                    project.addError('Change of Billing Method is not approved');
                }
            }
        }
        return filteredProjects;
    }

    public static void prepareProjectsToChangeBillingMethod ( Map<Id, Project_Profile__c> projectsMap ){
        prepareTransitionFromInstallmentToMilestone();
        prepareTransitionFromMilestoneToInstallment();
        prepareTransitionFromPercentageToMilestone();
        prepareTransitionFromMilestoneToPercentage();
        prepareTransitionFromInstallmentToPercentage();
        prepareTransitionFromPercentageToInstallment();
    }

    @TestVisible /* installment -> milestone */
    private static void prepareTransitionFromInstallmentToMilestone(){
        if( projectsFromInstallmentToMilestone.isEmpty() ) return;
        //Remove Billing Dates
        removeBillingDatesForProjects( projectsFromInstallmentToMilestone );

        createBLIForMilestoneProjects( projectsFromInstallmentToMilestone );
        //Map<Id, Billing_Line_Item__c> bliToCreateInvoices = BillingLineItemServices.getNotSupercededBLIByProjectsId( projectsFromInstallmentToMilestone.keySet() );
        createProformaInvoicesForBillingLineItems( BillingLineItemServices.billingLineItemsToCreateInvoicesInReduBilling );
    }

    @TestVisible /* milestone -> installment */
    private static void prepareTransitionFromMilestoneToInstallment(){
        if( projectsFromMilestoneToInstallment.isEmpty() ) return;
        BillingDateServices.createBillingDateForProjects( projectsFromMilestoneToInstallment );

        List<Billing_Line_Item__c> billingLineItems = createBLIForInstallmentProjects( projectsFromMilestoneToInstallment );
        createProformaInvoicesForBillingLineItems( billingLineItems );
    }

    @TestVisible /* percentage -> milestone */
    private static void prepareTransitionFromPercentageToMilestone(){
        if( projectsFromPersentageToMilestone.isEmpty() ) return;
        projectsFromInstallmentToMilestone = projectsFromPersentageToMilestone;
        prepareTransitionFromInstallmentToMilestone();
    }

    @TestVisible /* milestone -> percentage */
    private static void prepareTransitionFromMilestoneToPercentage(){
        if( projectsFromMilestoneToPersentage.isEmpty() ) return;
        projectsFromMilestoneToInstallment = projectsFromMilestoneToPersentage;
        prepareTransitionFromMilestoneToInstallment();
    }

    @TestVisible /* installment -> percentage */
    private static void prepareTransitionFromInstallmentToPercentage(){
        if( projectsFromInstallmentToPersentage.isEmpty() ) return;
        //Remove Billing Dates
        removeBillingDatesForProjects( projectsFromInstallmentToPersentage );

        projectsFromMilestoneToInstallment = projectsFromInstallmentToPersentage;
        prepareTransitionFromMilestoneToInstallment();
    }

    @TestVisible /* percentage -> installment */
    private static void prepareTransitionFromPercentageToInstallment(){
        if( projectsFromPersentageToInstallment.isEmpty() ) return;
        //Remove Billing Dates
        removeBillingDatesForProjects( projectsFromPersentageToInstallment );

        projectsFromMilestoneToInstallment = projectsFromPersentageToInstallment;
        prepareTransitionFromMilestoneToInstallment();
    }

    @TestVisible
    private static void createProformaInvoicesForBillingLineItems( List<Billing_Line_Item__c> billingLineItems ){
        twiceUpdatePreventor = true;
        ProformaInvoiceServices.processProformaInvoices( billingLineItems, false, false, false );//MRS-7105
    }

    @TestVisible
    private static void createBLIForMilestoneProjects( Map<Id, Project_Profile__c> projectsMap ){
        Map<Id, Task_Item__c> taskItemsMap = new Map<Id, Task_Item__c>( [SELECT Service_Item__c, Project_Profile__c, Pre_billed__c, Phase__c, No_Met_Data_Scanning__c, Name, Is_Locked__c, Id, Expiration_Date__c,
                                                                        CreatedDate, Billing_Trigger__c, Billing_Percentage__c, Billing_Line_Item__c, Approved_Date__c, Actual_Start_Date__c, Actual_End_Date__c,
                                                                        Actual_Duration__c, Activity_Date__c, RecordTypeId, Hours_Remaining__c, Hours_Reported_For__c, Is_Change_Order__c
                                                                        FROM Task_Item__c
                                                                        WHERE Project_Profile__c IN: projectsMap.keySet()
                                                                        AND Pre_billed__c = false
                                                                        AND Billing_Trigger__c = true ]);
        if( !taskItemsMap.isEmpty() ){
            TaskItemServices.createBillingLineItemsFromTaskItems( taskItemsMap, projectsMap );
        }
    }

    @TestVisible
    private static Boolean removeBillingDatesForProjects( Map<Id, Project_Profile__c> projectsMap ){
        Boolean status = true;
        List <Billing_Date__c> billingDates = new List<Billing_Date__c>([SELECT Id, Project_Profile__c FROM Billing_Date__c WHERE Project_Profile__c IN: projectsMap.keySet()]);
        try{
            delete billingDates;
        } catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                projectsMap.get( billingDates[dmlEx.getDmlIndex(i)].Project_Profile__c ).addError('Error deleting Billing Dates: ' + dmlEx.getMessage());
            }
            status = false;
        }
        return status;
    }

    @TestVisible
    private static List<Billing_Line_Item__c> createBLIForInstallmentProjects(  Map<Id, Project_Profile__c> projectsMap ){
        List<Billing_Date__c> billingDateList = new List<Billing_Date__c>();
        for( Billing_Date__c billingDateItem: [Select Id, Billed__c, Project_Profile__c, Percentage__c, Step_Number__c
                                                From Billing_Date__c
                                                Where Project_Profile__c IN: projectsMap.keySet()
                                                AND Billed__c = false] ){
            billingDateItem.Billed__c = true;
            billingDateItem.Processing_Day__c = Date.today();
            billingDateItem.Percentage__c = 100;
            billingDateList.add( billingDateItem );
        }
        return TaskItemServices.createBilingLineItemsForBillingDatesBatch( billingDateList, Date.today(), projectsMap );
    }

    public static Map<Id, Project_Profile__c> filterProjectsToCreateBillingDates(List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap) {
        Map<Id, Project_Profile__c> filteredProjects = new Map<Id, Project_Profile__c>();

        for (Project_Profile__c project : newProjectList) { //MRS 7282
            if (    ( BILLINGMETHODINSTALLMENT == project.Billing_Method__c || ( BILLINGMETHODPERCENTAGE ==  project.Billing_Method__c && project.Interval__c ) )
                 && ( project.Project_Start_Date__c != oldProjectMap.get(project.Id).Project_Start_Date__c ||
                    project.Billing_End_Date__c != oldProjectMap.get(project.Id).Billing_End_Date__c ||
                      /*(BILLINGMETHODINSTALLMENT == project.Billing_Method__c && project.Billing_day__c != oldProjectMap.get(project.Id).Billing_day__c) ||
                      (BILLINGMETHODPERCENTAGE ==  project.Billing_Method__c && project.Interval__c && project.Billing_day__c != oldProjectMap.get(project.Id).Billing_day__c
                        && (DateUtils.WEEK_DAY_NUMBER_MAP.keySet().contains(project.Billing_day__c) || DateUtils.WEEK_DAY_NUMBER_MAP.keySet().contains(oldProjectMap.get(project.Id).Billing_day__c))) || */
                    project.Frequency__c != oldProjectMap.get(project.Id).Frequency__c ||
                      project.Quarterly_Month__c != oldProjectMap.get(project.Id).Quarterly_Month__c )
                 &&  !BillingDateServices.isChangedNumberInterval ) {
system.debug('!!! project.id = ' + project.id);
             BillingDateServices.isChangedNumberInterval = true;
                     filteredProjects.put(project.id, project);
            }
        }
        return filteredProjects;
    }

    public static Map<Id, Project_Profile__c> filterProjectsPercentageToChangeDateOfBillingDates(List<Project_Profile__c> newList, Map<Id, Project_Profile__c> oldMap) { //MRS 7282
        Map<Id, Project_Profile__c> filteredProjects = new Map<Id, Project_Profile__c>();
        for (Project_Profile__c project : newList) {
            if( BILLINGMETHODINSTALLMENT == project.Billing_Method__c || ( BILLINGMETHODPERCENTAGE ==  project.Billing_Method__c && project.Interval__c )
                 && project.Billing_day__c != oldMap.get(project.Id).Billing_day__c
                 &&  !BillingDateServices.isChangedNumberInterval
                 /*&& !DateUtils.WEEK_DAY_NUMBER_MAP.keySet().contains(project.Billing_day__c) && !DateUtils.WEEK_DAY_NUMBER_MAP.keySet().contains(oldMap.get(project.Id).Billing_day__c)*/) {
                filteredProjects.put(project.id, project);
            }
        }
        system.debug('!!! filteredProjects = ' + filteredProjects);
        BillingDateServices.isChangedNumberInterval = true;
        return filteredProjects;
    }

    public static Map<Id, Id> prepareMi3ProposalsMap( List<Proposal__c> proposals ) {
        Map<Id, Id> proposalIdToRecordtypeId = new Map<Id, Id>();
        for( Proposal__c proposal : proposals ) {
            if( !String.isBlank( proposal.Mi3_MRC__c ) ) {
                proposalIdToRecordtypeId.put( proposal.Id, null );
            }
        }
        if( !proposalIdToRecordtypeId.keySet().isEmpty() ) {
            List<Id> mi3RecordType = new List<Id>( RecordTypeServices.getRecordTypesForObjectByDeveloperNames( PROJECT_SOBJECT_NAME, new Set<String>{ PROJECT_MI3_DEVELOPERNAME } ).keySet() );
            if( !mi3RecordType.isEmpty() ) {
                for( Id proposalId : proposalIdToRecordtypeId.keySet() ) {
                    proposalIdToRecordtypeId.put( proposalId, mi3RecordType[0] );
                }
            }
        }
        return proposalIdToRecordtypeId;
    }

    public static Map<Id, Map<String, Decimal>> getProjectIdToAmountTypeToAmount( Set<Id> projectProfileIds ) {
        return getProjectIdToAmountTypeToAmount( projectProfileIds, false );
    }

    //this method calculates a set of values that is needed to calculate amounts for BLIs creation
    public static Map<Id, Map<String, Decimal>> getProjectIdToAmountTypeToAmount( Set<Id> projectProfileIds, Boolean isCurrentlyPrebilling ) {
        Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount = new Map<Id, Map<String, Decimal>>();
        for( Id projectProfileId : projectProfileIds ) {
            projectIdToAmountTypeToAmount.put( projectProfileId, new Map<String, Decimal>{ BillingLineItemServices.UNBILLED_PERCENTAGE => 100.00,
                                                                                           BillingLineItemServices.TOTAL_AMOUNT => 0.00,
                                                                                           BillingLineItemServices.BILLED_AMOUNT => 0.00,
                                                                                           BillingLineItemServices.BILLED_TAX1_AMOUNT => 0.00,
                                                                                           BillingLineItemServices.BILLED_TAX2_AMOUNT => 0.00,
                                                                                           BillingLineItemServices.TOTAL_TAX1_AMOUNT => 0.00,
                                                                                           BillingLineItemServices.TOTAL_TAX2_AMOUNT => 0.00 } );
        }
        for( Project_Profile__c project : [ SELECT Billing_Method__c, Interval__c, Total_Service_Amount__c, Pre_billed__c, Discounted_Total_Service_Amount__c,
                                                   ( SELECT Task_Item__r.Billing_Percentage__c, Amount__c, Sales_Tax_Amount_1__c,
                                                            Sales_Tax_Amount_2__c, Billing_Date__c, Billing_Date__r.Percentage__c,
                                                            Billing_Date__r.Billed__c
                                                     FROM Billing_Line_Items__r
                                                     WHERE IsReimbursable__c = false
                                                       AND Department_Based__c = false
                                                       AND Active_Billing_Line_Item__c = true
                                                       AND isHourlyConsulting__c = false
                                                       AND Is_Check_Processing_Fee__c = false ),
                                                   ( SELECT Sales_Tax_Amount_1__c, Sales_Tax_Amount_2__c
                                                     FROM Service_Items__r
                                                     WHERE Is_Alternative__c = false
                                                       AND ( ( Is_Amendmend_Deleted__c = false ) OR
                                                             ( Is_Amendmend_Deleted__c = true AND Change_Order__r.Status__c != : ChangeOrderServices.STATUS_APPROVED ) ) ),
                                                   ( SELECT Percentage__c
                                                     FROM Billing_Dates__r )
                                            FROM Project_Profile__c
                                            WHERE Id IN : projectProfileIds ] ) {
            Map<String, Decimal> amountTypeToAmount = projectIdToAmountTypeToAmount.get( project.Id );
            amountTypeToAmount.put( BillingLineItemServices.TOTAL_AMOUNT, project.Discounted_Total_Service_Amount__c );

            if( project.Pre_billed__c && !isCurrentlyPrebilling ) {
                amountTypeToAmount.put( BillingLineItemServices.UNBILLED_PERCENTAGE, 0.00 );
            } else if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c ) {
                //KDI heard that for percentage method the total percentage can be more than 100? here is the part for percentage and billing dates...
                //it won't hurt the existing projects where there are dates with total of 100, but it would accomodate new ones with more than 100
                Decimal totalPercentage = 0.00;
                for( Billing_Date__c bd : project.Billing_Dates__r ) {
                    totalPercentage += bd.Percentage__c;
                }
                amountTypeToAmount.put( BillingLineItemServices.UNBILLED_PERCENTAGE, totalPercentage );
            }

            for( Billing_Line_Item__c bli : project.Billing_Line_Items__r ) {
                //Percentage Without Interval
                if( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !project.Interval__c ) {
                    if( bli.Task_Item__r.Billing_Percentage__c != null && bli.Task_Item__r.Billing_Percentage__c > 0 && ( !project.Pre_billed__c || isCurrentlyPrebilling ) ) {
                        amountTypeToAmount.put( BillingLineItemServices.UNBILLED_PERCENTAGE, amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) - bli.Task_Item__r.Billing_Percentage__c );
                    }
                    if( bli.Amount__c != null ) {
                        amountTypeToAmount.put( BillingLineItemServices.BILLED_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) + bli.Amount__c.setScale(2) );
                    }
                    if( bli.Sales_Tax_Amount_1__c != null ) {
                        amountTypeToAmount.put( BillingLineItemServices.BILLED_TAX1_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) + bli.Sales_Tax_Amount_1__c );
                    }
                    if( bli.Sales_Tax_Amount_2__c != null ) {
                        amountTypeToAmount.put( BillingLineItemServices.BILLED_TAX2_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) + bli.Sales_Tax_Amount_2__c );
                    }
                //Percentage With Interval and Installment
                } else if( ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && project.Interval__c ) ||
                           ( project.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) ) {
                    if( bli.Billing_Date__r.Billed__c || bli.Billing_Date__c == null ) {
                        if( bli.Billing_Date__r.Percentage__c != null && bli.Billing_Date__r.Percentage__c > 0 && ( !project.Pre_billed__c || isCurrentlyPrebilling ) ) {
                            amountTypeToAmount.put( BillingLineItemServices.UNBILLED_PERCENTAGE, amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) - bli.Billing_Date__r.Percentage__c );
                        }
                        if( bli.Amount__c != null ) {
                            amountTypeToAmount.put( BillingLineItemServices.BILLED_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) + bli.Amount__c.setScale(2) );
                        }
                        if( bli.Sales_Tax_Amount_1__c != null ) {
                            amountTypeToAmount.put( BillingLineItemServices.BILLED_TAX1_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) + bli.Sales_Tax_Amount_1__c );
                        }
                        if( bli.Sales_Tax_Amount_2__c != null ) {
                            amountTypeToAmount.put( BillingLineItemServices.BILLED_TAX2_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) + bli.Sales_Tax_Amount_2__c );
                        }
                    }
                }
            }
            //Calculate total tax amount for all service items in Project
            for( Service_Item__c si : project.Service_Items__r ) {
                if( si.Sales_Tax_Amount_1__c != null ) {
                    amountTypeToAmount.put( BillingLineItemServices.TOTAL_TAX1_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) + si.Sales_Tax_Amount_1__c );
                }
                if( si.Sales_Tax_Amount_2__c != null ) {
                    amountTypeToAmount.put( BillingLineItemServices.TOTAL_TAX2_AMOUNT, amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) + si.Sales_Tax_Amount_2__c );
                }
            }
        }
        return projectIdToAmountTypeToAmount;
    }

    public static List<Project_Profile__c> blockFutureBillingDatesForProjects( Set<Id> projectIds ) {
        List<Project_Profile__c> projectProfilesToBlockBillingDates = new List<Project_Profile__c>();
        for( Id projectId : projectIds ) {
            projectProfilesToBlockBillingDates.add( new Project_Profile__c( Id = projectId, Billing_Dates_Blocked__c = true ) );
        }
        return projectProfilesToBlockBillingDates;
    }

    public static Map <Id, Boolean> getProjectRosterStatus (Id projectProfileId){
        Map<Id, Boolean> projectStatusesResultMap = new Map<Id, Boolean>();
        Map <Id, Project_Roster__c> getProjectRosterMap = getProjectRosterStatusOnlyValid (projectProfileId);
        for (Id idItem : getProjectRosterMap.keySet()){
            if (getProjectRosterMap.get(idItem) != null ){
                projectStatusesResultMap.put(idItem, true);
            } else {
                projectStatusesResultMap.put(idItem, false);
            }
        }
        return projectStatusesResultMap;
    }

    public static Map <Id, Project_Roster__c> getProjectRosterStatusOnlyValid (Id projectProfileId){
        List<Project_Profile__c> projectProfileList = [SELECT Id, Account_Executive__c, FREP__c, Partner__c, Production_Manager__c, Project_Member__c, Primary_Company_Contact__c,
                                                            Billing_Company_Contact__c, Project_Manager__c, Proposal_Specialist__c, Resource__c, Salesperson__c, OwnerId,
                                                            Proposal__r.OwnerId, Accounting_Contact__c,
                                                            (Select Id, OwnerId
                                                             From Service_Items__r
                                                             Where Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                            (Select Id, OwnerId
                                                             From Task_Items__r
                                                             Where RecordType.Name !=: TaskManagementServices.MILESTONE_RECORDTYPE_NAME And
                                                             Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                            (Select Id, Active__c, User__c, Contact__c, Role__c, LastModifiedDate, CreatedDate, Is_Manually_Added_Roster__c, Is_Manually_Activated__c, Is_Manually_Deactivated__c
                                                             From Project_Rosters__r Order By CreatedDate Desc)
                                                      FROM Project_Profile__c
                                                            WHERE Id = : projectProfileId];

        return !projectProfileList.isEmpty() ? getProjectRosterStatusOnlyValid(projectProfileList[0], true, true) : new Map<Id, Project_Roster__c>();
    }


    public static Map <Id, Project_Roster__c> getProjectRosterStatusOnlyValid (Project_Profile__c projectProfileItem){

        return getProjectRosterStatusOnlyValid(projectProfileItem, true, true);
    }

    public static Map <Id, Project_Roster__c> getProjectRosterStatusOnlyValid (Project_Profile__c projectProfileItem,
                                                                               Boolean doGetRelatedServices,
                                                                               Boolean doGetRelatedTasks){
        Map<Id, Project_Roster__c> projectStatusesResultMap = new Map<Id, Project_Roster__c>();
        if (projectProfileItem == null || projectProfileItem.Id == null){ return projectStatusesResultMap; }

        Map<Id, String> userWithRoleMap = UserServices.getUserIdToRoleName();

        Map<Id, Set<String>> projectRosterUserRole = new Map<Id, Set<String>>();
        Map<String, Set<Id>> projectRosterRoleUser = new Map<String, Set<Id>>();
        Map<String, Map<Id, Datetime>> projectRosterMap = new Map<String, Map<Id, Datetime>>();

        for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
            Boolean bool = projectRosterItem.Contact__c != null && ( projectRosterItem.Is_Manually_Added_Roster__c ||
                           ( ( projectRosterItem.Role__c != ProjectRosterServices.PRIMARY_CLIENT_CONTACT &&
                               projectRosterItem.Role__c != ProjectRosterServices.BILLING_CLIENT_CONTACT &&
                               projectRosterItem.Role__c != ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT ) ||
                              ( projectRosterItem.Role__c == ProjectRosterServices.PRIMARY_CLIENT_CONTACT && projectRosterItem.Contact__c == projectProfileItem.Primary_Company_Contact__c ) ||
                              ( projectRosterItem.Role__c == ProjectRosterServices.BILLING_CLIENT_CONTACT && projectRosterItem.Contact__c == projectProfileItem.Billing_Company_Contact__c ) ||
                              ( projectRosterItem.Role__c == ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT && projectRosterItem.Contact__c == projectProfileItem.Accounting_Contact__c ) ) );
            if (bool){
                projectStatusesResultMap.put(projectRosterItem.Id, projectRosterItem );
            } else {
                projectStatusesResultMap.put(projectRosterItem.Id, null );
            }

            if ( !projectRosterMap.containsKey(projectRosterItem.Role__c) ){
                projectRosterMap.put(projectRosterItem.Role__c, new Map<Id, Datetime>());
            }
            if ( projectRosterItem.User__c != null ){
                if ( !projectRosterMap.get(projectRosterItem.Role__c).containsKey(projectRosterItem.User__c) ){
                    projectRosterMap.get(projectRosterItem.Role__c).put(projectRosterItem.User__c, projectRosterItem.CreatedDate);
                }
                if ( projectRosterMap.get(projectRosterItem.Role__c).get(projectRosterItem.User__c) < projectRosterItem.CreatedDate ){
                    projectRosterMap.get(projectRosterItem.Role__c).put(projectRosterItem.User__c, projectRosterItem.CreatedDate);
                }
            } else {
                if ( !projectRosterMap.get(projectRosterItem.Role__c).containsKey(projectRosterItem.Contact__c) ){
                    projectRosterMap.get(projectRosterItem.Role__c).put(projectRosterItem.Contact__c, projectRosterItem.CreatedDate);
                }
                if ( projectRosterMap.get(projectRosterItem.Role__c).get(projectRosterItem.Contact__c) < projectRosterItem.CreatedDate ){
                    projectRosterMap.get(projectRosterItem.Role__c).put(projectRosterItem.Contact__c, projectRosterItem.CreatedDate);
                }
            }
        }
        if (doGetRelatedServices){
            for (Service_Item__c serviceItem : projectProfileItem.Service_Items__r){
                String ownerRole = userWithRoleMap.get(serviceItem.OwnerId);
                Id ownerIdItem = serviceItem.OwnerId;
                if (!projectRosterUserRole.containsKey(ownerIdItem)){
                    projectRosterUserRole.put(ownerIdItem, new Set<String>{ownerRole});
                } else {
                    projectRosterUserRole.get(ownerIdItem).add(ownerRole);
                }
                if ( !projectRosterRoleUser.containsKey(ownerRole) ){
                    projectRosterRoleUser.put(ownerRole, new Set<Id>{ownerIdItem});
                } else {
                    projectRosterRoleUser.get(ownerRole).add(ownerIdItem);
                }
            }
        }
        if (doGetRelatedTasks){
            for (Task_Item__c taskItem : projectProfileItem.Task_Items__r){
                String ownerRole = userWithRoleMap.get(taskItem.OwnerId);
                Id ownerIdItem = taskItem.OwnerId;
                if (!projectRosterUserRole.containsKey(ownerIdItem)){
                    projectRosterUserRole.put(ownerIdItem, new Set<String>{ownerRole});
                } else {
                    projectRosterUserRole.get(ownerIdItem).add(ownerRole);
                }
                if ( !projectRosterRoleUser.containsKey(ownerRole) ){
                    projectRosterRoleUser.put(ownerRole, new Set<Id>{ownerIdItem});
                } else {
                    projectRosterRoleUser.get(ownerRole).add(ownerIdItem);
                }
            }
        }

        Map<String, Set<Id>> checkForUniqueRecordMap = new Map<String, Set<Id>>();

        for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
            if (projectRosterItem.User__c != null){
                if ( projectRosterMap.get(projectRosterItem.Role__c).get(projectRosterItem.User__c) > projectRosterItem.CreatedDate ){
                    continue;
                }
                if ( projectRosterItem.Is_Manually_Added_Roster__c ){
                    projectStatusesResultMap.put(projectRosterItem.Id, projectRosterItem);
                    continue;
                }
                if( (projectProfileItem.OwnerId == projectRosterItem.User__c && projectRosterItem.Role__c == ProjectRosterServices.PROJECT_OWNER_ROLE) ||
                    (projectProfileItem.Project_Manager__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_PROJECT_MANAGER_2) ||
                    (projectProfileItem.Project_Member__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_PROJECT_MANAGER_1) ||
                    (projectProfileItem.FREP__c == projectRosterItem.User__c && projectRosterItem.Role__c == ProjectRosterServices.FILING_REP) ||
                    (projectProfileItem.Production_Manager__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_PRODUCTION_MANAGER) ||
                    (projectProfileItem.Partner__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_PARTNER) ||
                    (projectProfileItem.Account_Executive__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_ACCOUNT_MANAGER) ||
                    (projectProfileItem.Proposal_Specialist__c == projectRosterItem.User__c && projectRosterItem.Role__c == UserServices.PROFILE_PROPOSAL_SPECIALIST) ||
                    (projectProfileItem.Salesperson__c == projectRosterItem.User__c && projectRosterItem.Role__c == ProjectRosterServices.SALESPERSON) ||
                    (projectProfileItem.Proposal__r.OwnerId == projectRosterItem.User__c && projectRosterItem.Role__c == ProjectRosterServices.PROPOSAL_CREATOR_ROLE) ){
                    projectStatusesResultMap.put(projectRosterItem.Id, projectRosterItem);
                    continue;
                }
                if ( projectRosterUserRole.containsKey(projectRosterItem.User__c) && projectRosterUserRole.get(projectRosterItem.User__c).contains(projectRosterItem.Role__c) &&
                    projectRosterRoleUser.containsKey(projectRosterItem.Role__c) && projectRosterRoleUser.get(projectRosterItem.Role__c).contains(projectRosterItem.User__c) ){
                    projectStatusesResultMap.put(projectRosterItem.Id, projectRosterItem);
                    continue;
                }
            }
        }

        //remove duplicates
        for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
            String rosterRoleValue = projectRosterItem.Role__c;
            Id rosterContactUserIdValue = projectRosterItem.User__c != null ? projectRosterItem.User__c : projectRosterItem.Contact__c;

            if ( !checkForUniqueRecordMap.containsKey(rosterRoleValue) ){
                checkForUniqueRecordMap.put(rosterRoleValue, new Set<Id>{rosterContactUserIdValue});
                continue;
            }
            if( !checkForUniqueRecordMap.get(rosterRoleValue).contains(rosterContactUserIdValue) ){
                checkForUniqueRecordMap.get(rosterRoleValue).add(rosterContactUserIdValue);
                continue;
            }
            projectStatusesResultMap.remove(projectRosterItem.Id);
        }

        //remove or add Manually Deactivated or Activater rosters
        for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
            if ( !projectRosterItem.Active__c && projectRosterItem.Is_Manually_Deactivated__c ){
                projectStatusesResultMap.put(projectRosterItem.Id, null);
            } else if ( projectRosterItem.Active__c && projectRosterItem.Is_Manually_Activated__c ){
                projectStatusesResultMap.put(projectRosterItem.Id, projectRosterItem);
            }
        }

        return projectStatusesResultMap;
    }

    public static Map<Id, List<Task_Item__c>> groupTaskItemsByProjectId(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return new Map<Id, List<Task_Item__c>>();

        }
        List<Task_Item__c> tasks = new List<Task_Item__c>([SELECT Service_Item__c, Successor_Milestone__c, Is_Locked__c, Billing_Trigger__c, Billing_Percentage__c, Project_Profile__c
                                                           FROM Task_Item__c
                                                           WHERE Project_Profile__c IN: projectIds AND
                                                               Billing_Trigger__c = true]);//MRS-6396

        Map<Id, List<Task_Item__c>> projectIdToTaskItems = new Map<Id, List<Task_Item__c>>();

        for (Task_Item__c item : tasks) {
            if (!projectIdToTaskItems.containsKey(item.Project_Profile__c)) {
                projectIdToTaskItems.put(item.Project_Profile__c, new List<Task_Item__c>());

            }
            projectIdToTaskItems.get(item.Project_Profile__c).add(item);

        }
        return projectIdToTaskItems;

    }

    public static Map<Id, List<Task_Item__c>> groupTaskItemsByProjectIdForBillingDate(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return new Map<Id, List<Task_Item__c>>();
        }

        Map<Id, List<Task_Item__c>> projectIdToTaskItems = new Map<Id, List<Task_Item__c>>();
        for (Id idItem : projectIds) {
            projectIdToTaskItems.put(idItem, new List<Task_Item__c>());
        }

        List<Task_Item__c> tasks = new List<Task_Item__c>([SELECT Service_Item__c, Successor_Milestone__c, Is_Locked__c, Billing_Trigger__c, Billing_Percentage__c, Project_Profile__c
                                                           FROM Task_Item__c
                                                           WHERE Project_Profile__c IN: projectIds AND
                                                                Billing_Trigger__c = true AND
                                                                Is_Locked__c = false AND
                                                                Billing_Percentage__c > 0]);

        for (Task_Item__c item : tasks) {
            projectIdToTaskItems.get(item.Project_Profile__c).add(item);
        }
        return projectIdToTaskItems;

    }

    //filtered Project with changed "Expected Construction Start Date" or "Client Project #" field values
    public static List<Project_Profile__c> filtereProjectWithChangedFieldsValues(List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld){
        List<Project_Profile__c> filteredProjectList = new List<Project_Profile__c>();
        for (Project_Profile__c projectProfileItem : projectProfileListNew){
            if ( (projectProfileItem.Expected_Construction_Start_Date__c != null && projectProfileItem.Expected_Construction_Start_Date__c != projectProfileMapOld.get(projectProfileItem.Id).Expected_Construction_Start_Date__c) ||
                 (projectProfileItem.Expected_Construction_End_Date__c != null && projectProfileItem.Expected_Construction_End_Date__c != projectProfileMapOld.get(projectProfileItem.Id).Expected_Construction_End_Date__c) ||
                 (projectProfileItem.Expected_Occupancy_Date__c != null && projectProfileItem.Expected_Occupancy_Date__c != projectProfileMapOld.get(projectProfileItem.Id).Expected_Occupancy_Date__c) ||
                 (projectProfileItem.Client_Project__c != projectProfileMapOld.get(projectProfileItem.Id).Client_Project__c) ){
                filteredProjectList.add(projectProfileItem);
            }
        }
        return filteredProjectList;
    }

    //check if current User can edit "Expected Construction Start Date" or "Client Project #" field values
    public static void checkIfCurrentUserCanEditFields (List<Project_Profile__c> projectProfileFilteredList, Map<Id, Project_Profile__c> projectProfileMapOld){
        if (projectProfileFilteredList.isEmpty()){ return; }

        Id currentUserId = userinfo.getuserid();
        User currentUserWithRoleProfile = [SELECT Id, Profile.Name, ProfileId, UserRoleId, UserRole.Name
                                           FROM User
                                           WHERE Id = : currentUserId];
        String currentUserProfileName = currentUserWithRoleProfile.Profile.Name;
        String currentUserRoleName = currentUserWithRoleProfile.UserRole.Name;

        if (currentUserProfileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) { return; }

        Map<Id, Project_Profile__c> projectWithRostersTaskServicesMap = getProjectWithRostersTaskServices (projectProfileFilteredList, currentUserId);

        for (Project_Profile__c projectProfileItem : projectProfileFilteredList){
            Boolean errorFound = false; //MRS 7469
            String errorString = '';
            if (projectProfileItem.Expected_Construction_Start_Date__c != projectProfileMapOld.get(projectProfileItem.Id).Expected_Construction_Start_Date__c ){
                errorString = 'You cannot update the "Expected Construction Start Date" field value';
                errorFound = true;
            } else if (projectProfileItem.Client_Project__c != projectProfileMapOld.get(projectProfileItem.Id).Client_Project__c && currentUserProfileName != UserServices.PROFILE_OPERATIONS_MANAGER){ //MRS 7469
                errorString = 'You cannot update the "Client Project #" field value from ' +
                              ( projectProfileMapOld.get(projectProfileItem.Id).Client_Project__c == null ? 'an empty value' : '"' + projectProfileMapOld.get(projectProfileItem.Id).Client_Project__c + '"' ) +
                              ' to ' +
                              ( projectProfileItem.Client_Project__c == null ? 'an empty value' : + '"' + projectProfileItem.Client_Project__c + '"' ) +
                              ' on the Project';
                errorFound = true;
            }

            Project_Profile__c projectWithRostersTaskServicesItem = projectWithRostersTaskServicesMap.get(projectProfileItem.Id);

            if ( !isUserInProjectRosterList (projectWithRostersTaskServicesItem, currentUserId, currentUserProfileName, currentUserRoleName, true) && errorFound ){ //MRS 7467 7469
                projectProfileItem.addError(errorString);
            }
        }
    }

    public static Boolean isUserInProjectRosterList (Project_Profile__c projectWithRostersTaskServicesItem, Id currentUserId,
                                                     String currentUserProfileName, String currentUserRoleName, Boolean isManualyCreatedRosterValid){
        if (currentUserProfileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) { return true; }

        if ( projectWithRostersTaskServicesItem.Project_Rosters__r.isEmpty() ){
            return false;
        } else {
            Set<String> rosterRolesForUser = new Set<String>();
            for (Project_Roster__c projectRosterItem : projectWithRostersTaskServicesItem.Project_Rosters__r){
                rosterRolesForUser.add(projectRosterItem.Role__c);
                if (isManualyCreatedRosterValid && projectRosterItem.Is_Manually_Added_Roster__c){ return true; }
            }
            if ( !( ( projectWithRostersTaskServicesItem.Proposal__r.OwnerId == currentUserId && rosterRolesForUser.contains(ProjectRosterServices.PROPOSAL_CREATOR_ROLE) ) ||
                    ( projectWithRostersTaskServicesItem.OwnerId == currentUserId && rosterRolesForUser.contains(ProjectRosterServices.PROJECT_OWNER_ROLE) ) ||
                    ( projectWithRostersTaskServicesItem.Project_Manager__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_PROJECT_MANAGER_2) ) ||
                    ( projectWithRostersTaskServicesItem.Project_Member__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_PROJECT_MANAGER_1) ) ||
                    ( projectWithRostersTaskServicesItem.FREP__c == currentUserId && rosterRolesForUser.contains(ProjectRosterServices.FILING_REP) ) ||
                    ( projectWithRostersTaskServicesItem.Production_Manager__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_PRODUCTION_MANAGER) ) ||
                    ( projectWithRostersTaskServicesItem.Partner__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_PARTNER) ) ||
                    ( projectWithRostersTaskServicesItem.Account_Executive__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_ACCOUNT_MANAGER) ) ||
                    ( projectWithRostersTaskServicesItem.Proposal_Specialist__c == currentUserId && rosterRolesForUser.contains(UserServices.PROFILE_PROPOSAL_SPECIALIST) ) ||
                    ( projectWithRostersTaskServicesItem.Salesperson__c == currentUserId && rosterRolesForUser.contains(ProjectRosterServices.SALESPERSON) ) ) &&
                 !( rosterRolesForUser.contains(currentUserRoleName) &&
                    (!projectWithRostersTaskServicesItem.Service_Items__r.isEmpty() || !projectWithRostersTaskServicesItem.Task_Items__r.isEmpty()) ) ){
                return false;
            }
        }

        return true;
    }

    public static Map<Id, Project_Profile__c> getProjectWithRostersTaskServices(List<Project_Profile__c> projectProfileFilteredList, Id currentUserId){
        if ( projectProfileFilteredList == null || projectProfileFilteredList.isEmpty() ){
            return new Map<Id, Project_Profile__c>();
        }

        return new Map<Id, Project_Profile__c>([SELECT Id, Proposal__r.OwnerId, OwnerId, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c, Partner__c, Account_Executive__c, Proposal_Specialist__c,Salesperson__c,
                                                     Submitted_Planned_Dates__c, Project_State__c, Project_Start_Date__c, Project_Expected_End_Date__c, Avoid_Validation_Rules__c, //MRS-6731
                                                     Billing_Method__c, Interval__c, Billing_End_Date__c,                                                                          //MRS-6786
                                                     (Select Id, User__c, Role__c, Is_Manually_Added_Roster__c From Project_Rosters__r Where User__c = : currentUserId AND Active__c = true), /* MRS 7467 */
                                                     (Select Id From Service_Items__r Where OwnerId = : currentUserId And Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                     (Select Id From Task_Items__r Where OwnerId = : currentUserId And Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE And RecordType.Name !=: TaskManagementServices.MILESTONE_RECORDTYPE_NAME)
                                                FROM Project_Profile__c
                                                WHERE Id IN : projectProfileFilteredList]);
    }

    public static List<Project_Profile__c> getPreBilledProjectByIds(Set<Id> projectIds) {
        return new List<Project_Profile__c>([SELECT Id, Project_Name__c, Building__r.Name, Building__c, Floor_s__c,
                                                    Proposal__c, Name, Primary_Company_Name__c, Primary_Company_Name__r.Name,
                                                    Project_Address__c, Municipal_Agency_ID__c, Letter_Body__c, Interval__c,
                                                    Floor_Counting__c, No_Met_Data_Scanning__c, Fulfillment_Office__c, No_Messenger_Fedex__c,
                                                    Submitted_Planned_Dates__c, Project_Start_Date__c, Project_Manager__c, Project_State__c, Project_Expected_End_Date__c, Pre_billed__c,
                                                    Reimbursable1__c, Reimbursable2__c, Reimbursable3__c, Reimbursable4__c, Discounted_Total_Service_Amount__c, Billing_Method__c,
                                                    Accounting_Contact_Company__c, Accounting_Contact__c, Billing_Company_Name__c, Billing_Company_Contact__c, Primary_Company_Contact__c
                                             FROM Project_Profile__c
                                             WHERE Id IN: projectIds AND Pre_billed__c =: true]);
    }

    public static Project_Profile__c getProjectForSendLetterById( Id projectId ) {
        if( String.isBlank( projectId ) ) {
            throw new ErrorException('Parameter project id cannot be empty!');
        }
        List<Project_Profile__c> projects = [ SELECT Letter_Name_Project_1__c, Letter_Name_Service_1__c, Letter_Name_Task_1__c,
                                                     Letter_Name_Project_2__c, Letter_Name_Service_2__c, Letter_Name_Task_2__c,
                                                     Letter_Name_Project_3__c, Letter_Name_Service_3__c, Letter_Name_Task_3__c,
                                                     Letter_Body_Project_1__c, Letter_Body_Service_1__c, Letter_Body_Task_1__c,
                                                     Letter_Body_Project_2__c, Letter_Body_Service_2__c, Letter_Body_Task_2__c,
                                                     Letter_Body_Project_3__c, Letter_Body_Service_3__c, Letter_Body_Task_3__c
                                              FROM Project_Profile__c
                                              WHERE Id = : projectId ];
        if( projects.isEmpty() ) {
            throw new ErrorException('Project does not exist for' + projectId + ' id!');
        }
        return projects.get(0);
    }

    //MRS-6078
    public static List<Project_Profile__c> filteredProjectWithCheckedNoMessengerFedex( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();

        if( oldProjectMap != null ) {
            for( Project_Profile__c project : newProjectList ) {
                if ( project.No_Messenger_Fedex__c != null && project.No_Messenger_Fedex__c && project.No_Messenger_Fedex__c != oldProjectMap.get(project.Id).No_Messenger_Fedex__c ){
                    filteredProjects.add( project );
                }
            }
        }

        return filteredProjects;
    }

    //MRS-6422
    public static List<Project_Profile__c> filterProjectWithChangedName( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for( Project_Profile__c project : newProjectList ) {
            if( project.Project_Name__c != null && project.Project_Name__c != oldProjectMap.get( project.Id ).Project_Name__c) {
                filteredProjects.add( project );
            }
        }
        return filteredProjects;
    }

    public static List<Project_Profile__c> filterProjectsWithChangedProposalCreator( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ){
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for( Project_Profile__c project : newProjectList ) {
            if( project.Proposal_Specialist__c != oldProjectMap.get( project.Id ).Proposal_Specialist__c ) {
                filteredProjects.add( project );
            }
        }
        return filteredProjects;
    }

    public static List<Project_Profile__c> filterProjectsWithChangedClientProject( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for( Project_Profile__c project : newProjectList ) {
            if( project.Client_Project__c != oldProjectMap.get( project.Id ).Client_Project__c ) {
                filteredProjects.add( project );
            }
        }
        return filteredProjects;
    }


    //MRS-6545
    public static List<Project_Profile__c> filteredProjectWithChangedOwner( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        Id currentUserId = userinfo.getuserid();
        for( Project_Profile__c project : newProjectList ) {
            if( oldProjectMap.get(project.Id).OwnerId != currentUserId && project.OwnerId != oldProjectMap.get(project.Id).OwnerId ) {
                filteredProjects.add(project);
            }
        }

        return filteredProjects;
    }

    public static void projectWithChangedOwnerValidation (List<Project_Profile__c> filteredProjectProfileList, Map<Id, Project_Profile__c> projectProfileMapOld){
        if (filteredProjectProfileList == null || filteredProjectProfileList.isEmpty()){ return; }

        User currentUser = UserServices.currentUserWithRoleProfile;
        if ( currentUser.Profile.Name != UserServices.PROFILE_SHARED_SERVICES_MANAGER ){
            return;
        }

        Set<Id> roleSubordinateUsers = ProjectManagerHomePageController.getRoleSubordinateUsers(currentUser.Id);

        for (Project_Profile__c projectProfileItem : filteredProjectProfileList){
            if ( !roleSubordinateUsers.contains ( projectProfileMapOld.get(projectProfileItem.Id).OwnerId ) ){
                projectProfileItem.addError('You have no permissions to change Owner of current record.');
            }
        }
    }

    //MRS-6242
    public static List<Project_Profile__c> uncheckNoReimbursablesAfterPreBill( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for ( Project_Profile__c item : projectProfileListNew ){
            if ( !item.Pre_billed__c && projectProfileMapOld.get(item.Id).Pre_billed__c && item.No_Reimbursables_After_Pre_Bill__c) {
                item.No_Reimbursables_After_Pre_Bill__c = false;
            }
        }
        return filteredProjects;
    }

    //MRS-6610
    public static Map<Id, Project_Profile__c> filteredProjectWithChangedBillingAccountingInformation( List<Project_Profile__c> newProjectList, Map<Id, Project_Profile__c> oldProjectMap ) {
        Map<Id, Project_Profile__c> filteredProjectsMap = new Map<Id, Project_Profile__c>();

        for ( Project_Profile__c item : newProjectList ){
            Project_Profile__c oldProject = oldProjectMap.get(item.id);
            if ( item.Accounting_Contact__c != oldProject.Accounting_Contact__c ||
                 item.Accounting_Contact_Company__c != oldProject.Accounting_Contact_Company__c ||
                 item.Billing_Company_Contact__c != oldProject.Billing_Company_Contact__c) {

                filteredProjectsMap.put( item.Id, item );
            }
        }
        return filteredProjectsMap;
    }

	public static Map<Id, Project_Profile__c> filteredProjectsWithChangedAccOrProdManager(List<Project_Profile__c> newList, Map<Id, Project_Profile__c> oldMap) { //MRS 7540
		Map<Id, Project_Profile__c> result = new Map<Id, Project_Profile__c>();
		for(Project_Profile__c pp : newList) {
			if(oldMap == null || oldMap.get(pp.Id) == null || pp.Account_Executive__c != oldMap.get(pp.Id).Account_Executive__c || pp.Production_Manager__c != oldMap.get(pp.Id).Production_Manager__c) result.put(pp.Id, pp); 
		}
		return result;
	}

    //MRS-6683
    public static List<Project_Profile__c> filterProjectWithBillingCompanyHold( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ) {
        List<Project_Profile__c> filteredProjects = new List<Project_Profile__c>();
        for ( Project_Profile__c item : projectProfileListNew ){
            if ( item.Billing_Company_Name__c != projectProfileMapOld.get(item.id).Billing_Company_Name__c && item.Billing_Company_Accounting_Hold__c != item.Accounting_Hold__c ) {
                item.Accounting_Hold__c = item.Billing_Company_Accounting_Hold__c;
                item.Project_State__c = item.Billing_Company_Accounting_Hold__c ? PROJECT_STATE_ON_HOLD :
                                                        ( item.Submitted_Planned_Dates__c ? ProjectProfileServices.PROJECT_STATE_IN_PROCESS : ProjectProfileServices.PROJECT_STATE_NOT_STARTED );
                filteredProjects.add(item);
            } else if ( item.Accounting_Hold__c && !projectProfileMapOld.get(item.id).Accounting_Hold__c &&
                        item.Project_State__c == projectProfileMapOld.get(item.id).Project_State__c && (item.Project_State__c == PROJECT_STATE_IN_PROCESS || item.Project_State__c == PROJECT_STATE_NOT_STARTED) ){
                item.Project_State__c = PROJECT_STATE_ON_HOLD;
            } else if ( !item.Accounting_Hold__c && projectProfileMapOld.get(item.id).Accounting_Hold__c &&
                        item.Project_State__c == projectProfileMapOld.get(item.id).Project_State__c && item.Project_State__c == PROJECT_STATE_ON_HOLD ){
                item.Project_State__c = item.Submitted_Planned_Dates__c ? ProjectProfileServices.PROJECT_STATE_IN_PROCESS : ProjectProfileServices.PROJECT_STATE_NOT_STARTED;
            }
        }
        return filteredProjects;
    }

    public static void processingOnHoldAccountingNotification( List<Project_Profile__c> filteredProjects ) {
        if ( filteredProjects == null || filteredProjects.isEmpty() ){ return; }

        Map<Id, Set<Id>> projectWithRosterUsersMap = new Map<Id, Set<Id>>();

        for (Project_Profile__c projectProfileItem : [SELECT Id, Account_Executive__c, FREP__c, Partner__c, Production_Manager__c, Project_Member__c, Primary_Company_Contact__c,
                                                            Billing_Company_Contact__c, Project_Manager__c, Proposal_Specialist__c, Resource__c, Salesperson__c, OwnerId,
                                                            Proposal__r.OwnerId, Accounting_Contact__c,
                                                            (Select Id, OwnerId
                                                             From Service_Items__r
                                                             Where Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                            (Select Id, OwnerId
                                                             From Task_Items__r
                                                             Where RecordType.Name !=: TaskManagementServices.MILESTONE_RECORDTYPE_NAME And
                                                             Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE),
                                                            (Select Id, User__c, Contact__c, Role__c, LastModifiedDate, CreatedDate, Is_Manually_Added_Roster__c, Active__c, Is_Manually_Activated__c, Is_Manually_Deactivated__c /*MRS 6800*/
                                                             From Project_Rosters__r Where User__c != null And  User__r.IsActive = true And RecordType.Name =: ProjectRosterServices.TYPE_USER Order By CreatedDate Desc)
                                                      FROM Project_Profile__c
                                                      WHERE Id IN : filteredProjects]){

            Set<Id> userSetId = new Set<Id>();
            for (Project_Roster__c rosterItem : getProjectRosterStatusOnlyValid (projectProfileItem).values()){
                if (rosterItem != null ){
                    userSetId.add(rosterItem.User__c);
                }
            }
            projectWithRosterUsersMap.put( projectProfileItem.Id, userSetId);
        }

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for ( Project_Profile__c projectProfileItem : filteredProjects ){
            if ( projectWithRosterUsersMap.containsKey( projectProfileItem.Id ) ){
                String subjectValue = projectProfileItem.Name;
                subjectValue += projectProfileItem.Accounting_Hold__c ? ' has been placed on hold.' : ' has been removed from hold.';

                String emailBodyValue = projectProfileItem.Name;
                emailBodyValue += projectProfileItem.Accounting_Hold__c ? ' has been placed on hold. No work should be done for this Project until it have been removed from hold.'
                                                                        : ' has been removed on hold. Please proceed with working on this project.';

                for ( Id userId : projectWithRosterUsersMap.get( projectProfileItem.id ) ){
                    mailList.add( EmailMessageService.createEmailNotificationMessage(subjectValue, emailBodyValue, userId) );
                }
            }
        }

        if( !Test.isRunningTest() && !mailList.isEmpty() ) Messaging.sendEmail(mailList);
    }

    //MRS-6871
    public static List<Project_Profile__c> filteredChangeClosedProject( List<Project_Profile__c> projectProfileListNew, Map<Id, Project_Profile__c> projectProfileMapOld ){
        List<Project_Profile__c> filteredList = new List<Project_Profile__c>();

        for (Project_Profile__c projectProfileItem : projectProfileListNew){
            if ( (projectProfileItem.Project_State__c == PROJECT_STATE_CLOSED && projectProfileItem.Project_State__c != projectProfileMapOld.get(projectProfileItem.Id).Project_State__c) ||
                 (projectProfileItem.Project_State__c != PROJECT_STATE_CLOSED && projectProfileMapOld.get(projectProfileItem.Id).Project_State__c == PROJECT_STATE_CLOSED) ){
                filteredList.add(projectProfileItem);
            }
        }

        return filteredList;
    }

    public static void updateChangeOrderIfCloseProject( List<Project_Profile__c> projectProfileFilteredList ){
        if (projectProfileFilteredList == null || projectProfileFilteredList.isEmpty()){
            return;
        }

        List<Change_Order__c> changeOrderUpdateList = [SELECT Id, Status__c, Status_Reopen__c, Project_Profile__r.Project_State__c
                                                       FROM Change_Order__c
                                                       WHERE Project_Profile__c IN : projectProfileFilteredList AND
                                                          (( Status__c != : ChangeOrderServices.STATUS_APPROVED And Project_Profile__r.Project_State__c = : PROJECT_STATE_CLOSED ) OR
                                                           ( Status__c = : ChangeOrderServices.STATUS_CANCELED And Status_Reopen__c != null And Status_Reopen__c != '' And Project_Profile__r.Project_State__c != : PROJECT_STATE_CLOSED))];

            for (Change_Order__c changeOrderItem : changeOrderUpdateList){
                if( changeOrderItem.Project_Profile__r.Project_State__c == PROJECT_STATE_CLOSED ){
                    changeOrderItem.Status_Reopen__c = changeOrderItem.Status__c;
                    changeOrderItem.Status__c = ChangeOrderServices.STATUS_CANCELED;
                } else {
                    changeOrderItem.Status__c = changeOrderItem.Status_Reopen__c;
                    changeOrderItem.Status_Reopen__c = '';
                }
            }

        try{
            update changeOrderUpdateList;
        } catch (DMLException dmlEx){
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                new Map<Id, Project_Profile__c>(projectProfileFilteredList).get( changeOrderUpdateList[i].Project_Profile__c ).addError( 'Can not update Change Orders. ' + dmlEx.getMessage() );
            }
        }
    }

    //MRS-6851
    public static void populateUsersFieldOnProject(List<Proposal__c> proposalList, List<Service_Item__c> serviceItemList, List<Project_Roster__c> projectRosterList){
        Set<Id> projectProfileSetId = new Set<Id>();

        if ( proposalList != null ){
            for (Proposal__c coItem : proposalList){
                projectProfileSetId.add(coItem.Project_Profile__c);
            }
        }
        if ( serviceItemList != null ){
            for (Service_Item__c serviceItem : serviceItemList){
                projectProfileSetId.add(serviceItem.Project_Profile__c);
            }
        }
        if ( projectRosterList != null ){
            for (Project_Roster__c projectRosterItem : projectRosterList){
                projectProfileSetId.add(projectRosterItem.Project_Profile__c);
            }
        }

        if ( projectProfileSetId.isEmpty() ) return;

        List<Project_Profile__c> projectProfileList = [SELECT Id, C_Z_Analyst__c, C_of_O_Coordinator__c, SIPS_Coordinator__c, FDNY_Coordinator__c, Avoid_Validation_Rules__c,
                                                            (Select Id, OwnerId, Status__c, Actual_End_Date__c, Role_Assignment__c, Manager_Lookup__c
                                                             From Service_Items__r
                                                             Where Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE And
                                                                  Is_Alternative__c = false And
                                                                  (Original__c = true or (Change_Order__r.Approved_Date__c != null)) And
                                                                  (Role_Assignment__c IN : ROLENAMESFORPROJECTASSIGNMENT Or Role_Assignment__c Like : '%' + UserServices.ROLE_CZ_MANAGER)
                                                                  Order By Role_Assignment__c, Actual_End_Date__c NULLS FIRST),
                                                            (Select Id, User__c, Role__c
                                                             From Project_Rosters__r
                                                             Where Active__c = true And
                                                                User__c != null And
                                                                (Role__c IN : ROLENAMESFORPROJECTASSIGNMENT or Role__c Like : '%' + UserServices.ROLE_CZ_MANAGER) )
                                                       FROM Project_Profile__c
                                                       WHERE Id IN : projectProfileSetId];

        Map<Id, Project_Profile__c> projectProfileUpdateMap = new Map<Id, Project_Profile__c>();

        for (Project_Profile__c projectProfileItem : projectProfileList){
            Boolean doUpdate = false;
            Service_Item__c cOfOCoordinatorUserSI, codeAndZoningAnalistUserSI, sipsCoordinatorUserSI, fdnyCoordinatorUserSI = null;
            Id cOfOCoordinatorUserId, codeAndZoningAnalistUserId, sipsCoordinatorUserId, fdnyCoordinatorUserId = null;

            Set<Id> rosterUsers = new Set<Id>();
            Set<Id> cOfOCoordinatorUserSetId  = new Set<Id>();
            Set<Id> codeAndZoningAnalistUserSetId = new Set<Id>();
            Set<Id> sipsCoordinatorUserSetId = new Set<Id>();
            Set<Id> fdnyCoordinatorUserSetId = new Set<Id>();

            for(Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
                rosterUsers.add(projectRosterItem.User__c);
                if (projectRosterItem.Role__c == UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER ||
                    projectRosterItem.Role__c == UserServices.ROLE_C_OF_O_DEPARTMENT_COORDINATOR){
                    cOfOCoordinatorUserId = projectRosterItem.User__c;
                    cOfOCoordinatorUserSetId.add(projectRosterItem.User__c);
                } else if (projectRosterItem.Role__c == UserServices.ROLE_CODE_ZONING_ANALYST ||
                           projectRosterItem.Role__c == UserServices.ROLE_CODE_ZONING_DEPARTMENT_REVIEWER ||
                           projectRosterItem.Role__c.contains(UserServices.ROLE_CZ_MANAGER)){
                    codeAndZoningAnalistUserId = projectRosterItem.User__c;
                    codeAndZoningAnalistUserSetId.add(projectRosterItem.User__c);
                } else if (projectRosterItem.Role__c == UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER ||
                           projectRosterItem.Role__c == UserServices.ROLE_SIPS_DEPARTMENT_COORDINATOR){
                    sipsCoordinatorUserId = projectRosterItem.User__c;
                    sipsCoordinatorUserSetId.add(projectRosterItem.User__c);
                } else {
                    fdnyCoordinatorUserId = projectRosterItem.User__c;
                    fdnyCoordinatorUserSetId.add(projectRosterItem.User__c);
                }
            }

            for(Service_Item__c si : projectProfileItem.Service_Items__r){
                if (rosterUsers.contains(si.OwnerId)){
                    if ( (si.Role_Assignment__c == UserServices.ROLE_C_OF_O_DEPARTMENT_MANAGER ||
                          si.Role_Assignment__c == UserServices.ROLE_C_OF_O_DEPARTMENT_COORDINATOR) &&
                         cOfOCoordinatorUserSetId.contains(si.OwnerId) ){

                        if ( cOfOCoordinatorUserSI == null ||
                             (si.Actual_End_Date__c == null && cOfOCoordinatorUserSI.Actual_End_Date__c != null) ||
                             (si.Actual_End_Date__c == null && cOfOCoordinatorUserSI.Actual_End_Date__c == null && si.Manager_Lookup__c != si.OwnerId && cOfOCoordinatorUserSI.Manager_Lookup__c == cOfOCoordinatorUserSI.OwnerId) ||
                             (si.Actual_End_Date__c != null && cOfOCoordinatorUserSI.Actual_End_Date__c != null && si.Manager_Lookup__c != si.OwnerId && cOfOCoordinatorUserSI.Manager_Lookup__c == cOfOCoordinatorUserSI.OwnerId) ){

                             cOfOCoordinatorUserSI = si;
                             cOfOCoordinatorUserId = si.OwnerId;
                        }

                    } else if( (si.Role_Assignment__c == UserServices.ROLE_CODE_ZONING_ANALYST ||
                                si.Role_Assignment__c == UserServices.ROLE_CODE_ZONING_DEPARTMENT_REVIEWER ||
                                si.Role_Assignment__c.contains(UserServices.ROLE_CZ_MANAGER)) &&
                                codeAndZoningAnalistUserSetId.contains(si.OwnerId) ){

                        if ( codeAndZoningAnalistUserSI == null ||
                             (si.Actual_End_Date__c == null && codeAndZoningAnalistUserSI.Actual_End_Date__c != null) ||
                             (si.Actual_End_Date__c == null && codeAndZoningAnalistUserSI.Actual_End_Date__c == null && si.Manager_Lookup__c != si.OwnerId && codeAndZoningAnalistUserSI.Manager_Lookup__c == codeAndZoningAnalistUserSI.OwnerId) ||
                             (si.Actual_End_Date__c != null && codeAndZoningAnalistUserSI.Actual_End_Date__c != null && si.Manager_Lookup__c != si.OwnerId && codeAndZoningAnalistUserSI.Manager_Lookup__c == codeAndZoningAnalistUserSI.OwnerId) ){

                             codeAndZoningAnalistUserSI = si;
                             codeAndZoningAnalistUserId = si.OwnerId;
                        }

                    } else if( (si.Role_Assignment__c == UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER ||
                                si.Role_Assignment__c == UserServices.ROLE_SIPS_DEPARTMENT_COORDINATOR) &&
                                sipsCoordinatorUserSetId.contains(si.OwnerId) ){

                        if ( sipsCoordinatorUserSI == null ||
                             (si.Actual_End_Date__c == null && sipsCoordinatorUserSI.Actual_End_Date__c != null) ||
                             (si.Actual_End_Date__c == null && sipsCoordinatorUserSI.Actual_End_Date__c == null && si.Manager_Lookup__c != si.OwnerId && sipsCoordinatorUserSI.Manager_Lookup__c == sipsCoordinatorUserSI.OwnerId) ||
                             (si.Actual_End_Date__c != null && sipsCoordinatorUserSI.Actual_End_Date__c != null && si.Manager_Lookup__c != si.OwnerId && sipsCoordinatorUserSI.Manager_Lookup__c == sipsCoordinatorUserSI.OwnerId) ){

                             sipsCoordinatorUserSI = si;
                             sipsCoordinatorUserId = si.OwnerId;
                        }

                    } else if( (si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_MANAGER ||
                                si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_REVIEWER ||
                                si.Role_Assignment__c == UserServices.ROLE_FDNY_DEPARTMENT_COORDINATOR) &&
                                fdnyCoordinatorUserSetId.contains(si.OwnerId) ){

                        if ( fdnyCoordinatorUserSI == null ||
                             (si.Actual_End_Date__c == null && fdnyCoordinatorUserSI.Actual_End_Date__c != null) ||
                             (si.Actual_End_Date__c == null && fdnyCoordinatorUserSI.Actual_End_Date__c == null && si.Manager_Lookup__c != si.OwnerId && fdnyCoordinatorUserSI.Manager_Lookup__c == fdnyCoordinatorUserSI.OwnerId) ||
                             (si.Actual_End_Date__c != null && fdnyCoordinatorUserSI.Actual_End_Date__c != null && si.Manager_Lookup__c != si.OwnerId && fdnyCoordinatorUserSI.Manager_Lookup__c == fdnyCoordinatorUserSI.OwnerId) ){

                             fdnyCoordinatorUserSI = si;
                             fdnyCoordinatorUserId = si.OwnerId;
                        }
                    }
                }
            }

            if ( projectProfileItem.C_of_O_Coordinator__c != cOfOCoordinatorUserId ){
                projectProfileItem.C_of_O_Coordinator__c = cOfOCoordinatorUserId;
                doUpdate = true;
            }
            if ( projectProfileItem.C_Z_Analyst__c != codeAndZoningAnalistUserId ){
                projectProfileItem.C_Z_Analyst__c = codeAndZoningAnalistUserId;
                doUpdate = true;
            }
            if ( projectProfileItem.SIPS_Coordinator__c != sipsCoordinatorUserId ){
                projectProfileItem.SIPS_Coordinator__c = sipsCoordinatorUserId;
                doUpdate = true;
            }
            if ( projectProfileItem.FDNY_Coordinator__c != fdnyCoordinatorUserId ){
                projectProfileItem.FDNY_Coordinator__c = fdnyCoordinatorUserId;
                doUpdate = true;
            }
            if (doUpdate){
                projectProfileItem.Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey();
                projectProfileUpdateMap.put(projectProfileItem.id, projectProfileItem);
            }
        }

        if (!projectProfileUpdateMap.isEmpty()){
            try {
                update projectProfileUpdateMap.values();
            } catch ( DMLException dmlEx ) {
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                    if ( Trigger.isExecuting ){
                        Id projectId = projectProfileUpdateMap.values()[dmlEx.getDmlIndex(i)].Id; //.addError( 'Can not update Service Item: ' + dmlEx.getMessage() );
                        if (serviceItemList != null && !serviceItemList.isEmpty()){
                            for (Service_Item__c si : serviceItemList){
                                if (si.Project_Profile__c == projectId){
                                    si.addError('Can not update Project: ' + dmlEx.getMessage());
                                }
                            }
                        }
                        if (projectRosterList != null && !projectRosterList.isEmpty()){
                            for (Project_Roster__c projectRosterItem : projectRosterList){
                                if (projectRosterItem.Project_Profile__c == projectId){
                                    projectRosterItem.addError('Can not update Project: ' + dmlEx.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    public static void updateProjectStatus(Map<Id, Change_Order__c> filteredChangeOrders) { // MRS 7062 MRS 7222
        List<Project_Profile__c> projectsToUpdate = new List<Project_Profile__c> ();

        Set<Id> projectsWithSignOffServices = new Set<Id>();
        Set<Id> projectsWithSignOffLSServices = new Set<Id>();
        Set<Id> projectsWithOtherServices = new Set<Id>();

        Set<Id> projectIdxSet = new Set<Id> ();
        for(Change_Order__c co : filteredChangeOrders.values()) if(co.Project_Profile__c != null) {
          projectIdxSet.add(co.Project_Profile__c);
        }
        List<Service_Item__c> serviceItems = [SELECT Primary_Grouping__c, Secondary_Grouping__c, Unit_of_Service__c, Project_Profile__c, Work_Type__c
                                              FROM Service_Item__c
                          WHERE Is_Alternative__c = false
                            AND (Is_Amendmend_Deleted__c != true OR (Is_Amendmend_Deleted__c = true AND (Change_Order__c = null OR Change_Order_Status__c != :ChangeOrderServices.STATUS_APPROVED)))
                            AND Status__c != 'Inactive'
                            AND Status__c != 'Completed'
                            AND Project_Profile__c IN :projectIdxSet];
        for(Service_Item__c si : serviceItems) {
            if( si.Primary_Grouping__c == ServiceItemServices.PRIMARY_GROUPING_SIGNOFF_LOC &&
                  ( si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_ALT2_D14 ||
                    si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_ALT_3 ||
                    si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_D2 ||
                    si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_EUP ) ) {

                if(ServiceItemServices.isServiceSignOffLS(si)) { // MRS 7266
                    projectsWithSignOffLSServices.add(si.Project_Profile__c);
                } else {
                    projectsWithSignOffServices.add(si.Project_Profile__c);
                }
            } else if( si.Unit_of_Service__c != ServiceItemServices.UNIT_OF_SERVICE_HOUR ) {
                projectsWithOtherServices.add( si.Project_Profile__c );
                break; //if any "other" service is found (which is not eligible), no need to continue the loop
            }
        }
        for(Id idx : projectIdxSet) {
            Project_Profile__c project = new Project_Profile__c (Id = idx);
            if(projectsWithSignOffLSServices.contains(idx) && !projectsWithSignOffServices.contains(idx) && !projectsWithOtherServices.contains(idx)) {
                project.Project_Status__c = PROJECT_STATUS_SIGNOFF_PENDING_LS;
            } else if(projectsWithSignOffServices.contains(idx) && !projectsWithOtherServices.contains(idx)) {
                project.Project_Status__c = PROJECT_STATUS_SIGNOFF_PENDING;
            } else {
                project.Project_Status__c = null;
            }
            projectsToUpdate.add(project);
        }
        try {
            UPDATE projectsToUpdate;
        } catch( DMLException dmlEx ) {
            Map<Id, List<Id>> projectProfileIdToChangeOrderIds = new Map<Id, List<Id>>();
            for( Change_Order__c co : filteredChangeOrders.values() ) {
                if( projectProfileIdToChangeOrderIds.get( co.Project_Profile__c ) == null ) {
                    projectProfileIdToChangeOrderIds.put( co.Project_Profile__c, new List<Id>() );
                }
                projectProfileIdToChangeOrderIds.get( co.Project_Profile__c ).add( co.Id );
            }
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                for( Id coId : projectProfileIdToChangeOrderIds.get( projectsToUpdate[dmlEx.getDmlIndex(i)].Id ) ) {
                    filteredChangeOrders.get( coId ).addError( 'Error Occured While Updating Project Status: ' + dmlEx.getMessage() );
                }
            }
        }
    }

    public static void setProjectStatus( List<Project_Profile__c> newProjects ) { //MRS 7062 MRS 7222
        Map<Id, Project_Profile__c> proposalIdToProject = new Map<Id, Project_Profile__c>();
        for( Project_Profile__c project : newProjects ) {
                proposalIdToProject.put( project.Proposal__c, project );
            }
        Set<Id> proposalsWithSignOffServices = new Set<Id>();
        Set<Id> proposalsWithSignOffLSServices = new Set<Id>();
        Set<Id> proposalsWithOtherServices = new Set<Id>();
        List<Proposal__c> proposals = [ SELECT Id,
                                               ( SELECT Id, Primary_Grouping__c, Secondary_Grouping__c, Unit_of_Service__c, Work_Type__c
                                                 FROM Service_Items__r
                                                   WHERE Is_Alternative__c = false )
                                        FROM Proposal__c
                                        WHERE Id IN : proposalIdToProject.keySet() ];
        for( Proposal__c proposal : proposals ) {
            for( Service_Item__c si : proposal.Service_Items__r ) {
                if( si.Primary_Grouping__c == ServiceItemServices.PRIMARY_GROUPING_SIGNOFF_LOC &&
                    ( si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_ALT2_D14 ||
                      si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_ALT_3 ||
                      si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_D2 ||
                      si.Secondary_Grouping__c == ServiceItemServices.SECONDARY_GROUPING_EUP ) ) {
                    if(ServiceItemServices.isServiceSignOffLS(si)) { // MRS 7266
                        proposalsWithSignOffLSServices.add(proposal.Id);
                    } else {
                        proposalsWithSignOffServices.add( proposal.Id );
                    }
                } else if( si.Unit_of_Service__c != ServiceItemServices.UNIT_OF_SERVICE_HOUR ) {
                    proposalsWithOtherServices.add( proposal.Id );
                    break; //if any "other" service is found (which is not eligible), no need to continue the loop
                }
            }
        }
        for( Proposal__c proposal : proposals ) {
            if(proposalsWithSignOffLSServices.contains(proposal.Id) && !proposalsWithSignOffServices.contains(proposal.Id) && !proposalsWithOtherServices.contains(proposal.Id)) {
                proposalIdToProject.get( proposal.Id ).Project_Status__c = PROJECT_STATUS_SIGNOFF_PENDING_LS;
            } else if(proposalsWithSignOffServices.contains(proposal.Id) && !proposalsWithOtherServices.contains(proposal.Id)) {
                proposalIdToProject.get( proposal.Id ).Project_Status__c = PROJECT_STATUS_SIGNOFF_PENDING;
            } else {
                proposalIdToProject.get( proposal.Id ).Project_Status__c = null;
            }
        }
    }

    public static void setQuarterlyMonthAccordinglyToFrequency(List<Project_Profile__c> newList) { //MRS 7400
        for(Project_Profile__c project : newList) {
            if(project.Frequency__c == 'Weekly' || project.Frequency__c == 'Monthly') project.Quarterly_Month__c = null;
        }
    }
}