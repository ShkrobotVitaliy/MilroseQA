//@isTest
public class TestingUtils{
    public static final String FF_GROUP_NAME_VALUE = 'FF Milrose Consultants, Inc.';

    public static final String CLOSED_PERIOD_ERROR = 'You cannot save a document that falls within a closed period.';

    private static final Integer NUMBER_TO_CREATE_ACCOUNT = 3;
    private static final Integer NUMBER_TO_CREATE_REGION = 1;
    private static final Integer NUMBER_TO_CREATE_MUNICIPALITIES = 1;
    private static final Integer NUMBER_TO_CREATE_BUILDING = 1;
    private static final Integer NUMBER_TO_CREATE_PROJECT_TEAM = 2;

    public static List<Project_Team__c> testProjectTeamList;
    public static List<Account> testAccountList;
    public static List<Contact> testContactWithAccountList;
    public static List<Region__c> testRegionList;
    public static List<Munucipalities__c> testMunucipalitiesList;
    public static List<Building__c> testBuildingList;
    public static List<Proposal__c> testProposalList;
    public static List<Project_Profile__c> testProjectProfileList;

    public static User testPartnerUser;
    public static User testProjectManagerUser;
    public static Id testCurrentUserId;
    public static User testProductionManagerUser;

    public static void setupData (){
        testPartnerUser = userWithProfile ('Partner');
        testProjectManagerUser = userWithProfile (UserServices.PROFILE_PROJECT_MANAGER_2);
        testProductionManagerUser = userWithProfile (UserServices.PROFILE_PRODUCTION_MANAGER);
        testCurrentUserId = UserInfo.getUserId ();
        testProjectTeamList = createProjectTeamList (NUMBER_TO_CREATE_PROJECT_TEAM, testCurrentUserId, testProjectManagerUser.Id, true);
        testAccountList = createAccountList (NUMBER_TO_CREATE_ACCOUNT, null, true);
        testContactWithAccountList = createContactList (1, new List<Id>{testAccountList[0].Id, testAccountList[1].Id, testAccountList[2].Id}, true);
        testRegionList = createRegionList (NUMBER_TO_CREATE_REGION, 'New York', true);
        testMunucipalitiesList = createMunicipalitiesList (NUMBER_TO_CREATE_MUNICIPALITIES, null, testRegionList[0].Id, true);
        testBuildingList = createBuildingList (NUMBER_TO_CREATE_BUILDING, testMunucipalitiesList[0].Id, null, null, null, null, true);
    }

    public static List<Project_Profile__c> createProjectProfileForTest(Integer numberToCreate, Boolean doInsert){
        if (testProjectTeamList == null || testAccountList == null || testContactWithAccountList == null || testRegionList == null ||
            testMunucipalitiesList == null || testBuildingList == null || testPartnerUser == null || testProjectManagerUser == null ||
            testCurrentUserId == null){
            setupData ();
        }

        List<Proposal__c> proposalList = createProposalListForTest(numberToCreate, true);

        List<Project_Profile__c> createdProjectProfileList = createProjectProfileList ( numberToCreate, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                        testAccountList[1].Id, testContactWithAccountList[1].Id, testAccountList[2].Id,
                                                                                        testContactWithAccountList[2].Id, testProjectManagerUser.Id, false );

        Integer i = 0;
        for (Project_Profile__c projectProfileItem : createdProjectProfileList) {
            projectProfileItem.Project_Team__c = testProjectTeamList[0].Id;
            projectProfileItem.Building__c = proposalList[i].Address__c;
            projectProfileItem.Proposal__c = proposalList[i++].Id;
        }
        if (doInsert){
            insert createdProjectProfileList;
        }
        return createdProjectProfileList;
    }

    public static List<Proposal__c> createProposalListForTest(Integer numberToCreate, Boolean doInsert){
        if (testProjectTeamList == null || testAccountList == null || testContactWithAccountList == null || testRegionList == null ||
            testMunucipalitiesList == null || testBuildingList == null || testPartnerUser == null || testProjectManagerUser == null ||
            testCurrentUserId == null){
            setupData ();
        }

        List<Proposal__c> createdProposalList = TestingUtils.createProposalList (numberToCreate, null, testAccountList[0].Id, testContactWithAccountList[0].Id,
                                                                                 testAccountList[1].Id, testContactWithAccountList[1].Id, testBuildingList[0].Id,
                                                                                 null, null, null, null, testPartnerUser.Id, testCurrentUserId,
                                                                                 testProjectManagerUser.Id, false);
        if(doInsert){
            insert createdProposalList;
        }
        return createdProposalList;
    }

    public static void createProposalWithProjectProfileList(Integer numberToCreate){
        testProposalList = createProposalListForTest(numberToCreate, true);
        testProjectProfileList = createProjectProfileForTest(numberToCreate, false);
        for (Integer i = 0; i < numberToCreate; i++){
            testProjectProfileList[i].Proposal__c = testProposalList[i].Id;
        }
        insert testProjectProfileList;
        for (Integer i = 0; i < numberToCreate; i++){
            testProposalList[i].Project_Profile__c = testProjectProfileList[i].Id;
            testProposalList[i].Project_Team__c = testProjectProfileList[i].Project_Team__c;
        }
        update testProposalList;
    }

    public static final String FF_USER_STANDART_USER_STRING = 'Account Manager';

    private static List<Profile> currentProfileList{
        get{
            if (currentProfileList == null){
                currentProfileList = [SELECT Id, Name, UserLicense.Name FROM Profile];
            }
            return currentProfileList;
        }
        set{}
    }

    private static Map<String, Id> mapProfileNameId {
        get{
            if (mapProfileNameId == null){
                mapProfileNameId = new Map<String, Id>();
                for (Profile profileItem : currentProfileList){
                    mapProfileNameId.put(profileItem.Name, profileItem.Id);
                }
            }
            return mapProfileNameId;
        }
        set {}
    }

    /*private static Map<Id, String> mapProfileIdName {
        get{
            if (mapProfileIdName == null){
                mapProfileIdName = new Map<Id, String>();
                for (Profile profileItem : currentProfileList){
                    mapProfileIdName.put(profileItem.Id, profileItem.Name);
                }
            }
            return mapProfileIdName;
        }
        set {}
    }*/

    private static Map<String, List<Profile>> mapUserLicensProfiles{
        get {
            if (mapUserLicensProfiles == null){
                mapUserLicensProfiles = new Map<String, List<Profile>>();
                for (Profile profileItem : currentProfileList){
                    if (!mapUserLicensProfiles.containsKey(profileItem.UserLicense.Name)){
                        mapUserLicensProfiles.put(profileItem.UserLicense.Name, new List<Profile>());
                    }
                    mapUserLicensProfiles.get(profileItem.UserLicense.Name).add(profileItem);
                }
            }
            return mapUserLicensProfiles;
        }
        set{}
    }

    private static String userLicenseByProfileId(Id userProfileId){
        return new Map<Id, Profile>(currentProfileList).get(userProfileId).UserLicense.Name;
    }

    public static String userLicenseByProfileName(String userProfileName){
        return userLicenseByProfileId(mapProfileNameId.get(userProfileName));
    }

    /*public static Id userProfileIdByProfileName (String userProfileName){
        return mapProfileNameId.containsKey(userProfileName) ? mapProfileNameId.get(userProfileName) : null;
    }

    public static String userProfileNameByProfileId (Id profileId){
        return mapProfileIdName.get(profileId);
    }*/

    public static List<Profile> userProfilesByUserLicenseName (String userLicenseName){
        return mapUserLicensProfiles.get(userLicenseName);
    }

    /*public static List<User> userByUserLicensName(String userLicenseName){
        return [SELECT Id, Name, ProfileId FROM User WHERE ProfileId IN : mapUserLicensProfiles.get(userLicenseName)];
    }*/

