public with sharing class CompleteFormsTaskExtension {

    public static String SVE_PAGES_ARE_NOT_DEFINED = 'Selected Form in incorrect configured in Form Library (SVE Visualforce Pages field cannot be empty). Please contact Adminisrtator to resolve this issue.';
    public static String SIGNATORIES_ARE_NOT_DEFINED = 'Please define Signatories before Form generation.';
    public static String ERROR_INSERTING_FORM_ITEM = 'Error Occurred when inserting a new Form Item Record';
    public static String ERROR_FORM_NOT_VALID = 'This form version is no longer valid. Please select the latest one.';
    public static String ERROR_TASK_IS_NOT_STARTED = 'You must start the Task in order to generate Forms';

    public final Task_Item__c taskItem { get; set; }
    /*public List<Form_Item__c> formItemsList { get; set; }*/

    //public Map<Id, Form_Item__c> formItemsMap = new Map<Id, Form_Item__c>();
    public Map<String, String> shortFormNameToLastFormItemCopyId = new Map<String, String>();
    private Map<Id, Integer> formTemplateWithMaxVersionValue = new Map<Id, Integer>();
    public List<Form_Signature__c> formSignForDeleteOnLoad = new List<Form_Signature__c>();
    public List<Form_Template__c> formTemplatesList {get; set;}
    public List<LStore__Stored_Document__c> lStoreDocumentsForDisplay { get; set; }
    public List<Form_Template__c> selectedFormTemplatesList {
        get {
            if( selectedFormTemplatesList == null) selectedFormTemplatesList = new List<Form_Template__c>();
            return selectedFormTemplatesList;
        }
        set;
    }
    public List<LStore__Stored_Document__c> lStoreDocumentList {
        get {
            if(lStoreDocumentList == null) lStoreDocumentList = new List<LStore__Stored_Document__c>();
            return lStoreDocumentList;
        }
        set;
    }

    public PageReference iFrameDocumentPageReference { get; set; }
    public Boolean isForms { get{ if(isForms == null) isForms = true; return isForms;} set{ isForms = value;} }
    public Boolean isEmails { get; set{ isEmails = value;} }
    public Boolean isLetters { get; set{ isLetters = value;} }
    public Boolean isSearchResults { get; set; }
    public Boolean isSearchPanel { get; set; }
    public Boolean showAddNewButton { get; set; }
    public String refNumberFilter {get; set{ refNumberFilter = value;} }
    public String shortNameFilter { get; set{ shortNameFilter = value;} }
    public String fullNameFilter { get; set{ fullNameFilter = value;} }
    public String municipalityFilter { get; set{ municipalityFilter = value;} }
    private String queryWhere;
    public String selectedFormItemId { get; set; }
    public String selectedFormItemIdForClone { get; set; }
    public String storedDocumentId { get; set; }
    public String serviceItemId { get; set; }
    public Id formId { get; set; }
    public Id formSignId { get; set; }
    public String formName { get; set; }
    public String formType { get; set; }
    public String formIdString { get; set; }
    public Boolean isValid { get; set; }

    public String sveFormPage { get; set; }
    public String sveFormMetaData { get; set; }
    public String downloadPdfUrl { get; set; }

    public Boolean isInactiveService {
        get {
            return this.taskItem.Service_Item__r.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE;
        }
        set;
    }


    public String orderedForm {
        get;
        set {
            orderedForm = value;
            if( !String.isEmpty( orderedForm ) ) {
                Map<Id, FormWrapper> formWrappersMap = new Map<Id, FormWrapper>();
                for( FormWrapper formWrapperItem : formWrapperList ) {
                    formWrappersMap.put( formWrapperItem.formItemRecord.Id, formWrapperItem );
                }
                Integer i = 0;
                for( String stringItem : orderedForm.split(';') ) {
                    if ( stringItem != null && (stringItem instanceOf Id) && formWrappersMap.containsKey(Id.valueOf(stringItem)) ){
                        formWrappersMap.get(Id.valueOf(stringItem)).formItemRecord.Form_Row_Number_For_ComplForm__c = i++;
                    }
                }
            }
        }
    }

    public String regionId { get { if ( regionId == null ) regionId = taskItem.Region__c; return regionId; } set{ regionId = value;}}
    public List<selectOption> regionOptions {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for( Region__c item: [Select Name, Id From Region__c LIMIT 1000]){
                options.add( new SelectOption( item.Name , item.Name ) );
            }
            return options;
        }
        set;
    }

    public List<FormTemplatesWrapper> formTemplatesWrapperList {
        get {
            if(formTemplatesWrapperList == null) formTemplatesWrapperList = new List<FormTemplatesWrapper>();
            return formTemplatesWrapperList;
        }
        set;
    }

    private Set<String> fullFieldSetCloneQueryStringForFMDO{
        get {
            if( fullFieldSetCloneQueryStringForFMDO == null ) {
                fullFieldSetCloneQueryStringForFMDO = new Set<String>();
                fullFieldSetCloneQueryStringForFMDO.addAll(MilroseDevHelper.getEditableFieldsListByObjectName('Form_Meta_Data_Object_1__c', new Set<String>()));
            }
            return fullFieldSetCloneQueryStringForFMDO;
        }
        set;
    }

    private String fullCloneQueryStringForFMDO{
        get {
            if( fullCloneQueryStringForFMDO == null ) {
                List<String> fieldList = new List<String>();
                fieldList.addAll(fullFieldSetCloneQueryStringForFMDO);
                fullCloneQueryStringForFMDO = String.join(fieldList, ',');
            }
            return fullCloneQueryStringForFMDO;
        }
        set;
    }

    public with sharing class FormTemplatesWrapper {
        public Form_Template__c formTemplate { get; set; }
        public Boolean isSelected {
            get{
                if( isSelected == null ) isSelected = false;
                return isSelected;
            }
            set;
        }
        public Integer amount{
            get{
                if( amount == null ) amount = 1;
                return amount;
            }
            set;
        }

        public FormTemplatesWrapper( Form_Template__c formTemplate, Boolean isSelected, Integer amount ) {
            this.formTemplate = formTemplate;
            this.isSelected = isSelected;
            this.amount= amount;
        }
    }

    public CompleteFormsTaskExtension( ApexPages.StandardController controller ) {
        taskItem = (Task_Item__c)controller.getRecord();
        //getStoreDocuments();
        initRoster();
        initFullWrapper();
    }

    /*public PageReference deleteEmptySignatories() {
        if( formSignForDeleteOnLoad != null && !formSignForDeleteOnLoad.isEmpty() ){
            delete formSignForDeleteOnLoad;
            initFullWrapper();
        }
        return null;
    }*/

    public void saveAction() {
        saveAction( true );
    }

    public void saveAction( Boolean doInit ) {
        List<Form_Signature__c> formSignForUpdate = new List<Form_Signature__c>();
        List<Form_Item__c> formItemForUpdate = new List<Form_Item__c>();

        for (FormWrapper formWrapperItem : formWrapperList){
            formItemForUpdate.add( formWrapperItem.formItemRecord );
            for (Form_Signature__c formSignatureItem : formWrapperItem.formSignatureList){
                formSignForUpdate.add( formSignatureItem );
            }
        }

        if( !formSignForUpdate.isEmpty() ) {
            List<Form_Signature__c> signatoriesInDB = new List<Form_Signature__c>();
            for( Form_Signature__c signatoryItem : formSignForUpdate ) {
                if( !String.isBlank( signatoryItem.Id ) ) {
                    signatoriesInDB.add(signatoryItem);
                }
            }
            UPDATE signatoriesInDB;
        }

        if( !formItemForUpdate.isEmpty() ) {
            UPDATE formItemForUpdate;
        }

        if( doInit ) {
            initFullWrapper();
        }
        return;
    }

    public List<Form_Item__c> getFormItemsList() {
        List<Form_Item__c> formItemsList = new List<Form_Item__c>();
        for( Form_Item__c formItem : [ Select Task_Type__c, Form_Id__c, Status__c, Service_Item__c, Region__c, Name, Consumer__c, Form_Type__c,
                                               Id, Form_Template__c, Complete_Forms_Status__c, Complete_Forms__c, Stored_Document__c, Project__c,
                                               Stored_Document__r.Id, Short_Form_Name__c, Form_Name__c, Form_Template__r.Form_ID__c, Subject__c,
                                               Form_Template__r.Subject__c, Form_Template__r.Form_Name__c, Form_Template__r.Name, Project__r.Building__c,
                                               Form_Signatures_Count__c, Form_Status__c, External_Form__c, Form_Signatories__c, Is_Copy__c, Form_Row_Number_For_ComplForm__c,
                                               sve_SVE_Visualforce_Page__c, Form_Meta_Data_Object_1__c, sve_Meta_Data_Query__c, Current_Page_Number__c,
                                               Building_Project_No__c, Borough__c, Building_MRC__c, Manualy_Uploaded_Form__c, Project__r.Name, isCloned__c,
                                               ( Select Task_Item__c, Id, Form_Item__c, Project_Roster__c, Role__c, Order__c
                                                 From Form_Signatures__r Order by Order__c, Id ),
                                               ( Select Id, Service_Item__c, Task_Item__c, Form_Item__c From Form_Meta_Data_Objects_1__r )
                                       From Form_Item__c
                                       Where Service_Item__c =: taskItem.Service_Item__c Order by Form_Template__r.Form_Id__c, Form_Id__c, Form_Name__c, External_Form__c
                                       LIMIT 1000 ] ){

            if ( formItem.Form_Signatures_Count__c > 1 ){
                for( Form_Signature__c item: formItem.Form_Signatures__r ){
                    if( item.Project_Roster__c == null ) formSignForDeleteOnLoad.add(item);
                }
            }
            formItemsList.add( formItem );
            shortFormNameToLastFormItemCopyId.put(formItem.Short_Form_Name__c, formItem.Form_Id__c);
        }
        //formItemsMap = new Map<Id, Form_Item__c>( formItemsList );
        return formItemsList;
    }

    public void deleteFormItem() {
        saveAction( false );
        if( selectedFormItemId == null ) {
            return;
        }
        Form_Item__c tobeDeleted = null;
        for( FormWrapper formWrapperItem : formWrapperList ) {
            if( formWrapperItem.formItemRecord.Id == selectedFormItemId ) {
               tobeDeleted = formWrapperItem.formItemRecord;
               break;
            }
        }
        if( tobeDeleted != null ) {
            DELETE tobeDeleted;
        }
        initFullWrapper();
    }

    public void deleteStoredDocument(){
        LStore__Stored_Document__c docToDelete;
        for(LStore__Stored_Document__c sd : lStoreDocumentsForDisplay){
            if (sd.Id == storedDocumentId) {
                docToDelete = sd;
                break;
            }
        }
        if (docToDelete != null) {
            try {
                DELETE docToDelete;
                getStoreDocuments();
            } catch( System.DMLException e ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Error deleting Store Document' ) );
            }
        }
    }

    public PageReference searchAction() {
        isSearchResults = true;
        Set<String> setOfRefsInTable = new Set<String>();
        queryWhere = FormTemplatesServices.buildQueryWhere( refNumberFilter, shortNameFilter, fullNameFilter, municipalityFilter, regionId, isForms, isEmails, isLetters );
        formTemplatesList = Database.query(FormTemplatesServices.buildQuery(queryWhere));
        List<Form_Template__c> formTemplatesListClone = formTemplatesList.clone();
        formTemplatesList.clear();

        for( Form_Template__c formTemplate: formTemplatesListClone ){
            formTemplatesList.add( formTemplate );
        }

        getFormTemplatesWrapper();
        if(formTemplatesWrapperList.isEmpty()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No results found. Please specify another search criteria.'));
        return null;
    }

    public PageReference submitAction() {
        isSearchResults = false;
        isSearchPanel = false;
        getSelectedFormTemplates();
        FormItemsServices.insertNewFormItems( selectedFormTemplatesList, taskItem );
        initFullWrapper();
        return null;
    }

    public PageReference addNewForm() {
        saveAction( false );

        isSearchPanel = true;
        refNumberFilter = null;
        shortNameFilter = null;
        fullNameFilter = null;
        municipalityFilter = null;
        regionId = taskItem.Region__c;
        return null;
    }

    public void saveRowPosition() {
        List<Form_Item__c> formsToSavePosition = new List<Form_Item__c>();
        for( FormWrapper formWrapperItem : formWrapperList ) {
            if( !String.isBlank( formWrapperItem.formItemRecord.Id ) ) {
                formsToSavePosition.add( new Form_Item__c( Id = formWrapperItem.formItemRecord.Id, Form_Row_Number_For_ComplForm__c = formWrapperItem.formItemRecord.Form_Row_Number_For_ComplForm__c ) );
            }
        }
        if( !formsToSavePosition.isEmpty() ) {
            UPDATE formsToSavePosition;
        }
    }

    public PageReference cancelAction() {
        isSearchResults = false;
        isSearchPanel = false;
        initFullWrapper();
        return null;
    }

    private void populateFormTemplateWithMaxVersionMap(Set<Id> formTemplateSetId){
        formTemplateWithMaxVersionValue = new Map<Id, Integer>();

        Map<Id, List<Form_Item__c>> formTemplatesWithFormItemMap = new Map<Id, List<Form_Item__c>>();

        for (Id idItem : formTemplateSetId){
            formTemplatesWithFormItemMap.put(idItem, new List<Form_Item__c>());
        }

        for (FormWrapper formWrapperItem : formWrapperList){
            if ( formTemplatesWithFormItemMap.containsKey(formWrapperItem.formItemRecord.Form_Template__c) ){
                formTemplatesWithFormItemMap.get(formWrapperItem.formItemRecord.Form_Template__c).add(formWrapperItem.formItemRecord);
            }
        }

        for (Id formTemplateId : formTemplateSetId){
            Integer maxVersion = -1;
            if (!formTemplatesWithFormItemMap.get(formTemplateId).isEmpty()){
                for ( Form_Item__c formItem : formTemplatesWithFormItemMap.get(formTemplateId) ){
                    String s = formItem.Form_Id__c.removeStartIgnoreCase( formItem.Form_Template__r.Form_Id__c );
                    s = s.removeStartIgnoreCase( '_' );
                    Integer i = s.isNumeric() ? Integer.valueOf(s) : 0;
                    if ( i > maxVersion ){
                        maxVersion = i;
                    }
                }
            }
            formTemplateWithMaxVersionValue.put(formTemplateId, maxVersion);
        }
    }

    public void getSelectedFormTemplates(){

        if( selectedFormTemplatesList != null ) selectedFormTemplatesList.clear();
        Set<Id> selectedFormTemplateIdSet = new Set<Id>();

        for( FormTemplatesWrapper formsWrapper: formTemplatesWrapperList ){
            if( formsWrapper.isSelected ) {
                selectedFormTemplateIdSet.add(formsWrapper.formTemplate.Id);
            }
        }

        populateFormTemplateWithMaxVersionMap(selectedFormTemplateIdSet);

        for( FormTemplatesWrapper formsWrapper: formTemplatesWrapperList ){
            if( formsWrapper.isSelected ) {
                Integer maxVersion = formTemplateWithMaxVersionValue.get(formsWrapper.formTemplate.Id);

                for( Integer i = 0; i < formsWrapper.amount; i++ ){
                    Form_Template__c newFormTemplate = formsWrapper.formTemplate.clone(true,true,false,false);
                    ++maxVersion;
                    if ( maxVersion > 0 ) {
                        String versionSufix = String.valueOf(maxVersion);
                        While( versionSufix.length() < 3 ){
                            versionSufix = '0' + versionSufix;
                        }
                        newFormTemplate.Form_Id__c = newFormTemplate.Form_Id__c + '_' + versionSufix;
                    }
                    formTemplateWithMaxVersionValue.put(formsWrapper.formTemplate.Id, maxVersion);

                    selectedFormTemplatesList.add( newFormTemplate );
                }
            }

        }

   }

    public void getFormTemplatesWrapper() {

        if( formTemplatesWrapperList != null )formTemplatesWrapperList.clear();
        if( formTemplatesList!=null ){
            for (Form_Template__c item : formTemplatesList) {
                formTemplatesWrapperList.add(new FormTemplatesWrapper(item, false, 1));
            }
        }
    }

    public List<FormWrapper> formWrapperList{
        get {
            if(formWrapperList == null) formWrapperList = new List<FormWrapper>();
            return formWrapperList;
        }
        set;
    }

    public class FormWrapper implements Comparable {
        public Form_Item__c formItemRecord { get; set; }
        public List<Form_Signature__c> formSignatureList { get; set; }
        public Boolean isSelectedForClone { get; set; }

        public Integer compareTo(Object compareTo){
            FormWrapper compFullWrapper = (FormWrapper) compareTo;
            if (compFullWrapper.formItemRecord.Form_Row_Number_For_ComplForm__c == null ||
                formItemRecord.Form_Row_Number_For_ComplForm__c == null ||
                compFullWrapper.formItemRecord.Form_Row_Number_For_ComplForm__c == formItemRecord.Form_Row_Number_For_ComplForm__c){
                if (compFullWrapper.formItemRecord.Form_Row_Number_For_ComplForm__c == null && formItemRecord.Form_Row_Number_For_ComplForm__c != null) return -1;
                if (compFullWrapper.formItemRecord.Form_Row_Number_For_ComplForm__c != null && formItemRecord.Form_Row_Number_For_ComplForm__c == null) return 1;
                if (formItemRecord.Form_Id__c == compFullWrapper.formItemRecord.Form_Id__c) {
                    if (formItemRecord.Form_Name__c == compFullWrapper.formItemRecord.Form_Name__c) {
                        if (formItemRecord.External_Form__c == compFullWrapper.formItemRecord.External_Form__c) return 0;
                        if (formItemRecord.External_Form__c > compFullWrapper.formItemRecord.External_Form__c) return 1;
                    }
                    if (formItemRecord.Form_Name__c > compFullWrapper.formItemRecord.Form_Name__c) return 1;
                }
                if (formItemRecord.Form_Id__c > compFullWrapper.formItemRecord.Form_Id__c) return 1;
            } else {
                if ( formItemRecord.Form_Row_Number_For_ComplForm__c > compFullWrapper.formItemRecord.Form_Row_Number_For_ComplForm__c ) return 1;
            }
            return -1;
        }

        public FormWrapper ( Form_Item__c formItemRecord ){
            this.formItemRecord = formItemRecord;
            this.isSelectedForClone = false;
            this.formSignatureList = new List<Form_Signature__c>();
            for (Form_Signature__c formSignatureItem : formItemRecord.Form_Signatures__r){
                formSignatureList.add(formSignatureItem);
            }
        }
    }

    public void initFullWrapper() {
        formWrapperList = null;
        for( Form_Item__c formItem : getFormItemsList() ) {
            if( !formItem.Manualy_Uploaded_Form__c || !String.isEmpty(formItem.Form_Name__c) ) {
                formWrapperList.add( new FormWrapper( formItem ) );
            }
        }
        formWrapperList.sort();
    }

    public Map<String, String> rosterIdToEmail { get; set; }
    public List<SelectOption> rosterIdToContact { get; set; }
    private List<Project_Roster__c> rosters;

    public List<Project_Roster__c> getRoster {
        get {
            if (null == this.rosters) {
                this.rosters = ProjectRosterServices.getRosterByProjectId(taskItem.Project_Profile__c);

            }
            return this.rosters;
        }
    }

    public PageReference cloneAction() {
        saveAction( false );
        try{
            prepareDataForClone();
        } catch (Exception ex){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ex.getMessage() ) );
        }
        this.selectedFormItemIdForClone = '';
        initFullWrapper();
        return null;
    }

    private void prepareDataForClone(){
        List<FormWrapper> selectedFormWrapperList = new List<FormWrapper>();
        Map<Id, Form_Item__c> originalWithClonedFormItems = new Map<Id, Form_Item__c>();
        Map<Id, List<String>> formTemplatesWithFormItemNames = new Map<Id, List<String>>();
        Set<Id> formTemplateClonnedSetId = new Set<Id>();
        Map<Id, Integer> formTemplateIdWithMaxFormVersion = new Map<Id, Integer>();

        Map<Id, Form_Item__c> formItemRowPositionUpdateList = new Map<Id, Form_Item__c>();

        Integer rowPosition = 0;
        for (FormWrapper formWrapperItem : formWrapperList){
            formItemRowPositionUpdateList.put(formWrapperItem.formItemRecord.Id,
                                              new Form_Item__c(Id = formWrapperItem.formItemRecord.Id, Form_Row_Number_For_ComplForm__c = rowPosition++));

            if ( formWrapperItem.formItemRecord.Id == selectedFormItemIdForClone ) {
                //MRS-6894
                if ( formWrapperItem.formItemRecord.Form_Template__c == null ){
                    throw new ErrorException( ERROR_FORM_NOT_VALID );
                }

                selectedFormWrapperList.add(formWrapperItem);
                formTemplateClonnedSetId.add(formWrapperItem.formItemRecord.Form_Template__c);
                rowPosition++;
            }

            if ( !formTemplatesWithFormItemNames.containsKey(formWrapperItem.formItemRecord.Form_Template__c) ){
                formTemplatesWithFormItemNames.put(formWrapperItem.formItemRecord.Form_Template__c, new List<String>{formWrapperItem.formItemRecord.Form_Id__c});
            } else {
                formTemplatesWithFormItemNames.get(formWrapperItem.formItemRecord.Form_Template__c).add(formWrapperItem.formItemRecord.Form_Id__c);
            }
        }

        if (selectedFormWrapperList.isEmpty()) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'please select Forms for cloning' ) );
            return;
        }

        update formItemRowPositionUpdateList.values();

        populateFormTemplateWithMaxVersionMap(formTemplateClonnedSetId);

        for(FormWrapper formWrapperItem : selectedFormWrapperList){
            Form_Item__c formItemCloned = formWrapperItem.formItemRecord.clone(false, true, false, false);
            formItemCloned.Id = null;
            Integer i = formTemplateWithMaxVersionValue.get( formWrapperItem.formItemRecord.Form_Template__c ) + 1;
            String newNameValue = String.valueOf( i );
            while ( newNameValue.length() < 3 ){
                newNameValue = '0' + newNameValue;
            }
            formItemCloned.Form_Id__c = formWrapperItem.formItemRecord.Form_Template__r.Form_ID__c + '_' + newNameValue;
            formItemCloned.Form_Row_Number_For_ComplForm__c = formItemRowPositionUpdateList.get( formWrapperItem.formItemRecord.Id ).Form_Row_Number_For_ComplForm__c + 1;
            formItemCloned.Form_Row_Number_For_Send_And__c = null;
            formItemCloned.Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_NOT_STARTED;
            formItemCloned.isCloned__c = true;

            originalWithClonedFormItems.put(formWrapperItem.formItemRecord.Id, formItemCloned);

            formTemplateWithMaxVersionValue.put( formWrapperItem.formItemRecord.Form_Template__c, i );
        }

        insert originalWithClonedFormItems.values();

        Map<Id, Form_Item__c> clonedFormItemWithSignatureMap = new Map<Id, Form_Item__c>([SELECT Id,
                                                                                                (Select Task_Item__c, Id, Form_Item__c, Project_Roster__c, Role__c, Order__c From Form_Signatures__r)
                                                                                           FROM Form_Item__c
                                                                                           WHERE Id IN : originalWithClonedFormItems.values()]);

        List<Form_Signature__c> clonedFormSignatureListForUpdate = new List<Form_Signature__c>();
        for (FormWrapper formWrapperItem : selectedFormWrapperList){
            Form_Item__c clonedFormItemWithSignature = clonedFormItemWithSignatureMap.get(originalWithClonedFormItems.get( formWrapperItem.formItemRecord.Id ).Id );
            Map<Decimal, Form_Signature__c> newOrderedFormSignatureMap = new Map<Decimal, Form_Signature__c>();
            for (Form_Signature__c formSignatureItem : formWrapperItem.formSignatureList){
                if ( formSignatureItem.Project_Roster__c != null ){
                    if ( newOrderedFormSignatureMap.isEmpty() ){
                        for (Form_Signature__c formSignatureCloned : clonedFormItemWithSignature.Form_Signatures__r){
                            if ( formSignatureCloned.Order__c != null ){
                                newOrderedFormSignatureMap.put( formSignatureCloned.Order__c, formSignatureCloned );
                            }
                        }
                    }
                    if ( newOrderedFormSignatureMap.containsKey(formSignatureItem.Order__c) ){
                        clonedFormSignatureListForUpdate.add( new Form_Signature__c( Id = newOrderedFormSignatureMap.get(formSignatureItem.Order__c).Id, Project_Roster__c = formSignatureItem.Project_Roster__c ) );
                    }
                }
            }
        }
        if (!clonedFormSignatureListForUpdate.isEmpty()){
            update clonedFormSignatureListForUpdate;
        }

        String queryFMDO = 'SELECT ';
        if ( !fullFieldSetCloneQueryStringForFMDO.contains('Form_Item__c') ){
            queryFMDO += 'Form_Item__c, ';
        }
        if ( !fullFieldSetCloneQueryStringForFMDO.contains('Page_Number__c') ){
            queryFMDO += 'Page_Number__c, ';
        }

        queryFMDO += fullCloneQueryStringForFMDO + ' FROM Form_Meta_Data_Object_1__c WHERE Form_Item__c IN (';
        for ( Id idItem : originalWithClonedFormItems.keySet() ){
            queryFMDO += '\'' + idItem + '\',\'' + originalWithClonedFormItems.get(idItem).Id + '\',';
        }
        queryFMDO = queryFMDO.removeEnd(',') + ')';

        List<Form_Meta_Data_Object_1__c> fmdoUpdateList = new List<Form_Meta_Data_Object_1__c>();
        List<Form_Meta_Data_Object_1__c> fmdoList = Database.query(queryFMDO);

        Map<Id, Map<Integer, Form_Meta_Data_Object_1__c>> formWithFMDOMap = new Map<Id, Map<Integer, Form_Meta_Data_Object_1__c>>();

        for ( Form_Meta_Data_Object_1__c fmdoItem : fmdoList ){
            if ( !formWithFMDOMap.containsKey(fmdoItem.Form_Item__c) ){
                formWithFMDOMap.put( fmdoItem.Form_Item__c, new Map<Integer, Form_Meta_Data_Object_1__c>() );
            }
            formWithFMDOMap.get(fmdoItem.Form_Item__c).put(Integer.valueOf( fmdoItem.Page_Number__c ), fmdoItem);
        }

        for ( Id idItem : originalWithClonedFormItems.keySet() ){
            Map<Integer, Form_Meta_Data_Object_1__c> pageNumberWithFMDO = formWithFMDOMap.get( (originalWithClonedFormItems.get(idItem).Id) );
            for( Integer i : formWithFMDOMap.get(idItem).keySet() ){
                Form_Meta_Data_Object_1__c fmdo = (formWithFMDOMap.get(idItem)).get(i);
                Form_Meta_Data_Object_1__c fmdoCloned = ( formWithFMDOMap.get( originalWithClonedFormItems.get(idItem).Id ) ).get(i);
                for (String fieldNameValue : fullFieldSetCloneQueryStringForFMDO){
                    if ( fmdoCloned.get(fieldNameValue) != fmdo.get(fieldNameValue) ){
                        fmdoCloned.put(fieldNameValue, fmdo.get(fieldNameValue));
                    }
                }
                for ( Integer pageNumber : pageNumberWithFMDO.keySet() ){
                    fmdoCloned.put( 'Page_' + pageNumber + '_ID__c', pageNumberWithFMDO.get(pageNumber).Id );
                }
                fmdoUpdateList.add(fmdoCloned);
            }
        }

        update fmdoUpdateList;
    }

    public Map<Id, String> projectRosterMap {
        get{
            if (projectRosterMap == null){
                projectRosterMap = new Map<Id, String>();
                projectRosterMap.put(null, 'Blank (No Signatory)');
                for (Project_Roster__c roster : this.getRoster){
                    projectRosterMap.put(roster.Id, roster.Role__c + ' - ' + roster.Name__c);
                }
            }
            return projectRosterMap;
        }
        set;
    }

    public void initRoster() {
        rosterIdToEmail = new Map<String, String>();
        rosterIdToContact = new List<SelectOption>();
        rosterIdToContact.add(new SelectOption ('', 'Blank (No Signatory)'));

        for (Project_Roster__c roster : this.getRoster) {
            if (!String.isBlank(roster.Role__c)) {
                this.rosterIdToContact.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c));

                if (!rosterIdToEmail.containsKey(roster.Id)) {
                    rosterIdToEmail.put(roster.Id, roster.Email__c);
                }
            }
        }

    }

    public PageReference updateFormSignature(){
        Form_Signature__c formSignForUpdate = new Form_Signature__c();

        for (FormWrapper formWrapperItem : formWrapperList){
            if ( formWrapperItem.formItemRecord.Id != formId ){ continue; }
            for (Form_Signature__c formSignatureItem : formWrapperItem.formSignatureList){
                if ( formSignatureItem.Id == formSignId ){
                    formSignForUpdate = formSignatureItem;
                    break;
                }
            }
        }

        if( formSignForUpdate.Id != null ) {
            update formSignForUpdate;
        }

        List<Form_Item__c> formItemForUpdate = new List<Form_Item__c>();
        for( FormWrapper formWrapperItem : formWrapperList ){
            formItemForUpdate.add( formWrapperItem.formItemRecord );
        }
        if( !formItemForUpdate.isEmpty() ){
            UPDATE formItemForUpdate;
        }

        formWrapperList.sort();
        //initFullWrapper();
        return null;
    }

    public void disableAddNewButton(){
        showAddNewButton = true;
    }

    public void autorun() {
        getStoreDocuments();
        saveInitialRowPositions();
    }

    public void saveInitialRowPositions() {
        Integer i = 0;
        List<Form_Item__c> formsToSavePosition = new List<Form_Item__c>();
        for( FormWrapper formWrapperItem : formWrapperList ) {
            formsToSavePosition.add( new Form_Item__c( Id = formWrapperItem.formItemRecord.Id, Form_Row_Number_For_ComplForm__c = i++ ) );
        }
        if( !formsToSavePosition.isEmpty() ) {
            UPDATE formsToSavePosition;
        }
    }

    public void getStoreDocuments() {
        PageReference pr;
        PageReference prFileList;
        lStoreDocumentsForDisplay = new List<LStore__Stored_Document__c>();
        Set<Id> fmdoIds = new Set<Id>();
        for( Form_Meta_Data_Object_1__c fmdo : [ Select Id From Form_Meta_Data_Object_1__c
                                                 Where Service_Item__c = :taskItem.Service_Item__c AND Task_Item__c = :taskItem.Id ] ){
            fmdoIds.add( fmdo.Id );
        }

        lStoreDocumentsForDisplay = [ SELECT RecordType.DeveloperName, RecordTypeId, LStore__Related_Object_Id__c, LStore__File_Name__c, Id,
                                             LStore__Type_Calc__c, CreatedDate, LStore__Description__c, CreatedById, CreatedBy.Alias,
                                             LStore__File_Size_Calc__c
                                      FROM LStore__Stored_Document__c
                                      WHERE RecordTypeId != : StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                      AND Related_Object_Id__c IN : fmdoIds ];
    }

    public PageReference openPDF(){
        downloadPdfUrl = '/apex/lstore__storedDocViewRestore?id=' + selectedFormItemId + '&action=download&contentType=redirect&retURL=/' + taskItem.Id;
        return null;
    }

    private static String getFirstPage( String visualforcePages ){
        String page = visualforcePages;
        if( visualforcePages != null && visualforcePages.contains(',') ) {
            page = visualforcePages.left( visualforcePages.indexOf(',') );
        }
        return page;
    }

    public void updateMetaDataRecord(){
        if ( taskItem.Actual_Start_Date__c == null || taskItem.Status__c == TaskItemServices.TASK_ITEM_STATUS_NOT_STARTED ){
            isValid = false;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ERROR_TASK_IS_NOT_STARTED ) );
            return;
        }
        saveAction( false );
        Form_Item__c currForm;
        for( FormWrapper formWrapperItem : formWrapperList ) {
            if( formWrapperItem.formItemRecord.Id == (Id)formId ) {
                currForm = formWrapperItem.formItemRecord;
            }
        }
        List<Form_Meta_Data_Object_1__c> fmdoList = new List<Form_Meta_Data_Object_1__c>([ Select Id, Form_Item__r.Manualy_Uploaded_Form__c, Form_Item__c From Form_Meta_Data_Object_1__c Where Form_Item__c = :formId AND Page_Number__c = 1 ]);
        if( fmdoList.isEmpty() || currForm.Manualy_Uploaded_Form__c ) {
            return;
        }
        Form_Meta_Data_Object_1__c currentFmdo = fmdoList[0];
        sveFormPage = getFirstPage( currForm.sve_SVE_Visualforce_Page__c );
        sveFormMetaData = currentFmdo.Id;

        isValid = true;
        if(String.isEmpty(sveFormPage)) {
            isValid = false;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, SVE_PAGES_ARE_NOT_DEFINED ) );
            return;
        }

        if (currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_NOT_STARTED ||
            currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_STARTED ||
            currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_GENERATED){
            List<Form_Meta_Data_Object_1__c> metadataObjects;

            if( currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_NOT_STARTED && !currForm.isCloned__c ) {

                if ( currForm.Form_Template__c == null ){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, ERROR_FORM_NOT_VALID ) );
                    isValid = false;
                    return;
                }

                Map<String, String> metadataFieldToWaveField = new Map<String, String>();
                for( Forms_Field_Mapping__c ffmRecord : [ Select Id, Name, Meta_Data_Field_Name__c, Milrose_Wave_Field_Name__c
                                                     From Forms_Field_Mapping__c Where Form__c = :currForm.Form_Template__c ] ) {
                    metadataFieldToWaveField.put( ffmRecord.Meta_Data_Field_Name__c, ffmRecord.Milrose_Wave_Field_Name__c );
                }
                List<Form_Item__c> recordSet = Database.query( currForm.sve_Meta_Data_Query__c + '\'' + formId + '\'' );
                Form_Item__c initDataForForm = recordSet[0];

                metadataObjects = FormItemsServices.initialPreparationFormMetaDataObject( currForm );

                FormMetaDataObject1Services.populateSignatoriesFields( new Map<Id, Form_Meta_Data_Object_1__c>( metadataObjects ) );

                for( String metadataField : metadataFieldToWaveField.keySet() ){
                    for( Form_Meta_Data_Object_1__c fmdo : metadataObjects ) {
                        fmdo.put( metadataField, initDataForForm.get( metadataFieldToWaveField.get( metadataField ) ) );
                    }
                }
                UPDATE metadataObjects;
            } else if ( currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_STARTED ||
                        currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_GENERATED ||
                        (currForm.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_NOT_STARTED && currForm.isCloned__c) ) {
                metadataObjects = [ SELECT Id, Page_Number__c, Form_Item__c From Form_Meta_Data_Object_1__c
                                    WHERE Form_Item__c =:currForm.Id Order By Page_Number__c ];

                FormMetaDataObject1Services.populateSignatoriesFields( new Map<Id, Form_Meta_Data_Object_1__c>( metadataObjects ) );
            }

            String userAlias = UserServices.getUserById( UserInfo.getUserId() ).Alias;

            for (Form_Meta_Data_Object_1__c formMetaDataObject1Item : metadataObjects){
                formMetaDataObject1Item.put('User_Alias__c', userAlias);
            }
            UPDATE metadataObjects;
        }
    }

    /* Upload Form Section */
    public Form_Item__c formItemToInsert {
        get{
            if( formItemToInsert == null ){
                for( FormWrapper formWrapperItem : formWrapperList ) {
                    if( formWrapperItem.formItemRecord.Manualy_Uploaded_Form__c && String.isEmpty(formWrapperItem.formItemRecord.Form_Name__c) ) {
                        formItemToInsert = formWrapperItem.formItemRecord;
                        break;
                    }
                }
                if( formItemToInsert == null ){
                    formItemToInsert = new Form_Item__c( Service_Item__c = taskItem.Service_Item__c,
                                                         Region__c = taskItem.Project_Profile__r.Region_ID__c,
                                                         Manualy_Uploaded_Form__c = true,
                                                         Complete_Forms_Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED,
                                                         Complete_Forms__c = taskItem.Successor_Task__c,
                                                         Project__c = taskItem.Project_Profile__c );
                }
            }
            return formItemToInsert;
        }
        private set;
    }

    public Form_Meta_Data_Object_1__c formMetaDataToInsert{
        get{
            if( formMetaDataToInsert == null ){
                if(formItemToInsert.Id != null && !formItemToInsert.Form_Meta_Data_Objects_1__r.isEmpty() ){
                    formMetaDataToInsert = formItemToInsert.Form_Meta_Data_Objects_1__r[0];
                }else{
                    formMetaDataToInsert = new Form_Meta_Data_Object_1__c( Service_Item__c = taskItem.Service_Item__c, Task_Item__c = taskItem.Id );
                }
            }
            return formMetaDataToInsert;
        }
        private set;
    }

    public void prepareDocumentUpload(){
        saveAction( false );
        initFullWrapper();
        formItemToInsert = null;
        formMetaDataToInsert = null;
        try {
            if( formMetaDataToInsert.Id == null ){
                insert formItemToInsert;

                formMetaDataToInsert.Form_Item__c = formItemToInsert.Id;
                insert formMetaDataToInsert;

                LStore__Stored_Document__c folderDoc = StoredDocumentServices.createFolder(StoredDocumentServices.FORMS_FILE_TYPE, formMetaDataToInsert.Id);
                insert folderDoc;
            }
        } catch( DmlException ex ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, ERROR_INSERTING_FORM_ITEM ) );
        }
    }

    public String regionName{ get{ return taskItem.Region__c;} private set; }
    public String iframeUrl{
        get{
            return URL.getSalesforceBaseUrl().toExternalForm() + '/apex/StoredDocsInlineUploadForm?id=' + formMetaDataToInsert.Id + '&formItemId=' + formItemToInsert.Id;
        }
        private set;
    }
}