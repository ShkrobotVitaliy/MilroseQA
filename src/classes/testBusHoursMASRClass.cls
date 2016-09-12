@isTest
private class testBusHoursMASRClass {

	static testMethod void insertBusHoursMASR() {

		Building__c testBuilding = TestingUtils.createBuildingList(1, null, null, null, null, null, true)[0];
		Municipal_Approval_Scanning_Request__c mas = New Municipal_Approval_Scanning_Request__c (MRC_Number__c = 'test', Job_Address__c = testBuilding.Id, To__c = 'test');
		mas.Municipal_Agency_ID__c = 'Test';
		mas.Date__c=System.Today();
		mas.Project_Initiated_By__c = 'Test123';
		mas.Start_Time__c = System.Now();
		mas.Completion_Time__c = System.Now();
		mas.Application__c = True;
		Insert mas;

		mas.Amendment__c = false;
		Update mas;

		List<Municipal_Approval_Scanning_Request__c> scanRequests = getScanningRequestsByIds(new List<Id>{mas.Id} );

		System.assertEquals(1, scanRequests.size());
		System.assert(! String.isBlank(scanRequests.get(0).Total_Time_New__c) );
	}


	// helper DAO methods

	private static List<Municipal_Approval_Scanning_Request__c> getScanningRequestsByIds(List<Id> ids){
		return [SELECT Id, Total_Time_New__c
				FROM Municipal_Approval_Scanning_Request__c
				WHERE Id IN : ids];
	}
}