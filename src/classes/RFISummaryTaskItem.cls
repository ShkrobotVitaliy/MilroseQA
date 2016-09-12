public with sharing class RFISummaryTaskItem {
    private final Task_Item__c taskItem;
    private List<RFI_Scope__c> rfiScopes;
    
    public Boolean isApp { get; set; }
    public Boolean isSignOff { get; set; }
    
    public RFISummaryTaskItem(ApexPages.StandardController controller) {
        this.taskItem = (Task_Item__c)controller.getRecord();
    
    }
    
    public List<RFI_Scope__c> getRFIScopes() {
        this.isApp     = false;
        this.isSignOff = false;
        
        this.rfiScopes = new List<RFI_Scope__c>();
        
        try {
            if (RFIScopeServices.APPLICATION_FILING == this.taskItem.Service_Item__r.Category__c && RFIScopeServices.PLAN_APPROVAL == this.taskItem.Service_Item__r.Type__c) {
                this.rfiScopes = RFIScopeServices.getAppPlanApproveRFIScopesByProjectIdServiceId(this.taskItem.Project_Profile__c , this.taskItem.Service_Item__c);
                this.isApp = true;
                
            } else if (RFIScopeServices.APPLICATION_FILING == this.taskItem.Service_Item__r.Category__c && RFIScopeServices.WORK_PERMIT == this.taskItem.Service_Item__r.Type__c) {
                this.rfiScopes = RFIScopeServices.getAppWorkPermitRFIByProjectIdServiceId(this.taskItem.Project_Profile__c , this.taskItem.Service_Item__c);
                this.isApp = true;
                
            } else  if (RFIScopeServices.APPLICATION_SIGN_OFF == this.taskItem.Service_Item__r.Category__c) {
                this.rfiScopes = RFIScopeServices.getSignOffRFIByProjectIdServiceId(this.taskItem.Project_Profile__c , this.taskItem.Service_Item__c);
                this.isSignOff = true;
                
            }
        
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;
            
        }
            
        return this.rfiScopes;
    
    }

}