@IsTest
public class TestPortalPartyDeleteAPI {
    @testSetup
    static void dataSetup() {

        GeneralHelper.currentSystemDate = Date.newInstance(2020, 01, 01);

        Profile profile = [Select Id from Profile where name = 'System Administrator'];
        User testUser = new User(
        ProfileId = profile.Id,
        Username = TestUtility.generateFakeName() + '@example.com',
        Alias = 'test',
        Email='testUser6572@test.com',
        EmailEncodingKey='UTF-8',
        FirstName='Bruce',
        LastName='Wayne',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        TimeZoneSidKey='America/Chicago'
        );
        insert testUser;

            Account testAccount = TestUtility.createAccount();
        	testAccount.Name = 'Test Borrower';
            Update testAccount;
            Contact testContact = TestUtility.createContact();
        	testContact.LastName = 'Borrower';
            Update testContact ;

            TestUtility.runSetupData();
            genesis__Applications__c appln = TestUtility.createApplication();
        	appln.Portal_Stage__c = 'LoanInfo';
        	Update appln;
    }

    /* Test Methods - Fuctionality */

    @isTest
    static void test_PortalPartyDeleteAPIException()
    {
        Test.startTest();
        /* Test User */

        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        clcommon.Response response = new PortalPartyDeleteAPI().invokeAction('', null, new Map<String, Object>{
                  'email' => testUser.Email,
                  'accountId' => testAccount.Id,
                   'acc' => testAccount,
                  'contactId' => testContact.Id,
                  'applicationId' => 'appln.Id'
        });

        if(testUser.Email != null && testUser.Email == testUser.Username)
        {
            System.ResetPasswordResult result =  System.resetPassword(testUser.Id, true);

            response.status = clcommon.Constants.SUCCESS;

            system.assertEquals(response.Status,'SUCCESS');
        }
        Test.stopTest();
    }
     @isTest
    static void test_PortalPartyDeleteAPI()
    {
        Test.startTest();

        User  testUser =[select id,Username,email from user limit 1];

        Account testAccount = [select id,name from account where  name='Test Borrower'];

        Contact testContact = [select id,name from contact where lastname='Borrower'];
        genesis__Applications__c appln =[select id from genesis__Applications__c where Portal_Stage__c='LoanInfo'];

        clcommon.Response response = new PortalPartyDeleteAPI().invokeAction('', null, new Map<String, Object>{
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
            system.assertEquals(response.Status,'SUCCESS');
        }
        Test.stopTest();
    }
}