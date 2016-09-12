public with sharing class InvoicePercentageController {

	public Boolean isValid { get; set; }
    public TableWrapper content { get; set; }
    public Pro_forma_Invoice__c parent;
    public Pro_forma_Invoice__c proforma { get; set; }

    public String address1 { get { return content.record.Project_Address_Building_AKA__c != null ? content.record.Project_Address_Building_AKA__c : ''; } }
    public String address2 { get { return getAddress2(); } }

    public InvoicePercentageController() {
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

	public Boolean showEmptyLine { set; get {
			return (!content.phaseWithIdToLinesList.isEmpty() && !content.phaseNullIdToLinesList.isEmpty());
		}
	}
	
    public class TableWrapper {

        public Map<Id, String> phaseIdToNameMap { get { if(phaseIdToNameMap == null) phaseIdToNameMap = new Map<Id, String> (); return phaseIdToNameMap; } set; }
        public Map<Id, List<LineWrapper>> phaseWithIdToLinesList { get { if(phaseWithIdToLinesList == null) phaseWithIdToLinesList = new Map<Id, List<LineWrapper>> ();  return phaseWithIdToLinesList; } set; }
		public Map<Id, List<LineWrapper>> phaseNullIdToLinesList { get { if(phaseNullIdToLinesList == null) phaseNullIdToLinesList = new Map<Id, List<LineWrapper>> ();  return phaseNullIdToLinesList; } set; }

        public List<LineWrapper> lines { get { if( lines == null ) lines = new List<LineWrapper>(); return lines; } set; }
        public Pro_Forma_Invoice__c record { get { if( record == null ) record = new Pro_Forma_Invoice__c(); return record; } set; }
        public Boolean showServiceNumber { get { if( showServiceNumber == null ) showServiceNumber = false; return showServiceNumber; } set; }
        public Boolean showFloors { get { if( showFloors == null ) showFloors = false; return showFloors; } set; }

        public Decimal subtotal { get { if( subtotal == null ) subtotal = 0.00; return subtotal; } set; }
        public Decimal tax { get { if( tax == null ) tax = 0.00; return tax; } set; }
        public Decimal credits { get { if( credits == null ) credits = 0.00; return credits; } set; }
        public Decimal amountDue { get { if( amountDue == null ) amountDue = 0.00; return amountDue; } set; }

        public Decimal outstAmtToday { get { if( outstAmtToday == null ) outstAmtToday = 0.00; return outstAmtToday; } set; }
        public Decimal outstAmt30 { get { if( outstAmt30 == null ) outstAmt30 = 0.00; return outstAmt30; } set; }
        public Decimal outstAmt60 { get { if( outstAmt60 == null ) outstAmt60 = 0.00; return outstAmt60; } set; }
        public Decimal outstAmt90 { get { if( outstAmt90 == null ) outstAmt90 = 0.00; return outstAmt90; } set; }
        public Decimal outstAmt90plus { get { if( outstAmt90plus == null ) outstAmt90plus = 0.00; return outstAmt90plus; } set; }
        public Decimal outstAmtTotal { get { return outstAmtToday + outstAmt30 + outstAmt60 + outstAmt90 + outstAmt90plus; } }

        public Boolean poShow { get { if( poShow == null ) poShow = false; return poShow; } set; }
		public Boolean poUnbilledReimbShow { get { if( poUnbilledReimbShow == null ) poUnbilledReimbShow = false; return poUnbilledReimbShow; } set; }
		public Boolean poUnbilledServShow { get { if( poUnbilledServShow == null ) poUnbilledServShow = false; return poUnbilledServShow; } set; }
		public Boolean poUnbilledMuFeeShow { get { if( poUnbilledMuFeeShow == null ) poUnbilledMuFeeShow = false; return poUnbilledMuFeeShow; } set; }
        public Decimal poAmount { get { if( poAmount == null ) poAmount = 0.00; return poAmount; } set; }
		public Decimal poReimbursables { get { if( poReimbursables == null ) poReimbursables = 0.00; return poReimbursables; } set; }
		public Decimal poServices { get { if( poServices == null ) poServices = 0.00; return poServices; } set; }
		public Decimal poMunAgFee { get { if( poMunAgFee == null ) poMunAgFee = 0.00; return poMunAgFee; } set; }
		public Decimal poUnbilledReimburs { get { if( poUnbilledReimburs == null ) poUnbilledReimburs = 0.00; return poUnbilledReimburs; } set; }
		public Decimal poUnbilledServices { get { if( poUnbilledServices == null ) poUnbilledServices = 0.00; return poUnbilledServices; } set; }
		public Decimal poUnbilledMunAgFee { get { if( poUnbilledMunAgFee == null ) poUnbilledMunAgFee = 0.00; return poUnbilledMunAgFee; } set; }
        public Decimal poBilledAmount { get { if( poBilledAmount == null ) poBilledAmount = 0.00; return poBilledAmount; } set; }
		public String showAsteriskRow { get { for(LineWrapper lw : lines) { if(lw.isTaxable) return 'block'; } return 'none'; } set; } //MRS 7519
		public String totalBilledPercentage { set;
			get {
				if(amountDue == 0) return '0';
				if(poAmount == 0) return '100';
				return String.valueOf((this.amountDue / this.poAmount * 100).round()); 
			}
		}
		public String totalUnbReimbPerc { set;
			get { 
				if(poReimbursables == 0 || poUnbilledReimburs < 0) return '0';
				return String.valueOf((poUnbilledReimburs / poReimbursables * 100).round()); 
			}
		}
		public String totalUnbServsPerc { set;
			get {
				if(poServices == 0 || poUnbilledServices < 0) return '0';
				return String.valueOf((poUnbilledServices / poServices * 100).round());
			}
		}
		public String totalUnbMuFeePerc { set;
			get {
				if(poMunAgFee == 0 || poUnbilledMunAgFee < 0) return '0';
				return String.valueOf((poUnbilledMunAgFee / poMunAgFee * 100).round());
			}
		}
        public Decimal poUnbilled { get { return poAmount - poBilledAmount; } set; }

        public Boolean reimbDepositShow { get { if( reimbDepositShow == null ) reimbDepositShow = false; return reimbDepositShow; } set; }
        public Decimal reimbDepositPaid { get { if( reimbDepositPaid == null ) reimbDepositPaid = 0.00; return reimbDepositPaid; } set; }
        public Decimal reimbDepositApplied { get { if( reimbDepositApplied == null ) reimbDepositApplied = 0.00; return reimbDepositApplied; } set; }
        public Decimal reimbDepositRemaining { get { if( reimbDepositRemaining == null ) reimbDepositRemaining = 0.00; return reimbDepositRemaining; } set; }

        public Boolean srvDepositShow { get { if( srvDepositShow == null ) srvDepositShow = false; return srvDepositShow; } set; }
        public Decimal srvDepositPaid { get { if( srvDepositPaid == null ) srvDepositPaid = 0.00; return srvDepositPaid; } set; }
        public Decimal srvDepositApplied { get { if( srvDepositApplied == null ) srvDepositApplied = 0.00; return srvDepositApplied; } set; }
        public Decimal srvDepositRemaining { get { if( srvDepositRemaining == null ) srvDepositRemaining = 0.00; return srvDepositRemaining; } set; }

        public String arCoorName { get { if( arCoorName == null ) arCoorName = ''; return arCoorName; } set; }
        public String arCoorPhone { get { if( arCoorPhone == null ) arCoorPhone = ''; return arCoorPhone; } set; }
        public String arCoorEmail { get { if( arCoorEmail == null ) arCoorEmail = ''; return arCoorEmail; } set; }
        public String arCoorCompany { get { if( arCoorCompany == null) arCoorCompany = ''; return arCoorCompany; } set; }
        public String arCoorTitle {get { if( arCoorTitle == null ) arCoorTitle = ''; return arCoorTitle; } set; }
        public List<Billing_Line_Item__c> hourlyBlis { set;
            get {
                if( hourlyBlis == null) hourlyBlis = new List<Billing_Line_Item__c> ();
                return hourlyBlis;
            }
        }
        public Boolean hourlyInvoiceDescriptionRendered { set;
            get {
                if( hourlyInvoiceDescriptionRendered == null ) hourlyInvoiceDescriptionRendered = false;
                return hourlyInvoiceDescriptionRendered;
            }
        }
        public Boolean showPRArea { set; get; }
        public String prName {get { if( prName == null) prName = ''; return prName; } set; }
        public String prTitle {get { if( prTitle == null) prTitle = ''; return prTitle; } set; }
        public String prPhone {get { if( prPhone == null) prPhone = ''; return prPhone; } set; }
        public String prEmail {get { if( prEmail == null) prEmail = ''; return prEmail; } set; }

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
                Boolean allBlisReimbursable = true; 
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

            for(LineWrapper lineWrapper : this.lines) {
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
				this.poUnbilledReimburs = pfi.Purchase_Order__r.Remaining_Balance_Reimbursables__c;
				this.poUnbilledServices = pfi.Purchase_Order__r.Remaining_Balance_Services__c;
				this.poUnbilledMunAgFee = pfi.Purchase_Order__r.Remaining_Balance_Municipal_Fees__c;
				this.poReimbursables = pfi.Purchase_Order__r.Reimbursables__c != null ? pfi.Purchase_Order__r.Reimbursables__c : 0;
				this.poServices = pfi.Purchase_Order__r.Services__c != null ? pfi.Purchase_Order__r.Services__c : 0;
				this.poMunAgFee = pfi.Purchase_Order__r.Municipal_Fees__c != null ? pfi.Purchase_Order__r.Municipal_Fees__c : 0;
				if(pfi.Purchase_Order__r.Reimbursables__c != null && pfi.Purchase_Order__r.Reimbursables__c > 0) poUnbilledReimbShow = true;
				if(pfi.Purchase_Order__r.Services__c != null && pfi.Purchase_Order__r.Services__c > 0) poUnbilledServShow = true;
				if(pfi.Purchase_Order__r.Municipal_Fees__c != null && pfi.Purchase_Order__r.Municipal_Fees__c > 0) poUnbilledMuFeeShow = true;
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

            this.arCoorName  = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Name : 'Milrose Consultants, Inc.';
            this.arCoorPhone = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Phone : '212-643-4545';
            this.arCoorEmail = (!String.isEmpty(pfi.Billing_Client_Company__c) && !String.isEmpty(pfi.Billing_Client_Company__r.A_R_coordinator__c)) ? pfi.Billing_Client_Company__r.A_R_coordinator__r.Email : '';

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
            hourlyInvoiceDescriptionRendered = pfi.Include_Supporting_Documentation__c;
            for( Billing_Line_Item__c bli : pfi.Billing_Line_Items__r ) {
                if( bli.isHourlyConsulting__c ) hourlyBlis.add(bli);
            } 
        }

    }

    public class LineWrapper {
        public String refNumber { get { if( refNumber == null ) refNumber = ''; return refNumber; } set; }
        public String serviceNameShort { get { if( serviceNameShort == null ) serviceNameShort = ''; return serviceNameShort; } set; }
        public String description { get { if( description == null ) description = ''; return description; } set; }
        public Decimal quantity { get { if( quantity == null ) quantity = 0.00; return quantity; } set; }
        public Decimal unitPrice { get { if( unitPrice  == null ) unitPrice = 0.00; return unitPrice; } set; }
        public Decimal amount { get { if( amount == null ) amount = 0.00; return amount; } set; }
		public Boolean isTaxable { get { if( isTaxable == null ) isTaxable = false; return isTaxable; } private set; } //MRS 7519
        public String floors { get { if( floors == null ) floors = ''; return floors; } set; }
        public Boolean isReimbursable { get { if( isReimbursable == null ) isReimbursable = false; return isReimbursable; } set; }
        public Boolean showUnitPrice { get { if( showUnitPrice == null ) showUnitPrice = true; return showUnitPrice; } set; }
        public Id phaseId { get; set; }
        public String phaseName { get { if(phaseName == null) return ''; return phaseName; } set; }

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

            this.description = ( !String.isEmpty( bli.Description__c ) ? bli.Description__c : '' );
			//if(bli.Quantity__c == null) bli.Quantity__c = 0;
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
                    this.description += ' ' + (bli.Quantity__c * 100).round() + '%';
                    this.showUnitPrice = false;
                } else if( bli.isReimbursable__c ) {
                    this.description += ' ' + (bli.Quantity__c * 100).round() + '%';
                } else {
                    if( bli.isHourlyConsulting__c ) {
                        this.description = joinStrings( new List<String>{ serviceName, description + ownerName } ) + ' ' + (bli.Quantity__c * 100).round() + '%';
                    } else {
                        if( ( pfi.Project_Profile__r.Interval__c ) ||
                            ( !pfi.Project_Profile__r.Interval__c && String.isBlank( bli.Service_Name__c ) )
							|| ( !pfi.Project_Profile__r.Interval__c && String.isBlank( bli.Description__c ) ) ) {
                            this.description = 'Percentage Billing' + ' ' + (bli.Quantity__c * 100).round() + '%';
                        } else {
							if(!String.isBlank( bli.Service_Name__c )) {
                            	this.description = bli.Service_Name__c;
							}
							this.description += ' ' + (bli.Quantity__c * 100).round() + '%'; 
							
                        }
                    }
                }
            } else if( pfi.Project_Profile__r.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
                if( !String.isEmpty( bli.Description__c ) && bli.Description__c.contains( ProformaInvoiceServices.CHANGE_ORDER_BALANCE ) ) {
                    this.description += ' ' + (bli.Quantity__c * 100).round() + '%';
                    this.showUnitPrice = false;
                } else if( bli.isReimbursable__c ) {
                    this.description += ' ' + (bli.Quantity__c * 100).round() + '%';
                } else {
                    if( bli.isHourlyConsulting__c ) {
                        this.description = joinStrings( new List<String>{ serviceName, description + ownerName } ) + ' ' + (bli.Quantity__c * 100).round() + '%';
                    } else {
                        this.description = ( !String.isEmpty( pfi.Project_Profile__r.Frequency__c ) ? pfi.Project_Profile__r.Frequency__c + ' ' : '' ) 
						+ 'Installment Billing ' + ( bli.Billing_Date__r.Step_Number__c != null ? String.valueOf( bli.Billing_Date__r.Step_Number__c ) : '0' )
						+ ' of ' + project.Billing_Dates__r.size() + ' ' + (bli.Quantity__c * 100).round() + '%';
                    }
                }
            }

            if( !String.isBlank( bli.Service_Item__c ) &&
                bli.Service_Item__r.Subtype__c == ServiceItemServices.SUBTYPE_AHV &&
                !String.isBlank( bli.Service_Item__r.Phase__c ) &&
                !bli.Service_Item__r.Phase__r.Is_default__c &&
                bli.Service_Item__r.Phase__r.Name__c != PhaseServices.SINGLE_PHASE ) {
                this.description = bli.Service_Item__r.Phase__r.Name__c + ' ' + this.description; 
            } else {
                this.description = ( bli.Milestone_Date__c == null ? '' : bli.Milestone_Date__c.format() ) + ' ' + this.description;
            }

            this.description = splitStringIfHasWordsLonger(this.description, 29);

            if(!String.isBlank(bli.Service_Item__c) && !String.isBlank(bli.Service_Item__r.Phase__c) && !String.isBlank(bli.Service_Item__r.Phase__r.Name__c)) {
                this.phaseId = bli.Service_Item__r.Phase__c;
                this.phaseName = bli.Service_Item__r.Phase__r.Name__c;
            }

        }

        public String splitStringIfHasWordsLonger(String s, Integer pos) {
            String res = '';
            for(String subS : s.split(' ')) {
                res += res.length() > 0 ? ' ' : '';
                res += subS.length() > pos ? subS.substring(0, pos) + ' ' + splitStringIfHasWordsLonger(subS.substring(pos, subS.length()), pos) : subS;
            }
            return res;
        }

        public String joinStrings( List<String> input ) {
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

    public Pro_forma_Invoice__c getParentWithBlis( Id parentId ) {
        List<Pro_forma_Invoice__c> parents = [ SELECT Name, Invoice_Date__c, Client_Project__c,
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
                                                      Billing_Client_Company__r.A_R_coordinator__r.Title,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Phone,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Email,
                                                      Billing_Contact__r.MailingStreet,
                                                      Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState,
                                                      Billing_Contact__r.MailingPostalCode, Billing_Contact__r.Salutation, Billing_Contact__r.Name,
                                                      Invoice_Format__c, Project_Profile__r.Billing_Method__c,
                                                      Subtotal__c, Tax__c, Credit__c, Amount_Due__c, Display_Text_on_Invoice__c,
                                                      Project_Profile__r.Frequency__c, Project_Profile__r.Number_Of_Intervals__c,
                                                      Purchase_Order__c,
													  Purchase_Order__r.Name,
													  Purchase_Order__r.Purchase_Order_Amount__c,
													  Purchase_Order__r.Remaining_Balance_Reimbursables__c,
													  Purchase_Order__r.Remaining_Balance_Services__c,
													  Purchase_Order__r.Remaining_Balance_Municipal_Fees__c,
													  Purchase_Order__r.Reimbursables__c,
													  Purchase_Order__r.Services__c,
													  Purchase_Order__r.Municipal_Fees__c,
													  Project_Profile__r.Proposal__r.Name,
                                                      Project_Address_Building_AKA__c, Project_Profile__r.Building_AKA__c,
                                                      Project_Address__r.City__c, Project_Address__r.State__c, Project_Address__r.PostalCode__c,
                                                      Project_Profile__r.Building_AKA__r.Building__r.City__c, Project_Profile__r.Building_AKA__r.Building__r.State__c, Project_Profile__r.Building_AKA__r.Building__r.PostalCode__c,
                                                      Project_Profile__r.Proposal__r.Is_Floors_To_Services__c,
                                                      Include_Supporting_Documentation__c,
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

    public Project_Profile__c getProject( Id profileId ) {
        Project_Profile__c project = new Project_Profile__c();
        if( !String.isEmpty( profileId ) ) {
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

    public String getAddress2() {
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