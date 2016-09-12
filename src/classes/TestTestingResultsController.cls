@isTest
global class TestTestingResultsController implements HttpCalloutMock {
	
	global HTTPResponse respond( HTTPRequest req ) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
		if(req.getEndpoint().contains('ApexCodeCoverageAggregate')) {
        	res.setBody('{"Name":"Name1", "NumLinesCovered":"1", "NumLinesUncovered":"1", "Name":"Name2", "NumLinesCovered":"0", "NumLinesUncovered":"0"}');
		} else {
			res.setBody('{"Name":"Name1", "TestMethodName":"testMethodName1", "NumLinesCovered":"1", "NumLinesUncovered":"2"}');
		}
        res.setStatusCode(200);
        return res;
    }

	@isTest static void test_method_one() {
		Test.setMock( HttpCalloutMock.class, new TestTestingResultsController() );
		Test.startTest();
		TestingResultsController trc = new TestingResultsController();
		Test.stopTest();
		Double res1 = trc.content[0].covered;
		Double res2 = trc.content[1].covered;
		Double res3 = trc.totalCoverage;
	}
	
}