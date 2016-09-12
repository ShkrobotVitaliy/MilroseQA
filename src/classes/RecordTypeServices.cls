public class RecordTypeServices {

    public static Id getRecordTypeIdBysObjectAndDeveloperName(String sObjectName, String DeveloperName) {
        Id recordTypeId = [SELECT Id, Name, DeveloperName, SobjectType
                        FROM RecordType
                        WHERE SobjectType =: sObjectName AND DeveloperName =: DeveloperName LIMIT 1][0].Id;

        if (null == recordTypeId) {
            throw new ErrorException('Record Type does not exist where sObject Name = ' + sObjectName + ' and DeveloperName = ' + DeveloperName);

        }

        return recordTypeId;

    }
     
    public static Id getRecordTypeIdByRecordTypeName(String recordTypeName) {
        Id recordTypeId = [SELECT Id 
                        FROM RecordType 
                        WHERE Name =: recordTypeName LIMIT 1].Id;

        if (null == recordTypeId) {
            throw new ErrorException('Record Type does not exist where Record Type Name = ' + recordTypeName);

        }

        return recordTypeId;
 
    }
     
    public static Id getRecordTypeIdByRecordTypeName(String recordTypeName, String sObjectName) {
        Id recordTypeId = [SELECT Id 
                        FROM RecordType 
                        WHERE Name =: recordTypeName And SobjectType =: sObjectName LIMIT 1].Id;

        if (null == recordTypeId) {
            throw new ErrorException('Record Type does not exist where Record Type Name = ' + recordTypeName);

        }

        return recordTypeId;
 
    }

    public static Map<Id, RecordType> getRecordTypesForObject(Set<String> recordTypeNames, String sObjectName) {
        return new Map<Id, RecordType>([SELECT Id, Name
                                           FROM RecordType 
                                           WHERE Name IN: recordTypeNames AND SobjectType =: sObjectName]);
    }

    public static Map<Id, RecordType> getRecordTypesForObjectByDeveloperNames( String sObjectName, Set<String> recordTypeNames ) {
        if( !String.isBlank(sObjectName) ) {
            if( recordTypeNames == null || recordTypeNames.isEmpty() ) {
                return new Map<Id, RecordType>( [ SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = : sObjectName ] );
            } else {
                return new Map<Id, RecordType>( [ SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = : sObjectName AND DeveloperName IN : recordTypeNames ] );
            }
        }
        return null;
    }

}