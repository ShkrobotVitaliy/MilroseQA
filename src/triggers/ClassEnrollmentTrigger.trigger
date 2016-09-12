trigger ClassEnrollmentTrigger on Class_Enrollment__c (before insert, before update) {
	if(Trigger.isBefore) {
		if(Trigger.isInsert || Trigger.isUpdate) {
			ClassEnrollmentServices.checkIfPrerequisiteCourseCompleted(Trigger.new);													
		}
	}
}