    public static User userWithProfile (String userProfileName){
        User userItem;
        Id userProfileId = mapProfileNameId.get(userProfileName);

        List<User> userItemList = [SELECT Id, ProfileId
                                   FROM User
                                   WHERE Id != : UserInfo.getUserId()
                                   AND isActive = true
                                   AND ProfileId IN : userProfilesByUserLicenseName(userLicenseByProfileName(userProfileName))];

        if (!userItemList.isEmpty()){
            for (User u : userItemList){
                if (u.ProfileId == userProfileId){
                    userItem = u;
                    break;
                }
            }
            if (userItem == null){
                userItem = userItemList[0];
                userItem.ProfileId = userProfileId;
                System.runAs([SELECT Id FROM User WHERE Id = : UserInfo.getUserId()][0]){
                    update userItem;
                }
            }
        }
        if (userItem == null){
            userItem = new User (ProfileId = userProfileId, Email = 'sometestemail@milrose.com', Username = 'SomeTestUserName',
                                 LastName = 'SomeTestUserLastName', CommunityNickname = 'SomeTestUserCominityName', TimeZoneSidKey = 'America/New_York',
                                 LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
            System.runAs([SELECT Id FROM User WHERE Id = : UserInfo.getUserId()][0]){
                insert userItem;
            }
        }
        return userItem;
    }

    public static List<Document> createDocumentList (Integer numberToCreate, String documentName, Id documentFolderId, Boolean doInsert){
        documentName = String.isEmpty(documentName) ? 'test_doc' : documentName;
        documentFolderId = documentFolderId == null ? [SELECT Id, Name FROM Folder LIMIT 1][0].Id : documentFolderId;
        List<Document> documentList = new List<Document>();
        for (Integer i = 0; i < numberToCreate; i++){
            documentList.add(new Document(Name = documentName + i, FolderId = documentFolderId));
        }
        if (doInsert){
            insert documentList;
        }
        return documentList;
    }

    /*public static List<Product2> createProduct2List (Integer numberToCreate, String product2Name, Id serviceSetupId, Boolean doInsert){
        serviceSetupId = serviceSetupId == null ? createServiceSetupList(1, true)[0].Id : serviceSetupId;
        product2Name = String.isEmpty(product2Name) ? 'test product2 name' : product2Name;
        List<Product2> product2List = new List<Product2>();
        for (Integer i = 0; i < numberToCreate; i++){
            product2List.add(new Product2(Name = product2Name + i));//, Service_Setup_Link__c = serviceSetupId));
        }
        if (doInsert){
            insert product2List;
        }
        return product2List;
    }*/

    public static List<Product2> createProduct2List (Integer numberToCreate, String product2Name, Boolean doInsert){
        product2Name = String.isEmpty(product2Name) ? 'test product2 name' : product2Name;
        List<Product2> product2List = new List<Product2>();
        for (Integer i = 0; i < numberToCreate; i++){
            product2List.add(new Product2(Name = product2Name + i));
        }

        if (doInsert){
            insert product2List;
        }

        return product2List;
    }

    public static List<Account> createAccountList (Integer numberToCreate, String accountName, Boolean doInsert){
        List<Account> accountListItem = new List<Account>();
        for (Integer i = 0; i < numberToCreate; i++){
            accountListItem.add(new Account(Name = String.isEmpty(accountName) ? 'Test Account' : accountName));
        }
        if (doInsert){
            insert accountListItem;
        }
        return accountListItem;
    }

    public static List<Contact> createContactList (Integer numberToCreate, Boolean doInsert){
        List<Contact> contactListItem = new List<Contact>();
        Id accountId = createAccountList (1, 'test account', true)[0].Id;
        for (Integer i=0; i<numberToCreate; i++){
            contactListItem.add(new Contact(LastName = 'LastName' + i, FirstName = 'FirstName' + i, AccountId = accountId));
        }
        if (doInsert){
            insert contactListItem;
        }
        return contactListItem;
    }

    public static List<Contact> createContactList(Integer numberToCreate, Id accountId, Boolean doInsert){
        List<Contact> contactListItem = new List<Contact>();
        for (Integer i=0; i<numberToCreate; i++){
            contactListItem.add(new Contact(LastName = 'LastName' + i, FirstName = 'FirstName' + i, AccountId = accountId));
        }
        if (doInsert){
            insert contactListItem;
        }
        return contactListItem;
    }

    public static List<Contact> createContactList(Integer numberToCreate, List<Id> accountIdList, Boolean doInsert){
        List<Contact> contactListItem = new List<Contact>();
        for (Id accountIdItem : accountIdList){
            contactListItem.addAll(createContactList(numberToCreate, accountIdItem, false));
        }
        if (doInsert){
            insert contactListItem;
        }
        return contactListItem;
    }

    public static List<Purchase_Order__c> createPurchaseOrderList(Integer numberToCreate, Date orderDate, Boolean doInsert){
        List<Purchase_Order__c> purchaseOrderListItem = new List<Purchase_Order__c>();
        orderDate = orderDate == null ? Date.today() : orderDate;
        for (Integer i = 0; i < numberToCreate; i++){
            purchaseOrderListItem.add ( new Purchase_Order__c (Purchase_Order_Date__c = orderDate) );

        }
        if (doInsert){
            insert purchaseOrderListItem;
        }
        return purchaseOrderListItem;
    }

    public static List<Service_Item__c> createServiceItemList(Integer numberToCreate, Boolean doInsert){
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        List<Proposal__c> proposals = createProposalListForTest( numberToCreate, true);
        for (Integer i = 0; i < numberToCreate; i++) serviceItemList.add( new Service_Item__c( Proposal__c = proposals[i].Id ) );
        if( doInsert ) {
            insert serviceItemList;
        }
        return serviceItemList;
    }

    /*public static List<Service_Setup__c> createServiceSetupList(Integer numberToCreate, Boolean doInsert){
        List<Service_Setup__c> serviceSetupList = new List<Service_Setup__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            serviceSetupList.add(new Service_Setup__c());
        }
        if(doInsert){
            insert serviceSetupList;
        }
        return serviceSetupList;
    }*/

    public static List<Service_Item__c> createServiceItemList(Integer numberToCreate, Id proposalId, Boolean doInsert){
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for (Integer i = 0; i < numberToCreate; i++) {
            serviceItemList.add( new Service_Item__c( Proposal__c = proposalId ) );
        }
        if(doInsert){
            insert serviceItemList;
        }
        return serviceItemList;
    }

    public static List<Service_Item__c> createServiceItemList(Integer numberToCreate, List<Proposal__c> proposalList, Boolean doInsert){
        List<Service_Item__c> serviceItemList = new List<Service_Item__c>();
        for (Proposal__c proposalItem : proposalList){
            for (Service_Item__c serviceItem : createServiceItemList(numberToCreate, proposalItem.Id, false)){
                serviceItem.Project_Profile__c = proposalItem.Project_Profile__c;
                serviceItemList.add(serviceItem);
            }
        }
        if(doInsert){
            insert serviceItemList;
        }
        return serviceItemList;
    }

    public static List<Service_Template__c> createServiceTemplateList(Integer numberToCreate, Boolean doInsert){
        MilroseSetting__c milroseSet = MilroseSetting__c.getInstance('Is_run_service_template');
        if (milroseSet == null){
            MilroseSetting__c setting = new MilroseSetting__c();
            setting.Name = 'Is_run_service_template';
            setting.Is_run_service_template__c = true;
            insert setting;
        }

        List<Service_Template__c> serviceTemplateList = new List<Service_Template__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            serviceTemplateList.add(new Service_Template__c(Service_Row_Number__c = 'TEST'));
        }
        if (doInsert){
            insert serviceTemplateList;
        }
        return serviceTemplateList;
    }

    public static List<Client_Price__c> createClientPriceList (Integer numberToCreate, Boolean doInsert){
        List<Client_Price__c> clientPriceList = new List<Client_Price__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            clientPriceList.add(new Client_Price__c());
        }
        if(doInsert){
            insert clientPriceList;
        }
        return clientPriceList;
    }

    public static List<Task_Item__c> createTaskItemList (Integer numberToCreate, Boolean doInsert){
        List<Task_Item__c> taskItemList = new List<Task_Item__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taskItemList.add(new Task_Item__c());
        }
        if (doInsert){
            insert taskItemList;
        }
        return taskItemList;
    }

    public static List<Task_Item__c> createTaskItemList (Integer numberToCreate, Id serviceItemId, Id projectProfileId, Boolean doInsert){
        List<Task_Item__c> taskItemList = createTaskItemList(numberToCreate, false);
        for (Task_Item__c taskItem : taskItemList){
            taskItem.Service_Item__c = serviceItemId;
            taskItem.Project_Profile__c = projectProfileId;
        }
        if (doInsert){
            try{
                insert taskItemList;
            } catch (DMLException ex){
                throw new ErrorException('DML Exception: ' + ex.getMessage() + [SELECT Id FROM Task_Item__c]);
            }
        }
        return taskItemList;
    }

    public static List<Task_Template__c> createTaskTemplateList (Integer numberToCreate, Boolean doInsert){
        List<Task_Template__c> taskTemplateListItem = new List<Task_Template__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taskTemplateListItem.add(new Task_Template__c());
        }
        if (doInsert){
            insert taskTemplateListItem;
        }
        return taskTemplateListItem;
    }

    public static List<Task_Template__c> createTaskTemplateList (Integer numberToCreate, String taskTemplateName, Boolean doInsert){
        List<Task_Template__c> taskTemplateListItem = new List<Task_Template__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taskTemplateListItem.add(new Task_Template__c(Name = String.isEmpty(taskTemplateName) ? 'Task Template' + i : taskTemplateName + i));
        }
        if (doInsert){
            insert taskTemplateListItem;
        }
        return taskTemplateListItem;
    }

    public static List<Task_Template__c> createTaskTemplateList (Integer numberToCreate, List<String> taskTemplateNameList, Boolean doInsert){
        List<Task_Template__c> taskTemplateListItem = new List<Task_Template__c>();
        for (Integer i = 0; i < taskTemplateNameList.size(); i++){
            taskTemplateListItem.addAll(createTaskTemplateList(numberToCreate, taskTemplateNameList[i], false));
        }
        if (doInsert){
            insert taskTemplateListItem;
        }
        return taskTemplateListItem;
    }

    public static List<Task_State_Change__c> createTaskStateChangeList (Integer numberToCreate, Boolean doInsert){
        List<Task_State_Change__c> taskStateChangeListItem = new List<Task_State_Change__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taskStateChangeListItem.add(new Task_State_Change__c());
        }
        if (doInsert){
            insert taskStateChangeListItem;
        }
        return taskStateChangeListItem;
    }

    public static List<Phase__c> createPhaseList (Integer numberToCreate, Boolean doInsert){
        List<Phase__c> phaseListItem = new List<Phase__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            phaseListItem.add(new Phase__c( Name__c = 'test' ));
        }
        if (doInsert){
            insert phaseListItem;
        }
        return phaseListItem;
    }

    public static List<Munucipalities__c> createMunicipalitiesList (Integer numberToCreate, String municipalitiesName, Id regionId, Boolean doInsert){
        List<Munucipalities__c> municipalitiesListItem = new List<Munucipalities__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            municipalitiesListItem.add ( new Munucipalities__c( Name = String.isEmpty(municipalitiesName) ? 'Test region' + i : municipalitiesName + i,
                                                                Region__c = regionId));
        }
        if (doInsert){
            try{
                insert municipalitiesListItem;
            } catch (DMLException ex){
                insert municipalitiesListItem;
            }
        }
        return municipalitiesListItem;
    }

    public static List<Additional_Reimbursable__c> createAdditionalReimbursableList(Integer numberToCreate, Id proposalId, Boolean doInsert){
        List<Additional_Reimbursable__c> additionalReimbursableList = new List<Additional_Reimbursable__c>();

        if (proposalId == null){
            proposalId = createProposalListForTest(1, true)[0].Id;
        }

        for (Integer i = 0; i < numberToCreate; i++){
            additionalReimbursableList.add(new Additional_Reimbursable__c(Proposal__c = proposalId));
        }

        if(doInsert){
            insert additionalReimbursableList;
        }

        return additionalReimbursableList;
    }

    /*public static List<Munucipalities__c> createMunicipalitiesList (Integer numberToCreate, String municipalitiesName, List<Id> regionIdList, Boolean doInsert){
        List<Munucipalities__c> municipalitiesListItem = new List<Munucipalities__c>();
        for (Integer i = 0; i < regionIdList.size(); i++){
            municipalitiesListItem.addAll (createMunicipalitiesList(numberToCreate,
                                                                    String.isEmpty(municipalitiesName) ? 'Test region' + i : municipalitiesName + i,
                                                                    regionIdList[i],
                                                                    false));
        }
        if (doInsert){
            insert municipalitiesListItem;
        }
        return municipalitiesListItem;
    }*/

    public static Region__c createRegion (String regionName, Boolean doInsert){
        Region__c regionItem = new Region__c(Name = String.isEmpty(regionName) ? 'Test region' : regionName);
        if (doInsert){
            try{
                insert regionItem;
            } catch (DMLException ex){
                insert regionItem;
            }
        }
        return regionItem;
    }

    public static List<Region__c> createRegionList (Integer numberToCreate, String regionName, Boolean doInsert){
        List<Region__c> regionListItem = new List<Region__c>();
        if (regionName != null && numberToCreate == 1){
            regionListItem.add(createRegion(regionName, false));
        } else {
                for (Integer i = 0; i < numberToCreate; i++){
                regionListItem.add(createRegion(String.isEmpty(regionName) ? 'Test region' + i : regionName + i, false));
            }
        }
        if (doInsert){
            try{
                insert regionListItem;
            } catch (DMLException ex){
                insert regionListItem;
            }
        }
        return regionListItem;
    }

    public static List<Building__c> createBuildingList (Integer numberToCreate, Id municipalityId, String streetName, String houseNumber,
                                                        String cityName, String zipCode, Boolean doInsert){
        List<Building__c> buildingListItem = new List<Building__c>();
        municipalityId = municipalityId == null ? createMunicipalitiesList(1, null, createRegionList(1, null, true)[0].Id, true)[0].Id : municipalityId;
        cityName = String.isEmpty(cityName) ? 'Some City' : cityName;
        zipCode = String.isEmpty(zipCode) ? '12345' : zipCode;
        for (Integer i = 0; i < numberToCreate; i++){
            buildingListItem.add ( new Building__c (Municipality__c = municipalityId, Street__c = String.isEmpty(streetName) ? 'Some srtreet' + i : streetName,
                                                    House_No__c = String.isEmpty(houseNumber) ? String.valueOf(i) : houseNumber + String.valueOf(i),
                                                    City__c = cityName, PostalCode__c = zipCode, Not_a_duplicate_building__c = true) );
        }
        if (doInsert){
            try{
                insert buildingListItem;
            } catch (DMLException ex){
                insert buildingListItem;
            }
        }
        return buildingListItem;
    }

    public static List<Floor__c> createFloorList (Integer numberToCreate, Boolean doInsert){
        List<Floor__c> floorListItem = new List<Floor__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            floorListItem.add(new Floor__c());
        }
        if(doInsert){
            insert floorListItem;
        }
        return floorListItem;
    }

    public static List<Project_Profile__c> createProjectProfileList(Integer numberToCreate, Id accountingContactCompanyId, Id accountingContactId, Id companyIdPrimary, Id contactIdPrimary,
                                                                    Id companyIdBilling, Id contactIdBilling, Id projectOwnerId, Boolean doInsert){
        List<Project_Profile__c> projectProfileList = new List<Project_Profile__c>();
        List<Account> tmpAccountList;
        List<Contact> tmpContactList;
        if (companyIdPrimary == null || companyIdBilling == null || accountingContactCompanyId == null){
            tmpAccountList = createAccountList(3, null, true);
            tmpContactList = createContactList (3, false);
            accountingContactCompanyId = tmpContactList[0].AccountId = tmpAccountList[0].Id;
            companyIdPrimary = tmpContactList[1].AccountId = tmpAccountList[1].Id;
            companyIdBilling = tmpContactList[2].AccountId = tmpAccountList[2].Id;
            insert tmpContactList;
            accountingContactId = tmpContactList[0].Id;
            contactIdPrimary = tmpContactList[1].Id;
            contactIdBilling = tmpContactList[2].Id;
        }
        if (contactIdPrimary == null || contactIdBilling == null){
            tmpContactList = createContactList (3, false);
            tmpContactList[0].AccountId = accountingContactCompanyId;
            tmpContactList[1].AccountId = companyIdPrimary;
            tmpContactList[2].AccountId = companyIdBilling;
            insert tmpContactList;
            accountingContactId = tmpContactList[0].Id;
            contactIdPrimary = tmpContactList[1].Id;
            contactIdBilling = tmpContactList[2].Id;
        }
        if (projectOwnerId == null){
            User projectManagerUser = userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
            projectOwnerId = projectManagerUser.Id;
        }

        if (ProjectProfileServices.idProposalToNewProjectProfiles == null){
            ProjectProfileServices.idProposalToNewProjectProfiles =  new Map<Id, Project_Profile__c>();
        }

        for (Integer i=0; i<numberToCreate; i++){
            projectProfileList.add(new Project_Profile__c(Accounting_Contact_Company__c = accountingContactCompanyId, Accounting_Contact__c = accountingContactId,
                                                          Primary_Company_Name__c = companyIdPrimary, Primary_Company_Contact__c = contactIdPrimary, OwnerId = projectOwnerId,
                                                          Billing_Company_Name__c = companyIdBilling, Billing_Company_Contact__c = contactIdBilling));
        }
        if (doInsert){
            upsert projectProfileList;
        }
        return projectProfileList;
    }
