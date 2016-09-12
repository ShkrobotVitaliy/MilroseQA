public class RFISingletonInstance {
    public static final RFISingletonInstance INSTANCE = new RFISingletonInstance();
    
    public RFI_Scope__c rfiScope = new RFI_Scope__c();
    public Map<Id, RFI_Scope__c> rfiScopesMap = new Map<Id, RFI_Scope__c>(); 

    private RFISingletonInstance() {
    
    }

}