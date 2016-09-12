public with sharing class EventServices {

    public static String TASK_ALERT_SUBJECT = 'Task Alert';
    public static String TASK_NOTIFICATION_SUBJECT = 'Task Notification';
    public static String PM_REMINDER_SUBJECT = 'Reminder for Project Manager';
    public static String ACCOUNT_MANAGER_MSA_REMINDER = ' Master Service Agreement is due to expire on ';

    public static void createEventsFromTaskItemIfAlertIfNotification ( Map<String, List<Task_Item__c>> eventSubjectTofilterTaskItemsForEventAlertNotification ) {
        if( eventSubjectTofilterTaskItemsForEventAlertNotification == null ||
            eventSubjectTofilterTaskItemsForEventAlertNotification.isEmpty() ){
            return;
        }
        List<Task_Item__c> taskItemsForAlert = new List<Task_Item__c>();
        List<Task_Item__c> taskItemsForNotification = new List<Task_Item__c>();
        if(eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_ALERT_SUBJECT) != null) {
            for( Task_Item__c item: eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_ALERT_SUBJECT) ){
                taskItemsForAlert.add(item);
            }
        }
        if(eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_NOTIFICATION_SUBJECT) != null) {
            for( Task_Item__c item: eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_NOTIFICATION_SUBJECT) ){
                taskItemsForNotification.add(item);
            }
        }
        if( taskItemsForAlert.isEmpty() && taskItemsForNotification.isEmpty() ) return;
        Map<Id, Id> taskItemIdToPM1Id = new Map<Id, Id>();
        for(Task_Item__c item: [Select Id, Project_Profile__r.Project_Team__r.Project_Member__c From Task_Item__c
                                Where Id IN: taskItemsForAlert OR
                                      Id IN: taskItemsForNotification ]){
            taskItemIdToPM1Id.put(item.Id, item.Project_Profile__r.Project_Team__r.Project_Member__c );
        }
        System.debug('@taskItemIdToPM1Id='+taskItemIdToPM1Id);
        List<Event> eventList = new List<Event>();
        Event newReminderEvent;
        Event newNotificationEvent;
        for( Task_Item__c taskItem: taskItemsForAlert ) {
            if( taskItem.Task_Alert__c ){
                newReminderEvent = new Event();

                newReminderEvent.Description = TASK_ALERT_SUBJECT;
                newReminderEvent.OwnerId = ( taskItemIdToPM1Id.get(taskItem.Id) != null ) ? taskItemIdToPM1Id.get(taskItem.Id) : taskItem.OwnerId;
                newReminderEvent.WhatId = taskItem.Id;
                newReminderEvent.Subject = TASK_ALERT_SUBJECT;
                newReminderEvent.StartDateTime = taskItem.Expected_Start_Date__c;
                newReminderEvent.EndDateTime = ( taskItem.Expected_End_Date__c.addDays(-14) > taskItem.Expected_Start_Date__c ) ? taskItem.Expected_Start_Date__c.addDays(14) : taskItem.Expected_End_Date__c ;

                eventList.add( newReminderEvent );

            }
        }

        for( Task_Item__c taskItem: taskItemsForNotification ) {
            if( taskItem.Task_Notification__c ){
                newNotificationEvent = new Event();

                newNotificationEvent.Description = TASK_NOTIFICATION_SUBJECT;
                newNotificationEvent.OwnerId = ( taskItemIdToPM1Id.get(taskItem.Id) != null ) ? taskItemIdToPM1Id.get(taskItem.Id) : taskItem.OwnerId;
                newNotificationEvent.WhatId = taskItem.Id;
                newNotificationEvent.Subject = TASK_NOTIFICATION_SUBJECT;
                newNotificationEvent.StartDateTime = taskItem.Expected_Start_Date__c;
                newNotificationEvent.EndDateTime = ( taskItem.Expected_End_Date__c.addDays(-14) > taskItem.Expected_Start_Date__c ) ? taskItem.Expected_Start_Date__c.addDays(14) : taskItem.Expected_End_Date__c ;

                eventList.add( newNotificationEvent );

            }
            System.debug('@eventList'+eventList);
        }

        try{
            if( !eventList.isEmpty() ) {
                insert eventList;
            }
        }
        catch ( DMLException dmlEx ){
            if ( Trigger.isExecuting ){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Event eventItem = eventList[dmlEx.getDmlIndex(i)];
                    if( eventItem.Subject == TASK_ALERT_SUBJECT ){
                        new Map<Id, Task_Item__c> (eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_ALERT_SUBJECT)).get(eventItem.WhatId).addError( Label.Create_Event_Error + dmlEx.getMessage() );
                    }
                    if( eventItem.Subject == TASK_NOTIFICATION_SUBJECT ){
                        new Map<Id, Task_Item__c> (eventSubjectTofilterTaskItemsForEventAlertNotification.get(TASK_NOTIFICATION_SUBJECT)).get(eventItem.WhatId).addError( Label.Create_Event_Error + dmlEx.getMessage() );
                    }
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
        }
    }

    public static void deleteEventsFromTaskItemIfAlertIfNotification ( List<Task_Item__c> newTaskItemList ) {
        if (newTaskItemList.isEmpty()){
            return;
        }

        List<Task_Item__c> taskItemList = [Select Id, Task_Alert__c, Task_Notification__c, (Select WhatId, Subject, OwnerId, Id From Events)
                                                                    From Task_Item__c Where Id IN: newTaskItemList];

        List<Event> eventList = new List<Event>();
        for( Task_Item__c taskItem: taskItemList ) {
            if( !taskItem.Task_Alert__c ){
                for( Event event: taskItem.Events ){
                    if(event.Subject == TASK_ALERT_SUBJECT)
                    eventList.add( event );
                }
            }
            if( !taskItem.Task_Notification__c ){
                for( Event event: taskItem.Events ){
                    if(event.Subject == TASK_NOTIFICATION_SUBJECT)
                    eventList.add( event );
                }
            }
            System.debug('@eventList'+eventList);
        }

        try{
            if( !eventList.isEmpty() ) {
                delete eventList;
            }
        }
        catch ( DMLException dmlEx ){
            if ( Trigger.isExecuting ){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    Event eventItem = eventList[dmlEx.getDmlIndex(i)];
                    new Map<Id, Task_Item__c> (newTaskItemList).get(eventItem.WhatId).addError( 'Can not delete Event' + dmlEx.getMessage() );
                }
            } else {
                throw new ErrorException( dmlEx.getMessage() );
            }
        }
    }

    public static void updateEventsIsReminderSetForSignatureSealsTaskItem(List<Event> eventList) {
        Set<Id> taskItemIds = new Set<Id>();
        String whatId;
        List<Event> eventForUpdateMap = new List<Event>();
        for(Event event : eventList) {
            if( !String.isBlank(event.WhatId) && !String.isBlank(event.Subject) ) {
                whatId = (String)event.WhatId;
                if( whatId.startsWith(Schema.SObjectType.Task_Item__c.getKeyPrefix()) && event.Subject.equals(PM_REMINDER_SUBJECT) && !event.IsReminderSet) {
                    taskItemIds.add((Id)whatId);
                    eventForUpdateMap.add(event);
                }
            }
        }
        if(taskItemIds.isEmpty()) return;
        Map<Id, Task_Item__c> taskItemMap = new Map<Id, Task_Item__c>([SELECT Id FROM Task_Item__c WHERE Id IN : taskItemIds AND RecordTypeId = : TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get( TaskItemServices.SEND_FORMS_TASK_NAME )]);

        if(taskItemMap.isEmpty()) return;
        for(Event event : eventForUpdateMap) {
            if(taskItemMap.containsKey(event.WhatId)) {
                event.IsReminderSet = true;
                event.ReminderDateTime = datetime.now() + 15;
            }
        }
    }

    public static void manageEventsForSignatureSealsTaskItem( List<Form_Assignment__c> newList ) {
        Set<Id> taskItemIds = new Set<Id>();
        Map<Id, List<Form_Assignment__c>> taskItemIdToFormAssignments = new Map<Id, List<Form_Assignment__c>>();
        List<Event> eventsToDelete = new List<Event>();
        List<Event> eventsToCreate = new List<Event>();
        List<Form_Assignment__c> filteredFormAssignments;

        filteredFormAssignments = [ SELECT Alert_Calendar__c, Form_Item__r.Complete_Forms__c
                                    FROM Form_Assignment__c
                                    WHERE Id IN : newList
                                     AND Form_Item__r.Complete_Forms__r.RecordTypeId = : TaskItemServices.TASK_ITEM_RECORD_TYPE_IDS.get( TaskItemServices.SEND_FORMS_TASK_NAME ) ];

        for( Form_Assignment__c formAssignmentItem : filteredFormAssignments ) {
            taskItemIds.add( formAssignmentItem.Form_Item__r.Complete_Forms__c );
        }
        taskItemIds.remove( null );

        filteredFormAssignments = [ SELECT Alert_Calendar__c, Form_Item__r.Complete_Forms__c
                                    FROM Form_Assignment__c
                                    WHERE Form_Item__r.Complete_Forms__c IN : taskItemIds ];

        if( !filteredFormAssignments.isEmpty() ) {
            for( Form_Assignment__c formAssignmentItem : filteredFormAssignments ) {
                if( taskItemIdToFormAssignments.get( formAssignmentItem.Form_Item__r.Complete_Forms__c ) == null ) {
                    taskItemIdToFormAssignments.put( formAssignmentItem.Form_Item__r.Complete_Forms__c, new List<Form_Assignment__c>() );
                }
                taskItemIdToFormAssignments.get( formAssignmentItem.Form_Item__r.Complete_Forms__c ).add( formAssignmentItem );
            }
            taskItemIdToFormAssignments.remove( null );

            eventsToDelete = [SELECT Id FROM Event WHERE WhatId IN : taskItemIdToFormAssignments.keySet() AND Subject = : PM_REMINDER_SUBJECT ];
            Event event;
            for( Form_Assignment__c formAssignmentItem : filteredFormAssignments ) {
                if( formAssignmentItem.Alert_Calendar__c != null ) {
                    event = createNewEvent( formAssignmentItem.Form_Item__r.Complete_Forms__c, formAssignmentItem.Alert_Calendar__c, PM_REMINDER_SUBJECT, TaskItemServices.SEND_FORMS_TASK_NAME );
                    eventsToCreate.add( event );
                }
            }

            Savepoint eventManagementSP = Database.setSavePoint();
            try {
                DELETE eventsToDelete;
            } catch( DMLException dmlEx ) {
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                    taskItemIdToFormAssignments.get( eventsToDelete[dmlEx.getDmlIndex(i)].WhatId )[0].addError( 'Error updating Events' + dmlEx.getMessage() );
                    Database.rollback( eventManagementSP );
                    return;
                }
            }
            try {
                INSERT eventsToCreate;
            } catch( DMLException dmlEx ) {
                for ( Integer i = 0; i < dmlEx.getNumDml(); i++ ){
                    taskItemIdToFormAssignments.get( eventsToCreate[dmlEx.getDmlIndex(i)].WhatId )[0].addError( 'Error updating Events' + dmlEx.getMessage() );
                    Database.rollback( eventManagementSP );
                    return;
                }
            }
        }
    }

    public static Event createNewEvent( Id parentObjectId, Datetime alertDateTime, String subject, String description) {
        return new Event( OwnerId = UserInfo.getUserId(),
                          WhatId = parentObjectId,
                          Subject = subject,
                          StartDateTime = alertDateTime,
                          EndDateTime = alertDateTime,
                          Description = description );
    }


    public static void updateAssignedTo(List<Event> events) {
        for(Event e : events) {
            if(!String.isBlank(e.Activitie_Id__c)) {
                e.OwnerId = e.Activitie_Id__c;
            }
        }
    }

}