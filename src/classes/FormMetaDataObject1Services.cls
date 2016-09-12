public with sharing class FormMetaDataObject1Services {

    public static final String DETERMINATION_TEAM_EMAIL = 'DeterminationTeam@MILROSE.com';
    
    public static Boolean allowCreateMetaDataObjectRecords = true;
    
    public static void populateSignatoriesFields( Map<Id, Form_Meta_Data_Object_1__c> metadataRecords ) {
        if ( metadataRecords.isEmpty() ) { return; }

        Map<Id, Id> fmdoIDToFormItemId = new Map<Id, Id>();
        Map<Id, List<Form_Signature__c>> formItemIdToSignatories = new Map<Id, List<Form_Signature__c>>();

        for( Form_Meta_Data_Object_1__c fmdo :metadataRecords.values() ){
            fmdoIDToFormItemId.put( fmdo.Id, fmdo.Form_Item__c );
        }

        for( Form_Signature__c sign : [ Select Id, Contact_Business_Fax__c, Contact_Business_Phone__c, Contact_First_Name__c, Contact_Last_Name__c, DOB_Tracking__c,
                                              Contact_Mailing_City__c, Contact_Mailing_State_Province__c, Contact_Mailing_Street__c, Contact_Full_Name__c, Home_Phone__c, 
                                              Contact_Mailing_Zip_Postal_Code__c, Contact_Mobile_Phone__c, Form_Item__c, Order__c, Company_Name__c, Inspections_Agency_Number__c,
                                              Contact_Professional_ID__c, Company_Address__c, Contact_Email__c, Contact_Mailing_Address__c, Contact_Title__c, Taxpayer_Id__c,
                                              Contact_Street_Address2__c, Contact_Suffix__c
                                        From  Form_Signature__c 
                                        Where Form_Item__c IN : fmdoIDToFormItemId.values() 
                                        Order By Order__c ] ) {
            if( !formItemIdToSignatories.containsKey( sign.Form_Item__c ) ) {
                formItemIdToSignatories.put( sign.Form_Item__c, new List<Form_Signature__c>() );
            }
            formItemIdToSignatories.get( sign.Form_Item__c ).add( sign );
        }

        if( formItemIdToSignatories.isEmpty() ) return;

        for( Form_Meta_Data_Object_1__c fmdo : metadataRecords.values() ){
            //Signatories for Forms
            for( Form_Signature__c signator : formItemIdToSignatories.get( fmdoIDToFormItemId.get( fmdo.Id ) ) ) {
                if( signator.Order__c > 0 && signator.Order__c <= 9 ) {
                    if ( signator.Order__c == 1 ){
                        fmdo.put( 'Signator_' + signator.Order__c + '_Street_Address2__c', signator.Contact_Street_Address2__c );
                        fmdo.put( 'Signator_' + signator.Order__c + '_Suffix__c', signator.Contact_Suffix__c );
                    }
                    fmdo.put( 'Signator_' + signator.Order__c + '_Business_Fax__c', signator.Contact_Business_Fax__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Business_Phone__c', signator.Contact_Business_Phone__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_First_Name__c', signator.Contact_First_Name__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Last_Name__c', signator.Contact_Last_Name__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Full_Name__c', signator.Contact_Full_Name__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Mailing_Address__c', signator.Contact_Mailing_Address__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Mailing_Street__c', signator.Contact_Mailing_Street__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Mailing_City__c', signator.Contact_Mailing_City__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Mailing_State__c', signator.Contact_Mailing_State_Province__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Mobile_Phone__c', signator.Contact_Mobile_Phone__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Zip_Code__c', signator.Contact_Mailing_Zip_Postal_Code__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_License_Number__c', signator.Contact_Professional_ID__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Email__c', signator.Contact_Email__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Title__c', signator.Contact_Title__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Business_Name__c', signator.Company_Name__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Business_Address__c', signator.Company_Address__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Taxpayer_Id__c', signator.Taxpayer_Id__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_Inspections_Agency_Number__c', signator.Inspections_Agency_Number__c );
                    fmdo.put( 'Signator_' + signator.Order__c + '_DOB_Tracking__c', signator.DOB_Tracking__c );
                }
            }
            fmdo.put( 'Signator_1_Home_Phone__c', formItemIdToSignatories.get( fmdoIDToFormItemId.get( fmdo.Id ) )[0].Home_Phone__c ); // set Home Phone only for first Signator 
        }
    }

    public static void populateBuildingFields( List<Form_Meta_Data_Object_1__c> metadataRecords ) {
        if ( metadataRecords.isEmpty() ) { return; }

        String userAlias = UserServices.getUserById( UserInfo.getUserId() ).Alias;

        Map<Id, Building__c> buildingMap = new Map<Id, Building__c>();
        Map<Id, Service_Item__c> serviceItemMap = new Map<Id, Service_Item__c>();

        for ( Form_Meta_Data_Object_1__c fmdo : metadataRecords){
            if (fmdo.Building__c != null ) {
                buildingMap.put(fmdo.Building__c, null);
            }
            if ( fmdo.Service_Item__c != null ) {
                serviceItemMap.put(fmdo.Service_Item__c, null);
            }
        }

        buildingMap = new Map<Id, Building__c>([SELECT Id, BIN__c, NYC_Block__c, CB__c, House_No__c, NYC_Lot__c, Street__c, Name, PostalCode__c, NYC_Section__c,
                                                        City__c, State__c, Legal_Height__c, Num_of_Stories__c, Construction_Class__c, Construction_Class_Code__c, Zoning1__c, Special_Zoning__c,
                                                        Occupancy_Class__c, Multiple_Dwelling__c, Num_Dwelling_Units__c, Map__c, Legal_Street_Width__c
                                                FROM Building__c
                                                WHERE Id IN : buildingMap.keySet()]);

        serviceItemMap = new Map<Id, Service_Item__c> ([SELECT Id, Floor__c, Municipal_Agency_ID__c, Project_Number__c, Project_Profile__r.Floor_s__c
                                                        FROM Service_Item__c
                                                        WHERE Id IN : serviceItemMap.keySet()]);

        for( Form_Meta_Data_Object_1__c fmdo : metadataRecords ){

            // Building Info
            if ( fmdo.Building__c != null ) {
                Building__c buildingItem = buildingMap.get(fmdo.Building__c);

                fmdo.Building_Bin__c                = buildingItem.BIN__c;
                fmdo.Building_Block__c              = buildingItem.NYC_Block__c;
                fmdo.Building_CB_No__c              = buildingItem.CB__c;
                fmdo.Building_House__c              = buildingItem.House_No__c;
                fmdo.Building_Lot__c                = buildingItem.NYC_Lot__c;
                fmdo.Building_Street_Name__c        = buildingItem.Street__c;
                fmdo.Building_Address__c            = buildingItem.Name;
                fmdo.Building_Zip_Code__c           = buildingItem.PostalCode__c;
                fmdo.Building_Section__c            = buildingItem.NYC_Section__c;
                fmdo.Building_City__c               = buildingItem.City__c;
                fmdo.Building_State__c              = buildingItem.State__c;
                fmdo.Building_Full_Address__c       = buildingItem.House_No__c + ' ' + buildingItem.Street__c + ', ' + buildingItem.City__c + ', ' + buildingItem.State__c + ' ' + buildingItem.PostalCode__c;

                fmdo.Building_Legal_Height__c       = String.valueOf(buildingItem.Legal_Height__c);
                fmdo.Building_Num_of_Stories__c     = String.valueOf(buildingItem.Num_of_Stories__c);
                fmdo.Building_Legal_Street_Width__c = buildingItem.Legal_Street_Width__c;
                fmdo.Building_Construction_Class__c = buildingItem.Construction_Class_Code__c;
                fmdo.Building_Zoning1__c            = buildingItem.Zoning1__c;
                fmdo.Building_Special_Zoning__c     = buildingItem.Special_Zoning__c;
                fmdo.Building_Occupancy_Class__c    = buildingItem.Occupancy_Class__c;
                fmdo.Building_Multiple_Dwelling__c  = buildingItem.Multiple_Dwelling__c;
                fmdo.Building_Num_Dwelling_Units__c = String.valueOf(buildingItem.Num_Dwelling_Units__c);
                fmdo.Building_Map__c                = buildingItem.Map__c;
            }

            // General Info
            if ( fmdo.Service_Item__c != null ) {
                Service_Item__c serviceItem = serviceItemMap.get(fmdo.Service_Item__c);

                fmdo.Building_Floor_s__c = String.isBlank(fmdo.Building_Floor_s__c) ? serviceItem.Floor__c : fmdo.Building_Floor_s__c;
                fmdo.Project_Floor_s__c = serviceItem.Project_Profile__r.Floor_s__c;
                fmdo.Building_MRC__c  = serviceItem.Municipal_Agency_ID__c;
                fmdo.Job_Number__c  = serviceItem.Municipal_Agency_ID__c;
                fmdo.Building_Project_No__c = serviceItem.Project_Number__c;
                fmdo.User_Alias__c = userAlias;
            }
        }
    }

    public static List<Form_Meta_Data_Object_1__c> filterFormMetaDataRecordsChangeBuilding( List<Form_Meta_Data_Object_1__c> fmdoRecords, Map<Id, Form_Meta_Data_Object_1__c> oldMap ){
        List<Form_Meta_Data_Object_1__c> fmdRecords = new List<Form_Meta_Data_Object_1__c>();
        for( Form_Meta_Data_Object_1__c fmdo : fmdoRecords ){
            if( (oldMap == null && fmdo.Building__c != null) || (oldMap != null && fmdo.Building__c != oldMap.get( fmdo.Id ).Building__c) ) {
                fmdRecords.add ( fmdo );
            }
        }
        return fmdRecords;
    }

    public static Map<Id, Form_Meta_Data_Object_1__c> filterFormMetaDataRecordsChangeSignatory( List<Form_Meta_Data_Object_1__c> fmdoRecords, Map<Id, Form_Meta_Data_Object_1__c> oldMap ){
        Map<Id, Form_Meta_Data_Object_1__c> fmdRecords = new Map<Id, Form_Meta_Data_Object_1__c>();
        for( Form_Meta_Data_Object_1__c fmdo : fmdoRecords ){
            Form_Meta_Data_Object_1__c oldFmdo = oldMap.get( fmdo.Id );
            if( fmdo.Signatory_1__c != oldFmdo.Signatory_1__c ||
                fmdo.Signatory_2__c != oldFmdo.Signatory_2__c ||
                fmdo.Signatory_3__c != oldFmdo.Signatory_3__c ||
                fmdo.Signatory_4__c != oldFmdo.Signatory_4__c ||
                fmdo.Signatory_5__c != oldFmdo.Signatory_5__c || 
                fmdo.Signatory_6__c != oldFmdo.Signatory_6__c ||
                fmdo.Signatory_7__c != oldFmdo.Signatory_7__c ||
                fmdo.Signatory_8__c != oldFmdo.Signatory_8__c ||
                fmdo.Signatory_9__c != oldFmdo.Signatory_9__c ) {
                fmdRecords.put( fmdo.Id, fmdo );
            }
        }
        return fmdRecords;
    }

    public static void createMetaDataObjectRecords( List<Form_Item__c> commingFormItems ){
        List<Form_Meta_Data_Object_1__c> allRecords = new List<Form_Meta_Data_Object_1__c>();
        for( Form_Item__c fi : commingFormItems ) {
            if ( fi.External_Form__c == null ) {
                allRecords.addAll( initFormMetaDataObjects( fi ) );
            }
        }
        insert allRecords;
    }


    public static List<Form_Meta_Data_Object_1__c> initFormMetaDataObjects( Form_Item__c formItem ) {
        List<Form_Meta_Data_Object_1__c> metaDataObjects = new List<Form_Meta_Data_Object_1__c>();
        Form_Meta_Data_Object_1__c fmdo;

        Integer i=1;
        if( formItem.sve_SVE_Visualforce_Page__c != null ) {
            for( String page : formItem.sve_SVE_Visualforce_Page__c.split(',') ){
                fmdo = new Form_Meta_Data_Object_1__c(); 
                fmdo.Form_Short_Name__c = formItem.Short_Form_Name__c;
                fmdo.Form_PDF_Name__c = formItem.Short_Form_Name__c + '_' + formItem.Form_Id__c;
                fmdo.Service_Item__c = formItem.Service_Item__c;
                fmdo.Task_Item__c = formItem.Complete_Forms__c;
                fmdo.Form_Item__c = formItem.Id;
                fmdo.Building__c = (Id)formItem.Building_ID__c;
                fmdo.Version__c = -1;
                fmdo.Visualforce_Page__c = page;
                fmdo.Page_Number__c = i++;
                fmdo.Determination_Team_Email__c = DETERMINATION_TEAM_EMAIL;
                metaDataObjects.add( fmdo );
            }
        }
        return metaDataObjects;
    }
    
    public static Form_Meta_Data_Object_1__c getFormMetaDataObject1ById(Id recordId) {
        if (null == recordId) {
            return new Form_Meta_Data_Object_1__c();
        
        }
        
        List<Form_Meta_Data_Object_1__c> formDatObjects = new List<Form_Meta_Data_Object_1__c>([SELECT Building_Address__c, Building_MRC__c, Job_Number__c, Building_Project_No__c, Building_CB_No__c,
                                                                                                       User_Alias__c, CheckBox1__c, Checkbox10__c, Checkbox100__c, Checkbox101__c, Building_Block__c,
                                                                                                       Building_Borough__c, Building_Lot__c, Building_Bin__c, Building_House__c, Building_Street_Name__c,
                                                                                                       input_field1__c, Input_Field124__c, Building_Floor_s__c, Signator_1_Last_Name__c, Signator_1_First_Name__c,
                                                                                                       Input_Field123__c, Signator_1_Business_Name__c, Input_Field_DM1__c, Signator_1_Business_Phone__c,
                                                                                                       Signator_1_Mailing_Street__c, Signator_1_Mailing_State__c, Signator_1_Mailing_City__c, Signator_1_Zip_Code__c,
                                                                                                       Checkbox102__c, Checkbox103__c, Checkbox104__c, Input_Field125__c, Signator_1_License_Number__c, input_field10__c,
                                                                                                       Input_Field104__c, Input_Field109__c, Input_Field113__c, Input_Field118__c, Input_Field100__c, Input_Field105__c,
                                                                                                       input_field11__c, Input_Field114__c, Input_Field119__c, Input_Field101__c, Input_Field106__c, Input_Field110__c,
                                                                                                       Input_Field115__c, input_field12__c, Input_Field102__c, Input_Field108__c, Input_Field111__c, Input_Field116__c,
                                                                                                       Input_Field120__c, Input_Field103__c, Input_Field107__c, Input_Field112__c, Input_Field117__c, Input_Field121__c,
                                                                                                       Signator_1_Full_Name__c, Signator_1_Title__c, Signator_2_Full_Name__c, Signator_2_Title__c, Input_Field122__c,
                                                                                                       Input_Field130__c, Input_Field131__c, Input_Field132__c, Input_Field133__c, Input_Field134__c,
                                                                                                       Service_Item__c, Task_Item__c, Form_Item__c, Version__c, Signator_1_Business_Fax__c, Checkbox108__c,
                                                                                                       Signator_1_Mobile_Phone__c, Signator_1_Email__c, Date_Field_1__c, Checkbox106__c, Checkbox105__c, Checkbox107__c,
                                                                                                       Input_Field_DM10__c, Signator_3_Full_Name__c, Signatory_3__c //MRS-7545
                                                                                                FROM Form_Meta_Data_Object_1__c 
                                                                                                WHERE Id =: recordId]);
                
        if (!formDatObjects.isEmpty()) {
            return formDatObjects.get(0);
    
        }
        return new Form_Meta_Data_Object_1__c();
        
    }

}