/*
    public static List<Proposal__c> createProposalWithProjectIdList( Integer numberToCreate, Id projectId, Id companyIdPrimary, Id contactIdPrimary, Id companyIdBilling,
                                                                     Id contactIdBilling, Id buildingId, Date expirationDate, Integer reminderExpiration,
                                                                     DateTime proposalSendReinder, DateTime proposalExpirationDate, Id partnerUserId, 
                                                                     Id salespersonId, Id projectManagerId, Boolean doInsert ) {
        List<Proposal__c> propList = createProposalList(numberToCreate, 'test', companyIdPrimary, contactIdPrimary, companyIdBilling,
                                                        contactIdBilling, buildingId, expirationDate, reminderExpiration,
                                                        proposalSendReinder, proposalExpirationDate, partnerUserId, 
                                                        salespersonId, projectManagerId, false );
       for( Proposal__c pr : propList){
           pr.Project_Profile__c = projectId;
           pr.Status__c = ProposalServices.PROPOSAL_STATUS_AWARDED;
       }
        if (doInsert){
            insert propList;
        }
        return propList;
     }
*/
    public static List<Proposal__c> createProposalList(Integer numberToCreate, String projectName, Id companyIdPrimary, Id contactIdPrimary, Id companyIdBilling,
                                                       Id contactIdBilling, Id buildingId, Date expirationDate, Integer reminderExpiration,
                                                       DateTime proposalSendReinder, DateTime proposalExpirationDate, Id partnerUserId, Id salespersonId, Id projectManagerId, Boolean doInsert){
        proposalSendReinder = proposalSendReinder == null ? DateTime.now().addDays(1) : proposalSendReinder;
        proposalExpirationDate = proposalExpirationDate == null ? DateTime.now().addDays(1) : proposalExpirationDate;
        List<Proposal__c> proposalList = new List<Proposal__c>();
        List<Account> tmpAccountList;
        List<Contact> tmpContactList;
        if (String.isEmpty(projectName)){
            projectName = 'Test project name';
        }
        if (buildingId == null){
            buildingId = createBuildingList (1, null, null, null, null, null, true)[0].Id;
        }
        if (expirationDate == null){
            expirationDate = Date.today();
        }
        if (companyIdPrimary == null || companyIdBilling == null){
            tmpAccountList = createAccountList(2, null, true);
            tmpContactList = createContactList (2, false);
            companyIdPrimary = tmpContactList[0].AccountId = tmpAccountList[0].Id;
            companyIdBilling = tmpContactList[1].AccountId = tmpAccountList[1].Id;
            insert tmpContactList;
            contactIdPrimary = tmpContactList[0].Id;
            contactIdBilling = tmpContactList[1].Id;
        }
        if (contactIdPrimary == null || contactIdBilling == null){
            tmpContactList = createContactList (2, false);
            tmpContactList[0].AccountId = companyIdPrimary;
            tmpContactList[1].AccountId = companyIdBilling;
            insert tmpContactList;
            contactIdPrimary = tmpContactList[0].Id;
            contactIdBilling = tmpContactList[1].Id;
        }
        if (partnerUserId == null){
            User partnerUser = userWithProfile(UserServices.PROFILE_PARTNER);
            partnerUserId = partnerUser.Id;
        }
        if (salespersonId == null){
            salespersonId = UserInfo.getUserId();
        }
        if (projectManagerId == null){
            User projectManagerUser = userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2);
            projectManagerId = projectManagerUser.Id;
        }

        for (Integer i =0 ; i < numberToCreate; i++){
            proposalList.add(new Proposal__c(Project_Name__c = projectName + i, Primary_Company_Name__c = companyIdPrimary, Partner__c = partnerUserId,
                                             Primary_Company_Contact__c = contactIdPrimary, Billing_Company_Name__c = companyIdBilling, Salesperson__c = salespersonId,
                                             Address__c = buildingId, Proposal_Sent_Date__c = Date.today(), Billing_Company_Contact__c = contactIdBilling,
                                             Proposal_Send_Reminder__c = proposalSendReinder, Proposal_Expiration_Date__c = proposalExpirationDate,
                                             Proposal_RFP_Request_Date__c = datetime.now(), Floor_s__c = '1', Partner_Approval_Required__c = false, 
                                             Description__c = 'Description', Expiration_Date__c = expirationDate, Fulfillment_Office__c = 'New York, NY'));
        }
        if (doInsert){
            insert ProposalList;
        }
        return proposalList;
    }

    public static List<Proposal__c> createProposalWithStatusDraftList(Integer numberToCreate, Boolean doInsert){
        List<Proposal__c> proposalList = new List<Proposal__c>();
        for (Integer i =0 ; i < numberToCreate; i++){
            proposalList.add(new Proposal__c(Status__c = ProposalServices.PROPOSAL_STATUS_NEW, Is_Draft__c = true));//set ProposalStatus 'Draft'
        }
        if (doInsert){
            insert ProposalList;
        }
        return proposalList;
    }

    public static List<Proposal__c> createProposalDraftList (Integer numberToCreate, Boolean doInsert){
        List<Proposal__c> proposalDraftListItem = new List<Proposal__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            proposalDraftListItem.add(new Proposal__c());
        }
        if(doInsert){
            insert proposalDraftListItem;
        }
        return proposalDraftListItem;
    }

    /*public static List<Proposal_Historical__c> createProposalHistoricalList( Integer numberToCreate, Boolean doInsert ){
        List<Proposal_Historical__c> proposalHistoricalList = new List<Proposal_Historical__c>();

        for( Integer i = 0 ; i < numberToCreate; i++ ){
            proposalHistoricalList.add(new Proposal_Historical__c(Name = 'Test Historical Proposal ' + i, Project_Name__c = 'test Project ' + i ));
        }
        if (doInsert){
            insert proposalHistoricalList;
        }
        return proposalHistoricalList;
    }

    public static List<Service_Historical__c> createServiceItemHistoricalList( Integer numberToCreate, Id proposalHistoricalId, Boolean doInsert ){
        List<Service_Historical__c> serviceItemHistoricalList = new List<Service_Historical__c>();
        for( Integer i = 0 ; i < numberToCreate; i++ ){
            serviceItemHistoricalList.add( new Service_Historical__c(Name = 'Test Historical Service ' + i, Proposal_Historical__c = proposalHistoricalId ));
        }
        if (doInsert){
            insert serviceItemHistoricalList;
        }
        return serviceItemHistoricalList;
    }*/
