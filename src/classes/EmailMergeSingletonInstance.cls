public class EmailMergeSingletonInstance {
    public static final EmailMergeSingletonInstance INSTANCE = new EmailMergeSingletonInstance();
    
    public Map<String, String> mergeFieldsMap = new Map<String, String>(); 

    private EmailMergeSingletonInstance() {
        system.debug('!!! construction');
    
    }

}