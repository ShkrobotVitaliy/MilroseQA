public with sharing class CreateProjectLabelController {

    private final static String NO_DDP_AVAILABLE = 'Error finding correct DDP.';

    public Project_Profile__c project {get;set;}
    private String retUrl {
        get {
            if(retUrl == null) retUrl = '/' + Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '/o';
            return retUrl;
        }
        set;
    }
    
    public CreateProjectLabelController (ApexPages.StandardController controller) {
        project = (Project_Profile__c)controller.getRecord();
    }

    public PageReference autorun() {
        return runDDP();
    }

    private PageReference runDDP() {
        PageReference pr;
        List<Loop__DDP_Integration_Option__c> deliveryMethod  = [SELECT Id, Loop__DDP__c
                                                                 FROM Loop__DDP_Integration_Option__c
                                                                 WHERE Loop__DDP__r.Name = 'Create Project Label'
                                                                 AND Name = : 'Attach'];
        if( !deliveryMethod.isEmpty() ) {
            pr = new PageReference('/apex/loop__looplus');
            pr.getParameters().put('eid', project.Id);
            pr.getParameters().put('autorun', 'true');
            pr.getParameters().put('deploy', deliveryMethod[0].Id);
            pr.getParameters().put('ddpIds', deliveryMethod[0].Loop__DDP__c);
            //pr.getParameters().put('contactId', project.Billing_Contact__c);
            //pr.getParameters().put('retURL', retUrl);
            pr.setRedirect(true);
            return pr;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, NO_DDP_AVAILABLE));
        }
        return null;
    }

}