public with sharing class ContactController {

    public Contact contact {get; set;}
    public String selectedAccountId {get;set;}
    public Map<Id, String> accountIdToName { get { if(accountIdToName == null) accountIdToName = new Map<Id, String>(); return accountIdToName; } set; }
    public Boolean isSavedContact {get;set;}
    public Boolean canAddAsbestos {get;set;}
    public String primaryClientCompany = '';
    public String primaryBillingCompany = '';
    public String accountingContactCompany = '';
    private Set<String> accountIds = new Set<String>();

    public ContactController(ApexPages.StandardController controller) {
        this.contact = new Contact();
        this.primaryClientCompany = ApexPages.currentPage().getParameters().get('primaryClientCompany');
        this.primaryBillingCompany = ApexPages.currentPage().getParameters().get('primaryBillingCompany');
        this.accountingContactCompany = ApexPages.currentPage().getParameters().get('accountingContactCompany');
        this.canAddAsbestos = ApexPages.currentPage().getParameters().get('canAddAsbestos') == 'true' ? true : false;
        this.valid();
    }

    private void valid() {
        if(this.primaryBillingCompany != '' && this.primaryBillingCompany != null) {
            this.accountIds.add(this.primaryBillingCompany);
            this.selectedAccountId = this.primaryBillingCompany;
        }
        if(this.primaryClientCompany != '' && this.primaryClientCompany != null) {
            this.accountIds.add(this.primaryClientCompany);
            this.selectedAccountId = this.primaryClientCompany;
        }
        if(this.accountingContactCompany != '' && this.accountingContactCompany != null) {
            this.accountIds.add(this.accountingContactCompany);
            this.selectedAccountId = this.accountingContactCompany;
        }
        if( selectedAccountId == null ){
            if( canAddAsbestos ){
                selectedAccountId = 'asbestos';
            } else {
                selectedAccountId = 'requestedBy';
            }
        } else {
            this.contact.AccountId = this.selectedAccountId;
        }

    }

    public List<SelectOption> getAccountOptions() {
        List<SelectOption> options = new List<SelectOption>();
        for(Account ac : [SELECT Id, Name FROM Account WHERE Id IN : this.accountIds]) {
            options.add(new SelectOption(ac.Id,ac.Name));
            accountIdToName.put(ac.Id, ac.Name);
        }
        options.add(new SelectOption('requestedBy','Contact for Requested By'));
        if( canAddAsbestos ){ options.add(new SelectOption('asbestos','Asbestos Investigator')); }
        return options;
    }

    public PageReference addNewContactAction() {
        if( String.isBlank(contact.FirstName) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Required field is missing: [First Name]' ) );
            return null;
        }
        try {
            insert this.contact;
            this.isSavedContact = true;
        } catch(System.DMLException ex) {
            ApexPages.addMessage(new ApexPages.Message( ApexPages.Severity.ERROR,  ex.getDmlMessage(0)));
        }
        return null;
    }

    public PageReference companyNameAction() {
        system.debug('this.selectedAccountId:' + this.selectedAccountId);
        if( this.selectedAccountId != 'requestedBy' && this.selectedAccountId != 'asbestos' ) {
            this.contact.AccountId = this.selectedAccountId;
        } else {
            this.contact.AccountId = null;
        }
        return null;
    }
}