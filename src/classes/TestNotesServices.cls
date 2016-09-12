@isTest
private class TestNotesServices {
    private static final Integer NUMBER_TO_CREATE_NOTE = 4;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 3;//parent object for Note
    private static final String TEST_NOTE_TITLE = 'TestTitle';
    private static final String TEST_NOTE_BODY = 'test Note Body value';

    private static List<Note> testNoteList;
    private static List<Contact> testContactList;//parent object for Note

    private static testmethod void testFilterAndSaveNotes(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT + 1, true);

        testNoteList = new List<Note>();
        for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE + 1, testContactList[0].Id, TEST_NOTE_TITLE, false)){
            noteItem.Body = 'test';
            testNoteList.add(noteItem);
        }
        insert testNoteList;

        Test.startTest();

            NotesServices.filterAndSaveNotes(testContactList[1].Id, testNoteList, new Note(Title = TEST_NOTE_TITLE), TEST_NOTE_BODY);

        Test.stopTest();
    }

    private static testmethod void testFilterAndSaveNotesWithEmptyList(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, true);

        Test.startTest();

            NotesServices.filterAndSaveNotes(testContactList[0].Id, new List<Note>(), new Note(Title = TEST_NOTE_TITLE), TEST_NOTE_BODY);

        Test.stopTest();
    }

    private static testmethod void testRetrieveNotes(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, true);

        testNoteList = new List<Note>();
        for (Contact contactItem : testContactList){
            for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE, contactItem.Id, TEST_NOTE_TITLE, false)){
                noteItem.Body = 'test';
                testNoteList.add(noteItem);
            }
        }
        insert testNoteList;

        List<Note> resultNoteList;

        Test.startTest();

            resultNoteList = NotesServices.retrieveNotes(testContactList[0].Id);

        Test.stopTest();

        System.assert(!resultNoteList.isEmpty());
    }

    private static testmethod void testgetNotesByParentIds(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, true);

        testNoteList = new List<Note>();
        for (Contact contactItem : testContactList){
            for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE, contactItem.Id, TEST_NOTE_TITLE, false)){
                testNoteList.add(noteItem);
            }
        }
        insert testNoteList;

        List<Note> resultNoteList;

        Test.startTest();

            resultNoteList = NotesServices.getNotesByParentIds(new Map<Id, Contact>(testContactList).keySet(), true);

        Test.stopTest();

        System.assert(!resultNoteList.isEmpty());
    }

    private static testmethod void testgetNotesByParentIdsWithEmptyParentSet(){
        List<Note> resultNoteList;

        Test.startTest();

            resultNoteList = NotesServices.getNotesByParentIds(new Set<Id>(), true);

        Test.stopTest();

        System.assert(resultNoteList.isEmpty());
    }

    private static testmethod void testJoinNotes(){
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, true);

        testNoteList = new List<Note>();
        for (Contact contactItem : testContactList){
            for (Note noteItem : TestingUtils.createNoteList(NUMBER_TO_CREATE_NOTE + 1, contactItem.Id, TEST_NOTE_TITLE, false)){
                noteItem.Body = 'test';
                testNoteList.add(noteItem);
            }
        }
        insert testNoteList;

        String resultString;

        Test.startTest();

            resultString = NotesServices.joinNotes(testNoteList);

        Test.stopTest();

        System.assert(!String.isEmpty(resultString));
    }
}