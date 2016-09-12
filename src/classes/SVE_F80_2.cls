global with sharing class SVE_F80_2 {
    public Form_Meta_Data_Object_1__c record { get; set; }
    Map<Integer, Id> pageNumberToId = new Map<Integer, Id>();
    Map<Integer, String> pageNumberToPageName = new Map<Integer, String>();

    public Boolean hidePageBody{
        get{
            return false;
        }
        set;
    }

    public String Label{
        get{
            return '';
        }
        set;
    }

    public SVE_F80_2(ApexPages.StandardController controller) {
        Form_Meta_Data_Object_1__c fmdo = (Form_Meta_Data_Object_1__c)controller.getRecord();

        List<String> fmdoNameString = new List<String>{'Form_Item__r.Complete_Forms_Status__c', 'Form_Item__r.sve_SVE_Visualforce_Page__c'};

        for ( Schema.SObjectField fieldTocken : (Schema.getGlobalDescribe().get('Form_Meta_Data_Object_1__c').getDescribe().Fields.getMap()).values()){
            Schema.DescribeFieldResult field = fieldTocken.getDescribe();
            fmdoNameString.add(fieldTocken.getDescribe().getName());
        }

        String queryString = 'SELECT ' + String.join( fmdoNameString, ', ') + ' FROM Form_Meta_Data_Object_1__c WHERE Id = \'' + fmdo.Id + '\'';

        List<Form_Meta_Data_Object_1__c> records = Database.query(queryString);

        record = records[0];

        initForm();
    }

    private void initForm(){
        for( Form_Meta_Data_Object_1__c fmdo : [ SELECT Id, Page_Number__c, Visualforce_Page__c
                                                 FROM Form_Meta_Data_Object_1__c 
                                                 WHERE Form_Item__c = : record.Form_Item__c Order By Page_Number__c ] ) {
            pageNumberToId.put( (Integer)fmdo.Page_Number__c, fmdo.Id );
            pageNumberToPageName.put( (Integer)fmdo.Page_Number__c, fmdo.Visualforce_Page__c );
        }
    }

    public PageReference savePage() {
        saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
        return new PageReference('/' + record.Task_Item__c );
    }

    public PageReference cancelPage() {
        return new PageReference('/' + record.Task_Item__c );
    }
    
    public PageReference nextPage() {
        PageReference pr;
        if( record.Page_Number__c + 1 <= pageNumberToId.size() ){
            saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
            pr = new PageReference('/apex/' + pageNumberToPageName.get( (Integer)record.Page_Number__c + 1 ) );
            pr.getParameters().put('id', pageNumberToId.get( (Integer)record.Page_Number__c + 1 ));
            pr.setRedirect(true);
        }
        return pr;
    }
    
    public PageReference prevPage() {
        PageReference pr;
        if( record.Page_Number__c - 1 > 0 ){
            saveReords( FormItemsServices.FORM_ITEM_STATUS_STARTED );
            pr = new PageReference('/apex/' + pageNumberToPageName.get( (Integer)record.Page_Number__c - 1 ) );
            pr.getParameters().put('id', pageNumberToId.get( (Integer)record.Page_Number__c - 1 ) );
            pr.setRedirect(true);
        }
        return pr;
    }

    public PageReference updateDocAndDdp() {
        saveReords( FormItemsServices.FORM_ITEM_STATUS_GENERATED );
 
        PageReference pr = new PageReference('/apex/CreateFormItemPDFHelper');
        if (!test.isRunningTest()) pr.getParameters().put('id', record.Id);
        pr.setRedirect(true);
        return pr;
    }

    private void saveReords( String formStatus ) {
        update record;
        update new Form_Item__c( Id = record.Form_Item__c, 
                                 Complete_Forms_Status__c = formStatus );
    }
    
    private final String FIVE_WHITE_SPACES = '     ';

    public void updateTEXTAreaLONGField(){
        record.TEXT_Area_LONG__c = '!';
        for( dataItem item: dataItemWrapper ){
            record.TEXT_Area_LONG__c += (item.value + FIVE_WHITE_SPACES).substring(0,5);
        }
    }

    public List<dataItem> dataItemWrapper{ 
        get{
            if( dataItemWrapper == null ){
                dataItemWrapper = new List<dataItem>();

                Double verticalStep = 20.7;  /* 373px(table height)/18(rows) */
                Double horizontalStep = 50;  /* 100px(table width) /2(columns) */
                Double positionLeft;
                Double positionTop = 205;
                Integer substringStart = 1;
                
                for ( Integer i = 1; i <= 18; i++ ){
                    List<dataItem> dataRow = new List<dataItem>();
                    positionLeft = 886;
                    for ( Integer j = 1; j <= 2; j++ ){
                        String dataItemValue;
                        if( !String.isBlank(record.TEXT_Area_LONG__c) && substringStart <= record.TEXT_Area_LONG__c.length() ){
                            if( substringStart + 5 <= record.TEXT_Area_LONG__c.length() ){
                                dataItemValue = record.TEXT_Area_LONG__c.substring( substringStart, substringStart + 5 );
                            }else{
                                dataItemValue = record.TEXT_Area_LONG__c.substring( substringStart, record.TEXT_Area_LONG__c.length());
                            }
                            if( dataItemValue == FIVE_WHITE_SPACES ) dataItemValue = '';
                            substringStart += 5;
                        }else{
                            dataItemValue = '';
                        }
                        dataRow.add( new dataItem(dataItemValue, positionTop, positionLeft) );
                        positionLeft += horizontalStep;
                    }
                    dataItemWrapper.addAll(dataRow);
                    positionTop += verticalStep;
                }
            }
            return dataItemWrapper;
        }
        set;
    }

    public class dataItem{
        public String value { get; set;}
        public String positionTop { get; set;}
        public String positionLeft { get; set;}
        private String PX = 'px;';
        
        public dataItem( String value, Double top, Double left){
            this.value = value;
            this.positionTop = 'top:' + String.valueOf(top) + PX;
            this.positionLeft = 'left:' + String.valueOf(left) + PX;
        }
    }
}