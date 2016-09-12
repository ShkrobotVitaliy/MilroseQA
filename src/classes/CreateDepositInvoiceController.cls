public class CreateDepositInvoiceController {
    private final static String ERROR_MESSAGE_INVALID_PARAMETERS = 'Can not create PDF, invalid parameters have been passed.';
    public Deposit_invoice__c invoice { get; set; }
    private Boolean isValid { get; set; }

    public CreateDepositInvoiceController(ApexPages.StandardController controller) {
        invoice = (Deposit_invoice__c)controller.getRecord();
        isValid = true;
        if( invoice == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
            isValid = false;
        }
    }

    public PageReference autoRun() {
        if( isValid ) {
            try {
                DDPEmailServices.generateAndAttachPDF( invoice.Id, DepositInvoiceServices.RETAINER_INVOICE_DDP, null, null, null, null);
                return goBack();
            } catch( exception ex ) {
                ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.Error, ex.getMessage() ) );
                return null;
            }
        } else {
            return null;
        }
    }

    public PageReference goBack() {
        return new PageReference('/'+invoice.Id);
    }

}