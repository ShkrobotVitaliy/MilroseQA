@isTest
private class TestSendFormOutboundEmailProjectContr {
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
	private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 1;
	private static final Integer NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1 = 1;
	private static final Integer NUMBER_TO_CREATE_FORM_ASSIGNMENT = 1;

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
	private static List<Form_Item__c> testFormItemList;
	private static List<Form_Assignment__c> testFormAssignmentList;
	private static List<Form_Meta_Data_Object_1__c> testFormMetadataObject1List;
	private static List<LStore__Stored_Document__c> testStoredDocumentList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static SendFormOutboundEmailProjectController testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
		partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
		currentUserId = UserInfo.getUserId();
		testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
		testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, false);
		for (Integer i = 0; i < testContactWithAccountList.size(); i++){
			testContactWithAccountList[i].Email = 'test' + String.valueOf(i) + 'test@gmail.com';
		}
		insert testContactWithAccountList;
		testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
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

		testFormItemList = new List<Form_Item__c>();
		for (Form_Template__c formTemplateItem : testFormTemplateList){
			for (Task_Item__c taskItemItem : testTaskItemList){
				for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
					formItemItem.Service_Item__c = taskItemItem.Service_Item__c;
					formItemItem.Project__c = taskItemItem.Project_Profile__c;
					formItemItem.Complete_Forms__c = taskItemItem.Id;
					formItemItem.Form_Template__c = formTemplateItem.Id;
					testFormItemList.add(formItemItem);
				}
			}
		}
		insert testFormItemList;

		testFormMetadataObject1List = new List<Form_Meta_Data_Object_1__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Form_Meta_Data_Object_1__c fmdo : TestingUtils.createFormMetaDataObject1List(NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1, formItemItem.Id, false)){
				fmdo.Service_Item__c = formItemItem.Service_Item__c;
				fmdo.Task_Item__c = formItemItem.Complete_Forms__c;
				testFormMetadataObject1List.add(fmdo);
			}
		}
		insert testFormMetadataObject1List;

		testFormAssignmentList = new List<Form_Assignment__c>();
		for (Form_Item__c formItemItem : testFormItemList){
			for (Project_Roster__c projectRosterItem : testProjectRosterList){
				for (Form_Assignment__c formAssignmentItem : TestingUtils.createFormAssignmentList(NUMBER_TO_CREATE_FORM_ASSIGNMENT, new List<Form_Item__c>{formItemItem}, false)){
					formAssignmentItem.Recipient_Role__c = projectRosterItem.Id;
					formAssignmentItem.Project__c = formItemItem.Project__c;
					testFormAssignmentList.add(formAssignmentItem);
				}
			}
		}
		insert testFormAssignmentList;
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

	private static void preparePageController (Project_Profile__c projectProfileForStandardController, List<Form_Item__c> formItemList){
		testPage = Page.SendFormOutboundEmailProject;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			ApexPages.currentPage().getParameters().put('projectId', projectProfileForStandardController.Id);
			if (formItemList != null && !formItemList.isEmpty()){
				List<String> tmpStringList = new List<String>();
				for (Form_Item__c formItemItem : formItemList){
					if (formItemItem.Project__c == projectProfileForStandardController.Id) tmpStringList.add(String.valueOf(formItemItem.Id));
				}
				ApexPages.currentPage().getParameters().put('formIds', String.join(tmpStringList, ','));
			}
			testController = new SendFormOutboundEmailProjectController();
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

			Test.startTest();

				preparePageController(testProjectProfileList[0], testFormItemList);
				System.assert(testController != null);

				//for test coverage
				Boolean testBoolean;
				testBoolean = testController.getEmailToFormItems() == null;
				testBoolean = testController.sendTo == null;
				for (String stringItem : testController.getEmailToFormItems().keySet()){
					testController.sendTo = stringItem;
					break;
				}
				testBoolean = testController.formItemsName == null;
				testBoolean = testController.getProjectId() == null;
				testBoolean = testController.getFormIds() == null;
				testBoolean = testController.drawloopName == null;
				testBoolean = testController.emailTemplateName == null;
				testBoolean = testController.draftTemplateName == null;
				testBoolean = testController.formForSignatures == null;
				testBoolean = testController.project == null;
				testBoolean = testController.contactRecipient == null;
				testBoolean = testController.contactEmail == null;
				testBoolean = testController.loggedUserName == null;
				testBoolean = testController.clearEmailAddress() == null;
				testBoolean = testController.attachmentIds == null;
				testBoolean = testController.onCompleteReview() == null;
				testBoolean = testController.showReviewEmail() == null;
				testBoolean = testController.goBack() == null;
				testBoolean = testController.emailsAddressForDrawLoop == null;
				testBoolean = testController.updateCCEmailsAddressForDrawLoop() == null;
				testBoolean = testController.updateAfterSend() == null;

			Test.stopTest();
	}
}