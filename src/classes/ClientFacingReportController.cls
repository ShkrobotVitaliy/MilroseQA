public with sharing class ClientFacingReportController { //MRS 6865

    public Proposal__c baseProposal { get; set; }

    private final String projectProfileId = ApexPages.currentPage().getParameters().get('Id');

    private String queryWhere;

    public Boolean isExcelRendered { get { if(isExcelRendered == null) isExcelRendered = false; return isExcelRendered; } set; }

	public String multiplePrtojects {
		get {
			if(multiplePrtojects == null) multiplePrtojects = '';
			return multiplePrtojects;
		}
		set;
	}

    public List<Project_Profile__c> selectedProjectsList {
        get {
            if( selectedProjectsList == null) selectedProjectsList = new List<Project_Profile__c>();
            return selectedProjectsList;
        }
        set;
    }

    public String selectedSingleProject{
        get{
            if ( String.isEmpty(selectedSingleProject) ){
                selectedSingleProject = 'false';
            }
            return selectedSingleProject;
        }
        set;
    }

    public String selectedMultipleProject{
        get{
            if ( String.isEmpty(selectedMultipleProject) ){
                selectedMultipleProject = 'false';
            }
            return selectedMultipleProject;
        }
        set;
    }

    public List<SelectOption> getRadioItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('true','Sign-Off'));
        options.add(new SelectOption('false','No Sign-Off'));
        return options;
    }

    //Start Execution
    public ClientFacingReportController ( ApexPages.StandardController controller ) {
        try{
            baseProposal =  [ Select Id, Name, Project_Profile__c, Accounting_Contact_Company__c, Billing_Company_Name__c, Primary_Company_Name__c, Address__c, Project_Team__c
                                   From Proposal__c
                                   Where Project_Profile__c = :projectProfileId ];
            baseProposal.Project_Profile__c = projectProfileId;
            baseProposal.Accounting_Contact_Company__c = null;
            baseProposal.Billing_Company_Name__c = null;
            baseProposal.Primary_Company_Name__c = null;
            baseProposal.Address__c = null;
			baseProposal.Project_Team__c = null;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid parameters: ' + e.getMessage()));
        }
    }

    public void searchAction() {
        queryWhere = buildQueryWhere( baseProposal.Project_Profile__c, multiplePrtojects,baseProposal.Primary_Company_Name__c, baseProposal.Address__c, baseProposal.Billing_Company_Name__c, baseProposal.Accounting_Contact_Company__c, baseProposal.Project_Team__c );
		isExcelRendered = false;
        if( baseProposal.Project_Profile__c == null &&
				baseProposal.Accounting_Contact_Company__c == null &&
				baseProposal.Project_Team__c == null && //MRS 7565
				baseProposal.Billing_Company_Name__c == null &&
				baseProposal.Primary_Company_Name__c == null &&
				baseProposal.Address__c == null &&
				String.isBlank(multiplePrtojects) ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'You must enter some values in filter to run this report.') );
        }else {
			selectedProjectsList = Database.query(buildQuery(queryWhere));
			if ( selectedProjectsList.size() == 0 ){
				ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'No matches found.') );	
	        } else if(selectedProjectsList.size() > 250) {
            	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, 'Over 250 matches have been found. Please review you filter settings for more accurate results.') ); //MRS 7555
			} else if( selectedProjectsList.size() > 0 ){
	            isExcelRendered = true;
	        }
		}
    }

    //Redirect to background Project
    public PageReference returnToProjectLevel() {
        return new PageReference( '/' + projectProfileId );
    }

    public static String buildQueryWhere(final String projectFilter, final String multProjects, final String primaryCompanyFilter, final String buildingFilter,
                                        final String billingCompanyFilter, final String accountingCompanyFilter, final String teamFilter) {
        String queryWhere = '';

		Boolean firstIn = true;
		if(!String.isEmpty(projectFilter) || !String.isBlank(multProjects)) {
			queryWhere += 'WHERE (';
			if ( !String.isEmpty(projectFilter) ) {
				queryWhere += 'Id = \'' + projectFilter + '\' ';
				firstIn = false;
			}
			if ( !String.isBlank(multProjects) ) {
				for(String s : multProjects.split(',')) {
					if(!String.isBlank(s)) {
						queryWhere += firstIn ? 'Name LIKE \'%' + s.trim() + '%\' ' : 'OR Name LIKE \'%' + s.trim() + '%\' ';
						firstIn = false;
					}
				}
			}
			queryWhere += ') ';
		}

		System.debug(LoggingLevel.ERROR, 'queryWhere =' + queryWhere);

        if ( !String.isEmpty(primaryCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Primary_Company_Name__c = \''+ primaryCompanyFilter +'\' ';
        }

        if ( !String.isEmpty(buildingFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Building__c = \''+ buildingFilter +'\' ';
        }

        if ( !String.isEmpty(billingCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Billing_Company_Name__c = \''+ billingCompanyFilter +'\' ';
        }

        if ( !String.isEmpty(accountingCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Accounting_Contact_Company__c = \''+ accountingCompanyFilter +'\' ';
        }

		if ( !String.isEmpty(teamFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += '	Project_Team__c = \''+ teamFilter +'\' ';
        }

        return queryWhere;
    }

    public static String buildQuery( String queryWhere ) {
        String generalContractor = 'General Contractor';
        return  ' Select Proposal__r.Proposal_Awarded_Date__c, Name, Proposal__r.Name, Floor_s__c, Project_Name__c, Building_Formula__c, '+
                ' Id, CreatedDate, (Select Role__c, Contact_Account_Name__c From Project_Rosters__r Where Role__c LIKE \'%'+ generalContractor +'%\' limit 1) ' +
                ' From Project_Profile__c '+ queryWhere  +' ORDER BY Name';
    }
}