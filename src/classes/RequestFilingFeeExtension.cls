public with sharing class RequestFilingFeeExtension {

    /*check processing fee start */
    public transient Boolean isCheckProcessingFeeOptionAvailable;
    public Boolean getIsCheckProcessingFeeOptionAvailable() {
        Boolean isNeeded = false;
        DateTime lastCreatedDate;
        for( Check_Processing_Fee__c setting : Check_Processing_Fee__c.getall().values() ) {
            if( lastCreatedDate == null || setting.CreatedDate > lastCreatedDate ) {
                lastCreatedDate = setting.CreatedDate;
                isNeeded = setting.Charge_Check_Processing_Fee__c;
            }
        }
        return isNeeded;
    }

    public Boolean isCheckProcessingFeeOptionNeeded { get { if( isCheckProcessingFeeOptionNeeded == null ) isCheckProcessingFeeOptionNeeded = false; return isCheckProcessingFeeOptionNeeded; } set; }
    /*check processing fee end */

    @TestVisible
    private Set<Id> staffAccountantUserIds {
        get {
            if (null == this.staffAccountantUserIds) {
                this.staffAccountantUserIds = new Set<Id>();
                Map<Id, User> usersMap = new Map<Id, User>([SELECT Profile.Name, ProfileId, IsActive
                                                            FROM User
                                                            WHERE IsActive =: true AND (Profile.Name =: UserServices.PROFILE_STAFF_ACCOUNTANT OR Profile.Name =: UserServices.PROFILE_STAFF_ACCOUNTANT_QA)]);
                this.staffAccountantUserIds.addall(usersMap.keySet());
            }
            return this.staffAccountantUserIds;
        } set;
    }

    @TestVisible
    private List<Project_Roster__c> rosters {
        get {
            if (null == this.rosters) {
                this.rosters = ProjectRosterServices.getRosterByProjectId(this.project.Id);
            }
            return this.rosters;
        } set;
    }

    public Contact contactRecipient {
        get {
            if (null == this.contactRecipient) {
                this.contactRecipient = new Contact();
            }
            return this.contactRecipient;
        } set;
    }

    public Decimal amountRemaining {
        get {
            if (null == this.amountRemaining) {
                this.amountRemaining = DepositInvoiceServices.getRemainingAmountByProjectId(this.project.Id);
            }
            return this.amountRemaining;
        } set;
    }

    public String checkRequestId { get; set; }
    public Project_Profile__c project { get; set; }

    public String drawloopName { get { return CheckServices.REQUEST_CHECK_DRAWLOOP_NAME; } set; }
    public String emailTemplateName { get { return CheckServices.REQUEST_CHECK_TEMPLATE_NAME; } set; }
    public String draftTemplateName { get { return CheckServices.REQUEST_CHECK_TEMPLATE_NAME_DRAFT; } set; }
    public String rffEmailType { get { return MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL; } set; }

    public List<SelectOption> rostersSendTo {
        get {
            if (null == this.rostersSendTo) {
                this.rostersSendTo = new List<SelectOption>();
                this.rostersSendTo.add(new SelectOption ('', '-- None --'));
                for (Project_Roster__c roster : this.rosters) {
                    this.rostersSendTo.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c)); //MRS-6868
                }
            }
            return this.rostersSendTo;
        } private set;
    }

    public String additionalSubject {
        get {
            if (null == this.additionalSubject) {
                this.additionalSubject = '';
            }
            return this.additionalSubject;
        } private set;
    }

    @TestVisible
    private List<Check__c> checkRequested {
        get {
            if (null == this.checkRequested) {
                this.checkRequested = CheckServices.getChecksByProjectId(this.project.Id);
            }
            return this.checkRequested;
        } set;
    }

    @TestVisible
    private List<Check__c> checkTrackRequested {
        get {
            if (null == this.checkTrackRequested) {
                this.checkTrackRequested = CheckServices.getChecksByProjectId(this.project.Id);
            }
            return this.checkTrackRequested;
        } set;
    }

    @TestVisible
    private String bodyMail {
        get {
            if (null == this.bodyMail) {
                this.bodyMail = CheckServices.emailTemplate.HtmlValue.substring(CheckServices.emailTemplate.HtmlValue.indexOf('CDATA[') + 6, CheckServices.emailTemplate.HtmlValue.lastIndexOf(']]>'));
                if (this.bodyMail.contains('{receiver}')) {
                    List<Check__c> checks = getSelectedCheckRequest();
                    if (checks.isEmpty()) {
                        this.bodyMail = this.bodyMail.replace('{receiver}', '');
                    } else {
                        Check__c check = checks.get(0);
                        List<Project_Roster__c> rosters = ProjectRosterServices.getRostersByIds(new Set<Id> { check.Project_Roster__c });
                        if (rosters.isEmpty()) {
                            this.bodyMail = this.bodyMail.replace('{receiver}', '');
                        } else {
                            this.sendTo   = rosters.get(0).Name__c;
                            this.emailTo  = rosters.get(0).Email__c;
                            this.bodyMail = this.bodyMail.replace('{receiver}', rosters.get(0).Name_Full__c);
                        }
                    }
                }
                if (this.bodyMail.contains('{link}')) {
                    this.bodyMail = this.bodyMail.replace('{link}', '<a href="' + CheckServices.getForPayments(this.project.Name) + '">click here</a>');
                }
                if (this.bodyMail.contains('{phone}')) {
                    this.bodyMail = this.bodyMail.replace('{phone}', String.isBlank(CheckServices.loggedUser.Phone) ? 'none' : CheckServices.loggedUser.Phone);
                }
            }
            return this.bodyMail;
        } set;
    }

    @TestVisible
    private String textContext {
        get {
            if (null == this.textContext) {
                this.textContext = this.bodyMail.substring(0, this.bodyMail.indexOf('<table'));
            }
            return this.textContext;
        } set;
    }

    @TestVisible
    private String tableHeader {
        get {
            if (null == this.tableHeader) {
                this.tableHeader = this.bodyMail.substring(this.bodyMail.indexOf('<table'), this.bodyMail.lastIndexOf('</table>'));
            }
            return this.tableHeader;
        } set;
    }

    public String selectedInternalRequest { get; set; }
    public String subject { get; set; }
    public String editedTemplate { get; set; }

    public String sendTo { get; private set; }
    public String emailTo { get; private set; }
    public String sendCC { get; private set; }

    public Boolean reviewEmail { get; set; }

    public String loggedUserName { get { return UserInfo.getName(); } private set; }

    public List<SelectOption> options { get { if( null == this.options ) { this.options = CheckServices.getInternalRequestOptions(); } return this.options; } private set; }

    public List<CheckRequestWrapper> sendChecks {
        get {
            if (null == this.sendChecks) {
                this.sendChecks = new List<CheckRequestWrapper>();
                for (Check__c check : this.checkRequested) {
                    if (null == check.Date_Received__c) {
                        this.sendChecks.add(new CheckRequestWrapper(check));
                    }
                }
            }
            return this.sendChecks;
        } set;
    }

    public List<Check__c> trackSendChecks {
        get {
           this.trackSendChecks = new List<Check__c>();
            for (Check__c check : this.checkTrackRequested) {
                if (null != check.Date_Requested__c) {
                    this.trackSendChecks.add(check);
                }
            }
            return this.trackSendChecks;
        } set;
    }

    public String linkToCloseTemplate { get; private set; }

    public RequestFilingFeeExtension(ApexPages.StandardController controller) {
        this.project             = (Project_Profile__c)controller.getRecord();
        this.reviewEmail         = false;
        this.linkToCloseTemplate =  '/' + String.valueOf(this.project.Id);

    }

    public void selectInternalRequest() {
        if (String.isBlank(this.checkRequestId)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Empty Id.'));
            return;
        }
        for (CheckRequestWrapper checkWrap : this.sendChecks) {
            if (this.checkRequestId == checkWrap.check.Id) {
                checkWrap.check.Project_Roster__c = null;
                return;
            }
        }
    }

    public void sendInternalRequest() {
        List<Check__c> selectedChecks = new List<Check__c>();
        List<Task> tasks = new List<Task>();

        //Get Selected Check Requests
        for (CheckRequestWrapper item : this.sendChecks) {
            if (item.isSelected && null == item.check.Date_Received__c) {
                selectedChecks.add(item.check);
            }
        }

        if (selectedChecks.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_SELECT_CHECK_REQUEST));
            return;
        }

        //MRS-6274
        List<Check__c> eligibleChecks = new List<Check__c>();
        Map<Id, Check__c> selectedChecksMap = new Map<Id, Check__c>( selectedChecks );          // MRS 7052 
        for( Check__c checkItem : [ SELECT Id, Description__c, Internal__c, Reimbursable_Expense_Invoice__c, Reimbursable_Expense_Invoice__r.FFA_PIN_Created__c,
                                           ( SELECT Id, FFA_PIN_Created__c
                                             FROM Reimbursable_Expense_Invoices__r
                                             WHERE FFA_PIN_Created__c = true
                                             LIMIT 1 )
                                   FROM Check__c
                                   WHERE Id IN : selectedChecksMap.keySet() ] ) {       // MRS 7052
            if( !checkItem.Reimbursable_Expense_Invoices__r.isEmpty() || ( checkItem.Reimbursable_Expense_Invoice__c != null
                                                                        && checkItem.Reimbursable_Expense_Invoice__r.FFA_PIN_Created__c != null
                                                                        && checkItem.Reimbursable_Expense_Invoice__r.FFA_PIN_Created__c == true ) ) {
                ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, String.format( CheckServices.CHECK_ERROR_UPDATE, new List<String>{checkItem.Description__c} ) ) );
            } else {
                eligibleChecks.add( selectedChecksMap.get( checkItem.Id ) );
            }
        }

        if( eligibleChecks.isEmpty() ) {
            return;
        }

        if( this.selectedInternalRequest.equals( CheckServices.INTERNAL_STANDARD_REQUEST ) ) {
            for( Check__c check : eligibleChecks ) {
                check.Internal__c = true;
                check.Project_Roster__c = null;
                check.Date_Requested__c = datetime.now();
                check.isQueue__c = true;
                check.Requested_From__c = CheckServices.INTERNAL;
                check.Add_Check_Processing_Fee__c = isCheckProcessingFeeOptionNeeded;
            }
        }

        if( this.selectedInternalRequest.equals( CheckServices.INTERNAL_RUSH_REQUEST ) ) {
            Map<Id, List<String>> taskItemIdToComments = new Map<Id, List<String>>();
            Map<Id, List<String>> taskItemIdToRelatedRecords = new Map<Id, List<String>>();

            for (Check__c check :  eligibleChecks) {
                check.Internal__c = true;
                check.Project_Roster__c = null;
                check.Date_Requested__c = datetime.now();
                check.isQueue__c = true;
                check.Requested_From__c = CheckServices.INTERNAL;
                check.Add_Check_Processing_Fee__c = isCheckProcessingFeeOptionNeeded;

                if (!taskItemIdToComments.containsKey(check.Task_Item__c)) {
                    taskItemIdToComments.put(check.Task_Item__c, new List<String>());
                }
                taskItemIdToComments.get(check.Task_Item__c).add('"' + check.Account__r.Name + ' - ' + check.Check_Amount__c + '"');

                if (!taskItemIdToRelatedRecords.containsKey(check.Task_Item__c)) {
                    taskItemIdToRelatedRecords.put(check.Task_Item__c, new List<String>());
                }
                taskItemIdToRelatedRecords.get(check.Task_Item__c).add(check.Id);
            }

            tasks.addall(TaskServices.createTasksForStaffAccounts(this.staffAccountantUserIds,
                                                                  'Not Started',
                                                                  'High',
                                                                  datetime.now(),
                                                                  date.today(),
                                                                  CheckServices.INTERNAL_RUSH_REQUEST + ' - ' + this.project.Name + ' Interoffice Fee Request',
                                                                  taskItemIdToComments,
                                                                  taskItemIdToRelatedRecords));
        }

        if( this.selectedInternalRequest.equals( CheckServices.INTERNAL_CHARGED_TO_CORPORATE_CARD ) ) {
            //6274
            List<Reimbursable_Expense_Invoice__c> reimbursableExpenseInvoiceList = [SELECT Id, FFA_PIN_Created__c, Check_Request__c
                                                                                    FROM Reimbursable_Expense_Invoice__c
                                                                                    WHERE Check_Request__c IN : eligibleChecks];

            Map<Id, List<Reimbursable_Expense_Invoice__c>> checkWithReimbursableExpenseInvoiceMap = new Map<Id, List<Reimbursable_Expense_Invoice__c>>();

            for (Reimbursable_Expense_Invoice__c reimbursableExpenseInvoiceItem : reimbursableExpenseInvoiceList){
                if (checkWithReimbursableExpenseInvoiceMap.containsKey(reimbursableExpenseInvoiceItem.Check_Request__c)){
                    checkWithReimbursableExpenseInvoiceMap.get(reimbursableExpenseInvoiceItem.Check_Request__c).add(reimbursableExpenseInvoiceItem);
                } else {
                    checkWithReimbursableExpenseInvoiceMap.put(reimbursableExpenseInvoiceItem.Check_Request__c, new List<Reimbursable_Expense_Invoice__c>{reimbursableExpenseInvoiceItem});
                }
            }

            List<Account> americaExpress = AccountServices.getAmericanExpressAccount();
            List<Reimbursable_Expense_Invoice__c> reimbInvoices = new List<Reimbursable_Expense_Invoice__c>();
            Reimbursable_Expense_Invoice__c reimburExpense;

            List<Check__c> checkListUpdate = new List<Check__c>();

            for (Check__c check :  eligibleChecks) {
                Boolean isValidCheckForUpdate = true;
                check.Internal__c       = true;
                check.Project_Roster__c = null;
                check.Date_Requested__c = datetime.now();
                check.Requested_From__c = CheckServices.CHARGE;
                check.Add_Check_Processing_Fee__c = isCheckProcessingFeeOptionNeeded;

                if (!americaExpress.isEmpty()) {
                    check.Invoice_Payee__c = americaExpress.get(0).Id;
                    if ( checkWithReimbursableExpenseInvoiceMap.containsKey(check.Id) && !checkWithReimbursableExpenseInvoiceMap.get(check.Id).isEmpty() ){
                        //6274
                        for (Reimbursable_Expense_Invoice__c reimbursableExpenseInvoiceItem : checkWithReimbursableExpenseInvoiceMap.get(check.Id)){
                            if (reimbursableExpenseInvoiceItem.FFA_PIN_Created__c){
                                isValidCheckForUpdate = false;
                                break;
                            }
                        }
                        if (isValidCheckForUpdate) {
                            reimburExpense = ReimbursableExpenseInvoiceServices.pupolatedReimbursableExpenseInvoiceFiled(check, this.project.Id, checkWithReimbursableExpenseInvoiceMap.get(check.Id)[0]);
                        }
                    } else {
                        reimburExpense = ReimbursableExpenseInvoiceServices.newInstance(check, this.project.Id);
                    }
                    if (isValidCheckForUpdate){
                        reimburExpense.Invoice_Display_Name__c = check.Account__r.Name;
                        reimbInvoices.add(reimburExpense);
                    }
                } else {
                    check.isQueue__c = true;
                }
                if (isValidCheckForUpdate) {checkListUpdate.add(check);}
            }
            if (!reimbInvoices.isEmpty()) {
                upsert reimbInvoices;
            }

            selectedChecks = checkListUpdate;
            CheckServices.updateCheckExpenseInvoice(reimbInvoices, selectedChecks);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            insert tasks;
            CheckServices.updateCheck(selectedChecks);
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        } finally {
            this.checkTrackRequested = null;
            this.trackSendChecks = null;
            this.checkRequested = null;
            this.sendChecks = null;
        }

    }

    public void updateSendCheckRequests() {
        try {
            List<Check__c> checksToUpdate = new List<Check__c>();
            for (CheckRequestWrapper check : this.sendChecks) {
                checksToUpdate.add(check.check);
            }
            CheckServices.updateCheck(checksToUpdate);
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        } finally {
            this.checkTrackRequested = null;
            this.trackSendChecks = null;
        }
    }

    public void updateTrackSendCheckRequests() {
       try {
            CheckServices.updateCheck(this.trackSendChecks);
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        } finally {
            this.checkRequested = null;
            this.sendChecks = null;
        }
    }

    /* Begin Email Review */
    @TestVisible
    private List<Check__c> getSelectedCheckRequest() {
        List<Check__c> checks = new List<Check__c>();
        for (CheckRequestWrapper item : this.sendChecks) {
            if (item.isSelected && null == item.check.Date_Received__c) {
                checks.add(item.check);
            }
        }
        return checks;
    }

    public List<String> sentEmailBodyValue{get{if (sentEmailBodyValue == null){sentEmailBodyValue = new List<String>();} return sentEmailBodyValue;}set;}//MRS-7494

    public void displayEmailPreview() {
        //Checking if recipient is Contact
        for (Check__c check : getSelectedCheckRequest()) {
            List<Project_Roster__c> rosters = ProjectRosterServices.getRostersByIds(new Set<Id> { check.Project_Roster__c });
            if ( rosters.isEmpty() || null == rosters.get(0).Contact__c || null == rosters.get(0).Email__c ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
                return;
            } else {
                this.contactRecipient.Id = rosters.get(0).Contact__c;
                break;
            }
        }

        Integer countRoster = 0;
        Set<Id> rosterIds = new Set<Id>();
        Map<Id, Id> checkRequestIdToServiceItemId = new Map<Id, Id>();
        Map<Id, Check__c> checkRequestIdToCheckRequest = new Map<Id, Check__c>();

        for( CheckRequestWrapper item : this.sendChecks ) {
            if (item.isSelected && null == item.check.Date_Received__c) {
                this.additionalSubject += item.check.Id + ';';
                if (item.check.Internal__c) {
                    ApexPages.addMessage( new ApexPages.message(ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_ONE_ONLY_INTERNAL ) );
                    return;
                }
                countRoster += ( null != item.check.Project_Roster__c ) ? 1 : 0;
                rosterIds.add( item.check.Project_Roster__c );
                checkRequestIdToCheckRequest.put( item.check.Id, item.check );
                checkRequestIdToServiceItemId.put( item.check.Id, item.check.Service_Item__c );
            }
        }

        if( checkRequestIdToCheckRequest.keySet().isEmpty() ) {
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_SELECT_CHECK_REQUEST ) );
            return;
        }

        if( countRoster != checkRequestIdToCheckRequest.keySet().size() ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_SPECIFY_CONTACT ) );
            return;
        }

        rosterIds.remove( null );
        if( rosterIds.size() > 1 ) {
            Set<String> contactNames = new Set<String>();
            for( Project_Roster__c rosterName : ProjectRosterServices.getRostersByIds( rosterIds ) ) {
                contactNames.add( rosterName.Name__c );
            }
            contactNames.remove( null );
            if( contactNames.size() > 1 ) {
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_ONE_CONTACT_FOR_REQUEST ) );
                return;
            }
        }
        //MRS-6274
        String errorString = '';
        List<Check__c> eligibleChecks = new List<Check__c>();
        for( Check__c checkItem : [ SELECT Id, Description__c, Internal__c, Service_Item__c,
                                           ( SELECT Id, FFA_PIN_Created__c
                                             FROM Reimbursable_Expense_Invoices__r
                                             WHERE FFA_PIN_Created__c = true
                                             LIMIT 1 )
                                    FROM Check__c
                                    WHERE Id IN : checkRequestIdToCheckRequest.keySet() ] ) {
            if( !checkItem.Reimbursable_Expense_Invoices__r.isEmpty() ) {
                ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, String.format( CheckServices.CHECK_ERROR_UPDATE, new List<String>{checkItem.Description__c} ) ) );
                checkRequestIdToServiceItemId.remove( checkItem.Id );
            } else {
                eligibleChecks.add( checkRequestIdToCheckRequest.get( checkItem.Id ) );
            }
        }

        if( eligibleChecks.isEmpty() ) {
            return;
        }

        List<RFI_Work__c> rfiWorkTypes = RFIWorkTypeServices.getWorkTypeByServiceItemIds( new Set<Id>( checkRequestIdToServiceItemId.values() ) );

        Integer order = 1;
        this.editedTemplate = this.textContext;
        for( Check__c item : eligibleChecks ) {
            this.editedTemplate += '<table>' + this.tableHeader + CheckServices.checkRow(order++, item) + '</table> <br />';
            if (item.Include_Estimated_Cost_Detail__c) {
                this.editedTemplate += CheckServices.workTypeTable(item, rfiWorkTypes);
            }
        }

        Set<Id> parentDocumentSetIds = new Set<Id>();
        for( Check__c checkItem : eligibleChecks ) {
            parentDocumentSetIds.add(checkItem.Task_Item__c);
            parentDocumentSetIds.add(checkItem.Task_Item__r.Service_Item__c);
        }
        parentDocumentSetIds.add(this.project.Id);
        parentDocumentSetIds.add(this.project.Proposal__c);
        parentDocumentSetIds.addAll(new Map<Id, RFI_Scope__c>([SELECT Id FROM RFI_Scope__c WHERE Project__c = : this.project.Id]).KeySet());
        parentDocumentSetIds.remove(null);
        this.parentDocumentIds = new List<Id>();
        this.parentDocumentIds.addAll(parentDocumentSetIds);

        this.editedTemplate += String.format(CheckServices.EXTERNAL_LINK_FOR_NYC, new List<String>{this.project.Name,
                                                                                                   this.project.Project_Name__c,
                                                                                                   (String.isBlank(CheckServices.loggedUser.Phone)) ? 'none' : CheckServices.loggedUser.Phone});

        this.reviewEmail = true;

        try {
            this.project.EmailToRfi__c   = this.emailTo;
            this.project.EmailToCCRfi__c = '';
            update this.project;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        } finally {
            this.checkTrackRequested = null;
            this.trackSendChecks = null;
            this.bodyMail    = null;
            this.textContext = null;
            this.tableHeader = null;
        }
    }

    //prepare attachment section
    public List<Id> parentDocumentIds { get { if ( parentDocumentIds == null ) { parentDocumentIds = new List<Id>(); } return parentDocumentIds; } set; }
    /* End Email Review */

    /* Begin callback */
    public String emailsAddressForDrawLoop { get; set; }
    public Datetime reminderDatetime { get; set; }

    public void updateCCEmailsAddressForDrawLoop() {
        try {
            this.project.EmailToCCRfi__c = this.emailsAddressForDrawLoop;
            update this.project;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;
        }
    }

    public void updateAfterSend() {
        try {
            Datetime currentTime = datetime.now();
            List<Check__c> checkRequest = getSelectedCheckRequest();
            AggregateResult[] groupedResults  = [SELECT MAX(Requested_Checks_Group__c)aver FROM Check__c WHERE Requested_Checks_Group__c !=: null];
            Decimal nextGroupNumber = (Decimal)groupedResults[0].get('aver') + 1;
            String ccAddress = ProjectProfileServices.getProjectById(this.project.Id).EmailToCCRfi__c;

            //MRS-6274
            List<Reimbursable_Expense_Invoice__c> reimbursableExpenseInvoiceList = [ SELECT Id, FFA_PIN_Created__c, Check_Request__c
                                                                                     FROM Reimbursable_Expense_Invoice__c
                                                                                     WHERE Check_Request__c IN : checkRequest
                                                                                       AND FFA_PIN_Created__c = false ];

            Map<Id, List<Reimbursable_Expense_Invoice__c>> checkWithReimbursableExpenseInvoiceMap = new Map<Id, List<Reimbursable_Expense_Invoice__c>>();

            for (Reimbursable_Expense_Invoice__c reimbursableExpenseInvoiceItem : reimbursableExpenseInvoiceList){
                if (checkWithReimbursableExpenseInvoiceMap.containsKey(reimbursableExpenseInvoiceItem.Check_Request__c)){
                    checkWithReimbursableExpenseInvoiceMap.get(reimbursableExpenseInvoiceItem.Check_Request__c).add(reimbursableExpenseInvoiceItem);
                } else {
                    checkWithReimbursableExpenseInvoiceMap.put(reimbursableExpenseInvoiceItem.Check_Request__c, new List<Reimbursable_Expense_Invoice__c>{reimbursableExpenseInvoiceItem});
                }
            }

            List<Reimbursable_Expense_Invoice__c> reimbursableExpenseInvoiceDeleteList = new List<Reimbursable_Expense_Invoice__c>();

            for (Check__c item : checkRequest) {
                item.Date_Requested__c         = currentTime;
                item.Requested_From__c         = this.sendTo;
                item.Requested_Checks_Group__c = nextGroupNumber;
                item.Send_Reminder__c          = false;
                if (null != reminderDatetime) {
                    item.Recipient_Reminder__c         = reminderDatetime;
                    item.Recipient_Reminder_Address__c = ProjectRosterServices.getRostersByIds(new Set<Id> { item.Project_Roster__c }).get(0).Email__c;
                    item.Reminder_Body__c              = sentEmailBodyValue != null && !sentEmailBodyValue.isEmpty() ? sentEmailBodyValue[sentEmailBodyValue.size() - 1] : null;//MRS-7494
                }

                if (!String.isBlank(ccAddress)) {
                    item.Recipient_Reminder_Address_CC__c = ccAddress;
                }
                //MRS-6274
                if (!item.Internal__c){
                    if (checkWithReimbursableExpenseInvoiceMap.containsKey(item.Id) && !checkWithReimbursableExpenseInvoiceMap.get(item.Id).isEmpty()){
                        reimbursableExpenseInvoiceDeleteList.addAll( checkWithReimbursableExpenseInvoiceMap.get(item.Id) );
                    }
                }
            }
            CheckServices.updateCheck(checkRequest);

            //MRS-6274
            DELETE reimbursableExpenseInvoiceDeleteList;
        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception occured during seding email: ' + ex.getMessage()));
            return;
        } finally {
            this.reviewEmail = false;
            this.checkTrackRequested = null;
            this.trackSendChecks = null;
            this.checkRequested = null;
            this.sendChecks = null;
            this.sentEmailBodyValue = new List<String>();
        }
    }
    /* End Callback  */
}