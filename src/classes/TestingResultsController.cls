public with sharing class TestingResultsController {
	
	public String selectedClass { set; get; }
	public List<SelectOption> classesAndTriggers  { set; get {
			if(classesAndTriggers == null) classesAndTriggers = new List<SelectOption>();
			return classesAndTriggers;
		}
	}

	class TestResultWrapper {
		public String name { get; set; } 
		public Double linesCovered { get; set; }
		public Double linesUncovered { get; set; }
		public Double covered { set; get {
				if((linesUncovered + linesCovered) > 0) {
					return (linesCovered / (linesUncovered + linesCovered) * 100).round();
				} else {
					return 0;
				}
			}
		}
	}

	public Double totalCoverage { set;
		get {
			if(totalCoverage == null) {
				Double totalCovered = 0.0;
				Double totalUncovered = 0.0;
				for(TestResultWrapper trw : content) {
					totalCovered += trw.linesCovered;
					totalUncovered += trw.linesUncovered;
				}
				totalCoverage = totalCovered / (totalCovered + totalUncovered) * 100;
			}
			return totalCoverage;
		}
	}

	public List<TestResultWrapper> content { set; get; }
	public List<TestResultWrapper> extendedContent { set; get; }

	public TestingResultsController() {
		rerenderMainData();
		rerenderExtendedData();
	}

	public void rerenderMainData() {
		String objectIdQuery = 'SELECT Id, ApexClassOrTriggerId, ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered, Coverage FROM ApexCodeCoverageAggregate';
		String environmentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/tooling/query/?q=' + EncodingUtil.urlEncode(objectIdQuery, 'UTF-8');
		HttpRequest req = new HttpRequest();
		req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
		req.setHeader('Content-Type', 'application/json');
		req.setEndpoint(environmentURL);
		req.setMethod('GET');
		Http h = new Http();
		HTTPResponse response = h.send(req);
		String body = response.getBody();
		content = new List<TestResultWrapper>();
		JSONParser parser = JSON.createParser(body);
		while (parser.nextToken() != null) {
			if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'Name') {
				TestResultWrapper trw = new TestResultWrapper();
				parser.nextToken(); trw.name = parser.getText();
				classesAndTriggers.add(new SelectOption(parser.getText(), parser.getText()));
				while(parser.getCurrentToken() != JSONToken.FIELD_NAME || parser.getText() != 'NumLinesCovered') parser.nextToken();
				parser.nextToken(); trw.linesCovered = Double.valueOf(parser.getText());
				while(parser.getCurrentToken() != JSONToken.FIELD_NAME || parser.getText() != 'NumLinesUncovered') parser.nextToken();
				parser.nextToken(); trw.linesUncovered = Double.valueOf(parser.getText());
				content.add(trw);
			}
		}
		classesAndTriggers.sort();
		if(!classesAndTriggers.isEmpty()) selectedClass=classesAndTriggers[0].getValue();
	}

	public void rerenderExtendedData() {
		extendedContent = new List<TestResultWrapper>();
		if(selectedClass != null) {
			String objectIdQuery = 'SELECT ApexTestClass.Name,TestMethodName,NumLinesCovered,NumLinesUncovered FROM ApexCodeCoverage WHERE ApexClassOrTrigger.Name = \'' + selectedClass + '\'';
			String environmentURL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v33.0/tooling/query/?q=' + EncodingUtil.urlEncode(objectIdQuery, 'UTF-8');
			HttpRequest req = new HttpRequest();
			req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
			req.setHeader('Content-Type', 'application/json');
			req.setEndpoint(environmentURL);
			req.setMethod('GET');
			Http h = new Http();
			JSONParser parser = JSON.createParser(h.send(req).getBody());
			while (parser.nextToken() != null) {
				if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'Name') {
					TestResultWrapper trw = new TestResultWrapper();
					parser.nextToken(); trw.name = parser.getText() + '.';
					while(parser.getCurrentToken() != JSONToken.FIELD_NAME || parser.getText() != 'TestMethodName') parser.nextToken();
					parser.nextToken(); trw.name += parser.getText();
					while(parser.getCurrentToken() != JSONToken.FIELD_NAME || parser.getText() != 'NumLinesCovered') parser.nextToken();
					parser.nextToken(); trw.linesCovered = Double.valueOf(parser.getText());
					while(parser.getCurrentToken() != JSONToken.FIELD_NAME || parser.getText() != 'NumLinesUncovered') parser.nextToken();
					parser.nextToken(); trw.linesUncovered = Double.valueOf(parser.getText());
					extendedContent.add(trw);
				}
			}
		}
	}
}