trigger BuildingTrigger on Building__c (after insert, after update, before insert, before update) { //MRS-6915
	if(Trigger.isBefore) { //MRS 7486
		if(Trigger.isInsert) {
			BuildingServices.formAdressAndCheckForDuplicates(Trigger.new);
		}
		if(Trigger.isUpdate) {
			BuildingServices.preventNotDuplicateChangeIfNameNotChanged(Trigger.new, Trigger.oldMap);
		}
	}
	if( Trigger.isAfter ) {
    StoredDocumentServices.createFolders(StoredDocumentServices.filterIfFoldersCreated(Trigger.newMap.keySet()));
		if(Trigger.isUpdate) { //MRS 6888
			BuildingServices.updateProjectRostersIfOwnerOrManagerChanged(BuildingServices.buildingsWithChangedOwnerOrManagerFilter(Trigger.new, Trigger.oldMap));
		}
    }
}