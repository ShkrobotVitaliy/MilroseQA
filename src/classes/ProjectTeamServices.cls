public with sharing class ProjectTeamServices {
    public static final String RESOURCE_ROLE_FILLING_REP = 'Filing Rep';
    public static final String RESOURCE_ROLE_MANAGER = 'Project Manager 2';
    public static final String RESOURCE_ROLE_MEMBER = 'Project Manager 1';
    public static final String RESOURCE_ROLE_PRODUCTION_MANAGER = 'Production Manager';
    public static final Set<String> PROJECT_TEAM_USERS = new Set<String>{ RESOURCE_ROLE_MANAGER, RESOURCE_ROLE_FILLING_REP,
                                                                          RESOURCE_ROLE_PRODUCTION_MANAGER, RESOURCE_ROLE_MEMBER, UserServices.PROFILE_FREP };
    public static final String PRODUCTION_MANAGER_FIELD = 'Production_Manager__c';
    public static final String NEW_BUILDING_FIELD = 'New_Building__c';

    public static final String SORT_TEAM_NAME = 'n';
    public static final String SORT_CLIENT = 'c';
    public static final String SORT_BUILDING = 'b';
    public static final String SORT_WORKLOAD = 'w';
    public static final String SORT_REGION = 'r';
    public static final String SORT_AGING = 'a';

    public static Map<Id, Project_Team__c> getProposalIdToProjectTeam( List<Proposal__c> proposals ) {

        Set<Id> projectTeamIds = new Set<Id>();
        for( Proposal__c proposalItem: proposals ) {
            projectTeamIds.add( proposalItem.Project_Team__c );
        }
        projectTeamIds.remove(null);
        Map<Id, Project_Team__c> projectTeamIdToProjectTeam = new Map<Id, Project_Team__c>( [SELECT Id, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c, Task_Items_Duration__c
                                                                                             FROM Project_Team__c
                                                                                             WHERE Id IN : projectTeamIds] );
        return projectTeamIdToProjectTeam;
    }

    public static Map<Id, Project_Team__c> getProjectIdToProjectTeam( List<Project_Profile__c> projects ) {

        Set<Id> projectTeamIds = new Set<Id>();
        for( Project_Profile__c projectItem: projects ) {
            projectTeamIds.add( projectItem.Project_Team__c );
        }
        projectTeamIds.remove(null);
        Map<Id, Project_Team__c> projectTeamIdToProjectTeam = new Map<Id, Project_Team__c>( [SELECT Id, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c, Task_Items_Duration__c
                                                                                             FROM Project_Team__c
                                                                                             WHERE Id IN : projectTeamIds] );
        return projectTeamIdToProjectTeam;
    }

    public static List<Project_Team__c> getAllProjectTeams( Id prodManagerId ) {
        return new List<Project_Team__c>([SELECT Email_Distribution__c, FREP__c, Production_Manager__c, Project_Manager__c, Id, Name, Task_Items_Duration__c, OwnerId
                                        FROM Project_Team__c
                                        Order by Name]);
    }

    public static Map<Id, Project_Team__c> getAllProjectTeams() {
        return new Map<Id, Project_Team__c>( [ SELECT Project_Manager__c
                                               FROM Project_Team__c
                                               ORDER BY Name ] );
    }

    public static List<SelectOption> getProjectTeamOptions( Id prodManagerId ) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        for (Project_Team__c item : getAllProjectTeams( prodManagerId ) ) {
            if( prodManagerId != null && UserInfo.getUserId() == prodManagerId ){
            	if( item.OwnerId == prodManagerId ) options.add(new SelectOption(item.Id, item.Name));
            }else{
            	options.add(new SelectOption(item.Id, item.Name));
            }
        }
        return options;
    }

    public static List<SelectOption> getFrepsOptions( Id projectTeamId, Id currentFrepId ) {
        List<SelectOption> options = new List<SelectOption>();
        if( String.isBlank( projectTeamId ) || String.isBlank( currentFrepId ) ) {
            options.add( new SelectOption( '', '-- None --' ) );
        } else {
            Map<String, Set<Id>> frepNameToIds = new Map<String, Set<Id>>();
            for( User user : [ SELECT Id, Name FROM User WHERE Profile.Name = : UserServices.PROFILE_FREP OR Id = : currentFrepId ] ) {
                if( frepNameToIds.get( user.Name ) == null ) {
                    frepNameToIds.put( user.Name, new Set<Id>() );
                }
                frepNameToIds.get( user.Name ).add( user.Id );
            }
            for( Project_Team__c team : [ SELECT FREP__c, FREP__r.Name FROM Project_Team__c WHERE FREP__c != null ] ) {
                if( frepNameToIds.get( team.FREP__r.Name ) == null ) {
                    frepNameToIds.put( team.FREP__r.Name, new Set<Id>() );
                }
                frepNameToIds.get( team.FREP__r.Name ).add( team.FREP__c );
            }

            List<String> frepNames = new List<String>();
            frepNames.addAll( frepNameToIds.keySet() );
            frepNames.sort();
            for( String frepName : frepNames ) {
                for( Id frepId : frepNameToIds.get( frepName ) ) {
                    options.add( new SelectOption( frepId, frepName ) );
                }
            }
        }
        return options;
    }

    public static List<SelectOption> getProdManagersOptions( Id existingProdManagerId ) {
        List<SelectOption> options = new List<SelectOption>();
            options.add( new SelectOption( '', '-- None --' ) );

            Map<String, Set<Id>> prodManagerNameToIds = new Map<String, Set<Id>>();
            String query = 'SELECT Id, Name FROM User WHERE ( Profile.Name = \'' + UserServices.PROFILE_PRODUCTION_MANAGER + '\' AND isActive = true )';
            if( existingProdManagerId != null ) {
                query += ' OR Id = \'' + existingProdManagerId + '\'';
            }
            for( User user : Database.query( query ) ) {
                if( prodManagerNameToIds.get( user.Name ) == null ) {
                    prodManagerNameToIds.put( user.Name, new Set<Id>() );
                }
                prodManagerNameToIds.get( user.Name ).add( user.Id );
            }
            List<String> prodManagerNames = new List<String>();
            prodManagerNames.addAll( prodManagerNameToIds.keySet() );
            prodManagerNames.sort();

            for( String prodManagerName : prodManagerNames ) {
                for( Id prodManagerNameId : prodManagerNameToIds.get( prodManagerName ) ) {
                    options.add( new SelectOption( prodManagerNameId, prodManagerName ) );
                }
            }

        return options;
    }

    public static Id getDefaultFrepForProjectTeam( Id projectTeamId ) {
        if( !String.isBlank( projectTeamId ) ) {
            List<Project_Team__c> teams = [ SELECT FREP__c FROM Project_Team__c WHERE Id = : projectTeamId ];
            if( !teams.isEmpty() ) {
                return teams[0].FREP__c;
            }
        }
        return null;
    }

    public static Id getDefaultProdManagerForProjectTeam( Id projectTeamId ) {
        if( !String.isBlank( projectTeamId ) ) {
            List<Project_Team__c> teams = [ SELECT Production_Manager__c FROM Project_Team__c WHERE Id = : projectTeamId ];
            if( !teams.isEmpty() ) {
                return teams[0].Production_Manager__c;
            }
        }
        return null;
    }

    /*public static void recalculateUnfulfilledTasksDuration(Set<Id> filteredProjectTeamsIdList, Map<Id, Set<Id>> filteredProjectTeamIdToProjectProfileIdSet, Map<Id, Task_Item__c> oldTaskItemMap, Map<Id, Project_Profile__c> oldProjectProfileMap ){
        if ((filteredProjectTeamIdToProjectProfileIdSet == null || filteredProjectTeamIdToProjectProfileIdSet.isEmpty()) && (filteredProjectTeamsIdList == null || filteredProjectTeamsIdList.isEmpty())){
            return;
        }
        Map<Id, Project_Team__c> projectTeamIdToProjectTeam = ProjectTeamServices.getAllProjectTeamsWithProjects();
        List<Task_Item__c> taskItems = new List<Task_Item__c>();
        if ( filteredProjectTeamsIdList != null ){
            taskItems = TaskItemServices.getUnfinishedTaskItemByProjectTeamIds( filteredProjectTeamsIdList );
        }else if( filteredProjectTeamIdToProjectProfileIdSet.keySet() != null ){
            taskItems = TaskItemServices.getUnfinishedTaskItemByProjectTeamIds( filteredProjectTeamIdToProjectProfileIdSet.keySet() );
        }
        Map<Id, String> teamIdToDuration = new Map<Id, String>();
        List<Project_Team__c> projectTeamListForUpdate = new List<Project_Team__c>();
        if ( taskItems != null){
            for (Task_Item__c task : taskItems) {
                if (!teamIdToDuration.containsKey(task.Project_Profile__r.Project_Team__c)) {
                    teamIdToDuration.put(task.Project_Profile__r.Project_Team__c, '0d 00h');
                }
        //String duration = teamIdToDuration.get(task.Project_Profile__r.Project_Team__c) != null ? teamIdToDuration.get(task.Project_Profile__r.Project_Team__c) : '0d 0h';
                //System.debug('@@duration ='+duration );
                system.debug('xxx teamIdToDuration ' + teamIdToDuration);
                system.debug('xxx teamIdToDuration.get(task.Project_Profile__r.Project_Team__c) ' + teamIdToDuration.get(task.Project_Profile__r.Project_Team__c) );
                system.debug('xxx task.Expected_Duration__c ' + task.Expected_Duration__c );
                system.debug('xxx task.Project_Profile__r.Project_Team__c ' + task.Project_Profile__r.Project_Team__c);
                system.debug('xxx task.Id ' + task.Id );

                teamIdToDuration.put(task.Project_Profile__r.Project_Team__c, DateUtils.appendDurations( teamIdToDuration.get(task.Project_Profile__r.Project_Team__c), task.Expected_Duration__c) );

            }
        }
        if ( filteredProjectTeamsIdList != null ){
            for ( Id teamId : filteredProjectTeamsIdList ) {
                Project_Team__c projectTeamItem = new Project_Team__c();
                projectTeamItem.Id = teamId;
                projectTeamItem.Task_Items_Duration__c = teamIdToDuration.containsKey(teamId) ? Integer.valueOf( teamIdToDuration.get(teamId).substringBefore('d') ) : 0;
                projectTeamListForUpdate.add( projectTeamItem );
            }
        }else if( filteredProjectTeamIdToProjectProfileIdSet.keySet() != null ){
            for ( Id teamId : filteredProjectTeamIdToProjectProfileIdSet.keySet() ) {
                Project_Team__c projectTeamItem = new Project_Team__c();
                projectTeamItem.Id = teamId;
                projectTeamItem.Task_Items_Duration__c = teamIdToDuration.containsKey(teamId) ? Integer.valueOf( teamIdToDuration.get(teamId).substringBefore('d') ) : 0;
                projectTeamListForUpdate.add( projectTeamItem );
            }
        }
        try{
            update projectTeamListForUpdate;
        } catch ( DMLException dmlEx ){//redooooo
            for ( Integer i=0; i < dmlEx.getNumDml(); i++){
                if( oldTaskItemMap != null ){
                    for ( Id itemId: filteredProjectTeamIdToProjectProfileIdSet.get(projectTeamListForUpdate[dmlEx.getDmlIndex(i)].Id) ){
                        for ( Task_Item__c itemTask: oldTaskItemMap.values() ){
                            if( itemTask.Project_Profile__c == itemId ){
                                itemTask.addError( dmlEx.getMessage() );
                            }
                        }
                    }
                }
                if( oldProjectProfileMap != null ){
                    for ( Project_Profile__c item: oldProjectProfileMap.values() ){
                        if ( projectTeamListForUpdate[dmlEx.getDmlIndex(i)].Id == item.Project_Team__c ){
                            item.addError( dmlEx.getMessage() );
                        }
                    }
                }
            }
        }
    }*/

    public static void updateProjectTeamOwner(List<Project_Team__c> projectTeamList) {
        for( Project_Team__c item: projectTeamList ){
            if( item.Production_Manager__c != null ) item.OwnerId = item.Production_Manager__c;
        }
    }

    public static Map<Id, Project_Team__c> filteredProjectTeamsByChangedUsers( List<Project_Team__c> projectTeamListNew, Map<Id, Project_Team__c> projectTeamMapOld ) {
        Map<Id, Project_Team__c> filteredProjectTeamsList = new Map<Id, Project_Team__c>();
        for ( Project_Team__c item : projectTeamListNew ){
            Project_Team__c itemOld = projectTeamMapOld.get(item.id);
            if ( item.Project_Manager__c != itemOld.Project_Manager__c || item.Project_Member__c != itemOld.Project_Member__c ||
            item.FREP__c != itemOld.FREP__c || item.Production_Manager__c != itemOld.Production_Manager__c ) {
                filteredProjectTeamsList.put(item.Id, item);
            }
        }
        return filteredProjectTeamsList;
    }

    public static Project_Team__c getProjectTeam( Id projectTeamId, List<String> fieldApiNames ) {
        Project_Team__c projectTeam = new Project_Team__c();
        if( !String.isEmpty(projectTeamId) && fieldApiNames != null && !fieldApiNames.isEmpty() ) {
            List<Project_Team__c> teams = Database.query( 'SELECT ' + String.join( fieldApiNames, ', '  ) + ' FROM Project_Team__c WHERE Id = \'' + projectTeamId + '\'' );
            if( !teams.isEmpty() ) {
                projectTeam = teams[0];
            }
        }
        return projectTeam;
    }

    public static List<AssignmentWrapper> getAssignmentsForProjectTeam( Proposal__c proposal ) {
        List<AssignmentWrapper> assignments = new List<AssignmentWrapper>();
        Boolean doMarkUnqualifiedTeams = proposal.sowScopeOfWork__c != null && proposal.sowScopeOfWork__c == ProposalWizardServices.SOW_NEW_BUILDING;
        for( Project_Team__c team : ProjectTeamServices.getAllProjectTeamsWithProjectsForAssignmentCalculation( proposal.Address__c, proposal.Primary_Company_Contact__c ).values() ) {
            Integer countProject = 0;
            Integer countBuilding = 0;
            for( Project_Profile__c project : team.Projects__r ) {
                countProject += project.Primary_Company_Contact__c == proposal.Primary_Company_Contact__c ? 1 : 0;
                countBuilding += project.Building__c == proposal.Address__c ? 1 : 0;
            }
            assignments.add( new AssignmentWrapper( team.Name,
                                                    countProject,
                                                    countBuilding,
                                                    team.Expected_Duration__c,
                                                    team.Total_Duration__c,
                                                    doMarkUnqualifiedTeams,
                                                    team.New_Building__c ) );
        }
        return assignments;
    }

    public static List<AssignmentWrapper> getAssignmentsForResource( Proposal__c proposal ) {
        List<AssignmentWrapper> assignments = new List<AssignmentWrapper>();
        for( User user : ProjectTeamServices.getAllUsersWithProjectsForAssignmentCalculation( proposal.Address__c, proposal.Primary_Company_Contact__c ).values() ) {
            Integer countProject = 0;
            Integer countBuilding = 0;
            for( Project_Profile__c project : user.Projects2__r ) {
                countProject += project.Primary_Company_Contact__c == proposal.Primary_Company_Contact__c ? 1 : 0;
                countBuilding += project.Building__c == proposal.Address__c ? 1 : 0;
            }
            assignments.add( new AssignmentWrapper( user.Name,
                                                    countProject,
                                                    countBuilding,
                                                    user.Expected_Duration__c,
                                                    user.Total_Duration__c,
                                                    !user.IsActive,
                                                    user.IsActive ) );
        }
        return assignments;
    }

    public static List<AssignmentWrapper> getAssignmentsForFrep() {
        List<AssignmentWrapper> assignments = new List<AssignmentWrapper>();
        for( User user : [ SELECT Name, Division, Total_Duration__c, Expected_Duration__c FROM User WHERE Profile.Name = : UserServices.PROFILE_FREP AND isActive = true ] ) {
            assignments.add( new AssignmentWrapper( user.Name,
                                                    user.Division,
                                                    user.Expected_Duration__c,
                                                    user.Total_Duration__c ) );
        }
        return assignments;
    }

    public static Map<Id, Project_Team__c> getAllProjectTeamsWithProjectsForAssignmentCalculation( Id buildingId, Id primaryContactId ) {
        return new Map<Id, Project_Team__c>( [ SELECT Name, Expected_Duration__c, Total_Duration__c, New_Building__c,
                                                      ( SELECT Id, Name, Primary_Company_Contact__c, Building__r.Street__c, Building__c
                                                        FROM Projects__r
                                                        WHERE Building__c = : buildingId 
                                                           OR Primary_Company_Contact__c = : primaryContactId )
                                               FROM Project_Team__c
                                               ORDER BY Name ] );
    }

    public static Map<Id, User> getAllUsersWithProjectsForAssignmentCalculation( Id buildingId, Id primaryContactId ) {
        return new Map<Id, User>( [ SELECT Name, Expected_Duration__c, Total_Duration__c, IsActive,
                                           ( SELECT Name, Primary_Company_Contact__c, Building__c
                                             FROM Projects2__r
                                             WHERE Building__c = : buildingId
                                                OR Primary_Company_Contact__c = : primaryContactId )
                                    FROM User ] );
    }

}