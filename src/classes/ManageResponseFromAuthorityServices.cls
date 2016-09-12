public without sharing class ManageResponseFromAuthorityServices{
    public static final String SENT_VIA_EMAIL = 'Email';
    public static Map<Id, Manage_Response_From_Authority__c> filterResponseRecordsToCreateReminders( Map<Id, Manage_Response_From_Authority__c> newResponseItemMap, Map<Id, Manage_Response_From_Authority__c> oldResponseItemMap ){
        Map<Id, Manage_Response_From_Authority__c> filteredResponseItems = new Map<Id, Manage_Response_From_Authority__c>();
        for( Manage_Response_From_Authority__c responseItem: newResponseItemMap.values() ){
            if( responseItem.Received_Date_Time__c == null && responseItem.Alert_Time__c != null && responseItem.Use_Alert__c && ( !oldResponseItemMap.get(responseItem.Id).Use_Alert__c || oldResponseItemMap.get(responseItem.Id).Alert_Time__c == null ) ){
                filteredResponseItems.put( responseItem.Id, responseItem );
            }
        }
        return filteredResponseItems;
    }

    public static void createEventsForProjectManager( Map<Id, Manage_Response_From_Authority__c> ResponseItemMap) {
        List<Event> eventsToUpsert = new List<Event>();
        for( Manage_Response_From_Authority__c responseItem: ResponseItemMap.values() ){
            Event newEvent = new Event();
            newEvent.OwnerId = UserInfo.getUserId();
            newEvent.WhatId = responseItem.Task_Item__c;
            newEvent.Subject = 'Reminder for Project Manager';
            
            newEvent.IsReminderSet = true;
            newEvent.ReminderDateTime = datetime.now();

            newEvent.StartDateTime = responseItem.Alert_Time__c;
            newEvent.EndDateTime = responseItem.Alert_Time__c;
            newEvent.Description = 'Manage Response From Authority';
            eventsToUpsert.add( newEvent );
        }
    
        try{
            insert eventsToUpsert;
        }
        catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                ResponseItemMap.get(eventsToUpsert[dmlEx.getDmlIndex(i)].WhatId).addError( 'Error upserting Event' + dmlEx.getMessage() );
            }
        }
    }

    public static Map<Id, Manage_Response_From_Authority__c> filterResponseRecordsToDeleteReminders( Map<Id, Manage_Response_From_Authority__c> newResponseItemMap, Map<Id, Manage_Response_From_Authority__c> oldResponseItemMap ){
        Map<Id, Manage_Response_From_Authority__c> filteredResponseItems = new Map<Id, Manage_Response_From_Authority__c>();
        for( Manage_Response_From_Authority__c responseItem: newResponseItemMap.values() ){
            if( responseItem.Received_Date_Time__c != null && responseItem.Received_Date_Time__c != oldResponseItemMap.get(responseItem.Id).Received_Date_Time__c ){
                filteredResponseItems.put( responseItem.Id, responseItem );
            }
        }
        return filteredResponseItems;
    }

    public static void deleteEventsForProjectManager( Map<Id, Manage_Response_From_Authority__c> ResponseItemMap ) {
        Set<Id> taskItemsId = new Set<Id>(); 
        for( Manage_Response_From_Authority__c responseItem: ResponseItemMap.values() ){
            responseItem.Use_Alert__c = false;
            responseItem.Alert_Time__c = null;
            taskItemsId.add(responseItem.Task_Item__c);
        }
        List<Event> eventsToDelete = new List<Event>([SELECT Id, WhatId FROM Event WHERE WhatId IN: taskItemsId]);
        try{
            delete eventsToDelete;
        }
        catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                ResponseItemMap.get(eventsToDelete[dmlEx.getDmlIndex(i)].WhatId).addError( 'Error deleting Event' + dmlEx.getMessage() );
            }
        }
    }
}