public without sharing class BillingDateServices {
    private final static String NOT_CORRECT_BILLING_END_DATE = 'Please select the correct Billing End Date so at least one billing date could be created where the sum of percentage amounts to 100%.';

    private static Decimal billedPercentage     = 0;
    private static Integer numberBilledInterval = 0;
    private static Integer numberInterval       = 0;

    private static Map<Integer, Date> countSteps                = new Map<Integer, Date>();
    private static List<Billing_Date__c> billingDatesForDisplay = new List<Billing_Date__c>();

    public static Boolean isChangedNumberInterval = false;

    public static Boolean checkTotalsPercentage(List<BillingDateWrapper> billingDateWrapperList) {
        Decimal countPercentage = 0;

        for (BillingDateWrapper billingDate : billingDateWrapperList) {
            if (null != billingDate.bd.Percentage__c) {
                countPercentage += billingDate.bd.Percentage__c;

            }

        }

        if (100 == countPercentage) {
            return true;

        } else {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Total does not equal 100 percent.') );

        }
        return false;

    }

    public static void createBillingDateForProjects( Map<Id, Project_Profile__c> projects ){
        List<Billing_Date__c> billingDates = new List<Billing_Date__c>();
        Id mediatorId;


    	Map<Id, Decimal> idProjectToBilledAmount = new Map<Id, Decimal>();

    	for(AggregateResult aggResults: [SELECT Project_Profile__c proj, SUM(Amount_Billed__c) am
                                         FROM Billing_Line_Item__c
                                         WHERE isReimbursable__c = false AND
                                            Service_Item__r.Is_Amendmend_Deleted__c = false AND
                                            Project_Profile__c != null AND
                                            Project_Profile__c IN: projects.keySet()
                                         GROUP BY Project_Profile__c]){

            idProjectToBilledAmount.put( (Id)aggResults.get('proj'), ( (Decimal)aggResults.get('am') != null ) ? (Decimal)aggResults.get('am') : 0 );
        }

        for (Project_Profile__c project : projects.values()) {
            if( project.Discounted_Total_Service_Amount__c - (idProjectToBilledAmount.containsKey(project.Id) ? idProjectToBilledAmount.get(project.Id) : 0) > 0 ){
	                mediatorId           = project.Id;
	                billedPercentage     = 0;
	                numberBilledInterval = 0;
	                numberInterval       = 0;

	                countSteps.clear();
	                billingDatesForDisplay.clear();

	                billingDates.addall(createBillingDateList(project));
            }

        }

        try {
            upsert billingDates;

        } catch(Exception ex) {
            throw new ErrorException(ex.getMessage());

        }

    }

    private static List<Billing_Date__c> createBillingDateList(Project_Profile__c project) {
        if (null == project.Project_Start_Date__c || null == project.Billing_End_Date__c) {
            return new List<Billing_Date__c>();

        }

        if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE)) {
            return createBillingDateForPercentage(project);

        } else if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT)) {
            return createBillingDateForInstallment(project);

        }
        return new List<Billing_Date__c>();

    }

    private static List<Billing_Date__c> createBillingDateForPercentage(Project_Profile__c project) {
        List<Billing_Date__c> billingDates = new List<Billing_Date__c>();

        Date startDate = filterBillingDate( project );
        Date endDate   = endBillingDate( startDate, project );

        project.Billing_End_Date__c = endDate;

        system.debug('!!! startDate = ' + startDate + ' endDate = ' + endDate);
        countSteps = DateUtils.getMatchesInCurrentPeriod(startDate, project.Billing_End_Date__c, project.Frequency__c, project.Quarterly_Month__c, project.Billing_day__c);
		system.debug('!!! countSteps = ' + countSteps);
        if (countSteps.isEmpty()) {
        	if(project.Billing_End_Date__c != null) { //MRS 7539
            	countSteps = DateUtils.getMatchesInCurrentPeriod(startDate, project.Billing_End_Date__c.addMonths(3), project.Frequency__c, project.Quarterly_Month__c, project.Billing_day__c);
				billingDates.add( new Billing_Date__c(Processing_Day__c = countSteps.get(1), Step_Number__c = 1, Project_Profile__c = project.Id, Percentage__c = 0) );
				project.Billing_End_Date__c = countSteps.get(1);
            }
			return billingDates;
        }

        numberInterval = countSteps.size() + numberBilledInterval;
		system.debug('!!! numberInterval = ' + numberInterval);
        for (Integer i = 1; i < countSteps.size(); i++) {
            billingDates.add( new Billing_Date__c(Processing_Day__c = countSteps.get(i), Step_Number__c = (i + numberBilledInterval), Project_Profile__c = project.Id, Percentage__c = 0) );
        }

        billingDates.add( new Billing_Date__c(Processing_Day__c = countSteps.get(countSteps.size()), Step_Number__c = numberInterval, Project_Profile__c = project.Id, Percentage__c = 0) );
		system.debug('!!! billingDates = ' + billingDates);
        return billingDates;

    }

    private static List<Billing_Date__c> createBillingDateForInstallment(Project_Profile__c project) {
        List<Billing_Date__c> billingDates = new List<Billing_Date__c>();

        Date startDate = filterBillingDate( project );
        Date endDate   = endBillingDate( startDate, project );

        project.Billing_End_Date__c = endDate;
        system.debug('!!! startDate = ' + startDate + ' endDate = ' + endDate);

        if (null != startDate && null != endDate && startDate == date.today() && endDate == date.today()) {
            throw new ErrorException(NOT_CORRECT_BILLING_END_DATE);
        }

        countSteps = DateUtils.getMatchesInCurrentPeriod(startDate, endDate, project.Frequency__c, project.Quarterly_Month__c, project.Billing_day__c);

        if (countSteps.isEmpty() && billedPercentage < 100.00) {
            throw new ErrorException(NOT_CORRECT_BILLING_END_DATE);
        }

        numberInterval = countSteps.size() + numberBilledInterval;

        Decimal notBilledPercentage = (1.00 - billedPercentage / 100);
        Decimal percentege          = (notBilledPercentage / (Decimal)countSteps.size()) * 100;

        for (Integer i = 1; i < countSteps.size(); i++) {
            billingDates.add( new Billing_Date__c(Processing_Day__c = countSteps.get(i), Step_Number__c = (i + numberBilledInterval), Project_Profile__c = project.Id, Percentage__c = percentege) );
        }
        billingDates.add( new Billing_Date__c(Processing_Day__c = countSteps.get(countSteps.size()), Step_Number__c = numberInterval, Project_Profile__c = project.Id,
                                              Percentage__c = (100 - billedPercentage - percentege * (countSteps.size() - 1))));

        return billingDates;

    }

    private static Date endBillingDate(Date startDate, Project_Profile__c project) {
        //MRS-7506
        if ( project.Billing_End_Date__c == null ){
            return null;
        }
        if ( project.Frequency__c == ProjectProfileServices.FREQUENCY_WEEKLY ) {
            Date billingEndDate = project.Billing_End_Date__c;
            Map<Integer, Date> dates = DateUtils.getMatchesInCurrentPeriod(startDate, billingEndDate, project.Frequency__c, project.Quarterly_Month__c, project.Billing_day__c);

            if (dates.get(dates.size()) > billingEndDate) {
                billingEndDate = dates.get(dates.size());
			}
            return billingEndDate;

        } else if ( project.Frequency__c == ProjectProfileServices.FREQUENCY_MONTHLY && project.Billing_End_Date__c.day() < Integer.valueOf(project.Billing_day__c)) {
            return date.newinstance(project.Billing_End_Date__c.year(), project.Billing_End_Date__c.month(), Integer.valueOf(project.Billing_day__c));

        } else if ( project.Frequency__c == ProjectProfileServices.FREQUENCY_QUARTERLY ) {
            return project.Billing_End_Date__c;

        } else {
            return project.Billing_End_Date__c;
        }
    }

    private static Date filterBillingDate(Project_Profile__c project) {
        List<Billing_Date__c> billingDateToRemove = new List<Billing_Date__c>();
        List<Billing_Date__c> billingDates        = BillingDateServices.getBillingDatesByProjectId(project.Id);

        if (billingDates.isEmpty()) {
            return project.Project_Start_Date__c;

        }
        billingDatesForDisplay.addall(billingDates);

        Date startDate = ProjectProfileServices.BILLINGMETHODINSTALLMENT.equals(project.Billing_Method__c) ? (project.Project_Start_Date__c >= Date.today() ? project.Project_Start_Date__c : Date.today()) :
                                                                                                              project.Project_Start_Date__c;
        Boolean isChangedStartDate = false;
        Date lastBilledDate = project.Project_Start_Date__c;

        for (Billing_Date__c bd : billingDates) {
            if (!bd.Billed__c) {
                billingDateToRemove.add(bd);
            } else {
                isChangedStartDate = true;
                startDate = ProjectProfileServices.BILLINGMETHODINSTALLMENT.equals(project.Billing_Method__c) ? (bd.Processing_Day__c >= Date.today() ? bd.Processing_Day__c : Date.today()) :
                                                                                                                 bd.Processing_Day__c;

                lastBilledDate = ( bd.Processing_Day__c >= lastBilledDate ) ? bd.Processing_Day__c : lastBilledDate;

                numberBilledInterval = Integer.valueOf(bd.Step_Number__c);
                billedPercentage += bd.Percentage__c;
	    }
        }

        delete billingDateToRemove;
	system.debug('!!! startDate = ' + startDate);
	system.debug('!!! lastBilledDate = ' + lastBilledDate);
	system.debug('!!! numberBilledInterval = ' + numberBilledInterval);

        if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT) && isChangedStartDate) {
            if (startDate < project.Project_Start_Date__c) {
                startDate = project.Project_Start_Date__c;
	    }

            if (project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_WEEKLY) /*&&
            		( DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('EEEE') )
            		 <= DateUtils.WEEK_DAY_NUMBER_MAP.get(project.Billing_day__c) )*/ ) {

                startDate = startDate.addDays( DateUtils.WEEK_DAY_NUMBER_MAP.get(project.Billing_day__c) - DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('EEEE') ) );
		system.debug('!!! startDate = ' + startDate);
		if( lastBilledDate.addDays(7) > startDate ) {
                	startDate = startDate.addDays(7);
                }system.debug('!!! startDate = ' + startDate);
		if( startDate < Date.today() ) {
                	startDate = startDate.addDays(7);
                }

            } else if (project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_MONTHLY) /*&&
            			Integer.valueOf(startDate.day()) <= Integer.valueOf(project.Billing_day__c)*/) {

                startDate = startDate.addDays( Integer.valueOf(project.Billing_day__c) - Integer.valueOf(startDate.day()) );
                if( startDate.year() == lastBilledDate.year() && startDate.month() == lastBilledDate.month() ) {
                	startDate = startDate.addMonths(1);
                }
		if( startDate < Date.today() ) {
                	startDate = startDate.addMonths(1);
                }

            } else if ( project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_QUARTERLY)	) {
		system.debug('!!! startDate = ' + startDate);
		Integer currentStartDayInQuarter = Integer.valueOf(startDate.day()) <= Integer.valueOf(project.Billing_day__c) ? Integer.valueOf(startDate.day()) : Integer.valueOf(project.Billing_day__c);
		Decimal neededMonth = (startDate.month() + 1)/3;
		Integer currentStartMonthInQuarter = (Integer.valueOf(neededMonth.round()) - 1)*3 + Integer.valueOf(project.Quarterly_Month__c.left(1));

		startDate = Date.newInstance( lastBilledDate.year(), currentStartMonthInQuarter, currentStartDayInQuarter );

		if( startDate < Date.today() || ( DateUtils.getQuarterNumber(startDate) == DateUtils.getQuarterNumber(lastBilledDate) )  ) {
                	startDate = startDate.addMonths(3);
                }
            }	system.debug('!!! startDate = ' + startDate);

        }

        if (!project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT) && isChangedStartDate) {
            if (project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_WEEKLY)) {
                startDate = startDate.addDays( DateUtils.WEEK_DAY_NUMBER_MAP.get(project.Billing_day__c) - DateUtils.WEEK_DAY_NUMBER_MAP.get( DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0)).format('EEEE') ) );
		system.debug('!!! startDate = ' + startDate);
		if( lastBilledDate.addDays(7) > startDate ) {
                	startDate = startDate.addDays(7);
                }system.debug('!!! startDate = ' + startDate);
		if( startDate < Date.today() ) {
                	startDate = startDate.addDays(7);
                }

            } else if (project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_MONTHLY)) {
                startDate = startDate.addDays( Integer.valueOf(project.Billing_day__c) - Integer.valueOf(startDate.day()) );
                if( startDate.year() == lastBilledDate.year() && startDate.month() == lastBilledDate.month() ) {
                	startDate = startDate.addMonths(1);
                }
		if( startDate < Date.today() ) {
                	startDate = startDate.addMonths(1);
                }

            } else if (project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_QUARTERLY)) {
                system.debug('!!! startDate = ' + startDate);
		Integer currentStartDayInQuarter = Integer.valueOf(startDate.day()) <= Integer.valueOf(project.Billing_day__c) ? Integer.valueOf(startDate.day()) : Integer.valueOf(project.Billing_day__c);
		Decimal neededMonth = (startDate.month() + 1)/3;
		Integer currentStartMonthInQuarter = (Integer.valueOf(neededMonth.round()) - 1)*3 + Integer.valueOf(project.Quarterly_Month__c.left(1));

		startDate = Date.newInstance( lastBilledDate.year(), currentStartMonthInQuarter, currentStartDayInQuarter );

		if( startDate < Date.today() || ( DateUtils.getQuarterNumber(startDate) == DateUtils.getQuarterNumber(lastBilledDate) ) ) {
                	startDate = startDate.addMonths(3);
                }
            }

        }
        return startDate;

    }

	public static void updateBillingDateFprProjectsPercentage(Map<Id, Project_Profile__c> projects) { //MRS 7282
		List<Billing_Date__c> billingDatesToUpdate = new List<Billing_Date__c>();
		List<Billing_Date__c> billingDates = [SELECT Id, Processing_Day__c, Project_Profile__c, Billed__c
												FROM Billing_Date__c
												WHERE Project_Profile__c IN : projects.keySet()
												ORDER BY Step_Number__c ASC ];
		for( Project_Profile__c item: projects.values() ){
			Date endDate   = endBillingDate( item.Project_Start_Date__c, item );

		        item.Billing_End_Date__c = endDate;
		}

		for (Billing_Date__c bd : billingDates) {
	            if (!bd.Billed__c) {
			if( DateUtils.WEEK_DAY_NUMBER_MAP.keySet().contains(projects.get(bd.Project_Profile__c).Billing_day__c) ){
				Integer billingDay = DateUtils.WEEK_DAY_NUMBER_MAP.get(projects.get(bd.Project_Profile__c).Billing_day__c);

//              bd.Processing_Day__c = bd.Processing_Day__c.toStartofWeek().addDays(billingDay - 1);
                //MRS-7512
                bd.Processing_Day__c = bd.Processing_Day__c.toStartofWeek().addDays(billingDay);

			}else{
				Date dt = bd.Processing_Day__c;
				Integer day = Integer.valueOf(projects.get(bd.Project_Profile__c).Billing_day__c);
				if(day > Date.daysInMonth(dt.year(), dt.month())) day = Date.daysInMonth(dt.year(), dt.month());
				bd.Processing_Day__c = Date.newInstance(dt.year(), dt.month(), day);
			}
			if( projects.get(bd.Project_Profile__c).Billing_End_Date__c < bd.Processing_Day__c ) projects.get(bd.Project_Profile__c).Billing_End_Date__c = bd.Processing_Day__c;
	                if( projects.get(bd.Project_Profile__c).Project_Start_Date__c > bd.Processing_Day__c ) bd.Processing_Day__c = projects.get(bd.Project_Profile__c).Project_Start_Date__c;
	                billingDatesToUpdate.add(bd);
	            }
		}
	    system.debug('!!! billingDatesToUpdate = ' + billingDatesToUpdate);
		UPDATE billingDatesToUpdate;
	}

    /* -------------------------------------- Begin DAO Methods -------------------------------------------------*/
    public static List<Billing_Date__c> getBillingDatesByProjectId(Id projectId) {
        return new List<Billing_Date__c>([SELECT Id, Processing_Day__c, Step_Number__c, Percentage__c, Project_Profile__c, Project_Profile__r.Total_Service_Amount__c,
                                                 Project_Profile__r.Discounted_Total_Service_Amount__c, Billed__c, Amount__c
                                          FROM Billing_Date__c
                                          WHERE Project_Profile__c =: projectId Order By Step_Number__c ASC ]);

    }
    /* -------------------------------------- End DAO Methods -------------------------------------------------*/

}