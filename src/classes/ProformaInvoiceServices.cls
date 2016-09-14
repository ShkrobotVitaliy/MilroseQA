public with sharing class ProformaInvoiceServices {
    private static final String CATEGORY_APPLICATION_FILING  = 'Application Filing';
    private static final String CATEGORY_APPLICATION_REQUIREMENT = 'Application Requirement';
    private static final String TYPE_PLAN_APPROVAL           = 'Plan Approval';
    private static final String FILLING_STATUS_INITIAL       = 'Initial Filing';
    private static final String FILLING_STATUS_POST_APPROVAL = 'Post Approval Amendment';
    private static final String CATEGORY_AMENDMENT_APPLICATION_FILING = 'Amendment-Application Filing';

    public final static String CREATE_CREDIT_NOTE1_JOB_NAME     = 'Create Credit Note 1';
    public final static String CREATE_CREDIT_NOTE2_JOB_NAME     = 'Create Credit Note 2';

    public final static String DO_NOT_BILL_REIMPURSABLES_AALONE = 'Reimbursable Billing Items were selected for invoicing that do not have related non-reimbursable line items.  They have not been added to an invoice. BLIs: ';
    public final static String CHANGE_ORDER_BALANCE = 'Change Order Balance';

    public static Boolean isTest = false;
    public static Boolean billAnyway = false;

	public static Boolean invoiceAmountHasBeenDeducated = false; //MRS 7527

    public static Map<Id, Project_Profile__c> projectMap = new Map<Id, Project_Profile__c>();
    public static Map<Id, Date> projectIdToInvoiceCutoffDateMap = new Map<Id, Date>();
    public static List<Purchase_Order__c> purchaseOrders = new List<Purchase_Order__c>();
    public static Set<String> noTimeInvoicingForBLIs = new Set<String>();

    public static String createPFIErrorsHendle;
    public static String updateBLIErrorsHendle;
    public static String errorsDuringInsertReimbursables;
    public static String errorsDuringUpdateServiceItems;
    public static String restrictionsBasedPO;

    public static Map<String, DDP_Helper__c> ddpHelperMap;

    public static void preventCheckHideFromRecap(List<Pro_forma_Invoice__c> newInvoicesList, Map<Id, Pro_forma_Invoice__c> oldInvoicesMap) { //MRS 7140
        Set<Id> idxSetUpdatedInvoicesToCheck = new Set<Id> ();
        List<Pro_forma_Invoice__c> updatedInvoicesToCheck = new List<Pro_forma_Invoice__c> ();
        for(Pro_forma_Invoice__c invoice : newInvoicesList) {
            if(invoice.Hide_from_Recap__c) {
                if(String.isBlank(invoice.Id)) {
                    invoice.Hide_from_Recap__c = false;
                    invoice.addError('Hide from Recap/PO can\'t be checked unless there is a Sales Invoice related to the PFI.'); // MRS 7256
                } else if(!oldInvoicesMap.get(invoice.Id).Hide_from_Recap__c) {
                    updatedInvoicesToCheck.add(invoice);
                    idxSetUpdatedInvoicesToCheck.add(invoice.Id);
                }
            }
        }

        Set<Id> idxProformaWithFFInvoiceSet = new Set<Id> ();

        if(!idxSetUpdatedInvoicesToCheck.isEmpty()) {
            for(AggregateResult ar : [SELECT cl_Pro_forma_Invoice__c, COUNT(Id)amount
                                      FROM c2g__codaInvoice__c
                                      WHERE cl_Pro_forma_Invoice__c IN :idxSetUpdatedInvoicesToCheck
                                          GROUP BY cl_Pro_forma_Invoice__c]) {
                if((Integer)ar.get('amount') > 0) idxProformaWithFFInvoiceSet.add((Id)ar.get('cl_Pro_forma_Invoice__c'));
            }
        }

        for(Pro_forma_Invoice__c invoice : updatedInvoicesToCheck) { // MRS 7256
            if(!idxProformaWithFFInvoiceSet.contains(invoice.Id)) {
                invoice.Hide_from_Recap__c = false;
                invoice.addError('Hide from Recap/PO can\'t be checked unless there is a Sales Invoice related to the PFI.');
            }
        }
    }

    public static void validationCreateFFACreditNote(Map<Id, Pro_forma_Invoice__c> newInvoicesMap, List<Pro_forma_Invoice__c> oldInvoices) {
        Set<Id> invoiceIds = new Set<Id>();

        for (Pro_forma_Invoice__c invoice : oldInvoices) {
            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c && !invoice.cl_Create_FFA_Credit_Note_1__c ||
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c && !invoice.cl_Create_FFA_Credit_Note_2__c) {
                    invoiceIds.add(invoice.Id);

            }

        }

        for (Pro_forma_Invoice__c invoice : getProformaInvoiceByIds(invoiceIds)) {
            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c && !invoice.cl_Create_FFA_Credit_Note_1__c) {
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c = allowCheckFFACreditNote1(invoice.Billing_Line_Items__r);

                if (!newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_1__c) {
                    newInvoicesMap.get(invoice.Id).addError(ErrorException.PRO_FORMA_REQUIRED_FIELDS_ON_BLI);

                }

            }

            if (newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c && !invoice.cl_Create_FFA_Credit_Note_2__c) {
                newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c = allowCheckFFACreditNote2(invoice.Billing_Line_Items__r);

                if (!newInvoicesMap.get(invoice.Id).cl_Create_FFA_Credit_Note_2__c) {
                    newInvoicesMap.get(invoice.Id).addError(ErrorException.PRO_FORMA_REQUIRED_FIELDS_ON_BLI);

                }

            }

        }

    }

    private static Boolean allowCheckFFACreditNote1(List<Billing_Line_Item__c> billingLineItems) {
        for (Billing_Line_Item__c bli : billingLineItems) {
            if (null == bli.cl_Credit_1_Amount__c) {
                return false;

            }

        }
        return true;

    }

    private static Boolean allowCheckFFACreditNote2(List<Billing_Line_Item__c> billingLineItems) {
        for (Billing_Line_Item__c bli : billingLineItems) {
            if (null == bli.cl_Credit_2_Amount__c) {
                return false;

            }

        }
        return true;

    }

    public static void processProformaInvoices( List<Billing_Line_Item__c> bLineItems ) {
        processProformaInvoices( bLineItems, false, false, false );
    }

    public static void updateARCoordinator( Map<Id, Account> filteredAccounts ) {
        if( filteredAccounts.isEmpty() ) return;
        List<Pro_forma_Invoice__c> invoicesForUpdate = new List<Pro_forma_Invoice__c>();

        for( Pro_forma_Invoice__c item: [Select Id, Name, A_R_Coordinator__c, Accounting_Contact_Company__c From Pro_forma_Invoice__c Where Accounting_Contact_Company__c IN: filteredAccounts.keySet() ] ){
            if ( item.A_R_Coordinator__c != filteredAccounts.get( item.Accounting_Contact_Company__c ).A_R_Coordinator__c ){ //MRS-6568
                item.A_R_Coordinator__c = filteredAccounts.get( item.Accounting_Contact_Company__c ).A_R_Coordinator__c;
                invoicesForUpdate.add( item );
            }
        }

        try{
            if ( !invoicesForUpdate.isEmpty() ){ //MRS-6568
                update invoicesForUpdate;
            }
        }catch( DMLException dmlEx ){
            for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                filteredAccounts.get( invoicesForUpdate[dmlEx.getDmlIndex(i)].Accounting_Contact_Company__c ).addError( 'Can not update related Pro-forma Invoice ' + dmlEx.getMessage() );
            }
        }
    }

    public static void processProformaInvoices( List<Billing_Line_Item__c> bLineItems, Boolean doNotBillReimbursablesAlone, Boolean isBillAnyway, Boolean invoiceBatchIsExecuted ) {
        if( bLineItems.isEmpty() ) return;
        Savepoint sp = Database.setSavepoint();
        billAnyway = isBillAnyway;

        //Populate Project map
        populateProjectProfileMapForInvoicing( bLineItems );

        List<Billing_Line_Item__c> bliForInvoicingRightNow = new List<Billing_Line_Item__c>();
        noTimeInvoicingForBLIs.clear();
        if( !invoiceBatchIsExecuted && !isBillAnyway ){//MRS-7105
            for( Billing_Line_Item__c bli : bLineItems ){
                if( bli.Milestone_Date__c <= projectIdToInvoiceCutoffDateMap.get( bli.Project_Profile__c ) ){
                    bliForInvoicingRightNow.add( bli );
                } else{
                    noTimeInvoicingForBLIs.add( bli.Name );
                }
            }
        }else{
            bliForInvoicingRightNow.addAll( bLineItems );
        }
system.debug(LoggingLevel.Error,'bliForInvoicingRightNow ='+bliForInvoicingRightNow);
        if( bliForInvoicingRightNow.isEmpty() ) return;

        List<Billing_Line_Item__c> reimbursableLineItems = prepareReimbursableBLIs( bliForInvoicingRightNow, sp, invoiceBatchIsExecuted );

        //Generate Invoices
        List<Billing_Line_Item__c> lineItemsForInvoices = new List<Billing_Line_Item__c>();
        try {
            lineItemsForInvoices.addall( bliForInvoicingRightNow );
            if (!reimbursableLineItems.isEmpty()) {
        		lineItemsForInvoices.addall([SELECT Id, isReimbursable__c, Unit_Price__c, Project_Profile__c, Accounting_Contact_Company__c, Accounting_Contact__c, Hide_from_Recap__c, /*MRS 7550*/
                                                        Service_Item__c, Purchase_Order__c, Is_Manualy_Created__c, Related_Service_Item__c, Billing_Client__c,
							                            Billing_Contact__c, Client_Contact__c, Description__c, Product_Name__c, Is_Check_Processing_Fee__c,
							                            Reimbursable_Type__c, Pre_billed__c, Quantity__c, Amount__c, Milestone_Date__c, Phase__c, Pro_forma_Invoice__c, Name,
							                            Project_Address__c, Sales_Tax_Amount__c, Project_Profile__r.PO_Required__c, Project_Profile__r.PO_Not_Required__c
                                                    FROM Billing_Line_Item__c
                                                    WHERE Id IN: reimbursableLineItems]);
            }

            createProformaInvoiceList( lineItemsForInvoices, doNotBillReimbursablesAlone, invoiceBatchIsExecuted );

        } catch(Exception ex) {
            Database.rollback(sp);
            throw new ErrorException('Error while generating Proforma Invoices' + ex.getMessage());
        }

        //Show message about Proforma Invoices that can't be converted to a FF sales invoice
        if( !invoiceBatchIsExecuted ){
            Set<Id> setIdForManipulation = new Set<Id>();
            for( Billing_Line_Item__c bli: bliForInvoicingRightNow ){
                setIdForManipulation.add( bli.Id );
            }
            Map<Id, Billing_Line_Item__c> billingLineItemsFormDB = new Map<Id, Billing_Line_Item__c>([SELECT Pro_forma_Invoice__c, Id FROM Billing_Line_Item__c WHERE Id IN: setIdForManipulation]);
            setIdForManipulation.clear();
            for( Billing_Line_Item__c bli: billingLineItemsFormDB.values() ){
                setIdForManipulation.add( bli.Pro_forma_Invoice__c );
            }
            Map<Id, Pro_forma_Invoice__c> proformaInvoicesMap = new Map<Id, Pro_forma_Invoice__c>([SELECT Id, Name, Invoice_Exceeded_PO__c, cl_Create_FFA_Invoice__c, Purchase_Order__c, Purchase_Order__r.Received_and_Verified__c FROM Pro_forma_Invoice__c WHERE Id IN: setIdForManipulation]);
            List<String> lockedProformaInvoiceNames = new List<String>();
            List<String> notVerifiedProformaInvoiceNames = new List<String>();

            for (Billing_Line_Item__c bli: billingLineItemsFormDB.values()) {
                if (proformaInvoicesMap.containsKey(bli.Pro_forma_Invoice__c)) {
                    if( proformaInvoicesMap.get(bli.Pro_forma_Invoice__c).Invoice_Exceeded_PO__c ){
                        lockedProformaInvoiceNames.add(proformaInvoicesMap.get(bli.Pro_forma_Invoice__c).Name);

                    }

                    if( proformaInvoicesMap.get(bli.Pro_forma_Invoice__c).Purchase_Order__c != null && !proformaInvoicesMap.get(bli.Pro_forma_Invoice__c).Purchase_Order__r.Received_and_Verified__c ){
                        notVerifiedProformaInvoiceNames.add(proformaInvoicesMap.get(bli.Pro_forma_Invoice__c).Name);

                    }

                }

            }
            String errorMessage1, errorMessage2;
            if( !lockedProformaInvoiceNames.isEmpty() ) {
                errorMessage1 = 'Following Proforma Invoices cannot be integrated to a FF sales invoices. This restriction can be overridden if \'Override Billing Restrictions\' option on appropriate Purchase Orders will be allowed.';
                errorMessage2 = String.join( lockedProformaInvoiceNames, ', ' );
                if( ApexPages.currentPage() != null ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, errorMessage1 ) );
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO , errorMessage2 ) );
                } else {
                    throw new ErrorException( errorMessage1 + ' ' + errorMessage2 );
                }
            }
            if( !notVerifiedProformaInvoiceNames.isEmpty() ) {
                errorMessage1 = 'Following Proforma Invoices are associated with a Purchase Orders that have not been received and verified.';
                errorMessage2 = String.join( notVerifiedProformaInvoiceNames, ', ' );
                if( ApexPages.currentPage() != null ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, errorMessage1 ) );
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, errorMessage2 ) );
                } else {
                    throw new ErrorException( errorMessage1 + ' ' + errorMessage2 );
                }
            }
        }
    }

    private static List<Billing_Line_Item__c> prepareReimbursableBLIs( List<Billing_Line_Item__c> bLineItems, Savepoint sp, Boolean invoiceBatchIsExecuted ) {
        List<Billing_Line_Item__c> reimbursableLineItems = new List<Billing_Line_Item__c>();
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        Map<Id, Set<Id>> consideredProjectsIdToPhasesSetMap  = new Map<Id, Set<Id>>();

        //MRS-6396
        Set<Id> projectIds = new Set<Id>();
        for (Billing_Line_Item__c bli: bLineItems) {
            projectIds.add(bli.Project_Profile__c);

        }
        projectIds.remove(null);

        Map<Id, List<Task_Item__c>> projectIdToTaskItems       = ProjectProfileServices.groupTaskItemsByProjectId(projectIds);
        Map<Id, List<Service_Item__c>> projectIdToServiceItems = ServiceItemServices.groupServiceItemsByProjectId(projectIds);

        //UCRX 2.1 (add Reimbursable Line Item per project)
        reimbursableLineItems.addAll( getReimbursableLineItemsPerProject( bLineItems, consideredProjectsIdToPhasesSetMap, serviceItemsToUpdate, projectIdToTaskItems, projectIdToServiceItems ) );//MRS-6396

        //UCRX 2.2 (add Reimbursable Line Item per invoice)
        reimbursableLineItems.addAll( getReimbursableLineItemsPerInvoice( bLineItems, consideredProjectsIdToPhasesSetMap, serviceItemsToUpdate, projectIdToTaskItems, projectIdToServiceItems ) );//MRS-6396

        if( !reimbursableLineItems.isEmpty() ){
            //Populate BLI purchase Order lookup
            //BillingLineItemServices.populateReimbursableLineItemsPurchaseOrder( reimbursableLineItems, purchaseOrders );
            if ( invoiceBatchIsExecuted ){
                Database.SaveResult[] srList1 = Database.insert( reimbursableLineItems, false );
                errorsDuringInsertReimbursables = '';
                errorsDuringUpdateServiceItems = '';

                for ( Integer i = 0; i < reimbursableLineItems.size(); i++ ) {
                   Database.SaveResult sr = srList1[i];
                   Billing_Line_Item__c origRecord = reimbursableLineItems[i];
                   if ( !sr.isSuccess() ) {

                       for(Database.Error err : sr.getErrors()) {
                           errorsDuringInsertReimbursables += '\n' + origRecord.Project_Profile__c + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                       }
                   }
                }

                Database.SaveResult[] srList2 = Database.update( serviceItemsToUpdate, false );

                for ( Integer i = 0; i < serviceItemsToUpdate.size(); i++ ) {
                   Database.SaveResult sr = srList2[i];
                   Service_Item__c origRecord = serviceItemsToUpdate[i];
                   if ( !sr.isSuccess() ) {

                       for(Database.Error err : sr.getErrors()) {
                           errorsDuringUpdateServiceItems += '\n' + origRecord.Name + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                       }
                   }
                }

             }else {
                try {
            system.debug(LoggingLevel.Error,'reimbursableLineItems ='+reimbursableLineItems[0].Purchase_Order__c);
                    insert reimbursableLineItems;
                    upsert serviceItemsToUpdate;
                } catch(Exception ex) {
                    Database.rollback(sp);
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
                }
            }
        }

        for(Integer i = reimbursableLineItems.size() - 1; i >= 0; i--) { // NRS 7156
            if(  reimbursableLineItems[i].Description__c == 'Document Shredding' && reimbursableLineItems[i].Do_not_create_Invoice__c) {
                reimbursableLineItems.remove(i);
            }
        }

        return reimbursableLineItems;
    }

    private static Map<Id, Map<Id, Map<Id, List<Billing_Line_Item__c>>>> getProjectToPhaseToServiceToLineItemsMap(List<Billing_Line_Item__c> bLineItems) {
        Map<Id, Map<Id, Map<Id, List<Billing_Line_Item__c>>>> projectToPhaseToServiceToLineItems = new Map<Id, Map<Id, Map<Id, List<Billing_Line_Item__c>>>>();

        for (Billing_Line_Item__c bli : bLineItems) {
            // Initiate the map with serviceId key and billingLineItems value
            if ( !projectToPhaseToServiceToLineItems.containsKey( bli.Project_Profile__c ) ) {
                projectToPhaseToServiceToLineItems.put(bli.Project_Profile__c, new Map<Id, Map<Id, List<Billing_Line_Item__c>>>());

            }

            // Initiate the map with phaseId key and serviceIdToLineItemsMap value
            if ( !projectToPhaseToServiceToLineItems.get( bli.Project_Profile__c ).containsKey( bli.Phase__c ) ) {
                projectToPhaseToServiceToLineItems.get( bli.Project_Profile__c ).put( bli.Phase__c, new Map<Id, List<Billing_Line_Item__c>>() );
            }

            // Initiate the billingLineItems list with serviceId key
            if ( !projectToPhaseToServiceToLineItems.get(bli.Project_Profile__c).get(bli.Phase__c).containsKey(bli.Service_Item__c) ) {
                projectToPhaseToServiceToLineItems.get(bli.Project_Profile__c).get(bli.Phase__c).put(bli.Service_Item__c, new List<Billing_Line_Item__c>());

            }
            projectToPhaseToServiceToLineItems.get(bli.Project_Profile__c).get(bli.Phase__c).get(bli.Service_Item__c).add(bli);
        }
        return projectToPhaseToServiceToLineItems;
    }

    @TestVisible
    private static Boolean isServiceItemSutableToCreateShredingPerProject( Billing_Line_Item__c bli, Map<Id, List<Service_Item__c>> projectIdToServiceItems ){
        if( bli.Service_Shredding_Fee__c > 0 && bli.Service_Type__c == TYPE_PLAN_APPROVAL &&
                        ( bli.Service_Category__c == CATEGORY_APPLICATION_FILING || bli.Service_Category__c == CATEGORY_APPLICATION_REQUIREMENT) ){
            for (Service_Item__c service : projectIdToServiceItems.get(bli.Project_Profile__c)) {
                if( service.id == bli.Service_Item__c ){
                    return !service.Doc_Shredding_BLI_Created__c;
                }
            }
        }
        return false;
    }

    private static Map<Id, Billing_Line_Item__c> blisFromDB {
        get {
            if (null != projectMap.keySet() && !projectMap.keySet().isEmpty() && null == blisFromDB) {
                blisFromDB = new Map<Id, Billing_Line_Item__c>([SELECT Id__c, isReimbursable__c, Service_Category__c, Service_Item__c, Service_Filling_Status__c,
                                                                            Service_Type__c, Pro_forma_Invoice__c, isReimbursableOnProjectLevel__c, Project_Profile__c
                                                                     FROM Billing_Line_Item__c
                                                                     WHERE Project_Profile__c =: projectMap.keySet()]);
            } else {
                blisFromDB = new Map<Id, Billing_Line_Item__c>();

            }
            return blisFromDB;

        }
        set;

    }

    @TestVisible
    private static List<Billing_Line_Item__c> getReimbursableLineItemsPerProject( List<Billing_Line_Item__c> lineItems,
                                                                                  Map<Id, Set<Id>> consideredProjectsIdToPhasesSetMap,
                                                                                  List<Service_Item__c> serviceItemsToUpdate,
                                                                                  Map<Id, List<Task_Item__c>> projectIdToTaskItems,
                                                                                  Map<Id, List<Service_Item__c>> projectIdToServiceItems ) {
        List<Billing_Line_Item__c> reimbursableLineItems = new List<Billing_Line_Item__c>();
        Billing_Line_Item__c reimbursableLineItem;



        for( Billing_Line_Item__c bli: lineItems ){
            Project_Profile__c bliProject = projectMap.get(bli.Project_Profile__c);
            Service_Item__c serviceItemToCreateReimbursable;
            if( bliProject.No_Document_Shredding__c || bliProject.Pre_billed__c || consideredProjectsIdToPhasesSetMap.keySet().contains(bli.Project_Profile__c) || bli.isReimbursable__c ) continue;

            //Check if Reimbursable BLI per project exists
            Boolean reimbursableItemPerProjectExists = false;
            //for( Billing_Line_Item__c existingLineItem: bliProject.Billing_Line_Items__r ){
            for (Billing_Line_Item__c existingLineItem: blisFromDB.values()) {
                if( existingLineItem.Project_Profile__c == bli.Project_Profile__c &&
                    existingLineItem.isReimbursable__c &&
                    existingLineItem.isReimbursableOnProjectLevel__c ){
                    reimbursableItemPerProjectExists = true;
                    break;
                }
            }
            if( reimbursableItemPerProjectExists ) continue;

            if( bliProject.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ){
                if( isServiceItemSutableToCreateShredingPerProject( bli, projectIdToServiceItems ) ){
                    serviceItemToCreateReimbursable = new Service_Item__c(Id = bli.Service_Item__c);
                    serviceItemToCreateReimbursable.Shredding_Fees__c = bli.Service_Shredding_Fee__c;
                    serviceItemToCreateReimbursable.Phase__c = bli.Service_Item__r.Phase__c;
                    serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = bli.Purchase_Order__c == null ? false : true; // MRS 7156 MRS 7250
                    reimbursableItemPerProjectExists = true;
                }

                if( !reimbursableItemPerProjectExists ){
                    serviceItemToCreateReimbursable = ServiceItemServices.getServiceItemShreddingPerProject(bliProject,
                                                                                                        projectIdToServiceItems.get(bliProject.Id),
                                                                                                        projectIdToTaskItems.get(bliProject.Id));
                    serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = bli.Purchase_Order__c == null ? false : true; // MRS 7156 MRS 7250
                }
            }else if( bliProject.Billing_Method__c == ProjectProfileServices.BILLINGMETHODINSTALLMENT || bliProject.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE ){
                serviceItemToCreateReimbursable = ServiceItemServices.getServiceItemShreddingPerProject(bliProject,
                                                                                                        projectIdToServiceItems.get(bliProject.Id),
                                                                                                        projectIdToTaskItems.get(bliProject.Id));
                serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = bli.Purchase_Order__c == null ? false : true; // MRS 7156 MRS 7250
            }
            //Add reimbursable BLI and update all needed data
            if( serviceItemToCreateReimbursable != null && serviceItemToCreateReimbursable.Id != null ){
                updateCurrentDataForShreddingBLIInsert(serviceItemToCreateReimbursable,
                                                        bliProject,
                                                        reimbursableLineItems,
                                                        serviceItemsToUpdate,
                                                        consideredProjectsIdToPhasesSetMap,
                                                        true);
            }
        }

        return reimbursableLineItems;
    }

    @TestVisible
    private static void updateCurrentDataForShreddingBLIInsert(Service_Item__c serviceItemToCreateReimbursable,
                                                                Project_Profile__c bliProject,
                                                                List<Billing_Line_Item__c> reimbursableLineItems,
                                                                List<Service_Item__c> serviceItemsToUpdate,
                                                                Map<Id, Set<Id>> consideredProjectsIdToPhasesSetMap,
                                                                Boolean isPerProjectBli ){
        Billing_Line_Item__c reimbursableLineItem;
        reimbursableLineItem = BillingLineItemServices.newReimbursableLineItemShredding( serviceItemToCreateReimbursable, bliProject );
        reimbursableLineItem.Do_not_create_Invoice__c = bliProject != null && bliProject.PO_Required__c
                                                        && !serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c; // MRS 7156
        serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = true;
        if( isPerProjectBli ){
            reimbursableLineItem.isReimbursableOnProjectLevel__c = true;
        }
        reimbursableLineItems.add(reimbursableLineItem);
        serviceItemsToUpdate.add(serviceItemToCreateReimbursable);
        if( !consideredProjectsIdToPhasesSetMap.containsKey(bliProject.Id) ) consideredProjectsIdToPhasesSetMap.put( bliProject.Id, new Set<id>());
        if( !consideredProjectsIdToPhasesSetMap.get(bliProject.Id).contains(reimbursableLineItem.Phase__c) ){
            Set<Id> projectPhasesSet = consideredProjectsIdToPhasesSetMap.get(bliProject.Id);
            projectPhasesSet.add(reimbursableLineItem.Phase__c);
            consideredProjectsIdToPhasesSetMap.put( bliProject.Id, projectPhasesSet);
        }
    }

    @TestVisible
    private static Boolean isServiceItemSutableToCreateShredingPerInvoice( Billing_Line_Item__c bli, Map<Id, List<Service_Item__c>> projectIdToServiceItems ){
        if( bli.Service_Shredding_Fee__c > 0 &&
                    ( bli.Service_Type__c != TYPE_PLAN_APPROVAL || ( bli.Service_Category__c != CATEGORY_APPLICATION_FILING && bli.Service_Category__c != CATEGORY_APPLICATION_REQUIREMENT ) ) ){
            for (Service_Item__c service : projectIdToServiceItems.get(bli.Project_Profile__c) ) {
                if( service.id == bli.Service_Item__c ){
                    return !service.Doc_Shredding_BLI_Created__c;
                }
            }
        }
        return false;
    }

    @TestVisible
    private static Map<Id, Task_Item__c> taskItemsFromDB {
        get {
            if (null != projectMap.keySet() && !projectMap.keySet().isEmpty() && null == taskItemsFromDB) {
                taskItemsFromDB = new Map<Id, Task_Item__c>([SELECT Service_Item__c, Successor_Milestone__c, Is_Locked__c, Billing_Trigger__c, Billing_Percentage__c, Project_Profile__c
                                                             FROM Task_Item__c
                                                             WHERE Project_Profile__c =: projectMap.keySet()]);
            } else {
                taskItemsFromDB = new Map<Id, Task_Item__c>();

            }
            return taskItemsFromDB;

        }
        set;

    }

    @TestVisible
    private static List<Billing_Line_Item__c> getReimbursableLineItemsPerInvoice( List<Billing_Line_Item__c> lineItems,
                                                                                  Map<Id, Set<Id>> consideredProjectsIdToPhasesSetMap,
                                                                                  List<Service_Item__c> serviceItemsToUpdate,
                                                                                  Map<Id, List<Task_Item__c>> projectIdToTaskItems,
                                                                                  Map<Id, List<Service_Item__c>> projectIdToServiceItems ) {
        List<Billing_Line_Item__c> reimbursableLineItems = new List<Billing_Line_Item__c>();

        for (Billing_Line_Item__c bli: lineItems) {
            Project_Profile__c bliProject = projectMap.get(bli.Project_Profile__c);
            Service_Item__c serviceItemToCreateReimbursable;

            Boolean disableCreateReimbursable = false;
            if( bliProject.No_Document_Shredding__c || bliProject.Pre_billed__c || bli.isReimbursable__c ){
                disableCreateReimbursable = true;
            }else if( bliProject.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE && bliProject.Separate_Phases__c ){
                disableCreateReimbursable = consideredProjectsIdToPhasesSetMap.containsKey(bliProject.Id) && consideredProjectsIdToPhasesSetMap.get(bliProject.Id).contains(bli.Service_Item__r.Phase__c);
            }else{
                disableCreateReimbursable = consideredProjectsIdToPhasesSetMap.containsKey(bliProject.Id);
            }
            if( disableCreateReimbursable ) continue;

            if( bliProject.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE ){
                Boolean reimbursableItemPerInvoiceExists = false;
                if( isServiceItemSutableToCreateShredingPerInvoice( bli, projectIdToServiceItems ) ){
                    serviceItemToCreateReimbursable = new Service_Item__c(Id = bli.Service_Item__c);
                    serviceItemToCreateReimbursable.Shredding_Fees__c = bli.Service_Shredding_Fee__c;
                    serviceItemToCreateReimbursable.Phase__c = bli.Service_Item__r.Phase__c;
                    serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = bli.Purchase_Order__c == null ? false : true; // MRS 7156 MRS 7250
                    reimbursableItemPerInvoiceExists = true;
                }


            } else if (ProjectProfileServices.BILLINGMETHODINSTALLMENT == bliProject.Billing_Method__c || ProjectProfileServices.BILLINGMETHODPERCENTAGE == bliProject.Billing_Method__c) {
                //MRS-5870
                serviceItemToCreateReimbursable = ServiceItemServices.getServiceItemShreddingPerInvoice(bliProject,
                                                                                                        projectIdToServiceItems.get(bliProject.Id),
                                                                                                        projectIdToTaskItems.get(bliProject.Id));
                serviceItemToCreateReimbursable.Doc_Shredding_BLI_Created__c = bli.Purchase_Order__c == null ? false : true; // MRS 7156 MRS 7250

            }
            //Add reimbursable BLI and update all needed data
            if( serviceItemToCreateReimbursable != null && serviceItemToCreateReimbursable.Id != null ){
                updateCurrentDataForShreddingBLIInsert(serviceItemToCreateReimbursable,
                                                        bliProject,
                                                        reimbursableLineItems,
                                                        serviceItemsToUpdate,
                                                        consideredProjectsIdToPhasesSetMap,
                                                        false);
            }
        }


        return reimbursableLineItems;
    }

	public static void updateSecondContactOnProFormaInvoices(Map<Id, Project_Profile__c> newMap) { //MRS 7540
		List<Pro_forma_Invoice__c> proFormaList = [SELECT Id, Project_Profile__c, Second_Contact_Person_Full_Name__c, Second_Contact_Person_Phone__c, Second_Contact_Type__c
													FROM Pro_forma_Invoice__c WHERE Project_Profile__c IN :newMap.keySet()];
		Map<Id, User> usersMap = new Map<Id, User>();
		for(Project_Profile__c pp : newMap.values()) {
			if(pp.Account_Executive__c != null) {
				usersMap.put(pp.Account_Executive__c, new User());
			}
			if(pp.Production_Manager__c != null) {
				usersMap.put(pp.Production_Manager__c, new User());
			}
		}
		if(!usersMap.isEmpty()) usersMap = new Map<Id, User> ([SELECT Id, FirstName, LastName, Phone FROM User WHERE Id IN :usersMap.keySet()]);
		for(Pro_forma_Invoice__c inv : proFormaList) {
			if(newMap.get(inv.Project_Profile__c).Account_Executive__c != null) {
				inv.Second_Contact_Person_Full_Name__c = usersMap.get(newMap.get(inv.Project_Profile__c).Account_Executive__c).FirstName + ' ' + usersMap.get(newMap.get(inv.Project_Profile__c).Account_Executive__c).LastName;
				inv.Second_Contact_Person_Phone__c = usersMap.get(newMap.get(inv.Project_Profile__c).Account_Executive__c).Phone;
				inv.Second_Contact_Type__c = 'Account';
			} else if(newMap.get(inv.Project_Profile__c).Production_Manager__c != null) {
				inv.Second_Contact_Person_Full_Name__c = usersMap.get(newMap.get(inv.Project_Profile__c).Production_Manager__c).FirstName + ' ' + usersMap.get(newMap.get(inv.Project_Profile__c).Production_Manager__c).LastName;
				inv.Second_Contact_Person_Phone__c = usersMap.get(newMap.get(inv.Project_Profile__c).Production_Manager__c).Phone;
				inv.Second_Contact_Type__c = 'Production';
			} else {
				inv.Second_Contact_Person_Full_Name__c = null;
				inv.Second_Contact_Person_Phone__c = null;
				inv.Second_Contact_Type__c = null;
			}
		}
		if(!proFormaList.isEmpty()) UPSERT proFormaList;
	}

    @TestVisible //this method doesn't used
    private static Map<Id, List<Billing_Line_Item__c>> getProformaInvoiceToLineItemsMap(List<Billing_Line_Item__c> lineItems) {
        Map<Id, List<Billing_Line_Item__c>> projectIdToLineItems = new Map<Id, List<Billing_Line_Item__c>>();

        //Group Map by Project
        for (Billing_Line_Item__c item : lineItems) {
            if (!projectIdToLineItems.containsKey(item.Project_Profile__c)) {
                projectIdToLineItems.put(item.Project_Profile__c, new List<Billing_Line_Item__c>());
            }
            projectIdToLineItems.get(item.Project_Profile__c).add(item);
        }
        projectIdToLineItems.remove(null);
        return projectIdToLineItems;
    }

    @TestVisible //this method doesn't used
    private static Map<Id, Map<Id, List<Billing_Line_Item__c>>> getProjectToProformaInvoiceToLineItemsMap(List<Billing_Line_Item__c> bLineItems) {
        Map<Id, Map<Id, List<Billing_Line_Item__c>>> projectToProformaInvoiceToLineItemsMap = new Map<Id, Map<Id, List<Billing_Line_Item__c>>>();

        for (Billing_Line_Item__c bli : bLineItems) {

            if (null != bli.Project_Profile__c) {
                if (!projectToProformaInvoiceToLineItemsMap.containsKey(bli.Project_Profile__c)) {
                    projectToProformaInvoiceToLineItemsMap.put( bli.Project_Profile__c, new Map<Id, List<Billing_Line_Item__c>>() );

                }

            }

            if (null != bli.Pro_forma_Invoice__c) {
                if (projectToProformaInvoiceToLineItemsMap.containsKey(bli.Project_Profile__c) && !projectToProformaInvoiceToLineItemsMap.get(bli.Project_Profile__c).containsKey(bli.Pro_forma_Invoice__c)) {
                    projectToProformaInvoiceToLineItemsMap.get(bli.Project_Profile__c).put(bli.Pro_forma_Invoice__c, new List<Billing_Line_Item__c>());

                }

            }

            if ( projectToProformaInvoiceToLineItemsMap.containsKey(bli.Project_Profile__c) && projectToProformaInvoiceToLineItemsMap.get(bli.Project_Profile__c).containsKey(bli.Pro_forma_Invoice__c) ) {
                projectToProformaInvoiceToLineItemsMap.get(bli.Project_Profile__c).get(bli.Pro_forma_Invoice__c).add(bli);
            }

        }
        return projectToProformaInvoiceToLineItemsMap;

    }

    public static void populateProjectProfileMapForInvoicing( List<Billing_Line_Item__c> billingLineItems ) {
        Set<Id> projectIds = new Set<Id>();
        for( Billing_Line_Item__c bli : billingLineItems ){
            if ( bli.Project_Profile__c != null ) {
                projectIds.add( bli.Project_Profile__c );
            }
        }
        if( !projectIds.isEmpty() ){
            projectMap = ProjectProfileServices.getProgectProfileMapForprocessProforma( projectIds );//MRS-6396
        }

        calculateCutoffDateForProjects( projectMap );

        purchaseOrders = PurchaseOrderServices.getPurchaseOrdersForNewMailroomLineItems( projectMap.keySet() );
    }

    private static void calculateCutoffDateForProjects( Map<Id, Project_Profile__c> projMAp ){
        for( Project_Profile__c proj : projMAp.values() ){
            projectIdToInvoiceCutoffDateMap.put( proj.Id, DateUtils.getDateWithPeriodAndStartDay( Date.today(), proj.Frequency__c, proj.Billing_day__c, proj.Quarterly_Month__c ) );
        }
    }

    private static Boolean isPhaseSeparated( String billingMethodm, Boolean isSeparatePhases, Boolean theSamePhases ){
        return ( billingMethodm != ProjectProfileServices.BILLINGMETHODMILESTONE ) ||
               ( ( billingMethodm == ProjectProfileServices.BILLINGMETHODMILESTONE ) &&
                 ( !isSeparatePhases || ( isSeparatePhases && theSamePhases ) ) );
    }

    private static Boolean isProformaInvoiceForBLI( Billing_Line_Item__c lineItem, Pro_forma_Invoice__c invoice, Project_Profile__c bliProject ){
    system.debug(LoggingLevel.Error,'lineItem.Purchase_Order__c ='+lineItem.Purchase_Order__c);
        return ( ( (lineItem.Milestone_Date__c <= invoice.Invoice_End_Date__c && lineItem.Milestone_Date__c <= projectIdToInvoiceCutoffDateMap.get( lineItem.Project_Profile__c ) ) ||
                   (invoice.Invoice_End_Date__c == Date.today() && lineItem.Milestone_Date__c > projectIdToInvoiceCutoffDateMap.get( lineItem.Project_Profile__c ) ) ||
                   ( billAnyway && isBillAnywayBLI( lineItem ) ) ) && //MRS-7105, MRS-7549
                 lineItem.Purchase_Order__c == invoice.Purchase_Order__c &&
                 lineItem.Project_Profile__c == invoice.Project_Profile__c &&
                 lineItem.Accounting_Contact__c == invoice.Accounting_Contact__c &&
                 isPhaseSeparated( bliProject.Billing_Method__c, bliProject.Separate_Phases__c, lineItem.Phase__c == invoice.Phase__c ) );
    }

    private static Map<Id, List<Pro_forma_Invoice__c>> idOfProjectToProcessedProformaInvoicesList = new Map<Id, List<Pro_forma_Invoice__c>>();
    private static Map<Id, List<Pro_forma_Invoice__c>> idOfProjectToProcessedProformaInvoicesListReimbursable = new Map<Id, List<Pro_forma_Invoice__c>>();

    private static void findOrCreateProformaInvoiceForBLI( Billing_Line_Item__c lineItem, List<Pro_forma_Invoice__c> invoicesToProcess, List<Pro_forma_Invoice__c> invoicesToProcessReimbursable, Boolean additionalConditions, Boolean useRecentlyCreatedPFI ) {
        if ( !fitProformaIvoiceCriteria( lineItem, (invoicesToProcess != null), useRecentlyCreatedPFI ) && additionalConditions ) {
            if( !( projectMap.get(lineItem.Project_Profile__c).PO_Required__c && lineItem.Purchase_Order__c == null )
                || ( projectMap.get(lineItem.Project_Profile__c).PO_Not_Required__c && ( lineItem.isReimbursable__c || lineItem.Is_Check_Processing_Fee__c ) ) || billAnyway ){//MRS-7249
					system.debug(LoggingLevel.Error,'lineItem ='+lineItem);
                Pro_forma_Invoice__c proformaInvoice = createProformaInvoice( lineItem );
                if( invoicesToProcess != null ){
                    invoicesToProcess.add( proformaInvoice );
                    if( !idOfProjectToProcessedProformaInvoicesList.containsKey(lineItem.Project_Profile__c) ){
                        idOfProjectToProcessedProformaInvoicesList.put(lineItem.Project_Profile__c, new List<Pro_forma_Invoice__c>{proformaInvoice});
                    }else{
                        idOfProjectToProcessedProformaInvoicesList.get(lineItem.Project_Profile__c).add(proformaInvoice);
                    }
                }else{
                    invoicesToProcessReimbursable.add( proformaInvoice );
                    if( !idOfProjectToProcessedProformaInvoicesListReimbursable.containsKey(lineItem.Project_Profile__c) ){
                        idOfProjectToProcessedProformaInvoicesListReimbursable.put(lineItem.Project_Profile__c, new List<Pro_forma_Invoice__c>{proformaInvoice});
                    }else{
                        idOfProjectToProcessedProformaInvoicesListReimbursable.get(lineItem.Project_Profile__c).add(proformaInvoice);
                    }
                }
            }
        }
    }

    private static Boolean fitProformaIvoiceCriteria( Billing_Line_Item__c lineItem, Boolean invoicesToProcessNotIsReimbursable, Boolean useRecentlyCreatedPFI ){
        Boolean proformaFound = false;
        Project_Profile__c currentProject = projectMap.get( lineItem.Project_Profile__c );
        List<Pro_forma_Invoice__c> invoicesToProcess = new List<Pro_forma_Invoice__c>();

        if( invoicesToProcessNotIsReimbursable ){
            if( idOfProjectToProcessedProformaInvoicesList.containsKey(lineItem.Project_Profile__c) && lineItem.Project_Profile__c != null ){
                invoicesToProcess = idOfProjectToProcessedProformaInvoicesList.get(lineItem.Project_Profile__c);
            }
            //MRS-7228
            if ( useRecentlyCreatedPFI && pfiForBillAnyway != null && pfiForBillAnyway.containsKey(lineItem.Project_Profile__c) ){
                invoicesToProcess.addAll(pfiForBillAnyway.get(lineItem.Project_Profile__c));
            }
        }else{
            if( idOfProjectToProcessedProformaInvoicesListReimbursable.containsKey(lineItem.Project_Profile__c) && lineItem.Project_Profile__c != null ){
                invoicesToProcess = idOfProjectToProcessedProformaInvoicesListReimbursable.get(lineItem.Project_Profile__c);
            }
        }

        for ( Pro_forma_Invoice__c invoice : invoicesToProcess ) {
            if ( isProformaInvoiceForBLI( lineItem, invoice, currentProject ) ) {
                proformaFound = true;
                lineItem.Pro_forma_Invoice__c = invoice.Id;
				if(invoice.Total_Billed_Amount_Without_Recaped_BLIs__c == null ) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c = 0; //MRS 7550
				if(!lineItem.Hide_from_Recap__c) {
					if(lineItem.Amount__c != null) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c += lineItem.Amount__c;
					if(lineItem.Sales_Tax_Amount__c != null) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c += lineItem.Sales_Tax_Amount__c;
				}
                break;
            }
        }

        return proformaFound;
    }

    //MRS-7228
    public static Set<Id> bliWithPreviuslyCreatedPFIForBillAnyway;
    private static Map<Id, List<Pro_forma_Invoice__c>> pfiForBillAnyway;

    private static void prepareExistingProformaInvoiceForBillAnywayBLIs(){
        if (billAnyway && bliWithPreviuslyCreatedPFIForBillAnyway != null && !bliWithPreviuslyCreatedPFIForBillAnyway.isEmpty()){
            Map<Id, Pro_forma_Invoice__c> existingProFormas = new Map<Id, Pro_forma_Invoice__c>();
            for (Billing_Line_Item__c bli : [SELECT Id, Pro_forma_Invoice__c, Pro_forma_Invoice__r.Name, Pro_forma_Invoice__r.Invoice_Exceeded_PO__c,
                                                    Pro_Forma_Invoice__r.Accounting_Contact__c, Pro_Forma_Invoice__r.Phase__c,
                                                    Pro_forma_Invoice__r.cl_Create_FFA_Invoice__c, Pro_forma_Invoice__r.Purchase_Order__c, Pro_Forma_Invoice__r.Invoice_End_Date__c,
                                                    Pro_forma_Invoice__r.Purchase_Order__r.Received_and_Verified__c, Pro_forma_Invoice__r.Project_Profile__c,
                                                    Pro_forma_Invoice__r.Total_Billed_Amount_Without_Recaped_BLIs__c //MRS-7392
                                             FROM Billing_Line_Item__c
                                             WHERE Id IN : bliWithPreviuslyCreatedPFIForBillAnyway AND
                                                    Pro_forma_Invoice__c != null AND
                                                    Pro_forma_Invoice__r.Sales_Invoice__c = null]){
                existingProFormas.put(bli.Pro_forma_Invoice__c, bli.Pro_forma_Invoice__r);
            }
            pfiForBillAnyway = new Map<Id, List<Pro_Forma_Invoice__c>>();
            for (Pro_forma_Invoice__c pfi : existingProFormas.values()){
                if ( !pfiForBillAnyway.containsKey( pfi.Project_Profile__c ) ){
                    pfiForBillAnyway.put( pfi.Project_Profile__c, new List<Pro_Forma_Invoice__c>());
                }
                pfiForBillAnyway.get( pfi.Project_Profile__c ).add( pfi );
            }
        }
    }

    private static Boolean isBillAnywayBLI(Billing_Line_Item__c lineItem){
        return (lineItem.Project_Profile__r.PO_Required__c && null == lineItem.Purchase_Order__c) || (lineItem.Milestone_Date__c > projectIdToInvoiceCutoffDateMap.get( lineItem.Project_Profile__c) );
    }

    private static void createProformaInvoiceList( List<Billing_Line_Item__c> billingLineItems, Boolean doNotBillReimbursablesAlone, Boolean invoiceBatchIsExecuted ) {
        Map<Id, Map<Id, List<Billing_Line_Item__c>>> phaseIdToLineItemsMap;
        Map<Id, List<Billing_Line_Item__c>> serviceIdToLineItemsMap;
        Set<Id> idsOfProjectsThatHaveRegularBlis = new Set<Id>();

        Set<Billing_Line_Item__c> lineItemsToCheckInvoices = new Set<Billing_Line_Item__c>();

        List<Pro_forma_Invoice__c> proFormaInvoiceForRBLIToCreate = new List<Pro_forma_Invoice__c>();
        Map<Id, Billing_Line_Item__c> RBLIMap = new Map<Id, Billing_Line_Item__c>();
        Map<Id, Billing_Line_Item__c> reimbWithoutSeparateInvoiceBLIMap = new Map<Id, Billing_Line_Item__c>();
        List<Billing_Line_Item__c> sortedBLIs = new List<Billing_Line_Item__c>();

        // New version
        List<Pro_forma_Invoice__c> proFormaInvoiceToCreate = new List<Pro_forma_Invoice__c>();
        List<Pro_forma_Invoice__c> reimbursableProFormaInvoiceToCreate = new List<Pro_forma_Invoice__c>();
        List<Billing_Line_Item__c> regularBLIs = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> regularBillAnywayBLIs = new List<Billing_Line_Item__c>();
        List<Billing_Line_Item__c> reimbursableBLIs = new List<Billing_Line_Item__c>();
        restrictionsBasedPO = '';
		system.debug(LoggingLevel.Error,'billingLineItems ='+billingLineItems);
        // Split on Regular and Reimbursable BLIs and remove BLIs that required PO but dont have
        for( Billing_Line_Item__c lineItem : billingLineItems ){
            if( !projectMap.containsKey( lineItem.Project_Profile__c ) ) continue;

            if( !( lineItem.Project_Profile__r.PO_Required__c && lineItem.Purchase_Order__c == null ) ||
        		( lineItem.Project_Profile__r.PO_Not_Required__c && ( lineItem.isReimbursable__c || lineItem.Is_Check_Processing_Fee__c ) ) ||
				billAnyway ) {

        		if( lineItem.isReimbursable__c || lineItem.Is_Check_Processing_Fee__c ){
	                reimbursableBLIs.add( lineItem );
	            } else {
                    //MRS-7228
                    if (!billAnyway){
                        regularBLIs.add( lineItem );
                    } else {
                        if ( isBillAnywayBLI (lineItem) ){
                            regularBillAnywayBLIs.add(lineItem);
                        } else {
                            regularBLIs.add( lineItem );
                        }
                    }
	            }
        	}else{
        		if ( invoiceBatchIsExecuted ){
        			restrictionsBasedPO += '\n' + lineItem.Name;
        		}
        	}
		}

        //MRS-7228
        if(billAnyway){
            prepareExistingProformaInvoiceForBillAnywayBLIs();
        }

		system.debug(LoggingLevel.Error,'regularBLIs ='+regularBLIs);
        //Work with Regular BLIs
        for( Billing_Line_Item__c lineItem : regularBLIs ) {
            findOrCreateProformaInvoiceForBLI( lineItem, proFormaInvoiceToCreate, null, true, true );
            idsOfProjectsThatHaveRegularBlis.add( lineItem.Project_Profile__c );
        }

        //MRS-7228
        if ( !regularBillAnywayBLIs.isEmpty() ){
            //Work with Regular BLIs Bill Anyway
            for( Billing_Line_Item__c lineItem : regularBillAnywayBLIs ) {
                findOrCreateProformaInvoiceForBLI( lineItem, proFormaInvoiceToCreate, null, true, true );
            }
        }

        //Work with Reimbursable BLIs
        for( Billing_Line_Item__c lineItem : reimbursableBLIs ) {
            Project_Profile__c currentProject = projectMap.get( lineItem.Project_Profile__c );

            //MRS-7482
            if( doNotBillReimbursablesAlone && !idsOfProjectsThatHaveRegularBlis.contains(lineItem.Project_Profile__c) ){
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE "Do Not run Reimbursable alone" and reimbursables are without regular Blis ========= ');
                continue;
            }

            //MRS-7482
            if( currentProject.Separate_Reimbursables__c && doNotBillReimbursablesAlone && currentProject.PO_Not_Required__c ){
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE "PO Not Required" and "Do Not run Reimbursable alone" ========= ');
                if ( idOfProjectToProcessedProformaInvoicesList.containsKey(lineItem.Project_Profile__c) || (pfiForBillAnyway != null && pfiForBillAnyway.containsKey(lineItem.Project_Profile__c)) ){
                    findOrCreateProformaInvoiceForBLI( lineItem, null, reimbursableProFormaInvoiceToCreate, true, false );
                }
                continue;
            }

	    	// MRS-7458 MRS-7481
            if( currentProject.PO_Not_Required__c ) {
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE PO NOt Required ========= ');
                findOrCreateProformaInvoiceForBLI( lineItem, null, reimbursableProFormaInvoiceToCreate, true, false );
				continue;
            }

            // MRS-3514: Cases 1 & 5
            if( currentProject.Separate_Reimbursables__c && doNotBillReimbursablesAlone ) {
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE 1 & 5 ========= ');
                if( fitProformaIvoiceCriteria( lineItem, true, false ) ||
                    lineItem.Milestone_Date__c < Date.today() - 60 ) { //MRS-4553
                        findOrCreateProformaInvoiceForBLI( lineItem, null, reimbursableProFormaInvoiceToCreate, true, false );
                }
            }

            // MRS-3514: Cases 2 & 6
            if( currentProject.Separate_Reimbursables__c && !doNotBillReimbursablesAlone ) {
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE 2 & 6 ========= ');
                findOrCreateProformaInvoiceForBLI( lineItem, null, reimbursableProFormaInvoiceToCreate, true, false );
            }

            // MRS-3514: Cases 3 & 7
            if( !currentProject.Separate_Reimbursables__c && doNotBillReimbursablesAlone ) {
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE 3 & 7 ========= ');
                findOrCreateProformaInvoiceForBLI( lineItem, proFormaInvoiceToCreate, null,
                                                   lineItem.Milestone_Date__c < Date.today() - 60, false ); //MRS-4553 7341
            }

            // MRS-3514: Cases 4 & 8
            if( !currentProject.Separate_Reimbursables__c && !doNotBillReimbursablesAlone ) {
                system.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@ CASE 4 & 8 ========= ');
                findOrCreateProformaInvoiceForBLI( lineItem, proFormaInvoiceToCreate, null, true, false );
            }
        }

        List<Pro_forma_Invoice__c> proformaAll = new List<Pro_forma_Invoice__c>();
        proformaAll.addAll( proFormaInvoiceToCreate );
        proformaAll.addAll( reimbursableProFormaInvoiceToCreate );

        //for billing job
        if( invoiceBatchIsExecuted ){
            if ( ddpHelperMap == null || ddpHelperMap.isEmpty() ){
                ddpHelperMap = new Map<String, DDP_Helper__c>();
                List<DDP_Helper__c> ddpHelperList = new List<DDP_Helper__c>();
                List<DDP_Helper__c> ddpHelperConfigurationRecord = [Select Id, Type__c, Text1__c, Text2__c, Create_FFA_Invoice__c, Email_Invoices__c From DDP_Helper__c Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT];

                for( Schema.PicklistEntry item: Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ){
                    ddpHelperList.add( new DDP_Helper__c( Type__c = DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB,
                                                            Delivery_Method__c = item.getValue(),
                                                            Email_Invoices__c = ( item.getValue() == 'Email' ) ? ddpHelperConfigurationRecord[0].Email_Invoices__c : false,
                                                            Create_FFA_Invoice__c = ddpHelperConfigurationRecord[0].Create_FFA_Invoice__c ) );
                }
                insert ddpHelperList;

                for( DDP_Helper__c item: [Select Id, Type__c, Delivery_Method__c From DDP_Helper__c Where Id IN: ddpHelperList] ){
                    ddpHelperMap.put( item.Delivery_Method__c, item );
                }
            }

            for( Pro_forma_Invoice__c item: proformaAll ) {
                String itemDeliveryMethod = projectMap.get(item.Project_Profile__c).Delivery_Method__c;
                item.DDP_Helper__c = ddpHelperMap.get( itemDeliveryMethod ).Id;
            }
        }

        if ( invoiceBatchIsExecuted ){
            Database.SaveResult[] srList = Database.insert( proformaAll, false );
            createPFIErrorsHendle = '';

            for ( Integer i = 0; i < proformaAll.size(); i++ ) {
               Database.SaveResult sr = srList[i];
               Pro_forma_Invoice__c origRecord = proformaAll[i];
               if ( !sr.isSuccess() ) {
                   for(Database.Error err : sr.getErrors()) {
                       createPFIErrorsHendle += '\n' + origRecord.Project_Profile__c + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                   }
               }
            }
        } else {
            insert proformaAll;
        }

        Set<String> bliWithoutInvoices = new Set<String>();
        for( Billing_Line_Item__c lineItem : billingLineItems ){
            Project_Profile__c bliProject =  projectMap.get(lineItem.Project_Profile__c);
            if( ( bliProject.Separate_Reimbursables__c || bliProject.PO_Not_Required__c ) && ( lineItem.isReimbursable__c || lineItem.Is_Check_Processing_Fee__c ) ) {
               fitProformaIvoiceCriteria( lineItem, false, false );
            } else {
            	if( !( lineItem.Project_Profile__r.PO_Required__c && lineItem.Purchase_Order__c == null ) ||
	        		( lineItem.Project_Profile__r.PO_Not_Required__c && ( lineItem.isReimbursable__c || lineItem.Is_Check_Processing_Fee__c ) ) ||
					billAnyway ) {

					fitProformaIvoiceCriteria( lineItem, true, true );
				}
            }
            if( lineItem.Pro_forma_Invoice__c == null ){
                bliWithoutInvoices.add( lineItem.Name );
            } else {
                lineItem.Billed__c = true;
            }
        }

        if ( invoiceBatchIsExecuted ){
            Database.SaveResult[] srList = Database.update( billingLineItems, false );

            updateBLIErrorsHendle = '';

            for ( Integer i = 0; i < billingLineItems.size(); i++ ) {
                Database.SaveResult sr = srList[i];
                Billing_Line_Item__c origRecord = billingLineItems[i];
                if ( !sr.isSuccess() ) {
                   for(Database.Error err : sr.getErrors()) {
                       updateBLIErrorsHendle += '\n' + origRecord.Name + ' ' + err.getStatusCode() + ': ' + err.getMessage();
                   }
                }
            }
        } else {
            update billingLineItems;
        }

        if( !bliWithoutInvoices.isEmpty() && !invoiceBatchIsExecuted && !billAnyway ){
            String namesString = MilroseDevHelper.joinStrings( bliWithoutInvoices, ', ' );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, DO_NOT_BILL_REIMPURSABLES_AALONE + namesString ) );
        }
    }

     public static Pro_forma_Invoice__c createProformaInvoice(Billing_Line_Item__c lineItem) {
        Project_Profile__c project = projectMap.get(lineItem.Project_Profile__c);

        Pro_forma_Invoice__c invoice          = new Pro_forma_Invoice__c();
        invoice.Billing_Client_Company__c     = lineItem.Billing_Client__c;
        invoice.Billing_Contact__c            = lineItem.Billing_Contact__c;
        invoice.Accounting_Contact_Company__c = lineItem.Accounting_Contact_Company__c;
        invoice.Accounting_Contact__c         = lineItem.Accounting_Contact__c;
        invoice.Project_Profile__c            = lineItem.Project_Profile__c;
        invoice.Purchase_Order__c             = lineItem.Purchase_Order__c;
        //MRS-4092
        if( project.Separate_Phases__c ){
            invoice.Phase__c = lineItem.Phase__c;
        }
        invoice.Project_Address__c            = lineItem.Project_Address__c;

        invoice.Send_Copy_To_Emails__c          = project.Send_Copy_To__c;
        invoice.Project_Address_Building_AKA__c = project.Address_Building_AKA__c;
        invoice.Client_Project__c               = project.Client_Project__c;
        invoice.Invoice_Format__c               = project.Invoice_Format__c;
        invoice.Floor_s__c                      = project.Floor_s__c;
        invoice.Account_Manager__c              = project.Account_Executive__c;
        invoice.Project_Details__c              = project.Project_Name__c;
        invoice.Invoice_Date__c                 = Date.today();

        // Invoice Cutoff Date - Invoice_End_Date__c
        invoice.Invoice_End_Date__c      = lineItem.Milestone_Date__c <= projectIdToInvoiceCutoffDateMap.get(project.Id) ? projectIdToInvoiceCutoffDateMap.get(project.Id) : Date.today(); //MRS-7105
        invoice.Only_Reimb_In_Invoice__c = lineItem.isReimbursable__c;

		if(invoice.Total_Billed_Amount_Without_Recaped_BLIs__c == null ) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c = 0; //MRS 7550
		if(!lineItem.Hide_from_Recap__c) {
			if(lineItem.Amount__c != null) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c += lineItem.Amount__c;
			if(lineItem.Sales_Tax_Amount__c != null) invoice.Total_Billed_Amount_Without_Recaped_BLIs__c += lineItem.Sales_Tax_Amount__c;
		}

        if (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODINSTALLMENT) ||
           (project.Billing_Method__c.equals(ProjectProfileServices.BILLINGMETHODPERCENTAGE) && project.Interval__c)) {
               invoice.Tax__c = (null == lineItem.Sales_Tax_Amount__c ? 0 : lineItem.Sales_Tax_Amount__c) / ((null == project.Billing_Dates__r || project.Billing_Dates__r.isEmpty()) ? 1 : Integer.valueOf(project.Billing_Dates__r.size()));

        }
		system.debug(LoggingLevel.Error,'invoice ='+invoice);
        return invoice;

    }

    public static Set<Id> filterPurchaseOrdersForTotalAmount( Map<Id, Pro_forma_Invoice__c> newProformaInvoiceMap, Map<Id, Pro_forma_Invoice__c> oldProformaInvoiceMap ){
        Set<Id> filteredPurchaseOrders = new Set<Id>();
        if( oldProformaInvoiceMap == null ){
            for( Pro_forma_Invoice__c invoice : newProformaInvoiceMap.values() ) {
                if( invoice.Purchase_Order__c != null ) filteredPurchaseOrders.add(invoice.Purchase_Order__c);
            }
            return filteredPurchaseOrders;
        }
        if( newProformaInvoiceMap == null ){
            for( Pro_forma_Invoice__c invoice : oldProformaInvoiceMap.values() ) {
                if( invoice.Purchase_Order__c != null ) filteredPurchaseOrders.add(invoice.Purchase_Order__c);
            }
            return filteredPurchaseOrders;
        }
        for( Pro_forma_Invoice__c invoice : newProformaInvoiceMap.values() ) {
            if( invoice.Total_Billed_Amount__c != oldProformaInvoiceMap.get(invoice.Id).Total_Billed_Amount__c
                || invoice.Purchase_Order__c != oldProformaInvoiceMap.get(invoice.Id).Purchase_Order__c ||
                invoice.Sales_Invoice__c != oldProformaInvoiceMap.get(invoice.Id).Sales_Invoice__c
				|| invoice.Hide_from_Recap__c != oldProformaInvoiceMap.get(invoice.Id).Hide_from_Recap__c) { //MRS 7502
                if( invoice.Purchase_Order__c != null ) filteredPurchaseOrders.add(invoice.Purchase_Order__c);
            }
        }
        return filteredPurchaseOrders;
    }

    public static void restrictFFAInvoiceCreation( List<Pro_forma_Invoice__c> newIvoicesList ){
        Set<Id> purchaseOrdersId = new Set<Id>();
        for( Pro_forma_Invoice__c invoice : newIvoicesList ) {
            purchaseOrdersId.add(invoice.Purchase_Order__c);
        }
        Map<Id, Purchase_Order__c> purchaseOrdersMap = new Map<Id, Purchase_Order__c>([SELECT Id, Override_Billing_Restrictions__c, Purchase_Order_Amount__c, Total_Billing__c, Pending_Billing__c, /*MRS 7527*/
																						PO_Excludes_Sales_Tax__c, /*MRS-7577*/
                                                                                        (Select Id From Pro_forma_Invoices__r)
                                                                                        FROM Purchase_Order__c WHERE Id IN: purchaseOrdersId]);
		for(Purchase_Order__c po : purchaseOrdersMap.values()) { //MRS 7527 7550 7551
			if(po.Purchase_Order_Amount__c == null) po.Purchase_Order_Amount__c =0;
			if(po.Total_Billing__c == null) po.Total_Billing__c =0;
			if(po.Pending_Billing__c == null) po.Pending_Billing__c =0;
		}

        for( Pro_forma_Invoice__c invoice : newIvoicesList ){
            Map<Id, Pro_forma_Invoice__c> poInvoices = purchaseOrdersMap.containsKey(invoice.Purchase_Order__c) ?
                new Map<Id, Pro_forma_Invoice__c>(purchaseOrdersMap.get(invoice.Purchase_Order__c).Pro_forma_Invoices__r) :
                new Map<Id, Pro_forma_Invoice__c>();
			Decimal amountFromBlisToBeCompared = 0;
			if(invoice.Purchase_Order__c != null && purchaseOrdersMap.get(invoice.Purchase_Order__c).PO_Excludes_Sales_Tax__c ) { //MRS 7577
				amountFromBlisToBeCompared = invoice.Total_Billed_AmNoTax_Without_Recaped_BLI__c == null ? 0 : invoice.Total_Billed_AmNoTax_Without_Recaped_BLI__c;
			} else {
				amountFromBlisToBeCompared = invoice.Total_Billed_Amount_Without_Recaped_BLIs__c == null ? 0 : invoice.Total_Billed_Amount_Without_Recaped_BLIs__c;
			}
			Decimal remainingPoAmount = invoice.Purchase_Order__c == null ? 0 : purchaseOrdersMap.get(invoice.Purchase_Order__c).Purchase_Order_Amount__c
																				- purchaseOrdersMap.get(invoice.Purchase_Order__c).Total_Billing__c
																				- purchaseOrdersMap.get(invoice.Purchase_Order__c).Pending_Billing__c;
			Double remainingAmount = poInvoices.containsKey(invoice.Id) ? remainingPoAmount + amountFromBlisToBeCompared : remainingPoAmount; //MRS 7392 7527 7550 7551 7577

            if( !ProformaInvoiceServices.invoiceAmountHasBeenDeducated && invoice.Purchase_Order__c != null && !invoice.cl_Create_FFA_Invoice__c && amountFromBlisToBeCompared > remainingAmount && !purchaseOrdersMap.get(invoice.Purchase_Order__c).Override_Billing_Restrictions__c ){
                invoice.Invoice_Exceeded_PO__c = true;
            }

			System.debug(LoggingLevel.ERROR, '### invoice.Id = ' + invoice.Id);
			System.debug(LoggingLevel.ERROR, '### poInvoices.containsKey(invoice.Id) = ' + poInvoices.containsKey(invoice.Id));
			System.debug(LoggingLevel.ERROR, '### invoice.Remaining_PO_Amount__c = ' + invoice.Remaining_PO_Amount__c);
			System.debug(LoggingLevel.ERROR, '### amountFromBlisToBeCompared = ' + amountFromBlisToBeCompared);
			System.debug(LoggingLevel.ERROR, '### invoice.Subtotal__c = ' + invoice.Subtotal__c);
			System.debug(LoggingLevel.ERROR, '### remainingAmount = ' + remainingAmount);
			System.debug(LoggingLevel.ERROR, '############################################################################################################');
			System.debug(LoggingLevel.ERROR, '### invoice.Purchase_Order__c = ' + invoice.Purchase_Order__c);
			System.debug(LoggingLevel.ERROR, '### invoice.cl_Create_FFA_Invoice__c = ' + invoice.cl_Create_FFA_Invoice__c);
			System.debug(LoggingLevel.ERROR, '### invoice.Invoice_Exceeded_PO__c = ' + invoice.Invoice_Exceeded_PO__c);

        }
		ProformaInvoiceServices.invoiceAmountHasBeenDeducated = true;
    }

    public static void totalBilledAmount(Map<Id, Set<Id>> billinLineItemToProFormaMap, Map<Id, Billing_Line_Item__c> bliMap ) {

		//MRS 7392
		Map<Id, Decimal> invoiceIdToTotalWithoutRecaped = new Map<Id, Decimal>();
		Map<Id, Decimal> invoiceIdToTotalWithoutRecaperNoTax = new Map<Id, Decimal>(); //MRS-7577
		for(AggregateResult ar : [SELECT Pro_forma_Invoice__c pfi, SUM(Amount__c) am, SUM(Sales_Tax_Amount__c) sta
				                                            FROM Billing_Line_Item__c
				                                            WHERE Pro_forma_Invoice__c IN : billinLineItemToProFormaMap.keySet()
																AND Hide_from_Recap__c = false
				                                            GROUP BY Pro_forma_Invoice__c
				                                            ORDER BY Pro_forma_Invoice__c]) {
			invoiceIdToTotalWithoutRecaped.put((Id)ar.get('pfi'), (Decimal)ar.get('am') + (Decimal)ar.get('sta'));
			invoiceIdToTotalWithoutRecaperNoTax.put((Id)ar.get('pfi'), (Decimal)ar.get('am')); //MRS-7577
		}

        List<AggregateResult> aggResults = [SELECT Pro_forma_Invoice__c pfi, SUM(Amount__c) am, SUM(Sales_Tax_Amount__c) sta,
                                                SUM(cl_Credit_1_Amount__c) ca1, SUM(cl_Credit_2_Amount__c) ca2, SUM(Credit_1_Tax_Amount__c) cta1,
                                                SUM(Credit_2_Tax_Amount__c) cta2
                                            FROM Billing_Line_Item__c
                                            WHERE Pro_forma_Invoice__c IN : billinLineItemToProFormaMap.keySet()
                                            GROUP BY Pro_forma_Invoice__c
                                            ORDER BY Pro_forma_Invoice__c];

        List<Pro_forma_Invoice__c> proFormaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (AggregateResult ar : aggResults) {
            proFormaInvoiceList.add ( new Pro_forma_Invoice__c( Id = (Id)ar.get('pfi'), Subtotal__c = (Decimal)ar.get('am'),
                                      Tax__c = (Decimal)ar.get('sta'), Credit_1_Amount__c = (Decimal)ar.get('ca1'),
                                      Credit_2_Amount__c = (Decimal)ar.get('ca2'), Credit_1_Tax_Amount__c = (Decimal)ar.get('cta1'),
                                      Credit_2_Tax_Amount__c = (Decimal)ar.get('cta2'),
			Total_Billed_Amount_Without_Recaped_BLIs__c = invoiceIdToTotalWithoutRecaped.get((Id)ar.get('pfi')) != null ? invoiceIdToTotalWithoutRecaped.get((Id)ar.get('pfi')): 0,
			Total_Billed_AmNoTax_Without_Recaped_BLI__c = invoiceIdToTotalWithoutRecaperNoTax.get((Id)ar.get('pfi')) != null ? invoiceIdToTotalWithoutRecaperNoTax.get((Id)ar.get('pfi')): 0 ) ); //MRS 7392 MRS-7577
        }
        if (billinLineItemToProFormaMap.keySet().size() > proFormaInvoiceList.size()){
            Set<Id> tmpProFormaSetId = new Map<Id, Pro_forma_Invoice__c>(proFormaInvoiceList).keySet();
            for (Id idItem : billinLineItemToProFormaMap.keySet()){
                if (!tmpProFormaSetId.contains(idItem)){
                    proFormaInvoiceList.add ( new Pro_forma_Invoice__c( Id = idItem, Subtotal__c = 0 ) );
                }
            }
        }
        try{
            update proFormaInvoiceList;
        }catch ( DMLException dmlEx ){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                for (Id bliId : billinLineItemToProFormaMap.get(proFormaInvoiceList[dmlEx.getDmlIndex(i)].Id)){
                    if (bliMap.containsKey(bliId)){
                        bliMap.get(bliId).addError( 'Update Pro-forma Invoice Error' + dmlEx.getMessage() );
                    }
                }
            }
        }
    }

    public static Set<Id> filterProFormaInvoicesForOutstandingAmountsCalculation(List<Pro_Forma_Invoice__c> newMap, Map<Id, Pro_Forma_Invoice__c> oldMap) {
        Set<Id> filteredProfileIds = new Set<Id>();
        if( oldMap == null ) {
            for( Pro_Forma_Invoice__c invItem : newMap ) {
                if( invItem.Amount_Due__c != null && invItem.Amount_Due__c != 0 ) {
                    filteredProfileIds.add( invItem.Project_Profile__c );
                }
            }
        } else {
            for( Pro_Forma_Invoice__c invItem : newMap ) {
                if( invItem.Amount_Due__c != null && invItem.Amount_Due__c != oldMap.get(invItem.Id).Amount_Due__c ) {
                    filteredProfileIds.add( invItem.Project_Profile__c );
                    filteredProfileIds.add( oldMap.get(invItem.Id).Project_Profile__c );
                }
            }
        }
        filteredProfileIds.remove(null);
        return filteredProfileIds;
    }


    public static List<Pro_forma_Invoice__c> filteredProFormaInvoiceWithChangedAddressContact (List<Pro_forma_Invoice__c> newProFormaInvoiceList, Map<Id,Pro_forma_Invoice__c> oldProformaInvoiceMap){
        List<Pro_forma_Invoice__c> proformaInvoiceFilteredList = new List<Pro_forma_Invoice__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : newProFormaInvoiceList){
            Pro_forma_Invoice__c proformaInvoiceOld = oldProformaInvoiceMap.get(proformaInvoiceItem.Id);
            if (proformaInvoiceItem.Billing_Client_Company__c != proformaInvoiceOld.Billing_Client_Company__c ||
                proformaInvoiceItem.Billing_Contact__c != proformaInvoiceOld.Billing_Contact__c ||
                proformaInvoiceItem.Accounting_Contact_Company__c != proformaInvoiceOld.Accounting_Contact_Company__c ||
                proformaInvoiceItem.Accounting_Contact__c != proformaInvoiceOld.Accounting_Contact__c ||
   				proformaInvoiceItem.Project_Address__c != proformaInvoiceOld.Project_Address__c){
                proformaInvoiceFilteredList.add(proformaInvoiceItem);
            }
        }
        return proformaInvoiceFilteredList;
    }

    public static void updateBillingLIAddressContactValues (List<Pro_forma_Invoice__c> newProFormaInvoiceList){
        if (newProFormaInvoiceList == null || newProFormaInvoiceList.isEmpty()){
            return;
        }

        List<Billing_Line_Item__c> billingLineItemUpdatedList = [SELECT Id, Billing_Client__c, Billing_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c,
                                                                        Project_Address__c, Project_Profile__c, Pro_forma_Invoice__c, Pro_forma_Invoice__r.Billing_Client_Company__c,
                                                                        Pro_forma_Invoice__r.Billing_Contact__c, Pro_forma_Invoice__r.Accounting_Contact_Company__c,
                                                                        Pro_forma_Invoice__r.Accounting_Contact__c, Pro_forma_Invoice__r.Project_Address__c,
                                                                        Pro_forma_Invoice__r.Project_Profile__c
                                                                 FROM Billing_Line_Item__c
                                                                 WHERE Pro_forma_Invoice__c IN : newProFormaInvoiceList];

        if (billingLineItemUpdatedList.isEmpty()){
            return;
        }

        for (Billing_Line_Item__c billingLineItem : billingLineItemUpdatedList){
            billingLineItem.Billing_Client__c = billingLineItem.Pro_forma_Invoice__r.Billing_Client_Company__c;
            billingLineItem.Billing_Contact__c = billingLineItem.Pro_forma_Invoice__r.Billing_Contact__c;
            billingLineItem.Accounting_Contact_Company__c = billingLineItem.Pro_forma_Invoice__r.Accounting_Contact_Company__c;
            billingLineItem.Accounting_Contact__c = billingLineItem.Pro_forma_Invoice__r.Accounting_Contact__c;
			billingLineItem.Project_Address__c = billingLineItem.Pro_forma_Invoice__r.Project_Address__c;
        }

        try {
            update billingLineItemUpdatedList;
        } catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Pro_forma_Invoice__c proformaInvoiceWithError = new Map<Id, Pro_forma_Invoice__c>(newProFormaInvoiceList).get(billingLineItemUpdatedList[dmlEx.getDmlIndex(i)].Pro_forma_Invoice__c);
                proformaInvoiceWithError.addError('Can not update related BLI ' + dmlEx.getMessage());
            }
        }
    }

    public static List<Pro_forma_Invoice__c> getProformaInvoiceByIds(Set<Id> ids) {
        if (null == ids || ids.isEmpty()) {
            return new List<Pro_forma_Invoice__c>();

        }
        return new List<Pro_forma_Invoice__c>([SELECT Invoice_End_Date__c, Purchase_Order__c, Project_Profile__c, Accounting_Contact__c, Phase__c, Id,
                                                      cl_Create_FFA_Credit_Note_2__c, cl_Create_FFA_Credit_Note_1__c, cl_Create_FFA_Invoice__c,
                                                      Contains_Hourly_Consulting__c, cl_FFA_Invoice_Created__c, Contains_Fedex_Mailroom__c,
                                                      Contains_Mess_Meilroom__c, Contains_Sredding__c, Contains_Scanning__c, Contains_AmEx_Checks__c,
                                                      cl_FF_Sales_Credit_Note_1__r.c2g__CreditNoteDate__c, cl_FF_Sales_Credit_Note_2__r.c2g__CreditNoteDate__c,

                                                      Subtotal__c, Sales_Invoice__c, Project_Number__c, Project_Name__c, Project_Address__c,  A_R_Coordinator_Email__c,
                                                      Name_without_Prefix__c, Floor_s__c, Accounting_Contact_Full_Name__c, Accounting_Contact_Email__c, Invoice_Date__c,
                                                      Accounting_Contact_Email_Address__c, Accounting_Contact_Company__c, Accounting_Contact_Address__c,
                                                      Account_Manager__r.Name, Account_Manager__c, A_R_Coordinator_Phone__c, A_R_Coordinator_Full_Name__c,
                                                      cl_FF_Sales_Credit_Note_Name_2__c, cl_FF_Sales_Credit_Note_Name_1__c, Client_Project__c,
                                                      Purchase_Order__r.Purchase_Order__c, Project_Profile__r.Project_Address__c, A_R_Coordinator__r.Email,
                                                      Billing_Client_Company__r.A_R_coordinator__r.Email, Display_Text_on_Invoice__c,

                                                      Project_Profile__r.Total_Due__c, Project_Profile__r.Outst_Amt_Today__c, Project_Profile__r.Outst_Amt_90__c,
                                                      Project_Profile__r.Outst_Amt_90_Plus__c, Project_Profile__r.Outst_Amt_60__c, Project_Profile__r.Outst_Amt_30__c,
                                                      Project_Profile__r.Frequency__c, Project_Profile__r.Billing_Method__c, Project_Profile__r.Interval__c,

                                                      Billing_Contact__r.MailingPostalCode, Billing_Contact__r.MailingState, Billing_Contact__r.MailingCity,
                                                      Billing_Contact__r.MailingStreet, Billing_Contact__r.Name, Billing_Contact__r.Salutation, Billing_Contact__c,
                                                      Billing_Client_Company__r.Name, Billing_Client_Company__c, Total_Billed_Amount__c, Purchase_Order_Amount__c,
                                                      Credit_1_Amount__c, Credit_1_Amount_Due__c, Credit_2_Amount_Due__c, Credit_2_Tax_Amount__c, Credit_2_Amount__c, Credit_1_Tax_Amount__c,

                                                      (SELECT Id, Service_Item__c, cl_Credit_1_Amount__c, cl_Credit_2_Amount__c, Description__c,
                                                              Service_Name__c, Service_Name_Short__c, Municipal_Agency_ID__c, isReimbursable__c, Milestone_Date__c,
                                                              Service_Item__r.Subtype__c, Service_Item__r.Phase__c, Service_Item__r.Phase__r.Name__c, Service_Item__r.Phase__r.Is_default__c
                                                       FROM Billing_Line_Items__r)
                                               FROM Pro_forma_Invoice__c WHERE Id IN: ids]);

    }


    public static void updateProformaInvoicesFormatAndSendCopyTo( Map<Id, Project_Profile__c> projectsWithUpdatedFormat, Map<Id, Project_Profile__c> projectsWithUpdatedSendCopyTo ){
        if( projectsWithUpdatedFormat.isEmpty() && projectsWithUpdatedSendCopyTo.isEmpty() ) return;

        Set<Id> invoiceIdsToRegeneratePdfs = new Set<Id>();
        Set<Id> changedProjects = new Set<Id>();
        changedProjects.addAll( projectsWithUpdatedFormat.keySet() );
        changedProjects.addAll( projectsWithUpdatedSendCopyTo.keySet() );

        Map<Id, Pro_forma_Invoice__c> proformaInvoices = new Map<Id, Pro_forma_Invoice__c>( [ SELECT Id, Project_Profile__c, Invoice_Format__c, Send_Copy_To_Emails__c
                                                                                              FROM Pro_forma_Invoice__c
                                                                                              WHERE Project_Profile__c IN : changedProjects ] );
        Map<Id, Pro_forma_Invoice__c> proformaInvoicesToUpdate = new Map<Id, Pro_forma_Invoice__c>();
        for( Pro_forma_Invoice__c invoice : proformaInvoices.values() ) {
            if( projectsWithUpdatedFormat.containsKey( invoice.Project_Profile__c ) ) {
                String projectInvoiceFormat = projectsWithUpdatedFormat.get(invoice.Project_Profile__c).Invoice_Format__c;
                if( invoice.Invoice_Format__c != projectInvoiceFormat ) {
                    if( !proformaInvoicesToUpdate.containsKey( invoice.Id ) ) {
                        proformaInvoicesToUpdate.put( invoice.Id, new Pro_forma_Invoice__c( Id = invoice.Id, Invoice_Format__c = projectInvoiceFormat ) );
                    } else {
                        proformaInvoicesToUpdate.get( invoice.Id ).Invoice_Format__c = projectInvoiceFormat;
                    }
                }
                invoiceIdsToRegeneratePdfs.add( invoice.Id );
            }
            if( projectsWithUpdatedSendCopyTo.containsKey( invoice.Project_Profile__c ) ) {
                String projectSendCopyTo = projectsWithUpdatedSendCopyTo.get(invoice.Project_Profile__c).Send_Copy_To__c;
                if( invoice.Send_Copy_To_Emails__c != projectSendCopyTo ) {
                    if( !proformaInvoicesToUpdate.containsKey( invoice.Id ) ) {
                        proformaInvoicesToUpdate.put( invoice.Id, new Pro_forma_Invoice__c( Id = invoice.Id, Send_Copy_To_Emails__c = projectSendCopyTo ) );
                    } else {
                        proformaInvoicesToUpdate.get( invoice.Id ).Send_Copy_To_Emails__c = projectSendCopyTo;
                    }
                }
            }
        }

        if( !proformaInvoices.isEmpty() ) {
            try {
                UPDATE proformaInvoicesToUpdate.values();
                if( !invoiceIdsToRegeneratePdfs.isEmpty() ) {
                    generateProformaInvoicesPDF( invoiceIdsToRegeneratePdfs );
                }
            } catch( DMLException dmlEx ){
                for( Integer i = 0; i < dmlEx.getNumDml(); i++ ) {
                    Id projectId = proformaInvoices.get( dmlEx.getDmlId(i) ).Project_Profile__c;
                    Project_Profile__c updatedProject;
                    if( projectsWithUpdatedFormat.containsKey( projectId ) ) {
                        updatedProject = projectsWithUpdatedFormat.get( projectId );
                    } else if( projectsWithUpdatedSendCopyTo.containsKey( projectId ) ) {
                        updatedProject = projectsWithUpdatedSendCopyTo.get( projectId );
                    }
                    if( updatedProject != null ) {
                        updatedProject.addError( 'Error Occured While Updating Proforma Invoices: ' + dmlEx.getMessage() );
                    }
                }
            }
        }
    }

    public static void generateProformaInvoicesPDF( Set<Id> invoicesId ){
        if( invoicesId.isEmpty() ) return;
        DDPRequest ddpRequest = new DDPRequest();
        for( Id invoiceId: invoicesId ){
            ddpRequest.addConfiguration ( invoiceId, DDPEmailServices.DDP_NAME_CREATE_INVOICES, DDPEmailServices.DELIVERY_METHOD_ATTACH, null, null, null, null );
        }
        ddpRequest.sendRequest();
    }

    public static void undoPriorBilling( Map<Id, Project_Profile__c> updatedProjects ){
        if( updatedProjects.isEmpty() ) return;

        Map<Id, Pro_forma_Invoice__c> proformaInvoices = new Map<Id, Pro_forma_Invoice__c>([ SELECT Id, Project_Profile__c, Invoice_Format__c, Superceded__c, Sales_Invoice__c,
                                                                                            Credit_1_Amount__c, Credit_2_Amount__c,
                                                                                            (Select Id__c, Billed__c, Superceded__c, Pro_forma_Invoice__c From Billing_Line_Items__r)
                                                                                             FROM Pro_forma_Invoice__c
                                                                                             WHERE Project_Profile__c IN: updatedProjects.keySet()
                                                                                             AND Superceded__c =: false]);

        List<Billing_Line_Item__c> bliWithoutInvoises = new List<Billing_Line_Item__c>([Select Id, Pro_forma_Invoice__c, Superceded__c
                                                                                        From Billing_Line_Item__c
                                                                                        WHERE Project_Profile__c IN: updatedProjects.keySet()
                                                                                        AND Pro_forma_Invoice__c =: null
                                                                                        AND Superceded__c =: false]);
        List<Pro_forma_Invoice__c> invoicesToUpdate = new List<Pro_forma_Invoice__c>();
        List<Pro_forma_Invoice__c> invoicesToDelete = new List<Pro_forma_Invoice__c>();
        List<Billing_Line_Item__c> bliToUpdate = new List<Billing_Line_Item__c>();

        for( Pro_forma_Invoice__c invoice: proformaInvoices.values() ){
            if( invoice.Sales_Invoice__c == null ){
                for( Billing_Line_Item__c bli : invoice.Billing_Line_Items__r ){
                    bli.Billed__c = false;
                    bli.Superceded__c = true;
                    bli.Pro_forma_Invoice__c = null;
                    bliToUpdate.add(bli);
                }
                invoicesToDelete.add(invoice);
            }else{
                for( Billing_Line_Item__c bli : invoice.Billing_Line_Items__r ){
                    bli.Superceded__c = true;
                    bliToUpdate.add(bli);
                }
                invoice.Superceded__c = true;
                invoicesToUpdate.add(invoice);
            }
        }

        for( Billing_Line_Item__c bli : bliWithoutInvoises ){
            bli.Superceded__c = true;
            bliToUpdate.add(bli);
        }

        try {
            update invoicesToUpdate;
            delete invoicesToDelete;
            update bliToUpdate;
            generateCreditNotes( invoicesToUpdate );
        } catch( DMLException dmlEx ){
            for( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                for( Project_Profile__c project: updatedProjects.values() ){
                    project.addError('Error Occured While Changing Billing Method: ' + dmlEx.getMessage());
                }
            }
        }
    }

    public static void generateCreditNotes( List<Pro_forma_Invoice__c> proformaInvoices ){
        Boolean generateCreditNote1 = false;
        Boolean generateCreditNote2 = false;
        for( Pro_forma_Invoice__c invoice: proformaInvoices ){
            if( invoice.Credit_1_Amount__c != null && invoice.Credit_1_Amount__c > 0 ){
                generateCreditNote1 = true;
            } else if( invoice.Credit_2_Amount__c != null && invoice.Credit_2_Amount__c > 0  ){
                generateCreditNote2 = true;
            }
        }

        if( generateCreditNote1 ){
            Database.executeBatch(new ClickLinkBatch(CREATE_CREDIT_NOTE1_JOB_NAME));
        }
        if( generateCreditNote2 ){
            Database.executeBatch(new ClickLinkBatch(CREATE_CREDIT_NOTE2_JOB_NAME));
        }

    }

    public static void updateInvoicesMailRoomData(List<Mailroom__c> newMailRoomList, Map<Id, Mailroom__c> oldMailRoomMap) { // MRS 7196

        Set<Id> affectedMailRoomsIdSet = new Set<Id>();
        Set<Id> invoicesIdxSet = new Set<Id>();

        for(Mailroom__c mr : newMailRoomList) {
            if(oldMailRoomMap == null
                || oldMailRoomMap.get(mr.Id) == null
                || mr.COSTCATID_Service_Type__c != oldMailRoomMap.get(mr.Id).COSTCATID_Service_Type__c) {
                affectedMailRoomsIdSet.add(mr.Id);
            }
        }
        if(newMailRoomList == null) {
            for(Mailroom__c mr : oldMailRoomMap.values()) {
                affectedMailRoomsIdSet.add(mr.Id);
            }
        }

        if(!affectedMailRoomsIdSet.isEmpty()) {
            for(Billing_Line_Item__c bli : [SELECT Id, Pro_forma_Invoice__c FROM Billing_Line_Item__c WHERE Pro_forma_Invoice__c != null AND Mailroom__c IN :affectedMailRoomsIdSet]) {
                invoicesIdxSet.add(bli.Pro_forma_Invoice__c);
            }
        }

        if(!invoicesIdxSet.isEmpty()) {
            List<Billing_Line_Item__c> lineItemsForPDF = [SELECT Id, Pro_forma_Invoice__c, Mailroom__r.COSTCATID_Service_Type__c, Mailroom_COSTCATID_Service_Type__c
                                                          FROM Billing_Line_Item__c
                                                          WHERE Pro_forma_Invoice__c IN : invoicesIdxSet AND
                                                               (Mailroom__r.COSTCATID_Service_Type__c = : BillingLineItemServices.FEDEX_FILTER OR
                                                                Mailroom__r.COSTCATID_Service_Type__c = : BillingLineItemServices.FEDEX_AIRBORNE_FILTER OR
                                                                Mailroom__r.COSTCATID_Service_Type__c LIKE : BillingLineItemServices.SUPREME_SYSTEMS_FILTER + '%')];

            List<Pro_forma_Invoice__c> invoicesToUpdate = new List<Pro_forma_Invoice__c>();
            Map<Id, List<Billing_Line_Item__c>> invoiceIdToBlisListMap = new Map<Id, List<Billing_Line_Item__c>>();
            for(Billing_Line_Item__c bli: lineItemsForPDF) {
                if(invoiceIdToBlisListMap.get(bli.Pro_forma_Invoice__c) == null) invoiceIdToBlisListMap.put(bli.Pro_forma_Invoice__c, new List<Billing_Line_Item__c>());
                invoiceIdToBlisListMap.get(bli.Pro_forma_Invoice__c).add(bli);
            }
            for(Id idx : invoiceIdToBlisListMap.keySet()) {
                Boolean containsFedex = false;
                Boolean containsMess = false;
                for(Billing_Line_Item__c bli : invoiceIdToBlisListMap.get(idx)) {
                    if(BillingLineItemServices.FEDEX_FILTER == bli.Mailroom_COSTCATID_Service_Type__c || BillingLineItemServices.FEDEX_AIRBORNE_FILTER == bli.Mailroom_COSTCATID_Service_Type__c){ //MRS 6707
                        containsFedex = true;
                    }
                    if(null != bli.Mailroom_COSTCATID_Service_Type__c && bli.Mailroom_COSTCATID_Service_Type__c.startsWith(BillingLineItemServices.SUPREME_SYSTEMS_FILTER)) {
                        containsMess = true;
                    }
                    if(containsFedex && containsMess) break;
                }
                invoicesToUpdate.add(new Pro_forma_Invoice__c(Id = idx, Contains_Fedex_Mailroom__c = containsFedex, Contains_Mess_Meilroom__c = containsMess));
            }
            for(Id idx : invoicesIdxSet) {
                if(!invoiceIdToBlisListMap.keySet().contains(idx)) {
                    invoicesToUpdate.add(new Pro_forma_Invoice__c(Id = idx, Contains_Fedex_Mailroom__c = false, Contains_Mess_Meilroom__c = false));
                }
            }
            UPDATE invoicesToUpdate;
        }
    }

    public static Boolean updateInvoicesDataForPDF(Map<Id, Pro_forma_Invoice__c> incomingInvoicesMap, final Boolean isSentToClient) {
        Boolean status = false;

        Map<Id, Pro_forma_Invoice__c> invoicesToUpdateMap = new Map<Id, Pro_forma_Invoice__c>();

        if (isSentToClient) {
            for (Pro_forma_Invoice__c invoice: incomingInvoicesMap.values()) {
                if (!invoice.Sent_To_Client__c) {
                    invoice.Sent_To_Client__c = true;
                    invoicesToUpdateMap.put(invoice.Id, invoice);
                }
            }

        }

        Map<Id, Billing_Line_Item__c> lineItemsForPDF = BillingLineItemServices.getBLIForInvoicesToGeneratePDF( incomingInvoicesMap.keySet() );

        for( Billing_Line_Item__c bli: lineItemsForPDF.values() ){
            Pro_forma_Invoice__c invoice = incomingInvoicesMap.get(bli.Pro_forma_Invoice__c);
            Boolean updateInvoice = false;
            if( (BillingLineItemServices.FEDEX_FILTER == bli.Mailroom_COSTCATID_Service_Type__c || BillingLineItemServices.FEDEX_AIRBORNE_FILTER == bli.Mailroom_COSTCATID_Service_Type__c)
                    && !invoice.Contains_Fedex_Mailroom__c ){ //MRS 6707
                    invoice.Contains_Fedex_Mailroom__c = true;
                    updateInvoice = true;
            }
            if( bli.Mailroom_COSTCATID_Service_Type__c != null && bli.Mailroom_COSTCATID_Service_Type__c.startsWith(BillingLineItemServices.SUPREME_SYSTEMS_FILTER) && !invoice.Contains_Mess_Meilroom__c ){
                invoice.Contains_Mess_Meilroom__c = true;
                updateInvoice = true;
            }
            if( String.valueOf(bli.Reimbursable_Type__c) == BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING && !invoice.Contains_Sredding__c ){
                invoice.Contains_Sredding__c = true;
                updateInvoice = true;
            }
            if( String.valueOf(bli.Reimbursable_Type__c) == BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING && !invoice.Contains_Scanning__c ){
                invoice.Contains_Scanning__c = true;
                updateInvoice = true;
            }
            if( bli.isHourlyConsulting__c && !invoice.Contains_Hourly_Consulting__c ){
                invoice.Contains_Hourly_Consulting__c = true;
                updateInvoice = true;
            }
            if( updateInvoice ){
                invoicesToUpdateMap.put( invoice.Id, invoice );
            }
        }

        for( Id invoiceId : BillingLineItemServices.getInvoiceIdsThatHaveChargeChecks( incomingInvoicesMap.keySet() ) ) {
            Pro_forma_Invoice__c invoice = incomingInvoicesMap.get( invoiceId );
            if( invoice != null && !invoice.Contains_AmEx_Checks__c ) {
                invoice.Contains_AmEx_Checks__c = true;
                invoicesToUpdateMap.put( invoice.Id, invoice );
            }
        }

        //try {
            UPSERT invoicesToUpdateMap.values();
            status = true;
        //} catch( dmlException ex ) {

        //}

        return status;
    }

    //MRS-6610
    public static void updateChangedBillingAccountingInformation( Map<Id, Project_Profile__c> newProjectMap, Map<Id, Project_Profile__c> oldProjectMap ){
        if ( newProjectMap == null || newProjectMap.isEmpty() ){return;}

        List<Pro_forma_Invoice__c> proformaInvoiceUpdateList = new List<Pro_forma_Invoice__c>();

        for (Pro_forma_Invoice__c proformaInvoiceItem : [SELECT Id, Project_Profile__c, Accounting_Contact__c, Accounting_Contact_Company__c, Billing_Contact__c, Billing_Client_Company__c,
        														Client_Project__c, Account_Manager__c
                                                         FROM Pro_forma_Invoice__c
                                                         WHERE Project_Profile__c IN : newProjectMap.keySet() AND
                                                                Amount_Due__c > 0]){
            Project_Profile__c newProjectProfile = newProjectMap.get(proformaInvoiceItem.Project_Profile__c);
            Project_Profile__c oldProjectProfile = oldProjectMap.get(proformaInvoiceItem.Project_Profile__c);
            Boolean doUpdate = false;//MRS-6741
            if ( proformaInvoiceItem.Accounting_Contact_Company__c != newProjectProfile.Accounting_Contact_Company__c && proformaInvoiceItem.Accounting_Contact_Company__c == oldProjectProfile.Accounting_Contact_Company__c ){
                proformaInvoiceItem.Accounting_Contact_Company__c = newProjectProfile.Accounting_Contact_Company__c;
                proformaInvoiceItem.Accounting_Contact__c = newProjectProfile.Accounting_Contact__c;
                doUpdate = true;
            }
            if ( proformaInvoiceItem.Accounting_Contact__c != newProjectProfile.Accounting_Contact__c &&
                 proformaInvoiceItem.Accounting_Contact__c == oldProjectProfile.Accounting_Contact__c &&
                 proformaInvoiceItem.Accounting_Contact_Company__c == newProjectProfile.Accounting_Contact_Company__c ){
                proformaInvoiceItem.Accounting_Contact__c = newProjectProfile.Accounting_Contact__c;
                doUpdate = true;
            }
            if ( (proformaInvoiceItem.Billing_Contact__c != newProjectProfile.Billing_Company_Contact__c && proformaInvoiceItem.Billing_Contact__c == oldProjectProfile.Billing_Company_Contact__c) &&
                  proformaInvoiceItem.Billing_Client_Company__c == newProjectProfile.Billing_Company_Name__c ){
                proformaInvoiceItem.Billing_Contact__c = newProjectProfile.Billing_Company_Contact__c;
                doUpdate = true;
            }
            if ( proformaInvoiceItem.Account_Manager__c != newProjectProfile.Account_Executive__c && proformaInvoiceItem.Account_Manager__c == oldProjectProfile.Account_Executive__c ){
                proformaInvoiceItem.Account_Manager__c = newProjectProfile.Account_Executive__c;
                doUpdate = true;
            }
            if ( proformaInvoiceItem.Client_Project__c != newProjectProfile.Client_Project__c && proformaInvoiceItem.Client_Project__c == oldProjectProfile.Client_Project__c ){
                proformaInvoiceItem.Client_Project__c = newProjectProfile.Client_Project__c;
                doUpdate = true;
            }
            if ( doUpdate ){
                proformaInvoiceUpdateList.add(proformaInvoiceItem);
            }
        }

        if ( !proformaInvoiceUpdateList.isEmpty() ){
            try{
                update proformaInvoiceUpdateList;
            } catch (DMLException dmlEx){
                for( Integer i=0; i < dmlEx.getNumDml(); i++  ){
                    newProjectMap.get( proformaInvoiceUpdateList[dmlEx.getDmlIndex(i)].Project_Profile__c ).addError('Error Occurred While updating Billing/Accounting information on the Pro-forma Invoice record: ' + dmlEx.getMessage());
                }
            }
        }
    }

    //MRS-6549
    public static List<Pro_forma_Invoice__c> filteredProFormaInvoiceWithHideFromRecap (List<Pro_forma_Invoice__c> newProFormaInvoiceList, Map<Id,Pro_forma_Invoice__c> oldProformaInvoiceMap){
        List<Pro_forma_Invoice__c> proformaInvoiceFilteredList = new List<Pro_forma_Invoice__c>();
        for (Pro_forma_Invoice__c proformaInvoiceItem : newProFormaInvoiceList){
            if ( proformaInvoiceItem.Hide_from_Recap__c != null && proformaInvoiceItem.Hide_from_Recap__c != oldProformaInvoiceMap.get(proformaInvoiceItem.Id).Hide_from_Recap__c ){
                proformaInvoiceFilteredList.add(proformaInvoiceItem);
            }
        }
        return proformaInvoiceFilteredList;
    }

    public static void updateBillingLIHideFromRecap (List<Pro_forma_Invoice__c> newProFormaInvoiceList){
        if (newProFormaInvoiceList == null || newProFormaInvoiceList.isEmpty()){ return; }

        List<Billing_Line_Item__c> billingLineItemUpdatedList = new List<Billing_Line_Item__c>();
        for (Billing_Line_Item__c billingLineItem : [SELECT Id, Hide_from_Recap__c, Pro_forma_Invoice__r.Hide_from_Recap__c, Pro_forma_Invoice__c
                                                     FROM Billing_Line_Item__c
                                                     WHERE Pro_forma_Invoice__c IN : newProFormaInvoiceList]){
            if (billingLineItem.Hide_from_Recap__c != billingLineItem.Pro_forma_Invoice__r.Hide_from_Recap__c){
                billingLineItem.Hide_from_Recap__c = billingLineItem.Pro_forma_Invoice__r.Hide_from_Recap__c;
                billingLineItemUpdatedList.add(billingLineItem);
            }
        }

        if ( billingLineItemUpdatedList.isEmpty() ){ return; }

        try {
            update billingLineItemUpdatedList;
        } catch (DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Pro_forma_Invoice__c proformaInvoiceWithError = new Map<Id, Pro_forma_Invoice__c>(newProFormaInvoiceList).get(billingLineItemUpdatedList[dmlEx.getDmlIndex(i)].Pro_forma_Invoice__c);
                proformaInvoiceWithError.addError('Can not update related BLI ' + dmlEx.getMessage());
            }
        }
    }

	public static void updateInvoiceCashMatchingFields(Set<Id> setInvoicesIdx) { // MRS 7285
		if(!setInvoicesIdx.isEmpty()) {
			Set<Id> invoicesWithCash = new Set<Id>();
			Set<Id> invoicesWithCredits = new Set<Id>();
			Set<Id> invoicesWithJournals = new Set<Id>();
			List<Pro_forma_Invoice__c> invoicesToUpdate = new List<Pro_forma_Invoice__c>();
			for(c2g__codaTransactionLineItem__c codaTransactionLine : [SELECT c2g__Transaction__r.Pro_forma_Invoice__c,
																		(SELECT Cash_Applied__c, Credits_Applied__c, Journals_Applied__c
																		 FROM c2g__CashMatchingHistories__r)
																	FROM c2g__codaTransactionLineItem__c
																	WHERE c2g__Transaction__r.Pro_forma_Invoice__c IN :setInvoicesIdx] ) {
				for(c2g__codaCashMatchingHistory__c codaCMHistory : codaTransactionLine.c2g__CashMatchingHistories__r) {
					if(codaCMHistory.Cash_Applied__c) invoicesWithCash.add(codaTransactionLine.c2g__Transaction__r.Pro_forma_Invoice__c);
					if(codaCMHistory.Credits_Applied__c) invoicesWithCredits.add(codaTransactionLine.c2g__Transaction__r.Pro_forma_Invoice__c);
					if(codaCMHistory.Journals_Applied__c) invoicesWithJournals.add(codaTransactionLine.c2g__Transaction__r.Pro_forma_Invoice__c);
				}

			}
			for(Id idInvoice : setInvoicesIdx) {
				invoicesToUpdate.add(new Pro_forma_Invoice__c(Id = idInvoice,
															  Cash_Applied__c = invoicesWithCash.contains(idInvoice),
															  Credits_Applied__c = invoicesWithCredits.contains(idInvoice),
															  Journals_Applied__c = invoicesWithJournals.contains(idInvoice)));
			}

			Database.update( invoicesToUpdate, false );
		}
	}

}