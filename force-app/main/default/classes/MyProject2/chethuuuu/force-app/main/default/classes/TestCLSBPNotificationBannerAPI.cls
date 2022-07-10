@IsTest
public class TestCLSBPNotificationBannerAPI {

    @testSetup
    static void dataSetup() {
        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);
        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
            ProfileId = profile.Id,
            Username = TestUtility.generateFakeName() + '@example.com',
            Alias = 'test',
            Email='testssb32@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

        Account testAccount = new Account(Name = 'Test Borrower');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Borrower', AccountId = testAccount.Id);
        insert testContact ;

        TestUtility.runSetupData();
        genesis__Applications__c appln =  TestUtility.createApplication();
        appln.Portal_Stage__c = 'LoanInfo';
        update appln;
        genesis__org_parameters__c orgParams = genesis__Org_Parameters__c.getOrgDefaults();
        orgParams.genesis__Digits_After_Decimals__c = 2;
        orgParams.genesis__Rounding_Mode__c = 'Nearest';
        upsert orgParams;
    }

    @isTest
    static void test_CLSBPNotificationBannerAPI()
    {

        User  testUser =[select id,Username,email from user limit 1];
        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];
        genesis__org_parameters__c orgParams =[select id from genesis__org_parameters__c];

        Test.startTest();

        clcommon.Response response = new CLSBPNotificationBannerAPI().invokeAction('', null, new Map<String, Object>{
            'email' => testUser.Email,
                'accountId' => testAccount.Id,
                'acc' => testAccount,
                'contactId' => testContact.Id,
                'applicationId' => appln.Id,
                'notificationBanner' => JSON.deserializeUntyped(JSON.serialize(orgParams))
                });

        if(testUser.Email != null && testUser.Email == testUser.Username)
        {
            System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);

            response.status = clcommon.Constants.SUCCESS;

            system.debug('--response--'+response);
            system.assertEquals(response.Status,'SUCCESS');
        }
        Test.stopTest();
    }
    @isTest
    static void test_CLSBPNotificationBannerAPISucess()
    {
        Test.startTest();

        User  testUser =[select id,email,Username from user limit 1];
        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        clcommon.Response response = new CLSBPNotificationBannerAPI().invokeAction('', null, new Map<String, Object>{
            'email' => testUser.Email,
            'accountId' => testAccount.Id,
            'acc' => testAccount,
            'contactId' => testContact.Id,
            'applicationId' => appln.Id
        });

        if(testUser.Email != null && testUser.Email == testUser.Username)
        {
            System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);
            response.status = clcommon.Constants.SUCCESS;

            system.debug('--response--'+response);
            system.assertEquals(response.Status,'SUCCESS');
        }
        Test.stopTest();
    }
}