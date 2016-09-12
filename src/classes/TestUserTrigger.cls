@isTest
private class TestUserTrigger {
	
	private static testmethod void testAfterUpdate(){

		List<User> userList = [SELECT Id, IsActive FROM User WHERE Id != : userinfo.getuserid() LIMIT 3];
		for (User u : userList){
			u.IsActive = !u.IsActive;
		}

		Test.startTest();
			update userList;
		Test.stopTest();
	}
}