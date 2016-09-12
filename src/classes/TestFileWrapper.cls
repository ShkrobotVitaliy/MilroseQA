@isTest
private class TestFileWrapper {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static LStore__Stored_Document__c testStoreDoc;
    private static String relateTo = 'ToTest';
    private static FileWrapper testFileWrp;
    private static void setUp(){
        testStoreDoc = TestingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE, false)[0];
        testStoreDoc.LStore__External_Id__c = UserInfo.getUserId();
        insert testStoreDoc;
    }
    
    private static testMethod void testFileWrapper(){
        setUp();
        
        Test.startTest();
            testFileWrp = new FileWrapper(testStoreDoc);
            String externalURL = testFileWrp.externalURL;

            System.assert(! String.isBlank(externalURL) );

        Test.stopTest();    
    }
    
    private static testMethod void testFileWrapperSecond(){
        setUp();
        
        Test.startTest();
            testFileWrp = new FileWrapper(testStoreDoc,relateTo);
        Test.stopTest();    

        System.assert(! testFileWrp.isSelect );
    }
}