public with sharing class PurchaseOrderServices {

    public static Boolean preventDoubleLinkingBLIsToPO = false;

    // MRS-6939 MRS-7008 MRS-7015 MRS 7140
    public static void updatePurchaseOrdersData(Set<Id> posIds) {
    if( posIds.isEmpty() ) return;
system.debug(LoggingLevel.Error,'posIds ='+posIds);
        Map<Id, Purchase_Order__c> idToPoToUpdateMap = new Map<Id, Purchase_Order__c> ();
        Map<Id, Decimal> idToTotalDiscAmount = PoIdToPoTotalDiscServBalMap ( posIds );

        List<Billing_Line_Item__c> blis = [SELECT Amount__c, Billed__c, IsReimbursable__c, Purchase_Order__c, Is_Check_Processing_Fee__c, Hide_from_Recap__c, Sales_Tax_Amount__c, IsMunicipalFee__c /* MRS 7264 */,
												Pro_forma_Invoice__c, Pro_forma_Invoice__r.cl_FFA_Invoice_Created__c /*MRS 7570 */
                                           FROM Billing_Line_Item__c WHERE Purchase_Order__c IN: posIds];
        Map<Id, List<Billing_Line_Item__c>> poIdToListOfBLIs = new Map<Id, List<Billing_Line_Item__c>> ();
        if( !blis.isEmpty() ) {
            for(Billing_Line_Item__c bli : blis) {
                if(poIdToListOfBLIs.get(bli.Purchase_Order__c) == null) poIdToListOfBLIs.put(bli.Purchase_Order__c, new List<Billing_Line_Item__c> ());
                poIdToListOfBLIs.get(bli.Purchase_Order__c).add(bli);
            }
        }

		for( Id idx : posIds ) {
            Decimal reimbursableBilling = 0;
            Decimal municipalFeesBilling = 0;
            Decimal serviceBilling = 0;
            Decimal checkProccessingFeeBilling = 0;
            Decimal totalBillingAmount = 0; //MRS 7570
            if( poIdToListOfBLIs.get(idx) != null) {
                for(Billing_Line_Item__c bli : poIdToListOfBLIs.get(idx)) {
                    if( bli.Amount__c != null && !bli.Hide_from_Recap__c) {
                            if( bli.isReimbursable__c) {
                            	if( bli.IsMunicipalFee__c ){
                            		municipalFeesBilling += bli.Amount__c;
                            	}else{
                            		reimbursableBilling += bli.Amount__c;
                            	}
                            } else  if( bli.Is_Check_Processing_Fee__c ) {
                                        //checkProccessingFeeBilling += bli.Amount__c;
										reimbursableBilling += bli.Amount__c; //MRS 7281 
                                    } else {
                                        serviceBilling += bli.Amount__c;
                                    }
						if(bli.Pro_forma_Invoice__c != null && bli.Pro_forma_Invoice__r.cl_FFA_Invoice_Created__c) {
                        	totalBillingAmount += bli.Amount__c + bli.Sales_Tax_Amount__c; // MRS 7264 7570
						}
                    }
                }
            }

            idToPoToUpdateMap.put(idx, new Purchase_Order__c( Id = idx,
                                                              Reimbursable_Billing__c = reimbursableBilling,
                                                              Check_Processing_Fee_billing__c = checkProccessingFeeBilling,
                                                              Municipal_Fees_Billing__c = municipalFeesBilling,
                                                              Service_Billing__c = serviceBilling,
                                                              Total_Billing__c = totalBillingAmount,
                                                              Total_Disc_Serv_Bal__c = idToTotalDiscAmount.get( idx ) ) );
        }

		PurchaseOrderServices.preventDoubleLinkingBLIsToPO = true;
        update idToPoToUpdateMap.values();
    }

    public static Map<Id, Decimal> PoIdToPoTotalDiscServBalMap (Set<Id> posIds) {

        Map<Id, Decimal> res = new Map<Id, Decimal> ();
		if(posIds != null && posIds.size() > 0) { //MRS 7574
	        List<Service_Item__c> serviceItemList = [SELECT Purchase_Order__r.PO_Excludes_Sales_Tax__c, Balance_to_Bill__c, Purchase_Order__c, Is_Amendmend_Deleted__c, Change_Order_Status__c,
															Sales_Tax_Amount__c, Amount_Billed__c, Total_Service_Price__c
	                                                 FROM Service_Item__c
	                                                 WHERE Purchase_Order__c IN: posIds];

	        Map<Id, List<Service_Item__c>> poIdToListOfServiceItems = new Map<Id, List<Service_Item__c>> ();

	        if(!serviceItemList.isEmpty()) {
	            for(Service_Item__c serviceItem : serviceItemList) {
	                if(poIdToListOfServiceItems.get(serviceItem.Purchase_Order__c) == null) poIdToListOfServiceItems.put(serviceItem.Purchase_Order__c, new List<Service_Item__c> ());
	                poIdToListOfServiceItems.get(serviceItem.Purchase_Order__c).add(serviceItem);
	            }
	        }

	        for( Id idx : posIds ) {
	            Decimal totalDiscountedServicesBalance = 0;
	            if( poIdToListOfServiceItems.get(idx) != null ) {
	                for(Service_Item__c serviceItem : poIdToListOfServiceItems.get(idx)) {
	                    if( serviceItem.Balance_to_Bill__c != null) {
							Decimal tempServiceBalance = 0;
							if(!serviceItem.Purchase_Order__r.PO_Excludes_Sales_Tax__c) {
								tempServiceBalance += serviceItem.Balance_to_Bill__c;
							} else {
								if(serviceItem.Amount_Billed__c == null) serviceItem.Amount_Billed__c = 0;
								tempServiceBalance += serviceItem.Balance_to_Bill__c - serviceItem.Sales_Tax_Amount__c * (serviceItem.Balance_to_Bill__c - serviceItem.Sales_Tax_Amount__c - serviceItem.Amount_Billed__c) / serviceItem.Total_Service_Price__c;
							}

	                        if( serviceItem.Is_Amendmend_Deleted__c == false ) {
								totalDiscountedServicesBalance += tempServiceBalance;
							}
	                        if( serviceItem.Is_Amendmend_Deleted__c == true && serviceItem.Change_Order_Status__c != null && serviceItem.Change_Order_Status__c != ChangeOrderServices.STATUS_APPROVED ) {
	                            totalDiscountedServicesBalance += tempServiceBalance * (-1);
	                        }
	                    }
	                }
	            }

	            res.put( idx, totalDiscountedServicesBalance);
	        }
		}
        return res;
    }

    public static void totalAmountPurchaseOrder(Set<Id> purchaseOrderIdSet) {
        List<AggregateResult> aggResults = [SELECT Purchase_Order__c po, SUM(Total_Billed_Amount__c) tbaSum FROM Pro_forma_Invoice__c WHERE Purchase_Order__c IN : purchaseOrderIdSet GROUP BY Purchase_Order__c ORDER BY Purchase_Order__c];
        List<Purchase_Order__c> purchaseOrderList = new List<Purchase_Order__c>();
        for (AggregateResult ar : aggResults) {
            purchaseOrderList.add(new Purchase_Order__c(
                Id = (String) ar.get('po'),
                Total_Billing__c = (Decimal) ar.get('tbaSum')
            ));
        }
        update purchaseOrderList;
    }

    public static void calculatePurchaseOrderTotals( Set<Id> purchaseOrdersId ){ //MRS 7332
	if( purchaseOrdersId.isEmpty() ) return;

		Map<Id, Purchase_Order__c> poMap = new Map<Id, Purchase_Order__c>();
		for(Pro_forma_Invoice__c invoice : [SELECT Id, Purchase_Order__r.Id, Total_Billed_Amount__c, cl_FFA_Invoice_Created__c,
												(SELECT Amount__c, Billed__c, IsReimbursable__c, Purchase_Order__c, Is_Check_Processing_Fee__c,
														Hide_from_Recap__c, Sales_Tax_Amount__c, IsMunicipalFee__c FROM Billing_Line_Items__r)
											FROM Pro_forma_Invoice__c
											WHERE Purchase_Order__c IN: purchaseOrdersId]) {
			if(poMap.get(invoice.Purchase_Order__c) == null) {
				poMap.put(invoice.Purchase_Order__c, new Purchase_Order__c(Id = invoice.Purchase_Order__c,
																			Total_Billing__c = 0, Pending_Billing__c = 0,
																			Total_Billing_Services__c = 0, Pending_Billing_Services__c = 0,
																			Total_Billing_Municipal_Fees__c = 0, Pending_Billing_Municipal_Fees__c = 0,
																			Total_Billing_Reimbursable__c = 0, Pending_Billing_Reimbursable__c = 0));
			}

			//if( invoice.cl_FFA_Invoice_Created__c ){ //-MRS 7570
			//	poMap.get(invoice.Purchase_Order__c).Total_Billing__c += invoice.Total_Billed_Amount__c;
			//} else {
			//	poMap.get(invoice.Purchase_Order__c).Pending_Billing__c += invoice.Total_Billed_Amount__c;
			//}

			for(Billing_Line_Item__c bli : invoice.Billing_Line_Items__r) {
				if(bli.Amount__c != null && !bli.Hide_from_Recap__c) {
					if(bli.isReimbursable__c || bli.Is_Check_Processing_Fee__c) {
						if(bli.IsMunicipalFee__c) {
							if(invoice.cl_FFA_Invoice_Created__c) {
								poMap.get(invoice.Purchase_Order__c).Total_Billing_Municipal_Fees__c += bli.Amount__c;
							} else {
								poMap.get(invoice.Purchase_Order__c).Pending_Billing_Municipal_Fees__c += bli.Amount__c; 
							}
						} else {
							if(invoice.cl_FFA_Invoice_Created__c) {
								poMap.get(invoice.Purchase_Order__c).Total_Billing_Reimbursable__c += bli.Amount__c;
							} else {
								poMap.get(invoice.Purchase_Order__c).Pending_Billing_Reimbursable__c += bli.Amount__c; 
							}
						}
					} else  {
						if(invoice.cl_FFA_Invoice_Created__c) {
							poMap.get(invoice.Purchase_Order__c).Total_Billing_Services__c += bli.Amount__c;
						} else {
							poMap.get(invoice.Purchase_Order__c).Pending_Billing_Services__c += bli.Amount__c; 
						}
					}

					if( invoice.cl_FFA_Invoice_Created__c ) { //MRS 7570
						poMap.get(invoice.Purchase_Order__c).Total_Billing__c += bli.Amount__c + bli.Sales_Tax_Amount__c;
	                } else {
				    	poMap.get(invoice.Purchase_Order__c).Pending_Billing__c += bli.Amount__c + bli.Sales_Tax_Amount__c;
					}	
				}
			}
		}

		if(!poMap.isEmpty()) {
			UPSERT poMap.values();
        }
    }

    public static List<Purchase_Order__c> getPurchaseOrdersForNewMailroomLineItems ( Set<Id> projectProfileIds ){  // MRS-7025
        return new List<Purchase_Order__c>( [ SELECT Pending_Balance__c, Total_Billing__c, Remaining_Balance__c, Purchase_Order_Amount__c, Project_Profile__c, NTE_Includes_Reimbursables__c, Id, CreatedDate,
                                                     Unallocated_Balance__c, Service_Billing__c, Total_Disc_Serv_Bal__c, Check_Processing_Fee_billing__c, Unallocated_Balance_Without_Service_Am__c,
                                                     Services__c, Reimbursables__c, Reimbursable_Billing__c, Municipal_Fees__c, Municipal_Fees_Billing__c, PO_Expiration_Date__c,
                                               (SELECT Name, Total_Service_Price__c, Sales_Tax_Amount__c FROM Covered_Services__r ),
                                               (Select Id, Amount__c, isReimbursable__c, Sales_Tax_Amount__c, Service_Item__c From Billing_Line_Items__r WHERE isReimbursable__c = true )
                                               FROM Purchase_Order__c
                                               WHERE Project_Profile__c IN : projectProfileIds AND NTE_Includes_Reimbursables__c = true
                                               ORDER BY CreatedDate ASC] );
    }

    public static List<Purchase_Order__c> getPurchaseOrdersForBillingLineItems ( Set<Id> projectProfileIds ){
        return new List<Purchase_Order__c>( [ SELECT Pending_Balance__c, Total_Billing__c, Remaining_Balance__c, Purchase_Order_Amount__c, Project_Profile__c, NTE_Includes_Reimbursables__c, Id, CreatedDate,
                        Project_Profile__r.Interval__c, Project_Profile__r.Billing_Method__c, Service_Billing__c, Total_Disc_Serv_Bal__c, Check_Processing_Fee_billing__c, Unallocated_Balance_Without_Service_Am__c,
                                               (SELECT Name, Total_Service_Price__c, Sales_Tax_Amount__c FROM Covered_Services__r ),
                                               (Select Id, Amount__c, isReimbursable__c, Sales_Tax_Amount__c, Service_Item__c From Billing_Line_Items__r )
                                               FROM Purchase_Order__c
                                               WHERE Project_Profile__c IN : projectProfileIds
                                               ORDER BY CreatedDate ] );
    }

    public static Purchase_Order__c getPurchaseOrderById(Id purchaseOrderId) {
        List<Purchase_Order__c> purchaseOrderList = [Select Proposal__c, Id From Purchase_Order__c Where Id = : purchaseOrderId];
        Purchase_Order__c purchaseOrder = new Purchase_Order__c();
        if(purchaseOrderList.size() > 0) {
            purchaseOrder = purchaseOrderList.get(0);
        }
        return purchaseOrder;
    }

    public static Set<Id> filterInvoicesWithChangedPO( List<Purchase_Order__c> newPOList, Map<Id, Purchase_Order__c> oldPOMap) {
        Set<Id> filteredPOId = new Set<Id>();
        for( Purchase_Order__c purchaseOrder: newPOList ){
            if( purchaseOrder.Purchase_Order_Amount__c != oldPOMap.get(purchaseOrder.Id).Purchase_Order_Amount__c ){
                filteredPOId.add(purchaseOrder.Id);
            }
        }

        Map<Id, Pro_forma_Invoice__c> proformaInvoices = new Map<Id, Pro_forma_Invoice__c>([ SELECT Id, Project_Profile__c, Invoice_Format__c
                                                                                            FROM Pro_forma_Invoice__c
                                                                                            WHERE Purchase_Order__c IN: filteredPOId]);
        return proformaInvoices.keySet();
    }

    public static Map<Id, Purchase_Order__c> getPurchaseOrdersForProposal( Id proposalId ){ // MRS 7046
        return new Map<Id, Purchase_Order__c>( [ SELECT Name, Revision_Date__c, Received_and_Verified__c, Purchase_Order_Number__c, Purchase_Order_Date__c, PO_Excludes_Sales_Tax__c, //MRS 6205
                                                Purchase_Order_Amount__c, Notes__c, NTE_Includes_Reimbursables__c, Id, Blanket_PO__c, Proposal__c, Reimbursables_Only__c,
                                                CreatedDate, CreatedById, Services__c, Reimbursables__c, Municipal_Fees__c, Municipal_Fees_Billing__c, Reimbursable_Billing__c, 
												Check_Processing_Fee_billing__c, Service_Billing__c, PO_Expiration_Date__c,// MRS 7192
												Unallocated_Balance_Services__c, //MRS 7364
                                                ( Select Id From Covered_Services__r )
                                                 FROM Purchase_Order__c
                                                 WHERE Proposal__c = : proposalId
                                                 ORDER BY CreatedDate ASC ]);
    }

    public class PurchaseOrderComparableCreatedDate implements Comparable { // MRS 7046
        public Purchase_Order__c myPO;
        public PurchaseOrderComparableCreatedDate ( Purchase_Order__c pO ) {
            myPO = pO;
        }
        public Integer compareTo(Object compareTo) {
            PurchaseOrderComparableCreatedDate pO = (PurchaseOrderComparableCreatedDate)compareTo;
            if ( myPO.CreatedDate == pO.myPO.CreatedDate ) return 0;
            return myPO.CreatedDate > pO.myPO.CreatedDate ? -1 : 1;
        }
    }

    //Filter Milestone Services with existing Project that have been linked to PO
    public static List<Purchase_Order__c> filterPOsWithLinkedServices(List<Service_Item__c> serviceItemListNew, Map<Id, Service_Item__c> serviceItemMapOld){
        List<Purchase_Order__c> filteredPurchaseOrders = new List<Purchase_Order__c>();
        for (Service_Item__c serviceItem : serviceItemListNew){
            if ( /*( (ProjectProfileServices.BILLINGMETHODMILESTONE.equals(serviceItem.Billing_Method__c) &&
                    ProjectProfileServices.BILLINGMETHODMILESTONE.equals(serviceItemMapOld.get(serviceItem.Id).Billing_Method__c) ) ||
            ( ProjectProfileServices.BILLINGMETHODPERCENTAGE.equals(serviceItem.Billing_Method__c) && !serviceItem.Interval__c &&
                      ProjectProfileServices.BILLINGMETHODPERCENTAGE.equals(serviceItemMapOld.get(serviceItem.Id).Billing_Method__c) ) ) &&*/
                !String.isBlank(serviceItem.Project_Profile__c) &&
                !String.isBlank(serviceItemMapOld.get(serviceItem.Id).Project_Profile__c) &&
                !String.isBlank(serviceItem.Purchase_Order__c) &&
                String.isBlank(serviceItemMapOld.get(serviceItem.Id).Purchase_Order__c)){
                filteredPurchaseOrders.add(new Purchase_Order__c(Id = serviceItem.Purchase_Order__c, Project_Profile__c = serviceItem.Project_Profile__c));
            }
        }
	system.debug(LoggingLevel.Error,'filteredPurchaseOrders ='+filteredPurchaseOrders);
        return filteredPurchaseOrders;
    }

    //MRS-6595
    public static void populateProjectProfileOnPO ( List<Purchase_Order__c> newPOList ) {
        for (Purchase_Order__c purchaseOrderItem : newPOList){
            if ( purchaseOrderItem.Project_Profile__c == null && !String.isBlank(purchaseOrderItem.ProjectProfileOnProposal__c) ){
                purchaseOrderItem.Project_Profile__c = Id.valueOf(purchaseOrderItem.ProjectProfileOnProposal__c);
            }
        }
    }

   public static void deleteRelatedFilesAndFoldersForPurchaseOrder( Id purchaseOrderId ) { // MRS 6803
        List<LStore__Stored_Document__c> existingDocs = [ SELECT LStore__Folder__c
                                                          FROM LStore__Stored_Document__c
                                                          WHERE Related_Object_Id__c = : String.valueOf( purchaseOrderId )
                                                            AND Recordtype.Name = : StoredDocumentServices.DOCUMENT_RECORDTYPE ];
        DELETE existingDocs;
        List<LStore__Stored_Document__c> existingFlds = [ SELECT LStore__Folder__c
                                                          FROM LStore__Stored_Document__c
                                                          WHERE Related_Object_Id__c = : String.valueOf( purchaseOrderId )
                                                            AND Recordtype.Name = : StoredDocumentServices.FOLDER_RECORDTYPE ];
        DELETE existingFlds;
    }


    public static void deletePurchaseOrder( Purchase_Order__c purchaseOrder, Boolean checkIfThisIsTemplate ) { // MRS 6803
        if( purchaseOrder.Id != null && ( !checkIfThisIsTemplate || purchaseOrder.Proposal__c == null ) ) {
            List<Service_Item__c> serviceItemsList= [SELECT Id, Purchase_Order__c FROM Service_Item__c WHERE Purchase_Order__c = :purchaseOrder.Id];
            if( serviceItemsList != null ) { // MRS-7074
                for( Service_Item__c sI : serviceItemsList ) {
                    sI.Purchase_Order__c = null;
                }
                UPSERT serviceItemsList;
            }
            deleteRelatedFilesAndFoldersForPurchaseOrder( purchaseOrder.Id );
            DELETE purchaseOrder;
        }
    }
}