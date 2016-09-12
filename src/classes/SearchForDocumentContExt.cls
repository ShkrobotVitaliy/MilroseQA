public with sharing class SearchForDocumentContExt {
    
    public Boolean isFilterEmpty {
        get {
            return this.filterFields.isFilterEmpty && String.isBlank(this.lstoreStoredDocumenFilter.Drawings_Title__c) && 
                   String.isBlank(this.lstoreStoredDocumenFilter.LStore__Description__c) && String.isBlank(this.lstoreStoredDocumenFilter.LStore__Keywords__c) && 
                   String.isBlank(this.lstoreStoredDocumenFilter.Drawing_Number__c) && String.isBlank(this.lstoreStoredDocumenFilter.Worktype__c) && String.isBlank(this.lstoreStoredDocumenFilter.Municipal_Description_ID__c) &&
                   String.isBlank(this.lstoreStoredDocumenFilter.Municipal_Agency_Id__c) && null == lstoreStoredDocumenFilter.Drawing_Revision_Date__c; 
            
        }
        private set;
    }
    
    public String getAdditionalDocuments {
        get {
            return StoredDocumentServices.DOCUMENTS_FILE_TYPE;
        }
    }

    public String getGeneratedForms {
        get {
            return StoredDocumentServices.FORMS_FILE_TYPE;
        }
    }

    public String getProposals {
        get {
            return StoredDocumentServices.PROPOSALS_FILE_TYPE;
        }
    }

    public String getDrawings {
        get {
            return StoredDocumentServices.DRAWINGS_FILE_TYPE;
        }
    }

    public String getAccountingDocuments {
        get {
            return StoredDocumentServices.ACCOUNTING_FILE_TYPE;
        }
    }

    public String getOther {
        get {
            return StoredDocumentServices.OTHER_FILE_TYPE;
        }
    }

    public Boolean isLegacyDocument {
        get {
            return filterFields.accountingDocTypeObjectKeyPrefix != null &&
                   ( filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.LEGACY_PROFORMA_INVOICE_DOCUMENT ||
                     filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.LEGACY_CREDIT_NOTE_DOCUMENT );
        }
    }

    public Boolean isProformaInvoiceDocumentType {
        get {
            return filterFields.accountingDocTypeObjectKeyPrefix != null && filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.PROFORMA_INVOICE_DOCUMENT &&
                   filterFields.typeObjectKeyPrefix != null && filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix());
        }
    }

    public Boolean isDepositInvoiceDocument {
        get {
            return filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.DEPOSIT_DETAIL_REPORT_DOCUMENT;
        }
    }

    public Boolean isAccountSummaryRecapReportDocument {
        get {
            return filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT;
        }
    }

    public Boolean isStatementsOfAccountsDocument {
        get {
            return filterFields.accountingDocTypeObjectKeyPrefix == StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT;
        }
    }

    public Boolean isUploadSection { 
        get {
            if( isUploadSection == null ) isUploadSection = true;
            return isUploadSection; 
        } 
        set; 
    }

    public Boolean isFinancialUser { 
        get {
            String userProfile = UserServices.getProfile().Name;
            return ( userProfile.contains(UserServices.PROFILE_ACCOUNT_MANAGER) ||
                     userProfile.contains(UserServices.PROFILE_PARTNER) || 
                     userProfile.contains(UserServices.PROFILE_FINANCE_MANAGER) ||
                     userProfile.contains(UserServices.PROFILE_CFO) ||
                     userProfile.contains(UserServices.PROFILE_A_R_CORDINATOR) ||
                     userProfile.contains(UserServices.PROFILE_STAFF_ACCOUNTANT) ||
                     userProfile.contains(UserServices.PROFILE_OPERATIONS_MANAGER) ||
                     userProfile.contains(UserServices.PROFILE_SHARED_SERVICES_MANAGER) ||
                     userProfile.contains(UserServices.EXECUTIVE_ADMIN_PROFILE_NAME) ||
                     userProfile.contains(UserServices.PROFILE_PROPOSAL_SPECIALIST) ||
                     userProfile.contains(UserServices.PROFILE_DIRECTOR_OF_OPERATIONS) || //MRS-6507
                     userProfile.contains(UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) ); 
        } 
        set; 
    }

    public Boolean isProposalSpecialistUser { 
        get {
            return ( UserServices.getProfile().Name == UserServices.PROFILE_PROPOSAL_SPECIALIST || UserServices.getProfile().Name == UserServices.PROFILE_PROPOSAL_SPECIALIST_QA ); 
        } 
        set; 
    }

    public String downloadPdfUrl {get;set;}

    public List<LStore__Stored_Document__c> lstoreStoredDocumenResults {
        get {
            if(lstoreStoredDocumenResults == null) {
                lstoreStoredDocumenResults = new List<LStore__Stored_Document__c>();
            }
            return lstoreStoredDocumenResults   ;
        }
        set;
    }

    public LStore__Stored_Document__c lstoreStoredDocumenFilter {
        get {
            if(lstoreStoredDocumenFilter == null) {
                lstoreStoredDocumenFilter = new LStore__Stored_Document__c();
            }
            return lstoreStoredDocumenFilter;
        }
        set;
    }

    public FilterFields filterFields {
        get {
            if(filterFields == null) {
                filterFields = new FilterFields();
            }
            return filterFields;
        }
        set;
    }

    public ApexPages.StandardSetController con{get;set;}
    public Integer cuntPages {get;set;}

    private String queryWhere;
    private static final Integer COUNTRECORDS = 200;

    public List<SelectOption> regionNameOptions{
        get{
            if( regionNameOptions == null ){
                regionNameOptions = ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Service_Bundle__c.sObjectType, 'Region__c'), true, true);
            }
            return regionNameOptions;
        }
        private set;
    }

    public List<SelectOption> proposalStatusOptions {
        get{
            if( proposalStatusOptions == null ){
                proposalStatusOptions = ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.sObjectType, 'Status__c'), true, true);
            }
            return proposalStatusOptions;
        }
        private set;
    }

    public sortExtension sortAssignmentExtension {
        get {
            if(sortAssignmentExtension == null) {
                sortAssignmentExtension = new sortExtension('Drawings_Title__c');
            }
            return sortAssignmentExtension;
        }
        set;
    }

    public SearchForDocumentContExt() {}

    public void searchAction() {
        if (this.isFilterEmpty) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Please select an additional filter to narrow search results.'));
            return;
        
        }
        
        system.debug('start searchAction: ');
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getSortDirection();
        queryWhere = StoredDocumentServices.buildWhereQuery(lstoreStoredDocumenFilter, filterFields);

        String fullQuery = StoredDocumentServices.buildQuery(queryWhere, sortBy);

        system.debug(LoggingLevel.ERROR, '@@@@@@@@@@ fullQuery = ' + fullQuery);

        con = new ApexPages.StandardSetController( Database.query( fullQuery ) );

        cuntPages = Integer.valueOf(Math.ceil((Decimal)con.getResultSize()/(Decimal)COUNTRECORDS));

        con.setPageSize(COUNTRECORDS);
        createStoredDocumenItemList();
    }

    @TestVisible private void createStoredDocumenItemList() {
        lstoreStoredDocumenResults.clear();
        for(SObject lsd : con.getRecords()) {
            LStore__Stored_Document__c storDoc = (LStore__Stored_Document__c)lsd;
            if ( storDoc.Task_Item__c != null && storDoc.Drawings_Title__c == StoredDocumentServices.TRANSMITTAL_DOCUMENT){
                storDoc.Drawings_Title__c = storDoc.Name.removeEndIgnoreCase('.pdf');
            }
            lstoreStoredDocumenResults.add( storDoc );
        }
    }

    public PageReference sortAction() {
        if (!lstoreStoredDocumenResults.isEmpty()) {
            getStoredDocumenFromDB();

        }

        return null;
    }

    public PageReference openPDF() {
        String relatedId = ApexPages.currentPage().getParameters().get('relatedId');
        String selectedId = ApexPages.currentPage().getParameters().get('selectedId');

        if( !String.isBlank(relatedId) && !String.isBlank(selectedId) ) {
            downloadPdfUrl = '/apex/lstore__storedDocViewRestore?id=' + selectedId + '&action=download&contentType=redirect&retURL=/' + relatedId;
        }
        return null;
    }

    @TestVisible private void getStoredDocumenFromDB(){
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getSortDirection();
        con = new ApexPages.StandardSetController(Database.query(StoredDocumentServices.buildQuery(queryWhere, sortBy)));
        cuntPages = Integer.valueOf(Math.ceil((Decimal)con.getResultSize()/(Decimal)COUNTRECORDS));
        con.setPageSize(COUNTRECORDS);
        createStoredDocumenItemList();
    }

    public List<SelectOption> getArtifactsCategory() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(StoredDocumentServices.DOCUMENTS_FILE_TYPE,  'Additional Documents'));
        options.add(new SelectOption(StoredDocumentServices.DRAWINGS_FILE_TYPE,   'Drawings'));
        options.add(new SelectOption(StoredDocumentServices.FORMS_FILE_TYPE,      'Generated Forms'));
        options.add(new SelectOption(StoredDocumentServices.PROPOSALS_FILE_TYPE,  'Proposals'));

        if( isFinancialUser ){
            options.add(new SelectOption(StoredDocumentServices.ACCOUNTING_FILE_TYPE, 'Accounting Documents'));
        }
        
        options.add(new SelectOption(StoredDocumentServices.OTHER_FILE_TYPE, 'Other'));
        return options;
    }

    public List<SelectOption> getTypeDocument() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'All'));
        options.add(new SelectOption(Schema.SObjectType.Proposal__c.getKeyPrefix(), 'Proposal'));
        options.add(new SelectOption(Schema.SObjectType.Project_Profile__c.getKeyPrefix(), 'Project'));
        options.add(new SelectOption(Schema.SObjectType.Service_Item__c.getKeyPrefix(), 'Service Item'));
        options.add(new SelectOption(Schema.SObjectType.Task_Item__c.getKeyPrefix(), 'Task Item'));
        options.add(new SelectOption(Schema.SObjectType.RFI_Scope__c.getKeyPrefix(), 'RFI Scope'));
        options.add(new SelectOption(Schema.SObjectType.Building__c.getKeyPrefix(), 'Building'));
        return options;
    }

    public List<SelectOption> getTypeGeneratedDocument() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'All'));
        options.add(new SelectOption(Schema.SObjectType.Proposal__c.getKeyPrefix(), 'Proposal'));
        options.add(new SelectOption(Schema.SObjectType.Project_Profile__c.getKeyPrefix(), 'Project'));
        options.add(new SelectOption(Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix(), 'Pro-forma Invoice'));
        options.add(new SelectOption(Schema.SObjectType.Account.getKeyPrefix(), 'Account'));
        options.add(new SelectOption(Schema.SObjectType.Deposit_Invoice__c.getKeyPrefix(), 'Deposit Invoice'));
        options.add(new SelectOption(Schema.SObjectType.Legacy_Pro_forma_Invoice__c.getKeyPrefix(), 'Legacy Pro-forma Invoice'));
        return options;
    }

    public List<SelectOption> getDocumentTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();

        if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Proposal__c.getKeyPrefix()) ){
            options.add(new SelectOption(StoredDocumentServices.RETAINER_INVOICE_DOCUMENT, StoredDocumentServices.RETAINER_INVOICE_DOCUMENT));
        
        } else if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix()) && !isProposalSpecialistUser ){
            options.add(new SelectOption(StoredDocumentServices.PROFORMA_INVOICE_DOCUMENT, StoredDocumentServices.PROFORMA_INVOICE_DOCUMENT));
            options.add(new SelectOption(StoredDocumentServices.DOCUMENT_SHREDDING_DOCUMENT, StoredDocumentServices.DOCUMENT_SHREDDING_DOCUMENT));
            options.add(new SelectOption(StoredDocumentServices.MET_DATA_SCANNING_DOCUMENT, StoredDocumentServices.MET_DATA_SCANNING_DOCUMENT));
            options.add(new SelectOption(StoredDocumentServices.SUPREME_SYSTEMS_DOCUMENT, StoredDocumentServices.SUPREME_SYSTEMS_DOCUMENT));
            options.add(new SelectOption(StoredDocumentServices.CREDIT_NOTE_DOCUMENT, StoredDocumentServices.CREDIT_NOTE_DOCUMENT));

        } else if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Account.getKeyPrefix()) && !isProposalSpecialistUser ){
            options.add(new SelectOption(StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT, StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT));

        } else if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Project_Profile__c.getKeyPrefix()) ){
            options.add(new SelectOption(StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT, StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT));

        } else if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Deposit_Invoice__c.getKeyPrefix()) && !isProposalSpecialistUser ){
            options.add(new SelectOption(StoredDocumentServices.DEPOSIT_DETAIL_REPORT_DOCUMENT, StoredDocumentServices.DEPOSIT_DETAIL_REPORT_DOCUMENT));

        } else if( filterFields.typeObjectKeyPrefix.equals(Schema.SObjectType.Legacy_Pro_forma_Invoice__c.getKeyPrefix()) && !isProposalSpecialistUser ){
            options.add(new SelectOption(StoredDocumentServices.LEGACY_PROFORMA_INVOICE_DOCUMENT, StoredDocumentServices.LEGACY_PROFORMA_INVOICE_DOCUMENT));
            options.add(new SelectOption(StoredDocumentServices.LEGACY_CREDIT_NOTE_DOCUMENT, StoredDocumentServices.LEGACY_CREDIT_NOTE_DOCUMENT));

        } else {
            options.add(new SelectOption(StoredDocumentServices.RETAINER_INVOICE_DOCUMENT, StoredDocumentServices.RETAINER_INVOICE_DOCUMENT));
            if( !isProposalSpecialistUser) {
                options.add(new SelectOption(StoredDocumentServices.PROFORMA_INVOICE_DOCUMENT, StoredDocumentServices.PROFORMA_INVOICE_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.DOCUMENT_SHREDDING_DOCUMENT, StoredDocumentServices.DOCUMENT_SHREDDING_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.MET_DATA_SCANNING_DOCUMENT, StoredDocumentServices.MET_DATA_SCANNING_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.SUPREME_SYSTEMS_DOCUMENT, StoredDocumentServices.SUPREME_SYSTEMS_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.CREDIT_NOTE_DOCUMENT, StoredDocumentServices.CREDIT_NOTE_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT, StoredDocumentServices.STATEMENT_OF_ACCOUNTS_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT, StoredDocumentServices.ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.DEPOSIT_DETAIL_REPORT_DOCUMENT, StoredDocumentServices.DEPOSIT_DETAIL_REPORT_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.LEGACY_PROFORMA_INVOICE_DOCUMENT, StoredDocumentServices.LEGACY_PROFORMA_INVOICE_DOCUMENT));
                options.add(new SelectOption(StoredDocumentServices.LEGACY_CREDIT_NOTE_DOCUMENT, StoredDocumentServices.LEGACY_CREDIT_NOTE_DOCUMENT));
            }
        }
        return options;
    }

    public void clearFilter() {
        String artifactsCategory = lstoreStoredDocumenFilter.Artifacts_Category__c;
        lstoreStoredDocumenFilter = new LStore__Stored_Document__c();
        filterFields = new FilterFields();
        lstoreStoredDocumenFilter.Artifacts_Category__c = artifactsCategory;

        isUploadSection = lstoreStoredDocumenFilter.Artifacts_Category__c == StoredDocumentServices.DOCUMENTS_FILE_TYPE ||
                          lstoreStoredDocumenFilter.Artifacts_Category__c == StoredDocumentServices.DRAWINGS_FILE_TYPE ||
                          lstoreStoredDocumenFilter.Artifacts_Category__c == StoredDocumentServices.FORMS_FILE_TYPE;

        lstoreStoredDocumenResults =  new List<LStore__Stored_Document__c>();

        filterFields.accountingDocTypeObjectKeyPrefix = null;
    }

    public void clearFiltersForLegacyDocs(){
        if (isLegacyDocument) {
            filterFields.proposalNumber = null;
        }
    }

    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    //Page number of the current displaying records
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }

    //Returns the previous page of records
    public void previous() {
        con.previous();
    }

    //Returns the next page of records
    public void next() {
        con.next();
    }

}