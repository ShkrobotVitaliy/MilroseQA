@isTest
private class TestPurchaseOrderServices {
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_PROFILE = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 1;
    private static final Integer NUMBER_TO_CREATE_PURCHASE_ORDER = 3;
    private static final Integer NUMBER_TO_CREATE_PRO_FORMA_INVOICE = 3;

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Purchase_Order__c> testPurchaseOrderList;
    private static List<Pro_forma_Invoice__c> testProformaInvoiceList;
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static void setupData (){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);
        currentUserId = UserInfo.getUserId();
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, 'PurchaseOrderServices', true);
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

    private static testmethod void testTotalAmountPurchaseOrder(){
        setupData ();
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, null, true);
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        integer subtotalValue = 1;
        integer taxValue = 1;
        for (Purchase_Order__c purchaseOrderItem : testPurchaseOrderList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    testContactWithAccountList[0].AccountId,
                                                                                                    testContactWithAccountList[0].Id,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Purchase_Order__c = purchaseOrderItem.Id;
                proformaInvoiceItem.Subtotal__c = subtotalValue++;
                proformaInvoiceItem.Tax__c = taxValue++;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
            purchaseOrderItem.Total_Billing__c = null;
        }
        insert testProformaInvoiceList;
        update testPurchaseOrderList;

        Test.startTest();

            PurchaseOrderServices.totalAmountPurchaseOrder(new Map<Id, Purchase_Order__c>(testPurchaseOrderList).keySet());

        Test.stopTest();

        testPurchaseOrderList = [SELECT Id, Total_Billing__c,
                                        (Select Id, Total_Billed_Amount__c
                                         From Pro_forma_Invoices__r)
                                 FROM Purchase_Order__c
                                 WHERE Id IN : testPurchaseOrderList];

        System.assert(!testPurchaseOrderList.isEmpty());
        for (Purchase_Order__c purchaseOrderItem : testpurchaseOrderList){
            Decimal totalBilledAmountValue = 0;
            System.assert(!purchaseOrderItem.Pro_forma_Invoices__r.isEmpty());
            for (Pro_forma_Invoice__c proformaInvoiceItem : purchaseOrderItem.Pro_forma_Invoices__r){
                totalBilledAmountValue += proformaInvoiceItem.Total_Billed_Amount__c;
            }
            System.assertEquals(totalBilledAmountValue, purchaseOrderItem.Total_Billing__c);
        }
    }

    private static testmethod void testCalculatePurchaseOrderTotals(){
        setupData ();
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, null, true);
        testProformaInvoiceList = new List<Pro_forma_Invoice__c>();
        integer subtotalValue = 1;
        integer taxValue = 1;
        for (Purchase_Order__c purchaseOrderItem : testPurchaseOrderList){
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    testContactWithAccountList[0].AccountId,
                                                                                                    testContactWithAccountList[0].Id,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Purchase_Order__c = purchaseOrderItem.Id;
                proformaInvoiceItem.Subtotal__c = subtotalValue++;
                proformaInvoiceItem.Tax__c = taxValue++;
                proformaInvoiceItem.cl_FFA_Invoice_Created__c = false;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
            for (Pro_forma_Invoice__c proformaInvoiceItem : TestingUtils.createProFormaInvoiceList (NUMBER_TO_CREATE_PRO_FORMA_INVOICE,
                                                                                                    testContactWithAccountList[0].AccountId,
                                                                                                    testContactWithAccountList[0].Id,
                                                                                                    testBuildingList[0].Id,
                                                                                                    false)){
                proformaInvoiceItem.Purchase_Order__c = purchaseOrderItem.Id;
                proformaInvoiceItem.Subtotal__c = subtotalValue++;
                proformaInvoiceItem.Tax__c = taxValue++;
                proformaInvoiceItem.cl_FFA_Invoice_Created__c = true;
                testProformaInvoiceList.add(proformaInvoiceItem);
            }
            purchaseOrderItem.Total_Billing__c = null;
            purchaseOrderItem.Pending_Billing__c = null;
        }
        insert testProformaInvoiceList;
        update testPurchaseOrderList;

        Test.startTest();

            PurchaseOrderServices.calculatePurchaseOrderTotals(new Map<Id, Purchase_Order__c>(testPurchaseOrderList).keySet());

        Test.stopTest();

        testPurchaseOrderList = [SELECT Id, Total_Billing__c, Pending_Billing__c,
                                        (Select Id, Total_Billed_Amount__c, cl_FFA_Invoice_Created__c
                                         From Pro_forma_Invoices__r)
                                 FROM Purchase_Order__c
                                 WHERE Id IN : testPurchaseOrderList];

        System.assert(!testPurchaseOrderList.isEmpty());
        for (Purchase_Order__c purchaseOrderItem : testpurchaseOrderList){
            Decimal totalBilledAmountValue = 0;
            Double pendingBillingValue = 0;
            System.assert(!purchaseOrderItem.Pro_forma_Invoices__r.isEmpty());
            for (Pro_forma_Invoice__c proformaInvoiceItem : purchaseOrderItem.Pro_forma_Invoices__r){
                if (proformaInvoiceItem.cl_FFA_Invoice_Created__c) {
                    totalBilledAmountValue += proformaInvoiceItem.Total_Billed_Amount__c;
                } else {
                    pendingBillingValue += proformaInvoiceItem.Total_Billed_Amount__c;
                }
            }
            //System.assertEquals(totalBilledAmountValue, purchaseOrderItem.Total_Billing__c);
            //System.assertEquals(pendingBillingValue, purchaseOrderItem.Pending_Billing__c);
        }
    }

	@isTest private static void testUpdatePoData() {
		setupData();
		Proposal__c tProposal = TestingUtils.createProposalListForTest(1, false)[0];
		tProposal.PO_Not_Required__c = false;
		INSERT tProposal;

		createProjectProfileForTest(1, false);
		testProjectProfileList[0].Proposal__c = tProposal.Id;
		INSERT testProjectProfileList;

		tProposal.Project_Profile__c = testProjectProfileList[0].Id;
		UPDATE tProposal; 

		Purchase_Order__c testPo = TestingUtils.createPurchaseOrderList(1, null, false)[0];
		testPo.Purchase_Order_Amount__c = 9999;
		testPo.Services__c = 3333;
		testPo.Reimbursables__c = 3333;
		testPo.Municipal_Fees__c = 3333;
		
		INSERT testPo;
		
        Pro_forma_Invoice__c testInvoice = TestingUtils.createProFormaInvoiceList (1, testContactWithAccountList[0].AccountId, testContactWithAccountList[0].Id, testBuildingList[0].Id, false)[0];
		testInvoice.Purchase_Order__c = testPo.Id;
		testInvoice.Subtotal__c = 1000;
        testInvoice.Tax__c = 333;
        testInvoice.cl_FFA_Invoice_Created__c = false;
		INSERT testInvoice;

		Service_Item__c sItem = TestingUtils.createServiceItemList(1, false)[0];
		sItem.Project_Profile__c = testProjectProfileList[0].Id;
		sItem.Purchase_Order__c = testPo.Id;
		INSERT sItem;

		List<Billing_Line_Item__c> blis = TestingUtils.createBillingLineItemList(2, testProjectProfileList[0].Id, testContactWithAccountList[0].AccountId, testContactWithAccountList[0].Id, false);
		blis[0].Project_Profile__c = testProjectProfileList[0].Id;
		blis[0].Service_Item__c = sItem.Id;
		blis[0].Department_Based__c = false;
		blis[0].Purchase_Order__c = null;
		blis[0].Billed__c = false;
		blis[0].Amount__c = 100;
		blis[0].isReimbursable__c = true;
		blis[1].Project_Profile__c = testProjectProfileList[0].Id;
		blis[1].Service_Item__c = sItem.Id;
		blis[1].Department_Based__c = false;
		blis[1].Purchase_Order__c = null;
		blis[1].Billed__c = false;
		blis[1].isReimbursable__c = false;
		blis[1].Amount__c = 100;
		INSERT blis;
		//blis[0].Purchase_Order__c = testPo.Id;
		//UPSERT blis;

		Test.startTest();
			PurchaseOrderServices.updatePurchaseOrdersData(new Set<Id> { testPo.Id });
			List<Purchase_Order__c> poList = PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems (new Set<Id> { testPo.Id });
			poList = PurchaseOrderServices.filterPOsWithLinkedServices(new List<Service_Item__c> { sItem }, new Map<Id, Service_Item__c> { sItem.Id => sItem });
			PurchaseOrderServices.populateProjectProfileOnPO(new List<Purchase_Order__c> { testPo } );
			Map<Id, Purchase_Order__c> getPurchaseOrdersForProposal = PurchaseOrderServices.getPurchaseOrdersForProposal(tProposal.Id);
			PurchaseOrderServices.PurchaseOrderComparableCreatedDate nestClass = new PurchaseOrderServices.PurchaseOrderComparableCreatedDate(testPo);
			Integer res = nestClass.compareTo(new PurchaseOrderServices.PurchaseOrderComparableCreatedDate(testPo));
			PurchaseOrderServices.deleteRelatedFilesAndFoldersForPurchaseOrder( testPo.Id );
			PurchaseOrderServices.deletePurchaseOrder(testPo, true);
		Test.stopTest();
	}
