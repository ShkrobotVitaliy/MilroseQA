trigger ServiceSetupBeforeUpsert on Service_Setup__c (before insert, before update) {
    
    // This trigger makes sure that the fields indicated in the trigger exist and that the percentages are correct.
    
    Map<String, Schema.SObjectField> describeFields = Schema.SObjectType.Service_Detail__c.fields.getMap();
    
    for(Service_Setup__c s : Trigger.new){

        Decimal d = 0;
        if((s.Billing_Trigger_1__c == null) || (s.Billing_Trigger_1__c == '')){ 
            s.Billing_Trigger_1_Percent__c = 0;
        }else{
            if(describeFields.get(s.Billing_Trigger_1__c) == null){
                s.addError('The field ' + s.Billing_Trigger_1__c + ' does not exist in the object Service_Detail__c');
            }
            d = d + s.Billing_Trigger_1_Percent__c;
        }
        
        if((s.Billing_Trigger_2__c == null) || (s.Billing_Trigger_2__c == '')){
            s.Billing_Trigger_2_Percent__c = 0;
        }else{
            if(describeFields.get(s.Billing_Trigger_2__c) == null){
                s.addError('The field ' + s.Billing_Trigger_2__c + ' does not exist in the object Service_Detail__c');
            }
            d = d + s.Billing_Trigger_2_Percent__c;
        }
        
        if((s.Billing_Trigger_3__c == null) || (s.Billing_Trigger_3__c == '')){
            s.Billing_Trigger_3_Percent__c = 0;
        }else{
            if(describeFields.get(s.Billing_Trigger_3__c) == null){
                s.addError('The field ' + s.Billing_Trigger_3__c + ' does not exist in the object Service_Detail__c');
            }
            d = d + s.Billing_Trigger_3_Percent__c;
        }
        
        if((s.Billing_Trigger_1_Percent__c + s.Billing_Trigger_2_Percent__c + s.Billing_Trigger_3_Percent__c != 100)
        && (s.Billing_Trigger_1_Percent__c + s.Billing_Trigger_2_Percent__c + s.Billing_Trigger_3_Percent__c != 0)){
            s.addError('The sum of all Billing Trigger Percentages can not be different from 0% or 100%. The current sum is ' + d);
        }
    }
    
}