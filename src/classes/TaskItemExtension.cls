public with sharing class TaskItemExtension {
    private final Task_Item__c taskItem;
    private List<Check__c> checksForCompare;

    private Map<Id, Decimal> workTypeIdToEstimatedCost { get; set; }

    public String checkIdToRemove { get; set; }
    public String checkIdForCalculateFee { get; set; }
    public String checkIdForEditAmount { get; set; }
    public Boolean showWorkTypePanel { get; set; }
    public Double totalFee {
        get {
            if (null == this.totalFee) {
                this.totalFee = 0.00;

            }
            return this.totalFee;
        }
        set;
    }

    public Boolean isInactiveService {
        get {
            return this.taskItem.Service_Item__r.Status__c == ServiceItemServices.SERVICE_STATUS_INACTIVE;
        }
        set;
    }

    public List<SelectOption> idToAccount {
        get {
            if (null == this.idToAccount) {
                this.idToAccount = AccountServices.getParentAccountsSelectOptions();

            }
            return this.idToAccount;

        }
        private set;
    }

    public List<RFI_Work__c> rfiWorkTypes {
        get {
            if (null == this.rfiWorkTypes) {
                this.rfiWorkTypes = RFIWorkTypeServices.getWorkTypeByServiceItemId(this.taskItem.Service_Item__c);

                //Remember Estimate Cost
                this.workTypeIdToEstimatedCost = new Map<Id, Decimal>();
                for (RFI_Work__c workType : this.rfiWorkTypes) {
                    this.workTypeIdToEstimatedCost.put(workType.Id, workType.Estimated_Cost__c);

                }

            }
            return this.rfiWorkTypes;

        }
        set;
    }

    public List<Check__c> checksRequest {
        get {
            if (null == this.checksRequest) {
                this.checksRequest = CheckServices.getChecksByTaskItemId(this.taskItem.Id);

            }
            return this.checksRequest;

        }
        set;

    }

    public TaskItemExtension(ApexPages.StandardController controller) {
        this.taskItem = (Task_Item__c)controller.getRecord();

    }

    public void updateCheck() {
        try {
            String message = getMessageChangedAmount();
            if (!String.isBlank(message)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));

            }
            CheckServices.updateCheck(this.checksRequest);

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        }

    }

    private String getMessageChangedAmount() {
        String message = '';
        Map<Id, Check__c> checkMap = new Map<Id, Check__c>(this.checksRequest);

        for (Check__c check : CheckServices.getChecksByTaskItemId(this.taskItem.Id)) {
            if (checkMap.containsKey(check.Id) && null != checkMap.get(check.Id).Date_Requested__c && check.Check_Amount__c != checkMap.get(check.Id).Check_Amount__c) {
                checkMap.get(check.Id).Date_Requested__c = null;
                message += 'Payee: ' + check.Account__r.Name + ' Description: ' + check.Description__c + ' Check Amount: ' + check.Check_Amount__c + ', ';

            }

        }

        if (String.isBlank(message)) {
            return '';

        }
        return message.substring(0, message.length() - 2) + ' check(s) request was already sent with a different check amount. Please inform the appropriate parties and re-send this request.';

    }

    public void addNewCheck() {
        try {
            CheckServices.updateCheck(this.checksRequest);
            this.checksRequest.add(CheckServices.newInstance(this.taskItem));
        } catch( Exception e ) {
            ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.INFO, e.getMessage() ) );
        }
    }

    public void removeCheck() {
        if (String.isBlank(this.checkIdToRemove)) {
            return;

        }

        Check__c check;
        Map<Id, Check__c> checksMap = new Map<Id, Check__c>(this.checksRequest);

        if (checksMap.containsKey(this.checkIdToRemove)) {
            check = checksMap.get(this.checkIdToRemove);

        }

        if (null == check || null != check.Date_Received__c || null != check.Check_Number__c || null != check.Date_Check_Returned__c|| !String.isBlank(check.Reasone__c)) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Sorry, but you cannot remove this check!'));
            return;

        }

        try {
            delete check;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Exception occured during delete check: ' + ex.getMessage()));

        } finally {
            this.checksRequest = null;

        }

    }

    /* ------------------------------------------------------ Begin Fee Calculator ----------------------------------------------------------------- */

    public void displayFeeCalculator() {
        if (isNotSupportServiceItem()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.SERVICE_ITEM_NOT_SUPPORT_FUNCTIONLITY));
            return;

        }

        this.totalFee = 0.00;

        for (RFI_Work__c type : this.rfiWorkTypes) {
            type.Filing_Fee__c = 0.00;

        }
        this.showWorkTypePanel = true;

    }

    public void hideFeeCalculator() {
        setOriginalEstimatedCost();
        this.showWorkTypePanel = false;

    }

    public void calculatorFee() {
        if (isNotSupportServiceItem()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.SERVICE_ITEM_NOT_SUPPORT_FUNCTIONLITY));
            return;

        }

        this.totalFee = 0.00;

        for (RFI_Work__c type : this.rfiWorkTypes) {
            type.Filing_Fee__c = CheckServices.calculateFee(Double.valueOf(type.Estimated_Cost__c), String.valueOf(this.taskItem.Service_Item__r.Subtype__c));
            this.totalFee += type.Filing_Fee__c;

        }

    }

    public void applyFeeCalculator() {
        for (Check__c check : this.checksRequest) {
            if (this.checkIdForCalculateFee == check.Id) {
                if (check.Check_Amount__c != this.totalFee && check.Check_Amount__c > 0 && check.Date_Requested__c != null) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, ErrorException.CHECK_REQUEST_SEND_AGAIN));
                    //check.Date_Requested__c = null;

                }
                check.Check_Amount__c                  = this.totalFee;
                check.Include_Estimated_Cost_Detail__c = true;
                break;

            }

        }

        try {
            setOriginalEstimatedCost();
            update this.rfiWorkTypes;

        } catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            return;

        } finally {
            this.showWorkTypePanel = false;

        }

    }

    @testVisible
    private void setOriginalEstimatedCost() {
        for (RFI_Work__c workType : this.rfiWorkTypes) {
            workType.Estimated_Cost__c = workTypeIdToEstimatedCost.get(workType.Id);

        }

    }

    public void calcualteSumFee() {
        this.totalFee = 0.00;

        for (RFI_Work__c type : this.rfiWorkTypes) {
            if (null == type.Filing_Fee__c) {
                type.Filing_Fee__c = 0.00;

            }
            this.totalFee += type.Filing_Fee__c;

        }

    }

    @TestVisible
    private Boolean isNotSupportServiceItem() {
        return !this.taskItem.Service_Item__r.Subtype__c.contains(ServiceItemServices.RFF_ALTERATION_TYPE_1) &&
               !this.taskItem.Service_Item__r.Subtype__c.contains(ServiceItemServices.RFF_ALTERATION_TYPE_2) &&
               !this.taskItem.Service_Item__r.Subtype__c.contains(ServiceItemServices.RFF_ALTERATION_TYPE_3);

    }

    /* ------------------------------------------------------ End Fee Calculator ----------------------------------------------------------------- */

}