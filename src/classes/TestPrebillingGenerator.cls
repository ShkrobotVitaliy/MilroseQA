@isTest
private class TestPrebillingGenerator {
	private static List<Project_Team__c> testProjectTeamList;
    private static Account testAccount;
    private static Contact testContact;
    private static Region__c testRegion;
    private static Munucipalities__c testMunucipalities;
    private static Building__c testBuilding;
    private static Project_Profile__c testProjectProfile;
    private static PrebillingGeneratorController prebCon;
    private static final Integer NUMBER_TO_CREATE = 5;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static final String PROJECT_ID = 'Id';

	private static void setUp(){
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
		testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];
        testRegion = TestingUtils.createRegionList(NUMBER_TO_CREATE, null, true)[0];
        testMunucipalities = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE, null, testRegion.Id, true)[0];
        testBuilding = TestingUtils.createBuildingList(NUMBER_TO_CREATE, testMunucipalities.Id, null, null, null, null, true)[0];      
		testProjectProfile = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE, false)[0];
			testProjectProfile.Building__c = testBuilding.Id;
			insert testProjectProfile;
		testProjectProfile = [SELECT Id,Building__c, Region_ID__c FROM Project_Profile__c WHERE Id = : testProjectProfile.Id];		
	}
	
	private static void initiliazeController(){
		Test.setCurrentPageReference(Page.PrebillingGenerator);
		ApexPages.currentPage().getParameters().put(PROJECT_ID,testProjectProfile.Id);
		prebCon = new PrebillingGeneratorController();
	}
	
	private static testMethod void testSelectedProjectsList(){
		setUp();
		initiliazeController();
		
		Test.startTest();
			List<Project_Profile__c> selectedProjectsList = prebCon.selectedProjectsList;	
			System.assert( selectedProjectsList.isEmpty() );		
		Test.stopTest();
	}
	
	private static testMethod void testGetFullWrapperNotPreBilledProjects(){
		setUp();
		initiliazeController();
		
		Test.startTest();
			System.assert(prebCon != null);
			prebCon.searchAction();	
		Test.stopTest();
	}
	
	private static testMethod void testAddNewProject(){		
		setUp();
		initiliazeController();
		
		Test.startTest();
			System.assert(prebCon != null);
			prebCon.addNewProject();	
		Test.stopTest();
	}
	
	private static testMethod void testBuildQueryWhere(){		
		
		Test.startTest();
			String queryWhere = PrebillingGeneratorController.buildQueryWhere('Test', 'Test', 'Test', 'Test', 'Test');	
			String query = PrebillingGeneratorController.buildQuery(queryWhere);
			System.assert(! String.isBlank(query) );
		Test.stopTest();
	}
	
	private static testMethod void testReturnToProjectLevel(){
		setUp();
		initiliazeController();
		
		Test.startTest();
			System.assert(prebCon != null);
			prebCon.returnToProjectLevel();
		Test.stopTest();
	}
	
	private static testMethod void testAddForPrebilling(){		
		setUp();
		initiliazeController();
		
		Test.startTest();
			System.assert(prebCon != null);
			prebCon.AddForPrebilling();	
		Test.stopTest();
	}
	
	private static testMethod void testGeneratePreBilling(){		
		setUp();
		initiliazeController();
		
		Test.startTest();
			System.assert(prebCon != null);
			prebCon.generatePreBilling();	
		Test.stopTest();
	}
	
}