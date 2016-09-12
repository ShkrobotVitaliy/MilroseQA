public with sharing class ScanRequestServices {
    public static Boolean IS_DOCUMENT_SCAN_REQUEST_SINGLETON = false;    
    public static Boolean IS_DRAWINGS_SCAN_REQUEST_SINGLETON = false;
    
    public static Boolean isUniqueScanRequest(final String artifactName) {
        if (String.isBlank(artifactName)) {
            throw new ErrorException(ErrorException.SCAN_REQUEST_EMPTY_ARTIFACT_NAME);
            
        }
        List<Scan_Request__c> scanItems = new List<Scan_Request__c>([SELECT Artifact_Name__c, Id, Is_Active__c 
                                                                     FROM Scan_Request__c
                                                                     WHERE Artifact_Name__c =: artifactName AND Is_Active__c =: true]);
        
        return scanItems.isEmpty();
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByTaskItemId(final Id taskItemId, final String fileType) {
        if (null == taskItemId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c 
                                          FROM Scan_Request__c
                                          WHERE Task_Item__c =: taskItemId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByServiceItemId(final Id serviceItemId, final String fileType) {
        if (null == serviceItemId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c, Proposal__c 
                                          FROM Scan_Request__c
                                          WHERE Service_Item__c =: serviceItemId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByProjectId(final Id projectId, final String fileType) {
        if (null == projectId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c, Proposal__c 
                                          FROM Scan_Request__c
                                          WHERE Project__c =: projectId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByProposalId(final Id proposalId, final String fileType) {
        if (null == proposalId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c, Proposal__c 
                                          FROM Scan_Request__c
                                          WHERE Proposal__c =: proposalId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByProformaId(final Id proformaId, final String fileType) {
        if (null == proformaId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c, Proposal__c,
                                                 Pro_forma_Invoice__c, Legacy_Pro_forma_Invoice__c 
                                          FROM Scan_Request__c
                                          WHERE Pro_forma_Invoice__c =: proformaId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static List<Scan_Request__c> getScanRequestsByLegacyProformaId(final Id legacyProformaId, final String fileType) {
        if (null == legacyProformaId || String.isBlank(fileType)) {
            return new List<Scan_Request__c>();
        
        }
        return new List<Scan_Request__c>([SELECT Work_Type__c, User__c, User_Unique_Card_ID__c, Tenant__c, Task_Item__c, Service_Item__c, Revision_Date__c, 
                                                 Related_Object_Id__c, Project__c, Number__c, Name, Municipal_Description_ID__c, Municipal_Agency_Id__c, 
                                                 Keywords__c, Is_Active__c, Id, Description__c, Comments__c, Artifact_Name__c, Account__c, File_Type__c, Proposal__c,
                                                 Pro_forma_Invoice__c, Legacy_Pro_forma_Invoice__c 
                                          FROM Scan_Request__c
                                          WHERE Legacy_Pro_forma_Invoice__c =: legacyProformaId AND File_Type__c =: fileType AND Is_Active__c =: true]);
    
    }
    
    public static void insertScanRequest(Scan_Request__c scanRequest) {
        if (!ScanRequestServices.isUniqueScanRequest(scanRequest.Artifact_Name__c)) {
            throw new ErrorException(ErrorException.SCAN_REQUEST_UNIQUE_TITLE);
        
        }
        insert scanRequest;
    
    }

    public static List<Scan_Request__c> filterScanRequestsForRelatedObjectIdPopulation( List<Scan_Request__c> newRequests, Map<Id, Scan_Request__c> oldRequestsMap ) {
        List<Scan_Request__c> filteredRequests = new List<Scan_Request__c>();
        if( oldRequestsMap == null ) {
            return newRequests;
        } else {
            for( Scan_Request__c request : newRequests ) {
                if( ( !String.isBlank( request.Task_Item__c ) && request.Task_Item__c != oldRequestsMap.get( request.Id ).Task_Item__c ) ||
                    ( !String.isBlank( request.Service_Item__c ) && request.Service_Item__c != oldRequestsMap.get( request.Id ).Service_Item__c ) ||
                    ( !String.isBlank( request.Pro_forma_Invoice__c ) && request.Pro_forma_Invoice__c != oldRequestsMap.get( request.Id ).Pro_forma_Invoice__c ) ||
                    ( !String.isBlank( request.Legacy_Pro_forma_Invoice__c ) && request.Legacy_Pro_forma_Invoice__c != oldRequestsMap.get( request.Id ).Legacy_Pro_forma_Invoice__c ) ||
                    ( !String.isBlank( request.Proposal__c ) && request.Proposal__c != oldRequestsMap.get( request.Id ).Proposal__c ) ||
                    ( !String.isBlank( request.Project__c ) && request.Project__c != oldRequestsMap.get( request.Id ).Project__c ) ) {
                    filteredRequests.add( request );
                }
            }
        }
        return filteredRequests;
    }

    public static void populateRelatedObjectId( List<Scan_Request__c> filteredRequests ) {
        for( Scan_Request__c request : filteredRequests ) {
            if( !String.isEmpty( request.Task_Item__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Task_Item__c );
            } else if( !String.isEmpty( request.Service_Item__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Service_Item__c );
            } else if( !String.isEmpty( request.Pro_forma_Invoice__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Pro_forma_Invoice__c );
            } else if( !String.isEmpty( request.Legacy_Pro_forma_Invoice__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Legacy_Pro_forma_Invoice__c );
            } else if( !String.isEmpty( request.Proposal__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Proposal__c );
            } else if( !String.isEmpty( request.Project__c ) ) {
                request.Related_Object_Id__c = String.valueOf( request.Project__c );
            } else {
                request.Related_Object_Id__c = '';
            }
        }
    }

    public static void copyFieldsFromScanRequest( List<LStore__Stored_Document__c> filteredDocuments ) {
        Map<Id, LStore__Stored_Document__c> documentIdToDocument = new Map<Id, LStore__Stored_Document__c>();
        Map<Id, Scan_Request__c> scanRequestIdToScanRequest = new Map<Id, Scan_Request__c>();
        for( LStore__Stored_Document__c document : filteredDocuments ) {
            if( document.Scan_Request_Id__c instanceOf Id ) {
                documentIdToDocument.put( document.Id, document );
                scanRequestIdToScanRequest.put( document.Scan_Request_Id__c, null );
            }
        }
        scanRequestIdToScanRequest = new Map<Id, Scan_Request__c>( [ SELECT Id, Comments__c, Description__c, File_Type__c, Keywords__c,
                                                                            Municipal_Agency_Id__c, Municipal_Description_ID__c, Number__c,
                                                                            Revision_Date__c, Tenant__c, Work_Type__c, Account__c,
                                                                            Legacy_Pro_forma_Invoice__c, Pro_forma_Invoice__c, Project__c,
                                                                            Project_Roster__c, Proposal__c, Service_Item__c, Task_Item__c
                                                                     FROM Scan_Request__c
                                                                     WHERE Id IN : scanRequestIdToScanRequest.keySet() ] );
        for( LStore__Stored_Document__c document : documentIdToDocument.values() ) {
            Scan_Request__c request = scanRequestIdToScanRequest.get( document.Scan_Request_Id__c );
            if( request != null ) {
                document.Comments__c = request.Comments__c;
                document.LStore__Description__c = request.Description__c;
                document.Artifacts_Category__c = request.File_Type__c;
                document.Key_Words__c = request.Keywords__c;
                document.Municipal_Agency_Id__c = request.Municipal_Agency_Id__c;
                document.Municipal_Description_ID__c = request.Municipal_Description_ID__c;
                document.Drawing_Number__c = request.Number__c;
                document.Drawing_Revision_Date__c = request.Revision_Date__c;
                document.Tenant__c = request.Tenant__c;
                document.Worktype__c = request.Work_Type__c;
                document.Account__c = request.Account__c;
                document.Legacy_Pro_forma_Invoice__c = request.Legacy_Pro_forma_Invoice__c;
                document.Pro_forma_Invoice__c = request.Pro_forma_Invoice__c;
                document.Project__c = request.Project__c;
                document.Author__c = request.Project_Roster__c;
                document.Proposal__c = request.Proposal__c;
                document.Service_Item__c = request.Service_Item__c;
                document.Task_Item__c = request.Task_Item__c;
            }
        }
    }

}