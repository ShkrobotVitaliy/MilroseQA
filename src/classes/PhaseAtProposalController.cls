public class PhaseAtProposalController {

    public Proposal__c proposal { get; set; }
    public List<Phase__c> phaseList { get; set; }

    public sortExtension sortAssignmentExtension {
        get {
            if(sortAssignmentExtension == null) {
                sortAssignmentExtension = new SortExtension( 'Name__c' );
            }
            return sortAssignmentExtension;
        }
        set;
    }

    public PhaseAtProposalController( ApexPages.StandardController controller ) {
        proposal = (Proposal__c)controller.getRecord();
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getSortDirection();
        phaseList = PhaseServices.sortPhase( sortBy, proposal.Id );

    }

    public void sortAction() {
        String sortBy = sortAssignmentExtension.sortExpression  + ' ' + sortAssignmentExtension.getsortDirection();
        phaseList = PhaseServices.sortPhase( sortBy, proposal.Id );
    }

}