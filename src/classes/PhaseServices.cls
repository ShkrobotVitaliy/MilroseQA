public with sharing class PhaseServices {
    public static final String PHASE_OBJECT_API_NAME = 'Phase__c';
    public static final String SINGLE_PHASE = 'Single Phase';

    public static List<Phase__c> phases;

    public static Map<Id, Phase__c> getPhaseMapById( Id proposalId, String orderBy ) {
        return new Map<Id, Phase__c>( getPhaseList( proposalId, 'Number__c' ) );
    }

    public static List<Phase__c> getPhaseList( Id proposalId, String orderBy ) {
        if( PhaseServices.phases == null ) {
            PhaseServices.phases = getPhasesByProposalId( proposalId, orderBy );
        }
        return PhaseServices.phases;
    }

    public static List<Phase__c> getPhasesByProposalId( Id proposalId ) {
        return getPhasesByProposalId( proposalId, 'Number__c' );
    }

    public static List<Phase__c> getPhasesByProposalId( Id proposalId, String orderBy ) {
        List<Phase__c> phaseList = new List<Phase__c>();
        if( proposalId != null ) {
            String query = 'SELECT Id, Start_Date__c, Proposal__c, Is_default__c, Number__c, Name__c, End_Date__c FROM Phase__c WHERE Proposal__c =\'' + proposalId + '\'';
            if( orderBy != null && orderBy != '' ) {
                query += ' ORDER BY ' + orderBy + ' ASC';
            }
            phaseList = database.query( query );
        }
        return phaseList;
    }

    public static List<Phase__c> sortPhase( String sortBy, String proposalId ) {
        List<Phase__c> phaseList = new List<Phase__c>();
        if( String.isNotBlank( proposalId ) ) {
            String query = 'SELECT Id, Start_Date__c, Proposal__c, Is_default__c, Number__c, Name__c, End_Date__c FROM Phase__c WHERE Proposal__c = \'' + proposalId + '\'';
            if( String.isNotBlank( sortBy ) ) {
                query += ' ORDER BY ' + sortBy;
            }
            phaseList = Database.query( query );
        }
        return phaseList;
    }

    public static Map<Decimal, Phase__c> getPhaseMap( Id proposalId ) {
        Map<Decimal, Phase__c> phaseMap = new Map<Decimal, Phase__c>();
        for( Phase__c phaseItem : getPhaseList( proposalId, 'Number__c' ) ) {
            phaseMap.put( phaseItem.Number__c, phaseItem );
        }
        return phaseMap;
    }

    public static List<Phase__c> rerenderPhaseNumber(List<Phase__c> phaseList) {
        Integer phaseNumber = 1;
        for(Phase__c pase : phaseList) {
            pase.Number__c = phaseNumber;
            phaseNumber++;
        }
        try {
            update phaseList;
        } catch ( DMLException dmlEx ) {
            for ( Integer i=0; i < dmlEx.getNumDml(); i++  ) {
                //TODO: add handler
            }
        }
        return phaseList;
    }

    public static List<Phase__c> getPhaseByProjectId(Id projectId) {
        return new List<Phase__c>([SELECT Id, Name__c
                                   FROM Phase__c
                                   WHERE Project_Profile__c =: projectId]);
    }

    public static void populatePhaseNames( List<Phase__c> phasesIn ) {
        for( Phase__c phase : phasesIn ) {
            if( String.isEmpty( phase.Name__c ) ) {
                phase.Name__c = SINGLE_PHASE;
            }
            phase.Name = phase.Name__c.left(80);
        }
    }

}