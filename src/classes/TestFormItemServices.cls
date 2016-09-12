@isTest
private class TestFormItemServices {
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_TEMPLATE = 5;
    private static final Integer NUMBER_TO_CREATE_TASK_ITEM = 3;
    private static final Integer NUMBER_TO_CREATE_FORM_ASSIGNMENT = 4;
    private static final Integer NUMBER_TO_CREATE_SERVICE_ITEM = 2;
    private static final Integer NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT = 2;
    private static final Integer NUMBER_TO_CREATE_FORM_SIGNATURE = 4;
    private static final Integer NUMBER_TO_CREATE_FORM_META_DATA_OBJECT_1 = 3;
    private static final String SEPARATOR_FOR_FORM_ID = '; ';
    private static final String TEST_URL_VALUE = 'www.google.com';
    private static final String TASK_ITEM_COMPLETE_FORMS_NAME = 'Complete Forms';

    private static List<Form_Item__c> testFormItemList;
    private static List<Form_Meta_Data_Object_1__c> testFormMetaDataObject1List;
    private static List<Form_Signature__c> testFormSignatList;
    private static List<Form_Template__c> testFormTemplateList;
    private static List<Task_Item__c> testTaskItemList;
    private static List<Form_Assignment__c> testFormAssignmentList;
    private static List<Service_Item__c> testServiceItemList;
    private static List<LStore__Stored_Document__c> testLStoreStoredDocumentList;

    private static testmethod void testFilteredFormItemsByStatusAndChangeCurrentTask(){
        List<Task_Item__c> successorTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM * 2, true);
        testTaskItemList = new List<Task_Item__c>();
        for (Task_Item__c taskItemSuccessorItem : successorTaskItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(1, false)){
                taskItemItem.Successor_Task__c = taskItemSuccessorItem.Id;
                taskItemItem.Name = TaskItemServices.COMPLETE_FORMS_TASK_NAME;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;
        testFormItemList = new List<Form_Item__c>();
        Map<Id, List<Form_Item__c>> taskItemWithFormItem = new Map<Id, List<Form_Item__c>>();
        for (Task_Item__c taskItemItem : testTaskItemList){
            taskItemWithFormItem.put(taskItemItem.Id, new List<Form_Item__c>());
            for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
                formItemItem.Complete_Forms__c = taskItemItem.Id;
                testFormItemList.add(formItemItem);
                taskItemWithFormItem.get(taskItemItem.Id).add(formItemItem);
            }
        }
        insert testFormItemList;

        Map<Id, Form_Item__c> testFormItemOldMap = new Map<Id, Form_Item__c> ( [SELECT Id, Complete_Forms__c, Current_Task_Successor__c,
                                                                                        Complete_Forms__r.Successor_Task__c, Sent_Form_Status_Formula__c
                                                                                FROM Form_Item__c
                                                                                WHERE Id IN : testFormItemList] );

        testFormAssignmentList = new List<Form_Assignment__c>();

        for (Integer i = 0; i < NUMBER_TO_CREATE_TASK_ITEM; i++){
            for (Form_Item__c formItemItem : taskItemWithFormItem.get(testTaskItemList[i].Id)){
                for (Form_Assignment__c formAssignmentItem : TestingUtils.createFormAssignmentList (NUMBER_TO_CREATE_FORM_ASSIGNMENT,
                                                                                                    new List<Form_Item__c>{formItemItem},
                                                                                                    false)){
                    formAssignmentItem.Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;
                    testFormAssignmentList.add(formAssignmentItem);
                }
            }
        }

        for (Integer i = NUMBER_TO_CREATE_TASK_ITEM; i < NUMBER_TO_CREATE_TASK_ITEM * 2; i++){
            for (Form_Item__c formItemItem : taskItemWithFormItem.get(testTaskItemList[i].Id)){
                for (Form_Assignment__c formAssignmentItem : TestingUtils.createFormAssignmentList (NUMBER_TO_CREATE_FORM_ASSIGNMENT,
                                                                                                    new List<Form_Item__c>{formItemItem},
                                                                                                    false)){
                    formAssignmentItem.Status__c = FormItemsServices.FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED;
                    testFormAssignmentList.add(formAssignmentItem);
                }
            }
        }
        insert testFormAssignmentList;

