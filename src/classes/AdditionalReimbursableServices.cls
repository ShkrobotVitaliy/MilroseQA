public with sharing class AdditionalReimbursableServices {
    public static List<Additional_Reimbursable__c> additionalReimbursables;

    public static Map<Id, Additional_Reimbursable__c> getRecordsByProposalId( Id proposalId ) {
        return new Map<Id, Additional_Reimbursable__c>( getRecordsByProposalIdList( proposalId ) );
    }

	public static List<Additional_Reimbursable__c> getRecordsByProposalIdList( Id proposalId ) {
        if( AdditionalReimbursableServices.additionalReimbursables == null ) {
            AdditionalReimbursableServices.additionalReimbursables = getAdditionalReimbursablesByProposalId( proposalId );
        }
        return AdditionalReimbursableServices.additionalReimbursables;
	}

    public static List<Additional_Reimbursable__c> getAdditionalReimbursablesByProposalId( Id proposalId ) {
        if( proposalId != null ) {
            return new List<Additional_Reimbursable__c>( [ SELECT Id, Amount__c, Change_Order__c, CreatedDate, Proposal__c, Description__c, Change_Order__r.Status__c, Send_Muni_Fee_Invoice__c /* MRS 7298 */
                                                           FROM Additional_Reimbursable__c
                                                           WHERE Proposal__c = : proposalId
                                                           ORDER BY CreatedDate ] );
        } else {
            return new List<Additional_Reimbursable__c>();
        }
    }

	public static Map<Id, Additional_Reimbursable__c> getRecordsByProposal(Proposal__c proposal) { //MRS 7280
        return new Map<Id, Additional_Reimbursable__c>(getRecordsByProposalList(proposal));
    }

	public static List<Additional_Reimbursable__c> getRecordsByProposalList(Proposal__c proposal) { //MRS 7280
        //if( AdditionalReimbursableServices.additionalReimbursables == null ) { // MRS 7404
            AdditionalReimbursableServices.additionalReimbursables = getAdditionalReimbursablesByProposal(proposal);
        //}
        return AdditionalReimbursableServices.additionalReimbursables;
	}

    public static List<Additional_Reimbursable__c> getAdditionalReimbursablesByProposal(Proposal__c proposal) { //MRS 7280
        if(proposal != null && proposal.Id != null) {
			String query = 'SELECT Id, Amount__c, Change_Order__c, CreatedDate, Proposal__c, Description__c, Change_Order__r.Status__c, Send_Muni_Fee_Invoice__c' //MRS 7298
							+ ' FROM Additional_Reimbursable__c WHERE Proposal__c = \'' + proposal.Id + '\'';
			query += proposal.optView_Hide_Canceled_Change_Orders__c ? ' AND (Change_Order__c = null OR Change_Order__r.Status__c != \'Canceled\')' : '';
			query += ' ORDER BY CreatedDate';
			return Database.query(query);
        } else {
            return new List<Additional_Reimbursable__c>();
        }
    }
}