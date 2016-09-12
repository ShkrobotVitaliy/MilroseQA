public class TermsAndConditionsServices {

    public static String getContractClauses( Proposal__c proposal ) {
        String res = '';
        res += '<div><strong>Cancellation Clause</strong></div>' +
        '<div style="text-align: justify;">Client or Milrose upon 5 days prior written notice may terminate this agreement with or without cause. ' +
        'Milrose shall be compensated as provided for in this agreement for the services performed through the date of termination.</div>';
        if( proposal == null || proposal.Id == null || new Set<String>{ 'NY', 'New York', 'LI', 'Long Island' }.contains( proposal.Address__r.Region__c ) ) {
            res += '<div> </div>' +
            '<div><strong>Sales Tax Exception Notice</strong></div>' +
            '<div style="text-align: justify;">In accordance with New York Tax Law Sections 1105(c)(1) and 1105(c)(9), as well as the New York State ' +
            'Department of Taxation and Finance&#39;s clarifying guidance in TSB-M-10(7)S, certain consulting services provided by Milrose Consultants, Inc. ' +
            'are subject to New York sales tax. Please note that providing a Certificate of Capital Improvement does not exempt the taxable services ' +
            'provided by Milrose. To the extent the services are subject to New York sales tax, it is understood and agreed that said sales tax shall be ' +
            'paid by the Client.</div>';
        }
        res += '<div> </div>' +
        '<div><strong>Exclusionary Clause</strong></div>' +
        '<div style="text-align: justify;">It is understood and agreed by the parties hereto that should Milrose Consultants, Inc. be found liable, ' +
        'among other things, under the theories of breach of contract or negligence, or any other theory of liability, its liability will be limited ' +
        'to the amount paid by Client for the individual service promised by Milrose that is claimed to have caused or contributed to, either directly ' +
        'or indirectly, the damages claimed by Client. Moreover, Milrose and Client waive consequential damages for claims, disputes or other matters ' +
        'in question as against each other arising out of the services herein, including loss of use and lost profit.</div>' +
        '<div> </div>' +
        '<div><strong>Additional Services</strong></div>' +
        '<div style="text-align: justify;">If Milrose is requested to perform any additional services not set forth in this Agreement, it shall perform ' +
        'said services pursuant its standard rates, which are available upon request. Milrose will endeavor to obtain written approval prior to performing ' +
        'any additional services provided Milrose is furnished with at least forty-eight (48) hours advance notice before having to render said service.</div>' +
        '<div> </div>' +
        '<div><strong>Progress Billing</strong></div>' + //MRS-6953
        '<div style="text-align: justify;">Milrose bills certain services in installments upon the completion of key milestones for that service. ' +
        'Services subject to installment billing are: New Building Applications; Alteration Type 1 Applications; Applications related to Fire Alarm, ' +
        'Sprinkler, Standpipe, Fire Protection Plan, and Place of Assembly; Certificate of Occupancy Services; and Letters of Completion.</div>';
        return res;
    }

    public static String getTncPage1Column1( Proposal__c proposal ) {
        String res = '';
        res += '<div><strong>1. STANDARD OF CARE</strong></div>' +
        '<div style="text-align: justify;">Milrose shall perform its services consistent with the skill and care ordinarily provided by such consultants ' +
        'practicing in the same or similar locality under the same or similar circumstances. The Client acknowledges that Milrose’s services will be rendered ' +
        'without any warranties, express or implied and further acknowledges that Milrose will not be rendering any architectural, engineering or other ' +
        'professional services and shall not be responsible for any errors or omissions with said services as rendered by others.</div>' +
        '<div> </div>' +
        '<div><strong>2. INDEPENDENT CONTRACTOR</strong></div><div style="text-align: justify;">Both the Client and Milrose agree that Milrose will act as an ' +
        'independent contractor in the performance of its duties under this Agreement.</div>' +
        '<div> </div>' +
        '<div><strong>3. CONFIDENTIAL INFORMATION</strong></div>' +
        '<div style="text-align: justify;">Milrose agrees that any information received by it during any furtherance of its obligations under this Agreement ' +
        'which concerns the personal financial or other affairs of the Client will be treated by Milrose in full confidence and will not be revealed to ' +
        'any other persons, firms or organizations.</div>' +
        '<div> </div>' +
        '<div><strong>4. CONSEQUENTIAL DAMAGES</strong></div>' +
        '<div style="text-align: justify;">Milrose and Client waive consequential damages for claims, disputes or other matters in question arising out of ' +
        'or relating to this Agreement, including loss of use and lost profit.</div>' +
        '<div> </div>' +
        '<div><strong>5. CLIENT RESPONSIBILITY</strong></div>' +
        '<div style="text-align: justify;">The Client must promptly and fully cooperate with Milrose on this project. The Client must timely provide upon ' +
        'request by Milrose all information relevant to the subject matter of this Agreement. The Client must pay promptly when due all invoices as required ' +
        'by this Agreement. Pending resolution of any dispute, the Client shall continue to make payments of all amounts due. If the Client does not comply with ' +
        'these requirements, Milrose may either suspend services, until such time as the Client, at Milrose’s sole discretion, satisfies the requirements herein, ' +
        'or withdraw from representing the Client and terminate this Agreement.</div>' +
        '<div> </div>' +
        '<div><strong>6. THIRD PARTY RESPONSIBILITY</strong></div>' +
        '<div style="text-align: justify;">If any licensed third party professionals assigned to this project do not comply with the project requirements i.e. ' +
        'sprinkler, plumbing, and any other special inspections within a reasonable length of time, Milrose will not be obligated or responsible for the ' +
        'ramifications of the incomplete actions that are required with the project due to lack of action taken by said third party professionals.</div>' +
        '<div> </div>' +
        '<div><strong>7. LIMITATION OF LIABILITY</strong></div>' +
        '<div style="text-align: justify;">It is understood and agreed by the parties hereto that should Milrose be found liable, among other things, under the ' +
        'theories of breach of contract or negligence, or any other theory of liability, its liability will be limited to the amount paid by Client for the ' +
        'individual service promised by Milrose that is claimed to have caused or contributed to, either directly or indirectly, the damages claimed by Client.</div>';
        return res;
    }

    public static String getTncPage1Column2( Proposal__c proposal ) {
        String res = '';
        res += '<div><strong>8. NO RESPONSIBILITY FOR CONSTRUCTION WORK</strong></div>' +
        '<div style="text-align: justify;">Milrose shall not have control over, charge of, or responsibility for the construction means, methods, techniques, ' +
        'sequences or procedures, or for safety precautions and programs in connection with any construction work and shall not be responsible for acts or ' +
        'omissions of any contractor or of any other persons or entities performing construction work.</div>' +
        '<div> </div>' +
        '<div><strong>9. TERMINATION OR SUSPENSION OF SERVICES</strong></div>' +
        '<div style="text-align: justify;">In the event Milrose, at its sole discretion, determines that the Client is in violation of any of its obligations as ' +
        'set forth herein, or in the event the Client sells or conveys the real property subject to this Agreement, Milrose may elect in its sole discretion to ' +
        'either: (i) terminate this Agreement by five (5) days written notice of such termination to Client at which time Milrose shall be compensated as provided ' +
        'for in this Agreement for all services performed by Milrose up through the date of termination; or, (ii) suspend the performance of its obligations in ' +
        'this Agreement until such time as Milrose in its sole discretion determines that the Client has satisfactorily cured said violation. Milrose shall not ' +
        'be responsible for any delays or any costs or damages arising from same if it suspends services under this provision.</div>' +
        '<div> </div>' +
        '<div><strong>10. NON-SOLICITATION</strong></div>' +
        '<div style="text-align: justify;">The Client acknowledges that Milrose expends considerable resources to recruit, train and integrate its employees. ' +
        'During the term of this Agreement and for a period of 12 months thereafter, the Client shall not directly or indirectly solicit, engage or hire (whether ' +
        'as an employee, contractor or otherwise) any individual who is then, or within the 12 months prior thereto was, an employee of Milrose and had at any ' +
        'time been assigned by Milrose to perform services for the benefit of Client, except with the prior written consent of Milrose. In the event the Client ' +
        'breaches this covenant, in addition to all other remedies available to Milrose, the Client shall pay Milrose a conversion fee equal to twice the ' +
        'individual’s most recent annual rate of compensation with Milrose.</div>' +
        '<div> </div>' +
        '<div><strong>11. COMPLETE AGREEMENT</strong></div>' +
        '<div style="text-align: justify;">Any changes or additions to the services provided herein shall be in writing, subject to the acceptance by Milrose ' +
        'and the Client at a price to be agreed upon. This Agreement constitutes the entire Agreement between the parties hereto, and no other provision, expressed ' +
        'or implied, shall be binding. This Agreement is the expression of the Agreement between Milrose and the Client and incorporates and supersedes all prior ' +
        'negotiations, correspondence and agreements.</div>' +
        '<div> </div>' +
        '<div><strong>12. DELAYS</strong></div>' +
        '<div style="text-align: justify;">Milrose will not be responsible for delays caused by, but not limited, to (1) acts of God; (ii) the Client or its agents; ' +
        '(iii) inclement weather, strikes, riots or other civil disturbance, war or government action or inaction; (iv) non-issuance of all required permits; ' +
        '(v) vandalism; (vi) the Client’s failure to make payments when due or other failure to perform under this Agreement; (vii) work performed by others; and ' +
        '(viii) any other reasons beyond Milrose’s control.</div>';
        return res;
    }

    public static String getTncPage2Column1( Proposal__c proposal ) {
        String res = '';
        res += '<div><strong>13. COSTS FOR ENFORCEMENT</strong></div>' +
        '<div style="text-align: justify;">The Client shall be responsible for any and all fees and costs, including reasonable attorney’s fees, incurred by Milrose ' +
        'in connection with enforcing any of the provisions of this Agreement.</div>' +
        '<div> </div>' +
        '<div><strong>14. SURVIVAL</strong></div>' +
        '<div style="text-align: justify;">If any of the terms or conditions in the Agreement or herein, or portions thereof, shall be adjudged null and ' +
        'void, then it is</div>';
        return res;
    }

    public static String getTncPage2Column2( Proposal__c proposal ) {
        String res = '';
        res += '<div style="text-align: justify;">agreed that the remaining terms and conditions herein shall remain intact and be given full force and effect.</div>' +
        '<div> </div>' +
        '<div><strong>15. THIRD-PARTY BENEFICIARIES</strong></div>' +
        '<div style="text-align: justify;">This Agreement does not and is not intended to confer any rights or remedies upon any person other than the parties.</div>';
        return res;
    }

    public static Terms_And_Conditions__c initTncRecord( Id accountId, String type, Integer pageNumber, Boolean setText2 ) {
        return initTncRecord( accountId, type, pageNumber, setText2, '', '' );
    }

    public static Terms_And_Conditions__c initTncRecord( Id accountId, String type, Integer pageNumber, Boolean setText2, String text1, String text2 ) {
        if( setText2 == true ) {
            return new Terms_And_Conditions__c( Account__c = accountId, Type__c = type, Page_Number__c = pageNumber, Text_1__c = text1, Text_2__c = text2 );
        } else {
            return new Terms_And_Conditions__c( Account__c = accountId, Type__c = type, Page_Number__c = pageNumber, Text_1__c = text1 );
        }
    }

    public static TncWrapper populateStandardContractClauses( Proposal__c proposal ) {
        return new TncWrapper( initTncRecord( proposal.Billing_Company_Name__c, CustomTncEditor.CONTRACT_CLAUSES, 1, false, getContractClauses( proposal ), null ), true, true );
    }

    public static List<TncWrapper> populateStandardTermsAndConditions( Proposal__c proposal ) {
        return new List<TncWrapper>{ new TncWrapper( initTncRecord( proposal.Billing_Company_Name__c, CustomTncEditor.TERMS_AND_CONDITIONS, 1, true, getTncPage1Column1( proposal ), getTncPage1Column2( proposal ) ), true, false ),
                                     new TncWrapper( initTncRecord( proposal.Billing_Company_Name__c, CustomTncEditor.TERMS_AND_CONDITIONS, 2, true, getTncPage2Column1( proposal ), getTncPage2Column2( proposal ) ), false, true ) };
    }

    public class TncWrapper {
        public Terms_And_Conditions__c record { get; set; }
        public String data1 { get { return record != null && record.Text_1__c != null ? record.Text_1__c : ''; } }
        public String data2 { get { return record != null && record.Text_2__c != null ? record.Text_2__c : ''; } }
        public Boolean isFirst { get { if( isFirst == null ) isFirst = false; return isFirst; } set; }
        public Boolean isLast { get { if( isLast == null ) isLast = false; return isLast; } set; }

        public TnCWrapper( Terms_And_Conditions__c record ) {
            this.record = record;
        }

        public TnCWrapper( Terms_And_Conditions__c record, Boolean isFirst, Boolean isLast ) {
            this.record = record;
            this.isFirst = isFirst;
            this.isLast = isLast;
        }
    }

    public static List<Terms_And_Conditions__c> getTermsAndConditionsByAccountId( Id accountId ) {
        if( accountId != null ) {
            return [ SELECT Account__c, Text_1__c, Text_2__c, Type__c, Page_Number__c
                     FROM Terms_And_Conditions__c
                     WHERE Account__c = : accountId
                     ORDER BY Page_Number__c ASC NULLS FIRST, LastModifiedDate DESC ];
        } else {
            return new List<Terms_And_Conditions__c>();
        }
    }

}