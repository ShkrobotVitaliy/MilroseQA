public with sharing class OpportunityServices {
	
	public OpportunityServices() {}

	public static List<Opportunity> filteredOpportunitiesThatMustBeEmailed(List<Opportunity> newList) {
		List<Opportunity> res = new List<Opportunity>();
		Set<String> trackedStatuses = new Set<String> {'Scope Review Required', 'Proposal Required', 'Proposal Sent'};
		for(Opportunity opp : newList) {
			if(trackedStatuses.contains(opp.StageName)) {
				res.add(opp);
			}
		}
		return res;
	}

	public static void sendEmailNotificationToUsers(List<Opportunity> opps) {

		String emailHtmlBody = '';
		String subject = '';
		List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> ();
		
		Set<Id> oppsIdxSet = new Set<Id>();
		for(Opportunity opp : opps) {
			oppsIdxSet.add(opp.Id);
		}
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([SELECT Id, Building__c, Building__r.Name, AccountId, Account.Name, Opportunity_Contact__c, Opportunity_Contact__r.Name
																FROM Opportunity
																WHERE Id IN :oppsIdxSet]);
		for(Opportunity opp : opps) {
			Set<Id> usersIds = new Set<Id>();
 	
			subject = 'Opportunity '+ opp.Name + ' has been changed to ' + opp.StageName;
			String oppDate = opp.Date_of_Proposal_Requested__c == null ? '' : opp.Date_of_Proposal_Requested__c.format();
			String buildingName = String.isBlank(oppMap.get(opp.Id).Building__c) ? '' : oppMap.get(opp.Id).Building__r.Name;
			String accountName = String.isBlank(oppMap.get(opp.Id).AccountId) ? '' : oppMap.get(opp.Id).Account.Name;
			String contactName = String.isBlank(oppMap.get(opp.Id).Opportunity_Contact__c) ? '' : oppMap.get(opp.Id).Opportunity_Contact__r.Name;
			emailHtmlBody = '<html>'
						  + 'Opportunity <a href="'+System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + opp.Id+'">' + opp.Name + '</a> has been changed to ' + opp.StageName + '.<br/><br/>'
						  + 'Proposal Due Date: ' + oppDate + '<br/><br/>'
						  + 'Address: ' + buildingName + '<br/><br/>'
						  + 'Opportunity Account: ' + accountName + '<br/><br/>'
						  + 'Opportunity Contact: ' + contactName + '<br/><br/>'
						  + '</html>';

			if(opp.StageName == 'Scope Review Required') {
				if(!String.isBlank(opp.Scope_Reviewer__c) && UserInfo.getUserId() != opp.Scope_Reviewer__c) usersIds.add(opp.Scope_Reviewer__c);
			}
			if(opp.StageName == 'Proposal Required') {
				if(!String.isBlank(opp.Proposal_Specialist__c) && UserInfo.getUserId() != opp.Proposal_Specialist__c) usersIds.add(opp.Proposal_Specialist__c);
				if(!String.isBlank(opp.Account_Manager__c) && UserInfo.getUserId() != opp.Account_Manager__c) usersIds.add(opp.Account_Manager__c);
			}
			if(opp.StageName == 'Proposal Sent') {
				if(!String.isBlank(opp.OwnerId) && UserInfo.getUserId() != opp.OwnerId) usersIds.add(opp.OwnerId);
				if(!String.isBlank(opp.Account_Manager__c) && UserInfo.getUserId() != opp.Account_Manager__c) usersIds.add(opp.Account_Manager__c);
			}
	        
			for(Id userID : usersIds ) {
	            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
	            emailMsg.setTargetObjectId(userID);
	            emailMSg.saveAsActivity = false;
	            emailMsg.setBccSender(false);
	            emailMsg.setUseSignature( false );
				emailmsg.setHtmlBody(emailHtmlBody);
				emailMsg.setSubject(subject);
	            messages.add(emailMsg);
	        }
		}

        Messaging.sendEmail(messages);
	}

	public static void setOpportunityFollowUpHours(List<Opportunity> opps) { //MRS 7407
		for(Opportunity opp : opps) {
			opp.Email_Hour__c = opp.Date_of_Next_Follow_up__c == null ? null : opp.Date_of_Next_Follow_up__c.hour();
		}
	}

}