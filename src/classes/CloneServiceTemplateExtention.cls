public without sharing class CloneServiceTemplateExtention {

	public Service_Template__c serviceTemplate { get; set; }

	public String profileName;
	public String currentUserRoleName;

	public Set<String> allowedProfiles = new Set<String> {	UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN,
															UserServices.PROFILE_OPERATIONS_MANAGER};

	public CloneServiceTemplateExtention(ApexPages.StandardController controller) {
		serviceTemplate = (Service_Template__c)controller.getRecord();
		Profile profileRecord = [Select Name From Profile where id =: UserInfo.getProfileId() limit 1];
        profileName = profileRecord.Name;
        UserRole currentUserRole = UserServices.getCurrentUserRole();
        currentUserRoleName = currentUserRole == null ? '' : currentUserRole.Name;
	}

	public PageReference cloneServiceTemplate() {
		if(!isAccessAllowed()) return null;
		Savepoint sp = Database.setSavepoint();
		serviceTemplate = Database.query('SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName('Service_Template__c') 
									  + ' FROM Service_Template__c WHERE Id = ' + '\'' + serviceTemplate.Id + '\'');
		Service_Template__c clonedServiceTemplate = serviceTemplate.clone(false, true, false, false);
		try {
			INSERT clonedServiceTemplate;
		} catch(DmlException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error during cloning of Service Template. Plase contact your System Administrator with next info: ' + ex.getMessage() + '(' + serviceTemplate.Id + ').'));
			return null;
		}
		List<Task_Template__c> taskTemplates = Database.query('SELECT ' + MilroseDevHelper.getCreatableFieldsSelectByObjectName('Task_Template__c') 
									  + ' FROM Task_Template__c WHERE Service__c = ' + '\'' + serviceTemplate.Id + '\' ORDER BY Sequence_Number__c');
		if(!taskTemplates.isEmpty()) {
			Map<Id, String> templateIdToNameOriginal = new Map<Id, String>();
			List<Task_Template__c> clonedTaskTemplates = new List<Task_Template__c>();
			for(Task_Template__c tt : taskTemplates) {
				templateIdToNameOriginal.put(tt.Id, tt.Name);
				Task_Template__c clonedTask = tt.clone(false, true, false, false);
				clonedTask.Service__c = clonedServiceTemplate.Id;
				clonedTask.Predecessor_Task__c = null;
				clonedTask.Successor_Task__c = null;
				clonedTaskTemplates.add(clonedTask);	
			}
			try {
				INSERT clonedTaskTemplates;
				Map<String, Id> templateNameToIdMap = new Map<String, Id>();
				for(Task_Template__c tt : clonedTaskTemplates) {
					templateNameToIdMap.put(tt.Name, tt.Id);	
				}
				for(Integer index = 0; index < taskTemplates.size(); index ++) {
					if(taskTemplates.get(index).Predecessor_Task__c != null) clonedTaskTemplates.get(index).Predecessor_Task__c = templateNameToIdMap.get(templateIdToNameOriginal.get(taskTemplates.get(index).Predecessor_Task__c));
					if(taskTemplates.get(index).Successor_Task__c != null) clonedTaskTemplates.get(index).Successor_Task__c = templateNameToIdMap.get(templateIdToNameOriginal.get(taskTemplates.get(index).Successor_Task__c));
				}
				UPSERT clonedTaskTemplates;
			} catch(DmlException ex) {
				Database.rollback(sp);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error during cloning of Task Templates. Plase contact your System Administrator with next info: ' + ex.getMessage() + '(' + serviceTemplate.Id + ').'));
				return null;
			}
		}
		PageReference pr = new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/' + clonedServiceTemplate.Id);
        pr.setRedirect(true);
        return pr;
	}

	public Boolean isAccessAllowed() {
		if(!allowedProfiles.contains(profileName)) {
			String errorMessage = 'Only Users with profiles: ';
			Integer temp = 1;
			for(String pName : allowedProfiles) {
				if(temp == allowedProfiles.size()) {
					errorMessage += ' \'' + pName + '\'';
				} else if(temp == allowedProfiles.size() - 1) {
					errorMessage += ' \'' + pName + '\' and';
				} else {
					errorMessage += ' \'' + pName + '\',';
				}
				temp ++;
			}
			errorMessage += ' have permission to clone Service Template.';
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
			return false;
		} else {
			return true;
		}
	}

	public PageReference backAction() {
		PageReference pageReference = new ApexPages.StandardController(serviceTemplate).view();
		pageReference.setRedirect(true);
		return pageReference;
	}
}