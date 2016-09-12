public with sharing class ChangeOrderServices {
    public static final String CHANGE_ORDER_OBJECT_API_NAME = 'Change_Order__c';

    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_REQUESTED = 'Change Order Requested';
    public static final String STATUS_IN_CZ_REVIEW = 'In C&Z Scope Review';
    public static final String STATUS_CZ_REVIEW_COMPLETE = 'C&Z Scope Review Complete';
    public static final String STATUS_IN_INT_REVIEW = 'In Internal Review';
    public static final String STATUS_PASSED_INT_REVIEW = 'Passed Internal Review';
    public static final String STATUS_FAILED_INT_REVIEW = 'Failed Internal Review';
    public static final String STATUS_PENDING_CLIENT = 'Pending Client Approval';
    public static final String STATUS_APPROVED = 'Change Order Approved';
    public static final String STATUS_REJECTED = 'Change Order Rejected';
    public static final String STATUS_CANCELED = 'Canceled';

    public static final String SERVICES_SUBTOTAL_TITLE = 'Subtotal';
    public static final String SERVICES_DISCOUNT_TITLE = 'Discount';
    public static final String SERVICES_SALES_TAX_TITLE = 'Sales Tax';
    public static final String SERVICES_REIMBURSABLE_COSTS_TITLE = 'Reimbursable Costs';
    public static final String SERVICES_COST_OF_SERVICES_TITLE = 'Cost Of Services';

    public static final Double VERSION_SUB_STEP = 0.0001;
    public static final Double VERSION_MINOR_STEP = 0.01;
    public static final Double VERSION_MAJOR_STEP = 1;

    public static final String ORIGINAL_CHANGE_ORDER = 'Original';
    public static final String ALTERNATIVE_CHANGE_ORDER = 'Alternative';

    public static final Map<String, String> PROPOSAL_FIELDS_TO_COMPARE_MAP = new Map<String, String>{ 'Expected Construction Cost' => 'Expected_Construction_Cost__c',
                                                                                                      'Expected Construction Start Date' => 'Expected_Construction_Start_Date__c' };
    public static final Map<String, String> PROPOSAL_SERVICES_FIELDS_TO_COMPARE_MAP = new Map<String, String>{ 'Unit Price' => 'Unit_Price__c',
                                                                                                               'Quantity' => 'Quantity__c' };
    private static final String SERVICE_STATUS_ADDED = 'Added';
    private static final String SERVICE_STATUS_REMOVED = 'Removed';
    private static final String SERVICE_STATUS_UPDATED = 'Updated';
    public static final String PROPOSAL_FIELD_CLIENT_NAME_LABEL = 'Client Name';
    public static final String PROPOSAL_FIELD_PROJECT_NAME_LABEL = 'Project Name';
    public static final String PROPOSAL_FIELD_VERSION_LABEL = 'Version';
    public static final String PROPOSAL_FIELD_LAST_MODIFIED_LABEL = 'Last Modified';

    public static final String DOB_VARIANCE_FEES_PROJECTED = 'DOB Variance Fees (Determined)'; //G300 MRS-6819

    public static final String CO_DOCUMENT_TYPE_LIGHT = 'Light';
    public static final String CO_DOCUMENT_TYPE_FULL = 'Full';

    public static String changeOrderPrefix { get { if( changeOrderPrefix == null ) changeOrderPrefix = Change_Order__c.sObjectType.getDescribe().getKeyPrefix(); return changeOrderPrefix; } private set; }

    public static Map<String, List<String>> proposalFieldsDiff = new Map<String, List<String>>(); /* Map{proposalFiedName, <oldValue, newValue>} */
    public static Map<Id, String> servicesStatus = new Map<Id, String>(); /* Map{ServiceId, [Added/Removed/Updated]} */
    public static Map<Id, String> servicesIdToName = new Map<Id, String>(); /* Map{ServiceId, SeviceName} */
    public static Map<Id, Map<String, List<String>>> servicesFieldsDiff = new Map<Id, Map<String, List<String>>>();/* Map{ServiceId, {serviceFieldName,<oldValue, newValue>}} */
    public static Map<Id, Map<String, String>> proposalsGeneralData = new Map<Id, Map<String, String>>(); /* Map{ProposalId, {fieldLabel, value}} */

    @TestVisible private static SObject prepareProposalData( Id proposalId, Boolean isProposalHistorical )
    {
        SObject proposal;
        if( isProposalHistorical ){
            proposal = [SELECT Id, Expected_Construction_Cost__c, Expected_Construction_Start_Date__c, Version__c, Primary_Company_Contact__r.Name, Project_Name__c, LastModifiedDate,
                                (SELECT Id, Unit_Price__c, Service_Item__c, Quantity__c FROM Services_Historical__r)
                        FROM Proposal_Historical__c p
                        WHERE Id=: proposalId LIMIT 1];
        }else{
            proposal = [SELECT Id, Expected_Construction_Cost__c, Expected_Construction_Start_Date__c, Version_Text__c, Primary_Company_Contact__r.Name, Project_Name__c, LastModifiedDate,
                                    (SELECT Id, Name, Unit_Price__c, Quantity__c FROM Service_Items__r)
                        FROM Proposal__c p
                        WHERE Id=: proposalId LIMIT 1] ;
        }

        return proposal;
    }


    /*
    * Store Proposal general data in proposalsGeneralData map
    */
    @TestVisible private static void prepareProposalGeneralData( List<sObject> proposalList )
    {
        for( sObject proposal: proposalList ){
            Contact contact = (Contact)proposal.getSObject('Primary_Company_Contact__r');
            proposalsGeneralData.put( proposal.Id, new Map<String, String>{PROPOSAL_FIELD_CLIENT_NAME_LABEL => ( contact == null ) ? null : contact.Name,
                                                                                PROPOSAL_FIELD_PROJECT_NAME_LABEL => String.valueOf(proposal.get('Project_Name__c')),
                                                                                PROPOSAL_FIELD_VERSION_LABEL => String.valueOf(proposal.get('Version_Text__c')),
                                                                                PROPOSAL_FIELD_LAST_MODIFIED_LABEL => String.valueOf(proposal.get('LastModifiedDate'))});
        }
    }

    public static Map<Id, Proposal__c> getProposalsFromChangeOrders( List<Change_Order__c> changeOrders ) {
        Set<Id> proposalIdsFromChangeOrders = new Set<Id>();
        for( Change_Order__c changeOrderItem : changeOrders ) {
            proposalIdsFromChangeOrders.add( changeOrderItem.Proposal__c );
        }
        proposalIdsFromChangeOrders.remove( null );
        return new Map<Id, Proposal__c>( [ SELECT Project_Profile__c, Project_Team__c, Project_Profile__r.OwnerId, Region__c, Project_Profile__r.Name, Project_Profile__r.Project_Address__c,
                                                  Project_Profile__r.Project_Member__c, Project_Profile__r.Project_Manager__c, Project_Profile__r.Production_Manager__c, //MRS-6618
                                                  Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c, Project_Profile__r.Account_Executive__c, Account_Executive__c,
                                                  Project_Profile__r.Total_Service_Amount__c, FREP__c, Total_Service_Amount__c,
                                                  Discounted_Total_Service_Amount__c, Project_Profile__r.Discounted_Total_Service_Amount__c,  Project_Profile__r.Project_Status__c, Project_Profile__r.Pre_billed__c
                                           FROM Proposal__c
                                           WHERE Id IN : proposalIdsFromChangeOrders ] );
    }

    public static Map<Id, List<Change_Order__c>> filterChangeOrdersForVersionChange( List<Change_Order__c> newChangeOrderList, Map<Id, Change_Order__c> oldChangeOrderMap ) {
        Map<Id, List<Change_Order__c>> proposalIdToChangeOrders = new Map<Id, List<Change_Order__c>>();

        for( Change_Order__c changeOrder : newChangeOrderList ) {
            if( !String.isBlank(changeOrder.Proposal__c) && (oldChangeOrderMap == null || changeOrder.Status__c != oldChangeOrderMap.get(changeOrder.Id).Status__c ) ){
                if( !proposalIdToChangeOrders.containsKey( changeOrder.Proposal__c ) ){
                    proposalIdToChangeOrders.put( changeOrder.Proposal__c, new List<Change_Order__c>() );
                }
                List<Change_Order__c> changeOrdersForProposal = proposalIdToChangeOrders.get( changeOrder.Proposal__c );
                changeOrdersForProposal.add( changeOrder );
                proposalIdToChangeOrders.put( changeOrder.Proposal__c, changeOrdersForProposal );
            }
        }

        return proposalIdToChangeOrders;
    }

    //KDI: 12/11/2013 Removed in MRS-3162; suspecting re-use in the future
    /*public static Map<Id, List<Change_Order__c>> filterChangeOrdersForVersionChange( List<Change_Order__c> newChangeOrderList, Map<Id, Change_Order__c> oldChangeOrderMap ) {
        Map<Id, List<Change_Order__c>> proposalIdToChangeOrders = new Map<Id, List<Change_Order__c>>();
        if( newChangeOrderList != null && oldChangeOrderMap != null ) {
            for( Change_Order__c coItem : newChangeOrderList ) {
                if( ( ( coItem.Status__c == STATUS_APPROVED && oldChangeOrderMap.get(coItem.Id).Status__c != STATUS_APPROVED ) ||
                      ( coItem.Status__c == STATUS_PENDING_CLIENT && oldChangeOrderMap.get(coItem.Id).Status__c != STATUS_PENDING_CLIENT ) ||
                      ( coItem.Status__c == STATUS_IN_INT_REVIEW && oldChangeOrderMap.get(coItem.Id).Status__c != STATUS_IN_INT_REVIEW ) ) &&
                    ( !String.isBlank(coItem.Proposal__c) ) ) {
                    if( proposalIdToChangeOrders.get( coItem.Proposal__c ) == null ) proposalIdToChangeOrders.put( coItem.Proposal__c, new List<Change_Order__c>() );
                    List<Change_Order__c> changeOrdersForProposal = proposalIdToChangeOrders.get( coItem.Proposal__c );
                    changeOrdersForProposal.add( coItem );
                }
            }
        }
        return proposalIdToChangeOrders;
    }*/

    //KDI: 12/11/2013 Removed in MRS-3162; suspecting re-use in the future
    /*public static void updateChangeOrderVersion( Map<Id, List<Change_Order__c>> proposalIdToChangeOrders ){
        List<List<Change_Order__c>> changeOrders = proposalIdToChangeOrders.values();
        for( List<Change_Order__c> coList : changeOrders ) {
            for( Change_Order__c coItem : coList ) {
                if( coItem.Version__c == null ) coItem.Version__c = 0.0;
                if( coItem.Status__c == STATUS_APPROVED ) {
                    coItem.Version__c = coItem.Version__c.intValue() + VERSION_MAJOR_STEP;
                } else if( coItem.Status__c == STATUS_PENDING_CLIENT ) {
                    coItem.Version__c = coItem.Version__c + VERSION_MINOR_STEP;
                } else if ( coItem.Status__c == STATUS_IN_INT_REVIEW ) {
                    coItem.Version__c = coItem.Version__c + VERSION_SUB_STEP;
                }
            }
        }
    }*/

    public static List<Change_Order__c> filterChangeOrdersWithoutNumbers( List<Change_Order__c> newChangeOrders ) {
        List<Change_Order__c> filteredChangeOrders = new List<Change_Order__c>();
        for( Change_Order__c co : newChangeOrders ) {
            if( ( co.Number__c == null || co.Number__c == 0 ) && !String.isEmpty( co.Project_Profile__c ) && co.Status__c != ChangeOrderServices.STATUS_DRAFT ) {
                filteredChangeOrders.add( co );
            }
        }
        return filteredChangeOrders;
    }

    public static void updateChangeOrderNumber( List<Change_Order__c> newChangeOrders ) {
        if( newChangeOrders.isEmpty() ) return;
        Map<Id, Integer> projectIdToMaxChangeOrderNumber = new Map<Id, Integer>();
        for( Change_Order__c co : newChangeOrders ) {
            projectIdToMaxChangeOrderNumber.put( co.Project_Profile__c, 0 );
        }
        for( AggregateResult ar : [ SELECT MAX(Number__c) maxNumber, Project_Profile__c
                                    FROM Change_Order__c
                                    WHERE Project_Profile__c IN : projectIdToMaxChangeOrderNumber.keySet()
                                    GROUP BY Project_Profile__c ] ) {
            projectIdToMaxChangeOrderNumber.put( (Id)ar.get( 'Project_Profile__c' ), Integer.valueOf( (Decimal)ar.get( 'maxNumber' ) ) );
        }
        for( Change_Order__c co : newChangeOrders ) {
            Integer coNumber = projectIdToMaxChangeOrderNumber.get( co.Project_Profile__c );
            if( coNumber == null ) {
                coNumber = 0;
            }
            co.Number__c = ++coNumber;
            projectIdToMaxChangeOrderNumber.put( co.Project_Profile__c, coNumber );
        }
    }

    public static Map<Id, Change_Order__c> filterApprovedChangeOrders( List<Change_Order__c> newChangeOrders, Map<Id, Change_Order__c> oldChangeOrderMap ){
        if( oldChangeOrderMap == null ) return new Map<Id, Change_Order__c>( newChangeOrders );
        if( newChangeOrders == null ) return oldChangeOrderMap;
        Map<Id, Change_Order__c> filteredChangeOrders = new Map<Id, Change_Order__c>();
        for( Change_Order__c changeOrder: newChangeOrders ){
            if( changeOrder.Status__c.equals( STATUS_APPROVED ) &&
                !oldChangeOrderMap.get( changeOrder.Id ).Status__c.equals( STATUS_APPROVED ) &&
                changeOrder.Approved_Date__c == null ) {
                filteredChangeOrders.put( changeOrder.Id, changeOrder );
            }
        }
        return filteredChangeOrders;
    }

    public static void updateChangeOrderNumbers( Map<Id, Change_Order__c> changeOrderMap ) {
        Set<id> projectIds = new Set<Id>();
        List<Change_Order__c> approvedChangeOrders = new List<Change_Order__c>();
        List<Change_Order__c> notApprovedChangeOrders = new List<Change_Order__c>();
        Map<Id, List<Change_Order__c>> projectIdToCOListMap = new Map<Id, List<Change_Order__c>>();

        for( Change_Order__c changeOrder: changeOrderMap.values() ){
            projectIds.add( changeOrder.Project_Profile__c );
        }

        for( Change_Order__c changeOrder: [ SELECT Project_Profile__c, Number__c, Id, CreatedDate, Status__c
                                           FROM Change_Order__c
                                           WHERE Project_Profile__c IN: projectIds
                                           ORDER BY Approved_DateTime__c ASC NULLS LAST, CreatedDate ASC ] ){
            if( !changeOrder.Status__c.equals( STATUS_APPROVED ) ){
                notApprovedChangeOrders.add( changeOrder );
            }else{
                approvedChangeOrders.add( changeOrder );
            }
        }

        for( Change_Order__c changeOrder: approvedChangeOrders ){
            if( !projectIdToCOListMap.containsKey( changeOrder.Project_Profile__c ) ) {
                projectIdToCOListMap.put( changeOrder.Project_Profile__c, new List<Change_Order__c>() );
            }
            projectIdToCOListMap.get( changeOrder.Project_Profile__c ).add( changeOrder );
        }

        for( Change_Order__c changeOrder: notApprovedChangeOrders ){
            if( !projectIdToCOListMap.containsKey( changeOrder.Project_Profile__c ) ) {
                projectIdToCOListMap.put( changeOrder.Project_Profile__c, new List<Change_Order__c>() );
            }
            projectIdToCOListMap.get( changeOrder.Project_Profile__c ).add( changeOrder );
        }

        List<Change_Order__c> changeOrdersToUpdate = new List<Change_Order__c>();
        for( Id projectId: projectIdToCOListMap.keySet() ){
            Integer changeOrderNumber = 1;
            for( Change_Order__c changeOrder: projectIdToCOListMap.get(projectId) ){
                changeOrder.Number__c = changeOrderNumber++;
                changeOrdersToUpdate.add(changeOrder);
            }
        }
        try{
            upsert changeOrdersToUpdate;
        } catch( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                changeOrderMap.get( dmlEx.getDmlId(i) ).addError( 'Error Upserting Change Order' + dmlEx.getMessage() );
            }
        }
    }

	public static Decimal serviceItemSubtotal(Service_Item__c si) {  //MRS 7560
		Decimal quantity = !String.isBlank(String.valueOf(si.Quantity__c)) ? si.Quantity__c : 0.00;
		Decimal servicePrice = !String.isBlank(String.valueOf(si.Unit_Price__c)) ? si.Unit_Price__c : 0.00;
		if(si.Change_Order__c != null && si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED && si.Is_Amendmend_Deleted__c) return 0.00; 
		return quantity * servicePrice;
	}

	public static Decimal serviceItemReimbursableCosts(Service_Item__c si) {
		Integer coReimbursable;
		if(si.Original__c) {
			coReimbursable = si.Proposal__r.Reimbursable_Items_Basis__c ? si.Proposal__r.Reimbursable_Percentage__c.intValue() : 0;
		} else {
			coReimbursable = si.Change_Order__r.Apply_Reimbursable__c &&
			si.Change_Order__r.Reimbursable_Percentage__c != null ?
			si.Change_Order__r.Reimbursable_Percentage__c.intValue() : 0;
		}
		return serviceItemSubtotal(si) * coReimbursable / 100;
	}

	public static Decimal getServicesTotalFromItems(List<Service_Item__c> siList, String typeOfTotal) {
		Decimal res = 0;
		if(typeOfTotal == ChangeOrderServices.SERVICES_SUBTOTAL_TITLE) {
			for(Service_Item__c si : siList) {
				res += serviceItemSubtotal(si);	
			}
		} else if(typeOfTotal == ChangeOrderServices.SERVICES_DISCOUNT_TITLE) {
			for(Service_Item__c si : siList) {
				Decimal discount = !String.isBlank(String.valueOf(si.Discount_Percentage__c)) ? si.Discount_Percentage__c : 0;
				res += serviceItemSubtotal(si) * (100 - discount) / 100;
			}
			res = getServicesTotalFromItems(siList, ChangeOrderServices.SERVICES_SUBTOTAL_TITLE) - res;
		} else if(typeOfTotal == ChangeOrderServices.SERVICES_SALES_TAX_TITLE) {
			for(Service_Item__c si : siList) {
				Decimal discount = !String.isBlank(String.valueOf(si.Discount_Percentage__c)) ? si.Discount_Percentage__c : 0;
				Decimal discountedServicePrice = serviceItemSubtotal(si) * (100 - discount) / 100;
				Decimal taxPerc1 = (null != si.Tax_Percent_1__c) ? si.Tax_Percent_1__c : 0.00;
				Decimal taxPerc2 = (null != si.Tax_Percent_2__c) ? si.Tax_Percent_2__c : 0.00;
				res += !si.Is_Alternative__c ? ( ( (taxPerc1 + taxPerc2) * discountedServicePrice ) / 100 ).setScale(2) : 0.00; 
			}
		} else if(typeOfTotal == ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE) {
			for(Service_Item__c si : siList) {
				res += serviceItemReimbursableCosts(si);
			}
		} else if(typeOfTotal == ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE) {
			for(Service_Item__c si : siList) {
				Decimal discount = !String.isBlank(String.valueOf(si.Discount_Percentage__c)) ? si.Discount_Percentage__c : 0;
				Decimal discountedServicePrice = serviceItemSubtotal(si) * (100 - discount) / 100;
				Decimal taxPerc1 = (null != si.Tax_Percent_1__c) ? si.Tax_Percent_1__c : 0.00;
				Decimal taxPerc2 = (null != si.Tax_Percent_2__c) ? si.Tax_Percent_2__c : 0.00;
				Decimal totalTaxes = !si.Is_Alternative__c ? ( ( (taxPerc1 + taxPerc2) * discountedServicePrice ) / 100 ).setScale(2) : 0.00;
				res += serviceItemSubtotal(si) - discount - totalTaxes + serviceItemReimbursableCosts(si);
			}
			return res;	
		}
		
		return res;
	}

    public static Decimal getServicesTotal(List<ServiceModel> serviceModels, Id currentChangeOrderId) {
        Decimal total = 0.00;
        for( ServiceModel smItem : serviceModels ) {
            if( smItem.getIsQuantityChangeOrder() ) {
                if( smItem.changeOrderId == currentChangeOrderId ) {
                    total += smItem.getTotalServicePriceDiff();
                } else {
                    total += smItem.getTotalServicePriceOld();
                }
            } else {
                if( smItem.isAmendmendDeleted && smItem.changeOrderId == currentChangeOrderId ) {
                    total += -1 * smItem.getTotalServicePrice();
                } else {
                    total += smItem.getTotalServicePrice();
                }
            }
        }
        return total;
    }

    public static Decimal getServicesTotalDiscounted (List<ServiceModel> serviceModels, Id currentChangeOrderId) {
        Decimal total = 0.00;
        for( ServiceModel smItem : serviceModels ) {
            if( smItem.getIsQuantityChangeOrder() ) {
                if( smItem.changeOrderId == currentChangeOrderId ) {
                    total += smItem.getTotalDiscountedServicePriceDiff();
                } else {
                    total +=smItem.getTotalDiscountedServicePriceOld();
                }
            } else {
                if( smItem.isAmendmendDeleted && smItem.changeOrderId == currentChangeOrderId ) {
                    total += -1 * smItem.getTotalDiscountedServicePrice();
                } else {
                    total += smItem.getTotalDiscountedServicePrice();
                }
            }
        }
        return total;
    }

    public static Decimal getServicesTotalSalesTax (List<ServiceModel> serviceModels, Id currentChangeOrderId) {
        Decimal totalSalesTax = 0.00;
        for( ServiceModel smItem : serviceModels ) {
            if( smItem.getIsQuantityChangeOrder() ) {
                if( smItem.changeOrderId == currentChangeOrderId ) {
                    totalSalesTax += smItem.getSalesTaxDiff();
                } else {
                    totalSalesTax += smItem.getSalesTaxOld();
                }
            } else {
                if( smItem.isAmendmendDeleted && smItem.changeOrderId == currentChangeOrderId ) {
                    totalSalesTax += -1 * smItem.getSalesTax();
                } else {
                    totalSalesTax += smItem.getSalesTax();
                }
            }
        }
        return totalSalesTax;
    }

    public static Boolean isMaxCompleteness( List<ServiceModel> serviceModels ) {
        for( ServiceModel sm : serviceModels ) {
            if( String.isBlank(sm.serviceGroup) && sm.getIsServiceGroupRequired() ) {
                return false;
            }
        }
        return true;
    }

    public static Boolean areThereOnlyDraftCOs( List<ChangeOrderModel> changeOrders ) {
        if( changeOrders != null ) {
            for( ChangeOrderModel changeOrderItem : changeOrders ) {
                if( changeOrderItem.status != STATUS_DRAFT ) return false;
            }
        }
        return true;
    }

    public static Map<Id, Change_Order__c> filterChangeOrdersInCZScopingReview ( Map<Id, Change_Order__c> newChangeOrderMap, Map<Id, Change_Order__c> oldChangeOrderMap ){
        Map<Id, Change_Order__c> filteredChangeOrders = new Map<Id, Change_Order__c>();
        for( Change_Order__c changeOrder: newChangeOrderMap.values() ){
            if( changeOrder.Status__c.equals( STATUS_IN_CZ_REVIEW ) && oldChangeOrderMap.get( changeOrder.Id ).Status__c != changeOrder.Status__c) {
                filteredChangeOrders.put( changeOrder.Id, changeOrder );
            }
        }
        return filteredChangeOrders;
    }

    public static List<Change_Order__c> getChangeOrdersByProjectProfileId( String projectId, Proposal__c proposal) { //MRS 7280
		String request = 'SELECT Id, Status__c, Services_Total__c, Approved_DateTime__c, SIPS_Coordinator__c, Name,' //MRS 7507
                          			+ ' Project_Profile__c, Proposal__c, Internal_Reviewer__c, Internal_Reviewer_Reminder__c, Code_Zoning_Analyst__c,'
									+ ' Code_Zoning_Analyst_Email__c, Municipal_Authority_Fees__c, Projected_DOB_Fee__c,'
									+ ' Apply_Reimbursable__c, Reimbursable_Percentage__c, Apply_Discount__c, Discount_Percentage__c, Reminder_for_Creator__c,'
									+ ' Received_Signed_CO__c, Disable_Followups__c, Document_Type__c, Follow_Ups_Count__c, UseDocusign__c,'
									+ ' Change_Order_Sender__c'
									+ ' FROM Change_Order__c'
									+ ' WHERE Project_Profile__c = \'' + projectId + '\'';
		if(proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c) {
			request += proposal.optView_Hide_Canceled_Change_Orders__c ? ' AND Status__c != \'Canceled\'' : '';
		}
		request += ' ORDER BY Number__c';
		return Database.query(request);
    }

    public static void createBliOrTaskForApprovedChangeOrders( Map<Id, Change_Order__c> approvedChangeOrders ) {
        Map<Id, List<Change_Order__c>> projectIdToChangeOrders = new Map<Id, List<Change_Order__c>>(); // for dml errors handling
        List<Billing_Line_Item__c> billingLineItemsToInsert = new List<Billing_Line_Item__c>();
        List<Task> tasksToInsert = new List<Task>();
        Set<Id> projectIdsToBlockFutureBillingDates = new Set<Id>();
        Map<Id, Project_Profile__c> projectIdToProject = new Map<Id, Project_Profile__c>();
        for( Change_Order__c co : approvedChangeOrders.values() ) {
            projectIdToProject.put( co.Project_Profile__c, null );
            if( !projectIdToChangeOrders.containsKey( co.Project_Profile__c ) ) {
                projectIdToChangeOrders.put( co.Project_Profile__c, new List<Change_Order__c>() );
            }
            projectIdToChangeOrders.get( co.Project_Profile__c ).add( co );
        }
        projectIdToProject.remove( null );
        projectIdToChangeOrders.remove( null );
        //system.debug(LoggingLevel.Error, 'xxx projectIdToChangeOrders: ' + String.valueOf(projectIdToChangeOrders));

        projectIdToProject = new Map<Id, Project_Profile__c>( [ SELECT Name, Billing_Method__c, Interval__c, Accounting_Contact_Company__r.A_R_coordinator__c
                                                                FROM Project_Profile__c
                                                                WHERE Id IN : projectIdToProject.keySet() ] );
        for( Id projectId : projectIdToProject.keySet() ) {
            Project_Profile__c project = projectIdToProject.get( projectId );
            if( project.Billing_Method__c != ProjectProfileServices.BILLINGMETHODINSTALLMENT &&
                project.Billing_Method__c != ProjectProfileServices.BILLINGMETHODPERCENTAGE ) {
                projectIdToProject.remove( projectId );
            }
        }
        if( !projectIdToProject.keySet().isEmpty() ) {
            Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount = ProjectProfileServices.getProjectIdToAmountTypeToAmount( projectIdToProject.keySet() );
            Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmountCO = getProjectIdToAmountTypeToAmountCO( approvedChangeOrders.keySet() );
            for( Id projectId : projectIdToProject.keySet() ) {
                Map<String, Decimal> amountTypeToAmount = projectIdToAmountTypeToAmount.get( projectId );
                Map<String, Decimal> amountTypeToAmountCO = projectIdToAmountTypeToAmountCO.get( projectId );
                //system.debug(LoggingLevel.Error, 'xxx amountTypeToAmount: ' + amountTypeToAmount);
                //system.debug(LoggingLevel.Error, 'xxx amountTypeToAmountCO: ' + amountTypeToAmountCO);
                if(
                    (
                        amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) <= 0 //no more BLI are to be created
                    ) && (
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT ) > 0 || //CO increases the Total Price or Tax
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) > 0 ||
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) > 0
                    /*) && (
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT ) >= 0 && //CO does not reduce any of amounts
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) >= 0 &&
                        amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) >= 0*/
                    ) && (
                        amountTypeToAmount.get( BillingLineItemServices.TOTAL_AMOUNT ) //CO does not reduce what has already been billed
                      + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT )
                      - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) >= 0
                    ) && (
                        amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) //CO does not reduce what has already been billed
                      + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT )
                      - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) >= 0
                    ) && (
                        amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) //CO does not reduce what has already been billed
                      + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT )
                      - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) >= 0
                    )
                  ) {
                    Billing_Line_Item__c billingLineItemToInsert = new Billing_Line_Item__c(
                        Project_Profile__c = projectId,
                        Is_Manualy_Created__c = false,
                        Product_Name__c = BillingLineItemServices.CONSULTING_INCOME_PRODUCT_NAME,
                        Amount__c = (   amountTypeToAmount.get( BillingLineItemServices.TOTAL_AMOUNT )
                                      + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT )
                                      - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) ).setScale(2),
                        Sales_Tax_Amount_1__c = (   amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT )
                                                  + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT )
                                                  - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) ).setScale(2),
                        Sales_Tax_Amount_2__c = (   amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT )
                                                  + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT )
                                                  - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) ).setScale(2),
                        Quantity__c = 1,
                        Unit_Price__c = (   amountTypeToAmount.get( BillingLineItemServices.TOTAL_AMOUNT )
                                      + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT )
                                      - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) ).setScale(2),
                        Description__c =   projectIdToProject.get( projectId ).Billing_Method__c
                                         + ' Billing - Change Order Balance'
                    );
                    //system.debug(LoggingLevel.Error, 'xxx billingLineItemToInsert: ' + String.valueOf(billingLineItemToInsert));
                    if( billingLineItemToInsert.Amount__c > 0 ||
                        billingLineItemToInsert.Sales_Tax_Amount_1__c > 0 ||
                        billingLineItemToInsert.Sales_Tax_Amount_2__c > 0 ) {
                        billingLineItemsToInsert.add( billingLineItemToInsert );
                    }
                } else if(
                    (
                      amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) <= 0 //no more BLI are to be created
                    ) || (
                      (
                        amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) > 0 //more BLI are to be created
                      ) && (
                        (
                            amountTypeToAmount.get( BillingLineItemServices.TOTAL_AMOUNT ) //CO reduces what has already been billed
                          + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_AMOUNT )
                          - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) < 0
                        ) || (
                            amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT ) //CO reduces what has already been billed
                          + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT )
                          - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX1_AMOUNT ) < 0
                        ) || (
                            amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT ) //CO reduces what has already been billed
                          + amountTypeToAmountCO.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT )
                          - amountTypeToAmount.get( BillingLineItemServices.BILLED_TAX2_AMOUNT ) < 0
                        )
                      )
                    )
                  ) {
                    if( !String.isEmpty( projectIdToProject.get( projectId ).Accounting_Contact_Company__r.A_R_coordinator__c ) ) {
                        tasksToInsert.add( TaskServices.newInstance( projectIdToProject.get( projectId ).Accounting_Contact_Company__r.A_R_coordinator__c,
                                                                     TaskServices.TASK_STATUS_NOT_STARTED,
                                                                     TaskServices.TASK_PRIORITY_HIGH,
                                                                     projectId,
                                                                     Datetime.now(),
                                                                     Date.today(),
                                                                     projectIdToProject.get( projectId ).Name +
                                                                       ' - A change order has changed the service totals or tax amounts after it was already billed',
                                                                     'Please review the discrepancy with the client and take appropriate action.',
                                                                     null ) );
                        projectIdsToBlockFutureBillingDates.add( projectId );
                    }
                }
            }
        }
        //system.debug(LoggingLevel.Error, 'xxx billingLineItemsToInsert: ' + billingLineItemsToInsert);
        List<Project_Profile__c> projectProfilesToUpdate = ProjectProfileServices.blockFutureBillingDatesForProjects( projectIdsToBlockFutureBillingDates );
        Savepoint sp = Database.setSavepoint();
        try {
            INSERT billingLineItemsToInsert;
        } catch( dmlException dmlEx ) {
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                for( Change_Order__c co : projectIdToChangeOrders.get( billingLineItemsToInsert[dmlEx.getDmlIndex(i)].Project_Profile__c ) ) {
                    co.addError( 'Error Occured While Creating Billing Line Items: ' + dmlEx.getMessage() );
                }
            }
            DataBase.rollback(sp);
            return;
        }
        try {
            INSERT tasksToInsert;
        } catch( dmlException dmlEx ) {
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                for( Change_Order__c co : projectIdToChangeOrders.get( tasksToInsert[dmlEx.getDmlIndex(i)].WhatId ) ) {
                    co.addError( 'Error Occured While Creating Tasks: ' + dmlEx.getMessage() );
                }
            }
            DataBase.rollback(sp);
            return;
        }
        try {
            UPDATE projectProfilesToUpdate;
        } catch( dmlException dmlEx ) {
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                for( Change_Order__c co : projectIdToChangeOrders.get( projectProfilesToUpdate[dmlEx.getDmlIndex(i)].Id ) ) {
                    co.addError( 'Error Occured While Updating Projects: ' + dmlEx.getMessage() );
                }
            }
            DataBase.rollback(sp);
            return;
        }
    }

    public static Map<Id, Map<String, Decimal>> getProjectIdToAmountTypeToAmountCO( Set<Id> changeOrderIds ) {
        Map<Id, Map<String, Decimal>> projectIdToAmountTypeToAmount = new Map<Id, Map<String, Decimal>>();
        for( Change_Order__c changeOrder : [ SELECT Id, Project_Profile__c,
                                               ( SELECT Sales_Tax_Amount_1__c, Sales_Tax_Amount_2__c, Is_Amendmend_Deleted__c, Total_Service_Price__c
                                                 FROM Service_Items__r )
                                            FROM Change_Order__c
                                            WHERE Id IN : changeOrderIds ] ) {
            projectIdToAmountTypeToAmount.put( changeOrder.Project_Profile__c, new Map<String, Decimal>{ BillingLineItemServices.TOTAL_AMOUNT => 0.00,
                                                                                                         BillingLineItemServices.TOTAL_TAX1_AMOUNT => 0.00,
                                                                                                         BillingLineItemServices.TOTAL_TAX2_AMOUNT => 0.00 } );
            Map<String, Decimal> amountTypeToAmount = projectIdToAmountTypeToAmount.get( changeOrder.Project_Profile__c );
            for( Service_Item__c si : changeOrder.Service_Items__r ) {
                amountTypeToAmount.put( BillingLineItemServices.TOTAL_AMOUNT,
                                        amountTypeToAmount.get( BillingLineItemServices.TOTAL_AMOUNT )
                                        + ( si.Is_Amendmend_Deleted__c ? -1 : 1 ) * si.Total_Service_Price__c );
                if( si.Sales_Tax_Amount_1__c != null ) {
                    amountTypeToAmount.put( BillingLineItemServices.TOTAL_TAX1_AMOUNT,
                                            amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX1_AMOUNT )
                                            + ( si.Is_Amendmend_Deleted__c ? -1 : 1 ) * si.Sales_Tax_Amount_1__c );
                }
                if( si.Sales_Tax_Amount_2__c != null ) {
                    amountTypeToAmount.put( BillingLineItemServices.TOTAL_TAX2_AMOUNT,
                                            amountTypeToAmount.get( BillingLineItemServices.TOTAL_TAX2_AMOUNT )
                                            + ( si.Is_Amendmend_Deleted__c ? -1 : 1 ) * si.Sales_Tax_Amount_2__c );
                }
            }
        }
        return projectIdToAmountTypeToAmount;
    }

    public static Map<Id, Change_Order__c> filterPendingClientApprovalCO( List<Change_Order__c> newChangeOrders, Map<Id, Change_Order__c> oldChangeOrderMap ){
        Map<Id, Change_Order__c> filteredChangeOrders = new Map<Id, Change_Order__c>();
        for( Change_Order__c changeOrder: newChangeOrders ){
            if( changeOrder.Status__c.equals( STATUS_PENDING_CLIENT ) && !oldChangeOrderMap.get( changeOrder.Id ).Status__c.equals( STATUS_PENDING_CLIENT )) {
                filteredChangeOrders.put( changeOrder.Id, changeOrder );
            }
        }
        return filteredChangeOrders;
    }

    public static void populateChangeOrderSentDateField( Map<Id, Change_Order__c> changeOrders ){
        for( Change_Order__c changeOrder: changeOrders.values() ){
            changeOrder.Change_Order_Sent_Date__c = Date.today();
            changeOrder.Change_Order_Sent_DateTime__c = DateTime.now();
            if( changeOrder.Initial_Sent_To_Client_Date__c == null ) changeOrder.Initial_Sent_To_Client_Date__c = Date.today();
        }
    }

    public static List<Roster_Email_Junction__c> filterEmailJunctionsAfterPendingClientApproval( List<Change_Order__c> newChangeOrders, Map<Id, Change_Order__c> oldChangeOrderMap ){
        List<Roster_Email_Junction__c> filteredJucntions = new List<Roster_Email_Junction__c>();
        Set<Id> changeOrdersId = new Set<Id>();
        for( Change_Order__c newChangeOrder: newChangeOrders ){
            if( newChangeOrder.Status__c != STATUS_PENDING_CLIENT && oldChangeOrderMap.get(newChangeOrder.Id).Status__c == STATUS_PENDING_CLIENT){
                changeOrdersId.add(newChangeOrder.Id);
            }
        }
        if ( !changeOrdersId.isEmpty() ){//MRS-7473
            List<Change_Order__c> changeOrdersFromDB = [SELECT Id, (Select Id From Roster_Email_Junction__r) FROM Change_Order__c WHERE Id IN: changeOrdersId];
            for( Change_Order__c changeOrder: changeOrdersFromDB ){
                filteredJucntions.addAll(changeOrder.Roster_Email_Junction__r);
            }
        }
        return filteredJucntions;
    }

    public static List<Change_Order__c> filterChangeOrdersAfterPendingClientApprovalToVoidEnvelopes( List<Change_Order__c> newChangeOrders, Map<Id, Change_Order__c> oldChangeOrderMap ) {
        List<Change_Order__c> filteredChangeOrders = new List<Change_Order__c>();
        for( Change_Order__c changeOrder : newChangeOrders ) {
            if( changeOrder.Status__c != STATUS_PENDING_CLIENT && changeOrder.Status__c != STATUS_APPROVED && oldChangeOrderMap.get( changeOrder.Id ).Status__c == STATUS_PENDING_CLIENT ) {
                filteredChangeOrders.add( changeOrder );
            }
        }
        return filteredChangeOrders;
    }

    @future
    public static void updateReceivedPO( Set<Id> changeOrderIds ) {//MRS-7473
        updateReceivedPO( changeOrderIds, new List<Service_Item__c>(), true, null );
    }

    public static void updateReceivedPO( Set<Id> changeOrderIds, List<Service_Item__c> serviceItemListNew ) {
        updateReceivedPO( changeOrderIds, serviceItemListNew, true, null );
    }

    //repeatAgainForOldCOs = false (default = true) and changeOrdersToUpdateFromPreviousRun are populated when this function is run again to determine checkboxes for old COs of Services
    public static void updateReceivedPO( Set<Id> changeOrderIds, List<Service_Item__C> serviceItemListNew, Boolean repeatAgainForOldCOs, Map<Id, Change_Order__c> changeOrdersToUpdateFromPreviousRun ) {
        Map<Id, Change_Order__c> changeOrdersToUpdate = new Map<Id, Change_Order__c>();

        if( changeOrdersToUpdateFromPreviousRun != null ) {
            changeOrdersToUpdate.putAll( changeOrdersToUpdateFromPreviousRun.values() );
        }

        Set<Id> coWithServicesIdxSet = new Set<Id>(); //MRS 7074
        Set<Id> coWithServicesIdxSetOld = new Set<Id>();

        if( !changeOrderIds.isEmpty() ) {
            Map<Id, List<Service_Item__c>> changeOrderIdToServiceItems = new Map<Id, List<Service_Item__c>>();
            for( Id changeOrderId : changeOrderIds ) {
                changeOrderIdToServiceItems.put( changeOrderId, new List<Service_Item__c>() );
            }
            for( Service_Item__c si : [ SELECT Change_Order__c, Purchase_Order__c, Status__c, Original__c, Change_Order__r.Status__c, Change_Order_Old__c
                                        FROM Service_Item__c
                                        WHERE Is_Alternative__c = false
                                          AND Change_Order__c IN : changeOrderIds ] ) {
                if( si.Purchase_Order__c == null && ( si.Status__c == ServiceItemServices.SERVICE_STATUS_ACTIVE 
                                                      || si.Status__c == ServiceItemServices.SERVICE_STATUS_NOTSTARTED
                                                      || si.Status__c == ServiceItemServices.SERVICE_STATUS_COMPLETED ) ) {
                    changeOrderIdToServiceItems.get( si.Change_Order__c ).add( si );
                }
                if( si.Original__c || si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED ) {
                    if( si.Status__c == ServiceItemServices.SERVICE_STATUS_ACTIVE 
                        || si.Status__c == ServiceItemServices.SERVICE_STATUS_NOTSTARTED
                        || si.Status__c == ServiceItemServices.SERVICE_STATUS_COMPLETED ) {
                        coWithServicesIdxSet.add( si.Change_Order__c );
                    }
                    if( si.Change_Order_Old__c != null ) {
                        coWithServicesIdxSetOld.add( si.Change_Order_Old__c );
                    }
                }
            }

            for( Id changeOrderId : changeOrderIdToServiceItems.keySet() ) {
                if( coWithServicesIdxSet.contains( changeOrderId ) ) {
                    Boolean isReceivedPo = changeOrderIdToServiceItems.get( changeOrderId ).isEmpty();
                    Change_Order__c currentCo = changeOrdersToUpdate.get( changeOrderId );
                    if( currentCo == null ) {
                        currentCo = new Change_Order__c( Id = changeOrderId, Received_PO__c = isReceivedPo );
                    } else if( currentCo.Received_PO__c == true && !isReceivedPo ) {
                        currentCo.Received_PO__c = false;
                    }
                    changeOrdersToUpdate.put( changeOrderId, currentCo );

                } else {
                    if( changeOrdersToUpdate.get( changeOrderId ) == null ) {
                        changeOrdersToUpdate.put( changeOrderId, new Change_Order__c( Id = changeOrderId, Received_PO__c = false ) );
                    }
                }
            }
        }

        if( repeatAgainForOldCOs && !coWithServicesIdxSetOld.isEmpty() ) {
            updateReceivedPO( coWithServicesIdxSetOld, serviceItemListNew, false, changeOrdersToUpdate );
        } else {
            if( !changeOrdersToUpdate.keySet().isEmpty() ) {
                List<Change_Order__c> changeOrdersInUpdate = changeOrdersToUpdate.values();
                try {
                    UPDATE changeOrdersInUpdate;
                } catch( DMLException dmlEx ) {
                    if ( serviceItemListNew == null || serviceItemListNew.isEmpty() ){ //MRS-6595
                        for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                            changeOrdersInUpdate[dmlEx.getDmlIndex(i)].addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                        }
                    } else {
                        for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                            Id changeOrderlId = changeOrdersInUpdate[dmlEx.getDmlIndex(i)].Id;
                            for ( Service_Item__c serviceItemItem : serviceItemListNew ){
                                if ( serviceItemItem.Change_Order__c == changeOrderlId ){
                                    serviceItemItem.addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /*public static void updateReceivedPO( Set<Id> changeOrderIds, List<Service_Item__C> serviceItemListNew ){
        List<Change_Order__c> cahngeOrdersFromDB = [SELECT Id, Received_PO__c,
                                             ( Select Id FROM Service_Items__r
                                                WHERE (Status__c =: ServiceItemServices.SERVICE_STATUS_ACTIVE OR Status__c =: ServiceItemServices.SERVICE_STATUS_NOTSTARTED)
                                                AND Purchase_Order__c =: null)
                                             FROM Change_Order__c WHERE Id IN: changeOrderIds];

        Set<Id> coWithServicesIdxSet = new Set<Id> ();  // MRS 7074
        List<Service_Item__c> servicesToBeChecked = [ SELECT Id, Change_Order__c
                                                         FROM Service_Item__c
                                                         WHERE Change_Order__c IN : changeOrderIds
                                                           AND ( Status__c = : ServiceItemServices.SERVICE_STATUS_ACTIVE OR Status__c = : ServiceItemServices.SERVICE_STATUS_NOTSTARTED )
                                                           AND ( Original__c = true OR Change_Order__r.Status__c = : ChangeOrderServices.STATUS_APPROVED )
                                                           AND Is_Alternative__c = false LIMIT 1];
        if( servicesToBeChecked != null ) for( Service_Item__c sI : servicesToBeChecked ) coWithServicesIdxSet.add( sI.Change_Order__c );


        List<Change_Order__c> changeOrdersToUpdate = new List<Change_Order__c>();
        for( Change_Order__c changeOrder: cahngeOrdersFromDB ){
            if( coWithServicesIdxSet.contains( changeOrder.Id ) ) {
            changeOrdersToUpdate.add(new Change_Order__c(Id = changeOrder.Id, Received_PO__c = changeOrder.Service_Items__r.isEmpty() ));
            } else {
                changeOrdersToUpdate.add(new Change_Order__c(Id = changeOrder.Id, Received_PO__c = false ));
            }
        }

        try {
            UPDATE changeOrdersToUpdate;
        } catch( DMLException dmlEx ) {
            if ( serviceItemListNew == null || serviceItemListNew.isEmpty() ){//MRS-6595
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    changeOrdersToUpdate[dmlEx.getDmlIndex(i)].addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                }
            } else {
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    Id changeOrderlId = changeOrdersToUpdate[dmlEx.getDmlIndex(i)].Id;
                    for ( Service_Item__c serviceItemItem : serviceItemListNew ){
                        if ( serviceItemItem.Change_Order__c == changeOrderlId ){
                            serviceItemItem.addError( 'Error Occurred While Updating Proposal : ' + dmlEx.getMessage() );
                        }
                    }
                }
            }
        }
    }*/
/*
    public static void runPreBill(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return;

        }
        ProjectProfileServices.isAllowedPreBillGenerated = true;
        ProjectProfileServices.prebillProjects(ProjectProfileServices.getPreBilledProjectByIds(projectIds));

    }
*/
    public static List<Change_Order__c> filterChangeOrdersChangesFromDraftToRequested( List<Change_Order__c> newChangeOrderList, Map<Id, Change_Order__c> oldChangeOrderMap ) {
        List<Change_Order__c> changeOrders = new List<Change_Order__c>();

        for( Change_Order__c changeOrder : newChangeOrderList ) {
            if( changeOrder.Status__c != STATUS_APPROVED && //MRS-6927
                changeOrder.Status__c != STATUS_CANCELED &&
                changeOrder.Status__c != STATUS_DRAFT &&
                changeOrder.Status__c != oldChangeOrderMap.get(changeOrder.Id).Status__c ){

                changeOrders.add( changeOrder );
            }
        }

        return changeOrders;
    }

    public static void updateProjectCompletedProjectState( List<Change_Order__c> newChangeOrders ){
        List<Project_Profile__c> updateProjectStateList = new List<Project_Profile__c>();
        Set<Id> projectProfileSetId = new Set<Id>();
        for (Change_Order__c changeOrderItem : newChangeOrders){
            if ( changeOrderItem.Project_State_Formula__c == ProjectProfileServices.PROJECT_STATE_COMPLETE ){
                projectProfileSetId.add( changeOrderItem.Project_Profile__c );
            }
        }
        for (Id projectId : projectProfileSetId){
            updateProjectStateList.add( new Project_Profile__c (Id = projectId, Project_State__c = ProjectProfileServices.PROJECT_STATE_IN_PROCESS, Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey() ) );
        }
        if (!updateProjectStateList.isEmpty()){
            update updateProjectStateList;
        }
    }

    //MRS-6414
    public static Set<Id> filteredComplatedApprovedChangeOrders ( List<Change_Order__c> newChangeOrderList, Map<Id, Change_Order__c> oldChangeOrderMap ){
        Set<Id> filteredProjectProfileSetId = new Set<Id>();
        for (Change_Order__c changeOrderItem : newChangeOrderList){
            if ( changeOrderItem.Project_Profile__c != null &&
                 (changeOrderItem.Status__c == STATUS_APPROVED || changeOrderItem.Status__c == STATUS_CANCELED) &&
                 changeOrderItem.Status__c != oldChangeOrderMap.get(changeOrderItem.Id).Status__c ){

                filteredProjectProfileSetId.add(changeOrderItem.Project_Profile__c);

            }
        }
        return filteredProjectProfileSetId;
    }

	public static void preventChangingStatusManually(Map<Id, Change_Order__c> newMap, Map<Id, Change_Order__c> oldMap) { //MRS 7462
		Set<Id> coAffected = new Set<Id>();
		for(Change_Order__c co : newMap.values()) {
			if(oldMap.get(co.Id).Status__c == STATUS_APPROVED && co.Status__c != STATUS_APPROVED) {
				newMap.get(co.Id).Approved_Date__c = null;
				coAffected.add(co.Id);
			}
		}
		if(!coAffected.isEmpty()) {
			for(AggregateResult ar : [SELECT COUNT(Id)amount, Change_Order__c FROM Service_Item__c
									  WHERE Change_Order__c IN :coAffected AND Applied_Amendment__c = true
									  GROUP BY Change_Order__c]) {
				if(ar.get('amount') != null && Integer.valueOf(ar.get('amount')) > 0) {
					newMap.get((Id)ar.get('Change_Order__c')).addError('Status of Change Order can not be changed from Approved manually if any of milestones are set.');
				}
			}
		}
	}

	public static void deleteTaskItemsWhenCoUnapprowed(Map<Id, Change_Order__c> newMap, Map<Id, Change_Order__c> oldMap) { //MRS 7462
		Set<Id> coAffected = new Set<Id>();
		for(Change_Order__c co : newMap.values()) {
			if(oldMap.get(co.Id).Status__c == STATUS_APPROVED && co.Status__c != STATUS_APPROVED) {
				coAffected.add(co.Id);
			}
		}
		if(!coAffected.isEmpty()) {
			Map<Id, Service_Item__c> servicesMap = new Map<Id, Service_Item__c> ([SELECT Id, Change_Order__c, (SELECT Id, Service_Item__c FROM Task_Items__r)
																					FROM Service_Item__c WHERE Change_Order__c IN :coAffected]);
			Map<Id, Task_Item__c> taskItemsToDelete = new Map<Id, Task_Item__c>();
			for(Service_Item__c si : servicesMap.values()) {
				for(Task_Item__c ti : si.Task_Items__r) {
					taskItemsToDelete.put(ti.Id, new Task_Item__c(Id = ti.Id, Service_Item__c = ti.Service_Item__c));
				}
			}
			if(!taskItemsToDelete.isEmpty()) {
				Savepoint sp = Database.setSavepoint();
				Boolean deleteSuccess = true;
				Database.DeleteResult[] deleteResults = Database.delete(taskItemsToDelete.values());
				for(Database.DeleteResult dr : deleteResults) {
					if(!dr.isSuccess()) {
						newMap.get(servicesMap.get(taskItemsToDelete.get(dr.getId()).Service_Item__c).Change_Order__c).addError('Error occurs during erasing Task Items connected to Change Order.');
						deleteSuccess = false;
					}
				}
				if(!deleteSuccess) DataBase.rollback(sp);
			}
		}
	}
}