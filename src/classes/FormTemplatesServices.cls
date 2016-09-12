public with sharing class FormTemplatesServices {
    public static final String FORM_TYPE_FORM   = 'Form';
    public static final String FORM_TYPE_EMAIL  = 'Email';
    public static final String FORM_TYPE_LETTER = 'Letter';
    
    public static final String FORM_LETTER_TEMPLATE_NAME                  = 'Form Letter';
    public static final String FORM_LETTER_WITH_ATTACHMENTS_TEMPLATE_NAME = 'Form Letter With Attachment';
        
    public static Map<String, Form_Template__c> getFormTemplatesByFormId ( Set<String> formsIds ) {
        Map<String, Form_Template__c> formTemplateMap = new Map<String, Form_Template__c>();
        
        for( Form_Template__c itemForm: [ Select Region__c, Region_Lookup__c, Name, Id, Form_Type__c, Form_ID__c, Form_Name__c, Subject__c, Consumer__c, Municipality__c, Mulit_Part__c, 
                                                 Form_Signatories__c, sve_SVE_Visualforce_Page__c, sve_Meta_Data_Object__c,
                                                 ( Select Id, Meta_Data_Field_Name__c, Milrose_Wave_Field_Name__c From Forms_Field_Mapping__r )
                                          From Form_Template__c Where Form_ID__c IN: formsIds ] ) {
            formTemplateMap.put( itemForm.Form_ID__c, itemForm );
        }
        return formTemplateMap;
    }

    public static String buildQueryWhere(final String refNumberFilter, final String shortNameFilter, final String fullNameFilter, 
                                        final String municipalityFilter, final String regionId, final Boolean isForm, final Boolean isEmail, final Boolean isLetter ) {
        String queryWhere = '';

        if ( !String.isEmpty(refNumberFilter) ) {
            queryWhere = 'WHERE Form_ID__c LIKE \'%' + refNumberFilter + '%\' ';

        }

        if ( !String.isEmpty(shortNameFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Name LIKE \'%'+ shortNameFilter +'%\' ';

        }

        if ( !String.isEmpty(fullNameFilter) ) {
            String stringItem = fullNameFilter.replaceAll('\'', '%');
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Form_Name__c LIKE \'%'+ stringItem +'%\' ';

        }
        
        if ( !String.isEmpty(municipalityFilter) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Municipality__c LIKE \'%'+ municipalityFilter +'%\' ';

        }
        
        if ( !String.isEmpty(regionId) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Region__c LIKE \'%'+ regionId +'%\' ';

        }
        
        if ( isForm != null && isForm ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Form_Type__c = \''+ FORM_TYPE_FORM +'\' ';

        }
        
        if ( isEmail != null && isEmail ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Form_Type__c = \''+ FORM_TYPE_EMAIL +'\' ';

        }
        
        if ( isLetter != null && isLetter ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Form_Type__c = \''+ FORM_TYPE_LETTER +'\' ';

        }
        system.debug('@@@@@@@@ queryWhere= ' + queryWhere);
        return queryWhere;
    }

    public static String buildQuery( String queryWhere ) {

        return  'Select Region__c, Region_Lookup__c, OwnerId, Name, IsDeleted, sve_SVE_Visualforce_Page__c, Letter_Body__c, ' +
                ' Id, Form_Type__c, Form_Name__c, Form_ID__c, CreatedDate, Subject__c, Consumer__c, Municipality__c, Mulit_Part__c, Form_Signatories__c, '+
                '( Select Id, Meta_Data_Field_Name__c, Milrose_Wave_Field_Name__c From Forms_Field_Mapping__r )'+
                ' From Form_Template__c '+ queryWhere  +' ORDER BY Form_Name__c LIMIT 1000';
    }

    public static void attachDDPToFormTemplate ( List<Form_Template__c> formTemplateListNew ){
        Set<String> regions = new Set<String>();
        Map<String, Id> regionToId = new Map<String, Id>();
        Set<String> ddpLeftStartName = new Set<String>();
        Map<String, Id> ddpLeftStartNameToDDPId = new Map<String, Id>();
        String buidQuery = 'Select Name, Id From Loop__DDP__c';
        String queryLike = '';

        for( Form_Template__c itemForm: formTemplateListNew){
            regions.add(itemForm.Region__c);
            ddpLeftStartName.add( itemForm.Name );
        }

        for( Region__c regionItem: [Select Id, Name From Region__c Where Name IN: regions] ){
            regionToId.put( regionItem.Name, regionItem.Id );
        }

        for( String loopItem: ddpLeftStartName ){
            queryLike += String.isBlank(queryLike) ? ' WHERE Name Like ' : ' OR Name Like ';
            queryLike += '\'%'+ loopItem +'%\'';
        }
        if( queryLike != '' ) buidQuery += queryLike;
        System.debug('@buidQuery='+buidQuery);
        System.debug('@Database.Query(buidQuery)='+Database.Query(buidQuery));
        for( Loop__DDP__c itemLoop: Database.Query(buidQuery) ){
            ddpLeftStartNameToDDPId.put( itemLoop.Name, itemLoop.Id );
        }

        for( Form_Template__c itemForm: formTemplateListNew){
            itemForm.Region_Lookup__c = regionToId.get(itemForm.Region__c);
            if( itemForm.Name != null && ddpLeftStartNameToDDPId.get(itemForm.Name) != null ){
                itemForm.PDF_Template__c = ddpLeftStartNameToDDPId.get(itemForm.Name);
            }
        }
    }

    public static List<Form_Template__c> filteredFormTemplateWithChangedName (List<Form_Template__c> formTemplateListNew, Map<Id, Form_Template__c> formTemplateMapOld){
        List<Form_Template__c> resultFormTemplateList = new List<Form_Template__c>();
        for ( Form_Template__c formTemplateItem : formTemplateListNew ){
            if ( formTemplateItem.Name != formTemplateMapOld.get(formTemplateItem.Id).Name &&
                 formTemplateItem.Form_Type__c == FORM_TYPE_FORM &&
                 !String.isEmpty(formTemplateItem.sve_SVE_Visualforce_Page__c) &&
                 formTemplateItem.sve_SVE_Visualforce_Page__c == formTemplateMapOld.get(formTemplateItem.Id).sve_SVE_Visualforce_Page__c ){

                resultFormTemplateList.add( formTemplateItem );
            }
        }

        return resultFormTemplateList;
    }

    public static void updateDDPFilesForFormTemplate (List<Form_Template__c> formTemplateListNew, Map<Id, Form_Template__c> formTemplateMapOld){
        if ( formTemplateListNew == null || formTemplateListNew.isEmpty() ) return;

        Map<Id, Loop__DDP_File__c> loppDDPFileUpdateMap = new Map<Id, Loop__DDP_File__c>();

        Map<String, ApexPage> visualforcePageMap = new Map <String, ApexPage>();
        for (Form_Template__c ft : formTemplateListNew){
            if (ft.sve_SVE_Visualforce_Page__c == null) continue;
            for (String s : ft.sve_SVE_Visualforce_Page__c.split(',')){
                visualforcePageMap.put(s + '_view', null);
            }
        }

        List<Loop__DDP_File__c> loppDDPFileList = [SELECT Id, Name, Loop__Document_ID__c, Loop__Compare_Value__c
                                                   FROM Loop__DDP_File__c
                                                   WHERE Name IN : visualforcePageMap.keySet() AND
                                                        Loop__Compare_Field__c = '<<Form_Meta_Data_Object_1_Form_Short_Name>>' AND
                                                        Loop__Compare_Type__c = 'equals' AND
                                                        Loop__Compare_Value__c != null];

        Map<String, List<Loop__DDP_File__c>> nameWithLoopDDPFileMap = new Map<String, List<Loop__DDP_File__c>>();
        for (Loop__DDP_File__c loopDDPFileItem : loppDDPFileList){
            if (!nameWithLoopDDPFileMap.containsKey(loopDDPFileItem.Name)){
                nameWithLoopDDPFileMap.put(loopDDPFileItem.Name, new List<Loop__DDP_File__c>{loopDDPFileItem});
            } else {
                nameWithLoopDDPFileMap.get(loopDDPFileItem.Name).add(loopDDPFileItem);
            }
        }

        List<ApexPage> apexPageList = [SELECT Id, Name FROM ApexPage WHERE Name IN : visualforcePageMap.keySet() ];

        for (ApexPage apexPageItem : apexPageList){
            visualforcePageMap.put( apexPageItem.Name, apexPageItem );
        }

        for (Form_Template__c ft : formTemplateListNew){
            if (ft.sve_SVE_Visualforce_Page__c == null) continue;
            for (String s : ft.sve_SVE_Visualforce_Page__c.split(',')){
                String apexPageName = s + '_view';
                Form_Template__c formTemplateOld = formTemplateMapOld.get( ft.Id );
                if ( nameWithLoopDDPFileMap.containsKey(apexPageName) ){
                    for ( Loop__DDP_File__c loopDDPFileItem : nameWithLoopDDPFileMap.get(apexPageName) ){
                        if ( loopDDPFileItem.Loop__Compare_Value__c == formTemplateOld.Name ){
                            loppDDPFileUpdateMap.put(loopDDPFileItem.Id, new Loop__DDP_File__c(Id = loopDDPFileItem.Id, Loop__Compare_Value__c = ft.Name) );
                        }
                    }
                }
            }
        }

        try {
            update loppDDPFileUpdateMap.values();
        } catch ( DmlException dmlEx ){
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                String loopDDPFileName = loppDDPFileUpdateMap.values()[dmlEx.getDmlIndex(i)].Name.removeEnd('_view');
                for ( Form_Template__c ft : formTemplateListNew ){
                    if ( ft.sve_SVE_Visualforce_Page__c.contains(loopDDPFileName) ){
                        ft.addError( 'Can not update DDP File ' + dmlEx.getMessage() );
                    }
                }
            }
        }
    }
}