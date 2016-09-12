@isTest
private class TestProposalWizardServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_PHASE = 1;
    private static final Integer NUMBER_TO_CREATE_FLOOR = 1;
    private static final Integer NUMBER_TO_CREATE_CLIENT_PRICE = 3;
    private static final Integer NUMBER_TO_CREATE_LAST_PROPOSAL_PRICE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_BUNDLE = 3;
    private static final Integer NUMBER_TO_CREATE_SERVICE_BUNDLE_ITEM = 1;
    private static final Integer NUMBER_TO_CREATE_DOCUMENT = 3;
    private static final Integer NUMBER_TO_GET_FOLDER_FOR_TEST = 2;
    private static final Integer NUMBER_TO_CREATE_LOOP_DDP = 2;
    private static final Integer NUMBER_TO_CREATE_LOOP_DDP_INTEGRATION_OPTIONS = 2;
    private static final Integer NUMBER_TO_CREATE_LOOP_DDP_FILE = 2;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 4;
    private static final Integer NUMBER_TO_CREATE_CHANGE_HISTORY_PROPOSAL = 4;
    private static final Integer NUMBER_TO_CREATE_DEPOSIT_INVOICE = 2;
    private static final String ARTIFACT_FOLDER_NAME = 'RFP Artifacts';
    private static final String PROPOSAL_RFP_ATTACHMENTS = '<<Proposal_RFP_Attachments>>';
    private static final String LOOP_DDP_INTEGRATION_OPTIONS_NAME = 'test name';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Contact> testContactList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunicipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Proposal__c> testProposalList;
    private static List<Proposal__c> testProposalDraftList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Change_Order__c> testChangeOrderList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<Service_Template__c> testServiceTemplateList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Template__c> testTaskTemplateList;
    private static List<ServiceModel> testServiceModelList;
    private static List<Phase__c> testPhaseList;
    private static List<Floor__c> testFloorList;
    private static List<Client_Price__c> testClientPriceList;
    private static List<Last_Proposal_Price__c> testLastProposalPriceList;
    private static List<Service_Bundle__c> testServiceBundleList;
    private static List<Service_Bundle_Item__c> testServiceBundleItemList;
    private static List<Folder> testFolderList;
    private static List<Document> testDocumentList;
    private static List<Loop__DDP__c> testLoopDDPList;
    private static List<Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOptionList;
    private static List<Loop__DDP_File__c> testLoopDDPFileList;
    private static List<LStore__Stored_Document__c> testLStoreStoredDocument;
    private static List<DocumentWrapper> testDocumentWrapperList;
    private static List<Service_Floor_Junction__c> testServiceFloorJunctionList;
    private static List<Change_History_Proposal__c> testChangeHistoryProposalList;
    private static List<Deposit_Invoice__c> testDepositInvoiceList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static PageReference testPageReference;

    private static void createContactsWithAccounts(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactList = new List<Contact>();
        for (Account accountItem : testAccountList){
            for (Contact contactItem : TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, accountItem.Id, false)){
                contactItem.Is_Active__c = true;
                testContactList.add(contactItem);
            }
        }
        insert testContactList;
    }

    private static void setupData (){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'New York', true);
        testMunicipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunicipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void createProposalListForTest(Integer numberToCreate, Boolean doInsert){
        testProposalList = TestingUtils.createProposalList (numberToCreate, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, doInsert);
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);

        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Resource__c = partnerUser.Id;
        }

        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static void createServiceItemListForTest(Integer numberToCreate, Boolean doInsert){
        testServiceItemList = TestingUtils.createServiceItemList(numberToCreate, doInsert);
    }

    private static void createPhaseListForTest(Integer numberToCreate, Boolean doInsert){
        testPhaseList = TestingUtils.createPhaseList(numberToCreate, doInsert);
    }

    private static testmethod void testGetProfileNameById(){
        Profile testUsersProfile = [SELECT Id, Name
                                    FROM Profile LIMIT 1][0];
        String resultProfileName;

        Test.startTest();
            resultProfileName = ProposalWizardServices.getProfileNameById(testUsersProfile.Id);
        Test.stopTest();

        System.assertEquals (testUsersProfile.Name, resultProfileName);
    }

    private static testmethod void testGetDocumentsFromDirectory(){
        Folder artifactFolder = [SELECT Id, Name FROM Folder WHERE Name =: ARTIFACT_FOLDER_NAME][0];
        testDocumentList = TestingUtils.createDocumentList(NUMBER_TO_CREATE_DOCUMENT, null, artifactFolder.Id, true);

        Test.startTest();
            testDocumentList = ProposalWizardServices.getDocumentsFromDirectory();
        Test.stopTest();

        System.assert(!testDocumentList.isEmpty());
        System.assertEquals (NUMBER_TO_CREATE_DOCUMENT, testDocumentList.size());
    }

    private static testmethod void testGetDefaultBooleanValue(){
        Schema.sObjectType accountType = Account.sObjectType;
        Schema.sObjectType proposalDraftType = Proposal__c.sObjectType;
        Schema.sObjectType proposalType = Proposal__c.sObjectType;

        Test.startTest();
            System.assert( ProposalWizardServices.getDefaultBooleanValue(accountType, 'Separate_Reimbursables__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(accountType, 'No_Document_Shredding__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(accountType, 'No_Met_Data_Scanning__c'));

            System.assert(!ProposalWizardServices.getDefaultBooleanValue(proposalDraftType, 'sowServicesNeededAPS__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(proposalDraftType, 'sowServicesNeededOther__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(proposalDraftType, 'sowACUnits__c'));

            System.assert( ProposalWizardServices.getDefaultBooleanValue(proposalType, 'Reimbursable_Items_Basis__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(proposalType, 'Primary_Client_is_Billing_Client__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(proposalType, 'Provided_Documents__c'));
            System.assert(!ProposalWizardServices.getDefaultBooleanValue(Case.sObjectType, ''));
        Test.stopTest();
    }

    private static testmethod void testGetPicklistOptionsForServiceTemplate(){
        Id serviceTemplateRecordTypeId = TestingUtils.getRecordTypeNameIdByObjecttypename('Service_Template__c').values()[0];

        testServiceTemplateList =TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false);
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            serviceTemplateItem.Region__c = 'testRegion';
            serviceTemplateItem.Category__c = 'testCategory';
            serviceTemplateItem.Type__c = 'testType';
            serviceTemplateItem.Subtype__c = 'testSubtype';
            serviceTemplateItem.RecordTypeId = serviceTemplateRecordTypeId;
        }
        insert testServiceTemplateList;

        List<List<String>> resultStringList;

        Test.startTest();
            resultStringList = ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(String.valueOf(testServiceTemplateList[0].RecordTypeId), 'testRegion', 'testCategory', 'testType', 'testSubtype', 'Category__c');
			resultStringList = ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(String.valueOf(testServiceTemplateList[0].RecordTypeId), 'testRegion', 'testCategory', 'testType', 'testSubtype', 'Type__c');
			resultStringList = ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(String.valueOf(testServiceTemplateList[0].RecordTypeId), 'testRegion', 'testCategory', 'testType', 'testSubtype', 'Subtype__c');
        Test.stopTest();

        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetFrequencyToBillingDay(){
        Map<String, List<String>> resultMap;

        Test.startTest();

            resultMap = ProposalWizardServices.getFrequencyToBillingDay();

        Test.stopTest();

        System.assert(!resultMap.isEmpty());
    }

    private static testmethod void testGetPicklistOptionsForApprovedVendors(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, false);
        for (Account accountItem : testAccountList){
            accountItem.Approved_Vendor__c = true;
        }
        insert testAccountList;

        List<String> resultStringList;

        Test.startTest();

            resultStringList = ProposalWizardServices.getPicklistOptionsForApprovedVendors();

        Test.stopTest();

        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetDefaultPicklistValue(){
        Schema.sObjectType accountType = Account.sObjectType;
        Schema.sObjectType caseType = Case.sObjectType;
        Schema.sObjectType proposalType = Proposal__c.sObjectType;
        String resultString;

        Test.startTest();
            resultString = ProposalWizardServices.getDefaultPicklistValue(proposalType, 'Billing_Method__c');
            System.assertEquals ('Milestone', resultString);

            resultString = ProposalWizardServices.getDefaultPicklistValue(proposalType, 'Name');
            System.assertEquals (null, resultString);

            resultString = ProposalWizardServices.getDefaultPicklistValue(accountType, 'Frequency__c');
            System.assertEquals ('Monthly', resultString);

            resultString = ProposalWizardServices.getDefaultPicklistValue(accountType, 'Billing_day__c');
            System.assertEquals ('1', resultString);

            resultString = ProposalWizardServices.getDefaultPicklistValue(caseType, 'Status');
            System.assertEquals ('New', resultString);
        Test.stopTest();
    }

    private static testmethod void testGetPicklistOptions(){
        Schema.sObjectType proposalType = Proposal__c.sObjectType;
        Map<String, String> resultMap;

        Test.startTest();
            resultMap = ProposalWizardServices.getPicklistOptions(proposalType, 'Billing_Method__c');
        Test.stopTest();

        System.assert (!resultMap.isEmpty());
    }

    private static testmethod void testGenerateOptions(){
        List<String> testStringList = new List<String>{'test1', 'test2'};
        List<SelectOption> resultList;

        Test.startTest();
            resultList = ProposalWizardServices.generateOptions(testStringList);
        Test.stopTest();

        System.assert(!resultList.isEmpty());
        System.assertEquals(testStringList.size() + 1, resultList.size());
    }

    private static testmethod void testGenerateOptionsWithPicklistEntry(){
        Map<String, String> testStringMap = new Map<String, String>{'test1' => 'test1', 'test2' => 'test2'};
        List<Schema.PicklistEntry> proposalPicklistEntry = Proposal__c.sObjectType.Billing_Method__c.getDescribe().getPicklistValues();
        List<SelectOption> resultList;

        Test.startTest();
            resultList = ProposalWizardServices.generateOptions(proposalPicklistEntry, testStringMap, true, true);
        Test.stopTest();

        System.assert(!resultList.isEmpty());
        System.assertEquals(testStringMap.size() + proposalPicklistEntry.size() + 1, resultList.size());
    }

    private static testmethod void testGenerateOptionsWithBackwardsSort(){
        Map<String, String> testStringMap = new Map<String, String>{'test1' => 'test1', 'test2' => 'test2'};
        List<Schema.PicklistEntry> proposalPicklistEntry = Proposal__c.sObjectType.Billing_Method__c.getDescribe().getPicklistValues();
        List<SelectOption> resultList;

        Test.startTest();
            resultList = ProposalWizardServices.generateOptions(proposalPicklistEntry, testStringMap, true, true, true);
        Test.stopTest();

        System.assert(!resultList.isEmpty());
        System.assertEquals(testStringMap.size() + proposalPicklistEntry.size() + 1, resultList.size());
    }

    private static testmethod void testGetUserByProfileMap(){
        String testProfileName = [SELECT Id, Profile.Name FROM User LIMIT 1][0].Profile.Name;
        Set<String> resultSetString = new Set<String>();
        for (User userItem : [SELECT Id, Profile.Name
                              FROM User
                              WHERE Profile.Name =: testProfileName]){
            resultSetString.add(userItem.Id);
        }
        Map<String, Map<String, String>> resultMap;

        Test.startTest();
            resultMap = ProposalWizardServices.getUserByProfileMap(new Set<String>{testProfileName});
        Test.stopTest();

        System.assert(!resultMap.isEmpty());
    }

    private static testmethod void testGetBuildingById(){
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunicipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunicipalitiesList[0].Id, null, null, null, null, true);
        Building__c resultBuilding;

        Test.startTest();
            resultBuilding = ProposalWizardServices.getBuildingById(testBuildingList[0].Id);
        Test.stopTest();

        System.assert (resultBuilding != null);
        System.assertEquals(testBuildingList[0].Id, resultBuilding.Id);
    }

    private static testmethod void testGetBuildingByIdWithEmptyParameter(){
        Building__c resultBuilding;

        Test.startTest();
            resultBuilding = ProposalWizardServices.getBuildingById(null);
        Test.stopTest();

        System.assert (resultBuilding == null);
    }

    private static testmethod void testGetProposal(){
        setupData ();
        createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);
        Proposal__c resultProposal;

        Test.startTest();
            resultProposal = ProposalWizardServices.getProposal(testProposalList[0].Id);
        Test.stopTest();

        System.assert(resultProposal != null);
        System.assertEquals(testProposalList[0].Id, resultProposal.id);
    }

    private static testmethod void testGetProposalWithNullParameter(){
        Proposal__c resultProposal;

        Test.startTest();
            resultProposal = ProposalWizardServices.getProposal(null);
        Test.stopTest();

        System.assert(resultProposal != null);
        System.assertEquals(null, resultProposal.id);
    }

    private static testmethod void testVisibleMethods(){
        Id incorrectProposalId = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        String incorrectCOIdString = Change_Order__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000';
        Id incorrectCOId = Id.valueOf(incorrectCOIdString);

        Boolean resultBoolean;
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true);
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible('some test status', 'other profile', 'test role', true);
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, 'other profile', 'test role', true);
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible('some test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isSumbitChangeOrderButtonVisible(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', false);
        resultBoolean = ProposalWizardServices.isNotAwardedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false);
        resultBoolean = ProposalWizardServices.isNotAwardedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true);
        resultBoolean = ProposalWizardServices.isAwardedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false);
        resultBoolean = ProposalWizardServices.isAwardedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true);
        resultBoolean = ProposalWizardServices.isWithdrawnButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isCanceledButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isCanceledButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_ACCOUNT_MANAGER, 'test role', true);
        resultBoolean = ProposalWizardServices.isCanceledButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, 'some test profile', 'test role', true);
        resultBoolean = ProposalWizardServices.isChangeOrderApprovedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true);
        resultBoolean = ProposalWizardServices.isChangeOrderApprovedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_ACCOUNT_MANAGER, 'test role', true, true);
        resultBoolean = ProposalWizardServices.isChangeOrderApprovedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, 'some test profile', 'test role', true, true);
        resultBoolean = ProposalWizardServices.isChangeOrderApprovedButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false);
        resultBoolean = ProposalWizardServices.isRejectedWithNotesButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isRejectedWithNotesButtonVisible(ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT, UserServices.PROFILE_ACCOUNT_MANAGER, 'test role', true);
        resultBoolean = ProposalWizardServices.isRejectedWithNotesButtonVisible('test status', UserServices.PROFILE_ACCOUNT_MANAGER, 'test role', true);
        resultBoolean = ProposalWizardServices.isRejectButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', null);
        resultBoolean = ProposalWizardServices.isApproveButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', null);
        resultBoolean = ProposalWizardServices.isApproveButtonVisible('some test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', null);
        resultBoolean = ProposalWizardServices.isSaveButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true, null, null, true, true, true, null);
        resultBoolean = ProposalWizardServices.isSaveButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true, null, incorrectProposalId, false, true, true, null);
        resultBoolean = ProposalWizardServices.isSaveButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false, null, incorrectProposalId, false, false, false, null);
        resultBoolean = ProposalWizardServices.isSaveButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_REVIEW, UserServices.PROFILE_ACCOUNT_MANAGER, 'test role', true, false, null, incorrectProposalId, false, false, true, null);
        resultBoolean = ProposalWizardServices.isSaveButtonVisible('test status', UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', false, true, null, incorrectProposalId, false, true, true, null);
        resultBoolean = ProposalWizardServices.isCompleteButtonVisible(ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role');
        resultBoolean = ProposalWizardServices.isSubmitButtonVisible(ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false);
        resultBoolean = ProposalWizardServices.isSendForCZScopingReviewButtonVisible(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isSendToClientButtonVisible(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true);
        resultBoolean = ProposalWizardServices.isSendForInternalReviewButtonVisible(ProposalServices.PROPOSAL_STATUS_NEW, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true);
        resultBoolean = ProposalWizardServices.isCreator(null, null, null, null);
        resultBoolean = ProposalWizardServices.disableInputs(UserServices.PROFILE_PROPOSAL_SPECIALIST, ProposalServices.PROPOSAL_STATUS_NEW, 'test role', true, true, true, true, true);
        resultBoolean = ProposalWizardServices.disableInputs(UserServices.PROFILE_PROPOSAL_SPECIALIST, ProposalServices.PROPOSAL_STATUS_NEW, 'test role', true, true, true, true, true);
        resultBoolean = ProposalWizardServices.disableInputs(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, ProposalServices.PROPOSAL_STATUS_NEW, 'test role', false, false, true, false, false);
        resultBoolean = ProposalWizardServices.isAnyAllowedProfile(UserServices.PROFILE_ACCOUNT_MANAGER, 'test role');
        resultBoolean = ProposalWizardServices.isAnyAllowedProfile(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role');
        resultBoolean = ProposalWizardServices.isAnyAllowedProfile('some test profile', 'test role');
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled(ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW, UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', true, false, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled(null, null, 'test role', false, false, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled(ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW, UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled(null, null, 'test role', false, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled(null, null, 'test role', false, true, false, true, true, true, true);
        resultBoolean = ProposalWizardServices.areServiceButtonsEnabled('test status', 'test profile', 'test role', true, false, true, false, false, false, false);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true, false, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', false, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', false, true, false, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled('test status', 'test profile', 'test role', true, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.arePhasesButtonsEnabled('test status', UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', false, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true, false, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', false, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', false, true, false, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled('test status', 'test profile', 'test role', true, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled('test status', UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', true, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.areFloorButtonsEnabled('test status', 'test profile', 'test role', false, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test,role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled(null, null, 'test role', false, false, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled(null, null, 'test role', false, false, false, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', false, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled('test status', 'test profile', 'test role', true, false, true, false, false, true, true, false);
        resultBoolean = ProposalWizardServices.areContactButtonsEnabled('test status', 'test profile', 'test role', true, false, true, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.enableBillingPreferences(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test,role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableBillingPreferences('test status', 'test profile', 'test,role', true, false, true, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.enableAccountManager(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableAccountManager('test status', 'test profile', 'test role', true, false, true, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.enableAccountManager('test status', 'test profile', 'test role', false, false, true, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.isFulfillmentOfficeEnabled(ProposalServices.PROPOSAL_STATUS_AWARDED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFulfillmentOfficeEnabled('test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', false, false, true, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isClientProjectEnabled(ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED, UserServices.PROFILE_PROJECT_MANAGER_2, 'test,role', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isClientProjectEnabled('test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test,role', true, false, true, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.isAddPurchaseOrderButtonEnabled('test status', UserServices.PROFILE_BILLING_COORDINATOR, 'test role', true, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isAddPurchaseOrderButtonEnabled(ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW, UserServices.PROFILE_CODE_ZONING_ANALYST, UserServices.ROLE_LI_CZ_MANAGER, false, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isAddPurchaseOrderButtonEnabled(ProposalServices.PROPOSAL_STATUS_WITHDRAWN, UserServices.PROFILE_BILLING_COORDINATOR, UserServices.ROLE_LI_CZ_MANAGER, false, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isAddPurchaseOrderButtonEnabled('test status', UserServices.PROFILE_BILLING_COORDINATOR, UserServices.ROLE_LI_CZ_MANAGER, false, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isAttachingFilesEnabled('test status', UserServices.PROFILE_SIPS_COORDINATOR, 'test role', false, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isAttachingFilesEnabled('test status', UserServices.PROFILE_SIPS_COORDINATOR, 'test role', true, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isFollowUpButtonVisible('test status', UserServices.EXECUTIVE_ADMIN_PROFILE_NAME, 'test role', false);
        resultBoolean = ProposalWizardServices.isSendForInternalReviewButtonVisible('test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, false);
        resultBoolean = ProposalWizardServices.isSaveDraftButtonVisible('test status', UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', true, incorrectProposalId, true, true);
        resultBoolean = ProposalWizardServices.isVisibleForSIPS(true, ProposalServices.PROPOSAL_STATUS_IN_REVIEW, true, incorrectCOIdString, null);
        resultBoolean = ProposalWizardServices.isVisibleForSIPS(true, ProposalServices.PROPOSAL_STATUS_AWARDED, false, incorrectCOIdString, ChangeOrderServices.STATUS_IN_INT_REVIEW);
        resultBoolean = ProposalWizardServices.isServiceGroupRequired(true, true, 'test status', false, incorrectCOIdString);
        resultBoolean = ProposalWizardServices.isPhasesVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isPhasesVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, false, true);
        resultBoolean = ProposalWizardServices.isPhasesVisible(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, false, true);
        resultBoolean = ProposalWizardServices.isPhasesEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isPhasesEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isPhasesEditable(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER , 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ProposalServices.PROPOSAL_STATUS_IN_REVIEW, true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsVisible(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', ProposalServices.PROPOSAL_STATUS_IN_REVIEW, true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isFloorsEditable(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isServiceGroupVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isServiceGroupVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isServiceGroupEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isServiceGroupEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isServiceGroupEditable(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isPurchaseOrderVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.isPurchaseOrderVisible(UserServices.PROFILE_FINANCE_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, false, false, true);
        resultBoolean = ProposalWizardServices.isPurchaseOrderVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.isPurchaseOrderEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true);
        resultBoolean = ProposalWizardServices.isPurchaseOrderEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', userinfo.getuserid(), null, null, 'test status', true, true, true, true);
        resultBoolean = ProposalWizardServices.isMunicipalAgencyVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.isMunicipalAgencyEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isMunicipalAgencyEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, false, false);
        resultBoolean = ProposalWizardServices.isMunicipalAgencyEditable(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, false, false);
        resultBoolean = ProposalWizardServices.isUnitOfServiceVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitOfServiceVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitOfServiceVisible(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityVisible(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isQuantityEditable(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, false, false, false, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitPriceVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitPriceVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitPriceEditable('test', 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isUnitPriceEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isLastPriceVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isLastPriceVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isTotalPriceVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isTotalPriceVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isActivityStatusVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isActivityStatusVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isMovableVisible('test', 'test role', 'test', true, 'test', 'test', null, null, null, true, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isMovableVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', null, null, null, true, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isMovableVisible(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test', true, 'test', 'test', null, null, null, true, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.isRemoveVisible('test', 'test role', 'test', false, 'test', 'test', null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.isRemoveVisible(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', false, 'test', 'test', null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.isRemoveEditable('test', 'test role', 'test', true, 'test', 'test', UserInfo.getUserId(), null, null, 'test status', true, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.isRemoveEditable(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test', true, 'test', 'test', UserInfo.getUserId(), null, null, 'test status', true, true, true, true, false, false, true, true);
        resultBoolean = ProposalWizardServices.showMoveServices('test profile', 'test role', null, null, null, null, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.showMoveServices(UserServices.PROFILE_PROJECT_MANAGER, 'test role', null, null, null, null, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.showSaveServiceBundle('test profile', 'test role', null, true, null, null, null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.showSaveServiceBundle(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', null, true, null, null, null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.enableSaveServiceBundle('test profile', 'test role', '', true, '', '', null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.enableSaveServiceBundle(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', '', true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableSaveServiceBundle(UserServices.PROFILE_PROJECT_MANAGER, 'test role', '', true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showAddNewService('test profile', 'test role', ChangeOrderServices.STATUS_CANCELED, true, null, null, null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.showAddNewService(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_CANCELED, true, null, null, null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableAddNewService ('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, true, '', '', null, null, null, true, true, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.enableAddNewService (UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_DRAFT, true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableAddNewService (UserServices.PROFILE_PROJECT_MANAGER, 'test role', ChangeOrderServices.STATUS_DRAFT, true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableAddNewService (UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', ChangeOrderServices.STATUS_DRAFT, true, '', '', null, null, null, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.showInsertServiceBundle('test profile', 'test role', 'test status', true, null, null, null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showInsertServiceBundle(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', true, null, null, null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showInsertServiceBundle(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', true, null, null, null, null, null, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.enableInsertServiceBundle('test profile', 'test role', '', true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableInsertServiceBundle(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', '', true, '', '', null, null, null, false, false, false, false, false, false, false);
        resultBoolean = ProposalWizardServices.enableInsertServiceBundle(UserServices.PROFILE_PROJECT_MANAGER, 'test role', '', true, '', '', null, null, null, true, true, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showRemoveChangeOrder('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.showRemoveChangeOrder(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showRemoveChangeOrder(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, true, true, true, true, false);
        resultBoolean = ProposalWizardServices.enableRemoveChangeOrder('test profile', 'test role', 'test status', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableRemoveChangeOrder('test profile', 'test role', 'test status', null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.showCancelCORequest('test profile', 'test role', 'test status', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showCancelCORequest('test profile', 'test role', 'test status', null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.enableCancelCORequest('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableCancelCORequest('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.showSubmitCORequest('test profile', 'test role', 'test status', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showSubmitCORequest('test profile', 'test role', 'test status', null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.showSubmitCORequest(UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER, 'test role', 'test status', null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableSubmitCORequest('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.enableSubmitCORequest('test profile', 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, false, false, false, true, false);
        resultBoolean = ProposalWizardServices.enableSubmitCORequest(UserServices.PROFILE_PROJECT_MANAGER, 'test role', ChangeOrderServices.STATUS_DRAFT, null, null, null, true, true, true, true, true);
        resultBoolean = ProposalWizardServices.showSendForCZReview('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showSendForCZReview(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.getShowSendForSIPSCoordinator('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.getShowSendForSIPSCoordinator(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendForCZReview('test profile', 'test role', ChangeOrderServices.STATUS_REQUESTED, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendForCZReview(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showComplete(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showCompleteSIPS('test status', true);
        resultBoolean = ProposalWizardServices.enableComplete(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_IN_CZ_REVIEW, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showSendForInternalReview('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showSendForInternalReview(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendForInternalReview('test profile', 'test role', ChangeOrderServices.STATUS_REJECTED, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendForInternalReview(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', ChangeOrderServices.STATUS_REJECTED, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showSendToClient('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showSendToClient(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendToClient('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableSendToClient(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', ChangeOrderServices.STATUS_REJECTED, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showReSendToClient('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showReSendToClient(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test co status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableReSendToClient('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableReSendToClient(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test co status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showFollowUp('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableFollowUp('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showApproveChangeOrderIR(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableApproveChangeOrderIR(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_IN_INT_REVIEW, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showRejectChangeOrderIR(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.isCZAssignmentVisible(UserServices.PROFILE_CODE_ZONING_ANALYST, 'test role', ChangeOrderServices.STATUS_IN_CZ_REVIEW, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.isSIPSAssignmentVisible(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER, null, null, ChangeOrderServices.STATUS_IN_INT_REVIEW);
        resultBoolean = ProposalWizardServices.enableRejectChangeOrderIR(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_IN_INT_REVIEW, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showApproveChangeOrderPS('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showApproveChangeOrderPS(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableApproveChangeOrderPS('test profile', 'test role', ChangeOrderServices.STATUS_PENDING_CLIENT, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableApproveChangeOrderPS(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_PENDING_CLIENT, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showRejectChangeOrderPS('test profile', 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.showRejectChangeOrderPS(UserServices.PROFILE_PROPOSAL_SPECIALIST, 'test role', 'test status', null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableRejectChangeOrderPS('test profile', 'test role', ChangeOrderServices.STATUS_PENDING_CLIENT, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.enableRejectChangeOrderPS(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN, 'test role', ChangeOrderServices.STATUS_PENDING_CLIENT, null, null, null, true, true, true);
        resultBoolean = ProposalWizardServices.disableReceivedSignedProposalCheckbox(new Proposal__c(Status__c = ''), false, UserServices.EXECUTIVE_ADMIN_PROFILE_NAME, 'test role');
        resultBoolean = ProposalWizardServices.isPreviewPdfDisabled(new Proposal__c(Status__c = 'test status', Is_Change_Order__c = false), true, 'test profile', false, true, false);
    }

    private static testmethod void testIsSomethingFromSecondSectionActive(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sowUseEgressOccupancy__c = false;
        testProposalDraftList[0].sowMultiplePhases__c = false;
        testProposalDraftList[0].sowOccupandLoadDiffers__c = false;
        testProposalDraftList[0].sowMeetingConfRooms__c = false;
        testProposalDraftList[0].sowTemporarySprinkler__c = false;
        testProposalDraftList[0].sowOpenFloorConnections__c = false;
        testProposalDraftList[0].sowSpecialPlaces__c = false;
        testProposalDraftList[0].sowFuelStorage__c = false;
        testProposalDraftList[0].sowTenantsWithGlassDoors__c = false;
        testProposalDraftList[0].sowExteriorSignage__c = false;
        testProposalDraftList[0].sowExteriorWork__c = false;

        System.assert(!ProposalWizardServices.isSomethingFromSecondSectionActive(testProposalDraftList[0]));
        testProposalDraftList[0].sowSpecialPlaces__c = true;
        System.assert(ProposalWizardServices.isSomethingFromSecondSectionActive(testProposalDraftList[0]));
    }

    private static testmethod void testGetCompleteness(){
        setupData();
        createProposalListForTest(1, true);
        List<String> proposalDraftFieldNameList = new List<String>{'Billing_Method__c', 'Billing_day__c'};
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].Partner_Approval_Required__c = false;
        testProposalDraftList[0].put(proposalDraftFieldNameList[0], 'test');
        Integer completenessResult;
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, null);
            serviceModelItem.isOriginal = true;
            serviceModelItem.isAlternative = false;
            serviceModelItem.serviceGroup = 'test';
            testServiceModelList.add(serviceModelItem);
        }
        completenessResult = ProposalWizardServices.getCompleteness(proposalDraftFieldNameList, testProposalDraftList[0], true, testServiceModelList);
        Integer integerValue = Math.round(100*(1 + 1)/(proposalDraftFieldNameList.size() + 1));
//      System.assertEquals(integerValue, completenessResult);
        for (String stringItem : proposalDraftFieldNameList){
            testProposalDraftList[0].put(stringItem, 'test');
        }
        completenessResult = ProposalWizardServices.getCompleteness(proposalDraftFieldNameList, testProposalDraftList[0], true, testServiceModelList);
        System.assertEquals(100, completenessResult);
    }

    private static testmethod void testGetServiceItemsMapAlternativeServices(){
        setupData();
        createProposalListForTest(1, true);

        createPhaseListForTest(NUMBER_TO_CREATE_PHASE, false);
        for (Phase__c phaseItem : testPhaseList){
            phaseItem.Proposal__c = testProposalList[0].id;
        }

        insert testPhaseList;
        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItemItem.Phase__c = phaseItem.Id;
                serviceItemItem.Is_Alternative__c = false;
                testServiceItemList.add(serviceItemItem);
            }
        }
        insert testServiceItemList;

        Test.startTest();
            Map<Id, Service_Item__c> resultServiceItemMap = ProposalWizardServices.getServiceItemsMap(testProposalList[0]);
        Test.stopTest();

        System.assertEquals(testServiceItemList.size(), resultServiceItemMap.size());
        System.assertEquals(new Map<Id, Service_Item__c>(testServiceItemList).keySet(), resultServiceItemMap.keySet());
    }

    private static testmethod void testGetServiceItemsMapNotAlternativeServices(){
        setupData();
        createProposalListForTest(1, true);

        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Proposal__c = testProposalList[0].id;
            serviceItemItem.Is_Alternative__c = true;
        }
        insert testServiceItemList;

        Test.startTest();
            Map<Id, Service_Item__c> resultServiceItemMap = ProposalWizardServices.getServiceItemsMap(testProposalList[0]);
        Test.stopTest();

        System.assertEquals(testServiceItemList.size(), resultServiceItemMap.size());
        System.assertEquals(new Map<Id, Service_Item__c>(testServiceItemList).keySet(), resultServiceItemMap.keySet());
    }

    private static testmethod void testGetServiceTemplatesMap(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        List<Id> serviceTemplateIdList = new List<Id>();
        serviceTemplateIdList.addAll(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet());
        Test.startTest();
            Map<Id, Service_Template__c> resultServicaTemplateMap = ProposalWizardServices.getServiceTemplatesMap(serviceTemplateIdList);
        Test.stopTest();
        System.assertEquals(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), resultServicaTemplateMap.keySet());
    }

    private static testmethod void testGetServiceIdToClientPrice(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testClientPriceList = new List<Client_Price__c>();
        for (Account accountItem : testAccountList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Client_Price__c clientPriceItem : TestingUtils.createClientPriceList(1, false)){
                    clientPriceItem.Service__c = serviceTemplateItem.Id;
                    clientPriceItem.Client__c = accountItem.Id;
                    testClientPriceList.add(clientPriceItem);
                }
            }
        }
        insert testClientPriceList;
        Test.startTest();
            Map<Id, Client_Price__c> resultServicaTemplateClientPriceMap = ProposalWizardServices.getServiceIdToClientPrice(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), testAccountList[0].Id);
        Test.stopTest();

        System.assertEquals(testServiceTemplateList.size(), resultServicaTemplateClientPriceMap.size());
        System.assertEquals(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), resultServicaTemplateClientPriceMap.keySet());
        for(Id serviceTemplateId : resultServicaTemplateClientPriceMap.keySet()){
            Client_Price__c clientPriceItem = resultServicaTemplateClientPriceMap.get(serviceTemplateId);
            System.assertEquals(testAccountList[0].Id, clientPriceItem.Client__c);
            System.assertEquals(serviceTemplateId, clientPriceItem.Service__c);
        }
    }

    private static testmethod void testGetServiceIdToLastProposalPrice(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testLastProposalPriceList = new List<Last_Proposal_Price__c>();
        for (Account accountItem : testAccountList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Last_Proposal_Price__c lastProposalPriceItem : TestingUtils.createLastProposalPriceList(1, false)){
                    lastProposalPriceItem.Service__c = serviceTemplateItem.Id;
                    lastProposalPriceItem.Client__c = accountItem.Id;
                    testLastProposalPriceList.add(lastProposalPriceItem);
                }
            }
        }
        insert testLastProposalPriceList;

        Map<Id, Last_Proposal_Price__c> resultServiceTemplateLastProposalPriceMap;

        Test.startTest();
            resultServiceTemplateLastProposalPriceMap = ProposalWizardServices.getServiceIdToLastProposalPrice(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), testAccountList[0].Id);
        Test.stopTest();

        System.assertEquals(testServiceTemplateList.size(), resultServiceTemplateLastProposalPriceMap.size());
        System.assertEquals(new Map<Id, Service_Template__c>(testServiceTemplateList).keySet(), resultServiceTemplateLastProposalPriceMap.keySet());
        for(Id serviceTemplateId : resultServiceTemplateLastProposalPriceMap.keySet()){
            Last_Proposal_Price__c lastProposalPriceItem = resultServiceTemplateLastProposalPriceMap.get(serviceTemplateId);
            System.assertEquals(testAccountList[0].Id, lastProposalPriceItem.Client__c);
            System.assertEquals(serviceTemplateId, lastProposalPriceItem.Service__c);
        }
    }

    private static testmethod void testGetServiceTemplatesMapByServiceRowNumberAndMunicipalities(){
        List<String> municipalitiesNameValueList = new List<String>();
        for (Schema.PicklistEntry ple : Service_Template__c.Region__c.getDescribe().getPicklistValues()){
            municipalitiesNameValueList.add(ple.getValue());
        }
        List<String> serviceTemplateRowNumberList = new List<String>();
        testServiceTemplateList = new List<Service_Template__c>();
        for (String munucipalitiesNameItem : municipalitiesNameValueList){
            Integer serviceRowNumberValue = 0;
            for (Service_Template__c serviceTemplateItem : TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, false)){
                serviceTemplateItem.Region__c = munucipalitiesNameItem;
                serviceTemplateItem.Service_Row_Number__c = 'APS' + String.valueOf(serviceRowNumberValue++);
                testServiceTemplateList.add(serviceTemplateItem);
                serviceTemplateRowNumberList.add(serviceTemplateItem.Service_Row_Number__c);
            }
        }
        insert testServiceTemplateList;

        Map<Id, Service_Template__c> resultMap;

        Test.startTest();
            resultMap = ProposalWizardServices.getServiceTemplatesMap(serviceTemplateRowNumberList, municipalitiesNameValueList[0]);
        Test.stopTest();

        System.assert(!resultMap.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_SERVICE_TEMPLATE, resultMap.size());
        for (Service_Template__c serviceTemplateItem : resultMap.values()){
            System.assertEquals(municipalitiesNameValueList[0], serviceTemplateItem.Region__c);
        }
    }

    private static testmethod void testGetServiceBundleItems(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testServiceBundleList = TestingUtils.createServiceBundleList(NUMBER_TO_CREATE_SERVICE_BUNDLE, null, true);
        testServiceBundleItemList = new List<Service_Bundle_Item__c>();
        for (Service_Bundle__c serviceBundleItem : testServiceBundleList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Bundle_Item__c serviceBundleItemItem : TestingUtils.createServiceBundleItemList(serviceTemplateItem.Id, serviceBundleItem.Id, false)){
                    testServiceBundleItemList.add(serviceBundleItemItem);
                }
            }
        }
        insert testServiceBundleItemList;

        Map<Id, Service_Bundle_Item__c> temporaryServiceBundleItemMap = new Map<Id, Service_Bundle_Item__c>(testServiceBundleItemList);

        List<Service_Bundle_Item__c> resultServiceBundleList;

        Test.startTest();
            resultServiceBundleList = ProposalWizardServices.getServiceBundleItems(testServiceBundleList[0].Id);
        Test.stopTest();

        System.assert(!resultServiceBundleList.isEmpty());
        System.assertEquals(testServiceTemplateList.size(), resultServiceBundleList.size());
        for(Service_Bundle_Item__c serviceBundleItemItem : resultServiceBundleList){
            System.assertEquals(testServiceBundleList[0].Id, temporaryServiceBundleItemMap.get(serviceBundleItemItem.Id).Service_Bundle__c);
        }
    }

    private static testmethod void testGetServiceRowNumbersFromBundleItems(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testServiceBundleList = TestingUtils.createServiceBundleList(NUMBER_TO_CREATE_SERVICE_BUNDLE, null, true);
        testServiceBundleItemList = new List<Service_Bundle_Item__c>();
        for (Service_Bundle__c serviceBundleItem : testServiceBundleList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Bundle_Item__c serviceBundleItemItem : TestingUtils.createServiceBundleItemList(serviceTemplateItem.Id, serviceBundleItem.Id, false)){
                    testServiceBundleItemList.add(serviceBundleItemItem);
                }
            }
        }
        insert testServiceBundleItemList;

        testServiceBundleItemList = [SELECT Id, Service_Row_Number__c
                                     FROM Service_Bundle_Item__c
                                     WHERE Id IN : testServiceBundleItemList];

        List<String> resultStringList;

        Test.startTest();
            resultStringList = ProposalWizardServices.getServiceRowNumbersFromBundleItems(testServiceBundleItemList, testServiceBundleList[0].Id);
        Test.stopTest();

        System.assert(!resultStringList.isEmpty());
        System.assertEquals(testServiceBundleItemList.size(), resultStringList.size());
    }

    private static testmethod void testRecordTypeIdToNameMap(){
        Map<String, Id> testRecordTypeNameRecordTypeIdMap = new Map<String, Id>();
        for (RecordType recordTypeItem : [SELECT Id, Name
                                          FROM RecordType LIMIT 1]){
            testRecordTypeNameRecordTypeIdMap.put(recordTypeItem.Name, recordTypeItem.Id);
        }

        Map<Id, String> resultRecordTypeIdNameMap;

        Test.startTest();
            resultRecordTypeIdNameMap = ProposalWizardServices.recordTypeIdToNameMap(testRecordTypeNameRecordTypeIdMap);
        Test.stopTest();

        System.assert(resultRecordTypeIdNameMap != null);
    }

    private static testmethod void testRecordTypeNameToId(){
        Map<String, Id> resultRecordTypeNameIdMap;

        Test.startTest();
            resultRecordTypeNameIdMap = ProposalWizardServices.recordTypeNameToId();
        Test.stopTest();

        System.assert(resultRecordTypeNameIdMap != null);
    }

    private static testmethod void testGetQuestionListNewBuilding(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sowScopeOfWork__c = 'New Building';
        testProposalDraftList[0].sowUseEgressOccupancy__c = true;
        testProposalDraftList[0].sowMultiplePhases__c = true;
        testProposalDraftList[0].sowOccupandLoadDiffers__c = true;
        testProposalDraftList[0].sowMeetingConfRooms__c = true;
        testProposalDraftList[0].sowTemporarySprinkler__c = true;
        testProposalDraftList[0].sowOpenFloorConnections__c = true;
        testProposalDraftList[0].sowSpecialPlaces__c = true;
        testProposalDraftList[0].sowFuelStorage__c = true;
        testProposalDraftList[0].sowTenantsWithGlassDoors__c = true;
        testProposalDraftList[0].sowExteriorSignage__c = true;
        testProposalDraftList[0].sowExteriorWork__c = true;
        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = true;
        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = true;
        testProposalDraftList[0].sow_sp_ssb__c = true;
        testProposalDraftList[0].sow_sp_ssd__c = true;
        testProposalDraftList[0].sow_sp_tls__c = true;
        testProposalDraftList[0].sow_sm_bow__c = true;
        testProposalDraftList[0].sow_sm_dwk__c = true;

        List<String> resultStringList;

        Test.startTest();
            resultStringList = ProposalWizardServices.getQuestionList(true, testProposalDraftList[0]);
        Test.stopTest();
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetQuestionListHUBProject(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sowScopeOfWork__c = 'HUB Project';
        testProposalDraftList[0].sowUseEgressOccupancy__c = true;
        testProposalDraftList[0].sowMultiplePhases__c = true;
        testProposalDraftList[0].sowOccupandLoadDiffers__c = true;
        testProposalDraftList[0].sowMeetingConfRooms__c = true;
        testProposalDraftList[0].sowTemporarySprinkler__c = true;
        testProposalDraftList[0].sowOpenFloorConnections__c = true;
        testProposalDraftList[0].sowSpecialPlaces__c = true;
        testProposalDraftList[0].sowFuelStorage__c = true;
        testProposalDraftList[0].sowTenantsWithGlassDoors__c = true;
        testProposalDraftList[0].sowExteriorSignage__c = true;
        testProposalDraftList[0].sowExteriorWork__c = true;
        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = true;
        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = true;
        testProposalDraftList[0].sow_sp_ssb__c = true;
        testProposalDraftList[0].sow_sp_ssd__c = true;
        testProposalDraftList[0].sow_sp_tls__c = true;
        testProposalDraftList[0].sow_sm_bow__c = true;
        testProposalDraftList[0].sow_sm_dwk__c = true;

        List<String> resultStringList;

        Test.startTest();
            resultStringList = ProposalWizardServices.getQuestionList(true, testProposalDraftList[0]);
        Test.stopTest();
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetQuestionList(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sowScopeOfWork__c = 'other text';
        testProposalDraftList[0].sowUseEgressOccupancy__c = true;
        testProposalDraftList[0].sowMultiplePhases__c = true;
        testProposalDraftList[0].sowOccupandLoadDiffers__c = true;
        testProposalDraftList[0].sowMeetingConfRooms__c = true;
        testProposalDraftList[0].sowTemporarySprinkler__c = true;
        testProposalDraftList[0].sowOpenFloorConnections__c = true;
        testProposalDraftList[0].sowSpecialPlaces__c = true;
        testProposalDraftList[0].sowFuelStorage__c = true;
        testProposalDraftList[0].sowTenantsWithGlassDoors__c = true;
        testProposalDraftList[0].sowExteriorSignage__c = true;
        testProposalDraftList[0].sowExteriorWork__c = true;
        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = true;
        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = true;
        testProposalDraftList[0].sow_sp_ssb__c = true;
        testProposalDraftList[0].sow_sp_ssd__c = true;
        testProposalDraftList[0].sow_sp_tls__c = true;
        testProposalDraftList[0].sow_sm_bow__c = true;
        testProposalDraftList[0].sow_sm_dwk__c = true;

        List<String> resultStringList;

        Test.startTest();
            resultStringList = ProposalWizardServices.getQuestionList(true, testProposalDraftList[0]);
        Test.stopTest();
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetIrServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_ir_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = null;

        List<String> resultStringList;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, false, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Interior Renovation';
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sowACUnits__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = false;
        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_pl__c = false;
        testProposalDraftList[0].sow_ir_st__c = false;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], true, true, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sowACUnits__c = true;
        testProposalDraftList[0].sow_ir_aw__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = false;
        testProposalDraftList[0].sow_ir_mw__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_pl__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = false;
        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_pl__c = false;
        testProposalDraftList[0].sow_ir_st__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = false;
        testProposalDraftList[0].sow_ir_st__c = false;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_st__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = false;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = false;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = false;
        testProposalDraftList[0].sow_ir_st__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_ir_aw__c = true;
        testProposalDraftList[0].sow_ir_mw__c = true;
        testProposalDraftList[0].sow_ir_pl__c = true;
        testProposalDraftList[0].sow_ir_st__c = true;

        resultStringList = ProposalWizardServices.getIrServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetIdServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_id_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = null;

        List<String> resultStringList;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, false, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Interior Demolition';

        testProposalDraftList[0].sow_id_aw__c = false;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = false;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], true, false, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_override__c = null;

        testProposalDraftList[0].sow_id_aw__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = false;
        testProposalDraftList[0].sow_id_mw__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = false;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = false;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = false;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = false;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = false;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = false;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_id_aw__c = true;
        testProposalDraftList[0].sow_id_mw__c = true;
        testProposalDraftList[0].sow_id_pl__c = true;
        testProposalDraftList[0].sow_id_st__c = true;

        resultStringList = ProposalWizardServices.getIdServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetErServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_er_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = null;

        List<String> resultStringList;

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, false, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Exterior Repairs or Modification';

        testProposalDraftList[0].sow_er_be__c = false;
        testProposalDraftList[0].sow_er_ba__c = false;
        testProposalDraftList[0].sow_er_bas__c = '';
        testProposalDraftList[0].sowFencePermit__c = false;

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], true, false, false);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_override__c = null;

        testProposalDraftList[0].sow_er_be__c = true;
        testProposalDraftList[0].sow_er_ba__c = false;
        testProposalDraftList[0].sow_er_bas__c = '';
        testProposalDraftList[0].sowFencePermit__c = false;

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_be__c = false;
        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = 'Sign';

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = 'Curb cut';

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = 'Antennae';

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = 'Sidewalk repair';

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = '';
        testProposalDraftList[0].sowFencePermit__c = true;

        resultStringList = ProposalWizardServices.getErServices(testProposalDraftList[0], false, true, false);
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetFaServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sowScopeOfWork__c = null;
        List<String> resultStringList;
        resultStringList = ProposalWizardServices.getFaServices(testProposalDraftList[0], true, true, true);

        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Fire Alarm Modification';
        resultStringList = ProposalWizardServices.getFaServices(testProposalDraftList[0], true, true, true);
        System.assert(!resultStringList.isEmpty());
        System.assertEquals(new List<String>{'APS11', 'APS35'}, resultStringList);
    }

    private static testmethod void testGetSpServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_sp_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = null;

        List<String> resultStringList;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], true, true, true);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_override__c = null;
        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Sprinkler System Modification';
        testProposalDraftList[0].sow_sp_ssb__c = false;
        testProposalDraftList[0].sow_sp_ssd__c = false;
        testProposalDraftList[0].sow_sp_tls__c = false;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], true, true, true);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = false;
        testProposalDraftList[0].sow_sp_ssd__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = false;
        testProposalDraftList[0].sow_sp_ssd__c = false;
        testProposalDraftList[0].sow_sp_tls__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = true;
        testProposalDraftList[0].sow_sp_ssd__c = true;
        testProposalDraftList[0].sow_sp_tls__c = false;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = false;
        testProposalDraftList[0].sow_sp_ssd__c = true;
        testProposalDraftList[0].sow_sp_tls__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssb__c = true;
        testProposalDraftList[0].sow_sp_ssd__c = false;
        testProposalDraftList[0].sow_sp_tls__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sp_ssd__c = true;

        resultStringList = ProposalWizardServices.getSpServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testGetSmServices(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_sm_override__c = 'Professional';
        testProposalDraftList[0].sowScopeOfWork__c = null;

        List<String> resultStringList;

        resultStringList = ProposalWizardServices.getSmServices(testProposalDraftList[0], true, true, true);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_sm_override__c = null;
        testProposalDraftList[0].sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposalDraftList[0].sowServicesNeededAPS__c = true;
        testProposalDraftList[0].sowNoneOfTheAbove__c = true;
        testProposalDraftList[0].sowSpaceAlterType__c = 'Standpipe Modification';
        testProposalDraftList[0].sow_sm_bow__c = false;
        testProposalDraftList[0].sow_sm_dwk__c = false;

        resultStringList = ProposalWizardServices.getSmServices(testProposalDraftList[0], true, true, true);
        System.assert(resultStringList.isEmpty());

        testProposalDraftList[0].sow_sm_bow__c = true;

        resultStringList = ProposalWizardServices.getSmServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());

        testProposalDraftList[0].sow_sm_bow__c = false;
        testProposalDraftList[0].sow_sm_dwk__c = true;

        resultStringList = ProposalWizardServices.getSmServices(testProposalDraftList[0], false, true, true);
        System.assert(!resultStringList.isEmpty());
    }

    private static testmethod void testIsIrValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_ir_aw__c = false;
        testProposalDraftList[0].sow_ir_mw__c = false;
        testProposalDraftList[0].sow_ir_pl__c = false;
        testProposalDraftList[0].sow_ir_st__c = false;

        Test.startTest();
            System.assert(!ProposalWizardServices.isIrValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    private static testmethod void testIsIdValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_id_aw__c = false;
        testProposalDraftList[0].sow_id_mw__c = false;
        testProposalDraftList[0].sow_id_pl__c = false;
        testProposalDraftList[0].sow_id_st__c = false;

        Test.startTest();
            System.assert(!ProposalWizardServices.isIdValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    private static testmethod void testIsErValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_er_be__c = false;
        testProposalDraftList[0].sow_er_ba__c = true;
        testProposalDraftList[0].sow_er_bas__c = '';
        testProposalDraftList[0].sowFencePermit__c = false;

        Test.startTest();
            System.assert(!ProposalWizardServices.isErValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    private static testmethod void testIsFaValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);

        Test.startTest();
            System.assert(ProposalWizardServices.isFaValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    private static testmethod void testIsSpValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_sp_ssb__c = false;
        testProposalDraftList[0].sow_sp_ssd__c = false;
        testProposalDraftList[0].sow_sp_tls__c = false;

        Test.startTest();
            System.assert(!ProposalWizardServices.isSpValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    private static testmethod void testIsSmValidEmpty(){
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        testProposalDraftList[0].sow_sm_bow__c = false;
        testProposalDraftList[0].sow_sm_dwk__c = false;

        Test.startTest();
            System.assert(!ProposalWizardServices.isSmValidEmpty(testProposalDraftList[0]));
        Test.stopTest();
    }

    /*private static testmethod void testCreateProposalPDF(){
        setupData ();
        createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        testFolderList = [SELECT Id
                          FROM Folder LIMIT : NUMBER_TO_GET_FOLDER_FOR_TEST];

        testDocumentList = new List<Document>();
        for (Folder folderItem : testFolderList){
            for (Document documentItem : TestingUtils.createDocumentList(NUMBER_TO_CREATE_DOCUMENT, null, folderItem.Id, false)){
                documentItem.Description = documentItem.Name;
                testDocumentList.add(documentItem);
            }
        }
        insert testDocumentList;
        testDocumentWrapperList = new List<DocumentWrapper>();
        for (Document documentItem : testDocumentList){
            testDocumentWrapperList.add(new DocumentWrapper(documentItem));
        }

        testLoopDDPList = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE_LOOP_DDP, false);
        testLoopDDPList[0].Name = ProposalWizardServices.PROPOSAL_DDP_NAME;
        insert testLoopDDPList;

        testLoopDDPFileList = new List<Loop__DDP_File__c>();
        for (Loop__DDP__c loopDDPItem : testLoopDDPList){
            for (Loop__DDP_File__c loopDDPFileItem : TestingUtils.createLoopDDPFileList(NUMBER_TO_CREATE_LOOP_DDP_FILE, loopDDPItem.Id, false)){
                if (loopDDPItem.Name == ProposalWizardServices.PROPOSAL_DDP_NAME){
                    loopDDPFileItem.Loop__Compare_Field__c = PROPOSAL_RFP_ATTACHMENTS;
                }
                testLoopDDPFileList.add(loopDDPFileItem);
            }
        }
        insert testLoopDDPFileList;

        testLoopDDPIntegrationOptionList = new List<Loop__DDP_Integration_Option__c>();
        for (Loop__DDP__c loopDDPItem : testLoopDDPList){
            for (Loop__DDP_Integration_Option__c loopDDPIntegrationOptionItem : TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE_LOOP_DDP_INTEGRATION_OPTIONS, loopDDPItem.Id, false)){
                loopDDPIntegrationOptionItem.Name = LOOP_DDP_INTEGRATION_OPTIONS_NAME;
                testLoopDDPIntegrationOptionList.add(loopDDPIntegrationOptionItem);
            }
        }
        insert testLoopDDPIntegrationOptionList;

        Test.startTest();
            testPageReference = ProposalWizardServices.createProposalPDF(testProposalList[0], testContactWithAccountList[0].Id, ProposalWizardServices.PROPOSAL_DDP_NAME, LOOP_DDP_INTEGRATION_OPTIONS_NAME, testDocumentWrapperList);
        Test.stopTest();

        System.assert(testPageReference != null);
    }*/

    /*private static testmethod void testCreateProposalPDFWithEmptyDeliveryMethod(){
        setupData ();
        createProposalListForTest(NUMBER_TO_CREATE_PROPOSAL, true);

        testFolderList = [SELECT Id
                          FROM Folder LIMIT : NUMBER_TO_GET_FOLDER_FOR_TEST];

        testDocumentList = new List<Document>();
        for (Folder folderItem : testFolderList){
            for (Document documentItem : TestingUtils.createDocumentList(NUMBER_TO_CREATE_DOCUMENT, null, folderItem.Id, false)){
                documentItem.Description = documentItem.Name;
                testDocumentList.add(documentItem);
            }
        }
        insert testDocumentList;

        testDocumentWrapperList = new List<DocumentWrapper>();
        for (Document documentItem : testDocumentList){
            testDocumentWrapperList.add(new DocumentWrapper(documentItem));
        }

        testLoopDDPList = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE_LOOP_DDP, false);
        testLoopDDPList[0].Name = ProposalWizardServices.PROPOSAL_DDP_NAME;
        insert testLoopDDPList;

        testLoopDDPFileList = new List<Loop__DDP_File__c>();
        for (Loop__DDP__c loopDDPItem : testLoopDDPList){
            for (Loop__DDP_File__c loopDDPFileItem : TestingUtils.createLoopDDPFileList(NUMBER_TO_CREATE_LOOP_DDP_FILE, loopDDPItem.Id, false)){
                if (loopDDPItem.Name == ProposalWizardServices.PROPOSAL_DDP_NAME){
                    loopDDPFileItem.Loop__Compare_Field__c = PROPOSAL_RFP_ATTACHMENTS;
                }
                testLoopDDPFileList.add(loopDDPFileItem);
            }
        }
        insert testLoopDDPFileList;

        testLoopDDPIntegrationOptionList = new List<Loop__DDP_Integration_Option__c>();
        for (Loop__DDP__c loopDDPItem : testLoopDDPList){
            for (Loop__DDP_Integration_Option__c loopDDPIntegrationOptionItem : TestingUtils.createLoopDDPIntegrationOptionList(NUMBER_TO_CREATE_LOOP_DDP_INTEGRATION_OPTIONS, loopDDPItem.Id, false)){
                loopDDPIntegrationOptionItem.Name = LOOP_DDP_INTEGRATION_OPTIONS_NAME;
                testLoopDDPIntegrationOptionList.add(loopDDPIntegrationOptionItem);
            }
        }
        insert testLoopDDPIntegrationOptionList;

        Test.startTest();
            testPageReference = ProposalWizardServices.createProposalPDF(testProposalList[0], testContactWithAccountList[0].Id, ProposalWizardServices.PROPOSAL_DDP_NAME, null, testDocumentWrapperList);
        Test.stopTest();

        System.assert(testPageReference != null);
    }*/

    /*private static testmethod void testUpdateAttachedDocuments(){
        testFolderList = [SELECT Id
                          FROM Folder LIMIT : NUMBER_TO_GET_FOLDER_FOR_TEST];

        testDocumentList = new List<Document>();
        for (Folder folderItem : testFolderList){
            for (Document documentItem : TestingUtils.createDocumentList(NUMBER_TO_CREATE_DOCUMENT, null, folderItem.Id, false)){
                documentItem.Description = documentItem.Name;
                testDocumentList.add(documentItem);
            }
        }
        insert testDocumentList;

        testDocumentWrapperList = new List<DocumentWrapper>();
        for (Document documentItem : testDocumentList){
            testDocumentWrapperList.add(new DocumentWrapper(documentItem));
        }

        for (DocumentWrapper documentWrapperItem : testDocumentWrapperList){
            documentWrapperItem.isAttached = true;
        }

        String resultString;

        Test.startTest();

            resultString = ProposalWizardServices.updateAttachedDocuments(testDocumentWrapperList);

        Test.stopTest();

        System.assert(!String.isEmpty(resultString));
        for (DocumentWrapper documentWrapperItem : testDocumentWrapperList){
            if(documentWrapperItem.isAttached){
                System.assert(resultString.contains(documentWrapperItem.documentName));
            }
        }
    }

    private static testmethod void testGetAssignmentsForProjectTeam(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);

        testTaskItemList = new List<Task_Item__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Project_Profile__c = projectProfileItem.Id;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testProjectTeamList = [SELECT Id, Name, Task_Items_Duration__c, Total_Duration__c,
                                    (Select Id, Primary_Company_Contact__c, Building__c
                                     From Projects__r)
                               FROM Project_Team__c
                               WHERE Id IN : testProjectTeamList];

        Map<Id, Project_Team__c> testProjectProfileWithProjectTeamMap = new Map<Id, Project_Team__c>();

        for (Project_Team__c projectTeamItem : testProjectTeamList){
            for (Project_Profile__c projectProfileItem : projectTeamItem.Projects__r){
                testProjectProfileWithProjectTeamMap.put(projectProfileItem.Id, projectTeamItem);
            }
        }

        List<AssignmentWrapper> resultAssignmentWrapperList;

        Test.startTest();

            resultAssignmentWrapperList = ProposalWizardServices.getAssignmentsForProjectTeam(testProposalDraftList[0], testProjectProfileWithProjectTeamMap, 'test');

        Test.stopTest();

        System.assert(resultAssignmentWrapperList != null);
    }*/

    private static testmethod void testGetProjectIdsFromProjectTeam(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testProjectTeamList = [SELECT Id,
                                    (Select Id
                                     From Projects__r)
                               FROM Project_Team__c
                               WHERE Id IN : testProjectTeamList];

        Set<Id> resultSetProjectProfileIdSet;

        Test.startTest();

            resultSetProjectProfileIdSet = ProposalWizardServices.getProjectIdsFromProjectTeam(testProjectTeamList);

        Test.stopTest();
    }

    private static testmethod void testGetProjectIdsFromUser(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        List<User> testPartnerUserList = [SELECT Id,
                                                (Select Id
                                                 From Projects2__r Limit 1)
                                          FROM User
                                          WHERE Id = : testProjectProfileList[0].Resource__c];

        Set<Id> resultSetProjectProfileIdSet;

        Test.startTest();

            resultSetProjectProfileIdSet = ProposalWizardServices.getProjectIdsFromUser(testPartnerUserList);

        Test.stopTest();

        System.assert(resultSetProjectProfileIdSet != null);
    }

    private static testmethod void testCreateServiceFloorJunctions(){
        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, true);
        testFloorList = TestingUtils.createFloorList(NUMBER_TO_CREATE_FLOOR, true);

        List<FloorWrapper> testFloorWrapperList = new List<FloorWrapper>();
        for (Floor__c floorItem : testFloorList){
            testFloorWrapperList.add(new FloorWrapper(floorItem));
        }

        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, null);
            serviceModelItem.isAlternative = false;
            testServiceModelList.add(serviceModelItem);
        }

        Test.startTest();

            testServiceFloorJunctionList = ProposalWizardServices.createServiceFloorJunctions(true, testServiceItemList, testServiceModelList, testFloorWrapperList, false);

        Test.stopTest();
    }

    private static testmethod void testGetChangeHistory(){
        List<Change_History_Proposal__c> resultChangeHistoryProposalList;
        resultChangeHistoryProposalList = ProposalWizardServices.getChangeHistory(null);
        resultChangeHistoryProposalList = ProposalWizardServices.getChangeHistory(UserInfo.getUserId());
    }

    private static testmethod void testIsUserAllowedToCreateChangeOrderOnProjectLevel(){
        TestingUtils.createProposalWithProjectProfileList(1);
        testProposalList = TestingUtils.testProposalList;
        testProposalList = [SELECT Id, Region__c, is_Change_Order__c, Project_Profile__r.OwnerId, Project_Profile__r.Account_Executive__c
                            FROM Proposal__c
                            WHERE Id IN : testProposalList];

        Boolean resultBoolean;

        resultBoolean = ProposalWizardServices.isUserAllowedToCreateChangeOrderOnProjectLevel (UserInfo.getUserId(), UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                                                               UserServices.ROLE_CZ_MANAGER, new Proposal__c (is_Change_Order__c = false));
        resultBoolean = ProposalWizardServices.isUserAllowedToCreateChangeOrderOnProjectLevel (UserInfo.getUserId(), UserServices.PROFILE_SHARED_SERVICES_MANAGER,
                                                                                               UserServices.ROLE_CZ_MANAGER, testProposalList[0]);
    }

    private static testmethod void testIsUserAllowedToCreateChangeOrderOnServiceItemLevel(){
        setupData();
        createProposalListForTest(1, true);
        testProposalList[0].is_Change_Order__c = true;

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, testProposalList[0].Id, true);

        testServiceModelList = new List<ServiceModel>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            ServiceModel serviceModelItem = new ServiceModel(serviceTemplateItem, null);
            serviceModelItem.isAlternative = false;
            testServiceModelList.add(serviceModelItem);
        }

        Boolean resultBoolean;
        resultBoolean = ProposalWizardServices.isUserAllowedToCreateChangeOrderOnServiceItemLevel(UserInfo.getUserId(), UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                  UserServices.ROLE_CZ_MANAGER, testProposalList[0], testServiceItemList, null);

        resultBoolean = ProposalWizardServices.isUserAllowedToCreateChangeOrderOnServiceItemLevel(UserInfo.getUserId(), UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                                                                  UserServices.ROLE_CZ_MANAGER, testProposalList[0], null, testServiceModelList);
    }

    private static testmethod void testIsCustomWorkTypeService(){
        Boolean resultBoolean = ProposalWizardServices.isCustomWorkTypeService('test', 'test', true);
        resultBoolean = ProposalWizardServices.isCustomWorkTypeService(RFIScopeServices.APPLICATION_SIGN_OFF, 'test', true);
        resultBoolean = ProposalWizardServices.isCustomWorkTypeService(RFIScopeServices.APPLICATION_SIGN_OFF, 'test', false);
    }

    private static testmethod void testIsCZSpesialistRequired(){
        Proposal__c testProposal = new Proposal__c();
        testProposal.Is_Draft__c = true;
        testProposal.sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE;
        testProposal.sowServicesNeededAPS__c = true;
        testProposal.sowUseEgressOccupancy__c = false;
        testProposal.sowMultiplePhases__c = false;
        testProposal.sowOccupandLoadDiffers__c = false;
        testProposal.sowMeetingConfRooms__c = false;
        testProposal.sowTemporarySprinkler__c = false;
        testProposal.sowOpenFloorConnections__c = false;
        testProposal.sowSpecialPlaces__c = false;
        testProposal.sowTenantsWithGlassDoors__c = false;
        testProposal.sowExteriorSignage__c = false;
        testProposal.sowFuelStorage__c = false;
        testProposal.sowExteriorWork__c = false;
        Boolean resultBoolean = ProposalWizardServices.isCZSpesialistRequired(testProposal);

        testProposal.Is_Draft__c = false;
        testProposal.Status__c = 'test status';
        resultBoolean = ProposalWizardServices.isCZSpesialistRequired(testProposal);
    }

    private static testmethod void testUniqueCombinationLastProposalPrice(){
        setupData();
        createProposalListForTest(1, true);
        Map<Id, Proposal__c> proposalMap = new Map<Id, Proposal__c>(testProposalList);

        testServiceTemplateList = TestingUtils.createServiceTemplateList(NUMBER_TO_CREATE_SERVICE_TEMPLATE, true);
        Map<Id, Service_Template__c> serviceTemplateMap = new Map<Id, Service_Template__c>(testServiceTemplateList);

        Map<Id, Last_Proposal_Price__c> serviceWithLastProposalPriceMap = new Map<Id, Last_Proposal_Price__c>();

        testLastProposalPriceList = new List<Last_Proposal_Price__c>();
        for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
            for (Last_Proposal_Price__c lastProposalPriceItem : TestingUtils.createLastProposalPriceList(1, false)){
                lastProposalPriceItem.Client__c = testProposalList[0].Billing_Company_Name__c;
                lastProposalPriceItem.Service__c = serviceTemplateItem.Id;
                serviceWithLastProposalPriceMap.put(serviceTemplateItem.Id, lastProposalPriceItem);
                testLastProposalPriceList.add(lastProposalPriceItem);
            }
        }
        insert testLastProposalPriceList;

        testServiceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Service_Template__c serviceTemplateItem : testServiceTemplateList){
                for (Service_Item__c serviceItemItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                    serviceItemItem.Service_Template__c = serviceTemplateItem.Id;
                    serviceItemItem.Proposal__c = proposalItem.Id;
                    testServiceItemList.add(serviceItemItem);
                }
            }
        }
        insert testServiceItemList;

        testServiceModelList = new List<ServiceModel>();
        for (Service_Item__c serviceItemItem : testServiceItemlist){
            ServiceModel serviceModelItem = new ServiceModel ( serviceItemItem,
                                                               serviceTemplateMap.get(serviceItemItem.Service_Template__c),
                                                               null,
                                                               serviceWithLastProposalPriceMap.get(serviceItemItem.Service_Template__c));
            testServiceModelList.add(serviceModelItem);
        }

        Map<String, Last_Proposal_Price__c> resulUniquetStringLastProposalPriceMap;

        Test.startTest();

            resulUniquetStringLastProposalPriceMap = ProposalWizardServices.uniqueCombinationLastProposalPrice(testServiceModelList, testProposalList[0]);

        Test.stopTest();
    }

    private static testMethod void testdoSort() {
        Selectoption[] opts = new Selectoption[] {
                                   new Selectoption('v1', 'l1'),
                                   new Selectoption('v5', 'l5')
                               };
       Test.startTest();
            ProposalWizardServices.doSort( opts );
       Test.stopTest();
       System.assertEquals('l1', opts[0].getLabel());
       System.assertEquals('l5', opts[1].getLabel());
    }

    private static testmethod void testGetServiceRowNumbers() {
        List<Floor__c> floors = new List<Floor__c>{ new Floor__c( Floor_Type__c = FloorServices.FLOOR_TYPE_REGULAR_FLOOR, Specification_Name__c = '1' ) };
        Test.startTest();
            List<String> servicesToAdd1 = ProposalWizardServices.getServiceRowNumbers( new Proposal__c( Expected_Construction_Start_Date__c = Date.today(),
                                                                                                              sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE,
                                                                                                              Asbestos__c = true,
                                                                                                              sowServicesNeededAPS__c = true ),
                                                                                       new Building__c( Is_Landmark__c = true,
                                                                                                        Is_MTA__c = true,
                                                                                                        Loft_Board_Authority__c = true,
                                                                                                        Little_E_Designation__c = true ),
                                                                                       floors );
            List<String> servicesToAdd2 = ProposalWizardServices.getServiceRowNumbers( new Proposal__c( Expected_Construction_Start_Date__c = Date.today(),
                                                                                                              sowScopeOfWork__c = ProposalWizardServices.SOW_EXISTING_SPACE,
                                                                                                              Asbestos__c = false,
                                                                                                              Asbestos_Investigation_Options__c = ProposalWizardServices.ASBESTOS_INVESTIGATION_OPTIONS_BY_OTHERS ),
                                                                                       new Building__c( Is_Landmark__c = false ),
                                                                                       floors );
        Test.stopTest();
    }

    private static testMethod void testForCoverage() {
        setupData();
        createProposalListForTest(1, true);
        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(1, false)){
                changeOrderItem.Proposal__c = testProposalList[0].Id;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        testServiceItemList = new List<Service_Item__c>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            for (Service_Item__c si : TestingUtils.createServiceItemList(1, changeOrderItem.Proposal__c, false)){
                si.Change_Order__c = changeOrderItem.Id;
                testServiceItemList.add(si);
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c si : testServiceItemList){
            for (Task_Item__c ti : TestingUtils.createTaskItemList(1, false)){
                ti.Service_Item__c = si.Id;
                testTaskItemList.add(ti);
            }
        }
        insert testTaskItemList;

        Test.startTest();

            ProposalWizardServices.getProposalRequiredFields( true, Datetime.now(), true );
            ProposalWizardServices.getUserNamesForAccountManagerDropdown();
            ProposalWizardServices.getUserNamesForSalespersonDropdown();
            ProposalWizardServices.getUserNamesForPartnerDropdown();
            Boolean testBoolean;
            testBoolean = ProposalWizardServices.getAccountIdToContactIdToContactName(new Set<String>{String.valueOf(testAccountList[0].Id)}) == null;
            testBoolean = ProposalWizardServices.getProposalForStep2(null) == null;
            testBoolean = ProposalWizardServices.getProposalForStep2(testProposalList[0].Id) == null;
            testBoolean = ProposalWizardServices.mergeFieldsFromStep2WithProposal(testProposalList[0], JSON.serialize(testProposalList[0])) == null;
            testBoolean = ProposalWizardServices.enableStep2Summary(testProposalList[0], true, true, true) == null;
            testBoolean = ProposalWizardServices.getProposalMergeFieldsById(new Set<String>{String.valueOf(testProposalList[0].Id)}) == null;
            testBoolean = ProposalWizardServices.getChangeOrderMergeFieldsById(new Set<String>{String.valueOf(testChangeOrderList[0].Id)}) == null;

            ProposalWizardModel testPWM = new ProposalWizardModel(testProposalList[0], new Project_Team__c(), 'test name', 'test role name');
            ChangeOrderModel testCOM = new ChangeOrderModel(testChangeOrderList[0],
                                                            UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                                            'test user role',
                                                            currentUserId,
                                                            testProposalList[0],
                                                            true,
                                                            testProjectTeamList[0],
                                                            true, true, true);
            testCOM.status = ChangeOrderServices.STATUS_PENDING_CLIENT;
            testPWM.notApprovedChangeOrders.add(testCOM);
            testBoolean = ProposalWizardServices.getPdfType(testPWM, false) == null;
            testBoolean = ProposalWizardServices.getPdfType(testPWM, true) == null;
//            testProposalList[0].UseDocusign__c = false;
//            testBoolean = ProposalWizardServices.getDeliveryMethodName(testPWM, testProposalList[0], String.valueOf(testChangeOrderList[0].Id), testContactWithAccountList[0].Id, 'test') == null;
//            testProposalList[0].UseDocusign__c = true;
//            testBoolean = ProposalWizardServices.getDeliveryMethodName(testPWM, testProposalList[0], String.valueOf(testChangeOrderList[0].Id), testContactWithAccountList[0].Id, 'test') == null;
//            testBoolean = ProposalWizardServices.getDeliveryMethodName(testPWM, testProposalList[0], '', testContactWithAccountList[0].Id, 'test') == null;
            testBoolean = ProposalWizardServices.getEmailTemplateDeveloperNameForPdf('test ddp name', 'test delivery Method') == null;

            testPWM.changeOrderModelMap.put(testChangeOrderList[0].Id, testCOM);
            testBoolean = ProposalWizardServices.setChangeOrderDocumentType(testPWM, String.valueOf(testChangeOrderList[0].Id), true) == null;
            testBoolean = ProposalWizardServices.setChangeOrderDocumentType(testPWM, String.valueOf(testChangeOrderList[0].Id), false) == null;
            testPWM.notApprovedChangeOrders.add(testCOM);
            testBoolean = ProposalWizardServices.setChangeOrderIdForResendFromFooter('', DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY, testPWM, true) == null;
            testProposalList[0].Additional_Documents__c = true;
            testBoolean = ProposalWizardServices.prepareProposalPDF(testProposalList[0], String.valueOf(testChangeOrderList[0].Id), 'test', 'test', new List<DocumentWrapper>(), true, true) == null;

            testCOM = new ChangeOrderModel( testChangeOrderList[0],
                                            UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                            'test user role',
                                            currentUserId,
                                            testProposalList[0],
                                            true,
                                            testProjectTeamList[0],
                                            true, true, true );
            testCOM.serviceModels = new List<ServiceModel>();
            for (Service_Item__c si : testServiceItemList){
                ServiceModel serviceModelItem = new ServiceModel(si, null, null, null);
                serviceModelItem.isAmendmendDeleted = true;
                serviceModelItem.changeOrderId = testChangeOrderList[0].Id;
                testCOM.serviceModels.add(serviceModelItem);
            }
            testBoolean = ProposalWizardServices.getDeletedTaskItemsInChangeOrderModel(new List<ChangeOrderModel>{testCOM}, testChangeOrderList[0].Id) == null;

        Test.stopTest();
    }

    private static testMethod void testprepareProposalPDF() {
        setupData();
        createProposalListForTest(1, true);
        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(1, false)){
                changeOrderItem.Proposal__c = proposalItem.Id;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        List<Document> docItem = [SELECT Id FROM Document LIMIT 1];
        List<DocumentWrapper> testDocWrapperList = new List<DocumentWrapper>();
        if (!docItem.isEmpty()){
            testDocWrapperList.add(new DocumentWrapper(docItem[0]));
        } else {
            Folder artifactFolder = [SELECT Id, Name FROM Folder WHERE Name =: ARTIFACT_FOLDER_NAME][0];
            Document testDoc = TestingUtils.createDocumentList(1, 'Test Name', artifactFolder.Id, true)[0];
            testDocWrapperList.add(new DocumentWrapper(new Document()));
        }
        for (DocumentWrapper docWrap : testDocWrapperList){
            docWrap.isAttached = true;
        }
        testLStoreStoredDocument = new List<LStore__Stored_Document__c>();
        Integer exrternalIdIndex = 0;
        for (Proposal__c proposalItem : testProposalList){
            for (LStore__Stored_Document__c testLStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (1, String.valueOf(proposalItem.Id), false)){
                testLStoreStoredDocumentItem.RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID;
                testLStoreStoredDocumentItem.LStore__File_Name__c = StoredDocumentServices.RFP_DOCUMENTS_FOLDER;
                testLStoreStoredDocumentItem.LStore__External_Id__c = 'test' + String.valueOf(exrternalIdIndex++);
                testLStoreStoredDocument.add(testLStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocument;

        List<LStore__Stored_Document__c> testLStoreStoredDocumentFiles = new List<LStore__Stored_Document__c>();
        for (LStore__Stored_Document__c testLStoreStoredDocumentFolder : testLStoreStoredDocument){
            for (LStore__Stored_Document__c testLStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (1, testLStoreStoredDocumentFolder.LStore__Related_Object_Id__c, false)){
                testLStoreStoredDocumentItem.LStore__Folder__c = testLStoreStoredDocumentFolder.Id;
                testLStoreStoredDocumentItem.LStore__Type__c = 'ppt';
                testLStoreStoredDocumentItem.LStore__External_Id__c = 'test' + String.valueOf(exrternalIdIndex++);
                testLStoreStoredDocumentItem.LStore__File_Size__c = 100;
                testLStoreStoredDocumentFiles.add(testLStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocumentFiles;

        List<Loop__DDP__c> ddpList;
        List<Loop__DDP_Integration_Option__c> ddpIntegrationOptionList;
        List<EmailTemplate> emailTemplateList = [SELECT Id FROM EmailTemplate LIMIT 1];
        if (!emailTemplateList.isEmpty()){
            ddpList = TestingUtils.createLoopDDPList(3, false);
            ddpList[0].Name = ProposalWizardServices.PROPOSAL_DDP_NAME;
            ddpList[1].Name = ProposalWizardServices.CHANGE_ORDER_DDP_NAME;
            ddpList[2].Name = ProposalWizardServices.CHANGE_ORDER_LIGHT_DDP_NAME;
            insert ddpList;

            ddpIntegrationOptionList = new List<Loop__DDP_Integration_Option__c>();
            for (Loop__DDP__c ddp : ddpList){
                for (Loop__DDP_Integration_Option__c ddpIntegrationOption : TestingUtils.createLoopDDPIntegrationOptionList (1, ddp.Id, false)){
                    ddpIntegrationOption.Send_Email_User__c = userinfo.getuserid();
                    ddpIntegrationOption.Name = DDPEmailServices.DELIVERY_METHOD_EMAIL;
                    ddpIntegrationOption.Loop__Template__c = emailTemplateList[0].Id;
                    ddpIntegrationOptionList.add(ddpIntegrationOption);
                }
                for (Loop__DDP_Integration_Option__c ddpIntegrationOption : TestingUtils.createLoopDDPIntegrationOptionList (1, ddp.Id, false)){
                    ddpIntegrationOption.Send_Email_User__c = userinfo.getuserid();
                    ddpIntegrationOption.Name = DDPEmailServices.DELIVERY_METHOD_DOCUSIGN;
                    ddpIntegrationOption.Loop__Template__c = emailTemplateList[0].Id;
                    ddpIntegrationOptionList.add(ddpIntegrationOption);
                }
            }
            insert ddpIntegrationOptionList;
        }

        Map<String, String> emailToNameForApprover = new Map<String, String>{'test1@gmail.com' => 'test1@gmail.com'};
        Map<String, String> emailToNameForCc = new Map<String, String>{'test2@gmail.com' => 'test2@gmail.com'};

        Test.startTest();

            Boolean testBoolean;
            testProposalList[0].Additional_Documents__c = true;
            testProposalList[0].Proposal_Type__c = ProposalServices.PROPOSAL_TYPE_RFP;
            testBoolean = ProposalWizardServices.sendProposalPDF(testProposalList[0], String.valueOf(testChangeOrderList[0].Id), testContactWithAccountList[0].Id, emailToNameForApprover, emailToNameForCc,
                                                                    ProposalWizardServices.PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP, null, testDocWrapperList) == null;
            testBoolean = ProposalWizardServices.sendProposalPDF(testProposalList[0], String.valueOf(testChangeOrderList[0].Id), testContactWithAccountList[0].Id, emailToNameForApprover, emailToNameForCc,
                                                                    ProposalWizardServices.PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_DOCUSIGN,
                                                                    (ddpIntegrationOptionList != null && !ddpIntegrationOptionList.isEmpty()) ? String.valueOf(ddpIntegrationOptionList[0].Id) : null, testDocWrapperList) == null;


            testBoolean = ProposalWizardServices.prepareProposalPDF(testProposalList[0], String.valueOf(testChangeOrderList[0].Id), ProposalWizardServices.PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP, testDocWrapperList, true, true) == null;
            testBoolean = ProposalWizardServices.prepareProposalPDF(testProposalList[0], String.valueOf(testChangeOrderList[0].Id), ProposalWizardServices.PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_EMAIL, testDocWrapperList, true, true) == null;
            testBoolean = ProposalWizardServices.prepareProposalPDF(testProposalList[0], '', ProposalWizardServices.PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_EMAIL, testDocWrapperList, true, true) == null;

        Test.stopTest();
    }

    private static testMethod void testRedirectBillingTriggers() {
        setupData();

        Map<Id, List<Task_Template__c>> serviceWithTaskMap = new Map<Id, List<Task_Template__c>>();

        testServiceTemplateList = TestingUtils.createServiceTemplateList(1, true);
        testTaskTemplateList = new List<Task_Template__c>();
        for (Service_Template__c st : testServiceTemplateList){
            serviceWithTaskMap.put(st.Id, new List<Task_Template__c>());
            for (Task_Template__c taskTemplateItem : TestingUtils.createTaskTemplateList(1, false)){
                taskTemplateItem.Service__c = st.Id;
                testTaskTemplateList.add(taskTemplateItem);
                serviceWithTaskMap.get(st.Id).add(taskTemplateItem);
            }
        }
        insert testTaskTemplateList;

        TestingUtils.createProposalWithProjectProfileList(1);
        testProposalList = TestingUtils.testProposalList;
        testProjectProfileList = TestingUtils.testProjectProfileList;
        testChangeOrderList = new List<Change_Order__c>();
        for (Proposal__c proposalItem : testProposalList){
            for (Change_Order__c changeOrderItem : TestingUtils.createChangeOrderList(1, false)){
                changeOrderItem.Proposal__c = testProposalList[0].Id;
                changeOrderItem.Project_Profile__c = proposalItem.Project_Profile__c;
                testChangeOrderList.add(changeOrderItem);
            }
        }
        insert testChangeOrderList;

        testServiceItemList = new List<Service_Item__c>();
        for (Change_Order__c changeOrderItem : testChangeOrderList){
            for (Service_Template__c st : testServiceTemplateList){
                for (Service_Item__c si : TestingUtils.createServiceItemList(2, changeOrderItem.Proposal__c, false)){
                    si.Change_Order__c = changeOrderItem.Id;
                    si.Project_Profile__c = changeOrderItem.Project_Profile__c;
                    si.Service_Template__c = st.Id;
                    si.Is_Amendmend_Deleted__c = true;
                    testServiceItemList.add(si);
                }
            }
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        Map<Id, List<Task_Item__c>> serviceItemWithTaskItemMap = new Map<Id, List<Task_Item__c>>();
        for (Service_Item__c si : testServiceItemList){
            serviceItemWithTaskItemMap.put(si.Id, new List<Task_Item__c>());
            for (Task_Template__c taskTemplate : serviceWithTaskMap.get(si.Service_Template__c)){
                for (Task_Item__c ti : TestingUtils.createTaskItemList(1, false)){
                    ti.Service_Item__c = si.Id;
                    ti.Task_Template__c = taskTemplate.Id;
                    ti.Project_Profile__c = si.Project_Profile__c;
                    ti.Billing_Percentage__c = 0.1;
                    ti.Billing_Trigger__c = true;
                    testTaskItemList.add(ti);
                    serviceItemWithTaskItemMap.get(si.Id).add(ti);
                }
                for (Task_Item__c ti : TestingUtils.createTaskItemList(1, false)){
                    ti.Service_Item__c = si.Id;
                    ti.Task_Template__c = taskTemplate.Id;
                    ti.Project_Profile__c = si.Project_Profile__c;
                    ti.Billing_Percentage__c = null;
                    ti.Billing_Trigger__c = true;
                    testTaskItemList.add(ti);
                    serviceItemWithTaskItemMap.get(si.Id).add(ti);
                }
            }
        }
        insert testTaskItemList;

        List<DDP_Helper__c> testDDPHelperList = TestingUtils.createDDPHelperList(2, false);
        testDDPHelperList[0].Text1__c = String.valueOf(serviceItemWithTaskItemMap.get(testServiceItemList[0].Id)[0].Id) + ProposalWizardServices.CHANGE_ORDER_CONTENT + 
                                        String.valueOf(testServiceItemList[0].Id) + ProposalWizardServices.SERVICE_ITEM_SPLITTER +
                                        String.valueOf(serviceItemWithTaskItemMap.get(testServiceItemList[0].Id)[1].Id);
        testDDPHelperList[1].Text1__c = String.valueOf(serviceItemWithTaskItemMap.get(testServiceItemList[1].Id)[0].Task_Template__c) + ProposalWizardServices.CHANGE_ORDER_CONTENT + 
                                        String.valueOf(testServiceItemList[1].Id) + ProposalWizardServices.SERVICE_ITEM_SPLITTER +
                                        String.valueOf(serviceItemWithTaskItemMap.get(testServiceItemList[1].Id)[1].Id);
        insert testDDPHelperList;

        Test.startTest();

            Boolean testBoolean;
            ProposalWizardServices.redirectBillingTriggers(testDDPHelperList[0].Id, testServiceItemList[0].Change_Order__c);
//            ProposalWizardServices.redirectBillingTriggers(testDDPHelperList[1].Id, testServiceItemList[0].Change_Order__c);

        Test.stopTest();
    }
}