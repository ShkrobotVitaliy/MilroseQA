@isTest
private class TestLegacyMailroomTrigger {
	public static testmethod void testInsertLegacyMailroom(){
		Legacy_Mailroom__c testLegacyMailroom = new Legacy_Mailroom__c();
		insert testLegacyMailroom;
	}
}