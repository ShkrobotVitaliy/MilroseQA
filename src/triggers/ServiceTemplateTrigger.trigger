trigger ServiceTemplateTrigger on Service_Template__c (before insert, after insert, after update) {
    
    if ( Trigger.isBefore && Trigger.isInsert ) {
    	ServiceTemplateServices.updateDefaultShortServiceName(Trigger.new);
    }
    
    MilroseSetting__c milroseSetting = MilroseSetting__c.getInstance('Is_run_service_template');
    if( milroseSetting.Is_run_service_template__c ) {
        if (Trigger.isAfter) {
            if(Trigger.isUpdate) {
                ServiceTemplateServices.updateServiceItemTaxCode( ServiceTemplateServices.filterServiceTemplateTaxCode( Trigger.new, Trigger.oldMap ) );
            }
            if(Trigger.isUpdate || Trigger.isInsert) {
                ServiceTemplateServices.updateMetDataScanningFee(ServiceTemplateServices.filterMetDataScanningFee(Trigger.newMap, Trigger.oldMap));
                ServiceItemServices.updateShreddingFeesOnServiceItem(ServiceItemServices.filterShreddingFeesOnServiceItem (Trigger.newMap, Trigger.oldMap), Trigger.newMap);
            }

        }
    }


}