public class RFIScopeServices {
    public static final String EMAIL_TEMPLATE_APP                       = 'RFI New York App';
    public static final String EMAIL_TEMPLATE_SIGN_OFF                  = 'RFI New York Sign Off';
    public static final String EMAIL_TEMPLATE_NEW_YORK_APP              = 'RFI New York App';
    public static final String EMAIL_TEMPLATE_NEW_YORK_SIGN_OFF         = 'RFI New York Sign Off';
    public static final String EMAIL_TEMPLATE_RFI_PHILADELPHIA_APP      = 'RFI Philadelphia App';
    public static final String EMAIL_TEMPLATE_RFI_PHILADELPHIA_SIGN_OFF = 'RFI Philadelphia Sign Off';
    public static final String EMAIL_TEMPLATE_RFI_NEW_JERSEY_APP        = 'RFI New Jersey App';
    public static final String EMAIL_TEMPLATE_RFI_NEW_JERSEY_SIGN_OFF   = 'RFI New Jersey Sign Off';
    public static final String EMAIL_TEMPLATE_RFI_PENNSYLVANIA_APP      = 'RFI Pennsylvania App';
    public static final String EMAIL_TEMPLATE_RFI_PENNSYLVANIA_SIGN_OFF = 'RFI Pennsylvania Sign Off';
    public static final String EMAIL_TEMPLATE_RFI_LONG_ISLAND_APP       = 'RFI Long Island App';
    public static final String EMAIL_TEMPLATE_RFI_LONG_ISLAND_SIGN_OFF  = 'RFI Long Island Sign Off';
    public static final String EMAIL_TEMPLATE_RFI_CONNECTICUT_APP       = 'RFI Connecticut App';
    public static final String EMAIL_TEMPLATE_RFI_CONNECTICUT_SIGN_OFF  = 'RFI Connecticut Sign Off';
    public static final String EMAIL_TEMPLATE_DRAFT_NAME                = 'RFI Scope Template For Use';
    
    public static final String APPLICATION_FILING          = 'Application Filing';
    public static final String PLAN_APPROVAL               = 'Plan Approval';
    public static final String WORK_PERMIT                 = 'Construction Work Permit';
    public static final String SINGLE_WORK_PERMIT          = 'Single Construction Work Permit';
    public static final String AMENDMENT_APPLICATION_FILING= 'Amendment-Application Filing';
    
    public static final String APPLICATION_SIGN_OFF        = 'Application Signoff';
    public static final String SINGLE_LETTER_OF_COMPLETION = 'Single Letter Of Completion';
    
    public static final String CERTIFICATE_OF_OCCUPANCY           = 'Certificate of Occupancy';
    public static final String TEMPORARY_CERTIFICATE_OF_OCCUPANCY = 'Temporary Certificate of Occupancy';
    
    public static final String CERTIFICATE_OF_APPROVAL_COMPLETION        = 'Certificate of Approval/Completion';
    public static final String SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION = 'Single Certificate of Approval/Completion';
    
    public static final String INSPECTION_COORDINATION   = 'Inspection Coordination';
    public static final String CERTIIFCATE_OF_COMPLETION = 'Certificate of Completion';
    public static final String CERTIIFCATE_OF_APPROVAL   = 'Certificate of Approval';
    public static final String USE_OCCUPANCY_CERTIFICATE = 'Use & Occupancy Certificate';
    
    public static final String APPLICATION_TYPE     = 'Application';
    public static final String SIGN_OFF_TYPE        = 'SignOff';

    public static final String RFI_SCOPE_OBJECT_NAME = 'RFI_Scope__c';

    public static final String RECORD_TYPE_NAME_STANDARD = 'Standard RFI Scope';    
    
    //---------------------------------------------------- Begin Business Logic Methods ----------------------------------------------------------------------------------------//
    @future(callout = true)
    public static void insertRFIScopesForProjects( Set<Id> projectIds ) {
        ID standardRecordTypeId                                     = RecordTypeServices.getRecordTypeIdByRecordTypeName(RECORD_TYPE_NAME_STANDARD, RFI_SCOPE_OBJECT_NAME);
        List<Project_Profile__c> projectItems                       = ProjectProfileServices.getProjectsWithServiceItemsById(projectIds);
        Map<Id, Map<String, RFI_Scope__c>> regionIdToNameToRFIScope = RegionServices.getRegionIdToNameToRFIScope(RegionServices.getRegionIdsByProjects(projectItems));
        
        RFI_Scope__c newRFI;
        Map<String, Project_Roster__c> rosterInProject;
        List<RFI_Scope__c> newRFIScopes;
        List<RFI_Scope__c> allRFIScopes = new List<RFI_Scope__c>();
        for (Project_Profile__c project : projectItems) {
            newRFIScopes = new List<RFI_Scope__c>();
            //Group Roster
            rosterInProject = ProjectRosterServices.getRoleToRoster(project.Project_Rosters__r);

            //Map for RFI(s) items for project
            Set<String> projectRFIs = new Set<String>();

            //Map of Service items group by Group number
            Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItems = new Map<Decimal, List<Service_Item__c>>();

            for (Service_Item__c serviceItem : project.Service_Items__r) {
                //Scopes for project
                projectRFIs.addall(getRFIsForProjectLevel(serviceItem, project.Building__r.Municipality__r.Region__r.Name));
               
                //Group Service items by group number
                if (!serviceGroupNumberToServiceItems.containsKey(serviceItem.Service_Group__c)) {
                    serviceGroupNumberToServiceItems.put(serviceItem.Service_Group__c, new List<Service_Item__c>());

                }
                serviceGroupNumberToServiceItems.get(serviceItem.Service_Group__c).add(serviceItem);

            }
            //Begin Create RFI for Service Item Level with group number
            RFI_Scope__c rfiGroup;

            for (Decimal groupNumber : serviceGroupNumberToServiceItems.keySet()) {
                Set<String> uniqueScopes = new Set<String>();
                List<RFI_Scope__c> rfiForGroup = new List<RFI_Scope__c>();
                
                for (Service_Item__c service : serviceGroupNumberToServiceItems.get(groupNumber)) {
                    //Create RFI Scopes
                    for (String rfiName : String.isBlank(service.Service_Level_RFI__c) ? new List<String>() : service.Service_Level_RFI__c.split(';', -1)) {
                        if (uniqueScopes.contains(rfiName)) {
                            continue;
                        
                        } else {
                            uniqueScopes.add(rfiName);
                            
                        }
                        
                        if (regionIdToNameToRFIScope.containsKey(project.Region_ID__c) && regionIdToNameToRFIScope.get(project.Region_ID__c).containsKey(rfiName)) {
                            RFI_Scope__c rfi = regionIdToNameToRFIScope.get(project.Region_ID__c).get(rfiName);
                            rfiGroup = createRFI(rfi, service, project, groupNumber, standardRecordTypeId , serviceGroupNumberToServiceItems, project.Building__r.Municipality__r.Region__r.Name);
                            
                            if (null != rfiGroup) {
                                //Set Roster
                                rfiGroup.Project_Roster__c = rosterInProject.containsKey(rfi.Project_Roster_Role__c) ? rosterInProject.get(rfi.Project_Roster_Role__c).Id : null;
                                rfiForGroup.add(rfiGroup);
                                rfiGroup = null;

                            }
                        
                        }

                    }
                    populateServiceItemsLookUp(groupNumber, serviceGroupNumberToServiceItems, rfiForGroup, project.Building__r.Municipality__r.Region__r.Name);

                }
                
                if (!rfiForGroup.isEmpty()) {
                    newRFIScopes.addall(rfiForGroup);
                
                }

            }
            //End Create RFI for Service Item Level with group number

            //Begin Create RFI items for Project Level
            for (String rfiName : projectRFIs) {
                if (regionIdToNameToRFIScope.containsKey(project.Region_ID__c) && regionIdToNameToRFIScope.get(project.Region_ID__c).containsKey(rfiName)) {
                    RFI_Scope__c rfi = regionIdToNameToRFIScope.get(project.Region_ID__c).get(rfiName);
                    newRFI = createRFIForGroup(rfi, null, project.Id, standardRecordTypeId , project.Region_ID__c);
                    newRFI.Project_Roster__c = rosterInProject.containsKey(rfi.Project_Roster_Role__c) ? rosterInProject.get(rfi.Project_Roster_Role__c).Id : null;
                    newRFIScopes.add(newRFI);

                }

            }
            //End Create RFI items for Project Level
            allRFIScopes.addall(newRFIScopes);

        }
        if (!allRFIScopes.isEmpty()) {
            try {
                insert allRFIScopes;

            } catch (Exception ex) {
                throw new ErrorException('DML Exception: ' + ex.getMessage());

            }

        }

    }

