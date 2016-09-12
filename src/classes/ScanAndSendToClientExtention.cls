public with sharing class ScanAndSendToClientExtention{
    private final String TASK_ITEM_FUNCTIONALITY_OBJECT_NAME = 'Task_Item_Functionality__c';
    private String SHIPPING_RECORD_TYPE_FROM_TASK_NAME = 'From Task';
    private final String SHIPPING_REQUEST_OBJECT_NAME = 'Shipping_Request__c';
    private final String RECORD_TYPE_NAME = 'Scan and Send to Client';
    public final Task_Item__c taskItem { get; set; }
    public String emailTypeRecord { get{ return MergeEmailTemplate.STANDARD_PARSING_EMAIL; } set; }
    private Id transmittalCreator;

    public Boolean disabledButton { get { return (showTransmittalEditor || showTemplateEditor || isShippingRequestPanel ); } set;}

    public Boolean isInactiveService {
        get {
            return this.taskItem.Service_Item__r.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE;
        }
        set;
    }

    private RecordType recordTypeRecord {
        get{
            if ( recordTypeRecord == null ){
                List<RecordType> recordTypes = new List<RecordType>([Select Id From RecordType where SobjectType =: TASK_ITEM_FUNCTIONALITY_OBJECT_NAME AND Name =: RECORD_TYPE_NAME LIMIT 1]);
                recordTypeRecord = recordTypes.isEmpty() ? new RecordType() : recordTypes[0];
            }
            return recordTypeRecord;
        }
        set;
    }
    private RecordType recordTypeShippingRequest {
        get{
            if ( recordTypeShippingRequest == null ){
                List<RecordType> recordTypes = new List<RecordType>([Select Id From RecordType where SobjectType =: SHIPPING_REQUEST_OBJECT_NAME AND Name =: SHIPPING_RECORD_TYPE_FROM_TASK_NAME LIMIT 1]);
                recordTypeShippingRequest = recordTypes.isEmpty() ? new RecordType() : recordTypes[0];
            }
            return recordTypeShippingRequest;
        }
        set;
    }
    public Boolean isShippingRequestPanel { get{if(isShippingRequestPanel == null) isShippingRequestPanel = false; return isShippingRequestPanel;} set; }
    public Shipping_Request__c shippingRequest{
        get {
            if ( shippingRequest == null ){
                shippingRequest = new Shipping_Request__c( Task_Item__c = taskItem.Id, MRC_Reference__c = projectProfileItem.Name, RecordTypeId = recordTypeShippingRequest.Id );
            }
            return shippingRequest;
        } set;
    }

    public Map<Id, Task_Item_Functionality__c> scanAndSaveDataMap {get{ return new Map<Id, Task_Item_Functionality__c>( scanAndSaveDataRows );} set;}
    public List<Task_Item_Functionality__c> scanAndSaveDataRows {get; set;}

    public Project_Profile__c projectProfileItem {
        get {
            if (null == this.projectProfileItem) {
                this.projectProfileItem = ProjectProfileServices.getProjectById(taskItem.Project_Profile__c);
        }
            return this.projectProfileItem;
        }
        set;
    }

    public List<String> recordsForAttachmentsIds {get{ return new List<String>{taskItem.Id, taskItem.Service_Item__c, taskItem.Project_Profile__c}; } set;}

    public String linkToCloseTemplate { get; private set;}
    
     public Contact contactRecipient { 
        get {
            if (null == this.contactRecipient) {
                this.contactRecipient = new Contact();
                
            }
            return this.contactRecipient;
        
        } 
        set; 
    }
    
    public ScanAndSendToClientExtention (ApexPages.StandardController controller) {
        this.taskItem            = (Task_Item__c)controller.getRecord();
        this.linkToCloseTemplate =  '/' + String.valueOf(this.taskItem.Id);

        initRoster();
        initScanAndSaveDataRows();
        initComments();

    }

    private void initScanAndSaveDataRows() {
        scanAndSaveDataRows = new List<Task_Item_Functionality__c>([SELECT Id, Name, Use_Alert__c, Task_Item__c, Sent_VIA__c, Sent_Tracking__c, Sent_Date_Time__c, Quantity__c,
                                                                                    Received_VIA__c, Received_Tracking__c, Received_Date_Time__c, Project_Roster__c, Project_Roster_Name__c,
                                                                                    Is_Email_Sent__c, Artifacts__c, Alert_Time__c, Email_To__c, Email_To_CC__c, Artifact_Id__c,  Project_Roster__r.Contact__c 
                                                                                FROM Task_Item_Functionality__c
                                                                                WHERE Task_Item__c =: taskItem.Id
                                                                                AND RecordTypeId =: recordTypeRecord.Id ORDER BY CreatedDate]);
    }

    /* Table Rows Functionality ----------------------------------------------------------------------------------------------------- */
    public String scanAndSaveItemId {get; set;}
    public void updateDataRowsAction (){
        try {
            for( Task_Item_Functionality__c item: scanAndSaveDataRows){
                item.Is_Email_Sent__c = false;
            }
            upsert scanAndSaveDataRows;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        initScanAndSaveDataRows();
    }
    public void deleteDataRowAction (){
        try {
            delete scanAndSaveDataMap.get( scanAndSaveItemId );
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
            return;
        }
        initScanAndSaveDataRows();
    }
    public void addNewDataRowAction (){
        Task_Item_Functionality__c scanAndSaveRecord = new Task_Item_Functionality__c( Task_Item__c = taskItem.Id, RecordTypeId = recordTypeRecord.Id );
        try {
            insert scanAndSaveRecord;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        scanAndSaveDataRows.add( scanAndSaveRecord );
    }
    /* End Table Rows Functionality ----------------------------------------------------------------------------------------------------- */
    private Set<String> contactsNames;
    private Set<String> viaNames;
    public Map<Id, Task_Item_Functionality__c> recordsToSendMap {get; set;}
    public void populateRecordsToSendMap(){
        recordsToSendMap = new Map<Id, Task_Item_Functionality__c>();
        contactsNames = new Set<String>();
        viaNames = new Set<String>();
        for( Task_Item_Functionality__c recordItem: scanAndSaveDataRows ){
            if( recordItem.Is_Email_Sent__c ){
                recordsToSendMap.put( recordItem.Id, recordItem );
                contactsNames.add( recordItem.Project_Roster_Name__c );
                viaNames.add( recordItem.Sent_VIA__c );
                rosterId = recordItem.Project_Roster__c;
            }
        }
    }
    /* Email Functionality -------------------------------------------------------------------------------------------------------------- */
    public String DDPName {get{ return DDPEmailServices.DDP_NAME_TASK_ITEM_FUNCTIONALITY;}}
    public String draftTemplateName {get{ return 'Task Item Functionality Draft';}}
    public String emailTemplateName {get{ return 'Task Item Functionality';}}
    public Id recordToSendEmailId {
        get{
            recordToSendEmailId = null;
            for( Task_Item_Functionality__c recordItem: scanAndSaveDataRows ){
                if( recordItem.Sent_VIA__c == ManageResponseFromAuthorityServices.SENT_VIA_EMAIL && recordItem.Is_Email_Sent__c){
                    recordToSendEmailId = recordItem.Id;
                    break;
                }
            }
            return recordToSendEmailId;
        }
        set;
    }
    public Task_Item_Functionality__c recordToSendEmail {
        get{
            return scanAndSaveDataMap.containsKey(recordToSendEmailId) ? scanAndSaveDataMap.get(recordToSendEmailId) : new Task_Item_Functionality__c();
        }
        set;
    }

    public Boolean showTemplateEditor {get{if(showTemplateEditor == null) showTemplateEditor = false; return showTemplateEditor;}  set;}
    
    public void previewEmailForCurrentRecordAction() {
        //Checking if recipient is Contact.
        for (Task_Item_Functionality__c recordItem: scanAndSaveDataRows) {
            if (recordItem.Is_Email_Sent__c && null == recordItem.Project_Roster__r.Contact__c) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT));
                return;
            
            } else if (recordItem.Is_Email_Sent__c && null != recordItem.Project_Roster__r.Contact__c) {
                this.contactRecipient.Id = recordItem.Project_Roster__r.Contact__c;
                
            }
        
        }
        
        populateRecordsToSendMap();
        if( recordsToSendMap.isEmpty() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are no records to send Email( \'VIA\' should be Email and \'Sent Email\' should be checked)'));
            return;
        }
        for( Task_Item_Functionality__c item: recordsToSendMap.values() ){
            if( item.Sent_VIA__c != ManageResponseFromAuthorityServices.SENT_VIA_EMAIL && item.Is_Email_Sent__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please specify \'VIA\' as \'Email\' value'));
                return;
            }
            if( String.isBlank( item.Artifacts__c ) || String.isBlank( item.Project_Roster__c ) ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please specify \'Artifacts\' and \'Roles\' fields for current record(s) in order to send Email'));
                return;
            }
        }
        if( contactsNames.size() > 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please make sure the recipient for multiple items is the same.'));
            return;
        }
        if( viaNames.size() > 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please make sure Via field is the same for all selected items.'));
            return;
        }

        showTemplateEditor = true;
        showTransmittalEditor = false;
    }

    public String emailsToDDP {get; set;}
    public void updateRecordCCField(){
        if( !String.isBlank(emailsToDDP) ){
            try {
                for( Task_Item_Functionality__c item: recordsToSendMap.values() ){
                    item.Email_To_CC__c = emailsToDDP;
                }
                update recordsToSendMap.values();
            } catch(Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Emails were not added to CC! Please try again!'));
                return;
            }
        }
    }
    public void updateRecordToSendEmail(){
        try{
            for ( Task_Item_Functionality__c item : scanAndSaveDataRows ){
                if (!recordsToSendMap.containsKey(item.Id)){
                    item.Is_Selected_Artifact__c = false;
                }
            }
            for( Task_Item_Functionality__c item: recordsToSendMap.values() ){
                item.Sent_Date_Time__c = datetime.now();
                item.Is_Email_Sent__c = false;
                item.Is_Selected_Artifact__c = true;
            }
            upsert scanAndSaveDataRows;
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occured during sending email: ' + ex.getMessage()));
            return;
        }
        initScanAndSaveDataRows();
    }

    /* End Email Functionality -------------------------------------------------------------------------------------------------------------- */
    public class rosterWrapper {
        public Id rosterIdCCToInWrapper { get; set; }
        public Project_Roster__c rosterForTransmittal { get; set; }

        public rosterWrapper( Id rosterIdCCToInWrapper, Project_Roster__c rosterForTransmittal ) {
            rosterIdCCToInWrapper = rosterIdCCToInWrapper;
            rosterForTransmittal = rosterForTransmittal;
        }
    }

    public List<rosterWrapper> wrapoutRosters {
        get {
            if(wrapoutRosters == null) wrapoutRosters = new List<rosterWrapper>();
            return wrapoutRosters;
        } set;
    }

    public void initRosterForTransmittal() {
        wrapoutRosters.add( new rosterWrapper( null, new Project_Roster__c() ) );
    }

    public PageReference rosterSendToAction() {
        for (Project_Roster__c item : this.projectRosters) {
            if (rosterId == item.Id) {
                rosterForTransmittalSendTo = item;
                break;

            }

        }
        return null;

    }

    public PageReference rosterReplyToAction() {
        rosterForTransmittalReplyTo = null;

        for (Project_Roster__c item: this.projectRosters) {
            if (rosterReplyToId == item.Id) {
                rosterForTransmittalReplyTo = item;
                break;

            }

        }
        return null;

    }

    public PageReference rosterCCToAction() {
        for (Project_Roster__c item: this.projectRosters) {
            for (rosterWrapper itemWrapper: wrapoutRosters) {
                if (itemWrapper.rosterIdCCToInWrapper == item.Id) {
                    itemWrapper.rosterForTransmittal = item;
                    break;

                }

            }

        }

        /*System.debug('### wrapoutRosters=' + wrapoutRosters);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, String.valueOf(wrapoutRosters)));
        return null;*/
        for( Integer j = 0; j < wrapoutRosters.size(); j++ ) {

           if( (wrapoutRosters.get(j).rosterForTransmittal != null && wrapoutRosters.get(j).rosterForTransmittal.Id == null) || wrapoutRosters.get(j).rosterIdCCToInWrapper == null) {
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
                if (itemWrapper.rosterForTransmittal == null ) {
                    disableAddCCButton = true;
                    break;
                }
            }
            return disableAddCCButton;
        }
        set;
    }

    public Id rosterReplyToId { get; set; }
    public Id rosterId { get; set; }
    public Project_Roster__c rosterForTransmittalSendTo { get { if( rosterForTransmittalSendTo == null ) rosterForTransmittalSendTo = new Project_Roster__c(); return rosterForTransmittalSendTo; } set; }
    public Project_Roster__c rosterForTransmittalReplyTo { get { if( rosterForTransmittalReplyTo == null ) rosterForTransmittalReplyTo = new Project_Roster__c(); return rosterForTransmittalReplyTo; } set; }
    public Map<String, String> rosterIdToEmail { get; set; }
    public List<SelectOption> rosterIdToContact { get; set; }

    public void initRoster() {
        rosterIdToEmail = new Map<String, String>();
        rosterIdToContact = new List<SelectOption>();
        rosterIdToContact.add(new SelectOption ('', '-- None --'));

        for (Project_Roster__c roster : this.projectRosters) {
            if (!String.isBlank(roster.Role__c)) {
                this.rosterIdToContact.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c)); //MRS-6868

                if (!rosterIdToEmail.containsKey(roster.Id)) {
                    rosterIdToEmail.put(roster.Id, roster.Email__c);

                }

            }

        }
        initRosterForTransmittal();

    }

    public List<SelectOption> rosterIdToRoleOptions {
        get {
            if (null == this.rosterIdToRoleOptions) {
                this.rosterIdToRoleOptions = new List<SelectOption>();
                this.rosterIdToRoleOptions.add(new SelectOption ('', '-- None --'));

                for (Project_Roster__c roster : this.projectRosters) {
                    if (!String.isBlank(roster.Role__c)) {
                        this.rosterIdToRoleOptions.add(new SelectOption(roster.Id, (roster.Role__c + ' - ' + roster.Name__c), !roster.Active__c)); //MRS-6868

                    }

                }

            }
            return this.rosterIdToRoleOptions;

        }
        private set;

    }

    /* Transmittal --------------------------------------------------------------------------------------------------------------------------- */
    public String commentsShortName { get; set; }
    private Map<String, String> transmittalComments = new Map<String, String>();
    public Boolean showTransmittalEditor {get{if(showTransmittalEditor == null) showTransmittalEditor = false; return showTransmittalEditor;}  set;}

    public Transmittal__c transmittal {
        get{
            if (transmittal == null ){
                transmittal = new Transmittal__c( Task_Item__c = taskItem.Id, CC_to__c = '', Reply_To__c = '', Comments__c = '', Send_To_Address__c = '',  Send_To_Street__c = '',
                                                  Resubmit__c = null, Return__c = null, Send_To__c = '', Submit__c = null, VIA__c = null, Other__c = null, Additional_Comments__c = '',
                                                  Fulfillment_Office_Address__c = '', Fulfillment_Office_Street__c = '', Fulfillment_Office_Phone__c = '', Fulfillment_Office_Fax__c = '' );
                for( Transmittal__c item: [Select Id, CreatedById From Transmittal__c Where Task_Item__c =: taskItem.Id limit 1]){
                    transmittal.Id = item.Id;
                }

                transmittalCreator = UserInfo.getUserId();

                FulfillmentOfficeAddresses__c fulfillmentOffice = FulfillmentOfficeAddresses__c.getValues(this.projectProfileItem.Fulfillment_Office__c);

                if ( fulfillmentOffice != null ){
                    if ( fulfillmentOffice.City__c != null ) transmittal.Fulfillment_Office_Address__c = fulfillmentOffice.City__c;
                    if ( fulfillmentOffice.Street__c != null ) transmittal.Fulfillment_Office_Street__c = fulfillmentOffice.Street__c;
                    if ( fulfillmentOffice.Phone__c != null ) transmittal.Fulfillment_Office_Phone__c = fulfillmentOffice.Phone__c;
                    if ( fulfillmentOffice.Fax__c != null ) transmittal.Fulfillment_Office_Fax__c = fulfillmentOffice.Fax__c;
                }
            }
            return transmittal;
        }
        set;
    }


    public Map<String, ProjectRosterWrapper> nameToRosterMap {
        get {
            if (null == this.nameToRosterMap) {
                this.nameToRosterMap = new Map<String, ProjectRosterWrapper>();

                for (Project_Roster__c roster : this.projectRosters) {
                    this.nameToRosterMap.put(roster.Name__c, new ProjectRosterWrapper(roster.Name__c, roster.Email__c));

                }

            }
            return this.nameToRosterMap;
        }
        set;
    }

    private List<Project_Roster__c> projectRosters {
        get {
            if (null == this.projectRosters) {
                this.projectRosters = ProjectRosterServices.getRosterByProjectId(taskItem.Project_Profile__c);

            }
            return this.projectRosters;

        }
        set;
    }

    public List<SelectOption> comments { get; set; }
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

    public void previewTransmittal(){
        populateRecordsToSendMap();
        if( recordsToSendMap.isEmpty() ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'There are no records to create Transmittal( \'Sent Email\' should be checked)'));
            return;
        }
        if( contactsNames.size() > 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please make sure the recipient for multiple items is the same.'));
            return;
        }
        if( viaNames.size() > 1 ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please make sure Via field is the same for all selected items.'));
            return;
        }
        for( Task_Item_Functionality__c item: recordsToSendMap.values() ){
            if( String.isBlank( item.Artifacts__c ) || String.isBlank( item.Project_Roster__c ) ){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please specify \'Artifacts\' and \'Roles\' fields for current record(s) in order to create Transmittal'));
                return;
            }
            if( item.Sent_VIA__c == null ) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please choose some sent VIA type.'));
                return;
            }else{
                transmittal.VIA__c = item.Sent_VIA__c;
            }
        }
        rosterSendToAction();
        rosterReplyToAction();

        for (Project_Roster__c item: this.projectRosters) {
            if (userInfo.getUserId() == item.User__c) {
                rosterReplyToId = item.Id;
                rosterForTransmittalReplyTo = item;
                break;

            }

        }

        showTransmittalEditor = true;
        showTemplateEditor = false;


    }


    public void filledOutTransmittalRecord(){

        if (rosterForTransmittalSendTo.Name__c != null) {
            transmittal.Send_To_Name__c = rosterForTransmittalSendTo.Name__c;
        }

        if(rosterForTransmittalSendTo.Company_Name__c != null) transmittal.Send_To__c += rosterForTransmittalSendTo.Company_Name__c;

        if( rosterForTransmittalSendTo.Contact_Mailing_Street__c != null ) transmittal.Send_To_Street__c += rosterForTransmittalSendTo.Contact_Mailing_Street__c;

        if( rosterForTransmittalSendTo.Contact_Mailing_City__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_City__c + ', ';
        if( rosterForTransmittalSendTo.Contact_Mailing_State_Province__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_State_Province__c + ' ';
        if( rosterForTransmittalSendTo.Contact_Mailing_Zip_Postal_Code__c != null ) transmittal.Send_To_Address__c += rosterForTransmittalSendTo.Contact_Mailing_Zip_Postal_Code__c + ', ';
        if( !String.isBlank(transmittal.Send_To_Address__c) ) transmittal.Send_To_Address__c = transmittal.Send_To_Address__c.removeEnd(', ');

        if( rosterForTransmittalReplyTo != null ){
            transmittal.Reply_To__c += !String.isBlank(rosterForTransmittalReplyTo.Name__c) ? rosterForTransmittalReplyTo.Name__c + ', ': '';
            transmittal.Reply_To__c += !String.isBlank(rosterForTransmittalReplyTo.Contact_Title__c) ? rosterForTransmittalReplyTo.Contact_Title__c : '';
        }

        for( rosterWrapper item: wrapoutRosters){
            if( item.rosterForTransmittal != null && item.rosterForTransmittal.Id != null ){
                if(item.rosterForTransmittal.Name__c != null) transmittal.CC_To__c += item.rosterForTransmittal.Name__c  + ', ';
                if(item.rosterForTransmittal.Company_Name__c != null) transmittal.CC_To__c += item.rosterForTransmittal.Company_Name__c;
                if(item.rosterForTransmittal.Company_Address__c != null) transmittal.CC_To__c += '\n' + item.rosterForTransmittal.Company_Address__c  + ', '; // MRS 7181
                transmittal.CC_to__c = transmittal.CC_to__c.trim().removeEnd(',') + '; ';
            }
        }
        if( transmittal.CC_to__c != null ) transmittal.CC_to__c = transmittal.CC_to__c.trim().removeEnd(';');

        Integer transmittalNumber = Integer.valueOf( [SELECT MAX(Number__c) FROM Transmittal__c WHERE Task_Item__c = : taskItem.Id][0].get('expr0') );
        transmittal.Number__c = transmittalNumber == null ? 1 : transmittalNumber + 1;
        transmittal.Comments__c = transmittalComments.get( transmittal.Comments__c );

    }

    public void cancelAction(){
        showTransmittalEditor = false;
        showTemplateEditor = false;
        isShippingRequestPanel = false;
        transmittal = null;
        wrapoutRosters.clear();
        initRosterForTransmittal();
    }

    List<Id> attachIds;

    public void saveTransmittal(){

        filledOutTransmittalRecord();

        try {
            upsert transmittal;
        } catch( dmlException e ) {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Transmittal: ' + String.valueOf(e) ) );
            return;
        }
        updateRecordToSendEmail();
    }

    public void attachPDF() {
        try {
            DDPEmailServices.generateAndAttachPDF( taskItem.Id, DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT, null, null, null, attachIds);
        } catch( Exception ex ) {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Generating and Attaching PDF File: ' + ex.getMessage() ) );
            return;
        }
    }
    /* End Transmittal --------------------------------------------------------------------------------------------------------------------------- */

    public void shippingRequestAction(){
        shippingRequest.Requested_By__c = rosterForTransmittalReplyTo.Name__c;
        shippingRequest.Shipping_Method__c = transmittal.VIA__c;
        shippingRequest.Requested_By__c = UserInfo.getName();
        shippingRequest.Send_To_Name__c = rosterForTransmittalSendTo.Name__c;
        shippingRequest.Send_To_Company__c = rosterForTransmittalSendTo.Company_Name__c;
        shippingRequest.Phone__c = rosterForTransmittalSendTo.Contact__r.Phone;
        shippingRequest.Address__c = rosterForTransmittalSendTo.Company_Address__c;
        shippingRequest.Date__c = Datetime.Now();

        for( rosterWrapper item: wrapoutRosters){
            if( item.rosterForTransmittal != null && item.rosterForTransmittal.Id != null ){
                if( item.rosterForTransmittal.Name__c != null ) shippingRequest.CC_To_Name__c = item.rosterForTransmittal.Name__c;
                if( item.rosterForTransmittal.Company_Name__c != null ) shippingRequest.CC_To_Company__c = item.rosterForTransmittal.Company_Name__c;
                if( item.rosterForTransmittal.Company_Address__c != null ) shippingRequest.CC_Address__c = item.rosterForTransmittal.Company_Address__c;
                if( item.rosterForTransmittal.Contact__r.Phone != null ) shippingRequest.CC_Phone__c = item.rosterForTransmittal.Contact__r.Phone;
                break;
            }
        }
        saveTransmittal();
        showTransmittalEditor = false;
        showTemplateEditor = false;
        isShippingRequestPanel = true;
    }

    public void sendShippingRequestAction(){

        insert shippingRequest;
        isShippingRequestPanel = false;
    }

    public void cancelFromShipping() {
        isShippingRequestPanel = false;

    }
}