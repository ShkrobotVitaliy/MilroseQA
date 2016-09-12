@isTest
private class TestBuildingController {
	private static final Integer NUMBER_TO_CREATE_REGION = 3;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITY = 4;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 2;
	private static final String TEST_REGION_NAME = 'Test region name';
	private static final String TEST_MUNICIPALITIES_NAME = 'Test municipalities name';
	private static final String TEST_BUILDING_STREET_NAME = 'Test Building strret';
	private static final String TEST_BUILDING_NUMBER = '1';
	private static final String TEST_BUILDING_CITY = 'Test Building City';
	private static final String TEST_BUILDING_POSTAL_CODE = '12345';
	private static final String TEST_BUILDING_STATE = 'NY';

	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunicipalitiesList;
	private static List<Building__c> testBuildingList;
	private static PageReference testPage;
	private static BuildingController testController;
	private static List<Account> testAccountList ;

	private static void setupData (){
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, TEST_REGION_NAME, true);
		testMunicipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITY, TEST_MUNICIPALITIES_NAME, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList ( NUMBER_TO_CREATE_BUILDING, testMunicipalitiesList[0].Id, TEST_BUILDING_STREET_NAME, TEST_BUILDING_NUMBER,
															 null, null, true );
																	 
	}
	/*
	private static void prepareData(){
		testPage = Page.AddBuilding;
		Test.setCurrentPage(Page.AddBuilding);
		testController = new BuildingController();
	}
	*/
	@isTest( seeAllData = false) private static void testBuildingController(){
		setupData();
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);
		String buildingId = ApexPages.currentPage().getParameters().get('buildingId');
		
	    testBuildingList = [SELECT Municipality__c, Street__c, House_No__c, City__c, PostalCode__c, State__c, Building_Owner__c,
                             Description__c, Is_Landmark__c, Is_MTA__c, Little_E_Designation__c, Loft_Board_Authority__c,
                             Municipality__r.Region__c, OwnerShip__c, Owner_Company__c, Owner_Contact_1__c,
                             Owner_Contact_2__c, Building_Manager__c, Business_Name_Agency__c
                           FROM Building__c
                           WHERE Id =: buildingId];
		
		Test.startTest();			
			testController = new BuildingController();
		Test.stopTest();			
		
		System.assertEquals(testBuildingList[0].Id, testController.building.Id);
		System.assertEquals(testBuildingList[0].Street__c, testController.buildingStreet);
		System.assertEquals(testBuildingList[0].Municipality__r.Region__c, testController.regionId);
		
	}
	
	@isTest( seeAllData = false) private static void testUpdateMunicipalityOptions_false(){
		setupData();
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);		
		testController = new BuildingController();
		
		Test.startTest();			
			testController.updateMunicipalityOptions();	
		Test.stopTest();			
		
		System.assertEquals(testMunicipalitiesList.size(), testController.municipalityList.size());
		Map<Id,Munucipalities__c> testMunicipalityMap = new Map<Id,Munucipalities__c>();
		for(Munucipalities__c item : testMunicipalitiesList){
			testMunicipalityMap.put(item.Id,item);
		}
		for(Munucipalities__c item : testController.municipalityList){
			System.assertEquals(testMunicipalityMap.get(item.Id), item);
		}
		
		System.assertEquals(null, testController.building.Municipality__c);
		
		
	}
		
	@isTest( seeAllData = false) private static void testCreateBuilding_State(){
		setupData();
		for(Building__c item : testBuildingList){
			item.State__c = null;
		}
		update testBuildingList;
		
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);		
		testController = new BuildingController();
		
		Test.startTest();			
			testController.createNewBuilding();	
		Test.stopTest();
		
		System.assert(TestingUtils.pageMessagesContain('Required fields are missing: [State]'));
		
	}
	
	@isTest( seeAllData = false) private static void testCreateBuilding_Ownership(){
		setupData();
		for(Building__c item : testBuildingList){	
			item.State__c = 'NY';		
			item.Ownership__c = null;			
		}
		update testBuildingList;
		
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);		
		testController = new BuildingController();
		
		Test.startTest();			
			testController.createNewBuilding();	
		Test.stopTest();
		
		System.assert(TestingUtils.pageMessagesContain('Required fields are missing: [Ownership]'));
		
	}
	
	@isTest( seeAllData = false) private static void testCreateBuilding_OwnerCompany(){
		setupData();
		for(Building__c item : testBuildingList){
			item.State__c = 'NY';
			item.OwnerShip__c = 'DOE';			
			item.Owner_Company__c = null;			
		}
		update testBuildingList;
		
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);		
		testController = new BuildingController();
		
		Test.startTest();			
			testController.createNewBuilding();	
		Test.stopTest();
		
		System.assert(TestingUtils.pageMessagesContain('Required fields are missing: [Owner Company]'));
	}
	
		@isTest( seeAllData = false) private static void testCreateBuilding_OwnerContact(){
		setupData();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, 'TestAccount', true);
		for(Building__c item : testBuildingList){
			item.State__c = 'NY';
			item.OwnerShip__c = 'DOE';
			item.Owner_Company__c = testAccountList[0].Id;
			item.Owner_Contact_1__c = null;
		}
		update testBuildingList;
		
		Test.setCurrentPage(Page.AddBuilding);
		ApexPages.currentPage().getParameters().put('buildingId',testBuildingList[0].Id);		
		testController = new BuildingController();
		
		Test.startTest();			
			testController.createNewBuilding();	
		Test.stopTest();
		
		
		System.assert(TestingUtils.pageMessagesContain('Required fields are missing: [Owner Contact 1]'));
		
	}

}