/*
    private static testmethod void testGetPurchaseOrderMapByProjectIds(){
        setupData ();
        createProjectProfileForTest(NUMBER_TO_CREATE_PROJECT_PROFILE, true);

        testPurchaseOrderList = new List<Purchase_Order__c>();
        for (Project_Profile__c projectProfileItem : testProjectProfileList){
            for (Purchase_Order__c purchaseOrderItem : TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, null, false)){
                purchaseOrderItem.Project_Profile__c = projectProfileItem.Id;
                purchaseOrderItem.NTE_Includes_Reimbursables__c = true;
                purchaseOrderItem.Purchase_Order_Amount__c = 20;
                purchaseOrderItem.Total_Billing__c = 15;
                testPurchaseOrderList.add(purchaseOrderItem);
            }
        }
        insert testPurchaseOrderList;

        Map<Id, Purchase_Order__c> resultPurchaseOrderMap;

        Test.startTest();

            resultPurchaseOrderMap = PurchaseOrderServices.getPurchaseOrderMapByProjectIds(new Map<Id, Project_Profile__c>(testProjectProfileList).keySet());

        Test.stopTest();

        System.assert(!resultPurchaseOrderMap.isEmpty());
        for (Purchase_Order__c purchaseOrderItem : resultPurchaseOrderMap.values()){
            System.assert(purchaseOrderItem.Remaining_Balance__c > 0);
            System.assert(purchaseOrderItem.NTE_Includes_Reimbursables__c);
            System.assert(new Map<Id, Project_Profile__c>(testProjectProfileList).containsKey(purchaseOrderItem.Project_Profile__c));
        }
    }
*/
    private static testmethod void testGetPurchaseOrderById(){
        testPurchaseOrderList = TestingUtils.createPurchaseOrderList(NUMBER_TO_CREATE_PURCHASE_ORDER, null, true);

        Purchase_Order__c resultPurchaseOrderRecord;

        Test.startTest();

            resultPurchaseOrderRecord = PurchaseOrderServices.getPurchaseOrderById(testPurchaseOrderList[0].Id);

        Test.stopTest();

        System.assert(resultPurchaseOrderRecord != null);
        System.AssertEquals(testPurchaseOrderList[0].Id, resultPurchaseOrderRecord.Id);
    }
}