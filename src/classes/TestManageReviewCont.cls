@isTest
private class TestManageReviewCont {

    private static ApexPages.StandardController testController;
    private static ManageReviewCont testManageReviewCont;

    private static testMethod void testManageReviewCont() {

        Test.setCurrentPageReference(Page.ManageReview);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, true)[0] );

        Test.startTest();
            testManageReviewCont = new ManageReviewCont(testController);
            System.assert(testManageReviewCont != null);

            List<Review__c> test1 = testManageReviewCont.reviewList;
            testManageReviewCont.save();
            testManageReviewCont.addNew();
            testManageReviewCont.save();
            
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }

    private static testMethod void testManageReviewCont1() {

        Test.setCurrentPageReference(Page.ManageReview);

        User u = TestingUtils.userWithProfile( UserServices.PROFILE_PROJECT_MANAGER_2 );

        Project_Profile__c project = TestingUtils.createProjectProfileForTest(1, true)[0];
        Task_Item__c taskItem = TestingUtils.createTaskItemList(1, false)[0];
        taskItem.Project_Profile__c = project.Id;
        INSERT taskItem;

        Id projectRosterUserRecordTypeId;
        Map<String, Id> projectRosterRecordTypesMap = TestingUtils.getRecordTypeNameIdByObjecttypename('Project_Roster__c');
        for (String projectRosterRecordTypeNameValue : projectRosterRecordTypesMap.keySet()){
            if (projectRosterRecordTypeNameValue == 'User') {
                projectRosterUserRecordTypeId = projectRosterRecordTypesMap.get(projectRosterRecordTypeNameValue);
                break;
            }
        }
        List<Project_Roster__c> rosters = TestingUtils.createProjectRosterList(5, false);
        for( Project_Roster__c pR : rosters ) {
            pR.Project_Profile__c = project.Id;
            pR.User__c = u.Id;
            pR.User_Contact__c = 'User';
            pR.RecordTypeId = projectRosterUserRecordTypeId;
        }
        INSERT rosters;

        testController = new ApexPages.StandardController( taskItem );
        
        Test.startTest();
            testManageReviewCont = new ManageReviewCont(testController);
            List<Review__c> test1 = testManageReviewCont.reviewList;
            testManageReviewCont.addNew();
            List<Review__c> reviewList = new List<Review__c>();
            for( Review__c item: [SELECT Review_End_Date__c, Review_Start_Date__c, Task_Item__c, Id FROM Review__c Where Task_Item__c =: testManageReviewCont.currentTaskItem.Id]){
                item.Review_Start_Date__c = Date.today();
                item.Review_End_Date__c = Date.today() - 1;
                reviewList.add(item);
            } 
            update reviewList;

            System.assert(! reviewList.isEmpty() );
            
            testManageReviewCont.save();
            testManageReviewCont.save();

            List<SelectOption> rosterIdToContact = testManageReviewCont.rosterIdToContact;
            testManageReviewCont.currentTaskItem = null;
            testManageReviewCont.addNew();

        Test.stopTest();

        System.assert( ApexPages.hasMessages() );
    }

    private static testMethod void testManageReviewCont2() {

        Test.setCurrentPageReference(Page.ManageReview);
        testController = new ApexPages.StandardController( TestingUtils.createTaskItemList(1, false)[0] );
        
        Test.startTest();
            testManageReviewCont = new ManageReviewCont(testController);
            List<Review__c> test1 = testManageReviewCont.reviewList;
            testManageReviewCont.addNew();
            
            testManageReviewCont.save(); 
        Test.stopTest();

        System.assert(! ApexPages.hasMessages() );
    }
}