/*
    public static List<Change_History_Proposal__c> createChangeHistoryProposalList( Integer numberToCreate, Boolean doInsert ){
        List<Change_History_Proposal__c> proposalChangeHistoryProposalList = new List<Change_History_Proposal__c>();

        for( Integer i = 0 ; i < numberToCreate; i++ ){
            proposalChangeHistoryProposalList.add(new Change_History_Proposal__c());
        }
        if (doInsert){
            insert proposalChangeHistoryProposalList;
        }
        return proposalChangeHistoryProposalList;
    }
*/
    public static List<Billing_Line_Item__c> createBillingLineItemList(Integer numberToCreate, Id projectProfileId, Id billingCompanyId, Id billingContactId, Boolean doInsert){
        if (projectProfileId == null){
            Project_Profile__c projectProfileItem = createProjectProfileList(1, null, null, null, null, null, null, null, true)[0];
            projectProfileId = projectProfileItem.Id;
            billingCompanyId = projectProfileItem.Billing_Company_Name__c;
            billingContactId = projectProfileItem.Billing_Company_Contact__c;
        }
        if (billingCompanyId == null){
            billingCompanyId = createAccountList(1, null, true)[0].Id;
            billingContactId = createContactList(1, billingCompanyId, true)[0].Id;
        }
        if (billingContactId == null){
            billingContactId = createContactList(1, billingCompanyId, true)[0].Id;
        }
        List<Billing_Line_Item__c> billingLineItemList = new List<Billing_Line_Item__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            billingLineItemList.add( new Billing_Line_Item__c ( Project_Profile__c = projectProfileId, Billing_Contact__c = billingContactId,
                                                                Billing_Client__c = billingCompanyId, Amount__c = 100, Sales_Tax_Amount_1__c = 10));
        }
        if (doInsert){
            insert billingLineItemList;
        }
        return billingLineItemList;
    }

    public static List<Pro_forma_Invoice__c> createProFormaInvoiceList(Integer numberToCreate, Id billingClientCompany, Id billingContactId, Id buildingId, Boolean doInsert){
        if (billingClientCompany == null){
            billingClientCompany = createAccountList(1, null, true)[0].Id;
        }
        if (billingContactId == null){
            billingContactId = createContactList(1, billingClientCompany, true)[0].Id;
        }
        if (buildingId == null){
            buildingId = createBuildingList(1, null, null, null, null, null, true)[0].Id;
        }
        List<Pro_forma_Invoice__c> proformaInvoiceList = new List<Pro_forma_Invoice__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            proformaInvoiceList.add ( new Pro_forma_Invoice__c (Billing_Client_Company__c = billingClientCompany,
                                                                Billing_Contact__c = billingContactId,
                                                                Project_Address__c = buildingId ) );
        }
        if (doInsert){
            insert proformaInvoiceList;
        }
        return proformaInvoiceList;
    }

    public static List<Billing_Date__c> createBillingDateList(Integer numberToCreate, Date processingDay, Id projectProfileId, Boolean doInsert){
        projectProfileId = projectProfileId == null ? createProjectProfileList(1, null, null, null, null, null, null, null, true)[0].Id : projectProfileId;
        processingDay = processingDay == null ? Date.today() : processingDay;
        List<Billing_Date__c> billingDateList = new List<Billing_Date__c>();
        for (Integer i = 1; i <= numberToCreate; i++){
            billingDateList.add(new Billing_Date__c(Processing_Day__c = processingDay, Project_Profile__c = projectProfileId, Step_Number__c = i));
        }
        if (doInsert){
            insert billingDateList;
        }
        return billingDateList;
    }

    public static List<Project_Roster__c> createProjectRosterList (Integer numberToCreate, Boolean doInsert){
        List<Project_Roster__c> projectRosterListItem = new List<Project_Roster__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            projectRosterListItem.add(new Project_Roster__c());
        }
        if(doInsert){
            insert projectRosterListItem;
        }
        return projectRosterListItem;
    }

    public static List<Roster_Email_Junction__c> createRosterEmailJunctionList (Integer numberToCreate, Proposal__c proposalItem, Boolean doInsert){
        List<Roster_Email_Junction__c> createdRosterEmailJunctionList = new List<Roster_Email_Junction__c>();

        if ( proposalItem == null || proposalItem.Id == null){
            proposalItem = createProposalListForTest(1, true)[0];
        }

        for (Integer i = 0; i < numberToCreate; i++){
            createdRosterEmailJunctionList.add(new Roster_Email_Junction__c(Proposal__c = proposalItem.Id));
        }
        if(doInsert){
            insert createdRosterEmailJunctionList;
        }
        return createdRosterEmailJunctionList;
    }

    public static User getFFUser (){
        List<User> ffUserList;

        Set<id> userIdSet = new Set<Id>();
        for (GroupMember groupMemberItem : [Select Id, UserOrGroupId From GroupMember Where Group.Name = : FF_GROUP_NAME_VALUE]){
            userIdSet.add(groupMemberItem.UserOrGroupId);
        }

        ffUserList = [SELECT Id FROM User WHERE Id IN : userIdSet And isActive = true And Profile.Name = : UserServices.PROFILE_PLATFORM_SYSTEM_ADMIN LIMIT 1];

        if (ffUserList.isEmpty()){
//            throw new TestException('there are no FF user');
        }

        return ffUserList[0];
    }

    public static List<c2g__codaGeneralLedgerAccount__c> createGeneralLedgerAccountList(Integer numberToCreate, String reportingCode,
                                                                                        String typeName, Boolean doInsert){
        reportingCode = String.isEmpty(reportingCode) ? 'test' : reportingCode;
        typeName = String.isEmpty(TypeName) ? 'test type name' : typeName;
        List<c2g__codaGeneralLedgerAccount__c> generalLedgerAccountList = new List<c2g__codaGeneralLedgerAccount__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            generalLedgerAccountList.add (new c2g__codaGeneralLedgerAccount__c (c2g__ReportingCode__c = reportingCode + String.valueOf(i),
                                                                                c2g__Type__c = typeName));
        }
        if (doInsert){
            insert generalLedgerAccountList;
        }
        return generalLedgerAccountList;
    }

    public static List<c2g__codaTaxCode__c> createTaxCodeList (Integer numberToCreate, Id ledgerAccountId, Boolean doInsert){
        ledgerAccountId = ledgerAccountId == null ? createGeneralLedgerAccountList(1, null, null, true)[0].Id : ledgerAccountId;
        List<c2g__codaTaxCode__c> codaTaxCodeList = new List<c2g__codaTaxCode__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            codaTaxCodeList.add (new c2g__codaTaxCode__c (c2g__GeneralLedgerAccount__c = ledgerAccountId));
        }
        if (doInsert){
            insert codaTaxCodeList;
        }
        return codaTaxCodeList;
    }

    public static List<c2g__codaTaxRate__c> createTaxRateList (Integer numberToCreate, Id taxCodeId, Decimal rateValue, Date startDate, Boolean doInsert){
        taxCodeId = taxCodeId == null ? createTaxCodeList(1, null, true)[0].Id : taxCodeId;
        rateValue = rateValue == null ? 0.0 : rateValue;
        startDate = startDate == null ? Date.today() : startDate;
        List<c2g__codaTaxRate__c> taxRateList = new List<c2g__codaTaxRate__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taxRateList.add (new c2g__codaTaxRate__c (c2g__TaxCode__c = taxCodeId, c2g__StartDate__c = startDate, c2g__Rate__c = rateValue));
        }
        if (doInsert){
            insert taxRateList;
        }
        return taxRateList;
    }

    public static List<c2g__codaDimension1__c> createDimension_1_List(Set<String> reportingCodeNameSet, Boolean doInsert){
        List<c2g__codaDimension1__c> codaDimension_1_List = new List<c2g__codaDimension1__c>();
        for (String stringItem : reportingCodeNameSet){
            codaDimension_1_List.add(new c2g__codaDimension1__c(c2g__ReportingCode__c = stringItem));
        }
        if (doInsert){
            try {
                insert codaDimension_1_List;
            } catch (Exception ex){
                insert codaDimension_1_List;
            }
        }
        return codaDimension_1_List;
    }

    public static List<c2g__codaDimension1__c> createDimension_1_List(Integer numberToCreate, Boolean doInsert){
        Set<String> reportingCodeNameSet = new Set<String>();
        for (Integer i = 0; i < numberToCreate; i++){
            reportingCodeNameSet.add('code' + String.valueOf(i));
        }
        return createDimension_1_List(reportingCodeNameSet, doInsert);
    }

    public static List<c2g__codaDimension2__c> createDimension2List(Integer numberToCreate, String reportingCode, Boolean doInsert){
        List<c2g__codaDimension2__c> codaDimension2List = new List<c2g__codaDimension2__c>();
        reportingCode = String.isEmpty(reportingCode) ? 'Test' : reportingCode;
        for (Integer i = 0; i < numberToCreate; i++){
            codaDimension2List.add(new c2g__codaDimension2__c(c2g__ReportingCode__c = reportingCode));
        }

        if (doInsert){
            try {
                insert codaDimension2List;
            } catch (Exception ex){
                insert codaDimension2List;
            }
        }

        return codaDimension2List;
    }

    /*public static List<Proposal__c> createProposalList( Integer numberToCreate,
                                                        Id userId,
                                                        String userName,
                                                        Boolean doInsert ){

        List<Proposal__c> proposalList = new List<Proposal__c>();
            for(integer i=0; i < numberToCreate; i++ ){
                proposalList.add(new Proposal__c(Partner__c = userId , Salesperson__c = userId));
            }
        if(doInsert){
            insert proposalList;
        }
     return proposalList;
    }*/

    //commented by pvl:
    
     public static List<Proposal__c> createProposalDraftList( Integer numberToCreate,
                                                                    Id userId,
                                                                    Boolean doInsert ){

        List<Proposal__c> proposalDraftList = new List<Proposal__c>();
            for(integer i=0; i < numberToCreate; i++ ){
                proposalDraftList.add(new Proposal__c(Partner__c = userId ));
            }
        if(doInsert){
            insert proposalDraftList;
        }
     return proposalDraftList;
    }

