public with sharing class ProFormaBillingLineItemController {

    public String billingClientCompanyFilter { get; set; }
    public String accountingContactCompanyFilter { get; set; }
    public String projectNumberFilter { get; set; }
    public String projectAddressFilter { get; set; }
    public String billingMethodFiltr { get; set; }
    public String serviceNameFilter { get; set; }
    public String poFilter { get; set; }
    public String reimbBillableType { get; set; }
    public Boolean isReimbursables { get; set; }
    public Boolean showGeneratedDocs { get; set; }
    private final String ALL_REIMBURSABLE_BILLABLE_TYPE_OPTION = 'All';
    public Boolean doNotBillReimbursablesAlone { get{ if( doNotBillReimbursablesAlone == null ) doNotBillReimbursablesAlone = true; return doNotBillReimbursablesAlone; } set; }
    public Set<Id> selectedBLIIDList {get{if (selectedBLIIDList == null)selectedBLIIDList = new Set<Id>(); return selectedBLIIDList;}set;}

    public transient List<GeneratedDocumentsWrapper> generatedDocuments;
    public List<GeneratedDocumentsWrapper> getGeneratedDocuments() {
        List<GeneratedDocumentsWrapper> documents = new List<GeneratedDocumentsWrapper>();
        for( LStore__Stored_Document__c document : [ SELECT Related_Object_Id__c, Name, LStore__Related_To__c, LStore__Related_Object_Id__c, LStore__File_Name__c,
                                                            LStore__External_Id__c, LStore__Description__c, Id, CreatedDate, LStore__Type__c
                                                     FROM LStore__Stored_Document__c
                                                     WHERE LStore__File_Name__c LIKE '%Scheduled Invoices%'
                                                     ORDER BY CreatedDate DESC
                                                     LIMIT 10000 ] ) {
            documents.add( new GeneratedDocumentsWrapper( document ) );
        }
        return documents;
    }

    public class GeneratedDocumentsWrapper {
        public LStore__Stored_Document__c record { get; set; }

        public transient String createdDate;
        public String getCreatedDate() {
            return ( this.record != null && this.record.CreatedDate != null )
                   ? this.record.CreatedDate.format( DateUtils.DATETIME_USER_FRIENDLY_FORMAT )
                   : '';
        }

        public GeneratedDocumentsWrapper( LStore__Stored_Document__c document ) {
            this.record = document;
        }
    }

    public SortExtension sortAssignmentExtension {
        get {
            if(sortAssignmentExtension == null) {
                sortAssignmentExtension = new sortExtension('CreatedDate');
            }
            return sortAssignmentExtension;
        }
        set;
    }
    private String queryWhere;
    public Boolean isGenerateInvoices {
        get {
            if( isGenerateInvoices == null ) {
                Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
                if(
                    ProfileName.Name.contains(UserServices.PROFILE_PARTNER) ||
                    ProfileName.Name.contains(UserServices.PROFILE_FINANCE_MANAGER) ||
                    ProfileName.Name.contains(UserServices.PROFILE_CFO) ||
                    ProfileName.Name.contains(UserServices.PROFILE_A_R_CORDINATOR)
                ) {
                    isGenerateInvoices = false;
                } else {
                    isGenerateInvoices = true;
                }
            }
            system.debug('isGenerateInvoices: ' + isGenerateInvoices);
            return isGenerateInvoices;
        }
        set;
    }

    public ApexPages.StandardSetController con{get; set;}
    public list<BillingLineItemWrapper> billingLineItemList {get; set;}
    public Integer cuntPages {get;set;}
    public Boolean showGenerateAction {get;set;}
    public Boolean infoMessageIsExist {
        get{
            if(infoMessageIsExist == null){
                infoMessageIsExist = false;
            }
            return infoMessageIsExist;
        }
        set;
    }
    private static final Integer COUNTRECORDS = Integer.valueOf(MilroseSetting__c.getInstance('Number_of_Rows_in_Proforma_Generator').Custom_Number__c);

    public ProFormaBillingLineItemController() {
        this.billingMethodFiltr = '';
        this.billingLineItemList = new List<BillingLineItemWrapper>();
    }

    public PageReference searchAction() {
        String sortBy = sortAssignmentExtension.sortExpression + ' DESC';
        if( reimbBillableType == ALL_REIMBURSABLE_BILLABLE_TYPE_OPTION || !isReimbursables ) reimbBillableType = '';

        this.queryWhere = BillingLineItemServices.buildQueryWhere(this.billingClientCompanyFilter, this.accountingContactCompanyFilter,
                                                                  this.projectNumberFilter, this.projectAddressFilter,
                                                                  this.billingMethodFiltr, this.serviceNameFilter,
                                                                  this.poFilter, this.isReimbursables, this.reimbBillableType, false);//MRS-6396
        system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ this.queryWhere = ' + this.queryWhere);
        this.con = new ApexPages.StandardSetController(Database.query(BillingLineItemServices.buildQuery(this.queryWhere, sortBy)));
        this.cuntPages = Integer.valueOf(Math.ceil((Decimal)this.con.getResultSize()/(Decimal)COUNTRECORDS));
        this.con.setPageSize(COUNTRECORDS);
        this.createBillingLineItemList();

        infoMessageIsExist = false;

        return null;
    }

    public SelectOption[] getPicklistValuesAsSelectOptions(Schema.sObjectType objType, String field, String falidFor) {
        SelectOption[] options = new List<SelectOption>();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(field).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values) {
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }

    public SelectOption[] billingMethodOptions {
        get {
            this.billingMethodOptions = new list<SelectOption>();
            this.billingMethodOptions.addAll(this.getPicklistValuesAsSelectOptions(Project_Profile__c.SObjectType, 'Billing_Method__c', NULL));
            this.billingMethodOptions.add(new SelectOption('', 'All'));
            this.billingMethodOptions.sort();
            return this.billingMethodOptions;
        }
        set;
    }

    public List<SelectOption> reimbBillableTypeOptions {
        get {
            if (null == this.reimbBillableTypeOptions) {
                this.reimbBillableTypeOptions = new List<SelectOption>();
                this.reimbBillableTypeOptions.add(new SelectOption('', ALL_REIMBURSABLE_BILLABLE_TYPE_OPTION));
                for (SelectOption option : this.getPicklistValuesAsSelectOptions(Billing_Line_Item__c.SObjectType, 'Reimb_Billable_Type__c', NULL)) {
                    if (option.getValue() != 'Non-Billable' ) {
                        this.reimbBillableTypeOptions.add(option);
                    }
                }
            }
            return this.reimbBillableTypeOptions;
        }
        set;
    }

    public PageReference sortAction() {
        if (!this.billingLineItemList.isEmpty()) {
            getBillingLineItemsListFromDB();

        }

        return null;
    }

    public PageReference billAnywayAction(){
        return generateInvoices(true);
    }

    public PageReference generateInvoicesAction(){
        return generateInvoices(false);
    }

    public PageReference generateInvoices(Boolean isBillAnyway) {
        system.debug('generateInvoices');
        List<Billing_Line_Item__c> lineItemsForInvoicing = new List<Billing_Line_Item__c>();
        Set<String> bliWithPORequired = new Set<String>();
        Set<Id> selectedBLIs = new Set<Id>();
        //MRS-7228, MRS-7366
        Set<String> noTimeInvoicingForBLIs = new Set<String>();
        Map<Id, Date> projectWithStartDate = new Map<Id, Date>();

        for (BillingLineItemWrapper bliModel : billingLineItemList) {
            if ( bliModel.selected ){
                selectedBLIs.add(bliModel.bli.Id);
            }

            //MRS-5319:If the BLI’s project has the “PO Required” field checked and the BLI has no value in its “Purchase Order” lookup field then the BLI should not be added to a Pro-forma Invoice.
            //MRS-7366
            if (bliModel.selected && ( (bliModel.bli.Project_Profile__r.PO_Required__c && null == bliModel.bli.Purchase_Order__c)
                                  && !( bliModel.bli.Project_Profile__r.PO_Not_Required__c && ( bliModel.bli.isReimbursable__c || bliModel.bli.Is_Check_Processing_Fee__c ) ) )
                                  && !isBillAnyway ) {

                //prepare PO Required Info Massage
                bliWithPORequired.add(bliModel.bli.Name);

                //check if Billing Date is valid for current BLI
                if ( !projectWithStartDate.containsKey( bliModel.bli.Project_Profile__c ) ){
                    projectWithStartDate.put( bliModel.bli.Project_Profile__c, DateUtils.getDateWithPeriodAndStartDay( Date.today(),
                                                                                                                       bliModel.bli.Project_Profile__r.Frequency__c,
                                                                                                                       bliModel.bli.Project_Profile__r.Billing_day__c,
                                                                                                                       bliModel.bli.Project_Profile__r.Quarterly_Month__c ) );
                }

                if ( bliModel.bli.Milestone_Date__c > projectWithStartDate.get( bliModel.bli.Project_Profile__c ) ){
                    noTimeInvoicingForBLIs.add( bliModel.bli.Name );
                }

                continue;

            }

            if( bliModel.selected && bliModel.bli.Quantity__c != null && bliModel.bli.Quantity__c > 0) {
                system.debug('bliModel.bli = ' + bliModel.bli);
                lineItemsForInvoicing.add(bliModel.bli);
            }

        }

        if (!bliWithPORequired.isEmpty()){
            infoMessageIsExist = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Following BLI require POs,\nno invoice will be generated until a PO is linked to the BLI:\n' +
                MilroseDevHelper.joinStrings( bliWithPORequired, ', ' ) ));
        }

        if (!lineItemsForInvoicing.isEmpty()) {
            system.debug('inside lineItemsForInvoicing');
            try{
                //MRS-7228
                if (!infoMessageIsExist) {
                    this.selectedBLIIDList.clear();
                }
                ProformaInvoiceServices.bliWithPreviuslyCreatedPFIForBillAnyway = this.selectedBLIIDList;
                ProformaInvoiceServices.processProformaInvoices( lineItemsForInvoicing, doNotBillReimbursablesAlone, isBillAnyway, false );
                getBillingLineItemsListFromDB();

                //MRS-7216
                for (BillingLineItemWrapper bliModel : billingLineItemList){
                    if ( selectedBLIs.contains(bliModel.bli.Id) ){
                        bliModel.selected = true;
                    }
                }

                //MRS-7366
                if( !ProformaInvoiceServices.noTimeInvoicingForBLIs.isEmpty() ){
                    noTimeInvoicingForBLIs.addAll(ProformaInvoiceServices.noTimeInvoicingForBLIs);
                }
            } catch(Exception ex){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            }
        }

        //MRS-7366
        if( !noTimeInvoicingForBLIs.isEmpty() ){
            infoMessageIsExist = true;

            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Following BLI\'s were created after the client\'s last preferred billing date, no invoice will be generated until the next billing date:\n' +
                MilroseDevHelper.joinStrings( noTimeInvoicingForBLIs, ', ' ) ));
        }

        //MRS-7228
        if (!isBillAnyway && infoMessageIsExist){
            this.selectedBLIIDList.addAll( selectedBLIs );
        } else {
            this.selectedBLIIDList.clear();
        }

        if (isBillAnyway) infoMessageIsExist = false;

        return null;
    }

    private void getBillingLineItemsListFromDB(){
        String sortBy = sortAssignmentExtension.sortExpression + ' DESC';
        system.debug('BillingLineItemServices.buildQuery(this.queryWhere, sortBy): ' + BillingLineItemServices.buildQuery(this.queryWhere, sortBy));
        this.con = new ApexPages.StandardSetController(Database.query(BillingLineItemServices.buildQuery(this.queryWhere, sortBy)));
        this.cuntPages = Integer.valueOf(Math.ceil((Decimal)this.con.getResultSize()/(Decimal)COUNTRECORDS));
        this.con.setPageSize(COUNTRECORDS);
        this.createBillingLineItemList();
    }

    private void createBillingLineItemList() {
        this.billingLineItemList.clear();
        showGenerateAction = false;
        for(SObject bli : this.con.getRecords()) {
            this.billingLineItemList.add(new BillingLineItemWrapper((Billing_Line_Item__c)bli));
        }
        if( !billingLineItemList.isEmpty() ){
            showGenerateAction = true;
        }
        system.debug('this.billingLineItemList: ' + this.billingLineItemList);
    }

    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext {
        get {
            return this.con.getHasNext();
        }
        set;
    }

    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious {
        get {
            return this.con.getHasPrevious();
        }
        set;
    }

    //Page number of the current displaying records
    public Integer pageNumber {
        get {
            return this.con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous() {
        this.con.previous();
        this.createBillingLineItemList();
    }

    //Returns the next page of records
    public void next() {
        this.con.next();
        this.createBillingLineItemList();
    }

}