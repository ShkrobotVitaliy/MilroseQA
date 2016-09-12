public class CreateProposalWithInvoiceController {
    private final static String PROPOSAL_INVOICE_DDP = 'Proposal Document';
    private final static String EMAIL_DELIVERY_METHOD = 'Email';
    private final static String ERROR_MESSAGE_INVALID_PARAMETERS = 'Can not create PDF, invalid parameters have been passed.';
    public Proposal__c proposal { get; set; }
    private Boolean isValid;
    private List<LStore__Stored_Document__c> attachments = new List<LStore__Stored_Document__c>();
    private List<Deposit_Invoice__c> depositInvoices;

    public CreateProposalWithInvoiceController(ApexPages.StandardController controller) {
        proposal = (Proposal__c)controller.getRecord();
        isValid = true;
        if( proposal == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
            isValid = false;
        } else {
            depositInvoices = [ SELECT Id FROM Deposit_Invoice__c WHERE Proposal__c = : proposal.Id AND Is_Created_From_Code__c = true LIMIT 1 ];
            if( depositInvoices.isEmpty() ) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
                isValid = false;
            } else {            	
                List<LStore__Stored_Document__c> attachmentsDb = [ SELECT Id, LStore__Type__c 
                                                                   FROM LStore__Stored_Document__c 
                                                                   WHERE Related_Object_Id__c = : depositInvoices[0].Id 
                                                                   ORDER BY CreatedDate DESC ];
                for( LStore__Stored_Document__c doc : attachmentsDb ) {
                    if( doc.LStore__Type__c == 'pdf' ) {
                        attachments.add( doc );
                    }
                }
                if( attachments.isEmpty() ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
                    isValid = false;
                }
            }
        }
    }

    public PageReference autoRun() {
        if( isValid ) {
            try {
                DDPEmailServices.sendDDPEmail( proposal.Id, PROPOSAL_INVOICE_DDP, EMAIL_DELIVERY_METHOD, null, proposal.Primary_Company_Contact__c, depositInvoices[0].Id, new List<Id>{ attachments[0].Id } );
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
        return new PageReference('/'+proposal.Id);
    }

}