@isTest
private class testBusHoursClass {

	@isTest
	static void insertBusHours() {

		MDC_Internal_Request__c mdc = New MDC_Internal_Request__c ();
		mdc.Reference_Project_Name_P_O_Billing__c = 'Test';
		mdc.Date__c = System.Today();
		mdc.Project_Initiated_By__c = 'Test123' ;
		mdc.Start_Time__c  = System.Now();
		mdc.Completion_Time__c = System.Now();
		mdc.Billable__c = True;
		Insert mdc;

		mdc.Billable__c = false;
		mdc.Non_Billable__c = True;
		Update mdc;

		List<MDC_Internal_Request__c> intRequests = getMdcInternalRequestsByIds(new List<Id>{mdc.Id} );

		System.assertEquals(1, intRequests.size());
		System.assert(! String.isBlank(intRequests.get(0).Total_Time_New__c) );
	}


	// helper DAO methods

	private static List<MDC_Internal_Request__c> getAllMdcInternalRequests(){
		return [SELECT Id, Total_Time_New__c, Billable__c, Non_Billable__c
				FROM MDC_Internal_Request__c];
	}

	private static List<MDC_Internal_Request__c> getMdcInternalRequestsByIds(List<Id> ids){
		return [SELECT Id, Total_Time_New__c, Billable__c, Non_Billable__c
				FROM MDC_Internal_Request__c
				WHERE Id IN : ids];
	}
}