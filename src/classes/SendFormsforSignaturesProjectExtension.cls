public with sharing class SendFormsforSignaturesProjectExtension {
    private final String TYPE_NAME = 'Project Level Transmittal For Multiple Task Items';

    private String SHIPPING_RECORD_TYPE_FROM_TASK_NAME = 'From Task';
    private final String SHIPPING_REQUEST_OBJECT_NAME = 'Shipping_Request__c';
    public Project_Profile__c projectProfile { get; set; }

    public transient List<Form_Item__c> formItemsList;
    public List<Form_Item__c> getFormItemsList() {
        List<Form_Item__c> formItemsListTemp = new List<Form_Item__c>();
        for( Form_Item__c formItem : [ SELECT Form_Id__c, Service_Item__c, Name, Quantity_For_Transmittal__c, Recipient_Role__c,
                                              Id, Form_Template__c, Complete_Forms__c, Form_Status__c, Form_Signatories__c, External_Form__c,
                                              Short_Form_Name__c, Form_Name__c, Project__c, Subject__c,
                                              Manualy_Uploaded_Form__c, Status__c, Project__r.Name, CreatedDate, Form_Row_Number_For_ComplForm__c,
                                              Form_Row_Number_For_Send_Project__c, Service_Item__r.Name,
                                              ( SELECT Sent_VIA__c, Sent_Tracking__c, Sent_Date__c, Recipient_Role__c, Received_VIA__c, Received_Tracking__c, Received_Date__c,
                                                       Name, Id, Form_Item__c, Alert_Checkbox__c, Alert_Calendar__c, Status__c, Form_Item__r.Form_Id__c, Form_Item__r.Form_Name__c
                                                FROM Form_Assignments__r WHERE Status__c != null // MRS 7342
                                                ORDER BY CreatedDate DESC, Form_Item__r.Form_Id__c ASC, Form_Item__r.Form_Name__c ASC)
                                       FROM Form_Item__c
                                       WHERE Project__c = : projectProfile.Id AND
                                             External_Form__c = null AND
                                             Service_Item__r.Status__c != : ServiceItemServices.SERVICE_STATUS_INACTIVE
                                       ORDER BY Form_Id__c, Form_Name__c, External_Form__c LIMIT 545]){
            formItemsListTemp.add( formItem );
        }
        return formItemsListTemp;
    }

    public List<Form_Assignment__c> formAssignmentsList {get; set;}
    private String queryWhere;
    public String commentsShortName { get; set; }
    public String selectedFormItemId { get; set; }
    public String storedDocumentId { get; set; }
    public String serviceItemId { get; set; }
    public String formRef { get; set; }
    public String formItemStatus { get; set; }
    public Id formItemId { get; set; }
    public Id formAssignmentId { get; set; }
    public Id rosterId { get; set; }
    public Id rosterReplyToId { get; set; }
    //@TestVisible private List<Project_Roster__c> rosters;
    public Project_Roster__c rosterForTransmittalSendTo { get { if( rosterForTransmittalSendTo == null ) rosterForTransmittalSendTo = new Project_Roster__c(); return rosterForTransmittalSendTo; } set; }
    public Project_Roster__c rosterForTransmittalReplyTo { get { if( rosterForTransmittalReplyTo == null ) rosterForTransmittalReplyTo = new Project_Roster__c(); return rosterForTransmittalReplyTo; } set; }
    public Map<String, String> rosterIdToEmail { get; set; }
    public List<SelectOption> rosterIdToContact { get; set; }
    public List<SelectOption> comments { get; set; }
    public List<SelectOption> formAssignmentStatus { get; set; }
    public Boolean isPrintPendingFormsPanel { get; set; }
    public Boolean isShippingRequestPanel { get; set; }
    private Map<String, String> transmittalComments = new Map<String, String>();
    private Id transmittalCreator;

    public String orderedForm { //MRS 7040
        get;
        set {
            orderedForm = value;
            if( !String.isEmpty( orderedForm ) ) {
                Integer i = 0;
                Map<Id, Form_Item__c> fItemIdToFormItem = new Map <Id, Form_Item__c> ();
                for( FormWrapper fWrapper : formWrapperList ) {
                    fItemIdToFormItem.put(fWrapper.formItemInFullWrapper.Id, fWrapper.formItemInFullWrapper);
                }
                for( String stringItem : orderedForm.split(';') ) {
                    if( stringItem != null && ( stringItem instanceOf Id ) && fItemIdToFormItem.containsKey( Id.valueOf( stringItem ) ) ) {
                        fItemIdToFormItem.get( Id.valueOf( stringItem ) ).Form_Row_Number_For_Send_Project__c = i++;
                    }
                }
                formWrapperList.sort();
                orderedForm = null;
            }
        }
    }

    public SendFormsforSignaturesProjectExtension( ApexPages.StandardController controller ) {
        if(!Test.isRunningTest()) {
            controller.addFields( new List<String>{ 'Fulfillment_Office__c', 'Name' } );
            projectProfile = (Project_Profile__c)controller.getRecord();
        } else {
            projectProfile = (Project_Profile__c)controller.getRecord();
            projectProfile = [SELECT Id, Fulfillment_Office__c, Name
                              FROM Project_Profile__c
                              WHERE Id =: projectProfile.Id];
        }
        initRoster();
        getFullWrapper();
        initComments();
        initFormAssignmentStatus();
    }

    public Form_Item__c newFormItem {
        get{
            newFormItem = new Form_Item__c();
            return newFormItem;
        } set;
    }

    private RecordType recordTypeShippingRequest {
        get{
            if ( recordTypeShippingRequest == null ){
                List<RecordType> recordTypes = new List<RecordType>([Select Id From RecordType where SobjectType =: SHIPPING_REQUEST_OBJECT_NAME AND Name =: SHIPPING_RECORD_TYPE_FROM_TASK_NAME LIMIT 1]);
                recordTypeShippingRequest = recordTypes.isEmpty() ? new RecordType() : recordTypes[0];
            }
            return recordTypeShippingRequest;
        } set;
    }

    public Set<Id> selectedIdRolesSet {
        get {
            if( selectedIdRolesSet == null) selectedIdRolesSet = new Set<Id>();
            return selectedIdRolesSet;
        } set;
    }


    public List<Form_Item__c> selectedFormItemsList {
        get {
            if( selectedFormItemsList == null) selectedFormItemsList = new List<Form_Item__c>();
            return selectedFormItemsList;
        } set;
    }

    public List<Form_Assignment__c> selectedFormAssignmentsList {
        get {
            if( selectedFormAssignmentsList == null) selectedFormAssignmentsList = new List<Form_Assignment__c>();
            return selectedFormAssignmentsList;
        } set;
    }

    public Transmittal__c transmittal {
        get {
            if( transmittal == null ) {
                transmittal = new Transmittal__c( Project_Profile__c = projectProfile.Id, CC_to__c = '', Send_To_Name__c = '', Reply_To__c = '', Send_To_Address__c = '', Send_To_Street__c = '',
                                                  Comments__c = '', Resubmit__c = null, Return__c = null, Send_To__c = '', Submit__c = null, VIA__c = null, Other__c = null, Additional_Comments__c = '',
                                                  Fulfillment_Office_Address__c = '', Fulfillment_Office_Street__c = '', Fulfillment_Office_Phone__c = '', Fulfillment_Office_Fax__c = '' );
                for( Transmittal__c item: [Select Id, CreatedById From Transmittal__c Where Project_Profile__c = : projectProfile.Id limit 1 ] ) {
                    transmittal.Id = item.Id;
                }
                transmittalCreator = UserInfo.getUserId();

                FulfillmentOfficeAddresses__c fulfillmentOffice = FulfillmentOfficeAddresses__c.getValues( this.projectProfile.Fulfillment_Office__c );

                if( fulfillmentOffice != null ) {
                    if( fulfillmentOffice.City__c != null ) transmittal.Fulfillment_Office_Address__c = fulfillmentOffice.City__c;
                    if( fulfillmentOffice.Street__c != null ) transmittal.Fulfillment_Office_Street__c = fulfillmentOffice.Street__c;
                    if( fulfillmentOffice.Phone__c != null ) transmittal.Fulfillment_Office_Phone__c = fulfillmentOffice.Phone__c;
                    if( fulfillmentOffice.Fax__c != null ) transmittal.Fulfillment_Office_Fax__c = fulfillmentOffice.Fax__c;
                }
            }
            return transmittal;
        } set;
    }

    public Shipping_Request__c shippingRequest {
        get {
            if ( shippingRequest == null ) {
                shippingRequest = new Shipping_Request__c( Project_Profile__c = projectProfile.Id,
                                                           MRC_Reference__c = projectProfile.Name,
                                                           RecordTypeId = recordTypeShippingRequest.Id );
            }
            return shippingRequest;
        } set;
    }

    public List<rosterWrapper> wrapoutRosters {
        get {
            if(wrapoutRosters == null) wrapoutRosters = new List<RosterWrapper>();
            return wrapoutRosters;
        } set;
    }

    public List<Project_Roster__c> getRosters() {
        return new List<Project_Roster__c>( ProjectRosterServices.getRosterByProjectId( projectProfile.Id ) );
    }

    public List<FormWrapper> formWrapperList {
        get {
            if(formWrapperList == null) formWrapperList = new List<FormWrapper>();
            return formWrapperList;
        } set;
    }

	public class AssignmentWrapper { //MRS 7510
		public Form_Assignment__c item { get; set; }
		public Boolean isSelected {
			get {
				if(isSelected == null) isSelected = false;
				return isSelected; } 
			set;
		}
		public AssignmentWrapper(Form_Assignment__c fa) {
			this.item = fa;
		}
	}

    public class FormWrapper implements Comparable {
        public Form_Item__c formItemInFullWrapper { get; set; }
        public List<AssignmentWrapper> formAssignments { get; set; } //MRS 7510
        public Boolean isSelected {
            get{
                if( isSelected == null ) isSelected = false;
                return isSelected;
            }
			set;
        }

        public Integer compareTo(Object compareTo){
            FormWrapper compFullWrapper = (FormWrapper) compareTo;
            if (compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_Send_Project__c == null ||
                formItemInFullWrapper.Form_Row_Number_For_Send_Project__c == null ||
                compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_Send_Project__c == formItemInFullWrapper.Form_Row_Number_For_Send_Project__c){
                if ( compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_ComplForm__c != null && formItemInFullWrapper.Form_Row_Number_For_ComplForm__c != null ){
                    if (compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_ComplForm__c == formItemInFullWrapper.Form_Row_Number_For_ComplForm__c) return 0;
                    if (compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_ComplForm__c > formItemInFullWrapper.Form_Row_Number_For_ComplForm__c) return -1;
                    if (compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_ComplForm__c < formItemInFullWrapper.Form_Row_Number_For_ComplForm__c) return 1;
                } else if (formItemInFullWrapper.Form_Id__c == compFullWrapper.formItemInFullWrapper.Form_Id__c) {
                    if (formItemInFullWrapper.Form_Name__c == compFullWrapper.formItemInFullWrapper.Form_Name__c) {
                        if (formItemInFullWrapper.External_Form__c == compFullWrapper.formItemInFullWrapper.External_Form__c) return 0;
                        if (formItemInFullWrapper.External_Form__c > compFullWrapper.formItemInFullWrapper.External_Form__c) return 1;
                    }
                    if (formItemInFullWrapper.Form_Name__c > compFullWrapper.formItemInFullWrapper.Form_Name__c) return 1;
                }
                if (formItemInFullWrapper.Form_Id__c > compFullWrapper.formItemInFullWrapper.Form_Id__c) return 1;
            } else {
                if ( formItemInFullWrapper.Form_Row_Number_For_Send_Project__c > compFullWrapper.formItemInFullWrapper.Form_Row_Number_For_Send_Project__c ) return 1;
            }
            return -1;
        }

        public FormWrapper (Form_Item__c formItem){
            this.formItemInFullWrapper = formItem;
            this.formAssignments = new List<AssignmentWrapper>(); //MRS 7510
			for(Form_Assignment__c fa : formItem.Form_Assignments__r) {
				formAssignments.add(new AssignmentWrapper(fa));
			}
            this.isSelected = false;
        }
    }

    public class rosterWrapper {
        public Id rosterIdCCToInWrapper { get; set; }
        public Project_Roster__c rosterForTransmittal { get; set; }

        public rosterWrapper( Id rosterIdCCToInWrapper, Project_Roster__c rosterForTransmittal ) {
            this.rosterIdCCToInWrapper = rosterIdCCToInWrapper;
            this.rosterForTransmittal = rosterForTransmittal;
        }
    }

    public void getFullWrapper() {
        formWrapperList.clear();
        for( Form_Item__c formItem : getFormItemsList() ) {
            if( !formItem.Form_Assignments__r.isEmpty() ) {
                formWrapperList.add( new FormWrapper( formItem ) );
            }
        }
        formWrapperList.sort();
    }

    public void initFormAssignmentStatus() {
        formAssignmentStatus = new List<SelectOption>();
        formAssignmentStatus.add(new SelectOption (FormItemsServices.FORM_ITEM_STATUS_GENERATED, FormItemsServices.FORM_ITEM_STATUS_GENERATED));
        formAssignmentStatus.add(new SelectOption (FormItemsServices.FORM_ITEM_STATUS_SENT, FormItemsServices.FORM_ITEM_STATUS_SENT));
        formAssignmentStatus.add(new SelectOption (FormItemsServices.FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED, FormItemsServices.FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED));
    }

    public void initRoster() {
        rosterIdToEmail = new Map<String, String>();
        rosterIdToContact = new List<SelectOption>();
        rosterIdToContact.add( new SelectOption ( '', '-- None --' ) );
        for( Project_Roster__c roster : getRosters() ) {
            if (!String.isBlank(roster.Role__c)) {
                this.rosterIdToContact.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c)); //MRS-6868
                if (!rosterIdToEmail.containsKey(roster.Id)) {
                    rosterIdToEmail.put(roster.Id, roster.Email__c);
                }
            }
        }
        initRosterForTransmittal();
    }

    public void initComments() {
        comments = new List<SelectOption>();
        comments.add(new SelectOption('', '-- Select One --'));

        for( Comments_Transmittal__c item: [Select Short_Name__c, Description__c From Comments_Transmittal__c]){
            transmittalComments.put(item.Short_Name__c, item.Description__c );
        }
        List<String> transmittalNames = new List<String>();
        transmittalNames.addAll(transmittalComments.keySet());
        transmittalNames.sort();
        for (String item : transmittalNames) {
            comments.add(new SelectOption( item , item ));
        }
    }

    public PageReference saveNewFormItem() {

        if( newFormItem.Form_Name__c != null ){
            INSERT newFormItem;
        }
        newFormItem = new Form_Item__c();
        getFullWrapper();
        return null;
    }

    public PageReference cancelSaveNewFormItem (){
        newFormItem = new Form_Item__c();
        return null;
    }

    public PageReference copyFormItem() {
        List<Form_Item__c> formItemsListTemp = getFormItemsList();
        saveFormRowPosition( formItemsListTemp );

        if( formItemStatus == FormItemsServices.FORM_ITEM_STATUS_NOT_STARTED  ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You can copy only Generated Forms.'));
            return null;
        }

        Id serviceItemId;
        for( Form_Item__c formItem : formItemsListTemp ) {
            if( formItem.Id == formItemId ) {
                serviceItemId = formItem.Service_Item__c;
                break;
            }
        }

        Form_Item__c newFormItem = new Form_Item__c();
        String formRefC = '';
        for( Form_Item__c formItem : formItemsListTemp ) {
            if ( formItem.Form_Id__c == null) continue;
            if ( formItem.Service_Item__c == serviceItemId && ( formItem.Form_Id__c.contains(formRef + '_') || formItem.Form_Id__c.contains(formRef.subStringBefore('_')+'_') ) ) {
                formRefC = formItem.Form_Id__c;
            }
        }
        for( Form_Item__c formItem : formItemsListTemp ) {
            if ( formItem.Id == formItemId ){
                newFormItem = formItem.clone( false, true, false, false );
                if ( !formRefC.contains('_') ){
                    newFormItem.Form_Id__c += '_001';
                }else {
                    String suffix = String.valueOf(Integer.valueOf(formRefC.subStringAfter('_'))+1);
                    while( suffix.length() < 3 ){
                        suffix = '0' + suffix;
                    }
                    newFormItem.Form_Id__c = newFormItem.Form_Id__c.subStringBefore('_') + '_' + suffix;
                }
                newFormItem.Is_Copy__c = true;
            }
        }
        insert newFormItem;
        getFullWrapper();
        return null;
    }

    public PageReference forwardFormAssignment() {
        List<Form_Item__c> formItemsListTemp = getFormItemsList();
        saveFormRowPosition( formItemsListTemp );

        List<Form_Assignment__c> assignmentsToUpdate = new List<Form_Assignment__c>();
        for( FormWrapper wrapperItem : formWrapperList ){
            if( wrapperItem.formItemInFullWrapper.Id == formItemId ) {
                for (AssignmentWrapper formAssignmentItem : wrapperItem.formAssignments ){
                    if( formAssignmentItem.item.Status__c != FormItemsServices.FORM_ITEM_STATUS_RECEIVED_AND_VERIFIED ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot forward a form unless you receive it back from the previous receipient.'));
                        return null;
                    }
                }
				for(AssignmentWrapper aw : wrapperItem.formAssignments) { //MRS 7510
					assignmentsToUpdate.add(aw.item);
				}
            }
        }
        Form_Assignment__c formAssignment = new Form_Assignment__c();
        formAssignment.Form_Item__c = formItemId;
        formAssignment.Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;
        formAssignment.Project__c = projectProfile.Id;
        INSERT formAssignment;

        Map<Id, Id> formItemIdToServiceItemId = new Map<Id, Id>();
        Map<Id, List<Id>> serviceItemIdToTaskItemIds = new Map<Id, List<Id>>();
        for( Form_Item__c formItem : formItemsListTemp ) {
            formItemIdToServiceItemId.put( formItem.Id, formItem.Service_Item__c );
        }
        for( Task_Item__c taskItem : [ SELECT Id, Service_Item__c
                                       FROM Task_Item__c
                                       WHERE Project_Profile__c = : projectProfile.Id
                                         AND RecordType.Name = : TaskItemServices.SEND_FORMS_TASK_NAME ] ) {
            if( serviceItemIdToTaskItemIds.get( taskItem.Service_Item__c ) == null ) {
                serviceItemIdToTaskItemIds.put( taskItem.Service_Item__c, new List<Id>() );
            }
            serviceItemIdToTaskItemIds.get( taskItem.Service_Item__c ).add( taskItem.Id );
        }

        Id taskItemIdForFormItem;
        if( formItemIdToServiceItemId.get( formItemId ) != null ) {
            List<Id> taskIds = serviceItemIdToTaskItemIds.get( formItemIdToServiceItemId.get( formItemId ) );
            if( taskIds != null && !taskIds.isEmpty() ) {
                taskItemIdForFormItem = taskIds[0];
            }
        }

        UPDATE new Form_item__c( Id = formAssignment.Form_Item__c, Complete_Forms__c = taskItemIdForFormItem );
        UPDATE assignmentsToUpdate;
        getFullWrapper();
        return null;
    }

    public PageReference saveAction() {
        saveFormRowPosition();

        formAssignmentsList = new List<Form_Assignment__c>();
        for( FormWrapper wrapperItem : formWrapperList ){
			for(AssignmentWrapper aw : wrapperItem.formAssignments) {
				formAssignmentsList.add(aw.item);
			}
        }
        upsert formAssignmentsList;
        getFullWrapper();
        return null;
    }

    public void saveFormRowPosition() { // MRS 7040
        List<Form_Item__c> formsToUpdateRowPositions = new List<Form_Item__c>();

        for( FormWrapper fWrapper : formWrapperList ) {
            formsToUpdateRowPositions.add( new Form_Item__c ( Id = fWrapper.formItemInFullWrapper.Id, Form_Row_Number_For_Send_Project__c = fWrapper.formItemInFullWrapper.Form_Row_Number_For_Send_Project__c ) );
        }

        DataBase.update( formsToUpdateRowPositions, false );
    }

    public void saveFormRowPosition( List<Form_Item__c> formItemsListTemp ) {
        if( formItemsListTemp == null ) {
            formItemsListTemp = getFormItemsList();
        }
        List<Form_Item__c> formsToUpdateRowPositions = new List<Form_Item__c>();
        for( Form_Item__c formItem : formItemsListTemp ) {
            formsToUpdateRowPositions.add( new Form_Item__c( Id = formItem.Id, Form_Row_Number_For_Send_Project__c = formItem.Form_Row_Number_For_Send_Project__c ) );
        }
        DataBase.update( formItemsListTemp, false );
    }

    public void getSelectedFormItems(){
        if( selectedFormItemsList != null ) selectedFormItemsList.clear();
        if( selectedFormAssignmentsList != null ) selectedFormAssignmentsList.clear();
        for( FormWrapper wrapperItem : formWrapperList ){
            if( wrapperItem.isSelected && wrapperItem.formItemInFullWrapper.Id != null ) {
                wrapperItem.formItemInFullWrapper.Quantity_For_Transmittal__c = 1;
                selectedFormItemsList.add( wrapperItem.formItemInFullWrapper );
                Form_Assignment__c formAssignment = wrapperItem.formAssignments[0].item; //MRS 7510
                selectedFormAssignmentsList.add( formAssignment );
                rosterId = formAssignment.Recipient_Role__c;
                selectedIdRolesSet.add( formAssignment.Recipient_Role__c );
            }
        }
    }

    public void printPendingForms(){
        saveFormRowPosition();

        selectedIdRolesSet.clear();
        getSelectedFormItems();
        if( selectedFormItemsList == null || selectedFormItemsList.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select at least one Form Item.'));
        } /* MRS-6636
          else if( selectedIdRolesSet.size() > 1 ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please make sure that Recipient Role fields match for forms you want to send under one transmittal.'));
        } else if( rosterId == null ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please make sure to select Recipient Role for forms you want to send.'));
        } */
          else {
            for( Form_Assignment__c item: selectedFormAssignmentsList) {
                if( item.Sent_Date__c != null && item.Sent_VIA__c != null ) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This form has already been sent. Please provide the tracking information and then forward.'));
                    isPrintPendingFormsPanel = false;
                    return;
                }
                if( item.Sent_VIA__c != null ) {
                    if( transmittal.VIA__c != null && item.Sent_VIA__c != transmittal.VIA__c ) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please choose only one sent VIA type.'));
                        isPrintPendingFormsPanel = false;
                        return;
                    }
                    transmittal.VIA__c = item.Sent_VIA__c;
                }
            }
            List<Project_Roster__c> rostersTemp = getRosters();
            for( Form_Item__c selectedFormItem: selectedFormItemsList ) {
                if( selectedFormItem.Form_Status__c != FormItemsServices.FORM_ITEM_STATUS_GENERATED ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This form is not ready for sending. Please fill it out first or check the Form Status in Form Tracking Section.'));
                    isPrintPendingFormsPanel = false;
                    return;
                } else {
                    isPrintPendingFormsPanel = true;
                    rosterSendToAction( rostersTemp );
                    rosterReplyToAction( rostersTemp );
                }
            }
            for( Project_Roster__c item : rostersTemp ) {
                if( userInfo.getUserId() == item.User__c ) {
                    rosterReplyToId = item.Id;
                    rosterForTransmittalReplyTo = item;
                    break;
                }
            }
        }
    }

    public void initRosterForTransmittal() {
        wrapoutRosters.add( new rosterWrapper( null, new Project_Roster__c() ) );
    }

    //MRS-6636
    public PageReference changeSendToAction() {
        list<Form_Assignment__c> formAssignmentUpdateList = new List<Form_Assignment__c>();
        for(Form_Item__c selectedFormItem: selectedFormItemsList){
            for(Form_Assignment__c formAssignmentItem : selectedFormItem.Form_Assignments__r){
                formAssignmentUpdateList.add(new Form_Assignment__c(id = formAssignmentItem.Id, Recipient_Role__c = rosterId));
            }
        }
        try {
            update formAssignmentUpdateList;
        } catch(DmlException e){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Recipient Role: ' + String.valueOf(e) ) );
            return null;
        }

        return null;
    }

    public PageReference rosterSendToAction() {
        return rosterSendToAction( null );
    }

    public PageReference rosterSendToAction( List<Project_Roster__c> rostersTemp ) {
        if( rostersTemp == null ) {
            rostersTemp = getRosters();
        }
        for( Project_Roster__c item : rostersTemp ) {
            if( rosterId == item.Id ){
                rosterForTransmittalSendTo = item;
                break;
            }
        }
        return null;
    }

    public PageReference rosterReplyToAction() {
        return rosterReplyToAction( null );
    }

    public PageReference rosterReplyToAction( List<Project_Roster__c> rostersTemp ) {
        if( rostersTemp == null ) {
            rostersTemp = getRosters();
        }
        rosterForTransmittalReplyTo = null;
        for( Project_Roster__c item : rostersTemp ) {
            if( rosterReplyToId == item.Id ) {
                rosterForTransmittalReplyTo = item;
                break;
            }
        }
        return null;
    }

    public PageReference rosterCCToAction() {
        return rosterCCToAction( null );
    }

    public PageReference rosterCCToAction( List<Project_Roster__c> rostersTemp ) {
        if( rostersTemp == null ) {
            rostersTemp = getRosters();
        }
        for( Project_Roster__c item : rostersTemp ) {
            for( rosterWrapper itemWrapper: wrapoutRosters) {
                if( itemWrapper.rosterIdCCToInWrapper == item.Id ) {
                    itemWrapper.rosterForTransmittal = item;
                    break;
                }
            }
        }

        for( Integer j = 0; j < wrapoutRosters.size(); j++ ) {

           if( wrapoutRosters.get(j).rosterForTransmittal.Id == null || wrapoutRosters.get(j).rosterIdCCToInWrapper == null) {
               wrapoutRosters.remove(j);
               break;
           }
        }
        return null;
    }

    public PageReference addCCToRoster() {
        wrapoutRosters.add( new rosterWrapper( null, new Project_Roster__c() ) );
        return null;
    }

    public Boolean disableAddCCButton{
        get{
            disableAddCCButton = false;
            for (rosterWrapper itemWrapper: wrapoutRosters) {
                if (itemWrapper.rosterForTransmittal == null || itemWrapper.rosterForTransmittal.Id == null) {
                    disableAddCCButton = true;
                    break;
                }
            }
            return disableAddCCButton;
        }
        set;
    }

    private List<String> attachIds = new List<String>();

    public void saveTransmittalAction() {
        if ( rosterId == null ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Please populate "Send to" value' ) );
            return;
        }


        Map<Id, Form_Item__c> idToSelectedFormItem = new Map<Id, Form_Item__c>();
        List<Form_Item__c> formItemsListForUpdateLookupTransmittal = new List<Form_Item__c>();
        List<Form_Assignment__c> formAssignmentUpdateList = new List<Form_Assignment__c>();

        filledOutTransmittalRecord();

        for (Form_Assignment__c formAssignmentItem : selectedFormAssignmentsList){
            formAssignmentUpdateList.add( new Form_Assignment__c (Id = formAssignmentItem.Id,
                                                                  Sent_VIA__c = transmittal.VIA__c,
                                                                  Sent_Date__c = DateTime.now(),
                                                                  Status__c = FormItemsServices.FORM_ITEM_STATUS_SENT,
                                                                  Recipient_Role__c = rosterId ));//MRS-6636
        }
        try {
            upsert formAssignmentUpdateList;
        } catch( dmlException e ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Form Assignment: ' + String.valueOf(e) ) );
            return;
        }

        try {
            upsert transmittal;
        } catch( dmlException e ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Transmittal: ' + String.valueOf(e) ) );
            return;
        }

        for( Form_Item__c selectedFormItem : selectedFormItemsList ) {
            idToSelectedFormItem.put( selectedFormItem.Id, selectedFormItem );
        }

        Map<Id, Id> fiIdTofmdoId = new Map<Id, Id>();
        Map<Id, Id> fmdoIdToDocId = new Map<Id, Id>();
        for( Form_Meta_Data_Object_1__c fmdo : [ Select Id, Form_Item__c, Form_Item__r.Quantity_For_Transmittal__c From Form_Meta_Data_Object_1__c
                                                 Where Form_Item__c IN : idToSelectedFormItem.keySet() ] ){
            fiIdTofmdoId.put( fmdo.Form_Item__c, fmdo.Id );
        }

        for( LStore__Stored_Document__c item: [ SELECT Related_Object_Id__c, Id
                                                FROM LStore__Stored_Document__c
                                                WHERE RecordTypeId != : StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                                    AND Related_Object_Id__c IN : fiIdTofmdoId.values() ]){
            fmdoIdToDocId.put( item.Related_Object_Id__c, item.Id );
        }

        List<Form_Item__c> formItemsListTemp = getFormItemsList();
        for( Form_Item__c formItem : formItemsListTemp ) {
            if( idToSelectedFormItem.get(formItem.Id) != null && formItem.Id == idToSelectedFormItem.get(formItem.Id).Id ) {
                formItem.Transmittal__c = transmittal.Id;
                if( formItem.Quantity_For_Transmittal__c != null && formItem.Quantity_For_Transmittal__c >= 1 ) {
                    for( Integer q = 0; q < formItem.Quantity_For_Transmittal__c; q++ ) {
                        attachIds.add( fmdoIdToDocId.get( fiIdTofmdoId.get( formItem.Id ) ) );
                    }
                }
            } else {
                formItem.Transmittal__c = null;
            }
            formItemsListForUpdateLookupTransmittal.add(formItem);
        }

        try {
            UPSERT formItemsListForUpdateLookupTransmittal;
        } catch( dmlException e ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Transmittal: ' + String.valueOf(e) ) );
            return;
        }

        initDdpHelpers();
    }

    public void attachPDF() {
        try {
            DDPEmailServices.generateAndAttachPDF( projectProfile.Id, DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT_TASK_ITEMS_FOR_PROJECT, null, null, null, attachIds);
            //DDPEmailServices.generateAndAttachPDF( taskItem.Id, DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT, null, null, null, attachIds);
        } catch( Exception ex ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Generating and Attaching PDF File: ' + ex.getMessage() ) );
            return;
        }
    }

    public void initDdpHelpers() {
        List<DDP_Helper__c> existingHelpers = [ SELECT Id
                                                FROM DDP_Helper__c
                                                WHERE Project_Profile__c =: projectProfile.Id AND
                                                      Type__c = : TYPE_NAME ];
        if( !existingHelpers.isEmpty() ) {
            DELETE existingHelpers;
        }

        List<DDP_Helper__c> newHelpers = new List<DDP_Helper__c>();
        if( !selectedFormItemsList.isEmpty() ) {
            for( Form_Item__c selectedFormItem : selectedFormItemsList ) {
                newHelpers.add( new DDP_Helper__c( Project_Profile__c = projectProfile.Id,
                                                   Type__c = TYPE_NAME,
                                                   Quantity__c = selectedFormItem.Quantity_For_Transmittal__c,
                                                   Artifact_Id__c = selectedFormItem.Short_Form_Name__c,
                                                   Artifacts__c = selectedFormItem.Form_Name__c ) );

            }
            INSERT newHelpers;
        }
    }

    public void filledOutTransmittalRecord(){

        if ( rosterForTransmittalSendTo.Name__c != null ) {
            transmittal.Send_To_Name__c = rosterForTransmittalSendTo.Name__c;
        }

        if( rosterForTransmittalSendTo.Company_Name__c != null ) transmittal.Send_To__c += rosterForTransmittalSendTo.Company_Name__c;
        if( rosterForTransmittalSendTo.Contact_Mailing_Street__c != null ) transmittal.Send_To_Street__c += rosterForTransmittalSendTo.Contact_Mailing_Street__c;

        if( rosterForTransmittalSendTo.Contact_Mailing_City__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_City__c + ', ';
        if( rosterForTransmittalSendTo.Contact_Mailing_State_Province__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_State_Province__c + ' ';
        if( rosterForTransmittalSendTo.Contact_Mailing_Zip_Postal_Code__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_Zip_Postal_Code__c + ', ';
        if( !String.isBlank(transmittal.Send_To_Address__c) ) transmittal.Send_To_Address__c = transmittal.Send_To_Address__c.removeEnd(', ');

        if ( rosterForTransmittalReplyTo != null ){
            if( rosterForTransmittalReplyTo.Name__c != null ) transmittal.Reply_To__c += rosterForTransmittalReplyTo.Name__c + ', ';
            if( rosterForTransmittalReplyTo.Role__c != null ) transmittal.Reply_To__c += rosterForTransmittalReplyTo.Contact_Title__c;

        }

        for( rosterWrapper item: wrapoutRosters){
            if( item.rosterForTransmittal.Id != null ){
                if( item.rosterForTransmittal.Name__c != null ) transmittal.CC_To__c += item.rosterForTransmittal.Name__c  + ', ';
                if( item.rosterForTransmittal.Company_Name__c != null ) transmittal.CC_To__c += item.rosterForTransmittal.Company_Name__c;
                if( item.rosterForTransmittal.Company_Address__c != null ) transmittal.CC_To__c += '\n' + item.rosterForTransmittal.Company_Address__c  + ', '; // MRS 7181
                transmittal.CC_to__c = transmittal.CC_to__c.trim().removeEnd(',') + '; ';
            }
        }
        if( transmittal.CC_to__c != null ) transmittal.CC_to__c = transmittal.CC_to__c.trim().removeEnd(';');

        Integer transmittalNumber = Integer.valueOf( [SELECT MAX(Number__c) FROM Transmittal__c WHERE Project_Profile__c = : projectProfile.Id][0].get('expr0') );
        transmittal.Number__c = transmittalNumber == null ? 1 : transmittalNumber + 1;
        transmittal.Comments__c = transmittalComments.get( commentsShortName );

    }

    public void cancelAction(){
        isPrintPendingFormsPanel = false;
        isShippingRequestPanel = false;
        transmittal = null;
        rosterReplyToId = null;
        rosterReplyToAction();
        wrapoutRosters.clear();
        initRosterForTransmittal();
    }

    public PageReference sendFormItems() {
        saveFormRowPosition();

        selectedIdRolesSet.clear();
        getSelectedFormItems();
        if( selectedFormItemsList == null || selectedFormItemsList.isEmpty() ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Forms specified for emailing.'));
            return null;
        }else if( selectedIdRolesSet.size() > 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please make sure that Recipient Role fields match for forms you want to send under one transmittal.'));
            return null;
        }else if( rosterId == null ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please make sure to select Recipient Role for forms you want to send.'));
            return null;
        }else{
            for( Form_Assignment__c item: selectedFormAssignmentsList){
                if( item.Sent_Date__c != null && item.Sent_VIA__c != null ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This form has already been sent. Please provide the tracking information and then forward.'));
                    isPrintPendingFormsPanel = false;
                    return null;
                }
            }
            for( Form_Item__c selectedFormItem: selectedFormItemsList ){
                if( selectedFormItem.Form_Status__c != FormItemsServices.FORM_ITEM_STATUS_GENERATED ){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This form is not ready for sending. Please fill it out first or check the Form Status in Form Tracking Section.'));
                    return null;
                }
            }
        }
        String formIds = '';

        for( FormWrapper wrapperItem : formWrapperList ){
            if (wrapperItem.isSelected) {
                formIds += wrapperItem.formItemInFullWrapper.Id + ',';
            }
        }
        PageReference page = new PageReference('/apex/SendFormOutboundEmailProject');
        page.getParameters().put( 'projectId', projectProfile.Id );
        //page.getParameters().put( 'serviceItemId', this.taskItem.Service_Item__c );
        //page.getParameters().put( 'taskItemId', this.taskItem.Id );
        page.getParameters().put( 'formIds', formIds );

        page.setRedirect(true);
        return page;

    }

    public void shippingRequestAction(){
        if ( rosterId == null ){
            ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Please populate "Send to" value' ) );
            return;
        }

        shippingRequest.Requested_By__c = UserInfo.getName();
        shippingRequest.Shipping_Method__c = transmittal.VIA__c;
        shippingRequest.MRC_Reference__c = projectProfile.Name;
        shippingRequest.Send_To_Name__c = rosterForTransmittalSendTo.Name__c;
        shippingRequest.Send_To_Company__c = rosterForTransmittalSendTo.Company_Name__c;
        shippingRequest.Phone__c = rosterForTransmittalSendTo.Contact__r.Phone;
        shippingRequest.Address__c = rosterForTransmittalSendTo.Company_Address__c;
        shippingRequest.Date__c = Datetime.Now();

        for( rosterWrapper item: wrapoutRosters){
            if( item.rosterForTransmittal.Id != null ){
                if( item.rosterForTransmittal.Name__c != null ) shippingRequest.CC_To_Name__c = item.rosterForTransmittal.Name__c;
                if( item.rosterForTransmittal.Company_Name__c != null ) shippingRequest.CC_To_Company__c = item.rosterForTransmittal.Company_Name__c;
                if( item.rosterForTransmittal.Company_Address__c != null ) shippingRequest.CC_Address__c = item.rosterForTransmittal.Company_Address__c;
                if( item.rosterForTransmittal.Contact__r.Phone != null ) shippingRequest.CC_Phone__c = item.rosterForTransmittal.Contact__r.Phone;
                break;
            }
        }
        isPrintPendingFormsPanel = false;
        isShippingRequestPanel = true;

        saveTransmittalAction();

    }

    public void sendShippingRequestAction(){
        insert shippingRequest;
        isShippingRequestPanel = false;
    }

    public void cancelFromShipping() {
        isShippingRequestPanel = false;
        isPrintPendingFormsPanel = false;
    }

}