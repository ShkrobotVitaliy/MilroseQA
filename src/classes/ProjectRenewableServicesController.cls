public with sharing class ProjectRenewableServicesController{
    private final Project_Profile__c project;
    private Map<Id, Service_Item__c> serviceItemsMap;
    private Map<String, RenewableServicesHistoryModel> renewableHistoryMap;
    private String ACTIVATION_DATE = 'Activation Date';
    private String EXPIRATION_DATE = 'Expiration Date';
    private String RENEWAL_DATE = 'Renewal Date';
    public List<String> municipalIdRow {get; set;}
    public List<String> typeRow {get; set;}
    public List<String> workTypeRow {get; set;}
    public Map<Integer, List<String>> tableRowsMap {get; set;}

    public ProjectRenewableServicesController(ApexPages.StandardController controller) {
        project = (Project_Profile__c)controller.getRecord();
        serviceItemsMap = new Map<Id, Service_Item__c>([SELECT Id, Type__c, Municipal_Agency_ID__c, Work_Type__c,
                                                               ( SELECT Id, Activation_Date__c, Expiration_Date__c, CreatedDate
                                                                 FROM Task_Items__r
                                                                 WHERE Name =: TaskItemServices.PICKUP_ANALIZE_TASK_NAME AND
                                                                       Activation_Date__c != null AND
                                                                       Expiration_Date__c != null
                                                                 ORDER BY CreatedDate ASC, Activation_Date__c ASC )
                                                        FROM Service_Item__c
                                                        WHERE Project_Profile__c =: project.Id AND
                                                              ( Issuance__c =: ServiceItemServices.SERVICE_ISSUANCE_RENEWAL OR
                                                                Issuance__c =: ServiceItemServices.SERVICE_ISSUANCE_RENEWABLE_SERVICE )
                                                        ORDER BY Municipal_Agency_ID__c]);

        Integer maxHistoryRecordsAmount = 0;
        renewableHistoryMap = new Map<String, RenewableServicesHistoryModel>();
        Task_Item__c renewableTask;
        for( Service_Item__c serviceItem: serviceItemsMap.values() ){
            if( serviceItem.Task_Items__r.isEmpty() ) continue;

            renewableTask = serviceItem.Task_Items__r[0];
            String historyMapKey = serviceItem.Municipal_Agency_ID__c + serviceItem.Type__c + serviceItem.Work_Type__c;
            if( !renewableHistoryMap.containsKey(historyMapKey) ){
                RenewableServicesHistoryModel historyRecord = new RenewableServicesHistoryModel(serviceItem.Municipal_Agency_ID__c, serviceItem.Type__c, serviceItem.Work_Type__c);
                renewableHistoryMap.put( historyMapKey, historyRecord );
            }
            renewableHistoryMap.get(historyMapKey).renewablePeriodsMap.put(renewableTask.Id, new Map<Datetime, Datetime>{renewableTask.Activation_Date__c => renewableTask.Expiration_Date__c});
            if( renewableHistoryMap.get(historyMapKey).renewablePeriodsMap.size() * 2 > maxHistoryRecordsAmount ){
                maxHistoryRecordsAmount = renewableHistoryMap.get(historyMapKey).renewablePeriodsMap.size() * 2;
            }
            renewableHistoryMap.get(historyMapKey).addCreatedDate( renewableTask.CreatedDate, renewableTask.Id ); //MRS-4356 will sort by createddate
        }

        tableRowsMap = new  Map<Integer, List<String>>();
        tableRowsMap.put( 0, new List<String>{ACTIVATION_DATE} );
        tableRowsMap.put( 1, new List<String>{EXPIRATION_DATE} );
        Boolean isOdd = false;
        for ( Integer i = 2; i < maxHistoryRecordsAmount; i++){
            if( isOdd ){
                tableRowsMap.put( i, new List<String>{EXPIRATION_DATE} );
            }else{
                tableRowsMap.put( i, new List<String>{RENEWAL_DATE} );
            }
            isOdd = !isOdd;
        }
        municipalIdRow = new List<String>{'Municipal Agency ID'};
        typeRow = new List<String>{'Service Type'};
        workTypeRow = new List<String>{'Work Type'};
        for( RenewableServicesHistoryModel historyRecord: renewableHistoryMap.values() ){
            municipalIdRow.add( historyRecord.municipalAgency == null ? 'N/A' : historyRecord.municipalAgency );
            typeRow.add( historyRecord.serviceType );
            workTypeRow.add( historyRecord.serviceWorkType == null ? 'N/A' : historyRecord.serviceWorkType );
            for( Integer mapKey: tableRowsMap.keySet() ){
                List<String> historyRow = tableRowsMap.get(mapKey);
                historyRow.add(mapKey < historyRecord.renewableDates.size() ? historyRecord.renewableDates[mapKey] : '');
                tableRowsMap.put( mapKey, historyRow );
            }
        }
    }
}