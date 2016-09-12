global class CreateProformaInvoicesBatch implements Database.Batchable<sObject>, Schedulable{

    global final String query;
    global final Boolean isDailyBillingJob;
	global final Id ddpHelperWithErrorsId;
	global final DDP_Helper__c ddpHelperConfigurationRecord;
	global final Set<Id> ddpHelperWithErrorsSetId;
	global final Map<String, DDP_Helper__c> ddpHelperMap;

    global void execute(SchedulableContext sc) {
        Database.executeBatch( new CreateProformaInvoicesBatch( false ), Integer.valueOf( Label.Batch_Size_For_PFI_Process ) );
    }

    global CreateProformaInvoicesBatch( Boolean isDaily ) {
		List<DDP_Helper__c> listDDPHelper = new List<DDP_Helper__c>{new DDP_Helper__c( Type__c = DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_ERRORS, Text1__c = '', Text3__c = '', Text4__c = '', Text5__c = '' )};
		ddpHelperWithErrorsSetId = new Set<Id>();

		List<DDP_Helper__c> ddphelperJobSupportList = [Select Id, Type__c, Text1__c, Text2__c, Create_FFA_Invoice__c, Email_Invoices__c From DDP_Helper__c Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT LIMIT 1];
		this.ddpHelperConfigurationRecord = !ddphelperJobSupportList.isEmpty() ? ddphelperJobSupportList[0] : new DDP_Helper__c(Type__c = DDPHelperServices.TYPE_BILLING_JOB_SUPPORT,
																																Text1__c = '',
																																Text2__c = 'wave@milrose.com',
																																Email_Invoices__c = false,
																																Create_FFA_Invoice__c = false);
		if ( this.ddpHelperConfigurationRecord.Id == null ){
			listDDPHelper.add(this.ddpHelperConfigurationRecord);
		}

		for( Schema.PicklistEntry item: Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ){
			listDDPHelper.add( new DDP_Helper__c ( Type__c = DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB,
													Delivery_Method__c = item.getValue(),
													Email_Invoices__c = ( item.getValue() == 'Email' ) ? ddpHelperConfigurationRecord.Email_Invoices__c : false,
													Create_FFA_Invoice__c = ddpHelperConfigurationRecord.Create_FFA_Invoice__c ) );
		}
		insert listDDPHelper;

		for (DDP_Helper__c ddpHelper : listDDPHelper){
			ddpHelperWithErrorsSetId.add(ddpHelper.Id);
		}

		this.ddpHelperMap = new Map<String, DDP_Helper__c>();
		for( DDP_Helper__c item: listDDPHelper ){
			if ( item.Type__c == DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB ){
				ddpHelperMap.put( item.Delivery_Method__c, item );
			} else if ( item.Type__c == DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB_ERRORS ) {
				this.ddpHelperWithErrorsId = item.Id;
			}
		}

		isDailyBillingJob = isDaily ? true : false;

		this.query  = ' SELECT Id FROM Project_Profile__c ';


	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Project_Profile__c> projectProfileList = ( List<Project_Profile__c> )scope;

		List<Billing_Line_Item__c> lineItemsForInvoicing = BillingLineItemServices.bliForBatchList( projectProfileList, isDailyBillingJob );

		ProformaInvoiceServices.ddpHelperMap = this.ddpHelperMap;

		ProformaInvoiceServices.processProformaInvoices( lineItemsForInvoicing, true, false, true );//MRS-7105

		if ( !String.isEmpty( ProformaInvoiceServices.createPFIErrorsHendle ) ||
			 !String.isEmpty( ProformaInvoiceServices.updateBLIErrorsHendle ) ||
			 !String.isEmpty( ProformaInvoiceServices.errorsDuringInsertReimbursables ) ||
			 !String.isEmpty( ProformaInvoiceServices.errorsDuringUpdateServiceItems ) ||
			 !String.isEmpty( ProformaInvoiceServices.restrictionsBasedPO )){

			DDP_Helper__c ddphelperWithError = [SELECT Id, Text1__c, Text3__c, Text4__c, Text5__c, Text6__c FROM DDP_Helper__c WHERE Id = : ddpHelperWithErrorsId];

			if (!String.isEmpty(ProformaInvoiceServices.createPFIErrorsHendle)){
				ddphelperWithError.Text1__c = !String.isEmpty(ddphelperWithError.Text1__c) ? (ddphelperWithError.Text1__c + ProformaInvoiceServices.createPFIErrorsHendle) : ProformaInvoiceServices.createPFIErrorsHendle;
			}

			if (!String.isEmpty(ProformaInvoiceServices.updateBLIErrorsHendle)){
				ddphelperWithError.Text3__c = !String.isEmpty(ddphelperWithError.Text3__c) ? (ddphelperWithError.Text3__c + ProformaInvoiceServices.updateBLIErrorsHendle) : ProformaInvoiceServices.updateBLIErrorsHendle;
			}

			if (!String.isEmpty(ProformaInvoiceServices.errorsDuringInsertReimbursables)){
				ddphelperWithError.Text4__c = !String.isEmpty(ddphelperWithError.Text4__c) ? (ddphelperWithError.Text4__c + ProformaInvoiceServices.errorsDuringInsertReimbursables) : ProformaInvoiceServices.errorsDuringInsertReimbursables;
			}

			if (!String.isEmpty(ProformaInvoiceServices.errorsDuringUpdateServiceItems)){
				ddphelperWithError.Text5__c = !String.isEmpty(ddphelperWithError.Text5__c) ? (ddphelperWithError.Text5__c + ProformaInvoiceServices.errorsDuringUpdateServiceItems) : ProformaInvoiceServices.errorsDuringUpdateServiceItems;
			}

			if (!String.isEmpty(ProformaInvoiceServices.restrictionsBasedPO)){
				ddphelperWithError.Text6__c = !String.isEmpty(ddphelperWithError.Text6__c) ? (ddphelperWithError.Text6__c + ProformaInvoiceServices.restrictionsBasedPO) : ProformaInvoiceServices.restrictionsBasedPO;
			}

			update ddphelperWithError;
		}
	}

	global void finish(Database.BatchableContext BC) {
		String emailTextBody = '';
		String pfiNames = '';
		for (Pro_forma_Invoice__c pfi : [SELECT Id, Name FROM Pro_forma_Invoice__c WHERE DDP_Helper__c IN : ddpHelperWithErrorsSetId AND DDP_Helper__r.Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB]){
			pfiNames += pfi.Name + '; ';
		}
		pfiNames = pfiNames.removeEnd('; ');
		if( pfiNames != '' ){ //MRS-6666
			emailTextBody += '\n' + 'Generated Pro-forma Invoices: '+ pfiNames + '.\n' + '\n' +'The scheduled billing job has completed. You may find the completed invoices here. ' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/ProFormaBillingLineItem';
		}

		if( emailTextBody == '' ) emailTextBody += 'None of BLI(s) was billed';

		DDP_Helper__c helperSupportForEmail = new DDP_Helper__c( Type__c = DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL );
		helperSupportForEmail.Text2__c = [Select Id, Text2__c From DDP_Helper__c Where Id =: this.ddpHelperConfigurationRecord.Id AND Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT limit 1][0].Text2__c;
		if( helperSupportForEmail.Text2__c == null ) helperSupportForEmail.Text2__c = 'wave@milrose.com';
		helperSupportForEmail.Text1__c = emailTextBody;

		insert helperSupportForEmail;


		DDP_Helper__c ddphelperWithError = [SELECT Id, Text1__c, Text3__c, Text4__c, Text5__c, Text6__c, Error_Message_Created__c FROM DDP_Helper__c WHERE Id = : ddpHelperWithErrorsId];

		ddphelperWithError.Error_Message_Created__c = !String.isEmpty(ddphelperWithError.Text1__c) || !String.isEmpty(ddphelperWithError.Text3__c) ||
													  !String.isEmpty(ddphelperWithError.Text4__c) || !String.isEmpty(ddphelperWithError.Text5__c) || !String.isEmpty(ddphelperWithError.Text6__c);

		ddphelperWithError.Text3__c =   'Errors occurred when Pro-forma Invoice records were created:' + (!String.isEmpty(ddphelperWithError.Text1__c) ? ('\n' + ddphelperWithError.Text1__c) : '') +
										'\nErrors occurred when BLI records were updated:' + (!String.isEmpty(ddphelperWithError.Text3__c) ? ('\n' + ddphelperWithError.Text3__c) : '') +
										'\nErrors occurred when Reimbursable BLIs records were created:' + (!String.isEmpty(ddphelperWithError.Text4__c) ? ('\n' + ddphelperWithError.Text4__c) : '') +
										'\nErrors occurred when Service Items records were updated:' + (!String.isEmpty(ddphelperWithError.Text5__c) ? ('\n' + ddphelperWithError.Text5__c) : '') +
										'\nFollowing BLIs require POs,\nno invoice will be generated until a PO is linked to the BLI:' + (!String.isEmpty(ddphelperWithError.Text6__c) ? ('\n' + ddphelperWithError.Text6__c) : '');
		ddphelperWithError.Text1__c = '';
		ddphelperWithError.Text4__c = '';
		ddphelperWithError.Text5__c = '';
		ddphelperWithError.Text6__c = '';
		update ddphelperWithError;
	}
}