public with sharing class CheckServices {
    public static final String CHARGE                             = 'CHARGE';
    public static final String INTERNAL                           = 'INTERNAL';
    public static final String INTERNAL_STANDARD_REQUEST          = 'Standard Request';
    public static final String INTERNAL_RUSH_REQUEST              = 'Rush Request';
    public static final String INTERNAL_CHARGED_TO_CORPORATE_CARD = 'Charged to Corporate Card';
    //MRS-6555, MRS-7494
    public static final String EXTERNAL_LINK_FOR_NYC              = '<br/><div style="font-size:12px;">For your convenience, we can issue checks payable to the municipal agencies if we receive payment via one ' +
                                                                    'of the following methods at least <b><u>three days</u></b> prior to the date of filing (which is expected to be<b> xx/xx/xx</b>):<br/></div>'+
                                                                    '<div style="font-size:12px;">' +
                                                                        '<li><b>Electronic Wire Transfer:</b>' +
                                                                        '<ul>' +
                                                                            '<div>Bank of America</div>' +
                                                                            '<div>1185 Avenue of the Americas</div>' +
                                                                            '<div>New York, NY 10036</div>' +
                                                                            '<div>ACCT # 4837307121</div>' +
                                                                            '<div>ABA # (ACH) 021000322</div>' +
                                                                            '<div>ABA # (Wire) 026009593</div>' +
                                                                            '<div><b>Ref: {0}, {1}</b></div>' +
                                                                            '<div />' +
                                                                        '</ul><br/>' +
                                                                        '<li><b>Online Credit Card Payment: https://www.milrose.com/payments/</b>' +
                                                                        '<ul>' +
                                                                            '<div>Enter "99" as the Invoice Number</div>' +
                                                                            '<div><b>Ref: {0}, {1}</b></div>' +
                                                                        '</ul>' +
                                                                    '</div>' +
                                                                    '<br/><div style="font-size:12px;">By submitting payment for the Municipal Fees in advance, you can ensure an expedited filing submissions timeline and prevent any unnecessary processing delays.</div>' +
                                                                    '<br/><div style="font-size:12px;">Please note that all submitted municipal fee payment balances will be captured on your invoices for tracking purposes.</div>' +
                                                                    '<br/><div style="font-size:12px;">Should you have any questions, please feel free to contact me at {2}. Thank you.</div>';

    public static final String REQUEST_CHECK_TEMPLATE_NAME          = 'Request Filing Fees Task Item';
    public static final String REQUEST_CHECK_TEMPLATE_NAME_DRAFT    = 'Request Filing Fees Task Item Draft';
    public static final String REQUEST_CHECK_TEMPLATE_NAME_REMINDER = 'Request Filling Fee Reminder';
    public static final String REQUEST_CHECK_DRAWLOOP_NAME          = 'Request Filing Fee';

    public static String RFF_FOLLOW_UP_MESSAGE = 'There are outstanding check requests for {0}. Please follow up.';
    public static String CHECK_ERROR_UPDATE = 'Check Request "[{0}]" has already been processed and cannot be modified or re-submitted. Please inform accounting and create a new request if this request is no longer valid.';

    /* ------------------------------------------- Begin Business logic Methods -------------------------------------------------------------------*/
    public static Set<Id> staffAccountantUserIds {
        get {
            if (null == staffAccountantUserIds) {
                staffAccountantUserIds = new Set<Id>();
                Map<Id, User> usersMap = new Map<Id, User>([SELECT Profile.Name, ProfileId, IsActive
                                                            FROM User
                                                            WHERE IsActive =: true AND (Profile.Name =: UserServices.PROFILE_STAFF_ACCOUNTANT OR Profile.Name =: UserServices.PROFILE_STAFF_ACCOUNTANT_QA)]);
                staffAccountantUserIds.addall(usersMap.keySet());

            }
            return staffAccountantUserIds;
        }
        set;
    }

    @TestVisible
    private static Datetime bussinessHoursPlusThreeDays {
        get {
            if (null == bussinessHoursPlusThreeDays) {
                bussinessHoursPlusThreeDays = DateUtils.getDatetimeWithTimeShiftByBusinessHours(datetime.now(), '3d');

            }
            return bussinessHoursPlusThreeDays;

        }
        set;
    }

    public static Check__c newInstance(final Task_Item__c taskItem) {
        if (null == taskItem) {
            throw new ErrorException(ErrorException.TASK_ITEM_EMPTY);

        }

        Check__c newCheck = new Check__c(Task_Item__c       = taskItem.Id,
                                         Check_Amount__c    = 0,
                                         Billing_Client__c  = taskItem.Project_Profile__r.Billing_Company_Name__c,
                                         Billing_Contact__c = taskItem.Project_Profile__r.Billing_Company_Contact__c,
                                         Phase__c           = taskItem.Service_Item__r.Phase__c,
                                         Project_Address__c = taskItem.Project_Profile__r.Building__c,
                                         Service_Item__c    = taskItem.Service_Item__c);
        insert newCheck;

        return newCheck;

    }

    public static void updateCheck( List<Check__c> checksRequest ) {
        List<Check__c> checkToUpdate = new List<Check__c>();

        for (Check__c check : checksRequest) {
            if (null == check.Account__c || null == check.Check_Amount__c || 0 == check.Check_Amount__c || String.isBlank(check.Description__c)) {
                throw new ErrorException(ErrorException.CHECK_REQUEST_REQUIRED_FIELDS);

            }

            if (null != check.Date_Received__c && null == check.Check_Number__c) {
                throw new ErrorException(ErrorException.CHECK_REQUEST_CHECK_NUMBER_REQUIRED);

            }

            if (null != check.Date_Check_Returned__c && String.isBlank(check.Reasone__c)) {
                throw new ErrorException(ErrorException.CHECK_REQUEST_RETURN_REASONE_REQUIRED);

            }
            checkToUpdate.add(check);
        }

        if( checkToUpdate.isEmpty() ) {
            return;
        }

        Database.SaveResult[] srList1 = Database.update( checkToUpdate, false );
        for( Integer i = 0; i < checkToUpdate.size(); i++ ) {
           Database.SaveResult sr = srList1[i];
           Check__c origRecord = checkToUpdate[i];
           if ( !sr.isSuccess() ) {
               for( Database.Error err : sr.getErrors() ) {
                    if( err.getMessage().contains( String.format( CHECK_ERROR_UPDATE, new List<String>{origRecord.Description__c} ) ) ) {
                        ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.INFO, err.getMessage() ) );
                    } else {
                        ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.INFO, 'An error has occurred while updating checks: ' + err.getMessage() ) );
                    }
               }
           }
        }
    }

    public static void updateCheckExpenseInvoice(List<Reimbursable_Expense_Invoice__c> reimbInvoices, List<Check__c> sendChecks) {
        if (null == reimbInvoices || reimbInvoices.isEmpty()) {
            return;
        }

        Map<Id, Reimbursable_Expense_Invoice__c> checkIdToExpenseInvoiceMap = new Map<Id, Reimbursable_Expense_Invoice__c>();

        for (Reimbursable_Expense_Invoice__c invoice : reimbInvoices) {
            if (!checkIdToExpenseInvoiceMap.containsKey(invoice.Check_Request__c)) {
                checkIdToExpenseInvoiceMap.put(invoice.Check_Request__c, invoice);
            }
        }

        for (Check__c check : sendChecks) {
            if (checkIdToExpenseInvoiceMap.containsKey(check.Id)) {
                check.Reimbursable_Expense_Invoice__c = checkIdToExpenseInvoiceMap.get(check.Id).Id;
            }
        }
    }

    public static String getForPayments(final String projectName) {
        if (String.isBlank(projectName)) {
            projectName = '';

        }
        return 'https://www.milrose.com/payments/index.php?ordernumber=' + projectName + '&invoicenumber=99FilingFee'; //MRS 7475
    }

    public static List<SelectOption> getInternalRequestOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(CheckServices.INTERNAL_STANDARD_REQUEST, CheckServices.INTERNAL_STANDARD_REQUEST));
        options.add(new SelectOption(CheckServices.INTERNAL_RUSH_REQUEST, CheckServices.INTERNAL_RUSH_REQUEST));
        options.add(new SelectOption(CheckServices.INTERNAL_CHARGED_TO_CORPORATE_CARD, CheckServices.INTERNAL_CHARGED_TO_CORPORATE_CARD));
        return options;

    }

    public static Double calculateFee(Double cost, final String subtype) {
        Double roundCost = roundUpThousand(cost);
        Double param1 = roundCost < 5000 ? 0 : (roundCost - 5000) / 1000;
        return param1 * 10.3 + getSecondFilingParam(roundCost, subtype);

    }

    private static Double getSecondFilingParam(final Double cost, final String subtype) {
        if (subtype.contains(ServiceItemServices.RFF_ALTERATION_TYPE_1)) {
            if (cost < 1) {
                return 0;

            } else if (1 < cost && cost < 4000) {
                return 100;

            } else if (4000 <= cost && cost < 5000) {
                return 120;

            } else if (cost >= 5000) {
                return 140;

            }

        } else if (subtype.contains(ServiceItemServices.RFF_ALTERATION_TYPE_2) || subtype.contains(ServiceItemServices.RFF_ALTERATION_TYPE_3)) {
            if (cost < 1) {
                return 0;

            } else if (1 < cost && cost < 4000) {
                return 225;

            } else if (4000 <= cost && cost < 5000) {
                return 245;

            } else if (cost >= 5000) {
                return 265;

            }

        }
        return 0.00;

    }

    @TestVisible private static Double roundUpThousand(Double cost) {
        if (null == cost) {
            return 0;

        }
        return 0 != (cost / 1000 - (cost / 1000).intValue()) ? ((cost / 1000).intValue() + 1) * 1000 : cost;

    }

    /* --------------------- Begin Action Button "Process Check Requests" On Payable Invoice Tab ----------------------------------------*/
    private static Set<Id> usedIds = new Set<Id>();

    public static void processCheckRequestsInQueue(Set<Id> chekcIds) {
        List<Check__c> checks = CheckServices.getCheckRequestInQueue(chekcIds);

        if (checks.isEmpty()) {
            return;

        }
        processCheckRequests(checks);

    }

    public static void processCheckRequestsInQueue() {
        List<Check__c> checks = CheckServices.getCheckRequestInQueue();

        if (checks.isEmpty()) {
            return;

        }
        processCheckRequests(checks);

    }

    private static void processCheckRequests( List<Check__c> checks ) {
        Map<Id, List<Check__c>> projectIdToChecks = new Map<Id, List<Check__c>>();
        Set<Id> accountIds = new Set<Id>();

        Savepoint sp = Database.setSavepoint();
        try {
            //set checkbox in DB to remove double-click issues on button (lock them by setting error checkbox; the select will get only those checks with error = false)
            for( Check__c check : checks ) {
                check.Processing_Error__c = true;
                check.Processing_Error_Message__c = 'Can not lock Check for processing or update Check.';
            }
            Database.SaveResult[] updateChecksResult = Database.update( checks, false );

            List<Check__c> checksPrepSuccess = new List<Check__c>();
            for( Integer i = 0; i < updateChecksResult.size(); i++ ) {
                if( updateChecksResult[i].isSuccess() ) {
                    checksPrepSuccess.add( checks[i] );
                }
            }

            //reset errors for check records that were locked
            for( Check__c check : checksPrepSuccess ) {
                check.Processing_Error__c = false;
                check.Processing_Error_Message__c = '';
            }

            for( Check__c check : checksPrepSuccess ) {
                if( !projectIdToChecks.containsKey( check.Task_Item__r.Project_Profile__c ) ) {
                    projectIdToChecks.put( check.Task_Item__r.Project_Profile__c, new List<Check__c>() );
                }
                projectIdToChecks.get( check.Task_Item__r.Project_Profile__c ).add( check );
                accountIds.add( check.Account__c );
            }
            projectIdToChecks.remove(null);
            accountIds.remove(null);

            usedIds = new Set<Id>();
            List<Reimbursable_Expense_Invoice__c> reimbInvoices = new List<Reimbursable_Expense_Invoice__c>();
            List<Account> accountList = AccountServices.getAccountWithPurchaseInvoicesByIds( accountIds );

            for( Id projectId : projectIdToChecks.keySet() ) {
                reimbInvoices.addall( CheckServices.setInvoicePayeeInQueue( projectId, accountList, projectIdToChecks.get( projectId ) ) );
            }

            //insert REI and error handling start
            Database.SaveResult[] insertReiResult = Database.insert( reimbInvoices, false );

            Map<Id, Reimbursable_Expense_Invoice__c> reimbInvoiceIdToReimbInvoice = new Map<Id, Reimbursable_Expense_Invoice__c>();
            for( Reimbursable_Expense_Invoice__c reimbInvoice : reimbInvoices ) {
                reimbInvoiceIdToReimbInvoice.put( reimbInvoice.Id, reimbInvoice );
            }

            Map<Id, Check__c> checkIdToCheck = new Map<Id, Check__c>( checksPrepSuccess );
            for( Integer i = 0; i < insertReiResult.size(); i++ ) {
                Database.SaveResult sr = insertReiResult[i];
                if( !sr.isSuccess() ) {
                    Check__c checkItem = checkIdToCheck.get( reimbInvoices[i].Check_Request__c );
                    checkItem.Processing_Error__c = true;
                    checkItem.Processing_Error_Message__c = 'Can not create REI or link Check to REI: ' + sr.getErrors()[0].getFields() + ': ' + sr.getErrors()[0].getMessage();
                    checkItem.Processing_Error_Message__c = checkItem.Processing_Error_Message__c.left(1024);
                }
            }
            //insert REI and error handling end

            updateCheckExpenseInvoice( reimbInvoices, checksPrepSuccess ); //populates lookup to REI on Check
            Database.SaveResult[] updateCheckResult = Database.update( checksPrepSuccess, false );

        } catch( Exception ex ) {
            Database.rollback(sp);
            throw new ErrorException( ex.getMessage() );
        }

    }

    public static List<Reimbursable_Expense_Invoice__c> setInvoicePayeeInQueue( final Id projectId, final List<Account> accountList, List<Check__c> sendChecks ) {
        List<Check__c> checksInQueue = new List<Check__c>();
        List<Reimbursable_Expense_Invoice__c> reimbInvoices = new List<Reimbursable_Expense_Invoice__c>();
        Reimbursable_Expense_Invoice__c reimburExpense;

        for( Check__c check : sendChecks ) {
            for( Account childAcc : accountList ) {
                if( check.Account__c == childAcc.Account_Check__c && childAcc.c2g__PurchaseInvoices__r.isEmpty() && !usedIds.contains(childAcc.Id) ) {
                    check.Invoice_Payee__c = childAcc.Id;
                    check.isQueue__c = false;
                    usedIds.add( childAcc.Id );
                    try {
                        reimburExpense = ReimbursableExpenseInvoiceServices.newInstance( check, projectId );
                        reimburExpense.Invoice_Display_Name__c = check.Account__r.Name;
                        reimbInvoices.add( reimburExpense );
                    } catch( Exception ex ) {
                        check.Processing_Error__c = true;
                        check.Processing_Error_Message__c = 'Errors populating REI: ' + ex.getMessage();
                        check.Processing_Error_Message__c = check.Processing_Error_Message__c.left(1024);
                    }
                    break;
                }
            }
            if (null == check.Invoice_Payee__c && null == check.Date_Received__c) {
                check.isQueue__c = true;
                checksInQueue.add(check);
            }
        }
        return reimbInvoices;
    }

    /* --------------------- End Action Button "Process Check Requests" On Payable Invoice Tab ----------------------------------------*/

    /* --------------------- Begin Build Dynamically Check Requetst Reminder ----------------------------------------*/

    @future (callout=true)
    public static void sendCheckRequestReminder(Set<Decimal> groupNumbers) {
        if (null == groupNumbers || groupNumbers.isEmpty()) {
            return;

        }

        Map<Decimal, List<Check__c>> groupNumberToChecks = getGroupNumbetToCheckRequestByGroupNumber(groupNumbers);
        Set<Id> serviceItemIds;

        for (Decimal groupNumber : groupNumberToChecks.keySet()) {
            serviceItemIds = new Set<Id>();

			//MRS-7494
            String emailBody;
            String projectMRC;
            String projectName;

            for (Check__c check : groupNumberToChecks.get(groupNumber)) {
                check.Send_Reminder__c = true;
                if ( check.Reminder_Body__c != null ) emailBody = check.Reminder_Body__c;
                if ( check.Service_Item__r.Project_Profile__c != null ){
                    projectMRC  = check.Service_Item__r.Project_Profile__r.Name;
                    projectName = check.Service_Item__r.Project_Profile__r.Project_Name__c;
                }
                serviceItemIds.add(check.Account__c);

            }

            if (String.isEmpty(emailBody)){
                emailBody          = getBodyMail(groupNumberToChecks.get(groupNumber).get(0)).substring(0, getBodyMail(groupNumberToChecks.get(groupNumber).get(0)).indexOf('<table'));
                Integer order      = 1;
                String tableHeader = getBodyMail(groupNumberToChecks.get(groupNumber).get(0)).substring(getBodyMail(groupNumberToChecks.get(groupNumber).get(0)).indexOf('<table'), getBodyMail(groupNumberToChecks.get(groupNumber).get(0)).lastIndexOf('</table>'));

                List<RFI_Work__c> rfiWorkTypes = RFIWorkTypeServices.getWorkTypeByServiceItemIds(serviceItemIds);

                for (Check__c item : groupNumberToChecks.get(groupNumber)) {
                    emailBody += '<table>' + tableHeader + CheckServices.checkRow(order++, item) + '</table> <br />';

                    if (item.Include_Estimated_Cost_Detail__c) {
                        emailBody += CheckServices.workTypeTable(item, rfiWorkTypes);

                    }

                }
                emailBody += String.format(CheckServices.EXTERNAL_LINK_FOR_NYC, new List<String>{projectMRC,
                                                                                                 projectName,
                                                                                                 (String.isBlank(loggedUser.Phone)) ? 'none' : loggedUser.Phone});

                emailBody += MergeEmailTemplate.legalFooter();
            }

            List<String> address = new List<String>();
            if (!String.isBlank(groupNumberToChecks.get(groupNumber).get(0).Recipient_Reminder_Address_CC__c)) {
                address = groupNumberToChecks.get(groupNumber).get(0).Recipient_Reminder_Address_CC__c.split(';');

            }
            address.add(groupNumberToChecks.get(groupNumber).get(0).Recipient_Reminder_Address__c);
            String[] addressEmail = address;

            Project_Profile__c project = ProjectProfileServices.getProjectById(groupNumberToChecks.get(groupNumber).get(0).Service_Item__r.Project_Profile__c);
            MergeEmailTemplate templateEmail = new MergeEmailTemplate(CheckServices.REQUEST_CHECK_TEMPLATE_NAME, project, '', MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL, '', '');
            EmailMessageService.sendSingleMailToDistribution(addressEmail, new String[] {} , 'REMINDER ' + templateEmail.subject, emailBody);

        }

    }

    public static Set<Decimal> getGroupNumbersForReminder(List<Check__c> newChecks, Map<Id, Check__c> oldMaps) {
        Set<Decimal> groupsSet = new Set<Decimal>();

        for (Check__c check : newChecks) {
            if (check.Send_Reminder__c && !oldMaps.get(check.Id).Send_Reminder__c) {
                if (!groupsSet.contains(check.Requested_Checks_Group__c)) {
                    groupsSet.add(check.Requested_Checks_Group__c);

                }

            }

        }

        groupsSet.remove(null);
        return groupsSet;

    }

    public static String checkRow(Integer orderNumber, Check__c check) {
        return '<tr><td style="width: 39px;">' + String.valueOf(orderNumber) + '</td>' + '<td style="width: 165px;">' + check.Account__r.Name + '</td>' + '<td style="width: 245px;">' + (null == check.Description__c ? '' : check.Description__c) + '</td>' + '<td style="width: 152px;">' + check.Check_Amount__c + '</td></tr>';

    }

    public static String workTypeTable(Check__c check, List<RFI_Work__c> rfiWorkTypes) {
        String body = '';

        for (RFI_Work__c workTypeItem : rfiWorkTypes) {
           if (check.Service_Item__c == workTypeItem.Application_Service_Item__c || check.Service_Item__c == workTypeItem.Sign_Off_Service_Item__c) {
               body += '<tr> <td style="border: 1px solid black;"></td> <td style="border: 1px solid black;">' + workTypeItem.Name + '</td> <td style="border: 1px solid black;">' + String.valueOf(workTypeItem.Estimated_Cost__c) + '</td> <td style="border: 1px solid black;">' + String.valueOf(workTypeItem.Filing_Fee__c) + '</td> </tr>';

           }

        }

        if (String.isBlank(body)) {
            return '';

        }
        return '<table style="border-collapse: collapse;"> <tr> <th style="border: 1px solid black;">Cost Detail</th> <th style="border: 1px solid black;">Work Type</th> <th style="border: 1px solid black;">Estimated Cost</th> <th style="border: 1px solid black;">Filing Fee</th> </tr>' + body + '</table> <br />';

    }

    public static EmailTemplate emailTemplate {
        get {
            if (null == emailTemplate) {
                try {
                    emailTemplate = EmailMessageService.getEmailTemplateByName(CheckServices.REQUEST_CHECK_TEMPLATE_NAME);

                } catch(Exception ex) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                    return null;

                }

            }
            return emailTemplate;

        }
        set;
    }

    private static String bodyMail;

    public static String getBodyMail(final Check__c check) {
        if (null == bodyMail) {
            bodyMail = emailTemplate.HtmlValue.substring(emailTemplate.HtmlValue.indexOf('CDATA[') + 6, emailTemplate.HtmlValue.lastIndexOf(']]>'));

            if (bodyMail.contains('{receiver}')) {
                if (null == check) {
                    bodyMail = bodyMail.replace('{receiver}', '');

                } else {
                    List<Project_Roster__c> rosters = ProjectRosterServices.getRostersByIds(new Set<Id> { check.Project_Roster__c });

                    if (rosters.isEmpty()) {
                        bodyMail = bodyMail.replace('{receiver}', '');

                    } else {
                        bodyMail = bodyMail.replace('{receiver}', rosters.get(0).Name_Full__c);

                    }

                }

            }

            if (bodyMail.contains('{link}')) {
                bodyMail = bodyMail.replace('{link}', '<a href="' + CheckServices.getForPayments(check.Service_Item__r.Project_Profile__r.Name) + '">click here</a>');

            }

            if (bodyMail.contains('{phone}')) {
                bodyMail = bodyMail.replace('{phone}', String.isBlank(loggedUser.Phone) ? 'none' : loggedUser.Phone);

            }

        }
        return bodyMail;

    }

    public static User loggedUser {
        get {
            if (null == loggedUser) {
                List<User> users = new List<User>([SELECT Id, Phone FROM User WHERE Id =: UserInfo.getUserId() limit 1]);

                if (users.isEmpty()) {
                    throw new ErrorException(ErrorException.USER_DOES_NOT_EXIST);

                }
                loggedUser = users.get(0);

            }
            return loggedUser;
        }
        set;
    }

    public static Set<Id> filterChecksForCompleteTasks(final Map<Id, Check__c> checks) {
        Set<Id> checkIds = new Set<Id>();

        for (Check__c check : checks.values()) {
            if (null != check.Date_Received__c && null != check.Check_Number__c) {
                checkIds.add(check.Id);

            }

        }

        return checkIds;

    }

    @future (callout=true)
    public static void completeTasks(final Set<Id> checks) {
        if (null == checks || checks.isEmpty()) {
            return;

        }

        List<String> ids = new List<String>();
        List<Task> tasks = Database.query(TaskServices.buildSelectByRelatedIds(checks));

        for (Task t : tasks) {
            ids.addall(t.Related_Record_Ids__c.split(';'));

        }

        Map<Id, Check__c> notCompleteChecks = new Map<Id, Check__c>([SELECT Id
                                                                     FROM Check__c
                                                                     WHERE id IN: ids AND Date_Received__c =: null AND Check_Number__c =: null]);

        Boolean isExistCheck;
        List<Task> tasksToUpdate = new List<Task>();

        for (Task t : tasks) {
            isExistCheck = false;
            for (String relatedId : t.Related_Record_Ids__c.split(';')) {
                if (notCompleteChecks.containsKey(relatedId)) {
                    isExistCheck = true;

                }

            }

            if (!isExistCheck) {
                t.Status = 'Completed';
                tasksToUpdate.add(t);

            }

        }
        update tasksToUpdate;

    }
    /* --------------------- End Build Dynamically Check Requetst Reminder ----------------------------------------*/

    /* ------------------------------------------- End Business logic Methods -------------------------------------------------------------------*/

    /* ------------------------------------------- Begin DAO Methods -------------------------------------------------------------------*/
    public static List<Check__c> getChecksByTaskItemId(final Id taskItemId) {
        if (String.isBlank(taskItemId)) {
            return new List<Check__c>();

        }

        List<Check__c> checks = new List<Check__c>([SELECT Id, Check_Number__c, Check_Amount__c, Date_Received__c, Date_Requested__c, Municipal_Agency_ID__c, Task_Item__r.Name,
                                                           Requested_From__c, Task_Item__c, Account__c, isQueue__c, Follow_Up_Alert__c, Recipient_Reminder__c, Project_Roster__r.Name__c,
                                                           Task_Item__r.Project_Profile__c, Account__r.Name, Date_Check_Returned__c, Project_Roster__c, Internal__c,
                                                           Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Reasone__c, Notes__c, Service_Item__r.Service_Name_Full__c,
                                                           Phase__c, Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Include_Estimated_Cost_Detail__c
                                                    FROM Check__c
                                                    WHERE Task_Item__c =: taskItemId]);

        if (null == checks) {
            return new List<Check__c>();

        }
        return checks;

    }

    public static List<Check__c> getChecksByProjectId(final Id projectId) {
        if (String.isBlank(projectId)) {
            throw new ErrorException(ErrorException.TASK_ITEM_ID_EMPTY);

        }

        List<Check__c> checksWithDesc = [SELECT Id, Name, Task_Item__r.Name, Check_Number__c, Check_Amount__c, Date_Received__c, Date_Requested__c, Municipal_Agency_ID__c, CreatedDate, Task_Item__r.Service_Item__c,
                                            Requested_From__c, Task_Item__c, Account__c, isQueue__c, Follow_Up_Alert__c, Recipient_Reminder__c, Project_Roster__r.Name__c,
                                            Task_Item__r.Project_Profile__c, Account__r.Name, Date_Check_Returned__c, Project_Roster__c, Internal__c, Service_Item__r.Service_Name_Short__c,
                                            Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Reasone__c, Notes__c, Service_Item__r.Service_Name_Full__c,
                                            Phase__c, Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Include_Estimated_Cost_Detail__c, Project_Roster__r.Contact__c,
                                            Service_Item__r.Short_Service_Name_Worktype__c, Add_Check_Processing_Fee__c
                                         FROM Check__c
                                         WHERE Task_Item__r.Project_Profile__c =: projectId AND Account__c != null AND Check_Amount__c != null
                                         ORDER BY CreatedDate ASC];

        List<Check__c> checks = new List<Check__c>();

        for (Check__c checkItem : checksWithDesc ) {
            if (!String.isBlank(checkItem.Description__c)) {
                checks.add(checkItem);

            }

        }
        return checks;

    }

    public static List<Check__c> getCheckRequestInQueue( Set<Id> checkIds ) {
        if (null == checkIds || checkIds.isEmpty()) {
            return new List<Check__c>();

        }

        return new List<Check__c>([ SELECT Id, Task_Item__r.Name, Check_Number__c, Check_Amount__c, Date_Received__c, Date_Requested__c, Municipal_Agency_ID__c, Invoice_Payee__r.Name,
                                           Requested_From__c, Task_Item__c, Account__c, isQueue__c, Follow_Up_Alert__c, Recipient_Reminder__c, Project_Roster__r.Name__c,
                                           Task_Item__r.Project_Profile__c, Account__r.Name, Date_Check_Returned__c, Project_Roster__c, Internal__c, Service_Item__r.Project_Profile__r.Name,
                                           Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Reasone__c, Notes__c, Service_Item__r.Service_Name_Full__c,
                                           Phase__c, Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Include_Estimated_Cost_Detail__c,
                                           Processing_Error__c, Processing_Error_Message__c
                                    FROM Check__c
                                    WHERE Id IN: checkIds
                                      AND isQueue__c = true
                                      AND Requested_From__c = : CheckServices.INTERNAL
                                      AND Processing_Error__c = false
                                    FOR UPDATE ] );

    }

    public static List<Check__c> getCheckRequestInQueue() {
        return new List<Check__c>([ SELECT Id, Task_Item__r.Name, Check_Number__c, Check_Amount__c, Date_Received__c, Date_Requested__c, Municipal_Agency_ID__c, Invoice_Payee__r.Name,
                                           Requested_From__c, Task_Item__c, Account__c, isQueue__c, Follow_Up_Alert__c, Recipient_Reminder__c, Project_Roster__r.Name__c,
                                           Task_Item__r.Project_Profile__c, Account__r.Name, Date_Check_Returned__c, Project_Roster__c, Internal__c, Service_Item__r.Project_Profile__r.Name,
                                           Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Reasone__c, Notes__c, Service_Item__r.Service_Name_Full__c,
                                           Phase__c, Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Include_Estimated_Cost_Detail__c,
                                           Processing_Error__c, Processing_Error_Message__c
                                    FROM Check__c
                                    WHERE isQueue__c = true
                                      AND Requested_From__c = : CheckServices.INTERNAL
                                      AND Processing_Error__c = false
                                    FOR UPDATE ] );

    }

    public static Map<Decimal, List<Check__c>> getGroupNumbetToCheckRequestByGroupNumber(final Set<Decimal> groupNumbers) {
        if (null == groupNumbers || groupNumbers.isEmpty()) {
            return new Map<Decimal, List<Check__c>>();

        }

        List<Check__c> checks = new List<Check__c>([SELECT  Id, Task_Item__r.Name, Check_Number__c, Check_Amount__c, Date_Received__c, Date_Requested__c, Municipal_Agency_ID__c,
                                                           Requested_From__c, Task_Item__c, Account__c, isQueue__c, Follow_Up_Alert__c, Recipient_Reminder__c, Project_Roster__r.Name__c,
                                                           Task_Item__r.Project_Profile__c, Account__r.Name, Date_Check_Returned__c, Project_Roster__c, Internal__c, CreatedDate, Service_Item__r.Project_Profile__r.Project_Name__c,
                                                           Billing_Client__c, Billing_Contact__c, Description__c, Invoice_Payee__c, Reasone__c, Notes__c, Service_Item__r.Service_Name_Full__c,
                                                           Phase__c, Product_Name__c, Project_Address__c, Service_Item__c, OwnerId, Include_Estimated_Cost_Detail__c, Recipient_Reminder_Address__c,
                                                           Requested_Checks_Group__c, Service_Item__r.Project_Profile__r.Name, Service_Item__r.Project_Profile__c, Recipient_Reminder_Address_CC__c, Reminder_Body__c
                                                   FROM Check__c
                                                   WHERE Requested_Checks_Group__c =: groupNumbers AND Date_Requested__c != null AND Date_Received__c =: null AND
                                                         (Requested_From__c !=: CHARGE AND Requested_From__c !=: INTERNAL AND Requested_From__c != null) AND
                                                         Recipient_Reminder_Address__c != null AND Recipient_Reminder__c != null
                                                   ORDER BY CreatedDate ASC]);

        Map<Decimal, List<Check__c>> numberToChecks = new Map<Decimal, List<Check__c>>();

        for (Check__c check : checks) {
            if (!numberToChecks.containsKey(check.Requested_Checks_Group__c)) {
                numberToChecks.put(check.Requested_Checks_Group__c, new List<Check__c>());

            }
            numberToChecks.get(check.Requested_Checks_Group__c).add(check);

        }
        return numberToChecks;

    }

    /* ------------------------------------------- End DAO Methods -------------------------------------------------------------------*/
   //MRS-6274
    public static List<Check__c> filteredChecktWithChangeAccountCheckAmount(List<Check__c> newCheckList, Map<Id, Check__c> oldCheckMap){
        List<Check__c> filteredCheckList = new List<Check__c>();
        for (Check__c checkItem : newCheckList){
            if ( checkItem.Invoice_Payee__c != oldCheckMap.get(checkItem.Id).Invoice_Payee__c || checkItem.Check_Amount__c != oldCheckMap.get(checkItem.Id).Check_Amount__c ){
                filteredCheckList.add(checkItem);
            }
        }

        return filteredCheckList;
    }

    public static void validateChangeChangeAccountCheckAmount(List<Check__c> filteredCheckList){
        if (filteredCheckList.isEmpty()) return;

        Map<Id, Check__c> checkMap = new Map<Id, Check__c>(filteredCheckList);

        for ( Check__c checkItem : [SELECT Id, (Select Id From Reimbursable_Expense_Invoices__r Where FFA_PIN_Created__c = true Limit 1)
                                    FROM Check__c
                                    WHERE Id IN : filteredCheckList]){
            if ( !checkItem.Reimbursable_Expense_Invoices__r.isEmpty() ){
                checkMap.get(checkItem.Id).addError( String.format( CHECK_ERROR_UPDATE, new List<String>{checkMap.get(checkItem.Id).Description__c} ) );
            }
        }
    }

    public static void clearProcessingErrors( List<Check__c> newChecks ) {
        for( Check__c check : newChecks ) {
            if( !check.Processing_Error__c ) {
                check.Processing_Error_Message__c = '';
            }
        }
    }

}