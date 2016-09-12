public with sharing class BillingLineItemWrapper {

    /**
     * Record.
     */
    public Billing_Line_Item__c bli {get; private set;}

    /**
     * Flag represents selection checkbox state
     */
    public Boolean selected {get; set;}

    /**
     * Constructs wrapper for given Billing_Line_Item__c object.
     *
     * @param Billing_Line_Item__c bli - object to construct wrapper for
     */
    public BillingLineItemWrapper(final Billing_Line_Item__c bli) {
        this.selected = false;
        this.bli = bli;
    }
}