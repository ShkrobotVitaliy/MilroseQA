@isTest
private class TestAssignmentWrapper{ 
	private static final String teamName = 'teamName';
	private static final String clientFactor = '5';
	private static final String buildingFactor = '5';
	private static final String totalWorkloadFactor = 'totalWorkloadFactor';
	private static final Integer clientFactorInteger = 7;
	private static final Integer buildingFactorInteger = 7;
	private static final Double totalWorkloadFactorDecimal = Double.valueOf(7);
	
	
    private static final Integer NUMBER_TO_CREATE = 5;
    private static AssignmentWrapper wrap;
    private static Account testAccount;
    private static Contact testContact;
    private static User projectManagerUser;
    private static List<Project_Profile__c> testProjectProfileList; 

    private static void setUp(){
        projectManagerUser = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
        testAccount = TestingUtils.createAccountList(NUMBER_TO_CREATE, null, true)[0];
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, testAccount.Id, true)[0];  
        testProjectProfileList = TestingUtils.createProjectProfileList (NUMBER_TO_CREATE, testAccount.Id, testContact.Id,
                                                                        testAccount.Id, testContact.Id, testAccount.Id,
                                                                        testContact.Id, projectManagerUser.Id, true);
    }

    private static void setUpSecondWrapper(){
        wrap = new AssignmentWrapper(teamName, clientFactorInteger, buildingFactorInteger,totalWorkloadFactorDecimal, totalWorkloadFactor, true, true);
    }
    
    @isTest(seeAllData = false) private static void testSecondWrapper(){
        
        Test.startTest();
            setUpSecondWrapper();
        Test.stopTest();
        
        System.assertEquals(teamName, wrap.teamName);
        System.assertEquals(clientFactorInteger, wrap.clientFactor);
        System.assertEquals(buildingFactorInteger, wrap.buildingFactor);
        System.assertEquals(totalWorkloadFactor, wrap.totalWorkloadFactor);
    }
            
    @isTest(seeAllData = false)private static void testOrderBy(){
        setUpSecondWrapper();
        
        Test.startTest();
            String orderBy = wrap.orderBy;
        Test.stopTest();
        
        System.assertEquals('ASC', orderBy);
    }
    
    @isTest(seeAllData = false)private static void testSortName(){
        setUpSecondWrapper();
        
        Test.startTest();
            String sortName = wrap.sortName;
        Test.stopTest();
        
        System.assert( sortName != null);
    }
    
    
    @isTest(seeAllData = false)private static void testCompareToTeamName(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(wrap);
        Test.stopTest();
        
        System.assert(testCompTo != null);
    }
    
    @isTest(seeAllData = false)private static void testCompareToClientFactor(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        wrap.sortName = 'clientFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(wrap);
        Test.stopTest();
        
        System.assertEquals(0, testCompTo);
    }
    
    @isTest(seeAllData = false)private static void testCompareToClientFactorSecondCondition(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        wrap.sortName = 'clientFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(new AssignmentWrapper('TestName', 15, 5,Double.valueOf(5), totalWorkloadFactor, true, true));
        Test.stopTest();
        
        System.assert(testCompTo != null);
    }
    
    @isTest(seeAllData = false)private static void testCompareToBuildingFactor(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        wrap.sortName = 'buildingFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(wrap);
        Test.stopTest();
        
        System.assertEquals(0, testCompTo);
    }
    
       
    @isTest(seeAllData = false)private static void testCompareToTotalWorkloadFactor(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        wrap.sortName = 'totalWorkloadFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(new AssignmentWrapper('TestName', 5, 5,Double.valueOf(5), totalWorkloadFactor, true, true));
        Test.stopTest();
        
        System.assert(testCompTo != null);
    }
    
    @isTest(seeAllData = false)private static void testCompareToTotalWorkloadFactorSecondCondition(){
        setUp();
        setUpSecondWrapper();
        wrap.orderBy = 'DESC';
        wrap.sortName = 'totalWorkloadFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(new AssignmentWrapper('TestName', 5, 5,Double.valueOf(15), totalWorkloadFactor, true, true));
        Test.stopTest();
        
        System.assert(testCompTo != null);
    }
    
    @isTest(seeAllData = false)private static void testCompareToBuildingFactorTeamNameisNull(){
        setUp();
        wrap = new AssignmentWrapper(null, 5, 5,Double.valueOf(15), totalWorkloadFactor, true, true);
        wrap.orderBy = 'DESC';
        wrap.sortName = 'buildingFactor';
        
        Test.startTest();
            Integer testCompTo = wrap.compareTo(wrap);
        Test.stopTest();
        
        System.assertEquals(0, testCompTo);
    }
    
}