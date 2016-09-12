@isTest
private class TestChangeOrderController {
    private static List<Project_Team__c> testProjectTeamList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;

    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;

    private static Proposal__c proposal;
    private static List<Phase__c> phases;
    private static List<Change_Order__c> changeOrders;
    private static List<Service_Item__c> serviceItems;

    private static ChangeOrderController controller;

    private static void setupGeneralData() {
        TestingUtils.setupData();
        partnerUser = TestingUtils.testPartnerUser;
        projectManagerUser = TestingUtils.testProjectManagerUser;
        currentUserId = TestingUtils.testCurrentUserId;
        testProjectTeamList = TestingUtils.testProjectTeamList;
        testAccountList = TestingUtils.testAccountList;
        testContactWithAccountList = TestingUtils.testContactWithAccountList;
        testRegionList = TestingUtils.testRegionList;
        testMunucipalitiesList = TestingUtils.testMunucipalitiesList;
        testBuildingList = TestingUtils.testBuildingList;
    }

    private static void setup() {
        proposal = TestingUtils.createProposalListForTest( 1, false )[0];
        proposal.Reimbursable_Percentage__c = 1;
        INSERT proposal;

        phases = TestingUtils.createPhaseList( 1, false );
        phases[0].Proposal__c = proposal.Id;
        INSERT phases;

        changeOrders = TestingUtils.createChangeOrderList( 2, false );
        for( Change_Order__c co : changeOrders ) {
            co.Proposal__c = proposal.Id;
        }
        changeOrders[0].Status__c = ChangeOrderServices.STATUS_APPROVED;
        changeOrders[1].Status__c = ChangeOrderServices.STATUS_PENDING_CLIENT;
        INSERT changeOrders;
        
        serviceItems = TestingUtils.createServiceItemList(6, proposal.Id, false);
        for( Service_Item__c si : serviceItems ) {
            si.Proposal__c = proposal.Id;
            si.Phase__c = phases[0].Id;
            si.Is_Alternative__c = false;
            si.Quantity__c = 10;
            si.Original__c = true;
            si.Unit_Price__c = 10;
            si.Discount_Percentage__c = 10;
        }
        serviceItems[0].Service_Group_Key__c = String.valueOf( Math.random() );

        serviceItems[1].Is_Amendmend_Deleted__c = true;
        serviceItems[1].Change_Order__c = changeOrders[0].Id;

        serviceItems[2].Quantity_Old__c = serviceItems[2].Quantity__c + 1;
        serviceItems[2].Change_Order__c = changeOrders[0].Id;

        serviceItems[3].Original__c = false;
        serviceItems[3].Is_Amendmend_Added__c = true;
        serviceItems[3].Change_Order__c = changeOrders[1].Id;

        serviceItems[4].Original__c = false;
        serviceItems[4].Is_Amendmend_Added__c = true;
        serviceItems[4].Is_Amendmend_Deleted__c = true;
        serviceItems[4].Change_Order__c = changeOrders[1].Id;
        serviceItems[4].Change_Order_Old__c = changeOrders[0].Id;

        serviceItems[5].Service_Group_Key__c = String.valueOf( Math.random() );
        serviceItems[5].Original__c = false;
        serviceItems[5].Is_Amendmend_Added__c = true;
        serviceItems[5].Quantity_Old__c = serviceItems[5].Quantity__c + 1;
        serviceItems[5].Change_Order__c = changeOrders[1].Id;
        serviceItems[5].Change_Order_Old__c = changeOrders[0].Id;
        INSERT serviceItems;
    }

    private static void createController( String proposalId ) {
        Test.setCurrentPageReference(Page.ChangeOrder);
        ApexPages.currentPage().getParameters().put( 'p', String.valueOf( proposalId ) );
        controller = new ChangeOrderController();
    }

    private static testmethod void generalInit() {
        setupGeneralData();
        setup();

        Test.startTest();
            createController( proposal.Id );
        Test.stopTest();
    }

    /*private static testmethod void initWithoutProposal() {
        setupGeneralData();
        setup();

        DELETE proposal;

        Test.startTest();
            createController( proposal.Id );
        Test.stopTest();
    }

    private static testmethod void initWithBadParameter() {
        setupGeneralData();
        setup();

        Test.startTest();
            createController( 'abc' );
        Test.stopTest();
    }*/
}