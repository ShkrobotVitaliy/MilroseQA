public class MdcInternalRequestController {
    public String projectId { get { if( projectId == null ) projectId = ''; return projectId; } set; }
    public String projectName { get { if( projectName == null ) projectName = ''; return projectName; } set; }

    public String mrcNumber { get { if( mrcNumber == null ) mrcNumber = ''; return mrcNumber.replaceFirst('MRC[0]*', ''); } set; }
    public String jobAddressId { get { if( jobAddressId == null ) jobAddressId = ''; return jobAddressId; } set; }
    public String jobAddressName { get { if( jobAddressName == null ) jobAddressName = ''; return jobAddressName; } set; }
    public String munipicalAgency { get { if( munipicalAgency == null ) munipicalAgency = ''; return munipicalAgency; } set; }
    public String projectNameStr { get { if( projectNameStr == null ) projectNameStr = ''; return projectNameStr; } set; }
    
    public String retURL { get { return '&retURL=/' + projectId; } }

    public MdcInternalRequestController( ApexPages.StandardController controller ) {
        Sobject parent = controller.getRecord();
        List<Project_Profile__c> projects = [ SELECT Id, Name, Building__c, Building_AKA__c, Address_Building_AKA__c, Municipal_Agency_ID__c, Project_Name__c
                                              FROM Project_Profile__c
                                              WHERE Id = : (Id)(controller.getRecord().get('Id')) ];
        if( !projects.isEmpty() ) {
            projectId = projects[0].Id;
            projectName = projects[0].Name;
            mrcNumber = projects[0].Name;
            jobAddressId = projects[0].Building_AKA__c != null ? projects[0].Building_AKA__c : projects[0].Building__c;
            jobAddressName = projects[0].Address_Building_AKA__c;
            munipicalAgency = projects[0].Municipal_Agency_ID__c;
            projectNameStr = projects[0].Project_Name__c;
        }
    }

}