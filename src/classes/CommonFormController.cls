public with sharing class CommonFormController {
	public Form_Meta_Data_Object_1__c record { get; set; }
	Map<Integer, Id> pageNumberToId = new Map<Integer, Id>();
	Map<Integer, String> pageNumberToPageName = new Map<Integer, String>();

	public Boolean hidePageBody{
		get{
			return false;
		}
		set;
	}

	public String Label{
		get{
			return '';
		}
		set;
	}

	public CommonFormController(ApexPages.StandardController controller) {
		Form_Meta_Data_Object_1__c fmdo = (Form_Meta_Data_Object_1__c)controller.getRecord();

		List<String> fmdoNameString = new List<String>{'Form_Item__r.Complete_Forms_Status__c', 'Form_Item__r.sve_SVE_Visualforce_Page__c', 'Form_Item__r.Form_Template__r.Form_ID__c'};

		for ( Schema.SObjectField fieldTocken : (Schema.getGlobalDescribe().get('Form_Meta_Data_Object_1__c').getDescribe().Fields.getMap()).values()){
			Schema.DescribeFieldResult field = fieldTocken.getDescribe();
			fmdoNameString.add(fieldTocken.getDescribe().getName());
		}

		String queryString = 'SELECT ' + String.join( fmdoNameString, ', ') + ' FROM Form_Meta_Data_Object_1__c WHERE Id = \'' + fmdo.Id + '\'';

		List<Form_Meta_Data_Object_1__c> records = Database.query(queryString);

		record = records[0];

		initForm();
	}

	private void initForm(){
		for( Form_Meta_Data_Object_1__c fmdo : [ SELECT Id, Page_Number__c, Visualforce_Page__c
												 FROM Form_Meta_Data_Object_1__c 
												 WHERE Form_Item__c = : record.Form_Item__c Order By Page_Number__c ] ) {
			pageNumberToId.put( (Integer)fmdo.Page_Number__c, fmdo.Id );
			pageNumberToPageName.put( (Integer)fmdo.Page_Number__c, fmdo.Visualforce_Page__c );
		}
	}

	public PageReference savePage() {
		saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
		return new PageReference('/' + record.Task_Item__c );
	}

	public PageReference cancelPage() {
		return new PageReference('/' + record.Task_Item__c );
	}
	
	public PageReference nextPage() {
		PageReference pr;
		if( record.Page_Number__c + 1 <= pageNumberToId.size() ){
			saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
			if(record.Form_PDF_Version__c != null && record.Page_Number__c == 1 && record.Form_Item__r.Form_Template__r.Form_ID__c.startsWith('F23-4')/*record.Form_PDF_Version__c.startsWith('CCD1')*/) updateF23InitialsRecords();
			pr = new PageReference('/apex/' + pageNumberToPageName.get( (Integer)record.Page_Number__c + 1 ) );
			pr.getParameters().put('id', pageNumberToId.get( (Integer)record.Page_Number__c + 1 ));
			pr.setRedirect(true);
		}
		return pr;
	}
	
	public PageReference prevPage() {
		PageReference pr;
		if( record.Page_Number__c - 1 > 0 ){
			saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
			pr = new PageReference('/apex/' + pageNumberToPageName.get( (Integer)record.Page_Number__c - 1 ) );
			pr.getParameters().put('id', pageNumberToId.get( (Integer)record.Page_Number__c - 1 ) );
			pr.setRedirect(true);
		}
		return pr;
	}

	public void updateF23InitialsRecords() {
		String newSignator1FullName = '';
	 	newSignator1FullName += record.Signator_1_Full_Name__c == null ? '' : record.Signator_1_First_Name__c;
		newSignator1FullName += record.input_field10__c == null ? '' : ' ' + record.input_field10__c;
		newSignator1FullName += record.Signator_1_Last_Name__c == null ? '' : ' ' + record.Signator_1_Last_Name__c;
		newSignator1FullName += record.Signator_1_Suffix__c == null ? '' : ' ' + record.Signator_1_Suffix__c;
		List<Form_Meta_Data_Object_1__c> metaDataObjectsToUpdate = new List<Form_Meta_Data_Object_1__c> {
		new Form_Meta_Data_Object_1__c(Id = pageNumberToId.get( (Integer)record.Page_Number__c + 1), Signator_1_Full_Name__c = newSignator1FullName),
		new Form_Meta_Data_Object_1__c(Id = pageNumberToId.get( (Integer)record.Page_Number__c + 2), Signator_1_Full_Name__c = newSignator1FullName)};
		UPSERT metaDataObjectsToUpdate;
	}

	public PageReference updateDocAndDdp() {
		saveReords( FormItemsServices.FORM_ITEM_STATUS_GENERATED );
 
		PageReference pr = new PageReference('/apex/CreateFormItemPDFHelper');
		if (!test.isRunningTest()) pr.getParameters().put('id', record.Id);
		pr.setRedirect(true);
		return pr;
	}

	private void saveReords( String formStatus ) {
		update record;
		update new Form_Item__c( Id = record.Form_Item__c, 
								 Complete_Forms_Status__c = formStatus );
	}
}