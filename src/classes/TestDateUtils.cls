@isTest
private class TestDateUtils {
    private static BusinessHours testBizHours;
    private static DateTime testStartDateTime = datetime.newInstance(2011, 1, 4, 0, 0, 0);
    private static String testDuration = '5';
    private static String testDurationWithDays = '5d';
    private static String testDurationWithDaysAndHours = '5.5d';
    private static String testDurationWithHours = '5h';
    private static String testDurationWithHoursAndMinutes = '5.5h';

    private final static Long ONE_MINUTE = DateUtils.ONE_MINUTE;
    private final static Long ONE_HOUR = DateUtils.ONE_HOUR;
    private final static Long ONE_DAY = DateUtils.ONE_DAY;
    private static Date testStartDate = Date.newInstance(1988, 3, 22);
    private static Date testEndDate = Date.newInstance(1988, 7, 22);    
    private static Date testSetCurrentDate = Date.newInstance(2013, 9, 27);

    private final static String MONTHLY_FREQUENCY = 'Monthly';
    private final static String WEEKLY_FREQUENCY = 'Weekly';
    private final static String QUARTERLY_FREQUENCY = 'Quarterly';
    private final static String YEARLY_FREQUENCY = 'Yearly';
    private final static String ANNUALLY_FREQUENCY = 'Annually';
    private final static String ONE_TIME_FEE_FREQUENCY = 'One Time Fee';
    private static String testQuarterlyMonth = '1st';
    private static Integer testBillingDayMonthly = 30;
    private static String testBillingDayWeekly = 'Wednesday';
    private static Integer testBillingDayQuarter= 30; 

    private final static Integer DAYS_IN_WEEK = 7;
    private final static Integer MONTHS_IN_QUARTER = 3;

    private static void setUp(){
         testBizHours = [ SELECT Id FROM BusinessHours WHERE IsDefault = true ];             
    }

    @isTest( seeAllData = false ) private static void testGetDatetimeWithTimeShiftByBusinessHours_DateTime_Null(){
        Test.startTest();
            DateUtils.getDatetimeWithTimeShiftByBusinessHours(null, testDuration);
        Test.stopTest();

        System.assertEquals(null, DateUtils.getDatetimeWithTimeShiftByBusinessHours(null, testDuration)); 
    }

    @isTest( seeAllData = false ) private static void testGetDatetimeWithTimeShiftByBusinessHours_withDays(){
        setUp(); 
        DateTime TestReturnDateTime =  BusinessHours.add( testBizHours.id, 
                                                       testStartDateTime, 
                                                       5 * ONE_DAY + 0 * ONE_HOUR + 0 * ONE_MINUTE );
        DateTime TestReturnDateTime1 =   BusinessHours.add(  testBizHours.id,
                                              TestReturnDateTime,
                                              -1 * ONE_MINUTE );    
        DateTime testDateTime = null;

        Test.startTest();
            testDateTime = DateUtils.getDatetimeWithTimeShiftByBusinessHours(testStartDateTime, testDurationWithDays);
        Test.stopTest();

        System.assert(testDateTime > testStartDateTime);
    }

    @isTest( seeAllData = false ) private static void testGetDatetimeWithTimeShiftByBusinessHours_WithHours(){
        setUp();
        DateTime TestReturnDateTime =  BusinessHours.add( testBizHours.id, 
                                                          testStartDateTime, 
                                                          0 * ONE_DAY + 5 * ONE_HOUR + 0 * ONE_MINUTE );
        
        DateTime testDateTime = null;

        Test.startTest();
            testDateTime = DateUtils.getDatetimeWithTimeShiftByBusinessHours(testStartDateTime , testDurationWithHours);
        Test.stopTest();

        System.assert(testDateTime > testStartDateTime);
    }

