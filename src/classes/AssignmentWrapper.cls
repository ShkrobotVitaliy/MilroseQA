public class AssignmentWrapper implements Comparable {
    public String teamName { get { if( teamName == null ) teamName = ''; return teamName; } set; }
    public String regionName { get { if( regionName == null ) regionName = ''; return regionName; } set; }
    public Integer clientFactor { get { if( clientFactor == null ) clientFactor = 0; return clientFactor; } set; }
    public Integer buildingFactor { get { if( buildingFactor == null ) buildingFactor = 0; return buildingFactor; } set; }
    public String totalWorkloadFactor { get { if( totalWorkloadFactor == null ) totalWorkloadFactor = '0d'; return totalWorkloadFactor; } set; }
    private Decimal totalWorkloadFactorDecimal { get { if( totalWorkloadFactorDecimal == null ) totalWorkloadFactorDecimal = 0; return totalWorkloadFactorDecimal; } set; }
    private Boolean doMarkUnqualifiedTeams { get { if( doMarkUnqualifiedTeams == null ) doMarkUnqualifiedTeams = false; return doMarkUnqualifiedTeams; } set; }
    private Boolean isNewBuildingOnTeam { get { if( isNewBuildingOnTeam == null ) isNewBuildingOnTeam = false; return isNewBuildingOnTeam; } set; }

    public transient Boolean isQualified;
    public Boolean getIsQualified() {
        if( this.doMarkUnqualifiedTeams ) {
            if( this.isNewBuildingOnTeam ) {
                Decimal maxLimit = 0;
                for( Project_Team_Qualification__c qualificationLimit : Project_Team_Qualification__c.getAll().values() ) {
                    if( qualificationLimit.Duration_Limit__c != null && qualificationLimit.Duration_Limit__c > maxLimit ) {
                        maxLimit = qualificationLimit.Duration_Limit__c;
                    }
                }
                return maxLimit * 480 >= totalWorkloadFactorDecimal;
            } else {
                return false;
            }
        } else {
            return true;
        }
    }

    public String orderBy { get { if( orderBy == null ) { orderBy = MilroseDevHelper.SORT_ASC; } return orderBy; } set; }
    public String sortName { get { if( sortName == null ) { sortName = ProjectTeamServices.SORT_WORKLOAD; } return sortName; } set; }

    public AssignmentWrapper( String teamName, Integer clientFactor, Integer buildingFactor, Decimal totalWorkloadFactorDecimal,
                              String totalWorkloadFactor, Boolean doMarkUnqualifiedTeams, Boolean isNewBuildingOnTeam ) {
        this.teamName = teamName;
        this.clientFactor = clientFactor;
        this.buildingFactor = buildingFactor;
        this.totalWorkloadFactorDecimal = totalWorkloadFactorDecimal;
        this.totalWorkloadFactor = totalWorkloadFactor;
        this.doMarkUnqualifiedTeams = doMarkUnqualifiedTeams;
        this.isNewBuildingOnTeam = isNewBuildingOnTeam;
    }

    public AssignmentWrapper( String teamName, String regionName, Decimal totalWorkloadFactorDecimal, String totalWorkloadFactor ) {
        this.teamName = teamName;
        this.regionName = regionName;
        this.totalWorkloadFactorDecimal = totalWorkloadFactorDecimal;
        this.totalWorkloadFactor = totalWorkloadFactor;
    }

    public Integer compareTo( Object compareTo ) {
        AssignmentWrapper compareToAssignment = (AssignmentWrapper)compareTo;
        Integer multiplier = this.orderBy != MilroseDevHelper.SORT_DESC ? 1 : -1;
        Integer result = 0;
        if( this.sortName == ProjectTeamServices.SORT_TEAM_NAME ) {
            if( this.teamName > compareToAssignment.teamName ) {
                result = 1;
            } else {
                result = -1;
            }
        } else if( sortName == ProjectTeamServices.SORT_CLIENT ) {
            if( this.clientFactor > compareToAssignment.clientFactor ) {
                result = 1;
            } else if( this.clientFactor < compareToAssignment.clientFactor ) {
                result = -1;
            } else {
                result = this.teamName > compareToAssignment.teamName ? 1 : -1;
            }
        } else if( sortName == ProjectTeamServices.SORT_BUILDING ) {
            if( this.buildingFactor > compareToAssignment.buildingFactor ) {
                result = 1;
            } else if( this.buildingFactor < compareToAssignment.buildingFactor ) {
                result = -1;
            } else {
                result = this.teamName > compareToAssignment.teamName ? 1 : -1;
            }
        } else if( sortName == ProjectTeamServices.SORT_WORKLOAD ) {
            if( !getIsQualified() && compareToAssignment.getIsQualified() ) {
                result = 1;
            } else if( getIsQualified() && !compareToAssignment.getIsQualified() ) {
                result = -1;
            } else {
                if( this.totalWorkloadFactorDecimal > compareToAssignment.totalWorkloadFactorDecimal ) {
                    result = 1;
                } else if( this.totalWorkloadFactorDecimal < compareToAssignment.totalWorkloadFactorDecimal ) {
                    result = -1;
                } else {
                    result = this.teamName > compareToAssignment.teamName ? 1 : -1;
                }
            }
        } else if( sortName == ProjectTeamServices.SORT_REGION ) {
            if( this.regionName > compareToAssignment.regionName ) {
                result = 1;
            } else if( this.regionName < compareToAssignment.regionName ) {
                result = -1;
            } else {
                result = this.teamName > compareToAssignment.teamName ? 1 : -1;
            }
        }
        return result * multiplier;
    }

}