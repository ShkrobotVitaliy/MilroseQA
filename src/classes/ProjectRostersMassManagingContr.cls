public with sharing class ProjectRostersMassManagingContr {

	public static Map<Id, User> allUsers { set; get {
			if(allUsers == null) allUsers = new Map<Id, User> ([SELECT Id, Name FROM User]);
			return allUsers;
		}
	}

	public Boolean wholeListSelected {set;get;}

	public Boolean isDeleteDisabled {set;
		get {
			for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) return false;
			return true;
		}
	}

	public Boolean isChangingDisabled {set;
		get {
			for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) return false;
			return true;
		}
	}

	public Boolean isAnyRosterSelected {set;
		get {
			for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) return false;
			return true;
		}
	}

	public Boolean isSelectAllDisabled {set;
		get {
			return rostersToShow.isEmpty() ? true : false;
		}
	}

	public Boolean contactToIsEmpty {set;
		get {
			return String.isBlank(changePersonTo.Contact__c);	
		}
	}

	public class RosterWrapper {
		public Boolean isMutable { set; get {
				return roster != null && !String.isBlank(roster.Role__c)
					&& !roster.Role__c.equals('Primary Client Contact')
					&& !roster.Role__c.equals('Billing Client Contact (Bill To)')
					&& !roster.Role__c.equals('Accounting Contact (Mail To)');
			}
		}
		public Project_Roster__c roster {set;get;}
		public Boolean selected {set;get;}
		public String owner { set; get {
				if(roster != null && roster.Project_Profile__c != null) {
					return allUsers.get(roster.Project_Profile__r.OwnerId).Name;
				} else {
					return '';
				}
			}
		}
		RosterWrapper(Project_Roster__c roster) {
			this.roster = roster;
			selected = false;
		}
	}

	public Project_Roster__c filter {set;
		get {
			if(filter == null) filter = new Project_Roster__c ();
			filter.RecordTypeId ='012A0000000zcPMIAY'; // MRS 7269
			filter.User_Type__c = 'External';
			return filter;
		}
	}
	
	public Project_Roster__c changePersonTo {set; get; }

	private List<Project_Roster__c> getRostersFromDB() {
		String queryS = 'SELECT Project_Profile__c,'
			+' Project_Profile__r.Name, Project_Profile__r.Project_Name__c, Project_Profile__r.Project_Team__r.Name, Project_Profile__r.OwnerId, Project_Profile__r.Project_State__c, Project_Profile__r.Address_Building_AKA__c,' //MRS 7390
			+' Role__c, Active__c, Contact__r.Account.Name, Project_Profile__r.A_R_Coordinator_Full_Name__c FROM Project_Roster__c WHERE Project_Profile__c != null';
		queryS += !String.isBlank(filter.Contact__c) ? ' AND Contact__c = \'' + filter.Contact__c + '\'' : '';
		queryS += !String.isBlank(filter.Role__c) ? ' AND Role__c = \'' + filter.Role__c + '\'' : '';
		return (List<Project_Roster__c>) Database.query(queryS);
	}

	public List<RosterWrapper> rostersToShow {set;
		get {
			if(rostersToShow == null) {
				rostersToShow = new List<RosterWrapper> ();
				if(!String.isBlank(filter.Contact__c)) for(Project_Roster__c pr : getRostersFromDB()) rostersToShow.add(new RosterWrapper(pr));
			}
			return rostersToShow;
		}
	}
	
	public ProjectRostersMassManagingContr() {
		wholeListSelected = false;
		changePersonTo = new Project_Roster__c ();
	}

	public void inverseWholeList() {
		for(RosterWrapper rw : rostersToShow) {
			if(rw.isMutable) rw.selected = wholeListSelected;
		}
	}

	public void updateRosters() {
		if(String.isBlank(filter.Contact__c)) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contact has to be populated for searching.'));
			return;
		}
		wholeListSelected = false;
		rostersToShow = null;
	}

	public void deleteSelectedRosters() {
		List<Project_Roster__c> rostersToDelete = new List<Project_Roster__c> ();
		for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) rostersToDelete.add(tRW.roster);
		delete rostersToDelete;
		wholeListSelected = false;
		rostersToShow = null;
	}

	public void inactivateSelectedRosters() {
		List<Project_Roster__c> rostersToInactivate = new List<Project_Roster__c>();
		for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) rostersToInactivate.add(new Project_Roster__c(Id = tRW.roster.Id, Active__c = false));
		update rostersToInactivate;
		wholeListSelected = false;
		rostersToShow = null;
	}

	public void changePerson() {
		
		List<Project_Roster__c> rostersToUpdate = new List<Project_Roster__c> ();	
		if(String.isBlank(changePersonTo.Contact__c)) { 
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contact has to be populated.'));
			return;
		}

		for(RosterWrapper tRW : rostersToShow) if(tRW.selected == true) {
			rostersToUpdate.add(new Project_Roster__c(Id = tRW.roster.Id, Contact__c = changePersonTo.Contact__c));
		}

		update rostersToUpdate;

		wholeListSelected = false;
		rostersToShow = null;

    }

}