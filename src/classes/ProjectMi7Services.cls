public with sharing class ProjectMi7Services {
    /* ----------------------------- Begin Business Logic Methods -----------------------------------------------*/
    
    public static void calculateOutstandingAmounts(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            throw new ErrorException(ErrorException.PROJECT_ID_EMPTY);
        
        }
        
        List<Project__c> projects = ProjectMi7Services.getProjectMi7ByIds(projectIds);
        Date todayDate = Date.today();
        
        for (Project__c project : projects) {
            project.Outstanding_Amount_1_To_30_Days__c  = 0.00;
            project.Outstanding_Amount_31_To_60_Days__c = 0.00;
            project.Outstanding_Amount_61_To_90_Days__c = 0.00;
            project.Outstanding_Amount_90_Days__c       = 0.00;
            project.Outstanding_Amount_Today__c         = 0.00;

            for (Legacy_Pro_forma_Invoice__c invoice : project.Legacy_Pro_forma_Invoices__r) {
                if (null != invoice.Amount_Due__c && null != invoice.Invoice_Date__c) {
                    project.Outstanding_Amount_Today__c         += (invoice.Invoice_Date__c >= todayDate)                                                      ? invoice.Amount_Due__c : 0.00 ;
                    project.Outstanding_Amount_1_To_30_Days__c  += (invoice.Invoice_Date__c < todayDate && invoice.Invoice_Date__c >= (todayDate - 30))        ? invoice.Amount_Due__c : 0.00;
                    project.Outstanding_Amount_31_To_60_Days__c += (invoice.Invoice_Date__c < (todayDate - 30) && invoice.Invoice_Date__c >= (todayDate - 60)) ? invoice.Amount_Due__c : 0.00;
                    project.Outstanding_Amount_61_To_90_Days__c += (invoice.Invoice_Date__c < (todayDate - 60) && invoice.Invoice_Date__c >= (todayDate - 90)) ? invoice.Amount_Due__c : 0.00;
                    project.Outstanding_Amount_90_Days__c       += (invoice.Invoice_Date__c < (todayDate - 90))                                                ? invoice.Amount_Due__c : 0.00;
                
                }
            
            }
        
        }
        update projects;
    
    }

	public static Map<Id, Project__c> filteredProjectsWithChangedAccManager(List<Project__c> newList, Map<Id, Project__c> oldMap) { //MRS 7540
		Map<Id, Project__c> result = new Map<Id, Project__c>();
		for(Project__c p : newList) {
			if(oldMap == null || oldMap.get(p.Id) == null || p.Billing_Client_Company__c != oldMap.get(p.Id).Billing_Client_Company__c) result.put(p.Id, p); 
		}
		return result;
	}
    
    /* ----------------------------- End Business Logic Methods -----------------------------------------------*/

    /* ----------------------------- Begin DAO Methods -----------------------------------------------*/
    
    public static List<Project__c> getProjectMi7ByIds(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            throw new ErrorException(ErrorException.PROJECT_ID_EMPTY);
        
        }
        
        return new List<Project__c>([SELECT Outstanding_Amount_Today__c, Outstanding_Amount_90_Days__c, Outstanding_Amount_61_To_90_Days__c, 
                                            Outstanding_Amount_31_To_60_Days__c, Outstanding_Amount_1_To_30_Days__c,
                                            (SELECT Invoice_Date__c, Amount_Due__c 
                                             FROM Legacy_Pro_forma_Invoices__r
                                             WHERE Amount_Due__c != 0)
                                     FROM Project__c
                                     WHERE Id IN: projectIds]);                     
        
    }
    
    /* ----------------------------- End DAO Methods -----------------------------------------------*/

}