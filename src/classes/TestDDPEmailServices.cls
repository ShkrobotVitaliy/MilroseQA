@isTest
private class TestDDPEmailServices {
    private static final Integer NUMBER_TO_CREATE = 5;
    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 5;
    private static final Integer NUMBER_TO_CREATE_CONTACT = 5;
    private static List <Loop__DDP_Integration_Option__c> testLoopDDPIntegrationOption;
    private static List <Loop__DDP__c> testLoopDDP;
    private static List<LStore__Stored_Document__c> testStoredDocumentList;
    private static List<Account> testAccountList;
    private static List<Contact> testContactList;
    private static String DDPName;
    private static String deliveryMethod;
    private static String parentIds;
    private static String retURL;
    private static String attachments;
    private static Id targetId;
    private static Account testAccount;
    private static Contact testContact;
    private static List<Attachment> testAttachmentList;
    
    private static void initializeVariables(){
        DDPName = 'TestName';
        deliveryMethod = 'Attach';
        parentIds = 'TestParent';
        retURL = 'TestUrl';
        attachments = 'TestAttachment';
    }
    
    private static void setUp(Boolean doInsert){        
        testLoopDDP = TestingUtils.createLoopDDPList(NUMBER_TO_CREATE, false);
            testLoopDDP[0].Name = DDPName;
            insert testLoopDDP;
        testLoopDDPIntegrationOption = TestingUtils.createLoopDDPIntegrationOptionList(1, testLoopDDP[0].Id, doInsert);
            testLoopDDPIntegrationOption[0].Name = deliveryMethod;          
    }

