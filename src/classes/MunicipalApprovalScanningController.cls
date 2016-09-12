public class MunicipalApprovalScanningController {
    public String taskId { get { if( taskId == null ) taskId = ''; return taskId; } set; }
    public String taskName { get { if( taskName == null ) taskName = ''; return taskName; } set; }
    public String projectId { get { if( projectId == null ) projectId = ''; return projectId; } set; }
    public String projectName { get { if( projectName == null ) projectName = ''; return projectName; } set; }

    public String mrcNumber { get { if( mrcNumber == null ) mrcNumber = ''; return mrcNumber.replaceFirst('MRC[0]*', ''); } set; }
    public String jobAddressId { get { if( jobAddressId == null ) jobAddressId = ''; return jobAddressId; } set; }
    public String jobAddressName { get { if( jobAddressName == null ) jobAddressName = ''; return jobAddressName; } set; }
    public String munipicalAgency { get { if( munipicalAgency == null ) munipicalAgency = ''; return munipicalAgency; } set; }
    
    public String retURL { get { return '&retURL=/' + taskId; } }

    public MunicipalApprovalScanningController( ApexPages.StandardController controller ) {
        Sobject parent = controller.getRecord();
       List<Task_Item__c> tasks = [ SELECT Id, Name, Project_Profile__c, Project_Profile__r.Name, Project_Profile__r.Building__c, Project_Profile__r.Building_AKA__c,
                                           Project_Profile__r.Address_Building_AKA__c, X3rd_Party_Authority_ID__c
                                    FROM Task_Item__c
                                    WHERE Id = : (Id)(controller.getRecord().get('Id')) ];
       if( !tasks.isEmpty() ) {
           taskId = tasks[0].Id;
           taskName = tasks[0].Name;
           projectId = tasks[0].Project_Profile__c;
           projectName = tasks[0].Project_Profile__r.Name;
           mrcNumber = tasks[0].Project_Profile__r.Name;
           jobAddressId = tasks[0].Project_Profile__r.Building_AKA__c != null ? tasks[0].Project_Profile__r.Building_AKA__c : tasks[0].Project_Profile__r.Building__c;
           jobAddressName = tasks[0].Project_Profile__r.Address_Building_AKA__c;
           munipicalAgency = tasks[0].X3rd_Party_Authority_ID__c;
       }
    }

}