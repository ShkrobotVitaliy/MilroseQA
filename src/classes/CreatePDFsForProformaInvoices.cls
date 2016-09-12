global class CreatePDFsForProformaInvoices implements Schedulable{

    global CreatePDFsForProformaInvoices() {}

    global void execute(SchedulableContext sc) {
        CreatePDFsForProformaInvoices job = new CreatePDFsForProformaInvoices();
        job.execute();
    }
    private String INVOICES_NOT_VALID_MESSAGE = '{0} [{1}] {2} either Invoice Format or Accounting Contact fields not populated.';

    //Execute method
    global void execute() {
			Integer ddpHelpersCount = new List<Schema.PicklistEntry>( Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ).size();
	        List<DDP_Helper__c> ddpHelperList = [Select Id From DDP_Helper__c Where Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB AND CreatedDate = TODAY Order by CreatedDate DESC limit: ddpHelpersCount];

	        Map<Id, Pro_forma_Invoice__c> proFormaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>();

		    List<String> notValidInvoicesNames = new List<String>();
		    Map<Id, Pro_forma_Invoice__c> validInvoicesMap = new Map<Id, Pro_forma_Invoice__c>();


	        if( !ddpHelperList.isEmpty() ){
				DDPRequest request = new DDPRequest();

	            //attach invoices
		    Set<Id> invoiceIds = new Set<Id>();
	            for( Pro_forma_Invoice__c item: [ Select Id, Name From Pro_forma_Invoice__c	Where ( DDP_Helper__r.Delivery_Method__c != 'Email' OR DDP_Helper__r.Email_Invoices__c = false ) AND DDP_Helper__c IN: ddpHelperList ] ){

					invoiceIds.add( item.Id );

	            }
		    Map<Id, Pro_forma_Invoice__c> invoiceDataMap = new Map<Id, Pro_forma_Invoice__c>();
		        Set<Id> projectIds = new Set<Id>();

		        for ( Pro_forma_Invoice__c invoice : ProformaInvoiceServices.getProformaInvoiceByIds( invoiceIds ) ) {
	                	invoiceDataMap.put( invoice.Id, invoice );
	                	projectIds.add( invoice.Project_Profile__c );

		        }
			//Recalculate Outstanding Invoice
            		ProjectProfileServices.calculateOutstandingAmountsByDate( projectIds );

			Map<Id, Billing_Line_Item__c> lineItemsForPDF = BillingLineItemServices.getBLIForInvoicesToGeneratePDF( invoiceDataMap.keySet() );
		        Map<Id, Pro_forma_Invoice__c> invoicesToUpdate = new Map<Id, Pro_forma_Invoice__c>();

		        for (Billing_Line_Item__c bli: lineItemsForPDF.values()) {
		            if (!invoiceDataMap.containsKey(bli.Pro_forma_Invoice__c)) {
		                continue;
		            }
		            Boolean updateInvoice = false;
		            Pro_forma_Invoice__c invoice = invoiceDataMap.get(bli.Pro_forma_Invoice__c);

		            if ((BillingLineItemServices.FEDEX_FILTER == bli.Mailroom_COSTCATID_Service_Type__c || BillingLineItemServices.FEDEX_AIRBORNE_FILTER == bli.Mailroom_COSTCATID_Service_Type__c)
		             		&& !invoice.Contains_Fedex_Mailroom__c) { // MRS 6707
		                invoice.Contains_Fedex_Mailroom__c = true;
		                updateInvoice = true;
		            }
		            if (null != bli.Mailroom_COSTCATID_Service_Type__c&& bli.Mailroom_COSTCATID_Service_Type__c.startsWith(BillingLineItemServices.SUPREME_SYSTEMS_FILTER) && !invoice.Contains_Mess_Meilroom__c) {
		                invoice.Contains_Mess_Meilroom__c = true;
		                updateInvoice = true;
		            }
		            if (BillingLineItemServices.REIMBURSABLE_TYPE_SHREDDING == String.valueOf(bli.Reimbursable_Type__c) && !invoice.Contains_Sredding__c) {
		                invoice.Contains_Sredding__c = true;
		                updateInvoice = true;
		            }
		            if (BillingLineItemServices.REIMBURSABLE_TYPE_SCANNING == String.valueOf(bli.Reimbursable_Type__c) && !invoice.Contains_Scanning__c) {
		                invoice.Contains_Scanning__c = true;
		                updateInvoice = true;
		            }
		            if (bli.isHourlyConsulting__c && !invoice.Contains_Hourly_Consulting__c) {
		                invoice.Contains_Hourly_Consulting__c = true;
		                updateInvoice = true;
		            }
		            if ( updateInvoice ) {
		                invoicesToUpdate.put( invoice.Id, invoice );
		            }
		        }

		        for( Id invoiceId : BillingLineItemServices.getInvoiceIdsThatHaveChargeChecks( invoiceDataMap.keySet() ) ) {
		            Pro_forma_Invoice__c invoice = invoiceDataMap.get( invoiceId );
		            if( invoice != null && !invoice.Contains_AmEx_Checks__c ) {
		                invoice.Contains_AmEx_Checks__c = true;
		                invoicesToUpdate.put( invoice.Id, invoice );
		            }
		        }


		            UPSERT invoicesToUpdate.values();

			Map<String, Map<String, String>> invoiceIdToAttachmentIdToParentIdForEmail = StoredDocumentServices.getParentIdsAndAttachmentIdsForUploadedChecks( invoiceIds );

		        DDPRequest ddpRequest = new DDPRequest();

		        for( Id invoiceId : invoiceIds ) {
		            ddpRequest.addConfiguration( invoiceId,
		                                         DDPEmailServices.DDP_NAME_CREATE_INVOICES,
		                                         'Attach',
		                                         null,
		                                         null,
		                                         null,
		                                         StoredDocumentServices.getAttachmentIdsForInvoice( invoiceIdToAttachmentIdToParentIdForEmail, invoiceId ) );
		        }
		        ddpRequest.sendRequest();






				//move this method to DDPHelperServices
	            //email invoices
	            proFormaInvoiceMap = new Map<Id, Pro_forma_Invoice__c>([SELECT Id, Name, cl_FFA_Invoice_Created__c, Accounting_Contact__c, Invoice_Format__c, Contains_Hourly_Consulting__c,
                                                                				Contains_Fedex_Mailroom__c, Contains_Mess_Meilroom__c, Contains_Sredding__c, Contains_Scanning__c, Sent_To_Client__c
                                                                		FROM Pro_forma_Invoice__c
                                                                		WHERE DDP_Helper__c IN: ddpHelperList
                                                                			AND DDP_Helper__r.Delivery_Method__c = 'Email'
                                                                			AND DDP_Helper__r.Email_Invoices__c = true
                                                                			AND Sent_To_Client__c = false]);

		        for( Pro_forma_Invoice__c invoice : proFormaInvoiceMap.values() ){
		            if( String.isEmpty( invoice.Invoice_Format__c ) || String.isEmpty( Invoice.Accounting_Contact__c ) ){
		                notValidInvoicesNames.add( invoice.Name );
		            }else{
		                validInvoicesMap.put( invoice.Id, invoice );
		            }
		        }

		        // Select DDP Helper record for sending summary mail.
		        DDP_Helper__c helperSupportForEmail = new DDP_Helper__c();
				String creatingProformaErrors = '';

				Boolean checkIfHasErrors = false; //MRS-7003

		        for (DDP_Helper__c item : [Select Id, Clicklink_Job_Id__c, Text3__c, Error_Message_Created__c, Type__c
										   From DDP_Helper__c
										   Where (Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL OR Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_ERRORS) AND
												CreatedDate = TODAY
										   Order by CreatedDate DESC limit 2]){
		        	if ( item.Type__c == DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL ){
		        		helperSupportForEmail = item;
		        	} else if ( item.Type__c == DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_ERRORS && !String.isEmpty(item.Text3__c) ){
		        		creatingProformaErrors = item.Text3__c + '\n';
		        		checkIfHasErrors = item.Error_Message_Created__c; //MRS-7003
		        	}
		        }

				helperSupportForEmail.Text3__c = 'Errors during creating Pro-forma Invoices: \n' + creatingProformaErrors;
		        helperSupportForEmail.Text3__c += '\nErrors before sending invoices: ';
		        if ( checkIfHasErrors ){ helperSupportForEmail.Error_Message_Created__c = true; } //MRS-7003

		        if( !notValidInvoicesNames.isEmpty() ){
		        	List<String> messageParameters;
		            messageParameters = new List<String>{notValidInvoicesNames.size() == 1 ? 'Invoice' : 'Invoices', String.join(notValidInvoicesNames, ', '), notValidInvoicesNames.size() == 1 ? 'has' : 'have'};
		            helperSupportForEmail.Text3__c += '\n' + String.format(INVOICES_NOT_VALID_MESSAGE, messageParameters);
		        	helperSupportForEmail.Error_Message_Created__c = true;
				}
		        update helperSupportForEmail;

	        }

    }
}