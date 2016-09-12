public class SchedulableJobModel{
    /* PROPERTIES */
    public boolean isSelected{get;set;}
    
    
    /* Constructor */
    public SchedulableJobModel(Schedulable_Job__c sj){
        isSelected = false;
        record = sj;
    }
    
    public Schedulable_Job__c record{
        get {
            if ( record == null )
                record = new Schedulable_Job__c();
            return record;
        }
        set {
            record = value;
        }
    }
}