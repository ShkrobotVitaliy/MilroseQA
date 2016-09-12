public with sharing class RedirectBillingTriggersController {
    public Id proposalId { get; set; }
    public Id changeOrderId { get; set; }
    public Boolean isValid { get; private set; }
    public Map<Id, BillingTriggerSelector> taskIdToBillingTrigger { get { if( taskIdToBillingTrigger == null ) taskIdToBillingTrigger = new Map<Id, BillingTriggerSelector>(); return taskIdToBillingTrigger; } set; }

    private List<Service_Item__c> servicesFreeInThisCO = new List<Service_Item__c>();
    private Map<Id, List<Task_Template__c>> serviceIdFreeInThisCOToTaskTemplates = new Map<Id, List<Task_Template__c>>();
    
    private List<Service_Item__c> servicesFreeNotInThisCO = new List<Service_Item__c>();
    private Map<Id, List<Task_Item__c>> serviceIdFreeNotInThisCOToTaskItems = new Map<Id, List<Task_Item__c>>();
    
    private Map<Id, Service_Item__c> serviceIdDeletedInThisCOToServiceItem = new Map<Id, Service_Item__c>();
    private Map<Id, List<Task_Item__c>> serviceIdDeletedInThisCOToTaskItems = new Map<Id, List<Task_Item__c>>();

    public RedirectBillingTriggersController() {
        isValid = true;
        String proposalId = ApexPages.currentPage().getParameters().get('p');
        String changeOrderId = ApexPages.currentPage().getParameters().get('co');
        if( proposalId == null || !(proposalId instanceOf Id) || changeOrderId == null || !(changeOrderId instanceOf Id) ) {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
        this.proposalId = proposalId;
        this.changeOrderId = changeOrderId;

        //here are all services including these in current CO, some of them can have deleted billing triggers
        List<Service_Item__c> services = [ SELECT Id, Name, Service_Name_Full__c, Change_Order__c, Quantity_Old__c, Service_Template__c, Is_Amendmend_Deleted__c,
                                               ( SELECT Id, Name, Billing_Trigger__c, Billing_Percentage__c
                                                 FROM Task_Items__r
                                                 WHERE Is_Locked__c = false
                                                 ORDER BY Id )
                                           FROM Service_Item__c
                                           WHERE Proposal__c = : proposalId
                                             AND Is_Alternative__c = false
                                             AND ( ( Is_Amendmend_Deleted__c = false AND Change_Order__r.Status__c != : ChangeOrderServices.STATUS_CANCELED ) OR
                                                   ( Is_Amendmend_Deleted__c = true  AND Change_Order__r.Status__c != : ChangeOrderServices.STATUS_APPROVED ) )
                                           ORDER BY Change_Order__r.Number__c NULLS FIRST, Row_Position__c ASC ];

        for( Service_Item__c si : services ) {
            if( si.Change_Order__c == changeOrderId ) {
                if( !si.Is_Amendmend_Deleted__c ) {
                    if( si.Quantity_Old__c == null || si.Quantity_Old__c == 0 ) {
                        if( si.Service_Template__c != null ) {
                            servicesFreeInThisCO.add( si );
                        }
                    } else {
                        if( !si.Task_Items__r.isEmpty() ) {
                            servicesFreeNotInThisCO.add( si );
                            serviceIdFreeNotInThisCOToTaskItems.put( si.Id, si.Task_Items__r );
                        }
                    }
                } else {
                    Boolean hasTasksWithBillingPercentage = false;
                    for( Task_Item__c ti : si.Task_Items__r ) {
                        if( ti.Billing_Percentage__c != null && ti.Billing_Percentage__c > 0 ) {
                            hasTasksWithBillingPercentage = true;
                            break;
                        }
                    }
                    if( hasTasksWithBillingPercentage ) {
                        serviceIdDeletedInThisCOToServiceItem.put( si.Id, si );
                    }
                }
            } else {
                if( !si.Task_Items__r.isEmpty() ) {
                    servicesFreeNotInThisCO.add( si );
                    serviceIdFreeNotInThisCOToTaskItems.put( si.Id, si.Task_Items__r );
                }
            }
        }

        //retrieve task templates that should create task items in this CO
        Map<Id, List<Id>> serviceTemplateIdToServiceIds = new Map<Id, List<Id>>();
        for( Service_Item__c si : servicesFreeInThisCO ) {
            if( !serviceTemplateIdToServiceIds.containsKey( si.Id ) ) {
                serviceTemplateIdToServiceIds.put( si.Service_Template__c, new List<Id>() );
            }
            serviceTemplateIdToServiceIds.get( si.Service_Template__c ).add( si.Id );
        }
        
        for( Service_Template__c serviceTemplate : TaskTemplateServices.getServiceTemplatesWithTaskStateChangesAndActualTaskTemplates( serviceTemplateIdToServiceIds.keySet() ) ) {
            for( Id siId : serviceTemplateIdToServiceIds.get( serviceTemplate.Id ) ) {
                if( !serviceIdFreeInThisCOToTaskTemplates.containsKey( siId ) ) {
                    serviceIdFreeInThisCOToTaskTemplates.put( siId, new List<Task_Template__c>() );
                }
                serviceIdFreeInThisCOToTaskTemplates.get( siId ).addAll( serviceTemplate.Tasks__r );
            }
        }

        //retrieve task items that are deleted in this CO and should be redirected
        for( Id siId : serviceIdDeletedInThisCOToServiceItem.keySet() ) {
            for( Task_Item__c ti : serviceIdDeletedInThisCOToServiceItem.get( siId ).Task_Items__r ) {
                if( ti.Billing_Trigger__c && ti.Billing_Percentage__c != null && ti.Billing_Percentage__c > 0 ) {
                    if( !serviceIdDeletedInThisCOToTaskItems.containsKey( siId ) ) {
                        serviceIdDeletedInThisCOToTaskItems.put( siId, new List<Task_Item__c>() );
                    }
                    serviceIdDeletedInThisCOToTaskItems.get( siId ).add( ti );
                }
            }
        }

        for( Id siId : serviceIdDeletedInThisCOToTaskItems.keySet() ) {
            for( Task_Item__c ti : serviceIdDeletedInThisCOToTaskItems.get( siId ) ) {
                taskIdToBillingTrigger.put( ti.Id, new BillingTriggerSelector( serviceIdDeletedInThisCOToServiceItem.get( siId ), ti ) );
            }
        }

        if( taskIdToBillingTrigger.keySet().isEmpty() ) {
            isValid = false;
        }
        
        //system.debug(LoggingLevel.Error, 'xxx taskIdToBillingTrigger: ' + taskIdToBillingTrigger);
        //system.debug(LoggingLevel.Error, 'xxx servicesFreeInThisCO: ' + servicesFreeInThisCO);
        //system.debug(LoggingLevel.Error, 'xxx serviceIdFreeInThisCOToTaskTemplates: ' + serviceIdFreeInThisCOToTaskTemplates);
        //system.debug(LoggingLevel.Error, 'xxx servicesFreeNotInThisCO: ' + servicesFreeNotInThisCO);
        //system.debug(LoggingLevel.Error, 'xxx serviceIdFreeNotInThisCOToTaskItems: ' + serviceIdFreeNotInThisCOToTaskItems);
        //system.debug(LoggingLevel.Error, 'xxx serviceIdDeletedInThisCOToServiceItem: ' + serviceIdDeletedInThisCOToServiceItem);
        //system.debug(LoggingLevel.Error, 'xxx serviceIdDeletedInThisCOToTaskItems: ' + serviceIdDeletedInThisCOToTaskItems);
        //system.debug(LoggingLevel.Error, 'xxx services: ' + services);
        //system.debug(LoggingLevel.Error, 'xxx changeOrderId: ' + changeOrderId);
        //system.debug(LoggingLevel.Error, 'xxx proposalId: ' + proposalId);
        //system.debug(LoggingLevel.Error, 'xxx isValid: ' + isValid);
    }

    public String taskIdActive { get; set; }
    public String serviceIdChosen { get; set; }
    public String serviceNameChosen { get; set; }
    public String taskIdChosen { get; set; }
    public String taskNameChosen { get; set; }

    public transient List<SelectOption> picklistForServices;
    public List<SelectOption> getPicklistForServices() {
        List<SelectOption> selectOptions = new List<SelectOption>();
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();
        serviceItems.addAll( servicesFreeNotInThisCO );
        serviceItems.addAll( servicesFreeInThisCO );
        selectOptions.add( new SelectOption( '', '-- Not Selected --' ) );
        for( Service_Item__c si : serviceItems ) {
            selectOptions.add( new SelectOption( si.Id, si.Name + ' - ' + si.Service_Name_Full__c ) );
        }
        return selectOptions;
    }

    public transient List<SelectOption> picklistForTasks;
    public List<SelectOption> getPicklistForTasks() {
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add( new SelectOption( '', '-- Not Selected --' ) );
        if( !String.isBlank( serviceIdChosen ) ) {
            if( serviceIdFreeNotInThisCOToTaskItems.containsKey( serviceIdChosen ) ) {
                for( Task_Item__c ti : serviceIdFreeNotInThisCOToTaskItems.get( serviceIdChosen ) ) {
                    selectOptions.add( new SelectOption( ti.Id, ti.Name ) );
                }
            }
            if( serviceIdFreeInThisCOToTaskTemplates.containsKey( serviceIdChosen ) ) {
                for( Task_Template__c tt : serviceIdFreeInThisCOToTaskTemplates.get( serviceIdChosen ) ) {
                    selectOptions.add( new SelectOption( tt.Id, tt.Name ) );
                }
            }
        }
        return selectOptions;
    }

    public void pickService() {
        for( BillingTriggerSelector selector : taskIdToBillingTrigger.values() ) {
            selector.isActive = false;
        }
        taskIdToBillingTrigger.get( taskIdActive ).isActive = true;
        serviceIdChosen = taskIdToBillingTrigger.get( taskIdActive ).serviceIdChosen;
        taskIdChosen = taskIdToBillingTrigger.get( taskIdActive ).taskIdChosen;
    }

    public void setService() {
        taskIdToBillingTrigger.get( taskIdActive ).setActiveService( serviceIdChosen, serviceNameChosen );
        taskIdToBillingTrigger.get( taskIdActive ).setActiveTask( null, null );
    }
    
    public void setTask() {
        taskIdToBillingTrigger.get( taskIdActive ).setActiveTask( taskIdChosen, taskNameChosen );
    }

    public Boolean allValuesSet {
        get {
            for( BillingTriggerSelector selector : taskIdToBillingTrigger.values() ) {
                if( selector.serviceIdChosen == null || selector.taskIdChosen == null ) {
                    return false;
                }
            }
            return true;
        }
    }
    
    public PageReference applySelection() {
        DDP_Helper__c changeOrderData = new DDP_Helper__c( Type__c = ProposalWizardServices.CHANGE_ORDER_APPROVAL_TYPE, Change_Order__c = changeOrderId, Text1__c = '' );
        for( BillingTriggerSelector selector : taskIdToBillingTrigger.values() ) {
            changeOrderData.Text1__c += selector.taskId;
            changeOrderData.Text1__c += ProposalWizardServices.CHANGE_ORDER_CONTENT;
            changeOrderData.Text1__c += selector.serviceIdChosen;
            changeOrderData.Text1__c += ProposalWizardServices.SERVICE_ITEM_SPLITTER;
            changeOrderData.Text1__c += selector.taskIdChosen;
            changeOrderData.Text1__c += ProposalWizardServices.CHANGE_ORDER_SPLITTER;
        }
        changeOrderData.Text1__c = changeOrderData.Text1__c.removeEnd( ProposalWizardServices.CHANGE_ORDER_SPLITTER );
        system.debug(LoggingLevel.Error, 'xxx changeOrderData: ' + changeOrderData.Text1__c);
        try {
            INSERT changeOrderData;
        } catch( dmlException e ) {
            MilroseDevHelper.addMessage( 'Can not pass your setup data from this page to Proposal Wizard.' );
            return null;
        }
        PageReference pr = new PageReference( '/apex/ProposalWizard' );
        pr.getParameters().put( 'id', proposalId );
        pr.getParameters().put( 'co', changeOrderId );
        pr.getParameters().put( 'data', changeOrderData.Id );
        pr.getParameters().put( 'action', ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION );
        pr.getParameters().put( 'step', '3' );
        pr.setRedirect(true);
        return pr;
    }

    public class BillingTriggerSelector {
        public Boolean isActive { get; set; }
        public Id serviceId { get; set; }
        public String serviceName { get; set; }
        public Id taskId { get; set; }
        public String taskName { get; set; }
        public Decimal billingPercentage { get; set; }

        public String serviceIdChosen { get; set; }
        public String serviceNameChosen { get { if( serviceIdChosen == null ) serviceNameChosen = '-- Not Selected --'; return serviceNameChosen; } set; }
        public String taskIdChosen { get; set; }
        public String taskNameChosen { get { if( taskIdChosen == null ) taskNameChosen = '-- Not Selected --'; return taskNameChosen; } set; }

        public BillingTriggerSelector( Service_Item__c service, Task_Item__c task ) {
            this.isActive = false;
            this.serviceId = service.Id;
            this.serviceName = service.Name + ' - ' + service.Service_Name_Full__c;
            this.taskId = task.Id;
            this.taskName = task.Name;
            this.billingPercentage = task.Billing_Percentage__c;
        }

        public void setActiveService( String serviceId, String serviceName ) {
            this.serviceIdChosen = String.isEmpty( serviceId ) ? null : serviceId;
            this.serviceNameChosen = String.isEmpty( serviceName ) ? null : serviceName;
        }
        
        public void setActiveTask( String taskId, String taskName ) {
            this.taskIdChosen = String.isEmpty( taskId ) ? null : taskId;
            this.taskNameChosen = String.isEmpty( taskName ) ? null : taskName;
        }
    }

}