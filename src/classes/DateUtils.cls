public with sharing class DateUtils {
    public static final String DATETIME_USER_FRIENDLY_FORMAT = 'EEE MMM dd HH:mm a yyyy';

    public final static String MONTHLY = 'Monthly';
    public final static String WEEKLY = 'Weekly';
    public final static String QUARTERLY = 'Quarterly';
    public final static String YEARLY = 'Yearly';
    public final static String ANNUALLY = 'Annually';
    public final static String ONE_TIME_FEE = 'One Time Fee';
    final static Integer MONTHS_IN_QUARTER = 3;
    final static Integer DAYS_IN_WEEK = 7;

    public final static Integer START_WORKING_DAY_HOUR = 9;
    public final static Integer HOURS_IN_DAY = 12;

    public final static Long ONE_MINUTE = 60 * 1000L;
    public final static Long ONE_HOUR = 60 * ONE_MINUTE;
    public final static Long ONE_DAY = 9 * ONE_HOUR;

	public final static Map<Integer, Integer> MONTH_NUMBER_IN_QUARTER = new Map<Integer, Integer> { //MRS 7456
																						1 => 1, 2 => 2, 3 => 3,
																						4 => 1, 5 => 2, 6 => 3,
																						7 => 1, 8 => 2, 9 => 3,
																					10 => 1, 11 => 2, 12 => 3};

    public final static Map<String, Integer> WEEK_DAY_NUMBER_MAP = new Map<String, Integer>{ 'Monday' => 1,
                                                                                             'Tuesday' => 2,
                                                                                             'Wednesday' => 3,
                                                                                             'Thursday' => 4,
                                                                                             'Friday' => 5,
                                                                                             'Saturday' => 6,
                                                                                             'Sunday' => 7 };

    public static Id MILROSE_BUSINESS_HOURS_ID {
        get{
            if ( MILROSE_BUSINESS_HOURS_ID == null ) {
                 MILROSE_BUSINESS_HOURS_ID = [ SELECT Id FROM BusinessHours WHERE IsDefault = true limit 1 ].Id;
            }
            return MILROSE_BUSINESS_HOURS_ID;
        }
    }

    public static Datetime getDatetimeWithTimeShiftByBusinessHours ( Datetime startDatetime, String duration ) {
        return getDatetimeWithTimeShiftByBusinessHours( startDatetime, duration, true );
    }

    public static Datetime getDatetimeWithTimeShiftByBusinessHours ( Datetime startDatetime, String duration, Boolean addTime ) {
        if( addTime == null ) addTime = true;
        Integer direction = addTime ? 1 : -1;
        if( startDatetime == null ) return null;
        Datetime datetimeForReturn = startDatetime;
        Integer days = 0, hours = 0, minutes = 0, dayHours = 0;
        if ( duration != null ) {
            List<String> daysAndHours = duration.split(' ',1000);
            for( String dayHourUnit : daysAndHours ) {
                if( dayHourUnit.containsIgnoreCase('d') ) {
                    days =  Integer.valueof( dayHourUnit.substringBefore('d').substringBefore('D') );
                }
                if( dayHourUnit.containsIgnoreCase('h') ) {
                    hours = Integer.valueof( dayHourUnit.substringBefore('h').substringBefore('H') );
                }
                if( dayHourUnit.containsIgnoreCase('m') ) {
                    minutes = Integer.valueof( dayHourUnit.substringBefore('m').substringBefore('M') );
                }
            }
            datetimeForReturn = BusinessHours.add( MILROSE_BUSINESS_HOURS_ID,
                                                   datetimeForReturn,
                                                   direction * ( days * ONE_DAY + hours * ONE_HOUR + ( minutes + 1 ) * ONE_MINUTE ) );
        } else {
            datetimeForReturn = BusinessHours.add( MILROSE_BUSINESS_HOURS_ID,
                                                   datetimeForReturn,
                                                   direction * ( 1 * ONE_MINUTE ) );
        }

        datetimeForReturn = BusinessHours.add( MILROSE_BUSINESS_HOURS_ID,
                                               datetimeForReturn,
                                               direction * ( -1 * ONE_MINUTE ) );
        return datetimeForReturn;
    }

    public static Map<Integer, Date> getMatchesInCurrentPeriod ( Date startDate, Date endDate, String frequency, String quarterlyMonth, String billingDay ){
        Map<Integer, Date> integerToDateMap = new Map<Integer, Date>();

        if (null != startDate && null != endDate && startDate == endDate) {
            Date d = Date.newInstance(startDate.year(), startDate.month(), startDate.day());
            integerToDateMap.put(1, d);
            return integerToDateMap;

        }

        if (startDate != null && endDate != null && !String.isEmpty(frequency) && !String.isEmpty(billingDay) && startDate < endDate) {
            if (frequency == WEEKLY){
                integerToDateMap = getDateMapWeekly(startDate, endDate, billingDay);

            }

            if (frequency == MONTHLY){
                integerToDateMap = getDateMapMonthly(startDate, endDate, Integer.valueOf(billingDay));

            }

            if (frequency == QUARTERLY && !String.isEmpty(quarterlyMonth)){
                integerToDateMap = getDateMapQuarterly(startDate, endDate, Integer.valueOf(quarterlyMonth.left(1)), Integer.valueOf(billingDay));

            }

        }

        return integerToDateMap;
    }

    private static Map<Integer, Date> getDateMapMonthly(Date startDate, Date endDate, Integer billingDay){
        Map<Integer, Date> resMap = new Map<Integer, Date>();
        integer i = 1;
        Date d = startDate.day() > billingDay ?
            Date.newInstance
                (startDate.year(),
                 startDate.month() + 1,
                 billingDay > date.daysInMonth (startDate.year(), startDate.month() + 1) ? date.daysInMonth(startDate.year(), startDate.month() + 1) : billingDay )
                 : Date.newInstance(startDate.year(), startDate.month(),
                 billingDay > date.daysInMonth (startDate.year(), startDate.month()) ? date.daysInMonth(startDate.year(), startDate.month()) : billingDay);
        While ( d <= endDate ){
            resMap.put(i, d);
            d = Date.newInstance(d.year(), d.month() + 1, billingDay > date.daysInMonth (d.year(), d.month() + 1) ? date.daysInMonth (d.year(), d.month() + 1) : billingDay);
            i++;
        }
        return resMap;
    }

    private static Map<Integer, Date> getDateMapQuarterly(Date startDate, Date endDate, Integer monthNumber, Integer billingDay){
        Map<Integer, Date> resMap = new Map<Integer, Date>();
        Integer i = 1;
        Integer currentStartDateQuarter = ((startDate.month() - 1) / MONTHS_IN_QUARTER) * MONTHS_IN_QUARTER + monthNumber;
system.debug('!!! currentStartDateQuarter = ' + currentStartDateQuarter);
        Date d = Date.newInstance(startDate.year(), currentStartDateQuarter, billingDay >= date.daysInMonth(startDate.year(), currentStartDateQuarter) ? date.daysInMonth(startDate.year(), currentStartDateQuarter) : billingDay);
        system.debug('!!! d = ' + d);
	d = d >= startDate ? d : Date.newInstance(d.year(), currentStartDateQuarter + MONTHS_IN_QUARTER, billingDay >= date.daysInMonth(d.year(), currentStartDateQuarter + MONTHS_IN_QUARTER) ? date.daysInMonth(d.year(), currentStartDateQuarter + MONTHS_IN_QUARTER) : billingDay);
        system.debug('!!! d = ' + d);
	While ( d <= endDate ){system.debug('!!! d = ' + d);
            resMap.put(i, d);
            d = Date.newInstance(d.year(), d.month() + MONTHS_IN_QUARTER, billingDay >= date.daysInMonth (d.year(), d.month() + MONTHS_IN_QUARTER) ? date.daysInMonth (d.year(), d.month() + MONTHS_IN_QUARTER) : billingDay);
            system.debug('!!! d = ' + d);
	    i++;
        }
        return resMap;
    }

    private static Map<Integer, Date> getDateMapWeekly(Date startDate, Date endDate, String billingDay){
        Map<Integer, Date> resMap = new Map<Integer, Date>();
        integer i = 1;
        Date d = startDate;
        While ( (DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEE') != billingDay) && (d <= endDate)){
            d = d.addDays(1);
        }
        While ( (DateTime.newInstance(d.year(), d.month(), d.day()).format('EEEE') == billingDay) && (d <= endDate) ){
            resMap.put(i, d);
            d = d.addDays(DAYS_IN_WEEK);
            i++;
        }
        return resMap;
    }

    /* Given a date, returns the day of week */
    public static String getDay(Date d){
        Datetime dt = DateTime.newInstance( d, Time.newInstance(0, 0, 0, 0) );
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek;
    }

    /* Given a date, returns the beginning date of that week (Monday) */
    public static Date getWeekStartDate(Date d){
        return d.toStartOfWeek().addDays(1);
    }

    public static Date getDateWithPeriodAndStartDay( Date d, String period, String startDay, String quarterMonth ) {
        if( period == null ) return Date.today();
        Date startDate;

        if ( period == WEEKLY ) {
            startDate = getDateStart( d, period, 0 );
            startDate = startDate.addDays( WEEK_DAY_NUMBER_MAP.get( startDay ) - 1 );
            if( startDate > d ) startDate = startDate.addDays(-7);
        } else if ( period == MONTHLY ) {
            Integer maxDays = ( Date.daysInMonth(d.year(), d.month()) < Integer.valueOf( startDay ) ? Date.daysInMonth(d.year(), d.month()) : Integer.valueOf( startDay ) );
            startDate = Date.newInstance( d.year(), d.month(), maxDays );
            if( startDate > d ) {
                Integer maxDaysPrevMonth = ( Date.daysInMonth(d.year(), d.month()-1) < Integer.valueOf( startDay ) ? Date.daysInMonth(d.year(), d.month()-1) : Integer.valueOf( startDay ) );
                startDate = Date.newInstance( startDate.year(), startDate.month()-1, maxDaysPrevMonth );
            }
        } else if ( period == QUARTERLY ) {
            Integer monthInQuarted = 0;
            if( quarterMonth == null ) quarterMonth = '1st';
            if( quarterMonth.equals( '1st' ) ) monthInQuarted = 1;
            else if( quarterMonth.equals( '2nd' ) ) monthInQuarted = 2;
            else if( quarterMonth.equals( '3rd' ) ) monthInQuarted = 3;

            startDate = getDateStart( d, period, monthInQuarted );
            Integer maxDays = ( Date.daysInMonth(startDate.year(), startDate.month()) < Integer.valueOf( startDay ) ? Date.daysInMonth(startDate.year(), startDate.month()) : Integer.valueOf( startDay ) );
            startDate = Date.newInstance( startDate.year(), startDate.month(), maxDays );
            if( startDate > d ) {
                Integer maxDaysPrevMonth = ( Date.daysInMonth(startDate.year(), startDate.month() - MONTHS_IN_QUARTER ) < Integer.valueOf( startDay )
                                                            ? Date.daysInMonth(startDate.year(), startDate.month() - MONTHS_IN_QUARTER )
                                                            : Integer.valueOf( startDay ) );
                startDate = Date.newInstance( startDate.year(), startDate.month() - MONTHS_IN_QUARTER, maxDaysPrevMonth );
            }
        }
        return startDate;
    }

    /* Returns the start date of a given period */
    public static Date getDateStart(Date d, String period, Integer monthInQuarted ){
        Date startDate = null;
        period = (period == null || period == '') ? MONTHLY: period;
        if (period == WEEKLY) {
            startDate = getWeekStartDate(d);
        } else if (period == MONTHLY) {
            // yr, month, day
            startDate = Date.newInstance(d.year(), d.month(), 1);
        } else if (period == ANNUALLY) {
            // yr, month, day
            startDate = Date.newInstance(d.year(), 1, 1);
        } else if (period == QUARTERLY) {
            // Values [0,1,2,3]
            Integer quarter = ((d.month() - 1)/ MONTHS_IN_QUARTER);
            // yr, month, day
            //startDate = Date.newInstance(d.year(), 1 + (quarter * MONTHS_IN_QUARTER), 1);
            startDate = Date.newInstance(d.year(), ( quarter * MONTHS_IN_QUARTER ) + monthInQuarted, 1);
        } else if (period == ONE_TIME_FEE) {
            startDate = d;
        }

        return startDate;
    }

    /* Returns the end date of a given period */
    public static Date getDateEnd(Date d, String period){
        Date endDate = null;

        period = (period == null)? MONTHLY: period;
        if (period == WEEKLY){
            endDate = getWeekStartDate(d).addDays(6);
        }else if (period == MONTHLY){
            // yr, month, day
            endDate = Date.newInstance(d.year(), d.month(), Date.daysInMonth(d.year(), d.month()));
        }else if (period == ANNUALLY){
            // yr, month, day
            endDate = Date.newInstance(d.year(), 12, Date.daysInMonth(d.year(), d.month()));
        }else if (period == QUARTERLY){
            // Values [0,1,2,3]
            Integer quarter = ((d.month() - 1)/ MONTHS_IN_QUARTER);
            Integer month = ((quarter + 1) * MONTHS_IN_QUARTER);
            // yr, month, day
            endDate = Date.newInstance(d.year(), month, Date.daysInMonth(d.year(), month));
        }else if (period == ONE_TIME_FEE){
            endDate = d;
        }

        return endDate;
    }

    /* Formatting Date methods */
    public static String format(Date d){
        if (d == null) return '';
        return String.valueOf(d.month()) + '/' + String.valueOf(d.day()) + '/' + String.valueOf(d.year());
    }

    public static String formatDate(Date d){
        if (d == null) return '';
        DateTime dt = Datetime.NewInstance(d.year(), d.month(), d.day(), 0, 0, 0);
        String val = dt.format('yyyy-MM-dd');
        return val;
    }

    public static String formatDateShort(Date d){
        if (d == null) return '';
        DateTime dt = Datetime.NewInstance(d.year(), d.month(), d.day(), 0, 0, 0);
        String val = dt.Month() + '/' + dt.year();
        return val;
    }

    public static Date getDateWithShift(Date d, String period, Integer shift){
        period = (period == null) ? MONTHLY : period;
        if (period == WEEKLY){
            d = d.addDays(DAYS_IN_WEEK*shift);
        }else if (period == MONTHLY){
            d = d.addMonths(shift);
        }else if (period == ANNUALLY){
            d = d.addYears(shift);
        }else if (period == QUARTERLY){
            d = d.addMonths(shift * MONTHS_IN_QUARTER);
        }
        return d;
    }

     /**
     *
     *
     */
    public static Integer getDayNumber(String dayOfWeek) {
        Map<String, Integer> stringToIntegerMap = new Map<String, Integer>();
        stringToIntegerMap.put('Monday', 1);
        stringToIntegerMap.put('Tuesday', 2);
        stringToIntegerMap.put('Wednesday', 3);
        stringToIntegerMap.put('Thursday', 4);
        stringToIntegerMap.put('Friday', 5);
        stringToIntegerMap.put('Saturday', 6);
        stringToIntegerMap.put('Sunday', 7);
        return stringToIntegerMap.get(dayOfWeek);
    }

    /**
     *
     *
     */
    public static Boolean eligibilityDate(Date currentDate, String frequency, String billingDay) {

        system.debug('Current date: ' + currentDate);
        system.debug('Frequency: ' + frequency);
        system.debug('Billing shift: ' + billingDay);

        integer x;
        boolean c = false;
        if (frequency == WEEKLY) {

            x = currentDate.toStartOfWeek().daysBetween(currentDate);
            c = x == (DateUtils.getDayNumber(billingDay) - 1);

        } else if (frequency == MONTHLY) {

            x = currentDate.toStartOfMonth().daysBetween(currentDate);
            c = x == (Integer.valueOf(billingDay) - 1);

        } else if (frequency == QUARTERLY) {

            x = currentDate.month() - (integer)(currentDate.month() / MONTHS_IN_QUARTER) * MONTHS_IN_QUARTER;
            c = x == Integer.valueOf(billingDay);
        }
        system.debug('Passed date: ' + c);

        return c;
    }

    public static String getDifferenceBetweanTwoDatetimes( BusinessHours bh, Datetime startDatetime, Datetime endDatetime, Boolean shiftForActualDiff ) {
        return null;
    }

    public static String getDifferenceBetweanTwoDatetimes( Datetime startDatetime, Datetime endDatetime, Boolean shiftForActualDiff ) {
        if( startDatetime == null || endDatetime == null ) return null;
        String remainingDayHours;
        if( shiftForActualDiff ) {
            String firstDayWorkingTime, lastDayWorkingTime;
            if( startDatetime < endDatetime ) {
                firstDayWorkingTime = getWorkingHoursForStartDayToCurrent( endDatetime );
                lastDayWorkingTime = getRemainingWorkingHoursForDay( startDatetime );
            } else {
                firstDayWorkingTime = getWorkingHoursForStartDayToCurrent( startDatetime );
                lastDayWorkingTime = getRemainingWorkingHoursForDay( endDatetime );
            }
            remainingDayHours = appendDurations( firstDayWorkingTime, lastDayWorkingTime );
        } else {
            String firstDayWorkingTime = getRemainingWorkingHoursForDay( startDatetime );
            String lastDayWorkingTime = getWorkingHoursForStartDayToCurrent( endDatetime );
            remainingDayHours = appendDurations( firstDayWorkingTime, lastDayWorkingTime );
        }
        Long diff = BusinessHours.diff( MILROSE_BUSINESS_HOURS_ID, startDatetime, endDatetime );
        Long realDays = diff /ONE_HOUR / START_WORKING_DAY_HOUR;
        if ( remainingDayHours.startsWith('1') ) realDays -= 1;
        if ( remainingDayHours.startsWith('2') ) realDays -= 2;
        String workingDays = realDays + 'd 0h 0m';
        remainingDayHours = appendDurations( remainingDayHours, workingDays );
        return remainingDayHours;
    }

    public static String getRemainingWorkingHoursForDay( Datetime workingDay ) {
        Datetime endWorkingTime = Datetime.newInstance( workingDay.year(),
                                                        workingDay.month(),
                                                        workingDay.day(),
                                                        17, 0, 0 );
        Decimal diffHoursInStrtDate = ( ( endWorkingTime.getTime() ) / ONE_MINUTE ) - ( ( workingDay.addSeconds( - workingDay.second() ).getTime() ) / ONE_MINUTE );
        if( diffHoursInStrtDate < 0 ) return getFormattedDuration(0, 0, 0);

        Integer workingHours = diffHoursInStrtDate.divide( 60.0, 1 ).abs().intValue();
        if( diffHoursInStrtDate < 0 ) workingHours *= -1;
        Decimal workingMinutes = diffHoursInStrtDate - workingHours * 60;
        if (workingHours >= START_WORKING_DAY_HOUR) return getFormattedDuration(1, 0, 0);
        return getFormattedDuration(0, workingHours, workingMinutes);
    }

    public static String getWorkingHoursForStartDayToCurrent( Datetime workingDay ) {
        Datetime startWorkingTime = Datetime.newInstance( workingDay.year(),
                                                          workingDay.month(),
                                                          workingDay.day(),
                                                          8, 0, 0 );
        Decimal diffHoursInDate = ( ( ( workingDay.addSeconds( - workingDay.second() ).getTime() ) / ONE_MINUTE ) - ( startWorkingTime.getTime() ) / ONE_MINUTE );
        if( diffHoursInDate < 0 ) return getFormattedDuration(0, 0, 0);
        Integer workingHours = diffHoursInDate.divide( 60.0, 1 ).abs().intValue();
        if( diffHoursInDate < 0 ) workingHours *= -1;
        Decimal workingMinutes = diffHoursInDate - workingHours * 60;
        if (workingHours >= START_WORKING_DAY_HOUR) return getFormattedDuration(1, 0, 0);
        return getFormattedDuration(0, workingHours, workingMinutes);
    }

    public static String appendDurations( String firstDuration, String secondDuration ) {
        if( firstDuration == null ) return secondDuration;
        if( secondDuration == null ) return firstDuration;
        Integer iD = 0;
        Decimal iH = 0;
        Decimal iM = 0;
        for (String st : (firstDuration + ' ' + secondDuration).split(' ')) {
            if (st.containsIgnoreCase('d')){
                iD += Integer.valueOf(st.removeEndIgnoreCase('d'));
            }
            if (st.containsIgnoreCase('h')){
                iH += Decimal.valueOf(st.removeEndIgnoreCase('h'));
            }
            if (st.containsIgnoreCase('m')){
                iM += Decimal.valueOf(st.removeEndIgnoreCase('m'));
            }
        }
        if( iM < 0 ) {
            iH--;
            iM += 60;
        } else if( iM >= 60 ) {
            iH ++;
            iM -= 60;
        }
        if( iH < 0 ) {
            iD--;
            iH += 9;
        }
        if( iH >= 9 ) {
            Integer fullDaysCount = Integer.valueOf(iH) / 9;
            iD += fullDaysCount;
            iH = iH - fullDaysCount * 9;
        }
        return getFormattedDuration(iD, iH, iM);
    }

    public static String diffDurationsHours( Datetime startDatetime, Datetime endDatetime ) {
        Decimal diffMinutes = ( endDatetime.hour() * 60 + endDatetime.minute() ) - ( startDatetime.hour() * 60 + startDatetime.minute() );
        Integer diffHours = diffMinutes.divide( 60.0, 3 ).abs().intValue();
        diffMinutes -= diffHours*60;
        return getFormattedDuration(0, diffHours, diffMinutes);
    }

    private static String getFormattedDuration( Decimal days, Decimal hours, Decimal minutes ) {
        return days + 'd ' + hours + 'h ' + minutes + 'm';
    }

    public static final map<String, Integer> countSecondsDayHoursMinute = new map<String, Integer>{'day' => 86400, 'hour' => 3600, 'minute' => 60};

    public static Integer getSecond(String duration) {
        Integer second = 0;
        List<String> daysAndHours = duration.split(' ',1000);
        for( String dayHourUnit : daysAndHours ) {
            if( dayHourUnit.containsIgnoreCase('d') ) {
                second += Integer.valueof( dayHourUnit.substringBefore('d')) * countSecondsDayHoursMinute.get('day');
            }
            if( dayHourUnit.containsIgnoreCase('h') ) {
                second += Integer.valueof( dayHourUnit.substringBefore('h') ) * countSecondsDayHoursMinute.get('hour');
            }
            if( dayHourUnit.containsIgnoreCase('m') ) {
                second += Integer.valueof( dayHourUnit.substringBefore('m') ) * countSecondsDayHoursMinute.get('minute');
            }
        }
        return second;
    }

    public static Integer getMinute(String duration) {
        Integer minute = 0;
        for( String stringItem : duration.split(' ',1000) ) {
            if( stringItem.containsIgnoreCase('d') ) {
                minute += Integer.valueof( stringItem.removeEndIgnoreCase('d')) * 8 * 60;
            }
            if( stringItem.containsIgnoreCase('h') ) {
                minute += Integer.valueof( stringItem.removeEndIgnoreCase('h') ) * 60;
            }
            if( stringItem.containsIgnoreCase('m') ) {
                minute += Integer.valueof( stringItem.removeEndIgnoreCase('m') );
            }
        }
        return minute;
    }

    public static Decimal getGMTDateShiftInHours() {
        String strOffset = System.now().format('Z');
        String strOffsetHours = strOffset.substring(0,3);
        if( strOffsetHours.startsWith('+') ) strOffsetHours = strOffsetHours.substring(1);
        Decimal hoursOffset = Decimal.valueOf( strOffsetHours + '.' + ( 100 * Integer.valueOf( strOffset.substring(3) ) / 60 ) );
        return hoursOffset;
    }

    public static Integer getGMTDateShiftInMinutes() {
        return Integer.valueOf( getGMTDateShiftInHours() * 60 );
    }
    
    public static Integer getQuarterNumber( Date dayOfYear ) { //MRS 7456
		return MONTH_NUMBER_IN_QUARTER.get(dayOfYear.toStartOfMonth().month());
	}

}