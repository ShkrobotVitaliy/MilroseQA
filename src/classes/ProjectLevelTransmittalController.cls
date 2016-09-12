public with sharing class ProjectLevelTransmittalController {
    public final Project_Profile__c projectProfileItem { get; set; }
    private final String TYPE_NAME = 'Project Level Transmittal';

    public Map<Id, DDP_Helper__c> tableDataMap {get{ return new Map<Id, DDP_Helper__c>( tableDataRows );} set;}
    public List<DDP_Helper__c> tableDataRows {get; set;}

    public Boolean disabledButton { 
        get{ 
            if( showTransmittalEditor ) {
                disabledButton = true;
            }else{
                disabledButton = false;
            } 
            return  disabledButton; 
        } 
        set;
    }
    
    public ProjectLevelTransmittalController ( ApexPages.StandardController controller ) {
        this.projectProfileItem = (Project_Profile__c)controller.getRecord();

        initRoster();
        initDataTable();
        initComments();

    }

    private void initDataTable() {
        tableDataRows = new List<DDP_Helper__c>([SELECT Id, Name, Project_Profile__c, Sent_VIA__c, Sent_Tracking__c, Sent_Date_Time__c, Quantity__c, Is_Sent_Transmittal__c,
                                                        Project_Roster__c, Project_Roster_Name__c, Artifacts__c, Artifact_Id__c, Is_Email_Sent__c, Is_Selected_Artifact__c
                                                FROM DDP_Helper__c
                                                WHERE Project_Profile__c =: projectProfileItem.Id AND
                                                      Type__c =: TYPE_NAME]);
        if( tableDataRows.isEmpty() ) {
            DDP_Helper__c initialHelper = new DDP_Helper__c( Project_Profile__c = projectProfileItem.Id, Type__c = TYPE_NAME );
            
            tableDataRows.add( initialHelper );
        }
    }

    /* Table Rows Functionality ----------------------------------------------------------------------------------------------------- */
    public String tableRecordId {get; set;}
    public void updateDataRowsAction (){
        try {
            for( DDP_Helper__c item: tableDataRows){
                item.Is_Email_Sent__c = false;
            }
            upsert tableDataRows;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        initDataTable();
    }
    public void deleteDataRowAction (){
        try {
            delete tableDataMap.get( tableRecordId );
            
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, + e.getMessage()));
            return;
        }
        initDataTable();
    }
    public void addNewDataRowAction (){
        DDP_Helper__c tableRecord = new DDP_Helper__c( Project_Profile__c = projectProfileItem.Id, Type__c = TYPE_NAME );
        try {
            insert tableRecord;
            upsert tableDataRows;
        } catch(System.DMLException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
            return;
        }
        tableDataRows.add( tableRecord );
    }

    private Set<String> contactsNames;
    private Set<String> viaNames;
    public Map<Id, DDP_Helper__c> recordsToSendMap {get; set;}
    public void populateRecordsToSendMap(){
        recordsToSendMap = new Map<Id, DDP_Helper__c>();
        contactsNames = new Set<String>();
        viaNames = new Set<String>();
        for( DDP_Helper__c recordItem: tableDataRows ){
            if( recordItem.Is_Email_Sent__c ){
                recordItem.Quantity__c = 1;
                recordItem.Artifact_Id__c = null;
                recordsToSendMap.put( recordItem.Id, recordItem );
                contactsNames.add( recordItem.Project_Roster_Name__c );
                viaNames.add( recordItem.Sent_VIA__c );
                rosterId = recordItem.Project_Roster__c;
            }
        }
    }

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
            if ( rosterReplyToId == item.Id ) {
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
                transmittal = new Transmittal__c( Project_Profile__c = projectProfileItem.Id, CC_to__c = '', Reply_To__c = '', Comments__c = '', Send_To_Address__c = '',  Send_To_Street__c = '',
                                                  Resubmit__c = null, Return__c = null, Send_To__c = '', Submit__c = null, VIA__c = null, Other__c = null, Additional_Comments__c = '',
                                                  Fulfillment_Office_Address__c = '', Fulfillment_Office_Street__c = '', Fulfillment_Office_Phone__c = '', Fulfillment_Office_Fax__c = '' );
                for( Transmittal__c item: [Select Id, CreatedById From Transmittal__c Where Project_Profile__c =: projectProfileItem.Id limit 1]){
                    transmittal.Id = item.Id;
                }

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
                this.projectRosters = ProjectRosterServices.getRosterByProjectId(projectProfileItem.Id);

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
        for( DDP_Helper__c item: recordsToSendMap.values() ){
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
        
        for (Project_Roster__c item: this.projectRosters) {
            if ( userInfo.getUserId() == item.User__c ) {
                rosterReplyToId = item.Id;
                rosterForTransmittalReplyTo = item;
                break;

            }

        }
        
        rosterSendToAction();
        rosterReplyToAction();

        showTransmittalEditor = true;

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

        Integer transmittalNumber = Integer.valueOf( [SELECT MAX(Number__c) FROM Transmittal__c WHERE Project_Profile__c = : projectProfileItem.Id][0].get('expr0') );
        transmittal.Number__c = transmittalNumber == null ? 1 : transmittalNumber + 1;
        transmittal.Comments__c = transmittalComments.get( transmittal.Comments__c );

    }

    public void cancelAction(){
        showTransmittalEditor = false;
    }

    List<Id> attachIds;

    public void saveTransmittal(){

        filledOutTransmittalRecord();

        try {
            upsert transmittal;
            updateRecordToCreateTransmittal();
        } catch( dmlException e ) {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Saving Transmittal: ' + String.valueOf(e) ) );
            return;
        }
                
        showTransmittalEditor = false;
    }
    
    public void updateRecordToCreateTransmittal(){
        try{
            for ( DDP_Helper__c item : tableDataRows ){
                if (!recordsToSendMap.containsKey(item.Id)){
                    item.Is_Selected_Artifact__c = false;
                }
            }
            for( DDP_Helper__c item: recordsToSendMap.values() ){
                item.Sent_Date_Time__c = datetime.now();
                item.Is_Email_Sent__c = false;
                item.Is_Sent_Transmittal__c = true;
                item.Is_Selected_Artifact__c = true;
                
            }
            upsert tableDataRows;
        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error occured during saving transmittal: ' + ex.getMessage()));
            return;
        }
        initDataTable();
    }

    public void attachPDF() {
        try {
            DDPEmailServices.generateAndAttachPDF( projectProfileItem.Id, DDPEmailServices.DDP_NAME_TRANSMITTAL_DOCUMENT_PROJECT, null, null, null, attachIds);
        } catch( Exception ex ) {
            ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, 'Error Occured While Generating and Attaching PDF File: ' + ex.getMessage() ) );
            return;
        }
    }
    
    //Redirect to background Project, from what Pre-billing was started.
    public PageReference returnToProjectLevel() {
        return new PageReference( '/' + projectProfileItem.Id );
    }
    /* End Transmittal --------------------------------------------------------------------------------------------------------------------------- */
}