@isTest
global class TestDeactivateUsersBatch implements HttpCalloutMock {

	global HTTPResponse respond( HTTPRequest req ) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }
	
	@isTest static void testDeactivateBatch() {
		Test.setMock( HttpCalloutMock.class, new TestDeactivateUsersBatch() );
		User u = TestingUtils.createUsers(1, true)[0];
		u = [SELECT Id, isActive FROM User WHERE Id = :u.Id];
		u.isActive = false;
		Test.startTest();
		UPDATE u;
		Test.stopTest();
	}	

}