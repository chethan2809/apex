@IsTest
private class TestCLSBPCompleteTaskPortalAPI {
     @testSetup
     static void dataSetup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];

        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account account = new Account(Name = 'Test Borrower');
            insert account;

            Account childAccount = new Account(Name = 'Test Child Account Name', ParentId = account.Id);
            insert childAccount;

            Contact contact = new Contact(LastName = 'Borrower', AccountId = account.Id);
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
        System.runAs(userRec) {
            TestUtility.runSetupData();
            genesis__Applications__c application = TestUtility.createApplication();
            application.Broker_Contact__c = userRec.ContactId;
            application.Portal_Stage__c='LoanInfo';
            update application;
            genesis__org_parameters__c orgParams = genesis__Org_Parameters__c.getOrgDefaults();
            orgParams.genesis__Digits_After_Decimals__c = 2;
            orgParams.genesis__Rounding_Mode__c = 'Nearest';
            upsert orgParams;
        }
    }

    @isTest
    static void test_CLSBPCompleteTaskPortal()
    {
        Account testAccount = [select id,name from account where  name='Test Borrower'];
        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c ];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;
        insert t;

        System.runAs(userRec) {
        Test.startTest();
        clcommon.Response response = new CLSBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => 'test@gmail.com',
                  'accountId' => testAccount.Id,
                  'acc' => testAccount,
                  'contactId' => testContact.Id,
                  CLSBPPortalConstants.APPLICATION_ID => appln.Id,
                  CLSBPPortalConstants.TASK_ID => t.Id
        });
        Test.stopTest();
        }
    }

    @isTest
    static void test_CLSBPCompleteTaskPortalException()
    {
        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;

        System.runAs(userRec) {
        Test.startTest();
        clcommon.Response response = new CLSBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => 'test@gmail.com',
                  'accountId' => testAccount.Id,
                  'acc' => testAccount,
                  'contactId' => testContact.Id,
                  CLSBPPortalConstants.APPLICATION_ID => appln.Id,
                  CLSBPPortalConstants.TASK_ID =>'taskId'

        });
        Test.stopTest();
        }
    }

    @isTest
    static void test_CLSBPCompleteTaskAlt()
    {
        User userRec = [SELECT Id, AccountId, ContactId FROM User WHERE Email = 'test@uniquedomain.com'];
        Account testAccount = [select id,name from account where  name='Test Borrower'];
        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c] ;
        Task t = new Task();
        t.Status = 'Completed';
        t.genesis__Application__c = appln.Id;

        insert t;

        String taskId = NuLL;
        System.runAs(userRec) {
        Test.startTest();
        clcommon.Response response = new CLSBPCompleteTaskPortalAPI().invokeAction('', null, new Map<String, Object>{
                 CLSBPPortalConstants.TASK_ID => t.Id
        });
        Test.stopTest();
        }
    }
}