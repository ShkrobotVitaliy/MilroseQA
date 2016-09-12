@isTest
private class TestClassEnrollmentTrigger {
    
    @isTest static void test_method_one() {
        User user = TestingUtils.createUsers(1, false)[0];
    user.MU_Instructor__c = true;
    insert user;
        MU_Course__c course = new MU_Course__c(Name = 'Hip-Hop Beginner',  Instructor__c = user.Id, Duration_Mins__c = 360);
        INSERT course;
        MU_Classes__c muClass = new MU_Classes__c(Course__c = course.Id, Name = course.Name, Start__c = Date.today() + 5);
        INSERT muClass;
        Class_Enrollment__c ce = new Class_Enrollment__c(Student_Name__c = user.Id, Status__c = 'Registered', Class__c = muClass.Id);
        INSERT ce;
    }

    
}