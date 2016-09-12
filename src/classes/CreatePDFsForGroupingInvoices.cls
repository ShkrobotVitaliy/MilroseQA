global class CreatePDFsForGroupingInvoices implements Schedulable{

    global CreatePDFsForGroupingInvoices() {}

    global void execute(SchedulableContext sc) {
        CreatePDFsForGroupingInvoices job = new CreatePDFsForGroupingInvoices();
        job.execute();
    }

    //Execute method
    global void execute() {

        Map<Id, DDP_Helper__c> ddpHelperMap = new Map<Id, DDP_Helper__c>();
        Set <Id> proformaInvoicesIds = new Set <Id>();
        Integer ddpHelpersCount = new List<Schema.PicklistEntry>( Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ).size();

        Map<Id, List<Id>> ddpHelperWithProformaMap = new Map<Id, List<Id>>();

        for( DDP_Helper__c item: [Select Id, Name, Is_Grouped_PDF_Created__c,
                                        ( Select Id
                                          From Pro_forma_Invoices__r
                                          Order By A_R_Coordinator_Full_Name__c, Accounting_Contact_Company__r.Name, Billing_Client_Company__r.Name, Project_Number__c)
                                  From DDP_Helper__c
                                  Where Email_Invoices__c = false AND
                                  		Is_Grouped_PDF_Created__c = false AND
                                  		Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB AND
        								CreatedDate = TODAY
                                  Order by CreatedDate DESC
                                  limit: ddpHelpersCount] ){

            ddpHelperWithProformaMap.put(item.Id, new List<Id>());

            for( Pro_forma_Invoice__c itemChild: item.Pro_forma_Invoices__r ){

                if( !ddpHelperMap.containsKey(item.Id) ){
                    ddpHelperMap.put( item.Id, item );
                    item.Is_Grouped_PDF_Created__c = true;
                }
                proformaInvoicesIds.add( itemChild.Id );

                ddpHelperWithProformaMap.get(item.Id).add(itemChild.Id);

            }

        }

        if( !ddpHelperMap.values().isEmpty() ){

            Map<Id, Id> idProformaInvoiceToGeneratedDocId = new Map<Id, Id>();
            for( LStore__Stored_Document__c item: [Select Related_Object_Id__c, Id
                                                   From LStore__Stored_Document__c
                                                   Where Related_Object_Id__c IN: proformaInvoicesIds AND
                                                   		LStore__File_Name__c like 'Invoice%'
                                                   	limit 10000]){

                idProformaInvoiceToGeneratedDocId.put( Id.valueOf( item.Related_Object_Id__c ), item.Id );
            }

            DDPRequest request = new DDPRequest();
            for( DDP_Helper__c item: ddpHelperMap.values()){

                List<Id> attachedIdsList = new List<Id>();

                for ( Id proformaId : ddpHelperWithProformaMap.get(item.Id) ){
                    attachedIdsList.add( idProformaInvoiceToGeneratedDocId.get( proformaId ) );
                }
                request.addConfiguration( item.Id, DDPEmailServices.DDP_NAME_PRO_FORMA_INVOICE_BATCH, DDPEmailServices.DELIVERY_METHOD_ATTACH, null, null, null, attachedIdsList );
            }

			update ddpHelperMap.values();
            request.sendRequest();

        }
	
	// Create and send an email with the results of the batch without FF part of errors.
        List<DDP_Helper__c> helperSupportForEmail = [Select Id, Text2__c, Text1__c 
							From DDP_Helper__c 
							Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL AND
    								CreatedDate = TODAY 
							Order by CreatedDate DESC limit 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        if( !helperSupportForEmail.isEmpty() ){
	        mail.setToAddresses( ( helperSupportForEmail[0].Text2__c != null) ? helperSupportForEmail[0].Text2__c.split( ',' , 1000 ) : new String[]{'wave@milrose.com' } );
	        mail.setSenderDisplayName( 'Billing Job Processing' );
	        mail.setSubject( 'Billing Job Results' );
	        mail.setPlainTextBody( helperSupportForEmail[0].Text1__c );

	        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
		}

    }
}