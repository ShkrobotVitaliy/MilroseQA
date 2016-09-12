@isTest
private class TestMonitorRFIScopeTrigger {
	
	@isTest static void test_method_one() {
		RFI_Scope__c rfiScope = new RFI_Scope__c();
		INSERT rfiScope;
		Monitor_RFI_Scope__c monitorRfiS = new Monitor_RFI_Scope__c();
		monitorRfiS.RFI_Scope__c = rfiScope.Id;
		INSERT monitorRfiS;
		system.debug('###'+monitorRfiS+'###');
	}
}