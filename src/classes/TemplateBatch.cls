global class TemplateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
 global String query;
 global String errors;

 private Id batchProcessId;
 private final String BATCH_JOB_TITLE = 'Template Batch Job ';

 private Date currentDate = Date.today();

 global TemplateBatch( String query, Date currDate ) {
  System.debug('TemplateBatch(query, currDate)');
  System.debug('TemplateBatch - query: ' + query);
  System.debug('TemplateBatch - query: ' + currDate);
  this.currentDate = currDate;
  this.query = query;
  this.errors = '';
 }

 global TemplateBatch() {
  System.debug('TemplateBatch()');
  this.query = 'SELECT Id FROM Account LIMIT 1';
  this.errors = '';
 }

 global database.querylocator start(Database.BatchableContext bc) {
  System.debug('TemplateBatch.start(bc)');
  System.debug('TemplateBatch.start - bc:' + bc);


  return Database.getQueryLocator(query);
 }

 global void execute(Database.BatchableContext bc, Sobject[] scope) {
  System.debug('TemplateBatch.execute(bc, scope)');
  System.debug('TemplateBatch.execute - bc:' + bc);
  System.debug('TemplateBatch.execute - scope:' + scope);

 }

 global void finish(Database.BatchableContext bc) {
  System.debug('TemplateBatch.finish(bc)');
  System.debug('TemplateBatch.execute - bc:' + bc);

 }

 /* Scheduler Method */
 global void execute(SchedulableContext sc) {
  System.debug('TemplateBatch.execute(sc)');
  System.debug('TemplateBatch.execute - sc:' + sc);

  TemplateBatch job = new TemplateBatch();
  batchProcessId = Database.executeBatch(job);
 }
}