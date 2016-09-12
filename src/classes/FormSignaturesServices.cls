public with sharing class FormSignaturesServices {

    public static void createFormSignatures( List<Form_Item__c> formItemListNew ){
        List<Form_Signature__c> formSignatureForInsert = new List<Form_Signature__c>();
        for( Form_Item__c formItem: formItemListNew ){
            if( formItem.External_Form__c == null ){
                if( formItem.Form_Signatories__c != null ){
                    Integer i=1;
                    for( String item: formItem.Form_Signatories__c.split(';',1000)){
                        if( item.trim() != '' ){
                            Form_Signature__c formSignatureItem = new Form_Signature__c( );
                            formSignatureItem.Form_Item__c = formItem.Id;
                            formSignatureItem.Task_Item__c = formItem.Complete_Forms__c;
                            formSignatureItem.Project__c = formItem.Project__c;
                            formSignatureItem.Service_Item__c = formItem.Service_Item__c;
                            formSignatureItem.Role__c = item.trim();
                            formSignatureItem.Order__c = i;
                            formSignatureForInsert.add(formSignatureItem);
                        }
                        i++;
                    }
                }else {
                    Form_Signature__c formSignatureItem = new Form_Signature__c( Form_Item__c = formItem.Id, Task_Item__c = formItem.Complete_Forms__c, Project__c = formItem.Project__c, Order__c = 1 );
                    formSignatureForInsert.add(formSignatureItem);
                }
            }
        }
        try{
            insert formSignatureForInsert;
        }catch( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Form_Signature__c formAssignment = formSignatureForInsert[dmlEx.getDmlIndex(i)];
                for( Form_Item__c formItem: formItemListNew ){
                    if( formItem.Id == formAssignment.Form_Item__c ){
                        formAssignment.addError('Can not insert Form Assignment.' + dmlEx.getMessage());
                    }
                }
            }
        }
    }
}