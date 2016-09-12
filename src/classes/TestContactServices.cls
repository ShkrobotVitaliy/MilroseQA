@isTest
private class TestContactServices {

    private static testmethod void testCreateEventsFromTaskItemIfAlertIfNotification(){
        Test.startTest();

            List<Contact> test1 =  ContactServices.getContactsByIds(null);
            System.assert(test1.isEmpty());

            List<Contact> test2 =  ContactServices.getContactsByIds(new Set<Id>{TestingUtils.createContactList(1, true)[0].Id});
            System.assert(!test2.isEmpty());

            Map<Id, Contact> test3 =  ContactServices.getContactsByIdsFromProjectRosters(null);
            System.assert(test3.isEmpty());

            Map<Id, Contact> test4 =  ContactServices.getContactsByIdsFromProjectRosters(new Set<Id>{TestingUtils.createContactList(1, true)[0].Id});
            System.assert(!test4.isEmpty());

        Test.stopTest();
    }
}