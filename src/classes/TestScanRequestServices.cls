@isTest
private class TestScanRequestServices {

    private static testMethod void testPopulateFields() {
        Proposal__c proposal = new Proposal__c( Is_Draft__c = true );
        INSERT proposal;
        Scan_Request__c request = new Scan_Request__c( Proposal__c = proposal.Id );
        INSERT request;
        Task_Item__c taskItem = TestingUtils.createTaskItemList( 1, true )[0];
        Project_Profile__c project = TestingUtils.createProjectProfileForTest( 1, true )[0];
        Service_Item__c serviceItem = TestingUtils.createServiceItemList( 1, proposal.Id, true )[0];
        Pro_forma_Invoice__c invoice = new Pro_forma_Invoice__c();
        invoice.Billing_Client_Company__c = TestingUtils.createAccountList ( 1, null, true)[0].Id;
        Contact billingContact = TestingUtils.createContactList ( 1, false)[0];
        billingContact.AccountId = invoice.Billing_Client_Company__c;
        INSERT billingContact;
        invoice.Billing_Contact__c = billingContact.Id;
        invoice.Project_Address__c = TestingUtils.createBuildingList (1, null, null, null, null, null, true)[0].Id;
        INSERT invoice;
        Legacy_Pro_forma_Invoice__c legacyInvoice = TestingUtils.createLegacyProFormaInvoiceList ( 1, true )[0];

        Test.startTest();
            List<Scan_Request__c> requests = [ SELECT Id, Related_Object_Id__c FROM Scan_Request__c WHERE Proposal__c = : proposal.Id ];
            System.assert( requests.size() == 1 );
            System.assert( requests[0].Related_Object_Id__c == String.valueOf( proposal.Id ) );
            try {
                ScanRequestServices.isUniqueScanRequest( null ); 
            } catch ( Exception ex ) {}
            ScanRequestServices.isUniqueScanRequest( 'test string' );
            List<Scan_Request__c> getScanRequestsByTaskItemId1 = ScanRequestServices.getScanRequestsByTaskItemId( taskItem.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByTaskItemId2 = ScanRequestServices.getScanRequestsByTaskItemId( taskItem.Id, null );
            List<Scan_Request__c> getScanRequestsByServiceItemId1 = ScanRequestServices.getScanRequestsByServiceItemId( serviceItem.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByServiceItemId2 = ScanRequestServices.getScanRequestsByServiceItemId( serviceItem.Id, null );
            List<Scan_Request__c> getScanRequestsByProjectId1 = ScanRequestServices.getScanRequestsByProjectId( project.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByProjectId2 = ScanRequestServices.getScanRequestsByProjectId( project.Id, null );
            List<Scan_Request__c> getScanRequestsByProposalId1 = ScanRequestServices.getScanRequestsByProposalId( proposal.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByProposalId2 = ScanRequestServices.getScanRequestsByProposalId( proposal.Id, null );
            List<Scan_Request__c> getScanRequestsByProformaId1 = ScanRequestServices.getScanRequestsByProformaId( invoice.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByProformaId2 = ScanRequestServices.getScanRequestsByProformaId( invoice.Id, null );
            List<Scan_Request__c> getScanRequestsByLegacyProformaId1 = ScanRequestServices.getScanRequestsByLegacyProformaId( legacyInvoice.Id, 'test_file_type' );
            List<Scan_Request__c> getScanRequestsByLegacyProformaId2 = ScanRequestServices.getScanRequestsByLegacyProformaId( legacyInvoice.Id, 'test_file_type' );
            try {
                ScanRequestServices.insertScanRequest( request );
            } catch ( Exception ex ) {}
            request = new Scan_Request__c( Proposal__c = proposal.Id, Artifact_Name__c = 'test_artifact_name');
            ScanRequestServices.insertScanRequest( request );
            request.Task_Item__c = taskItem.Id;
            request.Service_Item__c  = serviceItem.Id;
            request.Pro_forma_Invoice__c  = invoice.Id;
            request.Legacy_Pro_forma_Invoice__c  = legacyInvoice.Id;
            request.Proposal__c  = proposal.Id;
            request.Project__c  = null;
            Scan_Request__c request2 = new Scan_Request__c( Id = request.Id, Task_Item__c = taskItem.Id, Service_Item__c  = serviceItem.Id, Pro_forma_Invoice__c  = invoice.Id,
                                                        Legacy_Pro_forma_Invoice__c  = legacyInvoice.Id, Proposal__c  = proposal.Id, Project__c  = project.Id );

            List<Scan_Request__c> filterScanRequestsForRelatedObjectIdPopulation = ScanRequestServices.filterScanRequestsForRelatedObjectIdPopulation(new List<Scan_Request__c> { request },
                                                                                                                                new Map<Id, Scan_Request__c> { request2.Id => request2 } );
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Task_Item__c  = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Service_Item__c = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Pro_forma_Invoice__c = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Legacy_Pro_forma_Invoice__c = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Proposal__c = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            request2.Project__c = null;
            ScanRequestServices.populateRelatedObjectId( new List<Scan_Request__c> { request2 } );
            ScanRequestServices.copyFieldsFromScanRequest( new List<LStore__Stored_Document__c> { new LStore__Stored_Document__c( Scan_Request_Id__c = request.Id ) } );          
        Test.stopTest();
    }

}