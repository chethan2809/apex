@isTest
public class TestCCSSPUserProfileEditAPI {

    @isTest
    static void CCSSPUserProfileEditAPI()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
        clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
            PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_CONTACT_PHONE,
                'accountId' =>acc.Id, 'contactId' => contactRecord.Id
                });
        Test.stopTest();
    }

    @isTest
    static void CCSSPUserProfileEditAPIEmail()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_ADDRESS,
                    'accountId' =>acc.Id, 'contactId' => contactRecord.Id
                    });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCSSPUserProfileEditAPIAddress()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_HOME_ADDRESS,
                    'accountId' =>acc.Id, 'contactId' => contactRecord.Id
                    });
        Test.stopTest();

        System.assertEquals(response.Status,'SUCCESS');
    }

    @isTest
    private static void CCSSPUserProfileEditAPIPhone()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE,
                    'accountId' =>acc.Id, 'contactId' => contactRecord.Id
                    });
        Test.stopTest();
        System.assert(response != null);
    }

    @isTest
    private static void CCSSPUserProfileEditAPIException()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE,
                    'accountId' =>acc.Id, 'contactId' => contactRecord.Id
                    });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCSSPUserProfileWithoutAccountIdException()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE,
                    'contactId' => acc.Id
                    });
        Test.stopTest();

        System.assert(response != null);
    }

    @isTest
    private static void CCSSPUserProfileWithoutContactIDException()
    {
        Contact contactRecord = TestUtility.generateContact();
        contactRecord.MobilePhone = '9191919191';
        contactRecord.Email = TestUtility.generateFakeName() + '@example.com';
        contactRecord.FirstName = 'ccss';
        contactRecord.LastName  = 'ssccuser';
        insert contactRecord;
        Account acc = TestUtility.createAccount();

        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = :GeneralConstants.BROKER_USER_PROFILE_NAME LIMIT 1];

        User newUser = new User();
        newUser.Alias = contactRecord.LastName.substring(0,2);
        newUser.Email = contactRecord.Email;
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.FirstName = contactRecord.FirstName;
        newUser.LastName = contactRecord.LastName;
        newUser.LanguageLocaleKey = 'en_US';
        newUser.LocaleSidKey = 'en_US';
        newUser.ContactId = contactRecord.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.Username = TestUtility.generateFakeName() + 'test2@test.com';
        newUser.CommunityNickname = 'nikc';
        newUser.ProfileId = profile.Id;
        newUser.IsActive = true;

        DBManagerTestsStub userDBStubInstance = new DBManagerTestsStub();
        userDBStubInstance.genericReturnObject = new List<User>{newUser};
        CCSSPUserProfileEditAPI.userDBInstance = (UserDB) Test.createStub(UserDB.class, userDBStubInstance);

        Test.startTest();
            clcommon.Response response = new CCSSPUserProfileEditAPI().invokeAction('', null, new Map<String, Object>{
                PortalConstants.BROKER_CONTACT_DETAILS => JSON.serialize(contactRecord),
                    PortalConstants.PROFILE_EDIT_TYPE =>PortalConstants.PROFILE_EDIT_TYPE_BUSINESS_PHONE,
                    'accountId' =>acc.Id
                    });
        Test.stopTest();

        System.assert(response != null);
    }
}