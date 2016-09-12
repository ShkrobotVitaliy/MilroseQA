public with sharing class MilroseDevHelper {
    public static final String SHA_256_ALG = 'SHA-256';

    public static final String ERROR = 'Error';
    public static final String INFO = 'Info';
    public static final String QUERY_FIELD_SPLITTER = ', ';

    public static final String MILROSE_LOGO_DOCUMENT_DEVELOPER_NAME = 'MilroseLogo_png';
    public static final String MILROSE_COMPANY_NAME = 'Milrose Consultants, Inc.';
    public static final String MILROSE_COMPANY_PHONE = '212-643-4545';

    public static final String SORT_ASC = 'ASC';
    public static final String SORT_DESC = 'DESC';

    public static final String NULL_STRING = 'null';

    public static String getRandomString() { return String.valueOf( Math.random() ) + ' ' + String.valueOf( DateTime.now() ); }

    public static Boolean isIdsObjectTypeEqualToStringObjectType( String objectIdString, String objectTypeNameString ){
      return ( ( objectIdString instanceof Id )
                 && Id.valueOf( objectIdString ).getSObjectType().getDescribe().getName().equals( objectTypeNameString ) );
    }

    public static String getUniqueKey() {
        Blob sig = Crypto.generateDigest( SHA_256_ALG, Blob.valueOf( String.valueOf( Datetime.now() ) + String.valueOf( Math.random() ) ) );
        return EncodingUtil.urlEncode( ( EncodingUtil.base64Encode( sig ) ).left( 255 ), 'UTF-8').replaceAll('%', 'I');
    }

    public static String getKeyForServiceGroup() {
        String random = String.valueOf( Integer.valueOf( Math.random() * 1000000 ) );
        while( random.length() < 6 ) {
            random = '0' + random;
        }
        random += Datetime.now().format( 'mmss' );
        return random;
    }

    public static void setWorkType( List<sObject> newsObjects ) {
        Set<Id> serviceItemIds = new Set<Id>();
        for( sObject sObjectItem : newsObjects ) {
            serviceItemIds.add( (Id)sObjectItem.get('Service_Item__c') );
        }
        serviceItemIds.remove( null );
        Map<Id, Service_Item__c> serviceItemIdToServiceItem = new Map<Id, Service_Item__c>( [ SELECT Work_Type__c FROM Service_Item__c WHERE Id IN : serviceItemIds ] );
        for( sObject sObjectItem : newsObjects ) {
            if( serviceItemIds.contains( (Id)sObjectItem.get('Service_Item__c') ) ) {
                sObjectItem.put( 'Work_Type__c', serviceItemIdToServiceItem.get( (Id)sObjectItem.get('Service_Item__c') ).Work_Type__c );
            }
        }
    }

    public static List<String> splitStringsBySymbolCount( String input, Integer charLimit ) {
        List<String> output = new List<String>();
        Integer position = 0;
        if( !String.isBlank(input) && charLimit != null && charLimit > 0 ) {
            while( position < input.length() ) {
                output.add( input.substring( position, input.length() < position + charLimit
                                                       ? input.length()
                                                       : position + charLimit ) );
                position += charLimit;
            }
        } else {
            output.add('');
        }
        return output;
    }

    public static String joinStrings(Set<String> strings, String separator){
        if(strings == null || strings.isEmpty() ) return null;

        Boolean isFirst = true;
        String returnString = '';
        for(String strItem : strings){
            if(strItem == '') continue;

            if( isFirst ) {
                isFirst = false;
            } else {
                if( separator != null ) {
                    returnString += separator;
                }
            }
            returnString += '' + strItem + '';
        }
        return returnString;
    }

    public static void addMessage( String message ) {
        addMessage( message, ERROR );
    }

    public static void addMessage( String message, String type ) {
        if( String.isBlank(type) || ( type != ERROR && type != INFO ) ) type = ERROR;
        if( type == ERROR ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, message ) ); return; }
        if( type == INFO  ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Info, message ) ); return; }
    }

    //MRS-6248
    public static String getCreatableFieldsSelectByObjectName (String objectName){
        return getCreatableFieldsSelectByObjectName(objectName, new Set<String>());
    }

    // Returns a dynamic SOQL statement for all object creatable fields
    public static String getCreatableFieldsSelectByObjectName (String objectName, Set<String> notClonedFieldSet){
        List<String> resultStringList = getCreatableFieldsListByObjectName(objectName, notClonedFieldSet);

        return String.join(resultStringList, ', ');
    }

    // Returns a dynamic SOQL statement for all object creatable fields
    public static List<String> getCreatableFieldsListByObjectName (String objectName, Set<String> notClonedFieldSet){
        Map<String, Schema.SObjectField> fiedlsMap;
        try{
            fiedlsMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        }catch(Exception e){
            throw new ErrorException( ErrorException.NOT_VALID_OBJECT_NAME_FOR_SCHEMA_DESCRIBE );
        }

        list<string> selectedFields = new list<string>();

        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            if (field.isCreateable() && !notClonedFieldSet.contains(fieldNameValue)){
                selectedFields.add(fieldNameValue);
            }
        }

        if (selectedFields.isEmpty()){
            throw new ErrorException(ErrorException.NO_CREATABLE_FIELDS_IN_OBJECT);
        }

        return selectedFields;
    }

    // Returns a dynamic SOQL statement for all object creatable fields
    public static List<String> getEditableFieldsListByObjectName (String objectName, Set<String> notClonedFieldSet){
        Map<String, Schema.SObjectField> fiedlsMap;
        try{
            fiedlsMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        }catch(Exception e){
            throw new ErrorException( ErrorException.NOT_VALID_OBJECT_NAME_FOR_SCHEMA_DESCRIBE );
        }

        list<string> selectedFields = new list<string>();

        for (Schema.SObjectField fieldTocken : fiedlsMap.values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            String fieldNameValue = field.getName();
            if (field.isUpdateable() && !notClonedFieldSet.contains(fieldNameValue)){
                selectedFields.add(fieldNameValue);
            }
        }

        if (selectedFields.isEmpty()){
            throw new ErrorException(ErrorException.NO_CREATABLE_FIELDS_IN_OBJECT);
        }

        return selectedFields;
    }

    //Flatten list for a dynamic query
    public static String flattenListForQuery( List<Object> incoming ) {
        //Empty lists will cause an invalid query
        if( incoming.isEmpty() ) {
            throw new ErrorException(ErrorException.EMPTY_LIST_FOR_MILROSEDEVHELPER);
        }

        String query = '';
        for(Object addToString : incoming) {
            query += '\'' + String.valueOf(addToString) + '\',';
        }

        if(query != '') {
            query = query.substring(0, query.length()-1);
            query = '(' + query + ') ';
        }
        return query;
    }

    public Static String getSafeFileName( String unsafeFileName ) {
        if( unsafeFileName == null ) return '';
        return unsafeFileName.replace(',', '_').replace(';', '_').replace('*', '_').replace('/', '_').replace('\\', '_').replace('?', '_').replace('<', '_').replace('>', '_').replace('|', '_').replace('\'', '').replace('\"', '');
    }

    public static void trimStringFieldFromBeginning( sObject currentObject, String fieldName ) {
        if(currentObject != null && fieldName != null) {
            if( ( new Set<String>{ 'TEXTAREA', 'STRING' } ).contains( String.valueOf( currentObject.getSObjectType().getDescribe().fields.getMap().get( fieldName ).getDescribe().getType() ) ) ) {
                String currentValue = currentObject.get( fieldName ) != null ? (String)currentObject.get( fieldName ) : null;
                if( currentValue != null ) {
                    Integer currentLength = currentValue.length();
                    Integer maxLength = currentObject.getSObjectType().getDescribe().fields.getMap().get( fieldName ).getDescribe().getLength();
                    if( currentLength > maxLength ) {
                        currentObject.put( fieldName, currentValue.substring( currentLength - maxLength, currentLength ) );
                    }
                }
            }
        }
    }

    public static List<String> joinEveryNthElement( List<String> input, String separator, Integer everyNth ) {
        List<String> output = new List<String>();
        Integer currentNth = 1;
        String elementOutput = '';
        for( String element : input ) {
            if( currentNth <= everyNth ) {
                if( elementOutput != '' ) {
                    elementOutput += separator;
                }
            } else {
                output.add( elementOutput );
                elementOutput = '';
                currentNth = 1;
            }
            elementOutput += element;
            currentNth++;
        }
        if( currentNth != 1 ) {
            output.add( elementOutput );
        }
        return output;
    }

}