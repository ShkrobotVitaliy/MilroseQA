public with sharing class SubmitProposalForReviewController {
    private final String proposalId = ApexPages.currentPage().getParameters().get('Id');
    private final String toClient = ApexPages.currentPage().getParameters().get('toClient');

    public static String INVALID_PROPOSAL = Label.Invalid_Proposal_Specified;
    public static String SUBMITTED_FOR_APPROVAL = Label.Submitted_For_Approval;
    public static String SUBMISSION_ERROR = Label.Approval_Process_Submission_Error;
    public static String WRONG_STATUS_ERROR = Label.Wrong_Status_for_Approvel_Process;
    public static String PARTNER_REVIEW_IS_NOT_NEEDED_ERROR = Label.Partner_Review_is_not_needed;

    public boolean isValidUser { get; set; }

    private Proposal__c currentProposal;
    private Approval.ProcessResult result;

    public SubmitProposalForReviewController() {
        isValidUser = true;
        try {
            currentProposal = [ Select Partner__c, Partner_Approval_Required__c, Status__c From Proposal__c Where Id = :proposalId ];
        } catch( Exception e ) {
            isValidUser = false;
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, INVALID_PROPOSAL ) );
        }
    }

    public PageReference submitRequest() {
        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        PageReference pr = null;
        if ( isValidUser ) {
            try {
                if( toClient == null ) { // for Partner Review
                    if( !currentProposal.Partner_Approval_Required__c ||
                        currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT ||
                        currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED) {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, PARTNER_REVIEW_IS_NOT_NEEDED_ERROR ) );
                    } else {
                        if( currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_NEW ||
                            currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_NOT_AWARDED ||
                            currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                            currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED ) {
                            request.setObjectId( currentProposal.Id );
                            request.setComments( SUBMITTED_FOR_APPROVAL );
                            request.setNextApproverIds( new ID[] { currentProposal.Partner__c } );
                            result = Approval.process( request );

                            pr = new PageReference( '/' + currentProposal.Id );
                            pr.setRedirect(true);
                        } else {
                            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, WRONG_STATUS_ERROR ) );
                        }
                    }
                } else { // for Client Review
                    if( currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_NEW && currentProposal.Partner_Approval_Required__c ){
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, Label.Need_Approved_By_Partner ) );
                    } else{
                        if( currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                            currentProposal.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED) {
                            currentProposal.Status__c = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
                            currentProposal.Proposal_Sent_Date__c = date.today();
                            update currentProposal;

                            pr = new PageReference( '/' + currentProposal.Id );
                            pr.setRedirect(true);
                        } else {
                            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, WRONG_STATUS_ERROR ) );
                        }
                    }
                }
            } catch( Exception ex ) {
                for ( Integer i=0; i < ex.getNumDml(); i++ ) {
                    currentProposal.AddError( SUBMISSION_ERROR + ': ' + ex.getDmlMessage(i) );
                }
            }
        }
        return pr;
    }
}