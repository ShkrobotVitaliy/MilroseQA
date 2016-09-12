@isTest
private class TestMultiselectController {
	private static MultiselectController testController;

	private static testmethod void testInitController(){
		Test.startTest();

			testController = new MultiselectController();
			System.assert(testController != null);

			testController.leftOptions = new List<SelectOption>();
			testController.rightOptions = new List<SelectOption>();

			testController.leftOptionsHidden = 'test1&test2&test3';
			testController.rightOptionsHidden = 'test4&test4&test5';

		Test.stopTest();
	}
}