@isTest(seeAllData = true)
private class TestPopulateTaxesOnBliAndServiceItmBatch {
	
	private static final Integer PROPOSALS_TO_CREATE = 3;
	private static final Integer PROJECTS_TO_CREATE = 3;
	private static final Integer ACCOUNTS_TO_CREATE = 2;
	private static final Integer S_TEMPLATE_TO_CREATE = 1;
	private static final Integer SERVICES_TO_CREATE = 3;

	@isTest static void testPopulateTaxesOnBlisAndServiceItemsBatch() {

		List<Account> accountList = TestingUtils.createAccountList (ACCOUNTS_TO_CREATE, null, false);
		accountList[0].c2g__CODASalesTaxStatus__c = 'Taxable';
        accountList[1].c2g__CODASalesTaxStatus__c = 'Exempt for Qualifying Products';
        INSERT accountList;

        List<Contact> contactList = new List<Contact> {TestingUtils.createContactList(1, accountList[0].Id, true)[0], TestingUtils.createContactList(1, accountList[1].Id, true)[0]};

		List<Proposal__c> proposalList = TestingUtils.createProposalListForTest(PROPOSALS_TO_CREATE, false);
		for(Proposal__c p : proposalList) {
			p.Billing_Company_Name__c = accountList[0].Id;
		}
		INSERT proposalList;

		List<Project_Profile__c> projectList = TestingUtils.createProjectProfileForTest(PROJECTS_TO_CREATE, false);
		for(Integer i = 0; i < PROJECTS_TO_CREATE; i++) {
			projectList[i].Proposal__c = proposalList[i].Id; 	
		}
		projectList[0].Billing_Method__c = 'Milestone';
		projectList[1].Billing_Method__c = 'Istallment';
		projectList[2].Billing_Method__c = 'Percentage';
		projectList[2].Interval__c = true;
		INSERT projectList;

		for(Integer i = 0; i < PROPOSALS_TO_CREATE; i++) {
			proposalList[i].Project_Profile__c = projectList[i].Id; 	
		}
		UPDATE proposalList;

		List<c2g__codaTaxCode__c> taxCodes = [SELECT Id FROM c2g__codaTaxCode__c WHERE Name = 'New York State' OR Name = 'New York City'];

		List<Service_Template__c> serviceTemplateList = TestingUtils.createServiceTemplateList(S_TEMPLATE_TO_CREATE, false);
	 	serviceTemplateList[0].Tax_Code_1__c = taxCodes[0].Id;
	 	serviceTemplateList[0].Tax_Code_2__c = taxCodes[1].Id;
		INSERT serviceTemplateList;

		List<Service_Item__c> serviceItemList= TestingUtils.createServiceItemList(SERVICES_TO_CREATE, proposalList, false);
		serviceItemList[0].Service_Template__c = serviceTemplateList[0].Id;
		serviceItemList[1].Project_Profile__c = projectList[1].Id;
		serviceItemList[2].Project_Profile__c = projectList[2].Id;
		INSERT serviceItemList;

		Billing_Line_Item__c bliMileStone = TestingUtils.createBillingLineItemList(1, projectList[0].Id, accountList[0].Id, null, false)[0];
		bliMileStone.Service_Item__c = serviceItemList[0].Id;
		INSERT bliMileStone;

		Billing_Line_Item__c bliInstallment = TestingUtils.createBillingLineItemList(1, projectList[1].Id, accountList[0].Id, null, false)[0];
		bliInstallment.Service_Item__c = serviceItemList[1].Id;
		INSERT bliInstallment;

		Billing_Line_Item__c bliPercentageWithInterval = TestingUtils.createBillingLineItemList(1, projectList[2].Id, accountList[0].Id, null, false)[0];
		bliPercentageWithInterval.Service_Item__c = serviceItemList[2].Id;

		INSERT bliPercentageWithInterval;

		Test.startTest();

			for(Proposal__c p : proposalList) p.Billing_Company_Name__c = accountList[1].Id;
			PreventTwiceExecution.proposalFirstRun = true;
			UPDATE proposalList;

			for(Proposal__c p : proposalList) p.Billing_Company_Name__c = accountList[0].Id;
			PreventTwiceExecution.proposalFirstRun = true;
			UPDATE proposalList;

			accountList[0].c2g__CODASalesTaxStatus__c = 'Exempt for Qualifying Products';
			UPDATE accountList[0];

			accountList[0].c2g__CODASalesTaxStatus__c = 'Taxable';
			UPDATE accountList[0];

		Test.stopTest();
	}
	
}