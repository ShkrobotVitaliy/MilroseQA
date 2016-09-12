public with sharing class CFRController {

    public String renderAs { get; set; }
    public Project_Profile__c parent { get; private set; }
    public String parentInvoiceId { get; private set; }
    public Boolean isValid { get; private set; }
    public Boolean isSignOff { get; set; }
    public Boolean isSingleProject { get; set; }
    public Boolean isSinglePhaseProject { get; set; }
    public Boolean isManyProjects { get; set; }

    private String queryWhere;

    public String milroseLogoIdExternalUrl { get { return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + milroseLogoId + '&oid=' + UserInfo.getOrganizationId(); } }
    public String milroseLogoId {
        get {
            if( milroseLogoId == null ) {
                List<Document> docs = [ SELECT Id FROM Document WHERE DeveloperName = : MilroseDevHelper.MILROSE_LOGO_DOCUMENT_DEVELOPER_NAME ];
                if( !docs.isEmpty() ) {
                    milroseLogoId = docs[0].Id;
                } else {
                    milroseLogoId = '';
                }
            }
            return milroseLogoId;
        }
        set;
    }
    public Proposal__c baseProposal { get; set; }

    public List<Project_Profile__c> selectedProjectsList {
        get {
            if( selectedProjectsList == null) selectedProjectsList = new List<Project_Profile__c>();
            return selectedProjectsList;
        }
        set;
    }

    public List<Project_Profile__c> selectedServiceItems {
        get {
            if( selectedServiceItems == null) selectedServiceItems = new List<Project_Profile__c>();
            return selectedServiceItems;
        }
        set;
    }

    public Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>> projectIdToServiceGroupNumberToServiceItemsForTable {
        get {
            if( projectIdToServiceGroupNumberToServiceItemsForTable == null) projectIdToServiceGroupNumberToServiceItemsForTable = new Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>>();
            return projectIdToServiceGroupNumberToServiceItemsForTable;
        }
        set;
    }

    public Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>> projectIdToServiceGroupNumberToServiceItemsForCalculation {
        get {
            if( projectIdToServiceGroupNumberToServiceItemsForCalculation == null) projectIdToServiceGroupNumberToServiceItemsForCalculation = new Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>>();
            return projectIdToServiceGroupNumberToServiceItemsForCalculation;
        }
        set;
    }

    public Map<Id, Map<Decimal, Task_Item__c>> projectIdToPickupAnalyzeTask {
        get {
            if( projectIdToPickupAnalyzeTask == null) projectIdToPickupAnalyzeTask = new Map<Id, Map<Decimal, Task_Item__c>>();
            return projectIdToPickupAnalyzeTask;
        }
        set;
    }

    public Map<Id, Map<Decimal, Task_Item__c>> projectIdToTrackFormProcessingTask {
        get {
            if( projectIdToTrackFormProcessingTask == null) projectIdToTrackFormProcessingTask = new Map<Id, Map<Decimal, Task_Item__c>>();
            return projectIdToTrackFormProcessingTask;
        }
        set;
    }

    public Map<Id, String> projectIdToContactAccountName {
        get {
            if( projectIdToContactAccountName == null) projectIdToContactAccountName = new Map<Id, String>();
            return projectIdToContactAccountName;
        }
        set;
    }
    public Map<Id, Project_Profile__c> selectedProjectsMap { get; set; }
    public Map<Id, List<Form_Assignment__c>> idServiceToFormItemList { get{ if( idServiceToFormItemList == null) idServiceToFormItemList = new Map<Id, List<Form_Assignment__c>>(); return idServiceToFormItemList;} set; }

    public List<level1> level1List {
        get {
            if( level1List == null) level1List = new List<level1>();
            return level1List ;
        }
        set;}

    public Set<String> serviceRequirmentsTypes;

    private static Set<String> serviceItemFieldSet{
        get{
            if ( serviceItemFieldSet == null ){
                serviceItemFieldSet = new Set<String>();

                for ( Schema.SObjectField sif : Schema.getGlobalDescribe().get('Service_Item__c').getDescribe().Fields.getMap().values() ){

                    String fieldAPI = sif.getDescribe().getName();

                    if ( fieldAPI.endsWithIgnoreCase('_Drawings_Received__c') || fieldAPI.endsWithIgnoreCase('_Drawings_Request__c') ){
                        serviceItemFieldSet.add( ( ( fieldAPI.removeEndIgnoreCase('_Drawings_Received__c') ).removeEndIgnoreCase('_Drawings_Request__c') ).replace('_',' ') );
                    }
                }
            }
            return serviceItemFieldSet;
        }
        set;
    }

    public CFRController() {
        String projectFilter = ApexPages.currentPage().getParameters().get('p1').substringAfter('_');
        String primaryCompanyFilter = ApexPages.currentPage().getParameters().get('p3').substringAfter('_');
        String buildingFilter = ApexPages.currentPage().getParameters().get('p2').substringAfter('_');
        String billingCompanyFilter = ApexPages.currentPage().getParameters().get('p4').substringAfter('_');
        String accountingCompanyFilter = ApexPages.currentPage().getParameters().get('p5').substringAfter('_');
        String signOffParameter = ApexPages.currentPage().getParameters().get('p6');
		String teamFilter = ApexPages.currentPage().getParameters().get('p7').substringAfter('_'); //MRS 6865
		String multipleProjectFilter = ApexPages.currentPage().getParameters().get('p8').substringAfter('_');

        isSignOff = !String.isEmpty(signOffParameter) && Boolean.valueOf( signOffParameter );
        isSingleProject = !String.isEmpty(projectFilter);

        Set<Id> validProjectIds = new Set<Id>();
        queryWhere = buildQueryWhere( projectFilter, multipleProjectFilter, primaryCompanyFilter, buildingFilter, billingCompanyFilter, accountingCompanyFilter, teamFilter); //MRS 6865
        selectedProjectsList = Database.query(buildQuery( queryWhere ));
        selectedProjectsMap = new Map<Id, Project_Profile__c>( selectedProjectsList );

        isSinglePhaseProject = isSingleProject && (projectFilter instanceof Id) && selectedProjectsMap.containsKey( projectFilter ) && !selectedProjectsMap.get( projectFilter ).Proposal__r.isPhase__c;
        isManyProjects = selectedProjectsList.size() > 1; //MRS 6865

        List<Service_Item__c> selectedServiceItemsByCategory = [ SELECT Project_Profile__r.Project_Name__c, Project_Profile__r.Name, Project_Profile__r.Floor_s__c, Proposal__r.isPhase__c,
                                                            Name, Project_Profile__c, Service_Group__c, Municipal_Agency_ID__c, Work_Type__c, Type__c, Category__c, Phase__c,
                                                            Asbestos_Received__c, Asbestos_Requested__c, Boiler_Replacement_Drawings_Request__c, Boiler_Replacement_Drawings_Received__c,
                                                            Boiler_Drawings_Request__c, Boiler_Drawings_Received__c, Builders_Pavement_Plan_Drawings_Request__c, Phase__r.Number__c,
                                                            Builders_Pavement_Plan_Drawings_Received__c, Generator_Drawings_Request__c, Generator_Drawings_Received__c,
                                                            Fire_Alarm_Drawings_Request__c, Fire_Alarm_Drawings_Received__c, Fuel_Storage_Drawings_Request__c,
                                                            Fuel_Storage_Drawings_Received__c, Mechanical_Drawings_Request__c, Mechanical_Drawings_Received__c,
                                                            General_Construction_Drawings_Request__c, General_Construction_Drawings_Received__c, Place_of_Assembly_Drawings_Request__c,
                                                            Place_of_Assembly_Drawings_Received__c, Plumbing_Drawings_Request__c, Plumbing_Drawings_Received__c, Sprinkler_Drawings_Request__c,
                                                            Sprinkler_Drawings_Received__c, Standpipe_Drawings_Request__c, Standpipe_Drawings_Received__c, Structural_Drawings_Request__c,
                                                            Structural_Drawings_Received__c, Subtype__c, Floor__c, Phase__r.Name__c,
                                                            (Select Id, Name, Actual_End_Date__c From Task_Items__r Where Actual_End_Date__c != null ),
                                                            (Select Id, Name, MAX_Form_Assignment_Received_Date__c,
                                                                MIN_Form_Assignment_Sent_Date__c, Recipient_Role_Text__c From Form_Items__r)
                                                     FROM Service_Item__c
                                                     WHERE Project_Profile__c IN: selectedProjectsList AND
                                                        ( Category__c = 'Amendment-Application Filing' OR
                                                          Category__c =: ServiceItemServices.CATEGORY_APPLICATION_FILING OR
                                                          Category__c = 'Application Signoff' OR
                                                          Type__c = 'Asbestos Assessment' ) AND
                                                        Service_Group__c != null AND
                                                        Is_Amendmend_Deleted__c = false
                                                     Order by Phase__r.Number__c ASC, Municipal_Agency_ID__c ASC];

        List<Service_Item__c> selectedServiceItemsByCategoryForTable = new List<Service_Item__c>();
        Map<Id, Map<Id, Phase__c>> projectWithPhaseMap = new Map<Id, Map<Id, Phase__c>>();

        for( Service_Item__c serviceItem: selectedServiceItemsByCategory ){
            system.debug(LoggingLevel.error, '@serviceItem= ' +serviceItem);
            if( ( serviceItem.Type__c == ServiceItemServices.TYPE_PLAN_APPROVAL || serviceItem.Type__c == ServiceItemServices.TYPE_CERTIFICATE_OF_OPERATION ) &&
                serviceItem.Category__c == ServiceItemServices.CATEGORY_APPLICATION_FILING ){
                validProjectIds.add( serviceItem.Project_Profile__c );
                selectedServiceItemsByCategoryForTable.add( serviceItem );
                system.debug(LoggingLevel.error, '@serviceItem= ' +serviceItem);
                if( !projectIdToServiceGroupNumberToServiceItemsForTable.containsKey( serviceItem.Project_Profile__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForTable.put( serviceItem.Project_Profile__c, new Map<Id, Map<Decimal, List<Service_Item__c>>>());
                }
                if( !projectIdToServiceGroupNumberToServiceItemsForTable.get( serviceItem.Project_Profile__c ).containsKey( serviceItem.Phase__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForTable.get( serviceItem.Project_Profile__c ).put( serviceItem.Phase__c, new Map<Decimal, List<Service_Item__c>>());
                }
                if( !projectIdToServiceGroupNumberToServiceItemsForTable.get( serviceItem.Project_Profile__c ).get( serviceItem.Phase__c ).containsKey( serviceItem.Service_Group__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForTable.get( serviceItem.Project_Profile__c ).get( serviceItem.Phase__c ).put( serviceItem.Service_Group__c, new List<Service_Item__c>());
                }
                projectIdToServiceGroupNumberToServiceItemsForTable.get( serviceItem.Project_Profile__c ).get( serviceItem.Phase__c ).get( serviceItem.Service_Group__c ).add( serviceItem );
                
                if ( !projectWithPhaseMap.containsKey( serviceItem.Project_Profile__c ) ){
                    projectWithPhaseMap.put( serviceItem.Project_Profile__c, new Map<Id, Phase__c>() );
                }
                projectWithPhaseMap.get( serviceItem.Project_Profile__c).put(serviceItem.Phase__c, new Phase__c(Id = serviceItem.Phase__c, Name__c = serviceItem.Phase__r.Name__c));
            }else{system.debug(LoggingLevel.error, '@serviceItem= ' +serviceItem);
                if( !projectIdToServiceGroupNumberToServiceItemsForCalculation.containsKey( serviceItem.Project_Profile__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForCalculation.put( serviceItem.Project_Profile__c, new Map<Id, Map<Decimal, List<Service_Item__c>>>() );
                }
                if( !projectIdToServiceGroupNumberToServiceItemsForCalculation.get( serviceItem.Project_Profile__c ).containsKey( serviceItem.Phase__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForCalculation.get( serviceItem.Project_Profile__c ).put( serviceItem.Phase__c, new Map<Decimal, List<Service_Item__c>>());
                }
                if( !projectIdToServiceGroupNumberToServiceItemsForCalculation.get( serviceItem.Project_Profile__c ).get(serviceItem.Phase__c).containsKey( serviceItem.Service_Group__c ) ){
                    projectIdToServiceGroupNumberToServiceItemsForCalculation.get( serviceItem.Project_Profile__c ).get(serviceItem.Phase__c).put( serviceItem.Service_Group__c, new List<Service_Item__c>());
                }
                projectIdToServiceGroupNumberToServiceItemsForCalculation.get( serviceItem.Project_Profile__c ).get(serviceItem.Phase__c).get( serviceItem.Service_Group__c ).add( serviceItem );
            }
        }

        for( Form_Item__c formItem: [Select Id, Name, MAX_Form_Assignment_Received_Date__c,
                                            MIN_Form_Assignment_Sent_Date__c,
                                                (Select Id, Name, Recipient_Role__r.Role__c From Form_Assignments__r )
                                     From Form_Item__c
                                     Where Service_Item__c IN: selectedServiceItemsByCategoryForTable ] ){
            idServiceToFormItemList.put( formItem.Id, formItem.Form_Assignments__r );
        }
        Set<String> taskNames = new Set<String>{ 'Track Form Processing through Authority', 'Pickup/Analyze Artifacts from Authority' };
        for( Task_Item__c item: [Select Id, Name, Project_Profile__c, Actual_End_Date__c, Service_Item__c, Service_Item__r.Type__c, Service_Item__r.Category__c, Service_Item__r.Service_Group__c, Status__c
                                    From Task_Item__c
                                    Where Service_Item__c IN: selectedServiceItemsByCategory
                                        AND Actual_End_Date__c != null
                                        AND Status__c != null
                                        AND Name IN: taskNames] ){

            if( item.Name == 'Pickup/Analyze Artifacts from Authority' ){
                if( !projectIdToPickupAnalyzeTask.containsKey( item.Project_Profile__c ) ){
                    projectIdToPickupAnalyzeTask.put( item.Project_Profile__c, new Map<Decimal, Task_Item__c>() );
                }
                if( !projectIdToPickupAnalyzeTask.get( item.Project_Profile__c).containsKey( item.Service_Item__r.Service_Group__c ) ) {
                    projectIdToPickupAnalyzeTask.get( item.Project_Profile__c ).put( item.Service_Item__r.Service_Group__c, new Task_Item__c());
                }
                if( projectIdToPickupAnalyzeTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Actual_End_Date__c == null ||
                                                    ( projectIdToPickupAnalyzeTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Actual_End_Date__c > item.Actual_End_Date__c ||
                                                      ( item.Status__c != 'Approved' &&
                                                        projectIdToPickupAnalyzeTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Status__c != item.Status__c ) ) ){
                    projectIdToPickupAnalyzeTask.get( item.Project_Profile__c).put( item.Service_Item__r.Service_Group__c, item);
                }
            }else if( item.Name == 'Track Form Processing through Authority' ){
                if( !projectIdToTrackFormProcessingTask.containsKey( item.Project_Profile__c ) ){
                    projectIdToTrackFormProcessingTask.put( item.Project_Profile__c, new Map<Decimal, Task_Item__c>() );
                }
                if( !projectIdToTrackFormProcessingTask.get( item.Project_Profile__c).containsKey( item.Service_Item__r.Service_Group__c ) ) {
                    projectIdToTrackFormProcessingTask.get( item.Project_Profile__c ).put( item.Service_Item__r.Service_Group__c, new Task_Item__c());
                }
                if( projectIdToTrackFormProcessingTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Actual_End_Date__c == null ||
                                                    ( projectIdToTrackFormProcessingTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Actual_End_Date__c > item.Actual_End_Date__c ||
                                                      ( item.Status__c != 'Response Received' &&
                                                        projectIdToTrackFormProcessingTask.get( item.Project_Profile__c).get( item.Service_Item__r.Service_Group__c).Status__c != item.Status__c ) ) ){
                    projectIdToTrackFormProcessingTask.get( item.Project_Profile__c).put( item.Service_Item__r.Service_Group__c, item);
                }
            }
        }

        serviceRequirmentsTypes = new Set<String>();
        for( Service_Requirements__c item: Service_Requirements__c.getall().values() ){
            serviceRequirmentsTypes.add(item.Work_Type__c);
        }

        Integer iterator = 1;
        for( Project_Profile__c item: selectedProjectsList ){
            if( validProjectIds.contains( item.Id ) ){
                level1List.add( new level1( iterator++,
                                            item.Id,
                                            selectedProjectsMap,
                                            projectIdToServiceGroupNumberToServiceItemsForTable,
                                            projectIdToServiceGroupNumberToServiceItemsForCalculation,
                                            projectIdToPickupAnalyzeTask,
                                            projectIdToTrackFormProcessingTask,
                                            idServiceToFormItemList,
                                            serviceRequirmentsTypes,
                                            projectWithPhaseMap.get(item.Id) ) );
            }
        }
    }

    //General Wrapper
    public class level1 {
        public Integer level1Size { get{ if ( level1Size == null ) level1Size = 0; return level1Size; } set; }
        public Integer level1Rowspan { get{ if ( level1Rowspan == null ) level1Rowspan = 1; return level1Rowspan ; } set; }
        public Integer itemNumber { get ; set; }
        public Project_Profile__c currentProject { get ; set; }
        public List<level2phase> level2phaseList { get { if ( level2phaseList == null ) level2phaseList = new List<level2phase>(); return level2phaseList ; } set;}
        public level1( Integer iterator, Id currentProjectId,
                       Map<Id, Project_Profile__c> selectedProjectsMap,
                       Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>> projectIdToServiceGroupNumberToServiceItemsForTable,
                       Map<Id, Map<Id, Map<Decimal, List<Service_Item__c>>>> projectIdToServiceGroupNumberToServiceItemsForCalculation,
                       Map<Id, Map<Decimal, Task_Item__c>> projectIdToPickupAnalyzeTask,
                       Map<Id, Map<Decimal, Task_Item__c>> projectIdToTrackFormProcessingTask,
                       Map<Id, List<Form_Assignment__c>> idServiceToFormItemList,
                       Set<String> serviceRequirmentsTypes,
                       Map<Id, Phase__c> phaseMap) {
            this.itemNumber = iterator;
            currentProject = selectedProjectsMap.get( currentProjectId );

            Map<Id, Map<Decimal, List<Service_Item__c>>> projectServiceGroupNumberToServiceItemsTable = projectIdToServiceGroupNumberToServiceItemsForTable.containsKey( currentProjectId ) ?
                                                                                                                    projectIdToServiceGroupNumberToServiceItemsForTable.get( currentProjectId ) :
                                                                                                                    new Map<Id, Map<Decimal, List<Service_Item__c>>>();
            Map<Id, Map<Decimal, List<Service_Item__c>>> projectServiceGroupNumberToServiceItemsCalculation = projectIdToServiceGroupNumberToServiceItemsForCalculation.containsKey( currentProjectId ) ?
                                                                                                                    projectIdToServiceGroupNumberToServiceItemsForCalculation.get( currentProjectId ) :
                                                                                                                    new Map<Id, Map<Decimal, List<Service_Item__c>>>();

            Integer phaseNumber = 1;

            for ( Phase__c phaseItem : phaseMap.values() ){

                Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsTable = projectServiceGroupNumberToServiceItemsTable.get(phaseItem.Id);
                Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsCalculation = projectServiceGroupNumberToServiceItemsCalculation.get(phaseItem.Id);

                if( serviceGroupNumberToServiceItemsTable != null && !serviceGroupNumberToServiceItemsTable.isEmpty() ){

                    level2phaseList.add( new level2phase( currentProjectId,
                                                          phaseNumber++,
                                                          serviceGroupNumberToServiceItemsTable,
                                                          serviceGroupNumberToServiceItemsCalculation,
                                                          projectIdToPickupAnalyzeTask,
                                                          projectIdToTrackFormProcessingTask,
                                                          selectedProjectsMap,
                                                          idServiceToFormItemList,
                                                          serviceRequirmentsTypes,
                                                          phaseItem.Name__c ) );

                }
            }

            this.level1Rowspan = phaseNumber;

            for( level2phase item: level2phaseList ){
                level1Size += item.level2phaseSize;
                system.debug(LoggingLevel.error, '@level1Rowspan/level1Size= ' +level1Rowspan+' '+level1Size);
            }
        }
    }

    //Phase Wrapper
    public class level2phase {
        public Integer level2phaseSize { get{ if ( level2phaseSize == null ) level2phaseSize = 0; return level2phaseSize ; } set; }
        public Integer level2phaseRowspan { get{ if ( level2phaseRowspan == null ) level2phaseRowspan = 1; return level2phaseRowspan; } set; }
        public Project_Profile__c currentProject { get ; set; }
        public List<level2> level2List { get { if ( level2List == null ) level2List = new List<level2>(); return level2List ; } set;}
        public String phase { get{ if ( phase == null ) phase = ''; return phase ; } set; }
        public String serviceFloors{ get{ if ( serviceFloors == null ) serviceFloors = ''; return serviceFloors ; } set; }

        public level2phase( Id currentProjectId,
                            Integer phaseNumber,
                            Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsTable,
                            Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsCalculation,
                            Map<Id, Map<Decimal, Task_Item__c>> projectIdToPickupAnalyzeTask,
                            Map<Id, Map<Decimal, Task_Item__c>> projectIdToTrackFormProcessingTask,
                            Map<Id, Project_Profile__c> selectedProjectsMap,
                            Map<Id, List<Form_Assignment__c>> idServiceToFormItemList,
                            Set<String> serviceRequirmentsTypes,
                            String phaseName ) {
            this.phase = phaseName;
            this.level2phaseRowspan = phaseNumber;

            Integer serviceGroupNumber = 1;

            if( serviceGroupNumberToServiceItemsTable != null && !serviceGroupNumberToServiceItemsTable.isEmpty() ){


                List<Decimal> sortList = new List<Decimal>();
                for( Decimal item: serviceGroupNumberToServiceItemsTable.keySet() ){
                     sortList.add(item);
                }

                sortList.sort();
                for( Decimal item: sortList ){

                    level2List.add( new level2( currentProjectId,
                                                serviceGroupNumber++,
                                                item,
                                                serviceGroupNumberToServiceItemsTable,
                                                serviceGroupNumberToServiceItemsCalculation,
                                                projectIdToPickupAnalyzeTask,
                                                projectIdToTrackFormProcessingTask,
                                                selectedProjectsMap,
                                                idServiceToFormItemList,
                                                serviceRequirmentsTypes ) );

                }
            }

            Set<String> stringSet = new Set<String>();
            String floorString = '';

            for( level2 item: level2List ){
                level2phaseSize += item.level2Size;
                system.debug(LoggingLevel.error, '@level2phaseRowspan/level2phaseSize = ' +level2phaseRowspan+' '+level2phaseSize);
                for (level3 level3Item : item.level3List){
                    if (level3Item.serviceFloors != null ) floorString += level3Item.serviceFloors + ';';
                }
            }

            for (String s : floorString.split (';') ){
                stringSet.add(s);
            }
            List<String> floorList = new List<String>();
            floorList.addAll(stringSet);
            this.serviceFloors = String.join(floorList, ';');
        }
    }

    //Service Group Wrapper
    public class level2 {
        public Integer level2Size { get{ if ( level2Size == null ) level2Size = 0; return level2Size ; } set; }
        public Integer level2Rowspan { get{ if ( level2Rowspan == null ) level2Rowspan = 1; return level2Rowspan; } set; }
        public Project_Profile__c currentProject { get ; set; }
        public List<level3> level3List { get { if ( level3List == null ) level3List = new List<level3>(); return level3List ; } set;}

        public level2( Id currentProjectId, Integer serviceGroupNumber, Decimal serviceGroupKey, Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsTable,
                       Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsCalculation, Map<Id, Map<Decimal, Task_Item__c>> projectIdToPickupAnalyzeTask,
                       Map<Id, Map<Decimal, Task_Item__c>> projectIdToTrackFormProcessingTask, Map<Id, Project_Profile__c> selectedProjectsMap,
                       Map<Id, List<Form_Assignment__c>> idServiceToFormItemList, Set<String> serviceRequirmentsTypes ) {

            this.level2Rowspan = serviceGroupNumber;

            Integer i = 1;
            level3List.add( new level3( currentProjectId,
                                        serviceGroupKey,
                                        serviceGroupNumberToServiceItemsTable,
                                        serviceGroupNumberToServiceItemsCalculation,
                                        projectIdToPickupAnalyzeTask,
                                        projectIdToTrackFormProcessingTask,
                                        selectedProjectsMap,
                                        idServiceToFormItemList,
                                        i++,
                                        serviceRequirmentsTypes ) );

            for( level3 item: level3List ){
                level2Size += item.level3Size;
            }

            system.debug(LoggingLevel.error, '@level2Rowspan/level2Size= ' +level2Rowspan+' '+level2Size);
        }

    }

    //Service Wrapper
    public class level3 {
        public Integer level3Size { get{ if ( level3Size == null ) level3Size = 0; return level3Size ; } set; }
        public Integer level3Rowspan { get{ if ( level3Rowspan == null ) level3Rowspan = 1; return level3Rowspan; } set; }

        public Integer serviceGroupKey { get ; set; }
        public String serviceFloors { get ; set; }
        public String applicationType { get ; set; }
        public Date RFIReceived { get ; set; }
        public Date applicantFormSent { get ; set; }
        public Date applicantFormReceived { get ; set; }
        public Date ownerFormSent { get ; set; }
        public Date ownerFormReceived { get ; set; }
        public Date asbestosReceived { get ; set; }
//        public Date asbestosRequested { get ; set; }
        public Date tenantsFormsSent { get ; set; }
        public Date tenantsFormsReceived { get ; set; }
        public Date dateFilled { get ; set; }
        public String DOBNumber { get ; set; }
        public String DOBStatus { get ; set; }

        public Set<String> workType { get { if ( workType == null ) workType = new Set<String>(); return workType ; } set;}
        public Map<String, Date> workTypeToDrawingsReceived { get { if ( workTypeToDrawingsReceived == null ) workTypeToDrawingsReceived = new Map<String, Date>(); return workTypeToDrawingsReceived ; } set;}
//        public Map<String, Date> workTypeToDrawingsRequested { get { if ( workTypeToDrawingsRequested == null ) workTypeToDrawingsRequested = new Map<String, Date>(); return workTypeToDrawingsRequested ; } set;}
        public String generalContractor { get ; set; }

        public List<level4> level4List { get { if ( level4List == null ) level4List = new List<level4>(); return level4List ; } set;}

        public level3( Id currentProjectId, Decimal serviceGroupKey, Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsTable, Map<Decimal, List<Service_Item__c>> serviceGroupNumberToServiceItemsCalculation, Map<Id, Map<Decimal, Task_Item__c>> projectIdToPickupAnalyzeTask, Map<Id, Map<Decimal, Task_Item__c>> projectIdToTrackFormProcessingTask, Map<Id, Project_Profile__c> selectedProjectsMap, Map<Id, List<Form_Assignment__c>> idServiceToFormItemList, Integer k, Set<String> serviceRequirmentsTypes ) {
            this.level3Rowspan = k;
            Boolean asbestosReceivedSILevel = false;
            system.debug(LoggingLevel.error, '@serviceGroupKey= ' +serviceGroupKey);
            if(serviceGroupNumberToServiceItemsTable != null && serviceGroupKey != null){
                List<Service_Item__c> currentServiceItemsTable = serviceGroupNumberToServiceItemsTable.get( serviceGroupKey );
                system.debug(LoggingLevel.error, '@currentServiceItemsTable = ' +currentServiceItemsTable );
                if( serviceGroupNumberToServiceItemsCalculation != null ){
                    List<Service_Item__c> currentServiceItemsCalculation = serviceGroupNumberToServiceItemsCalculation.get( serviceGroupKey );

                    if( currentServiceItemsCalculation != null ){

                        for( Service_Item__c serviceItem: currentServiceItemsCalculation ){
                            if( serviceItem.Type__c == 'Asbestos Assessment' ){

                                for( Task_Item__c taskItem: serviceItem.Task_Items__r ){
                                    if( taskItem.Name == 'Request/Assign Vendor Activity' && ( asbestosReceived == null || taskItem.Actual_End_Date__c > asbestosReceived ) ){
                                        if( taskItem.Actual_End_Date__c != null )asbestosReceived = date.newinstance(taskItem.Actual_End_Date__c.year(), taskItem.Actual_End_Date__c.month(), taskItem.Actual_End_Date__c.day());
                                        asbestosReceivedSILevel = true;
                                    }
                                }

                            }
                        }
                    }
                }

                for( Service_Item__c serviceItem: currentServiceItemsTable ){
                    if( serviceItem.Type__c == 'Plan Approval' || serviceItem.Type__c == 'Certificate of Operation' ){

                        if( serviceFloors == null ) serviceFloors = '';
                        if( !serviceFloors.contains( serviceItem.Floor__c ) ) serviceFloors += serviceItem.Floor__c + ';';

                        if( applicationType == null ) applicationType = '';
                        if( !applicationType.contains( serviceItem.Subtype__c ) ) applicationType += serviceItem.Subtype__c + ';';
/*
                        if( asbestosRequested == null || serviceItem.Asbestos_Requested__c > asbestosRequested ) {
                            if( serviceItem.Asbestos_Requested__c != null ) asbestosRequested = date.newinstance(serviceItem.Asbestos_Requested__c.year(), serviceItem.Asbestos_Requested__c.month(), serviceItem.Asbestos_Requested__c.day());
                        }
*/
                        if( ( asbestosReceived == null || serviceItem.Asbestos_Received__c > asbestosReceived ) && !asbestosReceivedSILevel ) {
                            if( serviceItem.Asbestos_Received__c != null ) {
                                asbestosReceived = date.newinstance(serviceItem.Asbestos_Received__c.year(), serviceItem.Asbestos_Received__c.month(), serviceItem.Asbestos_Received__c.day());
                            }
                        }

                        for( Task_Item__c taskItem: serviceItem.Task_Items__r ){
                            if( taskItem.Name == 'Request For Information' && ( RFIReceived == null || taskItem.Actual_End_Date__c > RFIReceived ) ){
                                if( taskItem.Actual_End_Date__c != null )RFIReceived = date.newinstance(taskItem.Actual_End_Date__c.year(), taskItem.Actual_End_Date__c.month(), taskItem.Actual_End_Date__c.day());
                            }
                            if( taskItem.Name == 'Submit Filing Package to Authority' && ( dateFilled == null || taskItem.Actual_End_Date__c < dateFilled ) ){
                                if( taskItem.Actual_End_Date__c != null )dateFilled = date.newinstance(taskItem.Actual_End_Date__c.year(), taskItem.Actual_End_Date__c.month(), taskItem.Actual_End_Date__c.day());
                            }
                        }
                        for( Form_Item__c formItem: serviceItem.Form_Items__r ){
                            if ( idServiceToFormItemList != null && idServiceToFormItemList.get( formItem.Id ) != null ){
                                for( Form_Assignment__c item: idServiceToFormItemList.get( formItem.Id ) ){system.debug(LoggingLevel.error, '@item= ' +item);
                                    if( item.Recipient_Role__r.Role__c != 'Building Owner Signature' ) {
                                        if ( ( applicantFormSent == null && formItem.MIN_Form_Assignment_Sent_Date__c != null) || formItem.MIN_Form_Assignment_Sent_Date__c < applicantFormSent ){
                                            applicantFormSent = date.newinstance(formItem.MIN_Form_Assignment_Sent_Date__c.year(), formItem.MIN_Form_Assignment_Sent_Date__c.month(), formItem.MIN_Form_Assignment_Sent_Date__c.day());
                                        }
                                        if ( ( applicantFormReceived == null && formItem.MAX_Form_Assignment_Received_Date__c != null) || formItem.MAX_Form_Assignment_Received_Date__c > applicantFormReceived ){
                                            applicantFormReceived = date.newinstance(formItem.MAX_Form_Assignment_Received_Date__c.year(), formItem.MAX_Form_Assignment_Received_Date__c.month(), formItem.MAX_Form_Assignment_Received_Date__c.day());
                                        }
                                    }
                                    if( item.Recipient_Role__r.Role__c == 'Building Owner Signature' ) {
                                        if ( ( ownerFormSent == null && formItem.MIN_Form_Assignment_Sent_Date__c != null) || formItem.MIN_Form_Assignment_Sent_Date__c < ownerFormSent ){
                                            ownerFormSent = date.newinstance(formItem.MIN_Form_Assignment_Sent_Date__c.year(), formItem.MIN_Form_Assignment_Sent_Date__c.month(), formItem.MIN_Form_Assignment_Sent_Date__c.day());
                                        }
                                        if ( ( ownerFormReceived == null && formItem.MAX_Form_Assignment_Received_Date__c != null) || formItem.MAX_Form_Assignment_Received_Date__c > ownerFormReceived ){
                                            ownerFormReceived = date.newinstance(formItem.MAX_Form_Assignment_Received_Date__c.year(), formItem.MAX_Form_Assignment_Received_Date__c.month(), formItem.MAX_Form_Assignment_Received_Date__c.day());
                                        }
                                    }
                                }
                            }
                        }
                        DOBNumber = serviceItem.Municipal_Agency_ID__c;
                        system.debug(LoggingLevel.error, '@serviceItem.Municipal_Agency_ID__c= ' +serviceItem.Municipal_Agency_ID__c);
                        if( serviceItem.Work_Type__c != null ){
                            for( String item: serviceItem.Work_Type__c.split(';') ){system.debug(LoggingLevel.error, '@item= ' +item);
                            system.debug(LoggingLevel.error, '@serviceItem= ' +serviceItem);
                                workType.add( item.trim() );
                                item = item.contains('OT-') ? item.substringAfter('OT-') : item;
                                if( !workTypeToDrawingsReceived.containsKey( item.trim() ) ){
                                    workTypeToDrawingsReceived.put( item.trim(), null );
                                }

                                if( serviceItemFieldSet.contains( item.trim() ) && serviceItem.get( item.trim().replace(' ','_') + '_Drawings_Received__c' ) != null ){
                                    Date tempDate = ( (DateTime)serviceItem.get( item.trim().replace(' ','_') + '_Drawings_Received__c' ) ).Date();
                                    if( workTypeToDrawingsReceived.get( item.trim() ) == null || workTypeToDrawingsReceived.get( item.trim() ) < tempDate ) {
                                        workTypeToDrawingsReceived.put( item.trim(), tempDate );
                                    }
                                }
/*
                                if( !workTypeToDrawingsRequested.containsKey( item.trim() ) ){
                                    workTypeToDrawingsRequested.put( item.trim(), null );
                                }

                                if( serviceItemFieldSet.contains( item.trim() ) && serviceItem.get( item.trim().replace(' ','_') + '_Drawings_Request__c' ) != null ){
                                    Date tempDate = ( (DateTime)serviceItem.get( item.trim().replace(' ','_') + '_Drawings_Request__c') ).Date();
                                    if ( workTypeToDrawingsRequested.get(item.trim()) == null || workTypeToDrawingsRequested.get( item.trim() ) < tempDate ) {
                                        workTypeToDrawingsRequested.put( item.trim(), tempDate );
                                    }
                                }
*/
                            }
                            system.debug(LoggingLevel.error, '@workTypeToDrawingsReceived= ' +workTypeToDrawingsReceived);
                        }
                    }
                }

                if( serviceFloors != null )  serviceFloors = serviceFloors.removeEnd(';');
                if( applicationType != null ) applicationType = applicationType.removeEnd(';');

            }

            if( projectIdToPickupAnalyzeTask != null && projectIdToPickupAnalyzeTask.get( currentProjectId ) != null ) {
                Task_Item__c taskForDOBStatus = projectIdToPickupAnalyzeTask.get( currentProjectId ).get( serviceGroupKey );
                if( taskForDOBStatus != null ){
                    Date dobDate = date.newinstance( taskForDOBStatus.Actual_End_Date__c.year(), taskForDOBStatus.Actual_End_Date__c.month(), taskForDOBStatus.Actual_End_Date__c.day() );
                    if( taskForDOBStatus.Status__c == 'Approved'){
                        if( taskForDOBStatus.Service_Item__r.Category__c == 'Application Signoff' && taskForDOBStatus.Service_Item__r.Type__c.contains('Letter Of Completion') ){
                            DOBStatus = 'Signed Off: ' + String.valueOf( dobDate );
                        }else if( taskForDOBStatus.Service_Item__r.Category__c == 'Amendment-Application Filing' && taskForDOBStatus.Service_Item__r.Type__c == 'Withdrawal' ){
                            DOBStatus = 'Withdrawn: ' + String.valueOf( dobDate );
                        }else if( taskForDOBStatus.Service_Item__r.Category__c == 'Application Filing' && taskForDOBStatus.Service_Item__r.Type__c.contains('Work Permit') ){
                            DOBStatus = 'Permit: ' + String.valueOf( dobDate );
                        }else if( taskForDOBStatus.Service_Item__r.Category__c == 'Application Filing' && taskForDOBStatus.Service_Item__r.Type__c == 'Plan Approval' ){
                            DOBStatus = 'Approved: ' + String.valueOf( dobDate );
                        }
                    } else if( taskForDOBStatus.Status__c == 'Disapproved'){
                        if( taskForDOBStatus.Service_Item__r.Category__c == 'Application Filing' && taskForDOBStatus.Service_Item__r.Type__c == 'Plan Approval' ){
                            DOBStatus = 'Disapproved: ' + String.valueOf( dobDate );
                        }
                    }
                }

            }

            if( ( DOBStatus == null || DOBStatus == 'Withdrawn: null' ) && projectIdToTrackFormProcessingTask != null && projectIdToTrackFormProcessingTask.get( currentProjectId ) != null ) {
                Task_Item__c taskForDOBStatus1 = projectIdToTrackFormProcessingTask.get( currentProjectId ).get( serviceGroupKey );
                if( taskForDOBStatus1 != null ){
                    if( taskForDOBStatus1.Status__c == 'Response Received'){
                        if( taskForDOBStatus1.Service_Item__r.Category__c == 'Amendment-Application Filing' && taskForDOBStatus1.Service_Item__r.Type__c == 'Withdrawal' ){
                            DOBStatus = 'Withdrawn: ' + String.valueOf( date.newinstance( taskForDOBStatus1.Actual_End_Date__c.year(), taskForDOBStatus1.Actual_End_Date__c.month(), taskForDOBStatus1.Actual_End_Date__c.day() ) );
                        }
                    }
                }

            }

            for( Project_Roster__c item: selectedProjectsMap.get( currentProjectId ).Project_Rosters__r){
                generalContractor = item.Contact_Account_Name__c;
            }

            Integer i = 1;
            for( String item: workType ){
                if ( serviceRequirmentsTypes.contains(item) ) level4List.add( new level4( item, i++, workTypeToDrawingsReceived.get((item.contains('OT-') ? item.substringAfter('OT-') : item))/*, workTypeToDrawingsRequested.get((item.contains('OT-') ? item.substringAfter('OT-') : item))*/ ) );
            }
            for( level4 item: level4List ){
                level3Size += item.level4Size;
            }
            if ( level4List.isEmpty() ) {
                level4List.add( new level4 ( ' ', 1, null/*, null*/ ) );
                level3Size = 1;
            }
            system.debug(LoggingLevel.error, '@level3Rowspan/level3Size= ' + level3Rowspan + ' ' + level3Size);
        }
    }

    //Set work types Wrapper
    public class level4 {
        public Integer level4Size { get{ if ( level4Size == null ) level4Size = 1; return level4Size; } set; }
        public Integer level4Rowspan { get{ if ( level4Rowspan == null ) level4Rowspan = 1; return level4Rowspan; } set; }
        public String workType { get ; set; }
        public Date drawingsReceived { get ; set; }
//        public Date drawingsRequested { get ; set; }
        public List<level5> level5List { get { if ( level5List == null ) level5List = new List<level5>(); return level5List ; } set;}

        public level4( String item, Integer i, Date drawingsReceived/*, Date drawingsRequested*/ ) {
            this.workType = item;
            if( drawingsReceived != null ) this.drawingsReceived = drawingsReceived;
//            if( drawingsRequested != null ) this.drawingsRequested = drawingsRequested;
            this.level4Rowspan = i;
            Integer j = 1;
            for( Service_Requirements__c item1: Service_Requirements__c.getall().values()){
                if( item1.Work_Type__c == item ){
                    level5List.add( new level5 ( item1, j++ ) );
                }
            }
            if ( level5List.isEmpty() ) level5List.add( new level5 ( new Service_Requirements__c(), 1 ) );
            level4Size = ( level5List.size() != 0 ) ? level5List.size() : 1;

            system.debug(LoggingLevel.error, '@level4Rowspan/level4Size= ' +level4Rowspan+' '+level4Size);
        }
    }

    //level5
    public class level5 {
        public Integer level5Rowspan { get{ if ( level5Rowspan == null ) level5Rowspan = 1; return level5Rowspan ; } set;}
        public String partyResponsible { get ; set; }
        public String signoffRequirements { get ; set; }
        public String itemsRequired { get ; set; }
        public String comment { get ; set; }

        public level5( Service_Requirements__c item, Integer i ) {
            this.level5Rowspan = i;
            partyResponsible = item.Party_Responsible__c;
            signoffRequirements = item.Signoff_Requirements__c;
            itemsRequired = item.Items_Required__c;
            comment = item.Comments__c;
        }
    }

    public void searchAction() {
        queryWhere = buildQueryWhere( baseProposal.Project_Profile__c, null, baseProposal.Accounting_Contact_Company__c, baseProposal.Billing_Company_Name__c, baseProposal.Primary_Company_Name__c, baseProposal.Address__c, null ); //MRS 6865
        System.debug(LoggingLevel.ERROR, 'buildQuery(queryWhere) =' + buildQuery(queryWhere));
		selectedProjectsList = Database.query(buildQuery(queryWhere));
    }

    public static String buildQueryWhere(final String projectFilter, final String multProjects, final String primaryCompanyFilter, final String buildingFilter,
                                        final String billingCompanyFilter, final String accountingCompanyFilter, final String teamFilter) { //MRS 6865
        String queryWhere = '';

        Boolean firstIn = true;
		if(!String.isEmpty(projectFilter) || !String.isBlank(multProjects)) {
			queryWhere += 'WHERE (';
			if ( !String.isEmpty(projectFilter) ) {
				queryWhere += 'Id = \'' + projectFilter + '\' ';
				firstIn = false;
			}
			if ( !String.isBlank(multProjects) ) {
				for(String s : multProjects.split(',')) {
					if(!String.isBlank(s)) {
						queryWhere += firstIn ? 'Name LIKE \'%' + s.trim() + '%\' ' : 'OR Name LIKE \'%' + s.trim() + '%\' ';
						firstIn = false;
					}
				}
			}
			queryWhere += ') ';
		}

        if ( !String.isEmpty(primaryCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Primary_Company_Name__c = \''+ primaryCompanyFilter +'\' ';
        }

        if ( !String.isEmpty(buildingFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Building__c = \''+ buildingFilter +'\' ';
        }

        if ( !String.isEmpty(billingCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Billing_Company_Name__c = \''+ billingCompanyFilter +'\' ';
        }

        if ( !String.isEmpty(accountingCompanyFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += 'Accounting_Contact_Company__c = \''+ accountingCompanyFilter +'\' ';
        }

		if ( !String.isEmpty(teamFilter ) ) {
            queryWhere += String.isBlank(queryWhere) ? 'WHERE ' : 'AND ';
            queryWhere += '	Project_Team__c = \''+ teamFilter +'\' ';
        }

        return queryWhere;
    }

    public static String buildQuery( String queryWhere ) {
        String generalContractor = 'General Contractor';
        return  ' Select Proposal__r.Proposal_Awarded_Date__c, Name, Proposal__r.Name, Floor_s__c, Project_Name__c, Building_Formula__c, Proposal__r.isPhase__c, Client_Project__c, '+
                ' Id, CreatedDate, (Select Role__c, Contact_Account_Name__c From Project_Rosters__r Where Role__c LIKE \'%'+ generalContractor +'%\' limit 1) ' +
                ' From Project_Profile__c '+ queryWhere  + 'ORDER BY CreatedDate DESC, Name'; //MRS 7555
    }



}