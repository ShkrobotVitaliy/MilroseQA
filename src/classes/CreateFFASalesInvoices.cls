global class CreateFFASalesInvoices implements Schedulable{

    global CreateFFASalesInvoices() {}

    global void execute(SchedulableContext sc) {
        CreateFFASalesInvoices job = new CreateFFASalesInvoices();
        job.execute();
    }

    //Execute method
    global void execute() {
    	Integer ddpHelpersCount = new List<Schema.PicklistEntry>( Project_Profile__c.Delivery_Method__c.getDescribe().getPicklistValues() ).size();

        List<DDP_Helper__c> helperList = [Select Id
        								From DDP_Helper__c
        								Where Create_FFA_Invoice__c = true AND
        									Type__c =: DDPHelperServices.TYPE_PROFORMA_INVOICE_BATCH_JOB AND
        									CreatedDate = TODAY
        								Order by CreatedDate DESC
        								limit: ddpHelpersCount];

		List<DDP_Helper__c> helperSupportForEmail = [Select Id, Clicklink_Job_Id__c, Text3__c, Error_Message_Created__c
													From DDP_Helper__c
													Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL AND
														CreatedDate = TODAY
													Order by CreatedDate DESC limit 1];

        helperSupportForEmail[0].Text3__c += '\n' + '\n' + 'Errors during checking Create FFA Invoice box: ';

        if( !helperList.isEmpty() ){
			List<Pro_forma_Invoice__c> invoicesProFormaList = new List<Pro_forma_Invoice__c>();
            for( Pro_forma_Invoice__c item: [ Select Id, Name, (Select Name From Billing_Line_Items__r) From Pro_forma_Invoice__c Where DDP_Helper__c IN: helperList ] ){
				item.cl_Create_FFA_Invoice__c = true;
				invoicesProFormaList.add( item );
            }
            Database.SaveResult[] srList = Database.update( invoicesProFormaList, false );
            for ( Integer i = 0; i < invoicesProFormaList.size(); i++ ) {
			    Database.SaveResult sr = srList[i];
			    Pro_forma_Invoice__c origRecord = invoicesProFormaList[i];
			    if ( !sr.isSuccess() ) {
			    	helperSupportForEmail[0].Error_Message_Created__c = true;
			        for(Database.Error err : sr.getErrors()) {
			            helperSupportForEmail[0].Text3__c += '\n' + origRecord.Name + ' ' + err.getStatusCode() + ': ' + err.getMessage();
			        }
			    }
			}

        }
		Id batchprocessId = Database.executeBatch( new ClickLinkBatch('Create Sales Invoices'), 1 );

		helperSupportForEmail[0].Clicklink_Job_Id__c = batchprocessId;
		helperSupportForEmail[0].Text3__c += '\n' + '\n' + 'Errors during posting FF invoices: ';
		update helperSupportForEmail;


    }
}