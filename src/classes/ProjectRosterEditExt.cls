public with sharing class ProjectRosterEditExt{
    private static final String PROJECT_ROSTER_ENT_PREFIX = 'Project_Roster_Recort_Type_Ent_Prefix';

    public Project_Roster__c projectRoster{get;set;}

    public ProjectRosterEditExt(ApexPages.StandardController controller) {
        this.projectRoster = (Project_Roster__c)controller.getRecord();
        if (this.projectRoster.id == null){
            this.projectRoster.Is_Manually_Added_Roster__c = true;
        } else {
            this.projectRoster = [SELECT Id, Name, RecordType.Name, RecordTypeId, Project_Profile__c, Project_Profile__r.Name, Proposal__c,
                                        User__c, Active__c, User_Type__c, Mi3_Roster_ID__c, Is_Manually_Added_Roster__c,
                                        Initially_Added_Roster__c, Contact__c, Role__c
                                  FROM Project_Roster__c
                                  WHERE Id = : this.projectRoster.Id][0];
        }
    }

    public PageReference saveAction(){
        upsert this.projectRoster;
        PageReference pr = new PageReference('/' + this.projectRoster.Project_Profile__c);
        pr.setRedirect(true);
        return pr;
    }


    public PageReference saveAndNew() {
        upsert this.projectRoster;
        ProjectRosterObject__c customSettingPojectRoster = ProjectRosterObject__c.getValues(PROJECT_ROSTER_ENT_PREFIX);

        PageReference pr = new PageReference('/setup/ui/recordtypeselect.jsp');
        pr.getParameters().put('ent', customSettingPojectRoster.Project_Roster_Object_Id__c);
        pr.getParameters().put('retURL', this.projectRoster.Project_Profile__c);
        pr.getParameters().put('save_new_url', '/' + Schema.SObjectType.Project_Roster__c.getKeyPrefix() +
                                     '/e?' + customSettingPojectRoster.ProjectRoster_Field_Id__c + '=' + this.projectRoster.Project_Profile__r.Name + '&' + customSettingPojectRoster.ProjectRoster_Field_Id__c +
                                     '_lkid=' + this.projectRoster.Project_Profile__c + '&' + customSettingPojectRoster.Manualy_Added_Field_Id__c + '=1' +
                                     '&retURL=' + this.projectRoster.Project_Profile__c);

        pr.getParameters().put('saveURL', '/' + this.projectRoster.Project_Profile__c);
        pr.setRedirect(true);
        return pr;
    }
}