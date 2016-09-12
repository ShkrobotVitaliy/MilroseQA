public with sharing class TaskManagementServices {
    public static final Integer FIRST_TASK_IN_SEQUENCE = 1;

    public static Map<Id, Map<Integer, Task_Item__c>> seqNumberToTaskItemForService = new Map<Id, Map<Integer, Task_Item__c>>();
    public static Map<Id, Set<Id>> taskIdWithPredecessors = new Map<Id, Set<Id>>();
    public static Map<Id, Set<Id>> taskIdWithSuccessors = new Map<Id, Set<Id>>();
    public static Map<Id, Task_Item__c> taskIdToTask = new Map<Id, Task_Item__c>();
    public static Map<Id, Task_Item__c> tasksToNotProcess = new Map<Id, Task_Item__c>();
    public static Datetime expectedStartDateForEditedTask;

    public static final String MILESTONE_RECORDTYPE_NAME = 'Milestone';
    public static final String MILESTONE_PROJECT_START = 'Project Start';

    public static final String TIME_DURATION_PATTERN = '0d 0h 0m';

    public static Id MILESTONE_RECORDTYPE_ID {
        get{
            if (MILESTONE_RECORDTYPE_ID == null){
                for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Task_Item__c.SObjectType.getDescribe().getRecordTypeInfos()){
                    if ( schemaRecordTypeInfoItem.getName() == MILESTONE_RECORDTYPE_NAME ){
                        MILESTONE_RECORDTYPE_ID = schemaRecordTypeInfoItem.getRecordTypeId();
                        break;
                    }
                }
            }
            return MILESTONE_RECORDTYPE_ID;
        }
    }

    public static void debugLogs( String logText, Boolean showLog ){
        if( showLog ){
            system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@ ' + logText );
        }
    }

    public static Id collectTaskPredecessorsAndSuccessors( Map<Id, Service_Item__c> serviceItemMap, Id taskItemIdStartFrom, Boolean cameFromDateCalculation, Boolean calculateDurations ) {
        Map<Integer, Task_Item__c> orderedListOfTasks;
        Id serviceIdDoNotUpdate;
        Service_Item__c currentServiceItem;

        try{
            for( Id serviceId : seqNumberToTaskItemForService.keySet() ) {
                currentServiceItem = serviceItemMap.get( serviceId );
                orderedListOfTasks = seqNumberToTaskItemForService.get( serviceId );
                List<Integer> ranksList = new List<Integer>();
                ranksList.addAll( orderedListOfTasks.keySet() );
                ranksList.sort();
System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices currentServiceItem.Name = ' + currentServiceItem.Name);
                for( Integer sequenceNumber : ranksList ) {
                    Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );

                    if( taskItem.Id == taskItemIdStartFrom ) { // Needed in future - calculatePlannedExpectedDatesForServices()
                        serviceIdDoNotUpdate = taskItem.Service_Item__c;
                    }

                    // Collect Predecessor Tasks for Successor
                    if( !taskIdWithPredecessors.containsKey( taskItem.Successor_Task__c ) ) {
                        taskIdWithPredecessors.put( taskItem.Successor_Task__c,  new Set<Id>() );
                    }
                    taskIdWithPredecessors.get( taskItem.Successor_Task__c ).add( taskItem.Id );
                    if( !taskIdWithPredecessors.containsKey( taskItem.Id ) ) {
                        taskIdWithPredecessors.put( taskItem.Id,  new Set<Id>() );
                    }
                    taskIdWithPredecessors.get( taskItem.Id ).add( taskItem.Predecessor_Task__c );

                    // Collect Successor Tasks for Predecessor
                    if( !taskIdWithSuccessors.containsKey( taskItem.Id ) ) {
                        taskIdWithSuccessors.put( taskItem.Id, new Set<Id>() );
                    }
                    taskIdWithSuccessors.get( taskItem.Id ).add( taskItem.Successor_Task__c );

                    if( !taskIdWithSuccessors.containsKey( taskItem.Predecessor_Task__c ) ) {
                        taskIdWithSuccessors.put( taskItem.Predecessor_Task__c, new Set<Id>() );
                    }
                    taskIdWithSuccessors.get( taskItem.Predecessor_Task__c ).add( taskItem.Id );

                    //Prepare Task map
                    taskIdToTask.put( taskItem.Id, taskItem );
                }
                taskIdWithPredecessors.remove( null );
                taskIdWithSuccessors.remove( null );

                if( !calculateDurations ) continue;//return serviceIdDoNotUpdate;

                if( currentServiceItem.Actual_End_Date__c != null && !currentServiceItem.Actual_Start_Date_Is_From_Terminator__c ) {
                    continue;
                }
                
                String serviceTotalDuration;
                if( !currentServiceItem.Actual_Start_Date_Is_From_Terminator__c ){
                    serviceTotalDuration = getTotalDurationForService( orderedListOfTasks, taskItemIdStartFrom );
                    currentServiceItem.Expected_Service_Duration__c = serviceTotalDuration;                
                } else {
                    serviceTotalDuration = getTotalDurationForServiceMi3( orderedListOfTasks, taskItemIdStartFrom, cameFromDateCalculation );
                    currentServiceItem.Expected_Service_Duration__c = serviceTotalDuration;
                }

                if( expectedStartDateForEditedTask != null ) {
                    if( !currentServiceItem.Actual_Start_Date_Is_From_Terminator__c || !cameFromDateCalculation ) {
                        currentServiceItem.Expected_Start_Date__c = expectedStartDateForEditedTask;
                    }
                    Datetime endDateWithShift = DateUtils.getDatetimeWithTimeShiftByBusinessHours( currentServiceItem.Expected_Start_Date__c, serviceTotalDuration );
                    
                    currentServiceItem.Expected_End_Date__c = endDateWithShift;
                    
                    if( !currentServiceItem.Project_Profile__r.Submitted_Planned_Dates__c ) {
                        currentServiceItem.Planned_Start_Date__c = currentServiceItem.Expected_Start_Date__c;
                        currentServiceItem.Planned_End_Date__c = currentServiceItem.Expected_End_Date__c;
                    }
                }
            }
        } catch ( Exception ex ){
            throw new ErrorException( ex.getMessage() + ' on the Service Item [' + currentServiceItem.Name + ']');
        }
        return serviceIdDoNotUpdate;
    }

    public static String getTotalDurationForServiceMi3( Map<Integer, Task_Item__c> orderedListOfTasks, Id taskItemIdStartFrom, Boolean fromDateCalculation ) {
        List<Task_Item__c> successorsForCurrentTask;
        Set<Id> tempSetOfSuccessors;
        Set<Id> outstandingSuccessorsForCurrentTask = new Set<Id>();

        expectedStartDateForEditedTask = null;
        String serviceDuration = TIME_DURATION_PATTERN;
        String terminatedTaskDurationSum = TIME_DURATION_PATTERN;

        List<Integer> ranksList = new List<Integer>();
        ranksList.addAll( orderedListOfTasks.keySet() );
        ranksList.sort();

        for( Integer sequenceNumber : ranksList ) {
            Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );
            
            if( outstandingSuccessorsForCurrentTask.contains( taskItem.Id ) ) {
                continue;
            }
            if( fromDateCalculation && taskItem.Actual_End_Date__c != null && taskItem.Name.contains('(TERMINATED)') ) {
                terminatedTaskDurationSum = DateUtils.appendDurations( terminatedTaskDurationSum, taskItem.Expected_Duration__c );
                continue;
            }

            String currentDurrationSum = taskItem.Expected_Duration__c;

            currentDurrationSum = DateUtils.appendDurations( currentDurrationSum, taskItem.Delay_End_Date__c );
            serviceDuration = DateUtils.appendDurations( serviceDuration, currentDurrationSum );
            if( taskItem.Id == taskItemIdStartFrom || 
                ( fromDateCalculation && expectedStartDateForEditedTask == null ) /* First uncompleted task after terminated */) {

                expectedStartDateForEditedTask = DateUtils.getDatetimeWithTimeShiftByBusinessHours ( taskItem.Project_Profile__r.Project_Start_Date__c, null );

                Task_Item__c predecessorTask = orderedListOfTasks.get( Integer.valueOf( taskItem.Sequence_Number__c - 1 ) );
                Datetime predecessorEndDate = DateTime.newInstance( predecessorTask.Expected_End_Date__c.year(), 
                                                                    predecessorTask.Expected_End_Date__c.month(), 
                                                                    predecessorTask.Expected_End_Date__c.day(), 
                                                                    17, 0, 0 );
                String newDuration = DateUtils.getDifferenceBetweanTwoDatetimes( predecessorEndDate,
                                                                                 expectedStartDateForEditedTask, true );

                serviceDuration = DateUtils.appendDurations( serviceDuration, newDuration );
            }

            successorsForCurrentTask = collectAllSuccessorsForTaskItem( taskItem.Id );
            if( successorsForCurrentTask.size() > 1 ) {
                for( Task_Item__c someTask : successorsForCurrentTask ) {
                    Id endpointTaskId = someTask.Successor_Task__c;
                    if( endpointTaskId != null ) {
                        for( Task_Item__c slaveTask : successorsForCurrentTask ) {
                            if( someTask.Id != slaveTask.Id ) {
                                String sequenceDuration = slaveTask.Expected_Duration__c;

                                if( slaveTask.Delay_End_Date__c != null ) {
                                    sequenceDuration = DateUtils.appendDurations( sequenceDuration, slaveTask.Delay_End_Date__c );
                                }

                                Boolean noSequence = false;
                                Id successorIdForSuccessor = slaveTask.Successor_Task__c;
                                tempSetOfSuccessors = new Set<Id> ();
                                while( successorIdForSuccessor != endpointTaskId && !noSequence ) {
                                    tempSetOfSuccessors.add( successorIdForSuccessor );

                                    sequenceDuration = DateUtils.appendDurations( sequenceDuration, taskIdToTask.get( successorIdForSuccessor ).Expected_Duration__c );

                                    if( taskIdToTask.get( successorIdForSuccessor ).Delay_End_Date__c != null ) {
                                        sequenceDuration = DateUtils.appendDurations( sequenceDuration, taskIdToTask.get( successorIdForSuccessor ).Delay_End_Date__c );
                                    }

                                    successorIdForSuccessor = taskIdToTask.get( successorIdForSuccessor ).Successor_Task__c;
                                    noSequence = ( taskIdToTask.get( successorIdForSuccessor ).Successor_Task__c == null );
                                }

                                if( noSequence ) {
                                    if( DateUtils.getMinute(currentDurrationSum) < DateUtils.getMinute(slaveTask.Expected_Duration__c) ) {
                                        currentDurrationSum = slaveTask.Expected_Duration__c;
                                    }
                                } else {
                                    if( DateUtils.getMinute(currentDurrationSum) < DateUtils.getMinute(sequenceDuration) ) {
                                        currentDurrationSum = sequenceDuration;
                                        outstandingSuccessorsForCurrentTask.addAll( tempSetOfSuccessors );
                                    }
                                }
                            }
                            outstandingSuccessorsForCurrentTask.add( slaveTask.Id );
                        }
                    }
                }
                serviceDuration = DateUtils.appendDurations( serviceDuration, currentDurrationSum );
            }
        }
        serviceDuration = DateUtils.appendDurations( serviceDuration, terminatedTaskDurationSum );
        return serviceDuration;
    }

    public static String getTotalDurationForService( Map<Integer, Task_Item__c> orderedListOfTasks, Id taskItemIdStartFrom ) {
        List<Task_Item__c> successorsForCurrentTask;
        Set<Id> tempSetOfSuccessors;
        Set<Id> outstandingSuccessorsForCurrentTask = new Set<Id>();

        expectedStartDateForEditedTask = null;
        String serviceDuration = TIME_DURATION_PATTERN;

        List<Integer> ranksList = new List<Integer>();
        ranksList.addAll( orderedListOfTasks.keySet() );
        ranksList.sort();

        Datetime tmpDatetime;
        for( Integer sequenceNumber : ranksList ) {
            Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );
            if( outstandingSuccessorsForCurrentTask.contains( taskItem.Id ) ) {
                continue;
            }
System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices sequenceNumber = ' + sequenceNumber);
            String currentDurrationSum = taskItem.Expected_Duration__c;

            currentDurrationSum = DateUtils.appendDurations( currentDurrationSum, taskItem.Delay_End_Date__c );

            serviceDuration = DateUtils.appendDurations( serviceDuration, currentDurrationSum );

            if( taskItem.Sequence_Number__c == FIRST_TASK_IN_SEQUENCE ) {
                tmpDatetime = taskItem.Expected_Start_Date__c;
                
                if( taskItem.Id == taskItemIdStartFrom ) {
                    expectedStartDateForEditedTask = tmpDatetime;
                }
            }

            if( taskItem.Sequence_Number__c > FIRST_TASK_IN_SEQUENCE ) {
                if( taskItem.Id == taskItemIdStartFrom ) {
                    expectedStartDateForEditedTask = tmpDatetime;
                }

                if(taskItem.Predecessor_Task__c != null && TaskManagementServices.taskIdToTask.containsKey( taskItem.Predecessor_Task__c )){
                    Task_Item__c predecessorTask = TaskManagementServices.taskIdToTask.get( taskItem.Predecessor_Task__c );
                    if (taskItem.Actual_Start_Date__c != null && predecessorTask.Expected_End_Date__c != taskItem.Expected_Start_Date__c){
                        String newDuration = DateUtils.getDifferenceBetweanTwoDatetimes( predecessorTask.Expected_End_Date__c,
                                                                                         taskItem.Expected_Start_Date__c, true );
                        if (predecessorTask.Expected_End_Date__c < taskItem.Expected_Start_Date__c){
                            serviceDuration = DateUtils.appendDurations( serviceDuration, newDuration );
                        } else {
                            String s = '';
                            Integer d = 0;
                            Decimal h, m = 0;
                            for (String st : newDuration.split(' ')) {
                                if (st.containsIgnoreCase('d')){
                                    d = Integer.valueOf(st.removeEndIgnoreCase('d'));
                                }
                                if (st.containsIgnoreCase('h')){
                                    h = Decimal.valueOf(st.removeEndIgnoreCase('h'));
                                }
                                if (st.containsIgnoreCase('m')){
                                    m = Decimal.valueOf(st.removeEndIgnoreCase('m'));
                                }
                            }
                            newDuration = String.valueOf(d) + 'd -' + String.valueOf(h) + 'h -' + String.valueOf(m) + 'm';
                            serviceDuration = DateUtils.appendDurations( serviceDuration, newDuration );
                        }
                    }
                }

                successorsForCurrentTask = collectAllSuccessorsForTaskItem( taskItem.Id );
                if( successorsForCurrentTask.size() > 1 ) {
                    for( Task_Item__c someTask : successorsForCurrentTask ) {
                        Id endpointTaskId = someTask.Successor_Task__c;
                        if( endpointTaskId != null ) {
                            for( Task_Item__c slaveTask : successorsForCurrentTask ) {
                                if( someTask.Id != slaveTask.Id ) {
                                    String sequenceDuration = slaveTask.Expected_Duration__c;
                                    if( slaveTask.Delay_End_Date__c != null ) {
                                        sequenceDuration = DateUtils.appendDurations( sequenceDuration, slaveTask.Delay_End_Date__c );
                                    }
                                    Id successorIdForSuccessor = slaveTask.Successor_Task__c;
                                    Boolean noSequence = ( successorIdForSuccessor == null );
                                    tempSetOfSuccessors = new Set<Id> ();
                                    while( successorIdForSuccessor != endpointTaskId && !noSequence ) {
                                        tempSetOfSuccessors.add( successorIdForSuccessor );

                                        sequenceDuration = DateUtils.appendDurations( sequenceDuration, taskIdToTask.get( successorIdForSuccessor ).Expected_Duration__c );

                                        if( taskIdToTask.get( successorIdForSuccessor ).Delay_End_Date__c != null ) {
                                            sequenceDuration = DateUtils.appendDurations( sequenceDuration, taskIdToTask.get( successorIdForSuccessor ).Delay_End_Date__c );
                                        }

                                        successorIdForSuccessor = taskIdToTask.get( successorIdForSuccessor ).Successor_Task__c;
                                        noSequence = ( !taskIdToTask.containsKey( successorIdForSuccessor ) || taskIdToTask.get( successorIdForSuccessor ).Successor_Task__c == null );
                                    }
                                    
                                    if( noSequence ) {
                                        if( DateUtils.getMinute( currentDurrationSum ) < DateUtils.getMinute( slaveTask.Expected_Duration__c ) ) {
                                            currentDurrationSum = slaveTask.Expected_Duration__c;
                                        }
                                    } else {
                                        if( DateUtils.getMinute(currentDurrationSum) < DateUtils.getMinute(sequenceDuration) ) {
                                            currentDurrationSum = sequenceDuration;
                                            outstandingSuccessorsForCurrentTask.addAll( tempSetOfSuccessors );
                                        }
                                    }
                                }
                                outstandingSuccessorsForCurrentTask.add( slaveTask.Id );
                            }
                        }
                    }
                    serviceDuration = DateUtils.appendDurations( serviceDuration, currentDurrationSum );
                }
            }
        }
        return serviceDuration;
    }

    // Collect all Successors for current Task
    public static List<Task_Item__c> collectAllSuccessorsForTaskItem( Id taskItemId ) {
        List<Task_Item__c> successorsForCurrentTask = new List<Task_Item__c>();
        if( taskIdWithSuccessors.containsKey( taskItemId ) ) {
            for ( Id successorId : taskIdWithSuccessors.get( taskItemId ) ) {
                Task_Item__c succesTask = taskIdToTask.get( successorId );
                if( succesTask != null ) {
                    if( taskIdWithPredecessors.containsKey( succesTask.Id ) ) {
                        for ( Id predecessorId : taskIdWithPredecessors.get( succesTask.Id ) ) {
                            Task_Item__c predTask = taskIdToTask.get( predecessorId );
                            if( predTask != null ) {
                                if( predTask.Id == taskItemId ) {
                                    successorsForCurrentTask.add( succesTask );
                                }
                            }
                        }
                    }
                }
            }
        }
        return successorsForCurrentTask;
    }

    public static void calculatePlannedExpectedDatesForServices( Map<Id, Service_Item__c> serviceItemMap, Id serviceIdDoNotUpdate, Id processingTaskItemId ) {
        Map<String, List<Service_Item__c>> predecessorMilestoneForServices = new Map<String, List<Service_Item__c>>();
        Map<String, List<Service_Item__c>> successorMilestoneForServices = new Map<String, List<Service_Item__c>>();
        List<Service_Item__c> startProjectServices = new List<Service_Item__c>();
        
        Map<String, Map<String, List<Service_Item__c>> > predecessorSuccessorSortedServiceItmList = new Map<String, Map<String, List<Service_Item__c>> >();
        
        Datetime currentEndDate;
        String projectStartMilestone;

        // Set Successor/Predecessor Milestone for Service block
        for( Id serviceId : serviceItemMap.keySet() ) {
            Service_Item__c serviceItem = serviceItemMap.get( serviceId );
System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices serviceItem.Name = ' + serviceItem.Name);
            // Clean up Dates for new recalculation
            if( serviceId != serviceIdDoNotUpdate &
                ( serviceItem.Actual_Start_Date__c == null || serviceItem.Actual_Start_Date_Is_From_Terminator__c ) ) {
                if( !serviceItem.Actual_Start_Date_Is_From_Terminator__c ) serviceItem.Expected_Start_Date__c = null;
                serviceItem.Expected_End_Date__c = null;
            }
            
            if( !TaskManagementServices.seqNumberToTaskItemForService.containsKey( serviceId ) ||
                 TaskManagementServices.seqNumberToTaskItemForService.get( serviceId ).isEmpty() ) continue;
            
            Map<Integer, Task_Item__c> tasksForService = TaskManagementServices.seqNumberToTaskItemForService.get( serviceId );

            if( tasksForService.isEmpty() && tasksForService.get(1) != null ) continue;
            if( tasksForService.get(1).Predecessor_Milestone_from_Template__c == null ) {
                generateErrorMessage( 'Predecessor Milestone is not defined for ' + serviceItem.Name + ' Service', processingTaskItemId );
            }
            if( tasksForService.get( tasksForService.size()).Successor_Milestone_from_Template__c == null ) {
                generateErrorMessage( 'Successor Milestone is not defined for ' + serviceItem.Name + ' Service', processingTaskItemId );
            }

            if( serviceIdDoNotUpdate == null ) {
                // Get first task in row with Predecessor (Predecessor should be there)
                if( serviceItem.Predecessor_Milestone__c == null ) {
                    serviceItem.Predecessor_Milestone__c = tasksForService.get(1).Predecessor_Milestone_from_Template__c;
                }
                // Get last task in row with Successor (Successor should be there)
                if( serviceItem.Successor_Milestone__c == null ) {
                    serviceItem.Successor_Milestone__c = tasksForService.get( tasksForService.size() ).Successor_Milestone_from_Template__c;
                }
            }

            // Get milestones depended from Services
            if( !successorMilestoneForServices.containsKey( serviceItem.Successor_Milestone__c ) ) {
                successorMilestoneForServices.put( serviceItem.Successor_Milestone__c, new List<Service_Item__c>() );
            }
            successorMilestoneForServices.get( serviceItem.Successor_Milestone__c ).add( serviceItem );

            if( !predecessorMilestoneForServices.containsKey( serviceItem.Predecessor_Milestone__c ) ) {
                predecessorMilestoneForServices.put( serviceItem.Predecessor_Milestone__c, new List<Service_Item__c>() );
            }
            predecessorMilestoneForServices.get( serviceItem.Predecessor_Milestone__c ).add( serviceItem );
            // PROJECT START MILESTONE: Calculate Dates for Project Start Services
            if( serviceItem.Predecessor_Milestone__c.contains( TaskManagementServices.MILESTONE_PROJECT_START ) ) {
                if( projectStartMilestone != null && projectStartMilestone != serviceItem.Predecessor_Milestone__c ) {
                    generateErrorMessage( 'Please specify only one Project Start Predecessor Milestone (Milestone that contains the "Project Start" text should be one)', processingTaskItemId );
                }
                projectStartMilestone = serviceItem.Predecessor_Milestone__c;
                if( serviceId != serviceIdDoNotUpdate ) {
                    if( serviceItem.Actual_Start_Date__c == null  || serviceItem.Actual_Start_Date_Is_From_Terminator__c ) {
                        if( !serviceItem.Actual_Start_Date_Is_From_Terminator__c ) {
                            serviceItem.Expected_Start_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours ( serviceItem.Project_Profile__r.Project_Start_Date__c, null );
                        }
                        serviceItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( serviceItem.Expected_Start_Date__c, serviceItem.Expected_Service_Duration__c );
                    }
                }  else {
                    if( tasksForService.get( 1 ).Expected_Start_Date__c != null ) {
                        serviceItem.Expected_Start_Date__c = tasksForService.get( 1 ).Expected_Start_Date__c;
                    }
                    serviceItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( serviceItem.Expected_Start_Date__c, serviceItem.Expected_Service_Duration__c );
                }
                if( currentEndDate == null || currentEndDate < serviceItem.Expected_End_Date__c ) currentEndDate = serviceItem.Expected_End_Date__c;
                if( !serviceItem.Project_Profile__r.Submitted_Planned_Dates__c ) {
                    serviceItem.Planned_Start_Date__c = serviceItem.Expected_Start_Date__c;
                    serviceItem.Planned_End_Date__c = serviceItem.Expected_End_Date__c;
                    serviceItem.Total_Planned_Service_Duration__c = serviceItem.Expected_Service_Duration__c;
                }
                startProjectServices.add( serviceItem );
            }

            if( !predecessorSuccessorSortedServiceItmList.containsKey( serviceItem.Predecessor_Milestone__c ) ){
                predecessorSuccessorSortedServiceItmList.put( serviceItem.Predecessor_Milestone__c, new Map<String, List<Service_Item__c>>() );
            }
            if( !predecessorSuccessorSortedServiceItmList.get( serviceItem.Predecessor_Milestone__c ).containsKey( serviceItem.Successor_Milestone__c ) ){
                predecessorSuccessorSortedServiceItmList.get( serviceItem.Predecessor_Milestone__c ).put( serviceItem.Successor_Milestone__c, new List<Service_Item__c>() );
            }
            
            predecessorSuccessorSortedServiceItmList.get( serviceItem.Predecessor_Milestone__c ).get( serviceItem.Successor_Milestone__c ).add( serviceItem );
        }
        if( projectStartMilestone == null ) {
            generateErrorMessage( 'At least one Service should have Project Start Predecessor Milestone (Milestone that contains "Project Start" text)', processingTaskItemId );
        }
        Map<Datetime, String> theClosestDateForMilestoneMap;

        List<Service_Item__c> currentLevelServices;
        debugLogs( '@@@@@@@@@@@ startProjectServices.size()= ' + startProjectServices.size(), true );
        if( !startProjectServices.isEmpty() ){
            Map<String, List<Service_Item__c>> servicesWithSuccessors = predecessorSuccessorSortedServiceItmList.get( startProjectServices[0].Predecessor_Milestone__c );
            List<String> sortedSuccessors = new List<String>( servicesWithSuccessors.keySet() );
            sortedSuccessors.sort();
            currentLevelServices = new List<Service_Item__c>();

            for( String milestone : sortedSuccessors ) {
                currentLevelServices.addAll( servicesWithSuccessors.get( milestone ) );
            }
        }
        
        debugLogs( '@@@@@@@@@@@ predecessorSuccessorSortedServiceItmList = ' + predecessorSuccessorSortedServiceItmList, true );
                
        if( currentLevelServices != null && !currentLevelServices.isEmpty() ){
            debugLogs( '@@@@@@@@@@@ currentLevelServices: LEVEL = ' + currentLevelServices[0].Predecessor_Milestone__c, true );
            debugLogs( '@@@@@@@@@@@ currentLevelServices.size() = ' + currentLevelServices.size(), true );
            for( Service_Item__c si : currentLevelServices ){
                debugLogs( '@@@@@@@@@@@ si.Name = ' + si.Name, true );
            }
            debugLogs( '@@@@@@@@@@@ =============================', true );
        } else {
            debugLogs( '@@@@@@@@@@@ currentLevelServices is EMPTY!', true );
        }
       
        while( currentLevelServices != null ) {
            theClosestDateForMilestoneMap = new Map<Datetime, String>();
            Boolean noMoreSuccessors = true;
            for( Service_Item__c predecessorService : currentLevelServices ) {
                debugLogs( '@@@@@@@@@@@ ********predecessorService = ' + predecessorService.Name, true );
                Datetime longestDate;
                Service_Item__c firstMilestoneService;
                Boolean allProcessed = true;
                List<Service_Item__c> successorTasksForCurrent = predecessorMilestoneForServices.get( predecessorService.Successor_Milestone__c );
                debugLogs( '@@@@@@@@@@@ ********successorTasksForCurrent = ' + successorTasksForCurrent, true );
                if( successorTasksForCurrent != null ){
                    noMoreSuccessors = false;
                } else {
                    continue;
                }

                for ( Service_Item__c nextAfterCurrentService : successorTasksForCurrent ) {
                    debugLogs( '@@@@@@@@@@@ ******** ++++++++++++++ nextAfterCurrentService = ' + nextAfterCurrentService.Name, true );
                    debugLogs( '@@@@@@@@@@@ ******** ++++++++++++++ 1) nextAfterCurrentService.Expected_Start_Date__c = ' + nextAfterCurrentService.Expected_Start_Date__c, true );
                    if( firstMilestoneService == null ){
                        firstMilestoneService = nextAfterCurrentService;
                        if( nextAfterCurrentService.Expected_Start_Date__c != null && 
                            ( nextAfterCurrentService.Actual_Start_Date__c == null ) &&
                            nextAfterCurrentService.Id != serviceIdDoNotUpdate ) {
                            
                            theClosestDateForMilestoneMap.put( nextAfterCurrentService.Expected_Start_Date__c, nextAfterCurrentService.Predecessor_Milestone__c );
                            continue; // Already calculated
                        }

                        debugLogs( '@@@@@@@@@@@ ++++++++++++++ successorMilestoneForServices.get( nextAfterCurrentService.Predecessor_Milestone__c ) = ' + successorMilestoneForServices.get( nextAfterCurrentService.Predecessor_Milestone__c ), true );
                        for( Service_Item__c predForNextAfterCurrentService : successorMilestoneForServices.get( nextAfterCurrentService.Predecessor_Milestone__c ) ) {
                            debugLogs( '@@@@@@@@@@@ ******** ++++++++++++++ ======== predForNextAfterCurrentService = ' + predForNextAfterCurrentService.Name, true );
                            debugLogs( '@@@@@@@@@@@ ******** ++++++++++++++ ======== predForNextAfterCurrentService.Expected_Start_Date__c = ' + predForNextAfterCurrentService.Expected_Start_Date__c, true );
                            if( predForNextAfterCurrentService.Expected_Start_Date__c == null ) {
                                allProcessed = false;
                                break;
                            }
                            if( nextAfterCurrentService.Predecessor_Milestone__c.equals( predForNextAfterCurrentService.Successor_Milestone__c ) ) {
                                longestDate = ( ( longestDate == null || longestDate < predForNextAfterCurrentService.Expected_End_Date__c )
                                                        ? predForNextAfterCurrentService.Expected_End_Date__c
                                                        : longestDate );
                            }
                        }
                        debugLogs( '@@@@@@@@@@@ ++++++++++++++ allProcessed = ' + allProcessed, true );
                        debugLogs( '@@@@@@@@@@@ ++++++++++++++ longestDate = ' + longestDate, true );
                        if( !allProcessed ) continue;

                        if( nextAfterCurrentService.Id != serviceIdDoNotUpdate ) {
                            if( nextAfterCurrentService.Actual_Start_Date__c == null || nextAfterCurrentService.Actual_Start_Date_Is_From_Terminator__c ) {
                                if( !nextAfterCurrentService.Actual_Start_Date_Is_From_Terminator__c ){
                                    nextAfterCurrentService.Expected_Start_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours ( longestDate, null );
                                }
                                nextAfterCurrentService.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( nextAfterCurrentService.Expected_Start_Date__c, nextAfterCurrentService.Expected_Service_Duration__c );   
                            }
                        }
debugLogs( '@@@@@@@@@@@ 1) firstMilestoneService.Expected_Start_Date__c = ' + firstMilestoneService.Expected_Start_Date__c, true );
                    } else {
                        if( nextAfterCurrentService.Id != serviceIdDoNotUpdate ) {
                            if( nextAfterCurrentService.Actual_Start_Date__c == null || nextAfterCurrentService.Actual_Start_Date_Is_From_Terminator__c ) {
                                if( !nextAfterCurrentService.Actual_Start_Date_Is_From_Terminator__c ){
debugLogs( '@@@@@@@@@@@ 2) firstMilestoneService.Expected_Start_Date__c = ' + firstMilestoneService.Expected_Start_Date__c, true );
                                    nextAfterCurrentService.Expected_Start_Date__c = firstMilestoneService.Expected_Start_Date__c;
                                }
                                nextAfterCurrentService.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( nextAfterCurrentService.Expected_Start_Date__c, nextAfterCurrentService.Expected_Service_Duration__c );   
                            }
                        }
                    }

                    debugLogs( '@@@@@@@@@@@ ++++++++++++++ 2) nextAfterCurrentService.Expected_Start_Date__c = ' + nextAfterCurrentService.Expected_Start_Date__c, true );
                    if( !nextAfterCurrentService.Project_Profile__r.Submitted_Planned_Dates__c ) {
                        nextAfterCurrentService.Planned_Start_Date__c = nextAfterCurrentService.Expected_Start_Date__c;
                        nextAfterCurrentService.Planned_End_Date__c = nextAfterCurrentService.Expected_End_Date__c;
                        nextAfterCurrentService.Total_Planned_Service_Duration__c = nextAfterCurrentService.Expected_Service_Duration__c;
                    }
debugLogs( '@@@@@@@@@@@ nextAfterCurrentService.Expected_Start_Date__c = ' + nextAfterCurrentService.Expected_Start_Date__c + ' nextAfterCurrentService.Predecessor_Milestone__c = ' + String.valueOf(nextAfterCurrentService.Predecessor_Milestone__c), true );
                    theClosestDateForMilestoneMap.put( nextAfterCurrentService.Expected_Start_Date__c, nextAfterCurrentService.Predecessor_Milestone__c );
                }
            }
for (DateTime dt : theClosestDateForMilestoneMap.keySet()){
    debugLogs( '@@@@@@@@@@@ theClosestDateForMilestoneMap.get(dt) = ' + theClosestDateForMilestoneMap.get(dt) + ' dt = ' + String.valueOf(dt), true );
}
            debugLogs( '@@@@@@@@@@@ noMoreSuccessors = ' + noMoreSuccessors, true );
            if( noMoreSuccessors ) break;
            currentLevelServices = null;
            debugLogs( '@@@@@@@@@@@ theClosestDateForMilestoneMap = ' + theClosestDateForMilestoneMap, true );
            if( !theClosestDateForMilestoneMap.isEmpty() ) {
                List<Datetime> sortList = new List<Datetime>();
                sortList.addAll( new List<Datetime>( theClosestDateForMilestoneMap.keySet() ) );
                sortList.sort();

                String calculatedMilestone = theClosestDateForMilestoneMap.get(sortList.get(0)); // Get most closest Milestone
                debugLogs( '@@@@@@@@@@@ calculatedMilestone = ' + calculatedMilestone, true );
                currentLevelServices = predecessorMilestoneForServices.get( calculatedMilestone );
            }
            debugLogs( '@@@@@@@@@@@ currentLevelServices = ' + currentLevelServices, true );
        }

        // Update Service Expected dates
        if( serviceIdDoNotUpdate != null ) {
            Map<Integer, Task_Item__c> tasksForService = TaskManagementServices.seqNumberToTaskItemForService.get( serviceIdDoNotUpdate );
            if( tasksForService.get( 1 ).Expected_Start_Date__c != null ) {
                serviceItemMap.get( serviceIdDoNotUpdate ).Expected_Start_Date__c = tasksForService.get( 1 ).Expected_Start_Date__c;
                serviceItemMap.get( serviceIdDoNotUpdate ).Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( serviceItemMap.get( serviceIdDoNotUpdate ).Expected_Start_Date__c,
                                                                                                                                     serviceItemMap.get( serviceIdDoNotUpdate ).Expected_Service_Duration__c );
            }
        }
    }

    public static void calculatePlannedDatesForTasks( Map<Id, Service_Item__c> incomingServiceItems, Id taskIdDoNotUpdate, Id taskItemIdStartFrom ) {
        calculatePlannedDatesForTasks( incomingServiceItems, taskIdDoNotUpdate, taskItemIdStartFrom, false );
    }

    public static void calculatePlannedDatesForTasks( Map<Id, Service_Item__c> incomingServiceItems, Id taskIdDoNotUpdate, Id taskItemIdStartFrom, Boolean cameFromDateCalculation ) {
        Map<Integer, Task_Item__c> orderedListOfTasks;
        Map<Id, Task_Item__c> milestonePredecessorsToUpdate = new Map<Id, Task_Item__c>();
        Map<Id, Task_Item__c> milestoneSuccessorsToUpdate = new Map<Id, Task_Item__c>();
        Map<Id, Datetime> milestoneSuccessorsToPlannedDatetime = new Map<Id, Datetime>();
        Map<Id, Datetime> milestoneSuccessorsToExpectedDatetime = new Map<Id, Datetime>();
        Datetime prevTaskPlannedEndDate;
        
        for( Id serviceId : seqNumberToTaskItemForService.keySet() ) {
            // Get ordered (by sequence number) list of Tasks for appropriate Service
            orderedListOfTasks = seqNumberToTaskItemForService.get( serviceId );
            List<Integer> ranksList = new List<Integer>();
            ranksList.addAll( orderedListOfTasks.keySet() );
            ranksList.sort();
System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices serviceId = ' + serviceId +' TaskManagementServices serviceId = ' + incomingServiceItems.get( serviceId ).Name + ' SI.Expected_Start_Date__c = ' + incomingServiceItems.get( serviceId ).Expected_Start_Date__c);
            Task_Item__c lastTerminatedTask;
            for( Integer sequenceNumber : ranksList ) {
                Task_Item__c taskItem = orderedListOfTasks.get( sequenceNumber );

                if( incomingServiceItems.get( taskItem.Service_Item__c ).Actual_Start_Date_Is_From_Terminator__c && 
                    taskItem.Actual_End_Date__c != null && 
                    taskItem.Name.contains('(TERMINATED)') ) {
                        lastTerminatedTask = taskItem;
                        continue;
                }
System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices sequenceNumber = ' + sequenceNumber + ' Id = ' + taskItem.Id);
                // TASK TERMINATOR CASE
                if( cameFromDateCalculation && 
                    incomingServiceItems.get( taskItem.Service_Item__c ).Actual_Start_Date_Is_From_Terminator__c &&
                    taskItem.Predecessor_Task__c == lastTerminatedTask.Id ) {
                        if( taskItem.Actual_Start_Date__c == null ) {
                            taskItem.Expected_Start_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours ( taskItem.Project_Profile__r.Project_Start_Date__c, null );
                        }
                } else { // NORMAL CASE
                    if( taskItem.Sequence_Number__c == FIRST_TASK_IN_SEQUENCE ) { // First Task in Task row
                        if( taskItem.Actual_Start_Date__c == null && taskItem.Id != taskItemIdStartFrom ) {
                            taskItem.Expected_Start_Date__c = incomingServiceItems.get( taskItem.Service_Item__c ).Expected_Start_Date__c;
                        }
                    } else {
                        if( test.isRunningTest() ) {
                            prevTaskPlannedEndDate = Datetime.now();
                        } else {
                            if( taskIdWithPredecessors.containsKey( taskItem.Id ) ) {  // Check if current task has Predecessors
                                System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices Check if current task has Predecessors sequenceNumber = ' + sequenceNumber);
                                prevTaskPlannedEndDate = findLongestDateForTask( taskIdWithPredecessors.get( taskItem.Id ), incomingServiceItems.get( serviceId ).Name, taskIdDoNotUpdate );
                            } else if ( taskIdWithSuccessors.containsKey( taskItem.Id ) ) { // Task w/o Predecessors but maybe with Successors
                                System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices Task w/o Predecessors but maybe with Successors sequenceNumber = ' + sequenceNumber);
                                prevTaskPlannedEndDate = findLongestDateForTask( taskIdWithSuccessors.get( taskItem.Id ), incomingServiceItems.get( serviceId ).Name, taskIdDoNotUpdate );
                            }
                        }

                        if( prevTaskPlannedEndDate == null ) {System.Debug(LoggingLevel.ERROR, '^^^ TaskManagementServices prevTaskPlannedEndDate == null sequenceNumber = ' + sequenceNumber);
                            generateErrorMessage( 'Expected Start Date cannot be calculated for Task in [' + incomingServiceItems.get( serviceId ).Name + ']' + ' Service. Check Services that are predecessors for current Service.', taskIdDoNotUpdate);
                        }
                        if( taskItem.Actual_Start_Date__c == null && taskItem.Id != taskItemIdStartFrom ) {
                            taskItem.Expected_Start_Date__c = prevTaskPlannedEndDate;
                        }
                    }
                }

                if( taskItem.Actual_End_Date__c == null ) {
                    taskItem.Expected_End_Date__c = DateUtils.getDatetimeWithTimeShiftByBusinessHours( taskItem.Expected_Start_Date__c, taskItem.Expected_Duration__c );
                }
                prevTaskPlannedEndDate = taskItem.Expected_End_Date__c;

                if( taskItem.Delay_End_Date__c != null) {
                    prevTaskPlannedEndDate = DateUtils.getDatetimeWithTimeShiftByBusinessHours( prevTaskPlannedEndDate, taskItem.Delay_End_Date__c );
                }

                if( !taskItem.Project_Profile__r.Submitted_Planned_Dates__c ) {
                    taskItem.Planned_Start_Date__c = taskItem.Expected_Start_Date__c;
                    taskItem.Planned_End_Date__c = taskItem.Expected_End_Date__c;
                    taskItem.Planned_Durration__c = taskItem.Expected_Duration__c;
                }

                // Prepare Predecessor Milestones for Services
                if( taskItem.Predecessor_Milestone__c != null ) {
                    if( !milestonePredecessorsToUpdate.containsKey( taskItem.Predecessor_Milestone__c ) ) {
                        milestonePredecessorsToUpdate.put( taskItem.Predecessor_Milestone__c, new Task_Item__c( Id = taskItem.Predecessor_Milestone__c,
                                                                                                                Planned_Start_Date__c = taskItem.Planned_Start_Date__c,
                                                                                                                Expected_Start_Date__c = taskItem.Expected_Start_Date__c ) );
                    } else{
                        if( milestonePredecessorsToUpdate.get( taskItem.Predecessor_Milestone__c ).Planned_Start_Date__c > taskItem.Planned_Start_Date__c ) {
                            milestonePredecessorsToUpdate.get( taskItem.Predecessor_Milestone__c ).Planned_Start_Date__c = taskItem.Planned_Start_Date__c;
                        }
                        if( milestonePredecessorsToUpdate.get( taskItem.Predecessor_Milestone__c ).Expected_Start_Date__c > taskItem.Expected_Start_Date__c ) {
                            milestonePredecessorsToUpdate.get( taskItem.Predecessor_Milestone__c ).Expected_Start_Date__c = taskItem.Expected_Start_Date__c;
                        }
                    }
                }
                // Prepare Successor Milestones for Services
                if ( taskItem.Successor_Milestone__c != null ) {
                    Service_Item__c servItem = incomingServiceItems.get( taskItem.Service_Item__c );
                    if( !milestoneSuccessorsToPlannedDatetime.containsKey( taskItem.Successor_Milestone__c ) ||
                        milestoneSuccessorsToPlannedDatetime.get( taskItem.Successor_Milestone__c ) < servItem.Planned_End_Date__c ) {
                        milestoneSuccessorsToPlannedDatetime.put( taskItem.Successor_Milestone__c, servItem.Planned_End_Date__c );
                    }
                    if( !milestoneSuccessorsToExpectedDatetime.containsKey( taskItem.Successor_Milestone__c ) ||
                        milestoneSuccessorsToExpectedDatetime.get( taskItem.Successor_Milestone__c ) < servItem.Expected_End_Date__c ) {
                        milestoneSuccessorsToExpectedDatetime.put( taskItem.Successor_Milestone__c, servItem.Expected_End_Date__c );
                    }

                    if( !milestoneSuccessorsToUpdate.containsKey( taskItem.Successor_Milestone__c ) ) {
                        milestoneSuccessorsToUpdate.put( taskItem.Successor_Milestone__c, new Task_Item__c( Id = taskItem.Successor_Milestone__c ) );
                    }

                    if( incomingServiceItems.get( serviceId ).Actual_Start_Date_Is_From_Terminator__c ) {
                        incomingServiceItems.get( serviceId ).Expected_End_Date__c = taskItem.Expected_End_Date__c;

                        incomingServiceItems.get( serviceId ).Expected_Service_Duration__c = DateUtils.getDifferenceBetweanTwoDatetimes(
                                                                                        incomingServiceItems.get( serviceId ).Expected_Start_Date__c, 
                                                                                        incomingServiceItems.get( serviceId ).Expected_End_Date__c, !cameFromDateCalculation);
                        if( !incomingServiceItems.get( serviceId ).Project_Profile__r.Submitted_Planned_Dates__c ) {
                            incomingServiceItems.get( serviceId ).Planned_Start_Date__c = incomingServiceItems.get( serviceId ).Expected_Start_Date__c;
                            incomingServiceItems.get( serviceId ).Planned_End_Date__c = incomingServiceItems.get( serviceId ).Expected_End_Date__c;
                            incomingServiceItems.get( serviceId ).Total_Planned_Service_Duration__c = incomingServiceItems.get( serviceId ).Expected_Service_Duration__c;
                        }
                    }
                }
            }
            Service_Item__c si = incomingServiceItems.get( serviceId );
            si.Expected_Start_Date__c = null;
            si.Expected_End_Date__c = null;
            Boolean doRecalculate = false;
            for (Task_Item__c ti : orderedListOfTasks.values()){
                if (ti.Expected_End_Date__c != null && (si.Expected_End_Date__c == null || si.Expected_End_Date__c < ti.Expected_End_Date__c)){
                    si.Expected_End_Date__c = ti.Expected_End_Date__c;
                    doRecalculate = true;
                }
                if (ti.Expected_Start_Date__c != null && (si.Expected_Start_Date__c == null || si.Expected_Start_Date__c > ti.Expected_Start_Date__c)){
                    si.Expected_Start_Date__c = ti.Expected_Start_Date__c;
                    doRecalculate = true;
                }
            }
            if (doRecalculate){si.Expected_Service_Duration__c = DateUtils.getDifferenceBetweanTwoDatetimes(si.Expected_Start_Date__c, si.Expected_End_Date__c, true);}
        }
        for( Id milId : milestoneSuccessorsToUpdate.keySet() ) {
            if( milestonePredecessorsToUpdate.containsKey( milId ) ) {
                milestoneSuccessorsToUpdate.remove( milId );
            } else {
                Task_Item__c mil = milestoneSuccessorsToUpdate.get( milId );
                mil.Planned_Start_Date__c = milestoneSuccessorsToPlannedDatetime.get( mil.Id );
                mil.Expected_Start_Date__c = milestoneSuccessorsToExpectedDatetime.get( mil.Id );
            }
        }
        List<Task_Item__c> tasksToInsert = new List<Task_Item__c>();
        for( Id serviceId : seqNumberToTaskItemForService.keySet() ) {
            for(Task_Item__c ti : seqNumberToTaskItemForService.get( serviceId ).values() ) {
                if( ti.Id != taskIdDoNotUpdate && !ti.Name.contains('(TERMINATED)') ) {
                    tasksToInsert.add( ti );
                }
            }
        }
        tasksToInsert.addAll( milestonePredecessorsToUpdate.values() );
        tasksToInsert.addAll( milestoneSuccessorsToUpdate.values() );
        
        try{
            update tasksToInsert;
        } catch (Exception ex ) {
            generateErrorMessage( ex.getMessage(), taskIdDoNotUpdate);
        }
    }
    
    public static Datetime findLongestDateForTask( Set<Id> taskSet, String serviceName, Id processingTaskItemId ) {
        Datetime prevTaskPlannedEndDate;
        String delayForLongestTask = null;
        for( Id taskId : taskSet ) { // Run through all Predecessors/Successors for current Task
            if( taskId == null ) {
                generateErrorMessage( 'Task Predecessors/Successor is not defined for Task in [' + serviceName + ']' + ' Service', processingTaskItemId );
            }
            if( prevTaskPlannedEndDate == null ||
               ( taskIdToTask.get( taskId ).Actual_Start_Date__c == null &&
                 prevTaskPlannedEndDate < taskIdToTask.get( taskId ).Expected_End_Date__c ) ) {
				System.debug(LoggingLevel.ERROR, '### prevTaskPlannedEndDate = ' + prevTaskPlannedEndDate);
				System.debug(LoggingLevel.ERROR, '### taskIdToTask.get( taskId ).Actual_Start_Date__c = ' + taskIdToTask.get( taskId ).Actual_Start_Date__c);
                System.debug(LoggingLevel.ERROR, '### taskIdToTask.get( taskId ).Expected_End_Date__c = ' + taskIdToTask.get( taskId ).Expected_End_Date__c);
				prevTaskPlannedEndDate = taskIdToTask.get( taskId ).Expected_End_Date__c;
                delayForLongestTask = taskIdToTask.get( taskId ).Delay_End_Date__c;
            }
        }

        if( prevTaskPlannedEndDate != null ) {
            // Add Delay if Task has defined Loop
            if( delayForLongestTask != null ) {
                prevTaskPlannedEndDate = DateUtils.getDatetimeWithTimeShiftByBusinessHours( prevTaskPlannedEndDate, delayForLongestTask );
            }
        } else {
            system.debug(LoggingLevel.ERROR, 'HERE-2!!!!!!!!!!!!');
            generateErrorMessage(  '[' + serviceName + '] Service cannot be processed. Maybe some of the Milestones are missing. Please recheck and finish setting up Milestones', processingTaskItemId );
        }
        return prevTaskPlannedEndDate;
    }
    
    private static void generateErrorMessage( String errorText, Id recordId ){
        if( Trigger.isExecuting ){
            Trigger.newMap.get( recordId ).addError( errorText );
        } else {
            throw new MilestoneException( errorText  );
        }
    }

    //Custom Exception Class (control what error message gets displayed)
    public class MilestoneException extends Exception {}
}