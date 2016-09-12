global class CreateBatchSalesInvoicesPost implements Schedulable, Database.Batchable<Sobject>, Database.AllowsCallouts{

    global void execute( SchedulableContext sc ) {
        Database.executeBatch( new CreateBatchSalesInvoicesPost(), 1 );
    }
    global Database.QueryLocator start( Database.BatchableContext BC ){
       return Database.getQueryLocator( 'Select Id, Name, Sales_Invoice__c, Sales_Invoice__r.Name From Pro_forma_Invoice__c Where DDP_Helper__r.CreatedDate = TODAY AND DDP_Helper__r.Type__c =\'' + 'Create Pro-Forma Invoices' + '\' AND DDP_Helper__r.Create_FFA_Invoice__c = true AND Sales_Invoice__r.c2g__InvoiceStatus__c =\'' + 'In Progress' + '\'' );
    }
    //Execute method
    global void execute( Database.BatchableContext BC, List<Sobject> scope ) {
        List<Pro_forma_Invoice__c> scopeList = ( List<Pro_forma_Invoice__c> ) scope;
            for( Pro_forma_Invoice__c item: scopeList ){
                c2g.CODAAPICommon.Reference ref = new c2g.CODAAPICommon.Reference();
                ref.Id = item.Sales_Invoice__c;

                try{
                    c2g.CODAAPISalesInvoice_3_0.PostInvoice( null, ref );
                }catch (Exception e){
                    List<DDP_Helper__c> helperSupportForEmail = [Select Id, Clicklink_Job_Id__c, Text3__c, Text2__c, Error_Message_Created__c
                                                    From DDP_Helper__c
                                                    Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL AND
                                                        CreatedDate = TODAY
                                                    Order by CreatedDate DESC limit 1];
                    helperSupportForEmail[0].Text3__c += '\n' + item.Sales_Invoice__r.Name + ' ' + e;
                    helperSupportForEmail[0].Error_Message_Created__c = true;
                    update helperSupportForEmail;
                }

            }
            


    }

     global void finish(Database.BatchableContext BC){
        //Select errors from database that occured during creating FF invoices
            List<DDP_Helper__c> helperSupportForEmail = [Select Id, Clicklink_Job_Id__c, Text3__c, Text2__c, Error_Message_Created__c
                                                         From DDP_Helper__c
                                                         Where Type__c =: DDPHelperServices.TYPE_BILLING_JOB_SUPPORT_FOR_EMAIL AND
                                                            CreatedDate = TODAY
                                                         Order by CreatedDate DESC limit 1];

            helperSupportForEmail[0].Text3__c += '\n' + '\n' + 'Errors during creating FF invoices: ';

            //MRS-6705
            for( ffirule__IntegrationRuleLog__c item: [Select Id, (Select Id, ffirule__Message__c From ffirule__IntegrationRuleLogLineItems__r Where ffirule__Severity__c = 'Error' Limit 1)
                                                        From ffirule__IntegrationRuleLog__c
                                                        Where ffirule__ApexJobID__c =: helperSupportForEmail[0].Clicklink_Job_Id__c ] ){
                if (!item.ffirule__IntegrationRuleLogLineItems__r.isEmpty()){
                    helperSupportForEmail[0].Text3__c += URL.getSalesforceBaseUrl().toExternalForm() + '/' + item.Id;
                    helperSupportForEmail[0].Error_Message_Created__c = true;
                }

            }


        update helperSupportForEmail;
        if ( helperSupportForEmail[0].Error_Message_Created__c ){
            // Create and send an email with the results of the batch.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses( ( !helperSupportForEmail.isEmpty() && helperSupportForEmail[0].Text2__c != null) ? helperSupportForEmail[0].Text2__c.split( ',' , 1000 ) : new String[]{'wave@milrose.com' } );
            mail.setSenderDisplayName('Scheduled Billing Job Errors');
            mail.setSubject( 'Scheduled Billing Job Errors' );
            mail.setPlainTextBody( helperSupportForEmail[0].Text3__c );

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}