    @isTest( seeAllData = false ) private static void testGetMatchesInCurrentPeriod_WEEKLY(){
        Date testStartWeeklyDate = Date.newInstance(2013, 9, 23);
        Date testEndWeeklyDate = Date.newInstance(2013, 9, 27);     
        Date expDate = Date.newInstance(2013, 9, 25);

        Test.startTest();
            Map<Integer, Date> testMap = DateUtils.getMatchesInCurrentPeriod(testStartWeeklyDate, testEndWeeklyDate, DateUtils.WEEKLY, String.valueOf(testBillingDayQuarter), testBillingDayWeekly);
        Test.stopTest();

        System.assertEquals(1, testMap.size());

        for(Integer item : testMap.KeySet()){
            System.assertEquals(expDate, testMap.get(1));
        }
    }
    
    @isTest( seeAllData = false ) private static void testGetMatchesInCurrentPeriod_MOTHLY(){
        Date testStartWeeklyDate = Date.newInstance(2013, 9, 23);
        Date testEndWeeklyDate = Date.newInstance(2013, 10, 31);    
        Map<Integer, Date> testIntegerToDateMap = new Map<Integer, Date>{1=>Date.newInstance(2013, 9, 30),
                                                                         2=>Date.newInstance(2013, 10, 30)}; 
        Date expDate = Date.newInstance(2013, 10, 30);  

        Test.startTest();
            Map<Integer, Date> testMap = DateUtils.getMatchesInCurrentPeriod(testStartWeeklyDate, testEndWeeklyDate, MONTHLY_FREQUENCY, String.valueOf(testBillingDayQuarter), String.valueOf(testBillingDayMonthly));
        Test.stopTest();

        System.assertEquals(testIntegerToDateMap.size(), testMap.size());

        for(Integer item : testIntegerToDateMap.KeySet()){
            System.assertEquals(testIntegerToDateMap.get(item), testMap.get(item));
        }
    }

    @isTest( seeAllData = false ) private static void testGetMatchesInCurrentPeriod_QUARTERLY(){
        Date testForMethodStartDate = Date.newInstance(1988, 3, 22);
        Date testForMethodEndDate = Date.newInstance(1988, 7, 22);
        Map<Integer, Date> testIntegerToDateMap = new Map<Integer, Date>{1=>Date.newInstance(1988, 03, 30),
                                                                         2=>Date.newInstance(1988, 06, 30)}; 

        Test.startTest();
            Map<Integer, Date> testMap = DateUtils.getMatchesInCurrentPeriod(testForMethodStartDate, testForMethodEndDate, QUARTERLY_FREQUENCY, String.valueOf(testBillingDayQuarter), String.valueOf(testBillingDayMonthly));
        Test.stopTest(); 

        System.assertEquals(testIntegerToDateMap.size(), testMap.size());

        for(Integer item : testIntegerToDateMap.KeySet()){
            System.assertEquals(testIntegerToDateMap.get(item), testMap.get(item));
        }
    }
    
    @isTest( seeAllData = false ) private static void testGetDay(){
        Date testWeekDay = Date.newInstance(2013, 9, 27); //it is Friday

        Test.startTest();
            String friday = DateUtils.getDay(testWeekDay);
        Test.stopTest();

        System.assertEquals('Friday', friday);
    }

    @isTest( seeAllData = false ) private static void testGetWeekStartDate(){
        Date testDate = Date.newInstance(2013, 9, 27); //it is Friday
        Date testfirstDayOfTheWeek = Date.newInstance(2013, 9, 23); //it is Friday; 

        Test.startTest();
            Date testMethodDate = DateUtils.getWeekStartDate(testDate);
        Test.stopTest();

        System.assertEquals(testfirstDayOfTheWeek, testMethodDate);
    }

    @isTest( seeAllData = false ) private static void testFormat(){
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        String testMondayString = '9/23/2013';

        Test.startTest();
            String testStringDate = DateUtils.format(testWeekMondayDay);
        Test.stopTest();

        System.assertEquals(testMondayString, testStringDate);
    }
    
