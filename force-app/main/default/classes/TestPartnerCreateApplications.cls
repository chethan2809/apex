@IsTest
private class TestPartnerCreateApplications {

    @testSetup
    private static void setup() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account account = TestUtility.generateAccount();
            account.Name='Test Account Name';
            account.Legacy_AccountID__c = '23456789';
            insert account;

            Contact contact = TestUtility.generateContact();
            contact.LastName = 'Contact Last Name';
            contact.AccountId = account.Id;
            insert contact;

            Default_Portal_Owner_Mapping__mdt defaultPortalOwner = [Select DeveloperName, Owner_Email__c FROM Default_Portal_Owner_Mapping__mdt WHERE DeveloperName = 'Default_Broker_Portal_Owner' LIMIT 1];

            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='BrokerCommunityPlus'].Id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = TestUtility.generateFakeName() + 'test12@test.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'test@uniquedomain.com';
            user.IsActive = true;
            user.ContactId = contact.Id;
            insert user;
        }

        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        System.runAs(testUser) {
            TestUtility.runSetupData();
            TestUtility.createCompany();

            clcommon__Company__c clCompany = new clcommon__Company__c();
            clCompany.clcommon__Company_Name__c = 'CAN Capital';
            clCompany.clcommon__Branch_Date__c = date.newInstance(2020, 01, 01);
            insert clCompany;

            Account acc = [SELECT Id FROM Account WHERE Name = 'Web Bank'];
            acc.Merchant_ID__c = '999999999';
            Update acc;
        }
    }

    @isTest
    static void buildRequest() {
        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];
        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc98","phone":"8454243000","industry":"Business Services","taxId":"45456698","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":""},"contactDetails":{"title":"CEO","firstName":"Ira98","lastName":"Boyar98","email":"iraboyar98@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);

        Test.startTest();
           Map<String, Object> request = PartnerCreateApplications.buildRequest(requestMap);
        Test.stopTest();

        System.assert(request != null);
    }

    @isTest
    static void createApplication() {

        loan__Loan_Product__c loanProduct1 = new loan__Loan_Product__c();
        loanProduct1.Name = 'CAN Capital';
        loanProduct1.loan__Default_Number_of_Installments__c = 6;
        loanProduct1.loan__Frequency_of_Loan_Payment__c = 'WEEKLY';
        insert loanProduct1;

        clcommon__CL_Product__c productCL1 = new clcommon__CL_Product__c();
        productCL1.clcommon__Product_Name__c = GeneralConstants.PRODUCT_NAME_DEFAULT;
        productCL1.loan__Lending_Product__c = loanProduct1.Id;
        insert productCL1;

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

        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        clcommon__Legal_Entity__c legalEntity = new clcommon__Legal_Entity__c(Name = 'Corporation', clcommon__Legal_Entity_Type__c = 'Corporation');
        INSERT legalEntity;

        loan__Loan_Product__c loanProduct = [SELECT Id,Name FROM loan__Loan_Product__c LIMIT 1];
        loanProduct.loan__Default_Number_of_Installments__c=6;
        loanProduct.loan__Frequency_of_Loan_Payment__c = 'Daily';
        Update loanProduct;
        clcommon__CL_Product__c cpl= new clcommon__CL_Product__c(clcommon__Product_Name__c='CAN Capital', loan__Lending_Product__c = loanProduct.Id);
        Insert cpl;

        String str = '{"loanDetails":{"loanPurpose":"Expansion","loanAmount":"20000.00"},"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"},"accountDetails":{"name":"BorrowerAcc989","phone":"8454243000","industry":"Business Services","taxId":"45456699","dba":"Test Business Trading Name","businessStructureName":"Corporation","stateOfFormation":"AZ","bizStartDate":"1990-06-07","billingStreet":"1123 Old Albany Post Road","billingBuildingNumber":"108","billingCity":"Garrison","billingState":"NY","billingPostalCode":"10524","billingCountry":"US","legalEntityType":"'+ legalEntity.Id +'"},"contactDetails":{"title":"CEO","firstName":"Ira989","lastName":"Boyar989","email":"iraboyar998@mailinator.com","phone":"8454243000","birthDate":"1998-10-06","socialSecurityNumber":"45456298","mailingStreet":"627 Horseblock Rd","mailingBuildingNumber":"108","mailingCity":"Farmingville","mailingState":"NY","mailingCountry":"US","mailingPostalCode":"11738"}}';

        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);
        requestMap = PartnerCreateApplications.buildRequest(requestMap);

        Id applicationId;
        Exception ex;
        Test.startTest();
            try {
                applicationId = PartnerCreateApplications.createApplication(requestMap);
            }
            catch(Exception e) {
                ex = e;
            }
        Test.stopTest();
    }

    @isTest
    static void buildResponse() {
        Default_Portal_Owner_Mapping__mdt defaultPortalOwner = new Default_Portal_Owner_Mapping__mdt();
        defaultPortalOwner.DeveloperName = PortalConstants.DEFAULT_BROKER_PORTAL_OWNER;
        defaultPortalOwner.MasterLabel = defaultPortalOwner.DeveloperName;
        defaultPortalOwner.Owner_Email__c = 'test@uniquedomain.com';
        Map<String, Default_Portal_Owner_Mapping__mdt> defaultPortalOwnerMap = new Map<String, Default_Portal_Owner_Mapping__mdt>();
        defaultPortalOwnerMap.put(defaultPortalOwner.DeveloperName, defaultPortalOwner);
        CustomMetaDataHelper.defaultPortalOwnerMap = defaultPortalOwnerMap;

        User userRec = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        genesis__Applications__c application = new genesis__Applications__c();
        application.Broker_Contact__c = userRec.ContactId;
        application.Type__c = 'New';
        application.Industry_Rating__c = 'B';
        application.SC4_Tier__c = 'TIER 2';
        application.genesis__Payment_Frequency__c = 'WEEKLY';
        application.Total_Competitors_Amount__c = 1000;
        application.Id = TestUtility.getFakeId(genesis__Applications__c.getSObjectType());

        clcommon__Party_Type__c typeBorrower = new clcommon__Party_Type__c();
        typeBorrower.Name = GeneralConstants.PARTY_TYPE_BORROWER;
        typeBorrower.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party_Type__c typeGuarantor = new clcommon__Party_Type__c();
        typeGuarantor.Name = GeneralConstants.PARTY_TYPE_GUARANTOR;
        typeGuarantor.Id = TestUtility.getFakeId(clcommon__Party_Type__c.getSObjectType());

        clcommon__Party__c partyBorrower = new clcommon__Party__c();
        partyBorrower.genesis__Application__c = application.Id;
        partyBorrower.clcommon__Account__c = application.genesis__Account__c;
        partyBorrower.Competitor_Amount__c = 1000;
        partyBorrower.clcommon__Type__c= typeBorrower.Id;
        partyBorrower.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        clcommon__Party__c partyGuarantor = new clcommon__Party__c();
        partyGuarantor.genesis__Application__c = application.Id;
        partyGuarantor.clcommon__Account__c = application.genesis__Account__c;
        partyGuarantor.Competitor_Amount__c = 1000;
        partyGuarantor.clcommon__Type__c = typeGuarantor.Id;
        partyGuarantor.Id = TestUtility.getFakeId(clcommon__Party__c.getSObjectType());

        Test.startTest();
           Map<String, Object> responseMap = PartnerCreateApplications.buildResponse(new List<genesis__Applications__c>{application}, new List<clcommon__Party__c>{partyGuarantor,partyBorrower});
        Test.stopTest();

        System.assert(responseMap != null);
    }

    @isTest
    static void validateIndustryPicklist() {
        Exception ex;
        Test.startTest();
            try {
                PartnerCreateApplications.validateIndustryPicklist('Business Services');
            }
            catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertNullException(ex);
    }

    @isTest
    static void validateIndustryPicklistEmptyCheck() {
        Exception ex;
        Test.startTest();
            try {
                PartnerCreateApplications.validateIndustryPicklist('');
            }
            catch(Exception e) {
                ex = e;
            }
        Test.stopTest();

        TestUtility.assertException(ex);
        System.assertEquals(ex.getMessage(), PartnerCreateApplications.INVALID_INDUSTRY);
    }

    @isTest
    static void getIndustryPicklistAPIFromLabel() {
        Test.startTest();
           String picklistValue = PartnerCreateApplications.getIndustryPicklistAPIFromLabel('Business Services');
        Test.stopTest();

        System.assertEquals('BUSINESS SERVICES', picklistValue);
    }

    @isTest
    static void getIndustryPicklistAPIFromLabelEmptyCheck() {
        Test.startTest();
           String picklistValue = PartnerCreateApplications.getIndustryPicklistAPIFromLabel('Test');
        Test.stopTest();

        System.assertEquals(null, picklistValue);
    }

    @isTest
    static void constructRequestMap() {
        Map<String, Object> mapRecord = new Map<String, Object>{
            'name' => 'BorrowerAcc98',
            'phone' => '8454243000',
            'industry' => 'Business Services',
            'taxId' => '45456698'
        };

        Map<String, String> basicInfoMap = new Map<String, String>{
            'Name' => 'name',
            'Industry' => 'industry',
            'Phone' => 'phone',
            'TaxId' => 'taxId'
        };

        Test.startTest();
           Map<String, Object> mapRequest = PartnerCreateApplications.constructRequestMap(mapRecord, basicInfoMap);
        Test.stopTest();

        System.assert(mapRequest != null);
    }

    @isTest
    static void getPartnerEmail() {
        Map<String,Object> argumentsMap = new Map<String,Object>{
           'partnerInfo'=> '{"partnerEmail":"test_acc@mailinator.com"}'
        };

        Test.startTest();
           Set<String> partnerEmail = PartnerCreateApplications.getPartnerEmail(argumentsMap);
        Test.stopTest();

        System.assert(partnerEmail != null);
    }

}