public class TaskServices {
    public static Boolean preventor = false;

    public static final String TERMINATED_TASK_NAME_PREFIX = '(TERMINATED) ';
    public static final String TASK_STATUS_NOT_STARTED     = 'Not Started';
    public static final String TASK_PRIORITY_HIGH          = 'High';
    public static final String REMOVED_SERVICE_CO_SUBJECT  = 'Change Order has removed a service that has already been billed.';

    public static final String RELATED_TO_RECORD_NAME_NONE = '- None -';

    public static String taskPrefix { get { if( taskPrefix == null ) taskPrefix = Task.sObjectType.getDescribe().getKeyPrefix(); return taskPrefix; } private set; }

    public static List<Task> filteredTaskWithEmptyParentRecord ( List<Task> taskList ){
    	List<Task> filteredTasks = new List<Task>();
    	for( Task item: taskList ){
    		if( item.WhatId == null ) filteredTasks.add( item );
    	}
    	return filteredTasks;
    }

    public static void connectDummySharingRecordToTask ( List<Task> filteredTasks ) {
        if ( filteredTasks.isEmpty() ) return;
		Dummy_Sharing__c dummySharing = new Dummy_Sharing__c( Name = RELATED_TO_RECORD_NAME_NONE );
		for( Dummy_Sharing__c item: [Select Id, Name, CreatedById From Dummy_Sharing__c Where CreatedById =: UserInfo.getUserId() ]){
			dummySharing.Id = item.Id;
		}
		try{
			upsert dummySharing;
		}catch (Exception ex) {
            throw new ErrorException(ex.getMessage());
		}

		for( Task item: filteredTasks ){
			item.WhatId = dummySharing.Id;
		}
    }

    public static void createTask(final Id userId, final String status, final String priority, final Id parentId, final Datetime reminder, final Date dateActivity, final String subject, final String description, final String relatedRecordIds) {
        try {
            insert newInstance(userId, status, priority, parentId, reminder, dateActivity, subject, description, relatedRecordIds);

        } catch (Exception ex) {
            throw new ErrorException(ex.getMessage());

        }

    }

    public static List<Task> createTasksForStaffAccounts(final Set<Id> userIds, final String status, final String priority, final Datetime reminder, final Date dateActivity, final String subject, final Map<Id, List<String>> taskItemIdsToComments, final Map<Id, List<String>> taskItemIdsToRecordIds) {
        if (null == userIds || userIds.isEmpty() || null == taskItemIdsToComments || taskItemIdsToComments.isEmpty()) {
            return new List<Task>();

        }

        String description      = '';
        String relatedRecordIds = '';
        List<Task> tasks        = new List<Task>();

        for (Id taskItemId : taskItemIdsToComments.keySet()) {
            description      = String.join(taskItemIdsToComments.get(taskItemId), ',');
            relatedRecordIds = taskItemIdsToRecordIds.get(taskItemId) != null ? String.join(taskItemIdsToRecordIds.get(taskItemId), ';') : '';

            for (Id userId : userIds) {
                tasks.add(newInstance(userId, status, priority, taskItemId, reminder, dateActivity, subject.left(255), description, relatedRecordIds.left(255)));

            }

        }
        return tasks;

    }

    public static Task newInstance( final Id userId,
                                    final String status,
                                    final String priority,
                                    final Id parentId,
                                    final Datetime reminder,
                                    final Date dateActivity,
                                    final String subject,
                                    final String description,
                                    final String relatedRecordIds) {
        Task task         = new Task();
        task.OwnerId      = userId;
        task.Status       = status;
        task.Priority     = priority;
        task.WhatId       = parentId;
        if (null != reminder) {
            task.ReminderDateTime = reminder;
            task.IsReminderSet = true;

        }
        task.ActivityDate = dateActivity;
        task.Subject      = subject;
        task.Description  = description;
        if (!String.isBlank(relatedRecordIds)) {
            task.Related_Record_Ids__c = relatedRecordIds;

        }
        return task;

    }

