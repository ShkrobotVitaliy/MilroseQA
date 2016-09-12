@isTest
private class TestServiceItemServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 3;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_PHASE = 5;
    private static final Integer NUMBER_TO_CREATE_GENERAL_LEDGER_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_TAX_CODE = 4;
    private static final Integer NUMBER_TO_CREATE_TAX_RATE = 1;
    private static final Integer NUMBER_TO_CREATE_DIMENSION_1 = 1;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM =3;
    private static final Integer NUMBER_TO_CREATE_MILESTONE_TASK_ITEM =5;
    private static final Decimal TAX_CODE_RATE_VALUE = 12.5;
    private static final Decimal TEST_QUANTITY = 23.7;
    private static final Decimal TEST_UNIT_PRICE = 34.9;
    private static final Decimal TEST_DISCOUNT_PERCENTAGE = 8;
    private static final Decimal TEST_TOTAL_SERVICE_PRICE = 14.2;
    private static final String TEST_MILESTONE_PREDECESSOR_NAME = 'test predecessor name';
    private static final String TEST_MILESTONE_SUCCESSOR_NAME = 'test successor name';

    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Service_Item__c> testServiceItemList;
    private static Set<Service_Item__c> testServiceItemSet;
    private static List<c2g__codaGeneralLedgerAccount__c> testGeneralLedgerAccount;
    private static List<c2g__codaTaxCode__c> testTaxCodeList;
    private static List<c2g__codaTaxRate__c> testTaxRateList;
    private static List<c2g__codaDimension1__c> testDimension_1_List;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Task_Item__c> testMilestoneTaskItemList;
    private static List<Phase__c> testPhaseList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static Id taskMilestoneRecordTypeId;
    private static Id taskNonMilestoneRecordTypeId;

    private static void prepareDataForTest (){
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[0].Id, testContactWithAccountList[0].Id, testAccountList[0].Id,
                                                                        testContactWithAccountList[0].Id, projectManagerUser.Id, true);
    }

    private static void createGeneralLedgerAccountTaxCodeTaxRate(){
        testGeneralLedgerAccount = testingUtils.createGeneralLedgerAccountList(NUMBER_TO_CREATE_GENERAL_LEDGER_ACCOUNT, null, null, true);
        testTaxCodeList = TestingUtils.createTaxCodeList(NUMBER_TO_CREATE_TAX_CODE, testGeneralLedgerAccount[0].Id, true);
        testTaxRateList = new List<c2g__codaTaxRate__c>();
        for (c2g__codaTaxCode__c taxCodeItem : testTaxCodeList){
            testTaxRateList.addAll(TestingUtils.createTaxRateList(NUMBER_TO_CREATE_TAX_RATE, taxCodeItem.Id, TAX_CODE_RATE_VALUE, Date.today(), false));
        }
        insert testTaxRateList;
    }

    //create GeneralLedgerAccount, TaxCode, TaxRate lists
    private static void setupData(){
        prepareDataForTest ();
        testProposalList = TestingUtils.createProposalList( NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                            null, null, null, null, partnerUser.Id, currentUserId, projectManagerUser.Id, false);
        testProposalList[0].Total_Service_Amount__c = TEST_TOTAL_SERVICE_PRICE;
        insert testProposalList;

        createGeneralLedgerAccountTaxCodeTaxRate();
    }

    private static void prepareRecordTypeForTest(){
        Map<String, Id> temporaryMapTaskRecordType = TestingUtils.getRecordTypeNameIdByObjecttypename('Task_Item__c');
        taskMilestoneRecordTypeId = temporaryMapTaskRecordType.get(TaskManagementServices.MILESTONE_RECORDTYPE_NAME);
        for (String recordTypeNameItem : temporaryMapTaskRecordType.keySet()){
            if (recordTypeNameItem != TaskManagementServices.MILESTONE_RECORDTYPE_NAME){
                taskNonMilestoneRecordTypeId = temporaryMapTaskRecordType.get(recordTypeNameItem);
                break;
            }
        }
    }

    private static void createServiceItemList(Integer numberToCreate, Boolean doInsert){
        testServiceItemList = TestingUtils.createServiceItemList(numberToCreate, doInsert);
    }
    private static void addTasksToServiceItemList(){
        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, testServiceItemList[0].Id, testProjectProfileList[0].Id, false);
        for(Task_Item__c item : testTaskItemList){
            item.OwnerId = partnerUser.Id;
        }
            insert testTaskItemList;
    }
    private static testmethod void testGetPhaseIdServiceItemMap(){
        Set<Id> phaseSetIdForTest = new Set<Id>();
        testPhaseList = TestingUtils.createPhaseList(NUMBER_TO_CREATE_PHASE * 2, true);
        testServiceItemList = new List<Service_Item__c>();
        for (Phase__c phaseItem : testPhaseList){
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false)){
                serviceItem.Phase__c = phaseItem.Id;
                testServiceItemList.add(serviceItem);
            }
        }
        insert testServiceItemList;
        for (Integer i = 0; i <= NUMBER_TO_CREATE_PHASE; i++){
            phaseSetIdForTest.add(testPhaseList[i].Id);
        }
        Map<Id, Service_Item__c> resultMapIdServiceItem;

        Test.startTest();

            resultMapIdServiceItem = ServiceItemServices.getPhaseIdServiceItemMap(phaseSetIdForTest);

        Test.stopTest();

        System.assert(!resultMapIdServiceItem.isEmpty());
        System.assertEquals(phaseSetIdForTest.size(), resultMapIdServiceItem.Size());
        System.assertEquals(phaseSetIdForTest, resultMapIdServiceItem.keySet());
    }

    private static testmethod void testGetServiceItemMap() {
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, true);

        Set<Id> setServiceItemId = new Map<Id, Service_Item__c>(testServiceItemList).keySet();
        Map<Id, Service_Item__c> mapIdServiceItem;

        Test.startTest();
            mapIdServiceItem = ServiceItemServices.getServiceItemMap(setServiceItemId);
        Test.stopTest();

        System.assert (setServiceItemId.containsAll(mapIdServiceItem.keySet()) && mapIdServiceItem.keySet().containsAll(setServiceItemId));
    }

    private static testmethod void testFilterServiceItemTaxOldMapIsNull() {
        setupData();

        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Tax_Code_1__c = null;
            serviceItem.Tax_Code_2__c = null;
        }
        insert testServiceItemList;

        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = null;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2; i < NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            testServiceItemList[i].Tax_Code_1__c = null;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        Test.startTest();
            testServiceItemSet = new Set<Service_Item__c>(ServiceItemServices.filterServiceItemTax(testServiceItemList));
        Test.stopTest();

        System.assertEquals (NUMBER_TO_CREATE_SERVICE_ITEM * 3, testServiceItemSet.size());
        for (Service_Item__c serviceItem : testServiceItemSet){
            System.assert(serviceItem.Tax_Code_1__c != null || serviceItem.Tax_Code_2__c != null);
        }
    }

    private static testmethod void testFilterServiceItemTaxOldMapIsNotNull() {
        setupData();

        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Tax_Code_1__c = null;
            serviceItem.Tax_Code_2__c = null;
            serviceItem.Proposal__c = testProposalList[0].id;
//          serviceItem.Quantity__c  = TEST_QUANTITY;
//          serviceItem.Unit_Price__c = TEST_UNIT_PRICE;
        }
        insert testServiceItemList;
        testServiceItemList = [ SELECT Id, Tax_Code_1__c, Tax_Code_2__c, Total_Service_Price__c
                                FROM Service_Item__c
                                WHERE Id IN : testServiceItemList];
        Map<Id, Service_Item__c> oldIdServiceItemMap = new Map<Id, Service_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList.deepClone(true)){
            serviceItem.Tax_Code_1__c = testTaxCodeList[2].Id;
            serviceItem.Tax_Code_2__c = testTaxCodeList[3].Id;
            oldIdServiceItemMap.put(serviceItem.Id, serviceItem);
        }

        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = null;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2; i < NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            testServiceItemList[i].Tax_Code_1__c = null;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        Test.startTest();
            testServiceItemSet = new Set<Service_Item__c>(ServiceItemServices.filterServiceItemTax(testServiceItemList));
        Test.stopTest();

        System.assertEquals (NUMBER_TO_CREATE_SERVICE_ITEM * 3, testServiceItemSet.size());//realy must be * 3 value
    }

    private static testmethod void testServiceItemTaxCode() {
        setupData();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Tax_Code_1__c = null;
            serviceItem.Tax_Code_2__c = null;
            serviceItem.Proposal__c = testProposalList[0].id;
            serviceItem.Quantity__c  = TEST_QUANTITY;
            serviceItem.Unit_Price__c = TEST_UNIT_PRICE;
            serviceItem.Discount_Percentage__c = TEST_DISCOUNT_PERCENTAGE;
        }
        insert testServiceItemList;
        testServiceItemList = [ SELECT Id, Tax_Code_1__c, Tax_Code_2__c, Total_Service_Price__c, Tax_Value_1__c, Tax_Value_2__c,
                                    Tax_Percent_1__c, Tax_Percent_2__c, Discount_Percentage__c
                                FROM Service_Item__c
                                WHERE Id IN : testServiceItemList];

        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            testServiceItemList[i].Tax_Code_1__c = testTaxCodeList[0].Id;
            testServiceItemList[i].Tax_Code_2__c = null;
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2; i < NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            testServiceItemList[i].Tax_Code_1__c = null;
            testServiceItemList[i].Tax_Code_2__c = testTaxCodeList[1].Id;
        }

        Test.startTest();
            ServiceItemServices.filterServiceItemTax( testServiceItemList );
            ServiceItemServices.serviceItemTaxCode( testServiceItemList, true );
        Test.stopTest();

        Decimal testTotalServicePrice = (TEST_UNIT_PRICE - TEST_UNIT_PRICE * TEST_DISCOUNT_PERCENTAGE/100) * TEST_QUANTITY.setScale(2);

        for (Service_Item__c serviceItem : testServiceItemList){
            if (serviceItem.Tax_Code_1__c != null){
                System.assertEquals ((TAX_CODE_RATE_VALUE * testTotalServicePrice / 100).setScale(2), serviceItem.Tax_Value_1__c.setScale(2));
            } else {
                System.assertEquals (null, serviceItem.Tax_Value_1__c);
            }
            if (serviceItem.Tax_Code_2__c != null){
                System.assertEquals ((TAX_CODE_RATE_VALUE * testTotalServicePrice / 100).setScale(2), serviceItem.Tax_Value_2__c.setScale(2));
            } else {
                System.assertEquals (null, serviceItem.Tax_Value_2__c);
            }
        }
    }

    private static testmethod void testFilterServiceItemWithChangedMilestones(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, false);
        for (Service_Item__c serviceItem : testServiceItemList){
            serviceItem.Predecessor_Milestone__c = null;
            serviceItem.Successor_Milestone__c = null;
        }
        insert testServiceItemList;
        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>(testServiceItemList.deepClone(true));

        Set<Id> resultSetId = new Set<Id>();
        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            testServiceItemList[i].Predecessor_Milestone__c = TEST_MILESTONE_PREDECESSOR_NAME;
            testServiceItemList[i].Successor_Milestone__c = TEST_MILESTONE_SUCCESSOR_NAME;
            resultSetId.add(testServiceItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            testServiceItemList[i].Predecessor_Milestone__c = TEST_MILESTONE_PREDECESSOR_NAME;
            resultSetId.add(testServiceItemList[i].Id);
        }

        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2 ; i < NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            testServiceItemList[i].Successor_Milestone__c = TEST_MILESTONE_SUCCESSOR_NAME;
            resultSetId.add(testServiceItemList[i].Id);
        }

        Map<Id, Service_Item__c> testResult;

        Test.startTest();

            testResult = ServiceItemServices.filterServiceItemWithChangedMilestones(testServiceItemList, serviceItemMapOld);

        Test.stopTest();

        System.assert(!testResult.isEmpty());
        System.assertEquals(resultSetId, testResult.keySet());
    }

    private static testmethod void testUpdatePredecessorSuccessorTaskItem(){
        prepareRecordTypeForTest();
        prepareDataForTest();
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE_PROJECT_PROFILE, testAccountList[0].Id,
                                                                        testContactWithAccountList[0].Id, testAccountList[1].Id,
                                                                        testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, true);

        // create Milestone Task Item for test
        List<sObject> listSobjectForInsert = new List<sObject>();
        testMilestoneTaskItemList = new List<Task_Item__c>();
        testServiceItemList = new List<Service_Item__c>();
        Map<Id, Map<Integer, Task_Item__c>> testProjectProfileWithMilestones = new Map<Id, Map<Integer, Task_Item__c>>();
        Task_Item__c testCommonMilestone = TestingUtils.createTaskItemList(1, false)[0];
        testCommonMilestone.RecordTypeId = taskMilestoneRecordTypeId;
        listSobjectForInsert.add(testCommonMilestone);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            testProjectProfileWithMilestones.put(projectProfileItem.id, new Map<Integer, Task_Item__c>());
            integer i = 1;
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_MILESTONE_TASK_ITEM + NUMBER_TO_CREATE_SERVICE_ITEM * 3, null, projectProfileItem.Id, false)){
                taskItem.RecordTypeId = taskMilestoneRecordTypeId;
                taskItem.Name = String.valueOf(i) + projectProfileItem.Id;
                testMilestoneTaskItemList.add(taskItem);
                testProjectProfileWithMilestones.get(projectProfileItem.id).put(i, taskItem);
                listSobjectForInsert.add(taskItem);
                i++;
            }
            for (Service_Item__c serviceItem : TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM * 4, false)){
                serviceItem.Predecessor_Milestone__c = null;
                serviceItem.Successor_Milestone__c = null;
                serviceItem.Project_Profile__c = projectProfileItem.id;
                testServiceItemList.add(serviceItem);
                listSobjectForInsert.add(serviceItem);
            }
        }
        insert listSobjectForInsert;

        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>(testServiceItemList.deepClone(true));

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItem : testServiceItemList){
            Integer sequenceNumber = TaskManagementServices.FIRST_TASK_IN_SEQUENCE;
            for (Task_Item__c taskItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, serviceItem.Id, serviceItem.Project_Profile__c, false)){
                taskItem.Sequence_Number__c = sequenceNumber++;
                //populate Predecessor Milestone for first Task Item
                taskItem.Predecessor_Milestone__c = taskItem.Sequence_Number__c == TaskManagementServices.FIRST_TASK_IN_SEQUENCE ?
                                                        testCommonMilestone.Id :
                                                        null;
                //populate Successor Milestone for last Task Item
                taskItem.Successor_Milestone__c = taskItem.Sequence_Number__c == NUMBER_TO_CREATE_TASK_ITEM ?
                                                        testCommonMilestone.Id :
                                                        null;
                taskItem.RecordTypeId = taskNonMilestoneRecordTypeId;
                testTaskItemList.add(taskItem);
            }
        }
        insert testTaskItemList;

        //change Predecessor Milestone value in Service Item records
        for (Integer i = 0; i < NUMBER_TO_CREATE_SERVICE_ITEM; i++){
            testServiceItemList[i].Predecessor_Milestone__c = testProjectProfileWithMilestones.get(testServiceItemList[i].Project_Profile__c).get(i + 1).Name;//testServiceItemList[i].Project_Profile__c + String.valueOf(NUMBER_TO_CREATE_MILESTONE_TASK_ITEM);
        }

        //change Predecessor Milestone value in Service Item records
        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM; i < NUMBER_TO_CREATE_SERVICE_ITEM * 2; i++){
            testServiceItemList[i].Successor_Milestone__c = testProjectProfileWithMilestones.get(testServiceItemList[i].Project_Profile__c).get(i + 1).Name;//testServiceItemList[i].Project_Profile__c + String.valueOf(NUMBER_TO_CREATE_MILESTONE_TASK_ITEM);
        }

        //change Predecessor Milestone value in Service Item records
        for (Integer i = NUMBER_TO_CREATE_SERVICE_ITEM * 2; i <= NUMBER_TO_CREATE_SERVICE_ITEM * 3; i++){
            testServiceItemList[i].Predecessor_Milestone__c = testProjectProfileWithMilestones.get(testServiceItemList[i].Project_Profile__c).get(i + 1).Name;//testServiceItemList[i].Project_Profile__c + String.valueOf(NUMBER_TO_CREATE_MILESTONE_TASK_ITEM - 1);
            testServiceItemList[i].Successor_Milestone__c = testProjectProfileWithMilestones.get(testServiceItemList[i].Project_Profile__c).get(i + 1).Name;//testServiceItemList[i].Project_Profile__c + String.valueOf(NUMBER_TO_CREATE_MILESTONE_TASK_ITEM);
        }

        Test.startTest();

            ServiceItemServices.updatePredecessorSuccessorTaskItem(new Map<Id, Service_Item__c>(testServiceItemList), serviceItemMapOld);

        Test.stopTest();

        testTaskItemList = [SELECT Id, Sequence_Number__c, Predecessor_Milestone__c, Successor_Milestone__c, Predecessor_Milestone__r.Name,
                                    Successor_Milestone__r.Name, Service_Item__r.Predecessor_Milestone__c, Service_Item__r.Successor_Milestone__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        for (Task_Item__c taskItem : testTaskItemList){
            if (taskItem.Service_Item__r.Predecessor_Milestone__c != null && taskItem.Predecessor_Milestone__c != null){
                System.assertEquals(taskItem.Service_Item__r.Predecessor_Milestone__c, taskItem.Predecessor_Milestone__r.Name);
            }
            if (taskItem.Service_Item__r.Successor_Milestone__c != null && taskItem.Successor_Milestone__c != null){
                System.assertEquals(taskItem.Service_Item__r.Successor_Milestone__c, taskItem.Successor_Milestone__r.Name);
            }
        }
    }

    private static testmethod void testCreateNewServiceItemFromTemplate(){
        createGeneralLedgerAccountTaxCodeTaxRate();
        testDimension_1_List = TestingUtils.createDimension_1_List(NUMBER_TO_CREATE_DIMENSION_1, true);

        Service_Template__c testServiceTemplate = TestingUtils.createServiceTemplateList(1, false)[0];
        testServiceTemplate.Work_Performed__c = 'test work performed';
        testServiceTemplate.Service_Name_Full__c = 'test service name';
        testServiceTemplate.Category__c = 'test service category';
        testServiceTemplate.Subtype__c = 'test service subtype';
        testServiceTemplate.Plan_Submission_Type__c = 'test plan submission';
        testServiceTemplate.Type__c = 'test type';
        testServiceTemplate.Unit_of_Service__c = 'test unit of Service';
        testServiceTemplate.Department__c = testDimension_1_List[0].Id;
        testServiceTemplate.Work_Type__c = 'test work type';
        testServiceTemplate.Issuance__c = 'test issuance';
        testServiceTemplate.Description__c = 'test description';
        testServiceTemplate.Tax_Code_1__c = testTaxCodeList[0].Id;
        testServiceTemplate.Tax_Code_2__c = testTaxCodeList[0].Id;
        testServiceTemplate.GLA_Product__c = null;
        testServiceTemplate.Medium_Price__c = TEST_UNIT_PRICE;
        testServiceTemplate.Quantity__c = TEST_UNIT_PRICE;
        insert testServiceTemplate;

        testServiceTemplate = [ SELECT Id, Work_Performed__c, Service_Name_Full__c, Category__c, Subtype__c, Plan_Submission_Type__c, Type__c,
                                        Unit_of_Service__c, Department__c, Work_Type__c, Issuance__c, Description__c, Tax_Code_1__c, Tax_Code_2__c,
                                        GLA_Product__c, Abbreviation__c, Medium_Price__c, Quantity__c, Role_Assignment__c, Short_Service_Name__c
                                FROM Service_Template__c
                                WHERE Id = : testServiceTemplate.Id ];

        Service_Item__c testServiceItemResult;

        Test.startTest();

            testServiceItemResult = ServiceItemServices.createNewServiceItemFromTemplate(testServiceTemplate);

        Test.stopTest();

      /*  System.assert(testServiceItemResult != null);
        System.assertEquals(testServiceTemplate.Work_Performed__c, testServiceItemResult.Work_Performed__c);
        System.assertEquals(testServiceTemplate.Id, testServiceItemResult.Service_Template__c);
        System.assertEquals(testServiceTemplate.Service_Name_Full__c, testServiceItemResult.Service_Name_Full__c);
        System.assertEquals(testServiceTemplate.Category__c, testServiceItemResult.Category__c);
        System.assertEquals(testServiceTemplate.Subtype__c, testServiceItemResult.Subtype__c);
        System.assertEquals(testServiceTemplate.Plan_Submission_Type__c, testServiceItemResult.Plan_Submission_Type__c);
        System.assertEquals(testServiceTemplate.Type__c, testServiceItemResult.Type__c);
        System.assertEquals(testServiceTemplate.Unit_of_Service__c, testServiceItemResult.Unit_of_Service__c);
        System.assertEquals(testServiceTemplate.Department__c, testServiceItemResult.Department__c);
        System.assertEquals(testServiceTemplate.Work_Type__c, testServiceItemResult.Work_Type__c);
        System.assertEquals(testServiceTemplate.Issuance__c, testServiceItemResult.Issuance__c);
        System.assertEquals(testServiceTemplate.Description__c, testServiceItemResult.Description__c);
        System.assertEquals(testServiceTemplate.Tax_Code_1__c, testServiceItemResult.Tax_Code_1__c);
        System.assertEquals(testServiceTemplate.Tax_Code_2__c, testServiceItemResult.Tax_Code_2__c);
        System.assertEquals(testServiceTemplate.GLA_Product__c, testServiceItemResult.GLA_Product__c);
        System.assertEquals(testServiceTemplate.Abbreviation__c, testServiceItemResult.Abbreviation__c);
        System.assertEquals(testServiceTemplate.Medium_Price__c, testServiceItemResult.Unit_Price__c);
        System.assertEquals(testServiceTemplate.Quantity__c, testServiceItemResult.Quantity__c);*/
    }
    
    @isTest(seeAllData = false) private static void testFilteredServiceItemsForFormsCreation(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
        }
            insert testServiceItemList;
            
        Test.startTest();
            List<Service_Item__c> filteredServiceItemsForFormsCreation = ServiceItemServices.filteredServiceItemsForFormsCreation(testServiceItemList);
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemsByProjectId(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            Map<Id, Service_Item__c> getServiceItemsByProjectId = ServiceItemServices.getServiceItemsByProjectId(testProjectProfileList[0].Id);
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemsByProjectIdException(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            try{
                ServiceItemServices.getServiceItemsByProjectId('');
            }catch(Exception e){
                String testException = String.valueOf(e);
            }
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemById(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            Service_Item__c getServiceItemById = ServiceItemServices.getServiceItemById(testServiceItemList[0].Id);
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemByIdException(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            try{
                ServiceItemServices.getServiceItemById('');
            }catch(Exception e){
                String testException = String.valueOf(e);
            }   
        Test.stopTest();
    }
    
    @isTest(seeAllData = false) private static void testGetServiceItemByIdSecondException(){
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
        Service_Item__c testServiveItem = TestingUtils.createServiceItemList( 1, true )[0];
            
        Test.startTest();
            try{
                ServiceItemServices.getServiceItemById(testServiveItem.Id);
            }catch(Exception e){
                String testException = String.valueOf(e);
            }   
        Test.stopTest();
    }
    
    private static testmethod void testFilteredServiceItemWithChangedOwner(){
        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>();
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        Id userProfielProjectManagerId = [SELECT Id FROM User WHERE Profile.Name Like : '%' + UserServices.PROFILE_PROJECT_MANAGER + '%' AND isActive = true LIMIT 1][0].Id;
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id;
            item.OwnerId = userProfielProjectManagerId;
        }
        insert testServiceItemList;

        testServiceItemList = [SELECT Id, OwnerId, Owner_Profile__c
                               FROM Service_Item__c
                               WHERE Id IN : testServiceItemList];

        serviceItemMapOld = new Map<Id, Service_Item__c>(testServiceItemList.deepClone(true));

        for(Service_Item__c item : testServiceItemList){
            item.OwnerId = currentUserId;
        }

        Test.startTest();
            Map<Id, Service_Item__c> filteredServiceItemWithChangedOwner = ServiceItemServices.filteredServiceItemWithChangedOwner(testServiceItemList, serviceItemMapOld);
        Test.stopTest();
    }
    
    private static testMethod void testUpdateTaskItemOwner(){
        Id testRecordType = [SELECT Name,SObjectType FROM RecordType WHERE SObjectType = 'Service_Template__c' AND Name = : ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME limit 1].Id;
        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>();
        Map<Id, Service_Item__c> serviceItemMapNew = new Map<Id, Service_Item__c>();
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        Service_Template__c testServiceTemplateItem = TestingUtils.createServiceTemplateList(1, false)[0];
            testServiceTemplateItem.RecordTypeId = testRecordType;
            insert testServiceTemplateItem;
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        for(Service_Item__c item : testServiceItemList){    
            serviceItemMapOld.put(item.Id,item.clone());
            item.OwnerId = currentUserId;
            item.Service_Template__c = testServiceTemplateItem.Id;
            serviceItemMapNew.put(item.Id,item);
        }
            update testServiceItemList; 
        addTasksToServiceItemList();    
        
        Test.startTest();
            ServiceItemServices.updateTaskItemOwner(serviceItemMapNew, serviceItemMapOld);
        Test.stopTest();
    }
    
     private static testMethod void testFilterServiceItemsWithChangedMunicipalAgency(){
        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>();
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        for(Service_Item__c item : testServiceItemList){    
            serviceItemMapOld.put(item.Id,item.clone());
            item.OwnerId = currentUserId;
            item.Municipal_Agency_ID__c = 'TestMunic';
        }
            update testServiceItemList; 
            
        Test.startTest();
            Map<Id, Service_Item__c> filterServiceItemsWithChangedMunicipalAgency = ServiceItemServices.filterServiceItemsWithChangedMunicipalAgency(testServiceItemList, serviceItemMapOld);
        Test.stopTest();    
     }
     
     private static testMethod void testUpdateMunicipalAgencyOnTaskItems(){
        Map<Id, Service_Item__c> serviceItemMapOld = new Map<Id, Service_Item__c>();
        prepareDataForTest();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        for(Service_Item__c item : testServiceItemList){    
            
            item.OwnerId = currentUserId;
            item.Municipal_Agency_ID__c = 'TestMunic';
            serviceItemMapOld.put(item.Id,item);
        }
            update testServiceItemList; 
            
        Test.startTest();
            ServiceItemServices.updateMunicipalAgencyOnTaskItems(serviceItemMapOld);
        Test.stopTest();    
     }
     
     private static testMethod void testGetServiceItemsByProposalsIdList(){
        setupData();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Proposal__c = testProposalList[0].Id;
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            Map<Id, List<Service_Item__c>> getServiceItemsByProposalsIdList  = ServiceItemServices.getServiceItemsByProposalsIdList(testProposalList);
        Test.stopTest();    
     }
     
     private static testMethod void testGetServiceItemIdsByProjectId(){
        setupData();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Proposal__c = testProposalList[0].Id;
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            Set<Id> getServiceItemIdsByProjectId  = ServiceItemServices.getServiceItemIdsByProjectId(testProjectProfileList[0].Id);
        Test.stopTest();    
     }
     
     private static testMethod void testGetServiceItemIdsByProjectIdException(){
        setupData();
        createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM,false);
        for(Service_Item__c item : testServiceItemList){
            item.Forms__c = 'TestForm';
            item.Proposal__c = testProposalList[0].Id;
            item.Project_Profile__c = testProjectProfileList[0].Id; 
        }
            insert testServiceItemList;
            
        Test.startTest();
            try{
                ServiceItemServices.getServiceItemIdsByProjectId(testProjectProfileList[0].Id);
            }catch(Exception e){
                String testException = String.valueOf(e);
            }           
        Test.stopTest();    
     }
    
    private static testMethod void testGetOriginalServiceItemsByProjectIdsEmptyParameter() {
        Test.startTest();
            List<Service_Item__c> services = ServiceItemServices.getOriginalServiceItemsByProjectIds(null);
        Test.stopTest();
    }
    
    private static testMethod void testGetOriginalServiceItemsByProjectIds() {
        Test.startTest();
        List<Project_Profile__c> projects = TestingUtils.createProjectProfileForTest(1, true);
        List<Service_Item__c> services    =  TestingUtils.createServiceItemList(1, true);
        
        services.get(0).Project_Profile__c = projects.get(0).Id;
        services.get(0).Original__c        = true;
        update services.get(0);
        
        List<Service_Item__c> serviceItems = ServiceItemServices.getOriginalServiceItemsByProjectIds(new Set<Id> { projects.get(0).Id });
        
        Test.stopTest();
    }
    
    private static testMethod void testGetAmendmentServiceItemByProposalIdsEmptyParameter() {
        Test.startTest();
            Map<Id, Service_Item__c> servicesMap = ServiceItemServices.getAmendmentServiceItemByProposalIds(new Set<Id>(), new List<Change_Order__c>());
        Test.stopTest();
    }
    
    private static testMethod void testGetAmendmentServiceItemByProposalIds() {
        Test.startTest();
            List<Proposal__c> proposals        = TestingUtils.createProposalListForTest(1, true);
            List<Change_Order__c> changeOrders = TestingUtils.createChangeOrderList(1, true);
            changeOrders.get(0).Status__c      = ChangeOrderServices.STATUS_APPROVED;
            update changeOrders;
            List<Service_Item__c> services     = TestingUtils.createServiceItemList(1, true);
            
            services.get(0).Proposal__c           = proposals.get(0).Id;
            services.get(0).Change_Order__c       = changeOrders.get(0).Id; 
            services.get(0).Original__c           = false;
            services.get(0).Applied_Amendment__c  = false;
            services.get(0).Is_Alternative__c     = false;
            services.get(0).Is_Amendmend_Added__c = false;
            update services.get(0);
            
            Map<Id, Service_Item__c> serviceItems = ServiceItemServices.getAmendmentServiceItemByProposalIds(new Set<Id> { proposals.get(0).Id }, changeOrders);
        Test.stopTest();
    }
    
    private static testMethod void testGetOriginalServiceItemByProposalIdsEmptyParameter() {
        Test.startTest();
            Map<Id, Service_Item__c> servicesMap = ServiceItemServices.getOriginalServiceItemByProposalIds(null);
        Test.stopTest();
    }
    
    private static testMethod void testGetOriginalServiceItemByProposalIds() {
        Test.startTest();
            List<Proposal__c> proposals        = TestingUtils.createProposalListForTest(1, true);
            List<Service_Item__c> services     = TestingUtils.createServiceItemList(1, true);
            
            services.get(0).Project_Profile__c    = null;
            services.get(0).Proposal__c           = proposals.get(0).Id;
            services.get(0).Original__c           = true;
            services.get(0).Is_Alternative__c     = false;
            update services.get(0);
            
            Map<Id, Service_Item__c> serviceItems = ServiceItemServices.getOriginalServiceItemByProposalIds(new Set<Id> { proposals.get(0).Id });
            
            Map<Id, Service_Item__c> serviceMap = ServiceItemServices.getServiceItemsWithTaskItemsByProjectId(null, null);
            
            Project_Profile__c p = new Project_Profile__c();
            insert p;
            
            serviceMap = ServiceItemServices.getServiceItemsWithTaskItemsByProjectId(p.Id, new Set<String>());
            
            try {
                Set<Id> serviceIds = ServiceItemServices.getServiceItemIdsByProjectId(null);
                
            } catch (Exception ex) { }
            
            //Map<Id, Service_Item__c> serviceMap2 = ServiceItemServices.getServiceItemsByProjectsId(new Set<Id>());
        Test.stopTest();
    }
    
    private static testMethod void testGetDeletedOriginalServiceItemByIds() {
        Test.startTest();
            List<Proposal__c> proposals    = TestingUtils.createProposalListForTest(1, true);
            List<Service_Item__c> services = TestingUtils.createServiceItemList(1, true);
            
            List<Service_Item__c> servicesList = ServiceItemServices.getDeletedOriginalServiceItemByIds(null);
            servicesList = ServiceItemServices.getDeletedOriginalServiceItemByIds(new Set<Id> { services.get(0).Id });

        Test.stopTest();
    
    }
    
}