@isTest
private class TestPortalCreateUserAPI {

    @testSetup
    static void dataSetup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;
        System.debug('adminUser::::'+adminUser);

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
            application.Portal_Stage__c='LoanInfo';
            update application;
        }
    }

    @IsTest
    static void testCreateUserAPI() {
        Account testAccount = [select id,name from account where  name='Test Account Name'];
        Contact testContact = [select id,name,email,FirstName,LastName,AccountId from contact limit 1];
        System.debug('testContact.email::::'+testContact.email);

        //User testUser =[select id, ContactId, Username, email from user Limit 1];
        User testUser =[select id, ContactId, Username, email from user limit 1];
        System.debug('testUser.Username::::'+testUser.Username);

        genesis__Applications__c appln =[select id,Portal_Stage__c from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        Map<String,Object> con= new Map<String,String>{'contactId' => testContact.id, 'accountId' => testAccount.Id, 'password' => 'testpwd'};
        Map<String,Object> contactMap = new Map<String,Object>{'argumentsFromPortal' => con};

        clcommon.Response response = new PortalCreateUserAPI().invokeAction('', null, contactMap);
   }

   @IsTest
    static void testCreateUserAPI1() {
        Contact testContact = [select id,name,AccountId from contact limit 1];
        Account testAccount = [select id,name from account where Id = :testContact.AccountId];

        User  testUser =[select id,Username,email from user where contactId =: testContact.Id];

        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        Test.startTest();
        Map<String,Object> con= new Map<String,String>{'contactId' => testContact.id, 'accountId' => testAccount.Id, 'password' => 'testpwd'};
        Map<String,Object> contactMap = new Map<String,Object>{'argumentsFromPortal' => con};
        clcommon.Response response = new PortalCreateUserAPI().invokeAction('', null, contactMap);
        Test.stopTest();
   }
}