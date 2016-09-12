trigger TaskItemTrigger on Task_Item__c ( before insert, after insert, before update, after update ) {
    if( Trigger.isBefore && Trigger.isUpdate ){
        if ( !TaskItemServices.runInFutureMethod ){
            TaskItemServices.checkIfServiceItemsCount( Trigger.new, Trigger.oldMap );
        } else {//MRS-6815
            TaskItemServices.avoidValidationRuleInFuture(Trigger.new);
        }
    }

    if( Trigger.isBefore && Trigger.isUpdate ){
        TaskItemServices.updateActualStartEndDate( Trigger.new, Trigger.oldMap );
        //MRS-6903
        TaskItemServices.updateDisapprovedDate( TaskItemServices.filteredTaskItemWithDisapprovedStatus(Trigger.new, Trigger.oldMap) );
		TaskItemServices.preventChangingOwnerOnCopletedTasks(Trigger.new, Trigger.oldMap); //MRS 7379
    }

    Map<String, Map<Id, Task_Item__c>> filteredTasksWithDateField = new Map<String, Map<Id, Task_Item__c>>();
    if( Trigger.isUpdate && !TaskItemServices.taskCalculationPreventor ) {
        filteredTasksWithDateField = TaskItemServices.filterTasksWithUpdatedActualDate( Trigger.new, Trigger.oldMap );
    }

    if( Trigger.isBefore ) {
        TaskItemServices.setLowercaseExpectedDuration( Trigger.new, Trigger.oldMap );
        if( Trigger.isUpdate && !TaskItemServices.taskCalculationPreventor ) {
            if ( !TaskItemServices.isCalculateActualValuesInFuture ){
                // Changed Actual Start Date - WORKS ONLY FOR ONE TASK ITEM (MANUAL UPDATING OF TASK)!!!
                if( filteredTasksWithDateField.get( TaskItemServices.START_DATE_FIELD ).size() == 1 ) {
                    TaskItemServices.updateExpectedDatesForAllServices(  filteredTasksWithDateField.get( TaskItemServices.START_DATE_FIELD ), true );
                } // Changed Actual End Date
                else if( ! filteredTasksWithDateField.get( TaskItemServices.END_DATE_FIELD ).isEmpty() ) {
                    // Changed Actual End Date - WORKS ONLY FOR ONE TASK ITEM (MANUAL UPDATING OF TASK)!!!
                    if( filteredTasksWithDateField.get( TaskItemServices.END_DATE_FIELD ).size() == 1 ) {
                        TaskItemServices.updateExpectedDatesForAllServices( filteredTasksWithDateField.get( TaskItemServices.END_DATE_FIELD ), false );
                    }
                    // If Dependency Task is completed with Disaprove Status then insert new alternative path into the Task flow
//                    TaskItemServices.insertAlternativeTaskLineToConditionalTasks( filteredTasksWithDateField.get( TaskItemServices.END_DATE_FIELD ) ); //MRS-6903
                }
            }
        }
    }

    if( Trigger.isAfter ) {
        // Populate Form Items lookups to Project Profile and Complete Forms Task
        if( Trigger.isInsert ) {
            // MRS-5739: Otherwise System.LimitException: Too many DML rows: 10001
            if( Limits.getDMLRows() < 3000 ) {
                if (System.isFuture() || System.isBatch()){
                    FormItemsServices.createFormItemsAfterTaskInsert( TaskItemServices.filterCompleteFormsTaskItems( Trigger.new ) );
                    StoredDocumentServices.createFolders( Trigger.newMap.keySet() );
                } else {
                    TaskItemServices.createFormItemsAndFolderFuture( new Map<Id, Task_Item__c>( TaskItemServices.filterCompleteFormsTaskItems( Trigger.new ) ).keySet(), Trigger.newMap.keySet() );
                }
            }
        }

        if( Trigger.isUpdate && !TaskItemServices.taskCalculationPreventor ) {
            // Update Service Successor/Predecessor Milestones
            TaskItemServices.updateServiceItemPredecessorSuccessor( TaskItemServices.filteredTaskForServiceItemUpdate(Trigger.new, Trigger.oldMap) );

            TaskItemServices.populateReportingFieldsOnService( filteredTasksWithDateField.get( TaskItemServices.END_DATE_FIELD ) );

            // Update Service Actual Start/End Dates
            TaskItemServices.updateServiceActualStartDateActualEndDate( filteredTasksWithDateField, Trigger.oldMap );

            // Create Billing Line Items from Billed Task Items (Only if populated Actual End Date )
            if( !TaskItemServices.preventor ) {
                TaskItemServices.createBillingLineItemsFromTaskItems( TaskItemServices.filterTaskItemsForBillingLineItemsCreation( Trigger.new, Trigger.oldMap ), null );
            }
            TaskItemServices.createEventRemindersForProjectManager( TaskItemServices.filterTaskItemsToCreateReminders( Trigger.newMap, Trigger.oldMap ) );
            TaskItemServices.createChangeOrderForRenewableTasks( TaskItemServices.filterTaskItemsToCreateChangeOrder( Trigger.newMap, Trigger.oldMap ) );

            EventServices.createEventsFromTaskItemIfAlertIfNotification( TaskItemServices.eventSubjectTofilterTaskItemsForEventAlertNotification( Trigger.new, Trigger.oldMap ) );
            EventServices.deleteEventsFromTaskItemIfAlertIfNotification( TaskItemServices.filterTaskItemsForEventAlertNotificationDelete( Trigger.new, Trigger.oldMap ) );

            TaskItemServices.updateMunicipalAgencyForAllTask( TaskItemServices.filterTaskItemsMunicipalAgency( Trigger.new, Trigger.oldMap ) );

            ProjectProfileServices.updateExpectedProjectEndDate( TaskItemServices.filterExpectedEndDateTasks( Trigger.new, Trigger.oldMap ), Trigger.new );

            //Create Reimbursable Line Item for Request/Assign Vendor Activity Task Item when current task items is completed.
            VendorRequestServices.createVendorReimbursableLineItem(VendorRequestServices.filteredTaskItemIdsForReimbursableLineItem(Trigger.oldMap, Trigger.new));

            //MRS-6783 MRS-7076 Deactivate BLI when status changed from Complete to Incomplete or activate BLI when status changed from Incomplete to Complete
            if( !TaskItemServices.billingLineItemCreationPreventor ) {
                if( UserServices.getProfile().Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) { //This actions can be done only by Platform System Admin
                    //Deactivate BLI when status changed from Complete to Incomplete
                    BillingLineItemServices.updateBLIisActiveField( TaskItemServices.filteredTaskItemsToInCompleteStatus( Trigger.oldMap, Trigger.new ), null );
                }
                //Activate BLI when status changed from Incomplete to Complete
                BillingLineItemServices.updateBLIisActiveField( null, TaskItemServices.filteredTaskItemsToCompleteStatus( Trigger.oldMap, Trigger.new ) );
            }
            if ( TaskItemServices.isCalculateActualValuesInFuture ){
                TaskItemServices.prepareDataAndRunFutureMethod(Trigger.new, Trigger.newMap, Trigger.oldMap);
            }
        }
        if ( Trigger.isUpdate && ServiceItemServices.preventorUpdateServiceItemOwner){
            TaskItemServices.upsertProjectRosterList( TaskItemServices.filteredTaskItemWithChangedOwner(Trigger.new, Trigger.oldMap) );
        }
        if( !TaskItemServices.taskCalculationPreventor ){
            TaskItemServices.updateFormItemPackageStatus( TaskItemServices.filterTaskItemsPackageStatus(Trigger.new, Trigger.oldMap) );
        }
        //MRS-6304
        if( Trigger.isUpdate && !TaskItemServices.taskCalculationPreventor ){
            TaskItemServices.updateServiceItemExpirationDate( TaskItemServices.filteredTaskItemWithChangedExpirationDate(Trigger.new, Trigger.oldMap) );
        }
    }
}