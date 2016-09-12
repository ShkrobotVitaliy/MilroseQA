public with sharing class AddContactToSendCC {
    private final String proposalId { get; set; }
    private final String primaryCompany { get; set; }
    private final String billingCompany { get; set; }
    private final String accountingContact { get; set; }

    private List<ContactWrapper> contactWrapperList { get; set; }

    public Boolean noErrorsAddingContacts { get { if(noErrorsAddingContacts == null) noErrorsAddingContacts = true; return noErrorsAddingContacts; } set; }

    public String emailToCC { get; set; }

    public AddContactToSendCC() {
        this.contactWrapperList = new List<ContactWrapper>();

        this.primaryCompany    = ApexPages.currentPage().getParameters().get( 'primaryCompany' );
        this.billingCompany    = ApexPages.currentPage().getParameters().get( 'billingCompany' );
        this.accountingContact = ApexPages.currentPage().getParameters().get( 'accountingContact' );
        this.proposalId        = ApexPages.currentPage().getParameters().get( 'proposalId' );

    }

    public List<ContactWrapper> getContacts() {

        List<String> ids = new List<String>();
        if( !String.isBlank( this.primaryCompany ) ) {
            ids.add( this.primaryCompany );
        }
        if( !String.isBlank( this.billingCompany ) ) {
            ids.add( this.billingCompany );
        }
        if( !String.isBlank( this.accountingContact ) ) {
            ids.add( this.accountingContact );
        }

        List<Contact> contacts = new List<Contact>( [ SELECT LastName, FirstName, First_Name__c, Email, AccountId
                                                      FROM Contact
                                                      WHERE AccountId IN : ids
                                                          AND Is_Active__c = true
                                                          AND Email != null
                                                      ORDER BY First_Name__c, FirstName, LastName, AccountId, Email
                                                      LIMIT 1000 ] );

        this.contactWrapperList = new List<ContactWrapper>();
        for( Contact item : contacts ) {
            this.contactWrapperList.add( new ContactWrapper(item) );
        }System.debug( LoggingLevel.Error, 'contactWrapperList = '+contactWrapperList.size());
        return this.contactWrapperList;
    }

    public void addContact() {System.debug( LoggingLevel.Error, 'contactWrapperList = '+contactWrapperList.size());
        noErrorsAddingContacts = true;
        List<Proposal__c> proposals;

        if( String.isBlank( this.proposalId ) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please save Proposal!'));
            noErrorsAddingContacts = false;
            return;
        }

        proposals = new List<Proposal__c>( [ SELECT Send_Copy_To__c, Id
                                             FROM Proposal__c
                                             WHERE Id =: this.proposalId ] );

        if( proposals.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Proposal does not exist for Id = ' + this.proposalId));
            noErrorsAddingContacts = false;
            return;
        }

        if( null == proposals.get(0).Send_Copy_To__c ) {
            proposals.get(0).Send_Copy_To__c = '';
        }

        if( '' != proposals.get(0).Send_Copy_To__c ) {
            proposals.get(0).Send_Copy_To__c += '; ';
        }

        for( ContactWrapper item : this.contactWrapperList ) {
            if( item.selected && String.isNotBlank( item.contact.Email ) ) {
                proposals.get(0).Send_Copy_To__c += item.contact.Email + '; ';
            }
        }

        proposals.get(0).Send_Copy_To__c = proposals.get(0).Send_Copy_To__c.removeEnd('; ');

        try {
            UPDATE proposals;
            this.emailToCC = proposals.get(0).Send_Copy_To__c;
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check proposal!'));
            noErrorsAddingContacts = false;
            return;
        }/*System.debug( LoggingLevel.Error, 'contactWrapperList = '+contactWrapperList.size());*/
    }

    public class ContactWrapper {
        public Contact contact { get; private set; }
        public Boolean selected { get; set; }

        public ContactWrapper( final Contact contact ) {
            this.selected = false;
            this.contact = contact;
        }
    }

}