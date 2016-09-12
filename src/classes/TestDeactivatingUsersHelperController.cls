@isTest
private class TestDeactivatingUsersHelperController {
	
	@isTest static void testDeactUsersHelper() {
		DeactivatingUsersHelperController con = new DeactivatingUsersHelperController();
		String xmlheader = con.xmlheader;
		List<String> bliFieldsApiName = con.bliFieldsApiName;
		List<sObject> blisTest = con.blisTest;
		List<sObject> sObjects = con.workSheets[0].sObjects;
		
	}
}