public without sharing class ASRRController {
    private static final String TYPE_BASE = 'Base';
    private static final String TYPE_CO = 'Change Order';
    private static final String TYPE_INSTPERC = 'Installment-Percentage';
    private static final String TYPE_REIMB = 'Reimbursables';
    private static final String DOC_NEW = 'new';
    private static final String DOC_OLD = 'old';

    public String renderAs { get; set; }
    public Boolean showAsPage { get; set; }
    public Boolean detail { get; set; }
    public Project_Profile__c parent { get; private set; }
    public String parentInvoiceId { get; private set; }
    public Boolean isValid { get; private set; }
    public ASRRWrapper content { get; set; }
    
    public Boolean showPurchaseOrder { get { if( showPurchaseOrder == null ) showPurchaseOrder = false; return showPurchaseOrder; } set; }
    
    private String ppr;
    private String bc;
    private String documentType; //MRS-6641

    public String address1 { get { if( parent != null ) { return parent.Address_Building_AKA__c; } else { return ''; } } set; }
    public String address2 { get { if( parent != null ) { return getAddress2(); } else { return ''; } } set; }

    public String milroseLogoIdExternalUrl { get { return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + milroseLogoId + '&oid=' + UserInfo.getOrganizationId(); } }
    public String milroseLogoId {
        get {
            if( milroseLogoId == null ) {
                List<Document> docs = [ SELECT Id FROM Document WHERE DeveloperName = : MilroseDevHelper.MILROSE_LOGO_DOCUMENT_DEVELOPER_NAME ];
                if( !docs.isEmpty() ) {
                    milroseLogoId = docs[0].Id;
                } else {
                    milroseLogoId = '';
                }
            }
            return milroseLogoId;
        }
        set;
    }

	public String parentSplitedClient_Project { set; get { //MRS 7403
			if(parent != null && parent.Client_Project__c != null) return splitStringIfHasWordsLonger(parent.Client_Project__c, 15);
			return '';
		}
	}

	public static String splitStringIfHasWordsLonger(String s, Integer pos) {
        String res = '';
        for(String subS : s.split(' ')) {
            res += res.length() > 0 ? ' ' : '';
            res += subS.length() > pos ? subS.substring(0, pos) + ' ' + splitStringIfHasWordsLonger(subS.substring(pos, subS.length()), pos) : subS;
        }
        return res;
    }

    public ASRRController() {
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        parentInvoiceId = ApexPages.currentPage().getParameters().get('inv');
        renderAs = !( String.isEmpty( ApexPages.currentPage().getParameters().get('renderAs') ) ) ? 'pdf' : '';
        if( renderAs == 'pdf' ) {
            showAsPage = ( !String.isEmpty( ApexPages.currentPage().getParameters().get('page') ) && ApexPages.currentPage().getParameters().get('page') == 'true' ) ? true : false;
        }
        detail = ( !String.isEmpty( ApexPages.currentPage().getParameters().get('detail') ) && ApexPages.currentPage().getParameters().get('detail') == 'true' ) ? true : false;
        ppr = ApexPages.currentPage().getParameters().get('ppr');
        bc  = ApexPages.currentPage().getParameters().get('bc');
        documentType = ApexPages.currentPage().getParameters().get('type');
        if( String.isEmpty( documentType ) || documentType != DOC_NEW ) {
            documentType = DOC_OLD;
        } else {
            documentType = DOC_NEW;
        }

        if( parentId == null || !(parentId instanceOf Id) ) {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
        List<Project_Profile__c> parents = [ SELECT Id, Address_Building_AKA__c, Floor_s__c, Name, Client_Project__c, Project_Name__c,
                                                    Billing_Method__c, Frequency__c, Number_Of_Intervals__c, Interval__c,
                                                    Billing_Company_Name__r.A_R_Coordinator_Full_Name__c, Billing_Company_Name__r.A_R_Coordinator_Phone__c, Billing_Company_Name__r.A_R_Coordinator_Email__c,
                                                    Billing_Company_Name__c, Building_AKA__c, PO_Required__c,
                                                    Building_AKA__r.Building__r.City__c, Building_AKA__r.Building__r.State__c, Building_AKA__r.Building__r.PostalCode__c,
                                                    Building__r.City__c, Building__r.State__c, Building__r.PostalCode__c, 
                            (Select Id, Name From Purchase_Orders__r limit 1)
                                             FROM Project_Profile__c
                                             WHERE Id = : parentId ];
        if( parents.isEmpty() ) {
            isValid = false;
            MilroseDevHelper.addMessage('No Project Profile was found.');
            return;
        } else {
            parent = parents[0];
        if( parent.PO_Required__c || !parent.Purchase_Orders__r.isEmpty() ) showPurchaseOrder = true;
        }
        content = new ASRRWrapper( parent, parentInvoiceId, documentType == DOC_OLD, detail, ppr, bc );

        if( renderAs == 'pdf' ) {
            if( !showAsPage ) {
                Apexpages.currentPage().getHeaders().put( 'Content-Type', 'application/pdf; charset=UTF-8;' );
                Apexpages.currentPage().getHeaders().put( 'Content-Disposition', 'attachment; filename="Account Summary Recap Report' + ( parent != null ? ' - ' + parent.Name : '' ) + '.pdf"' );
            }
        } else {
            Apexpages.currentPage().getHeaders().put( 'Content-Type', 'application/vnd.ms-excel; charset=UTF-8;' );
            Apexpages.currentPage().getHeaders().put( 'Content-Disposition', 'attachment; filename="Account Summary Recap Report' + ( parent != null ? ' - ' + parent.Name : '' ) + '.xls"' );
        }
    }

    public without sharing class ASRRWrapper {
        public List<ASRRWrapperTable> tables { get { if( tables == null ) tables = new List<ASRRWrapperTable>(); return tables; } set; }
        //public List<c2g__codaTransactionLineItem__c> transactions { get { if( transactions == null ) transactions = new List<c2g__codaTransactionLineItem__c>(); return transactions; } set; } //MRS-5069

        public Decimal proposedAmount { get { if( proposedAmount == null ) proposedAmount = 0.00; return proposedAmount; } set; }
        public Decimal proposedAmountCO  { get { if( proposedAmountCO == null ) proposedAmountCO = 0.00; return proposedAmountCO; } set; }
        public Decimal amountBilled { get { if( amountBilled == null ) amountBilled = 0.00; return amountBilled; } set; }
        public Decimal amountPaid { get { if( amountPaid == null ) amountPaid = 0.00; return amountPaid; } set; }
        public Decimal amountDue { get { if( amountDue == null ) amountDue = 0.00; return amountDue; } set; }
        public Decimal balanceToBill { get { if( balanceToBill == null ) balanceToBill = 0.00; return balanceToBill; } set; }
        private Decimal amountBilledReimb { get { if( amountBilledReimb == null ) amountBilledReimb = 0.00; return amountBilledReimb; } set; }

        public ASRRWrapper( Project_Profile__c profile, String parentInvoiceId, Boolean isOldDocumentType, Boolean detail, String ppr, String bc ) {
            Integer seqNumber = 1;
            String query;

            query  = 'SELECT Name, Service_Name_Full__c, Quantity__c, Quantity_Old__c, Discounted_Unit_Price__c, ';
            query +=        'Total_Discounted_Price_Tax__c, Municipal_Agency_ID__c, Is_Amendmend_Added__c, Original__c, ';
            query +=        'Is_Amendmend_Deleted__c, Balance_to_Bill__c, Project_Profile__c, Status__c, ';
            query +=        'Phase__c, Phase__r.Number__c, Phase__r.Name__c, Tax_Percent_1__c, Tax_Percent_2__c, ';
            query +=        'Change_Order__c, Change_Order__r.Status__c, Change_Order__r.Number__c, Purchase_Order__c, Purchase_Order__r.Name,';
            query +=        'Change_Order_Old__c, Change_Order_Old__r.Status__c, Change_Order_Old__r.Number__c, ';
            query +=        '( SELECT Pro_forma_Invoice__r.Invoice_Date__c, Pro_forma_Invoice__r.Name_without_Prefix__c, ';
            query +=                 'Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c, ';
            query +=                 'Amount_Billed__c, cl_Amount_Paid2__c, Amount_Due__c, ';
            query +=                 'Related_Service_Item__r.Municipal_Agency_ID__c, Purchase_Order__c, Purchase_Order__r.Name,';
            query +=                 'Pro_forma_Invoice__c, Pro_forma_Invoice__r.Sales_Invoice__c, Pro_forma_Invoice__r.Sales_Invoice__r.c2g__InvoiceStatus__c ';
            query +=          'FROM Billing_Line_Items_del__r ';
            query +=          'WHERE Hide_from_Recap__c = false ';//MRS-6549
            query +=          'AND Department_Based__c = false ';//MRS-7373
            if( String.isBlank( ppr ) && String.isBlank( bc ) ) {
                query +=      'AND Pro_forma_Invoice__r.Billing_Client_Company__c = \'' + profile.Billing_Company_Name__c + '\' ';
            } else if( !String.isBlank( bc ) ) {
                query +=      'AND Pro_forma_Invoice__r.Billing_Client_Company__c = \'' + bc + '\' ';
            }
            query += ') ';
            query += 'FROM Service_Item__c ';
            //query += 'WHERE Project_Profile__c = \'' + profile.Id + '\' AND Status__c != \'' + ServiceItemServices.SERVICE_STATUS_INACTIVE + '\''; //removed Status__c check in MRS-6296
            query += 'WHERE Project_Profile__c = \'' + profile.Id + '\'';
            query += 'ORDER BY Phase__r.Number__c, ';
            query +=       'Row_Position__c ';

            List<Service_Item__c> baseServices = new List<Service_Item__c>();
            Map<Integer, List<Service_Item__c>> coServices = new Map<Integer, List<Service_Item__c>>();
            Map<Integer, List<Service_Item__c>> coServicesDeleted = new Map<Integer, List<Service_Item__c>>();
            for( Service_Item__c si : Database.query( query ) ) {
                Integer coNumberNew = Integer.valueOf( si.Change_Order__r.Number__c );
                Integer coNumberOld = Integer.valueOf( si.Change_Order_Old__r.Number__c );
                Boolean isQuantityCO = si.Quantity_Old__c != null && si.Quantity_Old__c != 0;

                Boolean containsPostedInvoice = false; //MRS-6296
                if( si.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE && !si.Billing_Line_Items_del__r.isEmpty() ) {
                    for( Billing_Line_Item__c bli : si.Billing_Line_Items_del__r ) {
                    system.debug('!!! bli.Pro_forma_Invoice__c= ' + bli.Pro_forma_Invoice__c);
                    system.debug('!!! bli.Pro_forma_Invoice__r.Sales_Invoice__c= ' + bli.Pro_forma_Invoice__r.Sales_Invoice__c);
                    system.debug('!!! bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__InvoiceStatus__c= ' + bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__InvoiceStatus__c);
                        if( bli.Pro_forma_Invoice__c != null && bli.Pro_forma_Invoice__r.Sales_Invoice__c != null && bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__InvoiceStatus__c == 'Complete' ) {
                            containsPostedInvoice = true;
                            break;
                        }
                    }
                }

                if( isOldDocumentType || //MRS-6641 for old doc style show removed service in both COs '+' in original CO/Base Section and '-' in current CO, for new doc style don't show them at all (except for the case when it has a posted invoice)
                    ( si.Status__c != ServiceItemServices.SERVICE_STATUS_INACTIVE || containsPostedInvoice ) ) { //MRS-6296
                    if( si.Original__c ) { //Base services
                        baseServices.add( si );
                        if( coNumberNew != null && si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ) { //deleted from Base Section to new CO, or quantity CO
                            if( isOldDocumentType || !isQuantityCO ) { //MRS-6676 if quantity is changed, don't show the service in CO (show in Base section with new quantity instead)
                                if( !coServicesDeleted.containsKey( coNumberNew ) ) {
                                    coServicesDeleted.put( coNumberNew, new List<Service_Item__c>() );
                                }
                                coServicesDeleted.get( coNumberNew ).add( si );
                            }
                        }
                    } else { //CO services
                        if( coNumberOld != null ) {
                            if( !coServices.containsKey( coNumberOld ) ) {
                                coServices.put( coNumberOld, new List<Service_Item__c>() );
                            }
                            coServices.get( coNumberOld ).add( si );
                            if( si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ) { //deleted from old CO to new CO, or quantity CO
                                if( isOldDocumentType || !isQuantityCO ) { //MRS-6676 if quantity is changed, don't show the service in CO (show in original CO with new quantity instead)
                                    if( !coServicesDeleted.containsKey( coNumberNew ) ) {
                                        coServicesDeleted.put( coNumberNew, new List<Service_Item__c>() );
                                    }
                                    coServicesDeleted.get( coNumberNew ).add( si );
                                }
                            }
                        } else {
                            if( si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ) { //added to CO
                                if( !coServices.containsKey( coNumberNew ) ) {
                                    coServices.put( coNumberNew, new List<Service_Item__c>() );
                                }
                                coServices.get( coNumberNew ).add( si );
                            }
                        }
                    }
                }
            }
            for( Integer coNumber : coServicesDeleted.keySet() ) { //put deleted services to the end of list of new CO
                if( !coServices.containsKey( coNumber ) ) {
                    coServices.put( coNumber, new List<Service_Item__c>() );
                }
                coServices.get( coNumber ).addAll( coServicesDeleted.get( coNumber ) );
            }

            tables.add( new ASRRWrapperTable( profile, parentInvoiceId, null, baseServices, TYPE_BASE, seqNumber++, isOldDocumentType, detail ) );
            List<Integer> coNumbers = new List<Integer>( coServices.keySet() );
            coNumbers.sort();
            for( Integer key : coNumbers ) {
                if( !coServices.get( key ).isEmpty() ) {
                    tables.add( new ASRRWrapperTable( profile, parentInvoiceId, key, coServices.get( key ), TYPE_CO, seqNumber++, isOldDocumentType, detail ) );
                }
            }

            query  = 'SELECT Amount_Billed__c, cl_Amount_Paid2__c, Amount_Due__c, Project_Profile__c, ';
            query +=        'Municipal_Agency_ID__c, Description__c, Billing_Date_Step_Number__c, ';
            query +=        'Service_Item__c, Pro_forma_Invoice__c, isReimbursable__c, Purchase_Order__c, Purchase_Order__r.Name, ';
            query +=        'Invoice_Date__c, Pro_forma_Invoice__r.Name_without_Prefix__c, Related_Service_Item__r.Municipal_Agency_ID__c, ';
            query +=        'Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c ';
            query += 'FROM Billing_Line_Item__c ';
            query += 'WHERE Pro_forma_Invoice__r.Project_Profile__c = \'' + profile.Id + '\' AND Hide_from_Recap__c = false ';//MRS-6549
            query +=          'AND Department_Based__c = false ';//MRS-7373
            if( String.isBlank( ppr ) && String.isBlank( bc ) ) {
                query += 'AND Pro_forma_Invoice__r.Billing_Client_Company__c = \'' + profile.Billing_Company_Name__c + '\' ';
            } else if( !String.isBlank( bc ) ) {
                query += 'AND Pro_forma_Invoice__r.Billing_Client_Company__c = \'' + bc + '\' ';
            }
            query += 'ORDER BY CreatedDate ASC';

            List<Billing_Line_Item__c> blItems = new List<Billing_Line_Item__c>();
            List<Billing_Line_Item__c> blItemsReimb = new List<Billing_Line_Item__c>();
            for( Billing_Line_Item__c bli : Database.query( query ) ) {
            system.debug('!!! bli.Pro_forma_Invoice__c= ' + bli.Pro_forma_Invoice__c);
                    system.debug('!!! bli.Pro_forma_Invoice__r.Sales_Invoice__c= ' + bli.Pro_forma_Invoice__r.Sales_Invoice__c);
                    system.debug('!!! bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c = ' + bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c );
                if( !String.isEmpty( bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c ) || !String.isEmpty( parentInvoiceId ) || Test.isRunningTest() ) {
                    if( !bli.isReimbursable__c ) {
                        if( profile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !profile.Interval__c ) {
                            blItems.add( bli );
                        } else if( String.isBlank( bli.Service_Item__c ) ) {
                            blItems.add( bli );
                        }
                    } else {
                        blItemsReimb.add( bli );
                    }
                }
            }
            if( !blItems.isEmpty() ) {
                tables.add( new ASRRWrapperTable( profile, parentInvoiceId, blItems, TYPE_INSTPERC, seqNumber++ ) );
            }
            if( !blItemsReimb.isEmpty() ) {
                tables.add( new ASRRWrapperTable( profile, parentInvoiceId, blItemsReimb, TYPE_REIMB, seqNumber++ ) );
            }

            for( ASRRWrapperTable table : tables ) {
                proposedAmount += table.proposedAmount;
                proposedAmountCO += table.proposedAmountCO;
                amountBilled += table.amountBilled;
                amountPaid += table.amountPaid;
                amountDue += table.amountDue;
                amountBilledReimb += table.amountBilledReimb;
            }
            balanceToBill += proposedAmount + proposedAmountCO - amountBilled + amountBilledReimb;

            /* //MRS-5069
            List<c2g__codaTransactionLineItem__c> transactionsFromDB = [ SELECT Project_Profile__c, c2g__DocumentOutstandingValue__c, Statement_Reference__c, Document_Number__c,
                                                                                c2g__Account__c, Deposit_Invoice__r.Project_Profile__r.Billing_Company_Name__c
                                                                         FROM c2g__codaTransactionLineItem__c
                                                                         WHERE Deposit_Invoice__r.Project_Profile__c = : profile.Id AND
                                                                               ( c2g__Transaction__r.c2g__TransactionType__c = 'Cash' OR
                                                                                 c2g__Transaction__r.c2g__TransactionType__c = 'Journal' OR
                                                                                 c2g__Transaction__r.c2g__TransactionType__c = 'Credit Note' OR
                                                                                 c2g__Transaction__r.c2g__TransactionType__c = 'Cash Matching Journal' ) AND
                                                                               c2g__LineType__c = 'Account' AND
                                                                               c2g__MatchingStatus__c = 'Available' ];
            for( c2g__codaTransactionLineItem__c tli : transactionsFromDB ) {
                if( tli.c2g__Account__c == tli.Deposit_Invoice__r.Project_Profile__r.Billing_Company_Name__c ) {
                    transactions.add( tli );
                    amountDue += tli.c2g__DocumentOutstandingValue__c != null ? tli.c2g__DocumentOutstandingValue__c : 0.00;
                }
            }
            */
        }
    }

    public without sharing class ASRRWrapperTable {
        public List<ASRRWrapperSection> sections { get { if( sections == null ) sections = new List<ASRRWrapperSection>(); return sections; } set; }
        public String header { get; set; }
        public Integer seqNumber { get; set; }

        public Decimal proposedAmount { get { if( proposedAmount == null ) proposedAmount = 0.00; return proposedAmount; } set; }
        public Decimal proposedAmountCO  { get { if( proposedAmountCO == null ) proposedAmountCO = 0.00; return proposedAmountCO; } set; }
        public Decimal amountBilled { get { if( amountBilled == null ) amountBilled = 0.00; return amountBilled; } set; }
        public Decimal amountPaid { get { if( amountPaid == null ) amountPaid = 0.00; return amountPaid; } set; }
        public Decimal amountDue { get { if( amountDue == null ) amountDue = 0.00; return amountDue; } set; }
        public Decimal balanceToBill { get { if( balanceToBill == null ) balanceToBill = 0.00; return balanceToBill; } set; }
        public Boolean showProposedAmount { get { if( showProposedAmount == null ) showProposedAmount = true; return showProposedAmount; } set; }
        public Boolean showProposedAmountCO { get { if( showProposedAmountCO == null ) showProposedAmountCO = true; return showProposedAmountCO; } set; }
        public Boolean showAmountBilled { get { if( showAmountBilled == null ) showAmountBilled = true; return showAmountBilled; } set; }
        public Boolean showAmountPaid { get { if( showAmountPaid == null ) showAmountPaid = true; return showAmountPaid; } set; }
        public Boolean showAmountDue { get { if( showAmountDue == null ) showAmountDue = true; return showAmountDue; } set; }
        public Boolean showBalanceToBill { get { if( showBalanceToBill == null ) showBalanceToBill = true; return showBalanceToBill; } set; }
        private Decimal amountBilledReimb { get { if( amountBilledReimb == null ) amountBilledReimb = 0.00; return amountBilledReimb; } set; }

        public ASRRWrapperTable( Project_Profile__c profile, String parentInvoiceId, Integer changeOrderNumber, List<Service_Item__c> sItems, String type, Integer seqNumber, Boolean isOldDocumentType, Boolean detail ) {
            this.seqNumber = seqNumber;
            Map<Integer, List<Service_Item__c>> phaseServices = new Map<Integer, List<Service_Item__c>>();
            for( Service_Item__c si : sItems ) {
                Integer phaseNumber = Integer.valueOf( si.Phase__r.Number__c );
                if( !phaseServices.containsKey( phaseNumber ) ) {
                    phaseServices.put( phaseNumber, new List<Service_Item__c>() );
                }
                phaseServices.get( phaseNumber ).add( si );
            }
            phaseServices.remove(null);
            List<Integer> phaseNumbers = new List<Integer>( phaseServices.keySet() );
            phaseNumbers.sort();
            for( Integer key : phaseNumbers ) {
                if( !phaseServices.get( key ).isEmpty() ) {
                    sections.add( new ASRRWrapperSection( profile, parentInvoiceId, changeOrderNumber, phaseServices.get( key ), type, isOldDocumentType, detail ) );
                }
            }
            sumUpTotals( type );
            if( type == TYPE_BASE ) {
                header = String.valueOf( seqNumber ) + '. Base';
                showProposedAmountCO = false;
            }
            if( type == TYPE_CO ) {
                header = String.valueOf( seqNumber ) + '. Change Order # ' + changeOrderNumber;
                showProposedAmount = false;
            }
        }

        public ASRRWrapperTable( Project_Profile__c profile, String parentInvoiceId, List<Billing_Line_Item__c> blItems, String type, Integer seqNumber ) {
            this.seqNumber = seqNumber;
            sections.add( new ASRRWrapperSection( profile, parentInvoiceId, blItems, type ) );
            sumUpTotals( type );
            if( type == TYPE_INSTPERC ) {
                header = 'Installment/Percentage Billing';
                showProposedAmount = false;
                showProposedAmountCO = false;
            }
            if( type == TYPE_REIMB ) {
                header = 'Reimbursables';
                showProposedAmount = false;
                showProposedAmountCO = false;
                //showBalanceToBill = false;
            }
        }

        private void sumUpTotals( String type ) {
            for( ASRRWrapperSection section : sections ) {
                for( ASRRWrapperLine line : section.lines ) {
                    proposedAmount += line.proposedAmount;
                    proposedAmountCO += line.proposedAmountCO;
                    amountBilled += line.amountBilled;
                    amountPaid += line.amountPaid;
                    amountDue += line.amountDue;
                    balanceToBill += line.balanceToBill;
                    if( type == TYPE_REIMB ) {
                        amountBilledReimb += line.amountBilled;
                    }
                }
            }
        }
    }

    public without sharing class ASRRWrapperSection {
        public List<ASRRWrapperLine> lines { get { if( lines == null ) lines = new List<ASRRWrapperLine>(); return lines; } set; }
        public String header { get { if( header == null ) header = ''; return header; } set; }
        public Boolean showHeader { get { if( showHeader == null ) showHeader = true; return showHeader; } set; }

        public ASRRWrapperSection( Project_Profile__c profile, String parentInvoiceId, Integer changeOrderNumber, List<Service_Item__c> sItems, String type, Boolean isOldDocumentType, Boolean detail ) {
            header = String.valueOf( sItems[0].Phase__r.Name__c );
            for( Service_Item__c si : sItems ) {
                lines.add( new ASRRWrapperLine( profile, parentInvoiceId, changeOrderNumber, si, type, isOldDocumentType, detail ) );
            }
        }

        public ASRRWrapperSection( Project_Profile__c profile, String parentInvoiceId, List<Billing_Line_Item__c> blItems, String type ) {
            showHeader = false;
            for( Billing_Line_Item__c bli : blItems ) {
                lines.add( new ASRRWrapperLine( profile, parentInvoiceId, bli, type ) );
            }
        }
    }

    public without sharing class ASRRWrapperLine {
        public String psn { get; set; }
        public String serviceItem { get; set; }
        public Decimal proposedAmount { get { if( proposedAmount == null ) proposedAmount = 0.00; return proposedAmount; } set; }
        public Boolean showProposedAmount { get { if( showProposedAmount == null ) showProposedAmount = true; return showProposedAmount; } set; }
        public Decimal proposedAmountCO { get { if( proposedAmountCO == null ) proposedAmountCO = 0.00; return proposedAmountCO; } set; }
        public Boolean showProposedAmountCO { get { if( showProposedAmountCO == null ) showProposedAmountCO = true; return showProposedAmountCO; } set; }
        public String municipalAgency { get { if( municipalAgency == null ) municipalAgency = ''; return municipalAgency; } set { if( !String.isBlank(value) ) municipalAgency = value; } }
        public String invoiceNumbers { get { if( invoiceNumbers == null ) invoiceNumbers = ''; return invoiceNumbers; } set { if( !String.isBlank(value) ) invoiceNumbers = value; }  }
        public String invoiceDates { get { if( invoiceDates == null ) invoiceDates = ''; return invoiceDates; } set { if( !String.isBlank(value) ) invoiceDates = value; }  }
        public String purchaseOrder { get { if( purchaseOrder == null ) purchaseOrder = ''; return splitStringIfHasWordsLonger(purchaseOrder, 15); } set { if( !String.isBlank(value) ) purchaseOrder = value; }  } //MRS 7403
        public String amountsBilled { get { if( amountsBilled == null ) amountsBilled = ''; return amountsBilled; } set; }
        public String amountsPaid { get { if( amountsPaid == null ) amountsPaid = ''; return amountsPaid; } set; }
        public String amountsDue { get { if( amountsDue == null ) amountsDue = ''; return amountsDue; } set; }

        public Decimal amountBilled { get { if( amountBilled == null ) amountBilled = 0.00; return amountBilled; } set; }
        public Decimal amountPaid { get { if( amountPaid == null ) amountPaid = 0.00; return amountPaid; } set; }
        public Decimal amountDue { get { if( amountDue == null ) amountDue = 0.00; return amountDue; } set; }
        public Decimal balanceToBill { get { if( balanceToBill == null ) balanceToBill = 0.00; return balanceToBill; } set; }
        public Boolean showMunicipalAgency { get { if( showMunicipalAgency == null ) showMunicipalAgency = true; return showMunicipalAgency; } set; }
        public Boolean showInvoiceNumbers { get { if( showInvoiceNumbers == null ) showInvoiceNumbers = true; return showInvoiceNumbers; } set; }
        public Boolean showInvoiceDates { get { if( showInvoiceDates == null ) showInvoiceDates = true; return showInvoiceDates; } set; }
        public Boolean showParentName { get { if( showParentName == null ) showParentName = true; return showParentName; } set; }
        public Boolean showClientProject { get { if( showClientProject == null ) showClientProject = true; return showClientProject; } set; }
        public Boolean showAmountBilled { get { if( showAmountBilled == null ) showAmountBilled = true; return showAmountBilled; } set; }
        public Boolean showAmountPaid { get { if( showAmountPaid == null ) showAmountPaid = true; return showAmountPaid; } set; }
        public Boolean showAmountDue { get { if( showAmountDue == null ) showAmountDue = true; return showAmountDue; } set; }
        public Boolean showBalanceToBill { get { if( showBalanceToBill == null ) showBalanceToBill = true; return showBalanceToBill; } set; }
        public Boolean isInvoicePosted { get { if( isInvoicePosted == null ) isInvoicePosted = false; return isInvoicePosted; } set; }
        public Boolean showAmounts { get { if( showAmounts == null ) showAmounts = true; return showAmounts; } set; }
        public String fontWeight { get { if( fontWeight == null ) fontWeight = 'normal'; return fontWeight; } set; }

        public ASRRWrapperLine( Project_Profile__c profile, String parentInvoiceId, Integer changeOrderNumber, Service_Item__c si, String type, Boolean isOldDocumentType, Boolean detail ) {
            Boolean isQuantityCO = si.Quantity_Old__c != null && si.Quantity_Old__c != 0;
            Boolean isMilestone = profile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE;
            psn = si.Name;

            Decimal quantity = 0; //number of services
            if( isOldDocumentType ) {
                if( !isQuantityCO ) {
                    quantity = si.Quantity__c;
                } else {
                    if( ( changeOrderNumber == null && si.Change_Order_Old__c == null ) || ( changeOrderNumber != null && si.Change_Order_Old__r.Number__c == changeOrderNumber ) ) {
                        quantity = si.Quantity_Old__c;
                    } else {
                        quantity = si.Quantity_Old__c - si.Quantity__c;
                    }
                }
            } else {
                if( !isQuantityCO ) {
                    quantity = si.Quantity__c;
                } else {
                    if( si.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED ) {
                        quantity = si.Quantity_Old__c;
                    } else {
                        quantity = si.Quantity__c;
                    }
                }
            }

            serviceItem = si.Service_Name_Full__c + ' (' + String.valueOf( quantity ) + ' @ $' + String.valueOf( si.Discounted_Unit_Price__c ) + ')';

            Decimal singleServicePrice = si.Discounted_Unit_Price__c * ( 1 + ( si.Tax_Percent_1__c != null ? si.Tax_Percent_1__c : 0 ) + ( si.Tax_Percent_2__c != null ? si.Tax_Percent_2__c : 0 ) );

            if( type == TYPE_BASE ) { //base services section
                showProposedAmountCO = false;
                if( isQuantityCO && ( isOldDocumentType || si.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED ) ) {
                    proposedAmount = quantity * singleServicePrice;
                } else {
                    proposedAmount = ( si.Is_Amendmend_Deleted__c ? -1 : 1 ) * si.Total_Discounted_Price_Tax__c;
                }
            }
            if( type == TYPE_CO ) { //co services sections
                showProposedAmount = false;
                if( isOldDocumentType ) {
                    if( isQuantityCO ) {
                        if( si.Change_Order_Old__r.Number__c == changeOrderNumber ) {
                            proposedAmountCO = si.Quantity_Old__c * singleServicePrice;
                        } else {
                            proposedAmountCO = -1 * quantity * singleServicePrice;
                        }
                    } else {
                        proposedAmountCO = ( si.Is_Amendmend_Deleted__c && ( si.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED || si.Change_Order_Old__r.Number__c == changeOrderNumber ) ) ? (-1) * si.Total_Discounted_Price_Tax__c : si.Total_Discounted_Price_Tax__c;
                    }
                } else {
                    if( isQuantityCO && si.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED ) {
                        proposedAmountCO = quantity * singleServicePrice;
                    } else {
                        proposedAmountCO = ( si.Is_Amendmend_Deleted__c && si.Change_Order_Old__r.Number__c == changeOrderNumber ? -1 : 1 ) * si.Total_Discounted_Price_Tax__c;
                    }
                }
            }

            municipalAgency = si.Municipal_Agency_ID__c;
            purchaseOrder = ( si.Purchase_Order__c != null && !detail ) ? si.Purchase_Order__r.Name : '';
        
            for( Billing_Line_Item__c bli : si.Billing_Line_Items_del__r ) {
                if( ( ( ( bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c != null ) ||
                        ( !String.isEmpty( parentInvoiceId ) ) ) &&
                     !( profile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !profile.Interval__c ) ) ||
                    ( Test.isRunningTest() ) ) {
                    isInvoicePosted = true;

                    Decimal currentAmountBilled = 0.00;
                    Decimal currentAmountPaid = 0.00;
                    Decimal currentAmountDue = 0.00;

                    if( ( ( !si.Is_Amendmend_Deleted__c ) || ( si.Is_Amendmend_Deleted__c && si.Change_Order_Old__r.Number__c == changeOrderNumber ) ) &&
                        ( !isQuantityCO || ( isQuantityCO && ( ( changeOrderNumber == null && si.Change_Order_Old__c == null ) || ( changeOrderNumber != null && si.Change_Order_Old__r.Number__c == changeOrderNumber ) ) ) ) ) { //for quantity co, calculate amounts only for old CO
                        currentAmountBilled = bli.Amount_Billed__c != null ? bli.Amount_Billed__c : 0.00;
                        amountBilled += currentAmountBilled;

                        currentAmountPaid = bli.cl_Amount_Paid2__c != null ? bli.cl_Amount_Paid2__c : 0.00;
                        amountPaid += currentAmountPaid;

                        currentAmountDue = bli.Amount_Due__c != null ? bli.Amount_Due__c : 0.00;
                        amountDue += currentAmountDue;

                    } else if(  ( si.Is_Amendmend_Deleted__c && si.Change_Order_Old__r.Number__c != changeOrderNumber ) ||
                               !( isQuantityCO && ( ( changeOrderNumber == null && si.Change_Order_Old__c == null ) || ( changeOrderNumber != null && si.Change_Order_Old__r.Number__c == changeOrderNumber ) ) ) ) { //for quantity co, don't show amounts for new CO
                        showAmounts = false;
                    }

                    if( detail ) {
                if( bli.Purchase_Order__c != null ){
                purchaseOrder +=  bli.Purchase_Order__r.Name + '<br/>';
            }else{
                purchaseOrder +=  '<br/>';
            }
                        amountsBilled += convertToCurrency(currentAmountBilled) + '<br/>';
                        amountsPaid += convertToCurrency(currentAmountPaid) + '<br/>';
                        amountsDue += convertToCurrency(currentAmountDue) + '<br/>';
                    }

                    if( !String.isBlank( bli.Pro_forma_Invoice__r.Name_without_Prefix__c ) && !String.isBlank( String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c) ) ) {
                        invoiceNumbers += bli.Pro_forma_Invoice__r.Name_without_Prefix__c + '<br/>';
                        invoiceDates += String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(5, 7) + '/' + String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(8, 10) + '/' + String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(0, 4) + '<br/>';
                    } else if( String.isBlank( bli.Pro_forma_Invoice__r.Name_without_Prefix__c ) && !String.isBlank( String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c) ) ) {
                        invoiceNumbers += '<br/>';
                        invoiceDates += String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(5, 7) + '/' + String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(8, 10) + '/' + String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c).substring(0, 4) + '<br/>';
                    } else if( !String.isBlank( bli.Pro_forma_Invoice__r.Name_without_Prefix__c ) && String.isBlank( String.valueOf(bli.Pro_forma_Invoice__r.Invoice_Date__c) ) ) {
                        invoiceNumbers += bli.Pro_forma_Invoice__r.Name_without_Prefix__c + '<br/>';
                        invoiceDates += '<br/>';
                    }

                    if( !String.isEmpty( parentInvoiceId ) && bli.Pro_forma_Invoice__c == parentInvoiceId && fontWeight == 'normal' ) {
                        fontWeight = 'bold';
                    }
                }
            }

            balanceToBill = ( isInvoicePosted
                              ? proposedAmount + proposedAmountCO - amountBilled
                              : ( isMilestone
                                  ? proposedAmount + proposedAmountCO
                                  : 0.00 ) ); //for milestone if invoice was not posted to not subtract balance to bill

            showAmountBilled = isInvoicePosted && showAmounts;
            showAmountPaid = isInvoicePosted && showAmounts;
            showAmountDue = isInvoicePosted && showAmounts;
            showBalanceToBill = isInvoicePosted || isMilestone; //for milestone show always

            invoiceNumbers = invoiceNumbers.removeEnd('<br/>');
            invoiceDates = invoiceDates.removeEnd('<br/>');
        purchaseOrder = purchaseOrder.removeEnd('<br/>');

            if( detail ) {
                amountsBilled = amountsBilled.removeEnd('<br/>');
                amountsPaid = amountsPaid.removeEnd('<br/>');
                amountsDue = amountsDue.removeEnd('<br/>');
            } else {
                amountsBilled = convertToCurrency(amountBilled);
                amountsPaid = convertToCurrency(amountPaid);
                amountsDue = convertToCurrency(amountDue);
            }

            if( String.isBlank(amountsBilled) ) {
                amountsBilled = '$0.00';
            }
            if( String.isBlank(amountsPaid) ) {
                amountsPaid = '$0.00';
            }
            if( String.isBlank(amountsDue) ) {
                amountsDue = '$0.00';
            }
        }

        public ASRRWrapperLine( Project_Profile__c profile, String parentInvoiceId, Billing_Line_Item__c bli, String type ) {
            if( type == TYPE_INSTPERC ) {
                showBalanceToBill = false;
                showProposedAmount = false;
                showProposedAmountCO = false;
                if( profile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT ) {
                    serviceItem = profile.Frequency__c + ' Installment Billing ' + String.valueOf( bli.Billing_Date_Step_Number__c ) + ' of ' + String.valueOf( profile.Number_Of_Intervals__c );
                }
                if( profile.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
                    serviceItem = 'Percentage Billing';
                }
            }
            if( type == TYPE_REIMB ) {
                showBalanceToBill = false;
                showProposedAmount = false;
                showProposedAmountCO = false;
                serviceItem = bli.Description__c;
                municipalAgency = bli.Related_Service_Item__r.Municipal_Agency_ID__c;
            }

            purchaseOrder = bli.Purchase_Order__c != null ? bli.Purchase_Order__r.Name : '';

            if( bli.Pro_forma_Invoice__r.Sales_Invoice__r.c2g__Transaction__c != null || !String.isEmpty( parentInvoiceId ) || Test.isRunningTest() ) {
                isInvoicePosted = true;
                invoiceNumbers  = bli.Pro_forma_Invoice__r.Name_without_Prefix__c;
                invoiceDates    = String.valueOf( bli.Invoice_Date__c );

                amountBilled += bli.Amount_Billed__c != null ? bli.Amount_Billed__c : 0.00;
                amountPaid += bli.cl_Amount_Paid2__c != null ? bli.cl_Amount_Paid2__c : 0.00;
                amountDue += bli.Amount_Due__c != null ? bli.Amount_Due__c : 0.00;
                //balanceToBill = si.Balance_To_Bill__c;
        
                if( !String.isEmpty( parentInvoiceId ) && bli.Pro_forma_Invoice__c == parentInvoiceId ) {
                    fontWeight = 'bold';
                }
            }

            showAmountBilled = isInvoicePosted;
            showAmountPaid = isInvoicePosted;
            showAmountDue = isInvoicePosted;
            showBalanceToBill = isInvoicePosted;

            amountsBilled = convertToCurrency(amountBilled);
            amountsPaid = convertToCurrency(amountPaid);
            amountsDue = convertToCurrency(amountDue);
        }

        public String convertToCurrency( Decimal amount ) {
            Decimal dec = amount.setScale(2);
            String result = '';
            if( amount != null ) {
                String str = String.valueOf(dec);
                String separator = '.';
                if( str.contains(',') ) {
                    separator = ',';
                }
                if( str.contains(separator) ) {
                    str = str.substring( 0, str.indexOf(separator) );
                }
                if( dec - Decimal.valueOf(str) == 0 ) {
                    result = String.valueOf(dec.format()) + separator + '00';
                } else if( ( dec - Decimal.valueOf(str) ).abs() * 10 - ( ( dec - Decimal.valueOf(str) ).abs() * 10 ).intValue() == 0 ) {
                    result = String.valueOf(dec.format()) + '0';
                } else {
                    result = String.valueOf(dec.format());
                }
                if( str.contains('-') ) {
                    result = result.replace('-', '-$');
                } else {
                    result = '$' + result;
                }
            }
            return result;
        }
    }

    public String getAddress2() {
        String address = '';
        if( parent.Building_AKA__c != null ) {
            address = ( !String.isEmpty(parent.Building_AKA__r.Building__r.City__c) ? parent.Building_AKA__r.Building__r.City__c : '' ) +
                      ( !String.isEmpty(parent.Building_AKA__r.Building__r.City__c) && ( !String.isEmpty(parent.Building_AKA__r.Building__r.State__c) || !String.isEmpty(parent.Building_AKA__r.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(parent.Building_AKA__r.Building__r.State__c) ? parent.Building_AKA__r.Building__r.State__c : '' ) +
                      ( !String.isEmpty(parent.Building_AKA__r.Building__r.State__c) && !String.isEmpty(parent.Building_AKA__r.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(parent.Building_AKA__r.Building__r.PostalCode__c) ? parent.Building_AKA__r.Building__r.PostalCode__c : '' );
        } else {
            address = ( !String.isEmpty(parent.Building__r.City__c) ? parent.Building__r.City__c : '' ) +
                      ( !String.isEmpty(parent.Building__r.City__c) && ( !String.isEmpty(parent.Building__r.State__c) || !String.isEmpty(parent.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(parent.Building__r.State__c) ? parent.Building__r.State__c : '' ) +
                      ( !String.isEmpty(parent.Building__r.State__c) && !String.isEmpty(parent.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(parent.Building__r.PostalCode__c) ? parent.Building__r.PostalCode__c : '' );
        }
        return address;
    }
}