@isTest
private class TestAttachmentTrigger {
	private static final Integer NUMBER_TO_CREATE_ATTACHMENT = 3;
	private static final Integer NUMBER_TO_CREATE_PARENT_ACCOUNT = 2;
	private static final String TEST_ATTACHMENT_NAME = 'test';
	private static final Blob TEST_ATTACHMENT_BODY = Blob.valueOf('test attachment body');

	private static List<Account> testAccountList;
	private static List<Attachment> testAttachmentList;

	private static testmethod void testInsertAttachment(){
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_PARENT_ACCOUNT, null, true);
		testAttachmentList = new List<Attachment>();

		for (Account accountItem : testAccountList){
			testAttachmentList.addAll(TestingUtils.createAttachmentList(NUMBER_TO_CREATE_ATTACHMENT, accountItem.Id, TEST_ATTACHMENT_NAME, TEST_ATTACHMENT_BODY, false, false));
		}

		Test.startTest();

			insert testAttachmentList;

		Test.stopTest();

		List<Attachment> resultAttachmentList = [SELECT Id
												 FROM Attachment
												 WHERE Id IN : testAttachmentList];

		System.assert(resultAttachmentList != null && !resultAttachmentList.isEmpty());
		System.assertEquals(testAttachmentList.size(), resultAttachmentList.size());
	}
}