public with sharing class ErrorException extends Exception {
    public static final String TASK_ITEM_EMPTY    = 'Parameter Task Item cannot be empty.';
    public static final String TASK_ITEM_ID_EMPTY = 'Parameter task item Id cannot be empty.';
    
    public static final String CHECK_REQUEST_REQUIRED_FIELDS         = 'Fields Payee & Check Amount & Description are required.';
    public static final String CHECK_REQUEST_CHECK_NUMBER_REQUIRED   = 'You have entered Date Received field value, please provide Field Check# to proceed.';
    public static final String CHECK_REQUEST_RETURN_REASONE_REQUIRED = 'You have populated Check Returned field, please provide Return Reason to proceed.';
    public static final String CHECK_REQUEST_EMPTY                   = 'Parameter check request cannot be empty.';
    public static final String CHECK_REQUEST_SELECT_ONE              = 'Please select at least one check.';
    public static final String CHECK_REQUEST_SELECT_CHECK_REQUEST    = 'Please select at least one check request with empty received date.';
    public static final String CHECK_REQUEST_SPECIFY_CONTACT         = 'Please specify contacts for each requests.';
    public static final String CHECK_REQUEST_ONE_CONTACT_FOR_REQUEST = 'You can only publish one email at a time, but you have selected multiple check requests to be sent to different contacts. Please select requests that are being sent to the same person only.';
    public static final String CHECK_REQUEST_ONE_ONLY_INTERNAL       = 'You cannot request fee for internal Check request(s).';
    public static final String CHECK_REQUEST_SEND_AGAIN              = 'This check request was already sent with a different check amount. Please inform the appropriate parties and re-send this request.';
    
    public static final String PROJECT_ID_EMPTY = 'Parameter project id cannot be empty.';
    
    public static final String EMAIL_MESSAGE_SELECT_EMAIL_ADDRESS = 'Please specify email address.';
    public static final String EMAIL_MESSAGE_EMPTY_SUBJECT        = 'Subject cannot be empty.';
    public static final String EMAIL_MESSAGE_EMPTY_BODY           = 'Email Body cannot be empty.';
    public static final String EMAIL_MESSAGE_TOO_MANE_ADDRESS     = 'You cannot specify more than 25 email address.';
    public static final String EMAIL_MESSAGE_EMPTY_MANE           = 'Template Name cannot be empty.';
    public static final String EMAIL_MESSAGE_FOLLOW_UP_PAST_TIME  = 'Follow-Up Date time cannot be past.';
    public static final String EMAIL_MESSAGE_REMINDER_PAST_TIME   = 'Reminder Date time cannot be past.';
    
    public static final String SERVICE_ITEM_EMPTY_ID                 = 'Parameter Service Item Id can not be empty.';
    public static final String SERVICE_ITEM_NOT_SUPPORT_FUNCTIONLITY = 'This functionality is not available for current service item.';
    
    public static final String PROJECT_ROSTER_EMPTY_ROSTER_ID        = 'Parameter Project Roster Id cannot be empty.';
    public static final String PROJECT_START_DATE_EMPTY              = 'Project Start Date should be set in order installments could be calculated.';
    
    public static final String ATTACHMENT_INVALID_OBJECT_ID = 'You selected object with invalid Id. Please try another.';
    public static final String ATTACHMENT_EMPTY_OBJECT_ID   = 'You selected object with empty Id. Please try another.';
    
    public static final String VENDOR_REQUEST_SELECT_AT_LEAST_ONE      = 'Please select at least one vendor.';
    public static final String VENDOR_REQUEST_EMPTY_EMAIL              = 'Please specify email address for the selected contact(s).';
    public static final String VENDOR_REQUEST_SUCCESSFULLY_NOTIFIED    = 'Vendor(s) was successfully notified.';
    public static final String VENDOR_REQUEST_NOT_VENDOR_FOR_NOTIFY    = 'You did not select correct vendor(s) for notify.';
    public static final String VENDOR_REQUEST_CANNOT_FILL_COST         = 'Pass Through Expense is checked, please populate the Cost field.';
    public static final String VENDOR_REQUEST_CANNOT_FILL_START_DATE   = 'Scheduled Start Date can only be populated if Status of Request value equals to Vendor Proposal Accepted.';
    public static final String VENDOR_REQUEST_CANNOT_FILL_END_DATE     = 'Scheduled End Date can only be populated if Status of Request value equals to Vendor Proposal Accepted.';
    public static final String VENDOR_REQUEST_START_DATE_LESS_END_DATE = 'Scheduled End Date cannot be less than Scheduled Start Date.';
    
    public static final String SITE_URL_CANNOT_BE_FOUND = 'URL for current organization cannot be found.';
    
    public static final String RFI_SCOPE_ID_CANNOT_BE_EMPTY = 'Rfi scope Id cannot be empty.';
    public static final String RFI_SCOPE_NOT_EXIST          = 'Rfi scope does not exist.';
    
    public static final String INVOICE_ID_EMPTY = 'Parameter Invoice Id is empty.';
    
    public static final String USER_DOES_NOT_EXIST = 'User does not exist.';
    
    public static final String NUMBER_OF_INTERVAL_LESS_THAN_BILLED = 'Number of interval cannot be less or equals than number of billed intervals.';

    public static final String BAD_QUERY = 'String Parameter Passed to Database. Query is Not a Valid Query.';
    
    public static final String REGION_NAME_EMPTY = 'Region name cannot be empty.';
    public static final String PRO_FORMA_REQUIRED_FIELDS_ON_BLI = 'Please populate the necessary fields on the Billing Line Item(s).';

    public static final String NOT_VALID_OBJECT_NAME_FOR_SCHEMA_DESCRIBE = 'Object name is not valid to be selected by Schema Describe method';
    public static final String NO_CREATABLE_FIELDS_IN_OBJECT = 'There are no creatable fields in object to be selected';

    public static final String EMPTY_LIST_FOR_MILROSEDEVHELPER = 'Empty List Passed To MilroseDevHelper List Flattener';
    
    public static final String MRC_NUMBER_DOES_NOT_EXIST = 'This MRC# does not exist, please enter a valid project number.';
    
    public static final String ACCOUNT_CONTACT_CANNOT_POPULATED_MANUALLY    = 'Accounting Contact cannot be populated manually.';
    public static final String ACCOUNTING_COMPANY_CANNOT_POPULATED_MANUALLY = 'Accounting Contact Company cannot be populated manually.';
    public static final String BILLING_CLIENT_CANNOT_POPULATED_MANUALLY     = 'Billing Client cannot be populated manually.';
    public static final String PROJETC_ADDRESS_CANNOT_POPULATED_MANUALLY    = 'Project Address cannot be populated manually.';
    
    public final static String MRC_NUMBER_NOT_EXIST            = 'This MRC# does not exist, please enter a valid project number.';
    public final static String DIMENSION_1_2_MUST_BE_POPULATED = 'If MRC# is populated then Dimension 1 and Dimension 2 must also be populated for the record to save.';
    
    public final static String OPERATION_WAS_SUCCEEDED = 'Operation was succeeded.';
    public final static String SELECT_APPROPRIATE_ITEM = 'Please wait a few seconds for PDF document to completely finish generaton and click the \'Download\' button again.';
    
    public final static String LEGACY_MRC_FIELD_NOT_EDITABLE           = 'MRC# field cannot be edited.';
    public final static String LEGACY_DEPARTMENT_FIELD_IS_REQUIRED     = 'Department field is required.';
    public final static String LEGACY_PRODUCT_FIELD_IS_REQUIRED        = 'Product Name field is required.';
    public final static String LEGACY_TERRITORY_FIELD_IS_REQUIRED      = 'Territory field is required.';
    public static final String LEGACY_PRO_FORMA_REQUIRED_FIELDS_ON_BLI = 'Please populate the necessary fields on the Legacy Billing Line Item(s).';
    public static final String LEGACY_CANNOT_GENERATE_NOTE_1_PDF       = 'Credit Note 1 PDF could be generated only upon Credit Note 1 generation.';
    public static final String LEGACY_CANNOT_GENERATE_NOTE_2_PDF       = 'Credit Note 2 PDF could be generated only upon Credit Note 2 generation.';
    public static final String LEGACY_ID_IS_EMPTY                      = 'Parameter Invoice Id cannot be empty.';
    public static final String LEGACY_INVOICE_NOT_EXIST                = 'Legacy Invoice does not exist.';
    public static final String LEGACY_BILLED_SELECTED_RECORDS          = 'Some of selected records are already billed. Please repeat search.';
    
    public static final String SOBJECT_DATA_DISCREPANCY = 'SObject data discrepancy.';
    
    public static final String ROSTER_CANNOT_BE_DELETED = 'Project Roster cannot be deleted.';
    
    public static final String DOCUMENTS_IS_NOT_GENERATED = 'Please wait a few seconds for PDF document to completely finish generation and click the \'Download\' button again.';
    
    public static final String PROFORMA_PLEASE_SELECT_ONE_INVOICE = 'Please select at least one invoice.';
    
    public static final String ERROR_SETTING_PROJECT_TEAM        = 'Error setting project team';
    public static final String ERROR_CREATING_PROJECT            = 'Error creating project';
    public static final String PARAMETER_USER_ID_BUNDLE_ID_EMPTY = 'Parameters UserId and ServiceBundleId cannot be empty.';
    
    public static final String SCAN_REQUEST_EMPTY_ARTIFACT_NAME  = 'Parameter Artifact Name cannot be empty.';
    public static final String SCAN_REQUEST_UNIQUE_TITLE         = 'All active Scan Request should have a unique title. The title you entered already exists. Please modify it.';
    public static final String SCAN_REQUEST_PLEASE_CHOOSE_FOLDER = 'Please choose folder.';
    public static final String SCAN_REQUEST_INCORRECT_FILE_TYPE  = 'Incorrect file type.';
    
    public static final String EMAIL_CAN_BE_SEND_ONLY_TO_CONTACT = 'Emails can be sent to Contacts only. Please select another recipient.';
    
    public static final String REQUIRED_PARAMETER_DDP_EMPTY = 'Required parameter for DDP is empty.';
    
    // SF Limitation exceptions
    public static final String APEX_CPU_TIME_LIMIT_EXCEEDED = 'Apex CPU time limit exceeded';


    //https://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_concepts_core_data_objects.htm#i1421192
    public static Map<String, String> proposalErrorCodeToMessage = new Map<String, String> {
        'INACTIVE_OWNER_OR_USER' => 'User who is supposed to be an Owner of a Project/Service Item/Task Item is inactive. Please check Project Team and Shared Service Users are associated with selected Services.'
    };

    public static void addLog( Exception ex, String category ) {
        addLog( ex, null, null, category );
    }

    public static void addLog( sObject parentObject, String category ) {
        addLog( null, parentObject, null, category );
    }

    public static void addLog( String description, String category ) {
        addLog( null, null, description, category );
    }

    public static void addLog( Exception ex, sObject parentObject, String category ) {
        addLog( ex, parentObject, null, category );
    }

    public static void addLog( Exception ex, String description, String category ) {
        addLog( ex, null, description, category );
    }

    public static void addLog( sObject parentObject, String description, String category ) {
        addLog( null, parentObject, description, category );
    }

    public static void addLog( Exception ex, sObject parentObject, String description, String category ) {
        Debug_Log__c dl = new Debug_Log__c();
        dl.Category__c = category;
        dl.Description__c = description;
        if( parentObject != null ) {
            dl.ObjectId__c = (Id)parentObject.get('Id');
            dl.ObjectType__c = String.valueOf(  parentObject.getSobjectType() );
        }
        if( ex != null ) {
            dl.Cause__c = String.valueOf( ex.getCause() );
            dl.LineNumber__c = ex.getLineNumber();
            dl.Message__c = ex.getMessage();
            dl.StackTrace__c = ex.getStackTraceString();
            dl.TypeName__c = ex.getTypeName();
            if( dl.TypeName__c == 'System.DmlException' || dl.TypeName__c == 'System.EmailException' ) {
                for( Integer i = 0; i < ex.getNumDml(); i++ ) {
                    dl.Number__c = i;
                    if( ex.getDmlFieldNames(i) != null ) {
                        dl.DmlFieldNames__c = String.join( ex.getDmlFieldNames(i), '; ' );
                    }
                    if( ex.getDmlFields(i) != null ) {
                        dl.DmlFields__c = '';
                        for( Schema.sObjectField field : ex.getDmlFields(i) ) {
                            dl.DmlFields__c += field + '; ';
                        }
                        dl.DmlFields__c = dl.DmlFields__c.removeEnd( '; ' );
                    }
                    dl.DmlIndex__c = ex.getDmlIndex(i);
                    dl.DmlMessage__c = ex.getDmlMessage(i);
                    dl.DmlType__c = String.valueOf( ex.getDmlType(i) );
                    dl.NumDml__c = ex.getNumDml();
                }
            }
        }
        //System.debug( LoggingLevel.Error, 'xxx Debug Log Added: ' + dl );
        try {
            INSERT dl;
        } catch( DmlException dlDmlEx ) {
        }
    }

}