    @isTest( seeAllData = false ) private static void testFormat_Null(){

        Test.startTest();
            String testStringDate = DateUtils.format(null);
        Test.stopTest();

        System.assertEquals('', testStringDate);
    }
    
    @isTest( seeAllData = false ) private static void testFormatDate(){
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        String testMondayString = '2013-09-23'; 

        Test.startTest();
            String testStringDate = DateUtils.formatDate(testWeekMondayDay);
        Test.stopTest();

        System.assertEquals(testMondayString, testStringDate);
    }
    
    @isTest( seeAllData = false ) private static void testFormatDate_Null(){

        Test.startTest();
            String testStringDate = DateUtils.formatDate(null);
        Test.stopTest();

        System.assertEquals('', testStringDate);
    }

    @isTest( seeAllData = false ) private static void testFormatDateShort(){
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        String testMondayString = '9/2013'; 

        Test.startTest();
            String testStringDate = DateUtils.formatDateShort(testWeekMondayDay);
        Test.stopTest();

        System.assertEquals(testMondayString, testStringDate);
    }
    
    @isTest( seeAllData = false ) private static void testFormatDateShort_Null(){

        Test.startTest();
            String testStringDate = DateUtils.formatDateShort(null);
        Test.stopTest();

        System.assertEquals('', testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDateWithShift_Weekly(){
        Integer shift = 1;
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        Date testShiftedDate = Date.newInstance(2013, 9, 30);   //shifted one week

        Test.startTest();
            Date testStringDate = DateUtils.getDateWithShift(testWeekMondayDay, DateUtils.WEEKLY, shift);
        Test.stopTest();

        System.assertEquals(testShiftedDate, testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDateWithShift_Monthly(){
        Integer shift = 1;
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        Date testShiftedDate = Date.newInstance(2013, 10, 23);  //shifted one Month

        Test.startTest();
            Date testStringDate = DateUtils.getDateWithShift(testWeekMondayDay, DateUtils.MONTHLY, shift);
        Test.stopTest();

        System.assertEquals(testShiftedDate, testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDateWithShift_Annually(){//ask how it should be shift
        Integer shift = 3;
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        Date testShiftedDate = Date.newInstance(2016, 9, 23);   //shifted one Year

        Test.startTest();
            Date testStringDate = DateUtils.getDateWithShift(testWeekMondayDay, DateUtils.ANNUALLY, shift);
        Test.stopTest();

        System.assertEquals(testShiftedDate, testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDateWithShift_Quarterly(){
        Integer shift = 1;
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        Date testShiftedDate = Date.newInstance(2013, 12, 23);  //shifted one Quarter

        Test.startTest();
            Date testStringDate = DateUtils.getDateWithShift(testWeekMondayDay, DateUtils.QUARTERLY, shift);
        Test.stopTest();

        System.assertEquals(testShiftedDate, testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDateWithShift_Null(){
        Integer shift = 1;
        Date testWeekMondayDay = Date.newInstance(2013, 9, 23); //it is Monday
        Date testShiftedDate = Date.newInstance(2013, 10, 23);  //shifted one Month

        Test.startTest();
            Date testStringDate = DateUtils.getDateWithShift(testWeekMondayDay, null, shift);
        Test.stopTest();

        System.assertEquals(testShiftedDate, testStringDate);
    }

    @isTest( seeAllData = false ) private static void testGetDayNumber(){
        String wednesdayDay = 'Wednesday';
        Integer wednesdayDayCount = 3; 

        Test.startTest();
            Integer testIntegerDate = DateUtils.getDayNumber(wednesdayDay);
        Test.stopTest();

        System.assertEquals(wednesdayDayCount, testIntegerDate);
    }

    @isTest( seeAllData = false ) private static void testEligibilityDate_Weekly(){
        String thursdayDay = 'Saturday';

        Test.startTest();
            Boolean testBoolean = DateUtils.eligibilityDate(testSetCurrentdate, DateUtils.WEEKLY, thursdayDay);
        Test.stopTest();

        System.assertEquals(true, testBoolean) ;
    }

    @isTest( seeAllData = false ) private static void testEligibilityDate_Monthly(){        
        String testBillingMonthlyDay = '27';
        
        Test.startTest();
            Boolean testBoolean = DateUtils.eligibilityDate(testSetCurrentdate, DateUtils.MONTHLY, testBillingMonthlyDay);
        Test.stopTest();        
        
        System.assertEquals(true, testBoolean) ;
    }
    
    @isTest( seeAllData = false ) private static void testEligibilityDate_QUARTERLY(){      
        String testBillingQuarterlyDay = '1';
        
        Test.startTest();
            Boolean testBoolean = DateUtils.eligibilityDate(testSetCurrentdate, DateUtils.QUARTERLY, testBillingQuarterlyDay);
        Test.stopTest();        
        
        System.assertEquals(false, testBoolean) ;
    }
    
    @isTest( seeAllData = false ) private static void testGetDifferenceBetweanTwoDatetimes_TheSameDay(){
        DateTime testThisMethodStartDate = DateTime.newInstance(2013, 9, 30, 10, 15, 0);
        DateTime testThisMethodEndDate = DateTime.newInstance(2013, 9, 30, 12, 15, 0);
        String experctedResultString = '0d 2h 0m';
        
        Test.startTest();
            String testDateString = DateUtils.getDifferenceBetweanTwoDatetimes(testThisMethodStartDate, testThisMethodEndDate, true);
        Test.stopTest();
        
        System.assertEquals(experctedResultString, testDateString);
    }
    
    @isTest( seeAllData = false ) private static void testGetDifferenceBetweanTwoDatetimes_ShiftForActualDiff_true(){
        setUp();            
        DateTime testThisMethodStartDate = DateTime.newInstance(2013, 9, 29, 10, 15, 0);
        DateTime testThisMethodEndDate = DateTime.newInstance(2013, 9, 30, 12, 15, 0);
        String experctedResultString = '0d 2h 0m';
        
        Test.startTest();
            String testDateString = DateUtils.getDifferenceBetweanTwoDatetimes(testThisMethodStartDate, testThisMethodEndDate, true);
        Test.stopTest();
        
        System.assertEquals(experctedResultString, testDateString);
    }
    
    @isTest( seeAllData = false ) private static void testGetDifferenceBetweanTwoDatetimes_ShiftForActualDiff_false(){
        setUp();            
        DateTime testThisMethodStartDate = DateTime.newInstance(2013, 9, 29, 10, 15, 0);
        DateTime testThisMethodEndDate = DateTime.newInstance(2013, 9, 30, 13, 15, 0);
        String experctedResultString = '0d 3h 0m';
        
        Test.startTest();
            String testDateString = DateUtils.getDifferenceBetweanTwoDatetimes(testThisMethodStartDate, testThisMethodEndDate, false);
        Test.stopTest();
        
      System.assertEquals(experctedResultString, testDateString);
    }
    
    
    @isTest( seeAllData = false ) private static void testGetRemainingWorkingHoursForDay(){
        DateTime testWorkingDay = DateTime.newInstance(2013, 9, 29, 12, 15, 0);
        String expectedFormattedString = '0d 4h 45m';
        
        Test.startTest();
            String remainingTime = DateUtils.getRemainingWorkingHoursForDay(testWorkingDay);
        Test.stopTest();
        
        System.assertEquals(expectedFormattedString, remainingTime);
        
    }
    
    
    @isTest( seeAllData = false ) private static void testGetWorkingHoursForStartDayToCurrent(){ // Method works incorrectly always adds 5 hours
//        User projectmanager = TestingUtils.userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
//        System.runAs(projectmanager){
        DateTime testWorkingDay = DateTime.newInstance(2013, 9, 29, 13, 45, 0);
        String expectedFormattedString = '0d 5h 45m';
        
        Test.startTest();
            String remainingTime = DateUtils.getWorkingHoursForStartDayToCurrent(testWorkingDay);
        Test.stopTest();
        
        System.assertEquals(expectedFormattedString, remainingTime);
//        }
    }
    
    
    
    @isTest( seeAllData = false ) private static void testAppendDurations(){
        String firstDurationString = '0d 0h 15m';
        String secondDurationString = '1d 1h 45m';
        String sumExpectedDuration = '1d 2h 0m';
        
        Test.startTest();
            String appendedDurationString = DateUtils.appendDurations(firstDurationString, secondDurationString);
        Test.stopTest();
        
        System.assertEquals(sumExpectedDuration, appendedDurationString);
    }
    
    
    @isTest( seeAllData = false ) private static void testDiffDurationsHours(){
        DateTime testThisMethodStartDate = DateTime.newInstance(2013, 9, 29, 10, 15, 0);
        DateTime testThisMethodEndDate = DateTime.newInstance(2013, 9, 29, 17, 00, 0);
        String expDiffTime = '0d 6h 45m';
        
        Test.startTest();
            String diffTime = DateUtils.diffDurationsHours(testThisMethodStartDate, testThisMethodEndDate);
        Test.stopTest();
        
        System.assertEquals(expDiffTime, diffTime);
    }

    private static testmethod void testGetDateStartForWeeklyPeriod(){
        Date testStartDateValue = Date.newInstance(2014, 02, 3); //start Date = "03 January 2014"

        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(testStartDateValue, DateUtils.WEEKLY, null);

        Test.stopTest();

        System.assertEquals(testStartDateValue.toStartOfWeek().addDays(1), resultDate);
    }

    private static testmethod void testGetDateStartForWeeklyPeriodWithCurrentDate(){
        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(Date.today(), DateUtils.WEEKLY, null);

        Test.stopTest();

        System.assertEquals(Date.today().toStartOfWeek().addDays(1), resultDate);
    }

    private static testmethod void testGetDateStartForMonthlyPeriod(){
        Date testStartDateValue = Date.newInstance(2014, 08, 5); //start Date = "03 January 2014"

        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(testStartDateValue, DateUtils.MONTHLY, null);

        Test.stopTest();

        System.assertEquals(Date.newInstance(2014, 08, 1), resultDate);
    }

    private static testmethod void testGetDateStartForMonthlyPeriodWithCurrentDate(){
        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(Date.today(), DateUtils.MONTHLY, null);

        Test.stopTest();

        System.assertEquals( Date.newInstance(Date.today().year(), Date.today().month(), 1), resultDate);
    }

    private static testmethod void testGetDateStartForQuarterlyPeriod(){
        Date testStartDateValue = Date.newInstance(2014, 08, 5); //start Date = "03 January 2014"

        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(testStartDateValue, DateUtils.QUARTERLY, 1);

        Test.stopTest();

        System.assertEquals(Date.newInstance(2014, 07, 1), resultDate);
    }

    private static testmethod void testGetDateStartForQuarterlyPeriodWithCurrentDateWeekly(){
        Date resultDate;

        Test.startTest();

            resultDate = DateUtils.getDateStart(Date.today(), DateUtils.QUARTERLY, 1);

        Test.stopTest();

        System.assertEquals( Date.newInstance( Date.today().year(), ((Date.today().month() - 1)/3) * 3 + 1, 1), resultDate);
    }

    private static testmethod void testGetDateWithPeriodAndStartDayWeeklyPeriod(){
        Date testDateValue;
        Date resultDate;
        String testWeekNameValue;
        Integer dateOfWeekShiftValue;//availeble for testing values [0..6]

        Test.startTest();

            // test current date with current StartDay week value
            dateOfWeekShiftValue = 0;
            testDateValue = Date.today();
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays(dateOfWeekShiftValue), resultDate);

            // test current date with next StartDay week value
            dateOfWeekShiftValue = 3;
            testDateValue = Date.today();
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays( -7 + dateOfWeekShiftValue), resultDate);

            // test current date with previous StartDay week value
            dateOfWeekShiftValue = -2;
            testDateValue = Date.today();
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays(dateOfWeekShiftValue), resultDate);

            // test fixed date with current StartDay week value
            dateOfWeekShiftValue = 0;
            testDateValue = Date.newInstance(2012, 7, 19);
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays(dateOfWeekShiftValue), resultDate);

            // test fixed date with next StartDay week value
            dateOfWeekShiftValue = 3;
            testDateValue = Date.newInstance(2013, 5, 21);
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays( -7 + dateOfWeekShiftValue), resultDate);

            // test fixed date with previous StartDay week value
            dateOfWeekShiftValue = -2;
            testDateValue = Date.newInstance(2013, 11, 14);
            testWeekNameValue = DateTime.newInstance( testDateValue.addDays(dateOfWeekShiftValue), Time.newInstance(0, 0, 0, 0) ).format('EEEE');
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.WEEKLY, testWeekNameValue, null);
            System.assertEquals (testDateValue.addDays(dateOfWeekShiftValue), resultDate);

        Test.stopTest();
    }

    private static testmethod void testGetDateWithPeriodAndStartDayMonthlyPeriod(){
        Date testDateValue;
        Date resultDate;
        String testMonthDayValue;
        Integer dateOfMonthShiftValue;

        Test.startTest();

            //test current date with cuurent StartDay month
            dateOfMonthShiftValue = 0;
            testDateValue = Date.today();
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

            //test current date with next StartDay month
            dateOfMonthShiftValue = 5;
            testDateValue = Date.today();
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue.addDays(dateOfMonthShiftValue), DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

            //test current date with previous StartDay month
            dateOfMonthShiftValue = -5;
            testDateValue = Date.today();
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue.addMonths(1).addDays(dateOfMonthShiftValue).addDays(dateOfMonthShiftValue), DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

            //test fixed date with cuurent StartDay month
            dateOfMonthShiftValue = 0;
            testDateValue = Date.newInstance(2012, 7, 19);
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue, DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

            //test fixed date with next StartDay month
            dateOfMonthShiftValue = 5;
            testDateValue = Date.newInstance(2013, 5, 21);
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue.addDays(dateOfMonthShiftValue), DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

            //test fixed date with previous StartDay month
            dateOfMonthShiftValue = -5;
            testDateValue = Date.newInstance(2013, 11, 14);
            testMonthDayValue = String.valueOf(testDateValue.day());
            resultDate = DateUtils.getDateWithPeriodAndStartDay(testDateValue.addMonths(1).addDays(dateOfMonthShiftValue), DateUtils.MONTHLY, testMonthDayValue, null);
            System.assertEquals (testDateValue, resultDate);

        Test.stopTest();
    }

    private static testmethod void testGetDateWithPeriodAndStartDayQuarterlyPeriod(){
        Date resultDate;

        Test.startTest();

            //test fixed date with previous StartDay month, the first month
            resultDate = DateUtils.getDateWithPeriodAndStartDay(Date.newInstance(2010, 2, 18), DateUtils.QUARTERLY, '18', null);
            System.assertEquals (Date.newInstance(2010, 1, 18), resultDate);

            //test fixed date with next StartDay month, the first month
            resultDate = DateUtils.getDateWithPeriodAndStartDay(Date.newInstance(2010, 2, 18), DateUtils.QUARTERLY, '20', null);
            System.assertEquals (Date.newInstance(2010, 1, 20), resultDate);

            //test fixed date with previous StartDay month, the first month
            resultDate = DateUtils.getDateWithPeriodAndStartDay(Date.newInstance(2010, 2, 18), DateUtils.QUARTERLY, '15', null);
            System.assertEquals (Date.newInstance(2010, 1, 15), resultDate);

        Test.stopTest();
    }
}