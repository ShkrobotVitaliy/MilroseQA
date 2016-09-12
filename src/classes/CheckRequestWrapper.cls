public with sharing class CheckRequestWrapper {
    public Check__c check { get; set; }
    public Boolean isSelected { get; set; }
    
    public CheckRequestWrapper(Check__c check) {
        this.check = check;
        this.isSelected = false;
    
    }
    
}