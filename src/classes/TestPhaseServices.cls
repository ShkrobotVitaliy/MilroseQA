@isTest
private class TestPhaseServices {
    private static Integer numberToCreateGood = 5;
    private static Integer numberToCreateBad = 7;
    private static Integer oneUser = 1;

    static testMethod void testGetPhaseList_Proposal(){
        String projectName = 'testProject';
        User testUser = TestingUtils.createUsers(oneUser, 
                                                 'Phase0TestUserName@gmail.com', 
                                                 'Phase0TestUserSurname', 
                                                 'Phase0TestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true)[0];
            
        Account accountTest = TestingUtils.createAccountList(numberToCreateGood, 'TestAccount', true)[0];
        
        Contact contactTest = TestingUtils.createContactList(numberToCreateGood, false)[0];
        contactTest.AccountId =  accountTest.Id;
        insert contactTest;
        
        Building__c buildingsTest = TestingUtils.createBuildingList( numberToCreateGood, null, null, null, null, null, true )[0];
        Proposal__c proposal = TestingUtils.createProposalList( numberToCreateGood,
                                                                projectName,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                buildingsTest.Id,
                                                                null,
                                                                null,
                                                                Date.today(),
                                                                Date.today(),
                                                                null,
                                                                null,
                                                                null,
                                                                true )[0];     
    
        List<Phase__c> insertPhaseList = TestingUtils.createPhaseList( numberToCreateBad, false );
        List<Phase__c> phaseListGood = TestingUtils.createPhaseList( numberToCreateGood, false );
        
        for( Phase__c item : phaseListGood ){
            item.Proposal__c = proposal.Id;
        }
        
        insertPhaseList.addAll( phaseListGood );    
        
        insert insertPhaseList;
    
        Test.startTest();
            List<Phase__c> testPhaseList = PhaseServices.getPhaseList( proposal.Id, 'Name' );
        Test.stopTest();
    
        System.AssertEquals(phaseListGood.size(), testPhaseList.size());
        
        for(Phase__c item : testPhaseList){
            System.AssertEquals( proposal.Id,item.Proposal__c );
        }
    }
    
    private static testmethod void testGetPhaseList_Proposal_Draft(){            
        List<Phase__c> phaseListGood = TestingUtils.createPhaseList(numberToCreateGood, false);
        Proposal__c proposalDraft = TestingUtils.createProposalWithStatusDraftList(numberToCreateGood, true)[0];
        
        for(Phase__c item : phaseListGood){
            item.Proposal__c = proposalDraft.Id;
        }
        
        List<Phase__c> insertPhaseList = TestingUtils.createPhaseList(numberToCreateBad, false);        
            insertPhaseList.addAll(phaseListGood);         
        insert insertPhaseList;
        
        Test.startTest();
            List<Phase__c> testPhaseDraftList = PhaseServices.getPhaseList(proposalDraft.Id, 'Name');
        Test.stopTest();
        
        System.assertEquals(phaseListGood.size(), testPhaseDraftList.size());
        for(Phase__c item : testPhaseDraftList){
            System.AssertEquals( proposalDraft.Id,item.Proposal__c );
        }
    }


    private static testmethod void testSummarizeAllServicesTotals_Insert(){
        Integer Quantity  = 5;
        Integer Unit_Price = 5;
        
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, true);
        List<Service_Item__c> serviceList = new List<Service_Item__c>();            

        for(Phase__c phaseItem : phaseList){
            for(Service_Item__c item : TestingUtils.createServiceItemList(numberToCreateGood, false)){
                    item.Phase__c = phaseItem.Id;
                    item.Quantity__c = Quantity;
                    item.Unit_Price__c = Unit_Price;
                serviceList.add(item);

            }
        }

        Test.startTest();
            insert serviceList;
        Test.stopTest();

        System.assert(! serviceList.isEmpty() );

        for (Service_Item__c si : serviceList) {
            System.assert(si.Id != null);
        }

    }
    private static testmethod void testSummarizeAllServicesTotals_Update(){
        Integer Quantity  = 5;
        Integer Unit_Price = 5;
        
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, true);
        List<Service_Item__c> serviceList = new List<Service_Item__c>() ;           

        for(Phase__c phaseItem : phaseList){
            for(Service_Item__c item : TestingUtils.createServiceItemList(numberToCreateGood, false)){
                    item.Phase__c = phaseItem.Id;
                    item.Quantity__c = Quantity;
                    item.Unit_Price__c = Unit_Price;
                serviceList.add(item);

            }
        }
        insert serviceList;
        
