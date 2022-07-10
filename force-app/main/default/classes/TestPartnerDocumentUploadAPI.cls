@IsTest
private class TestPartnerDocumentUploadAPI {

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
            application.Type__c = 'New';
            application.Industry_Rating__c = 'B';
            application.SC4_Tier__c = 'TIER 2';
            application.genesis__Payment_Frequency__c = 'WEEKLY';
            update application;
        }
    }

    @isTest
    static void uploadDocument () {
        GeneralHelper.currentSystemDate = Date.newInstance(2019, 01, 01);
        User testUser = [SELECT Id, email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        Account account = new Account();
        account.Id = testUser.AccountId;
        account.Name = 'TestPartnerDocUpload';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        clcommon__Document_Definition__c docDef = new clcommon__Document_Definition__c();
        docDef.Name = 'Bank Statements';
        docDef.clcommon__Active__c = true;
        insert docDef;

        clcommon__Document_Category__c documentCategory = new clcommon__Document_Category__c();
        documentCategory.clcommon__Category_Name__c = 'Bank Statements';
        documentCategory.genesis__Application__c = application.Id;
        insert documentCategory;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/uploaddocs/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', testUser.Email);
        req.addParameter('partnerAPIKey', account.Partner_API_Key__c);
        req.addParameter('name','test.pdf');
        req.addParameter('documentType','Bank Statements');
        req.addParameter('contentType','application/pdf');

        req.requestBody = Blob.valueof('this is test pdf content');

        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
            PartnerDocumentUploadAPI.uploadDocument();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(200, resVal.statusCode);
    }

    @isTest
    static void uploadDocumentErrorOne() {
         genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/uploaddocs/';
        req.addParameter('application',application.Name);
        req.addParameter('partnerEmail','testUser1.email');
        req.addParameter('partnerAPIKey', 'Partner_API_Key__c');
        req.addParameter('name','test.pdf');
        req.addParameter('documentType','Bank Statements');
        req.addParameter('contentType','application/pdf');

        req.requestBody = Blob.valueof('this is test pdf content');

        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
            PartnerDocumentUploadAPI.uploadDocument();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }

    @isTest
    static void uploadDocumentEmptyBody() {
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

        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/v1/partner/uploaddocs/';
        req.addParameter('application', application.Name);
        req.addParameter('partnerEmail', testUser.Email);
        req.addParameter('partnerAPIKey', account.Partner_API_Key__c);
        req.addParameter('name','test.pdf');
        req.addParameter('documentType','Bank Statements');
        req.addParameter('contentType','application/pdf');

        req.requestBody = Blob.valueof('');

        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        PartnerDocumentUploadAPI.uploadDocument();
        Test.stopTest();

        RestResponse resVal = RestContext.response;
        System.assertEquals(500, resVal.statusCode);
    }
}