    @future(callout=true)
    public static void createRFIForChangeOrder( Set<Id> serviceItemIds ) {
        //Group Service Item by Project Id for Change Order impact on the RFI
        Map<Id, List<Service_Item__c>> projectIdToServiceItems = ServiceItemServices.getProjectIdToServiceItemsForChangeOrderRfiScope( serviceItemIds );

        if( null == projectIdToServiceItems || projectIdToServiceItems.isEmpty() ) {
            return;
        }
        
        ID standardRecordTypeId                                     = RecordTypeServices.getRecordTypeIdByRecordTypeName(RECORD_TYPE_NAME_STANDARD, RFI_SCOPE_OBJECT_NAME);
        List<Project_Profile__c> projectItems                       = ProjectProfileServices.getProjectsWithServiceItemsById(projectIdToServiceItems.keySet());
        Map<Id, Map<String, RFI_Scope__c>> regionIdToNameToRFIScope = RegionServices.getRegionIdToNameToRFIScope(RegionServices.getRegionIdsByProjects(projectItems));
        
        RFI_Scope__c rfiGroup;
        List<RFI_Scope__c> newRFIScopes;
        List<RFI_Scope__c> allRFIScopes                       = new List<RFI_Scope__c>();
        Map<String, Project_Roster__c> rosterInProject        = new Map<String, Project_Roster__c>();
        Map<Id, Set<Decimal>> projectIdToGroupNumbers         = getProjectIdToGroupNumbers(projectIdToServiceItems.keySet());
        Map<Id, Map<Decimal, List<Service_Item__c>>> groupMap = groupByProjectIdByGroupNumberByServiceItems(projectIdToServiceItems);
         
        for (Project_Profile__c project : projectItems) {
            newRFIScopes = new List<RFI_Scope__c>();
            //Group Roster
            rosterInProject = ProjectRosterServices.getRoleToRoster(project.Project_Rosters__r);
            
            for (Decimal groupNumber : groupMap.get(project.Id).keySet()) {                
                //If new Service Item added to existing group number, system shouldn't create RFI Scope
                if (projectIdToGroupNumbers.containsKey(project.Id) && projectIdToGroupNumbers.get(project.Id).contains(groupNumber)) {
                    continue;
                
                }
                
                Set<String> uniqueScopes = new Set<String>();
                List<RFI_Scope__c> rfiForGroup = new List<RFI_Scope__c>();
                
                for (Service_Item__c service : groupMap.get(project.Id).get(groupNumber)) {
                    //Generate new RFI Scopes
                    for (String rfiName : String.isBlank(service.Service_Level_RFI__c) ? new List<String>() : service.Service_Level_RFI__c.split(';', -1)) {
                        if (uniqueScopes.contains(rfiName)) {
                            continue;
                        
                        } else {
                            uniqueScopes.add(rfiName);
                            
                        }
                        
                        if (regionIdToNameToRFIScope.containsKey(project.Region_ID__c) && regionIdToNameToRFIScope.get(project.Region_ID__c).containsKey(rfiName)) {
                            RFI_Scope__c rfi = regionIdToNameToRFIScope.get(project.Region_ID__c).get(rfiName);
                            rfiGroup = createRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap.get(project.Id), project.Building__r.Municipality__r.Region__r.Name);
                                    
                            if (null != rfiGroup) {
                                //Set Roster
                                rfiGroup.Project_Roster__c = rosterInProject.containsKey(rfi.Project_Roster_Role__c) ? rosterInProject.get(rfi.Project_Roster_Role__c).Id : null;
                                rfiForGroup.add(rfiGroup);
                                rfiGroup = null;
        
                            }
                        
                        }
        
                    }
                    populateServiceItemsLookUp(groupNumber, groupMap.get(project.Id), rfiForGroup, project.Building__r.Municipality__r.Region__r.Name);
                    
                }
                
                if (!rfiForGroup.isEmpty()) {
                    newRFIScopes.addall(rfiForGroup);

                }
    
            }
            //End Generate RFI Scopes
            allRFIScopes.addall(newRFIScopes);
        
        }
        
