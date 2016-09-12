@isTest
private class TestReimbursableExpenseInvoiceServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_CHECK = 3;
    private static final String STANDARD_STRING_VALUE = 'Standard';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Check__c> testCheckList;
    private static List<Reimbursable_Expense_Invoice__c> testReimbursableExpenseInvoiceList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        testProjectTeamList = TestingUtils.createProjectTeamList(NUMBER_TO_CREATE_PROJECT_TEAM, currentUserId, projectManagerUser.Id, true);
    }

    private static void createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        testProjectProfileList = TestingUtils.createProjectProfileList( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                        testContactWithAccountList[2].Id, projectManagerUser.Id, false);
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Project_Manager__c = projectManagerUser.Id;
        }
        if (doInsert){
            insert testProjectProfileList;
        }
    }

    private static testmethod void testNewInstance(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testCheckList = TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, true);

        testCheckList = [SELECT Id, Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Municipal_Agency_ID__c, Phase__c,
                                Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Check_Amount__c
                         FROM Check__c
                         WHERE Id IN : testCheckList];

        Reimbursable_Expense_Invoice__c resultRecord;

        Test.startTest();
            resultRecord = ReimbursableExpenseInvoiceServices.newInstance(testCheckList[0], testProjectProfileList[0].Id);
        Test.stopTest();

        System.assert(resultRecord != null);
        System.assertEquals(testCheckList[0].Billing_Client__c, resultRecord.Billing_Client__c);
        System.assertEquals(testCheckList[0].Billing_Contact__c, resultRecord.Billing_Contact__c);
        System.assertEquals(testCheckList[0].Id, resultRecord.Check_Request__c);
        System.assertEquals(testCheckList[0].Description__c, resultRecord.Description__c);
        System.assertEquals(testCheckList[0].Invoice_Payee__c, resultRecord.Invoice_Payee__c);
        System.assertEquals(testCheckList[0].Municipal_Agency_ID__c, resultRecord.Municipal_Agency_ID__c);
        System.assertEquals(testCheckList[0].Phase__c, resultRecord.Phase__c);
        System.assertEquals(testCheckList[0].Product_Name__c, resultRecord.Product_Name__c);
        System.assertEquals(testProjectProfileList[0].Id, resultRecord.Project_Profile__c);
        System.assertEquals(STANDARD_STRING_VALUE, resultRecord.Reimb_Billable_Type__c);
        System.assertEquals(testCheckList[0].OwnerId, resultRecord.Requester__c);
        System.assertEquals(testCheckList[0].Service_Item__c, resultRecord.Service_Item__c);
    }

    private static testmethod void testNewInstanceWithoutCheck(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testCheckList = TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, true);

        testCheckList = [SELECT Id, Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Municipal_Agency_ID__c, Phase__c,
                                Product_Name__c, Project_Address__c, Service_Item__c, OwnerId
                         FROM Check__c
                         WHERE Id IN : testCheckList];

        Reimbursable_Expense_Invoice__c resultRecord;
        String errorString;

        Test.startTest();
            try{
                resultRecord = ReimbursableExpenseInvoiceServices.newInstance(null, testProjectProfileList[0].Id);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }
        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecord == null);
    }

    private static testmethod void testNewInstanceWithoutProjectProfile(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);
        testCheckList = TestingUtils.createCheckList(NUMBER_TO_CREATE_CHECK, testAccountList[0].Id, true);

        testCheckList = [SELECT Id, Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Municipal_Agency_ID__c, Phase__c,
                                Product_Name__c, Project_Address__c, Service_Item__c, OwnerId
                         FROM Check__c
                         WHERE Id IN : testCheckList];

        Reimbursable_Expense_Invoice__c resultRecord;
        String errorString;

        Test.startTest();
            try{
                resultRecord = ReimbursableExpenseInvoiceServices.newInstance(testCheckList[0], null);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }
        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecord == null);
    }
}