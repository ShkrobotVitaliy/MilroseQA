public with sharing class FormAssignmentsServices {

    public static void createFormAssignments( List<Form_Item__c> formItemListNew ){
        List<Form_Assignment__c> formAssignForInsert = new List<Form_Assignment__c>();
        for( Form_Item__c formItem: formItemListNew ){
            //MRS-6361
            Form_Assignment__c formAssignItem = new Form_Assignment__c( );
            formAssignItem.Form_Item__c = formItem.Id;
            formAssignItem.Project__c = formItem.Project__c;
            if( formItem.Manualy_Uploaded_Form__c || formItem.Complete_Forms_Status__c == FormItemsServices.FORM_ITEM_STATUS_GENERATED ){
                formAssignItem.Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;
            } 

            formAssignForInsert.add(formAssignItem);
        }
        try{
            insert formAssignForInsert;
        }catch( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Form_Assignment__c formAssignment = formAssignForInsert[dmlEx.getDmlIndex(i)];
                for( Form_Item__c formItem: formItemListNew ){
                    if( formItem.Id == formAssignment.Form_Item__c ){
                        formAssignment.addError('Can not insert Form Assignment.' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static void updateFormAssignmentsStatus( List<Form_Item__c> formItems ){
        if( formItems == null || formItems.isEmpty() ) return;

        List<Form_Assignment__c> formAssignForUpdate = new List<Form_Assignment__c>();

        for( Form_Assignment__c item: [Select Id, Form_Item__c, Status__c From Form_Assignment__c Where Form_Item__c IN: formItems] ){
            if( String.isEmpty( item.Status__c ) ) {
                item.Status__c = FormItemsServices.FORM_ITEM_STATUS_GENERATED;
                formAssignForUpdate.add(item);
            }
        }
        try{
            update formAssignForUpdate;
        }catch( DMLException dmlEx){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                Form_Assignment__c formAssignment = formAssignForUpdate[dmlEx.getDmlIndex(i)];
                for( Form_Item__c formItem: formItems ){
                    if( formItem.Id == formAssignment.Form_Item__c ){
                        formItem.addError('Can not update Form Assignment.' + dmlEx.getMessage());
                    }
                }
            }
        }
    }

    public static List<Form_Assignment__c> filterFormAssignmentsForEventManagement( List<Form_Assignment__c> newList, Map<Id, Form_Assignment__c> oldMap ) {
        List<Form_Assignment__c> filteredFormAssignments = new List<Form_Assignment__c>();
        for( Form_Assignment__c formAssignmentItem : newList ) {
            if( formAssignmentItem.Alert_Calendar__c != oldMap.get( formAssignmentItem.Id ).Alert_Calendar__c ) {
                filteredFormAssignments.add( formAssignmentItem );
            }
        }
        return filteredFormAssignments;
    }

}