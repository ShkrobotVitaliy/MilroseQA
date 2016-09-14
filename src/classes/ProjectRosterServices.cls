public with sharing class ProjectRosterServices {
    public static final String PROJECT_ROSTER_OBJECT_API_NAME = 'Project_Roster__c';

    public static final String BUILDING_OWNER_SIGNATURE = 'Building Owner Signature';
    public static final String PRIMARY_CLIENT_CONTACT = 'Primary Client Contact';
    public static final String BILLING_CLIENT_CONTACT = 'Billing Client Contact (Bill To)';
    public static final String ACCOUNTING_CLIENT_CONTACT = 'Accounting Contact (Mail To)';

    public static final String PARTNER = 'Partner';
    public static final String ACCOUNT_MANAGER = 'Account Manager';
    public static final String SALESPERSON = 'Salesperson';
    public static final String PRODUCTION_MANAGER = 'Production Manager';
    public static final String FILING_REP = 'Filing Rep';
    public static final String PROJECT_OWNER_ROLE = 'Project Owner';
    public static final String PROPOSAL_CREATOR_ROLE = 'Proposal Creator';
    public static final String SIPS_DEPARTMENT_MANAGER_ROLE = 'SIPS Department Manager';

	public static final String BUILDING_OWNER_1 = 'Building Owner Contact 1'; //MRS 6888
	public static final String BUILDING_OWNER_2 = 'Building Owner Contact 2';
	public static final String BUILDING_MANAGER = 'Building/Property Manager';

    public static final String TYPE_USER = 'User';
    public static final String TYPE_CONTACT = 'Contact';
    public static final String USER_TYPE_EX = 'External';
    public static final String USER_TYPE_IN = 'Internal';

    public static void setKey( List<Project_Roster__c> projectsFromTrigger ) {
        for( Project_Roster__c item : projectsFromTrigger ) {
            if(item.Key__c==null) {
                item.Key__c = MilroseDevHelper.getUniqueKey();
            }
        }
    }

    public static void populateProposal( List<Project_Roster__c> projectsFromTrigger ) {

        for( Project_Roster__c item : projectsFromTrigger ) {
            if( item.Proposal__c == null && item.Project_Profile__c != null ){
                item.Proposal__c = item.Proposal_From_Project__c; //projects.get( item.Project_Profile__c ).Proposal__c;
            }
        }
    }

    public static Map<String, RecordType> projectRosterRecordTypeMap {
        get {
            if( projectRosterRecordTypeMap == null ) {
                projectRosterRecordTypeMap = new Map<String, RecordType>();
                for( RecordType recordType : [ SELECT Id, Name
                                               FROM RecordType
                                               WHERE SobjectType = 'Project_Roster__c'
                                                 AND IsActive = true ] ) {
                    projectRosterRecordTypeMap.put( String.valueOf( recordType.Name ), recordType );
                }
            }
            return projectRosterRecordTypeMap;
        }
        private set;
    }

    public static Map<String, Id> getRoleToUserField( Proposal__c proposal ) {
        return new Map<String, String>{ ProjectRosterServices.PARTNER => proposal.Partner__c,
                                        ProjectRosterServices.SALESPERSON => proposal.Salesperson__c,
                                        ProjectRosterServices.ACCOUNT_MANAGER => proposal.Account_Executive__c,
                                        ProjectRosterServices.PROPOSAL_CREATOR_ROLE => ( proposal.Id == null ? UserInfo.getUserId() : proposal.CreatedById ),
                                        ProjectRosterServices.PRIMARY_CLIENT_CONTACT => proposal.Primary_Company_Contact__c,
                                        ProjectRosterServices.BILLING_CLIENT_CONTACT => proposal.Billing_Company_Contact__c,
                                        ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT => proposal.Accounting_Contact__c };
    }

    public static Map<String, Boolean> getRoleToIsUser() {
        return new Map<String, Boolean>{ ProjectRosterServices.PARTNER => true,
                                         ProjectRosterServices.SALESPERSON => true,
                                         ProjectRosterServices.ACCOUNT_MANAGER => true,
                                         ProjectRosterServices.PROPOSAL_CREATOR_ROLE => true };
    }

    public static Contact getContactById( Id contactId ) {
        if( contactId != null ) {
            return [ SELECT Name, Primary_Profession__c, Email, DND__c, MailingStreet, Is_Active__c, EmailBouncedDate
                     FROM Contact
                     WHERE Id = : contactId /*AND Is_Active__c = true*/ LIMIT 1 ];
        }
        return new Contact();
    }

    public static Id getRecordTypeByObjectNameId (String objectName, String recordTypeName){
        if (mapObjectNameRecordTypeNameRecordTypeId == null){
            mapObjectNameRecordTypeNameRecordTypeId = new Map<String, Map<String, Id>>();
            for (RecordType recordTypeItem : [SELECT Id, Name, SobjectType, DeveloperName, Description FROM RecordType]){
                if (!mapObjectNameRecordTypeNameRecordTypeId.containsKey(recordTypeItem.SobjectType)){
                    mapObjectNameRecordTypeNameRecordTypeId.put(recordTypeItem.SobjectType, new Map<String, Id>());
                }
                mapObjectNameRecordTypeNameRecordTypeId.get(recordTypeItem.SobjectType).put(recordTypeItem.Name, recordTypeItem.id);
            }
        }
        return mapObjectNameRecordTypeNameRecordTypeId.get(objectName).get(recordTypeName);
    }

    private static Map<String, Map<String, Id>> mapObjectNameRecordTypeNameRecordTypeId;

    public static List<Project_Roster__c> getProjectRosterByProjectProfileId(Id projectProfileId) {
        if (null == projectProfileId) {
            return new List<Project_Roster__c>();

        }

        return new List<Project_Roster__c>([SELECT User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c,
                                                   User_Type__c, Contact__r.AccountId, Company_Name__c, Company_Address__c,
                                                   Name__c, Is_Read__c, Email__c, Contact__c, Contact_Account_Name__c,
                                                   RecordType.Name, Contact__r.Name, User__r.Name, Send_Reminder__c,
                                                   Is_Reminder_Sent__c, Key__c, CreatedDate, CreatedBy.Name, CreatedById,
                                                   Contact__r.Is_Active__c, User__r.IsActive, LastModifiedDate, Contact__r.DND__c, //MRS-6716
                                                   LastModifiedBy.Name, LastModifiedById, User_Contact_IsActive__c,
                                                   Is_Manually_Deactivated__c, Is_Manually_Activated__c, Active__c, Active_Tracking__c
                                            FROM Project_Roster__c
                                            WHERE Project_Profile__c =: projectProfileId]);

    }

    public static List<Project_Roster__c> getProjectRosterByProjectProfileIds( Set<Id> projectProfileIds ) {
        if ( null == projectProfileIds ) {
            return new List<Project_Roster__c>();

        }

        return new List<Project_Roster__c>([SELECT User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, User_Type__c,
                                                  Company_Name__c, Company_Address__c, Name__c, Is_Read__c, Email__c, Contact__c,
                                                  RecordType.Name, Contact__r.Name, User__r.Name, Send_Reminder__c, Is_Reminder_Sent__c, Key__c,
                                                  Contact__r.Is_Active__c, User_Contact_IsActive__c, Active__c
                                            FROM Project_Roster__c
                                            WHERE Project_Profile__c IN: projectProfileIds AND
                                                Active__c = true]);

    }

    public static List<Project_Roster__c> getProjectRosterByProposalId( Id proposalId ) {
        List<Project_Roster__c> projectRosterList = new List<Project_Roster__c>();
        projectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, User_Type__c, User_Contact_IsActive__c,
                                    Name__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, Proposal__c, Send_Reminder__c, Is_Reminder_Sent__c, Key__c
                             From Project_Roster__c
                             Where Proposal__c = : proposalId];
        return projectRosterList;
    }

    public static map<String, RecordType> getRecordType() {
        map<String, RecordType> recordTypeMap = new map<String, RecordType>();
        for(RecordType recordType : [SELECT SobjectType, Name, IsActive, Id FROM RecordType WHERE SobjectType = 'Project_Roster__c' AND IsActive = true]) {
            recordTypeMap.put(String.valueOf(recordType.Name), recordType);
        }
        return recordTypeMap;
    }

    public static List<Project_Roster__c> getProjectRosterOnlyContactByProposalId (Id proposalId) {
        map<String, RecordType> recordTypeMap = ProjectRosterServices.getRecordType();
        List<Project_Roster__c> projectRosterList = new List<Project_Roster__c>();
        projectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, Active__c, CreatedDate,//MRS-7509
                                    Name__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, Send_Reminder__c,
                                    Is_Reminder_Sent__c, Key__c, User_Type__c, User_Contact_IsActive__c
                             From Project_Roster__c
                             Where Proposal__c = : proposalId AND RecordTypeId = : recordTypeMap.get(ProjectRosterServices.TYPE_CONTACT).Id];
        return projectRosterList;
    }

     public static Map<Id, Map<Id, Project_Roster__c>> getRosterMapById( Set<Id> idSet ) {
        Map<Id, Map<Id, Project_Roster__c>> rosterMap = new Map<Id, Map<Id, Project_Roster__c>>();
        Map<Id, Project_Roster__c> rosterMapIn = new Map<Id, Project_Roster__c>([ SELECT Id, To__c, Cc__c, User_Type__c, User_Contact__c, Send_Reminder__c, Is_Reminder_Sent__c, Key__c, Contact__c, Project_Profile__c, Role__c FROM Project_Roster__c WHERE Project_Profile__c IN: idSet ]);
        for ( Project_Roster__c item: rosterMapIn.values() ){
            if( !rosterMap.containsKey(item.Project_Profile__c) ){
                rosterMap.put(item.Project_Profile__c, new Map<Id, Project_Roster__c>() );
            }
            rosterMap.get(item.Project_Profile__c).put(item.Id, item);

        }
		return rosterMap;
    }

    public static List<Project_Roster__c> getProjectRosterById( Id parentId ) {
        List<Project_Roster__c> projectRosterList = new List<Project_Roster__c>();
        if( !String.isEmpty(parentId) ) {
            projectRosterList = [ SELECT User_Type__c, User_Contact_IsActive__c, Is_Read__c, Send_Reminder__c, Contact__c, User__c, Role__c, To__c, Cc__c, RecordTypeId,
                                         Contact__r.Name, Contact__r.Primary_Profession__c, Contact__r.DND__c, Contact__r.MailingStreet, Contact__r.Email,
                                         Approver__c, User__r.Name, User__r.Email, Active__c //MRS-6868
                                  FROM Project_Roster__c
                                  WHERE Proposal__c = : parentId
                                  LIMIT 1000 ];
        }
        return projectRosterList;
    }

    public static List<Project_Roster__c> getRosterByProjectId(Id projectId) {
        if ( null == projectId ) {
            return new List<Project_Roster__c>();
        }
        return new List<Project_Roster__c> ([SELECT Id, Project_Profile__c, Email__c, Contact_Full_Name__c, Role__c, Contact__c, Name__c, Company_Name__c, RecordType.Name,
                                                    Company_Address__c, Contact__r.Is_Active__c, User__r.IsActive, Contact__r.Account.Name, Contact__r.Phone, Contact_Mailing_Street__c,
                                                    Contact_Mailing_City__c, Contact_Mailing_State_Province__c, Contact_Mailing_Zip_Postal_Code__c, Contact_Title__c, Is_Read__c, Active__c //MRS-6868
                                             FROM Project_Roster__c
                                             WHERE Project_Profile__c =: projectId AND (Contact__r.Is_Active__c =: true OR User__r.IsActive =: true)
                                             ORDER BY Role__c LIMIT 999]);
    }

    public static List<Project_Roster__c> getRostersByContactId( Id contactId ) {
        if ( null == contactId ) {
            return new List<Project_Roster__c>();
        }
        return new List<Project_Roster__c> ([SELECT Id, Project_Profile__c, Email__c, Contact_Full_Name__c, Role__c, Contact__c, Name__c, Company_Name__c, RecordType.Name,
                                                    Company_Address__c, Contact__r.Is_Active__c, User__r.IsActive, Contact__r.Account.Name, Contact__r.Phone, Contact_Mailing_Street__c,
                                                    Contact_Mailing_City__c, Contact_Mailing_State_Province__c, Contact_Mailing_Zip_Postal_Code__c, Contact_Title__c, Active__c
                                             FROM Project_Roster__c
                                             WHERE Contact__c =: contactId AND Contact__r.Is_Active__c =: true
                                             ORDER BY Role__c]);
    }

    public static List<Project_Roster__c> getRostersByIds(Set<Id> projectRosterIds) {
        if (null == projectRosterIds || projectRosterIds.isEmpty()) {
            throw new ErrorException(ErrorException.PROJECT_ROSTER_EMPTY_ROSTER_ID);
        }
        return new List<Project_Roster__c> ([SELECT Id, Email__c, Role__c, Name__c, Name_Full__c, Contact__c, User__c
                                             FROM Project_Roster__c
                                             WHERE Id IN: projectRosterIds]);
    }

    public static Map<String, Project_Roster__c> getRoleToRoster(List<Project_Roster__c> rosters) {
        Map<String, Project_Roster__c> rosteRoleToRoster = new Map<String, Project_Roster__c>();

        for (Project_Roster__c roster : rosters) {
            if (!rosteRoleToRoster.containsKey(roster.Role__c)) {
                rosteRoleToRoster.put(roster.Role__c, roster);
            }
        }
        return rosteRoleToRoster;
    }

    public static Map<Id, Map<String, List<Project_Roster__c>>> getProjectRostersByRoleNameByParentId( Schema.sObjectType objectname, List<sObject> objects, List<Id> objectsIds, List<String> rolesNames ) {
        //you can pass list of object ids, or list of objects, or both of them
        //if rolesNames == null then method retrieves rosters with any role, else only roles passed to the method
        Map<Id, Map<String, List<Project_Roster__c>>> projectRostersByRoleNameByParentId = new Map<Id, Map<String, List<Project_Roster__c>>>();
        Set<Id> objectIds = new Set<Id>();
        Set<String> roleNames = new Set<String>();

        if( objectname != null ) {
            if( rolesNames != null ) {
                roleNames.addAll( rolesNames );
            }
            if( objects != null ) {
                for( sObject objectItem : objects ) {
                    objectIds.add( (Id)objectItem.get('Id') );
                }
            }
            if( objectsIds != null ) {
                objectIds.addAll( objectsIds );
            }
            objectIds.remove( null );
            objectIds.addAll( objectIds );

            if( !objectIds.isEmpty() ) {
                for( Id objectId : objectIds ) {
                    if( projectRostersByRoleNameByParentId.get( objectId ) == null ) {
                        projectRostersByRoleNameByParentId.put( objectId, new Map<String, List<Project_Roster__c>>() );
                    }
                    if( !roleNames.isEmpty() ) {
                        Map<String, List<Project_Roster__c>> projectRostersByRoleName = projectRostersByRoleNameByParentId.get( objectId );
                        for( String roleName : roleNames ) {
                            if( projectRostersByRoleName.get( roleName ) == null ) {
                                projectRostersByRoleName.put( roleName, new List<Project_Roster__c>() );
                            }
                        }
                    }
                }

                List<Project_Roster__c> rostersFromDb = new List<Project_Roster__c>();
                String querySelect = 'SELECT Proposal__c, Project_Profile__c, Role__c, Contact__c, User__c, User_Contact__c FROM Project_Roster__c WHERE ';
                String queryLookup;
                if( objectname == Project_Profile__c.sObjectType || objectname == Proposal__c.sObjectType ) {
                    queryLookup = String.valueOf( objectname );
                }
                String queryWhere = ' IN : objectIds' + ( !roleNames.isEmpty()
                                                          ? ' AND Role__c IN : roleNames'
                                                          : '' );
                if( !String.isBlank( queryLookup ) ) {
                    for( Project_Roster__c roster : Database.query( querySelect + queryLookup + queryWhere ) ) {
                        Id objectId;
                        if( objectname == Project_Profile__c.sObjectType ) {
                            objectId = roster.Project_Profile__c;
                        } else if( objectname == Proposal__c.sObjectType ) {
                            objectId = roster.Proposal__c;
                        }
                        if( objectId != null ) {
                            Map<String, List<Project_Roster__c>> projectRostersByRoleName = projectRostersByRoleNameByParentId.get( objectId );
                            if( !roleNames.isEmpty() ) {
                                if( roleNames.contains( roster.Role__c ) ) {
                                    projectRostersByRoleName.get( roster.Role__c ).add( roster );
                                }
                            } else {
                                if( !projectRostersByRoleName.containsKey( roster.Role__c ) ) {
                                    projectRostersByRoleName.put( roster.Role__c, new List<Project_Roster__c>() );
                                }
                                projectRostersByRoleName.get( roster.Role__c ).add( roster );
                            }
                        }
                    }
                }
            }
        }
        return projectRostersByRoleNameByParentId;
    }

    public static void updateProjectRosterWithProposalCreatorDataFromProject( List<Project_Profile__c> projectsWithChangedCreator ) {
        Map<Id, Project_Profile__c> rosterIdToProjectForErrorHandling = new Map<Id, Project_Profile__c>();
        Map<Id, Map<String, List<Project_Roster__c>>> projectIdToRoleNameToRosters = ProjectRosterServices.getProjectRostersByRoleNameByParentId( Project_Profile__c.sObjectType,
                                                                                                                                                  projectsWithChangedCreator,
                                                                                                                                                  null,
                                                                                                                                                  new List<String>{ UserServices.ROLE_PROPOSAL_SPECIALIST } );
        Map<Id, Project_Roster__c> rosterIdToRoster = new Map<Id, Project_Roster__c>();

        for( Project_Profile__c project : projectsWithChangedCreator ) {
            List<Project_Roster__c> proposalSpecialists = projectIdToRoleNameToRosters.get( project.Id ).get( UserServices.ROLE_PROPOSAL_SPECIALIST );
            if( !proposalSpecialists.isEmpty() ) {
                for( Project_Roster__c roster : proposalSpecialists ) {
                    if( roster.User__c != project.Proposal_Specialist__c ) {
                        roster.User__c = project.Proposal_Specialist__c;
                        rosterIdToRoster.put( roster.Id, roster );
                        rosterIdToProjectForErrorHandling.put( roster.Id, project );
                    }
                }
            }
        }
        rosterIdToProjectForErrorHandling.remove(null);
        rosterIdToRoster.remove(null);

        List<Project_Roster__c> rostersToUpdate = rosterIdToRoster.values();
        try {
            UPDATE rostersToUpdate;
        } catch( DmlException dmlEx ) {
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                rosterIdToProjectForErrorHandling.get( rostersToUpdate[i].Id ).addError( 'Can not update Roster after changing Proposal Creator. ' + dmlEx.getMessage() );
            }
        }
    }

    public static void updateProjectRosterWithProposalCreatorDataFromProposal( List<Proposal__c> proposalsWithChangedCreator, List<Proposal__c> proposalsWithChangedOwner ) {
        Map<Id, Proposal__c> proposalsWithChangedCreatorOrOwner = new Map<Id, Proposal__c>( proposalsWithChangedOwner );
        proposalsWithChangedCreatorOrOwner.putAll( new Map<Id, Proposal__c>( proposalsWithChangedCreator ) );
        List<Project_Roster__c> rostersToUpdate = new List<Project_Roster__c>();

        if( !proposalsWithChangedCreatorOrOwner.isEmpty() ) {
            Id projectRosterUserRecordTypeId = projectRosterRecordTypeMap.get(TYPE_USER).Id;
            Map<Id, Map<String, List<Project_Roster__c>>> proposalIdToRoleNameToRosters = ProjectRosterServices.getProjectRostersByRoleNameByParentId( Proposal__c.sObjectType,
                                                                                                                                                       proposalsWithChangedCreatorOrOwner.values(),
                                                                                                                                                       null,
                                                                                                                                                       new List<String>{ UserServices.ROLE_PROPOSAL_SPECIALIST } );

            for( Proposal__c proposal : proposalsWithChangedCreatorOrOwner.values() ) {
                if( proposal.Project_Profile__c == null ) {
                    List<Project_Roster__c> proposalSpecialists = proposalIdToRoleNameToRosters.get( proposal.Id ).get( UserServices.ROLE_PROPOSAL_SPECIALIST );
                    if( !proposalSpecialists.isEmpty() ) {
                        for( Project_Roster__c roster : proposalSpecialists ) {
                            if( roster.User__c != proposal.Proposal_Specialist__c ) {
                                roster.User__c = proposal.Proposal_Specialist__c;
                                rostersToUpdate.add( roster );
                            }
                        }
                    } else {
                        rostersToUpdate.add( ProjectProfileServices.createAfterAssignProjectRoster( proposal.OwnerId, proposal.Project_Profile__c, proposal.Id, projectRosterUserRecordTypeId, UserServices.ROLE_PROPOSAL_SPECIALIST, null ) );
                    }
                }
            }

            try {
                UPSERT rostersToUpdate;
            } catch( DmlException dmlEx ) {
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                    proposalsWithChangedCreatorOrOwner.get( rostersToUpdate[i].Id ).addError( 'Can not update Roster after changing Proposal Creator. ' + dmlEx.getMessage() );
                }
            }
        }
    }

    public static Boolean isUserInRoster( Id userId, List<Project_Roster__c> rosters, List<ProposalWizardRosterWrapper> rosterWrappers ) {
        if( rosters != null && !rosters.isEmpty() ) {
            for( Project_Roster__c roster : rosters ) {
                if( roster.User__c == userId ) {
                    return true;
                }
            }
        } else if( rosterWrappers != null && !rosterWrappers.isEmpty() ) {
            for( ProposalWizardRosterWrapper roster : rosterWrappers ) {
                if( roster.record.User__c == userId ) {
                    return true;
                }
            }
        }
        return false;
    }

    public static Boolean isUserAllowedToChangeBillingPreferences( Id userId, String profileName, String roleName, Proposal__c proposal, List<ProposalWizardRosterWrapper> rosterWrappers, Boolean isFromCoRequestPage ) { /*MRS-6197*/
        Boolean isAllowed = profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                            profileName == UserServices.PROFILE_CFO ||
                            profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                            profileName == UserServices.PROFILE_FINANCE_MANAGER ||
                            profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR ||
                            profileName == UserServices.PROFILE_STAFF_ACCOUNTANT ||
                            profileName == UserServices.PROFILE_A_R_CORDINATOR ||
                            roleName == UserServices.ROLE_MANAGER_OF_ACCOUNTS ||
                            proposal.Project_Profile__r.Account_Executive__c == userId;
        if( isAllowed == false ) {
            if( isFromCoRequestPage == true ) {
                isAllowed = isAllowed || proposal.Project_Profile__r.Proposal_Specialist__c == userId;
            } else {
                isAllowed = isAllowed || proposal.Proposal_Specialist__c == userId;
            }
        }
        if( isAllowed == false ) {
            if( rosterWrappers != null ) {
                isAllowed = isAllowed || isUserInRoster( userId, null, rosterWrappers );
            } else {
                isAllowed = isAllowed || ProjectRosterServices.isUserInRoster( userId, ProjectRosterServices.getProjectRosterByProposalId( proposal.Id ), null );
            }
        }
        return isAllowed;
    }

    public static List<Project_Roster__c> sortRoster(String sortBy, String proposalId, String projectRosterId, Boolean onlyContact) {
        String query = 'Select Id, User__c, Name, User_Contact__c, User_Type__c, Role__c, Project_Profile__c, Phone__c, Name__c, Send_Reminder__c, Is_Read__c, Email__c, Contact__c, Contact_Account_Name__c, Contact__r.AccountId, User_Contact_IsActive__c,';
        query += ' RecordType.Name, RecordTypeId, Contact__r.Name, User__r.Name, Contact__r.Is_Active__c, Contact__r.DND__c, User__r.IsActive, LastModifiedDate, LastModifiedBy.Name, LastModifiedById, CreatedDate, ';//MRS-6716
        query += ' CreatedBy.Name, CreatedById, Is_Manually_Activated__c, Is_Manually_Deactivated__c, Active__c, Active_Tracking__c From Project_Roster__c ';//MRS-6716
        String queryWhere = 'Where Id != null ';
        if(String.isNotBlank(proposalId)) {
            queryWhere += 'And Proposal__c = \''+ proposalId +'\' ';
        } else if(String.isNotBlank(projectRosterId)) {
            queryWhere += 'And Project_Profile__c = \''+ projectRosterId + '\' ';
        }
        if(onlyContact) {
            Map<String, RecordType> recordTypeMap = ProjectRosterServices.getRecordType();
            queryWhere += 'AND RecordTypeId = \'' +recordTypeMap.get(ProjectRosterServices.TYPE_CONTACT).Id + '\' ';
        }
        query += queryWhere;
        if(String.isNotBlank(sortBy)) {
            query += 'ORDER BY ' + sortBy;
        }
        //system.debug(logginglevel.ERROR, '^^^query: '  + query);
        List<Project_Roster__c> prjectRosterList = Database.query(query);
        return prjectRosterList;
    }

    public static void populateDeactivationDate(List<Project_Roster__c> projectRosterListNew, Map<Id, Project_Roster__c> projectRosterOldMap){
        List<Project_Roster__c> filteredList = new List<Project_Roster__c>();

        for (Project_Roster__c projectRosterItem : projectRosterListNew){
            if (projectRosterItem.Active__c != null && !projectRosterItem.Active__c && projectRosterItem.Active__c != projectRosterOldMap.get(projectRosterItem.Id).Active__c){
                projectRosterItem.Deactivation_Date__c = Datetime.now();
                projectRosterItem.Active_Tracking__c = projectRosterItem.Active_Tracking__c == null ? 'Deactivated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now()) :
                                                                                                       projectRosterItem.Active_Tracking__c + '\'r\'n' + 'Deactivated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now());
            }
        }
    }

    public static void deactivateProjectRosters(List<Project_Roster__c> filteredProjectRosterList){
        if (filteredProjectRosterList.isEmpty()){return;}

        Map<Id, List<Project_Roster__c>> projectWithRostersMap = new Map<Id, List<Project_Roster__c>>();
        List<String> projectRosterId = new List<String>();

        for (Project_Roster__c projectRosterItem : filteredProjectRosterList){
            if(projectRosterItem.Role__c == null || (projectRosterItem.Contact__c == null && projectRosterItem.User__c == null)){continue;}
            projectRosterId.add(String.valueOf(projectRosterItem.Id));
            if (!projectWithRostersMap.containsKey(projectRosterItem.Project_Profile__c)){
                projectWithRostersMap.put(projectRosterItem.Project_Profile__c, new List<Project_Roster__c>{projectRosterItem});
            } else {
                projectWithRostersMap.get(projectRosterItem.Project_Profile__c).add(projectRosterItem);
            }
        }

        String queryString = 'SELECT Id, Active__c, Role__c, Contact__c, User__c FROM Project_Roster__c WHERE Active__c = true AND (NOT Id IN (\'' + String.join(projectRosterId, '\',\'') + '\') ) AND (';

        for (Id projectProfileId : projectWithRostersMap.keySet()){
            queryString += '(Project_Profile__c = \'' + String.valueOf(projectProfileId) + '\' AND (';
            for (Project_Roster__c projectRosterItem : projectWithRostersMap.get(projectProfileId)){
                queryString += '(Role__c = \'' + projectRosterItem.Role__c + '\' And ';
                queryString += projectRosterItem.Contact__c != null ? ' Contact__c = \'' + projectRosterItem.Contact__c + '\') Or ' : ' User__c = \'' + projectRosterItem.User__c + '\') Or ';
            }
            queryString = queryString.removeEnd(' Or ');
            queryString += ')) OR ';
        }
        queryString = queryString.removeEnd(' OR ') + ')';

        System.debug(LoggingLevel.ERROR, '^^^ Project RosterServices deactivateProjectRosters queryString = ' + queryString);

        List<Project_Roster__c> projectRosterList = Database.query(queryString);

        for (Project_Roster__c projectRosterItem : projectRosterList){
            projectRosterItem.Active__c = false;
        }

        update projectRosterList;
    }

    public static List<Id> filteredProjectsWithManualyAddedRosters(List<Project_Roster__c> projectRosterListNew){
        List<Id> filteredList = new List<Id>();

        for (Project_Roster__c projectRosterItem : projectRosterListNew){
            if (projectRosterItem.Project_Profile__c != null && projectRosterItem.Is_Manually_Added_Roster__c){
                filteredList.add(projectRosterItem.Project_Profile__c);
            }
        }

        return filteredList;
    }

    public static void deactivateOldRosters(List<Id> projectProfileIdList){
        if ( projectProfileIdList.isEmpty() ){ return; }

        updateRostersIsActiveState(projectProfileIdList, null, true, true, true, true);
    }

    public static List<Project_Profile__c> getProjectProfileListForUpdateActiveRosters(List<Id> projectProfileListId,
                                                                                       Boolean doGetRelatedServices,
                                                                                       Boolean doGetRelatedTasks,
                                                                                       Boolean doGetContactRosters,
                                                                                       Boolean doGetUserRosters){

        List<Project_Profile__c> projectProfileResultList = new List<Project_Profile__c>();

        if (projectProfileListId == null || projectProfileListId.isEmpty()){return projectProfileResultList;}

        String queryString = 'SELECT Id, Account_Executive__c, FREP__c, Partner__c, Production_Manager__c, Project_Member__c, Primary_Company_Contact__c, ' +
                             '      Billing_Company_Contact__c, Project_Manager__c, Proposal_Specialist__c, Resource__c, Salesperson__c, OwnerId, ' +
                             '      Proposal__r.OwnerId, Accounting_Contact__c';

        if ( doGetRelatedServices ){
            queryString += ', (Select Id, OwnerId From Service_Items__r Where Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\')';
        }

        if ( doGetRelatedTasks ){
            queryString += ', (Select Id, OwnerId ' +
                           '   From Task_Items__r ' +
                           '   Where RecordType.Name != \'' + TaskManagementServices.MILESTONE_RECORDTYPE_NAME + '\' And Service_Item__r.Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\')';
        }

        queryString += ',   (Select Id, Active__c, User__c, Contact__c, Role__c, LastModifiedDate, CreatedDate, Is_Manually_Added_Roster__c, Is_Manually_Activated__c, Is_Manually_Deactivated__c ' +
                       '     From Project_Rosters__r ';

        if (doGetContactRosters || doGetUserRosters){
            String doAddOr = '';
            queryString += 'Where ';
            if (doGetContactRosters){
                queryString += ' Contact__c != null ';
                doAddOr = ' Or ';
            }
            if (doGetUserRosters){
                queryString += doAddOr + ' User__c != null ';
            }
            queryString += '';
        }
        queryString += ' Order By CreatedDate Desc) ' +
                       ' FROM Project_Profile__c WHERE Id IN (\'' + String.join( projectProfileListId, '\',\'') + '\' )';

        System.debug(LoggingLevel.Error, '^^^ queryString = ' + queryString);

        try{
            projectProfileResultList = Database.query(queryString);
        } catch (Exception ex){}

        return projectProfileResultList;
    }

    public static void updateRostersIsActiveState(List<Id> projectProfileListId,
                                                  List<Project_Profile__c> projectProfileWithTaskServiceRosterList,
                                                  Boolean doGetRelatedServices,
                                                  Boolean doGetRelatedTasks,
                                                  Boolean doGetContactRosters,
                                                  Boolean doGetUserRosters){

        if ( projectProfileWithTaskServiceRosterList == null && projectProfileListId == null ){return;}

        if ( (projectProfileWithTaskServiceRosterList == null || projectProfileWithTaskServiceRosterList.isEmpty() ) && projectProfileListId != null ){
            projectProfileWithTaskServiceRosterList = getProjectProfileListForUpdateActiveRosters(projectProfileListId,
                                                                                                  doGetRelatedServices,
                                                                                                  doGetRelatedTasks,
                                                                                                  doGetContactRosters,
                                                                                                  doGetUserRosters);
        }

        if (projectProfileWithTaskServiceRosterList.isEmpty()){return;}

        List<Project_Roster__c> projectRosterUpdateList = new List<Project_Roster__c>();

        for (Project_Profile__c projectProfileItem : projectProfileWithTaskServiceRosterList){
            Map<Id, Project_Roster__c> projectRosterSatusMap = ProjectProfileServices.getProjectRosterStatusOnlyValid(projectProfileItem, doGetRelatedServices, doGetRelatedTasks);
            for(Project_Roster__c projectRoster : projectProfileItem.Project_Rosters__r){
                if ( !projectRosterSatusMap.containsKey(projectRoster.Id) || projectRosterSatusMap.get(projectRoster.Id) == null ){
                    if ( projectRoster.Active__c == null || projectRoster.Active__c ) projectRosterUpdateList.add(new Project_Roster__c( Id = projectRoster.Id, Active__c = false ));
                } else if (projectRosterSatusMap.containsKey(projectRoster.Id) && projectRosterSatusMap.get(projectRoster.Id) != null){
                    if ( projectRoster.Active__c != null && !projectRoster.Active__c && !projectRoster.Is_Manually_Deactivated__c ) projectRosterUpdateList.add(new Project_Roster__c( Id = projectRoster.Id, Active__c = true ));
                }
            }
        }

        if (!projectRosterUpdateList.isEmpty()){
            try{
                update projectRosterUpdateList;
            } catch (DMLException dmlEx){
                throw new ErrorException('Error occured during updating Project Roster Active field ' + dmlEx.getMessage());
            }
        }
    }

    //MRS-6851
    public static List<Project_Roster__c> filteredProjectRosterForProjectAssignment(List<Project_Roster__c> newList, Map<Id, Project_Roster__c> oldMap){
        List<Project_Roster__c> filteredServiceItemList = new List<Project_Roster__c>();

        for (Project_Roster__c projectRosterItem : (newList != null) ? newList : oldMap.values()){
            if ( projectRosterItem.Role__c != null &&
                 projectRosterItem.Project_Profile__c != null &&
                 projectRosterItem.User__c != null &&
                 projectRosterItem.User_Contact_IsActive__c &&
                 (ProjectProfileServices.ROLENAMESFORPROJECTASSIGNMENT.contains(projectRosterItem.Role__c) || projectRosterItem.Role__c.contains(UserServices.ROLE_CZ_MANAGER) ) &&
                 ( ( (oldMap == null || newList == null ) && projectRosterItem.Active__c ) || (oldMap != null && projectRosterItem.Active__c != oldMap.get(projectRosterItem.Id).Active__c ) ) ){

                filteredServiceItemList.add(projectRosterItem);
            }
        }

        return filteredServiceItemList;
    }

    //MRS-7487
    public static Boolean rosterIsGoingFromWizard = false;

    public static List<Project_Roster__c> filteredSIPSManagerProjectRosters( List<Project_Roster__c> projectRosterListNew ){
        List<Project_Roster__c> filteredList = new List<Project_Roster__c>();

        for (Project_Roster__c projectRosterItem : projectRosterListNew){
            if ( projectRosterItem.Project_Profile__c != null && projectRosterItem.Role__c == SIPS_DEPARTMENT_MANAGER_ROLE && projectRosterItem.User__c != null ){
                filteredList.add( projectRosterItem );
            }
        }

        return filteredList;
    }

	public static void createSIPSTeamRosters( List<Project_Roster__c> filteredList ){
		if( filteredList.isEmpty() ) return;

        List<Project_Roster__c> newRostersList = new List<Project_Roster__c>();
        List<User> sipsUsersList = [Select UserRole.Name, UserRoleId, Profile.Name, ProfileId, Name, IsActive, Id
        							From User u
        							Where Profile.Name like '%SIPS%'
        								AND IsActive = true];

        for( Project_Roster__c projectRosterItem : filteredList ){
        	for( User userItem: sipsUsersList ){
        		if( userItem.Id != projectRosterItem.User__c ){
        			Project_Roster__c newRoster = projectRosterItem.clone(false, false, false, false);
        			newRoster.Role__c = userItem.UserRole.Name;
        			newRoster.User__c = userItem.Id;
				newRoster.Key__c = null;
				newRoster.Is_Manually_Activated__c = true;

        			newRostersList.add( newRoster );
        		}
        	}
        }
		ProjectRosterServices.rosterIsGoingFromWizard = false;
        if( !newRostersList.isEmpty() ) insert newRostersList;
    }

}