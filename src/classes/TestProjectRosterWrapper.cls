@isTest
private class TestProjectRosterWrapper {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static ProjectRosterWrapper testProjectWrap;
    private static Contact testContact;
    private static final String TEST_NAME = 'Test Name';
    private static final String TEST_ROLE = 'Test Role';
    private static final String TEST_EMAIL = 'test@email.com';

    public static void setUp(){
        testContact = TestingUtils.createContactList(NUMBER_TO_CREATE, true)[0];
    }

    private static testmethod void testProjectRosterWrapperConstructorFirst(){
        setUp();

        Test.startTest();

            testProjectWrap = new ProjectRosterWrapper(TEST_NAME, TEST_EMAIL);

        Test.stopTest();

        System.assert(testProjectWrap != null);
        System.assertEquals(TEST_NAME, testProjectWrap.name);
        System.assertEquals(TEST_EMAIL, testProjectWrap.email);
        System.assertEquals(false, testProjectWrap.isSelect);
    }

    private static testmethod void testProjectRosterWrapperConstructorSecond(){
        setUp();

        Test.startTest();

            testProjectWrap = new ProjectRosterWrapper(TEST_NAME, TEST_EMAIL, testContact, TEST_ROLE);

        Test.stopTest();

        System.assert(testProjectWrap != null);
        System.assertEquals(TEST_NAME, testProjectWrap.name);
        System.assertEquals(TEST_EMAIL, testProjectWrap.email);
        System.assertEquals(false, testProjectWrap.isSelect);
        System.assertEquals(TEST_ROLE, testProjectWrap.role);
        System.assert(testProjectWrap.contact != null);
    }
}