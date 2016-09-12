@isTest
private class TestFormMetaDataObject1Services {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
	private static final Integer NUMBER_TO_CREATE_FORM_SIGNATURE = 4;
	private static final Integer NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1 = 5;
	private static final Integer NUMBER_TO_CREATE_FLOOR = 1;
	private static final String MUNICIPAL_AGENCY_TEST_VALUE = 'test';

	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static User partnerUser;
	private static User projectManagerUser;
	public static User testProductionManagerUser;
	private static Id currentUserId;

	private static List<Form_Signature__c> testFormSignatureList;
	private static List<Form_Item__c> testFormItemList;
	private static List<Form_Meta_Data_Object_1__c> testFormMetaDataObject1List;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Floor__c> testFloorList;

	private static void setupData (){
		TestingUtils.setupData();
		partnerUser = TestingUtils.testPartnerUser;
		projectManagerUser = TestingUtils.testProjectManagerUser;
		testProductionManagerUser = TestingUtils.testProductionManagerUser;
		currentUserId = TestingUtils.testCurrentUserId;
		testProjectTeamList = TestingUtils.testProjectTeamList;
		testAccountList = TestingUtils.testAccountList;
		testContactWithAccountList = TestingUtils.testContactWithAccountList;
		testRegionList = TestingUtils.testRegionList;
		testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
		testBuildingList = TestingUtils.testBuildingList;
		testProjectProfileList = TestingUtils.createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
	}

	private static testmethod void testPopulateSignatoriesFields(){
		setupData();

		Map<Id, List<Floor__c>> projectWithFloorMap = new Map<Id, List<Floor__c>>();

		testFloorList = new List<Floor__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectWithFloorMap.put(projectProfileItem.Id, new List<Floor__c>());
			for (Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
				floorItem.Project__c = projectProfileItem.Id;
				projectWithFloorMap.get(projectProfileItem.Id).add(floorItem);
				testFloorList.add(floorItem);
			}
		}
		insert testFloorList;

