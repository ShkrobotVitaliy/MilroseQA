@isTest
private class TestStoredDocContExt {

    private static ApexPages.StandardController testController;
    private static StoredDocContExt testStoredDocContExt;

    @isTest static void testUncoveredParts() {
        Project_Profile__c project = TestingUtils.createProjectProfileForTest( 1, false )[0];
        INSERT project;

        Profile p = [SELECT Id FROM Profile WHERE Name = :UserServices.PROFILE_CODE_ZONING_ANALYST LIMIT 1];
        User userCZAnalyst = new User(Alias = 'newUser', Email='n1e1w1u1s1e1r@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                                                                                                            TimeZoneSidKey='America/Los_Angeles', UserName='n1e1w1u1s1e1r@testorg.com');
        p = [SELECT Id FROM Profile WHERE Name = :UserServices.SUPPORT_STAFF LIMIT 1];
        User userSupportStaff = new User(Alias = 'newUser1', Email='newuser1SupportStaff@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                                                                                                            TimeZoneSidKey='America/Los_Angeles', UserName='newuser1SupportStaff@testorg.com');
        INSERT userCZAnalyst;
        INSERT userSupportStaff;

        Task_Item__c taskItem = TestingUtils.createTaskItemList( 1, true)[0];

        Contact testContact = TestingUtils.createContactList( 1, true)[0];

        Account testAccount = TestingUtils.createAccountList( 1, 'testAccount', true)[0]; 

        Id userProjectRosterRecordTypeId;
        for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
            if (schemaRecordTypeInfoItem.getName() == 'User'){ userProjectRosterRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId(); }
        }
        List<Project_Roster__c> rosterList = TestingUtils.createProjectRosterList (5, false);
        for(Project_Roster__c pr : rosterList) {
            pr.Contact__c = testContact.Id;
            pr.Project_Profile__c = project.Id;
            pr.User__c = userCZAnalyst.Id;
            pr.User_Type__c = 'Internal';
            pr.User_Contact__c = 'User';
            pr.RecordTypeId = userProjectRosterRecordTypeId;
        }
        INSERT rosterList;

        Test.setCurrentPageReference(Page.StoredDocsInlineProjectProfile);
        ApexPages.currentPage().getParameters().put('relatedObjectId', project.Id);
        ApexPages.StandardController stdController = new ApexPages.StandardController( project );
        StoredDocContExt contExt = new StoredDocContExt( stdController );

        Date drawingsRevisionDate = contExt.drawingsRevisionDate;
        Boolean isShowMeaageForScanRequest = contExt.isShowMeaageForScanRequest;

        Scan_Request__c scanRequestDrawings = contExt.scanRequestDrawings;
        List<Scan_Request__c> scanDocumentRequests = contExt.scanDocumentRequests;
        List<Scan_Request__c> scanDrawingsRequests = contExt.scanDrawingsRequests;
        System.runAs( userCZAnalyst ) {
            Boolean isRestrictArtifactsVisibility = contExt.isRestrictArtifactsVisibility;
        }
        System.runAs( userSupportStaff ) {
            Boolean getIsAllowedToUploadDocsOnBuilding = contExt.getIsAllowedToUploadDocsOnBuilding();
        }

        Boolean isUserInRosterForProjectAndProposal = contExt.isUserInRosterForProjectAndProposal();
        Boolean getEnableViewProposalFolderForPM = contExt.getEnableViewProposalFolderForPM();
        String proposalDocumentsFolderName = contExt.proposalDocumentsFolderName;
        List<SelectOption> getWorkType = contExt.getWorkType;
        String roleName = contExt.roleName;
        List<SelectOption> scanRequestAuthors = contExt.scanRequestAuthors;
        contExt.createScanRequest();
        contExt.setFolderDocName('FOLDER_TO_SCAN');
        contExt.createScanRequest();
        contExt.setFolderDocName( StoredDocumentServices.DOCUMENTS_FILE_TYPE );
        contExt.createScanRequest();
        contExt.setFolderDocName( StoredDocumentServices.DRAWINGS_FILE_TYPE );
        contExt.createScanRequest();
        Scan_Request__c scanRequest = new Scan_Request__c();
        INSERT scanRequest;
        contExt.preparateScanRequest( scanRequest, 'Document' );
        contExt.scanRequest();
        contExt.cancelScanRequest();
        Id parentObjectId = contExt.parentObjectId;
        Map<Id, List<String>> documentOwners = contExt.documentOwners;
        String getFolderDocName = contExt.getFolderDocName();
        contExt.setFolderDocId( null );

        contExt.projectProfile = null;
        contExt.taskItem = taskItem;
        Boolean  test1 = contExt.projectProfileIsProjectManager;

        contExt.authorSelect = userCZAnalyst.Id;
        contExt.setAuthorSelect();
        contExt.authorSelect = testContact.Id;
        contExt.setAuthorSelect();
        contExt.authorSelect = testAccount.Id;
        contExt.setAuthorSelect();
    }

    private static testMethod void testStoredDocContExt() {

        Test.setCurrentPageReference(Page.StoredDocsInlineProjectProfile);
        ApexPages.currentPage().getParameters().put('relatedObjectId', TestingUtils.createProjectProfileList(1, null, null, null, null, null, null, null, true)[0].Id);
        testController = new ApexPages.StandardController( TestingUtils.createProjectProfileList(1, null, null, null, null, null, null, null, true)[0] );

        Profile p = [SELECT Id FROM Profile WHERE Name = :UserServices.PROFILE_CODE_ZONING_ANALYST];
        User userCZAnalyst = new User(Alias = 'newUser2', Email='n2e2w2u2s2e2r@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                                                                                                            TimeZoneSidKey='America/Los_Angeles', UserName='n2e2w2u2s2e2r@testorg.com');
        INSERT userCZAnalyst;

        p = [SELECT Id FROM Profile WHERE Name = :UserServices.PROFILE_PROPOSAL_SPECIALIST];
        User userPS = new User(Alias = 'newUser3', Email='n3e3w3u3s3e3r@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                                                                                                            TimeZoneSidKey='America/Los_Angeles', UserName='n3e3w3u3s3e3r@testorg.com');
        INSERT userPS;

        Test.startTest();
            testStoredDocContExt = new StoredDocContExt(testController);
            testStoredDocContExt.relatedId = TestingUtils.createProjectProfileList(1, null, null, null, null, null, null, null, true)[0].Id;
            System.runAs( userCZAnalyst ) {
                Boolean  test1 = testStoredDocContExt.projectProfileIsProjectManager;
            }
            System.runAs( userPS ) {
                Boolean  test1 = testStoredDocContExt.projectProfileIsProjectManager;
            }
            Boolean test11 = testStoredDocContExt.isLStoreDocIdByDatetimeMap;
            LStore__Stored_Document__c  test2 = testStoredDocContExt.lStoreDocumentSObject;
            testStoredDocContExt.relatedId = TestingUtils.createProposalListForTest( 1, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createProjectProfileForTest( 1, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createServiceItemList(1, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createTaskItemList(1, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createRFIScopeList( 1, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createPurchaseOrderList(1, Date.today(), true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.relatedId = TestingUtils.createBuildingList (1, null, null, null, null, null, true)[0].Id;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.saveOtherFieldAction();
            testStoredDocContExt.setFieldsByObjectAction();
            testStoredDocContExt.relatedId = null;

        Test.stopTest();

    }
    
    private static testMethod void testStoredDocContExt1() {

        Test.setCurrentPageReference(Page.StoredDocsInlineProjectProfile);
        ApexPages.currentPage().getParameters().put('relatedObjectId', TestingUtils.createServiceItemList(1, true)[0].Id);
        testController = new ApexPages.StandardController( TestingUtils.createServiceItemList(1, true)[0] );

        Test.startTest();
            testStoredDocContExt = new StoredDocContExt(testController);
            testStoredDocContExt.relatedId = TestingUtils.createServiceItemList(1, true)[0].Id;
            Boolean  test1 = testStoredDocContExt.projectProfileIsProjectManager;
            Boolean test11 = testStoredDocContExt.isLStoreDocIdByDatetimeMap;
            LStore__Stored_Document__c  test2 = testStoredDocContExt.lStoreDocumentSObject;
            testStoredDocContExt.getFieldsByObject();
            testStoredDocContExt.getFieldsByProposal();
            testStoredDocContExt.getFieldsByBuilding();            
            
        Test.stopTest();

    }
}