public with sharing class BuildingServices {
    /* ------------------------------------ Begin Bussiness Logic ------------------------- */
    public static List<SelectOption> getBuildinOptionsByBuildingId(Id buildingId) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-- None --', '-- None --'));
        
        if (String.isBlank(buildingId)) {
            return options;
        
        }        
        
        for (Building_AKA__c building : getBuildingAKAByBuildingId(buildingId)) {
            options.add(new SelectOption(building.Id, building.Name));
        
        }
        return options;
    
    }

	public static Map<Building__c, List<Boolean>> buildingsWithChangedOwnerOrManagerFilter(List<Building__c> newList, Map<Id, Building__c> oldMap) { //MRS 6888
		Map<Building__c, List<Boolean>> buildingsMap = new Map<Building__c, List<Boolean>>();
		for(Building__c b : newList) {
			if(oldMap.get(b.Id).Owner_Contact_1__c != b.Owner_Contact_1__c || oldMap.get(b.Id).Owner_Contact_2__c != b.Owner_Contact_2__c || oldMap.get(b.Id).Building_Manager__c != b.Building_Manager__c) {
				buildingsMap.put(b, new List<Boolean> { oldMap.get(b.Id).Owner_Contact_1__c != b.Owner_Contact_1__c,
														oldMap.get(b.Id).Owner_Contact_2__c != b.Owner_Contact_2__c,
														oldMap.get(b.Id).Building_Manager__c != b.Building_Manager__c});
			}
		}
		return buildingsMap;
	}

	public static void updateProjectRostersIfOwnerOrManagerChanged(Map<Building__c, List<Boolean>> buildingsMap) { //MRS 6888
		Set<Id> buildingIdSet = new Set<Id>();
		Map<Id, Building__c> buildingsAffectedMap = new Map<Id, Building__c>();
		for(Building__c b : buildingsMap.keySet()) {
			buildingIdSet.add(b.Id);
			buildingsAffectedMap.put(b.Id, b);
		}
		if(!buildingsAffectedMap.isEmpty()) {
			Map<Id, Project_Profile__c> projectsMap = new Map<Id, Project_Profile__c> ([SELECT Id, Building__c, Proposal__c,
																							(SELECT Id, Active__c, Role__c FROM Project_Rosters__r
																							 WHERE Active__c = true AND (Role__c = :ProjectRosterServices.BUILDING_OWNER_1
																													  OR Role__c = :ProjectRosterServices.BUILDING_OWNER_2
																													  OR Role__c = :ProjectRosterServices.BUILDING_MANAGER))
																						FROM Project_Profile__c
																						WHERE Building__c IN :buildingIdSet]);
			Map<Id,List<Id>> buildingIdToProjectIdMap = new Map<Id, List<Id>>();
			Map<Id, Map<String, List<Project_Roster__c>>> projectIdToRostersMap = new Map<Id, Map<String, List<Project_Roster__c>>>();

			for(Project_Profile__c p : projectsMap.values()) {
				if(buildingIdToProjectIdMap.get(p.Building__c) == null) buildingIdToProjectIdMap.put(p.Building__c, new List<Id>());
				buildingIdToProjectIdMap.get(p.Building__c).add(p.Id);
				projectIdToRostersMap.put(p.Id, new Map<String, List<Project_Roster__c>> {ProjectRosterServices.BUILDING_OWNER_1 => new List<Project_Roster__c>(),
																						  ProjectRosterServices.BUILDING_OWNER_2 => new List<Project_Roster__c>(),
																						  ProjectRosterServices.BUILDING_MANAGER => new List<Project_Roster__c>()});
				for(Project_Roster__c pRoster : p.Project_Rosters__r) {
					if(pRoster.Role__c == ProjectRosterServices.BUILDING_OWNER_1) {
						projectIdToRostersMap.get(p.Id).get(ProjectRosterServices.BUILDING_OWNER_1).add(pRoster);
					}
					if(pRoster.Role__c == ProjectRosterServices.BUILDING_OWNER_2) {
						projectIdToRostersMap.get(p.Id).get(ProjectRosterServices.BUILDING_OWNER_2).add(pRoster);
					}
					if(pRoster.Role__c == ProjectRosterServices.BUILDING_MANAGER) {
						projectIdToRostersMap.get(p.Id).get(ProjectRosterServices.BUILDING_MANAGER).add(pRoster);
					}
				}
				
			}

			Id contactProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_CONTACT);
			List<Project_Roster__c> rostersToUpdate = new List<Project_Roster__c>();

			for(Building__c building : buildingsMap.keySet()) {
				if(buildingIdToProjectIdMap.get(building.Id) != null) { //MRS 7486
					if(buildingsMap.get(building).get(0)) { //Owner_Contact_1__c has been changed
						for(Id projectId : buildingIdToProjectIdMap.get(building.Id)) {
							for(Project_Roster__c pRoster : projectIdToRostersMap.get(projectId).get(ProjectRosterServices.BUILDING_OWNER_1)) {
								rostersToUpdate.add(new Project_Roster__c(Id = pRoster.Id, Active__c = false));
							}
							if(building.Owner_Contact_1__c != null) {
								rostersToUpdate.add(ProjectProfileServices.createAfterAssignProjectRosterContact(building.Owner_Contact_1__c, projectId,
													projectsMap.get(projectId).Proposal__c, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_OWNER_1));
							}
						}
					}
					if(buildingsMap.get(building)[1]) { //Owner_Contact_2__c has been changed
						for(Id projectId : buildingIdToProjectIdMap.get(building.Id)) {
							for(Project_Roster__c pRoster : projectIdToRostersMap.get(projectId).get(ProjectRosterServices.BUILDING_OWNER_2)) {
								rostersToUpdate.add(new Project_Roster__c(Id = pRoster.Id, Active__c = false));
							}
							if(building.Owner_Contact_2__c != null) {
								rostersToUpdate.add(ProjectProfileServices.createAfterAssignProjectRosterContact(building.Owner_Contact_2__c, projectId,
									projectsMap.get(projectId).Proposal__c, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_OWNER_2));
							}
						}
					}
					if(buildingsMap.get(building)[2]) { //Building_Manager__c has been changed
						for(Id projectId : buildingIdToProjectIdMap.get(building.Id)) {
							for(Project_Roster__c pRoster : projectIdToRostersMap.get(projectId).get(ProjectRosterServices.BUILDING_MANAGER)) {
								rostersToUpdate.add(new Project_Roster__c(Id = pRoster.Id, Active__c = false));
							}
							if(building.Building_Manager__c != null) {
								rostersToUpdate.add(ProjectProfileServices.createAfterAssignProjectRosterContact(building.Building_Manager__c, projectId,
									projectsMap.get(projectId).Proposal__c, contactProjectRosterRecordTypeId, ProjectRosterServices.BUILDING_MANAGER));
							}
						}
					}
				}
			}

			if(!rostersToUpdate.isEmpty()) {
				try {
					UPSERT rostersToUpdate;
				} catch (DmlException e) {
					for(Building__c b : buildingsMap.keySet()) {
						b.addError('Next errors occured during updating linked Project Rosters' + e);
					}
				}
			}
		}
	}

	public static void formAdressAndCheckForDuplicates(List<Building__c> newList) { //MRS 7486
		Set<String> setOfNames = new Set<String>();
		List<Building__c> notADuplicateBuildings = new List<Building__c>();

		for(Building__c b : newList) {
			if(b.House_No__c != null && b.Street__c != null) b.Name = b.House_No__c + ' ' + b.Street__c;
			if(!b.Not_a_duplicate_building__c) {
				setOfNames.add(b.Name);
				notADuplicateBuildings.add(b);
			}
		}
		if(!setOfNames.isEmpty()) {
			Set<String> selectedNames = new Set<String>();
			for(Building__c b : [SELECT Name FROM Building__c WHERE Name IN :setOfNames]) {
				selectedNames.add(b.Name);
			}
			for(Building__c b : notADuplicateBuildings) {
				if(selectedNames.contains(b.Name)) b.addError('Another building with the exact same address already exists. If you have verified that this is not a duplicate then check the "Not a duplicate building" box before saving this record.');
			}
		}
	}

	public static void preventNotDuplicateChangeIfNameNotChanged(List<Building__c> newList, Map<Id, Building__c> oldMap) {
		for(Building__c b : newList) {
			if(b.Name == oldMap.get(b.Id).Name) {
				b.Not_a_duplicate_building__c = oldMap.get(b.Id).Not_a_duplicate_building__c;
			}
		}
	}
    /* ------------------------------------ End Bussiness Logic ------------------------- */

    /* ------------------------------------ Begin DAO Methods --------------------------- */
    
    public static List<Building_AKA__c> getBuildingAKAByBuildingId(Id buildingId) {
        if (String.isBlank(buildingId)) {
            throw new ErrorException('Parameter Building Id can not be empty.');
        
        }
        
        return new List<Building_AKA__c>([SELECT Id, Building__c, Name
                                          FROM Building_AKA__c
                                          WHERE Building__c =: buildingId]);
    
    }
    
    /* ------------------------------------ End DAO Methods --------------------------- */
    
    public static Building__c getBuildingById(Id buildingId) {
        List<Building__c> buildingList = [Select Id From Building__c Where Id = : buildingId];
        Building__c building = new Building__c();
        if(buildingList.size() > 0) {
            building = buildingList.get(0);
        }
        return building;
    }
    
}