public with sharing class ProposalWizardRosterWrapper implements Comparable {
    public Project_Roster__c record { get; set; }
    public Contact contact { get; set; }
    public String contactName { get; set; }
	public Boolean dnd { get; set; } // MRS 7237
	public Boolean isContact { set; get; }
    public String email { get; set; }
    public Boolean isActive { get { if( isActive == null ) isActive = true; return isActive; } private set; }
	public Boolean notAvaliableForToOrAOrS { get { return (record.Role__c != 'Primary Client Contact' && record.Role__c != 'Billing Client Contact (Bill To)' && record.Role__c != 'Accounting Contact (Mail To)'); } set; } //MRS 7465
    
	public ProposalWizardRosterWrapper( Project_Roster__c roster ) {
        initRosterRecord( roster );
        if( roster.RecordTypeId == ProjectRosterServices.projectRosterRecordTypeMap.get( ProjectRosterServices.TYPE_CONTACT ).id ) {
            initContactRecord( roster );
            this.contactName = roster.Contact__r.Name;
			this.dnd = roster.Contact__r.DND__c;
			this.isContact = true;
            this.email = roster.Contact__r.Email;
        } else {
            this.contactName = roster.User__r.Name;
			this.dnd = false;
			this.isContact = false;
            this.email = roster.User__r.Email;
        }
        if( roster.User_Contact_IsActive__c == false ) {
            this.record.To__c = false;
            this.record.Cc__c = false;
            this.record.Approver__c = false;
            this.isActive = false;
        }
        setDefaultToCcValues();
    }

    public ProposalWizardRosterWrapper( Project_Roster__c roster, Contact contact ) {
        system.debug('contact: ' + contact);
        initRosterRecord( roster );
        this.record.To__c = false;
        this.record.User_Type__c = ProjectRosterServices.USER_TYPE_EX;
        this.record.RecordTypeId = ProjectRosterServices.projectRosterRecordTypeMap.get( ProjectRosterServices.TYPE_CONTACT ).Id;
        initContactRecord( contact );
        this.contactName = contact.Name;
        this.email = contact.Email;
        if( contact.Is_Active__c == false || contact.EmailBouncedDate != null ) {
            this.record.To__c = false;
            this.record.Cc__c = false;
            this.record.Approver__c = false;
            this.isActive = false;
        }
        setDefaultToCcValues();
    }

    public ProposalWizardRosterWrapper( Project_Roster__c roster, Contact contact, String role, Boolean checkToField ) {
        populateRoster( roster, null, contact, role, /*checkToField*/false );
    }

    public ProposalWizardRosterWrapper( Project_Roster__c roster, User user, String role, Boolean checkToField ) {
        populateRoster( roster, user, null, role, /*checkToField*/false );
    }

    public ProposalWizardRosterWrapper( final Project_Roster__c roster, final Contact contact, String role ) {
        populateRoster( roster, null, contact, role, /*true*/false );
    }

    public ProposalWizardRosterWrapper( final Project_Roster__c roster, final User user, String role ) {
        populateRoster( roster, user, null, role, /*true*/false );
    }

    private void populateRoster( Project_Roster__c roster, User user, Contact contact, String role, Boolean checkToField ) {
        initRosterRecord( roster );
        this.record.To__c = checkToField;
        this.record.Is_Read__c = true;
        this.record.Role__c = role;
        if( contact != null ) {
            initContactRecord( contact );
            this.contactName = contact.Name;
            this.email = contact.Email;
            this.record.User_Type__c = ProjectRosterServices.USER_TYPE_EX;
            this.record.RecordTypeId =  ProjectRosterServices.projectRosterRecordTypeMap.get( ProjectRosterServices.TYPE_CONTACT ).Id;
            if( contact.Is_Active__c == false || contact.EmailBouncedDate != null ) {
                this.record.To__c = false;
                this.record.Cc__c = false;
                this.record.Approver__c = false;
                this.isActive = false;
            }
        } else if( user != null ) {
            this.contactName = user.Name;
            this.email = user.Email;
            this.record.RecordTypeId = ProjectRosterServices.projectRosterRecordTypeMap.get( ProjectRosterServices.TYPE_USER ).Id;
            if( user.IsActive == false ) {
                this.record.To__c = false;
                this.record.Cc__c = false;
                this.record.Approver__c = false;
                this.isActive = false;
            }
        }
        setDefaultToCcValues();
    }

    private void initRosterRecord( Project_Roster__c roster ) {
        this.record = new Project_Roster__c( Id = roster.Id,
                                             To__c = roster.To__c,
                                             Cc__c = roster.Cc__c,
                                             Approver__c = roster.Approver__c,
                                             Send_Reminder__c = roster.Send_Reminder__c,
                                             Role__c = roster.Role__c,
                                             User_Type__c = roster.User_Type__c,
                                             RecordTypeId = roster.RecordTypeId,
                                             Is_Read__c = roster.Is_Read__c,
                                             Contact__c = roster.Contact__c,
                                             User__c = roster.User__c );
        if( roster.User__c != null && roster.To__c ) { //MRS-7030 if User has TO checked - recheck it as CC
            this.record.To__c = false;
            this.record.Cc__c = true;
        }
        if( roster.User__c != null && roster.Approver__c ) { //MRS-7030 if User is Approver - recheck it as CC
            this.record.Approver__c = false;
            this.record.Cc__c = true;
        }
    }

    private void initContactRecord( Project_Roster__c roster ) {
        this.contact = new Contact( Id = roster.Contact__c,
                                    Primary_Profession__c = roster.Contact__r.Primary_Profession__c,
                                    MailingStreet = roster.Contact__r.MailingStreet,
                                    DND__c = roster.Contact__r.DND__c );
    }

    private void initContactRecord( Contact contact ) {
        this.contact = new Contact( Id = contact.Id,
                                    Primary_Profession__c = contact.Primary_Profession__c,
                                    MailingStreet = contact.MailingStreet,
                                    DND__c = contact.DND__c );
    }

    private void setDefaultToCcValues() {
        if( this.record.To__c == null ) {
            this.record.To__c = false;
        }
        if( this.record.Cc__c == null ) {
            this.record.Cc__c = false;
        }
        if( this.record.Approver__c == null ) {
            this.record.Approver__c = false;
        }
    }

    public Integer compareTo( Object compareTo ) {
        ProposalWizardRosterWrapper rosterToCompare = (ProposalWizardRosterWrapper)compareTo;
        Map<String, Integer> rolesOrder = new Map<String, Integer>{ ProjectRosterServices.PRIMARY_CLIENT_CONTACT => 1,
                                                                    ProjectRosterServices.BILLING_CLIENT_CONTACT => 2,
                                                                    ProjectRosterServices.ACCOUNTING_CLIENT_CONTACT => 3,
                                                                    ProjectRosterServices.PARTNER => 4,
                                                                    ProjectRosterServices.SALESPERSON => 5,
                                                                    ProjectRosterServices.ACCOUNT_MANAGER => 6,
                                                                    ProjectRosterServices.PROPOSAL_CREATOR_ROLE => 7 };
        return ( this.record.is_Read__c != rosterToCompare.record.is_Read__c
                 ? ( String.valueOf( this.record.is_Read__c ) > String.valueOf( rosterToCompare.record.is_Read__c ) ? -1 : 1 )
                 : ( rolesOrder.get( this.record.Role__c ) != null
                     ? ( rolesOrder.get( this.record.Role__c ) != rolesOrder.get( rosterToCompare.record.Role__c )
                         ? ( rolesOrder.get( this.record.Role__c ) > rolesOrder.get( rosterToCompare.record.Role__c ) ? 1 : -1 )
                         : ( this.record.Role__c > rosterToCompare.record.Role__c ? 1 : -1 ) )
                     : ( rolesOrder.get( rosterToCompare.record.Role__c ) != null
                         ? 1
                         : ( this.record.Role__c > rosterToCompare.record.Role__c ? 1 : -1 ) ) ) );
    }

}