        System.assert(! testFormAssignmentList.isEmpty() );

        testFormItemList = [SELECT Id, Complete_Forms__c, Current_Task_Successor__c, Complete_Forms__r.Successor_Task__c,
                                    Sent_Form_Status_Formula__c
                            FROM Form_Item__c
                            WHERE Id IN : testFormItemList];

        for (Form_Item__c formItemItem : testFormItemList){
            formItemItem.Complete_Forms__c = null;
        }

        Test.startTest();
            FormItemsServices.filteredFormItemsByStatusAndChangeCurrentTask(testFormItemList, testFormItemOldMap);
        Test.stopTest();

        for (Form_Item__c formItemItem : testFormItemList){
            //System.assertEquals(formItemItem.Complete_Forms__r.Successor_Task__c, formItemItem.Complete_Forms__c);
        }

        System.assert(! testFormItemList.isEmpty());
    }

    private static testmethod void testCreateFormItemsAfterTaskInsert(){
        testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, true);
        testFormTemplateList = [SELECT Id, Form_ID__c
                                FROM Form_Template__c
                                WHERE Id IN : testFormTemplateList];

        String formTemplateFormId = '';

        for (Form_Template__c formTemplateItem : testFormTemplateList){
            formTemplateFormId += formTemplateItem.Form_ID__c + SEPARATOR_FOR_FORM_ID;
        }
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Forms__c = formTemplateFormId;
            serviceItemItem.External_Forms__c = TEST_URL_VALUE;
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Name = TaskItemServices.COMPLETE_FORMS_TASK_NAME;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Forms_Formula__c, Service_Item__c, Project_Profile__c, External_Form__c, Name
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        delete [SELECT Id FROM Form_Item__c WHERE Complete_Forms__c IN : testTaskItemList];

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        System.assert(testFormItemList.isEmpty());

        Test.startTest();

            FormItemsServices.createFormItemsAfterTaskInsert(testTaskItemList);

        Test.stopTest();

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        System.assert(!testFormItemList.isEmpty());
        //System.assertEquals((NUMBER_TO_CREATE_FORM_TEMPLATE +1) * NUMBER_TO_CREATE_SERVICE_ITEM * NUMBER_TO_CREATE_TASK_ITEM, testFormItemList.size());
    }

    private static testmethod void testCreateFormItemsAfterTaskInsertWithIncorrectData(){
        testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, true);
        testFormTemplateList = [SELECT Id, Form_ID__c
                                FROM Form_Template__c
                                WHERE Id IN : testFormTemplateList];

        String formTemplateFormId = '';

        for (Form_Template__c formTemplateItem : testFormTemplateList){
            formTemplateFormId += formTemplateItem.Form_ID__c + SEPARATOR_FOR_FORM_ID;
        }
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Forms__c = formTemplateFormId;
            serviceItemItem.External_Forms__c = TEST_URL_VALUE;
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Name = TaskItemServices.COMPLETE_FORMS_TASK_NAME;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Forms_Formula__c, Service_Item__c, Project_Profile__c, External_Form__c, Name
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        delete [SELECT Id FROM Form_Item__c WHERE Complete_Forms__c IN : testTaskItemList];

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        System.assert(testFormItemList.isEmpty());

        Id incorrectProjectProfileId = Id.valueOf(Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        testTaskItemList[0].Project_Profile__c = incorrectProjectProfileId;

        Test.startTest();

            FormItemsServices.createFormItemsAfterTaskInsert(testTaskItemList);

        Test.stopTest();

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        System.assert(testFormItemList.isEmpty());
    }

    private static testmethod void testCreateFormItems(){
        testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, true);
        testFormTemplateList = [SELECT Id, Form_ID__c
                                FROM Form_Template__c
                                WHERE Id IN : testFormTemplateList];

        String formTemplateFormId = '';

        for (Form_Template__c formTemplateItem : testFormTemplateList){
            formTemplateFormId += formTemplateItem.Form_ID__c + SEPARATOR_FOR_FORM_ID;
        }
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, false);
        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Forms__c = null;//formTemplateFormId;
            serviceItemItem.External_Forms__c = null;//TEST_URL_VALUE;
        }
        insert testServiceItemList;

        testTaskItemList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            for (Task_Item__c taskItemItem : TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false)){
                taskItemItem.Service_Item__c = serviceItemItem.Id;
                taskItemItem.Name = TASK_ITEM_COMPLETE_FORMS_NAME;
                testTaskItemList.add(taskItemItem);
            }
        }
        insert testTaskItemList;

        testTaskItemList = [SELECT Id, Forms_Formula__c, Service_Item__c, Project_Profile__c, External_Form__c
                            FROM Task_Item__c
                            WHERE Id IN : testTaskItemList];

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Service_Item__c IN : testServiceItemList];

        System.assert(testFormItemList.isEmpty());

        for (Service_Item__c serviceItemItem : testServiceItemList){
            serviceItemItem.Forms__c = formTemplateFormId;
            serviceItemItem.External_Forms__c = TEST_URL_VALUE;
        }

        Test.startTest();

            FormItemsServices.createFormItems(testServiceItemList);

        Test.stopTest();

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Service_Item__c IN : testServiceItemList];

        System.assert(!testFormItemList.isEmpty());
        System.assertEquals(NUMBER_TO_CREATE_FORM_TEMPLATE * NUMBER_TO_CREATE_SERVICE_ITEM, testFormItemList.size());
    }

    private static testmethod void testInsertNewFormItems(){
        testFormTemplateList = TestingUtils.createFormTemplateList(NUMBER_TO_CREATE_FORM_TEMPLATE, null, true);

        testTaskItemList = TestingUtils.createTaskItemList(NUMBER_TO_CREATE_TASK_ITEM, false);

        testFormItemList = [SELECT Id
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        System.assert(testFormItemList.isEmpty());

        Test.startTest();

            FormItemsServices.insertNewFormItems(testFormTemplateList, testTaskItemList[0]);

        Test.stopTest();

        testFormItemList = [SELECT Id, Complete_Forms__c, Form_Template__c
                            FROM Form_Item__c
                            WHERE Complete_Forms__c IN : testTaskItemList];

        Set<Id> resultFormTemplateSetId = new Set<Id>();

        System.assert(!testFormItemList.isEmpty());
        System.assertEquals(testFormTemplateList.size(), testFormItemList.size());
        for (Form_Item__c formItemItem : testFormItemList){
            System.assertEquals(testTaskItemList[0].Id, formItemItem.Complete_Forms__c);
            System.assert(formItemItem.Form_Template__c != null);
            resultFormTemplateSetId.add(formItemItem.Form_Template__c);
        }
        System.assertEquals(new Map<Id, Form_Template__c>(testFormTemplateList).keySet(), resultFormTemplateSetId);
    }

    private static testmethod void testAttachStoredDocumentToFormItem(){
        testServiceItemList = TestingUtils.createServiceItemList(NUMBER_TO_CREATE_SERVICE_ITEM, true);

        testLStoreStoredDocumentList = new List<LStore__Stored_Document__c>();
        for (Service_Item__c serviceItemItem : testServiceItemList){
            Integer i = 0;
            for (LStore__Stored_Document__c lStoreStoredDocumentItem : TestingUtils.createLStoreStoredDocumentList (NUMBER_TO_CREATE_LSTORE_STORED_DOCUMENT, false)){
                lStoreStoredDocumentItem.LStore__Related_Object_Id__c = serviceItemItem.Id;
                lStoreStoredDocumentItem.RecordTypeId = StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID;
                lStoreStoredDocumentItem.LStore__File_Name__c = serviceItemItem.Id + String.valueOf(i);
                testLStoreStoredDocumentList.add(lStoreStoredDocumentItem);
            }
        }
        insert testLStoreStoredDocumentList;

        testFormItemList = new List<Form_Item__c>();
        for (LStore__Stored_Document__c lStoreStoredDocumentItem : testLStoreStoredDocumentList){
            for (Form_Item__c formItemItem : TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, false)){
                formItemItem.Service_Item__c = Id.valueOf(lStoreStoredDocumentItem.LStore__Related_Object_Id__c);
                formItemItem.Short_Form_Name__c = lStoreStoredDocumentItem.LStore__File_Name__c;
                formItemItem.Form_Id__c = lStoreStoredDocumentItem.LStore__File_Name__c;
                testFormItemList.add(formItemItem);
            }
        }
        insert testFormItemList;

        Test.startTest();
            FormItemsServices.attachStoredDocumentToFormItem(testLStoreStoredDocumentList);
        Test.stopTest();

        testFormItemList = [SELECT Id, Stored_Document__c, Short_Form_Name__c, Service_Item__c, Form_Id__c
                            FROM Form_Item__c
                            WHERE Id IN : testFormItemList];

        for (Form_Item__c formItemItem : testFormItemList){
            System.assert(formItemItem.Stored_Document__c != null);
        }
    }

    private static testmethod void testGetFormItemsByFormIds(){
        testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

        Map<Id, Form_Item__c> resultFormItemMap;

        Test.startTest();

            resultFormItemMap = FormItemsServices.getFormItemsByFormIds(new Map<Id, Form_Item__c>(testFormItemList).keySet());

        Test.stopTest();

        System.assert(!resultFormItemMap.isEmpty());
        System.assertEquals(testFormItemList.size(), resultFormItemMap.size());
        System.assertEquals(new Map<Id, Form_Item__c>(testFormItemList).keySet(), resultFormItemMap.keySet());
    }

    private static testmethod void testGetFormItemsByFormIdsWithEmptyIds(){
        testFormItemList = new List<Form_Item__c>();

        Map<Id, Form_Item__c> resultFormItemMap;

        String errorString;

        Test.startTest();
            try {
                resultFormItemMap = FormItemsServices.getFormItemsByFormIds(new Map<Id, Form_Item__c>(testFormItemList).keySet());
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        System.assert(!String.isEmpty(errorString));
        System.assert(resultFormItemMap == null || resultFormItemMap.isEmpty());
    }

    private static testmethod void testGetFormItemsByFormIdsWithIncorrectFormItemIds(){
        Map<Id, Form_Item__c> resultFormItemMap;

        String errorString;

        Test.startTest();
            try {
                resultFormItemMap = FormItemsServices.getFormItemsByFormIds(new Set<Id>{UserInfo.getUserId()});
            } catch (Exception ex) {
                errorString = ex.getMessage();
            }

        Test.stopTest();

        //System.assert(!String.isEmpty(errorString));
        //System.assert(resultFormItemMap == null || resultFormItemMap.isEmpty());
    }

    private static testmethod void testInitialPreparationFormMetaDataObject(){
        testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

        testFormSignatList = new List<Form_Signature__c>();
        for (Form_Item__c formItemItem : testFormItemList){
            for (Form_Signature__c formSignatureItem : TestingUtils.createFormSignatureList(NUMBER_TO_CREATE_FORM_SIGNATURE, formItemItem.Id, false)){
                testFormSignatList.add(formSignatureItem);
            }
        }
        insert testFormSignatList;

        testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
        for (Form_Item__c formItemItem : testFormItemList){
            integer pageNumber = 1;
            for (Form_Meta_Data_Object_1__c FormMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(1, formItemItem.Id, false)){
                FormMetaDataObject1Item.Page_Number__c = pageNumber++;
                testFormMetaDataObject1List.add(FormMetaDataObject1Item);
            }
        }
        insert testFormMetaDataObject1List;

        List<Form_Meta_Data_Object_1__c> resultFormMetaDataList;

        Test.startTest();

            resultFormMetaDataList = FormItemsServices.initialPreparationFormMetaDataObject(testFormItemList[0]);

        Test.stopTest();

        System.assert(! resultFormMetaDataList.isEmpty() );
    }
}