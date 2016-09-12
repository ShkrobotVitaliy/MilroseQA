public with sharing class ProjectRosterAtProjectRelatedListContExt {
    private static final String PROJECT_ROSTER_ENT_PREFIX = 'Project_Roster_Recort_Type_Ent_Prefix';

    private final Project_Profile__c projectProfile;

	public List<Project_Roster__c> projectRosterList {
        get {
            if (null == this.projectRosterList) {
                this.projectRosterList = new List<Project_Roster__c>();
                Map<String, Map<Id, Project_Roster__c>> rolePersonRSterMap = new Map<String, Map<Id, Project_Roster__c>>();
                for (Project_Roster__c projectRoster : ProjectRosterServices.getProjectRosterByProjectProfileId(this.projectProfile.Id)){
                    if (!rolePersonRSterMap.containsKey(projectRoster.Role__c)){
                        rolePersonRSterMap.put(projectRoster.Role__c, new Map<Id, Project_Roster__c>());
                    }
                    if ( ( projectRoster.User__c != null && !rolePersonRSterMap.get(projectRoster.Role__c).containsKey(projectRoster.User__c) ) ||
                         ( projectRoster.Contact__c != null && !rolePersonRSterMap.get(projectRoster.Role__c).containsKey(projectRoster.Contact__c) )){
                        rolePersonRSterMap.get(projectRoster.Role__c).put(projectRoster.User__c != null ? projectRoster.User__c : projectRoster.Contact__c, projectRoster);
                    } else {
                        Project_Roster__c pr = (rolePersonRSterMap.get(projectRoster.Role__c)).get(projectRoster.User__c != null ? projectRoster.User__c : projectRoster.Contact__c);
                        if ((!pr.Active__c && projectRoster.Active__c) || (!pr.Active__c && pr.CreatedDate < projectRoster.CreatedDate)){
                            rolePersonRSterMap.get(projectRoster.Role__c).put(projectRoster.User__c != null ? projectRoster.User__c : projectRoster.Contact__c, projectRoster);
                        }
                    }
                }
                List<String> sortedRoleNameList = new List<String>();
                sortedRoleNameList.addAll(rolePersonRSterMap.keySet());
                sortedRoleNameList.sort();

                for (String roleItem : sortedRoleNameList){
                    Map<Id, Project_Roster__c> prRosMap = rolePersonRSterMap.get(roleItem);
                    this.projectRosterList.addAll(rolePersonRSterMap.get(roleItem).values());
                }
            }
            return this.projectRosterList;

        }
        set;
    }

    public Boolean renderedButtonOrLink { get; set; }

    public String redirectUrl {
        get {
            if (String.isBlank(this.redirectUrl)) {
                ProjectRosterObject__c customSettingPojectRoster = ProjectRosterObject__c.getValues(PROJECT_ROSTER_ENT_PREFIX);

                PageReference redirect = new PageReference('/setup/ui/recordtypeselect.jsp');
                redirect.getParameters().put('ent', customSettingPojectRoster.Project_Roster_Object_Id__c);
                redirect.getParameters().put('retURL', this.projectProfile.Id);
                redirect.getParameters().put('save_new_url', '/' + Schema.SObjectType.Project_Roster__c.getKeyPrefix() +
                                             '/e?' + customSettingPojectRoster.ProjectRoster_Field_Id__c + '=' + this.projectProfile.Name + '&' + customSettingPojectRoster.ProjectRoster_Field_Id__c +
                                             '_lkid=' + this.projectProfile.Id + '&' + customSettingPojectRoster.Manualy_Added_Field_Id__c + '=1' +
                                             '&retURL=' + this.projectProfile.Id);

                redirect.getParameters().put('saveURL', '/' + this.projectProfile.Id);
                redirect.setRedirect(true);
                this.redirectUrl = redirect.getUrl();

            }
            return this.redirectUrl;

        }
        private set;

    }

    private Profile profile {
        get {
            if (null == this.profile) {
                this.profile = UserServices.getProfile();

            }
            return this.profile;

        }
        set;

    }

    public sortExtension sortAssignmentExtension {
        get {
            if (null == this.sortAssignmentExtension) {
				this.sortAssignmentExtension = new sortExtension('Active__c'); // MRS 7179
				this.sortAssignmentExtension.setSortDirection('DESC');
            }
            return this.sortAssignmentExtension;

        }
        private set;

    }

    public String primaryClientContact {
        get {
            return ProjectRosterServices.PRIMARY_CLIENT_CONTACT;

        }

    }

    public String billingClientContact {
        get {
            return ProjectRosterServices.BILLING_CLIENT_CONTACT;

        }

    }

    //MRS-7454
    public String accountingClientContact {
        get {
            return ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT;

        }

    }

    public ProjectRosterAtProjectRelatedListContExt(ApexPages.StandardController controller) {
        this.projectProfile = (Project_Profile__c)controller.getRecord();

        this.renderedButtonOrLink = this.projectProfile.Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED &&
        							( this.profile.Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                                    this.profile.Name == UserServices.SYSTEM_ADMINISTRATOR ||
                                    this.profile.Name == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                                    this.profile.Name == UserServices.PROFILE_OPERATIONS_MANAGER ||
                                    this.profile.Name == UserServices.SUPPORT_STAFF || // MRS-6924
                                    this.projectProfile.Project_Manager__c   == UserInfo.getUserId() ||
                                    this.projectProfile.Account_Executive__c == UserInfo.getUserId() ||
                                    this.projectProfile.FREP__c              == UserInfo.getUserId() ||
                                    this.projectProfile.Project_Member__c    == UserInfo.getUserId() ||
                                    this.projectProfile.OwnerId              == UserInfo.getUserId() ||
                                    this.projectProfile.Resource__c          == UserInfo.getUserId() );

        for (Project_Roster__c pr : this.projectRosterList) {
            if (//pr.User_Type__c == ProjectRosterServices.USER_TYPE_EX && pr.Contact__r.OwnerId == UserInfo.getUserId() ||
                pr.User_Type__c != ProjectRosterServices.USER_TYPE_EX && pr.User__c == UserInfo.getUserId()) {
                    this.renderedButtonOrLink = true;
                    break;

            }
        }

		sortAction(); // MRS 7179	

    }

    public PageReference addToTheRosterAction() {
        return null;

    }

    public String rosterIdToDelete { get; set; }

    public void removeRosterAction() {
        if(String.isNotBlank(rosterIdToDelete)) {
            Map<Id, Project_Roster__c> projectRosterMap = new Map<Id, Project_Roster__c>(this.projectRosterList);

            if (!projectRosterMap.containsKey(rosterIdToDelete)) {
                return;
            }

            Savepoint sp = Database.setSavepoint();
            try {
                Project_Roster__c projectRosterForDelete = projectRosterMap.get(rosterIdToDelete);

                List<Project_Roster__c> projectRosterDeleteList = new List<Project_Roster__c>([SELECT Id
                                                                                               FROM Project_Roster__c
                                                                                               WHERE Project_Profile__c = : projectRosterForDelete.Project_Profile__c AND
                                                                                                    Role__c = : projectRosterForDelete.Role__c AND
                                                                                                    User__c = : projectRosterForDelete.User__c AND
                                                                                                    Contact__c = : projectRosterForDelete.Contact__c]);

                if (!projectRosterDeleteList.isEmpty()){
                    delete projectRosterDeleteList;
                }
            } catch(Exception e) {
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ErrorException.ROSTER_CANNOT_BE_DELETED));
            }

            projectRosterMap.remove(rosterIdToDelete);
            this.projectRosterList = projectRosterMap.values();
        }
    }

    public String rosterIdToActivationOrDeactivation { get; set; }

    public void activateRosterAction() {
        if(String.isNotBlank(rosterIdToActivationOrDeactivation)) {
            Map<Id, Project_Roster__c> projectRosterMap = new Map<Id, Project_Roster__c>(this.projectRosterList);

            if (!projectRosterMap.containsKey(rosterIdToActivationOrDeactivation)) {
                return;
            }

            Project_Roster__c projectRosterForActivate = projectRosterMap.get(rosterIdToActivationOrDeactivation).clone(true, true, true, true);

            Savepoint sp = Database.setSavepoint();
            try {

                List<Project_Roster__c> projectRosterDeactivationList = new List<Project_Roster__c>([SELECT Id, Active__c, Is_Manually_Activated__c, Is_Manually_Deactivated__c, Active_Tracking__c
                                                                                                     FROM Project_Roster__c
                                                                                                     WHERE Project_Profile__c = : projectRosterForActivate.Project_Profile__c AND
                                                                                                          Role__c = : projectRosterForActivate.Role__c AND
                                                                                                          User__c = : projectRosterForActivate.User__c AND
                                                                                                          Contact__c = : projectRosterForActivate.Contact__c AND
                                                                                                          Active__c = true]);

                for (Project_Roster__c projectRosterItem : projectRosterDeactivationList){
                    projectRosterItem.Active__c = false;
                    projectRosterForActivate.Is_Manually_Activated__c = false;
                    projectRosterForActivate.Is_Manually_Deactivated__c = false;
                }

                if (projectRosterForActivate.Active__c){
                    projectRosterForActivate.Active__c = false;
                    projectRosterForActivate.Is_Manually_Activated__c = false;
                    projectRosterForActivate.Is_Manually_Deactivated__c = true;
                    projectRosterForActivate.Active_Tracking__c = projectRosterForActivate.Active_Tracking__c == null ? 'Manually Deactivated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now()) :
                                                                                                       projectRosterForActivate.Active_Tracking__c + '\'r\'n' + 'Manually Deactivated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now());
                } else {
                    projectRosterForActivate.Active__c = true;
                    projectRosterForActivate.Is_Manually_Activated__c = true;
                    projectRosterForActivate.Is_Manually_Deactivated__c = false;
                    projectRosterForActivate.Active_Tracking__c = projectRosterForActivate.Active_Tracking__c == null ? 'Manually Activated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now()) :
                                                                                                       projectRosterForActivate.Active_Tracking__c + '\'r\'n' + 'Manually Activated by: ' + String.valueOf(UserInfo.getUserId()) + ' at: ' + String.valueOf(Datetime.now());
                }

                projectRosterDeactivationList.add(projectRosterForActivate);

                update projectRosterForActivate;

            } catch(Exception e) {
                Database.rollback(sp);
                projectRosterForActivate = projectRosterMap.get(rosterIdToActivationOrDeactivation);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Can not Deactivate/Activate this roster' + e.getMessage()));
            }

            rosterIdToActivationOrDeactivation = null;
            projectRosterMap.put(projectRosterForActivate.Id, projectRosterForActivate);
            this.projectRosterList = projectRosterMap.values();
        }
    }

    public void sortAction() {
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getSortDirection();
        Set<Id> projectRostersWithoutDuplicates = new Map<Id, Project_Roster__c>(this.projectRosterList).keySet();
        this.projectRosterList = new List<Project_Roster__c>();
        for (Project_Roster__c projectRoster : ProjectRosterServices.sortRoster(sortBy, null, this.projectProfile.Id, false)){
            if ( projectRostersWithoutDuplicates.contains(projectRoster.Id) ){
                this.projectRosterList.add(projectRoster);
            }
        }
    }

}