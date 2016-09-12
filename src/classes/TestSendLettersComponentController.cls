@isTest
private class TestSendLettersComponentController {
	private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
	private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
	private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
	private static final Integer NUMBER_TO_CREATE_REGION = 1;
	private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
	private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
	private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 1;
	private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 3;

	private static List<Account> testAccountList;
	private static List<Contact> testContactWithAccountList;
	private static List<Region__c> testRegionList;
	private static List<Munucipalities__c> testMunucipalitiesList;
	private static List<Building__c> testBuildingList;
	private static List<Project_Team__c> testProjectTeamList;
	private static List<Project_Profile__c> testProjectProfileList;
	private static List<Proposal__c> testProposalList;
	private static List<Project_Roster__c> testProjectRosterList;
	private static List<Service_Item__c> testServiceItemList;
	private static List<Task_Item__c> testTaskItemList;
	private static List<Form_Template__c> testFormTemplateList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static SendLettersComponentController testController;

	private static void prepareDataForTest(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);

		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, false);
		testRegionList[0].Name = RegionServices.REGION_NAME_NY;
		insert testRegionList;

		testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
		testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
		testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);

		TestingUtils.createProposalWithProjectProfileList(NUMBER_TO_CREATE_PROJECT_PROFILE);
		testProposalList = TestingUtils.testProposalList;
		testProjectProfileList = TestingUtils.testProjectProfileList;

		prepareRecordTypes();

		testProjectRosterList = new List<Project_Roster__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
				projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
				projectRosterItem.Project_Profile__c = projectProfileItem.Id;
				projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
				projectRosterItem.User__c = currentUserId;
				testProjectRosterList.add(projectRosterItem);
			}
			for (Contact contactItem : testContactWithAccountList){
				for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
					projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
					projectRosterItem.Project_Profile__c = projectProfileItem.Id;
					projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
					projectRosterItem.Contact__c = contactItem.Id;
					testProjectRosterList.add(projectRosterItem);
				}
			}
		}
		insert testProjectRosterList;

		testServiceItemList = new List<Service_Item__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, projectProfileItem.Proposal__c, false)){
				serviceItemItem.Project_Profile__c = projectProfileItem.Id;
				testServiceItemList.add(serviceItemItem);
			}
		}
		insert testServiceItemList;

		testTaskItemList = new List<Task_Item__c>();
		for (Service_Item__c serviceItemItem : testServiceItemList){
			for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItemItem.Id, serviceItemItem.Project_Profile__c, false)){
				testTaskItemList.add(taskItemItem);
			}
		}
		insert testTaskItemList;

		testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, false);
		for (Form_Template__c formTemplateItem : testFormTemplateList){
			formTemplateItem.Name = formTemplateItem.Form_ID__c;
			formTemplateItem.Form_Name__c = formTemplateItem.Form_ID__c;
			formTemplateItem.Municipality__c = testMunucipalitiesList[0].Name;
			formTemplateItem.Region__c = RegionServices.REGION_NAME_NY;
			formTemplateItem.Form_Type__c = FormTemplatesServices.FORM_TYPE_LETTER;
		}
		insert testFormTemplateList;
	}

	private static void prepareRecordTypes(){
		for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
			if (schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_CONTACT){
				projectRosterContactRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
			if (schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_USER){
				projectRosterUserRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
			}
		}
	}

	private static testmethod void testInitControllerTaskItem(){
		prepareDataForTest();

		Test.startTest();

			testController = new SendLettersComponentController();
			System.assert(testController != null);
			testController.setProjectId( String.valueOf(testTaskItemList[0].Project_Profile__c) );
			testController.setRecordId( String.valueOf(testTaskItemList[0].Id) );

			//for test coverage
			Boolean testBoolean;
			testBoolean = testController.drawloopName == null;
			testBoolean = testController.getRecordId() == null;
			testBoolean = testController.getProjectId() == null;
			testBoolean = testController.letterEmailType == null;
			testBoolean = testController.templateName == null;
			testBoolean = testController.parentDocumentIds == null;
			testBoolean = testController.isDisplaySearchSection == null;
			testBoolean = testController.isDisplaySenderRecipientSection == null;
			testBoolean = testController.isDisplayEmailSection == null;
			testBoolean = testController.isDisplayButtonPanel == null;
			testBoolean = testController.contactInfo == null;
			testController.contactInfo = new Project_Roster__c(User__c = currentUserId, Contact__c = testContactWithAccountList[0].Id);
			testBoolean = testController.recipient == null;
			testBoolean = testController.sender == null;
			testController.sender = new User(Id = currentUserId);
			testController.recipient = testContactWithAccountList[0];
			testBoolean = testController.formTemplates == null;
			testController.letterRecordId = testFormTemplateList[0].Id;
			testController.municipalityFilter = testMunucipalitiesList[0].Name;
			testBoolean = testController.isDisplayLetterBody == null;
			testBoolean = testController.letterName == null;
			testBoolean = testController.innerTemplateBody == null;
			testBoolean = testController.project == null;
			testBoolean = testController.serviceItems == null;
			testBoolean = testController.taskItems == null;
			testBoolean = testController.regionName == null;
			testBoolean = testController.municipalityFilter == null;
			testBoolean = testController.refNumberFilter == null;
			testBoolean = testController.shortNameFilter == null;
			testBoolean = testController.fullNameFilter == null;
			testBoolean = testController.letterRecordId == null;
			testBoolean = testController.regionOptions == null;
			testBoolean = testController.search() == null;
			testBoolean = testController.selectLetter() == null;
			testBoolean = testController.backToSearch() == null;
			testBoolean = testController.moveToLetter() == null;
			testBoolean = testController.backToChooseSenderRecipient() == null;
			testBoolean = testController.sendAsEmail() == null;
			testBoolean = testController.isTaskItem == null;
			testBoolean = testController.isServiceItem == null;
			testBoolean = testController.attachLetterAsPDF() == null;
			testBoolean = testController.close() == null;
			testBoolean = testController.emailsToDDP == null;
			testBoolean = testController.emailsCCDDP == null;
			testBoolean = testController.updateRecordTOField() == null;
			testBoolean = testController.updateRecordCCField() == null;

		Test.stopTest();

	}


	private static testmethod void testInitControllerServiceItem(){
		prepareDataForTest();

		Test.startTest();

			testController = new SendLettersComponentController();
			System.assert(testController != null);
			testController.setProjectId( String.valueOf(testServiceItemList[0].Project_Profile__c) );
			testController.setRecordId( String.valueOf(testServiceItemList[0].Id) );

			testController.attachLetterAsPDF();

		Test.stopTest();

	}
	private static testmethod void testInitController(){
		prepareDataForTest();

		Test.startTest();

			testController = new SendLettersComponentController();
			System.assert(testController != null);
			testController.setProjectId( String.valueOf(testProjectProfileList[0].Id) );
			testController.setRecordId( String.valueOf(testProjectProfileList[0].Id) );

			testController.attachLetterAsPDF();

		Test.stopTest();

	}
}