public with sharing class ServiceDetailTriggerUtils {
    
    // Used in ServiceDetailTrigger.trigger to insert the corresponding Invoice Line Items.
    public static Invoice_line_items__c buildInvoiceItem( Service_Detail__c obj, Decimal percentage, Map<Id, Project__c> projectMap ){
        Invoice_line_items__c elm = new Invoice_line_items__c();
        
        elm.Name = String.valueOf(Math.random()*100);
        elm.Service_Detail__c = obj.Id;
        
        if((obj.Proposal_Amount__c == null) || (percentage == null)){
            elm.Line_Item_Amount__c = 0;
        }else{
            elm.Line_Item_Amount__c = obj.Proposal_Amount__c * percentage / 100;
        }
        
        elm.Project__c = obj.Project__c;
        Project__c p = projectMap.get(elm.Project__c);
        elm.Project_Address__c = p.Building__c;
        elm.Billing_Contact__c = p.Billing_Contact_SF__c;
        elm.Client_Company__c = p.Billing_Contact_SF__r.AccountID;
        elm.Assigned__c = p.Assigned_SF__c;
        
        return elm;
    }

}