public with sharing class PrebillingGeneratorController {

    private Project_Profile__c currentProject;
    private final String projectProfileId = ApexPages.currentPage().getParameters().get('Id');
    public List<Project_Profile__c> selectedProjectsList {
        get {
            if( selectedProjectsList == null) selectedProjectsList = new List<Project_Profile__c>();
            return selectedProjectsList;
        }
        set;
    }

    public List<fullWrapper> wrapout {
        get {
            if(wrapout == null) wrapout = new List<fullWrapper>();
            return wrapout;
        }
        set;
    }

    public List<fullWrapper> wrapoutSearchResults {
        get {
            if(wrapoutSearchResults == null) wrapoutSearchResults = new List<fullWrapper>();
            return wrapoutSearchResults;
        }
        set;
    }

    public class fullWrapper{
        public Project_Profile__c projectItemInFullWrapper { get; set; }
        public Boolean isSelected {
            get{
                if( isSelected == null ) isSelected = false;
                return isSelected;
            }
            set;
        }
        public Decimal amount {
            get{
                if( amount == null ) amount = 0;
                return amount;
            }
            set;
        }
        public Decimal amountWithFees {
            get{
                if( amountWithFees == null ) amountWithFees = 0;
                return amountWithFees;
            }
            set;
        }
        public Boolean isSelectedViaSearch {
            get{
                if( isSelectedViaSearch == null ) isSelectedViaSearch = false;
                return isSelectedViaSearch;
            }
            set;
        }
        public fullWrapper( Project_Profile__c projectItemInFullWrapper, Boolean isSelected, Boolean isSelectedViaSearch, Decimal amount ) {
            this.projectItemInFullWrapper = projectItemInFullWrapper;
            this.projectItemInFullWrapper.Reimbursable1__c = 0;
            this.projectItemInFullWrapper.Reimbursable2__c = 0;
            this.projectItemInFullWrapper.Reimbursable3__c = 0;
            this.projectItemInFullWrapper.Reimbursable4__c = 0;
            this.isSelected = isSelected;
            this.isSelectedViaSearch = isSelectedViaSearch;
            this.amount = ( amount >= 0 ) ? amount : 0;
        }
    }

    //Add Projects to wrappers
    public void getAmount() {
        for( fullWrapper item: wrapout ){
                item.amountWithFees = ( ( item.amount > 0 ) ? item.amount : 0 ) + ( ( (item.projectItemInFullWrapper.Reimbursable1__c != null) ? item.projectItemInFullWrapper.Reimbursable1__c : 0 ) ) +
                + ( ( (item.projectItemInFullWrapper.Reimbursable2__c != null) ? item.projectItemInFullWrapper.Reimbursable2__c : 0 ) ) +
                + ( ( (item.projectItemInFullWrapper.Reimbursable3__c != null) ? item.projectItemInFullWrapper.Reimbursable3__c : 0 ) ) +
                + ( ( (item.projectItemInFullWrapper.Reimbursable4__c != null) ? item.projectItemInFullWrapper.Reimbursable4__c : 0 ) );
        }
    }

    public Boolean isSearchPanel { get; set; }
    public String mRCNumberFilter {get; set{ mRCNumberFilter = value;} }
    public String billingCompanyNameFilter {get; set{ billingCompanyNameFilter = value;} }
    public String buildingFilter {get; set{ buildingFilter = value;} }
    public String municipalityFilter {get; set{ municipalityFilter = value;} }
    public String regionId { get { if ( regionId == null ) regionId = Id.valueOf(currentProject.Region_Id__c); return regionId; } set;}
    private String queryWhere;
    public Set<Id> idsOfSelectedProjects = new Set<Id>();
    public Set<Id> idsOfSearchProjects = new Set<Id>();
    private Map<Id, Decimal> idProjectToBilledAmount = new Map<Id, Decimal>();

    public List<selectOption> regionOptions {
        get{
            List<SelectOption> options = new List<SelectOption>();
            for( Region__c item: [Select Name, Id From Region__c LIMIT 1000]){
                options.add( new SelectOption( item.Id , item.Name ) );
            }
            return options;
        }
        set;
    }

    //Start execution
    public PrebillingGeneratorController () {
        try{
            currentProject =  [ Select Id, Name, Submitted_Planned_Dates__c, Project_Start_Date__c, Project_Manager__c, Discounted_Total_Service_Amount__c,
                                          Project_State__c, Project_Expected_End_Date__c, Pre_billed__c, Reimbursable1__c, Reimbursable4__c, Tax_Value__c,
                                          Reimbursable2__c, Reimbursable3__c, Region_ID__c, No_Met_Data_Scanning__c, No_Document_Shredding__c, No_Reimbursables_After_Pre_Bill__c
                                   From Project_Profile__c
                                   Where Id = :projectProfileId ];
            if( currentProject.Pre_billed__c ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This Project is already Pre-billed. You can use search and find another not Pre-billed Projects.'));
                return;
            }
            getFullWrapper();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid parameters: ' + e.getMessage()));
        }
    }

    //Add Projects to wrappers
    public void getFullWrapper() {
        for(AggregateResult aggResults: [SELECT Project_Profile__c proj, SUM(Amount_Billed__c) am
                                         FROM Billing_Line_Item__c
                                         WHERE isReimbursable__c = false AND
                                            Service_Item__r.Is_Amendmend_Deleted__c = false AND
                                            Project_Profile__c != null AND
                                            (( Project_Profile__c IN: idsOfSelectedProjects ) OR ( Project_Profile__c =: currentProject.Id ) OR ( Project_Profile__c IN: idsOfSearchProjects ) )
                                         GROUP BY Project_Profile__c]){
            idProjectToBilledAmount.put( (Id)aggResults.get('proj'), ( (Decimal)aggResults.get('am') != null ) ? (Decimal)aggResults.get('am') : 0 );
        }

        if( !currentProject.Pre_billed__c && !idsOfSelectedProjects.contains(currentProject.Id) ){

            wrapout.add( new fullWrapper( currentProject, true, true, ( ( (currentProject.Tax_Value__c != null) ? currentProject.Tax_Value__c  : 0 ) ) + ( ( currentProject.Discounted_Total_Service_Amount__c != null ) ? currentProject.Discounted_Total_Service_Amount__c  : 0 ) - ( ( idProjectToBilledAmount.get( currentProject.Id ) != null ) ? idProjectToBilledAmount.get( currentProject.Id ) : 0 ) ) );
            idsOfSelectedProjects.add( currentProject.Id );
        }

        for( fullWrapper wrapperItem: wrapoutSearchResults ){
            if( wrapperItem.isSelectedViaSearch && !idsOfSelectedProjects.contains(wrapperItem.projectItemInFullWrapper.Id) ){
                wrapout.add( new fullWrapper( wrapperItem.projectItemInFullWrapper, false, true, ( ( (wrapperItem.projectItemInFullWrapper.Tax_Value__c != null) ? wrapperItem.projectItemInFullWrapper.Tax_Value__c  : 0 ) ) + ( ( wrapperItem.projectItemInFullWrapper.Discounted_Total_Service_Amount__c != null ) ? wrapperItem.projectItemInFullWrapper.Discounted_Total_Service_Amount__c : 0 ) - ( ( idProjectToBilledAmount.get( wrapperItem.projectItemInFullWrapper.Id ) != null ) ? idProjectToBilledAmount.get( wrapperItem.projectItemInFullWrapper.Id ) : 0 ) ) );
                idsOfSelectedProjects.add( wrapperItem.projectItemInFullWrapper.Id );
            }
        }
        getAmount();
    }

    public void getFullWrapperNotPreBilledProjects() {
        wrapoutSearchResults.clear();
        for( Project_Profile__c projectItem: selectedProjectsList ){
            if( !idsOfSelectedProjects.contains( projectItem.Id ) ){
                wrapoutSearchResults.add( new fullWrapper( projectItem, false, false, ( ( (projectItem.Tax_Value__c != null) ? projectItem.Tax_Value__c  : 0 ) ) + ( ( projectItem.Discounted_Total_Service_Amount__c != null ) ? projectItem.Discounted_Total_Service_Amount__c : 0 ) - ( ( idProjectToBilledAmount.get( projectItem.Id ) != null ) ? idProjectToBilledAmount.get( projectItem.Id ) : 0 ) ) );
                idsOfSearchProjects.add( projectItem.Id );
            }
        }
    }

    //Update Project with checked Pre-billed checkbox for Pre-billing Execution in ProjectProfileTrigger
    public void generatePreBilling() {
        List<Project_Profile__c> projectsForPreBilled = new List<Project_Profile__c>();
	String zeroProjectsNames = '';
        try{
            for( fullWrapper wrapperItem: wrapout ){

                if( wrapperItem.isSelected ){
                    wrapperItem.projectItemInFullWrapper.Pre_billed__c = true;
                    if( wrapperItem.amountWithFees == 0 ) zeroProjectsNames += wrapperItem.projectItemInFullWrapper.Name + ',';
		    projectsForPreBilled.add( wrapperItem.projectItemInFullWrapper );
		}
            }
	    zeroProjectsNames = zeroProjectsNames.removeEnd(',');
	    if( zeroProjectsNames != '' ) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no billable services to prebill for ' + zeroProjectsNames));
	    
            ProjectProfileServices.isAllowedPreBillGenerated = true;
            update projectsForPreBilled;
            for( Project_Profile__c item: projectsForPreBilled ){
                if(currentProject.Id == item.Id) currentProject.Pre_billed__c = true;
            }
            wrapout.clear();
            getFullWrapper();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot Pre-billed Project(s): ' + e.getMessage()));
        }
        finally{
            ProjectProfileServices.isAllowedPreBillGenerated = true;
        }

    }

    //Select available for Pre-billing Projects from Database
    public void addNewProject() {
        isSearchPanel = true;
        mRCNumberFilter = null;
        billingCompanyNameFilter = null;
        buildingFilter = null;
        municipalityFilter = null;
        regionId = null;
    }
    //Search Pre-billed Project by criteria
    public void searchAction() {
        queryWhere = buildQueryWhere( billingCompanyNameFilter, mRCNumberFilter, buildingFilter, municipalityFilter, regionId );
        selectedProjectsList = Database.query(buildQuery(queryWhere));
        getFullWrapperNotPreBilledProjects();
    }

    public void AddForPrebilling(){
        getFullWrapper();
        getFullWrapperNotPreBilledProjects();
    }

    public static String buildQueryWhere(final String billingCompanyNameFilter, final String mRCNumberFilter, final String buildingFilter,
                                        final String municipalityFilter, final String regionId ) {
        String queryWhere = 'WHERE Pre_billed__c = false ';

        if ( !String.isEmpty(billingCompanyNameFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Billing_Company_Name__r.Name LIKE \'%' + billingCompanyNameFilter + '%\' ';
        }

        if ( !String.isEmpty(mRCNumberFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Name LIKE \'%'+ mRCNumberFilter +'%\' ';
        }

        if ( !String.isEmpty(municipalityFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Building__r.Municipality__r.Name LIKE \'%'+ municipalityFilter +'%\' ';
        }

        if ( !String.isEmpty(regionId) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Building__r.Municipality__r.Region__r.Id = \''+ regionId +'\' ';
        }

        if ( !String.isEmpty(buildingFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Building__r.Name LIKE \'%'+ buildingFilter +'%\' ';
        }

        return queryWhere;
    }

    public static String buildQuery( String queryWhere ) {

        return  ' Select Proposal__r.Proposal_Awarded_Date__c, Name, Proposal__r.Name, Reimbursable1__c, Reimbursable2__c, Reimbursable3__c, Reimbursable4__c, Discounted_Total_Service_Amount__c, '+
                ' Id, CreatedDate, CreatedById, Project_Name__c, Billing_Company_Name__r.Name, Building__r.Name, No_Met_Data_Scanning__c, No_Document_Shredding__c, Tax_Value__c, No_Reimbursables_After_Pre_Bill__c '+
                ' From Project_Profile__c '+ queryWhere  +' ORDER BY Name LIMIT 700';
    }

    //Redirect to background Project, from what Pre-billing was started.
    public PageReference returnToProjectLevel() {
        return new PageReference( '/' + currentProject.Id );
    }
}