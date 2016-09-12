public with sharing class DDPEmailServices {
    private static final String DDP_NAME_EMPTY                       = 'DDP Name parameter cannot be empty!';
    private static final String DELIVERY_METHOD_EMPTY                = 'Delivery method parameter cannot be empty!';
    private static final String TARGET_ID_EMPTY                      = 'Target Id parameter cannot be empty!';
    private static final String INTEGRATION_OPTION_NOT_EXIST         = 'System cannot find integration option. Please contact your system administrator.';
    public static final String MAIN_RECORD_ID_EMPTY                  = 'Main Record Id parameter cannot be empty!';
    public static final String EXCEPTION_DDP_CONFIGURATION_NOT_VALID = 'DDP Name or delivery Method are not valid!';

    /* Begin DDP Names */
    public static final String DDP_NAME_SEND_ATTACHMENT_PROJECT        = 'Send Attachments (Project)';
    public static final String DDP_NAME_SEND_ATTACHMENT_FORMS_FOR_PROJECT = 'Send Attachments (Forms For Project)';
    public static final String DDP_NAME_SEND_ATTACHMENT_SERVICE_ITEM   = 'Send Attachments (Service Item)';
    public static final String DDP_NAME_MANAGE_RESPONSE_FROM_AUTHORITY = 'Manage Response from Authority';
    public static final String DDP_NAME_TASK_ITEM_FUNCTIONALITY        = 'Task Item Functionality';
    public static final String DDP_NAME_TRANSMITTAL_DOCUMENT           = 'Transmittal Document';
    public static final String DDP_NAME_TRANSMITTAL_DOCUMENT_TASK_ITEMS_FOR_PROJECT = 'Transmittal Document Task Items For Project';
    public static final String DDP_NAME_TRANSMITTAL_DOCUMENT_PROJECT   = 'Transmittal Document Project';
    public static final String DDP_NAME_TRANSMITTAL_DOCUMENT_CONTACT   = 'Transmittal Document Contact';
    public static final String DDP_NAME_SEND_EMAIL_FROM_ENTITY         = 'Send Email From Entity';
    public static final String DDP_NAME_CREATE_LEGACY_INVOICE          = 'Create Legacy Invoice';
    public static final String DDP_NAME_CREATE_SEND_LEGACY_INVOICE     = 'Create & Send Legacy Invoice';
    public static final String DDP_NAME_PRO_FORMA_INVOICE_BATCH        = 'Pro-forma Invoice Batch';
    public static final String DDP_NAME_PREPARE_FILING_PACKAGE         = 'Prepare Filing Package';
    public static final String DDP_NAME_CREATE_LEGACY_CREDIT_1         = 'Create Legacy Credit 1';
    public static final String DDP_NAME_CREATE_LEGACY_CREDIT_2         = 'Create Legacy Credit 2';
    public static final String DDP_NAME_CREATE_INVOICES                = 'Create Invoices';
    public static final String DDP_NAME_JOIN_LEGACY_PDF                = 'Join Legacy Invoice PDF';
    public static final String DDP_NAME_JOIN_INVOICE_PDF               = 'Join Invoices Together';
    public static final String DDP_NAME_SEND_LETTER                    = 'Send Letter';
    public static final String DDP_NAME_ATTACH_LETTER_PROJECT          = 'Attach Letter To Project';
    public static final String DDP_NAME_ATTACH_LETTER_SERVICE          = 'Attach Letter To Service Item';
    public static final String DDP_NAME_ATTACH_LETTER_TASK             = 'Attach Letter To Task Item';
    public static final String DDP_NAME_UPLOAD_DOC_FROM_ATTACHMENT_TO_PROPOSAL = 'Upload Stored Document From Attachment To Proposal';
    public static final String DDP_NAME_UPLOAD_DOC_FROM_ATTACHMENT_TO_TASK     = 'Upload Stored Document From Attachment To Task';
    /* End DDP Names */

    /* Begin Delivery methods name */
    public static final String DELIVERY_METHOD_EMAIL = 'Email';
    public static final String DELIVERY_METHOD_ATTACH = 'Attach';
    public static final String DELIVERY_METHOD_DOWNLOAD = 'Download';
    public static final String DELIVERY_METHOD_DOCUSIGN = 'Docusign';
    //public static final String DELIVERY_METHOD_DOCUSIGN_FOLLOWUP = 'Docusign (Follow Up)';
    public static final String DELIVERY_METHOD_EMAIL_FOLLOWUP = 'Email (Follow Up)';
    public static final String DELIVERY_METHOD_CLASSIC_SUFFIX = ' (Classic)';
    /* End Delivery methods name */
    
    public static final String EMAIL_FOLLOWUP_FUNCTIONALITY = 'Email (Follow Up)';
    public static final String EMAIL_RESEND_FUNCTIONALITY = 'Email (Resend)';

    public static PageReference createDDPLoopPlus(final String DDPName, final String deliveryMethod, final Id targetId, final Id contactId, final String parentIds, final String retURL, final String attachments, Boolean isDdpIdsRequired) {
        if (String.isBlank(DDPName)) {
            throw new ErrorException(DDP_NAME_EMPTY);

        }

        if (String.isBlank(deliveryMethod)) {
            throw new ErrorException(DELIVERY_METHOD_EMPTY);

        }

        if (String.isBlank(targetId)) {
            throw new ErrorException(TARGET_ID_EMPTY);

        }

        List<Loop__DDP_Integration_Option__c> ddpIntegration = [SELECT Id, Loop__DDP__c
                                                                FROM Loop__DDP_Integration_Option__c
                                                                WHERE Loop__DDP__r.Name =: DDPName AND Name =: deliveryMethod limit 1];

        if (ddpIntegration.isEmpty()) {
            throw new ErrorException(INTEGRATION_OPTION_NOT_EXIST);

        }

        PageReference page = new PageReference('/apex/loop__looplus');
        page.getParameters().put('autorun', 'true');
        page.getParameters().put('eid', targetId);
        if (isDdpIdsRequired) {
            page.getParameters().put('ddpIds', ddpIntegration[0].Loop__DDP__c);

        }
        page.getParameters().put('deploy', ddpIntegration[0].Id);
        if (!String.isBlank(retURL)) {
            page.getParameters().put('retURL', retURL); //Url.getSalesforceBaseUrl().toExternalForm() +

        }
        if (!String.isBlank(attachments)) {
            page.getParameters().put('attachIds', attachments);

        }
        if (!String.isBlank(parentIds)) {
            page.getParameters().put('parentIds', parentIds);

        }

        if (deliveryMethod.equals(DDPEmailServices.DELIVERY_METHOD_EMAIL) && !String.isBlank(contactId)) {
            page.getParameters().put('contactId', contactId);

        }

        page.setRedirect(true);
        return page;

    }

    public static Loop__DDP_Integration_Option__c getDDPIntegrationOption( String ddpName, String ddpDeliveryMethod ){
        List<Loop__DDP_Integration_Option__c> ddpIntegrationsList = new List<Loop__DDP_Integration_Option__c>([SELECT Id, Loop__DDP__c
                                                                                                               FROM Loop__DDP_Integration_Option__c
                                                                                                               WHERE Loop__DDP__r.Name =: ddpName AND Name =: ddpDeliveryMethod limit 1]);

        return ddpIntegrationsList.isEmpty() ? new Loop__DDP_Integration_Option__c() : ddpIntegrationsList[0];

    }

    public static Map<Id, Loop__DDP__c> getDDPMap( Set<String> ddpNames ){
        return new Map<Id, Loop__DDP__c>([SELECT Name, Id, (SELECT Id, Name FROM Loop__Custom_Integration_Options__r) FROM Loop__DDP__c WHERE Name IN: ddpNames ]);
    }

    public static void sendDDPEmail( Id mainRecordId, String ddpName, String ddpDeliveryMethod, Id accountId, Id contactId, Id otherObjectId, List<Id> attachments){
        if( String.isBlank( mainRecordId ) ){
            throw new ErrorException( MAIN_RECORD_ID_EMPTY );
        }
        Loop__DDP_Integration_Option__c ddpIntegrationOption = getDDPIntegrationOption( ddpName, ddpDeliveryMethod );

        if( ddpIntegrationOption.Id == null ){
            throw new ErrorException( EXCEPTION_DDP_CONFIGURATION_NOT_VALID );
        }
        Map<String, String> requestConfiguration = new Map<String, String>{'deploy' => ddpIntegrationOption.Id }; //DELIVERY (FTP)
        if( accountId != null) requestConfiguration.put('SFAccount', accountId); //SAMPLE ACCOUNT ID
        if( contactId != null) requestConfiguration.put('SFContact', contactId); // SAMPLE CONTACT ID
        if( otherObjectId != null) requestConfiguration.put('SFOther_Object__c', otherObjectId); // OTHER OBJECT ID
        if( attachments != null) requestConfiguration.put('attachIds', String.join( attachments, '|'));

        Loop.loopMessage lm = new Loop.loopMessage();
        lm.requests.add(new Loop.loopMessage.loopMessageRequest(
            mainRecordId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
            ddpIntegrationOption.Loop__DDP__c, //DDP ID
            requestConfiguration
        ));
        // SEND DDP RUN REQUEST IN A SINGLE CALL OUT
        lm.sendAllRequests();
    }

    public static void generateAndAttachPDF(final Id mainRecordId, final String ddpName, final Id accountId, final Id contactId, final Id otherObjectId, List<Id> attachments) {
        if (String.isBlank(mainRecordId)) {
            throw new ErrorException(MAIN_RECORD_ID_EMPTY);

        }

        Loop__DDP_Integration_Option__c ddpIntegrationOption = getDDPIntegrationOption(ddpName, DELIVERY_METHOD_ATTACH);
        if (String.isBlank(ddpIntegrationOption.Id)) {
            throw new ErrorException(EXCEPTION_DDP_CONFIGURATION_NOT_VALID);

        }

        Map<String, String> requestConfiguration = new Map<String, String>{ 'deploy' => ddpIntegrationOption.Id }; //DELIVERY (FTP)

        if (!String.isBlank(accountId)) {
            requestConfiguration.put('SFAccount', accountId); //SAMPLE ACCOUNT ID

        }

        if (!String.isBlank(contactId)) {
            requestConfiguration.put('SFContact', contactId); // SAMPLE CONTACT ID

        }

        if (!String.isBlank(otherObjectId)) {
            requestConfiguration.put('SFOther_Object__c', otherObjectId); // OTHER OBJECT ID

        }

        if (null != attachments && !attachments.isEmpty()) {
            requestConfiguration.put('attachIds', String.join( attachments, '|'));

        }

        Loop.loopMessage lm = new Loop.loopMessage();
        lm.requests.add(new Loop.loopMessage.loopMessageRequest(
                                                 mainRecordId, // MAIN RECORD ID - SAME OBJECT AS THE DDP RECORD TYPE SPECIFIES
                                                 ddpIntegrationOption.Loop__DDP__c, //DDP ID
                                                 requestConfiguration));
        // SEND DDP RUN REQUEST IN A SINGLE CALL OUT
        lm.sendAllRequests();

    }

}