@isTest
private class TestAddContactToSendCC {
    private static final Integer NUMBER_TO_CREATE_PROPOSAL_DRAFT = 1;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT_FOR_ACCOUNT = 1;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 1;

    private static final String EMAIL_ADDRESS_PREFIX = '@gmail.com';

    private static List<Account> testAccountList;
    private static List<Contact> testContactWithAccountList;
    private static List<Contact> testContactWithoutAccountList;
    private static List<Proposal__c> testProposalDraftList;
    private static PageReference testPage;
    private static AddContactToSendCC testController;

    private static void prepareDataForTest(){
        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, false);
        //populate Prinary Company name
        testAccountList[0].Name = 'Primary Company';
        //populate Billing Company name
        testAccountList[1].Name = 'Billing Company';
        //populate Accounting Contact name
        testAccountList[2].Name = 'Accounting Contact';
        insert testAccountList;
        List<sObject> temporarySobjectListForInsert = new List<sObject>();
        testContactWithoutAccountList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, false);
        for (Integer i = 0; i < testContactWithoutAccountList.size(); i++){
            testContactWithoutAccountList[i].Email = 'test_contact_email_number' + String.valueOf(i) + EMAIL_ADDRESS_PREFIX;
            temporarySobjectListForInsert.add(testContactWithoutAccountList[i]);
        }
        testContactWithAccountList = new List<Contact>();
        for (Account accountItem : testAccountList){
            Integer i = 0;
            for (Contact contactItem : TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT_FOR_ACCOUNT, accountItem.Id, false)){
                contactItem.Email = accountItem.Id + String.valueOf(i++) + EMAIL_ADDRESS_PREFIX;
                testContactWithAccountList.add(contactItem);
                temporarySobjectListForInsert.add(contactItem);
            }
        }

        testProposalDraftList = TestingUtils.createProposalWithStatusDraftList(NUMBER_TO_CREATE_PROPOSAL_DRAFT, false);
        for (Proposal__c proposalDraftItem : testProposalDraftList){
            temporarySobjectListForInsert.add(proposalDraftItem);
        }
        insert temporarySobjectListForInsert;

        testContactWithAccountList = [SELECT Id, Email, AccountId FROM Contact WHERE Id IN : testContactWithAccountList];
        testContactWithoutAccountList = [SELECT Id, Email, AccountId FROM Contact WHERE Id IN : testContactWithoutAccountList];
    }

    private static void preparePageControllerForTest(Id primaryCompanyId, Id billingCompanyId, Id accountingContactId, Id proposalDraftId,
                                                     List<Contact> contactListWhithAccount, List<Contact> contactListWithoutAccount){
        List<Contact> temporaryContactList = new List<Contact>();
        if(contactListWhithAccount != null && !contactListWhithAccount.isEmpty()){
            temporaryContactList.addAll(contactListWhithAccount);
        }
        if(contactListWithoutAccount != null && !contactListWithoutAccount.isEmpty()){
            temporaryContactList.addAll(contactListWithoutAccount);
        }
        testPage = Page.SendCopyToCC;
        Test.setCurrentPage(testPage);
        Set<Id> accountSetIdItem = new Set<Id>();
        if (primaryCompanyId != null){
            ApexPages.currentPage().getParameters().put('primaryCompany', primaryCompanyId); accountSetIdItem.add(primaryCompanyId);
        }
        if (billingCompanyId != null) {
            ApexPages.currentPage().getParameters().put('billingCompany', billingCompanyId); accountSetIdItem.add(billingCompanyId);
        }
        if (accountingContactId != null) {
            ApexPages.currentPage().getParameters().put('accountingContact', accountingContactId); accountSetIdItem.add(accountingContactId);
        }
        if (proposalDraftId != null) {
            ApexPages.currentPage().getParameters().put('proposalId', proposalDraftId);
        }
        Integer i = 0;
        for (Contact contactItem : temporaryContactList){
            if (accountSetIdItem.contains(contactItem.AccountId)){
                i++;
                ApexPages.currentPage().getParameters().put('contact_' + i, contactItem.Id);
            }
        }
        if (i > 0) ApexPages.currentPage().getParameters().put('i', String.valueOf(i));
        testController = new AddContactToSendCC();
    }

    private static testmethod void testCreateController(){
        prepareDataForTest();

        Test.startTest();
            preparePageControllerForTest(testAccountList[0].Id,
                                         testAccountList[1].Id,
                                         testAccountList[2].Id,
                                         testProposalDraftList[0].Id,
                                         testContactWithAccountList,
                                         testContactWithoutAccountList);
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty(), msgList);
    }

    private static testmethod void testGetContactsWithWitoutAccount(){
        prepareDataForTest();
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     testProposalDraftList[0].Id,
                                     testContactWithAccountList,
                                     testContactWithoutAccountList);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList;

        Test.startTest();
            resaultContactWrapperList = testController.getContacts();
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty(), msgList);

        List<Contact> testContactListForVerificationResult = new List<Contact>();
        testContactListForverificationResult.addAll(testContactWithAccountList);
        testContactListForverificationResult.addAll(testContactWithoutAccountList);

        System.assertEquals(testContactWithAccountList.size(), resaultContactWrapperList.size());
        Set<Id> resultContactWraperSetId = new Set<Id>();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            resultContactWraperSetId.add(contactWraperItem.contact.Id);
            System.assert(!contactWraperItem.selected);
        }

        System.assertEquals(new Map<Id, Contact>(testContactWithAccountList).keySet(), resultContactWraperSetId);
    }

    private static testmethod void testGetContactsWithAccount(){
        prepareDataForTest();
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     testProposalDraftList[0].Id,
                                     testContactWithAccountList,
                                     null);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList;

        Test.startTest();
            resaultContactWrapperList = testController.getContacts();
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty(), msgList);

        System.assertEquals(testContactWithAccountList.size(), resaultContactWrapperList.size());

        Set<Id> resultContactWraperSetId = new Set<Id>();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            resultContactWraperSetId.add(contactWraperItem.contact.Id);
            System.assert(!contactWraperItem.selected);
        }

        System.assertEquals(new Map<Id, Contact>(testContactWithAccountList).keySet(), resultContactWraperSetId);
    }

    private static testmethod void testGetContactsWitoutAccount(){
        prepareDataForTest();
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     testProposalDraftList[0].Id,
                                     null,
                                     testContactWithoutAccountList);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList;

        Test.startTest();
            resaultContactWrapperList = testController.getContacts();
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty(), msgList);

        System.assertEquals(testContactWithAccountList.size(), resaultContactWrapperList.size());
        Set<Id> resultContactWraperSetId = new Set<Id>();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            resultContactWraperSetId.add(contactWraperItem.contact.Id);
            System.assert(!contactWraperItem.selected);
        }

        System.assertEquals(new Map<Id, Contact>(testContactWithAccountList).keySet(), resultContactWraperSetId);
    }

    private static testmethod void testAddContactWithoutProposalDraft(){
        prepareDataForTest();
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     null,
                                     testContactWithAccountList,
                                     testContactWithoutAccountList);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList = testController.getContacts();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            contactWraperItem.selected = true;
        }

        Test.startTest();
            testController.addContact();
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals ('Please save Proposal!', msgList[0].getDetail());
    }

    private static testmethod void testAddContactWithIncorrectProposalDraft(){
        prepareDataForTest();
        Id incorrectProposalId = Id.valueOf(Proposal__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     incorrectProposalId,//incorrect Proposal Draft Id value
                                     testContactWithAccountList,
                                     testContactWithoutAccountList);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList = testController.getContacts();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            contactWraperItem.selected = true;
        }

        Test.startTest();
            testController.addContact();
        Test.stopTest();

        System.assert(String.isEmpty(testController.emailToCC));

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (!msgList.isEmpty());
        System.assertEquals ('Proposal does not exist for Id = ' + incorrectProposalId, msgList[0].getDetail());
    }

    private static testmethod void testAddContact(){
        prepareDataForTest();
        preparePageControllerForTest(testAccountList[0].Id,
                                     testAccountList[1].Id,
                                     testAccountList[2].Id,
                                     testProposalDraftList[0].Id,
                                     testContactWithAccountList,
                                     testContactWithoutAccountList);

        List<AddContactToSendCC.ContactWrapper> resaultContactWrapperList = testController.getContacts();
        for (AddContactToSendCC.ContactWrapper contactWraperItem : resaultContactWrapperList){
            contactWraperItem.selected = true;
        }

        Test.startTest();
            testController.addContact();
        Test.stopTest();

        List<ApexPages.Message> msgList = ApexPages.getMessages();
        System.assert (msgList.isEmpty(), msgList);

        testProposalDraftList = [SELECT Id, Send_Copy_To__c
                                 FROM Proposal__c
                                 WHERE Id = : testProposalDraftList[0].Id];


        System.assert(!testProposalDraftList.isEmpty());
        System.assert(!String.isEmpty(testProposalDraftList[0].Send_Copy_To__c));
        for (Contact contactItem : testContactWithAccountList){
            System.assert(testProposalDraftList[0].Send_Copy_To__c.contains(contactItem.Email), testProposalDraftList[0].Send_Copy_To__c + contactItem.Email);
        }
        System.assertEquals(testContactWithAccountList.size(), testProposalDraftList[0].Send_Copy_To__c.split('; ').size());
    }
}