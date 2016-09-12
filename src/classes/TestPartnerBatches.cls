@isTest
private class TestPartnerBatches {

    @isTest( SeeAllData = true ) static void testCreatePreBatchFullRecalculation (){
        Test.startTest();
            Database.executeBatch( new CreatePreBatchFullRecalculation() );
        Test.stopTest();

    }

    @isTest( SeeAllData = false ) static void testCreateBatchForPartnerReportsMonth (){
        Test.startTest();
            CreateBatchForPartnerReportsMonth partnerReportsBatch = new CreateBatchForPartnerReportsMonth();
            partnerReportsBatch.execute();
        Test.stopTest();
    }

    @isTest( SeeAllData = false ) static void testCreateBatchForPartnerReportsMonthNull (){
        Test.startTest();
            CreateBatchForPartnerReportsMonth partnerReportsBatch = new CreateBatchForPartnerReportsMonth();
            partnerReportsBatch.execute( null );
        Test.stopTest();
    }

}