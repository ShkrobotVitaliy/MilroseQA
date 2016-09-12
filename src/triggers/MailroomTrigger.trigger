trigger MailroomTrigger on Mailroom__c (after insert, after update, after delete) {
    
    if (Trigger.isInsert) {
        BillingLineItemServices.generateBillingLineItemsForMailroomTrigger(Trigger.newMap);
    }
	ProformaInvoiceServices.updateInvoicesMailRoomData(Trigger.new, Trigger.oldMap); // MRS 7196
}