/*
    public static List<Proposal__c> createProposalList( Integer numberToCreate,
                                                                    Id userId,
                                                                    Boolean doInsert ){

        List<Proposal__c> proposalList = new List<Proposal__c>();
            for(integer i=0; i < numberToCreate; i++ ){
                proposalList.add(new Proposal__c(Partner__c = userId ));
            }
        if(doInsert){
            insert proposalList;
        }
     return proposalList;
    }
*/


     public static List<User> createUsers( Integer numberToCreate, Boolean doInsert ){
  return createUsers(numberToCreate, null, null, null, null, null, null, null, null, null, null, doInsert);
 }

    public static List<User> createUsers( Integer numberToCreate,
                                          String username,
                                          String lastName,
                                          String email,
                                          String alias,
                                          String communityNickname,
                                          String timeZoneSidKey,
                                          String localeSidKey,
                                          String emailEncodingKey,
                                          Id profileId,
                                          String languageLocaleKey,
                                          Boolean doInsert ){
        if( profileId == null || profileId == '' ) profileId = getProfileId( FF_USER_STANDART_USER_STRING );
        List<User> newUserList = new List<User>();
        for( Integer i = 0 ; numberToCreate > i ; i++ ) {
            newUserList.add( new User( Username = username != null && username != '' ? username : 'testUserForTest' + i + '@email.com',
                                       LastName = lastName != null && lastName != '' ? lastName : 'Test User' + i,
                                       Email = email != null && email != '' ? email : 'testUser789' + i + '@bluewolfgroup.com',
                                       Alias = alias != null && alias != '' ? alias : 'tUser' + i,
                                       CommunityNickname = communityNickname != null && communityNickname != '' ? communityNickname : 'tUser' + i,
                                       TimeZoneSidKey = timeZoneSidKey != null && timeZoneSidKey != '' ? timeZoneSidKey : 'GMT',
                                       LocaleSidKey = localeSidKey != null && localeSidKey != '' ? localeSidKey : 'en_US',
                                       EmailEncodingKey = emailEncodingKey != null && emailEncodingKey != '' ? emailEncodingKey : 'ISO-8859-1',
                                       ProfileId = profileId,
                                       LanguageLocaleKey = languageLocaleKey != null && languageLocaleKey != '' ? languageLocaleKey : 'en_US' ) );
        }

        if( doInsert && !newUserList.isEmpty()  )
            insert newUserList;

        return newUserList;
    }
    public static Id getProfileId( String profileName ) {
        return [SELECT Id, Name FROM Profile WHERE Name = : profileName].Id;
    }

     public static List<Event> createEventList( Integer numberToCreate, boolean doInsert ){
        List<Event> eventList = new List<Event>();
        for( Integer i = 0; i< numberToCreate; i++ ){
            eventList.add(new Event(DurationInMinutes = i,ActivityDateTime = Date.today(), IsReminderSet = true));
        }
        if(doInsert){
            insert eventList;
        }
        return eventList;
     }
     public static List<Task> createTaskList ( Integer numberToCreate, boolean doInsert ){
        List<Task> taskList = new List<Task>();
        for( Integer i = 0; i < numberToCreate; i++){
            taskList.add(new Task());
        }
        if(doInsert){
            insert taskList;
        }
        return taskList;
     }

     public static Boolean pageMessagesContain(String messageNeedle)
    {
        for(ApexPages.Message message : ApexPages.getMessages())
        {
            if(message.getSummary() == messageNeedle)
                return true;
        }
        return false;
    }


    /*public static Boolean pageMessagesContain(String messageNeedle, Boolean equal){
        if (equal){
            return pageMessagesContain(messageNeedle);
        }
        for(ApexPages.Message message : ApexPages.getMessages())
        {
            if( message.getSummary().contains(messageNeedle) )
                return true;
        }
        return false;
    }
        public static User userWithProfile (String userProfileName, Set<Id> userIdSet){
        User userItem;
        Id userProfileId = mapProfileNameId.get(userProfileName);

        List<User> userItemList = [SELECT Id, ProfileId
                                   FROM User
                                   WHERE Id != : UserInfo.getUserId()
                                   AND isActive = true
                                   AND Id NOT IN : userIdSet
                                   AND ProfileId IN : userProfilesByUserLicenseName(userLicenseByProfileName(userProfileName))];

        if (!userItemList.isEmpty()){
            for (User u : userItemList){
                if (u.ProfileId == userProfileId){
                    userItem = u;
                    break;
                }
            }
            if (userItem == null){
                userItem = userItemList[0];
                userItem.ProfileId = userProfileId;
                System.runAs([SELECT Id FROM User WHERE Id = : UserInfo.getUserId()][0]){
                    update userItem;
                }
            }
        }
        if (userItem == null){
            userItem = new User (ProfileId = userProfileId, Email = 'sometestemail@milrose.com', Username = 'SomeTestUserName',
                                 LastName = 'SomeTestUserLastName', CommunityNickname = 'SomeTestUserCominityName', TimeZoneSidKey = 'America/New_York',
                                 LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
            System.runAs([SELECT Id FROM User WHERE Id = : UserInfo.getUserId()][0]){
                insert userItem;
            }
        }
        return userItem;
    }*/

    private static Map<String, Map<String, Id>> recordTypeSobjecttypeWithNameId{
        get{
            if (recordTypeSobjecttypeWithNameId == null){
                recordTypeSobjecttypeWithNameId = new Map<String, Map<String, Id>>();
                for (RecordType recordTypeItem : [SELECT Id, Name, sObjectType FROM RecordType]){
                    if (!recordTypeSobjecttypeWithNameId.containsKey(recordTypeItem.sObjectType)){
                        recordTypeSobjecttypeWithNameId.put(recordTypeItem.sObjectType, new Map<String, Id>());
                    }
                    recordTypeSobjecttypeWithNameId.get(recordTypeItem.sObjectType).put(recordTypeItem.Name, recordTypeItem.Id);
                }
            }
            return recordTypeSobjecttypeWithNameId;
        }
        set{}
    }

    public static Map<String, Id> getRecordTypeNameIdByObjecttypename(String sobjectName){
        return recordTypeSobjecttypeWithNameId.get(sobjectName);
    }

    public static Id getRecordTypeIdByObjecttypenameRecordTypeName(String sobjectName, String recordTypeName){
        return (recordTypeSobjecttypeWithNameId.containsKey(sobjectName)) ? recordTypeSobjecttypeWithNameId.get(sobjectName).get(recordTypeName) : null;
    }

    public static List<Project_Team__c> createProjectTeamList(Integer numberToCreate, Id productionManagerId, Id projectManagerId, Boolean doInsert){
        List<Project_Team__c> projectTeamList = new List<Project_Team__c>();

        testProductionManagerUser = testProductionManagerUser == null ? userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER) : testProductionManagerUser;
        productionManagerId = testProductionManagerUser.Id;//productionManagerId == null ? userWithProfile(UserServices.PROFILE_PRODUCTION_MANAGER).Id : productionManagerId;
        projectManagerId = projectManagerId == null ? userWithProfile(UserServices.PROFILE_PROJECT_MANAGER_2).Id : projectManagerId;

        for(Integer i = 0; i < numberToCreate; i++ ){
            projectTeamList.add(new Project_Team__c(Production_Manager__c = productionManagerId, Project_Manager__c = projectManagerId));
        }
        if(doInsert){
            try{
                insert projectTeamList;
            } catch (DMLException ex){
                insert projectTeamList;
            }
        }
        return projectTeamList;
    }

    public static List<RFI_Scope__c> createRFIScopeList(Integer numberToCreate, Boolean doInsert){
        List<RFI_Scope__c> createdRFIScopeList = new List<RFI_Scope__c>();
        for(Integer i = 0; i < numberToCreate; i++){
            createdRFIScopeList.add(new RFI_Scope__c());
        }
        if(doInsert){
            insert createdRFIScopeList;
        }
        return createdRFIScopeList;
    }

    public static List<RFI_Scope__c> createRFI_ScopeList(Integer numberToCreate, Id regionId, Boolean doInsert){
        List<RFI_Scope__c> createdRFIScopeList = createRFIScopeList(numberToCreate, false);
        for(RFI_Scope__c itemRFIScope : createdRFIScopeList){
            itemRFIScope.RecordTypeId = getRecordTypeNameIdByObjecttypename(RFIScopeServices.RFI_SCOPE_OBJECT_NAME).get(RFIScopeServices.RECORD_TYPE_NAME_STANDARD);
            itemRFIScope.Region__c = regionId;
        }
        if(doInsert){
            insert createdRFIScopeList;
        }
        return createdRFIScopeList;
    }

    public static List<RFI_Scope_Description_New_York__c> createRFIScopeDescriptionNewYorkList(Integer numberToCreate, Boolean doInsert){
        List<RFI_Scope_Description_New_York__c> createdRFIScopeDescriptionNewYorkList = new List<RFI_Scope_Description_New_York__c>();
        for(Integer i = 0; i < numberToCreate; i++){
            createdRFIScopeDescriptionNewYorkList.add(new RFI_Scope_Description_New_York__c());
        }
        if(doInsert){
            insert createdRFIScopeDescriptionNewYorkList;
        }
        return createdRFIScopeDescriptionNewYorkList;
    }

    public static List<RFI_Work__c> createRFIWorkList(Integer numberToCreate, Boolean doInsert){
        List<RFI_Work__c> createdRFIWorkList = new List<RFI_Work__c>();
        for(Integer i = 0; i < numberToCreate; i++){
            createdRFIWorkList.add(new RFI_Work__c());
        }
        if(doInsert){
            insert createdRFIWorkList;
        }
        return createdRFIWorkList;
    }

    public static List<Monitor_RFI_Scope__c> createMonitorRFIWorkList(Integer numberToCreate, Id rfiScopeId, Boolean doInsert){
        rfiScopeId = rfiScopeId == null ? createRFIScopeList(1, true)[0].Id : rfiScopeId;
        List<Monitor_RFI_Scope__c> createdMonitorRFIWorkList = new List<Monitor_RFI_Scope__c>();
        for(Integer i = 0; i < numberToCreate; i++){
            createdMonitorRFIWorkList.add(new Monitor_RFI_Scope__c(RFI_Scope__c = rfiScopeId));
        }
        if(doInsert){
            insert createdMonitorRFIWorkList;
        }
        return createdMonitorRFIWorkList;
    }

    public static List<Mailroom__c> createMailRoomList(Integer numberToCreate,Boolean doInsert){
        List<Mailroom__c> mailRoomList = new List<Mailroom__c>();
        for(Integer i = 0 ; i< numberToCreate; i++){
            mailRoomList.add(new Mailroom__c());
        }
        if(doInsert){
            insert mailRoomList;
        }
        return mailRoomList;

    }

    public static List<c2g__codaInvoice__c> createSalesInvoiceList(Integer numberToCreate, Id accountId, Date invoiceDate, Date dueDate, Boolean doInsert){
        List<c2g__codaInvoice__c> salesInvoiceList = new List<c2g__codaInvoice__c>();

        accountId = accountId == null ? createAccountList(1, null, true)[0].Id : accountId;
        invoiceDate = invoiceDate == null ? Date.today() : invoiceDate;
        dueDate = dueDate == null ? Date.today() : dueDate;

        for(Integer i = 0 ; i< numberToCreate; i++){
            salesInvoiceList.add( new c2g__codaInvoice__c ( c2g__Account__c = accountId, c2g__InvoiceDate__c = invoiceDate, c2g__DueDate__c = dueDate ) );
        }

        if(doInsert){
            insert salesInvoiceList;
        }

        return salesInvoiceList;
    }
/*
    public static List<c2g__codaTransaction__c> createTransAction(Integer numberToCreate,Boolean doInsert){
        List<c2g__codaTransaction__c> transActionList = new List<c2g__codaTransaction__c>();
        for(Integer i = 0 ; i< numberToCreate; i++){
            transActionList.add(new c2g__codaTransaction__c());
        }
        if(doInsert){
            insert transActionList;
        }
        return transActionList;
    }

    public static List<c2g__codaTransactionLineItem__c> createTransActionLineItemList(Integer numberToCreate, Id companyId, Boolean doInsert){
        List<c2g__codaTransactionLineItem__c> transActionList = new List<c2g__codaTransactionLineItem__c>();
        for(Integer i = 0 ; i< numberToCreate; i++){
            transActionList.add(new c2g__codaTransactionLineItem__c(c2g__OwnerCompany__c = companyId));
        }
        if(doInsert){
            insert transActionList;
        }
        return transActionList;
    }

    public static List<c2g__codaCashEntry__c> createCashEntryList(Integer numberToCreate, Id accountId, Boolean doInsert){
        List<c2g__codaCashEntry__c> cashEntryList = new List<c2g__codaCashEntry__c>();

        accountId = accountId == null ? createAccountList(1, null, true)[0].Id : accountId;

        for(Integer i = 0 ; i<  numberToCreate; i++){
            cashEntryList.add( new c2g__codaCashEntry__c ( c2g__Account__c = accountId, c2g__Status__c = 'In Progress', c2g__Date__c = Date.today() ) );
        }

        if(doInsert){
            insert cashEntryList;
        }

        return cashEntryList;
    }

    public static List<c2g__codaCashEntryLineItem__c> createCashEntryLineItemList(Integer numberToCreate, Id accountId, Id cashEntryId, Decimal cashEntryValue, Boolean doInsert){
        List<c2g__codaCashEntryLineItem__c> cashEntryLineItemList = new List<c2g__codaCashEntryLineItem__c>();

        accountId = accountId == null ? createAccountList(1, null, true)[0].Id : accountId;
        cashEntryId = cashEntryId == null ? createCashEntryList(1, accountId, true)[0].Id : cashEntryId;
        cashEntryValue = cashEntryValue == null ? 1 : cashEntryValue;

        for(Integer i = 0 ; i<  numberToCreate; i++){
            cashEntryLineItemList.add ( new c2g__codaCashEntryLineItem__c ( c2g__Account__c = accountId, c2g__CashEntryValue__c = cashEntryValue, c2g__CashEntry__c = cashEntryId ) );
        }

        if(doInsert){
            insert cashEntryLineItemList;
        }

        return cashEntryLineItemList;
    }

    public static List<c2g__codaCompany__c> createCompanyList(Integer numberToCreate, Boolean doInsert){
        List<c2g__codaCompany__c> companyList = new List<c2g__codaCompany__c>();
        for(Integer i = 0 ; i<  numberToCreate; i++){
            companyList.add(new c2g__codaCompany__c());
        }
        if(doInsert){
            insert companyList;
        }
        return companyList;
    }

    public static List<Note> createNoteList(Integer numberToCreate,Boolean doInsert){
        List<Note> noteList = new List<Note>();
        for(Integer i = 0 ; i<  numberToCreate; i++){
            noteList.add(new Note());
        }
        if(doInsert){
            insert noteList;
        }
        return noteList;
    }
*/
    public static List<Note> createNoteList(Integer numberToCreate, Id parentId, String titleValue, Boolean doInsert){
        parentId = parentId == null ? createAccountList(1, null, true)[0].Id : parentId;
        titleValue = String.isEmpty(titleValue) ? 'test title' : titleValue;
        List<Note> noteList = new List<Note>();
        for(Integer i = 0; i <  numberToCreate; i++){
            noteList.add(new Note(ParentId = parentId, Title = titleValue + String.valueOf(i)));
        }
        if(doInsert){
            insert noteList;
        }
        return noteList;
    }

    public static List<LStore__Stored_Document__c> createLStoreStoredDocumentList (Integer numberToCreate, String relatedObjectId, Boolean doInsert){
        List<LStore__Stored_Document__c> lStoreStoredDocumentListItem = new List<LStore__Stored_Document__c>();
        relatedObjectId = String.isEmpty(relatedObjectId) ? String.valueOf(UserInfo.getUserId()) : relatedObjectId;
        for (Integer i = 0; i < numberToCreate; i++){
            lStoreStoredDocumentListItem.add(new LStore__Stored_Document__c(LStore__File_Name__c = 'test_file_name.txt', LStore__Related_Object_Id__c = relatedObjectId));
        }
        if(doInsert){
            insert lStoreStoredDocumentListItem;
        }
        return lStoreStoredDocumentListItem;
    }
    public static List<LStore__Stored_Document__c> createLStoreStoredDocumentList (Integer numberToCreate, Boolean doInsert){
        return createLStoreStoredDocumentList(numberToCreate, null, doInsert);
    }

    public static List<Service_Bundle__c> createServiceBundleList (Integer numberToCreate, String serviceBundleName, Boolean doInsert){
        List<Service_Bundle__c> createServiceBundleListItem = new List<Service_Bundle__c>();
        serviceBundleName = serviceBundleName == null ? 'testservice bundle' : serviceBundleName;
        for (Integer i = 0; i < numberToCreate; i++){
            createServiceBundleListItem.add(new Service_Bundle__c(Bundle_Name__c = serviceBundleName + String.valueOf(i)));
        }
        if(doInsert){
            insert createServiceBundleListItem;
        }
        return createServiceBundleListItem;
    }

    public static List<Service_Bundle_Item__c> createServiceBundleItemList (Id serviceTemplateId, Id serviceBundleId, Boolean doInsert){
        List<Service_Bundle_Item__c> createServiceBundleItemListItem = new List<Service_Bundle_Item__c>();
        if(serviceTemplateId == null){
            serviceTemplateId = createServiceTemplateList(1, true)[0].Id;
        }
        if(serviceBundleId == null){
            serviceBundleId = createServiceBundleList(1, null, true)[0].Id;
        }
        createServiceBundleItemListItem.add(new Service_Bundle_Item__c(Service__c = serviceTemplateId, Service_Bundle__c = serviceBundleId));
        if(doInsert){
            insert createServiceBundleItemListItem;
        }
        return createServiceBundleItemListItem;
    }

    public static List<ProjectRosterObject__c> createProjectRosterObjectList(Integer numberToCreate,Boolean doInsert){
        List<ProjectRosterObject__c> projectRosterObjectList = new List<ProjectRosterObject__c>();
        for(Integer i = 0 ; i< numberToCreate; i++){
            projectRosterObjectList.add(new ProjectRosterObject__c());
        }
        if(doInsert){
            insert projectRosterObjectList;
        }
        return projectRosterObjectList;
    }

    public static List<Loop__DDP__c> createLoopDDPList (Integer numberToCreate, Boolean doInsert){
        List<Loop__DDP__c> createcreateLoopDDPListItem = new List<Loop__DDP__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            createcreateLoopDDPListItem.add(new Loop__DDP__c());
        }
        if(doInsert){
            insert createcreateLoopDDPListItem;
        }
        return createcreateLoopDDPListItem;
    }

    public static List<Loop__DDP_Integration_Option__c> createLoopDDPIntegrationOptionList (Integer numberToCreate, Id loopDDPId, Boolean doInsert){
        List<Loop__DDP_Integration_Option__c> createcreateLoopDDPIntegrationOptionListItem = new List<Loop__DDP_Integration_Option__c>();
        if (loopDDPId == null){
            loopDDPId = createLoopDDPList(1, true)[0].Id;
        }
        for (Integer i = 0; i < numberToCreate; i++){
            createcreateLoopDDPIntegrationOptionListItem.add(new Loop__DDP_Integration_Option__c(Loop__DDP__c = loopDDPId));
        }
        if(doInsert){
            insert createcreateLoopDDPIntegrationOptionListItem;
        }
        return createcreateLoopDDPIntegrationOptionListItem;
    }
