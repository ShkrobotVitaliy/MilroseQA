public with sharing class ServiceItemServices {
    public static final String SERVICE_ITEM_OBJECT_API_NAME = 'Service_Item__c';

    public static final String SERVICE_STATUS_ACTIVE = 'Started';
    public static final String SERVICE_STATUS_INACTIVE = 'Inactive';
    public static final String SERVICE_STATUS_COMPLETED = 'Completed';
    public static final String SERVICE_STATUS_NOTSTARTED = 'Not Started';
    public static final String SERVICE_ISSUANCE_RENEWAL = 'Renewal';
    public static final String SERVICE_ISSUANCE_RENEWABLE_SERVICE = 'Renewable Service';
    public static final String APS_SERVICE = 'APS';
    public static final String OS_SERVICE = 'OS';
    public static final String APS_SERVICE_RECORD_TYPE_NAME = 'Application & Permit Services';
    public static final String OS_SERVICE_RECORD_TYPE_NAME = 'Other Services';

    //Constant for Request Filing Fee
    public static final String RFF_ALTERATION_TYPE_1 = 'Alteration Type 1';
    public static final String RFF_ALTERATION_TYPE_2 = 'Alteration Type 2';
    public static final String RFF_ALTERATION_TYPE_3 = 'Alteration Type 3';

    public static final String RECORD_TYPE_APPLICATION_PERMIT_SERVICES = 'Application_Permit_Services';
    public static final String RECORD_TYPE_OTHER_SERVICES = 'Other_Services';

    public static final String CATEGORY_APPLICATION_FILING      = 'Application Filing';
    public static final String CATEGORY_APPLICATION_REQUIREMENT = 'Application Requirement';
    public static final String CATEGORY_CONSULTING              = 'Consulting';

    public static final String TYPE_PLAN_APPROVAL               = 'Plan Approval';
    public static final String TYPE_SPECIAL_INSPECTION          = 'Special Inspection';
    public static final String TYPE_CERTIFICATE_OF_OPERATION    = 'Certificate of Operation';
    public static final String TYPE_CERTIFICATE_OF_OCCUPANCY    = 'Certificate of Occupancy';
    public static final String TYPE_TEMPORARY_CERTIFICATE_OF_OCCUPANCY    = 'Temporary Certificate of Occupancy';

    public static final String SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION = 'Special Inspection Project Coordination';
    public static final String SERVICE_NAME_SPECIAL_INSPECTION_PROJECT_COORDINATION = 'Consulting for Special Inspection Project Coordination';

    public static final String UNIT_OF_SERVICE_HOUR = 'Hour';
    public static final String UNIT_OF_SERVICE_FILING = 'Filing';

    public static final String SUBTYPE_AHV = 'After Hours Variance';

    //MRS 7062
    public static final String PRIMARY_GROUPING_SIGNOFF_LOC = 'Signoff/LOC';
    public static final String SECONDARY_GROUPING_ALT2_D14 = 'Alt 2 D14';
    public static final String SECONDARY_GROUPING_ALT_3 = 'Alt 3';
    public static final String SECONDARY_GROUPING_D2 = 'D2';
    public static final String SECONDARY_GROUPING_EUP = 'EUP';

	// MRS 7222
	public static final String WT_FIRE_ALARM = 'Fire Alarm';
	public static final String WT_SPRINKLER = 'Sprinkler';
	public static final String WT_STANDPIPE = 'Standpipe';
	public static final String WT_FIRE_SUPPRESSION = 'Fire Suppression';
	public static final String WT_FIRE_PROTECTION_PLAN = 'Fire Protection Plan';
	public static final String WT_SPRINKLER_STANDPIPE = 'Sprinkler Standpipe';

    /*public static String getServiceNumbersToShowShortNameAndWorktype() { //+MRS-6586 //-MRS-7053
      Set<String> affectedServiceNumbers = new Set<String>{ 'APS35', 'APS36', 'APS37', 'APS48', 'APS51', 'APS52', 'APS53', 'APS54', 'APS55', 'APS271', 'APS407' };
      String result = '';
      for( String serviceNumber : affectedServiceNumbers ) {
        result += serviceNumber + ';';
      }
      return result;
    }*/

	public static Boolean isServiceSignOffLS(Service_Item__c si) { // MRS 7266
		if(String.isBlank(si.Work_Type__c)) return true;
		String s = si.Work_Type__c.remove(WT_FIRE_ALARM);
		s = s.remove(WT_SPRINKLER);
		s = s.remove(WT_STANDPIPE);
		s = s.remove(WT_FIRE_SUPPRESSION);
		s = s.remove(WT_FIRE_PROTECTION_PLAN);
		s = s.remove(WT_SPRINKLER_STANDPIPE);
		s = s.remove(';');
		s = s.deleteWhitespace();
		if(s.length() > 0) return false;
		return true;
	}

    public static Boolean preventorUpdateServiceItemOwner = true;
	public static Boolean taskItemOwnerUpdatedFromServiceItemTrigger = false; //MRS 7379

    public static List<Service_Item__c> filterTaxCodeInServiceItemsWasChanged(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap) { //MRS 7096
        List<Service_Item__c> res = new List<Service_Item__c> ();
        for(Service_Item__c si : newList) {
            if(si.Tax_Code_1__c != oldMap.get(si.Id).Tax_Code_1__c || si.Tax_Code_2__c != oldMap.get(si.Id).Tax_Code_2__c) {
                res.add(si);
            } else {
                si.Tax_Percent_1__c = oldMap.get(si.Id).Tax_Percent_1__c;
                si.Tax_Percent_2__c = oldMap.get(si.Id).Tax_Percent_2__c;
            }
        }
        return res;
    }

    // MRS-6939
    public static Set<Id> filteredIdxOfPOsToUpdate(Map<Id, Service_Item__c> newSItems, Map<Id, Service_Item__c> oldSItems) {
        Set<Id> res = new Set<Id> ();

        if(newSItems != null) {
            for(Id idx : newSItems.keySet()) {
                if(( oldSItems == null || oldSItems.get(idx) == null)) {
                    if(newSItems.get(idx).Purchase_Order__c != null) res.add(newSItems.get(idx).Purchase_Order__c);
                    continue;
                }
                if( newSItems.get(idx).Balance_to_Bill__c != oldSItems.get(idx).Balance_to_Bill__c
                    || newSItems.get(idx).Purchase_Order__c != oldSItems.get(idx).Purchase_Order__c) {
                      if (newSItems.get(idx).Purchase_Order__c != null) res.add(newSItems.get(idx).Purchase_Order__c);
                      if (oldSItems.get(idx).Purchase_Order__c != null) res.add(oldSItems.get(idx).Purchase_Order__c);
                    continue;
                }
            }
        }
        if(oldSItems != null) {
            for(Id idx : oldSItems.keySet()) {
                if( newSItems == null || !newSItems.keySet().contains(idx) ) {
                    if( oldSItems.get(idx).Purchase_Order__c != null ) {
                        res.add(oldSItems.get(idx).Purchase_Order__c);
                    }
                }
            }
        }

        return res;
    }

    public static Map<Id, List<Service_Item__c>> getServiceItemsByProposalsIdList( List<Proposal__c> proposals ) { // KDI 11/12/13
        Map<Id, List<Service_Item__c>> proposalIdToServiceItems = new Map<Id, List<Service_Item__c>>();
        if( proposals != null && !proposals.isEmpty() ) {
            for( Service_Item__c si : [ SELECT Proposal__c, Service_Template__r.Service_Row_Number__c,
                                               Service_Template__r.Role_Assignment__c, Municipal_Agency_ID__c
                                          FROM Service_Item__c
                                         WHERE Proposal__c IN : proposals ] ) {
                if( !proposalIdToServiceItems.containsKey( si.Proposal__c ) ) {
                    proposalIdToServiceItems.put( si.Proposal__c, new List<Service_Item__c>() );
                }
                proposalIdToServiceItems.get( si.Proposal__c ).add( si );
            }
        }
        return proposalIdToServiceItems;
    }

    public static List<Service_Item__c> getOriginalServiceItemsByProjectIds(Set<id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return new List<Service_Item__c>();

        }
        return new List<Service_Item__c>([SELECT Service_Group__c, Project_Profile__c, Original__c, Id
                                          FROM Service_Item__c
                                          WHERE Project_Profile__c IN: projectIds AND Original__c =: true]);

    }

    public static Map<Id, Service_Item__c> getServiceItemsWithTaskItemsByProjectId( Id projectId, Set<String> serviceStatuses ) {
         if (null == projectId) {
             return new Map<Id, Service_Item__c>();

         }

         return new Map<Id, Service_Item__c>([SELECT Id, Proposal__c, Service_Template__c, Planned_Start_Date__c, Service_Name_Short__c,
                                                     Total_Planned_Service_Duration__c, Project_Profile__r.Project_Start_Date__c,
                                                     Expected_Start_Date__c, Expected_End_Date__c, Expected_Service_Duration__c,
                                                     Project_Profile__r.Submitted_Planned_Dates__c, Name, Actual_Start_Date__c,
                                                     Successor_Milestone__c, Predecessor_Milestone__c, Planned_End_Date__c,
                                                     Actual_Start_Date_Is_From_Terminator__c, Actual_End_Date__c, Applied_Amendment__c,
                                                     Submitted_CO_Planned_Dates__c, Project_Profile__c,
                                                     Custom_Work_Type_Service__c, /* +MRS-7053 */
                                                     ( SELECT Id, Planned_Durration__c, Name, Predecessor_Milestone__c,
                                                              Sequence_Number__c, Successor_Milestone__c, Predecessor_Task__c,
                                                              Successor_Task__c, Predecessor_Milestone_from_Template__c,
                                                              Successor_Milestone_from_Template__c, Service_Item__c,
                                                              Expected_Duration__c, Expected_End_Date__c, Expected_Start_Date__c,
                                                              Planned_Start_Date__c, Planned_End_Date__c, Delay_End_Date__c,
                                                              Project_Profile__r.Submitted_Planned_Dates__c, Actual_Start_Date__c,
                                                              Actual_End_Date__c, Project_Profile__r.Project_Start_Date__c, Actual_Duration__c
                                                      FROM Task_Items__r Order By Sequence_Number__c )
                                                FROM Service_Item__c
                                                WHERE Project_Profile__c =: projectId AND Is_Alternative__c = false
                                                      AND ( Status__c IN : serviceStatuses )
                                                      AND ( Original__c = true OR
                                                            ( Applied_Amendment__c = true
                                                              AND ( Is_Amendmend_Deleted__c = false OR
                                                                    Change_Order__r.Approved_Date__c = null ) ) ) ]);

    }

    public static Map<Id, Service_Item__c> getServiceItemsMapForAttachServicesToProjectProfiles( Set<Id> proposalIds, Set<Id> changeOrderIds, Set<Id> serviceItemIds, Boolean isAmendment ) {
        Map<Id, Service_Item__c> serviceItemMapOutput = new Map<Id, Service_Item__c>();
        if( proposalIds == null || proposalIds.isEmpty() ) {
            return serviceItemMapOutput;
        }

        String selectQuery = '';
        selectQuery += 'SELECT Id, Name, Proposal__c, Proposal__r.Id, Project_Profile__c, Service_Template__c, Service_Template__r.Role_Assignment__c, Proposal__r.Region__c, Change_Order__c, ';//MRS-7473
        selectQuery += 'Proposal__r.Proposal_Awarded_Date__c, Service_Name_Full__c, Project_Profile__r.Project_Start_Date__c, OwnerId, Service_Group__c, RecordType.Name, ';
        selectQuery += 'Is_Amendmend_Added__c, Service_Template__r.RecordType.Name, Manager_Lookup__c, Unit_of_Service__c, Municipal_Agency_ID__c, Discounted_Unit_Price__c, ';
        selectQuery += 'Service_Level_RFI__c, Category__c, Type__c, Service_Name_Short__c, Name_Short__c, Region__c, X3rd_Party_Issue_Date__c, X3rd_Party_Disapproved_Date__c, X3rd_Party_Description__c, Type_in_Municipal_Agency_Name__c, ';
        selectQuery += 'Project_Profile__r.Account_Executive__c, Met_Data_Scanning_Fee__c, Shredding_Fees__c, ( SELECT Id FROM Task_Items__r ) ';
        selectQuery += 'FROM Service_Item__c ';
        String whereString = '';
        if( serviceItemIds == null ) {
            whereString = ' WHERE Proposal__c IN ' + MilroseDevHelper.flattenListForQuery( new List<Id>( proposalIds ) ) + ' AND Is_Alternative__c = false ';
            whereString += ' AND ( Status__c = \'' + SERVICE_STATUS_NOTSTARTED + '\' OR Status__c = \'' + SERVICE_STATUS_ACTIVE + '\') ';
            if( isAmendment ) {
                whereString += ' AND Applied_Amendment__c = false ';
                whereString += ' AND Original__c = false ';
                whereString += ' AND Is_Amendmend_Added__c = true ';
                whereString += ' AND Change_Order__r.Status__c = \'' + ChangeOrderServices.STATUS_APPROVED + '\'';
                if( changeOrderIds != null ) {
                    whereString += ' AND Change_Order__c IN ' + MilroseDevHelper.flattenListForQuery( new List<Id>( changeOrderIds ) );
                }
            } else {
                whereString += ' AND Original__c = true ';
            }
        } else {
            whereString = ' WHERE Id IN :serviceItemIds';
        }

        if( serviceItemIds == null ) {
            for( Service_Item__c si : Database.query( selectQuery + whereString ) ) {
                if( isAmendment && !si.Task_Items__r.isEmpty() ) {
                    continue;
                } else {
                    serviceItemMapOutput.put( si.Id, si );
                }
            }
        } else {
            serviceItemMapOutput = new Map<Id, Service_Item__c>( (List<Service_Item__c>)Database.query( selectQuery + whereString ) );
        }
        return serviceItemMapOutput;
    }


    public static Map<Id, List<Service_Item__c>> getProjectIdToServiceItemsForChangeOrderRfiScope( Set<Id> serviceItemIds ) {
        Map<Id, List<Service_Item__c>> projectIdToServiceItems = new Map<Id, List<Service_Item__c>>();
        if( serviceItemIds == null || serviceItemIds.isEmpty() ) {
            return projectIdToServiceItems;
        }
        for( Service_Item__c si : [ SELECT Id, Name, Proposal__c, Proposal__r.Id, Project_Profile__c, Service_Template__c,
                                           Service_Template__r.Role_Assignment__c, Proposal__r.Region__c,
                                           Proposal__r.Proposal_Awarded_Date__c, Service_Name_Full__c,
                                           Project_Profile__r.Project_Start_Date__c, OwnerId, Service_Group__c, RecordType.Name,
                                           Is_Amendmend_Added__c, Service_Template__r.RecordType.Name, Manager_Lookup__c,
                                           Unit_of_Service__c, Municipal_Agency_ID__c, Discounted_Unit_Price__c,
                                           Service_Level_RFI__c, Category__c, Type__c, Service_Name_Short__c, Region__c,
                                           X3rd_Party_Issue_Date__c, X3rd_Party_Disapproved_Date__c, X3rd_Party_Description__c, Type_in_Municipal_Agency_Name__c,
                                           Project_Profile__r.Account_Executive__c, Met_Data_Scanning_Fee__c, Shredding_Fees__c,
                                           ( SELECT Id FROM Task_Items__r )
                                    FROM Service_Item__c
                                    WHERE Id IN :serviceItemIds ] ) {
            if ( !projectIdToServiceItems.containsKey( si.Project_Profile__c ) ) {
                projectIdToServiceItems.put( si.Project_Profile__c, new List<Service_Item__c>() );
            }
            projectIdToServiceItems.get( si.Project_Profile__c ).add( si );
        }
        return projectIdToServiceItems;
    }

    public static Map<Id, Service_Item__c> getAmendmentServiceItemByProposalIds(Set<Id> proposalIds, List<Change_Order__c> changeOrders) {
        return new Map<Id, Service_Item__c> ([SELECT Id, Name, Proposal__c, Proposal__r.Id, Project_Profile__c, Service_Template__c, Service_Template__r.Role_Assignment__c,
                                                  Proposal__r.Proposal_Awarded_Date__c, Service_Name_Full__c, Project_Profile__r.Project_Start_Date__c, OwnerId, Service_Group__c,
                                                  Is_Amendmend_Added__c, Service_Template__r.RecordType.Name, Manager_Lookup__c, Unit_of_Service__c, Municipal_Agency_ID__c,
                                                  Service_Level_RFI__c, Category__c, Type__c, Service_Name_Short__c,
                                                  (SELECT Id FROM Task_Items__r )
                                              FROM Service_Item__c
                                              WHERE Proposal__c IN : proposalIds
                                              AND Applied_Amendment__c = false
                                              AND Is_Alternative__c = false
                                              AND Original__c = false
                                              AND Is_Amendmend_Added__c = true
                                              AND Change_Order__c IN : changeOrders
                                              AND Change_Order__r.Status__c =: ChangeOrderServices.STATUS_APPROVED ]);

    }

    public static Map<Id, Service_Item__c> getOriginalServiceItemByProposalIds(Set<Id> proposalIds) {
        if (null == proposalIds || proposalIds.isEmpty()) {
            return new Map<Id, Service_Item__c>();

        }

        return new Map<Id, Service_Item__c> ([SELECT Id, Name, Proposal__c, Proposal__r.Id, Project_Profile__c, Service_Template__c, Service_Template__r.Role_Assignment__c,
                                                     Proposal__r.Proposal_Awarded_Date__c, Service_Name_Full__c, Project_Profile__r.Project_Start_Date__c, OwnerId, Service_Name_Short__c,
                                                     Service_Template__r.RecordType.Name, Manager_Lookup__c, Unit_of_Service__c, Municipal_Agency_ID__c, Service_Group__c
                                              FROM Service_Item__c
                                              WHERE Proposal__c IN : proposalIds
                                              AND Project_Profile__c = null
                                              AND Original__c = true
                                              AND Is_Alternative__c = false]);

    }

    public static Set<Id> getServiceItemIdsByProjectId(Id projectId) {
        if (null == projectId) {
            throw new ErrorException('Parameter project Id cannot be empty!');

        }

        return (new Map<Id, Service_Item__c>([SELECT Id FROM Service_Item__c WHERE Project_Profile__c =: projectId])).keySet();

    }

    public static map<Id, Service_Item__c> getServiceItemMap(set<Id> serviceItemIds) {
        return new map<Id, Service_Item__c>( [ SELECT Id, Name, Quantity__c, Total_Service_Price__c, Service_Name_Short__c,
                                                      Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c,
                                                      Work_Type__c, Proposal__c, Purchase_Order__c, Met_Data_BLI_Created__c,
                                                      Discount_Percentage__c, Met_Data_Scanning_Fee__c
                                               FROM Service_Item__c
                                               WHERE Id IN : serviceItemIds ] );
    }

    public static map<Id, Service_Item__c> getPhaseIdServiceItemMap(set<Id> phaseIds) {
        map<Id, Service_Item__c> phaseIdServiceItemMap = new map<Id, Service_Item__c>();
        for(Service_Item__c serviceItem : [ SELECT Id, Name, Quantity__c, Total_Service_Price__c,
                                                      Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c,
                                                      Work_Type__c, Proposal__c, Purchase_Order__c,
                                                      Discount_Percentage__c, Service_Name_Short__c
                                               FROM Service_Item__c
                                               WHERE Phase__c IN : phaseIds ]) {
            phaseIdServiceItemMap.put(serviceItem.Phase__c, serviceItem);
        }

        return phaseIdServiceItemMap;
    }

    public static Map<Id, Service_Item__c> getServiceItemsByProjectsId (set<Id> projectIds) {
        return new Map<Id, Service_Item__c>([ SELECT Id, Name, Quantity__c, Total_Service_Price__c, GLA_Product__c, GLA_Product__r.Name, Status__c,
                                                Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c, Discounted_Unit_Price__c,
                                                Work_Type__c, Proposal__c, Purchase_Order__c, Met_Data_BLI_Created__c, Doc_Shredding_BLI_Created__c,
                                                Discount_Percentage__c, Met_Data_Scanning_Fee__c, Service_Name_Short__c,
                                                Tax_Percent_1__c, Tax_Percent_2__c
                                         FROM Service_Item__c
                                         WHERE Project_Profile__c IN: projectIds]);
    }

    public static List<Service_Item__c> filterServiceItemTax(List<Service_Item__c> newServiceItemList ) {
        List<Service_Item__c> filteredServiceItemList = new List<Service_Item__c>();
        for(Service_Item__c sd : newServiceItemList) {
            if( sd.Tax_Code_1__c != null || sd.Tax_Code_2__c != null ) {
                filteredServiceItemList.add( sd );
            }
        }
        return filteredServiceItemList;
    }

    public static void serviceItemTaxCode( List<Service_Item__c> comingServiceItems, Boolean isUpdate ) {
        if( comingServiceItems.isEmpty() ) return;
        Set<Id> taxCodeIdSet = new Set<Id>();

        for( Service_Item__c si : comingServiceItems ) {
            if(si.Tax_Code_1__c != null) taxCodeIdSet.add(si.Tax_Code_1__c);
            if(si.Tax_Code_2__c != null) taxCodeIdSet.add(si.Tax_Code_2__c);
        }
        updateServiceItemTaxCode(comingServiceItems, taxCodeIdSet, isUpdate );
    }

    public static void updateServiceItemTaxCode(List<Service_Item__c> comingServiceItems, Set<Id> taxCodeIdSet, Boolean isUpdate) {
        if( comingServiceItems.isEmpty() ) return;
        List<c2g__codaTaxRate__c> taxRateList = [ Select c2g__TaxCode__c, c2g__StartDate__c, c2g__Rate__c, Id
                                                  From c2g__codaTaxRate__c
                                                  WHERE c2g__StartDate__c <= :Date.today()
                                                  AND c2g__TaxCode__c IN : taxCodeIdSet
                                                  Order By c2g__StartDate__c desc ];

        for( Service_Item__c usi: comingServiceItems ) {
            Boolean taxCode1Found = false;
            Boolean taxCode2Found = false;
            if( String.isBlank( usi.Tax_Code_1__c ) ) {
                usi.Tax_Value_1__c = null;
                usi.Tax_Percent_1__c = null;
            }
            if( String.isBlank( usi.Tax_Code_2__c ) ) {
                usi.Tax_Value_2__c = null;
                usi.Tax_Percent_2__c = null;
            }
            for( c2g__codaTaxRate__c taxRate : taxRateList ) {
               if( usi.Total_Service_Price__c != null ) {
                   if( !taxCode1Found && taxRate.c2g__TaxCode__c == usi.Tax_Code_1__c) {
                       usi.Tax_Value_1__c = taxRate.c2g__Rate__c/100*usi.Total_Service_Price__c;
                       usi.Tax_Percent_1__c = taxRate.c2g__Rate__c;
                       taxCode1Found = true;
                   }
                   if( !taxCode2Found && taxRate.c2g__TaxCode__c == usi.Tax_Code_2__c) {
                       usi.Tax_Value_2__c = taxRate.c2g__Rate__c/100*usi.Total_Service_Price__c;
                       usi.Tax_Percent_2__c = taxRate.c2g__Rate__c;
                       taxCode2Found = true;
                   }
                   if( taxCode1Found && taxCode2Found ) break;
               }
            }
        }
        if(isUpdate) {
            system.debug('comingServiceItems: ' + comingServiceItems);
            try{
                update comingServiceItems;
            } catch (DMLException dmlEx){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    Service_Item__c serviceItem = comingServiceItems[dmlEx.getDmlIndex(i)];
                    for (Service_Item__c sI : comingServiceItems){
                        if (sI.Id == serviceItem.Id){
                            serviceItem.addError('Can not update Service Item.' + dmlEx.getMessage());
                        }
                    }
                }
            }
        }
    }

    //Filter for Service Items there Predecessor Milestone or Successor Milestone has been changed
    public static Map<Id, Service_Item__c> filterServiceItemWithChangedMilestones(List<Service_Item__c> serviceItemListNew, Map<Id, Service_Item__c> serviceItemMapOld){
        Map<Id, Service_Item__c> filteredServiceItemMap = new Map<Id, Service_Item__c>();
        for (Service_Item__c serviceItem : serviceItemListNew){
            if ((serviceItem.Predecessor_Milestone__c != serviceItemMapOld.get(serviceItem.Id).Predecessor_Milestone__c) ||
                (serviceItem.Successor_Milestone__c != serviceItemMapOld.get(serviceItem.Id).Successor_Milestone__c)){
                filteredServiceItemMap.put(serviceItem.Id, serviceItem);
            }
        }
        return filteredServiceItemMap;
    }

    public static void updatePredecessorSuccessorTaskItem( Map<Id, Service_Item__c> serviceItemMapNew, Map<Id, Service_Item__c> serviceItemMapOld ) {
       if (serviceItemMapNew.isEmpty())
            return;

        //Project with all Milestone Task Items
        Map<Id, Map<String, Task_Item__c>> projectIdMilestoneTaskItem = new Map<Id, Map<String, Task_Item__c>>();
        Set<String> milestoneTaskItemName = new Set<String>();
        Set<Id> serviceWithChangedPredecessorSetId = new Set<Id>();
        Set<Id> serviceWithChangedSuccessorSetId = new Set<Id>();

        for( Service_Item__c serviceItem : serviceItemMapNew.values() ) {
            if (!projectIdMilestoneTaskItem.containsKey(serviceItem.Project_Profile__c)) {
                projectIdMilestoneTaskItem.put(serviceItem.Project_Profile__c, new Map<String, Task_Item__c>());
            }
            if( serviceItem.Predecessor_Milestone__c != serviceItemMapOld.get(serviceItem.Id).Predecessor_Milestone__c &&
                serviceItem.Predecessor_Milestone__c != null ) {
                milestoneTaskItemName.add( serviceItem.Predecessor_Milestone__c );
                serviceWithChangedPredecessorSetId.add(serviceItem.Id);
            }
            if( serviceItem.Successor_Milestone__c != serviceItemMapOld.get(serviceItem.Id).Successor_Milestone__c &&
                serviceItem.Successor_Milestone__c != null) {
                milestoneTaskItemName.add( serviceItem.Successor_Milestone__c );
                serviceWithChangedSuccessorSetId.add(serviceItem.Id);
            }
        }

        Map<Id, Task_Item__c> taskItemUpdateMap = new Map<Id, Task_Item__c>();

        List<Task_Item__c> tasksToUpdate = new List<Task_Item__c>();
        for (Task_Item__c taskItem : [SELECT Id, Name, Project_Profile__c, Service_Item__c, RecordTypeId, RecordType.Name, Sequence_Number__c,
                                                                                Predecessor_Milestone__c, Successor_Milestone__c, Service_Item__r.Predecessor_Milestone__c,
                                                                                Service_Item__r.Successor_Milestone__c
                                      FROM Task_Item__c
                                      WHERE Project_Profile__c IN :projectIdMilestoneTaskItem.keySet() AND
                                          ( ( RecordType.Name =: TaskManagementServices.MILESTONE_RECORDTYPE_NAME AND Name IN : milestoneTaskItemName )
                                              OR ( (Service_Item__c IN: serviceWithChangedPredecessorSetId AND Predecessor_Milestone__c != null) OR
                                                   (Service_Item__c IN: serviceWithChangedSuccessorSetId AND Successor_Milestone__c != null )
                                          ) ) ] ) {
            if ( taskItem.RecordType.Name == TaskManagementServices.MILESTONE_RECORDTYPE_NAME ) {
                projectIdMilestoneTaskItem.get(taskItem.Project_Profile__c).put(taskItem.Name, taskItem);
            } else {
                tasksToUpdate.add( taskItem );
            }
        }
        for ( Task_Item__c taskItem : tasksToUpdate ){
            if( taskItem.Predecessor_Milestone__c != null ) {
                if( projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).containsKey( taskItem.Service_Item__r.Predecessor_Milestone__c ) ) {
                    if ( taskItem.Predecessor_Milestone__c != projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Predecessor_Milestone__c ).Id ){
                        taskItem.Predecessor_Milestone__c = projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Predecessor_Milestone__c ).Id;
                        taskItemUpdateMap.put(taskItem.Id, taskItem);
                    }
                }
            }
            if( taskItem.Successor_Milestone__c != null ) {
                if( projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).containsKey( taskItem.Service_Item__r.Successor_Milestone__c ) ) {
                    if ( taskItem.Successor_Milestone__c != projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Successor_Milestone__c ).Id ){
                        taskItem.Successor_Milestone__c = projectIdMilestoneTaskItem.get( taskItem.Project_Profile__c ).get( taskItem.Service_Item__r.Successor_Milestone__c ).Id;
                        taskItemUpdateMap.put(taskItem.Id, taskItem);
                    }
                }
            }
        }
        System.debug(LoggingLevel.Error,'taskItemUpdateMap' + taskItemUpdateMap);
        if ( !taskItemUpdateMap.isEmpty() ){
            try{
                update taskItemUpdateMap.values();
            } catch (DMLException dmlEx){
                for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                    Task_Item__c taskItem = taskItemUpdateMap.values()[dmlEx.getDmlIndex(i)];
                    for (Service_Item__c serviceItem : serviceItemMapNew.values()){
                        if (serviceItem.Id == taskItem.Service_Item__c){
                            serviceItem.addError('Can not update Task Item.' + dmlEx.getMessage());
                        }
                    }
                }
            }
        }
    }

    //MRS-7530
    public static Service_Item__c createNewServiceItemFromTemplate (Service_Template__c serviceTemplate ){
        Service_Item__c si = new Service_Item__c();
        populateServiceItemFromServiceTemplateFields(serviceTemplate, si, false);

        if(!String.isBlank(si.Work_Type__c) )  {
            si.Service_Name_Full__c += ' ' + si.Work_Type__c.replace(';', ' ');
        }

        return si;
    }

    public static void populateServiceItemFromServiceTemplateFields(Service_Template__c serviceTemplate, Service_Item__c serviceItem, Boolean isFromWizard){
        if ( serviceTemplate == null || serviceItem == null ){return;}

        serviceItem.Forms__c                 = serviceTemplate.Forms__c;
        serviceItem.External_Forms__c        = serviceTemplate.External_Forms__c;
        serviceItem.Service_Level_RFI__c     = serviceTemplate.Service_Level_RFI__c;
        serviceItem.Project_Level_RFI__c     = serviceTemplate.Project_Level_RFI__c;
        serviceItem.Shredding_Fees__c        = serviceTemplate.Shredding_Fees__c;
        serviceItem.Met_Data_Scanning_Fee__c = serviceTemplate.Met_Data_Scanning_Fee__c;
        serviceItem.Filing_Status__c         = serviceTemplate.Filing_Status__c;
        serviceItem.Region__c                = serviceTemplate.Region__c;

        serviceItem.Role_Assignment__c       = serviceTemplate.Role_Assignment__c;
        serviceItem.Work_Performed__c        = serviceTemplate.Work_Performed__c;
        serviceItem.Service_Template__c      = serviceTemplate.id;
        serviceItem.Service_Name_Full__c     = serviceTemplate.Service_Name_Full__c;
        serviceItem.Service_Name_Short__c    = serviceTemplate.Short_Service_Name__c;
        serviceItem.Category__c              = serviceTemplate.Category__c;
        serviceItem.Subtype__c               = serviceTemplate.Subtype__c;
        serviceItem.Plan_Submission_Type__c  = serviceTemplate.Plan_Submission_Type__c;
        serviceItem.Type__c                  = serviceTemplate.Type__c;
        serviceItem.Unit_of_Service__c       = serviceTemplate.Unit_of_Service__c;
        serviceItem.Department__c            = serviceTemplate.Department__c;
        serviceItem.Work_Type__c             = serviceTemplate.Work_Type__c;
        serviceItem.Issuance__c              = serviceTemplate.Issuance__c;
        serviceItem.Description__c           = serviceTemplate.Description__c;
        serviceItem.GLA_Product__c           = serviceTemplate.GLA_Product__c;
        serviceItem.Abbreviation__c          = serviceTemplate.Abbreviation__c;

        if (!isFromWizard){
            serviceItem.Quantity__c          = serviceTemplate.Quantity__c;

            serviceItem.Tax_Code_1__c        = serviceTemplate.Tax_Code_1__c;
            serviceItem.Tax_Code_2__c        = serviceTemplate.Tax_Code_2__c;
            serviceItem.Unit_Price__c        = serviceTemplate.Medium_Price__c;
        }
    }

    public static List<Service_Template__c> getServiceTemplateForServiceItem( List<Id> serviceIds, String issuance ){
      if ( ( serviceIds == null || serviceIds.isEmpty() ) && String.isEmpty( issuance ) ){ return new List<Service_Template__c>(); }

        String queryString = 'SELECT Id, Service_Name_Full__c, Name, Description__c, Region__c, Category__c, Type__c, Subtype__c, ' +
                             '        Medium_Price__c, Unit_of_Service__c, Department__c, Work_Type__c, Issuance__c, Tax_Code_1__c, Tax_Code_2__c, ' +
                             '        GLA_Product__c, Role_Assignment__c, Abbreviation__c, Work_Performed__c, Plan_Submission_Type__c, Shredding_Fees__c, ' +
                             '        Met_Data_Scanning_Fee__c, Service_Level_RFI__c, Project_Level_RFI__c, Forms__c, External_Forms__c, Filing_Status__c, ' +
                             '        Short_Service_Name__c, RecordTypeId, Quantity__c, Low_Price__c, High_Price__c ' +
                             'FROM Service_Template__c ' +
                             'WHERE ';

        if( serviceIds != null && !serviceIds.isEmpty() ){
            queryString += 'Id IN (\'' + String.join(serviceIds, '\',\'') + '\')';
        } else {
            queryString += 'Issuance__c = \'' + issuance + '\'';
        }

        return Database.query( queryString );
    }

    public static List<Service_Item__c> filteredServiceItemsForFormsCreation( List<Service_Item__c> serviceItemListNew ){
        List<Service_Item__c> filteredServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItem : serviceItemListNew){
            if ( serviceItem.Forms__c != null ){
                filteredServiceItemList.add(serviceItem);
            }
        }
        return filteredServiceItemList;
    }

    public static Map<Id, Service_Item__c> getServiceItemsByProjectId(Id projectId) {
        if (String.isBlank(projectId)) {
            throw new ErrorException('Parameter project id cannot be empty!');

        }
        return new Map<Id, Service_Item__c> ([SELECT Id, Name, Project_Profile__c, Total_Service_Price__c, Service_Name_Full__c,
                                                    Service_Group__c, Category__c, Type__c, Service_Name_Short__c
                                              FROM Service_Item__c
                                              WHERE Project_Profile__c = : projectId
                                              	AND Status__c !=: SERVICE_STATUS_INACTIVE]);

    }

    public static Map<Id, Service_Item__c> getServiceItemsWithTaskItemsByProjectId(Id projectId) {
        if (String.isBlank(projectId)) {
            throw new ErrorException('Parameter project id cannot be empty!');

        }
        return new Map<Id, Service_Item__c>( [ SELECT Id, Name, Project_Profile__c, Total_Service_Price__c, Service_Name_Full__c,
                                                      Service_Group__c, Category__c, Type__c, Service_Name_Short__c,
                                                      Region__c, Service_Template_Row__c, Short_Service_Name_Worktype__c,
                                                      Custom_Work_Type_Service__c, /* +MRS 7053 */
                                                      ( SELECT Id, Name, Billing_Trigger__c, Billing_Percentage__c, Service_Item__c, Is_Locked__c, Service_Item__r.Total_Service_Price__c
                                                        FROM Task_Items__r
                                                        ORDER BY Sequence_Number__c ASC )
                                              FROM Service_Item__c
                                              WHERE Project_Profile__c = : projectId ] );

    }

    public static Service_Item__c getServiceItemById(Id serviceItemId) {
        if (String.isBlank(serviceItemId)) {
            throw new ErrorException('Parameter service item id cannot be empty!');

        }

        List<Service_Item__c> serviceItems = new List<Service_Item__c>([SELECT Id, Name, Quantity__c, Total_Service_Price__c, Floor__c, Email_To_Form__c, Project_Profile__c,
                                                                               Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c, Email_Cc_Form__c, Status__c,
                                                                               Work_Type__c, Proposal__c, Purchase_Order__c, Met_Data_BLI_Created__c, Change_Order__c,
                                                                               Discount_Percentage__c, Met_Data_Scanning_Fee__c, Service_Name_Short__c, Project_Profile__r.Building__c,
                                                                               (SELECT Id FROM Task_Items__r)
                                                                       FROM Service_Item__c
                                                                       WHERE Id =: serviceItemId]);

        if (null == serviceItems || serviceItems.isEmpty()) {
            throw new ErrorException('Service Item does not exist!');

        }
        return serviceItems.get(0);

    }

	public static void preventChangingOwnerOnCopletedServices(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap) { //MRS 7379 7578
		if(ProposalWizardServices.getProfileNameById(UserInfo.getProfileId()) != UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN) {
			for(Service_Item__c si : newList) {
				if(si.OwnerId != oldMap.get(si.Id).OwnerId && si.Status__c == 'Completed' && oldMap.get(si.Id).Status__c == 'Completed') {
					si.OwnerId = oldMap.get(si.Id).OwnerId;
					si.addError('You can not change Owner once Service is completed.');
				}
			}
		}
	}

    public static Map<Id, Service_Item__c> filteredServiceItemWithChangedOwner(List<Service_Item__c> serviceItemListNew, Map<Id, Service_Item__c> serviceItemMapOld){
        Map<Id, Service_Item__c> filteredServiceItemMap = new Map<Id, Service_Item__c>();
        for (Service_Item__c serviceItemItem : serviceItemListNew){
            if ( serviceItemItem.Project_Profile__c != null && serviceItemItem.OwnerId != serviceItemMapOld.get(serviceItemItem.Id).OwnerId ) {
                filteredServiceItemMap.put(serviceItemItem.Id, serviceItemItem);
            }
        }
        return filteredServiceItemMap;
    }

    public static void updateTaskItemOwner(Map<Id, Service_Item__c> serviceItemMapNew, Map<Id, Service_Item__c> serviceItemMapOld){
        if ( serviceItemMapNew.isEmpty() ) return;

        Map<Id, Map <String, Map<Id, Project_Roster__c>>> projectIdToProjectRosterMap = new Map<Id, Map<String, Map<Id, Project_Roster__c>>>();
        Map<Id, String> userIdToRoleName = UserServices.getUserIdToRoleName();

        List<Service_Item__c> serviceItemOtherServicesList = [SELECT Id, Service_Template__r.RecordType.Name, OwnerId, Project_Profile__c,
                                                                     Service_Template__r.Role_Assignment__c, Proposal__c,
                                                                     Project_Profile__r.Project_Manager__c, Project_Profile__r.Project_Member__c,
                                                                     Project_Profile__r.FREP__c, Project_Profile__r.Production_Manager__c,
                                                                    ( Select Id, OwnerId, Resources__c, Service_Item__c
                                                                      From Task_Items__r
                                                                      Where RecordType.Name != : TaskManagementServices.MILESTONE_RECORDTYPE_NAME )
                                                              FROM Service_Item__c
                                                              WHERE Id IN : serviceItemMapNew.keySet() limit 50000];

        if( serviceItemOtherServicesList.isEmpty() ) return;

        List<Task_Item__c> taskItemUpdateList = new List<Task_Item__c>();
        for (Service_Item__c serviceItemItem : serviceItemOtherServicesList){
            for (Task_Item__c taskItemItem : serviceItemItem.Task_Items__r){
                if (taskItemItem.OwnerId != serviceItemItem.OwnerId) {
                    taskItemItem.OwnerId = serviceItemItem.OwnerId;
                    taskItemUpdateList.add(taskItemItem);
                }
            }
            String userRoleItem = userIdToRoleName.get(serviceItemItem.OwnerId);
            if (!projectIdToProjectRosterMap.containsKey(serviceItemItem.Project_Profile__c)){
                projectIdToProjectRosterMap.put(serviceItemItem.Project_Profile__c, new Map<String, Map<Id, Project_Roster__c>>());
            }
            if (!projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).containsKey(userRoleItem)){
                projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).put(userRoleItem, new Map<Id, Project_Roster__c>());
            }
            if (!projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).get(userRoleItem).containsKey(serviceItemItem.OwnerId)){
                projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).get(userRoleItem).put(serviceItemItem.OwnerId, null);
            }
        }

        List<Project_Roster__c> projRosters = ProjectRosterServices.getProjectRosterByProjectProfileIds( projectIdToProjectRosterMap.keySet() );

        for( Project_Roster__c prRost : projRosters ){
            if ( projectIdToProjectRosterMap.get(prRost.Project_Profile__c).containsKey(prRost.Role__c) &&
                 projectIdToProjectRosterMap.get(prRost.Project_Profile__c).get(prRost.Role__c).containsKey(prRost.User__c) &&
                 projectIdToProjectRosterMap.get(prRost.Project_Profile__c).get(prRost.Role__c).get(prRost.User__c) == null ){
                projectIdToProjectRosterMap.get(prRost.Project_Profile__c).get(prRost.Role__c).put(prRost.User__c, prRost);
            }
        }

        Id userProjectRosterRecordTypeId;

        for (Schema.RecordTypeInfo schemaRecordTypeInfoItem : Project_Roster__c.SObjectType.getDescribe().getRecordTypeInfos()){
            if (schemaRecordTypeInfoItem.getName() == ProjectRosterServices.TYPE_USER) {
                userProjectRosterRecordTypeId = schemaRecordTypeInfoItem.getRecordTypeId();
                break;
            }
        }

        List<Project_Roster__c> projRostersAll = new List<Project_Roster__c>();
        Map<Id, Project_Roster__c> projectRosterUpdateMap = new Map<Id, Project_Roster__c>();

        for ( Service_Item__c serviceItemItem : serviceItemOtherServicesList ) {
            if ( serviceItemItem.OwnerId == serviceItemItem.Project_Profile__r.Project_Manager__c || serviceItemItem.OwnerId == serviceItemItem.Project_Profile__r.Project_Member__c ||
                 serviceItemItem.OwnerId == serviceItemItem.Project_Profile__r.FREP__c || serviceItemItem.OwnerId == serviceItemItem.Project_Profile__r.Production_Manager__c ){
                continue;
            }
            String serviceItemOwnerRoleName =  userIdToRoleName.get(serviceItemItem.OwnerId);
            Project_Roster__c projectRosterItem = projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).get(serviceItemOwnerRoleName).get(serviceItemItem.OwnerId);

            if (projectRosterItem == null || serviceItemItem.OwnerId != projectRosterItem.User__c || serviceItemOwnerRoleName != projectRosterItem.Role__c){
                projectRosterItem = ProjectProfileServices.createAfterAssignProjectRoster( serviceItemItem.OwnerId,
                                                                                           serviceItemItem.Project_Profile__c,
                                                                                           serviceItemItem.Proposal__c,
                                                                                           userProjectRosterRecordTypeId,
                                                                                           serviceItemOwnerRoleName,
                                                                                           projectRosterItem );
                projectIdToProjectRosterMap.get(serviceItemItem.Project_Profile__c).get(serviceItemOwnerRoleName).put(serviceItemItem.OwnerId, projectRosterItem);
                if (projectRosterItem.Id == null) { projRostersAll.add( projectRosterItem ); } else { projectRosterUpdateMap.put(projectRosterItem.Id, projectRosterItem); }
            }
        }

        projRostersAll.addAll(projectRosterUpdateMap.values());

        ProjectProfileServices.preventToUpdateProjectAssignment = false;
        upsert projRostersAll;
        ProjectProfileServices.preventToUpdateProjectAssignment = true;

        if( taskItemUpdateList.isEmpty() ) return;

        try {
            update taskItemUpdateList;
        } catch (DMLException dmlEx) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                serviceItemMapNew.get(taskItemUpdateList[dmlEx.getDmlIndex(i)].Service_Item__c).addError('Can not update Task Item Owner: ' + dmlEx.getMessage());
            }
        }

        List<Id> projectListId = new List<Id>();
        projectListId.addAll(projectIdToProjectRosterMap.keySet());
        ProjectRosterServices.updateRostersIsActiveState(projectListId, null, true, true, false, true);
    }

    public static Map<Id, Service_Item__c> filterServiceItemsWithChangedMunicipalAgency( List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap ) {
        Map<Id, Service_Item__c> filteredServiceItems = new Map<Id, Service_Item__c>();
        if( newList != null && oldMap != null ) {
            for( Service_Item__c si : newList ) {
                if( si.Municipal_Agency_ID__c != oldMap.get( si.Id ).Municipal_Agency_ID__c ||
                    si.X3rd_Party_Issue_Date__c != oldMap.get( si.Id ).X3rd_Party_Issue_Date__c ||
                    si.X3rd_Party_Disapproved_Date__c != oldMap.get( si.Id ).X3rd_Party_Disapproved_Date__c ||
                    si.X3rd_Party_Description__c != oldMap.get( si.Id ).X3rd_Party_Description__c ||
                    si.Type_in_Municipal_Agency_Name__c != oldMap.get( si.Id ).Type_in_Municipal_Agency_Name__c) {
                    filteredServiceItems.put( si.Id, si );
                }
            }
        }
        return filteredServiceItems;
    }

    public static void updateMunicipalAgencyOnTaskItems( Map<Id, Service_Item__c> serviceItems ) {
        if( serviceItems.isEmpty() ) return;

        List<Task_Item__c> taskItemsToUpdate = [ SELECT Id, Service_Item__c, X3rd_Party_Authority_ID__c, X3rd_Party_Issue_Date__c, X3rd_Party_Disapproved_Date__c, X3rd_Party_Description__c, Type_in_Municipal_Agency_Name__c FROM Task_Item__c WHERE Service_Item__c IN : serviceItems.values() ];
        for( Task_Item__c ti : taskItemsToUpdate ) {
            ti.X3rd_Party_Authority_ID__c = serviceItems.get( ti.Service_Item__c ).Municipal_Agency_ID__c;
            ti.X3rd_Party_Issue_Date__c = serviceItems.get( ti.Service_Item__c ).X3rd_Party_Issue_Date__c;
            ti.X3rd_Party_Disapproved_Date__c = serviceItems.get( ti.Service_Item__c ).X3rd_Party_Disapproved_Date__c;
            ti.X3rd_Party_Description__c = serviceItems.get( ti.Service_Item__c ).X3rd_Party_Description__c;
            ti.Type_in_Municipal_Agency_Name__c = serviceItems.get( ti.Service_Item__c ).Type_in_Municipal_Agency_Name__c;
        }
        try {
            UPDATE taskItemsToUpdate;
        } catch( DMLException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                serviceItems.get( taskItemsToUpdate[dmlEx.getDmlIndex(i)].Service_Item__c ).addError( 'Can not update Municipal Agency: ' + dmlEx.getMessage() );
            }
        }
    }

    public static void updateMunicipalAgencyOnServiceItems( Map<Id, String> proposalIdToMunicipalityIdMap ) {
        List<Proposal__c> proposals = new List<Proposal__c>();
        for( Id proposalId : proposalIdToMunicipalityIdMap.keySet() ) {
            proposals.add( new Proposal__c(Id = proposalId));
        }
        Map<Id, List<Service_Item__c>> proposalToServicesMap = getServiceItemsByProposalsIdList(proposals);
        List<Service_Item__c> servicesToUpdate = new List<Service_Item__c>();
        for( Id proposalId : proposalToServicesMap.keySet() ) {
            for( Service_Item__c serviceItem: proposalToServicesMap.get(proposalId)){
                servicesToUpdate.add( new Service_Item__c( Id = serviceItem.Id, Municipal_Agency_ID__c = proposalIdToMunicipalityIdMap.get(proposalId) ) );
            }
        }
        try {
            UPDATE servicesToUpdate;
        } catch( DMLException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                servicesToUpdate[i].addError( 'Can not update Municipal Agency: ' + dmlEx.getMessage() );
            }
        }
    }

    public static List<Service_Item__c> filterShreddingFeesOnServiceItem (Map<Id, Service_Template__c> serviceTemplateNewMap,  Map<Id, Service_Template__c> serviceTemplateOldMap) {
        Set<Id> serviceTemplateIds = new Set<Id>();
        if(serviceTemplateOldMap != null) {
            for(Id stId : serviceTemplateNewMap.keySet()) {
                if(!serviceTemplateOldMap.containsKey(stId) || serviceTemplateOldMap.get(stId).Shredding_Fees__c != serviceTemplateNewMap.get(stId).Shredding_Fees__c) {
                    serviceTemplateIds.add(stId);
                }
            }
        } else {
            serviceTemplateIds.addAll(serviceTemplateNewMap.keySet());
        }
        List<Service_Item__c> serviceItems = [Select Shredding_Fees__c, Service_Template__c, Id From Service_Item__c Where Service_Template__c IN : serviceTemplateIds];
        return serviceItems;
    }

    public static void updateShreddingFeesOnServiceItem(List<Service_Item__c> serviceItemsToUpdate, Map<Id, Service_Template__c> serviceTemplateNewMap) {
        for(Service_Item__c si : serviceItemsToUpdate) {
            si.Shredding_Fees__c = serviceTemplateNewMap.get(si.Service_Template__c).Shredding_Fees__c;
        }
        try {
            UPDATE serviceItemsToUpdate;
         } catch( DMLException dmlEx ) {
            for ( Integer i = 0; i < dmlEx.getNumDml(); i++){
                serviceTemplateNewMap.get( serviceItemsToUpdate[dmlEx.getDmlIndex(i)].Service_Template__c ).addError( 'Can not update Shredding Fees: ' + dmlEx.getMessage() );
            }
        }
    }

    /* Filters for Scanning and Shredding Reimbursable BLI ---------------------------------------------------------------------------------------------------------------------- */
     public static List<Service_Item__c> getServiceItemsToCreateScanninReimbursableBLI(Project_Profile__c projectProfile, List<Service_Item__c> servicesRelatedToProject, Map<Id, Service_Item__c> updatedServices, List<Task_Item__c> tasksRelatedToProject) {
        if (null == updatedServices) {
            updatedServices = new Map<Id, Service_Item__c>();

        }
		Set<Id> affectedSiSet = new Set<Id>(); /*MRS 5798*/
		if(null != servicesRelatedToProject) {
			for(Service_Item__c si : servicesRelatedToProject) {
				affectedSiSet.add(si.Id);
			}
		}
		Map<Id, Service_Item__c> serviceItemsFromDB = new Map<Id, Service_Item__c> ([SELECT Is_Amendmend_Deleted__c, Change_Order__c, Change_Order__r.Status__c FROM Service_Item__c WHERE Id IN :affectedSiSet]);
		
        List<Service_Item__c> serviceItems = new List<Service_Item__c>();

        if (!projectProfile.No_Met_Data_Scanning__c && !projectProfile.Pre_billed__c) {
            if (null != servicesRelatedToProject) {
                for (Service_Item__c service : servicesRelatedToProject) {
                    if (    service.Met_Data_Scanning_Fee__c > 0
						&& !service.Met_Data_BLI_Created__c
						&& isServiceCompleted(projectProfile, service, updatedServices, isLastBillingInProject(projectProfile, tasksRelatedToProject, true))
						&& serviceItemsFromDB.get(service.Id) != null && ((serviceItemsFromDB.get(service.Id).Change_Order__c == null || serviceItemsFromDB.get(service.Id).Change_Order__r.Status__c != 'Change Order Approved' || !serviceItemsFromDB.get(service.Id).Is_Amendmend_Deleted__c))
						) {
                        serviceItems.add(new Service_Item__c(Id                       = service.Id,
                                                             Met_Data_BLI_Created__c  = true,
                                                             Met_Data_Scanning_Fee__c = service.Met_Data_Scanning_Fee__c));

                    }

                }

            }

        }
        return serviceItems;

    }

    @testVisible
    private static Boolean isLastBillingInProject(Project_Profile__c projectProfile, List<Task_Item__c> taskItems, Boolean isScanningScope) {
        Integer countOfNotBilledItems = 0;
        //If we check project billing completnes for scanning, tasks and dates from db should contain the last not completed item
        Integer amountForComparison = isScanningScope ? 1 : 0;

        if ((ProjectProfileServices.BILLINGMETHODPERCENTAGE == projectProfile.Billing_Method__c && projectProfile.Interval__c) || ProjectProfileServices.BILLINGMETHODINSTALLMENT  == projectProfile.Billing_Method__c) {
            for (Billing_Date__c billingDate : projectProfile.Billing_Dates__r) {
                countOfNotBilledItems += !billingDate.Billed__c ? 1 : 0;
            }
        } else {
            if( taskItems != null ){
            	for (Task_Item__c taskItem : taskItems) {
	                countOfNotBilledItems += (taskItem.Billing_Trigger__c && !taskItem.Is_Locked__c && taskItem.Billing_Percentage__c > 0) ? 1 : 0;
	            }
            }
        }
        return countOfNotBilledItems == amountForComparison;
	}

    private static Boolean isServiceCompleted( Project_Profile__c projectProfile, Service_Item__c service , Map<Id, Service_Item__c> updatedServices, Boolean isLastBillingInProject ){
        return isLastBillingInProject || (!isLastBillingInProject && (service.Actual_End_Date__c != null || updatedServices.containsKey(service.id) && updatedServices.get(service.Id).Actual_End_Date__c != null ) );
    }

    public static Service_Item__c getServiceItemShreddingPerProject( Project_Profile__c projectProfile, Boolean includeNotCompleted){
        List<Service_Item__c> filteredServiceItems = new List<Service_Item__c>();
        if( !projectProfile.No_Document_Shredding__c && !projectProfile.Pre_billed__c ){
            for (Service_Item__c service : projectProfile.Service_Items__r) {
                if( service.Shredding_Fees__c > 0 && !service.Doc_Shredding_BLI_Created__c && service.Type__c == TYPE_PLAN_APPROVAL
                    && ( service.Category__c == CATEGORY_APPLICATION_FILING || service.Category__c == CATEGORY_APPLICATION_REQUIREMENT ) ){
                    if( includeNotCompleted || (!includeNotCompleted && service.Actual_End_Date__c != null ) ) {
                        filteredServiceItems.add( new Service_Item__c(Id = service.Id, Doc_Shredding_BLI_Created__c = true, Shredding_Fees__c = service.Shredding_Fees__c, Phase__c = service.Phase__c) );
                    }
                }
            }
        }
        if( filteredServiceItems.isEmpty() ) return new Service_Item__c();

        return getMostValuableShreddingService(filteredServiceItems);
    }

    public static Service_Item__c getServiceItemShreddingPerProject( Project_Profile__c projectProfile, List<Service_Item__c> serviceItems, List<Task_Item__c> taskItems){
        List<Service_Item__c> filteredServiceItems = new List<Service_Item__c>();

        if( !projectProfile.No_Document_Shredding__c && !projectProfile.Pre_billed__c ){
            for (Service_Item__c service : serviceItems) {
                if( service.Shredding_Fees__c > 0 && !service.Doc_Shredding_BLI_Created__c && service.Type__c == TYPE_PLAN_APPROVAL
                    && ( service.Category__c == CATEGORY_APPLICATION_FILING || service.Category__c == CATEGORY_APPLICATION_REQUIREMENT ) &&
                    isServiceCompleted(projectProfile, service, new Map<Id, Service_Item__c>(), isLastBillingInProject(projectProfile, taskItems, false)) ){
                    filteredServiceItems.add( new Service_Item__c(Id = service.Id,
                                                                  Doc_Shredding_BLI_Created__c = true,
                                                                  Shredding_Fees__c = service.Shredding_Fees__c,
                                                                  Phase__c = service.Phase__c) );
                }
            }
        }

        if( filteredServiceItems.isEmpty() ){
            return new Service_Item__c();
        }

        return getMostValuableShreddingService(filteredServiceItems);
    }

    public static Service_Item__c getServiceItemShreddingPerInvoice(Project_Profile__c projectProfile, List<Service_Item__c> serviceItems, List<Task_Item__c> taskItems) {
        List<Service_Item__c> filteredServiceItems = new List<Service_Item__c>();

        if (!projectProfile.No_Document_Shredding__c && !projectProfile.Pre_billed__c) {
            for (Service_Item__c service : serviceItems) {

                if (service.Shredding_Fees__c > 0 && !service.Doc_Shredding_BLI_Created__c &&
                    isServiceCompleted(projectProfile, service, new Map<Id, Service_Item__c>(), isLastBillingInProject(projectProfile, taskItems, false)) &&
                    (TYPE_PLAN_APPROVAL != service.Type__c || (CATEGORY_APPLICATION_FILING != service.Category__c && CATEGORY_APPLICATION_REQUIREMENT != service.Category__c))) {

                        filteredServiceItems.add(new Service_Item__c(Id                           = service.Id,
                                                                     Doc_Shredding_BLI_Created__c = true,
                                                                     Shredding_Fees__c            = service.Shredding_Fees__c,
                                                                     Phase__c                     = service.Phase__c));

                }

            }

        }
        if (filteredServiceItems.isEmpty()) {
            return new Service_Item__c();

        }
        return getMostValuableShreddingService(filteredServiceItems);

    }

    public static Service_Item__c getMostValuableShreddingService( List<Service_Item__c> serviceItems ){
        Service_Item__c filteredService = serviceItems[0];
        for( Service_Item__c serviceItem: serviceItems ){
            if( serviceItem.Shredding_Fees__c > filteredService.Shredding_Fees__c ) filteredService = serviceItem;
        }
        filteredService.Doc_Shredding_BLI_Created__c = true;
        return filteredService;
    }
    /* End Filters for Scanning and Shredding Reimbursable BLI ---------------------------------------------------------------------------------------------------------------------- */

    public static Decimal calculateSalesTax( Service_Item__c si, Boolean isAlternative, Decimal discountedServicePrice ) {
        Decimal salesTax;
        Decimal taxPerc1 = (null != si.Tax_Percent_1__c) ? si.Tax_Percent_1__c : 0.00;
        Decimal taxPerc2 = (null != si.Tax_Percent_2__c) ? si.Tax_Percent_2__c : 0.00;
        salesTax = !isAlternative ? ( ( (taxPerc1 + taxPerc2) * discountedServicePrice ) / 100 ).setScale(2) : 0.00;
        return salesTax;
    }

    public static List<Service_Item__c> getDeletedOriginalServiceItemByIds(Set<Id> serviceItemIds) {
        if (null == serviceItemIds || serviceItemIds.isEmpty()) {
            return new List<Service_Item__c>();

        }
        return new List<Service_Item__c>([SELECT Total_Service_Price__c, Status__c, Original__c, Is_Amendmend_Deleted__c, Id,
                                               (SELECT Id, Active_Billing_Line_Item__c, Amount__c
                                                FROM Billing_Line_Items_del__r
                                                WHERE Active_Billing_Line_Item__c =: true)
                                          FROM Service_Item__c
                                          WHERE Id IN: serviceItemIds AND Is_Amendmend_Deleted__c =: true]);

    }

    public static List<Id> filterProposalsWithOriginalServices ( List<Service_Item__c> serviceItems, Map<Id, Service_Item__c> oldServiceMap ) {
        List<Id> proposalIds = new List<Id>();

        for(Service_Item__c si : serviceItems ) {
            if( si.Original__c && si.Proposal__c != null && !si.Is_Alternative__c &&
                ( oldServiceMap == null || si.Total_Service_Price__c != oldServiceMap.get( si.Id ).Total_Service_Price__c ) ) {
                proposalIds.add( si.Proposal__c );
            }
        }
        return proposalIds;
    }

    public static Set<Id> filterProposalsToUpdateReceivedPO ( List<Service_Item__c> newServiceList, Map<Id, Service_Item__c> oldServiceMap ) {
        Set<Id> proposalIds = new Set<Id>();
        if( newServiceList == null ){
            for(Service_Item__c si : oldServiceMap.values() ) {
                if( /*si.Original__c &&*/ !si.Is_Alternative__c && (si.Status__c != SERVICE_STATUS_ACTIVE || String.isBlank(si.Purchase_Order__c ) ) ){
                    proposalIds.add( si.Proposal__c );
                }
            }
            return proposalIds;
        }

        for(Service_Item__c si : newServiceList ) {
            //if( !si.Original__c ) continue;
            //if( si.Is_Alternative__c ) continue; //service can be changed to alternative and backwards

            if( oldServiceMap == null ){
                if( si.Status__c != SERVICE_STATUS_ACTIVE || String.isBlank(si.Purchase_Order__c ) ){
                    proposalIds.add( si.Proposal__c );
                }
            }else{
                if( si.Status__c != oldServiceMap.get( si.Id ).Status__c // MRS-7074
                      ||  si.Purchase_Order__c != oldServiceMap.get( si.Id ).Purchase_Order__c ){
                    proposalIds.add( si.Proposal__c );
                }
            }
        }

        return proposalIds;
    }

    public static Set<Id> filterCOToUpdateReceivedPO ( List<Service_Item__c> newServiceList, Map<Id, Service_Item__c> oldServiceMap ) {
        Set<Id> changeOrderIds = new Set<Id>();
        if( newServiceList == null ){
            for(Service_Item__c si : oldServiceMap.values() ) {
                if( !String.isBlank(si.Change_Order__c) && (si.Status__c != SERVICE_STATUS_ACTIVE || String.isBlank(si.Purchase_Order__c ) ) ){
                    changeOrderIds.add( si.Change_Order__c );
                }
            }
            return changeOrderIds;
        }

        for(Service_Item__c si : newServiceList ) {
            if( String.isBlank(si.Change_Order__c) ) continue;

            if( oldServiceMap == null ){
                if( si.Status__c != SERVICE_STATUS_ACTIVE || String.isBlank(si.Purchase_Order__c ) ){
                    changeOrderIds.add( si.Change_Order__c );
                }
            }else{
                if( si.Status__c != oldServiceMap.get( si.Id ).Status__c // MRS-7074
                    ||  si.Purchase_Order__c != oldServiceMap.get( si.Id ).Purchase_Order__c ||  si.Purchase_Order__c != oldServiceMap.get( si.Id ).Purchase_Order__c ){
                    changeOrderIds.add( si.Change_Order__c );
                }
            }
        }

        return changeOrderIds;
    }

    public static Map<Id, List<Service_Item__c>> groupServiceItemsByProjectId(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return new Map<Id, List<Service_Item__c>>();

        }
        //MRS-6396
        List<Service_Item__c> services = new List<Service_Item__c>([SELECT Id, Name, Quantity__c, Total_Service_Price__c, GLA_Product__c, GLA_Product__r.Name, Service_Name_Short__c,
                                                                          Unit_Price__c, Description__c, Phase__c, Service_Name_Full__c, Discounted_Unit_Price__c,
                                                                          Work_Type__c, Proposal__c, Purchase_Order__c, Met_Data_BLI_Created__c, Type__c, Shredding_Fees__c, Category__c,
                                                                          Discount_Percentage__c, Met_Data_Scanning_Fee__c, Actual_End_Date__c, Doc_Shredding_BLI_Created__c,
                                                                          Tax_Percent_1__c, Tax_Percent_2__c, Project_Profile__c
                                                                    FROM Service_Item__c
                                                                    WHERE Project_Profile__c IN: projectIds]);

        Map<Id, List<Service_Item__c>> projectIdToServiceItems = new Map<Id, List<Service_Item__c>>();

        for (Service_Item__c item : services) {
            if (!projectIdToServiceItems.containsKey(item.Project_Profile__c)) {
                projectIdToServiceItems.put(item.Project_Profile__c, new List<Service_Item__c>());

            }
            projectIdToServiceItems.get(item.Project_Profile__c).add(item);

        }
        return projectIdToServiceItems;

    }

    public static List<Service_Item__c> filteredServiceItemWhithChangedComment(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap){
        List<Service_Item__c> resultServiceItemList = new List<Service_Item__c>();
        for (Service_Item__c serviceItem : newList){
            if ( serviceItem.Project_Profile__c != null && serviceItem.Comments__c != oldMap.get(serviceItem.Id).Comments__c){
                resultServiceItemList.add(serviceItem);
            }
        }
        return resultServiceItemList;
    }


    public static void checkIfCommentsFieldEditable(List<Service_Item__c> filteredServiceItemList){
        if (filteredServiceItemList.isEmpty()){return;}

        if ( UserServices.getProfile().Name == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ){ return; }
        Id currentUserId = userinfo.getuserid();

        Map<Id, Project_Profile__c> mapProjectProfileWithChild = new Map<Id, Project_Profile__c>();

        for (Service_Item__c serviceItem : filteredServiceItemList){
            mapProjectProfileWithChild.put(serviceItem.Project_Profile__c, null);
        }

        mapProjectProfileWithChild = new Map<Id, Project_Profile__c>([SELECT Id, Project_Manager__c, Project_Member__c,
                                                                   FREP__c, Production_Manager__c,
                                                                   (Select Id From Project_Rosters__r Where User__c =: currentUserId)
                                                         FROM Project_Profile__c WHERE Id IN : mapProjectProfileWithChild.keySet()]);

        for (Service_Item__c serviceItem : filteredServiceItemList){
            Project_Profile__c projectProfileItem = mapProjectProfileWithChild.get(serviceItem.Project_Profile__c);
            if ( projectProfileItem == null ) continue;
            if ( projectProfileItem.Project_Manager__c != currentUserId &&
                 projectProfileItem.Project_Member__c != currentUserId &&
                 projectProfileItem.FREP__c != currentUserId &&
                 projectProfileItem.Production_Manager__c != currentUserId &&
                 projectProfileItem.Project_Rosters__r.isEmpty() ){
                serviceItem.addError('You cannot update the "Comments" field value');
            }
        }
    }

    public static void populatePOReceivedFields(List<Change_Order__c> newList, Map<Id, Change_Order__c> oldMap) { //MRS 7074
      Set<Id> proposalIdxSet = new Set<Id> ();
      Set<Id> coIdxSet = new Set<Id> ();
      for( Change_Order__c cO : newList ) {
        if( cO.Status__c != oldMap.get( cO.Id ).Status__c ) {
          if( cO.Proposal__c != null ) proposalIdxSet.add( cO.Proposal__c );
          coIdxSet.add( cO.Id );
        }
      }
      //MRS-7473
      if( !proposalIdxSet.isEmpty() ) ProposalServices.updateReceivedPO( proposalIdxSet );
      if( !coIdxSet.isEmpty() ) ChangeOrderServices.updateReceivedPO( coIdxSet );
    }

    //MRS-6414
    public static Set<Id> filteredComplatedServices (List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap){
        Set<Id> filteredProjectProfileSetId = new Set<Id>();
        for (Service_Item__c serviceItemItem : newList){
            if ( serviceItemItem.Project_Profile__c != null && serviceItemItem.Actual_End_Date__c != null && oldMap.get(serviceItemItem.Id).Actual_End_Date__c == null ){
                filteredProjectProfileSetId.add(serviceItemItem.Project_Profile__c);
            }
        }
        return filteredProjectProfileSetId;
    }

    public static void populateShortServiceNameWorktypeField( List<Service_Item__c> services ) {
        //String serviceNumbersToShowShortNameAndWorktype = getServiceNumbersToShowShortNameAndWorktype(); //+MRS-6586 //-MRS-7053
        for( Service_Item__c si : services ) {
            if( /*si.Region__c == RegionServices.REGION_NAME_NY &&
                !String.isEmpty( si.Service_Template_Row__c ) && serviceNumbersToShowShortNameAndWorktype.contains( si.Service_Template_Row__c + ';' )*/ //+MRS-6586 //-MRS-7053
                si.Custom_Work_Type_Service__c ) {
                si.Short_Service_Name_Worktype__c = ( !String.isEmpty( si.Short_Service_Name__c ) ? si.Short_Service_Name__c : '' ) +
                                                    ( !String.isEmpty( si.Work_Type__c ) && !String.isEmpty( si.Short_Service_Name__c ) ? ' ' : '' ) +
                                                    ( !String.isEmpty( si.Work_Type__c ) ? si.Work_Type__c : '' );
            } else {
                si.Short_Service_Name_Worktype__c = si.Service_Name_Short__c;
            }
        }
    }

    //MRS-6851
    public static List<Service_Item__c> filteredServiceItemForChangeUserFieldsOnProject(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap){
        List<Service_Item__c> filteredServiceItemList = new List<Service_Item__c>();

        for (Service_Item__c serviceItem : newList){
            if ( !serviceItem.Is_Alternative__c && /* MRS 7160 */
                 serviceItem.Role_Assignment__c != null &&
                 serviceItem.Project_Profile__c != null &&
                 (ProjectProfileServices.ROLENAMESFORPROJECTASSIGNMENT.contains(serviceItem.Role_Assignment__c) || serviceItem.Role_Assignment__c.contains(UserServices.ROLE_CZ_MANAGER) ) &&
                 (serviceItem.OwnerId != oldMap.get(serviceItem.Id).OwnerId || (serviceItem.Actual_End_Date__c != null && oldMap.get(serviceItem.Id).Actual_End_Date__c == null) ) ){

                filteredServiceItemList.add(serviceItem);
            }
        }

        return filteredServiceItemList;
    }

	
	public static List<Service_Item__c> filteredSiToSendEmailsToSips(List<Service_Item__c> newList, Map<Id, Service_Item__c> oldMap) { //MRS 7499
		List<Service_Item__c> res = new List<Service_Item__c>();
		for(Service_Item__c si : newList) {
			if(si.Subtype__c == 'Construction' && si.Approved_Date__c != null && (oldMap.get(si.id) == null || oldMap.get(si.id).Subtype__c != 'Construction' || oldMap.get(si.id).Approved_Date__c == null)) {
				res.add(si);
			}
		}
		System.debug(LoggingLevel.ERROR, '### 1' + res);
		return res;
	}

	public static void sendEmailToSipsIfConstructionServiceApproved(List<Service_Item__c> siList) { //MRS 7499

		Set<Id> projectsAffectedIdSet = new Set<Id>();
		for(Service_Item__c si : siList) {
			if(si.Project_Profile__c != null) {
				projectsAffectedIdSet.add(si.Project_Profile__c);
			}
		}
		if(!projectsAffectedIdSet.isEmpty()) {
			List<Service_Item__c> services = [SELECT Id, Project_Profile__c, Subtype__c, Approved_Date__c, Project_Profile__r.Name
											  FROM Service_Item__c
											  WHERE Project_Profile__c IN :projectsAffectedIdSet
												AND (Subtype__c = 'Special Inspection Project Coordination' OR (Subtype__c = 'Construction' AND Approved_Date__c != null))
											  ORDER BY Subtype__c DESC];
			Map<Id, Service_Item__c> servicesMap = new Map<Id, Service_Item__c> (services);
			Map<Id, Set<Id>> projectsWithSipsServices = new Map<Id, Set<Id>>();
			for(Service_Item__c si : services) {
				if(si.Subtype__c == 'Special Inspection Project Coordination') projectsWithSipsServices.put(si.Project_Profile__c, new Set<Id>());
				if(si.Subtype__c == 'Construction' && projectsWithSipsServices.keySet().contains(si.Project_Profile__c)) projectsWithSipsServices.get(si.Project_Profile__c).add(si.Id);
			}
			Map<Id, String> projectIdToProjectNameMap = new Map<Id, String>();
			
			for(Service_Item__c si : siList) {
				if(projectsWithSipsServices.keySet().contains(si.Project_Profile__c) && projectsWithSipsServices.get(si.Project_Profile__c).size() == 1) {
					projectIdToProjectNameMap.put(si.Project_Profile__c, servicesMap.get(si.Id).Project_Profile__r.Name);
				}
			}

			if(!projectIdToProjectNameMap.isEmpty()) {
				Set<Id> setOfSIPS = new Set<Id>();
				for(User u : [SELECT Id FROM User WHERE IsActive = true AND ProfileId IN (SELECT Id FROM Profile WHERE Name = :UserServices.PROFILE_SIPS_COORDINATOR OR Name = :UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER)]) {
					setOfSIPS.add(u.Id);
				}
				if(!setOfSIPS.isEmpty()) {
					for(Id idx : projectIdToProjectNameMap.keySet()) {
						EmailMessageService.sendMassMailToInternalUsers(setOfSIPS, 'Permits have been issued for <a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/'
													+ String.valueOf(idx) + '">' + projectIdToProjectNameMap.get(idx) + '</a></html>', 'Permits have been issued for ' + projectIdToProjectNameMap.get(idx));
					}
				}
			}
		}
    }
}