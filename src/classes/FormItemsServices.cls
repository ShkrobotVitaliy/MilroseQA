public with sharing class FormItemsServices {
    public static final String FORM_ITEM_EXTERNAL_FORM                = 'External Form';
    public static final String FORM_ITEM_STATUS_GENERATED             = 'Generated';
    public static final String FORM_ITEM_STATUS_STARTED               = 'Started';
    public static final String FORM_ITEM_STATUS_NOT_STARTED           = 'Not Started';
    public static final String FORM_ITEM_STATUS_SENT                  = 'Sent';
    public static final String FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED = 'Received & Verified';
    public static final String FORM_ITEM_TYPE_FORM                    = 'Form';
    public static final String FORM_ITEM_EMAIL_TEMPLATE_NAME          = 'Form Item Template';
    public static final String FORM_ITEM_EMAIL_TEMPLATE_DRAFT_NAME    = 'Form Item Template Draft';

    public static void filteredFormItemsByStatusAndChangeCurrentTask ( List<Form_Item__c> formItemListNew, Map<Id, Form_Item__c> formItemMapOld ){
        for( Form_Item__c formItem: formItemListNew ){
            if( formItem.Form_Status__c == FORM_ITEM_STATUS_GENERATED && formItemMapOld.get(formItem.Id).Form_Status__c  != FORM_ITEM_STATUS_GENERATED &&
                formItem.Currently_Active_Task_Name__c == TaskItemServices.COMPLETE_FORMS_TASK_NAME ) {
                formItem.Complete_Forms__c = formItem.Current_Task_Successor__c;
            }
            if( formItem.Form_Status__c == FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED && formItemMapOld.get(formItem.Id).Form_Status__c  != FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED &&
                formItem.Currently_Active_Task_Name__c == TaskItemServices.SEND_FORMS_TASK_NAME  ){
                formItem.Complete_Forms__c = formItem.Current_Task_Successor__c;
            }
        }
    }

    public static List<Form_Item__c> filteredFormItemsIdsWithFilledOutStatusChangedTo ( List<Form_Item__c> formItemListNew, Map<Id, Form_Item__c> formItemMapOld ){
        List<Form_Item__c> formItems = new List<Form_Item__c>();
        for( Form_Item__c formItem: formItemListNew ){
            if( formItemMapOld != null && (formItem.Form_Status__c == FormItemsServices.FORM_ITEM_STATUS_GENERATED &&
                    formItemMapOld.get(formItem.Id).Form_Status__c  != FormItemsServices.FORM_ITEM_STATUS_GENERATED) ){
                formItems.add( formItem );
            }
        }
        return formItems;
    }

    @future(callout=true)
    public static void createFormItemsAfterTaskInsertFuture( String serializedTaskIltemsList ){
        List<Task_Item__c> allTaskItemListNew = (List<Task_Item__c>)JSON.deserialize(serializedTaskIltemsList, List<Task_Item__c>.class);  
        createFormItemsAfterTaskInsert( TaskItemServices.filterCompleteFormsTaskItems( allTaskItemListNew ) );
    }

    public static void createFormItemsAfterTaskInsert( List<Task_Item__c> allTaskItemListNew ){
        List<Task_Item__c> taskItemListNew = TaskItemServices.filterCompleteFormsTaskItems(allTaskItemListNew);

        if ( taskItemListNew == null || taskItemListNew.isEmpty() ) return;
        List<Form_Item__c> formItemsListForInsert = new List<Form_Item__c>();
        Map<Id, List<Form_Meta_Data_Object_1__c>> formIdToFormMetaDataObject = new Map<Id, List<Form_Meta_Data_Object_1__c>>();
        Set<String> allFormsSet = new Set<String>();
        Map<Id, List<String>> idTaskItemToListFormsIds = new Map<Id, List<String>>();
        for( Task_Item__c taskItem: taskItemListNew ){
            List<String> formsIds = new List<String>();
            if( taskItem.Forms_Formula__c == null ) continue;
            for( String item: taskItem.Forms_Formula__c.split(';',1000)){
                formsIds.add(item.trim());
                allFormsSet.add(item.trim());
            }
            idTaskItemToListFormsIds.put(taskItem.Id, formsIds);
        }

        if( allFormsSet.isEmpty() ) return;

        Map<String, Form_Template__c> formIdToFormTemplateMap = FormTemplatesServices.getFormTemplatesByFormId( allFormsSet );
        Map<Id, String> formIdToFormFieldMappingQuery = new Map<Id, String>();

        if ( formIdToFormTemplateMap == null || formIdToFormTemplateMap.isEmpty() ) return;

        for( Task_Item__c taskItem: taskItemListNew ){
            if( taskItem.External_Form__c != null ){
                Form_Item__c formItem = new Form_Item__c( Project__c = taskItem.Project_Profile__c,
                                                          Subject__c = FORM_ITEM_EXTERNAL_FORM, 
                                                          Form_Type__c = FORM_ITEM_TYPE_FORM,
                                                          Service_Item__c = taskItem.Service_Item__c, 
                                                          Form_Name__c = taskItem.External_Form__c, 
                                                          External_Form__c = taskItem.External_Form__c );
                formItemsListForInsert.add(formItem);
            }
            if( idTaskItemToListFormsIds.get( taskItem.Id ) != null ) {
                for( String itemString: idTaskItemToListFormsIds.get(taskItem.Id) ) {
                    Form_Template__c formTemplate = formIdToFormTemplateMap.get( itemString.toUpperCase() );
                    if ( formTemplate == null ) continue;

                    formItemsListForInsert.add( initFormItem( formTemplate, null, taskItem ) );
                }
            }
        }

        try{
            insert formItemsListForInsert;
        }catch( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Form_Item__c formItem = formItemsListForInsert[dmlEx.getDmlIndex(i)];
                for (Task_Item__c taskItem : taskItemListNew){
                    if( formItem.Complete_Forms__c == taskItem.Id ){
                        taskItem.addError('Can not insert Form Item.' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static void createFormItems( List<Service_Item__c> serviceItemListNew ){
        if ( serviceItemListNew == null || serviceItemListNew.isEmpty() ) return;

        List<Form_Item__c> formItemsListForInsert = new List<Form_Item__c>();
        Map<String, List<Form_Meta_Data_Object_1__c>> formNameToFormMetaDataObject = new Map<String, List<Form_Meta_Data_Object_1__c>>();
        Set<String> allFormsSet = new Set<String>();
        Map<Id, List<String>> idServiceItemToListFormsIds = new Map<Id, List<String>>();
        for( Service_Item__c serviceItem: serviceItemListNew ){
            List<String> formsIds = new List<String>();
            for( String item: serviceItem.Forms__c.split(';',1000)){
                formsIds.add(item.trim());
                allFormsSet.add(item.trim());
            }
            idServiceItemToListFormsIds.put(serviceItem.Id, formsIds);
        }

        Map<String, Form_Template__c> formIdToFormTemplateMap = FormTemplatesServices.getFormTemplatesByFormId( allFormsSet );

        if ( formIdToFormTemplateMap == null || formIdToFormTemplateMap.isEmpty() ) return;
        for( Service_Item__c serviceItem: [ Select Id, Name, Project_Profile__c, 
                                            ( Select Id, Name From Task_Items__r 
                                              Where Name =: TaskItemServices.COMPLETE_FORMS_TASK_NAME 
                                              ORDER BY Sequence_Number__c limit 1 )
                                            From Service_Item__c Where Id IN: serviceItemListNew ] ){

            for( String itemString: idServiceItemToListFormsIds.get(serviceItem.Id) ){
                Form_Template__c formTemplate = formIdToFormTemplateMap.get(itemString);
                if ( formTemplate == null ) continue;
                formItemsListForInsert.add( initFormItem( formTemplate, serviceItem, null ) );
            }
        }

        try{
            insert formItemsListForInsert;
        }catch( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Form_Item__c formItem = formItemsListForInsert[dmlEx.getDmlIndex(i)];
                for (Service_Item__c serviceItem : serviceItemListNew){
                    if( formItem.Service_Item__c == serviceItem.Id ){
                        serviceItem.addError('Can not insert Form Item.' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static void insertNewFormItems( List<Form_Template__c> formTemplatesList, Task_Item__c taskItem ){

        List<Form_Item__c> formItemsListForInsert = new List<Form_Item__c>();
        Map<String, List<Form_Meta_Data_Object_1__c>> formNameToFormMetaDataObject = new Map<String, List<Form_Meta_Data_Object_1__c>>();
        
        for( Form_Template__c formTemplate: formTemplatesList ){
            formItemsListForInsert.add( initFormItem( formTemplate, null, taskItem ) );
        }

        if( !formItemsListForInsert.isEmpty() ) {
            insert formItemsListForInsert;
        }
    }

    public static void attachStoredDocumentToFormItem( List<LStore__Stored_Document__c> storedDocumentList ){
        if( storedDocumentList.isEmpty() ) return;

        Map<String, Id> docNameToDocId = new Map<String, Id>();
        Map<Id, List<String>> idServiceItemToDocumentsNamesList = new Map<Id, List<String>>();
        List<Form_Item__c> formItemList = new List<Form_Item__c>();

        for( LStore__Stored_Document__c itemDoc: storedDocumentList ){
            docNameToDocId.put( itemDoc.LStore__File_Name__c.substringBefore(' '), itemDoc.Id );

            if( !idServiceItemToDocumentsNamesList.containsKey(itemDoc.LStore__Related_Object_Id__c) ){
                idServiceItemToDocumentsNamesList.put( Id.valueOf(itemDoc.LStore__Related_Object_Id__c), new List<String>{itemDoc.LStore__File_Name__c} );
            } else {
                idServiceItemToDocumentsNamesList.get( Id.valueOf(itemDoc.LStore__Related_Object_Id__c) ).add(itemDoc.LStore__File_Name__c);
            }
        }

        for( Form_Item__c formItem: [ Select Id, Stored_Document__c, Short_Form_Name__c, Service_Item__c, Form_Id__c
                                      From Form_Item__c
                                      Where Service_Item__c IN: idServiceItemToDocumentsNamesList.keySet() AND
                                            Short_Form_Name__c != null AND Form_Id__c != null] ) {
             if( idServiceItemToDocumentsNamesList.get( formItem.Service_Item__c ) != null ){
                for( String item: idServiceItemToDocumentsNamesList.get( formItem.Service_Item__c ) ){
                    if( formItem.Stored_Document__c == null &&
                        item.contains(formItem.Short_Form_Name__c) && item.contains(formItem.Form_Id__c) ) {
                        formItem.Stored_Document__c = docNameToDocId.get(formItem.Short_Form_Name__c);
                    }
                    formItemList.add(formItem);
                    break;
                }
            }
        }
        if( formItemList != null && !formItemList.isEmpty() ) {
            update formItemList;
        }
    }

    public static Map<Id, Form_Item__c> getFormItemsByFormIds(final Set<Id> formIds) {
        if (formIds.isEmpty()) {
            throw new ErrorException('Set of Ids cannot be empty!');
        
        }

        return new Map<Id, Form_Item__c>([SELECT Recipient_Role__r.Name__c, Recipient_Role__r.Email__c, Recipient_Role__c, Recipient_Name__c, Id, Form_Name__c, Form_Id__c,
                                                (SELECT Recipient_Role__c, Recipient_Name__c, Recipient_Email__c, Status__c, Sent_Date__c, Recipient_Role__r.Contact__c
                                                 FROM Form_Assignments__r
                                                 WHERE Recipient_Role__c != '' AND Sent_Date__c =: null)
                                            FROM Form_Item__c
                                            WHERE Id IN : formIds]);

    }

    public static List<Form_Meta_Data_Object_1__c> initialPreparationFormMetaDataObject( Form_Item__c formItem ) {
        List<Form_Meta_Data_Object_1__c> fmdoRecords = [ Select Id, Form_Item__c, Page_Number__c, Visualforce_Page__c From Form_Meta_Data_Object_1__c 
                                                           Where Form_Item__c =:formItem.Id Order By Page_Number__c ];

        for( Form_Meta_Data_Object_1__c metadataObject : fmdoRecords ){
            metadataObject.Building__c = formItem.Project__r.Building__c;
            metadataObject.Building_Project_No__c = formItem.Project__r.Name;//formItem.Building_Project_No__c;
            metadataObject.Building_Borough__c = formItem.Borough__c;
            metadataObject.Building_MRC__c = formItem.Building_MRC__c;
            if(metadataObject.Visualforce_Page__c == 'SVE_F75_2'){
                metadataObject.TEXT_Area_LONG__c = '!';
            }
            if(metadataObject.Visualforce_Page__c == 'SVE_F30_2'){
                metadataObject.TEXT_Area_LONG__c = '!';
                metadataObject.TEXT_Area_LONG_10__c = '!';
                metadataObject.TEXT_Area_LONG_2__c = '!';
                metadataObject.TEXT_Area_LONG_3__c = '!';
                metadataObject.TEXT_Area_LONG_4__c = '!';
                metadataObject.TEXT_Area_LONG_5__c = '!';
            }
            if(metadataObject.Visualforce_Page__c == 'SVE_F80_2'){
                metadataObject.TEXT_Area_LONG__c = '!';
            }
            updateSignatories( metadataObject, formItem.Form_Signatures__r );

            for( Form_Meta_Data_Object_1__c updPageRec : fmdoRecords ){
                updPageRec.put('Page_' + metadataObject.Page_Number__c + '_ID__c', metadataObject.Id );
            }
        }
        return fmdoRecords;
    }

    public static void updateSignatories( Form_Meta_Data_Object_1__c metadataObject, List<Form_Signature__c> signatories ){
        for( Form_Signature__c signator : signatories ) {
            if( signator.Order__c > 0 && signator.Order__c <= 6 ) {
                metadataObject.put( 'Signatory_' + signator.Order__c + '__c', signator.Id );
            }
        }
    }

    private static Form_Item__c initFormItem(Form_Template__c formTemplate, Service_Item__c serviceItem, Task_Item__c taskItem) {
            Form_Item__c formItem = new Form_Item__c();

            formItem.Form_Template__c            = formTemplate.Id;
            formItem.Form_Name__c                = formTemplate.Form_Name__c;
            formItem.Short_Form_Name__c          = formTemplate.Name;
            formItem.Subject__c                  = formTemplate.Subject__c;
            formItem.Form_Id__c                  = formTemplate.Form_Id__c;
            formItem.Region__c                   = formTemplate.Region_Lookup__c;
            formItem.Consumer__c                 = formTemplate.Consumer__c;
            formItem.Municipality__c             = formTemplate.Municipality__c;
            formItem.Form_Type__c                = formTemplate.Form_Type__c;
            formItem.Form_Signatories__c         = formTemplate.Form_Signatories__c;
            formItem.sve_SVE_Visualforce_Page__c = formTemplate.sve_SVE_Visualforce_Page__c;
            formItem.sve_Meta_Data_Query__c      = buildMetaDataQuery( formTemplate.Forms_Field_Mapping__r );
            
            if (null != taskItem) {
                formItem.Service_Item__c   = taskItem.Service_Item__c;
                formItem.Project__c        = taskItem.Project_Profile__c;
                formItem.Complete_Forms__c = taskItem.Id;
            
            } else if (null != serviceItem) {
                formItem.Service_Item__c = serviceItem.Id;
                formItem.Project__c      = serviceItem.Project_Profile__c;
                
                if (null != serviceItem.Task_Items__r&& !serviceItem.Task_Items__r.isEmpty() ) {
                    formItem.Complete_Forms__c = serviceItem.Task_Items__r[0].Id;
                
                }
            
            }
            return formItem;
    
    }

    private static Form_Meta_Data_Object_1__c initFormMetaDataObject(Form_Template__c formTemplate, Id serviceItemId, Id taskItemId) {
        if (null == formTemplate) {
            return new Form_Meta_Data_Object_1__c();
        
        }
        return new Form_Meta_Data_Object_1__c(Form_PDF_Name__c    = formTemplate.Name + '_' + formTemplate.Form_Id__c,
                                              Visualforce_Page__c = formTemplate.sve_SVE_Visualforce_Page__c,
                                              Service_Item__c     = serviceItemId,
                                              Task_Item__c        = taskItemId,
                                              Version__c          = -1,
                                              Form_Short_Name__c  = formTemplate.Name);
        
    }

    private static List<Form_Meta_Data_Object_1__c> initFormMetaDataObjects(Form_Template__c formTemplate, Id serviceItemId, Id taskItemId) {
        if (null != formTemplate.sve_SVE_Visualforce_Page__c) {
            return new List<Form_Meta_Data_Object_1__c>();
        
        }

        Integer i = 1;        
        List<Form_Meta_Data_Object_1__c> metaDataObjects = new List<Form_Meta_Data_Object_1__c>();
        
        for (String page : formTemplate.sve_SVE_Visualforce_Page__c.split(',')) {
            metaDataObjects.add(new Form_Meta_Data_Object_1__c(Form_PDF_Name__c    = formTemplate.Name + '_' + formTemplate.Form_Id__c,
                                                               Service_Item__c     = serviceItemId,
                                                               Task_Item__c        = taskItemId,
                                                               Version__c          = -1,
                                                               Form_Short_Name__c  = formTemplate.Name,
                                                               Visualforce_Page__c = page,
                                                               Page_Number__c      = i++));
       
        }
        return metaDataObjects;
    
    }

    public static String buildMetaDataQuery(List<Forms_Field_Mapping__c> ffmRecords) {
        String builtQuery = 'Select Id ';

        for (Forms_Field_Mapping__c ffm : ffmRecords) {
            builtQuery += ', ' + ffm.Milrose_Wave_Field_Name__c;
        
        }
        builtQuery = builtQuery.left(builtQuery.length());
        builtQuery += ' From Form_Item__c Where Id = ';
        return builtQuery;
    
    }
    
}