    public static String buildSelectByRelatedIds(final Set<Id> checkIds) {
        String queryWhere = '';
        String selectQuery = 'SELECT Id, Related_Record_Ids__c, Status FROM Task WHERE Related_Record_Ids__c != null AND Status != \'Completed\' ';

        if (null == checkIds || checkIds.isEmpty()) {
            return selectQuery;

        }

        for (Id checkId : checkIds) {
            queryWhere += ' Related_Record_Ids__c LIKE\'%' + String.valueOf(checkId) + '%\' OR ';

        }
        queryWhere = queryWhere.removeEnd(' OR ');
        selectQuery += 'AND ( ' + queryWhere + ')' + ' limit 50000 ';
        return selectQuery;
    }

    public static void createTasksForARCoordinatorAfterCO(final Set<Id> serviceItemIds, final Set<Id> userIds, final Id projectId) {
        if (null == serviceItemIds || serviceItemIds.isEmpty() || null == userIds || userIds.isEmpty()) {
            return;

        }

        Decimal bliAmountSum = 0;
        List<Task> tasks = new List<Task>();

        for (Service_Item__c serviceItem : ServiceItemServices.getDeletedOriginalServiceItemByIds(serviceItemIds)) {
            bliAmountSum = 0;

            for (Billing_Line_Item__c bli : serviceItem.Billing_Line_Items_del__r) {
                bliAmountSum += bli.Amount__c;

            }

            if (serviceItem.Total_Service_Price__c == bliAmountSum) {
                for (Id userID : userIds) {
                    tasks.add(TaskServices.newInstance(userID, TASK_STATUS_NOT_STARTED, TASK_PRIORITY_HIGH, projectId, Datetime.now(), Date.today(), REMOVED_SERVICE_CO_SUBJECT, '', ''));

                }

            }

            if (tasks.size() > 0) {
                break;

            }

        }

        if (tasks.size() > 0) {
            insert tasks;

        }

    }

