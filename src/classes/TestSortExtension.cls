@isTest
private class TestSortExtension {
	
	
	
	private static testMethod void testGetSortDirection(){
		SortExtension srtExt = new SortExtension('DESC');		
		srtExt.setSortDirection('ASC');
		
		Test.startTest();
			String testString  = srtExt.getSortDirection();
		Test.stopTest();
	}
	
	private static testMethod void testSetSortDirection(){
		SortExtension srtExt = new SortExtension('');		
		srtExt.setSortDirection('ASC');
		srtExt.sortExpression = '';
		
		Test.startTest();
			String testString  = srtExt.getSortDirection();
		Test.stopTest();
	}
}