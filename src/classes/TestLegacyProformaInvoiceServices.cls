@isTest
private class TestLegacyProformaInvoiceServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_PRODUCT_2 = 1;
    private static final Integer NUMBER_TO_CREATE_DIMENSION_1 = 1;
    private static final Integer NUMBER_TO_CREATE_DIMENSION_2 = 1;

    private static List<Legacy_Billing_Item__c> testLegacyBillingItemList;
    private static List<Legacy_Pro_forma_Invoice__c> testLegacyProformaInvoiceList;
    private static List<Project__c> testProjectOldList;
    private static Account testAccount;
    private static Contact testContact;

    private static List<Product2> testProduct2List;
    private static List<c2g__codaDimension1__c> testDimension1List;
    private static List<c2g__codaDimension2__c> testDimension2List;


    private static void prepareDataForTest(){
        testProduct2List = TestingUtils.createProduct2List(NUMBER_TO_CREATE_PRODUCT_2, null, true);
        testDimension1List = TestingUtils.createDimension_1_List(NUMBER_TO_CREATE_DIMENSION_1, true);
        testDimension2List = TestingUtils.createDimension2List(NUMBER_TO_CREATE_DIMENSION_2, null, true);

        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];

        testProjectOldList = TestingUtils.createProjectMI7List(NUMBER_TO_CREATE, null, false);
        for (Project__c projectItem : testProjectOldList){
            projectItem.Billing_Client_Company__c = testAccount.Id;
            projectItem.Billing_Contact_SF__c = testContact.Id;
            projectItem.Sales_Exec_SF__c = testContact.Id;
        }
        insert testProjectOldList;
    }

    private static testMethod void testGenerateLegacyProformaInvoice(){
        prepareDataForTest();
        testLegacyBillingItemList = new List<Legacy_Billing_Item__c>();
        for (Project__c projectItem : testProjectOldList){
            for(Legacy_Billing_Item__c legacyBillingItem : TestingUtils.createLegacyBillingItemList (NUMBER_TO_CREATE, null, null, null, testDimension2List[0].Id,
                                                                                        testProduct2List[0].Id, testDimension1List[0].Id, false)){
                legacyBillingItem.Project_Name_Mi7__c = projectItem.Id;
                testLegacyBillingItemList.add(legacyBillingItem);
            }
        }
        insert testLegacyBillingItemList;

        System.assert(! testLegacyBillingItemList.isEmpty() );

        Test.startTest();
            LegacyProformaInvoiceServices.generateLegacyInvoices(testLegacyBillingItemList);

            try {
                Legacy_Pro_forma_Invoice__c legacyInvoice = new Legacy_Pro_forma_Invoice__c();
                insert legacyInvoice;
                delete legacyInvoice;
            } catch(Exception ex) {}
        Test.stopTest();
    }
    
    private static testMethod void testGetLegacyProformaInvoicesByIdEmptyParameter() {
        Test.startTest();
            List<Legacy_Pro_forma_Invoice__c> invoices = LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(null);
            System.assert( invoices.isEmpty() );
        Test.stopTest();
        
    }
    
    private static testMethod void testGetLegacyProformaInvoicesById() {
        Test.startTest();
            Legacy_Pro_forma_Invoice__c legacyInvoice = new Legacy_Pro_forma_Invoice__c();
            insert legacyInvoice;
            List<Legacy_Pro_forma_Invoice__c> invoices = LegacyProformaInvoiceServices.getLegacyProformaInvoicesById(new Set<Id> { legacyInvoice.Id } );
            
            System.assert(! invoices.isEmpty() );

            LegacyProformaInvoiceServices.unbilledLegacyItemForLegacyInvoices(null);
            LegacyProformaInvoiceServices.generateLegacyInvoices(null);
            
            LegacyProformaInvoiceServices.validationCreateFFACreditNote(new Map<Id, Legacy_Pro_forma_Invoice__c>(), new List<Legacy_Pro_forma_Invoice__c>());
        Test.stopTest();
        
    }

    private static testMethod void testValidationCreateFFACreditNote() {
        prepareDataForTest();
        testLegacyProformaInvoiceList = TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE, false);
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : testLegacyProformaInvoiceList){
            legacyProformaInvoiceItem.cl_Create_FFA_Credit_Note_1__c = false;
            legacyProformaInvoiceItem.cl_Create_FFA_Credit_Note_2__c = false;
        }
        insert testLegacyProformaInvoiceList;

        testLegacyBillingItemList = new List<Legacy_Billing_Item__c>();
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoice : testLegacyProformaInvoiceList){
            for (Legacy_Billing_Item__c legacyBillingItem : TestingUtils.createLegacyBillingItemList (NUMBER_TO_CREATE, null, null, null, testDimension2List[0].Id,
                                                                                                      testProduct2List[0].Id, testDimension1List[0].Id, false)){
                legacyBillingItem.Project_Name_Mi7__c = testProjectOldList[0].Id;
                legacyBillingItem.Legacy_Pro_forma_Invoice__c = legacyProformaInvoice.Id;

                testLegacyBillingItemList.add(legacyBillingItem);
            }
        }
        insert testLegacyBillingItemList;

        System.assert(! testLegacyBillingItemList.isEmpty() );

        Map<Id, Legacy_Pro_forma_Invoice__c> legacyProformaInvoiceMapNew = new Map<Id, Legacy_Pro_forma_Invoice__c>(testLegacyProformaInvoiceList.deepClone(true));
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : legacyProformaInvoiceMapNew.values()){
            legacyProformaInvoiceItem.cl_Create_FFA_Credit_Note_1__c = true;
            legacyProformaInvoiceItem.cl_Create_FFA_Credit_Note_2__c = true;
        }

        Test.startTest();

            LegacyProformaInvoiceServices.validationCreateFFACreditNote(legacyProformaInvoiceMapNew, testLegacyProformaInvoiceList);

        Test.stopTest();
    }

    private static testMethod void testUpdateSentToClientField() {
        testLegacyProformaInvoiceList = TestingUtils.createLegacyProFormaInvoiceList(NUMBER_TO_CREATE, false);
        for (Legacy_Pro_forma_Invoice__c legacyProformaInvoiceItem : testLegacyProformaInvoiceList){
            legacyProformaInvoiceItem.Sent_To_Client__c = false;
        }
        insert testLegacyProformaInvoiceList;

        System.assert(! testLegacyProformaInvoiceList.isEmpty() );
        
        Test.startTest();
            LegacyProformaInvoiceServices.updateSentToClientField(testLegacyProformaInvoiceList);
        Test.stopTest();
    }
}