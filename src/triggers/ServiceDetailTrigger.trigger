trigger ServiceDetailTrigger on Service_Detail__c (before insert, before update, after insert, after update) {
    
    // This trigger passes onto the Service Detail the Service Setup percentages
    // It creates the Invoice Line Items when the corresponding fields are filled in
    if(Trigger.isAfter){
        
        set<Id> projectIdSet = new set<Id>();
        map<Id,Project__c> projectMap = new map<Id,Project__c>();
        
        
        for(Service_Detail__c obj : trigger.new){
            projectIdSet.add(obj.Project__c);
        }
        
        projectMap = new Map<Id, Project__c>([  SELECT p.Id, p.Building__c, p.Billing_Contact_SF__c, p.Billing_Contact_SF__r.AccountID, p.Assigned_SF__c 
                                                FROM Project__c p 
                                                WHERE p.Id IN :projectIdSet 
                                                LIMIT 9999 ]);
        
        list<Invoice_line_items__c> lineItemsToInsert = new list<Invoice_line_items__c>();
        
        for(Service_Detail__c obj : trigger.new){
            if((Trigger.isInsert && obj.Billing_Trigger_1_Done__c) || (Trigger.isUpdate && (trigger.oldMap.get(obj.Id).Billing_Trigger_1_Done__c != obj.Billing_Trigger_1_Done__c))){
                lineItemsToInsert.add( ServiceDetailTriggerUtils.buildInvoiceItem(obj, obj.Billing_Trigger_1_Percent__c, projectMap ) );
            }
            if((Trigger.isInsert && obj.Billing_Trigger_2_Done__c) || (Trigger.isUpdate && (trigger.oldMap.get(obj.Id).Billing_Trigger_2_Done__c != obj.Billing_Trigger_2_Done__c))){
                lineItemsToInsert.add( ServiceDetailTriggerUtils.buildInvoiceItem(obj, obj.Billing_Trigger_2_Percent__c, projectMap ) );
            }
            if((Trigger.isInsert && obj.Billing_Trigger_3_Done__c) || (Trigger.isUpdate && (trigger.oldMap.get(obj.Id).Billing_Trigger_3_Done__c != obj.Billing_Trigger_3_Done__c))){
                lineItemsToInsert.add( ServiceDetailTriggerUtils.buildInvoiceItem(obj, obj.Billing_Trigger_3_Percent__c, projectMap ) );
            }
        }
        
        if(lineItemsToInsert.size() > 0) upsert lineItemsToInsert;
        
    }else{
        
        if(trigger.isInsert){
            map<Id,Id> sDetailMap = new map<Id,Id>();
            set<Id> sSetupIdSet = new set<Id>();
            map<Id,Service_Setup__c> sSetupMap = new map<Id,Service_Setup__c>();
            
            for(Service_Detail__c obj : trigger.new){
                if(obj.Service__c == null) continue;
                sSetupIdSet.add(obj.Service__c);
                sDetailMap.put(obj.Id,obj.Service__c);
            }       
                
            sSetupMap = new Map<Id,Service_Setup__c>([  SELECT s.Billing_Trigger_3__c, s.Billing_Trigger_3_Percent__c, s.Billing_Trigger_2__c, s.Billing_Trigger_2_Percent__c, s.Billing_Trigger_1__c, s.Billing_Trigger_1_Percent__c 
                                                        FROM Service_Setup__c s
                                                        WHERE s.Id IN :sSetupIdSet
                                                        LIMIT 9999 ]);      
    
            for(Service_Detail__c obj : trigger.new){
                
                //lets get the corresponding service_setup__c object for the current service_detail__c object
                Service_Setup__c serviceSetupElement = sSetupMap.get(sDetailMap.get(obj.Id));
                if(serviceSetupElement == null) continue;
                
                map<Integer,String> fieldsFilledAPINames = new map<Integer,String>();
                
                //Having values, lets check if api names exist      
                //try{
                    //Check firstly if fields has been filled with info, and secondly, try to get value from current object using API names
                    //If API name does not exist in current object, an error message will be shown to the user.
                    String val = '';
                    
                    if((serviceSetupElement.Billing_Trigger_1__c != null) && (serviceSetupElement.Billing_Trigger_1_Percent__c != null)){
                        val = String.valueOf(obj.get(serviceSetupElement.Billing_Trigger_1__c));
                        fieldsFilledAPINames.put(0,serviceSetupElement.Billing_Trigger_1__c);
                    } else{ 
                        fieldsFilledAPINames.put(0, ''); 
                    }
                    
                    if((serviceSetupElement.Billing_Trigger_2__c != null) && (serviceSetupElement.Billing_Trigger_2_Percent__c != null)){ 
                        val = String.valueOf(obj.get(serviceSetupElement.Billing_Trigger_2__c)); 
                        fieldsFilledAPINames.put(1,serviceSetupElement.Billing_Trigger_2__c); 
                    }else{ 
                        fieldsFilledAPINames.put(1, '');
                    }
                    
                    if((serviceSetupElement.Billing_Trigger_3__c != null) && (serviceSetupElement.Billing_Trigger_3_Percent__c != null)){
                        val = String.valueOf(obj.get(serviceSetupElement.Billing_Trigger_3__c));
                        fieldsFilledAPINames.put(2,serviceSetupElement.Billing_Trigger_3__c);
                    }else{
                        fieldsFilledAPINames.put(2, '');
                    }
                    
                    if(fieldsFilledAPINames.size() < 1) continue;
                    
                    if((obj.Billing_Trigger_1_Percent__c == null) && (fieldsFilledAPINames.get(0) != '')){
                        obj.Billing_Trigger_1_Percent__c = serviceSetupElement.Billing_Trigger_1_Percent__c;                        
                    }
                    
                    if((obj.Billing_Trigger_2_Percent__c == null) && (fieldsFilledAPINames.get(1) != '')){
                        obj.Billing_Trigger_2_Percent__c = serviceSetupElement.Billing_Trigger_2_Percent__c;                        
                    }
                    
                    if((obj.Billing_Trigger_3_Percent__c == null) && (fieldsFilledAPINames.get(2) != '')){
                        obj.Billing_Trigger_3_Percent__c = serviceSetupElement.Billing_Trigger_3_Percent__c;                        
                    }
                    
                    obj.Billing_Trigger_1__c = serviceSetupElement.Billing_Trigger_1__c;
                    obj.Billing_Trigger_2__c = serviceSetupElement.Billing_Trigger_2__c;
                    obj.Billing_Trigger_3__c = serviceSetupElement.Billing_Trigger_3__c;
                    
                    if(obj.Billing_Trigger_1_Percent__c == null){ obj.Billing_Trigger_1_Percent__c = 0; }
                    if(obj.Billing_Trigger_2_Percent__c == null){ obj.Billing_Trigger_2_Percent__c = 0; }
                    if(obj.Billing_Trigger_3_Percent__c == null){ obj.Billing_Trigger_3_Percent__c = 0; }
                    
                    if((obj.Billing_Trigger_1_Percent__c + obj.Billing_Trigger_2_Percent__c + obj.Billing_Trigger_3_Percent__c != 100) 
                    && (obj.Billing_Trigger_1_Percent__c + obj.Billing_Trigger_2_Percent__c + obj.Billing_Trigger_3_Percent__c != 0)){
                        obj.addError('The sum of all Billing Trigger Percentages can not be different from 0% or 100%.');
                    }
                    
                    if((obj.Billing_Trigger_1__c != null) && ((obj.get(obj.Billing_Trigger_1__c) != null))){
                        obj.Billing_Trigger_1_Done__c = true;
                    }
                    if((obj.Billing_Trigger_2__c != null) && ((obj.get(obj.Billing_Trigger_2__c) != null))){
                        obj.Billing_Trigger_2_Done__c = true;
                    }
                    if((obj.Billing_Trigger_3__c != null) && ((obj.get(obj.Billing_Trigger_3__c) != null))){
                        obj.Billing_Trigger_3_Done__c = true;
                    }
                    
                //}catch( Exception e ){
                //    obj.addError('Error: Please verify API names in Service_Setup__c object.'+e.getMessage());
                //}
            }
        }else{
            for(Service_Detail__c obj : trigger.new){
                if((obj.Billing_Trigger_1__c != null) && ((obj.get(obj.Billing_Trigger_1__c) != null))){
                    obj.Billing_Trigger_1_Done__c = true;
                }
                if((obj.Billing_Trigger_2__c != null) && ((obj.get(obj.Billing_Trigger_2__c) != null))){
                    obj.Billing_Trigger_2_Done__c = true;
                }
                if((obj.Billing_Trigger_3__c != null) && ((obj.get(obj.Billing_Trigger_3__c) != null))){
                    obj.Billing_Trigger_3_Done__c = true;
                }
            }
        }
    }
    
}