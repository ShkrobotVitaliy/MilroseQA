/**
 * Routine class for helping debug in SalesForce
 */
public with sharing class DebugHelper {
	
	private static String ENTRANCE_STAGE = 'entrance';
	private static String EXIT_STAGE = 'exit';
	private static String MARK_STAGE = 'mark';
	
	public class ActionParams {
		public String methodName { get; set; }
		public String options { get; set; }
		public String stage { get; set; }
		public Integer level { get; set; }
		
		public ActionParams(String method, String st) {
			methodName = method;
			stage = st;
			level = 0;
		}
		
		public ActionParams(String method, String st, String opt) {
			this(method, st);
			options = opt;
		}
	}
	
	public interface IAction {
		void proceed(ActionParams params);
		void flush();
	}
	
	public class ActionLogger implements IAction {
		
		private List<String> logLines = new List<String>();
		public void proceed(ActionParams params) {
			String lim = 'SOQL: ' + Limits.getQueries();
			String opt = ( String.isBlank(params.options) ) ? '' : '(' + params.options +')';
			String levelPrefix = '';
			for (Integer i=0; i<params.level; i++) levelPrefix += '_ ';
			logLines.add(levelPrefix + params.stage + ' -> ' + params.methodName + opt + ', ' + lim);
		}
		
		public void flush() {
			System.debug(LoggingLevel.Error, '\n' + String.join(logLines, '\n'));
		}
	}
	
	private static IAction actionItem { get; set; }
	private static List<String> stackList = new List<String>();
	
	private static void doAction(ActionParams params) {
		if ( actionItem != null ) {
			// update level
			params.level = stackList.size();
			if ( params.stage == ENTRANCE_STAGE ) {
				stackList.add(params.stage);
			} else if ( params.stage == EXIT_STAGE && !stackList.isEmpty() ) {
				stackList.remove(stackList.size() - 1);
				params.level = stackList.size();
			}
			
			actionItem.proceed(params);
		}
	}
	
	private static String buildTriggerOptions(Boolean isBefore, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
		String opt = ( isBefore ) ? 'before' : 'after';
		if ( isInsert ) opt += ' insert';
		if ( isUpdate ) opt += ' update';
		if ( isDelete ) opt += ' delete';
		return opt;
	}
	
	public static void triggerEntrance(String triggerName, Boolean isBefore, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
		doAction(new ActionParams(triggerName, ENTRANCE_STAGE, buildTriggerOptions(isBefore, isInsert, isUpdate, isDelete)));
	}
	
	public static void triggerExit(String triggerName, Boolean isBefore, Boolean isInsert, Boolean isUpdate, Boolean isDelete) {
		doAction(new ActionParams(triggerName, EXIT_STAGE, buildTriggerOptions(isBefore, isInsert, isUpdate, isDelete)));
	}
	
	public static void markEntrance(String method) {
		doAction(new ActionParams(method, ENTRANCE_STAGE));
	}
	
	public static void markExit(String method) {
		doAction(new ActionParams(method, EXIT_STAGE));
	}
	
	public static void mark(String method, String msg) {
		if ( String.isBlank(msg) ) msg = MARK_STAGE;
		doAction(new ActionParams(method, msg));
	}
	
	public static void start(IAction action) {
		actionItem = action;
		doAction(new ActionParams('debug', 'start'));
	}
	
	public static void stop() {
		if ( actionItem != null ) {
			actionItem.flush();
		}
	}
	
}