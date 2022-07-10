@IsTest
private class TestPartnerGetApplicationStatusAPI {

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

        User userRec = [SELECT Id, AccountId, ContactId, Email FROM User WHERE Email = 'test@uniquedomain.com'];

        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account Name'];
        System.runAs(userRec) {
            TestUtility.runSetupData();
            genesis__Applications__c application = TestUtility.createApplication();
            application.Broker_Contact__c = userRec.ContactId;
            update application;
        }
    }

    @isTest
    static void partnerGetStatusAPI () {
        User testUser = [SELECT Id, Email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        Account account = new Account();
        account.Id = testUser.AccountId;
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/applicationstatus/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', testUser.Email);
        req.addParameter('partnerAPIKey', account.Partner_API_Key__c);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerGetApplicationStatusAPI.getApplicationStatus();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assert(resVal != null);
    }

    @isTest
    static void partnerGetStatusAPIErrorOne() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/applicationstatus/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', 'error@mail.com');
        req.addParameter('partnerAPIKey', 'Partner_API_Key__c');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerGetApplicationStatusAPI.getApplicationStatus();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }

    @isTest
    static void partnerGetStatusAPIErrorTwo() {
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'GET');
        req.requestUri = '/services/apexrest/v1/partner/applicationstatus/';
        req.addParameter('application',application.Name);

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerGetApplicationStatusAPI.getApplicationStatus();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(400, resVal.statusCode);
    }
}