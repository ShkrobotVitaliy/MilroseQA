public with sharing class SVE_F27_1_Extension {
    private final String FIRST_ROW     = '1';
    private final String SECOND_ROW    = '2';
    private final String THIRD_ROW     = '3';
    private final String FOURTH_ROW    = '4';
    private final String FIFTH_ROW     = '5';
    private final String FORM_ITEM_F28 = 'F28';
    
    private final Form_Meta_Data_Object_1__c standardRecord;
    private final String generatePDF;
    
    private Task_Item__c taskItem {
        get {
            if (null == this.taskItem) {
                this.taskItem = TaskItemServices.getTaskItemById(record.Task_Item__c);
                
            }
            return this.taskItem;
        
        }
        set;
    
    }
    
    private Service_Item__c serviceItem {
        get {
            if (null == this.serviceItem) {
                List<Service_Item__c> services = new List<Service_Item__c>([SELECT Project_Profile__c, Id, 
                                                                                   (SELECT Id FROM Task_Items__r) 
                                                                            FROM Service_Item__c
                                                                            WHERE Id =: this.record.Service_Item__c LIMIT 1]);
                
                if (!services.isEmpty()) {
                    this.serviceItem = services.get(0);
                
                }    
            
            }
            return this.serviceItem;
        
        }
        set;
    }
    
    public Form_Meta_Data_Object_1__c record {
        get {
            if (null == this.record) {
                this.record = FormMetaDataObject1Services.getFormMetaDataObject1ById(this.standardRecord.Id);
            
            }
            return this.record;
        
        }
        set;
        
    }
    
    public Boolean isGeneratePDF {
        get {
            return this.generatePDF == 'true';
        
        }
        set;
    }
    
    public SVE_F27_1_Extension(ApexPages.StandardController controller) {
        this.standardRecord = (Form_Meta_Data_Object_1__c)controller.getRecord();
        this.generatePDF    = ApexPages.currentPage().getParameters().get('generatePDF');

    }
    
    public void saveFormDataObject() {
        try {
            update this.record;
        
        } catch(Exception ex) {
            return;
        
        }
    
    }
    
    public PageReference generateFormF27_1PDF() {
        PageReference page = new PageReference('/' + this.taskItem.Id);
        page.setRedirect(true);
    
        Savepoint sp = Database.setSavepoint();
        try {
            update new Form_Item__c(Id = this.record.Form_Item__c, Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED);
            
            this.record.Version__c++; 
            saveFormDataObject();
            
            DDPRequest request = new DDPRequest();
            request.addConfiguration(this.standardRecord.Id, 'Generate From F27_1', DDPEmailServices.DELIVERY_METHOD_ATTACH, null, null, null, new List<Id>());
            request.sendRequest();
            
            createFormItemsF28();
        
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return page;
        
        }
        return page;
    
    }
    
    public PageReference generateFormF27_2PDF() {
        PageReference page = new PageReference('/' + this.taskItem.Id);
        page.setRedirect(true);
    
        Savepoint sp = Database.setSavepoint();
        try {
            update new Form_Item__c(Id = this.record.Form_Item__c, Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED);
            
            this.record.Version__c++; 
            saveFormDataObject();
            
            DDPRequest request = new DDPRequest();
            request.addConfiguration(this.standardRecord.Id, 'Generate From F27_2', DDPEmailServices.DELIVERY_METHOD_ATTACH, null, null, null, new List<Id>());
            request.sendRequest();
            
            createFormItemsF28();
        
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return page;
        
        }
        return page;
    
    }

    private void createFormItemsF28() {
        List<Form_Template__c> formTemplates = new List<Form_Template__c>([SELECT Id, Form_Name__c, Name, Subject__c, Form_Id__c, Region_Lookup__c, Consumer__c,
                                                                                  Municipality__c, Form_Type__c, Form_Signatories__c, sve_SVE_Visualforce_Page__c, 
                                                                                  (SELECT Id, Meta_Data_Field_Name__c, Milrose_Wave_Field_Name__c FROM Forms_Field_Mapping__r )
                                                                           FROM Form_Template__c
                                                                           WHERE Form_ID__c =: FORM_ITEM_F28]);
        List<Form_Item__c> formItems = new List<Form_Item__c>([SELECT Id, Form_Id__c
                                                               FROM Form_Item__c 
                                                               WHERE Service_Item__c =: this.serviceItem.Id AND Form_Id__c LIKE 'F28%']);
        
        Integer versionNumber = formItems.size();
        
        Map<String, Form_Item__c> rowNumberToFormItem = new Map<String, Form_Item__c>();
        
        if (!String.isBlank(this.record.Input_Field130__c) || !String.isBlank(this.record.input_field10__c) || !String.isBlank(this.record.Input_Field104__c) || 
            !String.isBlank(this.record.Input_Field109__c) || !String.isBlank(this.record.Input_Field113__c) || !String.isBlank(this.record.Input_Field118__c)) {                
                rowNumberToFormItem.put(FIRST_ROW, newFormItem(formTemplates.get(0), this.taskItem, this.serviceItem, versionNumber++));
        
        }
        
        if (!String.isBlank(this.record.Input_Field131__c) || !String.isBlank(this.record.Input_Field100__c) || !String.isBlank(this.record.Input_Field105__c) || 
            !String.isBlank(this.record.input_field11__c) || !String.isBlank(this.record.Input_Field114__c) || !String.isBlank(this.record.Input_Field119__c)) {
                rowNumberToFormItem.put(SECOND_ROW, newFormItem(formTemplates.get(0), this.taskItem, this.serviceItem, versionNumber++));
        
        }
        
        if (!String.isBlank(this.record.Input_Field132__c) || !String.isBlank(this.record.Input_Field101__c) || !String.isBlank(this.record.Input_Field106__c) || 
            !String.isBlank(this.record.Input_Field110__c) || !String.isBlank(this.record.Input_Field115__c) || !String.isBlank(this.record.input_field12__c)) {
                rowNumberToFormItem.put(THIRD_ROW, newFormItem(formTemplates.get(0), this.taskItem, this.serviceItem, versionNumber++));

        }
        
        if (!String.isBlank(this.record.Input_Field133__c) || !String.isBlank(this.record.Input_Field102__c) || !String.isBlank(this.record.Input_Field108__c) || 
            !String.isBlank(this.record.Input_Field111__c) || !String.isBlank(this.record.Input_Field116__c) || !String.isBlank(this.record.Input_Field120__c)) {
                rowNumberToFormItem.put(FOURTH_ROW, newFormItem(formTemplates.get(0), this.taskItem, this.serviceItem, versionNumber++));
        
        }
        
        if (!String.isBlank(this.record.Input_Field134__c) || !String.isBlank(this.record.Input_Field103__c) || !String.isBlank(this.record.Input_Field107__c) || 
            !String.isBlank(this.record.Input_Field112__c) || !String.isBlank(this.record.Input_Field117__c) || !String.isBlank(this.record.Input_Field121__c)) {
                rowNumberToFormItem.put(FIFTH_ROW, newFormItem(formTemplates.get(0), this.taskItem, this.serviceItem, versionNumber++));

        }
        FormMetaDataObject1Services.allowCreateMetaDataObjectRecords = false;
        insert rowNumberToFormItem.values();
        
        List<Form_Meta_Data_Object_1__c> formMetaDataForRow;
        List<Form_Meta_Data_Object_1__c> formMetaDataRecords = new List<Form_Meta_Data_Object_1__c>();
        
        for (String rowNumber : rowNumberToFormItem.keySet()) {
            if (null == rowNumberToFormItem.get(rowNumber).External_Form__c) {
                formMetaDataForRow = new List<Form_Meta_Data_Object_1__c>();
                
                formMetaDataForRow.addAll(FormMetaDataObject1Services.initFormMetaDataObjects(rowNumberToFormItem.get(rowNumber)));
                
                for (Form_Meta_Data_Object_1__c formData : formMetaDataForRow) {
                    if (FIRST_ROW == rowNumber) {
                        setFields(formData, this.record.Input_Field130__c, this.record.input_field10__c, this.record.Input_Field104__c, this.record.Input_Field109__c, this.record.Input_Field113__c, this.record.Input_Field118__c);
                    
                    } else if (SECOND_ROW == rowNumber) {
                        setFields(formData, this.record.Input_Field131__c, this.record.Input_Field100__c, this.record.Input_Field105__c, this.record.input_field11__c, this.record.Input_Field114__c, this.record.Input_Field119__c);
                    
                    } else if (THIRD_ROW == rowNumber) {
                        setFields(formData, this.record.Input_Field132__c, this.record.Input_Field101__c, this.record.Input_Field106__c, this.record.Input_Field110__c, this.record.Input_Field115__c, this.record.input_field12__c);
                    
                    } else if (FOURTH_ROW == rowNumber) {
                        setFields(formData, this.record.Input_Field133__c, this.record.Input_Field102__c, this.record.Input_Field108__c, this.record.Input_Field111__c, this.record.Input_Field116__c, this.record.Input_Field120__c);
                    
                    } else if (FIFTH_ROW == rowNumber) {
                        setFields(formData, this.record.Input_Field134__c, this.record.Input_Field103__c, this.record.Input_Field107__c, this.record.Input_Field112__c, this.record.Input_Field117__c, this.record.Input_Field121__c);
                    
                    }
                
                }
                
                if (!formMetaDataForRow.isEmpty()) {
                    formMetaDataRecords.addall(formMetaDataForRow);
            
                }
            }
            
        }
        insert formMetaDataRecords;

        //MRS-7545
        List<Form_Signature__c> signatories = [SELECT Id, Project_Roster__c
                                               FROM Form_Signature__c
                                               WHERE ( Form_Item__c IN : rowNumberToFormItem.values() ) OR
                                                     ( Id = : this.record.Signatory_3__c )];
        Id projectRosterId;
        for (Form_Signature__c signatory : signatories){
            if ( signatory.Id == this.record.Signatory_3__c ){
                projectRosterId = signatory.Project_Roster__c;
                break;
            }
        }

        if ( projectRosterId != null ){
            List<Form_Signature__c> signatoriesUpdate = new List<Form_Signature__c>();
            for (Form_Signature__c signatory : signatories){
                if ( signatory.Id != this.record.Signatory_3__c ){
                    signatoriesUpdate.add( new Form_Signature__c( Id = signatory.Id, Project_Roster__c = projectRosterId ) );
                }
            }
            if ( !signatoriesUpdate.isEmpty() ) update signatoriesUpdate;
        }
    }
    
    private void setFields(Form_Meta_Data_Object_1__c formData, String value1, String value2, String value3, String value4, String value5, String value6) {
        formData.Input_Field_DM11__c = value1;
        formData.Input_Field_DM12__c = value2;
        formData.Building_Floor_s__c = value3;
        formData.Input_Field_DM13__c = value5;
        formData.Input_Field_DM15__c = value6;
                        
    }
    
    private Form_Item__c newFormItem(final Form_Template__c formTemplate, final Task_Item__c taskItem, final Service_Item__c serviceItem, final Integer versionNumber) {
        String versionSuffix = '';
        
        if (0 == versionNumber) {
            versionSuffix = '';
        
        } else if (versionNumber < 10) {
            versionSuffix = '_00' + String.valueOf(versionNumber);
        
        } else if (versionNumber >= 10) {
            versionSuffix = '_0' + String.valueOf(versionNumber);
        
        }
        
        Form_Item__c formItem = new Form_Item__c(Form_Template__c            = formTemplate.Id,
                                                 Form_Name__c                = formTemplate.Form_Name__c,
                                                 Short_Form_Name__c          = formTemplate.Name,
                                                 Subject__c                  = formTemplate.Subject__c,
                                                 Form_Id__c                  = formTemplate.Form_Id__c + versionSuffix,
                                                 Region__c                   = formTemplate.Region_Lookup__c,
                                                 Consumer__c                 = formTemplate.Consumer__c,
                                                 Municipality__c             = formTemplate.Municipality__c,
                                                 Form_Type__c                = formTemplate.Form_Type__c,
                                                 Form_Signatories__c         = formTemplate.Form_Signatories__c,
                                                 sve_SVE_Visualforce_Page__c = formTemplate.sve_SVE_Visualforce_Page__c,
                                                 sve_Meta_Data_Query__c      = FormItemsServices.buildMetaDataQuery(formTemplate.Forms_Field_Mapping__r));

        if (null != taskItem) {
            formItem.Service_Item__c   = taskItem.Service_Item__c;
            formItem.Project__c        = taskItem.Project_Profile__c;
            formItem.Complete_Forms__c = taskItem.Id;
            
        } else if (null != serviceItem) {
            formItem.Service_Item__c = serviceItem.Id;
            formItem.Project__c      = serviceItem.Project_Profile__c;
            
            if (null != serviceItem.Task_Items__r && !serviceItem.Task_Items__r.isEmpty()) {
                formItem.Complete_Forms__c = serviceItem.Task_Items__r[0].Id;
            
            }
        
        }        
        return formItem;
    
    }
    
    public PageReference cancel() {
        PageReference page = new PageReference('/' + this.taskItem.Id);
        page.setRedirect(true);
        return page;
    
    }
    
    //----------------------Test Methods Start--------------------------//
    public SVE_F27_1_Extension( ) {}
    private static SVE_F27_1_Extension testExtender = new SVE_F27_1_Extension();
    
    private static List<Task_Item__c> testTaskItemList;
    private static List<Form_Meta_Data_Object_1__c> testFormMetaDataObject1List;
    private static List<Form_Item__c> testFormItemList;

    private static void prepareDataForTest(){
        testTaskItemList = TestingUtils.createTaskItemList(5, true);
        testFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();
        testFormItemList = new List<Form_Item__c>();

        String visualforcePageValue = '';
        for (Integer i = 0; i < 5; i++){
            visualforcePageValue += 'test' + String.valueOf(i) + ',';
        }

        List<Service_Item__c> serviceList = TestingUtils.createServiceItemList(1,true);
        for (Task_Item__c taskItemItem : testTaskItemList){
            Integer i = 0;
            for (Form_Item__c formItemItem : TestingUtils.createFormItemList(1, false)){
                formItemItem.Complete_Forms__c = taskItemItem.Id;
                formItemItem.Current_Page_Number__c = i++;
                formItemItem.Service_Item__c = serviceList[0].Id;
                testFormItemList.add(formItemItem);
            }
        }
        insert testFormItemList;

        for (Form_Item__c formItemItem : testFormItemList){
            Integer i = 0;
            for (Form_Meta_Data_Object_1__c formMetaDataObject1Item : TestingUtils.createFormMetaDataObject1List(1, formItemItem.Id, false)){
                formMetaDataObject1Item.Task_Item__c = formItemItem.Complete_Forms__c;
                formMetaDataObject1Item.Service_Item__c = serviceList[0].Id;
                formMetaDataObject1Item.Page_Number__c = i++;
                formMetaDataObject1Item.Version__c = 1;
                formMetaDataObject1Item.Visualforce_Page__c = visualforcePageValue;
                testFormMetaDataObject1List.add(formMetaDataObject1Item);
            }
        }
        insert testFormMetaDataObject1List;
        
        List<Form_Template__c> formTemplateList = TestingUtils.createFormTemplateList(10, 'F2', true );
    }

    private static testmethod void testInitForm(){
        prepareDataForTest();

        Test.startTest();

            testExtender.record = testFormMetaDataObject1List[0];
            Boolean isGeneratePDF = testExtender.isGeneratePDF;
            testExtender.saveFormDataObject();
            testExtender.generateFormF27_1PDF();
            testExtender.generateFormF27_2PDF();
            testExtender.setFields(testFormMetaDataObject1List[0], 'test', 'test', 'test', 'test', 'test', 'test');
            testExtender.record.Input_Field130__c = 'test';
            testExtender.record.Input_Field131__c = 'test';
            testExtender.record.Input_Field132__c = 'test';
            testExtender.record.Input_Field133__c = 'test';
            testExtender.record.Input_Field134__c = 'test';
            testExtender.createFormItemsF28();
	    testExtender.cancel();
            
        Test.stopTest();
    }
    
    private static testmethod void testInitForm1(){
    	prepareDataForTest();

        Test.startTest();
	ApexPages.currentPage().getParameters().put('generatePDF','true');
	ApexPages.StandardController testController = new ApexPages.StandardController(testFormMetaDataObject1List[0]);
	SVE_F27_1_Extension extensionController = new SVE_F27_1_Extension( testController );               
        Test.stopTest();
    }
    

    
    //----------------------Test Methods End--------------------------//

}