/*
    public static List<Loop__DDP_File__c> createLoopDDPFileList (Integer numberToCreate, Id loopDDPId, Boolean doInsert){
        List<Loop__DDP_File__c> createcreateLoopDDPFileListItem = new List<Loop__DDP_File__c>();
        if (loopDDPId == null){
            loopDDPId = createLoopDDPList(1, true)[0].Id;
        }
        for (Integer i = 0; i < numberToCreate; i++){
            createcreateLoopDDPFileListItem.add(new Loop__DDP_File__c(Loop__DDP__c = loopDDPId));
        }
        if(doInsert){
            insert createcreateLoopDDPFileListItem;
        }
        return createcreateLoopDDPFileListItem;
    }
*/
    public static List<Opportunity> createOpportunityList (Integer numberToCreate,String name, String stageName,Date closeDate, Boolean doInsert){
        List<Opportunity> OpportunityList = new List<Opportunity>();
        for (Integer i = 0; i < numberToCreate; i++){
            OpportunityList.add(new Opportunity(Name = name == null || name == '' ? 'TestName' + i : name,
                                                StageName = stageName == null || stageName == '' ? 'TestStageName' + i : stageName,
                                                CloseDate = closeDate == null  ? Date.today().addDays(30): closeDate));
        }
        if(doInsert){
            insert OpportunityList;
        }
        return OpportunityList;
    }

    public static List<Change_Order__c> createChangeOrderList (Integer numberToCreate, Boolean doInsert){
        List<Change_Order__c> changeOrderListItem = new List<Change_Order__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            changeOrderListItem.add(new Change_Order__c());
        }
        if(doInsert){
            insert changeOrderListItem;
        }
        return changeOrderListItem;
    }

    public static List<Form_Item__c> createFormItemList (Integer numberToCreate, Boolean doInsert){
        List<Form_Item__c> formItemListItem = new List<Form_Item__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            formItemListItem.add(new Form_Item__c());
        }
        if(doInsert){
            insert formItemListItem;
        }
        return formItemListItem;
    }

    public static List<Form_Assignment__c> createFormAssignmentList (Integer numberToCreate, List<Form_Item__c> formItemList, Boolean doInsert){
        List<Form_Assignment__c> formAssignmentListItem = new List<Form_Assignment__c>();
        if (formItemList == null){
            return formAssignmentListItem;
        }
        for ( Form_Item__c formItemItem : formItemList ) {
            for (Integer i = 0; i < numberToCreate; i++){
                formAssignmentListItem.add(new Form_Assignment__c(Form_Item__c = formItemItem.Id));
            }
        }
        if(doInsert){
            insert formAssignmentListItem;
        }
        return formAssignmentListItem;
    }

    public static List<Form_Template__c> createFormTemplateList (Integer numberToCreate, String formTemplateIdName, Boolean doInsert){
        formTemplateIdName = String.isEmpty(formTemplateIdName) ? 'F' : formTemplateIdName;
        List<Form_Template__c> formTemplateListItem = new List<Form_Template__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            formTemplateListItem.add(new Form_Template__c(Form_ID__c = formTemplateIdName + String.valueOf(i)));
        }
        if(doInsert){
            insert formTemplateListItem;
        }
        return formTemplateListItem;
    }

    public static List<Form_Signature__c> createFormSignatureList (Integer numberToCreate, Id formItemId, Boolean doInsert){
        formItemId = formItemId == null ? createFormItemList(1, true)[0].Id : formItemId;
        List<Form_Signature__c> formSignatureListItem = new List<Form_Signature__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            formSignatureListItem.add(new Form_Signature__c(Form_Item__c = formItemId));
        }
        if(doInsert){
            insert formSignatureListItem;
        }
        return formSignatureListItem;
    }

    public static List<Application_Filing_Checklist__c> createApplicationFillingChecklistList (Integer numberToCreate, Boolean doInsert){
        List<Application_Filing_Checklist__c> applicationFillingChecklistListItem = new List<Application_Filing_Checklist__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            applicationFillingChecklistListItem.add(new Application_Filing_Checklist__c());
        }
        if(doInsert){
            insert applicationFillingChecklistListItem;
        }
        return applicationFillingChecklistListItem;
    }

    public static List<Work_Permit_Filing_Checklist__c> createWorkPermitFillingChecklistList (Integer numberToCreate, Boolean doInsert){
        List<Work_Permit_Filing_Checklist__c> workPermitFillingChecklistListItem = new List<Work_Permit_Filing_Checklist__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            workPermitFillingChecklistListItem.add(new Work_Permit_Filing_Checklist__c());
        }
        if(doInsert){
            insert workPermitFillingChecklistListItem;
        }
        return workPermitFillingChecklistListItem;
    }

    public static List<Application_Sign_Off_Scope__c> createApplicationSignOffScopeList (Integer numberToCreate, Boolean doInsert){
        List<Application_Sign_Off_Scope__c> applicationSignOffListItem = new List<Application_Sign_Off_Scope__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            applicationSignOffListItem.add(new Application_Sign_Off_Scope__c());
        }
        if(doInsert){
            insert applicationSignOffListItem;
        }
        return applicationSignOffListItem;
    }

    public static List<Vendor_Request__c> createVendorRequestList (Integer numberToCreate, Boolean doInsert){
        List<Vendor_Request__c> vendorRequestList = new List<Vendor_Request__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            vendorRequestList.add(new Vendor_Request__c());
        }
        if(doInsert){
            insert vendorRequestList;
        }
        return vendorRequestList;
    }

    public static List<Check__c> createCheckList (Integer numberToCreate, Id accountId, Boolean doInsert){
        accountId = accountId == null ? createAccountList (1, null, true)[0].Id : accountId;
        List<Check__c> checkListItem = new List<Check__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            checkListItem.add(new Check__c(Account__c = accountId));
        }
        if(doInsert){
            insert checkListItem;
        }
        return checkListItem;
    }

    public static List<Reimbursable_Expense_Invoice__c> createReimbursableExpenseInvoiceList (Integer numberToCreate, Boolean doInsert){
        List<Reimbursable_Expense_Invoice__c> reimbursableExpenseInvoiceListItem = new List<Reimbursable_Expense_Invoice__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            reimbursableExpenseInvoiceListItem.add(new Reimbursable_Expense_Invoice__c());
        }
        if(doInsert){
            insert reimbursableExpenseInvoiceListItem;
        }
        return reimbursableExpenseInvoiceListItem;
    }
