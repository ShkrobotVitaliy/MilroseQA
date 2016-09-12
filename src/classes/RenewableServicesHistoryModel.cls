public with sharing class RenewableServicesHistoryModel{
    public String municipalAgency {get; set;}
    public String serviceType {get; set;}
    public String serviceWorkType {get; set;}
    public Map<Id, Map<Datetime, Datetime>> renewablePeriodsMap {get; set;}
    private Map<DateTime, List<Id>> createdDateToTaskIds;

    public List<String> renewableDates {
        get{
            if( renewableDates== null ){
                renewableDates = new List<String>();

                //MRS-4356 will sort by createddate
                List<DateTime> taskCreatedDates = new List<DateTime>();
                taskCreatedDates.addAll( this.createdDateToTaskIds.keySet() );
                taskCreatedDates.sort();

                for( Datetime taskCreatedDate : taskCreatedDates ) {
                    for( Id renewableTaskId : this.createdDateToTaskIds.get( taskCreatedDate ) ) {
                        Map<Datetime, Datetime> renewablePeriod = this.renewablePeriodsMap.get( renewableTaskId );
                        for( DateTime activationDate : renewablePeriod.keySet() ) {
                            DateTime expirationDate = renewablePeriod.get( activationDate );
                            String Link1 = '<span style="cursor: pointer;text-decoration: underline;" onclick="redirect(\''+renewableTaskId+'\')">' + String.valueOf(activationDate.format('MM/dd/yyyy')) + '</span>';
                            String Link2 = '<span style="cursor: pointer;text-decoration: underline;" onclick="redirect(\''+renewableTaskId+'\')">' + String.valueOf(expirationDate.format('MM/dd/yyyy')) + '</span>';
                            renewableDates.add(Link1);
                            renewableDates.add(Link2);
                        }
                    }
                }

                //old; seems to sort by activation date
                /*List<Datetime> activationDates = new List<Datetime>();
                for( Map<Datetime, Datetime> renewablePeriod: renewablePeriodsMap.values() ){
                    activationDates.addAll(renewablePeriod.keySet());
                }
                activationDates.sort();
                for( Datetime activationDate: activationDates ){
                    for( Id renewableTaskId: renewablePeriodsMap.keySet() ){
                        Map<Datetime, Datetime> renewablePeriod = renewablePeriodsMap.get(renewableTaskId);
                        if( renewablePeriod.containsKey(activationDate) ){
                            String Link1 = '<span style="cursor: pointer;text-decoration: underline;" onclick="redirect(\''+renewableTaskId+'\')">' + String.valueOf(activationDate.format('MM/dd/yyyy')) + '</span>';
                            String Link2 = '<span style="cursor: pointer;text-decoration: underline;" onclick="redirect(\''+renewableTaskId+'\')">' + String.valueOf(renewablePeriod.get(activationDate).format('MM/dd/yyyy')) + '</span>';
                            renewableDates.add(Link1);
                            renewableDates.add(Link2);
                        }
                    }
                }*/
            }
            return renewableDates;
        }
        set;
    }

    public void addCreatedDate( DateTime taskCreatedDate, Id taskId ) {
        if( this.createdDateToTaskIds.get( taskCreatedDate ) == null ) {
            this.createdDateToTaskIds.put( taskCreatedDate, new List<Id>() );
        }
        List<Id> taskIds = this.createdDateToTaskIds.get( taskCreatedDate );
        taskIds.add( taskId );
        this.createdDateToTaskIds.put( taskCreatedDate, taskIds );
    }

    public RenewableServicesHistoryModel ( String municipalAgencyId, String serviceType, String serviceWorkType ){
        this.municipalAgency = municipalAgencyId;
        this.serviceType = serviceType;
        this.serviceWorkType = serviceWorkType;
        this.renewablePeriodsMap = new Map<Id, Map<Datetime, Datetime>>();
        this.createdDateToTaskIds = new Map<DateTime, List<Id>>();
    }
}