        Integer Quantity_updated = 10;
        Integer Unit_Price_updated = 10; 
          
        for(Service_Item__c item : serviceList){           
            item.Quantity__c = Quantity_updated;
            item.Unit_Price__c = Unit_Price_updated;                   
        }
        
        Test.startTest();
            update serviceList;
        Test.stopTest();

        System.assert(! serviceList.isEmpty() );

        for (Service_Item__c si : serviceList) {
            System.assert(si.Id != null);
        }

    }
    
    private static testmethod void testGetPhaseMap(){   
        Integer numberC = 1;  
        
        String projectName = 'testProject';
        User testUser = TestingUtils.createUsers(oneUser, 
                                                 'Phase8TestUserName@gmail.com', 
                                                 'Phase8TestUserSurname', 
                                                 'Phase8TestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true)[0];
        Account accountTest = TestingUtils.createAccountList(numberToCreateGood, 'TestAccount', true)[0];
        
        Contact contactTest = TestingUtils.createContactList(numberToCreateGood, false)[0];
        contactTest.AccountId =  accountTest.Id;
        insert contactTest;
        
        Building__c buildingsTest = TestingUtils.createBuildingList( numberToCreateGood, null, null, null, null, null, true )[0];
        Proposal__c proposal = TestingUtils.createProposalList( numberToCreateGood,
                                                                projectName,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                buildingsTest.Id,
                                                                null,
                                                                null,
                                                                Date.today(),
                                                                Date.today(),
                                                                null,
                                                                null,
                                                                null,
                                                                true )[0];     

        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, false);
        for(Phase__c item : phaseList){
            item.Proposal__c = proposal.Id;
            item.Number__c = numberC;
            numberC++;
        }
        insert phaseList;
            
        List<Phase__c> phase_list_list = PhaseServices.getPhaseList(proposal.Id, 'Number__c');        
         
        Test.startTest();
            Map<Decimal,Phase__c> phaseMapTest = PhaseServices.getPhaseMap(proposal.Id);
        Test.stopTest();        
         
        System.assertEquals(phaseList.size(), phaseMapTest.values().size());
        
        for(Phase__c item : phaseMapTest.values()){
            System.assertEquals(proposal.Id, item.Proposal__c );
        }
         
    }

    private static testmethod void testRerenderPhaseNumber(){
        Integer phaseNumber = 1;
        Integer PhaseNumberTest = 1;
        
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, false);
        
        for(Phase__c phase : phaseList) {
            phase.Number__c = phaseNumber;             
        }    
        insert phaseList;
            
        Test.startTest();
            List <Phase__c> phaseListTest = PhaseServices.rerenderPhaseNumber(phaseList);
        Test.stopTest();
        
        System.assert(! phaseListTest.isEmpty() );

        for(Phase__c phaseTest : phaseListTest){            
            System.assertEquals( PhaseNumberTest++,phaseTest.Number__c );
        }
    }

    private static testmethod void testGetPhaseMapById(){
        String projectName = 'testProject';
        User testUser = TestingUtils.createUsers(oneUser, 
                                                 'Phase5TestUserName@gmail.com', 
                                                 'Phase5TestUserSurname', 
                                                 'Phase5TestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true)[0];
        Account accountTest = TestingUtils.createAccountList(numberToCreateGood, 'TestAccount', true)[0];
        
        Contact contactTest = TestingUtils.createContactList(numberToCreateGood, false)[0];
        contactTest.AccountId =  accountTest.Id;
        insert contactTest;
        
        Building__c buildingsTest = TestingUtils.createBuildingList( numberToCreateGood, null, null, null, null, null, true )[0];
        Proposal__c proposal = TestingUtils.createProposalList( numberToCreateGood,
                                                                projectName,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                buildingsTest.Id,
                                                                null,
                                                                null,
                                                                Date.today(),
                                                                Date.today(),
                                                                null,
                                                                null,
                                                                null,
                                                                true )[0];
                                                           
        Proposal__c proposalDraft = TestingUtils.createProposalWithStatusDraftList(numberToCreateGood, true)[0];
        
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, false);
        for(Phase__c item : phaseList){
            item.Is_default__c = false;                         
            item.Proposal__c = proposalDraft.Id;
        }
        insert  phaseList;
        
        phaseList = [SELECT Id,Name__c,Is_default__c,Proposal__c FROM Phase__c Where Proposal__c = :proposal.Id ];
        
        Test.startTest();
            Map<Id, Phase__c> testPhaseMap = PhaseServices.getPhaseMapById(proposal.Id, 'Name');
        Test.stopTest();
        
        System.assertEquals(phaseList.size(), testPhaseMap.size());
        Map<Id, Phase__c> testMap = new Map<Id, Phase__c>();
        for(Phase__c item : phaseList){
            testMap.put(item.id,item);
        }
        for(Phase__c item : testPhaseMap.values()){
            System.assertEquals(testMap.get(item.Id),item);         
        }   
    }
    
    private static testmethod void testSortPhase(){
        Integer testNumber = 1;
        Integer testAnotherNumber = 5;
        String projectName = 'testProject';
        User testUser = TestingUtils.createUsers(oneUser, 
                                                 'Phase6TestUserName@gmail.com', 
                                                 'Phase6TestUserSurname', 
                                                 'Phase6TestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true)[0];
        Account accountTest = TestingUtils.createAccountList(numberToCreateGood, 'TestAccount', true)[0];
        
        Contact contactTest = TestingUtils.createContactList(numberToCreateGood, false)[0];
        contactTest.AccountId =  accountTest.Id;
        insert contactTest;
        
        Building__c buildingsTest = TestingUtils.createBuildingList( numberToCreateGood, null, null, null, null, null, true )[0];
        Proposal__c proposal = TestingUtils.createProposalList( numberToCreateGood,
                                                                projectName,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                buildingsTest.Id,
                                                                null,
                                                                null,
                                                                Date.today(),
                                                                Date.today(),
                                                                null,
                                                                null,
                                                                null,
                                                                true )[0];
        Proposal__c proposalDraft = TestingUtils.createProposalWithStatusDraftList(numberToCreateGood, true)[0];
        List<Phase__c> badPhaseList = TestingUtils.createPhaseList(numberToCreateGood, true);
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, false);
        for(Phase__c item : phaseList){
            item.Name = 'TestName' + testAnotherNumber--;
            item.Proposal__c = proposal.Id;
        }
        insert  phaseList;
        
            
        
        Test.startTest();
            List<Phase__c> testPhaseList = PhaseServices.sortPhase('Name', proposal.Id);
        Test.stopTest();
        
        System.assertEquals(phaseList.size(), testPhaseList.size());
                                                                        
    }
    
    private static testmethod void testSortPhase_ProposalDraft(){
        Integer testNumber = 1;
        Integer testAnotherNumber = 5;
        String projectName = 'testProject';
        User testUser = TestingUtils.createUsers(oneUser, 
                                                 'Phase7TestUserName@gmail.com', 
                                                 'Phase7TestUserSurname', 
                                                 'Phase7TestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true)[0];
        Account accountTest = TestingUtils.createAccountList(numberToCreateGood, 'TestAccount', true)[0];
        
        Contact contactTest = TestingUtils.createContactList(numberToCreateGood, false)[0];
        contactTest.AccountId =  accountTest.Id;
        insert contactTest;
        
        Building__c buildingsTest = TestingUtils.createBuildingList( numberToCreateGood, null, null, null, null, null, true )[0];
        Proposal__c proposal = TestingUtils.createProposalList( numberToCreateGood,
                                                                projectName,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                accountTest.Id,
                                                                contactTest.Id,
                                                                buildingsTest.Id,
                                                                null,
                                                                null,
                                                                Date.today(),
                                                                Date.today(),
                                                                null,
                                                                null,
                                                                null,
                                                                true )[0];
        Proposal__c proposalDraft = TestingUtils.createProposalWithStatusDraftList(numberToCreateGood, true)[0];
        List<Phase__c> badPhaseList = TestingUtils.createPhaseList(numberToCreateGood, true);
        List<Phase__c> phaseList = TestingUtils.createPhaseList(numberToCreateGood, false);
        for(Phase__c item : phaseList){
            item.Name = 'TestName' + testAnotherNumber--;
            item.Proposal__c = proposalDraft.Id;
        }
        insert  phaseList;
        
            
        
        Test.startTest();
            List<Phase__c> testPhaseList = PhaseServices.sortPhase('Name', proposalDraft.Id);
        Test.stopTest();
        
        System.assertEquals(phaseList.size(), testPhaseList.size());
    }
}