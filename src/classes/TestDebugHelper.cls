@isTest
private class TestDebugHelper {

private static String ACTION_METHOD = 'test method';
private static String ENTRANCE_STAGE = 'entrance';
private static String ACTION_OPTION = 'test stage';

	
	private static testmethod void testTestDebugHelper() {
		DebugHelper.ActionParams param1 = new DebugHelper.ActionParams(ACTION_METHOD, ENTRANCE_STAGE, ACTION_OPTION);
		DebugHelper.ActionLogger acl = new DebugHelper.ActionLogger();
		DebugHelper.IAction action1 = acl;
		DebugHelper.start(action1);
		DebugHelper.triggerEntrance('testTrigger', true, true, false, false);
		DebugHelper.triggerExit('testTrigger', true, true, false, false);
		DebugHelper.markEntrance(ACTION_METHOD);
		DebugHelper.markExit(ACTION_METHOD);
		DebugHelper.mark(ACTION_METHOD, ENTRANCE_STAGE);
		DebugHelper.start(action1);


		DebugHelper.stop();

	}
}