    public static void createTasksForStaffAccountantsForSalesInvoices( List<c2g__codaInvoice__c> invoices ) {
        List<Task> tasks = new List<Task>();
        Map<Id, Id> salesInvoiceIdToProjectProfileId = new Map<Id, Id>();
        Map<Id, Set<String>> projectProfileIdToDepositInvoiceTypes = new Map<Id, Set<String>>();
        Map<Id, c2g__codaInvoice__c> invoiceIdToInvoice = new Map<Id, c2g__codaInvoice__c>();
        Map<Id, String> invoiceIdToComments = new Map<Id, String>();
        Map<Id, String> salesInvoiceIdToProformaInvoiceName = new Map<Id, String>();
        Set<Id> users = UserServices.getUserIdsByProfileName( UserServices.PROFILE_STAFF_ACCOUNTANT );
        if( !users.isEmpty() ) {
            for( Pro_forma_Invoice__c proformaInvoiceItem : [ SELECT Name, Sales_Invoice__c, Project_Profile__c
                                                              FROM Pro_forma_Invoice__c
                                                              WHERE Sales_Invoice__c IN : invoices ] ) {
                salesInvoiceIdToProformaInvoiceName.put( proformaInvoiceItem.Sales_Invoice__c, proformaInvoiceItem.Name );
                if( !String.isBlank( proformaInvoiceItem.Project_Profile__c ) ) {
                    salesInvoiceIdToProjectProfileId.put( proformaInvoiceItem.Sales_Invoice__c, proformaInvoiceItem.Project_Profile__c );
                }
            }
            for( Deposit_Invoice__c depositInvoice : [ SELECT Project_Profile__c, Deposit_Invoice_Type__c
                                                       FROM Deposit_Invoice__c
                                                       WHERE ( Deposit_Invoice_Type__c = : DepositInvoiceServices.SERVICE_RETAINER_TYPE
                                                            OR Deposit_Invoice_Type__c = : DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE )
                                                         AND Amount_Remaining__c > 0
                                                         AND Project_Profile__c IN : salesInvoiceIdToProjectProfileId.values() ] ) {
                if( !projectProfileIdToDepositInvoiceTypes.containsKey( depositInvoice.Project_Profile__c ) ) projectProfileIdToDepositInvoiceTypes.put( depositInvoice.Project_Profile__c, new Set<String>() );
                projectProfileIdToDepositInvoiceTypes.get( depositInvoice.Project_Profile__c ).add( depositInvoice.Deposit_Invoice_Type__c );
            }
            for( c2g__codaInvoice__c invoiceItem : invoices ) {
                invoiceIdToInvoice.put( invoiceItem.Id, invoiceItem );
                invoiceIdToComments.put( invoiceItem.Id, 'Apply deposit to invoice ' + ( salesInvoiceIdToProformaInvoiceName.get( invoiceItem.Id ) == null ? '' : salesInvoiceIdToProformaInvoiceName.get( invoiceItem.Id ) ) );
            }
            for( c2g__codaInvoice__c invoiceItem : invoices ) {
                String invoiceTypes = '';
                if( !String.isBlank( salesInvoiceIdToProjectProfileId.get( invoiceItem.Id ) ) ) {
                    Set<String> invoiceTypesSet = projectProfileIdToDepositInvoiceTypes.get( salesInvoiceIdToProjectProfileId.get( invoiceItem.Id ) );
                    if( invoiceTypesSet != null && !invoiceTypesSet.isEmpty() ) {
                        List<String> invoiceTypesList = new List<String>();
                        invoiceTypesList.addAll( invoiceTypesSet );
                        invoiceTypes = String.join( invoiceTypesList, ', ' );
                    }
                }
                for(Id userId : users) {
                    tasks.add( newInstance( userId, TASK_STATUS_NOT_STARTED, TASK_PRIORITY_HIGH, invoiceItem.Id, Datetime.now(), Date.today(), invoiceIdToComments.get(invoiceItem.Id), invoiceTypes, null ) );
                }
            }
            try {
                INSERT tasks;
            } catch( DMLException dmlEx ) {
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                    invoiceIdToInvoice.get( tasks[dmlEx.getDmlIndex(i)].WhatId ).addError( 'Can not create Task for Sales Invoice: ' + dmlEx.getMessage() );
                }
            }
        }
    }

    public static List<Task> filteredCheckEmailTrecingList (List<Task> newTaskList){
        List<Task> resultTaskList = new List<Task>();
        for(Task taskItem : newTaskList){
            if ( taskItem.Subject != null && taskItem.Subject.startsWith('Email: ') && taskItem.WhoId != null && String.valueOf(taskItem.WhoId).startsWith('003') ){
                resultTaskList.add(taskItem);
            }
        }
        return resultTaskList;
    }

    public static void populateContactSendersList(List<Task> filteredTaskList){
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Contact> contactUpdateMap = new Map<Id,Contact>();
        for ( Task taskItem : filteredTaskList){
            contactMap.put(taskItem.WhoId, null);
        }
        contactMap = new Map<Id, Contact>([SELECT Id, Senders_Of_Emails__c, Email FROM Contact WHERE Email != null AND ID IN : contactMap.keySet() ]);
        for (Task taskItem : filteredTaskList){
            if (contactMap.containsKey(taskItem.WhoId)){
                Id taskOwnerId = Id.valueOf(taskItem.OwnerId);
                if (contactMap.get(taskItem.WhoId).Senders_Of_Emails__c == null || !contactMap.get(taskItem.WhoId).Senders_Of_Emails__c.contains(taskOwnerId)){
                    Contact contactItem = contactMap.get(taskItem.WhoId);
                    contactItem.Senders_Of_Emails__c = contactItem.Senders_Of_Emails__c == null ? taskOwnerId + '^' : contactItem.Senders_Of_Emails__c + taskOwnerId + '^';
                    contactUpdateMap.put(contactItem.Id, contactItem);
                }
            }
        }
        if (!contactUpdateMap.isEmpty()){
            Database.update(contactUpdateMap.values(), false);
        }
    }
}