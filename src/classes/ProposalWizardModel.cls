public class ProposalWizardModel {
    private Proposal__c proposal { get { if( proposal == null ) proposal = new Proposal__c(); return proposal; } set; }
    private String profileName { get; set; }
    private String currentUserRoleName { get; set; }
    private Project_Team__c assignedProjectTeam;
    private Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel;
    public Boolean isUserInRoster;

    //MRS 7114
    public transient String primaryClientInstructions;
    public String getPrimaryClientInstructions() {
        String res = '';
        if(proposal != null && proposal.Primary_Company_Name__c != null) res = [SELECT Proposal_Instructions__c FROM Account WHERE Id = :proposal.Primary_Company_Name__c].Proposal_Instructions__c;
        return res == null ? '' : res;
    }
    public transient String billingClientInstructions;
    public String getBillingClientInstructions() {
        String res = '';
        if(proposal != null && proposal.Billing_Company_Name__c != null) res = [SELECT Proposal_Instructions__c FROM Account WHERE Id = :proposal.Billing_Company_Name__c].Proposal_Instructions__c;
        return res == null ? '' : res;
    }
    public transient String accountingClientInstructions;
    public String getAccountingClientInstructions() {
        String res = '';
        if(proposal != null && proposal.Accounting_Contact_Company__c != null) res = [SELECT Proposal_Instructions__c FROM Account WHERE Id = :proposal.Accounting_Contact_Company__c].Proposal_Instructions__c;
        return res == null ? '' : res;
    }
    public transient String buildingInstructions;
    public String getBuildingInstructions() {
        String res = '';
        if(proposal != null && proposal.Address__c != null) res = [SELECT Proposal_Instructions__c FROM Building__c WHERE Id = :proposal.Address__c].Proposal_Instructions__c;
        return res == null ? '' : res;
    }
    public transient String billingInstructions;
    public String getBillingInstructions() {
        String res = '';
        if(proposal != null && proposal.Billing_Company_Name__c != null) res = [SELECT Billing_Instructions__c FROM Account WHERE Id = :proposal.Billing_Company_Name__c].Billing_Instructions__c;
        return res == null ? '' : res;
    }

    public Map<Id, ServiceModel> serviceModels { get;
        set {
            serviceModels = value;
            updateChangeOrderModelMap();
            updateChangeOrderLists();
        }
    }

	public Map<String, Map<String, Decimal>> optViewIdToTotalsMap { //MRS 7560
		get;
		set;
	}

    public Boolean canCreateNewCo {
        get;
        set {
            this.canCreateNewCo = value;
            for( ChangeOrderModel com : changeOrderModelMap.values() ) {
                com.canCreateNewCo = value;
            }
        }
    }

    private Id userId { get; set; }
    private Map<String, Decimal> changeOrderSubtotal { get { if( changeOrderSubtotal == null ) changeOrderSubtotal = new Map<String, Decimal>(); return changeOrderSubtotal; } set; }
    private Map<String, Decimal> changeOrderDiscount { get { if( changeOrderDiscount == null ) changeOrderDiscount = new Map<String, Decimal>(); return changeOrderDiscount; } set; }
    private Map<String, Decimal> changeOrderSalesTax { get { if( changeOrderSalesTax == null ) changeOrderSalesTax = new Map<String, Decimal>(); return changeOrderSalesTax; } set; }
    private Map<String, Decimal> changeOrderReimbursableCosts { get { if( changeOrderReimbursableCosts == null ) changeOrderReimbursableCosts = new Map<String, Decimal>(); return changeOrderReimbursableCosts; } set; }
    private Map<String, Decimal> changeOrderCostOfServices { get { if( changeOrderCostOfServices == null ) changeOrderCostOfServices = new Map<String, Decimal>(); return changeOrderCostOfServices; } set; }

    public Map<String, Map<String, Decimal>> changeOrderTotalsMap {
        get {
            changeOrderTotalsMap = new Map<String, Map<String, Decimal>>();
            updateChangeOrderTotalMaps();
            changeOrderTotalsMap.put( ChangeOrderServices.SERVICES_SUBTOTAL_TITLE, changeOrderSubtotal );
            changeOrderTotalsMap.put( ChangeOrderServices.SERVICES_DISCOUNT_TITLE, changeOrderDiscount );
            changeOrderTotalsMap.put( ChangeOrderServices.SERVICES_SALES_TAX_TITLE, changeOrderSalesTax );
            changeOrderTotalsMap.put( ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE, changeOrderReimbursableCosts );
            changeOrderTotalsMap.put( ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE, changeOrderCostOfServices );
            return changeOrderTotalsMap;
        } set;
    }

    private Integer discount { get { if( discount == null ) discount = 0; return discount; } set; }
    private Integer origionalReimbursable { get { if( origionalReimbursable == null ) origionalReimbursable = 0; return origionalReimbursable; } set; }

    public Map<String, ChangeOrderModel> changeOrderModelMap { get { if( changeOrderModelMap == null ) changeOrderModelMap = new Map<String, ChangeOrderModel>(); return changeOrderModelMap; } set; }
    public List<ChangeOrderModel> originalChangeOrders { get{ if( originalChangeOrders == null ){ originalChangeOrders = new List<ChangeOrderModel>();} return originalChangeOrders; } set; }
    public List<ChangeOrderModel> approvedChangeOrders { get{ if( approvedChangeOrders == null ){ approvedChangeOrders = new List<ChangeOrderModel>();} return approvedChangeOrders; } set; }
    public List<ChangeOrderModel> notApprovedChangeOrders { get{ if( notApprovedChangeOrders == null ){ notApprovedChangeOrders = new List<ChangeOrderModel>();} return notApprovedChangeOrders; } set; }
    public List<ChangeOrderModel> alternativeChangeOrders { get{ if( alternativeChangeOrders == null ){ alternativeChangeOrders = new List<ChangeOrderModel>();} return alternativeChangeOrders; } set; }
    public List<ChangeOrderModel> canceledChangeOrders { get{ if( canceledChangeOrders == null ){ canceledChangeOrders = new List<ChangeOrderModel>();} return canceledChangeOrders; } set; }
    private List<Change_Order__c> changeOrderList = new List<Change_Order__c>();
    public Change_Order__c dummyChangeOrder { get { if( dummyChangeOrder == null ) { dummyChangeOrder = new Change_Order__c( Internal_Reviewer__c = proposal.Internal_Reviewer__c ); } return dummyChangeOrder; } set { dummyChangeOrder = value; } }

    public ProposalWizardModel( Proposal__c proposal, Project_Team__c assignedProjectTeam, String profileName, String userRoleName ) {
        this.profileName = profileName;
        this.currentUserRoleName = userRoleName;
        this.userId = UserInfo.getUserId();
        this.assignedProjectTeam = assignedProjectTeam;
        this.proposal = proposal;
        this.isChangeOrderAllowedOnProjectOrServiceItemLevel = false;
        this.isUserInRoster = false;
        this.canCreateNewCo = false;
        initChangeOrderList();
        initChangeOrderModelMaps();
    }

    private void initChangeOrderList(){
        if( proposal != null && !String.isBlank(proposal.Project_Profile__c) ){
            changeOrderList = ChangeOrderServices.getChangeOrdersByProjectProfileId(proposal.Project_Profile__c, proposal); // MRS 7280
        }
    }

    public void updateReimbursableAndDiscountData( Proposal__c proposal, Account billingAccount){
        discount = proposal.Apply_Discount__c ? proposal.Discount_Percentage__c.intValue() : 0;
        origionalReimbursable = proposal.Reimbursable_Items_Basis__c ? proposal.Reimbursable_Percentage__c.intValue() : 0;
        for( ServiceModel sm : serviceModels.values() ){
            if( String.isBlank(sm.changeOrderId) ){
                sm.discount = discount;
            }
        }
    }

    /* Change Order Scope ------------------------------------------------------------------------------------------------------------------------------------------------------- */
    private void initChangeOrderModelMaps(){
        changeOrderModelMap.clear();
        changeOrderModelMap.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, new ChangeOrderModel( null, this.profileName, this.currentUserRoleName, userId, this.proposal, true, this.assignedProjectTeam, this.isChangeOrderAllowedOnProjectOrServiceItemLevel, this.canCreateNewCo, this.isUserInRoster ) );
        changeOrderModelMap.put( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER, new ChangeOrderModel( null, this.profileName, this.currentUserRoleName, userId, this.proposal, false, this.assignedProjectTeam, this.isChangeOrderAllowedOnProjectOrServiceItemLevel, this.canCreateNewCo,  this.isUserInRoster ) );
        for( Change_Order__c co: changeOrderList ){
            changeOrderModelMap.put( co.Id, new ChangeOrderModel( co, this.profileName, this.currentUserRoleName, userId, this.proposal, null, this.assignedProjectTeam, this.isChangeOrderAllowedOnProjectOrServiceItemLevel, this.canCreateNewCo, this.isUserInRoster ) );
        }
    }

    private void updateChangeOrderModelMap(){
        initChangeOrderModelMaps();
        for( ServiceModel serviceModel: serviceModels.values() ){
            ChangeOrderModel processCOModel;
            List<ServiceModel> processServiceModelList = new List<ServiceModel>{serviceModel};
            if( serviceModel.isAlternative ){
                processCOModel = changeOrderModelMap.get( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER );
                processCOModel.addServiceModel( processServiceModelList );
                changeOrderModelMap.put( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER, processCOModel );
                continue;
            }
            if( serviceModel.isOriginal ){
                processCOModel = changeOrderModelMap.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                processCOModel.addServiceModel( processServiceModelList );
                changeOrderModelMap.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, processCOModel );
            }
            if( changeOrderModelMap.containsKey( serviceModel.changeOrderOldId ) ){
                processCOModel = changeOrderModelMap.get( serviceModel.changeOrderOldId );
                processCOModel.addServiceModel( processServiceModelList );
                changeOrderModelMap.put( serviceModel.changeOrderOldId, processCOModel );
            }
            if( changeOrderModelMap.containsKey( serviceModel.changeOrderId ) ){
                processCOModel = changeOrderModelMap.get( serviceModel.changeOrderId );
                processCOModel.addServiceModel( processServiceModelList );
                changeOrderModelMap.put( serviceModel.changeOrderId, processCOModel );
            }
        }
        for( ChangeOrderModel changeOrderModel: changeOrderModelMap.values() ){
            changeOrderModel.sortSeviceModels();
        }
    }

    private void initChangeOrderTotalMaps(){
        changeOrderSubtotal.clear();
        changeOrderDiscount.clear();
        changeOrderSalesTax.clear();
        changeOrderReimbursableCosts.clear();
        changeOrderCostOfServices.clear();
		if(proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c) { //MRS 7560
			changeOrderSubtotal.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER) );
	        changeOrderDiscount.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_DISCOUNT_TITLE).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER) );
	        changeOrderSalesTax.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SALES_TAX_TITLE).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER) );
	        changeOrderReimbursableCosts.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER) );
	        changeOrderCostOfServices.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER) );
		} else {
        changeOrderSubtotal.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, 0.00 );
        changeOrderDiscount.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, 0.00 );
        changeOrderSalesTax.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, 0.00 );
        changeOrderReimbursableCosts.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, 0.00 );
        changeOrderCostOfServices.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, 0.00 );
    }
    }

    private void updateChangeOrderTotalMaps(){
        initChangeOrderTotalMaps();
        for( ChangeOrderModel changeOrderModel: changeOrderModelMap.values() ){
            if( changeOrderModel.isAlternative ) continue;
            Decimal subtotal = changeOrderModel.getServicesTotal();
            Decimal discount = subtotal - changeOrderModel.getServicesTotalDiscounted();
            Decimal salesTax = changeOrderModel.getServicesTotalSalesTax();
			Decimal reimbursableCosts = subtotal * getCoReimbursablePercentage(changeOrderModel) / 100;
            Decimal costOfServices = subtotal - discount + salesTax + reimbursableCosts;
            
            if( changeOrderModel.isOriginal || changeOrderModel.status == ChangeOrderServices.STATUS_APPROVED ){
                reimbursableCosts += changeOrderReimbursableCosts.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                subtotal += changeOrderSubtotal.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                discount += changeOrderDiscount.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                salesTax += changeOrderSalesTax.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                costOfServices += changeOrderCostOfServices.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER );
                changeOrderSubtotal.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, subtotal );
                changeOrderDiscount.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, discount );
                changeOrderSalesTax.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, salesTax );
                changeOrderReimbursableCosts.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, reimbursableCosts );
                changeOrderCostOfServices.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, costOfServices );
            } else {
                String recordId = changeOrderModel.changeOrderRecord.Id;
				if(proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c) { //MRS 7560
					if(optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).get(recordId) != null) subtotal += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).get(recordId);
					if(optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_DISCOUNT_TITLE).get(recordId) != null) subtotal += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_DISCOUNT_TITLE).get(recordId);
					if(optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SALES_TAX_TITLE).get(recordId) != null) subtotal += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SALES_TAX_TITLE).get(recordId);
					if(optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE).get(recordId) != null) subtotal += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE).get(recordId);
					if(optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE).get(recordId) != null) subtotal += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE).get(recordId);
                }
                changeOrderSubtotal.put( recordId, subtotal );
                changeOrderDiscount.put( recordId, discount );
                changeOrderSalesTax.put( recordId, salesTax );
                changeOrderReimbursableCosts.put( recordId, reimbursableCosts );
                changeOrderCostOfServices.put( recordId, costOfServices );
            }
        }
        addAdditionalReimbursables();
    }

    private Integer getCoReimbursablePercentage( ChangeOrderModel coModel ) {
        Integer coReimbursable;
        String recordId = coModel.changeOrderRecord.Id;
        if( coModel.isOriginal ) {
            coReimbursable = origionalReimbursable;
        } else {
            coReimbursable = changeOrderModelMap.get(recordId).changeOrderRecord.Apply_Reimbursable__c &&
                    changeOrderModelMap.get(recordId).changeOrderRecord.Reimbursable_Percentage__c != null ?
                    changeOrderModelMap.get(recordId).changeOrderRecord.Reimbursable_Percentage__c.intValue() : 0;
        }
        return coReimbursable;
    }

    private void addAdditionalReimbursables(){
        Map<String, Decimal> reimbursableCostsMap = getChageOrderReimbursableCosts();
        for( String reimbursableCostsMapKey: changeOrderReimbursableCosts.keySet()){
            if(reimbursableCostsMap.containsKey(reimbursableCostsMapKey)){
                if (reimbursableCostsMapKey == ChangeOrderServices.ORIGINAL_CHANGE_ORDER){
                    if( /*origionalReimbursable > 0*/this.proposal.Reimbursable_Items_Basis__c ) {
                        updateChangeOrderTotalCosts( reimbursableCostsMapKey, reimbursableCostsMap.get(reimbursableCostsMapKey));
                    }
                    for( String mapKey : reimbursableCostsMap.keySet()){
                        if( mapKey != ChangeOrderServices.ORIGINAL_CHANGE_ORDER &&
                            changeOrderModelMap.get(mapKey).changeOrderRecord.Apply_Reimbursable__c &&
                            changeOrderModelMap.get(mapKey).status == ChangeOrderServices.STATUS_APPROVED){
                            updateChangeOrderTotalCosts(reimbursableCostsMapKey, reimbursableCostsMap.get(mapKey));
                        }
                    }
                } else if (reimbursableCostsMapKey != ChangeOrderServices.ORIGINAL_CHANGE_ORDER && changeOrderModelMap.get(reimbursableCostsMapKey).changeOrderRecord.Apply_Reimbursable__c){
                    updateChangeOrderTotalCosts(reimbursableCostsMapKey, reimbursableCostsMap.get(reimbursableCostsMapKey));
                }
            }
        }
    }

    private void updateChangeOrderTotalCosts(String mapKey, Decimal coReimbursable){
        Decimal reimbursableCosts = changeOrderReimbursableCosts.get(mapKey) + coReimbursable;
        Decimal costOfService = changeOrderCostOfServices.get(mapKey) + coReimbursable;
        changeOrderReimbursableCosts.put(mapKey, reimbursableCosts);
        changeOrderCostOfServices.put(mapKey, costOfService);
    }

    public List<Additional_Reimbursable__c> reimbursableList {
        get{
           return AdditionalReimbursableServices.getRecordsByProposalList(proposal); //MRS 7280
        }
        set;
    }

    private Map<String, Decimal> getChageOrderReimbursableCosts(){
        Map<String, Decimal> reimbursableCostsMap = new Map<String, Decimal>();
        Map<String, List<Additional_Reimbursable__c>> reimbursableMap = getChangeOrderReimbursableMap();

        for( String mapKey: reimbursableMap.keySet() ){
            Decimal totalReimbursable = 0;
            for( Additional_Reimbursable__c reimbursable: reimbursableMap.get(mapKey)){
                totalReimbursable += reimbursable.Amount__c;
            }
            reimbursableCostsMap.put(mapKey, totalReimbursable );
        }

        return reimbursableCostsMap;
    }

    public Map<String, List<Additional_Reimbursable__c>> getChangeOrderReimbursableMap() {
        Map<String, List<Additional_Reimbursable__c>> coReimbursableMap = new Map<String, List<Additional_Reimbursable__c>>();
        coReimbursableMap.put(ChangeOrderServices.ORIGINAL_CHANGE_ORDER, new List<Additional_Reimbursable__c>());
        for( String coId: changeOrderModelMap.keySet() ){
            coReimbursableMap.put(coId, new List<Additional_Reimbursable__c>());
        }
        if( proposal.Id == null ) return coReimbursableMap;

        for( Additional_Reimbursable__c item: reimbursableList ){
            if( String.isBlank(item.Change_Order__c)){
                List<Additional_Reimbursable__c> reimbursables = coReimbursableMap.get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER);
                reimbursables.add(item);
                coReimbursableMap.put(ChangeOrderServices.ORIGINAL_CHANGE_ORDER, reimbursables);
            }else{
                List<Additional_Reimbursable__c> reimbursables = coReimbursableMap.get(item.Change_Order__c);
                reimbursables.add(item);
                coReimbursableMap.put(item.Change_Order__c, reimbursables);
            }
        }

        return coReimbursableMap;
    }

    public void updateChangeOrderReimbursableData(String changeOrderId ){
        if( !changeOrderModelMap.containsKey(changeOrderId) ){
            return;
        }
        Change_Order__c changeOrder = changeOrderModelMap.get(changeOrderId).changeOrderRecord;
        try {
            Decimal reimbPercentValue = changeOrder.Apply_Reimbursable__c ? String.isBlank(String.valueOf(changeOrder.Reimbursable_Percentage__c)) ? 10 : changeOrder.Reimbursable_Percentage__c : 0;
            UPSERT new Change_Order__c( id = changeOrder.Id,
                                        Apply_Reimbursable__c = changeOrder.Apply_Reimbursable__c,
                                        Reimbursable_Percentage__c = reimbPercentValue);
            changeOrder.Reimbursable_Percentage__c = reimbPercentValue;
        } catch (exception ex) {
            throw new ErrorException( 'Error updating Change Order Reimbursable Data');
        }
    }

    public void changeReceivedDocumentStatus( String changeOrderId ) {
        if( String.isBlank( changeOrderId ) ) {
            try {
                UPSERT new Proposal__c( Id = proposal.Id, Received_Signed_Proposal__c = proposal.Received_Signed_Proposal__c);
            } catch( Exception ex ) {
                throw new ErrorException( 'Error updating Proposal Received Signed Data' );
            }
        }else{
            Change_Order__c changeOrder = changeOrderModelMap.get( changeOrderId ).changeOrderRecord;
            try {
                UPSERT new Change_Order__c( Id = changeOrder.Id, Received_Signed_CO__c = changeOrder.Received_Signed_CO__c);
            } catch( Exception ex ) {
                throw new ErrorException( 'Error updating Change Order Received Signed Data');
            }
        }
    }

    public void updateChangeOrderDiscountData( String changeOrderId ){
        if( !changeOrderModelMap.containsKey(changeOrderId) ){
            return;
        }
        Change_Order__c changeOrder = changeOrderModelMap.get(changeOrderId).changeOrderRecord;
        if( changeOrder.Discount_Percentage__c == null ) {
            changeOrder.Discount_Percentage__c = 0;
        }
        List<Service_Item__c> servicesToUpdate = new List<Service_Item__c>();
        Decimal discount = changeOrder.Apply_Discount__c ? changeOrder.Discount_Percentage__c : 0;
        for( ServiceModel serviceModel : changeOrderModelMap.get( changeOrderId ).serviceModels ) {
            if( ( serviceModel.isAmendmendAdded && serviceModel.changeOrderOldId == null ) || serviceModel.changeOrderOldId == changeOrderId ) {
                serviceModel.discount = discount;
                servicesToUpdate.add( new Service_Item__c( Id = serviceModel.recordId, Discount_Percentage__c = discount ) );
            }
        }
        try {
            UPSERT new Change_Order__c( Id = changeOrder.Id,
                                        Apply_Discount__c = changeOrder.Apply_Discount__c,
                                        Discount_Percentage__c = changeOrder.Discount_Percentage__c );
        } catch( Exception ex ) {
            throw new ErrorException( 'Error updating Change Order Discount Data');
        }
        try {
            UPSERT servicesToUpdate;
        } catch( Exception ex ) {
            throw new ErrorException( 'Error updating Change Order Services Discount Data');
        }
    }

    private void updateChangeOrderLists(){
        approvedChangeOrders.clear();
        notApprovedChangeOrders.clear();
        canceledChangeOrders.clear();
        originalChangeOrders = new List<ChangeOrderModel>{changeOrderModelMap.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER )};
        alternativeChangeOrders = new List<ChangeOrderModel>{changeOrderModelMap.get( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER )};
        for( Change_Order__c changeOrder: changeOrderList ){
            ChangeOrderModel currentCOModel = changeOrderModelMap.get(changeOrder.Id);
            if( currentCOModel.status == ChangeOrderServices.STATUS_APPROVED ){
                approvedChangeOrders.add( currentCOModel );
            }else if( currentCOModel.status == ChangeOrderServices.STATUS_CANCELED ){
                canceledChangeOrders.add( currentCOModel );
            }else{
                notApprovedChangeOrders.add( currentCOModel );
            }
        }

    }

    private void updateNotApprovedChangeOrderList(){
        notApprovedChangeOrders.clear();
        for( ChangeOrderModel changeOrderModel: changeOrderModelMap.values() ){
            if( !changeOrderModel.isOriginal && !changeOrderModel.isAlternative && changeOrderModel.status != ChangeOrderServices.STATUS_APPROVED ){
                notApprovedChangeOrders.add( changeOrderModel );
            }
        }
    }

    public void updateAllChangeOrderData(){  // MRS 7254
        initChangeOrderList();
        updateChangeOrderModelMap();
        updateChangeOrderLists();
    }

    public Boolean addChangeOrder(){
        Change_Order__c newChangeOrder = new Change_Order__c(
            Proposal__c = proposal.Id,
            Project_Profile__c = proposal.Project_Profile__c,
            Apply_Reimbursable__c = proposal.Reimbursable_Items_Basis__c,
            Reimbursable_Percentage__c = proposal.Reimbursable_Percentage__c,
            Apply_Discount__c = proposal.Apply_Discount__c,
            Discount_Percentage__c = proposal.Discount_Percentage__c);
        try {
            insert( newChangeOrder );
            updateAllChangeOrderData();
            return true;
        } catch(System.DMLException e) {
            return false;
        }
        return false;
    }

    public Boolean deleteChangeOrder( Id deleteCOId ){
        List<Service_Item__c > servicesToUpdate = new List<Service_Item__c >();
        List<Service_Item__c > servicesToDelete = new List<Service_Item__c >();
        Set<Id> serviceIdsToRemove = new Set<Id>();
        for( ServiceModel serviceModel : changeOrderModelMap.get( deleteCOId ).serviceModels ) {
            if( serviceModel.isAmendmendDeleted || serviceModel.getIsQuantityChangeOrder() ){
                undeleteServiceModel( serviceModels.get(serviceModel.recordId) );
                servicesToUpdate.add( serviceModels.get(serviceModel.recordId).getServiceItem( false ) );
            } else {
                servicesToDelete.add( serviceModels.get(serviceModel.recordId).serviceItemRecord );
                serviceIdsToRemove.add( serviceModel.recordId );
            }
        }

        List<Additional_Reimbursable__c> reimbursableToDelete = new List<Additional_Reimbursable__c>();
        for( Additional_Reimbursable__c reimbursable: reimbursableList ){
            if( reimbursable.Change_Order__c ==  deleteCOId ){
                reimbursableToDelete.add(new Additional_Reimbursable__c( Id = reimbursable.Id ) );
            }
        }

        Savepoint sp_deleteChangeOrder = Database.setSavepoint();
        try {
            DELETE changeOrderModelMap.get(deleteCOId).changeOrderRecord;
            if( !servicesToUpdate.isEmpty() || !servicesToDelete.isEmpty() ) {
                UPDATE servicesToUpdate;
                DELETE servicesToDelete;
                for( ServiceModel serviceModel : changeOrderModelMap.get( deleteCOId ).serviceModels ) {
                    if( serviceIdsToRemove.contains( serviceModel.recordId ) ) {
                        serviceModels.remove( serviceModel.recordId );
                    }
                }
            }
            if( !reimbursableToDelete.isEmpty() ){
                DELETE reimbursableToDelete;
            }
            updateAllChangeOrderData();
            return true;
        } catch(System.DMLException e) {
            Database.rollback(sp_deleteChangeOrder);
            return false;
        }
        return false;
    }

    public Boolean saveChangeOrders( Id changeOrderId ){
        List<Change_Order__c> changeOrders = new List<Change_Order__c>();
        for( String key : changeOrderModelMap.keySet() ) {
            if( key != ChangeOrderServices.ORIGINAL_CHANGE_ORDER && key != ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) {
                ChangeOrderModel coModel = changeOrderModelMap.get( key );
                Change_Order__c co = coModel.getChangeOrder( proposal, false );

                if( changeOrderId == null || changeOrderId == coModel.changeOrderRecord.Id ) { // MRS 7265 //don't overwrite the status of other COs if several users are working with the same Wizard
                    co.Status__c = coModel.status;
                    Boolean sipsForCO = isSIPSUserInChangeOrder( co.Id, profileName, userId ); // MRS 7248
                    if( sipsForCO && co.Status__c == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ) {
                        co.SIPS_Coordinator__c = null;
                        co.Internal_Reviewer__c = null;
                    }
					if(proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c && optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).get(co.Id) != null) { //MRS 7560
						co.Services_Total__c += optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).get(co.Id);
                    }
                    changeOrders.add( co );
                }
            }
        }
        try {
            UPSERT changeOrders;
            return true;
        } catch( System.DMLException e ) {
            System.debug( LoggingLevel.ERROR, 'exception ' + String.valueOf(e) );
            return false;
        }
        return false;
    }

    public void cleanUpDummyChangeOrder(){
        dummyChangeOrder = new Change_Order__c( Internal_Reviewer__c = proposal.Internal_Reviewer__c, Reminder_for_Creator__c = null );
    }

    public Boolean changeCOStatus( String changeOrderId, String changeOrderNewStatus, String oldStatus, List<FloorWrapper> currentFloorWrapperList ) {
        if( String.isBlank(changeOrderId) || !(changeOrderId instanceOf Id) ) return false;
        String newStatus;
        //System.debug(LoggingLevel.ERROR, 'xxx changeOrderId ' + changeOrderId);
        //System.debug(LoggingLevel.ERROR, 'xxx changeOrderNewStatus ' + changeOrderNewStatus);
        if( changeOrderNewStatus == 'Draft' ) newStatus = ChangeOrderServices.STATUS_DRAFT;
        else if( changeOrderNewStatus == 'Change Order Requested' ) newStatus = ChangeOrderServices.STATUS_REQUESTED;
        else if( changeOrderNewStatus == 'In C&Z Scope Review' ) newStatus = ChangeOrderServices.STATUS_IN_CZ_REVIEW;
        else if( changeOrderNewStatus == 'C&Z Scope Review Complete' ) newStatus = ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE;
        else if( changeOrderNewStatus == 'In Internal Review' ) newStatus = ChangeOrderServices.STATUS_IN_INT_REVIEW;
        else if( changeOrderNewStatus == 'Passed Internal Review' ) newStatus = ChangeOrderServices.STATUS_PASSED_INT_REVIEW;
        else if( changeOrderNewStatus == 'Failed Internal Review' ) newStatus = ChangeOrderServices.STATUS_FAILED_INT_REVIEW;
        else if( changeOrderNewStatus == 'Pending Client Approval' ) newStatus = ChangeOrderServices.STATUS_PENDING_CLIENT;
        else if( changeOrderNewStatus == 'Change Order Approved' ) newStatus = ChangeOrderServices.STATUS_APPROVED;
        else if( changeOrderNewStatus == 'Change Order Rejected' ) newStatus = ChangeOrderServices.STATUS_REJECTED;
        else if( changeOrderNewStatus == 'Canceled' ) newStatus = ChangeOrderServices.STATUS_CANCELED;
        else return false;
        ChangeOrderModel currentChangeOrder = changeOrderModelMap.get(changeOrderId);
        for( ServiceModel sm : currentChangeOrder.serviceModels ) {
            if( sm.getIsUnitPriceRequired() && ( sm.servicePrice == null /*|| sm.servicePrice == 0*/ ) ) {
                throw new ErrorException( 'You should set the Unit Price for services requiring this before changing the status of this Change Order.' );
                return false;
            }
        }
        if( newStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && !isSIPSUserInChangeOrder( currentChangeOrder.changeOrderRecord.Id, profileName, userId ) ) {
            currentChangeOrder.internalReviewer = dummyChangeOrder.Internal_Reviewer__c;
            currentChangeOrder.internalReviewerReminder = dummyChangeOrder.Internal_Reviewer_Reminder__c;
            currentChangeOrder.internalReviewerForCells = currentChangeOrder.internalReviewer != null ? currentChangeOrder.internalReviewer : proposal.Internal_Reviewer__c;
            cleanUpDummyChangeOrder();
        }
        if( newStatus == ChangeOrderServices.STATUS_CANCELED ) {
            undeleteServicesOfChangeOrder( changeOrderId );
        }
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();
        for( ServiceModel sm : currentChangeOrder.serviceModels ) {
            Service_Item__c si = sm.getServiceItem( false );
            sm.status = newStatus;
            sm.internalReviewerForCells = currentChangeOrder.internalReviewerForCells;
            if( ( sm.isAmendmendDeleted && newStatus == ChangeOrderServices.STATUS_APPROVED ) || newStatus == ChangeOrderServices.STATUS_CANCELED ) {
                si.Purchase_Order__c = null;
                sm.serviceItemRecord.Purchase_Order__c = null;
                sm.purchaseOrderNumber = '';
                sm.isAddedToPurchaseOrder = false;
            }
            serviceItems.add( si );
        }

        //MRS-4879, MRS-4434
        if( newStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW ){
            Map<Id, User> czManagersMap = UserServices.getUsersMapByRoleAndRegion(UserServices.ROLE_CZ_MANAGER, proposal.Region__c);
            if( !czManagersMap.isEmpty() ){
                currentChangeOrder.changeOrderRecord.Code_Zoning_Analyst__c = czManagersMap.values()[0].Id;
                currentChangeOrder.changeOrderRecord.Code_Zoning_Analyst_Email__c = czManagersMap.values()[0].Email;
            }
        }

        //MRS-5542
        if( newStatus == ChangeOrderServices.STATUS_REJECTED ){
            currentChangeOrder.changeOrderRecord.Was_Rejected__c = true;
        }

        String oldChangeOrderStatus = currentChangeOrder.status;
        currentChangeOrder.status = newStatus;
        Savepoint sp_changeCOStatus = Database.setSavepoint();
        try {
            if( newStatus == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                UPSERT ProposalWizardServices.uniqueCombinationLastProposalPrice( currentChangeOrder.serviceModels, proposal ).values();
                currentChangeOrder.changeOrderCreatorReminder = dummyChangeOrder.Reminder_for_Creator__c;
                currentChangeOrder.changeOrderRecord.UseDocusign__c = proposal.UseDocusign__c;
                cleanUpDummyChangeOrder();
            }
            saveChangeOrders( changeOrderId );
            UPSERT serviceItems;
            updateAllChangeOrderData();

            Set<Id> serviceItemIds = new Set<Id>();
            for (ServiceModel sm : currentChangeOrder.serviceModels) {
                //If CO status equals Aproved & Original Service Item is deleted with actual status started.
                //BLIs was created for All Task Items but Not All Task Items have status complete. This only works from Mistone project.
                //System.debug(Logginglevel.Error, '!!! changeOrderNewStatus = ' + changeOrderNewStatus + ' this.proposal.Billing_Method__c = ' + this.proposal.Billing_Method__c + ' sm.serviceItemRecord.Original__c = ' + sm.serviceItemRecord.Original__c + ' sm.serviceItemRecord.Is_Amendmend_Deleted__c = ' + sm.serviceItemRecord.Is_Amendmend_Deleted__c);
                if (changeOrderNewStatus.equals(ChangeOrderServices.STATUS_APPROVED) && this.proposal.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODMILESTONE) &&
                    sm.serviceItemRecord.Is_Amendmend_Deleted__c) {
                        serviceItemIds.add(sm.serviceItemRecord.Id);

                }

            }

            if (serviceItemIds.size() > 0) {
                TaskServices.createTasksForARCoordinatorAfterCO(serviceItemIds,
                                                                null != this.proposal.Accounting_Contact_Company__c && null != this.proposal.Accounting_Contact_Company__r.A_R_coordinator__c ?
                                                                new Set<Id> { this.proposal.Accounting_Contact_Company__r.A_R_coordinator__c } :
                                                                CheckServices.staffAccountantUserIds,
                                                                this.proposal.Project_Profile__c);

            }

        } catch ( Exception e ) {
            System.debug(LoggingLevel.ERROR, 'exception ' + String.valueOf(e));
            currentChangeOrder.status = oldChangeOrderStatus;
            Database.rollback( sp_changeCOStatus );
            throw new ErrorException( e.getMessage() );
            return false;
        }
        return true;
    }

    private void undeleteServicesOfChangeOrder ( Id changeOrderId ){
        for( ServiceModel serviceModel: changeOrderModelMap.get(changeOrderId).serviceModels ){
            if( serviceModel.isAmendmendDeleted ){
                undeleteServiceModel( serviceModel );
            }
        }
    }

    public Boolean areThereOnlyDraftCOs { get { return ChangeOrderServices.areThereOnlyDraftCOs( notApprovedChangeOrders ); } }

    public void updateCZAnalystEmailOnChangeOrder(String changeOrderId ){
        if( !changeOrderModelMap.containsKey(changeOrderId) ){
            return;
        }
        Change_Order__c changeOrder = changeOrderModelMap.get(changeOrderId).changeOrderRecord;
        User selectedUser = UserServices.getUserById( changeOrder.Code_Zoning_Analyst__c );

        for( ChangeOrderModel changeOrderModel : changeOrderModelMap.values() ) {
            Boolean isAssignedCZAnalyst = changeOrderModel.isAssignedCZAnalyst();
            for( ServiceModel serviceModel : changeOrderModel.serviceModels ) {
                serviceModel.isAssignedCZAnalyst = isAssignedCZAnalyst;
            }
        }

        try {
            UPSERT new Change_Order__c( id = changeOrder.Id,
                                        Code_Zoning_Analyst__c = changeOrder.Code_Zoning_Analyst__c,
                                        Code_Zoning_Analyst_Email__c = selectedUser != null ? selectedUser.Email : null);
        } catch( Exception ex ) {
            System.debug( LoggingLevel.ERROR, 'exception ' + ex.getMessage() );
        }
    }

    public void updateSIPSCoordinatorOnChangeOrder( String changeOrderId ) {
        if( !changeOrderModelMap.containsKey( changeOrderId ) ) {
            return;
        }
        ChangeOrderModel coModel = changeOrderModelMap.get( changeOrderId );
        Change_Order__c changeOrder = coModel.changeOrderRecord;
        UPSERT new Change_Order__c( Id = changeOrder.Id, SIPS_Coordinator__c = changeOrder.SIPS_Coordinator__c );
        coModel.sipsCoordinatorForCells = changeOrder.SIPS_Coordinator__c;
    }

    public Boolean isSIPSUserInChangeOrder( String changeOrderId, String userProfile, Id currentUserId ){
        if( !changeOrderModelMap.containsKey(changeOrderId) ){
            return false;
        }
        Change_Order__c changeOrder = changeOrderModelMap.get(changeOrderId).changeOrderRecord;

        return ( /*profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||*/
                 ( changeOrder.Status__c == ChangeOrderServices.STATUS_IN_INT_REVIEW &&
                   ( changeOrder.Internal_Reviewer__c == currentUserId &&
                     profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) ) ||
                   ( changeOrder.SIPS_Coordinator__c == currentUserId &&
                     profileName.contains(UserServices.PROFILE_SIPS_COORDINATOR) ) ) );
    }

    /* End Change Order Scope ------------------------------------------------------------------------------------------------------------------------------------- */

    /* Service Scope ---------------------------------------------------------------------------------------------------------------------------------------------- */

    // MRS 7056
    public Boolean hasNonBillabale { set;
        get {
            if( proposal != null && proposal.Status__c != ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT && proposal.Status__c != ProposalServices.PROPOSAL_STATUS_AWARDED ) {
                for( ServiceModel sM : originalChangeOrders[0].serviceModels ) {
                    if(sM.servicePrice <= 0 || (sM.discount == 100 && proposal.Apply_Discount__c)) return true; // MRS 7254
                }
                for( ChangeOrderModel cO : approvedChangeOrders ) {
                    for( ServiceModel sM : cO.serviceModels ) {
                        if(sM.servicePrice <= 0 || (sM.discount == 100 && proposal.Apply_Discount__c)) return true;
                    }
                }
            } 
            return false;
        }
    }
    public Boolean hasNonBillableWithoutReason { set; // MRS 7139
        get {
            //for(ChangeOrderModel cO : originalChangeOrders) {
				for( ServiceModel sM : originalChangeOrders[0].serviceModels ) {
                    if((sM.servicePrice <= 0 || (sM.discount == 100 && proposal.Apply_Discount__c) ) && String.isBlank( sM.serviceItemRecord.Non_Billable_Reason__c )) return true; // MRS 7254
                }
            //}
            for( ChangeOrderModel cO : approvedChangeOrders ) {
				for( ServiceModel sM : cO.serviceModels ) {
                    if((sM.servicePrice <= 0 || (sM.discount == 100 && proposal.Apply_Discount__c) ) && String.isBlank( sM.serviceItemRecord.Non_Billable_Reason__c )) return true;
                }
			}
            return false;
        }
    }

    private void undeleteServiceModel( ServiceModel sm ){
        if( sm.getIsQuantityChangeOrder() ) {
            sm.changeOrderId = sm.changeOrderOldId;
            sm.changeOrderOldId = null;
            sm.quantityStr = sm.quantityOldStr;
            sm.quantityOld = null;
            sm.serviceItemRecord.Change_Order_Old__c = sm.changeOrderOldId;
            sm.serviceItemRecord.Change_Order__c = sm.changeOrderId;
            sm.serviceItemRecord.Quantity_Old__c = sm.quantityOld;
            sm.serviceItemRecord.Quantity__c = sm.quantity;
        } else {
            sm.isAmendmendDeleted = false;
            sm.serviceItemRecord.Is_Amendmend_Deleted__c = false;
            sm.changeOrderId = sm.changeOrderOldId;
            sm.serviceItemRecord.Change_Order__c = sm.changeOrderOldId;
            sm.changeOrderOldId = null;
            sm.serviceItemRecord.Change_Order_Old__c = null;
        }
    }

    public Integer getServiceMaxRowNumberInChangeOrder( String changeOrderId ){
        Integer maxRowNumber = 0;
        if( !changeOrderModelMap.containsKey( changeOrderId ) ) return ++maxRowNumber;
        for( serviceModel sm: changeOrderModelMap.get( changeOrderId ).serviceModels ){
            if( sm.serviceItemRecord.Row_Position__c > maxRowNumber) maxRowNumber = Integer.valueOf(sm.serviceItemRecord.Row_Position__c);
        }
        return ++maxRowNumber;
    }

    public void updateServiceRowPositions( String collectivePositionsData ){
        List<String> changeOrderGroups = collectivePositionsData.split(ProposalWizardServices.CHANGE_ORDER_SPLITTER);
        Map<String, List<String>> changeOrderGroupedData = new Map<String, List<String>>();
        List<String> serviceIdList;
        for(String groupData: changeOrderGroups ){
            List<String> orderAndServices = groupData.split(ProposalWizardServices.CHANGE_ORDER_CONTENT);
            serviceIdList = new List<String>();
            if( orderAndServices.size() > 1 ) {
                for( String serviceId: orderAndServices[1].split(ProposalWizardServices.SERVICE_ITEM_SPLITTER) ){
                    serviceIdList.add( serviceId );
                }
                changeOrderGroupedData.put( orderAndServices[0], serviceIdList );
            }
        }
        for( String changeOrderId: changeOrderGroupedData.keySet() ){
            if( !changeOrderModelMap.containsKey(changeOrderId) ) continue;
            serviceIdList = changeOrderGroupedData.get(changeOrderId);
            for( Integer i = 0; i < serviceIdList.size(); i++){
                for( ServiceModel sm: changeOrderModelMap.get(changeOrderId).serviceModels ){
                    if( sm.recordId == serviceIdList[i] ){
                        sm.rowNumber = i + 1;
                        break;
                    }
                }
            }
        }
    }

    public Boolean removeServiceItems( List<String> serviceItemIds, Id activeChangeOrderId ) {
        //System.debug( LoggingLevel.Error, 'xxx REMOVE SI START ---------: ' );
        Map<Id, ServiceModel> currentServiceModels = serviceModels;
        //System.debug( LoggingLevel.Error, 'xxx serviceModels.keySet(): ' + serviceModels.keySet() );
        //System.debug( LoggingLevel.Error, 'xxx currentServiceModels.keyset(): ' + currentServiceModels.keyset() );
        List<String> serviceItemIdsToChangeQuantity = new List<String>();
        List<String> serviceItemIdsToDelete = new List<String>();
        Boolean result = true;
        for( String serviceItemId : serviceItemIds ) {
            //System.debug( LoggingLevel.Error, 'xxx currentServiceModels.containsKey( serviceItemId ): ' + currentServiceModels.containsKey( serviceItemId ) );
            if( !currentServiceModels.containsKey( serviceItemId ) ) {
                return false;
            }
            if( currentServiceModels.get( serviceItemId ).getIsQuantityChangeOrder() ) {
                serviceItemIdsToChangeQuantity.add( serviceItemId );
            } else {
                serviceItemIdsToDelete.add( serviceItemId );
            }
        }

        //System.debug( LoggingLevel.Error, 'xxx serviceItemIdsToChangeQuantity: ' + serviceItemIdsToChangeQuantity );
        //System.debug( LoggingLevel.Error, 'xxx serviceItemIdsToDelete: ' + serviceItemIdsToDelete );

        result = changeQuantityInServiceModel( null, null, serviceItemIdsToChangeQuantity, activeChangeOrderId, true, true ) && result; //remove service items from CO if pressed on X for services with changed quantity
        //System.debug( LoggingLevel.Error, 'xxx result: ' + result );
        result = deleteServiceItems( serviceItemIdsToDelete, activeChangeOrderId ) && result;
        //System.debug( LoggingLevel.Error, 'xxx result: ' + result );
        if( result == true ) {
            for( ServiceModel sm : serviceModels.values() ) {
                sm.checked = false;
            }
        }
        return result;
    }

    public Boolean deleteServiceItems( List<String> serviceItemIds, Id activeChangeOrderId ) {
        //System.debug( LoggingLevel.Error, 'xxx DELETE SI START ' );

        //System.debug( LoggingLevel.Error, 'xxx serviceItemIds: ' + serviceItemIds );
        if( !serviceItemIds.isEmpty() ) {
            Map<Id, ServiceModel> currentServiceModels = serviceModels;
            List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
            List<Service_Item__c> serviceItemsToDelete = new List<Service_Item__c>();
            List<Id> serviceItemIdsToDelete = new List<Id>();

            for( String serviceItemId : serviceItemIds ) {

                ServiceModel currentServiceModel = currentServiceModels.get( serviceItemId );
                ChangeOrderModel currentChangeOrder = currentServiceModel.changeOrderId == null ? null : changeOrderModelMap.get(currentServiceModel.changeOrderId);
                Service_Item__c currentServiceItem;

                //Delete Service Item
                if( String.isBlank( proposal.Id ) || currentServiceModel.isAlternative ||
                    (  proposal.is_Change_Order__c && currentChangeOrder != null && currentChangeOrder.status != ChangeOrderServices.STATUS_APPROVED && currentServiceModel.activityStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                      !proposal.is_Change_Order__c ) {
                    currentServiceItem = serviceModels.get( serviceItemId ).serviceItemRecord;
                }
                //System.debug( LoggingLevel.Error, 'xxx currentServiceItem: ' + currentServiceItem );
                if( currentServiceItem != null ) {
                    serviceItemsToDelete.add( currentServiceItem );
                    serviceItemIdsToDelete.add( serviceItemId );
                } else {
                    //System.debug( LoggingLevel.Error, 'xxx currentServiceItem 2: ' + currentServiceItem );
                    currentServiceItem = new Service_Item__c( Id = serviceItemId );
                    if( currentChangeOrder != null && currentChangeOrder.status != ChangeOrderServices.STATUS_APPROVED && currentServiceModel.activityStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) {
                        //Undelete Service Item
                        //System.debug(Logginglevel.Error, 'xxx Undelete Service Item');
                        //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
                        //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel.changeOrderOldId);
                        currentServiceModel.isAmendmendDeleted = false;
                        currentServiceModel.changeOrderId = currentServiceModel.changeOrderOldId;
                        currentServiceModel.changeOrderOldId = null;
                    } else if( ( currentChangeOrder == null || currentChangeOrder.status == ChangeOrderServices.STATUS_APPROVED ) && ( currentServiceModel.activityStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED || currentServiceModel.activityStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE) ){
                        //Remove Service Item
                        //System.debug(Logginglevel.Error, 'xxx Remove Service Item');
                        //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
                        currentServiceModel.isAmendmendDeleted = true;
                        currentServiceModel.changeOrderOldId = currentServiceModel.changeOrderId;
                        currentServiceModel.changeOrderId = activeChangeOrderId;
                    }
                    currentServiceItem.Is_Amendmend_Deleted__c = currentServiceModel.isAmendmendDeleted;
                    currentServiceItem.Change_Order__c = currentServiceModel.changeOrderId;
                    currentServiceItem.Change_Order_Old__c = currentServiceModel.changeOrderOldId;
                    serviceItemsToUpdate.add( currentServiceItem );
                }
            }
            //System.debug(Logginglevel.Error, 'xxx serviceItemsToUpdate: ' + serviceItemsToUpdate);
            //System.debug(Logginglevel.Error, 'xxx serviceItemsToDelete: ' + serviceItemsToDelete);
            try {
                if( !serviceItemsToUpdate.isEmpty() ) {
                    UPDATE serviceItemsToUpdate;
                }
                if( !serviceItemsToDelete.isEmpty() ) {
                    DELETE serviceItemsToDelete;
                    for( Id serviceItemIdToDelete : serviceItemIdsToDelete ) {
                        currentServiceModels.remove( serviceItemIdToDelete );
                    }
                }
                serviceModels = currentServiceModels;
            } catch( Exception e ) {
                return false;
            }
        }
        return true;
    }

    public Boolean isQuantityChangeNeedsConfirmation( String newQuantityString, String oldQuantityString, String serviceItemId, Boolean isDiff ) {
        Decimal newQuantity;
        try {
            newQuantity = Decimal.valueOf( newQuantityString );
            AggregateResult ar = [ SELECT SUM(Quantity__c) FROM Billing_Line_Item__c WHERE Service_Item__c = : serviceItemId AND IsReimbursable__c = false ][0];
            if( ar.get('expr0') != null ) {
                Decimal billedQuantity = (Decimal)ar.get('expr0');
                if( serviceModels.containsKey( serviceItemId ) ) {
                    if( isDiff ) {
                        return billedQuantity > serviceModels.get( serviceItemId ).quantityOld - Decimal.valueOf( newQuantityString );
                    } else {
                        return billedQuantity > Decimal.valueOf( newQuantityString );
                    }
                }
            }
        } catch( exception ex ) {
            cancelQuantityChangeInServiceModel( oldQuantityString, serviceItemId, isDiff );
            throw new ErrorException( 'Wrong quantity was entered for service ' + serviceModels.get( serviceItemId ).serviceItemRecord.Name );
            return false;
        }
        return false;
    }

    public void cancelQuantityChangeInServiceModel( String oldQuantityString, String serviceItemId, Boolean isDiff ) {
        if( serviceModels.containsKey( serviceItemId ) ) {
            if( isDiff ) {
                serviceModels.get( serviceItemId ).quantityDiffStr = oldQuantityString;
            } else {
                serviceModels.get( serviceItemId ).quantityStr = oldQuantityString;
            }
        }
    }

    public Boolean changeQuantityInServiceModel( String newQuantityString, String oldQuantityString, List<String> serviceItemIds, Id activeChangeOrderId, Boolean isDiff ) {
        return changeQuantityInServiceModel( newQuantityString, oldQuantityString, serviceItemIds, activeChangeOrderId, isDiff, false );
    }

    public Boolean changeQuantityInServiceModel( String newQuantityString, String oldQuantityString, List<String> serviceItemIds, Id activeChangeOrderId, Boolean isDiff, Boolean isDelete ) { //serviceItemId
        //System.debug(LoggingLevel.Error, 'xxx ---------------- changeQuantityInServiceModel ------------------- ');
        //isDiff is used to specify what values are passed in the newQuantityString and oldQuantityString
        //new quantity / old quantity (false) or
        //new removed services number / old removed services number (true)

        //TODO KDI 07.05.2014: remove debugs if everything is OK!!!

        //system.debug(LoggingLevel.Error, 'xxx newQuantityString: ' + newQuantityString);
        //system.debug(LoggingLevel.Error, 'xxx oldQuantityString: ' + oldQuantityString);
        //system.debug(LoggingLevel.Error, 'xxx serviceItemId: ' + serviceItemId);
        //system.debug(LoggingLevel.Error, 'xxx activeChangeOrderId: ' + activeChangeOrderId);
        //system.debug(LoggingLevel.Error, 'xxx isDiff: ' + isDiff);


        //System.debug( LoggingLevel.Error, 'xxx serviceItemIds: ' + serviceItemIds );
        if( !serviceItemIds.isEmpty() ) {
            Map<Id, ServiceModel> currentServiceModels = serviceModels;
            List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();

            for( String serviceItemId : serviceItemIds ) {
                if( !currentServiceModels.containsKey( serviceItemId ) ) {
                    return false;
                }

                ServiceModel currentServiceModel = currentServiceModels.get( serviceItemId );
                ChangeOrderModel currentChangeOrder = currentServiceModel.changeOrderId == null ? null : changeOrderModelMap.get(currentServiceModel.changeOrderId);
                Service_Item__c currentServiceItem = new Service_Item__c( Id = serviceItemId );

                if( isDelete ) {
                    //Remove Service Item from CO ( quantity CO )
                    //System.debug(Logginglevel.Error, 'xxx Remove Service Item from CO ( quantity CO )');
                    //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
                    currentServiceModel.changeOrderId = currentServiceModel.changeOrderOldId;
                    currentServiceModel.changeOrderOldId = null;
                    currentServiceModel.quantityStr = currentServiceModel.quantityOldStr;
                    currentServiceModel.quantityOld = null;
                    currentServiceItem.Change_Order_Old__c = currentServiceModel.changeOrderOldId;
                    currentServiceItem.Change_Order__c = currentServiceModel.changeOrderId;
                    currentServiceItem.Quantity_Old__c = currentServiceModel.quantityOld;
                    currentServiceItem.Quantity__c = currentServiceModel.quantity;
                    serviceItemsToUpdate.add( currentServiceItem );
                    //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
                } else {
                    Decimal newQuantity;
                    try {
                        newQuantity = Decimal.valueOf( newQuantityString ).setScale(2);
                    } catch( exception ex ) {
                        if( !isDiff ) {
                            currentServiceModel.quantityStr = oldQuantityString;
                        } else {
                            currentServiceModel.quantityDiffStr = oldQuantityString;
                        }
                        throw new ErrorException( 'Wrong quantity was entered for service ' + currentServiceModel.serviceItemRecord.Name );
                        return false;
                    }

                    //System.debug(LoggingLevel.Error, 'xxx ----------------: ');
                    //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityOldStr: ' + currentServiceModel.quantityOldStr);
                    //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityStr: ' + currentServiceModel.quantityStr);
                    //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.changeOrderOldId: ' + currentServiceModel.changeOrderOldId);
                    //System.debug(LoggingLevel.Error, 'xxx proposal.is_Change_Order__c: ' + proposal.is_Change_Order__c);
                    //System.debug(LoggingLevel.Error, 'xxx ----------------: ');

                    //prevent user to change quantity to a value <= 0 to more than quantity in service if this service was approved
                    if( proposal.is_Change_Order__c &&
                        !isDiff &&
                        String.isEmpty(currentServiceModel.changeOrderOldId) &&
                        ( newQuantity > Decimal.valueOf(oldQuantityString).setScale(2) ||
                          newQuantity <= 0 ) &&
                        ( ( currentChangeOrder != null &&
                            ( currentChangeOrder.isOriginal ||
                              currentChangeOrder.isAlternative ||
                              currentChangeOrder.status == ChangeOrderServices.STATUS_APPROVED ) ) ||
                          ( currentChangeOrder == null ) ) ) {
                        //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityStr: ' + currentServiceModel.quantityStr);
                        currentServiceModel.quantityStr = oldQuantityString;
                        //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityStr: ' + currentServiceModel.quantityStr);
                        continue;
                    }

                    //prevent user to change quantity in quantity CO value >= than service quantity or < 0
                    if( proposal.is_Change_Order__c &&
                        isDiff &&
                        currentServiceModel.changeOrderId != currentServiceModel.changeOrderOldId &&
                        ( currentChangeOrder != null &&
                          currentChangeOrder.status != ChangeOrderServices.STATUS_APPROVED ) &&
                        ( ( newQuantity >= currentServiceModel.quantityOld ) ||
                          ( newQuantity <= 0 ) ) ) {
                        //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityStr: ' + currentServiceModel.quantityStr);
                        currentServiceModel.quantityDiffStr = oldQuantityString;
                        //System.debug(LoggingLevel.Error, 'xxx currentServiceModel.quantityStr: ' + currentServiceModel.quantityStr);
                        continue;
                    }

                    //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
                    //System.debug(Logginglevel.Error, 'xxx currentServiceModel.quantity: ' + currentServiceModel.quantity);
                    //System.debug(Logginglevel.Error, 'xxx newQuantityString: ' + newQuantityString);
                    //System.debug(Logginglevel.Error, 'xxx oldQuantityString: ' + oldQuantityString);

                    if( ( String.isBlank( proposal.Id ) ) ||
                        ( currentServiceModel.isAlternative ) ||
                        ( !proposal.is_Change_Order__c ) ||
                        ( ( proposal.is_Change_Order__c && !isDiff && currentServiceModel.quantityOld == 0 ) &&
                          ( currentChangeOrder != null && currentChangeOrder.status != ChangeOrderServices.STATUS_APPROVED ) ) ) {
                        //Change quantity for ordinary service ( not quantity CO )
                        //System.debug( Logginglevel.Error, 'xxx Change quantity for ordinary service ( not quantity CO )' );
                        currentServiceModel.quantityStr = newQuantityString;
                        currentServiceItem.Quantity__c = currentServiceModel.quantity;
                        serviceItemsToUpdate.add( currentServiceItem );
                    } else if( ( !isDiff ) &&
                               ( currentChangeOrder == null || currentChangeOrder.status == ChangeOrderServices.STATUS_APPROVED ) ) {
                        //Put service to new co ( create quantity change for service )
                        //System.debug(Logginglevel.Error, 'Put service to new co ( create quantity change for service )');
                        currentServiceModel.changeOrderOldId = currentServiceModel.changeOrderId;
                        currentServiceModel.changeOrderId = activeChangeOrderId;
                        currentServiceModel.quantityOldStr = oldQuantityString;
                        currentServiceModel.quantityStr = newQuantityString;
                        currentServiceItem.Change_Order_Old__c = currentServiceModel.changeOrderOldId;
                        currentServiceItem.Change_Order__c = currentServiceModel.changeOrderId;
                        currentServiceItem.Quantity_Old__c = currentServiceModel.quantityOld;
                        currentServiceItem.Quantity__c = currentServiceModel.quantity;
                        serviceItemsToUpdate.add( currentServiceItem );
                    }
                }
            }

            //System.debug(Logginglevel.Error, 'xxx currentServiceModel: ' + currentServiceModel);
            try {
                if( !serviceItemsToUpdate.isEmpty() ) {
                    UPDATE serviceItemsToUpdate;
                }
                serviceModels = currentServiceModels;
            } catch( Exception e ) {
                throw new ErrorException( 'Can not update service: ' + e.getMessage() );
                return false;
            }
        }
        return true;
    }

    public void updateServiceClientPrices(Id billingCompanyId){
        if( serviceModels.isEmpty() ) return;
        Set<Id> serviceTemplatesIds = new Set<Id>();
        for( ServiceModel serviceModel: serviceModels.values() ){
            serviceTemplatesIds.add( serviceModel.serviceItemRecord.Service_Template__c );
            serviceModel.priceRecord = null;
            serviceModel.lastProposalPriceId = null;
            serviceModel.lastProposalPrice = null;
            serviceModel.lastProposalId = null;
        }
        if( String.isBlank(billingCompanyId) ) return;
        Map<Id, Client_Price__c> serviceTemplateToClientPriceMap = ProposalWizardServices.getServiceIdToClientPrice( serviceTemplatesIds, billingCompanyId );
        Map<Id, Last_Proposal_Price__c> serviceTemplateToLastProposalPriceMap = ProposalWizardServices.getServiceIdToLastProposalPrice( serviceTemplatesIds, billingCompanyId );
        for( ServiceModel serviceModel: serviceModels.values() ){
            serviceModel.priceRecord = serviceTemplateToClientPriceMap.get(serviceModel.serviceItemRecord.Service_Template__c);

            if( serviceTemplateToLastProposalPriceMap.containsKey(serviceModel.serviceItemRecord.Service_Template__c) ) {
                serviceModel.lastProposalPriceId = serviceTemplateToLastProposalPriceMap.get(serviceModel.serviceItemRecord.Service_Template__c).Id;
                serviceModel.lastProposalPrice = serviceTemplateToLastProposalPriceMap.get(serviceModel.serviceItemRecord.Service_Template__c).Last_Proposed_Price__c;
                serviceModel.lastProposalId = serviceTemplateToLastProposalPriceMap.get(serviceModel.serviceItemRecord.Service_Template__c).Last_Proposal__c;
            }
        }
    }

    public void manageServiceFloorJunctions( String serviceIdsForMultiAction, String selectedServiceFloorIds, String partialServiceFloorIds, List<FloorWrapper> existingFloors ) {
        if( String.isEmpty( serviceIdsForMultiAction ) ) {
            return;
        }
        if( String.isEmpty( selectedServiceFloorIds ) && String.isEmpty( partialServiceFloorIds ) ) {
            throw new ErrorException( ProposalWizardServices.SERVICE_JUNCTIONS_SHOULD_BE_POPULATED_MESSAGE );
        }

        //existing floor wrappers
        Map<Id, FloorWrapper> floorIdToFloorWrapper = new Map<Id, FloorWrapper>();
        for( FloorWrapper floorWrapperItem : existingFloors ) {
            floorIdToFloorWrapper.put( floorWrapperItem.floorId, floorWrapperItem );
        }

        //ids in selectedServiceFloorIds mean that these floors were previously selected for all selected services, or they were not chosen previously, but were selected on the page
        Set<String> selectedFloorIds = new Set<String>();
        if( !String.isEmpty( selectedServiceFloorIds ) ) {
            selectedFloorIds.addAll( selectedServiceFloorIds.split(';', 0) );
        }

        //ids in partialServiceFloorIds mean that these floors are populated just for some of the selected services, but there was no action for them on the page -> just leave the junctions for such floors without change
        Set<String> partialFloorIds = new Set<String>();
        if( !String.isEmpty( partialServiceFloorIds ) ) {
            partialFloorIds.addAll( partialServiceFloorIds.split(';', 0) );
        }

        //affected service Item Ids (for which floors are changed)
        Set<String> affectedServiceIds = new Set<String>( serviceIdsForMultiAction.split(';', 0) );

        List<Service_Floor_Junction__c> junctionsToInsert = new List<Service_Floor_Junction__c>();
        List<Service_Floor_Junction__c> junctionsToDelete = new List<Service_Floor_Junction__c>();
        Map<Id, Set<Id>> serviceIdToExistingFloors = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> serviceIdToPartialFloorIds = new Map<Id, Set<Id>>();

        //leave partially selected floors unchanged, delete unneeded junctions, create a map for existing and selected junctions
        for( Service_Floor_Junction__c junction : [ SELECT Id, Floor__c, Service_Item__c
                                                    FROM Service_Floor_Junction__c
                                                    WHERE Service_Item__c IN : affectedServiceIds ] ) {

            if( partialFloorIds.contains( junction.Floor__c ) ) {
                if( !serviceIdToPartialFloorIds.containsKey( junction.Service_Item__c ) ) {
                    serviceIdToPartialFloorIds.put( junction.Service_Item__c, new Set<Id>() );
                }
                serviceIdToPartialFloorIds.get( junction.Service_Item__c ).add( junction.Floor__c );
            } else if( selectedFloorIds.contains( junction.Floor__c ) ) {
                if( !serviceIdToExistingFloors.containsKey( junction.Service_Item__c ) ) {
                    serviceIdToExistingFloors.put( junction.Service_Item__c, new Set<Id>() );
                }
                serviceIdToExistingFloors.get( junction.Service_Item__c ).add( junction.Floor__c );
            } else {
                junctionsToDelete.add( junction );
            }
        }

        //populate the map for creating floors string; add missing junctions
        List<Service_Item__c> servicesToUpdate = new List<Service_Item__c>();
        for( String serviceItemId : affectedServiceIds ) {
            Set<Id> floorIdsForFloorsString = new Set<Id>();
            for( Id selectedFloorId : selectedFloorIds ) { //add all floors that are selected on page for string creation; create junctions for them if they don't exist already
                floorIdsForFloorsString.add( selectedFloorId );
                if( !serviceIdToExistingFloors.containsKey( selectedFloorId ) || !serviceIdToExistingFloors.get( selectedFloorId ).contains( selectedFloorId ) ) {
                    junctionsToInsert.add( new Service_Floor_Junction__c( Service_Item__c = serviceItemId, Floor__c = selectedFloorId ) );
                }
            }
            if( serviceIdToPartialFloorIds.containsKey( serviceItemId ) ) { //add all floors that are partially selected (and did not change on page)
                floorIdsForFloorsString.addAll( serviceIdToPartialFloorIds.get( serviceItemId ) );
            }
            if( floorIdsForFloorsString.isEmpty() ) {
                throw new ErrorException( ProposalWizardServices.SERVICE_JUNCTIONS_SHOULD_BE_POPULATED_MESSAGE );
            }
            List<FloorWrapper> floorsForService = new List<FloorWrapper>();
            for( Id floorId : floorIdsForFloorsString ) {
                floorsForService.add( floorIdToFloorWrapper.get( floorId ) );
            }
            servicesToUpdate.add( new Service_Item__c( Id = serviceItemId, Floor__c = FloorServices.createFloorsString( floorsForService, false ) ) );
        }
        try {
            UPDATE servicesToUpdate;
            DELETE junctionsToDelete;
            INSERT junctionsToInsert;
            for( ServiceModel sm : serviceModels.values() ) {
                sm.checked = false;
            }
        } catch( Exception ex ) {
            throw new ErrorException( 'Error assigning Services to Floors: ' + ex.getMessage() );
        }
    }

    public static void updateServicesAndJunctions( List<FloorWrapper> floors, List<ServiceModel> serviceModelsToUpdate, Proposal__c proposal, Boolean isFromAddRemoveFloorFunctionality ) {
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        for( ServiceModel sm : serviceModelsToUpdate ) {
            if( !sm.IsAlternative ) {
                serviceItemsToUpdate.add( new Service_Item__c( Id = sm.recordId ) );
            }
        }
        updateServicesAndJunctions( floors, serviceItemsToUpdate, proposal, isFromAddRemoveFloorFunctionality );
    }

    public static void updateServicesAndJunctions( List<FloorWrapper> floors, List<Service_Item__c> serviceItemsToUpdate, Proposal__c proposal, Boolean isFromAddRemoveFloorFunctionality ) {
        Map<Id, Service_Item__c> serviceMap = new Map<Id, Service_Item__c>();
        List<Service_Floor_Junction__c> junctionsToInsert = new List<Service_Floor_Junction__c>();
        List<Service_Floor_Junction__c> junctionsToDelete = new List<Service_Floor_Junction__c>();
        String floorsString = FloorServices.createFloorsString(floors, false);

        if( isFromAddRemoveFloorFunctionality ) {
            if( !proposal.Is_Floors_To_Services__c ) {
                for( Service_Item__c si : serviceItemsToUpdate ) {
                    Service_Item__c serviceItem = new Service_Item__c( Id = si.Id, Floor__c = floorsString );
                    serviceMap.put( si.Id, serviceItem );
                }
            }
        } else {
            for( Service_Item__c si : serviceItemsToUpdate ) {
                Service_Item__c serviceItem = new Service_Item__c( Id = si.Id, Floor__c = floorsString );
                if( proposal.Is_Floors_To_Services__c ) {
                    for( FloorWrapper floorWrapperItem : floors ) {
                        junctionsToInsert.add( new Service_Floor_Junction__c( Service_Item__c = si.Id, Floor__c = floorWrapperItem.floorId) );
                    }
                    serviceItem.Junctions_Created__c = true;
                }else{
                    serviceItem.Junctions_Created__c = false;
                }
                serviceMap.put(si.Id, serviceItem);
            }

            if( !proposal.Is_Floors_To_Services__c ) {
                junctionsToDelete = new List<Service_Floor_Junction__c>([SELECT Id, Floor__c from Service_Floor_Junction__c WHERE Service_Item__c =: serviceMap.keySet()]);
            }
        }
        try {
            UPSERT serviceMap.values();
        } catch( Exception ex ) {
            throw new ErrorException( 'Error Updating Service for Floors Junctions.' );
        }
        try {
            UPSERT new Proposal__c( Id = proposal.Id, Is_Floors_To_Services__c = proposal.Is_Floors_To_Services__c, Floor_s__c = proposal.Floor_s__c );
        } catch( Exception ex ) {
            throw new ErrorException( 'Error Updating Proposal.' );
        }
        try {
            DELETE junctionsToDelete;
        } catch( Exception ex ) {
            throw new ErrorException( 'Error Deleting Service to Floors Junctions.' );
        }
        try {
            UPSERT junctionsToInsert;
        } catch( Exception ex ) {
            throw new ErrorException( 'Error Inserting Service to Floors Junctions.' );
        }
    }

    @future
    public static void updateRestOfServiceAndJunctions( Id proposalId){
        Proposal__c proposal;
        try {
            proposal = [SELECT id, Is_Floors_To_Services__c, Floor_s__c FROM Proposal__c WHERE id =: proposalId];
        } catch ( Exception ex ){
            return;
        }
        List<FloorWrapper> floorWrapperList = new List<FloorWrapper>();
        for( Floor__c floor : [ SELECT Id, Floor_Type__c, Floor_Number__c, Specification_Name__c, Proposal__c, Tenant_Type__c, Tenant_Number__c, Specification_Tenant_Name__c, Floor_is_shown__c /* MRS 7109 */
                              FROM Floor__c
                              WHERE Proposal__c = : proposalId ] ) {
            floorWrapperList.add( new FloorWrapper( floor ) );
        }
        List<Service_Item__c> serviceItemsToProcess = new List<Service_Item__c>([SELECT Id FROM Service_Item__c WHERE Proposal__c =: proposalId AND Junctions_Created__c =: false]);
        if( !serviceItemsToProcess.isEmpty() && !floorWrapperList.isEmpty() ){
            updateServicesAndJunctions( floorWrapperList, serviceItemsToProcess, proposal, false );
        }
    }

    public Boolean checkIfAllServicesAreConnectedToFloors( Id proposalId){
        for( Service_Item__c si: [SELECT Id, Floor_Concatenated__c FROM Service_Item__c WHERE Proposal__c =: proposalId AND Is_Alternative__c =: false]){
            if( String.isEmpty(si.Floor_Concatenated__c) ) return false;
        }
        return true;
    }

    public void removeFloorAndServiceJunctions( Id floorId ){
        Map<Id, Service_Floor_Junction__c> floorJunctions = new Map<Id, Service_Floor_Junction__c>([SELECT Id, Floor__c, Service_Item__c
                                                                                                    FROM Service_Floor_Junction__c
                                                                                                    WHERE Floor__c =: floorId
                                                                                                    AND Service_Item__c IN: serviceModels.keySet()]);
        if( !floorJunctions.isEmpty() ){
            throw new ErrorException( 'Can not remove floor if there are services attached to it. Please reassign services from this floor on Step 3 and try to delete it again.' );
        }

        Savepoint sp = Database.setSavePoint();
        try {
            DELETE floorJunctions.values();
        } catch (DMLException ex){
            throw new ErrorException( 'Error Deleting Service to Floors Junctions.' );
        }

        try {
            DELETE new Floor__c( Id = floorId );
        } catch (DMLException ex){
            Database.rollback( sp );
            throw new ErrorException( 'Error Deleting Floor.' );
        }

    }
    /* End Service Scope ---------------------------------------------------------------------------------------------------------------------------------------------- */

    public Boolean isServiceModelValidForBundle( ServiceModel sm, Id changeOrderId, String virtualChangeOrderName,Boolean isSIPSUser ){
        Boolean status = false;
        if( !sm.isAmendmendDeleted && (this.profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || !isSIPSUser || sm.getIsSIPSService()) ){
            if( !String.isBlank(changeOrderId) && sm.changeOrderId == changeOrderId ){
                status = true;
            }else if( virtualChangeOrderName == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && sm.isOriginal && !sm.isAlternative ){
                status = true;
            }else if(  virtualChangeOrderName == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && sm.isAlternative ){
                status = true;
            }
        }

        return status;
    }

    public Boolean saveServiceBundle( Id changeOrderId, String serviceBundleName, String virtualChangeOrderName, String region, Boolean isSIPSUser ) {
        List<Service_Bundle_Item__c> sbiToCreate = new List<Service_Bundle_Item__c>();
        if( !String.isBlank(serviceBundleName) ) {
            Service_Bundle__c sbToCreate = new Service_Bundle__c( Bundle_Name__c = serviceBundleName, Region__c = region );
            Savepoint sp_saveServiceBundle = Database.setSavepoint();
            //We need it because some field have been removed from main select duering view state optimisation
            Map<Id, Service_Item__c> servicesFromDB = new Map<Id, Service_Item__c>( [ SELECT Work_Type__c, Category__c, Type__c,
                                                                                             Subtype__c, RecordType.Name
                                                                                      FROM Service_Item__c
                                                                                      WHERE Id IN : serviceModels.keySet() ] );
            try {
                UPSERT sbToCreate;

                List<Integer> rowPositions = new List<Integer>();
                for( ServiceModel sm : serviceModels.values() ) {
                    if( isServiceModelValidForBundle(sm, changeOrderId, virtualChangeOrderName, isSIPSUser) ) {
                        rowPositions.add(sm.rowNumber);
                    }
                }
                rowPositions.sort();
                Map<Integer, Integer> rowPositionsMap = new Map<Integer, Integer>();
                Integer normalizedPosition = 0;
                for( Integer positionItem : rowPositions ) {
                    rowPositionsMap.put( positionItem, ++normalizedPosition );
                }

                for( Id serviceItemId : serviceModels.keySet() ) {
                    ServiceModel sm = serviceModels.get( serviceItemId );
                    Service_Item__c si = servicesFromDB.get( serviceItemId );
                    if( isServiceModelValidForBundle( sm, changeOrderId, virtualChangeOrderName, isSIPSUser ) ) {
                        sbiToCreate.add( new Service_Bundle_Item__c( Quantity__c = sm.Quantity,
                                                                     Row_Position__c = rowPositionsMap.get( sm.rowNumber ),
                                                                     Service__c = sm.serviceItemRecord.Service_Template__c,
                                                                     Service_Bundle__c = sbToCreate.Id,
                                                                     Service_Group_Key__c = sm.serviceItemRecord.Service_Group_Key__c,
                                                                     Work_Type__c = ProposalWizardServices.isCustomWorkTypeService( si.Category__c,
                                                                                                                                    si.Type__c,
                                                                                                                                    si.RecordType.Name == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME )
                                                                                    ? si.Work_Type__c
                                                                                    : null ) );
                    }
                }
                if ( !sbiToCreate.isEmpty() ) {
                    UPSERT sbiToCreate;
                    return true;
                } else {
                    Database.rollback(sp_saveServiceBundle);
                }
            } catch(Exception ex) {
                Database.rollback(sp_saveServiceBundle);
                return false;
            }
        }
        return true;
    }

    public List<Service_Bundle__c> getServiceBundles( String municipalityName ){
        String query = 'SELECT Bundle_Name__c, allUsersVisible__c, Region__c FROM Service_Bundle__c WHERE Region__c = ';
        query += '\'' + municipalityName + '\'' + ' ';
        if( this.profileName != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) {
            query += 'AND (OwnerID = ' + '\'' + UserInfo.getUserId() + '\'' + ' ' + 'OR allUsersVisible__c = true) ';
        }
        query += 'ORDER BY Bundle_Name__c ASC LIMIT 1000'; // MRS 7168

        return new List<Service_Bundle__c>( (List<Service_Bundle__c>)Database.query(query) );
    }

    public List<Service_Bundle__c> getServiceBundle( Id bundleId ) {
        if( !String.isEmpty( bundleId ) ) {
            return [ SELECT Bundle_Name__c, allUsersVisible__c, Region__c FROM Service_Bundle__c WHERE Id = : bundleId ];
        }
        return new List<Service_Bundle__c>();
    }

    public List<DocumentWrapper> documentWrapperList { get; set; }
    public void populateDocumentWrapperList( Proposal__c proposalItem ) {
        List<DocumentWrapper> documentWrapperList = new List<DocumentWrapper>();
        for( Document document: ProposalWizardServices.getDocumentsFromDirectory() ){
            DocumentWrapper docWrapper = new DocumentWrapper(document);
            docWrapper.isAttached = proposalItem.RFP_Attachments__c != null && proposalItem.RFP_Attachments__c.contains(document.Id);
            documentWrapperList.add( docWrapper );
        }
        this.documentWrapperList = documentWrapperList;
    }

    public void updateIsChangeOrderAllowedOnProjectOrServiceItemLevel( Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        this.isChangeOrderAllowedOnProjectOrServiceItemLevel = isChangeOrderAllowedOnProjectOrServiceItemLevel;
        for( ChangeOrderModel com : changeOrderModelMap.values() ) {
            com.updateIsChangeOrderAllowedOnProjectOrServiceItemLevel( isChangeOrderAllowedOnProjectOrServiceItemLevel );
        }
    }

    public void updateIsUserInRoster( Boolean isUserInRoster ) {
        this.isUserInRoster = isUserInRoster;
        for( ChangeOrderModel com : changeOrderModelMap.values() ) {
            com.updateIsUserInRoster( isUserInRoster );
        }
    }

}