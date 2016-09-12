@isTest
private class TestRFIWorkTypeServices {
	private static final String workType = 'TestWork';
	private static final String workSecondType = 'TestWorkSecond';
	private static final Integer NUMBER_TO_CREATE = 5;
	private static List<RFI_Scope__c> rfiScopeList;
	private static List<Service_Item__c> testServiceItemList;
	private static void setUp(Boolean doInsert){
		testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, false);
			testServiceItemList[0].Work_Type__c = workType;
			testServiceItemList[1].Work_Type__c = workSecondType;
			insert testServiceItemList;
			
		rfiScopeList = TestingUtils.createRFIScopeList(NUMBER_TO_CREATE, false);
		for(RFI_Scope__c rfiScopeItem : rfiScopeList){
			rfiScopeItem.Application_Service_Item__c = testServiceItemList[0].Id;
			rfiScopeItem.Sign_Off_Service_Item__c = testServiceItemList[1].Id;
		}
			rfiScopeList[0].Name = RFIWorkTypeServices.NYC_RFI05;
		if(doInsert){
			insert rfiScopeList;
		}
	} 
	
	private static testmethod void testCreateRFIWorkType(){
		setUp(false);		
		
		Test.startTest();
			insert rfiScopeList;
		Test.stopTest();
		
		
		List<RFI_Work__c> testList = [SELECT Id,Name FROM RFI_Work__c];
		System.assertEquals(2, testList.size());
		for(RFI_Work__c item : testList){
			if(item.Name == workType){
				System.assertEquals(workType, item.Name);
			}else if(item.Name == workSecondType){
				System.assertEquals(workSecondType, item.Name);
			}else{
				throw new ErrorException('WorkTypes are incorrect');
			}
		}
	}
	
	private static testMethod void testGetWorkTypeByServiceItemId(){
		setUp(true);
		Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>();
		for(RFI_Scope__c item : rfiScopeList){
			rfiMap.put(item.Id,item);
		}
		RFIWorkTypeServices.createRFIWorkType(rfiMap);
		
		Test.startTest();
			 List<RFI_Work__c> getWorkTypeByServiceItemIds = RFIWorkTypeServices.getWorkTypeByServiceItemId(testServiceItemList[0].Id);
		Test.stopTest();
		
		/*System.debug(LoggingLevel.Error,'@@@getWorkTypeByServiceItemIds' + getWorkTypeByServiceItemIds);
		System.assertEquals(2, getWorkTypeByServiceItemIds.size());
		for(RFI_Work__c item : getWorkTypeByServiceItemIds){
			if(item.Name == workType){
				System.assertEquals(workType, item.Name);
			}else if(item.Name == workSecondType){
				System.assertEquals(workSecondType, item.Name);
			}else{
				throw new ErrorException('WorkTypes are incorrect');
			}
		}*/
	}
	
	private static testMethod void testGetWorkTypeByServiceItemIdSetOfId(){
		setUp(true);
		Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>();
		for(RFI_Scope__c item : rfiScopeList){
			rfiMap.put(item.Id,item);
		}
		RFIWorkTypeServices.createRFIWorkType(rfiMap);
		Set<Id> testSet = new Set<Id>();
			testSet.add(testServiceItemList[0].Id);
		
		Test.startTest();
			 List<RFI_Work__c> getWorkTypeByServiceItemIds = RFIWorkTypeServices.getWorkTypeByServiceItemIds(testSet);
		Test.stopTest();
		
		/*System.assertEquals(2, getWorkTypeByServiceItemIds.size());
		for(RFI_Work__c item : getWorkTypeByServiceItemIds){
			if(item.Name == workType){
				System.assertEquals(workType, item.Name);
			}else if(item.Name == workSecondType){
				System.assertEquals(workSecondType, item.Name);
			}else{
				throw new ErrorException('WorkTypes are incorrect');
			}
		}*/
	}
	
	private static testMethod void testGetWorkTypeByServiceItemIdException(){
		setUp(true);
		Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>();
		for(RFI_Scope__c item : rfiScopeList){
			rfiMap.put(item.Id,item);
		}
		RFIWorkTypeServices.createRFIWorkType(rfiMap);
		Id testId;
		
		Test.startTest();
			try{
				 List<RFI_Work__c> getWorkTypeByServiceItemIds = RFIWorkTypeServices.getWorkTypeByServiceItemId(testId);
			}catch(Exception e){
				String exceptionString = String.valueOf(e);
			}
		Test.stopTest();
	}
	
	private static testMethod void testGetWorkTypeByServiceItemIdSetOfIdException(){
		setUp(true);
		Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>();
		for(RFI_Scope__c item : rfiScopeList){
			rfiMap.put(item.Id,item);
		}
		RFIWorkTypeServices.createRFIWorkType(rfiMap);
		Set<Id> testSet = new Set<Id>();
		
		Test.startTest();
			try{
				 List<RFI_Work__c> getWorkTypeByServiceItemIds = RFIWorkTypeServices.getWorkTypeByServiceItemIds(testSet);
			}catch (Exception e){
				String  exceptionString = String.valueOf(e);
			}
		Test.stopTest();
	}
	
}