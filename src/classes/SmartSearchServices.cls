public with sharing class SmartSearchServices {

	public static void createJunctionsAndPopulateSearchFields( Smart_Search__c smartSearch ){
		String queryWhereAccount = 'Select Id, Name, Smart_Search_Description__c From Account Where ';
		String queryWhereBuilding = 'Select Id, Name, Smart_Search_Description__c From Building__c Where ';

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

	public static void updateAccountOrBuildingAfterSSupdating( Smart_Search__c smartSearchOld, Smart_Search__c smartSearchNew ){
		List<Account> findedAccountsForUpate = new List<Account>();

		for( Account_Search_Junction__c item: [Select Id, Name, Account__c, Account__r.Smart_Search_Description__c
												From Account_Search_Junction__c
												Where Smart_Search__c =: smartSearchOld.Id] ){
			Account findedAccount;
			String oldSmartSearchValueFromAccount = item.Account__r.Smart_Search_Description__c;
			if( smartSearchOld.Smart_Search_Version_1__c != smartSearchNew.Smart_Search_Version_1__c ){
				findedAccount = new Account(Id = item.Account__c, Smart_Search_Description__c = oldSmartSearchValueFromAccount.replaceFirst(smartSearchOld.Smart_Search_Version_1__c,smartSearchNew.Smart_Search_Version_1__c));
			}

			if( smartSearchOld.Smart_Search_Version_2__c != smartSearchNew.Smart_Search_Version_2__c ){
				if( findedAccount == null ) findedAccount = new Account(Id = item.Account__c, Smart_Search_Description__c = oldSmartSearchValueFromAccount );
				if( smartSearchOld.Smart_Search_Version_2__c == null ){
					findedAccount.Smart_Search_Description__c += smartSearchNew.Smart_Search_Version_2__c + ';';
				}else{
					if( smartSearchNew.Smart_Search_Version_2__c == null ){
						findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_2__c + ';', '');
					}else{
						findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_2__c + ';', smartSearchNew.Smart_Search_Version_2__c + ';');
					}
				}
			}

			if( smartSearchOld.Smart_Search_Version_3__c != smartSearchNew.Smart_Search_Version_3__c ){
				if( findedAccount == null ) findedAccount = new Account(Id = item.Account__c, Smart_Search_Description__c = oldSmartSearchValueFromAccount );
				if( smartSearchOld.Smart_Search_Version_3__c == null ){
					findedAccount.Smart_Search_Description__c += smartSearchNew.Smart_Search_Version_3__c + ';';
				}else{
					if( smartSearchNew.Smart_Search_Version_3__c == null ){
						findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_3__c + ';', '');
					}else{
						findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_3__c + ';', smartSearchNew.Smart_Search_Version_3__c + ';');
					}
				}
			}
			if( findedAccount != null ) findedAccountsForUpate.add( findedAccount );
		}

		List<Building__c> findedBuildingsForUpate = new List<Building__c>();

		for( Building_Search_Junction__c item: [Select Id, Name, Building__c, Building__r.Smart_Search_Description__c
												From Building_Search_Junction__c
												Where Smart_Search__c =: smartSearchOld.Id] ){
			Building__c findedBuilding;
			String oldSmartSearchValueFromBuilding = item.Building__r.Smart_Search_Description__c;

			if( smartSearchOld.Smart_Search_Version_1__c != smartSearchNew.Smart_Search_Version_1__c ){
				findedBuilding = new Building__c(Id = item.Building__c, Smart_Search_Description__c = oldSmartSearchValueFromBuilding.replaceFirst(smartSearchOld.Smart_Search_Version_1__c,smartSearchNew.Smart_Search_Version_1__c));
			}

			if( smartSearchOld.Smart_Search_Version_2__c != smartSearchNew.Smart_Search_Version_2__c ){
				if( findedBuilding == null ) findedBuilding = new Building__c(Id = item.Building__c, Smart_Search_Description__c = oldSmartSearchValueFromBuilding );
				if( smartSearchOld.Smart_Search_Version_2__c == null ){
					findedBuilding.Smart_Search_Description__c += smartSearchNew.Smart_Search_Version_2__c + ';';
				}else{
					if( smartSearchNew.Smart_Search_Version_2__c == null ){
						findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_2__c + ';', '');
					}else{
						findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_2__c + ';', smartSearchNew.Smart_Search_Version_2__c + ';');
					}
				}
			}

			if( smartSearchOld.Smart_Search_Version_3__c != smartSearchNew.Smart_Search_Version_3__c ){
				if( findedBuilding == null ) findedBuilding = new Building__c(Id = item.Building__c, Smart_Search_Description__c = oldSmartSearchValueFromBuilding );
				if( smartSearchOld.Smart_Search_Version_3__c == null ){
					findedBuilding.Smart_Search_Description__c += smartSearchNew.Smart_Search_Version_3__c + ';';
				}else{
					if( smartSearchNew.Smart_Search_Version_3__c == null ){
						findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_3__c + ';', '');
					}else{
						findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearchOld.Smart_Search_Version_3__c + ';', smartSearchNew.Smart_Search_Version_3__c + ';');
					}
				}
			}
			if( findedBuilding != null ) findedBuildingsForUpate.add( findedBuilding );
		}

		update findedAccountsForUpate;
		update findedBuildingsForUpate;
	}

	public static void cleanAccountOrBuildingAfterSSdeleting( Smart_Search__c smartSearch ){
		List<Account> findedAccountsForUpate = new List<Account>();
		for( Account_Search_Junction__c item: [Select Id, Name, Account__c, Account__r.Smart_Search_Description__c
												From Account_Search_Junction__c
												Where Smart_Search__c =: smartSearch.Id] ){

			if( smartSearch.Smart_Search_Version_1__c != null ){
				Account findedAccount = new Account(Id = item.Account__c, Smart_Search_Description__c = item.Account__r.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_1__c+';',''));

				if( smartSearch.Smart_Search_Version_2__c != null ){
					findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_2__c+';','');
				}
				if( smartSearch.Smart_Search_Version_3__c != null ){
					findedAccount.Smart_Search_Description__c = findedAccount.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_3__c+';','');
				}
				findedAccountsForUpate.add(findedAccount);
			}
		}

		List<Building__c> findedBuildingsForUpate = new List<Building__c>();
		for( Building_Search_Junction__c item: [Select Id, Name, Building__c, Building__r.Smart_Search_Description__c
												From Building_Search_Junction__c
												Where Smart_Search__c =: smartSearch.Id] ){

			if( smartSearch.Smart_Search_Version_1__c != null ){
				Building__c findedBuilding = new Building__c(Id = item.Building__c, Smart_Search_Description__c = item.Building__r.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_1__c+';',''));

				if( smartSearch.Smart_Search_Version_2__c != null ){
					findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_2__c+';','');
				}
				if( smartSearch.Smart_Search_Version_3__c != null ){
					findedBuilding.Smart_Search_Description__c = findedBuilding.Smart_Search_Description__c.replaceFirst(smartSearch.Smart_Search_Version_3__c+';','');
				}
				findedBuildingsForUpate.add(findedBuilding);
			}
		}

		update findedAccountsForUpate;
		update findedBuildingsForUpate;
	}

}