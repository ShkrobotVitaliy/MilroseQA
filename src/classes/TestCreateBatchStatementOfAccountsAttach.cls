@isTest
private class TestCreateBatchStatementOfAccountsAttach {
	@isTest static void testMethodOne() {
		DateTime myToday = DateTime.now();
		Account a = TestingUtils.createAccountList(1, 'testAccount', true)[0];
		Contact c = TestingUtils.createContactList(1, false)[0];
		c.AccountId = a.Id;
		c.Email_Statements_Job_Error__c = false;
		c.Email_Statement_Sent_Date_Time__c = myToday.addDays(1);
		c.Additional_Email_Statement_Sent_Date__c = myToday.addDays(1);
		c.Subject_for_SOA_email__c = 'test';
		INSERT c;
		Task t = TestingUtils.createTaskList(1, false)[0];
		t.WhoId = c.Id;
		t.Subject = 'Email: test';
		INSERT t;
		LStore__Stored_Document__c doc = new LStore__Stored_Document__c(LStore__File_Name__c = 'fileName.txt', Related_Object_Id__c = t.Id, LStore__Related_Object_Id__c = t.Id);
		INSERT doc;
		CreateBatchStatementOfAccountsAttach ba = new CreateBatchStatementOfAccountsAttach(myToday);
		Test.startTest();
		Database.executeBatch(ba);
		Test.stopTest();
	}
}