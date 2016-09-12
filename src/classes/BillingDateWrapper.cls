public with sharing class BillingDateWrapper {

    /**
     * Record.
     */
    public Billing_Date__c bd {get; set;}

    /**
     * Flag represents selection checkbox state
     */
    public Decimal totalAmount = 0;

    public Decimal amount {
        get {
            if(amount == null) {
                amount = 0;
            }
            return amount.setScale(2);
        }
        set;
    }

    public Map<String, Decimal> amountTypeToAmount;

    /**
     * Constructs wrapper for given Billing_Date__c object.
     *
     * @param Billing_Date__c bli - object to construct wrapper for
     */
    public BillingDateWrapper( final Billing_Date__c bd, Decimal totalAmount, Map<String, Decimal> amountTypeToAmount ) {
        this.amount = 0;
        this.bd = bd;
        this.totalAmount = null == totalAmount ? 0 : totalAmount;
        this.amountTypeToAmount = amountTypeToAmount;
        this.setAmount();
    }

    public void setAmount(){
        if(this.bd != null && this.bd.Percentage__c != null && this.totalAmount != 0) {
            if( !bd.Billed__c ){
            	if ( amountTypeToAmount == null || amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) == 0){
            		this.amount = this.totalAmount * (this.bd.Percentage__c/100);
            	}else{
            		this.amount = ( ( bd.Percentage__c / amountTypeToAmount.get( BillingLineItemServices.UNBILLED_PERCENTAGE ) ) *
                        			    ( totalAmount - amountTypeToAmount.get( BillingLineItemServices.BILLED_AMOUNT ) ) ).setScale(2);

            	}
            }else{
            	this.amount = bd.Amount__c;
            }
        }
    }
}