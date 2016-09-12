public class TaskItemModel{
    /* PROPERTIES */
    public Boolean isBillable { get; set; }
    public Boolean isLockedTaskItem { get; set; }
    public String percentage { get; set; }
    public String id { get; set; }
    public Decimal totalServicePrice { get; set; }
    public Decimal amountFromBLI { get; set; }
	public Boolean isLocked { get; set; } // MRS 7365

    private Decimal discountedTotalProjectAmount;

    public transient Decimal amount;
    public Decimal getAmount() {
        Decimal amount = 0;

        if( !String.isBlank( this.percentage ) ) {
            if( amountFromBLI != 0 ){
                amount = amountFromBLI;
            }else{
                amount = ( Decimal.valueOf( percentage ) / 100 ) * ( discountedTotalProjectAmount != null
                                                                 ? this.discountedTotalProjectAmount
                                                                 : this.totalServicePrice );
            }
        }
        return amount.setScale(2);
    }

    /* Constructor */
    public TaskItemModel(Task_Item__c taskItem, Project_Profile__c projectProfile, Boolean isLockedTaskItem, Decimal amountFromBLI ) {
        this.isBillable       = taskItem.Billing_Trigger__c;
        this.id               = taskItem.id;
        this.isLockedTaskItem = isLockedTaskItem;
        this.percentage       = String.valueOf(taskItem.Billing_Percentage__c);
        this.amountFromBLI    = amountFromBLI;
		this.isLocked 		  = taskItem.Is_Locked__c;

        if( projectProfile.Billing_Method__c.equals( ProjectProfileServices.BILLINGMETHODPERCENTAGE ) &&
            !projectProfile.Interval__c ) {
            this.discountedTotalProjectAmount = projectProfile.Cost__c;
        }
    }

}