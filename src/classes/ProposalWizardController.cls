public without sharing class ProposalWizardController {
    public Proposal__c proposal { get; set; }
    public ProposalWizardModel pwm { get; set; }
    public ProposalWizardRoster pwr { get; set; }

    public ProposalWizardController( ApexPages.StandardController controller ) {
        proposal = ProposalWizardServices.getProposal( ((Proposal__c)controller.getRecord()).Id );
        activeChangeOrderId = ApexPages.currentPage().getParameters().get('co');
        String proposalStep = ApexPages.currentPage().getParameters().get('step');
        String opportunityId = ApexPages.currentPage().getParameters().get('opportunity'); // MRS 6648
        if(!String.isBlank(opportunityId)) populateProposalWitOpportunityValues(opportunityId);
        if( !String.isBlank(proposalStep) && proposalStep.isNumeric() && Integer.valueOf(proposalStep) <= 4 && Integer.valueOf(proposalStep) >= 1 ) {
            proposal.Step__c = Integer.valueOf(proposalStep);
        }

        setFormPosition();

        assignedProjectTeam = ProjectTeamServices.getProjectTeam( proposal.Project_Team__c, new List<String>{ ProjectTeamServices.PRODUCTION_MANAGER_FIELD, ProjectTeamServices.NEW_BUILDING_FIELD } );
        pwm = new ProposalWizardModel( proposal, assignedProjectTeam, profileName, currentUserRoleName );

        if( proposal.Send_Reminder_To_Creator__c == null ) {
            proposal.Send_Reminder_To_Creator__c = proposal.Proposal_Send_Reminder__c;
        }
        building = ProposalWizardServices.getBuildingById( proposal.Address__c );
        if( building != null && !String.isEmpty( proposal.Id ) ) {
            proposal.is_Landmark__c = building.is_Landmark__c;
            proposal.is_MTA__c = building.is_MTA__c;
        }

        recalculateFrequencyAndBillingDay();

        populateServiceModels(true);
        updateReimbursableAndDiscountData();
        pwm.canCreateNewCo = canCreateNewCo();

        rightPanelView = 'Notes';

        isDisableDocumentsCheckbox();
        if( !String.isEmpty( proposal.Id ) ) {
            if( proposal.Provided_Documents__c ) {
                currentStorageFolder = StoredDocumentServices.DOCUMENTS_FILE_TYPE;
                manageFileUpload(false);
            }
            if( proposal.Provided_Drawings__c) {
                currentStorageFolder = StoredDocumentServices.DRAWINGS_FILE_TYPE;
                manageFileUpload(false);
            }
        }
        createDeleteAdditionalDocumentsFolder( false );
        if( getPhaseList().size() > 1 ) proposal.isPhase__c = true;

        pwm.populateDocumentWrapperList( proposal );

        pwr = new ProposalWizardRoster( proposal, pwm );
        pwm.updateServiceClientPrices( proposal.Billing_Company_Name__c );

        // MRS-6966
        if( proposal.Project_Team__c != null ) projectTeamId = proposal.Project_Team__c;
        if( proposal.Production_Manager__c != null ) productionManagerId = proposal.Production_Manager__c;
        if( proposal.FREP__c != null ) frepId = proposal.FREP__c;

        if(!String.isBlank(opportunityId) && !String.isBlank(proposal.Billing_Company_Name__c)) billingCompanyAction(); // MRS 7316
    }

        // MRS 6648
        public String proposalCreator {
                get {
                        if(!String.isBlank(proposal.OwnerId)) {
                                return UserServices.getUserById(proposal.OwnerId).Name;
                        } else {
                                return '';
                        }
                }
                set;
        }

        public void populateProposalWitOpportunityValues(String opportunityId) {
                Opportunity opp = [SELECT Id, Building__c, Partner__c, Salesperson__c, Account_Manager__c, Proposal_Specialist__c, Proposal_Type__c,Client_Project__c,
                                                                  Expected_Construction_Start__c, Expected_Construction_Cost__c, Scope_of_Work__c, Primary_Company__c, Primary_Company_Contact__c,
                                                                  Billing_Client_Co__c, Billing_Contact__c, Accounting_Contact_Company__c, Accounting_Contact__c FROM Opportunity WHERE Id = :opportunityId];
                proposal.Opportunity__c = opp.Id;
                proposal.Address__c = opp.Building__c;
                proposal.Partner__c = opp.Partner__c;
                proposal.Salesperson__c = opp.Salesperson__c;
                proposal.Account_Executive__c = opp.Account_Manager__c;
                if(opp.Proposal_Specialist__c != null) proposal.OwnerId = opp.Proposal_Specialist__c;
                proposal.Proposal_Specialist__c = opp.Proposal_Specialist__c;
                proposal.Proposal_Type__c = opp.Proposal_Type__c;
                proposal.Client_Project__c = opp.Client_Project__c;
                proposal.Expected_Construction_Start_Date__c = opp.Expected_Construction_Start__c;
                proposal.Expected_Construction_Cost__c = opp.Expected_Construction_Cost__c;
				proposal.Is_Draft__c = true; //MRS 7461
                if(!String.isBlank(opp.Scope_of_Work__c)) { //MRS 7480
					proposal.Description__c = opp.Scope_of_Work__c.replaceAll('<br>','\r\n').replaceAll('<[^>]+>',' ');
				}
                proposal.Primary_Company_Name__c = opp.Primary_Company__c;
                if(!String.isBlank(proposal.Primary_Company_Name__c)) {
                        for(Contact c : [SELECT Id FROM Contact WHERE AccountId =: proposal.Primary_Company_Name__c]) {
                                if(c.Id == opp.Primary_Company_Contact__c) {
                                        proposal.Primary_Company_Contact__c = opp.Primary_Company_Contact__c;
                                        break;
                                }
                        }
                }
                proposal.Billing_Company_Name__c = opp.Billing_Client_Co__c;
                if(!String.isBlank(proposal.Billing_Company_Name__c)) {
                        for(Contact c : [SELECT Id FROM Contact WHERE AccountId =: proposal.Billing_Company_Name__c]) {
                                if(c.Id == opp.Billing_Contact__c) {
                                        proposal.Billing_Company_Contact__c = opp.Billing_Contact__c;
                                        break;
                                }
                        }
                }
                if(!String.isBlank(opp.Accounting_Contact_Company__c)) {
                        proposal.Accounting_Contact_Company__c = opp.Accounting_Contact_Company__c;
                        proposal.Send_Invoices_to_Different_Contact__c = true;
                        for(Contact c : [SELECT Id FROM Contact WHERE AccountId =: opp.Accounting_Contact_Company__c]) {
                                if(c.Id == opp.Accounting_Contact__c) {
                                        proposal.Accounting_Contact__c = opp.Accounting_Contact__c;
                                        break;
                                }
                        }
                }
                if(!String.isBlank(proposal.Billing_Company_Name__c) && !String.isBlank(proposal.Billing_Company_Contact__c)
                        && proposal.Primary_Company_Name__c == proposal.Billing_Company_Name__c
                        && proposal.Primary_Company_Contact__c == proposal.Billing_Company_Contact__c) {
                        proposal.Primary_Client_is_Billing_Client__c = true;
                }
        }

    public transient String opportunityNumber; //MRS 7307
    public String getOpportunityNumber() {
        String res = '';
        if(proposal.Opportunity__c != null) res =' #' + [SELECT Opportunity_Number__c FROM Opportunity WHERE Id = :proposal.Opportunity__c].Opportunity_Number__c;
        return res;
    }

    @RemoteAction
    public static String retriveSelectedOpportunityNumber(String oppId) {
        return [SELECT Opportunity_Number__c FROM Opportunity WHERE Id = :oppId].Opportunity_Number__c;
    }

    // MRS-6966
    private String projectTeamId;
    private String productionManagerId;
    private String frepId;

    public transient Boolean isOptimalView; //MRS 7280 MRS 7357
    public Boolean getIsOptimalView() {
        return proposal.Percents_View_State__c > proposal.optView_Percents_Limit__c;
    }

    public PageReference saveProposalAndSetOptViewMode() {
        PreventTwiceExecution.proposalFirstRun = false;
        if(!proposal.optView_Hide_Canceled_Change_Orders__c && !proposal.optView_Hide_Completed_Services__c && !proposal.optView_Hide_Inactive_Services__c ) {
            proposal.Percents_View_State__c = null;
        }
        Proposal__c prop = new Proposal__c(Id = proposal.Id, Percents_View_State__c = proposal.Percents_View_State__c, optView_Hide_Canceled_Change_Orders__c = proposal.optView_Hide_Canceled_Change_Orders__c, 
                                        optView_Hide_Completed_Services__c = proposal.optView_Hide_Completed_Services__c, optView_Hide_Inactive_Services__c = proposal.optView_Hide_Inactive_Services__c);
        UPSERT prop;
        PageReference pr = new PageReference('/apex/ProposalWizard');
        pr.getParameters().put('id', proposal.Id);
        pr.getParameters().put('step', currentStep);
        pr.setRedirect(true);
        return pr;
    }

    private String dateStampBasic() {
        return Datetime.now().format('\' - \'MM/dd/yyyy hh:mm:ss\' - \'') + 'basic instructions';
    }

    public Integer formPosition { get { if( formPosition == null ) formPosition = 0; return formPosition; } set { try { formPosition = Integer.valueOf( value ); } catch( exception e ) {} } }
    public void setFormPosition() {
        try {
            formPosition = Integer.valueOf( ApexPages.currentPage().getParameters().get('scroll') );
        } catch( Exception e ) {
            formPosition = 0;
        }
    }

        public boolean eSignatureAndNoSigners {
                set;
                get { // MRS 7180
                        Boolean hasSigner = false;
                        for(ProposalWizardRosterWrapper pwrItem : pwr.rosters) {
                                if(pwrItem.record.To__c) {
                                        hasSigner = true;
                                        break;
                                }
                        }
                        return proposal.UseDocusign__c && !hasSigner;
                }
        }


    public String changeCOStatusOldStatus;

    public void approveChangeOrderBeforeRedirectBillingTriggers() { // MRS 7229
        String action = ApexPages.currentPage().getParameters().get('action');
        String dataFileId = ApexPages.currentPage().getParameters().get('data');
        String changeOrderId = ApexPages.currentPage().getParameters().get('co');
        if( !String.isBlank( action ) && action == ProposalWizardServices.CHANGE_ORDER_APPROVE_ACTION ) {
            if( !String.isEmpty( changeOrderId ) && !String.isEmpty( dataFileId ) && ( changeOrderId instanceOf Id ) && ( dataFileId instanceOf Id ) ) {
                for( ChangeOrderModel coModelItem : pwm.approvedChangeOrders ) {
                    if( coModelItem.changeOrderRecord.Id == changeOrderId ) {
                        addMessage( 'This Change Order has been already approved.' );
                        return;
                    }
                }
                Boolean found = false;
                for( ChangeOrderModel coModelItem : pwm.notApprovedChangeOrders ) {
                    if( coModelItem.changeOrderRecord.Id == changeOrderId ) {
                        changeCOStatusOldStatus = coModelItem.status;
                        found = true;
                                                break;
                    }
                }
                if( found == false ) {
                    addMessage( 'Can not find the requested Change Order.' );
                        return;
                }
                changeCoStatusCoId = changeOrderId;
                changeCoStatusNewStatus = ChangeOrderServices.STATUS_APPROVED;
                changeCOStatus( false );
            }
        }
    }

    public PageReference redirectBillingTriggers() { // MRS 7229
                String changeOrderId = ApexPages.currentPage().getParameters().get('co');
        String proposalId = ApexPages.currentPage().getParameters().get('id');
        String dataFileId = ApexPages.currentPage().getParameters().get('data');
        Savepoint sp_redirectTriggers = Database.setSavePoint();
        try {
            if( !ApexPages.hasMessages() ) {
                ProposalWizardServices.redirectBillingTriggers( dataFileId, changeCoStatusCoId );
                                changeCoStatusCoId = null;
                    changeCoStatusNewStatus = null;
                    changeCOStatusOldStatus = null;
                PageReference pr = new PageReference( '/apex/ProposalWizard' );
                pr.getParameters().put( 'id', proposalId );
                pr.getParameters().put( 'co', changeOrderId );
                pr.getParameters().put( 'step', '3' );
                pr.setRedirect(true);
                return pr;
            } else {
                throw new ErrorException( 'Unable to redirect Billing Triggers.' );
            }
        } catch( Exception e ) {
            addMessage( 'An error occurred while redirecting Billing Triggers: ' + e.getMessage() );
            Database.rollback( sp_redirectTriggers );
            for( ChangeOrderModel coModelItem : pwm.notApprovedChangeOrders ) {
                if( coModelItem.changeOrderRecord.Id == changeCoStatusCoId ) {
                    coModelItem.status = changeCOStatusOldStatus;
                }
            }
            changeCoStatusCoId = null;
            changeCoStatusNewStatus = null;
            changeCOStatusOldStatus = null;
            return null;
        }
    }

    public void addErrorMessageRedirectTriggers() {
        addMessage( 'Error retrieving new tasks or the maximum wait period has reached.' );
    }

    @RemoteAction
    public static Boolean checkNewTasksExistance( String coId ) {
        Map<Id, Service_Item__c> si = new Map<Id, Service_Item__c>( [ SELECT Id
                                                                      FROM Service_Item__c
                                                                      WHERE Change_Order__c = : coId
                                                                        AND Is_Amendmend_Deleted__c = false
                                                                        AND ( Quantity_Old__c = 0 OR Quantity_Old__c = null ) ] );
        if( !si.keySet().isEmpty() &&
            [ SELECT Count() FROM Task_Item__c WHERE Service_Item__c IN : si.keySet() ] == 0 ) {
            return false;
        }
        return true;
    }

	public void populateMapIdToTotalsForHiddenCOandServices() { //MRS 7560
		if(pwm.optViewIdToTotalsMap == null) {
			pwm.optViewIdToTotalsMap = new Map<String, Map<String, Decimal>> {  ChangeOrderServices.SERVICES_SUBTOTAL_TITLE => new Map<String, Decimal>(),
																				ChangeOrderServices.SERVICES_DISCOUNT_TITLE => new Map<String, Decimal>() ,
																				ChangeOrderServices.SERVICES_SALES_TAX_TITLE => new Map<String, Decimal>() ,
																				ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE => new Map<String, Decimal>() ,
																				ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE => new Map<String, Decimal>() };
			for(Map<String, Decimal> idToTotalMap : pwm.optViewIdToTotalsMap.values()) {
				idToTotalMap.put('Original', 0.00);
			}
			
			if(proposal.optView_Hide_Canceled_Change_Orders__c || proposal.optView_Hide_Completed_Services__c || proposal.optView_Hide_Inactive_Services__c) {
				String proposalId = proposal.Id;
				Boolean isConditionAdded = false;
				String request = 'SELECT Id, Original__c, Is_Amendmend_Deleted__c, Quantity__c, Unit_Price__c, Change_Order__r.Status__c, Is_Alternative__c, Tax_Percent_1__c, Tax_Percent_2__c, Discount_Percentage__c,'
								+ ' Change_Order__r.Apply_Reimbursable__c, Change_Order__r.Reimbursable_Percentage__c, Proposal__r.Reimbursable_Items_Basis__c, Proposal__r.Reimbursable_Percentage__c'
								+ ' FROM Service_Item__c'
								+ ' WHERE (( Is_Alternative__c = false AND Phase__r.Proposal__c = ' + '\'' + proposalId + '\') OR ( Is_Alternative__c = true AND Proposal__c = ' + '\'' + proposalId + '\'))';
				if(proposal.optView_Hide_Canceled_Change_Orders__c) {
					request += ' AND (';
					request += ' Change_Order__r.Status__c = \'Canceled\'';
					isConditionAdded = true;
				}
				if(proposal.optView_Hide_Completed_Services__c) {
					request += isConditionAdded ? ' OR' :' AND (';
					request += ' Status__c = \'Completed\'';
					isConditionAdded = true;
				}
				if(proposal.optView_Hide_Inactive_Services__c) {
					request += isConditionAdded ? ' OR' :' AND (';
					request += ' Status__c = \'Inactive\'';
					isConditionAdded = true;
				}
				if(isConditionAdded) request += ')';
				List<Service_Item__c> hiddenServiceItems = Database.query(request);

				Map<String, List<Service_Item__c>> coIdToSitemsList = new Map<String, List<Service_Item__c>> (); 

				if(hiddenServiceItems != null) {
					for(Service_Item__c si : hiddenServiceItems) {
						if(si.Original__c || (si.Change_Order__r.Status__c == ChangeOrderServices.STATUS_APPROVED)) {
							if(coIdToSitemsList.get('Original') == null) coIdToSitemsList.put('Original', new List<Service_Item__c>());
							coIdToSitemsList.get('Original').add(si);
						}
						if(si.Change_Order__c != null) {
							if(coIdToSitemsList.get(si.Change_Order__c) == null) coIdToSitemsList.put(si.Change_Order__c, new List<Service_Item__c>());
							coIdToSitemsList.get(si.Change_Order__c).add(si);
						}
					}
					for(String idx : coIdToSitemsList.keySet()) {
						pwm.optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE).put(idx, ChangeOrderServices.getServicesTotalFromItems(coIdToSitemsList.get(idx), ChangeOrderServices.SERVICES_SUBTOTAL_TITLE));
						pwm.optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_DISCOUNT_TITLE).put(idx, ChangeOrderServices.getServicesTotalFromItems(coIdToSitemsList.get(idx), ChangeOrderServices.SERVICES_DISCOUNT_TITLE));
						pwm.optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_SALES_TAX_TITLE).put(idx, ChangeOrderServices.getServicesTotalFromItems(coIdToSitemsList.get(idx), ChangeOrderServices.SERVICES_SALES_TAX_TITLE));
						pwm.optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE).put(idx, ChangeOrderServices.getServicesTotalFromItems(coIdToSitemsList.get(idx), ChangeOrderServices.SERVICES_REIMBURSABLE_COSTS_TITLE));
						pwm.optViewIdToTotalsMap.get(ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE).put(idx, ChangeOrderServices.getServicesTotalFromItems(coIdToSitemsList.get(idx), ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE));
					}
				}
			}
		}
	}

    private void populateServiceModels( Boolean onlyAddItems ) {
        Map<Id, ServiceModel> serviceModels = pwm.serviceModels;
        if( !onlyAddItems || serviceModels == null ) {
            serviceModels = new Map<Id, ServiceModel>();
        }
        if( !String.isBlank( proposal.Billing_Company_Name__c ) || ( String.isBlank( proposal.Billing_Company_Name__c ) && getIsMi3() ) ) {
            if( !String.isBlank( proposal.Id ) ) {
                Map<Id, Service_Item__c> serviceItemIdToServiceItem = ProposalWizardServices.getServiceItemsMap(proposal); //MRS 7280
				if(getIsOptimalView()) { //MRS 7560
					populateMapIdToTotalsForHiddenCOandServices();
				}
                if( !serviceItemIdToServiceItem.isEmpty() ) {
                    List<Id> serviceTemplateIdsInServiceItems = new List<Id>();
                    for( Service_Item__c serviceItem : serviceItemIdToServiceItem.values() ) {
                        serviceTemplateIdsInServiceItems.add( serviceItem.Service_Template__c);
                    }
                    Map<Id, Service_Template__c> serviceTemplateIdToServiceTemplate = ProposalWizardServices.getServiceTemplatesMap( serviceTemplateIdsInServiceItems );
                    Map<Id, Client_Price__c> serviceIdToClientPrice = ProposalWizardServices.getServiceIdToClientPrice( serviceTemplateIdToServiceTemplate.keySet(), proposal.Billing_Company_Name__c );
                    Map<Id, Last_Proposal_Price__c> serviceIdToLastProposalPrice = ProposalWizardServices.getServiceIdToLastProposalPrice( serviceTemplateIdToServiceTemplate.keySet(), proposal.Billing_Company_Name__c );
                    for(Service_Item__c serviceItem : serviceItemIdToServiceItem.values()) {
                        if(isBillingCompanyFreeOfTax) { // MRS 7141
                            serviceItem.Tax_Code_1__c = null;
                            serviceItem.Tax_Code_2__c = null;
                        } else {
                            serviceItem.Tax_Code_1__c = serviceItem.Service_Template__r.Tax_Code_1__c;
                            serviceItem.Tax_Code_2__c = serviceItem.Service_Template__r.Tax_Code_2__c;
                        }
                    }
                                        ServiceItemServices.serviceItemTaxCode(serviceItemIdToServiceItem.values(), false);
                                        for( Service_Item__c serviceItem : serviceItemIdToServiceItem.values() ) {
                        if( !onlyAddItems || ( onlyAddItems && !serviceModels.containsKey( serviceItem.Id ) ) ) {
                            serviceModels.put( serviceItem.Id, new ServiceModel( serviceItem,
                                                                                 serviceTemplateIdToServiceTemplate.get( serviceItem.Service_Template__c ),
                                                                                 serviceIdToClientPrice.get( serviceItem.Service_Template__c ),
                                                                                 serviceIdToLastProposalPrice.get( serviceItem.Service_Template__c ) ) );
                        }
                    }
                }
            }
        }
        pwm.serviceModels = serviceModels;
        pwm.updateIsChangeOrderAllowedOnProjectOrServiceItemLevel( getIsChangeOrderAllowedOnProjectOrServiceItemLevel() );
    }

    public transient String userName;
    public String getUserName() {
        return Userinfo.getName();
    }
    public void setUserName( String incomingUserName ) {}

    public transient String building_AKA_Id;
    public String getBuilding_AKA_Id() {
        return String.isBlank( proposal.Building_AKA__c ) ? '' : proposal.Building_AKA__c;
    }
    public void setBuilding_AKA_Id( String buildingAkaId ) {
        if( !String.isBlank( buildingAkaId ) && buildingAkaId instanceOf Id ) {
            proposal.Building_AKA__c = buildingAkaId;
        }
    }

    public transient Account billingAccount;
    public Account getBillingAccount() {
        return ProposalWizardServices.getBillingAccountForFields( proposal );
    }

    public transient List<SelectOption> buildingAKAs;
    public List<SelectOption> getBuildingAKAs() {
        return BuildingServices.getBuildinOptionsByBuildingId(this.proposal.Address__c);
    }

    private Map<String, Map<String, String>> usersByProfilesMap {
        get {
            if( usersByProfilesMap == null ) {
                Map<String, Map<String, String>> usersByProfilesMaps = ProposalWizardServices.getUserByProfileMap( new Set<String> { UserServices.PROFILE_PARTNER,
                                                                                                                                     UserServices.PROFILE_ACCOUNT_MANAGER,
                                                                                                                                     UserServices.PROFILE_CODE_ZONING_ANALYST,
                                                                                                                                     UserServices.PROFILE_SIPS_COORDINATOR } );

                Map<String, String> salesPersons = new Map<String, String>();
                salesPersons.putAll( usersByProfilesMaps.get( UserServices.PROFILE_ACCOUNT_MANAGER ) );

                Set<String> additionalUserNames = new Set<String>();
                additionalUserNames.addAll( ProposalWizardServices.getUserNamesForAccountManagerDropdown() );
                additionalUserNames.addAll( ProposalWizardServices.getUserNamesForSalespersonDropdown() );
                additionalUserNames.addAll( ProposalWizardServices.getUserNamesForPartnerDropdown() );

                Map<String, String> additionalAccountManagers = usersByProfilesMaps.get( UserServices.PROFILE_ACCOUNT_MANAGER );
                Map<String, String> additionalPartners = usersByProfilesMaps.get( UserServices.PROFILE_PARTNER );
                for( User userItem : [ SELECT Id, Name FROM User WHERE Name IN : additionalUserNames AND IsActive = true ORDER BY Name ] ) {
                    if( ProposalWizardServices.getUserNamesForAccountManagerDropdown().contains( userItem.Name ) ) {
                        additionalAccountManagers.put( userItem.Id, userItem.Name );
                    }
                    if( ProposalWizardServices.getUserNamesForSalespersonDropdown().contains( userItem.Name ) ) {
                        salesPersons.put( userItem.Id, userItem.Name );
                    }
                    if( ProposalWizardServices.getUserNamesForPartnerDropdown().contains( userItem.Name ) ) {
                        additionalPartners.put( userItem.Id, userItem.Name );
                    }
                }
                usersByProfilesMaps.put( UserServices.PROFILE_ACCOUNT_MANAGER, additionalAccountManagers );
                usersByProfilesMaps.put( UserServices.PROFILE_PARTNER, additionalPartners );
                usersByProfilesMaps.put( ProposalWizardServices.SALES_PERSON_KEYWORD, salesPersons );


                usersByProfilesMap = usersByProfilesMaps;
            }
            return usersByProfilesMap;
        } set;
    }


    public transient List<SelectOption> primaryContacts;
    public List<SelectOption> getPrimaryContacts() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getAccountIdToContactIdToContactName( new Set<String>{ proposal.Primary_Company_Name__c } ).get( proposal.Primary_Company_Name__c ), true, true );
    }

    public transient List<SelectOption> billingContacts;
    public List<SelectOption> getBillingContacts() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getAccountIdToContactIdToContactName( new Set<String>{ proposal.Billing_Company_Name__c } ).get( proposal.Billing_Company_Name__c ), true, true );
    }

    public transient List<SelectOption> accountingContacts;
    public List<SelectOption> getAccountingContacts() {
        /*if(String.isBlank(proposal.Accounting_Contact_Company__c)) {
            proposal.Accounting_Contact__c = null;
            accountingContactCompanyAction();
        }*/
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getAccountIdToContactIdToContactName( new Set<String>{ proposal.Accounting_Contact_Company__c } ).get( proposal.Accounting_Contact_Company__c ), true, true );
    }

    public transient List<SelectOption> partners;
    public List<SelectOption> getPartners() {
        return ProposalWizardServices.generateOptions( null, usersByProfilesMap.get( UserServices.PROFILE_PARTNER ), true, true );
    }

    public transient List<SelectOption> accountManagers;
    public List<SelectOption> getAccountManagers() {
        return ProposalWizardServices.generateOptions( null, usersByProfilesMap.get( UserServices.PROFILE_ACCOUNT_MANAGER ), true, true );
    }

    public transient List<SelectOption> salespersons;
    public List<SelectOption> getSalespersons() {
        return ProposalWizardServices.generateOptions( null, usersByProfilesMap.get( ProposalWizardServices.SALES_PERSON_KEYWORD ), true, true );
    }

    public transient List<SelectOption> cZAnalysts;
    public List<SelectOption> getCZAnalysts() {
        return ProposalWizardServices.generateOptions( null, usersByProfilesMap.get( UserServices.PROFILE_CODE_ZONING_ANALYST ), true, true );
    }

    public transient List<SelectOption> sipsCoordinators;
    public List<SelectOption> getSipsCoordinators() {
        return ProposalWizardServices.generateOptions( null, usersByProfilesMap.get( UserServices.PROFILE_SIPS_COORDINATOR ), true, true );
    }

    public transient List<SelectOption> fulfillmentOffices;
    public List<SelectOption> getFulfillmentOffices() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Fulfillment_Office__c' ), true, true );
    }

    public transient List<SelectOption> deliveryMethods;
    public List<SelectOption> getDeliveryMethods() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Delivery_Method__c' ), false, true );
    }

    public transient List<SelectOption> billingMethods;
    public List<SelectOption> getBillingMethods() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Billing_Method__c' ), false, true );
    }

    public transient List<SelectOption> frequencies;
    public List<SelectOption> getFrequencies() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Frequency__c' ), true, true );
    }

    public transient List<SelectOption> quarterlyMonths;
    public List<SelectOption> getQuarterlyMonths() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Quarterly_Month__c' ), proposal.Frequency__c != ProposalServices.PROPOSAL_FREQUENCY_QUARTERLY, true );
    }

    public transient List<SelectOption> billingDaysAllPossible; //MRS 7335 
    public List<SelectOption> getBillingDaysAllPossible() {
        List<SelectOption> res = new List<SelectOption>();
        res.addAll(ProposalWizardServices.generateOptions(ProposalWizardServices.getFrequencyToBillingDay().get('Monthly')));
        res.addAll(ProposalWizardServices.generateOptions(ProposalWizardServices.getFrequencyToBillingDay().get('Weekly')));
        res.remove(32);
        return res; 
    }

    @RemoteAction
    public static List<SelectOption> getFrequencyToBillingDayFunction(String type) {
        return ProposalWizardServices.generateOptions(ProposalWizardServices.getFrequencyToBillingDay().get(type));
    }

    public transient List<SelectOption> invoiceFormats;
    public List<SelectOption> getInvoiceFormats() {
        return ProposalWizardServices.generateOptions( null, ProposalWizardServices.getPicklistOptions( Proposal__c.sObjectType, 'Invoice_Format__c' ), false, true );
    }

    public transient List<SelectOption> proposalTypes;
    public List<SelectOption> getProposalTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption( '', '-- None --' ) );
        for( Schema.PicklistEntry item : Proposal__c.sObjectType.getDescribe().fields.getMap().get( 'Proposal_Type__c' ).getDescribe().getPicklistValues() ) {
            /*if( proposal.Proposal_Type__c == ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER ) { //MRS-7049
                if( item.getValue() == ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER ) {
                    options.add( new SelectOption ( item.getValue(), item.getValue() ) );
                }
            } else {
                if( item.getValue() != ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER ) {
                    options.add( new SelectOption ( item.getValue(), item.getValue() ) );
                }
            }*/
            String picklistValue = item.getValue();
            if( picklistValue != ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER ) {
                options.add( new SelectOption( picklistValue, picklistValue ) );
            }
        }
        return options;
    }

    public transient String originalChangeOrderKey;
    public String getOriginalChangeOrderKey() {
        return ChangeOrderServices.ORIGINAL_CHANGE_ORDER;
    }

    public transient String alternativeChangeOrderKey;
    public String getAlternativeChangeOrderKey() {
        return ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER;
    }

    public transient Map<Id, Service_Item__c> serviceInfo;
    public Map<Id, Service_Item__c> getServiceInfo() {
        Map<Id, Service_Item__c> serviceIdToServiceItem = new Map<Id, Service_Item__c>();
        if( proposal.Id != null ) {
            serviceIdToServiceItem = new Map<Id, Service_Item__c>( [ SELECT Name, Service_Name_Full__c, Floor__c, Floor_Concatenated__c, Service_Group__c, Municipal_Agency_ID__c, Original__c, Change_Order__c,
                                                                            Change_order_Old__c, Change_Order__r.Number__c, Change_order_Old__r.Number__c, Service_Template__r.Service_Row_Number__c
                                                                     FROM Service_Item__c
                                                                     WHERE Proposal__c = : proposal.Id ] );
        }
        return serviceIdToServiceItem;
    }


    public transient Boolean isMi3;
    public Boolean getIsMi3() { return ProposalWizardServices.isMi3( proposal ); }

    public List<SelectOption> rFPAttachmentsOption { get; set; }
    public List<SelectOption> rosterContactsOption { get; set; }
    public Decimal chosenPhase { get; set; }
    public String rightPanelView { get; set; }
    public PageReference iFrameRightPageReference { get; set; }
    public Building__c building { get { if( building == null ) building = new Building__c(); return building; } set; }

    public transient Boolean renderQuarterlyMonthPicklist;
    public Boolean getRenderQuarterlyMonthPicklist() {
        return proposal.Frequency__c == ProposalServices.PROPOSAL_FREQUENCY_QUARTERLY;
    }

    public transient Boolean renderBillingDayPicklist;
    public Boolean getRenderBillingDayPicklist() {
        return proposal.Frequency__c != null;
    }

    public Boolean rejectionReasonPanelView { get { if( rejectionReasonPanelView == null ) rejectionReasonPanelView = false; return rejectionReasonPanelView; } set; }

    public transient String changeOrderSplitter;
    public String getChangeOrderSplitter() { return ProposalWizardServices.CHANGE_ORDER_SPLITTER; }

    public transient String changeOrderContent;
    public String getChangeOrderContent() { return ProposalWizardServices.CHANGE_ORDER_CONTENT; }

    public transient String serviceItemSplitter;
    public String getServiceItemSplitter() { return ProposalWizardServices.SERVICE_ITEM_SPLITTER; }

    public transient List<Change_History_Proposal__c> changeHistory;
    public List<Change_History_Proposal__c> getChangeHistory() {
        return ProposalWizardServices.getChangeHistory( proposal.Id );
    }

    public void changeProposalReceivedDocumentStatus() {
        changeReceivedDocumentStatus('');
    }
    public void changeCOReceivedDocumentStatus(){
        changeReceivedDocumentStatus( activeChangeOrderId );
    }
    public void changeReceivedDocumentStatus( String changeOrderId ) {
        try {
            pwm.changeReceivedDocumentStatus( changeOrderId );
        } catch( exception ex ) {
            addMessage( 'Unable to change the document status: ' + ex.getMessage() );
        }
    }

    public transient Map<String, List<Additional_Reimbursable__c>> changeOrderReimbursableMap;
    public Map<String, List<Additional_Reimbursable__c>> getChangeOrderReimbursableMap() {
        return pwm.getChangeOrderReimbursableMap();
    }

    public Additional_Reimbursable__c reimbursableToCreate { get { if( reimbursableToCreate == null ) reimbursableToCreate = new Additional_Reimbursable__c(); return reimbursableToCreate; } set; }
    public void addReimbursableAction() {
        if( String.isBlank( proposal.Id ) ) {
            addMessage( 'Please save Proposal Draft before adding a new Reimbursable Item' );
            return;
        }
        if( String.isBlank( String.valueOf( reimbursableToCreate.Description__c ) ) ) {
            addMessage( 'Required field is missing: [Description]' );
            return;
        }
        if( String.isBlank( String.valueOf( reimbursableToCreate.Amount__c ) ) ) {
            addMessage( 'Required field is missing: [Amount]' );
            return;
        }
        reimbursableToCreate.Proposal__c = proposal.Id;
        if( !String.isBlank(activeChangeOrderId) ) {
            reimbursableToCreate.Change_Order__c = activeChangeOrderId;
        }
        try{
            UPSERT reimbursableToCreate;
            AdditionalReimbursableServices.additionalReimbursables = null;
            reimbursableToCreate = new Additional_Reimbursable__c();
        } catch( Exception e ) {
            addMessage( 'Error Saving Additional Reimbursable.' );
            return;
        }
    }
    public void addAndNewReimbursableAction() {
        addReimbursableAction();
        rightPanelView = 'Reimbursable';
    }

    public String reimbursableIdToRemove { get; set; }
    public void deleteReimbursableAction() {
        Map<Id, Additional_Reimbursable__c> reimbursableMap = new Map<Id, Additional_Reimbursable__c>(pwm.reimbursableList);
        if( reimbursableMap.containsKey( reimbursableIdToRemove ) ) {
            try{
                DELETE new Additional_Reimbursable__c( Id = reimbursableIdToRemove );
                AdditionalReimbursableServices.additionalReimbursables = null;
            }catch( DmlException ex ) {
                addMessage( 'Error Deleting Additional Reimbursable.' );
                return;
            }
            reimbursableIdToRemove = null;
        }
    }

    public void updateChangeOrderReimbursableData() {
        try {
            pwm.updateChangeOrderReimbursableData( activeChangeOrderId );
        } catch( exception ex ) {
            addMessage( 'Unable to update Change Order reimbursable data: ' + ex.getMessage() );
        }
    }

    public void updateChangeOrderDiscountData() {
        try {
            pwm.updateChangeOrderDiscountData(activeChangeOrderId);
        } catch( exception ex ) {
            addMessage( 'Unable to update Change Order discount data: ' + ex.getMessage() );
        }
    }

    public transient String proposalVersion;
    public String getProposalVersion() {
        if( proposal.Id != null ) {
            List<Proposal__c> proposals = [ SELECT Version_Text__c FROM Proposal__c where Id = : proposal.Id ];
            if( !proposals.isEmpty() ) {
                return proposals[0].Version_Text__c;
            }
        }
        return '00.01';
    }
    public void setProposalVersion( String proposalVersion ) {}

    public transient List<Phase__c> phaseList;
    public List<Phase__c> getPhaseList() {
        return PhaseServices.getPhaseList(proposal.Id, 'Number__c');
    }

    public transient Map<String, Phase__c> phaseInfo;
    public Map<Id, Phase__c> getPhaseInfo() {
        Map<Id, Phase__c> phaseMapForPhaseInfo = PhaseServices.getPhaseMapById( proposal.Id, 'Number__c' );
        phaseMapForPhaseInfo.put( null, new Phase__c( Name = '', Name__c = '' ) );
        return phaseMapForPhaseInfo;
    }

    public transient Boolean renderedPhaseAction;
    public Boolean getRenderedPhaseAction() {
        Profile profile = [ SELECT Name FROM Profile WHERE Id = : UserInfo.getProfileId() ];
        if( !profile.Name.contains( UserServices.PROFILE_PROJECT_MANAGER ) ) {
            return false;
        } else {
            return true;
        }
    }

    public transient List<SelectOption> phaseSelectOption;
    public List<SelectOption> getPhaseSelectOption() {
        List<SelectOption> phaseOptions = new List<SelectOption>();
        List<Phase__c> phases = getPhaseList();
        for( Phase__c phase : phases ) {
            phaseOptions.add( new SelectOption(String.valueOf(phase.Number__c), phase.Name__c) );
        }
        if( !phaseOptions.isEmpty() ) chosenPhase = phases[0].Number__c;
        return phaseOptions;
    }

    public transient Boolean isAnyServiceItems;
    public Boolean getIsAnyServiceItems() {
        return (pwm.serviceModels != null && !pwm.serviceModels.isEmpty());
    }

    private List<Floor__c> getCurrentFloorsList() {
        return FloorServices.getRecordsByProposalIdList( proposal.Id );
    }

    public transient List<FloorWrapper> floorWrapperList;
    public List<FloorWrapper> getFloorWrapperList() {
        List<FloorWrapper> floorWrappers = new List<FloorWrapper>();
        if( !String.isEmpty( proposal.Id ) ) {
            for( Floor__c floor : getCurrentFloorsList() ) {
                floorWrappers.add( new FloorWrapper( floor ) );
            }
        }
        return FloorServices.sortFloorType( floorWrappers );
    }



    public String floorIdToRemove { get; set;}
    public void removeFloorAction() {
        try {
            pwm.removeFloorAndServiceJunctions(floorIdToRemove);
            FloorServices.floors = null;
            List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
            proposal.Floor_s__c = FloorServices.updateFloorsString( proposal.Id, proposal.Project_Profile__c, currentFloorWrapperList, true );
            ProposalWizardModel.updateServicesAndJunctions( currentFloorWrapperList, pwm.serviceModels.values(), proposal, true );
        } catch ( Exception ex ) {
            addMessage( 'Error deleting floor: ' + ex.getMessage() );
        } finally {
            floorIdToRemove = null;
        }
    }

    public Boolean statusOfFloorVisibility {get;set;} // MRS 7109
    public void changeVisibilityOfFloor() {
        Integer amountOfSelectedFloors = 0;
        for(FloorWrapper floorWrapper : getFloorWrapperList()) {
            if(floorWrapper.floorIsShown) amountOfSelectedFloors++;
        }
        if(amountOfSelectedFloors < 2 && !statusOfFloorVisibility) {
            addMessage('At least one of the checkboxes should always be checked');
            return;
        }
        try {
            Floor__c floor = new Floor__c(Id = floorIdToRemove, Floor_is_shown__c = statusOfFloorVisibility);
            UPDATE floor;
            FloorServices.floors = null;
            List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
            proposal.Floor_s__c = FloorServices.updateFloorsString( proposal.Id, proposal.Project_Profile__c, currentFloorWrapperList, true );
        } catch (Exception ex) {
            addMessage('Error updating floor status: ' + ex.getMessage());
        } finally {
            floorIdToRemove = null;
            statusOfFloorVisibility = null;
        }
    }

    public void associateFloorsWithServicesAction() {
        Integer dmlAllowed = 10000;
        List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        List<Service_Item__c> serviceItemsToProcess = new List<Service_Item__c>();

        for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( !sm.IsAlternative ) {
                serviceItemsToUpdate.add(new Service_Item__c(Id = sm.recordId));
            }
        }
        Boolean notAllServicesProcessed = false;
        if( serviceItemsToUpdate.size() * currentFloorWrapperList.size() >  dmlAllowed){
            notAllServicesProcessed = true;
            Decimal servicesAmount = dmlAllowed/currentFloorWrapperList.size();
            for(Integer i=0; i<servicesAmount.intValue(); i++){
                serviceItemsToProcess.add(serviceItemsToUpdate[i]);
            }
        } else {
            serviceItemsToProcess = serviceItemsToUpdate;
        }
        try {
            ProposalWizardModel.updateServicesAndJunctions( currentFloorWrapperList, serviceItemsToProcess, proposal, false );
            if( notAllServicesProcessed ){
                ProposalWizardModel.updateRestOfServiceAndJunctions(proposal.Id);
            }
        } catch( Exception ex ) {
            addMessage( ex.getMessage() );
        }
    }

    public void manageServiceFloorJunctions() {
        try {
            pwm.manageServiceFloorJunctions( serviceIdsForMultiAction, selectedServiceFloorIds, partialServiceFloorIds, getFloorWrapperList() );
        } catch( Exception ex ) {
            addMessage( ex.getMessage() );
        }

        serviceIdsForMultiAction = null;
        selectedServiceFloorIds = null;
        partialServiceFloorIds = null;
    }

    public String selectedServiceFloorIds { get; set; }
    public String partialServiceFloorIds { get; set; }
    public void populateServiceFloorJunctionsIds() {
        Set<String> serviceIdsForPopulatingServiceJunctions = new Set<String>( serviceIdsForMultiAction.split(';') );
        List<Service_Floor_Junction__c> serviceJunctions = new List<Service_Floor_Junction__c>( [ SELECT Id, Floor__c, Service_Item__c
                                                                                                  FROM Service_Floor_Junction__c
                                                                                                  WHERE Service_Item__c IN : serviceIdsForPopulatingServiceJunctions ] );
        Map<Id, Set<String>> floorIdToServiceIds = new Map<Id, Set<String>>();
        for( Service_Floor_Junction__c serviceJunction : serviceJunctions ) {
            if( !floorIdToServiceIds.containsKey( serviceJunction.Floor__c ) ) {
                floorIdToServiceIds.put( serviceJunction.Floor__c, new Set<String>() );
            }
            floorIdToServiceIds.get( serviceJunction.Floor__c ).add( serviceJunction.Service_Item__c );
        }
        List<String> selectedFloorsIdList = new List<String>();
        List<String> partialFloorsIdList = new List<String>();
        for( Id floorIdItem : floorIdToServiceIds.keySet() ) {
            if( floorIdToServiceIds.get( floorIdItem ).containsAll( serviceIdsForPopulatingServiceJunctions ) ) {
                selectedFloorsIdList.add( floorIdItem );
            } else {
                partialFloorsIdList.add( floorIdItem );
            }
        }
        selectedServiceFloorIds = selectedFloorsIdList.isEmpty() ? '' : String.join( selectedFloorsIdList, ';' );
        partialServiceFloorIds = partialFloorsIdList.isEmpty() ? '' : String.join( partialFloorsIdList, ';' );
    }


    private Boolean isBuildingUpdated {
        get {
            if( isBuildingUpdated == null ) isBuildingUpdated = false;
            return isBuildingUpdated;
        } set;
    }

    public Boolean isLandmark {
        get {
            if( isLandmark == null ) isLandmark = proposal.is_Landmark__c;
            if( isBuildingUpdated && building != null ) {
                isLandmark = building.Is_Landmark__c;
            }
            return isLandmark;
        }
        set { proposal.is_Landmark__c = value; }
    }

    public Boolean isMTA {
        get {
            if( isMTA == null) isMTA = proposal.is_MTA__c;
            if( isBuildingUpdated && building != null ) {
                isMTA = building.is_MTA__c;
            }
            return isMTA;
        }
        set { proposal.is_MTA__c = value; }
    }
    public transient Boolean showProposalAwardedDate;
    public Boolean getShowProposalAwardedDate() {
        return proposal.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED;
    }

    public transient List<SelectOption> floorCountingOptions;
    public List<SelectOption> getFloorCountingOptions() {
        return ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Proposal__c.SObjectType, 'Floor_Counting__c'), false, true);
    }

    public transient List<SelectOption> projectTeams;
    public List<SelectOption> getProjectTeams() {
        return ProjectTeamServices.getProjectTeamOptions( proposal.Production_Manager__c );
    }

    public transient List<SelectOption> freps;
    public List<SelectOption> getFreps() {
        return ProjectTeamServices.getFrepsOptions( proposal.Project_Team__c, proposal.FREP__c );
    }

    public transient List<SelectOption> prodManagers;
    public List<SelectOption> getProdManagers() {
        return ProjectTeamServices.getProdManagersOptions( proposal.Production_Manager__c );
    }

    public void setDefaultFrep() {
        proposal.FREP__c = ProjectTeamServices.getDefaultFrepForProjectTeam( proposal.Project_Team__c );
    }

    public void setDefaultProdManager() {
        proposal.Production_Manager__c = ProjectTeamServices.getDefaultProdManagerForProjectTeam( proposal.Project_Team__c );
        proposal.FREP__c = ProjectTeamServices.getDefaultFrepForProjectTeam( proposal.Project_Team__c );
    }

    /* Assignment start */
    public String assignmentSortField {
        get { if( String.isBlank( assignmentSortField ) ) assignmentSortField = ProjectTeamServices.SORT_WORKLOAD; return assignmentSortField; }
        set { if( assignmentSortField == value ) assignmentSortDirection = assignmentSortDirection == MilroseDevHelper.SORT_ASC ? MilroseDevHelper.SORT_DESC : MilroseDevHelper.SORT_ASC; else assignmentSortDirection = MilroseDevHelper.SORT_ASC; assignmentSortField = value; }
    }
    public String assignmentSortDirection { get { if( assignmentSortDirection == null ) { assignmentSortDirection = MilroseDevHelper.SORT_ASC; } return assignmentSortDirection; } set; }

    public transient String assignmentDirectionMark;
    public String getAssignmentDirectionMark() { return assignmentSortDirection == MilroseDevHelper.SORT_ASC ? ' ▼' : ' ▲'; }

    public transient List<AssignmentWrapper> assignments;
    public List<AssignmentWrapper> getAssignments() {
        List<AssignmentWrapper> assignmentsFromDB = new List<AssignmentWrapper>();
        if( getCanAssignProjectTeam() ) {
            assignmentsFromDB = ProjectTeamServices.getAssignmentsForProjectTeam( proposal );
        } else if( getCanAssignResource() ) {
            assignmentsFromDB = ProjectTeamServices.getAssignmentsForResource( proposal );
        }
        for( AssignmentWrapper assignment : assignmentsFromDB ) {
            assignment.sortName = assignmentSortField;
            assignment.orderBy = assignmentSortDirection;
        }
        assignmentsFromDB.sort();
        return assignmentsFromDB;
    }

    public String frepSortField {
        get { if( String.isBlank( frepSortField ) ) frepSortField = ProjectTeamServices.SORT_WORKLOAD; return frepSortField; }
        set { if( frepSortField == value ) frepSortDirection = frepSortDirection == MilroseDevHelper.SORT_ASC ? MilroseDevHelper.SORT_DESC : MilroseDevHelper.SORT_ASC; else frepSortDirection = MilroseDevHelper.SORT_ASC; frepSortField = value; }
    }
    public String frepSortDirection { get { if( frepSortDirection == null ) { frepSortDirection = MilroseDevHelper.SORT_ASC; } return frepSortDirection; } set; }

    public transient String frepDirectionMark;
    public String getFrepDirectionMark() { return frepSortDirection == MilroseDevHelper.SORT_ASC ? ' ▼' : ' ▲'; }

    public transient List<AssignmentWrapper> frepAssignments;
    public List<AssignmentWrapper> getFrepAssignments() {
        List<AssignmentWrapper> assignmentsFromDB = ProjectTeamServices.getAssignmentsForFrep();
        for( AssignmentWrapper assignment : assignmentsFromDB ) {
            assignment.sortName = frepSortField;
            assignment.orderBy = frepSortDirection;
        }
        assignmentsFromDB.sort();
        return assignmentsFromDB;
    }
    /* Assignment End */

    public transient Boolean isExistAPSService;
    public Boolean getIsExistAPSService() {
        if( pwm.serviceModels != null ) {
            for( ServiceModel sm : pwm.changeOrderModelMap.get( ChangeOrderServices.ORIGINAL_CHANGE_ORDER ).serviceModels ) {
                if( sm.serviceItemRecord.Service_Template__c != null && sm.serviceItemRecord.Is_Aps_Service__c ) {
                    return true;
                }
            }
            if( proposal.Is_Change_Order__c ) {
                for( String changeOrderId : pwm.changeOrderModelMap.keySet() ) {
                    ChangeOrderModel changeOrder = pwm.changeOrderModelMap.get( changeOrderId );
                    if( changeOrderId instanceOf Id && changeOrder.status == ChangeOrderServices.STATUS_APPROVED ) {
                        for( ServiceModel sm : changeOrder.serviceModels ) {
                            if( sm.serviceItemRecord.Service_Template__c != null && sm.serviceItemRecord.Is_Aps_Service__c ) {
                                return true;
                            }
                        }
                    }
                }
            }
        }
        return false;
    }

    public transient Boolean isAllOSServices;
    public Boolean getIsAllOSServices() {
        Boolean hasOS = false;
        if( pwm.serviceModels != null ) {
            for( ServiceModel sm : pwm.serviceModels.values() ) {
                if( !sm.isAlternative &&
                    sm.serviceItemRecord.Service_Template__c != null && !sm.serviceItemRecord.Is_Aps_Service__c ) {
                        hasOS = true;
                } else {
                    return false;
                }
            }
        }
        return hasOS;
    }

    public transient Boolean canShowAssignment;
    public Boolean getCanShowAssignment() {
        return getCanAssignProjectTeam() || getCanAssignResource();
    }

    public transient Boolean canAssignProjectTeam;
    public Boolean getCanAssignProjectTeam() {
        return ( ( ( this.profileName.contains( UserServices.PROFILE_OPERATIONS_MANAGER ) ||
                     this.profileName.contains( UserServices.PROFILE_DIRECTOR_OF_OPERATIONS ) || //MRS-6507
                     this.profileName.contains( UserServices.PROFILE_SHARED_SERVICES_MANAGER ) || //MRS-6728
                     getIsAdmin() ||
                     UserInfo.getUserId() == proposal.Production_Manager__c ) &&
                   proposal.Status__c == 'Awarded' ) ||
                 ( ( getIsPS() || getIsPManager1() || getIsPManager2() || getIsAdmin() ) &&
                   getIsMi3() ) ) &&
               getIsExistAPSService();
    }

    public transient Boolean showAssignProjectTeamButton;
    public Boolean getShowAssignProjectTeamButton() {
        return proposal.Status__c == ProposalServices.PROPOSAL_STATUS_AWARDED &&
               getCanAssignProjectTeam() &&
               ( String.isBlank( proposal.Project_Profile__c ) || String.isBlank( proposal.Project_Profile__r.Project_Team__c ) );
    }

    public transient Boolean canAssignResource;
    public Boolean getCanAssignResource() {
        return ( this.profileName.contains( UserServices.PROFILE_SHARED_SERVICES_MANAGER ) ||
                 getIsAdmin() ) &&
               !proposal.Is_Change_Order__c &&
               proposal.Status__c == 'Awarded' &&
               getIsAllOSServices();
    }

    public transient String hideErrorCodes;
    public String getHideErrorCodes() {
        return String.join( new List<String>( ErrorException.proposalErrorCodeToMessage.keySet() ), ' ');
    }

    public void addErrorsWhenCreatingProject( DMLException dmlEx, Boolean isSettingProjectTeam ) {
        for ( Integer dmlExIndex = 0; dmlExIndex < dmlEx.getNumDml(); dmlExIndex++ ) {
            String dmlError = dmlEx.getDmlMessage( dmlExIndex );
            for( String errorCode : ErrorException.proposalErrorCodeToMessage.keySet() ) {
                if( dmlError.contains( errorCode ) ) {
                    dmlError = ErrorException.proposalErrorCodeToMessage.get( errorCode );
                    break;
                }
            }
            addMessage( ( isSettingProjectTeam ? ErrorException.ERROR_SETTING_PROJECT_TEAM : ErrorException.ERROR_CREATING_PROJECT ) + ': ' + dmlError, 'Info' );
        }
    }

    public void setCurrentStep() {
        setCurrentStep( currentStep );
    }

    public void setCurrentStep( String stepNumber ) {
        currentStep = ProposalWizardServices.setCurrentStep( proposal, stepNumber );
    }

    public pageReference setProjectTeam() {
        setCurrentStep();
        Savepoint sp_setProjectTeam = Database.setSavepoint();
        if( String.isBlank( proposal.Project_Team__c ) ) {
            proposal.FREP__c = null;
            proposal.Production_Manager__c = null;
        }

        if( !saveProjectRoster() ) return null;
        Boolean updateProposal = String.isBlank( proposal.Project_Profile__c );
        try {
            if( updateProposal ) {
                ServiceItemServices.preventorUpdateServiceItemOwner = false;
                UPDATE new Proposal__c( Id = proposal.Id, Project_Team__c = proposal.Project_Team__c, FREP__c = proposal.FREP__c, Production_Manager__c = proposal.Production_Manager__c );
            } else {
                UPDATE new Project_profile__c( Id = proposal.Project_Profile__c, Project_Team__c = proposal.Project_Team__c, FREP__c = proposal.FREP__c, Production_Manager__c = proposal.Production_Manager__c, Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey() );
            }
            filterAndSaveNotes( proposal.Id );
        } catch( DMLException dmlEx ) {
            addErrorsWhenCreatingProject( dmlEx, true );
            Database.rollback( sp_setProjectTeam );
            if( updateProposal ) {
                ServiceItemServices.preventorUpdateServiceItemOwner = true;
            }
            return null;
        }
        return ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition );
    }

    public transient Boolean canAssignCZAnalyst;
    public Boolean getCanAssignCZAnalyst() {
        String region = !String.isEmpty( proposal.Id ) ? ( proposal.Region__c ) : ( '' );
        return ( getIsAdmin() ||
               ( getIsCZAnalyst() &&
                 currentUserRoleName.contains( UserServices.ROLE_CZ_MANAGER ) &&
                 !String.isBlank( region ) && currentUserRoleName.contains( region ) ) ) &&
               ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW );
    }

    public PageReference assignCZAnalyst(){
        try {
            Proposal__c proposalToUpdate = new Proposal__c( Id = proposal.Id, Code_Zoning_Analyst__c = proposal.Code_Zoning_Analyst__c );
            User selectedUser = UserServices.getUserById( proposal.Code_Zoning_Analyst__c );
            if( user.Id != null ){
                proposalToUpdate.Code_Zoning_Analyst_Email__c = selectedUser.Email;
            }
            if( proposalToUpdate.Id != null && filterAndSaveNotes( proposalToUpdate.Id )){
                UPDATE proposalToUpdate;
            }
            return ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition );
            //In case manager assign proposal to himself we need to recalculate this value
            //isThisUserAssignedCZAnalyst = null;
        } catch(Exception ex) {
            addMessage( 'Error setting CZ Analyst: ' + ex.getMessage() );
        }
        return null;
    }

    public void saveNotes() {
        setCurrentStep();
        if( String.isBlank( proposal.Id ) ) {
            saveProposalIfNotExists();
        }
        filterAndSaveNotes( proposal.Id );
    }

    public transient Boolean canAssignSIPSCoordinator;
    public Boolean getCanAssignSIPSCoordinator() {
        return ( getIsAdmin() || profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) )&&
                 proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
    }

    public void assignSIPSCoordinator(){
        try {
            Proposal__c proposalToUpdate = new Proposal__c( Id = proposal.Id, SIPS_Coordinator__c = proposal.SIPS_Coordinator__c );
            if( proposalToUpdate.Id != null && filterAndSaveNotes( proposalToUpdate.Id )){
                UPDATE proposalToUpdate;
            }
        } catch(Exception ex) {
            addMessage( 'Error setting SIPS Coordinator: ' + ex.getMessage() );
        }
    }

    public transient Boolean viewOnly { get; set; }
    public Boolean getViewOnly() {
        return ( proposal.is_Change_Order__c &&
                 !getIsFromChangeOrderRequestButton() &&
                 profileName.contains( UserServices.PROFILE_PROJECT_MANAGER ) ) ||
               ( !proposal.is_Change_Order__c &&
                 getIsCZAnalyst() &&
                 proposal.Code_Zoning_Analyst__c != currentUserId &&
                 !getIsPS() ); /*||
               ( !proposal.Is_Draft__c && proposal.Is_Mi3_Project_Created__c )*/
    }

        public Boolean isAccountOrProjectOnHold { // MRS 6800
                set;
                get {
                        return (proposal.Project_Profile__c != null && proposal.Project_Profile__r.Project_State__c == 'On Hold')
                                || (proposal.Billing_Company_Name__c != null && proposal.Billing_Company_Name__r.Accounting_Hold__c);
                }
        }

    public transient Boolean hasNoID; //MRS 6835
    public Boolean getHasNoID() {
        return String.isBlank(proposal.Id);
    }

    public transient Boolean isChangeOrder;
    public Boolean getIsChangeOrder() {
        return ( String.isEmpty( proposal.Id ) || proposal.Is_Draft__c ) ? false : proposal.is_Change_Order__c;
    }

    public transient Boolean showServicesPrices;
    public Boolean getShowServicesPrices() {
        return profileName != UserServices.PROFILE_PROJECT_MANAGER_2 &&
               !getIsCZAnalyst();
    }

    public void updateAttachedDocuments() {
        proposal.RFP_Attachments__c = ProposalWizardServices.updateAttachedDocuments( pwm.documentWrapperList );
    }

    public Boolean createServiceItemsFromRowList( Boolean isBundle ) { //true = load bundle, false = load from step 2
        List<Service_Bundle_Item__c> serviceBundleItems = new List<Service_Bundle_Item__c>();
        List<String> serviceRowNumbers = new List<String>();
        Map<Id, Service_Template__c> serviceIdToServiceTemplate;
        List<ServiceModel> serviceModelTemplates = new List<ServiceModel>();
        Map<Id, Client_Price__c> serviceIdToClientPrice;
        Map<String, Service_Template__c> serviceRowNumberToServiceTemplate = new Map<String, Service_Template__c>();

        if( isBundle ) {
            if( !String.isBlank(serviceBundleChosen) && building != null && proposal.Billing_Company_Name__c != null ) {
                serviceBundleItems = ProposalWizardServices.getServiceBundleItems( serviceBundleChosen );
                ProposalWizardServices.regenerateServiceGroupKeys( serviceBundleItems );
                serviceRowNumbers = ProposalWizardServices.getServiceRowNumbersFromBundleItems( serviceBundleItems, serviceBundleChosen );
            }
        } else {
            serviceRowNumbers = ProposalWizardServices.getServiceRowNumbers( proposal, building, getCurrentFloorsList() );
        }
        if( !serviceRowNumbers.isEmpty() ) {
            serviceIdToServiceTemplate = ProposalWizardServices.getServiceTemplatesMap( serviceRowNumbers, isBundle ? '%' : building.Region__c );//MRS-6715
            serviceIdToClientPrice = ProposalWizardServices.getServiceIdToClientPrice(serviceIdToServiceTemplate.keySet(), proposal.Billing_Company_Name__c);
            for( Service_Template__c stItem : serviceIdToServiceTemplate.values() ) {
                serviceRowNumberToServiceTemplate.put( stItem.Service_Row_Number__c, stItem );
            }
            Integer rowNumberItem = 0;
            for( String serviceRowNumberItem : serviceRowNumbers ) {
                Service_Template__c stItem = serviceRowNumberToServiceTemplate.get(serviceRowNumberItem);
                if( stItem != null ) {
                    if( !String.isBlank(activeChangeOrderId) && serviceBundleItems[rowNumberItem].Is_Alternative__c ) {
                        rowNumberItem++;
                            continue;
                        }
                        serviceModelTemplates.add( new ServiceModel( stItem.clone(true), serviceIdToClientPrice.get(stItem.Id)) );
                        Integer sIndex = serviceModelTemplates.size() - 1;
                    if( !isBundle ) {
                        if( serviceModelTemplates[sIndex].serviceTemplateRecord.Service_Row_Number__c == 'APS76' ) {
                            serviceModelTemplates[sIndex].quantity = proposal.sowACUnitsNumber__c.setScale(0);
                        } else {
                            serviceModelTemplates[sIndex].quantity = 1;
                        }
                    } else {
                        if( ProposalWizardServices.isCustomWorkTypeService( serviceModelTemplates[sIndex].serviceTemplateRecord.Category__c,
                                                                            serviceModelTemplates[sIndex].serviceTemplateRecord.Type__c,
                                                                            serviceModelTemplates[sIndex].serviceTemplateRecord.RecordTypeId == recordTypeNameToId.get( ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME ) ) &&
                            !String.isBlank( serviceBundleItems[rowNumberItem].Work_Type__c ) ) {
                            ProposalWizardServices.populateWorkTypeAndFullName( null, null, serviceBundleItems[rowNumberItem], serviceModelTemplates[sIndex].serviceTemplateRecord );
                        }
                        serviceModelTemplates[sIndex].serviceItemRecord.Service_Group_Key__c = serviceBundleItems[rowNumberItem].Service_Group_Key__c;
                        serviceModelTemplates[sIndex].quantity = (serviceBundleItems[rowNumberItem].Quantity__c).setScale(0);
                        serviceModelTemplates[sIndex].discount = String.isBlank( activeChangeOrderId )
                                                                 ? ( proposal.Apply_Discount__c ? proposal.Discount_Percentage__c : 0 )
                                                                 : ( pwm.changeOrderModelMap.get( activeChangeOrderId ).changeOrderRecord.Apply_Discount__c ? pwm.changeOrderModelMap.get( activeChangeOrderId ).changeOrderRecord.Discount_Percentage__c : 0 );
                        if( !String.isBlank(activeChangeOrderId) ) {
                            serviceModelTemplates[sIndex].changeOrderId = activeChangeOrderId;
                            serviceModelTemplates[sIndex].isAmendmendAdded = true;
                            serviceModelTemplates[sIndex].isOriginal = false;
                        }else if( virtualChangeOrderName == ChangeOrderServices.ORIGINAL_CHANGE_ORDER ){
                            serviceModelTemplates[sIndex].isOriginal = true;
                        }else if( virtualChangeOrderName == ChangeOrderServices.ALTERNATIVE_CHANGE_ORDER ){
                            serviceModelTemplates[sIndex].isOriginal = true;
                            serviceModelTemplates[sIndex].isAlternative = true;
                        }
                    }
                }
                rowNumberItem++;
            }

            if( !createPhasesAndServiceItems( false, serviceModelTemplates ) ) {
                return false;
            }
            for( ServiceModel sm : pwm.serviceModels.values() ) {
                sm.checked = false;
            }
            populateServiceModels( isBundle );
        }
        return true;
    }

    public String serviceIdsSerialized { get; set { pwm.updateServiceRowPositions( value ); } }

    public String serviceIdToRemove { get; set; }
    public void removeServiceModel() {
        if( pwm.removeServiceItems( new List<String>{ serviceIdToRemove }, activeChangeOrderId ) == false ) {
            addMessage( 'Error occurred while deleting service Item.' );
        }/* else {
            pwm.serviceModels.get( serviceIdToRemove ).checked = false;
        }*/
        //recalculateReimbursables();
        //recalculateServiceRowPositions();
        serviceIdToRemove = null; //
    }

    public Boolean isConfirmationNeeded { get { if( isConfirmationNeeded == null ) isConfirmationNeeded = false; return isConfirmationNeeded; } set; }
    public String serviceIdToChange { get; set; }
    public String newQuantity { get; set; }
    public String oldQuantity { get; set; }
    public Boolean isDiff { get; set; }
    public void changeQuantity() {
        try {
            if( pwm.isQuantityChangeNeedsConfirmation( newQuantity, oldQuantity, serviceIdToChange, isDiff ) ) {
                isConfirmationNeeded = true;
            } else {
                isConfirmationNeeded = false;
                changeQuantityInServiceModel();
            }
        } catch( exception ex ) {
            changeQuantityCancel();
            addMessage( ex.getMessage() );
        } finally {
            if( !isConfirmationNeeded ) {
                serviceIdToChange = null;
                newQuantity = null;
                oldQuantity = null;
                isDiff = null;
            }
        }
    }

    public void changeQuantityApprove() {
        isConfirmationNeeded = false;
        changeQuantityInServiceModel();
        serviceIdToChange = null; //
        newQuantity = null; //
        oldQuantity = null; //
        isDiff = null; //
    }

    public void changeQuantityCancel() {
        isConfirmationNeeded = false;
        pwm.cancelQuantityChangeInServiceModel( oldQuantity, serviceIdToChange, isDiff );
        serviceIdToChange = null; //
        newQuantity = null; //
        oldQuantity = null; //
        isDiff = null; //
    }

    public void changeQuantityInServiceModel() {
        try {
            String serviceGroupKey = pwm.serviceModels.get( serviceIdToChange ).serviceItemRecord.Service_Group_Key__c;
            if( serviceGroupKey != null ){
                for( ServiceModel sm: pwm.serviceModels.values() ){
                    if( sm.serviceItemRecord.Service_Group_Key__c == serviceGroupKey ){
                        pwm.changeQuantityInServiceModel( newQuantity, oldQuantity, new List<String>{ sm.recordId }, activeChangeOrderId, isDiff );
                    }
                }
            }else{
                pwm.changeQuantityInServiceModel( newQuantity, oldQuantity, new List<String>{ serviceIdToChange }, activeChangeOrderId, isDiff );
            }
        } catch( Exception ex ) {
            addMessage( ex.getMessage() );
        }
    }

    public void changeUnitPriceInServiceModel() {
        String serviceGroupKey = pwm.serviceModels.get( serviceIdToChange ).serviceItemRecord.Service_Group_Key__c;
        if( serviceGroupKey != null ){
            Decimal newServicePrice = pwm.serviceModels.get( serviceIdToChange ).servicePrice;
            for( ServiceModel sm: pwm.serviceModels.values() ){
                if( sm.serviceItemRecord.Service_Group_Key__c == serviceGroupKey ){
                    sm.servicePrice = newServicePrice;
                }
            }
        }
    }

    public Boolean confirmServiceTune { get; set; }
    public Boolean fromSubmitButton { get { if( fromSubmitButton == null ) fromSubmitButton = false; return fromSubmitButton; } set;}
    public void setConfirmServiceTune() { /*MRS 7094*/ saveInstructions(); fromSubmitButton = false; confirmServiceTune = true; }
    public void setConfirmServiceTuneSubmit() { /*MRS 7094*/ saveInstructions(); fromSubmitButton = true; confirmServiceTune = true; }

    public PageReference populateServicesFromStepTwoCZDialog( String previousStatus ) {
        PageReference pr;
        if( !String.isEmpty( proposal.Id ) ) {
            if( fromSubmitButton ) {
                populateServicesFromStepTwo(false);
                fromSubmitButton = false;
            }
            pr = saveDraft();
        } else {
            pr = complete();
        }
        if( pr == null && previousStatus != null ) {
            proposal.Status__c = previousStatus; return pr;
        }
        return pr;
    }

    public PageReference skipSendingToCZSpecialist() { // NRS 7375
        populateServicesFromStepTwoCZDialog( null );
        PageReference pr = new PageReference('/apex/ProposalWizard');
        pr.getParameters().put('id', proposal.Id);
        pr.getParameters().put('step', '3');
        pr.setRedirect(true);
        return pr;
    }

    public PageReference sendToCZSpecialist() {
        confirmServiceTune = false;
        String previousStatus = proposal.Status__c;
        proposal.Status__c = ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW;

        //MRS-4879, MRS-4434
        if( !usersByProfilesMap.get( UserServices.PROFILE_CODE_ZONING_ANALYST ).isEmpty() ){
            Map<Id, User> czManagersMap = UserServices.getUsersMapByRoleAndRegion(UserServices.ROLE_CZ_MANAGER, proposal.Region__c);
            for(Id czManagerId : czManagersMap.keySet() ){
                if( usersByProfilesMap.get( UserServices.PROFILE_CODE_ZONING_ANALYST ).containsKey(czManagerId) ){
                    proposal.Code_Zoning_Analyst__c = czManagerId;
                    proposal.Code_Zoning_Analyst_Email__c = czManagersMap.get(czManagerId).Email;
                    break;
                }
            }
        }
        return populateServicesFromStepTwoCZDialog( previousStatus );
    }

    public void updateCZAnalystEmailOnChangeOrder(){
        pwm.updateCZAnalystEmailOnChangeOrder( activeChangeOrderId );
    }

    public void updateSIPSCoordinatorOnChangeOrder(){
        pwm.updateSIPSCoordinatorOnChangeOrder( activeChangeOrderId );
    }

    public PageReference populateServicesFromStepTwo() { return populateServicesFromStepTwo(true); }

    public PageReference populateServicesFromStepTwo(Boolean isUpdate) {
        fromSubmitButton = false;
        confirmServiceTune = false;
        System.Savepoint sp_populateServicesFromStepTwo = Database.setSavepoint();
        if( !pwm.serviceModels.isEmpty() ) {
            if( !String.isBlank( proposal.Id ) ) {
                try {
                    DELETE [ SELECT Id FROM Service_Item__c WHERE Phase__r.Proposal__c = : proposal.Id ];
                    pwm.serviceModels = new Map<Id, ServiceModel>();
                } catch (DMLException e) {
                    Database.rollback(sp_populateServicesFromStepTwo);
                    addMessage( 'Error delecting old Service Items.' );
                    return null;
                }
            }
        }
        if( createServiceItemsFromRowList( false ) == false ) { Database.rollback(sp_populateServicesFromStepTwo); return null; }
        setCurrentStep('3');
        formPosition = 0;
        if(isUpdate && !proposal.sowServicesNeededAPS__c && proposal.sowServicesNeededOther__c) {
            if( getPhaseList().isEmpty() ) {
                if( !createPhasesAndServiceItems(true,  null) ) { Database.rollback(sp_populateServicesFromStepTwo); return null; }
            }
            //changeRightPanelToServiceItem();
            return null;
        }
        if( isUpdate ) {
            recalculateDiscount();
            return saveDraft();
        }
        return null;
    }

    public void moveServicesToPhase() {
        Set<String> serviceIdsAbleToMovePhase = new Set<String>();
        if( !String.isEmpty( serviceIdsForMultiAction ) ) {
            List<String> serviceIdsAbleToMovePhaseList = serviceIdsForMultiAction.split(';');
            serviceIdsAbleToMovePhase.addAll( serviceIdsAbleToMovePhaseList );
        }
        Map<Decimal, Phase__c> phaseMap = PhaseServices.getPhaseMap( proposal.Id );
        for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( sm.checked && serviceIdsAbleToMovePhase.contains( sm.recordId ) ) {
                //sm.phaseStep = Integer.valueOf(chosenPhase);
                //sm.phaseName = phaseMap.get(chosenPhase).Name__c;
                sm.phaseId = phaseMap.get(chosenPhase).Id;
            }
            sm.checked = false;
        }
        isPhasesPanelShown = false;
        //recalculateServiceRowPositions();
    }

    public void moveServiceToPhase() {
        Map<Decimal, Phase__c> phaseMap = PhaseServices.getPhaseMap( proposal.Id );
        for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( serviceIdsForMultiAction.contains( sm.recordId ) ) {
                //sm.phaseStep = Integer.valueOf(chosenPhase);
                //sm.phaseName = phaseMap.get(chosenPhase).Name__c;
                sm.phaseId = phaseMap.get(chosenPhase).Id;
            }
        }
        isPhasesPanelShown = false;
        //recalculateServiceRowPositions();
    }

    public String serviceIdsForMultiAction { get; set; }
    public void deleteMultipleServices() {
        Set<String> serviceIdsAbleToDelete = new Set<String>();
        if( !String.isEmpty( serviceIdsForMultiAction ) ) {
            List<String> serviceIdsAbleToDeleteList = serviceIdsForMultiAction.split(';');
            serviceIdsAbleToDelete.addAll( serviceIdsAbleToDeleteList );
        }
        //System.debug( LoggingLevel.Error, 'xxx serviceIdsForDelete: ' + serviceIdsAbleToDelete );
        List<String> serviceIdsToRemove = new List<String>();
        for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( sm.checked && serviceIdsAbleToDelete.contains( sm.recordId ) ) {
                serviceIdsToRemove.add( sm.recordId );
            }
        }
        if( pwm.removeServiceItems( serviceIdsToRemove, activeChangeOrderId ) == false ) {
            addMessage( 'Error while deleting service Item.' );
        }
        /*for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( sm.checked ) {
                sm.checked = false;
            }
        }*/
        serviceIdsForMultiAction = null;
    }

    public String whereToMoveDestination { set; get; } // MRS 6931
    public void moveServicesBetweenTables() {
        Set<String> serviceIdsAbleToMove = new Set<String>();
        if( !String.isEmpty( serviceIdsForMultiAction ) ) {
            List<String> serviceIdsAbleToMoveList = serviceIdsForMultiAction.split(';');
            serviceIdsAbleToMove.addAll( serviceIdsAbleToMoveList );
        }
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        Map<Id, ServiceModel> idToAlternativeServiceMap = new Map<Id, ServiceModel>();
        for(ServiceModel sm : pwm.alternativeChangeOrders[0].serviceModels) {
            idToAlternativeServiceMap.put(sm.serviceItemRecord.Id, sm);
        }
        for ( String serviceModelID : serviceIdsAbleToMove ) { //MRS 7134
            Service_Item__c si = new Service_Item__c (Id = serviceModelID, Is_Alternative__c = whereToMoveDestination == 'MoveToServicesTable' ? false : true );
            if(proposal.isPhase__c && !si.Is_Alternative__c) {
                if(String.isBlank(idToAlternativeServiceMap.get(serviceModelID).phaseId)) {
                    addMessage('Please populate the Phase field in all services that you\'d like to move.');
                    return;
                } else {
                    si.Phase__c = idToAlternativeServiceMap.get(serviceModelID).phaseId;
                }
            }
            serviceItemsToUpdate.add(si);
        }
        try {
            UPSERT serviceItemsToUpdate;
        } catch ( DMLException e ) {
            addMessage( 'Error while moving Service(s).' );
        }
        populateServiceModels(false);
        serviceIdsForMultiAction = null;
    }

    public Boolean isPhasesPanelShown { get { if( isPhasesPanelShown == null ) isPhasesPanelShown = false; return isPhasesPanelShown; } set; }

    public PageReference showPhasesOutputPanel() {
        String showPhasesPanel = ApexPages.currentPage().getParameters().get('showPhasesPanel');
        if( showPhasesPanel == '1' )
            isPhasesPanelShown = true;
        else
            if( showPhasesPanel == '0' )
                isPhasesPanelShown = false;
            else
                isPhasesPanelShown = !isPhasesPanelShown;
        return null;
    }

    public transient Boolean enableStep2Summary;
    public Boolean getEnableStep2Summary() {
        return ProposalWizardServices.enableStep2Summary( proposal, getIsCZAnalyst(), getIsPS(), getIsAdmin() );
    }

    public transient Boolean isCZSpesialistRequired;
    public Boolean getIsCZSpesialistRequired() {
        return ProposalWizardServices.isCZSpesialistRequired( proposal );
    }

    public transient Boolean isCZAssignmentVisible;
    public Boolean getIsCZAssignmentVisible() {
        String region = !String.isBlank( proposal.Id ) ? ( proposal.Region__c ) : ( '' );
        return ( getIsAdmin() ||
                 ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW &&
                   getIsCZAnalyst() && !String.isBlank( currentUserRoleName ) &&
                   currentUserRoleName.contains( UserServices.ROLE_CZ_MANAGER) &&
                   !String.isBlank( region ) && currentUserRoleName.contains( region ) ) );
    }

    public transient Boolean isSIPSAssignmentVisible;
    public Boolean getIsSIPSAssignmentVisible() {
        return ( getIsAdmin() ||
                 ( profileName.contains(UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER) && getIsSaveButtonVisible() ) &&
                 proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_REVIEW );
    }

    public String noteBody { get; set; }

    public transient Boolean isNoteBodyEmpty;
    public Boolean getIsNoteBodyEmpty() {
        return String.isBlank(this.noteBody);
    }

    public transient Boolean canUseSendToCZSpecialistButton;
    public Boolean getCanUseSendToCZSpecialistButton() {
        return ( ( proposal.Is_Draft__c && !String.isBlank(proposal.sowScopeOfWork__c ) ) || !proposal.Is_Draft__c ) &&
               !String.isBlank(noteBody) &&
               !String.isBlank(proposal.Billing_Company_Name__c) &&
               !String.isBlank(proposal.Address__c) &&
               //!getFloorWrapperList().isEmpty() && //checking on page
               !String.isBlank(String.valueOf(proposal.Expected_Construction_Start_Date__c));
    }

    public transient Boolean canUseCreateServicesButton;
    public Boolean getCanUseCreateServicesButton() {
        return !String.isBlank(proposal.sowScopeOfWork__c) &&
               !String.isBlank(proposal.Billing_Company_Name__c) &&
               !String.isBlank(proposal.Address__c) &&
               //!getFloorWrapperList().isEmpty() && //checking on page
               !String.isBlank(String.valueOf(proposal.Expected_Construction_Start_Date__c));
    }

    //MRS-6915
    public String primaryCInstructions {set; get;}
    public String billingCInstructions {set; get;}
    public String accountingCInstructions {set; get;}
    public String buildingInstructions {set; get;}
    public String billingInstructions {set; get;}

    public String changeCoStatusCoId { get; set { if( String.isBlank( value ) ) changeCoStatusCoId = null; else changeCoStatusCoId = value; } }
    public String changeCoStatusNewStatus { get; set; }
    public Boolean changeCoStatusDisableFollowUps { get; set; }
    public Boolean changeCoStatusIsLightDoc { get; set; }
    public Boolean doCompletenessChecks { get; set; } //used in Proposal and CO functionality

    public PageReference changeCOStatus() {
        return changeCOStatus( true );
    }

    public PageReference changeCOStatus( Boolean doBillingTriggerChecks ) {
        if( changeCoStatusDisableFollowUps != null ) {
            pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Disable_Followups__c = changeCoStatusDisableFollowUps;
            changeCoStatusDisableFollowUps = null;
        }

        if( changeCoStatusNewStatus == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                        if(String.isBlank(pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord.Change_Order_Sender__c)) { // MRS 7151
                                pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord.Change_Order_Sender__c = UserInfo.getUserId();
            }
                        // MRS 7056
            if( pwm.changeOrderModelMap.get( changeCoStatusCoId ).hasNonBillableWithoutReason ) {
                addMessage( 'You must indicate the reason for the non-billable services on this proposal/change order before you can send it.' );
                return null;
            }
            showAdditionalToCcMessage = !pwr.isAdditionalToAndCcValid();
            if( showAdditionalToCcMessage ) {
                setCurrentStep('4');
                return null;
            } else {
                setCurrentStep();
            }
        } else {
            showAdditionalToCcMessage = false;
        }

        String oldStatus = pwm.changeOrderModelMap.get( changeCoStatusCoId ).status;
		if(oldStatus == ChangeOrderServices.STATUS_PENDING_CLIENT && changeCoStatusNewStatus != oldStatus) { //MRS 7386
			proposal.List_of_Attached_Docs__c = '';
			PreventTwiceExecution.proposalFirstRun = false;
			UPSERT new Proposal__c(Id = pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord.Proposal__c, List_of_Attached_Docs__c = '');
		}
        if( changeCoStatusNewStatus == oldStatus ) {
            Id contactToId = pwr.addAdditionalToAndCc( proposal );
            try {
                if( complete( false ) == null ) {
                    addMessage( 'Error saving Proposal' );
                    return null;
                }
                /*UPDATE new Proposal__c( Id = proposal.Id,
                                        Additional_To__c = proposal.Additional_To__c,
                                        Additional_Cc__c = proposal.Additional_Cc__c );*/
                Change_Order__c changeOrderUpdateItem = new Change_Order__c( Id = changeCoStatusCoId );
                pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.UseDocusign__c = proposal.UseDocusign__c;
                changeOrderUpdateItem.UseDocusign__c = proposal.UseDocusign__c;
                if( !String.isBlank( String.ValueOf( pwm.dummyChangeOrder.Reminder_for_Creator__c ) ) || emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY ) {
                    if ( !String.isBlank( String.ValueOf( pwm.dummyChangeOrder.Reminder_for_Creator__c ) ) ){
                        changeOrderUpdateItem.Reminder_for_Creator__c = pwm.dummyChangeOrder.Reminder_for_Creator__c;
                    }
                    if ( emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY ){
                        changeOrderUpdateItem.Follow_Ups_Count__c = pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Follow_Ups_Count__c == null ? 1 : pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Follow_Ups_Count__c + 1;
                        changeOrderUpdateItem.Last_Follow_Up_Date__c = DateTime.now();
                    }
                    pwm.dummyChangeOrder.Reminder_for_Creator__c = null;
                }
                UPDATE changeOrderUpdateItem;

                List<Deposit_Invoice__c> depositInvoices = DepositInvoiceServices.manageDepositInvoices( proposal, pwm.notApprovedChangeOrders );
                DepositInvoiceServices.createDepositInvoicePdf( depositInvoices );
                doCreatePdf = true;
                if( emailType != DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY ) {
                    ProposalWizardServices.setChangeOrderDocumentType( pwm, changeCoStatusCoId, changeCoStatusIsLightDoc );
                    RosterEmailJunctionServices.changeRosterEmailJunctionType( changeCoStatusIsLightDoc, changeCoStatusCoId );
                } else {
                    changeCoStatusIsLightDoc = pwm.changeOrderModelMap.get( Id.valueOf( changeCoStatusCoId ) ).changeOrderRecord.Document_Type__c == ChangeOrderServices.CO_DOCUMENT_TYPE_LIGHT;
                }
            } catch( DMLException dmlEx ) {
                changeCoStatusCoId = null;
                changeCoStatusNewStatus = null;
                doCompletenessChecks = null;
                emailType = null;
                doCreatePdf = false;
                changeCoStatusIsLightDoc = null;
                addMessage( 'Error saving Proposal Recipients' );
                return null;
            }
        /*MRS-5559 Skip everything below if user re-sends CO to client (old status == new status)*/ //follow-up, resend
        } else {
            if( doCompletenessChecks == true ) {
                for( ChangeOrderModel coModelItem : pwm.notApprovedChangeOrders ) {
                    if( coModelItem.changeOrderRecord.Id == changeCoStatusCoId ) {
                        if( coModelItem.getIsMaxCompleteness() ) {
                            break;
                        } else {
                            addMessage( 'Your changes have not been saved. Please make sure all mandatory fields on all steps are filled out.' );
                            return null;
                        }
                    }
                }
            }
            rejectionReasonMessageNotification = '';
            rejectionReasonPanelView = false;
            if( !String.isBlank( changeCoStatusNewStatus ) ) {
                if( String.isBlank(noteBody) && (changeCoStatusNewStatus == ChangeOrderServices.STATUS_CANCELED ) ) {
                    rejectionReasonPanelView = true;
                    rejectionReasonMessageNotification = 'Please provide a reason for cancelling this Change Order';
                    changeCoStatusCoId = null;
                    changeCoStatusNewStatus = null;
                    doCompletenessChecks = null;
                    changeCoStatusIsLightDoc = null;
                    return null;
                } else {
                    rejectionReasonPanelView = false;
                    if( filterAndSaveNotes( proposal.Id ) == false ) {
                        addMessage( 'Error Adding Note for canceled Change Order.' );
                        changeCoStatusCoId = null;
                        changeCoStatusNewStatus = null;
                        doCompletenessChecks = null;
                        changeCoStatusIsLightDoc = null;
                        return null;
                    } else {
                        cleanUpCurrentNote();
                    }
                }
            }

            if( doBillingTriggerChecks &&
                changeCoStatusNewStatus == ChangeOrderServices.STATUS_APPROVED &&
                proposal.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !proposal.Interval__c ) {
                Boolean hasAtLeastOneTaskWithNonZeroPercentage = false;
                List<Task_Item__c> taskItemsWithZeroPercentage = new List<Task_Item__c>();
                for( Task_Item__c ti : ProposalWizardServices.getDeletedTaskItemsInChangeOrderModel( pwm.notApprovedChangeOrders, changeCoStatusCoId ).values() ) {
                    if( ti.Billing_Percentage__c > 0 ) {
                        hasAtLeastOneTaskWithNonZeroPercentage = true;
                        break;
                    } else {
                        ti.Billing_Trigger__c = false;
                        ti.Billing_Percentage__c = null;
                        taskItemsWithZeroPercentage.add( ti );
                    }
                }
                if( hasAtLeastOneTaskWithNonZeroPercentage ) {
                    PageReference pr = new PageReference( '/apex/RedirectBillingTriggers' );
                    pr.getParameters().put('p', proposal.Id );
                    pr.getParameters().put('co', changeCoStatusCoId );
                    pr.setRedirect( true );
                    return pr;
                } else {
                    try {
                        UPDATE taskItemsWithZeroPercentage;
                    } catch( Exception e ) {
                        addMessage( e.getMessage() );
                        return null;
                    }
                }
            }

			checkAndShowNotificationAboutPO(); //MRS 7402

            Savepoint sp_changeCOStatus = Database.setSavePoint();
            try {
                try {
                    if( changeCoStatusNewStatus == ChangeOrderServices.STATUS_APPROVED || changeCoStatusNewStatus == ChangeOrderServices.STATUS_CANCELED ) {
                        cancelPurchaseOrderAction();
                    }
                    if( pwm.changeCOStatus( changeCoStatusCoId, changeCoStatusNewStatus, oldStatus, getFloorWrapperList() ) == false ) {
                        throw new ErrorException('Error changing status of Change Order.');
                    }
                } catch( Exception e ) {
                    Database.rollback( sp_changeCOStatus );
                    addMessage( e.getMessage() );
                    return null;
                }
                updateReimbursableAndDiscountData();
                Id contactToId = pwr.addAdditionalToAndCc( proposal );
                UPDATE new Proposal__c( Id = proposal.Id,
                                        Sales_Tax__c = proposal.Sales_Tax__c,
                                        Total_Service_Amount__c = proposal.Total_Service_Amount__c,
                                        Cost__c = proposal.Cost__c,
                                        Additional_To__c = proposal.Additional_To__c, //MRS-6548
                                        Discounted_Total_Service_Amount__c = pwm.changeOrderTotalsMap.get('Subtotal').get('Original').setScale(2)-
                                                      pwm.changeOrderTotalsMap.get('Discount').get('Original').setScale(2),
                                        Additional_Cc__c = proposal.Additional_Cc__c );
                UPDATE new Project_Profile__c( Id = proposal.Project_Profile__c,
                                               Total_Service_Amount__c = proposal.Total_Service_Amount__c,
                                               Cost__c = proposal.Cost__c,
                                               Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey() );

                setCurrentStep('3');
                if( changeCoStatusNewStatus == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                    if( complete( false ) == null ) {
                        throw new ErrorException('Can not update Proposal Data.');
                    }
                    List<Deposit_Invoice__c> depositInvoices = DepositInvoiceServices.manageDepositInvoices( proposal, pwm.notApprovedChangeOrders );
                    DepositInvoiceServices.createDepositInvoicePdf( depositInvoices );
                    doCreatePdf = true;
                    ProposalWizardServices.setChangeOrderDocumentType( pwm, changeCoStatusCoId, changeCoStatusIsLightDoc );
                }
				if((changeCoStatusNewStatus == ChangeOrderServices.STATUS_PASSED_INT_REVIEW || changeCoStatusNewStatus == ChangeOrderServices.STATUS_FAILED_INT_REVIEW)
					&& profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST) { //MRS 7507
					ProposalWizardServices.sendEmailNotificationToInternalReviewer(null, pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord, 
																										pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Internal_Reviewer__c);
				}
            } catch (exception e) {
                addMessage( e.getMessage() );
                pwm.changeOrderModelMap.get( changeCoStatusCoId ).status = oldStatus;
                changeCoStatusCoId = null;
                emailType = null;
                doCreatePdf = false;
                changeCoStatusIsLightDoc = null;
                Database.rollback( sp_changeCOStatus );
            } finally {
                doCompletenessChecks = null;
                if(getIsOptimalView() && (changeCoStatusNewStatus == ChangeOrderServices.STATUS_APPROVED || changeCoStatusNewStatus == ChangeOrderServices.STATUS_CANCELED)) { //MRS 7355 7411
                    changeCoStatusNewStatus = null;
                    PageReference pr = new PageReference('/apex/ProposalWizard');
                    pr.getParameters().put('id', proposal.Id);
                    pr.getParameters().put('step', '3');
                    pr.setRedirect(true);
                    return pr;
                }
                changeCoStatusNewStatus = null;
            }
        }
        return null;
    }

	public void checkAndShowNotificationAboutPO() { //MRS 7402
		if(changeCoStatusNewStatus == ChangeOrderServices.STATUS_APPROVED && proposal.PO_Required__c && pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord.Id != null && proposal.Billing_Company_Name__c != null) {
			Boolean anyServiceDoNotHavePoAndPoHasCapacity = false;
			Proposal__c intProposal = [SELECT Id, (SELECT Purchase_Order__c, Total_Discounted_Price__c FROM Service_Items__r WHERE Change_Order__c = :pwm.changeOrderModelMap.get(changeCoStatusCoId).changeOrderRecord.Id),
													(SELECT Unallocated_Balance__c FROM Purchase_Orders__r) FROM Proposal__c WHERE Id =: proposal.Id];
			for(Service_Item__c si : intProposal.Service_Items__r) {
				if(si.Purchase_Order__c == null) {
					for(Purchase_Order__c po : intProposal.Purchase_Orders__r) {
						if(po.Unallocated_Balance__c >= si.Total_Discounted_Price__c) { //MRS 7583
							anyServiceDoNotHavePoAndPoHasCapacity = true;
							break;
						}
					}
				}
			}
			if(anyServiceDoNotHavePoAndPoHasCapacity) {
				Account billingCompany = [SELECT PO_NOT_required_for_Change_Order__c, PO_NOT_required_for_Change_Orders_under__c FROM Account WHERE Id = :proposal.Billing_Company_Name__c LIMIT 1];
				if(!billingCompany.PO_NOT_required_for_Change_Order__c
					&& (billingCompany.PO_NOT_required_for_Change_Orders_under__c == null
						|| billingCompany.PO_NOT_required_for_Change_Orders_under__c < pwm.changeOrderModelMap.get(changeCoStatusCoId).getServicesTotalDiscounted())) {

					

					addMessage( 'The change order services awarded require a PO. Please note there is a PO on file with unallocated funds.', 'Info' );
				}
			}
		}
	}

    public void cancelChangeOrderInternalReviewer() {
        pwm.cleanUpDummyChangeOrder();
    }

    public String retrieveReimbursableQuantity {
        get {
            if( proposal.Reimbursable_Percentage__c == null ) proposal.Reimbursable_Percentage__c = 15;
            return String.valueOf( (proposal.Reimbursable_Percentage__c).setScale(0) );
        }
        set {
            if( !value.isNumeric() ) value = '10';
            Integer valueInt = Integer.valueOf( Decimal.valueOf(value).setScale(0) );
            if( valueInt < 0 ) valueInt = 0;
            if( valueInt > 100 ) valueInt = 100;
            /*valueInt = Integer.valueOf((Math.round(Decimal.valueOf(valueInt)/5))*5);*/
            proposal.Reimbursable_Percentage__c = valueInt;
            value = String.valueOf(valueInt);
        }
    }

    public String retrieveDiscountQuantity {
        get {
            if( proposal.Discount_Percentage__c == null ) proposal.Discount_Percentage__c = 10;
            return String.valueOf((proposal.Discount_Percentage__c).setScale(0));
        }
        set {
            if( !value.isNumeric() ) value = '10';
            Integer valueInt = Integer.valueOf(Decimal.valueOf(value).setScale(0));
            if( valueInt < 0 ) valueInt = 0;
            if( valueInt > 100 ) valueInt = 100;
            proposal.Discount_Percentage__c = valueInt;
            value = String.valueOf(valueInt);
        }
    }

    public void recalculateReimbursables() {
        if( proposal.Reimbursable_Percentage__c == null ) proposal.Reimbursable_Percentage__c = 15;
        if(  !proposal.Reimbursable_Items_Basis__c ) proposal.Reimbursable_Percentage__c = 15;
        updateReimbursableAndDiscountData();
    }

    public void recalculateDiscount() {
        if( proposal.Discount_Percentage__c == null ) proposal.Discount_Percentage__c = 10;
        if(  !proposal.Apply_Discount__c ) proposal.Discount_Percentage__c = 10;
        updateReimbursableAndDiscountData();
    }

    private void updateReimbursableAndDiscountData() {
        pwm.updateReimbursableAndDiscountData( proposal, ProposalWizardServices.getBillingAccountForFields( proposal ) );
        proposal.Sales_Tax__c = (pwm.changeOrderTotalsMap.get(ChangeOrderServices.SERVICES_SALES_TAX_TITLE)).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER);
        proposal.Total_Service_Amount__c = (pwm.changeOrderTotalsMap.get(ChangeOrderServices.SERVICES_SUBTOTAL_TITLE)).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER);
        proposal.Cost__c = (pwm.changeOrderTotalsMap.get(ChangeOrderServices.SERVICES_COST_OF_SERVICES_TITLE)).get(ChangeOrderServices.ORIGINAL_CHANGE_ORDER);
    }

    public transient String totalNotesText;
    public String getTotalNotesText() {
        return NotesServices.joinNotes( NotesServices.retrieveNotes( proposal.Id ) );
    }

    @RemoteAction
    public static void saveGeneralChangeOrderNotes( String changeOrderId, String notesValue ) {
        if( changeOrderId != null && changeOrderId instanceOf Id ) {
            UPSERT new Change_Order__c( Id = changeOrderId, General_Change_Order_Notes__c = notesValue );
        }
    }

    public transient Map<Id, Change_Order__c> changeOrderInfo;
    public Map<Id, Change_Order__c> getChangeOrderInfo() {
        Map<Id, Change_Order__c> changeOrderInfoTemp = new Map<Id, Change_Order__c>();
        if( proposal.Id != null && proposal.Is_Change_Order__c ) {
            changeOrderInfoTemp = new Map<Id, Change_Order__c>( [ SELECT Id, Name, Number__c, General_Change_Order_Notes__c,
                                                                         Approved_Date__c, Change_Request_Date__c, CreatedDate
                                                                  FROM Change_Order__c
                                                                  WHERE Proposal__c = : proposal.Id ] );
        }
        changeOrderInfoTemp.put( null, new Change_Order__c( General_Change_Order_Notes__c = '' ) );
        return changeOrderInfoTemp;
    }

    public transient Map<Id, Document> documentInfo;
    public Map<Id, Document> getDocumentInfo() {
        Map<Id, Document> documentInfoTemp = new Map<Id, Document>();
        if( pwm.documentWrapperList != null && !pwm.documentWrapperList.isEmpty() ) {
            for( DocumentWrapper documentWrapper : pwm.documentWrapperList ) {
                documentInfoTemp.put( documentWrapper.documentId, new Document() );
            }
            documentInfoTemp.putAll( new Map<Id, Document>( ProposalWizardServices.getDocumentsFromDirectory() ) ); //MRS 7335
        }
        return documentInfoTemp;
    }

    @RemoteAction
    public static void clearTemporaryInstructionsFields( String proposalId ) { //MRS 6915
        if( !String.isBlank( proposalId ) ) {
            UPSERT new Proposal__c( Id = proposalId,
                                    T_Primary_Client_Instructions__c = '',
                                    T_Billing_Client_Instructions__c = '',
                                    T_Accounting_Client_Instructions__c = '',
                                    T_Billing_Instructions__c = '' );
        }
    }

    // MRS - 6915
    public void saveInstructions() {
        if( !String.isBlank( proposal.Id ) ) {
            if( String.isBlank( primaryCInstructions ) &&
                String.isBlank( billingCInstructions ) &&
                String.isBlank( accountingCInstructions ) &&
                String.isBlank( buildingInstructions ) &&
                String.isBlank( billingInstructions ) ) {
                return;
            } else {
                Proposal__c newProp = new Proposal__c( Id = proposal.Id,
                                                       Primary_Client_Instructions__c = primaryCInstructions,
                                                       Billing_Client_Instructions__c = billingCInstructions,
                                                       Accounting_Client_Instructions__c = accountingCInstructions,
                                                       Building_Instructions__c = buildingInstructions,
                                                       Billing_Instructions__c = billingInstructions,
                                                       T_Primary_Client_Instructions__c = '',
                                                       T_Billing_Client_Instructions__c = '',
                                                       T_Accounting_Client_Instructions__c = '',
                                                       T_Billing_Instructions__c = '');
                primaryCInstructions = '';
                billingCInstructions = '';
                accountingCInstructions = '';
                buildingInstructions = '';
                billingInstructions = '';
                try {
                    PreventTwiceExecution.proposalFirstRun = false;
                    UPSERT newProp;
                    PreventTwiceExecution.proposalFirstRun = true; //7106
                } catch( DMLException e ) {
                    addMessage( 'Error during saving updating proposal instructions.' );
                }
            }
        }
    }

    // MRS - 6915
    @RemoteAction
    public static void checkAndUpdateInstructions( String idx, String htmlId, String value, String primaryCompanyId, String billingCompanyId, String accountCompanyId, String buildingId ) {
        Proposal__c prop = [ SELECT Primary_Client_Instructions__c, T_Primary_Client_Instructions__c, Primary_Company_Name__c,
                                    Billing_Client_Instructions__c, T_Billing_Client_Instructions__c, Billing_Company_Name__c,
                                    Accounting_Client_Instructions__c, T_Accounting_Client_Instructions__c, Accounting_Contact_Company__c,
                                    Building_Instructions__c, Address__c, Billing_Instructions__c, T_Billing_Instructions__c
                             FROM Proposal__c
                             WHERE Id = : idx ];

        if( htmlId.equals( 'ProposalWizardPage:theForm:primaryCInstructions' ) ) {
            if( !String.isBlank( primaryCompanyId ) && !primaryCompanyId.equals( '000000000000000' ) ) {
                if( primaryCompanyId.equals( prop.Primary_Company_Name__c ) ) {
                    if( String.isBlank( value ) && !String.isBlank( prop.Primary_Client_Instructions__c ) ) {
                        prop.Primary_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.Primary_Client_Instructions__c = value;
                    }
                    prop.Primary_Client_Instructions__c += dateStampUser();
                } else {
                    if( String.isBlank( value ) && !String.isBlank( prop.T_Primary_Client_Instructions__c ) ) {
                        prop.T_Primary_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.T_Primary_Client_Instructions__c = value;
                    }
                    prop.T_Primary_Client_Instructions__c += dateStampUser();
                }
                UPSERT prop;
            }
        }

        if( htmlId.equals( 'ProposalWizardPage:theForm:billingCInstructions' ) ) {
            if( !String.isBlank( billingCompanyId ) && !billingCompanyId.equals( '000000000000000' ) ) {
                if( billingCompanyId.equals( prop.Billing_Company_Name__c ) ) {
                    if( String.isBlank( value ) && !String.isBlank( prop.Billing_Client_Instructions__c ) ) {
                        prop.Billing_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.Billing_Client_Instructions__c = value;
                    }
                    prop.Billing_Client_Instructions__c += dateStampUser();
                } else {
                    if( String.isBlank( value ) && !String.isBlank( prop.T_Billing_Client_Instructions__c ) ) {
                        prop.T_Billing_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.T_Billing_Client_Instructions__c = value;
                    }
                    prop.T_Billing_Client_Instructions__c += dateStampUser();
                }
                UPSERT prop;
            }
        }

        if( htmlId.equals( 'ProposalWizardPage:theForm:accountingCInstructions' ) ) {
            if( !String.isBlank(accountCompanyId) && !accountCompanyId.equals( '000000000000000' ) ) {
                if( accountCompanyId.equals( prop.Accounting_Contact_Company__c ) ) {
                    if( String.isBlank( value ) && !String.isBlank( prop.Accounting_Client_Instructions__c ) ) {
                        prop.Accounting_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.Accounting_Client_Instructions__c = value;
                    }
                    prop.Accounting_Client_Instructions__c += dateStampUser();
                } else {
                    if( String.isBlank( value ) && !String.isBlank( prop.T_Accounting_Client_Instructions__c ) ) {
                        prop.T_Accounting_Client_Instructions__c = '<DELETED> ';
                    } else {
                        prop.T_Accounting_Client_Instructions__c = value;
                    }
                    prop.T_Accounting_Client_Instructions__c += dateStampUser();
                }
                UPSERT prop;
            }
        }

        if( htmlId.equals( 'ProposalWizardPage:theForm:buildingInstructions' ) ) {
            if( !String.isBlank( buildingId ) && !buildingId.equals( '000000000000000' ) ) {
                if( String.isBlank( value ) && !String.isBlank( prop.Building_Instructions__c ) ) {
                    prop.Building_Instructions__c = '<DELETED> ';
                } else {
                    prop.Building_Instructions__c = value;
                }
                prop.Building_Instructions__c += dateStampUser();
                UPSERT prop;
            }
        }

        if( htmlId.equals( 'ProposalWizardPage:theForm:billingInstructions' ) ) {
            if( !String.isBlank( billingCompanyId ) ) {
                if( billingCompanyId.equals( prop.Billing_Company_Name__c ) ) {
                    if( String.isBlank( value ) && !String.isBlank( prop.Billing_Instructions__c ) ) {
                        prop.Billing_Instructions__c = '<DELETED> ';
                    } else {
                        prop.Billing_Instructions__c = value;
                    }
                    prop.Billing_Instructions__c += dateStampUser();
                } else {
                    if( String.isBlank( value ) && !String.isBlank( prop.T_Billing_Instructions__c ) ) {
                        prop.T_Billing_Instructions__c = '<DELETED> ';
                    } else {
                        prop.T_Billing_Instructions__c = value;
                    }
                    prop.T_Billing_Instructions__c += dateStampUser();
                }
                UPSERT prop;
            }
        }
    }

    // MRS - 6915
    public transient List<String> proposalOwnInstructions;
    public List<String> getProposalOwnInstructions() {
        Proposal__c prop;
        List<String> res = new List<String> { '', '', '', '', ''};

        List<TableDataWrapper> outerInstructions = getProposalInstructions();

        if( !String.isEmpty( proposal.Id ) ) {
            prop = [ SELECT Primary_Client_Instructions__c, T_Primary_Client_Instructions__c, Primary_Company_Name__c,
                            Billing_Client_Instructions__c, T_Billing_Client_Instructions__c, Billing_Company_Name__c,
                            Accounting_Client_Instructions__c, T_Accounting_Client_Instructions__c, Accounting_Contact_Company__c,
                            Building_Instructions__c, Address__c, Billing_Instructions__c, T_Billing_Instructions__c
                     FROM Proposal__c
                     WHERE Id = : proposal.Id ];
        }

        if( prop != null ) {
            if( !String.isBlank( proposal.Address__c ) ) {
                if( String.isBlank( prop.Building_Instructions__c ) ) {
                    res.set( 0, String.isBlank( outerInstructions.get(0).recordName ) ? '' : outerInstructions.get(0).recordName + dateStampBasic() );
                } else {
                    res.set( 0, prop.Building_Instructions__c );
                }
            }

            if( !String.isBlank( proposal.Primary_Company_Name__c ) ) {
                if( proposal.Primary_Company_Name__c.equals( prop.Primary_Company_Name__c ) ) {
                    if( String.isBlank( prop.Primary_Client_Instructions__c ) ) {
                        res.set( 1, String.isBlank( outerInstructions.get(1).recordName ) ? '' : outerInstructions.get(1).recordName + dateStampBasic() );
                    } else {
                        res.set( 1, prop.Primary_Client_Instructions__c );
                    }
                } else {
                    if( String.isBlank( prop.T_Primary_Client_Instructions__c ) ) {
                        res.set( 1, String.isBlank( outerInstructions.get(1).recordName ) ? '' : outerInstructions.get(1).recordName + dateStampBasic() );
                    } else {
                        res.set( 1, prop.T_Primary_Client_Instructions__c );
                    }
                }
            }

            if( !String.isBlank( proposal.Billing_Company_Name__c ) ) {
                if( proposal.Billing_Company_Name__c.equals( prop.Billing_Company_Name__c ) ) {
                    if( String.isBlank( prop.Billing_Client_Instructions__c ) ) {
                        res.set( 2, String.isBlank( outerInstructions.get(2).recordName ) ? '' : outerInstructions.get(2).recordName + dateStampBasic() );
                    } else {
                        res.set( 2, prop.Billing_Client_Instructions__c );
                    }
                    if( String.isBlank( prop.Billing_Instructions__c ) ) {
                        res.set( 4, String.isBlank( outerInstructions.get(4).recordName ) ? '' : outerInstructions.get(4).recordName + dateStampBasic() );
                    } else {
                        res.set( 4, prop.Billing_Instructions__c );
                    }
                } else {
                    if( String.isBlank( prop.T_Billing_Client_Instructions__c ) ) {
                        res.set( 2, String.isBlank( outerInstructions.get(2).recordName ) ? '' : outerInstructions.get(2).recordName + dateStampBasic() );
                    } else {
                        res.set( 2, prop.T_Billing_Client_Instructions__c );
                    }
                    if( String.isBlank( prop.T_Billing_Instructions__c ) ) {
                        res.set( 4, String.isBlank( outerInstructions.get(4).recordName ) ? '' : outerInstructions.get(4).recordName + dateStampBasic() );
                    } else {
                        res.set( 4, prop.T_Billing_Instructions__c );
                    }
                }
            }

            if( !String.isBlank( proposal.Accounting_Contact_Company__c ) ) {
                if( proposal.Accounting_Contact_Company__c.equals( prop.Accounting_Contact_Company__c ) ) {
                    if( String.isBlank( prop.Accounting_Client_Instructions__c ) ) {
                        res.set( 3,String.isBlank( outerInstructions.get(3).recordName ) ? '' : outerInstructions.get(3).recordName + dateStampBasic() ); // accountingC instructions
                    } else {
                        res.set( 3, prop.Accounting_Client_Instructions__c );
                    }
                } else {
                    if( String.isBlank( prop.T_Accounting_Client_Instructions__c ) ) {
                        res.set( 3, String.isBlank( outerInstructions.get(3).recordName ) ? '' : outerInstructions.get(3).recordName + dateStampBasic() ); // accountingC instructions
                    } else {
                        res.set( 3, prop.T_Accounting_Client_Instructions__c );
                    }
                }
            }
        } else {
            if( !String.isBlank( proposal.Primary_Company_Name__c ) ) {
                Account tempA = [ SELECT Proposal_Instructions__c
                                  FROM Account
                                  WHERE Id = : proposal.Primary_Company_Name__c ];
                if( !String.isBlank( tempA.Proposal_Instructions__c ) ) {
                    res.set( 1, tempA.Proposal_Instructions__c );
                }
            }
            if( !String.isBlank( proposal.Billing_Company_Name__c ) ) {
                Account tempA = [ SELECT Proposal_Instructions__c, Billing_Instructions__c
                                  FROM Account
                                  WHERE Id = : proposal.Billing_Company_Name__c ];
                if( !String.isBlank( tempA.Proposal_Instructions__c ) ) {
                    res.set( 2, tempA.Proposal_Instructions__c );
                }
                if( !String.isBlank( tempA.Billing_Instructions__c ) ) {
                    res.set( 2, tempA.Billing_Instructions__c );
                }
            }
            if( !String.isBlank( proposal.Accounting_Contact_Company__c ) ) {
                Account tempA = [ SELECT Proposal_Instructions__c
                                  FROM Account
                                  WHERE Id = : proposal.Accounting_Contact_Company__c ];
                if( !String.isBlank( tempA.Proposal_Instructions__c ) ) {
                    res.set( 3, tempA.Proposal_Instructions__c );
                }
            }
            if( !String.isBlank( proposal.Address__c ) ) {
                Building__c tempB = [ SELECT Proposal_Instructions__c
                                      FROM Building__c
                                      WHERE Id = : proposal.Address__c ];
                if( !String.isBlank( tempB.Proposal_Instructions__c ) ) {
                    res.set( 0, tempB.Proposal_Instructions__c );
                }
            }
        }
        return res;
    }

    public transient List<TableDataWrapper> proposalInstructions;
    public List<TableDataWrapper> getProposalInstructions() {
        List<TableDataWrapper> proposalInstructions = new List<TableDataWrapper>{ new TableDataWrapper( '' ), //[0] = building instructions
                                                                                  new TableDataWrapper( '' ), //[1] = primary client instructions
                                                                                  new TableDataWrapper( '' ), //[2] = billing client Proposal instructions
                                                                                  new TableDataWrapper( '' ), //[3] = accounting client instructions G-300 MRS-6845
                                                                                  new TableDataWrapper( '' ), //[4] = billing client Billing instructions G-300 MRS-6845
                                                                                  new TableDataWrapper( '' )};//[5] = billing account A_R_coordinator__r.Name G-300 MRS-6845
        if( !String.isBlank( proposal.Address__c ) ) { //building instructions
            List<Building__c> buildings = [ SELECT Id, Proposal_Instructions__c
                                            FROM Building__c
                                            WHERE Id = : proposal.Address__c ];
            if( !buildings.isEmpty()) {
                proposalInstructions[0].recordId = buildings[0].Id; //G300 MRS 6845
                proposalInstructions[0].recordName = buildings[0].Proposal_Instructions__c;
            }
        }
                                                                                                                    //G300 MRS-6845
        Set<String> queryIds = new Set<String>{ proposal.Primary_Company_Name__c, proposal.Billing_Company_Name__c, proposal.Accounting_Contact_Company__c}; //primary & billing instructions
        queryIds.remove( null );
        if( !queryIds.isEmpty() ) {                                 //G300 MRS-6845
            for( Account acc : [ SELECT Id, Proposal_Instructions__c, Billing_Instructions__c, A_R_coordinator__r.Name
                                 FROM Account
                                 WHERE Id IN : queryIds ] ) {
                if( acc.Id == proposal.Primary_Company_Name__c ) {
                    proposalInstructions[1].recordId = acc.Id;
                    proposalInstructions[1].recordName = acc.Proposal_Instructions__c;
                }
                if( acc.Id == proposal.Billing_Company_Name__c ) {
                    proposalInstructions[2].recordId = acc.Id;
                    proposalInstructions[2].recordName = acc.Proposal_Instructions__c;
                    proposalInstructions[4].recordId = acc.Id;
                    proposalInstructions[4].recordName = acc.Billing_Instructions__c;
                    proposalInstructions[5].recordName = acc.A_R_coordinator__r.Name;
                }
                if( acc.Id == proposal.Accounting_Contact_Company__c ) {
                    proposalInstructions[3].recordId = acc.Id;
                    proposalInstructions[3].recordName = acc.Proposal_Instructions__c;
                }
            }
        }
        return proposalInstructions;
    }

    public transient List<TableDataWrapper> buildingProjectsData;
    public List<TableDataWrapper> getBuildingProjectsData() {
        List<TableDataWrapper> buildingProjects = new List<TableDataWrapper>();
        if( proposal.Address__c != null ) {
            for( Project_Profile__c project : [ SELECT Id, Name, Project_Name__c
                                                FROM Project_Profile__c
                                                WHERE Building__c = : proposal.Address__c
                                                ORDER BY CreatedDate DESC LIMIT 1000] ) { // hot fix list of projects done to building exceed 1000
                buildingProjects.add( new TableDataWrapper( project.Id, project.Project_Name__c, project.Name ) );
            }
        }
        return buildingProjects;
    }

    public class TableDataWrapper {
        public String recordId { get; set; }
        public String recordName { get; set; }
        public String recordNumber { get; set; }

        public TableDataWrapper( String recordId, String recordName, String recordNumber ) {
            this.recordId = recordId;
            this.recordName = String.isBlank( recordName ) ? 'N/A' : recordName;
            this.recordNumber = recordNumber;
        }

        public TableDataWrapper( String recordName ) {
            this.recordName = recordName;
        }
    }

    public void projectAddressAction() {
        building = ProposalWizardServices.getBuildingById(proposal.Address__c);
        isBuildingUpdated = true;
        if( String.isBlank( proposal.Id ) ) {
            saveProposalIfNotExists();
        } else {
            upsert new Proposal__c (id=proposal.Id, Building_Instructions__c=''); // MRS 6915
            saveDraft();
        }
    }

    public transient String buildingHint;
    public String getBuildingHint() {
        if( building != null ) {
            List<String> items = new List<String>();
            if( building.Is_MTA__c ) items.add( 'Transit Authority' );
            if( building.Is_Landmark__c ) items.add( 'Landmark' );
            if( building.Little_E_Designation__c ) items.add( '\'Little E\' Designation' );
            if( building.Loft_Board_Authority__c ) items.add( 'Loft Board Authority' );
                        if(building.Flood_Plain__c) items.add('Flood Plain'); // MRS 7171
            return String.join( items, ', ' );
        }
        return '';
    }

    public transient Boolean showBuildingHint; /*MRS-5972*/
    public Boolean getShowBuildingHint() {
        return proposal.Is_Draft__c &&
               ( proposal.Status__c != ProposalServices.PROPOSAL_STATUS_IN_REVIEW &&
                 proposal.Status__c != ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) &&
               building != null &&
               ( building.Is_MTA__c ||
                 building.Is_Landmark__c ||
                 building.Little_E_Designation__c ||
                 building.Loft_Board_Authority__c ||
                                 building.Flood_Plain__c) && // MRS 7171
               ( getIsPS() || getIsAM() || getIsPartner() );
    }

    public void updateProjectLocation() {
        String buildingId = ApexPages.currentPage().getParameters().get('buildingId');
        proposal.Address__c = Id.valueOf(buildingId);
        rightPanelView= 'Notes';
        projectAddressAction();
    }

    public void changeRightPanelToNotes() {
        rightPanelView= 'Notes';
        serviceTemplatesForNewServices = null; //MRS 7335
    }

    public void changeRightPanelToReimbursable() {
        rightPanelView = 'Reimbursable';
        reimbursableToCreate = new Additional_Reimbursable__c();
        try {
            saveProposalIfNotExists();
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return;
        }
    }

    public void changeRightPanelToFloor() {
        rightPanelView = 'Floor'; //MRS 7324
    }

    public Boolean checkSendCopyToEmails(Boolean isSync) {
        try {
            saveProposalIfNotExists();
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return false;
        }
        Boolean emailValid = false;
        if( String.isNotBlank(proposal.Send_Copy_To__c) ) {
            List<String> sendCopyToEmails = proposal.Send_Copy_To__c.split(';');
            Pattern p = Pattern.compile( '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
            for(String emailAddress : sendCopyToEmails) {
                emailAddress = emailAddress.trim();
                Matcher m = p.matcher(emailAddress);
                if( !m.matches()) {
                    addMessage( 'Invalid email address: ' + emailAddress );
                    return emailValid;
                }
            }
        }
        try {
            if( isSync && !String.isEmpty( proposal.Id ) ) {
                UPDATE proposal;
            }
            emailValid = true;
        } catch(Exception ex) {
            addMessage( 'Error saving proposal.' );
            emailValid = false;
        }
        return emailValid;
    }

    public String emailsToCC { get; set; }

    public void showSendCopyTo() {
        if(!checkSendCopyToEmails(true)) { return; }
        rightPanelView= 'sendToCopy';
        iFrameRightPageReference = new PageReference('/apex/SendCopyToCC');
        iFrameRightPageReference.getParameters().put('proposalId', proposal.Id);
        iFrameRightPageReference.getParameters().put('primaryCompany', proposal.Primary_Company_Name__c);
        iFrameRightPageReference.getParameters().put('billingCompany', proposal.Billing_Company_Name__c);
        iFrameRightPageReference.getParameters().put('accountingContact', proposal.Send_Invoices_to_Different_Contact__c ? proposal.Accounting_Contact_Company__c : null);

    }

    public void populateReminderForCreatorFields() { proposal.Send_Reminder_To_Creator__c = proposal.Proposal_Send_Reminder__c; }
    public void cancelSendCopyTo() { rightPanelView = 'Notes'; }
    public void updateSendCopyTo() { rightPanelView = 'Notes'; this.proposal.Send_Copy_To__c = this.emailsToCC; }
    public transient Boolean isMaxCompleteness;
    public Boolean getIsMaxCompleteness() { return getCompleteness() == (String.isBlank(String.valueOf(proposal.Id)) ? 100 : 100); }

    public transient Integer completeness;
    public Integer getCompleteness() {
        return ProposalWizardServices.getCompleteness( ProposalWizardServices.getProposalRequiredFields( getIsMi3(), proposal.CreatedDate, proposal.Is_Draft__c ),
                                                       proposal,
                                                       !getCurrentFloorsList().isEmpty(),
                                                       new List<ServiceModel>() );
    }

    public transient String proposalRfpRequestDate;
    public String getProposalRfpRequestDate() {
        return ( proposal.Proposal_RFP_Request_Date__c != null
               ? proposal.Proposal_RFP_Request_Date__c.format('M/d/yyyy K:m a')
               : null );
    }
    public void setProposalRfpRequestDate( String dateString ) {}

    public transient String proposalExpirationDate;
    public String getProposalExpirationDate() {
        return ( proposal.Proposal_Expiration_Date__c !=null
               ? proposal.Proposal_Expiration_Date__c.format('M/d/yyyy K:m a')
               : null );
    }
    public void setProposalExpirationDate( String dateString ) {}

    public PageReference iFrameDocumentsPageReference { get; set; }
    public PageReference iFrameDrawingsPageReference { get; set; }
    public PageReference iFrameDrawingsFileListPageReference { get; set; }
    public String currentStorageFolder { get; set; }

    public void manageFileUpload() { manageFileUpload( true ); }
    public void manageFileUpload( Boolean isInsert ) {
        PageReference pr;
        PageReference prFileList;
        Id parentObjectId;

        if( !String.isBlank(proposal.Id)) {
            parentObjectId = proposal.Id;
        } else {
            if( isInsert ) {
                try {
                    UPSERT proposal;
                    proposal = ProposalWizardServices.getProposal( proposal.Id );
                    parentObjectId = proposal.Id;
                } catch( Exception ex ) {
                    addMessage( 'Error saving proposal.' );
                    return;
                }
            }
        }

        List<LStore__Stored_Document__c> storedDocsFolderDb = [SELECT RecordType.DeveloperName, RecordTypeId, LStore__Related_Object_Id__c, LStore__File_Name__c
                                                               FROM LStore__Stored_Document__c
                                                               WHERE RecordTypeId = : StoredDocumentServices.FOLDER_RECORD_TYPE_ID
                                                                 AND Related_Object_Id__c = : String.valueOf(parentObjectId)];
        List<LStore__Stored_Document__c> storedDocsFolder = new List<LStore__Stored_Document__c>();
        for( LStore__Stored_Document__c doc : storedDocsFolderDb ) {
            if( doc.LStore__File_Name__c == currentStorageFolder ) {
                storedDocsFolder.add( doc );
                break;
            }
        }
        if( storedDocsFolder.isEmpty() ) {
            LStore__Stored_Document__c newDocsFolder = new LStore__Stored_Document__c( RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
                                                                                       LStore__File_Name__c = currentStorageFolder,
                                                                                       LStore__Related_Object_Id__c = String.valueOf(parentObjectId),
                                                                                       LStore__Keywords__c = currentStorageFolder );
            if( isInsert ) {
                try {
                    INSERT newDocsFolder;
                    storedDocsFolder.add( newDocsFolder );
                } catch( Exception ex ) {
                    addMessage( 'Error creating documents folder.' );
                    return;
                }
            } else {
                if( currentStorageFolder == StoredDocumentServices.DOCUMENTS_FILE_TYPE ) proposal.Provided_Documents__c = false;
                if( currentStorageFolder == StoredDocumentServices.DRAWINGS_FILE_TYPE  ) proposal.Provided_Drawings__c  = false;
            }
        }

        pr = new PageReference( !String.isBlank(proposal.Id) ? '/apex/StoredDocsInlineProposalNoFolders' : null );
        if( !storedDocsFolder.isEmpty() ) {
            pr.getParameters().put('fid', storedDocsFolder[0].Id);
        }
        pr.getParameters().put('eid', String.valueOf(parentObjectId).left(15));
        pr.getParameters().put('disableActions', disableInputs || getIsChangeOrder() ? 'true' : 'false');

        prFileList  = new PageReference( !String.isBlank(proposal.Id) ? '/apex/ProposalDrawingsStoredDocs' : null );
        prFileList.getParameters().put('parentId', String.valueOf(parentObjectId).left(15));

        if( currentStorageFolder == StoredDocumentServices.DOCUMENTS_FILE_TYPE && proposal.Provided_Documents__c ) {
            pr.getParameters().put('fileTypesName', StoredDocumentServices.DOCUMENTS_FILE_TYPE);
            iFrameDocumentsPageReference = pr;
        } else if( currentStorageFolder == StoredDocumentServices.DRAWINGS_FILE_TYPE && proposal.Provided_Drawings__c ) {
            pr.getParameters().put('fileTypes', '*.dwg; *.dxf; *.pdf; *.jpg; *.tif; *.tiff');
            pr.getParameters().put('fileTypesName', StoredDocumentServices.DRAWINGS_FILE_TYPE);

            iFrameDrawingsPageReference = pr;
            iFrameDrawingsFileListPageReference = prFileList;
        }
    }

    public transient PageReference iFrameAdditionalDocumentsPageReference;
    public PageReference getIFrameAdditionalDocumentsPageReference() {
        Id folderId = StoredDocumentServices.getAdditionalDocumentsFolder( proposal.Id ).Id;
        PageReference pr = new PageReference( !String.isBlank( proposal.Id ) ? '/apex/StoredDocsInlineProposalRfpNoFolders' : null );
        pr.getParameters().put('fid', folderId);
        pr.getParameters().put('eid', String.valueOf( proposal.Id ).left(15));
        pr.getParameters().put('disableActions', !getIsAttachingFilesEnabled() /*disableInputs || getIsChangeOrder()*/ ? 'true' : 'false');
        return pr;
    }

    private Id createDeleteAdditionalDocumentsFolder( Boolean dmlAllowed ) {
        LStore__Stored_Document__c documentFolder;
        if( proposal.Additional_Documents__c == true ) {
            if( dmlAllowed ) {
                try {
                    saveProposalIfNotExists();
                } catch( Exception e ) {
                    addMessage( e.getMessage() );
                    return null;
                }
            }
            if( !String.isBlank( proposal.Id ) ) {
                documentFolder = StoredDocumentServices.getAdditionalDocumentsFolder( proposal.Id );
                if( documentFolder.Id == null ) {
                    if( dmlAllowed ) {
                        LStore__Stored_Document__c newDocsFolder = new LStore__Stored_Document__c( RecordTypeId = StoredDocumentServices.FOLDER_RECORD_TYPE_ID,
                                                                                                   LStore__File_Name__c = StoredDocumentServices.RFP_DOCUMENTS_FOLDER,
                                                                                                   LStore__Related_Object_Id__c = String.valueOf( proposal.Id ),
                                                                                                   LStore__Keywords__c = StoredDocumentServices.RFP_DOCUMENTS_FOLDER );
                        try {
                            INSERT newDocsFolder;
                            documentFolder = newDocsFolder;
                        } catch(Exception ex) {
                            addMessage( 'Error creating ' + StoredDocumentServices.RFP_DOCUMENTS_FOLDER + ' folder.' );
                            return null;
                        }
                    } else {
                        proposal.Additional_Documents__c = false;
                    }
                }
                return documentFolder.Id;
            } else {
                proposal.Additional_Documents__c = false;
            }
        } else {
            if( dmlAllowed ) {
                documentFolder = StoredDocumentServices.getAdditionalDocumentsFolder( proposal.Id );
                if( documentFolder.Id != null && documentFolder.LStore__Stored_Documents__r.isEmpty() ) {
                    try {
                        DELETE documentFolder;
                    } catch(Exception ex) {
                        addMessage( 'Error deleting ' + StoredDocumentServices.RFP_DOCUMENTS_FOLDER + ' folder.' );
                        return null;
                    }
                }
            }
        }
        return null;
    }

    public void createDeleteAdditionalDocumentsFolder() {
        createDeleteAdditionalDocumentsFolder( true );
    }

    public Boolean isDisableAdditionalDocuments { get; set;}
    public Boolean isDisableDrawings { get; set;}
    public List<LStore__Stored_Document__c> drawings {
        get {
            if(drawings == null) {
                drawings = new List<LStore__Stored_Document__c>();
            }
            return drawings;
        } set;
    }
    public List<LStore__Stored_Document__c> additionalDocuments {
        get {
            if(additionalDocuments == null) {
                additionalDocuments = new List<LStore__Stored_Document__c>();
            }
            return additionalDocuments;
        } set;
    }

    public void isDisableDocumentsCheckbox() {
        if( String.isNotBlank( proposal.Id ) ) {
            isDisableAdditionalDocuments = false;
            isDisableDrawings = false;
            additionalDocuments = ProposalServices.storedDocsOrFolder(proposal.Id, StoredDocumentServices.FOLDER_RECORD_TYPE_ID, StoredDocumentServices.DOCUMENTS_FILE_TYPE);

            if( !additionalDocuments.isEmpty() ) {
                proposal.Provided_Documents__c = true;
                isDisableAdditionalDocuments = true;
                //manageFileUpload(false);
            }
            drawings = ProposalServices.storedDocsOrFolder(proposal.Id, StoredDocumentServices.FOLDER_RECORD_TYPE_ID, StoredDocumentServices.DRAWINGS_FILE_TYPE);
            if(drawings.size() > 0) {
                proposal.Provided_Drawings__c = true;
                isDisableDrawings = true;
                //manageFileUpload(false);
            }
        }
    }

    public void setServiceTypesOverride() {
        String overrideType = '';
        if( proposal.Expected_Construction_Start_Date__c != null ) {
            if( proposal.Expected_Construction_Start_Date__c < Date.Today().addDays(56) ) {
                overrideType = 'Professional';
            } else {
                overrideType = 'Standard';
            }
        }
        try {
            proposal.sow_ir_override__c = overrideType;
            proposal.sow_id_override__c = overrideType;
            proposal.sow_er_override__c = overrideType;
            proposal.sow_sp_override__c = overrideType;
            proposal.sow_sm_override__c = overrideType;

            if( String.isBlank( proposal.Id ) ) {
                saveProposalIfNotExists();
            } else {
                saveDraft();
            }
        } catch( exception e ) {
            addMessage( e.getMessage() );
            return;
        }
    }

    private Boolean filterAndSaveNotes( Id parentId ) {
        if( !NotesServices.filterAndSaveNotes( parentId,
                                               NotesServices.retrieveNotes( proposal.Id, false ),
                                               new Note( parentId = proposal.Id, Title = 'Proposal Note' ),
                                               noteBody ) ) {
            addMessage( 'Error saving notes.' );
            return false;
        }
        cleanUpCurrentNote();
        return true;
    }
    private void cleanUpCurrentNote() {
        noteBody = '';
    }

    private Boolean updateProposalFloors( Id proposalId, List<FloorWrapper> currentFloorWrapperList ) {
        if( !currentFloorWrapperList.isEmpty() ) {
            List<Floor__c> floorsToUpdate = new List<Floor__c>();
            for( FloorWrapper floorWrapper : currentFloorWrapperList ) {
                floorWrapper.floor.Proposal__c = proposalId;
                floorsToUpdate.add( floorWrapper.floor );
            }
            try {
               UPDATE floorsToUpdate;
            } catch( Exception e ) {
                addMessage( 'Error updating floors.' );
                return false;
            }
        }
        return true;
    }

    public void updateProposalMunicipalAgency() {
        if( !pwm.originalChangeOrders.isEmpty() ) {
            for( ServiceModel sm : pwm.originalChangeOrders[0].serviceModels ) {
                if( String.isNotBlank( sm.municipalAgency ) ) {
                    proposal.Municipal_Agency_ID__c = sm.municipalAgency;
                    break;
                }
            }
        }
    }

    public PageReference complete() {
        return complete( true );
    }

    //MRS-6915
    private static String dateStampUser() {
        return Datetime.now().format('\' - \'MM/dd/yyyy hh:mm:ss\' - \'') + userinfo.getName();
    }

    public PageReference complete( Boolean updateDepositInvoices ) {
        saveInstructions(); //MRS-6915

        setCurrentStep();
        if( proposal.Proposal_Type__c == 'Standard' ) proposal.RFP_Attachments__c = '';
        if( String.isBlank(proposal.Id) ) {
            populateServiceModels( false );
        }
        updateReimbursableAndDiscountData();
        Boolean isProposalIdPopulated = !String.isBlank(proposal.Id);
        updateProposalMunicipalAgency();
        if( doCompletenessChecks == true &&
            ( ProposalWizardServices.getCompleteness( ProposalWizardServices.getProposalRequiredFields( getIsMi3(), proposal.CreatedDate, proposal.Is_Draft__c ),
                                                      proposal,
                                                      true, //hasFloors
                                                      pwm.serviceModels.values() ) < 100 ) ) {
            addMessage( 'Your changes have not been saved. Please make sure all mandatory fields on all steps are filled out.' );
            return null;
        }

        List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
        if( currentFloorWrapperList.isEmpty() ) {
            addMessage( 'At least one floor should exist in the floors list.' );
            return null;
        } else {
            proposal.Floor_s__c = FloorServices.updateFloorsString( proposal.Id, proposal.Project_Profile__c, currentFloorWrapperList, false );
        }
        if( proposal.Is_Draft__c && proposal.Is_Floors_To_Services__c && !pwm.checkIfAllServicesAreConnectedToFloors(proposal.Id) ){
            addMessage( ProposalWizardServices.SERVICE_JUNCTIONS_SHOULD_BE_POPULATED_MESSAGE );
            return null;
        }
        if( proposal.Send_Invoices_to_Different_Contact__c && (String.isBlank(proposal.Accounting_Contact_Company__c) || String.isBlank(proposal.Accounting_Contact__c)) ) {
            addMessage( 'Accounting Contact Company and Accounting Contact are required.' );
            return null;
        }
        if( String.isBlank(String.valueOf(proposal.Expected_Construction_Start_Date__c)) ) {
            addMessage( 'Expected Construction Start dates is required' );
            return null;
        }
        if( !proposal.Send_Invoices_to_Different_Contact__c ) {
            proposal.Accounting_Contact_Company__c = proposal.Billing_Company_Name__c;
            proposal.Accounting_Contact__c = proposal.Billing_Company_Contact__c;
        }
        if( String.isBlank(proposal.Fulfillment_Office__c) ) {
            addMessage( 'Fulfillment Office field is required.' );
            return null;
        }
        if( String.isBlank(proposal.Description__c) ) {
            addMessage( 'Description field is required.' );
            return null;
        }
        if( !pwr.isRosterValid() ) {
            //deletePrimaryOrBillingCompanyContact();
            addMessage( 'Recipients: All the \'Type\' have to be filled.' );
            return null;
        }
        if(proposal.IsPhase__c && getPhaseList().size() <= 0) {
            addMessage( 'If \'Multiple Phase Project\' selected phase cannot be empty.' );
            return null;
        }
        if( !String.isEmpty(proposal.Frequency__c) && String.isEmpty(proposal.Billing_day__c) ) {
            addMessage( 'If \'Frequency\' is selected, \'Billing day\' cannot be empty.' );
            return null;
        }
        if( proposal.Billing_Method__c == 'Installment' && String.isEmpty(proposal.Frequency__c) ) {
            addMessage( 'If \'Billing Method\' is \'Installment\', \'Frequency\' cannot be empty.' );
            return null;
        }
        if( proposal.Billing_Method__c == 'Percentage' && proposal.Interval__c && String.isEmpty(proposal.Frequency__c) ) {
            addMessage( 'If \'Billing Method\' is \'Percentage\' and \'Interval\' is selected, \'Frequency\' cannot be empty.' );
            return null;
        }
        if( !checkSeparatePhases() ) { //MRS 7330
            return null;
        }
        if( proposal.Send_Invoices_to_Different_Contact__c && proposal.Billing_Company_Contact__c == proposal.Accounting_Contact__c ) {
            addMessage( 'Billing Company Contact cannot be equal to Accounting Contact.' );
            return null;
        }
        if( String.isBlank( proposal.Project_Team__c ) ) {
            proposal.FREP__c = null;
        }


        //G300 MRS-6548
        proposal.Discounted_Total_Service_Amount__c = pwm.changeOrderTotalsMap.get('Subtotal').get('Original').setScale(2)-
                                                      pwm.changeOrderTotalsMap.get('Discount').get('Original').setScale(2);

        System.Savepoint sp_complete = Database.setSavepoint();
        if( !checkSendCopyToEmails(false) ) return null;
        Boolean proposalWasNotCreatedYet;
        try {
            /*if( proposal.Project_Profile__c != null ) { //MRS-7049
                proposal.Proposal_Type__c = ProposalServices.PROPOSAL_TYPE_CHANGE_ORDER;
            }*/
            if( getIsMi3() ) {
                proposal.Is_Mi3_Project_Created__c = true;
            }
            Id projectTeamTempId = proposal.Project_Team__c;
            if( !getIsMi3() && proposal.Project_Profile__c == null ) {
                proposal.Project_Team__c = null; //disallow creation of project when save button is clicked (project team trigger)
            }
            proposalWasNotCreatedYet = proposal.Id == null;
            proposal.Is_Draft__c = false;

            if( !String.isBlank( proposal.Project_Profile__c ) ) {
                Proposal__c newProposal = new Proposal__c( Id = proposal.Id ); //MRS-6978
                SObject sObjectNewProposal = (SObject) newProposal;
                SObject sObjectProposal = (SObject) proposal;

                Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get( 'Proposal__c' ).getDescribe().Fields.getMap();
                Set<String> fieldsNames = new Set<String>();
                if( fieldsMap != null ) {
                    for( Schema.SObjectField fieldsMapItem : fieldsMap.values() ) {
                        Schema.DescribeFieldResult fieldDescription = fieldsMapItem.getDescribe();
                        if( fieldDescription.isCreateable() ) {
                            fieldsNames.add( fieldDescription.getName().toLowerCase() );
                        }
                    }
                }

                for( String fieldName : ProposalWizardServices.C_FIELDS_TO_GET_FROM_PROPOSAL) {
                    if( fieldsNames.contains( fieldName.toLowerCase() ) ) {
                        if( ( fieldName.equals( 'FREP__c' ) && frepId == proposal.FREP__c ) ||
                            ( fieldName.equals( 'Production_Manager__c' ) && productionManagerId == proposal.Production_Manager__c ) ||
                            ( fieldName.equals( 'Project_Team__c' ) && projectTeamId == proposal.Project_Team__c ) ) {
                            continue;
                        }
                        sObjectNewProposal.put( fieldName, sObjectProposal.get( fieldName ) );
                    }
                }
                UPSERT newProposal;
            } else {
                UPSERT proposal;
            }
            proposal.Project_Team__c = projectTeamTempId;
            if( !updateProposalFloors( proposal.Id, currentFloorWrapperList ) ||
                /*!updateProposalPurchaseOrders( proposal.Id ) ||*/ //MRS-7378
                !createPhasesAndServiceItems( false, null ) ||
                !filterAndSaveNotes( proposal.Id ) ||
                !saveProjectRoster() ||
                !savePhase() ||
                !pwm.saveChangeOrders( null ) ) {
                    Database.rollback( sp_complete );
                    if( proposalWasNotCreatedYet ) proposal.Id = null;
                    return null;
            }
            if( updateDepositInvoices == true ) {
                DepositInvoiceServices.manageDepositInvoices( proposal, pwm.notApprovedChangeOrders );
            }
            if( proposal.Project_Profile__c != null ) { //sync proposal fields with project
                Project_Profile__c profileToUpdate = new Project_Profile__c( Id = proposal.Project_Profile__c,
                    Billing_Company_Name__c = proposal.Billing_Company_Name__c,
                    Billing_Company_Contact__c = proposal.Billing_Company_Contact__c,
                    Accounting_Contact_Company__c = proposal.Accounting_Contact_Company__c,
                    Accounting_Contact__c = proposal.Accounting_Contact__c,
                    Primary_Company_Name__c = proposal.Primary_Company_Name__c,
                    Primary_Company_Contact__c = proposal.Primary_Company_Contact__c,
                    Account_Executive__c = proposal.Account_Executive__c,
                    Partner__c = proposal.Partner__c,
                    Salesperson__c = proposal.Salesperson__c,
                    Client_Project__c = proposal.Client_Project__c,
                    Fulfillment_Office__c = proposal.Fulfillment_Office__c,
                    Delivery_Method__c = proposal.Delivery_Method__c,
                    Send_Copy_To__c = proposal.Send_Copy_To__c,
                    Frequency__c = proposal.Frequency__c,
                    Invoice_Format__c = proposal.Invoice_Format__c,
                    Separate_Reimbursables__c = proposal.Separate_Reimbursables__c,
                    No_Document_Shredding__c = proposal.No_Document_Shredding__c,
                    No_Met_Data_Scanning__c = proposal.No_Met_Data_Scanning__c,
                    No_Messenger_Fedex__c = proposal.No_Messenger_Fedex__c,
                    Billing_Method__c = proposal.Billing_Method__c,
                    Interval__c = proposal.Interval__c,
                    Billing_day__c = proposal.Billing_day__c,
                    Quarterly_Month__c = proposal.Quarterly_Month__c,
                    Separate_Phases__c = proposal.Separate_Phases__c,
                    Avoid_Validation_Rules__c = MilroseDevHelper.getUniqueKey() );
                //MRS-6966
                if( frepId != proposal.FREP__c ) {
                    profileToUpdate.FREP__c = proposal.FREP__c;
                }
                if( productionManagerId != proposal.Production_Manager__c ) {
                    profileToUpdate.Production_Manager__c = proposal.Production_Manager__c;
                }
                UPDATE profileToUpdate;
                pwr = new ProposalWizardRoster( proposal, pwm ); //reselect rosters after updating project data
            }
            //MRS-6966 MRS 7133
            projectTeamId = proposal.Project_Team__c;
            productionManagerId = proposal.Production_Manager__c;
            frepId = proposal.FREP__c;

         } catch( System.Dmlexception dmlEx ) {
            Database.rollback(sp_complete);
            //setCurrentStep('1');
            for ( Integer dmlExIndex = 0; dmlExIndex < dmlEx.getNumDml(); dmlExIndex++ ) {
                String dmlError = dmlEx.getDmlMessage( dmlExIndex ).contains('duplicate value found: Client_Project__c') ? 'Proposal with the same Client Project # already exists.' : dmlEx.getDmlMessage( dmlExIndex );
                if( ApexPages.hasMessages() ) {
                    for( ApexPages.Message messageItem : ApexPages.getMessages() ) {
                        if( messageItem.getSummary() != dmlEx.getDmlMessage( dmlExIndex ) ) {
                            addMessage( 'Error creating/updating proposal: ' + dmlError );
                        }
                    }
                } else {
                    addMessage( 'Error creating/updating proposal: ' + dmlError );
                }
            }
            if( proposalWasNotCreatedYet == true ) {
                proposal.Id = null;
            }
            return null;
        }
        if( reloadPage ) { return ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition ); } else { reloadPage = null; return null; }
    }

    public String currentStep { get; set; }
    public Boolean reloadPage { get { if( reloadPage == null ) reloadPage = true; return reloadPage; } set; }

    public PageReference saveDraft() {

        setCurrentStep();
        if( !checkSeparatePhases() ) { //MRS 7330
            return null;
        }
        System.Savepoint sp_saveDraft = Database.setSavepoint();
        updateReimbursableAndDiscountData();
        updateProposalMunicipalAgency();
        //G300 MRS-6548
        proposal.Discounted_Total_Service_Amount__c = pwm.changeOrderTotalsMap.get('Subtotal').get('Original').setScale(2)-
                                                      pwm.changeOrderTotalsMap.get('Discount').get('Original').setScale(2);

        boolean saveDraftFirstTime = String.isBlank(proposal.Id) ? true : false;
        try {
            List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
            if( currentFloorWrapperList.isEmpty() ) {
                proposal.Floor_s__c = '';
            } else {
                proposal.Floor_s__c = FloorServices.updateFloorsString( proposal.Id, proposal.Project_Profile__c, currentFloorWrapperList, false );
            }
            if( !proposal.Send_Invoices_to_Different_Contact__c ) {
                proposal.Accounting_Contact_Company__c = proposal.Billing_Company_Name__c;
                proposal.Accounting_Contact__c = proposal.Billing_Company_Contact__c;
            }
            UPSERT proposal;
            if( !filterAndSaveNotes( proposal.Id ) ) { Database.rollback(sp_saveDraft); return null; }
            if( !createPhasesAndServiceItems( false, null ) ) { Database.rollback(sp_saveDraft); return null; }
            if( !saveProjectRoster() ) { Database.rollback(sp_saveDraft); return null; }

            //MRS-6915
            if(saveDraftFirstTime) {
                Proposal__c prop = new Proposal__c(id=proposal.Id);
                if(!String.isBlank(primaryCInstructions)) prop.Primary_Client_Instructions__c = primaryCInstructions;
                if(!String.isBlank(billingCInstructions)) prop.Billing_Client_Instructions__c = billingCInstructions;
                if(!String.isBlank(accountingCInstructions)) prop.Accounting_Client_Instructions__c = accountingCInstructions;
                if(!String.isBlank(buildingInstructions)) prop.Building_Instructions__c = buildingInstructions;
                if(!String.isBlank(billingInstructions)) prop.Billing_Instructions__c = billingInstructions;
                upsert prop;
                primaryCInstructions = '';
                billingCInstructions = '';
                accountingCInstructions = '';
                buildingInstructions = '';
                billingInstructions = '';
            } else {
                saveInstructions();
            }


            if( reloadPage ) { return ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition ); } else { reloadPage = null; return null; }
        } catch( DMLException dmlEx ) {
            Database.rollback(sp_saveDraft);
            for( Integer dmlExIndex = 0; dmlExIndex < dmlEx.getNumDml(); dmlExIndex++ ) {
                String dmlError = dmlEx.getDmlMessage( dmlExIndex ).contains('duplicate value found: Client_Project__c') ? 'Proposal with the same Client Project # already exists.' : dmlEx.getDmlMessage( dmlExIndex );
                addMessage( 'Error saving proposal. ' + dmlError );
            }
            ErrorException.addLog( dmlEx, proposal, 'Wizard (' + String.valueOf( proposal.Id ) + '): Could not create Proposal (SaveDraft)', 'Wizard' );
            return null;
        }
        return null;
    }

    public PageReference close() {
        String prString;
        if( !String.isBlank( proposal.Id ) ) {
            prString = proposal.Id;
        } else {
            prString = Proposal__c.sObjectType.getDescribe().getKeyPrefix()+'/o';
        }
        PageReference pageReference = new PageReference('/' + prString);
        pageReference.setRedirect(true);
        return pageReference;
    }

    public String proposalStatus { get; set; }
    public PageReference changeProposalStatus() {
        // MRS 7056
        if( proposalStatus == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT && pwm.hasNonBillableWithoutReason == true ) {
            doCreatePdf = false;
            addMessage( 'You must indicate the reason for the non-billable services on this proposal/change order before you can send it.' );
            return null;
        }
        rejectionReasonMessageNotification = '';
        rejectionReasonPanelView = false;
        showAdditionalToCcMessage = false;
        String oldStatus = proposal.Status__c;
        String newStatus;
		Id internalReviewerBackup = proposal.Internal_Reviewer__c; //MRS 7507
        if( proposalStatus == 'Failed Internal Review' ) newStatus = ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW;
        else if( proposalStatus == 'Passed Internal Review' ) newStatus = ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW;
        else if( proposalStatus == 'Rejected' ) newStatus = ProposalServices.PROPOSAL_STATUS_REJECTED;
        else if( proposalStatus == 'Canceled' ) newStatus = ProposalServices.PROPOSAL_STATUS_CANCELLED;
        else if( proposalStatus == 'Not Awarded' ) newStatus = ProposalServices.PROPOSAL_STATUS_NOT_AWARDED;
        else if( proposalStatus == 'Awarded' ) newStatus = ProposalServices.PROPOSAL_STATUS_AWARDED;
        else if( proposalStatus == 'Passed Internal Review' ) newStatus = ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW;
        else if( proposalStatus == 'In Internal Review' ) newStatus = ProposalServices.PROPOSAL_STATUS_IN_REVIEW;
        else if( proposalStatus == 'Pending Client Approval' ) newStatus = ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT;
        else if( proposalStatus == 'C&Z Scope Review Complete' ) newStatus = ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE;
        else if( proposalStatus == 'Withdrawn' ) newStatus = ProposalServices.PROPOSAL_STATUS_WITHDRAWN;
        else if( proposalStatus == 'Change Order Requested' ) newStatus = ProposalServices.PROPOSAL_STATUS_CHANGE_ORDER_REQUESTED;
		if(oldStatus == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT && newStatus != oldStatus) proposal.List_of_Attached_Docs__c = ''; //MRS 7381
        if( !String.isBlank(newStatus) ) {
            updateAttachedDocuments();
            if( String.isBlank(noteBody) && (newStatus == ProposalServices.PROPOSAL_STATUS_NOT_AWARDED ||
                                             newStatus == ProposalServices.PROPOSAL_STATUS_CANCELLED ||
                                             newStatus == ProposalServices.PROPOSAL_STATUS_REJECTED ||
                                             newStatus == ProposalServices.PROPOSAL_STATUS_WITHDRAWN ||
                                             newStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW) ) {
                rejectionReasonPanelView = true;
                rejectionReasonMessageNotification = 'Please provide the reason for Proposal Rejection in the Notes section.';
                return null;
            } else {
                rejectionReasonPanelView = false;
            }
            System.Savepoint sp_changeProposalStatus = Database.setSavepoint();
            try {
                if( newStatus == ProposalServices.PROPOSAL_STATUS_AWARDED ) {
                    proposal.Status__c = newStatus;
                    proposal.Proposal_Awarded_Date__c = Date.today();
                    if( getIsExistAPSService() ) {
                        proposal.Assigner_OM__c = true;
                    }
                    if( getIsAllOSServices() ) {
                        proposal.Assigner_SS__c = true;
                        proposal.FREP__c = null;
                        proposal.Production_Manager__c = null;
                    }
                    UPDATE proposal;
                    if( filterAndSaveNotes( proposal.Id ) == false ) { Database.rollback(sp_changeProposalStatus); return null; }
                } else if( newStatus == ProposalServices.PROPOSAL_STATUS_PENDING_CLIENT ) {
                    showAdditionalToCcMessage = !pwr.isAdditionalToAndCcValid();
                    if( showAdditionalToCcMessage ) {
                        setCurrentStep('4');
                        return null;
                    } else {
                        setCurrentStep();
                    }
                    Id contactToId = pwr.addAdditionalToAndCc( proposal );
                    proposal.Proposal_Sent_Date__c = date.today();
                    proposal.Proposal_Expiration_Date__c = date.today().addMonths(6);//MRS-7279
                    proposal.Status__c = newStatus;
					if(String.isBlank(proposal.Proposal_Sender__c)) { // MRS 7151
						proposal.Proposal_Sender__c = UserInfo.getUserId();
					}
                    if( complete( false ) == null ) { proposal.Status__c = oldStatus; return null; }

                    UPSERT ProposalWizardServices.uniqueCombinationLastProposalPrice(pwm.serviceModels.values(), proposal).values();

                    //if( !proposal.No_Retainer__c && proposal.Retainer_Amount__c != null && proposal.Retainer_Amount__c > 0 ) {
                        try {
                            List<Deposit_Invoice__c> depositInvoices = DepositInvoiceServices.manageDepositInvoices( proposal, null );
                            DepositInvoiceServices.createDepositInvoicePdf( depositInvoices );
                            doCreatePdf = true;
                        } catch( dmlException ex ) {
                            doCreatePdf = false;
                            addMessage( 'Could not create (update) Deposit Invoice: ' + ex.getMessage() );
                            return null;
                        }
                    //}
                    return null;
                } else if( newStatus == ProposalServices.PROPOSAL_STATUS_IN_REVIEW) {
                    proposal.Status__c = newStatus;
                    if( complete() == null ) {
                        proposal.Status__c = oldStatus; return null;
                    }
                } else if( newStatus == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE) {
                    proposal.Status__c = newStatus;
                    if( String.isBlank(proposal.Id) ) {
                        if( complete() == null ) { proposal.Status__c = oldStatus; return null; }
                    } else {
                        if( saveDraft() == null ) { proposal.Status__c = oldStatus; return null; }
                    }
                } else if( newStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW ) {
                    Boolean isThisAssignedSIPSUser = getIsThisUserAssignedSIPSUser();
                    Id sipsCoordinatorBackup = proposal.SIPS_Coordinator__c;
                    Boolean partnerApprovalRequiredBackup = proposal.Partner_Approval_Required__c;
                    proposal.Status__c = newStatus;
                    proposal.Internal_Reviewer__c = null;
                    if( isThisAssignedSIPSUser ) proposal.SIPS_Coordinator__c = null;
                    proposal.Partner_Approval_Required__c = false;
                    if( complete() == null ) {
                        proposal.Status__c = oldStatus;
                        proposal.Internal_Reviewer__c = internalReviewerBackup;
                        proposal.SIPS_Coordinator__c = sipsCoordinatorBackup;
                        proposal.Partner_Approval_Required__c = partnerApprovalRequiredBackup;
                        return null;
                    }
                } else if( oldStatus == ProposalServices.PROPOSAL_STATUS_NEW) { //MRS 6835
                    proposal.Status__c = newStatus;
                    saveDraft();
                } else {
                    proposal.Status__c = newStatus;
                    if( complete() == null ) { proposal.Status__c = oldStatus; return null; }
                }
            } catch( DMLException dmlEx ) {
                proposal.Status__c = oldStatus;
                ErrorException.addLog( dmlEx, proposal, 'Wizard (' + String.valueOf( proposal.Id ) + '): Could not create Proposal to ' + newStatus + ' (changeProposalStatus)', 'Wizard' );
                if( newStatus == ProposalServices.PROPOSAL_STATUS_AWARDED && getIsAllOSServices() ) {
                    addErrorsWhenCreatingProject( dmlEx, false );
                } else {
                    addMessage( 'Error saving Proposal with status ' + newStatus );
                }
                Database.rollback(sp_changeProposalStatus);
                return null;
            }
			if((newStatus == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW || newStatus == ProposalServices.PROPOSAL_STATUS_PASSED_INTERNAL_REWIEW)
				&& profileName == UserServices.PROFILE_PROPOSAL_SPECIALIST) { //MRS 7507
				ProposalWizardServices.sendEmailNotificationToInternalReviewer(proposal, null, internalReviewerBackup);
			}
        }
        return ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition );
    }

    public String emailType { get; set { emailType = String.isBlank( value ) ? null : value; } }
    public void reSendPdf() {
        showAdditionalToCcMessage = false;
        showAdditionalToCcMessage = !pwr.isAdditionalToAndCcValid();
        if( showAdditionalToCcMessage ) {
            setCurrentStep('4');
        } else {
            setCurrentStep();
            Id contactToId = pwr.addAdditionalToAndCc( proposal );
            if( complete( false ) == null ) {
                addMessage( 'Error saving Proposal' );
                emailType = null;
                return;
            }
            try {
                if( emailType != DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY &&
                    ProposalWizardServices.getPdfType( pwm, null ) == ProposalWizardServices.PROPOSAL_DDP_NAME ) {
                    List<Deposit_Invoice__c> depositInvoices = DepositInvoiceServices.manageDepositInvoices( proposal, pwm.notApprovedChangeOrders );
                    DepositInvoiceServices.createDepositInvoicePdf( depositInvoices );
                }
            } catch( DMLException dmlEx ) {
                addMessage( 'Error updating Deposit Invoice.' );
                emailType = null;
                return;
            }
            try {
                //MRS-6295
                Proposal__c proposalToUpdateItem = new Proposal__c( Id = proposal.Id,
                                                                    Additional_To__c = proposal.Additional_To__c,
                                                                    Additional_Cc__c = proposal.Additional_Cc__c );
                if ( emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY ){
                    proposalToUpdateItem.Follow_Ups_Count__c = proposal.Follow_Ups_Count__c == null ? 1 : proposal.Follow_Ups_Count__c + 1;
                    proposalToUpdateItem.Last_Follow_Up_Date__c = DateTime.now();
                }
                UPDATE proposalToUpdateItem;
                proposal.Follow_Ups_Count__c = proposalToUpdateItem.Follow_Ups_Count__c;
                proposal.Last_Follow_Up_Date__c = proposalToUpdateItem.Last_Follow_Up_Date__c;
            } catch( DMLException dmlEx ) {
                addMessage( 'Error saving Proposal Recipients' );
                emailType = null;
            }
        }
    }

    public boolean doCreatePdf { get { if( doCreatePdf == null ) doCreatePdf = false; return doCreatePdf; } set; }
	public Boolean isFollowUp { get { if(isFollowUp == null) isFollowUp = false; return isFollowUp; } set; } //MRS 7406
    public void prepareProposalPdf() {
        doCreatePdf = false;
        changeCoStatusCoId = ProposalWizardServices.setChangeOrderIdForResendFromFooter( changeCoStatusCoId, emailType, pwm, changeCoStatusIsLightDoc );
        if( !ProposalWizardServices.doUseDocusign( proposal, changeCoStatusCoId, pwm ) ) {
            Id contactToId = pwr.addAdditionalToAndCc( proposal );

            deliveryMethodId = ProposalWizardServices.prepareProposalPDF( proposal,
                                                                          changeCoStatusCoId,
                                                                          ProposalWizardServices.getPdfType( pwm, changeCoStatusIsLightDoc ),
                                                                          ProposalWizardServices.getDeliveryMethodName( pwm, proposal, changeCoStatusCoId, contactToId, emailType ),
                                                                          pwm.documentWrapperList,
                                                                          true, false, isFollowUp ).get(1).get(0); //MRS 7406
        }
    }
    private Id deliveryMethodId;

    public PageReference sendProposalPdf() {
        Boolean hasErrors = false;
        Map<String, String> emailToNameForCc;
        Map<String, String> emailToNameForApprover;
        Boolean doUseDocusign = ProposalWizardServices.doUseDocusign( proposal, changeCoStatusCoId, pwm );
        if( doUseDocusign ) {
            emailToNameForCc = new Map<String, String>(); //is populated by memory reference if using docusign
            emailToNameForApprover = new Map<String, String>(); //is populated by memory reference if using docusign
        }
        Id contactToId = pwr.addAdditionalToAndCc( proposal, emailToNameForCc, emailToNameForApprover );

        try {
            if( doUseDocusign && emailType == DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY &&
                ( proposal.Is_Change_Order__c && !getHasPendingChangeOrders() ) ) {
                Throw new ErrorException( 'When using Docusign, there is no possibility to resend a document when there are no change orders that are in the pending client approval status' );
            }

            changeCoStatusCoId = ProposalWizardServices.setChangeOrderIdForResendFromFooter( changeCoStatusCoId, emailType, pwm, changeCoStatusIsLightDoc );


            /*if( //doUseDocusign &&
                  emailType == DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY ) {
                DocusignServices.voidEnvelopes( envelopeIds, DocusignServices.VOID_REASON_RESEND );
            }*/
            List<String> envelopeIds = DocusignServices.getEnvelopesFromDocusignStatusesForObject( proposal, new Change_Order__c( Id = changeCoStatusCoId ) );
            if( doUseDocusign && emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY && !envelopeIds.isEmpty() ) { //for docusign follow-ups resend an old envelope is exists
                DocusignServices.resendEnvelopes( envelopeIds );
            } else { //otherwise send a docusign envelope or a regular email with pdf, voiding old documents
                if( ( emailType == DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY || emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY ) && !envelopeIds.isEmpty() ) {
                    //if use docusign is unchecked, resend should void old envelopes; if not using, it still could have old envelopes if the use docusign checkbox was uncheched
                    //if not using docusign, follow-up should void old envelopes, since we will re-send them via e-mails
                    DocusignServices.voidEnvelopes( envelopeIds, DocusignServices.VOID_REASON_RESEND );
                }
                PageReference result = ProposalWizardServices.sendProposalPDF( proposal, changeCoStatusCoId, contactToId,
                                                                               emailToNameForApprover, emailToNameForCc,
                                                                               ProposalWizardServices.getPdfType( pwm, changeCoStatusIsLightDoc ),
                                                                               ProposalWizardServices.getDeliveryMethodName( pwm, proposal, changeCoStatusCoId, contactToId, emailType ),
                                                                               deliveryMethodId,
                                                                               pwm.documentWrapperList, isFollowUp);
            }

            if( String.isBlank( emailType ) || emailType == DDPEmailServices.EMAIL_RESEND_FUNCTIONALITY ) { //manage junctions when sending or resending to client
                List<Roster_Email_Junction__c> rosterJunctions = pwr.createRosterEmailJunctions( pwm,
                                                                                                 proposal,
                                                                                                 changeCoStatusCoId,
                                                                                                 true,
                                                                                                 ProposalWizardServices.enableCreateAutomaticFollowUps( proposal, changeCoStatusCoId, pwm, true, true ) );

                List<Id> filesAttachedAsUrl = ProposalWizardServices.prepareProposalPDF( proposal, null, null, ProposalWizardServices.getDeliveryMethodName( pwm, proposal, changeCoStatusCoId, contactToId, emailType ),
                                                                                         pwm.documentWrapperList, true, true, isFollowUp).get(0); // MRS-6807 MRS-7406
                if( rosterJunctions != null && !rosterJunctions.isEmpty() && filesAttachedAsUrl != null && !filesAttachedAsUrl.isEmpty() ) { //G300 MRS-6807
                    List<Roster_StoredDocument_Junction__c> storedDocumentJunctions = new List<Roster_StoredDocument_Junction__c>();
                    for( Roster_Email_Junction__c rosterJunction : rosterJunctions ) {
                        for( Id fileAttachedAsUrlId : filesAttachedAsUrl ) {
                            Roster_StoredDocument_Junction__c newStoredDocumentJunction = new Roster_StoredDocument_Junction__c();
                            newStoredDocumentJunction.Roster_Email_Junction__c = rosterJunction.id;
                            newStoredDocumentJunction.Stored_Document__c = fileAttachedAsUrlId;
                            storedDocumentJunctions.add( newStoredDocumentJunction );
                        }
                    }
                    UPSERT storedDocumentJunctions;
                }
            }

            if( emailType == DDPEmailServices.EMAIL_FOLLOWUP_FUNCTIONALITY && changeCoStatusCoId != null && pwm.changeOrderModelMap != null && pwm.changeOrderModelMap.containsKey( changeCoStatusCoId ) ){ //MRS-6295
                pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Follow_Ups_Count__c = pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Follow_Ups_Count__c != null
                                                                                                          ? pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Follow_Ups_Count__c + 1
                                                                                                          : 1;
            }
			isFollowUp = false; //MRS 7406
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            hasErrors = true;
        }
		
		if(doUseDocusign) ProposalWizardServices.setSentViaDocusignCheckBox(proposal.Id, changeCoStatusCoId); //MRS 7515

        emailType = null;
        changeCoStatusCoId = null;
        changeCoStatusNewStatus = null;
        doCompletenessChecks = null;
        deliveryMethodId = null;
        changeCoStatusIsLightDoc = null;
        return hasErrors ? null : ProposalWizardServices.returnToWizard( proposal, '', getMode(), formPosition );
    }



    public Boolean doSendChangeOrderPdf() {
        Boolean doSendChangeOrderPdf = !pwm.approvedChangeOrders.isEmpty();
        if( !doSendChangeOrderPdf ) {
            for( ChangeOrderModel co : pwm.notApprovedChangeOrders ) {
                if( co.status == ChangeOrderServices.STATUS_PENDING_CLIENT ) {
                    doSendChangeOrderPdf = true;
                    break;
                }
            }
        }
        return doSendChangeOrderPdf;
    }

    public transient Boolean enableSendProposalPdf;
    public Boolean getEnableSendProposalPdf() {
        return pwm.approvedChangeOrders.isEmpty() && pwm.notApprovedChangeOrders.isEmpty();
    }

    public Boolean createPhasesAndServiceItems( Boolean onlyPhases, List<ServiceModel> serviceModels ) {
        if( !String.isBlank( proposal.Id ) ) {
            System.Savepoint sp_createPhasesAndServiceItems = Database.setSavepoint();
            Map<Integer, Phase__c> availablePhases = new Map<Integer, Phase__c>();
            List<Phase__c> phases = getPhaseList();
            if( phases.isEmpty() ) {
                availablePhases.put( 1, new Phase__c( Name__c = PhaseServices.SINGLE_PHASE,
                                                      Is_default__c = true,
                                                      Number__c = 1,
                                                      Proposal__c = proposal.Id,
                                                      Project_Profile__c = proposal.Project_Profile__c ) );
            } else {
                Map<Id, Phase__c> phaseIdToPhase = PhaseServices.getPhaseMapById( proposal.Id, 'Number__c' );
                if( !String.isBlank( phaseIdsSerialized ) ) {
                    Integer rowPosition = 0;
                        for( String phaseId : phaseIdsSerialized.Split('\\|', 0) ) {
                            Phase__c tempPhase = phaseIdToPhase.get( Id.valueOf( phaseId ) );
                            if( !String.isBlank(proposal.Id) && tempPhase.Proposal__c != proposal.Id ) tempPhase.Proposal__c = proposal.Id;
                            tempPhase.Number__c = ++rowPosition;
                            availablePhases.put( Integer.valueOf( tempPhase.Number__c ), tempPhase );
                        }
                } else {
                    for( Phase__c phase : phases ) {
                        if( !String.isBlank( proposal.Id ) && phase.Proposal__c != proposal.Id ) phase.Proposal__c = proposal.Id;
                        availablePhases.put( Integer.valueOf( phase.Number__c ), phase );
                    }
                }
            }
            try {
                UPSERT availablePhases.values();
                PhaseServices.phases = null;
            } catch(Exception e) {
                Database.rollback(sp_createPhasesAndServiceItems);
                addMessage( 'Error saving Phases.' );
                return false;
            }
            //updateServiceItemsPhases();
            if( !onlyPhases ) {
                try {
                    ProposalWizardServices.saveServiceItems( pwm, proposal, serviceModels == null ? pwm.serviceModels.values() : serviceModels, getFloorWrapperList(), availablePhases, null,
                                                             null, activeChangeOrderId, null, null,
                                                             null, null, null, null,
                                                             getIsAdmin(), getIsThisUserAssignedSIPSUser(), getIsSIPSUserInChangeOrder(), null,
                                                             null, null, ProposalWizardServices.getBillingAccountForFields( proposal ) );
                } catch( Exception e ) {
                    Database.rollback( sp_createPhasesAndServiceItems );
                    addMessage( e.getMessage() );
                    return false;
                }
            }
        }
        return true;
    }

    public void setRejectionReasonPanelView() { rejectionReasonPanelView = true; }
    public String rejectionReasonMessageNotification { get; set; }

    public void recalculateFrequencyAndBillingDay() {
        if( !checkSeparatePhases() ) { //MRS 7330
            return;
        }
        recalculateBillingDay();
    }

    public void recalculateBillingDay() {
        if ( proposal.Frequency__c == null ) proposal.Billing_Day__c = null;
        if ( proposal.Frequency__c != ProposalServices.PROPOSAL_FREQUENCY_QUARTERLY ) proposal.Quarterly_Month__c = null;
    }

    public PageReference createNonFeeProposalPDF() {
        setCurrentStep();
        return ProposalWizardServices.sendProposalPDF( proposal, null, null,
                                                       null, null,
                                                       ProposalWizardServices.NON_FEE_PROPOSAL_DDP_NAME, DDPEmailServices.DELIVERY_METHOD_ATTACH, null, pwm.documentWrapperList, false); //MRS 7406
    }

    public String profileName {
        get {
            if( profileName == null ) {
                profileName = ProposalWizardServices.getProfileNameById( UserInfo.getProfileId() );
            }
            return profileName;
        } set;
    }

        public Boolean isBillingCompanyFreeOfTax { // MRS 7141
                get {
                        if(isBillingCompanyFreeOfTax == null) {
                                if(!String.isBlank(proposal.Billing_Company_Name__c)) {
                                        isBillingCompanyFreeOfTax = ProposalWizardServices.getIsBillingCompanyFreeOfTax(proposal.Billing_Company_Name__c);
                                } else {
                                        isBillingCompanyFreeOfTax = false;
                                }
                        }
                        return isBillingCompanyFreeOfTax;
                }
                private set;
        }

    public String currentUserRoleName {
        get {
            if( currentUserRoleName == null ){
                UserRole currentUserRole = UserServices.getCurrentUserRole();
                currentUserRoleName = currentUserRole == null ? '' : currentUserRole.Name;
            }
            return currentUserRoleName;
        }
        set;
    }

    public Boolean disableInputs { get { if( disableInputs == null ) disableInputs = ProposalWizardServices.disableInputs( profileName, currentUserRoleName, proposal.Status__c, getIsThisUserCreator(), proposal.Internal_Reviewer__c == currentUserId, getIsMi3(), getIsThisUserAssignedCZAnalyst(), getIsChangeOrderAllowedOnProjectOrServiceItemLevel() ); return disableInputs; } private set; }
    public Boolean disableGeneralProposalNotes{ get{if(disableGeneralProposalNotes == null) disableGeneralProposalNotes = ProposalWizardServices.disableGeneralProposalNotes(proposal.Status__c, getIsThisUserCreator()); return disableGeneralProposalNotes;} private set;}
    public Boolean enableStep3Inputs() {
        if( getIsChangeOrder() ) return true;
        if( getIsAdmin() ) {
            return !disableInputs;
        }
        if( profileName == UserServices.PROFILE_PROJECT_MANAGER_2 ) {
            if(  getIsChangeOrder() ) {
                return true;
            } else {
                return false;
            }
        }
        if( getIsPS() ) {
            return !disableInputs;
        }
        if( getIsPartner() ) {
            return !disableInputs;
        }
        if( getIsCZAnalyst() ) {
            if( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

    public transient Boolean rejectedOrFailedStatus;
    public Boolean getRejectedOrFailedStatus() { return ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_REJECTED || proposal.Status__c == ProposalServices.PROPOSAL_STATUS_FAILED_INTERNAL_REWIEW ); }

    public Boolean showAdditionalToCcMessage { get { if( showAdditionalToCcMessage == null ) showAdditionalToCcMessage = false; return showAdditionalToCcMessage; } set; }

    /* roster functionality start */
    public void changePartnerAction() { pwr.replaceRoster( proposal, pwm, ProjectRosterServices.PARTNER, false, true, true ); }
    public void changeSalespersonAction() { pwr.replaceRoster( proposal, pwm, ProjectRosterServices.SALESPERSON, false, true, true ); }
    public void changeAccountManagerAction() { pwr.replaceRoster( proposal, pwm, ProjectRosterServices.ACCOUNT_MANAGER, false, true, true ); }
    public void changeProductionManagerAction() { pwr.replaceRoster( proposal, pwm, ProjectRosterServices.PRODUCTION_MANAGER, false, true, true ); }
    public void changePrimaryContactAction() { pwr.replaceRoster( proposal, pwm, ProjectRosterServices.PRIMARY_CLIENT_CONTACT, false, true, false ); }
    public void changeBillingContactAction() { pwr.billingCompanyAndContactAction( proposal, pwm, false, true ); }
    public void changeAccountingContactAction() { pwr.accountingContactAction( proposal, pwm ); }

    public void primaryCompanyAction() {
        pwr.primaryCompanyAction( proposal, pwm, true );
                if(!String.isBlank(proposal.Billing_Company_Name__c)) isBillingCompanyFreeOfTax = ProposalWizardServices.getIsBillingCompanyFreeOfTax(proposal.Billing_Company_Name__c); // MRS 7141
                populateServiceModels( false );
        pwm.updateServiceClientPrices( proposal.Billing_Company_Name__c );
        setCurrentStep( currentStep ); //MRS-6683
    }

    public void billingCompanyAction() {
        pwr.billingCompanyAction( proposal, pwm, true, true );
        if(!String.isBlank(proposal.Billing_Company_Name__c)) isBillingCompanyFreeOfTax = ProposalWizardServices.getIsBillingCompanyFreeOfTax(proposal.Billing_Company_Name__c); // MRS 7141
        populateServiceModels( false );
        pwm.updateServiceClientPrices( proposal.Billing_Company_Name__c );
        if(proposal.Status__c != ProposalServices.PROPOSAL_STATUS_AWARDED) { // MRS 7367
        recalculateFrequencyAndBillingDay();
        }
        setCurrentStep( currentStep ); //MRS-6683
    }

    public void accountingCompanyAction() {
        pwr.accountingCompanyAction( proposal, pwm, true );
    }

    public void primaryCompanyIsBillingCompanyAction() {
        pwr.primaryCompanyIsBillingCompanyAction( proposal, pwm );
                if(!String.isBlank(proposal.Billing_Company_Name__c)) isBillingCompanyFreeOfTax = ProposalWizardServices.getIsBillingCompanyFreeOfTax(proposal.Billing_Company_Name__c); // MRS 7141
                populateServiceModels( false );
        pwm.updateServiceClientPrices( proposal.Billing_Company_Name__c );
        setCurrentStep( currentStep ); //MRS-6683
    }
    //MRS-7191
    public void poRequiredAndNotRequiredLogic() {
        if( !proposal.PO_Required__c ) proposal.PO_Not_Required__c = false;
                setCurrentStep( currentStep );
    }

    public void sendInvoicesToDifferentContactAction() {
        pwr.sendInvoicesToDifferentContactAction( proposal, pwm );
    }

    public void addContactToRosterAction() {
        pwr.addContactToRosterAction( proposal );
    }

    private Boolean saveProjectRoster() {
        saveProposalIfNotExists();
        try {
            return pwr.saveProjectRoster( proposal, pwm );
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return false;
        }
    }
    /* roster functionality end */

    public Boolean renderedLinkPhaseDelete {
        get {
            if(renderedLinkPhaseDelete == null) {
                Profile profile = UserServices.getProfile();
                if( getIsCZAnalyst() ) {
                    if(proposal.Status__c == ProposalServices.PROPOSAL_STATUS_C_Z_SCOPING_REVIEW_COMPLETE) {
                        renderedLinkPhaseDelete = true;
                    } else {
                        renderedLinkPhaseDelete = false;
                    }
                } else {
                    renderedLinkPhaseDelete = true;
                }
            }
            return renderedLinkPhaseDelete;
        } set;
    }

    public Boolean disablePhasesCheckbox {
        get {
            Boolean disablePhasesCheckbox = false;
            List<Phase__c> phases = getPhaseList();
            if( proposal.isPhase__c && (phases.size() > 1) ) {
                return true;
            }
            return disablePhasesCheckbox;
        } set;
    }

    public Boolean renderedPhasesAction {
        get {
            if( getIsChangeOrder() ||
                ( !disableInputs || enableStep3Inputs() ) ||
                ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW && getIsCZAnalyst() )
              ) {
              return true;
            }
            return false;
        } set;
    }

    public void checkSeparatePhasesVoid() { //MRS 7330
        checkSeparatePhases();
    }

    public Boolean checkSeparatePhases() { //MRS 7330
        if( proposal.isPhase__c && proposal.Separate_Phases__c && proposal.Billing_Method__c != ProposalServices.PROPOSAL_BILLING_METHOD_MILESTONE){
            addMessage( 'Separate Phases should be unchecked if Billing Method is Installment or Percentage' );
            return false;
        }
        return true;
    }

    public void saveProposalIfNotExists() {
        if( String.isBlank( proposal.Id ) ) {
            updateReimbursableAndDiscountData();
            updateProposalMunicipalAgency();
            try {
                INSERT proposal;
            } catch( Exception e ) {
                throw new ErrorException( 'Error creating proposal: ' + e.getMessage() );
            }
            proposal = ProposalWizardServices.getProposal( proposal.Id );
            pwr.saveProjectRoster( proposal, pwm );
        }
    }

    /* ----------------- Phases ----------------------------- */
    public Phase__c phaseToCreate { get { if( phaseToCreate == null ) phaseToCreate = new Phase__c(); return phaseToCreate; } set; }

    public transient Boolean validPhaseDate;
    public Boolean getValidPhaseDate() {
        Boolean isValid = true;
        if(phaseToCreate != null && phaseToCreate.Start_Date__c != null && phaseToCreate.End_Date__c != null) {
            if(phaseToCreate.Start_Date__c > phaseToCreate.End_Date__c) {
                isValid = false;
            }
        }
        return isValid;
    }

    public transient Boolean validPhaseName;
    public Boolean getValidPhaseName() {
        return !String.isEmpty(phaseToCreate.Name__c);
    }

    public Boolean isSavePhase { get { if(isSavePhase == null) isSavePhase = true; return isSavePhase; } set; } //MRS 7330

    public void savePhaseAction() {
        isSavePhase = false;
        if(!getValidPhaseName()) { addMessage( '\'Name\' cannot be empty.' ); return; }
        if(!getValidPhaseDate()) { addMessage( '\'Start Date\' cannot be less than \'End Date\'.' ); return; }
        if(proposal.isPhase__c) {
            phaseToCreate.Proposal__c = proposal.Id;
            phaseToCreate.Project_Profile__c = proposal.Project_Profile__c;
        }
        if( String.isBlank( phaseToCreate.Id ) ) {
            Integer maxNumber = 0;
            for( Phase__c phase : getPhaseList() ) {
                if( Integer.valueOf(phase.Number__c) > maxNumber ) maxNumber = Integer.valueOf(phase.Number__c);
            }
            phaseToCreate.Number__c = ++maxNumber;
        }
        try {
            UPSERT phaseToCreate;
            PhaseServices.phases = null;
            isSavePhase = true;
        } catch(System.DMLException e) {
            isSavePhase = false;
            addMessage( 'Error saving Phase.' );
            return;
        }
        updatePhaseNumbers( null );
        phaseToCreate = null;
    }

    public String phaseEditId { get; set; }
    public String phaseDelId { get; set; }
    public String phaseIdsSerialized { get; set; }

    public void editPhaseAction() {
        /*
        if(!validPhaseName) { addMessage( '\'Name\' cannot be empty.' ); return; }
        if(!validPhaseDate) { addMessage( '\'Start Date\' cannot be less than \'End Date\'.' ); return; }
        */
        if( !String.isBlank(phaseEditId) ) {
            List<Phase__c> availablePhases = [SELECT Name__c, Start_Date__c, End_Date__c, Number__c FROM Phase__c WHERE Id = : phaseEditId];
            if( !availablePhases.isEmpty() ) {
                phaseToCreate = availablePhases[0];
                phaseToCreate.Is_default__c = false;
            } else {
                phaseToCreate = null;
            }
        } else {
            phaseToCreate = null;
        }
    }

    public void newPhaseAction() { //MRS 7330
        phaseToCreate = null;
        phaseEditId = null;
        phaseDelId = null;
        rightPanelView = 'Notes';
    }

    /* ----------------- Phases Main Page ------------------- */
    public void changeRightPanelToPhase() {
        rightPanelView= 'Phase';
        try {
            saveProposalIfNotExists();
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return;
        }
    }

    public void deletePhaseAction() {
        if( phaseEditId == phaseDelId ) {
            phaseEditId = null;
            phaseToCreate = new Phase__c();
        }
        if( !String.isBlank(phaseDelId) ) {
            List<Phase__c> phasesToDelete = [ SELECT Id, Number__c,
                                                     ( SELECT Id
                                                       FROM Service_Items__r
                                                       WHERE Is_Alternative__c = false )
                                              FROM Phase__c
                                              WHERE Id = : phaseDelId ];
            if( !phasesToDelete.isEmpty() ) {
                Phase__c phaseToDelete = phasesToDelete[0];

                for( ServiceModel sm : pwm.serviceModels.values() ) { //do not allow regular services to live without phases
                    if( sm.serviceItemRecord.Phase__c == phaseToDelete.Id && !sm.isAlternative ) {
                        addMessage( 'Can not remove phases if there are services attached to it. If you have moved the services to another phase on Step 3, please save the changes and try to remove the phase once more.' );
                        updatePhaseNumbers( null );
                        return;
                    } else {
                        if( sm.phaseId == phaseToDelete.Id && !sm.isAlternative ) {
                            addMessage( 'Can not remove phases if there are services pending to be attached to it. Please move these services to another phase on Step 3 and try to delete it again.' );
                            updatePhaseNumbers( null );
                            return;
                        }
                    }
                }

                if( !phaseToDelete.Service_Items__r.isEmpty() ) {
                    addMessage( 'The phase with attached services can not be deleted.' );
                    return;
                }

                System.Savepoint sp_deletePhaseAction = Database.setSavepoint();
                try {
                    for( ServiceModel sm : pwm.serviceModels.values() ) { //clear phase ids for alternative services
                        if( sm.isAlternative && ( sm.serviceItemRecord.Phase__c == phaseToDelete.Id || sm.phaseId == phaseToDelete.Id ) ) {
                            sm.serviceItemRecord.Phase__c = null;
                            sm.phaseId = null;
                        }
                    }
                    updatePhaseNumbers( phaseDelId );
                    DELETE phaseToDelete;
                    PhaseServices.phases = null;
                } catch( Exception e ) {
                    Database.rollback( sp_deletePhaseAction );
                    addMessage( 'Error removing phase.' );
                    return;
                }
            }
            PhaseServices.rerenderPhaseNumber( getPhaseList() );
            if( selectedPhase == phaseDelId ) {
                selectedPhase = null;
            }
            phaseDelId = null;
        }
    }

    public void updatePhaseNumbers( String phaseIdToExclude ) {
        if( !String.isBlank( phaseIdsSerialized ) ) {
            Integer rowPosition = 0;
            List<Phase__c> phasesToUpdate = new List<Phase__c>();
            for( String phaseId : phaseIdsSerialized.Split('\\|', 0) ) {
                if( phaseId != phaseIdToExclude ) {
                    phasesToUpdate.add( new Phase__c( Id = Id.valueOf( phaseId ),
                                                      Number__c = ++rowPosition ) );
                }
            }
            UPDATE phasesToUpdate;
            PhaseServices.phases = null;
            //updateServiceItemsPhases();
        }
    }

    public Boolean savePhase() {
        List<Phase__c> phases = getPhaseList();
        if( phases != null && proposal.Id != null ) {
            for( Phase__c phase : phases ) {
                phase.Proposal__c = proposal.Id;
                phase.Project_Profile__c = proposal.Project_Profile__c;
            }
            try {
                UPSERT phases;
                PhaseServices.phases = null;
            } catch(Exception e){
                addMessage( 'Error saving phase.' );
                return false;
            }
        }
        return true;
    }

    /* ----------------- Floors ----------------------------- */
    public Floor__c floorToCreate { get { if( floorToCreate == null ) floorToCreate = new Floor__c(); return floorToCreate; } set; }
    public Boolean floorCreated { get { if( floorCreated == null ) floorCreated = false; return floorCreated; } set; }

    public transient Boolean disableFloorAction;
    public Boolean getDisableFloorAction() { return ( getIsChangeOrder() || !disableInputs || ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW && getIsCZAnalyst() ) ); }

    public transient List<SelectOption> floorTypeOptions;
    public List<SelectOption> getFloorTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption ( '', '-- None --' ) );
        for( Schema.PicklistEntry item : Floor__c.SObjectType.getDescribe().fields.getMap().get('Floor_Type__c').getDescribe().getPicklistValues() ) {
            options.add( new SelectOption ( Item.getValue(), Item.getValue() ) );
        }
        return options;
    }

    public transient List<SelectOption> tenantFloorTypeOptions;
    public List<SelectOption> getTenantFloorTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption ( '', '-- None --' ) );
        for( Schema.PicklistEntry item : Floor__c.SObjectType.getDescribe().fields.getMap().get('Tenant_Type__c').getDescribe().getPicklistValues() ) {
            options.add( new SelectOption ( Item.getValue(), Item.getValue() ) );
        }
        return options;
    }

    public void saveFloorAndCloseTab() {
        try {
            saveFloor();
            if(floorCreated) { // MRS 7200 7328
                rightPanelView = 'Notes';
            } else {
                rightPanelView = 'Floor';
            }
        } catch(System.DMLException ex) {
            addMessage( 'Error saving Floor: ' + ex.getMessage() );
            return;
        }
    }

    public void saveFloorAndDoNotCloseTab() {
        try {
            saveFloor();
            rightPanelView = 'Floor'; //MRS 7328
        } catch(System.DMLException ex) {
            addMessage( 'Error saving Floor: ' + ex.getMessage() );
            return;
        }
    }

    public void saveFloor() {
        floorCreated = false;

        try { //MRS 7324
            saveProposalIfNotExists();
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return;
        }

        if( String.isBlank(floorToCreate.Floor_Type__c)) {
            addMessage( 'Required fields are missing: [Floor Type]' );
            return;
        }

        if(  (FloorServices.requiredFloorNumberTypes.contains(floorToCreate.Floor_Type__c) || !FloorServices.notRequiredFloorNumberTypes.contains(floorToCreate.Floor_Type__c)) && String.isBlank( String.valueOf(floorToCreate.Floor_Number__c) ) ) {
            addMessage( 'Required fields are missing: [Floor #]' );
            return;
        }

        if (  (null != floorToCreate.Floor_Number__c && FloorServices.specificationNamesvariable.containsKey(floorToCreate.Floor_Type__c) && !FloorServices.requiredFloorNumberValue.contains(floorToCreate.Floor_Type__c) ) &&
            !Pattern.matches('^[0-9]+([,-]{1}[0-9]+)*', String.valueOf(floorToCreate.Floor_Number__c)) ) {
            addMessage( 'Field Floor # for floor type \'' + floorToCreate.Floor_Type__c + '\' has no valid format' );
            return;
        }

        if( (null != floorToCreate.Floor_Number__c && FloorServices.specificationNamesvariable.containsKey(floorToCreate.Floor_Type__c) && FloorServices.requiredFloorNumberValue.contains(floorToCreate.Floor_Type__c) ) &&
            (String.valueOf(floorToCreate.Floor_Number__c).length() > 50) ) {
            addMessage( 'Field Floor # for floor type \'' + floorToCreate.Floor_Type__c + '\' cannot have more than 50 symbols' );
            return;
        }

        if( (null != floorToCreate.Tenant_Type__c && null != floorToCreate.Tenant_Number__c && FloorServices.specificationNamesvariable.containsKey(floorToCreate.Tenant_Type__c) && !FloorServices.requiredFloorNumberValue.contains(floorToCreate.Tenant_Type__c) ) &&
            !Pattern.matches('^[0-9]+([,-]{1}[0-9]+)*', String.valueOf(floorToCreate.Tenant_Number__c)) ) {
            addMessage( 'Field Floor Tenant # for floor tenant type \'' + floorToCreate.Tenant_Type__c + '\' has no valid format' );
            return;
        }

        if( (null != floorToCreate.Tenant_Type__c && null != floorToCreate.Tenant_Number__c && FloorServices.specificationNamesvariable.containsKey(floorToCreate.Tenant_Type__c) && !FloorServices.requiredFloorNumberValue.contains(floorToCreate.Tenant_Type__c) ) &&
            (null != floorToCreate.Floor_Number__c && String.valueOf(floorToCreate.Floor_Number__c).length() > 50) ) {
            addMessage( 'Field Floor Tenant # for floor tenant type \'' + floorToCreate.Tenant_Type__c + '\' cannot have more than 50 symbols' );
            return;
        }

        floorToCreate.Specification_Name__c = FloorServices.getFullFloorName(String.valueOf(floorToCreate.Floor_Type__c), String.valueOf(floorToCreate.Floor_Number__c));
        floorToCreate.Specification_Tenant_Name__c = FloorServices.getFullFloorName(String.valueOf(floorToCreate.Tenant_Type__c), String.valueOf(floorToCreate.Tenant_Number__c));
        floorToCreate.Proposal__c =  proposal == null ? null : proposal.Id;
        floorToCreate.Project__c = proposal.Project_Profile__c;

        UPSERT floorToCreate;
        FloorServices.floors = null;
        List<FloorWrapper> currentFloorWrapperList = getFloorWrapperList();
        proposal.Floor_s__c = FloorServices.updateFloorsString( proposal.Id, proposal.Project_Profile__c, currentFloorWrapperList, true );
        ProposalWizardModel.updateServicesAndJunctions( currentFloorWrapperList, pwm.serviceModels.values(), proposal, true );

        floorToCreate = new Floor__c();
        floorCreated = true;
    }

    public void cancelFloorAction() {
        floorToCreate = new Floor__c();
        floorCreated = false;
        rightPanelView = 'Notes';
    }

    /* ---------------- Service Item ---------------- */
    public String searchField {
        get {
            if( searchField == null ) {
                searchField = '';
            }
            return searchField;
        }
        set;
    }

    public Service_Template__c serviceTemplateForAddPanel { // MRS 7335
        get {
            if( serviceTemplateForAddPanel == null ) {
                serviceTemplateForAddPanel = new Service_Template__c(RecordTypeId = recordTypeNameToId.get(ServiceItemServices.APS_SERVICE_RECORD_TYPE_NAME));
            }
            return serviceTemplateForAddPanel;
        }
        set;
    }

    public Service_Template__c serviceTemplate { // MRS 7335
        get {
            if( serviceTemplate == null ) {
                serviceTemplate = new Service_Template__c(RecordTypeId = recordTypeNameToId.get(ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME));
            }
                serviceTemplate.Category__c = ServiceItemServices.CATEGORY_CONSULTING;
                serviceTemplate.Type__c = ServiceItemServices.TYPE_SPECIAL_INSPECTION;
            return serviceTemplate;
        }
        set;
    }

    public transient List<SelectOption> approvedVendorsOptions;
    public List<SelectOption> getApprovedVendorsOptions() {
        return ProposalWizardServices.generateOptions( ProposalWizardServices.getPicklistOptionsForApprovedVendors() );
    }

    public transient List<SelectOption> serviceTypeOption;
    public List<SelectOption> getServiceTypeOption() {
        List<SelectOption> serviceTypeOptions = new List<SelectOption>();
        for( String strItem : recordTypeNameToId.keySet() ) {
            serviceTypeOptions.add( new SelectOption(recordTypeNameToId.get(strItem), strItem) );
        }
        return serviceTypeOptions;
    }

    private Map<String, Id> recordTypeNameToId {
        get {
            if( recordTypeNameToId == null ) {
                recordTypeNameToId = ProposalWizardServices.recordTypeNameToId();
            }
            return recordTypeNameToId;
        }
        set;
    }

    public String serializedProposal {
        get;
        set {
            if( !String.isBlank( value ) ) {
                ProposalWizardServices.mergeFieldsFromStep2WithProposal( proposal, value );
            }
        }
    }

    public transient Boolean isSinglePermit;
    public Boolean getIsSinglePermit() {
        return proposal.Is_Draft__c &&
               proposal.sowScopeOfWork__c == 'Existing Space' &&
               proposal.sowServicesNeededAPS__c &&
               proposal.sowNoneOfTheAbove__c &&
               proposal.sowSpaceAlterType__c == 'Single Permit';
    }

    public transient Boolean isRecordTypeSelectionDisabled;
    public Boolean getIsRecordTypeSelectionDisabled() {
        if( getIsChangeOrder() ) {
            return false;
        } else {
            if( //profileName == 'Proposal Specialist' &&
                proposal.Is_Draft__c &&
                proposal.sowScopeOfWork__c == 'Existing Space' &&
                !proposal.sowServicesNeededAPS__c &&
                proposal.sowServicesNeededOther__c ) {
                return true;
            }
        }
        return false;
    }

    @RemoteAction // MRS 7335
    public static Map<String, List<List<String>>> getListsForServiceItemAddDialog(String levelOfChange, String sTypeID, String region, String category, String type, String subtype, String planPermission, String workTypeSearchInput) {
        Map<String, List<List<String>>> res = new Map<String, List<List<String>>>();
        if(levelOfChange == 'RecordTypeId') {
            res.put('Category__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Category__c'));
            res.put('Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Type__c'));
            res.put('Subtype__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Subtype__c'));
            res.put('Plan_Submission_Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Plan_Submission_Type__c'));
        } else if(levelOfChange == 'Category__c') {
            res.put('Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Type__c'));
            res.put('Subtype__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Subtype__c'));
            res.put('Plan_Submission_Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Plan_Submission_Type__c'));
        } else if(levelOfChange == 'Type__c') {
            res.put('Subtype__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Subtype__c'));
            res.put('Plan_Submission_Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Plan_Submission_Type__c'));
        } else if(levelOfChange == 'Subtype__c') {
            res.put('Plan_Submission_Type__c', ProposalWizardServices.getPicklistOptionsForServiceTemplateJS(sTypeID, region, category, type, subtype, 'Plan_Submission_Type__c'));
        }
        res.put('List_Of_Services', getServiceTemplatesMapJS(sTypeID, region, category, type, subtype, planPermission, workTypeSearchInput));
        return res;
    }

    @RemoteAction
    public static List<Boolean> getCharacteristicsOfSelectedTemplate(String templateID, String recordTypeName, String vendorSelected, String inspectionType) {
        List<Boolean> res = new List<Boolean>();
        Service_Template__c serviceTemp = [SELECT Category__c, Type__c, Subtype__c, Unit_of_Service__c, Service_Name_Full__c FROM Service_Template__c WHERE Id = :templateID];
        res.add(ProposalWizardServices.isCustomWorkTypeService(serviceTemp.Category__c, serviceTemp.Type__c, recordTypeName == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME));

        res.add(serviceTemp.Category__c == ServiceItemServices.CATEGORY_CONSULTING 
                && serviceTemp.Type__c == ServiceItemServices.TYPE_SPECIAL_INSPECTION 
                && serviceTemp.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION);
        res.add(serviceTemp.Category__c == ServiceItemServices.CATEGORY_CONSULTING && serviceTemp.Type__c == ServiceItemServices.TYPE_SPECIAL_INSPECTION && 
                    !( (serviceTemp.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION ||
                       (serviceTemp.Subtype__c == null && serviceTemp.Service_Name_Full__c == ServiceItemServices.SERVICE_NAME_SPECIAL_INSPECTION_PROJECT_COORDINATION ) ) &&
                     (String.isBlank(vendorSelected) || String.isBlank(inspectionType) )));


        res.add(serviceTemp.Unit_of_Service__c == 'Hour');
        return res;
    }

        // ---------------- Service Item Main Page -----------------
    public String serviceType { get; set; }

    public void performTemplateChecks() {
		performTemplateChecksBool();
	}

    public Boolean performTemplateChecksBool() { //MRS 7463
        if( String.isBlank(building.Id) ) {
            addMessage( 'Building should be populated.' );
			return false;
        } else {
            if( String.isBlank(building.Municipality__c) ) {
                addMessage( 'Building should have a municipality.' );
				return false;
            } else {
                if( String.isBlank(building.Region__c) ) {
                    addMessage( 'Municipality of a building should have a region.' );
					return false;
                }
            }
        }
        if( String.isBlank(proposal.Billing_Company_Name__c) ) {
            addMessage( 'Billing company should be populated.' );
			return false;
        }
        if( String.isBlank(proposal.Id) ) {
            addMessage( 'Proposal should be saved to the database in order to create service items for it.' );
			return false;
        }
        if( proposal.isPhase__c && getPhaseList().isEmpty() ) {
            addMessage( 'Proposal should have at least one phase.' );
			return false;
        } else {
            if( !proposal.isPhase__c && getPhaseList().isEmpty() ) {
                if( !createPhasesAndServiceItems( true, null ) ) { return false; }
            }
        }
        return true;
    }

    public String selectedVendor { get; set; }

    public Integer quantityOfServicesToInsert {
        get {
            if( quantityOfServicesToInsert == null ) quantityOfServicesToInsert = 1;
            return quantityOfServicesToInsert;
        }
        set;
    }

    public String serviceTypeToAdd { get; set; } //MRS 7335
    public String changeOrderIdToAdd { get; set; }
    public String selectedServiceIDToAdd { get; set; }
    public PageReference addServiceAction() {
        if(String.isBlank(selectedServiceIDToAdd)) {
            addMessage( 'Service Template was not chosen. Please redefine select options.', 'WARNING' );
        } else if(performTemplateChecksBool()) {// MRS 7463
            if( saveServiceItem() == false ) { return null; }
            for( ServiceModel sm : pwm.serviceModels.values() ) {
                sm.checked = false;
            }
            populateServiceModels(true);
            serviceTypeToAdd = null;
            changeOrderIdToAdd = null;
            selectedServiceIDToAdd = null;  
        }
        return null;
    }

    public Service_Template__c serviceTemplatesForNewServices {
        get {
            if(serviceTemplatesForNewServices == null) {
                serviceTemplatesForNewServices = new Service_Template__c();
            }
            return serviceTemplatesForNewServices;
        }
        set;
    }

    public static List<List<String>> getServiceTemplatesMapJS(String sTypeID, String region, String category, String type, String subtype, String planPermission, String workTypeSearchInput) {
        List<Service_Template__c> selectedServiceTemplates;
        List<Service_Template__c> matchedServiceTemplates = new List<Service_Template__c>();
            String query = '' +
            'SELECT Id, Service_Name_Full__c FROM Service_Template__c';

            List<String> whereConditions = new List<String>();
        whereConditions.add('RecordTypeId = \'' + sTypeID + '\'');
        if(!String.isBlank(region)) {
                String regionName = '';
            if(    region == RegionServices.REGION_NAME_MASSACHUSETTS
                || region == RegionServices.REGION_NAME_RHODE_ISLAND
                || region == RegionServices.REGION_NAME_MAINE
                || region == RegionServices.REGION_NAME_VERMONT
                || region == RegionServices.REGION_NAME_NEW_HAMPSHIRE ) { // MRS 6581
                    regionName = String.escapeSingleQuotes(RegionServices.REGION_NAME_CT);
            }else if(region == RegionServices.REGION_NAME_VIRGINIA ){
                    regionName = String.escapeSingleQuotes(RegionServices.REGION_NAME_WASH);
                }else{
                regionName = String.escapeSingleQuotes(region);
                }
                whereConditions.add( 'Region__c = \'' + regionName + '\'' );
            }
        if(!String.isBlank(category)) {
            whereConditions.add( 'Category__c = \'' + String.escapeSingleQuotes(category) + '\'' );
        }
        if(!String.isBlank(type)) {
            whereConditions.add( 'Type__c = \'' + String.escapeSingleQuotes(type) + '\'' );
        }
        if(!String.isBlank(subtype)) {
            whereConditions.add( 'Subtype__c = \'' + String.escapeSingleQuotes(subtype) + '\'' );
        }
        if(!String.isBlank(planPermission)) {
            whereConditions.add( 'Plan_Submission_Type__c = \'' + String.escapeSingleQuotes(planPermission) + '\'' );
            }
		whereConditions.add('Deactivate__c = false'); //MRS 7476
            query += ' WHERE ' + String.join( whereConditions, ' AND ' );
        query += ' LIMIT 1000';
            selectedServiceTemplates = (List<Service_Template__c>)Database.query( query );
            for( Service_Template__c serviceTemplate : selectedServiceTemplates ) {
                String templateName = serviceTemplate.Service_Name_Full__c;
                if ( templateName == null ) continue;

                Boolean criteriaMatched = true;
            if(!String.isBlank(workTypeSearchInput)) {
                for(String searchWord : workTypeSearchInput.split(' ')) {
                    if( !templateName.containsIgnoreCase( searchWord ) ) {
                        criteriaMatched = false;
                        break;
                    }
                }
            }
            if(criteriaMatched) matchedServiceTemplates.add(serviceTemplate);
        }
        return ServiceTemplateServices.getSortedListOfServiceTempates(matchedServiceTemplates);
    }

    public Boolean getRequiredSIPSFieldsPopulated(String serviceFullName) {//MRS-6281
        return !( ( serviceTemplate.Subtype__c == ServiceItemServices.SUBTYPE_SPECIAL_INSPECTION_PROJECT_COORDINATION ||
                    ( serviceTemplate.Subtype__c == null && serviceFullName == ServiceItemServices.SERVICE_NAME_SPECIAL_INSPECTION_PROJECT_COORDINATION ) ) &&
                  ( selectedVendor == null || serviceTemplate.Inspection_Type__c == null ) );
    }

    private Boolean saveServiceItem() { //MRS 7335
        if(String.isBlank(selectedServiceIDToAdd)) return true; //Preventor of quick click on save button before its rerender.
        //MRS-7530
        Service_Template__c servTemp = ServiceItemServices.getServiceTemplateForServiceItem(new List<Id>{Id.valueOf(selectedServiceIDToAdd)}, null)[0];
        String recordTypeName = ProposalWizardServices.recordTypeIdToNameMap( recordTypeNameToId ).get(servTemp.RecordTypeId);
        System.debug(LoggingLevel.ERROR, '### serviceTypeToAdd == *' + serviceTypeToAdd + '*');
        System.debug(LoggingLevel.ERROR, '### changeOrderIdToAdd == *' + changeOrderIdToAdd + '*');
        System.debug(LoggingLevel.ERROR, '### selectedServiceIDToAdd == *' + selectedServiceIDToAdd + '*');
        System.debug(LoggingLevel.ERROR, '### servTemp == *' + servTemp + '*');
        System.debug(LoggingLevel.ERROR, '### recordTypeName == *' + recordTypeName + '*');
        if(changeOrderIdToAdd.length() < 1) {
            changeOrderIdToAdd = null;
        } else {
            activeChangeOrderId = changeOrderIdToAdd;
        }
        System.Savepoint sp_saveServiceItem = Database.setSavepoint();
        try {
            ProposalWizardServices.saveServiceItems( pwm, proposal, null, getFloorWrapperList(), null, getPhaseList(),
                                                    selectedPhase, changeOrderIdToAdd, servTemp, serviceTemplatesForNewServices,
                                                    quantityOfServicesToInsert, serviceTemplate.Inspection_Type__c,
                                                    ProposalWizardServices.isCustomWorkTypeService(servTemp.Category__c, servTemp.Type__c, recordTypeName == ServiceItemServices.OS_SERVICE_RECORD_TYPE_NAME),
                                                    serviceTypeToAdd, getIsAdmin(), getIsThisUserAssignedSIPSUser(), getIsSIPSUserInChangeOrder(), getRequiredSIPSFieldsPopulated(servTemp.Service_Name_Full__c),
                                                     selectedVendor, retrieveDiscountQuantity, ProposalWizardServices.getBillingAccountForFields( proposal ) );
            serviceTemplatesForNewServices = new Service_Template__c();
            quantityOfServicesToInsert = 1;
            serviceTemplate.Inspection_Type__c = null;
            selectedVendor = null;
        } catch( Exception e ) {
            Database.rollback( sp_saveServiceItem );
            addMessage( e.getMessage() );
            return false;
        }
        return true;
    }

    public String selectedPhase { get; set; }

    public transient List<SelectOption> availablePhases;
    public List<SelectOption> getAvailablePhases() {
        List<SelectOption> phases = new List<SelectOption>();
        if( !String.isEmpty( proposal.Id ) ) {
            for( Phase__c phase : [SELECT Name__c, Number__c FROM Phase__c WHERE Proposal__c = : proposal.Id ORDER BY Number__c, CreatedDate] ) {
                phases.add( new SelectOption(phase.Id, String.valueOf(phase.Number__c) + ' - ' + phase.Name__c) );
            }
        }
        return phases;
    }

    // MRS 7056
    public String reasonForNonPayable { set; get; }
    public List<SelectOption> optionsForNonPayableReasons { set;
        get {
            optionsForNonPayableReasons = new List<SelectOption> ();
            Schema.DescribeFieldResult describeOfField = Service_Item__c.Non_Billable_Reason__c.getDescribe();
            if( describeOfField != null ) {
                List<Schema.PicklistEntry> pleList = describeOfField.getPicklistValues();
                if( pleList != null ) {
                    for( Schema.PicklistEntry  pleItem : pleList ) {
                        optionsForNonPayableReasons.add( new SelectOption( pleItem.getLabel(), pleItem.getValue() ) );
                    }
                }
            }
            return optionsForNonPayableReasons;
        }
    }
    public void setSelectedReasonToSelectedServiceItems() {
        List<String> serviceIdsAbleToMoveList = serviceIdsForMultiAction.split(';');
                complete(false); // MRS 7254
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c> ();
        if( !String.isBlank( reasonForNonPayable ) ) {
            for( String id : serviceIdsAbleToMoveList ) {
                serviceItemsToUpdate.add( new Service_Item__c ( Id = (Id)id, Non_Billable_Reason__c = reasonForNonPayable ) );
            }
        }

        try {
            UPSERT serviceItemsToUpdate;
        } catch ( DMLException e ) {
            addMessage( 'Error while updating Non Payable Reason(s) of Service(s).' );
        }
        populateServiceModels(false);
        pwm.updateAllChangeOrderData();
        serviceIdsForMultiAction = null;
    }

    // ----------------- Purchase Order -----------------
    public transient Boolean disableAddPurchaseOrderButton;
    public Boolean getDisableAddPurchaseOrderButton() {
        return ( pwm.serviceModels == null ||
                pwm.serviceModels.isEmpty() ||
                profileName.startsWith( UserServices.PROFILE_PROJECT_MANAGER ) );
    }

    public Boolean purchaseOrderCreated { get { if( purchaseOrderCreated == null ) purchaseOrderCreated = false; return purchaseOrderCreated; }set;}
    public Purchase_Order__c currentPurchaseOrder { get { if( currentPurchaseOrder == null ) currentPurchaseOrder = new Purchase_Order__c( NTE_Includes_Reimbursables__c = true ); return currentPurchaseOrder; } set;}
    public Boolean updateServiceTable { get { if( updateServiceTable == null ) updateServiceTable = false; return updateServiceTable; }set;}
    public Boolean updateExistingPurchaseOrders { get { if( updateExistingPurchaseOrders == null ) updateExistingPurchaseOrders = false; return updateExistingPurchaseOrders; }set;}

    public Map<Id, Purchase_Order__c> existingPurchaseOrders {
        get {
            if( existingPurchaseOrders == null || updateExistingPurchaseOrders ) {
                if( proposal.Id == null ) {
                    existingPurchaseOrders = new Map<Id, Purchase_Order__c>();
                } else {
                    existingPurchaseOrders = PurchaseOrderServices.getPurchaseOrdersForProposal( proposal.Id );
                }
                updateExistingPurchaseOrders = false;
            }
            return existingPurchaseOrders;
        } set;
    }

    public List<Purchase_Order__c> sortedPurchaseOrdersByCreatedDateDESC { set; // MRS 7046
        get {
            List<Purchase_Order__c> res = new List<Purchase_Order__c>();
            List<PurchaseOrderServices.PurchaseOrderComparableCreatedDate> tempList = new List<PurchaseOrderServices.PurchaseOrderComparableCreatedDate> ();
            for( Purchase_Order__c pO : existingPurchaseOrders.values() ) tempList.add( new PurchaseOrderServices.PurchaseOrderComparableCreatedDate( pO ) );
            tempList.sort();
            for( PurchaseOrderServices.PurchaseOrderComparableCreatedDate myPO : tempList ) res.add( myPO.myPO );
            return res;
        }
    }

    public void addAllServicesToPurchaseOrder() {
        updateServiceTable = false;
        Decimal oldTotalServicesPrice = 0;
        Decimal newTotalServicesPrice = 0;
        List<Service_Item__c> newServiceItemsToUpdate = new List<Service_Item__c>();
        List<ServiceModel> affectedServices = new List<ServiceModel>();

        for( ServiceModel sm : pwm.serviceModels.values() ) {
            Decimal servicePrice = currentPurchaseOrder.PO_Excludes_Sales_Tax__c ? sm.getTotalDiscountedServicePrice() : sm.getTotalDiscountedServicePrice() + sm.getSalesTax(); //MRS 6205
            if( sm.isAddedToPurchaseOrder ) {
                oldTotalServicesPrice += servicePrice;
                newTotalServicesPrice += servicePrice;
                newServiceItemsToUpdate.add( sm.serviceItemRecord );
            }
            if( !sm.isAddedToPurchaseOrder && String.isBlank( sm.purchaseOrderNumber ) && ProposalWizardServices.serviceCanBeAddedToPo( pwm, sm ) ) {
                affectedServices.add( sm );
                newTotalServicesPrice += servicePrice;
            }
        }
        if( String.isBlank( String.valueOf( currentPurchaseOrder.Purchase_Order_Amount__c ) ) && oldTotalServicesPrice > 0 ) {
            addMessage( 'Please enter the Purchase Order Amount' );
            updateServiceTable = true;
            return;
        }
        if( oldTotalServicesPrice > currentPurchaseOrder.Purchase_Order_Amount__c || newTotalServicesPrice > currentPurchaseOrder.Purchase_Order_Amount__c ) {
            addMessage( 'Total services price can not exceed Purchase Order Amount' );
            return;
        }
        for( ServiceModel sm : affectedServices ) {
            sm.isAddedToPurchaseOrder = true;
        }
    }

    public void cleanUpPurchaseOrder() {
        currentPurchaseOrder = new Purchase_Order__c( NTE_Includes_Reimbursables__c = true );
        editPurchaseOrderBlockTitle = ProposalWizardServices.CREATE_NEW_PURCHASE_ORDER_TITLE;
        purchaseOrderToUpdate = null;
        for( ServiceModel serviceModel: pwm.serviceModels.values() ) {
            serviceModel.isAddedToPurchaseOrder = false;
        }
        try {
            INSERT currentPurchaseOrder;
        } catch( Exception e ) {
            addMessage( 'Error Creating Purchase Order.' );
            return;
        }
    }

    public void cancelPurchaseOrderAction() {

        try {
            PurchaseOrderServices.deletePurchaseOrder( currentPurchaseOrder, true );
        } catch( Exception e ) {
            addMessage( 'Error canceling Purchase Order.' );
            return;
        }
        updateExistingPurchaseOrders = true; // MRS 6860
    }

    public void prepareFileUploadPageForCurrentPO() { //MRS-6803
        purchaseOrderStorageIframe = new PageReference( '/apex/storedDocInlinePurchaseOrder' );
        purchaseOrderStorageIframe.getParameters().put( 'eid', String.valueOf( currentPurchaseOrder.Id ).left(15) );
    }

    public void prepareCurrentPurchaseOrder() { //MRS-6803
        cleanUpPurchaseOrder();
        prepareFileUploadPageForCurrentPO();
    }

    public String editPurchaseOrderBlockTitle { get { if( editPurchaseOrderBlockTitle == null ) editPurchaseOrderBlockTitle = ProposalWizardServices.CREATE_NEW_PURCHASE_ORDER_TITLE; return editPurchaseOrderBlockTitle; } set; }

    public transient String addPurchaseOrderButtonTitle;
    public String getAddPurchaseOrderButtonTitle() { return editPurchaseOrderBlockTitle == ProposalWizardServices.CREATE_NEW_PURCHASE_ORDER_TITLE ? 'Add' : 'Save'; }

    public transient String addAndNewPurchaseOrderButtonTitle;
    public String getAddAndNewPurchaseOrderButtonTitle() { return editPurchaseOrderBlockTitle == ProposalWizardServices.CREATE_NEW_PURCHASE_ORDER_TITLE ? 'Add and New' : 'Save and New'; }

    public String purchaseOrderToUpdate { get; set; }
    public PageReference purchaseOrderStorageIframe { get; set; }

    public void updatePurchaseOrderAction() {
        try {
            PurchaseOrderServices.deletePurchaseOrder( currentPurchaseOrder, true ); //MRS-6803 delete template when switching to another PO
        } catch( Exception e ) {
            addMessage( 'Error switching to Purchase Order.' );
            return;
        }
        updateExistingPurchaseOrders = true;
        currentPurchaseOrder = existingPurchaseOrders.get( purchaseOrderToUpdate );
        editPurchaseOrderBlockTitle = ProposalWizardServices.EDIT_PURCHASE_ORDER_TITLE + ' ' + currentPurchaseOrder.Name;
        for( ServiceModel sm : pwm.serviceModels.values() ) {
            sm.isAddedToPurchaseOrder = sm.serviceItemRecord.Purchase_Order__c == purchaseOrderToUpdate;
        }
        for( Service_Item__c service: currentPurchaseOrder.Covered_Services__r ) {
            if( pwm.serviceModels.containsKey( service.Id ) ) {
                ServiceModel sm = pwm.serviceModels.get( service.Id );
                sm.isAddedToPurchaseOrder = true;
            }
        }
        prepareFileUploadPageForCurrentPO(); //MRS-6803
    }

    public void deletePurchaseOrderAction() {
        Purchase_Order__c purchaseOrderToDelete = existingPurchaseOrders.get(purchaseOrderToUpdate);
        try {
            for( ServiceModel sm: pwm.serviceModels.values() ) {
                if( sm.serviceItemRecord.Purchase_Order__c == purchaseOrderToUpdate ) {
                    sm.serviceItemRecord.Purchase_Order__c = null;
                    sm.purchaseOrderNumber = '';
                    sm.isAddedToPurchaseOrder = false;
                }
            }
            if( currentPurchaseOrder.Id == purchaseOrderToDelete.Id ) {
                prepareCurrentPurchaseOrder(); //MRS-6803
            }
            PurchaseOrderServices.deletePurchaseOrder( purchaseOrderToDelete, false );
            updateExistingPurchaseOrders = true;
            currentPurchaseOrdersList = existingPurchaseOrders.values();
        } catch( Exception e ) {
            addMessage( 'Error deleting Purchase Order.' );
            return;
        }
    }

    public void saveAndNewPurchaseOrderAction() {
        savePurchaseOrderAction(); //MRS - 6860
    }

    public void savePurchaseOrderAction() {

        purchaseOrderCreated = false;
        if( String.isBlank( String.valueOf( currentPurchaseOrder.Name ) ) ) {
            addMessage( 'Required fields are missing: PO #' );
            return;
        }
        if( String.isBlank( String.valueOf( currentPurchaseOrder.Purchase_Order_Amount__c ) ) ) {
            addMessage( 'Required fields are missing: Purchase Order Amount' );
            return;
        }
        if( String.isBlank( String.valueOf( currentPurchaseOrder.Purchase_Order_Date__c ) ) ) {
            addMessage( 'Required fields are missing: Purchase Order Date' );
            return;
        }
        Decimal totalServicesPrice = 0;
        Decimal totalDiscountedServicesBalance = 0; //MRS-6939
        List<Service_Item__c> serviceItemsToUpdate = new List<Service_Item__c>();
        for( ServiceModel sm : pwm.serviceModels.values() ) { //MRS-6588
            if( sm.isAddedToPurchaseOrder ) {
                serviceItemsToUpdate.add( sm.serviceItemRecord );
                totalServicesPrice += currentPurchaseOrder.PO_Excludes_Sales_Tax__c ? sm.getTotalDiscountedServicePrice() : sm.getTotalDiscountedServicePrice() + sm.getSalesTax(); //MRS 6205
                if( sm.serviceItemRecord.Balance_to_Bill__c != null ) {
					if(!currentPurchaseOrder.PO_Excludes_Sales_Tax__c) { //MRS 7574
						totalDiscountedServicesBalance += sm.serviceItemRecord.Balance_to_Bill__c;  //MRS-6939 
					} else {
						//if(sm.serviceItemRecord.Total_Discounted_Price__c == null) sm.serviceItemRecord.Total_Discounted_Price__c = 0;
						if(sm.serviceItemRecord.Amount_Billed__c == null) sm.serviceItemRecord.Amount_Billed__c = 0;
						totalDiscountedServicesBalance += sm.serviceItemRecord.Balance_to_Bill__c - sm.serviceItemRecord.Sales_Tax_Amount__c * (sm.serviceItemRecord.Balance_to_Bill__c - sm.serviceItemRecord.Sales_Tax_Amount__c - sm.serviceItemRecord.Amount_Billed__c) / sm.serviceItemRecord.Total_Service_Price__c;
					}
				}
            }
        }
        //MRS-7006
        Decimal totalReimbursableBlisAmount = 0;
        currentPurchaseOrder.Total_Disc_Serv_Bal__c = totalDiscountedServicesBalance;
        List<Billing_Line_Item__c> blis = new List<Billing_Line_Item__c> ();
        if( currentPurchaseOrder.Id != null ) { // error Date: Thu, Dec 17, 2015 at 10:23 PM
            blis = [SELECT Amount__c, IsReimbursable__c, Description__c
                       FROM Billing_Line_Item__c
                       WHERE Purchase_Order__c =: currentPurchaseOrder.Id
                            AND Billed__c =: true];
        }
        if( blis != null ) {
            for( Billing_Line_Item__c bli : blis) {
                if( bli.Amount__c != null) {
                    if ( bli.IsReimbursable__c == true ) totalReimbursableBlisAmount += bli.Amount__c;
                    if ( bli.IsReimbursable__c == false && bli.Description__c != null && bli.Description__c == 'Check Processing Fee' ) totalDiscountedServicesBalance += bli.Amount__c;
                }
            }
        }

		System.debug(LoggingLevel.ERROR, '### currentPurchaseOrder.Purchase_Order_Amount__c =' + currentPurchaseOrder.Purchase_Order_Amount__c + ' totalDiscountedServicesBalance =' + totalDiscountedServicesBalance + ' totalReimbursableBlisAmount='+totalReimbursableBlisAmount);
		
        if(currentPurchaseOrder.Purchase_Order_Amount__c - totalDiscountedServicesBalance - totalReimbursableBlisAmount < 0 ) {
            addMessage( 'There are insufficient funds left on this purchase order for the service(s) that you have chosen. This calculation includes both services linked to the PO and reimbursables that have been previously billed against it.' );
            return;
        }
        currentPurchaseOrder.Total_Disc_Serv_Bal__c = totalDiscountedServicesBalance;

        if( totalServicesPrice > currentPurchaseOrder.Purchase_Order_Amount__c ) {
            addMessage( 'Total services price can not exceed Purchase Order Amount' );
            return;
        }
        if( !currentPurchaseOrder.Reimbursables_Only__c && serviceItemsToUpdate.isEmpty()) { //MRS-5745
            addMessage( 'Purchase Orders must be associated with services unless they are only for reimbursables.' );
            return;
        }

        // hot fix, error from prod: 13/01/16, Too many query rows: 50001
        List <LStore__Stored_Document__c> files = new List <LStore__Stored_Document__c> ();
        if (currentPurchaseOrder != null && currentPurchaseOrder.id != null) {
            files  = [SELECT id, purchase_Order__c, name
                        FROM LStore__Stored_Document__c
                        WHERE purchase_Order__c =: currentPurchaseOrder.id];
        }

        if(files.isEmpty()) {
            addMessage( 'You need minimum one file to be added to proceed with this PO.' );
            return;
        }

        currentPurchaseOrder.Proposal__c =  proposal == null ? null : proposal.Id;
        currentPurchaseOrder.Project_Profile__c =  proposal == null ? null : proposal.Project_Profile__c;
        System.Savepoint sp_savePurchaseOrderAction = Database.setSavepoint();

        List<Service_Item__c> servicesToUpdate = new List<Service_Item__c>();
        Set<Id> servicesToUnlinkSetId = new Set<Id>();

        try {
            if( existingPurchaseOrders.containsKey( currentPurchaseOrder.Id ) ) {
                for( Service_Item__c service : currentPurchaseOrder.Covered_Services__r ) {
                        servicesToUnlinkSetId.add( service.Id );
                }
            }
            for( Service_Item__c serviceItem : serviceItemsToUpdate ) {

                if( pwm.serviceModels.containsKey( serviceItem.Id ) && serviceItem.Purchase_Order__c != currentPurchaseOrder.Id ) {
                    servicesToUpdate.add( new Service_Item__c( Id = serviceItem.Id, Purchase_Order__c = currentPurchaseOrder.Id ) );
                    pwm.serviceModels.get( serviceItem.Id ).serviceItemRecord.Purchase_Order__c = currentPurchaseOrder.Id;
                    pwm.serviceModels.get( serviceItem.Id ).isAddedToPurchaseOrder = true;
                    pwm.serviceModels.get( serviceItem.Id ).purchaseOrderNumber = currentPurchaseOrder.Name;

                }
                if( pwm.serviceModels.get( serviceItem.Id ).serviceItemRecord.Purchase_Order__c != null ) servicesToUnlinkSetId.remove( serviceItem.Id );
            }
            for( Id serviceId : servicesToUnlinkSetId ) {
                if( pwm.serviceModels.containsKey( serviceId ) ) {
                    servicesToUpdate.add( new Service_Item__c( Id = serviceId, Purchase_Order__c = null ) );
                    pwm.serviceModels.get( serviceId ).serviceItemRecord.Purchase_Order__c = null;
                    pwm.serviceModels.get( serviceId ).isAddedToPurchaseOrder = false;
                    pwm.serviceModels.get( serviceId ).purchaseOrderNumber = null;
                }
            }
            if( servicesToUpdate.size() > 0 /*&&
                ( ( proposal.Billing_Method__c == ProjectProfileServices.BILLINGMETHODPERCENTAGE && !proposal.Interval__c ) ||
                        proposal.Billing_Method__c == ProjectProfileServices.BILLINGMETHODMILESTONE )*/ ) {

                BillingLineItemServices.serviceTriggerWillAttachPO = true;
                UPSERT currentPurchaseOrder;

                BillingLineItemServices.serviceTriggerWillAttachPO = false;
                UPDATE servicesToUpdate;

            }else{
                UPSERT currentPurchaseOrder;
            }



        } catch( Exception e ) {
            Database.rollback( sp_savePurchaseOrderAction );
            addMessage( 'Error creating purchase order or services.' );
            return;
        }

        try { // MRS 7126
            DELETE [SELECT Id, Purchase_Order_Amount__c, Project_Profile__c, Proposal__c
                                                  FROM Purchase_Order__c
                                                  WHERE Project_Profile__c =: null
                                                      AND Proposal__c =: null
                                                      AND (Purchase_Order_Amount__c =: 0 OR Purchase_Order_Amount__c =: null)
                                                      AND CreatedDate < TODAY];
        } catch ( DMLException ex) {
            addMessage( 'Error during clearing of empty Purchase Orders' );
        }

        //MRS 6860
        try {
            cleanUpPurchaseOrder();
        } catch (Exception e) {
            Database.rollback( sp_savePurchaseOrderAction );
            addMessage( 'Error creating PO services after saving.' );
            return;
        }
        prepareFileUploadPageForCurrentPO();
        updateExistingPurchaseOrders = true;
        purchaseOrderCreated = true;
        currentPurchaseOrdersList = existingPurchaseOrders.values();

        Long startingTime = System.now().getTime();
        Integer delayInMilliseconds = 2000;
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {}
    }

    private List<Purchase_Order__c> currentPurchaseOrdersList = new List<Purchase_Order__c>();
    private Boolean updateProposalPurchaseOrders( Id proposalId ) {
        if( !currentPurchaseOrdersList.isEmpty() ) {
            for( Purchase_Order__c purchaseOrder : currentPurchaseOrdersList ) {
                purchaseOrder.Proposal__c = proposalId;
            }
            try {
               UPDATE currentPurchaseOrdersList;
            } catch( Exception e ) {
                addMessage( 'Error while updating Purchase Orders.' );
                return false;
            }
        }
        return true;
    }

    public void blanketPOAction() {
        if( currentPurchaseOrder.Blanket_PO__c && String.isBlank( String.valueOf( currentPurchaseOrder.Purchase_Order_Amount__c ) ) ) {
            addMessage( 'You can not select Blanket PO when required field is missing: [Purchase Order Amount]' );
            currentPurchaseOrder.Blanket_PO__c = false;
            return;
        }
        Decimal totalServicesPrice = 0.00;
                populateServiceModels(false); // MRS 7230
        for( ServiceModel sm : pwm.serviceModels.values() ) {
            if( sm.isAmendmendDeleted || sm.isAlternative || ( sm.serviceItemRecord.Change_Order__c != null && sm.serviceItemRecord.Change_Order__r.Status__c != ChangeOrderServices.STATUS_APPROVED ) ) continue;
            if( currentPurchaseOrder.Blanket_PO__c ) {
                if( sm.serviceItemRecord.Purchase_Order__c == null && !sm.isAddedToPurchaseOrder && String.IsBlank(sm.purchaseOrderNumber) || sm.serviceItemRecord.Purchase_Order__c == currentPurchaseOrder.Id){
                    sm.isAddedToPurchaseOrder = true;
                    totalServicesPrice += currentPurchaseOrder.PO_Excludes_Sales_Tax__c ? sm.getTotalDiscountedServicePrice() : sm.getTotalDiscountedServicePrice() + sm.getSalesTax(); //MRS 6205
                    totalServicesPrice = totalServicesPrice.setScale(2);
                    if( totalServicesPrice > currentPurchaseOrder.Purchase_Order_Amount__c ) {
                        addMessage( 'Total services price can not exceed Purchase Order Amount' );
                    }
                } else {
                    sm.isAddedToPurchaseOrder = false;
                }
            } else {
                sm.isAddedToPurchaseOrder = false;
            }
        }
    }

    // -------------- Service Bundle Functionality ---------------
    public void loadServiceBundle() {
        try {
            saveProposalIfNotExists();
        } catch( Exception e ) {
            addMessage( e.getMessage() );
            return;
        }
        //recalculateServiceRowPositions();
        createServiceItemsFromRowList( true );

    }

    public transient Boolean serviceBundleChosenCanBeDeleted;
    public Boolean getServiceBundleChosenCanBeDeleted() {
        for( Service_Bundle__c bundleItem : pwm.getServiceBundle( serviceBundleChosen ) ) {
            return getIsAdmin() ? true : !bundleItem.allUsersVisible__c;
        }
        return false;
    }

    public void deleteServiceBundle() {
        if( serviceBundleChosen != null ){
            DELETE new Service_Bundle__c( Id = serviceBundleChosen );
        }
    }

    public String serviceBundleChosen { get; set; }

    public transient List<SelectOption> serviceBundlesToChoose;
    public List<SelectOption> getServiceBundlesToChoose() {
        List<SelectOption> SelectOptions = new List<SelectOption>();
        List<Service_Bundle__c> serviceBundles = pwm.getServiceBundles( building.Region__c );
        for( Service_Bundle__c bundleItem : serviceBundles ) {
            SelectOptions.add( new SelectOption ( bundleItem.id, bundleItem.Bundle_Name__c) );
        }
        if( !serviceBundles.isEmpty() ) {
            serviceBundleChosen = serviceBundles[0].Id;
        }
        return SelectOptions;
    }

    public String serviceBundleName { get; set; }
    public String virtualChangeOrderName { get; set; }

    public void saveServiceBundle() {
        if( !pwm.saveServiceBundle(activeChangeOrderId, serviceBundleName, virtualChangeOrderName, building.Region__c, getIsThisUserAssignedSIPSUser() || getIsSIPSUserInChangeOrder() ) ) {
            addMessage( 'Error creating Service Bundle.' );
        }
        serviceBundleName = '';
    }


    // ------------- Buttons Visibility --------------
    private Project_Team__c assignedProjectTeam;

    private Id currentUserId { get { if( currentUserId == null ) currentUserId = UserInfo.getUserId(); return currentUserId; } set; }

    public transient Boolean isStatusInInternalReview;
    public Boolean getIsStatusInInternalReview() {
        return ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_REVIEW );
    }

    public transient Boolean isThisUserAssignedCZAnalyst;
    public Boolean getIsThisUserAssignedCZAnalyst() {
        return getIsAdmin() ||
               proposal.Status__c != ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW ||
               ( proposal.Code_Zoning_Analyst__c == currentUserId && proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_C_Z_SCOPING_REVIEW );
    }

    public transient Boolean isThisUserCreator;
    public Boolean getIsThisUserCreator() {
        return ProposalWizardServices.isCreator( proposal.Id, proposal.Proposal_Specialist__c, proposal.OwnerId, currentUserId ) || getIsAdmin();
    }

    private Boolean isThisUserProductionManager() {
        return currentUserId == assignedProjectTeam.get(ProjectTeamServices.PRODUCTION_MANAGER_FIELD);
    }

    private Boolean isThisUserSharedServiceCoor() {
        return profileName == UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME && !String.isBlank( proposal.Id ) && proposal.Project_Profile__r.OwnerId == currentUserId;
    }

    //MRS-6570
    private Boolean isThisUserSharedServiceDepartmentManager() {
        return profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER;
    }

    public transient Id assignedIrId;
    public Id getAssignedIrId() {
        if( proposal.Partner_Approval_Required__c ) return proposal.Internal_Reviewer__c; else return null;
    }

    public transient Boolean isSaveDraftButtonVisible;
    public Boolean getIsSaveDraftButtonVisible() {
        return ProposalWizardServices.isSaveDraftButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Id, proposal.Is_Draft__c, getIsMi3() ) ||
               ( proposal.Is_Draft__c && ( getIsClientProjectEnabled() || getIsFulfillmentOfficeEnabled() ) );
    }

    public transient Boolean isSendForInternalReviewButtonVisible;
    public Boolean getIsSendForInternalReviewButtonVisible() {
        return ProposalWizardServices.isSendForInternalReviewButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Partner_Approval_Required__c );
    }

    public transient Boolean isSendToClientButtonVisible;
    public Boolean getIsSendToClientButtonVisible() {
        return ProposalWizardServices.isSendToClientButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isReSendToClientButtonVisible;
    public Boolean getIsReSendToClientButtonVisible() {
        return ProposalWizardServices.isReSendToClientButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isFollowUpButtonVisible;
    public Boolean getIsFollowUpButtonVisible() {
        return ProposalWizardServices.isFollowUpButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isSendForCZScopingReviewButtonVisible;
    public Boolean getIsSendForCZScopingReviewButtonVisible() {
        return ProposalWizardServices.isSendForCZScopingReviewButtonVisible ( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isSubmitButtonVisible;
    public Boolean getIsSubmitButtonVisible() {
        return ProposalWizardServices.isSubmitButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Is_Change_Order__c ) && proposal.Is_Draft__c;
    }

    public transient Boolean isCompleteButtonVisible;
    public Boolean getIsCompleteButtonVisible() {
        return ProposalWizardServices.isCompleteButtonVisible( proposal.Status__c, profileName, currentUserRoleName );
    }

    public transient Boolean isSaveButtonVisible;
    public Boolean getIsSaveButtonVisible() {
        return ProposalWizardServices.isSaveButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Is_Change_Order__c, getAssignedIrId(),
                                                           proposal.Id, proposal.Is_Draft__c, isThisUserProductionManager(), getIsThisUserAssignedSIPSUser(), currentUserId ) ||
               ( !proposal.Is_Draft__c && ( getIsClientProjectEnabled() || getIsFulfillmentOfficeEnabled() || getEnableBillingPreferencesGroupTwo() ) );
    }

    public transient Boolean isApproveButtonVisible;
    public Boolean getIsApproveButtonVisible() {
        return ProposalWizardServices.isApproveButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getAssignedIrId() );
    }

    public transient Boolean isRejectButtonVisible;
    public Boolean getIsRejectButtonVisible() {
        return ProposalWizardServices.isRejectButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getAssignedIrId() );
    }

    public transient Boolean isChangeOrderApprovedButtonVisible;
    public Boolean getIsChangeOrderApprovedButtonVisible() {
        return ProposalWizardServices.isChangeOrderApprovedButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Is_Change_Order__c );
    }

    public transient Boolean isRejectedWithNotesButtonVisible;
    public Boolean getIsRejectedWithNotesButtonVisible() {
        return ProposalWizardServices.isRejectedWithNotesButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isWithdrawnButtonVisible;
    public Boolean getIsWithdrawnButtonVisible() {
        return ProposalWizardServices.isWithdrawnButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isCanceledButtonVisible;
    public Boolean getIsCanceledButtonVisible() {
        return ProposalWizardServices.isCanceledButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator() );
    }

    public transient Boolean isAwardedButtonVisible;
    public Boolean getIsAwardedButtonVisible() {
        return ProposalWizardServices.isAwardedButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Is_Change_Order__c );
    }

    public transient Boolean isNotAwardedButtonVisible;
    public Boolean getIsNotAwardedButtonVisible() {
        return ProposalWizardServices.isNotAwardedButtonVisible( proposal.Status__c, profileName, currentUserRoleName, getIsThisUserCreator(), proposal.Is_Change_Order__c );
    }

    public transient Boolean isSumbitChangeOrderButtonVisible;
    public Boolean getIsSumbitChangeOrderButtonVisible() {
        return ProposalWizardServices.isSumbitChangeOrderButtonVisible( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c );
    }

    public transient Boolean isAnyAllowedProfile;
    public Boolean getIsAnyAllowedProfile() {
        return ProposalWizardServices.isAnyAllowedProfile( profileName, currentUserRoleName );
    }

    public transient Boolean isApproveButtonEnabled;
    public Boolean getIsApproveButtonEnabled() {
        return ProposalWizardServices.isApproveButtonEnabled( proposal.Status__c, profileName, currentUserRoleName, getAssignedIrId(), currentUserId );
    }

    public transient Boolean isRejectButtonEnabled;
    public Boolean getIsRejectButtonEnabled() {
        return ProposalWizardServices.isRejectButtonEnabled( proposal.Status__c, profileName, currentUserRoleName, getAssignedIrId(), currentUserId );
    }

    public transient Boolean areServiceButtonsEnabled;
    public Boolean getAreServiceButtonsEnabled() {
        return ProposalWizardServices.areServiceButtonsEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                                getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                                getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean arePhasesButtonsEnabled;
    public Boolean getArePhasesButtonsEnabled() {
        return ProposalWizardServices.arePhasesButtonsEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                               getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                               getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );//MRS-6570
    }

    public transient Boolean areFloorButtonsEnabled;
    public Boolean getAreFloorButtonsEnabled() {
        return ProposalWizardServices.areFloorButtonsEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                              getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                              getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );//MRS-6570
    }

    public transient Boolean areContactButtonsEnabled;
    public Boolean getAreContactButtonsEnabled() {
        return ProposalWizardServices.areContactButtonsEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                                getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                                getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isFulfillmentOfficeEnabled;
    public Boolean getIsFulfillmentOfficeEnabled() {
        return ProposalWizardServices.isFulfillmentOfficeEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                                  getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                                  getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isClientProjectEnabled;
    public Boolean getIsClientProjectEnabled() {
        return ProposalWizardServices.isClientProjectEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                              getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                              getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isAddPurchaseOrderButtonEnabled;
    public Boolean getIsAddPurchaseOrderButtonEnabled() {
        return ProposalWizardServices.isAddPurchaseOrderButtonEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                                       getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                                       getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isAttachingFilesEnabled;
    public Boolean getIsAttachingFilesEnabled() {
        return ProposalWizardServices.isAttachingFilesEnabled( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                               getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                               getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isSIPSUserInChangeOrder;
    public Boolean getIsSIPSUserInChangeOrder() {
        return pwm.isSIPSUserInChangeOrder( activeChangeOrderId, profileName, currentUserId );
    }

    public transient Boolean enableBillingPreferences;
    public Boolean getEnableBillingPreferences() {
        return ProposalWizardServices.enableBillingPreferences( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                                getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                                getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean enableBillingPreferencesGroupTwo; /*MRS-6197*/
    public Boolean getEnableBillingPreferencesGroupTwo() {
        return getIsFromChangeOrderRequestButton() &&
               ProjectRosterServices.isUserAllowedToChangeBillingPreferences( currentUserId, profileName, currentUserRoleName, proposal, pwr.getUserRosters(), false );
    }

    public Boolean hasBillingOccurredOnProject {
        get {
            if( hasBillingOccurredOnProject == null ) {
                hasBillingOccurredOnProject = ProposalWizardServices.hasBillingOccurredOnProject( proposal.Project_Profile__c );
            }
            return hasBillingOccurredOnProject;
        } set;
    }

    public transient Boolean enableAccountManager;
    public Boolean getEnableAccountManager() {
        return ProposalWizardServices.enableAccountManager( proposal.Status__c, profileName, currentUserRoleName, proposal.Is_Change_Order__c,
                                                            getIsThisUserCreator(), disableInputs, isThisUserProductionManager(), isThisUserSharedServiceCoor(),
                                                            getIsChangeOrderAllowedOnProjectOrServiceItemLevel(), getIsFromChangeOrderRequestButton(), canCreateNewCoOrUserInRoster() );
    }

    public transient Boolean isThisUserAssignedSIPSUser;
    public Boolean getIsThisUserAssignedSIPSUser() {
        return ( proposal.Status__c == ProposalServices.PROPOSAL_STATUS_IN_REVIEW ) &&
               ( ( getIsAdmin() ) ||
                 ( proposal.Internal_Reviewer__c == currentUserId &&
                   profileName.contains( UserServices.PROFILE_SIPS_DEPARTMENT_MANAGER ) ) ||
                 ( proposal.SIPS_Coordinator__c == currentUserId &&
                   profileName.contains( UserServices.PROFILE_SIPS_COORDINATOR ) ) );
    }

    public transient Boolean isSIPSOnly;
    public Boolean getIsSIPSOnly() {
        return ( getIsThisUserAssignedSIPSUser() || getIsSIPSUserInChangeOrder() ) && !getIsAdmin();
    }

    public transient Boolean isCreateNewChangeOrderVisible;
    public Boolean getIsCreateNewChangeOrderVisible() {
        return canCreateNewCoOrUserInRoster();
    }

    public Boolean canCreateNewCo() {
        return ( proposal.is_Change_Order__c ) &&
               ( getIsAdmin() || //profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN
                 ( ( getIsFromChangeOrderRequestButton() ) &&
                   ( getIsPManager1() || //profileName == UserServices.PROFILE_PROJECT_MANAGER_1
                     getIsPManager2() || //profileName == UserServices.PROFILE_PROJECT_MANAGER_2
                     isThisUserSharedServiceCoor() || //profileName == UserServices.SHARED_SERVICES_COORDINATOR_PROFILE_NAME && !String.isBlank( proposal.Id ) && proposal.Project_Profile__r.OwnerId == currentUserId
                     isThisUserSharedServiceDepartmentManager() || //MRS-6570 //profileName == UserServices.PROFILE_SHARED_SERVICES_DEPARTMENT_MANAGER
                     profileName == UserServices.PROFILE_DIRECTOR_OF_OPERATIONS || //MRS-6507
                     profileName == UserServices.PROFILE_A_R_CORDINATOR || //MRS-5851
                     profileName == UserServices.PROFILE_ACCOUNTING_SUPERVISOR || //MRS-5851
                     profileName == UserServices.PROFILE_CFO || //MRS-5851
                     profileName == UserServices.PROFILE_FINANCE_MANAGER || //MRS-5851
                     profileName == UserServices.PROFILE_STAFF_ACCOUNTANT || //MRS-5851
                     proposal.Project_Profile__r.OwnerId == currentUserId  ||
                     UserServices.isProjectManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Project_Manager__c, proposal.Project_Profile__r.Project_Member__c ) ||
                     UserServices.isProductionManagerAssignedToProject( currentUserId, profileName, proposal.Project_Profile__r.Production_Manager__c ) ||
                     isThisUserProductionManager() ||
                     getIsChangeOrderAllowedOnProjectOrServiceItemLevel() ) ) );
    }

    public Boolean canCreateNewCoOrUserInRoster() {
        return canCreateNewCo() || ( getIsFromChangeOrderRequestButton() && pwm.isUserInRoster );
    }

    public transient Boolean isChangeOrderAllowedOnProjectOrServiceItemLevel;
    public Boolean getIsChangeOrderAllowedOnProjectOrServiceItemLevel() {
        return ProposalWizardServices.isUserAllowedToCreateChangeOrderOnProjectLevel( currentUserId, profileName, currentUserRoleName, proposal ) ||
               ProposalWizardServices.isUserAllowedToCreateChangeOrderOnServiceItemLevel( currentUserId, profileName, currentUserRoleName, proposal, null, pwm.serviceModels.values() );
    }

    public Boolean getIsFromChangeOrderRequestButton() {
        return !ApexPages.currentPage().getParameters().containsKey('mode') && proposal.is_Change_Order__c;
    }

    public String getMode() {
        return ApexPages.currentPage().getParameters().get('mode');
    }

    public transient Boolean isSubmitButtonEnabled;
    public Boolean getIsSubmitButtonEnabled() {
        return !( proposal.Is_Draft__c &&
                  !String.isBlank(proposal.sowSpaceAlterType__c) &&
                   proposal.sowSpaceAlterType__c.contains('Single Permit') &&
                   proposal.sowSpaceAlterType__c != 'Single Permit' ) ||
                ( getIsIrValid() && getIsIdValid() && getIsErValid() && getIsFaValid() && getIsSpValid() && getIsSmValid() );
    }

    public Boolean getIsIrValid() { return !ProposalWizardServices.getIrServices( proposal, true, false, false ).isEmpty(); }
    public Boolean getIsIdValid() { return !ProposalWizardServices.getIdServices( proposal, true, false, false ).isEmpty(); }
    public Boolean getIsErValid() { return !ProposalWizardServices.getErServices( proposal, true, false, false ).isEmpty(); }
    public Boolean getIsFaValid() { return !ProposalWizardServices.getFaServices( proposal, true, false, false ).isEmpty(); }
    public Boolean getIsSpValid() { return !ProposalWizardServices.getSpServices( proposal, true, false, false ).isEmpty(); }
    public Boolean getIsSmValid() { return !ProposalWizardServices.getSmServices( proposal, true, false, false ).isEmpty(); }

    public String drawingsTitle { get; set;}
    public String drawingsDescriptioin { get; set;}
    public String drawingsNumber { get; set;}
    public Date drawingsRevisionDate { get; set;}

    public void updateArtifacts() {
        Id projectId;
        if( !String.isBlank(proposal.Id)) {
            projectId = proposal.Project_Profile__c;
        }

        List<LStore__Stored_Document__c> createdStoredDocument = [ Select Id, Drawings_Title__c
                                                                   From LStore__Stored_Document__c
                                                                   Where Related_Object_Id__c = :String.valueOf( proposal.Id )
                                                                   Order By CreatedDate Desc LIMIT 1 ];

        if( !createdStoredDocument.isEmpty() ) {
            LStore__Stored_Document__c currentDoc = createdStoredDocument[0];
            currentDoc.RecordTypeId = StoredDocumentServices.DRAWINGS_RECORD_TYPE_ID;
            currentDoc.Proposal__c = proposal.Id;
            currentDoc.Project__c = projectId;
            currentDoc.Address__c = proposal.Address__c;
            currentDoc.Applicant__c = proposal.Accounting_Contact_Company__c;

            currentDoc.Drawings_Title__c = drawingsTitle;
            currentDoc.Drawings_Description__c = drawingsDescriptioin;
            currentDoc.Drawing_Number__c = drawingsNumber;
            currentDoc.Drawing_Revision_Date__c = drawingsRevisionDate;
        }
        UPDATE createdStoredDocument;
        drawingsTitle = null; //
        drawingsDescriptioin = null; //
        drawingsNumber = null; //
        drawingsRevisionDate = null; //
    }

    public void removeChangeOrder() {
        if( !pwm.deleteChangeOrder(activeChangeOrderId) ) addMessage( 'Error removing Change Order.' );
        activeChangeOrderId = null;
    }
    public void addChangeOrder() {
        if( !pwm.addChangeOrder() ) addMessage( 'Error creating Change Order.' );
    }

    private void addMessage( String message ) {
        addMessage( message, 'Error' );
    }

    private void addMessage( String message, String type ) {
        if( type == 'Error' ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, message ) ); return; }
        if( type == 'Info' ) { ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Info, message ) ); return; }
    }

    public Id activeChangeOrderId { get; set; }

    // Create Wave Project from MI3 Proposal Start
    private Id projectTeamIdForMI3ProjectCreation { get; set; }
    private Id frepIdForMI3ProjectCreation { get; set; }

    public PageReference createMI3Project() {
        if( ProposalWizardServices.getCompleteness( ProposalWizardServices.getProposalRequiredFields( true, proposal.CreatedDate, proposal.Is_Draft__c ),
                                                    proposal,
                                                    true, //hasFloors
                                                    pwm.serviceModels.values() ) < 100 ) {
            addMessage( 'Your changes have not been saved. Please make sure all mandatory fields on all steps are filled out.' );
            return null;
        }
        Savepoint createMI3ProjectSP = Database.setSavePoint();
        //saveDraft();
        projectTeamIdForMI3ProjectCreation = proposal.Project_Team__c;
        frepIdForMI3ProjectCreation = proposal.FREP__c;
        try {
            proposal.Project_Team__c = null;
            //System.debug( LoggingLevel.Error, 'xxx setteam complete: ' );
            complete();
            proposal.Project_Team__c = projectTeamIdForMI3ProjectCreation;
            proposal.FREP__c = frepIdForMI3ProjectCreation;
            if( getIsAllOSServices() ) {
                projectTeamIdForMI3ProjectCreation = null;
                frepIdForMI3ProjectCreation = null;
            }
            return null;
        } catch( Exception ex ) {
            addMessage( 'Error updating Proposal: ' + ex.getMessage() );
            undoCreateMI3Project();
            proposal.Project_Team__c = projectTeamIdForMI3ProjectCreation;
            proposal.FREP__c = frepIdForMI3ProjectCreation;
            Database.rollback( createMI3ProjectSP );
            return null;
        }
    }

    public PageReference createMI3ProjectStage2() {
        Savepoint createMI3ProjectSP2 = Database.setSavePoint();
        try {
            Proposal__c proposalToUpdate = new Proposal__c( Id = proposal.Id, Assigner_OM__c = getIsExistAPSService(), Assigner_SS__c = getIsAllOSServices(),
                                                            Proposal_Awarded_Date__c = Date.today(), Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED,
                                                            Is_Mi3_Project_Created__c = true, Project_Team__c = projectTeamIdForMI3ProjectCreation,
                                                            FREP__c = frepIdForMI3ProjectCreation );
            PreventTwiceExecution.proposalFirstRun = true;
            ServiceItemServices.preventorUpdateServiceItemOwner = false;
            UPDATE proposalToUpdate;
            List<Project_Profile__c> projectIds = [SELECT Proposal__c FROM Project_Profile__c WHERE Proposal__c = : proposal.Id];
            if( !projectIds.isEmpty() && !String.isBlank( projectIds[0].Proposal__c ) ) {
                PageReference retUrl = new PageReference('/' + projectIds[0].Id);
                retUrl.setRedirect(true);
                return retUrl;
            } else {
                addMessage( 'Error Creating Project.' );
                Database.rollback( createMI3ProjectSP2 );
                undoCreateMI3Project();
                return null;
            }
        } catch( Exception ex ) {
            addMessage( 'Error Creating Project: ' + ex.getMessage() );
            Database.rollback( createMI3ProjectSP2 );
            undoCreateMI3Project();
            return null;
        }
        return null;
    }

    public void undoCreateMI3Project() {
        proposal.Is_Mi3_Project_Created__c = false;
        proposal.Is_Draft__c = true;
        proposal.Assigner_OM__c = false;
        proposal.Assigner_SS__c = false;
        proposal.Proposal_Awarded_Date__c = null;
        proposal.Status__c = ProposalServices.PROPOSAL_STATUS_NEW;
        proposal.Is_Mi3_Project_Created__c = false;
        UPDATE new Proposal__c( Id = proposal.Id, Is_Draft__c = true, Assigner_OM__c = false, Assigner_SS__c = false,
                                Proposal_Awarded_Date__c = null, Status__c = ProposalServices.PROPOSAL_STATUS_NEW,
                                Is_Mi3_Project_Created__c = false, Project_Team__c = null, FREP__c = null );
    }
    // Create Wave Project from MI3 Proposal End

    public transient Boolean isAdmin;
    public Boolean getIsAdmin() { return profileName == UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN; }

    public transient Boolean isPManager1;
    public Boolean getIsPManager1() { return profileName == UserServices.PROFILE_PROJECT_MANAGER_1; }

    public transient Boolean isPManager2;
    public Boolean getIsPManager2() { return profileName == UserServices.PROFILE_PROJECT_MANAGER_2; }

    public transient Boolean isPS;
    public Boolean getIsPS() { return ProposalWizardServices.isPsExAdmOmLiCzAdmin( profileName, currentUserRoleName ); }

    public transient Boolean isAM;
    public Boolean getIsAM() { return profileName == UserServices.PROFILE_ACCOUNT_MANAGER; }

    public transient Boolean isPartner;
    public Boolean getIsPartner() { return profileName == UserServices.PROFILE_PARTNER; }

    public transient Boolean isCZAnalyst;
    public Boolean getIsCZAnalyst() { return profileName == UserServices.PROFILE_CODE_ZONING_ANALYST; }

    public transient Boolean isAssignedInternalReviewer;
    public Boolean getIsAssignedInternalReviewer() { return currentUserId == getAssignedIrId(); }

    public transient Boolean isPreviewPdfDisabled;
    public Boolean getIsPreviewPdfDisabled() {
        return ProposalWizardServices.isPreviewPdfDisabled( proposal, getIsThisUserCreator(), profileName, getIsAdmin(), getIsPS(), getIsCZAnalyst() );
    }

    public transient Boolean showAlternativeServicesTable;
    public Boolean getShowAlternativeServicesTable() { //MRS6931
        return ProposalWizardServices.showAlternativeServicesTable( proposal, pwm, getIsThisUserCreator(), getIsAdmin(), getIsPartner(), getIsPS(), getIsAM(), getIsCZAnalyst(), getIsAssignedInternalReviewer(), getIsPManager1(), getIsPManager2() );
    }

    public transient Boolean disableReceivedSignedProposalCheckbox;
    public Boolean getDisableReceivedSignedProposalCheckbox() {
        return ProposalWizardServices.disableReceivedSignedProposalCheckbox( proposal, getIsThisUserCreator(), profileName, currentUserRoleName );
    }

    public void manageFollowups() {
        try {
            if( String.isBlank( changeCoStatusCoId ) ) {
                if( !String.isBlank( proposal.Id ) ) {
                    UPDATE new Proposal__c( Id = proposal.Id, Disable_Followups__c = proposal.Disable_Followups__c );
                }
            } else {
                UPDATE new Change_Order__c( Id = changeCoStatusCoId, Disable_Followups__c = pwm.changeOrderModelMap.get( changeCoStatusCoId ).changeOrderRecord.Disable_Followups__c );
            }
            if( ProposalWizardServices.enableCreateAutomaticFollowUps( proposal, changeCoStatusCoId, pwm, true, false ) ) {
                pwr.createRosterEmailJunctions( pwm, proposal, changeCoStatusCoId, false, true );
            } else {
                DELETE pwr.getRosterEmailJunctionsForDeletion( proposal, changeCoStatusCoId, false, true );
            }
        } catch( DmlException ex ) {
            addMessage( 'There was an error while adding or removing automatic follow-ups: ' + ex.getMessage() );
        }
        changeCoStatusCoId = null;
    }

    public transient Boolean enableAutomaticFollowUps;
    public Boolean getEnableAutomaticFollowUps() {
        return ProposalWizardServices.enableCreateAutomaticFollowUps( proposal, null, pwm, false, true );
    }

    public Boolean getHasPendingChangeOrders() {
        return ProposalWizardServices.hasPendingChangeOrders( pwm );
    }

    public transient Boolean isUseDocusignEditable;
    public Boolean getIsUseDocusignEditable() {
        return ProposalWizardServices.isUseDocusignEditable( profileName, currentUserRoleName, proposal.Status__c, currentUserId, getAssignedIrId(), getIsThisUserCreator(), getHasPendingChangeOrders() );
    }

    @RemoteAction
    public static Boolean changeAddReimbMuniFeeInvStatus(Id idx, Boolean val) { //MRS 7298
        UPSERT (new Additional_Reimbursable__c(Id = idx, Send_Muni_Fee_Invoice__c = val));
        return true;
    }

}