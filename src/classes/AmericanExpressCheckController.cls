public with sharing class AmericanExpressCheckController {
    private static final Long UNIQUE_07_DIGIT_START = 1230000L;
    private static final Long UNIQUE_18_DIGIT_START = 320142751000000000L;

    public Boolean isValid { get { if( isValid == null ) isValid = true; return isValid; } set; }
    
    public Map<Id, List<String>> invoiceIdToUniqueNumbers { get { if( invoiceIdToUniqueNumbers == null ) invoiceIdToUniqueNumbers = new Map<Id, List<String>>(); return invoiceIdToUniqueNumbers; } set; }
    public Pro_forma_Invoice__c pfi { get; set; }
    public List<AmericanExpressProformaInvoiceWrapper> invoices { get { if( invoices == null ) invoices = new List<AmericanExpressProformaInvoiceWrapper>(); return invoices; } set; }

    public AmericanExpressCheckController( ApexPages.StandardController controller ) {
        pfi = (Pro_forma_Invoice__c)controller.getRecord();
        if( pfi == null || pfi.Id == null ) {
            isValid = false;
            MilroseDevHelper.addMessage( 'No valid Pro-forma Invoice was given.' );
            return;
        }
        List<Pro_forma_Invoice__c> pfis = [ SELECT Invoice_Date__c FROM Pro_forma_Invoice__c WHERE Id = : pfi.Id ];
        if( !pfis.isEmpty() ) {
            pfi = pfis[0];
        } else {
            isValid = false;
            MilroseDevHelper.addMessage( 'No valid Pro-forma Invoice was given.' );
            return;
        }
        List<c2g__codaPurchaseInvoice__c> purchaseInvoices = [ SELECT Id, Billing_Line_Item__r.Milestone_Date__c, Check_Request__r.Account__r.Name, Check_Request__r.Account__r.City__c,
                                                                       Check_Request__r.Account__r.StateProvID__c, Check_Request__r.Owner.Name, Billing_Line_Item__r.Amount__c,
                                                                       Billing_Line_Item__r.Name, Check_Request__r.Account__r.Phone, Check_Request__r.Account__r.BillingStreet,
                                                                       Check_Request__r.Account__r.BillingCity, Check_Request__r.Account__r.BillingState,
                                                                       Check_Request__r.Account__r.BillingPostalCode, Check_Request__r.Account__r.BillingCountry
                                                               FROM c2g__codaPurchaseInvoice__c
                                                               WHERE Check_Request__r.Requested_From__c = : CheckServices.CHARGE
                                                                 AND Billing_Line_Item__r.Pro_forma_Invoice__c = : pfi.Id ];
        if( purchaseInvoices.isEmpty() ) {
            isValid = false;
            MilroseDevHelper.addMessage( 'No valid checks were found.' );
            return;
        }
        for( c2g__codaPurchaseInvoice__c invoice : purchaseInvoices ) {
            invoices.add( new AmericanExpressProformaInvoiceWrapper( invoice ) );
        }
    }

    public class AmericanExpressProformaInvoiceWrapper {
        public String invoiceId   { get; set; }
        public Date milestoneDate { get; set; }
        public String accountName              { get { if( accountName == null ) accountName = ''; return accountName; } set; }
        public String accountCity              { get { if( accountCity == null ) accountCity = ''; return accountCity; } set; }
        public String accountStateProvID       { get { if( accountStateProvID == null ) accountStateProvID = ''; return accountStateProvID; } set; }
        public String checkOwnerName           { get { if( checkOwnerName == null ) checkOwnerName = ''; return checkOwnerName; } set; }
        public Decimal bliAmount               { get { if( bliAmount == null ) bliAmount = 0.00; return bliAmount; } set; }
        public String accountBillingStreet     { get { if( accountBillingStreet == null ) accountBillingStreet = ''; return accountBillingStreet; } set; }
        public String accountBillingCity       { get { if( accountBillingCity == null ) accountBillingCity = ''; return accountBillingCity; } set; }
        public String accountBillingState      { get { if( accountBillingState == null ) accountBillingState = ''; return accountBillingState; } set; }
        public String accountBillingPostalCode { get { if( accountBillingPostalCode == null ) accountBillingPostalCode = ''; return accountBillingPostalCode; } set; }
        public String accountBillingCountry    { get { if( accountBillingCountry == null ) accountBillingCountry = ''; return accountBillingCountry; } set; }
        public String accountPhone             { get { if( accountPhone == null ) accountPhone = ''; return accountPhone; } set; }
        public String shortUniqueNumber        { get { if( shortUniqueNumber == null ) shortUniqueNumber = ''; return shortUniqueNumber; } set; }
        public String longUniqueNumber         { get { if( longUniqueNumber == null ) longUniqueNumber = ''; return longUniqueNumber; } set; }

        public AmericanExpressProformaInvoiceWrapper( c2g__codaPurchaseInvoice__c invoice ) {
            this.invoiceId = invoice.Id;
            this.milestoneDate = invoice.Billing_Line_Item__r.Milestone_Date__c;
            this.accountName = invoice.Check_Request__r.Account__r.Name;
            this.accountCity = invoice.Check_Request__r.Account__r.City__c;
            this.accountStateProvID = invoice.Check_Request__r.Account__r.StateProvID__c;
            this.checkOwnerName = invoice.Check_Request__r.Owner.Name;
            this.bliAmount = invoice.Billing_Line_Item__r.Amount__c;
            this.accountBillingStreet = invoice.Check_Request__r.Account__r.BillingStreet;
            this.accountBillingCity = invoice.Check_Request__r.Account__r.BillingCity;
            this.accountBillingState = invoice.Check_Request__r.Account__r.BillingState;
            this.accountBillingPostalCode = invoice.Check_Request__r.Account__r.BillingPostalCode;
            this.accountBillingCountry = invoice.Check_Request__r.Account__r.BillingCountry;
            this.accountPhone = invoice.Check_Request__r.Account__r.Phone;

            Integer bliNumber = 0;
            Pattern nonWordChar = Pattern.compile('[\\D]');
            String bliNumberString = nonWordChar.matcher( invoice.Billing_Line_Item__r.Name ).replaceAll('');
            if( !String.isEmpty( bliNumberString ) ) {
                bliNumber += Integer.valueOf( bliNumberString );
            }
            shortUniqueNumber = String.valueOf( AmericanExpressCheckController.UNIQUE_07_DIGIT_START + bliNumber );
            longUniqueNumber = String.valueOf( AmericanExpressCheckController.UNIQUE_18_DIGIT_START + bliNumber );
        }

    }

}