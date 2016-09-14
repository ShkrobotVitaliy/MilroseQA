trigger ProjectMi7Trigger on Project__c (after insert, after update) {

	if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) { //MRS 7540
		LegacyProformaInvoiceServices.updateSecondContactOnLegacyInvoices(ProjectMi7Services.filteredProjectsWithChangedAccManager(Trigger.new, Trigger.oldMap));
	}
}