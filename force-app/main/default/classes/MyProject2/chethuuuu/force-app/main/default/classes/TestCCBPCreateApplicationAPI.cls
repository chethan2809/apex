@IsTest
private class TestCCBPCreateApplicationAPI {

    @testSetup
    private static void dataSetup() {

        TestUtility.runSetupData();
        TestUtility.createCompany();

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;

        System.runAs(adminUser){
            Account account = new Account(Name='Test Account Name');
            insert account;

            Contact contact = new Contact(LastName = 'Contact Last Name', AccountId = account.Id);
            insert contact;

            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='BrokerCommunityPlus'].Id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = TestUtility.generateFakeName() + '@example.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'test@uniquedomain.com';
            user.IsActive = true;
            user.ContactId = contact.Id;
            insert user;
        }
    }

    @isTest
    static void CCBPCreateApplicationAPI()
    {
        loan__Loan_Product__c loanProduct = new loan__Loan_Product__c();
        loanProduct.Name = 'CAN Capital';
        loanProduct.loan__Default_Number_of_Installments__c = 6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct;

        clcommon__CL_Product__c productCL = new clcommon__CL_Product__c();
        productCL.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL.loan__Lending_Product__c = loanProduct.Id;
        insert productCL;

        genesis__Company__c company = new genesis__Company__c();
        company.Name = 'CAN Capital';
        company.genesis__Short_Name__c = 'CAN';
        insert company;

        GeneralHelper.currentSystemDate = Date.newInstance(2018, 01, 01);
        clcommon__Company__c clCompany = new clcommon__Company__c();
        clCompany.clcommon__Company_Name__c = 'CAN Capital';
        clCompany.clcommon__Branch_Date__c = GeneralHelper.currentSystemDate;
        insert clCompany;

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        User testUser = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456611","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPIIndustryException()
    {
        CAN_Industry_Rating_Profile__c irp = new CAN_Industry_Rating_Profile__c();
        irp.Description__c = 'BUSINESS SERVICES';
        irp.Digit_Code__c = '73';
        irp.Industry_Rating__c = 'Prohibited';
        irp.Id = TestUtility.getFakeId(CAN_Industry_Rating_Profile__c.getSObjectType());

        DBManagerTestsStub industryRatingProfileStubInstance = new DBManagerTestsStub();
        industryRatingProfileStubInstance.genericReturnObject = new List<CAN_Industry_Rating_Profile__c>{irp};
        OriginationHelper.industryRatingProfileDBInstance = (IndustryRatingProfileDB) Test.createStub(IndustryRatingProfileDB.class, industryRatingProfileStubInstance);

        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        User testUser = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456612","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();
        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPITitleException()
    {
        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        User testUser = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456613","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"Other","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPICountryException()
    {
        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        User testUser = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456614","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"UK","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"UK","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPIExistingContact()
    {
        Account account = new Account();
        account.Name = 'Dummy Account';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CCBPCreateApplicationAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.FirstName = 'first';
        contact.LastName = 'last';
        contact.Email = 'Testemailccbp@gmail.com';
        contact.AccountId = TestUtility.getFakeId(Account.getSObjectType());
        contact.loan__Contact_Type__c = Leads.GUARANTOR;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub ContactDBStubInstance = new DBManagerTestsStub();
        ContactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        CCBPCreateApplicationAPI.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, ContactDBStubInstance);

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "'+ contact.AccountId +'"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contact.Id;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPCreateApplicationAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c>{legalEntity};
        CCBPCreateApplicationAPI.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        Lead leadRecord = new Lead();
        leadRecord.LastName = TestUtility.generateFakeName();
        leadRecord.Company = 'Test Company';
        leadRecord.LeadSource = 'Merchant Phone';
        leadRecord.Id = TestUtility.getFakeId(Lead.getSObjectType());

        DBManagerTestsStub leadDBStubInstance = new DBManagerTestsStub();
        leadDBStubInstance.genericReturnObject = new List<Lead>{leadRecord};
        CCBPCreateApplicationAPI.leadDBInstance = (leadDB) Test.createStub(leadDB.class, leadDBStubInstance);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'New';
        newOpportunity.Primary_Contact__c = contact.Id;
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        opportunityDBStubInstance.genericReturnObject = new List<Opportunity>{newOpportunity};
        CCBPCreateApplicationAPI.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Maximum_Funding_Amount__c = 275000;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCBPCreateApplicationAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__c = contact.Id;
        party.clcommon__Account__c = account.Id;
        party.clcommon__Type__c = partyTypeGuarantor.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CCBPCreateApplicationAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456615","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"first","lastName":"last","email":"Testemailccbp@gmail.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPIExistingContact1()
    {
        Account account = new Account();
        account.Name = 'Dummy Account';
        account.Type = GeneralConstants.PARTY_TYPE_BORROWER;
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(account.Type).getRecordTypeId();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        CCBPCreateApplicationAPI.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Id contactId = TestUtility.getFakeId(Contact.getSObjectType());

        User testUser = (User) JSON.deserialize(
            '{ "AccountId" : "'+ contact.AccountId +'"}' , User.class
        );
        testUser.Email = 'no@email.com';
        testUser.ContactId = contactId;
        testUser.Id = TestUtility.getFakeId(User.getSObjectType());

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        CCBPCreateApplicationAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c();
        legalEntity.Name = GeneralConstants.LEGAL_TYPE_CORPORATION;
        legalEntity.Id = TestUtility.getFakeId(clcommon__Legal_Entity__c.getSObjectType());

        DBManagerTestsStub legalEntityDBStubInstance = new DBManagerTestsStub();
        legalEntityDBStubInstance.genericReturnObject = new List<clcommon__Legal_Entity__c>{legalEntity};
        CCBPCreateApplicationAPI.legalEntityDBInstance = (LegalEntityDB) Test.createStub(LegalEntityDB.class, legalEntityDBStubInstance);

        Lead leadRecord = new Lead();
        leadRecord.LastName = TestUtility.generateFakeName();
        leadRecord.Company = 'Test Company';
        leadRecord.LeadSource = 'Merchant Phone';
        leadRecord.Id = TestUtility.getFakeId(Lead.getSObjectType());

        DBManagerTestsStub leadDBStubInstance = new DBManagerTestsStub();
        leadDBStubInstance.genericReturnObject = new List<Lead>{leadRecord};
        CCBPCreateApplicationAPI.leadDBInstance = (leadDB) Test.createStub(leadDB.class, leadDBStubInstance);

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.StageName = 'New';
        newOpportunity.Primary_Contact__c = contactId;
        newOpportunity.Id = TestUtility.getFakeId(Opportunity.getSObjectType());

        DBManagerTestsStub opportunityDBStubInstance = new DBManagerTestsStub();
        opportunityDBStubInstance.genericReturnObject = new List<Opportunity>{newOpportunity};
        CCBPCreateApplicationAPI.opportunityDBInstance = (OpportunityDB) Test.createStub(OpportunityDB.class, opportunityDBStubInstance);

        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(
            '{ "Origination_Fee_Amount__c" : "299", "Business_Type__c" : "Sole Proprietorship"}' , genesis__Applications__c.class
        );
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());
        application.genesis__Account__c = TestUtility.getFakeId(Account.getSObjectType());
        application.Opportunity__c = TestUtility.getFakeId(Opportunity.getSObjectType());
        application.Industry_Rating__c = 'A+ Medical';
        application.SC4_Tier__c = 'TIER 1';
        application.Annual_Volume__c = 1413777;
        application.Type__c = 'New';
        application.Origination_Fee_Percentage__c = 1;
        application.genesis__Payment_Frequency__c = 'DAILY';
        application.Maximum_Funding_Amount__c = 275000;

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        CCBPCreateApplicationAPI.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        clcommon__Party_Type__c partyTypeGuarantor = new clcommon__Party_Type__c();
        partyTypeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        partyTypeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c party = new clcommon__Party__c();
        party.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());
        party.genesis__Application__c = application.Id;
        party.clcommon__Contact__c = contactId;
        party.clcommon__Account__c = account.Id;
        party.clcommon__Type__c = partyTypeGuarantor.Id;

        DBManagerTestsStub partyDBStubInstance = new DBManagerTestsStub();
        partyDBStubInstance.genericReturnObject = new List<clcommon__Party__c>{party};
        CCBPCreateApplicationAPI.partyDBInstance = (PartyDB) Test.createStub(PartyDB.class, partyDBStubInstance);

        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Id = TestUtility.getFakeId(Error_Log__c.getSObjectType());

        DBManagerTestsStub errorLogDBStubInstance = new DBManagerTestsStub();
        errorLogDBStubInstance.genericReturnObject = new List<Error_Log__c>{errorLog};
        CCBPCreateApplicationAPI.errorLogDBInstance = (ErrorLogDB) Test.createStub(ErrorLogDB.class, errorLogDBStubInstance);

        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456616","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"first","lastName":"last","email":"Testemailccbp@gmail.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Test.startTest();
           clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    static void CCBPCreateApplicationAPIAgeException()
    {
        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;
        User testUser = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456617","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"New York","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"Other","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"2020-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"New York","mailingCountry":"US","mailingPostalCode":"11738"}}';
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);
        Test.startTest();
        clcommon.Response response = new CCBPCreateApplicationAPI().invokeAction('', null, requestMap);
        Test.stopTest();
        System.assert(response != null);
    }
}