//cannot execute dml operation if this method has been executed
    public static List<EmailTemplate> createEmailTemplateList (Integer numberToCreate, String developerNameUnique, Id folderEmailTemplateId, String emailTemplateType, Boolean doInsert){
        developerNameUnique = String.isEmpty(developerNameUnique) ? 'TestDeveloperName' : developerNameUnique;
        folderEmailTemplateId = folderEmailTemplateId == null ? [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1][0].Id : folderEmailTemplateId;
        emailTemplateType = String.isEmpty(emailTemplateType) ? 'text' : emailTemplateType;
        List<EmailTemplate> emailTemplateListItem = new List<EmailTemplate>();
        for (Integer i = 0; i < numberToCreate; i++){
            emailTemplateListItem.add(new EmailTemplate(Name = developerNameUnique,
                                                        DeveloperName = developerNameUnique + String.valueOf(i),
                                                        FolderId = folderEmailTemplateId,
                                                        TemplateType = emailTemplateType));
        }
        if(doInsert){
            insert emailTemplateListItem;
        }
        return emailTemplateListItem;
    }
    
    public static List<Manage_Response_From_Authority__c> createManageResponceFromAuthority (Integer numberToCreate, Boolean doInsert){
        List<Manage_Response_From_Authority__c> ManageResponceFromAuthorityList = new List<Manage_Response_From_Authority__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            ManageResponceFromAuthorityList.add(new Manage_Response_From_Authority__c());
        }
        if(doInsert){
            insert ManageResponceFromAuthorityList;
        }
        return ManageResponceFromAuthorityList;
    }
    
    public static List<Comments_Transmittal__c> createCommnetsTransmittal(Integer numberToCreate, Boolean doInsert){
        List<Comments_Transmittal__c> CommnetsTransmittalList = new List<Comments_Transmittal__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            CommnetsTransmittalList.add(new Comments_Transmittal__c());
        }
        if(doInsert){
            insert CommnetsTransmittalList;
        }
        return CommnetsTransmittalList;
    }
    
    public static List<Transmittal__c> createTransmital(Integer numberToCreate, Boolean doInsert){
        List<Transmittal__c> TransmittalList = new List<Transmittal__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            TransmittalList.add(new Transmittal__c());
        }
        if(doInsert){
            insert TransmittalList;
        }
        return TransmittalList;
    }
    
    public static List<Appointment__c> createAppointmentList(Integer numberToCreate, Boolean doInsert){
        List<Appointment__c> AppointmentList = new List<Appointment__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            AppointmentList.add(new Appointment__c());
        }
        if(doInsert){
            insert AppointmentList;
        }
        return AppointmentList;
    }

    public static List<Attendee__c> createAttendeeList(Integer numberToCreate, Boolean doInsert, Id appointmentId){
        List<Attendee__c> AttendeeList = new List<Attendee__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            AttendeeList.add(new Attendee__c(Appointment__c = appointmentId));
        }
        if(doInsert){
            insert AttendeeList;
        }
        return AttendeeList;
    }
/*
    public static List<ffirule__IntegrationRule__c> createIntegrationRule (Integer numberToCreate, String sourceObjectNameField, String sourceObject,String targetObjectNameField,String targetObject, Boolean doInsert){
        sourceObjectNameField = String.isBlank(sourceObjectNameField) ? 'Name' : sourceObjectNameField;        
        sourceObject = String.isBlank(sourceObject) ? 'c2g__codaPurchaseInvoice__c' : sourceObject;    
        targetObjectNameField = String.isBlank(targetObjectNameField) ? 'Name' : targetObjectNameField;    
        targetObject = String.isBlank(targetObject) ? 'Billing_Line_Item__c' : targetObject;    
        List<ffirule__IntegrationRule__c> integrationRuleList = new List<ffirule__IntegrationRule__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            integrationRuleList.add (new ffirule__IntegrationRule__c (ffirule__SourceObjectNameField__c = sourceObjectNameField,ffirule__SourceObject__c = sourceObject,ffirule__TargetObjectNameField__c = targetObjectNameField,ffirule__TargetObject__c = targetObject ));
        }
        if (doInsert){
            insert integrationRuleList;
        }
        return integrationRuleList;
    }
   
    
    public static List<ffirule__IntegrationRuleJob__c> createIntegrationRuleJob (Integer numberToCreate, String jobName, Id integraionRuleId ,String listViewName, Boolean doInsert){
        jobName = String.isBlank(jobName) ? 'Create Payable Invoice Job' : jobName;      
        listViewName = String.isBlank(listViewName) ? 'TestViewName' : listViewName;      
        List<ffirule__IntegrationRuleJob__c> integrationRuleJobList = new List<ffirule__IntegrationRuleJob__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            integrationRuleJobList.add (new ffirule__IntegrationRuleJob__c (Name = jobName,ffirule__IntegrationRule__c = integraionRuleId,ffirule__ListViewName__c = listViewName ));
        }
        if (doInsert){
            insert integrationRuleJobList;
        }
        return integrationRuleJobList;
    } 
    
    public static  ffirule__IntegrationRuleJob__c createOneIntegrationRuleJob(){
        return TestingUtils.createIntegrationRuleJob(1, null, TestingUtils.createIntegrationRule(1, null, null, null, null, true)[0].Id, null, true)[0];
    }  
*/
    public static List<Task_Item_Functionality__c> createTaskItemFunctionality(Integer numberToCreate, Boolean doInsert){
        List<Task_Item_Functionality__c> taskItemFunctionalityList = new List<Task_Item_Functionality__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            taskItemFunctionalityList.add(new Task_Item_Functionality__c());
        }
        if(doInsert){
            insert taskItemFunctionalityList;
        }
        return taskItemFunctionalityList;
    }
    
    public static List<DDP_Helper__c> createDDPHelperList(Integer numberToCreate, Boolean doInsert){
        List<DDP_Helper__c> dDPHelperList = new List<DDP_Helper__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            dDPHelperList.add(new DDP_Helper__c());
        }
        if(doInsert){
            insert dDPHelperList;
        }
        return dDPHelperList;
    }
    
    public static List<Deposit_Invoice__c> createDepostiInvoiceList(Integer numberToCreate, Boolean doInsert){
        List<Deposit_Invoice__c> depositInvoiceList = new List<Deposit_Invoice__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            depositInvoiceList.add(new Deposit_Invoice__c());
        }
        if(doInsert){
            insert depositInvoiceList;
        }
        return depositInvoiceList;
    }

    public static List<ffirule__IntegrationRule__c> createIntegrationRuleList (Integer numberToCreate, String sourceObjectNameField,
                                                                                String sourceObject, String targetObjectNameField, String targetObject,
                                                                                Boolean doInsert){

        List<ffirule__IntegrationRule__c> integrationRuleList = new List<ffirule__IntegrationRule__c>();

        String sourceObjectNameFieldItem = String.isEmpty(sourceObjectNameField) ? 'Name' : sourceObjectNameField;
        String sourceObjectItem = String.isEmpty(sourceObject) ? 'Pro_forma_Invoice__c' : sourceObject;
        String targetObjectNameFieldItem = String.isEmpty(targetObjectNameField) ? 'Name' : targetObjectNameField;
        String targetObjectItem = String.isEmpty(targetObject) ? 'c2g__codaInvoice__c' : targetObject;

        for (Integer i = 0; i < numberToCreate; i++){
            integrationRuleList.add(new ffirule__IntegrationRule__c(ffirule__SourceObjectNameField__c = sourceObjectNameFieldItem,
                                                                    ffirule__SourceObject__c = sourceObjectItem,
                                                                    ffirule__TargetObjectNameField__c = targetObjectNameFieldItem,
                                                                    ffirule__TargetObject__c = targetObjectItem));
        }

        if (doInsert){
            insert integrationRuleList;
        }

        return integrationRuleList;
    }

    public static List<ffirule__IntegrationRuleJob__c> createIntegrationRuleJobList(Integer numberToCreate, Id integrationRuleId, String listViewNameValue, Boolean doInsert){
        List<ffirule__IntegrationRuleJob__c> integrationRuleJobList = new List<ffirule__IntegrationRuleJob__c>();

        String listViewNameValueItem = String.isEmpty(listViewNameValue) ? 'test' : listViewNameValue;
        Id integrationRuleIdItem = integrationRuleId == null ? createIntegrationRuleList(1, null, null, null, null, true)[0].Id : integrationRuleId;

        for (Integer i = 0; i < numberToCreate; i++){
            integrationRuleJobList.add(new ffirule__IntegrationRuleJob__c(ffirule__IntegrationRule__c = integrationRuleIdItem, ffirule__ListViewName__c = listViewNameValueItem));
        }
        return integrationRuleJobList;
    }

    public static List<Deposit_invoice__c> createDepositInvoiceList (Integer numberToCreate, Id proposalId, Id projectId, Boolean doInsert){
        List<Deposit_invoice__c> depositInvoiceList = new List<Deposit_Invoice__c>();

        if (proposalId == null && projectId == null){
            projectId = createProjectProfileForTest(1, true)[0].Id;
        }

        for (Integer i = 0; i < numberToCreate; i++){
            depositInvoiceList.add(new Deposit_invoice__c(Proposal__c = proposalId, Project_Profile__c = projectId));
        }
        if (doInsert){
            insert depositInvoiceList;
        }
        return depositInvoiceList;
    }

    public static List<Legacy_Billing_Item__c> createLegacyBillingItemList (Integer numberToCreate, Date dateAdded, String invoiceLineDescription,
                                                                            String mRC, Id teritoryId, Id productId, Id departmentId, Boolean doInsert){
        List<Legacy_Billing_Item__c> legacyBillingItemList = new List<Legacy_Billing_Item__c>();

        dateAdded = dateAdded == null ? Date.today() : dateAdded;
        invoiceLineDescription = String.isBlank(invoiceLineDescription) ? 'TestDescription' : invoiceLineDescription;
        mRC = String.isBlank(mRC) ?  'TestId' : mRC;
        teritoryId = teritoryId != null ? teritoryId : createDimension2List(1, null, true)[0].Id;
        productId = productId != null ? productId : createProduct2List(1, null, true)[0].Id;
        departmentId = departmentId != null ? departmentId : createDimension_1_List(1, true)[0].Id;

        for (Integer i = 0; i < numberToCreate; i++){
            legacyBillingItemList.add ( new Legacy_Billing_Item__c ( Date_Added__c =  dateAdded, Invoice_Line_Description__c = invoiceLineDescription + i,
                                                                    Territory__c = teritoryId, Department__c = departmentId, Product_Name__c = productId )
                                      );
        }

        if (doInsert){
            insert legacyBillingItemList;
        }

        return legacyBillingItemList;
    }

    public static List<Legacy_Pro_forma_Invoice__c> createLegacyProFormaInvoiceList (Integer numberToCreate, Boolean doInsert){
        List<Legacy_Pro_forma_Invoice__c> legacyProFormaInvoiceList = new List<Legacy_Pro_forma_Invoice__c>();
        for (Integer i = 0; i < numberToCreate; i++){
            legacyProFormaInvoiceList.add(new Legacy_Pro_forma_Invoice__c());
        }
        if (doInsert){
            insert legacyProFormaInvoiceList;
        }
        return legacyProFormaInvoiceList;
    }
    public static List<Project__c> createProjectMI7List (Integer numberToCreate,String mRC, Boolean doInsert){   
        List<Project__c> projectMI7List = new List<Project__c>();     
        mRC = String.isBlank(mRC) ?  'TestId' : mRC;        
        for (Integer i = 0; i < numberToCreate; i++){
            projectMI7List.add(new Project__c(MRC__c = mRC + i));
        }
        if (doInsert){
            insert projectMI7List;
        }
        return projectMI7List;
    }

    public static List<Form_Meta_Data_Object_1__c> createFormMetaDataObject1List(Integer numberToCreate, Id formItemId, Boolean doInsert){
        List<Form_Meta_Data_Object_1__c> createdFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();

        formItemId = formItemId == null ? createFormItemList(1, true)[0].Id : formItemId;

        for(Integer i = 0; i < numberToCreate; i++){
            createdFormMetaDataObject1List.add(new Form_Meta_Data_Object_1__c(Form_Item__c = formItemId));
        }

        if(doInsert){
            insert createdFormMetaDataObject1List;
        }

        return createdFormMetaDataObject1List;
    }
