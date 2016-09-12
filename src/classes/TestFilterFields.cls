@isTest
private class TestFilterFields {
    private static testmethod void testFilterFields(){
        Test.startTest();
            FilterFields filter = new FilterFields();
            system.assertEquals(true, filter.isFilterEmpty);
        
            FilterFields testFilterFields = new FilterFields();
            testFilterFields.projectNamber = null;
            testFilterFields.address = null;
            testFilterFields.serviceItemNumber = null;
            testFilterFields.createdByName = null;
            testFilterFields.proposalDraftNumber = null;
            testFilterFields.taskItemNumber = null;
            testFilterFields.typeObjectKeyPrefix = null;
            testFilterFields.artifactsCategory = null;
            testFilterFields.purcaseOrder = null;
            testFilterFields.projectName = null;
            testFilterFields.municipalFormTypeName = null;
            testFilterFields.municipalAgencyId = null;
            testFilterFields.formNamber = null;
            testFilterFields.longName = null;
            testFilterFields.shortName = null;
            testFilterFields.formRegion = null;
            testFilterFields.changeOrderNumber = null;
            testFilterFields.municipalDescription = null;

            system.assertEquals('', testFilterFields.projectNamber, '');
            system.assertEquals('', testFilterFields.address, '');
            system.assertEquals('', testFilterFields.serviceItemNumber, '');
            system.assertEquals('', testFilterFields.createdByName, '');
            system.assertEquals('', testFilterFields.createdByName, '');
            system.assertEquals('', testFilterFields.proposalDraftNumber, '');
            system.assertEquals('', testFilterFields.taskItemNumber, '');
            system.assertEquals('', testFilterFields.typeObjectKeyPrefix, '');
            system.assertEquals('', testFilterFields.artifactsCategory, '');
            system.assertEquals('', testFilterFields.purcaseOrder, '');
            system.assertEquals('', testFilterFields.projectName, '');
            system.assertEquals('', testFilterFields.municipalFormTypeName, '');
            system.assertEquals('', testFilterFields.municipalAgencyId, '');
            system.assertEquals('', testFilterFields.formNamber, '');
            system.assertEquals('', testFilterFields.shortName, '');
            system.assertEquals('', testFilterFields.formRegion, '');
            system.assertEquals('', testFilterFields.changeOrderNumber, '');
            system.assertEquals('', testFilterFields.changeOrderNumber, '');
            system.assertEquals('', testFilterFields.longName, '');
            system.assertEquals('', testFilterFields.municipalDescription, '');
        Test.stopTest();
    }
}