@isTest
private class TestStoreDocProposalForProjectCont {

    private static ApexPages.StandardController testController;
    private static StoreDocProposalForProjectCont testStoreDocProposalForProjectCont;

    @isTest(seeAllData = false) private static void testGetStoreDocuments() { 
    
       Test.setCurrentPageReference(Page.ManageReview);
       List<Project_Profile__c> projectProfileList = TestingUtils.CreateProjectProfileForTest(1, true);
       
       testController = new ApexPages.StandardController( projectProfileList[0] );
            
       List<LStore__Stored_Document__c> lStoreDocumentList = TestingUtils.createLStoreStoredDocumentList(1, false);
       lStoreDocumentList[0].LStore__Related_Object_Id__c = projectProfileList[0].Id;
       insert lStoreDocumentList;
       
       Test.startTest();
           testStoreDocProposalForProjectCont = New StoreDocProposalForProjectCont(testController);
       Test.stopTest();           
    }
    
}