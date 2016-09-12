public with sharing class PerformHourlyConsultingSubmitCont {
    public static String INVALID_TASK_ITEM = 'Invalid Task Item: ';
    public static String HOURS_REPORTED_NOW_IS_NOT_SPECIFIED = 'Hours Reported Now has not been specified or is invalid. Please do it before submit.';
    public static String HOURS_REPORTED_TOO_SMALL = 'Hours Reported Now value should be with increment not less than 0.05';
    public static String HOURS_REPORTED_NOW_EXCEEDED = 'You have exceeded the hours budgeted for this service. Please request a change order.';
    public static String ACTIVITY_DATE_IS_NOT_SPECIFIED = 'Activity Date has not been specified. Please do it before submit.';
    public static String ACTIVITY_NOTES_IS_NOT_SPECIFIED = 'Activity Notes has not been specified. Please do it before submit.';
    public static String PROJECT_IS_NOT_COMMITTED = 'Please Commit Project Plan before running of current Task.';
    public static String REQUEST_BILLABLE_HOURS_IS_NOT_COMMITTED = 'Request Billable Hours has not been specified. Please do it before submit.';
    public static String REASON_FOR_BILLABLE_HOURS_IS_NOT_COMMITTED = 'Reason For Billable Hours has not been specified. Please do it before submit.';
    public static String TYPE_OF_BILLABLE_HOURS_IS_NOT_COMMITTED = 'Type of Billable Hours has not been specified or is invalid. Please do it before submit.';
    public static String INVALID_PROJECT_ROLE = 'You have no permissions. Only assigned users to Project/Service/Task Item or users with expanded permissions have access to current record.';
    public static String HOURS_REPORTED_FOR_IS_EMPTY  = 'You should specify Hours Reported For field before submit.';
    public static String ANOTHER_USER_HAS_UPDATED = 'Another user has recently submitted hours for this task. Please check if your data is not interfering with these changes and submit your hours again.';

    public Decimal consultingHourBudget { get; set; }
    public Decimal workedToDate { get; set; }
    public Decimal hoursRemaining { get; set; }

    public Task_Item__c currentTaskItem { get; set; }

    public boolean isValidUser { get; set; }

    public boolean isValidStatus { get { return currentTaskItem != null &&
                                                currentTaskItem.Project_Profile__r.Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED &&
                                                currentTaskItem.Project_Profile__r.Project_State__c != ProjectProfileServices.PROJECT_STATE_ON_HOLD && //MRS-6683
                                                currentTaskItem.Service_Item__r.Status__c != ServiceItemServices.SERVICE_STATUS_INACTIVE && //MRS-6831
                                                currentTaskItem.Status__c == TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS; } }

    public boolean isValidSubmitStatus { get { return currentTaskItem != null &&
                                               currentTaskItem.Project_Profile__r.Project_State__c != ProjectProfileServices.PROJECT_STATE_CLOSED &&
                                               currentTaskItem.Project_Profile__r.Project_State__c != ProjectProfileServices.PROJECT_STATE_ON_HOLD && //MRS-6683
                                               currentTaskItem.Service_Item__r.Status__c != ServiceItemServices.SERVICE_STATUS_INACTIVE && //MRS-6831
                                               (currentTaskItem.Status__c == TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS || currentTaskItem.Status__c == TaskItemServices.TASK_ITEM_STATUS_COMPLETED); } }

    public boolean isExecutiveAdmin { get; set; }
    public boolean isStaffAccountant { get; set; }

    public PerformHourlyConsultingSubmitCont(ApexPages.StandardController controller){
        isValidUser = true;
        currentTaskItem = (Task_Item__c)controller.getRecord();

        getTaskItem();

        String userProfileName = UserServices.getProfile().Name;
        isExecutiveAdmin = ( userProfileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                             userProfileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                             userProfileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME );
        isStaffAccountant = ( userProfileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                              userProfileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                              userProfileName == UserServices.PROFILE_STAFF_ACCOUNTANT );
        getServiceForProject();
    }

    private void getTaskItem() {
        currentTaskItem = [ SELECT Consulting_Hour_Budget__c, Name, Consulting_Type__c, Type_of_Billable_Hours__c,
                                   Type_of_Billable_Hours_Template__c, Request_Billable_Hours__c, Region__c,
                                   Reason_for_Billable_Hours__c, Status__c, Actual_End_Date__c, Hours_Remaining__c,
                                   Service_Item__r.Quantity__c, Service_Item__r.Discounted_Unit_Price__c, Is_Locked__c, Project_Profile__r.Project_State__c,
                                   Project_Profile__r.Submitted_Planned_Dates__c, Project_Profile__r.Building__c,
                                   Project_Profile__r.Primary_Company_Contact__c, Project_Profile__r.Billing_Method__c,
                                   Project_Profile__r.Billing_Company_Contact__c, Project_Profile__r.Billing_Company_Name__c,
                                   Project_Profile__r.Accounting_Contact__c, Project_Profile__r.Accounting_Contact_Company__c,
                                   Service_Item__r.GLA_Product__r.Name, Service_Item__r.Phase__c, OwnerId, Manager_Lookup__c,
                                   Service_Item__r.Service_Name_Full__c, Service_Item__r.Purchase_Order__c, Service_Item__r.Status__c,
                                   Service_Item__r.Proposal__c, Project_Profile__c, Activity_Date__c, Hours_Reported_Now__c,
                                   Billing_Trigger__c, Hours_Reported_For__c, Id, Activity_Notes_Long__c, Worked_to_Date__c,
                                   Service_Item__c, Service_Item__r.Municipal_Agency_ID__c, Service_Item__r.Service_Group__c,
                                   Service_Item__r.Floor__c, Service_Item__r.OwnerId, Service_Item__r.Manager_Lookup__c,
                                   Project_Profile__r.Interval__c, Project_Name__c, Project_Number__c, GUID__c, Pre_billed__c,
                                   Service_Item__r.Proposal__r.Is_Change_Order__c, Service_Item__r.Proposal__r.Is_Floors_To_Services__c,
                                   Service_Item__r.Proposal__r.Reimbursable_Items_Basis__c, Service_Item__r.Proposal__r.Reimbursable_Percentage__c,
                                   Service_Item__r.Proposal__r.Apply_Discount__c, Service_Item__r.Proposal__r.Discount_Percentage__c
                            FROM Task_Item__c
                            WHERE Id = : currentTaskItem.Id ][0];
        initProperties();
    }

    private void initProperties() {
        consultingHourBudget = currentTaskItem.Consulting_Hour_Budget__c.setScale(2);
        workedToDate = currentTaskItem.Worked_to_Date__c = currentTaskItem.Worked_to_Date__c.setScale(2);
        hoursRemaining = currentTaskItem.Hours_Remaining__c.setScale(2);
    }

    public List<Task_Item__c> taskItemList {
        get {
            if( taskItemList == null ) {
                taskItemList = new List<Task_Item__c>();
            }
             return taskItemList;
        }
        set;
    }

    public Boolean reRenderParentPage { get { if ( reRenderParentPage == null ) reRenderParentPage = false; return reRenderParentPage; } set; }

    public void submit(){
        Savepoint sp = Database.setSavepoint();

        if ( isValidUser ){
            try {
                //MRS-6878

                Task_Item__c taskItemBeforeSubmit = currentTaskItem.clone(false, false, false, false);

                getTaskItem();

                currentTaskItem.Hours_Reported_Now__c  = taskItemBeforeSubmit.Hours_Reported_Now__c;
                currentTaskItem.Activity_Date__c       = taskItemBeforeSubmit.Activity_Date__c;
                currentTaskItem.Activity_Notes_Long__c = taskItemBeforeSubmit.Activity_Notes_Long__c;
                currentTaskItem.Hours_Reported_For__c  = taskItemBeforeSubmit.Hours_Reported_For__c;

                initProperties();

                Boolean hasErrors = false;
                if( !isExecutiveAdmin &&
                    !isStaffAccountant &&
                    !UserServices.isValidUserForProject( UserInfo.getUserId(), ProjectProfileServices.getProjectWithAssignmentsById( currentTaskItem.Project_Profile__c ),
                                                           currentTaskItem.OwnerId, currentTaskItem.Manager_Lookup__c, false, false ) ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, INVALID_PROJECT_ROLE ));
                    hasErrors = true;
                }
                if( !currentTaskItem.Project_Profile__r.Submitted_Planned_Dates__c ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, PROJECT_IS_NOT_COMMITTED ));
                    hasErrors = true;
                }
                if( currentTaskItem.Activity_Date__c == null ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ACTIVITY_DATE_IS_NOT_SPECIFIED ));
                    hasErrors = true;
                }
                if( String.isBlank( currentTaskItem.Activity_Notes_Long__c ) ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ACTIVITY_NOTES_IS_NOT_SPECIFIED ));
                    hasErrors = true;
                }
                if( isExecutiveAdmin && currentTaskItem.Hours_Reported_For__c == null ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, HOURS_REPORTED_FOR_IS_EMPTY));
                    hasErrors = true;
                }
                if( ( currentTaskItem.Hours_Reported_Now__c == null ) ||
                    ( currentTaskItem.Hours_Reported_Now__c != null && currentTaskItem.Hours_Reported_Now__c <= 0.00 ) ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, HOURS_REPORTED_NOW_IS_NOT_SPECIFIED ));
                    hasErrors = true;
                } else if( currentTaskItem.Hours_Reported_Now__c < 0.05 ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, HOURS_REPORTED_TOO_SMALL ));
                    hasErrors = true;
                } else if( taskItemBeforeSubmit.Hours_Remaining__c != hoursRemaining ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, ANOTHER_USER_HAS_UPDATED ));
                    hasErrors = true;
                } else if( currentTaskItem.Hours_Reported_Now__c > hoursRemaining ) {
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, HOURS_REPORTED_NOW_EXCEEDED ));
                    hasErrors = true;
                }
                if( hasErrors ) return;

                Billing_Line_Item__c billingLineItem = BillingLineItemServices.initBillingLineItem( null, currentTaskItem,
                    new Service_Item__c( Purchase_Order__c = currentTaskItem.Service_Item__r.Purchase_Order__c,
                                         Service_Name_Full__c = currentTaskItem.Service_Item__r.Service_Name_Full__c,
                                         Phase__c = currentTaskItem.Service_Item__r.Phase__c ),
                    new Project_Profile__c (
                        Id = currentTaskItem.Project_Profile__c,
                        Accounting_Contact_Company__c = currentTaskItem.Project_Profile__r.Accounting_Contact_Company__c,
                        Accounting_Contact__c = currentTaskItem.Project_Profile__r.Accounting_Contact__c,
                        Billing_Company_Name__c = currentTaskItem.Project_Profile__r.Billing_Company_Name__c,
                        Billing_Company_Contact__c = currentTaskItem.Project_Profile__r.Billing_Company_Contact__c,
                        Billing_Method__c = currentTaskItem.Project_Profile__r.Billing_Method__c,
                        Primary_Company_Contact__c = currentTaskItem.Project_Profile__r.Primary_Company_Contact__c,
                        Building__c = currentTaskItem.Project_Profile__r.Building__c
                    ), null );
                billingLineItem.Milestone_Date__c = currentTaskItem.Activity_Date__c;
                billingLineItem.Quantity__c = currentTaskItem.Hours_Reported_Now__c;
                billingLineItem.Product_Name__c = currentTaskItem.Service_Item__r.GLA_Product__r.Name;
                billingLineItem.isHourlyConsulting__c = true;
                if( currentTaskItem.Hours_Reported_For__c == null ){
                    billingLineItem.OwnerId = UserInfo.getUserId();
                } else {
                    billingLineItem.OwnerId = currentTaskItem.Hours_Reported_For__c;
                }

                if( currentTaskItem.Billing_Trigger__c && currentTaskItem.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE )  {
                    if (currentTaskItem.Pre_billed__c){ billingLineItem.Active_Billing_Line_Item__c = false; }
                    billingLineItem.Description__c = currentTaskItem.Activity_Notes_Long__c;
                    billingLineItem.Unit_Price__c = currentTaskItem.Service_Item__r.Discounted_Unit_Price__c;
                    billingLineItem.Amount__c = (billingLineItem.Unit_Price__c * billingLineItem.Quantity__c).setScale(2,System.RoundingMode.HALF_UP);
                } else if( currentTaskItem.Billing_Trigger__c && currentTaskItem.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !currentTaskItem.Project_Profile__r.Interval__c ) {
                    billingLineItem.Description__c = BillingLineItemServices.NON_BILLABLE_CONSULTING + currentTaskItem.Activity_Notes_Long__c;
                    billingLineItem.Active_Billing_Line_Item__c = false;
                    billingLineItem.Unit_Price__c = currentTaskItem.Service_Item__r.Discounted_Unit_Price__c;
                    billingLineItem.Amount__c = (billingLineItem.Unit_Price__c * billingLineItem.Quantity__c).setScale(2,System.RoundingMode.HALF_UP);
                } else {
                    billingLineItem.Description__c = BillingLineItemServices.NON_BILLABLE_CONSULTING + currentTaskItem.Activity_Notes_Long__c;
                    billingLineItem.Active_Billing_Line_Item__c = false;
                    billingLineItem.Unit_Price__c = 0;
                    billingLineItem.Amount__c = 0;
                }
                INSERT billingLineItem;

                if( billingLineItem.OwnerId != currentTaskItem.OwnerId ){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                    mail.setToAddresses( new String[] { UserServices.getUserById( currentTaskItem.Service_Item__r.OwnerId ).Email });
                    mail.setSenderDisplayName( 'Perform Hourly Consulting' );
                    mail.setSubject( 'Notification Email' );
                    mail.setPlainTextBody( 'This is a notification that ' +currentTaskItem.Hours_Reported_Now__c + ' hours have been submitted for task Item ' +  currentTaskItem.GUID__c + ', ' + currentTaskItem.Project_Name__c + ', '
                        + currentTaskItem.Project_Number__c + ' by ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '.' );

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }

                currentTaskItem.Worked_to_Date__c = ( workedToDate == null ) ? 0.00 : workedToDate;

                currentTaskItem.Worked_to_Date__c += currentTaskItem.Hours_Reported_Now__c;
                currentTaskItem.Status__c  = ( consultingHourBudget == currentTaskItem.Worked_to_Date__c || currentTaskItem.Actual_End_Date__c != null
                                                    ? TaskItemServices.TASK_ITEM_STATUS_COMPLETED
                                                    : ( currentTaskItem.Worked_to_Date__c > 0
                                                            ? TaskItemServices.TASK_ITEM_STATUS_IN_PROCESS
                                                            : TaskItemServices.TASK_ITEM_STATUS_NOT_STARTED ) );

                reRenderParentPage = true;
                Decimal hoursReportedNow = currentTaskItem.Hours_Reported_Now__c;
                currentTaskItem.Hours_Reported_Now__c = null;
                currentTaskItem.Activity_Date__c = null;
                currentTaskItem.Activity_Notes_Long__c = null;

                Boolean isLocked = ( consultingHourBudget == currentTaskItem.Worked_to_Date__c );

                //MRS-6398
                if (currentTaskItem.Billing_Trigger__c &&
                    currentTaskItem.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE &&
                    !currentTaskItem.Project_Profile__r.Interval__c &&
                    !currentTaskItem.Pre_billed__c &&
                    consultingHourBudget == hoursReportedNow){
                    isLocked = false;
                }

                UPDATE new Task_Item__c( Id = currentTaskItem.Id,
                                         /*Is_Locked__c = isLocked,*/
                                         Hours_Reported_For__c = null,
                                         Worked_to_Date__c = currentTaskItem.Worked_to_Date__c,
                                         Status__c = currentTaskItem.Status__c,
                                         Hours_Reported_Now__c = currentTaskItem.Hours_Reported_Now__c,
                                         Activity_Date__c = currentTaskItem.Activity_Date__c,
                                         Activity_Notes_Long__c = currentTaskItem.Activity_Notes_Long__c,
                                         Billing_Line_Item__c = billingLineItem.Id );
                getTaskItem();
            } catch ( dmlException dmlEx ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, dmlEx.getMessage()));
                DataBase.rollback(sp);

                return;
            }
        }
    }

    public transient List<Billing_Line_Item__c> billingLineItemList;
    public List<Billing_Line_Item__c> getBillingLineItemList() {
        if( currentTaskItem != null && String.isNotBlank(currentTaskItem.Id) ) {
            return BillingLineItemServices.getBillingLineItemListForTaskItemId(currentTaskItem.Id);
        } else {
            return new List<Billing_Line_Item__c>();
        }
    }

    private Decimal bilHours;
    private String requestReason;
    private Id requestedService;

    public void submitRequest() {
        Savepoint sp = Database.setSavepoint();
        PageReference pr;
        try {
            Boolean hasErrors = false;
            if( !UserServices.isValidUserForProject( UserInfo.getUserId(), ProjectProfileServices.getProjectWithAssignmentsById( currentTaskItem.Project_Profile__c ),
                                                     currentTaskItem.OwnerId, currentTaskItem.Manager_Lookup__c, false, false ) ) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, INVALID_PROJECT_ROLE ));
                hasErrors = true;
            }
            if( currentTaskItem.Request_Billable_Hours__c == null || ( currentTaskItem.Request_Billable_Hours__c != null && currentTaskItem.Request_Billable_Hours__c <= 0 ) ) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, REQUEST_BILLABLE_HOURS_IS_NOT_COMMITTED ));
                hasErrors = true;
            }
            if( String.isBlank( currentTaskItem.Reason_For_Billable_Hours__c ) ) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, REASON_FOR_BILLABLE_HOURS_IS_NOT_COMMITTED ));
                hasErrors = true;
            }
            if( currentTaskItem.Type_of_Billable_Hours__c == null ) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, TYPE_OF_BILLABLE_HOURS_IS_NOT_COMMITTED ));
                hasErrors = true;
            }

            if( hasErrors ) return;

            bilHours = currentTaskItem.Request_Billable_Hours__c;
            requestReason = currentTaskItem.Reason_For_Billable_Hours__c;
            requestedService = currentTaskItem.Type_of_Billable_Hours__c;

            currentTaskItem.Request_Billable_Hours__c = null;
            currentTaskItem.Reason_For_Billable_Hours__c = null;

            UPDATE new Task_Item__c( Id = currentTaskItem.Id,
                                     Request_Billable_Hours__c = currentTaskItem.Request_Billable_Hours__c,
                                     Reason_For_Billable_Hours__c = currentTaskItem.Reason_For_Billable_Hours__c,
                                     Type_of_Billable_Hours__c = currentTaskItem.Type_of_Billable_Hours__c );

            getTaskItem();

            createChangeOrderForBillableHours( currentTaskItem, bilHours, requestReason, requestedService );


        } catch ( Exception e ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            DataBase.rollback(sp);
            currentTaskItem.Request_Billable_Hours__c = bilHours;
            currentTaskItem.Reason_For_Billable_Hours__c = requestReason;
            currentTaskItem.Type_of_Billable_Hours__c = requestedService;
            return;
        }
    }

    public void getServiceForProject() {
        if( currentTaskItem != null && String.isNotBlank( currentTaskItem.id ) ) {
            taskItemList = [ SELECT Service_Item__r.Unit_of_Service__c,Service_Item__c, Name,
                                    Service_Item__r.Change_Order__r.Approved_Date__c,
                                    Project_Profile__c, Id, Service_Item__r.Service_Name_Full__c, Hours_Remaining__c
                             FROM Task_Item__c
                             WHERE Project_Profile__c = : currentTaskItem.Project_Profile__c
                                     AND Service_Item__r.Unit_of_Service__c = : ServiceItemServices.UNIT_OF_SERVICE_HOUR
                                     AND RecordType.Name = : TaskItemServices.PERFORM_HOURLY_CONSULTING_TASK_NAME
                                     AND Id != : currentTaskItem.Id
                                     AND ( ( Service_Item__r.Original__c = true AND Service_Item__r.Change_Order__c = null ) OR
                                           ( ( Service_Item__r.Change_Order__r.Approved_Date__c = null  AND Service_Item__r.Is_Amendmend_Added__c   = false ) OR
                                             ( Service_Item__r.Change_Order__r.Approved_Date__c != null AND Service_Item__r.Is_Amendmend_Deleted__c = false ) ) ) ];

        }
    }

    public void createChangeOrderForBillableHours( Task_Item__c taskItem, Decimal bilHours, String requestReason, Id requestedService ) {
        if( !taskItem.Service_Item__r.Proposal__r.Is_Change_Order__c ) {
            UPDATE new Proposal__c( Id = taskItem.Service_Item__r.Proposal__c, Is_Change_Order__c = true );
        }

        Change_Order__c newChangeOrder = new Change_Order__c( Proposal__c = taskItem.Service_Item__r.Proposal__c,
                                                              Project_Profile__c = taskItem.Project_Profile__c,
                                                              Status__c = ChangeOrderServices.STATUS_DRAFT,
                                                              Apply_Discount__c = taskItem.Service_Item__r.Proposal__r.Apply_Discount__c,
                                                              Discount_Percentage__c = taskItem.Service_Item__r.Proposal__r.Discount_Percentage__c,
                                                              Apply_Reimbursable__c = taskItem.Service_Item__r.Proposal__r.Reimbursable_Items_Basis__c,
                                                              Reimbursable_Percentage__c = taskItem.Service_Item__r.Proposal__r.Reimbursable_Percentage__c );
        INSERT newChangeOrder;

        Note proposalNote = new Note( Title = 'Change Order Reason' );
        proposalNote.ParentId = taskItem.Service_Item__r.Proposal__c;
        proposalNote.Body = requestReason;
        INSERT proposalNote;

        //Select Service Template
        //MRS-7530
        Service_Template__c serviceTemplate = ServiceItemServices.getServiceTemplateForServiceItem(new List<Id>{taskItem.Type_of_Billable_Hours_Template__c}, null)[0];


        Service_Item__c coServiceItem = ServiceItemServices.createNewServiceItemFromTemplate( serviceTemplate );
        coServiceItem.Quantity__c = bilHours;
        coServiceItem.Is_Alternative__c = false;
        coServiceItem.Is_Amendmend_Added__c = true;
        coServiceItem.Original__c = false;
        coServiceItem.Phase__c = taskItem.Service_Item__r.Phase__c;
        coServiceItem.Region__c = taskItem.Region__c;
        coServiceItem.Proposal__c = taskItem.Service_Item__r.Proposal__c;
        coServiceItem.Change_Order__c = newChangeOrder.Id;
        coServiceItem.Project_Profile__c = taskItem.Project_Profile__c;
        coServiceItem.Municipal_Agency_ID__c = taskItem.Service_Item__r.Municipal_Agency_ID__c;
        coServiceItem.Service_Group__c = taskItem.Service_Item__r.Service_Group__c;
        coServiceItem.Row_Position__c = 1;
        coServiceItem.Floor__c = taskItem.Service_Item__r.Floor__c;
        if(newChangeOrder.Apply_Discount__c) //MRS 6944
            coServiceItem.Discount_Percentage__c = taskItem.Service_Item__r.Proposal__r.Discount_Percentage__c;
        INSERT coServiceItem;

        if( taskItem.Service_Item__r.Proposal__r.Is_Floors_To_Services__c ) {
            List<Service_Floor_Junction__c> serviceFloorJunctionForInsertList = new List<Service_Floor_Junction__c>();

            for( Service_Floor_Junction__c serviceFloorJunctionItem : [ SELECT Id, Service_Item__c, Floor__c
                                                                        FROM Service_Floor_Junction__c
                                                                        WHERE Service_Item__c = : taskItem.Service_Item__c ] ) {
                serviceFloorJunctionForInsertList.add( new Service_Floor_Junction__c( Service_Item__c = coServiceItem.Id, Floor__c = serviceFloorJunctionItem.Floor__c ) );
            }

            insert serviceFloorJunctionForInsertList;
        }
    }
}