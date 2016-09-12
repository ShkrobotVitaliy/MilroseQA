public class ProjectRosterAtProposal{
    public Proposal__c proposal { get; set; }
    public List<Project_Roster__c> projectRosterList { get; set; }
    public String redirectUrl { get; set; }

    public Boolean renderedEmailAndPhone {
        get {
            if(renderedEmailAndPhone == null) {
                renderedEmailAndPhone = true;
                Profile profile = UserServices.getProfile();
                if(profile.Name == UserServices.PROFILE_PROPOSAL_SPECIALIST) {
                    renderedEmailAndPhone = false;
                }
            }
            return renderedEmailAndPhone;
        }
        set;
    }

    public sortExtension sortAssignmentExtension {
        get {
            if(sortAssignmentExtension == null) {
                sortAssignmentExtension = new sortExtension('Name__c');
            }
            return sortAssignmentExtension;
        }
        set;
    }

    public ProjectRosterAtProposal ( ApexPages.StandardController controller) {
        proposal = (Proposal__c) controller.getRecord();

        projectRosterList = uniqueRosters(ProjectRosterServices.getProjectRosterOnlyContactByProposalId(proposal.Id));

        ProjectRosterObject__c countries = ProjectRosterObject__c.getValues('Project_Roster_Recort_Type_Ent_Prefix');
        PageReference redirect = new PageReference('/setup/ui/recordtypeselect.jsp');
        redirect.getParameters().put('ent', countries.Project_Roster_Object_Id__c);
        redirect.getParameters().put('retURL', this.proposal.Id);
        redirect.getParameters().put('save_new_url', '/'+Schema.SObjectType.Project_Roster__c.getKeyPrefix()+'/e?'+countries.ProjectRoster_Field_Id__c+'='+this.proposal.Name+'&'+countries.ProjectRoster_Field_Id__c+'_lkid='+this.proposal.Id+'&retURL='+this.proposal.Id);
        redirect.getParameters().put('saveURL', '/'+this.proposal.Id);
        redirect.setRedirect(true);
        redirectUrl = redirect.getUrl();
        system.debug('redirectUrl: ' + redirectUrl);
    }

    public static List<Project_Roster__c> uniqueRosters(List<Project_Roster__c> fullProjectRosterList){
        List<Project_Roster__c> projectRosterResultList = new List<Project_Roster__c>();
        //MRS-7522
        Map<String, Map<Id, Project_Roster__c>> roleWithContactWithRoster = new Map<String, Map<Id, Project_Roster__c>>();
        for (Project_Roster__c projectRosterItem : fullProjectRosterList){
            if ( projectRosterItem.Contact__c == null ){
                continue;
            }
            if ( !roleWithContactWithRoster.containsKey(projectRosterItem.Role__c) ){
                roleWithContactWithRoster.put(projectRosterItem.Role__c, new Map<Id, Project_Roster__c>{projectRosterItem.Contact__c => projectRosterItem});
            } else if ( !roleWithContactWithRoster.get(projectRosterItem.Role__c).containsKey( projectRosterItem.Contact__c ) ){
                roleWithContactWithRoster.get(projectRosterItem.Role__c).put(projectRosterItem.Contact__c, projectRosterItem);
            } else {
                Project_Roster__c pr = (roleWithContactWithRoster.get(projectRosterItem.Role__c)).get(projectRosterItem.Contact__c);
                if (pr.CreatedDate < projectRosterItem.CreatedDate ){
                    roleWithContactWithRoster.get(projectRosterItem.Role__c).put(projectRosterItem.Contact__c, projectRosterItem);
                }
            }
        }

        Set<Id> uniqueRosterIds = new Set<Id>();
        for (Map<Id, Project_Roster__c> contactWithRosters : roleWithContactWithRoster.values() ){
            for ( Project_Roster__c projectRosterItem : contactWithRosters.values() ){
                uniqueRosterIds.add(projectRosterItem.Id);
            }
        }

        for (Project_Roster__c projectRosterItem : fullProjectRosterList){
            if (uniqueRosterIds.contains(projectRosterItem.Id)){
                projectRosterResultList.add(projectRosterItem);
            }
        }

        return projectRosterResultList;
    }

    public void sortAction() {
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getSortDirection();
        projectRosterList = uniqueRosters(ProjectRosterServices.sortRoster(sortBy, proposal.Id, null, true));
    }

    public PageReference addToTheRosterAction() {
        return null;
    }
}