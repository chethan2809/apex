@IsTest
private class TestPartnerProcessApplicationAPI {

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
    static void processApplication () {
        GeneralHelper.currentSystemDate = Date.newInstance(2019, 01, 01);
        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{"application":"'+application.Name+'","consentAccepted":true,"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"}}';

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/processapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerProcessApplicationAPI.processApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(200, resVal.statusCode);
    }

    @isTest
    static void processApplicationErrorOne() {
        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{"application":"applicationName","consentAccepted":true,"partnerDetails":{"partnerEmail":"'+ testUser.Email +'"}}';

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/processapplication/';
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerProcessApplicationAPI.processApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }

    @isTest
    static void processApplicationErrorTwo() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String str = '{}';

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/processapplication/';
        req.addParameter('application',application.Name);
        req.requestBody = Blob.valueof(str);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerProcessApplicationAPI.processApplication();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }
}