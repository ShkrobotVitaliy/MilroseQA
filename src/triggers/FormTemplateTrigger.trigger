trigger FormTemplateTrigger on Form_Template__c (before insert, before update, after update) {
	if ( Trigger.isBefore ){
		if ( Trigger.isInsert || Trigger.isUpdate ){
			FormTemplatesServices.attachDDPToFormTemplate(Trigger.new);
		}
	}

	if ( Trigger.isAfter && Trigger.isUpdate ){
		FormTemplatesServices.updateDDPFilesForFormTemplate(FormTemplatesServices.filteredFormTemplateWithChangedName(Trigger.new, Trigger.oldMap), Trigger.oldMap);
	}
}