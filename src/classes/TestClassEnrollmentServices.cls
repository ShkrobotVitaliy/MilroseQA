@isTest
private class TestClassEnrollmentServices {
    
    @isTest static void test_method_one() {
        User user = TestingUtils.createUsers(1, false)[0];
    user.MU_Instructor__c = true;
    insert user;
        MU_Course__c course1 = new MU_Course__c(Name = 'Hip-Hop Beginner', Instructor__c = user.Id, Duration_Mins__c = 360 );
        INSERT course1;
        MU_Course__c course2 = new MU_Course__c(Name = 'Hip-Hop Advanced', Prerequisite_Course__c = course1.Id, Prerequisite_Required__c = 'Yes', Instructor__c = user.Id, Duration_Mins__c = 360);
        INSERT course2;
        MU_Classes__c muClass = new MU_Classes__c(Course__c = course2.Id, Name = course2.Name, Start__c = Date.today() + 5 );
        INSERT muClass;
        Class_Enrollment__c ce = new Class_Enrollment__c(Student_Name__c = user.Id, Status__c = 'Registered', Class__c = muClass.Id);
        try{
            INSERT ce;
        }catch(Exception e){}
        
    }
    
    
}