@isTest
private class TestAttendAppointmentController {

    private static ApexPages.StandardController testController;
    private static AttendAppointmentController testAttendAppointmentController;

    @isTest
    private static void testAttendAppointmentController() {

        setupTestData();
        setupTestPageAndController();

        List<Appointment__c> appointments = getAllAppointments();
        System.assert(! appointments.isEmpty() );

        Test.startTest();
            testAttendAppointmentController = new AttendAppointmentController(testController);
            testAttendAppointmentController.pageLoad();
            testAttendAppointmentController.isUser = true;
            testAttendAppointmentController.updateAttendees();
            testAttendAppointmentController.updateAppointment();
            

            testAttendAppointmentController.isUser = true;
            testAttendAppointmentController.appointmentId = appointments[0].Id;
            testAttendAppointmentController.isUser = true;
            testAttendAppointmentController.pageLoad();
            //testAttendAppointmentController.addAttendee();
            
            testAttendAppointmentController.pageLoad();
            testAttendAppointmentController.appointmentId = appointments[0].Id;
            testAttendAppointmentController.createEvent();
            
            testAttendAppointmentController.isUser = false;
            testAttendAppointmentController.addAttendee();
            testAttendAppointmentController.updateAttendees();
            testAttendAppointmentController.updateAppointment();
            testAttendAppointmentController.addNewAppointment();

            //testAttendAppointmentController.createEvent();
            testAttendAppointmentController.getGmtShift();

            testAttendAppointmentController.getMinute();
            List<SelectOption> test1 = testAttendAppointmentController.getOptions('Appointment_Type__c');
            testAttendAppointmentController.addMessage('Error', 'Info');
        Test.stopTest();

    }

    @isTest
    private static void testAttendAppointmentControllerWithNoAppointments() {

        setupTestData();
        setupTestPageAndController();

        List<Appointment__c> appointments = getAllAppointments();
        System.assert(! appointments.isEmpty() );
       
        delete appointments;

        Test.startTest();
            testAttendAppointmentController = new AttendAppointmentController(testController);
            testAttendAppointmentController.pageLoad();
            testAttendAppointmentController.isUser = true;
            testAttendAppointmentController.updateAttendees();
            testAttendAppointmentController.updateAppointment();
        Test.stopTest();

        //one appointment was created by controller
        appointments = getAllAppointments();
        System.assert(! appointments.isEmpty() );
    }    


    //helper methods

    //task item must be pre-setup before methods call
    private static void setupTestData(){
        Task_Item__c taskItem = TestingUtils.createTaskItemList(1, false)[0];
        taskItem.X3rd_Party_Authority_ID__c = 'testId';
        insert taskItem;

        List<Appointment__c>  appointmentList = TestingUtils.createAppointmentList(1, false);
        appointmentList[0].Task_Item__c = taskItem.Id;
        appointmentList[0].Appointment_Type__c = 'test';
        appointmentList[0].Notes__c = 'Notes';
        insert appointmentList;
        List<Attendee__c>  attendeeList = TestingUtils.createAttendeeList(2, false, appointmentList[0].Id);
        attendeeList = TestingUtils.createAttendeeList(2, false, appointmentList[0].Id);
        Contact cont = TestingUtils.createContactList(1, true)[0];
        attendeeList[0].Contact__c = cont.Id;
        attendeeList[0].isUser__c = false;
        attendeeList[1].User__c = UserInfo.getUserId();
        attendeeList[1].isUser__c = true;
        insert attendeeList; 
        
        MilroseSetting__c setting = new MilroseSetting__c();
        setting.Name = 'activitie_field_id';
        setting.Activitie_field_id__c = 'test';
        insert setting;               
        
        setting = new MilroseSetting__c();
        setting.Name = 'appointmen_field_id';
        setting.Appointmen_field_id__c = 'test';
        insert setting;    
    }

    private static void setupTestPageAndController(){
        List<Task_Item__c> taskItems = getAllTaskItems();
        System.assert(! taskItems.isEmpty());

        Test.setCurrentPageReference(Page.AttendAppointment);
        testController = new ApexPages.StandardController( taskItems.get(0) );
        testAttendAppointmentController = new AttendAppointmentController(testController);
    }

    //helper DAO methods

    private static List<Appointment__c> getAllAppointments(){
        return [SELECT Id
                FROM Appointment__c];
    }

    private static List<Task_Item__c> getAllTaskItems(){
        return [SELECT Id, X3rd_Party_Authority_ID__c
                FROM Task_Item__c];
    }

}