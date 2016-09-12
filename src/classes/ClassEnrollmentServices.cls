public with sharing class ClassEnrollmentServices {

	public static void checkIfPrerequisiteCourseCompleted(List<Class_Enrollment__c> enrollmentsNewList) {


		Set<Id> affectedClasses = new Set<Id> ();
		Set<Id> affectedUsers = new Set<Id> ();
		for(Class_Enrollment__c ce : enrollmentsNewList) if(ce.Class__c != null && ce.Student_Name__c != null) {
			affectedClasses.add(ce.Class__c);
			affectedUsers.add(ce.Student_Name__c);
		}

		Map<Id, Id> classIdToPreCourseItMap = new Map<Id, Id> ();
		for(MU_Classes__c muClass : [SELECT Course__c, Course__r.Prerequisite_Course__c, Course__r.Prerequisite_Required__c
									FROM MU_Classes__c
									WHERE Id IN :affectedClasses]) {
			if(muClass.Course__c != null && muClass.Course__r.Prerequisite_Course__c != null
				&& muClass.Course__r.Prerequisite_Required__c == 'Yes') classIdToPreCourseItMap.put(muClass.Id, muClass.Course__r.Prerequisite_Course__c);
		}

		Map<Id, Set<Id>> userIdToCompletedCoursesSetMap = new Map<Id, Set<Id>> ();
		for(Class_Enrollment__c ce : [SELECT Class__r.Course__c, Student_Name__c
										 FROM Class_Enrollment__c
										 WHERE Status__c = 'Completed'
										   AND Student_Name__c IN :affectedUsers
										   AND Class__r.Course__c IN :classIdToPreCourseItMap.values()]) {
			if(userIdToCompletedCoursesSetMap.get(ce.Student_Name__c) == null) userIdToCompletedCoursesSetMap.put(ce.Student_Name__c, new Set<Id> ()); 
			userIdToCompletedCoursesSetMap.get(ce.Student_Name__c).add(ce.Class__r.Course__c);	
		}

		for(Class_Enrollment__c ce : enrollmentsNewList) {
			if(  ce.Class__c != null && ce.Student_Name__c != null
			  && classIdToPreCourseItMap.get(ce.Class__c) != null
			  && (userIdToCompletedCoursesSetMap.get(ce.Student_Name__c) == null
			     || !userIdToCompletedCoursesSetMap.get(ce.Student_Name__c).contains(classIdToPreCourseItMap.get(ce.Class__c)))
			) {
				ce.addError('You cannot register for this class until you have completed the prerequisite course.');
			}
		}
	}

	public ClassEnrollmentServices() {
		
	}
}