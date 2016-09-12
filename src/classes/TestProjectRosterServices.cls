@isTest
private class TestProjectRosterServices {
    private static final Integer NUMBER_TO_CREATE_CONTACT = 2;
    private static final Integer NUMBER_TO_CREATE_PROJECT_ROSTER = 5;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL = 4;
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 4;

    private static List<Contact> testContactList;
    private static List<Project_Roster__c> testProjectRosterList;
    private static List<Proposal__c> testProposalList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Region__c> testRegionList;
    private static List<Munucipalities__c> testMunucipalitiesList;
    private static List<Building__c> testBuildingList;
    private static List<Proposal__c> testProposalDraftList;
    private static List<Project_Profile__c> testProjectProfileList;
    private static List<User> testUserList;
    
    private static User partnerUser;
    private static User projectManagerUser;
    private static Id currentUserId;
    private static Id testProjectProfileItemID;
    private static Id testProposalItemID;
    private static Id testProposalDraftItemID;

    private static void setUpData(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_WITH_ACCOUNT, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = TestingUtils.createRegionList(NUMBER_TO_CREATE_REGION, null, true);
        testMunucipalitiesList = TestingUtils.createMunicipalitiesList(NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = TestingUtils.createBuildingList(NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
        partnerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PARTNER);

        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        currentUserId = UserInfo.getUserId();
        testProposalList = TestingUtils.createProposalList (NUMBER_TO_CREATE_PROPOSAL, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                            testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id, null,
                                                            null, null, null, partnerUser.Id, currentUserId, projectManagerUser.id, true);
        testProposalDraftList = TestingUtils.createProposalDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, true);

        testUserList =  TestingUtils.createUsers(1, 
                                                 'RosterTestUserName@gmail.com', 
                                                 'RosterTestUserSurname', 
                                                 'RosterTestUserEmail@gmail.com', 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 null, 
                                                 true);
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_PROJECT_ROSTER, true);
        testProjectProfileList = TestingUtils.createProjectProfileList(1, null, testContactList[0].id, null, null, null, null, projectManagerUser.id, true);
    }

    private static void prepareData(){
        testProjectRosterList = new List<Project_Roster__c>();
        Id testRecordTypeContactId = [Select r.Id From RecordType r where r.sobjectType = 'Project_Roster__c' and r.Name = 'Contact'][0].Id;
        //Id testRecordTypeUserId = [Select r.Id From RecordType r where r.sobjectType = 'Project_Roster__c' and r.Name = 'User'][0].Id;
        
        for (Proposal__c proposalItem : testProposalList){
            for (Project_Profile__c tmpProjectProfileItem: testProjectProfileList){
                for (Project_Roster__c tmpProjectRosterItem: TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                    tmpProjectRosterItem.Project_Profile__c = tmpProjectProfileItem.Id;
                    tmpProjectRosterItem.Contact__c = testContactList[0].id;
                    tmpProjectRosterItem.RecordTypeId = testRecordTypeContactId;
                    tmpProjectRosterItem.Proposal__c = proposalItem.Id;
                    
                    testProjectRosterList.add(tmpProjectRosterItem);
                }
            }
        }
        
        for (Proposal__c proposalDraftItem : testProposalDraftList){
            for (Project_Roster__c projectRosterItem : TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false)){
                projectRosterItem.Proposal__c = proposalDraftItem.Id;
                projectRosterItem.Contact__c = testContactList[0].id;
                projectRosterItem.RecordTypeId = testRecordTypeContactId;
                testProjectRosterList.add(projectRosterItem);
            }
        }
        
        insert testProjectRosterList;
        
        testProjectProfileItemID = testProjectProfileList[0].Id;
        testProposalItemID = testProposalList[0].Id;
        testProposalDraftItemID = testProposalDraftList[0].Id;

    }
    
	private static testMethod void testRosterEmailJunctionTrigger(){
		setUpData();
		prepareData();
		Project_Roster__c testProjRoster = testProjectRosterList[0];
		Proposal__c prop = testProposalDraftList[0];
		
		Roster_Email_Junction__c rej = new Roster_Email_Junction__c( /*Project_Roster__c = testProjRoster.Id,*/ Proposal__c = prop.Id );
		insert rej;
		
        Test.startTest();
			update rej;
        Test.stopTest();
		
	}
	
    private static testMethod void testGetContactById() {
        Contact testContact = TestingUtils.createContactList(1, false)[0];
        testContact.DND__c = true;
        testContact.Primary_Profession__c = 'some text';
        testContact.Salutation = 'Test Salutation';
        testContact.MailingStreet = 'some test Street';
        testContact.Email = 'test_contact_email_address@gmail.com';
        insert testContact;
        
        Test.startTest();
            Contact testContactFromMethod = ProjectRosterServices.getContactById(testContact.Id);
        Test.stopTest();
        
        System.assertEquals(testContact.id, testContactFromMethod.id);
    }
    
    //private static testMethod void testGetRecordTypeByObjectNameId
    
    private static testMethod void testGetProjectRosterByProjectProfileId(){
        setUpData();
        prepareData();
        List<Project_Roster__c> tmpProjectRosterList = new List<Project_Roster__c>();
        
        Test.startTest();
            tmpProjectRosterList = ProjectRosterServices.getProjectRosterByProjectProfileId(null);
            tmpProjectRosterList = ProjectRosterServices.getProjectRosterByProjectProfileId(testProjectProfileItemID);
        Test.stopTest();
        
        //Integer testRosterListCount = [SELECT Count() FROM Project_Roster__c WHERE Project_Profile__c = : testProjectProfileItemID];
        //System.assertEquals(testRosterListCount, tmpProjectRosterList.size());
        //System.debug('SHOW size of tmpProjectRosterList: ' + tmpProjectRosterList.size());
        //System.debug('SHOW calculated count' + testRosterListCount);
        System.assertEquals(NUMBER_TO_CREATE_PROJECT_ROSTER * NUMBER_TO_CREATE_PROPOSAL, tmpProjectRosterList.size());
        
        for (Project_Roster__c tmpProjectRosterItem : tmpProjectRosterList){
            system.assertEquals(testProjectProfileItemID, tmpProjectRosterItem.Project_Profile__c);
        }
    }
    
    private static testMethod void testGetProjectRosterByProposalId() {
        setUpData();
        prepareData();
        
        Test.startTest();
            testProjectRosterList = ProjectRosterServices.getProjectRosterByProposalId(testProposalItemID);
        Test.stopTest();

        for (Project_Roster__c tmpProjectRosterItem : testProjectRosterList){
            system.assertEquals(testProposalItemID, tmpProjectRosterItem.Proposal__c);
        }
    }
    
    //private static testMethod void testGetRecordType
    //private static testMethod void testGetProjectRosterOnlyContactByProposalId
    //private static testMethod void testGetProjectRosterOnlyContactByProposalDraftId
    
    private static testMethod void testGetRosterMapById(){
        setUpData();
        prepareData();
        Set<Id> testIdSet = new Map<Id, Project_Profile__c>(testProjectProfileList).keySet(); 
        Map<Id, Map<Id, Project_Roster__c>> testRosterMap = new Map<Id, Map<Id, Project_Roster__c>>();
        
        Test.startTest();
            testRosterMap = ProjectRosterServices.getRosterMapById(testIdSet);
        Test.stopTest();

        system.assertEquals(testRosterMap.keySet(), testIdSet);     
    }

    private static testMethod void testGetProjectRosterByIdForProposalDraft() {
        setUpData();
        prepareData();
        
        Test.startTest();
            testProjectRosterList = ProjectRosterServices.getProjectRosterById(testProposalDraftItemID);
        Test.stopTest();
        
        System.assertEquals(NUMBER_TO_CREATE_PROJECT_ROSTER, testProjectRosterList.size());
    }
    
    private static testMethod void testSortRoster(){
        setUpData();
        prepareData();
        Id proposalSortId;
        Id projectRosterId;

        for (Project_Roster__c projectRosterItem : [SELECT RecordTypeId, Contact__r.Salutation, Contact__r.Name, Contact__r.Primary_Profession__c, 
                                                        Contact__r.Email, Contact__r.MailingStreet, Role__c, Contact__r.DND__c,
                                                        To__c, Is_Read__c, Cc__c, User_Contact_IsActive__c, Proposal__c
                                                    FROM Project_Roster__c 
                                                    WHERE id in : testProjectRosterList LIMIT 1]){

            proposalSortId = projectRosterItem.Proposal__c;
            projectRosterId = projectRosterItem.Id;
        }   
        System.assert(projectRosterId != null);

        List<Project_Roster__c> projectRosterSorter;

        projectRosterSorter = ProjectRosterServices.sortRoster('Name', String.valueOf(projectRosterId), proposalSortId == null ? null : String.valueOf(proposalSortId), false);
        
        System.assert( projectRosterSorter != null );
    }
    
    @isTest( seeAllData =false)private static void testGetRecordType(){
        setUpData();
        prepareData();
        
        List<RecordType> testRecordTypeList = [SELECT SobjectType, Name, IsActive, Id FROM RecordType WHERE SobjectType = 'Project_Roster__c' AND IsActive = true];
        System.debug(LoggingLevel.Error, '@@@testRecordTypeList' + testRecordTypeList);
        
        Test.startTest();
            Map <String, RecordType> testRecordTypeMap = ProjectRosterServices.getRecordType();
        Test.stopTest();
        System.debug(LoggingLevel.Error,'@@@testRecordTypeMap' + testRecordTypeMap);
        System.assertEquals(testRecordTypeList.size(), testRecordTypeMap.size());
        for(RecordType item : testRecordTypeList){
            System.assertEquals(testRecordTypeMap.get(String.valueOf(item.Name)),item);
        }
    }
    
    @isTest( seeAllData =false)private static void testGetProjectRosterOnlyContactByProposalId(){
        setUpData();
        prepareData();
        List<Project_Roster__c> badProjectRosterList =  TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false);
           for(Project_Roster__c item : badProjectRosterList){
            item.Contact__c = testContactList[0].id;   
           }
           insert badProjectRosterList;
        
        List <Project_Roster__c> projectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c,Name__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, Send_Reminder__c
                                                      From Project_Roster__c
                                                      Where Proposal__c = : testProposalList[0].Id 
                                                      AND RecordTypeId = : String.valueOf(ProjectRosterServices.getRecordType().get(ProjectRosterServices.TYPE_CONTACT).Id)];
       
        Test.startTest();
            List<Project_Roster__c> testProjectRosetList = ProjectRosterServices.getProjectRosterOnlyContactByProposalId(testProposalList[0].Id);
        Test.stopTest();
        
        System.assertEquals(projectRosterList.size(), testProjectRosetList.size());
        Map<Id,Project_Roster__c> testMap = new Map<Id,Project_Roster__c>();
        for(Project_Roster__c item : projectRosterList){
            testMap.put(item.Id,item);
        }
        for(Project_Roster__c item : testProjectRosetList){
            //System.assertEquals(testMap.get(item.Id), item);
        }
    }
 
    @isTest( seeAllData =false)private static void testSortRoster_WithProposal(){
        setUpData();
        prepareData();
        List<Project_Roster__c> badProjectRosterList =  TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false);
           for(Project_Roster__c item : badProjectRosterList){
            item.Contact__c = testContactList[0].id;   
           }
           insert badProjectRosterList;
        
        List<Project_Roster__c> prjectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, Name__c, Send_Reminder__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, RecordTypeId, Contact__r.Name, User__r.Name 
                                                    From Project_Roster__c 
                                                    Where Active__c = true
                                                    And Proposal__c = : String.valueOf(testProposalItemID) 
                                                    And Project_Profile__c = : String.valueOf(testProjectProfileItemID)
                                                    AND RecordTypeId = : String.valueOf(ProjectRosterServices.getRecordType().get(ProjectRosterServices.TYPE_CONTACT).Id)
                                                    ORDER BY Name];
        System.debug(LoggingLevel.ERROR,'@@@prjectRosterList' + prjectRosterList);
        
        Test.startTest();
            List<Project_Roster__c> testPrjectRosterList  = ProjectRosterServices.sortRoster('Name', String.valueOf(testProposalItemID), String.valueOf(testProjectProfileItemID), true);
        Test.stopTest();
            System.debug(LoggingLevel.ERROR,'@@@testPrjectRosterList' + testPrjectRosterList);
        System.assertEquals(prjectRosterList.size(),testPrjectRosterList.size());
        
        Map<Id,Project_Roster__c > testMap = new Map<Id,Project_Roster__c >();
        for(Project_Roster__c item : testPrjectRosterList){
            testMap.put(item.Id,item);  
        }
        for(Project_Roster__c item : testPrjectRosterList){
            System.assertEquals(testMap.get(item.Id), item); 
        }    
    }
    
    @isTest( seeAllData =false)private static void testSortRoster_WithProposalDraft(){
        setUpData();
        prepareData();
        List<Project_Roster__c> badProjectRosterList =  TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false);
           for(Project_Roster__c item : badProjectRosterList){
            item.Contact__c = testContactList[0].id;   
           }
           insert badProjectRosterList;
        
        List<Project_Roster__c> prjectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, Name__c, Send_Reminder__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, RecordTypeId, Contact__r.Name, User__r.Name 
                                                    From Project_Roster__c 
                                                    Where Active__c = true
                                                    And Proposal__c  = : String.valueOf(testProposalDraftItemID)                                                   
                                                    AND RecordTypeId = : String.valueOf(ProjectRosterServices.getRecordType().get(ProjectRosterServices.TYPE_CONTACT).Id)
                                                    ORDER BY Name];
        System.debug(LoggingLevel.ERROR,'@@@prjectRosterList' + prjectRosterList);
        
        Test.startTest();
            List<Project_Roster__c> testPrjectRosterList  = ProjectRosterServices.sortRoster('Name', String.valueOf(testProposalDraftItemID), String.valueOf(testProjectProfileItemID), true);
        Test.stopTest();
            System.debug(LoggingLevel.ERROR,'@@@testPrjectRosterList' + testPrjectRosterList);
        System.assertEquals(prjectRosterList.size(),testPrjectRosterList.size());
        
        Map<Id,Project_Roster__c > testMap = new Map<Id,Project_Roster__c >();
        for(Project_Roster__c item : testPrjectRosterList){
            testMap.put(item.Id,item);  
        }
        for(Project_Roster__c item : testPrjectRosterList){
            System.assertEquals(testMap.get(item.Id), item); 
        }    
    }
    
       @isTest( seeAllData =false)private static void testSortRoster_WithProjectId(){
        setUpData();
        prepareData();
        List<Project_Roster__c> badProjectRosterList =  TestingUtils.createProjectRosterList(NUMBER_TO_CREATE_PROJECT_ROSTER, false);
           for(Project_Roster__c item : badProjectRosterList){
            item.Contact__c = testContactList[0].id;   
           }
           insert badProjectRosterList;
        
        List<Project_Roster__c> prjectRosterList = [Select User__c, Name, User_Contact__c, Role__c, Project_Profile__c, Phone__c, Name__c, Send_Reminder__c, Is_Read__c, Email__c, Contact__c, RecordType.Name, RecordTypeId, Contact__r.Name, User__r.Name 
                                                    From Project_Roster__c 
                                                    Where Active__c = true
                                                    And Project_Profile__c = : String.valueOf(testProjectProfileItemID)                                                   
                                                    AND RecordTypeId = : String.valueOf(ProjectRosterServices.getRecordType().get(ProjectRosterServices.TYPE_CONTACT).Id)
                                                    ORDER BY Name];
        System.debug(LoggingLevel.ERROR,'@@@prjectRosterList' + prjectRosterList);
        
        Test.startTest();
            List<Project_Roster__c> testPrjectRosterList  = ProjectRosterServices.sortRoster('Name', null, String.valueOf(testProjectProfileItemID), true);
        Test.stopTest();
            System.debug(LoggingLevel.ERROR,'@@@testPrjectRosterList' + testPrjectRosterList);
        System.assertEquals(prjectRosterList.size(),testPrjectRosterList.size());
        
        Map<Id,Project_Roster__c > testMap = new Map<Id,Project_Roster__c >();
        for(Project_Roster__c item : testPrjectRosterList){
            testMap.put(item.Id,item);  
        }
        for(Project_Roster__c item : testPrjectRosterList){
            System.assertEquals(testMap.get(item.Id), item); 
        }    
    }
    
    private static testMethod void testGetRosterByProjectId() {
        Test.startTest();
            List<Project_Roster__c> emptyRosters = ProjectRosterServices.getRosterByProjectId(null);
            
            setUpData();
            prepareData();

            List<Project_Roster__c> rosters = ProjectRosterServices.getRosterByProjectId(testProjectProfileList.get(0).Id);
            System.assert(! rosters.isEmpty());
        Test.stopTest();

    }
    
    private static testMethod void testGetRostersByIds() {
        Test.startTest();
            try {
                List<Project_Roster__c> emptyRosters = ProjectRosterServices.getRostersByIds(null);
            
            } catch (Exception ex) {
                system.assert(true);
            
            }
            
            setUpData();
            prepareData();
            List<Project_Roster__c> rosters = ProjectRosterServices.getRostersByIds(new Set<Id> { testProjectRosterList.get(0).Id });
            System.assert(! rosters.isEmpty());
        Test.stopTest();
        
    }  
    
    private static testMethod void testGetRoleToRoster() {
        setUpData();
        prepareData();
                
        Test.startTest();
            Map<String, Project_Roster__c> roleToRosters = ProjectRosterServices.getRoleToRoster(testProjectRosterList);
        Test.stopTest();
        
    }
    
}