		testServiceItemList = new List<Service_Item__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Service_item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
				serviceItemItem.Project_Profile__c = projectProfileItem.Id;
				serviceItemItem.Floor__c = projectWithFloorMap.get(projectProfileItem.Id)[0].Id;
				serviceItemItem.Municipal_Agency_ID__c = MUNICIPAL_AGENCY_TEST_VALUE;
				testServiceItemList.add(serviceItemItem);
			}
		}
		insert testServiceItemList;

		testFormItemList = new List<Form_Item__c>();
		for (Service_Item__c serviceItemItem : testServiceItemList){
			for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
				formItemItem.Service_Item__c = serviceItemItem.Id;
				testFormItemList.add(formItemItem);
			}
		}
		insert testFormItemList;

		testFormSignatureList = new List<Form_Signature__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_SIGNATURE, formItemItem.Id, false)){
				formSignatureItem.Order__c = 2;
				testFormSignatureList.add(formSignatureItem);
			}
		}
		insert testFormSignatureList;

		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for ( Form_Item__c formItemItem : testFormItemList ) {
			for ( Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List (1, formItemItem.Id, false) ) {
				formMetaDataObject1Item.Building__c = testBuildingList[0].Id;
				testFormMetaDataObject1List.add(formMetaDataObject1Item);
			}
		}
		insert testFormMetaDataObject1List;

		Test.startTest();

			FormMetaDataObject1Services.populateSignatoriesFields(new Map<id, Form_Meta_Data_Object_1__c>(testFormMetaDataObject1List));

		Test.stopTest();

		System.assert(! testFormMetaDataObject1List.isEmpty() );
	}

	private static testmethod void testpopulateBuildingFields(){
		setupData();

		Map<Id, List<Floor__c>> projectWithFloorMap = new Map<Id, List<Floor__c>>();

		testFloorList = new List<Floor__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectWithFloorMap.put(projectProfileItem.Id, new List<Floor__c>());
			for (Floor__c floorItem : TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, false)){
				floorItem.Project__c = projectProfileItem.Id;
				projectWithFloorMap.get(projectProfileItem.Id).add(floorItem);
				testFloorList.add(floorItem);
			}
		}
		insert testFloorList;

		testServiceItemList = new List<Service_Item__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Service_item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
				serviceItemItem.Project_Profile__c = projectProfileItem.Id;
				serviceItemItem.Floor__c = projectWithFloorMap.get(projectProfileItem.Id)[0].Id;
				serviceItemItem.Municipal_Agency_ID__c = MUNICIPAL_AGENCY_TEST_VALUE;
				testServiceItemList.add(serviceItemItem);
			}
		}
		insert testServiceItemList;

		testFormItemList = new List<Form_Item__c>();
		for (Service_Item__c serviceItemItem : testServiceItemList){
			for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
				formItemItem.Service_Item__c = serviceItemItem.Id;
				testFormItemList.add(formItemItem);
			}
		}
		insert testFormItemList;

		testFormSignatureList = new List<Form_Signature__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_SIGNATURE, formItemItem.Id, false)){
				formSignatureItem.Order__c = 2;
				testFormSignatureList.add(formSignatureItem);
			}
		}
		insert testFormSignatureList;

		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for ( Form_Item__c formItemItem : testFormItemList ) {
			for ( Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List (1, formItemItem.Id, false) ) {
				formMetaDataObject1Item.Building__c = testBuildingList[0].Id;
				formMetaDataObject1Item.Service_Item__c = testServiceItemList[0].Id;
				testFormMetaDataObject1List.add(formMetaDataObject1Item);
			}
		}

		Test.startTest();

			FormMetaDataObject1Services.populateBuildingFields(testFormMetaDataObject1List);

		Test.stopTest();

		System.assert(! testFormMetaDataObject1List.isEmpty() );
	}

	private static testmethod void testFilterFormMetaDataRecordsChangeBuildingInsert(){
		setupData();

		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

		Map<Id, List<Form_Signature__c>> formItemSignatureMap = new Map<Id, List<Form_Signature__c>>();

		testFormSignatureList = new List<Form_Signature__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			formItemSignatureMap.put(formItemItem.Id, new List<Form_Signature__c>());
			for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_ITEM, formItemItem.Id, false)){
				testFormSignatureList.add(formSignatureItem);
				formItemSignatureMap.get(formItemItem.Id).add(formSignatureItem);
			}
		}
		insert testFormSignatureList;

		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(1, formItemItem.Id, false)){
				formMetaDataObject1Item.Building__c = testBuildingList[0].Id;
				testFormMetaDataObject1List.add(formMetaDataObject1Item);
			}
		}

		List<Form_Meta_Data_Object_1__c> resultFormMetaDataObject1List;

		Test.startTest();

			resultFormMetaDataObject1List = FormMetaDataObject1Services.filterFormMetaDataRecordsChangeBuilding(testFormMetaDataObject1List, null);

		Test.stopTest();

		System.assert(!resultFormMetaDataObject1List.isEmpty());
		System.assertEquals(testFormMetaDataObject1List.size(), resultFormMetaDataObject1List.size());
	}

	private static testmethod void testFilterFormMetaDataRecordsChangeBuildingUpdate(){
		setupData();

		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

		Map<Id, List<Form_Signature__c>> formItemSignatureMap = new Map<Id, List<Form_Signature__c>>();

		testFormSignatureList = new List<Form_Signature__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			formItemSignatureMap.put(formItemItem.Id, new List<Form_Signature__c>());
			for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_ITEM, formItemItem.Id, false)){
				testFormSignatureList.add(formSignatureItem);
				formItemSignatureMap.get(formItemItem.Id).add(formSignatureItem);
			}
		}
		insert testFormSignatureList;

		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(1, formItemItem.Id, false)){
				testFormMetaDataObject1List.add(formMetaDataObject1Item);
			}
		}
		insert testFormMetaDataObject1List;

		Map<Id, Form_Meta_Data_Object_1__c> oldFormMetaDataObject1Map = new Map<Id, Form_Meta_Data_Object_1__c>(testFormMetaDataObject1List.deepClone(true));

		for (Form_Meta_Data_Object_1__c formMetaDataObjectItem : testFormMetaDataObject1List){
			formMetaDataObjectItem.Building__c = testBuildingList[0].Id;
		}

		List<Form_Meta_Data_Object_1__c> resultFormMetaDataObject1List;

		Test.startTest();

			resultFormMetaDataObject1List = FormMetaDataObject1Services.filterFormMetaDataRecordsChangeBuilding(testFormMetaDataObject1List, oldFormMetaDataObject1Map);

		Test.stopTest();

		System.assert(!resultFormMetaDataObject1List.isEmpty());
		System.assertEquals(new Map<Id, Form_Meta_Data_Object_1__c>(testFormMetaDataObject1List).keySet(), new Map<Id, Form_Meta_Data_Object_1__c>(resultFormMetaDataObject1List).keySet());
	}

	private static testmethod void testFilterFormMetaDataRecordsChangeSignatory(){
		setupData();

		testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

		Map<Id, List<Form_Signature__c>> formItemSignatureMap = new Map<Id, List<Form_Signature__c>>();

		testFormSignatureList = new List<Form_Signature__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			formItemSignatureMap.put(formItemItem.Id, new List<Form_Signature__c>());
			for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_ITEM, formItemItem.Id, false)){
				testFormSignatureList.add(formSignatureItem);
				formItemSignatureMap.get(formItemItem.Id).add(formSignatureItem);
			}
		}
		insert testFormSignatureList;

		testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(1, formItemItem.Id, false)){
				testFormMetaDataObject1List.add(formMetaDataObject1Item);
			}
		}
		insert testFormMetaDataObject1List;

		Map<Id, Form_Meta_Data_Object_1__c> oldFormMetaDataObject1Map = new Map<Id, Form_Meta_Data_Object_1__c>(testFormMetaDataObject1List.deepClone(true));

		for (Form_Meta_Data_Object_1__c formMetaDataObjectItem : testFormMetaDataObject1List){
			formMetaDataObjectItem.Signatory_1__c = formItemSignatureMap.get(formMetaDataObjectItem.Form_Item__c)[0].Id;
		}

		Map<Id, Form_Meta_Data_Object_1__c> resultFormMetaDataObject1Map;

		Test.startTest();

			resultFormMetaDataObject1Map = FormMetaDataObject1Services.filterFormMetaDataRecordsChangeSignatory(testFormMetaDataObject1List, oldFormMetaDataObject1Map);

		Test.stopTest();

		System.assert(!resultFormMetaDataObject1Map.isEmpty());
		System.assertEquals(new Map<Id, Form_Meta_Data_Object_1__c>(testFormMetaDataObject1List).keySet(), resultFormMetaDataObject1Map.keySet());
	}
}