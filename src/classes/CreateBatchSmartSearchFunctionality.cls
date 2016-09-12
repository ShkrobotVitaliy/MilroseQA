global class CreateBatchSmartSearchFunctionality implements Schedulable, Database.Batchable<sObject>, Database.AllowsCallouts  {

	global void execute( SchedulableContext sc ) {
        CreateBatchSmartSearchFunctionality batch = new CreateBatchSmartSearchFunctionality();
        Database.executeBatch( batch, 1 );
    }

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator( 'Select Id, Name, Original_Version__c, Smart_Search_Version_1__c, Smart_Search_Version_2__c, Smart_Search_Version_3__c From Smart_Search__c' );
    }

    //Execute method
    global void execute( Database.BatchableContext BC, List<Sobject> scope ) {
    	List<Smart_Search__c> scopeList = (List<Smart_Search__c>)scope;
    	Smart_Search__c smartSearch = scopeList[0];

    	String queryWhereAccount = 'Select Id, Name, Smart_Search_Description__c From Account Where ( ';
		String queryWhereBuilding = 'Select Id, Name, Smart_Search_Description__c From Building__c Where ( ';

		//Selection of needed Account and Buildings based on original search values
		String originalValue = smartSearch.Original_Version__c;

		//Accounts
		SObjectType acc = Schema.getGlobalDescribe().get('Account');
		Map<String,Schema.SObjectField> allAccountFields = acc.getDescribe().fields.getMap();

		for( String item: allAccountFields.keySet() ){
			String likeCondition = '';
			if( String.valueOf(allAccountFields.get(item).getDescribe().getType()) == 'STRING'){
				String fieldName = allAccountFields.get(item).getDescribe().getName();

				likeCondition += ' ( ' + fieldName + ' like \'%' + originalValue + '%\'  )' + ' OR';

				queryWhereAccount += likeCondition;
			}
		}
		queryWhereAccount = queryWhereAccount.removeEnd('OR');

		Set<Id> connectedAccountsIds = new Set<Id>();
		for( Account_Search_Junction__c item: [Select Id, Account__c, Smart_Search__c From Account_Search_Junction__c Where Smart_Search__c =: smartSearch.Id]){
			connectedAccountsIds.add( item.Account__c);
		}
		queryWhereAccount += ' ) AND (Id NOT IN : connectedAccountsIds) ';

		List<Account> findedAccounts = Database.query(queryWhereAccount);
		List<Account_Search_Junction__c> accountSearchJunctionsList = new List<Account_Search_Junction__c>();

		//Populating smart search values from Smart search records to Account hidden text area field and junction object inserting
		for( Account item: findedAccounts ){
			if( item.Smart_Search_Description__c == null ) item.Smart_Search_Description__c = '';
			if( smartSearch.Smart_Search_Version_1__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_1__c + ';';
			if( smartSearch.Smart_Search_Version_2__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_2__c + ';';
			if( smartSearch.Smart_Search_Version_3__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_3__c + ';';

			accountSearchJunctionsList.add( new Account_Search_Junction__c(Account__c = item.Id, Smart_Search__c = smartSearch.Id) );
		}

		//Buildings
		SObjectType build = Schema.getGlobalDescribe().get('Building__c');
		Map<String,Schema.SObjectField> allBuildingFields = build.getDescribe().fields.getMap();

		for( String item: allBuildingFields.keySet() ){
			String likeCondition = '';
			if( String.valueOf(allBuildingFields.get(item).getDescribe().getType()) == 'STRING'){
				String fieldName = allBuildingFields.get(item).getDescribe().getName();

				likeCondition += ' ( ' + fieldName + ' like \'%' + originalValue + '%\'  )' + ' OR';

				queryWhereBuilding += likeCondition;
			}
		}
		queryWhereBuilding = queryWhereBuilding.removeEnd('OR');

		Set<Id> connectedBuildingsIds = new Set<Id>();
		for( Building_Search_Junction__c item: [Select Id, Building__c, Smart_Search__c From Building_Search_Junction__c Where Smart_Search__c =: smartSearch.Id]){
			connectedBuildingsIds.add( item.Building__c);
		}
		queryWhereBuilding += ' ) AND (Id NOT IN : connectedBuildingsIds) ';

		List<Building__c> findedBuildings = Database.query(queryWhereBuilding);
		List<Building_Search_Junction__c> buildingSearchJunctionsList = new List<Building_Search_Junction__c>();

		//Populating smart search values from Smart search records to Building hidden text area field and junction object inserting
		for( Building__c item: findedBuildings ){
			if( item.Smart_Search_Description__c == null ) item.Smart_Search_Description__c = '';
			if( smartSearch.Smart_Search_Version_1__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_1__c + ';';
			if( smartSearch.Smart_Search_Version_2__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_2__c + ';';
			if( smartSearch.Smart_Search_Version_3__c != null ) item.Smart_Search_Description__c += smartSearch.Smart_Search_Version_3__c + ';';

			buildingSearchJunctionsList.add( new Building_Search_Junction__c(Building__c = item.Id, Smart_Search__c = smartSearch.Id) );
		}

		update findedAccounts;
		update findedBuildings;

		insert accountSearchJunctionsList;
		insert buildingSearchJunctionsList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}