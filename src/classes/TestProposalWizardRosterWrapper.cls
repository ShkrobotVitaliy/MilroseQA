@isTest
private class TestProposalWizardRosterWrapper {
	
	@isTest static void testProposalCWizardRosterWrapper() {
		
		Contact contact = TestingUtils.createContactList( 1, true)[0];
		User user = TestingUtils.userWithProfile( UserServices.SYSTEM_ADMINISTRATOR );
		user = [SELECT Id, Name, Email, isActive FROM User WHERE Id = :user.Id];
		Project_Roster__c pR = TestingUtils.createProjectRosterList( 1, false)[0];
		pR.Contact__c = contact.Id;
		INSERT pR;
		
		ProposalWizardRosterWrapper pwrw;
		ProposalWizardRosterWrapper pwrwTwo;

		pwrw = new ProposalWizardRosterWrapper( pR );
		pwrw = new ProposalWizardRosterWrapper( pR, contact );
		pwrw = new ProposalWizardRosterWrapper( pR, contact, UserServices.ROLE_MANAGER_OF_ACCOUNTS, true );
		pwrw = new ProposalWizardRosterWrapper( pR, user, UserServices.ROLE_MANAGER_OF_ACCOUNTS, true );
		pwrw = new ProposalWizardRosterWrapper( pR, contact, UserServices.ROLE_MANAGER_OF_ACCOUNTS );
		pwrwTwo = new ProposalWizardRosterWrapper( pR, user, UserServices.ROLE_MANAGER_OF_ACCOUNTS );
		Integer compareTo = pwrw.compareTo( pwrwTwo );
	}
}