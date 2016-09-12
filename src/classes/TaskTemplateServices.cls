public with sharing class TaskTemplateServices {
    public static final String INVALID_TASK_SEQUENCE  = 'You have defined incorrect Sequence Number. Please review previously created Tasks within Service and figure out what is wrong.';


    public static List<Task_Template__c> getTasksWithDurrationByServiceIds(List<Id> serviceIds) {
        if (null == serviceIds || serviceIds.isEmpty()) {
            return new List<Task_Template__c>();
        
        }
        return new List<Task_Template__c>([SELECT Id, Standard_Duration__c, Service__c
                                           FROM Task_Template__c
                                           WHERE Service__c IN : serviceIds]);
    
    }

    public static List<Service_Template__c> getServiceTemplatesWithTaskStateChangesAndActualTaskTemplates( Set<Id> serviceIds ) {
        if ( serviceIds.isEmpty())  return new List<Service_Template__c>();
        
        return new List<Service_Template__c>( [ Select Id, ( SELECT Id, Related_Task__c, Task_Line__c, Condition__c, Service__c FROM Task_State_Changes__r ),
                                                       ( SELECT Id, Standard_Duration__c, Name, Results__c, Description__c, Financial_Force_Integration__c, Input__c,
                                                                Forms__c, Reminder_Offset__c, Manager_Role__c, Notes__c, Resources__c, Task_Action__c, Billing_Trigger__c,
                                                                Predecessor_Milestone__c, Successor_Milestone__c, Billing_Percentage__c, Predecessor_Task__c, Successor_Task__c,
                                                                Artifacts__c, Service__c, Sequence_Number__c
                                                          FROM Tasks__r Order By Sequence_Number__c )
                                                From Service_Template__c
                                                Where Id IN :serviceIds ] );
    }

    public static void updateTaskTemplateNames( List<Task_Template__c> newTaskTemplates ){
        for( Task_Template__c tt : newTaskTemplates ){
            if( tt.Task_Type__c != null ) {
                tt.Name = tt.Task_Type__c;
                tt.Is_Manually_Created__c = true;
            }
        }
    }

    //ONLY FOR MANUAL CREATED TASKS
    public static void populateSuccessorPredecessorTasks( List<Task_Template__c> newTaskTemplates ){
        if( newTaskTemplates.size() > 1 ) return;
        
        Task_Template__c currentTaskTemplate = newTaskTemplates[0];
        if( !currentTaskTemplate.Is_Manually_Created__c ) return;

        Service_Template__c parrentService = [ Select Id, RecordType.Name From Service_Template__c Where Id =: currentTaskTemplate.Service__c];

        Map<Integer, Task_Template__c> seqNimberToTaskTemplate = new Map<Integer, Task_Template__c>();

        List<Task_Template__c> previousCreatedTaskTemplates = [ Select Id, Sequence_Number__c, Successor_Task__c, Predecessor_Task__c 
                                                                From Task_Template__c
                                                                Where Service__c = : currentTaskTemplate.Service__c AND 
                                                                      Sequence_Number__c <= : currentTaskTemplate.Sequence_Number__c + 1 AND
                                                                      Sequence_Number__c >= : currentTaskTemplate.Sequence_Number__c - 1 
                                                                Order By Sequence_Number__c ];

        if( previousCreatedTaskTemplates.size() > 3 ) currentTaskTemplate.addError( INVALID_TASK_SEQUENCE );

        for( Task_Template__c tt : previousCreatedTaskTemplates ){
            if( seqNimberToTaskTemplate.containsKey( Integer.valueOf( tt.Sequence_Number__c ) ) ) currentTaskTemplate.addError( INVALID_TASK_SEQUENCE );

            seqNimberToTaskTemplate.put( Integer.valueOf( tt.Sequence_Number__c ), tt );
        }

        if( parrentService.RecordType.Name != 'Subservice' && 
            !seqNimberToTaskTemplate.containsKey( Integer.valueOf( currentTaskTemplate.Sequence_Number__c - 1 ) ) && 
            currentTaskTemplate.Sequence_Number__c > 1 ) {
                currentTaskTemplate.addError( INVALID_TASK_SEQUENCE );
            }

        for( Task_Template__c tt : previousCreatedTaskTemplates ){
            if( tt.Sequence_Number__c < currentTaskTemplate.Sequence_Number__c && tt.Successor_Task__c == null ) {
                tt.Successor_Task__c = currentTaskTemplate.Id;
                seqNimberToTaskTemplate.get( Integer.valueOf( currentTaskTemplate.Sequence_Number__c ) ).Predecessor_Task__c = tt.Id;
            } else if( tt.Sequence_Number__c > currentTaskTemplate.Sequence_Number__c && tt.Predecessor_Task__c == null ) {
                tt.Predecessor_Task__c = currentTaskTemplate.Id;
                seqNimberToTaskTemplate.get( Integer.valueOf( currentTaskTemplate.Sequence_Number__c ) ).Successor_Task__c = tt.Id;
            }
        }

        update previousCreatedTaskTemplates;
    }
    
}