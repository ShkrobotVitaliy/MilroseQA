public class MergeEmailTemplate {
    private final String emailType;
    private final String sendTo;
    private final String originalTemplateName;
    @TestVisible private final String rfiLink;
    private final String additionalSubject;
    private final String additionalBody;
    private final Project_Profile__c project;
    private final Contact recipient;
    private final Change_Order__c changeOrder;
    private final Proposal__c proposal;
    public String documentLink;

    public static final String RFI_EMAIL                = 'RFI_EMAIL';
    public static final String REQUEST_FILING_FEE_EMAIL = 'REQUEST_FILING_FEE_EMAIL';
    public static final String FORM_FOR_SIGNATURES      = 'FORM_FORSUGNATURES';
    public static final String STANDARD_PARSING_EMAIL   = 'STANDARD_PARSING_EMAIL';
    public static final String LETTER_EMAIL             = 'LETTER_EMAIL';
    public static final String PROPOSAL                 = 'PROPOSAL';
    public static final String CHANGE_ORDER             = 'CHANGE_ORDER';
    public static final String PROPOSAL_FOLLOWUP        = 'PROPOSAL_FOLLOWUP';
    public static final String CHANGE_ORDER_FOLLOWUP    = 'CHANGE_ORDER_FOLLOWUP';

    private static User loggedUserStatic {
        get {
            if( null == loggedUserStatic ) {
                List<User> users = new List<User>([SELECT Title, Phone, Name, Id, Extension, Email, CompanyName, Fax,
                                                          Street, State, PostalCode, Office_Number__c, Longitude, Latitude, Country, City
                                                   FROM User
                                                   WHERE Id =: UserInfo.getUserId()]);
                loggedUserStatic = users.get(0);
            }
            return loggedUserStatic;
        } set;
    }

    public Id loggedUserId { get { if( loggedUserId == null ) loggedUserId = UserInfo.getUserId(); return loggedUserId; } set; }
    public User loggedUser {
        get {
            if( null == loggedUser ) {
                List<User> users = new List<User>([SELECT Title, Phone, Name, Id, Extension, Email, CompanyName, Fax,
                                                          Street, State, PostalCode, Office_Number__c, Longitude, Latitude, Country, City
                                                   FROM User
                                                   WHERE Id =: loggedUserId]);
                loggedUser = users.get(0);
            }
            return loggedUser;
        } set;
    }

    public static String legalFooter() {
        String signatureBody = Label.EmailSignatureHTML;

        signatureBody = mergeField( signatureBody , '{!User.Name}', getStringValue(loggedUserStatic.Name) );
        signatureBody = mergeField( signatureBody , '{!User.Title}', getStringValue(loggedUserStatic.Title).replace(', ', ',<br/>') );
        signatureBody = mergeField( signatureBody , '{!User.Street}', getStringValue(loggedUserStatic.Street) );
        signatureBody = mergeField( signatureBody , '{!User.City}', getStringValue(loggedUserStatic.City) );
        signatureBody = mergeField( signatureBody , '{!User.State}', getStringValue(loggedUserStatic.State) );
        signatureBody = mergeField( signatureBody , '{!User.PostalCode}', getStringValue(loggedUserStatic.PostalCode) );
        signatureBody = mergeField( signatureBody , '{!User.Phone}', getStringValue(loggedUserStatic.Phone) );
        signatureBody = mergeField( signatureBody , '{!User.Office_Number__c}', getStringValue(loggedUserStatic.Office_Number__c) );
        signatureBody = mergeField( signatureBody , '{!User.Email}', getStringValue(loggedUserStatic.Email) );

        return signatureBody;
    }

    public String legalFooterForProposalAndCOEmails() {
        String signatureBody = Label.EmailSignatureProposalAndCOHTML;

        signatureBody = mergeField( signatureBody , '{!User.Name}', getStringValue(loggedUser.Name) );
        signatureBody = mergeField( signatureBody , '{!User.Title}', getStringValue(loggedUser.Title).replace(', ', ',<br/>') );
        signatureBody = mergeField( signatureBody , '{!MilroseLogo}', '<br/><img src=\"' + milroseLogoIdExternalUrl +'\" style=\"width: 25mm;\"/><br/>' );
        signatureBody = mergeField( signatureBody , '{!User.Street}', getStringValue(loggedUser.Street) );
        signatureBody = mergeField( signatureBody , '{!User.City}', getStringValue(loggedUser.City) );
        signatureBody = mergeField( signatureBody , '{!User.State}', getStringValue(loggedUser.State) );
        signatureBody = mergeField( signatureBody , '{!User.PostalCode}', getStringValue(loggedUser.PostalCode) );
        signatureBody = mergeField( signatureBody , '{!User.Phone}', getStringValue(loggedUser.Phone) );
        signatureBody = mergeField( signatureBody , '{!User.Fax}', getStringValue(loggedUser.Fax) );
        signatureBody = mergeField( signatureBody , '{!User.Office_Number__c}', getStringValue(loggedUser.Office_Number__c) );
        signatureBody = mergeField( signatureBody , '{!User.Email}', getStringValue(loggedUser.Email) );

        return signatureBody;
    }

    public static String milroseLogoIdExternalUrl { get { return URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + milroseLogoId + '&oid=' + UserInfo.getOrganizationId(); } }
    public static String milroseLogoId {
        get {
            if( milroseLogoId == null ) {
                List<Document> docs = [ SELECT Id FROM Document WHERE DeveloperName = : MilroseDevHelper.MILROSE_LOGO_DOCUMENT_DEVELOPER_NAME ];
                if( !docs.isEmpty() ) {
                    milroseLogoId = docs[0].Id;
                } else {
                    milroseLogoId = '';
                }
            }
            return milroseLogoId;
        }
        set;
    }



    @TestVisible
    private Date currentDatePlusThreeBusinessDays {
        get {
            if (null == this.currentDatePlusThreeBusinessDays) {
                Datetime businessHour = DateUtils.getDatetimeWithTimeShiftByBusinessHours(datetime.now(), '3d');
                this.currentDatePlusThreeBusinessDays = date.newinstance(businessHour.year(), businessHour.month(), businessHour.day());

            }
            return this.currentDatePlusThreeBusinessDays;

        }
        set;
    }

    @TestVisible
    private EmailTemplate originalEmailTemplate {
        get {
            if (null == this.originalEmailTemplate) {
                this.originalEmailTemplate = EmailMessageService.getEmailTemplateByName(this.originalTemplateName);

            }
            return this.originalEmailTemplate;
        }
        set;
    }

    public Id templateId {
        get {
            return this.originalEmailTemplate.Id;

        }
        private set;
    }

    public String headerBody {
        get {
            if (String.isBlank(this.headerBody) && this.originalEmailTemplate.HtmlValue.contains('CDATA[')) {
                this.headerBody = this.originalEmailTemplate.HtmlValue.substring(0, this.originalEmailTemplate.HtmlValue.indexOf('CDATA[') + 6);

            }
            return this.headerBody;

        }
        private set;

    }

    public String footerBody {
        get {
            if (String.isBlank(this.footerBody) && this.originalEmailTemplate.HtmlValue.contains(']]>')) {
                this.footerBody = this.originalEmailTemplate.HtmlValue.substring(this.originalEmailTemplate.HtmlValue.lastIndexOf(']]>'), this.originalEmailTemplate.HtmlValue.length());

            }
            return this.footerBody;

        }
        private set;
    }

    public String subject {
        get {
            if (null == this.subject) {
                this.subject = mergeSubject(this.originalEmailTemplate.Subject);

            }
            return this.subject;
        }
        set;
    }
    public String body {
        get {
            if (null == this.body) {
                this.body = mergeBody(this.originalEmailTemplate.HtmlValue);

            }
            return this.body;
        }
        set;
    }

    public MergeEmailTemplate( EmailTemplate originalTemplate ) {
        this.originalTemplateName = originalTemplate.Name;
        this.originalEmailTemplate = originalTemplate;

    }

    public MergeEmailTemplate( String originalTemplateName ) {
        this.originalTemplateName = originalTemplateName;

    }

    public MergeEmailTemplate( String originalTemplateName, Project_Profile__c project, String sendTo, String emailType, String rfiLink ) {
        this.originalTemplateName = originalTemplateName;
        this.sendTo = sendTo;
        this.emailType = emailType;
        this.project = project;
        this.rfiLink = rfiLink;

    }

    public MergeEmailTemplate( String originalTemplateName, Project_Profile__c project, String sendTo, String emailType, String additionalSubject, String additionalBody ) {
        this.originalTemplateName = originalTemplateName;
        this.sendTo            = sendTo;
        this.emailType         = emailType;
        this.project           = project;
        this.additionalSubject = additionalSubject;
        this.additionalBody    = additionalBody;

    }

    public MergeEmailTemplate( String originalTemplateName, Project_Profile__c project, String sendTo, String emailType, String additionalSubject, String additionalBody, Contact recipient ) {
        this.originalTemplateName = originalTemplateName;
        this.sendTo            = sendTo;
        this.emailType         = emailType;
        this.project           = project;
        this.additionalSubject = additionalSubject;
        this.additionalBody    = additionalBody;
        this.recipient         = recipient;

    }

    public MergeEmailTemplate( EmailTemplate originalTemplate, Change_Order__c changeOrder, Boolean isFollowUp ) {
        this.originalTemplateName = originalTemplate.Name;
        this.originalEmailTemplate = originalTemplate;
        this.changeOrder = changeOrder;
        if( isFollowUp == true ) {
            this.emailType = MergeEmailTemplate.CHANGE_ORDER_FOLLOWUP;
        } else {
            this.emailType = MergeEmailTemplate.CHANGE_ORDER;
        }
    }

    public MergeEmailTemplate( EmailTemplate originalTemplate, Proposal__c proposal, Boolean isFollowUp ) {
        this.originalTemplateName = originalTemplate.Name;
        this.originalEmailTemplate = originalTemplate;
        this.proposal = proposal;
        if( isFollowUp == true ) {
            this.emailType = MergeEmailTemplate.PROPOSAL_FOLLOWUP;
        } else {
            this.emailType = MergeEmailTemplate.PROPOSAL;
        }
    }

    @TestVisible
    private String mergeSubject(String subjectTemplate) {
        if (String.isBlank(subjectTemplate)) {
            return '';

        }
        if( this.emailType == MergeEmailTemplate.PROPOSAL || this.emailType == MergeEmailTemplate.PROPOSAL_FOLLOWUP ) {
            return mergeProposalToSubject( subjectTemplate );
        }
        if( this.emailType == MergeEmailTemplate.CHANGE_ORDER || this.emailType == MergeEmailTemplate.CHANGE_ORDER_FOLLOWUP ) {
            return mergeChangeOrderToSubject( subjectTemplate );
        }
        if (MergeEmailTemplate.RFI_EMAIL == this.emailType) {
            return getRFISubject(subjectTemplate);

        } else if (MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL == this.emailType) {
           return getRFFSubject(subjectTemplate);

        } else if (MergeEmailTemplate.STANDARD_PARSING_EMAIL == this.emailType) {
           return getStandardParsedSubject(subjectTemplate);

        } else if (MergeEmailTemplate.FORM_FOR_SIGNATURES == this.emailType) {
            return getStandardParsedSubject(subjectTemplate);

        } else if (MergeEmailTemplate.LETTER_EMAIL == this.emailType && !String.isBlank(this.additionalSubject)) {
            return this.additionalSubject;

        }

        return subjectTemplate;

    }

    @TestVisible
    private String mergeBody(String bodyTemplate) {
        if (String.isBlank(bodyTemplate)) {
            return '';

        }

        if (bodyTemplate.contains('CDATA[') && bodyTemplate.contains(']]>')) {
            bodyTemplate = bodyTemplate.substring(bodyTemplate.indexOf('CDATA[') + 6, bodyTemplate.lastIndexOf(']]>'));

        }
        if( this.emailType == MergeEmailTemplate.PROPOSAL || this.emailType == MergeEmailTemplate.PROPOSAL_FOLLOWUP ) {
            return mergeProposalToBody( bodyTemplate );
        }
        if( this.emailType == MergeEmailTemplate.CHANGE_ORDER || this.emailType == MergeEmailTemplate.CHANGE_ORDER_FOLLOWUP ) {
            return mergeChangeOrderToBody( bodyTemplate );
        }
        if ( MergeEmailTemplate.RFI_EMAIL == this.emailType ) {
            return getRFIBody(bodyTemplate);

        } else if (MergeEmailTemplate.REQUEST_FILING_FEE_EMAIL == this.emailType) {
            return getRFFBody(bodyTemplate);

        } else if (MergeEmailTemplate.STANDARD_PARSING_EMAIL == this.emailType) {
            return getStandardEmailTemplateBody( bodyTemplate, this.project, this.recipient );

        } else if (MergeEmailTemplate.LETTER_EMAIL == this.emailType && !String.isBlank(this.additionalBody)) {
            return this.additionalBody;

        } else if (MergeEmailTemplate.FORM_FOR_SIGNATURES == this.emailType ) {
            return getStandardEmailTemplateBody( bodyTemplate, this.project, this.recipient );
        }
        return bodyTemplate;

    }

    public static String getValidOutlookBody( String bodyTemplate){
        String pTagOpenLong = '<p class="MsoNormal" style="background-color: rgb(255, 255, 255);">';
        String pTagOpen = '<p class="MsoNormal">';
        Integer lengthOfPTagOpen = 21;
        String pTagClose = '</p>';
        String fontTagStart = '<font';
        String fontTagOpen = '<font face="Arial,Sans-Serif" size="3">';
        String fontTagClose = '</font>';
        String result = '';
        bodyTemplate = bodyTemplate.replace(pTagOpenLong, pTagOpen);

        Integer currentOpenPTagPosition = bodyTemplate.indexOf(pTagOpen);
        if( currentOpenPTagPosition < 0 ){
            return bodyTemplate;
        }

        while (currentOpenPTagPosition >= 0) {
            result = result + bodyTemplate.substring(0, currentOpenPTagPosition + lengthOfPTagOpen);
            bodyTemplate = bodyTemplate.substring(currentOpenPTagPosition + lengthOfPTagOpen);

            Integer currentPTagClosePosition = bodyTemplate.indexOf(pTagClose);
            String innerText = bodyTemplate.substring(0, currentPTagClosePosition);

            if( innerText.indexOf(fontTagStart) < 0  ){
                innerText = fontTagOpen + innerText + fontTagClose;
            }

            result = result + innerText + pTagClose;
            bodyTemplate = bodyTemplate.substring(currentPTagClosePosition + 4);
            currentOpenPTagPosition = bodyTemplate.indexOf(pTagOpen );
        }

        result = result + bodyTemplate;
        return result;
    }

    @TestVisible
    private String mergeProposalToSubject( String subjectTemplate ) {
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Name}', this.proposal.Name != null ? this.proposal.Name : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Project_Name__c}', this.proposal.Project_Name__c != null ? this.proposal.Project_Name__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Address_Building_AKA__c}', this.proposal.Address_Building_AKA__c != null ? this.proposal.Address_Building_AKA__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Floor_s__c}', this.proposal.Floor_s__c != null ? this.proposal.Floor_s__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Project_Profile__c.Name}', this.proposal.Project_Profile__r.Project_Name_For_Email__c != null ? this.proposal.Project_Profile__r.Project_Name_For_Email__c : ''); // MRS 6259
        return subjectTemplate.left(225);
    }

    @TestVisible
    private String mergeChangeOrderToSubject( String subjectTemplate ) {
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Name}', this.changeOrder.Proposal__r.Name != null ? this.changeOrder.Proposal__r.Name : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Project_Profile__c}', this.changeOrder.Proposal__r.Project_Profile__r.Name != null ? this.changeOrder.Proposal__r.Project_Profile__r.Name : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Project_Name__c}', this.changeOrder.Proposal__r.Project_Name__c != null ? this.changeOrder.Proposal__r.Project_Name__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Address_Building_AKA__c}', this.changeOrder.Proposal__r.Address_Building_AKA__c != null ? this.changeOrder.Proposal__r.Address_Building_AKA__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Proposal__c.Floor_s__c}', this.changeOrder.Proposal__r.Floor_s__c != null ? this.changeOrder.Proposal__r.Floor_s__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Change_Order__c.Send_To_Client_Email_Subject__c}', this.changeOrder.Send_To_Client_Email_Subject__c != null ? this.changeOrder.Send_To_Client_Email_Subject__c : '' );
        subjectTemplate = subjectTemplate.replace( '{!Change_Order__c.Number__c}', this.changeOrder.Number__c != null ? String.valueOf( this.changeOrder.Number__c ) : '' );
		subjectTemplate = subjectTemplate.replace( '{!Project_Profile__c.Name}', this.changeOrder.Proposal__r.Project_Profile__r.Project_Name_For_Email__c != null ? this.changeOrder.Proposal__r.Project_Profile__r.Project_Name_For_Email__c : ''); // MRS 6259 
        return subjectTemplate.left(225);
    }

    @TestVisible
    private String mergeProposalToBody( String bodyTemplate ) {
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Proposal_Sent_Date__c}', this.proposal.Proposal_Sent_Date__c != null ? this.proposal.Proposal_Sent_Date__c.format() : Date.today().format() );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Billing_Company_Contact__c}', ( this.proposal.Billing_Company_Contact__r.Salutation != null ? this.proposal.Billing_Company_Contact__r.Salutation + ' ' : '' ) +
                                                                                          ( this.proposal.Billing_Company_Contact__r.Name != null ? this.proposal.Billing_Company_Contact__r.Name : '' ) +
                                                                                          ( this.proposal.Billing_Company_Contact__r.Suffix__c != null ? ', ' + this.proposal.Billing_Company_Contact__r.Suffix__c : '' ) );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Project_Name__c}', this.proposal.Project_Name__c != null ? this.proposal.Project_Name__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Address_Building_AKA__c}', this.proposal.Address_Building_AKA__c != null ? this.proposal.Address_Building_AKA__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Floor_s__c}', this.proposal.Floor_s__c != null ? this.proposal.Floor_s__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Proposal_With_Link}', !String.isBlank(documentLink) ? '<a href="' + documentLink + '">proposal</a>' : 'proposal' );
        return bodyTemplate;
    }

    @TestVisible
    private String mergeChangeOrderToBody( String bodyTemplate ) {
        bodyTemplate = bodyTemplate.replace( '{!Change_Order__c.Change_Order_Sent_Date__c}', this.changeOrder.Change_Order_Sent_Date__c != null ? this.changeOrder.Change_Order_Sent_Date__c.format() : Date.today().format() );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Billing_Company_Contact__c}', ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Salutation != null ? this.changeOrder.Proposal__r.Billing_Company_Contact__r.Salutation + ' ' : '' ) +
                                                                                          ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Name != null ? this.changeOrder.Proposal__r.Billing_Company_Contact__r.Name : '' ) +
                                                                                          ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Suffix__c != null ? ', ' + this.changeOrder.Proposal__r.Billing_Company_Contact__r.Suffix__c : '' ) );
        bodyTemplate = bodyTemplate.replace( '{!Change_Order__c.Billing_Company_Contact_Full_Name__c}', ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Salutation != null ? this.changeOrder.Proposal__r.Billing_Company_Contact__r.Salutation + ' ' : '' ) +
                                                                                                        ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Name != null ? this.changeOrder.Proposal__r.Billing_Company_Contact__r.Name : '' ) +
                                                                                                        ( this.changeOrder.Proposal__r.Billing_Company_Contact__r.Suffix__c != null ? ', ' + this.changeOrder.Proposal__r.Billing_Company_Contact__r.Suffix__c : '' ) );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Project_Name__c}', this.changeOrder.Proposal__r.Project_Name__c != null ? this.changeOrder.Proposal__r.Project_Name__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Address_Building_AKA__c}', this.changeOrder.Proposal__r.Address_Building_AKA__c != null ? this.changeOrder.Proposal__r.Address_Building_AKA__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Proposal__c.Floor_s__c}', this.changeOrder.Proposal__r.Floor_s__c != null ? this.changeOrder.Proposal__r.Floor_s__c : '' );
        bodyTemplate = bodyTemplate.replace( '{!Change_Order__c.Number__c}', this.changeOrder.Number__c != null ? String.valueOf( this.changeOrder.Number__c ) : '' );
        bodyTemplate = bodyTemplate.replace( '{!Change_Order_With_Link}', !String.isBlank(documentLink) ? '<a href="' + documentLink + '">change order</a>' : 'change order' );
        return bodyTemplate;
    }

    /* ------------------------------------- Begin RFI ---------------------------------- */
    @TestVisible
    private String getRFISubject(String subjectTemplate) {
        subjectTemplate = mergeField(subjectTemplate, '{!Project_Profile__c.Name}', this.project.Project_Name_For_Email__c); // MRS 6259
        subjectTemplate = mergeField(subjectTemplate, '{!Project_Profile__c.Project_Name__c}', this.project.Project_Name__c);
        subjectTemplate = mergeField(subjectTemplate, '{!Project_Profile__c.Building__r.Name}', this.project.Building__r.Name);
        subjectTemplate = mergeField(subjectTemplate, '{!Project_Profile__c.Floor_s__c}', this.project.Floor_s__c);
        return subjectTemplate.left(225);

    }

    @TestVisible
    private String getRFIBody(String bodyTemplate) {
        if (bodyTemplate.contains('{!sendTo}')) {
            bodyTemplate = bodyTemplate.replace('{!sendTo}', this.sendTo);

        }

        if (bodyTemplate.contains('{!from}')) {
            bodyTemplate = bodyTemplate.replace('{!from}', UserInfo.getName());

        }

        if (bodyTemplate.contains('{!link}')) {
            bodyTemplate = bodyTemplate.replace('{!link}', this.rfiLink);

        }

        if (bodyTemplate.contains('{!completeDate}')) {
            bodyTemplate = bodyTemplate.replace('{!completeDate}', DateUtils.getDatetimeWithTimeShiftByBusinessHours(datetime.now(), '3d').format('MM/dd/yyyy'));

        }

        return bodyTemplate;

    }
    /* ------------------------------------- End RFI ----------------------------------------- */

    /* ------------------------------------- Begin Request Filing Fee ---------------------------------- */
    @TestVisible
    private String getRFFSubject(String subjectTemplate) {
        if (subjectTemplate.contains('{Name}')) {
             subjectTemplate = subjectTemplate.replace('{Name}', getStringValue(this.project.Project_Name_For_Email__c)); // MRS 6259
        }

        if (subjectTemplate.contains('{CustomName}')) {
            subjectTemplate = subjectTemplate.replace('{CustomName}', getStringValue(this.project.Project_Name__c));
        }

        if (subjectTemplate.contains('{Address}')) {
            subjectTemplate = subjectTemplate.replace('{Address}', getStringValue(this.project.Building__r.Name));
        }

        if (subjectTemplate.contains('{Floor}')) {
            subjectTemplate = subjectTemplate.replace('{Floor}', getStringValue(this.project.Floor_s__c));
        }
        return subjectTemplate.left(225);

    }

    @TestVisible
    private String getStandardEmailTemplateBody(String subjectTemplate, Project_Profile__c project) {
        subjectTemplate = mergeCommonInfo(subjectTemplate);
        subjectTemplate = mergeProjectInfo(subjectTemplate, project);
        subjectTemplate = mergeSenderInfo(subjectTemplate, loggedUserStatic);
        return subjectTemplate;

    }

    private String getStandardEmailTemplateBody( String subjectTemplate, Project_Profile__c project, Contact recipient ) {
        subjectTemplate = getStandardEmailTemplateBody( subjectTemplate, project );

        if ( recipient != null && subjectTemplate.contains('{!Contact.First_Name__c}')) {
            subjectTemplate = subjectTemplate.replace('{!Contact.First_Name__c}', getStringValue( recipient.Name_Full__c ));
        }
        return subjectTemplate;
    }


    @TestVisible
    private String getRFFBody(String bodyTemplate) {
        if (!String.isBlank(this.additionalBody)) {
            bodyTemplate = this.additionalBody;

        }
        return bodyTemplate;

    }
    /* ------------------------------------- End Request Filing Fee ---------------------------------- */

    /* ------------------------------------- Begin Forms for Signatures/Seals ---------------------------------- */
    @TestVisible
    private String getFormSignatureSubject(String subjectTemplate) {

        if (subjectTemplate.contains('{Project Name}')) {
             subjectTemplate = subjectTemplate.replace('{Project Name}', getStringValue(this.project.Project_Name__c));

        }

        if (subjectTemplate.contains('{Address}')) {
             subjectTemplate = subjectTemplate.replace('{Address}', getStringValue(this.project.Building__r.Name));

        }

        if (subjectTemplate.contains('{Floor}')) {
             subjectTemplate = subjectTemplate.replace('{Floor}', getStringValue(this.project.Floor_s__c));

        }
        return subjectTemplate.left(225);

    }
    /* ------------------------------------- Begin Forms for Signatures/Seals ---------------------------------- */

    /* ------------------------------------- Begin Standard Template ---------------------------------- */
    @TestVisible
    private String getStandardParsedSubject(String subjectTemplate) {
        if (subjectTemplate.contains('{!Project_Profile__c.Municipal_Agency_ID__c}')) {
             subjectTemplate = subjectTemplate.replace('{!Project_Profile__c.Municipal_Agency_ID__c}', getStringValue(this.project.Municipal_Agency_ID__c));

        }

        if (subjectTemplate.contains('{!Account.Name}')) {
             subjectTemplate = subjectTemplate.replace('{!Account.Name}', getStringValue(this.project.Primary_Company_Name__r.Name));

        }

        if (subjectTemplate.contains('{!Project_Profile__c.Project_Name__c}')) {
             subjectTemplate = subjectTemplate.replace('{!Project_Profile__c.Project_Name__c}', getStringValue(this.project.Project_Name__c));

        }

        if (subjectTemplate.contains('{!Project_Profile__c.Project_Address__c}')) {
             subjectTemplate = subjectTemplate.replace('{!Project_Profile__c.Project_Address__c}', getStringValue(this.project.Project_Address__c));

        }

        if (subjectTemplate.contains('{!Project_Profile__c.Floor_s__c}')) {
             subjectTemplate = subjectTemplate.replace('{!Project_Profile__c.Floor_s__c}', getStringValue(this.project.Floor_s__c));

        }
        subjectTemplate = mergeField(subjectTemplate, '{!Project_Profile__c.Name}', this.project.Project_Name_For_Email__c); // MRS 6259

        return subjectTemplate.left(225);

    }
    /* ------------------------------------- End Standard Template ---------------------------------- */

     /* --------------------------------------- Begin Merge Letter ------------------------------------------- */
    public static String mergeLetterBody(String letterBody, final Project_Profile__c project, final User sender, final Contact recipient) {
        system.debug(LoggingLevel.ERROR, '@@@@@@@@ sender = ' + sender);
        system.debug(LoggingLevel.ERROR, '@@@@@@@@ recipient = ' + recipient);
        letterBody = mergeCommonInfo(letterBody);
        letterBody = mergeProjectInfo(letterBody, project);
        letterBody = mergeCommissionerInfo(letterBody, project);
        letterBody = mergeSenderInfo(letterBody, sender);
        letterBody = mergeRecipientInfo(letterBody, recipient);
        return letterBody;

    }

    private static String mergeCommonInfo(String letterBody) {
        letterBody = mergeField(letterBody, '[DATE]', String.valueOf(date.today()));
        letterBody = mergeField(letterBody, '{!Today}', String.valueOf(date.today()));
        return letterBody;

    }

    private static String mergeCommissionerInfo(String letterBody, final Project_Profile__c project) {
        letterBody = mergeField(letterBody, '[COMMISSIONER NAME]', getStringValue(project.Building__r.Municipality__r.Commissioner__r.Name ));
        letterBody = mergeField(letterBody, '[COMMISSIONER TITLE]', getStringValue(project.Building__r.Municipality__r.Commissioner__r.Title));
        letterBody = mergeField(letterBody, '[COMMISSIONER STREET ADDRESS]', getStringValue(project.Building__r.Municipality__r.Commissioner__r.MailingStreet));
        letterBody = mergeField(letterBody, '[COMMISSIONER CITY STATE ZIP]', getStringValue(project.Building__r.Municipality__r.Commissioner__r.MailingCity) + ' ' +
                                                                             getStringValue(project.Building__r.Municipality__r.Commissioner__r.MailingState)  + ' ' +
                                                                             getStringValue(project.Building__r.Municipality__r.Commissioner__r.MailingPostalCode));
        return letterBody;

    }

    private static String mergeProjectInfo(String letterBody, final Project_Profile__c project) {
        letterBody = mergeField(letterBody, '[PROJECT NAME]', getStringValue(project.Project_Name__c));
        letterBody = mergeField(letterBody, '{!Project_Profile__c.Project_Name__c}', getStringValue(project.Project_Name__c));
        letterBody = mergeField(letterBody, '[PROJECT ADDRESS]', getStringValue(project.Project_Address__c));
        letterBody = mergeField(letterBody, '{!Project_Profile__c.Project_Address__c}', getStringValue(project.Project_Address__c));
        letterBody = mergeField(letterBody, '[FLOORS]', getStringValue(project.Floor_Counting__c));
        letterBody = mergeField(letterBody, '{!Project_Profile__c.Floor_Counting__c}', getStringValue(project.Floor_Counting__c));
        letterBody = mergeField(letterBody, '{!Project_Profile__c.Municipal_Agency_ID__c}', getStringValue(project.Municipal_Agency_ID__c));
        return letterBody;

    }

    private static String mergeSenderInfo(String letterBody, final User sender) {
        letterBody = mergeField(letterBody, '{!User.Phone}', getStringValue(sender.Phone));
        letterBody = mergeField(letterBody, '{!User.Name}', getStringValue(sender.Name));
        letterBody = mergeField(letterBody, '{!User.Title}', getStringValue(sender.Title));
        letterBody = mergeField(letterBody, '{!User.Address}', getStringValue(sender.Street) + ' ' +
                                                               getStringValue(sender.City) + ' ' +
                                                               getStringValue(sender.State) + ' ' +
                                                               getStringValue(sender.PostalCode) + ' ' +
                                                               getStringValue(sender.Country));
        letterBody = mergeField(letterBody, '{!User.Office_Number__c}', getStringValue(sender.Office_Number__c));
        return letterBody;

    }

    private static String mergeRecipientInfo(String letterBody, final Contact recipient) {
        letterBody = mergeField(letterBody, '[NAME]', getStringValue(recipient.Name));
        letterBody = mergeField(letterBody, '[SALUTATION]', getStringValue(recipient.Salutation));
        letterBody = mergeField(letterBody, '[LAST NAME]', getStringValue(recipient.LastName));
        letterBody = mergeField(letterBody, '[COMPANY/AGENCY]', getStringValue(recipient.Account.Name));
        letterBody = mergeField(letterBody, '[CITY]', getStringValue(recipient.MailingCity));
        letterBody = mergeField(letterBody, '[STATE]', getStringValue(recipient.MailingState));
        letterBody = mergeField(letterBody, '[ZIP]', getStringValue(recipient.MailingPostalCode));
        letterBody = mergeField(letterBody, '[ADDRESS]', getStringValue(recipient.MailingStreet) + ' ' +
                                                         getStringValue(recipient.MailingCity) + ' ' +
                                                         getStringValue(recipient.MailingState) + ' ' +
                                                         getStringValue(recipient.MailingPostalCode) + ' ' +
                                                         getStringValue(recipient.MailingCountry));

        letterBody = mergeField(letterBody, '{!Contact.First_Name__c}', getStringValue(recipient.Name));
        return letterBody;

    }
    /* --------------------------------------- End Merge Letter ------------------------------------------- */

    @TestVisible
    private static String mergeField(String message, String mergeField, String value) {
        return message.contains(mergeField) ? message.replace(mergeField, getStringValue(value)) : message;

    }

    @TestVisible
    private static String getStringValue(String value) {
        return String.isBlank(value) ? '' : value;

    }

}