@isTest
private class TestSearchForDocumentContExt {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 2;
    private static final Integer NUMBER_TO_CREATE_STORED_DOCUMENT = 3;

    private static List<Account> testAccountList;
    private static List<LStore__Stored_Document__c> testStoredDocumentList;

    private static ApexPages.StandardController testController;
    private static SearchForDocumentContExt testSearchForDocumentContExt;

    private static void initController(){
        Test.setCurrentPageReference(Page.SearchForDocument);
        testSearchForDocumentContExt = new SearchForDocumentContExt();
    }

    private static testMethod void testCoverageProperties() {
        initController();

        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testStoredDocumentList = new List<LStore__Stored_Document__c>();
        for (Account accountItem : testAccountList){
            for (LStore__Stored_Document__c storedDocumentItem : TestingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE_STORED_DOCUMENT, accountItem.Id, false)){
                testStoredDocumentList.add(storedDocumentItem);
            }
        }
        testStoredDocumentList[0].Drawings_Title__c = 'test drawings title';
        insert testStoredDocumentList;

        Test.startTest();
            LStore__Stored_Document__c test1 = testSearchForDocumentContExt.lstoreStoredDocumenFilter;
            List<LStore__Stored_Document__c> test3 = testSearchForDocumentContExt.lstoreStoredDocumenResults;

            sortExtension test8 = testSearchForDocumentContExt.sortAssignmentExtension;
            testSearchForDocumentContExt.lstoreStoredDocumenFilter.Drawings_Title__c = testStoredDocumentList[0].Drawings_Title__c;
            testSearchForDocumentContExt.searchAction();
            testSearchForDocumentContExt.createStoredDocumenItemList();
            testSearchForDocumentContExt.sortAction();
            testSearchForDocumentContExt.getStoredDocumenFromDB();
            List<SelectOption> test9 = testSearchForDocumentContExt.getTypeDocument();
            Boolean testBool;
            testBool = testSearchForDocumentContExt.hasNext;
            testBool = testSearchForDocumentContExt.hasPrevious;
            Integer test13 = testSearchForDocumentContExt.pageNumber;
            testSearchForDocumentContExt.previous();
            testSearchForDocumentContExt.next();
            String testString;
            testString = testSearchForDocumentContExt.getAdditionalDocuments;
            testString = testSearchForDocumentContExt.getGeneratedForms;
            testString = testSearchForDocumentContExt.getProposals;
            testString = testSearchForDocumentContExt.getDrawings;
            testString = testSearchForDocumentContExt.getAccountingDocuments;
            testString = testSearchForDocumentContExt.getOther;
            testBool = testSearchForDocumentContExt.isLegacyDocument;
            testBool = testSearchForDocumentContExt.isDepositInvoiceDocument;
            testBool = testSearchForDocumentContExt.isAccountSummaryRecapReportDocument;
            testBool = testSearchForDocumentContExt.isStatementsOfAccountsDocument;
            testBool = testSearchForDocumentContExt.isUploadSection;
            testBool = testSearchForDocumentContExt.isFinancialUser;
            testBool = testSearchForDocumentContExt.isProposalSpecialistUser;
            system.assert(testSearchForDocumentContExt != null);
            List<SelectOption> selectOptionList;
            selectOptionList = testSearchForDocumentContExt.regionNameOptions;
            selectOptionList = testSearchForDocumentContExt.proposalStatusOptions;
            selectOptionList = testSearchForDocumentContExt.getArtifactsCategory();
        Test.stopTest();
    }

    private static testmethod void testGetTypeGeneratedDocument(){
        initController();

        List<SelectOption> selectOptionList;

        Test.startTest();

            selectOptionList = testSearchForDocumentContExt.getTypeGeneratedDocument();

        Test.stopTest();
    }

    private static testmethod void testGetDocumentTypeOptions(){
        initController();

        List<SelectOption> selectOptionList;

        Test.startTest();

            //get Document types for Proposal
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Proposal__c.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Pro forma Invocie
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Account
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Account.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Project Profile
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Project_Profile__c.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Deposit Invoice
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Deposit_Invoice__c.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Legacy Pro forma Invocie
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = Schema.SObjectType.Legacy_Pro_forma_Invoice__c.getKeyPrefix();
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

            //get Document types for Other
            testSearchForDocumentContExt.filterFields.typeObjectKeyPrefix = null;
            selectOptionList = testSearchForDocumentContExt.getDocumentTypeOptions();

        Test.stopTest();
    }

    private static testmethod void testClearFilter(){
        initController();

        Test.startTest();

            testSearchForDocumentContExt.clearFilter();

        Test.stopTest();
    }

    private static testmethod void testOpenPDF(){
        initController();

        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testStoredDocumentList = new List<LStore__Stored_Document__c>();
        for (Account accountItem : testAccountList){
            for (LStore__Stored_Document__c storedDocumentItem : TestingUtils.createLStoreStoredDocumentList(NUMBER_TO_CREATE_STORED_DOCUMENT, accountItem.Id, false)){
                testStoredDocumentList.add(storedDocumentItem);
            }
        }
        insert testStoredDocumentList;

        ApexPages.currentPage().getParameters().put('selectedId', testStoredDocumentList[0].Id);
        ApexPages.currentPage().getParameters().put('relatedId', testStoredDocumentList[0].LStore__Related_Object_Id__c);

        Test.startTest();

            testSearchForDocumentContExt.openPDF();

        Test.stopTest();
    }
}