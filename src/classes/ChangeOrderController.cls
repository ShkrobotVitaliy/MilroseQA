public with sharing class ChangeOrderController {
    public final static String ORIGINAL_SERVICES = 'Original Services';
    public final static String CHANGE_ORDER_SERVICES = 'Change Order Services';

    public String parentId { get; private set; }
    public Boolean isValid { get; private set; }
    public Boolean isLightCo { get; private set; }
    public Id lightCoId { get; private set; }
    public String lightCoNumber { get { if( lightCoNumber == null ) lightCoNumber = ''; return lightCoNumber; } private set; }
    public Boolean isPreview { get { if( isPreview == null ) isPreview  = true; return isPreview ; } private set; }
    private String previewChangeOrderId;
    public Date initialCOSendToClientDate { get; private set; }
    public Proposal__c proposal { get; private set; }
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

    public ChangeOrderWrapper originalContent { get; private set; }
    public ChangeOrderWrapper changeOrderContent { get; private set; }

    public String partnerImage { //MRS 7327
		get {
			if(String.isBlank(proposal.Partner__c)) return 'Dominic_Maurillo.png';
			return ( proposal != null && !String.isEmpty( proposal.Partner__r.Signature__c ) ) ? proposal.Partner__r.Signature__c : 'Empty.png';
		}
	}

    public Map<Decimal, String> phaseNumberToPhaseName { get { if( phaseNumberToPhaseName == null ) phaseNumberToPhaseName = new Map<Decimal, String>(); return phaseNumberToPhaseName; } private set; }
    public Map<Decimal, Decimal> phaseNumberToPhaseTotal { get { if( phaseNumberToPhaseTotal == null ) phaseNumberToPhaseTotal = new Map<Decimal, Decimal>(); return phaseNumberToPhaseTotal; } private set; }
    public List<Decimal> phaseNumbers { get { if( phaseNumbers == null ) phaseNumbers = new List<Decimal>(); return phaseNumbers; } private set; }
    Set<Decimal> phaseNumbersUnique = new Set<Decimal>();
    public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
    public Decimal discount { get { if( discount == null ) discount = 0.00; return discount; } private set; }
    public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
    public List<Additional_Reimbursable__c> reimbursableList  { get { if( reimbursableList == null ) reimbursableList = new List<Additional_Reimbursable__c>(); return reimbursableList; }  private set; }
    public Decimal reimbursablePending { get { if( reimbursablePending == null ) reimbursablePending = 0.00; return reimbursablePending; } private set; }
    public Decimal reimbursableApproved { get { if( reimbursableApproved == null ) reimbursableApproved = 0.00; return reimbursableApproved; } private set; }
    public Decimal baseReimbursable { get { return reimbursablePending + reimbursableApproved; } private set; }
    public Decimal reimbursable { get { return baseReimbursable/* + additionalReimbursable*/; } private set; }
    public Decimal additionalReimbursable { get { if( additionalReimbursable == null ) additionalReimbursable = 0.00; return additionalReimbursable; } private set; }
    public Boolean showReimbursablePercentage { get { if( showReimbursablePercentage == null ) showReimbursablePercentage = false; return showReimbursablePercentage; } private set; }
    public Decimal reimbursablePercentage { get; private set; }
    public Decimal grandTotal { get { return ( total + discount ) + salesTax + reimbursable + additionalReimbursable; } }

    public ChangeOrderController( String parentId ) {
        this.parentId = parentId;
        this.isPreview = false;
        this.isLightCo = false;
        initMainData();
    }

    public ChangeOrderController() {
        this.parentId = ApexPages.currentPage().getParameters().get('p');
        if( !String.isEmpty( ApexPages.currentPage().getParameters().get('type') ) ) {
            this.isPreview = false;
        }
        initMainData();
        initLightCoData();
        initCanceledRejectedChangeOrdersData();
    }

    private void initMainData() {
        this.isValid = true;
        if( parentId == null || !(parentId instanceOf Id) ) {
            MilroseDevHelper.addMessage('Invalid parameters have been passed.');
            isValid = false;
            return;
        }
        if( isPreview ) {
            previewChangeOrderId = ApexPages.currentPage().getParameters().get('co');
            if( previewChangeOrderId != null && !(previewChangeOrderId instanceOf Id) ) {
                MilroseDevHelper.addMessage('Invalid parameters have been passed.');
                isValid = false;
                return;
            }
        }
        List<Proposal__c> proposals = getProposal( parentId );
        if( proposals.isEmpty() ) {
            isValid = false;
            MilroseDevHelper.addMessage( 'No Proposal was found.' );
            return;
        } else {
            proposal = proposals[0];
        }
        populateReimbursableData( proposal.Id );
        List<Service_Item__c> services = getServices( proposal.Id );
        originalContent = new ChangeOrderWrapper( proposal, services, ORIGINAL_SERVICES, isPreview, previewChangeOrderId, originalReimbursableList, changeOrderMap);
        calculateTotals( originalContent );

        ChangeOrderWrapper changeOrderServicesWrapper = new ChangeOrderWrapper( proposal, services, CHANGE_ORDER_SERVICES, isPreview, previewChangeOrderId, originalReimbursableList, changeOrderMap );
        if( !changeOrderServicesWrapper.tables.isEmpty() ) {
            changeOrderContent = changeOrderServicesWrapper;
        }
        calculateTotals( changeOrderServicesWrapper );
        initialCOSendToClientDate = changeOrderServicesWrapper.initialCOSendToClientDate;
        phaseNumbers.addAll( phaseNumbersUnique );
        phaseNumbers.sort();
    }

    private void initLightCoData() {
        String lightCoParam = ApexPages.currentPage().getParameters().get('light');
        if( !String.isBlank( lightCoParam ) && lightCoParam instanceOf Id ) {
            lightCoId = lightCoParam;
        }
        isLightCo = lightCoId != null;

        if( isLightCo && changeOrderContent != null ) {
            for( ChangeOrderTable table : changeOrderContent.tables ) {
                if( lightCoId == table.changeOrderRecord.Id ) {
                    lightCoNumber = ' #' + table.name;
                }
            }
        }
    }

    public Boolean hasPendingDocusignCo {
        get {
            Boolean result = false;
            if( changeOrderContent != null ) {
            for( ChangeOrderTable table : changeOrderContent.tables ) {
                if( table.status == ChangeOrderServices.STATUS_PENDING_CLIENT && table.changeOrderRecord.UseDocusign__c ) {
                    result = true;
                    break;
                }
            }
            }
            return result;
        }
    }

	public class ChangeOrderTableWrapper implements Comparable { // MRS 7178
		public ChangeOrderTable thisCoTable;
		public ChangeOrderTableWrapper(ChangeOrderTable coTable) {
			thisCoTable = coTable;
		}
		public Integer compareTo(Object compareTo) {
			ChangeOrderTableWrapper coTableWrapper = (ChangeOrderTableWrapper) compareTo;
			return coTableWrapper.thisCoTable.changeOrderRecord.Number__c == thisCoTable.changeOrderRecord.Number__c ? 0 :
				coTableWrapper.thisCoTable.changeOrderRecord.Number__c > thisCoTable.changeOrderRecord.Number__c ? -1 : 1;
		}
	}

	public List<ChangeOrderTable> allChangeOrdersList { set; get { // MRS 7178
			List<ChangeOrderTableWrapper> listCOTablesToSort = new List<ChangeOrderTableWrapper> ();
			if(changeOrderContent != null && changeOrderContent.tables != null) {
				for(ChangeOrderTable cot : changeOrderContent.tables) listCOTablesToSort.add(new ChangeOrderTableWrapper(cot));
			}
			for(ChangeOrderTable cot : canceledRejectedChangeOrders) listCOTablesToSort.add(new ChangeOrderTableWrapper(cot));
			listCOTablesToSort.sort();
			List<ChangeOrderTable> res = new List<ChangeOrderTable> ();
			for(ChangeOrderTableWrapper cotWrapper : listCOTablesToSort) res.add(cotWrapper.thisCoTable);
			return res;
		}
	}

    public List<ChangeOrderTable> canceledRejectedChangeOrders { get; set; }
    private void initCanceledRejectedChangeOrdersData() {
        canceledRejectedChangeOrders = new List<ChangeOrderTable>();
        for( Change_Order__c changeOrder : getCanceledRejectedChangeOrders( proposal.Id ) ) {
            if( previewChangeOrderId == null || changeOrder.Id != previewChangeOrderId ) {
                canceledRejectedChangeOrders.add( new ChangeOrderTable( changeOrder ) );
            }
        }
    }

    private void calculateTotals( ChangeOrderWrapper content ) {
        phaseNumbersUnique.addAll( content.phaseNumbersUnique );
        total += content.total;
        discount += content.discount;
        salesTax += content.salesTax;
        reimbursablePending += content.reimbursablePending;
        reimbursableApproved += content.reimbursableApproved;
        additionalReimbursable += content.additionalReimbursable;
        reimbursableList.addAll( content.reimbursableList );
        if( reimbursablePercentage == null ) {
            reimbursablePercentage = content.reimbursablePercentage;
            showReimbursablePercentage = content.showReimbursablePercentage;
        } else if( showReimbursablePercentage == true &&
                   ( content.showReimbursablePercentage == false ||
                     reimbursablePercentage != content.reimbursablePercentage ) ) {
            showReimbursablePercentage = false;
        }
        for( Decimal phaseNumber : content.phaseNumbersUnique ) {
            phaseNumberToPhaseName.put( phaseNumber, content.phaseNumberToPhaseName.get( phaseNumber ) );
            if( phaseNumberToPhaseTotal.get( phaseNumber ) == null ) {
                phaseNumberToPhaseTotal.put( phaseNumber, 0.00 );
            }
            phaseNumberToPhaseTotal.put( phaseNumber, phaseNumberToPhaseTotal.get( phaseNumber ) + content.phaseNumberToPhaseTotal.get( phaseNumber ) );
        }
    }

    public class ChangeOrderWrapper {
        public List<ChangeOrderTable> tables { get { if( tables == null ) tables = new List<ChangeOrderTable>(); return tables; } private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal discount { get { if( discount == null ) discount = 0.00; return discount; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public Decimal reimbursablePending { get { if( reimbursablePending == null ) reimbursablePending = 0.00; return reimbursablePending; } private set; }
        public Decimal reimbursableApproved { get { if( reimbursableApproved == null ) reimbursableApproved = 0.00; return reimbursableApproved; } private set; }
        public Decimal reimbursable { get { return reimbursablePending + reimbursableApproved; } private set; }
        public List<Additional_Reimbursable__c> reimbursableList  { get { if( reimbursableList == null ) reimbursableList = new List<Additional_Reimbursable__c>(); return reimbursableList; }  private set; }
        public Decimal additionalReimbursable { get { if( additionalReimbursable == null ) additionalReimbursable = 0.00; return additionalReimbursable; } private set; }
        public Boolean showReimbursablePercentage { get { if( showReimbursablePercentage == null ) showReimbursablePercentage = false; return showReimbursablePercentage; } private set; }
        public Decimal reimbursablePercentage { get; private set; }
        public Map<Decimal, String> phaseNumberToPhaseName { get { if( phaseNumberToPhaseName == null ) phaseNumberToPhaseName = new Map<Decimal, String>(); return phaseNumberToPhaseName; } private set; }
        public Map<Decimal, Decimal> phaseNumberToPhaseTotal { get { if( phaseNumberToPhaseTotal == null ) phaseNumberToPhaseTotal = new Map<Decimal, Decimal>(); return phaseNumberToPhaseTotal; } private set; }
        public Set<Decimal> phaseNumbersUnique { get { if( phaseNumbersUnique == null ) phaseNumbersUnique = new Set<Decimal>(); return phaseNumbersUnique; } private set; }
        public Boolean showFloors { get { if( showFloors == null ) showFloors = false; return showFloors; } private set; }
        public Map<Id, Change_Order__c> changeOrderMap { get; set; }
        public Date initialCOSendToClientDate { get; set; }

        public ChangeOrderWrapper( Proposal__c proposal, List<Service_Item__c> services, String tableContent, Boolean isPreview, Id isChangeOrderPreviewedChangeOrderId, List<Additional_Reimbursable__c> originalReimbursableList, Map<Id, Change_Order__c> changeOrderMap ) {
            this.showFloors = proposal.Is_Floors_To_Services__c;
            this.changeOrderMap = changeOrderMap;
            List<Id> orderedChangeOrderIds = new List<Id>();
            Map<Id, Change_Order__c> changeOrderIdToChangeOrder = new Map<Id, Change_Order__c>();
            Map<Id, List<Service_Item__c>> changeOrderIdToServiceItems = new Map<Id, List<Service_Item__c>>();

            Map<DateTime, Set<Id>> topChangeOrderDateToIds = new Map<DateTime, Set<Id>>();
            Map<DateTime, Set<Id>> pendingChangeOrderDateToIds = new Map<DateTime, Set<Id>>();
            Map<DateTime, Set<Id>> awardedChangeOrderDateToIds = new Map<DateTime, Set<Id>>();

            for( Service_Item__c si : services ) {
                if( tableContent == CHANGE_ORDER_SERVICES && !String.isEmpty( si.Change_Order__c ) &&
                    ( si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ||
                      si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_PENDING_CLIENT ||
                      ( isChangeOrderPreviewed( isPreview, si.Change_Order__c, isChangeOrderPreviewedChangeOrderId ) ) ) ) {
                    populateChangeOrderData( si, changeOrderIdToChangeOrder, changeOrderIdToServiceItems, isChangeOrderPreviewedChangeOrderId, isPreview,
                                             topChangeOrderDateToIds, pendingChangeOrderDateToIds, awardedChangeOrderDateToIds, tableContent, true );
                }
                if( ( tableContent == ORIGINAL_SERVICES && si.Original__c ) ||
                    ( tableContent == CHANGE_ORDER_SERVICES && !String.isEmpty( si.Change_Order_Old__c ) ) ) {
                    populateChangeOrderData( si, changeOrderIdToChangeOrder, changeOrderIdToServiceItems, isChangeOrderPreviewedChangeOrderId, isPreview,
                                             topChangeOrderDateToIds, pendingChangeOrderDateToIds, awardedChangeOrderDateToIds, tableContent, false );
                }
            }

            sortChangeOrderIdsByDateTime( orderedChangeOrderIds, topChangeOrderDateToIds );
            sortChangeOrderIdsByDateTime( orderedChangeOrderIds, pendingChangeOrderDateToIds );
            sortChangeOrderIdsByDateTime( orderedChangeOrderIds, awardedChangeOrderDateToIds );

            if( !orderedChangeOrderIds.isEmpty() ){
                Change_Order__c firstCO = changeOrderIdToChangeOrder.get( orderedChangeOrderIds[0] );
                if( firstCO.Was_Rejected__c ) {
                    initialCOSendToClientDate = firstCO.Initial_Sent_To_Client_Date__c;
                }
            }

            for( Id changeOrderId : orderedChangeOrderIds ) {
                Change_Order__c changeOrder = changeOrderIdToChangeOrder.get( changeOrderId );
                if( ( String.isEmpty( changeOrder.Id ) ) ||
                      ( changeOrder.Status__c == ChangeOrderServices.STATUS_APPROVED ||
                      changeOrder.Status__c == ChangeOrderServices.STATUS_PENDING_CLIENT ) ) {
                    ChangeOrderTable table = new ChangeOrderTable( proposal,
                                                                   changeOrder,
                                                                   changeOrderIdToServiceItems.get( changeOrderId ),
                                                                   tableContent,
                                                                   originalReimbursableList );
                    if( !table.sections.isEmpty() ) {
                        tables.add( table );
                        if( String.isEmpty( table.status ) ||
                            table.status == ChangeOrderServices.STATUS_APPROVED ||
                            table.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                            total += table.total;
                            discount += table.discount;
                            salesTax += table.salesTax;
                            if( table.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                                reimbursablePending += table.reimbursable;
                            } else {
                                reimbursableApproved += table.reimbursable;
                            }
                            additionalReimbursable += table.additionalReimbursable;
                            reimbursableList.addAll( table.reimbursableList );
                            if( reimbursablePercentage == null ) {
                                reimbursablePercentage = table.reimbursablePercentage;
                                showReimbursablePercentage = true;
                            } else if( reimbursablePercentage != table.reimbursablePercentage ) {
                                showReimbursablePercentage = false;
                            }
                        }
                    }
                    calculatePhaseTotals( table );
                }
            }
        }

        private void sortChangeOrderIdsByDateTime( List<Id> orderedChangeOrderIds, Map<DateTime, Set<Id>> changeOrderDateTimeToIds ) {
            List<DateTime> orderedDateTimes = new List<DateTime>();
            List<DateTime> changeOrderDateTimes = new List<DateTime>( changeOrderDateTimeToIds.keySet() );
            changeOrderDateTimes.sort();
            for( Integer i = changeOrderDateTimes.size() - 1; i >= 0; i-- ) {
                orderedDateTimes.add( changeOrderDateTimes[i] );
            }
            for( DateTime dtItem : orderedDateTimes ) {
                for( Id idItem : changeOrderDateTimeToIds.get( dtItem ) ) {
                    orderedChangeOrderIds.add( idItem );
                }
            }
        }

        private void populateChangeOrderData( Service_Item__c si,
                                              Map<Id, Change_Order__c> changeOrderIdToChangeOrder,
                                              Map<Id, List<Service_Item__c>> changeOrderIdToServiceItems,
                                              Id isChangeOrderPreviewedChangeOrderId,
                                              Boolean isPreview,
                                              Map<DateTime, Set<Id>> topChangeOrderDateToIds,
                                              Map<DateTime, Set<Id>> pendingChangeOrderDateToIds,
                                              Map<DateTime, Set<Id>> awardedChangeOrderDateToIds,
                                              String tableContent,
                                              Boolean isNew ) {
            Id currentChangeOrderId = isNew ? si.Change_Order__c : si.Change_Order_Old__c;
            Change_Order__c currentChangeOrder = createChangeOrderFromServiceItemData( si, isPreview, isChangeOrderPreviewedChangeOrderId, isNew );

            changeOrderIdToChangeOrder.put( currentChangeOrderId, currentChangeOrder );
            if( !changeOrderIdToServiceItems.containsKey( currentChangeOrderId ) ) {
                changeOrderIdToServiceItems.put( currentChangeOrderId, new List<Service_Item__c>() );
            }
            changeOrderIdToServiceItems.get( currentChangeOrderId ).add( si );

            if( isChangeOrderPreviewed( isPreview, currentChangeOrderId, isChangeOrderPreviewedChangeOrderId ) ||
                ( tableContent == ORIGINAL_SERVICES && si.Original__c ) ) {
                if( !topChangeOrderDateToIds.containsKey( currentChangeOrder.Change_Order_Sent_DateTime__c ) ) {
                    topChangeOrderDateToIds.put( currentChangeOrder.Change_Order_Sent_DateTime__c, new Set<Id>() );
                }
                topChangeOrderDateToIds.get( currentChangeOrder.Change_Order_Sent_DateTime__c ).add( currentChangeOrderId );
            } else if( currentChangeOrder.Status__c == ChangeOrderServices.STATUS_APPROVED ) {
                if( !awardedChangeOrderDateToIds.containsKey( currentChangeOrder.Approved_DateTime__c ) ) {
                    awardedChangeOrderDateToIds.put( currentChangeOrder.Approved_DateTime__c, new Set<Id>() );
                }
                awardedChangeOrderDateToIds.get( currentChangeOrder.Approved_DateTime__c ).add( currentChangeOrderId );
            } else if( currentChangeOrder.Status__c == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                if( !pendingChangeOrderDateToIds.containsKey( currentChangeOrder.Change_Order_Sent_DateTime__c ) ) {
                    pendingChangeOrderDateToIds.put( currentChangeOrder.Change_Order_Sent_DateTime__c, new Set<Id>() );
                }
                pendingChangeOrderDateToIds.get( currentChangeOrder.Change_Order_Sent_DateTime__c ).add( currentChangeOrderId );
            }
        }

        private Change_Order__c createChangeOrderFromServiceItemData( Service_Item__c si, Boolean isPreview, Id changeOrderId, Boolean isNew ) {
            Change_Order__c newChangeOrder;
            if( isNew ) {
                newChangeOrder =  new Change_Order__c( Id = si.Change_Order__c,
                                            Number__c = si.Change_Order__r.Number__c,
                                            UseDocusign__c = si.Change_Order__r.UseDocusign__c,
                                            Approved_Date__c = si.Change_Order__r.Approved_Date__c,
                                            Approved_DateTime__c = si.Change_Order__r.Approved_DateTime__c,
                                            Status__c = isChangeOrderPreviewed( isPreview, si.Change_Order__c, changeOrderId )
                                                        ? ChangeOrderServices.STATUS_PENDING_CLIENT
                                                        : si.Change_Order__r.Status__c,
                                            General_Change_Order_Notes__c = si.Change_Order__r.General_Change_Order_Notes__c,
                                            Change_Order_Sent_Date__c = isChangeOrderPreviewed( isPreview, si.Change_Order__c, changeOrderId )
                                                                        ? Date.Today()
                                                                        : si.Change_Order__r.Change_Order_Sent_Date__c,
                                            Change_Order_Sent_DateTime__c = isChangeOrderPreviewed( isPreview, si.Change_Order__c, changeOrderId )
                                                                            ? Date.Today()
                                                                            : si.Change_Order__r.Change_Order_Sent_DateTime__c != null
                                                                              ? si.Change_Order__r.Change_Order_Sent_DateTime__c
                                                                              : si.Change_Order__r.Change_Order_Sent_Date__c,
                                            Municipal_Authority_Fees__c = si.Change_Order__r.Municipal_Authority_Fees__c,
                                            Projected_DOB_Fee__c = si.Change_Order__r.Projected_DOB_Fee__c,
                                            Initial_Sent_To_Client_Date__c = si.Change_Order__r.Initial_Sent_To_Client_Date__c,
                                            Was_Rejected__c = si.Change_Order__r.Was_Rejected__c );
            } else {
                newChangeOrder =  new Change_Order__c( Id = si.Change_Order_Old__c,
                                            Number__c = si.Change_Order_Old__r.Number__c,
                                            UseDocusign__c = si.Change_Order_Old__r.UseDocusign__c,
                                            Approved_Date__c = si.Change_Order_Old__r.Approved_Date__c,
                                            Approved_DateTime__c = si.Change_Order_Old__r.Approved_DateTime__c,
                                            Status__c = isChangeOrderPreviewed( isPreview, si.Change_Order_Old__c, changeOrderId )
                                                        ? ChangeOrderServices.STATUS_PENDING_CLIENT
                                                        : si.Change_Order_Old__r.Status__c,
                                            General_Change_Order_Notes__c = si.Change_Order_Old__r.General_Change_Order_Notes__c,
                                            Change_Order_Sent_Date__c = isChangeOrderPreviewed( isPreview, si.Change_Order_Old__c, changeOrderId )
                                                                        ? Date.Today()
                                                                        : si.Change_Order_Old__r.Change_Order_Sent_Date__c,
                                            Change_Order_Sent_DateTime__c = isChangeOrderPreviewed( isPreview, si.Change_Order_Old__c, changeOrderId )
                                                                            ? Date.Today()
                                                                            : si.Change_Order_Old__r.Change_Order_Sent_DateTime__c != null
                                                                              ? si.Change_Order_Old__r.Change_Order_Sent_DateTime__c
                                                                              : si.Change_Order_Old__r.Change_Order_Sent_Date__c,
                                            Municipal_Authority_Fees__c = si.Change_Order_Old__r.Municipal_Authority_Fees__c,
                                            Projected_DOB_Fee__c = si.Change_Order_Old__r.Projected_DOB_Fee__c,
                                            Initial_Sent_To_Client_Date__c = si.Change_Order__r.Initial_Sent_To_Client_Date__c,
                                            Was_Rejected__c = si.Change_Order__r.Was_Rejected__c );
            }
            if(changeOrderMap.containsKey(newChangeOrder.Id)){
                newChangeOrder.Apply_Reimbursable__c = changeOrderMap.get(newChangeOrder.Id).Apply_Reimbursable__c;
                newChangeOrder.Reimbursable_Percentage__c = changeOrderMap.get(newChangeOrder.Id).Reimbursable_Percentage__c;
                newChangeOrder.Apply_Discount__c = changeOrderMap.get(newChangeOrder.Id).Apply_Discount__c;
                newChangeOrder.Discount_Percentage__c = changeOrderMap.get(newChangeOrder.Id).Discount_Percentage__c;
            }
            return newChangeOrder;
        }

        private Boolean isChangeOrderPreviewed( Boolean isPreview, Id serviceItemChangeOrderId, Id changeOrderId ) {
            return isPreview && serviceItemChangeOrderId == changeOrderId;
        }

        private void calculatePhaseTotals( ChangeOrderTable table ) {
            phaseNumbersUnique.addAll( table.phaseNumbers );
            for( Decimal phaseNumber : table.phaseNumbers ) {
                phaseNumberToPhaseName.put( phaseNumber, table.phaseNumberToPhaseName.get( phaseNumber ) );
                if( phaseNumberToPhaseTotal.get( phaseNumber ) == null ) {
                    phaseNumberToPhaseTotal.put( phaseNumber, 0.00 );
                }
                if( String.isEmpty( table.status ) || table.status == ChangeOrderServices.STATUS_APPROVED ) {
                    phaseNumberToPhaseTotal.put( phaseNumber, phaseNumberToPhaseTotal.get( phaseNumber ) + table.phaseNumberToPhaseTotal.get( phaseNumber ) );
                }
            }
        }
    }

    public class ChangeOrderTable {
        public List<ChangeOrderSection> sections { get { if( sections == null ) sections = new List<ChangeOrderSection>(); return sections; } private set; }
        public List<Service_Item__c> sItems {private set; get;}
        public String name { get; private set; }
        public Date awardedDate { get; private set; }
        public Date sentDate { get; private set; }
        public Boolean wasRejected { get; private set; }
        public Date initialSendToClientDate { get; private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal discount { get { if( discount == null ) discount = 0.00; return discount; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public Decimal reimbursable { get { if( reimbursable == null ) reimbursable = 0.00; return reimbursable; } private set; }
        public Decimal grandTotal { get { if( grandTotal == null ) grandTotal = 0.00; return grandTotal; } private set; }
        public Map<Decimal, String> phaseNumberToPhaseName { get { if( phaseNumberToPhaseName == null ) phaseNumberToPhaseName = new Map<Decimal, String>(); return phaseNumberToPhaseName; } private set; }
        public Map<Decimal, Decimal> phaseNumberToPhaseTotal { get { if( phaseNumberToPhaseTotal == null ) phaseNumberToPhaseTotal = new Map<Decimal, Decimal>(); return phaseNumberToPhaseTotal; } private set; }
        public List<Decimal> phaseNumbers { get { if( phaseNumbers == null ) phaseNumbers = new List<Decimal>(); return phaseNumbers; } set; }
        public String status { get; set; }
        public Change_Order__c changeOrderRecord { get; set; }
        public Decimal reimbursablePercentage { get { if( reimbursablePercentage == null ) reimbursablePercentage = 0; return reimbursablePercentage; } private set; }
        public List<Additional_Reimbursable__c> reimbursableList  { get { if( reimbursableList == null ) reimbursableList = new List<Additional_Reimbursable__c>(); return reimbursableList; }  private set; }
        public Decimal additionalReimbursable { get { if( additionalReimbursable == null ) additionalReimbursable = 0.00; return additionalReimbursable; } private set; }
        public Boolean applyDiscount { get { if( applyDiscount == null ) applyDiscount = false; return applyDiscount; } private set; }
        public Decimal discountPercentage { get { if( discountPercentage == null ) discountPercentage = 0; return discountPercentage; } private set; }
		public Boolean isRejectedOrCancelled { set; get { return status == 'Rejected' || status == 'Canceled' ? true : false; } } // MRS 7178

        public ChangeOrderTable( Proposal__c proposal, Change_Order__c changeOrder, List<Service_Item__c> serviceItems, String tableContent, List<Additional_Reimbursable__c> originalReimbursableList ) {
            if( tableContent == ORIGINAL_SERVICES ) {
                sItems = serviceItems; //MRS-6827
                name = proposal.Name;
                awardedDate = proposal.Proposal_Awarded_Date__c;
                wasRejected = false;
                if( proposal.Reimbursable_Items_Basis__c){
                    for( Additional_Reimbursable__c item: originalReimbursableList ){
                        if( String.isBlank(item.Change_Order__c) ){
                            reimbursableList.add(item);
                            additionalReimbursable += item.Amount__c;
                        }
                    }
                    reimbursablePercentage = proposal.Reimbursable_Percentage__c;
                }
                applyDiscount = proposal.Apply_Discount__c;
                discountPercentage = proposal.Discount_Percentage__c;
            } else if( tableContent == CHANGE_ORDER_SERVICES ) {
                sItems = serviceItems; //MRS-6827
                name = changeOrder.Number__c != null ? String.valueOf( changeOrder.Number__c ) : '';
                awardedDate = changeOrder.Approved_Date__c;
                wasRejected = changeOrder.Was_Rejected__c;
                initialSendToClientDate = changeOrder.Initial_Sent_To_Client_Date__c;
                sentDate = changeOrder.Change_Order_Sent_Date__c;
                status = changeOrder.Status__c;
                if( changeOrder.Apply_Reimbursable__c){
                    for( Additional_Reimbursable__c item: originalReimbursableList ){
                        if( item.Change_Order__c == changeOrder.Id ){
                            reimbursableList.add(item);
                            additionalReimbursable += item.Amount__c;
                        }
                    }
                    reimbursablePercentage = changeOrder.Reimbursable_Percentage__c;
                }
                applyDiscount = changeOrder.Apply_Discount__c;
                discountPercentage = changeOrder.Discount_Percentage__c;
            }
            changeOrderRecord = changeOrder;
            Map<Decimal, Phase__c> phaseNumberToPhase = new Map<Decimal, Phase__c>();
            Map<Decimal, List<Service_Item__c>> phaseNumberToServiceItems = new Map<Decimal, List<Service_Item__c>>();
            for( Service_Item__c si : serviceItems ) {
                Decimal phaseNumber = si.Phase__r.Number__c;
                String phaseName = si.Phase__r.Name__c;
                phaseNumberToPhase.put( phaseNumber, new Phase__c( Id = si.Phase__c,
                                                                   Number__c = phaseNumber,
                                                                   Name__c = phaseName ) );
                phaseNumberToPhaseName.put( phaseNumber, phaseName );
                phaseNumberToPhaseTotal.put( phaseNumber, 0.00 );
                if( !phaseNumberToServiceItems.containsKey( phaseNumber ) ) {
                    phaseNumberToServiceItems.put( phaseNumber, new List<Service_Item__c>() );
                }
                phaseNumberToServiceItems.get( phaseNumber ).add( si );
            }
            phaseNumbers.addAll( phaseNumberToPhase.keySet() );
            phaseNumbers.sort();
            for( Decimal phaseNumber : phaseNumbers ) {
                ChangeOrderSection section = new ChangeOrderSection( changeOrder,
                                                                     phaseNumberToPhase.get( phaseNumber ),
                                                                     phaseNumberToServiceItems.get( phaseNumber ) );
                if( !section.lines.isEmpty() ) {
                    sections.add( section );
                    total += section.total;
                    discount += section.discountedTotal - section.total;
                    salesTax += section.salesTax;
                }
                phaseNumberToPhaseTotal.put( phaseNumber, phaseNumberToPhaseTotal.get( phaseNumber ) + section.total );
            }
            reimbursable = total * reimbursablePercentage / 100;
            grandTotal = ( total + discount ) + salesTax + reimbursable + additionalReimbursable;
        }

        public ChangeOrderTable( Change_Order__c changeOrder ) {
            changeOrderRecord = changeOrder;
            name = String.valueOf( changeOrder.Number__c );
            status = changeOrder.Status__c == ChangeOrderServices.STATUS_REJECTED
                     ? 'Rejected'
                     : changeOrder.Status__c == ChangeOrderServices.STATUS_CANCELED
                       ? 'Canceled'
                       : '';
            for( Change_History_Proposal__c changeHistory : changeOrder.Change_Histories_Proposal__r ) {
                sentDate = changeHistory.Date__c;
            }
            if( sentDate == null ) {
                sentDate = changeOrder.CreatedDate.date();
            }
        }
    }

    public class ChangeOrderSection {
        public List<ChangeOrderLine> lines { get { if( lines == null ) lines = new List<ChangeOrderLine>(); return lines; } private set; }
        public String name { get; private set; }
        public Decimal total { get { if( total == null ) total = 0.00; return total; } private set; }
        public Decimal discountedTotal { get { if( discountedTotal == null ) discountedTotal = 0.00; return discountedTotal; } private set; }
        public Decimal salesTax { get { if( salesTax == null ) salesTax = 0.00; return salesTax; } private set; }
        public Boolean hasLargeGroup { get { for( ChangeOrderLine line : lines ) { if( line.hasLargeGroup ) return true; } return false; } }

        public ChangeOrderSection( Change_Order__c changeOrder, Phase__c phase, List<Service_Item__c> serviceItems ) {
            name = phase.Name__c;
            //deleted services and services with quantity changes in current CO go to bottom
            Map<Boolean, List<Service_Item__c>> areDeletedToServiceItems = new Map<Boolean, List<Service_Item__c>>();
            List<Boolean> areDeleted = new List<Boolean>();
            for( Service_Item__c si : serviceItems ) {
                Boolean isDeleted = false;
                if( ( si.Is_Amendmend_Deleted__c &&
                      si.Change_Order__c == changeOrder.Id ) ||
                    ( !si.Is_Amendmend_Deleted__c &&
                      ( si.Quantity_Old__c != null && si.Quantity_Old__c != 0 ) &&
                      si.Change_Order__c == changeOrder.Id ) ) {
                    isDeleted = true;
                }
                if( !areDeletedToServiceItems.containsKey( isDeleted ) ) {
                    areDeletedToServiceItems.put( isDeleted, new List<Service_Item__c>() );
                }
                areDeletedToServiceItems.get( isDeleted ).add( si );
            }
            areDeleted.addAll( areDeletedToServiceItems.keySet() );
            areDeleted.sort();
            //service groups go to bottom also if deleted ( within previous groups )
            for( Boolean isDeleted : areDeleted ) { //false goes first
                Map<String, List<Service_Item__c>> serviceGroupToServiceItems = new Map<String, List<Service_Item__c>>();

                Map<Integer, List<Service_Item__c>> positionToServiceItems = new Map<Integer, List<Service_Item__c>>();
                Integer currentPosition = 1;
                Integer serviceInPhaseIndex = 0;
                String currentGroupKey;
                List<Service_Item__c> currentGroup = new List<Service_Item__c>();

                if( !serviceItems.isEmpty() ) {
                    for( Integer serviceIndex = 0; serviceIndex < areDeletedToServiceItems.get( isDeleted ).size(); serviceIndex++ ) {
                        Service_Item__c si = areDeletedToServiceItems.get( isDeleted )[serviceIndex];
                        String groupKey = si.Service_Group_Key__c;

                        if( isDeleted == false ) { //for not deleted services
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
                            if( serviceIndex == areDeletedToServiceItems.get( isDeleted ).size() - 1 && !currentGroup.isEmpty() ) { //check if service is last and if yes, return remainders
                                if( !positionToServiceItems.containsKey( currentPosition ) ) {
                                    positionToServiceItems.put( currentPosition, new List<Service_Item__c>() );
                                }
                                positionToServiceItems.get( currentPosition ).addAll( currentGroup );
                            }
                            serviceInPhaseIndex++;

                        } else { //for deleted services or groups, not in group go first
                            if( !serviceGroupToServiceItems.containsKey( groupKey ) ) {
                                serviceGroupToServiceItems.put( groupKey, new List<Service_Item__c>() );
                            }
                            serviceGroupToServiceItems.get( groupKey ).add( si );
                        }

                    }
                }

                //create lines for not deleted services
                List<Integer> positions = new List<Integer>( positionToServiceItems.keySet() );
                positions.sort();
                for( Integer position : positions ) {
                    ChangeOrderLine line = new ChangeOrderLine( changeOrder,
                                                                positionToServiceItems.get( position ) );
                    lines.add( line );
                    total += line.total;
                    discountedTotal += line.discountedTotal;
                    salesTax += line.salesTax;
                }

                //create lines for deleted services
                List<String> serviceGroups = new List<String>( serviceGroupToServiceItems.keySet() );
                serviceGroups.sort();
                for( String serviceGroup : serviceGroups ) {
                    if( String.isEmpty( serviceGroup ) ) {
                        for( Service_Item__c si : serviceGroupToServiceItems.get( serviceGroup ) ) {
                            ChangeOrderLine line = new ChangeOrderLine( changeOrder,
                                                                        new List<Service_Item__c>{ si } );
                            lines.add( line );
                            total += line.total;
                            discountedTotal += line.discountedTotal;
                            salesTax += line.salesTax;
                        }
                    } else {
                        ChangeOrderLine line = new ChangeOrderLine( changeOrder,
                                                                    serviceGroupToServiceItems.get( serviceGroup ) );
                        lines.add( line );
                        total += line.total;
                        discountedTotal += line.discountedTotal;
                        salesTax += line.salesTax;
                    }
                }
            }
        }
    }

    public class ChangeOrderLine {
        public Boolean isGroup { get { if( isGroup == null ) isGroup = false; return isGroup; } private set; }
        public String name { get; private set; }
        public List<String> names { get { if( names == null ) names = new List<String>(); return names; } private set; }
        public String floor { get; private set; }
        public List<String> floors { get { if( floors == null ) floors = new List<String>(); return floors; } private set; }
        public String municipalAgency { get; private set; }
        public List<String> municipalAgencies { get { if( municipalAgencies == null ) municipalAgencies = new List<String>(); return municipalAgencies; } private set; }
        public String fullName { get; private set; }
        public String description { get { if( description == null ) description = ''; return description; } private set; }
        public String action { get; private set; }
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

        public ChangeOrderLine( Change_Order__c changeOrder, List<Service_Item__c> serviceItems ) {
            Boolean isCurrentCONew = serviceItems[0].Change_Order__c == changeOrder.Id;
            Boolean isCurrentCOOld = serviceItems[0].Change_Order_Old__c == changeOrder.Id;
            Boolean isQuantityCO = serviceItems[0].Quantity_Old__c != null && serviceItems[0].Quantity_Old__c != 0;
            Boolean isQuantityCOInCONew = isCurrentCONew && isQuantityCO;
            Boolean isQuantityCOInCOOld = isCurrentCOOld && isQuantityCO;
            Boolean isDeletedInCONew = isCurrentCONew && serviceItems[0].Is_Amendmend_Deleted__c;
            Integer removalMultiplier = isDeletedInCONew || isQuantityCOInCONew ? -1 : 1;
            Decimal discountedUnitPrice;

            fullName = serviceItems[0].Service_Name_Full__c;
            description = serviceItems[0].Description__c;
            action = ( isDeletedInCONew || isQuantityCOInCONew ) ? 'Removed' : 'Added';
            if( String.isEmpty( serviceItems[0].Service_Group_Key__c ) || serviceItems.size() == 1 ) {
                name = serviceItems[0].Name_Short__c != null ? serviceItems[0].Name_Short__c : '';
                floor = serviceItems[0].Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( serviceItems[0].Floor__c.split(', '), ',' ).split(','), ',&nbsp;', 2 ), ', ' ) : '';
                municipalAgency = serviceItems[0].Municipal_Agency_ID__c != null ? serviceItems[0].Municipal_Agency_ID__c : '';
                if( !isQuantityCO ) {
                    quantity = serviceItems[0].Quantity__c;
                } else {
                    if( isQuantityCOInCONew ) {
                        quantity = serviceItems[0].Quantity_Old__c - serviceItems[0].Quantity__c;
                    } else {
                        quantity = serviceItems[0].Quantity_Old__c;
                    }
                }
                unitPrice = serviceItems[0].Unit_Price__c != null ? serviceItems[0].Unit_Price__c : 0.00;
                discountedUnitPrice = serviceItems[0].Discounted_Unit_Price__c;
            } else {
                isGroup = true;
                for( Service_Item__c si : serviceItems ) {
                    names.add( si.Name_Short__c != null ? si.Name_Short__c : '' );
                    floors.add( si.Floor__c != null ? String.join( MilroseDevHelper.joinEveryNthElement( String.join( si.Floor__c.split(', '), ',' ).split(','), ',&nbsp;', 2 ), ', ' ) : '' );
                    municipalAgencies.add( si.Municipal_Agency_ID__c != null ? si.Municipal_Agency_ID__c : '' );
                }
                quantity = serviceItems.size();
                if( !isQuantityCO ) {
                    unitPrice = serviceItems[0].Quantity__c * ( serviceItems[0].Unit_Price__c != null ? serviceItems[0].Unit_Price__c : 0.00 );
                    discountedUnitPrice = serviceItems[0].Quantity__c * serviceItems[0].Discounted_Unit_Price__c;
                } else {
                    if( isQuantityCOInCONew ) {
                        unitPrice = ( serviceItems[0].Quantity_Old__c - serviceItems[0].Quantity__c ) * ( serviceItems[0].Unit_Price__c != null ? serviceItems[0].Unit_Price__c : 0.00 );
                        discountedUnitPrice = ( serviceItems[0].Quantity_Old__c - serviceItems[0].Quantity__c ) * serviceItems[0].Discounted_Unit_Price__c;
                    } else {
                        unitPrice = serviceItems[0].Quantity_Old__c * ( serviceItems[0].Unit_Price__c != null ? serviceItems[0].Unit_Price__c : 0.00 );
                        discountedUnitPrice = serviceItems[0].Quantity_Old__c * serviceItems[0].Discounted_Unit_Price__c;
                    }
                }
            }
            total = removalMultiplier * quantity * unitPrice;
            discountedTotal = removalMultiplier * quantity * discountedUnitPrice;
            salesTax = ( ( discountedTotal * ( ( serviceItems[0].Tax_Percent_1__c != null
                                                 ? serviceItems[0].Tax_Percent_1__c
                                                 : 0.00 ) +
                                               ( serviceItems[0].Tax_Percent_2__c != null
                                                 ? serviceItems[0].Tax_Percent_2__c
                                                 : 0.00 ) ) )
                                            / 100 ).setScale(2);
        }
    }

    /*public String setOfFloors {set; //MRS-6827
        get {
            Set<id> servItemsIds = new Set<Id>();
            for(ChangeOrderTable table : changeOrderContent.tables) {
                if (!isLightCo || (isLightCo && lightCoId == table.changeOrderRecord.Id)) {
                    for(Service_Item__c tSI : table.sItems) {
                        servItemsIds.add(tSI.id);
                    }
                }
            }
            return FloorServices.getFloorsStringFromFloorServiceJunctions(servItemsIds);
        }
    }*/

    private List<Proposal__c> getProposal( Id proposalId ) { //MRS-6827
        return [ SELECT Id, Name, Version_Text__c, Client_Project__c, Billing_Company_Contact__r.Name, Billing_Company_Contact__r.Salutation, Partner__c, //MRS 7327
                        Billing_Company_Name__r.Name, Billing_Company_Name__r.BillingStreet,
                        Billing_Company_Name__r.BillingCity, Billing_Company_Name__r.BillingState, Billing_Company_Name__r.BillingPostalCode,
                        Billing_Company_Contact__r.MailingStreet,
                        Billing_Company_Contact__r.MailingCity, Billing_Company_Contact__r.MailingState, Billing_Company_Contact__r.MailingPostalCode,
                        Address_Building_AKA__c, Project_Name__c, Floor_s__c, Total_Service_Amount__c, Sales_Tax__c, Reimbursable_Percentage__c,
                        Cost__c, Fulfillment_Office__c, Primary_Company_Contact__r.Title, Primary_Company_Contact__r.Name,
                        Primary_Company_Contact__r.Suffix__c, Primary_Company_Name__r.Name, Partner__r.Name, Partner__r.Title, Partner__r.Signature__c,
                        Municipal_Authority_Fees__c, Projected_DOB_Fee__c, General_Proposal_Notes__c, Proposal_Awarded_Date__c,
                        Reimbursable_Estimated__c, Billing_Company_Contact__r.Title, Billing_Company_Contact__r.Suffix__c, Project_Profile__r.Name,
                        Discount_Percentage__c, Apply_Discount__c, Region__c, Address__r.Region__c, Reimbursable_Items_Basis__c,
                        Delivery_Method__c, Accounting_Contact_Company__r.Name, Accounting_Contact__r.MailingStreet, Accounting_Contact__r.MailingCity,
                        Accounting_Contact__r.MailingState, Accounting_Contact__r.MailingPostalCode, Accounting_Contact__r.Name, Accounting_Contact__r.Salutation,
                        Accounting_Contact__r.Email,
                        Building_AKA__c, Building_AKA__r.Building__r.City__c, Building_AKA__r.Building__r.State__c, Building_AKA__r.Building__r.PostalCode__c,
                        Address__r.City__c, Address__r.State__c, Address__r.PostalCode__c, Is_Floors_To_Services__c
                 FROM Proposal__c
                 WHERE Id = : proposalId ];
    }

    private List<Service_Item__c> getServices( Id proposalId ) {
        List<Service_Item__c> services = new List<Service_Item__c>();
        if( !String.isBlank( proposalId ) ) {
            services = [ SELECT Id, Name_Short__c, Service_Name_Full__c, Municipal_Agency_ID__c, Description__c, Is_Amendmend_Added__c,
                                Is_Amendmend_Deleted__c, Phase__c, Phase__r.Name__c, Phase__r.Number__c, Quantity__c, Quantity_Old__c,
                                Original__c, Discounted_Unit_Price__c, Total_Service_Price__c, Row_Position__c, Service_Group_Key__c,
                                Tax_Percent_1__c, Tax_Percent_2__c, Sales_Tax_Amount__c, Unit_Price__c, Discount_Percentage__c, Floor__c,

                                Change_Order__c, Change_Order__r.Number__c, Change_Order__r.Approved_Date__c,
                                Change_Order__r.Approved_DateTime__c, Change_Order__r.Status__c, Change_Order__r.General_Change_Order_Notes__c,
                                Change_Order__r.Change_Order_Sent_Date__c, Change_Order__r.Change_Order_Sent_DateTime__c,
                                Change_Order__r.Municipal_Authority_Fees__c, Change_Order__r.Projected_DOB_Fee__c,
                                Change_Order__r.Initial_Sent_To_Client_Date__c, Change_Order__r.Was_Rejected__c,
                                Change_Order__r.Apply_Discount__c, Change_Order__r.Discount_Percentage__c, Change_Order__r.UseDocusign__c,

                                Change_Order_Old__c, Change_Order_Old__r.Number__c, Change_Order_Old__r.Approved_Date__c,
                                Change_Order_Old__r.Approved_DateTime__c, Change_Order_Old__r.Status__c, Change_Order_Old__r.General_Change_Order_Notes__c,
                                Change_Order_Old__r.Change_Order_Sent_Date__c, Change_Order_Old__r.Change_Order_Sent_DateTime__c,
                                Change_Order_Old__r.Municipal_Authority_Fees__c, Change_Order_Old__r.Projected_DOB_Fee__c,
                                Change_Order_Old__r.Apply_Discount__c, Change_Order_Old__r.Discount_Percentage__c, Change_Order_Old__r.UseDocusign__c
                          FROM Service_Item__c
                          WHERE Proposal__c = : proposalId AND
                                Is_Alternative__c = false AND
                                ( ( Original__c = true AND Change_Order__c = null ) OR
                                  ( Change_Order__c != : null ) )
                          ORDER BY Row_Position__c ];
        }
        return services;
    }

    private List<Change_Order__c> getCanceledRejectedChangeOrders( Id proposalId ) {
        return [ SELECT Number__c, Status__c, CreatedDate,
                 ( SELECT Date__c
                   FROM Change_Histories_Proposal__r
                   WHERE Status__c = : ChangeOrderServices.STATUS_REJECTED
                      OR Status__c = : ChangeOrderServices.STATUS_CANCELED
                   ORDER BY Date__c DESC, CreatedDate DESC
                   LIMIT 1 )
                 FROM Change_Order__c
                 WHERE Proposal__c = : proposalId
                   AND ( Status__c = : ChangeOrderServices.STATUS_REJECTED
                      OR Status__c = : ChangeOrderServices.STATUS_CANCELED )
                 ORDER BY Number__c ];
    }

    public Map<Id, Additional_Reimbursable__c> originalReimbursableMap{ get; set; }
    public List<Additional_Reimbursable__c> originalReimbursableList{ get; set; }
    public Map<Id, Change_Order__c> changeOrderMap { get; set; }
    public Map<String, List<Additional_Reimbursable__c>> changeOrderReimbursableMap {get; set;}

    private void populateReimbursableData( id proposalId ){
        changeOrderMap = new Map<Id, Change_Order__c>([SELECT Id, Apply_Reimbursable__c, Reimbursable_Percentage__c, Apply_Discount__c, Discount_Percentage__c
                                                                FROM Change_Order__c
                                                                WHERE Proposal__c =: proposalId]);
        originalReimbursableList =  AdditionalReimbursableServices.getRecordsByProposalIdList(proposalId);
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

}