@isTest
private class TestStoredDocumentServices {
    private static final Integer NUMBER_TO_CREATE = 5 ;
    private static List<LStore__Stored_Document__c> testStoredDocList;
    private static List<RFI_Scope__c> testRFIScopeList;
    private static Region__c testRegion;
    private static Project_Roster__c testProjectRoster;
    private static Account testAccount;
    private static Contact testContact;
    private static Id teRecordTypeId;
    private static String relatedObjectIdString = 'a37K0000000DDg1IAG';
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId; 
    private static List<Proposal__c> testProposalList;
    private static List<Building__c> testBuildingList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static Project_Profile__c testProjectProfile;
    private static Service_Item__c testServiceItem;
    private static Task_Item__c testTaskItem;
    
    private static void setUp(){
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProjectRoster = TestingUtils.createProjectRosterList(NUMBER_TO_CREATE, false)[0];
            testProjectRoster.Contact__c = testContact.Id;
            insert testProjectRoster;
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, 'TestRegion', true)[0];
        testRFIScopeList = TestingUtils.createRFI_ScopeList(NUMBER_TO_CREATE, testRegion.Id, true);     
    }
    
    private static void createDocList(String relatedObject, Boolean doInsert){
        testStoredDocList = TestingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE, false);   
        teRecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID;
        for(LStore__Stored_Document__c item : testStoredDocList){
            item.LStore__File_Name__c = 'TestStorageName';
            item.RecordTypeId = teRecordTypeId;
            item.LStore__Related_Object_Id__c =  relatedObject;
            item.LStore__Keywords__c = 'TestStorageName';
        }
        if(doInsert){
            insert testStoredDocList;
        }
        
    }
    
    private static void insertAdditionalData(){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE, null, testAccount.Id, testContact.Id,
                                                            testAccount.Id, testContact.Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, true);
        testProjectProfile = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true)[0];                                                    
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true)[0];
        testTaskItem = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, testServiceItem.Id, testProjectProfile.Id, true)[0];                                                            
        
    }
    private static testMethod void testAllIds(){
        setUp();
        insertAdditionalData();
        System.debug(LoggingLevel.Error,'@@@Schema.SObjectType.Proposal__c.getKeyPrefix()' + Schema.SObjectType.Proposal__c.getKeyPrefix());
        Test.startTest();
            Id folderId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID;
            Id recordId = StoredDocumentServices.FORMS_RECORD_TYPE_ID;
            Id documentId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
            Id drawingId = StoredDocumentServices.DRAWINGS_RECORD_TYPE_ID;          
        Test.stopTest();
    }
    private static testMethod void testGetStoredDocumentFolder(){
        setUp();
        createDocList(relatedObjectIdString, true);
                
        Test.startTest();
            List<LStore__Stored_Document__c> getStoredDocumentFolder = StoredDocumentServices.getStoredDocumentFolder(teRecordTypeId, 'TestStorageName', 'a37K0000000DDg1IAG');
        Test.stopTest();
    }
    
    private static testMethod void testGetStoredDocumentList(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            List<LStore__Stored_Document__c> getStoredDocumentFolder = StoredDocumentServices.getStoredDocumentList(Id.valueOf('a37K0000000DDg1IAG'));
        Test.stopTest();
    }
    
    private static testMethod void testUpdateName(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        for(LStore__Stored_Document__c item : testStoredDocList){
            item.RecordTypeId = teRecordTypeId;
        }
            insert testStoredDocList;
            
        Test.startTest();
            StoredDocumentServices.updateName(testStoredDocList);
        Test.stopTest();
    }
    
    private static testMethod void testFilterStoredDocuments(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            StoredDocumentServices.filterStoredDocuments(testStoredDocList);
        Test.stopTest();
    }
    
    private static testMethod void testPopulateRequiredFields(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DRAWINGS_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);    
        for(LStore__Stored_Document__c item : testStoredDocList){
            item.RecordTypeId = teRecordTypeId;
        }
            insert testStoredDocList;   
        Map<String, List<LStore__Stored_Document__c>> groupedDocumentsByTypes = new  Map<String, List<LStore__Stored_Document__c>> ();
            groupedDocumentsByTypes.put(StoredDocumentServices.DRAWINGS_FILE_TYPE,testStoredDocList);   
        
        Test.startTest();
            StoredDocumentServices.populateRequiredFields(groupedDocumentsByTypes);
        Test.stopTest();
    }
    
    private static testMethod void testGetStoredDocumentByRelatedId(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            StoredDocumentServices.getStoredDocumentByRelatedId(testStoredDocList[0].Id);
        Test.stopTest();
    }
    
    private static testMethod void testGetStoredDocumentByRelatedIds(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            List<LStore__Stored_Document__c> storedDocuments = StoredDocumentServices.getStoredDocumentByRelatedIds(null);
            StoredDocumentServices.getStoredDocumentByRelatedIds(new Set<Id>{testStoredDocList[0].Id});
        Test.stopTest();
    }
    
    private static testMethod void testBuildWhereQueryTitle(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        FilterFields filterFields = new FilterFields();
        testStoredDocList[0].Drawings_Title__c = 'TestTitle';
            insert testStoredDocList;
            
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereQueryAuthor(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        FilterFields filterFields = new FilterFields();
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereQueryPurchaseOrder(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        FilterFields filterFields = new FilterFields();
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereQueryKeyWords(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].LStore__Keywords__c = 'TestKeyWords';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereQueryWorkType(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Worktype__c = 'TestWorkType';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereQueryNumber(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Drawing_Number__c = 'TestNumber';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereProposalPrefix(){
        setUp();
        insertAdditionalData();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Artifacts_Category__c = 'TestCategory';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereProjectProfilePrefix(){
        setUp();
        insertAdditionalData();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Artifacts_Category__c = 'TestCategory';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereProjectServiceItemPrefix(){
        setUp();
        insertAdditionalData();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Artifacts_Category__c = 'TestCategory';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildWhereProjectTaskItemPrefix(){
        setUp();
        insertAdditionalData();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Artifacts_Category__c = 'TestCategory';
            insert testStoredDocList;
        FilterFields filterFields = new FilterFields(); 
        Test.startTest();
            String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
        Test.stopTest();    
    }
    
    private static testMethod void testBuildQuery(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, false);
        testStoredDocList[0].Artifacts_Category__c = 'TestCategory';
            insert testStoredDocList;       
        FilterFields filterFields = new FilterFields();
        String whereQuery = StoredDocumentServices.buildWhereQuery(testStoredDocList[0], filterFields);
            
        Test.startTest();       
            StoredDocumentServices.buildQuery(whereQuery, 'Name');
        Test.stopTest();    
    }
    
    private static testMethod void testFilterIfFoldersCreated(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            StoredDocumentServices.filterIfFoldersCreated(new Set<Id>{Id.valueOf(relatedObjectIdString)});
        Test.stopTest();
    }
    
    private static testMethod void testCreateFolders(){
        setUp();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(relatedObjectIdString, true);
        
        Test.startTest();
            StoredDocumentServices.createFolders(new Set<Id>{Id.valueOf(relatedObjectIdString)});
        Test.stopTest();
    }
    
    private static testMethod void testDeleteStoredDocForFormItemAfterNewUpload(){
        setUp();
        insertAdditionalData();
        teRecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
        createDocList(String.valueOf(testServiceItem.Id), true);
        
        Test.startTest();
            StoredDocumentServices.deleteStoredDocForFormItemAfterNewUpload(testStoredDocList);
        Test.stopTest();
    }
    
    
    
}