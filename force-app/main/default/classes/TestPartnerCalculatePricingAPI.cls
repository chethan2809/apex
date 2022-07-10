@IsTest
private class TestPartnerCalculatePricingAPI {

    @testSetup
    private static void setup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

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

        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Name'];
        System.runAs(userRec) {
            TestUtility.runSetupData();
            genesis__Applications__c application = TestUtility.createApplication();
            application.Broker_Contact__c = userRec.ContactId;
            application.Type__c = 'New';
            application.Industry_Rating__c = 'B';
            application.SC4_Tier__c = 'TIER 2';
            application.genesis__Payment_Frequency__c = 'WEEKLY';
            update application;
        }
    }

    @isTest
    static void partnerGetPricingAPI() {
        GeneralHelper.currentSystemDate = Date.newInstance(2019, 01, 01);
        User testUser = [SELECT Id, email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        Account account = new Account();
        account.Id = testUser.AccountId;
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        CAN_GAV_Matrix_Detail__c gavMatrixDetail = new CAN_GAV_Matrix_Detail__c();
        gavMatrixDetail.Industry_Rating__c = 'B';
        gavMatrixDetail.SC4_Tier__c = 'TIER 2';
        gavMatrixDetail.Term__c = 14;
        gavMatrixDetail.GAV__c = 10.95;
        insert gavMatrixDetail;

        CAN_Pricing_Matrix_Detail__c pricingMatrixDetail = new CAN_Pricing_Matrix_Detail__c();
        pricingMatrixDetail.Loan_Type__c = 'New';
        pricingMatrixDetail.Industry_Rating__c = 'B';
        pricingMatrixDetail.SC4_Tier__c = 'TIER 2';
        pricingMatrixDetail.Term__c = 14;
        pricingMatrixDetail.Pricing_Rate__c = 1.28;
        insert pricingMatrixDetail;

        CAN_Max_Amount_And_Max_Term_Mapping__c maxAmountMaxTermMapping = new CAN_Max_Amount_And_Max_Term_Mapping__c();
        maxAmountMaxTermMapping.Maximum_Term__c = 14;
        maxAmountMaxTermMapping.Maximum_Amount_Multi_Location__c =  250000.0;
        maxAmountMaxTermMapping.Maximum_Amount_Single_Location__c = 175000.0;
        maxAmountMaxTermMapping.Industry_Rating__c = 'B';
        maxAmountMaxTermMapping.SC4_Tier__c = ' TIER 2';
        maxAmountMaxTermMapping.Loan_Type__c = 'New';
        insert maxAmountMaxTermMapping;

        CAN_Ocrolus_Report__c ocrolusReport = new CAN_Ocrolus_Report__c();
        ocrolusReport.Application__c = application.Id;
        ocrolusReport.Max_Daily_Payment__c = 200.00;
        insert ocrolusReport;

        CAN_Pricing_Detail__c pricingDetail = new CAN_Pricing_Detail__c();
        pricingDetail.Application__c = application.Id;
        pricingDetail.Term__c = 14;
        pricingDetail.Industry_Rating__c = 'B';
        pricingDetail.SC4_Tier__c = 'TIER 2';
        pricingDetail.Loan_Type__c = 'New';
        pricingDetail.Maximum_Exception_Amount__c = 10000;
        pricingDetail.Selected_Amount__c = 10000;
        pricingDetail.Origination_Fee_Percentage__c = 5;
        pricingDetail.Status__c = 'Sent To Customer';
        pricingDetail.Annual_Volume__c = 100000;
        insert pricingDetail;
        System.debug('pricingDetail:::::'+pricingDetail);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/calculatepricing/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', testUser.Email);
        req.addParameter('partnerAPIKey', account.Partner_API_Key__c);
        req.addParameter('term', '14');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCalculatePricingAPI.calculatePricing();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(200, resVal.statusCode);
    }

    @isTest
    static void partnerGetPricingAPIErrorOne() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/calculatepricing/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', 'error@mail.com');
        req.addParameter('partnerAPIKey', 'account.Partner_API_Key__c');
        req.addParameter('term', '14');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCalculatePricingAPI.calculatePricing();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }

    @isTest
    static void partnerGetPricingAPIErrorTwo() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/calculatepricing/';
        req.addParameter('application',application.Name);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerCalculatePricingAPI.calculatePricing();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }
}