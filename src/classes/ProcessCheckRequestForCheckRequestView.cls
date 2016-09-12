public with sharing class ProcessCheckRequestForCheckRequestView {
    private Map<Id, Check__c> selectedChecks;
    private Prevent_More_Than_One_Click__c clickPreventor;

    private Boolean isError = false;
    public Boolean getIsError() { return isError; }

    public ProcessCheckRequestForCheckRequestView( ApexPages.StandardSetController controller ) {
        controller.setPageSize(1000);
        selectedChecks  = new Map<Id, Check__c>( (List<Check__c>)controller.getSelected() );
    }

    public void setClickPreventor() {
        getPreventor();
        if( !clickPreventor.Is_Clicked__c || ( clickPreventor.Is_Clicked__c && Datetime.now() > clickPreventor.LastModifiedDate.addMinutes(5) ) ) {
            clickPreventor.Is_Clicked__c = true;
            clickPreventor.Who_Clicked__c = UserInfo.getUserId();
            UPDATE clickPreventor;
            showClickPreventorInfoMessage();
        } else {
            showClickPreventorErrorMessage();
            isError = true;
        }
    }

    private void getPreventor() {
        clickPreventor = Prevent_More_Than_One_Click__c.getValues( ReimbursableExpenseInvoiceServices.CUSTOM_SETTING_IS_PROCESS_CHECKED );
        if( clickPreventor == null ) {
            clickPreventor = new Prevent_More_Than_One_Click__c( Name = ReimbursableExpenseInvoiceServices.CUSTOM_SETTING_IS_PROCESS_CHECKED );
        try {
                INSERT clickPreventor;
            } catch( Exception e ) {
                ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, 'Can not lock the records. Please contact system admin.' ) );
                isError = true;
            }
        }
    }

    public PageReference processCheckRequestsInQueue() {
        if( !isError ) {
            getPreventor();
            if( !clickPreventor.Is_Clicked__c || clickPreventor.Who_Clicked__c != UserInfo.getUserId() ) {
                showClickPreventorErrorMessage();
                isError = true;
            }

            if( !isError ) {
                try {
                    CheckServices.processCheckRequestsInQueue( selectedChecks.keySet() );
                    ReimbursableExpenseInvoiceServices.runPayableInvoiceClickRule(); //Trigger Clicklink Rule for creating Payable Invoices
                } catch( Exception ex ) {
                    ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, ex.getMessage() ) );
                    isError = true;
                    return null;
                }

                clickPreventor.Is_Clicked__c = false;
                clickPreventor.Who_Clicked__c = '';
                UPDATE clickPreventor;

                return returnBack();
            }
        }
        return null;
    }

    public void showClickPreventorErrorMessage() {
        String userName = 'Someone';
        if( clickPreventor.Who_Clicked__c != null ) {
            List<User> users = [ SELECT Name FROM User WHERE Id = : clickPreventor.Who_Clicked__c ];
            if( !users.isEmpty() ) {
                userName = users[0].Name;
            }
        }
        ApexPages.addMessage( new ApexPages.message( ApexPages.severity.ERROR, userName + ' is currectly processing his check requests. Please try again in a minute.' ) );
    }

    public void showClickPreventorInfoMessage() {
        ApexPages.addMessage( new ApexPages.message( ApexPages.severity.INFO, 'Please do not close the tab. You will be redirected back after the job is done. Working...' ) );
    }

    public PageReference returnBack() {
        PageReference page = new PageReference( '/' + Check__c.sObjectType.getDescribe().getKeyPrefix() );
        page.setRedirect(true);
        return page;
    }
}