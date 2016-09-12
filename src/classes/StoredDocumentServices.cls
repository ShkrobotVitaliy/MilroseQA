public class StoredDocumentServices {
    public static final String DRAWINGS_FILE_TYPE = 'Drawings';
    public static final String DOCUMENTS_FILE_TYPE = 'Additional Documents';
    public static final String PROPOSALS_FILE_TYPE = 'Proposal & CO';
    //public static final String PROPOSALS_FILE_TYPE = 'Proposals';
    public static final String PROJECT_PROFILES_FILE_TYPE = 'Project Profiles';
    public static final String FOLDER_FILE_TYPE = 'Folder';
    public static final String FORMS_FILE_TYPE = 'Generated Forms';
    public static final String ACCOUNTING_FILE_TYPE = 'Accounting Documents';
    public static final String OTHER_FILE_TYPE = 'Other';

    public static final String DOCUMENT_TYPE = 'Document';
    public static final String DRAWING_TYPE = 'Drawing';
    public static final String DOCUMENT_RECORDTYPE = 'Document';
    public static final String FOLDER_RECORDTYPE = 'Folder';

    // Accounting Documents
    public static final String PROPOSAL_DOCUMENT = 'Proposal';
    public static final String CHANGE_ORDER_DOCUMENT = 'Change Order#';
    public static final String CHANGE_ORDER_FILENAME = 'Change Order';
    public static final String RETAINER_INVOICE_DOCUMENT = 'Retainer Invoice';
    public static final String RETAINER_INVOICE_DOCUMENT_WITHOUT_SPACE = 'RetainerInvoice';
    public static final String PROFORMA_INVOICE_DOCUMENT = 'Pro-forma Invoice';
    public static final String DOCUMENT_SHREDDING_DOCUMENT = 'Document Shredding';
    public static final String MET_DATA_SCANNING_DOCUMENT = 'Met Data Scanning';
    public static final String SUPREME_SYSTEMS_DOCUMENT = 'Supreme Systems';
    public static final String FEDEX_DOCUMENT = 'FedEx';
    public static final String CREDIT_NOTE_DOCUMENT = 'Credit Note';
    public static final String STATEMENT_OF_ACCOUNTS_DOCUMENT = 'Statement of Accounts';
    public static final String ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT = 'Account Summary Recap Report';
    public static final String DEPOSIT_DETAIL_REPORT_DOCUMENT = 'Deposit Detail Report';
    public static final String LEGACY_PROFORMA_INVOICE_DOCUMENT = 'Legacy Pro-forma Invoice';
    public static final String LEGACY_CREDIT_NOTE_DOCUMENT = 'Legacy Credit Note';
    public static final String TRANSMITTAL_DOCUMENT = 'Transmittal';
    public static final String PROJECT_LABEL_DOCUMENT = 'Project Label.pdf';
    public static final String RFP_DOCUMENTS_FOLDER = 'Additional Attachments';
    public static final String RFP_ARTIFACTS_FOLDER = 'RFP Artifacts';
    public static final String PDF_EXTENSION = '.pdf';

    //document prefixes for search
    public static final String PROFORMA_INVOICE_DOC_NAME_PREFIX = 'Invoice 14';
    public static final String CREDIT_NOTE_DOC_NAME_PREFIX_1 = 'Credit 1 14';
    public static final String CREDIT_NOTE_DOC_NAME_PREFIX_2 = 'Credit 2 14';
    public static final String LEFACY_PROFORMA_INVOICE_DOC_NAME_PREFIX = 'Legacy Invoice 13';
    public static final String LEGACY_CREDIT_NOTE_DOC_NAME_PREFIX_1 = 'Credit 1 13';
    public static final String LEGACY_CREDIT_NOTE_DOC_NAME_PREFIX_2 = 'Credit 2 13';

    public static final String PROJEC_LABEL_KEYWORD = 'Label';

    //Financial documents names
    public static final Set<String> PROPOSAL_FINANCIAL_DOCUMENTS_NAMES = new Set<String>{'Change Order', 'Proposal', 'Retainer Invoice', 'Non-Fee Proposal'};
    public static final Set<String> PROJECT_FINANCIAL_DOCUMENTS_NAMES = new Set<String>{'Account Summary Recap Report'};

    //docusign data
    public static final String DOCUSIGN_COMPLETED_SUFFIX_OLD = '_Completed';
    public static final String DOCUSIGN_COMPLETED_SUFFIX_NEW = 'Signed';
    public static final String DOCUSIGN_SIGNED_ON_PAPER_OLD = 'Signed-on-Paper_';
    public static final String DOCUSIGN_SIGNED_ON_PAPER_NEW = 'Signed on Paper';

    public static Id FOLDER_RECORD_TYPE_ID {
        get {
            if( FOLDER_RECORD_TYPE_ID == null ) {
                FOLDER_RECORD_TYPE_ID = [ SELECT Id, Name, DeveloperName, SobjectType
                                            FROM RecordType
                                            WHERE SobjectType = 'LStore__Stored_Document__c'
                                               AND DeveloperName = 'Folder' LIMIT 1 ][0].Id;
            }
            return FOLDER_RECORD_TYPE_ID;
        }
        private set;
    }

    public static Id FORMS_RECORD_TYPE_ID {
        get {
            if( FORMS_RECORD_TYPE_ID == null ) {
                FORMS_RECORD_TYPE_ID = [ SELECT Id, Name, DeveloperName, SobjectType
                                            FROM RecordType
                                            WHERE SobjectType = 'LStore__Stored_Document__c'
                                               AND DeveloperName = 'Forms' LIMIT 1 ][0].Id;
            }
            return FORMS_RECORD_TYPE_ID;
        }
        private set;
    }

    public static Id DOCUMENT_RECORD_TYPE_ID {
        get {
            if( DOCUMENT_RECORD_TYPE_ID == null ) {
                DOCUMENT_RECORD_TYPE_ID = [ SELECT Id, Name, DeveloperName, SobjectType
                                            FROM RecordType
                                             WHERE SobjectType = 'LStore__Stored_Document__c'
                                              AND DeveloperName = 'Document' LIMIT 1 ][0].Id;
            }
            return DOCUMENT_RECORD_TYPE_ID;
        }
        private set;
    }
    public static Id DRAWINGS_RECORD_TYPE_ID {
        get {
            if( DRAWINGS_RECORD_TYPE_ID == null ) {
                DRAWINGS_RECORD_TYPE_ID = [ SELECT Id, Name, DeveloperName, SobjectType
                                            FROM RecordType
                                            WHERE SobjectType = 'LStore__Stored_Document__c'
                                               AND DeveloperName = 'Drawings' LIMIT 1 ][0].Id;
            }
            return DRAWINGS_RECORD_TYPE_ID;
        }
        private set;
    }

    public static void cloneRelatedObjectIdField( List<LStore__Stored_Document__c> docs ) {
        for( LStore__Stored_Document__c doc : docs ) {
            doc.Related_Object_Id__c = doc.LStore__Related_Object_Id__c;
        }
    }

    public static List<LStore__Stored_Document__c> getStoredDocumentFolder(Id folderRecordTypeId, String storageFolderName, String rfiScopeId) {
        return new List<LStore__Stored_Document__c>([ SELECT RecordType.DeveloperName, RecordTypeId, LStore__Related_Object_Id__c, LStore__File_Name__c
                                                      FROM LStore__Stored_Document__c
                                                      WHERE RecordTypeId = : folderRecordTypeId
                                                         AND LStore__File_Name__c =: storageFolderName
                                                         AND Related_Object_Id__c =: rfiScopeId LIMIT 1 ]);

    }


    public static List<LStore__Stored_Document__c> getStoredDocumentList( Id recordId ) {
        return new List<LStore__Stored_Document__c>( [ SELECT LStore__Related_Object_Id__c, LStore__File_Name__c, LStore__Folder__c
                                                       FROM LStore__Stored_Document__c
                                                       WHERE RecordTypeId = :DOCUMENT_RECORD_TYPE_ID
                                                       AND LStore__Folder__c = :[ SELECT Id, Name FROM LStore__Stored_Document__c
                                                                                  WHERE LStore__File_Name__c = :DRAWINGS_FILE_TYPE
                                                                                  AND Related_Object_Id__c like :recordId LIMIT 1 ]
                                                       AND Related_Object_Id__c like :recordId
                                                       ] );
    }

    public static void updateName( List<LStore__Stored_Document__c> incommintDocuments ) {
        for( LStore__Stored_Document__c storedDoc : incommintDocuments ) {
            if(storedDoc.RecordTypeId == DOCUMENT_RECORD_TYPE_ID) {
                storedDoc.Name = storedDoc.LStore__File_Name__c.left(80);
            }
	}
    }

    public static Map<String, List<LStore__Stored_Document__c>> filterStoredDocuments( List<LStore__Stored_Document__c> incommintDocuments ) {
        Map<String, List<LStore__Stored_Document__c>> filteredDocumentsByTypes = new Map<String, List<LStore__Stored_Document__c>>();

        filteredDocumentsByTypes.put( DRAWINGS_FILE_TYPE, new List<LStore__Stored_Document__c>() );
        filteredDocumentsByTypes.put( DOCUMENTS_FILE_TYPE, new List<LStore__Stored_Document__c>() );

        for( LStore__Stored_Document__c storedDoc : incommintDocuments ) {
            if(storedDoc.RecordTypeId == DOCUMENT_RECORD_TYPE_ID) {
                storedDoc.Name = storedDoc.LStore__File_Name__c;
            }

            if( storedDoc.Folder_Name__c != null &&
                ( storedDoc.Folder_Name__c.equals( DRAWINGS_FILE_TYPE ) ||
                   storedDoc.Folder_Name__c.equals( DOCUMENTS_FILE_TYPE ) ) ) {
                filteredDocumentsByTypes.get( storedDoc.Folder_Name__c ).add( storedDoc );
            }
        }
        return filteredDocumentsByTypes;
    }

    public static void populateRequiredFields( Map<String, List<LStore__Stored_Document__c>> groupedDocumentsByTypes ) {
        Map<Id, Id> objectIdToAccountId = new Map<Id, Id>();

        for( String recordType : groupedDocumentsByTypes.keySet() ) {
            if( recordType.equals( DRAWINGS_FILE_TYPE ) ) { // Populate required fields for Drawings artifact
                for( LStore__Stored_Document__c doc : groupedDocumentsByTypes.get( recordType ) ) {
                    if( MilroseDevHelper.isIdsObjectTypeEqualToStringObjectType( doc.LStore__Related_Object_Id__c, 'Project_Profile__c' ) ) {
                        doc.Project__c = (Id)doc.LStore__Related_Object_Id__c;
                        objectIdToAccountId.put( doc.Project__c, null );
                    } else if( MilroseDevHelper.isIdsObjectTypeEqualToStringObjectType( doc.LStore__Related_Object_Id__c, 'Service_Item__c' ) ) {
                        doc.Service_Item__c = (Id)doc.LStore__Related_Object_Id__c;
                        objectIdToAccountId.put( doc.Service_Item__c, null );
                    } else if( MilroseDevHelper.isIdsObjectTypeEqualToStringObjectType( doc.LStore__Related_Object_Id__c, 'Task_Item__c' ) ) {
                        doc.Task_Item__c = (Id)doc.LStore__Related_Object_Id__c;
                        objectIdToAccountId.put( doc.Task_Item__c, null );
                    } else if( MilroseDevHelper.isIdsObjectTypeEqualToStringObjectType( doc.LStore__Related_Object_Id__c, 'Building__c' ) ) {
                        doc.Address__c = (Id)doc.LStore__Related_Object_Id__c;
                        objectIdToAccountId.put( doc.Address__c, null );
                    }
                }
            }
        }
    }

    public static List<LStore__Stored_Document__c> getStoredDocumentByRelatedId(String Id) {
        system.debug('Id: ' + Id);
        return [ Select Id, Drawings_Title__c, Folder_Name__c, Drawing_Number__c, Drawing_Revision_Date__c, LStore__Description__c, RecordTypeId, LStore__Folder__r.RecordTypeId, LStore__Folder__r.LStore__File_Name__c, LStore__Folder__c
                 From LStore__Stored_Document__c Where Related_Object_Id__c = : Id Order By CreatedDate Desc ]; // LIMIT
    }

    public static List<LStore__Stored_Document__c> getStoredDocumentByRelatedIds(Set<Id> ids) {
        if (null == ids) {
            return new List<LStore__Stored_Document__c>();

        }
        return new List<LStore__Stored_Document__c> ([SELECT Id, Drawings_Title__c, Drawing_Number__c, Drawing_Revision_Date__c, LStore__Description__c,
                                                             LStore__File_Name__c, Name, LStore__External_Id__c, CreatedDate,
                                                             LStore__Folder__r.RecordTypeId, RecordTypeId, LStore__File_Size_Calc__c, Folder_Name__c,
                                                             LStore__Related_Object_Id__c, LStore__File_Size__c
                                                      FROM LStore__Stored_Document__c
                                                      WHERE Related_Object_Id__c IN: ids ORDER BY CreatedDate DESC LIMIT 200]);

    }

    public static List<LStore__Stored_Document__c> getStoredDocumentByRelatedIds(Set<Id> ids, Integer recordLimit, Datetime generatedDate) {
        if (null == ids) {
            return new List<LStore__Stored_Document__c>();

        }

        if (null == recordLimit || recordLimit <= 0) {
            recordLimit = 200;

        }

        return new List<LStore__Stored_Document__c> ([SELECT Id, Drawings_Title__c, Drawing_Number__c, Drawing_Revision_Date__c, LStore__Description__c,
                                                             LStore__File_Name__c, Name, LStore__External_Id__c, CreatedDate, Related_Object_Id__c,
                                                             LStore__Folder__r.RecordTypeId, RecordTypeId, LStore__File_Size_Calc__c, Folder_Name__c,
                                                             LStore__Related_Object_Id__c, LStore__File_Size__c
                                                      FROM LStore__Stored_Document__c
                                                      WHERE Related_Object_Id__c IN: ids AND CreatedDate >: generatedDate
                                                      ORDER BY Pro_forma_Invoice__r.A_R_Coordinator_Full_Name__c, Pro_forma_Invoice__r.Billing_Client_Company__r.Name LIMIT: recordLimit]);

    }

    public static List<LStore__Stored_Document__c> getStoredDocumentsNotFinancial(Set<Id> relatedObjectIdSet) {
        if (null == relatedObjectIdSet) {
            throw new ErrorException('List of related objects id cannot be empty!');
        }
        List<LStore__Stored_Document__c> filteredDocuments = new List<LStore__Stored_Document__c> ();
        String proposalObjectKeyPrefix = Schema.SObjectType.Proposal__c.getKeyPrefix();
        String projectProfileObjectKeyPrefix = Schema.SObjectType.Project_Profile__c.getKeyPrefix();

        for(LStore__Stored_Document__c document: [SELECT Id, Drawings_Title__c, Drawing_Number__c, Drawing_Revision_Date__c, LStore__Related_Object_Id__c,
                                                    LStore__Description__c, LStore__File_Name__c, Name, LStore__External_Id__c, LStore__File_Size__c, Form_Item_Copy__c, Form_Item_Copy__r.Form_Row_Number_For_Send_And__c,
                                                    LStore__Folder__r.RecordTypeId, RecordTypeId, LStore__File_Size_Calc__c, Folder_Name__c, CreatedDate, LStore__Type__c
                                                    FROM LStore__Stored_Document__c
                                                    WHERE Related_Object_Id__c IN : relatedObjectIdSet AND RecordTypeId != : FOLDER_RECORD_TYPE_ID]){
            //Exclude documents with financial information
            Boolean excludeDocument = false;
            if( document.LStore__Related_Object_Id__c.startsWith(proposalObjectKeyPrefix) ){
                for(String financeName: PROPOSAL_FINANCIAL_DOCUMENTS_NAMES){
                    if( document.LStore__File_Name__c.contains(financeName) ){
                        excludeDocument = true;
                        break;
                    }
                }
                if( excludeDocument ) continue;
            }else if( document.LStore__Related_Object_Id__c.startsWith(projectProfileObjectKeyPrefix) ){
                for(String financeName: PROJECT_FINANCIAL_DOCUMENTS_NAMES){
                    if( document.LStore__File_Name__c.contains(financeName) ){
                        excludeDocument = true;
                        break;
                    }
                }
                if( excludeDocument ) continue;
            }
            filteredDocuments.add(document);
        }

        return filteredDocuments;
    }

   public static String buildWhereQuery(LStore__Stored_Document__c lStoreDocument, FilterFields  filterFields) {
        system.debug('filterFields: ' + filterFields);
        String queryWhere = 'WHERE RecordTypeId != \''+FOLDER_RECORD_TYPE_ID+'\' ';

        if (lStoreDocument.Artifacts_Category__c == OTHER_FILE_TYPE){
            if ( !String.isBlank(lStoreDocument.Drawings_Title__c) ){
                queryWhere += 'AND ( ( Name Like \'%' + lStoreDocument.Drawings_Title__c + '%.pdf\' AND Task_Item__c != null AND Drawings_Title__c = \'' + TRANSMITTAL_DOCUMENT + '\')';
                queryWhere += ' OR ( Drawings_Title__c Like \'%' + lStoreDocument.Drawings_Title__c + '%\' ) )';
            }
        } else {
            queryWhere += buildQueryWhere('Drawings_Title__c', lStoreDocument.Drawings_Title__c);
        }
        queryWhere += buildQueryWhere('LStore__Description__c', lStoreDocument.LStore__Description__c);
        queryWhere += buildQueryWhere('Drawing_Number__c', lStoreDocument.Drawing_Number__c);
        queryWhere += buildQueryWhere('Worktype__c', lStoreDocument.Worktype__c);
        queryWhere += buildQueryWhere('LStore__Keywords__c', lStoreDocument.LStore__Keywords__c);
        queryWhere += buildQueryWhere('Tenant__c', lStoreDocument.Tenant__c);
        queryWhere += buildQueryWhere('Municipal_Description_ID__c', lStoreDocument.Municipal_Description_ID__c);

        if(String.isNotBlank(lStoreDocument.Artifacts_Category__c)) {
            if( lStoreDocument.Artifacts_Category__c == ACCOUNTING_FILE_TYPE ){
                if( filterFields.typeObjectKeyPrefix == '' || filterFields.typeObjectKeyPrefix == Schema.SObjectType.Proposal__c.getKeyPrefix() ){
                    queryWhere += ' AND (Folder_Name__c = \'' + PROPOSALS_FILE_TYPE +'\' OR Folder_Name__c = null ) ';
                } else if( filterFields.typeObjectKeyPrefix == Schema.SObjectType.Proposal__c.getKeyPrefix() ){
                    queryWhere += ' AND Folder_Name__c = \'' + PROPOSALS_FILE_TYPE +'\' ';
                } else {
                    queryWhere += ' AND Folder_Name__c = null ';
                }
            } else if ( lStoreDocument.Artifacts_Category__c == OTHER_FILE_TYPE ) {
                queryWhere += ' AND ( (Folder_Name__c != \'' + DOCUMENTS_FILE_TYPE + '\' AND ' +
                                    'Folder_Name__c != \'' + DRAWINGS_FILE_TYPE + '\' AND ' +
                                    'Folder_Name__c != \'' + FORMS_FILE_TYPE + '\' AND ' +
                                    'Folder_Name__c != \'' + PROPOSALS_FILE_TYPE + '\' AND ' +
                                    'Folder_Name__c != \'' + ACCOUNTING_FILE_TYPE + '\') OR ' +
                                    'Folder_Name__c = null ) ';
            } else {
                queryWhere += ' AND Folder_Name__c = \''+ lStoreDocument.Artifacts_Category__c +'\' ';
            }

        }
        if(lStoreDocument.Drawing_Revision_Date__c != null) {
            datetime dateNewInst = datetime.newInstance( lStoreDocument.Drawing_Revision_Date__c.year(), lStoreDocument.Drawing_Revision_Date__c.month(), lStoreDocument.Drawing_Revision_Date__c.day(), 0,0,0 );
            String dateTimeMinFormat = dateNewInst.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

            datetime dateMax = dateNewInst.addDays(1);
            String dateTimeMaxFormat = dateMax.formatGmt('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            queryWhere += ' AND ( CreatedDate >= '+ dateTimeMinFormat +' AND CreatedDate < '+ dateTimeMaxFormat +' ) ';
        }

        queryWhere += buildQueryWhere('Address__r.Name', filterFields.address);
        queryWhere += buildQueryWhere('Change_Order__r.Name', filterFields.changeOrderNumber);
        queryWhere += buildQueryWhere('Municipal_Form_Type_Name__c', filterFields.municipalFormTypeName);
        queryWhere += buildQueryWhere('Purchase_Order__r.Name', filterFields.purcaseOrder);
        queryWhere += buildQueryWhere('Service_Item__r.Name', filterFields.serviceItemNumber);
        queryWhere += buildQueryWhere('Task_Item__r.GUID__c', filterFields.taskItemNumber);
        queryWhere += buildQueryWhere('CreatedBy.Name', filterFields.createdByName);
        queryWhere += buildQueryWhere('Form_Item_Copy__r.Form_Id__c', filterFields.formNamber);
        queryWhere += buildQueryWhere('Form_Item_Copy__r.Short_Form_Name__c', filterFields.shortName);
        queryWhere += buildQueryWhere('Form_Item_Copy__r.Form_Name__c', filterFields.longName);
        queryWhere += buildQueryWhere('Form_Item_Copy__r.Region_Name__c', filterFields.formRegion);
        queryWhere += buildQueryWhere('Proposal__r.Status__c', filterFields.statusProposal);

        if (! String.isBlank(filterFields.author)) {
            queryWhere += ' AND (Contact__r.Name LIKE \'%'+ filterFields.author +'%\' ';
            queryWhere += ' OR User__r.Name LIKE \'%'+ filterFields.author +'%\') ';
        }

        if (! isLegacyDocument(filterFields) ){
            queryWhere += buildQueryWhere('Project__r.Name', filterFields.projectNamber);
            queryWhere += buildQueryWhere('Project__r.Project_Name__c', filterFields.projectName);
            queryWhere += buildQueryWhere('Proposal__r.Name', filterFields.proposalNumber);

        } else {
            queryWhere += buildQueryWhere('Project_Mi7__r.MRC__c', filterFields.projectNamber);
            queryWhere += buildQueryWhere('Project_Mi7__r.Name', filterFields.projectName);
        }

        if (String.isNotBlank(filterFields.typeObjectKeyPrefix)) {
            queryWhere += ' AND ( ';
            queryWhere += ' LStore__Related_Object_Id__c LIKE \''+ filterFields.typeObjectKeyPrefix +'%\' ';

            if( lStoreDocument.Artifacts_Category__c.equalsIgnoreCase('Generated Forms')
                && filterFields.typeObjectKeyPrefix.startsWith( Schema.SObjectType.Task_Item__c.getKeyPrefix() ) ) {

                queryWhere += 'OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Form_Meta_Data_Object_1__c.getKeyPrefix() +'%\' ';
            }

            queryWhere += ') ';

        } else {

            if( lStoreDocument.Artifacts_Category__c == ACCOUNTING_FILE_TYPE ){
                queryWhere += ' AND ( ';
                queryWhere += ' LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Proposal__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Project_Profile__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Pro_forma_Invoice__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Account.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Deposit_Invoice__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Legacy_Pro_forma_Invoice__c.getKeyPrefix() +'%\' ';
                queryWhere += ') ';
            } else {
                queryWhere += ' AND ( ';
                queryWhere += ' LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Proposal__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Project_Profile__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Task_Item__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Service_Item__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.RFI_Scope__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Form_Meta_Data_Object_1__c.getKeyPrefix() +'%\' ';
                queryWhere += ' OR LStore__Related_Object_Id__c LIKE \''+ Schema.SObjectType.Building__c.getKeyPrefix() +'%\' ';
                queryWhere += ') ';
            }
        }

        if ( String.isNotBlank( filterFields.accountingDocTypeObjectKeyPrefix ) ) {

            if( filterFields.accountingDocTypeObjectKeyPrefix == PROFORMA_INVOICE_DOCUMENT ){
                queryWhere += ' AND LStore__File_Name_Calc__c LIKE \''+ PROFORMA_INVOICE_DOC_NAME_PREFIX + '%\' ';

            } else if( filterFields.accountingDocTypeObjectKeyPrefix == RETAINER_INVOICE_DOCUMENT){
                queryWhere += ' AND LStore__File_Name_Calc__c LIKE \'%' + RETAINER_INVOICE_DOCUMENT + '%\' ';
                queryWhere += 'AND Drawings_Title__c = \'' + RETAINER_INVOICE_DOCUMENT + '\'';

            } else if( filterFields.accountingDocTypeObjectKeyPrefix == LEGACY_PROFORMA_INVOICE_DOCUMENT){
                queryWhere += ' AND LStore__File_Name_Calc__c LIKE \'' + LEFACY_PROFORMA_INVOICE_DOC_NAME_PREFIX + '%\' ';

            } else if( filterFields.accountingDocTypeObjectKeyPrefix == LEGACY_CREDIT_NOTE_DOCUMENT){
                queryWhere += ' AND ( LStore__File_Name_Calc__c LIKE \'' + LEGACY_CREDIT_NOTE_DOC_NAME_PREFIX_1 + '%\' OR ';
                queryWhere += ' LStore__File_Name_Calc__c LIKE \'' + LEGACY_CREDIT_NOTE_DOC_NAME_PREFIX_2 + '%\' ) ';

            } else if( filterFields.accountingDocTypeObjectKeyPrefix == CREDIT_NOTE_DOCUMENT){
                queryWhere += ' AND ( LStore__File_Name_Calc__c LIKE \'' + CREDIT_NOTE_DOC_NAME_PREFIX_1 + '%\' OR ';
                queryWhere += ' LStore__File_Name_Calc__c LIKE \'' + CREDIT_NOTE_DOC_NAME_PREFIX_2 + '%\' )';

            } else if( filterFields.accountingDocTypeObjectKeyPrefix == DEPOSIT_DETAIL_REPORT_DOCUMENT){
                queryWhere += ' AND ( LStore__File_Name_Calc__c LIKE \'%' + DEPOSIT_DETAIL_REPORT_DOCUMENT + '%\' OR ';
                queryWhere += ' LStore__File_Name_Calc__c LIKE \'%' + DEPOSIT_DETAIL_REPORT_DOCUMENT + '%\' )';

            } else {

                queryWhere += ' AND LStore__File_Name_Calc__c LIKE \''+ filterFields.accountingDocTypeObjectKeyPrefix +'%\' ';
            }
        }

        if ( !isLegacyDocument(filterFields) ){
            if ( !String.isEmpty(filterFields.accountingClient) ){
                queryWhere += ' AND ( (Proposal__c != null AND Proposal__r.Accounting_Contact_Company__r.Name LIKE \''+ filterFields.accountingClient +'%\' ) OR ' +
                              '       (Project__c != null AND Project__r.Accounting_Contact_Company__r.Name LIKE \''+ filterFields.accountingClient +'%\' ) )';
            }
            if ( !String.isEmpty(filterFields.billingClient) ){
                queryWhere += ' AND ( (Proposal__c != null AND Proposal__r.Billing_Company_Name__r.Name LIKE \''+ filterFields.billingClient +'%\' ) OR ' +
                              '       (Project__c != null AND Project__r.Billing_Company_Name__r.Name LIKE \''+ filterFields.billingClient +'%\' ) )';
            }
            if ( !String.isEmpty(filterFields.primaryClient) ){
                queryWhere += ' AND ( (Proposal__c != null AND Proposal__r.Primary_Company_Name__r.Name LIKE \''+ filterFields.primaryClient +'%\' ) OR ' +
                              '       (Project__c != null AND Project__r.Primary_Company_Name__r.Name LIKE \''+ filterFields.primaryClient +'%\' ) )';
            }
        } else {
            if ( !String.isEmpty(filterFields.accountingClient) ){
                queryWhere += ' AND Project_Mi7__r.Accounting_Contact_Company__r.Name LIKE \''+ filterFields.accountingClient +'%\' ';
            }
            if ( !String.isEmpty(filterFields.billingClient) ){
                queryWhere += ' AND Project_Mi7__r.Billing_Client_Company__r.Name LIKE \''+ filterFields.billingClient +'%\' ';
            }
            if ( !String.isEmpty(filterFields.primaryClient) ){
                queryWhere += ' AND Project_Mi7__r.Primary_Client_Company_SF__r.Name LIKE \''+ filterFields.primaryClient +'%\' ';
            }
        }

        system.debug('queryWhere: ' + queryWhere);
        return queryWhere;
    }

    public static String buildQueryWhere(String key, String value) {
        String result = '';
        if( !String.isBlank(value) ) {
            result = ' AND '+key+' LIKE \'%'+ value +'%\' ';
        }
        return result;
    }

    public static Boolean isLegacyDocument(FilterFields  filterFields) {
        return filterFields.accountingDocTypeObjectKeyPrefix == LEGACY_PROFORMA_INVOICE_DOCUMENT
                || filterFields.accountingDocTypeObjectKeyPrefix == LEGACY_CREDIT_NOTE_DOCUMENT;

    }

    public static String buildQuery(String queryWhere, String sortBy) {

        return  'SELECT Id, Task_Item__r.GUID__c, LStore__Import_Date__c, Drawings_Title__c, Drawing_Revision_Date__c, Name, Folder_Name__c, Proposal__r.Name, '+
                'LStore__Description__c, Drawing_Number__c, Worktype__c, Municipal_Form_Type_Name__c, LStore__Related_Object_Id__c, ' +
                'Municipal_Agency_Id__c, Tenant__c, LStore__Keywords__c, Project__r.Project_Name__c , Address__r.Name, ' +
                'Proposal__c, Project__r.Name, Project__c, Service_Item__r.Name, Service_Item__c, Owner.Name, CreatedBy.Name, ' +
                'Task_Item__r.Name, Task_Item__c, Purchase_Order__r.Name, Purchase_Order__c, LastModifiedDate, Architect_Engineer__c, ' +
                'Author__r.Name__c, CreatedDate, LStore__File_Name__c , Form_Item_Copy__r.Form_Name__c, Applicant__c, Applicant__r.Name, ' +
                'Pro_forma_Invoice__c, Pro_forma_Invoice__r.Name, Deposit_Invoice__c, Deposit_Invoice__r.Deposit_Invoice_Number__c, Legacy_Pro_forma_Invoice__c, Legacy_Pro_forma_Invoice__r.Name, ' +
                'Project_Mi7__c, Project_Mi7__r.Name, Project_Mi7__r.MRC__c, Pro_forma_Invoice__r.Total_Billed_Amount__c, Pro_forma_Invoice__r.Amount_Due__c ' +
                'FROM LStore__Stored_Document__c '+ queryWhere  +' ORDER BY '+ sortBy +' LIMIT 1000';
    }

    public static set<Id> filterIfFoldersCreated( Set<Id> idSet ) {
        for(LStore__Stored_Document__c ls : [SELECT LStore__Related_Object_Id__c
                                             FROM LStore__Stored_Document__c
                                             WHERE Related_Object_Id__c IN : idSet
                                             AND ( LStore__File_Name__c = : StoredDocumentServices.DOCUMENTS_FILE_TYPE OR LStore__File_Name__c = : StoredDocumentServices.DRAWINGS_FILE_TYPE )]) {
            idSet.remove(ls.LStore__Related_Object_Id__c);
        }
        return idSet;
    }

    public static void createFolders(set<Id> IdList) {
        if(IdList.size() == 0) return;
        list<LStore__Stored_Document__c> newDocsFolder = new list<LStore__Stored_Document__c>();
        for(String item : IdList) {
            newDocsFolder.add(new LStore__Stored_Document__c( RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
                                                              LStore__File_Name__c = StoredDocumentServices.DOCUMENTS_FILE_TYPE,
                                                              LStore__Related_Object_Id__c = item,
                                                              LStore__Keywords__c = StoredDocumentServices.DOCUMENTS_FILE_TYPE ));
            newDocsFolder.add(new LStore__Stored_Document__c( RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
                                                              LStore__File_Name__c = StoredDocumentServices.DRAWINGS_FILE_TYPE,
                                                              LStore__Related_Object_Id__c = item,
                                                              LStore__Keywords__c = StoredDocumentServices.DRAWINGS_FILE_TYPE ));
        }
        system.debug('newDocsFolder: ' + newDocsFolder);
        if(newDocsFolder.size() > 0) {
            try {
                insert newDocsFolder;
            } catch(DMLException dmlEx ) {
                throw new ErrorException('Cannot create new folder! ' + dmlEx.getMessage());
            }
        }
    }

    public static void createFoldersForStoredDocsFromAttachments( Set<Id> parentIds ) {
        Set<Id> proposalIds = new Set<Id>();
        Set<Id> changeOrderIds = new Set<Id>();
        for( Id parentId : parentIds ) {
            if( String.valueOf( parentId ).startsWith( ProposalServices.proposalPrefix ) ) {
                proposalIds.add( parentId );
            } else if( String.valueOf( parentId ).startsWith( ChangeOrderServices.changeOrderPrefix ) ) {
                changeOrderIds.add( parentId );
            }
        }

        if( !changeOrderIds.isEmpty() ) {
            for( Change_Order__c changeOrder : [ SELECT Proposal__c FROM Change_Order__c WHERE Id IN : changeOrderIds ] ) {
                proposalIds.add( changeOrder.Proposal__c );
            }
        }

        for( LStore__Stored_Document__c doc : [ SELECT Related_Object_Id__c
                                                  FROM LStore__Stored_Document__c
                                                 WHERE LStore__File_Name__c = : StoredDocumentServices.PROPOSALS_FILE_TYPE
                                                   AND RecordType.Name = : StoredDocumentServices.FOLDER_RECORDTYPE
                                                   AND Related_Object_Id__c IN : proposalIds ] ) {
            proposalIds.remove( doc.Related_Object_Id__c );
        }
        if( !proposalIds.isEmpty() ) {
            List<LStore__Stored_Document__c> newFolders = new List<LStore__Stored_Document__c>();
            for( Id proposalId : proposalIds ) {
                newFolders.add( new LStore__Stored_Document__c( LStore__Related_Object_Id__c = proposalId,
                                                                LStore__File_Name__c = StoredDocumentServices.PROPOSALS_FILE_TYPE,
                                                                RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
                                                                LStore__Keywords__c = '' ) );
            }
            INSERT newFolders;
        }
    }

    public static LStore__Stored_Document__c createFolder(String folderName, String relatedObjId){
        return new LStore__Stored_Document__c(
            RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
            LStore__File_Name__c = folderName,
            Name = folderName,
            LStore__Related_Object_Id__c = relatedObjId);
    }

    public static void deleteStoredDocForFormItemAfterNewUpload( List<LStore__Stored_Document__c> docsList ){
        system.debug('@docsList='+docsList);
        Schema.DescribeSObjectResult sa = Service_Item__c.sObjectType.getDescribe();
        String keyPrefix = sa.getKeyPrefix();
        Set<Id> idsServices = new Set<Id>();
        Set<String> namesFiles = new Set<String>();
        List<LStore__Stored_Document__c> docsForDelete = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c item: docsList ){
            if( item.LStore__Related_Object_Id__c.substring(0,3) == keyPrefix ){
                idsServices.add(item.LStore__Related_Object_Id__c);
                namesFiles.add(item.Name);
            }
        }

        for( LStore__Stored_Document__c item: [Select Id, Name, LStore__File_Name__c, LStore__Related_Object_Id__c
                                               From LStore__Stored_Document__c
                                               Where Related_Object_Id__c IN: idsServices AND Name IN: namesFiles AND Id NOT IN: docsList]){
            for( LStore__Stored_Document__c itemNew: docsList ){
                if( itemNew.LStore__Related_Object_Id__c == item.LStore__Related_Object_Id__c &&
                    itemNew.Name == item.Name ){
                    docsForDelete.add(item);
                }
            }
        }system.debug('@docsForDelete='+docsForDelete);

        if ( !docsForDelete.isEmpty() ) delete docsForDelete;
    }

    public static Map<Id, LStore__Stored_Document__c> filterFormItemForStoreDocument( List<LStore__Stored_Document__c> docsList ) {
         Map<Id, LStore__Stored_Document__c> storeDocToFormMetaDataIdMap = new  Map<Id, LStore__Stored_Document__c>();
        for(LStore__Stored_Document__c doc : docsList) {
            if( doc.LStore__Related_Object_Id__c != null && doc.LStore__Related_Object_Id__c.startsWith( Schema.SObjectType.Form_Meta_Data_Object_1__c.getKeyPrefix() ) ) {
                storeDocToFormMetaDataIdMap.put( doc.LStore__Related_Object_Id__c, doc );
            }
        }
        return storeDocToFormMetaDataIdMap;

    }

    public static void updateFormItemForStoreDocument( Map<Id, LStore__Stored_Document__c> storeDocToFormMetaDataIdMap ) {
        if( storeDocToFormMetaDataIdMap.isEmpty() ) return;

        Map<Id, Form_Meta_Data_Object_1__c> formMetaDataMap = new Map<Id, Form_Meta_Data_Object_1__c>( [ SELECT Id, Form_Item__r.Form_Name__c, Form_Item__c, Form_Item__r.Subject__c, Task_Item__c,
                                                                                                        Service_Item__c, Service_Item__r.Project_Profile__c, Service_Item__r.Proposal__c, Service_Item__r.Municipal_Agency_ID__c
                                                                                                         FROM Form_Meta_Data_Object_1__c
                                                                                                         WHERE Id IN : storeDocToFormMetaDataIdMap.keySet()] );
        for( LStore__Stored_Document__c doc : storeDocToFormMetaDataIdMap.values() ) {
            if( formMetaDataMap.containsKey( doc.LStore__Related_Object_Id__c ) ) {

                Form_Meta_Data_Object_1__c metadataObject = formMetaDataMap.get( doc.LStore__Related_Object_Id__c );

                doc.Drawings_Title__c      = metadataObject.Form_Item__r.Form_Name__c;
                doc.Form_Item_Copy__c      = metadataObject.Form_Item__c;
                doc.Task_Item__c           = metadataObject.Task_Item__c;
                doc.Service_Item__c        = metadataObject.Service_Item__c;
                doc.Proposal__c            = metadataObject.Service_Item__r.Proposal__c;
                doc.Project__c             = metadataObject.Service_Item__r.Project_Profile__c;
                doc.LStore__Description__c = metadataObject.Form_Item__r.Subject__c;
                doc.Municipal_Agency_Id__c = metadataObject.Service_Item__r.Municipal_Agency_ID__c;
            }
        }

        //associate docs with respective folders
        List<LStore__Stored_Document__c> sFolders = getFoldersByFormMetaDataIds( new List<Id>(storeDocToFormMetaDataIdMap.keySet()) );

        List<LStore__Stored_Document__c> assignedFolders = new List<LStore__Stored_Document__c>();

        for (LStore__Stored_Document__c folder : sFolders) {
            if (storeDocToFormMetaDataIdMap.containsKey(folder.LStore__Related_Object_Id__c)){

                LStore__Stored_Document__c storedDoc = storeDocToFormMetaDataIdMap.get(folder.LStore__Related_Object_Id__c);

                if (storedDoc.LStore__Folder__c == null){
                    // assign folder to doc
                    storedDoc.LStore__Folder__c = folder.Id;
                    //
                    folder.Drawings_Title__c = storedDoc.Drawings_Title__c;

                    assignedFolders.add(folder);
                }
            }
        }
        if (! assignedFolders.isEmpty() ) {
            update assignedFolders;
        }

    }

    public static Map<String, List<LStore__Stored_Document__c>> filterDocumentsByTypes( List<LStore__Stored_Document__c> docsList ){
        Map<String, List<LStore__Stored_Document__c>> docTypeToDocumentsList = new Map<String, List<LStore__Stored_Document__c>>();

        docTypeToDocumentsList.put( FORMS_FILE_TYPE, new List<LStore__Stored_Document__c>() );
        docTypeToDocumentsList.put( ACCOUNTING_FILE_TYPE, new List<LStore__Stored_Document__c>() );
        docTypeToDocumentsList.put( PROJECT_LABEL_DOCUMENT, new List<LStore__Stored_Document__c>() );

        String fmdoKeyPreffix = Form_Meta_Data_Object_1__c.sObjectType.getDescribe().getKeyPrefix();
        String proposalPreffix = Proposal__c.sObjectType.getDescribe().getKeyPrefix();
        String projectProfilePreffix = Project_Profile__c.sObjectType.getDescribe().getKeyPrefix();

        for( LStore__Stored_Document__c itemDoc: docsList ){
            if( itemDoc.LStore__File_Name__c != null && itemDoc.RecordTypeId == StoredDocumentServices.DOCUMENT_RECORD_TYPE_ID && itemDoc.LStore__Related_Object_Id__c != null ){
                if(  itemDoc.LStore__Related_Object_Id__c.substring(0,3) == fmdoKeyPreffix ) {
                    docTypeToDocumentsList.get( FORMS_FILE_TYPE ).add( itemDoc );
                }else if( itemDoc.LStore__Related_Object_Id__c.startsWith(projectProfilePreffix) && itemDoc.LStore__File_Name__c == PROJECT_LABEL_DOCUMENT){
                    docTypeToDocumentsList.get( PROJECT_LABEL_DOCUMENT ).add( itemDoc );
                } else if( itemDoc.LStore__Folder__c == null ||
                           ( itemDoc.LStore__Related_Object_Id__c.substring(0,3) == proposalPreffix &&
                             ( itemDoc.LStore__File_Name__c.contains( RETAINER_INVOICE_DOCUMENT ) ||
                               itemDoc.LStore__File_Name__c.contains( RETAINER_INVOICE_DOCUMENT_WITHOUT_SPACE ) ||
                               itemDoc.LStore__File_Name__c.contains( PROPOSAL_DOCUMENT ) ||
                               itemDoc.LStore__File_Name__c.contains( CHANGE_ORDER_DOCUMENT ) )
                ) ) {
                    docTypeToDocumentsList.get( ACCOUNTING_FILE_TYPE ).add( itemDoc );
                }
            }
        }
        return docTypeToDocumentsList;

    }

    public static void updateProjectLabelDocumentFields( List<LStore__Stored_Document__c> storedDocumentList ){
        if( storedDocumentList.isEmpty() ) return;
        for( LStore__Stored_Document__c documet: storedDocumentList ){
            documet.LStore__Description__c = PROJEC_LABEL_KEYWORD;
            documet.LStore__Keywords__c = PROJEC_LABEL_KEYWORD;
        }
    }

    public static void copyChangeOrderDocumentType( List<LStore__Stored_Document__c> storedDocumentList ) {
        Set<Id> proposalIds = new Set<Id>();
        Map<Id, Map<Integer, List<LStore__Stored_Document__c>>> proposalIdToChangeOrderNumberToDocs = new Map<Id, Map<Integer, List<LStore__Stored_Document__c>>>();

        for( LStore__Stored_Document__c doc : storedDocumentList ) {
            try {
                String relatedObjectName = doc.LStore__Related_Object_Id__c.substring( 0, 3 );
                String documentName = doc.Name;
                if( !String.isBlank( doc.Proposal__c ) && documentName.contains( CHANGE_ORDER_DOCUMENT ) ) {
                    String currentSymbol;
                    String changeOrderNumberStr = '';
                    documentName = documentName.substringAfterLast( CHANGE_ORDER_DOCUMENT );
                    WHILE( !String.isBlank( documentName ) && ( String.isBlank( currentSymbol ) || currentSymbol.isNumeric() ) ) {
                        if( !String.isBlank( currentSymbol ) ) changeOrderNumberStr = changeOrderNumberStr + currentSymbol;
                        currentSymbol = documentName.substring( 0, 1 );
                        documentName = documentName.substring( 1, documentName.length() - 1 );
                    }
                    if( !String.isBlank( changeOrderNumberStr ) ) {
                        Integer changeOrderNumber = Integer.valueOf( changeOrderNumberStr );
                        proposalIds.add( doc.Proposal__c );
                        if( proposalIdToChangeOrderNumberToDocs.get( doc.Proposal__c ) == null ) {
                            proposalIdToChangeOrderNumberToDocs.put( doc.Proposal__c, new Map<Integer, List<LStore__Stored_Document__c>>() );
                        }
                        Map<Integer, List<LStore__Stored_Document__c>> changeOrderNumberToDocs = proposalIdToChangeOrderNumberToDocs.get( doc.Proposal__c );
                        if( changeOrderNumberToDocs.get( changeOrderNumber ) == null ) {
                            changeOrderNumberToDocs.put( changeOrderNumber, new List<LStore__Stored_Document__c>() );
                        }
                        changeOrderNumberToDocs.get( changeOrderNumber ).add( doc );
                    }
                }
            } catch( Exception e ) {
            }
        }
        for( Change_Order__c changeOrder : [ SELECT Document_Type__c, Number__c, Proposal__c FROM Change_Order__c WHERE Proposal__c IN : proposalIds ] ) {
            try {
                if( changeOrder.Number__c != null ) {
                    Integer changeOrderNumber = (Integer)changeOrder.Number__c;
                    Map<Integer, List<LStore__Stored_Document__c>> changeOrderNumberToDocs = proposalIdToChangeOrderNumberToDocs.get( changeOrder.Proposal__c );
                    if( changeOrderNumberToDocs != null ) {
                        List<LStore__Stored_Document__c> docs = changeOrderNumberToDocs.get( changeOrderNumber );
                        if( docs != null ) {
                            for( LStore__Stored_Document__c doc : docs ) {
                                doc.Is_Light_Change_Order__c = changeOrder.Document_Type__c == ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
                            }
                        }
                    }
                }
            } catch( Exception e ) {
            }
        }
    }

    public static void fillRelatedFieldsInStoredDocuments( List<LStore__Stored_Document__c> storedDocumentList ){
        if( storedDocumentList.isEmpty() ) return;

        String proposalKeyPreffix = Proposal__c.sObjectType.getDescribe().getKeyPrefix();
        String projectKeyPreffix = Project_Profile__c.sObjectType.getDescribe().getKeyPrefix();
        String proformaInvoiceKeyPreffix = Pro_forma_Invoice__c.sObjectType.getDescribe().getKeyPrefix();
        String depositInvoiceKeyPreffix = Deposit_Invoice__c.sObjectType.getDescribe().getKeyPrefix();
        String legacyInvoiceKeyPreffix = Legacy_Pro_forma_Invoice__c.sObjectType.getDescribe().getKeyPrefix();
        String accountKeyPreffix = Account.sObjectType.getDescribe().getKeyPrefix();
        String taskItemKeyPrefix = Task_Item__c.sObjectType.getDescribe().getKeyPrefix();

        List<Id> proposalIds = new List<Id>();
        List<Id> projectIds = new List<Id>();
        List<Id> proformaInvoiceIds = new List<Id>();
        List<Id> depositInvoiceIds = new List<Id>();
        List<Id> legacyInvoiceIds = new List<Id>();
        List<Id> taskItemIds = new List<Id>();

        for( LStore__Stored_Document__c itemDoc: storedDocumentList ) {
            String relatedObjectName = itemDoc.LStore__Related_Object_Id__c.substring(0,3);
            if (proposalKeyPreffix.equals(relatedObjectName)) {
                proposalIds.add( itemDoc.LStore__Related_Object_Id__c );
                if( itemDoc.Name.contains( RETAINER_INVOICE_DOCUMENT ) ) itemDoc.Drawings_Title__c = RETAINER_INVOICE_DOCUMENT;
            } else if (accountKeyPreffix.equals(relatedObjectName)) {
                itemDoc.Applicant__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                if( itemDoc.Name.contains( STATEMENT_OF_ACCOUNTS_DOCUMENT ) ) itemDoc.Drawings_Title__c = STATEMENT_OF_ACCOUNTS_DOCUMENT;

            } else if (projectKeyPreffix.equals(relatedObjectName)) {
                projectIds.add( itemDoc.LStore__Related_Object_Id__c );
                if( itemDoc.Name.contains( ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT ) ) itemDoc.Drawings_Title__c = ACCOUNT_SUMMARY_RECAP_REPORT_DOCUMENT;

            } else if (proformaInvoiceKeyPreffix.equals(relatedObjectName)) {
                proformaInvoiceIds.add( itemDoc.LStore__Related_Object_Id__c );
                if( itemDoc.Name.startsWith( 'Invoice' ) ) itemDoc.Drawings_Title__c = PROFORMA_INVOICE_DOCUMENT;
                if( itemDoc.Name.startsWith( 'Credit 1' ) ) itemDoc.Drawings_Title__c = CREDIT_NOTE_DOCUMENT + ' 1';
                if( itemDoc.Name.startsWith( 'Credit 2' ) ) itemDoc.Drawings_Title__c = CREDIT_NOTE_DOCUMENT + ' 2';
                if( itemDoc.Name.contains( DOCUMENT_SHREDDING_DOCUMENT ) ) itemDoc.Drawings_Title__c = DOCUMENT_SHREDDING_DOCUMENT;
                if( itemDoc.Name.contains( MET_DATA_SCANNING_DOCUMENT ) ) itemDoc.Drawings_Title__c = MET_DATA_SCANNING_DOCUMENT;
                if( itemDoc.Name.contains( SUPREME_SYSTEMS_DOCUMENT ) ) itemDoc.Drawings_Title__c = SUPREME_SYSTEMS_DOCUMENT;
                if( itemDoc.Name.contains( FEDEX_DOCUMENT ) ) itemDoc.Drawings_Title__c = FEDEX_DOCUMENT;

            } else if (depositInvoiceKeyPreffix.equals(relatedObjectName)) {
                depositInvoiceIds.add( itemDoc.LStore__Related_Object_Id__c );
                if( itemDoc.Name.contains( DEPOSIT_DETAIL_REPORT_DOCUMENT ) ) itemDoc.Drawings_Title__c = DEPOSIT_DETAIL_REPORT_DOCUMENT;
                if( itemDoc.Name.contains( RETAINER_INVOICE_DOCUMENT ) ) itemDoc.Drawings_Title__c = RETAINER_INVOICE_DOCUMENT;

            } else if (legacyInvoiceKeyPreffix.equals(relatedObjectName)) {
                legacyInvoiceIds.add( itemDoc.LStore__Related_Object_Id__c );
                if( itemDoc.Name.startsWith( 'Legacy Invoice' ) ) itemDoc.Drawings_Title__c = LEGACY_PROFORMA_INVOICE_DOCUMENT;
                if( itemDoc.Name.startsWith( 'Credit 1' ) ) itemDoc.Drawings_Title__c = LEGACY_CREDIT_NOTE_DOCUMENT + ' 1';
                if( itemDoc.Name.startsWith( 'Credit 2' ) ) itemDoc.Drawings_Title__c = LEGACY_CREDIT_NOTE_DOCUMENT + ' 2';

            } else if (taskItemKeyPrefix.equals(relatedObjectName)) {
                taskItemIds.add( itemDoc.LStore__Related_Object_Id__c );
                itemDoc.Drawings_Title__c = TRANSMITTAL_DOCUMENT;

            }
        }

        Map<Id, Proposal__c> proposalsMap = new Map<Id, Proposal__c>([ Select Id, Address__c, Project_Profile__c From Proposal__c Where Id =:proposalIds ]);
        Map<Id, Project_Profile__c> projectsMap = new Map<Id, Project_Profile__c>([ Select Id, Building__c, Proposal__c From Project_Profile__c Where Id =:projectIds ]);
        Map<Id, Pro_forma_Invoice__c> proformaInvoicesMap = new Map<Id, Pro_forma_Invoice__c>([ Select Id, Project_Address__c, Project_Profile__c, Project_Profile__r.Proposal__c From Pro_forma_Invoice__c Where Id =:proformaInvoiceIds ]);
        Map<Id, Deposit_Invoice__c> depositInvoicesMap = new Map<Id, Deposit_Invoice__c>([ Select Id, Project_Profile__c, Project_Profile__r.Building__c, Proposal__c From Deposit_Invoice__c Where Id =:depositInvoiceIds ]);
        Map<Id, Legacy_Pro_forma_Invoice__c> legacyInvoicesMap = new Map<Id, Legacy_Pro_forma_Invoice__c>([ Select Id, Project_Address__c, Project_Native__c, Project_Native__r.Name, Project_Native__r.MRC__c From Legacy_Pro_forma_Invoice__c Where Id =:legacyInvoiceIds ]);
        Map<Id, Task_Item__c> taskItemsMap = new Map<Id, Task_Item__c>([Select Id, Service_item__c, Project_Profile__c From Task_item__c Where Id IN : taskItemIds]);

        for( LStore__Stored_Document__c itemDoc: storedDocumentList ) {
            String relatedObjectName = itemDoc.LStore__Related_Object_Id__c.substring(0,3);

            if (proposalKeyPreffix.equals(relatedObjectName)) { // PROPOSAL
                itemDoc.Proposal__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Project__c = proposalsMap.get( itemDoc.Proposal__c ).Project_Profile__c;
                itemDoc.Address__c = proposalsMap.get( itemDoc.Proposal__c ).Address__c;

            } else if (projectKeyPreffix.equals(relatedObjectName)) { // PROJECT
                itemDoc.Project__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Proposal__c = projectsMap.get( itemDoc.Project__c) .Proposal__c;
                itemDoc.Address__c = projectsMap.get( itemDoc.Project__c ).Building__c;

            } else if (proformaInvoiceKeyPreffix.equals(relatedObjectName)) { // PRO-FORMA INVOICE
                itemDoc.Pro_forma_Invoice__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Proposal__c = proformaInvoicesMap.get( itemDoc.Pro_forma_Invoice__c ).Project_Profile__r.Proposal__c;
                itemDoc.Project__c = proformaInvoicesMap.get( itemDoc.Pro_forma_Invoice__c ).Project_Profile__c;
                itemDoc.Address__c = proformaInvoicesMap.get( itemDoc.Pro_forma_Invoice__c ).Project_Address__c;

            } else if (depositInvoiceKeyPreffix.equals(relatedObjectName)) { // DEPOSIT INVOICE
                itemDoc.Deposit_Invoice__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Proposal__c = depositInvoicesMap.get( itemDoc.Deposit_Invoice__c ).Proposal__c;
                itemDoc.Project__c = depositInvoicesMap.get( itemDoc.Deposit_Invoice__c ).Project_Profile__c;
                itemDoc.Address__c = depositInvoicesMap.get( itemDoc.Deposit_Invoice__c ).Project_Profile__r.Building__c;

            } else if (legacyInvoiceKeyPreffix.equals(relatedObjectName)) { // LEGACY PRO-FORMA INVOICE
                itemDoc.Legacy_Pro_forma_Invoice__c = (Id)itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Address__c = legacyInvoicesMap.get( itemDoc.Legacy_Pro_forma_Invoice__c ).Project_Address__c;
                itemDoc.LStore__Description__c = legacyInvoicesMap.get( itemDoc.Legacy_Pro_forma_Invoice__c ).Project_Native__c;
                itemDoc.Architect_Engineer__c = legacyInvoicesMap.get( itemDoc.Legacy_Pro_forma_Invoice__c ).Project_Native__r.Name;
                itemDoc.Drawing_Number__c = legacyInvoicesMap.get( itemDoc.Legacy_Pro_forma_Invoice__c ).Project_Native__r.MRC__c;

                Id projId = legacyInvoicesMap.get( itemDoc.Legacy_Pro_forma_Invoice__c ).Project_Native__c;
                itemDoc.Project_Mi7__c = projId;

            } else if (taskItemKeyPrefix.equals(relatedObjectName)) {
                itemDoc.Task_Item__c = (Id) itemDoc.LStore__Related_Object_Id__c;
                itemDoc.Project__c = taskItemsMap.get( itemDoc.Task_Item__c ).Project_Profile__c;
                itemDoc.Service_item__c = taskItemsMap.get( itemDoc.Task_Item__c ).Service_item__c;

            }
        }
    }


    // helper DAO methods

    public static List<LStore__Stored_Document__c> getFoldersByFormMetaDataIds(List<Id> metaDataIDs){
        return [SELECT Id, LStore__Related_Object_Id__c
                FROM LStore__Stored_Document__c
                WHERE LStore__Related_Object_Id__c IN : metaDataIDs
                AND RecordTypeId = : StoredDocumentServices.FOLDER_RECORD_TYPE_ID];
    }

    public static LStore__Stored_Document__c getAdditionalDocumentsFolder( Id proposalId ) {
        LStore__Stored_Document__c folder = new LStore__Stored_Document__c();
        if( !String.isEmpty( proposalId ) ) {
            List<LStore__Stored_Document__c> storedDocsFolderDb = [ SELECT Id,
                                                                           ( SELECT Id, RecordTypeId, LStore__File_Size__c,
                                                                                    LStore__Type__c, LStore__External_Id__c,
                                                                                    Drawings_Title__c, Name, To_Be_Sent_this_time__c /* MRS 6809 */
                                                                             FROM LStore__Stored_Documents__r )
                                                                    FROM LStore__Stored_Document__c
                                                                    WHERE RecordTypeId = : StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                                                      AND Related_Object_Id__c = : String.valueOf( proposalId )
                                                                      AND LStore__File_Name__c = : StoredDocumentServices.RFP_DOCUMENTS_FOLDER ];
            if( !storedDocsFolderDb.isEmpty() ) {
                folder = storedDocsFolderDb[0];
            }
        }
        return folder;
    }

    public static List<LStore__Stored_Document__c> getDocumentsFromRosterSDocJunctions ( Roster_Email_Junction__c junction) { //G300 MRS-6807
        Set<Id> docs = new Set<Id>();
        for(Roster_StoredDocument_Junction__c tSD : junction.Roster_StoredDocument_Junctions__r) {
            docs.add(tSD.Stored_Document__c);
        }
        return [SELECT Id, RecordTypeId, LStore__File_Size__c, LStore__Type__c, LStore__External_Id__c,
                                                                            Drawings_Title__c, CreatedDate, Name, LStore__File_Name__c, Is_Light_Change_Order__c
                                                                    FROM LStore__Stored_Document__c WHERE id IN: docs];
    }

    public static Map<Id, List<LStore__Stored_Document__c>> getDocumentFoldersForProposals ( Set<Id> proposalsId ) {
        List<String> stringProposalsId = new List<String>();
        for(Id proposalId: proposalsId){
            stringProposalsId.add(String.valueOf( proposalId ));
        }
        Set<String> documentForlderNames = new Set<String>{StoredDocumentServices.RFP_DOCUMENTS_FOLDER, StoredDocumentServices.PROPOSALS_FILE_TYPE};
        Map<Id, List<LStore__Stored_Document__c>> proposalIdToDocumentMap = new Map<Id, List<LStore__Stored_Document__c>>();

        if( !proposalsId.isEmpty() ) {
            List<LStore__Stored_Document__c> storedDocsFolders = [ SELECT Id, Related_Object_Id__c,
                                                                   ( SELECT Id, RecordTypeId, LStore__File_Size__c, LStore__Type__c, LStore__External_Id__c,
                                                                            Drawings_Title__c, CreatedDate, Name, LStore__File_Name__c, Is_Light_Change_Order__c
                                                                    FROM LStore__Stored_Documents__r WHERE RecordTypeId !=: StoredDocumentServices.FOLDER_RECORD_TYPE_ID)
                                                                    FROM LStore__Stored_Document__c
                                                                    WHERE RecordTypeId =: StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                                                      AND Related_Object_Id__c IN: stringProposalsId
                                                                      AND LStore__File_Name__c IN:  documentForlderNames];
            for( LStore__Stored_Document__c document: storedDocsFolders ){
                if( !document.LStore__Stored_Documents__r.isEmpty() ){
                    if(!proposalIdToDocumentMap.containsKey(document.Related_Object_Id__c)){
                        proposalIdToDocumentMap.put(document.Related_Object_Id__c, new List<LStore__Stored_Document__c>());
                    }
                    proposalIdToDocumentMap.get(document.Related_Object_Id__c).add(document);
                }
            }
        }

        return proposalIdToDocumentMap;
    }

    public static List<LStore__Stored_Document__c> filterStoredDocumentsForCopyingFieldsFromScanRequest( List<LStore__Stored_Document__c> newDocuments ) {
        List<LStore__Stored_Document__c> filteredDocuments = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c document : newDocuments ) {
            if( !String.isBlank( document.Scan_Request_Id__c ) ) {
                filteredDocuments.add( document );
            }
        }
        return filteredDocuments;
    }

    public static Map<String, Map<String, String>> getParentIdsAndAttachmentIdsForUploadedChecks( Set<Id> proformaInvoiceIds ) {
        Map<String, Map<String, String>> pfiIdToAttachmentIdToBliId = new Map<String, Map<String, String>>();
        if( proformaInvoiceIds != null && !proformaInvoiceIds.isEmpty() ) {
            Map<Id, Id> billingLineItemIdToPfiId = new Map<Id, Id>();
            for( Billing_Line_Item__c billingLineItem : [ SELECT Id, Pro_forma_Invoice__c
                                                          FROM Billing_Line_Item__c
                                                          WHERE Pro_forma_Invoice__c IN : proformaInvoiceIds
                                                            AND Requires_Check_Image__c = true
                                                            AND Check_Image_Attached__c = true
                                                            AND Pro_forma_Invoice__c != null ] ) {
                billingLineItemIdToPfiId.put( billingLineItem.Id, billingLineItem.Pro_forma_Invoice__c );
            }
            if( !billingLineItemIdToPfiId.keySet().isEmpty() ) {
                for( LStore__Stored_Document__c check : [ SELECT Id, Related_Object_Id__c
                                                          FROM LStore__Stored_Document__c
                                                          WHERE Related_Object_Id__c IN : billingLineItemIdToPfiId.keySet()
                                                            AND Attach_to_Invoice__c = true ] ) {
                    Id pfiId = billingLineItemIdToPfiId.get( check.Related_Object_Id__c );
                    if( !pfiIdToAttachmentIdToBliId.containsKey( pfiId ) ) {
                        pfiIdToAttachmentIdToBliId.put( pfiId, new Map<String, String>() );
                    }
                    Map<String, String> attachmentIdToBliId = pfiIdToAttachmentIdToBliId.get( pfiId );
                    attachmentIdToBliId.put( check.Id, check.Related_Object_Id__c );
                }
            }
        }
        return pfiIdToAttachmentIdToBliId;
    }

    public static List<Id> getAttachmentIdsForInvoice( Map<String, Map<String, String>> invoiceIdToAttachmentIdToParentId, Id invoiceId ) {
        List<Id> attachmentIds;
        if( invoiceIdToAttachmentIdToParentId != null ) {
            Map<String, String> attachmentIdToParentId = invoiceIdToAttachmentIdToParentId.get( invoiceId );
            if( attachmentIdToParentId != null ) {
                Set<String> attachmentIdsSet = attachmentIdToParentId.keySet();
                if( attachmentIdsSet != null && !attachmentIdsSet.isEmpty() ) {
                    attachmentIds = new List<Id>();
                    for( Id attachmentId : attachmentIdsSet ) {
                        attachmentIds.add( attachmentId );
                    }
                }
            }
        }
        return attachmentIds;
    }

    public static Map<Id, Set<String>> filterStoredDocumentsToFindRelatedAttachmentsByNames( List<LStore__Stored_Document__c> newDocs ) {
        Map<Id, Set<String>> parentIdToAttachmentNames = new Map<Id, Set<String>>();
        for( LStore__Stored_Document__c doc : newDocs ) {
            String attName = doc.LStore__File_Name__c.replaceAll(  '#\\d+? ', '# ' );
            if( doc.Recordtype__c == DOCUMENT_RECORDTYPE &&
                //Docusign Status Proposal/CO Attachments Delete
                ( doc.LStore__Related_Object_Id__c.startsWith( ProposalServices.proposalPrefix ) &&
                  ( attName.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) || attName.contains( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' ) ) ) ||

                //Task Attachment Delete
                ( doc.LStore__Related_Object_Id__c.startsWith( TaskServices.taskPrefix ) ) ) {

                if( parentIdToAttachmentNames.get( doc.LStore__Related_Object_Id__c ) == null ) {
                    parentIdToAttachmentNames.put( doc.LStore__Related_Object_Id__c, new Set<String>() );
                }
                parentIdToAttachmentNames.get( doc.LStore__Related_Object_Id__c ).add( doc.LStore__File_Name__c );
            }
        }
        return parentIdToAttachmentNames;
    }

    public static List<LStore__Stored_Document__c> filterStoredDocumentsToFindSignedOrOnPaperAttachments( List<LStore__Stored_Document__c> newDocs ) {
        List<LStore__Stored_Document__c> signedOrOnPaperDocs = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c doc : newDocs ) {
            String attName = doc.LStore__File_Name__c.replaceAll(  '#\\d+? ', '# ' );
            if( doc.Recordtype__c == DOCUMENT_RECORDTYPE &&
                doc.LStore__Related_Object_Id__c.startsWith( ProposalServices.proposalPrefix ) &&
                ( attName.contains( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' ) || attName.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ) ) {
                signedOrOnPaperDocs.add( doc );
            }
        }
        return signedOrOnPaperDocs;
    }

    public static void deleteDocusignSignedDocsIfOnPaperExists( List<LStore__Stored_Document__c> signedOrOnPaperDocs ) {
        List<LStore__Stored_Document__c> docsToDelete = new List<LStore__Stored_Document__c>();
        Set<Id> docIdsToDeleteInFuture = new Set<Id>();

        if( !signedOrOnPaperDocs.isEmpty() ) {
            Set<String> namesToCheck = new Set<String>();

            Map<Id, Map<String, LStore__Stored_Document__c>> parentId_DocNamesForCheckSignedOnPaper_Doc = new Map<Id, Map<String, LStore__Stored_Document__c>>();
            Map<Id, Map<String, LStore__Stored_Document__c>> parentId_DocNamesForCheckSigned_Doc = new Map<Id, Map<String, LStore__Stored_Document__c>>();
            for( LStore__Stored_Document__c doc : signedOrOnPaperDocs ) {
                String nameToCheck1 = ''; // MRS 7247
				String nameToCheck2 = '';
				String nameToCheck3 = '';
                if( doc.LStore__File_Name__c.contains( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' ) ) {
                    nameToCheck1 = doc.LStore__File_Name__c.replace( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.', StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
					nameToCheck2 = doc.LStore__File_Name__c.replace( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.', '- Change Order ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
					nameToCheck3 = doc.LStore__File_Name__c.replace( StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.', '- Proposal ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' );
                    if( parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ) == null ) {
                        parentId_DocNamesForCheckSigned_Doc.put( doc.LStore__Related_Object_Id__c, new Map<String, LStore__Stored_Document__c>() );
                    }
                    parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck1, doc );
					parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck2, doc );
					parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck3, doc );	
                    namesToCheck.add( nameToCheck1 );
					namesToCheck.add( nameToCheck2 );
					namesToCheck.add( nameToCheck3 );
                } else if( doc.LStore__File_Name__c.contains( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.' ) ) {
                    nameToCheck1 = doc.LStore__File_Name__c.replace( StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.', StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' );
					if(doc.LStore__File_Name__c.contains( '- Change Order ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.')) nameToCheck2 = doc.LStore__File_Name__c.replace( '- Change Order ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.', StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' );
					if(doc.LStore__File_Name__c.contains( '- Proposal ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.')) nameToCheck3 = doc.LStore__File_Name__c.replace( '- Proposal ' + StoredDocumentServices.DOCUSIGN_COMPLETED_SUFFIX_NEW + '.', StoredDocumentServices.DOCUSIGN_SIGNED_ON_PAPER_NEW + '.' );
                    if( parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ) == null ) {
                        parentId_DocNamesForCheckSignedOnPaper_Doc.put( doc.LStore__Related_Object_Id__c, new Map<String, LStore__Stored_Document__c>() );
                    }
                    parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck1, doc );
					if(!String.isBlank(nameToCheck2)) parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck2, doc );
					if(!String.isBlank(nameToCheck3)) parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ).put( nameToCheck3, doc );
                    namesToCheck.add( nameToCheck1 );
					if(!String.isBlank(nameToCheck2)) namesToCheck.add( nameToCheck2 );
					if(!String.isBlank(nameToCheck3)) namesToCheck.add( nameToCheck3 );
                }
            }
            for( LStore__Stored_Document__c doc : [ SELECT Id, LStore__Related_Object_Id__c, LStore__File_Name__c
                                                    FROM LStore__Stored_Document__c
                                                    WHERE LStore__File_Name__c IN : namesToCheck
                                                      AND ( LStore__Related_Object_Id__c IN : parentId_DocNamesForCheckSigned_Doc.keySet()
                                                         OR LStore__Related_Object_Id__c IN : parentId_DocNamesForCheckSignedOnPaper_Doc.keySet() ) ] ) {
                if( parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ) != null &&
                    parentId_DocNamesForCheckSigned_Doc.get( doc.LStore__Related_Object_Id__c ).get( doc.LStore__File_Name__c ) != null ) { //check if signed docs exist, if yes - delete these existing docs
                    docsToDelete.add( doc );
                }
                if( parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ) != null &&
                    parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ).get( doc.LStore__File_Name__c ) != null ) { //check if signed on paper docs exist, if yes - delete incoming docs
                    docIdsToDeleteInFuture.add( parentId_DocNamesForCheckSignedOnPaper_Doc.get( doc.LStore__Related_Object_Id__c ).get( doc.LStore__File_Name__c ).Id );
                }
            }
        }

        if( !docsToDelete.isEmpty() ) {
            Database.delete( docsToDelete, false );
        }
        if( !docIdsToDeleteInFuture.isEmpty() ) {
            deleteIncomingSignedDocs( docIdsToDeleteInFuture );
        }
    }

    @future
    public static void deleteIncomingSignedDocs( Set<Id> docIdsToDeleteInFuture ) {
        List<LStore__Stored_Document__c> docsToDelete = new List<LStore__Stored_Document__c>();
        for( Id docId : docIdsToDeleteInFuture ) {
            docsToDelete.add( new LStore__Stored_Document__c( Id = docId ) );
        }
        Database.delete( docsToDelete, false );
    }

}