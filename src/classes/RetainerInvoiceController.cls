public without sharing class RetainerInvoiceController {

    public Boolean isValid { get; private set; }
    public List<RetainerInvoiceWrapper> invoices { get; set; }
    public Boolean isLightCo { get; private set; }
    public Id lightCoId { get; private set; }

    public RetainerInvoiceController() {
        invoices = new List<RetainerInvoiceWrapper>();
        List<Deposit_Invoice__c> depositInvoices;
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        if( parentId != null && parentId instanceOf Id ) {
            String objectType = String.valueOf( Id.valueOf(parentId).getsObjectType() );
            Boolean createForChangeOrders = ApexPages.currentPage().getParameters().get('type') == 'co';
            if( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME || objectType == 'Deposit_Invoice__c' ) {
                initLightCoData( parentId, objectType );
                depositInvoices = getInvoices( parentId, objectType, createForChangeOrders );
                if( depositInvoices == null || depositInvoices.isEmpty() ) {
                    MilroseDevHelper.addMessage('No related Deposit Invoice found.');
                    isValid = false;
                    return;
                } else {
                    for( Deposit_Invoice__c invoice : depositInvoices ) {
						if(invoice.Amount_Due__c != null && invoice.Amount_Due__c > 0) { //MRS 7573
                        	invoices.add( new RetainerInvoiceWrapper( invoice ) );
						}
                    }
                }
            } else {
                MilroseDevHelper.addMessage('Invalid Id of Deposit Invoice / Proposal.');
                isValid = false;
                return;
            }
        } else {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
    }

    private void initLightCoData( Id parentId, String objectType ) {
        if( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME ) {
            String lightCoParam = ApexPages.currentPage().getParameters().get('light');
            if( !String.isBlank( lightCoParam ) && lightCoParam instanceOf Id ) {
                lightCoId = lightCoParam;
            }
        }
        isLightCo = lightCoId != null;
    }

    public class RetainerInvoiceWrapper {
        public Deposit_Invoice__c parent { get { if( parent == null ) parent = new Deposit_Invoice__c(); return parent; } set; }

        public RetainerInvoiceWrapper( Deposit_Invoice__c parent ) {
            this.parent = parent;
        }

        public String invoiceId { get { return parent.Deposit_Invoice_Number__c != null ? parent.Deposit_Invoice_Number__c : ''; } }
        public Date invoiceDate { get { return parent.Deposit_Invoice_Date__c != null ? parent.Deposit_Invoice_Date__c : Date.today(); } }
        public String proposalName { get { return parent.Proposal__r.Name != null ? parent.Proposal__r.Name : ''; } }
        public String clientProject { get { return parent.Proposal__r.Client_Project__c != null ? parent.Proposal__r.Client_Project__c : ''; } }
        public Boolean showMailTo { get { return parent.Proposal__r.Delivery_Method__c != null && parent.Proposal__r.Delivery_Method__c == 'Email'; } }
        public String floors { get { return parent.Proposal__r.Floor_s__c != null ? parent.Proposal__r.Floor_s__c : ''; } }
        public String projectName { get { return parent.Proposal__r.Project_Name__c != null ? parent.Proposal__r.Project_Name__c : ''; } }
        public String projectMrcName { get { return parent.Project_Profile__c != null ? parent.Project_Profile__r.Name : ''; } }
        public String refNumber { get { return parent.Change_Order__c == null ? 'Base Proposal' : 'CO#' + String.valueOf( parent.Change_Order__r.Number__c ); } }

        public String address1 { get { return parent.Proposal__r.Address_Building_AKA__c != null ? parent.Proposal__r.Address_Building_AKA__c : ''; } }
        public String address2 { get { return getAddress2(); } }

		public List<Additional_Reimbursable__c> addReimbursables { //MRS 7415
			get {

				if(isRetainerReimbursables && parent.Change_Order__c != null) {
					return [SELECT Description__c, Amount__c FROM Additional_Reimbursable__c WHERE Change_Order__c = :parent.Change_Order__c AND Send_Muni_Fee_Invoice__c = true ORDER BY Description__c];
				} else if(isRetainerReimbursables && parent.Proposal__c != null) {
					return [SELECT Description__c, Amount__c FROM Additional_Reimbursable__c WHERE Proposal__c = :parent.Proposal__c AND Send_Muni_Fee_Invoice__c = true ORDER BY Description__c];
				}
				return new List<Additional_Reimbursable__c>();
			}
			set;
		}

        public String depositPercentage {
            get {
                return ( parent.Deposit_Invoice_Type__c == DepositInvoiceServices.SERVICE_RETAINER_TYPE
                         ? ( parent.Proposal__r.Retainer_Amount__c != null
                             ? String.valueOf( parent.Proposal__r.Retainer_Amount__c ) + '% '
                             : '0% ' )
                         : '' );
            }
        }

		public Boolean isRetainerReimbursables { //MRS 7415
			get {
				return (depositType == 'Municipal Fee Deposit - Additional Reimbursables'); //MRS 7498
			}
		}

        public String depositType {
            get {
                String type = '';
                if( parent.Deposit_Invoice_Type__c == DepositInvoiceServices.SERVICE_RETAINER_TYPE ) {
                    type = parent.Deposit_Invoice_Type__c;
                } else {
                    type = 'Municipal Fee Deposit'; //MRS 7498
                    if(parent.For_Add_Reimbursables__c) {
						type += ' - Additional Reimbursables';
                    } else if(parent.Is_Created_From_Code__c) { //MRS 7298
                        type += ' - DOB Variance Fees';
                    }
                }
                return type;
            }
        }

        public Decimal quantity { get { return 1.00; } }
        public Decimal depositAmount { get { return parent.Deposit_Amount__c != null ? parent.Deposit_Amount__c : 0.00; } }
        public Decimal depositAmountTotal { get { return depositAmount * quantity; } }
        public Decimal amountPaid { get { return parent.Amount_Paid__c != null ? parent.Amount_Paid__c : 0.00; } }
        public Decimal tax { get { return 0.00; } }
        public Decimal amountDue { get { return parent.Amount_Due__c != null ? parent.Amount_Due__c : 0.00; } }

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

        public String arCoorName {
            get {
                if( parent.Billing_Company_Name__c != null ) {
                    return parent.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? getContactName( null,
                                             parent.Billing_Company_Name__r.A_R_coordinator__r.FirstName,
                                             parent.Billing_Company_Name__r.A_R_coordinator__r.LastName )
                           : MilroseDevHelper.MILROSE_COMPANY_NAME;
                } else {
                    return parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? getContactName( null,
                                             parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.FirstName,
                                             parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.LastName )
                           : MilroseDevHelper.MILROSE_COMPANY_NAME;
                }
            }
        }

        public String arCoorPhone {
            get {
                if( parent.Billing_Company_Name__c != null ) {
                    return parent.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? parent.Billing_Company_Name__r.A_R_coordinator__r.Phone
                           : MilroseDevHelper.MILROSE_COMPANY_PHONE;
                } else {
                    return parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.Phone
                           : MilroseDevHelper.MILROSE_COMPANY_PHONE;
                }
            }
        }

        public String arCoorEmail {
            get {
                if( parent.Billing_Company_Name__c != null ) {
                    return parent.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? parent.Billing_Company_Name__r.A_R_coordinator__r.Email
                           : '';
                } else {
                    return parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__c != null
                           ? parent.Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.Email
                           : '';
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

    private List<Deposit_Invoice__c> getInvoices( Id parentId, String objectType, Boolean createForChangeOrders ) {
        String query;
        query  = 'SELECT Id, Deposit_Invoice_Number__c, Deposit_Invoice_Date__c, Deposit_Invoice_Type__c, ';
        query +=        'Deposit_Amount__c, Amount_Paid__c, Amount_Due__c, Is_Created_From_Code__c, For_Add_Reimbursables__c, '; //MRS 7298

        query +=        'Proposal__c, Proposal__r.Name, Proposal__r.Client_Project__c, Proposal__r.Retainer_Amount__c, Proposal__r.Floor_s__c, '; //MRS 7415
        query +=        'Proposal__r.Account_Executive__r.FirstName, Proposal__r.Account_Executive__r.LastName, ';
        query +=        'Proposal__r.Project_Name__c, Proposal__r.Address_Building_AKA__c, Proposal__r.Delivery_Method__c, ';
        query +=        'Proposal__r.Building_AKA__c, Proposal__r.Building_AKA__r.Building__r.City__c, Proposal__r.Building_AKA__r.Building__r.State__c, Proposal__r.Building_AKA__r.Building__r.PostalCode__c, ';
        query +=        'Proposal__r.Address__r.City__c, Proposal__r.Address__r.State__c, Proposal__r.Address__r.PostalCode__c, ';

        query +=        'Proposal__r.No_Retainer__c, Proposal__r.Municipal_Authority_Fees__c, Proposal__r.Projected_DOB_Fee__c, ';
        query +=        'Change_Order__c, Change_Order__r.Municipal_Authority_Fees__c, Change_Order__r.Projected_DOB_Fee__c, ';
        query +=        'Change_Order__r.Number__c, Project_Profile__c, Project_Profile__r.Name, ';

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
        query +=        'Billing_Company_Name__r.A_R_coordinator__c, ';
        query +=        'Billing_Company_Name__r.A_R_coordinator__r.FirstName, Billing_Company_Name__r.A_R_coordinator__r.LastName, ';
        query +=        'Billing_Company_Name__r.A_R_coordinator__r.Phone, Billing_Company_Name__r.A_R_coordinator__r.Email, ';
        query +=        'Proposal__r.Billing_Company_Name__r.Name, ';
        query +=        'Proposal__r.Billing_Company_Name__r.A_R_coordinator__c, ';
        query +=        'Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.FirstName, Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.LastName, ';
        query +=        'Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.Phone, Proposal__r.Billing_Company_Name__r.A_R_coordinator__r.Email, ';

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
        if( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME && !createForChangeOrders ) {
            query += 'Proposal__c =\'' + parentId + '\' ';
            query += 'ORDER BY Deposit_Invoice_Type__c ASC, Deposit_Invoice_Number__c ASC';
        } else if( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME && createForChangeOrders ) {
            if( isLightCo && !String.isBlank( lightCoId ) ) {
                query += 'Change_Order__c = \'' + lightCoId + '\' ';
                query += 'AND ';
            }
            query += 'Change_Order__r.Proposal__c =\'' + parentId + '\' ';
            query += 'AND ';
            query += 'Change_Order__r.Status__c =\'' + ChangeOrderServices.STATUS_PENDING_CLIENT + '\' ';
            query += 'ORDER BY Deposit_Invoice_Type__c ASC, Deposit_Invoice_Number__c ASC';
        } else {
            query += 'Id =\'' + parentId + '\'';
            query += ' LIMIT 1';
        }

        List<Deposit_Invoice__c> invoices = Database.query( query );
        List<Deposit_Invoice__c> result = new List<Deposit_Invoice__c>();
        for( Deposit_Invoice__c invoice : invoices ) {
            if( ( objectType != ProposalServices.PROPOSAL_OBJECT_API_NAME ) ||
                ( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME &&
                    createForChangeOrders &&
                    invoice.Deposit_Invoice_Type__c == DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE &&
                    !invoice.Proposal__r.No_Retainer__c &&
                    invoice.Change_Order__r.Municipal_Authority_Fees__c != null &&
                    invoice.Change_Order__r.Municipal_Authority_Fees__c.contains( ChangeOrderServices.DOB_VARIANCE_FEES_PROJECTED ) &&
                    invoice.Change_Order__r.Projected_DOB_Fee__c != null &&
                    invoice.Change_Order__r.Projected_DOB_Fee__c > 0 ) ||
                ( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME &&
                    !createForChangeOrders &&
                    invoice.Deposit_Invoice_Type__c == DepositInvoiceServices.SERVICE_RETAINER_TYPE &&
                    !invoice.Proposal__r.No_Retainer__c &&
                    invoice.Proposal__r.Retainer_Amount__c != null &&
                    invoice.Proposal__r.Retainer_Amount__c > 0 ) ||
                ( objectType == ProposalServices.PROPOSAL_OBJECT_API_NAME &&
                    !createForChangeOrders &&
                    invoice.Deposit_Invoice_Type__c == DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE &&
                    !invoice.Proposal__r.No_Retainer__c &&
                    invoice.Proposal__r.Municipal_Authority_Fees__c != null &&
                    invoice.Proposal__r.Municipal_Authority_Fees__c.contains( ChangeOrderServices.DOB_VARIANCE_FEES_PROJECTED ) &&
                    invoice.Proposal__r.Projected_DOB_Fee__c != null &&
                    invoice.Proposal__r.Projected_DOB_Fee__c > 0 ) ) {
                result.add( invoice );
            }
        }

        return result;
    }

}