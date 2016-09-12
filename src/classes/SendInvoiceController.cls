public with sharing class SendInvoiceController {
    private final static String ACTION = 'action';
    private final static String DDPNAME = 'ddpName';
    private final static String EMAIL_OPTION = 'Email';
    private final static String EMAIL_ACTION = 'Send';
    private final static String ATTACH_OPTION = 'Attach';
    private final static String ATTACH_ACTION = 'Create';
    private final static String CREATE_INVOICES_DDPNAME = 'CreateInvoices';
    private final static String CREATE_CREDIT_1 = 'Create Credit 1';
    private final static String CREATE_CREDIT_1_DDPNAME = 'CreateCredit1';
    private final static String CREATE_CREDIT_2 = 'Create Credit 2';
    private final static String CREATE_CREDIT_2_DDPNAME = 'CreateCredit2';
    private final static String ERROR_MESSAGE_CANNOT_SEND_PDF_SIWNC = 'Can not send PDF to Client, because Sales Invoice was not created yet or its info was not passed.';
    private final static String ERROR_MESSAGE_CANNOT_SEND_PDF_CWNP = 'Can not send PDF to Client, because the Client was not populated on this Pro-forma Invoice.';
    private final static String ERROR_MESSAGE_INVALID_PARAMETERS = 'Can not create PDF, invalid parameters have been passed.';
    private final static String ERROR_MESSAGE_INVALID_FFA_INVOICE_CREATED = 'FFA Invoice should be created before printing of PDF.';
    private final static String NO_DDP_AVAILABLE = 'Error finding correct DDP.';
    
    private final static String FEDEX_DDP = 'Mailroom FedEx';
    private final static String FEDEX_FILTER = 'FED EX';
    private final static String SUPREME_SYSTEMS_DDP = 'Mailroom Supreme Systems';
    private final static String SUPREME_SYSTEMS_FILTER = 'MESS';
    private final static String REIMBURSABLE_SHREDDING_DDP = 'Reimbursable Shredding';
    private final static String REIMBURSABLE_SCANNING_DDP = 'Reimbursable Scanning';
    

    @TestVisible private String deliveryOption {get;set;}
    @TestVisible private String ddpNameOption {get;set;}
    @TestVisible public Pro_forma_invoice__c invoice {get;set;}
    @TestVisible private Map<Id, Billing_Line_Item__c> lineItemsForPDF;
    @TestVisible private String retUrl {
        get {
            if(retUrl == null) retUrl = '/' + Pro_forma_invoice__c.sObjectType.getDescribe().getKeyPrefix() + '/o';
            return retUrl;
        }
        set;
    }
    public Boolean isValid {get;set;}
    public Boolean showWarning { get { if( showWarning == null ) showWarning = false; return showWarning; } set; }

    public SendInvoiceController(ApexPages.StandardController controller) {
        invoice = (Pro_forma_invoice__c)controller.getRecord();
        isValid = true;
        if( invoice == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
            isValid = false;
        }

        if( ApexPages.currentPage().getParameters().get(DDPNAME) == CREATE_INVOICES_DDPNAME ) {
            ddpNameOption = DDPEmailServices.DDP_NAME_CREATE_INVOICES;
        } else {
            if( ApexPages.currentPage().getParameters().get(DDPNAME) == CREATE_CREDIT_1_DDPNAME ) {
                ddpNameOption = CREATE_CREDIT_1;
            } else {
                if( ApexPages.currentPage().getParameters().get(DDPNAME) == CREATE_CREDIT_2_DDPNAME ) {
                    ddpNameOption = CREATE_CREDIT_2;
                } else {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
                    isValid = false;
                }
            }
        }

        if( ApexPages.currentPage().getParameters().get(ACTION) == ATTACH_ACTION ) {
            deliveryOption = ATTACH_OPTION;
        } else {
            if( ApexPages.currentPage().getParameters().get(ACTION) == EMAIL_ACTION ) {
                deliveryOption = EMAIL_OPTION;
            } else {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_PARAMETERS ) );
                isValid = false;
            }
        }

        if( deliveryOption == EMAIL_OPTION ) {
            if( !invoice.cl_FFA_Invoice_Created__c) {
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_INVALID_FFA_INVOICE_CREATED ) );
                isValid = false;
            } else if( String.isBlank( invoice.Accounting_Contact__c/*contactId*/ ) ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_CANNOT_SEND_PDF_CWNP ) );
                    isValid = false;
            } else {
                if( String.isBlank( invoice.Sales_Invoice__c/*salesInvoiceId*/ ) ) {
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, ERROR_MESSAGE_CANNOT_SEND_PDF_SIWNC ) );
                    isValid = false;
                }  
            }
        }
    }

    public PageReference goBack() {
        return new PageReference( '/' + invoice.Id );
    }

    public void autorun() {
        //Checking, Can system generate Credit Note 1/2 pdf
        if (!this.invoice.cl_FFA_Credit_Note_Created_1__c && ApexPages.currentPage().getParameters().get(DDPNAME).equals(CREATE_CREDIT_1_DDPNAME)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.LEGACY_CANNOT_GENERATE_NOTE_1_PDF));
            isValid = false;
            return;
        
        }
        
        if (!this.invoice.cl_FFA_Credit_Note_Created_2__c && ApexPages.currentPage().getParameters().get(DDPNAME).equals(CREATE_CREDIT_2_DDPNAME)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ErrorException.LEGACY_CANNOT_GENERATE_NOTE_2_PDF));
            isValid = false;
            return;
        
        }
        
        if( invoice.Deposit_On_Account__c && invoice.Credit__c == 0 ) {
            showWarning = true;
        }
        
        prepareDdpHelpers();
        //Update invoice PDF data
        Boolean updateInvoiceStatus = ProformaInvoiceServices.updateInvoicesDataForPDF( new Map<Id, Pro_forma_Invoice__c>{invoice.Id => invoice}, ApexPages.currentPage().getParameters().get(ACTION) == EMAIL_ACTION);
        
        if( !updateInvoiceStatus ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occurred While Updating Pro-Forma Invoice'));
        
        }
    
    }

    public void prepareDdpHelpers() {
        List<DDP_Helper__c> ddpHelpers = [ SELECT Currency1__c, Currency2__c, Currency3__c, Text2__c, Pro_forma_Invoice__c
                                           FROM DDP_Helper__c
                                           WHERE Pro_forma_Invoice__c = : invoice.Id
                                             AND ( Text2__c = : DepositInvoiceServices.SERVICE_RETAINER_TYPE
                                                OR Text2__c = : DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE )
                                             AND Type__c = 'Pro-Forma Invoice - Deposit Invoice Data' ];
        try {
            DELETE ddpHelpers;
        } catch( dmlException ex ) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occurred While Updating Deposit Invoice Totals: ' + ex.getMessage()));
            return;
        }
        Map<String, DDP_Helper__c> invoiceTypeToDdpHelper = new Map<String, DDP_Helper__c>();
        ddpHelpers = new List<DDP_Helper__c>();
        if( !String.isBlank( invoice.Project_Profile__c ) ) {
            List<Deposit_Invoice__c> depositInvoices = [ SELECT Amount_Paid__c, Amount_Remaining__c, Amount_Applied__c, Deposit_Invoice_Type__c
                                                         FROM Deposit_Invoice__c
                                                         WHERE Project_Profile__c = : invoice.Project_Profile__c
                                                           AND ( Deposit_Invoice_Type__c = : DepositInvoiceServices.SERVICE_RETAINER_TYPE
                                                              OR Deposit_Invoice_Type__c = : DepositInvoiceServices.MUNICIPAL_FEE_RETAINER_TYPE ) ];
            for( Deposit_Invoice__c depositInvoice : depositInvoices ) {
                if( !invoiceTypeToDdpHelper.containsKey( depositInvoice.Deposit_Invoice_Type__c ) ) {
                    invoiceTypeToDdpHelper.put( depositInvoice.Deposit_Invoice_Type__c, new DDP_Helper__c( Text2__c = depositInvoice.Deposit_Invoice_Type__c,
                                                                                                           Currency1__c = 0.00,
                                                                                                           Currency2__c = 0.00,
                                                                                                           Currency3__c = 0.00,
                                                                                                           Pro_forma_Invoice__c = invoice.Id,
                                                                                                           Type__c = 'Pro-Forma Invoice - Deposit Invoice Data' ) );
                }
                invoiceTypeToDdpHelper.get( depositInvoice.Deposit_Invoice_Type__c ).Currency1__c += depositInvoice.Amount_Paid__c;
                invoiceTypeToDdpHelper.get( depositInvoice.Deposit_Invoice_Type__c ).Currency2__c += depositInvoice.Amount_Applied__c;
                invoiceTypeToDdpHelper.get( depositInvoice.Deposit_Invoice_Type__c ).Currency3__c += depositInvoice.Amount_Remaining__c;
            }
            try {
                INSERT invoiceTypeToDdpHelper.values();
            } catch( dmlException ex ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error Occured While Updating Deposit Invoice Totals: ' + ex.getMessage()));
                return;
            }
        }
    }

    public PageReference prepareAndRunDDP() {
        if( isValid && !ApexPages.hasMessages() ) {
            ProjectProfileServices.calculateOutstandingAmountsByDate( new Set<Id>{invoice.Project_Profile__c} );
            return runDDP();
        } else {
            return null;
        }
    }

    @TestVisible private PageReference runDDP() {
        PageReference pr;

        List<Loop__DDP_Integration_Option__c> deliveryMethod  = [SELECT Id, Loop__DDP__c
                                                                 FROM Loop__DDP_Integration_Option__c
                                                                 WHERE Loop__DDP__r.Name =: ddpNameOption
                                                                 AND Name = : deliveryOption];                                           
        System.debug('deliveryMethod='+deliveryMethod);
        if( !deliveryMethod.isEmpty() ) {
            pr = new PageReference('/apex/loop__looplus');
            pr.getParameters().put('eid', invoice.Id);
            pr.getParameters().put('autorun', 'true');
            pr.getParameters().put('ddpIds', deliveryMethod[0].Loop__DDP__c);
            pr.getParameters().put('deploy', deliveryMethod[0].Id);
            if( deliveryOption == EMAIL_OPTION ) {
                pr.getParameters().put('contactId', invoice.Accounting_Contact__c/*contactId*/);
            }
            Map<String, String> attachmentIdToParentId = StoredDocumentServices.getParentIdsAndAttachmentIdsForUploadedChecks( new Set<Id>{ invoice.Id } ).get( invoice.Id );
            if( attachmentIdToParentId != null && !attachmentIdToParentId.keySet().isEmpty() ) {
                Set<String> parentIdsSet = new Set<String>( attachmentIdToParentId.values() );
                parentIdsSet.remove(null);
                List<String> parentIds = new List<String>();
                parentIds.addAll( parentIdsSet );
                pr.getParameters().put( 'parentIds', String.join( parentIds, ',' ) ); //list of stored docs' parent ids

                List<String> attachIds = new List<String>();
                attachIds.addAll( attachmentIdToParentId.keySet() );
                pr.getParameters().put( 'attachIds', String.join( attachIds, ',' ) ); //list of stored docs' ids
            }
            return pr;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, NO_DDP_AVAILABLE));
        }
        return null;
    }
}