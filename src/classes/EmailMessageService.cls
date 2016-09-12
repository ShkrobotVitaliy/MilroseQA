public with sharing class EmailMessageService {
    public static final String SOA_TEMPLATE_NAME = 'Statement_Of_Accounts_Report_Template';
    public static final String EMAIL_TEMPLATE_PROPOSAL           = 'Proposal_Client_Approval';
    public static final String EMAIL_TEMPLATE_DRAFT_PROPOSAL     = 'Proposal_Client_Approval_Draft';
    public static final String EMAIL_TEMPLATE_PROPOSAL_FOLLOWUP           = 'Proposal_Client_Approval_FollowUp';
    public static final String EMAIL_TEMPLATE_DRAFT_PROPOSAL_FOLLOWUP     = 'Proposal_Client_Approval_FollowUp_Draft';

    public static final String EMAIL_TEMPLATE_CHANGE_ORDER       = 'Change_Order_Client_Approval';
    public static final String EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER = 'Change_Order_Client_Approval_Draft';
    public static final String EMAIL_TEMPLATE_CHANGE_ORDER_FOLLOWUP       = 'Change_Order_Client_Approval_FollowUp';
    public static final String EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER_FOLLOWUP = 'Change_Order_Client_Approval_FollowUp_Draft';

    public static final Set<String> unpredictableFilesEtentions = new Set<String>{'ppt', 'pptx'};
    public static final Double FIVE_MEGABYTES = 1024 * 1024 * 5;
    public static final Double THREE_MEGABYTES = 1024 * 1024 * 3;
    public static final Double ATTACHMENT_LIMIT = THREE_MEGABYTES;

    public static final Map<String, String> symbolsToEscape = new Map<String, String>{' ' => '%20',
                                                                                      '#' => '%23'};
    public static String getExternalURL( String externalId ) {
        String validExtId = externalId;
        for( String character: symbolsToEscape.keySet() ){
            validExtId = validExtId.replace(character, symbolsToEscape.get(character));
        }
        return 'https://s3.amazonaws.com/dl-' + UserInfo.getOrganizationId().toLowerCase() + '/' + validExtId;
    }

    public static void sendMassMailWithTemplate(Id templateId, List<Id> recipientIds, Id whatId) {
        if (null == templateId) {
            throw new ErrorException('Template ID cannot be null!');

        }

        if (null == recipientIds || recipientIds.isEmpty()) {
            throw new ErrorException('Recipients list cannot be empty!');

        }

        try {
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.SetTargetObjectIds(recipientIds);
            mail.setTemplateId(templateId);
            if( !Test.isRunningTest() ) Messaging.sendEmail(new Messaging.MassEmailMessage[] { mail });

        } catch (Exception ex) {
           throw new ErrorException('Exception occured during send email: ' + ex.getMessage());

        }

    }

    public static void sendSingleMailToDistribution(String[] distribution, String[] ccRecipient, String subject, String htmlBody) {
        if (distribution.isEmpty()) {
            throw new ErrorException('Email distribution cannot be empty!');

        }

        if (String.isBlank(subject)) {
            throw new ErrorException(ErrorException.EMAIL_MESSAGE_EMPTY_SUBJECT);

        }

        if (String.isBlank(htmlBody)) {
            throw new ErrorException(ErrorException.EMAIL_MESSAGE_EMPTY_BODY);

        }

        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(distribution);
            if (!ccRecipient.isEmpty()) {
                mail.setCcAddresses(ccRecipient);
            }
            mail.setSubject(subject.left(225));
            mail.setHtmlBody(htmlBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        } catch (Exception ex) {
            throw new ErrorException('Exception occured during send email: ' + ex.getMessage());

        }
    }

    public static void sendMassMailToInternalUsers(Set<Id> usersIds, String emailHtmBody, String subject) { //MRS 6991
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> ();

        for(Id userID : usersIds ) {
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
            emailMsg.setTargetObjectId(userID);
            emailMSg.saveAsActivity = false;
            emailMsg.setSubject( subject );
            emailMsg.setBccSender( false );
            emailMsg.setUseSignature( false );
            emailmsg.setHtmlBody( emailHtmBody );
            messages.add( emailMsg );
        }
        Messaging.sendEmail( messages );
    }

    public static void sendSingleEmailMessage( String[] toRecipients, String[] ccRecipients, Id trackingParentId, Id trackingContactId, String subject, String htmlBody, Id[] documentsId ) {
        if( toRecipients.isEmpty() && String.isBlank( trackingContactId ) ) {
            throw new ErrorException( 'At least one \'to\' recipient should be available to send an email!' );
        }
        if( String.isBlank( subject ) ) {
            throw new ErrorException( ErrorException.EMAIL_MESSAGE_EMPTY_SUBJECT );
        }
        if( String.isBlank( htmlBody ) ) {
            throw new ErrorException( ErrorException.EMAIL_MESSAGE_EMPTY_BODY );
        }
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toRecipients);
            if( !ccRecipients.isEmpty() ) {
                mail.setCcAddresses( ccRecipients );
            }
            if( !String.isBlank( trackingContactId ) ) {
                mail.setTargetObjectId( trackingContactId );
            }
            if( !String.isBlank( trackingParentId ) ) {
                mail.setWhatId( trackingParentId );
            }
            //mail.saveAsActivity = false;
            mail.setSubject( subject.left(225) );
            mail.setHtmlBody( htmlBody );
            if( !documentsId.isEmpty() ) {
                mail.setDocumentAttachments( documentsId );
            }
            Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
        } catch( Exception ex ) {
            throw new ErrorException( 'Exception occured while sending email: ' + ex.getMessage() );
        }
    }

    public static String getAttachmentsEmailBodyPart( Map<String, String> externalUrlToDocumentNameMap ){
        String filesAttachmentBodyPart = '';

        if( !externalUrlToDocumentNameMap.isEmpty() ){
            filesAttachmentBodyPart = '<br/><br/><br/>' + Label.Find_Attached_Documents_Message + '<br/>' + '<br/><ol>';
            for( String externalUrl : externalUrlToDocumentNameMap.keySet() ) {
                filesAttachmentBodyPart += '<li><a href=\"' + externalUrl + '\" style=\"color: blue;\">' + externalUrlToDocumentNameMap.get( externalUrl ) + '</li>';
            }
            filesAttachmentBodyPart += '</ol>';
        }

        return filesAttachmentBodyPart;
    }

    public static String getAttachmentsEmailBodyPartForSendingInOrder( Map<String, String> externalUrlToDocumentNameMap,
                                                          Map<String, String> externalUrlToDocumentNameMapAdditionalFiles){ //G300 MRS--6807
        String filesAttachmentBodyPart = '';

        if( !externalUrlToDocumentNameMap.isEmpty() ){
            filesAttachmentBodyPart = '<br/><br/><br/>' + Label.Find_Attached_Documents_Message + '<br/>' + '<br/><ol>';
            for( String externalUrl : externalUrlToDocumentNameMap.keySet() ) {
                filesAttachmentBodyPart += '<li><a href=\"' + externalUrl + '\" style=\"color: blue;\">' + externalUrlToDocumentNameMap.get( externalUrl ) + '</li>';
            }
            for( String externalUrl : externalUrlToDocumentNameMapAdditionalFiles.keySet() ) {
                filesAttachmentBodyPart += '<li><a href=\"' + externalUrl + '\" style=\"color: blue;\">' + externalUrlToDocumentNameMapAdditionalFiles.get( externalUrl ) + '</li>';
            }
            filesAttachmentBodyPart += '</ol>';
        }

        return filesAttachmentBodyPart;
    }

    public static Id getEmailTemplateIdForRequestFillingFee() {
        List<EmailTemplate> templateEmail = [SELECT id FROM EmailTemplate WHERE name like : 'Request Filing Fees' + '%'];

        if (null == templateEmail || templateEmail.isEmpty()) {
            throw new ErrorException('Email template with specified name cannot be found!');

        }
        return templateEmail.get(0).Id;

    }

    public static EmailTemplate getEmailTemplateByDeveloperName( String templateDeveloperName ) {
        if( String.isBlank( templateDeveloperName ) ) {
            throw new ErrorException( 'Template name cannot be empty!' );
        }
        List<EmailTemplate> emailTemplates = [SELECT Name, HtmlValue, Subject, DeveloperName, FolderId, TemplateType,
                                                     BrandTemplateId, TemplateStyle, Body, IsActive
                                             FROM EmailTemplate
                                             WHERE DeveloperName = : templateDeveloperName
                                             LIMIT 1];
        if( emailTemplates.isEmpty() ) {
            throw new ErrorException( 'The Email template with name: \'' + templateDeveloperName + '\' cannot be found!' );
            return null;
        }
        return emailTemplates.get(0);
    }

    public static EmailTemplate getEmailTemplateByName(String name) {
        if (String.isBlank(name)) {
            throw new ErrorException('Template name cannot be empty!');

        }

        List<EmailTemplate> templateEmail = [SELECT Id, Name, HtmlValue, Subject, developerName, FolderId, TemplateType, BrandTemplateId, TemplateStyle, Body, IsActive
                                             FROM EmailTemplate
                                             WHERE Name LIKE :name limit 1];

        if (null == templateEmail || templateEmail.isEmpty()) {
            if( name != null && name.indexOf('-%') > -1 ){
                name = name.substring( 0, name.indexOf('-%') );
            }
            throw new ErrorException('Email template with specified name: ' + name + ' cannot be found!');

        }
        return templateEmail.get(0);

    }

    public static EmailTemplate getEmailTemplateById(String name) {
        if (String.isBlank(name)) {
            throw new ErrorException('Template name cannot be empty!');

        }

        List<EmailTemplate> templateEmail = [SELECT Id, Name, HtmlValue, Subject, developerName, FolderId, TemplateType, BrandTemplateId, TemplateStyle, Body, IsActive
                                             FROM EmailTemplate
                                             WHERE Id = : name];

        if (null == templateEmail || templateEmail.isEmpty()) {
            if( name != null && name.indexOf('-%') > -1 ){
                name = name.substring( 0, name.indexOf('-%') );
            }
            throw new ErrorException('Email template with specified name: ' + name + ' cannot be found!');

        }
        return templateEmail.get(0);

    }

    public static Map<Id, EmailTemplate> getDeliveryMethodIdToEarliestEmailTemplate( String ddpName ) {
        Map<Id, Id> emailTemplateIdToDeliveryMethodId = new Map<Id, Id>();
        List<Loop__DDP_Integration_Option__c> deliveryMethods = [ SELECT Loop__Template__c
                                                                  FROM Loop__DDP_Integration_Option__c
                                                                  WHERE Loop__DDP__r.Name = : ddpName
                                                                    AND RecordType.Name = : DDPEmailServices.DELIVERY_METHOD_EMAIL
                                                                    AND Loop__Template__c != null ];
        for( Loop__DDP_Integration_Option__c deliveryMethod : deliveryMethods ) {
            emailTemplateIdToDeliveryMethodId.put( deliveryMethod.Loop__Template__c, deliveryMethod.Id );
        }
        List<EmailTemplate> emailTemplates = [ SELECT Name, HtmlValue, Subject, DeveloperName,
                                                      FolderId, TemplateType, BrandTemplateId,
                                                      TemplateStyle, Body, IsActive
                                               FROM EmailTemplate
                                               WHERE Id IN : emailTemplateIdToDeliveryMethodId.keySet()
                                               ORDER BY LastModifiedDate ASC, LastUsedDate ASC NULLS LAST, Name ASC, Id ASC
                                               LIMIT 1 ];
        if( !emailTemplates.isEmpty() ) {
            return new Map<Id, EmailTemplate>{ emailTemplateIdToDeliveryMethodId.get( emailTemplates[0].Id ) => emailTemplates[0] };
        } else {
            return null;
        }
    }

    public static Map<Integer, Map<Id, EmailTemplate>> getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( String ddpName ) {
        return getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( ddpName, DDPEmailServices.DELIVERY_METHOD_EMAIL );
    }

    public static Map<Integer, Map<Id, EmailTemplate>> getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( String ddpName, String deliveryMethodName ) {
        if( !String.isBlank( ddpName ) && !String.isBlank( deliveryMethodName ) ) {
            Map<Id, Id> emailTemplateIdToDeliveryMethodId = new Map<Id, Id>();
            Integer oldestTemplateNumber = null;
            List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
            List<Loop__DDP_Integration_Option__c> deliveryMethods = [ SELECT Id, Loop__Template__c, Send_Email_User__c
                                                                      FROM Loop__DDP_Integration_Option__c
                                                                      WHERE Loop__DDP__r.Name = : ddpName
                                                                        AND Name = : deliveryMethodName
                                                                        AND ( Send_Email_User__c = null Or Send_Email_User__c = : userinfo.getuserid() )
                                                                        AND Loop__Template__c != null
                                                                      ORDER BY Send_Email_User__c NULLS LAST ];
            for( Loop__DDP_Integration_Option__c deliveryMethod : deliveryMethods ) {
                if ( deliveryMethod.Send_Email_User__c != null ){
                    emailTemplateIdToDeliveryMethodId = new Map<Id, Id>{ deliveryMethod.Loop__Template__c => deliveryMethod.Id };
                    break;
                }
                emailTemplateIdToDeliveryMethodId.put( deliveryMethod.Loop__Template__c, deliveryMethod.Id );
            }
            emailTemplates = [ SELECT Name, HtmlValue, Subject, DeveloperName, FolderId, TemplateType,
                                      BrandTemplateId, TemplateStyle, Body, IsActive, Description
                               FROM EmailTemplate
                               WHERE Id IN : emailTemplateIdToDeliveryMethodId.keySet() ];

            if( !emailTemplates.isEmpty() ) {
                Map<Integer, List<EmailTemplate>> templateNumberToEmailTemplate = new Map<Integer, List<EmailTemplate>>();
                List<EmailTemplate> templatesWithWrongNumbers = new List<EmailTemplate>();
                for( EmailTemplate template : emailTemplates ) {
                    try {
                        Integer currentTemplateNumber = Integer.valueOf( template.Description );
                        if( !templateNumberToEmailTemplate.containsKey( currentTemplateNumber ) ) {
                            templateNumberToEmailTemplate.put( currentTemplateNumber, new List<EmailTemplate>() );
                        }
                        templateNumberToEmailTemplate.get( currentTemplateNumber ).add( template );
                    } catch( Exception e ) {
                        templatesWithWrongNumbers.add( template );
                    }
                }
                List<Integer> validTemplateNumbers = new List<Integer>( templateNumberToEmailTemplate.keySet() );
                validTemplateNumbers.sort();
                if( !validTemplateNumbers.isEmpty() || !templatesWithWrongNumbers.isEmpty() ) {
                    Integer largestTemplateNumber = validTemplateNumbers.isEmpty() ? 1 : validTemplateNumbers[validTemplateNumbers.size() - 1];
                    EmailTemplate oldestTemplate = templatesWithWrongNumbers.isEmpty()
                                                   ? templateNumberToEmailTemplate.get( validTemplateNumbers[0] ).get(0)
                                                   : templatesWithWrongNumbers[0];
                    //EmailTemplate oldestTemplate = validTemplateNumbers.isEmpty() ? templatesWithWrongNumbers[0] : templateNumberToEmailTemplate.get( validTemplateNumbers[0] ).get(0);
                    return new Map<Integer, Map<Id, EmailTemplate>>{ largestTemplateNumber =>
                                                                     ( new Map<Id, EmailTemplate>{ emailTemplateIdToDeliveryMethodId.get( oldestTemplate.Id ) =>
                                                                                                   oldestTemplate } ) };
                }
            }
        }
        return null;
    }

    public List<FileWrapper> currentDocuments { get{ if( currentDocuments == null ) currentDocuments = new List<FileWrapper>(); return currentDocuments; } set; }
    public static Map<Id, EmailTemplate> getEmailTemplatesFromFolder(String folderName, String templateNameToExclude){
        if( String.isBlank( folderName )){
            throw new ErrorException('Folder must be specified!');
        }
        if( templateNameToExclude == null ) templateNameToExclude = '';
        Map<Id, EmailTemplate> emailTemplates = new Map<Id, EmailTemplate>([SELECT Id, Name, HtmlValue, Subject, developerName, FolderId, Folder.Name, TemplateType, BrandTemplateId, TemplateStyle, Body, IsActive
                                                FROM EmailTemplate
                                                WHERE Folder.Name =: folderName
                                                AND Name !=: templateNameToExclude]);
        return emailTemplates;
    }

    @future
    public static void sendEmailNotification (Set<Id> projectProfileSetId){
        //get ProjectProfile
        Map<id, Project_Profile__c> projectProfilesMap = new Map<Id, Project_Profile__c>([SELECT Id, Name, OwnerId, Project_Manager__c, Project_Member__c, FREP__c, Production_Manager__c,
                                                                                                Project_Manager__r.Email, Project_Member__r.Email, FREP__r.Email, Production_Manager__r.Email,
                                                                                                Owner.Email, Floor_s__c, Project_Address__c, Project_Name__c, Project_Team__c, Project_Name_For_Email__c, /* MRS 6259 */
                                                                                                (Select Id, Name, OwnerId, Owner.Email, Service_Name_Short__c From Service_Items__r)
                                                                                          FROM Project_Profile__c
                                                                                          WHERE Id IN : projectProfileSetId]);

        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        for ( Project_Profile__c projectProfileItem : projectProfilesMap.values() ){
            Set<Id> userIds = new Set<Id>();
            mailList.add( populateEmailAboutProjectCreationNotification( projectProfileItem, projectProfileItem.OwnerId ) );
            userIds.add( projectProfileItem.OwnerId );

            if ( projectProfileItem.Project_Team__c != null ){
                if( !userIds.contains( projectProfileItem.Project_Member__c ) ){
                    mailList.add( populateEmailAboutProjectCreationNotification( projectProfileItem, projectProfileItem.Project_Member__c ) );
                    userIds.add( projectProfileItem.Project_Member__c );
                }
                if( !userIds.contains( projectProfileItem.FREP__c ) ){
                    mailList.add( populateEmailAboutProjectCreationNotification( projectProfileItem, projectProfileItem.FREP__c ) );
                    userIds.add( projectProfileItem.FREP__c );
                }
                if( !userIds.contains( projectProfileItem.Production_Manager__c ) ){
                    mailList.add( populateEmailAboutProjectCreationNotification( projectProfileItem, projectProfileItem.Production_Manager__c ) );
                    userIds.add( projectProfileItem.Production_Manager__c );
                }

            }
            for ( Service_Item__c serviceItem : projectProfileItem.Service_Items__r ){
                //send email to Service Owner
                if ( !userIds.contains( serviceItem.OwnerId ) ){
                    mailList.add( populateEmailAboutProjectCreationNotification( projectProfileItem, serviceItem.OwnerId ) );
                    userIds.add( serviceItem.OwnerId );
                }
            }
        }

        if( !Test.isRunningTest() && !mailList.isEmpty() ) Messaging.sendEmail(mailList);
    }

    public static Messaging.SingleEmailMessage populateEmailAboutProjectCreationNotification (Project_Profile__c projectProfileItem, Id userId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId( userId );
        mail.saveAsActivity = false;
        //prepare Email Subject
        String emailSubject = 'New WAVE ' + projectProfileItem.Project_Name_For_Email__c + ' Assigned'; // MRS 6259
        if ( projectProfileItem.Project_Name__c != null ) emailSubject += ' - ' + projectProfileItem.Project_Name__c;
        if ( projectProfileItem.Project_Address__c != null ) emailSubject += ' - ' + projectProfileItem.Project_Address__c;
        if ( projectProfileItem.Floor_s__c != null ) emailSubject += ', Floor ' + projectProfileItem.Floor_s__c;
        mail.setSubject( emailSubject );

        //prepare Email Body
        String emailBodyValue = '<b>Please be informed, that a new project has been assigned to you: </b><br/>';
        emailBodyValue += projectProfileItem.Project_Name_For_Email__c; // MRS 6259
        if ( projectProfileItem.Project_Address__c != null ) emailBodyValue += ' - ' + projectProfileItem.Project_Address__c;
        if ( projectProfileItem.Floor_s__c != null ) emailBodyValue += ', Floor ' + projectProfileItem.Floor_s__c;
        if ( projectProfileItem.Project_Name__c != null ) emailBodyValue += ', ' + projectProfileItem.Project_Name__c;
        emailBodyValue += '<br/> You can access it <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + projectProfileItem.Id + '">here.</a><br/><br/><br/>';
        emailBodyValue += 'It consists of the following Services:<br/>';
        emailBodyValue += '<table style="padding:40px 40px 40px 40px"><tbody><tr style="background-color:#000080;color:#FFFAFA"><th>Service ID</th><th>Short name</th></tr>';
        if (!projectProfileItem.Service_Items__r.isEmpty()){
            Boolean boolStyle = true;
            for (Service_Item__c serviceItem : projectProfileItem.Service_Items__r){
                //prepare Email body
                if (boolStyle){
                    emailBodyValue += '<tr style="background-color:#F8F8F8"><td>';
                } else {
                    emailBodyValue += '<tr style="background-color:#F2F2F2"><td>';
                }
                emailBodyValue += serviceItem.Name + '</td>' + '<td style="padding-left:25px">' + serviceItem.Service_Name_Short__c + '</td></tr>';
                boolStyle = !boolStyle;
            }
        }

        emailBodyValue += '</tbody></table>';
        mail.setHtmlBody(emailBodyValue);

        return mail;
    }

    //MRS-6618
    public static void sendEmailNotificationChangeOrder (List<Change_Order__c> newApprovedChangeOrderList, Map<Id, Proposal__c> proposalsFromChangeOrders){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        for ( Change_Order__c changeOrderItem : newApprovedChangeOrderList ){
            Set<Id> userIds = new Set<Id>();
            Proposal__c proposalItem = proposalsFromChangeOrders.get(changeOrderItem.Proposal__c);

			if( proposalItem.Project_Profile__c != null && proposalItem.Project_Profile__r.OwnerId != null && !userIds.contains(proposalItem.Project_Profile__r.OwnerId)){ // MRS 7258
            mailList.add( populateEmailAboutCOApprovedCreationNotification( changeOrderItem, proposalItem, proposalItem.Project_Profile__r.OwnerId ) );
				userIds.add( proposalItem.Project_Profile__r.OwnerId );
			}

            if( !userIds.contains( changeOrderItem.CreatedById ) && changeOrderItem.CreatedById != null ){
                mailList.add( populateEmailAboutCOApprovedCreationNotification( changeOrderItem, proposalItem, changeOrderItem.CreatedById ) );
                userIds.add( changeOrderItem.CreatedById );
            }

            if ( proposalItem.Project_Team__c != null ){
                if( !userIds.contains( proposalItem.Project_Profile__r.Project_Member__c ) && proposalItem.Project_Profile__r.Project_Member__c != null ){
                    mailList.add( populateEmailAboutCOApprovedCreationNotification( changeOrderItem, proposalItem, proposalItem.Project_Profile__r.Project_Member__c ) );
                    userIds.add( proposalItem.Project_Profile__r.Project_Member__c );
                }
                if( !userIds.contains( proposalItem.Project_Profile__r.Project_Manager__c ) && proposalItem.Project_Profile__r.Project_Manager__c != null ){
                    mailList.add( populateEmailAboutCOApprovedCreationNotification( changeOrderItem, proposalItem, proposalItem.Project_Profile__r.Project_Manager__c ) );
                    userIds.add( proposalItem.Project_Profile__r.Project_Manager__c );
                }
                if( !userIds.contains( proposalItem.Project_Profile__r.Production_Manager__c ) && proposalItem.Project_Profile__r.Production_Manager__c != null ){
                    mailList.add( populateEmailAboutCOApprovedCreationNotification( changeOrderItem, proposalItem, proposalItem.Project_Profile__r.Production_Manager__c ) );
                    userIds.add( proposalItem.Project_Profile__r.Production_Manager__c );
                }
            }

        }

        if( !Test.isRunningTest() && !mailList.isEmpty() ) Messaging.sendEmail(mailList);
    }

    public static Messaging.SingleEmailMessage populateEmailAboutCOApprovedCreationNotification (Change_Order__c changeOrder, Proposal__c proposal, Id userId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId( userId );
        mail.saveAsActivity = false;

        //prepare Email Subject
        String emailSubject = 'New WAVE Change Order ' + changeOrder.Name + ' has been Approved';
        if ( proposal.Project_Profile__r.Name != null ) emailSubject += ' - ' + proposal.Project_Profile__r.Name;
        if ( changeOrder.Project_Name__c != null ) emailSubject += ' - ' + changeOrder.Project_Name__c;
        if ( proposal.Project_Profile__r.Project_Address__c != null ) emailSubject += ' - ' + proposal.Project_Profile__r.Project_Address__c;
        if ( changeOrder.Floor_s__c != null ) emailSubject += ', Floor ' + changeOrder.Floor_s__c;
        mail.setSubject( emailSubject );

        //prepare Email Body
        String emailBodyValue = '<b>Please be informed, that new Change Order has been Approved: </b><br/>';
        emailBodyValue += changeOrder.Name;
        if ( proposal.Project_Profile__r.Name != null ) emailBodyValue += '-' + proposal.Project_Profile__r.Name;
        if ( changeOrder.Project_Name__c != null ) emailBodyValue += ' - ' + changeOrder.Project_Name__c;
        if ( proposal.Project_Profile__r.Project_Address__c != null ) emailBodyValue += ' - ' + proposal.Project_Profile__r.Project_Address__c;
        if ( changeOrder.Floor_s__c != null ) emailBodyValue += ', Floor ' + changeOrder.Floor_s__c;
        emailBodyValue += '<br/> You can access Project <a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + proposal.Project_Profile__c + '">here.</a><br/><br/><br/>';

        mail.setHtmlBody(emailBodyValue);

        return mail;
    }

    public static Messaging.SingleEmailMessage createEmailNotificationMessage (String subject, String emailBody, Id targetId){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setTargetObjectId( targetId );
        mail.saveAsActivity = targetId != null && (String.valueOf(targetId)).startsWithIgnoreCase('003');

        mail.setSubject( subject );

        mail.setHtmlBody(emailBody);

        return mail;
    }

    //MRS-7483
    public static void sendEmailNotificationDeactivateUser(List<Id> executingUserIds, Id deactivatedUserId){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

		PageReference ref = Page.DeactivatingUsersHelper;
        ref.getParameters().put( 'userId', String.valueOf(deactivatedUserId) );

        Messaging.EmailFileAttachment attachmentHelper = new Messaging.EmailFileAttachment();
		String attachmentFileName = 'Helper.xls';

		Blob attachmentBody;
		if( Test.isRunningTest() ) { attachmentBody = Blob.valueOf(' '); } else { attachmentBody = ref.getContent(); }

        attachmentHelper.setFileName( attachmentFileName );
        attachmentHelper.setBody( attachmentBody );
        Messaging.EmailFileAttachment[] attachmentList = new Messaging.EmailFileAttachment[]{attachmentHelper};

        for (Id targetUserId : executingUserIds){
            Messaging.SingleEmailMessage mail = createEmailNotificationMessage('User with Id = "' + deactivatedUserId + '" has been deactivated', 'User with Id = "' + deactivatedUserId + '" has been deactivated', targetUserId);
            mail.setFileAttachments(attachmentList);
            mailList.add(mail);
        }
			
        if( !Test.isRunningTest() && !mailList.isEmpty() ) Messaging.sendEmail(mailList);
    }
}