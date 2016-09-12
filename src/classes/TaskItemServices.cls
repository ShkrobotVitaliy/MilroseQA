public without sharing class TaskItemServices{
    private static Integer MAX_SIZE_CUSTOM_SETTING_NAME = 38;
    public static Boolean preventor = false;
    public static Boolean taskCalculationPreventor = false;
    public static Boolean taskDurationCalculationPreventor = false;
    public static Boolean isCalculateActualValuesInFuture = false;
    public static Boolean runInFutureMethod = false;
    public static Boolean billingLineItemCreationPreventor = false;

    public static final String PROJECT_TASK_RECORD_TYPE             = 'Project Task';

    public static final String PICKUP_ANALYZE_ARTIFACTS_CUSTOM_SETTING_NAME = 'Pickup/Analyze Artifacts from Author';
    public static final String TRACK_FROM_PROCESSING_CUSTOM_SETTING_NAME    = 'Track Form Processing through Author';

    public static final String TASK_ITEM_STATUS_NOT_STARTED = 'Not Started';
    public static final String TASK_ITEM_STATUS_IN_PROCESS = 'In Process';
    public static final String TASK_ITEM_STATUS_COMPLETED = 'Completed';
    public static final String TASK_ITEM_STATUS_APPROVED = 'Approved';
    public static final String TASK_ITEM_STATUS_DISAPPROVED = 'Disapproved';
    public static final String TASK_ITEM_STATUS_PACKAGE_COMPLETED = 'Package Completed';
    public static final Set<String> TASK_ITEM_END_STATUS_VALUES = new Set<String> { 'RFI Complete',
                                                                                    'Drawings Received',
                                                                                    'Checks Received',
                                                                                    'Forms Completed',
                                                                                    'All Signatures Received & Verified',
                                                                                    'Package Submitted',
                                                                                    'Response Received',
                                                                                    'Appointment Completed', //old?
                                                                                    'Activity Completed',
                                                                                    'Sent',
                                                                                    'Appointment/Meeting Attended',
                                                                                    TASK_ITEM_STATUS_PACKAGE_COMPLETED,
                                                                                    TASK_ITEM_STATUS_APPROVED,
//                                                                                    TASK_ITEM_STATUS_DISAPPROVED, //MRS-6903
                                                                                    TASK_ITEM_STATUS_COMPLETED };
    public static final String TASK_STATUS_RENEWABLE_SERVICE = 'Renewable Service';
    public static final String TASK_STATUS_RENEWAL_SERVICE = 'Renewal';
    public static final String PICKUP_ANALIZE_TASK_NAME = 'Pickup/Analyze Artifacts from Authority';
    public static final String SUBMIT_FILING_PACKAGE_TO_AUTHORITY_TASK_NAME = 'Submit Filing Package to Authority';
    public static final String PICKUP_ANALIZE_RENEWABLE_OR_RENEWAL_TASK_NAME = 'Pickup/Analyze Artifacts from Authority Service Renewable or Renewal';
    public static final String REQUEST_FOR_INFORMATION_TASK_NAME = 'Request for Information';
    public static final String COMPLETE_FORMS_TASK_NAME = 'Complete Forms';
    public static final String SEND_FORMS_TASK_NAME = 'Send Forms for Signatures/Seals';
    public static final String PERFORM_HOURLY_CONSULTING_TASK_NAME = 'Perform Hourly Consulting';
    public static final String PREPARE_FILING_PACKAGE_TASK_NAME = 'Prepare Filing Package';
    public static final String REQUEST_ASSIGN_VENDOR_ACTIVITY = 'Request/Assign Vendor Activity';

    public static final String START_DATE_FIELD = 'Start Date';
    public static final String END_DATE_FIELD = 'End Date';
    public static final String PICKUP_ANALIZE_TASK_REMINDER_SUBJECT = 'Pickup/Analyze Artifacts From Authority Reminder for Project Manager';

    private static Map<Id, Service_Item__c> servicesWithTasks;
    public static Map<Id, Map<String, Task_Item__c>> projectIdToMilestone = new Map<Id, Map<String, Task_Item__c>>();

    private static Map<Id, Boolean> tasksNeedBillingLineItemDisapprovalStatus;

    public static Map<Id, Service_Item__c> servicesUpdatedInCurrentScope = new Map<Id, Service_Item__c>();

    public static Integer SERVICE_ITEM_COUNT {
        get{
            if ( SERVICE_ITEM_COUNT == null ){
                Number_Of_Records__c serviceItemCount = Number_Of_Records__c.getValues('Service For Task');
                if ( serviceItemCount != null && serviceItemCount.Record_Count__c != null ){
                    SERVICE_ITEM_COUNT = Integer.valueOf(serviceItemCount.Record_Count__c);
                } else {
                    SERVICE_ITEM_COUNT = 200;
                }
            }
            return SERVICE_ITEM_COUNT;
        }
    }

    public static Map<String, Id> TASK_ITEM_RECORD_TYPE_IDS {
        get{
            if ( TASK_ITEM_RECORD_TYPE_IDS == null ){
                TASK_ITEM_RECORD_TYPE_IDS = new Map<String, Id>();
                for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Task_Item__c.SObjectType.getDescribe().getRecordTypeInfos()){
                    TASK_ITEM_RECORD_TYPE_IDS.put(schemaRecordTypeInfoItem.getName(), schemaRecordTypeInfoItem.getRecordTypeId());
                }
            }
            return TASK_ITEM_RECORD_TYPE_IDS;
        }
    }

    public static Set<Id> getTaskItemIdsByProjectId(Id projectId) {
        if (null == projectId) {
            throw new ErrorException('Parameter project Id cannot be empty!');

        }

        return (new Map<Id, Task_Item__c>([SELECT Id FROM Task_Item__c WHERE Project_Profile__c =: projectId])).keySet();

    }

    public static List<Task_Item__c> getUnfinishedTaskItemByProjectIds(Set<Id> ids) {
        return new List<Task_Item__c>([SELECT Project_Profile__c, Id, Actual_End_Date__c, Expected_Duration__c, Actual_Duration__c, Project_Profile__r.Project_Team__c
                                       FROM Task_Item__c
                                       WHERE Project_Profile__c IN: ids  AND Actual_End_Date__c = null]);

    }

    public static List<Task_Item__c> getUnfinishedTaskItemByProjectTeamIds(Set<Id> ids) {
        return new List<Task_Item__c>([SELECT Project_Profile__c, Id, Actual_End_Date__c, Expected_Duration__c, Actual_Duration__c, Project_Profile__r.Project_Team__c
                                       FROM Task_Item__c
                                       WHERE Project_Profile__r.Project_Team__c IN: ids  AND Actual_End_Date__c = null AND RecordType.Name != 'Milestone']);

    }

    public static Map<Id, Task_Item__c> filterTaskItemsForBillingLineItemsCreation( List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap ) {
        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>();

        for( Task_Item__c task : newTaskItemList ) {
            if( ( task.Billing_Trigger__c && !task.Is_Locked__c && (!task.Pre_billed__c || (task.Pre_billed__c && task.Is_Change_Order__c) ||
                  ( task.Pre_billed__c && !task.Is_Change_Order__c && task.Name == PERFORM_HOURLY_CONSULTING_TASK_NAME &&
                    (task.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE || task.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT) && task.Hours_Remaining__c > 0) ) ) && //MRS-6395
                task.Actual_End_Date__c != null && TASK_ITEM_END_STATUS_VALUES.contains( task.Status__c ) &&
                task.Status__c != oldTaskItemMap.get( task.Id ).Status__c &&
                !task.Name.contains( TaskServices.TERMINATED_TASK_NAME_PREFIX ) ) {

	        	billingLineItemCreationPreventor = false;

	            taskItemMap.put( task.Id, task );

	            if( task.Billing_Line_Item__c == null || !task.Is_Future__c) billingLineItemCreationPreventor = true;
            }

        	if( !task.Billing_Trigger__c ) billingLineItemCreationPreventor = true;
        }System.Debug(LoggingLevel.ERROR, '^^^ TaskItemServices.filterTaskItemsForBillingLineItemsCreation taskItemMap = ' + taskItemMap);
        return taskItemMap;
    }

    public static void createBillingLineItemsFromTaskItems( Map<Id, Task_Item__c> newTaskItemMap, Map <Id, Project_Profile__c> projectsMap ) {
        createBillingLineItemsFromTaskItems( newTaskItemMap, projectsMap, false );
    }

    public static void createBillingLineItemsFromTaskItems( Map<Id, Task_Item__c> newTaskItemMap, Map <Id, Project_Profile__c> projectsMap, Boolean isCurrentlyPrebilling ) {
        if( newTaskItemMap.isEmpty() ) return;

        //system.debug(LoggingLevel.Error, 'xxx newTaskItemMap: ' + newTaskItemMap);
        Set<Id> serviceItemIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>();
        List<Billing_Line_Item__c> billingLineItems = new List<Billing_Line_Item__c>();
        List<Task_Item__c> taskItemUpdateList = new List<Task_Item__c>();
        List<Service_Item__c> serviceItemUpdateList = new List<Service_Item__c>();
        List<Billing_Line_Item__c> bliForHiddenBliCreation = new List<Billing_Line_Item__c>();//MRS-7157

        if( projectsMap == null ) {
            for( Task_Item__c taskItem : newTaskItemMap.values() ) {
                projectProfileMap.put( taskItem.Project_Profile__c, null );
                serviceItemIds.add(taskItem.Service_Item__c);
            }
            projectProfileMap.remove( null );
            projectProfileMap = ProjectProfileServices.getProgectProfileMap( projectProfileMap.keySet() );
            for( Project_Profile__c project : projectProfileMap.values() ) {
                projectIds.add(project.Id);
            }
            serviceItemUpdateList.addAll( ServiceItemServices.getServiceItemsByProjectsId( projectIds ).values() );
        } else {
            projectProfileMap = projectsMap;
            for( Task_Item__c taskItem : newTaskItemMap.values() ) {
                serviceItemIds.add( taskItem.Service_Item__c );
            }
            serviceItemUpdateList.addAll( ServiceItemServices.getServiceItemsByProjectsId( projectProfileMap.keySet() ).values() );
        }

        //List<Purchase_Order__c> purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForBillingLineItems( projectProfileMap.keySet() );

        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>( serviceItemUpdateList );
        Map<Id, Service_Item__c> serviceItemUpdateMap = new Map<Id, Service_Item__c>();
        List<Billing_Line_Item__c> reimbursabelBLI = new List<Billing_Line_Item__c>();

        //MRS-799
        Map<Id, Billing_Line_Item__c> milestoneServiceIdToBliMap = new Map<Id, Billing_Line_Item__c>();
        List<Billing_Line_Item__c> existBLIForMilestone = BillingLineItemServices.getBillingLineItemForMilstone( serviceItemIds );
        for( Billing_Line_Item__c bli: existBLIForMilestone ){
            milestoneServiceIdToBliMap.put( bli.Service_Item__c, bli );
        }
        Map<Id, Decimal> serviceItemIdToTotalBilledPercentage;

        //MRS-7150
        //Service Item With the latest TaskItem
        Map<Id, Task_Item__c> serviceWithLatestTaskItemMap = new Map<Id, Task_Item__c>();
        if (isCurrentlyPrebilling){
            for (Task_Item__c taskItem : newTaskItemMap.values() ){
                if( projectProfileMap.get(taskItem.Project_Profile__c).Billing_Method__c != ProjectProfileServices.BILLINGMETHODMILESTONE ){
                    continue;
                }

                if ( !serviceWithLatestTaskItemMap.containsKey(taskItem.Service_Item__c) ||
                     ( serviceWithLatestTaskItemMap.get(taskItem.Service_Item__c).Sequence_Number__c < taskItem.Sequence_Number__c ) ){
                    serviceWithLatestTaskItemMap.put( taskItem.Service_Item__c, taskItem );
                }
            }
        }

        //MRS-6289
        Set<Id> idOfTaskWithExistBLIWithProformaInvoice = new Set<Id>();
        Set<Id> idOfTaskWithExistBLIWithProformaInvoiceReimbursableTypeScanning = new Set<Id>();
        for( Billing_Line_Item__c bli: BillingLineItemServices.getBillingLineItemWithProformaInvoice( serviceItemIds ) ){
            if( bli.isReimbursable__c && bli.Reimbursable_Type__c == BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING ){
                idOfTaskWithExistBLIWithProformaInvoiceReimbursableTypeScanning.add( bli.Related_Service_Item__c );
            }
            if( !bli.isReimbursable__c ){
                idOfTaskWithExistBLIWithProformaInvoice.add( bli.Task_Item__c );
            }
        }

         //MRS-5799: Collection for fix bug: invalid query location
        Map<Id, List<Service_Item__c>> projectIdToServiceItems = ServiceItemServices.groupServiceItemsByProjectId(projectProfileMap.keySet());
        Map<Id, List<Task_Item__c>> projectIdToTaskItems       = ProjectProfileServices.groupTaskItemsByProjectIdForBillingDate(projectProfileMap.keySet());

        for( Task_Item__c taskItem : newTaskItemMap.values() ) {
            Project_Profile__c projectProfile = projectProfileMap.get( taskItem.Project_Profile__c );
            Service_Item__c serviceItem = serviceItemMap.get( taskItem.Service_Item__c );
            Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount; //holds remaining percentages and previously billed amounts for projects
            Billing_Line_Item__c billingLineItem;

            if( doCreateBliForHourlyConsultingRemainingHours( taskItem ) ) { //Perform hourly consulting task - create BLI for unused consulting hours
                if ( serviceItem.Status__c != ServiceItemServices.SERVICE_STATUS_INACTIVE ){//MRS-6616
                    Billing_Line_Item__c remainingHoursBli = BillingLineItemServices.initRemainingHoursBli( taskItem, serviceItem, projectProfile, serviceItemMap, isCurrentlyPrebilling );
                    if( remainingHoursBli != null ) {
                        if (taskItem.Pre_billed__c && !taskItem.Is_Change_Order__c &&
                            (projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE || projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT) ){//MRS-6395
                            remainingHoursBli.Unit_Price__c = 0;
                            remainingHoursBli.Amount__c = 0;
                            remainingHoursBli.Active_Billing_Line_Item__c = false;
                            billingLineItems.add( remainingHoursBli );
                            continue;
                        }
                        if ( !isCurrentlyPrebilling && projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ){//MRS-6616
                            remainingHoursBli.Active_Billing_Line_Item__c = false;
                            billingLineItems.add( remainingHoursBli );
                            continue;
                        }
                        billingLineItems.add( remainingHoursBli ); //should be added to the list before regular bli was added, so the lookup on task will be overwritten with a regular bli after insert if it will be created
                    }
                }
            }

            if( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE
                    && !doCreateBliForHourlyConsultingRemainingHours( taskItem ) /*MRS-5165*/) { //Milestone billing method


                if( milestoneServiceIdToBliMap.containsKey(taskItem.Service_Item__c) ) { //If BLI exist for current Service Item we use it, else we create a new one.
                    billingLineItem = milestoneServiceIdToBliMap.get(taskItem.Service_Item__c);
                }

                if( !idOfTaskWithExistBLIWithProformaInvoice.contains( taskItem.Id ) && taskItem.Billing_Line_Item__c == null ){
                    if( billingLineItem == null ) {
                        billingLineItem = BillingLineItemServices.initBillingLineItem(null, taskItem, serviceItem, projectProfile, null);

                        if ( isCurrentlyPrebilling ){
                            billingLineItem.OwnerId = serviceWithLatestTaskItemMap.get(taskItem.Service_Item__c).OwnerId;
                        }

                        billingLineItem.Quantity__c = 0.00;
                        taskItemUpdateList.add( new Task_Item__c( Id = taskItem.Id, Is_Locked__c = true) );
                    } else {
                        Task_Item__c taskItemToUpdate = new Task_Item__c( Id = taskItem.Id, Is_Locked__c = true );
                        if( billingLineItem.Id != null ){
                            taskItemToUpdate.Billing_Line_Item__c = billingLineItem.Id;
                        }
                        taskItemUpdateList.add( taskItemToUpdate );
                    }


                    BillingLineItemServices.calculateAmountsForBLI( projectProfile, billingLineItem, taskItem, null, serviceItem, null );

                    if( billingLineItem.Quantity__c > 0 ) {
                        milestoneServiceIdToBliMap.put( billingLineItem.Service_Item__c, billingLineItem );
                    }
                }else{
                    taskItemUpdateList.add( new Task_Item__c( Id = taskItem.Id, Is_Locked__c = true) );
                }

                if( serviceItemIdToTotalBilledPercentage == null ) { //populate the map the first time we need it
                    serviceItemIdToTotalBilledPercentage = getServiceItemIdToTotalBilledPercentage( serviceItemUpdateList ); //KDI: MRS-1111
                }

                //CASE UCRX2.0 Generate Reimbursable Line for Milestone billing method

                if( serviceItemIdToTotalBilledPercentage.get( serviceItem.Id ) == 100 && !serviceItemUpdateMap.containsKey( serviceItem.Id ) &&
                        !projectProfile.No_Met_Data_Scanning__c && taskItem.Met_Data_Scanning_Fee__c > 0 &&
                        !idOfTaskWithExistBLIWithProformaInvoiceReimbursableTypeScanning.contains( taskItem.Service_Item__c ) ) { //KDI: MRS-1111

                    reimbursabelBLI.add( BillingLineItemServices.newReimbursableLineItemScanning( taskItem, serviceItem, projectProfile, null ) );
                    serviceItemUpdateMap.put( serviceItem.Id, new Service_Item__c( Id = serviceItem.Id, Met_Data_BLI_Created__c = true ) );
                }

            } else if( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !projectProfile.Interval__c ) { //Percentage without Interval (with milestones) billing method

                if( !idOfTaskWithExistBLIWithProformaInvoice.contains( taskItem.Id ) && ( taskItem.Billing_Line_Item__c == null || taskItem.Name == PERFORM_HOURLY_CONSULTING_TASK_NAME ) ){
                    if( projectIdToAmountTypeToAmount == null ) { //init the map the first time we need it
                        projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( projectProfileMap.keySet(), isCurrentlyPrebilling );
                    }

                    billingLineItem = BillingLineItemServices.initBillingLineItem( null, taskItem, serviceItem, projectProfile, null );
                    BillingLineItemServices.calculateAmountsForBLI( projectProfile, billingLineItem, taskItem, null, null, projectIdToAmountTypeToAmount.get( billingLineItem.Project_Profile__c ) );
					if(taskItem.Billing_Trigger__c) billingLineItem.Description__c = ''; // MRS 6362

                    if( billingLineItem.Quantity__c > 0 ) {
                        //MRS-5941
                        billingLineItems.add( billingLineItem );
                        bliForHiddenBliCreation.add( billingLineItem );//MRS-7157
                    }
                }

                taskItemUpdateList.add( new Task_Item__c( Id = taskItem.Id, Is_Locked__c = true ) );

                //CASE UCRX2.3 Generate Reimbursable Line for Percentage billing method without Interval

                if( !idOfTaskWithExistBLIWithProformaInvoiceReimbursableTypeScanning.contains( taskItem.Service_Item__c ) ){

                    List<Service_Item__c> servicesToCreateScanning = ServiceItemServices.getServiceItemsToCreateScanninReimbursableBLI(projectProfile, projectIdToServiceItems.get(projectProfile.Id), servicesUpdatedInCurrentScope, projectIdToTaskItems.get(projectProfile.Id));

                    for( Service_Item__c service: servicesToCreateScanning ) {
                        reimbursabelBLI.add( BillingLineItemServices.newReimbursableLineItemScanning( null, service, projectProfile, null ) );
                        if( !serviceItemUpdateMap.containsKey( service.Id ) ){
                            serviceItemUpdateMap.put( service.Id, new Service_Item__c( Id = service.Id, Met_Data_BLI_Created__c = true ) );
                        }
                    }
                }
            }
        }

        //MRS-4049
        if( !milestoneServiceIdToBliMap.isEmpty() ) {
            billingLineItems.addAll( milestoneServiceIdToBliMap.values() );
    }

        //Populate reimbursable BLI PO lookup
        if( !reimbursabelBLI.isEmpty() ) {
            //BillingLineItemServices.populateReimbursableLineItemsPurchaseOrder( reimbursabelBLI, PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems( projectProfileMap.keySet() ) );
            billingLineItems.addAll(reimbursabelBLI);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            UPSERT billingLineItems;

            if( !bliForHiddenBliCreation.isEmpty() ) {//MRS-7157
                HiddenBliCalculator hiddenBliCalculator = new HiddenBliCalculator( bliForHiddenBliCreation );
                Database.insert( hiddenBliCalculator.getHiddenBli(), false );
            }

            preventor = true;
            BillingLineItemServices.billingLineItemsToCreateInvoicesInReduBilling = billingLineItems;

            Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>( taskItemUpdateList );
            for( Billing_Line_Item__c bli : billingLineItems ) {
                if( !bli.isReimbursable__c && taskItemMap.containsKey( bli.Task_Item__c ) ) {

                    taskItemMap.get( bli.Task_Item__c ).Billing_Line_Item__c = bli.Id;
        }
            }
            if( !taskItemUpdateList.isEmpty() ) {
                UPSERT taskItemUpdateList;

            }
            if( !serviceItemUpdateMap.isEmpty() ) {
                UPDATE serviceItemUpdateMap.values();
            }
        } catch( DMLException dmlEx ) {
            Database.rollback( sp );
            if (Trigger.isExecuting){
                for(Integer i = 0; i < dmlEx.getNumDml(); i++) {
                    newTaskItemMap.get( billingLineItems[dmlEx.getDmlIndex(i)].Task_Item__c ).addError( 'Can not create Billing Line Item ' + dmlEx.getMessage() );
                }
            } else {
                throw new ErrorException( 'Can not create Billing Line Item ' + dmlEx.getMessage() );
            }
        }
    }

    public static List<Billing_Line_Item__c> createBilingLineItemsForBillingDatesBatch( List<Billing_Date__c> billingDateList, Date currentDate, Map<Id, Project_Profile__c> projectProfiles ) {
        return createBilingLineItemsForBillingDatesBatch( billingDateList, currentDate, projectProfiles, false );
    }

    public static List<Billing_Line_Item__c> createBilingLineItemsForBillingDatesBatch(List<Billing_Date__c> billingDateList,
                                                                                       Date currentDate,
                                                                                       Map<Id, Project_Profile__c> projectProfiles,
                                                                                       Boolean isCurrentlyPrebilling) {
        List<Billing_Date__c> billingDateForUpdate    = new List<Billing_Date__c>();
        List<Billing_Line_Item__c> billingLineItems   = new List<Billing_Line_Item__c>();

        List<Billing_Line_Item__c> bliForHiddenBliCreation = new List<Billing_Line_Item__c>();
        List<Billing_Date__c> billingDatesForHiddenBliCreation = new List<Billing_Date__c>();

        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>();
        Set<Service_Item__c> serviceItemUpdateList    = new Set<Service_Item__c>();

        for( Billing_Date__c billingDate : billingDateList ) {
            projectProfileMap.put( billingDate.Project_Profile__c, null );

        }
        projectProfileMap.remove( null );
        projectProfileMap = projectProfiles == null ? ProjectProfileServices.getProgectProfileMap(projectProfileMap.keySet()) : projectProfiles;
        //List<Purchase_Order__c> purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForBillingLineItems( projectProfileMap.keySet() );

        Project_Profile__c projectProfile;
        Billing_Line_Item__c billingLineItem;
        List<Service_Item__c> serviceItemForScanning = new List<Service_Item__c>();
        Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount; //holds remaining percentages and previously billed amounts for projects

        //MRS-5799: Collection for fix bug: invalid query location
        Map<Id, List<Service_Item__c>> projectIdToServiceItems = ServiceItemServices.groupServiceItemsByProjectId(projectProfileMap.keySet());
        Map<Id, List<Task_Item__c>> projectIdToTaskItems       = ProjectProfileServices.groupTaskItemsByProjectIdForBillingDate(projectProfileMap.keySet());

        for( Billing_Date__c billingDate : billingDateList ) {
            projectProfile = projectProfileMap.get( billingDate.Project_Profile__c );

            if( ( ( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && projectProfile.Interval__c ) ||
                  ( projectProfile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) ) &&
                ( billingDate.Percentage__c != null && billingDate.Percentage__c > 0 ) ) {System.Debug(LoggingLevel.ERROR, '^^^ 414 = ');
                if( !projectProfile.Billing_Dates_Blocked__c ) { //this checkbox forbids the creation of new BLIs from Billing Dates
                    if( projectIdToAmountTypeToAmount == null ) { //init the map only if needed (when there is at least one task item with the % w/o Interval method), since it performs a DML
                        projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( projectProfileMap.keySet(), isCurrentlyPrebilling );
                    }
                    billingLineItem = BillingLineItemServices.initBillingLineItem( null, null, null, projectProfile, billingDate );
                    BillingLineItemServices.calculateAmountsForBLI( projectProfile, billingLineItem, null, billingDate, null, projectIdToAmountTypeToAmount.get( billingDate.Project_Profile__c ) );
System.Debug(LoggingLevel.ERROR, '^^^ billingLineItem = ' + billingLineItem);
                    if( billingLineItem.Quantity__c > 0 ) {
                        billingLineItem.Billing_Date__c = billingDate.Id; //set billing date lookup for BLI
                        billingLineItems.add( billingLineItem );
                        bliForHiddenBliCreation.add( billingLineItem );
                        billingDatesForHiddenBliCreation.add( billingDate );
                    } else {
                        continue;
                    }
                    billingDate.Billed__c = true;
                    billingDate.Amount__c = billingLineItem.Amount__c;
                    billingDateForUpdate.add( billingDate );
System.Debug(LoggingLevel.ERROR, '^^^ billingDateForUpdate = ' + billingDateForUpdate);
                }

            }

            List<Service_Item__c> servicesToCreateScanning = ServiceItemServices.getServiceItemsToCreateScanninReimbursableBLI(projectProfile, projectIdToServiceItems.get(projectProfile.Id), null, projectIdToTaskItems.get(projectProfile.Id));

            for (Service_Item__c service: servicesToCreateScanning) {

                Billing_Line_Item__c reimbBLI = BillingLineItemServices.newReimbursableLineItemScanning( null, service, projectProfile, billingDate );

                billingLineItems.add( reimbBLI );

                serviceItemUpdateList.add( service );
            }
        }

        String errors = '';
        if( !billingLineItems.isEmpty() ) {
            String errorMessage = '';
            Savepoint sp = Database.setSavepoint();
            try {

                Database.insert( billingLineItems, false );
                if( !bliForHiddenBliCreation.isEmpty() ) {
                    HiddenBliCalculator hiddenBliCalculator = new HiddenBliCalculator( bliForHiddenBliCreation, billingDatesForHiddenBliCreation );
                    Database.insert( hiddenBliCalculator.getHiddenBli(), false );
                }
                preventor = true;
                if( !billingDateForUpdate.isEmpty() ) {
                    update billingDateForUpdate;
                }
                if( !serviceItemUpdateList.isEmpty() ) {
                    update new List<Service_Item__c>(serviceItemUpdateList);
                }
            } catch( Dmlexception dmlE ) {System.Debug(LoggingLevel.ERROR, '^^^ dmlE = ' + dmlE.getMessage());
                Database.rollback( sp );
                errorMessage += 'Inserting of Billing Line Item failed.\n';
                for( Integer index = 0; index < dmlE.getNumDml(); index++ ) {
                    billingLineItem = billingLineItems[dmlE.getDmlIndex(index)];
                    errorMessage += 'billing Line Item Name: ' + billingLineItem.Name + '\n';
                    errorMessage += '\tReason(s):\n';
                    errorMessage += '\t\t' + dmlE.getMessage() + '\n\n';
                }
            }
            if( !errorMessage.equals( '' ) ) {
                errors += '\n' + errorMessage + '\n\n';
            }
        }
        //return errors;
        return billingLineItems;
    }

    public static Boolean doCreateBliForHourlyConsultingRemainingHours( Task_Item__c taskItem ) {
        return taskItem.RecordTypeId == TASK_ITEM_RECORD_TYPE_IDS.get( PERFORM_HOURLY_CONSULTING_TASK_NAME );
    }

    public static String getTaskItemBillingMethodQuery(Date currentDate) {
        return
            'SELECT Id, Percentage__c, Processing_Day__c, Project_Profile__c, Project_Profile__r.Name, Step_Number__c, Billed__c' +
            ' FROM Billing_Date__c ' +
            'WHERE Processing_Day__c <= ' + ((DateTime)currentDate).format('yyyy-MM-dd', 'GMT') +
            ' AND Billed__c = false' +
            ' AND Project_Profile__r.Billing_Method__c IN (\''+ProjectProfileServices.BILLINGMETHODINSTALLMENT+'\',\''+ProjectProfileServices.BILLINGMETHODPERCENTAGE+'\') ' +
            ' AND Project_Profile__r.Frequency__c != null' +
            ' AND Project_Profile__r.Project_State__c != \'' + ProjectProfileServices.PROJECT_STATE_CLOSED + '\'' + //MRS-6052
            ' AND Project_Profile__r.Project_State__c != \'' + ProjectProfileServices.PROJECT_STATE_ON_HOLD + '\'' + //MRS-6683
            ' ORDER BY Processing_Day__c ASC'; //KDI: MRS-3717
    }

    public static Map<Id, Decimal> getServiceItemIdToTotalBilledPercentage( List<Service_Item__c> incomingServiceItems ) {
        Map<Id, Decimal> serviceItemIdToTotalBilledPercentage = new Map<Id, Decimal>();
        if( incomingServiceItems != null ) {
            List<AggregateResult> taskItemsBillingPercentage = [SELECT Service_Item__c, SUM(Billing_Percentage__c)
                                                                FROM Task_Item__c
                                                                WHERE Billing_Trigger__c = true
                                                                  AND Met_Data_Scanning_Fee__c > 0
                                                                  AND Actual_End_Date__c != null
                                                                  AND No_Met_Data_Scanning__c = false
                                                                  AND Service_Item__r.Project_Profile__r.Billing_Method__c = : ProjectProfileServices.BILLINGMETHODMILESTONE
                                                                  AND Service_Item__c IN : incomingServiceItems
                                                                GROUP BY Service_Item__c];
            for( AggregateResult aggItem : taskItemsBillingPercentage ) {
                serviceItemIdToTotalBilledPercentage.put( (Id)aggItem.get('Service_Item__c'), (Decimal)aggItem.get('expr0') );
            }
        }
        return serviceItemIdToTotalBilledPercentage;
    }

    public static Service_Item__c getServiceItem(Project_Profile__c projectProfile) {
        for (Task_Item__c task : projectProfile.Task_Items__r) {
            if (null != task.Successor_Milestone__c ) {

                for (Service_Item__c service : projectProfile.Service_Items__r) {
                    if (task.Service_Item__c == service.Id && service.Met_Data_Scanning_Fee__c > 0 && !service.Met_Data_BLI_Created__c ) {
                        return new Service_Item__c(Id = service.Id, Met_Data_BLI_Created__c = true, Met_Data_Scanning_Fee__c = service.Met_Data_Scanning_Fee__c);

                    }
                }

            }
        }

        return null;
    }

    public static void attachTasksToProjectProfiles( Map<Id, Service_Item__c> serviceItemMap,
                                                     Map<Id, Map<Id, Task_Template__c>> serviceTemplateIdToTasksTemplates,
                                                     Map<Id, String> taskTemplIdToTotalDuration,
                                                     List<Proposal__c> proposals,
                                                     Map<Id, Project_Roster__c> projRosterRolesToRecords,
                                                     Boolean isChangeOrder ) {
        Map<String, Task_Item__c> milestoneNameToRecord;
        List<Task_Item__c> tasksToInsert = new List<Task_Item__c>();

        Map<Id, Project_Team__c> projectTeamIdToProjectTeamMap = ProjectProfileServices.projectTeamIdToProjectTeam.isEmpty() ?
                                                                 ProjectTeamServices.getProposalIdToProjectTeam(proposals) :
                                                                 ProjectProfileServices.projectTeamIdToProjectTeam;

        Map<Id, Proposal__c> proposalIdToProposalMap = new Map <Id, Proposal__c>(proposals);

        if ( isChangeOrder ) {
            for ( Proposal__c proposalItem : proposals ) {
                if ( proposalItem.Project_Profile__c != null ) {
                    projectIdToMilestone.put( proposalItem.Project_Profile__c, new Map<String, Task_Item__c>() );
                }
            }
            for ( Task_Item__c taskItemItem : [SELECT Id, Name, Project_Profile__c
                                               FROM Task_Item__c
                                               WHERE Project_Profile__c IN : projectIdToMilestone.keySet() AND
                                                    RecordType.Name = : TaskManagementServices.MILESTONE_RECORDTYPE_NAME] ) {
                projectIdToMilestone.get( taskItemItem.Project_Profile__c ).put( taskItemItem.Name, taskItemItem );
            }
        }

        Id ownerId;
        String billingMethod = '';
        Boolean isInterval = false;
        Decimal discountTotalServiceAmount = 0;
        Decimal sumPercentage = 0;
        Decimal fullPercentage = 0;
        Task_Item__c mediatorTaskItem = null;

        Id userProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_USER);

        List<Task_Item__c> notMilestoneTaskItemList = new List<Task_Item__c>();//MRS-6218

        for( Id serviceItemId: serviceItemMap.keySet() ) {
            Id serviceTemplateId = serviceItemMap.get(serviceItemId).Service_Template__c;

            if (ProjectProfileServices.idProposalToNewProjectProfiles != null) {
		    	if( ProjectProfileServices.idProposalToNewProjectProfiles.get( serviceItemMap.get( serviceItemId ).Proposal__c ) != null ){
	                ownerId                    = ProjectProfileServices.idProposalToNewProjectProfiles.get( serviceItemMap.get( serviceItemId ).Proposal__c ).OwnerId;
	                billingMethod              = ProjectProfileServices.idProposalToNewProjectProfiles.get(serviceItemMap.get(serviceItemId).Proposal__c).Billing_Method__c;
	                isInterval                 = ProjectProfileServices.idProposalToNewProjectProfiles.get(serviceItemMap.get(serviceItemId).Proposal__c).Interval__c;
	                discountTotalServiceAmount = proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c).Discounted_Total_Service_Amount__c;
				}else{
					ownerId                    = UserInfo.getUserId();
				}
            } else {
                if( proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c) != null ){
					ownerId                    = proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c).Project_Profile__r.OwnerId;
	                billingMethod              = proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c).Project_Profile__r.Billing_Method__c;
	                isInterval                 = proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c).Project_Profile__r.Interval__c;
	                discountTotalServiceAmount = proposalIdToProposalMap.get(serviceItemMap.get(serviceItemId).Proposal__c).Project_Profile__r.Discounted_Total_Service_Amount__c;
				}else{
					ownerId                    = UserInfo.getUserId();
				}
            }

            Service_Item__c serviceItemItem = serviceItemMap.get( serviceItemId );
            Project_Team__c projectTeamItem = projectTeamIdToProjectTeamMap.get( proposalIdToProposalMap.get( serviceItemItem.Proposal__c ).Project_Team__c );

            if( serviceTemplateIdToTasksTemplates.containsKey( serviceTemplateId ) ) {
                for( Task_Template__c taskTemplate : serviceTemplateIdToTasksTemplates.get( serviceTemplateId ).values() ) {
                    //MRS-6405
                    Task_Item__c taskItem = createAndPrepareTaskForInsertion( taskTemplate, serviceItemItem, proposalIdToProposalMap.get(serviceItemItem.Proposal__c), projectTeamItem, ownerId, taskTemplIdToTotalDuration.get( taskTemplate.Id ) );
                    notMilestoneTaskItemList.add(taskItem);

                    if (ProjectProfileServices.BILLINGMETHODPERCENTAGE.equals(billingMethod) && !isInterval && taskItem.Billing_Trigger__c) {
                        if(discountTotalServiceAmount != null && discountTotalServiceAmount != 0) {
							fullPercentage = (serviceItemItem.Discounted_Unit_Price__c / discountTotalServiceAmount) * taskItem.Billing_Percentage__c;
						} else {
							fullPercentage = serviceItemItem.Discounted_Unit_Price__c * taskItem.Billing_Percentage__c;
						}
                        taskItem.Billing_Percentage__c = ProjectProfileServices.idProposalToNewProjectProfiles != null ? fullPercentage.setScale(2) : 0.00;
                        sumPercentage += taskItem.Billing_Percentage__c;
                        mediatorTaskItem = taskItem;

                    }

                    if( !projectIdToMilestone.containsKey( taskItem.Project_Profile__c ) ) {
                        projectIdToMilestone.put( taskItem.Project_Profile__c, new Map<String, Task_Item__c>() );
                    }
                    milestoneNameToRecord = projectIdToMilestone.get( taskItem.Project_Profile__c );

                    Task_Item__c newMilestone = null;
                    // Prepare Predecessor Milestones for Services
                    if ( taskTemplate.Predecessor_Milestone__c != null && !milestoneNameToRecord.containsKey( taskTemplate.Predecessor_Milestone__c ) ) {
                        newMilestone = new Task_Item__c( Name = taskTemplate.Predecessor_Milestone__c,
                                                         RecordTypeId = TaskManagementServices.MILESTONE_RECORDTYPE_ID,
                                                         Project_Profile__c = taskItem.Project_Profile__c,
                                                         OwnerId = taskItem.OwnerId );
                        milestoneNameToRecord.put( taskTemplate.Predecessor_Milestone__c, newMilestone );
                        tasksToInsert.add( newMilestone );
                    }
                    // Prepare Successor Milestones for Services
                    if ( taskTemplate.Successor_Milestone__c != null && !milestoneNameToRecord.containsKey( taskTemplate.Successor_Milestone__c ) ) {
                        newMilestone = new Task_Item__c( Name = taskTemplate.Successor_Milestone__c,
                                                         RecordTypeId = TaskManagementServices.MILESTONE_RECORDTYPE_ID,
                                                         Project_Profile__c = taskItem.Project_Profile__c,
                                                         OwnerId = taskItem.OwnerId );
                        milestoneNameToRecord.put( taskTemplate.Successor_Milestone__c, newMilestone );
                        tasksToInsert.add( newMilestone );
                    }

                    if( !TaskManagementServices.seqNumberToTaskItemForService.containsKey( taskItem.Service_Item__c ) ) {
                        TaskManagementServices.seqNumberToTaskItemForService.put( taskItem.Service_Item__c, new Map<Integer, Task_Item__c>() );
                    }
                    TaskManagementServices.seqNumberToTaskItemForService.get( taskItem.Service_Item__c ).put( Integer.valueOf( taskItem.Sequence_Number__c ), taskItem );
                    tasksToInsert.add( taskItem );
                }
            }
        }

        if (ProjectProfileServices.BILLINGMETHODPERCENTAGE.equals(billingMethod) && !isInterval && null != mediatorTaskItem) {
            mediatorTaskItem.Billing_Percentage__c += (100 - sumPercentage);

            if (null == ProjectProfileServices.idProposalToNewProjectProfiles) {
                mediatorTaskItem.Billing_Percentage__c = 0;
                //mediatorTaskItem.Billing_Trigger__c = false;
            }

        }
        TaskItemServices.taskCalculationPreventor = true;
        insert tasksToInsert;

        if (projRosterRolesToRecords != null){//Create Project Roster for new Task Items, if runs in the Future method, MRS-6218
            createProjectRostersForNewTaskItems(notMilestoneTaskItemList, serviceItemMap, projRosterRolesToRecords.values());
        }
    }

    public static void prepareTaskMilestonePredecessorsSuccessors(  Map<Id, Service_Item__c> serviceItemMap,
                                                                    Map<Id, Map<Id, Task_Template__c>> serviceTemplateIdToTasksTemplates ) {
        Map<Integer, Task_Item__c> orderedListOfTasks;
        Map<String, Task_Item__c> milestoneNameToRecord;
        Map<Id, Task_Template__c> taskTemplateMapForSpecificService;
        Map<Id, Id> taskTemplateIdToTaskItemID;
        List<Task_Item__c> tasksToUpdate = new List<Task_Item__c>();

        for( Id serviceId : TaskManagementServices.seqNumberToTaskItemForService.keySet() ) {
            orderedListOfTasks = TaskManagementServices.seqNumberToTaskItemForService.get( serviceId );
            taskTemplateIdToTaskItemID = new Map<Id, Id>();

            Service_Item__c serviceItem = serviceItemMap.get( serviceId );

            List<Integer> ranksList = new List<Integer>();
            ranksList.addAll( orderedListOfTasks.keySet() );
            ranksList.sort();

            for( Integer sequenceNumber : ranksList ) {
                Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );

                //Define Milestone Predecessors/Successors: projectIdToMilestone defined in attachTasksToProjectProfiles();
                if( projectIdToMilestone.containsKey( taskItem.Project_Profile__c ) ) {
                    milestoneNameToRecord = projectIdToMilestone.get( taskItem.Project_Profile__c );
                    if( taskItem.Predecessor_Milestone_from_Template__c != null ) {
                        taskItem.Predecessor_Milestone__c = milestoneNameToRecord.get( taskItem.Predecessor_Milestone_from_Template__c ).Id;
                        serviceItem.Predecessor_Milestone__c = taskItem.Predecessor_Milestone_from_Template__c;
                    }
                    if( taskItem.Successor_Milestone_from_Template__c != null ) {
                        taskItem.Successor_Milestone__c   = milestoneNameToRecord.get( taskItem.Successor_Milestone_from_Template__c ).Id;
                        serviceItem.Successor_Milestone__c = taskItem.Successor_Milestone_from_Template__c;
                    }
                }

                // ------------------------------------------------------------
                // Predecessor/Successor definition for Tasks
                taskTemplateMapForSpecificService = serviceTemplateIdToTasksTemplates.get( serviceItem.Service_Template__c );
                if( !taskTemplateIdToTaskItemID.containsKey( taskItem.Task_Template__c ) ) {
                    taskTemplateIdToTaskItemID.put( taskItem.Task_Template__c, taskItem.Id );
                }
            }

            // ------------------------------------------------------------
            // Predecessor/Successor definition for Tasks
            for( Integer sequenceNumber : ranksList ) {
                Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );

                Id taskTemplatePredecessorId = taskTemplateMapForSpecificService.get( taskItem.Task_Template__c ).Predecessor_Task__c;
                Id taskTemplateSuccessorId = taskTemplateMapForSpecificService.get( taskItem.Task_Template__c ).Successor_Task__c;

                if( taskTemplateIdToTaskItemID.containsKey( taskTemplatePredecessorId ) ) {
                    taskItem.Predecessor_Task__c = taskTemplateIdToTaskItemID.get( taskTemplatePredecessorId );
                }
                if( taskTemplateIdToTaskItemID.containsKey( taskTemplateSuccessorId ) ) {
                    taskItem.Successor_Task__c = taskTemplateIdToTaskItemID.get( taskTemplateSuccessorId );
                }
            }
            tasksToUpdate.addAll( orderedListOfTasks.values() );
        }
        TaskItemServices.taskCalculationPreventor = true;
        update tasksToUpdate;
    }


    @future
    public static void createProjectRostersForNewTaskItemsFuture(Set<Id> serviceItemSetId){
        if (serviceItemSetId == null || serviceItemSetId.isEmpty()){
            return;
        }

        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>([SELECT Id, Project_Profile__c, Proposal__c
                                                                                FROM Service_Item__c
                                                                                WHERE Id IN : serviceItemSetId]);

        List<Task_Item__c> taskItemList = [SELECT Id, Project_Profile__c, OwnerId, Resources__c, Service_Item__c
                                           FROM Task_Item__c
                                           WHERE Service_Item__c IN : serviceItemSetId AND
                                                RecordType.Name != : TaskManagementServices.MILESTONE_RECORDTYPE_NAME];

        Set<Id> projectProfileSetId = new Set<Id>();

        for (Task_Item__c taskItem : taskItemList){
            projectProfileSetId.add(taskItem.Project_Profile__c);
        }

        List<Project_Roster__c> projectRosterList = [SELECT Id, User__c, Role__c, RecordTypeId, Project_Profile__c
                                                     FROM Project_Roster__c
                                                     WHERE Project_Profile__c IN : projectProfileSetId AND
                                                            Project_Profile__c != null AND
                                                            User__c != null];

        createProjectRostersForNewTaskItems(taskItemList, serviceItemMap, projectRosterList);
    }

    public static void createProjectRostersForNewTaskItems(List<Task_Item__c> taskItemList, Map<Id, Service_Item__c> serviceItemMap, List<Project_Roster__c> projectRosterList){
        Map<Id, Map<Id, Map<String, Project_Roster__c>>> projectWithUserRostersMap = new Map<Id, Map<Id, Map<String, Project_Roster__c>>>();

        List<Project_Roster__c> projectRosterInsertList = new List<Project_Roster__c>();

        for ( Project_Roster__c projectRosterItem : projectRosterList ){
            if ( projectRosterItem.Project_Profile__c == null ){ continue; }
            if ( !projectWithUserRostersMap.containsKey(projectRosterItem.Project_Profile__c) ){
                projectWithUserRostersMap.put(projectRosterItem.Project_Profile__c, new Map<Id, Map<String, Project_Roster__c>>());
            }
            if ( !projectWithUserRostersMap.get(projectRosterItem.Project_Profile__c).containsKey(projectRosterItem.User__c) ){
                projectWithUserRostersMap.get(projectRosterItem.Project_Profile__c).put(projectRosterItem.User__c, new Map<String, Project_Roster__c>());
            }
            if ( !projectWithUserRostersMap.get(projectRosterItem.Project_Profile__c).get(projectRosterItem.User__c).containsKey(projectRosterItem.Role__c) ){
                projectWithUserRostersMap.get(projectRosterItem.Project_Profile__c).get(projectRosterItem.User__c).put(projectRosterItem.Role__c, projectRosterItem);
            }
        }

        Id userProjectRosterRecordTypeId = ProjectRosterServices.getRecordTypeByObjectNameId('Project_Roster__c', ProjectRosterServices.TYPE_USER);

        Map<Id, String> usersWithRoleMap = UserServices.getUserIdToRoleName();

        for ( Task_Item__c taskItem : taskItemList){
            if ( taskItem.Project_Profile__c == null ||
                !usersWithRoleMap.containsKey( taskItem.OwnerId ) ){//MRS-7174
                continue;
            }

            String projectRosterRoleForTask = usersWithRoleMap.get( taskItem.OwnerId );
            Boolean isProjectRole = false;
            if ( projectRosterRoleForTask.contains(ProjectRosterServices.PROPOSAL_CREATOR_ROLE) ||
                 projectRosterRoleForTask.contains(ProjectRosterServices.PROJECT_OWNER_ROLE) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_PROJECT_MANAGER_2) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_PROJECT_MANAGER_1) ||
                 projectRosterRoleForTask.contains(ProjectRosterServices.FILING_REP) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_PRODUCTION_MANAGER) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_PARTNER) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_ACCOUNT_MANAGER) ||
                 projectRosterRoleForTask.contains(UserServices.PROFILE_PROPOSAL_SPECIALIST) ||
                 projectRosterRoleForTask.contains(ProjectRosterServices.SALESPERSON) ){
                isProjectRole = true;
            }

            if ( !projectWithUserRostersMap.containsKey(taskItem.Project_Profile__c) ){
                projectWithUserRostersMap.put(taskItem.Project_Profile__c, new Map<Id, Map<String, Project_Roster__c>>());
            }
            if ( !projectWithUserRostersMap.get(taskItem.Project_Profile__c).containsKey(taskItem.OwnerId) ){
                projectWithUserRostersMap.get(taskItem.Project_Profile__c).put(taskItem.OwnerId, new Map<String, Project_Roster__c>());
            }
            if ( !projectWithUserRostersMap.get(taskItem.Project_Profile__c).get(taskItem.OwnerId).containsKey( projectRosterRoleForTask ) ){
                if ( !isProjectRole ){
                    Project_Roster__c projectRosterItem = ProjectProfileServices.createAfterAssignProjectRoster( taskItem.OwnerId, taskItem.Project_Profile__c, serviceItemMap.get(taskItem.Service_Item__c).Proposal__c, userProjectRosterRecordTypeId, projectRosterRoleForTask, null );
                    projectWithUserRostersMap.get(taskItem.Project_Profile__c).get(taskItem.OwnerId).put( projectRosterRoleForTask, projectRosterItem );
                    projectRosterInsertList.add(projectRosterItem);
                }
            }
        }
        if (!projectRosterInsertList.isEmpty()){
            try{
                insert projectRosterInsertList;
            } catch (Exception ex){}
        }
    }

    public static Task_Item__c createAndPrepareTaskForInsertion( Task_Template__c taskTemplate, Service_Item__c serviceItemItem, Proposal__c proposalItem, Project_Team__c projectTeamItem, Id ownerId, String alternativeDurration ){
        Task_Item__c taskItem = createTaskItemFromTaskTemplate( taskTemplate );
        if( TASK_ITEM_RECORD_TYPE_IDS.containsKey( taskItem.Name ) ) {
            taskItem.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( taskItem.Name );
        } else {
            taskItem.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( PROJECT_TASK_RECORD_TYPE );
        }

        if( taskItem.Name == PERFORM_HOURLY_CONSULTING_TASK_NAME ){
            if( serviceItemItem.Unit_of_Service__c == ServiceItemServices.UNIT_OF_SERVICE_HOUR ) {
                taskItem.Type_of_Billable_Hours__c = serviceItemItem.Id;
            }
        }

        taskItem.Service_Item__c = serviceItemItem.Id;
        taskItem.Project_Region__c = serviceItemItem.Region__c;
        taskItem.Project_Profile__c = serviceItemItem.Project_Profile__c;
        taskItem.Service_Name__c = serviceItemItem.Service_Name_Full__c;
        taskItem.X3rd_Party_Authority_ID__c = serviceItemItem.Municipal_Agency_ID__c;
        taskItem.X3rd_Party_Issue_Date__c = serviceItemItem.X3rd_Party_Issue_Date__c;
        taskItem.X3rd_Party_Disapproved_Date__c = serviceItemItem.X3rd_Party_Disapproved_Date__c;
        taskItem.X3rd_Party_Description__c = serviceItemItem.X3rd_Party_Description__c;
        taskItem.Type_in_Municipal_Agency_Name__c = serviceItemItem.Type_in_Municipal_Agency_Name__c;

        UserServices.prepareUserRoleNameToUserId();

        if ( !String.isEmpty( taskTemplate.Resources__c ) ) {
            if( projectTeamItem != null ){
                if ( taskTemplate.Resources__c == ProjectTeamServices.RESOURCE_ROLE_FILLING_REP ){
                    taskItem.OwnerId = proposalItem.FREP__c; //projectTeamItem.FREP__c; //MRS-6571
                    taskItem.Manager_Lookup__c = projectTeamItem.Project_Member__c;
                } else if ( taskTemplate.Resources__c == ProjectTeamServices.RESOURCE_ROLE_MEMBER ) {
                    taskItem.OwnerId = projectTeamItem.Project_Member__c;
                    taskItem.Manager_Lookup__c = projectTeamItem.Project_Manager__c;
                } else if ( taskTemplate.Resources__c == ProjectTeamServices.RESOURCE_ROLE_MANAGER ) {
                    taskItem.OwnerId = projectTeamItem.Project_Manager__c;
                    taskItem.Manager_Lookup__c = projectTeamItem.Project_Manager__c;
                } else if ( taskTemplate.Resources__c == ProjectTeamServices.RESOURCE_ROLE_PRODUCTION_MANAGER ) {
                    taskItem.OwnerId = projectTeamItem.Production_Manager__c;
                    taskItem.Manager_Lookup__c = projectTeamItem.Production_Manager__c;
                }
            }
            if ( UserServices.userRoleNameToUserId.containsKey( taskTemplate.Resources__c ) ) {
                if( taskTemplate.Resources__c == UserServices.ROLE_MANAGER_OF_ACCOUNTS && proposalItem.Account_Executive__c != null ){
                    //MRS-6405
                    taskItem.OwnerId       = proposalItem.Account_Executive__c;
                }else{
                    taskItem.OwnerId       = UserServices.userRoleNameToUserId.get(taskTemplate.Resources__c);
                }

                taskItem.Manager_Lookup__c = UserServices.userRoleNameToUserId.get(taskTemplate.Resources__c);
            }
        }

        if( taskItem.OwnerId == null && serviceItemItem.Service_Template__r.RecordType.Name == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME ) {
            if ( String.isEmpty(taskItem.Task_Template__r.Resources__c) || !UserServices.userRoleNameToUserId.containsKey( taskItem.Task_Template__r.Resources__c ) ){
                for( String item: UserServices.userRoleNameToUserId.keySet() ){
                    if( item.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) && item.contains( serviceItemItem.Proposal__r.Region__c ) ){
                        taskItem.OwnerId           = UserServices.userRoleNameToUserId.get( item );
                        taskItem.Manager_Lookup__c = UserServices.userRoleNameToUserId.get( item );
                        break;
                    }
                }
            }
        }

        if( taskItem.OwnerId == null ) {
            taskItem.OwnerId = serviceItemItem.OwnerId;
        }

        if( alternativeDurration != null ) {
            taskItem.Delay_End_Date__c = DateUtils.appendDurations( alternativeDurration, taskItem.Expected_Duration__c );
        }
        return taskItem;
    }

    public static Task_Item__c createTaskItemFromTaskTemplate( Task_Template__c taskTemplate ) {
        Task_Item__c taskItem = new Task_Item__c();
        taskItem.Name = taskTemplate.Name;
        taskItem.Status__c = TASK_ITEM_STATUS_NOT_STARTED;
        taskItem.Billing_Trigger__c = taskTemplate.Billing_Trigger__c;
        taskItem.Billing_Percentage__c = taskTemplate.Billing_Percentage__c;
        taskItem.Task_Template__c = taskTemplate.Id;
        taskItem.Description__c = taskTemplate.Description__c;
        taskItem.Notes__c = taskTemplate.Notes__c;
        taskItem.Action__c = taskTemplate.Task_Action__c;
        taskItem.Input__c = taskTemplate.Input__c;
        taskItem.Resources__c = taskTemplate.Resources__c;
        taskItem.Artifacts__c = taskTemplate.Artifacts__c;
        taskItem.Financial_Force_Integration__c = taskTemplate.Financial_Force_Integration__c;
        taskItem.Results__c = taskTemplate.Results__c;
        taskItem.Sequence_Number__c = taskTemplate.Sequence_Number__c;
        taskItem.Planned_Durration__c = taskTemplate.Standard_Duration__c;
        taskItem.Expected_Duration__c = taskTemplate.Standard_Duration__c;
        taskItem.Predecessor_Milestone_from_Template__c= taskTemplate.Predecessor_Milestone__c;
        taskItem.Successor_Milestone_from_Template__c= taskTemplate.Successor_Milestone__c;
        taskItem.Reminder_Offset__c = taskTemplate.Reminder_Offset__c;
        taskItem.Forms__c = taskTemplate.Forms__c;

        return taskItem;
    }

    public static Map<String, Map<Id, Task_Item__c>> filterTasksWithUpdatedActualDate( List<Task_Item__c> commingTasks, Map<Id, Task_Item__c> oldTasks ) {
        Map<String, Map<Id, Task_Item__c>> filteredTasksWithDateField = new Map<String, Map<Id, Task_Item__c>>();
        filteredTasksWithDateField.put( START_DATE_FIELD, new Map<Id, Task_Item__c>() );
        filteredTasksWithDateField.put( END_DATE_FIELD, new Map<Id, Task_Item__c>() );

        Map<Id, Task_Item__c> filteredTaskItems = new Map<Id, Task_Item__c>();
        for( Task_Item__c tItem : commingTasks ) {
            if( tItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID ) {
                Task_Item__c oldTask = oldTasks.get( tItem.Id );
                if( tItem.Actual_Start_Date__c != oldTask.Actual_Start_Date__c ) {
                    filteredTasksWithDateField.get( START_DATE_FIELD ).put( tItem.Id, tItem );
                }
                if( tItem.Actual_End_Date__c != oldTask.Actual_End_Date__c ) {
                        filteredTasksWithDateField.get( END_DATE_FIELD ).put( tItem.Id, tItem );
                }
            }
        }
        return filteredTasksWithDateField;
    }

    public static Map<Id, Task_Item__c> filterTasksWithUpdatedActualDate( List<Task_Item__c> commingTasks, Map<Id, Task_Item__c> oldTasks, Boolean isStartDate ) {
        Map<Id, Task_Item__c> filteredTaskItems = new Map<Id, Task_Item__c>();
        for( Task_Item__c tItem : commingTasks ) {
            if( tItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID ) {
                if( isStartDate ){
                    if( tItem.Actual_Start_Date__c != oldTasks.get( tItem.Id ).Actual_Start_Date__c ) {
                        filteredTaskItems.put( tItem.Id, tItem );
                    }
                } else {
                    if( tItem.Actual_End_Date__c != oldTasks.get( tItem.Id ).Actual_End_Date__c ) {
                        filteredTaskItems.put( tItem.Id, tItem );
                    }
                }
            }
        }
        return filteredTaskItems;
    }

    public static void calculateActualDurationForTasks( Map<Id, Task_Item__c> incommingTasks ) {
        for( Task_Item__c currentTask : incommingTasks.values() ) {
            currentTask.Actual_Duration__c = DateUtils.getDifferenceBetweanTwoDatetimes( currentTask.Actual_Start_Date__c, currentTask.Actual_End_Date__c, true );
        }

    }

    public static Map<Id, Id> getTaskLinesForConditionalTaskTemplates( Map<Id, List<Id>> taskTemplateIdToTaskItemIdList, Map<Id, Task_Item__c> incommingTasks ) {
        Map<Id, Id> taskLineIdToConditionalTaskTemplateId = new Map<Id, Id>();
        if ( taskTemplateIdToTaskItemIdList == null ){
            taskTemplateIdToTaskItemIdList = new Map<Id, List<Id>>();
            for( Task_Item__c taskItem : incommingTasks.values() ) {
                if( !taskTemplateIdToTaskItemIdList.containsKey( taskItem.Task_Template__c ) ) {
                    taskTemplateIdToTaskItemIdList.put( taskItem.Task_Template__c, new List<Id>() );
                }
                taskTemplateIdToTaskItemIdList.get( taskItem.Task_Template__c ).add( taskItem.Id );
            }
        }
        tasksNeedBillingLineItemDisapprovalStatus = new Map<Id, Boolean>();
        for (Id taskItemId : incommingTasks.keySet()){tasksNeedBillingLineItemDisapprovalStatus.put(taskItemId, true);}

        for( Task_Template__c taskTempl : [ Select Id, Name,
                                                   ( Select Id, Condition__c, Task_Line__c
                                                     From Task_State_Changes__r
                                                     Where Condition__c != null )
                                            From Task_Template__c
                                            Where Id IN :taskTemplateIdToTaskItemIdList.keySet() ] ) {
            for( Task_State_Change__c tsc : taskTempl.Task_State_Changes__r ) { // taskTempl.Task_State_Changes__r.size() can be 0 or 1
                for( Id conditionalTaskItemId : taskTemplateIdToTaskItemIdList.get( taskTempl.Id ) ){
                    if( tsc.Condition__c.equals( incommingTasks.get( conditionalTaskItemId ).Status__c ) ) {
                        taskLineIdToConditionalTaskTemplateId.put( tsc.Task_Line__c, taskTempl.Id );
                        tasksNeedBillingLineItemDisapprovalStatus.put(conditionalTaskItemId, false);
                        break;
                    }
                }
            }
        }
        return taskLineIdToConditionalTaskTemplateId;
    }

    public static void insertAlternativeTaskLineToConditionalTasks( Map<Id, Task_Item__c> incommingTasks ) {
        if( incommingTasks.isEmpty() ) return;

        Map<Id, List<Id>> taskTemplateIdToTaskItemIdList = new Map<Id, List<Id>>();
        Map<String, Id> taskItemIdToSuccessorItemId = new Map<String, Id>();
        Map<String, Integer> conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber = new Map<String, Integer>();
        List<Task_Item__c> successorsToUpdateList = new List<Task_Item__c>();
        Map<Id, Integer> serviceIdToNumOfAltTasks = new Map<Id, Integer>();

        if ( runInFutureMethod ){
            incommingTasks = new Map<Id,Task_Item__c>([SELECT Id, Service_Name__c, X3rd_Party_Authority_ID__c, X3rd_Party_Issue_Date__c, X3rd_Party_Disapproved_Date__c,
                                                            X3rd_Party_Description__c, Type_in_Municipal_Agency_Name__c, Project_Region__c, Service_Item__c, Sequence_Number__c,
                                                            Task_Template__c, Successor_Task__c, Project_Profile__c, OwnerId, Billing_Percentage__c, Status__c, Manager_Lookup__c
                                                       FROM Task_Item__c
                                                       WHERE Id IN : incommingTasks.keySet()]);
        }

        for( Task_Item__c taskItem : incommingTasks.values() ) {
            if( !taskTemplateIdToTaskItemIdList.containsKey( taskItem.Task_Template__c ) ) {
                taskTemplateIdToTaskItemIdList.put( taskItem.Task_Template__c, new List<Id>() );
            }
            taskTemplateIdToTaskItemIdList.get( taskItem.Task_Template__c ).add( taskItem.Id );
        }

        // Get filtered conditional Tasks for which is needed create Alternativ Tasks from Task Line
        Map<Id, Id> taskLineIdToConditionalTaskTemplateId = getTaskLinesForConditionalTaskTemplates( taskTemplateIdToTaskItemIdList, incommingTasks );
        if( taskLineIdToConditionalTaskTemplateId.isEmpty() ) return;

        Map<Id, Task_Template__c> taskTemplatesForClones = new Map<Id, Task_Template__c>( [ Select Id, Standard_Duration__c, Name, Results__c, Description__c, Financial_Force_Integration__c,
                                                                                                      Input__c, Notes__c, Resources__c, Task_Action__c, Billing_Trigger__c,
                                                                                                      Predecessor_Milestone__c, Successor_Milestone__c, Billing_Percentage__c, Artifacts__c,
                                                                                                      Predecessor_Task__c, Successor_Task__c, Service__c, Sequence_Number__c, Forms__c, Reminder_Offset__c
                                                                                               From Task_Template__c
                                                                                               Where Id IN :taskLineIdToConditionalTaskTemplateId.values() ] );

        List<Task_Template__c> taskTemplatesFromTaskLineList = new List<Task_Template__c>( [ Select Id, Standard_Duration__c, Name, Results__c, Description__c, Financial_Force_Integration__c,
                                                                                                      Input__c, Notes__c, Resources__c, Task_Action__c, Billing_Trigger__c,
                                                                                                      Predecessor_Milestone__c, Successor_Milestone__c, Billing_Percentage__c, Artifacts__c,
                                                                                                      Predecessor_Task__c, Successor_Task__c, Service__c, Sequence_Number__c, Forms__c, Reminder_Offset__c
                                                                                               From Task_Template__c
                                                                                               Where Service__c IN :taskLineIdToConditionalTaskTemplateId.keySet()
                                                                                               Order By Sequence_Number__c ] );

        Map<Id, Task_Template__c> taskTemplatesFromTaskLines = new Map<Id, Task_Template__c>( taskTemplatesFromTaskLineList ); // With Map directly does not work properly (Order By does not work)

        for( Task_Template__c taskTemplate : taskTemplatesFromTaskLineList ) {
            if( !serviceIdToNumOfAltTasks.containsKey( taskTemplate.Service__c ) ){
                serviceIdToNumOfAltTasks.put( taskTemplate.Service__c, 0 );
            }
            serviceIdToNumOfAltTasks.put( taskTemplate.Service__c, serviceIdToNumOfAltTasks.get( taskTemplate.Service__c ) + 1 );
        }

        TaskManagementServices.seqNumberToTaskItemForService = new Map<Id, Map<Integer, Task_Item__c>>();

         //Go through the list of Task Templates that came from Task Lines
        for( Task_Template__c taskTemplate : taskTemplatesFromTaskLineList ) {
            Id condTaskTemplId = taskLineIdToConditionalTaskTemplateId.get( taskTemplate.Service__c ); // Get Conditional Task Template Id
            Task_Template__c conditionalTaskTemplate = taskTemplatesForClones.get( condTaskTemplId );

            //Put Clonned Conditional Task Template to map with Task Line's Task Templates
            taskTemplatesFromTaskLines.put( condTaskTemplId, conditionalTaskTemplate );

            for( Id condTaskItemId : taskTemplateIdToTaskItemIdList.get( condTaskTemplId ) ) {
                Task_Item__c conditionalTaskItem = incommingTasks.get( condTaskItemId ); // Get Conditional Task Item
                String bigKey = (String)condTaskItemId + '_' + (String)condTaskTemplId;

                Task_Item__c taskItem = createTaskItemFromTaskTemplate( taskTemplate ); // Create Task Item from Task Template
                if( TASK_ITEM_RECORD_TYPE_IDS.containsKey( taskTemplate.Name ) ) {
                    taskItem.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( taskTemplate.Name );
                } else {
                    taskItem.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( PROJECT_TASK_RECORD_TYPE );
                }

                taskItem.Service_Name__c = conditionalTaskItem.Service_Name__c;
                taskItem.Name = taskTemplate.Name;
                taskItem.X3rd_Party_Authority_ID__c = conditionalTaskItem.X3rd_Party_Authority_ID__c;
                taskItem.X3rd_Party_Issue_Date__c = conditionalTaskItem.X3rd_Party_Issue_Date__c;
                taskItem.X3rd_Party_Disapproved_Date__c = conditionalTaskItem.X3rd_Party_Disapproved_Date__c;
                taskItem.X3rd_Party_Description__c = conditionalTaskItem.X3rd_Party_Description__c;
                taskItem.Type_in_Municipal_Agency_Name__c = conditionalTaskItem.Type_in_Municipal_Agency_Name__c;
                taskItem.Alternative__c = true;
                taskItem.Project_Region__c = conditionalTaskItem.Project_Region__c;

                if( !TaskManagementServices.seqNumberToTaskItemForService.containsKey( conditionalTaskItem.Service_Item__c )  ) {
                    TaskManagementServices.seqNumberToTaskItemForService.put( conditionalTaskItem.Service_Item__c, new Map<Integer, Task_Item__c>() );
                }

                // Check if clone of Conditional Task exists for given Task Item
                if( !conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber.containsKey( bigKey ) ) { //First time Empty;
                    Integer currSeqNumber = Integer.valueOf( conditionalTaskItem.Sequence_Number__c ); // Get sequence number of Conditional Task

                    Task_Item__c clonnedConditionalTask = createTaskItemFromTaskTemplate( conditionalTaskTemplate );
                    if( TASK_ITEM_RECORD_TYPE_IDS.containsKey( conditionalTaskTemplate.Name ) ) {
                        clonnedConditionalTask.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( conditionalTaskTemplate.Name );
                    } else {
                        clonnedConditionalTask.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get( PROJECT_TASK_RECORD_TYPE );
                    }
                    clonnedConditionalTask.Sequence_Number__c = currSeqNumber + serviceIdToNumOfAltTasks.get( taskTemplate.Service__c ) + 1;
                    clonnedConditionalTask.Project_Profile__c = conditionalTaskItem.Project_Profile__c;
                    clonnedConditionalTask.Service_Item__c = conditionalTaskItem.Service_Item__c;
                    clonnedConditionalTask.OwnerId = conditionalTaskItem.OwnerId;
                    clonnedConditionalTask.Service_Name__c = conditionalTaskItem.Service_Name__c;
                    clonnedConditionalTask.Billing_Percentage__c = conditionalTaskItem.Billing_Percentage__c;
                    clonnedConditionalTask.X3rd_Party_Authority_ID__c = conditionalTaskItem.X3rd_Party_Authority_ID__c;
                    clonnedConditionalTask.X3rd_Party_Issue_Date__c = conditionalTaskItem.X3rd_Party_Issue_Date__c;
                    clonnedConditionalTask.X3rd_Party_Disapproved_Date__c = conditionalTaskItem.X3rd_Party_Disapproved_Date__c;
                    clonnedConditionalTask.X3rd_Party_Description__c = conditionalTaskItem.X3rd_Party_Description__c;
                    clonnedConditionalTask.Type_in_Municipal_Agency_Name__c = conditionalTaskItem.Type_in_Municipal_Agency_Name__c;
                    clonnedConditionalTask.Alternative__c = true;
                    clonnedConditionalTask.Project_Region__c = conditionalTaskItem.Project_Region__c;
                    //cloned task inherits this value
                    conditionalTaskItem.Billing_Percentage__c = 0;

                    conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber.put( bigKey, currSeqNumber + 1 );

                    TaskManagementServices.seqNumberToTaskItemForService.get( conditionalTaskItem.Service_Item__c ).put( Integer.valueOf(clonnedConditionalTask.Sequence_Number__c ), clonnedConditionalTask );
                } else {  // Conditional Task exists for given Tast Item;
                    conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber.put( bigKey, conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber.get( bigKey ) + 1 );
                }

                taskItem.Project_Profile__c = conditionalTaskItem.Project_Profile__c;
                taskItem.Service_Item__c = conditionalTaskItem.Service_Item__c;
                taskItem.OwnerId = conditionalTaskItem.OwnerId;
                taskItem.Manager_Lookup__c = conditionalTaskItem.Manager_Lookup__c;
                taskItem.Predecessor_Task__c = conditionalTaskItem.Id;

                taskItem.Sequence_Number__c = conditionalTemplateIdWithNextAfterConditionalTaskSeqNumber.get( bigKey );

                taskItemIdToSuccessorItemId.put( (String)conditionalTaskItem.Id + '_' + (String)conditionalTaskItem.Task_Template__c, conditionalTaskItem.Successor_Task__c );

                TaskManagementServices.seqNumberToTaskItemForService.get( taskItem.Service_Item__c ).put( Integer.valueOf( taskItem.Sequence_Number__c ), taskItem );
            }
        }
        Map<Id, Task_Item__c> successorTasksForConditionalTasks = new Map<Id, Task_Item__c> (
                                                                            [ Select Id, Name, Predecessor_Task__c, Successor_Task__c,
                                                                                     Sequence_Number__c, Expected_Duration__c, Actual_Start_Date__c
                                                                              From Task_Item__c
                                                                              Where Id IN: taskItemIdToSuccessorItemId.values() ]
                                                                  );

        List<Task_Item__c> tasksToInsert = new List<Task_Item__c>();
        for( Id serviceId : TaskManagementServices.seqNumberToTaskItemForService.keySet() ) {
            tasksToInsert.addAll( TaskManagementServices.seqNumberToTaskItemForService.get( serviceId ).values() );
        }
        insert tasksToInsert;

        Map<Id, Task_Item__c> insertedTasksMap = new Map<Id, Task_Item__c>( tasksToInsert );

        Map<Id, Integer> serviceIdToLastSeqNumber = new Map<Id, Integer>();

        // Linck with Successors and Predecessors Tasks
        for( Id serviceId : TaskManagementServices.seqNumberToTaskItemForService.keySet() ) {
            Map<Integer, Task_Item__c> orderedListOfTasks = TaskManagementServices.seqNumberToTaskItemForService.get( serviceId );
            List<Integer> ranksList = new List<Integer>();
            ranksList.addAll( orderedListOfTasks.keySet() );
            ranksList.sort();

            Task_Item__c firstTaskInRow;
            Task_Item__c lastTaskInRow;

            for( Integer sequenceNumber : ranksList ) {
                Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );
                if( firstTaskInRow == null ) firstTaskInRow = taskItem;
                lastTaskInRow = taskItem;

                // ------------------------------------------------------------
                // Predecessor/Successor definition for Tasks
                Boolean predeseccorFound = false;
                Boolean successorFound = false;
                Id taskTemplatePredecessorId = taskTemplatesFromTaskLines.get( taskItem.Task_Template__c ).Predecessor_Task__c;
                Id taskTemplateSuccessorId = taskTemplatesFromTaskLines.get( taskItem.Task_Template__c ).Successor_Task__c;

                for( Task_Item__c relatedTask : TaskManagementServices.seqNumberToTaskItemForService.get( serviceId ).values() ) {
                    Task_Template__c relatedTaskTemplate = taskTemplatesFromTaskLines.get( relatedTask.Task_Template__c );

                    if( relatedTaskTemplate == null ) continue;

                    if( taskTemplatePredecessorId == null ) predeseccorFound = true;
                    if( taskTemplateSuccessorId == null ) successorFound = true;

                    if( !predeseccorFound && relatedTaskTemplate.Id == taskTemplatePredecessorId ) {
                        taskItem.Predecessor_Task__c = relatedTask.Id;
                        predeseccorFound = true;
                    }
                    if( !successorFound && relatedTaskTemplate.Id == taskTemplateSuccessorId ) {
                        taskItem.Successor_Task__c = relatedTask.Id;
                        successorFound = true;
                    }
                    if( predeseccorFound && successorFound ) break;
                }

                if( incommingTasks.containsKey( taskItem.Predecessor_Task__c ) ) {
                    taskItem.Expected_Start_Date__c = incommingTasks.get( taskItem.Predecessor_Task__c ).Expected_End_Date__c;
                } else if( insertedTasksMap.containsKey( taskItem.Predecessor_Task__c ) ) {
                    taskItem.Expected_Start_Date__c = insertedTasksMap.get( taskItem.Predecessor_Task__c ).Expected_End_Date__c;
                }
                if( taskItem.Expected_Start_Date__c != null ) {
                    taskItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( taskItem.Expected_Start_Date__c, taskItem.Expected_Duration__c );
                }
            }
            Task_Item__c conditionalTaskToUpdate = incommingTasks.get( firstTaskInRow.Predecessor_Task__c );
            Task_Item__c successorToUpdate = successorTasksForConditionalTasks.get( taskItemIdToSuccessorItemId.get( (String)conditionalTaskToUpdate.Id + '_' + (String)conditionalTaskToUpdate.Task_Template__c ) );

            if( test.isRunningTest() && successorToUpdate == null ) {
                successorToUpdate = firstTaskInRow.clone();
            }

            conditionalTaskToUpdate.Successor_Task__c = firstTaskInRow.Id;
        if ( System.isFuture() ) tasksToInsert.add(new Task_Item__c(Id = conditionalTaskToUpdate.Id, Billing_Percentage__c = 0, Successor_Task__c = conditionalTaskToUpdate.Successor_Task__c));
            successorToUpdate.Predecessor_Task__c = lastTaskInRow.Id;

            Integer lastOldSeqNumber = Integer.valueOf( successorToUpdate.Sequence_Number__c );

            serviceIdToLastSeqNumber.put( serviceId, lastOldSeqNumber + 1 );

            successorToUpdate.Sequence_Number__c = lastTaskInRow.Sequence_Number__c + 1;

            lastTaskInRow.Successor_Task__c = successorToUpdate.Id;

            Task_Item__c prevTask = TaskManagementServices.seqNumberToTaskItemForService.get( lastTaskInRow.Service_Item__c ).get( Integer.valueOf( lastTaskInRow.Sequence_Number__c - 1 ) );

            lastTaskInRow.Predecessor_Task__c = prevTask.Id;
            prevTask.Successor_Task__c = lastTaskInRow.Id;

            lastTaskInRow.Expected_Start_Date__c = prevTask.Expected_End_Date__c;
            lastTaskInRow.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( lastTaskInRow.Expected_Start_Date__c, lastTaskInRow.Expected_Duration__c );

            if( successorToUpdate.Actual_Start_Date__c == null ) {
                successorToUpdate.Expected_Start_Date__c = lastTaskInRow.Expected_End_Date__c;
                successorToUpdate.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( successorToUpdate.Expected_Start_Date__c, successorToUpdate.Expected_Duration__c );
            }

            successorsToUpdateList.add( successorToUpdate );
            // LOOP will be used only for Termination. Bad solution but only one
            for( Id serId : serviceIdToLastSeqNumber.keySet() ) {
                for( Service_Item__c outServ : [ Select Id, Service_Template__c,
                                                        ( Select Id, Name, Sequence_Number__c
                                                           From Task_Items__r
                                                           Where Sequence_Number__c > :serviceIdToLastSeqNumber.get( serId )
                                                           AND Id NOT IN: tasksToInsert
                                                           Order By Sequence_Number__c )
                                                 From Service_Item__c Where Id =: serId ] ) {
                    for( Task_Item__c outTask : outServ.Task_Items__r ){
                        outTask.Sequence_Number__c += serviceIdToNumOfAltTasks.get( outServ.Service_Template__c ) + 1;//tasksToInsert.size() + 1;
                        successorsToUpdateList.add( outTask );
                    }
                }
            }
        }
        tasksToInsert.addAll( successorsToUpdateList );

        taskCalculationPreventor = true;

        upsert tasksToInsert;

        taskCalculationPreventor = false;

        if( taskLineIdToConditionalTaskTemplateId.size() == 1 && incommingTasks.size() == 1 ) {
            updateExpectedDatesForAllServices( incommingTasks, false );
        }
    }

    public static List<Task_Item__c> filteredTaskForServiceItemUpdate(List<Task_Item__c> taskItemListNew, Map<Id, Task_Item__c> taskItemMapOld){
        List<Task_Item__c> filteredTaskItemList = new List<Task_Item__c>();
        for ( Task_Item__c taskItem : taskItemListNew ) {
            if ( taskItem.Service_Item__c != null &&
                ( ( taskItem.Predecessor_Milestone__c != taskItemMapOld.get( taskItem.Id ).Predecessor_Milestone__c ) ||
                  ( taskItem.Successor_Milestone__c != taskItemMapOld.get( taskItem.Id ).Successor_Milestone__c )
                )
               ) {
                filteredTaskItemList.add(taskItem);
            }
        }
        return filteredTaskItemList;
    }

    public static void updateServiceItemPredecessorSuccessor( List<Task_Item__c> taskItemListNew ) {
        if ( taskItemListNew.isEmpty() ) return;

        Map<Id, Service_Item__c> serviceItemMapForUpdate = new Map<Id, Service_Item__c>();

        for ( Task_Item__c taskItem : taskItemListNew ) {
            if ( !serviceItemMapForUpdate.containsKey( taskItem.Service_Item__c ) ) {
                serviceItemMapForUpdate.put( taskItem.Service_Item__c, new Service_Item__c( Id = taskItem.Service_Item__c ) );
            }
        }
        List<Task_Item__c> taskItemListWithService = [ SELECT Id, Service_Item__c, Predecessor_Milestone__c,
                                                              Successor_Milestone__c, Predecessor_Milestone__r.Name,
                                                              Successor_Milestone__r.Name, RecordType.Name
                                                       FROM Task_Item__c
                                                       WHERE Service_Item__c IN : serviceItemMapForUpdate.keySet()
                                                             AND ( Predecessor_Milestone__c != null OR Successor_Milestone__c != null )
                                                             AND RecordType.Name != : TaskManagementServices.MILESTONE_RECORDTYPE_NAME ];
        for ( Task_Item__c taskItem : taskItemListWithService ) {
            if( taskItem.Predecessor_Milestone__c != null ) {
                serviceItemMapForUpdate.get( taskItem.Service_Item__c ).Predecessor_Milestone__c = taskItem.Predecessor_Milestone__r.Name;
            }
            if( taskItem.Successor_Milestone__c != null ) {
                serviceItemMapForUpdate.get(taskItem.Service_Item__c).Successor_Milestone__c = taskItem.Successor_Milestone__r.Name;
            }
        }
        if( !serviceItemMapForUpdate.isEmpty() ){
            try{
                update serviceItemMapForUpdate.values();
            } catch (DMLException dmlEx){
                if ( Trigger.isExecuting ){
                    for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                        Id serviceId = serviceItemMapForUpdate.values()[dmlEx.getDmlIndex(i)].Id;
                            for (Task_Item__c taskItem : taskItemListNew){
                                if (taskItem.Service_Item__c == serviceId){
                                    taskItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                                }
                            }
                    }
                } else {
                    throw new ErrorException( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                }
            }
        }
    }

    public static Map<Id, Set<Id>> filteredProjectTeamIdToProjectProfileIdSet ( List<Task_Item__c> taskItemListNew, Map<Id, Task_Item__c> taskItemMapOld ) {
        Map<Id, Set<Id>> filteredProjectTeamIdToProjectProfileIdSet = new Map<Id, Set<Id>>();
        Set<Id> filteredProjectProfileIdList= new Set<Id>();
        for (Task_Item__c taskItem : taskItemListNew){
            if ( taskItemMapOld == null || (taskItem.Project_Profile__c != null && taskItem.Actual_End_Date__c != taskItemMapOld.get(taskItem.id).Actual_End_Date__c) ) {
                filteredProjectProfileIdList.add(taskItem.Project_Profile__c);
            }
        }

        if (filteredProjectProfileIdList.isEmpty()){
            return filteredProjectTeamIdToProjectProfileIdSet;
        }

        for ( Project_Profile__c item: [Select Id, Project_Team__c From Project_Profile__c Where Id IN: filteredProjectProfileIdList ]){
            if( !filteredProjectTeamIdToProjectProfileIdSet.containsKey(item.Project_Team__c) ){
                filteredProjectTeamIdToProjectProfileIdSet.put(item.Project_Team__c, new Set<Id>());
            }
            filteredProjectTeamIdToProjectProfileIdSet.get(item.Project_Team__c).add(item.Id);
        }
        return filteredProjectTeamIdToProjectProfileIdSet;
    }

    //Author: Shkrobot Vitaliy (30.04.2014) new method
    public static void updateServiceActualStartDateActualEndDate( Map<String, Map<Id, Task_Item__c>> filteredTasksWithDateField, Map<Id, Task_Item__c> taskItemMapOld ) {
        if ( ( filteredTasksWithDateField.get(START_DATE_FIELD) == null || filteredTasksWithDateField.get(START_DATE_FIELD).isEmpty() ) &&
             ( filteredTasksWithDateField.get(END_DATE_FIELD)   == null || filteredTasksWithDateField.get(END_DATE_FIELD).isEmpty() ) ){
            return;
        }

        Boolean isStartDateChanged = filteredTasksWithDateField.get( END_DATE_FIELD ).isEmpty();

        List<Task_Item__c> filteredTaskItemList = isStartDateChanged ? filteredTasksWithDateField.get( START_DATE_FIELD ).values() : filteredTasksWithDateField.get( END_DATE_FIELD ).values();

        String queryString = 'SELECT Id, Actual_Start_Date__c, Actual_End_Date__c, Actual_Duration__c, ' +
                                    'Expected_Start_Date__c, Expected_End_Date__c, Expected_Service_Duration__c, ' +
                                    '( Select Id, Actual_End_Date__c, Actual_Start_Date__c' +
                                    ' From Task_Items__r ORDER BY ';
        queryString += isStartDateChanged ? 'Actual_Start_Date__c ASC NULLS LAST LIMIT 1' : ' Actual_End_Date__c DESC NULLS FIRST LIMIT 1';
        queryString += ' ) FROM Service_Item__c WHERE ID IN ( ';

        for (Task_Item__c taskItemItem : filteredTaskItemList){
            if ( taskItemItem.Service_Item__c != null ){
                queryString += '\'' + String.valueOf(taskItemItem.Service_Item__c) + '\', ';
            }
        }

        queryString = queryString.removeEnd(', ');
        queryString += ' ) ';

        List<Service_Item__c> serviceItemForUpdateList;

        try {
            serviceItemForUpdateList = (List<Service_Item__c>)Database.query(queryString);
        } catch (Exception ex){
            if (Trigger.isExecuting){
                for (Task_Item__c taskItemItem : filteredTaskItemList){
                    taskItemItem.addError( Label.Update_Task_Item_Error + ex.getMessage() );
                }
            } else {
                throw new ErrorException( Label.Update_Task_Item_Error + ex.getMessage() );
            }
            return;
        }

        for (Service_Item__c serviceItemItem : serviceItemForUpdateList){
            if (isStartDateChanged){
                if ( (serviceItemItem.Actual_Start_Date__c == null && serviceItemItem.Task_Items__r[0].Actual_Start_Date__c != null) ||
                    (serviceItemItem.Actual_Start_Date__c > serviceItemItem.Task_Items__r[0].Actual_Start_Date__c) ) {
                    serviceItemItem.Actual_Start_Date__c = serviceItemItem.Task_Items__r[0].Actual_Start_Date__c;
                }
            } else {
                if ( (serviceItemItem.Task_Items__r[0].Actual_End_Date__c != null && serviceItemItem.Actual_End_Date__c == null) ||
                      (serviceItemItem.Actual_End_Date__c < serviceItemItem.Task_Items__r[0].Actual_End_Date__c ) ){
                    serviceItemItem.Actual_End_Date__c = serviceItemItem.Task_Items__r[0].Actual_End_Date__c;
                    serviceItemItem.Actual_Duration__c = serviceItemItem.Expected_Service_Duration__c;
                }
            }
        }

        try{
            update serviceItemForUpdateList;
        } catch (DMLException dmlEx) {
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    Id serviceId = serviceItemForUpdateList[dmlEx.getDmlIndex(i)].Id;
                    for (Task_Item__c taskItemItem : filteredTaskItemList){
                        if (taskItemItem.Service_Item__c == serviceId){
                            taskItemItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                        }
                    }
                }
            } else {
                throw new ErrorException( Label.Update_Task_Item_Error + dmlEx.getMessage() );
            }
        }
    }

    private static Map<Id, Service_Item__c> populateServicesWithTasks(Id projectProfileId){
        return ServiceItemServices.getServiceItemsWithTaskItemsByProjectId( projectProfileId,
                                                                            new Set<String>{ServiceItemServices.SERVICE_STATUS_NOTSTARTED,
                                                                                            ServiceItemServices.SERVICE_STATUS_ACTIVE,
                                                                                            ServiceItemServices.SERVICE_STATUS_COMPLETED } );
    }

    // WORKS ONLY FOR ONE TASK ITEM (MANUAL UPDATING OF TASK)!!!
    public static void updateExpectedDatesForAllServices( Map<Id, Task_Item__c> commingTasks, Boolean isStartDate ) {
        Task_Item__c processingTask = commingTasks.values()[0];

        if ( servicesWithTasks == null ){
            servicesWithTasks = populateServicesWithTasks( processingTask.Project_Profile__c );
        }

        Service_Item__c serviceItem = servicesWithTasks.get( processingTask.Service_Item__c );
        if( serviceItem == null ) return;

        List<Task_Item__c> milestones = new List<Task_Item__c>();
        if( processingTask.Predecessor_Milestone__c != null ) {
            serviceItem.Expected_Start_Date__c = processingTask.Expected_Start_Date__c;
            serviceItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( serviceItem.Expected_Start_Date__c,
                                                                                                  serviceItem.Expected_Service_Duration__c );
            if( isStartDate ) {
                milestones.add( updateActualEndDateForMilestone( processingTask, isStartDate ) );
            }
        }

        if( processingTask.Successor_Milestone__c != null ) {
            serviceItem.Expected_End_Date__c = processingTask.Expected_End_Date__c;

            if( !isStartDate ) {
                milestones.add( updateActualEndDateForMilestone( processingTask, isStartDate ) );
            }
        }

        if( !milestones.isEmpty() ){
            try {
                update milestones;
            } catch( DMLException ex ){
                if( Trigger.isExecuting ){
                    processingTask.addError( ex.getDMLMessage(0) );
                } else {
                    throw new ErrorException( ex.getMessage() );
                }
            }
        }

        serviceItem.Expected_Service_Duration__c = '0d';
        TaskManagementServices.seqNumberToTaskItemForService = new Map<Id, Map<Integer, Task_Item__c>>();

        TaskManagementServices.seqNumberToTaskItemForService.put( serviceItem.Id, new Map<Integer, Task_Item__c>() );

        Boolean isActualStartDate = false;
        for( Task_Item__c tItem : serviceItem.Task_Items__r ) {
            if( tItem.Id == processingTask.Id ) {
                tItem.Expected_Start_Date__c = processingTask.Expected_Start_Date__c;
                tItem.Expected_End_Date__c = processingTask.Expected_End_Date__c;
                tItem.Expected_Duration__c = processingTask.Expected_Duration__c;
                tItem.Actual_Start_Date__c = processingTask.Actual_Start_Date__c;
                tItem.Actual_End_Date__c = processingTask.Actual_End_Date__c;
            } else if( !isStartDate && tItem.Actual_Start_Date__c != null && tItem.Sequence_Number__c > processingTask.Sequence_Number__c ) {
                isActualStartDate = true;
            }
            TaskManagementServices.seqNumberToTaskItemForService.get( serviceItem.Id ).put( Integer.valueOf(tItem.Sequence_Number__c), tItem );
            if (!String.isEmpty(tItem.Expected_Duration__c)){
                serviceItem.Expected_Service_Duration__c = DateUtils.appendDurations(serviceItem.Expected_Service_Duration__c, tItem.Expected_Duration__c);
            }
        }

        if( isActualStartDate ) {
            try {

                serviceItem.Expected_Start_Date__c = null;
                serviceItem.Expected_End_Date__c = null;
                Boolean doRecalculate = false;
                for (Task_Item__c ti : serviceItem.Task_Items__r){
                    if (ti.Expected_End_Date__c != null && (serviceItem.Expected_End_Date__c == null || serviceItem.Expected_End_Date__c < ti.Expected_End_Date__c)){
                        serviceItem.Expected_End_Date__c = ti.Expected_End_Date__c;
                        doRecalculate = true;
                    }
                    if (ti.Expected_Start_Date__c != null && (serviceItem.Expected_Start_Date__c == null || serviceItem.Expected_Start_Date__c > ti.Expected_Start_Date__c)){
                        serviceItem.Expected_Start_Date__c = ti.Expected_Start_Date__c;
                        doRecalculate = true;
                    }
                }
                if (doRecalculate){serviceItem.Expected_Service_Duration__c = DateUtils.getDifferenceBetweanTwoDatetimes(serviceItem.Expected_Start_Date__c, serviceItem.Expected_End_Date__c, true);}

                update serviceItem;
            } catch( DMLException ex ){
                if( Trigger.isExecuting ){
                    processingTask.addError( ex.getDMLMessage(0) );
                } else {
                    throw new ErrorException( ex.getMessage() );
                }
            }
            return;
        }

        Map<Id, Service_Item__c> servicesMap = new Map<Id, Service_Item__c>();
        servicesMap.put( serviceItem.Id, serviceItem );

        TaskManagementServices.collectTaskPredecessorsAndSuccessors( servicesMap, null, false, true );
        TaskManagementServices.calculatePlannedDatesForTasks( servicesMap, processingTask.Id, null );

        try {
            update servicesMap.values();
        } catch( DMLException ex ){
            if( Trigger.isExecuting ){
                processingTask.addError( ex.getDMLMessage(0) );
            } else {
                throw new ErrorException( ex.getMessage() );
            }
        }

        for (Service_Item__c serviceItemItem : servicesWithTasks.values()){
            TaskManagementServices.seqNumberToTaskItemForService.put( serviceItemItem.Id, new Map<Integer, Task_Item__c>() );
            for( Task_Item__c tItem : serviceItemItem.Task_Items__r ) {
                TaskManagementServices.seqNumberToTaskItemForService.get( serviceItemItem.Id ).put( Integer.valueOf(tItem.Sequence_Number__c), tItem );
            }
        }

        TaskManagementServices.taskIdWithPredecessors = new Map<Id, Set<Id>>();
        TaskManagementServices.taskIdWithSuccessors = new Map<Id, Set<Id>>();

        TaskManagementServices.collectTaskPredecessorsAndSuccessors( servicesWithTasks, null, false, false );

        TaskManagementServices.calculatePlannedExpectedDatesForServices( servicesWithTasks, processingTask.Service_Item__c, processingTask.Id );

        // Calculate Planned Start/End Dates for all Tasks
        TaskManagementServices.calculatePlannedDatesForTasks( servicesWithTasks, processingTask.Id, null );

        try {
            update servicesWithTasks.values();
        } catch( DMLException ex ){
            if( Trigger.isExecuting ){
                processingTask.addError( ex.getDMLMessage(0) );
            } else {
                throw new ErrorException( ex.getMessage() );
            }
        } finally {
            servicesWithTasks = null;
        }
    }

    public static Task_Item__c updateActualEndDateForMilestone( Task_Item__c comingTaskItem, Boolean isStartDateChanged ) {
        Id milestoneId = isStartDateChanged ? comingTaskItem.Predecessor_Milestone__c : comingTaskItem.Successor_Milestone__c;
        Task_Item__c predecessorMilestone = [ Select Id, Actual_Start_Date__c, Name,
                                                     ( Select Id, Name, Actual_Start_Date__c From Task_Items1__r
                                                       Order By Actual_Start_Date__c desc limit 1 ),
                                                     ( Select Id, Name, Actual_End_Date__c From Successor_Milestones__r
                                                       Order By Actual_End_Date__c asc)
                                              From Task_Item__c Where Id = :milestoneId ];

        if (!isStartDateChanged){
            if (!predecessorMilestone.Successor_Milestones__r.isEmpty()){
                if (predecessorMilestone.Task_Items1__r.isEmpty()){
                    Datetime currentActualDate = (predecessorMilestone.Actual_Start_Date__c != null ? predecessorMilestone.Actual_Start_Date__c : comingTaskItem.Actual_End_Date__c);
                    for( Task_Item__c tItem : predecessorMilestone.Successor_Milestones__r ) {
                        tItem.Actual_End_Date__c = tItem.Id == comingTaskItem.Id ? comingTaskItem.Actual_End_Date__c : tItem.Actual_End_Date__c;
                        if( tItem.Actual_End_Date__c != null ) {
                            if( currentActualDate == null || currentActualDate < tItem.Actual_End_Date__c ) {
                                currentActualDate = tItem.Actual_End_Date__c;
                            }
                        } else {
                            currentActualDate = null;
                            break;
                        }
                    }
                    predecessorMilestone.Actual_Start_Date__c = currentActualDate;
                }
            }
        } else {
            if( predecessorMilestone.Actual_Start_Date__c == null ||
                predecessorMilestone.Actual_Start_Date__c > comingTaskItem.Actual_Start_Date__c ) {
                   predecessorMilestone.Actual_Start_Date__c = comingTaskItem.Actual_Start_Date__c;
            }
        }
        return predecessorMilestone;
    }

    public static Map<Id, Task_Item__c> filterTaskItemsToCreateReminders( Map<Id, Task_Item__c> newTaskItemMap, Map<Id, Task_Item__c> oldTaskItemMap ){
        Map<Id, Task_Item__c> filteredTaskItems = new Map<Id, Task_Item__c>();
        for( Task_Item__c taskItem: newTaskItemMap.values() ){
            if( (taskItem.Service_Issuance__c == TASK_STATUS_RENEWABLE_SERVICE || taskItem.Service_Issuance__c == TASK_STATUS_RENEWAL_SERVICE)&&
                    (taskItem.Reminder_Offset__c != oldTaskItemMap.get(taskItem.Id).Reminder_Offset__c
                    || taskItem.Expiration_Date__c != oldTaskItemMap.get(taskItem.Id).Expiration_Date__c
                    || taskItem.Disable_Reminder__c != oldTaskItemMap.get(taskItem.Id).Disable_Reminder__c) ){
                filteredTaskItems.put( taskItem.Id, taskItem );
            }
        }
        return filteredTaskItems;
    }

    public static void createEventRemindersForProjectManager ( Map<Id, Task_Item__c> taskItemMap ){
        if( taskItemMap.isEmpty() ) return;

        Set<Id> projectProfilesId = new Set<Id>();
        List<Event> eventsToInsert = new List<Event>();
        List<Event> eventsToRemove = new List<Event>([ SELECT StartDateTime, ReminderDateTime, Id, EndDateTime, WhatId
                                                        FROM Event
                                                        WHERE WhatId  IN: taskItemMap.keySet()
                                                        AND Subject =: PICKUP_ANALIZE_TASK_REMINDER_SUBJECT ]);
        for( Task_Item__c taskItem: taskItemMap.values() ) {
            projectProfilesId.add( taskItem.Project_Profile__c );
        }
        Map<Id, Project_Profile__c> projectProfileMap = new Map<Id, Project_Profile__c>([SELECT Id, Floor_s__c, Name, Project_Name__c, Project_Manager__c, Project_Address__c, OwnerId
                                                                                        FROM Project_Profile__c
                                                                                        WHERE Id IN: projectProfilesId]);


        for( Task_Item__c taskItem: taskItemMap.values() ){
            if( taskItem.Reminder_Offset__c == null || taskItem.Reminder_Offset__c < 0 || taskItem.Project_Profile__c == null || taskItem.Disable_Reminder__c) continue;

            DateTime reminderDateTime = taskItem.Expiration_Date__c == null ? taskItem.Activation_Date__c : taskItem.Expiration_Date__c.addDays( -taskItem.Reminder_Offset__c.IntValue() );

            if( reminderDateTime < taskItem.Activation_Date__c ) {
                reminderDateTime = taskItem.Activation_Date__c;
            }
            Project_Profile__c projectProfile = projectProfileMap.get(taskItem.Project_Profile__c);
            Event newEvent = new Event();
            newEvent.OwnerId = ( projectProfile.Project_Manager__c != null ) ? projectProfile.Project_Manager__c : projectProfile.OwnerId;
            newEvent.WhatId = taskItem.Id;
            newEvent.Subject = PICKUP_ANALIZE_TASK_REMINDER_SUBJECT;
            newEvent.StartDateTime = reminderDateTime;
            newEvent.EndDateTime = reminderDateTime;
            newEvent.IsReminderSet = true;
            newEvent.ReminderDateTime = reminderDateTime;
            newEvent.Description = 'Project Number: ' + projectProfile.Name + '; Project Name: ' + projectProfile.Project_Name__c + '; Project Address: ' + projectProfile.Project_Address__c;
            newEvent.Description += '; Floors: ' + projectProfile.Floor_s__c + '; Service Type: ' + taskItem.Service_Type__c + '; Municipal Agency ID# ' + taskItem.X3rd_Party_Authority_ID__c;
            newEvent.Description += '; Activation Date: ' + taskItem.Activation_Date__c.format() + '; Expiration Date: ' + taskItem.Expiration_Date__c.format();
            newEvent.Description += '; Task Item URL: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + taskItem.Id;
            eventsToInsert.add( newEvent );
        }
        try{
            delete eventsToRemove;
            insert eventsToInsert;
        }
        catch( DMLException dmlEx ) {
            if (Trigger.isExecuting){
                for ( Task_Item__c taskItem: taskItemMap.values() ){
                    taskItem.addError( 'Error updating Events' + dmlEx.getMessage() );
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
        }
    }

    public static Map<Id, Task_Item__c> filterTaskItemsToCreateChangeOrder( Map<Id, Task_Item__c> newTaskItemMap, Map<Id, Task_Item__c> oldTaskItemMap ){
        Map<Id, Task_Item__c> filteredTaskItems = new Map<Id, Task_Item__c>();
        for( Task_Item__c taskItem: newTaskItemMap.values() ){
            if( (taskItem.Service_Issuance__c == TASK_STATUS_RENEWABLE_SERVICE || taskItem.Service_Issuance__c == TASK_STATUS_RENEWAL_SERVICE)&&
                taskItem.Request_Renewal_CO_Now__c && !oldTaskItemMap.get(taskItem.Id).Request_Renewal_CO_Now__c ){
                filteredTaskItems.put( taskItem.Id, taskItem );
            }
        }
        return filteredTaskItems;
    }

    public static void createChangeOrderForRenewableTasks( Map<Id, Task_Item__c> taskItemMap ) {
        if( taskItemMap.isEmpty() ) return;
        //Select task services
        Set<Id> serviceItemsIds = new Set<Id>();
        for(Task_Item__c taskItem: taskItemMap.values() ) serviceItemsIds.add( taskItem.Service_Item__c );
        Map<Id, Service_Item__c> serviceItemsMap = new Map<Id, Service_Item__c>([SELECT Id, Region__c, Category__c, Type__c, Subtype__c, Quantity__c, OwnerId, Discount_Percentage__c,
                                                                                        Work_Type__c, Issuance__c, Plan_Submission_Type__c, Proposal__c, Phase__c, Service_Template__r.RecordTypeId
                                                                                FROM Service_Item__c
                                                                                WHERE Id IN: serviceItemsIds]);

        Map<Id, Id> taskIdToProposalIdMap = new Map<Id, Id>();
        //Insert Notes with Change Order Reason
        List<Note> notesToInsert = new List<Note>();
        for( Task_Item__c taskItem: taskItemMap.values() ){
            Note proposalNote = new Note( Title = 'Change Order Reason' );
            proposalNote.ParentId = serviceItemsMap.get(taskItem.Service_Item__c).Proposal__c;
            proposalNote.Body = taskItem.Reason_for_Billable_Hours__c;
            notesToInsert.add(proposalNote);
            taskIdToProposalIdMap.put( taskItem.Id, serviceItemsMap.get(taskItem.Service_Item__c).Proposal__c );
        }
        Savepoint sp = Database.setSavepoint();

        try {
            INSERT notesToInsert;
        } catch( DMLException dmlEx ) {
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    taskItemMap.get(notesToInsert[dmlEx.getDmlIndex(i)].ParentId).addError( 'Error inserting Proposal Change Order Note' + dmlEx.getMessage() );
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
            Database.rollback(sp);
            return;
        }

        Map<Id, Proposal__c> proposalsMap = new Map<Id, Proposal__c>([SELECT Id, Project_Profile__c, is_Change_Order__c FROM Proposal__c WHERE Id IN: taskIdToProposalIdMap.values()]);
        List<Change_Order__c> changeOrdersToInsert = new List<Change_Order__c>();
        for( Proposal__c proposal: proposalsMap.values() ){
            Change_Order__c newChangeOrder = new Change_Order__c( Proposal__c = proposal.Id,
                                                                  Project_Profile__c = proposal.Project_Profile__c,
                                                                  Status__c = ChangeOrderServices.STATUS_REQUESTED );
            changeOrdersToInsert.add( newChangeOrder );

            proposal.is_Change_Order__c = true;
            //proposal.Proposal_Type__c = 'Change Order'; //MRS-7049
            proposal.Locked__c = false;
        }

        //Insert Change Orders
        try {
            INSERT changeOrdersToInsert;
        } catch (DMLException dmlEx){
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    for( Id taskItemId: taskIdToProposalIdMap.keySet() ){
                        if( serviceItemsMap.get(taskItemMap.get(taskItemId).Service_Item__c).Proposal__c == changeOrdersToInsert[dmlEx.getDmlIndex(i)].Proposal__c ){
                            taskItemMap.get(taskItemId).addError( 'Error Inserting Change Orders' + dmlEx.getMessage() );
                            break;
                        }
                    }
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
            Database.rollback(sp);
            return;
        }

        //Update Proposal
        try {
            UPDATE proposalsMap.values();
        } catch (DMLException dmlEx){
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    for( Id taskItemId: taskIdToProposalIdMap.keySet() ){
                        if( serviceItemsMap.get(taskItemMap.get(taskItemId).Service_Item__c).Proposal__c == proposalsMap.values()[dmlEx.getDmlIndex(i)].Id ){
                            taskItemMap.get(taskItemId).addError( 'Error Inserting Change Orders' + dmlEx.getMessage() );
                            break;
                        }
                    }
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
            Database.rollback(sp);
            return;
        }

        Map<Id, Change_Order__c> changeOrdersMap = new Map<Id, Change_Order__c>( changeOrdersToInsert );
        Map<Id, Id> proposalIdToChangeOrderIdMap = new Map<Id, Id>();
        for( Change_Order__c changeOrder: changeOrdersMap.values() ) {
            proposalIdToChangeOrderIdMap.put( changeOrder.Proposal__c, changeOrder.Id );
        }
        //Select Service Template
        //MRS-7530
        Map<Id, Service_Template__c> serviceTemplates = new Map<Id, Service_Template__c>(ServiceItemServices.getServiceTemplateForServiceItem(null, TASK_STATUS_RENEWAL_SERVICE));

        if( serviceTemplates.isEmpty() || changeOrdersMap.isEmpty() ){
            Database.rollback(sp);
            return;
        }

        //Insert amendment services
        Map<Id, List<Service_Template__c>> taskIdToAmendmentServicesMap = new Map<Id, List<Service_Template__c>>();
        Map<Id, Id> serviceTemplateIdToServiceIdMap = new Map<Id, Id>();
        List<Service_Template__c> suitableTemplates = new List<Service_Template__c>();
        List<Service_Item__c> amendmentServices = new List<Service_Item__c>();

        for( Task_Item__c taskItem: taskItemMap.values() ){
            if( !taskIdToAmendmentServicesMap.containsKey(taskItem.Id) ) taskIdToAmendmentServicesMap.put(taskItem.Id, new List<Service_Template__c>());
            Service_Item__c taskService = serviceItemsMap.get(taskItem.Service_Item__c);
            for( Service_Template__c template: serviceTemplates.values() ){
                if( taskService.Region__c == template.Region__c &&
                    taskService.Category__c == template.Category__c &&
                    taskService.Type__c == template.Type__c &&
                    taskService.Subtype__c == template.Subtype__c){
                        taskIdToAmendmentServicesMap.get(taskItem.Id).add(template);
                }
            }
        }

        Boolean needToRollback = false;
        for( Id taskItemId: taskIdToAmendmentServicesMap.keySet() ){
            //MRS-4583
            if( taskIdToAmendmentServicesMap.get(taskItemId).size() != 1 ){
                taskItemMap.get(taskItemId).addError('The system could not determine which service to add to the change order, please create a change order manually.');
                needToRollback = true;
            }else{
                Task_Item__c taskItem = taskItemMap.get(taskItemId);
                Service_Item__c si = ServiceItemServices.createNewServiceItemFromTemplate(taskIdToAmendmentServicesMap.get(taskItemId)[0]);
                si.Discount_Percentage__c = serviceItemsMap.get(taskItem.Service_Item__c).Discount_Percentage__c;
                si.Is_Alternative__c = false;
                si.Is_Amendmend_Added__c = true;
                si.Original__c = false;
                si.Phase__c = serviceItemsMap.get(taskItem.Service_Item__c).Phase__c;
                si.Region__c = serviceItemsMap.get(taskItem.Service_Item__c).Region__c;
                si.Proposal__c = taskIdToProposalIdMap.get(taskItem.Id);
                si.Change_Order__c = proposalIdToChangeOrderIdMap.get(taskIdToProposalIdMap.get(taskItem.Id));
                si.Project_Profile__c = taskItem.Project_Profile__c;
                si.Work_Type__c = serviceItemsMap.get(taskItem.Service_Item__c).Work_Type__c;
                si.Row_Position__c = 1;
                amendmentServices.add(si);
            }
        }
        if( needToRollback ){
            if (Trigger.isExecuting){
                Database.rollback(sp);
                return;
            } else {
                Database.rollback(sp);
                throw new ErrorException('The system could not determine which service to add to the change order, please create a change order manually.');
            }
        }
        try{
            if( !amendmentServices.isEmpty() ) {
                insert amendmentServices;
            } else {
                Database.rollback(sp);
            }
        } catch (DMLException dmlEx){
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    for( Id taskItemId: taskIdToProposalIdMap.keySet() ){
                        if( serviceItemsMap.get(taskItemMap.get(taskItemId).Service_Item__c).Proposal__c == amendmentServices[dmlEx.getDmlIndex(i)].Proposal__c ){
                            taskItemMap.get(taskItemId).addError(  + dmlEx.getMessage() );
                            break;
                        }
                    }
                }
                Database.rollback(sp);
                return;
            } else {
                Database.rollback(sp);
                throw new ErrorException( 'Error inserting Services' + dmlEx.getMessage() );
            }
        }
        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>(amendmentServices);
    }

    public static Map<String, List<Task_Item__c>> eventSubjectTofilterTaskItemsForEventAlertNotification( List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap ){
        Map<String, List<Task_Item__c>> eventSubjectToTaskItemList = new Map<String, List<Task_Item__c>>();
        List<Task_Item__c> filteredTaskItemsForAlert = new List<Task_Item__c>();
        List<Task_Item__c> filteredTaskItemsForNotification = new List<Task_Item__c>();
        for( Task_Item__c taskItem: newTaskItemList ){
            Task_Item__c taskItemOld = oldTaskItemMap.get(taskItem.Id);
            if( taskItem.Task_Alert__c && !taskItemOld.Task_Alert__c ){
                filteredTaskItemsForAlert.add( taskItem );
            }
            if( taskItem.Task_Notification__c && !taskItemOld.Task_Notification__c ){
                filteredTaskItemsForNotification.add( taskItem );
            }
        }
        if(!filteredTaskItemsForAlert.isEmpty()) eventSubjectToTaskItemList.put(EventServices.TASK_ALERT_SUBJECT, filteredTaskItemsForAlert );
        if(!filteredTaskItemsForNotification.isEmpty()) eventSubjectToTaskItemList.put(EventServices.TASK_NOTIFICATION_SUBJECT, filteredTaskItemsForNotification );

        return eventSubjectToTaskItemList;
    }

    public static List<Task_Item__c> filterTaskItemsForEventAlertNotificationDelete( List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap ){

        List<Task_Item__c> filteredTaskItems = new List<Task_Item__c>();
        for( Task_Item__c taskItem: newTaskItemList ){
            Task_Item__c taskItemOld = oldTaskItemMap.get(taskItem.Id);
            if( (!taskItem.Task_Alert__c && taskItemOld.Task_Alert__c) || (!taskItem.Task_Notification__c && taskItemOld.Task_Notification__c) ){
                filteredTaskItems.add( taskItem );
            }
        }
        return filteredTaskItems;
    }

    public static List<Task_Item__c> getTaskItemByServiceItemId(Id serviceItemId) {
        return [Select Successor_Task__c, Successor_Task__r.Name, Successor_Milestone__c, Sequence_Number__c,
                       Predecessor_Task__c, Predecessor_Task__r.Name, Predecessor_Milestone__c, Predecessor_Milestone__r.Name,
                       Name, Id, Expected_Start_Date__c, Successor_Milestone__r.Name, Owner.Name, OwnerId,
                       Expected_End_Date__c, Expected_Duration__c, Delay_End_Date__c, Service_Item__c, Task_Status_Color__c
                From Task_Item__c
                WHERE Service_Item__c = : serviceItemId ORDER BY Sequence_Number__c ASC ];
    }

    public static List<Task_Item__c> filterCompleteFormsTaskItems( List<Task_Item__c> newTaskItemList ) {
        List<Task_Item__c> filteredTaskItems = new List<Task_Item__c>();
        for( Task_Item__c taskItem: newTaskItemList ){
            if( taskItem.Name.equals( COMPLETE_FORMS_TASK_NAME ) ) {
                filteredTaskItems.add( taskItem );
            }
        }
        return filteredTaskItems;
    }

    public static Task_Item__c getTaskItemById(Id taskItemId) {
        return [Select Successor_Task__c, Successor_Task__r.Name, Successor_Milestone__c, Sequence_Number__c,
                       Predecessor_Task__c, Predecessor_Task__r.Name, Predecessor_Milestone__c, Predecessor_Milestone__r.Name,
                       Name, Id, Expected_Start_Date__c, Successor_Milestone__r.Name, Service_Item__r.Status__c,
                       Expected_End_Date__c, Expected_Duration__c, Delay_End_Date__c, Service_Item__c,
                       Project_Profile__r.Proposal__c, Project_Profile__c, Project_Profile__r.Proposal__r.Floor_s__c,
                       Project_Profile__r.Proposal__r.Address__c, Project_Profile__r.Building__c, Task_Status_Color__c
                From Task_Item__c
                WHERE id = : taskItemId limit 1 ];
    }


    public static Set<Id> filterExpectedEndDateTasks( List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap ) {
        Set<Id> projectIdSet = new Set<Id>();
        for( Task_Item__c taskItem : newTaskItemList ) {
            if( taskItem.Expected_End_Date__c != oldTaskItemMap.get( taskItem.Id ).Expected_End_Date__c  ) {
                projectIdSet.add( taskItem.Project_Profile__c );
            }
        }
        return projectIdSet;
    }

    public static List<Task_Item__c> filteredTaskItemForRecalculateProjectTeamExpectedDuration(List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap){
        List<Task_Item__c> filteredTaskItemList = new List<Task_Item__c>();
        if (oldTaskItemMap == null){
            for (Task_Item__c taskItemItem : newTaskItemList){
                Integer newDurationInSecond = !String.isEmpty(taskItemItem.Expected_Duration__c) ? DateUtils.getMinute(taskItemItem.Expected_Duration__c) : 0;
                if ( !String.isEmpty(taskItemItem.Project_Team__c) &&
                     taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID &&
                     taskItemItem.Actual_End_Date__c == null &&
                     newDurationInSecond > 0 ) {
                    filteredTaskItemList.add(taskItemItem);
                }
            }
        } else {
            for ( Task_Item__c taskItemItem : newTaskItemList ) {
                Task_Item__c oldTaskItem = oldTaskItemMap.get(taskItemItem.Id);
                Integer newDurationInMinute = !String.isEmpty(taskItemItem.Expected_Duration__c) ? DateUtils.getMinute(taskItemItem.Expected_Duration__c) : 0;
                Integer oldDurationInMinute = !String.isEmpty(oldTaskItem.Expected_Duration__c) ? DateUtils.getMinute(oldTaskItem.Expected_Duration__c) : 0;
                if ( !String.isEmpty(taskItemItem.Project_Team__c) &&
                     taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID &&
                     ( ( taskItemItem.Actual_End_Date__c == null &&
                          newDurationInMinute != oldDurationInMinute ) ||
                       ( taskItemItem.Actual_End_Date__c != null &&
                            oldTaskItem.Actual_End_Date__c == null &&
                            oldDurationInMinute > 0 )
                     ) ) {
                    filteredTaskItemList.add(taskItemItem);
                }
            }
        }
        return filteredTaskItemList;
    }

    public static void updateProjectTeamExpectedDuration(List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap){
        if (newTaskItemList.isEmpty()){
            return;
        }
        Map<Id, Integer> projectTeamWithChangedTaskItemDuration = new Map<Id, Integer>();
        if (oldTaskItemMap == null){
            for (Task_Item__c taskItemItem : newTaskItemList){
                Integer newDurationInMinute = !String.isEmpty(taskItemItem.Expected_Duration__c) ? DateUtils.getMinute(taskItemItem.Expected_Duration__c) : 0;
                if (!String.isEmpty(taskItemItem.Delay_End_Date__c)){
                    newDurationInMinute += DateUtils.getMinute(taskItemItem.Delay_End_Date__c);
                }

                if (!String.isEmpty(taskItemItem.Project_Team__c) && taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID &&
                    taskItemItem.Actual_End_Date__c == null && newDurationInMinute != 0){
                    if (!projectTeamWithChangedTaskItemDuration.containsKey(taskItemItem.Project_Team__c)){
                        projectTeamWithChangedTaskItemDuration.put(taskItemItem.Project_Team__c, newDurationInMinute);
                    } else {
                        newDurationInMinute += projectTeamWithChangedTaskItemDuration.get(taskItemItem.Project_Team__c);
                        projectTeamWithChangedTaskItemDuration.put(taskItemItem.Project_Team__c, newDurationInMinute);
                    }
                }
            }
        } else {
            for (Task_Item__c taskItemItem : newTaskItemList){
                Task_Item__c oldTaskItem = oldTaskItemMap.get(taskItemItem.Id);
                Integer newDurationInMinute = !String.isEmpty(taskItemItem.Expected_Duration__c) ? DateUtils.getMinute(taskItemItem.Expected_Duration__c) : 0;
                Integer oldDurationInMinute = !String.isEmpty(oldTaskItem.Expected_Duration__c) ? DateUtils.getMinute(oldTaskItem.Expected_Duration__c) : 0;
                if (!String.isEmpty(taskItemItem.Delay_End_Date__c)){
                    if (taskItemItem.Actual_End_Date__c != null && oldTaskItem.Actual_End_Date__c == null){
                        oldDurationInMinute += DateUtils.getMinute(oldTaskItem.Delay_End_Date__c);
                    }
                }

                if (!String.isEmpty(taskItemItem.Project_Team__c) && taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID &&
                    ((taskItemItem.Actual_End_Date__c == null && newDurationInMinute != oldDurationInMinute) ||
                    (taskItemItem.Actual_End_Date__c != null && oldTaskItem.Actual_End_Date__c == null && oldDurationInMinute != 0))){
                    newDurationInMinute = taskItemItem.Actual_End_Date__c == null ? newDurationInMinute : 0;
                    if (!projectTeamWithChangedTaskItemDuration.containsKey(taskItemItem.Project_Team__c)){
                        projectTeamWithChangedTaskItemDuration.put(taskItemItem.Project_Team__c, newDurationInMinute - oldDurationInMinute);
                    } else {
                        newDurationInMinute = newDurationInMinute + projectTeamWithChangedTaskItemDuration.get(taskItemItem.Project_Team__c) - oldDurationInMinute;
                        projectTeamWithChangedTaskItemDuration.put(taskItemItem.Project_Team__c, newDurationInMinute);
                    }
                }
            }
        }

        Map<Id, Project_Team__c> projectTeamUpdatedMap = new Map<Id, Project_Team__c>();
        for (Id projectTeamIdItem : projectTeamWithChangedTaskItemDuration.keySet()){
            if(projectTeamWithChangedTaskItemDuration.get(projectTeamIdItem) != 0){
                projectTeamUpdatedMap.put(projectTeamIdItem, new Project_Team__c(Id = projectTeamIdItem));
            }
        }

        if (projectTeamUpdatedMap.isEmpty()){
            return;
        }

        for (Task_Item__c taskItemItem : newTaskItemList){
            if (projectTeamUpdatedMap.containsKey(taskItemItem.Project_Team__c) && projectTeamUpdatedMap.get(taskItemItem.Project_Team__c).Expected_Duration__c == null){
                projectTeamUpdatedMap.get(taskItemItem.Project_Team__c).Expected_Duration__c = taskItemItem.Project_Team_Duration__c + projectTeamWithChangedTaskItemDuration.get(taskItemItem.Project_Team__c);
            }
        }

        try{
            update projectTeamUpdatedMap.values();
        } catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                for (Task_Item__c taskItemItem : newTaskItemList){
                    Id projectTeamId = Id.valueOf(taskItemItem.Project_Team__c);
                    if(projectTeamId == projectTeamUpdatedMap.values()[dmlEx.getDmlIndex(i)].Id){
                        taskItemItem.addError('Error updating Project Team: ' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static Map<Id, Task_Item__c> filterTaskItemsMunicipalAgency( List<Task_Item__c> newList, Map<Id, Task_Item__c> oldMap ) {
        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>();
        if( newList != null && oldMap != null ) {
            for( Task_Item__c ti : newList ) {
                if( ( ti.X3rd_Party_Authority_ID__c != oldMap.get( ti.Id ).X3rd_Party_Authority_ID__c ||
                      ti.X3rd_Party_Issue_Date__c   != oldMap.get( ti.Id ).X3rd_Party_Issue_Date__c ||
                      ti.X3rd_Party_Disapproved_Date__c   != oldMap.get( ti.Id ).X3rd_Party_Disapproved_Date__c ||
                      ti.X3rd_Party_Description__c  != oldMap.get( ti.Id ).X3rd_Party_Description__c ||
                      ti.Type_in_Municipal_Agency_Name__c  != oldMap.get( ti.Id ).Type_in_Municipal_Agency_Name__c)
                    && !String.isBlank( ti.Service_Item__c ) ) {
                    taskItemMap.put(ti.Id, ti );
                }
            }
        }
        return taskItemMap;
    }

    public static void updateMunicipalAgencyForAllTask( Map<Id, Task_Item__c> taskItemMap ) {
        if( taskItemMap.isEmpty() ) return;

        Map<Id, Task_Item__c> taskItemsToUpdateMap = new Map<Id, Task_Item__c>();
        Map<Id, Service_Item__c> serviceItemsToUpdateMap = new Map<Id, Service_Item__c>();
        Set<Id> serviceItemIds = new Set<Id>();
        Set<Id> ignoreTaskItemIds = new Set<Id>();
        for( Task_Item__c item : taskItemMap.values() ) {
            ignoreTaskItemIds.add(item.Id);
            serviceItemIds.add(item.Service_Item__c);
        }
        List<Task_Item__c> taskItems = [ SELECT Id, Service_Item__c, X3rd_Party_Authority_ID__c, X3rd_Party_Issue_Date__c, X3rd_Party_Disapproved_Date__c, X3rd_Party_Description__c, Type_in_Municipal_Agency_Name__c
                                         FROM Task_Item__c
                                         WHERE Service_Item__c IN : serviceItemIds AND Id NOT IN : ignoreTaskItemIds ];

        Map<Id, List<Task_Item__c> > serviceItemIdTaskItemsToUpdate = new Map<Id, List<Task_Item__c> >();
        for( Task_Item__c taskItem : taskItems ) {
            if( !serviceItemIdTaskItemsToUpdate.containsKey( taskItem.Service_Item__c ) ) {
                serviceItemIdTaskItemsToUpdate.put( taskItem.Service_Item__c, new List<Task_Item__c>() );
            }
            serviceItemIdTaskItemsToUpdate.get( taskItem.Service_Item__c ).add( taskItem );
        }
        for( Task_Item__c item : taskItemMap.values() ) {
            serviceItemsToUpdateMap.put( item.Service_Item__c, new Service_Item__c( Id = item.Service_Item__c,
                                                                                    Municipal_Agency_ID__c = item.X3rd_Party_Authority_ID__c,
                                                                                    X3rd_Party_Issue_Date__c = item.X3rd_Party_Issue_Date__c,
                                                                                    X3rd_Party_Disapproved_Date__c = item.X3rd_Party_Disapproved_Date__c,
                                                                                    X3rd_Party_Description__c = item.X3rd_Party_Description__c,
                                                                                    Type_in_Municipal_Agency_Name__c = item.Type_in_Municipal_Agency_Name__c ) );
            if( serviceItemIdTaskItemsToUpdate.containsKey( item.Service_Item__c ) ) {
                for( Task_Item__c taskItem : serviceItemIdTaskItemsToUpdate.get( item.Service_Item__c ) ) {
                    taskItemsToUpdateMap.put(taskItem.Id, new Task_Item__c( Id = taskItem.Id,
                                                             X3rd_Party_Authority_ID__c = item.X3rd_Party_Authority_ID__c,
                                                             X3rd_Party_Issue_Date__c   = item.X3rd_Party_Issue_Date__c,
                                                             X3rd_Party_Disapproved_Date__c   = item.X3rd_Party_Disapproved_Date__c,
                                                             X3rd_Party_Description__c  = item.X3rd_Party_Description__c,
                                                             Type_in_Municipal_Agency_Name__c  = item.Type_in_Municipal_Agency_Name__c
                                                            ) );
                }
            }
        }
        try {
            UPDATE taskItemsToUpdateMap.values();
            UPDATE serviceItemsToUpdateMap.values();
        } catch( DMLException dmlEx ) {
            if (Trigger.isExecuting){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    for ( Task_Item__c taskItemItem : taskItemMap.values() ){
                        Id itemId = taskItemItem.Id;
                        if(itemId == taskItemsToUpdateMap.values()[dmlEx.getDmlIndex(i)].Id){
                            taskItemItem.addError('Error updating Project Team: ' + dmlEx.getMessage());
                        }
                    }
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
        }
    }

    public static List<Task_Item__c> filterPickupAnalyze(List<Task_Item__c> taskItems) {
        Map<Id, Task_Item__c> serviceIdTaskItemPickupAnalizeId = new Map<Id, Task_Item__c>();
        List<Task_Item__c> taskItemsToUpdate = new List<Task_Item__c>();
        if(TASK_ITEM_RECORD_TYPE_IDS.containsKey(PICKUP_ANALIZE_TASK_NAME) ) {
            for(Task_Item__c taskItem : taskItems) {
                if(taskItem.RecordTypeId == TASK_ITEM_RECORD_TYPE_IDS.get(PICKUP_ANALIZE_TASK_NAME) && taskItem.Service_Item__c != null) {
                   serviceIdTaskItemPickupAnalizeId.put(taskItem.Service_Item__c, taskItem);
                }
            }
        }
        if( serviceIdTaskItemPickupAnalizeId.isEmpty() ) return taskItemsToUpdate;

        for(Service_Item__c si : [SELECT Id, Issuance__c FROM Service_Item__c WHERE Id IN : serviceIdTaskItemPickupAnalizeId.keySet() AND (Issuance__c = : TASK_STATUS_RENEWABLE_SERVICE OR Issuance__c = : TASK_STATUS_RENEWAL_SERVICE)]) {
            if(serviceIdTaskItemPickupAnalizeId.containsKey(si.Id)) {
                taskItemsToUpdate.add(serviceIdTaskItemPickupAnalizeId.get(si.Id));
            }
        }
        return taskItemsToUpdate;
    }

    public static List<Task_Item__c> filterPickupAnalyze(List<Service_Item__c> serviceItems) {
        Set<Id> serviceItemIds = new Set<Id>();
        for(Service_Item__c si : serviceItems) {
            if(si.Issuance__c == TASK_STATUS_RENEWABLE_SERVICE || si.Issuance__c == TASK_STATUS_RENEWAL_SERVICE) {
                serviceItemIds.add(si.Id);
            }
        }
        return [SELECT ID, RecordTypeId FROM Task_Item__c WHERE Service_Item__c IN : serviceItemIds AND Name = : PICKUP_ANALIZE_TASK_NAME];

    }

    public static void updatePickupAnalyze(List<Task_Item__c> taskItems) {
        if(TASK_ITEM_RECORD_TYPE_IDS.containsKey(PICKUP_ANALIZE_RENEWABLE_OR_RENEWAL_TASK_NAME) ) {
            for(Task_Item__c taskItem : taskItems) {
                taskItem.RecordTypeId = TASK_ITEM_RECORD_TYPE_IDS.get(PICKUP_ANALIZE_RENEWABLE_OR_RENEWAL_TASK_NAME);

            }
            try {
                UPDATE taskItems;
            } catch( DMLException dmlEx ) {
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                    for (Task_Item__c taskItem : taskItems){
                        taskItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                    }
                }
            }
        }
    }

    public static Map<Id, Task_Item__c> filterTaskItemsPackageStatus ( List<Task_Item__c> newTaskItems, Map<Id, Task_Item__c> oldTaskItemMap ) {
        Map<Id, Task_Item__c> serviceItemIdToTaskItem = new Map<Id, Task_Item__c>();
        if(oldTaskItemMap == null) {
           for(Task_Item__c taskItem : newTaskItems) {
               if(!String.isBlank(taskItem.Package_Status__c)) {
                   serviceItemIdToTaskItem.put(taskItem.Service_Item__c, taskItem);
               }
           }
        } else {
           for(Task_Item__c taskItem : newTaskItems) {
               if(taskItem.Package_Status__c != oldTaskItemMap.get(taskItem.Id).Package_Status__c) {
                   serviceItemIdToTaskItem.put(taskItem.Service_Item__c, taskItem);
               }
           }
        }
        return serviceItemIdToTaskItem;
    }

    public static void updateFormItemPackageStatus ( Map<Id, Task_Item__c> serviceItemIdToTaskItem ) {
        if(serviceItemIdToTaskItem.isEmpty()) return;
        List<Form_Item__c> formItems = [Select Id, Service_Item__c, Status__c From Form_Item__c Where Service_Item__c IN: serviceItemIdToTaskItem.keySet()];
        for(Form_Item__c formItem : formItems) {
            if(serviceItemIdToTaskItem.containsKey(formItem.Service_Item__c)) {
                formItem.Package_Status__c = serviceItemIdToTaskItem.get(formItem.Service_Item__c).Package_Status__c;
            }
        }
        try {
            UPDATE formItems;
        } catch( DMLException dmlEx ) {
            if (Trigger.isExecuting){
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                    for (Form_Item__c formItem : formItems){
                        formItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                    }
                }
            } else {
                throw new ErrorException( Label.Update_Task_Item_Error + dmlEx.getMessage() );
            }
        }
    }

    public static List<Task_Item__c> getTaskItemsByIdsForVendorRequests(final Set<Id> taskItemIds) {
        if (null == taskItemIds || taskItemIds.isEmpty()) {
            return new List<Task_Item__c>();

        }

        return new List<Task_Item__c>([SELECT Service_Item__c, Id, RecordType.Name, Service_Item__r.Type__c,
                                              Project_Profile__r.Project_Address__c, Project_Profile__r.Accounting_Contact__c, Project_Profile__c,
                                              Project_Profile__r.Accounting_Contact_Company__c, Service_Item__r.Description__c,
                                              Project_Profile__r.Billing_Method__c, Project_Profile__r.Building__c, Project_Profile__r.Billing_Company_Name__c,
                                              Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Primary_Company_Contact__c, Service_Item__r.Phase__c,
                                          (SELECT Id, Cost__c, Pass_Through_Expense__c , Is_Reimbursable_Line_Item_Created__c, Description_of_Work__c
                                           FROM Vendor_Requests__r
                                           WHERE Pass_Through_Expense__c =: true AND Is_Reimbursable_Line_Item_Created__c =: false)
                                       FROM Task_Item__c
                                       WHERE Id IN: taskItemIds AND RecordType.Name =: VendorRequestServices.VENDOR_REQUEST_RECORD_TYPE_NAME]);

    }

    public static Set<Id> filteredTaskItemsToInCompleteStatus(Map<Id, Task_Item__c> oldMap, List<Task_Item__c> newList) {
        if ( newList.isEmpty() ) return new Set<Id>();

        Set<Id> tasks = new Set<Id>();

        Task_Items_Statuses__c taskStatuses;
        for (Task_Item__c task : newList) {
            Task_Item__c oldTask = oldMap.get(task.Id);
            if (task.Name.contains(TaskServices.TERMINATED_TASK_NAME_PREFIX) || task.Status__c == oldTask.Status__c ) continue;

            taskStatuses = Task_Items_Statuses__c.getValues( TaskItemServices.convertRecrdTypeNameToCustomSettingName( task.Name ) );

            if (null == taskStatuses) continue;

            if( taskStatuses.Complete__c.equalsIgnoreCase( oldTask.Status__c ) ||
                  ( taskStatuses.Alternative__c != null && taskStatuses.Alternative__c.equalsIgnoreCase( oldTask.Status__c ) ) ){
                tasks.add(task.Id);
            }
        }
        return tasks;
    }

    public static Set<Id> filteredTaskItemsToCompleteStatus(Map<Id, Task_Item__c> oldMap, List<Task_Item__c> newList) {
        if ( newList.isEmpty() ) return new Set<Id>();

        Set<Id> tasks = new Set<Id>();
        Task_Items_Statuses__c taskStatuses;

        for (Task_Item__c task : newList) {
            Task_Item__c oldTask = oldMap.get(task.Id);
            if (task.Name.contains(TaskServices.TERMINATED_TASK_NAME_PREFIX) || task.Status__c == oldTask.Status__c ) continue;

            taskStatuses = Task_Items_Statuses__c.getValues(TaskItemServices.convertRecrdTypeNameToCustomSettingName(task.Name));

            if (null == taskStatuses)  continue;

            if( taskStatuses.Complete__c.equalsIgnoreCase( task.Status__c ) ||
                  ( taskStatuses.Alternative__c != null && taskStatuses.Alternative__c.equalsIgnoreCase( task.Status__c ) ) ){
                tasks.add(task.Id);
            }
        }
        return tasks;
    }

    public static String convertRecrdTypeNameToCustomSettingName(final String recordTypeName) {
        if (String.isBlank(recordTypeName)) {
            throw new ErrorException('Record type name cannot be empty.');

        }

        if (recordTypeName.contains(PICKUP_ANALYZE_ARTIFACTS_CUSTOM_SETTING_NAME)) {
            return PICKUP_ANALYZE_ARTIFACTS_CUSTOM_SETTING_NAME;

        } else if (recordTypeName.contains(TRACK_FROM_PROCESSING_CUSTOM_SETTING_NAME)) {
            return TRACK_FROM_PROCESSING_CUSTOM_SETTING_NAME;

        } else {
            return recordTypeName;

        }

    }

    public static void populateReportingFieldsOnService( Map<Id, Task_Item__c> tasksWithChangedActualEndDates ){
        if( tasksWithChangedActualEndDates.isEmpty() ) return;

        Set<Id> taskIdsForFilledDate = new Set<Id>();
        Set<Id> taskIdsForApprovedDate = new Set<Id>();
        Set<Id> taskIdsForDisapprovedDate = new Set<Id>();
        Set<Id> serviceIds = new Set<Id>();

        for( Task_Item__c t : tasksWithChangedActualEndDates.values() ){
            serviceIds.add( t.Service_Item__c );

            if( t.RecordTypeId == TASK_ITEM_RECORD_TYPE_IDS.get( SUBMIT_FILING_PACKAGE_TO_AUTHORITY_TASK_NAME ) ){
                taskIdsForFilledDate.add( t.Id );
            } else if( t.RecordTypeId == TASK_ITEM_RECORD_TYPE_IDS.get( PICKUP_ANALIZE_TASK_NAME ) ){
                if( t.Status__c == TASK_ITEM_STATUS_APPROVED ){
                    taskIdsForApprovedDate.add( t.Id );
                } else if( t.Status__c == TASK_ITEM_STATUS_DISAPPROVED ){
                    taskIdsForDisapprovedDate.add( t.Id );
                }
            }
        }

        Map<Id, Service_Item__c> servItemsMap = new Map<Id, Service_Item__c>( [ Select Id, Filed_Date__c, Approved_Date__c, Disapproved_Date__c From Service_Item__c Where Id IN: serviceIds ] );

        for( Id taskId : taskIdsForFilledDate ){
            Service_Item__c currService = servItemsMap.get( tasksWithChangedActualEndDates.get( taskId ).Service_Item__c );
            if( currService.Filed_Date__c == null || currService.Filed_Date__c > tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c ) {
                currService.Filed_Date__c = tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c;
            }
        }
        for( Id taskId : taskIdsForApprovedDate ){
            Service_Item__c currService = servItemsMap.get( tasksWithChangedActualEndDates.get( taskId ).Service_Item__c );
            if( currService.Approved_Date__c == null || currService.Approved_Date__c > tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c ) {
                currService.Approved_Date__c = tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c;
            }
        }
        for( Id taskId : taskIdsForDisapprovedDate ){
            Service_Item__c currService = servItemsMap.get( tasksWithChangedActualEndDates.get( taskId ).Service_Item__c );
            if( currService.Disapproved_Date__c == null || currService.Disapproved_Date__c > tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c ) {
                currService.Disapproved_Date__c = tasksWithChangedActualEndDates.get( taskId ).Actual_End_Date__c;
            }
        }

        try{
            update servItemsMap.values();
        } catch ( DMLException dmlEx ){
            if (Trigger.isExecuting){
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                    for ( Task_Item__c taskItem : tasksWithChangedActualEndDates.values() ){
                        taskItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                    }
                }
            } else {
                throw new ErrorException ( Label.Update_Task_Item_Error + dmlEx.getMessage() );
            }
        }
    }

    public static void checkIfServiceItemsCount(List<Task_Item__c> commingTasks, Map<Id, Task_Item__c> oldTasks){
        Id projectProfileId;
        for( Task_Item__c taskItem : commingTasks ){
            Task_Item__c oldTask = oldTasks.get( taskItem.Id );
            if( taskItem.Status__c != oldTask.Status__c && taskItem.Project_Profile__c != null &&
                ( (oldTask.Status__c == TASK_ITEM_STATUS_NOT_STARTED && taskItem.Actual_Start_Date__c == null) ||
                  (TASK_ITEM_END_STATUS_VALUES.contains( taskItem.Status__c ) && taskItem.Actual_End_Date__c == null) ) ){
                projectProfileId = taskItem.Project_Profile__c;
            }
        }

        if ( projectProfileId != null ){
            servicesWithTasks = populateServicesWithTasks(projectProfileId);
            isCalculateActualValuesInFuture = servicesWithTasks.size() >= SERVICE_ITEM_COUNT;
        }
    }

    public static void updateActualStartEndDate( List<Task_Item__c> commingTasks, Map<Id, Task_Item__c> oldTasks ){
        for( Task_Item__c taskItem : commingTasks ){
            Task_Item__c oldTask = oldTasks.get( taskItem.Id );
            if( taskItem.Status__c != oldTask.Status__c ){
                if( oldTask.Status__c == TASK_ITEM_STATUS_NOT_STARTED && taskItem.Actual_Start_Date__c == null ){
                    taskItem.Actual_Start_Date__c = taskItem.Expected_Start_Date__c = DateTime.now();
                    taskItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( taskItem.Actual_Start_Date__c,
                                                                                                       taskItem.Expected_Duration__c );
                }
                if( TASK_ITEM_END_STATUS_VALUES.contains( taskItem.Status__c ) && taskItem.Actual_End_Date__c == null) {
                    taskItem.Actual_End_Date__c = taskItem.Expected_End_Date__c = DateTime.now();
                    taskItem.Expected_Duration__c = taskItem.Actual_Duration__c = DateUtils.getDifferenceBetweanTwoDatetimes( taskItem.Expected_Start_Date__c,
                                                                                                                              taskItem.Expected_End_Date__c, true );
                }
            }
        }
    }

    public static List<Task_Item__c> filteredTaskItemWithChangedOwner(List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> oldTaskItemMap){
        if ( newTaskItemList == null || oldTaskItemMap == null ){ return new List<Task_Item__c>(); }
        List<Task_Item__c> filteredTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemItem : newTaskItemList){
            if ( taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID && taskItemItem.OwnerId != oldTaskItemMap.get(taskItemItem.Id).OwnerId ){
                filteredTaskItemList.add(taskItemItem);
            }
        }
        return filteredTaskItemList;
    }

    public static void upsertProjectRosterList( List<Task_Item__c> filteredTaskItemList ){
        if ( filteredTaskItemList == null || filteredTaskItemList.isEmpty() ) return;

        Map<Id, String> userIdToRoleName = UserServices.getUserIdToRoleName();
        Set<String> projectRosterRoleValueList = new Set<String>();
        //ProjectProfile => Task Item User Owner Role => Task Item User OwnerId => ProjectRoster
        Map<Id, Map<String, Map<Id, Project_Roster__c>>> projectWithRosterRoleUsersMap = new Map<Id, Map<String, Map<Id, Project_Roster__c>>>();

        for (Task_Item__c taskItemItem : filteredTaskItemList){
            String taskOwnerRole =  userIdToRoleName.get(taskItemItem.OwnerId);
            projectRosterRoleValueList.add( taskOwnerRole );
            if (!projectWithRosterRoleUsersMap.containsKey(taskItemItem.Project_Profile__c)) {
                projectWithRosterRoleUsersMap.put(taskItemItem.Project_Profile__c, new Map<String, Map<Id, Project_Roster__c>>());
            }
            if (!projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).containsKey(taskOwnerRole)){
                projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).put(taskOwnerRole, new Map<Id, Project_Roster__c>());
            }
            if (!projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).get(taskOwnerRole).containsKey(taskItemItem.OwnerId)){
                projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).get(taskOwnerRole).put(taskItemItem.OwnerId, null);
            }
        }

        Map<Id, Project_Profile__c> projectProfileWithRosterMap = new Map<Id, Project_Profile__c>([SELECT Id, Proposal__c, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c,
                                                                                                        ( SELECT Id, User__c, Role__c, Project_Profile__c, RecordTypeId
                                                                                                          FROM Project_Rosters__r
                                                                                                          WHERE RecordType.Name = 'User' AND
                                                                                                                Active__c = true AND
                                                                                                                Role__c IN : projectRosterRoleValueList )
                                                                                                   FROM Project_Profile__c
                                                                                                   WHERE Id IN : projectWithRosterRoleUsersMap.keySet()]);

        Id userProjectRosterRecordTypeId;

        for (Project_Profile__c projectProfileItem : projectProfileWithRosterMap.values()){
            if ( userProjectRosterRecordTypeId == null && !projectProfileItem.Project_Rosters__r.isEmpty() ) userProjectRosterRecordTypeId = projectProfileItem.Project_Rosters__r[0].RecordTypeId;
            for (Project_Roster__c projectRosterItem : projectProfileItem.Project_Rosters__r){
                if ( projectWithRosterRoleUsersMap.get( projectRosterItem.Project_Profile__c ).containsKey(projectRosterItem.Role__c) &&
                     projectWithRosterRoleUsersMap.get( projectRosterItem.Project_Profile__c ).get(projectRosterItem.Role__c).containsKey(projectRosterItem.User__c) &&
                     projectWithRosterRoleUsersMap.get( projectRosterItem.Project_Profile__c ).get(projectRosterItem.Role__c).get(projectRosterItem.User__c) == null ){
                    projectWithRosterRoleUsersMap.get( projectRosterItem.Project_Profile__c ).get(projectRosterItem.Role__c).put(projectRosterItem.User__c, projectRosterItem);
                }
            }
        }


        if ( userProjectRosterRecordTypeId == null ){
            for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
                if (schemaRecordTypeInfoItem.getName() == 'User'){ userProjectRosterRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId(); }
            }
        }

        List<Project_Roster__c> projectRosterUpsertList = new List<Project_Roster__c>();
        Map<Id, Project_Roster__c> projectRosterUpdateMap = new Map<Id, Project_Roster__c>();

        for ( Task_Item__c taskItemItem : filteredTaskItemList){
            if (taskItemItem.Project_Profile__c == null) continue;

            Project_Profile__c projectProfileItem = projectProfileWithRosterMap.get(taskItemItem.Project_Profile__c);

            if ( taskItemItem.OwnerId == projectProfileItem.Project_Manager__c || taskItemItem.OwnerId == projectProfileItem.Project_Member__c ||
                 taskItemItem.OwnerId == projectProfileItem.FREP__c || taskItemItem.OwnerId == projectProfileItem.Production_Manager__c ){
                continue;
            }

            String taskOwnerRole =  userIdToRoleName.get(taskItemItem.OwnerId);
            Project_Roster__c projectRosterItem = projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).get(taskOwnerRole).get(taskItemItem.OwnerId);
            if ( projectRosterItem == null || taskItemItem.OwnerId != projectRosterItem.User__c || taskOwnerRole != projectRosterItem.Role__c ){
                projectRosterItem = ProjectProfileServices.createAfterAssignProjectRoster( taskItemItem.OwnerId,
                                                                                           taskItemItem.Project_Profile__c,
                                                                                           projectProfileWithRosterMap.get(taskItemItem.Project_Profile__c).Proposal__c,
                                                                                           userProjectRosterRecordTypeId,
                                                                                           taskOwnerRole,
                                                                                           projectRosterItem );
                projectWithRosterRoleUsersMap.get(taskItemItem.Project_Profile__c).get(taskOwnerRole).put(taskItemItem.OwnerId, projectRosterItem);
                if ( projectRosterItem.Id == null ){ projectRosterUpsertList.add(projectRosterItem); } else { projectRosterUpdateMap.put(projectRosterItem.Id, projectRosterItem); }
            }
        }

        projectRosterUpsertList.addAll(projectRosterUpdateMap.values());

        try {
            upsert projectRosterUpsertList;
        } catch ( DMLException dmlEx ){
            Map<Id, Map<String, String>> tasksWithError = new Map<Id, Map<String, String>>();
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                Project_Roster__c projectRosterItemError = projectRosterUpsertList[dmlEx.getDmlIndex(i)];
                if ( !tasksWithError.containsKey(projectRosterItemError.Project_Profile__c) ){
                    tasksWithError.put(projectRosterItemError.Project_Profile__c, new Map<String, String>{projectRosterItemError.Role__c => dmlEx.getMessage()});
                } else {
                    tasksWithError.get(projectRosterItemError.Project_Profile__c).put( projectRosterItemError.Role__c, dmlEx.getMessage());
                }
            }
            for (Task_Item__c taskItemItemError : filteredTaskItemList){
                if (tasksWithError.containsKey(taskItemItemError.Project_Profile__c) && tasksWithError.get(taskItemItemError.Project_Profile__c).containsKey(userIdToRoleName.get(taskItemItemError.OwnerId))){
                    taskItemItemError.addError('can not update project roster ' + tasksWithError.get(taskItemItemError.Project_Profile__c).containsKey(userIdToRoleName.get(taskItemItemError.OwnerId)));
                }
            }
        }

        List<Id> projectListId = new List<Id>();
        projectListId.addAll(projectWithRosterRoleUsersMap.keySet());
        ProjectRosterServices.updateRostersIsActiveState(projectListId, null, true, true, false, true);
    }

    public static void prepareDataAndRunFutureMethod(List<Task_Item__c> newTaskItemList, Map<Id, Task_Item__c> newTaskItemMap, Map<Id, Task_Item__c> oldTaskItemMap){
        Set<Id> allTaskItemSetIds = oldTaskItemMap.keySet();


        calculateExpectedDateFutureMethod( allTaskItemSetIds );
    }

    @future //MRS-7473
    public static void createFormItemsAndFolderFuture( Set<Id> taskItemsFormItems, Set<Id> taskItemsFolder ){//MRS-7473
        if (taskItemsFormItems != null && !taskItemsFormItems.isEmpty()){
            List<Task_Item__c> allTaskItemListNew = [SELECT Id, Name, Project_Profile__c, Service_Item__c, External_Form__c, Forms_Formula__c
                                                     FROM Task_Item__C
                                                     WHERE Id IN : taskItemsFormItems];
            FormItemsServices.createFormItemsAfterTaskInsert( allTaskItemListNew );
        }

        if (taskItemsFolder != null && !taskItemsFolder.isEmpty()){
            StoredDocumentServices.createFolders( taskItemsFolder );
        }
    }

    // calculate Task Item, Service Item Expected/Actual Duration for more then 200 Service Items in the Project
    @future
    public static void calculateExpectedDateFutureMethod( Set<Id> allTaskItemSetIds ){

        Map<Id, Task_Item__c> taskItemMapNew = new Map<Id, Task_Item__c>([SELECT Id, Name, Status__c, Service_Item__c, RecordTypeId, RecordType.Name, OwnerId, Expected_Start_Date__c, Expected_End_Date__c, Expected_Duration__c,
                                                                                Actual_Start_Date__c, Actual_End_Date__c, Actual_Duration__c, Sequence_Number__c, Predecessor_Task__c, Successor_Task__c, Project_Profile__c,
                                                                                Predecessor_Milestone__c, Successor_Milestone__c
                                                                          FROM Task_Item__c
                                                                          WHERE Id IN : allTaskItemSetIds]);

        runInFutureMethod = true;

        try{

            Map<String, Map<Id, Task_Item__c>> filteredTasksWithDateField = new Map<String, Map<Id, Task_Item__c>>{ START_DATE_FIELD => new Map<Id, Task_Item__c>(), END_DATE_FIELD => new Map<Id, Task_Item__c>() };
            for (Task_Item__c taskItem : taskItemMapNew.values()){
                if ( taskItem.Actual_End_Date__c == null ){
                    filteredTasksWithDateField.get(START_DATE_FIELD).put(taskItem.Id, taskItem);
                } else {
                    filteredTasksWithDateField.get(END_DATE_FIELD).put(taskItem.Id, taskItem);
                }
            }

            //before update scope methods start
            if( filteredTasksWithDateField.get( START_DATE_FIELD ).size() == 1 ) {
                updateExpectedDatesForAllServices( filteredTasksWithDateField.get( START_DATE_FIELD ), true );
            } // Changed Actual End Date
            else if( !filteredTasksWithDateField.get( END_DATE_FIELD ).isEmpty() ) {
                // Changed Actual End Date - WORKS ONLY FOR ONE TASK ITEM (MANUAL UPDATING OF TASK)!!!
                if( filteredTasksWithDateField.get( END_DATE_FIELD ).size() == 1 ) {
                    updateExpectedDatesForAllServices( filteredTasksWithDateField.get( END_DATE_FIELD ), false );
                }
                // If Dependency Task is completed with Disaprove Status then insert new alternative path into the Task flow
//                insertAlternativeTaskLineToConditionalTasks( filteredTasksWithDateField.get( END_DATE_FIELD ) ); //MRS-6903
            }

        } catch (Exception ex){

            try{
                List<Task_Item__c> taskItemListWithError = [SELECT Id, Avoid_Validation_Rules__c, Error_Value__c FROM Task_Item__c WHERE Id IN : allTaskItemSetIds];
                for (Task_Item__c taskItem : taskItemListWithError){
                    taskItem.Error_Value__c += '\nDateTime Error occured = ' + String.valueOf(DateTime.now()) +
                                                '\nerror message: ' + ex.getMessage() +
                                                '\nStackTrace' + ex.getStackTraceString();
                }
                update taskItemListWithError;
            } catch (Exception dmlEx){}
            ErrorException.addLog(ex, null, 'TaskItem Set <Id> = "' + allTaskItemSetIds + '"', 'Future execution TaskItemServices.calculateExpectedDateFutureMethod udate Dates');
        }
    }

    //MRS-6815
    public static void avoidValidationRuleInFuture(List<Task_Item__c> taskItemNewList){
        for (Task_Item__c taskItemItem : taskItemNewList){
            taskItemItem.Avoid_Validation_Rules__c = !taskItemItem.Avoid_Validation_Rules__c;
        }
    }

    public static void setLowercaseExpectedDuration( List<Task_Item__c> newtaskItems, Map<Id, Task_Item__c> oldTaskItems ) {
        for( Task_Item__c ti : newTaskItems ) {
            if( ti.Expected_Duration__c != null &&
                ( oldTaskItems == null || oldTaskItems.get( ti.Id ).Expected_Duration__c != ti.Expected_Duration__c ) ) {
                ti.Expected_Duration__c = ti.Expected_Duration__c.toLowerCase();
            }
        }
    }

    //MRS-6304
    public static List<Task_Item__c> filteredTaskItemWithChangedExpirationDate( List<Task_Item__c> newtaskItems, Map<Id, Task_Item__c> oldTaskItems ){
        List<Task_Item__c> filteredTaskItemList = new List<Task_Item__c>();

        for (Task_Item__c taskItemItem : newtaskItems){
            if ( (taskItemItem.Expiration_Date__c != oldTaskItems.get(taskItemItem.Id).Expiration_Date__c ) && taskItemItem.Name != null &&
                 taskItemItem.Name.contains( PICKUP_ANALIZE_TASK_NAME ) && taskItemItem.Service_Item__c != null &&
                 taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID ){

                filteredTaskItemList.add(taskItemItem);
            }
        }

        return filteredTaskItemList;
    }

    public static void updateServiceItemExpirationDate( List<Task_Item__c> filteredTaskItems ){
        if ( filteredTaskItems == null || filteredTaskItems.isEmpty() ) return;

        Map<Id, Service_Item__c> serviceItemUpdateMap = new Map<Id, Service_Item__c>();

        for (Task_Item__c taskItemItem : filteredTaskItems){
            Date newExpirationDate = taskItemItem.Expiration_Date__c != null ? Date.newInstance(taskItemItem.Expiration_Date__c.year(),
                                                                                                taskItemItem.Expiration_Date__c.month(),
                                                                                                taskItemItem.Expiration_Date__c.day()) :
                                                                                                null;
            serviceItemUpdateMap.put( taskItemItem.Service_Item__c, new Service_Item__c( Id = taskItemItem.Service_Item__c,
                                                                                         Expiration_Date__c = newExpirationDate) );
        }

        try {
            update serviceItemUpdateMap.values();
        } catch (DMLException dmlEx){
            if (Trigger.isExecuting){
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                    Id serviceItemId = serviceItemUpdateMap.values()[dmlEx.getDmlIndex(i)].Id;
                    for ( Task_Item__c taskItem : filteredTaskItems ){
                        if ( taskItem.Service_Item__c == serviceItemId ) taskItem.addError( Label.Update_Task_Item_Error + dmlEx.getMessage() );
                    }
                }
            } else {
                throw new ErrorException ( Label.Update_Task_Item_Error + dmlEx.getMessage() );
            }
        }
    }

    //MRS-6903
    public static List<Task_Item__c> filteredTaskItemWithDisapprovedStatus( List<Task_Item__c> newtaskItems, Map<Id, Task_Item__c> oldTaskItems ){
        List<Task_Item__c> filteredTaskItemList = new List<Task_Item__c>();

        for (Task_Item__c taskItemItem : newtaskItems){
            if ( (taskItemItem.Status__c == TASK_ITEM_STATUS_DISAPPROVED && taskItemItem.Status__c != oldTaskItems.get(taskItemItem.Id).Status__c && oldTaskItems.get(taskItemItem.Id).Status__c != TASK_ITEM_STATUS_APPROVED ) &&
                 taskItemItem.Name.contains( PICKUP_ANALIZE_TASK_NAME ) && taskItemItem.Service_Item__c != null &&
                 taskItemItem.RecordTypeId != TaskManagementServices.MILESTONE_RECORDTYPE_ID ){

                filteredTaskItemList.add(taskItemItem);
            }
        }

        return filteredTaskItemList;
    }

    public static void updateDisapprovedDate( List<Task_Item__c> filteredTaskItems ){
        if ( filteredTaskItems == null || filteredTaskItems.isEmpty() ) return;

        Map<Id, Service_Item__c> serviceItemUpdateMap = new Map<Id, Service_Item__c>();

        Map<Id, Task_Item__c> taskItemWithTIFMap = new Map<Id, Task_Item__c>([SELECT Id, Status__c, Service_Item__c,
                                                                                (Select Id, Disapproved_Date__c
                                                                                 From Task_Item_Functionality__r
                                                                                 Where Is_Saved__c = true
                                                                                        Order By CreatedDate DESC, Disapproved_Date__c DESC NULLS FIRST LIMIT 1)
                                                                             FROM Task_Item__c
                                                                             WHERE Id = : filteredTaskItems]);

        for (Task_Item__c taskItemItem : filteredTaskItems){
            taskItemItem.X3rd_Party_Disapproved_Date__c = !(taskItemWithTIFMap.get(taskItemItem.Id).Task_Item_Functionality__r).isEmpty() ?
                                                                        taskItemWithTIFMap.get(taskItemItem.Id).Task_Item_Functionality__r[0].Disapproved_Date__c :
                                                                        taskItemItem.X3rd_Party_Disapproved_Date__c;
        }
    }

	public static void preventChangingOwnerOnCopletedTasks(List<Task_Item__c> newList, Map<Id, Task_Item__c> oldMap) { //MRS 7379 7578
		if(ProposalWizardServices.getProfileNameById(UserInfo.getProfileId()) != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN && !ServiceItemServices.taskItemOwnerUpdatedFromServiceItemTrigger) {
			for(Task_Item__c ti : newList) {
				if(!ServiceItemServices.taskItemOwnerUpdatedFromServiceItemTrigger && ti.OwnerId != oldMap.get(ti.Id).OwnerId && 
					ti.Actual_End_Date__c  != null && oldMap.get(ti.Id).Actual_End_Date__c != null) {
						ti.OwnerId = oldMap.get(ti.Id).OwnerId;
						ti.addError('You can not change Owner once Task is completed.');
				}
			}
        }
    }
}