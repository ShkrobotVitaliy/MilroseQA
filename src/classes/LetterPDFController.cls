public with sharing class LetterPDFController {
    private static final String TASK_TYPE = 'taskitem';
    private static final String SERVICE_TYPE = 'serviceitem';
    private static final String PROJECT_TYPE = 'project';
    private String projectId;
        
    public String fieldNumber { get { if( fieldNumber == null ) fieldNumber = '1'; return fieldNumber; } set; }
    public String type { get { if( type == null ) type = PROJECT_TYPE; return type; } set; }
    public Boolean isProjectProfile { get { return this.type.contains( PROJECT_TYPE ); } }
    public Boolean isServiceItem { get { return this.type.contains( SERVICE_TYPE ); } }
    public Boolean isTaskItem { get { return this.type.contains( TASK_TYPE ); } }

    public Project_Profile__c project {
        get {
            if( null == this.project ) {
                this.project = ProjectProfileServices.getProjectForSendLetterById( projectId );
            }
            return this.project;
        } set;
    }

    public FulfillmentOfficeAddresses__c fulfillmentOffice {
        get {
            if (null == this.fulfillmentOffice) {
                try {
                    this.fulfillmentOffice = FulfillmentOfficeAddresses__c.getValues(this.project.Fulfillment_Office__c);
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sorry, system cannot find current Fulfillment Office.'));
                    return null;
                }
            }
            return this.fulfillmentOffice;
        }
        private set;
    }
    
    public LetterPDFController() {
        this.projectId = ApexPages.currentPage().getParameters().get('projectId');
        this.type = ApexPages.currentPage().getParameters().get('type');
        this.fieldNumber = ApexPages.currentPage().getParameters().get('number');
    }
}