@isTest
private class TestFormSignaturesServices {
    private static final Integer NUMBER_TO_CREATE_FORM_ITEM = 3;
    private static final List<String> TEST_FORM_SIGNATURIES_VALUES_LIST = new List<String>{'first', 'second', 'third'};

    private static List<Form_Item__c> testFormItemList;
    private static List<Form_Signature__c> testFormSignatureList;

    private static testmethod void testCreateFormSignaturesForm(){
        String formSignaturiesStringForTest = '';
        for (String stringItem : TEST_FORM_SIGNATURIES_VALUES_LIST){
            formSignaturiesStringForTest += stringItem + ';';
        }
        formSignaturiesStringForTest = formSignaturiesStringForTest.removeEnd(';');

        testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM * 2, false);

        for (Integer i = 0; i < NUMBER_TO_CREATE_FORM_ITEM; i++) {
            testFormItemList[0].Form_Signatories__c = formSignaturiesStringForTest;
        }
        insert testFormItemList;

        testFormSignatureList = [SELECT Id
                                 FROM Form_Signature__c
                                 WHERE Form_Item__c IN : testFormItemList];

        if (!testFormSignatureList.isEmpty()){
            delete testFormSignatureList;
        }

        Test.startTest();

            FormSignaturesServices.createFormSignatures(testFormItemList);

        Test.stopTest();

        List<Form_Item__c> resultFormItemWithFormSignatureList = [SELECT Id, Form_Signatories__c, Complete_Forms__c, Project__c, Service_Item__c,
                                                                        (Select Id, Task_Item__c, Project__c, Order__c, Role__c, Service_Item__c
                                                                         From Form_Signatures__r)
                                                                  FROM Form_Item__c
                                                                  WHERE Id IN : testFormItemList];

        System.assert(!resultFormItemWithFormSignatureList.isEmpty());
        System.assertEquals(testFormItemList.size(), resultFormItemWithFormSignatureList.size());
        for (Form_Item__c formItemItem : resultFormItemWithFormSignatureList){
            System.assert(!formItemItem.Form_Signatures__r.isEmpty());
            if (String.isEmpty(formItemItem.Form_Signatories__c)){
                System.assertEquals(1, formItemItem.Form_Signatures__r.size());
                for (Form_Signature__c formSignatureItem : formItemItem.Form_Signatures__r){
                    System.assertEquals(formItemItem.Complete_Forms__c, formSignatureItem.Task_Item__c);
                    System.assertEquals(formItemItem.Project__c, formSignatureItem.Project__c);
                    System.assertEquals(1, formSignatureItem.Order__c);
                }
            } else {
                System.assertEquals(TEST_FORM_SIGNATURIES_VALUES_LIST.size(), formItemItem.Form_Signatures__r.size());
                for (Form_Signature__c formSignatureItem : formItemItem.Form_Signatures__r){
                    System.assertEquals(formItemItem.Complete_Forms__c, formSignatureItem.Task_Item__c);
                    System.assertEquals(formItemItem.Project__c, formSignatureItem.Project__c);
                }
            }
        }
    }

    private static testmethod void testCreateFormSignaturesFormWithIncorrectData(){
        testFormItemList = TestingUtils.createFormItemList(NUMBER_TO_CREATE_FORM_ITEM, true);

        testFormSignatureList = [SELECT Id
                                 FROM Form_Signature__c
                                 WHERE Form_Item__c IN : testFormItemList];

        if (!testFormSignatureList.isEmpty()){
            delete testFormSignatureList;
        }

        testFormItemList[0].Project__c = Id.valueOf(Project_Profile__c.sObjectType.getDescribe().getKeyPrefix() + '000000000000');

        Test.startTest();

            FormSignaturesServices.createFormSignatures(testFormItemList);

        Test.stopTest();

        List<Form_Item__c> resultFormItemWithFormSignatureList = [SELECT Id, Form_Signatories__c, Complete_Forms__c, Project__c, Service_Item__c,
                                                                        (Select Id, Task_Item__c, Project__c, Order__c, Role__c, Service_Item__c
                                                                         From Form_Signatures__r)
                                                                  FROM Form_Item__c
                                                                  WHERE Id IN : testFormItemList];

        System.assert(!resultFormItemWithFormSignatureList.isEmpty());
        System.assertEquals(testFormItemList.size(), resultFormItemWithFormSignatureList.size());
        for (Form_Item__c formItemItem : resultFormItemWithFormSignatureList){
            System.assert(formItemItem.Form_Signatures__r.isEmpty());
        }
    }
}