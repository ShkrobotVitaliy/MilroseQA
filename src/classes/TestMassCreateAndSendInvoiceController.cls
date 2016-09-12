@isTest
private class TestMassCreateAndSendInvoiceController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_PROFORMA_INVOICE = 3;
	
	private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Pro_forma_Invoice__c> testProFormaInvoiceList;
    
    private static PageReference testPage;
    private static MassCreateAndSendInvoiceController testController;
    private static ApexPages.StandardSetController testStandardController;

	private static void setupData (){
        TestingUtils.setupData();
        testBuildingList = TestingUtils.testBuildingList;
    }
	
	private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileForTest(numberToCreate, doInsert);
    }
    
    private static void prepareDataForTest() {
        testProFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Pro_forma_Invoice__c proFormaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PROFORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                testProFormaInvoiceList.add(proFormaInvoiceItem);
            }
        }
        testProFormaInvoiceList[0].cl_FFA_Invoice_Created__c = true;
        testProFormaInvoiceList[1].cl_FFA_Invoice_Created__c = false;
        testProFormaInvoiceList[2].Invoice_Format__c = null;
        insert testProFormaInvoiceList;
    }

    private static void preparePageController (List<Pro_forma_Invoice__c> proformaInvoiceList){
        testPage = Page.MassSendInvoiceEmail;
        Test.setCurrentPage(testPage);
        List<Pro_forma_Invoice__c> invoicesFormDB = [SELECT Id FROM Pro_forma_Invoice__c WHERE Id IN : proformaInvoiceList];
        testStandardController = new ApexPages.StandardSetController(invoicesFormDB);
        testController = new MassCreateAndSendInvoiceController(testStandardController);
		testController.proFormaInvoiceList = invoicesFormDB;
    }

    private static testmethod void testInitMassSendInvoiceContExt(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();

        Test.startTest();
            preparePageController(testProFormaInvoiceList);
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
    
    private static testmethod void testAutorun() {
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController(testProFormaInvoiceList);
        
        Test.startTest();
            testController.autorun();
        Test.stopTest();

        System.assert( ApexPages.hasMessages() );
    }  
    
    private static testmethod void testBackToInvoicesAction() {
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        prepareDataForTest();
        preparePageController(testProFormaInvoiceList);
        
        PageReference pr; 
        Test.startTest();
            pr = testController.backToInvoicesAction();
        Test.stopTest();

        System.assert( pr != null );
        System.assert(! ApexPages.hasMessages() );
    } 
}