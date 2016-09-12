public with sharing class InvoiceController {

    public Boolean isValid { get; private set; }
    public TableWrapper content { get; private set; }
    public Pro_forma_Invoice__c parent; //MRS-6827

    public Pro_forma_Invoice__c proforma {
        get;
        private set;
    }

    public String address1 { get { return content.record.Project_Address_Building_AKA__c != null ? content.record.Project_Address_Building_AKA__c : ''; } }
    public String address2 { get { return getAddress2(); } }

    public InvoiceController() {
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        if( parentId != null && parentId instanceOf Id ) {
            if( String.valueOf( Id.valueOf(parentId).getsObjectType() ) == 'Pro_forma_Invoice__c' ) {
                parent = getParentWithBlis( parentId );
                if( parent == null ) {
                    MilroseDevHelper.addMessage('No such Pro-Forma Invoice found.');
                    isValid = false;
                    return;
                }
            } else {
                MilroseDevHelper.addMessage('Invalid Pro-Forma Invoice Id.');
                isValid = false;
                return;
            }
        } else {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
        this.proforma = parent;
        content = new TableWrapper( parent, getProject( parent.Project_Profile__c ) );
    }

    /*public String setOfFloorsLinkedToServices { private set; //MRS-6827
        get {
            Set<Id> setOfServiceItemsIds = new Set<Id>();
            for( Billing_Line_Item__c bli : parent.Billing_Line_Items__r ) {
                setOfServiceItemsIds.add(bli.Service_Item__c);
            }
            return FloorServices.getFloorsStringFromFloorServiceJunctions(setOfServiceItemsIds);
        }
    }*/

	public Boolean showEmptyLine { set; get {
			return (!content.phaseWithIdToLinesList.isEmpty() && !content.phaseNullIdToLinesList.isEmpty());
		}
	}
	
    public class TableWrapper {

        public Map<Id, String> phaseIdToNameMap { get { if(phaseIdToNameMap == null) phaseIdToNameMap = new Map<Id, String> (); return phaseIdToNameMap; } private set; } // MRS 6617
        public Map<Id, List<LineWrapper>> phaseWithIdToLinesList { get { if(phaseWithIdToLinesList == null) phaseWithIdToLinesList = new Map<Id, List<LineWrapper>> ();  return phaseWithIdToLinesList; } private set; }
		public Map<Id, List<LineWrapper>> phaseNullIdToLinesList { get { if(phaseNullIdToLinesList == null) phaseNullIdToLinesList = new Map<Id, List<LineWrapper>> ();  return phaseNullIdToLinesList; } private set; }

        public List<LineWrapper> lines { get { if( lines == null ) lines = new List<LineWrapper>(); return lines; } private set; }
        public Pro_Forma_Invoice__c record { get { if( record == null ) record = new Pro_Forma_Invoice__c(); return record; } private set; }
        public Boolean showServiceNumber { get { if( showServiceNumber == null ) showServiceNumber = false; return showServiceNumber; } private set; }
        public Boolean showFloors { get { if( showFloors == null ) showFloors = false; return showFloors; } private set; }

        public Decimal subtotal { get { if( subtotal == null ) subtotal = 0.00; return subtotal; } private set; }
        public Decimal tax { get { if( tax == null ) tax = 0.00; return tax; } private set; }
        public Decimal credits { get { if( credits == null ) credits = 0.00; return credits; } private set; }
        public Decimal amountDue { get { if( amountDue == null ) amountDue = 0.00; return amountDue; } private set; }

        public Decimal outstAmtToday { get { if( outstAmtToday == null ) outstAmtToday = 0.00; return outstAmtToday; } private set; }
        public Decimal outstAmt30 { get { if( outstAmt30 == null ) outstAmt30 = 0.00; return outstAmt30; } private set; }
        public Decimal outstAmt60 { get { if( outstAmt60 == null ) outstAmt60 = 0.00; return outstAmt60; } private set; }
        public Decimal outstAmt90 { get { if( outstAmt90 == null ) outstAmt90 = 0.00; return outstAmt90; } private set; }
        public Decimal outstAmt90plus { get { if( outstAmt90plus == null ) outstAmt90plus = 0.00; return outstAmt90plus; } private set; }
        public Decimal outstAmtTotal { get { return outstAmtToday + outstAmt30 + outstAmt60 + outstAmt90 + outstAmt90plus; } }

        public Boolean poShow { get { if( poShow == null ) poShow = false; return poShow; } private set; }
        public Decimal poAmount { get { if( poAmount == null ) poAmount = 0.00; return poAmount; } private set; }
        public Decimal poBilledAmount { get { if( poBilledAmount == null ) poBilledAmount = 0.00; return poBilledAmount; } private set; }
        public Decimal poUnbilled { get { return poAmount - poBilledAmount; } private set; }

        public Boolean reimbDepositShow { get { if( reimbDepositShow == null ) reimbDepositShow = false; return reimbDepositShow; } private set; }
        public Decimal reimbDepositPaid { get { if( reimbDepositPaid == null ) reimbDepositPaid = 0.00; return reimbDepositPaid; } private set; }
        public Decimal reimbDepositApplied { get { if( reimbDepositApplied == null ) reimbDepositApplied = 0.00; return reimbDepositApplied; } private set; }
        public Decimal reimbDepositRemaining { get { if( reimbDepositRemaining == null ) reimbDepositRemaining = 0.00; return reimbDepositRemaining; } private set; }

        public Boolean srvDepositShow { get { if( srvDepositShow == null ) srvDepositShow = false; return srvDepositShow; } private set; }
        public Decimal srvDepositPaid { get { if( srvDepositPaid == null ) srvDepositPaid = 0.00; return srvDepositPaid; } private set; }
        public Decimal srvDepositApplied { get { if( srvDepositApplied == null ) srvDepositApplied = 0.00; return srvDepositApplied; } private set; }
        public Decimal srvDepositRemaining { get { if( srvDepositRemaining == null ) srvDepositRemaining = 0.00; return srvDepositRemaining; } private set; }

        public String arCoorName { get { if( arCoorName == null ) arCoorName = ''; return arCoorName; } private set; }
        public String arCoorPhone { get { if( arCoorPhone == null ) arCoorPhone = ''; return arCoorPhone; } private set; }
        public String arCoorEmail { get { if( arCoorEmail == null ) arCoorEmail = ''; return arCoorEmail; } private set; }
        //MRS-6885 MRS-7004
        public String arCoorCompany { get { if( arCoorCompany == null) arCoorCompany = ''; return arCoorCompany; } private set; }
        public String arCoorTitle {get { if( arCoorTitle == null ) arCoorTitle = ''; return arCoorTitle; } private set; }
		public String showAsteriskRow { get { for(LineWrapper lw : lines) { if(lw.isTaxable) return 'block'; } return 'none'; } set; } //MRS 7519
        //MRS 6043
        public List<Billing_Line_Item__c> hourlyBlis { private set;
            get {
                if( hourlyBlis == null) hourlyBlis = new List<Billing_Line_Item__c> ();
                return hourlyBlis;
            }
        }
        public Boolean hourlyInvoiceDescriptionRendered { private set;
            get {
                if( hourlyInvoiceDescriptionRendered == null ) hourlyInvoiceDescriptionRendered = false;
                return hourlyInvoiceDescriptionRendered;
            }
        }
        public Boolean showPRArea { private set; get; }
        public String prName {get { if( prName == null) prName = ''; return prName; } private set; }
        public String prTitle {get { if( prTitle == null) prTitle = ''; return prTitle; } private set; }
        public String prPhone {get { if( prPhone == null) prPhone = ''; return prPhone; } private set; }
        public String prEmail {get { if( prEmail == null) prEmail = ''; return prEmail; } private set; }

        public TableWrapper( Pro_forma_Invoice__c pfi, Project_Profile__c project ) {
            this.record = pfi;

            this.subtotal = pfi.Subtotal__c;
            this.tax = pfi.Tax__c;
            this.credits = pfi.Credit__c;
            this.amountDue = pfi.Amount_Due__c;

            for( Billing_Line_Item__c bli : pfi.Billing_Line_Items__r ) {
                this.lines.add( new LineWrapper( bli, pfi, project ) );
            }

            this.showServiceNumber = pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE;

            this.showFloors = pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE &&
                              pfi.Project_Profile__r.Proposal__r.Is_Floors_To_Services__c == true;
            if( this.showFloors ) {
                Boolean allBlisReimbursable = true; //MRS-6827
                for( LineWrapper lineWrapperItem : this.lines ) {
                    if( !lineWrapperItem.isReimbursable ) {
                        allBlisReimbursable = false;
                        break;
                    }
                }
                if( allBlisReimbursable ) {
                    this.showFloors = false;
                }
            }

            for(LineWrapper lineWrapper : this.lines) { // MRS 6617

				if(!String.isBlank(lineWrapper.phaseId)) {
	                if(phaseWithIdToLinesList.get(lineWrapper.phaseId) == null) {
	                    phaseIdToNameMap.put(lineWrapper.phaseId,lineWrapper.phaseName);
	                    phaseWithIdToLinesList.put(lineWrapper.phaseId, new List<LineWrapper>());
                	}
					phaseWithIdToLinesList.get(lineWrapper.phaseId).add(lineWrapper);
				} else {
					if(phaseNullIdToLinesList.get(lineWrapper.phaseId) == null) {
	                    phaseIdToNameMap.put(lineWrapper.phaseId,lineWrapper.phaseName);
	                    phaseNullIdToLinesList.put(lineWrapper.phaseId, new List<LineWrapper>());
                	}
					phaseNullIdToLinesList.get(lineWrapper.phaseId).add(lineWrapper);
				}

            }

            Date todayDate = Date.today();
            for( Pro_forma_Invoice__c invItem : project.Pro_forma_Invoices__r ) {
                if( invItem.Amount_Due__c != null && invItem.Invoice_Date__c != null ) {
                    if( invItem.Invoice_Date__c >= todayDate )
                        this.outstAmtToday += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < todayDate && invItem.Invoice_Date__c >= (todayDate - 30) )
                        this.outstAmt30 += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 30) && invItem.Invoice_Date__c >= (todayDate - 60) )
                        this.outstAmt60 += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 60) && invItem.Invoice_Date__c >= (todayDate - 90) )
                        this.outstAmt90 += invItem.Amount_Due__c;
                    if( invItem.Invoice_Date__c < (todayDate - 90) )
                        this.outstAmt90plus += invItem.Amount_Due__c;
                }
            }

            if( !String.isEmpty( pfi.Purchase_Order__c ) ) {
                this.poShow = true;
                this.poAmount = pfi.Purchase_Order__r.Purchase_Order_Amount__c;
                //MRS-5626
                AggregateResult[] groupedResults = [SELECT SUM(Tax__c), SUM(Subtotal__c)
                                                    FROM Pro_forma_Invoice__c
                                                    WHERE Purchase_Order__c =: pfi.Purchase_Order__c];

                this.poBilledAmount = (Decimal)groupedResults.get(0).get('expr0') + (Decimal)groupedResults.get(0).get('expr1');

            }

            for( Deposit_Invoice__c depositInvoice : project.Deposit_Invoices__r ) {
                if( depositInvoice.Deposit_Invoice_Type__c == DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE ) {
                    this.reimbDepositShow = reimbDepositShow || true;
                    this.reimbDepositPaid += depositInvoice.Amount_Paid__c;
                    this.reimbDepositApplied += depositInvoice.Amount_Applied__c;
                    this.reimbDepositRemaining += depositInvoice.Amount_Remaining__c;
                } else if( depositInvoice.Deposit_Invoice_Type__c == DepositInvoiceServices.SERVICE_RETAINER_TYPE ) {
                    this.srvDepositShow = srvDepositShow || true;
                    this.srvDepositPaid += depositInvoice.Amount_Paid__c;
                    this.srvDepositApplied += depositInvoice.Amount_Applied__c;
                    this.srvDepositRemaining += depositInvoice.Amount_Remaining__c;
                }
            }

            //MRS-5348
            this.arCoorName  = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Name : 'Milrose Consultants, Inc.';
            this.arCoorPhone = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Phone : '212-643-4545';
            this.arCoorEmail = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Email : '';

            //MRS-6885 MRS-7004
            this.arCoorCompany = (!String.isEmpty(pfi.Billing_Client_Company__c)) ? pfi.Billing_Client_Company__r.Name : 'Milrose Consultants, Inc.';
            this.arCoorTitle = ( !String.isEmpty( pfi.Billing_Client_Company__c ) && !String.isEmpty( pfi.Billing_Client_Company__r.A_R_coordinator__c ) ) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Title : '';

            this.prName = (!String.isEmpty(project.Account_Executive__c)) ? project.Account_Executive__r.Name :
                         ((!String.isEmpty(project.Production_Manager__c)) ? project.Production_Manager__r.Name :
                         ((!String.isEmpty(project.Owner.Name)) ? project.Owner.Name : 'none'));
            this.prTitle = (!String.isEmpty(project.Account_Executive__c)) ? project.Account_Executive__r.Title :
                         ((!String.isEmpty(project.Production_Manager__c)) ? project.Production_Manager__r.Title :
                         ((!String.isEmpty(project.Owner.Title)) ? project.Owner.Title : 'none'));
            this.prPhone = (!String.isEmpty(project.Account_Executive__c)) ? project.Account_Executive__r.Phone :
                         ((!String.isEmpty(project.Production_Manager__c)) ? project.Production_Manager__r.Phone :
                         ((!String.isEmpty(project.Owner.Phone)) ? project.Owner.Phone : 'none'));
            this.prEmail = (!String.isEmpty(project.Account_Executive__c)) ? project.Account_Executive__r.Email :
                         ((!String.isEmpty(project.Production_Manager__c)) ? project.Production_Manager__r.Email :
                         ((!String.isEmpty(project.Owner.Email)) ? project.Owner.Email : 'none'));
            this.showPRArea = (String.isEmpty(project.Account_Executive__c) && String.isEmpty(project.Production_Manager__c)) ? false : true;
            // MRS 6043
            hourlyInvoiceDescriptionRendered = pfi.Include_Supporting_Documentation__c;
            for( Billing_Line_Item__c bli : pfi.Billing_Line_Items__r ) {
                if( bli.isHourlyConsulting__c ) hourlyBlis.add(bli);
            }
        }

    }

    public class LineWrapper {
        public String refNumber { get { if( refNumber == null ) refNumber = ''; return refNumber; } private set; }
        public String serviceNameShort { get { if( serviceNameShort == null ) serviceNameShort = ''; return serviceNameShort; } private set; }
        public String description { get { if( description == null ) description = ''; return description; } private set; }
        public Decimal quantity { get { if( quantity == null ) quantity = 0.00; return quantity; } private set; }
        public Decimal unitPrice { get { if( unitPrice  == null ) unitPrice = 0.00; return unitPrice; } private set; }
        public Decimal amount { get { if( amount == null ) amount = 0.00; return amount; } private set; }
		public Boolean isTaxable { get { if( isTaxable == null ) isTaxable = false; return isTaxable; } private set; } //MRS 7519
        public String floors { get { if( floors == null ) floors = ''; return floors; } private set; }
        public Boolean isReimbursable { get { if( isReimbursable == null ) isReimbursable = false; return isReimbursable; } private set; }
        public Boolean showUnitPrice { get { if( showUnitPrice == null ) showUnitPrice = true; return showUnitPrice; } private set; }
        public Id phaseId { get; set; } // MRS 6617
        public String phaseName { get { if(phaseName == null) return ''; return phaseName; } private set; }

        public LineWrapper( Billing_line_Item__c bli, Pro_Forma_Invoice__c pfi, Project_Profile__c project ) {
            isReimbursable = bli.isReimbursable__c;
            if( bli.Service_Item__c != null ) {
                floors = bli.Service_Item__r.Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( bli.Service_Item__r.Floor__c.split(', '), ',' ).split(','), ',&nbsp;', 2 ), ', ' ) : '';

                if( bli.Service_Item__r.Original__c ) {
                    this.refNumber = 'Base Proposal';
                } else if( bli.Service_Item__r.Is_Amendmend_Deleted__c &&
                           bli.Service_Item__r.Change_Order_Old__c != null &&
                           bli.Service_Item__r.Change_Order_Old__r.Number__c != null ) {
                    this.refNumber = 'CO#' + String.valueOf( bli.Service_Item__r.Change_Order_Old__r.Number__c );
                } else if( !bli.Service_Item__r.Is_Amendmend_Deleted__c &&
                           bli.Service_Item__r.Change_Order__c != null &&
                           bli.Service_Item__r.Change_Order__r.Number__c != null ) {
                    this.refNumber = 'CO#' + String.valueOf( bli.Service_Item__r.Change_Order__r.Number__c );
                }
            }
			this.isTaxable = bli.Sales_Tax_Amount__c == null || bli.Sales_Tax_Amount__c == 0 ? false : true; //MRS 7519
            this.serviceNameShort = bli.Service_Name_Short__c;
            this.quantity = bli.Quantity__c;
            this.unitPrice = bli.Unit_Price__c;
            this.amount = bli.Amount__c;

            String serviceName = ( bli.Service_Name__c != null ? bli.Service_Name__c : ( bli.Service_Item__r.Service_Name_Full__c != null ? bli.Service_Item__r.Service_Name_Full__c : '' ) );
            String ownerName = ' (' +
                               ( String.isEmpty( bli.Owner.FirstName ) ? '' : bli.Owner.FirstName.substring(0, 1) + '. ' ) +
                               bli.Owner.LastName +
                               ')';
            String municipalAgency = ( !String.isEmpty( bli.Municipal_Agency_ID__c ) ? bli.Municipal_Agency_ID__c : '' );

            String description = ( !String.isEmpty( bli.Description__c ) ? bli.Description__c : '' );

            if( pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ) {
                if( String.isEmpty( bli.Service_Item__c ) ) {
                    this.description = bli.Description__c;
                } else {
                    if( bli.isHourlyConsulting__c ) {
                        this.description = joinStrings( new List<String>{ serviceName, description + ownerName } );
                    } else {
                        this.description = joinStrings( new List<String>{ serviceName, municipalAgency } );
                    }
                }
            } else if( pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
                if( !String.isEmpty( bli.Description__c ) && bli.Description__c.contains( ProformaInvoiceServices.CHANGE_ORDER_BALANCE ) ) {
                    this.description = bli.Description__c;
                    this.showUnitPrice = false;
                } else if( bli.isReimbursable__c ) {
                    this.description = bli.Description__c;
                } else {
                    if( bli.isHourlyConsulting__c ) {
                        this.description = joinStrings( new List<String>{ serviceName, description + ownerName } );
                    } else {
                        if( ( pfi.Project_Profile__r.Interval__c ) ||
                            ( !pfi.Project_Profile__r.Interval__c && String.isBlank( bli.Service_Name__c ) )
							|| ( !pfi.Project_Profile__r.Interval__c && String.isBlank( bli.Description__c ) ) ) { //MRS-6362
                            this.description = 'Percentage Billing';
                        } else {
                            this.description = bli.Service_Name__c;
                        }
                    }
                }
            } else if( pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
                if( !String.isEmpty( bli.Description__c ) && bli.Description__c.contains( ProformaInvoiceServices.CHANGE_ORDER_BALANCE ) ) {
                    this.description = bli.Description__c;
                    this.showUnitPrice = false;
                } else if( bli.isReimbursable__c ) {
                    this.description = bli.Description__c;
                } else {
                    if( bli.isHourlyConsulting__c ) {
                        this.description = joinStrings( new List<String>{ serviceName, description + ownerName } );
                    } else {
                        this.description = ( !String.isEmpty( pfi.Project_Profile__r.Frequency__c ) ? pfi.Project_Profile__r.Frequency__c + ' ' : '' ) + 'Installment Billing ' + ( bli.Billing_Date__r.Step_Number__c != null ? String.valueOf( bli.Billing_Date__r.Step_Number__c ) : '0' ) + ' of ' + project.Billing_Dates__r.size();
                    }
                }
            }

            if( !String.isBlank( bli.Service_Item__c ) &&
                bli.Service_Item__r.Subtype__c == ServiceItemServices.SUBTYPE_AHV &&
                !String.isBlank( bli.Service_Item__r.Phase__c ) &&
                !bli.Service_Item__r.Phase__r.Is_default__c &&
                bli.Service_Item__r.Phase__r.Name__c != PhaseServices.SINGLE_PHASE ) { //MRS-6426
                this.description = bli.Service_Item__r.Phase__r.Name__c + ' ' + this.description; //MRS-6426
            } else { //MRS-6426
                this.description = ( bli.Milestone_Date__c == null ? '' : bli.Milestone_Date__c.format() ) + ' ' + this.description;
            }

            this.description = splitStringIfHasWordsLonger(this.description, 29); //MRS 7131

            if(!String.isBlank(bli.Service_Item__c) && !String.isBlank(bli.Service_Item__r.Phase__c) && !String.isBlank(bli.Service_Item__r.Phase__r.Name__c)) { // MRS 6617
                this.phaseId = bli.Service_Item__r.Phase__c;
                this.phaseName = bli.Service_Item__r.Phase__r.Name__c;
            }

        }

        private String splitStringIfHasWordsLonger(String s, Integer pos) {
            String res = '';
            for(String subS : s.split(' ')) {
                res += res.length() > 0 ? ' ' : '';
                res += subS.length() > pos ? subS.substring(0, pos) + ' ' + splitStringIfHasWordsLonger(subS.substring(pos, subS.length()), pos) : subS;
            }
            return res;
        }

        private String joinStrings( List<String> input ) {
            String output = '';
            List<String> notEmptyInput = new List<String>();
            for( String inputItem : input ) {
                if( !String.isEmpty( inputItem ) ) {
                    notEmptyInput.add( inputItem );
                }
            }
            return String.join( notEmptyInput, '<br/>' );
        }
    }

    private Pro_forma_Invoice__c getParentWithBlis( Id parentId ) {
        List<Pro_forma_Invoice__c> parents = [ SELECT Name, Invoice_Date__c, Client_Project__c, Purchase_Order__r.Name,
                                                      Account_Manager__r.Name, Name_without_Prefix__c,
                                                      Project_Profile__r.Name, Project_Profile__r.Delivery_Method__c,
                                                      Project_Profile__r.Floor_s__c, Project_Profile__r.Project_Name__c,
                                                      Accounting_Contact_Company__c, Accounting_Contact_Company__r.Name,
                                                      Accounting_Contact_Company__r.A_R_coordinator__r.Name,
                                                      Accounting_Contact_Company__r.A_R_coordinator__r.Phone,
                                                      Accounting_Contact_Company__r.A_R_coordinator__r.Email,
                                                      Accounting_Contact__r.MailingStreet,
                                                      Accounting_Contact__r.MailingCity, Accounting_Contact__r.MailingState,
                                                      Accounting_Contact__r.MailingPostalCode, Accounting_Contact__r.Salutation,
                                                      Accounting_Contact__r.Name, Project_Profile__r.Interval__c,
                                                      Billing_Client_Company__c, Billing_Client_Company__r.Name,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Name,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Title, /* MRS-7004*/
                                                      Billing_Client_Company__r.A_R_coordinator__r.Phone,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Email,
                                                      Billing_Contact__r.MailingStreet,
                                                      Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState,
                                                      Billing_Contact__r.MailingPostalCode, Billing_Contact__r.Salutation, Billing_Contact__r.Name,
                                                      Invoice_Format__c, Project_Profile__r.Billing_Method__c,
                                                      Subtotal__c, Tax__c, Credit__c, Amount_Due__c, Display_Text_on_Invoice__c,
                                                      Project_Profile__r.Frequency__c, Project_Profile__r.Number_Of_Intervals__c,
                                                      Purchase_Order__c, Purchase_Order__r.Purchase_Order_Amount__c, Project_Profile__r.Proposal__r.Name,
                                                      Project_Address_Building_AKA__c, Project_Profile__r.Building_AKA__c,
                                                      Project_Address__r.City__c, Project_Address__r.State__c, Project_Address__r.PostalCode__c,
                                                      Project_Profile__r.Building_AKA__r.Building__r.City__c, Project_Profile__r.Building_AKA__r.Building__r.State__c, Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c,
                                                      Project_Profile__r.Proposal__r.Is_Floors_To_Services__c,
                                                      Include_Supporting_Documentation__c, /* MRS 6043 */
                                                      ( SELECT Name, Service_Name_Short__c, Service_Item__c, Description__c, Sales_Tax_Amount__c, /*MRS 7519*/
                                                               Service_Name__c, Service_Item__r.Service_Name_Full__c,
                                                               Municipal_Agency_ID__c, Quantity__c, Unit_Price__c,
                                                               Amount__c, isReimbursable__c, Billing_Date__r.Step_Number__c,
                                                               isHourlyConsulting__c, Milestone_Date__c, Owner.FirstName, Owner.LastName,
                                                               Service_Item__r.Subtype__c, Service_Item__r.Phase__c, Service_Item__r.Phase__r.Name__c, Service_Item__r.Phase__r.Is_default__c,
                                                               Service_Item__r.Original__c, Service_Item__r.Is_Amendmend_Deleted__c,
                                                               Service_Item__r.Change_Order__c, Service_Item__r.Change_Order__r.Number__c,
                                                               Service_Item__r.Change_Order_Old__c, Service_Item__r.Change_Order_Old__r.Number__c, Service_Item__r.Floor__c
                                                        FROM Billing_Line_Items__r
                                                        WHERE Department_Based__c = false //AND isHourlyConsulting__c = false
                                                        ORDER BY Billing_Date__r.Step_Number__c ASC NULLS LAST,
                                                                 //Phase__c ASC NULLS FIRST,
                                                                 Related_Service_Id__c ASC NULLS LAST,
                                                                 //Related_Service_Item__c ASC NULLS LAST,
                                                                 isReimbursable__c ASC,
                                                                 Milestone_Date__c ASC NULLS LAST,
                                                                 CreatedDate ASC )
                                              FROM Pro_forma_Invoice__c
                                              WHERE Id = : parentId ];
        if( !parents.isEmpty() ) {
            return parents[0];
        } else {
            return null;
        }
    }

    private Project_Profile__c getProject( Id profileId ) {
        Project_Profile__c project = new Project_Profile__c();
        if( !String.isEmpty( profileId ) ) {                        // MRS-6885
            List<Project_Profile__c> projects = [ SELECT Id, Account_Executive__c, Production_Manager__c,
                                                             Account_Executive__r.Name, Production_Manager__r.Name, Owner.Name,
                                                             Account_Executive__r.Title, Production_Manager__r.Title, Owner.Title,
                                                             Account_Executive__r.Phone, Production_Manager__r.Phone, Owner.Phone,
                                                             Account_Executive__r.Email, Production_Manager__r.Email, Owner.Email,
                                                         ( SELECT Invoice_Date__c, Amount_Due__c
                                                           FROM Pro_forma_Invoices__r
                                                           WHERE Amount_Due__c != 0 ),
                                                         ( SELECT Amount_Paid__c, Amount_Remaining__c,
                                                                  Amount_Applied__c, Deposit_Invoice_Type__c
                                                            FROM Deposit_Invoices__r
                                                            WHERE Deposit_Invoice_Type__c = : DepositInvoiceServices.SERVICE_RETAINER_TYPE OR
                                                                  Deposit_Invoice_Type__c = : DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE ),
                                                          ( SELECT Id
                                                            FROM Billing_Dates__r )
                                                  FROM Project_Profile__c
                                                  WHERE Id = : profileId ];
            if( !projects.isEmpty() ) {
                project = projects[0];
            }
        }
        return project;
    }

    private String getAddress2() {
        String address = '';
        if( content.record.Project_Profile__r.Building_AKA__c != null ) {
            address = ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.City__c) ? content.record.Project_Profile__r.Building_AKA__r.Building__r.City__c : '' ) +
                      ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.City__c) && ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.State__c) || !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.State__c) ? content.record.Project_Profile__r.Building_AKA__r.Building__r.State__c : '' ) +
                      ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.State__c) && !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(content.record.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c) ? content.record.Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c : '' );
        } else {
            address = ( !String.isEmpty(content.record.Project_Address__r.City__c) ? content.record.Project_Address__r.City__c : '' ) +
                      ( !String.isEmpty(content.record.Project_Address__r.City__c) && ( !String.isEmpty(content.record.Project_Address__r.State__c) || !String.isEmpty(content.record.Project_Address__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(content.record.Project_Address__r.State__c) ? content.record.Project_Address__r.State__c : '' ) +
                      ( !String.isEmpty(content.record.Project_Address__r.State__c) && !String.isEmpty(content.record.Project_Address__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(content.record.Project_Address__r.PostalCode__c) ? content.record.Project_Address__r.PostalCode__c : '' );
        }
        return address;
    }

}