    private static testmethod void testCreateDDPLoopPlusWithEmptyDDPName(){
        String errorString;

        Test.startTest();
            try{
                DDPEmailServices.createDDPLoopPlus('', '', null, null, '', '', '', true);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testCreateDDPLoopPlusWithEmptyDeliveryMethod(){
        initializeVariables();

        String errorString;

        Test.startTest();
            try{
                DDPEmailServices.createDDPLoopPlus(DDPName, '', null, null, '', '', '', true);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }


    private static testmethod void testCreateDDPLoopPlusWithEmptyTargetId(){
        initializeVariables();

        String errorString;

        Test.startTest();
            try{
                DDPEmailServices.createDDPLoopPlus(DDPName, deliveryMethod, null, null, '', '', '', true);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testCreateDDPLoopPlusWithEmptyDDPIntegration(){
        initializeVariables();

        String errorString;

        Test.startTest();
            try{
                DDPEmailServices.createDDPLoopPlus(DDPName, deliveryMethod, UserInfo.getUserId(), null, '', '', '', true);
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }

    private static testmethod void testCreateDDPLoopPlus(){
        initializeVariables();
        setUp(false);
        for (Loop__DDP_Integration_Option__c loopDDPIntegrationOptionItem : testLoopDDPIntegrationOption){
            loopDDPIntegrationOptionItem.Name = DDPEmailServices.DELIVERY_METHOD_EMAIL;
        }
        insert testLoopDDPIntegrationOption;

        testAccountList = TestingUtils.createAccountList(NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactList = TestingUtils.createContactList(NUMBER_TO_CREATE_CONTACT, true);
        testStoredDocumentList = TestingUtils.createLStoreStoredDocumentList(1, true);

        PageReference resultpageReference;

        Test.startTest();

            resultpageReference = DDPEmailServices.createDDPLoopPlus(DDPName, DDPEmailServices.DELIVERY_METHOD_EMAIL, testAccountList[0].Id, testContactList[0].Id, testAccountList[0].Id, 'test', testStoredDocumentList[0].Id, true);

        Test.stopTest();

        System.assert(resultpageReference != null);
    }

    private static testmethod void testGetDDPIntegrationOptionNotEmpty(){
        initializeVariables();      
        setUp(false);
            insert testLoopDDPIntegrationOption;
            
        Test.startTest();
            Loop__DDP_Integration_Option__c testgetDDPIntegrationOption = DDPEmailServices.getDDPIntegrationOption(ddpName, deliveryMethod);
        Test.stopTest();
            
        System.assertEquals(testLoopDDPIntegrationOption[0].Id, testgetDDPIntegrationOption.Id);        
    }
    
    private static testmethod void testGetDDPIntegrationOptionIsEmpty(){
        initializeVariables();
        setUp(false);
        insert testLoopDDPIntegrationOption;
        testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
        testContact = TestingUtils.createContactList(1, testAccount.Id, true)[0];
        testAttachmentList = new List<Attachment>();
        Service_Item__c testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true)[0];
        Task_Item__c testTaskItem = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, true)[0];
        List<Id> attachIdList = new List<Id>(); 
        for(Integer i = 0;i < NUMBER_TO_CREATE; i ++){
            testAttachmentList.add(new Attachment(Name = 'TestAtt' + i,Body = Blob.valueOf('TestBody') ,ParentId  = testServiceItem.Id));
        }   
            insert testAttachmentList;
        for(Attachment item : testAttachmentList){
            attachIdList.add(item.Id);
        }   
        
        System.assert(! attachIdList.isEmpty() );

        Test.startTest();
            //Loop__DDP_Integration_Option__c testgetDDPIntegrationOption = DDPEmailServices.getDDPIntegrationOption(ddpName, deliveryMethod);
            DDPEmailServices.generateAndAttachPDF( testServiceItem.Id, ddpName, testAccount.Id, testContact.Id, testTaskItem.Id, attachIdList);
        Test.stopTest();
            
        //System.assert(testgetDDPIntegrationOption != null);     
    }

    private static testmethod void testGetDDPMap(){
        initializeVariables();
        setUp(true);

        Set<String> loopDDPNameSet = new Set<String>();
        for (Loop__DDP__c loopDDPItem : [SELECT Id, Name
                                         FROM Loop__DDP__c
                                         WHERE Id IN : testLoopDDP]){
            loopDDPNameSet.add(loopDDPItem.Name);
        }

        Map<Id, Loop__DDP__c> resultLoopDDPMap;

        Test.startTest();

            resultLoopDDPMap = DDPEmailServices.getDDPMap(loopDDPNameSet);

        Test.stopTest();

        System.assert(!resultLoopDDPMap.isEmpty());
        System.assertEquals(new Map<Id, Loop__DDP__c>(testLoopDDP).keySet(), resultLoopDDPMap.keySet());
    }

    private static testmethod void testSendDDPEmail(){
        testAccount = new Account(Name = 'TestAccount');
            insert testAccount;
        testContact = TestingUtils.createContactList(1, testAccount.Id, true)[0];
        testAttachmentList = new List<Attachment>();
        Service_Item__c testServiceItem = TestingUtils.createServiceItemList(NUMBER_TO_CREATE, true)[0];
        Task_Item__c testTaskItem = TestingUtils.createTaskItemList(NUMBER_TO_CREATE, true)[0];
        List<Id> attachIdList = new List<Id>(); 
        for(Integer i = 0;i < NUMBER_TO_CREATE; i ++){
            testAttachmentList.add(new Attachment(Name = 'TestAtt' + i,Body = Blob.valueOf('TestBody') ,ParentId  = testServiceItem.Id));
        }   
            insert testAttachmentList;
        for(Attachment item : testAttachmentList){
            attachIdList.add(item.Id);
        }   
        
        initializeVariables();      
        setUp(false);
            insert testLoopDDPIntegrationOption;
        targetId = testLoopDDP[1].Id;
        
        System.assert( targetId != null);

        Test.startTest();
            DDPEmailServices.sendDDPEmail(testServiceItem.Id, ddpName, deliveryMethod, testAccount.Id, testContact.Id, testTaskItem.Id, attachIdList);
            
        Test.stopTest();
    }

    private static testmethod void testGenerateAndAttachPDFWithEmptyMainrecordId(){
        String errorString;

        Test.startTest();

            try{
                DDPEmailServices.generateAndAttachPDF(null, '', null, null, null, new List<Id>());
            } catch (Exception ex){
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
    }
}