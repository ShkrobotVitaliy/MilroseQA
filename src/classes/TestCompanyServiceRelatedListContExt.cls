@isTest
private class TestCompanyServiceRelatedListContExt {
    private static ApexPages.StandardController controller;
    private static CompanyServiceRelatedListContExt companyController;
    private static User projectManager;
    
    private static void setUp(){
        projectManager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
    }
    private static void getPageWithController(){
        Test.setCurrentPageReference(Page.CompanyServiceRelatedListPage);
        controller = new ApexPages.StandardController(projectManager);
        companyController = new CompanyServiceRelatedListContExt(controller);
    }
    
    @isTest(seeAllData = false) private static void testRerenderHightLowPrice(){
        setUp();
        getPageWithController();
        System.runAs(projectManager){                       
            
            Test.startTest();
                Boolean testBoolean = companyController.rerenderHightLowPrice;
            Test.stopTest();
            
            System.assertEquals(false, testBoolean);
        }
        
    }
}