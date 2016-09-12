trigger FormMetaDataObject1Trigger on Form_Meta_Data_Object_1__c ( before insert, before update ) {

	if ( Trigger.isBefore ) {

		FormMetaDataObject1Services.populateBuildingFields ( FormMetaDataObject1Services.filterFormMetaDataRecordsChangeBuilding( Trigger.new, Trigger.oldMap ) );

		if ( Trigger.isUpdate ) {

			FormMetaDataObject1Services.populateSignatoriesFields( FormMetaDataObject1Services.filterFormMetaDataRecordsChangeSignatory( Trigger.new, Trigger.oldMap ) );

		}

	}
}