        if (!allRFIScopes.isEmpty()) {
            try {
                insert allRFIScopes;
        
            } catch (Exception ex) {
                throw new ErrorException('DML Exception: ' + ex.getMessage());
        
            }
        
        }
    
    }
    
    private static RFI_Scope__c createRFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap, final String regionName) {
         RFI_Scope__c rfiGroup;
         
         //Create RFI Scope for New York Region
         if (RegionServices.REGION_NAME_NY == regionName) {
             rfiGroup = createNewYorkRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         //Create RFI Scope for Connecticut/Massachusetts/Westchester Regions
         } else if (RegionServices.REGION_NAME_CT == regionName || RegionServices.REGION_NAME_MASSACHUSETTS == regionName || RegionServices.REGION_NAME_WESTCHESTER == regionName) {
             rfiGroup = createWest_CT_MA_RFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         //Create RFI Scope for Long Island    
         } else if (RegionServices.REGION_NAME_LI == regionName) {
             rfiGroup = createLongIslandRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         //Create RFI Scope for New Jersey
         } else if (RegionServices.REGION_NAME_NJ == regionName) {
             rfiGroup = createNewJerseyRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         //Create RFI Scope for Delaware/Maryland/Pennsylvania Regions
         } else if (RegionServices.REGION_NAME_PENN == regionName || RegionServices.REGION_NAME_DE == regionName || RegionServices.REGION_NAME_MD == regionName) {
             rfiGroup = createPennDeMdRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         } else if (RegionServices.REGION_NAME_WASH == regionName || RegionServices.REGION_NAME_VIRGINIA == regionName) {
            rfiGroup = createPennDeMdRFI(rfi, service, project, groupNumber, standardRecordTypeId, groupMap);
         
         }
         return rfiGroup;
            
    }
    
    @testVisible
    private static RFI_Scope__c createNewYorkRFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap) {
        RFI_Scope__c rfiGroup;
        
        if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             rfiGroup.Application_Service_Item__c = service.Id;
            
         //A group consists of 2 types of services: Single Construction Work Permit & Single Sign Off
         } else if (((APPLICATION_FILING == service.Category__c && SINGLE_WORK_PERMIT == service.Type__c) || 
                   (APPLICATION_SIGN_OFF == service.Category__c && SINGLE_LETTER_OF_COMPLETION == service.Type__c)) &&
                     2 == groupMap.get(groupNumber).size()) {
                     
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             rfiGroup.Application_Service_Item__c = groupMap.get(groupNumber).get(0).Category__c.contains(APPLICATION_FILING)   ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
             rfiGroup.Sign_Off_Service_Item__c    = groupMap.get(groupNumber).get(0).Category__c.contains(APPLICATION_SIGN_OFF) ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
                                            
         //A group consists of Single Construction Work Permit service only
         } else if (APPLICATION_FILING == service.Category__c && SINGLE_WORK_PERMIT == service.Type__c && 1 == groupMap.get(groupNumber).size()) {
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             rfiGroup.Application_Service_Item__c = service.Id;
            
         //A group consists of Single Sign Off service only
         } else if(APPLICATION_SIGN_OFF == service.Category__c && SINGLE_LETTER_OF_COMPLETION == service.Type__c && 1 == groupMap.get(groupNumber).size()) {
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             rfiGroup.Sign_Off_Service_Item__c = service.Id;
            
         }
         return rfiGroup;
           
    }
    
    @testVisible
    private static RFI_Scope__c createWest_CT_MA_RFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap) {
        RFI_Scope__c rfiGroup;
        
        //Group Consist from 1 Service
        if (1 == groupMap.get(groupNumber).size()) {
            if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
                rfiGroup.Application_Service_Item__c = service.Id;
                 
            } else if (APPLICATION_SIGN_OFF == service.Category__c && CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                 rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
                 rfiGroup.Sign_Off_Service_Item__c = service.Id;
             
            } else if (APPLICATION_SIGN_OFF == service.Category__c && TEMPORARY_CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                 rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
                 rfiGroup.Sign_Off_Second_Service_Item__c = service.Id;
             
            }
         
        //Group Consist from 2 Service
        } else if (2 == groupMap.get(groupNumber).size() && ((APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) || 
                  (APPLICATION_SIGN_OFF == service.Category__c && (TEMPORARY_CERTIFICATE_OF_OCCUPANCY == service.Type__c || CERTIFICATE_OF_OCCUPANCY == service.Type__c)))) {
              rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
               
              if (APPLICATION_FILING == groupMap.get(groupNumber).get(0).Category__c) {
                  rfiGroup.Application_Service_Item__c = groupMap.get(groupNumber).get(0).Id;
                   
                  if (CERTIFICATE_OF_OCCUPANCY == groupMap.get(groupNumber).get(1).Type__c) {
                      rfiGroup.Sign_Off_Service_Item__c = groupMap.get(groupNumber).get(1).Id;
                   
                  } else {
                      rfiGroup.Sign_Off_Second_Service_Item__c = groupMap.get(groupNumber).get(1).Id;
                       
                  }
               
              } else {
                  //Group Consist with two Sign Off Services
                  if (APPLICATION_SIGN_OFF == groupMap.get(groupNumber).get(1).Category__c) {
                      rfiGroup.Sign_Off_Service_Item__c        = CERTIFICATE_OF_OCCUPANCY           == groupMap.get(groupNumber).get(0).Type__c ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
                      rfiGroup.Sign_Off_Second_Service_Item__c = TEMPORARY_CERTIFICATE_OF_OCCUPANCY == groupMap.get(groupNumber).get(0).Type__c ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
                   
                  } else {
                      rfiGroup.Application_Service_Item__c = groupMap.get(groupNumber).get(1).Id;
                       
                      if (CERTIFICATE_OF_OCCUPANCY == groupMap.get(groupNumber).get(0).Type__c) {
                          rfiGroup.Sign_Off_Service_Item__c = groupMap.get(groupNumber).get(0).Id;
                       
                      } else {
                          rfiGroup.Sign_Off_Second_Service_Item__c = groupMap.get(groupNumber).get(0).Id;
                           
                      }
                   
                  }
               
              }
             
         //Group Consist from 3 Service
         } else if (3 == groupMap.get(groupNumber).size() && ((APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) || 
                   (APPLICATION_SIGN_OFF == service.Category__c && (TEMPORARY_CERTIFICATE_OF_OCCUPANCY == service.Type__c || CERTIFICATE_OF_OCCUPANCY == service.Type__c)))) {
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             
             for (Service_Item__c serviceItem : groupMap.get(groupNumber)) {
                 if (APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) {
                     rfiGroup.Application_Service_Item__c = serviceItem.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == serviceItem.Category__c && CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c) {
                     rfiGroup.Sign_Off_Service_Item__c = serviceItem.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == serviceItem.Category__c && TEMPORARY_CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c) {
                     rfiGroup.Sign_Off_Second_Service_Item__c = serviceItem.Id;
                 
                 }
             
             }
         
         }
         return rfiGroup;
         
    }
    
    @testVisible
    private static RFI_Scope__c createLongIslandRFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap) {
        RFI_Scope__c rfiGroup = new RFI_Scope__c();
        
        //Group Consist from 1 Service
        if (1 == groupMap.get(groupNumber).size()) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);

            if (APPLICATION_FILING == service.Category__c) {
                if (PLAN_APPROVAL == service.Type__c) {
                    rfiGroup.Application_Service_Item__c = service.Id;
                
                } else if (SINGLE_WORK_PERMIT == service.Type__c) {
                    rfiGroup.Application_Work_Permit_Service_Item__c = service.Id;
                
                }
            
            } else if (APPLICATION_SIGN_OFF == service.Category__c && (CERTIFICATE_OF_APPROVAL_COMPLETION == service.Type__c || SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION == service.Type__c)) {
                rfiGroup.Sign_Off_Service_Item__c = service.Id;
                
            }
            
        //Group Consist from 2 Services
        } else if (2 == groupMap.get(groupNumber).size()) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);

            if (groupMap.get(groupNumber).get(0).Category__c.contains(APPLICATION_FILING) && groupMap.get(groupNumber).get(1).Category__c.contains(APPLICATION_FILING)) {
                rfiGroup.Application_Service_Item__c             = groupMap.get(groupNumber).get(0).Type__c == PLAN_APPROVAL ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
                rfiGroup.Application_Work_Permit_Service_Item__c = groupMap.get(groupNumber).get(0).Type__c == WORK_PERMIT   ? groupMap.get(groupNumber).get(0).Id : groupMap.get(groupNumber).get(1).Id;
            
            } else {
                rfiGroup.Application_Service_Item__c = groupMap.get(groupNumber).get(0).Category__c.contains(APPLICATION_FILING) && (groupMap.get(groupNumber).get(0).Type__c == PLAN_APPROVAL || groupMap.get(groupNumber).get(0).Type__c == WORK_PERMIT) ? 
                                                           groupMap.get(groupNumber).get(0).Id :  groupMap.get(groupNumber).get(1).Id;
                rfiGroup.Sign_Off_Service_Item__c = groupMap.get(groupNumber).get(0).Category__c.contains(APPLICATION_SIGN_OFF) && (groupMap.get(groupNumber).get(0).Type__c == CERTIFICATE_OF_APPROVAL_COMPLETION || groupMap.get(groupNumber).get(0).Type__c == SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION) ? 
                                                           groupMap.get(groupNumber).get(0).Id :  groupMap.get(groupNumber).get(1).Id;
            
            }


        //Group Consist from 3 Services        
        } else if (3 == groupMap.get(groupNumber).size()) {
             rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
             
             for (Service_Item__c serviceItem : groupMap.get(groupNumber)) {
                 if (APPLICATION_FILING == serviceItem.Category__c) {
                     if (PLAN_APPROVAL == serviceItem.Type__c) {
                         rfiGroup.Application_Service_Item__c = serviceItem.Id;
                    
                     } else if (SINGLE_WORK_PERMIT == serviceItem.Type__c) {
                         rfiGroup.Application_Work_Permit_Service_Item__c = serviceItem.Id;
                    
                     }
                        
                 } else if (APPLICATION_SIGN_OFF == serviceItem.Category__c) {
                     rfiGroup.Sign_Off_Service_Item__c = serviceItem.Id;
                     
                 }
            
            }         
        
        }
        return rfiGroup;
           
    }
    
    @testVisible
    private static RFI_Scope__c createNewJerseyRFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap) {
        RFI_Scope__c rfiGroup = new RFI_Scope__c();
        
        //Group Consist from 1 Service
        if (1 == groupMap.get(groupNumber).size()) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
            
            if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                rfiGroup.Application_Service_Item__c = service.Id;
                
            } else if (service.Category__c.contains(APPLICATION_SIGN_OFF) && (CERTIFICATE_OF_OCCUPANCY == service.Type__c || CERTIIFCATE_OF_APPROVAL == service.Type__c || CERTIIFCATE_OF_COMPLETION == service.Type__c || INSPECTION_COORDINATION == service.Type__c)) {
                rfiGroup.Sign_Off_Service_Item__c = service.Id;
                
            }
            
        } else if (groupMap.get(groupNumber).size() > 1) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
            
            for (Service_Item__c serviceItem : groupMap.get(groupNumber)) {     
                if (APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) {
                    rfiGroup.Application_Service_Item__c = serviceItem.Id;
                
                } else if (APPLICATION_SIGN_OFF == serviceItem.Category__c) {
                    if (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c) {
                        rfiGroup.Sign_Off_Service_Item__c = serviceItem.Id;
                    
                    } else if (null == rfiGroup.Sign_Off_Second_Service_Item__c && (CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || CERTIIFCATE_OF_COMPLETION == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c)) {
                        rfiGroup.Sign_Off_Second_Service_Item__c = serviceItem.Id;
    
                    } else if (CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || CERTIIFCATE_OF_COMPLETION == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c) {
                        rfiGroup.Sign_Off_Third_Service_Item__c = serviceItem.Id;
                    
                    }
                
                }
                
            }
        
        }
        return rfiGroup;
           
    }
    
    @testVisible
    private static RFI_Scope__c createPennDeMdRFI(RFI_Scope__c  rfi, Service_Item__c service, Project_Profile__c project, Decimal groupNumber, Id standardRecordTypeId, Map<Decimal, List<Service_Item__c>> groupMap) {
        RFI_Scope__c rfiGroup = new RFI_Scope__c();
        
        //Group Consist from 1 Service
        if (1 == groupMap.get(groupNumber).size()) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
            
            if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                rfiGroup.Application_Service_Item__c = service.Id;
                
            } else if (service.Category__c.contains(APPLICATION_SIGN_OFF) && (CERTIFICATE_OF_OCCUPANCY == service.Type__c || CERTIIFCATE_OF_APPROVAL == service.Type__c || INSPECTION_COORDINATION == service.Type__c || USE_OCCUPANCY_CERTIFICATE == service.Type__c)) {
                rfiGroup.Sign_Off_Service_Item__c = service.Id;
                
            }
            
        } else if (groupMap.get(groupNumber).size() > 1) {
            rfiGroup = createRFIForGroup(rfi, groupNumber, project.Id, standardRecordTypeId , project.Region_ID__c);
            
            for (Service_Item__c serviceItem : groupMap.get(groupNumber)) {     
                if (APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) {
                    rfiGroup.Application_Service_Item__c = serviceItem.Id;
                
                } else if (APPLICATION_SIGN_OFF == serviceItem.Category__c) {
                    if (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c) {
                        rfiGroup.Sign_Off_Service_Item__c = serviceItem.Id;
                    
                    } else if (null == rfiGroup.Sign_Off_Second_Service_Item__c && (CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || USE_OCCUPANCY_CERTIFICATE == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c)) {
                        rfiGroup.Sign_Off_Second_Service_Item__c = serviceItem.Id;
    
                    } else if (CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || USE_OCCUPANCY_CERTIFICATE == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c) {
                        rfiGroup.Sign_Off_Third_Service_Item__c = serviceItem.Id;
                    
                    }
                
                }
                
            }
        
        }
        return rfiGroup;
    
    }
        
    private static void populateServiceItemsLookUp(Decimal groupNumber, Map<Decimal, List<Service_Item__c>> groupMap, List<RFI_Scope__c> rfiForGroup, final String regionName) {
        //Set Application Work Permit Service Type to RFI Scopes
        for (Service_Item__c item : groupMap.get(groupNumber)) {
            for (RFI_Scope__c rfiG : rfiForGroup) {
                //Populate lookup for New York Region
                if (RegionServices.REGION_NAME_NY == regionName) {
                    if (item.Category__c.contains(APPLICATION_FILING) && WORK_PERMIT == item.Type__c) {
                        rfiG.Application_Work_Permit_Service_Item__c = item.Id;
                        
                    } else if (item.Category__c.contains(APPLICATION_SIGN_OFF)) {
                        rfiG.Sign_Off_Service_Item__c = item.Id;
                        
                    }
                
                //Populate lookup for Connecticut/Massachusetts/Westchester Regions
                } else if (RegionServices.REGION_NAME_CT == regionName || RegionServices.REGION_NAME_MASSACHUSETTS == regionName || RegionServices.REGION_NAME_WESTCHESTER == regionName) {         
                
                //Populate lookup for Delaware/Maryland/Pennsylvania Regions
                } else if (RegionServices.REGION_NAME_PENN == regionName || RegionServices.REGION_NAME_DE == regionName || RegionServices.REGION_NAME_MD == regionName) {
                
                //Populate lookup for Washington Region
                } else if (RegionServices.REGION_NAME_WASH == regionName || RegionServices.REGION_NAME_VIRGINIA == regionName) {
                
                }
            
            }
        
        }
    
    }
    
    @testVisible
    private static Set<String> getRFIsForProjectLevel(final Service_Item__c serviceItem, final String regionName) {
        if (String.isBlank(serviceItem.Project_Level_RFI__c)) {
            return new Set<String>();
        
        }
        
        Set<String> projectRFIs = new Set<String>();
        
        for (String rfiName : serviceItem.Project_Level_RFI__c.split(';', -1)) {
            //Project Level for New York Region
            if (RegionServices.REGION_NAME_NY == regionName && 
                (serviceItem.Category__c.contains(APPLICATION_SIGN_OFF) || (serviceItem.Category__c.contains(APPLICATION_FILING) && (PLAN_APPROVAL == serviceItem.Type__c || WORK_PERMIT == serviceItem.Type__c)) )) {
                projectRFIs.add(rfiName);
            
            //Project Level for Connecticut/Massachusetts/Westchester Regions
            } else if ((RegionServices.REGION_NAME_CT == regionName || RegionServices.REGION_NAME_MASSACHUSETTS == regionName || RegionServices.REGION_NAME_WESTCHESTER == regionName ) && 
                      ((serviceItem.Category__c.contains(APPLICATION_FILING) && PLAN_APPROVAL == serviceItem.Type__c) || 
                        serviceItem.Category__c.contains(APPLICATION_SIGN_OFF) && (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c || TEMPORARY_CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c))) {
                            projectRFIs.add(rfiName);
                            
            //Project Level for Long Island Region
            } else if (RegionServices.REGION_NAME_LI == regionName && 
                       ((APPLICATION_FILING == serviceItem.Category__c && (SINGLE_WORK_PERMIT == serviceItem.Type__c || PLAN_APPROVAL == serviceItem.Type__c)) || 
                         serviceItem.Category__c.contains(APPLICATION_SIGN_OFF))) {
                            projectRFIs.add(rfiName);
                                
            //Project Level for Long New Jersey Region
            } else if (RegionServices.REGION_NAME_NJ == regionName && 
                       ((APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) || 
                        (serviceItem.Category__c.contains(APPLICATION_SIGN_OFF) && 
                        (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c || CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || CERTIIFCATE_OF_COMPLETION == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c)))) {
                            projectRFIs.add(rfiName);
            
            //Project Level for Delaware/Maryland/Pennsylvania Region
            } else if ((RegionServices.REGION_NAME_PENN == regionName || RegionServices.REGION_NAME_DE == regionName || RegionServices.REGION_NAME_MD == regionName) && 
                       ((APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) || 
                        (serviceItem.Category__c.contains(APPLICATION_SIGN_OFF) && 
                        (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c || CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || USE_OCCUPANCY_CERTIFICATE == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c)))) {
                            projectRFIs.add(rfiName);
            
            } else if ((RegionServices.REGION_NAME_WASH == regionName || RegionServices.REGION_NAME_VIRGINIA == regionName) 
                        && ((APPLICATION_FILING == serviceItem.Category__c && PLAN_APPROVAL == serviceItem.Type__c) || 
                       (serviceItem.Category__c.contains(APPLICATION_SIGN_OFF) && 
                       (CERTIFICATE_OF_OCCUPANCY == serviceItem.Type__c || CERTIIFCATE_OF_APPROVAL == serviceItem.Type__c || USE_OCCUPANCY_CERTIFICATE == serviceItem.Type__c || INSPECTION_COORDINATION == serviceItem.Type__c)))) {
                           projectRFIs.add(rfiName);
            
            }
        
        }
        return projectRFIs;
    
    }

    @testVisible
    private static Map<Id, Map<Decimal, List<Service_Item__c>>> groupByProjectIdByGroupNumberByServiceItems(Map<Id, List<Service_Item__c>> projecIdToServiceItems) {
        Map<Id, Map<Decimal, List<Service_Item__c>>> projectIdToGroupNumberToServiceItems = new Map<Id, Map<Decimal, List<Service_Item__c>>>();
        
        for (Id projectId : projecIdToServiceItems.keySet()) {
            for (Service_Item__c serviceItem : projecIdToServiceItems.get(projectId)) {
                if (!projectIdToGroupNumberToServiceItems.containsKey(projectId)) {
                    projectIdToGroupNumberToServiceItems.put(projectId, new Map<Decimal, List<Service_Item__c>>());
                
                }
                
                if (!projectIdToGroupNumberToServiceItems.get(projectId).containsKey(serviceItem.Service_Group__c)) {
                    projectIdToGroupNumberToServiceItems.get(projectId).put(serviceItem.Service_Group__c, new List<Service_Item__c>());
                
                }
                projectIdToGroupNumberToServiceItems.get(projectId).get(serviceItem.Service_Group__c).add(serviceItem);
            
            }
        
        }
        return projectIdToGroupNumberToServiceItems;
    
    }
    
    @testVisible
    private static Map<Id, Set<Decimal>> getProjectIdToGroupNumbers(Set<Id> projectIds) {
        if (null == projectIds || projectIds.isEmpty()) {
            return new Map<Id, Set<Decimal>>();
        
        }
        
        Map<Id, Set<Decimal>> projectIdToGroupNumbers = new Map<Id, Set<Decimal>>();
        for (Service_Item__c serviceItem : ServiceItemServices.getOriginalServiceItemsByProjectIds(projectIds )) {
            if (!projectIdToGroupNumbers.containsKey(serviceItem.Project_Profile__c)) {
                projectIdToGroupNumbers.put(serviceItem.Project_Profile__c, new Set<Decimal>());
            
            }
            if (null != serviceItem.Service_Group__c) {
                projectIdToGroupNumbers.get(serviceItem.Project_Profile__c).add(serviceItem.Service_Group__c);
            
            }
        
        }                                          
        return projectIdToGroupNumbers;
    
    }
    
    @testVisible
    private static RFI_Scope__c createRFIForGroup(RFI_Scope__c  rfi, Decimal groupNumber, Id projectId, Id standardRecordTypeId, String regionId) {
        return new RFI_Scope__c(RFI_Section__c = rfi.RFI_Section__c, Project__c = projectId, Name = rfi.Name,
                                Project_Roster_Role__c = rfi.Project_Roster_Role__c, Roster_to_CC__c = rfi.Roster_to_CC__c, Status__c = 'Not Started',
                                Project_Level_RFI__c = false, RecordTypeId = standardRecordTypeId, Region__c = regionId, Group_Number__c = groupNumber,
                                Is_Sigh_Off_N_A__c = rfi.Is_Sigh_Off_N_A__c, Is_Application_N_A__c = rfi.Is_Application_N_A__c);
    }

    public static void createAdditionalRfiScopes(Id regionId, Id projectId, RFI_Scope__c rfiTemplate, List<Service_Item__c> serviceItems, List<Project_Roster__c> rosters, final String regionName) {
        if (null == rfiTemplate) {
            throw new ErrorException('Rfis Template element cannot be null!');

        }

        if (null == serviceItems || serviceItems.isEmpty()) {
            throw new ErrorException('Service Items list cannot be empty!');

        }
        ID standardRecordTypeId = RecordTypeServices.getRecordTypeIdByRecordTypeName(RECORD_TYPE_NAME_STANDARD, RFI_SCOPE_OBJECT_NAME);

        RFI_Scope__c newRfi = createRFIForGroup(rfiTemplate, serviceItems[0].Service_Group__c, projectId, standardRecordTypeId, regionId);

        for (Project_Roster__c roster : rosters) {
            if( roster.Role__c == rfiTemplate.Project_Roster_Role__c ) {
                newRfi.Project_Roster__c = roster.Id;
                break;

            }

        }
        populateServiceItemsLookUpForAdditionalRFI(serviceItems, regionName, newRfi);
        
        try {
            insert newRfi;

        } catch(Exception ex) {
            throw new ErrorException('Exception occured during insert new rfi scopes: ' + ex.getMessage());

        }

    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFI(final List<Service_Item__c> serviceItems, final String regionName, RFI_Scope__c newRfi) {
        //Populate lookup for New York Region
        if (RegionServices.REGION_NAME_NY == regionName) {
            populateServiceItemsLookUpForAdditionalRFINewYork(serviceItems, newRfi);
        
        //Populate lookup for Connecticut/Massachusetts/Westchester Regions
        } else if (RegionServices.REGION_NAME_CT == regionName || RegionServices.REGION_NAME_MASSACHUSETTS == regionName || RegionServices.REGION_NAME_WESTCHESTER == regionName) {
            populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(serviceItems, newRfi);
        
        //Populate lookup for Long Island Region
        } else if (RegionServices.REGION_NAME_LI == regionName) {
            populateServiceItemsLookUpForAdditionalRFILongIsland(serviceItems, newRfi);
        
        //Populate lookup for Long New Jersey Region
        } else if (RegionServices.REGION_NAME_NJ == regionName) {
            populateServiceItemsLookUpForAdditionalRFINewJersey(serviceItems, newRfi);
        
        //Populate lookup for Delaware/Maryland/Pennsylvania Regions
        } else if (RegionServices.REGION_NAME_PENN == regionName || RegionServices.REGION_NAME_DE == regionName || RegionServices.REGION_NAME_MD == regionName) {
            populateServiceItemsLookUpForAdditionalRFIPennMdDe(serviceItems, newRfi);
            
        } else if (RegionServices.REGION_NAME_WASH == regionName || RegionServices.REGION_NAME_VIRGINIA == regionName) {
            populateServiceItemsLookUpForAdditionalRFIPennMdDe(serviceItems, newRfi);
            
        }
    
    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFINewYork(final List<Service_Item__c> serviceItems, RFI_Scope__c newRfi) {
        for (Service_Item__c service : serviceItems) {
            if (service.Category__c.contains(APPLICATION_FILING) && PLAN_APPROVAL == service.Type__c) {
                newRfi.Application_Service_Item__c = service.Id;
    
            } else if (service.Category__c.contains(APPLICATION_FILING) && WORK_PERMIT == service.Type__c) {
                newRfi.Application_Work_Permit_Service_Item__c = service.Id;
    
            } else  if (service.Category__c.contains(APPLICATION_SIGN_OFF) && SINGLE_LETTER_OF_COMPLETION != service.Type__c) {
                newRfi.Sign_Off_Service_Item__c = service.Id;
    
            //A group consists of 2 types of services: Single Construction Work Permit & Single Sign Off
            } else if (((service.Category__c.contains(APPLICATION_FILING) && SINGLE_WORK_PERMIT == service.Type__c) || (service.Category__c.contains(APPLICATION_SIGN_OFF) && SINGLE_LETTER_OF_COMPLETION == service.Type__c)) && 2 == serviceItems.size()) {
                newRfi.Application_Service_Item__c = serviceItems.get(0).Category__c.contains(APPLICATION_FILING) ? serviceItems.get(0).Id : serviceItems.get(1).Id;
                newRfi.Sign_Off_Service_Item__c    = serviceItems.get(0).Category__c.contains(APPLICATION_SIGN_OFF) ? serviceItems.get(0).Id : serviceItems.get(1).Id;
                
            //A group consists of Single Construction Work Permit service only
            } else if (service.Category__c.contains(APPLICATION_FILING) && SINGLE_WORK_PERMIT == service.Type__c && 1 == serviceItems.size()) {
                newRfi.Application_Service_Item__c = service.Id;
                
            //A group consists of Single Sign Off service only
            } else if(service.Category__c.contains(APPLICATION_SIGN_OFF) && SINGLE_LETTER_OF_COMPLETION == service.Type__c && 1 == serviceItems.size()) {
                newRfi.Sign_Off_Service_Item__c = service.Id;
            
            } 
        
        }
    
    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFI_West_CT_MA(final List<Service_Item__c> serviceItems, RFI_Scope__c newRfi) {
        for (Service_Item__c service : serviceItems) {
            if (1 == serviceItems.size()) {
                if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                    newRfi.Application_Service_Item__c = service.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == service.Category__c && CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                      newRfi.Sign_Off_Service_Item__c = service.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == service.Category__c && TEMPORARY_CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                      newRfi.Sign_Off_Second_Service_Item__c = service.Id;
                 
                 }
                                
            } else if (2 == serviceItems.size()) {
                if (APPLICATION_FILING == serviceItems.get(0).Category__c) {
                   newRfi.Application_Service_Item__c = serviceItems.get(0).Id;
                   
                   if (CERTIFICATE_OF_OCCUPANCY == serviceItems.get(1).Type__c) {
                       newRfi.Sign_Off_Service_Item__c = serviceItems.get(1).Id;
                   
                   } else {
                       newRfi.Sign_Off_Second_Service_Item__c = serviceItems.get(1).Id;
                       
                   }
               
               } else {
                   //Group Consist with two Sign Off Services
                   if (APPLICATION_SIGN_OFF == serviceItems.get(1).Category__c) {
                       newRfi.Sign_Off_Service_Item__c        = CERTIFICATE_OF_OCCUPANCY           == serviceItems.get(0).Type__c ? serviceItems.get(0).Id : serviceItems.get(1).Id;
                       newRfi.Sign_Off_Second_Service_Item__c = TEMPORARY_CERTIFICATE_OF_OCCUPANCY == serviceItems.get(0).Type__c ? serviceItems.get(0).Id : serviceItems.get(1).Id;
                   
                   } else {
                       newRfi.Application_Service_Item__c = serviceItems.get(1).Id;
                       
                      if (CERTIFICATE_OF_OCCUPANCY == serviceItems.get(0).Type__c) {
                           newRfi.Sign_Off_Service_Item__c = serviceItems.get(0).Id;
                       
                       } else {
                           newRfi.Sign_Off_Second_Service_Item__c = serviceItems.get(0).Id;
                           
                       }
                   
                   }
               
               }
            
            } else if (3 == serviceItems.size()) {
                if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                     newRfi.Application_Service_Item__c = service.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == service.Category__c && CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                     newRfi.Sign_Off_Service_Item__c = service.Id;
                 
                 } else if (APPLICATION_SIGN_OFF == service.Category__c && TEMPORARY_CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                     newRfi.Sign_Off_Second_Service_Item__c = service.Id;
                 
                 }
            
            }
        
        }
    
    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFILongIsland(final List<Service_Item__c> serviceItems, RFI_Scope__c newRfi) {
        for (Service_Item__c service : serviceItems) {
            if (APPLICATION_FILING == service.Category__c) {
                if (PLAN_APPROVAL == service.Type__c) {
                    newRfi.Application_Service_Item__c = service.Id;
                
                } else if (SINGLE_WORK_PERMIT == service.Type__c) {
                    newRfi.Application_Work_Permit_Service_Item__c = service.Id;
                
                }
            
            } else if (APPLICATION_SIGN_OFF == service.Category__c) {
                newRfi.Sign_Off_Service_Item__c = service.Id;
            
            }
        
        }
    
    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFINewJersey(final List<Service_Item__c> serviceItems, RFI_Scope__c newRfi) {
        for (Service_Item__c service : serviceItems) {
            if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                newRfi.Application_Service_Item__c = service.Id;
            
            } else if (APPLICATION_SIGN_OFF == service.Category__c) {
                if (CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                    newRfi.Sign_Off_Service_Item__c = service.Id;
                
                } else if (null == newRfi.Sign_Off_Second_Service_Item__c && (CERTIIFCATE_OF_APPROVAL == service.Type__c || CERTIIFCATE_OF_COMPLETION == service.Type__c || INSPECTION_COORDINATION == service.Type__c)) {
                    newRfi.Sign_Off_Second_Service_Item__c = service.Id;

                } else if (CERTIIFCATE_OF_APPROVAL == service.Type__c || CERTIIFCATE_OF_COMPLETION == service.Type__c || INSPECTION_COORDINATION == service.Type__c) {
                    newRfi.Sign_Off_Third_Service_Item__c = service.Id;
                
                }
            
            }
        
        }
    
    }
    
    @testVisible
    private static void populateServiceItemsLookUpForAdditionalRFIPennMdDe(final List<Service_Item__c> serviceItems, RFI_Scope__c newRfi) {
        for (Service_Item__c service : serviceItems) {
            if (APPLICATION_FILING == service.Category__c && PLAN_APPROVAL == service.Type__c) {
                newRfi.Application_Service_Item__c = service.Id;
            
            } else if (APPLICATION_SIGN_OFF == service.Category__c) {
                if (CERTIFICATE_OF_OCCUPANCY == service.Type__c) {
                    newRfi.Sign_Off_Service_Item__c = service.Id;
                
                } else if (null == newRfi.Sign_Off_Second_Service_Item__c && (CERTIIFCATE_OF_APPROVAL == service.Type__c || USE_OCCUPANCY_CERTIFICATE == service.Type__c || INSPECTION_COORDINATION == service.Type__c)) {
                    newRfi.Sign_Off_Second_Service_Item__c = service.Id;

                } else if (CERTIIFCATE_OF_APPROVAL == service.Type__c || USE_OCCUPANCY_CERTIFICATE == service.Type__c || INSPECTION_COORDINATION == service.Type__c) {
                    newRfi.Sign_Off_Third_Service_Item__c = service.Id;
                
                }
            
            }
        
        }
    
    }
    
    public static void insertRFIDescriptions(List<RFI_Scope__c> rfiScopes) {
        List<RFI_Scope__c> rfiScopesNY   = new List<RFI_Scope__c>();
        List<RFI_Scope__c> rfiScopesLI   = new List<RFI_Scope__c>();
        List<RFI_Scope__c> rfiScopesCT   = new List<RFI_Scope__c>();
        List<RFI_Scope__c> rfiScopesNJ   = new List<RFI_Scope__c>();
        List<RFI_Scope__c> rfiScopesPenn = new List<RFI_Scope__c>();
        List<RFI_Scope__c> rfiScopesDC   = new List<RFI_Scope__c>();

        ID standardRecordTypeId = RecordTypeServices.getRecordTypeIdByRecordTypeName(RECORD_TYPE_NAME_STANDARD, RFI_SCOPE_OBJECT_NAME);
        Map<Id, Region__c> regionsMap = RegionServices.getRegionsMap();
        
        for (RFI_Scope__c rfi : rfiScopes) {
            if (rfi.RecordTypeId == standardRecordTypeId && regionsMap.containsKey(rfi.Region__c)) {
                if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_NY) {
                    rfiScopesNY.add(rfi);
                
                } else if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_LI) {
                    rfiScopesLI.add(rfi);
                
                } else if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_CT || 
                            regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_WESTCHESTER || 
                            regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_MASSACHUSETTS) {
                    rfiScopesCT.add(rfi);
                    
                } else if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_NJ) {
                    rfiScopesNJ.add(rfi);
                
                } else if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_DE || 
                           regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_MD || 
                           regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_PENN) {
                               rfiScopesPenn.add(rfi);
                
                } else if (regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_WASH || 
                    regionsMap.get(rfi.Region__c).Name == RegionServices.REGION_NAME_VIRGINIA) {
                    rfiScopesDC.add(rfi);
                    
                }
            
            }
        
        }
        RFIDescriptionNYServices.insertRFIDescriptionForNYRegion(rfiScopesNY);
        RFIDescriptionLIServices.insertRFIDescriptionForLIRegion(rfiScopesLI);
        RFIDescriptionCTServices.insertRFIDescriptionForCTRegion(rfiScopesCT);
        RFIDescriptionNJServices.insertRFIDescriptionForNJRegion(rfiScopesNJ);
        RFIDescriptionPAServices.insertRFIDescriptionForPARegion(rfiScopesPenn);
        RFIDescriptionDCServices.insertRFIDescriptionForDCRegion(rfiScopesDC);

    }

    public static void copyAppToSignOff(SObject rfiDescr, List<RFI_Work__c> rfiWorkTypes, Boolean copyIfNotEmpty) {
        if (null != rfiDescr) {
            //Here we use fieldSet functionlity. 
            //If we you copy new field from App to Sign Off please add App field to Field Set 
            for (Schema.FieldSetMember f : getAppFieldsToClone( rfiDescr )) {
                String fieldName = f.getFieldPath().replace('App__c', 'Off__c');  
                
                if (String.isBlank(String.valueOf(rfiDescr.get(fieldName))) || copyIfNotEmpty) {
                    rfiDescr.put(fieldName, rfiDescr.get(f.getFieldPath()));
                }
            }

            if( rfiDescr instanceof RFI_Scope_Description_New_York__c ){
                for (Schema.FieldSetMember f : getAppFieldsToCloneSign()) {
                    String fieldName = f.getFieldPath().replace('App__c', 'Sign_Off__c');  
                    
                    if (String.isBlank(String.valueOf(rfiDescr.get(fieldName))) || copyIfNotEmpty) {
                        rfiDescr.put(fieldName, rfiDescr.get(f.getFieldPath()));
                    }
                }

                RFI_Scope_Description_New_York__c nyDescription = (RFI_Scope_Description_New_York__c) rfiDescr;

                String architectWorkToCompleteSignOff = String.isBlank(nyDescription.Architect_Work_to_Complete_Sign_Off__c) || copyIfNotEmpty ? nyDescription.Architect_Work_to_Complet_App__c  : nyDescription.Architect_Work_to_Complete_Sign_Off__c;
                String contractorSigningDOBRegSignOf  = String.isBlank(nyDescription.Contractor_Signing_DOB_Reg_Sign_Of__c) || copyIfNotEmpty ? nyDescription.Contractor_Signing_DOB_Reg_App__c : nyDescription.Contractor_Signing_DOB_Reg_Sign_Of__c;
                rfiDescr.put('Architect_Work_to_Complete_Sign_Off__c', architectWorkToCompleteSignOff);
                rfiDescr.put('Contractor_Signing_DOB_Reg_Sign_Of__c', contractorSigningDOBRegSignOf);
            }
        }
        
        if (null != rfiWorkTypes) {            
            //Copy Estimated Cost for Work type
            for (RFI_Work__c workType : rfiWorkTypes) {
                if (null == workType.Actual_Costs__c || 0 == workType.Actual_Costs__c || copyIfNotEmpty) {
                    workType.Actual_Costs__c = workType.Estimated_Cost__c;
                }
            }
        }
    }

    private static List<Schema.FieldSetMember> getAppFieldsToClone( SObject rfiDescr ) {
        List<Schema.FieldSetMember> fieldset;
        if( rfiDescr instanceof RFI_Scope_Description_New_York__c ){
            fieldset = SObjectType.RFI_Scope_Description_New_York__c.FieldSets.App_Fields_to_Clone.getFields();

        }else if( rfiDescr instanceof RFI_Scope_Description_Long_Island__c ){
            fieldset = SObjectType.RFI_Scope_Description_Long_Island__c.FieldSets.App_Fields_to_Clone.getFields();

        }else if( rfiDescr instanceof RFI_Scope_Description_New_Jersey__c ){
            fieldset = SObjectType.RFI_Scope_Description_New_Jersey__c.FieldSets.App_Fields_to_Clone.getFields();

        }else if( rfiDescr instanceof RFI_Scope_Description_CT__c ){
            fieldset = SObjectType.RFI_Scope_Description_CT__c.FieldSets.App_Fields_to_Clone.getFields();

        }
        return fieldset;
    
    }
    
    private static List<Schema.FieldSetMember> getAppFieldsToCloneSign() {
        return SObjectType.RFI_Scope_Description_New_York__c.FieldSets.App_Fields_to_Clone_Sign.getFields();
    
    }
    
    //Function for complete native salesforce Follow-Up Alert tasks.
    public static void completeTasks(List<RFI_Scope__c> newRFIScopes, Map<Id, RFI_Scope__c> oldRFIScopeMap) {
        Set<Id> filteredRFIScopes = RFIScopeServices.filteredRFIScopes(newRFIScopes, oldRFIScopeMap);
        
        if (filteredRFIScopes.isEmpty()) {
            return;
        
        }
        
        List<Task> tasks = Database.query(TaskServices.buildSelectByRelatedIds(filteredRFIScopes));
        
        for (Task t : tasks) {
            if (String.isBlank(t.Related_Record_Ids__c)) {
                continue;
            
            }
            
            List<String> ids = t.Related_Record_Ids__c.split(';');
                                    
            if (RFIScopeServices.isExistRecievedRFIScopesByIds(ids)) {
                t.Status = 'Completed';
            
            }
            
        }
        update tasks;
        
    }
    
    private static Set<Id> filteredRFIScopes(List<RFI_Scope__c> newRFIScopes, Map<Id, RFI_Scope__c> oldRFIScopeMap) {
        Set<Id> filteredRFIScopes = new Set<Id>();
        
        for (RFI_Scope__c rfiScope : newRFIScopes) {
            if (rfiScope.Last_RFI_Received__c != oldRFIScopeMap.get(rfiScope.Id).Last_RFI_Received__c || rfiScope.Last_SignOff_RFI_Received__c != oldRFIScopeMap.get(rfiScope.Id).Last_SignOff_RFI_Received__c) {
                filteredRFIScopes.add(rfiScope.Id);
            
            }
        
        }
        return filteredRFIScopes;
    
    }
    
    public static Boolean isExistRecievedRFIScopesByIds(List<String> ids) {
        if (null == ids || ids.isEmpty()) {
            return false;
        
        }
        
        List<RFI_Scope__c> countScopes = new List<RFI_Scope__c>([SELECT Id 
                                                                 FROM RFI_Scope__c
                                                                 WHERE id IN: ids AND (Last_RFI_Received__c != null OR Last_SignOff_RFI_Received__c != null)]);
        
        return !countScopes.isEmpty();
    
    }
    
    public static void clearRosterLookupOnRFI(Id projectId, Id rosterId) {
        if (null == rosterId) {
            return;
        
        }
        
        List<RFI_Scope__c> rfis = new List<RFI_Scope__c>([SELECT Id, Project_Roster__c, Project__c 
                                                          FROM RFI_Scope__c 
                                                          WHERE Project_Roster__c =: rosterId AND Project__c =: projectId]);
        
        for (RFI_Scope__c rfi : rfis) {
            rfi.Project_Roster__c = null;
        
        }
        update rfis;
        
    }
    //---------------------------------------------------- End Business Logic Methods ----------------------------------------------------------------------------------------//

    //---------------------------------------------------- Begin DAO Methods -------------------------------------------------------------------------------------------------//
    public static List<RFI_Scope__c> getRFIScopesOrderedByGroupNumber(Id projectId) {
        if (null == projectId) {
            return new List<RFI_Scope__c>();
        
        }
        
        return new List<RFI_Scope__c>([SELECT Id, RFI_Section__c, Group_Number__c, Name
                                       FROM RFI_Scope__c 
                                       WHERE Project__c =: projectId ORDER BY Group_Number__c]);
            
    }
    
    public static List<RFI_Scope__c> getRFIScopesSiteOrderedByGroupNumber(Set<Id> rfiIds) {
        return new List<RFI_Scope__c>([SELECT Id, RFI_Section__c, Group_Number__c, Name
                                       FROM RFI_Scope__c 
                                       WHERE RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Id =: rfiIds]);
        
    }
    
    public static Set<Id> getRFIScopeIdsByServiceItemId(Id serviceItemId) {
        if (null == serviceItemId) {
            return new Set<Id>();
        
        }
        
        Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>([SELECT Id, Name                      
                                                                  FROM RFI_Scope__c 
                                                                  WHERE (Application_Service_Item__c =: serviceItemId 
                                                                      OR Application_Work_Permit_Service_Item__c =: serviceItemId 
                                                                      OR Sign_Off_Service_Item__c =: serviceItemId) 
                                                                      AND Name =: RFIWorkTypeServices.NYC_RFI05]);
                                                    
        return rfiMap.keySet();
        
    }
    
    public static Set<Id> getRFIScopeIdsByServiceItemIds(Set<Id> serviceItemIds) {
        if (null == serviceItemIds) {
            return new Set<Id>();
        
        }
        
        Map<Id, RFI_Scope__c> rfiMap = new Map<Id, RFI_Scope__c>([SELECT Id, Name                      
                                                                  FROM RFI_Scope__c 
                                                                  WHERE (Application_Service_Item__c IN: serviceItemIds
                                                                      OR Application_Work_Permit_Service_Item__c IN: serviceItemIds
                                                                      OR Sign_Off_Service_Item__c IN: serviceItemIds) 
                                                                      AND Name =: RFIWorkTypeServices.NYC_RFI05]);
                                                    
        return rfiMap.keySet();
        
    }
    
    public static Map<Id, RFI_Scope__c> getRFIScopeWithServiceItemById(Set<Id> ids) {
        if (null == ids || ids.isEmpty()) {
            return new Map<Id, RFI_Scope__c>(); 
        
        }
        
        return new Map<Id, RFI_Scope__c>([SELECT Sign_Off_Service_Item__c, Id, Application_Work_Permit_Service_Item__c, Application_Service_Item__r.Work_Type__c, 
                                                 Application_Service_Item__c, Sign_Off_Service_Item__r.Work_Type__c, Name 
                                          FROM RFI_Scope__c
                                          WHERE id IN: ids]);
    
    }
    
    public static Map<Id, RFI_Scope__c> getRFIScopesByRegionIds(Set<Id> regionId) {
        return new Map<Id, RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Project_Roster__r.Contact__c,
                                              Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c,
                                              Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c,
                                              Project_Roster_Role__c, Roster_to_CC__c, Project_Roster_to_CC__c, Last_RFI_Sent__c, Last_RFI_Received__c,
                                              Notes__c, Name, Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Is_Sigh_Off_N_A__c, Is_Application_N_A__c,
                                              Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c, Application_Work_Permit_Service_Item__c,
                                              Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c
                                          FROM RFI_Scope__c
                                          WHERE Region__c IN: regionId AND RecordType.Name !=: RECORD_TYPE_NAME_STANDARD]);
    }

    public static List<RFI_Scope__c> getProjectRFIScopesByRegionId(Id regionId, Id projectId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, Region__r.Name, RFI_Section__c, Selected__c, Status__c,
                                              Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Project_Roster__r.Contact__c,
                                              Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c,
                                              Notes__c, Name, Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Last_RFI_Sent__c, Last_RFI_Received__c,
                                              Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c,
                                              Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND Region__c =: regionId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD]);
    }

    public static List<RFI_Scope__c> getSignOfSubmittedRFIScopesByProjectId(Id projectId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, Region__r.Name, RFI_Section__c, Selected__c, Status__c, Project_Roster__r.Contact__c, Project_Roster__r.User_Contact__c, Project_Roster__r.User__c,
                                              Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Project_Roster__r.Name__c, Project_Roster__r.Name_Full__c,
                                              Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c,
                                              Project_Roster_Role__c, Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c,
                                              Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c,
                                              Project__r.Key__c, Project_Roster__r.Key__c, Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c,
                                              Group_Number__c, Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Submit_Sign_Off__c =: true]); // AND Status__c != 'Sent'
    }

    public static List<RFI_Scope__c> getApplicationSubmittedRFIScopesByProjectId(Id projectId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, Region__r.Name, RFI_Section__c, Selected__c, Status__c, Project_Roster__r.Contact__c, Project_Roster__r.User_Contact__c, Project_Roster__r.User__c,
                                              Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Project_Roster__r.Name__c, Project_Roster__r.Name_Full__c,
                                              Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c,
                                              Project_Roster_Role__c, Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c,
                                              Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c,
                                              Project__r.Key__c, Project_Roster__r.Key__c, Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c,
                                              Group_Number__c, Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Submit_Application__c =: true]); // AND Status__c != 'Sent'
    }

    public static List<RFI_Scope__c> getSignOffRFIByProjectIdServiceId(Id projectId, Id serviceId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Documents__c, Drawings__c,
                                              Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Recipient_Reminder_DateTime__c,
                                              Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c, Project_Roster_Role__c,
                                              Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c, App_Status__c, Sign_Off_Status__c,
                                              Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Project_Roster__r.Contact__c,
                                              Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c,
                                              Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c,
                                                  (SELECT Name, Send_Via__c, Sent__c, Received__c, Sent_to__c, RFI_Scope__c, Submit_Type__c FROM Monitor_RFI_Scopes__r)
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Sign_Off_Service_Item__c =: serviceId]);
    }

    public static List<RFI_Scope__c> getAppWorkPermitRFIByProjectIdServiceId(Id projectId, Id serviceId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Documents__c, Drawings__c,
                                              Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Recipient_Reminder_DateTime__c,
                                              Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c, Project_Roster_Role__c,
                                              Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c, App_Status__c, Sign_Off_Status__c,
                                              Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Project_Roster__r.Contact__c,
                                              Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c,
                                              Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c,
                                                  (SELECT Name, Send_Via__c, Sent__c, Received__c, Sent_to__c, RFI_Scope__c, Submit_Type__c FROM Monitor_RFI_Scopes__r)
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Application_Work_Permit_Service_Item__c =: serviceId]);
    }

    public static List<RFI_Scope__c> getAppPlanApproveRFIScopesByProjectIdServiceId(Id projectId, Id serviceId) {
        return new List<RFI_Scope__c>([SELECT Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Documents__c, Drawings__c,
                                              Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, Recipient_Reminder_DateTime__c,
                                              Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c, Project_Roster_Role__c,
                                              Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c, App_Status__c, Sign_Off_Status__c,
                                              Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Project_Roster__r.Contact__c,
                                              Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c,
                                              Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c,
                                                  (SELECT Name, Send_Via__c, Sent__c, Received__c, Sent_to__c, RFI_Scope__c, Submit_Type__c FROM Monitor_RFI_Scopes__r)
                                       FROM RFI_Scope__c
                                       WHERE Project__c =: projectId AND RecordType.Name =: RECORD_TYPE_NAME_STANDARD AND Application_Service_Item__c =: serviceId]);
    }
    
    public static String getRFIScopesCommonFieldsQuery(){
        return 'SELECT Id, Project__c, Region__c, Region__r.Id, RFI_Section__c, Selected__c, Status__c, Project_Roster__r.Contact__c, ' + 
                'Documents__c, Drawings__c, Follow_Up_Alert__c, Recipient_Reminder__c, Follow_Up_Alert_DateTime__c, RecordTypeId, ' + 
                'Recipient_Reminder_DateTime__c, Project_Roster__c, Project_Roster__r.Email__c, Project_Roster__r.Contact_Full_Name__c, ' + 
                'Project_Roster_Role__c, Roster_to_CC__c, Project_Roster_to_CC__c, Notes__c, Name, Last_RFI_Sent__c, Last_RFI_Received__c, ' + 
                'Project_Level_RFI__c, Submit_Sign_Off__c, Submit_Application__c, Sign_Off_Second_Service_Item__c, Sign_Off_Second_Service_Item__r.Name, Sign_Off_Second_Service_Item__r.Service_Name_Full__c, ' + 
                'Is_Sigh_Off_N_A__c, Is_Application_N_A__c, Sign_Off_Service_Item__c, Application_Service_Item__c, Group_Number__c, Email_Address_For_Submit_Notification__c, ' + 
                'Application_Work_Permit_Service_Item__c, Last_SignOff_RFI_Received__c, Last_SignOff_RFI_Sent__c, Proposal_Id__c, Sign_Off_Third_Service_Item__c, ' + 
                'Sign_Off_Service_Item__r.Name_Short__c, Sign_Off_Service_Item__r.Service_Name_Full__c, Sign_Off_Service_Item__r.Name, Sign_Off_Third_Service_Item__r.Name, ' + 
                'Application_Work_Permit_Service_Item__r.Name_Short__c, Application_Work_Permit_Service_Item__r.Service_Name_Full__c, Sign_Off_Third_Service_Item__r.Service_Name_Full__c, ' + 
                'Application_Work_Permit_Service_Item__r.Name, Application_Service_Item__r.Name_Short__c, Application_Service_Item__r.Service_Name_Full__c, ' + 
                'Application_Service_Item__r.Name, Sign_Off_Service_Item__r.Work_Type__c, Application_Work_Permit_Service_Item__r.Work_Type__c, Application_Service_Item__r.Work_Type__c, ' + 
                '(SELECT Name, Actual_Costs__c, Application_Service_Item__c, Estimated_Cost__c, RFI_Scope__c, Sign_Off_Service_Item__c, Filing_Fee__c FROM RFI_Work_Types__r),';
    }

    public static String getRFIScopesMonitorRelatedListQuery(){
        return ' (SELECT Name, Send_Via__c, Sent__c, Received__c, Sent_to__c, RFI_Scope__c, Submit_Type__c, Is_Lock__c FROM Monitor_RFI_Scopes__r ORDER BY Sent__c DESC)';
    }

    public static String getRFIScopesMonitorRelatedListByKeyQuery( String monitorKey ){
        return ' (SELECT Send_Via__c, Received__c, Is_Lock__c, Submit_Type__c FROM Monitor_RFI_Scopes__r WHERE Is_Lock__c = false AND Key__c = ' + '\'' + monitorKey + '\'' + ')';
    }

    public static String getRFIScopesWhereQuery( String rfiScopeId, String recordTypeName){
        return ' FROM RFI_Scope__c WHERE Id = ' + '\'' + rfiScopeId + '\'' + ' AND RecordType.Name = ' + '\'' + recordTypeName + '\'';
    }

    public static String getRFIScopesWhereForSetQuery( Set<Id> rfiIds, String recordTypeName){
        return ' FROM RFI_Scope__c WHERE (Id = \'' + String.join( new List<Id>(rfiIds), '\' OR Id = \'') + '\'' + ')' + ' AND RecordType.Name = ' + '\'' + recordTypeName + '\'';
    }

    @TestVisible
    private static String getQueryForRFIScopesById(Id rfiScopeId, String regionName){
        String query = getRFIScopesCommonFieldsQuery();
        query += getRFIScopesMonitorRelatedListQuery();
        
        if (regionName.equals(RegionServices.REGION_NAME_NY)) {
            query += RFIDescriptionNYServices.nyRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_LI)) {
            query += RFIDescriptionLIServices.liRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_CT) ||
                    regionName.equals(RegionServices.REGION_NAME_WESTCHESTER) || 
                    regionName.equals(RegionServices.REGION_NAME_MASSACHUSETTS)) {
            query += RFIDescriptionCTServices.ctRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_NJ)) {
            query += RFIDescriptionNJServices.njRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_DE) ||
                    regionName.equals(RegionServices.REGION_NAME_MD) || 
                    regionName.equals(RegionServices.REGION_NAME_PENN)) {
            query += RFIDescriptionPAServices.paRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_WASH)||
            regionName.equals(RegionServices.REGION_NAME_VIRGINIA) ) {
            query += RFIDescriptionDCServices.dcRegionFieldsQuery();
        
        }
        query += getRFIScopesWhereQuery( rfiScopeId, RECORD_TYPE_NAME_STANDARD);
        
        return query;
    }

    @TestVisible
    private static String getQueryForRFIScopesByProjectIdAndRosterId(Set<Id> rfiIds, String monitorKey, String regionName) {
        String query = getRFIScopesCommonFieldsQuery();
        query += getRFIScopesMonitorRelatedListByKeyQuery( monitorKey );
        
        if (regionName.equals(RegionServices.REGION_NAME_NY)) {
            query += RFIDescriptionNYServices.nyRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_LI)) {
            query += RFIDescriptionLIServices.liRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_CT) ||
                    regionName.equals(RegionServices.REGION_NAME_WESTCHESTER) || 
                    regionName.equals(RegionServices.REGION_NAME_MASSACHUSETTS)) {
            query += RFIDescriptionCTServices.ctRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_NJ)) {
            query += RFIDescriptionNJServices.njRegionFieldsQuery();
        
        } else if (regionName.equals(RegionServices.REGION_NAME_DE) ||
                   regionName.equals(RegionServices.REGION_NAME_MD) || 
                   regionName.equals(RegionServices.REGION_NAME_PENN)) {
            query += RFIDescriptionPAServices.paRegionFieldsQuery();
            
        } else if (regionName.equals(RegionServices.REGION_NAME_WASH) ||
            regionName.equals(RegionServices.REGION_NAME_VIRGINIA) ) {
            query += RFIDescriptionDCServices.dcRegionFieldsQuery();
        
        }
        query += getRFIScopesWhereForSetQuery( rfiIds, RECORD_TYPE_NAME_STANDARD);
        return query;
    
    }

    public static RFI_Scope__c getRFIScopesById(Id rfiScopeId, String regionName) {
        if (String.isBlank(rfiScopeId)) {
            throw new ErrorException(ErrorException.RFI_SCOPE_ID_CANNOT_BE_EMPTY);
        
        }

        List<RFI_Scope__c> rfiScopes = new List<RFI_Scope__c>();
        try {
            rfiScopes = Database.query(getQueryForRFIScopesById(rfiScopeId, regionName));
        
        } catch( Exception ex ) {
            throw new ErrorException(ErrorException.BAD_QUERY);
        
        }

        if (rfiScopes.isEmpty()) {
            throw new ErrorException(ErrorException.RFI_SCOPE_NOT_EXIST );
        
        }
        return rfiScopes.get(0);

    }

    public static List<RFI_Scope__c> getProjectRFIScopesByProjectIdAndRosterId(Set<Id> rfiIds, String monitorKey, String regionName) {
        if (rfiIds.isEmpty()) {
            throw new ErrorException(ErrorException.RFI_SCOPE_ID_CANNOT_BE_EMPTY);
        
        }
        
        List<RFI_Scope__c> rfiScopes = new List<RFI_Scope__c>();
        try {
            String query = getQueryForRFIScopesByProjectIdAndRosterId(rfiIds, monitorKey, regionName);
            rfiScopes = Database.query(query);
        
        } catch( Exception ex ) {
            throw new ErrorException(ErrorException.BAD_QUERY);
        
        }

        return rfiScopes;
    }
    
    public static RFI_Scope__c getRFIScopeById(Id rfiScopeId) {
        List<RFI_Scope__c> rfiScopeList = new List<RFI_Scope__c>([SELECT Proposal_Id__c, Id, Project__c, Project__r.Building__c, Project__r.Proposal__c
                                                                  FROM RFI_Scope__c 
                                                                  WHERE id =: rfiScopeId]);
        
        RFI_Scope__c rfiScope = new RFI_Scope__c();
        if(rfiScopeList.size() > 0) {
           rfiScope = rfiScopeList.get(0);
        
        }
        return rfiScope;
    
    }
    //---------------------------------------------------- End DAO Methods -----------------------------------------------------------------------------------------------------------------//
}