/*
    public static List<Form_Meta_Data_Object_1__c> createFormMetaDataObject1List(Integer numberToCreate, Boolean doInsert){
        List<Form_Meta_Data_Object_1__c> createdFormMetaDataObject1List = new List<Form_Meta_Data_Object_1__c>();

        for(Integer i = 0; i < numberToCreate; i++){
            createdFormMetaDataObject1List.add(new Form_Meta_Data_Object_1__c());
        }

        if(doInsert){
            insert createdFormMetaDataObject1List;
        }

        return createdFormMetaDataObject1List;
    }
*/
    public static List<Last_Proposal_Price__c> createLastProposalPriceList(Integer numberToCreate, Boolean doInsert){
        List<Last_Proposal_Price__c> createdLastProposalPriceList = new List<Last_Proposal_Price__c>();

        for(Integer i = 0; i < numberToCreate; i++){
            createdLastProposalPriceList.add(new Last_Proposal_Price__c());
        }

        if(doInsert){
            insert createdLastProposalPriceList;
        }

        return createdLastProposalPriceList;
    }

    public static List<Service_Floor_Junction__c> createServiceFloorJunctionList(Integer numberToCreate, Id serviceItemId, Id floorId, Boolean doInsert){
        List<Service_Floor_Junction__c> createdServiceFloorJunctionList = new List<Service_Floor_Junction__c>();

        serviceItemId = serviceItemId != null ? serviceItemId : createServiceItemList(1, true)[0].Id;
        floorId = floorId != null ? floorId : createFloorList(1, true)[0].Id;

        for(Integer i = 0; i < numberToCreate; i++){
            createdServiceFloorJunctionList.add(new Service_Floor_Junction__c(Service_Item__c = serviceItemId, Floor__c = floorId));
        }

        if(doInsert){
            insert createdServiceFloorJunctionList;
        }

        return createdServiceFloorJunctionList;
    }

    public static List<Attachment> createAttachmentList(Integer numberToCreate, Id parentId, String attachmentName, Blob bodyValue, Boolean isPrivate, Boolean doInsert){
        List<Attachment> createdAttachmentList = new List<Attachment>();

        parentId = parentId != null ? parentId : createAccountList(1, null, true)[0].Id;
        attachmentName = attachmentName != null ? attachmentName : 'test';
        bodyValue = bodyValue != null ? bodyValue : Blob.valueOf('test body value');
        isPrivate = isPrivate != null ? isPrivate : true;

        for (Integer i = 0; i < numberToCreate; i++){
            createdAttachmentList.add(new Attachment ( IsPrivate = isPrivate, ParentId = parentId, Name = attachmentName, Body = bodyValue) );
        }

        if ( doInsert ){
            insert createdAttachmentList;
        }

        return createdAttachmentList;
    }

    public static List<dsfs__DocuSign_Status__c> createDocuSignStatusList(Integer numberToCreate, Boolean doInsert){
        List<dsfs__DocuSign_Status__c> createdDocuSignStatusList = new List<dsfs__DocuSign_Status__c>();

        for(Integer i = 0; i < numberToCreate; i++){
            createdDocuSignStatusList.add(new dsfs__DocuSign_Status__c());
        }

        if(doInsert){
            insert createdDocuSignStatusList;
        }

        return createdDocuSignStatusList;
    }

    public static List<dsfs__DocuSign_Recipient_Status__c> createDocuSignRecipientStatusList(Integer numberToCreate, Id docuSignStatusId, Boolean doInsert){
        List<dsfs__DocuSign_Recipient_Status__c> createdDocuSignRecipientStatusList = new List<dsfs__DocuSign_Recipient_Status__c>();

        docuSignStatusId = docuSignStatusId != null ? docuSignStatusId : createDocuSignStatusList(1, true)[0].Id;

        for(Integer i = 0; i < numberToCreate; i++){
            createdDocuSignRecipientStatusList.add(new dsfs__DocuSign_Recipient_Status__c(dsfs__Parent_Status_Record__c = docuSignStatusId, dsfs__DocuSign_Recipient_Id__c = docuSignStatusId + String.valueOf(i) + String.valueOf(DateTime.now().millisecond())));
        }

        if(doInsert){
            insert createdDocuSignRecipientStatusList;
        }

        return createdDocuSignRecipientStatusList;
    }

    public static List<Drawings_Received__c> createDrawingsReceivedList(Integer numberToCreate, Id projectProfileId, Boolean doInsert){
        List<Drawings_Received__c> createdDrawingsReceivedList = new List<Drawings_Received__c>();

        if ( projectProfileId == null ){
            projectProfileId = createProjectProfileForTest(1, true)[0].Id;
        }

        for(Integer i = 0; i < numberToCreate; i++){
            createdDrawingsReceivedList.add(new Drawings_Received__c(Project_Profile__c = projectProfileId));
        }

        if(doInsert){
            insert createdDrawingsReceivedList;
        }

        return createdDrawingsReceivedList;
    }

    public static List<Terms_And_Conditions__c> createTermsAndConditionsList(Integer numberToCreate, Id accountId, Boolean doInsert){
        List<Terms_And_Conditions__c> createdTermsAndConditionsList = new List<Terms_And_Conditions__c>();

        if ( accountId == null ){
            accountId = createAccountList(1, null, true)[0].Id;
        }

        for(Integer i = 0; i < numberToCreate; i++){
            createdTermsAndConditionsList.add(new Terms_And_Conditions__c(Account__c = accountId));
        }

        if(doInsert){
            insert createdTermsAndConditionsList;
        }

        return createdTermsAndConditionsList;
    }

    public static Group testGroup;
    public static c2g__codaCompany__c company;
    public static c2g__codaYear__c yr;
    public static c2g__codaPeriod__c prd;
    public static c2g__codaUserCompany__c userCompany;
    public static c2g__codaAccountingCurrency__c accCurrency;
    public static c2g__codaExchangeRate__c exchRate;
    public static c2g__codaGeneralLedgerAccount__c testGLAcc;

    public static Group createGruopForFF(){
        testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        QueuesObject testQueue ; 
        System.runAs(new User(Id=UserInfo.getUserId())){
             List<queuesobject >  listQueue = new List<queuesobject >();
            queuesobject q1 = new queuesobject (queueid=testGroup.id, sobjecttype='Case'); 
            listQueue.add(q1);
            queuesobject q2 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaAccountingCurrency__c'); 
            listQueue.add(q2);
            queuesobject q3 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaPurchaseInvoice__c'); 
            listQueue.add(q3);
            queuesobject q4 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaCompany__c'); 
            listQueue.add(q4);
            queuesobject q5 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaYear__c'); 
            listQueue.add(q5);
            queuesobject q6 = new queuesobject (queueid=testGroup.id, sobjecttype='c2g__codaInvoice__c'); 
            listQueue.add(q6);
            insert  listQueue;

            GroupMember GroupMemberObj = new GroupMember();
            GroupMemberObj.GroupId = testGroup.id;
            GroupMemberObj.UserOrGroupId = UserInfo.getUserId();
            insert GroupMemberObj;
        }

        return testGroup;
    }

    public static c2g__codaCompany__c createCodaCompany(){
        company = new c2g__codaCompany__c();
        company.Name = 'Test Record';
        company.c2g__CashMatchingCurrencyMode__c = 'Test Account';
        company.c2g__YearEndMode__c = 'Test Code';
        company.c2g__ExternalId__c = 'ABCDE1234567876';
        company.c2g__LogoURL__c ='ww.XYZ.com';
        company.c2g__ECCountryCode__c = 'AE' ;
        company.c2g__VATRegistrationNumber__c = 'Test 222.222.222 TVA' ;
        company.c2g__Website__c = 'ww.xyz.com';
        company.c2g__Country__c ='US';
        company.ownerid = testGroup.Id;
        insert company;

        return company;
    }

    public static c2g__codaYear__c createCodaYear(Boolean doInsert){
        yr= new c2g__codaYear__c();
        yr.Name ='2015';
        yr.c2g__AutomaticPeriodList__c =  true;
        yr.c2g__OwnerCompany__c = company.id;
        yr.c2g__ExternalId__c = 'yzsd1234';
        yr.c2g__NumberOfPeriods__c =11;
        yr.c2g__StartDate__c =  system.today() - 10;
        yr.c2g__Status__c = 'Open';
        yr.c2g__PeriodCalculationBasis__c = '445';
        yr.c2g__YearEndMode__c = 'Full Accounting Code' ; 
        yr.c2g__UnitOfWork__c = 12;
        yr.ownerid = testGroup.Id;
        if (doInsert){
            insert yr;
        }

        return yr;
    }

    public static c2g__codaPeriod__c createCodaPeriod(Boolean doInsert){
        prd = new c2g__codaPeriod__c();
        prd.Name ='Test2015';
        prd.c2g__ExternalId__c ='abdc12345';
        prd.c2g__StartDate__c = System.today()-10;
        prd.c2g__EndDate__c= System.today()+10;
        prd.c2g__OwnerCompany__c = company.id;
        prd.c2g__PeriodNumber__c ='123';
        prd.c2g__Description__c ='test Desc';
        prd.c2g__PeriodGroup__c = 'Q1';
        prd.c2g__PeriodNumber__c = '1';
        prd.c2g__YearName__c = yr.id;
        if (doInsert){
            insert prd;
        }

        return prd;
    }

    public static c2g__codaUserCompany__c createUserCompany(Boolean doInsert){
        userCompany = new c2g__codaUserCompany__c();
        userCompany.c2g__Company__c =company.id;
        userCompany.c2g__User__c = userInfo.getUserId();
        userCompany.c2g__ExternalId__c = 'ABCDE1234567876';
        userCompany.c2g__UnitOfWork__c = 111 ;
        if (doInsert){
            insert userCompany;
        }

        return userCompany;
    }

    public static c2g__codaAccountingCurrency__c createAccountingCurrency(Boolean doInsert){
        accCurrency = new c2g__codaAccountingCurrency__c();
        accCurrency.c2g__OwnerCompany__c = company.id;
        accCurrency.c2g__DecimalPlaces__c = 2;
        accCurrency.Name = 'AED';
        accCurrency.c2g__Dual__c = true ;
        accCurrency.ownerid = testGroup.Id;
        if (doInsert){
            insert accCurrency;
        }

        return accCurrency;
    }

    public static c2g__codaExchangeRate__c createExchangeRate(Boolean doInsert){
        exchRate = new c2g__codaExchangeRate__c();
        exchRate.c2g__ExchangeRateCurrency__c = accCurrency.id;
        exchRate.c2g__OwnerCompany__c = company.id;
        exchRate.c2g__ExternalId__c ='12323232';
        exchRate.c2g__Rate__c =44.55;
        exchRate.c2g__StartDate__c = system.today()-10;
        exchRate.c2g__UnitOfWork__c =10;
        if (doInsert){
            insert exchRate;
        }

        return exchRate;
    }

    public static c2g__codaGeneralLedgerAccount__c createGeneralLedgerAccount(Boolean doInsert){
        testGLAcc = new c2g__codaGeneralLedgerAccount__c();
        testGLAcc.Name = 'Retained Earnings';
        testGLAcc.c2g__BalanceSheet1__c ='Balance Sheet';
        testGLAcc.c2g__ExternalId__c ='testID';
        testGLAcc.c2g__ReportingCode__c = '1234567543333';
        testGLAcc.c2g__UnitOfWork__c =123;
        testGLAcc.c2g__TrialBalance1__c = 'Balance Sheet' ;
        testGLAcc.c2g__Type__c = 'Balance Sheet';
        if (doInsert){
            insert testGLAcc;
        }

        return testGLAcc;
    }

    public static void prepareDataForFF(){
        createGruopForFF();
        createCodaCompany();
        createCodaYear(true);
        createCodaPeriod(true);
//        createUserCompany(true);
        createAccountingCurrency(true);
        createExchangeRate(true);
        createGeneralLedgerAccount(true);
    }

//    private class TestException extends Exception{}
}