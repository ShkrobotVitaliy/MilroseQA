trigger ScanRequestTrigger on Scan_Request__c (before insert, before update) {

    if( Trigger.isBefore ) {
        if( Trigger.isInsert || Trigger.isUpdate ) {
            ScanRequestServices.populateRelatedObjectId( ScanRequestServices.filterScanRequestsForRelatedObjectIdPopulation( Trigger.new, Trigger.oldMap ) );
        }
    }

}