public with sharing class DDPHelperServices {

	public static String TYPE_BILLING_JOB_SUPPORT = 'Billing Job Support';
	public static String TYPE_PROFORMA_INVOICE_BATCH_JOB = 'Create Pro-Forma Invoices';
	public static String TYPE_PROFORMA_INVOICE_BATCH_JOB_ERRORS = 'Create Pro-Forma Invoices Error';
	public static String TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL = 'Billing Job Support For Email';
	public static String CREATE_BATCH_SALES_INVOICES_POST = 'Post Sales Invoices';
	public static String CREATE_FFA_SALES_INVOICES = 'Create FFA Sales Invoices';
	public static String CREATE_PDFS_FOR_GROUPING_INVOICES = 'Create Grouped PDFs With Pro-Forma Invoices';
	public static String CREATE_PDFS_FOR_PROFORMA_INVOICES = 'Create PDFs For Pro-Forma Invoices';
	public static String SEND_PROFORMA_INVOICES = 'Send Pro-Forma Invoices';

	public static String TYPE_PROFORMA_INVOICE_BATCH_JOB_DAILY = 'Create Pro-Forma Invoices Daily';
	public static String CREATE_BATCH_SALES_INVOICES_POST_DAILY = 'Post Sales Invoices Daily';
	public static String CREATE_FFA_SALES_INVOICES_DAILY = 'Create FFA Sales Invoices Daily';
	public static String CREATE_PDFS_FOR_GROUPING_INVOICES_DAILY = 'Create Grouped PDFs With Pro-Forma Invoices Daily';
	public static String CREATE_PDFS_FOR_PROFORMA_INVOICES_DAILY = 'Create PDFs For Pro-Forma Invoices Daily';
	public static String SEND_PROFORMA_INVOICES_DAILY = 'Send Pro-Forma Invoices Daily';
	public static String STATEMENT_OF_ACCOUNTS_TASK_DOCUMENT = 'SOA Task';//MRS-7449
	public static String STATEMENT_OF_ACCOUNTS_SUBJECT = 'Accounts Receivable Statement from Milrose Consultants';

	public static void calculateExecutionDateForDDP (DDP_Helper__c ddpHelper, DateTime processingDateTime, Boolean doIncludeCurentDate){
		processingDateTime = processingDateTime == null ? DateTime.now() : processingDateTime;
		Integer currentHour = processingDateTime.hour();
		Integer emailStatementsHour = ddpHelper.Email_Statements_Job_Hour__c != null && ddpHelper.Email_Statements_Job_Hour__c.isNumeric() ? Integer.valueOf(ddpHelper.Email_Statements_Job_Hour__c) : 18;
		if ( ddpHelper.Is_Day_Of_Month__c ){
			Integer processingDateDay = processingDateTime.day();
			Integer fireDateDay = ddpHelper.Day_Of_Month__c == 'last' ? Date.daysInMonth(processingDateTime.year(), processingDateTime.month()) : Integer.valueOf(ddpHelper.Day_Of_Month__c);

			Boolean fireMonth = (doIncludeCurentDate && (fireDateDay < processingDateDay)) || (!doIncludeCurentDate && ((fireDateDay < processingDateDay) || (fireDateDay == processingDateDay && emailStatementsHour > currentHour)));

			Integer daysInFireMonth = Date.daysInMonth( ( processingDateTime.addMonths(fireMonth ? 1 : 0) ).year(),
														( processingDateTime.addMonths(fireMonth ? 1 : 0) ).month() );

			Date d = Date.newInstance( (processingDateTime.addMonths(fireMonth ? 1 : 0)).year(),
									   (processingDateTime.addMonths(fireMonth ? 1 : 0)).month(),
									   (ddpHelper.Day_Of_Month__c == 'last' || fireDateDay > daysInFireMonth) ? daysInFireMonth : fireDateDay );

			ddpHelper.Email_Statements_Job_Ex_DateTime__c = DateTime.newInstance(d, Time.newInstance(emailStatementsHour, 0, 0, 0));
		} else {
			Integer dayOfWeekNumber = Integer.valueOf(ddpHelper.Sunday_Or_Saturday__c);
			Date processingDate = Date.newInstance(processingDateTime.year(), processingDateTime.month(), processingDateTime.day());

			if (ddpHelper.Number_Week__c != 'L'){
				Integer weekNumber = Integer.valueOf(ddpHelper.Number_Week__c);
				Date dStartMonth = processingDate.toStartOfMonth();

				Date startWeekDate = dStartMonth.toStartOfWeek().addDays(dayOfWeekNumber - 1);

				Date weekNumberDate;

				if (dStartMonth.month() == startWeekDate.month()){
					weekNumberDate = startWeekDate.addDays( 7 * (weekNumber - 1) );
				} else {
					weekNumberDate = startWeekDate.addDays( 7 * weekNumber );
				}

				if ( (doIncludeCurentDate && ((weekNumberDate > processingDate) || (weekNumberDate == processingDate && emailStatementsHour <= currentHour))) || (!doIncludeCurentDate && weekNumberDate > processingDate) ){
					ddpHelper.Email_Statements_Job_Ex_DateTime__c = DateTime.newInstance(weekNumberDate, Time.newInstance(emailStatementsHour, 0, 0, 0));
				} else {
					dStartMonth = processingDate.addMonths(1).toStartOfMonth();
					startWeekDate = dStartMonth.toStartOfWeek();
					startWeekDate = startWeekDate.addDays( dayOfWeekNumber - 1 );

					if ( dStartMonth.month() == startWeekDate.month() ){
						startWeekDate = startWeekDate.addDays( 7 * (weekNumber - 1) );
					} else {
						startWeekDate = startWeekDate.addDays( 7 * weekNumber );
					}
					ddpHelper.Email_Statements_Job_Ex_DateTime__c = DateTime.newInstance(startWeekDate, Time.newInstance(emailStatementsHour, 0, 0, 0));
				}

			} else {
				Date dLastMonth = Date.newInstance( processingDate.year(), processingDate.month(), Date.daysInMonth( processingDate.year(), processingDate.month() ) );
				Date startWeekDate = dLastMonth.toStartOfWeek().addDays(dayOfWeekNumber - 8);

				Date lastWeekDate = startWeekDate.addDays( 7 ).month() == processingDate.month() ? startWeekDate.addDays( 7 ) : startWeekDate;

				if ((doIncludeCurentDate && (lastWeekDate > processingDate || (lastWeekDate == processingDate && emailStatementsHour >= currentHour))) || (!doIncludeCurentDate && lastWeekDate > processingDate)){
					ddpHelper.Email_Statements_Job_Ex_DateTime__c = DateTime.newInstance(lastWeekDate, Time.newInstance(emailStatementsHour, 0, 0, 0));
				} else {
					dLastMonth = Date.newInstance( (processingDate.addMonths(1)).year(), (processingDate.addMonths(1)).month(), Date.daysInMonth( (processingDate.addMonths(1)).year(), (processingDate.addMonths(1)).month() ) );
					startWeekDate = dLastMonth.toStartOfWeek().addDays(dayOfWeekNumber - 8);

					lastWeekDate = startWeekDate.addDays( 7 ).month() == dLastMonth.month() ? startWeekDate.addDays( 7 ) : startWeekDate;
					ddpHelper.Email_Statements_Job_Ex_DateTime__c = DateTime.newInstance(lastWeekDate, Time.newInstance(emailStatementsHour, 0, 0, 0));
				}
			}
		}
	}
}