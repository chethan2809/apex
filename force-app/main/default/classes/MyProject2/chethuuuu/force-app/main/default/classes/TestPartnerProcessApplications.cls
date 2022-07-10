@isTest
private class TestPartnerProcessApplications {
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

        User userRec = [SELECT Id, AccountId, Email, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];

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
    static void validateRequest () {
        Account account = new Account();
        account.Id = TestUtility.getFakeId(Account.getSObjectType());
        account.Name = 'TestPartnerCal';
        account.Partner_API_Key__c = GeneralHelper.generateUniqueReferenceId(account.Id);

        DBManagerTestsStub accountDBStubInstance = new DBManagerTestsStub();
        accountDBStubInstance.genericReturnObject = new List<Account>{account};
        PartnerAPIHelpers.accountDBInstance = (AccountDB) Test.createStub(AccountDB.class, accountDBStubInstance);

        Contact contact = new Contact();
        contact.LastName = 'test';
        contact.AccountId = account.Id;
        contact.Id = TestUtility.getFakeId(Contact.getSObjectType());

        DBManagerTestsStub contactDBStubInstance = new DBManagerTestsStub();
        contactDBStubInstance.genericReturnObject = new List<Contact>{contact};
        PartnerAPIHelpers.contactDBInstance = (ContactDB) Test.createStub(ContactDB.class, contactDBStubInstance);

        Map<String, String> testUserMap = new Map<String, String>();
        testUserMap.put('Id', TestUtility.getFakeId(User.getSObjectType()));
        testUserMap.put('ContactId', contact.Id);
        testUserMap.put('AccountId', contact.AccountId);
        testUserMap.put('Email', 'test@uniquedomain.com');
        String strUser = JSON.serialize(testUserMap);
        User testUser = (User) JSON.deserialize(strUser, User.class);

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{testUser};
        PartnerAPIHelpers.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Map<String, String> applicationMap = new Map<String, String>();
        applicationMap.put('Id', TestUtility.getFakeId(genesis__Applications__c.getSObjectType()));
        applicationMap.put('Name', 'APP-0000000678');
        applicationMap.put('Broker_Contact__c', testUser.ContactId);
        applicationMap.put('genesis__Status__c', Applications.STATUS_APPROVED);
        applicationMap.put('Overall_Status__c', Applications.STATUS_APPROVED);
        String jsonString = JSON.serialize(applicationMap);
        genesis__Applications__c application = (genesis__Applications__c) JSON.deserialize(jsonString, genesis__Applications__c.class);

        DBManagerTestsStub applicationDBStubInstance = new DBManagerTestsStub();
        applicationDBStubInstance.genericReturnObject = new List<genesis__Applications__c>{application};
        PartnerAPIHelpers.applicationDBInstance = (ApplicationDB) Test.createStub(ApplicationDB.class, applicationDBStubInstance);

        String str = '{"application":"'+application.Name+'","consentAccepted":true,"partnerDetails":{"partnerEmail":"'+ testUser.Email +'","partnerAPIKey":"'+ account.Partner_API_Key__c +'"}}';
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(str);

        Test.startTest();
           Id applicationId = PartnerProcessApplications.validateRequest(requestMap);
        Test.stopTest();

        System.assert(applicationId != null);
    }

    @isTest
    static void invokeApplicationProcess () {
        GeneralHelper.currentSystemDate = Date.newInstance(2019, 01, 01);
        User testUser = [SELECT Id, email, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com' LIMIT 1];
        genesis__Applications__c application = [SELECT Id, Name FROM genesis__Applications__c];

        Test.startTest();
            PartnerProcessApplications.invokeApplicationProcess(application.Id);
        Test.stopTest();
    }
}