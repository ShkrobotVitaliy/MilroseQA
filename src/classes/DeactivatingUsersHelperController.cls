public with sharing class DeactivatingUsersHelperController {
	public String xmlheader{ get{ return '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>'; } set; }
	public final Id userId{ get; set; }
	private final Integer RECORD_COUNT = 10;

	public List<WorkSheetWrapper> workSheets {
		get{
			if(workSheets == null){
				workSheets = new List<WorkSheetWrapper>();
			}
			return workSheets;
		}
		set;
	}

	public DeactivatingUsersHelperController() {
		userId = (!String.isEmpty( ApexPages.currentPage().getParameters().get('userId') ) &&
					ApexPages.currentPage().getParameters().get('userId') instanceOf Id) ?
														id.valueOf( ApexPages.currentPage().getParameters().get('userId') ) :
														UserInfo.getUserId();//for test needs

		List<DeactivatingUsersHelper__mdt> metadatas = [SELECT Id, AdditionalCondition__c, ApiName__c, LookUpFields__c,
																OutPutFields__c, WorkSheetName__c, MaxRecordCount__c,
																Order_Number__c
														FROM DeactivatingUsersHelper__mdt
														WHERE Add_WorkSheet__c = true ORDER BY Order_Number__c];

		for (DeactivatingUsersHelper__mdt metaData : metadatas){
			workSheets.add( new WorkSheetWrapper(metaData, userId) );
		}
	}

	public List<String> bliFieldsApiName{
		get{
			bliFieldsApiName = new List<String>{'Id','OwnerId','Project_Number__c','Project_Name__c','Service_Name__c','Description__c'};
			return bliFieldsApiName;
		}
		set;
	}

	public List<sObject> blisTest{
		get{
			blisTest = [SELECT Id, OwnerId, Project_Number__c, Project_Name__c, Service_Name__c, Description__c
					FROM Billing_Line_Item__c
					WHERE Active_Billing_Line_Item__c = true AND
						Billed__c = false AND
						OwnerId = : userId LIMIT : RECORD_COUNT];
			return blisTest;
		}
		set;
	}

	public class WorkSheetWrapper{
		public String workSheetName{get;set;}
		private transient List<sObject> sObjectsTrans;
		public List<sObject> sObjects{
			get{
				sObjectsTrans = Database.query(query);
				return sObjectsTrans;
			}
			set;
		}
		String query{get;set;}
		public List<String> outPutFields{get;set;}

		public WorkSheetWrapper(DeactivatingUsersHelper__mdt metaData, Id executedUserId){
			workSheetName = metaData.WorkSheetName__c;

			String outPutFieldsQuery = '';
			String lookUpConditionFieldQuery = '';

			outPutFields = new List<String>();

			Set<String> outPutFieldsSet = new Set<String>();
			for (String s : String.isEmpty(metaData.OutPutFields__c) ? new List<String>() : metaData.OutPutFields__c.split(',')){
				String fieldAPIName = s.toLowerCase().trim();
				if ( !outPutFieldsSet.contains(fieldAPIName) ){
					outPutFields.add( s.trim() );
					outPutFieldsQuery += s + ',';
					outPutFieldsSet.add( s.toLowerCase().trim() );
				}
			}

			outPutFieldsQuery = outPutFieldsQuery.removeEnd(',');
			if (String.isEmpty(outPutFieldsQuery)){
				outPutFieldsQuery = 'Id';
				outPutFieldsSet.add( 'id' );
			}
			if (!outPutFieldsSet.contains('id')){
				outPutFieldsQuery = 'Id,' + outPutFieldsQuery;
			}

			Set<String> fieldNames = new Set<String>();
			for ( String s : String.isEmpty(metaData.LookUpFields__c) ? new List<String>() : metaData.LookUpFields__c.split(',') ){
				String fieldAPIName = s.toLowerCase().trim();
				if (!outPutFieldsSet.contains(fieldAPIName)){
					outPutFieldsQuery += ',' + s;
					outPutFields.add(s);
				}
				fieldNames.add( s.toLowerCase().trim() );
			}
			for (String s : fieldNames){
				lookUpConditionFieldQuery += s + ' = \'' + String.valueOf( executedUserId ) + '\' or ';
			}
			lookUpConditionFieldQuery = lookUpConditionFieldQuery.removeEnd(' or ');
			lookUpConditionFieldQuery = !String.isEmpty(lookUpConditionFieldQuery) ? '(' + lookUpConditionFieldQuery + ')' : '';

			String additionalCondition = String.isEmpty(metaData.AdditionalCondition__c) ? '' : metaData.AdditionalCondition__c;
			String queryRowsLimit = metaData.MaxRecordCount__c == null /*|| metaData.MaxRecordCount__c > 1000*/ || metaData.MaxRecordCount__c == 0 ? '10000' : String.valueOf(metaData.AdditionalCondition__c);

			this.query = String.format('SELECT {0} FROM {1} WHERE {2} ' + (!String.isEmpty(additionalCondition) && !String.isEmpty(lookUpConditionFieldQuery) ? 'AND' : '') + ' {3} LIMIT {4}',
											new List<String>{outPutFieldsQuery, metaData.ApiName__c, lookUpConditionFieldQuery, additionalCondition, queryRowsLimit});

			System.Debug(LoggingLevel.ERROR, '^^^ query = ' + query);
			sObjects = Database.query(query);
		}
	}
}