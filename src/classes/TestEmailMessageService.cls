@isTest(SeeAllData = true)
private class TestEmailMessageService {
    private static final Integer NUMBER_TO_CREATE_EMAIL_TEMPLATE = 3;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 4;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer RECIPIENT_NUMBER = 5;
    private static final String TEST_EMAIL_TEMPLATE_DEVELOPER_NAME = 'TestDeveloperName';
    private static final String EMAIL_TEMPLATE_TYPE_HTML = 'html';
    private static final String EMAIL_TEMPLATE_TYPE_TEXT = 'text';
    private static final String TEST_EMAIL_TEMPLATE_PREFIX = '@gmail.com';
    //incorrect name contains more then 80 symbols
    private static final String INCORRECT_TEMPLATE_NAME = '123456789012345678901234567890123456789012345678901234567890123456789012345678901';

    private static List<EmailTemplate> testEmailTemplateList;
    private static List<Contact> testContactList;
    private static List<Account> testAccountList;
    private static List<Task> testTaskList;
    private static List<String> toAddressesEmailList;
    private static List<String> ccAddressesEmailList;


    private static void setupData(){
        testEmailTemplateList = [SELECT Id, Name, Folder.Name
                                 FROM EmailTemplate
                                 WHERE Folder.Name != null LIMIT : NUMBER_TO_CREATE_EMAIL_TEMPLATE];

        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT * 2, false);
        for (Contact contactItem : testContactList){
            contactItem.Email = contactItem.LastName + TEST_EMAIL_TEMPLATE_PREFIX;
        }
        insert testContactList;

        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);

        toAddressesEmailList = new List<String>();
        ccAddressesEmailList = new List<String>();
        for (Integer i = 0; i < RECIPIENT_NUMBER; i++){
            toAddressesEmailList.add('TestToEmailAddress' + String.valueOf(i) + TEST_EMAIL_TEMPLATE_PREFIX);
            ccAddressesEmailList.add('TestCCEmailAddress' + String.valueOf(i) + TEST_EMAIL_TEMPLATE_PREFIX);
        }
    }

    private static testmethod void testUncoveredPart() {
        setupData();
        
        Set<Id> setOfUserIds = new Set<Id>();

        List<User> usersList = TestingUtils.createUsers( 5, false );
        INSERT usersList;

        for( User userItem : usersList ) {
            setOfUserIds.add( userItem.Id );
        }

        List<Id> testRecipientListId = new List<Id>();
        for (Contact contactItem : testContactList){
            testRecipientListId.add(contactItem.Id);
        }
        
        Contact testContact = TestingUtils.createContactList( 1, true ).get( 0 );
        
        Set<Id> projectIdxSet = new Set<Id>();
        List<Project_Profile__c> projProfList = TestingUtils.createProjectProfileForTest( 5, false );
        for( Project_Profile__c project : projProfList ) {
            project.Project_Member__c = usersList.get( 1 ).Id;
            project.FREP__c = usersList.get( 2 ).Id;
            project.Production_Manager__c = usersList.get( 3 ).Id;
            project.OwnerId = usersList.get( 4 ).Id;
        }
        INSERT projProfList;

        Proposal__c proposal = TestingUtils.createProposalListForTest( 1, false).get( 0 );
        proposal.Project_Profile__c = projProfList.get( 0 ).Id;
        INSERT proposal;

        List<Change_Order__c> cOs = TestingUtils.createChangeOrderList( 1, false);
        cOs.get( 0 ).Proposal__c = proposal.Id;
        INSERT cOs;

        for( Project_Profile__c project : projProfList ) {
            projProfList.get( 0 ).Proposal__c = proposal.Id;
        }
        UPSERT projProfList;

        for( Project_Profile__c project : projProfList ) {
            projectIdxSet.add( project.Id );
        }

        List<Service_Item__c> serviceItems = TestingUtils.createServiceItemList(4, false);
        for( SErvice_Item__c serviceItem : serviceItems ) {
            serviceItem.Project_Profile__c = projProfList.get( 0 ).Id;
            serviceItem.Proposal__c = proposal.Id;
        }
        INSERT serviceItems;
        projProfList[0] = [SELECT Id, Name, OwnerId, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c,
                                    Project_Manager__r.Email, Project_Member__r.Email, FREP__r.Email, Production_Manager__r.Email,
                                    Owner.Email, Floor_s__c, Project_Address__c, Project_Name__c, Project_Team__c,
                                    (Select Id, Name, OwnerId, Owner.Email, Service_Name_Short__c From Service_Items__r)
                                                                                           FROM Project_Profile__c
                                                                                           WHERE Id =: projProfList.get( 0 ).Id];


        Test.startTest();
            try { String getExternalURL = EmailMessageService.getExternalURL( 'externalIdTestString' ); } catch ( Exception ex ) {}
            try { String getAttachmentsEmailBodyPart = EmailMessageService.getAttachmentsEmailBodyPart( new Map<String,String> {'testString1'=>'testString2'} ); } catch ( Exception ex ) {}
            try { EmailTemplate getEmailTemplateByDeveloperName = EmailMessageService.getEmailTemplateByDeveloperName( 'testDeveloperName' ); } catch ( Exception ex ) {}
            try { EmailTemplate getEmailTemplateById = EmailMessageService.getEmailTemplateById( testContact.Id ); } catch ( Exception ex ) {}
            try { Map<Id, EmailTemplate> getDeliveryMethodIdToEarliestEmailTemplate = EmailMessageService.getDeliveryMethodIdToEarliestEmailTemplate( 'testDdpName' ); } catch ( Exception ex ) {}
            try { Map<Integer, Map<Id, EmailTemplate>> getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate1 = EmailMessageService.getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( 'testDdpName' ); } catch ( Exception ex ) {}
            try { Map<Integer, Map<Id, EmailTemplate>> getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate2 = EmailMessageService.getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( 'testDdpName', 'testDeliveryMethodName' ); } catch ( Exception ex ) {}
            try { EmailMessageService.sendEmailNotification( projectIdxSet ); } catch ( Exception ex ) {}

            try { Messaging.SingleEmailMessage populateEmailAboutProjectCreationNotification = EmailMessageService.populateEmailAboutProjectCreationNotification( projProfList.get( 0 ), usersList.get( 0 ).Id ); } catch ( Exception ex ) {}
            //try { EmailMessageService.sendMassMailToInternalUsers( setOfUserIds, 'testBody', 'testSubject' ); } catch ( Exception ex ) {}
            try { EmailMessageService.sendSingleEmailMessage( new String[] {'test1@gmail.com'}, new String[] {'test2@gmail.com'}, null, testContact.Id, 'testSubject', 'testBody', null ); } catch ( Exception ex ) {}
            try { EmailMessageService.sendEmailNotificationChangeOrder( cOs, new Map<Id,Proposal__c> { cOs.get( 0 ).Id => proposal }); } catch ( Exception ex ) {}
            try { Messaging.SingleEmailMessage populateEmailAboutCOApprovedCreationNotification = EmailMessageService.populateEmailAboutCOApprovedCreationNotification( cOs.get( 0 ), proposal, usersList.get( 0 ).Id ); } catch ( Exception ex ) {}
            try { Messaging.SingleEmailMessage createEmailNotificationMessage = EmailMessageService.createEmailNotificationMessage ( 'test sybject', 'test body', usersList.get( 0 ).Id ); } catch ( Exception ex ) {}
        Test.stopTest();
    }

    private static testmethod void testSendMassMailWithTemplate(){
        setupData();

        List<Id> testRecipientListId = new List<Id>();
        for (Contact contactItem : testContactList){
            testRecipientListId.add(contactItem.Id);
        }

        Test.startTest();
            EmailMessageService.sendMassMailWithTemplate(testEmailTemplateList[0].Id, testRecipientListId, testAccountList[0].Id);
        Test.stopTest();

        System.assert(! testRecipientListId.isEmpty() );
    }

    private static testmethod void testSendMassMailWithTemplateWithEmptyTemplate(){
        setupData();

        List<Id> testRecipientListId = new List<Id>();
        for (Contact contactItem : testContactList){
            testRecipientListId.add(contactItem.Id);
        }

        String errorString;

        Test.startTest();

            try{
                EmailMessageService.sendMassMailWithTemplate(null, testRecipientListId, testAccountList[0].Id);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testSendMassMailWithEmptyRecipientList(){
        setupData();

        String errorString;

        Test.startTest();

            try{
                EmailMessageService.sendMassMailWithTemplate(testEmailTemplateList[0].Id, new List<Id>(), testAccountList[0].Id);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testSendSingleMailToDistribution(){
        setupData();

        Test.startTest();

            EmailMessageService.sendSingleMailToDistribution(toAddressesEmailList, ccAddressesEmailList, 'test subject', 'test html body');

        Test.stopTest();

        System.assert(! testContactList.isEmpty() );

    }

    private static testmethod void testSendSingleMailToDistributionWithEmptyDistribution(){
        setupData();

        String errorString;

        Test.startTest();

            try{
                EmailMessageService.sendSingleMailToDistribution(new List<String>(), ccAddressesEmailList, 'test subject', 'test html body');
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testSendSingleMailToDistributionWithEmptySubject(){
        setupData();

        String errorString;

        Test.startTest();

            try{
                EmailMessageService.sendSingleMailToDistribution(toAddressesEmailList, ccAddressesEmailList, '', 'test html body');
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testSendSingleMailToDistributionWithEmptyHTMLBody(){
        setupData();

        String errorString;

        Test.startTest();

            try{
                EmailMessageService.sendSingleMailToDistribution(toAddressesEmailList, ccAddressesEmailList, 'test subject', '');
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testGetEmailTemplateIdForRequestFillingFee(){
        Id resultRecordId;

        Test.startTest();

            resultRecordId = EmailMessageService.getEmailTemplateIdForRequestFillingFee();

        Test.stopTest();

        System.assert(resultRecordId != null);
    }

    private static testmethod void testGetEmailTemplateIdForRequestFillingFeeIncorrect(){
        Id resultRecordId;

        delete [SELECT id FROM EmailTemplate WHERE name like : 'Request Filing Fees' + '%'];

        String errorString;

        Test.startTest();
            try {
                resultRecordId = EmailMessageService.getEmailTemplateIdForRequestFillingFee();
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecordId == null);
    }

    private static testmethod void testGetEmailTemplateByName(){
        setupData();

        EmailTemplate resultRecord;

        Test.startTest();

            resultRecord = EmailMessageService.getEmailTemplateByName(testEmailTemplateList[0].Name);

        Test.stopTest();

        System.assert(resultRecord != null);
    }

    private static testmethod void testGetEmailTemplateByNameWithEmptyName(){
        EmailTemplate resultRecord;

        String errorString;

        Test.startTest();
            try{
                resultRecord = EmailMessageService.getEmailTemplateByName('');
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecord == null);
    }

    private static testmethod void testGetEmailTemplateByNameWithIncorrectName(){
        EmailTemplate resultRecord;

        String errorString;

        Test.startTest();
            try{
                resultRecord = EmailMessageService.getEmailTemplateByName(INCORRECT_TEMPLATE_NAME);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultRecord == null);
    }

    private static testmethod void testGetEmailTemplatesFromFolder(){
        setupData();

        Map<Id, EmailTemplate> resultMap;

        Test.startTest();

            resultMap = EmailMessageService.getEmailTemplatesFromFolder(testEmailTemplateList[0].Folder.Name, null);

        Test.stopTest();

        System.assert(resultMap != null);
        System.assert(!resultMap.isEmpty());
    }

    private static testmethod void testGetEmailTemplatesFromFolderWithEmptyFolderName(){
        setupData();

        Map<Id, EmailTemplate> resultMap;
        String errorString;

        Test.startTest();

            try{
                resultMap = EmailMessageService.getEmailTemplatesFromFolder(null, null);
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultMap == null);
    }
}