public with sharing class PrepareFilingPackageExtension {
    public static final String CHECKLIST_DESCRIPTIONS_RECORD_TYPE = 'Checklist Description';
    public static final String DEFAULT_CHECKLIST_RECORD_TYPE      = 'Checklist Default';
    public static final String REQUIRED_FILED_ERROR               = 'Please populate required field(s)!';
    public static final String COMPLETE_FAILED_ERROR              = 'Complete was failed!';
    public static final String FORM_SUCCESSFULLY_COMPLETED        = 'Your checklist has been successfully completed.';
    @TestVisible private final static String NO_DDP_AVAILABLE = 'Error finding correct DDP.';

    public static final String FIRE_ALARM           = 'Fire Alarm';
    public static final String GENERAL_CONSTRUCTION = 'General Construction';
    public static final String MECHANICAL           = 'Mechanical';
    public static final String PLUMBING             = 'Plumbing';
    public static final String SPRINKLER            = 'Sprinkler';
    public static final String STRUCTURAL           = 'Structural';

    public Task_Item__c taskItem {get;set;}

    private Id appDefaultRecordTypeId {
        get {
            if (null == this.appDefaultRecordTypeId) {
                this.appDefaultRecordTypeId = RecordTypeServices.getRecordTypeIdByRecordTypeName(DEFAULT_CHECKLIST_RECORD_TYPE, 'Application_Filing_Checklist__c');

            }
            return this.appDefaultRecordTypeId;

        }
        set;
    }

    private Id workPermitDefaultRecordTypeId {
        get {
            if (null == this.workPermitDefaultRecordTypeId) {
                this.workPermitDefaultRecordTypeId = RecordTypeServices.getRecordTypeIdByRecordTypeName(DEFAULT_CHECKLIST_RECORD_TYPE, 'Work_Permit_Filing_Checklist__c');

            }
            return this.workPermitDefaultRecordTypeId;

        }
        set;
    }

    private Id appSignOffDefaultRecordTypeId {
        get {
            if (null == this.appSignOffDefaultRecordTypeId) {
                this.appSignOffDefaultRecordTypeId = RecordTypeServices.getRecordTypeIdByRecordTypeName(DEFAULT_CHECKLIST_RECORD_TYPE, 'Application_Sign_Off_Scope__c');

            }
            return this.appSignOffDefaultRecordTypeId;

        }
        set;
    }

    public Application_Filing_Checklist__c appFilingCkecklistRecord { get; set; }
    public Work_Permit_Filing_Checklist__c workPermitCkecklistRecord { get; set; }
    public Application_Sign_Off_Scope__c appSignOffGeneralConstruction { get; set; }
    public Application_Sign_Off_Scope__c appSignOffMechanical { get; set; }
    public Application_Sign_Off_Scope__c appSignOffPlumbing { get; set; }
    public Application_Sign_Off_Scope__c appSignOffStructural { get; set; }
    public Application_Sign_Off_Scope__c appSignOffSprinkler { get; set; }
    public Application_Sign_Off_Scope__c appSignOffFireAlarm { get; set; }

    public Boolean isChecklistNotRequired {
        get {
            return this.isAppChecklistNotRequired && this.isConstructionChecklistNotRequired && this.isSignOffChecklistNotRequired;

        }
        private set;
    }

    public Boolean isAppChecklistNotRequired { get; set; }
    public Boolean isNotPropertyRequired { get; set; }
    public Boolean isNotScopeRequired { get; set; }

    public Boolean isConstructionChecklistNotRequired { get; set; }
    public Boolean isConstructionScopeNotRequired { get; set; }
    public Boolean isConstructionTechnicalReportsNotRequired { get; set; }
    public Boolean isConstructionFeesNotRequired { get; set; }

    public Boolean  isSignOffChecklistNotRequired { get; set; }

    public Boolean  isFireAlarmNotRequired { get; set; }
    public Boolean  isGeneralConstructionNotRequired { get; set; }
    public Boolean  isMechanicalNotRequired { get; set; }
    public Boolean  isPlumbingNotRequired { get; set; }
    public Boolean  isSprinklerNotRequired { get; set; }
    public Boolean  isStructuralNotRequired { get; set; }

    public Map<String, SchemaFieldSetMemberChangeLabel> schemaFieldSetMemberChangeLabelMap {get;set;}

    public Application_Filing_Checklist__c defaultFilingCkecklistRecord {
        get {
            if (null == this.defaultFilingCkecklistRecord) {
                this.defaultFilingCkecklistRecord = getAppFilingChecklistDescription().clone();

            }
            return this.defaultFilingCkecklistRecord;

        }
        private set;
    }

    public Application_Filing_Checklist__c mainAppFiling {
        get {
            if (null == this.mainAppFiling) {
                this.mainAppFiling = ApplicationFilingChecklistServices.getAppFillingChecklistByTaskItemId(this.taskItem.Id);

            }
            return this.mainAppFiling;

        }
        private set;
    }

    public Work_Permit_Filing_Checklist__c defaultWorkPermitFilingCkecklistRecord {
        get {
            if (null == this.defaultWorkPermitFilingCkecklistRecord) {
                this.defaultWorkPermitFilingCkecklistRecord = getWorkPermitFilingChecklistDescription().clone();

            }
            return this.defaultWorkPermitFilingCkecklistRecord;

        }
        private set;

    }

    public Work_Permit_Filing_Checklist__c workPermitFiling {
        get {
            if (null == this.workPermitFiling) {
                this.workPermitFiling = ConstructionFilingChecklistServices.getConstructionFillingChecklistByTaskItemId(this.taskItem.Id);

            }
            return this.workPermitFiling;

        }
        private set;
    }

    public Application_Sign_Off_Scope__c defaultAppSignOffFilingCkecklistRecord {
        get {
            if (null == this.defaultAppSignOffFilingCkecklistRecord) {
                this.defaultAppSignOffFilingCkecklistRecord = getSighOffFilingChecklistDescription().clone();

            }
            return this.defaultAppSignOffFilingCkecklistRecord;

        }
        private set;

    }

     public Application_Sign_Off_Scope__c signOffFiling {
        get {
            if (null == this.signOffFiling) {
                this.signOffFiling = SignOffFilingChecklistServices.getSignOffFillingChecklistByTaskItemId(this.taskItem.Id);

            }
            return this.signOffFiling;

        }
        private set;
    }

    private List<Application_Sign_Off_Scope__c> appSignOffList {
        get {
            if (null == this.appSignOffList) {
                this.appSignOffList = SignOffFilingChecklistServices.getSignOffFillingChecklistListByTaskItemId(this.taskItem.Id);

            }
            return this.appSignOffList;

        }
        set;

    }

    public Boolean isAccess {
        get {
            if(isAccess == null) {
                Schema.DescribeSObjectResult applicationSignOffDescribeSObjectResult = Schema.SObjectType.Application_Sign_Off_Scope__c;
                Schema.DescribeSObjectResult workPermiDescribeSObjectResult = Schema.SObjectType.Work_Permit_Filing_Checklist__c;
                Schema.DescribeSObjectResult applicationFilingDescribeSObjectResult = Schema.SObjectType.Application_Filing_Checklist__c;
                isAccess = true;
                if( !applicationSignOffDescribeSObjectResult.isCreateable() || !workPermiDescribeSObjectResult.isCreateable() || !applicationFilingDescribeSObjectResult.isCreateable() )  {
                    isAccess = false;
                }
            }
            return isAccess;
        }
        set;
    }

    public Boolean disableCompleteButton {
        get {
            try {
                validationProperty();
                disableCompleteButton = taskItem.Is_Application_Filing_Checklist_Complete__c;
            } catch(Exception ex) {
                disableCompleteButton = false;
            }
            return disableCompleteButton;
        }
        set;
    }

    public PrepareFilingPackageExtension(ApexPages.StandardController controller) {
        this.taskItem = (Task_Item__c)controller.getRecord();
        this.schemaFieldSetMemberChangeLabelMap = new Map<String, SchemaFieldSetMemberChangeLabel>();
        setChecklistRecords(this.taskItem.Id);
        setRequiredSection();

        if(taskItem.No_Checklist_Required_Service__c) {
            if (this.isChecklistNotRequired) {
                this.isAppChecklistNotRequired          = false;
                this.isConstructionChecklistNotRequired = false;
                this.isSignOffChecklistNotRequired      = false;

            } else {
                this.isAppChecklistNotRequired          = true;
                this.isConstructionChecklistNotRequired = true;
                this.isSignOffChecklistNotRequired      = true;

            }
        }
    }
    public Application_Sign_Off_Scope__c structuralDescription {
        get {
            if(structuralDescription == null) {
                structuralDescription = this.getDescription('Structural');
            }
            return structuralDescription;
        }
        set;
    }
    public Application_Sign_Off_Scope__c plumbingDescription {
        get {
            if(plumbingDescription == null) {
                plumbingDescription = this.getDescription('Plumbing');
            }
            return plumbingDescription;
        }
        set;
    }
    public Application_Sign_Off_Scope__c fireAlarmDescription {
        get {
            if(fireAlarmDescription == null) {
                fireAlarmDescription = this.getDescription('Fire Alarm');
            }
            return fireAlarmDescription;
        }
        set;
    }
    public Application_Sign_Off_Scope__c sprinklerDescription {
        get {
            if(sprinklerDescription == null) {
                sprinklerDescription = this.getDescription('Sprinkler');
            }
            return sprinklerDescription;
        }
        set;
    }


    private Application_Sign_Off_Scope__c getDescription(String workType) {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getAppSignOffFilingDescriptions()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE RecordType.Name = \''+ CHECKLIST_DESCRIPTIONS_RECORD_TYPE +'\' AND Work_Type__c = \''+workType+'\' ';
        return Database.query(query);

    }

    private void setChecklistRecords(final Id taskItemId) {
        this.appFilingCkecklistRecord  = getApplicationFilingChecklist(taskItemId);
        this.workPermitCkecklistRecord = getWorkPermitFilingChecklist(taskItemId);

        this.appSignOffGeneralConstruction = getSignOffFilingChecklist(taskItemId, GENERAL_CONSTRUCTION);
        this.appSignOffMechanical          = getSignOffFilingChecklist(taskItemId, MECHANICAL);
        this.appSignOffPlumbing            = getSignOffFilingChecklist(taskItemId, PLUMBING);
        this.appSignOffStructural          = getSignOffFilingChecklist(taskItemId, STRUCTURAL);
        this.appSignOffSprinkler           = getSignOffFilingChecklist(taskItemId, SPRINKLER);
        this.appSignOffFireAlarm           = getSignOffFilingChecklist(taskItemId, FIRE_ALARM);

    }

    private void setRequiredSection() {
        this.isAppChecklistNotRequired                 = (null == this.mainAppFiling) ? false : this.mainAppFiling.Is_App_Checklist_Not_Required__c;
        this.isNotPropertyRequired                     = (null == this.mainAppFiling) ? false : this.mainAppFiling.Is_Not_Property_Required__c;
        this.isNotScopeRequired                        = (null == this.mainAppFiling) ? false : this.mainAppFiling.Is_Not_Scope_Required__c;

        this.isConstructionChecklistNotRequired        = (null == this.workPermitFiling) ? false : this.workPermitFiling.Is_Construction_Checklist_Not_Required__c;
        this.isConstructionScopeNotRequired            = (null == this.workPermitFiling) ? false : this.workPermitFiling.Is_Construction_Scope_Not_Required__c;
        this.isConstructionTechnicalReportsNotRequired = (null == this.workPermitFiling) ? false : this.workPermitFiling.Is_Construction_Technical_Not_Require__c;
        this.isConstructionFeesNotRequired             = (null == this.workPermitFiling) ? false : this.workPermitFiling.Is_Construction_Fees_Not_Required__c;

        this.isSignOffChecklistNotRequired             = (null == this.signOffFiling) ? false : this.signOffFiling.Is_Sign_Off_Checklist_Not_Required__c;

        if (null == this.appSignOffList || this.appSignOffList.isEmpty()) {
            this.isFireAlarmNotRequired            = false;
            this.isGeneralConstructionNotRequired  = false;
            this.isMechanicalNotRequired           = false;
            this.isPlumbingNotRequired             = false;
            this.isSprinklerNotRequired            = false;
            this.isStructuralNotRequired           = false;

        } else {
            for (Application_Sign_Off_Scope__c appSignOff : this.appSignOffList) {
                if (GENERAL_CONSTRUCTION == appSignOff.Work_Type__c) {
                    this.isGeneralConstructionNotRequired = appSignOff.Is_General_Construction_Not_Required__c;

                } else if (MECHANICAL == appSignOff.Work_Type__c) {
                    this.isMechanicalNotRequired = appSignOff.Is_Mechanical_Not_Required__c;

                } else if (PLUMBING == appSignOff.Work_Type__c) {
                    this.isPlumbingNotRequired = appSignOff.Is_Plumbing_Not_Required__c;

                } else if (STRUCTURAL == appSignOff.Work_Type__c) {
                    this.isStructuralNotRequired = appSignOff.Is_Structural_Not_Required__c;

                } else if (SPRINKLER == appSignOff.Work_Type__c) {
                    this.isSprinklerNotRequired = appSignOff.Is_Sprinkler_Not_Required__c;

                } else if (FIRE_ALARM== appSignOff.Work_Type__c) {
                    this.isFireAlarmNotRequired = appSignOff.Is_Fire_Alarm_Not_Required__c;

                }

            }

        }

    }

    /* -------------------------- Begin Application Checklist -------------------------- */
    public List<Schema.FieldSetMember> getApplicationFilingPropertyFields() {
        for(Schema.FieldSetMember item : SObjectType.Application_Filing_Checklist__c.FieldSets.Property.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Filing_Checklist__c.FieldSets.Property.getFields();

    }

    public List<Schema.FieldSetMember> getApplicationFilingScopeFields() {
        for(Schema.FieldSetMember item : SObjectType.Application_Filing_Checklist__c.FieldSets.Scope.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Filing_Checklist__c.FieldSets.Scope.getFields();

    }

    private List<Schema.FieldSetMember> getApplicationFilingDescriptions() {
        for(Schema.FieldSetMember item : SObjectType.Application_Filing_Checklist__c.FieldSets.Description_Fields.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Filing_Checklist__c.FieldSets.Description_Fields.getFields();

    }

    private Application_Filing_Checklist__c getApplicationFilingChecklist(final Id taskItemId) {
        List<Application_Filing_Checklist__c> retrievedList = getAppFilingChecklistDefault(taskItemId);

        if (retrievedList.isEmpty()) {
            Application_Filing_Checklist__c newChecklist = getAppFilingChecklistDescription().clone();
            newChecklist.Task_Item__c = taskItemId;
            newChecklist.RecordTypeId = this.appDefaultRecordTypeId;
            return newChecklist;

        } else {
            return retrievedList[0];

        }

    }

    private List<Application_Filing_Checklist__c> getAppFilingChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getApplicationFilingPropertyFields()) {
            query += f.getFieldPath() + ', ';

        }

        for (Schema.FieldSetMember f : getApplicationFilingScopeFields()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Filing_Checklist__c WHERE Task_Item__c = \''+ taskItemId +'\'';
        return Database.query(query);

    }

    private Application_Filing_Checklist__c getAppFilingChecklistDescription() {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getApplicationFilingDescriptions()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Filing_Checklist__c WHERE RecordType.Name = \''+ CHECKLIST_DESCRIPTIONS_RECORD_TYPE +'\'';
        return Database.query(query);

    }
    /* -------------------------- End Application Checklist -------------------------- */

    /* -------------------------- Start ShemaFieldWrapper ---------------------------- */
    public class SchemaFieldSetMemberChangeLabel {

        private String label;
        private String field;

        private Map<String, String> fieldToLabelMap = new Map<String, String>{
            'Open_Violations_Civil_Penalties__c'    => 'Open Violations with Civil Penalties',
            'TR8_Special_Progress__c'               => 'TR-8 (Special/Progress)',
            'BIS_Property_Profile_Overview__c'      => 'BIS Property Profile Overview Attached',
            'Verify_Person_Signing_PW_2_Matches__c' => '<u>OUTER BOROUGHS ONLY:</u> Verify Person Signing PW-2 Matches BIS',
            'Signed_Sealed_Section__c'              => 'Signed and Sealed in Section 5, 6, & 7 - Signed by Owner.',
            'TR_8_Certification__c'                 => 'TR-8 Certification (Technical Report)',
            'Virtual_Folder_DOB_website__c'         => 'Virtual Folder'
        };

        public SchemaFieldSetMemberChangeLabel( Schema.FieldSetMember schemaFieldSetMemberList ) {
            this.label = schemaFieldSetMemberList.getLabel();
            this.field = schemaFieldSetMemberList.getFieldPath();

            if( !fieldToLabelMap.containsKey(this.field) ) {
                fieldToLabelMap.put(this.field, this.label);
            }
        }

        public String getLabel() {
            return fieldToLabelMap.get(this.field);
        }
    }
    /* -------------------------- End ShemaFieldWrapper ------------------------------ */

    /* -------------------------- Begin Work Permit Checklist -------------------------- */
    public List<Schema.FieldSetMember> getWorkPermitFilingScopeFields() {
        for(Schema.FieldSetMember item : SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Scope.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Scope.getFields();

    }

    public List<Schema.FieldSetMember> getWorkPermitFilingTechnicalReportsFields() {
        for(Schema.FieldSetMember item : SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Technical_Reports.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Technical_Reports.getFields();

    }

    public List<Schema.FieldSetMember> getWorkPermitFilingFeesFields() {
        for(Schema.FieldSetMember item : SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Fees.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Fees.getFields();

    }

    private List<Schema.FieldSetMember> getWorkPermitFilingDescriptions() {
        for(Schema.FieldSetMember item : SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Description_Fields.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Work_Permit_Filing_Checklist__c.FieldSets.Description_Fields.getFields();

    }

    private Work_Permit_Filing_Checklist__c getWorkPermitFilingChecklist(final Id taskItemId) {
        List<Work_Permit_Filing_Checklist__c> retrievedList = getWorkPermitChecklistDefault(taskItemId);

        if (retrievedList.isEmpty()) {
            Work_Permit_Filing_Checklist__c newChecklist = getWorkPermitFilingChecklistDescription().clone();
            newChecklist.Task_Item__c = taskItemId;
            newChecklist.RecordTypeId = this.workPermitDefaultRecordTypeId;
            return newChecklist;

        } else {
            return retrievedList[0];

        }

    }

    private List<Work_Permit_Filing_Checklist__c> getWorkPermitChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getWorkPermitFilingScopeFields()) {
            query += f.getFieldPath() + ', ';

        }

        for (Schema.FieldSetMember f : getWorkPermitFilingTechnicalReportsFields()) {
            query += f.getFieldPath() + ', ';

        }

        for (Schema.FieldSetMember f : getWorkPermitFilingFeesFields()) {
            query += f.getFieldPath() + ', ';

        }

        query += 'Id, Name FROM Work_Permit_Filing_Checklist__c WHERE Task_Item__c = \''+ taskItemId +'\'';
        return Database.query(query);

    }

    private Work_Permit_Filing_Checklist__c getWorkPermitFilingChecklistDescription() {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getWorkPermitFilingDescriptions()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Work_Permit_Filing_Checklist__c WHERE RecordType.Name = \'' + CHECKLIST_DESCRIPTIONS_RECORD_TYPE +'\'';
        return Database.query(query);

    }
    /* -------------------------- End Work Permit Checklist -------------------------- */

    /* -------------------------- Begin App Sign Off  -------------------------- */
    private List<Schema.FieldSetMember> getAppSignOffFilingDescriptions() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Description_Fields.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Description_Fields.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingGeneralConstruction() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.General_Construction.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.General_Construction.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingFireAlarm() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Fire_Alarm.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Fire_Alarm.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingMechanical() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Mechanical.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Mechanical.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingPlumbing() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Plumbing.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Plumbing.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingSprinkler() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Sprinkler.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Sprinkler.getFields();

    }

    public List<Schema.FieldSetMember> getAppSignOffFilingStructural() {
        for(Schema.FieldSetMember item : SObjectType.Application_Sign_Off_Scope__c.FieldSets.Structural.getFields()) {
            schemaFieldSetMemberChangeLabelMap.put(String.valueOf( item.getFieldPath() ),  new SchemaFieldSetMemberChangeLabel(item) );
        }
        return SObjectType.Application_Sign_Off_Scope__c.FieldSets.Structural.getFields();

    }

    private Application_Sign_Off_Scope__c getSignOffFilingChecklist(final Id taskItemId, final String workType) {
        List<Application_Sign_Off_Scope__c> retrievedList = new List<Application_Sign_Off_Scope__c>();

        if (GENERAL_CONSTRUCTION == workType) {
            retrievedList = getGeneralConstructionChecklistDefault(taskItemId);
        
        } else if (FIRE_ALARM == workType) {
            retrievedList = getFireAlarmChecklistDefault(taskItemId);
        
        } else if (MECHANICAL == workType) {
            retrievedList = getMechanicalChecklistDefault(taskItemId);
        
        } else if (PLUMBING == workType) {
            retrievedList = getPlumbingChecklistDefault(taskItemId);
        
        } else if (SPRINKLER == workType) {
            retrievedList = getSprinklerChecklistDefault(taskItemId);
        
        } else if (STRUCTURAL == workType) {
            retrievedList = getStructuralChecklistDefault(taskItemId);
        
        }

        if (retrievedList.isEmpty()) {
            Application_Sign_Off_Scope__c newChecklist = getSighOffFilingChecklistDescription().clone();
            newChecklist.Task_Item__c = taskItemId;
            newChecklist.RecordTypeId = this.appSignOffDefaultRecordTypeId;
            newChecklist.Work_Type__c = workType;
            return newChecklist;

        } else {
            return retrievedList[0];

        }

    }

    private List<Application_Sign_Off_Scope__c> getGeneralConstructionChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingGeneralConstruction()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'General Construction' + '\'';
        return Database.query(query);

    }

    private List<Application_Sign_Off_Scope__c> getFireAlarmChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingFireAlarm()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'Fire Alarm' + '\'';
        return Database.query(query);

    }

    private List<Application_Sign_Off_Scope__c> getMechanicalChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingMechanical()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'Mechanical' + '\'';
        return Database.query(query);

    }

    private List<Application_Sign_Off_Scope__c> getPlumbingChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingPlumbing()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'Plumbing' + '\'';
        return Database.query(query);

    }

    private List<Application_Sign_Off_Scope__c> getSprinklerChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingSprinkler()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'Sprinkler' + '\'';
        return Database.query(query);

    }

    private List<Application_Sign_Off_Scope__c> getStructuralChecklistDefault(Id taskItemId) {
        String query = 'SELECT ';
        for (Schema.FieldSetMember f : getAppSignOffFilingStructural()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = \''+ taskItemId +'\' AND Work_Type__c = \'' + 'Structural' + '\'';
        return Database.query(query);

    }

    private Application_Sign_Off_Scope__c getSighOffFilingChecklistDescription() {
        String query = 'SELECT ';

        for (Schema.FieldSetMember f : getAppSignOffFilingDescriptions()) {
            query += f.getFieldPath() + ', ';

        }
        query += 'Id, Name FROM Application_Sign_Off_Scope__c WHERE RecordType.Name = \''+ CHECKLIST_DESCRIPTIONS_RECORD_TYPE +'\' LIMIT 1';
        return Database.query(query);

    }
    /* -------------------------- End App Sign Off -------------------------- */
    public Boolean isFormCompleted { 
        get{ 
            if( isFormCompleted == null ) {
                List<Application_Sign_Off_Scope__c> applicationSignOffScope = [ SELECT Id FROM Application_Sign_Off_Scope__c WHERE Task_Item__c = : this.taskItem.Id ];
                isFormCompleted = true;
                if( applicationSignOffScope.isEmpty() ) {
                    isFormCompleted = false;
                }
            }
            return isFormCompleted;
        }
        set;
    }
    //Complete Button action
    public PageReference completeChecklists() {
        try {
            validationProperty();

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return null;

        }
        PageReference pr;
        Savepoint sp = Database.setSavepoint();
        try {
            setRequiredValues();
            taskItem.Is_Application_Filing_Checklist_Complete__c = true;
            List<Application_Sign_Off_Scope__c> appSignOffList = new List<Application_Sign_Off_Scope__c> { this.appSignOffGeneralConstruction, this.appSignOffMechanical,
                                                                                                           this.appSignOffPlumbing, this.appSignOffStructural,
                                                                                                           this.appSignOffSprinkler, this.appSignOffFireAlarm };

            upsert appSignOffList;
            upsert this.appFilingCkecklistRecord;
            upsert this.workPermitCkecklistRecord;
            update taskItem;
            
            //Generate PDF document
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, FORM_SUCCESSFULLY_COMPLETED));
            
            return DDPEmailServices.createDDPLoopPlus(DDPEmailServices.DDP_NAME_PREPARE_FILING_PACKAGE, DDPEmailServices.DELIVERY_METHOD_ATTACH, taskItem.Id, null, null, null, null, true);
            
        } catch(Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, COMPLETE_FAILED_ERROR));
            return null;

        }
        return null;

    }

    private void setRequiredValues() {
        this.appFilingCkecklistRecord.Is_App_Checklist_Not_Required__c           = this.isAppChecklistNotRequired;
        this.appFilingCkecklistRecord.Is_Not_Property_Required__c                = this.isAppChecklistNotRequired ? this.isAppChecklistNotRequired : this.isNotPropertyRequired;
        this.appFilingCkecklistRecord.Is_Not_Scope_Required__c                   = this.isAppChecklistNotRequired ? this.isAppChecklistNotRequired :this.isNotScopeRequired;

        this.workPermitCkecklistRecord.Is_Construction_Checklist_Not_Required__c = this.isConstructionChecklistNotRequired;
        this.workPermitCkecklistRecord.Is_Construction_Scope_Not_Required__c     = this.isConstructionChecklistNotRequired ? this.isConstructionChecklistNotRequired : this.isConstructionScopeNotRequired;
        this.workPermitCkecklistRecord.Is_Construction_Technical_Not_Require__c  = this.isConstructionChecklistNotRequired ? this.isConstructionChecklistNotRequired : this.isConstructionTechnicalReportsNotRequired;
        this.workPermitCkecklistRecord.Is_Construction_Fees_Not_Required__c      = this.isConstructionChecklistNotRequired ? this.isConstructionChecklistNotRequired : this.isConstructionFeesNotRequired;

        this.appSignOffGeneralConstruction.Is_Sign_Off_Checklist_Not_Required__c = this.isSignOffChecklistNotRequired;
        this.appSignOffMechanical.Is_Sign_Off_Checklist_Not_Required__c          = this.isSignOffChecklistNotRequired;
        this.appSignOffPlumbing.Is_Sign_Off_Checklist_Not_Required__c            = this.isSignOffChecklistNotRequired;
        this.appSignOffStructural.Is_Sign_Off_Checklist_Not_Required__c          = this.isSignOffChecklistNotRequired;
        this.appSignOffSprinkler.Is_Sign_Off_Checklist_Not_Required__c           = this.isSignOffChecklistNotRequired;
        this.appSignOffFireAlarm.Is_Sign_Off_Checklist_Not_Required__c           = this.isSignOffChecklistNotRequired;

        this.appSignOffGeneralConstruction.Is_General_Construction_Not_Required__c = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isGeneralConstructionNotRequired;
        this.appSignOffMechanical.Is_Mechanical_Not_Required__c                    = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isMechanicalNotRequired;
        this.appSignOffPlumbing.Is_Plumbing_Not_Required__c                        = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isPlumbingNotRequired;
        this.appSignOffStructural.Is_Structural_Not_Required__c                    = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isStructuralNotRequired;
        this.appSignOffSprinkler.Is_Sprinkler_Not_Required__c                      = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isSprinklerNotRequired;
        this.appSignOffFireAlarm.Is_Fire_Alarm_Not_Required__c                     = this.isSignOffChecklistNotRequired ? this.isSignOffChecklistNotRequired : this.isFireAlarmNotRequired;

    }

    private void validationProperty() {
        if (this.isChecklistNotRequired) {
            return;

        }

        if (!this.isAppChecklistNotRequired) {
            //Check all App property fields
            if (!this.isNotPropertyRequired) {
                for (Schema.FieldSetMember f : getApplicationFilingPropertyFields()) {
                    if (null == this.appFilingCkecklistRecord.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            //Check all App scope fields
            if (!this.isNotScopeRequired) {
                for (Schema.FieldSetMember f : getApplicationFilingScopeFields()) {
                    if (null == this.appFilingCkecklistRecord.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

        }

        if (!this.isConstructionChecklistNotRequired) {
            //Check all Costruction scope fields
            if (!this.isConstructionScopeNotRequired ) {
                for (Schema.FieldSetMember f : getWorkPermitFilingScopeFields()) {
                    if (null == this.workPermitCkecklistRecord.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            //Check all Costruction technical fields
            if (!this.isConstructionTechnicalReportsNotRequired) {
                for (Schema.FieldSetMember f : getWorkPermitFilingTechnicalReportsFields()) {
                    if (null == this.workPermitCkecklistRecord.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            //Check all Costruction fees fields
            if (!this.isConstructionFeesNotRequired) {
                for (Schema.FieldSetMember f : getWorkPermitFilingFeesFields()) {
                    if (null == this.workPermitCkecklistRecord.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }
        }

        //Check all Sign Off fees fields
        if (!this.isSignOffChecklistNotRequired) {

            if (!this.isGeneralConstructionNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingGeneralConstruction()) {
                    if (null == this.appSignOffGeneralConstruction.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            if (!this.isFireAlarmNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingFireAlarm()) {
                    if (null == this.appSignOffFireAlarm.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            if (!this.isMechanicalNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingMechanical()) {
                    if (null == this.appSignOffMechanical.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            if (!this.isPlumbingNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingPlumbing()) {
                    if (null == this.appSignOffPlumbing.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            if (!this.isSprinklerNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingSprinkler()) {
                    if (null == this.appSignOffSprinkler.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

            if (!this.isStructuralNotRequired) {
                for (Schema.FieldSetMember f : getAppSignOffFilingStructural()) {
                    if (null == this.appSignOffStructural.get(f.getFieldPath())) {
                        throw new ErrorException(REQUIRED_FILED_ERROR);

                    }

                }

            }

        }

    }

    public void setFilingChecklistState() {
        taskItem.No_Checklist_Required_Service__c = true;
    }

    public void setSubTableState() {

    }

    public void setAppFilingChecklistState() {
        this.isAppChecklistNotRequired = this.isAppChecklistNotRequired ? false : true;

        this.isNotPropertyRequired = this.isAppChecklistNotRequired;
        this.isNotScopeRequired    = this.isAppChecklistNotRequired;
    }

    public void setConstructionFilingChecklistState() {
        this.isConstructionChecklistNotRequired = this.isConstructionChecklistNotRequired ? false : true;

        this.isConstructionScopeNotRequired            = this.isConstructionChecklistNotRequired;
        this.isConstructionTechnicalReportsNotRequired = this.isConstructionChecklistNotRequired;
        this.isConstructionFeesNotRequired             = this.isConstructionChecklistNotRequired;
    }

    public void setAignOffChecklistState() {
        this.isSignOffChecklistNotRequired = this.isSignOffChecklistNotRequired ? false : true;

        this.isGeneralConstructionNotRequired = this.isSignOffChecklistNotRequired;
        this.isMechanicalNotRequired          = this.isSignOffChecklistNotRequired;
        this.isPlumbingNotRequired            = this.isSignOffChecklistNotRequired;
        this.isStructuralNotRequired          = this.isSignOffChecklistNotRequired;
        this.isSprinklerNotRequired           = this.isSignOffChecklistNotRequired;
        this.isFireAlarmNotRequired           = this.isSignOffChecklistNotRequired;
    }

    public void save() {
        if( taskItem.No_Checklist_Required_Service__c && String.isEmpty(taskItem.Comments__c)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Please Provide the Reason why Checklist is not Required for this Service'));
            return;
        }
        if (this.isChecklistNotRequired) {
            this.isAppChecklistNotRequired          = false;
            this.isConstructionChecklistNotRequired = false;
            this.isSignOffChecklistNotRequired      = false;

        } else {
            this.isAppChecklistNotRequired          = true;
            this.isConstructionChecklistNotRequired = true;
            this.isSignOffChecklistNotRequired      = true;

        }
        try {
            update taskItem;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        }
    }

    public void cancel() {
        taskItem.No_Checklist_Required_Service__c = false;
    
    }

}