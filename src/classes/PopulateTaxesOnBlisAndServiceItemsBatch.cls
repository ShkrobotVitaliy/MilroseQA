global class PopulateTaxesOnBlisAndServiceItemsBatch implements Database.Batchable<sObject> {
	
	private final String BATCH_JOB_TITLE = 'Popolate Taxes on BLIs and Service Items accordingly to Tax Status';

	String query;

	List<Set<Id>> proposalsIdxSets;
    Set<Id> allProposals;
	//proposalsIdxSets[0] - contaipopulateTaxesOnBlisAndServiceItemsns set of ProposalsID where ServiceItem's taxes has to be set tu null 
    //proposalsIdxSets[1] - contains set of ProposalsID where ServiceItem's taxes has to be populated accordingly to templates

	global PopulateTaxesOnBlisAndServiceItemsBatch(List<Set<Id>> proposals) {
		this.proposalsIdxSets = proposals;
		allProposals = new Set<Id> ();
		allProposals.addAll(proposals.get(0));
		allProposals.addAll(proposals.get(1));
		this.query = 'SELECT Proposal__c, Tax_Code_1__c, Tax_Code_2__c, Project_Profile__c, ' + 
					 'Service_Template__c, Service_Template__r.Tax_Code_1__c, Service_Template__r.Tax_Code_2__c ' +
					 'FROM Service_Item__c WHERE Proposal__c IN :allProposals';	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		List<Service_Item__c> serviceItems = (List<Service_Item__c>) scope;

		Set<Id> projectsIdSetToPopulate = new Set<Id> ();
        Set<Id> projectsIdSetToClear = new Set<Id> ();

        for(Service_Item__c serviceItem : serviceItems) {
            if(proposalsIdxSets[0].contains(serviceItem.Proposal__c)) {
                serviceItem.Tax_Code_1__c = null;
                serviceItem.Tax_Code_2__c = null;
                if(serviceItem.Project_Profile__c != null) projectsIdSetToClear.add(serviceItem.Project_Profile__c);
            } else {
              if(serviceItem.Service_Template__c != null) {
                serviceItem.Tax_Code_1__c = serviceItem.Service_Template__r.Tax_Code_1__c;
                serviceItem.Tax_Code_2__c = serviceItem.Service_Template__r.Tax_Code_2__c;
              }
              if(serviceItem.Project_Profile__c != null) projectsIdSetToPopulate.add(serviceItem.Project_Profile__c);
            }
        }

        Database.update(serviceItems, false);
        serviceItems = null;

        List<Billing_Line_Item__c> blis = [SELECT Id, Sales_Tax_Amount_1__c, Sales_Tax_Amount_2__c, Amount__c,
                                                  Service_Item__c, Service_Item__r.Tax_Percent_1__c,Service_Item__r.Tax_Percent_2__c,
                                                  Billing_Project_Method__c, Project_Profile__c, 
                                                  Interval_Project__c, Quantity__c, Tax_Code_1__c, Tax_Code_2__c,
                                                  Billing_Date__c, Billing_Date__r.Percentage__c
                                            FROM Billing_Line_Item__c
                                            WHERE (Project_Profile__c IN :projectsIdSetToPopulate OR Project_Profile__c IN :projectsIdSetToClear)
                                                AND Pro_forma_Invoice__c = null
                                                AND isReimbursable__c = false];

        Map<Id, AggregateResult> projectIdToAggResultMap;
        for(Billing_Line_Item__c bli : blis) {
            if(bli.Billing_Project_Method__c == 'Milestone') {
                if(bli.Amount__c == null) bli.Amount__c = 0;
                bli.Sales_Tax_Amount_1__c = ( bli.Service_Item__c != null && bli.Service_Item__r.Tax_Percent_1__c != null ? bli.Service_Item__r.Tax_Percent_1__c * bli.Amount__c / 100 : 0.00 ).setScale(2);
                bli.Sales_Tax_Amount_2__c = ( bli.Service_Item__c != null && bli.Service_Item__r.Tax_Percent_2__c != null ? bli.Service_Item__r.Tax_Percent_2__c * bli.Amount__c / 100 : 0.00 ).setScale(2);                    
            } else {
                if(projectsIdSetToClear.contains(bli.Project_Profile__c)) {
                    bli.Sales_Tax_Amount_1__c = 0;
                    bli.Sales_Tax_Amount_2__c = 0;
                } else {
                    if(projectIdToAggResultMap == null) {
                        projectIdToAggResultMap = new Map<Id, AggregateResult> (); 
                        List<AggregateResult> ars = [SELECT Project_Profile__c, SUM(Sales_Tax_Amount_1__c)salesTax1, SUM(Sales_Tax_Amount_2__c)salesTax2
                                                    FROM Service_Item__c
                                                    WHERE Project_Profile__c IN :projectsIdSetToPopulate
                                                    GROUP BY Project_Profile__c];
                        for(AggregateResult ar : ars) projectIdToAggResultMap.put((Id)ar.get('Project_Profile__c'), ar);
                    }
                    if(bli.Interval_Project__c) {
                        bli.Sales_Tax_Amount_1__c = !String.isBlank(bli.Tax_Code_1__c) && bli.Quantity__c > 0 && bli.Billing_Date__c != null ? bli.Billing_Date__r.Percentage__c * Double.valueOf(projectIdToAggResultMap.get(bli.Project_Profile__c).get('salesTax1')) / 100 : 0;
                        bli.Sales_Tax_Amount_2__c = !String.isBlank(bli.Tax_Code_2__c) && bli.Quantity__c > 0 && bli.Billing_Date__c != null ? bli.Billing_Date__r.Percentage__c * Double.valueOf(projectIdToAggResultMap.get(bli.Project_Profile__c).get('salesTax2')) / 100 : 0;
                    } else {
                        bli.Sales_Tax_Amount_1__c = !String.isBlank(bli.Tax_Code_1__c) && bli.Quantity__c > 0 ? bli.Quantity__c * Double.valueOf(projectIdToAggResultMap.get(bli.Project_Profile__c).get('salesTax1')) : 0;
                        bli.Sales_Tax_Amount_2__c = !String.isBlank(bli.Tax_Code_2__c) && bli.Quantity__c > 0 ? bli.Quantity__c * Double.valueOf(projectIdToAggResultMap.get(bli.Project_Profile__c).get('salesTax2')) : 0;
                    }
                }
            }
        }
        Database.update(blis, false);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}