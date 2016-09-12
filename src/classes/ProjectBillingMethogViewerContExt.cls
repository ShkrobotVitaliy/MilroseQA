public with sharing class ProjectBillingMethogViewerContExt {
    private Boolean isInit                  = false;
    private Boolean isChangedIntervalNumber = false;
    private Decimal billedPercentage        = 0;
    private Integer numberBilledInterval    = 0;

    private Map<Integer, Date> countSteps                = new Map<Integer, Date>();
    private List<Billing_Date__c> billingDateToRemove    = new List<Billing_Date__c>();
    private List<Billing_Date__c> billingDatesForDisplay = new List<Billing_Date__c>();

    public transient Map<Id, Task_Item__c> taskItemStaticData; //reducing viewstate
    public Map<Id, Task_Item__c> getTaskItemStaticData() {
        Map<Id, Task_Item__c> taskItemIdToTaskItem;
        Set<Id> taskItemIds = new Set<Id>();
        if( servicesIdToTaskItemListMap != null ) {
            for( List<TaskItemModel> taskItems : servicesIdToTaskItemListMap.values() ) {
                if( taskItems != null ) {
                    for( TaskItemModel taskItem : taskItems ) {
                        taskItemIds.add( taskItem.id );
                    }
                }
            }
        }
        taskItemIdToTaskItem = new Map<Id, Task_Item__c>( [ SELECT Name, Is_Locked__c
                                                            FROM Task_Item__c
                                                            WHERE Id IN : taskItemIds ] );
        return taskItemIdToTaskItem;
    }

    public transient Map<Id, Service_Item__c> serviceStaticData;
    public Map<Id, Service_Item__c> getServiceStaticData() {
        return ServiceItemServices.getServiceItemsByProjectId( this.project.Id );
    }

    public Integer numberInterval {
        get {
            if (null == this.numberInterval) {
                this.numberInterval = 0;

            }
            return this.numberInterval;

        }
        set;
    }

    public Project_Profile__c project {
        get {
            if (null == this.project) {
                this.project = new Project_Profile__c();

            }
            return this.project;

        }
        set;
    }

    public Boolean datesBlocked { get { return project.Billing_Dates_Blocked__c; } } //MRS-4966

    public List<BillingDateWrapper> billingDateWrapperList {
        get {
            if (null == this.billingDateWrapperList) {
                this.billingDateWrapperList = new List<BillingDateWrapper>();

            }
            return this.billingDateWrapperList;

        }
        set;
    }

    public Boolean isRenderedPrice {
        get {
            if(null == this.isRenderedPrice) {
                this.isRenderedPrice = !UserServices.getProfile().Name.contains(UserServices.PROFILE_CODE_ZONING_ANALYST);

            }
            return this.isRenderedPrice;

        }
        private set;

    }

    public Boolean commandButtonApply {
        get {
            if(null == this.commandButtonApply) {
                this.commandButtonApply = !UserServices.getProfile().Name.equals(UserServices.PROFILE_BILLING_COORDINATOR);

            }
            return this.commandButtonApply;

        }
        private set;

    }

    public String billingMethodSelectedString {
        get{
            if (null == this.billingMethodSelectedString) {
                this.billingMethodSelectedString = project.Billing_Method__c;

            }
            return this.billingMethodSelectedString;

        }
        set;

    }

    public Boolean isInterval {
        get{
            if (null == this.isInterval) {
                this.isInterval = project.Interval__c;

            }
            return this.isInterval;

        }
        set;
    }

    public Boolean isMilestone {
        get{
            return billingMethodSelectedString.equals(ProjectProfileServices.BILLINGMETHODMILESTONE);
        }
    }

    public Boolean isInstallment {
        get{
            return billingMethodSelectedString.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT);
        }
    }

    public Boolean isPercentage {
        get{
            return billingMethodSelectedString.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE);
        }
    }

    public Map<Id, List<TaskItemModel>> servicesIdToTaskItemListMap {
        get{
            if (null == this.servicesIdToTaskItemListMap) {
                this.servicesIdToTaskItemListMap = new Map<Id, List<TaskItemModel>>();

            }
            return this.servicesIdToTaskItemListMap;

        }
        private set;

    }

    public Map<Id,String> serviceItemIdToServiceItemNameMap {
        get{
            if (null == this.serviceItemIdToServiceItemNameMap) {
                this.serviceItemIdToServiceItemNameMap = new Map<Id, String>();

            }
            return this.serviceItemIdToServiceItemNameMap;

        }
        private set;

    }

    public Map<Id,Decimal> totalPercentageTaskItemForServiceItemMap {
        get{
            if (null == this.totalPercentageTaskItemForServiceItemMap) {
                this.totalPercentageTaskItemForServiceItemMap = new Map<Id, Decimal>();

            }
            return this.totalPercentageTaskItemForServiceItemMap;

        }
        private set;

    }

    public Decimal totalPercentageTaskItems {
        get{
            if (null == this.totalPercentageTaskItems) {
                this.totalPercentageTaskItems = 0;

            }
            return this.totalPercentageTaskItems;

        }
        set;
    }

	public String profileName { get; set; } // MRS 7365
	public Boolean userHasPermission { get; set; }
	public Boolean isVisible { get; set; } //MRS 7593

    public ProjectBillingMethogViewerContExt(ApexPages.StandardController stdController) {
        if (Test.isRunningTest()){
            this.project = (Project_Profile__c)stdController.getRecord();
            this.project = [SELECT Id, Billing_Method__c, Interval__c, Billing_day__c, Frequency__c, Total_Service_Amount__c, Expected_Construction_Start_Date__c,
                                Expected_Construction_End_Date__c, Quarterly_Month__c, Project_Start_Date__c, Billing_End_Date__c, Number_Of_Intervals__c,
                                Discounted_Total_Service_Amount__c, Billing_Dates_Blocked__c, Cost__c
                            FROM Project_Profile__c
                            WHERE Id =: project.Id];
        } else{
            stdController.addFields( new List<String>{ 'Billing_Method__c', 'Interval__c', 'Billing_day__c', 'Frequency__c',
                                                       'Total_Service_Amount__c', 'Expected_Construction_Start_Date__c',
                                                       'Expected_Construction_End_Date__c', 'Quarterly_Month__c',
                                                       'Project_Start_Date__c', 'Billing_End_Date__c', 'Number_Of_Intervals__c',
                                                       'Discounted_Total_Service_Amount__c', 'Billing_Dates_Blocked__c', 'Cost__c' } );
            this.project = (Project_Profile__c)stdController.getRecord();
        }

		profileName = [ SELECT Name FROM Profile WHERE Id = : UserInfo.getProfileId() LIMIT 1 ][0].Name; // MRS 7365 7535
        CustomPermissionsReviewBillableServ__c customPermissionsRevBillableServ = CustomPermissionsReviewBillableServ__c.getValues(UserInfo.getName());
		userHasPermission = (customPermissionsRevBillableServ != null && (Id.valueOf(customPermissionsRevBillableServ.Id__c) == UserInfo.getUserId()) )
								|| profileName == UserServices.PROFILE_ACCOUNT_MANAGER
								|| profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR
								|| profileName == UserServices.PROFILE_FINANCE_MANAGER
								|| profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST
								|| profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN
								|| profileName == UserServices.PROFILE_STAFF_ACCOUNTANT
								|| profileName == UserServices.SYSTEM_ADMINISTRATOR; //MRS 7593

		isVisible = (customPermissionsRevBillableServ != null && (Id.valueOf(customPermissionsRevBillableServ.Id__c) == UserInfo.getUserId()) )
								|| profileName == UserServices.PROFILE_ACCOUNT_MANAGER
								|| profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR
								|| profileName == UserServices.PROFILE_FINANCE_MANAGER
								|| profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST
								|| profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN
								|| profileName == UserServices.PROFILE_STAFF_ACCOUNTANT
								|| profileName == UserServices.SYSTEM_ADMINISTRATOR
								|| profileName == UserServices.PROFILE_A_R_CORDINATOR
								|| profileName == UserServices.PROFILE_CFO
								|| profileName == UserServices.PROFILE_COO
								|| profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS
								|| profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME
								|| profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER
								|| profileName == UserServices.SUPPORT_STAFF;

		//MilroseDevHelper.addMessage( 'You are not allowed to perform actions on this page.' );
    }

    public void init(){
        if (this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT) && null == this.project.Project_Start_Date__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ErrorException.PROJECT_START_DATE_EMPTY));
            return;

        }
        this.isInit = true;
        fillServicesIdToTaskItemListMap();
        selectBillingMethodAction();

    }

    //Methods
    private void totalPercentageTaskItemForServiceItem(String Id) {
        Decimal amount = 0;

        if (this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODMILESTONE)) {

            for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(Id)) {
                if (taskItemMod.isBillable && !String.isBlank(taskItemMod.Percentage)) {
                    amount += Decimal.valueOf(taskItemMod.Percentage);

                }

            }
            totalPercentageTaskItemForServiceItemMap.put(Id, amount);

        } else if (this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE) && !this.project.Interval__c) {
            for (Id serviceItemId : servicesIdToTaskItemListMap.keySet()) {
                for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
                    if (taskItemMod.isBillable && !String.isBlank(taskItemMod.Percentage)) {
                        amount += Decimal.valueOf(taskItemMod.Percentage);

                    }

                }

            }
            totalPercentageTaskItems = amount;

        }

    }

    public Map<Id,Decimal> idTaskToBilledBLIAmount {
        get{
            if (null == this.idTaskToBilledBLIAmount) {
                this.idTaskToBilledBLIAmount = new Map<Id, Decimal>();

            }
            return this.idTaskToBilledBLIAmount;

        }
        private set;

    }

    private void fillServicesIdToTaskItemListMap(){
        TaskItemModel taskMod;
        Boolean isLockedTaskItem;
        Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount;
        Map<String, Decimal> amountTypeToAmount;
        Decimal unBilledAmount;

        //MRS-7260
        if( isPercentage && !isInterval ){
            projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( new Set<Id>{ this.project.Id }, false );
            amountTypeToAmount = projectIdToAmountTypeToAmount.get( this.project.Id );

            for( Billing_Line_Item__c item: [Select Id, Task_Item__c, Amount__c
                                            From Billing_Line_Item__c
                                            Where Project_Profile__c =: this.project.Id
                                                AND Active_Billing_Line_Item__c = true
                                                AND Department_Based__c = false
                                                AND Task_Item__c != null
                                                AND isReimbursable__c = false
                                                AND Amount__c > 0] ){

                idTaskToBilledBLIAmount.put( item.Task_Item__c, item.Amount__c );
            }
        }

        for( Service_Item__c serviceItem : ServiceItemServices.getServiceItemsWithTaskItemsByProjectId( this.project.Id ).values() ) {
            String serviceDisplayName = serviceItem.Name + ' - ';

            //String serviceNumbersForWorktypes = ServiceItemServices.getServiceNumbersToShowShortNameAndWorktype(); //+MRS-6586 //-MRS-7053
            if( /*serviceItem.Region__c == RegionServices.REGION_NAME_NY &&
                serviceItem.Service_Template_Row__c != null && serviceNumbersForWorktypes.contains( serviceItem.Service_Template_Row__c + ';' ) */ //+MRS-6586 //-MRS-7053
                serviceItem.Custom_Work_Type_Service__c ) {
                serviceDisplayName += serviceItem.Short_Service_Name_Worktype__c;
            } else {
                serviceDisplayName += ( serviceItem.Service_Name_Short__c != null ? serviceItem.Service_Name_Short__c : serviceItem.Service_Name_Full__c );
            }
            serviceItemIdToServiceItemNameMap.put( serviceItem.Id, serviceDisplayName );
            servicesIdToTaskItemListMap.put(serviceItem.Id, new List<TaskItemModel>() );

            List<TaskItemModel> timeModelTempList = new List<TaskItemModel>();
            isLockedTaskItem = false;

            for (Task_Item__c taskItem : serviceItem.Task_Items__r) {
                if (taskItem.Billing_Trigger__c) {
                    isLockedTaskItem = true;
                    break;

                }
            }

            for (Task_Item__c taskItem : serviceItem.Task_Items__r) {
				Decimal taskItemAmount = 0;
				if( isPercentage && !isInterval && taskItem.Billing_Percentage__c != null && amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) != 0 ) taskItemAmount = ( ( taskItem.Billing_Percentage__c / amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) ) *
                                                  										   ( this.project.Discounted_Total_Service_Amount__c - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) ) ).setScale(2);
                timeModelTempList = servicesIdToTaskItemListMap.get( serviceItem.Id );
                if( idTaskToBilledBLIAmount.get(taskItem.Id) != null ){
                    taskMod = new TaskItemModel( taskItem, this.project, isLockedTaskItem, idTaskToBilledBLIAmount.get(taskItem.Id) );
                }else{
                    taskMod = new TaskItemModel( taskItem, this.project, isLockedTaskItem, taskItemAmount );
                }
                taskMod.totalServicePrice = serviceItem.Total_Service_Price__c;
                timeModelTempList.add( taskMod );
                servicesIdToTaskItemListMap.put( serviceItem.Id, timeModelTempList );

            }
            totalPercentageTaskItemForServiceItem(serviceItem.Id);
        }

    }

    public void apply(){
        if (isPercentage && !isInterval && totalPercentageTaskItems > 100) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, Label.PROJECT_TASKS_PERCENTAGE_CAN_NOT_EXCEED_100) );
            return;
        }

        if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE) && this.project.Interval__c) {

            if (null != this.billingDateWrapperList && !this.billingDateWrapperList.isEmpty() && BillingDateServices.checkTotalsPercentage(this.billingDateWrapperList)) {
                List<Billing_Date__c> billindateList = new List<Billing_Date__c>();

                for (BillingDateWrapper billindate : this.billingDateWrapperList) {
                    if(billindate.bd.Percentage__c > 0) {
                        billindateList.add(billindate.bd);
                    }

                }
                this.project.Number_Of_Intervals__c = this.numberInterval;

                Savepoint sp = Database.setSavepoint();
                try {
                    if (!billingDateToRemove.isEmpty()) {
                        delete this.billingDateToRemove;
                        this.billingDateToRemove.clear();

                    }

                    BillingDateServices.isChangedNumberInterval = true;
                    update this.project;
                    upsert billindateList;

                } catch (DMLException ex) {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Billing Date was not updated: ' + ex.getDmlMessage(0)));

                }

                if (!this.isInit) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Changes that have been made will affect the entire project. Please refresh the page to update the system data.'));

                }

            }

        }

        if (this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODMILESTONE)) {
            if (isValidMilestone()) {
                try {
                    upsert updateTaskItems();
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, 'Task Items have been updated successfully.' ) );

                } catch( DMLException dmlEx ){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Task Items was not updated: ' + dmlEx.getDmlMessage( 0 ) ) );

                }
            }
        }

        if (this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE) && !this.project.Interval__c) {
            if (isValidPercentage()) {
                try{
                    upsert updateTaskItems();
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.CONFIRM, 'Task Items were updated successfully.' ) );

                } catch( DMLException dmlEx ){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Task Items were not updated: ' + dmlEx.getDmlMessage( 0 ) ) );

                }
            }
        }
		servicesIdToTaskItemListMap = null; //MRS 7525
		fillServicesIdToTaskItemListMap();
    }

    public List<Task_Item__c> updateTaskItems() {
        List<Task_Item__c> updateTaskItemList = new List<Task_Item__c>();
        Task_Item__c taskItem                 = new Task_Item__c();
        Boolean isLockedTaskItem              = false;

        for (Id serviceItemId : servicesIdToTaskItemListMap.keySet()) {
            for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
                if (taskItemMod.isBillable) {
                    isLockedTaskItem = true;
                    break;
                }
            }

            for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
                taskItem = new Task_Item__c(Id = taskItemMod.Id, Billing_Trigger__c = taskItemMod.isBillable);
                taskItemMod.isLockedTaskItem = isLockedTaskItem;

                //MRS-7513 sets 0, MRS-7520 sets null
                taskItem.Billing_Percentage__c = (!String.isBlank(taskItemMod.percentage) && taskItemMod.isBillable) ? decimal.valueOf( taskItemMod.percentage ) : null;

                updateTaskItemList.add(taskItem);

            }

        }
        return updateTaskItemList;

    }

    public Boolean isValidMilestone() {
        Boolean valid = false;

        for (Id serviceItemId : servicesIdToTaskItemListMap.keySet()) {
            if (totalPercentageTaskItemForServiceItemMap.get(serviceItemId) != 100 && totalPercentageTaskItemForServiceItemMap.get(serviceItemId) >= 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of all Task Percentages within ' + serviceItemIdToServiceItemNameMap.get(serviceItemId) + ' service should be 100%.'));
                return false;

            } else {
                valid = true;

            }

            for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
                if ( taskItemMod.isBillable && decimal.valueOf(taskItemMod.percentage) < 0 ) {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'Percentage should not be less than zero.'));
                    return false;
                }
                if (taskItemMod.isBillable && String.isBlank(taskItemMod.percentage) ) {
                    ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR, 'If Is Billable is true Percentage should not be empty.'));
                    return false;

                } else {
                    valid = true;

                }

            }

        }
        return valid;

    }

    public Boolean isValidPercentage() {
        Boolean valid = false;

        for (Id serviceItemId : servicesIdToTaskItemListMap.keySet()) {
            for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
                if (taskItemMod.isBillable && !String.isBlank(taskItemMod.percentage) && decimal.valueOf(taskItemMod.percentage) < 0) { //MRS 7485
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Percentage should not be less than zero.'));
                    return false;
                }
                if (taskItemMod.isBillable && String.isBlank(taskItemMod.percentage)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Is Billable is true Percentage should not be empty.'));
                    return false;
                } else {
                    valid = true;

                }

            }

        }

        if (100 != totalPercentageTaskItems) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Sum of all Service Percentages should be 100%.'));
            return false;

        } else {
            valid = true;

        }
        return valid;

    }

    public void changeIsBillableAction() { //MRS 7365
		String serviceItemId = ApexPages.currentPage().getParameters().get('ServiceItemId');
		String taskId = ApexPages.currentPage().getParameters().get('taskId');
		if(this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE)) {
			for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
				if (taskId == taskItemMod.Id) {
					if(!taskItemMod.isBillable) taskItemMod.percentage = '';
					break;
				}
			}
		}
        totalPercentageTaskItemForServiceItem(serviceItemId);
    }

    public void setAmount() {
        totalPercentageTaskItemForServiceItem(ApexPages.currentPage().getParameters().get('ServiceItemId'));
    }

    public void selectBillingMethodAction() {
        if ((this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE) || this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT)) && null != this.project.Frequency__c) {
            loadBillingDate();

        }

    }

    public void loadBillingDate() {
        this.billingDateWrapperList = new List<BillingDateWrapper>();
        Set<Id> thisProjectId = new Set<Id>();
        thisProjectId.add(this.project.Id);
        Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( thisProjectId, false );
        for (Billing_Date__c bli : BillingDateServices.getBillingDatesByProjectId(this.project.Id)) {
            this.billingDateWrapperList.add(new BillingDateWrapper(bli, this.project.Discounted_Total_Service_Amount__c, projectIdToAmountTypeToAmount.get(this.project.Id) ) );
        }
        this.numberInterval = this.billingDateWrapperList.size();

        if ((null != this.project.Number_Of_Intervals__c && this.project.Number_Of_Intervals__c != this.numberInterval) || (null == this.project.Number_Of_Intervals__c)) {
            this.project.Number_Of_Intervals__c = this.numberInterval;

            try {
                update this.project;

            } catch (DMLException ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not update number of intervals for a project: ' + ex.getDmlMessage(0)));

            }

        }

    }

    public void numberIntervalAction() {
        if (this.numberInterval <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Number of intervals should be positive value.'));
            return;

        }
        this.commandButtonApply      = true;
        this.isInit                  = false;
        this.isChangedIntervalNumber = true;
        createBillingDateList();

    }

    private void createBillingDateList() {
        this.billedPercentage       = 0;
        this.numberBilledInterval   = 0;
        this.billingDateWrapperList = new List<BillingDateWrapper>();

        if (null == this.project.Project_Start_Date__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Project Start Date should be populated.'));
            return;

        }

        if (null == this.project.Billing_End_Date__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Billing End Date should be populated.'));
            return;

        }

        if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE)) {
            createBillingDateForPercentage();

        }

    }

    public void createBillingDateForPercentage() {
        try {
            Date startDate                   = filterBillingDate();
            Date endDate                     = endDateForPercentage(startDate);
            system.debug('!!! startDate = ' + startDate + ' endDate = ' + endDate);

            this.countSteps = DateUtils.getMatchesInCurrentPeriod(startDate, endDate, this.project.Frequency__c, this.project.Quarterly_Month__c, this.project.Billing_day__c);
            //Last Biling Date equels Billing End Date of Project
            this.project.Billing_End_Date__c = this.countSteps.get(this.countSteps.size());

            if (this.countSteps.isEmpty()) {
                return;

            }

            this.numberInterval = this.countSteps.size() + this.numberBilledInterval;
            Billing_Date__c billingDate;

            for (Integer i = 1; i <= this.countSteps.size(); i++) {
                //MRS-7516, getPercentageByIntervalNumber(i)) --> getPercentageByIntervalNumber(i + this.numberBilledInterval))
                billingDate = new Billing_Date__c(Processing_Day__c = this.countSteps.get(i), Step_Number__c = (i + this.numberBilledInterval), Project_Profile__c = this.project.Id, Percentage__c = getPercentageByIntervalNumber(i + this.numberBilledInterval));
                this.billingDateWrapperList.add(new BillingDateWrapper(billingDate, this.project.Discounted_Total_Service_Amount__c, null));

            }

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return;

        }

    }

    public Date filterBillingDate() {
        List<Billing_Date__c> billingDates = BillingDateServices.getBillingDatesByProjectId(this.project.Id);
        Boolean isChangedStartDate = false;

        if (billingDates.isEmpty()) {
            return this.project.Project_Start_Date__c;

        }
        this.billingDateToRemove.clear();
        this.billingDatesForDisplay.addall(billingDates);

        Date startDate = this.project.Project_Start_Date__c;

        for (Billing_Date__c bd : billingDates) {
            if (!bd.Billed__c) {
                this.billingDateToRemove.add(bd);

            } else {
                isChangedStartDate = true;
                startDate = bd.Processing_Day__c;

                this.numberBilledInterval = Integer.valueOf(bd.Step_Number__c);
                this.billedPercentage += bd.Percentage__c;
                this.billingDateWrapperList.add(new BillingDateWrapper(bd, this.project.Discounted_Total_Service_Amount__c, null));

            }

        }

        if (this.numberBilledInterval >= this.numberInterval) {
           this.commandButtonApply = false;
           throw new ErrorException(ErrorException.NUMBER_OF_INTERVAL_LESS_THAN_BILLED);

        }

        if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_WEEKLY) && isChangedStartDate) {
            startDate = startDate.addDays(7);

        } else if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_MONTHLY) && isChangedStartDate) {
            startDate = startDate.addMonths(1);

        } else if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_QUARTERLY) && isChangedStartDate) {
            startDate = startDate.addMonths(3);

        }
        return startDate;

    }

    private Date endDateForPercentage(Date firstBillingDate) {
        if (!this.isChangedIntervalNumber) {
            this.isChangedIntervalNumber = false;
            return this.project.Billing_End_Date__c;

        }

        Date endDate = firstBillingDate;
        Integer i    = this.numberInterval;

        //Minus billed interval
        if (0 != this.numberBilledInterval) {
            i -= this.numberBilledInterval;

        }

        if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_WEEKLY)) {
            //Case when first billing day equals project billing day & we billed billind day(s) does not exist.
            if (this.project.Project_Start_Date__c == firstBillingDate && DateTime.newInstance(firstBillingDate, Time.newInstance(0, 0, 0, 0)).format('EEEE').equals(this.project.Billing_day__c) && 0 == this.numberBilledInterval) {
                i -= 1;

            //Case when first billing day equals project billing day & we billed billind day(s) exist.
            } else if (DateTime.newInstance(firstBillingDate, Time.newInstance(0, 0, 0, 0)).format('EEEE').equals(this.project.Billing_day__c) && this.numberBilledInterval > 0) {
                i -= 1;

            }
            endDate = endDate.addDays(7 * i);

        }

        if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_MONTHLY)) {
            //Case when first billing day equals project billing day & we billed billind day(s) does not exist.
            if (this.project.Project_Start_Date__c == firstBillingDate && String.valueOf(firstBillingDate.day()).equals(this.project.Billing_day__c) && this.numberBilledInterval == 0) {
                i -= 1;

            //Case when first billing day equals project billing day & we billed billind day(s) exist.
            } else if (String.valueOf(firstBillingDate.day()).equals(this.project.Billing_day__c) && this.numberBilledInterval > 0) {
                i -= 1;

            }
            endDate = endDate.addMonths(i);

        }

        if (this.project.Frequency__c.equals(ProjectProfileServices.FREQUENCY_QUARTERLY)) {
            //Case when first billing day equals project billing day & we billed billind day(s) does not exist.
            if (this.project.Project_Start_Date__c == firstBillingDate && String.valueOf(firstBillingDate.day()).equals(this.project.Billing_day__c) && this.numberBilledInterval == 0) {
                i -= 1;

            //Case when first billing day equals project billing day & we billed billind day(s) exist.
            } else if (String.valueOf(firstBillingDate.day()).equals(this.project.Billing_day__c) && this.numberBilledInterval > 0) {
                i -= 1;

            }
            endDate = endDate.addMonths(3 * i);

        }
        return endDate;
    }

    private Decimal getPercentageByIntervalNumber(Integer currentInterval) {
        for (Billing_Date__c bd : this.billingDatesForDisplay) {
            if (bd.Step_Number__c == currentInterval) {
                return bd.Percentage__c;

            }

        }
        return 0;

    }

    public Integer formPosition { get { if( formPosition == null ) formPosition = 0; return formPosition; } set { try { formPosition = Integer.valueOf( value ); } catch( exception e ) {} } }
    public void setFormPosition() {
        try {
            formPosition = Integer.valueOf( ApexPages.currentPage().getParameters().get('scroll') );
        } catch( Exception e ) {
            formPosition = 0;
        }
    }

	public void reset() { //MRS 7365
		if(this.project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE)) {
			Decimal amount = 0;
			for (Id serviceItemId : servicesIdToTaskItemListMap.keySet()) {
				for (TaskItemModel taskItemMod : servicesIdToTaskItemListMap.get(serviceItemId)) {
				    if(taskItemMod.isBillable) {
						if(!taskItemMod.isLocked) {
							taskItemMod.percentage = '0';
						} else {
							amount += Decimal.valueOf(taskItemMod.Percentage);
						}
				    }
				}
			}
			totalPercentageTaskItems = amount;
		}
    }

}