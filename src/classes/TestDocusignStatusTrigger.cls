@isTest
private class TestDocusignStatusTrigger {
	private static final Integer NUMBER_TO_CREATE_DOCUSING_STATUS = 3;

	private static List<dsfs__DocuSign_Status__c> testDocuSignStatus;

	private static testmethod void testUpdateDocuSignStatus(){
		testDocuSignStatus = TestingUtils.createDocuSignStatusList(NUMBER_TO_CREATE_DOCUSING_STATUS, false);
		for (dsfs__DocuSign_Status__c docuSignStatusItem : testDocuSignStatus){
			docuSignStatusItem.dsfs__Envelope_Status__c = 'test old';
		}
		insert testDocuSignStatus;

		for (dsfs__DocuSign_Status__c docuSignStatusItem : testDocuSignStatus){
			docuSignStatusItem.dsfs__Envelope_Status__c = 'test new';
		}

		Test.startTest();

			update testDocuSignStatus;

		Test.stopTest();
	}
}