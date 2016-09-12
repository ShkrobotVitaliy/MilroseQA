@isTest
global class TestDocusignServices implements HttpCalloutMock {
	
	global HTTPResponse respond( HTTPRequest req ) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(200);
        return res;
    }

	@isTest static void test_method_one() {
		Test.setMock( HttpCalloutMock.class, new TestDocusignServices() );
		Test.startTest();
			String docusignStatusPrefix = DocusignServices.docusignStatusPrefix;
			DocusignServices.voidEnvelopes( new Map<String, String> { 'test' => 'test'}, new Map<String, String> { 'test' => 'test' } );
			DocusignServices.resendEnvelopes( new Set<String> {'test'} );
			Map<String, Object> getEnvelopeNotifications = DocusignServices.getEnvelopeNotifications( 'envelopID' );
			DocusignServices.setEnvelopeNotifications( 'envelopID' );
			List<String> getEnvelopesFromDocusignStatusesForObject1 = DocusignServices.getEnvelopesFromDocusignStatusesForObject( (sObject) new Proposal__c() );
			List<String> getEnvelopesFromDocusignStatusesForObject2 = DocusignServices.getEnvelopesFromDocusignStatusesForObject( (sObject) new Proposal__c(), (sObject) new Change_Order__c() );
			Map<String, String> getEnvelopesFromDocusignStatusesForObjects = DocusignServices.getEnvelopesFromDocusignStatusesForObjects( new List<sObject> { (sObject) new Proposal__c(),
																																							  	(sObject) new Change_Order__c() } );
			Proposal__c proposal = TestingUtils.createProposalListForTest( 1, true )[0];
			Change_Order__c cO = TestingUtils.createChangeOrderList ( 1, true )[0];
			Map<String, String> getEnvelopeVoidReasons1 = DocusignServices.getEnvelopeVoidReasons( new List<sObject> { (sObject) proposal }, new Map<Id, sObject> { proposal.Id => (sObject) proposal } );
			Map<String, String> getEnvelopeVoidReasons2 = DocusignServices.getEnvelopeVoidReasons( new List<sObject> { (sObject) cO }, new Map<Id, sObject> { cO.Id => (sObject) cO } );
			List<dsfs__DocuSign_Status__c> filterCompletedDocusignStatuses = DocusignServices.filterCompletedDocusignStatuses( new List<dsfs__DocuSign_Status__c> {new dsfs__DocuSign_Status__c()}, 
																												new Map<Id, dsfs__DocuSign_Status__c> { proposal.Id => new dsfs__DocuSign_Status__c() } );
			List<dsfs__DocuSign_Status__c> filterDocusignStatusesToRemoveReminders = DocusignServices.filterDocusignStatusesToRemoveReminders( new List<dsfs__DocuSign_Status__c> {new dsfs__DocuSign_Status__c()}, 
																												new Map<Id, dsfs__DocuSign_Status__c> { proposal.Id => new dsfs__DocuSign_Status__c() } );
			DocusignServices.setEsignedFlagOnProposalOrChangeOrder( new List<dsfs__DocuSign_Status__c> { new dsfs__DocuSign_Status__c()} );
			DocusignServices.removeUnfinishedFollowUpReminders ( new List<dsfs__DocuSign_Status__c> { new dsfs__DocuSign_Status__c()} );

		Test.stopTest();
	}
	
}