public with sharing class ProposalWizardServices {
    public static final String WIZARD_PAGEREF = '/apex/ProposalWizard';
    public static final String ASBESTOS_INVESTIGATION_OPTIONS_BY_OTHERS = 'By others. Please provide the contact information for the Client\'s Designation Asbestos Investigator';
    public static final String PROPOSAL_OBJECT_NAME = 'Proposal';
    public static final String SOW_EXISTING_SPACE = 'Existing Space';
    public static final String SOW_NEW_BUILDING = 'New Building';
    public static final String SOW_HUB_PROJECT = 'HUB Project';
    public static final String CHANGE_ORDER_SPLITTER = ';';
    public static final String CHANGE_ORDER_CONTENT = ':';
    public static final String SERVICE_ITEM_SPLITTER = ',';
    public static final String PROPOSAL_DDP_NAME = 'Proposal Document';
    public static final String NON_FEE_PROPOSAL_DDP_NAME = 'Non-Fee Proposal Document';
    public static final String CHANGE_ORDER_DDP_NAME = 'Change Order Document';
    public static final String CHANGE_ORDER_LIGHT_DDP_NAME = 'Change Order Document Light';
    public static final String NO_TEMPLATE_SELECTED = 'No Service Found';
    public static final String CREATE_NEW_PURCHASE_ORDER_TITLE = 'Create New Purchase Order';
    public static final String EDIT_PURCHASE_ORDER_TITLE = 'Edit Purchase Order #';
    public static final String SALES_PERSON_KEYWORD = 'Sales Person';
    public static final String ACCOUNT_MANAGER_KEYWORD = 'Account Manager';
    public static final String CHANGE_ORDER_APPROVAL_TYPE = 'Change Order Approval';
    public static final String CHANGE_ORDER_APPROVE_ACTION = 'Approve';
    public static final String QA_PROFILE = ' (QA)';
    public static final DateTime APPLY_SCOPE_OF_WORK_FUNCTIONALITY = Datetime.newInstance( 2014, 10, 28 );
    public static Integer MAX_NUMBER_OF_DOCUSIGN_CC_USERS = 15;

    public static final String SERVICE_JUNCTIONS_SHOULD_BE_POPULATED_MESSAGE = 'The \'associate floors with services\' checkbox on Step 1 was checked. You should provide at least one floor for each service in this case.';
    public static final String SERVICE_TEMPLATE_FULL_NAME_KEYWORD = 'Full Name';
    public static final String SERVICE_TEMPLATE_UNIT_OF_SERVICE_KEYWORD = 'Unit Of Service';

    //MRS-6966
    public static final List<String> C_FIELDS_TO_GET_FROM_PROPOSAL = new List<String> {'Id', 'Name', 'Owner.Name', 'CreatedById', 'CreatedBy.Name',
                                 'Region__c', 'CreatedDate', 'FREP__c', 'Production_Manager__c', 'PO_Not_Required__c',
                                 'Primary_Company_Name__c', 'Billing_Company_Name__c', 'Primary_Company_Contact__c', 'Accounting_Contact_Company__c', 'Accounting_Contact__c',
                                 'Billing_Company_Contact__c', 'Opportunity__c', 'Partner__c', 'Salesperson__c', 'Account_Executive__c', 'Fulfillment_Office__c',
                                 'Address__c', 'Floor_s__c', 'Project_Name__c', 'Description__c', 'Additional_Documents__c',
                                 'Primary_Client_is_Billing_Client__c', 'Partner_Approval_Required__c', 'Proposal_Expiration_Date__c', 'Proposal_Send_Reminder__c', 'Apply_Discount__c',
                                 'Reimbursable_Items_Basis__c', 'Requested_By__c', 'Rejection_Reason__c', 'Delivery_Method__c', 'Separate_Reimbursables__c', 'Billing_Method__c', 'Frequency__c',
                                 'Special_Instructions_Long__c', 'Billing_day__c', 'No_Document_Shredding__c', 'Invoice_Format__c', 'No_Met_Data_Scanning__c',
                                 'No_Messenger_Fedex__c', 'Expected_Construction_Start_Date__c', 'Expected_Construction_End_Date__c', 'Interval__c', 'Expected_Occupancy_Date__c',
                                 'Expected_Construction_Cost__c', 'Status__c', 'Proposal_Type__c', 'RFP_Attachments__c', 'Roster_Contacts__c', 'Reimbursable_Percentage__c',
                                 'Total_Service_Amount__c', 'Discount_Percentage__c', 'Cost__c', 'Provided_Documents__c', 'Provided_Drawings__c', 'Client_Project__c', 'Quarterly_Month__c',
                                 'Send_Invoices_to_Different_Contact__c', 'IsPhase__c', 'Floor_Counting__c', 'Change_History__c', 'Separate_Phases__c', 'Send_Copy_To__c',
                                 'Proposal_RFP_Request_Date__c', 'Project_Team__c', 'Send_Reminder_To_Creator__c', 'Internal_Reviewer__c', 'Internal_Reviewer_Reminder__c',
                                 'Proposal_Sent_Date__c', 'Sales_Tax__c', 'Is_Change_Order__c', 'PO_Required__c', 'MSA__c', 'MSA_Start_Date__c', 'MSA_End_Date__c', 'OwnerId', 'Project_Profile__c',
                                 'Is_Floors_To_Services__c', 'Code_Zoning_Analyst__c', 'Code_Zoning_Analyst_Email__c', 'Mi3_MRC__c', 'Building_AKA__c', 'Is_Mi3_Project_Created__c',
                                 'Additional_To__c', 'Additional_Cc__c', 'SIPS_Coordinator__c', 'Municipal_Authority_Fees__c', 'Projected_DOB_Fee__c', 'General_Proposal_Notes__c',
                                 'Is_Draft__c', 'No_Retainer__c', 'UseDocusign__c', 'Retainer_Amount__c', 'Proposal_Specialist__c', 'Disable_Followups__c', 'Last_Follow_Up_Date__c',
                                 'Follow_Ups_Count__c', 'City__c', 'Is_Landmark__c', 'Is_MTA__c', 'State__c', 'Step__c', 'Zip_Code__c', 'Display_Text_on_Invoice__c', 'SowScopeOfWork__c',
                                 'Asbestos__c', 'Asbestos_Investigation_Options__c', 'Asbestos_Investigator__c', 'SowServicesNeededAPS__c', 'SowServicesNeededOther__c',
                                 'SowNoneOfTheAbove__c', 'SowUseEgressOccupancy__c', 'SowMultiplePhases__c', 'SowOccupandLoadDiffers__c', 'SowMeetingConfRooms__c',
                                 'SowTemporarySprinkler__c', 'SowOpenFloorConnections__c', 'SowSpecialPlaces__c', 'SowTenantsWithGlassDoors__c', 'SowExteriorSignage__c',
                                 'SowFuelStorage__c', 'SowExteriorWork__c', 'SowSpaceAlterType__c', 'SowACUnits__c', 'SowACUnitsNumber__c', 'Sow_ir_override__c', 'Sow_id_override__c',
                                 'Sow_er_override__c', 'Sow_sp_override__c', 'Sow_sm_override__c', 'SowFencePermit__c', ' Sow_ir_aw__c', 'Sow_ir_mw__c', 'Sow_ir_pl__c', 'Sow_ir_st__c',
                                 'Sow_id_aw__c', 'Sow_id_mw__c', 'Sow_id_pl__c', 'Sow_id_st__c', 'Sow_er_be__c', 'Sow_er_ba__c', 'Sow_er_bas__c', 'Sow_sp_ssb__c', 'Sow_sp_ssd__c', 'Sow_sp_tls__c',
                                 'Sow_sm_bow__c', 'Sow_sm_dwk__c', 'Resource__c', 'Proposal_Awarded_Date__c', 'Received_Signed_Proposal__c',
                                 'Discounted_Total_Service_Amount__c', 'Percents_View_State__c', 'Proposal_Sender__c',
								 'optView_Hide_Canceled_Change_Orders__c', 'optView_Hide_Completed_Services__c', 'optView_Hide_Inactive_Services__c', 'optView_Percents_Limit__c', 'List_of_Attached_Docs__c'}; // MRS 7280 7381

    //MRS-6966
    public static final List<String> R_FIELDS_TO_GET_FROM_PROPOSAL = new List<String> { 'Proposal_Specialist__r.Name', 'Address__r.Street__c', 'Project_Profile__r.OwnerId',
                                 'Project_Profile__r.Account_Executive__c', 'Project_Profile__r.Production_Manager__c', 'Accounting_Contact_Company__r.A_R_coordinator__c',
                                 'Project_Profile__r.Name', 'Project_Profile__r.Project_Team__c', 'Project_Profile__r.Project_Manager__c', 'Project_Profile__r.Project_Member__c',
                                 'Billing_Company_Name__r.c2g__CODASalesTaxStatus__c', 'Project_Profile__r.Project_State__c', 'Billing_Company_Name__r.Accounting_Hold__c' };
                                                                                                //MRS 6800 Project_Profile__r.Project_State__c + Billing_Company_Name__r.Accounting_Hold__c
                                                                                                //MRS 7096 Billing_Company_Name__c.c2g__CODASalesTaxStatus__c

    public static List<String> getProposalRequiredFields( Boolean isMi3, DateTime createdDate, Boolean isDraft ) {
        List<String> fields = new List<String>{ 'Primary_Company_Name__c', 'Primary_Company_Contact__c', 'Billing_Company_Name__c',
                                                'Billing_Company_Contact__c', 'Salesperson__c', 'Fulfillment_Office__c', 'Address__c',
                                                'Project_Name__c', 'Proposal_Expiration_Date__c', 'Description__c',
                                                'Expected_Construction_Start_Date__c', 'Proposal_RFP_Request_Date__c', 'Proposal_Type__c' };
        if( isScopeOfWorkRequired( isMi3, createdDate, isDraft ) ) {
            fields.add( 'sowScopeOfWork__c' );
        }
        return fields;
    }

    public static Set<String> getUserNamesForAccountManagerDropdown() {
        return new Set<String>{ 'Anthony Caranante', 'Elliot Chiger', 'Jenny Mendez', 'Jill Daniele', 'Kenneth McVeigh',
                                'Neal Dennison', 'Rachel Cafarelli', 'Rossano Dolor', 'Stacy Hager', 'Alfonso Cava',
                                'Jack Sharkey', 'Christopher Mullen' };
    }
    public static Set<String> getUserNamesForSalespersonDropdown() {
        return new Set<String>{ 'William Rose', 'Louis Milo', 'Gustavo Mazza', 'Domenick Chieco', 'Anthony Caranante',
                                'Elliot Chiger', 'Jenny Mendez', 'Jill Daniele', 'Kenneth McVeigh', 'Neal Dennison',
                                'Rachel Cafarelli', 'Rossano Dolor', 'Stacy Hager', 'Alfonso Cava', 'Jack Sharkey',
                                'Christopher Mullen', 'Greg Tabone', 'Maria McGill' };
    }
    public static Set<String> getUserNamesForPartnerDropdown() {
        return new Set<String>{ 'Alfonso Cava', 'Mindy Zayas' };
    }

    public static Building__c getBuildingById( String Id ) {
        if (!String.isBlank( Id ) ) {
            return [ SELECT Id, State__c, PostalCode__c, City__c, Municipality__c, Municipality_Name__c,
                            Building_Owner__c, Owner_Company__c, Owner_Company_Name__c, Region__c,
                            Is_MTA__c, Is_Landmark__c, Little_E_Designation__c, Loft_Board_Authority__c,
							Flood_Plain__c // MRS 7171
                     FROM Building__c
                     WHERE Id = : Id]; //Description__c
        } else {
            return null;
        }
    }

    public static Map<String, Map<String, String>> getAccountIdToContactIdToContactName( Set<String> accountIds ) {
        Map<String, Map<String, String>> accountIdToContactIdToContactName = new Map<String, Map<String, String>>();
        Set<String> filteredAccountIds = new Set<String>();
        for( String accountId : accountIds ) {
            filteredAccountIds.add( accountId );
            accountIdToContactIdToContactName.put( accountId, new Map<String, String>() );
        }
        if( !filteredAccountIds.isEmpty() ) {
            for( Contact item : [ SELECT Id, Name, AccountId FROM Contact WHERE AccountId IN : filteredAccountIds AND Is_Active__c = true AND EmailBouncedDate = null ] ) {
                accountIdToContactIdToContactName.get( item.AccountId ).put( item.Id, item.Name );
            }
        }
        return accountIdToContactIdToContactName;
    }

    public static Map<String, Map<String, String>> getUserByProfileMap( Set<String> profiles ) {
        Map<String, Map<String, String>> usersByProfilesMap = new Map<String, Map<String, String>>();

        for( String profileName : profiles ) {
            usersByProfilesMap.put( profileName, new Map<String, String>() );
        }

        Map<String, String> usersByProfilesMapCurrent;
        for( User userItem : [ SELECT Id, Name, Email, Profile.Name FROM User WHERE Profile.Name IN :usersByProfilesMap.keySet() AND IsActive = true LIMIT 1000 ] ) {
            usersByProfilesMapCurrent = usersByProfilesMap.get( userItem.Profile.Name );
            usersByProfilesMapCurrent.put( userItem.Id, userItem.Name );
            usersByProfilesMap.put( userItem.Profile.Name, usersByProfilesMapCurrent );
        }
        return usersByProfilesMap;
    }

    public static void doSort( List<Selectoption> opts ) {
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        Integer suffix = 1;
        for( Selectoption opt : opts ) {
            mapping.put( ( opt.getLabel() + suffix++ ), opt );
        }

        List<String> sortKeys = new List<String>();
        sortKeys.addAll( mapping.keySet() );
        sortKeys.sort();
        opts.clear();

        for( String key : sortKeys ) {
            opts.add( mapping.get(key) );
        }
    }

    public static List<SelectOption> generateOptions( List<Schema.PicklistEntry> picklistEntry, Map<String, String> picklistMap,
                                                      Boolean addNone, Boolean sortOptions, Boolean isBackwardsSort ) {
        List<SelectOption> options = new List<SelectOption>();
        if( addNone ) options.add( new SelectOption( '', '-- None --' ) );
        if( picklistEntry != null ) {
            for ( Schema.PicklistEntry items : picklistEntry ) {
                options.add( new SelectOption( items.getLabel(), items.getValue() ) );
            }
        }
        if( picklistMap != null ) {
            for ( String itemsId : picklistMap.keySet() ) {
                options.add( new SelectOption( itemsId , picklistMap.get( itemsId ) ) );
            }
        }
        if( sortOptions ) {
            //options.sort();
            doSort(options);
        }
        if( isBackwardsSort && !options.isEmpty() ) {
            List<SelectOption> optionsTemp = new List<SelectOption>();
            for( Integer i = options.size() - 1; i >= 0; i-- ) {
                optionsTemp.add( options[i] );
            }
            options = optionsTemp;
        }
        return options;
    }

    public static List<SelectOption> generateOptions( List<Schema.PicklistEntry> picklistEntry, Map<String, String> picklistMap,
                                                      Boolean addNone, Boolean sortOptions ) {
        return generateOptions(picklistEntry, picklistMap, addNone, sortOptions, false);
    }

    public static List<SelectOption> generateOptions(List<String> values) {
        return generateOptions(values, true);
    }

    public static List<SelectOption> generateOptions(List<String> values, Boolean addNone) {
        List<SelectOption> options = new List<SelectOption>();
        if( addNone ) options.add( new SelectOption ( '', '-- None --' ) );
        if( values != null ) {
            for( String item : values ) {
                options.add( new SelectOption ( item, item ) );
            }
        }
        return options;
    }

    public static Map<String, String> getPicklistOptions( Schema.sObjectType objectname, String field ) {
        Map<String, String> picklistOptions = new Map<String, String>();
        for( Schema.PicklistEntry item : objectname.getDescribe().fields.getMap().get( field ).getDescribe().getPicklistValues() ) {
            picklistOptions.put( item.getValue(), item.getValue() );
        }
        return picklistOptions;
    }

    /**
     * Get picklist values for single field from Service_Template__c.
     * Filter list by values from Service_Template__c.
     */
	public static List<List<String>> getPicklistOptionsForServiceTemplateJS(String sTypeID, String region, String category, String type, String subtype, String field) { //MRS 7335
	
        // build SOQL query
        String query = 'SELECT COUNT(id), ' + field + ' FROM Service_Template__c ';
        // add dynamic params
        List<String> whereConditions = new List<String>();
        whereConditions.add('RecordTypeId = \'' + sTypeID + '\'');
        if (!String.isBlank(region)) {
            String regionName = '';
            if(    region == RegionServices.REGION_NAME_MASSACHUSETTS
                || region == RegionServices.REGION_NAME_RHODE_ISLAND
                || region == RegionServices.REGION_NAME_MAINE
                || region == RegionServices.REGION_NAME_VERMONT
                || region == RegionServices.REGION_NAME_NEW_HAMPSHIRE) { // MRS 6581
                regionName = String.escapeSingleQuotes( RegionServices.REGION_NAME_CT );
            } else if(region == RegionServices.REGION_NAME_VIRGINIA) {
                regionName = String.escapeSingleQuotes( RegionServices.REGION_NAME_WASH );
            } else {
                regionName = String.escapeSingleQuotes(region);
            }
            whereConditions.add( 'Region__c = \'' + regionName + '\'' );
        }
        while( true ) {
            if( field == 'Category__c' ) break;
            if(!String.isBlank(category)) {
                whereConditions.add('Category__c = \'' + String.escapeSingleQuotes(category) + '\'');
            }
            if( field == 'Type__c' ) break;
            if(!String.isBlank(type)) {
                whereConditions.add('Type__c = \'' + String.escapeSingleQuotes(type) + '\'');
            }
            if( field == 'Subtype__c' ) break;
            if(!String.isBlank(subtype)) {
                whereConditions.add('Subtype__c = \'' + String.escapeSingleQuotes(subtype) + '\'');
            }
            break;
        }
		whereConditions.add('Deactivate__c = false'); //MRS 7476
        query += ' WHERE ' + String.join( whereConditions, ' AND ' );
        query += ' GROUP BY ' + field + ' ORDER BY ' + field;

        List<List<String>> options = new List<List<String>>();
        for (AggregateResult aggrRecord: Database.query(query)) {
            Object fieldValue = aggrRecord.get(field);
            if (fieldValue != null) options.add(new List<String> { (String) fieldValue });
        }
        return options;
    }

    public static Map<String, List<String>> getFrequencyToBillingDay() {
        List<String> dayNumbers = new List<String>();
        for( Integer i = 1; i <= 31; i++ ) {
            dayNumbers.add( String.valueOf( i ) );
        }
        Map<String, List<String>> frequencyToBillingDay = new Map<String, List<String>>{ 'Weekly' => new List<String>{'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'},
                                                                                         'Monthly' => new List<String>( dayNumbers ) };
        frequencyToBillingDay.put( 'Quarterly', frequencyToBillingDay.get( 'Monthly' ) );
        return frequencyToBillingDay;
    }

    public static List<String> getPicklistOptionsForApprovedVendors( ) {
        List<String> vendorNames = new List<String>();
        for( Account acc : AccountServices.getApprovedVendors() ){
            vendorNames.add( acc.Name );
        }
        return vendorNames;
    }

    public static String getDefaultPicklistValue( Schema.sObjectType objectname, String field ) {
        if( String.valueOf(objectname) == 'Proposal__c' && field == 'Proposal_Type__c' ) { //MRS-7049
            return '';
        }
        List<Schema.PicklistEntry> p = objectname.getDescribe().fields.getMap().get( field ).getDescribe().getPicklistValues();
        for( Schema.PicklistEntry entry : p ) {
            if( entry.isDefaultValue() == true ) {
                return entry.getValue();
                break;
            }
            if( String.valueOf(objectname) == 'Account' ) {
                if( field == 'Frequency__c' ) return 'Monthly';
                if( field == 'Billing_day__c' ) return '1';
            }
        }
        return null;
    }

    public static Boolean getDefaultBooleanValue( Schema.sObjectType objectname, String field ) {
        Map<String, Set<String>> defTrueValues = new Map<String, Set<String>>{ 'Account' => new Set<String>{ 'Separate_Reimbursables__c' },
                                                                               'Proposal__c' => new Set<String>{ 'Is_Draft__c',
                                                                                                                 'Asbestos__c',
                                                                                                                 'Reimbursable_Items_Basis__c',
                                                                                                                 'Partner_Approval_Required__c',
                                                                                                                 'UseDocusign__c' } };
        if( defTrueValues.get( String.valueOf( objectname ) ) != null && defTrueValues.get( String.valueOf( objectname ) ).contains( field ) ) {
            return true;
        }
        return false;
    }

    public static Proposal__c getProposal( Id proposalId ) {
        List<Proposal__c> proposals = new List<Proposal__c>();
        if( !String.isEmpty( proposalId ) ) {
            //MRS 6966
            String request = '';
            for( String tempStr : C_FIELDS_TO_GET_FROM_PROPOSAL ) request += tempStr + ',';
            for( String tempStr : R_FIELDS_TO_GET_FROM_PROPOSAL ) request += tempStr + ',';
            if( request.endsWith(',') ) request = request.substring( 0, request.lastIndexOf( ',' ) );
            proposals = Database.query('SELECT ' + request + ' FROM Proposal__c WHERE Id =: proposalId');
        }
        if( !proposals.isEmpty() ) {
            Proposal__c proposal = proposals.get(0);
            if( proposal.Step__c == null ) {
                proposal.Step__c = 1;
            }
            return proposal;
        } else {
            return initProposal();
        }
    }

    public static Proposal__c getProposalForStep2( Id proposalId ) {
        Proposal__c proposal;
        if( proposalId != null ) {
            proposal = [ SELECT Id, Is_Draft__c, Address__r.Municipality__r.Region__r.Name, Status__c, Mi3_MRC__c,
                                Expected_Construction_Start_Date__c, CreatedDate, OwnerId, Proposal_Specialist__c,
                                Code_Zoning_Analyst__c, Internal_Reviewer__c,

                                sowScopeOfWork__c, Asbestos__c, Asbestos_Investigation_Options__c, Asbestos_Investigator__c,
                                sowServicesNeededAPS__c, sowServicesNeededOther__c, sowNoneOfTheAbove__c, sowUseEgressOccupancy__c,
                                sowMultiplePhases__c, sowOccupandLoadDiffers__c, sowMeetingConfRooms__c, sowTemporarySprinkler__c,
                                sowOpenFloorConnections__c, sowSpecialPlaces__c, sowTenantsWithGlassDoors__c, sowExteriorSignage__c,
                                sowFuelStorage__c, sowExteriorWork__c, sowSpaceAlterType__c, sowACUnits__c, sowACUnitsNumber__c,
                                sow_ir_override__c, sow_id_override__c, sow_er_override__c, sow_sp_override__c, sow_sm_override__c,
                                sowFencePermit__c,  sow_ir_aw__c, sow_ir_mw__c, sow_ir_pl__c, sow_ir_st__c, sow_id_aw__c, sow_id_mw__c,
                                sow_id_pl__c, sow_id_st__c, sow_er_be__c, sow_er_ba__c, sow_er_bas__c, sow_sp_ssb__c, sow_sp_ssd__c,
                                sow_sp_tls__c, sow_sm_bow__c, sow_sm_dwk__c
                         FROM Proposal__c
                         WHERE Id = : proposalId ];
        } else {
            proposal = ProposalWizardServices.initProposalForStep2( proposal );
            proposal.Is_Draft__c = true;
        }
        return proposal;
    }

    public static Proposal__c initProposal() {
        Proposal__c proposal = new Proposal__c();
        proposal.Proposal_Specialist__c = UserInfo.getUserId();
        proposal.Is_Draft__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Is_Draft__c');
        proposal.Version__c = null; //Decimal.valueOf( '0.00' Proposal__c.Version__c.getDescribe().getDefaultValueFormula() );
        proposal.Status__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Status__c');
        proposal.Fulfillment_Office__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Fulfillment_Office__c');
        proposal.Proposal_Type__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Proposal_Type__c');
        proposal.Additional_Documents__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'Additional_Documents__c');
        proposal.Delivery_Method__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Delivery_Method__c');
        proposal.Disable_Followups__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Disable_Followups__c');
        proposal.Billing_Method__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Billing_Method__c');
        proposal.Frequency__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Frequency__c');
        proposal.Billing_day__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Billing_day__c');
        proposal.Invoice_Format__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Invoice_Format__c');
        proposal.Separate_Reimbursables__c = getDefaultBooleanValue( Account.sObjectType, 'Separate_Reimbursables__c');
        proposal.No_Document_Shredding__c = getDefaultBooleanValue( Account.sObjectType, 'No_Document_Shredding__c');
        proposal.No_Met_Data_Scanning__c = getDefaultBooleanValue( Account.sObjectType, 'No_Met_Data_Scanning__c');
        proposal.No_Messenger_Fedex__c = getDefaultBooleanValue( Account.sObjectType, 'No_Messenger_Fedex__c');
        proposal.No_Retainer__c = getDefaultBooleanValue( Account.sObjectType, 'No_Retainer__c');
        proposal.Primary_Client_is_Billing_Client__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Primary_Client_is_Billing_Client__c');
        proposal.Reimbursable_Items_Basis__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Reimbursable_Items_Basis__c');
        proposal.Reimbursable_Percentage__c = 15;
        proposal.Discount_Percentage__c = 10;
        proposal.Provided_Documents__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Provided_Documents__c');
        proposal.Provided_Drawings__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Provided_Drawings__c');
        proposal.Partner_Approval_Required__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Partner_Approval_Required__c');
        proposal.Floor_Counting__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'Floor_Counting__c');
        proposal.Interval__c = false;
        proposal.Is_Floors_To_Services__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'Is_Floors_To_Services__c');
        proposal.UseDocusign__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'UseDocusign__c');
        proposal.Proposal_Expiration_Date__c = DateTime.now().addMonths(6);
        proposal.Proposal_RFP_Request_Date__c = DateTime.now();
        proposal.is_Change_Order__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'is_Change_Order__c');
        proposal.Step__c = 1;
		proposal.optView_Percents_Limit__c = 95; //MRS 7280
        proposal.Building_AKA__c = null;

        initProposalForStep2( proposal );
        return proposal;
    }

    public static Proposal__c initProposalForStep2( Proposal__c proposal ) {
        if( proposal == null ) proposal = new Proposal__c();
        proposal.Is_Draft__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'Is_Draft__c');
        proposal.Status__c = getDefaultPicklistValue( Proposal__c.sObjectType, 'Status__c');

        proposal.sowScopeOfWork__c = null; //getDefaultPicklistValue(Proposal__c.sObjectType, 'sowScopeOfWork__c');
        proposal.Asbestos__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'Asbestos__c');
        proposal.Asbestos_Investigation_Options__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'Asbestos_Investigation_Options__c');
        proposal.Asbestos_Investigator__c = null;
        proposal.sowServicesNeededAPS__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'sowServicesNeededAPS__c');
        proposal.sowServicesNeededOther__c = getDefaultBooleanValue( Proposal__c.sObjectType, 'sowServicesNeededOther__c');
        proposal.sowNoneOfTheAbove__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowNoneOfTheAbove__c');
        proposal.sowUseEgressOccupancy__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowUseEgressOccupancy__c');
        proposal.sowMultiplePhases__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowMultiplePhases__c');
        proposal.sowOccupandLoadDiffers__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowOccupandLoadDiffers__c');
        proposal.sowMeetingConfRooms__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowMeetingConfRooms__c');
        proposal.sowTemporarySprinkler__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowTemporarySprinkler__c');
        proposal.sowOpenFloorConnections__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowOpenFloorConnections__c');
        proposal.sowSpecialPlaces__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowSpecialPlaces__c');
        proposal.sowTenantsWithGlassDoors__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowTenantsWithGlassDoors__c');
        proposal.sowExteriorSignage__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowExteriorSignage__c');
        proposal.sowFuelStorage__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowFuelStorage__c');
        proposal.sowExteriorWork__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowExteriorWork__c');
        proposal.sowSpaceAlterType__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sowSpaceAlterType__c');
        proposal.sowACUnits__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowACUnits__c');
        proposal.sowACUnitsNumber__c = 1;
        proposal.sow_ir_override__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_ir_override__c');
        proposal.sow_id_override__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_id_override__c');
        proposal.sow_er_override__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_er_override__c');
        proposal.sow_sp_override__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_sp_override__c');
        proposal.sow_sm_override__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_sm_override__c');
        proposal.sowFencePermit__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sowFencePermit__c');
        proposal.sow_ir_aw__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_ir_aw__c');
        proposal.sow_ir_mw__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_ir_mw__c');
        proposal.sow_ir_pl__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_ir_pl__c');
        proposal.sow_ir_st__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_ir_st__c');
        proposal.sow_id_aw__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_id_aw__c');
        proposal.sow_id_mw__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_id_mw__c');
        proposal.sow_id_pl__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_id_pl__c');
        proposal.sow_id_st__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_id_st__c');
        proposal.sow_er_be__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_er_be__c');
        proposal.sow_er_ba__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_er_ba__c');
        proposal.sow_er_bas__c = getDefaultPicklistValue(Proposal__c.sObjectType, 'sow_er_bas__c');
        proposal.sow_sp_ssb__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_sp_ssb__c');
        proposal.sow_sp_ssd__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_sp_ssd__c');
        proposal.sow_sp_tls__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_sp_tls__c');
        proposal.sow_sm_bow__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_sm_bow__c');
        proposal.sow_sm_dwk__c = getDefaultBooleanValue(Proposal__c.sObjectType, 'sow_sm_dwk__c');
        return proposal;
    }

    public static void mergeFieldsFromStep2WithProposal( Proposal__c proposal, String serializedProposal ) {
        Proposal__c proposalFromStep2 = (Proposal__c)JSON.deserialize( serializedProposal.replace( '\\\'' , '\'' ).replace( '\\\\', '\\' ), Proposal__c.class );
        proposal.sowScopeOfWork__c = proposalFromStep2.sowScopeOfWork__c;
        proposal.Asbestos__c = proposalFromStep2.Asbestos__c;
        proposal.Asbestos_Investigation_Options__c = proposalFromStep2.Asbestos_Investigation_Options__c;
        proposal.Asbestos_Investigator__c  = proposalFromStep2.Asbestos_Investigator__c;
        proposal.sowServicesNeededAPS__c = proposalFromStep2.sowServicesNeededAPS__c;
        proposal.sowServicesNeededOther__c = proposalFromStep2.sowServicesNeededOther__c;
        proposal.sowNoneOfTheAbove__c = proposalFromStep2.sowNoneOfTheAbove__c;
        proposal.sowUseEgressOccupancy__c = proposalFromStep2.sowUseEgressOccupancy__c;
        proposal.sowMultiplePhases__c = proposalFromStep2.sowMultiplePhases__c;
        proposal.sowOccupandLoadDiffers__c = proposalFromStep2.sowOccupandLoadDiffers__c;
        proposal.sowMeetingConfRooms__c = proposalFromStep2.sowMeetingConfRooms__c;
        proposal.sowTemporarySprinkler__c = proposalFromStep2.sowTemporarySprinkler__c;
        proposal.sowOpenFloorConnections__c = proposalFromStep2.sowOpenFloorConnections__c;
        proposal.sowSpecialPlaces__c = proposalFromStep2.sowSpecialPlaces__c;
        proposal.sowTenantsWithGlassDoors__c = proposalFromStep2.sowTenantsWithGlassDoors__c;
        proposal.sowExteriorSignage__c = proposalFromStep2.sowExteriorSignage__c;
        proposal.sowFuelStorage__c = proposalFromStep2.sowFuelStorage__c;
        proposal.sowExteriorWork__c = proposalFromStep2.sowExteriorWork__c;
        proposal.sowSpaceAlterType__c = proposalFromStep2.sowSpaceAlterType__c;
        proposal.sowACUnits__c = proposalFromStep2.sowACUnits__c;
        proposal.sowACUnitsNumber__c = proposalFromStep2.sowACUnitsNumber__c;
        proposal.sow_ir_override__c = proposalFromStep2.sow_ir_override__c;
        proposal.sow_id_override__c = proposalFromStep2.sow_id_override__c;
        proposal.sow_er_override__c = proposalFromStep2.sow_er_override__c;
        proposal.sow_sp_override__c = proposalFromStep2.sow_sp_override__c;
        proposal.sow_sm_override__c = proposalFromStep2.sow_sm_override__c;
        proposal.sowFencePermit__c = proposalFromStep2.sowFencePermit__c;
        proposal.sow_ir_aw__c = proposalFromStep2.sow_ir_aw__c;
        proposal.sow_ir_mw__c = proposalFromStep2.sow_ir_mw__c;
        proposal.sow_ir_pl__c = proposalFromStep2.sow_ir_pl__c;
        proposal.sow_ir_st__c = proposalFromStep2.sow_ir_st__c;
        proposal.sow_id_aw__c = proposalFromStep2.sow_id_aw__c;
        proposal.sow_id_mw__c = proposalFromStep2.sow_id_mw__c;
        proposal.sow_id_pl__c = proposalFromStep2.sow_id_pl__c;
        proposal.sow_id_st__c = proposalFromStep2.sow_id_st__c;
        proposal.sow_er_be__c = proposalFromStep2.sow_er_be__c;
        proposal.sow_er_ba__c = proposalFromStep2.sow_er_ba__c;
        proposal.sow_er_bas__c = proposalFromStep2.sow_er_bas__c;
        proposal.sow_sp_ssb__c = proposalFromStep2.sow_sp_ssb__c;
        proposal.sow_sp_ssd__c = proposalFromStep2.sow_sp_ssd__c;
        proposal.sow_sp_tls__c = proposalFromStep2.sow_sp_tls__c;
        proposal.sow_sm_bow__c = proposalFromStep2.sow_sm_bow__c;
        proposal.sow_sm_dwk__c = proposalFromStep2.sow_sm_dwk__c;
    }

    public static Boolean enableStep2Summary( Proposal__c proposal, Boolean isCZAnalyst, Boolean isPS, Boolean isAdmin ) {
        String proposalStatus = proposal != null ? proposal.Status__c : ProposalServices.PROPOSAL_STATUS_NEW;
        if( proposalStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) {
            return false;
        }
        if( isCZAnalyst && !isPS ) {
            return true;
        }
        if( proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW && ( isCZAnalyst || isAdmin ) ) {
            return true;
        }
        return false;
    }

    public static String getProfileNameById ( Id profileId ){
        Profile profileRecord = [Select Name From Profile where id =: profileId limit 1];
        return  profileRecord == null ? '' : profileRecord.Name;
    }

    public static List<Document> getDocumentsFromDirectory(){
        List<Document> documentList = [SELECT Id, Name, Description FROM Document WHERE Folder.Name =: 'RFP Artifacts'];
        return documentList;
    }

    public static Boolean isSomethingFromSecondSectionActive( Proposal__c proposal ) {
        if( proposal.sowUseEgressOccupancy__c ||
            proposal.sowMultiplePhases__c ||
            proposal.sowOccupandLoadDiffers__c ||
            proposal.sowMeetingConfRooms__c ||
            proposal.sowTemporarySprinkler__c ||
            proposal.sowOpenFloorConnections__c ||
            proposal.sowSpecialPlaces__c ||
            proposal.sowTenantsWithGlassDoors__c ||
            proposal.sowExteriorSignage__c ||
            proposal.sowFuelStorage__c ||
            proposal.sowExteriorWork__c ) return true;
        return false;
    }

    public static Integer getCompleteness( List<String> requiredFields, Proposal__c proposal, boolean hasFloors, List<ServiceModel> serviceModels ) {
        Integer maxCompletenessRate = String.isBlank(String.valueOf(proposal.Id)) ? 100 : 100, countOfFieldsCompleted = 0, countSteps = 0;
        countSteps += requiredFields.size();
        countSteps += proposal.Partner_Approval_Required__c ? 1 : 0;
        countSteps++; //for floors
        for( ServiceModel sm : serviceModels ) {
            if( !sm.isAlternative && sm.isOriginal && sm.getIsServiceGroupRequired() ) {
                countSteps += 1;
                if( !String.isBlank( sm.serviceGroup ) ) {
                    countOfFieldsCompleted++;
                }
            }
        }
        for( String fieldName : requiredFields ) {
            if( proposal.get(fieldName) != null && !String.isBlank( String.valueOf( proposal.get(fieldName) ) ) ) {
                countOfFieldsCompleted++;
            }
        }
        if( proposal.Partner_Approval_Required__c && !(String.isBlank(proposal.Internal_Reviewer__c)) ) {
            countOfFieldsCompleted++;
        }
        if( hasFloors ) {
            countOfFieldsCompleted++;
        }
        return Math.round( maxCompletenessRate*countOfFieldsCompleted/countSteps );
    }

    // All SELECTs for Service Template/Item ----------------------------------------
    public static Map<Id, Service_Item__c> getServiceItemsMap(Proposal__c proposal) { //MRS 7280
        //these fields were removed from SELECT and are selected when they needed or are retrieved via transient variables:
        //Name, Service_Name_Full__c, Unit_of_Service__c, Work_Type__c, Category__c, Type__c, Subtype__c, RecordType.Name, Service_Name_Short__c, Floor__c
        //Phase__r.Name__c, Phase__r.Number__c, Purchase_Order__r.Purchase_Order_Number__c, Service_Template__r.Service_Row_Number__c
		String proposalId = proposal.Id;
        String request = 'SELECT Actual_End_Date__c, Actual_Start_Date__c, Change_Order_Old__c, Change_Order__c, Discount_Percentage__c, OwnerId__c,'
                     	+ ' Is_Alternative__c, Is_Amendmend_Added__c, Is_Amendmend_Deleted__c, Manager_Lookup__c, Municipal_Agency_ID__c, Original__c,'
                    	+ ' Phase__c, Purchase_Order__c, Purchase_Order__r.Name, Row_Position__c, Service_Group__c, Change_Order__r.Status__c,'
                    	+ ' Quantity__c, Quantity_Old__c, Service_Template__r.Medium_Price__c, Balance_to_Bill__c,'
                    	+ ' Is_Aps_Service__c, Status__c, Sales_Tax_Amount__c, Tax_Percent_1__c, Tax_Percent_2__c,'
                    	+ ' Total_Service_Price__c, Unit_Price__c, Service_Group_Key__c, Is_Hourly_Service__c, Is_Sips_Service__c, Discounted_Unit_Price__c, Non_Billable_Reason__c,'
					 	+ ' Service_Template__r.Tax_Code_1__c, Service_Template__r.Tax_Code_2__c, Tax_Code_1__c, Tax_Code_2__c'
              			+ ' FROM Service_Item__c'
              			+ ' WHERE (( Is_Alternative__c = false AND Phase__r.Proposal__c = ' + '\'' + proposalId + '\') OR ( Is_Alternative__c = true AND Proposal__c = ' + '\'' + proposalId + '\'))';
		if(proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c) {
			request += proposal.optView_Hide_Canceled_Change_Orders__c ? ' AND (Change_Order__c = null OR Change_Order__r.Status__c != \'Canceled\')' : '';
			request += proposal.optView_Hide_Completed_Services__c ? ' AND Status__c != \'Completed\'' : '';
			request += proposal.optView_Hide_Inactive_Services__c ? ' AND Status__c != \'Inactive\'' : '';
		} 
		Map<Id, Service_Item__c> res = new Map<Id, Service_Item__c>();
		List<Service_Item__c> serviceItems = Database.query(request);
		if(serviceItems != null) {
			for(Service_Item__c serviceItem : serviceItems) {
				res.put(serviceItem.Id, serviceItem);
			}
		}
		return res;
    }

	public static Boolean getIsBillingCompanyFreeOfTax(Id accountId) { // MRS 7141
		String taxStatus = [SELECT c2g__CODASalesTaxStatus__c FROM Account WHERE Id =: accountId].c2g__CODASalesTaxStatus__c;
		return taxStatus == 'Exempt' || taxStatus == 'Exempt for Qualifying Products' ? true : false;
	}

    public static Map<Id, Service_Template__c> getServiceTemplatesMap( List<String> serviceRowNumbers, String regionName ) {
        return new Map<Id, Service_Template__c> (
            [ SELECT Work_Type__c, Issuance__c, Work_Performed__c, Unit_of_Service__c, Type__c, Subtype__c, Service_Name_Full__c, Region__c,
               Plan_Submission_Type__c, Name, Medium_Price__c, Filing_Status__c, Description__c, Forms__c, External_Forms__c,
               Department__c, Abbreviation__c, Category__c, Tax_Code_1__c, Tax_Code_2__c, GLA_Product__c, Service_Row_Number__c, Shredding_Fees__c,  Met_Data_Scanning_Fee__c,
               Project_Level_RFI__c, Service_Level_RFI__c, Role_Assignment__c, RecordTypeId, Short_Service_Name__c
              FROM Service_Template__c
              WHERE Service_Row_Number__c IN : serviceRowNumbers
                AND Region__c LIKE : regionName ] );//MRS-6715
    }

    public static Map<Id, Service_Template__c> getServiceTemplatesMap( List<Id> serviceTemplateIdsInServiceItems ) {
        return new Map<Id, Service_Template__c> (
            [ SELECT Medium_Price__c, Service_Name_Full__c, RecordTypeId, Met_Data_Scanning_Fee__c, Short_Service_Name__c
              FROM Service_Template__c
              WHERE Id IN : serviceTemplateIdsInServiceItems ] );
    }
    // All SELECTs for Service Template/Item END----------------------------------------


    public static Map<Id, Client_Price__c> getServiceIdToClientPrice( Set<Id> serviceIds, Id billingCompany ) {
        Map<Id, Client_Price__c> serviceIdToClientPrice = new Map<Id, Client_Price__c>();
        List<Client_Price__c> clientPrices = new List<Client_Price__c>();
        if( !String.isEmpty( billingCompany ) ) {
            clientPrices = [SELECT High_Price__c, Medium_Price__c, Low_Price__c, Service__c, Client__c, Last_Proposal__c, Last_Proposed_Price__c
                            FROM Client_Price__c
                            WHERE Service__c IN : serviceIds
                              AND Client__c = : billingCompany];
        }
        for( Client_Price__c priceItem : clientPrices ) {
            serviceIdToClientPrice.put( priceItem.Service__c, priceItem );
        }
        return serviceIdToClientPrice;
    }

    public static Map<Id, Last_Proposal_Price__c> getServiceIdToLastProposalPrice( Set<Id> serviceIds, Id billingCompany ) {
        Map<Id, Last_Proposal_Price__c> serviceIdToLastProposalPrice = new Map<Id, Last_Proposal_Price__c>();
        List<Last_Proposal_Price__c> lastProposalPrice = new List<Last_Proposal_Price__c>();
        if( !String.isBlank(billingCompany) ) {
            lastProposalPrice = [SELECT Unique_Combination__c, Service__c, Last_Proposed_Price__c, Last_Proposal__c, Client__c
                            FROM Last_Proposal_Price__c
                            WHERE Service__c IN : serviceIds
                              AND Client__c = : billingCompany];
        }
        for( Last_Proposal_Price__c priceItem : lastProposalPrice ) {
            serviceIdToLastProposalPrice.put( priceItem.Service__c, priceItem );
        }
        return serviceIdToLastProposalPrice;
    }

    public static List<Service_Bundle_Item__c> getServiceBundleItems( String serviceBundleChosen ) {
        List<Service_Bundle_Item__c> serviceBundleItems = new List<Service_Bundle_Item__c>();
        if( !String.isEmpty( serviceBundleChosen ) && serviceBundleChosen instanceOf Id ) {
            serviceBundleItems = [SELECT Is_Alternative__c, Quantity__c, Row_Position__c, Service__c, Service_Row_Number__c, Work_Type__c, Service_Group_Key__c
                                  FROM Service_Bundle_Item__c
                                  WHERE Service_Bundle__c = : serviceBundleChosen
                                  ORDER BY Row_Position__c];
        }
        return serviceBundleItems;
    }

    public static List<String> getServiceRowNumbersFromBundleItems( List<Service_Bundle_Item__c> serviceBundleItems, String serviceBundleChosen ) {
        List<String> serviceRowNumbers = new List<String>();
        if( !serviceBundleItems.isEmpty() ) {
            for( Service_Bundle_Item__c bundleItem : serviceBundleItems ) {
                serviceRowNumbers.add( bundleItem.Service_Row_Number__c );
            }
            if( !String.isBlank(serviceBundleChosen) && serviceBundleChosen instanceOf Id ) {
                Database.update( new Service_Bundle__c( Id = serviceBundleChosen, Count_Usage__c = true ), false);
            }
        }
        return serviceRowNumbers;
    }

    public static Map<Id, String> recordTypeIdToNameMap( Map<String, Id> recordTypeNameToId ) {
        Map<Id, String> recordTypeIdToNameMap = new Map<Id, String>();
        for( String recordTypeName : recordTypeNameToId.keySet() ) {
            recordTypeIdToNameMap.put( recordTypeNameToId.get( recordTypeName ), recordTypeName );
        }
        return recordTypeIdToNameMap;
    }

    public static Map<String, Id> recordTypeNameToId() {
        Map<String, Id> recordTypeNameToId = new Map<String, Id>();
        List<RecordType> rt = [SELECT Id, Name, DeveloperName
                               FROM RecordType WHERE sObjectType = 'Service_Template__c'
                               AND DeveloperName IN : new List<String>{ ServiceItemServices.RECORD_TYPE_APPLICATION_PERMIT_SERVICES,
                                                                        ServiceItemServices.RECORD_TYPE_OTHER_SERVICES } ];
        for( RecordType rtItem : rt ) {
            recordTypeNameToId.put( rtItem.Name, rtItem.Id );
        }
        return recordTypeNameToId;
    }

    public static List<String> getQuestionList( Boolean isCZSpesialistRequired, Proposal__c proposal ) {
        List<String> questionList = new List<String>();

        Map<String, String> questionToFullText = new Map<String, String> {
            'sowScopeOfWorkNewBuilding' => 'New Building Construction',
            'sowScopeOfWorkHubProject' => 'HUB Project',
            'sowUseEgressOccupancy__c' => 'Does the scope of work change the use, egress or occupancy of the space?',
            'sowMultiplePhases__c' => 'Will the project involve multiple phases of construction?',
            'sowOccupandLoadDiffers__c' => 'Does the expected occupant load differ from the existing building C of O for the floor(s)?',
            'sowMeetingConfRooms__c' => 'Does the project have single or multiple meeting, conference or event rooms, or an employee cafeteria, where the sum of the number of occupants in all would be 75 or more persons?',
            'sowTemporarySprinkler__c' => 'Will the project involve or require the use of temporary sprinkler protection?',
            'sowOpenFloorConnections__c' => 'Does the project involve open floor connections between two of more floors with or without convenience stair?',
            'sowSpecialPlaces__c' => 'Does the project involve the inclusion of special or atypical amenity spaces?',
            'sowFuelStorage__c' => 'Does the project involve fuel storage?',
            'sowTenantsWithGlassDoors__c' => 'Does the project involve single or multiple tenants with glass doors in corridors?',
            'sowExteriorSignage__c' => 'Does the project involve exterior work, such as signage, marquee, antennae, construction equipment, facade, builders permit plan, curb cut?',
            'sowExteriorWork__c' => 'Does the project involve major exterior work, such as exterior egress modification, site safety, distinctive sidewalk?'/*,
            'sow_ir_aw__c' => 'Is  Architectural work required?',
            'sow_ir_mw__c' => 'Is Mechanical work required?',
            'sow_ir_pl__c' => 'Is Plumbing work required?',
            'sow_ir_st__c' => 'Is Structural work required?',
            'sow_id_aw__c' => 'Is  Architectural work required?',
            'sow_id_mw__c' => 'Is Mechanical work required?',
            'sow_id_pl__c' => 'Is Plumbing work required?',
            'sow_id_st__c' => 'Is Structural work required?',
            'sow_sp_ssb__c' => 'Is  Sprinkler System build-out work required?',
            'sow_sp_ssd__c' => 'Is Sprinkler System Demolition work required?',
            'sow_sp_tls__c' => 'Is Sprinkler Temporary Loop System work required?',
            'sow_sm_bow__c' => 'Is  Standpipe build-out work required?',
            'sow_sm_dwk__c' => 'Is Standpipe Demolition work required?'*/
        };

        if( isCZSpesialistRequired ) {
            if( !String.isBlank( proposal.sowScopeOfWork__c ) ) {
                if( proposal.sowScopeOfWork__c == SOW_NEW_BUILDING ) {
                    questionList.add(questionToFullText.get('sowScopeOfWorkNewBuilding'));
                } else if( proposal.sowScopeOfWork__c == SOW_HUB_PROJECT ) {
                    questionList.add(questionToFullText.get('sowScopeOfWorkHubProject'));
                } else {
                    if( proposal.sowUseEgressOccupancy__c    ) questionList.add(questionToFullText.get('sowUseEgressOccupancy__c'));
                    if( proposal.sowMultiplePhases__c        ) questionList.add(questionToFullText.get('sowMultiplePhases__c'));
                    if( proposal.sowOccupandLoadDiffers__c   ) questionList.add(questionToFullText.get('sowOccupandLoadDiffers__c'));
                    if( proposal.sowMeetingConfRooms__c      ) questionList.add(questionToFullText.get('sowMeetingConfRooms__c'));
                    if( proposal.sowTemporarySprinkler__c    ) questionList.add(questionToFullText.get('sowTemporarySprinkler__c'));
                    if( proposal.sowOpenFloorConnections__c  ) questionList.add(questionToFullText.get('sowOpenFloorConnections__c'));
                    if( proposal.sowSpecialPlaces__c         ) questionList.add(questionToFullText.get('sowSpecialPlaces__c'));
                    if( proposal.sowTenantsWithGlassDoors__c ) questionList.add(questionToFullText.get('sowTenantsWithGlassDoors__c'));
                    if( proposal.sowExteriorSignage__c       ) questionList.add(questionToFullText.get('sowExteriorSignage__c'));
                    if( proposal.sowFuelStorage__c           ) questionList.add(questionToFullText.get('sowFuelStorage__c'));
                    if( proposal.sowExteriorWork__c          ) questionList.add(questionToFullText.get('sowExteriorWork__c'));
                    /*for( String item: sowSpaceAlterTypeSelected ){
                        questionList.add(item);
                    }*/
                    if( proposal.sow_ir_aw__c    ) questionList.add(questionToFullText.get('sow_ir_aw__c'));
                    if( proposal.sow_ir_mw__c    ) questionList.add(questionToFullText.get('sow_ir_mw__c'));
                    if( proposal.sow_ir_pl__c    ) questionList.add(questionToFullText.get('sow_ir_pl__c'));
                    if( proposal.sow_ir_st__c    ) questionList.add(questionToFullText.get('sow_ir_st__c'));
                    if( proposal.sow_id_aw__c    ) questionList.add(questionToFullText.get('sow_id_aw__c'));
                    if( proposal.sow_id_mw__c    ) questionList.add(questionToFullText.get('sow_id_mw__c'));
                    if( proposal.sow_id_pl__c    ) questionList.add(questionToFullText.get('sow_id_pl__c'));
                    if( proposal.sow_id_st__c    ) questionList.add(questionToFullText.get('sow_id_st__c'));
                    if( proposal.sow_sp_ssb__c   ) questionList.add(questionToFullText.get('sow_sp_ssb__c'));
                    if( proposal.sow_sp_ssd__c   ) questionList.add(questionToFullText.get('sow_sp_ssd__c'));
                    if( proposal.sow_sp_tls__c   ) questionList.add(questionToFullText.get('sow_sp_tls__c'));
                    if( proposal.sow_sm_bow__c   ) questionList.add(questionToFullText.get('sow_sm_bow__c'));
                    if( proposal.sow_sm_dwk__c   ) questionList.add(questionToFullText.get('sow_sm_dwk__c'));
                }
            }
        }
        return questionList;
    }

    public static List<String> getServiceRowNumbers( Proposal__c proposal, Building__c building, List<Floor__c> currentFloorsList ) {
        List<String> servicesToAdd = new List<String>();
        if( !String.isBlank(proposal.sowScopeOfWork__c) && ( proposal.sowScopeOfWork__c.contains(SOW_EXISTING_SPACE) ) ) {
            Boolean isProfCertNeeded = proposal.Expected_Construction_Start_Date__c < Date.Today().addDays(56);
            if( building.Is_Landmark__c ) {
                if( FloorServices.floorContains(FloorServices.FLOOR_TYPE_REGULAR_FLOOR, 1, currentFloorsList) ||
                    FloorServices.floorContains(FloorServices.FLOOR_TYPE_REGULAR_FLOOR, 2, currentFloorsList) ||
                    FloorServices.floorContains(FloorServices.FLOOR_TYPE_MEZZANINE, 1, currentFloorsList) ||
                    FloorServices.floorContains(FloorServices.FLOOR_TYPE_MEZZANINE, 2, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_FACADE, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_ROOF, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_LOBBY, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_BASEMENT, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_CELLAR, currentFloorsList) ||
                    FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_SUBCELLAR, currentFloorsList) ) {
                    servicesToAdd.add('APS30');
                } else {
                    servicesToAdd.add('APS30');
                }
            }
            if( building.Is_MTA__c &&
                ( FloorServices.floorContains(FloorServices.FLOOR_TYPE_REGULAR_FLOOR, 1, currentFloorsList) || FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_LOBBY, currentFloorsList) || FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_BASEMENT, currentFloorsList) || FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_CELLAR, currentFloorsList) || FloorServices.isThereFloorWithType(FloorServices.FLOOR_TYPE_SUBCELLAR, currentFloorsList) ) ) {
                servicesToAdd.add('APS32');
            }
            if( building.Loft_Board_Authority__c ) servicesToAdd.add('APS94');
            if( building.Little_E_Designation__c ) servicesToAdd.add('APS40');
            if( proposal.sowScopeOfWork__c.contains(SOW_EXISTING_SPACE) ) {
                if(  proposal.Asbestos__c ) servicesToAdd.add('OS02');
                if( !proposal.Asbestos__c && proposal.Asbestos_Investigation_Options__c == ASBESTOS_INVESTIGATION_OPTIONS_BY_OTHERS ) servicesToAdd.add('OS03');
            }
            if( proposal.sowServicesNeededAPS__c ) {
                servicesToAdd.addAll( getIrServices( proposal, true, true, isProfCertNeeded ) );
                servicesToAdd.addAll( getIdServices( proposal, true, true, isProfCertNeeded ) );
                servicesToAdd.addAll( getErServices( proposal, true, true, isProfCertNeeded ) );
                servicesToAdd.addAll( getFaServices( proposal, true, true, isProfCertNeeded ) );
                servicesToAdd.addAll( getSpServices( proposal, true, true, isProfCertNeeded ) );
                servicesToAdd.addAll( getSmServices( proposal, true, true, isProfCertNeeded ) );
            }
        }
        return servicesToAdd;
    }

    public static List<String> getIrServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> irServices = new List<String>();
        if( !String.isBlank(proposal.sow_ir_override__c) ) {
            if( proposal.sow_ir_override__c == 'Professional' ) isProfCert = true; else isProfCert = false;
        }
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Interior Renovation') ) {
            if( checkEmpty && !proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) return new List<String>();
            if( proposal.sow_ir_mw__c && proposal.sowACUnits__c ) {
                if( populateServices ) { irServices.add('APS76'); }
            }
            if(  proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS99'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS221'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if( !proposal.sow_ir_aw__c &&  proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS98');  irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS103'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if( !proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c &&  proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS101'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS102'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if( !proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c &&  proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS100'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS110'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c &&  proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS174'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS173'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c &&  proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS175'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS176'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c && !proposal.sow_ir_mw__c &&  proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS177'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS178'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c &&  proposal.sow_ir_mw__c &&  proposal.sow_ir_pl__c && !proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS09'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS06'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c &&  proposal.sow_ir_mw__c && !proposal.sow_ir_pl__c &&  proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS179'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS180'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
            if(  proposal.sow_ir_aw__c &&  proposal.sow_ir_mw__c &&  proposal.sow_ir_pl__c &&  proposal.sow_ir_st__c ) {
                if( populateServices &&  isProfCert ) { irServices.add('APS181'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                if( populateServices && !isProfCert ) { irServices.add('APS182'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS48'); irServices.add('APS35'); }
                return irServices;
            }
        }
        return irServices;
    }

    public static List<String> getIdServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> idServices = new List<String>();
        if( !String.isBlank(proposal.sow_id_override__c) ) {
            if( proposal.sow_id_override__c == 'Professional' ) isProfCert = true; else isProfCert = false;
        }
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Interior Demolition') ) {
            if( checkEmpty && !proposal.sow_id_aw__c && !proposal.sow_id_mw__c && !proposal.sow_id_pl__c && !proposal.sow_id_st__c ) return new List<String>();
            if(  proposal.sow_id_aw__c && !proposal.sow_id_mw__c && !proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS190'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS97'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if( !proposal.sow_id_aw__c &&  proposal.sow_id_mw__c && !proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS193'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS194'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if( !proposal.sow_id_aw__c && !proposal.sow_id_mw__c &&  proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS195'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS196'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if( !proposal.sow_id_aw__c && !proposal.sow_id_mw__c && !proposal.sow_id_pl__c &&  proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS197'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS198'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c &&  proposal.sow_id_mw__c && !proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS198'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS199'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c && !proposal.sow_id_mw__c && !proposal.sow_id_pl__c &&  proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS192'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS200'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c && !proposal.sow_id_mw__c &&  proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS191'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS201'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c &&  proposal.sow_id_mw__c &&  proposal.sow_id_pl__c && !proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS96'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS05'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c &&  proposal.sow_id_mw__c && !proposal.sow_id_pl__c &&  proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS202'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS203'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
            if(  proposal.sow_id_aw__c &&  proposal.sow_id_mw__c &&  proposal.sow_id_pl__c &&  proposal.sow_id_st__c ) {
                if( populateServices &&  isProfCert ) { idServices.add('APS204'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                if( populateServices && !isProfCert ) { idServices.add('APS205'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS48'); idServices.add('APS35'); }
                return idServices;
            }
        }
        return idServices;
    }

    public static List<String> getErServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> erServices = new List<String>();
        if( !String.isBlank(proposal.sow_er_override__c) ) {
            if( proposal.sow_er_override__c == 'Professional' ) isProfCert = true; else isProfCert = false;
        }
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Exterior Repairs or Modification') ) {
            if( checkEmpty && !proposal.sow_er_be__c && ( !proposal.sow_er_ba__c || ( proposal.sow_er_ba__c && String.isBlank(proposal.sow_er_bas__c) )) && !proposal.sowFencePermit__c ) return new List<String>();
            if( proposal.sow_er_be__c && ( !proposal.sow_er_ba__c || ( proposal.sow_er_ba__c && String.isBlank(proposal.sow_er_bas__c) )) && !proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.addAll( new List<String>{ 'APS164', 'APS48', 'APS48', 'APS35' } ); }
                if( populateServices && !isProfCert ) { erServices.addAll( new List<String>{ 'APS146', 'APS48', 'APS48', 'APS35' } ); }
                return erServices;
            }
            if( !proposal.sow_er_be__c && ( proposal.sow_er_ba__c && !String.isBlank(proposal.sow_er_bas__c) && proposal.sow_er_bas__c == 'Sign') && !proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.add('APS20'); erServices.add('APS48'); erServices.add('APS35'); }
                if( populateServices && !isProfCert ) { erServices.add('APS19'); erServices.add('APS48'); erServices.add('APS35'); }
                return erServices;
            }
            if( !proposal.sow_er_be__c && ( proposal.sow_er_ba__c && !String.isBlank(proposal.sow_er_bas__c) && proposal.sow_er_bas__c == 'Curb cut' ) && !proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.add('APS121'); erServices.add('APS48'); erServices.add('OS85'); erServices.add('APS35'); }
                if( populateServices && !isProfCert ) { erServices.add('APS120'); erServices.add('APS48'); erServices.add('OS85'); erServices.add('APS35'); }
                return erServices;
            }
            if( !proposal.sow_er_be__c && ( proposal.sow_er_ba__c && !String.isBlank(proposal.sow_er_bas__c) && proposal.sow_er_bas__c == 'Antennae' ) && !proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.add('APS112'); erServices.add('APS48'); erServices.add('APS35'); }
                if( populateServices && !isProfCert ) { erServices.add('APS113'); erServices.add('APS48'); erServices.add('APS35'); }
                return erServices;
            }
            if( !proposal.sow_er_be__c && ( proposal.sow_er_ba__c && !String.isBlank(proposal.sow_er_bas__c) && proposal.sow_er_bas__c == 'Sidewalk repair' ) && !proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.add('APS274'); }
                if( populateServices && !isProfCert ) { erServices.add('APS274'); }
                return erServices;
            }
            if( !proposal.sow_er_be__c && ( !proposal.sow_er_ba__c || ( proposal.sow_er_ba__c && String.isBlank(proposal.sow_er_bas__c) )) && proposal.sowFencePermit__c ) {
                if( populateServices &&  isProfCert ) { erServices.add('APS49'); }
                if( populateServices && !isProfCert ) { erServices.add('APS49'); }
                return erServices;
            }
        }
        return erServices;
    }

    public static List<String> getFaServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> faServices = new List<String>();
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Fire Alarm Modification') ) {
            if( populateServices ) { faServices.add('APS11'); faServices.add('APS35'); }
            return faServices;
        }
        return faServices;
    }

    public static List<String> getSpServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> spServices = new List<String>();
        if( !String.isBlank(proposal.sow_sp_override__c) ) {
            if( proposal.sow_sp_override__c == 'Professional' ) isProfCert = true; else isProfCert = false;
        }
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Sprinkler System Modification') ) {
            if( checkEmpty && !proposal.sow_sp_ssb__c && !proposal.sow_sp_ssd__c && !proposal.sow_sp_tls__c ) return new List<String>();
            if(  proposal.sow_sp_ssb__c && !proposal.sow_sp_ssd__c && !proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS10'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS07'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if( !proposal.sow_sp_ssb__c &&  proposal.sow_sp_ssd__c && !proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS207'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS208'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if( !proposal.sow_sp_ssb__c && !proposal.sow_sp_ssd__c &&  proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS206'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS85'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if(  proposal.sow_sp_ssb__c &&  proposal.sow_sp_ssd__c && !proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS209'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS210'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if( !proposal.sow_sp_ssb__c &&  proposal.sow_sp_ssd__c &&  proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS211'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS212'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if(  proposal.sow_sp_ssb__c && !proposal.sow_sp_ssd__c &&  proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS213'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS214'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
            if(  proposal.sow_sp_ssb__c &&  proposal.sow_sp_ssd__c &&  proposal.sow_sp_tls__c ) {
                if( populateServices &&  isProfCert ) { spServices.add('APS215'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                if( populateServices && !isProfCert ) { spServices.add('APS216'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS48'); spServices.add('APS35'); }
                return spServices;
            }
        }
        return spServices;
    }

    public static List<String> getSmServices( Proposal__c proposal, Boolean checkEmpty, Boolean populateServices, Boolean isProfCert ) {
        List<String> smServices = new List<String>();
        if( !String.isBlank(proposal.sow_sm_override__c) ) {
            if( proposal.sow_sm_override__c == 'Professional' ) isProfCert = true; else isProfCert = false;
        }
        if( !String.isBlank(proposal.sowScopeOfWork__c) && proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) && proposal.sowServicesNeededAPS__c && proposal.sowNoneOfTheAbove__c && !String.isBlank(proposal.sowSpaceAlterType__c) && proposal.sowSpaceAlterType__c.contains('Standpipe Modification') ) {
            if( checkEmpty && !proposal.sow_sm_bow__c && !proposal.sow_sm_dwk__c ) return new List<String>();
            if(  proposal.sow_sm_bow__c && !proposal.sow_sm_dwk__c ) {
                if( populateServices &&  isProfCert ) { smServices.add('APS217'); smServices.add('APS48'); smServices.add('APS35'); }
                if( populateServices && !isProfCert ) { smServices.add('APS218'); smServices.add('APS48'); smServices.add('APS35'); }
                return smServices;
            }
            if( !proposal.sow_sm_bow__c &&  proposal.sow_sm_dwk__c ) {
                if( populateServices &&  isProfCert ) { smServices.add('APS219'); smServices.add('APS48'); smServices.add('APS35'); }
                if( populateServices && !isProfCert ) { smServices.add('APS220'); smServices.add('APS48'); smServices.add('APS35'); }
                return smServices;
            }
        }
        return smServices;
    }

    public static Boolean isIrValidEmpty( Proposal__c proposal ) {
        return !( !proposal.sow_ir_aw__c &&
                  !proposal.sow_ir_mw__c &&
                  !proposal.sow_ir_pl__c &&
                  !proposal.sow_ir_st__c );
    }

    public static Boolean isIdValidEmpty( Proposal__c proposal ) {
        return !( !proposal.sow_id_aw__c &&
                  !proposal.sow_id_mw__c &&
                  !proposal.sow_id_pl__c &&
                  !proposal.sow_id_st__c );
    }

    public static Boolean isErValidEmpty( Proposal__c proposal ) {
        return !( !proposal.sow_er_be__c &&
                  ( ( !proposal.sow_er_ba__c ) ||
                    (  proposal.sow_er_ba__c &&
                      String.isBlank(proposal.sow_er_bas__c) ) ) &&
                  !proposal.sowFencePermit__c );
    }

    public static Boolean isFaValidEmpty( Proposal__c proposal ) {
        return !( false );
    }

    public static Boolean isSpValidEmpty( Proposal__c proposal ) {
        return !( !proposal.sow_sp_ssb__c &&
                  !proposal.sow_sp_ssd__c &&
                  !proposal.sow_sp_tls__c );
    }

    public static Boolean isSmValidEmpty( Proposal__c proposal ) {
        return !( !proposal.sow_sm_bow__c &&
                  !proposal.sow_sm_dwk__c );
    }

    public static Map<Id, Proposal__c> getProposalMergeFieldsById( Set<String> proposalIds ) {
        Set<Id> proposalIdsFiltered = new Set<Id>();
        for( String proposalId : proposalIds ) {
            if( !String.isBlank( proposalId ) && proposalId instanceOf Id ) {
                proposalIdsFiltered.add( proposalId );
            }
        }
        Map<Id, Proposal__c> proposals = new Map<Id, Proposal__c>( [ SELECT Name, Proposal_Sent_Date__c, Billing_Company_Contact__r.Name,
                                                                            Project_Name__c, Address_Building_AKA__c, Floor_s__c, Project_Profile__c,
                                                                            Billing_Company_Contact__r.Salutation, Billing_Company_Contact__r.Suffix__c,
																			Project_Profile__r.Project_Name_For_Email__c /*MRS 6259*/
                                                                     FROM Proposal__c
                                                                     WHERE Id IN : proposalIdsFiltered ] );
        return proposals;
    }

    public static Map<Id, Change_Order__c> getChangeOrderMergeFieldsById( Set<String> changeOrderIds ) {
        Set<Id> changeOrderIdsFiltered = new Set<Id>();
        for( String changeOrderId : changeOrderIds ) {
            if( !String.isBlank( changeOrderId ) && changeOrderId instanceOf Id ) {
                changeOrderIdsFiltered.add( changeOrderId );
            }
        }
        Map<Id, Change_Order__c> changeOrders = new Map<Id, Change_Order__c>( [ SELECT Change_Order_Sent_Date__c, Proposal__r.Billing_Company_Contact__r.Name,
                                                                                       Proposal__r.Address_Building_AKA__c, Proposal__r.Floor_s__c,
                                                                                       Proposal__r.Project_Profile__r.Name, Proposal__r.Project_Name__c,
                                                                                       Proposal__r.Billing_Company_Contact__r.Salutation,
                                                                                       Proposal__r.Billing_Company_Contact__r.Suffix__c, Proposal__r.Name,
                                                                                       Send_To_Client_Email_Subject__c, Number__c,
                                                                                       Proposal__r.Project_Profile__r.Project_Name_For_Email__c /*MRS 6259*/
                                                                                FROM Change_Order__c
                                                                                WHERE Id IN : changeOrderIdsFiltered ] );
        return changeOrders;
    }

	public static void setSentViaDocusignCheckBox(Id proposalId, Id coId) { //MRS 7515
		if(coId != null) {
			PreventTwiceExecution.changeOrderFirstRun = false;
			UPSERT new Change_Order__c(id = coId, Sent_via_Docusign__c = true);
		} else if(proposalId != null) {
			PreventTwiceExecution.proposalFirstRun = false;
			UPSERT new Proposal__c(id = proposalId, Sent_via_Docusign__c = true);
		}
	}

    public static Boolean doUseDocusign( Proposal__c proposal, Id changeCoStatusCoId, ProposalWizardModel pwm ) {
        return ( String.isEmpty( changeCoStatusCoId ) && proposal.UseDocusign__c ) ||
               ( !String.isEmpty( changeCoStatusCoId ) && pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.UseDocusign__c );
    }

    public static String getPdfType( ProposalWizardModel pwm, Boolean isLightCo ) {
        Boolean doSendChangeOrderPdf = !pwm.approvedChangeOrders.isEmpty();
        if( !doSendChangeOrderPdf ) {
            for( ChangeOrderModel co : pwm.notApprovedChangeOrders ) {
                if( co.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                    doSendChangeOrderPdf = true;
                    break;
                }
            }
        }
        return doSendChangeOrderPdf
               ? ( isLightCo == true
                   ? CHANGE_ORDER_LIGHT_DDP_NAME
                   : CHANGE_ORDER_DDP_NAME )
               : PROPOSAL_DDP_NAME;
    }

    public static String getDeliveryMethodName( ProposalWizardModel pwm, Proposal__c proposal, String changeOrderId, Id contactToId, String emailType ) {
        return !String.isEmpty( contactToId )
               ? ( doUseDocusign( proposal, changeOrderId, pwm )
                   ? ( ( ( String.isBlank( changeOrderId ) && proposal.Disable_Followups__c ) || ( !String.isBlank( changeOrderId ) && pwm.changeOrderModelMap.get( changeOrderId ) != null && pwm.changeOrderModelMap.get( changeOrderId ).changeOrderRecord.Disable_Followups__c ) )
                       ? ( DDPEmailServices.DELIVERY_METHOD_DOCUSIGN )
                       : ( DDPEmailServices.DELIVERY_METHOD_DOCUSIGN/*_FOLLOWUP*/ ) )
                   : ( emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY
                       ? ( DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP )
                       : ( DDPEmailServices.DELIVERY_METHOD_EMAIL ) ) )
               : ( DDPEmailServices.DELIVERY_METHOD_ATTACH );
    }

    public static String getEmailTemplateDeveloperNameForPdf( String ddpName, String deliveryMethod ) {
        Map<String, Map<String, String>> ddpNameToDeliveryMethodToEmailTemplateDevName;
        ddpNameToDeliveryMethodToEmailTemplateDevName = new Map<String, Map<String, String>>{
            PROPOSAL_DDP_NAME => new Map<String, String>{
                DDPEmailServices.DELIVERY_METHOD_EMAIL => EmailMessageService.EMAIL_TEMPLATE_DRAFT_PROPOSAL,
                DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP => EmailMessageService.EMAIL_TEMPLATE_DRAFT_PROPOSAL_FOLLOWUP
            },
            CHANGE_ORDER_DDP_NAME => new Map<String, String>{
                DDPEmailServices.DELIVERY_METHOD_EMAIL => EmailMessageService.EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER,
                DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP => EmailMessageService.EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER_FOLLOWUP
            },
            CHANGE_ORDER_LIGHT_DDP_NAME => new Map<String, String>{
                DDPEmailServices.DELIVERY_METHOD_EMAIL => EmailMessageService.EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER,
                DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP => EmailMessageService.EMAIL_TEMPLATE_DRAFT_CHANGE_ORDER_FOLLOWUP
            }
        };
        return ( ddpNameToDeliveryMethodToEmailTemplateDevName.get( ddpName ) != null )
               ? ddpNameToDeliveryMethodToEmailTemplateDevName.get( ddpName ).get( deliveryMethod )
               : null;
    }

    public static void setChangeOrderDocumentType( ProposalWizardModel pwm, String changeOrderId, Boolean isLightDoc ) {
        Change_Order__c changeOrder = new Change_Order__c( Id = changeOrderId );
        if( isLightDoc == true ) {
            changeOrder.Document_Type__c = ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
        } else {
            changeOrder.Document_Type__c = ChangeOrderServices.CO_DOCUMENT_TYPE_FULL;
        }
        UPDATE changeOrder;
        pwm.changeOrderModelMap.get( Id.valueOf( changeOrderId ) ).changeOrderRecord.Document_Type__c = changeOrder.Document_Type__c;
    }

    public static String setChangeOrderIdForResendFromFooter( String changeCoStatusCoId, String emailType, ProposalWizardModel pwm, Boolean changeCoStatusIsLightDoc ) {
        //set any parent CO Id if resending from footer and there are COs
        String changeOrderId = changeCoStatusCoId;
        if( emailType == DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY &&
            String.isBlank( changeOrderId ) &&
            ProposalWizardServices.getPdfType( pwm, changeCoStatusIsLightDoc ) != ProposalWizardServices.PROPOSAL_DDP_NAME ) {
            for( ChangeOrderModel co : pwm.notApprovedChangeOrders ) {
                if( co.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                    changeOrderId = co.changeOrderRecord.Id;
                    changeCoStatusIsLightDoc = co.changeOrderRecord.Document_Type__c == ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
                }
            }
            if( String.isBlank( changeOrderId ) && !pwm.approvedChangeOrders.isEmpty() ) {
                changeOrderId = pwm.approvedChangeOrders[pwm.approvedChangeOrders.size() - 1].changeOrderRecord.Id;
                changeCoStatusIsLightDoc = pwm.approvedChangeOrders[pwm.approvedChangeOrders.size() - 1].changeOrderRecord.Document_Type__c == ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
            }
        }
        return changeOrderId;
    }

	//MRS 7320 7381
	public static void setSendThisTimeToFalse(Set<Id> idxSet, Id proposalId) { //MRS 7406
			if(idxSet == null) idxSet = new Set<Id>();
			Map<Id, String> proposalIdToListOfId = new Map<Id, String>();
			List<LStore__Stored_Document__c> docsToUpdate = new List<LStore__Stored_Document__c>();
			List<LStore__Stored_Document__c> documents;
			documents = [SELECT Id, To_Be_Sent_this_time__c, Related_Object_Id__c FROM LStore__Stored_Document__c
							WHERE Related_Object_Id__c =: proposalId AND Folder_Name__c = 'Additional Attachments'];
			if(!documents.isEmpty()) {
				for(LStore__Stored_Document__c document : documents) {
				docsToUpdate.add(new LStore__Stored_Document__c(Id = document.Id, To_Be_Sent_this_time__c = false));
				if(proposalIdToListOfId.get(document.Related_Object_Id__c) == null) {
						if(idxSet.contains(document.Id)) {
					proposalIdToListOfId.put(document.Related_Object_Id__c, String.valueOf(document.Id));
				} else {
							proposalIdToListOfId.put(document.Related_Object_Id__c, '');
						}
					} else {
						if(idxSet.contains(document.Id)) {
					proposalIdToListOfId.put(document.Related_Object_Id__c, proposalIdToListOfId.get(document.Related_Object_Id__c) + String.valueOf(document.Id));
				}
			}
				}
			UPSERT docsToUpdate;
			System.debug(LoggingLevel.ERROR, '### ' + proposalIdToListOfId);
			List<Proposal__c> proposals = new List<Proposal__c>();
			for(Id idx : proposalIdToListOfId.keySet()) {
				proposals.add(new Proposal__c(Id = idx, List_of_Attached_Docs__c = proposalIdToListOfId.get(idx)));
				System.debug(LoggingLevel.ERROR, '### ' + proposals);
			}
			PreventTwiceExecution.proposalFirstRun = false;
			UPSERT proposals;
		}
	}

    public static List<List<Id>> prepareProposalPDF( Proposal__c proposal, String changeOrderId, String ddpName, String deliveryMethod, List<DocumentWrapper> documentWrapperList, Boolean doUpdate, Boolean getAttachmentIds, Boolean isFollowUpFlow ) { //G300 MRS-6807 getAttachmentIds added //MRS 7406
        Boolean unpredictableFilesAttached = false;
        Double totalFilesSizeDocument = 0;
        List<Id> attachDocumentIds = new List<Id>();
        Double totalFilesSizeLoopStore = 0;
        List<Id> attachLoopStoreIds = new List<Id>();
        Map<Id, String> attachLoopStoreIdToExternalUrl = new Map<Id, String>();
        Map<String, String> externalURLToDocumentName = new Map<String, String>();
        List<Id> attachmentIds;
        String filesAttachmentBody = '';
        Boolean isFollowup = deliveryMethod == DDPEmailServices.DELIVERY_METHOD_EMAIL_FOLLOWUP;
        Boolean isEmail = deliveryMethod == DDPEmailServices.DELIVERY_METHOD_EMAIL;
        MergeEmailTemplate sourceMergeTemplate;
        EmailTemplate sourceTemplate, targetTemplate;
        Id deliveryMethodId;

        if( proposal.Proposal_Type__c == ProposalServices.PROPOSAL_TYPE_RFP && documentWrapperList != null && !documentWrapperList.isEmpty() ) {
            for( DocumentWrapper document : documentWrapperList ) {
                if( document.isAttached ) {
                    attachDocumentIds.add( document.documentId );
                }
            }
            for( Document document : [ SELECT Id, BodyLength, Type FROM Document WHERE Id IN : attachDocumentIds ] ) {
                totalFilesSizeDocument += document.bodyLength;
                if( EmailMessageService.unpredictableFilesEtentions.contains( document.Type ) ) {
                    unpredictableFilesAttached = true;
                }
            }
        }

        if( proposal.Additional_Documents__c == true ) {
            LStore__Stored_Document__c documentFolder = StoredDocumentServices.getAdditionalDocumentsFolder( proposal.Id );
            if( documentFolder.Id != null && !documentFolder.LStore__Stored_Documents__r.isEmpty() ) {
                for( LStore__Stored_Document__c document : documentFolder.LStore__Stored_Documents__r ) {
                    if( document.RecordTypeId != StoredDocumentServices.FOLDER_RECORD_TYPE_ID && (document.To_Be_Sent_this_time__c==true
																									|| ( isFollowUpFlow && !String.isBlank(proposal.List_of_Attached_Docs__c) &&
																										 proposal.List_of_Attached_Docs__c.contains(document.Id)))) { //MRS 6809 7381 7406
                        String externalUrl = EmailMessageService.getExternalURL( document.LStore__External_Id__c );
                        attachLoopStoreIds.add( document.Id );
                        attachLoopStoreIdToExternalUrl.put( document.Id, externalUrl );
                        externalURLToDocumentName.put( externalUrl, ( document.Drawings_Title__c != null ? document.Drawings_Title__c : document.Name ) );
                        totalFilesSizeLoopStore += document.LStore__File_Size__c;
                        if( EmailMessageService.unpredictableFilesEtentions.contains( document.LStore__Type__c ) ) {
                            unpredictableFilesAttached = true;
                        }
                    }
                }
            }
        }

        List<Id> attachmentIdsToBeAddedAsLinks = new List<Id>(); //G300 MRS-6807
        if( !attachDocumentIds.isEmpty() || !attachLoopStoreIds.isEmpty() ) {
            if( !attachDocumentIds.isEmpty() ) { //documents do not have external urls, so adding them as attachments no matter what
                attachmentIds = new List<Id>();
                attachmentIds.addAll( attachDocumentIds );
            }
            if( ( !isEmail && !isFollowup ) || //docusign or attach
                ( ( isEmail || isFollowup ) && !unpredictableFilesAttached && totalFilesSizeDocument + totalFilesSizeLoopStore <= EmailMessageService.ATTACHMENT_LIMIT ) ) {
                if( attachmentIds == null ) attachmentIds = new List<Id>();
                attachmentIds.addAll( attachLoopStoreIds );
            } else {
                if( doUpdate ) {
                    filesAttachmentBody = '<br/><br/><br/>' + Label.Find_Attached_Documents_Message + '<br/>' + '<br/><ol>';
                    for( Id attachLoopStoreId : attachLoopStoreIds ) {
                        attachmentIdsToBeAddedAsLinks.add( attachLoopStoreId ); //G300 MRS-6807
                        String extUrl = attachLoopStoreIdToExternalUrl.get( attachLoopStoreId );
                        filesAttachmentBody += '<li><a href=\"' + extUrl + '\" style=\"color: blue;\">' + externalURLToDocumentName.get( extUrl ) + '</li>';
                    }
                    filesAttachmentBody += '</ol>';
                }
            }
        }
        if( getAttachmentIds == true ) { //G300 MRS-6807
            return new List<List<Id>>{ attachmentIdsToBeAddedAsLinks };
        }

        if( doUpdate && ( isEmail || isFollowup ) ) {
            if( !String.isBlank( filesAttachmentBody ) ) { //if there are attachment links, use merge email template to add these links
                sourceTemplate = EmailMessageService.getEmailTemplateByDeveloperName( getEmailTemplateDeveloperNameForPdf( ddpName, deliveryMethod ) );
                if( !String.isBlank( changeOrderId ) ) {
                    Change_Order__c changeOrderForMerge = new Change_Order__c();
                    Map<Id, Change_Order__c> changeOrdersForMerge = getChangeOrderMergeFieldsById( new Set<String>{changeOrderId} );
                    if( changeOrdersForMerge.get( changeOrderId ) != null ) {
                        changeOrderForMerge = changeOrdersForMerge.get( changeOrderId );
                        sourceMergeTemplate = new MergeEmailTemplate( sourceTemplate, changeOrderForMerge, isFollowup );
                    }
                } else {
                    Proposal__c proposalForMerge = new Proposal__c();
                    Map<Id, Proposal__c> proposalsForMerge = getProposalMergeFieldsById( new Set<String>{proposal.Id} );
                    if( proposalsForMerge.get( proposal.Id ) != null ) {
                        proposalForMerge = proposalsForMerge.get( proposal.Id );
                        sourceMergeTemplate = new MergeEmailTemplate( sourceTemplate, proposalForMerge, isFollowup );
                    }
                }

                Integer oldestTemplateNumber;
                List<Integer> biggestNumbers = new List<Integer>();
                //emailSetupData = Biggest Email Template number (for the earliest Email Template) - to Delivery Method Id - to Email Template (the oldest one)
                Map<Integer, Map<Id, EmailTemplate>> emailSetupData = EmailMessageService.getBiggestNumberToDeliveryMethodIdToEarliestEmailTemplate( ddpName, deliveryMethod );
                if( emailSetupData != null ) {
                    biggestNumbers = new List<Integer>( emailSetupData.keySet() );
                    biggestNumbers.sort();
                }
                oldestTemplateNumber = !biggestNumbers.isEmpty() ? biggestNumbers[biggestNumbers.size() - 1] : null;
                Map<Id, EmailTemplate> deliveryMethodIdToEmailTemplate = !biggestNumbers.isEmpty() ? emailSetupData.get( oldestTemplateNumber ) : null;
                deliveryMethodId = deliveryMethodIdToEmailTemplate != null ? ( new List<Id>( deliveryMethodIdToEmailTemplate.keySet() ) )[0] : null;
                targetTemplate = deliveryMethodIdToEmailTemplate != null ? deliveryMethodIdToEmailTemplate.get( deliveryMethodId ) : null;
                if( targetTemplate != null && deliveryMethodId != null ) {
                    targetTemplate.Subject = sourceMergeTemplate.subject.left(225);
                    targetTemplate.HtmlValue = sourceMergeTemplate.headerBody +
                                               sourceMergeTemplate.body +
                                               filesAttachmentBody +
                                               sourceMergeTemplate.legalFooterForProposalAndCOEmails() +
                                               sourceMergeTemplate.footerBody;
                    targetTemplate.Description = String.valueOf( oldestTemplateNumber + 1 ); //description field is used to find the earliest unused template
                    UPDATE targetTemplate;
                }
            } else { //if there are no attachment links, use classic emailing scheme
                deliveryMethodId = DDPEmailServices.getDDPIntegrationOption( ddpName, deliveryMethod + DDPEmailServices.DELIVERY_METHOD_CLASSIC_SUFFIX ).Id;
            }
        }
        return new List<List<Id>>{ attachmentIds, new List<Id>{ deliveryMethodId } };
    }

    public static PageReference sendProposalPDF( Proposal__c proposal, String changeOrderId, Id contactToId,
                                                 Map<String, String> emailToNameForApprover, Map<String, String> emailToNameForCc,
                                                 String ddpName, String deliveryMethod, Id deliveryMethodId, List<DocumentWrapper> documentWrapperList,
												 Boolean isFollowUp) { //MRS 7406
        String ddpNameForDocument = ddpName;
        if( proposal != null ) {
            Id parentId = ( ( ddpName == CHANGE_ORDER_DDP_NAME || ddpName == CHANGE_ORDER_LIGHT_DDP_NAME ) && !String.isBlank( changeOrderId ) ) ? Id.valueOf( changeOrderId ) : proposal.Id;
            if( !String.isBlank( parentId ) && ( !String.isBlank( deliveryMethod ) || !String.isBlank( deliveryMethodId ) ) ) {
                List<Id> attachmentIds;
                if( ddpName != NON_FEE_PROPOSAL_DDP_NAME ) {
                    attachmentIds = prepareProposalPDF( proposal, null, ddpName, deliveryMethod, documentWrapperList, false, false, isFollowUp ).get(0); //MRS 7406
                }
                DDPRequest request = new DDPRequest();
                if( deliveryMethod == DDPEmailServices.DELIVERY_METHOD_DOCUSIGN ) {
                    request.addConfiguration( parentId, ddpNameForDocument, DDPEmailServices.DELIVERY_METHOD_ATTACH, null, null,
                                              null, null, null, attachmentIds ); //attach unsigned documents in case of docusign
                    deliveryMethod += emailToNameForApprover != null && !emailToNameForApprover.keySet().isEmpty() ? ' Approver' : ''; //add ' Approver' if approver is present
                    deliveryMethod += ' ' + String.valueOf( emailToNameForCc != null ? ( emailToNameForCc.keySet().size() <= MAX_NUMBER_OF_DOCUSIGN_CC_USERS ? emailToNameForCc.keySet().size() : MAX_NUMBER_OF_DOCUSIGN_CC_USERS ) : 0 ) + 'CC'; //add ' xxCC' if CCs are present
                }
                if( !String.isBlank( deliveryMethodId ) ) {
                    request.addConfiguration( parentId, ddpNameForDocument, deliveryMethodId, null, contactToId,
                                              emailToNameForApprover, emailToNameForCc, null, attachmentIds );
                } else if( !String.isBlank( deliveryMethod ) ) {
                    request.addConfiguration( parentId, ddpNameForDocument, deliveryMethod, null, contactToId,
                                              emailToNameForApprover, emailToNameForCc, null, attachmentIds );
                }
                request.sendRequest();
				if(attachmentIds == null) attachmentIds = new List<Id>();
				setSendThisTimeToFalse(new Set<Id>(attachmentIds), proposal.Id); //MRS 7320 7406
            }

            if( !proposal.Is_Change_Order__c ) {
                PageReference pr = new PageReference( '/' + String.valueOf( proposal.Id ) );
                pr.setRedirect(true);
                return pr;
            }
        }
        return null;
    }

    /*public static Boolean updateLoopDdpFilesRecords( List<DocumentWrapper> documentWrapperList, String ddpName ) {
      if( documentWrapperList == null || ddpName != PROPOSAL_DDP_NAME ) return true; // in case we want just to create  a PDF
        List<Loop__DDP_File__c> attachmentsInRfpFolder = [SELECT Id FROM Loop__DDP_File__c WHERE  Loop__Compare_Field__c =: '<<Proposal_RFP_Attachments>>'];
        System.Savepoint sp_updateLoopDdpFilesRecords = Database.setSavepoint();
        try {
            delete attachmentsInRfpFolder;
        } catch(Exception e) {
            Database.rollback( sp_updateLoopDdpFilesRecords );
            return false;
        }
        List<Loop__DDP__c> loopDdp = [SELECT Id FROM Loop__DDP__c WHERE Name = : PROPOSAL_DDP_NAME limit 1];
        if( loopDdp.isEmpty() ) return true;
        attachmentsInRfpFolder = new List<Loop__DDP_File__c>();
        for( DocumentWrapper document: documentWrapperList ) {
            attachmentsInRfpFolder.add( new Loop__DDP_File__c( Name = document.documentName,
                                                               Loop__Type__c = document.documentName.lastIndexOf('.') > 0 ? document.documentName.substring(document.documentName.lastIndexOf('.') + 1) : null,
                                                               Loop__Document_ID__c = document.documentId,
                                                               Loop__Advanced_Optional__c = true,
                                                               Loop__Compare_Field__c = '<<Proposal_RFP_Attachments>>',
                                                               Loop__Compare_Type__c = 'contains',
                                                               Loop__Compare_Value__c = document.documentName,
                                                               Loop__DDP__c = loopDdp[0].id ) );
        }
        try {
            insert attachmentsInRfpFolder;
        } catch( Exception e ) {
            Database.rollback( sp_updateLoopDdpFilesRecords );
            return false;
        }
        return true;
    }*/

    public static String updateAttachedDocuments( List<DocumentWrapper> documentWrapperList ) {
        List<String> attachedDocuments = new List<String>();
        for( DocumentWrapper docWrapper: documentWrapperList ){
            if( docWrapper.isAttached ) attachedDocuments.add(docWrapper.documentId);
        }
        return String.join(attachedDocuments, ProposalServices.PROPOSAL_RFP_ATTACHMENTS_DELIMITER);
    }

    public static Set<Id> getProjectIdsFromProjectTeam(List<Project_Team__c> projectTeams) {
        Set<Id> projectIds = new Set<Id>();
        for (Project_Team__c t : projectTeams) {
            for (Project_Profile__c p : t.Projects__r) {
                if (!projectIds.contains(p.Id)) {
                    projectIds.add(p.Id);
                }
            }
        }
        return projectIds;
    }

    public static Set<Id> getProjectIdsFromUser( List<User> users ) {
        Set<Id> projectIds = new Set<Id>();
        for( User user : users ) {
            for( Project_Profile__c project : user.Projects2__r ) {
                if( !projectIds.contains( project.Id ) ) {
                    projectIds.add( project.Id );
                }
            }
        }
        return projectIds;
    }

    public static Boolean hasBillingOccurredOnProject( Id projectId ) {
        if( projectId == null ) return false;
        List<Billing_Line_Item__c> blis = [ SELECT Id FROM Billing_Line_Item__c WHERE Project_Profile__c = : projectId AND Active_Billing_Line_Item__c = true ];
        return !blis.isEmpty();
    }

    public static String setCurrentStep( Proposal__c proposal, String currentStep ) {
        if( !String.isEmpty( currentStep ) && currentStep.isNumeric() && Integer.valueOf( currentStep ) < 4 && Integer.valueOf( currentStep ) >= 1 ) {
            proposal.Step__c = Integer.valueOf( currentStep );
        } else {
            proposal.Step__c = 1;
        }
        return String.valueOf( proposal.Step__c );
    }

    public static List<Service_Item__c> saveServiceItems( ProposalWizardModel pwm, Proposal__c proposal, List<ServiceModel> incomingServiceModels, List<FloorWrapper> floorWrapperList, Map<Integer, Phase__c> incomingPhaseNumberToPhase, List<Phase__c> phases,
                                                          Id selectedPhaseId, Id activeChangeOrderId, Service_Template__c st, Service_Template__c serviceTemplateForNewServices,
                                                          Integer quantityOfServicesToInsert, String inspectionType, Boolean showAppendedServiceName, String serviceType,
                                                          Boolean isAdmin, Boolean isThisUserAssignedSIPSUser, Boolean isSIPSUserInChangeOrder, Boolean requiredSIPSFieldsPopulated,
                                                          String selectedVendor, String discountQuantity, Account billingAccountForFields ) {
        Boolean isSingleTemplate = st != null; //if true then service comes from right panel
        List<Service_Item__c> servicesToInsert = new List<Service_Item__c>();
        Service_Item__c si;
        List<Service_Item__c> servicesToCreateJunctions = new List<Service_Item__c>();
        Map<String, Integer> changeOrderIdToRowNumber = new Map<String, Integer>();
        List<ServiceModel> serviceModels;
        Map<Integer, Phase__c> phaseNumberToPhase;
        String sortedFloors = FloorServices.createFloorsString( floorWrapperList, false );
        String groupKey = quantityOfServicesToInsert > 1 ? MilroseDevHelper.getKeyForServiceGroup() : null;
        //List<Service_Floor_Junction__c> serviceFloorJunctionsToInsert = new List<Service_Floor_Junction__c>();
        //Set<Id> serviceFloorJunctionsToDelete = new Set<Id>();

        if( isSingleTemplate ) { //create service model from template from right panel
            Decimal clientPrice;
            List<Client_Price__c> clientPrices = [ SELECT Medium_Price__c
                                                   FROM Client_Price__c
                                                   WHERE Service__c = : st.Id AND Client__c = : proposal.Billing_Company_Name__c
                                                   LIMIT 1 ];
            ServiceModel smSingle = new ServiceModel( st, !clientPrices.isEmpty() ? clientPrices[0] : null );
            smSingle.isAlternative = serviceType == 'Alternative';
            smSingle.changeOrderId = activeChangeOrderId;
            smSingle.discount = String.isBlank( activeChangeOrderId )
                                ? ( proposal.Apply_Discount__c ? proposal.Discount_Percentage__c : 0 )
                                : ( pwm.changeOrderModelMap.get( activeChangeOrderId ).changeOrderRecord.Apply_Discount__c ? pwm.changeOrderModelMap.get( activeChangeOrderId ).changeOrderRecord.Discount_Percentage__c : 0 );
            smSingle.isOriginal = String.isBlank( activeChangeOrderId );
            smSingle.isAmendmendAdded = !String.isBlank( activeChangeOrderId );
            smSingle.quantity = 1;
            //smSingle.phaseStep = 1;
            phaseNumberToPhase = new Map<Integer, Phase__c>{ 1 => new Phase__c( Id = selectedPhaseId != null ? selectedPhaseId : phases[0].Id ) };
            serviceModels = new List<ServiceModel>{ smSingle };
        } else { //create service models from step 2 or bundle, or update existing service models on proposal
            quantityOfServicesToInsert = 1;
            phaseNumberToPhase = incomingPhaseNumberToPhase;
            serviceModels = incomingServiceModels;
        }

        for( ServiceModel sm : serviceModels ) {
            for( Integer i = 0; i < quantityOfServicesToInsert; i++ ) {
                if( sm.isTemplate ) {
                    si = new Service_Item__c();
                    if( !String.isBlank( groupKey ) ) {
                        si.Service_Group_Key__c = groupKey;
                    } else if( !String.isBlank( sm.serviceItemRecord.Service_Group_Key__c ) ) { //for service bundle, we put this value to sm.serviceItemRecord.Service_Group_Key__c
                        si.Service_Group_Key__c = sm.serviceItemRecord.Service_Group_Key__c;
                    }

                    //MRS-7530
                    ServiceItemServices.populateServiceItemFromServiceTemplateFields(sm.serviceTemplateRecord, si, true);

                    si.Quantity__c = sm.quantity;
                    si.Phase__c = /*sm.isAlternative ? null : *//*phaseNumberToPhase.get( sm.phaseStep ).Id; */phaseNumberToPhase.get( 1 ).Id;
                    si.Unit_Price__c = sm.servicePrice;
                    si.Proposal__c = proposal.Id;
                    if(proposal.Billing_Company_Name__c == null ||
                             (proposal.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c != 'Exempt' && proposal.Billing_Company_Name__r.c2g__CODASalesTaxStatus__c != 'Exempt for Qualifying Products')) { //MRS 7096
                        si.Tax_Code_1__c = sm.serviceTemplateRecord.Tax_Code_1__c;
                        si.Tax_Code_2__c = sm.serviceTemplateRecord.Tax_Code_2__c;
                    }
                    si.Discount_Percentage__c = sm.discount;
                    si.Original__c = sm.isOriginal == null ? true : sm.isOriginal;
                    si.Is_Alternative__c = sm.isAlternative;
                    si.Change_Order__c = sm.changeOrderId;
                    si.Is_Amendmend_Added__c = sm.isAmendmendAdded == null ? false : sm.isAmendmendAdded;
                    si.Is_Amendmend_Deleted__c = sm.isAmendmendDeleted == null ? false : sm.isAmendmendDeleted;
                    si.Non_Billable_Reason__c = ''; // MRS 7056

                    if( !String.isBlank( sm.changeOrderId ) ) {
                        si.Row_Position__c = changeOrderIdToRowNumber.get( sm.changeOrderId ) == null ? pwm.getServiceMaxRowNumberInChangeOrder( activeChangeOrderId ) : changeOrderIdToRowNumber.get( sm.changeOrderId ) + i + 1;
                        changeOrderIdToRowNumber.put( sm.changeOrderId, Integer.valueOf( si.Row_Position__c ) );
                    } else if( sm.isAlternative ) {
                        si.Row_Position__c = changeOrderIdToRowNumber.get( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) == null ? pwm.getServiceMaxRowNumberInChangeOrder( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) : changeOrderIdToRowNumber.get( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) + i + 1;
                        changeOrderIdToRowNumber.put( ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER, Integer.valueOf( si.Row_Position__c ) );
                    } else {
                        si.Row_Position__c = changeOrderIdToRowNumber.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) == null ? pwm.getServiceMaxRowNumberInChangeOrder( ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) : changeOrderIdToRowNumber.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) + i + 1;
                        changeOrderIdToRowNumber.put( ChangeOrderServices.ORIGINAL_CHANGE_ORDER, Integer.valueOf( si.Row_Position__c ) );
                    }

                    if( isAdmin || isThisUserAssignedSIPSUser || isSIPSUserInChangeOrder ) {
                        if( requiredSIPSFieldsPopulated == true &&
                            sm.serviceTemplateRecord.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION &&
                            inspectionType != null ) {
                            si.Service_Name_Full__c += ' for ';
                            List<String> inspTypesArr = inspectionType.split(';');
                            for( String inspType : inspTypesArr ) {
                                Inspection_Types__c inspTypeRecord = Inspection_Types__c.getValues( inspType.left(38) );
                                si.Service_Name_Full__c += ( inspTypeRecord != null ? inspTypeRecord.Full_Name__c : inspType ) + ( inspTypesArr.size() > 1 ? ';' : '' );
                            }
                            si.Service_Name_Full__c += inspTypesArr.size() > 1 ? ' inspections ' : ' inspection ';
                            si.Service_Name_Full__c += 'from ' + selectedVendor;
                            //si.Service_Name_Short__c = sm.serviceTemplateRecord.Service_Name_Full__c;
                        }/* else {
                            si.Service_Name_Short__c = si.Service_Name_Full__c;
                        }*/
                        si.Service_Name_Short__c = si.Service_Name_Full__c.length() > 255 ? si.Service_Name_Full__c.substring(0, 255) : si.Service_Name_Full__c;
                    } else {
                        si.Service_Name_Short__c = sm.serviceTemplateRecord.Short_Service_Name__c;
                    }

                    if( showAppendedServiceName != null && showAppendedServiceName && serviceTemplateForNewServices != null && !String.isBlank( serviceTemplateForNewServices.Work_Type_CWP_LOC__c ) ) {
                        populateWorkTypeAndFullName( si, sm, null, serviceTemplateForNewServices );
                    } else {
                        si.Work_Type__c = sm.serviceTemplateRecord.Work_Type__c != null ? sm.serviceTemplateRecord.Work_Type__c.replace( '; ', ';' ).replace( ';', '; ' ) : sm.serviceTemplateRecord.Work_Type__c;
                    }

                    if( !sm.isAlternative ) {
                        si.Floor__c = sortedFloors;
                        servicesToCreateJunctions.add( si );
                    }
                    if( isAdmin ) si.Service_Group__c = 1;
                } else { //update existing service items on wizard saves, proposal status updates etc
                    si = sm.serviceItemRecord;
                    si.Quantity__c = sm.quantity;
                    si.Quantity_Old__c = sm.quantityOld;
                    si.Phase__c = /*sm.isAlternative ? null : */sm.phaseId;
                    if( sm.getIsUnitPriceRequired() && ( sm.servicePrice == null /*|| sm.servicePrice == 0*/ ) ) {
                        throw new ErrorException( 'You should set the Unit Price for services requiring this before applying changes.' );
                        return null;
                    }
                    si.Unit_Price__c = sm.servicePrice;
                    si.Proposal__c = proposal.Id;
                    si.Discount_Percentage__c = sm.discount;
                    si.Row_Position__c = sm.rowNumber;
                    si.Service_Group__c = sm.serviceGroup.isNumeric() ? Integer.valueOf( sm.serviceGroup ) : null;
                    si.Change_Order__c = sm.changeOrderId;
                    si.Change_Order_Old__c = sm.changeOrderOldId;
                    si.Is_Amendmend_Added__c = sm.isAmendmendAdded;
                    si.Is_Amendmend_Deleted__c = sm.isAmendmendDeleted;
                    si.Municipal_Agency_ID__c = sm.municipalAgency;
                    if( !sm.isAlternative && !proposal.Is_Floors_To_Services__c ) {
                        si.Floor__c = sortedFloors;
                    }
                }

                if( billingAccountForFields != null ) {
                    si.Sales_Tax_Status__c = billingAccountForFields.c2g__CODASalesTaxStatus__c;
                }

                servicesToInsert.add( si );
            }
        }

        try {
            //pwm.updateServiceToFloorJunctions( serviceFloorJunctionsToDelete, serviceFloorJunctionsToInsert );
            UPSERT( servicesToInsert );
            ProposalWizardServices.createServiceFloorJunctions( proposal.Is_Floors_To_Services__c, servicesToCreateJunctions, null, floorWrapperList, true );
            return servicesToInsert;
        } catch( Exception e ) {
            throw new ErrorException( 'Error saving Service Item. ' + e.getMessage() );
        }
    }

    public static void populateWorkTypeAndFullName( Service_Item__c si, ServiceModel sm, Service_Bundle_Item__c sbi, Service_Template__c st ) {
        if( st != null ) {
            Boolean isRegularService = si != null && sm != null;
            Boolean isBundle = sbi != null;
            if( isRegularService || isBundle ) {
                String fullName = '';
                String workType = '';
                String workTypeNamePart = '';
                String planSubmissionType = '';
                String issuance = '';

                if( isRegularService ) {
                    fullName = si.Service_Name_Full__c;
                    workType = st.Work_Type_CWP_LOC__c.replace( ';', '; ' );
                    workTypeNamePart = ' ' + st.Work_Type_CWP_LOC__c.replace( ';', ' ' );
                    planSubmissionType = sm.serviceTemplateRecord.Plan_Submission_Type__c;
                    issuance = sm.serviceTemplateRecord.Issuance__c;
                } else { //isBundle
                    fullName = st.Service_Name_Full__c;
                    workType = sbi.Work_Type__c/*.replace(';', '; ')*/;
                    workTypeNamePart = ' ' + sbi.Work_Type__c.replace(';', '');
                    planSubmissionType = st.Plan_Submission_Type__c;
                    issuance = st.Issuance__c;
                }

                String planSubmissionAndIssuanceNamePart = '';
                if( fullName.contains( '-' + planSubmissionType ) ) {
                    planSubmissionAndIssuanceNamePart = fullName.substring( fullName.indexOf( '-' + planSubmissionType ) );
                } else if( fullName.contains( '-' + issuance ) ) {
                    planSubmissionAndIssuanceNamePart = fullName.substring( fullName.indexOf( '-' + issuance ) );
                }
                if( !String.isBlank( planSubmissionAndIssuanceNamePart ) ) {
                    fullName = fullName.replace( planSubmissionAndIssuanceNamePart, workTypeNamePart );
                    fullName += planSubmissionAndIssuanceNamePart;
                } else {
                    fullName += workTypeNamePart;
                }

                if( isRegularService ) {
                    si.Work_Type__c = workType;
                    si.Service_Name_Full__c = fullName;
                } else { //isBundle
                    st.Work_Type__c = workType;
                    st.Service_Name_Full__c = fullName;
                }
            }
        }
    }

    public static void regenerateServiceGroupKeys( List<Service_Bundle_Item__c> serviceBundleItems ) {
        Map<String, String> oldKeyToNewKey = new Map<String, String>();
        for( Service_Bundle_Item__c serviceBundleItem : serviceBundleItems ) {
            String oldKey = serviceBundleItem.Service_Group_Key__c;
            if( !String.isBlank( oldKey ) ) {
                if( !oldKeyToNewKey.containsKey( oldKey ) ) {
                    oldKeyToNewKey.put( oldKey, MilroseDevHelper.getKeyForServiceGroup() );
                }
                serviceBundleItem.Service_Group_Key__c = oldKeyToNewKey.get( oldKey );
            }
        }
    }

    public static PageReference returnToWizard( Proposal__c proposal, String wizardPageref, String mode, Integer formPosition ) {
        PageReference retUrl = new PageReference( ProposalWizardServices.WIZARD_PAGEREF + wizardPageref );
        retUrl.getParameters().put( 'id', proposal.Id );
        retUrl.getParameters().put( 'step', ( !String.isEmpty( String.valueOf( proposal.Step__c ) ) ) ? String.valueOf( proposal.Step__c ) : '1' );
        if( !String.isBlank( mode ) ) {
            retUrl.getParameters().put( 'mode', mode );
        }
        if( formPosition != null && formPosition > 0 ) {
            retUrl.getParameters().put( 'scroll', String.valueOf( formPosition ) );
        }
        retUrl.setRedirect(true);
        return retUrl;
    }

    public static Boolean hasPendingChangeOrders( ProposalWizardModel pwm ) {
        for( ChangeOrderModel coModelItem : pwm.notApprovedChangeOrders ) {
            if( coModelItem.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                return true;
            }
        }
        return false;
    }

    public static List<Service_Floor_Junction__c> createServiceFloorJunctions( Boolean isFloorsToServices, List<Service_Item__c> serviceItems, List<ServiceModel> serviceModels, List<FloorWrapper> floorWrappers, Boolean isInsert ) {
        List<Service_Floor_Junction__c> serviceFloorJunctions = new List<Service_Floor_Junction__c>();
        if( isFloorsToServices ) {
            if( serviceItems != null ) {
                for( Service_Item__c serviceItem : serviceItems ) {
                    if( !serviceItem.Is_Alternative__c ) {
                        serviceFloorJunctions.addAll( addServiceFloorJunctions( serviceItem.Id, floorWrappers ) );
                    }
                }
            }
            if( serviceModels != null ) {
                for( ServiceModel smItem : serviceModels ) {
                    if( !smItem.isAlternative ) {
                        serviceFloorJunctions.addAll( addServiceFloorJunctions( smItem.recordId, floorWrappers ) );
                    }
                }
            }
            if( isInsert ) INSERT serviceFloorJunctions;
        }
        return serviceFloorJunctions;
    }

    private static List<Service_Floor_Junction__c> addServiceFloorJunctions( Id serviceItemId, List<FloorWrapper> floorWrappers ) {
        List<Service_Floor_Junction__c> serviceFloorJunctions = new List<Service_Floor_Junction__c>();
        if( !String.isBlank( serviceItemId ) ) {
            for( FloorWrapper floorModel : floorWrappers ) {
                if( !String.isBlank( floorModel.floorId ) ) {
                    serviceFloorJunctions.add( new Service_Floor_Junction__c( Service_Item__c = serviceItemId, Floor__c = floorModel.floorId) );
                }
            }
        }
        return serviceFloorJunctions;
    }

    public static List<Change_History_Proposal__c> getChangeHistory( Id recordId ) {
        if( String.isBlank( recordId ) ) {
            return new List<Change_History_Proposal__c>();
        }
        return new List<Change_History_Proposal__c>( [ SELECT Id, Change_Order__c, Link__c, User__c, Date__c, Proposal__c,
                                                              Status__c, Version__c, Version_Text__c, Type__c, Item_Name__c, Change_Order__r.Number__c
                                                       FROM Change_History_Proposal__c
                                                       WHERE Proposal__c = : recordId
                                                       ORDER BY Date__c, Version_Text__c ] );
    }

    public static Map<Id, Task_Item__c> getDeletedTaskItemsInChangeOrderModel( List<ChangeOrderModel> changeOrderModels, String changeOrderId ) {
        Set<Id> serviceItemIds = new Set<Id>();
        for( ChangeOrderModel coModelItem : changeOrderModels ) {
            if( coModelItem.changeOrderRecord.Id == changeOrderId ) {
                for( ServiceModel smItem : coModelItem.serviceModels ) {
                    if( smItem.isAmendmendDeleted && smItem.changeOrderId == changeOrderId ) {
                        serviceItemIds.add( smItem.recordId );
                    }
                }
            }
        }
        if( !serviceItemIds.isEmpty() ) {
            return new Map<Id, Task_Item__c>( [ SELECT Id, Billing_Percentage__c, Billing_Trigger__c
                                                FROM Task_Item__c
                                                WHERE Is_Locked__c = false
                                                  AND Billing_Trigger__c = true
                                                  AND Service_Item__c IN : serviceItemIds ] );
        }
        return new Map<Id, Task_Item__c>();
    }

    public static void redirectBillingTriggers( Id dataFileId, Id changeOrderId ) {
        List<DDP_Helper__c> dataFiles = [ SELECT Text1__c, Change_Order__c FROM DDP_Helper__c WHERE Id = : dataFileId ];
        String data;
        Map<Id, Id> oldTaskIdToNewTaskId = new Map<Id, Id>();
        Map<String, Set<Id>> compositeIdToOldTaskIds =  new Map<String, Set<Id>>();

        String taskTemplatePrefix = Task_Template__c.sObjectType.getDescribe().getKeyPrefix();
        String taskItemPrefix = Task_Item__c.sObjectType.getDescribe().getKeyPrefix();

        Set<Id> serviceItemIds = new Set<Id>();
        Set<Id> taskTemplateIds = new Set<Id>();

        //format: oldTaskItemId:newServiceItemId,newTaskItemId;
        if( !dataFiles.isEmpty() ) {
            data = dataFiles[0].Text1__c;
            if( data == null ) data = '';
            for( String dataFragment : data.split( CHANGE_ORDER_SPLITTER ) ) {
                List<String> oldTaskItemIdToServiceItemIdAndTaskItemId = dataFragment.split( CHANGE_ORDER_CONTENT );
                if( oldTaskItemIdToServiceItemIdAndTaskItemId.size() == 2 ) {
                    List<String> serviceItemIdAndTaskItemId = oldTaskItemIdToServiceItemIdAndTaskItemId[1].split( SERVICE_ITEM_SPLITTER );
                    if( serviceItemIdAndTaskItemId.size() == 2 ) {
                        String oldTaskItemId = oldTaskItemIdToServiceItemIdAndTaskItemId[0];
                        String serviceItemId = serviceItemIdAndTaskItemId[0];
                        String taskItemId = serviceItemIdAndTaskItemId[1]; //can be template
                        String taskPrefix = taskItemId.substring(0, 3);
                        if( taskPrefix.equals( taskItemPrefix ) ) {
                            oldTaskIdToNewTaskId.put( oldTaskItemId, taskItemId );
                        } else if( taskPrefix.equals( taskTemplatePrefix ) ) {
                            serviceItemIds.add( serviceItemId );
                            taskTemplateIds.add( taskItemId );
                            if( compositeIdToOldTaskIds.get( serviceItemId + taskItemId ) == null ) {
                                compositeIdToOldTaskIds.put( serviceItemId + taskItemId, new Set<Id>() );
                            }
                            compositeIdToOldTaskIds.get( serviceItemId + taskItemId ).add( oldTaskItemId );
                        }
                    }
                }
            }

            //system.debug(LoggingLevel.Error, 'xxx dataFileId: ' + dataFileId);
            //system.debug(LoggingLevel.Error, 'xxx changeOrderId: ' + changeOrderId);
            //system.debug(LoggingLevel.Error, 'xxx oldTaskIdToNewTaskId: ' + oldTaskIdToNewTaskId);
            //system.debug(LoggingLevel.Error, 'xxx serviceItemIds: ' + serviceItemIds);
            //system.debug(LoggingLevel.Error, 'xxx taskTemplateIds: ' + taskTemplateIds);
            //system.debug(LoggingLevel.Error, 'xxx compositeIdToOldTaskIds: ' + compositeIdToOldTaskIds);
            if( !serviceItemIds.isEmpty() && !taskTemplateIds.isEmpty() ) {
                Map<String, Id> compositeIdToNewTaskItemId = new Map<String, Id>();
                for( Task_Item__c ti : [ SELECT Service_Item__c, Task_Template__c
                                         FROM Task_Item__c
                                         WHERE Service_Item__c IN : serviceItemIds
                                           AND Task_Template__c IN : taskTemplateIds ] ) {
                    compositeIdToNewTaskItemId.put( String.valueOf(ti.Service_Item__c) + String.valueOf(ti.Task_Template__c), ti.Id );
                }
                for( String compositeId : compositeIdToOldTaskIds.keySet() ) {
                    if( compositeIdToNewTaskItemId.get( compositeId ) == null ) {
                        throw new ErrorException( 'Some Task Items that were involved in the process were not created. Aborting operation.' );
                        return;
                    } else {
                        for( Id idItem : compositeIdToOldTaskIds.get( compositeId ) ) {
                            oldTaskIdToNewTaskId.put( idItem, compositeIdToNewTaskItemId.get( compositeId ) );
                        }
                    }
                }
            }

            Set<Id> allTaskItemIds = new Set<Id>();
            allTaskItemIds.addAll( oldTaskIdToNewTaskId.keySet() );
            allTaskItemIds.addAll( oldTaskIdToNewTaskId.values() );
            Map<Id, Task_Item__c> taskItemsFromDatabase = new Map<Id, Task_Item__c> ( [ SELECT Service_Item__c, Billing_Trigger__c, Billing_Percentage__c
                                                                                        FROM Task_Item__c
                                                                                        WHERE Id IN : allTaskItemIds ] );
            //system.debug(LoggingLevel.Error, 'xxx allTaskItemIds: ' + allTaskItemIds);
            //system.debug(LoggingLevel.Error, 'xxx taskItemsFromDatabase: ' + taskItemsFromDatabase);
            for( Id taskId : oldTaskIdToNewTaskId.keySet() ) {
                Task_Item__c oldTaskItem = taskItemsFromDatabase.get( taskId );
                Task_Item__c newTaskItem = taskItemsFromDatabase.get( oldTaskIdToNewTaskId.get( taskId ) );
                if( oldTaskItem.Billing_Percentage__c != null && oldTaskItem.Billing_Percentage__c != 0 && oldTaskItem.Billing_Trigger__c ) {
                    newTaskItem.Billing_Trigger__c = true;
                    oldTaskItem.Billing_Trigger__c = false;
                    if( newTaskItem.Billing_Percentage__c == null ) {
                        newTaskItem.Billing_Percentage__c = 0.00;
                    }
                    newTaskItem.Billing_Percentage__c += oldTaskItem.Billing_Percentage__c;
                    oldTaskItem.Billing_Percentage__c = null;
                    newTaskItem.Avoid_Validation_Rules__c = true;
                    oldTaskItem.Avoid_Validation_Rules__c = true;
                }
            }
            //system.debug(LoggingLevel.Error, 'xxx oldTaskIdToNewTaskId: ' + oldTaskIdToNewTaskId);
            //system.debug(LoggingLevel.Error, 'xxx taskItemsFromDatabase: ' + taskItemsFromDatabase);

            //remove billing triggers from task items with 0 percentage and billing trigger set from services deleted in current CO
            for( Task_Item__c ti : [ SELECT Billing_Trigger__c, Billing_Percentage__c
                                      FROM Task_Item__c
                                      WHERE Billing_Trigger__c = true
                                        AND Billing_Percentage__c = 0
                                        AND Service_Item__r.Is_Amendmend_Deleted__c = true
                                        AND Service_Item__r.Change_Order__c = : changeOrderId
                                        AND Id NOT IN : taskItemsFromDatabase.keySet() ] ) {
                ti.Billing_Trigger__c = false;
                ti.Billing_Percentage__c = null;
                ti.Avoid_Validation_Rules__c = true;
                taskItemsFromDatabase.put( ti.Id, ti );
            }
            //ErrorException.addLog( String.valueOf( taskItemsFromDatabase.keyset() ), 'Billing Triggers' );

            Savepoint sp_changeBillingTriggers = Database.setSavepoint();
            try {
                TaskItemServices.taskDurationCalculationPreventor = true;
                UPDATE taskItemsFromDatabase.values();
                //DELETE dataFiles;
                DELETE [ SELECT Id
                         FROM DDP_Helper__c
                         WHERE Change_Order__c = : dataFiles[0].Change_Order__c
                           AND Type__c = : CHANGE_ORDER_APPROVAL_TYPE ];
            } catch( dmlException dmlEx ) {
                //system.debug(LoggingLevel.Error, 'xxx dmlEx: ' + dmlEx);
                DataBase.rollback( sp_changeBillingTriggers );
                throw new ErrorException( 'Unable to move billing triggers to new services. The action is aborted.' + dmlEx);
                return;
            }
        } else {
            throw new ErrorException( 'The data for Change Order Approval was not found.' );
            return;
        }
    }

    public static Boolean isCustomWorkTypeService( String category, String type, Boolean isOtherService ) {
        return !isOtherService &&
               ( category == RFIScopeServices.APPLICATION_SIGN_OFF &&
                    ( type == ServiceTemplateServices.LETTER_OF_COMPLETION || type == ServiceTemplateServices.SINGLE_LETTER_OF_COMPLETION ||
                      type == ServiceTemplateServices.TYPE_CERTIFICATE_OF_APPROVAL_COMPLETION || type == ServiceTemplateServices.TYPE_SINGLE_CERTIFICATE_OF_APPROVAL_COMPLETION
                    )
               ) ||
               ( category == RFIScopeServices.APPLICATION_FILING && ( type == ServiceTemplateServices.CONSTRUCTION_WORK_PERMIT || type == ServiceTemplateServices.SINGLE_CONSTRUCTION_WORK_PERMIT ) ) ||
               ( category == RFIScopeServices.AMENDMENT_APPLICATION_FILING );
    }

    public static Map<String, Last_Proposal_Price__c> uniqueCombinationLastProposalPrice(List<ServiceModel> serviceModelList, Proposal__c proposal) {
        Map<String, Last_Proposal_Price__c> uniqueCombinationLastProposalPriceMap = new Map<String, Last_Proposal_Price__c>();
        if(serviceModelList.isEmpty()) return uniqueCombinationLastProposalPriceMap;
        Id lastProposalPriceId;
        for( ServiceModel smItem : serviceModelList ) {
            lastProposalPriceId = (!String.isBlank(smItem.lastProposalPriceId) ? smItem.lastProposalPriceId : null ) ;
            uniqueCombinationLastProposalPriceMap.put((String)smItem.serviceItemRecord.Service_Template__c + (String)proposal.Billing_Company_Name__c,
                new Last_Proposal_Price__c( Id = lastProposalPriceId,
                                    Service__c = smItem.serviceItemRecord.Service_Template__c,
                                    Last_Proposal__c = proposal.Id,
                                    Unique_Combination__c = (String)smItem.serviceItemRecord.Service_Template__c + (String)proposal.Billing_Company_Name__c,
                                    Client__c = proposal.Billing_Company_Name__c,
                                    Last_Proposed_Price__c = smItem.servicePrice ) );
        }
        return uniqueCombinationLastProposalPriceMap;
    }

    public static Boolean isCZSpesialistRequired( Proposal__c proposal ) {
        return ( ( ( proposal.Is_Draft__c &&
                     !String.isBlank( proposal.sowScopeOfWork__c ) ) &&
                   ( ( proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_NEW_BUILDING) ||
                       proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_HUB_PROJECT) ) ||
                     ( proposal.sowScopeOfWork__c.contains(ProposalWizardServices.SOW_EXISTING_SPACE) &&
                       proposal.sowServicesNeededAPS__c &&
                       ProposalWizardServices.isSomethingFromSecondSectionActive( proposal ) ) ) ) ||
                 ( !proposal.Is_Draft__c &&
                   ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                     proposal.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                     proposal.Status__c == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ) );
    }

    public static Boolean isUserAllowedToCreateChangeOrderOnProjectLevel( Id userId, String profileName,
                                                                          String roleName, Proposal__c proposal ) {
        if( ( !String.isEmpty( proposal.Id ) && !String.isBlank( proposal.Project_Profile__c ) ) &&
            ( ( userId == proposal.Project_Profile__r.OwnerId ) ||
              ( ( profileName == UserServices.PROFILE_ACCOUNT_MANAGER &&
                  userId == proposal.Project_Profile__r.Account_Executive__c ) ||
                ( profileName == UserServices.PROFILE_ACCOUNT_MANAGER &&
                  (roleName == UserServices.ROLE_MANAGER_OF_ACCOUNTS || roleName == UserServices.ROLE_ACCOUNT_MANAGER) ) || //MRS 7592
                ( ( profileName.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) ) && //MRS-6507
                  roleName == proposal.Region__c + ' ' + UserServices.ROLE_OPERATIONS_MANAGER ) ||
                ( profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) ||
                ( profileName == UserServices.PROFILE_PRODUCTION_MANAGER &&
                  userId == proposal.Project_Profile__r.Production_Manager__c ) ||
                ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ) ) ) {
            return true;
        }
        return false;
    }

    public static Boolean isUserAllowedToCreateChangeOrderOnServiceItemLevel( Id userId, String profileName,
                                                                              String roleName, Proposal__c proposal,
                                                                              List<Service_Item__c> serviceItems,
                                                                              List<ServiceModel> serviceModels ) {
        if( ( !String.isBlank( proposal.Id ) && !String.isBlank( proposal.Project_Profile__c ) ) &&
            ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) ||
              ( profileName == UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME ) ||
              ( profileName.contains( UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER ) ) ||
              ( profileName == UserServices.PROFILE_SIPS_COORDINATOR ) ||
              ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST &&
                !roleName.contains( UserServices.ROLE_CZ_MANAGER ) ) ||
              ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST &&
                roleName.contains( UserServices.ROLE_CZ_MANAGER ) &&
                roleName.startsWith( proposal.Region__c ) ) ||
              ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST &&
                roleName == UserServices.ROLE_CODE_ZONING_ANALYST ) ||
              ( profileName == UserServices.SYSTEM_ADMINISTRATOR ) ||
              ( profileName == UserServices.SUPPORT_STAFF ) ||
              ( profileName == UserServices.PROFILE_ACCOUNT_MANAGER ) ||
              ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN )
            ) ) {
            if( serviceItems != null ) {
                if( !serviceItems.isEmpty() ) {
                    for( Service_Item__c si : serviceItems ) {
                        if( si.Manager_Lookup__c == userId ||
                            si.OwnerId__c == userId ) {
                            return true;
                        }
                    }
                } else {
                    return true;
                }
            } else if( serviceModels != null ) {
                if( !serviceModels.isEmpty() ) {
                    for( ServiceModel sm : serviceModels ) {
                        if( sm.serviceItemRecord.Manager_Lookup__c == userId ||
                            sm.serviceItemRecord.OwnerId__c == userId ) {
                            return true;
                        }
                    }
                } else {
                    return true;
                }
            } else {
                return false;
            }
        }
        return false;
    }



    public static Boolean isCreator( Id proposalId, Id proposalCreatorId, Id ownerId, Id currentUserId ) {
        return ( !String.isEmpty( proposalId ) && proposalCreatorId != null && currentUserId == proposalCreatorId ) ||
               ( !String.isEmpty( proposalId ) && proposalCreatorId == null && currentUserId == ownerId ) ||
               ( String.isEmpty( proposalId ) );
    }

    public static Boolean isPsIrAdmin( String profileName, String roleName, Boolean isCreator ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ||
               ( isAccManPartner( profileName ) && isCreator ) ||
               ( isPsExAdmOmLiCzAdmin( profileName, roleName ) );
    }

    public static Boolean isAccManPartner( String profileName ) {
        return profileName.contains( UserServices.PROFILE_PARTNER ) ||
               profileName.contains( UserServices.PROFILE_ACCOUNT_MANAGER );
    }

    public static Boolean isPsExAdmOmLiCzAdmin( String profileName, String roleName ) {
        return profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
               profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
               profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6625
               profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ||
               profileName == UserServices.PROFILE_OPERATIONS_MANAGER ||
               profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
               ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST && roleName == UserServices.ROLE_LI_CZ_MANAGER );
    }

    public static Boolean isProjManProdManSscAdmin( String profileName, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner ) {
        return ( !String.isEmpty( profileName ) &&
                 ( profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||  //  PM2, PM1
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ) || //  Platform Admin
               isProductionManager ||                                               //  Prod manager
               isSsmOrOmOrSscOwner;                                                 //  SSC (+SIPS) and Owner
    }

    public static Boolean disableInputs( String profileName, String roleName, String status, Boolean isCreator, Boolean isThisUserReviewer,
                                         Boolean isMi3, Boolean isThisUserAssignedCZAnalyst, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return !( ( isPsIrAdmin( profileName, roleName, isCreator ) &&
                    ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                      status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED ) ) ||
                  ( ( ( isAccManPartner( profileName ) && isThisUserReviewer ) ||
                      profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                        status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                  ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                      profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                      profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                      isMi3 &&
                      status == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                  ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN /*|| (isThisUserAssignedCZAnalyst && status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW)*/ ) /*||
                  ( isChangeOrderAllowedOnProjectOrServiceItemLevel )*/ );
    }

    public static Boolean disableGeneralProposalNotes( String status, Boolean isCreator ){
        return !( ( isCreator &&
                    ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_REJECTED ) ) );
    }

    public static Boolean isAnyAllowedProfile( String profileName, String roleName ) {
       return profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
           profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||
           ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
           profileName.contains( UserServices.PROFILE_PARTNER ) ||
           profileName == UserServices.PROFILE_ACCOUNT_MANAGER ||
           profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6723
           profileName == UserServices.PROFILE_CODE_ZONING_ANALYST;
    }

    public static Boolean areServiceButtonsEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( ( isChangeOrder &&
                  ( canCreateNewCo || //MRS-6780
                    isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                    isPsIrAdmin( profileName, roleName, isCreator ) ||
                    isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                    status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ) ) ||
                ( ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                    profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean arePhasesButtonsEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( ( isChangeOrder &&
                  ( canCreateNewCo || //MRS-6780
                    isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                    isPsIrAdmin( profileName, roleName, isCreator ) ||
                    profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                    (profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER && isFromChangeOrderRequestButton) || //MRS-6570
                    isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                    status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ) ) ||
                ( ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                    profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean areFloorButtonsEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( ( isChangeOrder &&
                  ( canCreateNewCo || //MRS-6780
                    isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                    isPsIrAdmin( profileName, roleName, isCreator ) ||
                    profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                    (profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER && isFromChangeOrderRequestButton) || //MRS-6570
                    isChangeOrderAllowedOnProjectOrServiceItemLevel  ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                    status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ) ) ||
                ( ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                    profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean areContactButtonsEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( isChangeOrder &&
                ( canCreateNewCo || //MRS-6780
                  isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                  isPsIrAdmin( profileName, roleName, isCreator ) ||
                  profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                  isChangeOrderAllowedOnProjectOrServiceItemLevel ||
                  ( isFromChangeOrderRequestButton &&
                    ( profileName == UserServices.PROFILE_A_R_CORDINATOR || /*MRS-5851*/
                      profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || /*MRS-5851*/
                      profileName == UserServices.PROFILE_CFO || /*MRS-5851*/
                      profileName == UserServices.PROFILE_FINANCE_MANAGER || /*MRS-5851*/
                      profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || /*MRS-6570*/
                      profileName == UserServices.PROFILE_STAFF_ACCOUNTANT /*MRS-5851*/ ) ) ) ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean enableBillingPreferences( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( isChangeOrder &&
                ( canCreateNewCo || //MRS-6780
                  profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                  ( isFromChangeOrderRequestButton &&
                    ( profileName == UserServices.PROFILE_A_R_CORDINATOR || /*MRS-5851*/
                      profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || /*MRS-5851*/
                      profileName == UserServices.PROFILE_CFO || /*MRS-5851*/
                      profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || /*MRS-6570*/
                      profileName == UserServices.PROFILE_FINANCE_MANAGER || /*MRS-5851*/
                      profileName == UserServices.PROFILE_STAFF_ACCOUNTANT /*MRS-5851*/ ) ) ) ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean enableAccountManager( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            if( isChangeOrder &&
                isFromChangeOrderRequestButton ) {
                return true;
            } else {
                return false;
            }
        }
    }

    public static Boolean isFulfillmentOfficeEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            return ( profileName == UserServices.PROFILE_OPERATIONS_MANAGER ||
                     profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   ( status == ProposalServices.PROPOSAL_STATUS_AWARDED );
        }
    }

    public static Boolean isClientProjectEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        if( !disableInputs ) {
            return true;
        } else {
            return ( ( profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
                       profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6625
                       profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                     ( status != ProposalServices.PROPOSAL_STATUS_NOT_AWARDED &&
                       status != ProposalServices.PROPOSAL_STATUS_CANCELLED &&
                       status != ProposalServices.PROPOSAL_STATUS_EXPIRED &&
                       status != ProposalServices.PROPOSAL_STATUS_WITHDRAWN ) ) ||
                   ( ( isChangeOrder ) &&
                     ( isFromChangeOrderRequestButton &&
                      ( profileName == UserServices.PROFILE_A_R_CORDINATOR || /*MRS-5851*/
                        profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || /*MRS-5851*/
                        profileName == UserServices.PROFILE_CFO || /*MRS-5851*/
                        profileName == UserServices.PROFILE_FINANCE_MANAGER || /*MRS-5851*/
                        profileName == UserServices.PROFILE_STAFF_ACCOUNTANT /*MRS-5851*/ ) ) );
        }
    }

    public static Boolean isAddPurchaseOrderButtonEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        //if( !disableInputs ) {
        //    return true;
        //} else {
            if( ( isChangeOrder &&
                  ( isPsIrAdmin( profileName, roleName, isCreator ) ||
                    isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                    profileName.contains( UserServices.PROFILE_ACCOUNT_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_STAFF_ACCOUNTANT ) ||
                    profileName == UserServices.PROFILE_A_R_CORDINATOR ||
                    profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6479
                    profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR ||
                    profileName == UserServices.PROFILE_FINANCE_MANAGER ||
                    profileName == UserServices.PROFILE_BILLING_COORDINATOR ) &&
                    ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ) ) ||
                ( !isChangeOrder &&
                  ( ( isPsIrAdmin( profileName, roleName, isCreator ) &&
                      profileName == UserServices.PROFILE_CODE_ZONING_ANALYST &&
                      status != ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                    ( isPsIrAdmin( profileName, roleName, isCreator ) &&
                      profileName != UserServices.PROFILE_CODE_ZONING_ANALYST ) ||
                    profileName.contains( UserServices.PROFILE_ACCOUNT_MANAGER ) ||
                    profileName.contains( UserServices.PROFILE_STAFF_ACCOUNTANT ) ||
                    profileName == UserServices.PROFILE_A_R_CORDINATOR ||
                    profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR ||
                    profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6479
                    profileName == UserServices.PROFILE_FINANCE_MANAGER ||
                    profileName == UserServices.PROFILE_BILLING_COORDINATOR ) &&
                    ( status != ProposalServices.PROPOSAL_STATUS_NOT_AWARDED &&
                      status != ProposalServices.PROPOSAL_STATUS_CANCELLED &&
                      status != ProposalServices.PROPOSAL_STATUS_EXPIRED &&
                      status != ProposalServices.PROPOSAL_STATUS_WITHDRAWN ) ) ) {
                return true;
            } else {
                return false;
            }
        //}
    }

    public static Boolean isAttachingFilesEnabled( String status, String profileName, String roleName, Boolean isChangeOrder, Boolean isCreator, Boolean disableInputs, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton, Boolean canCreateNewCo ) {
        return ( isCreator || profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 profileName == UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER || profileName == UserServices.PROFILE_SIPS_COORDINATOR ) && //MRS-6677
               ( ( !isChangeOrder &&
                   ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                     status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ||
                     status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                     status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                     status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                     status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                     status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ||
                 ( isChangeOrder ) );
    }

    public static Boolean isSumbitChangeOrderButtonVisible( String status, String profileName, String roleName, Boolean isChangeOrder ) {
        return isChangeOrder &&
                   ( profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                       ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                         status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED );
    }

    public static Boolean isNotAwardedButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean isChangeOrder ) {
        return !isChangeOrder &&
                    isPsIrAdmin( profileName, roleName, isCreator ) &&
                        status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
    }

    public static Boolean isAwardedButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean isChangeOrder ) {
        return !isChangeOrder &&
                    isPsIrAdmin( profileName, roleName, isCreator ) &&
                        status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
    }

    public static Boolean isWithdrawnButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) && //MRS 6835
                    ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                      status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.APPROVAL_PROCESS_STEP_REJECTED ||
                      status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT);
    }

    public static Boolean isCanceledButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) && //MRS 6835
                    ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                      status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.APPROVAL_PROCESS_STEP_REJECTED ||
                      status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT );
    }

    public static Boolean isRejectedWithNotesButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) &&
                    status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
    }

    public static Boolean isChangeOrderApprovedButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean isChangeOrder ) {
        return isChangeOrder &&
                    isPsIrAdmin( profileName, roleName, isCreator ) &&
                        status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
    }

    public static Boolean isRejectButtonVisible( String status, String profileName, String roleName, Id assignedIrId ) {
        return ( ( ( isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && !String.isBlank( assignedIrId ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ) &&
                     status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ); //MRS 7507
    }

    public static Boolean isRejectButtonEnabled( String status, String profileName, String roleName, Id assignedIrId, Id currentUserId ) {
        return ( ( ( isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && assignedIrId == currentUserId ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ) &&
                     status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW; //MRS 7507
    }

    public static Boolean isApproveButtonVisible( String status, String profileName, String roleName, Id assignedIrId ) {
        return ( ( ( isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && !String.isBlank( assignedIrId ) ) ||
                    profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ) &&
                    status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW; //MRS 7507
    }

    public static Boolean isApproveButtonEnabled( String status, String profileName, String roleName, Id assignedIrId, Id currentUserId ) {
        return ( ( ( isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && assignedIrId == currentUserId ) ||
                    profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ) &&
                    status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW; //MRS 7507
    }

    public static Boolean isSaveButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean isChangeOrder, Id assignedIrId,
                                               Id proposalId, Boolean isDraft, Boolean isUserProductionManager, Boolean isAssignedSIPSUser, Id currentUserId ) {
        return ( !String.isBlank(proposalId) && !isDraft ) &&
                ( ( profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR ) || //for saving the Display Text on Invoice
                  ( isPsIrAdmin( profileName, roleName, isCreator ) &&
                      ( status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                        status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                        status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                        status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED ) ) ||

                  ( isChangeOrder &&
                      isPsIrAdmin( profileName, roleName, isCreator ) &&
                          status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                          status == ProposalServices.PROPOSAL_STATUS_AWARDED ) ||

                  ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                      profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                      status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||

                  ( ( ( isAssignedSIPSUser ) ||
                      ( isAccManPartner( profileName ) && assignedIrId == currentUserId ) ) &&
                    ( status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ) ||

                  ( ( profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||
                      isAccManPartner( profileName ) ||
                      profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                      status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_APPROVED ) ||

                  ( ( ( isAccManPartner( profileName ) && !String.isBlank( assignedIrId ) ) ||
                        profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                      status == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||

                  ( isChangeOrder &&
                      ( profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ||
                        ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                        profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                        profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                          status == ProposalServices.PROPOSAL_STATUS_AWARDED ) );
    }

    public static Boolean isCompleteButtonVisible( String status, String profileName, String roleName ) {
        return ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW;
    }

    public static Boolean isSubmitButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean isChangeOrder ) {
        return !isChangeOrder &&
                   isPsIrAdmin( profileName, roleName, isCreator ) &&
                        ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                          status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE );
    }

    public static Boolean isSendForCZScopingReviewButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) &&
                    ( /*status == ProposalServices.PROPOSAL_STATUS_NEW ||*/
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                      status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED );
    }

    public static Boolean isSendToClientButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) &&
                    ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                      status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                      status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                      status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                      status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED );
    }

    public static Boolean isReSendToClientButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return isPsIrAdmin( profileName, roleName, isCreator ) &&
                    ( status == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                       status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT );
    }

    public static Boolean isFollowUpButtonVisible( String status, String profileName, String roleName, Boolean isCreator ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6625
                 profileName == UserServices.PROFILE_ACCOUNT_MANAGER ||
                 profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ) &&
                  ( status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT );
    }

    public static Boolean isSendForInternalReviewButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Boolean needsInternalReview ) {
        return //needsInternalReview &&
                   isPsIrAdmin( profileName, roleName, isCreator ) &&
                        ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                          status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                          status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                          status == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                          status == ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED );
    }

    public static Boolean isSaveDraftButtonVisible( String status, String profileName, String roleName, Boolean isCreator, Id proposalId, Boolean isDraft, Boolean isMi3 ) {
        return ( String.isBlank(proposalId) || isDraft ) &&
                 ( profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR ) || //for saving the Display Text on Invoice
                 ( ( isPsIrAdmin( profileName, roleName, isCreator ) &&
                     ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                       status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ) ||
                 ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                     ( status == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ||
                 ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                     profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                     ( isMi3 ) &&
                     ( status == ProposalServices.PROPOSAL_STATUS_NEW ) ) );
    }

    /* Start Fields Visibility and Availability Methods */
    public static Boolean isVisibleForSIPS( Boolean isSIPSUser, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus ){
        return ( isSIPSUser &&
                 ( ( proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW &&
                     ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                       ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||
                   ( proposalStatus == ProposalServices.PROPOSAL_STATUS_AWARDED &&
                     changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW &&
                     isChangeOrder && changeOrderId InstanceOf Id )
                 )
               );
    }

    public static Boolean isEditableForSIPS( Boolean isSIPSUser, Boolean isSIPSService, String proposalStatus, String serviceStatus, String changeOrderStatus, Boolean isChangeOrder, String changeOrderId,
                                             Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ){
        return ( isSIPSUser &&
                 ( isSIPSService &&
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus != ProposalServices.PROPOSAL_STATUS_AWARDED && serviceStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) || // MRS 7197
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && serviceStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ||
                 ( isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && serviceStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) );
    }

    public static Boolean isServiceGroupRequired( Boolean isSIPSService, Boolean isSIPSUser, String proposalStatus, Boolean isChangeOrder, String changeOrderId ) {
        return  !isSIPSService ||
                ( isSIPSUser &&
                  ( proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ||
                    isChangeOrder && ( changeOrderId InstanceOf Id ) )  ) ||
                proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW;
    }

    public static Boolean isPhasesVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                           Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                           Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( ( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||

                // SIPS User
                isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) );
    }

    public static Boolean isPhasesEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                            Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                            Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||

               ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                      //no need to check isChangeOrderAllowedOnProjectOrServiceItemLevel since draft is already allowed
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||

                // PS, Partner (owner) and Account Manager (owner) section
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == proposalCreator MRS-6321*/ ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   /*(  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_AWARDED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_AWARDED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED )*/
                   (  isChangeOrder && changeOrderId InstanceOf Id && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) || //MRS-6321
                   (  isChangeOrder && changeOrderId InstanceOf Id && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED )
                 ) ) ||

                // SIPS Manager and Coordinator Section
                isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( //( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

                // C&Z Section
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && isAssignedCZAnalyst ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ) ) ||

               ( (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                 (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                 (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                 (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isFloorsVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                           Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                           Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( ( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( isSIPSUser || profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) );
    }

    public static Boolean isFloorsEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                            Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                            Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                     //no need to check isChangeOrderAllowedOnProjectOrServiceItemLevel since draft is already allowed
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( //( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED && isAssignedCZAnalyst ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

                 // SIPS Manager and Coordinator Section
                 isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isServiceGroupVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6723
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ) ) ) ||
               ( canCreateNewCo &&
                 ( ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ) ) );
    }

    public static Boolean isServiceGroupEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                  Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                  Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED && isAssignedCZAnalyst ) ) ) ||

                 // SIPS Manager and Coordinator Section
                 isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 (  (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( canCreateNewCo &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( isChangeOrderAllowedOnProjectOrServiceItemLevel &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isPurchaseOrderVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                  Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        //MRS-2423 added Proposal Specialist and Staff Accountant
        //MRS-5879 added A/R Coordinator, Accounting Supervisor, Finance Management
        return ( ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                   ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   profileName.contains(UserServices.PROFILE_STAFF_ACCOUNTANT) ||
                   profileName.contains(UserServices.PROFILE_A_R_CORDINATOR) ||
                   profileName.contains(UserServices.PROFILE_ACCOUNTING_SUPERVISOR) ||
                   profileName.contains(UserServices.PROFILE_FINANCE_MANAGER)) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ) ) ||
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ) );
    }

    public static Boolean isPurchaseOrderEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isMunicipalAgencyVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                    Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                    Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean isFromChangeOrderRequestButton ) {
        return ( isFromChangeOrderRequestButton ) ||
               ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6723
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) );
    }

    public static Boolean isMunicipalAgencyEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                     Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                     Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED && isAssignedCZAnalyst ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

                 // SIPS Manager and Coordinator Section
                 isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isUnitOfServiceVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                  Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                  Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( ( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) );
    }

    public static Boolean isQuantityVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                             Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                             Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 ( ( changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) );
    }

    public static Boolean isQuantityEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                              Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                              Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && //MRS-6723
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   //no need to check isChangeOrderAllowedOnProjectOrServiceItemLevel since draft is already allowed
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   ( userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED && isAssignedCZAnalyst ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               // SIPS Manager and Coordinator Section
               isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               //MRS-6723
               ( ( profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&
                 (  (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isUnitPriceRequired( String profileName, String roleName, Boolean isMi3, Boolean isSIPSUser, Boolean isSIPSService ) {
        return ( ( isMi3 == true ) ||
                 ( isSIPSUser == true ) ||
                 ( isSIPSUser == false && isSIPSService == false ) ||
                 ( !( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ) );
    }

    public static Boolean isUnitPriceVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                              Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                              Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) || profileName == UserServices.PROFILE_ACCOUNT_MANAGER ) || //MRS-6285
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( profileName == UserServices.PROFILE_PARTNER ) || //MRS-7023
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isUnitPriceEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                               Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                               Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ( canCreateNewCo ) && //MRS-6780
                 ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus != ProposalServices.PROPOSAL_STATUS_AWARDED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) || // MRS 7197
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus != ProposalServices.PROPOSAL_STATUS_AWARDED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) || // MRS 7197
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( /*isChangeOrder || (!isChangeOrder &&*/ userId == internalReviewer /*)*/ ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrderAllowedOnProjectOrServiceItemLevel && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               // SIPS Manager and Coordinator Section
               isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isLastPriceVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                              Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                              Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) || profileName == UserServices.PROFILE_ACCOUNT_MANAGER ) || //MRS-6285
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( profileName == UserServices.PROFILE_PARTNER ) || //MRS-7023
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isTotalPriceVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                               Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                               Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) || profileName == UserServices.PROFILE_ACCOUNT_MANAGER ) || //MRS-6285
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( profileName == UserServices.PROFILE_PARTNER ) || //MRS-7023
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||
               ( ( profileName.contains(UserServices.PROFILE_STAFF_ACCOUNTANT) || profileName.contains(UserServices.PROFILE_A_R_CORDINATOR) || profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                     ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                     (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                     (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isActivityStatusVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                   Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6723
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) );
    }

    // MRS 6931
    public static Boolean isMovableVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                           Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                           Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( canCreateNewCo ||
                   isChangeOrderAllowedOnProjectOrServiceItemLevel ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && //MRS-6681, MRS-6570
                 ( ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isRemoveVisible( String profileName, String roleName, String proposalStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                           Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                           Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && ( changeOrderId InstanceOf Id ) ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, proposalStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && proposalStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( canCreateNewCo ||
                   isChangeOrderAllowedOnProjectOrServiceItemLevel ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && //MRS-6681, MRS-6570
                 ( ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                   ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   proposalStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }

    public static Boolean isRemoveEditable( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                            Id proposalCreator, String smStatus, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                            Boolean isSIPSUser, Boolean isSIPSService, Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               ( isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   ( userId == proposalCreator ) || //MRS-4313
                   ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED && isAssignedCZAnalyst ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||

               // SIPS Manager and Coordinator Section
               isEditableForSIPS( isSIPSUser, isSIPSService, pStatus, smStatus, changeOrderStatus, isChangeOrder, changeOrderId, isChangeOrderAllowedOnProjectOrServiceItemLevel ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && ( userId == internalReviewer ) ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) ) || //this enables deletion from original/approved services for ir; it is then blocked on CO level if current co ir != current user
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_INACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ) ||


               ( ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ||
                 ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                 ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_APPROVED && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ||
                 ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_ACTIVE ) ||
                 ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && smStatus == ServiceItemServices.SERVICE_STATUS_NOTSTARTED ) ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) );
    }
    /* End Fields Visibility and Availability Methods */

    /* Start Buttons Visibility and Availability Methods */
    public static Boolean showMoveServices( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer, Id proposalCreator,
                                            Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                            Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 isPsExAdmOmLiCzAdmin( profileName, roleName ) ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == proposalCreator MRS-6321*/ ) ||
                 profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6723
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                 isChangeOrderAllowedOnProjectOrServiceItemLevel );
    }

    public static Boolean showSaveServiceBundle( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == proposalCreator*/ ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == internalReviewer*/ ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean enableSaveServiceBundle( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == proposalCreator*/ ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) /*&& userId == internalReviewer*/ ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean showAddNewService( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                             Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                             Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean enableAddNewService( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                               Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                               Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                   profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) && //MRS-6570
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && isAssignedCZAnalyst ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean showInsertServiceBundle( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                   Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) &&
                 ( ( isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||
               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&//MRS-6570
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean enableInsertServiceBundle( String profileName, String roleName, String pStatus, Boolean isChangeOrder, String changeOrderId, String changeOrderStatus, Id userId, Id internalReviewer,
                                                     Id proposalCreator, Boolean isMi3, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst, Boolean isSIPSUser,
                                                     Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner || profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER ) &&//MRS-6570
                 ( (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ) ||
               ( ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                   ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ) ||
                   ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_REJECTED ) ) ) ||
               ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW && isAssignedCZAnalyst ) ) ) ||

               // SIPS User
               isVisibleForSIPS( isSIPSUser, pStatus, isChangeOrder, changeOrderId, changeOrderStatus ) ||

               ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                   profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( ( !isChangeOrder && changeOrderId == ChangeOrderServices.ORIGINAL_CHANGE_ORDER && pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ||
                   (  isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ) ) ) ||
               ( ( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ||
                   profileName == UserServices.PROFILE_PROJECT_MANAGER_1 ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                 ( isMi3 &&
                   pStatus == ProposalServices.PROPOSAL_STATUS_NEW ) ) ||
               ( ( isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
                 ( isChangeOrder && changeOrderId InstanceOf Id && changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) );
    }

    public static Boolean showRemoveChangeOrder( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-6619
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT );
    }

    public static Boolean enableRemoveChangeOrder( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                   Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-6619
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT );
    }

    public static Boolean showCancelCORequest( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer, Id proposalCreator,
                                               Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                               Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-6619
				 profileName.contains(UserServices.PROFILE_OPERATIONS_MANAGER) || //MRS 7301
                 userId == proposalCreator ||
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_DRAFT &&
                 changeOrderStatus != ChangeOrderServices.STATUS_CANCELED );
    }

    public static Boolean enableCancelCORequest( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-6619
				 profileName.contains(UserServices.PROFILE_OPERATIONS_MANAGER) || //MRS 7301
                 userId == proposalCreator ||
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_PENDING_CLIENT );
    }

    public static Boolean showSubmitCORequest( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer, Id proposalCreator,
                                               Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                               Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
				 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-7384
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT );
    }

    public static Boolean enableSubmitCORequest( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst,
                                                 Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel, Boolean canCreateNewCo ) {
        return ( canCreateNewCo && //MRS-6780
                 ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT ) ) ||
               ( ProposalWizardServices.isProjManProdManSscAdmin( profileName, isProductionManager, isSsmOrOmOrSscOwner ) ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER || //MRS-6570
				 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST || //MRS-7384
                 isChangeOrderAllowedOnProjectOrServiceItemLevel ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_DRAFT );
    }

    public static Boolean showSendForCZReview( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                               Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED );
    }

    public static Boolean getShowSendForSIPSCoordinator( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                         Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedSIPS ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) && userId == internalReviewer )) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW );
    }


    public static Boolean enableSendForCZReview( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ||
                 changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ||
                 changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ||
                 changeOrderStatus == ChangeOrderServices.STATUS_REJECTED );
    }

    public static Boolean showComplete( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                        Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW );
    }

    public static Boolean showCompleteSIPS( String changeOrderStatus, Boolean isAssignedSIPS ) {
        return isAssignedSIPS && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW;
    }

    public static Boolean enableComplete( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                          Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW ) &&
               ( isAssignedCZAnalyst );
    }

    public static Boolean showSendForInternalReview( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                     Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED );
    }

    public static Boolean enableSendForInternalReview( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                       Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ||
                 changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ||
                 changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ||
                 changeOrderStatus == ChangeOrderServices.STATUS_REJECTED );
    }

    public static Boolean showSendToClient( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                            Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED &&
                 changeOrderStatus != ChangeOrderServices.STATUS_PENDING_CLIENT &&
                 changeOrderStatus != ChangeOrderServices.STATUS_APPROVED );
    }

    public static Boolean enableSendToClient( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                              Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_REQUESTED ||
                 changeOrderStatus == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ||
                 changeOrderStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ||
                 changeOrderStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ||
                 changeOrderStatus == ChangeOrderServices.STATUS_REJECTED );
    }

    public static Boolean showReSendToClient( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                            Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT ||
                 changeOrderStatus == ChangeOrderServices.STATUS_APPROVED );
    }

    public static Boolean enableReSendToClient( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                              Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT ||
                 changeOrderStatus == ChangeOrderServices.STATUS_APPROVED );
    }

    public static Boolean showFollowUp( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                        Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
                 profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6625
                 profileName == UserServices.PROFILE_ACCOUNT_MANAGER ||
                 profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME );
    }

    public static Boolean enableFollowUp( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                          Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT );
    }

    public static Boolean showApproveChangeOrderIR( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                    Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || (profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW) ) 
				&& ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ); //MRS 7507
    }

    public static Boolean enableApproveChangeOrderIR( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                      Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || (profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW)) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ); //MRS 7507
    }

    public static Boolean showRejectChangeOrderIR( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( ( ProposalWizardServices.isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && ( userId == internalReviewer ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || (profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW)) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED ); //MRS 7507
    }

    public static Boolean isCZAssignmentVisible( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                 Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || //MRS-4879, MRS-4434
                 ( changeOrderStatus == ChangeOrderServices.STATUS_IN_CZ_REVIEW &&
                   profileName == UserServices.PROFILE_CODE_ZONING_ANALYST &&
                   ( !String.isBlank( roleName ) && roleName.contains(UserServices.ROLE_CZ_MANAGER) ) ) );
    }

    public static Boolean isSIPSAssignmentVisible( String profileName, Id userId, Id internalReviewer, String changeOrderStatus  ) {
        return ( profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ||
                 ( profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) && internalReviewer == userId ) &&
                 changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW );
    }

    public static Boolean enableRejectChangeOrderIR( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                     Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( ( ProposalWizardServices.isAccManPartner( profileName ) || profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER ) && ( userId == internalReviewer ) ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN || (profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST && changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW)) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_IN_INT_REVIEW ); //MRS 7507
    }

    public static Boolean showApproveChangeOrderPS( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                    Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED );
    }

    public static Boolean enableApproveChangeOrderPS( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                      Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT );
    }

    public static Boolean showRejectChangeOrderPS( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                   Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus != ChangeOrderServices.STATUS_CANCELED );
    }

    public static Boolean enableRejectChangeOrderPS( String profileName, String roleName, String changeOrderStatus, Id userId, Id internalReviewer,
                                                     Id proposalCreator, Boolean isProductionManager, Boolean isSsmOrOmOrSscOwner, Boolean isAssignedCZAnalyst ) {
        return ( ( isPsExAdmOmLiCzAdmin( profileName, roleName ) ) ||
                 ( ProposalWizardServices.isAccManPartner( profileName ) && userId == proposalCreator ) ||
                 profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
               ( changeOrderStatus == ChangeOrderServices.STATUS_PENDING_CLIENT );
    }

    public static Boolean getHasSIPSServices( List<ServiceModel> serviceModels, Boolean isSIPSUser ){
        Boolean hasSIPSService = false;
        for( ServiceModel sMod : serviceModels ){
            if( sMod.getIsSIPSService() ) {
                hasSIPSService = true;
                break;
            }
        }
        return hasSIPSService;
    }
    /* End Buttons Visibility and Availability Methods */

    public static Boolean isScopeOfWorkRequired( Boolean isMi3, DateTime createdDate, Boolean isDraft ) {
        return !isMi3 && isDraft && //MRS 7461
               ( createdDate == null ||
                 ( createdDate != null && createdDate >= ProposalWizardServices.APPLY_SCOPE_OF_WORK_FUNCTIONALITY ) );
    }

    public static Boolean isMi3( Proposal__c proposal ) {
        return !String.isBlank( proposal.Mi3_MRC__c );
    }

    public static Account getBillingAccountForFields( Proposal__c proposal ) {
        List<Account> accountForFields = new List<Account>();
        if( !String.isBlank( proposal.Billing_Company_Name__c ) ) {
            accountForFields = [ SELECT Interval__c, Special_Instructions__c, Special_Instructions_Long__c, Delivery_Method__c, c2g__CODASalesTaxStatus__c, Separate_Reimbursables__c,
                                        Billing_Method__c, Frequency__c, Quarterly_Month__c, Billing_day__c, No_Document_Shredding__c, Invoice_Format__c, No_Messenger_Fedex__c, UseDocusign__c,
                                        No_Met_Data_Scanning__c, No_Retainer__c, PO_Required__c, Retainer__c, No_Reimbursables__c, Reimbursables__c, Account_Manager__c, Salesperson__c,
                                        Mail_All_Invoices_To_Account__c, Mail_All_Invoices_To_Contact__c, Mail_All_Invoices_To_Account__r.Name, Mail_All_Invoices_To_Contact__r.Name,
                                        Mail_All_Invoices_To_Contact__r.AccountId, Mail_All_Invoices_To_Contact__r.Account.Name, Accounting_Hold__c, Send_Copy_To__c, PO_Not_Required__c /*MRS 7191 */
                                 FROM Account WHERE Id = : proposal.Billing_Company_Name__c];
            if( !accountForFields.isEmpty() ) return accountForFields[0];
        }
        return new Account();
    }

    public static Boolean serviceCanBeAddedToPo( ProposalWizardModel pwm, ServiceModel sm ) {
        return !( ( sm.isAlternative ) ||
                  ( pwm.changeOrderModelMap.get( sm.changeOrderId ) != null &&
                    ( ( sm.isAmendmendDeleted && pwm.changeOrderModelMap.get( sm.changeOrderId ).status == ChangeOrderServices.STATUS_APPROVED ) ||
                      ( !sm.isOriginal && !sm.isAmendmendDeleted && pwm.changeOrderModelMap.get( sm.changeOrderId ).status != ChangeOrderServices.STATUS_APPROVED ) ||
                      ( pwm.changeOrderModelMap.get( sm.changeOrderId ).status == ChangeOrderServices.STATUS_CANCELED ) ) ) );
    }

    public static Boolean disableReceivedSignedProposalCheckbox( Proposal__c proposal, Boolean isThisUserCreator, String profileName, String currentUserRoleName ) {
        return !( ( isThisUserCreator ||
                    currentUserRoleName == UserServices.ROLE_LI_CZ_MANAGER ||
                    profileName == UserServices.PROFILE_ACCOUNT_MANAGER ||
                    profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST ||
                    profileName == UserServices.PROFILE_SHARED_SERVICES_MANAGER || //MRS-6625
                    profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ) &&
                      ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED ||
                        proposal.Status__c == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT ) );
    }

    public static Boolean isPreviewPdfDisabled( Proposal__c proposal, Boolean isThisUserCreator, String profileName, Boolean isAdmin, Boolean isPS, Boolean isCZAnalyst ) {
        return !( profileName == UserServices.EXECUTIVE_ADMIN_PROFILE_NAME ||
                  profileName == UserServices.PROFILE_PARTNER ||
                  profileName == UserServices.PROFILE_ACCOUNT_MANAGER ||
                  isAdmin ||
                  ( isThisUserCreator &&
                    ( proposal.Is_Change_Order__c ||
                    ( !proposal.Is_Change_Order__c &&
                      ( ( isPS || proposal.Status__c != ProposalServices.PROPOSAL_STATUS_AWARDED ) && //MRS-6824 enable for PS in Awarded status, disable for other creators
                        proposal.Status__c != ProposalServices.PROPOSAL_STATUS_WITHDRAWN &&
                        proposal.Status__c != ProposalServices.PROPOSAL_STATUS_CANCELLED &&
                        proposal.Status__c != ProposalServices.PROPOSAL_STATUS_EXPIRED &&
                        proposal.Status__c != ProposalServices.PROPOSAL_STATUS_NOT_AWARDED &&
                        !( isPS && isCZAnalyst && proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ) ) ) );
    }

    public static Boolean showAlternativeServicesTable( Proposal__c proposal, ProposalWizardModel pwm, Boolean isThisUserCreator, Boolean isAdmin, Boolean isPartner, Boolean isPS, Boolean isAM, Boolean isCZAnalyst, Boolean isAssignedInternalReviewer, Boolean isPManager1, Boolean isPManager2 ) {
        return ( ( isAssignedInternalReviewer ||
                   isAdmin ||
                   ( isPS && !isCZAnalyst ) ||
                   ( isPS && isCZAnalyst && proposal.Status__c != ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ||
                   ( isThisUserCreator && ( isAM || isPartner ) ) ) &&
                 ( !proposal.is_Change_Order__c ) ) ||
               ( ( isAssignedInternalReviewer ||
                   isAdmin ||
                   isPManager1 ||
                   isPManager2 ) &&
                 ( proposal.is_Change_Order__c && !pwm.alternativeChangeOrders[0].serviceModels.isEmpty() ) );
    }

    public static Boolean enableCreateAutomaticFollowUps( String changeOrderStatus, Boolean disableFollowups ) { //for ChangeOrderModel property
        return enableCreateAutomaticFollowUps( null, null, null, false, true, changeOrderStatus, disableFollowups );
    }

    public static Boolean enableCreateAutomaticFollowUps( Proposal__c proposal, String changeCoStatusCoId, ProposalWizardModel pwm, Boolean takeDisableFollowUpsIntoAccount, Boolean takeOtherStatusesIntoAccount ) {
        return enableCreateAutomaticFollowUps( proposal, changeCoStatusCoId, pwm, takeDisableFollowUpsIntoAccount, takeOtherStatusesIntoAccount, null, null );
    }

    public static Boolean enableCreateAutomaticFollowUps( Proposal__c proposal, String changeCoStatusCoId, ProposalWizardModel pwm, Boolean takeDisableFollowUpsIntoAccount, Boolean takeOtherStatusesIntoAccount, String changeOrderStatus, Boolean isDisableFollowups ) {
        String status = changeOrderStatus != null
                        ? changeOrderStatus
                        : ( String.isBlank( changeCoStatusCoId )
                            ? proposal.Status__c
                            : pwm.changeOrderModelMap.get( changeCoStatusCoId ).status );
        Boolean disableFollowups = isDisableFollowups != null
                                   ? isDisableFollowups
                                   : ( String.isBlank( changeCoStatusCoId )
                                       ? proposal.Disable_Followups__c
                                       : pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Disable_Followups__c );
        return ( String.isBlank( changeCoStatusCoId ) && String.isBlank( changeOrderStatus ) )
               ? ( !disableFollowups || !takeDisableFollowUpsIntoAccount ) &&
                   ( status == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT ||
                     ( takeOtherStatusesIntoAccount &&
                       ( status == ProposalServices.PROPOSAL_STATUS_NEW ||
                         status == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                         status == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                         status == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                         status == ProposalServices.PROPOSAL_STATUS_REJECTED ) ) )
               : ( !disableFollowups || !takeDisableFollowUpsIntoAccount ) &&
                   ( status == ChangeOrderServices.STATUS_PENDING_CLIENT ||
                     ( takeOtherStatusesIntoAccount &&
                       ( status == ChangeOrderServices.STATUS_REQUESTED ||
                         status == ChangeOrderServices.STATUS_CZ_REVIEW_COMPLETE ||
                         status == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ||
                         status == ChangeOrderServices.STATUS_FAILED_INT_REVIEW ||
                         status == ChangeOrderServices.STATUS_REJECTED ) ) );
    }

    public static Boolean isUseDocusignEditable( String profileName, String roleName, String pStatus, Id userId, Id internalReviewer, Boolean isCreator, Boolean hasPendingChangeOrders ) {
        return /*!hasPendingChangeOrders &&*/
               ( ( ( isPsIrAdmin( profileName, roleName, isCreator ) ) &&
                   ( pStatus == ProposalServices.PROPOSAL_STATUS_NEW ||
                     pStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE ||
                     pStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ||
                     pStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ||
                     pStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                     pStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) ) ||
                 ( ( profileName == UserServices.PROFILE_CODE_ZONING_ANALYST ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   ( pStatus == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) ) ||
                 ( ( ( ProposalWizardServices.isAccManPartner( profileName ) && userId == internalReviewer ) ||
                     profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN ) &&
                   ( pStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) ) );
    }

	public static void sendEmailNotificationToInternalReviewer(Proposal__c proposal, Change_Order__c co, Id internalReviewer) { //MRS 7507
		String action = '';
		if(co == null) {
			action = proposal.Status__c == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ? 'approved' : 'rejected';
		} else {
			action = co.Status__c == ChangeOrderServices.STATUS_PASSED_INT_REVIEW ? 'approved' : 'rejected';
		}
		if(internalReviewer != null) {
			EmailMessageService.sendMassMailToInternalUsers(new Set<Id> { internalReviewer }, 
							'<html>' + UserInfo.getName() + ' has ' + action + ' <a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/'
							+ (String.valueOf(co != null ? co.Id : proposal.Id)) + '">' + (co != null ? co.Name : proposal.Name) + '</a>.</html>',
							(co != null ? co.Name : proposal.Name) + ' has been ' + action);
		}
    }

}