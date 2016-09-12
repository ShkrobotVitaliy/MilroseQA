trigger FormItemTrigger on Form_Item__c (after insert, before update, after update) {
    if( Trigger.isBefore ) FormItemsServices.filteredFormItemsByStatusAndChangeCurrentTask( Trigger.new, Trigger.oldMap );
    if( Trigger.isAfter ) {
        if( Trigger.isInsert ) {
            FormAssignmentsServices.createFormAssignments( Trigger.new );
            FormSignaturesServices.createFormSignatures( Trigger.new );
            
            if (FormMetaDataObject1Services.allowCreateMetaDataObjectRecords) {
                FormMetaDataObject1Services.createMetaDataObjectRecords( Trigger.new );
            
            }
        
        }
        
        if( Trigger.isUpdate ) {
        	FormAssignmentsServices.updateFormAssignmentsStatus( FormItemsServices.filteredFormItemsIdsWithFilledOutStatusChangedTo( Trigger.new, Trigger.oldMap ) );
        }
    }
}