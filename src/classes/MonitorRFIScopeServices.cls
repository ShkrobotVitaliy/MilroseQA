public class MonitorRFIScopeServices {
    
    public static Monitor_RFI_Scope__c newInstance(final String sendTo, final Id rfiId, final String key, final String submitType, final Id rosterId, final String rfiLink) {
        return new Monitor_RFI_Scope__c(Sent_to__c = sendTo, 
                                        Sent__c = datetime.now(), 
                                        Send_Via__c = 'Email', 
                                        RFI_Scope__c = rfiId , 
                                        Key__c = key, 
                                        Submit_Type__c = submitType, 
                                        Project_Roster__c = rosterId, 
                                        URL_Link__c = rfiLink);
    
    }
    
    public static List<Monitor_RFI_Scope__c> getUnlockedRFIMonitorByUniqeKey(String key) {
        if (String.isBlank(key)) {
            return new List<Monitor_RFI_Scope__c>();
        
        }
        
        return new List<Monitor_RFI_Scope__c>( [ SELECT Id, RFI_Scope__c, RFI_Scope__r.Project__c
                                                 FROM Monitor_RFI_Scope__c 
                                                 WHERE Key__c =: String.escapeSingleQuotes(key) ] );
                                                   //AND Is_Lock__c = false ] ); //MRS-6516
    }
    
    public static Boolean isNotValidLink(String key) {
        if (String.isBlank(key)) {
            return false;
        
        }
        
        List<Monitor_RFI_Scope__c> tackItems = new List<Monitor_RFI_Scope__c>([SELECT Id 
                                                                               FROM Monitor_RFI_Scope__c 
                                                                               WHERE Key__c =: String.escapeSingleQuotes(key)]);
                                                                               
        return tackItems.isEmpty();
    
    }
    
}