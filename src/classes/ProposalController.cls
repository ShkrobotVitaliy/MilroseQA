public with sharing class ProposalController {
    public final static String ORIGINAL_SERVICES = 'Original Services';
    public final static String ALTERNATIVE_SERVICES = 'Alternative Services';

    public Boolean isValid { get; private set; }
    public Boolean isPreview { get { if( isPreview == null ) isPreview = true; return isPreview; } private set; }
    public Boolean isPreviewTnc { get { if( isPreviewTnc == null ) isPreviewTnc = false; return isPreviewTnc; } private set; }
    public String previewAccountId { get; private set; }
    public Proposal__c proposal { get { if( proposal == null ) proposal = new Proposal__c(); return proposal; } set; }
    public String officeAddress {
        get {
            String address = '';
            try {
                FulfillmentOfficeAddresses__c ffo = FulfillmentOfficeAddresses__c.getValues( proposal.Fulfillment_Office__c );
                address = String.format( '{0} tel: {1} fax: {2} {3}', new String[] { ffo.Address__c != null ? ffo.Address__c : '',
                                                                                     ffo.Phone__c != null ? ffo.Phone__c : '',
                                                                                     ffo.Fax__c != null ? ffo.Fax__c : '',
                                                                                     ffo.URL__c != null ? ffo.URL__c : '' } );
            } catch (Exception ex) {
            }
            return address;
        }
    }

    public String address1 { get { if( proposal != null ) { return proposal.Address_Building_AKA__c; } else { return ''; } } set; }
    public String address2 { get { if( proposal != null ) { return getAddress2(); } else { return ''; } } set; }

    public ProposalTable originalContent { get; private set; }
    public ProposalTable alternativeContent { get; private set; }

    public String partnerImage { //MRS 7327
		get { 
			if(String.isBlank(proposal.Partner__c)) return 'Dominic_Maurillo.png';
			return ( proposal != null && !String.isEmpty( proposal.Partner__r.Signature__c ) && !hidePrices ) ? proposal.Partner__r.Signature__c : 'Empty.png';
		}
	}
    public Boolean hidePrices { get { if( hidePrices == null ) hidePrices = false; return hidePrices; } private set; }
    public Boolean showFloors { get { if( showFloors == null ) showFloors = false; return showFloors; } private set; }

    public Map<Decimal, String> phaseNumberToPhaseName { get { if( phaseNumberToPhaseName == null ) phaseNumberToPhaseName = new Map<Decimal, String>(); return phaseNumberToPhaseName; } private set; }
    public Map<Decimal, Decimal> phaseNumberToPhaseTotal { get { if( phaseNumberToPhaseTotal == null ) phaseNumberToPhaseTotal = new Map<Decimal, Decimal>(); return phaseNumberToPhaseTotal; } private set; }
    public List<Decimal> phaseNumbers { get { if( phaseNumbers == null ) phaseNumbers = new List<Decimal>(); return phaseNumbers; } private set; }
    Set<Decimal> phaseNumbersUnique = new Set<Decimal>();
    public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
    public Decimal discount { get { if( discount == null ) discount = 0.00; return discount; } private set; }
    public Decimal salesTax { get { return proposal.Sales_Tax__c != null ? proposal.Sales_Tax__c : 0.00; } private set; }
    public Decimal reimbursable { get { return ( proposal.Reimbursable_Items_Basis__c ? total * proposal.Reimbursable_Percentage__c / 100 : 0 ); } }
    public Decimal servicesTotal { get { return ( total + discount ); } }
    public Decimal servicesTotalWithTax { get { return servicesTotal + salesTax; } }
    public Decimal grandTotal { get { return servicesTotalWithTax + reimbursable + additionalReimbursableTotal; } }
    public Decimal retainer { //MRS 7419
		get {
			return ( ( proposal.Total_Service_Amount__c == null ? 0 : proposal.Total_Service_Amount__c + discount ) * ( proposal.Retainer_Amount__c == null ? 0 : proposal.Retainer_Amount__c ) / 100).setScale(2); 
		}
		set;
	}

    public String firstTimeSendToClientDate {
        get {
            if( String.isEmpty( this.firstTimeSendToClientDate ) ) {
                this.firstTimeSendToClientDate = '';
                if( !String.isBlank( proposal.Id ) ) {
                    List<Change_History_Proposal__c> changeHistories = getChangeHistories( proposal.Id );
                    Boolean clientRejectProposal = false;
                    Date firstTimeSendToClientDateValue = null;
                    if( !changeHistories.isEmpty() && changeHistories[changeHistories.size() - 1].Change_Order__c == null ) {
                        for( Change_History_Proposal__c proposalChangeHistoryItem : changeHistories ){
                            if( proposalChangeHistoryItem.Status__c == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT ) {
                                firstTimeSendToClientDateValue = proposalChangeHistoryItem.Date__c;
                            } else if( proposalChangeHistoryItem.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED ) {
                                if( firstTimeSendToClientDateValue != null ) {
                                    clientRejectProposal = true;
                                    break;
                                }
                            }
                        }
                    }
                    if( clientRejectProposal ) {
                        this.firstTimeSendToClientDate = String.valueOf( firstTimeSendToClientDateValue.month() ) + '/' + String.valueOf( firstTimeSendToClientDateValue.day() ) + '/' + String.valueOf( firstTimeSendToClientDateValue.year() );
                        this.firstTimeSendToClientDate += '(Revised - ' + String.valueOf( Date.today().month() ) + '/' + String.valueOf( Date.today().day() ) + '/' + String.valueOf( Date.today().year() ) + ')';
                    } else {
                        this.firstTimeSendToClientDate = String.valueOf( Date.today().month() ) + '/' + String.valueOf( Date.today().day() ) + '/' + String.valueOf( Date.today().year() );
                    }
                }
            }
            return this.firstTimeSendToClientDate;
        }
        set;
    }

    public ProposalController() {
        isValid = true;
        String parentId = ApexPages.currentPage().getParameters().get('p');
        String type = ApexPages.currentPage().getParameters().get('type');
        if( !String.isEmpty( type ) ) {
            isPreview = false;
            if( type == 'previewtnc' ) {
                isPreviewTnc = true;
                previewAccountId = ApexPages.currentPage().getParameters().get('previewacc');
            }
        }

        if( !isPreviewTnc ) {
        if( parentId == null || !(parentId instanceOf Id) ) {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }

        List<Proposal__c> proposals = getProposal( parentId );
        if( proposals.isEmpty() ) {
            isValid = false;
            MilroseDevHelper.addMessage( 'No Proposal was found.' );
            return;
        } else {
            proposal = proposals[0];
        }

        this.hidePrices = !String.isEmpty(ApexPages.currentPage().getParameters().get('dp')) && ApexPages.currentPage().getParameters().get('dp').equals('true');
        this.showFloors = proposal.Is_Floors_To_Services__c;

        List<Service_Item__c> services = getServices( proposal.Id );
        originalContent = new ProposalTable( proposal, services, ORIGINAL_SERVICES );
        alternativeContent = new ProposalTable( proposal, services, ALTERNATIVE_SERVICES );
        getReimbursableListAndTotal();
        calculateTotals( originalContent );

        phaseNumbers.addAll( phaseNumbersUnique );
        phaseNumbers.sort();
        } else {
            originalContent = new ProposalTable( proposal, null, null );
        }
        populateTnc();
    }

    public List<Additional_Reimbursable__c> reimbursableList {
        get{ if( reimbursableList == null ) reimbursableList =  new List<Additional_Reimbursable__c>(); return reimbursableList; }
        set;
    }
    private Decimal additionalReimbursableTotal {
        get{ if( additionalReimbursableTotal == null ) additionalReimbursableTotal = 0.00; return additionalReimbursableTotal; }
        set;
    }
    private void getReimbursableListAndTotal(){
        if( proposal.Reimbursable_Items_Basis__c ){
            for( Additional_Reimbursable__c reimbursable: AdditionalReimbursableServices.getRecordsByProposalId(proposal.Id).values() ){
                if( String.IsBlank(reimbursable.Change_Order__c) ) reimbursableList.add(reimbursable);
            }
            for( Additional_Reimbursable__c item: reimbursableList ){
                additionalReimbursableTotal += item.Amount__c;
            }
        }
    }

    private void calculateTotals( ProposalTable content ) {
        phaseNumbersUnique.addAll( content.phaseNumbersUnique );
        total += content.total;
        discount += content.discount;
        for( Decimal phaseNumber : content.phaseNumbersUnique ) {
            phaseNumberToPhaseName.put( phaseNumber, content.phaseNumberToPhaseName.get( phaseNumber ) );
            if( phaseNumberToPhaseTotal.get( phaseNumber ) == null ) {
                phaseNumberToPhaseTotal.put( phaseNumber, 0.00 );
            }
            phaseNumberToPhaseTotal.put( phaseNumber, phaseNumberToPhaseTotal.get( phaseNumber ) + content.phaseNumberToPhaseTotal.get( phaseNumber ) );
        }
    }

    public class ProposalTable {
        public List<ProposalSection> sections { get { if( sections == null ) sections = new List<ProposalSection>(); return sections; } private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal discount { get { if( discount == null ) discount = 0.00; return discount; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public Decimal reimbursable { get { if( reimbursable == null ) reimbursable = 0.00; return reimbursable; } private set; }
        public Decimal grandTotal { get { if( grandTotal == null ) grandTotal = 0.00; return grandTotal; } private set; }
        public Map<Decimal, String> phaseNumberToPhaseName { get { if( phaseNumberToPhaseName == null ) phaseNumberToPhaseName = new Map<Decimal, String>(); return phaseNumberToPhaseName; } private set; }
        public Map<Decimal, Decimal> phaseNumberToPhaseTotal { get { if( phaseNumberToPhaseTotal == null ) phaseNumberToPhaseTotal = new Map<Decimal, Decimal>(); return phaseNumberToPhaseTotal; } private set; }
        public Set<Decimal> phaseNumbersUnique { get { if( phaseNumbersUnique == null ) phaseNumbersUnique = new Set<Decimal>(); return phaseNumbersUnique; } private set; }
        public List<Decimal> phaseNumbers { get { if( phaseNumbers == null ) phaseNumbers = new List<Decimal>(); return phaseNumbers; } private set; }

        public ProposalTable( Proposal__c proposal, List<Service_Item__c> services, String tableContent ) {
            if( proposal.Id != null ) {
            Map<Decimal, Phase__c> phaseNumberToPhase = new Map<Decimal, Phase__c>();
            Map<Decimal, List<Service_Item__c>> phaseNumberToServiceItems = new Map<Decimal, List<Service_Item__c>>();
            for( Service_Item__c si : services ) {
                if( ( tableContent == ORIGINAL_SERVICES && !si.Is_Alternative__c ) ||
                      tableContent == ALTERNATIVE_SERVICES && si.Is_Alternative__c ) {
                    Decimal phaseNumber = si.Phase__r.Number__c;
                    String phaseName = si.Phase__r.Name__c;
                    Id phaseId = si.Phase__c;
                    phaseNumbersUnique.add( phaseNumber );
                    phaseNumberToPhase.put( phaseNumber, new Phase__c( Id = phaseId,
                                                                       Number__c = phaseNumber,
                                                                       Name__c = phaseName ) );
                    phaseNumberToPhaseName.put( phaseNumber, phaseName );
                    phaseNumberToPhaseTotal.put( phaseNumber, 0.00 );
                    if( !phaseNumberToServiceItems.containsKey( phaseNumber ) ) {
                        phaseNumberToServiceItems.put( phaseNumber, new List<Service_Item__c>() );
                    }
                    phaseNumberToServiceItems.get( phaseNumber ).add( si );
                }
            }
            phaseNumbers.addAll( phaseNumbersUnique );
            phaseNumbers.sort();

            for( Decimal phaseNumber : phaseNumbers ) {
                ProposalSection section = new ProposalSection( phaseNumberToPhase.get( phaseNumber ),
                                                               phaseNumberToServiceItems.get( phaseNumber ) );
                if( !section.lines.isEmpty() ) {
                    sections.add( section );
                    total += section.total;
                    discount += section.discountedTotal - section.total;
                    salesTax += section.salesTax;
                }
                phaseNumberToPhaseTotal.put( phaseNumber, phaseNumberToPhaseTotal.get( phaseNumber ) + section.total );
            }
            reimbursable = ( proposal.Reimbursable_Items_Basis__c ? total * proposal.Reimbursable_Percentage__c / 100 : 0 );
            grandTotal = ( total + discount ) + salesTax + reimbursable;
        }
    }
    }

    public class ProposalSection {
        public List<ProposalLine> lines { get { if( lines == null ) lines = new List<ProposalLine>(); return lines; } private set; }
        public String name { get; private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal discountedTotal { get { if( discountedTotal == null ) discountedTotal = 0.00; return discountedTotal; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public Boolean hasLargeGroup { get { for( ProposalLine line : lines ) { if( line.hasLargeGroup ) return true; } return false; } }

        public ProposalSection( Phase__c phase, List<Service_Item__c> serviceItems ) {
            name = phase.Name__c;
            Map<Integer, List<Service_Item__c>> positionToServiceItems = new Map<Integer, List<Service_Item__c>>();
            Integer currentPosition = 1;
            Integer serviceInPhaseIndex = 0;
            String currentGroupKey;
            List<Service_Item__c> currentGroup = new List<Service_Item__c>();

            //shows groups only if they are consequent
            if( !serviceItems.isEmpty() ) {
                for( Integer serviceIndex = 0; serviceIndex < serviceItems.size(); serviceIndex++ ) {
                    Service_Item__c si = serviceItems[serviceIndex];
                    if( si.Phase__c == phase.Id ) {
                        String groupKey = si.Service_Group_Key__c;
                        if( serviceInPhaseIndex == 0 ) { //add first service
                            currentGroupKey = groupKey;
                            currentGroup.add( si );
                        } else if( groupKey == null || groupKey != currentGroupKey ) { //add middle services if group condition changes or the service is not in group
                            currentGroupKey = groupKey;
                            if( !positionToServiceItems.containsKey( currentPosition ) ) {
                                positionToServiceItems.put( currentPosition, new List<Service_Item__c>() );
                            }
                            positionToServiceItems.get( currentPosition ).addAll( currentGroup );
                            currentGroup = new List<Service_Item__c>{ si };
                            currentPosition++;
                        } else { //add middle services if group condition does not change
                            currentGroup.add( si );
                        }
                        if( serviceIndex == serviceItems.size() - 1 && !currentGroup.isEmpty() ) { //check if service is last and if yes, return remainders
                            if( !positionToServiceItems.containsKey( currentPosition ) ) {
                                positionToServiceItems.put( currentPosition, new List<Service_Item__c>() );
                            }
                            positionToServiceItems.get( currentPosition ).addAll( currentGroup );
                        }
                        serviceInPhaseIndex++;
                    }
                }
            }

            List<Integer> positions = new List<Integer>( positionToServiceItems.keySet() );
            positions.sort();
            for( Integer position : positions ) {
                ProposalLine line = new ProposalLine( positionToServiceItems.get( position ) );
                lines.add( line );
                total += line.total;
                discountedTotal += line.discountedTotal;
                salesTax += line.salesTax;
            }

            //shows groups at the first place of their appearance
            /*name = phase.Name__c;
            List<Service_Item__c> servicesForCurrentPhase = new List<Service_Item__c>();
            Map<String, List<Service_Item__c>> serviceGroupToServiceItems = new Map<String, List<Service_Item__c>>();
            Map<String, Boolean> serviceGroupToIsGroupUsed = new Map<String, Boolean>();
            for( Service_Item__c si : serviceItems ) {
                if( si.Phase__c == phase.Id ) {
                    String groupKey = si.Service_Group_Key__c;
                    servicesForCurrentPhase.add( si );
                    if( !serviceGroupToServiceItems.containsKey( groupKey ) ) {
                        serviceGroupToServiceItems.put( groupKey, new List<Service_Item__c>() );
                        serviceGroupToIsGroupUsed.put( groupKey, false );
                    }
                    serviceGroupToServiceItems.get( groupKey ).add( si );
                }
            }
            serviceGroupToServiceItems.remove( null );
            serviceGroupToIsGroupUsed.remove( null );
            for( Service_Item__c si : servicesForCurrentPhase ) {
                Boolean isGroupUsed = serviceGroupToIsGroupUsed.get( si.Service_Group_Key__c );
                ProposalLine line;
                if( isGroupUsed == null ) { //single service
                    line = new ProposalLine( new List<Service_Item__c>{ si } );
                } else if( !isGroupUsed ) { //grouped service, not added yet
                    line = new ProposalLine( serviceGroupToServiceItems.get( si.Service_Group_Key__c ) );
                    serviceGroupToIsGroupUsed.put( si.Service_Group_Key__c, true );
                }
                if( line != null ) {
                    lines.add( line );
                    total += line.total;
                    discountedTotal += line.discountedTotal;
                    salesTax += line.salesTax;
                }
            }*/
        }
    }

    public class ProposalLine {
        public Boolean isGroup { get { if( isGroup == null ) isGroup = false; return isGroup; } private set; }
        public Integer groupSize { get { if( groupSize == null ) groupSize = 0; return groupSize; } private set; }
        public String fullName { get; private set; }
        public String name { get; private set; }
        public List<String> names { get { if( names == null ) names = new List<String>(); return names; } private set; }
        public String floor { get; private set; }
        public List<String> floors { get { if( floors == null ) floors = new List<String>(); return floors; } private set; }
        public String municipalAgency { get; private set; }
        public List<String> municipalAgencies { get { if( municipalAgencies == null ) municipalAgencies = new List<String>(); return municipalAgencies; } private set; }
        public String description { get { if( description == null ) description = ''; return description; } private set; }
        public Decimal quantity { get; private set; }
        public Decimal unitPrice { get; private set; }
        public Decimal discountedTotal { get; private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public List<Integer> serviceGroupLineIndexes {
            get {
                List<Integer> indexes = new List<Integer>();
                for( Integer index = 0; index < names.size(); index ++ ) {
                    indexes.add( index );
                }
                return indexes;
            } private set;
        }
        public Boolean hasLargeGroup { get { return names.size() >= 35; } }

        public ProposalLine( List<Service_Item__c> serviceItems ) {
            Boolean isQuantityCO = serviceItems[0].Quantity_Old__c != null && serviceItems[0].Quantity_Old__c != 0;
            Decimal discountedUnitPrice;

            fullName = serviceItems[0].Service_Name_Full__c;
            description = serviceItems[0].Description__c;
            if( String.isEmpty( serviceItems[0].Service_Group_Key__c ) || serviceItems.size() == 1 ) {
                name = serviceItems[0].Name_Short__c != null ? serviceItems[0].Name_Short__c : '';
                //floor = serviceItems[0].Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( serviceItems[0].Floor__c.split(', '), ',' ).split(','), ',&nbsp;', 2 ), ', ' ) : '';
				floor = serviceItems[0].Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( serviceItems[0].Floor__c.split(', '), ',' ).split(','), ', ', 2 ), ', ' ) : ''; // MRS 7215
                municipalAgency = serviceItems[0].Municipal_Agency_ID__c != null ? serviceItems[0].Municipal_Agency_ID__c: '';
                if( !isQuantityCO ) {
                    quantity = serviceItems[0].Quantity__c;
                } else {
                    quantity = serviceItems[0].Quantity_Old__c;
                }
                unitPrice = serviceItems[0].Unit_Price__c;
                discountedUnitPrice = serviceItems[0].Discounted_Unit_Price__c;
            } else {
                isGroup = true;
                groupSize = serviceItems.size();
                for( Service_Item__c si : serviceItems ) {
                    names.add( si.Name_Short__c != null ? si.Name_Short__c : '' );
                    floors.add( si.Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( si.Floor__c.split(', '), ',' ).split(','), ',&nbsp;', 2 ), ', ' ) : '' );
                    municipalAgencies.add( si.Municipal_Agency_ID__c != null ? si.Municipal_Agency_ID__c : '' );
                }
                quantity = serviceItems.size();
                if( !isQuantityCO ) {
                    unitPrice = serviceItems[0].Quantity__c * serviceItems[0].Unit_Price__c;
                    discountedUnitPrice = serviceItems[0].Quantity__c * serviceItems[0].Discounted_Unit_Price__c;
                } else {
                    unitPrice = serviceItems[0].Quantity_Old__c * serviceItems[0].Unit_Price__c;
                    discountedUnitPrice = serviceItems[0].Quantity_Old__c * serviceItems[0].Discounted_Unit_Price__c;
                }
            }

            total = quantity * unitPrice;
            discountedTotal = quantity * discountedUnitPrice;
            salesTax = ( ( discountedTotal * ( ( serviceItems[0].Tax_Percent_1__c != null
                                                 ? serviceItems[0].Tax_Percent_1__c
                                                 : 0.00 ) +
                                               ( serviceItems[0].Tax_Percent_2__c != null
                                                 ? serviceItems[0].Tax_Percent_2__c
                                                 : 0.00 ) ) )
                                            / 100 ).setScale(2);
        }
    }

    private List<Proposal__c> getProposal( Id parentId ) {
        return [ SELECT Id, Name, Version_Text__c, Client_Project__c, Apply_Discount__c, Billing_Company_Contact__r.Name, Partner__c, //MRS 7327
                        Billing_Company_Contact__r.Salutation, Billing_Company_Contact__r.Title, Reimbursable_Items_Basis__c,
                        Billing_Company_Contact__r.MailingStreet, Billing_Company_Contact__r.MailingCity, Billing_Company_Contact__r.MailingState,
                        Billing_Company_Contact__r.MailingPostalCode, Billing_Company_Contact__r.Suffix__c,
                        Billing_Company_Name__r.Name, Billing_Company_Name__r.BillingStreet, Billing_Company_Name__r.BillingCity,
                        Billing_Company_Name__r.BillingState, Billing_Company_Name__r.BillingPostalCode,
                        Address_Building_AKA__c, Project_Name__c, Floor_s__c, Is_Floors_To_Services__c,
                        Total_Service_Amount__c, Sales_Tax__c, Reimbursable_Percentage__c, Cost__c, Fulfillment_Office__c,
                        Primary_Company_Contact__r.Title, Primary_Company_Contact__r.Name,
                        Primary_Company_Contact__r.Suffix__c, No_Retainer__c, Retainer_Amount__c,
                        Primary_Company_Name__r.Name, Partner__r.Name, Partner__r.Title, Partner__r.Signature__c,
                        Municipal_Authority_Fees__c, Projected_DOB_Fee__c, General_Proposal_Notes__c, Discount_Percentage__c, Region__c, Address__r.Region__c,
                        Delivery_Method__c, Accounting_Contact_Company__r.Name, Accounting_Contact__r.MailingStreet, Accounting_Contact__r.MailingCity,
                        Accounting_Contact__r.MailingState, Accounting_Contact__r.MailingPostalCode, Accounting_Contact__r.Name, Accounting_Contact__r.Salutation,
                        Accounting_Contact__r.Email,
                        Building_AKA__c, Building_AKA__r.Building__r.City__c, Building_AKA__r.Building__r.State__c, Building_AKA__r.Building__r.PostalCode__c,
                        Address__r.City__c, Address__r.State__c, Address__r.PostalCode__c, UseDocusign__c,
                        Billing_Company_Name__c, Billing_Company_Name__r.TncStartDate__c, Billing_Company_Name__r.TncEndDate__c, Municipality__c // MRS 7278
                 FROM Proposal__c
                 WHERE Id = : parentId ];
    }

    private List<Service_Item__c> getServices( Id proposalId ) {
        List<Service_Item__c> services = new List<Service_Item__c>();
        if( !String.isBlank( proposalId ) ) {
            services = [ SELECT Name_Short__c, Service_Name_Full__c, Municipal_Agency_ID__c, Description__c,
                                Phase__c, Phase__r.Name__c, Phase__r.Number__c, Quantity__c, Discounted_Unit_Price__c,
                                Total_Service_Price__c, Service_Group_Key__c, Unit_Price__c, Is_Alternative__c,
                                Quantity_Old__c, Tax_Percent_1__c, Tax_Percent_2__c, Floor__c
                         FROM Service_Item__c
                         WHERE Proposal__c = : proposalId /*MRS 7020*/
                         ORDER BY Row_Position__c ];
        }
        return services;
    }

    private List<Change_History_Proposal__c> getChangeHistories( Id proposalId ) {
        List<Change_History_Proposal__c> changeHistories = new List<Change_History_Proposal__c>();
        if( !String.isBlank( proposalId ) ) {
            changeHistories = [ SELECT Id, Type__c, Status__c, Date__c, Change_Order__c, Change_Order_Number__c
                                FROM Change_History_Proposal__c
                                WHERE Proposal__c = : proposalId AND
                                      ( Status__c = : ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT OR
                                        Status__c = : ProposalServices.PROPOSAL_STATUS_REJECTED )
                                ORDER BY Date__c ];
        }
        return changeHistories;
    }

    private String getAddress2() {
        String address = '';
        if( proposal.Building_AKA__c != null ) {
            address = ( !String.isEmpty(proposal.Building_AKA__r.Building__r.City__c) ? proposal.Building_AKA__r.Building__r.City__c : '' ) +
                      ( !String.isEmpty(proposal.Building_AKA__r.Building__r.City__c) && ( !String.isEmpty(proposal.Building_AKA__r.Building__r.State__c) || !String.isEmpty(proposal.Building_AKA__r.Building__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(proposal.Building_AKA__r.Building__r.State__c) ? proposal.Building_AKA__r.Building__r.State__c : '' ) +
                      ( !String.isEmpty(proposal.Building_AKA__r.Building__r.State__c) && !String.isEmpty(proposal.Building_AKA__r.Building__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(proposal.Building_AKA__r.Building__r.PostalCode__c) ? proposal.Building_AKA__r.Building__r.PostalCode__c : '' );
        } else {
            address = ( !String.isEmpty(proposal.Address__r.City__c) ? proposal.Address__r.City__c : '' ) +
                      ( !String.isEmpty(proposal.Address__r.City__c) && ( !String.isEmpty(proposal.Address__r.State__c) || !String.isEmpty(proposal.Address__r.PostalCode__c) ) ? ', ' : '') +
                      ( !String.isEmpty(proposal.Address__r.State__c) ? proposal.Address__r.State__c : '' ) +
                      ( !String.isEmpty(proposal.Address__r.State__c) && !String.isEmpty(proposal.Address__r.PostalCode__c) ? ' ' : '' ) +
                      ( !String.isEmpty(proposal.Address__r.PostalCode__c) ? proposal.Address__r.PostalCode__c : '' );
        }
        return address;
    }

    public TermsAndConditionsServices.TncWrapper contractClauses { get { if( contractClauses == null ) contractClauses = new TermsAndConditionsServices.TncWrapper( TermsAndConditionsServices.initTncRecord( proposal.Billing_Company_Name__c, CustomTncEditor.CONTRACT_CLAUSES, 1, false ) ); return contractClauses; } set; }
    public List<TermsAndConditionsServices.TncWrapper> termsAndConditions { get { if( termsAndConditions == null ) termsAndConditions = new List<TermsAndConditionsServices.TncWrapper>(); return termsAndConditions; } set; }

    private void populateTnc() {
        Date todayDate = Date.today();
        if( ( proposal.Billing_Company_Name__r.TncStartDate__c != null && proposal.Billing_Company_Name__r.TncStartDate__c <= todayDate &&
              proposal.Billing_Company_Name__r.TncEndDate__c != null && proposal.Billing_Company_Name__r.TncEndDate__c >= todayDate ) ||
            ( isPreviewTnc ) ) {
            List<Terms_And_Conditions__c> tncsFromDb = TermsAndConditionsServices.getTermsAndConditionsByAccountId( isPreviewTnc ? previewAccountId : proposal.Billing_Company_Name__c );
            if( !tncsFromDb.isEmpty() ) {
                Map<Integer, Terms_And_Conditions__c> pageNumberToTncRecord = new Map<Integer, Terms_And_Conditions__c>();
                for( Terms_And_Conditions__c tncItem : tncsFromDb ) {
                    if( tncItem.Type__c == CustomTncEditor.CONTRACT_CLAUSES && contractClauses.record.Id == null ) {
                        contractClauses = new TermsAndConditionsServices.TncWrapper( tncItem );
                    } else if( tncItem.Type__c == CustomTncEditor.TERMS_AND_CONDITIONS && tncItem.Page_Number__c != null && pageNumberToTncRecord.get( Integer.valueOf( tncItem.Page_Number__c ) ) == null ) {
                        pageNumberToTncRecord.put( Integer.valueOf( tncItem.Page_Number__c ), tncItem );
                    }
                }
                List<Integer> pageNumbers = new List<Integer>( pageNumberToTncRecord.keySet() );
                pageNumbers.sort();
                for( Integer pageNumber : pageNumbers ) {
                    termsAndConditions.add( new TermsAndConditionsServices.TncWrapper( pageNumberToTncRecord.get( pageNumber ) ) );
                }
                if( !termsAndConditions.isEmpty() ) {
                    termsAndConditions[ 0 ].isFirst = true;
                    termsAndConditions[ termsAndConditions.size() - 1 ].isLast = true;
                }
            }
        } else {
            contractClauses = TermsAndConditionsServices.populateStandardContractClauses( proposal );
            termsAndConditions = TermsAndConditionsServices.populateStandardTermsAndConditions( proposal );
        }
    }

}