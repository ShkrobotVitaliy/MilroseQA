public with sharing class DeleteProformaInvoiceController {
    private final static String FFA_INVOICE_IS_CREATED_FOR_PROFORMA = 'This Pro-forma Invoice has already been sent to FinancialForce and cannot be deleted.';

    public Boolean isValid {get; set;}
	private final Pro_Forma_Invoice__c currentPFI;

    public DeleteProformaInvoiceController(ApexPages.StandardController stdController) {
        this.currentPFI = (Pro_Forma_Invoice__c)stdController.getRecord();
        isValid = true;
    }

    public PageReference validateAndDelete(){
        if( currentPFI.cl_FFA_Invoice_Created__c ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.INFO, FFA_INVOICE_IS_CREATED_FOR_PROFORMA ) );
            isValid = false;
            return null;
        } else {
            try{
                delete currentPFI;
            } catch (Exception e){
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error deliting Pro Forma Invoice:' + e.getMessage()));
            }
            return new PageReference( '/'+ Pro_forma_Invoice__c.sObjectType.getDescribe().getKeyPrefix() );
        }
    }

    public PageReference goBack() {
        return new PageReference( '/'+ currentPFI.Id );
    }
}