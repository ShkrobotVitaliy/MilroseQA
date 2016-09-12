public with sharing class NewNonFeeProposalExtensions {
    public static final String DDP_NAME = 'Non-Fee Proposal Document';
    public static final String DELIVERY_METHOD_NAME = 'Attach';
    
    public final Proposal__c proposal { get; private set; }
    
    public NewNonFeeProposalExtensions(ApexPages.StandardController controller) {
        this.proposal = (Proposal__c)controller.getRecord();
    
    }
    
    public PageReference createNewNonFeeProposal() {
        createDDPHelpers();
        
        List<Loop__DDP_Integration_Option__c> deliveryMethod = [SELECT Id, Loop__DDP__c
                                                                FROM Loop__DDP_Integration_Option__c
                                                                WHERE Loop__DDP__r.Name = : DDP_NAME AND Name = : DELIVERY_METHOD_NAME ];
                                                                      
        
        if (deliveryMethod.isEmpty()) {
            return null;

        }
        
        List<Proposal__c> proposalPrimaryContact = [SELECT p.Primary_Company_Contact__c FROM Proposal__c p WHERE p.Id =: this.proposal.Id limit 1];
        if (null == proposalPrimaryContact || proposalPrimaryContact.isEmpty()) {
            return null;
        
        }
                
        PageReference page = new PageReference('/apex/loop__looplus');
        page.getParameters().put('autorun', 'true');
        page.getParameters().put('eid', this.proposal.Id);
        page.getParameters().put('ddpIds', deliveryMethod[0].Loop__DDP__c);
        page.getParameters().put('deploy', deliveryMethod[0].Id);
        page.getParameters().put('contactId', proposalPrimaryContact.get(0).Primary_Company_Contact__c);
        page.setRedirect(true);            
        return page;

    }
    
    private void createDDPHelpers() {
        Map<Id, Phase__c> phases = new Map<Id, Phase__c> ([SELECT Id FROM Phase__c WHERE Proposal__c = : this.proposal.Id]);
        if( !phases.isEmpty() ) {
            DELETE [SELECT Id FROM DDP_Helper__c WHERE Phase__c IN :phases.keySet() AND Type__c = 'Non-Fee Proposal'];
            Map<Id, Service_Item__c> sItems = new Map<Id, Service_Item__c>( [SELECT Service_Name_Full__c, Abbreviation__c, Quantity__c, Total_Service_Price__c, Phase__c, Discounted_Unit_Price__c
                                                                             FROM Service_Item__c WHERE Phase__c IN :phases.keySet()] );
            if( !sItems.isEmpty() ) {
                Map<String, List<Id>> sNameSids = new Map<String, List<Id>>();
                for( Service_Item__c sItem : sItems.values() ) {
                    String key = String.valueOf(sItem.Phase__c) + sItem.Service_Name_Full__c + String.valueOf(sItem.Discounted_Unit_Price__c);
                    if( sNameSids.get(key) == null ) sNameSids.put( key, new List<Id>() );
                    List<Id> idsInMap = sNameSids.get(key);
                    idsInMap.add( sItem.Id );
                    sNameSids.put( key, idsInMap );
                }
                List<DDP_Helper__c> ddpHelpers = new List<DDP_Helper__c>();
                for( String key : sNameSids.keySet() ) {
                    DDP_Helper__c ddpHelper;
                    Service_Item__c sItem;
                    for( Id idItem : sNameSids.get(key) ) {
                        sItem = sItems.get(idItem);
                        if( ddpHelper == null )
                            ddpHelper = new DDP_Helper__c( Phase__c = sItem.Phase__c,
                                                           Number1__c = 0.00,
                                                           Number2__c = sItem.Discounted_Unit_Price__c,
                                                           Number3__c = 0.00,
                                                           Text2__c = '',
                                                           Type__c = 'Non-Fee Proposal' );
                        ddpHelper.Number1__c += sItem.Quantity__c;
                        ddpHelper.Number3__c += sItem.Total_Service_Price__c;
                        if( !String.isBlank(sItem.Abbreviation__c) && !ddpHelper.Text2__c.contains(sItem.Abbreviation__c) )
                            ddpHelper.Text2__c += sItem.Abbreviation__c + '; ';
                    }
                    ddpHelper.Text2__c = ddpHelper.Text2__c.removeEnd('; ');
                    ddpHelpers.add( ddpHelper );
                }
                insert ddpHelpers;
            }
        }
    }

}