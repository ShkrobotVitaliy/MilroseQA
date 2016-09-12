@isTest
private class TestBillingLineItemWrapper {
	private static final Integer NUMBER_TO_CREATE = 5;
	private static Billing_Line_Item__c testBilLineItem;
	private static Project_Profile__c testProject;
    private static Account testAccount;
    private static Contact testContact;
    private static User projectManager;
    private static BillingLineItemWrapper testBilLineItemWrap;
    private static Service_Item__c testServiceItem;
	private static void setUp(){
		projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, 'TestAccount', true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testProject = TestingUtils.createProjectProfileList(NUMBER_TO_CREATE,
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            testAccount.Id, 
                                                            testContact.Id, 
                                                            projectManager.Id,
                                                            false)[0];
		testProject.Billing_Method__c = 'Milestone';
             insert testProject; 
        testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false)[0];        
            testServiceItem.Project_Profile__c = testProject.Id;       
            insert testServiceItem;                                                                
		testBilLineItem = TestingUtils.createBillingLineItemList(NUMBER_TO_CREATE, testProject.Id, testAccount.Id, testContact.Id, false)[0];
			testBilLineItem.Service_Item__c = testServiceItem.Id;
			insert testBilLineItem;
	}
	
	private static testMethod void testBillingLineItemWrapper(){
		setUp();
		
		Test.startTest();
			testBilLineItemWrap = new BillingLineItemWrapper(testBilLineItem);
		Test.stopTest();
		
		Billing_Line_Item__c bilLineItem =  testBilLineItemWrap.bli;
		Boolean selected = testBilLineItemWrap.selected;

		System.assert(! selected);
		System.assert(testBilLineItemWrap.bli.Id == bilLineItem.Id);

	}
}