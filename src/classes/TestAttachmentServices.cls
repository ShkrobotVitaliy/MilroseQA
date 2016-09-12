@isTest
private class TestAttachmentServices {
    private static final Integer NUMBER_TO_CREATE = 5;   
    private static User projectManagerUser;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Proposal__c> testProposalList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Attachment> testAttachmentList;
    private static List<dsfs__DocuSign_Status__c> testDocuSignList;
    private static List<Task> testTaskList;
    
    private static void setUp(){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        TestingUtils.createProposalWithProjectProfileList(1);
        testProjectProfileList = TestingUtils.testProjectProfileList;
        testProposalList = TestingUtils.testProposalList;

        testChangeOrderList = TestingUtils.createChangeOrderList(1, true);

        testDocuSignList = TestingUtils.createDocuSignStatusList(2, false);
        testDocuSignList[0].Change_Order_Docusign_Status__c = testChangeOrderList[0].Id;
        testDocuSignList[1].Proposal_Docusign_Status__c = testProposalList[0].Id;
        insert testDocuSignList;

        testAttachmentList = new List<Attachment>();
        for (dsfs__DocuSign_Status__c dssItem : testDocuSignList){
            for (Attachment att : TestingUtils.createAttachmentList(1, dssItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.';
                testAttachmentList.add(att);
            }
            for (Attachment att : TestingUtils.createAttachmentList(1, dssItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_OLD + '.';
                testAttachmentList.add(att);
            }
        }
        for (Proposal__c proposalItem : testProposalList){
            for (Attachment att : TestingUtils.createAttachmentList(1, proposalItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.';
                testAttachmentList.add(att);
            }
            for (Attachment att : TestingUtils.createAttachmentList(1, proposalItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_OLD + '.';
                testAttachmentList.add(att);
            }
        }
        for (Change_Order__c coItem : testChangeOrderList){
            for (Attachment att : TestingUtils.createAttachmentList(1, coItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_OLD + '.';
                testAttachmentList.add(att);
            }
            for (Attachment att : TestingUtils.createAttachmentList(1, coItem.Id, null, null, false, false)){
                att.Name = StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_OLD + '.';
                testAttachmentList.add(att);
            }
        }
        insert testAttachmentList;
    }

    @isTest
    private static void testItemsRelatedToAttach(){
        
        Test.startTest();
            List<SelectOption> itemsRelatedToAttach = AttachmentServices.getItemsRelatedToAttach();
            AttachmentServices.setItemsRelatedToAttach(new SelectOption('Project', 'Project'));
            
            System.assert(! itemsRelatedToAttach.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    private static void testGetDocumentIds(){
        setUp();
        AttachmentServices.setDocumentIds(testProjectProfileList[0].Id);
        
        Test.startTest();
            Set<Id> documentIds = AttachmentServices.getDocumentIds();
            System.assert(documentIds.contains(testProjectProfileList[0].Id));
        Test.stopTest();
    }
    
    @isTest
    private static void testAttachmentParentIds(){
        setUp();
        AttachmentServices.setDocumentIds(testProjectProfileList[0].Id);  

        Test.startTest();
            String testAttachmentParentIds = AttachmentServices.attachmentParentIds;
            System.assert(testAttachmentParentIds.contains(testProjectProfileList[0].Id));
        Test.stopTest();
    }
    
    @isTest
    private static void testGetObjectName(){
        setUp();
        
        Test.startTest();
            String testObjectName = AttachmentServices.getObjectName(testProjectProfileList[0].Id);
            System.assert(testObjectName == Project_Profile__c.sobJectType.getDescribe().getLabel());
        Test.stopTest();
    }
    
    @isTest
    private static void testGetObjectNameException(){
        setUp();
        
        Test.startTest();
            try{
                String testObjectName = AttachmentServices.getObjectName(null);
                System.assert(testObjectName == null);
            }catch(ErrorException e){
                String testStringException = String.valueOf(e);
            }
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage(){
        setUp();
        Map<Id, List<Id>> parentIdToAttachmentNames = new Map<Id, List<Id>>();
        for (Attachment att : testAttachmentList){
            if (!parentIdToAttachmentNames.containsKey(att.ParentId))parentIdToAttachmentNames.put(att.ParentId, new List<Id>());
            parentIdToAttachmentNames.get(att.ParentId).add(att.Id);
        }

        Test.startTest();
            AttachmentServices.moveAttachmentsToStoredDocuments(parentIdToAttachmentNames);
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage1(){
        testTaskList = TestingUtils.createTaskList(1, true);

        testAttachmentList = new List<Attachment>();
        for (Task taskItem : testTaskList){
            for (Attachment att : TestingUtils.createAttachmentList(1, taskItem.Id, null, null, false, false)){
                testAttachmentList.add(att);
            }
        }
        insert testAttachmentList;

        Test.startTest();
            Boolean testBool = AttachmentServices.findAttachmentsForTasks(testTaskList) == null;
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage2(){
        setUp();

        Test.startTest();
            AttachmentServices.filterSignedAttachmentsForRenaming(testAttachmentList);
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage3(){
        setUp();

        Test.startTest();
            AttachmentServices.renameSignedAttachments(testAttachmentList);
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage4(){
        setUp();
        Map<Id, Set<String>> parentIdToAttachmentNames = new Map<Id,  Set<String>>();
        for (Attachment att : testAttachmentList){
            if (!parentIdToAttachmentNames.containsKey(att.ParentId))parentIdToAttachmentNames.put(att.ParentId, new Set<String>());
            parentIdToAttachmentNames.get(att.ParentId).add(String.valueOf(att.Id));
        }

        Test.startTest();
            AttachmentServices.deleteAttachmentsByName(parentIdToAttachmentNames);
        Test.stopTest();
    }

    @isTest
    private static void testForCoverage5(){
        setUp();
        List<Id> attachmentListId = new List<Id>();
        for (Attachment att : testAttachmentList){
            attachmentListId.add(att.Id);
        }

        Test.startTest();
            AttachmentServices.deleteUnneededAttachments(attachmentListId);
        Test.stopTest();
    }
}