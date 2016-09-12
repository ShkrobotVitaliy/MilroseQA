trigger SmartSearchTrigger on Smart_Search__c (after insert, after update, before delete) {
	if( Trigger.isInsert ){
		SmartSearchServices.createJunctionsAndPopulateSearchFields( Trigger.New[0] );
	}
	if( Trigger.isUpdate ){
		SmartSearchServices.updateAccountOrBuildingAfterSSupdating( Trigger.Old[0], Trigger.New[0] );
	}
	if( Trigger.isDelete ){
		SmartSearchServices.cleanAccountOrBuildingAfterSSdeleting( Trigger.Old[0] );
	}

}