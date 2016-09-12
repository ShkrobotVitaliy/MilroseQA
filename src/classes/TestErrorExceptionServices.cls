@isTest
private class TestErrorExceptionServices {

    private static final Integer NUMBER_TO_CREATE_CONTACT = 4;
    private static final String TEST_EMAIL_TEMPLATE_PREFIX = '@gmail.com';

    private static List<Contact> testContactList;

    private static void setupData(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT * 2, false);
        for (Contact contactItem : testContactList){
            contactItem.Email = contactItem.LastName + TEST_EMAIL_TEMPLATE_PREFIX;
        }
        insert testContactList;
    }

    private static List<Debug_Log__c> getAllDebugLogs(){
        return [SELECT Id
                FROM Debug_Log__c];
    }

    private static testmethod void testException(){
        
        Test.startTest();
            ErrorException test1 = new ErrorException('');
            try{
                throw new ErrorException('test');
            } catch (ErrorException e){
                
            }
            String s = ErrorException.TASK_ITEM_EMPTY;

            System.assert(! String.isBlank(s) );

        Test.stopTest();
    }


    private static testmethod void testLog(){
        setupData();

        String errorString;

        Test.startTest();
            ErrorException test1 = new ErrorException('');

            try{
                throw new ErrorException('test');

            } catch (ErrorException e){
                errorString = e.getMessage();
            }

            String s = ErrorException.TASK_ITEM_EMPTY;
        Test.stopTest();

        System.assert(! String.isEmpty(errorString) );
    }

}