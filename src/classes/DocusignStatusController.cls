public with sharing class DocusignStatusController {
    public Proposal__c proposal { get; set; }
    public List<dsfs__DocuSign_Status__c> statuses { get; set; }
    public Map<Id, String> statusIdToReceiverName { get; set; }
    public Map<Id, String> statusIdToReceiverId { get; set; }

    public String profileName {
        get {
            if( profileName == null ) {
                profileName = ProposalWizardServices.getProfileNameById( UserInfo.getProfileId() );
            }
            return profileName;
        } set;
    }

    public DocusignStatusController( ApexPages.StandardController controller ) {
        proposal = (Proposal__c)controller.getRecord();
        proposal = [ SELECT Project_Name__c, Address_Building_AKA__c
                       FROM Proposal__c
                      WHERE Id = : proposal.Id
                      LIMIT 1];
        refreshStatuses();
    }

    public void refreshStatuses() {
        statuses = [ SELECT Proposal_Docusign_Status__c, Change_Order_Docusign_Status__c,
                            Name, dsfs__Sender__c, dsfs__Envelope_Status__c, dsfs__Hrs_Sent_to_Sign__c, dsfs__Sent_Date_Time__c
                     FROM dsfs__DocuSign_Status__c
                     WHERE Proposal_Docusign_Status__c = : proposal.Id
                        OR Change_Order_Docusign_Status__r.Proposal__c = : proposal.Id
                     ORDER BY dsfs__Sent_Date_Time__c DESC NULLS LAST ];

        statusIdToReceiverName = new Map<Id, String>();
        statusIdToReceiverId = new Map<Id, String>();
        for( dsfs__DocuSign_Status__c status : statuses ) {
            statusIdToReceiverName.put( status.Id, '' );
            statusIdToReceiverId.put( status.Id, '' );
        }
        for( dsfs__DocuSign_Recipient_Status__c recipient : [ SELECT Name, dsfs__Parent_Status_Record__c, dsfs__Contact__c
                                                              FROM dsfs__DocuSign_Recipient_Status__c
                                                              WHERE dsfs__Parent_Status_Record__c IN : statusIdToReceiverName.keySet()
                                                                AND Recipient_Type__c = 'Signer' ] ) {
            statusIdToReceiverName.put( Id.valueOf(recipient.dsfs__Parent_Status_Record__c), recipient.Name );
            if( !String.isBlank( recipient.dsfs__Contact__c ) ) {
                statusIdToReceiverId.put( Id.valueOf(recipient.dsfs__Parent_Status_Record__c), recipient.dsfs__Contact__c );
            }
        }
    }
}