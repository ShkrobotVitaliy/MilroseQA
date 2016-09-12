@isTest
private class TestSendFormsforSignaturesProjectExt {
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
	private static final Integer NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL = 1;
	private final static String TEST_FULFILLMENT_OFFICE = 'test fulfillment office';
	private final static String TEST_SHORT_NAME = 'test short name';
	private final static String TEST_DESCRIPTION = 'test description';
	private final static String TEST_PROJECT_ROSTER_ROLE = 'test Project Roster Role';

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
	private static List<Comments_Transmittal__c> testCommentsTransmittalList;
	private static List<Transmittal__c> testTransmittalList;
	private static User partnerUser;
	private static User projectManagerUser;
	private static Id currentUserId;

	private static Id projectRosterUserRecordTypeId;
	private static Id projectRosterContactRecordTypeId;

	private static PageReference testPage;
	private static SendFormsforSignaturesProjectExtension testController;
	private static ApexPages.StandardController testStandardController;

	private static void prepareDataForTest(){
		FulfillmentOfficeAddresses__c testFulfillmentOfficeAddresses = new FulfillmentOfficeAddresses__c(Name = TEST_FULFILLMENT_OFFICE,
																										 City__c = 'city',
																										 Street__c = 'street',
																										 Phone__c = '888-999-666',
																										 Fax__c = '111-222-333');
		Insert testFulfillmentOfficeAddresses;

		testCommentsTransmittalList = TestingUtils.createCommnetsTransmittal(NUMBER_TO_CREATE_COMMENTS_TRANSMITTAL, false);
		for (Comments_Transmittal__c commentsTransmittalItem : testCommentsTransmittalList){
			commentsTransmittalItem.Short_Name__c = TEST_SHORT_NAME;
			commentsTransmittalItem.Description__c = TEST_DESCRIPTION;
		}
		insert testCommentsTransmittalList;

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
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			projectProfileItem.Fulfillment_Office__c = TEST_FULFILLMENT_OFFICE;
		}
		update testProjectProfileList;

		testTransmittalList = new List<Transmittal__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			for(Transmittal__c transmittalItem : TestingUtils.createTransmital(1, false)){
				transmittalItem.Project_Profile__c = projectProfileItem.Id;
			}
		}
		insert testTransmittalList;

		prepareRecordTypes();

		testProjectRosterList = new List<Project_Roster__c>();
		for (Project_Profile__c projectProfileItem : testProjectProfileList){
			Integer i = 0;
			for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
				projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
				projectRosterItem.Project_Profile__c = projectProfileItem.Id;
				projectRosterItem.RecordTypeId = projectRosterUserRecordTypeId;
				projectRosterItem.User__c = currentUserId;
				projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(i++);
				testProjectRosterList.add(projectRosterItem);
			}
			for (Contact contactItem : testContactWithAccountList){
				for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
					projectRosterItem.Proposal__c = projectProfileItem.Proposal__c;
					projectRosterItem.Project_Profile__c = projectProfileItem.Id;
					projectRosterItem.RecordTypeId = projectRosterContactRecordTypeId;
					projectRosterItem.Contact__c = contactItem.Id;
					projectRosterItem.Role__c = TEST_PROJECT_ROSTER_ROLE + String.valueOf(i++);
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
					formItemItem.Form_Id__c = formTemplateItem.Form_ID__c;
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

	private static void preparePageController (Project_Profile__c projectProfileForStandardController){
		testPage = Page.SendFormsforSignaturesSealsProject;
		Test.setCurrentPage(testPage);
		if (projectProfileForStandardController != null) {
			testStandardController = new ApexPages.standardController( projectProfileForStandardController );
			testController = new SendFormsforSignaturesProjectExtension(testStandardController);
		}
	}

	private static testmethod void testInitController(){
		prepareDataForTest();

			Test.startTest();

				preparePageController(testProjectProfileList[0]);
				System.assert(testController != null);

				//for test coverage
				Boolean testBoolean;
				testBoolean = testController.formAssignmentsList == null;
				testBoolean = testController.commentsShortName == null;
				testBoolean = testController.selectedFormItemId == null;
				testBoolean = testController.storedDocumentId == null;
				testBoolean = testController.serviceItemId == null;
				testBoolean = testController.formRef == null;
				testBoolean = testController.formItemStatus == null;
				testBoolean = testController.formItemId == null;
				testBoolean = testController.formAssignmentId == null;
				testBoolean = testController.rosterId == null;
				testBoolean = testController.rosterReplyToId == null;
				testBoolean = testController.rosterForTransmittalSendTo == null;
				testBoolean = testController.rosterForTransmittalReplyTo == null;
				testBoolean = testController.isPrintPendingFormsPanel == null;
				testBoolean = testController.isShippingRequestPanel == null;
				String testString = '';
				for (Form_Item__c fi : testController.getFormItemsList()){
					testString += fi.Id + ';';
				}
				testController.orderedForm = testString;
				testBoolean = testController.orderedForm == null;
				testBoolean = testController.newFormItem == null;
				testBoolean = testController.selectedIdRolesSet == null;
				testBoolean = testController.selectedFormItemsList == null;
				testBoolean = testController.selectedFormAssignmentsList == null;
				testBoolean = testController.transmittal == null;
				testBoolean = testController.shippingRequest == null;
				testController.newFormItem = new Form_Item__c(Form_Name__c = 'test');
				testBoolean = testController.saveNewFormItem() == null;
				testBoolean = testController.copyFormItem() == null;
				testBoolean = testController.cancelSaveNewFormItem() == null;
				testBoolean = testController.rosterSendToAction() == null;
				testBoolean = testController.rosterReplyToAction() == null;
				testBoolean = testController.rosterCCToAction() == null;
				testBoolean = testController.addCCToRoster() == null;
				testBoolean = testController.disableAddCCButton == null;
				testBoolean = testController.attachPDF() == null;
				testBoolean = testController.initDdpHelpers() == null;
				testBoolean = testController.initDdpHelpers() == null;
				testBoolean = testController.filledOutTransmittalRecord() == null;
				testBoolean = testController.cancelAction() == null;
				testBoolean = testController.sendFormItems() == null;
				testBoolean = testController.shippingRequestAction() == null;
				testBoolean = testController.sendShippingRequestAction() == null;
				testBoolean = testController.cancelFromShipping() == null;
				testController.formItemId = testController.getFormItemsList()[0].Id;
				testBoolean = testController.forwardFormAssignment() == null;
				for (SendFormsforSignaturesProjectExtension.FormWrapper fw : testController.formWrapperList){
					for (Form_Assignment__c formAssignmentItem : fw.formAssignments ){
						formAssignmentItem.Status__c = FormItemsServices.FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED;
					}
				}
				testController.formItemId = testController.getFormItemsList()[0].Id;
				testBoolean = testController.forwardFormAssignment() == null;
				testBoolean = testController.saveAction() == null;
				testBoolean = testController.saveTransmittalAction() == null;
				testController.rosterId = testProjectRosterList[0].Id;
				for (SendFormsforSignaturesProjectExtension.FormWrapper wrapperItem : testController.formWrapperList ){
					wrapperItem.isSelected = true;
				}
				testBoolean = testController.saveTransmittalAction() == null;
				for (SendFormsforSignaturesProjectExtension.FormWrapper wrapperItem : testController.formWrapperList ){
					wrapperItem.isSelected = true;
				}
				testBoolean = testController.getSelectedFormItems() == null;
				testBoolean = testController.printPendingForms() == null;
				testBoolean = testController.changeSendToAction() == null;

			Test.stopTest();
	}
}