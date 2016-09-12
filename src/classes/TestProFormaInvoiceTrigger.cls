@isTest
private class TestProFormaInvoiceTrigger {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
	private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 3;
	private static final Integer NUMBER_TO_CREATE_BILLING_LINE_ITEM = 4;

    private static List<Project_Team__c> testProjectTeamList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Pro_forma_Invoice__c> testProformaInvoiceList;
    private static List<Billing_Line_Item__c> testBillingLineItemList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static testmethod void testDeleteProformaInvoiceUpdateBillingLineItem(){
    	setupData ();
    	testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

    	testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
    	for (Project_Profile__c projectProfileItem : testProjectProfileList){
    		for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    projectProfileItem.Billing_Company_Name__c,
                                                                                                    projectProfileItem.Billing_Company_Contact__c,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
				proformaInvoiceItem.Project_Profile__c = projectProfileItem.Id;
				testProformaInvoiceList.add(proformaInvoiceItem);
    		}
    	}
    	insert testProformaInvoiceList;

    	testBillingLineItemList = new List<Billing_Line_Item__c>();
		for (Pro_forma_Invoice__c proformaInvoiceItem : testProformaInvoiceList){
            for (Billing_Line_Item__c billingLineItem : TestingUtils.createBillingLineItemList (NUMBER_TO_CREATE_BILLING_LINE_ITEM,
                                                                                                proformaInvoiceItem.Project_Profile__c,
                                                                                                proformaInvoiceItem.Billing_Client_Company__c,
                                                                                                proformaInvoiceItem.Billing_Contact__c,
                                                                                                false)){
                billingLineItem.isReimbursable__c = true;
                billingLineItem.Billed__c = false;
                testBillingLineItemList.add(billingLineItem);
            }
        }
        insert testBillingLineItemList;
 
        Test.startTest();

        	delete testProformaInvoiceList;

        Test.stopTest();

        List<Billing_Line_Item__c> resultBillingLineItemList = [SELECT Id, Billed__c
        														FROM Billing_Line_Item__c
        														WHERE Id IN : testBillingLineItemList AND
        																Billed__c = true];

		System.assert(resultBillingLineItemList != null && resultBillingLineItemList.isEmpty());
    }
}