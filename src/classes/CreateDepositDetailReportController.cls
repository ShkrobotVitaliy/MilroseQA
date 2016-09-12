public class CreateDepositDetailReportController {
    private final static String DEPOSIT_DETAIL_DDP = 'Deposit Detail';
    private final static String ERROR_MESSAGE_INVALID_PARAMETERS = 'Can not create PDF, invalid parameters have been passed.';
    public Deposit_invoice__c invoice { get; set; }
    public Boolean isValid { get; set; }

    public CreateDepositDetailReportController( ApexPages.StandardController controller ) {
        invoice = (Deposit_invoice__c)controller.getRecord();
        isValid = true;
        if( invoice == null || invoice.Id == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
            isValid = false;
        } else {
            List<Deposit_invoice__c> invoices = [ SELECT Id FROM Deposit_invoice__c WHERE Id = : invoice.Id ];
            if( !invoices.isEmpty() ) {
                invoice = invoices[0];
            } else {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'No deposit invoice found.' ) );
                isValid = false;
                return;
            }
        }
    }

    public PageReference autorun() {
        if( isValid ) {
            try {
                DDPEmailServices.generateAndAttachPDF( invoice.Id, DEPOSIT_DETAIL_DDP, null, null, null, null);
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