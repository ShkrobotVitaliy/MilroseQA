public with sharing class BuildingController{
    public Building__c building {get;set;}
    public List<Munucipalities__c> municipalityList {get;set;}
    public List<selectOption> regionOptions {get;set;}
    public List<selectOption> municipalityOptions {get;set;}
    public List<selectOption> states {get;set;}
    //public List<Contact> ownerContactList {get; set;}
    public List<selectOption> ownerContactOptions {get; set;}

    public String regionId {get; set;}
    public String buildingStreet { get;set { building.Street__c = value; buildingStreet = value; } }
    public Boolean buildingWasCreated {get; set;}
    public String buildingId {get;set;}
    public String disableRegion {get;set;}

    public Contact ownerCompanyHolder {get;set;}
    public Contact businessNameAgencyHolder {get;set;}

    public Id selectedContactOwner1 {get; set;}
    public Id selectedContactOwner2 {get; set;}
    
    public BuildingController() {
        buildingId = ApexPages.currentPage().getParameters().get('buildingId');
        disableRegion = ApexPages.currentPage().getParameters().get('disableRegion');
        building = new Building__c();
        states = ProposalWizardServices.generateOptions(null, ProposalWizardServices.getPicklistOptions(Building__c.sObjectType, 'State__c'), true, true);
        List<Region__c> regionList = new List<Region__c>([Select Name, Id, (Select Id, Name From Municipalities__r) From Region__c]);
        Map<String, String> regionMap = new Map<String, String>();
        for(Region__c region: regionList ) {
            regionMap.put(region.Id, region.Name);
        }
        regionOptions = ProposalWizardServices.generateOptions(null, regionMap, true, true);

        ownerCompanyHolder = new Contact();
        businessNameAgencyHolder = new Contact();
        
        if( !String.isBlank(buildingId) ) {
            List<Building__c> buildings = [SELECT Municipality__c, Street__c, House_No__c, City__c, PostalCode__c, State__c, Building_Owner__c,
                                             Description__c, Is_Landmark__c, Is_MTA__c, Little_E_Designation__c, Loft_Board_Authority__c,
                                             Municipality__r.Region__c, OwnerShip__c, Owner_Company__c, Owner_Contact_1__c, Owner_Contact_1__r.Name,
                                             Owner_Contact_2__c, Building_Manager__c, Business_Name_Agency__c, Family_1_2_3__c,
                                             Private_Street__c, Legal_Street_Width__c, Street_Frontage__c, POPS__c, 
                                             Zoning3__c, Zoning2__c, Zoning1__c, Special_Zoning__c
                                           FROM Building__c
                                           WHERE Id =: buildingId];
            if( !buildings.isEmpty() ) {
                building = buildings[0];
                buildingStreet = building.Street__c;
                regionId = building.Municipality__r.Region__c;
                
                selectedContactOwner1 = building.Owner_Contact_1__c;
                selectedContactOwner2 = building.Owner_Contact_2__c;
                
                ownerCompanyHolder = new Contact (AccountId = building.Owner_Company__c);
                businessNameAgencyHolder = new Contact (AccountId = building.Business_Name_Agency__c);
                
                updateMunicipalityOptions(false);
                updateContactOptions();
            }
        } else {
            updateMunicipalityOptions();
            updateContactOptions();
        }
        buildingWasCreated = false;
    }

    public void updateMunicipalityOptions(){
        updateMunicipalityOptions(true);
    }

    public void updateMunicipalityOptions( Boolean toBlankMunicipality ){
        municipalityList = new List<Munucipalities__c>([Select Id, Region__c, Name From Munucipalities__c where Region__c =: regionId]);
        Map<String, String> municipalityMap = new Map<String, String>();
        for(Munucipalities__c municipality: municipalityList ) {
            municipalityMap.put(municipality.Id, municipality.Name);
        }
        municipalityOptions = ProposalWizardServices.generateOptions(null, municipalityMap, true, true);
        if( toBlankMunicipality ) building.Municipality__c = null;
    }

    public void updateContactOptions (){
        
        List<Id> accIds = new List<Id>();
        
        if (ownerCompanyHolder.AccountId != null){
            accIds.add(ownerCompanyHolder.AccountId);
        }
        if (businessNameAgencyHolder.AccountId != null){
            accIds.add(businessNameAgencyHolder.AccountId);
        }
        
        Map<Id, Contact> ownerContactList = new Map<Id, Contact>( getContactsByIds(accIds) );

        //setup select list of contacts
        ownerContactOptions = new List<selectOption>{ new SelectOption( '', '-- None --' ) };
       
        if (! ownerContactList.isEmpty() ) {
            
            for (Contact contactItem : ownerContactList.values()){
                ownerContactOptions.add( new SelectOption( contactItem.Id, contactItem.Name ) );
            }
            //clear selected contacts if they are not children of selected accounts
            if (! ownerContactList.containsKey(selectedContactOwner1)){
                selectedContactOwner1 = null;
            }
            if (! ownerContactList.containsKey(selectedContactOwner2)){
                selectedContactOwner2 = null;
            }               
        }
               
    }

    public void createNewBuilding() {
        if( String.isBlank(building.State__c) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Required fields are missing: [State]' ) );
            return;
        }
        if( String.isBlank(building.Ownership__c) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Required fields are missing: [Ownership]' ) );
            return;
        }
        if( ownerCompanyHolder.AccountId == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Required fields are missing: [Owner Company]' ) );
            return;
        } 
        if( selectedContactOwner1 == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'Required fields are missing: [Owner Contact 1]' ) );
            return;
        }
        
        building.Owner_Company__c = ownerCompanyHolder.AccountId;
        building.Business_Name_Agency__c = businessNameAgencyHolder.AccountId;
        
        building.Owner_Contact_1__c = selectedContactOwner1;
        building.Owner_Contact_2__c = selectedContactOwner2;

        try {
            upsert building;
            buildingId = building.Id;
            buildingWasCreated = true;
        } catch(System.DMLException e) {
            buildingWasCreated = false;
        }
    }
    
    /* DAO Methods*/
    
    private static List<Contact> getContactsByIds(List<Id> accIds){
        return [SELECT Id, Name, AccountId
                FROM Contact 
                WHERE AccountId IN : accIds
                ORDER BY Name];
    }
    
}