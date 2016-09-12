@isTest
private class TestProjectInstructionsController {

    private static final String PCOMPANY_PROJECT_INSTR = 'Primary company PROJECT instructions';
    private static final String BCOMPANY_PROJECT_INSTR = 'Billing company PROJECT instructions';
    private static final String BCOMPANY_BILLING_INSTR = 'Billing company BILLING instructions';
    private static final String ACOMPANY_PROJECT_INSTR = 'Accounting company PROJECT instructions';
    private static final String PCONTACT_PROJECT_INSTR = 'Primary contact PROJECT instructions';
    private static final String BCONTACT_PROJECT_INSTR = 'Billing contact PROJECT instructions';
    private static final String ACONTACT_PROJECT_INSTR = 'Accounting contact PROJECT instructions';
    private static final String BUILDING_PROJECT_INSTR = 'Building PROJECT instructions';
    private static final String BUILDING_PROJECT_INSTR_2 = 'Building PROJECT instructions SECOND REPLACED';
    private static final String ROSTER_PROJECT_INSTR1 = 'Company PROJECT ROSTER instructions 1 REPLACED';
    private static final String ROSTER_CONTACT_INSTR = 'Contact ROSTER instructions REPLACED';
    private static final String CHANGES = ' changes where added';
    
    
        @isTest static void test_method_one() {

        List<Project_Instruction__c> instructions = new List<Project_Instruction__c> ();
        Map<String, String> typeOfInstrToInstrMap = new Map<String, String> ();

        List<Account> accounts = TestingUtils.createAccountList(4, null, false);
        Account primaryAccount = accounts.get(0);
        primaryAccount.Special_Instructions__c = PCOMPANY_PROJECT_INSTR;
        Account billingAccount = accounts.get(1);
        billingAccount.Special_Instructions__c = BCOMPANY_PROJECT_INSTR;
        billingAccount.Billing_Instructions__c = BCOMPANY_BILLING_INSTR;
        Account accountingAccount = accounts.get(2);
        accountingAccount.Special_Instructions__c = ACOMPANY_PROJECT_INSTR;
        Account rosterAccount = accounts.get(3);
        rosterAccount.Special_Instructions__c = ROSTER_PROJECT_INSTR1;
        rosterAccount.Billing_Instructions__c = ROSTER_PROJECT_INSTR1;
        UPSERT accounts;

        List<Contact> contacts = TestingUtils.createContactList(4, false);
        Contact primaryContact = contacts.get(0);
        primaryContact.AccountId = primaryAccount.Id;
        primaryContact.Special_Instructions__c = PCONTACT_PROJECT_INSTR;
        Contact billingContact = contacts.get(1);
        billingContact.AccountId = billingAccount.Id;
        billingContact.Special_Instructions__c = BCONTACT_PROJECT_INSTR;
        Contact accountingContact = contacts.get(2);
        accountingContact.AccountId = accountingAccount.Id;
        accountingContact.Special_Instructions__c = ACONTACT_PROJECT_INSTR;
        Contact rosterContact = contacts.get(3);
        rosterContact.AccountId = rosterAccount.Id;
        rosterContact.Special_Instructions__c = ROSTER_CONTACT_INSTR;
        UPSERT contacts;

        List<Building__c> buildings = TestingUtils.createBuildingList(2, null, null, null, null, null, false); 
        Building__c building = buildings.get(0);
        building.Special_Instructions__c = BUILDING_PROJECT_INSTR;
        Building__c buildingToReplace = buildings.get(1);
        buildingToReplace.Special_Instructions__c = BUILDING_PROJECT_INSTR_2;
        UPSERT buildings;

        Proposal__c proposal = TestingUtils.createProposalListForTest(1, true).get(0);

        Project_Profile__c project = TestingUtils.createProjectProfileForTest(1, false).get(0);
        project.Primary_Company_Name__c = primaryAccount.Id;
        project.Primary_Company_Contact__c = primaryContact.Id;
        project.Billing_Company_Name__c = billingAccount.Id;
        project.Billing_Company_Contact__c = billingContact.Id;
        project.Accounting_Contact_Company__c = accountingAccount.Id;
        project.Accounting_Contact__c = accountingContact.Id;
        project.Building__c = building.Id;
        project.Proposal__c = proposal.Id;
        UPSERT project;

        List<Project_Roster__c> rosters = TestingUtils.createProjectRosterList(2, false); 
        Project_Roster__c roster1 = rosters.get(0);
        roster1.Project_Profile__c = project.Id;
        roster1.Contact__c = rosterContact.Id;
        Project_Roster__c roster2 = rosters.get(1);
        roster2.Project_Profile__c = project.Id;
        roster2.Contact__c = rosterContact.Id;
        UPSERT rosters;

        ApexPages.StandardController sc = new ApexPages.standardController(project);
        ProjectInstructionsController projectInstrContr = new ProjectInstructionsController(sc);
    }
}