@isTest
private class TestCloneServiceTemplateExtention {
	@isTest
	private static void testCloningServiceTemplate() {
		Service_Template__c st = TestingUtils.createServiceTemplateList(1, true)[0];
		List<Task_Template__c> ttList = TestingUtils.createTaskTemplateList(5, 'test Name', true);
		for(Integer i = 0; i < 5; i++) {
			ttList[i].Service__c = st.Id;
			if(i > 0) ttList[i].Predecessor_Task__c	= ttList[i - 1].Predecessor_Task__c;
			if(i < 4) ttList[i].Successor_Task__c = ttList[i + 1].Successor_Task__c;
		}
		UPSERT ttList;
		ApexPages.StandardController testStandardController = new ApexPages.standardController(st);
		CloneServiceTemplateExtention cste = new CloneServiceTemplateExtention(testStandardController);
		System.assertNotEquals(cste.cloneServiceTemplate(), null);
		cste.profileName = 'not existing name';
		cste.allowedProfiles.add('one more Profile');
		System.assertNotEquals(cste.isAccessAllowed(), true);
		System.assertNotEquals(cste.backAction(), null);
	}
}