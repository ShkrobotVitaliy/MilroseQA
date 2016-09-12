public with sharing class DepositDetailController {

    public Boolean isValid { get; private set; }
    public Deposit_Invoice__c parent { get; private set; }
    public List<DDP_Helper__c> table { get; private set; }
    public DDP_Helper__c totals { get; private set; }

    public DepositDetailController() {
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        if( parentId != null && parentId instanceOf Id ) {
            String objectType = String.valueOf( Id.valueOf(parentId).getsObjectType() );
            if( objectType == 'Deposit_Invoice__c' ) {
                parent = getParent( parentId );
                if( parent == null ) {
                    MilroseDevHelper.addMessage('No related Deposit Invoice found.');
                    isValid = false;
                    return;
                } else {
                    getReportData( parent );
                }
            } else {
                MilroseDevHelper.addMessage('Invalid Id of Deposit Invoice.');
                isValid = false;
                return;
            }
        } else {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
    }

    public String invoiceId { get { return parent.Deposit_Invoice_Number__c != null ? parent.Deposit_Invoice_Number__c : ''; } }
    public Date invoiceDate { get { return parent.Deposit_Invoice_Date__c != null ? parent.Deposit_Invoice_Date__c : Date.today(); } }
    public String proposalName { get { return parent.Proposal__r.Name != null ? parent.Proposal__r.Name : ''; } }
    public String clientProject { get { return parent.Proposal__r.Client_Project__c != null ? parent.Proposal__r.Client_Project__c : ''; } }
    public Boolean showMailTo { get { return parent.Proposal__r.Delivery_Method__c != null && parent.Proposal__r.Delivery_Method__c == 'Email'; } }
    public String floors { get { return parent.Proposal__r.Floor_s__c != null ? parent.Proposal__r.Floor_s__c : ''; } }
    public String projectName { get { return parent.Proposal__r.Project_Name__c != null ? parent.Proposal__r.Project_Name__c : ''; } }

    public String address1 { get { return parent.Proposal__r.Address_Building_AKA__c != null ? parent.Proposal__r.Address_Building_AKA__c : ''; } }
    public String address2 { get { return getAddress2(); } }

    public String accountManagerName {
        get {
            return getContactName( null,
                                   parent.Proposal__r.Account_Executive__r.FirstName,
                                   parent.Proposal__r.Account_Executive__r.LastName );
        }
    }

    public String accountingCompanyName {
        get {
            if( parent.Accounting_Contact_Company__c != null ) {
                return parent.Accounting_Contact_Company__r.Name;
            } else {
                return parent.Proposal__r.Accounting_Contact_Company__r.Name != null
                       ? parent.Proposal__r.Accounting_Contact_Company__r.Name
                       : '';
            }
        }
    }

    public String accountingContactAddress {
        get {
            if( parent.Accounting_Contact__c != null ) {
                return getContactAddress( parent.Accounting_Contact__r.MailingStreet,
                                          parent.Accounting_Contact__r.MailingCity,
                                          parent.Accounting_Contact__r.MailingState,
                                          parent.Accounting_Contact__r.MailingPostalCode );
            } else {
                return getContactAddress( parent.Proposal__r.Accounting_Contact__r.MailingStreet,
                                          parent.Proposal__r.Accounting_Contact__r.MailingCity,
                                          parent.Proposal__r.Accounting_Contact__r.MailingState,
                                          parent.Proposal__r.Accounting_Contact__r.MailingPostalCode );
            }
        }
    }

    public String accountingContactName {
        get {
            if( parent.Accounting_Contact__c != null ) {
                return getContactName( parent.Accounting_Contact__r.Salutation,
                                       parent.Accounting_Contact__r.FirstName,
                                       parent.Accounting_Contact__r.LastName );
            } else {
                return getContactName( parent.Proposal__r.Accounting_Contact__r.Salutation,
                                       parent.Proposal__r.Accounting_Contact__r.FirstName,
                                       parent.Proposal__r.Accounting_Contact__r.LastName );
            }
        }
    }

    public String billingCompanyName {
        get {
            if( parent.Billing_Company_Name__c != null ) {
                return parent.Billing_Company_Name__r.Name;
            } else {
                return parent.Proposal__r.Billing_Company_Name__r.Name != null
                       ? parent.Proposal__r.Billing_Company_Name__r.Name
                       : '';
            }
        }
    }
    public String billingContactAddress {
        get {
            if( parent.Billing_Company_Contact__c != null ) {
                return getContactAddress( parent.Billing_Company_Contact__r.MailingStreet,
                                          parent.Billing_Company_Contact__r.MailingCity,
                                          parent.Billing_Company_Contact__r.MailingState,
                                          parent.Billing_Company_Contact__r.MailingPostalCode );
            } else {
                return getContactAddress( parent.Proposal__r.Billing_Company_Contact__r.MailingStreet,
                                          parent.Proposal__r.Billing_Company_Contact__r.MailingCity,
                                          parent.Proposal__r.Billing_Company_Contact__r.MailingState,
                                          parent.Proposal__r.Billing_Company_Contact__r.MailingPostalCode );
            }
        }
    }
    public String billingContactName {
        get {
            if( parent.Billing_Company_Contact__c != null ) {
                return getContactName( parent.Billing_Company_Contact__r.Salutation,
                                       parent.Billing_Company_Contact__r.FirstName,
                                       parent.Billing_Company_Contact__r.LastName );
            } else {
                return getContactName( parent.Proposal__r.Billing_Company_Contact__r.Salutation,
                                       parent.Proposal__r.Billing_Company_Contact__r.FirstName,
                                       parent.Proposal__r.Billing_Company_Contact__r.LastName );
            }
        }
    }

    private String getContactAddress( String address1, String city, String state, String zip ) {
            String result = '';
            result += address1 != null ? address1 : '';
            result += ( !String.isBlank( result ) ) ? '<br/>' : '';
            result += city != null ? city : '';
            result += ( city != null && ( state != null || zip != null ) ) ? ', ' : '';
            result += state != null ? state : '';
            result += ( state != null && zip != null ) ? ' ' : '';
            result += zip != null ? zip : '';
            return result;
    }

    private String getContactName( String salutation, String firstName, String lastName ) {
        String result = '';
        result += salutation != null ? salutation : '';
        result += ( salutation != null && firstName != null ) ? ' ' : '';
        result += firstName != null ? firstName : '';
        result += ( ( firstName != null || salutation != null ) && lastName != null ) ? ' ' : '';
        result += lastName != null ? lastName : '';
        return result;
    }

    private Deposit_Invoice__c getParent( Id parentId ) {
        String query;
        query  = 'SELECT Id, Deposit_Invoice_Number__c, Deposit_Invoice_Date__c, Deposit_Invoice_Type__c, ';
        query +=        'Deposit_Amount__c, Amount_Paid__c, Amount_Due__c, Amount_Remaining__c, ';

        query +=        'Proposal__r.Name, Proposal__r.Client_Project__c, Proposal__r.Retainer_Amount__c, Proposal__r.Floor_s__c, ';
        query +=        'Proposal__r.Account_Executive__r.FirstName, Proposal__r.Account_Executive__r.LastName, ';
        query +=        'Proposal__r.Project_Name__c, Proposal__r.Address_Building_AKA__c, Proposal__r.Delivery_Method__c, ';
        query +=        'Proposal__r.Building_AKA__c, Proposal__r.Building_AKA__r.Building__r.City__c, Proposal__r.Building_AKA__r.Building__r.State__c, Proposal__r.Building_AKA__r.Building__r.PostalCode__c, ';
        query +=        'Proposal__r.Address__r.City__c, Proposal__r.Address__r.State__c, Proposal__r.Address__r.PostalCode__c, ';

        query +=        'Accounting_Contact_Company__c, ';
        query +=        'Accounting_Contact_Company__r.Name, ';
        query +=        'Proposal__r.Accounting_Contact_Company__r.Name, ';

        query +=        'Accounting_Contact__c, ';
        query +=        'Accounting_Contact__r.MailingStreet, ';
        query +=        'Accounting_Contact__r.MailingCity, Accounting_Contact__r.MailingState, ';
        query +=        'Accounting_Contact__r.MailingPostalCode, Accounting_Contact__r.Salutation, ';
        query +=        'Accounting_Contact__r.FirstName, Accounting_Contact__r.LastName, ';
        query +=        'Proposal__r.Accounting_Contact__r.MailingStreet, ';
        query +=        'Proposal__r.Accounting_Contact__r.MailingCity, Proposal__r.Accounting_Contact__r.MailingState, ';
        query +=        'Proposal__r.Accounting_Contact__r.MailingPostalCode, Proposal__r.Accounting_Contact__r.Salutation, ';
        query +=        'Proposal__r.Accounting_Contact__r.FirstName, Proposal__r.Accounting_Contact__r.LastName, ';

        query +=        'Billing_Company_Name__c, ';
        query +=        'Billing_Company_Name__r.Name, ';
        query +=        'Proposal__r.Billing_Company_Name__r.Name, ';

        query +=        'Billing_Company_Contact__c, ';
        query +=        'Billing_Company_Contact__r.MailingStreet, Billing_Company_Contact__r.MailingCity, ';
        query +=        'Billing_Company_Contact__r.MailingState, Billing_Company_Contact__r.MailingPostalCode, ';
        query +=        'Billing_Company_Contact__r.Salutation,  Billing_Company_Contact__r.FirstName, ';
        query +=        'Billing_Company_Contact__r.LastName, ';
        query +=        'Proposal__r.Billing_Company_Contact__r.MailingStreet, Proposal__r.Billing_Company_Contact__r.MailingCity, ';
        query +=        'Proposal__r.Billing_Company_Contact__r.MailingState, Proposal__r.Billing_Company_Contact__r.MailingPostalCode, ';
        query +=        'Proposal__r.Billing_Company_Contact__r.Salutation,  Proposal__r.Billing_Company_Contact__r.FirstName, ';
        query +=        'Proposal__r.Billing_Company_Contact__r.LastName ';

        query += 'FROM Deposit_Invoice__c ';
        query += 'WHERE ';
        query += 'Id =\'' + parentId + '\'';
        query += 'LIMIT 1';

        List<Deposit_Invoice__c> depositInvoices = Database.query( query );
        if( !depositInvoices.isEmpty() ) {
            return depositInvoices[0];
        } else {
            return new Deposit_Invoice__c();
        }
    }

    private void getReportData( Deposit_Invoice__c parent ) {
        if( isValid ) {
            table = new List<DDP_Helper__c>();
            Set<Id> matchingReferenceIds = new Set<Id>();
            for( c2g__codaCashMatchingHistory__c cashMatchingHistoryItem : [ SELECT c2g__MatchingReference__c
                                                                             FROM c2g__codaCashMatchingHistory__c
                                                                             WHERE c2g__TransactionLineItem__r.Deposit_Invoice__c = : parent.Id ] ) {
                matchingReferenceIds.add( cashMatchingHistoryItem.c2g__MatchingReference__c );
            }
            matchingReferenceIds.remove( null );

            Decimal total = 0.00;
            table.add( new DDP_Helper__c( Text1__c = parent.Deposit_Invoice_Number__c,
                                          Text2__c = '',
                                          Currency1__c = parent.Amount_Paid__c ) ); // MRS-4814 add first row always
            total += table[table.size()-1].Currency1__c;
            if( !matchingReferenceIds.isEmpty() ) { //cash entries found
                List<c2g__codaCashMatchingHistory__c> cashMatchingHistories = [ SELECT c2g__TransactionLineItem__r.Deposit_Invoice__r.Deposit_Invoice_Number__c,
                                                                                       c2g__TransactionLineItem__r.Deposit_Invoice__r.Amount_Paid__c,
                                                                                       c2g__TransactionLineItem__r.Pro_forma_Invoice__c, c2g__HomeValue__c
                                                                                FROM c2g__codaCashMatchingHistory__c
                                                                                WHERE c2g__MatchingReference__c IN : matchingReferenceIds
                                                                                ORDER BY c2g__TransactionLineItem__r.Deposit_Invoice__c ASC NULLS LAST,
                                                                                         CreatedDate ];
                for( c2g__codaCashMatchingHistory__c cashMatchingHistoryItem : cashMatchingHistories ) {
                    /*if( !String.isBlank( cashMatchingHistoryItem.c2g__TransactionLineItem__r.Pro_forma_Invoice__c ) ||
                        !String.isBlank( cashMatchingHistoryItem.c2g__TransactionLineItem__r.Deposit_Invoice__r.Deposit_Invoice_Number__c ) ) {*/
                    if( !String.isBlank( cashMatchingHistoryItem.c2g__TransactionLineItem__r.Pro_forma_Invoice__c ) &&
                         String.isBlank( cashMatchingHistoryItem.c2g__TransactionLineItem__r.Deposit_Invoice__r.Deposit_Invoice_Number__c ) ) {
                        table.add( new DDP_Helper__c( Text1__c = ''/*cashMatchingHistoryItem.c2g__TransactionLineItem__r.Deposit_Invoice__r.Deposit_Invoice_Number__c*/,
                                                      Text2__c = cashMatchingHistoryItem.c2g__TransactionLineItem__r.Pro_forma_Invoice__c,
                                                      Currency1__c = String.isBlank( cashMatchingHistoryItem.c2g__TransactionLineItem__r.Pro_forma_Invoice__c )
                                                                     ? cashMatchingHistoryItem.c2g__TransactionLineItem__r.Deposit_Invoice__r.Amount_Paid__c
                                                                     : -1 * cashMatchingHistoryItem.c2g__HomeValue__c ) );
                        total += table[table.size()-1].Currency1__c;
                    }
                }
            } else { //no cash entries found - show amount remaining as total
                total = parent.Amount_Remaining__c;
            }
            totals = new DDP_Helper__c( Currency1__c = total );
        }
        return;
    }

    private String getAddress2() {
        String address = '';
        if( parent.Proposal__r.Building_AKA__c != null ) {
            address = ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.City__c) ? parent.Proposal__r.Building_AKA__r.Building__r.City__c : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.City__c) && ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.State__c) || !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.State__c) ? parent.Proposal__r.Building_AKA__r.Building__r.State__c : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.State__c) && !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Building_AKA__r.Building__r.PostalCode__c) ? parent.Proposal__r.Building_AKA__r.Building__r.PostalCode__c : '' );
        } else {
            address = ( !String.isEmpty(parent.Proposal__r.Address__r.City__c) ? parent.Proposal__r.Address__r.City__c : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Address__r.City__c) && ( !String.isEmpty(parent.Proposal__r.Address__r.State__c) || !String.isEmpty(parent.Proposal__r.Address__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(parent.Proposal__r.Address__r.State__c) ? parent.Proposal__r.Address__r.State__c : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Address__r.State__c) && !String.isEmpty(parent.Proposal__r.Address__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(parent.Proposal__r.Address__r.PostalCode__c) ? parent.Proposal__r.Address__r.PostalCode__c : '' );
        }
        return address;
    }

}