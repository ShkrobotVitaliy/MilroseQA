public with sharing class CustomTncEditor {
    public static final String CONTRACT_CLAUSES = 'Contract Clauses';
    public static final String TERMS_AND_CONDITIONS = 'Terms And Conditions';

	public Account account { get; set; }
    public TermsAndConditionsServices.TncWrapper contractClauses { get { if( contractClauses == null ) contractClauses = new TermsAndConditionsServices.TncWrapper( TermsAndConditionsServices.initTncRecord( account.Id, CONTRACT_CLAUSES, 1, false ) ); return contractClauses; } set; }
    public List<TermsAndConditionsServices.TncWrapper> termsAndConditions { get { if( termsAndConditions == null ) termsAndConditions = new List<TermsAndConditionsServices.TncWrapper>(); return termsAndConditions; } set; }
    public Boolean isEditable { get; set; }
    public Boolean isReadable { get; set; }
    private Set<Id> tncIdsToDelete = new Set<Id>();

    public CustomTncEditor( ApexPages.StandardController stdController ) {
        account = getAccount( (Account)stdController.getRecord() );

        Profile profile = UserServices.getProfile();
        CustomPermissionsTCM__c customPermissionsTCM = CustomPermissionsTCM__c.getValues( UserInfo.getName() );

        isEditable = new Set<String>{ UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
                                      UserServices.PROFILE_OPERATIONS_MANAGER }.contains( profile.Name );
        isReadable = new Set<String>{ UserServices.PROFILE_PROPOSAL_SPECIALIST,
                                      UserServices.PROFILE_ACCOUNT_MANAGER,
                                      UserServices.PROFILE_CFO,
                                      UserServices.PROFILE_COO,
                                      UserServices.PROFILE_PARTNER }.contains( profile.Name );

        if( !isEditable && CustomPermissionsTCM != null ) isEditable = ( Id.valueOf(customPermissionsTCM.Id__c) == UserInfo.getUserId() );

        if( !isReadable && !isEditable ) {
            MilroseDevHelper.addMessage( 'You have no access to this page' );
        } else {
            Map<Integer, Terms_And_Conditions__c> pageNumberToTncRecord = new Map<Integer, Terms_And_Conditions__c>();
            for( Terms_And_Conditions__c tncItem : TermsAndConditionsServices.getTermsAndConditionsByAccountId( account.Id ) ) { //get contract clauses and tncs from DB
                if( tncItem.Type__c == CONTRACT_CLAUSES && contractClauses.record.Id == null ) {
                    contractClauses = new TermsAndConditionsServices.TncWrapper( tncItem ); //populate contract clauses
                } else if( tncItem.Type__c == TERMS_AND_CONDITIONS && tncItem.Page_Number__c != null && pageNumberToTncRecord.get( Integer.valueOf( tncItem.Page_Number__c ) ) == null ) {
                    pageNumberToTncRecord.put( Integer.valueOf( tncItem.Page_Number__c ), tncItem );
                } else {
                    tncIdsToDelete.add( tncItem.Id ); //remove duplicates or bad records
                }
            }
            if( pageNumberToTncRecord.get( 1 ) == null ) { //populate tncs if no data in DB
                pageNumberToTncRecord.put( 1, TermsAndConditionsServices.initTncRecord( account.Id, TERMS_AND_CONDITIONS, 1, true ) );
            }
            List<Integer> pageNumbers = new List<Integer>( pageNumberToTncRecord.keySet() );
            pageNumbers.sort();
            for( Integer pageNumber = 1; pageNumber <= pageNumbers[ pageNumbers.size() - 1 ]; pageNumber++ ) { //add pages with intermediate numbers that are not in DB for any reason
                Terms_And_Conditions__c tncRecord = pageNumberToTncRecord.get( pageNumber );
                if( tncRecord == null ) {
                    tncRecord = TermsAndConditionsServices.initTncRecord( account.Id, TERMS_AND_CONDITIONS, pageNumber, true );
                    pageNumberToTncRecord.put( pageNumber, tncRecord );
                }
                termsAndConditions.add( new TermsAndConditionsServices.TncWrapper( tncRecord ) ); //populate tncs
            }
        }
    }

    public void addPage() {
        if( isEditable ) {
            termsAndConditions.add( new TermsAndConditionsServices.TncWrapper( TermsAndConditionsServices.initTncRecord( account.Id, TERMS_AND_CONDITIONS, termsAndConditions.size() + 1, true ) ) );
        }
    }

    public Integer pageNumberToDelete { get; set; }
    public void deletePage() {
        if( isEditable ) {
            if( pageNumberToDelete != null && pageNumberToDelete != 1 ) {
                List<TermsAndConditionsServices.TncWrapper> newTncWrappers = new List<TermsAndConditionsServices.TncWrapper>();
                for( TermsAndConditionsServices.TncWrapper tncWrapperItem : termsAndConditions ) {
                    Integer currentPageNumber = Integer.valueOf( tncWrapperItem.record.Page_Number__c );
                    if( currentPageNumber < pageNumberToDelete ) {
                        newTncWrappers.add( tncWrapperItem );
                    } else if( currentPageNumber == pageNumberToDelete ) {
                        if( tncWrapperItem.record.Id != null ) {
                            tncWrapperItem.record.Text_1__c = '';
                            tncWrapperItem.record.Text_2__c = '';
                            tncIdsToDelete.add( tncWrapperItem.record.Id );
                        }
                    } else if( currentPageNumber > pageNumberToDelete ) {
                        tncWrapperItem.record.Page_Number__c = currentPageNumber - 1;
                        newTncWrappers.add( tncWrapperItem );
                    }
                }
                termsAndConditions = newTncWrappers;
            }
        }
    }

    public void populateDefault() {
        if( contractClauses.record.Id != null ) {
            tncIdsToDelete.add( contractClauses.record.Id );
        }
        for( TermsAndConditionsServices.TncWrapper tncWrapperItem : termsAndConditions ) {
            if( tncWrapperItem.record.Id != null ) {
                tncIdsToDelete.add( tncWrapperItem.record.Id );
            }
        }
        contractClauses = TermsAndConditionsServices.populateStandardContractClauses( new Proposal__c( Billing_Company_Name__c = account.Id ) );
        termsAndConditions = TermsAndConditionsServices.populateStandardTermsAndConditions( new Proposal__c( Billing_Company_Name__c = account.Id ) );
    }

    public PageReference goBack() {
        PageReference pr = new PageReference( '/' + account.Id );
        pr.setRedirect( true );
        return pr;
    }

    public void preview() {
        save( false );
    }

    public PageReference save() {
        return save( true );
    }

    private PageReference save( Boolean returnPageReference ) {
        if( isEditable ) {
            List<Terms_And_Conditions__c> tncsToSave = new List<Terms_And_Conditions__c>();
            try {
                addTncForSaving( tncsToSave, contractClauses, false );
                for( TermsAndConditionsServices.TncWrapper tncWrapperItem : termsAndConditions ) {
                    addTncForSaving( tncsToSave, tncWrapperItem, true );
                }
            } catch( Exception e ) {
                MilroseDevHelper.addMessage( e.getMessage(), MilroseDevHelper.INFO );
                return null;
            }
            try {
                tncIdsToDelete.remove( null );
                if( !tncIdsToDelete.isEmpty() ) {
                    List<Terms_And_Conditions__c> tncsToDelete = new List<Terms_And_Conditions__c>();
                    for( Id tncIdItem : tncIdsToDelete ) {
                        if( tncIdItem != null ) {
                            tncsToDelete.add( new Terms_And_Conditions__c( Id = tncIdItem ) );
                        }
                    }
                    Database.delete( tncsToDelete );
                }
                UPSERT tncsToSave;
                UPDATE new Account( Id = account.Id, TncStartDate__c = account.TncStartDate__c, TncEndDate__c = account.TncEndDate__c );
            } catch( Exception e ) {
                MilroseDevHelper.addMessage( 'Could not save the data: ' + e.getMessage() );
                return null;
            }
        }
        if( returnPageReference ) {
            return goBack();
        } else {
            return null;
        }
    }

    private void addTncForSaving( List<Terms_And_Conditions__c> tncsToSave, TermsAndConditionsServices.TncWrapper tncWrapperForSaving, Boolean checkText2 ) {
        if( tncWrapperForSaving.record.Id == null ) {
            if( ( tncWrapperForSaving.record.Text_1__c != null && tncWrapperForSaving.record.Text_1__c != '' ) ||
                ( checkText2 && ( tncWrapperForSaving.record.Text_2__c != null && tncWrapperForSaving.record.Text_2__c != '' ) ) ) {
                if( account.TncStartDate__c == null || account.TncEndDate__c == null ) {
                    throw new ErrorException( 'You have to populate Custom T&Cs Start and End Dates to perform further.' );
                }
                tncsToSave.add( tncWrapperForSaving.record );
            }
        } else {
            if( ( tncWrapperForSaving.record.Text_1__c != null && tncWrapperForSaving.record.Text_1__c != '' ) ||
                ( checkText2 && ( tncWrapperForSaving.record.Text_2__c != null && tncWrapperForSaving.record.Text_2__c != '' ) ) ) {
                if( account.TncStartDate__c == null || account.TncEndDate__c == null ) {
                    throw new ErrorException( 'You have to populate Custom T&Cs Start and End Dates to perform further.' );
                }
                tncsToSave.add( tncWrapperForSaving.record );
            } else {
                if( tncWrapperForSaving.record.Id != null ) {
                    tncIdsToDelete.add( tncWrapperForSaving.record.Id );
                }
            }
        }
    }

    private Account getAccount( Account account ) {
        if( account.Id != null ) {
            List<Account> accounts = [ SELECT TncStartDate__c, TncEndDate__c
                                       FROM Account
                                       WHERE Id = : account.Id ];
            if( !accounts.isEmpty() ) {
                return accounts[0];
            }
        } else {
            MilroseDevHelper.addMessage( 'The specified Account is invalid' );
            isEditable = false;
        }
        return account;
    }

}